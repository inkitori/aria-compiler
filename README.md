# aria lang

compiler written with handwritten lexer/parser/codegen

supports assignments (`:`), `+ - * /`, comparisons (`<` `>` `=`), and `while` loops.

## example

`gcd.aria` computes `gcd(1071, 462)` via the euclidean algorithm, using `a - a / b * b` as `a mod b`

```
a : 1071;
b : 462;
while (b > 0)
{
	t : a - a / b * b;
	a : b + 0;
	b : t + 0;
}
```

after the loop, `a` holds the gcd (`21`).

## running

use ./run.sh, passing as an argument to print out its content at the end

```
./run.sh !.aria
# exit=21
```
