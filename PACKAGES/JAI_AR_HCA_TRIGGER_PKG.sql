--------------------------------------------------------
--  DDL for Package JAI_AR_HCA_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_AR_HCA_TRIGGER_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_ar_rc_t.pls 120.0 2005/09/01 12:25:24 rallamse noship $ */

  t_rec  HZ_CUST_ACCOUNTS%rowtype ;

  PROCEDURE ARD_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;

END JAI_AR_HCA_TRIGGER_PKG ;
 

/
