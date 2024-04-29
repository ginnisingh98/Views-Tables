--------------------------------------------------------
--  DDL for Package JAI_PO_HA_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_PO_HA_TRIGGER_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_po_ha_t.pls 120.0 2005/09/01 12:27:03 rallamse noship $ */

  t_rec  PO_HEADERS_ALL%rowtype ;

  PROCEDURE ARU_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;
  PROCEDURE ARU_T2 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;
  PROCEDURE ARU_T3 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;

END JAI_PO_HA_TRIGGER_PKG ;
 

/
