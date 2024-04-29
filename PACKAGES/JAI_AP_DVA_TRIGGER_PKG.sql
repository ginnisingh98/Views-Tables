--------------------------------------------------------
--  DDL for Package JAI_AP_DVA_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_AP_DVA_TRIGGER_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_ap_dva_t.pls 120.0 2005/09/01 12:24:52 rallamse noship $ */

  t_rec  AP_DUPLICATE_VENDORS_ALL%rowtype ;

  PROCEDURE ARI_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;

END JAI_AP_DVA_TRIGGER_PKG ;
 

/
