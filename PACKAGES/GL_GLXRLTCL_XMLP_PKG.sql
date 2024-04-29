--------------------------------------------------------
--  DDL for Package GL_GLXRLTCL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLXRLTCL_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLXRLTCLS.pls 120.0 2007/12/27 15:22:24 vijranga noship $ */
  P_CONC_REQUEST_ID NUMBER := 0;

  P_SET_OF_BOOKS_ID NUMBER;

  P_TXN_CODE VARCHAR2(30);

  SET_OF_BOOKS_NAME VARCHAR2(30);

  STRUCT_NUM NUMBER;

  VALUE_SET_ID NUMBER;

  PAGENO NUMBER;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION SET_OF_BOOKS_NAME_P RETURN VARCHAR2;

  FUNCTION STRUCT_NUM_P RETURN NUMBER;

  FUNCTION VALUE_SET_ID_P RETURN NUMBER;

  FUNCTION PAGENO_P RETURN NUMBER;

  PROCEDURE GL_GET_PERIOD_DATES(TSET_OF_BOOKS_ID IN NUMBER
                               ,TPERIOD_NAME IN VARCHAR2
                               ,TSTART_DATE OUT NOCOPY DATE
                               ,TEND_DATE OUT NOCOPY DATE
                               ,ERRBUF OUT NOCOPY VARCHAR2);

  PROCEDURE GL_GET_LEDGER_INFO(SOBID IN NUMBER
                              ,COAID OUT NOCOPY NUMBER
                              ,SOBNAME OUT NOCOPY VARCHAR2
                              ,FUNC_CURR OUT NOCOPY VARCHAR2
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

  PROCEDURE SET_LANGUAGE(LANG_ID IN NUMBER);

  FUNCTION GET_MESSAGE(MSG_NAME IN VARCHAR2
                      ,SHOW_NUM IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION MSG_TKN_EXPAND(MSG IN VARCHAR2
                         ,T1 IN VARCHAR2
                         ,V1 IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION GET_MESSAGE(MSG_NAME IN VARCHAR2
                      ,SHOW_NUM IN VARCHAR2
                      ,T1 IN VARCHAR2
                      ,V1 IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION GET_MESSAGE(MSG_NAME IN VARCHAR2
                      ,SHOW_NUM IN VARCHAR2
                      ,T1 IN VARCHAR2
                      ,V1 IN VARCHAR2
                      ,T2 IN VARCHAR2
                      ,V2 IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION GET_MESSAGE(MSG_NAME IN VARCHAR2
                      ,SHOW_NUM IN VARCHAR2
                      ,T1 IN VARCHAR2
                      ,V1 IN VARCHAR2
                      ,T2 IN VARCHAR2
                      ,V2 IN VARCHAR2
                      ,T3 IN VARCHAR2
                      ,V3 IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION GET_MESSAGE(MSG_NAME IN VARCHAR2
                      ,SHOW_NUM IN VARCHAR2
                      ,T1 IN VARCHAR2
                      ,V1 IN VARCHAR2
                      ,T2 IN VARCHAR2
                      ,V2 IN VARCHAR2
                      ,T3 IN VARCHAR2
                      ,V3 IN VARCHAR2
                      ,T4 IN VARCHAR2
                      ,V4 IN VARCHAR2) RETURN VARCHAR2;

END GL_GLXRLTCL_XMLP_PKG;


/
