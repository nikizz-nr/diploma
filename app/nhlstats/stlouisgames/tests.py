from django.test import TestCase
from .models import Game, toi_to_seconds
import datetime


class GameTestCase(TestCase):
    start_test = datetime.date(2021, 2, 1)
    end_test = datetime.date(2021, 2, 6)

    def test_games_getting(self):
        res = Game.get_stlouis_games(self.start_test, self.end_test)
        self.assertTrue(res == 'update_success' or res == 'nhl_api_unreachable', msg='Wrong function return')

    def test_update_game_stats_getting(self):
        Game.get_stlouis_games(self.start_test, self.end_test)
        Game.update_game_stats()
        parsed_games = Game.objects.all()
        for i in parsed_games:
            self.assertNotEqual(i.first_toi, '', msg='Empty top 1 TOU player')
            self.assertNotEqual(i.second_toi, '', msg='Empty top 2 TOU player')
            self.assertNotEqual(i.third_toi, '', msg='Empty top 3 TOU player')
            self.assertGreater(i.first_toi_time, i.second_toi_time, msg='Bad TOI order')
            self.assertGreater(i.second_toi_time, i.third_toi_time, msg='Bad TOI order')

    def test_get_best_toi_players(self):
        Game.get_stlouis_games(self.start_test, self.end_test)
        Game.update_game_stats()
        top = Game.get_best_toi_players()
        self.assertTrue(isinstance(top, dict), msg='Function returned non-dict')
        self.assertEqual(len(top), 6, msg='Function must return 3 records')
        self.assertNotEqual(top['first'], '', msg='Empty top 1 player name')
        self.assertNotEqual(top['second'], '', msg='Empty top 2 player name')
        self.assertNotEqual(top['second'], '', msg='Empty top 3 player name')
        self.assertGreater(toi_to_seconds(top['first_time']), toi_to_seconds(top['second_time']))
        self.assertGreater(toi_to_seconds(top['second_time']), toi_to_seconds(top['third_time']))

    def test_get_data(self):
        Game.get_stlouis_games(self.start_test, self.end_test)
        Game.update_game_stats()
        data = Game.get_data()
        self.assertTrue(isinstance(data, list), msg='Function returned non-dict')
