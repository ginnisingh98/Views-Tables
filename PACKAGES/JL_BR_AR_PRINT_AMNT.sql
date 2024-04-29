--------------------------------------------------------
--  DDL for Package JL_BR_AR_PRINT_AMNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_BR_AR_PRINT_AMNT" AUTHID CURRENT_USER AS
/* $Header: jlbrrpis.pls 120.2 2002/11/06 00:08:37 cleyvaol ship $ */
   FUNCTION BR_CONVERT_AMOUNT (X_Invoice_Amount IN NUMBER,
                               X_Currency_Name  IN VARCHAR2 DEFAULT 'REAL')
            RETURN VARCHAR2;
END JL_BR_AR_PRINT_AMNT;

 

/
