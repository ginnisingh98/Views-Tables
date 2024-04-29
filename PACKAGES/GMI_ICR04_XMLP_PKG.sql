--------------------------------------------------------
--  DDL for Package GMI_ICR04_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_ICR04_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: ICR04S.pls 120.0 2007/12/24 13:17:30 nchinnam noship $ */
  FISCAL_YEAR VARCHAR2(4);

  COST_METHOD VARCHAR2(4);

  FROM_ITEM VARCHAR2(32);

  TO_ITEM VARCHAR2(32);

  FROM_WHSE VARCHAR2(4);

  TO_WHSE VARCHAR2(4);

  FROM_DATE DATE;

  TO_DATE DATE;

  P_ORGN VARCHAR2(4);

  NONBLOCKSQL VARCHAR2(3);

  P_CONC_REQUEST_ID NUMBER;

  DOC_TYPE_INCP VARCHAR2(4) := 'NONE';

  REASON_CODE_INCP VARCHAR2(4) := 'NONE';

  QUANTITY_INCP NUMBER := 0.00;

  DOC_TYPE_OUTCP VARCHAR2(4) := 'NONE';

  REASON_CODE_OUTCP VARCHAR2(4) := 'NONE';

  QUANTITY_OUTCP NUMBER := 0.00;

  FUNCTION YTD_USAGECFFORMULA(DOC_TYPE_1 IN VARCHAR2
                             ,REASON_CODE_1 IN VARCHAR2
                             ,ITEM_ID_1 IN NUMBER
                             ,WHSE_CODE_1 IN VARCHAR2) RETURN NUMBER;
function R_Daily_Item_Usage(doc_type_1 varchar2,reason_code_1 varchar2) return varchar2;
function F_Doc_Type_InCP(doc_type_1 varchar2,reason_code_1 varchar2,line_id_1 number,doc_id_1 number,quantity_1 number)return varchar2;
function F_Doc_Type_OutCP(doc_type_1 varchar2,reason_code_1 varchar2,line_id_1 number,doc_id_1 number,quantity_1 number) return varchar2;
  FUNCTION ACT_USAGEFORMULA(DOC_TYPE_1 IN VARCHAR2
                           ,REASON_CODE_1 IN VARCHAR2
                           ,ITEM_ID_1 IN NUMBER
                           ,WHSE_CODE_1 IN VARCHAR2) RETURN NUMBER;

  FUNCTION YTD_VALUECFFORMULA RETURN NUMBER;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  PROCEDURE HEADER;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION DOC_TYPE_INCP_P RETURN VARCHAR2;

  FUNCTION REASON_CODE_INCP_P RETURN VARCHAR2;

  FUNCTION QUANTITY_INCP_P RETURN NUMBER;

  FUNCTION DOC_TYPE_OUTCP_P RETURN VARCHAR2;

  FUNCTION REASON_CODE_OUTCP_P RETURN VARCHAR2;

  FUNCTION QUANTITY_OUTCP_P RETURN NUMBER;

END GMI_ICR04_XMLP_PKG;


/
