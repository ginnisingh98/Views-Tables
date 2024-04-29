--------------------------------------------------------
--  DDL for Package AR_CASH_RECEIPT_PRINT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_CASH_RECEIPT_PRINT_PKG" AUTHID CURRENT_USER AS
-- $Header: arcrprpts.pls 120.0.12000000.1 2007/10/23 18:27:13 sgudupat noship $
/*===========================================================================+
|  Copyright (c) 2003 Oracle Corporation BelmFont, California, USA           |
|                          ALL rights reserved.                              |
+============================================================================+
| FILENAME                                                                   |
|     arcrps.pls                                                         |
|                                                                            |
| PACKAGE NAME                                                               |
|     AR_CASH_RECEIPT_PRINT_PKG                                                |
|                                                                            |
| DESCRIPTION                                                                |
|     Package specification.This provides XML extract for Receipt Print      |
|      report for    Israel                                                  |
|                                                                            |
| HISTORY                                                                    |
|     12/19/2006  SGAUTAM         Created                                    |
+===========================================================================*/

--
-- To be used in query as bind variable
--

P_COPY_OR_ORIGINAL          VARCHAR2(10);


P_START_DATE                DATE;
P_END_DATE                  DATE;

P_RECEIPT_FROM              VARCHAR2(30);
P_RECEIPT_TO                VARCHAR2(30);


P_DOC_SEQ_VALUE_FROM        NUMBER(15);
P_DOC_SEQ_VALUE_TO          NUMBER(15);


P_CUSTOMER_ID               NUMBER(15);


FUNCTION beforeReport RETURN BOOLEAN;

FUNCTION afterReport RETURN BOOLEAN;


END AR_CASH_RECEIPT_PRINT_PKG;

 

/
