--------------------------------------------------------
--  DDL for Package JAI_PAN_UPDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_PAN_UPDATE_PKG" AUTHID CURRENT_USER as
/* $Header: jai_pan_update_s.pls 120.0.12000000.1 2007/07/24 06:56:08 rallamse noship $ */

Procedure pan_update( P_errbuf       OUT NOCOPY varchar2,
                      P_return_code  OUT NOCOPY varchar2,
                      P_vendor_id in   PO_VENDORS.vendor_id%TYPE ,
                      P_old_pan_num  IN JAI_AP_TDS_VENDOR_HDRS.pan_no%TYPE,
                      P_new_pan_num  IN JAI_AP_TDS_VENDOR_HDRS.pan_no%TYPE,
                      P_debug_flag IN varchar2);

End  jai_pan_update_pkg;

 

/
