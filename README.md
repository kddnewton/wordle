# Wordle

A wordle solver, written in Ruby.

## Getting started

To start the program, run:

```sh
ruby wordle.rb
```

This will output something like:

```
aeros (12972)>
```

That means your guess is "aeros". Input that into wordle, and get back your results. Then, to feed the result back into the program, input `_` for gray tiles, `y` for yellow tiles, and `g` for green tiles.

Here is an example game with the final word of "":

```
aeros (12972)> y____
inlay (00801)> ___y_
mutha (00095)> ___yy
chawk (00005)> yggyg
The word is: whack
```

## Running tests

If you want to test how long it will take to get each word in the dictionary, run:

```sh
ruby tests.rb
```
