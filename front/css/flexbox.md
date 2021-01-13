### Flexbox


**Container**:

Define o tipo de disposição para flex.

``display: flex``

Define o fluxo dos items, por padrão é *row*

``flex-direction: row|row-reverse|column|column-reverse``

Define a quebra de linha para os elementos:

``flex-wrap: nowrap|wrap|wrap-reverse``

Atalho para flex-direction + flex-wrap:

``flex-flow: row wrap``

Alinhamento horizontal de elementos: 

``justify-content: flex-start|flex-end|center|space-between|space-around``

Alinhamento vertical de elementos: 

``align-items: stretch|flex-start|flex-end|center|baseline``

Alinhamento vertical com quebra de linha:

``align-content: stretch|space-around|space-between``

**Itens**:

Define ordem dos elementos: 

``order: 1|2..``

Alinha um itens no eixo oposto ao do container, se a direção estiver para row então alinha verticalmente, se está para column alinha horizontalmente.

``align-self: auto|flex-start|flex-end|center|baseline|stretch``

Define o crescimento de cada item:

Exemplo, todos elementos com grow igual à 1 signfica que todos tem a mesma medida. Se um elemento tiver grow como 3 este tentarar ter até três vezes o tamanho dos demais.

``flex-grow: 0|1|2...``

Define o tamanho inicial de cada item:

``flex-basis: 20px``

Define quanto um elemento deve ser "encolhido" em relação aso demais:

``flex-shrink: 1|2..``


