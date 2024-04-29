--------------------------------------------------------
--  DDL for Package JAI_JRG_PLA_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_JRG_PLA_TRIGGER_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_jrg_pla_t.pls 120.0 2005/09/01 12:26:40 rallamse noship $ */

  t_rec  JAI_CMN_RG_PLA_TRXS%rowtype ;

  PROCEDURE BRI_T1 ( pr_old t_rec%type , pr_new in out t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;

END JAI_JRG_PLA_TRIGGER_PKG ;
 

/
