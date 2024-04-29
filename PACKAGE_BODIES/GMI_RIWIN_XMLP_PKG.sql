--------------------------------------------------------
--  DDL for Package Body GMI_RIWIN_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_RIWIN_XMLP_PKG" AS
/* $Header: RIWINB.pls 120.0 2007/12/24 13:29:09 nchinnam noship $ */
  FUNCTION WHSE_QTYFORMULA(WHSCODE IN VARCHAR2
                          ,ITEM_ID IN NUMBER) RETURN NUMBER IS
    WHSEQTY NUMBER;
  BEGIN
    SELECT
      SUM(LOCT_ONHAND)
    INTO WHSEQTY
    FROM
      IC_ITEM_MST ITM,
      IC_LOCT_INV ILI
    WHERE ITM.ITEM_ID = ILI.ITEM_ID
      AND ILI.DELETE_MARK = 0
      AND ITM.DELETE_MARK = 0
      AND ILI.WHSE_CODE = WHSCODE
      AND ITM.ITEM_ID = WHSE_QTYFORMULA.ITEM_ID;
    RETURN (WHSEQTY);
  END WHSE_QTYFORMULA;

  FUNCTION TOTAL_QTYFORMULA(ITEM_ID IN NUMBER) RETURN NUMBER IS
    TOTALQTY NUMBER;
  BEGIN
    SELECT
      SUM(LOCT_ONHAND)
    INTO TOTALQTY
    FROM
      IC_ITEM_MST ITM,
      IC_LOCT_INV ILI
    WHERE ITM.ITEM_ID = ILI.ITEM_ID
      AND ILI.DELETE_MARK = 0
      AND ITM.DELETE_MARK = 0
      AND ITM.ITEM_ID = TOTAL_QTYFORMULA.ITEM_ID;
    RETURN (TOTALQTY);
    IF SQL%NOTFOUND THEN
      RETURN (0.00);
    END IF;
    RETURN NULL;
  END TOTAL_QTYFORMULA;

  FUNCTION WHSE_QTY2FORMULA(WHSCODE IN VARCHAR2
                           ,ITEM_ID IN NUMBER) RETURN NUMBER IS
    WHSEQTY2 NUMBER:=0;
  BEGIN
    SELECT
      NVL(SUM(LOCT_ONHAND2),0)
    INTO WHSEQTY2
    FROM
      IC_ITEM_MST ITM,
      IC_LOCT_INV ILI
    WHERE ITM.ITEM_ID = ILI.ITEM_ID
      AND ILI.DELETE_MARK = 0
      AND ITM.DELETE_MARK = 0
      AND ILI.WHSE_CODE = WHSCODE
      AND ITM.ITEM_ID = WHSE_QTY2FORMULA.ITEM_ID;
    RETURN (WHSEQTY2);
  END WHSE_QTY2FORMULA;

  FUNCTION TOTAL_QTY2FORMULA(ITEM_ID IN NUMBER) RETURN NUMBER IS
    TOTALQTY2 NUMBER:=0;
  BEGIN
    SELECT
      NVL(SUM(LOCT_ONHAND2),0)
    INTO TOTALQTY2
    FROM
      IC_ITEM_MST ITM,
      IC_LOCT_INV ILI
    WHERE ITM.ITEM_ID = ILI.ITEM_ID
      AND ILI.DELETE_MARK = 0
      AND ITM.DELETE_MARK = 0
      AND ITM.ITEM_ID = TOTAL_QTY2FORMULA.ITEM_ID;
    RETURN (TOTALQTY2);
    IF SQL%NOTFOUND THEN
      RETURN (0.00);
    END IF;
    RETURN NULL;
  END TOTAL_QTY2FORMULA;

  FUNCTION CF_RANGEFORMULA RETURN VARCHAR2 IS
    RANGEV VARCHAR2(200);
  BEGIN
    SELECT
      DECODE(FROM_ITEM
            ,NULL
            ,DECODE(TO_ITEM
                  ,NULL
                  ,'Item Range : All '
                  ,'Item Range : All - ' || TO_ITEM)
            ,DECODE(TO_ITEM
                  ,NULL
                  ,'Item Range : ' || FROM_ITEM || ' - All '
                  ,'Item Range : ' || FROM_ITEM || ' - ' || TO_ITEM))
    INTO RANGEV
    FROM
      DUAL;
    RETURN (RANGEV);
  END CF_RANGEFORMULA;

  FUNCTION USERCFFORMULA RETURN VARCHAR2 IS
    USERNAME VARCHAR2(100);
  BEGIN
    SELECT
      USER_NAME
    INTO USERNAME
    FROM
      FND_USER
    WHERE USER_ID = GMI_RIWIN_XMLP_PKG.USER_ID;
    RETURN (USERNAME);
  END USERCFFORMULA;

  FUNCTION FROM_ITEMCFFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF FROM_ITEM IS NULL THEN
      SELECT
        'All'
      INTO FROM_ITEMCP
      FROM
        DUAL;
    ELSE
      FROM_ITEMCP := FROM_ITEM;
    END IF;
    RETURN (FROM_ITEMCP);
  END FROM_ITEMCFFORMULA;

  FUNCTION TO_ITEMCFFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF TO_ITEM IS NULL THEN
      SELECT
        'All'
      INTO TO_ITEMCP
      FROM
        DUAL;
    ELSE
      TO_ITEMCP := TO_ITEM;
    END IF;
    RETURN (TO_ITEMCP);
  END TO_ITEMCFFORMULA;

  FUNCTION TO_WHSECFFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF TO_WHSE IS NULL THEN
      SELECT
        'All'
      INTO TO_WHSECP
      FROM
        DUAL;
    ELSE
      TO_WHSECP := TO_WHSE;
    END IF;
    RETURN (TO_WHSECP);
  END TO_WHSECFFORMULA;

  FUNCTION FROM_WHSECFFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF FROM_WHSE IS NULL THEN
      SELECT
        'All'
      INTO FROM_WHSECP
      FROM
        DUAL;
    ELSE
      FROM_WHSECP := FROM_WHSE;
    END IF;
    RETURN (FROM_WHSECP);
  END FROM_WHSECFFORMULA;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;

    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    RETURN (TRUE);
  END BEFOREREPORT;

  PROCEDURE HEADER IS
  BEGIN
    NULL;
  END HEADER;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION FROM_ITEMCP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN FROM_ITEMCP;
  END FROM_ITEMCP_P;

  FUNCTION TO_ITEMCP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN TO_ITEMCP;
  END TO_ITEMCP_P;

  FUNCTION FROM_WHSECP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN FROM_WHSECP;
  END FROM_WHSECP_P;

  FUNCTION TO_WHSECP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN TO_WHSECP;
  END TO_WHSECP_P;

END GMI_RIWIN_XMLP_PKG;


/