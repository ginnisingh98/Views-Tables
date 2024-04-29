--------------------------------------------------------
--  DDL for Package JAI_AP_IA_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_AP_IA_TRIGGER_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_ap_ia_t.pls 120.1 2008/02/13 13:23:26 rallamse ship $ */

  t_rec  AP_INVOICES_ALL%rowtype ;

  PROCEDURE ARUID_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;
  PROCEDURE BRIUD_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;

END JAI_AP_IA_TRIGGER_PKG ;

/
