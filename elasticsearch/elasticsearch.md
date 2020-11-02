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

*_bulk*: index, create (falha se tive rum documento com mesmo id), update, delete

<pre><code>POST _bulk
{ "index": { "_index": "products", "_id": 200 } }
{ "name: "Expresso Machine",  "price": 199, "in_stock": 5 }
{ "create: { "index": { "_index": "products", "_id": 200 } }
{ "name: "Mil Frather", "price": 149, "in_stock": 14 }</code></pre>
