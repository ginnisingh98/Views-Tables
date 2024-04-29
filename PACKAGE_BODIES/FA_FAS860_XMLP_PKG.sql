--------------------------------------------------------
--  DDL for Package Body FA_FAS860_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FAS860_XMLP_PKG" AS
/* $Header: FAS860B.pls 120.0.12010000.1 2008/07/28 13:15:59 appldev ship $ */
  FUNCTION REPORT_NAMEFORMULA(COMPANY_NAME IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      L_REPORT_NAME VARCHAR2(80);
    BEGIN
      RP_COMPANY_NAME := COMPANY_NAME;
      SELECT
        CP.USER_CONCURRENT_PROGRAM_NAME
      INTO
        L_REPORT_NAME
      FROM
        FND_CONCURRENT_PROGRAMS_VL CP,
        FND_CONCURRENT_REQUESTS CR
      WHERE CR.REQUEST_ID = P_CONC_REQUEST_ID
        AND CP.APPLICATION_ID = CR.PROGRAM_APPLICATION_ID
        AND CP.CONCURRENT_PROGRAM_ID = CR.CONCURRENT_PROGRAM_ID;
      RP_REPORT_NAME := L_REPORT_NAME;
   	IF (UPPER(RP_REPORT_NAME) LIKE 'MASS%CHANGE%PREVIEW%REPORT%(XML)%') THEN
		RP_REPORT_NAME := 'Mass Change Preview Report';
	END IF;
	RETURN (L_REPORT_NAME);
    EXCEPTION
      WHEN OTHERS THEN
        RP_REPORT_NAME := 'Mass Change Preview Report';
        RETURN (RP_REPORT_NAME);
    END;
    RETURN NULL;
  END REPORT_NAMEFORMULA;
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
     SELECT
--SUBSTR(ARGUMENT1,INSTR(ARGUMENT1,'"',1,1)+1,(INSTR(ARGUMENT1,'"',1,2)-INSTR(ARGUMENT1,'"',1,1) -1))
SUBSTR(ARGUMENT1,INSTR(ARGUMENT1,'=',1,1)+1)
INTO P_MASS_CHANGE_ID1
FROM FND_CONCURRENT_REQUESTS
WHERE REQUEST_ID =P_CONC_REQUEST_ID;
    RETURN (TRUE);
  END BEFOREREPORT;
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERREPORT;
  FUNCTION C_BOOKFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      BOOK VARCHAR(15);
      BOOK_CLASS VARCHAR(15);
      FROM_RULE VARCHAR(15);
      TO_RULE VARCHAR(15);
      FROM_ASSET VARCHAR(15);
      TO_ASSET VARCHAR(15);
      FROM_DPIS DATE;
      TO_DPIS DATE;
    BEGIN
      SELECT
        MCH.BOOK_TYPE_CODE,
        BC.BOOK_CLASS,
        MCH.FROM_ASSET_NUMBER,
        MCH.TO_ASSET_NUMBER,
        MCH.FROM_DATE_PLACED_IN_SERVICE,
        MCH.TO_DATE_PLACED_IN_SERVICE,
        FM.RATE_SOURCE_RULE,
        TM.RATE_SOURCE_RULE
      INTO
        BOOK
        ,BOOK_CLASS
        ,FROM_ASSET
        ,TO_ASSET
        ,FROM_DPIS
        ,TO_DPIS
        ,FROM_RULE
        ,TO_RULE
      FROM
        FA_MASS_CHANGES MCH,
        FA_METHODS FM,
        FA_METHODS TM,
        FA_BOOK_CONTROLS BC
      --WHERE MCH.MASS_CHANGE_ID = P_MASS_CHANGE_ID
      WHERE MCH.MASS_CHANGE_ID = P_MASS_CHANGE_ID1
        AND FM.METHOD_CODE (+) = MCH.FROM_METHOD_CODE
        AND NVL(FM.LIFE_IN_MONTHS (+),
          - 1) = NVL(MCH.FROM_LIFE_IN_MONTHS
         ,-1)
        AND TM.METHOD_CODE (+) = MCH.TO_METHOD_CODE
        AND NVL(TM.LIFE_IN_MONTHS (+),
          - 1) = NVL(MCH.TO_LIFE_IN_MONTHS
         ,-1)
        AND BC.BOOK_TYPE_CODE = MCH.BOOK_TYPE_CODE
        AND BC.DATE_INEFFECTIVE IS NULL;
      C_BOOK_CLASS := BOOK_CLASS;
      C_OLD_RULE := FROM_RULE;
      C_NEW_RULE := TO_RULE;
      C_FROM_ASSET := FROM_ASSET;
      C_TO_ASSET := TO_ASSET;
      C_FROM_DPIS := FROM_DPIS;
      C_TO_DPIS := TO_DPIS;
      RETURN (BOOK);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN (' ');
    END;
    RETURN NULL;
  END C_BOOKFORMULA;
  FUNCTION C_DO_UPDATEFORMULA(C_COUNT IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      UPDATE
        FA_MASS_CHANGES
      SET
        STATUS = 'PREVIEWED'
      --WHERE MASS_CHANGE_ID = P_MASS_CHANGE_ID
      WHERE MASS_CHANGE_ID = P_MASS_CHANGE_ID1
        AND STATUS = 'PREVIEW';
      COMMIT;
      RETURN (C_COUNT);
    END;
    RETURN NULL;
  END C_DO_UPDATEFORMULA;
  FUNCTION D_OLD_LIFEFORMULA(OLD_LIFE IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      IF (OLD_LIFE IS NOT NULL) THEN
        RETURN (FADOLIF(OLD_LIFE
                      ,NULL
                      ,NULL
                      ,NULL));
      ELSE
        RETURN (' ');
      END IF;
    END;
    RETURN NULL;
  END D_OLD_LIFEFORMULA;
  FUNCTION D_NEW_LIFEFORMULA(NEW_LIFE IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      IF (NEW_LIFE IS NOT NULL) THEN
        RETURN (FADOLIF(NEW_LIFE
                      ,NULL
                      ,NULL
                      ,NULL));
      ELSE
        RETURN (' ');
      END IF;
    END;
    RETURN NULL;
  END D_NEW_LIFEFORMULA;
  FUNCTION CHANGE_LEGALFORMULA(NEW_UOM IN VARCHAR2
                              ,ADDED_THIS_PERIOD IN NUMBER
                              ,ASSET_ID IN NUMBER
                              ,C_BOOK IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      MESSAGE_NAME VARCHAR(30);
    BEGIN
      NEW_UOM_REAL := NEW_UOM;
      MESSAGE_NAME := NULL;
      IF (C_OLD_RULE <> C_NEW_RULE) THEN
        IF (C_OLD_RULE = 'PRODUCTION') THEN
          IF (ADDED_THIS_PERIOD = 0) THEN
            MESSAGE_NAME := 'FA_MASSCHG_ASSET_DEPRED';
          ELSE
            DECLARE
              TEMP VARCHAR2(30);
            BEGIN
              SELECT
                'PRODUCTION IN TAX'
              INTO
                TEMP
              FROM
                FA_BOOK_CONTROLS BC,
                FA_BOOKS BK,
                FA_METHODS ME
              WHERE BK.BOOK_TYPE_CODE = BC.BOOK_TYPE_CODE
                AND BK.ASSET_ID = ASSET_ID
                AND BK.DATE_INEFFECTIVE IS NULL
                AND BC.DISTRIBUTION_SOURCE_BOOK = C_BOOK
                AND BC.DATE_INEFFECTIVE IS NULL
                AND BC.BOOK_CLASS = 'TAX'
                AND ME.METHOD_CODE = BK.DEPRN_METHOD_CODE
                AND NVL(ME.LIFE_IN_MONTHS
                 ,-1) = NVL(BK.LIFE_IN_MONTHS
                 ,-1)
                AND ME.RATE_SOURCE_RULE = 'PRODUCTION';
              MESSAGE_NAME := 'FA_MASSCHG_PROD_IN_TAX';
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                NULL;
            END;
          END IF;
        ELSIF (C_NEW_RULE = 'PRODUCTION') THEN
          IF (ADDED_THIS_PERIOD = 0) THEN
            MESSAGE_NAME := 'FA_MASSCHG_ASSET_DEPRED';
          ELSIF (C_BOOK_CLASS = 'TAX') THEN
            DECLARE
              NEW_UOM VARCHAR(25);
            BEGIN
              SELECT
                UNIT_OF_MEASURE
              INTO
                NEW_UOM
              FROM
                FA_BOOK_CONTROLS BC,
                FA_BOOKS BK
              WHERE BK.BOOK_TYPE_CODE = BC.DISTRIBUTION_SOURCE_BOOK
                AND BK.ASSET_ID = ASSET_ID
                AND BK.DATE_INEFFECTIVE IS NULL
                AND BC.BOOK_TYPE_CODE = C_BOOK
                AND BC.DATE_INEFFECTIVE IS NULL;
              NEW_UOM_REAL := NEW_UOM;
            EXCEPTION
              WHEN OTHERS THEN
                NULL;
            END;
            DECLARE
              TEMP VARCHAR2(30);
            BEGIN
              SELECT
                'PRODUCTION IN CORP'
              INTO
                TEMP
              FROM
                FA_BOOK_CONTROLS BC,
                FA_BOOKS BK,
                FA_METHODS ME
              WHERE BK.BOOK_TYPE_CODE = BC.DISTRIBUTION_SOURCE_BOOK
                AND BK.ASSET_ID = ASSET_ID
                AND BK.DATE_INEFFECTIVE IS NULL
                AND BC.BOOK_TYPE_CODE = C_BOOK
                AND BC.DATE_INEFFECTIVE IS NULL
                AND ME.METHOD_CODE = BK.DEPRN_METHOD_CODE
                AND NVL(ME.LIFE_IN_MONTHS
                 ,-1) = NVL(BK.LIFE_IN_MONTHS
                 ,-1)
                AND ME.RATE_SOURCE_RULE = 'PRODUCTION';
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                MESSAGE_NAME := 'FA_MASSCHG_NOT_PROD_IN_CORP';
            END;
          END IF;
        END IF;
      END IF;
      RETURN (MESSAGE_NAME);
    END;
    RETURN NULL;
  END CHANGE_LEGALFORMULA;
  FUNCTION MESSAGE_DISPFORMULA(CHANGE_LEGAL IN VARCHAR2
                              ,MESSAGE_DISP IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      IF (CHANGE_LEGAL IS NOT NULL) THEN
        FND_MESSAGE.SET_NAME('140'
                            ,':CHANGE_LEGAL');
      END IF;
      RETURN (MESSAGE_DISP);
    END;
    RETURN NULL;
  END MESSAGE_DISPFORMULA;
  FUNCTION NEW_UOM_REAL_P RETURN VARCHAR2 IS
  BEGIN
    RETURN NEW_UOM_REAL;
  END NEW_UOM_REAL_P;
  FUNCTION RP_COMPANY_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_COMPANY_NAME;
  END RP_COMPANY_NAME_P;
  FUNCTION RP_REPORT_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_REPORT_NAME;
  END RP_REPORT_NAME_P;
  FUNCTION C_OLD_RULE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_OLD_RULE;
  END C_OLD_RULE_P;
  FUNCTION C_NEW_RULE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NEW_RULE;
  END C_NEW_RULE_P;
  FUNCTION C_FROM_ASSET_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_FROM_ASSET;
  END C_FROM_ASSET_P;
  FUNCTION C_TO_ASSET_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_TO_ASSET;
  END C_TO_ASSET_P;
  FUNCTION C_FROM_DPIS_P RETURN DATE IS
  BEGIN
    RETURN C_FROM_DPIS;
  END C_FROM_DPIS_P;
  FUNCTION C_TO_DPIS_P RETURN DATE IS
  BEGIN
    RETURN C_TO_DPIS;
  END C_TO_DPIS_P;
  FUNCTION C_BOOK_CLASS_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BOOK_CLASS;
  END C_BOOK_CLASS_P;
--added
FUNCTION fadolif(life NUMBER,
		adj_rate NUMBER,
		bonus_rate NUMBER,
		prod NUMBER)
RETURN CHAR IS
   retval CHAR(7);
   num_chars NUMBER;
   temp_retval number;
BEGIN
   IF life IS NOT NULL
   THEN
      -- Fix for bug 601202 -- added substrb after lpad.  changed '90' to '999'
      temp_retval := fnd_number.canonical_to_number((LPAD(SUBSTR(TO_CHAR(TRUNC(life/12, 0), '999'), 2, 3),3,' ') || '.' ||
		SUBSTR(TO_CHAR(MOD(life, 12), '00'), 2, 2)) );
      retval := to_char(temp_retval,'999D99');
   ELSIF adj_rate IS NOT NULL
   THEN
      /* Bug 1744591
         Changed 90D99 to 990D99 */
           retval := SUBSTR(TO_CHAR(ROUND((adj_rate + NVL(bonus_rate, 0))*100, 2), '990.99'),2,6) || '%';
   ELSIF prod IS NOT NULL
   THEN
	--test for length of production_capacity; if it's longer
	--than 7 characters, then display in exponential notation
      --IF prod <= 9999999
      --THEN
      --   retval := TO_CHAR(prod);
      --ELSE
      --   retval := SUBSTR(LTRIM(TO_CHAR(prod, '9.9EEEE')), 1, 7);
      --END IF;
	--display nothing for UOP assets
	retval := '';
   ELSE
	--should not occur
      retval := ' ';
   END IF;
   return(retval);
END;
END FA_FAS860_XMLP_PKG;


/