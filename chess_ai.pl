:- use_module(library(lists)).

initial_state([
 piece(white, rook, 1,1), piece(white, knight, 2,1), piece(white, bishop, 3,1),
 piece(white, queen, 4,1), piece(white, king, 5,1), piece(white, bishop, 6,1),
 piece(white, knight, 7,1), piece(white, rook, 8,1),
 piece(white, pawn, 1,2), piece(white, pawn, 2,2), piece(white, pawn, 3,2),
 piece(white, pawn, 4,2), piece(white, pawn, 5,2), piece(white, pawn, 6,2),
 piece(white, pawn, 7,2), piece(white, pawn, 8,2),
 piece(black, rook, 1,8), piece(black, knight, 2,8), piece(black, bishop, 3,8),
 piece(black, queen, 4,8), piece(black, king, 5,8), piece(black, bishop, 6,8),
 piece(black, knight, 7,8), piece(black, rook, 8,8),
 piece(black, pawn, 1,7), piece(black, pawn, 2,7), piece(black, pawn, 3,7),
 piece(black, pawn, 4,7), piece(black, pawn, 5,7), piece(black, pawn, 6,7),
 piece(black, pawn, 7,7), piece(black, pawn, 8,7)
]).

opponent(white, black).
opponent(black, white).

in_bounds(X, Y) :-
 X >= 1, X =< 8,
 Y >= 1, Y =< 8.

occupied(State, X, Y) :-
 member(piece(_, _, X, Y), State).

occupied_by(State, Color, X, Y) :-
 member(piece(Color, _, X, Y), State).

occupied_by_opponent(State, Color, X, Y) :-
 opponent(Color, Opp),
 member(piece(Opp, _, X, Y), State).

empty(State, X, Y) :-
 in_bounds(X, Y),
 \+ occupied(State, X, Y).

piece_value(pawn, 100).
piece_value(knight, 320).
piece_value(bishop, 330).
piece_value(rook, 500).
piece_value(queen, 900).
piece_value(king, 20000).

all_legal_moves(Color, State, Moves) :-
 findall(Move, legal_move(Color, State, Move), Moves).

legal_move(Color, State, move(X1,Y1,X2,Y2)) :-
 member(piece(Color, Type, X1, Y1), State),
 pseudo_legal_move(Type, Color, State, X1, Y1, X2, Y2),
 safe_after_move(Color, State, move(X1,Y1,X2,Y2)).

safe_after_move(Color, State, Move) :-
 make_move(State, Move, NewState),
 \+ in_check(Color, NewState).

pseudo_legal_move(pawn, white, State, X, Y, X, Y2) :-
 Y2 is Y + 1,
 empty(State, X, Y2).

pseudo_legal_move(pawn, white, State, X, 2, X, 4) :-
 empty(State, X, 3),
 empty(State, X, 4).

pseudo_legal_move(pawn, white, State, X, Y, X2, Y2) :-
 Y2 is Y + 1,
 (X2 is X + 1 ; X2 is X - 1),
 occupied_by_opponent(State, white, X2, Y2).

pseudo_legal_move(pawn, black, State, X, Y, X, Y2) :-
 Y2 is Y - 1,
 empty(State, X, Y2).

pseudo_legal_move(pawn, black, State, X, 7, X, 5) :-
 empty(State, X, 6),
 empty(State, X, 5).

pseudo_legal_move(pawn, black, State, X, Y, X2, Y2) :-
 Y2 is Y - 1,
 (X2 is X + 1 ; X2 is X - 1),
 occupied_by_opponent(State, black, X2, Y2).

pseudo_legal_move(knight, Color, State, X, Y, X2, Y2) :-
 knight_delta(DX, DY),
 X2 is X + DX,
 Y2 is Y + DY,
 in_bounds(X2, Y2),
 \+ occupied_by(State, Color, X2, Y2).

pseudo_legal_move(bishop, Color, State, X, Y, X2, Y2) :-
 diagonal_move(X, Y, X2, Y2),
 clear_path(State, X, Y, X2, Y2),
 \+ occupied_by(State, Color, X2, Y2).

pseudo_legal_move(rook, Color, State, X, Y, X2, Y2) :-
 straight_move(X, Y, X2, Y2),
 clear_path(State, X, Y, X2, Y2),
 \+ occupied_by(State, Color, X2, Y2).

pseudo_legal_move(queen, Color, State, X, Y, X2, Y2) :-
 (straight_move(X, Y, X2, Y2) ; diagonal_move(X, Y, X2, Y2)),
 clear_path(State, X, Y, X2, Y2),
 \+ occupied_by(State, Color, X2, Y2).

pseudo_legal_move(king, Color, State, X, Y, X2, Y2) :-
 between(-1, 1, DX),
 between(-1, 1, DY),
 (DX \= 0 ; DY \= 0),
 X2 is X + DX,
 Y2 is Y + DY,
 in_bounds(X2, Y2),
 \+ occupied_by(State, Color, X2, Y2).

knight_delta(1,2).
knight_delta(2,1).
knight_delta(2,-1).
knight_delta(1,-2).
knight_delta(-1,-2).
knight_delta(-2,-1).
knight_delta(-2,1).
knight_delta(-1,2).

straight_move(X, Y, X2, Y) :-
 X2 \= X,
 in_bounds(X2, Y).

straight_move(X, Y, X, Y2) :-
 Y2 \= Y,
 in_bounds(X, Y2).

diagonal_move(X, Y, X2, Y2) :-
 DX is abs(X2 - X),
 DY is abs(Y2 - Y),
 DX =:= DY,
 DX > 0,
 in_bounds(X2, Y2).

clear_path(State, X1, Y1, X2, Y2) :-
 step(X1, X2, SX),
 step(Y1, Y2, SY),
 NX is X1 + SX,
 NY is Y1 + SY,
 clear_path_helper(State, NX, NY, X2, Y2).

clear_path_helper(_, X, Y, X, Y).

clear_path_helper(State, X, Y, X2, Y2) :-
 (X \= X2 ; Y \= Y2),
 empty(State, X, Y),
 step(X, X2, SX),
 step(Y, Y2, SY),
 NX is X + SX,
 NY is Y + SY,
 clear_path_helper(State, NX, NY, X2, Y2).

step(A, B, 1) :- B > A.
step(A, B, -1) :- B < A.
step(A, A, 0).

in_check(Color, State) :-
 member(piece(Color, king, KX, KY), State),
 opponent(Color, Opp),
 member(piece(Opp, Type, X, Y), State),
 attacks(Type, Opp, State, X, Y, KX, KY),
 !.

attacks(pawn, white, _, X, Y, X2, Y2) :-
 Y2 is Y + 1,
 (X2 is X + 1 ; X2 is X - 1).

attacks(pawn, black, _, X, Y, X2, Y2) :-
 Y2 is Y - 1,
 (X2 is X + 1 ; X2 is X - 1).

attacks(knight, _, _, X, Y, X2, Y2) :-
 knight_delta(DX, DY),
 X2 is X + DX,
 Y2 is Y + DY.

attacks(bishop, _, State, X, Y, X2, Y2) :-
 diagonal_move(X, Y, X2, Y2),
 clear_path(State, X, Y, X2, Y2).

attacks(rook, _, State, X, Y, X2, Y2) :-
 straight_move(X, Y, X2, Y2),
 clear_path(State, X, Y, X2, Y2).

attacks(queen, _, State, X, Y, X2, Y2) :-
 (straight_move(X, Y, X2, Y2) ; diagonal_move(X, Y, X2, Y2)),
 clear_path(State, X, Y, X2, Y2).

attacks(king, _, _, X, Y, X2, Y2) :-
 DX is abs(X2 - X),
 DY is abs(Y2 - Y),
 DX =< 1,
 DY =< 1,
 (DX > 0 ; DY > 0).

make_move(State, move(X1,Y1,X2,Y2), NewState) :-
 select(piece(Color, Type, X1, Y1), State, TempState),
 remove_piece_at(TempState, X2, Y2, TempState2),
 NewState = [piece(Color, Type, X2, Y2) | TempState2].

remove_piece_at([], _, _, []).

remove_piece_at([piece(_, _, X, Y)|T], X, Y, T) :- !.

remove_piece_at([H|T], X, Y, [H|R]) :-
 remove_piece_at(T, X, Y, R).

evaluate(State, Score) :-
 material_score(State, M),
 mobility_score(white, State, WM),
 mobility_score(black, State, BM),
 center_control_score(State, C),
 king_safety_score(State, K),
 Score is M + (WM - BM) * 5 + C + K.

material_score(State, Score) :-
 findall(V, (
  member(piece(Color, Type, _, _), State),
  piece_value(Type, Base),
  signed_value(Color, Base, V)
 ), Values),
 sum_list(Values, Score).

signed_value(white, V, V).

signed_value(black, V, NV) :-
 NV is -V.

mobility_score(Color, State, Score) :-
 all_legal_moves(Color, State, Moves),
 length(Moves, Score).

center_control_score(State, Score) :-
 findall(V, (
  member(piece(Color, _, X, Y), State),
  center_square(X, Y),
  center_bonus(Color, V)
 ), Values),
 sum_list(Values, Score).

center_square(3,3). center_square(4,3). center_square(5,3). center_square(6,3).
center_square(3,4). center_square(4,4). center_square(5,4). center_square(6,4).
center_square(3,5). center_square(4,5). center_square(5,5). center_square(6,5).
center_square(3,6). center_square(4,6). center_square(5,6). center_square(6,6).

center_bonus(white, 10).
center_bonus(black, -10).

king_safety_score(State, Score) :-
 king_position(white, State, WX, WY),
 king_position(black, State, BX, BY),
 pawn_shield_score(white, State, WX, WY, WS),
 pawn_shield_score(black, State, BX, BY, BS),
 Score is WS - BS.

king_position(Color, State, X, Y) :-
 member(piece(Color, king, X, Y), State).

pawn_shield_score(white, State, X, Y, Score) :-
 Y1 is Y + 1,
 findall(1, (
  member(DX, [-1,0,1]),
  X1 is X + DX,
  in_bounds(X1, Y1),
  occupied_by(State, white, X1, Y1)
 ), L),
 length(L, N),
 Score is N * 15.

pawn_shield_score(black, State, X, Y, Score) :-
 Y1 is Y - 1,
 findall(1, (
  member(DX, [-1,0,1]),
  X1 is X + DX,
  in_bounds(X1, Y1),
  occupied_by(State, black, X1, Y1)
 ), L),
 length(L, N),
 Score is N * 15.

best_move(Color, State, Depth, BestMove, BestScore) :-
 alphabeta(Color, State, Depth, -1000000, 1000000, BestMove, BestScore).

alphabeta(_, State, 0, _, _, none, Score) :-
 evaluate(State, Score),
 !.

alphabeta(Color, State, _, _, _, none, Score) :-
 all_legal_moves(Color, State, []),
 evaluate(State, Score),
 !.

alphabeta(white, State, Depth, Alpha, Beta, BestMove, BestScore) :-
 all_legal_moves(white, State, Moves),
 Depth1 is Depth - 1,
 max_value(Moves, State, Depth1, Alpha, Beta, none, -1000000, BestMove, BestScore).

alphabeta(black, State, Depth, Alpha, Beta, BestMove, BestScore) :-
 all_legal_moves(black, State, Moves),
 Depth1 is Depth - 1,
 min_value(Moves, State, Depth1, Alpha, Beta, none, 1000000, BestMove, BestScore).

max_value([], _, _, Alpha, _, BestMove, BestScore, BestMove, BestScore) :-
 BestScore = Alpha.

max_value([Move|Moves], State, Depth, Alpha, Beta, CurrBestMove, CurrBestScore,
          BestMove, BestScore) :-
 make_move(State, Move, NewState),
 alphabeta(black, NewState, Depth, Alpha, Beta, _, Score),
 (
  Score > CurrBestScore ->
  NewAlpha is max(Alpha, Score),
  NewBestMove = Move,
  NewBestScore = Score
 ;
  NewAlpha = Alpha,
  NewBestMove = CurrBestMove,
  NewBestScore = CurrBestScore
 ),
 (
  Beta =< NewAlpha ->
  BestMove = NewBestMove,
  BestScore = NewBestScore
 ;
  max_value(Moves, State, Depth, NewAlpha, Beta, NewBestMove, NewBestScore,
            BestMove, BestScore)
 ).

min_value([], _, _, _, Beta, BestMove, BestScore, BestMove, BestScore) :-
 BestScore = Beta.

min_value([Move|Moves], State, Depth, Alpha, Beta, CurrBestMove, CurrBestScore,
          BestMove, BestScore) :-
 make_move(State, Move, NewState),
 alphabeta(white, NewState, Depth, Alpha, Beta, _, Score),
 (
  Score < CurrBestScore ->
  NewBeta is min(Beta, Score),
  NewBestMove = Move,
  NewBestScore = Score
 ;
  NewBeta = Beta,
  NewBestMove = CurrBestMove,
  NewBestScore = CurrBestScore
 ),
 (
  NewBeta =< Alpha ->
  BestMove = NewBestMove,
  BestScore = NewBestScore
 ;
  min_value(Moves, State, Depth, Alpha, NewBeta, NewBestMove, NewBestScore,
            BestMove, BestScore)
 ).

show_legal_moves(Color) :-
 initial_state(State),
 all_legal_moves(Color, State, Moves),
 write(Moves), nl.

choose_opening_move(Color, Depth) :-
 initial_state(State),
 best_move(Color, State, Depth, Move, Score),
 write('Best move: '), write(Move), nl,
 write('Score: '), write(Score), nl.
