--------------------------------------------------------
--  DDL for Package IGI_CIS_PAYMENT_VOUCHERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_CIS_PAYMENT_VOUCHERS_PKG" AUTHID CURRENT_USER AS
/* $Header: igiciscs.pls 115.8 2003/07/22 13:14:32 sdixit ship $ */

    PROCEDURE Lock_Row(p_row_id                VARCHAR2
                      ,p_invoice_payment_id    NUMBER
                      ,p_vendor_id             NUMBER
                      ,p_vendor_site_id        NUMBER
                      ,p_pmt_vch_number        VARCHAR2
                      ,p_pmt_vch_amount        NUMBER
                      ,p_pmt_vch_received_date DATE
                      ,p_pmt_vch_description   VARCHAR2
                      );

    PROCEDURE Insert_Row(p_org_id                NUMBER
                       ,p_row_id                IN OUT NOCOPY VARCHAR2
                        ,p_invoice_payment_id    NUMBER
                        ,p_vendor_id             NUMBER
                        ,p_vendor_site_id        NUMBER
                        ,p_pmt_vch_number        VARCHAR2
                        ,p_pmt_vch_amount        NUMBER
                        ,p_pmt_vch_received_date DATE
                        ,p_pmt_vch_description   VARCHAR2
                        ,p_creation_date         DATE
                        ,p_created_by            NUMBER
                        ,p_last_update_date      DATE
                        ,p_last_updated_by       NUMBER
                        ,p_last_update_login     NUMBER
                        ,p_calling_sequence      IN OUT NOCOPY VARCHAR2
                        );

    PROCEDURE Update_Row(p_row_id                VARCHAR2
                        ,p_vendor_id             NUMBER
                        ,p_vendor_site_id        NUMBER
                        ,p_pmt_vch_number        VARCHAR2
                        ,p_pmt_vch_amount        NUMBER
                        ,p_pmt_vch_received_date DATE
                        ,p_pmt_vch_description   VARCHAR2
                        ,p_last_update_date      DATE
                        ,p_last_updated_by       NUMBER
                        ,p_last_update_login     NUMBER
                        );

END IGI_CIS_PAYMENT_VOUCHERS_PKG;

 

/
