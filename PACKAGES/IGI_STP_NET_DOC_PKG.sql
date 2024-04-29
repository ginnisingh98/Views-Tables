--------------------------------------------------------
--  DDL for Package IGI_STP_NET_DOC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_STP_NET_DOC_PKG" AUTHID CURRENT_USER as
 -- $Header: igistpbs.pls 120.3.12000000.3 2007/09/25 08:48:27 gkumares ship $
PROCEDURE Available_Docs	(x_type          VARCHAR2,
                        	 x_param         VARCHAR2,
    	                         x_ap_trx_min    VARCHAR2,
				 x_ap_trx_max    VARCHAR2,
    	                         x_ar_trx_min    VARCHAR2,
				 x_ar_trx_max    VARCHAR2,
    	                         --x_ref_min       VARCHAR2,
				 --x_ref_max       VARCHAR2,
                                 x_customer_id   number,
                                 x_vendor_id     number,
                                 x_currency_code VARCHAR2);

PROCEDURE Update_Candidates (x_type        VARCHAR2,
                             x_batch_id    NUMBER,
                             x_package_id  NUMBER,
                             x_org_id      number);
END IGI_STP_NET_DOC_PKG;

 

/
