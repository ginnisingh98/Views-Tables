--------------------------------------------------------
--  DDL for Package FII_AP_DRILL_ACROSS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AP_DRILL_ACROSS" AUTHID CURRENT_USER AS
/* $Header: FIIAPS5S.pls 120.1 2005/08/16 16:43:21 vkazhipu noship $ */

PROCEDURE drill_across(pSource IN varchar2,  pOperatingUnit IN varchar2,
                       pSupplier IN varchar2, pCurrency IN varchar2,
                       pAsOfDateValue IN varchar2,pPeriod IN varchar2,pParamIds IN varchar2);


END FII_AP_DRILL_ACROSS;

 

/
