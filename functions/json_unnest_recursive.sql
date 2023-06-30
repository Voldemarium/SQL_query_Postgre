create or replace function json_unnest_recursive(data json)
    returns table(
        path  text[],
        value json
    )
    immutable
    returns null on null input -- = strict
    parallel safe -- Postgres 10 or later
    security invoker
    language sql
    set search_path = ''
AS $func$
--explain (analyse)
with recursive r as
(
    select
        array[k.key] as path,
        v.value
    from json_typeof(data) as t(type)
    left join json_each(case t.type when 'object' then data end) as o(obj_key, obj_value) on true
    left join json_array_elements(case t.type when 'array' then data end) with ordinality as a(arr_value, arr_key) on true
    cross join coalesce(o.obj_key, (a.arr_key - 1)::text) as k(key)
    cross join coalesce(o.obj_value, a.arr_value) as v(value)
    where t.type in ('object', 'array')
      and k.key is not null
union all
    select
        array_append(path, k.key),
        v.value
    from r
    inner join json_typeof(r.value) as t(type) on t.type in ('object', 'array')
    left join json_each(case t.type when 'object' then value end) as o(obj_key, obj_value) on true
    left join json_array_elements(case t.type when 'array' then value end) with ordinality as a(arr_value, arr_key) on true
    cross join coalesce(o.obj_key, (a.arr_key - 1)::text) as k(key)
    cross join coalesce(o.obj_value, a.arr_value) as v(value)
    where k.key is not null
)
select *
from r
where json_typeof(value) not in ('object', 'array');
$func$;

comment on function json_unnest_recursive(data json) is 'Recursive parse nested JSON (arrays and objects), returns keys and its values';


--TEST AND USING EXAMPLE
select cardinality(path) as level, *
from json_unnest_recursive('{"id":123,"g":null,"a":[9,8],"name":"unknown"}'::json)
order by path;
