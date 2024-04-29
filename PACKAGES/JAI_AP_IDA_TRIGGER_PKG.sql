--------------------------------------------------------
--  DDL for Package JAI_AP_IDA_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_AP_IDA_TRIGGER_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_ap_ida_t.pls 120.0.12010000.2 2010/05/14 09:41:57 bgowrava ship $ */

  t_rec  AP_INVOICE_DISTRIBUTIONS_ALL%rowtype ;

  PROCEDURE ARUID_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;
  PROCEDURE BRIUD_T1 ( pr_old t_rec%type , pr_new in out  t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;

END JAI_AP_IDA_TRIGGER_PKG ;

/
