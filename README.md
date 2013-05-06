TechTalk May 2013: YAPP (Yet another PostgreSQL presentation)
=============================================================

JSON datatype
=============
PostgreSQL 9.2 (released 2012-09-10) introduced the JSON datatype.

The json data type can be used to store JSON (JavaScript Object Notation) data, as specified in RFC 4627. Such data can also be stored as text, but the json data type has the advantage of checking that each stored value is a _valid_ JSON value. 

The following functions are related to the JSON datatype:
* `array_to_json(anyarray [, pretty_bool])` returns the array as JSON. A PostgreSQL multidimensional array becomes a JSON array of arrays. Line feeds will be added between dimension 1 elements if `pretty_bool` is true.
```sql
select array_to_json('{{1,5},{99,100}}'::int[]);
array_to_json   
------------------
[[1,5],[99,100]]
```
* `row_to_json(record [, pretty_bool])` Returns the row/record as JSON. Line feeds will be added between level 1 elements if pretty_bool is true.
```sql
select row_to_json(row(1,'foo')) ;

row_to_json     
---------------------
{"f1":1,"f2":"foo"}
```

Usage examples:
---------------
```sql
> \d json_example_1

Table "public.json_example_1"
Column |  Type   |                         Modifiers                          
--------+---------+------------------------------------------------------------
a      | integer | not null default nextval('json_example_1_a_seq'::regclass)
b      | integer | not null default 0
c      | text    | 
d      | boolean | not null default false
Indexes:
"json_example_1_pkey" PRIMARY KEY, btree (a)
```

```sql
> SELECT * FROM json_example_1;

a | b |   c   | d 
---+---+-------+---
1 | 1 | hello | f
2 | 2 |       | t
(2 rows)
```

```sql
> SELECT row_to_json(rows) FROM (SELECT * FROM json_example_1) AS rows;

          row_to_json             
-------------------------------------
{"a":1,"b":1,"c":"hello","d":false}
{"a":2,"b":2,"c":null,"d":true}
(2 rows)
```

```sql
> SELECT row_to_json(rows, true) FROM (SELECT * FROM json_example_1) AS rows;

  row_to_json  
---------------
 {"a":1,      +
  "b":1,      +
  "c":"hello",+
  "d":false}
 {"a":2,      +
  "b":2,      +
  "c":null,   +
  "d":true}
(2 rows)
``` 
Something a bit more challenging:

```sql
> \d json_example_2

Table "public.json_example_2"
Column |   Type    |                         Modifiers                          
--------+-----------+------------------------------------------------------------
a      | integer   | not null default nextval('json_example_2_a_seq'::regclass)
b      | json      | 
c      | integer[] | 
Indexes:
"json_example_2_pkey" PRIMARY KEY, btree (a)
```

```sql
> SELECT * FROM json_example_2;
 a |                  b                   |    c    
---+--------------------------------------+---------
 1 | {"a1": 1, "a2": true, "a3": [1,2,3]} | {4,5,6}
(1 row)
```

```sql
> SELECT row_to_json(rows) FROM (SELECT * FROM json_example_2) AS rows;

row_to_json                          
--------------------------------------------------------------
{"a":1,"b":{"a1": 1, "a2": true, "a3": [1,2,3]},"c":[4,5,6]}
(1 row)
```

```sql
> SELECT row_to_json(rows,true) FROM (SELECT * FROM json_example_2) AS rows;
row_to_json                 
--------------------------------------------
{"a":1,                                   +
 "b":{"a1": 1, "a2": true, "a3": [1,2,3]},+
 "c":[4,5,6]}
(1 row)
```















