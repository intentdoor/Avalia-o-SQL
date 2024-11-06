
--CRIA O BANCO DE DADOS
CREATE DATABASE Biblioteca

--Cria as tabelas
CREATE TABLE Livros (
	LivroID INT PRIMARY KEY,
	NomeLivro VARCHAR(100),
	NomeAutor VARCHAR(100),
	Preco FLOAT
)

CREATE TABLE Clientes (
	ClienteID INT PRIMARY KEY,
	NomeCliente VARCHAR(100),

)

CREATE TABLE Aluguel (
	RegistroID INT PRIMARY KEY,
	DataRegistro DATETIME,
	ClienteID INT,
	LivroID INT,
	Status VARCHAR(10)
)

--Inserindo os dados nas tabelas
INSERT INTO Livros (LivroID,NomeLivro,NomeAutor,Preco)
VALUES (1,'O Pequeno Princípe','Carlos Doroth',15.00),
	   (2,'O Diário de Anne Frank','Anne Frank',20.00),
	   (3,'A Volta no Mundo em 80 Dias','Ricardo Silva',25.00),
	   (4,'A Revolução dos Bichos','George Orwell',23.00),
	   (5,'1985','George Orwell',25.50)

INSERT INTO Clientes (ClienteID,NomeCliente)
VALUES (1,'Leandro Yoki'),
	   (2,'Matheus Leitinho'),
	   (3,'Raí Carvalho')
	  
Insert INTO Aluguel (RegistroID,DataRegistro,ClienteID,LivroID,Status)
VALUES (1,'2024-11-01',2,3,'Em atraso'),
	   (2,'2024-09-08',3,1,'Em atraso'),
	   (3,'2024-10-08',1,2,'Devolvido')

--EXEMPLO DE UMA WINDOWS FUNCTION-- Mostra o valor arrecadado por livros de um determinado autor

SELECT
DISTINCT(NomeAutor),
SUM(Preco)OVER(PARTITION BY NomeAutor) AS Quantia_Vendida
FROM Livros
WHERE NomeAutor = 'George Orwell'


--EXEMPLO DE UM TRIGGER--  Mostra que o sistema impossibilita a exclusão de dados da coluna 'Aluguel'

CREATE OR ALTER TRIGGER ExcluirRegistro
ON Aluguel
INSTEAD OF DELETE
AS
BEGIN
 IF EXISTS(SELECT 1 FROM Aluguel WHERE RegistroID IN (1,2,3))
 BEGIN
 PRINT'Não é possível excluir dados desse campo!!'
 RETURN
END
END

DELETE FROM Aluguel WHERE RegistroID = 2

--EXEMPLO DE UM SUBQUERY--  Realiza uma consulta dos clientes que estão devendo livros
SELECT NomeCliente
FROM Clientes
WHERE ClienteID IN (
	SELECT ClienteID
	FROM Aluguel
	WHERE Status = 'Em atraso')





--EXEMPLO DE UMA FUNCTION-- Mostra quantos dias determinada pessoa está devendo um livro

CREATE FUNCTION TempoDeAluguel (@DataRegistro DATETIME)
RETURNS INT
AS
BEGIN
    RETURN DATEDIFF(DAY, @DataRegistro, GETDATE())
END

SELECT 
    c.NomeCliente, 
    l.NomeLivro, 
    dbo.TempoDeAluguel(a.DataRegistro) AS DiasDeAluguel
FROM 
    Aluguel a
JOIN 
    Clientes c ON a.ClienteID = c.ClienteID
JOIN 
    Livros l ON a.LivroID = l.LivroID
WHERE
    a.Status = 'Em atraso' 

--EXEMPLO DE UMA VIEW-- mostra  os registros de alugueis dos livros com informaçoes de outras tabelas  
--(atribuindo uma letra antes de uma coluna da pra referenciar varios fatores a uma letra só,assim diminui código)
CREATE VIEW vw_AlugueisDetalhados AS
SELECT 
    a.RegistroID,
    a.DataRegistro,
    c.NomeCliente,
    l.NomeLivro,
    l.NomeAutor,
    a.Status,
    l.Preco
FROM 
    Aluguel a
JOIN 
    Clientes c ON a.ClienteID = c.ClienteID
JOIN 
    Livros l ON a.LivroID = l.LivroID;

SELECT * FROM vw_AlugueisDetalhados;

 --EXEMPLO DE UMA CTE-- Mostra todos os registros de algueis

	WITH RegistrosDetalhados AS (
    SELECT
        Clientes.NomeCliente,
        Livros.NomeLivro,
        Aluguel.DataRegistro,
        Aluguel.Status
    FROM
        Aluguel
    JOIN
        Clientes ON Aluguel.ClienteID = Clientes.ClienteID
    JOIN
        Livros ON Aluguel.LivroID = Livros.LivroID
)

SELECT *
FROM RegistrosDetalhados
ORDER BY DataRegistro;

--EXEMPLO DE UMA PROCEDURE -- Busca informaçoes dos alugueis pelo id do cliente

IF EXISTS (SELECT 1 FROM SYS.OBJECTS WHERE TYPE='P' AND NAME ='BuscarAluguelPorCliente')
BEGIN
DROP PROCEDURE BuscarAluguelPorCliente
END
GO

CREATE PROCEDURE BuscarAluguelPorCliente
	@ClienteID INT
AS
BEGIN
	SELECT
		CLIENTES.NomeCliente,
		Livros.NomeLivro,
		Aluguel.DataRegistro,
		Aluguel.Status
	FROM Aluguel
	JOIN
		Clientes ON Aluguel.clienteID = Clientes.ClienteID
	JOIN
		Livros ON Aluguel.LivroID = Livros.LivroID
	WHERE Clientes.ClienteID = @ClienteID
	ORDER BY
		Aluguel.DataRegistro;
END

EXEC BuscarAluguelPorCliente @ClienteID = 3

--EXEMPLO DE UM LOOP--