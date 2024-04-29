--------------------------------------------------------
--  DDL for Package Body GML_ORUARPJ_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_ORUARPJ_XMLP_PKG" AS
/* $Header: ORUARPJB.pls 120.1 2008/01/06 13:44:32 dwkrishn noship $ */
  FUNCTION AFTERPFORM RETURN BOOLEAN IS
    SORT4 VARCHAR2(20);
    DECODESQL VARCHAR(50);
  BEGIN
    PARAM_WHERE_CLAUSE := ' ';
    PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and hdr.orgn_code = :p_default_orgn  ';
    IF (P_FROM_WHSE IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and dtl.from_whse >= :p_from_whse ';
    END IF;
    IF (P_TO_WHSE IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and dtl.from_whse <= :p_to_whse ';
    END IF;
    IF (P_FROM_ORDER_NO IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and hdr.order_no >= :p_from_order_no ';
    END IF;
    IF (P_TO_ORDER_NO IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and hdr.order_no <= :p_to_order_no ';
    END IF;
    IF (P_FROM_ITEM_NO IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and item.item_no >= :p_from_item_no ';
    END IF;
    IF (P_TO_ITEM_NO IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and item.item_no <= :p_to_item_no ';
    END IF;
    IF (P_FROM_CUST_NO IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and cust.cust_no >= :p_from_cust_no ';
    END IF;
    IF (P_TO_CUST_NO IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and cust.cust_no <= :p_to_cust_no ';
    END IF;
    IF (P_SHIPDATE IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and TRUNC(DTL.SCHED_SHIPDATE) <= TRUNC(:P_SHIPDATE) ';
    END IF;
    SELECT
      DECODE(P_SORT_1
            ,'5'
            ,3
            ,'1'
            ,4
            ,'3'
            ,5
            ,'2'
            ,6
            ,'4'
            ,8)
    INTO DECODESQL
    FROM
      DUAL;
    P_SORT := 'ORDER BY ' || DECODESQL;
    SELECT
      DECODE(P_SORT_2
            ,'5'
            ,3
            ,'1'
            ,4
            ,'3'
            ,5
            ,'2'
            ,6
            ,'4'
            ,8)
    INTO DECODESQL
    FROM
      DUAL;
    P_SORT := P_SORT || ',' || DECODESQL;
    SELECT
      DECODE(P_SORT_3
            ,'5'
            ,3
            ,'1'
            ,4
            ,'3'
            ,5
            ,'2'
            ,6
            ,'4'
            ,8)
    INTO DECODESQL
    FROM
      DUAL;
    P_SORT := P_SORT || ',' || DECODESQL;
    IF (P_SORT_4 IS NOT NULL) THEN
      IF (P_SORT_4 = '5') THEN
        P_SORT := P_SORT || ' ,DTL.FROM_WHSE ';
      END IF;
      IF (P_SORT_4 = '2') THEN
        P_SORT := P_SORT || ' ,HDR.ORDER_NO ';
      END IF;
      IF (P_SORT_4 = '1') THEN
        P_SORT := P_SORT || ' ,ITEM.ITEM_NO ';
      END IF;
      IF (P_SORT_4 = '4') THEN
        P_SORT := P_SORT || ' ,CUST.CUST_NO ';
      END IF;
      IF (P_SORT_4 = '3') THEN
        P_SORT := P_SORT || ' ,DTL.SCHED_SHIPDATE';
      END IF;
    ELSE
      P_SORT := P_SORT;
    END IF;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION CF_1FORMULA(QC_GRADE_WANTED IN VARCHAR2
                      ,ITEM_ID_1 IN NUMBER
                      ,FROM_WHSE IN VARCHAR2
                      ,ITEM_UM IN VARCHAR2
                      ,ORDER_UM1 IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    DECLARE
      V_SHIP_QTY NUMBER;
      V_COMMITTEDSALES_QTY NUMBER;
      V_COMMITTEDPROD_QTY NUMBER;
      V_INVENTORY_AVAIL NUMBER;
      V_TEMP NUMBER;
    BEGIN
      IF (LTRIM(RTRIM(QC_GRADE_WANTED)) IS NULL) THEN
        SELECT
          SUM(SUMINV.ONHAND_SHIP_QTY),
          SUM(SUMINV.COMMITTEDSALES_QTY),
          SUM(SUMINV.COMMITTEDPROD_QTY)
        INTO V_SHIP_QTY,V_COMMITTEDSALES_QTY,V_COMMITTEDPROD_QTY
        FROM
          IC_SUMM_INV SUMINV
        WHERE SUMINV.ITEM_ID = ITEM_ID_1
          AND SUMINV.WHSE_CODE = FROM_WHSE;
      ELSE
        SELECT
          SUM(SUMINV.ONHAND_SHIP_QTY),
          SUM(SUMINV.COMMITTEDSALES_QTY),
          SUM(SUMINV.COMMITTEDPROD_QTY)
        INTO V_SHIP_QTY,V_COMMITTEDSALES_QTY,V_COMMITTEDPROD_QTY
        FROM
          IC_SUMM_INV SUMINV
        WHERE SUMINV.ITEM_ID = ITEM_ID_1
          AND SUMINV.WHSE_CODE = FROM_WHSE
          AND SUMINV.QC_GRADE = QC_GRADE_WANTED;
      END IF;
      V_TEMP := GMISYUM.SY_UOMCV(ITEM_ID_1
                                ,0
                                ,V_INVENTORY_AVAIL
                                ,ITEM_UM
                                ,ITEM_UM
                                ,V_INVENTORY_AVAIL
                                ,ORDER_UM1
                                ,0
                                ,0
                                ,NULL);
      V_INVENTORY_AVAIL := V_SHIP_QTY - V_COMMITTEDSALES_QTY - V_COMMITTEDPROD_QTY;
      IF (V_INVENTORY_AVAIL < 0) THEN
        RETURN 0;
      ELSE
        RETURN V_INVENTORY_AVAIL;
      END IF;
    END;
    RETURN NULL;
  END CF_1FORMULA;

  function F_CF_1(v_value1 number,billing_currency varchar2) return varchar2 is
v_str VARCHAR2(20) ;
xx  NUMBER ;
v_value2 number;
BEGIN
v_value2:=v_value1;
 begin
    select decimal_precision into xx
           from gl_curr_mst
           where currency_code = billing_currency ;
    Exception
	when others then
	  xx := 0 ;
  End ;
v_str := '';
 LOOP
    if ((v_value2) >= 10) then
	v_value2 := v_value2/10;
	v_str := v_str ||'9' ;
    Else
	v_str := v_str ||'0D' ;
        Exit ;
    End if ;
    End LOOP ;
 WHILE (xx > 0 ) LOOP
      xx := xx - 1 ;
      v_str := v_str ||'9' ;
 END LOOP;
return(v_str);
end;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    PRN_LINES := 0;
    BEGIN
      SELECT
        ORGN_NAME
      INTO CP_ORGN_NAME
      FROM
        SY_ORGN_MST
      WHERE ORGN_CODE = P_DEFAULT_ORGN;
      SELECT
        USER_NAME
      INTO CP_USER
      FROM
        FND_USER
      WHERE P_DEFAULT_USER = USER_ID;
      IF P_SORT_1 IS NOT NULL THEN
        SELECT
          MEANING
        INTO CP_SORT_1
        FROM
          GEM_LOOKUPS
        WHERE LOOKUP_TYPE like 'GEMMS_OP_ORUARPJ'
          AND LOOKUP_CODE = P_SORT_1;
      END IF;
      IF P_SORT_2 IS NOT NULL THEN
        SELECT
          MEANING
        INTO CP_SORT_2
        FROM
          GEM_LOOKUPS
        WHERE LOOKUP_TYPE like 'GEMMS_OP_ORUARPJ'
          AND LOOKUP_CODE = P_SORT_2;
      END IF;
      IF P_SORT_3 IS NOT NULL THEN
        SELECT
          MEANING
        INTO CP_SORT_3
        FROM
          GEM_LOOKUPS
        WHERE LOOKUP_TYPE like 'GEMMS_OP_ORUARPJ'
          AND LOOKUP_CODE = P_SORT_3;
      END IF;
      IF P_SORT_4 IS NOT NULL THEN
        SELECT
          MEANING
        INTO CP_SORT_4
        FROM
          GEM_LOOKUPS
        WHERE LOOKUP_TYPE like 'GEMMS_OP_ORUARPJ'
          AND LOOKUP_CODE = P_SORT_4;
      END IF;
      RETURN (TRUE);
    EXCEPTION
      WHEN OTHERS THEN
        RETURN TRUE;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION CF_SORT_DESCFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SORT_1 IS NOT NULL THEN
      SELECT
        MEANING
      INTO CP_SORT_1
      FROM
        GEM_LOOKUP_VALUES
      WHERE LOOKUP_TYPE like 'GEMMS_OP_ORUARPJ'
        AND LOOKUP_CODE = P_SORT_1;
    END IF;
    IF P_SORT_2 IS NOT NULL THEN
      SELECT
        MEANING
      INTO CP_SORT_2
      FROM
        GEM_LOOKUP_VALUES
      WHERE LOOKUP_TYPE like 'GEMMS_OP_ORUARPJ'
        AND LOOKUP_CODE = P_SORT_2;
    END IF;
    IF P_SORT_3 IS NOT NULL THEN
      SELECT
        MEANING
      INTO CP_SORT_3
      FROM
        GEM_LOOKUP_VALUES
      WHERE LOOKUP_TYPE like 'GEMMS_OP_ORUARPJ'
        AND LOOKUP_CODE = P_SORT_3;
    END IF;
    IF P_SORT_4 IS NOT NULL THEN
      SELECT
        MEANING
      INTO CP_SORT_4
      FROM
        GEM_LOOKUP_VALUES
      WHERE LOOKUP_TYPE like 'GEMMS_OP_ORUARPJ'
        AND LOOKUP_CODE = P_SORT_4;
    END IF;
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END CF_SORT_DESCFORMULA;

  PROCEDURE GML_ORUARPJ_XMLP_PKG_HEADER IS
  BEGIN
    NULL;
  END GML_ORUARPJ_XMLP_PKG_HEADER;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION CP_ORGN_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_ORGN_NAME;
  END CP_ORGN_NAME_P;

  FUNCTION CP_USER_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_USER;
  END CP_USER_P;

  FUNCTION CP_SORT_1_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_SORT_1;
  END CP_SORT_1_P;

  FUNCTION CP_SORT_2_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_SORT_2;
  END CP_SORT_2_P;

  FUNCTION CP_SORT_3_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_SORT_3;
  END CP_SORT_3_P;

  FUNCTION CP_SORT_4_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_SORT_4;
  END CP_SORT_4_P;

END GML_ORUARPJ_XMLP_PKG;


/
