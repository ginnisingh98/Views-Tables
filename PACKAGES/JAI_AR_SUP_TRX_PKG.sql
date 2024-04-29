--------------------------------------------------------
--  DDL for Package JAI_AR_SUP_TRX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_AR_SUP_TRX_PKG" 
/* $Header: jai_ar_sup_trx.pls 120.1 2005/07/20 12:56:56 avallabh ship $ */
AUTHID CURRENT_USER AS

PROCEDURE process_report_stpr(p_batch_id number);

PROCEDURE identify_invoices(P_BATCH_ID NUMBER);

PROCEDURE process_invoices;

PROCEDURE create_invoices
        (ERRBUF OUT NOCOPY VARCHAR2,
         RETCODE OUT NOCOPY VARCHAR2,
         CHSN_FOR_CNSLDT IN VARCHAR2);

PROCEDURE calculate_tax(  transaction_name                VARCHAR2            ,
			  P_tax_category_id               NUMBER              ,
			  p_line_id                       NUMBER              ,
			  p_assessable_value              NUMBER default 0    ,
			  p_tax_amount   IN OUT  NOCOPY   NUMBER              ,
			  p_currency_conv_factor          NUMBER              ,
			  p_inventory_item_id             NUMBER              ,
			  p_line_quantity                 NUMBER              ,
			  p_uom_code                      VARCHAR2            ,
			  p_currency                      VARCHAR2            ,
			  p_creation_date                 DATE                ,
			  p_created_by                    NUMBER              ,
			  p_last_update_date              DATE                ,
			  p_last_updated_by               NUMBER              ,
			  p_last_update_login             NUMBER
			);

END jai_ar_sup_trx_pkg;
 

/
