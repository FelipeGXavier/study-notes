## Schemas
Muitas vezes sentimos a necessidade de usar o conceito de cross-database, isto é, criar consultas SQL cruzando informações entre campos de tabelas que estão em Banco de Dados distintos. Um schema no PostgreSQL seria como um espaço lógico onde os dados podem ser armazenados.

``CREATE SCHEMA customers;``
****
## Tabelas
*Principais tipos:*

- int
- serial (autoincrement)
- bool
- date
- timestamp
- float
- text (ilimitado)
- varchar
- uuid
- json
- char

*Sintaxe:*

**Criar uma tabela**
<pre><code>
CREATE TABLE schema.character_tests (
    id serial PRIMARY KEY,
    x CHAR (1),
    y VARCHAR (10),
    z TEXT,
    extra JSON
);</pre></code>

**Alterações**

Adicionar coluna 
``ALTER TABLE distributors ADD COLUMN address varchar(30);``

Alterar tipo da coluna
<pre><code>ALTER TABLE distributors
    ALTER COLUMN address TYPE varchar(80),
    ALTER COLUMN name TYPE varchar(100);</code></pre>

Remover coluna
``ALTER TABLE distributors DROP COLUMN address RESTRICT;``

Renomear uma coluna
``ALTER TABLE distributors RENAME COLUMN address TO city;``

Adicionar constraint

<pre><code>
ALTER TABLE distributors ADD CONSTRAINT fk_distribuitors_address
FOREIGN KEY (address) REFERENCES addresses (address) MATCH FULL;
</code></pre>

``ALTER TABLE distributors ADD PRIMARY KEY (dist_id);``

``ALTER TABLE distributors ADD CONSTRAINT zipchk CHECK (char_length(zipcode) = 5)``

``ALTER TABLE distributors ADD CONSTRAINT dist_id_zipcode_key UNIQUE (dist_id, zipcode);``

**Principais constraints**

- Check (faz uma validação booleana)
- Not null
- Null
- Unique

***

## Operações comuns DDL

<pre><code>INSERT INTO films (code, title, did, date_prod, kind)
    VALUES ('T_601', 'Yojimbo', 106, '1961-06-16', 'Drama');</code></pre>

<pre><code>
INSERT INTO films (code, title, did, date_prod, kind) VALUES
    ('B6717', 'Tampopo', 110, '1985-02-10', 'Comedy'),
    ('HG120', 'The Dinner Game', 140, DEFAULT, 'Comedy');
</code></pre>

<pre><code>UPDATE weather SET temp_lo = temp_lo+1, temp_hi = temp_lo+15, prcp = DEFAULT
  WHERE city = 'San Francisco' AND date = '2003-07-03';</code></pre>

``DELETE FROM films WHERE producer_id IN (SELECT id FROM producers WHERE name = 'foo');``


***
## Operadores

- Maior que >
- Menor que <
- Diferente de <> !=
- Igual a =
- Contém @>
- NOT, AND, OR, BETWEEN, IS (expressões) 
- LIKE (busca textual)
- string || string (concatenação)

***

## Datas

Diferença entre datas:

``SELECT DATE_PART('day', '2011-12-31 01:00:00'::timestamp - '2011-12-29 23:00:00'::timestamp);
``

``SELECT '2015-01-12'::date - '2015-01-01'::date;``

Extraindo campos:

``SELECT EXTRACT(YEAR FROM TIMESTAMP '2016-12-31 13:30:15');``

Adicionando tempo a uma data:

``SELECT CURRENT_DATE + INTERVAL '1 day';``
***
## Casting

Para converter entre tipos

``SELECT CAST ('10.2' AS DOUBLE PRECISION);``

``SELECT value::INTEGER as int_val;``

String para intervalo
<pre>
<code>SELECT '15 minute'::interval,
 '2 hour'::interval,
 '1 day'::interval,
 '2 week'::interval,
 '3 month'::interval;</code>
</pre>

## Expressões

**Expressões Condicionais**:

Definindo valor por condicional. **CASE**

<pre>
<code>SELECT a,
       CASE WHEN a=1 THEN 'one'
            WHEN a=2 THEN 'two'
            ELSE 'other'
       END
    FROM test;</code>
</pre>

Primeiro valor não nulo na expressão, caso todos forem nulos returna nulo. **COALESCE**

``SELECT COALESCE (NULL, 2 , 1);``

Retorna nulo se o primeiro elemento for igual ao segundo, caso contrário retorna primeiro elemento. **NULLIF**

``SELECT NULLIF (1, 1);`` &#8594; null
``SELECT NULLIF (1, 2);`` &#8594; 1

Maior elemento em uma lista. **GREATEST** e **LEAST**

``SELECT GREATEST(1,2, 3, 4);``

``SELECT GREATEST(current_date, current_date + 10);``

**Expressões de subconsulta**:

**EXISTS**: Recebe uma consulta como parâmetro validando para determinar se retorna alguma linha, caso pelo menos uma linha seja retornada é dado como true.

<pre>
<code>SELECT col1
FROM tab1
WHERE EXISTS (SELECT 1 FROM tab2 WHERE col2 = tab1.col2);</code>
</pre>

**IN**: Pode ser utilizado na cláusula WHERE para verificar se um valor corresponde a qualquer valor em uma lista de valores

<pre>
<code>SELECT
	customer_id,
	rental_id,
	return_date
FROM
	rental
WHERE
	customer_id IN (1, 2);</code>
</pre>

**ANY**: Operador compara um valor a um conjunto de valores retornados por uma subconsulta, tal forma que a subconjunta deve retornar exatamente uma coluna e preceda por um operador de comparação. Seguindo a forma *expresion operator ANY(subquery)*

**SOME**: