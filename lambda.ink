` The untyped lambda calculus, in Ink (dotink.co) `

` We use Church encoding to represent integers.
	A Church-encoded number N is a function that takes another function f and a
	value x, and applies f to x N times. `

` Zero is a function that takes an f, x, and applies f to x 0 times. `
Zero := f => x => x

` To define other numbers, we need a "successor" function, which is
	a function that takes N and returns N + 1. It takes a Church numeral n and
	returns a number where f has been applied to x once more. `
succ := n => f => x => f(n(f)(x))

` Now we can define 1, 2, 3, 4, 5 with Zero and succ. `
One := succ(Zero)
Two := succ(One)
Three := succ(Two)
Four := succ(Three)
Five := succ(Four)

` We can define arithmetic over Church numerals.
	To add A and B, we add 1 to A, B times. In other words, we apply the succ
	function to A, B times. `
add := a => b => b(succ)(a)
` A times B is A added to zero B times. `
mul := a => b => b(add(a))(Zero)
` A^B is 1 multiplied by A B times. `
pow := a => b => b(mul(a))(One)

` Since we have succ which gives N => N + 1, we should also have a pred, which
	gives N => N - 1.

	It turns out pred is quite a bit more complex. Our implementation of pred
	counts up from zero to find the number whose successor is the given N. `
pred := n => n (g => k => zero?(g(One))(k)(succ(g(k)))) (_ => Zero) (Zero)

` With pred defined, we can also define subtraction, which is just repeated pred-ing. `
sub := a => b => b(pred)(a)

` Booleans are encoded as "selector functions" that choose between two
	arguments depending on their value. `
True := x => y => x
False := x => y => y

` We can define functions over boolean values.
	Not simply flips the given value's choice. `
not := x => x(False)(True)
` A and B returns B if A is true, and false if A is false. `
and := a => b => a(b)(False)
` A or B returns true if A is true, and B if A is false. `
or := a => b => a(True)(b)

` One of the simplest predicates we can define in the lambda calculus is the
	Zero? predicate, which reports whether a number is Zero. We'll need it to write
	our Factorial function later.

	To express zero?, we start with true and apply N (0 or more) times a
	function that always returns false. `
zero? := n => n(_ => False)(True)

` Fixed-point combinators

	Fixed-point combinators help us define recursive functions in the lambda
	calculus without named functions or self-reference.

	This implementation is based on:
	- https://mvanier.livejournal.com/2897.html
	- https://medium.com/swlh/y-and-z-combinators-in-javascript-lambda-calculus-with-real-code-31f25be934ec `

` The Y combinator is a "fixed-point combinator". It uses the fact that a
	self-recursion can be written in terms of a fixed point of a function (a value
	for which the fn returns the given value) to express a recursive function
	without self-reference.

	The Y combinator's special property is that Y(g) = g(Y(g)).

	We can see this if we simplify:

	Y(g) = (x => g(x(x)))(x => g(x(x)))  -> definition of function application, Y(g)
	     = g(x => g(x(x)))(x => g(x(x))) -> apply the function (x => g(x(x))) to
	                                        its argument (x => g(x(x)))
	     = g(Y(g))                       -> by definition of Y(g). `
Y := g => (x => g(x(x)))(x => g(x(x)))
` Because Ink is a strictly (eagerly) evaluated language, the Y combinator
	actually results in an infinite loop. To define recursive functions in Ink
	in the lambda calculus, we'll need Y's strictly evaluated cousin, the Z
	combinator. `
Z := g => (x => g(v => x(x)(v)))(x => g(v => x(x)(v)))

` With the Z combinator defined, we can also define a factorial function for us
	to test our work so far. The factorial function is meant to be used with
	the Z combinator, and takes a function that Z will make recursive.

	We later invoke it on a number N with Z(factorial)(N). `
factorial := fact => n => (zero?(n) (_ => One) (_ => mul(n)(fact(pred(n))))) ()

` ---- TESTS AND STUFF ---- `

` helper for logging `
log := s => out(string(s) + char(10))

` some utilities to convert encoded booleans and numbers to Ink values `
toNumber := c => c(n => n + 1)(0)
toBool := c => c(true)(false)

log('-- numbers --')
log(toNumber(Zero)) `` => 0
log(toNumber(succ(Zero))) `` => 1
log(toNumber(add(Two)(Three))) `` => 5
log(toNumber(sub(Five)(Two))) `` => 3
log(toNumber(mul(Two)(Three))) `` => 6
log(toNumber(pow(Two)(Three))) `` => 8

log('-- bools --')
log(toBool(True)) `` => true
log(toBool(False)) `` => false
log(toBool(not(False))) `` => true
log(toBool(and(True)(False))) `` => false
log(toBool(or(False)(True))) `` => true

log('-- predicates --')
log(toBool(zero?(Zero))) `` => true
log(toBool(zero?(One))) `` => false
log(toBool(zero?(Two))) `` => false

log('-- factorial --')
log(toNumber(Z(factorial)(Zero))) `` => 1
log(toNumber(Z(factorial)(One))) `` => 1
log(toNumber(Z(factorial)(Two))) `` => 2
log(toNumber(Z(factorial)(Three))) `` => 6
log(toNumber(Z(factorial)(Four))) `` => 24
log(toNumber(Z(factorial)(Five))) `` => 120

