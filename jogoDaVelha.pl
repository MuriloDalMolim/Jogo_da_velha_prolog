:- initialization(iniciar, main).

posicao(1, 1, 0).
posicao(1, 2, 1).
posicao(1, 3, 2).
posicao(2, 1, 3).
posicao(2, 2, 4).
posicao(2, 3, 5).
posicao(3, 1, 6).
posicao(3, 2, 7).
posicao(3, 3, 8).


iniciar :-
    nl, write('=== JOGO DA VELHA COM IA AVANCADA (MINIMAX) ==='), nl,
    write('Jogador 1: Humano (X) | Jogador 2: Inteligencia Artificial (O)'), nl,
    TabInicial = [0,0,0,0,0,0,0,0,0],
    exibir_tabuleiro(TabInicial),
    rodar(TabInicial, 1, _),
    true.




exibir_tabuleiro(Tab) :-
    nl,
    imprimir_peca(Tab, 0), write(' | '), imprimir_peca(Tab, 1), write(' | '), imprimir_peca(Tab, 2), nl,
    write('---------'), nl,
    imprimir_peca(Tab, 3), write(' | '), imprimir_peca(Tab, 4), write(' | '), imprimir_peca(Tab, 5), nl,
    write('---------'), nl,
    imprimir_peca(Tab, 6), write(' | '), imprimir_peca(Tab, 7), write(' | '), imprimir_peca(Tab, 8), nl, nl.

imprimir_peca(Tab, Pos) :-
    nth0(Pos, Tab, Valor),
    (Valor == 0 -> write('.') ; 
     Valor == 1 -> write('X') ; 
     Valor == 2 -> write('O')).




vencedor(Tab, Jog) :-
    
    (nth0(0, Tab, Jog), nth0(1, Tab, Jog), nth0(2, Tab, Jog));
    (nth0(3, Tab, Jog), nth0(4, Tab, Jog), nth0(5, Tab, Jog));
    (nth0(6, Tab, Jog), nth0(7, Tab, Jog), nth0(8, Tab, Jog));
    
    (nth0(0, Tab, Jog), nth0(3, Tab, Jog), nth0(6, Tab, Jog));
    (nth0(1, Tab, Jog), nth0(4, Tab, Jog), nth0(7, Tab, Jog));
    (nth0(2, Tab, Jog), nth0(5, Tab, Jog), nth0(8, Tab, Jog));
    
    (nth0(0, Tab, Jog), nth0(4, Tab, Jog), nth0(8, Tab, Jog));
    (nth0(2, Tab, Jog), nth0(4, Tab, Jog), nth0(6, Tab, Jog)).

empate(Tab) :-
    \+ member(0, Tab),
    \+ vencedor(Tab, 1),
    \+ vencedor(Tab, 2).




jogar(Linha, Coluna, Tab, Jogador, NovoTab) :-
    posicao(Linha, Coluna, Pos),
    nth0(Pos, Tab, 0),
    substituir(Tab, Pos, Jogador, NovoTab).

substituir([_|T], 0, Valor, [Valor|T]) :- !.
substituir([H|T], Index, Valor, [H|R]) :-
    Index > 0,
    NextIndex is Index - 1,
    substituir(T, NextIndex, Valor, R).





avaliar(Tab, Profundidade, Pontuacao) :- 
    vencedor(Tab, 2), !, Pontuacao is 10 - Profundidade.
avaliar(Tab, Profundidade, Pontuacao) :- 
    vencedor(Tab, 1), !, Pontuacao is Profundidade - 10. 
avaliar(_, _, 0).


minimax(Tab, Profundidade, _, Pontuacao) :-
    (vencedor(Tab, _); empate(Tab)), !,
    avaliar(Tab, Profundidade, Pontuacao).

minimax(Tab, Profundidade, Jogador, MelhorPontuacao) :-
    ProximaProfundidade is Profundidade + 1,
    ProximoJogador is 3 - Jogador,
    findall(Pont, (posicao(_,_,P), nth0(P, Tab, 0), substituir(Tab, P, Jogador, NTab), minimax(NTab, ProximaProfundidade, ProximoJogador, Pont)), Pontuacoes),
    (Jogador == 2 -> max_list(Pontuacoes, MelhorPontuacao) ; min_list(Pontuacoes, MelhorPontuacao)).


escolher_melhor_movimento(Tab, MelhorPos) :-

    (posicao(_,_,P), nth0(P, Tab, 0), substituir(Tab, P, 2, NTab), vencedor(NTab, 2) -> MelhorPos = P, ! ;
    

    (posicao(_,_,P), nth0(P, Tab, 0), substituir(Tab, P, 1, NTab), vencedor(NTab, 1) -> MelhorPos = P, ! ;
    

    findall(Pont-P, (posicao(_,_,P), nth0(P, Tab, 0), substituir(Tab, P, 2, NTab), minimax(NTab, 0, 1, Pont)), Opcoes),
    keysort(Opcoes, Ordenado),
    last(Ordenado, _-MelhorPos))).




rodar(Tab, Jogador, _) :-
    Inverso is 3 - Jogador, 
    vencedor(Tab, Inverso), !,
    (Inverso == 1 -> write('Jogador 1 (Voce) venceu o jogo!') ; write('Jogador 2 (IA) venceu o jogo!')), nl,
    cancelar_execucao.

rodar(Tab, _, _) :-
    empate(Tab), !,
    write('O jogo terminou em empate!'), nl,
    cancelar_execucao.


rodar(Tab, 2, NovoTab) :-
    write('Turno do Jogador 2 (IA)... Pensando...'), nl,
    escolher_melhor_movimento(Tab, Pos),
    posicao(Linha, Coluna, Pos),
    jogar(Linha, Coluna, Tab, 2, TabAtualizado),
    write('IA jogou na Linha: '), write(Linha), write(' Coluna: '), write(Coluna), nl,
    exibir_tabuleiro(TabAtualizado),
    rodar(TabAtualizado, 1, NovoTab).


rodar(Tab, 1, NovoTab) :-
    write('Turno do Jogador 1 (Voce - X).'), nl,
    write('Digite a Linha (1-3): '), read(Linha),
    write('Digite a Coluna (1-3): '), read(Coluna),
    
    (Linha == -1, Coluna == -1 ->
        write('Jogo finalizado pelo usuario.'), nl,
        cancelar_execucao
    ;
        (posicao(Linha, Coluna, _) -> 
            (jogar(Linha, Coluna, Tab, 1, TabAtualizado) ->
                exibir_tabuleiro(TabAtualizado),
                rodar(TabAtualizado, 2, NovoTab)
            ;
                write('Jogada invalida! Essa posicao ja esta ocupada. Tente novamente.'), nl, nl,
                rodar(Tab, 1, NovoTab)
            )
        ;
            write('Jogada invalida! Coordenadas fora do tabuleiro. Tente novamente.'), nl, nl,
            rodar(Tab, 1, NovoTab)
        )
    ).

cancelar_execucao :-
    catch(halt, _, true).