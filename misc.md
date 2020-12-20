### Benchmark

Pode-se utilizar a VisualVM para monitorar aplicações que utilizam a JVM para execução.

Para rodar um stress test de requisição pode-se utilizar o Apache Benchmark.

``sudo apt-get install apache2-utils``

``ab -n 1000000 -c 1000 http://localhost:8080/v1/ping``

Definindo o tamanho do heap para a JVM:

``java -jar -Xms156M -Xmx156M app.jar``


## Falult-tolerant basics

Numa arquitetura que existe a comunicação com serviços distribuídos é importante prevenir sobre eventuais problemas. Quando se trata de uma comunicação HTTP para troca de informações ficamos à mercê de uma rede instável que nem sempre corresponderá como o necessário. Dado dois serviços A e B, o serviço A utiliza os recursos do serviço B por uma chamada HTTP direta. Nesse caso temos uma *remote call* visto que a chamada não é interna do próprio serviço A, i.e. *local call*, dessa forma trafegamos as informações por uma rede que eventualmente pode falhar por perde de pacotes, instabilidade ou mesmo um problema no serviço B. Caso esses problemas não sejam tratados podemos nos deparar com queda de um serviço e tempos de resposta altos. Programas tolerantes à falha indicam que pelo menos o programa tem uma chance de se recuperar de uma falha, o software é desenvolvido com esse pensamento. Para casos como estes algumas trativas podem ser tomadas.

Sempre utilizar timeouts, dessa forma não prendemos um recurso, uma thread, em uma execução por tempo demais que pode acumular com processos concorrentes

Dependendo do escopo pode-se utilizar uma tratativa de retentativa, retry policy. Dessa forma se a requisição falha pode ser feita *n* tentativas em recurso. Entretanto ainda pode ser ineficientes fazer requisições logo em seguida, qual a garantia que o serviço retornará com sucesso após uma falha 50ms atrás? 

Para tal utiliza-se um retry com backoff, que consiste um delay entre cada tentativa. Ainda podemos incrementar mais e adicionar um exponential backoff se necessário, a cada tentativa dobramos o delay entre a requisição e.g. 200ms 400ms 800ms. Ainda podemos adicionar mais um fator de aleatoriedade entre cada tentativa com *Jitter*