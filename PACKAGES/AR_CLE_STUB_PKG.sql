--------------------------------------------------------
--  DDL for Package AR_CLE_STUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_CLE_STUB_PKG" 
-- $Header: ARCLESTUBS.pls 120.0.12000000.1 2007/10/23 14:11:09 sgudupat noship $
--*************************************************************************
-- Copyright (c)  2000    Oracle                 Product Development
-- All rights reserved
--*************************************************************************
--
-- HEADER
--   Source control header
--
-- PROGRAM NAME
--  ARCLESTUBS.pls
--
-- DESCRIPTION
--  This script creates the package specification of AR_CLE_STUB_PKG
--  This checks where the localization program exists or not and to submit the localization program if exists.
--
-- USAGE
--   To install       sqlplus <apps_user>/<apps_pwd> @ARCLESTUBS.pls
--   To execute       sqlplus <apps_user>/<apps_pwd> AR_CLE_STUB_PKG
--
-- PROGRAM LIST                DESCRIPTION
-- localization_prog_exists    It AUTHID CURRENT_USER is a function of AR_CLE_STUB_PKG package.
--                             This checks where the localization program exists or not.
-- submit_prog                 It is a procedure of AR_CLE_STUB_PKG package.
--                             This is used to submit the localization program if exists.
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
   FUNCTION localization_prog_exists RETURN BOOLEAN;
   PROCEDURE submit_prog;

END AR_CLE_STUB_PKG;

 

/
