--------------------------------------------------------
--  DDL for Package GML_ORAKRP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_ORAKRP_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: ORAKRPS.pls 120.0 2007/12/24 13:22:29 nchinnam noship $ */
  ORGN_CODE VARCHAR2(4);

  P_SORT_ORDER VARCHAR2(40);

  P_DEFAULT_ORGN VARCHAR2(4);

  FROM_ORDER_NUMBER VARCHAR2(32);

  LFROM_ORDER_NUMBER VARCHAR2(32);

  TO_ORDER_NUMBER VARCHAR2(32);

  LTO_ORDER_NUMBER VARCHAR2(32);

  FROM_ORDER_DATE DATE;
  FROM_ORDER_DATE_1 varchar2(11);

  TO_ORDER_DATE DATE;
  TO_ORDER_DATE_1 varchar2(11);

  FROM_SOLD_TO VARCHAR2(32);

  LFROM_SOLD_TO VARCHAR2(32);

  TO_SOLD_TO VARCHAR2(32);

  LTO_SOLD_TO VARCHAR2(32);

  FROM_BILL_TO VARCHAR2(32);

  LFROM_BILL_TO VARCHAR2(32);

  TO_BILL_TO VARCHAR2(32);

  LTO_BILL_TO VARCHAR2(32);

  EXCLUDE_PRINTED VARCHAR2(4);

  EXCLUDE_ON_HOLD VARCHAR2(4);

  SORT_1 VARCHAR2(40);

  SORT_3 VARCHAR2(32767);

  SORT_2 VARCHAR2(32767);

  DEFAULT_USER NUMBER;

  P_BILL_ADDRESS1 VARCHAR2(80);

  P_CONC_REQUEST_ID NUMBER;

  CHARGE_DESCCP VARCHAR2(25);

  CHARGE_AMTCP NUMBER;

  ORGN_NAME_CP VARCHAR2(100);

  ORDER_NUMBERCP VARCHAR2(100):=' ';

  ORDER_DATECP VARCHAR2(100);

  SOLD_TOCP VARCHAR2(100):=' ';

  BILL_TOCP VARCHAR2(100):=' ';

  EXCLUDE_PRINTEDCP VARCHAR2(100) :=' ';

  EXCLUDE_ON_HOLDCP VARCHAR2(100):=' ';

  SORT1_CP VARCHAR2(100);

  SORT2_CP VARCHAR2(100):=' ' ;

  SORT3_CP VARCHAR2(100):=' ' ;

  CP_ORGN_NAME VARCHAR2(100);

  CP_USER VARCHAR2(15);

  FUNCTION LCHG_DESCCFFORMULA(LINE_ID IN NUMBER
                             ,ORDER_ID IN NUMBER) RETURN VARCHAR2;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION NET_WTCFFORMULA(ORDER_UM1 IN VARCHAR2
                          ,SHIPWT_UM IN VARCHAR2
                          ,SHIP_QTY1 IN NUMBER
                          ,ITEM_ID IN NUMBER
                          ,ITEM_UM IN VARCHAR2) RETURN NUMBER;

  FUNCTION EXTENDED_AMT_CFFORMULA(ORDER_QTY1 IN NUMBER
                                 ,NET_PRICE IN NUMBER) RETURN NUMBER;

  FUNCTION EXTENDED_AMOUNTCFFORMULA(LINE_ID IN NUMBER
                                   ,ORDER_ID IN NUMBER
                                   ,EXTENDED_PRICE IN NUMBER) RETURN NUMBER;

  FUNCTION ORDER_NUMBERCFFORMULA RETURN VARCHAR2;

  FUNCTION ORDER_DATECFFORMULA RETURN VARCHAR2;

  FUNCTION SOLD_TOCFFORMULA RETURN VARCHAR2;

  FUNCTION BILL_TOCFFORMULA RETURN VARCHAR2;

  FUNCTION EXCLUDE_PRINTEDCFFORMULA RETURN VARCHAR2;

  FUNCTION EXCLUDED_ON_HOLDCFFORMULA RETURN VARCHAR2;

  FUNCTION SORT1_CFFORMULA RETURN VARCHAR2;

  FUNCTION SORT2_CFFORMULA RETURN VARCHAR2;

  FUNCTION TOT_ORDERCFFORMULA(TOTAL_E_PRICECS IN NUMBER
                             ,TOT_EXTENDED_AMTCS IN NUMBER) RETURN NUMBER;

  FUNCTION SORT3_CFFORMULA RETURN VARCHAR2;

  FUNCTION SORT3_CPFORMULA(SORT3_CF IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION TERMS_CODEFORMULA(TERMS IN VARCHAR2) RETURN VARCHAR2;

  PROCEDURE OROAKRP_HEADER;

  FUNCTION UDATEFORMULA(ORDER_TYPE in Number, O_NO in varchar2, RELEASE_NO in number) RETURN VARCHAR2;

  FUNCTION LINE_CHARGESCFFORMULA(ORDER_ID IN NUMBER
                                ,LINE_ID IN NUMBER) RETURN NUMBER;

  FUNCTION LINEDISCOUNTS_CFFORMULA(ORDER_ID IN NUMBER
                                  ,LINE_ID IN NUMBER) RETURN NUMBER;

  FUNCTION HEAD_CHARGESCFFORMULA(ORDER_ID IN NUMBER) RETURN NUMBER;

  FUNCTION HEAD_DISCOUNTSCFFORMULA(ORDER_ID IN NUMBER) RETURN NUMBER;

  FUNCTION ORD_TOT_FORMULA(ORDER_ID IN NUMBER) RETURN NUMBER;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION CHARGE_DESCCP_P RETURN VARCHAR2;

  FUNCTION CHARGE_AMTCP_P RETURN NUMBER;

  FUNCTION ORGN_NAME_CP_P RETURN VARCHAR2;

  FUNCTION ORDER_NUMBERCP_P RETURN VARCHAR2;

  FUNCTION ORDER_DATECP_P RETURN VARCHAR2;

  FUNCTION SOLD_TOCP_P RETURN VARCHAR2;

  FUNCTION BILL_TOCP_P RETURN VARCHAR2;

  FUNCTION EXCLUDE_PRINTEDCP_P RETURN VARCHAR2;

  FUNCTION EXCLUDE_ON_HOLDCP_P RETURN VARCHAR2;

  FUNCTION SORT1_CP_P RETURN VARCHAR2;

  FUNCTION SORT2_CP_P RETURN VARCHAR2;

  FUNCTION SORT3_CP_P RETURN VARCHAR2;

  FUNCTION CP_ORGN_NAME_P RETURN VARCHAR2;

  FUNCTION CP_USER_P RETURN VARCHAR2;

END GML_ORAKRP_XMLP_PKG;


/