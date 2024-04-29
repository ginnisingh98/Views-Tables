--------------------------------------------------------
--  DDL for Package ZX_WRAPPER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_WRAPPER_PKG" AUTHID CURRENT_USER AS
/* $Header: zxiwrapperpkgs.pls 120.2 2005/08/09 10:55:22 asengupt noship $ */

/* ======================================================================
 | PROCEDURE redef_tax_class_wrapper: This procedure acts as a wrapper
 | to the ZX_API_PUB.redef_tax_classification_code.It is used to populate
 | the ZX_API_PUB.def_tax_cls_code_info_rec_type and then pass this record
 | as a parameter to redef_tax_classification_code.
 * ======================================================================*/
  PROCEDURE redef_tax_class_wrapper(
  p_api_version                    number,
  p_init_msg_list                  varchar2,
  p_commit                         varchar2,
  p_validation_level               number,
  p_application_id                 number,
  p_entity_code                    varchar2,
  p_event_class_code               varchar2,
  p_internal_organization_id       number,
  p_trx_id                         number,
  p_trx_line_id                    number,
  p_trx_level_type                 varchar2,
  p_ledger_id                      number,
  p_trx_date                       date,
  p_ref_doc_application_id         number,
  p_ref_doc_entity_code            varchar2,
  p_ref_doc_event_class_code       varchar2,
  p_ref_doc_trx_id                 number,
  p_ref_doc_line_id                number,
  p_ref_doc_trx_level_type         varchar2,
  p_account_ccid                   number,
  p_account_string                 varchar2,
  p_product_id                     number,
  p_product_org_id                 number,
  p_receivables_trx_type_id        number,
  p_ship_third_pty_acct_id         number,
  p_bill_third_pty_acct_id         number,
  p_ship_third_pty_acct_site_id    number,
  p_bill_third_pty_acct_site_id    number,
  p_ship_acct_site_use_id          number,
  p_bill_acct_site_use_id          number,
  p_ship_to_location_id            number,
  p_defaulting_attribute1          varchar2,
  p_defaulting_attribute2          varchar2,
  p_defaulting_attribute3          varchar2,
  p_defaulting_attribute4          varchar2,
  p_defaulting_attribute5          varchar2,
  p_defaulting_attribute6          varchar2,
  p_defaulting_attribute7          varchar2,
  p_defaulting_attribute8          varchar2,
  p_defaulting_attribute9          varchar2,
  p_defaulting_attribute10         varchar2,
  p_tax_user_override_flag         varchar2,
  p_overridden_tax_cls_code        varchar2,
  x_tax_classification_code      out    nocopy    varchar2,
  x_allow_tax_code_override_flag out    nocopy    varchar2,
  x_msg_count                    out    nocopy    number ,
  x_msg_data                     out    nocopy    varchar2,
  x_return_status                out    nocopy    varchar2
 );

/* ======================================================================
| PROCEDURE calculate_tax_wrapper: This procedure acts as a wrapper
| to the ZX_API_PUB.calculate_tax.It is used to populate
| the ZX_API_PUB.transaction_rec_type and then pass this record
| as a parameter to calculate_tax.
* ======================================================================*/
PROCEDURE calculate_tax_wrapper
  ( p_api_version           	IN         NUMBER,
    p_init_msg_list         	IN         VARCHAR2,
    p_commit                	IN         VARCHAR2,
    p_validation_level      	IN         NUMBER,
    x_return_status         	OUT NOCOPY VARCHAR2,
    x_msg_count             	OUT NOCOPY NUMBER,
    x_msg_data              	OUT NOCOPY VARCHAR2,
    p_application_id          	IN         NUMBER,
    p_entity_code           	IN         VARCHAR2,
    p_event_class_code      	IN         VARCHAR2,
    p_event_type_code        	IN         VARCHAR2,
    p_trx_id                 	IN         NUMBER,
    p_internal_organization_id  IN         NUMBER,
    p_hdr_trx_user_key1        	IN         VARCHAR2,
    p_hdr_trx_user_key2        	IN         VARCHAR2,
    p_hdr_trx_user_key3       	IN         VARCHAR2,
    p_hdr_trx_user_key4      	IN         VARCHAR2,
    p_hdr_trx_user_key5       	IN         VARCHAR2,
    p_hdr_trx_user_key6       	IN         VARCHAR2,
    p_first_pty_org_id       	IN         NUMBER,
    p_tax_event_class_code     	IN         VARCHAR2,
    p_tax_event_type_code      	IN         VARCHAR2,
    p_doc_event_status        	IN         VARCHAR2,
    p_application_doc_status 	IN         VARCHAR2,
    p_quote_flag            	IN         VARCHAR2,
    p_data_transfer_mode    	IN         VARCHAR2,
    x_doc_level_recalc_flag 	OUT NOCOPY VARCHAR2
   );

END ZX_WRAPPER_PKG;

 

/
