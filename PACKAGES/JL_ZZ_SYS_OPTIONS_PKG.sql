--------------------------------------------------------
--  DDL for Package JL_ZZ_SYS_OPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_ZZ_SYS_OPTIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: jlzzsops.pls 120.3 2006/02/24 10:57:22 amohiudd noship $ */


/* =======================================================================*
 | Fetches the value of Bank Transfer Currency                            |
 * =======================================================================*/

        FUNCTION get_bank_transfer_currency
        (
	p_org_id IN NUMBER DEFAULT NULL
	) RETURN  VARCHAR2;

/* =======================================================================*
 | Fetches the value of Copy Taxpayer ID Flag                             |
 * =======================================================================*/

        FUNCTION get_copy_cus_sup_name
        (
	p_org_id IN NUMBER DEFAULT NULL
	) RETURN  VARCHAR2;

/* =======================================================================*
 | Fetches the value of Payment Action                                    |
 * =======================================================================*/

        FUNCTION get_payment_action
        (
	p_org_id IN NUMBER
	) RETURN  VARCHAR2;

/* =======================================================================*
 | Fetches the value of Payment Action for AR                             |
 * =======================================================================*/

        FUNCTION get_payment_action_AR
        (
	p_org_id IN NUMBER
	) RETURN  VARCHAR2;

/* =======================================================================*
 | Fetches the value of Payment Location                                  |
 * =======================================================================*/

        FUNCTION get_payment_location
        (
	p_org_id IN NUMBER
	) RETURN  VARCHAR2;

/* =======================================================================*
 | Fetches the value of Taxpayer ID Error Flag                            |
 * =======================================================================*/

        FUNCTION get_taxid_raise_error
        (
	p_org_id IN NUMBER DEFAULT NULL
	) RETURN  VARCHAR2;

/* =======================================================================*
 | Fetches value of 'Use Related Transactions for Threshold Checking' flag|
 * =======================================================================*/

        FUNCTION get_ar_tx_use_whole_operation
        (
	p_org_id IN NUMBER
	) RETURN  VARCHAR2;

/* =======================================================================*
 | Fetches the value of Change Date Automatically                         |
 * =======================================================================*/

        FUNCTION get_change_date_automatically
        (
	p_org_id IN NUMBER
	) RETURN  VARCHAR2;

/* =======================================================================*
 | Fetches the value of Calendar                                          |
 * =======================================================================*/

        FUNCTION get_calendar
        (
	p_org_id IN NUMBER DEFAULT NULL
	) RETURN  VARCHAR2;

END JL_ZZ_SYS_OPTIONS_PKG;

 

/
