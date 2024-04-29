--------------------------------------------------------
--  DDL for Package Body QA_QLTRSLTR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_QLTRSLTR_XMLP_PKG" AS
/* $Header: QLTRSLTRB.pls 120.0 2007/12/24 10:38:28 krreddy noship $ */
  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    DECLARE
      V_DEFAULT_SELECT VARCHAR2(32767);
      V_DEFAULT_WHERE VARCHAR2(32767);
      V_DEFAULT_PROMPTS VARCHAR2(32767);
      V_DEFAULT_LENGTH VARCHAR2(32767);
      V_SUM VARCHAR2(32767);
      V_TITLE VARCHAR2(50);
      V_DESCRIPTION VARCHAR2(240);
    BEGIN
      IF P_CRITERIA_ID IS NOT NULL THEN
        MAKE_SQL(P_CRITERIA_ID
                ,V_DEFAULT_SELECT
                ,V_DEFAULT_WHERE
                ,V_DEFAULT_PROMPTS
                ,V_DEFAULT_LENGTH
                ,V_SUM
                ,V_TITLE
                ,V_DESCRIPTION);
        P_DEFAULT_SEL := V_DEFAULT_SELECT;
        P_DEFAULT_WHERE := V_DEFAULT_WHERE;
        P_DEFAULT_PROMPTS := V_DEFAULT_PROMPTS;
        P_DEFAULT_LENGTH := V_DEFAULT_LENGTH;
        P_DEFAULT_SUMS := V_SUM;
        P_TITLE := V_TITLE;
        P_DESC := V_DESCRIPTION;
      ELSE
        P_DEFAULT_SEL := P_SELECT_1 || P_SELECT_2 || P_SELECT_3 || P_SELECT_4 || P_SELECT_5 || P_SELECT_6 ||
	P_SELECT_7 || P_SELECT_8 || P_SELECT_9 || P_SELECT_10 || P_SELECT_11 || P_SELECT_12 || P_SELECT_13 ||
	P_SELECT_14 || P_SELECT_15 || P_SELECT_16 || P_SELECT_17 || P_SELECT_18 || P_SELECT_19 || P_SELECT_20 || P_SELECT_21 || P_SELECT_22 || P_SELECT_23 || P_SELECT_24 || P_SELECT_25;
        P_DEFAULT_WHERE := P_WHERE_1 || P_WHERE_2 || P_WHERE_3 || P_WHERE_4 || P_WHERE_5 ||
	P_WHERE_6 || P_WHERE_7 || P_WHERE_8 || P_WHERE_9 || P_WHERE_10 || P_WHERE_11 ||
	P_WHERE_12 || P_WHERE_13 || P_WHERE_14 || P_WHERE_15 || P_WHERE_16 || P_WHERE_17 || P_WHERE_18 || P_WHERE_19 || P_WHERE_20 || P_WHERE_21 || P_WHERE_22 || P_WHERE_23 || P_WHERE_24 || P_WHERE_25;
        P_DEFAULT_PROMPTS := P_PROMPTS_1 || P_PROMPTS_2 || P_PROMPTS_3 || P_PROMPTS_4 || P_PROMPTS_5 || P_PROMPTS_6;
        P_DEFAULT_LENGTH := P_LENGTH_1 || P_LENGTH_2 || P_LENGTH_3 || P_LENGTH_4 || P_LENGTH_5 || P_LENGTH_6;
        P_DEFAULT_SUMS := P_SUMS_1 || P_SUMS_2 || P_SUMS_3 || P_SUMS_4 || P_SUMS_5 || P_SUMS_6;
        P_DEFAULT_SEL := REPLACE(P_DEFAULT_SEL
                                ,'@@'
                                ,' ');
        P_DEFAULT_WHERE := REPLACE(P_DEFAULT_WHERE
                                  ,'@@'
                                  ,' ');
        P_DEFAULT_PROMPTS := REPLACE(P_DEFAULT_PROMPTS
                                    ,'@@'
                                    ,' ');
        P_DEFAULT_LENGTH := REPLACE(P_DEFAULT_LENGTH
                                   ,'@@'
                                   ,' ');
        P_DEFAULT_SUMS := REPLACE(P_DEFAULT_SUMS
                                 ,'@@'
                                 ,' ');
      END IF;
    END;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    EXECUTE IMMEDIATE
      P_DEFAULT_PROMPTS
      INTO P_1, P_2, P_3, P_4, P_5, P_6, P_7, P_8, P_9, P_10, P_11, P_12, P_13, P_14, P_15, P_16, P_17, P_18, P_19, P_20, P_21, P_22, P_23, P_24, P_25, P_26, P_27, P_28, P_29, P_30;
    EXECUTE IMMEDIATE
      P_DEFAULT_LENGTH
      INTO P_Len_1, P_Len_2, P_Len_3, P_Len_4, P_Len_5, P_Len_6, P_Len_7, P_Len_8, P_Len_9, P_Len_10, P_Len_11, P_Len_12, P_Len_13, P_Len_14, P_Len_15, P_Len_16, P_Len_17, P_Len_18, P_Len_19,
P_Len_20, P_Len_21, P_Len_22, P_Len_23, P_Len_24, P_Len_25, P_Len_26, P_Len_27, P_Len_28, P_Len_29, P_Len_30;
    EXECUTE IMMEDIATE
      P_DEFAULT_SUMS
      INTO P_Sum_1, P_Sum_2, P_Sum_3, P_Sum_4, P_Sum_5, P_Sum_6, P_Sum_7, P_Sum_8, P_Sum_9, P_Sum_10, P_Sum_11, P_Sum_12, P_Sum_13, P_Sum_14, P_Sum_15, P_Sum_16, P_Sum_17, P_Sum_18, P_Sum_19,
P_Sum_20, P_Sum_21, P_Sum_22, P_Sum_23, P_Sum_24, P_Sum_25, P_Sum_26, P_Sum_27, P_Sum_28, P_Sum_29, P_Sum_30;
    /*SRW.MESSAGE(001
               ,'before report trigger')*/NULL;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION C_DASH_1FORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (RPAD('-'
               ,P_LEN_1
               ,'-'));
  END C_DASH_1FORMULA;

  FUNCTION C_DASH_2FORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (RPAD('-'
               ,P_LEN_2
               ,'-'));
  END C_DASH_2FORMULA;

  FUNCTION C_DASH_3FORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (RPAD('-'
               ,P_LEN_3
               ,'-'));
  END C_DASH_3FORMULA;

  FUNCTION C_DASH_4FORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (RPAD('-'
               ,P_LEN_4
               ,'-'));
  END C_DASH_4FORMULA;

  FUNCTION C_DASH_5FORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (RPAD('-'
               ,P_LEN_5
               ,'-'));
  END C_DASH_5FORMULA;

  FUNCTION C_DASH_6FORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (RPAD('-'
               ,P_LEN_6
               ,'-'));
  END C_DASH_6FORMULA;

  FUNCTION C_DASH_7FORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (RPAD('-'
               ,P_LEN_7
               ,'-'));
  END C_DASH_7FORMULA;

  FUNCTION C_DASH_8FORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (RPAD('-'
               ,P_LEN_8
               ,'-'));
  END C_DASH_8FORMULA;

  FUNCTION C_DASH_9FORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (RPAD('-'
               ,P_LEN_9
               ,'-'));
  END C_DASH_9FORMULA;

  FUNCTION C_DASH_10FORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (RPAD('-'
               ,P_LEN_10
               ,'-'));
  END C_DASH_10FORMULA;

  FUNCTION C_DASH_11FORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (RPAD('-'
               ,P_LEN_11
               ,'-'));
  END C_DASH_11FORMULA;

  FUNCTION C_DASH_12FORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (RPAD('-'
               ,P_LEN_12
               ,'-'));
  END C_DASH_12FORMULA;

  FUNCTION C_DASH_13FORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (RPAD('-'
               ,P_LEN_13
               ,'-'));
  END C_DASH_13FORMULA;

  FUNCTION C_DASH_14FORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (RPAD('-'
               ,P_LEN_14
               ,'-'));
  END C_DASH_14FORMULA;

  FUNCTION C_DASH_15FORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (RPAD('-'
               ,P_LEN_15
               ,'-'));
  END C_DASH_15FORMULA;

  FUNCTION C_DASH_16FORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (RPAD('-'
               ,P_LEN_16
               ,'-'));
  END C_DASH_16FORMULA;

  FUNCTION C_DASH_17FORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (RPAD('-'
               ,P_LEN_17
               ,'-'));
  END C_DASH_17FORMULA;

  FUNCTION C_DASH_18FORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (RPAD('-'
               ,P_LEN_18
               ,'-'));
  END C_DASH_18FORMULA;

  FUNCTION C_DASH_19FORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (RPAD('-'
               ,P_LEN_19
               ,'-'));
  END C_DASH_19FORMULA;

  FUNCTION C_DASH_20FORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (RPAD('-'
               ,P_LEN_20
               ,'-'));
  END C_DASH_20FORMULA;

  FUNCTION C_DASH_21FORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (RPAD('-'
               ,P_LEN_21
               ,'-'));
  END C_DASH_21FORMULA;

  FUNCTION C_DASH_22FORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (RPAD('-'
               ,P_LEN_22
               ,'-'));
  END C_DASH_22FORMULA;

  FUNCTION C_DASH_23FORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (RPAD('-'
               ,P_LEN_23
               ,'-'));
  END C_DASH_23FORMULA;

  FUNCTION C_DASH_24FORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (RPAD('-'
               ,P_LEN_24
               ,'-'));
  END C_DASH_24FORMULA;

  FUNCTION C_DASH_25FORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (RPAD('-'
               ,P_LEN_25
               ,'-'));
  END C_DASH_25FORMULA;

  FUNCTION C_DASH_26FORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (RPAD('-'
               ,P_LEN_26
               ,'-'));
  END C_DASH_26FORMULA;

  FUNCTION C_DASH_27FORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (RPAD('-'
               ,P_LEN_27
               ,'-'));
  END C_DASH_27FORMULA;

  FUNCTION C_DASH_28FORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (RPAD('-'
               ,P_LEN_28
               ,'-'));
  END C_DASH_28FORMULA;

  FUNCTION C_DASH_29FORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (RPAD('-'
               ,P_LEN_29
               ,'-'));
  END C_DASH_29FORMULA;

  FUNCTION C_DASH_30FORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (RPAD('-'
               ,P_LEN_30
               ,'-'));
  END C_DASH_30FORMULA;

  FUNCTION C_MAY_DASH_1FORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_1 IS NOT NULL THEN
      RETURN (RPAD('-'
                 ,P_LEN_1
                 ,'-'));
    ELSE
      RETURN (RPAD(' '
                 ,P_LEN_1
                 ,' '));
    END IF;
    RETURN NULL;
  END C_MAY_DASH_1FORMULA;

  FUNCTION C_MAY_DASH_2FORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_2 IS NOT NULL THEN
      RETURN (RPAD('-'
                 ,P_LEN_2
                 ,'-'));
    ELSE
      RETURN (RPAD(' '
                 ,P_LEN_2
                 ,' '));
    END IF;
    RETURN NULL;
  END C_MAY_DASH_2FORMULA;

  FUNCTION C_MAY_DASH_3FORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_3 IS NOT NULL THEN
      RETURN (RPAD('-'
                 ,P_LEN_3
                 ,'-'));
    ELSE
      RETURN (RPAD(' '
                 ,P_LEN_3
                 ,' '));
    END IF;
    RETURN NULL;
  END C_MAY_DASH_3FORMULA;

  FUNCTION C_MAY_DASH_4FORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_4 IS NOT NULL THEN
      RETURN (RPAD('-'
                 ,P_LEN_4
                 ,'-'));
    ELSE
      RETURN (RPAD(' '
                 ,P_LEN_4
                 ,' '));
    END IF;
    RETURN NULL;
  END C_MAY_DASH_4FORMULA;

  FUNCTION C_MAY_DASH_5FORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_5 IS NOT NULL THEN
      RETURN (RPAD('-'
                 ,P_LEN_5
                 ,'-'));
    ELSE
      RETURN (RPAD(' '
                 ,P_LEN_5
                 ,' '));
    END IF;
    RETURN NULL;
  END C_MAY_DASH_5FORMULA;

  FUNCTION C_MAY_DASH_6FORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_6 IS NOT NULL THEN
      RETURN (RPAD('-'
                 ,P_LEN_6
                 ,'-'));
    ELSE
      RETURN (RPAD(' '
                 ,P_LEN_6
                 ,' '));
    END IF;
    RETURN NULL;
  END C_MAY_DASH_6FORMULA;

  FUNCTION C_MAY_DASH_7FORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_7 IS NOT NULL THEN
      RETURN (RPAD('-'
                 ,P_LEN_7
                 ,'-'));
    ELSE
      RETURN (RPAD(' '
                 ,P_LEN_7
                 ,' '));
    END IF;
    RETURN NULL;
  END C_MAY_DASH_7FORMULA;

  FUNCTION C_MAY_DASH_8FORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_8 IS NOT NULL THEN
      RETURN (RPAD('-'
                 ,P_LEN_8
                 ,'-'));
    ELSE
      RETURN (RPAD(' '
                 ,P_LEN_8
                 ,' '));
    END IF;
    RETURN NULL;
  END C_MAY_DASH_8FORMULA;

  FUNCTION C_MAY_DASH_9FORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_9 IS NOT NULL THEN
      RETURN (RPAD('-'
                 ,P_LEN_9
                 ,'-'));
    ELSE
      RETURN (RPAD(' '
                 ,P_LEN_9
                 ,' '));
    END IF;
    RETURN NULL;
  END C_MAY_DASH_9FORMULA;

  FUNCTION C_MAY_DASH_10FORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_10 IS NOT NULL THEN
      RETURN (RPAD('-'
                 ,P_LEN_10
                 ,'-'));
    ELSE
      RETURN (RPAD(' '
                 ,P_LEN_10
                 ,' '));
    END IF;
    RETURN NULL;
  END C_MAY_DASH_10FORMULA;

  FUNCTION C_MAY_DASH_11FORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_11 IS NOT NULL THEN
      RETURN (RPAD('-'
                 ,P_LEN_11
                 ,'-'));
    ELSE
      RETURN (RPAD(' '
                 ,P_LEN_11
                 ,' '));
    END IF;
    RETURN NULL;
  END C_MAY_DASH_11FORMULA;

  FUNCTION C_MAY_DASH_12FORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_12 IS NOT NULL THEN
      RETURN (RPAD('-'
                 ,P_LEN_12
                 ,'-'));
    ELSE
      RETURN (RPAD(' '
                 ,P_LEN_12
                 ,' '));
    END IF;
    RETURN NULL;
  END C_MAY_DASH_12FORMULA;

  FUNCTION C_MAY_DASH_13FORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_13 IS NOT NULL THEN
      RETURN (RPAD('-'
                 ,P_LEN_13
                 ,'-'));
    ELSE
      RETURN (RPAD(' '
                 ,P_LEN_13
                 ,' '));
    END IF;
    RETURN NULL;
  END C_MAY_DASH_13FORMULA;

  FUNCTION C_MAY_DASH_14FORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_14 IS NOT NULL THEN
      RETURN (RPAD('-'
                 ,P_LEN_14
                 ,'-'));
    ELSE
      RETURN (RPAD(' '
                 ,P_LEN_14
                 ,' '));
    END IF;
    RETURN NULL;
  END C_MAY_DASH_14FORMULA;

  FUNCTION C_MAY_DASH_15FORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_15 IS NOT NULL THEN
      RETURN (RPAD('-'
                 ,P_LEN_15
                 ,'-'));
    ELSE
      RETURN (RPAD(' '
                 ,P_LEN_15
                 ,' '));
    END IF;
    RETURN NULL;
  END C_MAY_DASH_15FORMULA;

  FUNCTION C_MAY_DASH_16FORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_16 IS NOT NULL THEN
      RETURN (RPAD('-'
                 ,P_LEN_16
                 ,'-'));
    ELSE
      RETURN (RPAD(' '
                 ,P_LEN_16
                 ,' '));
    END IF;
    RETURN NULL;
  END C_MAY_DASH_16FORMULA;

  FUNCTION C_MAY_DASH_17FORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_17 IS NOT NULL THEN
      RETURN (RPAD('-'
                 ,P_LEN_17
                 ,'-'));
    ELSE
      RETURN (RPAD(' '
                 ,P_LEN_17
                 ,' '));
    END IF;
    RETURN NULL;
  END C_MAY_DASH_17FORMULA;

  FUNCTION C_MAY_DASH_18FORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_18 IS NOT NULL THEN
      RETURN (RPAD('-'
                 ,P_LEN_18
                 ,'-'));
    ELSE
      RETURN (RPAD(' '
                 ,P_LEN_18
                 ,' '));
    END IF;
    RETURN NULL;
  END C_MAY_DASH_18FORMULA;

  FUNCTION C_MAY_DASH_19FORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_19 IS NOT NULL THEN
      RETURN (RPAD('-'
                 ,P_LEN_19
                 ,'-'));
    ELSE
      RETURN (RPAD(' '
                 ,P_LEN_19
                 ,' '));
    END IF;
    RETURN NULL;
  END C_MAY_DASH_19FORMULA;

  FUNCTION C_MAY_DASH_20FORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_20 IS NOT NULL THEN
      RETURN (RPAD('-'
                 ,P_LEN_20
                 ,'-'));
    ELSE
      RETURN (RPAD(' '
                 ,P_LEN_20
                 ,' '));
    END IF;
    RETURN NULL;
  END C_MAY_DASH_20FORMULA;

  FUNCTION C_MAY_DASH_21FORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_21 IS NOT NULL THEN
      RETURN (RPAD('-'
                 ,P_LEN_21
                 ,'-'));
    ELSE
      RETURN (RPAD(' '
                 ,P_LEN_21
                 ,' '));
    END IF;
    RETURN NULL;
  END C_MAY_DASH_21FORMULA;

  FUNCTION C_MAY_DASH_22FORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_22 IS NOT NULL THEN
      RETURN (RPAD('-'
                 ,P_LEN_22
                 ,'-'));
    ELSE
      RETURN (RPAD(' '
                 ,P_LEN_22
                 ,' '));
    END IF;
    RETURN NULL;
  END C_MAY_DASH_22FORMULA;

  FUNCTION C_MAY_DASH_23FORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_23 IS NOT NULL THEN
      RETURN (RPAD('-'
                 ,P_LEN_23
                 ,'-'));
    ELSE
      RETURN (RPAD(' '
                 ,P_LEN_23
                 ,' '));
    END IF;
    RETURN NULL;
  END C_MAY_DASH_23FORMULA;

  FUNCTION C_MAY_DASH_24FORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_24 IS NOT NULL THEN
      RETURN (RPAD('-'
                 ,P_LEN_24
                 ,'-'));
    ELSE
      RETURN (RPAD(' '
                 ,P_LEN_24
                 ,' '));
    END IF;
    RETURN NULL;
  END C_MAY_DASH_24FORMULA;

  FUNCTION C_MAY_DASH_25FORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_25 IS NOT NULL THEN
      RETURN (RPAD('-'
                 ,P_LEN_25
                 ,'-'));
    ELSE
      RETURN (RPAD(' '
                 ,P_LEN_25
                 ,' '));
    END IF;
    RETURN NULL;
  END C_MAY_DASH_25FORMULA;

  FUNCTION C_MAY_DASH_26FORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_26 IS NOT NULL THEN
      RETURN (RPAD('-'
                 ,P_LEN_26
                 ,'-'));
    ELSE
      RETURN (RPAD(' '
                 ,P_LEN_26
                 ,' '));
    END IF;
    RETURN NULL;
  END C_MAY_DASH_26FORMULA;

  FUNCTION C_MAY_DASH_27FORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_27 IS NOT NULL THEN
      RETURN (RPAD('-'
                 ,P_LEN_27
                 ,'-'));
    ELSE
      RETURN (RPAD(' '
                 ,P_LEN_27
                 ,' '));
    END IF;
    RETURN NULL;
  END C_MAY_DASH_27FORMULA;

  FUNCTION C_MAY_DASH_28FORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_28 IS NOT NULL THEN
      RETURN (RPAD('-'
                 ,P_LEN_28
                 ,'-'));
    ELSE
      RETURN (RPAD(' '
                 ,P_LEN_28
                 ,' '));
    END IF;
    RETURN NULL;
  END C_MAY_DASH_28FORMULA;

  FUNCTION C_MAY_DASH_29FORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_29 IS NOT NULL THEN
      RETURN (RPAD('-'
                 ,P_LEN_29
                 ,'-'));
    ELSE
      RETURN (RPAD(' '
                 ,P_LEN_29
                 ,' '));
    END IF;
    RETURN NULL;
  END C_MAY_DASH_29FORMULA;

  FUNCTION C_MAY_DASH_30FORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_30 IS NOT NULL THEN
      RETURN (RPAD('-'
                 ,P_LEN_30
                 ,'-'));
    ELSE
      RETURN (RPAD(' '
                 ,P_LEN_30
                 ,' '));
    END IF;
    RETURN NULL;
  END C_MAY_DASH_30FORMULA;

  FUNCTION C_FINAL_SUM_1FORMULA(SUM_1 IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_1 IS NULL THEN
      RETURN (RPAD(' '
                 ,P_LEN_1
                 ,' '));
    ELSE
      IF NVL(LENGTH(TO_CHAR(SUM_1))
         ,0) > P_LEN_1 THEN
        RETURN (RPAD('*'
                   ,P_LEN_1
                   ,'*'));
      ELSE
        RETURN (LPAD(TO_CHAR(SUM_1)
                   ,P_LEN_1
                   ,' '));
      END IF;
    END IF;
    RETURN NULL;
  END C_FINAL_SUM_1FORMULA;

  FUNCTION C_FINAL_SUM_2FORMULA(SUM_2 IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_2 IS NULL THEN
      RETURN (RPAD(' '
                 ,P_LEN_2
                 ,' '));
    ELSE
      IF NVL(LENGTH(TO_CHAR(SUM_2))
         ,0) > P_LEN_2 THEN
        RETURN (RPAD('*'
                   ,P_LEN_2
                   ,'*'));
      ELSE
        RETURN (LPAD(TO_CHAR(SUM_2)
                   ,P_LEN_2
                   ,' '));
      END IF;
    END IF;
    RETURN NULL;
  END C_FINAL_SUM_2FORMULA;

  FUNCTION C_FINAL_SUM_3FORMULA(SUM_3 IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_3 IS NULL THEN
      RETURN (RPAD(' '
                 ,P_LEN_3
                 ,' '));
    ELSE
      IF NVL(LENGTH(TO_CHAR(SUM_3))
         ,0) > P_LEN_3 THEN
        RETURN (RPAD('*'
                   ,P_LEN_3
                   ,'*'));
      ELSE
        RETURN (LPAD(TO_CHAR(SUM_3)
                   ,P_LEN_3
                   ,' '));
      END IF;
    END IF;
    RETURN NULL;
  END C_FINAL_SUM_3FORMULA;

  FUNCTION C_FINAL_SUM_4FORMULA(SUM_4 IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_4 IS NULL THEN
      RETURN (RPAD(' '
                 ,P_LEN_4
                 ,' '));
    ELSE
      IF NVL(LENGTH(TO_CHAR(SUM_4))
         ,0) > P_LEN_4 THEN
        RETURN (RPAD('*'
                   ,P_LEN_4
                   ,'*'));
      ELSE
        RETURN (LPAD(TO_CHAR(SUM_4)
                   ,P_LEN_4
                   ,' '));
      END IF;
    END IF;
    RETURN NULL;
  END C_FINAL_SUM_4FORMULA;

  FUNCTION C_FINAL_SUM_5FORMULA(SUM_5 IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_5 IS NULL THEN
      RETURN (RPAD(' '
                 ,P_LEN_5
                 ,' '));
    ELSE
      IF NVL(LENGTH(TO_CHAR(SUM_5))
         ,0) > P_LEN_5 THEN
        RETURN (RPAD('*'
                   ,P_LEN_5
                   ,'*'));
      ELSE
        RETURN (LPAD(TO_CHAR(SUM_5)
                   ,P_LEN_5
                   ,' '));
      END IF;
    END IF;
    RETURN NULL;
  END C_FINAL_SUM_5FORMULA;

  FUNCTION C_FINAL_SUM_6FORMULA(SUM_6 IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_6 IS NULL THEN
      RETURN (RPAD(' '
                 ,P_LEN_6
                 ,' '));
    ELSE
      IF NVL(LENGTH(TO_CHAR(SUM_6))
         ,0) > P_LEN_6 THEN
        RETURN (RPAD('*'
                   ,P_LEN_6
                   ,'*'));
      ELSE
        RETURN (LPAD(TO_CHAR(SUM_6)
                   ,P_LEN_6
                   ,' '));
      END IF;
    END IF;
    RETURN NULL;
  END C_FINAL_SUM_6FORMULA;

  FUNCTION C_FINAL_SUM_7FORMULA(SUM_7 IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_7 IS NULL THEN
      RETURN (RPAD(' '
                 ,P_LEN_7
                 ,' '));
    ELSE
      IF NVL(LENGTH(TO_CHAR(SUM_7))
         ,0) > P_LEN_7 THEN
        RETURN (RPAD('*'
                   ,P_LEN_7
                   ,'*'));
      ELSE
        RETURN (LPAD(TO_CHAR(SUM_7)
                   ,P_LEN_7
                   ,' '));
      END IF;
    END IF;
    RETURN NULL;
  END C_FINAL_SUM_7FORMULA;

  FUNCTION C_FINAL_SUM_8FORMULA(SUM_8 IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_8 IS NULL THEN
      RETURN (RPAD(' '
                 ,P_LEN_8
                 ,' '));
    ELSE
      IF NVL(LENGTH(TO_CHAR(SUM_8))
         ,0) > P_LEN_8 THEN
        RETURN (RPAD('*'
                   ,P_LEN_8
                   ,'*'));
      ELSE
        RETURN (LPAD(TO_CHAR(SUM_8)
                   ,P_LEN_8
                   ,' '));
      END IF;
    END IF;
    RETURN NULL;
  END C_FINAL_SUM_8FORMULA;

  FUNCTION C_FINAL_SUM_9FORMULA(SUM_9 IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_9 IS NULL THEN
      RETURN (RPAD(' '
                 ,P_LEN_9
                 ,' '));
    ELSE
      IF NVL(LENGTH(TO_CHAR(SUM_9))
         ,0) > P_LEN_9 THEN
        RETURN (RPAD('*'
                   ,P_LEN_9
                   ,'*'));
      ELSE
        RETURN (LPAD(TO_CHAR(SUM_9)
                   ,P_LEN_9
                   ,' '));
      END IF;
    END IF;
    RETURN NULL;
  END C_FINAL_SUM_9FORMULA;

  FUNCTION C_FINAL_SUM_10FORMULA(SUM_10 IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_10 IS NULL THEN
      RETURN (RPAD(' '
                 ,P_LEN_10
                 ,' '));
    ELSE
      IF NVL(LENGTH(TO_CHAR(SUM_10))
         ,0) > P_LEN_10 THEN
        RETURN (RPAD('*'
                   ,P_LEN_10
                   ,'*'));
      ELSE
        RETURN (LPAD(TO_CHAR(SUM_10)
                   ,P_LEN_10
                   ,' '));
      END IF;
    END IF;
    RETURN NULL;
  END C_FINAL_SUM_10FORMULA;

  FUNCTION C_FINAL_SUM_11FORMULA(SUM_11 IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_11 IS NULL THEN
      RETURN (RPAD(' '
                 ,P_LEN_11
                 ,' '));
    ELSE
      IF NVL(LENGTH(TO_CHAR(SUM_11))
         ,0) > P_LEN_11 THEN
        RETURN (RPAD('*'
                   ,P_LEN_11
                   ,'*'));
      ELSE
        RETURN (LPAD(TO_CHAR(SUM_11)
                   ,P_LEN_11
                   ,' '));
      END IF;
    END IF;
    RETURN NULL;
  END C_FINAL_SUM_11FORMULA;

  FUNCTION C_FINAL_SUM_12FORMULA(SUM_12 IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_12 IS NULL THEN
      RETURN (RPAD(' '
                 ,P_LEN_12
                 ,' '));
    ELSE
      IF NVL(LENGTH(TO_CHAR(SUM_12))
         ,0) > P_LEN_12 THEN
        RETURN (RPAD('*'
                   ,P_LEN_12
                   ,'*'));
      ELSE
        RETURN (LPAD(TO_CHAR(SUM_12)
                   ,P_LEN_12
                   ,' '));
      END IF;
    END IF;
    RETURN NULL;
  END C_FINAL_SUM_12FORMULA;

  FUNCTION C_FINAL_SUM_13FORMULA(SUM_13 IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_13 IS NULL THEN
      RETURN (RPAD(' '
                 ,P_LEN_13
                 ,' '));
    ELSE
      IF NVL(LENGTH(TO_CHAR(SUM_13))
         ,0) > P_LEN_13 THEN
        RETURN (RPAD('*'
                   ,P_LEN_13
                   ,'*'));
      ELSE
        RETURN (LPAD(TO_CHAR(SUM_13)
                   ,P_LEN_13
                   ,' '));
      END IF;
    END IF;
    RETURN NULL;
  END C_FINAL_SUM_13FORMULA;

  FUNCTION C_FINAL_SUM_14FORMULA(SUM_14 IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_14 IS NULL THEN
      RETURN (RPAD(' '
                 ,P_LEN_14
                 ,' '));
    ELSE
      IF NVL(LENGTH(TO_CHAR(SUM_14))
         ,0) > P_LEN_14 THEN
        RETURN (RPAD('*'
                   ,P_LEN_14
                   ,'*'));
      ELSE
        RETURN (LPAD(TO_CHAR(SUM_14)
                   ,P_LEN_14
                   ,' '));
      END IF;
    END IF;
    RETURN NULL;
  END C_FINAL_SUM_14FORMULA;

  FUNCTION C_FINAL_SUM_15FORMULA(SUM_15 IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_15 IS NULL THEN
      RETURN (RPAD(' '
                 ,P_LEN_15
                 ,' '));
    ELSE
      IF NVL(LENGTH(TO_CHAR(SUM_15))
         ,0) > P_LEN_15 THEN
        RETURN (RPAD('*'
                   ,P_LEN_15
                   ,'*'));
      ELSE
        RETURN (LPAD(TO_CHAR(SUM_15)
                   ,P_LEN_15
                   ,' '));
      END IF;
    END IF;
    RETURN NULL;
  END C_FINAL_SUM_15FORMULA;

  FUNCTION C_FINAL_SUM_16FORMULA(SUM_16 IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_16 IS NULL THEN
      RETURN (RPAD(' '
                 ,P_LEN_16
                 ,' '));
    ELSE
      IF NVL(LENGTH(TO_CHAR(SUM_16))
         ,0) > P_LEN_16 THEN
        RETURN (RPAD('*'
                   ,P_LEN_16
                   ,'*'));
      ELSE
        RETURN (LPAD(TO_CHAR(SUM_16)
                   ,P_LEN_16
                   ,' '));
      END IF;
    END IF;
    RETURN NULL;
  END C_FINAL_SUM_16FORMULA;

  FUNCTION C_FINAL_SUM_17FORMULA(SUM_17 IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_17 IS NULL THEN
      RETURN (RPAD(' '
                 ,P_LEN_17
                 ,' '));
    ELSE
      IF NVL(LENGTH(TO_CHAR(SUM_17))
         ,0) > P_LEN_17 THEN
        RETURN (RPAD('*'
                   ,P_LEN_17
                   ,'*'));
      ELSE
        RETURN (LPAD(TO_CHAR(SUM_17)
                   ,P_LEN_17
                   ,' '));
      END IF;
    END IF;
    RETURN NULL;
  END C_FINAL_SUM_17FORMULA;

  FUNCTION C_FINAL_SUM_18FORMULA(SUM_18 IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_18 IS NULL THEN
      RETURN (RPAD(' '
                 ,P_LEN_18
                 ,' '));
    ELSE
      IF NVL(LENGTH(TO_CHAR(SUM_18))
         ,0) > P_LEN_18 THEN
        RETURN (RPAD('*'
                   ,P_LEN_18
                   ,'*'));
      ELSE
        RETURN (LPAD(TO_CHAR(SUM_18)
                   ,P_LEN_18
                   ,' '));
      END IF;
    END IF;
    RETURN NULL;
  END C_FINAL_SUM_18FORMULA;

  FUNCTION C_FINAL_SUM_19FORMULA(SUM_19 IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_19 IS NULL THEN
      RETURN (RPAD(' '
                 ,P_LEN_19
                 ,' '));
    ELSE
      IF NVL(LENGTH(TO_CHAR(SUM_19))
         ,0) > P_LEN_19 THEN
        RETURN (RPAD('*'
                   ,P_LEN_19
                   ,'*'));
      ELSE
        RETURN (LPAD(TO_CHAR(SUM_19)
                   ,P_LEN_19
                   ,' '));
      END IF;
    END IF;
    RETURN NULL;
  END C_FINAL_SUM_19FORMULA;

  FUNCTION C_FINAL_SUM_20FORMULA(SUM_20 IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_20 IS NULL THEN
      RETURN (RPAD(' '
                 ,P_LEN_20
                 ,' '));
    ELSE
      IF NVL(LENGTH(TO_CHAR(SUM_20))
         ,0) > P_LEN_20 THEN
        RETURN (RPAD('*'
                   ,P_LEN_20
                   ,'*'));
      ELSE
        RETURN (LPAD(TO_CHAR(SUM_20)
                   ,P_LEN_20
                   ,' '));
      END IF;
    END IF;
    RETURN NULL;
  END C_FINAL_SUM_20FORMULA;

  FUNCTION C_FINAL_SUM_21FORMULA(SUM_21 IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_21 IS NULL THEN
      RETURN (RPAD(' '
                 ,P_LEN_21
                 ,' '));
    ELSE
      IF NVL(LENGTH(TO_CHAR(SUM_21))
         ,0) > P_LEN_21 THEN
        RETURN (RPAD('*'
                   ,P_LEN_21
                   ,'*'));
      ELSE
        RETURN (LPAD(TO_CHAR(SUM_21)
                   ,P_LEN_21
                   ,' '));
      END IF;
    END IF;
    RETURN NULL;
  END C_FINAL_SUM_21FORMULA;

  FUNCTION C_FINAL_SUM_22FORMULA(SUM_22 IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_22 IS NULL THEN
      RETURN (RPAD(' '
                 ,P_LEN_22
                 ,' '));
    ELSE
      IF NVL(LENGTH(TO_CHAR(SUM_22))
         ,0) > P_LEN_22 THEN
        RETURN (RPAD('*'
                   ,P_LEN_22
                   ,'*'));
      ELSE
        RETURN (LPAD(TO_CHAR(SUM_22)
                   ,P_LEN_22
                   ,' '));
      END IF;
    END IF;
    RETURN NULL;
  END C_FINAL_SUM_22FORMULA;

  FUNCTION C_FINAL_SUM_23FORMULA(SUM_23 IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_23 IS NULL THEN
      RETURN (RPAD(' '
                 ,P_LEN_23
                 ,' '));
    ELSE
      IF NVL(LENGTH(TO_CHAR(SUM_23))
         ,0) > P_LEN_23 THEN
        RETURN (RPAD('*'
                   ,P_LEN_23
                   ,'*'));
      ELSE
        RETURN (LPAD(TO_CHAR(SUM_23)
                   ,P_LEN_23
                   ,' '));
      END IF;
    END IF;
    RETURN NULL;
  END C_FINAL_SUM_23FORMULA;

  FUNCTION C_FINAL_SUM_24FORMULA(SUM_24 IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_24 IS NULL THEN
      RETURN (RPAD(' '
                 ,P_LEN_24
                 ,' '));
    ELSE
      IF NVL(LENGTH(TO_CHAR(SUM_24))
         ,0) > P_LEN_24 THEN
        RETURN (RPAD('*'
                   ,P_LEN_24
                   ,'*'));
      ELSE
        RETURN (LPAD(TO_CHAR(SUM_24)
                   ,P_LEN_24
                   ,' '));
      END IF;
    END IF;
    RETURN NULL;
  END C_FINAL_SUM_24FORMULA;

  FUNCTION C_FINAL_SUM_25FORMULA(SUM_25 IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_25 IS NULL THEN
      RETURN (RPAD(' '
                 ,P_LEN_25
                 ,' '));
    ELSE
      IF NVL(LENGTH(TO_CHAR(SUM_25))
         ,0) > P_LEN_25 THEN
        RETURN (RPAD('*'
                   ,P_LEN_25
                   ,'*'));
      ELSE
        RETURN (LPAD(TO_CHAR(SUM_25)
                   ,P_LEN_25
                   ,' '));
      END IF;
    END IF;
    RETURN NULL;
  END C_FINAL_SUM_25FORMULA;

  FUNCTION C_FINAL_SUM_26FORMULA(SUM_26 IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_26 IS NULL THEN
      RETURN (RPAD(' '
                 ,P_LEN_26
                 ,' '));
    ELSE
      IF NVL(LENGTH(TO_CHAR(SUM_26))
         ,0) > P_LEN_26 THEN
        RETURN (RPAD('*'
                   ,P_LEN_26
                   ,'*'));
      ELSE
        RETURN (LPAD(TO_CHAR(SUM_26)
                   ,P_LEN_26
                   ,' '));
      END IF;
    END IF;
    RETURN NULL;
  END C_FINAL_SUM_26FORMULA;

  FUNCTION C_FINAL_SUM_27FORMULA(SUM_27 IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_27 IS NULL THEN
      RETURN (RPAD(' '
                 ,P_LEN_27
                 ,' '));
    ELSE
      IF NVL(LENGTH(TO_CHAR(SUM_27))
         ,0) > P_LEN_27 THEN
        RETURN (RPAD('*'
                   ,P_LEN_27
                   ,'*'));
      ELSE
        RETURN (LPAD(TO_CHAR(SUM_27)
                   ,P_LEN_27
                   ,' '));
      END IF;
    END IF;
    RETURN NULL;
  END C_FINAL_SUM_27FORMULA;

  FUNCTION C_FINAL_SUM_28FORMULA(SUM_28 IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_28 IS NULL THEN
      RETURN (RPAD(' '
                 ,P_LEN_28
                 ,' '));
    ELSE
      IF NVL(LENGTH(TO_CHAR(SUM_28))
         ,0) > P_LEN_28 THEN
        RETURN (RPAD('*'
                   ,P_LEN_28
                   ,'*'));
      ELSE
        RETURN (LPAD(TO_CHAR(SUM_28)
                   ,P_LEN_28
                   ,' '));
      END IF;
    END IF;
    RETURN NULL;
  END C_FINAL_SUM_28FORMULA;

  FUNCTION C_FINAL_SUM_29FORMULA(SUM_29 IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_29 IS NULL THEN
      RETURN (RPAD(' '
                 ,P_LEN_29
                 ,' '));
    ELSE
      IF NVL(LENGTH(TO_CHAR(SUM_29))
         ,0) > P_LEN_29 THEN
        RETURN (RPAD('*'
                   ,P_LEN_29
                   ,'*'));
      ELSE
        RETURN (LPAD(TO_CHAR(SUM_29)
                   ,P_LEN_29
                   ,' '));
      END IF;
    END IF;
    RETURN NULL;
  END C_FINAL_SUM_29FORMULA;

  FUNCTION C_FINAL_SUM_30FORMULA(SUM_30 IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF P_SUM_30 IS NULL THEN
      RETURN (RPAD(' '
                 ,P_LEN_30
                 ,' '));
    ELSE
      IF NVL(LENGTH(TO_CHAR(SUM_30))
         ,0) > P_LEN_30 THEN
        RETURN (RPAD('*'
                   ,P_LEN_30
                   ,'*'));
      ELSE
        RETURN (LPAD(TO_CHAR(SUM_30)
                   ,P_LEN_30
                   ,' '));
      END IF;
    END IF;
    RETURN NULL;
  END C_FINAL_SUM_30FORMULA;

  FUNCTION C_AST_2FORMULA(NUM_2 IN NUMBER
                         ,COL_2 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF NVL(LENGTH(TO_CHAR(NUM_2))
       ,0) > P_LEN_2 THEN
      RETURN (RPAD('*'
                 ,P_LEN_2
                 ,'*'));
    ELSE
      RETURN (COL_2);
    END IF;
    RETURN NULL;
  END C_AST_2FORMULA;

  FUNCTION C_AST_3FORMULA(NUM_3 IN NUMBER
                         ,COL_3 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF NVL(LENGTH(TO_CHAR(NUM_3))
       ,0) > P_LEN_3 THEN
      RETURN (RPAD('*'
                 ,P_LEN_3
                 ,'*'));
    ELSE
      RETURN (COL_3);
    END IF;
    RETURN NULL;
  END C_AST_3FORMULA;

  FUNCTION C_AST_1FORMULA(NUM_1 IN NUMBER
                         ,COL_1 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF NVL(LENGTH(TO_CHAR(NUM_1))
       ,0) > P_LEN_1 THEN
      RETURN (RPAD('*'
                 ,P_LEN_1
                 ,'*'));
    ELSE
      RETURN (COL_1);
    END IF;
    RETURN NULL;
  END C_AST_1FORMULA;

  FUNCTION C_AST_4FORMULA(NUM_4 IN NUMBER
                         ,COL_4 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF NVL(LENGTH(TO_CHAR(NUM_4))
       ,0) > P_LEN_4 THEN
      RETURN (RPAD('*'
                 ,P_LEN_4
                 ,'*'));
    ELSE
      RETURN (COL_4);
    END IF;
    RETURN NULL;
  END C_AST_4FORMULA;

  FUNCTION C_AST_5FORMULA(NUM_5 IN NUMBER
                         ,COL_5 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF NVL(LENGTH(TO_CHAR(NUM_5))
       ,0) > P_LEN_5 THEN
      RETURN (RPAD('*'
                 ,P_LEN_5
                 ,'*'));
    ELSE
      RETURN (COL_5);
    END IF;
    RETURN NULL;
  END C_AST_5FORMULA;

  FUNCTION C_AST_6FORMULA(NUM_6 IN NUMBER
                         ,COL_6 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF NVL(LENGTH(TO_CHAR(NUM_6))
       ,0) > P_LEN_6 THEN
      RETURN (RPAD('*'
                 ,P_LEN_6
                 ,'*'));
    ELSE
      RETURN (COL_6);
    END IF;
    RETURN NULL;
  END C_AST_6FORMULA;

  FUNCTION C_AST_7FORMULA(NUM_7 IN NUMBER
                         ,COL_7 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF NVL(LENGTH(TO_CHAR(NUM_7))
       ,0) > P_LEN_7 THEN
      RETURN (RPAD('*'
                 ,P_LEN_7
                 ,'*'));
    ELSE
      RETURN (COL_7);
    END IF;
    RETURN NULL;
  END C_AST_7FORMULA;

  FUNCTION C_AST_8FORMULA(NUM_8 IN NUMBER
                         ,COL_8 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF NVL(LENGTH(TO_CHAR(NUM_8))
       ,0) > P_LEN_8 THEN
      RETURN (RPAD('*'
                 ,P_LEN_8
                 ,'*'));
    ELSE
      RETURN (COL_8);
    END IF;
    RETURN NULL;
  END C_AST_8FORMULA;

  FUNCTION C_AST_9FORMULA(NUM_9 IN NUMBER
                         ,COL_9 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF NVL(LENGTH(TO_CHAR(NUM_9))
       ,0) > P_LEN_9 THEN
      RETURN (RPAD('*'
                 ,P_LEN_9
                 ,'*'));
    ELSE
      RETURN (COL_9);
    END IF;
    RETURN NULL;
  END C_AST_9FORMULA;

  FUNCTION C_AST_10FORMULA(NUM_10 IN NUMBER
                          ,COL_10 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF NVL(LENGTH(TO_CHAR(NUM_10))
       ,0) > P_LEN_10 THEN
      RETURN (RPAD('*'
                 ,P_LEN_10
                 ,'*'));
    ELSE
      RETURN (COL_10);
    END IF;
    RETURN NULL;
  END C_AST_10FORMULA;

  FUNCTION C_AST_15FORMULA(NUM_15 IN NUMBER
                          ,COL_15 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF NVL(LENGTH(TO_CHAR(NUM_15))
       ,0) > P_LEN_15 THEN
      RETURN (RPAD('*'
                 ,P_LEN_15
                 ,'*'));
    ELSE
      RETURN (COL_15);
    END IF;
    RETURN NULL;
  END C_AST_15FORMULA;

  FUNCTION C_AST_14FORMULA(NUM_14 IN NUMBER
                          ,COL_14 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF NVL(LENGTH(TO_CHAR(NUM_14))
       ,0) > P_LEN_14 THEN
      RETURN (RPAD('*'
                 ,P_LEN_14
                 ,'*'));
    ELSE
      RETURN (COL_14);
    END IF;
    RETURN NULL;
  END C_AST_14FORMULA;

  FUNCTION C_AST_13FORMULA(NUM_13 IN NUMBER
                          ,COL_13 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF NVL(LENGTH(TO_CHAR(NUM_13))
       ,0) > P_LEN_13 THEN
      RETURN (RPAD('*'
                 ,P_LEN_13
                 ,'*'));
    ELSE
      RETURN (COL_13);
    END IF;
    RETURN NULL;
  END C_AST_13FORMULA;

  FUNCTION C_AST_12FORMULA(NUM_12 IN NUMBER
                          ,COL_12 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF NVL(LENGTH(TO_CHAR(NUM_12))
       ,0) > P_LEN_12 THEN
      RETURN (RPAD('*'
                 ,P_LEN_12
                 ,'*'));
    ELSE
      RETURN (COL_12);
    END IF;
    RETURN NULL;
  END C_AST_12FORMULA;

  FUNCTION C_AST_11FORMULA(NUM_11 IN NUMBER
                          ,COL_11 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF NVL(LENGTH(TO_CHAR(NUM_11))
       ,0) > P_LEN_11 THEN
      RETURN (RPAD('*'
                 ,P_LEN_11
                 ,'*'));
    ELSE
      RETURN (COL_11);
    END IF;
    RETURN NULL;
  END C_AST_11FORMULA;

  FUNCTION C_AST_18FORMULA(NUM_18 IN NUMBER
                          ,COL_18 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF NVL(LENGTH(TO_CHAR(NUM_18))
       ,0) > P_LEN_18 THEN
      RETURN (RPAD('*'
                 ,P_LEN_18
                 ,'*'));
    ELSE
      RETURN (COL_18);
    END IF;
    RETURN NULL;
  END C_AST_18FORMULA;

  FUNCTION C_AST_17FORMULA(NUM_17 IN NUMBER
                          ,COL_17 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF NVL(LENGTH(TO_CHAR(NUM_17))
       ,0) > P_LEN_17 THEN
      RETURN (RPAD('*'
                 ,P_LEN_17
                 ,'*'));
    ELSE
      RETURN (COL_17);
    END IF;
    RETURN NULL;
  END C_AST_17FORMULA;

  FUNCTION C_AST_16FORMULA(NUM_16 IN NUMBER
                          ,COL_16 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF NVL(LENGTH(TO_CHAR(NUM_16))
       ,0) > P_LEN_16 THEN
      RETURN (RPAD('*'
                 ,P_LEN_16
                 ,'*'));
    ELSE
      RETURN (COL_16);
    END IF;
    RETURN NULL;
  END C_AST_16FORMULA;

  FUNCTION C_AST_19FORMULA(NUM_19 IN NUMBER
                          ,COL_19 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF NVL(LENGTH(TO_CHAR(NUM_19))
       ,0) > P_LEN_19 THEN
      RETURN (RPAD('*'
                 ,P_LEN_19
                 ,'*'));
    ELSE
      RETURN (COL_19);
    END IF;
    RETURN NULL;
  END C_AST_19FORMULA;

  FUNCTION C_AST_20FORMULA(NUM_20 IN NUMBER
                          ,COL_20 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF NVL(LENGTH(TO_CHAR(NUM_20))
       ,0) > P_LEN_20 THEN
      RETURN (RPAD('*'
                 ,P_LEN_20
                 ,'*'));
    ELSE
      RETURN (COL_20);
    END IF;
    RETURN NULL;
  END C_AST_20FORMULA;

  FUNCTION C_AST_25FORMULA(NUM_25 IN NUMBER
                          ,COL_25 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF NVL(LENGTH(TO_CHAR(NUM_25))
       ,0) > P_LEN_25 THEN
      RETURN (RPAD('*'
                 ,P_LEN_25
                 ,'*'));
    ELSE
      RETURN (COL_25);
    END IF;
    RETURN NULL;
  END C_AST_25FORMULA;

  FUNCTION C_AST_24FORMULA(NUM_24 IN NUMBER
                          ,COL_24 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF NVL(LENGTH(TO_CHAR(NUM_24))
       ,0) > P_LEN_24 THEN
      RETURN (RPAD('*'
                 ,P_LEN_24
                 ,'*'));
    ELSE
      RETURN (COL_24);
    END IF;
    RETURN NULL;
  END C_AST_24FORMULA;

  FUNCTION C_AST_23FORMULA(NUM_23 IN NUMBER
                          ,COL_23 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF NVL(LENGTH(TO_CHAR(NUM_23))
       ,0) > P_LEN_23 THEN
      RETURN (RPAD('*'
                 ,P_LEN_23
                 ,'*'));
    ELSE
      RETURN (COL_23);
    END IF;
    RETURN NULL;
  END C_AST_23FORMULA;

  FUNCTION C_AST_22FORMULA(NUM_22 IN NUMBER
                          ,COL_22 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF NVL(LENGTH(TO_CHAR(NUM_22))
       ,0) > P_LEN_22 THEN
      RETURN (RPAD('*'
                 ,P_LEN_22
                 ,'*'));
    ELSE
      RETURN (COL_22);
    END IF;
    RETURN NULL;
  END C_AST_22FORMULA;

  FUNCTION C_AST_21FORMULA(NUM_21 IN NUMBER
                          ,COL_21 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF NVL(LENGTH(TO_CHAR(NUM_21))
       ,0) > P_LEN_21 THEN
      RETURN (RPAD('*'
                 ,P_LEN_21
                 ,'*'));
    ELSE
      RETURN (COL_21);
    END IF;
    RETURN NULL;
  END C_AST_21FORMULA;

  FUNCTION C_AST_30FORMULA(NUM_30 IN NUMBER
                          ,COL_30 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF NVL(LENGTH(TO_CHAR(NUM_30))
       ,0) > P_LEN_30 THEN
      RETURN (RPAD('*'
                 ,P_LEN_30
                 ,'*'));
    ELSE
      RETURN (COL_30);
    END IF;
    RETURN NULL;
  END C_AST_30FORMULA;

  FUNCTION C_AST_29FORMULA(NUM_29 IN NUMBER
                          ,COL_29 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF NVL(LENGTH(TO_CHAR(NUM_29))
       ,0) > P_LEN_29 THEN
      RETURN (RPAD('*'
                 ,P_LEN_29
                 ,'*'));
    ELSE
      RETURN (COL_29);
    END IF;
    RETURN NULL;
  END C_AST_29FORMULA;

  FUNCTION C_AST_28FORMULA(NUM_28 IN NUMBER
                          ,COL_28 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF NVL(LENGTH(TO_CHAR(NUM_28))
       ,0) > P_LEN_28 THEN
      RETURN (RPAD('*'
                 ,P_LEN_28
                 ,'*'));
    ELSE
      RETURN (COL_28);
    END IF;
    RETURN NULL;
  END C_AST_28FORMULA;

  FUNCTION C_AST_27FORMULA(NUM_27 IN NUMBER
                          ,COL_27 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF NVL(LENGTH(TO_CHAR(NUM_27))
       ,0) > P_LEN_27 THEN
      RETURN (RPAD('*'
                 ,P_LEN_27
                 ,'*'));
    ELSE
      RETURN (COL_27);
    END IF;
    RETURN NULL;
  END C_AST_27FORMULA;

  FUNCTION C_AST_26FORMULA(NUM_26 IN NUMBER
                          ,COL_26 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF NVL(LENGTH(TO_CHAR(NUM_26))
       ,0) > P_LEN_26 THEN
      RETURN (RPAD('*'
                 ,P_LEN_26
                 ,'*'));
    ELSE
      RETURN (COL_26);
    END IF;
    RETURN NULL;
  END C_AST_26FORMULA;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  PROCEDURE MAKE_SQL(X_CRITERIA_ID IN NUMBER
                    ,X_SELECT OUT NOCOPY VARCHAR2
                    ,X_WHERE OUT NOCOPY VARCHAR2
                    ,X_PROMPTS OUT NOCOPY VARCHAR2
                    ,X_LENGTH OUT NOCOPY VARCHAR2
                    ,X_SUM OUT NOCOPY VARCHAR2
                    ,X_TITLE OUT NOCOPY VARCHAR2
                    ,X_DESCRIPTION OUT NOCOPY VARCHAR2) IS
    CURSOR PCURSOR IS
      SELECT
        PLAN_ID,
        TITLE,
        DESCRIPTION
      FROM
        QA_CRITERIA_HEADERS
      WHERE CRITERIA_ID = X_CRITERIA_ID;
    V_PLAN_ID NUMBER;
    V_TITLE VARCHAR2(50);
    V_DESCRIPTION VARCHAR2(240);
    V_RET_VAL VARCHAR2(10);
    V_CUSTID NUMBER;
  BEGIN
    OPEN PCURSOR;
    FETCH PCURSOR
     INTO V_PLAN_ID,V_TITLE,V_DESCRIPTION;
    CLOSE PCURSOR;
    V_CRITERIA_ID := X_CRITERIA_ID;
    QLTSTORB.MAKE_REC_GROUP;
    LOOP_THROUGH_RECORDS;
    LAUNCH_PRODUCT(V_PLAN_ID);
    IF (P_SECURITY_PROFILE = 1) THEN
      SELECT
        NVL(PERSON_PARTY_ID
           ,-1)
      INTO V_CUSTID
      FROM
        FND_USER
      WHERE USER_ID = P_USER_ID;
      IF (V_CUSTID <> -1) THEN
        V_RET_VAL := FND_DATA_SECURITY.CHECK_FUNCTION(P_API_VERSION => 1.0
                                                     ,P_FUNCTION => 'QA_RESULTS_VIEW'
                                                     ,P_OBJECT_NAME => 'QA_PLANS'
                                                     ,P_INSTANCE_PK1_VALUE => TO_CHAR(V_PLAN_ID)
                                                     ,P_INSTANCE_PK2_VALUE => NULL
                                                     ,P_INSTANCE_PK3_VALUE => NULL
                                                     ,P_INSTANCE_PK4_VALUE => NULL
                                                     ,P_INSTANCE_PK5_VALUE => NULL);
      ELSE
        V_RET_VAL := 'F';
      END IF;
      IF (V_RET_VAL <> 'T') THEN
        V_WHERE := V_WHERE || ' AND 1 = 2';
      END IF;
    END IF;
    X_SELECT := V_SELECT;
    X_WHERE := V_WHERE;
    X_PROMPTS := V_PROMPTS;
    X_LENGTH := V_LENGTH;
    X_SUM := V_SUM;
    X_TITLE := V_TITLE;
    X_DESCRIPTION := V_DESCRIPTION;
  END MAKE_SQL;

  PROCEDURE LAUNCH_PRODUCT(X_PLAN_ID IN NUMBER) IS
    ROW_COUNT NUMBER;
    V_NAME VARCHAR2(1000);
    Y_NAME VARCHAR2(100);
    V_SELECT VARCHAR2(5000) := NULL;
    V_FROM VARCHAR2(5000);
    V_WHERE VARCHAR2(5000);
    V_GROUP_BY VARCHAR2(5000);
    V_ORDER_BY VARCHAR2(5000);
    V_LENGTHS  VARCHAR2(5000) := NULL;
    V_LENGTHS_1 VARCHAR2(5000) := NULL;
    V_SUMS VARCHAR2(5000) := NULL;
    V_SUMS_1 VARCHAR2(5000) := NULL;
    V_PROMPTS VARCHAR2(5000) := NULL;
    V_PROMPTS_1 VARCHAR2(5000) := NULL;
    V_COUNTER NUMBER := 1;
    V_PROMPT VARCHAR2(100);
    V_LENGTH NUMBER;
    V_SUM NUMBER;
    V_FXN_PROMPT VARCHAR2(10);
    V_GROUP_FLAG BOOLEAN := FALSE;
    TOTAL_ROWS_IN_REPORT NUMBER := 30;
  BEGIN
    ROW_COUNT := QLTSTORB.ROWS_IN_REC_GROUP;
    QLTSTORB.MAKE_FROM_REC_GRP;
    QLTSTORB.MAKE_WHERE_REC_GRP;
    QLTSTORB.ADD_ROW_TO_FROM_REC_GROUP('QA_RESULTS QR');
    QLTSTORB.ADD_ROW_TO_WHERE_REC_GROUP('qr.plan_id = ''' || TO_CHAR(X_PLAN_ID) || '''');
    FOR i IN 1 .. ROW_COUNT LOOP
      IF QLTSTORB.GET_NUMBER('sel'
                         ,I) = 1 THEN
        Y_NAME := FKEY_RESOLVER(I);
        V_NAME := ADD_FXN_RPT(I
                             ,Y_NAME);
        V_SELECT := V_SELECT || ', ' || V_NAME || ' col_' || TO_CHAR(V_COUNTER);
        IF QLTSTORB.GET_NUMBER('datatype'
                           ,I) = 2 THEN
          IF QLTSTORB.GET_CHAR('hardcoded_column'
                           ,I) IS NULL THEN
            Y_NAME := 'to_number(' || Y_NAME || ')';
          END IF;
          Y_NAME := ADD_FXN(I
                           ,Y_NAME);
          IF QLTSTORB.GET_NUMBER('function'
                             ,I) = 3 THEN
            Y_NAME := 'ROUND(' || Y_NAME || ', ' || TO_CHAR(QLTSTORB.GET_NUMBER('precision'
                                                 ,I) + 5) || ')';
          END IF;
          V_SELECT := V_SELECT || ', ' || Y_NAME || ' num_' || TO_CHAR(V_COUNTER);
          V_SELECT := V_SELECT || ', '|| 'QA_QLTRSLTR_XMLP_PKG.C_AST_'||TO_CHAR(V_COUNTER)||'FORMULA(' ||Y_NAME||','||V_NAME||')'||' C_AST_'||TO_CHAR(V_COUNTER) ;
 ELSE
          V_SELECT := V_SELECT || ', 999 num_' || TO_CHAR(V_COUNTER);
	  V_SELECT := V_SELECT || ', '|| 'QA_QLTRSLTR_XMLP_PKG.C_AST_'||TO_CHAR(V_COUNTER)||'FORMULA(' ||999 ||','||V_NAME||')'||' C_AST_'||TO_CHAR(V_COUNTER) ;

        END IF;
        V_COUNTER := V_COUNTER + 1;
        V_PROMPT := QLTSTORB.GET_CHAR('prompt'
                                     ,I);
        V_FXN_PROMPT := QLTSTORB.GET_CHAR('fxn_prompt'
                                         ,I);
        IF V_FXN_PROMPT IS NOT NULL THEN
          V_PROMPT := V_PROMPT || '(' || V_FXN_PROMPT || ')';
          V_GROUP_FLAG := TRUE;
        ELSE
          V_GROUP_BY := V_GROUP_BY || ', ' || V_NAME;
          IF QLTSTORB.GET_NUMBER('datatype'
                             ,I) = 2 THEN
            V_GROUP_BY := V_GROUP_BY || ', ' || Y_NAME;
          END IF;
        END IF;
        V_PROMPT := REPLACE(V_PROMPT
                           ,''''
                           ,'''''''''');
        V_PROMPT := '''' || V_PROMPT || '''';
        IF QLTSTORB.GET_NUMBER('datatype'
                           ,I) = 2 THEN
          V_PROMPT := 'lpad(' || V_PROMPT || ', ' || TO_CHAR(QLTSTORB.GET_NUMBER('disp_length'
                                                 ,I)) || ')';
        ELSE
          V_PROMPT := 'rpad(' || V_PROMPT || ', ' || TO_CHAR(QLTSTORB.GET_NUMBER('disp_length'
                                                 ,I)) || ')';
        END IF;
        V_PROMPTS := V_PROMPTS || ', ' || V_PROMPT;
        V_LENGTH := QLTSTORB.GET_NUMBER('disp_length'
                                       ,I);
        V_LENGTHS := V_LENGTHS || ', ' || TO_CHAR(V_LENGTH);
        V_SUM := QLTSTORB.GET_NUMBER('total',I);

        IF V_SUM = 2 OR V_SUM IS NULL THEN
          V_SUMS := V_SUMS || ', null';
        ELSE
          V_SUMS := V_SUMS || ', ' || TO_CHAR(V_SUM);
        END IF;
      ELSE
        CREATE_WHERE(I);
      END IF;
    END LOOP;
    V_FROM := QLTSTORB.CREATE_FROM_CLAUSE;
    V_WHERE := QLTSTORB.CREATE_WHERE_CLAUSE;
    FOR i IN V_COUNTER .. TOTAL_ROWS_IN_REPORT LOOP
      V_SELECT := V_SELECT || ', null col_' || TO_CHAR(I) || ', 999 num_' || TO_CHAR(I);
      V_PROMPTS := V_PROMPTS || ', null';
      V_LENGTHS := V_LENGTHS || ', null';
      V_SUMS := V_SUMS || ', null';
    END LOOP;
    --V_PROMPTS_1 := V_PROMPTS_1 || ' INTO :P_1';
    --V_LENGTHS_1 := V_LENGTHS_1 || ' INTO :P_Len_1';
    --V_SUMS_1 := V_SUMS_1 || ' INTO :P_Sum_1';
   /* FOR i IN 2 .. TOTAL_ROWS_IN_REPORT LOOP
      V_PROMPTS_1 := V_PROMPTS_1 || ', :P_' || TO_CHAR(I);
      V_LENGTHS_1 := V_LENGTHS_1 || ', :P_Len_' || TO_CHAR(I);
      V_SUMS_1 := V_SUMS_1 || ', :P_Sum_' || TO_CHAR(I);
    END LOOP;*/
    V_SELECT := 'SELECT ' || SUBSTR(V_SELECT,3);
    V_PROMPTS := 'SELECT ' || SUBSTR(V_PROMPTS,3) || ' FROM SYS.DUAL';
    V_LENGTHS := 'SELECT ' || SUBSTR(V_LENGTHS,3)|| ' FROM SYS.DUAL';
    V_SUMS := 'SELECT ' || SUBSTR(V_SUMS,3)|| ' FROM SYS.DUAL';

	IF V_GROUP_FLAG = TRUE AND V_GROUP_BY IS NOT NULL THEN

      V_GROUP_BY := 'GROUP BY ' || SUBSTR(V_GROUP_BY
                          ,3);
    ELSE
      V_GROUP_BY := NULL;
    END IF;
    QLTSTORB.KILL_REC_GROUP;
    QA_QLTRSLTR_XMLP_PKG.V_SELECT := V_SELECT ||' '|| ' ' || V_FROM;
    QA_QLTRSLTR_XMLP_PKG.V_WHERE := V_WHERE || ' ' || V_ORDER_BY || ' ' || V_GROUP_BY;
    QA_QLTRSLTR_XMLP_PKG.V_PROMPTS := V_PROMPTS;
    QA_QLTRSLTR_XMLP_PKG.V_LENGTH := V_LENGTHS;
    QA_QLTRSLTR_XMLP_PKG.V_SUM := V_SUMS;
  END LAUNCH_PRODUCT;

  PROCEDURE CREATE_WHERE(X_ROW IN NUMBER) IS
    V_NAME VARCHAR2(100);
    V_WHERE VARCHAR2(2000);
    V_OPER VARCHAR2(15);
    V_LOW VARCHAR2(80);
    V_HIGH VARCHAR2(80);
    V_DATATYPE NUMBER;
    V_IN_ARG VARCHAR2(150);
    V_PARENT_BLOCK_NAME VARCHAR2(30);
    V_LIST_ID NUMBER;
    DONE BOOLEAN := FALSE;
    CURSOR C IS
      SELECT
        VALUE
      FROM
        QA_IN_LISTS
      WHERE PARENT_BLOCK_NAME = V_PARENT_BLOCK_NAME
        AND LIST_ID = V_LIST_ID;
  BEGIN
    V_DATATYPE := QLTSTORB.GET_NUMBER('datatype'
                                     ,X_ROW);
    V_NAME := FKEY_RESOLVER(X_ROW);
    V_NAME := RESOLVE_TYPE(X_ROW
                          ,V_NAME);
    V_OPER := QLTSTORB.GET_CHAR('op'
                               ,X_ROW);
    V_LOW := QLTSTORB.GET_CHAR('low'
                              ,X_ROW);
    V_HIGH := QLTSTORB.GET_CHAR('high'
                               ,X_ROW);
    IF ((V_OPER = 'IN') OR (V_OPER = 'NOT IN')) THEN
      V_PARENT_BLOCK_NAME := QLTSTORB.GET_CHAR('parent_block_name'
                                              ,X_ROW);
      V_LIST_ID := QLTSTORB.GET_NUMBER('list_id'
                                      ,X_ROW);
      OPEN C;
      WHILE (NOT DONE) LOOP

        FETCH C
         INTO V_IN_ARG;
        IF (C%FOUND) THEN
          V_IN_ARG := '''' || V_IN_ARG || '''';
          IF (V_DATATYPE = 3) THEN
            V_IN_ARG := 'to_date(' || V_IN_ARG || ', ''YYYY/MM/DD'')';
          ELSIF (V_DATATYPE = 6) THEN
            V_IN_ARG := 'to_date(' || V_IN_ARG || ', ''YYYY/MM/DD HH24:MI:SS'')';
          ELSIF V_DATATYPE = 2 THEN
            V_IN_ARG := 'qltdate.any_to_number(' || V_IN_ARG || ')';
          END IF;
          V_WHERE := V_WHERE || ', ' || V_IN_ARG;
        ELSE
          DONE := TRUE;
        END IF;
      END LOOP;
      CLOSE C;
      IF (V_IN_ARG IS NULL) THEN
        V_WHERE := '1 = 2';
      ELSE
        V_WHERE := V_NAME || ' ' || V_OPER || ' (' || SUBSTR(V_WHERE
                         ,3) || ')';
      END IF;
    ELSIF V_OPER = 'OUTSIDE' THEN
      V_LOW := '''' || V_LOW || '''';
      V_HIGH := '''' || V_HIGH || '''';
      IF V_DATATYPE = 3 THEN
        V_LOW := 'to_date(' || V_LOW || ', ''YYYY/MM/DD'')';
        V_HIGH := 'to_date(' || V_HIGH || ', ''YYYY/MM/DD'')';
      ELSIF V_DATATYPE = 6 THEN
        V_LOW := 'to_date(' || V_LOW || ', ''YYYY/MM/DD HH24:MI:SS'')';
        V_HIGH := 'to_date(' || V_HIGH || ', ''YYYY/MM/DD HH24:MI:SS'')';
      ELSIF V_DATATYPE = 2 THEN
        V_LOW := 'qltdate.any_to_number(' || V_LOW || ')';
        V_HIGH := 'qltdate.any_to_number(' || V_HIGH || ')';
      END IF;
      V_WHERE := '(' || V_NAME || ' < ' || V_LOW || ' OR ' || V_NAME || ' > ' || V_HIGH || ')';
    ELSE
      V_WHERE := V_NAME || ' ' || V_OPER;
      IF V_LOW IS NOT NULL THEN
        V_LOW := '''' || V_LOW || '''';
        IF V_DATATYPE = 3 THEN
          V_LOW := 'to_date(' || V_LOW || ', ''YYYY/MM/DD'')';
        ELSIF V_DATATYPE = 6 THEN
          V_LOW := 'to_date(' || V_LOW || ', ''YYYY/MM/DD HH24:MI:SS'')';
        ELSIF V_DATATYPE = 2 THEN
          V_LOW := 'qltdate.any_to_number(' || V_LOW || ')';
        END IF;
        V_WHERE := V_WHERE || ' ' || V_LOW;
        IF V_HIGH IS NOT NULL THEN
          V_HIGH := '''' || V_HIGH || '''';
          IF V_DATATYPE = 3 THEN
            V_HIGH := 'to_date(' || V_HIGH || ', ''YYYY/MM/DD'')';
          ELSIF V_DATATYPE = 6 THEN
            V_HIGH := 'to_date(' || V_HIGH || ', ''YYYY/MM/DD HH24:MI:SS'')';
          ELSIF V_DATATYPE = 2 THEN
            V_HIGH := 'qltdate.any_to_number(' || V_HIGH || ')';
          END IF;
          V_WHERE := V_WHERE || ' AND ' || V_HIGH;
        END IF;
      END IF;
    END IF;
    QLTSTORB.ADD_ROW_TO_WHERE_REC_GROUP(V_WHERE);
  END CREATE_WHERE;

  FUNCTION FKEY_RESOLVER(X_ROW IN NUMBER) RETURN VARCHAR2 IS
    X_NAME VARCHAR2(100);
    X_LOOKUP NUMBER;
    X_WHERE VARCHAR2(2000);
    V_FROM VARCHAR2(100);
    V_TABLE_SH_NAME VARCHAR2(5);
    V_CATEGORY_SET_ID NUMBER;
  BEGIN
    X_LOOKUP := QLTSTORB.GET_NUMBER('fk_lookup_type'
                                   ,X_ROW);
    X_NAME := QLTSTORB.GET_CHAR('hardcoded_column'
                               ,X_ROW);
    IF X_NAME IS NULL THEN
      X_NAME := 'qr.' || QLTSTORB.GET_CHAR('result_column_name'
                                 ,X_ROW);
    ELSE
      X_NAME := 'qr.' || X_NAME;
    END IF;
    IF (X_LOOKUP = 1) OR (X_LOOKUP = 3) OR (X_LOOKUP = 0) THEN
      V_TABLE_SH_NAME := QLTSTORB.GET_CHAR('fk_table_short_name'
                                          ,X_ROW);
      V_FROM := QLTSTORB.GET_CHAR('fk_table_name'
                                 ,X_ROW);
      QLTSTORB.ADD_ROW_TO_FROM_REC_GROUP(V_FROM || ' ' || V_TABLE_SH_NAME);
      V_FROM := QLTSTORB.GET_CHAR('pk_id'
                                 ,X_ROW);
      X_WHERE := X_NAME || ' = ' || V_TABLE_SH_NAME || '.' || V_FROM || ' (+)';
      QLTSTORB.ADD_ROW_TO_WHERE_REC_GROUP(X_WHERE);
      V_FROM := QLTSTORB.GET_CHAR('pk_id2'
                                 ,X_ROW);
      IF V_FROM IS NOT NULL THEN
        V_FROM := V_TABLE_SH_NAME || '.' || V_FROM;
        X_WHERE := 'qr.' || QLTSTORB.GET_CHAR('fk_id2'
                                    ,X_ROW) || ' = ' || V_FROM || ' (+)';
        QLTSTORB.ADD_ROW_TO_WHERE_REC_GROUP(X_WHERE);
        V_FROM := QLTSTORB.GET_CHAR('pk_id3'
                                   ,X_ROW);
        IF V_FROM IS NOT NULL THEN
          V_FROM := V_TABLE_SH_NAME || '.' || V_FROM;
          X_WHERE := 'qr.' || QLTSTORB.GET_CHAR('fk_id3'
                                      ,X_ROW) || ' = ' || V_FROM || ' (+)';
          QLTSTORB.ADD_ROW_TO_WHERE_REC_GROUP(X_WHERE);
        END IF;
      END IF;
      X_WHERE := QLTSTORB.GET_CHAR('fk_add_where'
                                  ,X_ROW);
      IF X_WHERE IS NOT NULL THEN
        QLTSTORB.ADD_ROW_TO_WHERE_REC_GROUP(X_WHERE);
      END IF;
      X_NAME := QLTSTORB.GET_CHAR('fk_meaning'
                                 ,X_ROW);
      X_NAME := V_TABLE_SH_NAME || '.' || X_NAME;
      IF X_NAME = 'SH.ORDER_NUMBER' THEN
        X_NAME := 'NVL(MSO1.SEGMENT1,TO_CHAR(SH.ORDER_NUMBER))';
        QLTSTORB.ADD_ROW_TO_FROM_REC_GROUP('MTL_SALES_ORDERS MSO1');
        QLTSTORB.ADD_ROW_TO_WHERE_REC_GROUP('QR.SO_HEADER_ID=MSO1.SALES_ORDER_ID(+)');
      END IF;
    END IF;
    IF (X_LOOKUP = 3) THEN
      V_CATEGORY_SET_ID := FND_PROFILE.VALUE('QA_CATEGORY_SET');
      IF V_CATEGORY_SET_ID IS NULL THEN
        FND_MESSAGE.SET_NAME('QA'
                            ,'QA_PROFILE_NOT_SET');
        QLTSTORB.KILL_REC_GROUP;
        QLTSTORB.KILL_FROM_REC_GRP;
        QLTSTORB.KILL_WHERE_REC_GRP;
      END IF;
      X_WHERE := 'micsv.CATEGORY_SET_ID = ' || TO_CHAR(V_CATEGORY_SET_ID);
      QLTSTORB.ADD_ROW_TO_WHERE_REC_GROUP(X_WHERE);
    END IF;
    RETURN (X_NAME);
  END FKEY_RESOLVER;

  FUNCTION RESOLVE_TYPE(X_ROW IN NUMBER
                       ,X_NAME IN VARCHAR2) RETURN VARCHAR2 IS
    V_DATATYPE NUMBER;
    V_NAME VARCHAR2(100);
    V_HARDCODED VARCHAR2(100);
  BEGIN
    V_HARDCODED := QLTSTORB.GET_CHAR('hardcoded_column'
                                    ,X_ROW);
    V_DATATYPE := QLTSTORB.GET_NUMBER('datatype'
                                     ,X_ROW);
    IF V_HARDCODED IS NULL THEN
      IF V_DATATYPE = 2 THEN
        V_NAME := 'qltdate.any_to_number(' || X_NAME || ')';
      ELSIF V_DATATYPE = 3 THEN
        V_NAME := 'to_date(' || X_NAME || ', ''YYYY/MM/DD'')';
      ELSIF V_DATATYPE = 6 THEN
        V_NAME := 'to_date(' || X_NAME || ', ''YYYY/MM/DD HH24:MI:SS'')';
      ELSE
        V_NAME := X_NAME;
      END IF;
    ELSE
      IF V_DATATYPE = 3 THEN
        V_NAME := 'trunc(' || X_NAME || ')';
      ELSE
        V_NAME := X_NAME;
      END IF;
    END IF;
    RETURN (V_NAME);
  END RESOLVE_TYPE;

  FUNCTION ADD_FXN(X_ROW IN NUMBER
                  ,X_NAME IN VARCHAR2) RETURN VARCHAR2 IS
    V_FUNCTION NUMBER;
    V_NAME VARCHAR2(100);
  BEGIN
    V_FUNCTION := QLTSTORB.GET_NUMBER('function'
                                     ,X_ROW);
    IF V_FUNCTION = 1 THEN
      V_NAME := 'SUM(' || X_NAME || ')';
    ELSIF V_FUNCTION = 2 THEN
      V_NAME := 'COUNT(' || X_NAME || ')';
    ELSIF V_FUNCTION = 3 THEN
      V_NAME := 'AVG(' || X_NAME || ')';
    ELSIF V_FUNCTION = 5 THEN
      V_NAME := 'MAX(' || X_NAME || ')';
    ELSIF V_FUNCTION = 4 THEN
      V_NAME := 'MIN(' || X_NAME || ')';
    ELSE
      V_NAME := X_NAME;
    END IF;
    RETURN (V_NAME);
  END ADD_FXN;

  FUNCTION ADD_FXN_RPT(X_ROW IN NUMBER
                      ,X_NAME IN VARCHAR2) RETURN VARCHAR2 IS
    V_NAME VARCHAR2(1000);
    V_HARDCODED VARCHAR2(100);
    V_FUNCTION NUMBER;
    V_DATATYPE NUMBER;
    V_DISP_LEN NUMBER;
  BEGIN
    V_HARDCODED := QLTSTORB.GET_CHAR('hardcoded_column'
                                    ,X_ROW);
    V_FUNCTION := QLTSTORB.GET_NUMBER('function'
                                     ,X_ROW);
    V_DATATYPE := QLTSTORB.GET_NUMBER('datatype'
                                     ,X_ROW);
    V_DISP_LEN := QLTSTORB.GET_NUMBER('disp_length'
                                     ,X_ROW);
    IF V_FUNCTION IS NULL THEN
      IF V_DATATYPE = 2 THEN
        V_NAME := 'qltdate.number_canon_to_user(' || X_NAME || ')';
      ELSIF V_DATATYPE = 3 THEN
        V_NAME := 'qltdate.any_to_user(' || X_NAME || ')';
      ELSIF V_DATATYPE = 6 THEN
        IF V_HARDCODED IS NOT NULL THEN
          V_NAME := 'qltdate.canon_to_user(qltdate.date_to_canon_dt(' || X_NAME || '))';
        ELSE
          V_NAME := 'qltdate.canon_to_user(' || X_NAME || ')';
        END IF;
      ELSE
        V_NAME := X_NAME;
      END IF;
    ELSE
      IF V_HARDCODED IS NULL THEN
        IF V_FUNCTION <> 2 THEN
          V_NAME := 'qltdate.any_to_number(' || X_NAME || ')';
        ELSE
          V_NAME := X_NAME;
        END IF;
      ELSE
        V_NAME := X_NAME;
      END IF;
      V_NAME := ADD_FXN(X_ROW
                       ,V_NAME);
      V_NAME := 'to_char(' || V_NAME || ')';
    END IF;
    V_NAME := 'NVL(' || V_NAME || ', '' '')';
    IF V_DATATYPE = 2 THEN
      V_NAME := 'lpad(' || V_NAME || ', ' || TO_CHAR(V_DISP_LEN) || ')';
    ELSE
      V_NAME := 'rpad(' || V_NAME || ', ' || TO_CHAR(V_DISP_LEN) || ')';
    END IF;
    RETURN (V_NAME);
  END ADD_FXN_RPT;

  FUNCTION DECODE_FXN(FXNNUM IN NUMBER) RETURN VARCHAR2 IS
    FXNNAME VARCHAR2(30);
  BEGIN
    IF (FXNNUM = 1) THEN
      FXNNAME := 'SUM';
    ELSIF (FXNNUM = 2) THEN
      FXNNAME := 'COUNT';
    ELSIF (FXNNUM = 3) THEN
      FXNNAME := 'AVG';
    ELSIF (FXNNUM = 4) THEN
      FXNNAME := 'MIN';
    ELSIF (FXNNUM = 5) THEN
      FXNNAME := 'MAX';
    ELSE
      FXNNAME := NULL;
    END IF;
    RETURN (FXNNAME);
  END DECODE_FXN;

  FUNCTION DECODE_OPERATOR(OPNUM IN NUMBER
                          ,X_DATATYPE IN NUMBER) RETURN VARCHAR2 IS
    OPNAME VARCHAR2(30);
  BEGIN
    IF (OPNUM = 1) THEN
      IF ((X_DATATYPE = 1) OR (X_DATATYPE = 3) OR (X_DATATYPE = 6)) THEN
        OPNAME := 'LIKE';
      ELSE
        OPNAME := '=';
      END IF;
    ELSIF (OPNUM = 2) THEN
      IF ((X_DATATYPE = 1) OR (X_DATATYPE = 3) OR (X_DATATYPE = 6)) THEN
        OPNAME := 'NOT LIKE';
      ELSE
        OPNAME := '<>';
      END IF;
    ELSIF (OPNUM = 3) THEN
      OPNAME := '>=';
    ELSIF (OPNUM = 4) THEN
      OPNAME := '<=';
    ELSIF (OPNUM = 5) THEN
      OPNAME := '>';
    ELSIF (OPNUM = 6) THEN
      OPNAME := '<';
    ELSIF (OPNUM = 7) THEN
      OPNAME := 'IS NOT NULL';
    ELSIF (OPNUM = 8) THEN
      OPNAME := 'IS NULL';
    ELSIF (OPNUM = 9) THEN
      OPNAME := 'BETWEEN';
    ELSIF (OPNUM = 10) THEN
      OPNAME := 'OUTSIDE';
    ELSIF (OPNUM = 11) THEN
      OPNAME := 'IN';
    END IF;
    RETURN (OPNAME);
  END DECODE_OPERATOR;

  PROCEDURE LOOP_THROUGH_RECORDS IS
    CURSOR PCURSOR IS
      SELECT
        QCV.CHAR_ID,
        QCV.HARDCODED_COLUMN,
        QCV.RESULT_COLUMN_NAME,
        QCV.DATATYPE,
        QCV.OPERATOR,
        QCV.LOW_VALUE,
        QCV.HIGH_VALUE,
        QCV.SQL_TYPE,
        QCV.DISPLAY_LENGTH,
        QCV.PROMPT,
        QCV.ORDER_SEQUENCE,
        QCV.TOTAL,
        QCV.FXN,
        QCV.FXN_MEANING,
        QCV.DECIMAL_PRECISION,
        QCV.FK_LOOKUP_TYPE,
        QCV.FK_TABLE_NAME,
        QCV.FK_TABLE_SHORT_NAME,
        QCV.PK_ID,
        QCV.FK_ID,
        QCV.PK_ID2,
        QCV.FK_ID2,
        QCV.PK_ID3,
        QCV.FK_ID3,
        QCV.FK_MEANING,
        QCV.FK_DESCRIPTION,
        QCV.FK_ADD_WHERE,
        QIL.PARENT_BLOCK_NAME,
        QIL.LIST_ID
      FROM
        QA_CRITERIA_V QCV,
        QA_IN_LISTS QIL
      WHERE QCV.CRITERIA_ID = V_CRITERIA_ID
        AND qil.list_elem_id (+) = CRITERIA_SEQUENCE
      ORDER BY
        11;
    V_OPERATOR VARCHAR2(100);
  BEGIN
    FOR prec IN PCURSOR LOOP
      V_OPERATOR := DECODE_OPERATOR(PREC.OPERATOR
                                   ,PREC.DATATYPE);
      QLTSTORB.ADD_ROW_TO_REC_GROUP(PREC.CHAR_ID
                                   ,PREC.HARDCODED_COLUMN
                                   ,PREC.RESULT_COLUMN_NAME
                                   ,PREC.DATATYPE
                                   ,V_OPERATOR
                                   ,PREC.LOW_VALUE
                                   ,PREC.HIGH_VALUE
                                   ,PREC.SQL_TYPE
                                   ,PREC.DISPLAY_LENGTH
                                   ,PREC.PROMPT
                                   ,PREC.ORDER_SEQUENCE
                                   ,PREC.TOTAL
                                   ,PREC.FXN
                                   ,PREC.FXN_MEANING
                                   ,PREC.DECIMAL_PRECISION
                                   ,PREC.FK_LOOKUP_TYPE
                                   ,PREC.FK_TABLE_NAME
                                   ,PREC.FK_TABLE_SHORT_NAME
                                   ,PREC.PK_ID
                                   ,PREC.PK_ID2
                                   ,PREC.PK_ID3
                                   ,PREC.FK_ID
                                   ,PREC.FK_ID2
                                   ,PREC.FK_ID3
                                   ,PREC.FK_MEANING
                                   ,PREC.FK_DESCRIPTION
                                   ,PREC.FK_ADD_WHERE
                                   ,NULL
                                   ,PREC.PARENT_BLOCK_NAME
                                   ,PREC.LIST_ID);
    END LOOP;
  END LOOP_THROUGH_RECORDS;

END QA_QLTRSLTR_XMLP_PKG;



/
