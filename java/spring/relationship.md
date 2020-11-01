## Relações na ORM

Para relacionamentos biderecionais é necessário notar o relacionamento com **mappedBy = *"nome_coluna_inversa"*** para o objeto que não é o dono do relacionamento

| Notação        | Descrição     | 
| :------------- | :----------: | 
|  @Entity       | Uma classe com essa notação indica que o Hibernate fará o controle do ciclo de vida desse objeto, define as colunas e comportamento para o mapeamento <br>    |
| @OneToOne      | Qualquer um dos lados pode ser o dono, mas apenas um deles deve realmente ser o dono. Se isso não for especificado teremos uma dependência circular.  |
| @OneToMany     | O lado "many" da associação deve ser tornado como o dono da associação.  |
| @ManyToOne     | Este é como o de cima, porém visualizado sob uma perspectiva oposta, mas a mesma regra se aplica - o lado “many” é o dono da associação.  |
| @ManyToMany     | Qualquer um dos lados pode ser o dono da associação.  |
| @JoinColumn     | Indica o lado forte, dono, do relacionamento entre duas classes, define a coluna de join com a chave estrangeira. |

Exemplo @JoinColumn: 

<pre><code>@JoinColumns({
        @JoinColumn(name="ADDR_ID", referencedColumnName="ID"),
        @JoinColumn(name="ADDR_ZIP", referencedColumnName="ZIP")
    })</code></pre>

Este exemplo irá criar duas chaves estrangeiras na entidade.
    

**LAZY e EAGER**

EAGER: Os dados do relcionamento são carregados com o resto dos outros campos na hora que for chamado, sendo utilizado ou não .

LAZY: Os dados do relaciona são carregando quando chamados, por demanda.

**N+1 problem**

Imagine que você tem uma tabela Pessoa e uma tabela Endereco. Cada pessoa tem vários endereços, consolidando uma relação de um para muitos (1-N).

E agora você deseja pegar os endereços de várias pessoas. Normalmente, vemos a seguinte consulta utilizando o ORM de sua preferência:

<pre><code>public List<Pessoa> consultarPessoas() {
    String jpql = "select * from Pessoa";
    return em.createQuery(jpql).getResultList();
}</code></pre>

E, em seguida, você itera por cada Pessoa para pegar os seus endereços:

<pre><code>List<Pessoa> pessoas = consultarPessoas():
for (Pessoa pessoa : pessoas) {
    List<Endereco> enderecos = pessoa.getEnderecos();
}</code></pre>

Imaginando um LAZY entre pessoa e endereços, teremos o seguinte SQL para cada pessoa ao chamar o método pessoa.getEnderecos():

``SELECT * from Endereco where pessoa_id = :id;``

O problema ocorre porque para pegar os endereços das pessoas você pega primeiro a pessoa e depois busca os endereços de cada. Imaginando que a consulta anterior nos retornou 5 pessoas, a quantidade de SQLs gerados será algo assim:

<pre><code> SELECT * from pessoa
 SELECT * from endereco where pessoa_id = 1;
 SELECT * from endereco where pessoa_id = 2;
 SELECT * from endereco where pessoa_id = 3;
 SELECT * from endereco where pessoa_id = 4;
 SELECT * from endereco where pessoa_id = 5;</code></pre>

Ou seja, 1 select de pessoa com N select para endereços, o famoso N + 1 .

quais suas principais causas

Normalmente ela é causada pelo uso inadequado dos ORMs. É preciso entender o que o ORM faz por trás dos bastidores. Embora eles estejam aí para facilitar nossa vida, eles precisam ser usados com sabedoria. Por serem muito permissivos de forma geral, resultados inesperados podem ser causados no mal uso da ferramenta.

e como, na teoria, resolvê-los?

No exemplo que dei anteriormente, seu objetivo era pegar os endereços de várias pessoas. Se forem os endereços de todas as pessoas do banco de dados, você precisa apenas fazer:

 ``SELECT * from Endereco``
Mas se quiser aplicar um filtro para trazer aquelas 5 pessoas, isto pode ser feito evitando aquelas várias consultas com um JPQL diferente, partindo da tabela Endereco também:

 ``SELECT * from Endereco where pessoa_id IN (1,2,3,4,5);``
Já ouvi também que para resolver, é só praticar o eager loading. Mas até que ponto ele é benéfico e capaz de resolver esse problema?

O EAGER loading é uma alternativa, pois o SQL gerado seria algo assim:

<pre><code>SELECT p.id,
       p.nome,
       end.id,
       end.rua,
       end.pessoa_id
FROM pessoa p
JOIN endereco END ON end.pessoa_id = p.id</code></pre>
Contudo, o EAGER é um problema se adicionado entre o relacionamento de Pessoa e Endereço no seu ORM, pois toda vez que você buscar uma pessoa, os endereços também virão juntos. Acredite, você não quer isto como comportamento padrão do seu sistema. Os principais problemas de performance que vi em aplicações que envolviam o uso de algum ORM eram causados por isto.


