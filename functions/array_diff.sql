create or replace function array_diff(anyarray, anyarray)
    returns anyarray
    immutable
    returns null on null input
    parallel safe -- Postgres 10 or later
    language sql
    set search_path = ''
as $$
    select array(
        select v
        from unnest($1) with ordinality as t(v, pos)
        where array_position($2, v) is null
        order by pos
    );
$$;

comment on function array_diff(anyarray, anyarray) is 'Compares first array against second array. Returns the values in first array that are not present second array.';

--TEST
do $$
begin
    assert array_diff(array[8,2,2,null,3,1,3,4,7,5,null], array[3,5,3,5]) = array[8,2,2,null,1,4,7,null];
    assert array_diff(array[8,2,2,null,3,1,3,4,7,5,null], array[]::int[]) = array[8,2,2,null,3,1,3,4,7,5,null];
    assert array_diff(array[]::int[], array[3,5,3,5]) = array[]::int[];
    assert array_diff(array['b',null,'a'], array['d','c']) = array['b',null,'a'];
end
$$;
