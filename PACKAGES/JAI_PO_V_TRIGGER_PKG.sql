--------------------------------------------------------
--  DDL for Package JAI_PO_V_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_PO_V_TRIGGER_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_po_v_t.pls 120.1 2006/04/06 07:53:32 lgopalsa noship $ */

  -- Bug 5141305. Added by Lakshmi Gopalsami
  -- Changed PO_AP_VENDORS to AP_SUPPLIERS

  t_rec  AP_SUPPLIERS%rowtype ;

  PROCEDURE ARU_T1 ( pr_old t_rec%type ,
                     pr_new t_rec%type ,
		     pv_action varchar2 ,
		     pv_return_code out nocopy varchar2 ,
		     pv_return_message out nocopy varchar2 ) ;

END JAI_PO_V_TRIGGER_PKG ;
 

/
