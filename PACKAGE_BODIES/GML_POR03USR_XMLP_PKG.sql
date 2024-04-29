--------------------------------------------------------
--  DDL for Package Body GML_POR03USR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_POR03USR_XMLP_PKG" AS
/* $Header: POR03USRB.pls 120.0 2007/12/24 13:28:45 nchinnam noship $ */
  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    PARAM_WHERE_CLAUSE := ' ';
    PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and rh.orgn_code = NVL(:p_orgn_code,rh.orgn_code)';
    IF (P_PO_RETURNS = 'Y') THEN
      IF (P_STOCK_RETURNS = 'Y') THEN
        NULL;
      ELSIF (P_STOCK_RETURNS <> 'Y') THEN
        PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and rcvh.recv_type = 1 ';
      END IF;
    ELSIF (P_PO_RETURNS <> 'Y') THEN
      IF (P_STOCK_RETURNS = 'Y') THEN
        PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and rcvh.recv_type = 2 ';
      ELSIF (P_STOCK_RETURNS <> 'Y') THEN
        PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and rcvh.recv_type NOT IN(1,2) ';
      END IF;
    END IF;
    IF (P_ITEM_NO_FROM IS NOT NULL AND P_ITEM_NO_TO IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and im.item_no between
                            					:p_item_no_from and :p_item_no_to ';
    ELSIF (P_ITEM_NO_FROM IS NOT NULL AND P_ITEM_NO_TO IS NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and im.item_no >=:p_item_no_from ';
    ELSIF (P_ITEM_NO_FROM IS NULL AND P_ITEM_NO_TO IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and im.item_no <=:p_item_no_to ';
    ELSIF (P_ITEM_NO_FROM IS NULL AND P_ITEM_NO_TO IS NULL) THEN
      NULL;
    END IF;
    IF (P_LOT_NO_FROM IS NOT NULL AND P_LOT_NO_TO IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and lm.lot_no between
                            					:p_lot_no_from and :p_lot_no_to ';
    ELSIF (P_LOT_NO_FROM IS NOT NULL AND P_LOT_NO_TO IS NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and lm.lot_no >= :p_lot_no_from ';
    ELSIF (P_LOT_NO_FROM IS NULL AND P_LOT_NO_TO IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and lm.lot_no <= :p_lot_no_to ';
    ELSIF (P_LOT_NO_FROM IS NULL AND P_LOT_NO_TO IS NULL) THEN
      NULL;
    END IF;
    IF (P_SUBLOT_NO_FROM IS NOT NULL AND P_SUBLOT_NO_TO IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and lm.sublot_no between
                            					:p_sublot_no_from and :p_sublot_no_to ';
    ELSIF (P_SUBLOT_NO_FROM IS NOT NULL AND P_SUBLOT_NO_TO IS NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and lm.sublot_no >= :p_sublot_no_from ';
    ELSIF (P_SUBLOT_NO_FROM IS NULL AND P_SUBLOT_NO_TO IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and lm.sublot_no <= :p_sublot_no_to ';
    ELSIF (P_SUBLOT_NO_FROM IS NULL AND P_SUBLOT_NO_TO IS NULL) THEN
      NULL;
    END IF;
    IF (P_RETURN_NO_FROM IS NOT NULL AND P_RETURN_NO_TO IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and rh.return_no between
                            					:p_return_no_from and :p_return_no_to ';
    ELSIF (P_RETURN_NO_FROM IS NOT NULL AND P_RETURN_NO_TO IS NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and rh.return_no >= :p_return_no_from ';
    ELSIF (P_RETURN_NO_FROM IS NULL AND P_RETURN_NO_TO IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and rh.return_no <= :p_return_no_to ';
    ELSIF (P_RETURN_NO_FROM IS NULL AND P_RETURN_NO_TO IS NULL) THEN
      NULL;
    END IF;
    IF (P_RETURN_DATE_FROM IS NOT NULL AND P_RETURN_DATE_TO IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and TRUNC(rh.return_date) between
                            					TRUNC(:p_return_date_from) and TRUNC(:p_return_date_to) ';
    ELSIF (P_RETURN_DATE_FROM IS NOT NULL AND P_RETURN_DATE_TO IS NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and TRUNC(rh.return_date) >= TRUNC(:p_return_date_from) ';
    ELSIF (P_RETURN_DATE_FROM IS NULL AND P_RETURN_DATE_TO IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and TRUNC(rh.return_date) <= TRUNC(:p_return_date_to) ';
    ELSIF (P_RETURN_DATE_FROM IS NULL AND P_RETURN_DATE_TO IS NULL) THEN
      NULL;
    END IF;
    IF (P_VENDOR_NO_FROM IS NOT NULL AND P_VENDOR_NO_TO IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and vm.vendor_no between
                            					:p_vendor_no_from and :p_vendor_no_to ';
    ELSIF (P_VENDOR_NO_FROM IS NOT NULL AND P_VENDOR_NO_TO IS NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and vm.vendor_no >= :p_vendor_no_from ';
    ELSIF (P_VENDOR_NO_FROM IS NULL AND P_VENDOR_NO_TO IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and vm.vendor_no <= :p_vendor_no_to ';
    ELSIF (P_VENDOR_NO_FROM IS NULL AND P_VENDOR_NO_TO IS NULL) THEN
      NULL;
    END IF;
    IF (P_RETURN_CODE_FROM IS NOT NULL AND P_RETURN_CODE_TO IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and rd.return_code between
                            					:p_return_code_from and :p_return_code_to ';
    ELSIF (P_RETURN_CODE_FROM IS NOT NULL AND P_RETURN_CODE_TO IS NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and rd.return_code >= :p_return_code_from ';
    ELSIF (P_RETURN_CODE_FROM IS NULL AND P_RETURN_CODE_TO IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and rd.return_code <= :p_return_code_to ';
    ELSIF (P_RETURN_CODE_FROM IS NULL AND P_RETURN_CODE_TO IS NULL) THEN
      NULL;
    END IF;
    IF (P_WHSE_CODE_FROM IS NOT NULL AND P_WHSE_CODE_TO IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and tp.whse_code between
                            					:p_whse_code_from and :p_whse_code_to ';
    ELSIF (P_WHSE_CODE_FROM IS NOT NULL AND P_WHSE_CODE_TO IS NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and tp.whse_code >= :p_whse_code_from ';
    ELSIF (P_WHSE_CODE_FROM IS NULL AND P_WHSE_CODE_TO IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and tp.whse_code <= :p_whse_code_to ';
    ELSIF (P_WHSE_CODE_FROM IS NULL AND P_WHSE_CODE_TO IS NULL) THEN
      NULL;
    END IF;
    CP_RETURN_DATE_FROM := to_char(P_RETURN_DATE_FROM,'DD/MM/YYYY');
    CP_RETURN_DATE_TO := to_char(P_RETURN_DATE_TO,'DD/MM/YYYY');
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    PRN_ROWS := 0;
    BEGIN
      SELECT
        ORGN_NAME
      INTO CP_ORGN_NAME
      FROM
        SY_ORGN_MST
      WHERE ORGN_CODE = P_ORGN_CODE;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION CP_ROWS_P RETURN NUMBER IS
  BEGIN
    RETURN CP_ROWS;
  END CP_ROWS_P;

  FUNCTION CP_ORGN_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_ORGN_NAME;
  END CP_ORGN_NAME_P;

END GML_POR03USR_XMLP_PKG;


/
