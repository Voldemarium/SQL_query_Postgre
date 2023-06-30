create or replace function array_delta_decode(a int[])
    returns int[]
    immutable
    returns null on null input
    parallel safe -- Postgres 10+
    language sql
    set search_path = ''
as
$func$
    select array(
        select sum(a.v) over (order by a.o rows between unbounded preceding and current row)
        from unnest(array_delta_decode.a) with ordinality as a(v, o)
        order by a.o
    )
$func$;

comment on function array_delta_decode(a int[]) is 'https://en.wikipedia.org/wiki/Delta_encoding';

-- TEST
select array_delta_decode(array[2, 2, 2, 3, -2]) = array[2, 4, 6, 9, 7];
