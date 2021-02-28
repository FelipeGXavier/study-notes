### Testes automatizados

Quando o assunto são testes automatizados em aplicações back-end existem basicamente dois principais modelos de testes automatizados, unitários e de integração. Testes de unidade buscam testar comportamentos de forma isolada de menor granularidade, para atingir o teste de forma isolada se utilizam stubs, mocks e spies. Stubs são objetos falsos, servem apenas como dublês de um comportamento retornando uma informação. Mocks funcionamento como um "proxy", uma interface, para uma dependência de uma classe, um objeto do tipo Mock não possui nenhum comportamento até que seja descrito. Spies são similiares a Mocks, entretanto spies utilizam um objeto já existente, o comportamento de um spy é a do objeto que foi passado para tal a menos que seja sobrescrito seu comportamento assim como ocorre com Mocks. Um spy pode ser considerado como um mock parcial. 

Testes de integração procuram testar o comportamento como um todo de um sistema. Exemplificando, caso a aplicação seja um API e que utilize banco de dados um possível teste de integração para um endpoint simularia a chamada HTTP assim como a chamada ao banco de dados. Para questão de banco de dados é comum utilizar bancos mais leves, como é o caso do sqlite e h2. 

Em questão de testes um padrão muito comum é a injeção de dependência utilizando interfaces ou classes concretas. Com a inejação de dependência tem-se maior facilidade para testar unidades de comportamento com uso de mocks e spies. 

No ambiente de aplicações Java existem duas principais dependências para testes automatizados, JUnit e Mokcito. O Mockito é utilizado para mocks, spies, stubs, simulação de comportamentos e assim por diante, enquanto o JUnit, principalmente, é utilizado fazer as asserções de um resultado e controlar o ciclo de vida de uma bateria de testes. Considerando testes em três etapas, Given-When-Then, dado um contexto quando uma determinada condição ocorre é esperado que determinada ação ocorra. Exemplo, uma classe tem como resposabilidade chamar um serviço externo fazendo uma chamada HTTP para tal e processar esses dados com ou outra classe presente em suas dependências e posteriomente formatando o resultado. Para realizar um teste de integração as classes externas, de requisição e processamento, poderiam ser "mockadas" e ensinadas para qual valor devem retornar, a partir disso podemos testar o comportamento isolado da classe. 

Notas de gerais de uso com JUnit e Mockito: 

O ciclo de testes por padrão segue por método, esse comportamento pode ser alterado alterando o ciclo para que seja por classe com a anotação
``@TestInstance(TestInstance.Lifecycle.PER_CLASS)``
Dessa forma podemos utilizar os hooks de ``@BeforeAll`` sem seu uso estático por exemplo e alterar estado de objetos presentes na classe de teste ao longo de todos testes. 

O Mockito possui algumas formas de criar mocks, uma é utilizando ``@Mock`` nos atributes e ``@InjectMocks`` na classe de destino, para que seja possível utilizar essa forma é necessário que a classe esteja anotada com ``@ExtendWith(MockitoExtension.class)`` ou programaticamente como initMocks. 

Outra forma é utilizando o método <br>
``Mockito.mock(Dependencia.class)``

Para definir comportamentos para o Mock criado. <br>
``Mockito.when(dependencia.method()).thenReturn(val);``

Podemos definir para quando exata entrada retornar determinado valor ou quando qualquer tipo. 

``Mockito.when(dependencia.method(eq("test"))).thenReturn(anyString());``

``Mockito.when(dependencia.method(any()).thenReturn("Hello World");``

Podemos verificar quantas vezes o método de um mock foi chamado.

``Mockito.verify(dep, times(1)).get(anyString());``

Uso de spies: 
<pre><code>Writer spyWriter = spy(writer);
spyWriter.append("Hello").append("World");
spyWriter.finish();
verify(spyWriter, times(2)).flush();</code></pre>



