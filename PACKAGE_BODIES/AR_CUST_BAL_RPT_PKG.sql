--------------------------------------------------------
--  DDL for Package Body AR_CUST_BAL_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CUST_BAL_RPT_PKG" 
-- $Header: AR_CBSLRPTB.pls 120.0.12000000.1 2007/10/23 14:12:26 sgudupat noship $
--*************************************************************************
-- Copyright (c)  2000    Oracle                 Product Development
-- All rights reserved
--*************************************************************************
--
-- HEADER
--   Source control header
--
-- PROGRAM NAME
--  AR_CBSLRPTB.pls
--
-- DESCRIPTION
--  This script creates the package body of AR_CUST_BAL_RPT_PKG
--  This package is used to report on AR Customer Balance Statement Letter Report.
--
-- USAGE
--   To install       sqlplus <apps_user>/<apps_pwd> @AR_CBSLRPTB.pls
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
   FUNCTION BeforeReport RETURN BOOLEAN
   IS
    l_count1 number;
    l_count2 number;
   BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      P_SORT_BY_PHONETICS := FND_PROFILE.VALUE('RA_CUSTOMERS_SORT_BY_PHONETICS');

      IF P_SORT_BY_PHONETICS = 'Y'
      THEN
         P_SORT := 'HZP.ORGANIZATION_NAME_PHONETIC';
      ELSE
         P_SORT := 'HZP.PARTY_NAME';
      END IF;

      RETURN (TRUE);
   EXCEPTION
      WHEN OTHERS THEN
         P_SORT_BY_PHONETICS := 'N';
         P_SORT := 'HZP.PARTY_NAME';
   END;

   FUNCTION AfterReport RETURN BOOLEAN
   IS
   l_count1 number;
   l_count2 number;
   BEGIN
      RETURN (TRUE);
   END;

END AR_CUST_BAL_RPT_PKG;

/
