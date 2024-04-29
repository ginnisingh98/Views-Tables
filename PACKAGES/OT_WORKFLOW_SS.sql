--------------------------------------------------------
--  DDL for Package OT_WORKFLOW_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OT_WORKFLOW_SS" AUTHID CURRENT_USER AS
/* $Header: otwkflss.pkh 115.1 2003/04/09 09:29:13 sbhullar noship $ */
/*
   This package contails new (v4.0+)workflow related business logic
*/
--
-- ------------------------------------------------------------------------
-- |------------------------< Get_event_standard_price >-------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Get the event standard price
--
function get_event_standard_price
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number;
--
--
--
-- ------------------------------------------------------------------------
-- |------------------------< Get_activity_type >-------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Get the activity type
--
function get_activity_type
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;
--
-- ------------------------------------------------------------------------
-- |------------------------< Get_activity_category >-------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Get the activity category
--
function get_act_pm_category
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;
--
-- ------------------------------------------------------------------------
-- |------------------------< Get_act_pm_delivery_method >-------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Get the activity primary delivery method
--
function get_act_pm_delivery_method
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;
--
-- ------------------------------------------------------------------------
-- |------------------------< Get_enrollment_status >-------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Get the enrollment status
--
function get_enrollment_status
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;
--
--
END ot_workflow_ss;

 

/
