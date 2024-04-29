--------------------------------------------------------
--  DDL for Package AP_INCOME_TAX_REGIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_INCOME_TAX_REGIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: apiincrs.pls 120.4 2004/10/28 00:05:09 pjena noship $ */

    PROCEDURE CHECK_UNIQUE (X_ROWID VARCHAR2,
			    X_REGION_SHORT_NAME VARCHAR2,
			    X_REGION_CODE NUMBER,
			    X_calling_sequence VARCHAR2);

END AP_INCOME_TAX_REGIONS_PKG;

 

/
