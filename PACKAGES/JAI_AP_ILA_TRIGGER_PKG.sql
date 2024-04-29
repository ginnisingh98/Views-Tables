--------------------------------------------------------
--  DDL for Package JAI_AP_ILA_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_AP_ILA_TRIGGER_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_ap_ila_t.pls 120.1 2007/09/04 12:43:13 pjayaram ship $ */

  t_rec  AP_INVOICE_LINES_ALL%rowtype ;

  PROCEDURE ARI_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;

  PROCEDURE ARU_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;

END JAI_AP_ILA_TRIGGER_PKG ;

/
