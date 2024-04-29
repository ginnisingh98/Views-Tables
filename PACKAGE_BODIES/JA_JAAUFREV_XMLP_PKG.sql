--------------------------------------------------------
--  DDL for Package Body JA_JAAUFREV_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_JAAUFREV_XMLP_PKG" AS
/* $Header: JAAUFREVB.pls 120.1 2007/12/25 16:06:31 dwkrishn noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'SRWINIT failed in before report trigger')*/NULL;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION C_NEW_DEP_RSVFORMULA(TH_ID IN NUMBER
                               ,BOOK_TYPE_CODE IN VARCHAR2
                               ,ASSET_ID IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      L_NEW_DEP_RSV NUMBER;
    BEGIN
      SELECT
        DECODE(DEBIT_CREDIT_FLAG
              ,'CR'
              ,-ADJ.ADJUSTMENT_AMOUNT
              ,'DR'
              ,ADJ.ADJUSTMENT_AMOUNT)
      INTO L_NEW_DEP_RSV
      FROM
        FA_ADJUSTMENTS ADJ
      WHERE ADJ.TRANSACTION_HEADER_ID = TH_ID
        AND ADJ.BOOK_TYPE_CODE = C_NEW_DEP_RSVFORMULA.BOOK_TYPE_CODE
        AND ADJ.ASSET_ID = C_NEW_DEP_RSVFORMULA.ASSET_ID
        AND ADJ.SOURCE_TYPE_CODE = 'REVALUATION'
        AND ADJ.ADJUSTMENT_TYPE = 'RESERVE';
      RETURN (L_NEW_DEP_RSV);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        L_NEW_DEP_RSV := 0;
        RETURN (L_NEW_DEP_RSV);
    END;
    RETURN NULL;
  END C_NEW_DEP_RSVFORMULA;

  FUNCTION D_ASSET_CLASSFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      L_ASSET_CLASS VARCHAR2(250);
    BEGIN
      IF (P_ASSET_CLASS <> ' ') THEN
        SELECT
          DECODE(FLEX1.APPLICATION_COLUMN_NAME
                ,'SEGMENT7'
                ,C.SEGMENT7
                ,'SEGMENT6'
                ,C.SEGMENT6
                ,'SEGMENT5'
                ,C.SEGMENT5
                ,'SEGMENT4'
                ,C.SEGMENT4
                ,'SEGMENT3'
                ,C.SEGMENT3
                ,'SEGMENT2'
                ,C.SEGMENT2
                ,'SEGMENT1'
                ,C.SEGMENT1) || DECODE(NVL(FLEX2.APPLICATION_COLUMN_NAME
                    ,' ')
                ,' '
                ,' '
                ,'-') || DECODE(NVL(FLEX2.APPLICATION_COLUMN_NAME
                    ,' ')
                ,'SEGMENT7'
                ,C.SEGMENT7
                ,'SEGMENT6'
                ,C.SEGMENT6
                ,'SEGMENT5'
                ,C.SEGMENT5
                ,'SEGMENT4'
                ,C.SEGMENT4
                ,'SEGMENT3'
                ,C.SEGMENT3
                ,'SEGMENT2'
                ,C.SEGMENT2
                ,'SEGMENT1'
                ,C.SEGMENT1
                ,' ') || DECODE(NVL(FLEX3.APPLICATION_COLUMN_NAME
                    ,' ')
                ,' '
                ,' '
                ,'-') || DECODE(NVL(FLEX3.APPLICATION_COLUMN_NAME
                    ,' ')
                ,'SEGMENT7'
                ,C.SEGMENT7
                ,'SEGMENT6'
                ,C.SEGMENT6
                ,'SEGMENT5'
                ,C.SEGMENT5
                ,'SEGMENT4'
                ,C.SEGMENT4
                ,'SEGMENT3'
                ,C.SEGMENT3
                ,'SEGMENT2'
                ,C.SEGMENT2
                ,'SEGMENT1'
                ,C.SEGMENT1
                ,' ') || DECODE(NVL(FLEX4.APPLICATION_COLUMN_NAME
                    ,' ')
                ,' '
                ,' '
                ,'-') || DECODE(NVL(FLEX4.APPLICATION_COLUMN_NAME
                    ,' ')
                ,'SEGMENT7'
                ,C.SEGMENT7
                ,'SEGMENT6'
                ,C.SEGMENT6
                ,'SEGMENT5'
                ,C.SEGMENT5
                ,'SEGMENT4'
                ,C.SEGMENT4
                ,'SEGMENT3'
                ,C.SEGMENT3
                ,'SEGMENT2'
                ,C.SEGMENT2
                ,'SEGMENT1'
                ,C.SEGMENT1
                ,' ') || DECODE(NVL(FLEX5.APPLICATION_COLUMN_NAME
                    ,' ')
                ,' '
                ,' '
                ,'-') || DECODE(NVL(FLEX5.APPLICATION_COLUMN_NAME
                    ,' ')
                ,'SEGMENT7'
                ,C.SEGMENT7
                ,'SEGMENT6'
                ,C.SEGMENT6
                ,'SEGMENT5'
                ,C.SEGMENT5
                ,'SEGMENT4'
                ,C.SEGMENT4
                ,'SEGMENT3'
                ,C.SEGMENT3
                ,'SEGMENT2'
                ,C.SEGMENT2
                ,'SEGMENT1'
                ,C.SEGMENT1
                ,' ') || DECODE(NVL(FLEX6.APPLICATION_COLUMN_NAME
                    ,' ')
                ,' '
                ,' '
                ,'-') || DECODE(NVL(FLEX6.APPLICATION_COLUMN_NAME
                    ,' ')
                ,'SEGMENT7'
                ,C.SEGMENT7
                ,'SEGMENT6'
                ,C.SEGMENT6
                ,'SEGMENT5'
                ,C.SEGMENT5
                ,'SEGMENT4'
                ,C.SEGMENT4
                ,'SEGMENT3'
                ,C.SEGMENT3
                ,'SEGMENT2'
                ,C.SEGMENT2
                ,'SEGMENT1'
                ,C.SEGMENT1
                ,' ') || DECODE(NVL(FLEX7.APPLICATION_COLUMN_NAME
                    ,' ')
                ,' '
                ,' '
                ,'-') || DECODE(NVL(FLEX7.APPLICATION_COLUMN_NAME
                    ,' ')
                ,'SEGMENT7'
                ,C.SEGMENT7
                ,'SEGMENT6'
                ,C.SEGMENT6
                ,'SEGMENT5'
                ,C.SEGMENT5
                ,'SEGMENT4'
                ,C.SEGMENT4
                ,'SEGMENT3'
                ,C.SEGMENT3
                ,'SEGMENT2'
                ,C.SEGMENT2
                ,'SEGMENT1'
                ,C.SEGMENT1
                ,' ')
        INTO L_ASSET_CLASS
        FROM
          FA_CATEGORIES C,
          FND_ID_FLEXS FLEXID,
          FND_ID_FLEX_SEGMENTS FLEX1,
          FND_ID_FLEX_SEGMENTS FLEX2,
          FND_ID_FLEX_SEGMENTS FLEX3,
          FND_ID_FLEX_SEGMENTS FLEX4,
          FND_ID_FLEX_SEGMENTS FLEX5,
          FND_ID_FLEX_SEGMENTS FLEX6,
          FND_ID_FLEX_SEGMENTS FLEX7
        WHERE C.CATEGORY_ID = P_ASSET_CLASS
          AND FLEXID.APPLICATION_TABLE_NAME = 'FA_CATEGORIES_B'
          AND FLEXID.UNIQUE_ID_COLUMN_NAME = 'CATEGORY_ID'
          AND FLEX1.ID_FLEX_CODE = FLEXID.ID_FLEX_CODE
          AND FLEX1.SEGMENT_NUM = 1
          AND FLEX1.ENABLED_FLAG = 'Y'
          AND flex2.id_flex_code (+) = FLEXID.ID_FLEX_CODE
          AND flex2.enabled_flag (+) = 'Y'
          AND flex2.segment_num (+) = 2
          AND flex3.id_flex_code (+) = FLEXID.ID_FLEX_CODE
          AND flex3.enabled_flag (+) = 'Y'
          AND flex3.segment_num (+) = 3
          AND flex4.id_flex_code (+) = FLEXID.ID_FLEX_CODE
          AND flex4.enabled_flag (+) = 'Y'
          AND flex4.segment_num (+) = 4
          AND flex5.id_flex_code (+) = FLEXID.ID_FLEX_CODE
          AND flex5.enabled_flag (+) = 'Y'
          AND flex5.segment_num (+) = 5
          AND flex6.id_flex_code (+) = FLEXID.ID_FLEX_CODE
          AND flex6.enabled_flag (+) = 'Y'
          AND flex6.segment_num (+) = 6
          AND flex7.id_flex_code (+) = FLEXID.ID_FLEX_CODE
          AND flex7.enabled_flag (+) = 'Y'
          AND flex7.segment_num (+) = 7;
        RETURN (L_ASSET_CLASS);
      ELSE
        RETURN ('ALL');
      END IF;
    END;
    RETURN NULL;
  END D_ASSET_CLASSFORMULA;

  FUNCTION PROFIT_LOSSFORMULA(TOT_OLD_REVAL_RSV IN NUMBER
                             ,TOT_REVAL_RSV IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      L_PROFIT_LOSS NUMBER;
      L_RESERVE NUMBER;
    BEGIN
      IF TOT_OLD_REVAL_RSV >= 0 THEN
        IF TOT_REVAL_RSV >= 0 THEN
          L_PROFIT_LOSS := 0;
          L_RESERVE := TOT_REVAL_RSV;
        ELSE
          IF TOT_OLD_REVAL_RSV > -1 * TOT_REVAL_RSV THEN
            L_PROFIT_LOSS := 0;
            L_RESERVE := TOT_REVAL_RSV;
          ELSE
            L_RESERVE := -1 * TOT_OLD_REVAL_RSV;
            L_PROFIT_LOSS := TOT_REVAL_RSV - L_RESERVE;
          END IF;
        END IF;
      END IF;
      IF TOT_OLD_REVAL_RSV < 0 AND TOT_REVAL_RSV >= 0 THEN
        IF -1 * TOT_OLD_REVAL_RSV <= TOT_REVAL_RSV THEN
          L_PROFIT_LOSS := -1 * TOT_OLD_REVAL_RSV;
          L_RESERVE := TOT_REVAL_RSV - L_PROFIT_LOSS;
        ELSE
          L_PROFIT_LOSS := TOT_REVAL_RSV;
          L_RESERVE := 0;
        END IF;
      END IF;
      IF TOT_OLD_REVAL_RSV < 0 AND TOT_REVAL_RSV < 0 THEN
        L_PROFIT_LOSS := TOT_REVAL_RSV;
        L_RESERVE := 0;
      END IF;
      RESERVE := L_RESERVE;
      RETURN (L_PROFIT_LOSS);
    END;
    RETURN NULL;
  END PROFIT_LOSSFORMULA;

  FUNCTION C_CATEGORYFORMULA(ASSET_CLASS IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      L_ASSET_CLASS VARCHAR2(250);
    BEGIN
      SELECT
        DECODE(FLEX1.APPLICATION_COLUMN_NAME
              ,'SEGMENT7'
              ,C.SEGMENT7
              ,'SEGMENT6'
              ,C.SEGMENT6
              ,'SEGMENT5'
              ,C.SEGMENT5
              ,'SEGMENT4'
              ,C.SEGMENT4
              ,'SEGMENT3'
              ,C.SEGMENT3
              ,'SEGMENT2'
              ,C.SEGMENT2
              ,'SEGMENT1'
              ,C.SEGMENT1) || DECODE(NVL(FLEX2.APPLICATION_COLUMN_NAME
                  ,' ')
              ,' '
              ,' '
              ,'-') || DECODE(NVL(FLEX2.APPLICATION_COLUMN_NAME
                  ,' ')
              ,'SEGMENT7'
              ,C.SEGMENT7
              ,'SEGMENT6'
              ,C.SEGMENT6
              ,'SEGMENT5'
              ,C.SEGMENT5
              ,'SEGMENT4'
              ,C.SEGMENT4
              ,'SEGMENT3'
              ,C.SEGMENT3
              ,'SEGMENT2'
              ,C.SEGMENT2
              ,'SEGMENT1'
              ,C.SEGMENT1
              ,' ') || DECODE(NVL(FLEX3.APPLICATION_COLUMN_NAME
                  ,' ')
              ,' '
              ,' '
              ,'-') || DECODE(NVL(FLEX3.APPLICATION_COLUMN_NAME
                  ,' ')
              ,'SEGMENT7'
              ,C.SEGMENT7
              ,'SEGMENT6'
              ,C.SEGMENT6
              ,'SEGMENT5'
              ,C.SEGMENT5
              ,'SEGMENT4'
              ,C.SEGMENT4
              ,'SEGMENT3'
              ,C.SEGMENT3
              ,'SEGMENT2'
              ,C.SEGMENT2
              ,'SEGMENT1'
              ,C.SEGMENT1
              ,' ') || DECODE(NVL(FLEX4.APPLICATION_COLUMN_NAME
                  ,' ')
              ,' '
              ,' '
              ,'-') || DECODE(NVL(FLEX4.APPLICATION_COLUMN_NAME
                  ,' ')
              ,'SEGMENT7'
              ,C.SEGMENT7
              ,'SEGMENT6'
              ,C.SEGMENT6
              ,'SEGMENT5'
              ,C.SEGMENT5
              ,'SEGMENT4'
              ,C.SEGMENT4
              ,'SEGMENT3'
              ,C.SEGMENT3
              ,'SEGMENT2'
              ,C.SEGMENT2
              ,'SEGMENT1'
              ,C.SEGMENT1
              ,' ') || DECODE(NVL(FLEX5.APPLICATION_COLUMN_NAME
                  ,' ')
              ,' '
              ,' '
              ,'-') || DECODE(NVL(FLEX5.APPLICATION_COLUMN_NAME
                  ,' ')
              ,'SEGMENT7'
              ,C.SEGMENT7
              ,'SEGMENT6'
              ,C.SEGMENT6
              ,'SEGMENT5'
              ,C.SEGMENT5
              ,'SEGMENT4'
              ,C.SEGMENT4
              ,'SEGMENT3'
              ,C.SEGMENT3
              ,'SEGMENT2'
              ,C.SEGMENT2
              ,'SEGMENT1'
              ,C.SEGMENT1
              ,' ') || DECODE(NVL(FLEX6.APPLICATION_COLUMN_NAME
                  ,' ')
              ,' '
              ,' '
              ,'-') || DECODE(NVL(FLEX6.APPLICATION_COLUMN_NAME
                  ,' ')
              ,'SEGMENT7'
              ,C.SEGMENT7
              ,'SEGMENT6'
              ,C.SEGMENT6
              ,'SEGMENT5'
              ,C.SEGMENT5
              ,'SEGMENT4'
              ,C.SEGMENT4
              ,'SEGMENT3'
              ,C.SEGMENT3
              ,'SEGMENT2'
              ,C.SEGMENT2
              ,'SEGMENT1'
              ,C.SEGMENT1
              ,' ') || DECODE(NVL(FLEX7.APPLICATION_COLUMN_NAME
                  ,' ')
              ,' '
              ,' '
              ,'-') || DECODE(NVL(FLEX7.APPLICATION_COLUMN_NAME
                  ,' ')
              ,'SEGMENT7'
              ,C.SEGMENT7
              ,'SEGMENT6'
              ,C.SEGMENT6
              ,'SEGMENT5'
              ,C.SEGMENT5
              ,'SEGMENT4'
              ,C.SEGMENT4
              ,'SEGMENT3'
              ,C.SEGMENT3
              ,'SEGMENT2'
              ,C.SEGMENT2
              ,'SEGMENT1'
              ,C.SEGMENT1
              ,' ')
      INTO L_ASSET_CLASS
      FROM
        FA_CATEGORIES C,
        FND_ID_FLEXS FLEXID,
        FND_ID_FLEX_SEGMENTS FLEX1,
        FND_ID_FLEX_SEGMENTS FLEX2,
        FND_ID_FLEX_SEGMENTS FLEX3,
        FND_ID_FLEX_SEGMENTS FLEX4,
        FND_ID_FLEX_SEGMENTS FLEX5,
        FND_ID_FLEX_SEGMENTS FLEX6,
        FND_ID_FLEX_SEGMENTS FLEX7
      WHERE C.CATEGORY_ID = ASSET_CLASS
        AND FLEXID.APPLICATION_TABLE_NAME = 'FA_CATEGORIES_B'
        AND FLEXID.UNIQUE_ID_COLUMN_NAME = 'CATEGORY_ID'
        AND FLEX1.ID_FLEX_CODE = FLEXID.ID_FLEX_CODE
        AND FLEX1.SEGMENT_NUM = 1
        AND FLEX1.ENABLED_FLAG = 'Y'
        AND flex2.id_flex_code (+) = FLEXID.ID_FLEX_CODE
        AND flex2.enabled_flag (+) = 'Y'
        AND flex2.segment_num (+) = 2
        AND flex3.id_flex_code (+) = FLEXID.ID_FLEX_CODE
        AND flex3.enabled_flag (+) = 'Y'
        AND flex3.segment_num (+) = 3
        AND flex4.id_flex_code (+) = FLEXID.ID_FLEX_CODE
        AND flex4.enabled_flag (+) = 'Y'
        AND flex4.segment_num (+) = 4
        AND flex5.id_flex_code (+) = FLEXID.ID_FLEX_CODE
        AND flex5.enabled_flag (+) = 'Y'
        AND flex5.segment_num (+) = 5
        AND flex6.id_flex_code (+) = FLEXID.ID_FLEX_CODE
        AND flex6.enabled_flag (+) = 'Y'
        AND flex6.segment_num (+) = 6
        AND flex7.id_flex_code (+) = FLEXID.ID_FLEX_CODE
        AND flex7.enabled_flag (+) = 'Y'
        AND flex7.segment_num (+) = 7;
      RETURN (L_ASSET_CLASS);
    END;
    RETURN NULL;
  END C_CATEGORYFORMULA;

  FUNCTION C_OLD_COSTFORMULA(OLD_COST IN NUMBER
                            ,C_OLD_REVAL_RSV IN NUMBER
                            ,C_OLD_DEP_RSV IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (OLD_COST - C_OLD_REVAL_RSV + C_OLD_DEP_RSV);
  END C_OLD_COSTFORMULA;

  FUNCTION C_OLD_REVAL_RSVFORMULA(ASSET_ID IN NUMBER
                                 ,BOOK_TYPE_CODE IN VARCHAR2
                                 ,TH_ID IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      L_TOT_REV_RSV NUMBER;
      L_NEW_REV_RSV NUMBER;
      L_OLD_REV_RSV NUMBER;
    BEGIN
      BEGIN
        SELECT
          SUM(DECODE(DEBIT_CREDIT_FLAG
                    ,'CR'
                    ,ADJ.ADJUSTMENT_AMOUNT
                    ,'DR'
                    ,-ADJ.ADJUSTMENT_AMOUNT))
        INTO L_TOT_REV_RSV
        FROM
          FA_ADJUSTMENTS ADJ
        WHERE ADJ.ASSET_ID = C_OLD_REVAL_RSVFORMULA.ASSET_ID
          AND ADJ.BOOK_TYPE_CODE = C_OLD_REVAL_RSVFORMULA.BOOK_TYPE_CODE
          AND ADJ.SOURCE_TYPE_CODE = 'REVALUATION'
          AND ADJ.ADJUSTMENT_TYPE = 'REVAL RESERVE';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          L_TOT_REV_RSV := 0;
      END;
      BEGIN
        SELECT
          DECODE(DEBIT_CREDIT_FLAG
                ,'CR'
                ,ADJ.ADJUSTMENT_AMOUNT
                ,'DR'
                ,-ADJ.ADJUSTMENT_AMOUNT)
        INTO L_NEW_REV_RSV
        FROM
          FA_ADJUSTMENTS ADJ
        WHERE ADJ.TRANSACTION_HEADER_ID = TH_ID
          AND ADJ.ASSET_ID = C_OLD_REVAL_RSVFORMULA.ASSET_ID
          AND ADJ.BOOK_TYPE_CODE = C_OLD_REVAL_RSVFORMULA.BOOK_TYPE_CODE
          AND ADJ.SOURCE_TYPE_CODE = 'REVALUATION'
          AND ADJ.ADJUSTMENT_TYPE = 'REVAL RESERVE';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          L_NEW_REV_RSV := 0;
      END;
      L_OLD_REV_RSV := L_TOT_REV_RSV - L_NEW_REV_RSV;
      RETURN (L_OLD_REV_RSV);
    END;
    RETURN NULL;
  END C_OLD_REVAL_RSVFORMULA;

  FUNCTION C_OLD_DEP_RSVFORMULA(ASSET_ID IN NUMBER
                               ,BOOK_TYPE_CODE IN VARCHAR2
                               ,TH_ID IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      L_TOT_DEP_RSV NUMBER;
      L_NEW_DEP_RSV NUMBER;
      L_OLD_DEP_RSV NUMBER;
    BEGIN
      BEGIN
        SELECT
          SUM(DECODE(DEBIT_CREDIT_FLAG
                    ,'CR'
                    ,-ADJ.ADJUSTMENT_AMOUNT
                    ,'DR'
                    ,ADJ.ADJUSTMENT_AMOUNT))
        INTO L_TOT_DEP_RSV
        FROM
          FA_ADJUSTMENTS ADJ
        WHERE ADJ.ASSET_ID = C_OLD_DEP_RSVFORMULA.ASSET_ID
          AND ADJ.BOOK_TYPE_CODE = C_OLD_DEP_RSVFORMULA.BOOK_TYPE_CODE
          AND ADJ.SOURCE_TYPE_CODE = 'REVALUATION'
          AND ADJ.ADJUSTMENT_TYPE = 'RESERVE';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          L_TOT_DEP_RSV := 0;
      END;
      BEGIN
        SELECT
          DECODE(DEBIT_CREDIT_FLAG
                ,'CR'
                ,-ADJ.ADJUSTMENT_AMOUNT
                ,'DR'
                ,ADJ.ADJUSTMENT_AMOUNT)
        INTO L_NEW_DEP_RSV
        FROM
          FA_ADJUSTMENTS ADJ
        WHERE ADJ.TRANSACTION_HEADER_ID = TH_ID
          AND ADJ.ASSET_ID = C_OLD_DEP_RSVFORMULA.ASSET_ID
          AND ADJ.BOOK_TYPE_CODE = C_OLD_DEP_RSVFORMULA.BOOK_TYPE_CODE
          AND ADJ.SOURCE_TYPE_CODE = 'REVALUATION'
          AND ADJ.ADJUSTMENT_TYPE = 'RESERVE';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          L_NEW_DEP_RSV := 0;
      END;
      L_OLD_DEP_RSV := L_TOT_DEP_RSV - L_NEW_DEP_RSV;
      RETURN (L_OLD_DEP_RSV);
    END;
    RETURN NULL;
  END C_OLD_DEP_RSVFORMULA;

  FUNCTION C_ACTUAL_COSTFORMULA(C_OLD_COST IN NUMBER
                               ,C_OLD_REVAL_RSV IN NUMBER
                               ,C_OLD_DEP_RSV IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (C_OLD_COST + C_OLD_REVAL_RSV - C_OLD_DEP_RSV);
  END C_ACTUAL_COSTFORMULA;

  FUNCTION C_REVAL_RSVFORMULA(ADJ_COST IN NUMBER
                             ,C_NEW_DEP_RSV IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (ADJ_COST + C_NEW_DEP_RSV);
  END C_REVAL_RSVFORMULA;

  FUNCTION C_NEW_COSTFORMULA(C_ACTUAL_COST IN NUMBER
                            ,ADJ_COST IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (C_ACTUAL_COST + ADJ_COST);
  END C_NEW_COSTFORMULA;

  FUNCTION C_NEW_REVAL_RSVFORMULA(C_OLD_REVAL_RSV IN NUMBER
                                 ,C_REVAL_RSV IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (C_OLD_REVAL_RSV + C_REVAL_RSV);
  END C_NEW_REVAL_RSVFORMULA;

  FUNCTION RESERVE_P RETURN NUMBER IS
  BEGIN
    RETURN RESERVE;
  END RESERVE_P;

END JA_JAAUFREV_XMLP_PKG;



/
