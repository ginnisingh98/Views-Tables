--------------------------------------------------------
--  DDL for Package Body GML_ORPLRPJ_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_ORPLRPJ_XMLP_PKG" AS
/* $Header: ORPLRPJB.pls 120.0 2007/12/24 13:24:27 nchinnam noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    PRN_LINES := 0;
    SELECT
      ORGN_NAME
    INTO CP_DEFAULT_ORGN
    FROM
      SY_ORGN_MST
    WHERE ORGN_CODE = P_DEFAULT_ORGN;
    SELECT
      USER_NAME
    INTO CP_DEFAULT_USER
    FROM
      FND_USER
    WHERE USER_ID = P_DEFAULT_USER;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    PARAM_WHERE_CLAUSE := '  ';
    PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || 'and hdr.orgn_code = :p_default_orgn ';
    IF (P_FROM_SHIPPING_NO IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and bol.bol_no >= :p_from_shipping_no ';
    END IF;
    IF (P_TO_SHIPPING_NO IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and bol.bol_no <= :p_to_shipping_no ';
    END IF;
    IF (P_FROM_ORDER_NO IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and hdr.order_no >= :p_from_order_no ';
    END IF;
    IF (P_TO_ORDER_NO IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and hdr.order_no <= :p_to_order_no ';
    END IF;
    IF (P_FROM_SHIPTO IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and sc.cust_no >= :p_from_shipto ';
    END IF;
    IF (P_TO_SHIPTO IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and sc.cust_no <= :p_to_shipto ';
    END IF;
    IF (P_FROM_WHSE IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and dtl.from_whse >= :p_from_whse ';
    END IF;
    IF (P_TO_WHSE IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and dtl.from_whse <= :p_to_whse ';
    END IF;
    IF (P_FROM_SCHED_SHIPDATE IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and dtl.sched_shipdate >= :p_from_sched_shipdate ';
    END IF;
    IF (P_TO_SCHED_SHIPDATE IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and dtl.sched_shipdate <= :p_to_sched_shipdate ';
    END IF;
    IF (P_SORT_1 = 3) THEN
      FLAG := 1;
    ELSIF (P_SORT_1 = 1) THEN
      FLAG := 2;
    ELSIF (P_SORT_1 = 2) THEN
      FLAG := 3;
    ELSE
      /*SRW.MESSAGE(111
                 ,'invalid option')*/NULL;
      /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END IF;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION CF_SORTFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SORT_1 = 1 THEN
      RETURN ('Order Number, Line');
    ELSIF P_SORT_1 = 2 THEN
      RETURN ('Shipping Number, Line');
    ELSIF P_SORT_1 = 3 THEN
      RETURN ('Warehouse, Location, Item Code');
    END IF;
    RETURN NULL;
  END CF_SORTFORMULA;

  PROCEDURE GML_ORPLRPJ_XMLP_PKG_HEADER IS
  BEGIN
    NULL;
  END GML_ORPLRPJ_XMLP_PKG_HEADER;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION CP_DEFAULT_ORGN_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_DEFAULT_ORGN;
  END CP_DEFAULT_ORGN_P;

  FUNCTION CP_DEFAULT_USER_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_DEFAULT_USER;
  END CP_DEFAULT_USER_P;

END GML_ORPLRPJ_XMLP_PKG;


/
