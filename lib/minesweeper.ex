defmodule MyEnum do
  @moduledoc """
    Funções de processamento de lista úteis.
  """

  @doc """
  Aplica fun/2 para cada um dos itens da lista com um acumulador e retorna o último resultado de fun/2.

  O resultado de cada aplicação de fun é passado como argumento para a próxima aplicação.

  fun/2 deve ter a seguinte assinatura: fun(el, acc)
  """

  @doc since: "0.0.0"

  def list_process([], acc, _fun), do: acc

  def list_process([h | t], acc, fun) do
    list_process(t, fun.(h, acc), fun)
  end
end

defmodule Minesweeper do
  # PRIMEIRA PARTE - FUNÇÕES PARA MANIPULAR OS TABULEIROS DO JOGO (MATRIZES)

  # A ideia das próximas funções é permitir que a gente acesse uma lista usando um indice,
  # como se fosse um vetor

  # get_arr/2 (get array):  recebe uma lista (vetor) e uma posicao (p) e devolve o elemento
  # na posição p do vetor. O vetor começa na posição 0 (zero). Não é necessário tratar erros.

  def get_arr([h | _t], 0), do: h
  def get_arr([_h | t], n), do: get_arr(t, n - 1)

  # update_arr/3 (update array): recebe uma lista(vetor), uma posição (p) e um novo valor (v)e devolve um
  # novo vetor com o valor v na posição p. O vetor começa na posição 0 (zero)

  def update_arr([_h | t], 0, v), do: [v | t]
  def update_arr([h | t], n, v), do: [h | update_arr(t, n - 1, v)]

  # O tabuleiro do jogo é representado como uma matriz. Uma matriz, nada mais é do que um vetor de vetores.
  # Dessa forma, usando as operações anteriores, podemos criar funções para acessar os tabuleiros, como
  # se  fossem matrizes:

  # get_pos/3 (get position): recebe um tabuleiro (matriz), uma linha (l) e uma coluna (c) (não precisa validar).
  # Devolve o elemento na posicao tabuleiro[l,c]. Usar get_arr/2 na implementação

  def get_pos(tab, l, c), do: get_arr(get_arr(tab, l), c)

  # update_pos/4 (update position): recebe um tabuleiro, uma linha, uma coluna e um novo valor. Devolve
  # o tabuleiro modificado com o novo valor na posiçao linha x coluna. Usar update_arr/3 e get_arr/2 na implementação

  def update_pos(tab, l, c, v), do: update_arr(tab, l, update_arr(get_arr(tab, l), c, v))

  # SEGUNDA PARTE: LÓGICA DO JOGO

  # -- is_mine/3: recebe um tabuleiro com o mapeamento das minas, uma linha, uma coluna. Devolve true caso a posição contenha
  # uma mina e false caso contrário. Usar get_pos/3 na implementação
  #
  # Exemplo de tabuleiro de minas:
  #
  # mines_board = [[false, false, false, false, false, false, false, false, false],
  #                 [false, false, false, false, false, false, false, false, false],
  #                 [false, false, false, false, false, false, false, false, false],
  #                 [false, false, false, false, false, false, false, false, false],
  #                 [false, false, false, false, true , false, false, false, false],
  #                 [false, false, false, false, false, true, false, false, false],
  #                 [false, false, false, false, false, false, false, false, false],
  #                 [false, false, false, false, false, false, false, false, false],
  #                 [false, false, false, false, false, false, false, false, false]]
  #
  # esse tabuleiro possuí minas nas posições 4x4 e 5x5

  def is_mine(tab, l, c), do: get_pos(tab, l, c)

  # para testes, apagar dps
  def get_mines_board() do
    [
      [false, false, false, false, false, false, false, false, false],
      [false, false, false, false, false, false, false, false, false],
      [false, false, false, false, false, false, false, false, false],
      [false, false, false, false, false, false, false, false, false],
      [false, false, false, false, true, false, false, false, false],
      [false, false, false, false, false, true, false, false, false],
      [false, false, false, false, false, false, false, false, false],
      [false, false, false, false, false, false, false, false, false],
      [false, false, false, false, false, false, false, false, false]
    ]
  end

  # para testes, apagar dps
  def get_tab() do
    [
      ["-", "-", "-", "-", "-", "-", "-", "-", "-"],
      ["-", "-", "-", "-", "-", "-", "-", "-", "-"],
      ["-", "-", "-", "-", "-", "-", "-", "-", "-"],
      ["-", "-", "-", "-", "-", "-", "-", "-", "-"],
      ["-", "-", "-", "-", "-", "-", "-", "-", "-"],
      ["-", "-", "-", "-", "-", "-", "-", "-", "-"],
      ["-", "-", "-", "-", "-", "-", "-", "-", "-"],
      ["-", "-", "-", "-", "-", "-", "-", "-", "-"],
      ["-", "-", "-", "-", "-", "-", "-", "-", "-"]
    ]
  end

  # is_valid_pos/3 recebe o tamanho do tabuleiro (ex, em um tabuleiro 9x9, o tamanho é 9),
  # uma linha e uma coluna, e diz se essa posição é válida no tabuleiro. Por exemplo, em um tabuleiro
  # de tamanho 9, as posições 1x3,0x8 e 8x8 são exemplos de posições válidas. Exemplos de posições
  # inválidas seriam 9x0, 10x10 e -1x8

  def is_valid_pos(tamanho, l, c), do: l >= 0 && l < tamanho && (c >= 0 && c < tamanho)

  # valid_moves/3: Dado o tamanho do tabuleiro e uma posição atual (linha e coluna), retorna uma lista
  # com todas as posições adjacentes à posição atual
  # Exemplo: Dada a posição linha 3, coluna 3, as posições adjacentes são: [{2,2},{2,3},{2,4},{3,2},{3,4},{4,2},{4,3},{4,4}]
  #   ...   ...      ...    ...   ...
  #   ...  (2,2)    (2,3)  (2,4)  ...
  #   ...  (3,2)    (3,3)  (3,4)  ...
  #   ...  (4,2)    (4,3)  (4,4)  ...
  #   ...   ...      ...    ...   ...

  #  Dada a posição (0,0) que é um canto, as posições adjacentes são: [(0,1),(1,0),(1,1)]

  #  (0,0)  (0,1) ...
  #  (1,0)  (1,1) ...
  #   ...    ...  ..
  # Uma maneira de resolver seria gerar todas as 8 posições adjacentes e depois filtrar as válidas usando is_valid_pos

  def valid_moves(tam, l, c) do
    mov = [
      {l - 1, c - 1},
      {l - 1, c},
      {l - 1, c + 1},
      {l, c - 1},
      {l, c + 1},
      {l + 1, c - 1},
      {l + 1, c},
      {l + 1, c + 1}
    ]

    Enum.filter(mov, fn el -> is_valid_pos(tam, elem(el, 0), elem(el, 1)) end)
  end

  # conta_minas_adj/3: recebe um tabuleiro com o mapeamento das minas e uma  uma posicao  (linha e coluna), e conta quantas minas
  # existem nas posições adjacentes

  def conta_minas_adj(tab, l, c) do
    adj_pos = valid_moves(length(tab), l, c)

    num_minas =
      Enum.map(
        adj_pos,
        fn x ->
          case get_pos(tab, elem(x, 0), elem(x, 1)) do
            true -> 1
            false -> 0
          end
        end
      )

    Enum.reduce(num_minas, 0, &Kernel.+/2)
  end

  # abre_jogada/4: é a função principal do jogo!!
  # recebe uma posição a ser aberta (linha e coluna), o mapa de minas e o tabuleiro do jogo.

  # -> Devolve como resposta o tabuleiro do jogo modificado com essa jogada.

  # Essa função é recursiva, pois no caso da entrada ser uma posição sem minas adjacentes, o algoritmo deve
  # seguir abrindo todas as posições adjacentes até que se encontre posições adjacentes à minas.

  # Vamos analisar os casos:
  # - Se a posição a ser aberta é uma mina, o tabuleiro não é modificado e encerra
  # - Se a posição a ser aberta já foi aberta, o tabuleiro não é modificado e encerra
  # - Se a posição a ser aberta é adjacente a uma ou mais minas, devolver o tabuleiro modificado com o número de
  # minas adjacentes na posição aberta
  # - Se a posição a ser aberta não possui minas adjacentes, abrimos ela com zero (0) e recursivamente abrimos
  # as outras posições adjacentes a ela

  def abre_jogada(l, c, minas, tab) do
    cond do
      # Verifica se é mina
      is_mine(minas, l, c) ->
        tab

      # Verifica se já foi aberta
      get_pos(tab, l, c) != "-" ->
        tab

      true ->
        num_minas_adj = conta_minas_adj(minas, l, c)

        case num_minas_adj do
          # Não possui minas adjacentes, chamadas recursivas
          0 ->
            tab = update_pos(tab, l, c, "0")

            lista_jogadas = valid_moves(length(tab), l, c)

            abre_lista_jogadas(lista_jogadas, minas, tab)

          # Possui minas adjacentes
          _ ->
            update_pos(tab, l, c, "#{num_minas_adj}")
        end
    end
  end

  defp abre_lista_jogadas([], _minas, tab), do: tab

  defp abre_lista_jogadas([h | t], minas, tab) do
    novo_tab = abre_jogada(elem(h, 0), elem(h, 1), minas, tab)

    abre_lista_jogadas(t, minas, novo_tab)
  end

  # abre_posicao/4, que recebe um tabueiro de jogos, o mapa de minas, uma linha e uma coluna
  # Essa função verifica:
  # - Se a posição {l,c} já está aberta (contém um número), então essa posição não deve ser modificada
  # - Se a posição {l,c} contém uma mina no mapa de minas, então marcar  com "*" no tabuleiro
  # - Se a posição {l,c} está fechada (contém "-"), escrever o número de minas adjascentes a esssa posição no tabuleiro (usar conta_minas)

  def abre_posicao(tab, minas, l, c) do
    cond do
      # Verifica se a posição já está aberta
      get_pos(tab, l, c) != "-" ->
        tab

      # Verifica se é mina
      is_mine(minas, l, c) ->
        update_pos(tab, l, c, "*")

      # Posição fechada
      true ->
        num_minas_adj = conta_minas_adj(minas, l, c)

        update_pos(tab, l, c, "#{num_minas_adj}")
    end
  end

  # abre_tabuleiro/2: recebe o mapa de Minas e o tabuleiro do jogo, e abre todo o tabuleiro do jogo, mostrando
  # onde estão as minas e os números nas posições adjecentes às minas.Essa função é usada para mostrar
  # todo o tabuleiro no caso de vitória ou derrota. Para implementar esta função, usar a função abre_posicao/4

  def abre_tabuleiro(minas, tab) do
    percorre_tabuleiro(tab, minas, 0, 0)
  end

  defp percorre_tabuleiro(tab, minas, l, c) do
    tam_tab = length(tab)

    cond do
      l == tam_tab ->
        tab

      c == tam_tab ->
        percorre_tabuleiro(tab, minas, l + 1, 0)

      true ->
        novo_tab = abre_posicao(tab, minas, l, c)
        percorre_tabuleiro(novo_tab, minas, l, c + 1)
    end
  end

  # board_to_string/1: -- Recebe o tabuleiro do jogo e devolve uma string que é a representação visual desse tabuleiro.
  # Essa função é aplicada no tabuleiro antes de fazer o print dele na tela. Usar a sua imaginação para fazer um
  # tabuleiro legal. Olhar os exemplos no .pdf com a especificação do trabalho. Não esquecer de usar \n para quebra de linhas.
  # Você pode quebrar essa função em mais de uma: print_header, print_linhas, etc...

  # def board_to_string(tab) do
  #   # Imprime topo do tabuleiro
  #   str_tab_top = print_tab_top(length(tab)) <> "\n"

  #   # Imprime corpo do tabuleiro
  #   str_tab =
  #     MyEnum.list_process(tab, {"", 0}, fn el, acc ->
  #       {elem(acc, 0) <> "#{elem(acc, 1)} " <> list_to_string(el) <> "\n", elem(acc, 1) + 1}
  #     end)

  #   str_tab_top <> elem(str_tab, 0)
  # end

  # Usei esse para habilitar cores :)
  def print_board(tab) do
    # Imprime topo do tabuleiro
    str_tab_top = print_tab_top(length(tab))
    Printex.prints(str_tab_top, :yellow)

    # Imprime corpo do tabuleiro
    MyEnum.list_process(tab, 0, fn el, acc ->
      IO.puts(IO.ANSI.yellow() <> "#{acc} " <> IO.ANSI.reset() <> list_to_string(el))

      acc + 1
    end)
  end

  defp print_interval(from, to) when from == to, do: ""

  defp print_interval(from, to) do
    "#{from} " <> print_interval(from + 1, to)
  end

  defp print_tab_top(tab_len) do
    "  " <> print_interval(0, tab_len)
  end

  defp list_to_string([]), do: ""

  defp list_to_string([h | t]) do
    h <> " " <> list_to_string(t)
  end

  # gera_lista/2: recebe um inteiro n, um valor v, e gera uma lista contendo n vezes o valor v

  def gera_lista(0, _v), do: []
  def gera_lista(n, v), do: [v | gera_lista(n - 1, v)]

  # -- gera_tabuleiro/1: recebe o tamanho do tabuleiro de jogo e gera um tabuleiro  novo, todo fechado (todas as posições
  # contém "-"). Usar gera_lista

  def gera_tabuleiro(n), do: gera_lista(n, gera_lista(n, "-"))

  # -- gera_mapa_de_minas/1: recebe o tamanho do tabuleiro e gera um mapa de minas zero, onde todas as posições contém false

  def gera_mapa_de_minas(n), do: gera_lista(n, gera_lista(n, false))

  # conta_fechadas/1: recebe um tabueleiro de jogo e conta quantas posições fechadas existem no tabuleiro (posições com "-")

  def conta_fechadas(tab) do
    fechadas_por_linha =
      Enum.map(tab, fn el ->
        conta_simbolo_linha(el, "-", 0)
      end)

    Enum.reduce(fechadas_por_linha, 0, &Kernel.+/2)
  end

  defp conta_simbolo_linha([], _symbol, acc), do: acc

  defp conta_simbolo_linha([h | t], symbol, acc) when h == symbol,
    do: conta_simbolo_linha(t, symbol, acc + 1)

  defp conta_simbolo_linha([_h | t], symbol, acc), do: conta_simbolo_linha(t, symbol, acc)

  # -- conta_minas/1: Recebe o tabuleiro de Minas (MBoard) e conta quantas minas existem no jogo

  def conta_minas(minas) do
    minas_por_linha =
      Enum.map(minas, fn el ->
        conta_simbolo_linha(el, true, 0)
      end)

    Enum.reduce(minas_por_linha, 0, &Kernel.+/2)
  end

  # end_game?/2: recebe o tabuleiro de minas, o tauleiro do jogo, e diz se o jogo acabou.
  # O jogo acabou quando o número de casas fechadas é igual ao numero de minas
  def end_game(minas, tab), do: conta_fechadas(tab) == conta_minas(minas)

  #### fim do módulo
end

###################################################################
###################################################################

# A seguir está o motor do jogo!
# Somente descomentar essas linhas quando as funções do módulo anterior estiverem
# todas implementadas

defmodule Motor do
  def main() do
    v = IO.gets("Digite o tamanho do tabuleiro: \n")
    {size, _} = Integer.parse(v)
    minas = gen_mines_board(size)
    IO.inspect(minas)
    tabuleiro = Minesweeper.gera_tabuleiro(size)
    game_loop(minas, tabuleiro)
  end

  def game_loop(minas, tabuleiro) do
    Minesweeper.print_board(tabuleiro)
    v = IO.gets("Digite uma linha: \n")
    {linha, _} = Integer.parse(v)
    v = IO.gets("Digite uma coluna: \n")
    {coluna, _} = Integer.parse(v)

    if Minesweeper.is_mine(minas, linha, coluna) do
      Printex.prints("VOCÊ PERDEU!!!!!!!!!!!!!!!!", :red)
      IO.puts(Minesweeper.print_board(Minesweeper.abre_tabuleiro(minas, tabuleiro)))
      Printex.prints("TENTE NOVAMENTE!!!!!!!!!!!!", :red)
    else
      novo_tabuleiro = Minesweeper.abre_jogada(linha, coluna, minas, tabuleiro)

      if Minesweeper.end_game(minas, novo_tabuleiro) do
        Printex.prints("VOCÊ VENCEU!!!!!!!!!!!!!!", :green)
        IO.puts(Minesweeper.print_board(Minesweeper.abre_tabuleiro(minas, novo_tabuleiro)))
        Printex.prints("PARABÉNS!!!!!!!!!!!!!!!!!", :green)
      else
        game_loop(minas, novo_tabuleiro)
      end
    end
  end

  def gen_mines_board(size) do
    add_mines(ceil(size * size * 0.15), size, Minesweeper.gera_mapa_de_minas(size))
  end

  def add_mines(0, _size, mines), do: mines

  def add_mines(n, size, mines) do
    linha = :rand.uniform(size - 1)
    coluna = :rand.uniform(size - 1)

    if Minesweeper.is_mine(mines, linha, coluna) do
      add_mines(n, size, mines)
    else
      add_mines(n - 1, size, Minesweeper.update_pos(mines, linha, coluna, true))
    end
  end
end

# Motor.main()
