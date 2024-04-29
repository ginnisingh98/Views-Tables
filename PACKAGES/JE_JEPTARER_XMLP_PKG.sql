--------------------------------------------------------
--  DDL for Package JE_JEPTARER_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JE_JEPTARER_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: JEPTARERS.pls 120.1 2007/12/25 16:59:22 dwkrishn noship $ */
  P_SET_OF_BOOKS_ID NUMBER;

  P_CONC_REQUEST_ID NUMBER := 1374621;

  P_LEGAL_ENTITY_ID NUMBER;

  P_CHART_OF_ACCT NUMBER;

  P_BALANCING_SEGMENT VARCHAR2(25);

  P_BAL_SEG_NAME VARCHAR2(200) := '1=1';

  PLACE_REP_TITLE VARCHAR2(240);

  PLACE_COA_ID VARCHAR2(50);

  PLACE_SOB_NAME VARCHAR2(50);

  PLACE_FUNCT_CURR VARCHAR2(50);

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION PLACE_REP_TITLE_P RETURN VARCHAR2;

  FUNCTION PLACE_COA_ID_P RETURN VARCHAR2;

  FUNCTION PLACE_SOB_NAME_P RETURN VARCHAR2;

  FUNCTION PLACE_FUNCT_CURR_P RETURN VARCHAR2;

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

  PROCEDURE SET_NAME(APPLICATION IN VARCHAR2
                    ,NAME IN VARCHAR2);

  PROCEDURE SET_TOKEN(TOKEN IN VARCHAR2
                     ,VALUE IN VARCHAR2
                     ,TRANSLATE IN BOOLEAN);

  PROCEDURE RETRIEVE(MSGOUT OUT NOCOPY VARCHAR2);

  PROCEDURE CLEAR;

  FUNCTION GET_STRING(APPIN IN VARCHAR2
                     ,NAMEIN IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION GET RETURN VARCHAR2;

  FUNCTION GET_ENCODED RETURN VARCHAR2;

  PROCEDURE PARSE_ENCODED(ENCODED_MESSAGE IN VARCHAR2
                         ,APP_SHORT_NAME OUT NOCOPY VARCHAR2
                         ,MESSAGE_NAME OUT NOCOPY VARCHAR2);

  PROCEDURE SET_ENCODED(ENCODED_MESSAGE IN VARCHAR2);

  PROCEDURE RAISE_ERROR;

END JE_JEPTARER_XMLP_PKG;



/