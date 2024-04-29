--------------------------------------------------------
--  DDL for Package Body GML_PORIRUSR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_PORIRUSR_XMLP_PKG" AS
/* $Header: PORIRUSRB.pls 120.0 2007/12/24 13:29:34 nchinnam noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    BEGIN
      SELECT
        COUNT(RECV_NO)
      INTO CP_ROWS
      FROM
        IC_ITEM_MST IM,
        PO_RECV_HDR RH,
        PO_RECV_DTL RD,
        IC_TRAN_PND TP
      WHERE IM.ITEM_ID = RD.ITEM_ID
        AND RH.RECV_ID = RD.RECV_ID
        AND RH.DELETE_MARK = 0
        AND TRUNC(RD.RECV_DATE) between TRUNC(P_RECV_DATE_FROM)
        AND TRUNC(P_RECV_DATE_TO)
        AND IM.ITEM_NO between P_ITEM_NO_FROM
        AND P_ITEM_NO_TO
        AND RD.TO_WHSE between P_TO_WHSE_FROM
        AND P_TO_WHSE_TO
        AND TP.DOC_TYPE = 'RECV'
        AND TP.DOC_ID = RH.RECV_ID
        AND TP.LINE_ID = RD.LINE_ID
        AND TP.TRANS_QTY > 0;
    CP_RECV_DATE_FROM := to_char(P_RECV_DATE_FROM ,'DD-MON-YYYY');
    CP_RECV_DATE_TO := to_char (P_RECV_DATE_TO ,'DD-MON-YYYY');
    EXCEPTION
      WHEN OTHERS THEN
        CP_ROWS := 0;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION LOT_NOFORMULA(ITEM_ID IN NUMBER
                        ,LOT_ID IN NUMBER) RETURN VARCHAR2 IS
    V_LOT VARCHAR2(32);
  BEGIN
    SELECT
      LOT_NO
    INTO V_LOT
    FROM
      IC_LOTS_MST LM
    WHERE LM.ITEM_ID = LOT_NOFORMULA.ITEM_ID
      AND LM.LOT_ID = LOT_NOFORMULA.LOT_ID;
    RETURN (V_LOT);
    RETURN NULL;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END LOT_NOFORMULA;

  FUNCTION SUBLOT_NOFORMULA(ITEM_ID IN NUMBER
                           ,LOT_ID IN NUMBER) RETURN VARCHAR2 IS
    V_SUBLOT VARCHAR2(32);
  BEGIN
    SELECT
      SUBLOT_NO
    INTO V_SUBLOT
    FROM
      IC_LOTS_MST LM
    WHERE LM.ITEM_ID = SUBLOT_NOFORMULA.ITEM_ID
      AND LM.LOT_ID = SUBLOT_NOFORMULA.LOT_ID;
    RETURN (V_SUBLOT);
    RETURN NULL;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END SUBLOT_NOFORMULA;

  FUNCTION SORTRETCFFORMULA RETURN VARCHAR2 IS
    X_SORT1 VARCHAR2(300);
    CURSOR CUR_SELECT IS
      SELECT
        MEANING
      FROM
        GEM_LOOKUP_VALUES
      WHERE LOOKUP_CODE = P_SORT_BY
        AND LOOKUP_TYPE = 'SORT_OPTIONS1_GEMMSPO';
  BEGIN
    OPEN CUR_SELECT;
    FETCH CUR_SELECT
     INTO X_SORT1;
    CLOSE CUR_SELECT;
    RETURN (X_SORT1);
  END SORTRETCFFORMULA;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    PRN_ROWS := 0;
    PARAM_WHERE_CLAUSE := ' ';
    IF (P_RECV_DATE_FROM IS NOT NULL AND P_RECV_DATE_TO IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' AND TRUNC(rd.recv_date) BETWEEN TRUNC(:p_recv_date_from) AND
                            					TRUNC(:p_recv_date_to) ';
    ELSIF (P_RECV_DATE_FROM IS NOT NULL AND P_RECV_DATE_TO IS NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' AND TRUNC(rd.recv_date) >= TRUNC(:p_recv_date_from) ';
    ELSIF (P_RECV_DATE_FROM IS NULL AND P_RECV_DATE_TO IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' AND TRUNC(rd.recv_date) <= TRUNC(:p_recv_date_to) ';
    ELSE
      NULL;
    END IF;
    IF (P_TO_WHSE_FROM IS NOT NULL AND P_TO_WHSE_TO IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and rd.to_whse between
                            					:p_to_whse_from and :p_to_whse_to ';
    ELSIF (P_TO_WHSE_FROM IS NOT NULL AND P_TO_WHSE_TO IS NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and rd.to_whse >= :p_to_whse_from ';
    ELSIF (P_TO_WHSE_FROM IS NULL AND P_TO_WHSE_TO IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and rd.to_whse <= :p_to_whse_to ';
    ELSE
      NULL;
    END IF;
    IF (P_ITEM_NO_FROM IS NOT NULL AND P_ITEM_NO_TO IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and im.item_no between
                            					:p_item_no_from and :p_item_no_to ';
    ELSIF (P_ITEM_NO_FROM IS NOT NULL AND P_ITEM_NO_TO IS NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and im.item_no >=:p_item_no_from ';
    ELSIF (P_ITEM_NO_FROM IS NULL AND P_ITEM_NO_TO IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and im.item_no <=:p_item_no_to ';
    ELSE
      NULL;
    END IF;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION CP_ROWS_P RETURN NUMBER IS
  BEGIN
    RETURN CP_ROWS;
  END CP_ROWS_P;

END GML_PORIRUSR_XMLP_PKG;


/