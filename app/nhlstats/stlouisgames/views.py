from django.shortcuts import render, redirect
from .models import Game
from django.http import Http404


def index(request):
    # TODO Change static dates for calculated
    start_date = "2021-02-01"
    end_date = "2021-02-28"
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
