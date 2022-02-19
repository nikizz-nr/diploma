from django.db import models
import datetime
import json
import requests


def toi_to_seconds(toi):
    tmp = toi.split(":")
    return int(tmp[0]) * 60 + int(tmp[1])


def second_to_toi(sec):
    return "{}:{}".format(sec // 60, sec % 60)


class Game(models.Model):
    game_date = models.DateField('Game date')
    game_pk = models.IntegerField("Game pk", null=False, default=0, unique=True)
    home_team = models.CharField('Home team', max_length=100, null=False, default='')
    home_score = models.IntegerField('Home team score', null=False, default=0)
    away_team = models.CharField('Away team', max_length=100, null=False, default='')
    away_score = models.IntegerField('Away team score', null=False, default=0)
    first_toi = models.CharField('Top 1 TOI player', max_length=100, null=False, default='')
    first_toi_time = models.IntegerField(
        'Top 1 TOI player time',
        null=False,
        default=0
    )
    second_toi = models.CharField('Top 2 TOI player', max_length=100, null=False, default='')
    second_toi_time = models.IntegerField(
        'Top 2 TOI player time',
        null=False,
        default=0
    )
    third_toi = models.CharField('Top 3 TOI player', max_length=100, null=False, default='')
    third_toi_time = models.IntegerField(
        'Top 3 TOI player time',
        null=False,
        default=0
    )

    @classmethod
    def get_stlouis_games(cls, start_date, end_date):
        url = 'https://statsapi.web.nhl.com/api/v1/schedule?startDate={}&endDate={}&expand=schedule.venue'.format(
            start_date,
            end_date
        )
        response = requests.get(url)
        if response.status_code == 200:
            game_json = json.loads(response.content.decode('utf-8'))
            Game.objects.all().delete()
        else:
            return 'nhl_api_unreachable'
        for dt in game_json['dates']:
            for dt_game in dt['games']:
                if 'venue' in dt_game:
                    if 'location' in dt_game['venue']:
                        if 'city' in dt_game['venue']['location']:
                            if (dt_game['venue']['location']['city']) == "St. Louis":
                                cls.objects.create(
                                    game_pk=int(dt_game['gamePk']),
                                    game_date=datetime.datetime.strptime(
                                        dt_game['gameDate'],
                                        "%Y-%m-%dT%H:%M:%SZ"
                                    ).date(),
                                    away_team=dt_game['teams']['away']['team']['name'],
                                    away_score=dt_game['teams']['away']['score'],
                                    home_team=dt_game['teams']['home']['team']['name'],
                                    home_score=dt_game['teams']['home']['score'],
                                    first_toi='',
                                    first_toi_time=0,
                                    second_toi='',
                                    second_toi_time=0,
                                    third_toi='',
                                    third_toi_time=0,
                                )
        return 'update_success'

    @classmethod
    def update_game_stats(cls):
        update = True
        qs = Game.objects.all()
        res = []
        for parsed_game in qs:
            url = 'https://statsapi.web.nhl.com/api/v1/game/{}/boxscore'.format(parsed_game.game_pk)
            response = requests.get(url)
            if response.status_code == 200:
                boxscore_json = json.loads(response.content.decode('utf-8'))
            else:
                return 'nhl_api_unreachable'
            players = {}
            for player_info in boxscore_json['teams']['away']['players'].values():
                if 'skaterStats' in player_info['stats']:
                    players[player_info['person']['fullName']] = \
                        toi_to_seconds(player_info['stats']['skaterStats']['timeOnIce'])
                elif 'goalieStats' in player_info['stats']:
                    players[player_info['person']['fullName']] = \
                        toi_to_seconds(player_info['stats']['goalieStats']['timeOnIce'])
            for player_info in boxscore_json['teams']['home']['players'].values():
                if 'skaterStats' in player_info['stats']:
                    players[player_info['person']['fullName']] = \
                        toi_to_seconds(player_info['stats']['skaterStats']['timeOnIce'])
                elif 'goalieStats' in player_info['stats']:
                    players[player_info['person']['fullName']] = \
                        toi_to_seconds(player_info['stats']['goalieStats']['timeOnIce'])
            tmp = sorted(players, key=players.get, reverse=True)[:3]
            top = {
                'game_pk': parsed_game.game_pk,
                'top1': tmp[0],
                'top1_time': players[tmp[0]],
                'top2': tmp[1],
                'top2_time': players[tmp[1]],
                'top3': tmp[2],
                'top3_time': players[tmp[2]]
            }
            res.append(top)
        if update:
            for parsed_game in res:
                o = Game.objects.get(game_pk=parsed_game['game_pk'])
                o.first_toi = parsed_game['top1']
                o.first_toi_time = parsed_game['top1_time']
                o.second_toi = parsed_game['top2']
                o.second_toi_time = parsed_game['top2_time']
                o.third_toi = parsed_game['top3']
                o.third_toi_time = parsed_game['top3_time']
                o.save()
        return 'update_success'

    @classmethod
    def get_best_toi_players(cls):
        players = {}
        for parsed_game in Game.objects.all():
            if parsed_game.first_toi not in players:
                players[parsed_game.first_toi] = parsed_game.first_toi_time
            else:
                players[parsed_game.first_toi] += parsed_game.first_toi_time
            if parsed_game.second_toi not in players:
                players[parsed_game.second_toi] = parsed_game.second_toi_time
            else:
                players[parsed_game.second_toi] += parsed_game.second_toi_time
            if parsed_game.third_toi not in players:
                players[parsed_game.third_toi] = parsed_game.third_toi_time
            else:
                players[parsed_game.third_toi] += parsed_game.third_toi_time
        tmp = sorted(players, key=players.get, reverse=True)[:3]
        if len(tmp) == 3:
            return {
                'first': tmp[0],
                'first_time': second_to_toi(players[tmp[0]]),
                'second': tmp[1],
                'second_time': second_to_toi(players[tmp[1]]),
                'third': tmp[2],
                'third_time': second_to_toi(players[tmp[2]])
            }
        else:
            return {
                'first': "Not enough data",
                'first_time': "0",
                'second': "Not enough data",
                'second_time': "0",
                'third': "Not enough data",
                'third_time': "0",
            }

    @classmethod
    def get_data(cls):
        prepared_data = []
        data = cls.objects.all()
        for rec in data:
            tmp = {
                'date': rec.game_date,
                'home': rec.home_team,
                'away': rec.away_team,
                'score': '{}:{}'.format(rec.home_score, rec.away_score),
                'first': rec.first_toi,
                'first_time': second_to_toi(rec.first_toi_time),
                'second': rec.second_toi,
                'second_time': second_to_toi(rec.second_toi_time),
                'third': rec.third_toi,
                'third_time': second_to_toi(rec.third_toi_time),
            }
            prepared_data.append(tmp)
        return prepared_data
