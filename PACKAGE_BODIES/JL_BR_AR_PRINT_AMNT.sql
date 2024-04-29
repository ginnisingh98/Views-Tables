--------------------------------------------------------
--  DDL for Package Body JL_BR_AR_PRINT_AMNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_BR_AR_PRINT_AMNT" AS
/* $Header: jlbrrpib.pls 120.3.12010000.2 2009/08/06 10:16:33 nivnaray ship $ */

    FUNCTION BR_CONVERT_AMOUNT (X_Invoice_Amount IN NUMBER,
                  X_Currency_Name  IN VARCHAR2)
                  RETURN VARCHAR2 IS
-- ---------------------------------------------------------------
-- Declaracao de Objetos do Programa
-- ---------------------------------------------------------------
TYPE recext IS RECORD
(
ZERO             CHAR            (001) := '0',
E                CHAR            (003) := ' E ',
DE               CHAR            (004) := ' DE ',
VIRGULA          CHAR            (002) := ', ',
BRANCO           CHAR            (001) := ' ',
CEM              CHAR            (003) := 'CEM',
INVALIDO         CHAR            (008) := '????????',
PLURAL           CHAR            (003) := '999',
SINGULAR         CHAR            (003) := '000',
inteiro          NUMBER          (038) := 0,
decimal          NUMBER          (038) := 0,
Eplural          BOOLEAN               := FALSE,
Emil             BOOLEAN               := FALSE,
txt_inteiro      VARCHAR2        (250) := ' ',
txt_decimal      VARCHAR2        (250) := NULL,
txt_trabalho     VARCHAR2        (250) := ' ',
txt_separador    VARCHAR2        (003) := ' ',
txt_extencao     VARCHAR2        (250) := ' ',
texto            VARCHAR2        (250) := ' ',
centena          NUMBER          (003) := 0,
dezena           NUMBER          (002) := 0,
unidade          NUMBER          (001) := 0,
nivel            NUMBER          (002) := 0,
posicao          NUMBER          (002) := 0,
str_centena      VARCHAR2        (003) := NULL,
str_inteiro      VARCHAR2        (038) := NULL,
str_extracao     VARCHAR2        (038) := NULL
);
Ext recext;
TYPE typex IS TABLE OF VARCHAR2 (40) INDEX BY BINARY_INTEGER;
ex   typex;
mi   typex;
ms   typex;
mi_idx          INTEGER;

-- ---------------------------------------------------------------
-- Procedure de Erro
-- ---------------------------------------------------------------
PROCEDURE Erro (pfuncao IN VARCHAR2, ptexto IN VARCHAR2) IS
BEGIN
  Ext.texto := pfuncao || Ext.BRANCO || ptexto;
  -- DBMS_OUTPUT.PUT_LINE(Ext.inteiro);
  -- DBMS_OUTPUT.PUT_LINE(Ext.texto);
  RAISE_APPLICATION_ERROR(-20000,Ext.texto);
END Erro;
-- ---------------------------------------------------------------
-- Function Extencao
-- ---------------------------------------------------------------
FUNCTION Extencao (pcentena IN VARCHAR2, pnivel IN NUMBER) RETURN VARCHAR2 IS
BEGIN
  Ext.txt_extencao := Ext.INVALIDO;
  IF    pnivel =  0      THEN
        Ext.posicao := 0;
  ELSIF pnivel <= mi_idx THEN
        Ext.posicao := (Ext.nivel-(pnivel-1));
  END IF;

  IF TO_NUMBER(pcentena) > 1 THEN
     Ext.txt_extencao := ms(Ext.posicao);

  --ELSIF Ext.inteiro > 1 THEN
  ELSIF (Ext.inteiro > 1 and NVL(trim(Ext.txt_trabalho),' ') <> 'UM') THEN      --bug 8519062/8770930

     Ext.txt_extencao := ms(Ext.posicao);
  ELSE
     Ext.txt_extencao := mi(Ext.posicao);
  END IF;
  RETURN Ext.BRANCO||Ext.txt_extencao;
  EXCEPTION
    WHEN OTHERS THEN
         Erro ('Extencao',sqlerrm);
END Extencao;
-- ---------------------------------------------------------------
-- Function Centena
-- ---------------------------------------------------------------
FUNCTION Centena(pcentena IN VARCHAR2, pnivel IN NUMBER) RETURN VARCHAR2 IS
BEGIN
  Ext.centena := (TRUNC(TO_NUMBER(pcentena)/100)*100);
  Ext.dezena  := (TRUNC((TO_NUMBER(pcentena) - Ext.centena)/10)*10);
  Ext.unidade := (TO_NUMBER(pcentena) - (Ext.centena + Ext.dezena));
  Ext.txt_separador := Ext.BRANCO;
  Ext.txt_trabalho  := Ext.BRANCO;
  IF (Ext.centena + Ext.dezena + Ext.unidade) > 0 THEN

      IF ((pnivel=Ext.nivel) AND (Ext.decimal=0)) THEN
            IF Ext.nivel>1 THEN
               Ext.txt_trabalho := Ext.E;
            END IF;
      ELSIF pnivel>1 THEN
            Ext.txt_trabalho := Ext.VIRGULA;
      END IF;

      IF (Ext.centena <> 0) THEN
         IF ((Ext.dezena + Ext.unidade) > 0) THEN
	  Ext.txt_trabalho := Ext.txt_trabalho||ex(Ext.centena);
          /* acrescentada a condio ELSIF */
         ELSIF (Ext.centena /100) > 1 THEN
          Ext.txt_trabalho := Ext.txt_trabalho||ex(Ext.centena);
	 ELSE
	  Ext.txt_trabalho := Ext.txt_trabalho||Ext.CEM;
	 END IF;
	 Ext.txt_separador := Ext.E;
      END IF;
      IF (Ext.dezena + Ext.unidade) BETWEEN 1 AND 19 THEN
          Ext.txt_trabalho := Ext.txt_trabalho|| Ext.txt_separador;
          Ext.txt_trabalho := Ext.txt_trabalho|| ex(Ext.dezena+Ext.unidade);
      ELSE
          IF Ext.dezena <> 0 THEN
             Ext.txt_trabalho  := Ext.txt_trabalho || Ext.txt_separador;

             Ext.txt_trabalho  := Ext.txt_trabalho || ex(Ext.dezena);
             Ext.txt_separador := Ext.E;
          END IF;
      END IF;
      IF ((Ext.Unidade <> 0) AND ((Ext.dezena + Ext.unidade) NOT BETWEEN 1 AND 19)) THEN
        Ext.txt_trabalho := Ext.txt_trabalho || Ext.txt_separador;
	Ext.txt_trabalho := Ext.txt_trabalho || ex(Ext.unidade);
	Ext.txt_separador := Ext.E;
      END IF;
      Ext.txt_trabalho := Ext.txt_trabalho|| Extencao(Ext.str_centena,pnivel);
  ELSE
      IF pnivel = Ext.nivel THEN
         IF NOT Ext.Emil THEN
            Ext.txt_trabalho := Ext.txt_trabalho || Ext.DE;
         END IF;
         IF Ext.Eplural THEN
	    Ext.txt_trabalho := Ext.txt_trabalho || Extencao(Ext.PLURAL,pnivel);
	 ELSE
	    Ext.txt_trabalho := Ext.txt_trabalho || Extencao(Ext.SINGULAR,pnivel);
         END IF;
      END IF;
  END IF;
  RETURN REPLACE(Ext.txt_trabalho,'  ',Ext.BRANCO);
  EXCEPTION
    WHEN OTHERS THEN
         Erro ('Centena',sqlerrm);
END Centena;
-- --------------------------------------------
--   INICIO DA ROTINA PRINCIPAL
-- --------------------------------------------
BEGIN
 ex(1):='UM';    ex(11):='ONZE';     ex(10):='DEZ';      ex(100):='CENTO';
 ex(2):='DOIS';  ex(12):='DOZE';     ex(20):='VINTE';    ex(200):='DUZENTOS';
 ex(3):='TRES';  ex(13):='TREZE';    ex(30):='TRINTA';   ex(300):='TREZENTOS';
 ex(4):='QUATRO';ex(14):='QUATORZE'; ex(40):='QUARENTA'; ex(400):='QUATROCENTOS';
 ex(5):='CINCO'; ex(15):='QUINZE';   ex(50):='CINQUENTA';ex(500):='QUINHENTOS';
 ex(6):='SEIS';  ex(16):='DEZESSEIS';ex(60):='SESSENTA'; ex(600):='SEISCENTOS';
 ex(7):='SETE';  ex(17):='DEZESSETE';ex(70):='SETENTA';  ex(700):='SETECENTOS';
 ex(8):='OITO';  ex(18):='DEZOITO';  ex(80):='OITENTA';  ex(800):='OITOCENTOS';
 ex(9):='NOVE';  ex(19):='DEZENOVE'; ex(90):='NOVENTA';  ex(900):='NOVECENTOS';
 mi(2):='MIL';        ms(2):='MIL';
 mi(3):='MILHAO';     ms(3):='MILHOES';

 mi(4):='BILHAO';     ms(4):='BILHOES';
 mi(5):='TRILHAO';    ms(5):='TRILHOES';
 mi(6):='QUATILHAO';  ms(6):='QUATILHOES';
 mi(7):='QUINTILHAO'; ms(7):='QUINTILHOES';
 mi(8):='SEXTILHAO';  ms(7):='SEXTILHOES';
 mi_idx := 8;
 -- -----------------------------------------
 --    Define os tipos das moedas
 -- -----------------------------------------
  IF UPPER(X_Currency_Name) = 'REAL' THEN
	mi(0):='CENTAVO';     ms(0):='CENTAVOS';
        mi(1):='REAL';        ms(1):='REAIS';
  ELSIF UPPER(X_Currency_Name) = 'DOLAR' THEN
        mi(0):='CENTS';       ms(0):='CENTS';
        mi(1):='DOLAR';       ms(1):='DOLARES';
  ELSIF UPPER(X_Currency_Name) = 'YEN'   THEN
        mi(0):='CENTAVO';     ms(0):='CENTAVOS';
        mi(1):='YEN';         ms(1):='YENS';
  ELSE
        mi(0):='????????';    ms(0):='????????';
        mi(1):='????????';    ms(1):='????????';

  END IF;
  -- ---------------------------------------------------------------------
  --     Inicializa as vari de processamento
  -- ---------------------------------------------------------------------
  Ext.inteiro      := TRUNC(X_Invoice_Amount);
  Ext.decimal	   := TRUNC((X_Invoice_Amount - TRUNC(X_Invoice_Amount)) * 100);
  Ext.str_inteiro  := LTRIM(TO_CHAR(Ext.inteiro));
  Ext.nivel        := CEIL(LENGTH(Ext.str_inteiro) / 3);
  Ext.str_extracao := LPAD(Ext.str_inteiro,Ext.nivel * 3,Ext.ZERO);
  Ext.txt_inteiro  := Ext.BRANCO;
  Ext.txt_decimal  := Ext.BRANCO;
  IF Ext.inteiro > 0 THEN
     FOR pos IN 1..Ext.nivel LOOP
         Ext.str_centena := SUBSTR(Ext.str_extracao,((pos * 3) - 3 + 1), 3);
         Ext.txt_inteiro := Ext.txt_inteiro || Centena (Ext.str_centena,pos);
         IF NOT Ext.Emil THEN
            Ext.Emil := ((TO_NUMBER(Ext.str_centena) > 0) AND (pos=(Ext.nivel -1)));
	END IF;
	IF NOT Ext.Eplural THEN

           IF pos <> Ext.nivel THEN
	        Ext.Eplural := (TO_NUMBER(Ext.str_centena) > 1);

           ELSE

                Ext.Eplural := (Ext.inteiro > 1);

           END IF;

	END IF;

    END LOOP;
  END IF;
  IF Ext.decimal > 0 THEN
     Ext.str_centena := LTRIM(TO_CHAR(Ext.decimal,'099'));
     Ext.txt_decimal := Ext.BRANCO;
     IF Ext.inteiro > 0 THEN
        Ext.txt_decimal := Ext.E;
     END IF;
     Ext.txt_decimal := Ext.txt_decimal || Centena(Ext.str_centena,0);
     Ext.txt_inteiro := Ext.txt_inteiro || Ext.BRANCO || LTRIM(Ext.txt_decimal);
  END IF;
  RETURN REPLACE(LTRIM(Ext.txt_inteiro),'',Ext.BRANCO);
  EXCEPTION
     WHEN OTHERS THEN
	Erro('Extenso',sqlerrm);
  END BR_CONVERT_AMOUNT;

END JL_BR_AR_PRINT_AMNT;

/
