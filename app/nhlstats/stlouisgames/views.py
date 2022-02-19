from django.shortcuts import render, redirect
from .models import Game
from django.http import Http404


def index(request):
    today = datetime.today()
    if today.month == 1:
        start_date = today.replace(month=12, year=today.year-1, day=1)
    else:
        start_date = today.replace(month=today.month-1)
    end_date = start_date.replace(day=monthrange(start_date.year, start_date.month)[1]).strftime('%Y-%m-%d')
    start_date = start_date.strftime('%Y-%m-%d')
    if request.method == 'POST':
        Game.get_stlouis_games(start_date, end_date)
        Game.update_game_stats()
        return redirect('index')
    elif request.method == 'GET':
        context = {
            'data': Game.get_data(),
            'top3': Game.get_best_toi_players(),
            'start_date': start_date,
            'end_date': end_date
        }
    else:
        raise Http404("Wrong method")
    return render(request, 'stlouisgames/index.html', context)