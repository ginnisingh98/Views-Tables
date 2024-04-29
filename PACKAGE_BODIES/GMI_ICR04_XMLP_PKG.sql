--------------------------------------------------------
--  DDL for Package Body GMI_ICR04_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_ICR04_XMLP_PKG" AS
/* $Header: ICR04B.pls 120.1 2007/12/27 12:27:15 nchinnam noship $ */
  FUNCTION YTD_USAGECFFORMULA(DOC_TYPE_1 IN VARCHAR2
                             ,REASON_CODE_1 IN VARCHAR2
                             ,ITEM_ID_1 IN NUMBER
                             ,WHSE_CODE_1 IN VARCHAR2) RETURN NUMBER IS
    COMPLETED_TRANS_QTY NUMBER(10,2) := 0.00;
    REAS_TRANS_QTY NUMBER(10,2) := 0.00;
    REASP_TRANS_QTY NUMBER(10,2) := 0.00;
    PENDING_TRANS_QTY NUMBER(10,2) := 0.00;
    YTD_USAGE NUMBER(12,2) := 0.00;
  BEGIN
    SELECT
      SUM(T.TRANS_QTY)
    INTO COMPLETED_TRANS_QTY
    FROM
      IC_TRAN_CMP T,
      PM_MATL_DTL M
    WHERE DOC_TYPE_1 in ( 'ADJI' , 'ADJR' , 'PICY' , 'PIPH' , 'REPI' , 'REPR' )
      AND REASON_CODE_1 in (
      SELECT
        REASON_CODE
      FROM
        SY_REAS_CDS
      WHERE FLOW_TYPE = 0 )
      AND T.TRANS_DATE >= FROM_DATE
      AND T.TRANS_DATE <= TO_DATE
      AND T.DOC_TYPE = 'PROD'
      AND M.LINE_TYPE = - 1
      AND T.DOC_ID = M.BATCH_ID
      AND T.LINE_ID = M.LINE_ID
      AND T.ITEM_ID = ITEM_ID_1
      AND T.WHSE_CODE = WHSE_CODE_1
      AND DOC_TYPE_INCP is null
      AND DOC_TYPE_OUTCP is null;
    IF SQL%NOTFOUND THEN
      COMPLETED_TRANS_QTY := 0;
    END IF;
    SELECT
      SUM(T.TRANS_QTY)
    INTO REAS_TRANS_QTY
    FROM
      IC_TRAN_CMP T,
      SY_REAS_CDS R
    WHERE T.TRANS_DATE >= FROM_DATE
      AND T.TRANS_DATE <= TO_DATE
      AND R.FLOW_TYPE = 0
      AND T.REASON_CODE = R.REASON_CODE
      AND T.DOC_TYPE in ( 'ADJI' , 'ADJR' , 'PICY' , 'PIPH' , 'REPI' , 'REPR' )
      AND T.ITEM_ID = ITEM_ID_1
      AND T.WHSE_CODE = WHSE_CODE_1
      AND DOC_TYPE_INCP is null
      AND DOC_TYPE_OUTCP is null
      AND R.DELETE_MARK = 0;
    IF SQL%NOTFOUND THEN
      REAS_TRANS_QTY := 0;
    END IF;
    SELECT
      SUM(T.TRANS_QTY)
    INTO PENDING_TRANS_QTY
    FROM
      IC_TRAN_PND T,
      PM_MATL_DTL M
    WHERE T.TRANS_DATE >= FROM_DATE
      AND T.TRANS_DATE <= TO_DATE
      AND T.DOC_TYPE = 'PROD'
      AND M.LINE_TYPE = - 1
      AND T.DOC_ID = M.BATCH_ID
      AND T.LINE_ID = M.LINE_ID
      AND T.ITEM_ID = ITEM_ID_1
      AND T.WHSE_CODE = WHSE_CODE_1
      AND DOC_TYPE_INCP is null
      AND DOC_TYPE_OUTCP is null
      AND T.DELETE_MARK = 0
      AND T.COMPLETED_IND = 1;
    IF SQL%NOTFOUND THEN
      PENDING_TRANS_QTY := 0;
    END IF;
    SELECT
      SUM(T.TRANS_QTY)
    INTO REASP_TRANS_QTY
    FROM
      IC_TRAN_PND T,
      SY_REAS_CDS R
    WHERE T.TRANS_DATE >= FROM_DATE
      AND T.TRANS_DATE <= TO_DATE
      AND R.FLOW_TYPE = 0
      AND T.REASON_CODE = R.REASON_CODE
      AND T.DOC_TYPE in ( 'ADJI' , 'ADJR' , 'PICY' , 'PIPH' , 'REPI' , 'REPR' )
      AND T.ITEM_ID = ITEM_ID_1
      AND T.WHSE_CODE = WHSE_CODE_1
      AND DOC_TYPE_INCP is null
      AND DOC_TYPE_OUTCP is null
      AND R.DELETE_MARK = 0
      AND T.DELETE_MARK = 0
      AND T.COMPLETED_IND = 1;
    IF SQL%NOTFOUND THEN
      REASP_TRANS_QTY := 0;
    END IF;
    YTD_USAGE := COMPLETED_TRANS_QTY + PENDING_TRANS_QTY + REAS_TRANS_QTY + REASP_TRANS_QTY;
    RETURN (YTD_USAGE);
  END YTD_USAGECFFORMULA;

  FUNCTION ACT_USAGEFORMULA(DOC_TYPE_1 IN VARCHAR2
                           ,REASON_CODE_1 IN VARCHAR2
                           ,ITEM_ID_1 IN NUMBER
                           ,WHSE_CODE_1 IN VARCHAR2) RETURN NUMBER IS
    COMPLETED_TRANS_QTY NUMBER(10,2) := 0.00;
    REAS_TRANS_QTY NUMBER(10,2) := 0.00;
    REASP_TRANS_QTY NUMBER(10,2) := 0.00;
    PENDING_TRANS_QTY NUMBER(10,2) := 0.00;
    ACTUAL_USAGE NUMBER(12,2) := 0.00;
  BEGIN
    SELECT
      SUM(T.TRANS_QTY)
    INTO COMPLETED_TRANS_QTY
    FROM
      IC_TRAN_CMP T,
      PM_MATL_DTL M
    WHERE DOC_TYPE_1 in ( 'ADJI' , 'ADJR' , 'PICY' , 'PIPH' , 'REPI' , 'REPR' )
      AND REASON_CODE_1 in (
      SELECT
        REASON_CODE
      FROM
        SY_REAS_CDS
      WHERE FLOW_TYPE = 0 )
      AND T.TRANS_DATE >= (
      SELECT
        BEGIN_DATE
      FROM
        IC_CLDR_HDR
      WHERE ORGN_CODE = T.ORGN_CODE
        AND FISCAL_YEAR = FISCAL_YEAR )
      AND T.TRANS_DATE <= TO_DATE
      AND T.DOC_TYPE = 'PROD'
      AND M.LINE_TYPE = - 1
      AND T.DOC_ID = M.BATCH_ID
      AND T.LINE_ID = M.LINE_ID
      AND T.ITEM_ID = ITEM_ID_1
      AND T.WHSE_CODE = WHSE_CODE_1
      AND DOC_TYPE_INCP is null
      AND DOC_TYPE_OUTCP is null;
    IF SQL%NOTFOUND THEN
      COMPLETED_TRANS_QTY := 0;
    END IF;
    SELECT
      SUM(T.TRANS_QTY)
    INTO REAS_TRANS_QTY
    FROM
      IC_TRAN_CMP T,
      SY_REAS_CDS R
    WHERE T.TRANS_DATE >= (
      SELECT
        BEGIN_DATE
      FROM
        IC_CLDR_HDR
      WHERE ORGN_CODE = T.ORGN_CODE
        AND FISCAL_YEAR = FISCAL_YEAR )
      AND T.TRANS_DATE <= TO_DATE
      AND R.FLOW_TYPE = 0
      AND T.REASON_CODE = R.REASON_CODE
      AND T.DOC_TYPE in ( 'ADJI' , 'ADJR' , 'PICY' , 'PIPH' , 'REPI' , 'REPR' )
      AND T.ITEM_ID = ITEM_ID_1
      AND T.WHSE_CODE = WHSE_CODE_1
      AND DOC_TYPE_INCP is null
      AND DOC_TYPE_OUTCP is null
      AND R.DELETE_MARK = 0;
    IF SQL%NOTFOUND THEN
      REAS_TRANS_QTY := 0;
    END IF;
    SELECT
      SUM(T.TRANS_QTY)
    INTO PENDING_TRANS_QTY
    FROM
      IC_TRAN_PND T,
      PM_MATL_DTL M
    WHERE T.TRANS_DATE >= (
      SELECT
        BEGIN_DATE
      FROM
        IC_CLDR_HDR
      WHERE ORGN_CODE = T.ORGN_CODE
        AND FISCAL_YEAR = FISCAL_YEAR )
      AND T.TRANS_DATE <= TO_DATE
      AND T.DOC_TYPE = 'PROD'
      AND M.LINE_TYPE = - 1
      AND T.DOC_ID = M.BATCH_ID
      AND T.LINE_ID = M.LINE_ID
      AND T.ITEM_ID = ITEM_ID_1
      AND T.WHSE_CODE = WHSE_CODE_1
      AND DOC_TYPE_INCP is null
      AND DOC_TYPE_OUTCP is null
      AND T.DELETE_MARK = 0
      AND T.COMPLETED_IND = 1;
    IF SQL%NOTFOUND THEN
      PENDING_TRANS_QTY := 0;
    END IF;
    SELECT
      SUM(T.TRANS_QTY)
    INTO REASP_TRANS_QTY
    FROM
      IC_TRAN_PND T,
      SY_REAS_CDS R
    WHERE T.TRANS_DATE >= (
      SELECT
        BEGIN_DATE
      FROM
        IC_CLDR_HDR
      WHERE ORGN_CODE = T.ORGN_CODE
        AND FISCAL_YEAR = FISCAL_YEAR )
      AND T.TRANS_DATE <= TO_DATE
      AND R.FLOW_TYPE = 0
      AND T.REASON_CODE = R.REASON_CODE
      AND T.DOC_TYPE in ( 'ADJI' , 'ADJR' , 'PICY' , 'PIPH' , 'REPI' , 'REPR' )
      AND T.ITEM_ID = ITEM_ID_1
      AND T.WHSE_CODE = WHSE_CODE_1
      AND DOC_TYPE_INCP is null
      AND DOC_TYPE_OUTCP is null
      AND R.DELETE_MARK = 0
      AND T.DELETE_MARK = 0
      AND T.COMPLETED_IND = 1;
    IF SQL%NOTFOUND THEN
      REASP_TRANS_QTY := 0;
    END IF;
    ACTUAL_USAGE := COMPLETED_TRANS_QTY + PENDING_TRANS_QTY + REAS_TRANS_QTY + REASP_TRANS_QTY;
    RETURN (ACTUAL_USAGE);
  END ACT_USAGEFORMULA;

  FUNCTION YTD_VALUECFFORMULA RETURN NUMBER IS
  BEGIN
    RETURN (0);
  END YTD_VALUECFFORMULA;

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
function R_Daily_Item_Usage(doc_type_1 varchar2,reason_code_1 varchar2) return varchar2 is
  return_flag varchar2(4);
begin
  if doc_type_1 in ('ADJI','ADJR') then
    select 'TRUE' into return_flag from dual
    where reason_code_1 in (select reason_code from sy_reas_cds where flow_type in (1,-1));
  end if;
  return('true');
exception
  when no_data_found then
    return('false');
end;
function F_Doc_Type_InCP(doc_type_1 varchar2,reason_code_1 varchar2,line_id_1 number,doc_id_1 number,quantity_1 number) return varchar2 is
return_flag varchar2(4);
begin
    select 'TRUE' into return_flag from dual
    where doc_type_1 in ('PORD','RECV','CREI','CRER','FPO','REQ')
    or    (doc_type_1 in ('TRNI','TRNR')and quantity_1 > 0)
    or    (doc_type_1 ='PROD' and line_id_1 in (select line_id from pm_matl_dtl
	   where line_type in (1,2) and batch_id = doc_id_1 and line_id=line_id_1))
    or    (doc_type_1 in ('ADJI','ADJR','PICY','PIPH','REPI','REPR') and reason_code_1
	   in (select reason_code from sy_reas_cds where flow_type=1)) ;
  return ('TRUE');
  RETURN NULL; exception when no_data_found then
  return('FALSE');
end;
function F_Doc_Type_OutCP(doc_type_1 varchar2,reason_code_1 varchar2,line_id_1 number,doc_id_1 number,quantity_1 number) return varchar2 is
return_flag varchar2(4);
return_flag1 varchar2(4);
begin
   select 'TRUE' into return_flag from dual
    where doc_type_1 in ('OPCR','OPSO','OPSP')
    or    (doc_type_1 in ('TRNI','TRNR','MTRI')and quantity_1 < 0)
    or    (doc_type_1 ='PROD' and line_id_1 in (select line_id from pm_matl_dtl
	   where line_type =-1 and batch_id = doc_id_1 and line_id=line_id_1))
    or    (doc_type_1 in ('ADJI','ADJR','PICY','PIPH','REPI','REPR') and reason_code_1
	   in (select reason_code from sy_reas_cds where flow_type=-1)) ;
   if sql%found then
  return ('TRUE');
   else
  return('FALSE');
  end if;
RETURN NULL; exception when no_data_found then
  return('FALSE');

end;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION DOC_TYPE_INCP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN DOC_TYPE_INCP;
  END DOC_TYPE_INCP_P;

  FUNCTION REASON_CODE_INCP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN REASON_CODE_INCP;
  END REASON_CODE_INCP_P;

  FUNCTION QUANTITY_INCP_P RETURN NUMBER IS
  BEGIN
    RETURN QUANTITY_INCP;
  END QUANTITY_INCP_P;

  FUNCTION DOC_TYPE_OUTCP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN DOC_TYPE_OUTCP;
  END DOC_TYPE_OUTCP_P;

  FUNCTION REASON_CODE_OUTCP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN REASON_CODE_OUTCP;
  END REASON_CODE_OUTCP_P;

  FUNCTION QUANTITY_OUTCP_P RETURN NUMBER IS
  BEGIN
    RETURN QUANTITY_OUTCP;
  END QUANTITY_OUTCP_P;

END GMI_ICR04_XMLP_PKG;


/
