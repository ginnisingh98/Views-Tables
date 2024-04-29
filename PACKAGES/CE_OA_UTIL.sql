--------------------------------------------------------
--  DDL for Package CE_OA_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_OA_UTIL" AUTHID CURRENT_USER AS
/* $Header: ceoautls.pls 120.0 2004/06/21 21:51:56 bhchung ship $ */

FUNCTION XTR_USER(X_user_id number) RETURN VARCHAR2;
FUNCTION IS_INSTALLED(X_prod_id number) RETURN VARCHAR2;

END CE_OA_UTIL;

 

/
