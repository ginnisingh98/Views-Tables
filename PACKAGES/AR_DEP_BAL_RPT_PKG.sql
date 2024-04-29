--------------------------------------------------------
--  DDL for Package AR_DEP_BAL_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_DEP_BAL_RPT_PKG" 
-- $Header: AR_DEPBALRPT_PS.pls 120.0.12000000.1 2007/10/25 11:33:42 sgudupat noship $
--*************************************************************************
-- Copyright (c)  2000    Oracle                 Product Development
-- All rights reserved
--*************************************************************************
--
-- HEADER
--   Source control header
--
-- PROGRAM NAME
--  AR_DEP_BAL_RPT_PKG
--
-- DESCRIPTION
--  This script creates the package specification of AR_DEP_BAL_RPT_PKG
--  This package AUTHID CURRENT_USER is used to report on Deposit Balance Detail .
--
-- USAGE
--   To install       sqlplus <apps_user>/<apps_pwd> @AR_DEPBALRPT_PS.pls
--   To execute       sqlplus <apps_user>/<apps_pwd> AR_DEP_BAL_RPT_PKG
--
-- PROGRAM LIST       DESCRIPTION
--
-- DEPENDENCIES
--   None
--
-- CALLED BY
--   Deposit Balance Report - Japan.
--
-- LAST UPDATE DATE   27-Jul-2007
--   Date the program has been modified for the last time
--
-- HISTORY
-- =======
--
-- VERSION DATE        AUTHOR(S)       DESCRIPTION
-- ------- ----------- --------------- ------------------------------------
-- Draft1A 27-Jul-2007 Rakesh Pulla     Initial Creation
-- Draft1B 13-Aug-2007 Rakesh Pulla     Incorporated the SO Review comments as per Ref # 28859
--************************************************************************
AS

P_CUSTOMER        VARCHAR2(100);
P_CUSTOMER_NAME   VARCHAR2(100);
P_CURRENCY        VARCHAR2(30);
P_CUSTOMER_DUMMY  VARCHAR2(360);
P_PERIOD_FROM     VARCHAR2(100);
P_PERIOD_TO       VARCHAR2(100);

/* Global Variables */
gn_ledger_id      NUMBER;
gn_cust_id        NUMBER;
gc_customer       VARCHAR2(100);
gc_currency       VARCHAR2(100);
gc_per_start_date VARCHAR2(100);
gc_per_end_date   VARCHAR2(100);

FUNCTION beforeReport  RETURN BOOLEAN ;
FUNCTION description(p_value IN VARCHAR2, p_segment IN VARCHAR2) RETURN VARCHAR2;
FUNCTION commitment_balance( p_customer_trx_id      IN NUMBER) RETURN NUMBER;

END AR_DEP_BAL_RPT_PKG;

 

/
