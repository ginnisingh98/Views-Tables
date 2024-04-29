--------------------------------------------------------
--  DDL for Package JAI_JMCR_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_JMCR_TRIGGER_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_jcmr_t.pls 120.0 2005/09/01 12:26:04 rallamse noship $ */

  t_rec  JAI_CMN_MATCH_RECEIPTS%rowtype ;

  PROCEDURE ARIU_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;
  PROCEDURE ARIU_T2 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;

END JAI_JMCR_TRIGGER_PKG ;
 

/
