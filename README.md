# Guia para Execução dos Scripts no Oracle

Este repositório disponibiliza scripts de criação de pacotes PL/SQL que facilitam o gerenciamento de alunos, disciplinas, professores e suas respectivas funcionalidades no Oracle Database.

---

## Passos para Executar os Scripts

### Preparação do Ambiente
1. **Configuração do Banco de Dados**  
   Verifique se o Oracle Database está corretamente configurado e em funcionamento.

2. **Ferramenta de Acesso**  
   Utilize uma interface como o Oracle SQL Developer ou o Oracle Live SQL para interagir com o banco de dados.

---

### Criação de Tabelas Base (se necessário)
Antes de rodar os scripts dos pacotes, assegure-se de que as tabelas relacionadas já estão criadas no banco de dados. As tabelas necessárias incluem:

- `aluno`  
- `disciplina`  
- `professor`  
- `turma`  
- `matricula`  

---

### Execução dos Scripts
1. **Abrir o Script no Editor**  
   Carregue o script do pacote desejado no Oracle SQL Developer.

2. **Execução em Ordem Correta**  
   - Execute primeiro a especificação do pacote:  
     ```sql
     CREATE OR REPLACE PACKAGE ...
     ```
   - Em seguida, execute o corpo do pacote:  
     ```sql
     CREATE OR REPLACE PACKAGE BODY ...
     ```

---

### Teste das Funcionalidades
- Utilize os exemplos de testes incluídos no repositório ou crie seus próprios blocos PL/SQL para invocar os procedimentos e funções de cada pacote.

---

## Resumo dos Pacotes

### **PKG_ALUNO**
Gerencia as operações associadas aos alunos.

- **Procedures**  
  - `EXCLUIR_ALUNO`: Remove um aluno e todas as matrículas vinculadas a ele.

- **Cursores**  
  - `LISTAR_ALUNOS_MAIORES_18`: Lista alunos com mais de 18 anos.  
  - `LISTAR_ALUNOS_POR_CURSO`: Retorna alunos matriculados em um curso específico.

---

### **PKG_DISCIPLINA**
Administra as funcionalidades relacionadas às disciplinas.

- **Procedures**  
  - `CADASTRAR_DISCIPLINA`: Insere uma nova disciplina, evitando duplicatas.  
  - `LISTAR_ALUNOS_DISCIPLINA`: Retorna alunos matriculados em uma disciplina específica.

- **Cursores**  
  - `TOTAL_ALUNOS_POR_DISCIPLINA`: Lista disciplinas com mais de 10 alunos matriculados e a quantidade total de alunos.

- **Funções**  
  - `MEDIA_IDADE_DISCIPLINA`: Calcula a média de idade dos alunos em uma disciplina.

---

### **PKG_PROFESSOR**
Gerencia as operações relacionadas aos professores.

- **Procedures**  
  - `TOTAL_TURMAS_POR_PROFESSOR`: Lista professores e o número de turmas que cada um leciona (apenas para aqueles com mais de uma turma).

- **Funções**  
  - `TOTAL_TURMAS_PROFESSOR`: Retorna o total de turmas de um professor específico.  
  - `PROFESSOR_DISCIPLINA`: Recupera o nome do professor responsável por uma disciplina específica.

---

## Dicas Úteis

### Habilitar DBMS_OUTPUT
Para visualizar mensagens de saída ou resultados de cursores, ative o recurso DBMS_OUTPUT no Oracle SQL Developer.

### Identificar Erros de Compilação
Caso ocorram erros ao compilar um pacote, utilize o comando `SHOW ERRORS` para identificar e corrigir os problemas.

### Inserir Dados para Testes
Popule as tabelas relacionadas com dados de exemplo para criar cenários reais e testar as funcionalidades implementadas nos pacotes.
