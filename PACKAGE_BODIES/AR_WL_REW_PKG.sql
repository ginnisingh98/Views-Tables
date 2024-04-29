--------------------------------------------------------
--  DDL for Package Body AR_WL_REW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_WL_REW_PKG" AS
-- $Header: ARWLREWB.pls 120.0.12010000.2 2008/09/04 14:11:29 tthangav noship $
/*===========================================================================+
--*************************************************************************
-- Copyright (c)  2000    Oracle                 Product Development
-- All rights reserved
--*************************************************************************
--
-- HEADER
--  Source control Body
--
-- PROGRAM NAME
--   ARWLREWS.pls
--
-- DESCRIPTION
-- This script creates the package body of AR_WL_REW_PKG
-- This package is used for Cash Application work load review report.
--
-- USAGE
--   To install        sqlplus <apps_user>/<apps_pwd> @ARWLREWS.pls
--   To execute        sqlplus <apps_user>/<apps_pwd> AR_WL_REW_PKG.
--
-- PROGRAM LIST        DESCRIPTION
--
-- BEFOREREPORT        This function is used to dynamically get the
--                     WHERE clause in SELECT statement.
--
-- DEPENDENCIES
-- None
--
-- CALLED BY
--
--
-- LAST UPDATE DATE    25-Jul-2008
-- Date the program has been modified for the last time.
--
-- HISTORY
-- =======
--
-- VERSION DATE        AUTHOR(S)       DESCRIPTION
-- ------- ----------- --------------- --------------------------------------
--         25-Jul-2008 Thirumalaisamy   Initial Creation
+===========================================================================*/

--**********************************************************
-- Before Report function used to obtain the Dynamic Queries
-- Based on the Input Parameter Values
--**********************************************************
FUNCTION beforereport RETURN BOOLEAN
IS
BEGIN
--****************************************************
-- Based on p_org_id the data will be filtered
-- else we will fetch all the Receipts of any org
--****************************************************
  IF p_org_id IS NOT NULL THEN
    gc_org_id := ' AND acr.org_id = :p_org_id ';
  END IF;

--****************************************************
-- Based on p_cash_appln_owner_from and p_cash_appln_owner_to the
-- data will be filtered else we receive the information
-- for all the Cash Application Owners
--****************************************************
  IF p_cash_appln_owner_from IS NOT NULL AND p_cash_appln_owner_to IS NOT NULL THEN
    gc_cash_appln_owner := ' AND fu.user_name >= :p_cash_appln_owner_from
                          AND fu.user_name <= :p_cash_appln_owner_to ';
  ELSIF p_cash_appln_owner_from IS NULL AND p_cash_appln_owner_to IS NOT NULL THEN
    gc_cash_appln_owner := ' AND fu.user_name <= :p_cash_appln_owner_to ';
  ELSIF p_cash_appln_owner_from IS NOT NULL AND p_cash_appln_owner_to IS NULL THEN
    gc_cash_appln_owner := ' AND fu.user_name >= :p_cash_appln_owner_from ';
  ELSE
    gc_cash_appln_owner := ' AND 1 = 1 ';
  END IF;

--****************************************************
-- Based on p_recpt_date_from and p_recpt_date_to the
-- data will be filtered else we receive the information
-- for all the Receipt Dates
--****************************************************
  IF p_recpt_date_from IS NOT NULL AND p_recpt_date_to IS NOT NULL THEN
    gc_recpt_date := ' AND acr.receipt_date >= :p_recpt_date_from
                          AND acr.receipt_date <= :p_recpt_date_to ';
  ELSIF p_recpt_date_from IS NULL AND p_recpt_date_to IS NOT NULL THEN
    gc_recpt_date := ' AND acr.receipt_date <= :p_recpt_date_to ';
  ELSIF p_recpt_date_from IS NOT NULL AND p_recpt_date_to IS NULL THEN
    gc_recpt_date := ' AND acr.receipt_date >= :p_recpt_date_from ';
  ELSE
    gc_recpt_date := ' AND 1 = 1 ';
  END IF;

--****************************************************
-- Based on p_cust_from and p_cust_to the
-- data will be filtered else we receive the information
-- for all the Customers
--****************************************************
  IF p_cust_from IS NOT NULL AND p_cust_to IS NOT NULL THEN
    gc_cust := ' AND hca.account_number >= :p_cust_from
                          AND hca.account_number <= :p_cust_to ';
  ELSIF p_cust_from IS NULL AND p_cust_to IS NOT NULL THEN
    gc_cust := ' AND hca.account_number <= :p_cust_to ';
  ELSIF p_cust_from IS NOT NULL AND p_cust_to IS NULL THEN
    gc_cust := ' AND hca.account_number >= :p_cust_from ';
  ELSE
    gc_cust := ' AND 1 = 1 ';
  END IF;

--****************************************************
-- Based on p_work_item_status_from and p_work_item_status_to the
-- data will be filtered else we receive the information
-- for all the Status
--****************************************************
  IF p_work_item_status_from IS NOT NULL AND p_work_item_status_to IS NOT NULL THEN
    gc_work_item_status := ' AND lu.meaning  >= :p_work_item_status_from
                          AND lu.meaning  <= :p_work_item_status_to ';
  ELSIF p_work_item_status_from IS NULL AND p_work_item_status_to IS NOT NULL THEN
    gc_work_item_status := ' AND lu.meaning  <= :p_work_item_status_to ';
  ELSIF p_work_item_status_from IS NOT NULL AND p_work_item_status_to IS NULL THEN
    gc_work_item_status := ' AND lu.meaning  >= :p_work_item_status_from ';
  ELSE
    gc_work_item_status := ' AND 1 = 1 ';
  END IF;

--****************************************************
-- Based on p_assgn_date_from and p_assgn_date_to the
-- data will be filtered else we receive the information
-- for all the Assignment Dates
--****************************************************
  IF p_assgn_date_from IS NOT NULL AND p_assgn_date_to IS NOT NULL THEN
    gc_assgn_date := ' AND acr.work_item_assignment_date >= :p_assgn_date_from
                          AND acr.work_item_assignment_date <= :p_assgn_date_to ';
  ELSIF p_assgn_date_from IS NULL AND p_assgn_date_to IS NOT NULL THEN
    gc_assgn_date := ' AND acr.work_item_assignment_date <= :p_assgn_date_to ';
  ELSIF p_assgn_date_from IS NOT NULL AND p_assgn_date_to IS NULL THEN
    gc_assgn_date := ' AND acr.work_item_assignment_date >= :p_assgn_date_from ';
  ELSE
    gc_assgn_date := ' AND 1 = 1 ';
  END IF;

  RETURN (TRUE);
END beforereport;

END AR_WL_REW_PKG;

/
