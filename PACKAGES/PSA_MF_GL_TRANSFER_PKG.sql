--------------------------------------------------------
--  DDL for Package PSA_MF_GL_TRANSFER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSA_MF_GL_TRANSFER_PKG" AUTHID CURRENT_USER AS
/* $Header: PSAMFGLS.pls 120.2 2006/09/13 12:51:38 agovil noship $ */

/*************************************/
/* Function for Transactions Posting */
/*************************************/
FUNCTION psa_mf_trx_transfer(p_trx_rec in PSA_MFAR_UTILS.trx_rec)
RETURN varchar2;

/*************************************/
/* Function for Adjustments Posting */
/*************************************/
FUNCTION psa_mf_adj_transfer(p_adj_rec in PSA_MFAR_UTILS.adj_rec)
RETURN varchar2;

/*************************************/
/* Function for Receipts Posting */
/*************************************/
FUNCTION psa_mf_rct_transfer(p_rct_rec in PSA_MFAR_UTILS.rct_rec)
RETURN varchar2;

/******************************************************/
/* Function to Insert TRX additionalMFAR jes into GL Interface */
/******************************************************/
FUNCTION psa_mf_MFAR_trx_jes(p_trx_rec in PSA_MFAR_UTILS.trx_rec)
return varchar2;

/******************************************************/
/* Function to Insert ADJ additionalMFAR jes into GL Interface */
/******************************************************/
FUNCTION psa_mf_MFAR_adj_jes(p_adj_rec in PSA_MFAR_UTILS.adj_rec)
RETURN varchar2;

/*****************************************************/
/* Function to Insert RCT additionalMFAR jes into GL Interface */
/*****************************************************/
FUNCTION psa_mf_MFAR_rct_jes(p_rct_rec in PSA_MFAR_UTILS.rct_rec)
RETURN varchar2;



function get_entered_dr_rct (p_lookup_code in number, p_amount in number,
                        p_discount in number  default null,
                        p_ue_discount in number  default null)
return number ;

function get_entered_cr_rct (p_lookup_code in number, p_amount in number,
                        p_discount in number default null,
                        p_ue_discount in number  default null)
return number ;

function get_entered_dr_adj (p_lookup_code in number, p_amount in number)
return number ;

function get_entered_cr_adj (p_lookup_code in number, p_amount in number)
return number ;

function get_entered_dr_crm (p_lookup_code in number, p_amount in number)
return number ;

function get_entered_cr_crm (p_lookup_code in number, p_amount in number)
return number ;

user_adj_cat_name varchar2(25) := PSA_MFAR_UTILS.get_user_category_name ('Adjustment');
user_cb_cat_name varchar2(25) := PSA_MFAR_UTILS.get_user_category_name ('Chargebacks');
user_cmapp_cat_name varchar2(25) := PSA_MFAR_UTILS.get_user_category_name ('Credit Memo Applications');
user_cm_cat_name varchar2(25) := PSA_MFAR_UTILS.get_user_category_name ('Credit Memos');
user_dm_cat_name varchar2(25) := PSA_MFAR_UTILS.get_user_category_name ('Debit Memos');
user_mcr_cat_name varchar2(25) := PSA_MFAR_UTILS.get_user_category_name ('Misc Receipts');
user_radj_cat_name varchar2(25) := PSA_MFAR_UTILS.get_user_category_name ('Rate Adjustments');
user_inv_cat_name varchar2(25) := PSA_MFAR_UTILS.get_user_category_name ('Sales Invoices');
user_rct_cat_name varchar2(25) := PSA_MFAR_UTILS.get_user_category_name ('Trade Receipts');
user_ccr_cat_name varchar2(25) := PSA_MFAR_UTILS.get_user_category_name ('Cross Currency');
user_br_cat_name varchar2(25) := PSA_MFAR_UTILS.get_user_category_name ('Bills Receivable');


END PSA_MF_GL_TRANSFER_PKG;


 

/
