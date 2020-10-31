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

<pre><code>ALTER TABLE distributors ADD CONSTRAINT fk_distribuitors_address
FOREIGN KEY (address) REFERENCES addresses (address) MATCH FULL;</code></pre>

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

***

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

``SELECT NULLIF (1, 1);`` &#8594; null\
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

**ANY**: Operador compara um valor a um conjunto de valores retornados por uma subconsulta, tal forma que a subconsulta deve retornar exatamente uma coluna e preceda por um operador de comparação. Seguindo a forma *expresion operator ANY(subquery)*

<pre><code>SELECT title
FROM film
WHERE length >= ANY(
    SELECT MAX( length )
    FROM film
    INNER JOIN film_category USING(film_id)
    GROUP BY  category_id );</code></pre>

**ALL**: Permite consultar dados comparando um valor com uma lista de valores retornados por uma subconsulta.

- *nome_da_coluna* > ALL (subconsulta) a expressão é avaliada como verdadeira se um valor for maior do que o maior valor retornado pela subconsulta.

<pre><code>SELECT film_id,
       title,
       LENGTH
FROM film
WHERE LENGTH > ALL
    (SELECT ROUND(AVG (LENGTH),2)
     FROM film
     GROUP BY rating)
ORDER BY LENGTH;</code></pre>

***

## Transações

O ponto essencial de uma transação é que ela agrupa várias etapas em uma única operação tudo ou nada. Os estados intermediários entre as etapas não são visíveis para outras transações simultâneas e, se ocorrer alguma falha que impeça a conclusão da transação, nenhuma das etapas afetará o banco de dados.

**BEGIN**: Indicia ínicio de uma transação 
**COMMIT**: Define o ponto onde as alterações são de fato efetivadas no banco de dados
**ROLLBACK**: Volta ao último estado do banco de dados
**SAVEPOINT**: Pontos de "checkpoint" onde podemos voltar com *rollback* caso alguma operação falhe

<pre><code>BEGIN;
UPDATE accounts SET balance = balance - 100.00
    WHERE name = 'Alice';
SAVEPOINT my_savepoint;
UPDATE accounts SET balance = balance + 100.00
    WHERE name = 'Bob';
ROLLBACK TO my_savepoint;
UPDATE accounts SET balance = balance + 100.00
    WHERE name = 'Wally';
COMMIT;</code></pre>

***

## Joins

Através de operações de conjuntos podemos relacionar entidades.

**INNER JOIN**: Operação entre intersecção de dois conjuntos. Compara o valor da primeira coluna da primeira tabela com o valor da segunda coluna de cada linha da segunda tabela. Se esses valores forem iguais, a junção interna cria uma nova linha que contém colunas de ambas as tabelas e adiciona essa nova linha ao conjunto de resultados.

<pre><code>SELECT *
FROM table_1
INNER JOIN table_2 ON table_1.id = table_2.id</code></pre>

<div style="text-align: center"><img src="https://images.squarespace-cdn.com/content/v1/5732253c8a65e244fd589e4c/1464122775537-YVL7LO1L7DU54X1MC2CI/ke17ZwdGBToddI8pDm48kMjn7pTzw5xRQ4HUMBCurC5Zw-zPPgdn4jUwVcJE1ZvWMv8jMPmozsPbkt2JQVr8L3VwxMIOEK7mu3DMnwqv-Nsp2ryTI0HqTOaaUohrI8PIvqemgO4J3VrkuBnQHKRCXIkZ0MkTG3f7luW22zTUABU/image-asset.png?format=300w"></div>

**LEFT JOIN**: Feita a comparação entre as colunas das duas tabelas e caso esses valores forem iguais a junção à esquerda cria uma nova linha que contém colunas de ambas as tabelas e adiciona essa nova linha ao conjunto de resultados. Caso os valores não sejam iguais, a junção à esquerda também cria uma nova linha que contém colunas de ambas as tabelas e a adiciona ao conjunto de resultados, caso não exista dados para coluna a direita será prenchido como null.

<pre><code>SELECT *
FROM left_table
INNER JOIN right_table ON left_table.id = right_table.id</code></pre>

<div style="text-align: center"><img src="https://images.squarespace-cdn.com/content/v1/5732253c8a65e244fd589e4c/1464122797709-C2CDMVSK7P4V0FNNX60B/ke17ZwdGBToddI8pDm48kMjn7pTzw5xRQ4HUMBCurC5Zw-zPPgdn4jUwVcJE1ZvWEV3Z0iVQKU6nVSfbxuXl2c1HrCktJw7NiLqI-m1RSK4p2ryTI0HqTOaaUohrI8PIO5TUUNB3eG_Kh3ocGD53-KZS67ndDu8zKC7HnauYqqk/image-asset.png?format=300w"></div>

**RIGHT JOIN**: Funciona de forma analoga ao left join considerando os elementos na tabela da direita.

<pre><code>SELECT *
FROM right_table
RIGHT JOIN left_table ON right_table.id = left_table.id</code></pre>

<div style="text-align: center"><img src="https://images.squarespace-cdn.com/content/v1/5732253c8a65e244fd589e4c/1464122744888-MVIUN2P80PG0YE6H12WY/ke17ZwdGBToddI8pDm48kMjn7pTzw5xRQ4HUMBCurC5Zw-zPPgdn4jUwVcJE1ZvWlExFaJyQKE1IyFzXDMUmzc1HrCktJw7NiLqI-m1RSK4p2ryTI0HqTOaaUohrI8PI-FpwTc-ucFcXUDX7aq6Z4KQhQTkyXNMGg1Q_B1dqyTU/image-asset.png?format=300w"></div>

**FULL JOIN**: Retorna um conjunto de resultados que contém todas as linhas das tabelas esquerda e direita, com as linhas correspondentes de ambos os lados, se disponíveis. Caso não haja correspondência, as colunas da tabela serão preenchidas com NULL.

<pre><code>SELECT a,
       fruit_a,
       b,
       fruit_b
FROM basket_a
FULL OUTER JOIN basket_b ON fruit_a = fruit_b;</code></pre>

<div style="text-align: center"><img src="https://images.squarespace-cdn.com/content/v1/5732253c8a65e244fd589e4c/1464122981217-RIYH5VL2MF1XWTU2DKVQ/ke17ZwdGBToddI8pDm48kMjn7pTzw5xRQ4HUMBCurC5Zw-zPPgdn4jUwVcJE1ZvWEV3Z0iVQKU6nVSfbxuXl2c1HrCktJw7NiLqI-m1RSK4p2ryTI0HqTOaaUohrI8PIO5TUUNB3eG_Kh3ocGD53-KZS67ndDu8zKC7HnauYqqk/image-asset.png?format=300w"></div>


**UNION**: Combina conjuntos de resultados de duas ou mais instruções SELECT em um único conjunto de resultados.

<pre><code>SELECT select_list_1
FROM table_expresssion_1
UNION
SELECT select_list_2
FROM table_expression_2</code></pre>