--------------------------------------------------------
--  DDL for Package JAI_PO_LLA_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_PO_LLA_TRIGGER_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_po_lla_t.pls 120.0.12000000.2 2007/10/25 02:24:30 rallamse ship $ */

  t_rec  PO_LINE_LOCATIONS_ALL%rowtype ;

  PROCEDURE ARD_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;
  PROCEDURE ARI_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;
  PROCEDURE ARU_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;

END JAI_PO_LLA_TRIGGER_PKG ;
 

/
