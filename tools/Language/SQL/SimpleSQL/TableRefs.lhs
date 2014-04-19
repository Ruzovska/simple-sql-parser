
These are the tests for parsing focusing on the from part of query
expression

> {-# LANGUAGE OverloadedStrings #-}
> module Language.SQL.SimpleSQL.TableRefs (tableRefTests) where

> import Language.SQL.SimpleSQL.TestTypes
> import Language.SQL.SimpleSQL.Syntax


> tableRefTests :: TestItem
> tableRefTests = Group "tableRefTests" $ map (uncurry TestQueryExpr)
>     [("select a from t"
>      ,ms [TRSimple "t"])

>      ,("select a from f(a)"
>       ,ms [TRFunction "f" [Iden "a"]])

>     ,("select a from t,u"
>      ,ms [TRSimple "t", TRSimple "u"])

>     ,("select a from s.t"
>      ,ms [TRSimple ["s","t"]])

these lateral queries make no sense but the syntax is valid

>     ,("select a from lateral a"
>      ,ms [TRLateral $ TRSimple "a"])

>     ,("select a from lateral a,b"
>      ,ms [TRLateral $ TRSimple "a", TRSimple "b"])

>     ,("select a from a, lateral b"
>      ,ms [TRSimple "a", TRLateral $ TRSimple "b"])

>     ,("select a from a natural join lateral b"
>      ,ms [TRJoin (TRSimple "a") True JInner
>                  (TRLateral $ TRSimple "b")
>                  Nothing])

>     -- the lateral binds on the outside of the join which is incorrect
>     ,("select a from lateral a natural join lateral b"
>      ,ms [TRJoin (TRLateral $ TRSimple "a") True JInner
>                  (TRLateral $ TRSimple "b")
>                  Nothing])


>     ,("select a from t inner join u on expr"
>      ,ms [TRJoin (TRSimple "t") False JInner (TRSimple "u")
>                        (Just $ JoinOn $ Iden "expr")])

>     ,("select a from t join u on expr"
>      ,ms [TRJoin (TRSimple "t") False JInner (TRSimple "u")
>                        (Just $ JoinOn $ Iden "expr")])

>     ,("select a from t left join u on expr"
>      ,ms [TRJoin (TRSimple "t") False JLeft (TRSimple "u")
>                        (Just $ JoinOn $ Iden "expr")])

>     ,("select a from t right join u on expr"
>      ,ms [TRJoin (TRSimple "t") False JRight (TRSimple "u")
>                        (Just $ JoinOn $ Iden "expr")])

>     ,("select a from t full join u on expr"
>      ,ms [TRJoin (TRSimple "t") False JFull (TRSimple "u")
>                        (Just $ JoinOn $ Iden "expr")])

>     ,("select a from t cross join u"
>      ,ms [TRJoin (TRSimple "t") False
>                        JCross (TRSimple "u") Nothing])

>     ,("select a from t natural inner join u"
>      ,ms [TRJoin (TRSimple "t") True JInner (TRSimple "u")
>                        Nothing])

>     ,("select a from t inner join u using(a,b)"
>      ,ms [TRJoin (TRSimple "t") False JInner (TRSimple "u")
>                        (Just $ JoinUsing ["a", "b"])])

>     ,("select a from (select a from t)"
>      ,ms [TRQueryExpr $ ms [TRSimple "t"]])

>     ,("select a from t as u"
>      ,ms [TRAlias (TRSimple "t") (Alias "u" Nothing)])

>     ,("select a from t u"
>      ,ms [TRAlias (TRSimple "t") (Alias "u" Nothing)])

>     ,("select a from t u(b)"
>      ,ms [TRAlias (TRSimple "t") (Alias "u" $ Just ["b"])])

>     ,("select a from (t cross join u) as u"
>      ,ms [TRAlias (TRParens $
>                    TRJoin (TRSimple "t") False JCross (TRSimple "u") Nothing)
>                           (Alias "u" Nothing)])
>      -- todo: not sure if the associativity is correct

>     ,("select a from t cross join u cross join v",
>        ms [TRJoin
>            (TRJoin (TRSimple "t") False
>                    JCross (TRSimple "u") Nothing)
>            False JCross (TRSimple "v") Nothing])
>     ]
>   where
>     ms f = makeSelect {qeSelectList = [(Iden "a",Nothing)]
>                       ,qeFrom = f}
