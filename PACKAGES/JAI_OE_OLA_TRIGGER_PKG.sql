--------------------------------------------------------
--  DDL for Package JAI_OE_OLA_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_OE_OLA_TRIGGER_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_oe_ola_t.pls 120.0.12010000.3 2010/04/16 21:10:03 haoyang ship $ */

  t_rec  OE_ORDER_LINES_ALL%rowtype ;

  PROCEDURE ARD_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;
  PROCEDURE ARIU_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;
  -- added by Allen Yang 31-Mar-2010 for bug 9485355, begin
  PROCEDURE ARIU_T2 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;
  -- added by Allen Yang 31-Mar-2010 for bug 9485355, end
  PROCEDURE ARU_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;
  PROCEDURE BRIU_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;

END JAI_OE_OLA_TRIGGER_PKG ;

/
