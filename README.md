TechTalk May 2013: YAPP
=======================
Yet another PostgreSQL presentation.

1. JSON datatype
2. ENUM datatype
3. HStore datatype
4. Heroku Postgresql

# 1. JSON datatype
PostgreSQL 9.2 (released 2012-09-10, but for some reason not included in Ubuntu 13.04) introduced the JSON datatype.

The jJSON data type can be used to store JSON (JavaScript Object Notation) data, as specified in RFC 4627. Such data can also be stored as text, but the json data type has the advantage of checking that each stored value is a _valid_ JSON value. 

The following functions are related to the JSON datatype:
* `array_to_json(anyarray [, pretty_bool])` returns the array as JSON. A PostgreSQL multidimensional array becomes a JSON array of arrays. Line feeds will be added between dimension 1 elements if `pretty_bool` is true.

```
SELECT array_to_json('{{1,5},{99,100}}'::integer[]);
array_to_json   
------------------
[[1,5],[99,100]]
```
* `row_to_json(record [, pretty_bool])` Returns the row/record as JSON. Line feeds will be added between level 1 elements if pretty_bool is true.

```
SELECt row_to_json(row(1,'foo')) ;

row_to_json     
---------------------
{"f1":1,"f2":"foo"}
```

Usage examples:
---------------
```
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

```
> SELECT * FROM json_example_1;

a | b |   c   | d 
---+---+-------+---
1 | 1 | hello | f
2 | 2 |       | t
(2 rows)
```

```
> SELECT row_to_json(json_example_1) FROM json_example_1;
row_to_json             
-------------------------------------
{"a":1,"b":1,"c":"hello","d":false}
{"a":2,"b":2,"c":null,"d":true}
(2 rows)
```

```
> SELECT row_to_json(rows) FROM (SELECT a,b,c FROM json_example_1) AS rows;
row_to_json        
---------------------------
{"a":1,"b":1,"c":"hello"}
{"a":2,"b":2,"c":null}
(2 rows)
```

```
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
Something a bit more interesting: Nested JSON.

```
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

```
> SELECT * FROM json_example_2;
 a |                  b                   |    c    
---+--------------------------------------+---------
 1 | {"a1": 1, "a2": true, "a3": [1,2,3]} | {4,5,6}
(1 row)
```

```
> SELECT row_to_json(json_example_2) FROM json_example_2;

row_to_json                          
--------------------------------------------------------------
{"a":1,"b":{"a1": 1, "a2": true, "a3": [1,2,3]},"c":[4,5,6]}
(1 row)
```

```
> SELECT row_to_json(json_example_2,true) FROM json_example_2;

row_to_json                 
--------------------------------------------
{"a":1,                                   +
 "b":{"a1": 1, "a2": true, "a3": [1,2,3]},+
 "c":[4,5,6]}
(1 row)
```

JSON (and XML) formatting are also available as output format specifiers for the EXPLAIN command. Older versions provided one with the following output:
```
> EXPLAIN SELECT row_to_json(json_example_2) FROM json_example_2;

QUERY PLAN                            
------------------------------------------------------------------
Seq Scan on json_example_2  (cost=0.00..12.91 rows=830 width=68)
(1 row)
```

This type of output is not suitable for parsing. Specifying the JSON format:
```
> EXPLAIN (FORMAT JSON) SELECT row_to_json(json_example_2) FROM json_example_2;

QUERY PLAN                
------------------------------------------
[                                       +
  {                                     +
    "Plan": {                           +
      "Node Type": "Seq Scan",          +
      "Relation Name": "json_example_2",+
      "Alias": "json_example_2",        +
      "Startup Cost": 0.00,             +
      "Total Cost": 12.91,              +
      "Plan Rows": 830,                 +
      "Plan Width": 68                  +
    }                                   +
  }                                     +
]
(1 row)
```

An interesting link with some performance benchmarks:
http://blog.hashrocket.com/posts/faster-json-generation-with-postgresql

# 2. Enumerated types
Enumerated types are data types that comprise a static, ordered set of values. They are equivalent to the enum types supported in a number of programming languages. Each enumerated data type is separate and cannot be compared with other enumerated types.

Enumerated types are created using the CREATE TYPE command, for example:
```
CREATE TYPE mood AS ENUM ('sad', 'ok', 'happy');
```

An enum value occupies four bytes on disk. The length of an enum value's textual label is limited to 63 bytes (a compiler directive).

Enum labels are case sensitive, so 'happy' is not the same as 'HAPPY'. White space in the labels is significant too.

The translations from internal enum values to textual labels are kept in the system catalog pg_enum. Querying this catalog directly can be useful.

```
> SELECT * FROM pg_enum;
 enumtypid | enumsortorder | enumlabel 
-----------+---------------+-----------
    391072 |             1 | sad
    391072 |             2 | ok
    391072 |             3 | happy
(3 rows)

> ALTER TYPE mood ADD VALUE 'positive' AFTER 'ok';
> SELECT * FROM pg_enum;
 enumtypid | enumsortorder | enumlabel 
-----------+---------------+-----------
    391072 |             1 | sad
    391072 |             2 | ok
    391072 |             3 | happy
    391072 |           2.5 | positive
(4 rows)
```

Once created, the enum type can be used in table and function definitions much like any other type:
```
CREATE TYPE mood AS ENUM ('sad', 'ok', 'happy');
CREATE TABLE person (
    name text,
    current_mood mood
);
INSERT INTO person VALUES ('Moe', 'happy');
SELECT * FROM person WHERE current_mood = 'happy';
 name | current_mood 
------+--------------
 Moe  | happy
(1 row)
```

The ordering of the values in an enum type is the order in which the values were listed when the type was created. All standard comparison operators and related aggregate functions are supported for enums. For example:
```
INSERT INTO person VALUES ('Larry', 'sad');
INSERT INTO person VALUES ('Curly', 'ok');
SELECT * FROM person WHERE current_mood > 'sad';
 name  | current_mood 
-------+--------------
 Moe   | happy
 Curly | ok
(2 rows)

    
SELECT * FROM person WHERE current_mood > 'sad' ORDER BY current_mood;
 name  | current_mood 
-------+--------------
 Curly | ok
 Moe   | happy
(2 rows)


SELECT name
  FROM person
 WHERE current_mood = (SELECT MIN(current_mood) FROM person);
 name  
-------
Larry
(1 row)
```

# 3. HStore
HStore is an optional module included since PostgreSQL 9.0. It provides key-value store functionality similar to a number of "NoSQL" solutions. 

```
CREATE EXTENSION IF NOT EXISTS hstore;
```




For example, say you wanted to store user profile data as a set of key-value data. First, you'd load HStore, since it's an optional module. Next, you'd create a table:

```
CREATE TABLE user_profile (
    user_id INT NOT NULL PRIMARY KEY REFERENCES users(user_id),
    profile HSTORE
);
```

Then you can store key-value data in that table:

```
INSERT INTO user_profile 
VALUES ( 5, hstore('"Home City"=>"San Francisco","Occupation"=>"Sculptor"');
```

Notice that the format for the HStore strings is a lot like hashes in Perl, but you can also use an array format, and simple JSON objects will probably be supported in 9.1. You probably want to index the keys in the HStore for fast lookup:
```
CREATE INDEX user_profile_hstore ON user_profile USING GIN (profile);
```

Now you can see what keys you have:
```
SELECT akeys(profile) FROM user_profile WHERE user_id = 5;
```

Look up individual keys:
```
SELECT profile -> 'Occupation' FROM user_profile;
```

Or even delete specific keys:
```
UPDATE user_profile 
   SET profile = profile - 'Occupation'::text 
 WHERE user_id = 5;
```

For all the operators and functions related to the HStore type, see: http://www.postgresql.org/docs/9.2/static/hstore.html

# 4. Heroku PostgreSQL

* [Database-as-a-Service](https://postgres.heroku.com/) Provides PostgreSQL 9.2, so I could construct this techtalk using their free dev DB.
* *Forking* a database is just like forking source code. It creates a perfect, byte-for-byte clone of your database with a single command. Do you have new schema migrations that you need to test? Simply fork your production database and run the new migrations against the fork. Load testing? Fork your database and run your testing environment against it. Forking databases lets you work with your production schema and data without risk or hassle. And when you are done, simply throw the fork away.
* *Followers* are read-only asynchronous replicas of a database. Followers stay up-to-date with changes to your database and can be queried. Traditionally, setting-up and maintaining replication is a difficult and specialized task. But with followers, it just works. Followers provide horizontal scalability by distributing database read traffic. They are also perfect for real-time analytics — use them to make expensive queries against up-to-date data without affecting application speed and availability.
* *Continuous Protection* keeps data safe on Heroku Postgres. Every change to your data is written to write-ahead logs, which are shipped to multi-datacenter, high-durability storage. In the unlikely event of unrecoverable hardware failure, these logs can be automatically 'replayed' to recover the database to within seconds of its last known state.
* Databases on Heroku Postgres can be used from anywhere and with any Postgres client. Apps can connect to Heroku Postgres from Heroku, Google App Engine, Microsoft Azure, Cloud Foundry, EC2, or from your local computer. PostgreSQL is supported by most modern programming languages - including Perl, Python, Ruby, Scala, Go, Tcl, C/C++, Java, .Net, and Javascript. It is even available via ODBC.
* There are 8 Heroku Postgres plans. The plans vary primarily by the size of their data cache. Queries made from cached data are 100-1000x faster than from the full data set. Well engineered, high performance, web applications will have 99% or more of their queries be served from cache. Heroku Postgres databases are self-optimizing; they automatically keep frequently accessed data in cache.
* *Automated Health Checks* Around the clock, Heroku Postgres performs a battery of health checks on every database in operation. These checks ensure that the database is online and working properly. You can sleep well, knowing that if a problem is detected, our 24/7 on-call team is immediately dispatched and our automated recovery software can have you back online in minutes, even in the event of catastrophic hardware failure.
* Creating production-ready relational databases systems has never been this easy. Forget servers. Forget software packages. And forget ever having to worry about maintenance tasks. Heroku does all the hard work of maintaining it while you focus on building software. Creating a database requires just a single click, and are available in two minutes.


















