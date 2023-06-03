USE [hack]
GO

/****** Object:  StoredProcedure [dbo].[TABELAPRICE]    Script Date: 02/06/2023 21:01:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[TABELAPRICE] @Valor decimal(18,2), @Prazo int

AS

CREATE TABLE #TabelaPrice (
    numero int,
    valorPrestacao decimal(18,2),
    valorJuros decimal(18,2),
    valorAmortizacao decimal(18,2),
)

DECLARE @TaxaJuros numeric(10,9)
-- Determina a taxa de juros de acordo com o Valor e Prazo
SET @TaxaJuros = (select PC_TAXA_JUROS from [dbo].[PRODUTO] where @Valor between VR_MINIMO and VR_MAXIMO and @Prazo between NU_MINIMO_MESES and NU_MAXIMO_MESES)
-- Valor prestações fixas
DECLARE @valorPrestacao decimal(18,2) = (@Valor * @TaxaJuros) / (1 - POWER(1 + @TaxaJuros, -@Prazo))

-- Valores serão alterados a cada prestação
DECLARE @valorAmortizacao decimal(18,2)
DECLARE @valorJuros decimal(18,2)

-- Número da prestação
DECLARE @i int = 1

-- Calcula os valores de cada prestação
WHILE @i <= @Prazo
BEGIN
    SET @valorJuros = @Valor * @TaxaJuros
    SET @valorAmortizacao = @valorPrestacao - @valorJuros
    SET @Valor = @Valor - @valorAmortizacao

    -- Insere na tabela temporária
    INSERT INTO #TabelaPrice (Numero, valorPrestacao, valorJuros, valorAmortizacao)
    VALUES (@i, @valorPrestacao, @valorJuros, @valorAmortizacao)

    SET @i = @i + 1
END

-- Mostra o resultado
SELECT numero, valorAmortizacao, valorJuros, valorPrestacao
FROM #TabelaPrice

-- Exclui a tabela temporária
DROP TABLE #TabelaPrice
GO


