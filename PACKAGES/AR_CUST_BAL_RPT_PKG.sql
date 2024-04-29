--------------------------------------------------------
--  DDL for Package AR_CUST_BAL_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_CUST_BAL_RPT_PKG" 
-- $Header: AR_CBSLRPTS.pls 120.0.12000000.1 2007/10/23 14:12:14 sgudupat noship $
--*************************************************************************
-- Copyright (c)  2000    Oracle                 Product Development
-- All rights reserved
--*************************************************************************
--
-- HEADER
--   Source control header
--
-- PROGRAM NAME
--  AR_CBSLRPTS.pls
--
-- DESCRIPTION
--  This script creates the package specification of AR_CUST_BAL_RPT_PKG
--  This package AUTHID CURRENT_USER is used to report on AR Customer Balance Statement Letter Report.
--
-- USAGE
--   To install       sqlplus <apps_user>/<apps_pwd> @AR_CBSLRPTS.pls
--   To execute       sqlplus <apps_user>/<apps_pwd> AR_CUST_BAL_RPT_PKG
--
-- PROGRAM LIST                DESCRIPTION
--
-- DEPENDENCIES
--   None
--
-- CALLED BY
--   Statement Generation Program.
--
-- LAST UPDATE DATE   24-Jun-2007
--   Date the program has been modified for the last time
--
-- HISTORY
-- =======
--
-- VERSION DATE        AUTHOR(S)       DESCRIPTION
-- ------- ----------- --------------- ------------------------------------
-- Draft1A 02-Feb-2007 Sajana Doma     Initial Creation
--
--
--************************************************************************
AS

-- To be used in query as bind variable

   P_RESP_APPLICATION_ID           NUMBER;
   P_CONC_REQUEST_ID	              NUMBER;
   P_SORT	                      VARCHAR2(500);
   P_SORT_BY_PHONETICS	          VARCHAR2(1);
   P_AS_OF_DATE	                  DATE;

   FUNCTION BeforeReport RETURN BOOLEAN;
   FUNCTION AfterReport RETURN BOOLEAN;

END AR_CUST_BAL_RPT_PKG;

 

/
