--------------------------------------------------------
--  DDL for Package JAI_OPM_GBH_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_OPM_GBH_TRIGGER_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_opm_gbh_t.pls 120.0 2005/09/02 09:01:57 rallamse noship $ */

  t_rec  GME_BATCH_HEADER%rowtype ;

  PROCEDURE ARU_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;

END JAI_OPM_GBH_TRIGGER_PKG ;
 

/
