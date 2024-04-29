--------------------------------------------------------
--  DDL for Package Body ONT_OEXOEPCL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_OEXOEPCL_XMLP_PKG" AS
/* $Header: OEXOEPCLB.pls 120.1 2007/12/25 07:24:21 npannamp noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      BEGIN
        P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
        /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
      EXCEPTION
        WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
          /*SRW.MESSAGE(1000
                     ,'Failed in BEFORE REPORT trigger')*/NULL;
          RETURN (FALSE);
      END;
      DECLARE
        L_COMPANY_NAME VARCHAR2(100);
        L_FUNCTIONAL_CURRENCY VARCHAR2(15);
      BEGIN
        SELECT
          SOB.NAME,
          SOB.CURRENCY_CODE
        INTO L_COMPANY_NAME,L_FUNCTIONAL_CURRENCY
        FROM
          GL_SETS_OF_BOOKS SOB,
          FND_CURRENCIES CUR
        WHERE SOB.SET_OF_BOOKS_ID = P_SOB_ID
          AND SOB.CURRENCY_CODE = CUR.CURRENCY_CODE;
        RP_COMPANY_NAME := L_COMPANY_NAME;
        RP_FUNCTIONAL_CURRENCY := L_FUNCTIONAL_CURRENCY;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;
      DECLARE
        L_REPORT_NAME VARCHAR2(240);
      BEGIN
        SELECT
          CP.USER_CONCURRENT_PROGRAM_NAME
        INTO L_REPORT_NAME
        FROM
          FND_CONCURRENT_PROGRAMS_VL CP,
          FND_CONCURRENT_REQUESTS CR
        WHERE CR.REQUEST_ID = P_CONC_REQUEST_ID
          AND CP.APPLICATION_ID = CR.PROGRAM_APPLICATION_ID
          AND CP.CONCURRENT_PROGRAM_ID = CR.CONCURRENT_PROGRAM_ID;
        RP_REPORT_NAME := SUBSTR(L_REPORT_NAME,1,INSTR(L_REPORT_NAME,' (XML)'));
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RP_REPORT_NAME := 'Processing Constraints Listing';
      END;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Failed in AFTER REPORT TRIGGER')*/NULL;
        RETURN (FALSE);
    END;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    /*SRW.MESSAGE(99999
               ,'$Header: ONT_OEXOEPCL_XMLP_PKG.rdf 120.1 2005/10/21 08:44 ddey noship
	       $')*/NULL;
    DECLARE
      ENTITY VARCHAR2(80);
      ATTRIBUTE VARCHAR2(80);
      OPERATION VARCHAR2(80);
      VAL_ENTITY VARCHAR2(80);
      RECORD_SET VARCHAR2(80);
      VAL_TEMPLATE VARCHAR2(80);
      SEEDED VARCHAR2(80);
    BEGIN
     BEGIN
      IF P_ENTITY IS NOT NULL THEN
        LP_ENTITY := ' and c.entity_id = :p_entity ';
        SELECT
          NVL(E.ENTITY_DISPLAY_NAME
             ,' ')
        INTO ENTITY
        FROM
          OE_PC_ENTITIES_V E
        WHERE E.ENTITY_ID = P_ENTITY;
        RP_ENTITY := ENTITY;
      ELSE
        LP_ENTITY := ' '; --praveen
      END IF;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN  --praveen
          NULL;
    END;
    BEGIN
      IF P_ATTRIBUTE IS NOT NULL THEN
        LP_ATTRIBUTE := ' and c.column_name = :p_attribute ';
        SELECT
          NVL(A.ATTRIBUTE_DISPLAY_NAME
             ,' ')
        INTO ATTRIBUTE
        FROM
          OE_PC_ATTRIBUTES_V A
        WHERE A.COLUMN_NAME = P_ATTRIBUTE
          AND ENTITY_ID = P_ENTITY;
        RP_ATTRIBUTE := ATTRIBUTE;
      ELSE
        LP_ATTRIBUTE := ' '; --praveen
      END IF;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN  --praveen
          NULL;
    END;
    BEGIN
      IF P_OPERATION IS NOT NULL THEN
        LP_OPERATION := ' and c.constrained_operation = :p_operation ';
        SELECT
          NVL(LU.MEANING
             ,' ')
        INTO OPERATION
        FROM
          OE_LOOKUPS LU
        WHERE LU.LOOKUP_CODE = P_OPERATION
          AND LU.LOOKUP_TYPE = 'PC_OPERATION';
        RP_OPERATION := OPERATION;
       ELSE
	LP_OPERATION := ' '; --praveen
      END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN  --praveen
          NULL;

     END;
     BEGIN
      IF P_VAL_ENTITY IS NOT NULL THEN
        LP_VAL_ENTITY := ' and cc.validation_entity_id = :p_val_entity ';
        SELECT
          DISTINCT
          NVL(V.VALIDATION_ENTITY_DISPLAY_NAME
             ,' ')
        INTO VAL_ENTITY
        FROM
          OE_PC_VENTITIES_V V
        WHERE V.VALIDATION_ENTITY_ID = P_VAL_ENTITY
          AND V.ENTITY_ID = P_ENTITY;
        RP_VAL_ENTITY := VAL_ENTITY;
        ELSE
	LP_VAL_ENTITY := ' ';--praveen
      END IF;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN  --praveen
          NULL;
   END;
    BEGIN
      IF P_RECORD_SET IS NOT NULL THEN
        LP_RECORD_SET := ' and cc.record_set_id = :p_record_set ';
        SELECT
          NVL(RECORD_SET_DISPLAY_NAME
             ,' ')
        INTO RECORD_SET
        FROM
          OE_PC_RSETS_VL
        WHERE RECORD_SET_ID = P_RECORD_SET
          AND ENTITY_ID = P_VAL_ENTITY;
        RP_RECORD_SET := RECORD_SET;
        ELSE
	LP_RECORD_SET := ' ';--praveen
      END IF;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN  --praveen
          NULL;
   END;
   BEGIN
      IF P_VAL_TEMPLATE IS NOT NULL THEN
        LP_VAL_TEMPLATE := ' and cc.validation_tmplt_id = :p_val_template ';
        SELECT
          NVL(VALIDATION_TMPLT_DISPLAY_NAME
             ,' ')
        INTO VAL_TEMPLATE
        FROM
          OE_PC_VTMPLTS_VL
        WHERE VALIDATION_TMPLT_ID = P_VAL_TEMPLATE
          AND ENTITY_ID = P_VAL_ENTITY;
        RP_VAL_TEMPLATE := VAL_TEMPLATE;
        ELSE
	LP_VAL_TEMPLATE :=' '; --praveen
       END IF;
 EXCEPTION
    WHEN NO_DATA_FOUND THEN  --praveen
          NULL;
  END;
  BEGIN
      IF P_SEEDED IS NOT NULL THEN
        LP_SEEDED := ' and cc.system_flag = :p_seeded ';
        SELECT
          NVL(LU.MEANING
             ,' ')
        INTO SEEDED
        FROM
          FND_LOOKUPS LU
        WHERE LU.LOOKUP_CODE = P_SEEDED
          AND LU.LOOKUP_TYPE = 'YES_NO';
        RP_SEEDED := SEEDED;
      ELSE
        LP_SEEDED :=' ';  --praveen
      END IF;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN  --praveen
          NULL;
    END;
    END;
   RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION C_APPL_TOFORMULA(C_COUNT_RESP IN NUMBER
                           ,CONSTRAINT_ID IN NUMBER) RETURN CHAR IS
  BEGIN
    DECLARE
      L_APPL_TO VARCHAR2(20);
      L_FLAG VARCHAR2(1);
    BEGIN
      IF C_COUNT_RESP = 0 THEN
        L_APPL_TO := 'ALL';
      ELSE
        SELECT
          NVL(ASSIGNED_OR_EXCLUDED_FLAG
             ,' ')
        INTO L_FLAG
        FROM
          OE_PC_RESPS_V
        WHERE CONSTRAINT_ID = CONSTRAINT_ID
          AND ROWNUM = 1;
        IF L_FLAG = 'A' THEN
          L_APPL_TO := 'Constrained';
        ELSIF L_FLAG = 'E' THEN
          L_APPL_TO := 'Authorized';
        END IF;
      END IF;
      RETURN (L_APPL_TO);
    END;
  END C_APPL_TOFORMULA;

  FUNCTION RP_REPORT_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_REPORT_NAME;
  END RP_REPORT_NAME_P;

  FUNCTION RP_SUB_TITLE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_SUB_TITLE;
  END RP_SUB_TITLE_P;

  FUNCTION RP_COMPANY_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_COMPANY_NAME;
  END RP_COMPANY_NAME_P;

  FUNCTION RP_FUNCTIONAL_CURRENCY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_FUNCTIONAL_CURRENCY;
  END RP_FUNCTIONAL_CURRENCY_P;

END ONT_OEXOEPCL_XMLP_PKG;


/
