% Define que o predicado 'iniciar' será executado automaticamente ao iniciar o programa.
:- initialization(iniciar, main).

% Mapeia as coordenadas de matriz (Linha, Coluna) para uma posição que vai de 0 a 8 na lista.
posicao(1, 1, 0).
posicao(1, 2, 1).
posicao(1, 3, 2).
posicao(2, 1, 3).
posicao(2, 2, 4).
posicao(2, 3, 5).
posicao(3, 1, 6).
posicao(3, 2, 7).
posicao(3, 3, 8).



% ==========================================
% REGRAS DE VERIFICAÇÃO DE ESTADO

% Prepara a interface inicial, zera o tabuleiro e inicia o jogo.
iniciar :-
    nl, write('=== Inicio do jogo! ==='), nl,
    write('Jogador 1: Humano (X) | Jogador 2: Inteligencia Artificial (O)'), nl,
    TabInicial = [0,0,0,0,0,0,0,0,0],   % Cria a lista com 9 posições zeradas.
    tabuleiro(TabInicial),              % Imprime o tabuleiro inicial vazio na tela.
    rodar(TabInicial, 1, _),            % Inicia o jogo com a vez do Jogador 1.
    true.



% Desenha visualmente a grade do Jogo da Velha no console.
tabuleiro(Tab) :-
    nl,
    imprimirPeca(Tab, 0), write(' | '), imprimirPeca(Tab, 1), write(' | '), imprimirPeca(Tab, 2), nl,
    write('---------'), nl,
    imprimirPeca(Tab, 3), write(' | '), imprimirPeca(Tab, 4), write(' | '), imprimirPeca(Tab, 5), nl,
    write('---------'), nl,
    imprimirPeca(Tab, 6), write(' | '), imprimirPeca(Tab, 7), write(' | '), imprimirPeca(Tab, 8), nl, nl.

% Converte os valores numéricos internos em caracteres textuais.
imprimirPeca(Tab, Pos) :-
    nth0(Pos, Tab, Valor),
    (Valor == 0 -> write('.') ; 
     Valor == 1 -> write('X') ; 
     Valor == 2 -> write('O')).



% ==========================================
% REGRAS DE VERIFICAÇÃO 

% Define todas as condições possíveis de vitória para um jogador.
vencedor(Tab, Jog) :-
    
    % Linhas horizontais:
    (nth0(0, Tab, Jog), nth0(1, Tab, Jog), nth0(2, Tab, Jog));
    (nth0(3, Tab, Jog), nth0(4, Tab, Jog), nth0(5, Tab, Jog));
    (nth0(6, Tab, Jog), nth0(7, Tab, Jog), nth0(8, Tab, Jog));
    
    % Colunas verticais:
    (nth0(0, Tab, Jog), nth0(3, Tab, Jog), nth0(6, Tab, Jog));
    (nth0(1, Tab, Jog), nth0(4, Tab, Jog), nth0(7, Tab, Jog));
    (nth0(2, Tab, Jog), nth0(5, Tab, Jog), nth0(8, Tab, Jog));
    
    % Diagonais:
    (nth0(0, Tab, Jog), nth0(4, Tab, Jog), nth0(8, Tab, Jog));
    (nth0(2, Tab, Jog), nth0(4, Tab, Jog), nth0(6, Tab, Jog)).

% Verifica se o jogo terminou empatado (tabuleiro cheio e sem vencedores).
empate(Tab) :-
    \+ member(0, Tab),      % Garante que não há nenhuma posição com valor 0 (vazia).
    \+ vencedor(Tab, 1),    % Garante que o jogador 1 não venceu.
    \+ vencedor(Tab, 2).    % Garante que o jogador 2 não venceu.



% ==========================================
% MANIPULAÇÃO E ATUALIZAÇÃO DO TABULEIRO

% Realiza uma jogada validando a posição informada e atualizando o tabuleiro.
jogar(Linha, Coluna, Tab, Jogador, NovoTab) :-
    posicao(Linha, Coluna, Pos),                % Converte (Linha, Coluna) para a posição.
    nth0(Pos, Tab, 0),                          % Garante que a posição escolhida está vazia (0).
    substituir(Tab, Pos, Jogador, NovoTab).     % Substitui o 0 pelo número do Jogador.

% Predicado auxiliar recursivo para alterar o valor de um índice específico em uma lista.
substituir([_|T], 0, Valor, [Valor|T]) :- !.    % Caso base: chegou ao índice 0, substitui a cabeça.
substituir([H|T], Index, Valor, [H|R]) :-       % Caso recursivo: caminha pela lista decrementando o índice.
    Index > 0,
    NextIndex is Index - 1,
    substituir(T, NextIndex, Valor, R).



% ==========================================
% INTELIGÊNCIA ARTIFICIAL

% Atribui uma pontuação heurística ao estado atual com base na profundidade da árvore de busca.
avaliar(Tab, Profundidade, Pontuacao) :- 
    vencedor(Tab, 2), !, Pontuacao is 10 - Profundidade.    % IA ganhou: pontuação positiva (favorece vitórias mais rápidas).
avaliar(Tab, Profundidade, Pontuacao) :- 
    vencedor(Tab, 1), !, Pontuacao is Profundidade - 10.    % Humano ganhou: pontuação negativa (evita derrotas rápidas).
avaliar(_, _, 0).                                           % Empate ou jogo inacabado recebe pontuação neutra (0).

% Caso base: Se o jogo acabou, calcula a pontuação final daquele ramo.
minimax(Tab, Profundidade, _, Pontuacao) :-
    (vencedor(Tab, _); empate(Tab)), !,
    avaliar(Tab, Profundidade, Pontuacao).

% Caso recursivo: Simula as jogadas futuras de ambos os jogadores.
minimax(Tab, Profundidade, Jogador, MelhorPontuacao) :-
    ProximaProfundidade is Profundidade + 1,
    ProximoJogador is 3 - Jogador,      % Alterna dinamicamente entre os jogadores.
    findall(Pont, (posicao(_,_,P), nth0(P, Tab, 0), substituir(Tab, P, Jogador, NTab), minimax(NTab, ProximaProfundidade, ProximoJogador, Pont)), Pontuacoes),
    % 'findall' gera uma lista contendo as pontuações de todos os tabuleiros futuros válidos possíveis.
    (Jogador == 2 -> max_list(Pontuacoes, MelhorPontuacao) ; min_list(Pontuacoes, MelhorPontuacao)).
    % Se for a vez da IA, ela maximiza a pontuação. Se for o humano, ela assume que ele vai minimizar.

% Estratégia de tomada de decisão da IA.
melhorMovimento(Tab, MelhorPos) :-

    % Se a IA puder vencer na próxima jogada, ela joga nessa posição imediatamente.
    (posicao(_,_,P), nth0(P, Tab, 0), substituir(Tab, P, 2, NTab), vencedor(NTab, 2) -> MelhorPos = P, ! ;
    
    % Se o humano estiver prestes a vencer, a IA joga ali para bloqueá-lo.
    (posicao(_,_,P), nth0(P, Tab, 0), substituir(Tab, P, 1, NTab), vencedor(NTab, 1) -> MelhorPos = P, ! ;
    
    % Se não houver vitória ou bloqueio imediato, roda o Minimax completo para escolher a melhor jogada a longo prazo.
    findall(Pont-P, (posicao(_,_,P), nth0(P, Tab, 0), substituir(Tab, P, 2, NTab), minimax(NTab, 0, 1, Pont)), Opcoes),
    keysort(Opcoes, Ordenado),
    last(Ordenado, _-MelhorPos))).


% ==========================================
% LOOP PRINCIPAL DO JOGO

% Verifica se o jogador da rodada anterior venceu o jogo.
rodar(Tab, Jogador, _) :-
    Inverso is 3 - Jogador, 
    vencedor(Tab, Inverso), !,
    (Inverso == 1 -> write('Jogador 1 (Voce) venceu o jogo!') ; write('Jogador 2 (IA) venceu o jogo!')), nl,
    cancelarExecucao.

% Verifica se o jogo empatou.
rodar(Tab, _, _) :-
    empate(Tab), !,
    write('O jogo terminou em empate!'), nl,
    cancelarExecucao.

% Fluxo de Turno: IA.
rodar(Tab, 2, NovoTab) :-
    write('Turno do Jogador 2 (IA)... Pensando...'), nl,
    melhorMovimento(Tab, Pos),                      % Calcula a melhor posição para jogar.
    posicao(Linha, Coluna, Pos),                    % Converte a posição para coordenadas de matriz.
    jogar(Linha, Coluna, Tab, 2, TabAtualizado),    % Executa a jogada da IA.
    write('IA jogou na Linha: '), write(Linha), write(' Coluna: '), write(Coluna), nl,
    tabuleiro(TabAtualizado),                       % Mostra o tabuleiro atualizado.
    rodar(TabAtualizado, 1, NovoTab).               % Passa a vez para o Jogador 1.

% Fluxo de Turno: Jogador.
rodar(Tab, 1, NovoTab) :-
    write('Turno do Jogador 1 (Voce - X).'), nl,
    % Leitura das linhas e colunas:
    write('Digite a Linha (1-3): '), read(Linha),
    write('Digite a Coluna (1-3): '), read(Coluna),
    
    (Linha == -1, Coluna == -1 ->
        write('Jogo finalizado pelo usuario.'), nl,
        cancelarExecucao
    ;
        % Verifica se as coordenadas inseridas existem no tabuleiro.
        (posicao(Linha, Coluna, _) -> 
            % Tenta executar a jogada (falhará se a posição já estiver ocupada).
            (jogar(Linha, Coluna, Tab, 1, TabAtualizado) ->
                tabuleiro(TabAtualizado),
                rodar(TabAtualizado, 2, NovoTab)    % Jogada válida: passa a vez para a IA.
            ;
                % Se falhar por ocupação, repete o turno do jogador 1.
                write('Jogada invalida! Essa posicao ja esta ocupada. Tente novamente.'), nl, nl,
                rodar(Tab, 1, NovoTab)
            )
        ;
            % Se falhar por coordenadas inválidas, repete o turno do jogador 1.
            write('Jogada invalida! Coordenadas fora do tabuleiro. Tente novamente.'), nl, nl,
            rodar(Tab, 1, NovoTab)
        )
    ).

% Finaliza o interpretador Prolog de forma segura.
cancelarExecucao :-
    catch(halt, _, true).
