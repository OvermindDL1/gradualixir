-module('Elixir.List').

-type deep_list(A) :: [A | deep_list(A)].

-spec flatten(deep_list(A))      -> [A].
-spec flatten(deep_list(A), [A]) -> [A].
