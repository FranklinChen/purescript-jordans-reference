module Syntax.Basic.LetLacksGeneralization where

import Prelude

{-
We saw previously that we can define functions inside a `let` binding
and use it later after the `in`. The below example does NOT have a type
signature associated with it.                                                 -}
letBindingExample :: Int
letBindingExample =
  let
    add4 x = x + 4
  in add4 6 -- outputs 10

{-
We also saw that we can add type signatures to the `let` binding
to make it easier to read:                                                    -}
letBindingExampleWithTypeSignature :: Int
letBindingExampleWithTypeSignature =
  let
    add4 :: Int -> Int
    add4 x = x + 4
  in add4 6

{-
All of the above examples use monomorphism (i.e. each function only works
on 1 type), not polymorphism (i.e. each function works on multiple types).
In some situations, we may want to use polymorphism in our let bindings:      -}
letBindingWithPolymorphicTypeSignature :: Int
letBindingWithPolymorphicTypeSignature =
  let
    ignoreArgumentAndReturn4 :: forall a. a -> Int
    ignoreArgumentAndReturn4 _ = 4
  in
    (ignoreArgumentAndReturn4 8) + (ignoreArgumentAndReturn4 "foo")

{-
When you remove the type signature above the let binding, you will discover
that "`let` bindings lack generalization". The below example will not compile.
You can uncomment it and see for yourself:                                    -}
-- failsToCompile :: Int
-- failsToCompile =
--   let
--     -- based on the usage below, it would appear that this function's
--     -- type signature is "forall a. a -> Int"
--     polymorphicLetBindingWithNoTypeSignature _ = 4
--   in
--     (polymorphicLetBindingWithNoTypeSignature 8) +   -- argument is Int
--     (polymorphicLetBindingWithNoTypeSignature "foo") -- argument is String

{-
Running `failsToCompile` will produce the following error:

  Error found:
  in module Syntax.Basic.LetLacksGeneralization
  at src/02-Data-and-Functions/07-Some-Keywords-and-Their-Syntax/07-Let-Lacks-Generalization.purs:48:34 - 48:39 (line 48, column 34 - line 48, column 39)

    Could not match type

      String

    with type

      Int


  while checking that type String
    is at least as general as type Int
  while checking that expression "foo"
    has type Int
  in value declaration failsToCompile

  See https://github.com/purescript/documentation/blob/master/errors/TypesDoNotUnify.md for more information,
  or to contribute content related to this error.
-}

{-
When the compiler comes across the first usage of
`polymorphicLetBindingWithNoTypeSignature`, the type of the first argument, 8,
is Int. Rather than making this binding polymorphic, the compiler assumes
that the function is monomorphic and it's type signature will be
"Int -> Int". Thus, when it encounters the second usage of the function,
`polymorphicLetBindingWithNoTypeSignature "foo"`, it fails because
String is not the same type as Int.

This missing feature is called "`let` generalization." Its absence is
intentional. For more context, see the paper titled,
"Let should not be generalized" - https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/tldi10-vytiniotis.pdf
-}

-- This issue can arise when you use `where` clauses because
-- `where` clauses are syntax sugar for `let` bindings

-- alsoFailsToCompile :: Int
-- alsoFailsToCompile =
--     (functionWithNoTypeSignature 8) + -- argument is Int
--     (functionWithNoTypeSignature "foo")
--
--     where
--       functionWithNoTypeSignature _ = 4

-- This version will compile because the type signature
-- has been specified.
polymorphicWhereClauseWithTypeSignature :: Int
polymorphicWhereClauseWithTypeSignature =
    (functionWithNoTypeSignature 8) + -- argument is Int
    (functionWithNoTypeSignature "foo")

    where
      functionWithNoTypeSignature :: forall a. a -> Int
      functionWithNoTypeSignature _ = 4
