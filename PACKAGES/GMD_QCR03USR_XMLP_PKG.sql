--------------------------------------------------------
--  DDL for Package GMD_QCR03USR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_QCR03USR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: QCR03USRS.pls 120.0 2007/12/24 13:09:00 krreddy noship $ */
  FROM_SAMPLE VARCHAR2(40);
  TO_SAMPLE VARCHAR2(40);
  FROM_BATCH VARCHAR2(40);
  TO_BATCH VARCHAR2(40);
  FROM_FORMULA VARCHAR2(40);
  TO_FORMULA VARCHAR2(40);
  FROM_ROUTING VARCHAR2(40);
  TO_ROUTING VARCHAR2(40);
  FROM_FORMULA_VERSION VARCHAR2(40);
  TO_FORMULA_VERSION VARCHAR2(40);
  FROM_ROUTING_VERSION VARCHAR2(40);
  TO_ROUTING_VERSION VARCHAR2(40);
  FROM_ROUTING_STEP_NO NUMBER;
  TO_ROUTING_STEP_NO NUMBER;
  FROM_OPERATION VARCHAR2(40);
  TO_OPERATION VARCHAR2(40);
  FROM_ITEM VARCHAR2(40);
  TO_ITEM VARCHAR2(40);
  FROM_RESULT_DATE DATE;
  TO_RESULT_DATE DATE;
  INCLUDE VARCHAR2(40);
  PRINT_CONDITION VARCHAR2(30);
  P_ORGN VARCHAR2(40);
  SY_ALL VARCHAR2(3);
  NONBLOCKSQL VARCHAR2(3);
  FROM_LOTNO VARCHAR2(32);
  TO_LOTNO VARCHAR2(32);
  FROM_SUBLOT VARCHAR2(40);
  TO_SUBLOT VARCHAR2(32);
  P_ORGANIZATION_ID VARCHAR2(40);
  P_CONC_REQUEST_ID NUMBER;
  ASSAY_TYPECP VARCHAR2(1);
  FINAL_CP VARCHAR2(32767);
  ACCEPT_CP VARCHAR2(32767);
  SAMPLECP VARCHAR2(300);
  --BATCHCP VARCHAR2(300);
  BATCHCP VARCHAR2(300):=' ';
  --FORMULACP VARCHAR2(300);
  FORMULACP VARCHAR2(300):=' ';
  --FORMULA_VERSCP VARCHAR2(300);
  FORMULA_VERSCP VARCHAR2(300):= ' ';
  --ROUTINGCP VARCHAR2(300);
  ROUTINGCP VARCHAR2(300):=' ';
  --ROUTING_VERSCP VARCHAR2(300);
  ROUTING_VERSCP VARCHAR2(300):= ' ';
  --ITEMCP VARCHAR2(300);
  ITEMCP VARCHAR2(300):=  ' ';
  --DATE1CP VARCHAR2(300);
  DATE1CP VARCHAR2(300):=' ';
  OPRNNOCP VARCHAR2(100);
  --OPRNTBLCP VARCHAR2(100);
  OPRNTBLCP VARCHAR2(100):= ' ';
  --OPRNCP VARCHAR2(300);
  OPRNCP VARCHAR2(300):=' ';
  ROUTSTEPCP VARCHAR2(100);
  ROUTSTEPTBLCP VARCHAR2(100);
  --ROUT_STEPNOCP VARCHAR2(300);
  ROUT_STEPNOCP VARCHAR2(300):= ' ';
  ORDERCP VARCHAR2(100);
  --FINAL1CP VARCHAR2(200);
  FINAL1CP VARCHAR2(200):= ' ';
  FROM_ITEMCP VARCHAR2(32);
  TO_ITEMCP VARCHAR2(32);
  FROM_SAMPLECP VARCHAR2(32);
  TO_SAMPLECP VARCHAR2(32);
  FROM_RSLT_DTCP VARCHAR2(11);
  TO_RSLT_DTCP VARCHAR2(11);
  FROM_FORMULACP VARCHAR2(32);
  TO_FORMULACP VARCHAR2(32);
  FROM_BATCHCP VARCHAR2(32);
  TO_BATCHCP VARCHAR2(32);
  FROM_OPERATIONCP VARCHAR2(16);
  TO_OPERATIONCP VARCHAR2(16);
  FROM_ROUTINGCP VARCHAR2(32);
  TO_ROUTINGCP VARCHAR2(32);
  FROM_ROUTING_STEP_NOCP VARCHAR2(5);
  TO_ROUTING_STEP_NOCP VARCHAR2(5);
  FROM_ROUTING_VERSIONCP VARCHAR2(5);
  TO_ROUTING_VERSIONCP VARCHAR2(5);
  FROM_FORMULA_VERSIONCP VARCHAR2(5);
  TO_FORMULA_VERSIONCP VARCHAR2(5);
  --LOTNOCP VARCHAR2(500);
  LOTNOCP VARCHAR2(500):=' ';
  FROM_LOTNOCP VARCHAR2(32);
  TO_LOTNOCP VARCHAR2(32);
  ORGCP VARCHAR2(20);
  FUNCTION SAMPLECFFORMULA RETURN VARCHAR2;
  FUNCTION BATCHCFFORMULA RETURN VARCHAR2;
  FUNCTION FORMULACFFORMULA RETURN VARCHAR2;
  FUNCTION FORMULA_VERSCFFORMULA RETURN VARCHAR2;
  FUNCTION ROUTINGCFFORMULA RETURN VARCHAR2;
  FUNCTION ROUTING_VERSCFFORMULA RETURN VARCHAR2;
  FUNCTION ITEMCFFORMULA RETURN VARCHAR2;
  FUNCTION DATE1CFFORMULA RETURN VARCHAR2;
  FUNCTION OPRNCFFORMULA RETURN VARCHAR2;
  FUNCTION OPRNCFFORMULA0032 RETURN VARCHAR2;
  FUNCTION OPRNTBLCFFORMULA RETURN VARCHAR2;
  FUNCTION ROUTSTEPCFFORMULA RETURN VARCHAR2;
  FUNCTION ROUTSTEPTBLCFFORMULA RETURN VARCHAR2;
  FUNCTION ROUT_STEPNOCFFORMULA RETURN VARCHAR2;
  FUNCTION ORDERCFFORMULA RETURN VARCHAR2;
  FUNCTION FINAL1CFFORMULA RETURN VARCHAR2;
  FUNCTION ASSAY_DESCCFFORMULA(ASSAY_CODE IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION TEXTCFFORMULA(TEXT_SPEC IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION TARGETCFFORMULA(TEXT_SPEC IN VARCHAR2
                          ,TARGET_SPEC IN NUMBER
                          ,TEST_TYPE IN VARCHAR2
                          ,PRECISION IN NUMBER) RETURN CHAR;
  FUNCTION QCUNIT_CODECFFORMULA(QC_SPEC_ID IN NUMBER
                               ,ASSAY_CODE IN VARCHAR2
                               ,QCASSY_TYP_ID IN NUMBER) RETURN VARCHAR2;
  FUNCTION MIN_SPECCFFORMULA(MIN_CHAR IN VARCHAR2
                            ,MIN_SPEC IN NUMBER
                            ,TEST_TYPE IN VARCHAR2
                            ,PRECISION IN NUMBER) RETURN CHAR;
  FUNCTION MAX_SPECCFFORMULA(MAX_CHAR IN VARCHAR2
                            ,MAX_SPEC IN NUMBER
                            ,TEST_TYPE IN VARCHAR2
                            ,PRECISION IN NUMBER) RETURN CHAR;
  --FUNCTION FROM_DATECFFORMULA(SAMPLE_NO IN VARCHAR2) RETURN DATE;
  FUNCTION FROM_DATECFFORMULA(SAMPLE_NO_V IN VARCHAR2) RETURN DATE;
  --FUNCTION TO_DATECFFORMULA(SAMPLE_NO IN VARCHAR2) RETURN DATE;
  FUNCTION TO_DATECFFORMULA(SAMPLE_NO_V IN VARCHAR2) RETURN DATE;
  FUNCTION TEXTARRAYCFFORMULA(TEXTCODECF IN NUMBER) RETURN VARCHAR2;
  FUNCTION TEXT_CODECFFORMULA(QC_SPEC_ID IN NUMBER) RETURN NUMBER;
  --FUNCTION TEXTARRAY2CFFORMULA(TEXT_CODE IN NUMBER) RETURN VARCHAR2;
  FUNCTION TEXTARRAY2CFFORMULA(TEXT_CODE_V IN NUMBER) RETURN VARCHAR2;
 /* FUNCTION STEPCFFORMULA(ROUTING_ID IN NUMBER
                        ,ROUTINGSTEP_ID IN NUMBER) RETURN NUMBER;*/
 FUNCTION STEPCFFORMULA(ROUTING_ID_V IN NUMBER
                        ,ROUTINGSTEP_ID_V IN NUMBER) RETURN NUMBER;
  --FUNCTION OPERATIONCFFORMULA(OPRN_ID IN NUMBER) RETURN VARCHAR2;
  FUNCTION OPERATIONCFFORMULA(OPRN_ID_V IN NUMBER) RETURN VARCHAR2;
  FUNCTION FROM_ITEMCFFORMULA RETURN VARCHAR2;
  FUNCTION TO_ITEMCFFORMULA RETURN VARCHAR2;
  FUNCTION FROM_SAMPLECFFORMULA RETURN VARCHAR2;
  FUNCTION TO_SAMPLECFFORMULA RETURN VARCHAR2;
  FUNCTION FROM_RSLT_DTCFFORMULA RETURN VARCHAR2;
  FUNCTION TO_RSLT_DTCFFORMULA RETURN VARCHAR2;
  FUNCTION FROM_FORMULACFFORMULA RETURN VARCHAR2;
  FUNCTION TO_FORMULACFFORMULA RETURN VARCHAR2;
  FUNCTION FROM_BATCHCFFORMULA RETURN VARCHAR2;
  FUNCTION TO_BATCHCFFORMULA RETURN VARCHAR2;
  FUNCTION FROM_OPERATIONCFFORMULA RETURN VARCHAR2;
  FUNCTION TO_OPERATIONCFFORMULA RETURN VARCHAR2;
  FUNCTION FROM_ROUTINGCFFORMULA RETURN VARCHAR2;
  FUNCTION TO_ROUTINGCFFORMULA RETURN VARCHAR2;
  FUNCTION FROM_ROUTING_STEPNOCFFORMULA RETURN VARCHAR2;
  FUNCTION TO_ROUTING_STEP_NOCFFORMULA RETURN VARCHAR2;
  FUNCTION FROM_ROUTING_VERSIONCFFORMULA RETURN VARCHAR2;
  FUNCTION TO_ROUTING_VERSIONCFFORMULA RETURN VARCHAR2;
  FUNCTION FROM_FORMULA_VERSIONCFFORMULA RETURN VARCHAR2;
  FUNCTION TO_FORMULA_VERSIONCFFORMULA RETURN VARCHAR2;
  FUNCTION TEXTCODERSLTCFFORMULA(QC_RESULT_ID IN NUMBER
                                ,ASSAY_CODE IN VARCHAR2) RETURN NUMBER;
  FUNCTION INCLUDE_TEXTCFFORMULA RETURN VARCHAR2;
  FUNCTION PRINT_TEXTCFFORMULA RETURN VARCHAR2;
  FUNCTION BEFOREREPORT RETURN BOOLEAN;
  FUNCTION ACCEPT_CFFORMULA(ACCEPT_ANYWAY IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION FINAL_CFFORMULA(FINAL_MARK IN VARCHAR2) RETURN VARCHAR2 ;
  PROCEDURE GMD_QCR03USR_XMLP_PKG_HEADER;
  FUNCTION FROM_LOTNOCFFORMULA RETURN VARCHAR2;
  FUNCTION LOTCFFORMULA RETURN VARCHAR2;
  FUNCTION TO_LOTNOCFFORMULA RETURN VARCHAR2;
  FUNCTION BEFOREPFORM RETURN BOOLEAN;
  FUNCTION AFTERPFORM RETURN BOOLEAN;
  --FUNCTION OPRN_VERSCFFORMULA0017(OPRN_ID IN NUMBER) RETURN NUMBER;
  FUNCTION OPRN_VERSCFFORMULA0017(OPRN_ID_V IN NUMBER) RETURN NUMBER;
  FUNCTION ORDERCPFORMULA RETURN CHAR;
  FUNCTION ROUTSTEPCPFORMULA RETURN CHAR;
  FUNCTION ROUT_STEPNOCPFORMULA RETURN CHAR;
  FUNCTION ASSAY_DISPLAYCFFORMULA(ASSAY_CODE IN VARCHAR2
                                 ,QCASSY_TYP_ID IN NUMBER
                                 ,TARGETCF IN VARCHAR2) RETURN CHAR;
  FUNCTION ASSAYMIN_DISPCFFORMULA(QCASSY_TYP_ID IN NUMBER
                                 ,MIN_SPECCF IN VARCHAR2) RETURN CHAR;
  FUNCTION ASSAYMAX_DISPCFFORMULA(QCASSY_TYP_ID IN NUMBER
                                 ,MAX_SPECCF IN VARCHAR2) RETURN CHAR;
  FUNCTION RESULT_DISPCFFORMULA(QCASSY_TYP_ID IN NUMBER
                               ,NUM_RESULT IN NUMBER) RETURN CHAR;
  FUNCTION MAX_CHARCFFORMULA(MAX_CHAR IN VARCHAR2) RETURN CHAR;
  FUNCTION MIN_CHARCFFORMULA(MIN_CHAR IN VARCHAR2) RETURN CHAR;
  FUNCTION RESULT_NUMCFFORMULA(TEXT_RESULT IN VARCHAR2
                              ,NUM_RESULT IN NUMBER
                              ,TEST_TYPE IN VARCHAR2
                              ,PRECISION IN NUMBER) RETURN CHAR;
  FUNCTION ORGCFFORMULA RETURN CHAR;
  FUNCTION AFTERREPORT RETURN BOOLEAN;
  FUNCTION ASSAY_TYPECP_P RETURN VARCHAR2;
  FUNCTION SAMPLECP_P RETURN VARCHAR2;
  FUNCTION BATCHCP_P RETURN VARCHAR2;
  FUNCTION FORMULACP_P RETURN VARCHAR2;
  FUNCTION FORMULA_VERSCP_P RETURN VARCHAR2;
  FUNCTION ROUTINGCP_P RETURN VARCHAR2;
  FUNCTION ROUTING_VERSCP_P RETURN VARCHAR2;
  FUNCTION ITEMCP_P RETURN VARCHAR2;
  FUNCTION DATE1CP_P RETURN VARCHAR2;
  FUNCTION OPRNNOCP_P RETURN VARCHAR2;
  FUNCTION OPRNTBLCP_P RETURN VARCHAR2;
  FUNCTION OPRNCP_P RETURN VARCHAR2;
  FUNCTION ROUTSTEPCP_P RETURN VARCHAR2;
  FUNCTION ROUTSTEPTBLCP_P RETURN VARCHAR2;
  FUNCTION ROUT_STEPNOCP_P RETURN VARCHAR2;
  FUNCTION ORDERCP_P RETURN VARCHAR2;
  FUNCTION FINAL1CP_P RETURN VARCHAR2;
  FUNCTION FROM_ITEMCP_P RETURN VARCHAR2;
  FUNCTION TO_ITEMCP_P RETURN VARCHAR2;
  FUNCTION FROM_SAMPLECP_P RETURN VARCHAR2;
  FUNCTION TO_SAMPLECP_P RETURN VARCHAR2;
  FUNCTION FROM_RSLT_DTCP_P RETURN VARCHAR2;
  FUNCTION TO_RSLT_DTCP_P RETURN VARCHAR2;
  FUNCTION FROM_FORMULACP_P RETURN VARCHAR2;
  FUNCTION TO_FORMULACP_P RETURN VARCHAR2;
  FUNCTION FROM_BATCHCP_P RETURN VARCHAR2;
  FUNCTION TO_BATCHCP_P RETURN VARCHAR2;
  FUNCTION FROM_OPERATIONCP_P RETURN VARCHAR2;
  FUNCTION TO_OPERATIONCP_P RETURN VARCHAR2;
  FUNCTION FROM_ROUTINGCP_P RETURN VARCHAR2;
  FUNCTION TO_ROUTINGCP_P RETURN VARCHAR2;
  FUNCTION FROM_ROUTING_STEP_NOCP_P RETURN VARCHAR2;
  FUNCTION TO_ROUTING_STEP_NOCP_P RETURN VARCHAR2;
  FUNCTION FROM_ROUTING_VERSIONCP_P RETURN VARCHAR2;
  FUNCTION TO_ROUTING_VERSIONCP_P RETURN VARCHAR2;
  FUNCTION FROM_FORMULA_VERSIONCP_P RETURN VARCHAR2;
  FUNCTION TO_FORMULA_VERSIONCP_P RETURN VARCHAR2;
  FUNCTION LOTNOCP_P RETURN VARCHAR2;
  FUNCTION FROM_LOTNOCP_P RETURN VARCHAR2;
  FUNCTION TO_LOTNOCP_P RETURN VARCHAR2;
  FUNCTION ORGCP_P RETURN VARCHAR2;
END GMD_QCR03USR_XMLP_PKG;


/