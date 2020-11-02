## Elasticsearch

No Elasticsearch os dados são armazenados como documentos, unidades de informação. Analogamento um documento seria um registro de uma tabela em um banco de dados relacional. 

Um documento possui campos que seria equivalente a colunas em bancos relacionais.

Nós comunicamos com Elasticsearch através de chamadas HTTP por uma API rest.

ElasticStack
- Kibana (Análise visual e métricas)
- Logstash (Processar logs e enviar para o Elasticsearch, processamento de pipeline)
- Beats (Coletar dados para Elasticsearch ou Logstash)
- X-Pack (Traz mais funcionalidades para Elasticsearch, segurança, monitoramento)
- Elasticsearch (Engine de busca)

**Características e arquitetura**

**Node:** Uma instância do Elasticsearch que armazena dados. Podemos ter vários nós rodando, um nó se refere a uma instância do Elasticsearch e não a uma máquina, então é possível rodar vários nós em uma mesma máquina. Os dados são distribuídos entre os nós.

**Master Node:** Dentre os nós elegidos como master este é o responsável por criar e delete índices entre os outros.

**Cluster:** Coleção de nós relacionados, clusteres são independentes entre si. 

Documentos são organizados por índices. Um índice agrupa documentos e provê configurações que facilitam disponibilidade e escalibilidade.

*_cat* facilita formatação de dados para visualização. Endereções que começam com _ são de API por convenção.

``GET _cat/nodes?v`` retorna dados sobre os nós

``GET _cat/indices?v`` retorna dados sobre os índices

``GET _shard?v`` retorna dados sobre shards

``GET _cluster/health`` retorna dados sobre o cluster

Executando com cURL

``curl -XGET "http://localhost:9200/_cluster/health"``

<pre><code>curl -XGET "http://es01:9200/.kibana/_search" -H 'Content-Type: application/json' -d'{  "query": {    "match_all": {}  }}'</code></pre>

Sharding: Uma forma de dividir um índice em partes separadas onde que cada parte é chamada de shard. Sharding occore a nível de índice e não de cluster ou nó. Principal motivo para separar um índice em múltiplos shard é para escalar horizontalmente com o volume de dados. Podemos distribuir shard entre múltiplos nós.

Replicação: Por padrão o Elasticseacrh já provê replicação de shards. Replicação é configurado a nível de índice e funciona criando cópias de shards, conhecidas como replica shards. Um shard que foi replicado é chamado de primary shard. Um primary shard e seus replica shards são chamados de replication group. Replica shard são uma cópia completa de um shard. 

Caso não seja definido um id para o documento o Elasticsearch irá gerar um hash único para tal.

Cria um novo índice :
<pre><code>PUT /products
{
  "settings": {
    "number_of_shard": 2,
    "number_of_replicas": 2
  }
}</code></pre> 

Deleta um índice:
``DELETE /pages`` 

Cria um documento:
<pre><code>POST /products/_doc
{
  "name": "Coffe Make",
  "price": 64,
  "in_stock": 10
}</code></pre>

Cria um documento definindo um id:
<pre><code>PUT /products/_doc/1
{
  "name": "Coffe Maker",
  "price": 64,
  "in_stock": 10
}</code></pre>

Retorna documento pelo id:
``GET /products/_doc/1`` 

Atualiza um documento:
<pre><code>POST /products/_update/1
{
  "in_stock": 0
}</code></pre> 

**Scripting:** Possibilita escrever uma lógica diferente acessando os valores de um documento

Atualiza um documento utilizando o antigo valor:
<pre><code>POST /products/_update/1
{
  "script": {
    "source": "ctx._source.in_stock--"
  }

}</code></pre> 

Atualiza um documento junto com um parâmetro:
<pre><code>POST /products/_update/1
{
  "script": {
    "source": "ctx._source.in_stock -= params.quantity",
    "params": {
      "quantity": 4
    }
  }

}</code></pre> 


Faz um upsert, caso o documento exista aumenta o estoque, caos contrário insere o documento:
<pre><code>POST /products/_update/1
{
  "script": {
    "source": "ctx._source.in_stock++",
  },
  "upsert": {
    "name": "Blender",
    "price": 399,
    "in_stock": 5
  }
}</code></pre> 

Substitui um documento por completo:
<pre><code>PUT /products/_doc/1
{
  {
    "name": "Toaster"
  }
}</code></pre> 

Remove um documento:
``DELETE /products/_doc/1`` 

**Routing:** Processo de resolver um shard para um documento, cálcula onde o documento está de acordo com a quantidade de shardings no índice.

Para ler um documento. Uma requisição é recebida e processada por um nó coordenador. Routing é utilizado para resolver o grupo de repluicação do documento. ARS (Adaptive Replica Selection) é utilizado para enviar a consulta ao melhor shard disponível. Serve como um load balancer. Nó coordenador coleta a response e envia para o client.

Para escrever um documento. Requisição é recebida por um primary shard e encaminhado para suas replicas. Primary terms para se recuprar de falhas.

**Versioning:** O metadado _version de um documento representa em qual versão ele se encontra. Cada vez que alterado ou feita alguma operação em cima ele é incrementando.

**Primary term:** Para garantir que uma versão mais antiga de um documento não substitua uma versão mais recente, cada operação realizada em um documento recebe um número de sequência pelo fragmento primário que coordena essa mudança.

**Sequence number:** É um número sequencial que conta o número de operações que aconteceram no índice

**Optimistic concurrency control:** Previne uma versão antiga de um documento sobrescreva uma nova versão, mantém a sequência correta de operações. 

- if_primary_term
- if_seq_no

Atualiza documentos por query:
<pre><code>POST /products/_update_by_query
{
  "script": {
    "source": "ctx._source.in_stock--"
  },
  "query": {
    "match_all": {}
  }
}</code></pre> 

Atualiza documentos por query, caso tiver conflito continua:
<pre><code>POST /products/_update_by_query
{
  "conflicts": "proceed",
  "script": {
    "source": "ctx._source.in_stock--"
  },
  "query": {
    "match_all": {}
  }
}</code></pre> 

Deleta documentos por query:
<pre><code>POST /products/_delete_by_query
{
  "query": {
    "match_all": {}
  }
}</code></pre> 

**Batch processing:** 

Se umaoperação falhar não irá interromper as demais.

*_bulk*: index, create (falha se tiver um documento com mesmo id), update, delete

<pre><code>POST _bulk
{ "index": { "_index": "products", "_id": 200 } }
{ "name: "Expresso Machine",  "price": 199, "in_stock": 5 }
{ "create: { "index": { "_index": "products", "_id": 200 } }
{ "name: "Mil Frather", "price": 149, "in_stock": 14 }</code></pre>

<pre><code>POST _bulk/products
{ "update": {"_id": 200 } }
{ "doc: { "price": 10 } }
{ "delete: { "index": { "_id": 200 } }</code></pre>

**Importando data com curl:**

<pre><code>curl -H "Content-type: application/x-ndjson" -XPOST http://localhost:9200/products/_bulk --data-binary "@products-bulk.json"</code></pre>

**Analysis:** Quando um documento é indexado ele passa pelo processo do analyzer antes de ser armazenado.

1. Character filters: Adiciona, remove ou altera caracteres, analyzers contém zero ou mais character filters. São aplicados na ordem que forem especificados, e.g. *html_strip*
2. Tokenizer: Um analyzer contém apenas um tokenizer. Responsável por separar uma string em tokens.
3. Token filters: Recebe os tokens do tokenizer. Pode remover, adicionar ou alterar tokens. Um analyzer pode ter zero ou mais token filters. e.g. *lowercase*

<img src="../assets/es_01.png">

Elasticsearch possui vários analyzers nativamente, characters filters, tokenizer e token filters. Sendo possível criar um customizado.

Retorna a forma como o analyzer avalia a sentença: 

<pre><code>POST _analyze
{
  "text": "2 guys walk into a bar, but the third... DUCKS! :-)",
  "analyzer": "standard"
}</code></pre>

<pre><code>POST _analyze
{
  "text": "2 guys walk into a bar, but the third... DUCKS! :-)",
  "char_filter": [],
  "tokenizer": "standard",
  "filter": ["lowercase"]
}</code></pre>

**Inverted indices:** Mapeamento entre termos e documentos que contenham eles. Termos são os tokens do analyzer. O Elasticsearch usa uma estrutura de dados chamada índice invertido que oferece suporte a pesquisas de texto completo muito rápidas. Um índice invertido lista cada palavra única que aparece em qualquer documento e identifica todos os documentos em que cada palavra ocorre. Cada campos textual tem seu próprio índice invertido. Criados e gerenciados pelo Apache Lucene.

<img src="../assets/es_02.png">

**Mapping:** Define uma estrutrua para um documento, seus campos e tipo de dado. Configuração de como os valores são indexados. Comparando ao banco de dados relacional seria como o schema de uma tabela. Mapping de um documento pode ser explícito, definindo manualmente os tipos e valores, ou dinâmico onde o Elasticsearch gerará o mapping quando os documentos são indexados.

<img src="../assets/es_03.png">

**Tipos de dados**: <a href="https://www.elastic.co/guide/en/elasticsearch/reference/current/mapping-types.html">Documentação</a>

Alguns casos:

- nested (consulta de objetos, arrays de forma individual)
- object
- keyword (busca por valores exatos, não é divdido em outros tokens, mantém o campo como um único)
- text (sem necessariamente serem exatos)

Análise de como campos marcados como keyword são análisados.

<pre><code>POST _analyze
{
  "text": "2 guys walk into a bar, bar the third... DUCKS! :-)",
  "analyzer": "keyword"
}</code></pre>

Resultado:

<pre><code>{
  "tokens" : [
    {
      "token" : "2 guys walk into a bar, bar the third... DUCKS! :-)",
      "start_offset" : 0,
      "end_offset" : 51,
      "type" : "word",
      "position" : 0
    }
  ]
}</code></pre>

Análise padrão:

<pre><code>POST _analyze
{
  "text": "2 guys walk into a bar, bar the third... DUCKS! :-)",
  "analyzer": "keyword"
}</code></pre>

Resultado: 

<pre><code>{
  "tokens" : [
    {
      "token" : "2",
      "start_offset" : 0,
      "end_offset" : 1,
      "type" : "<NUM>",
      "position" : 0
    },
    {
      "token" : "guys",
      "start_offset" : 2,
      "end_offset" : 6,
      "type" : "<ALPHANUM>",
      "position" : 1
    },
    {
      "token" : "walk",
      "start_offset" : 7,
      "end_offset" : 11,
      "type" : "<ALPHANUM>",
      "position" : 2
    },
    {
      "token" : "into",
      "start_offset" : 12,
      "end_offset" : 16,
      "type" : "<ALPHANUM>",
      "position" : 3
    },
    {
      "token" : "a",
      "start_offset" : 17,
      "end_offset" : 18,
      "type" : "<ALPHANUM>",
      "position" : 4
    },
    {
      "token" : "bar",
      "start_offset" : 19,
      "end_offset" : 22,
      "type" : "<ALPHANUM>",
      "position" : 5
    },
    {
      "token" : "bar",
      "start_offset" : 24,
      "end_offset" : 27,
      "type" : "<ALPHANUM>",
      "position" : 6
    },
    {
      "token" : "the",
      "start_offset" : 28,
      "end_offset" : 31,
      "type" : "<ALPHANUM>",
      "position" : 7
    },
    {
      "token" : "third",
      "start_offset" : 32,
      "end_offset" : 37,
      "type" : "<ALPHANUM>",
      "position" : 8
    },
    {
      "token" : "ducks",
      "start_offset" : 41,
      "end_offset" : 46,
      "type" : "<ALPHANUM>",
      "position" : 9
    }
  ]
}</code></pre>

**Type coersion:** Elasticsearch pode fazer a conversão entre alguns tipos, e.g. um campo notado como float pode receber um float em forma de string que ainda será aceito pela coerção do tipo. Coerção de tipos não é utilizado para o mapping dinâmico. Quando feita consulta em documentos o tipo pode ser armazenado com ostring, como nesse último, apesar de que internamente no Apache Lucene ele será tratado como float. Caso o tipo seja importante para a aplicação pode ser desabilitado a coerção de tipos ou definir o mapping de forma explícita.

**Explicit Mapping:** 

<pre><code>PUT /reviews
{
  "mappings": {
    "properties": {
      "rating": { "type": "float"},
      "content": { "type": "text"},
      "product_id": {"type": "integer" },
      "author": { 
        "properties": {
          "first_name": {"type": "text" },
          "last_name": {"type": "text" },
          "email": {"type": "keyword" }
        }
      }
    }
  }
}</code></pre>

Adicionar mapping para um index: 

<pre><code>PUT /reviews/_mapping
{
  "mappings": {
    "properties": {
      "created_at": { "type": "date"}
    }
  }
}</code></pre>

Retorna mapping de um index:
``GET /reviews/_mapping``

**Dates:** Podem ser armazenadas de três formas, em strings formatadas para uma data, como milisegundo em um long e em segundos desde a época em um integer.

- date (data com tempo, sem tempo e milisegundos desde a época)

Apenas data:

<pre><code>PUT /reviews/_doc/2
{
  "rating": 4.5,
  "content": "Not bad. Not bad at all!",
  "product_id": 123,
  "created_at": "2015-03-27",
  "author": {
    "first_name": "Average",
    "last_name": "Joe",
    "email": "avgjoe@example.com"
  }
}</code></pre>

Data e tempo:
<pre><code>PUT /reviews/_doc/3
{
  "rating": 3.5,
  "content": "Could be better",
  "product_id": 123,
  "created_at": "2015-04-15T13:07:41Z",
  "author": {
    "first_name": "Spencer",
    "last_name": "Pearson",
    "email": "spearson@example.com"
  }
}</code></pre>

Com timezone:

<pre><code>PUT /reviews/_doc/4
{
  "rating": 5.0,
  "content": "Incredible!",
  "product_id": 123,
  "created_at": "2015-01-28T09:21:51+01:00",
  "author": {
    "first_name": "Adam",
    "last_name": "Jones",
    "email": "adam.jones@example.com"
  }
}</code></pre>

Como timestamp (milisegundos desde a eṕoca)
<pre><code>PUT /reviews/_doc/5
{
  "rating": 4.5,
  "content": "Very useful",
  "product_id": 123,
  "created_at": 1436011284000,
  "author": {
    "first_name": "Taylor",
    "last_name": "West",
    "email": "twest@example.com"
  }
}</code></pre>

https://www.elastic.co/guide/en/elasticsearch/guide/current/_finding_exact_values.html

