--------------------------------------------------------
--  DDL for Package JAI_JOM_LM_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_JOM_LM_TRIGGER_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_jom_lm_t.pls 120.0 2005/09/01 12:26:08 rallamse noship $ */

  t_rec  JAI_OM_LC_MATCHINGS%rowtype ;

  PROCEDURE ARI_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;

END JAI_JOM_LM_TRIGGER_PKG ;
 

/
