create or replace function sql_comments_remove(
    sql text  --SQL запрос
)
    returns text
    stable
    returns null on null input
    parallel safe
    language sql
    set search_path = ''
    cost 2
as
$function$
    --https://postgrespro.ru/docs/postgresql/12/sql-syntax-lexical
    select regexp_replace(sql, $regexp$
        (?:
             --[^\r\n]*                     #singe-line comment
          |  /\*                            #multi-line comment (can be nested)
               [^*/]* #speed improves
               (?: [^*/]+
                 | \*[^/] #not end comment
                 | /[^*]  #not begin comment
                 |   #recursive:
                     /\*                            #multi-line comment (can be nested)
                       [^*/]* #speed improves
                       (?: [^*/]+
                         | \*[^/] #not end comment
                         | /[^*]  #not begin comment
                         |   #recursive:
                             /\*                            #multi-line comment (can be nested)
                               [^*/]* #speed improves
                               (?: [^*/]+
                                 | \*[^/] #not end comment
                                 | /[^*]  #not begin comment
                                 #| #recursive
                               )*
                             \*/
                       )*
                     \*/
               )*
             \*/
          |  ("(?:[^\\"]+|""|\\.)*")        #1 identifiers
          |  ('(?:[^']+|'')*')              #2 string constants
          |  (\m[Ee]'(?:[^\\']+|''|\\.)*')  #3 string constants with c-style escapes
          |  (                              #4
               (\$[a-zA-Z]*\$)                #5 dollar-quoted string
                 [^$]*  #speed improves
                 .*?
               \5
             )
        )
    $regexp$, ' \1\2\3\4', 'xg');

$function$;

comment on function depers.sql_comments_remove(sql text) is $$
    Удаляет из SQL запроса однострочные и многострочные комментарии (заменяет их на пробел)
    For example, it's useful to clean up the query field returned by the pg_stat_statements extension and remove all comments.
$$;

--TEST
DO $do$
DECLARE
    sql text default $sql$
TEST sql_comments_remove() start
  ,qq   --/*7/*8*/9*/!
  ,'st--\''ri$$ng/*--*/'!
  ,e' \' --/*1''2 */'!
  ,"id--""/*--*/en$$t\"\\"!
  ,/*--"456--*/!
  ,/* многострочный" комментарий"!
  ,--123---!
  ,\* /*с*/ вложенностью: /* вложенный /*блок*/" комментария */!
  ,*/!
  ,$$dol--lar$$!
  ,$b$dol--lar$b$!
TEST sql_comments_remove() end
    $sql$;

BEGIN
    --raise notice '%', sql_comments_remove(sql);
    perform sql_comments_remove(sql);
END;
$do$;
