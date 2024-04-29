--------------------------------------------------------
--  DDL for Package JAI_INV_MMT_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_INV_MMT_TRIGGER_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_inv_mmt_t.pls 120.0 2005/09/01 12:25:46 rallamse noship $ */

  t_rec  MTL_MATERIAL_TRANSACTIONS%rowtype ;

  PROCEDURE ARI_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;

END JAI_INV_MMT_TRIGGER_PKG ;
 

/