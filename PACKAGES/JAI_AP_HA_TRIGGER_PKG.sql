--------------------------------------------------------
--  DDL for Package JAI_AP_HA_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_AP_HA_TRIGGER_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_ap_ha_t.pls 120.0.12010000.4 2009/06/14 07:58:34 vumaasha ship $ */

  t_rec  AP_HOLDS_ALL%rowtype ;

  PROCEDURE BRI_T1 ( pr_old t_rec%type , pr_new in out t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;
  PROCEDURE BRIUD_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;

END JAI_AP_HA_TRIGGER_PKG ;

/
