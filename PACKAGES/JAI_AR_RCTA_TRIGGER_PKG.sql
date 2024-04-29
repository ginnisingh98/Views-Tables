--------------------------------------------------------
--  DDL for Package JAI_AR_RCTA_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_AR_RCTA_TRIGGER_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_ar_rcta_t.pls 120.1.12010000.3 2010/04/30 05:19:45 boboli ship $ */
/****************************************************************************************************
  CHANGE HISTORY:

  S.No      Date          Author and Details
  1.        30/01/2007    SACSETHI FOR BUG 5631784  FILE VERSION 120.1
                          PROCEDURE ARU_T7 IS NEWELY CREATED FOR PROVIDING TCS FUNCTIONALITY
  2.        07/11/2008    CSahoo for bug#7450481, File Version 120.0.12000000.3
                          Issue: AUTOINVOICE IMPORT PROGRAM ENDING IN ERROR FOR BILL ONLY ORDERS
                          Fix: Added the procedure ARD_T1

  3.        29-Apr-2010    Bo Li for bug9666476
                           Add procedure ARU_T8 to handle the non-shippable RMA flow

*******************************************************************************************************/


  t_rec  RA_CUSTOMER_TRX_ALL%rowtype ;

  PROCEDURE ARI_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;
  PROCEDURE ARU_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;
  PROCEDURE ARU_T2 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;
  PROCEDURE ARU_T3 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;
  PROCEDURE ARU_T4 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;
  PROCEDURE ARU_T5 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;
  PROCEDURE ARU_T6 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;
  PROCEDURE ARU_T7 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ; -- Added by sacsethi for bug 5631784 on 30-01-2007
  PROCEDURE ARU_T8 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ; -- Added by Bo Li for VAT non-shippable RMA for bug9666476 on 29-Apr-2010
  PROCEDURE ASI_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;
  -- added the procedure ARD_T1 for bug#7450481
  PROCEDURE ARD_T1 ( pr_old t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 );


END JAI_AR_RCTA_TRIGGER_PKG ;

/
