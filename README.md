# 🎮 Jogo da Velha com IA em Prolog

Projeto acadêmico desenvolvido para a matéria de Paradigmas da programação da UTPFR-DV, curso de Engenharia de Software

## 📋 Sobre o projeto
Um jogo da velha clássico (Tic-Tac-Toe) desenvolvido em Prolog, onde o jogador humano enfrenta uma Inteligência Artificial baseada no algoritmo Minimax com cortes lógicos de vitória e bloqueio imediato.

A tomada de decisão da IA ocorre em três camadas hierárquicas prioritárias:
1. Vitória Imediata: Se houver uma coordenada livre que garanta a vitória, a IA joga nela.
2. Bloqueio de Oponente: Se o humano estiver prestes a ganhar, a IA intercepta a jogada.
3. Algoritmo Minimax: Caso contrário, a IA simula todas as jogadas futuras, escolhendo o caminho ideal com base na profundidade da árvore (10 - Profundidade).

---

## 🛠️ Ferramentas utilizadas
* SWI-Prolog (Ambiente de desenvolvimento e compilador para a linguagem Prolog)

---

## 🚀 Como Executar

### Pré-requisitos
Possuir o [SWI-Prolog](https://www.swi-prolog.org/download/stable) instalado na máquina

### Passo a passo
1. Clone o repositório:
   ```bash
   git clone https://github.com/MuriloDalMolim/Jogo_da_velha_prolog

2. Vá até o diretório do arquivo e execute o comando:
    ```bash
    swipl jogoDaVelha.pl

--- 

## 🎲 Como Jogar

O tabuleiro é mapeado por meio de uma matriz onde você escolhe a Linha (1 a 3) e a Coluna (1 a 3).

Atenção: Por ser um ambiente Prolog, todas as entradas numéricas digitadas no console devem ser finalizadas obrigatoriamente com um ponto final (.).

Exemplo de rodada:
Turno do Jogador 1 (Voce - X).
Digite a Linha (1-3): 2.
Digite a Coluna (1-3): 2.

Para desistir ou encerrar o jogo a qualquer momento da partida, basta digitar "-1." tanto para a linha quanto para a coluna.

---
