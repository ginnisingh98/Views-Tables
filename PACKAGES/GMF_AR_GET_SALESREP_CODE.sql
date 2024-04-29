--------------------------------------------------------
--  DDL for Package GMF_AR_GET_SALESREP_CODE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_AR_GET_SALESREP_CODE" AUTHID CURRENT_USER AS
/* $Header: gmfrepcs.pls 115.1 2002/11/11 00:40:56 rseshadr ship $ */
  PROCEDURE RA_GET_SALESREP_CODE(STARTDATE                   DATE,
                                 ENDDATE                     DATE,
                                 SALESREPNAME                VARCHAR2,
                                 SALESREPID    OUT    NOCOPY NUMBER,
                                 ROW_TO_FETCH  IN OUT NOCOPY NUMBER,
                                 STATUSCODE    OUT    NOCOPY NUMBER);
END GMF_AR_GET_SALESREP_CODE;

 

/
