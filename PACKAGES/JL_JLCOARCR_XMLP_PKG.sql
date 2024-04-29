--------------------------------------------------------
--  DDL for Package JL_JLCOARCR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_JLCOARCR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: JLCOARCRS.pls 120.1 2007/12/25 16:43:46 dwkrishn noship $ */
  P_CONC_REQUEST_ID NUMBER := 0;
  P_CUSTOMER_NUMBER_FROM VARCHAR2(40);
  P_CUSTOMER_NUMBER_TO VARCHAR2(40);
  P_CUSTOMER_NAME_FROM VARCHAR2(40);
  P_CUSTOMER_NAME_TO VARCHAR2(40);
  P_RECEIPT_NUMBER_FROM VARCHAR2(40);
  P_RECEIPT_NUMBER_TO VARCHAR2(40);
  P_RECEIPT_DATE_FROM DATE;
  P_RECEIPT_DATE_TO DATE;
  P_PAYMENT_METHOD VARCHAR2(40);
  P_PAYMENT_MODE VARCHAR2(40);
  P_THIRD_PARTY_ID_FROM VARCHAR2(40);
  P_THIRD_PARTY_ID_TO VARCHAR2(40);
  P_SET_OF_BOOKS_ID NUMBER;
  P_LEGAL_ENTITY_ID NUMBER;
  C_FUNC_CURRENCY VARCHAR2(25);
  C_PRECISION NUMBER;
  C_STRUCT_NUM NUMBER;
  C_SOB_NAME VARCHAR2(100);
  C_REPORT_START_DATE DATE;
  C_REPORT_RUN_TIME VARCHAR2(8);
  VLOCATION_ID NUMBER;
  COMPANY_NAME VARCHAR2(60);
  NIT_NUMBER VARCHAR2(15);
  DIGIT_VERIF VARCHAR2(2);
  VADDRESS1 VARCHAR2(120);
  VADDRESS2 VARCHAR2(120);
  VREGION VARCHAR2(60);
  VTOWN_CITY VARCHAR2(60);
  VADDRESS3 VARCHAR2(120);
  VCOUNTRY VARCHAR2(60);
  PROCEDURE GL_GET_SET_OF_BOOKS_INFO(SOBID IN NUMBER
                                    ,COAID OUT NOCOPY NUMBER
                                    ,SOBNAME OUT NOCOPY VARCHAR2
                                    ,FUNC_CURR OUT NOCOPY VARCHAR2
                                    ,ERRBUF OUT NOCOPY VARCHAR2);
				    PROCEDURE GET_INFO(CURRENCY_CODE IN VARCHAR2
                    ,PRECISION OUT NOCOPY NUMBER
                    ,EXT_PRECISION OUT NOCOPY NUMBER
                    ,MIN_ACCT_UNIT OUT NOCOPY NUMBER);
  FUNCTION BEFOREREPORT RETURN BOOLEAN;
  FUNCTION AFTERREPORT RETURN BOOLEAN;
  FUNCTION CONVERT_NUMBER2(SEGMENT IN NUMBER) RETURN VARCHAR2;
  FUNCTION CONVERT_NUMBER(IN_NUMERAL IN INTEGER := 0) RETURN VARCHAR2;
  FUNCTION GET_WORD_VALUE(P_AMOUNT IN NUMBER
                         ,P_UNIT_SINGULAR IN VARCHAR2
                         ,P_UNIT_PLURAL IN VARCHAR2
                         ,P_SUB_UNIT_SINGULAR IN VARCHAR2
                         ,P_SUB_UNIT_PLURAL IN VARCHAR2
                         ,P_UNIT_RATIO IN NUMBER) RETURN VARCHAR2;
  FUNCTION PRECISION(CUR_CODE IN VARCHAR2) RETURN NUMBER;
  FUNCTION CF_INVOICE_NUMFORMULA(INVOICE_NUMBER IN VARCHAR2) RETURN CHAR;
  FUNCTION C_FUNC_CURRENCY_P RETURN VARCHAR2;
  FUNCTION C_PRECISION_P RETURN NUMBER;
  FUNCTION C_STRUCT_NUM_P RETURN NUMBER;
  FUNCTION C_SOB_NAME_P RETURN VARCHAR2;
  FUNCTION C_REPORT_START_DATE_P RETURN DATE;
  FUNCTION C_REPORT_RUN_TIME_P RETURN VARCHAR2;
  FUNCTION VLOCATION_ID_P RETURN NUMBER;
  FUNCTION COMPANY_NAME_P RETURN VARCHAR2;
  FUNCTION NIT_NUMBER_P RETURN VARCHAR2;
  FUNCTION DIGIT_VERIF_P RETURN VARCHAR2;
  FUNCTION VADDRESS1_P RETURN VARCHAR2;
  FUNCTION VADDRESS2_P RETURN VARCHAR2;
  FUNCTION VREGION_P RETURN VARCHAR2;
  FUNCTION VTOWN_CITY_P RETURN VARCHAR2;
  FUNCTION VADDRESS3_P RETURN VARCHAR2;
  FUNCTION VCOUNTRY_P RETURN VARCHAR2;
 /* PROCEDURE JG_GET_SET_OF_BOOKS_INFO(SOBID IN NUMBER
                                    ,COAID OUT NOCOPY NUMBER
                                    ,SOBNAME OUT NOCOPY VARCHAR2
                                    ,FUNC_CURR OUT NOCOPY VARCHAR2
                                    ,ERRBUF OUT NOCOPY VARCHAR2);
  PROCEDURE JG_GET_BUD_OR_ENC_NAME(ACTUAL_TYPE IN VARCHAR2
                                  ,TYPE_ID IN NUMBER
                                  ,NAME OUT NOCOPY VARCHAR2
                                  ,ERRBUF OUT NOCOPY VARCHAR2);
  PROCEDURE JG_GET_LOOKUP_VALUE(LMODE IN VARCHAR2
                               ,CODE IN VARCHAR2
                               ,TYPE IN VARCHAR2
                               ,VALUE OUT NOCOPY VARCHAR2
                               ,ERRBUF OUT NOCOPY VARCHAR2);
  PROCEDURE JG_GET_FIRST_PERIOD(APP_ID IN NUMBER
                               ,TSET_OF_BOOKS_ID IN NUMBER
                               ,TPERIOD_NAME IN VARCHAR2
                               ,TFIRST_PERIOD OUT NOCOPY VARCHAR2
                               ,ERRBUF OUT NOCOPY VARCHAR2);
  PROCEDURE JG_GET_FIRST_PERIOD_OF_QUARTER(APP_ID IN NUMBER
                                          ,TSET_OF_BOOKS_ID IN NUMBER
                                          ,TPERIOD_NAME IN VARCHAR2
                                          ,TFIRST_PERIOD OUT NOCOPY VARCHAR2
                                          ,ERRBUF OUT NOCOPY VARCHAR2);
  FUNCTION JG_FORMAT_CURR_AMT(IN_PRECISION IN NUMBER
                             ,IN_AMOUNT_DISP IN VARCHAR2) RETURN VARCHAR2;
  PROCEDURE GL_GET_PERIOD_DATES(TSET_OF_BOOKS_ID IN NUMBER
                               ,TPERIOD_NAME IN VARCHAR2
                               ,TSTART_DATE OUT NOCOPY DATE
                               ,TEND_DATE OUT NOCOPY DATE
                               ,ERRBUF OUT NOCOPY VARCHAR2);
  PROCEDURE GL_GET_BUD_OR_ENC_NAME(ACTUAL_TYPE IN VARCHAR2
                                  ,TYPE_ID IN NUMBER
                                  ,NAME OUT NOCOPY VARCHAR2
                                  ,ERRBUF OUT NOCOPY VARCHAR2);
  PROCEDURE GL_GET_LOOKUP_VALUE(LMODE IN VARCHAR2
                               ,CODE IN VARCHAR2
                               ,TYPE IN VARCHAR2
                               ,VALUE OUT NOCOPY VARCHAR2
                               ,ERRBUF OUT NOCOPY VARCHAR2);
  PROCEDURE GL_GET_FIRST_PERIOD(TSET_OF_BOOKS_ID IN NUMBER
                               ,TPERIOD_NAME IN VARCHAR2
                               ,TFIRST_PERIOD OUT NOCOPY VARCHAR2
                               ,ERRBUF OUT NOCOPY VARCHAR2);
  PROCEDURE GL_GET_FIRST_PERIOD_OF_QUARTER(TSET_OF_BOOKS_ID IN NUMBER
                                          ,TPERIOD_NAME IN VARCHAR2
                                          ,TFIRST_PERIOD OUT NOCOPY VARCHAR2
                                          ,ERRBUF OUT NOCOPY VARCHAR2);
  PROCEDURE GL_GET_CONSOLIDATION_INFO(CONS_ID IN NUMBER
                                     ,CONS_NAME OUT NOCOPY VARCHAR2
                                     ,METHOD OUT NOCOPY VARCHAR2
                                     ,CURR_CODE OUT NOCOPY VARCHAR2
                                     ,FROM_SOBID OUT NOCOPY NUMBER
                                     ,TO_SOBID OUT NOCOPY NUMBER
                                     ,DESCRIPTION OUT NOCOPY VARCHAR2
                                     ,START_DATE OUT NOCOPY DATE
                                     ,END_DATE OUT NOCOPY DATE
                                     ,ERRBUF OUT NOCOPY VARCHAR2);
  FUNCTION GET_FORMAT_MASK(CURRENCY_CODE IN VARCHAR2
                          ,FIELD_LENGTH IN NUMBER) RETURN VARCHAR2;
  FUNCTION SAFE_GET_FORMAT_MASK(CURRENCY_CODE IN VARCHAR2
                               ,FIELD_LENGTH IN NUMBER) RETURN VARCHAR2;
  PROCEDURE BUILD_FORMAT_MASK(FORMAT_MASK OUT NOCOPY VARCHAR2
                             ,FIELD_LENGTH IN NUMBER
                             ,PRECISION IN NUMBER
                             ,MIN_ACCT_UNIT IN NUMBER
                             ,DISP_GRP_SEP IN BOOLEAN
                             ,NEG_FORMAT IN VARCHAR2
                             ,POS_FORMAT IN VARCHAR2);
  PROCEDURE SAFE_BUILD_FORMAT_MASK(FORMAT_MASK OUT NOCOPY VARCHAR2
                                  ,FIELD_LENGTH IN NUMBER
                                  ,PRECISION IN NUMBER
                                  ,MIN_ACCT_UNIT IN NUMBER
                                  ,DISP_GRP_SEP IN BOOLEAN
                                  ,NEG_FORMAT IN VARCHAR2
                                  ,POS_FORMAT IN VARCHAR2);
  PROCEDURE SET_NAME(APPLICATION IN VARCHAR2
                    ,NAME IN VARCHAR2);
  PROCEDURE SET_TOKEN(TOKEN IN VARCHAR2
                     ,VALUE IN VARCHAR2
                     ,TRANSLATE IN BOOLEAN);
  PROCEDURE RETRIEVE(MSGOUT OUT NOCOPY VARCHAR2);
  PROCEDURE CLEAR;
  FUNCTION GET_STRING(APPIN IN VARCHAR2
                     ,NAMEIN IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION GET_NUMBER(APPIN IN VARCHAR2
                     ,NAMEIN IN VARCHAR2) RETURN NUMBER;
  FUNCTION GET RETURN VARCHAR2;
  FUNCTION GET_ENCODED RETURN VARCHAR2;
  PROCEDURE PARSE_ENCODED(ENCODED_MESSAGE IN VARCHAR2
                         ,APP_SHORT_NAME OUT NOCOPY VARCHAR2
                         ,MESSAGE_NAME OUT NOCOPY VARCHAR2);
  PROCEDURE SET_ENCODED(ENCODED_MESSAGE IN VARCHAR2);
  PROCEDURE RAISE_ERROR;
  FUNCTION GET_NEXT_SEQUENCE(APPID IN NUMBER
                            ,CAT_CODE IN VARCHAR2
                            ,SOBID IN NUMBER
                            ,MET_CODE IN VARCHAR2
                            ,TRX_DATE IN DATE
                            ,DBSEQNM IN OUT NOCOPY VARCHAR2
                            ,DBSEQID IN OUT NOCOPY INTEGER) RETURN NUMBER;
  PROCEDURE GET_SEQ_NAME(APPID IN NUMBER
                        ,CAT_CODE IN VARCHAR2
                        ,SOBID IN NUMBER
                        ,MET_CODE IN VARCHAR2
                        ,TRX_DATE IN DATE
                        ,DBSEQNM OUT NOCOPY VARCHAR2
                        ,DBSEQID OUT NOCOPY INTEGER
                        ,SEQASSID OUT NOCOPY INTEGER);
  FUNCTION GET_NEXT_AUTO_SEQ(DBSEQNM IN VARCHAR2) RETURN NUMBER;
  FUNCTION GET_NEXT_AUTO_SEQUENCE(APPID IN NUMBER
                                 ,CAT_CODE IN VARCHAR2
                                 ,SOBID IN NUMBER
                                 ,MET_CODE IN VARCHAR2
                                 ,TRX_DATE IN VARCHAR2) RETURN NUMBER;
  FUNCTION GET_NEXT_AUTO_SEQUENCE(APPID IN NUMBER
                                 ,CAT_CODE IN VARCHAR2
                                 ,SOBID IN NUMBER
                                 ,MET_CODE IN VARCHAR2
                                 ,TRX_DATE IN DATE) RETURN NUMBER;
  PROCEDURE CREATE_GAPLESS_SEQUENCES;
  FUNCTION CREATE_GAPLESS_SEQUENCE(SEQID IN NUMBER
                                  ,SEQASSID IN NUMBER) RETURN NUMBER;
  FUNCTION GET_NEXT_USER_SEQUENCE(FDS_USER_ID IN NUMBER
                                 ,SEQASSID IN NUMBER
                                 ,SEQID IN NUMBER) RETURN NUMBER;*/
END JL_JLCOARCR_XMLP_PKG;



/