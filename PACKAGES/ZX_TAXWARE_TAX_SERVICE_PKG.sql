--------------------------------------------------------
--  DDL for Package ZX_TAXWARE_TAX_SERVICE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TAXWARE_TAX_SERVICE_PKG" AUTHID CURRENT_USER as
/*$Header: zxtxwsrvcpkgs.pls 120.2 2006/01/04 14:29:31 vchallur ship $*/
/*Global variables*/
NOT_VALID_VERSION Varchar2(10):='NOT_VALID';
/*User defined Exceptions*/
VERSION_ERROR  EXCEPTION;
WRONG_BUSINESS_FLOW EXCEPTION;

G_MESSAGES_TBL          ZX_TAX_PARTNER_PKG.messages_tbl_type;
err_count               number := 0;


PROCEDURE CALCULATE_TAX_API
       (p_currency_tab        IN OUT NOCOPY ZX_TAX_PARTNER_PKG.tax_currencies_tbl_type,
	x_tax_lines_tbl          OUT NOCOPY ZX_TAX_PARTNER_PKG.tax_lines_tbl_type,
	x_error_status           OUT NOCOPY VARCHAR2,
	x_messages_tbl           OUT NOCOPY ZX_TAX_PARTNER_PKG.messages_tbl_type);

Procedure SYNCHRONIZE_TAXWARE_REPOSITORY
	(x_output_sync_tax_lines OUT NOCOPY zx_tax_partner_pkg.output_sync_tax_lines_tbl_type,
   	 x_return_status         OUT NOCOPY varchar2,
   	 x_messages_tbl          OUT NOCOPY ZX_TAX_PARTNER_PKG.messages_tbl_type) ;


Procedure GLOBAL_DOCUMENT_UPDATE
	(x_transaction_rec       IN         zx_tax_partner_pkg.trx_rec_type,
   	 x_return_status         OUT NOCOPY varchar2,
   	 x_messages_tbl          OUT NOCOPY ZX_TAX_PARTNER_PKG.messages_tbl_type) ;

END ZX_TAXWARE_TAX_SERVICE_PKG;

 

/
