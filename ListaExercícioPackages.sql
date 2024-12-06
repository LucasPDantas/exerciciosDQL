
CREATE OR REPLACE PACKAGE PKG_ALUNO AS
    -- Procedure para excluir um aluno e todas as suas matrículas associadas no sistema
    PROCEDURE EXCLUIR_ALUNO (p_id_aluno IN NUMBER);

    -- Procedure para abrir um cursor que lista todos os alunos com idade maior que 18 anos
    PROCEDURE LISTAR_ALUNOS_MAIORES_18 (cur_alunos OUT SYS_REFCURSOR);

    -- Procedure para abrir um cursor parametrizado que retorna alunos matriculados em um curso específico
    PROCEDURE LISTAR_ALUNOS_POR_CURSO (p_id_curso IN NUMBER, cur_curso OUT SYS_REFCURSOR);
END PKG_ALUNO;
/


CREATE OR REPLACE PACKAGE BODY PKG_ALUNO AS
    -- Procedure para excluir um aluno com todas as suas dependências
    PROCEDURE EXCLUIR_ALUNO (p_id_aluno IN NUMBER) IS
    BEGIN
        -- Remove todas as matrículas relacionadas ao aluno informado
        DELETE FROM matricula
        WHERE id_aluno = p_id_aluno;

        -- Remove o aluno especificado do banco de dados
        DELETE FROM aluno
        WHERE id_aluno = p_id_aluno;

        COMMIT; -- Aplica as alterações no banco de dados
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK; -- Reverte as alterações em caso de erro
            RAISE; -- Relança o erro para ser tratado externamente
    END EXCLUIR_ALUNO;

    -- Procedure para listar todos os alunos com idade acima de 18 anos
    PROCEDURE LISTAR_ALUNOS_MAIORES_18 (cur_alunos OUT SYS_REFCURSOR) IS
    BEGIN
        -- Abre o cursor para obter os dados dos alunos maiores de 18 anos
        OPEN cur_alunos FOR
        SELECT nome, data_nascimento
        FROM aluno
        WHERE TRUNC(MONTHS_BETWEEN(SYSDATE, data_nascimento) / 12) > 18;
    END LISTAR_ALUNOS_MAIORES_18;

    -- Procedure para listar alunos matriculados em um curso específico
    PROCEDURE LISTAR_ALUNOS_POR_CURSO (p_id_curso IN NUMBER, cur_curso OUT SYS_REFCURSOR) IS
    BEGIN
        -- Abre o cursor com a lista de alunos vinculados ao curso informado
        OPEN cur_curso FOR
        SELECT DISTINCT a.nome
        FROM aluno a
        INNER JOIN matricula m ON a.id_aluno = m.id_aluno
        INNER JOIN disciplina d ON m.id_disciplina = d.id_disciplina
        WHERE d.id_curso = p_id_curso;
    END LISTAR_ALUNOS_POR_CURSO;
END PKG_ALUNO;
/


CREATE OR REPLACE PACKAGE PKG_DISCIPLINA AS
    -- Procedure para cadastrar uma nova disciplina no banco de dados
    PROCEDURE CADASTRAR_DISCIPLINA(p_nome IN VARCHAR2, p_descricao IN CLOB, p_carga_horaria IN NUMBER);

    -- Procedure para abrir um cursor que retorna o total de alunos matriculados por disciplina
    PROCEDURE TOTAL_ALUNOS_POR_DISCIPLINA(cur_disciplinas OUT SYS_REFCURSOR);

    -- Procedure para calcular a média de idade dos alunos em uma disciplina específica
    PROCEDURE MEDIA_IDADE_DISCIPLINA(p_id_disciplina IN NUMBER, cur_media OUT SYS_REFCURSOR);

    -- Procedure para abrir um cursor que lista os alunos de uma disciplina específica
    PROCEDURE LISTAR_ALUNOS_DISCIPLINA(p_id_disciplina IN NUMBER, cur_alunos OUT SYS_REFCURSOR);
END PKG_DISCIPLINA;
/


CREATE OR REPLACE PACKAGE BODY PKG_DISCIPLINA AS
    -- Procedure para inserir uma nova disciplina, evitando duplicatas
    PROCEDURE CADASTRAR_DISCIPLINA(p_nome IN VARCHAR2, p_descricao IN CLOB, p_carga_horaria IN NUMBER) IS
        v_exists NUMBER;
    BEGIN
        -- Verifica se já existe uma disciplina com os mesmos atributos no banco de dados
        SELECT COUNT(1)
        INTO v_exists
        FROM disciplina
        WHERE nome = p_nome 
          AND DBMS_LOB.SUBSTR(descricao, 4000) = DBMS_LOB.SUBSTR(p_descricao, 4000)
          AND carga_horaria = p_carga_horaria;

        -- Caso não exista, insere a nova disciplina
        IF v_exists = 0 THEN
            INSERT INTO disciplina (nome, descricao, carga_horaria)
            VALUES (p_nome, p_descricao, p_carga_horaria);
            COMMIT; -- Salva a alteração no banco
        END IF;
    END CADASTRAR_DISCIPLINA;

    -- Procedure para retornar disciplinas com o número de alunos matriculados, filtrando por mais de 10 alunos
    PROCEDURE TOTAL_ALUNOS_POR_DISCIPLINA(cur_disciplinas OUT SYS_REFCURSOR) IS
    BEGIN
        -- Abre o cursor para listar disciplinas e o total de alunos matriculados
        OPEN cur_disciplinas FOR
        SELECT d.nome AS disciplina, COUNT(m.id_aluno) AS total_alunos
        FROM disciplina d
        LEFT JOIN matricula m ON d.id_disciplina = m.id_disciplina
        GROUP BY d.nome
        HAVING COUNT(m.id_aluno) > 10;
    END TOTAL_ALUNOS_POR_DISCIPLINA;

    -- Procedure para calcular a média de idade dos alunos de uma disciplina específica
    PROCEDURE MEDIA_IDADE_DISCIPLINA(p_id_disciplina IN NUMBER, cur_media OUT SYS_REFCURSOR) IS
    BEGIN
        -- Abre o cursor com o cálculo da média de idade
        OPEN cur_media FOR
        SELECT AVG(TRUNC(MONTHS_BETWEEN(SYSDATE, a.data_nascimento) / 12)) AS media_idade
        FROM aluno a
        INNER JOIN matricula m ON a.id_aluno = m.id_aluno
        WHERE m.id_disciplina = p_id_disciplina;
    END MEDIA_IDADE_DISCIPLINA;

    -- Procedure para listar todos os alunos matriculados em uma disciplina específica
    PROCEDURE LISTAR_ALUNOS_DISCIPLINA(p_id_disciplina IN NUMBER, cur_alunos OUT SYS_REFCURSOR) IS
    BEGIN
        -- Abre o cursor para retornar a lista de alunos vinculados à disciplina
        OPEN cur_alunos FOR
        SELECT a.nome AS aluno
        FROM aluno a
        INNER JOIN matricula m ON a.id_aluno = m.id_aluno
        WHERE m.id_disciplina = p_id_disciplina;
    END LISTAR_ALUNOS_DISCIPLINA;
END PKG_DISCIPLINA;
/


CREATE OR REPLACE PACKAGE PKG_PROFESSOR AS
    -- Procedure para abrir um cursor que retorna o total de turmas por professor, filtrando por mais de uma turma
    PROCEDURE TOTAL_TURMAS_POR_PROFESSOR(cur_professores OUT SYS_REFCURSOR);

    -- Function que calcula o total de turmas atribuídas a um professor específico
    FUNCTION TOTAL_TURMAS_PROFESSOR(p_id_professor IN NUMBER) RETURN NUMBER;

    -- Function para retornar o nome do professor responsável por uma disciplina específica
    FUNCTION PROFESSOR_DISCIPLINA(p_id_disciplina IN NUMBER) RETURN VARCHAR2;
END PKG_PROFESSOR;
/


CREATE OR REPLACE PACKAGE BODY PKG_PROFESSOR AS
    -- Procedure para listar professores e o número total de turmas atribuídas
    PROCEDURE TOTAL_TURMAS_POR_PROFESSOR(cur_professores OUT SYS_REFCURSOR) IS
    BEGIN
        -- Abre o cursor com a lista de professores e o total de turmas
        OPEN cur_professores FOR
        SELECT p.nome AS professor, COUNT(t.id_turma) AS total_turmas
        FROM professor p
        LEFT JOIN turma t ON p.id_professor = t.id_professor
        GROUP BY p.nome
        HAVING COUNT(t.id_turma) > 1;
    END TOTAL_TURMAS_POR_PROFESSOR;

    -- Function para calcular e retornar o total de turmas atribuídas a um professor
    FUNCTION TOTAL_TURMAS_PROFESSOR(p_id_professor IN NUMBER) RETURN NUMBER IS
        v_total NUMBER;
    BEGIN
        -- Conta o número de turmas associadas ao professor
        SELECT COUNT(*)
        INTO v_total
        FROM turma
        WHERE id_professor = p_id_professor;

        RETURN v_total; -- Retorna o total calculado
    END TOTAL_TURMAS_PROFESSOR;

    -- Function para obter o nome do professor responsável por uma disciplina
    FUNCTION PROFESSOR_DISCIPLINA(p_id_disciplina IN NUMBER) RETURN VARCHAR2 IS
        v_professor_nome VARCHAR2(100);
    BEGIN
        -- Busca o nome do professor atribuído à disciplina especificada
        SELECT p.nome
        INTO v_professor_nome
        FROM professor p
        INNER JOIN turma t ON p.id_professor = t.id_professor
        WHERE t.id_disciplina = p_id_disciplina;

        RETURN v_professor_nome; -- Retorna o nome do professor
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'Nenhum professor encontrado para esta disciplina.';
        WHEN TOO_MANY_ROWS THEN
            RETURN 'Mais de um professor encontrado para esta disciplina.';
    END PROFESSOR_DISCIPLINA;
END PKG_PROFESSOR;
/
