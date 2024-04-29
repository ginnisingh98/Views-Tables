--------------------------------------------------------
--  DDL for Package Body ZX_WRAPPER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_WRAPPER_PKG" AS
/* $Header: zxiwrapperpkgb.pls 120.3 2005/08/09 10:55:33 asengupt noship $ */




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
 ) AS
 l_tax_class_code_record ZX_API_PUB.def_tax_cls_code_info_rec_type;

 BEGIN

  l_tax_class_code_record.application_id  :=  p_application_id  ;
  l_tax_class_code_record.entity_code     :=  p_entity_code      ;
  l_tax_class_code_record.event_class_code  := p_event_class_code          ;
  l_tax_class_code_record.internal_organization_id :=    p_internal_organization_id ;
  l_tax_class_code_record.trx_id   :=  p_trx_id                   ;
  l_tax_class_code_record.trx_line_id := p_trx_line_id             ;
  l_tax_class_code_record.trx_level_type := p_trx_level_type        ;
  l_tax_class_code_record.ledger_id   := p_ledger_id              ;
  l_tax_class_code_record.trx_date    := p_trx_date                ;
  l_tax_class_code_record.ref_doc_application_id := p_ref_doc_application_id     ;
  l_tax_class_code_record.ref_doc_entity_code  := p_ref_doc_entity_code      ;
  l_tax_class_code_record.ref_doc_event_class_code := p_ref_doc_event_class_code   ;
  l_tax_class_code_record.ref_doc_trx_id  := p_ref_doc_trx_id         ;
  l_tax_class_code_record.ref_doc_line_id := p_ref_doc_line_id         ;
  l_tax_class_code_record.ref_doc_trx_level_type := p_ref_doc_trx_level_type     ;
  l_tax_class_code_record.account_ccid  := p_account_ccid         ;
  l_tax_class_code_record.account_string := p_account_string        ;
  l_tax_class_code_record.product_id := p_product_id                 ;
 l_tax_class_code_record.product_org_id := p_product_org_id         ;
  l_tax_class_code_record.receivables_trx_type_id := p_receivables_trx_type_id     ;
  l_tax_class_code_record.ship_third_pty_acct_id := p_ship_third_pty_acct_id       ;
  l_tax_class_code_record.bill_third_pty_acct_id := p_bill_third_pty_acct_id       ;
  l_tax_class_code_record.ship_third_pty_acct_site_id := p_ship_third_pty_acct_site_id  ;
  l_tax_class_code_record.bill_third_pty_acct_site_id := p_bill_third_pty_acct_site_id;
  l_tax_class_code_record.ship_to_cust_acct_site_use_id := p_ship_acct_site_use_id;
  l_tax_class_code_record.bill_to_cust_acct_site_use_id := p_bill_acct_site_use_id;
  l_tax_class_code_record.ship_to_location_id   := p_ship_to_location_id      ;
  l_tax_class_code_record.defaulting_attribute1 := p_defaulting_attribute1    ;
  l_tax_class_code_record.defaulting_attribute2 := p_defaulting_attribute2    ;
  l_tax_class_code_record.defaulting_attribute3 := p_defaulting_attribute3    ;
  l_tax_class_code_record.defaulting_attribute4 := p_defaulting_attribute4    ;
  l_tax_class_code_record.defaulting_attribute5 := p_defaulting_attribute5    ;
  l_tax_class_code_record.defaulting_attribute6 := p_defaulting_attribute6    ;
  l_tax_class_code_record.defaulting_attribute7 := p_defaulting_attribute7    ;
  l_tax_class_code_record.defaulting_attribute8 := p_defaulting_attribute8    ;
  l_tax_class_code_record.defaulting_attribute9 := p_defaulting_attribute9    ;
  l_tax_class_code_record.defaulting_attribute10 := p_defaulting_attribute10   ;
  l_tax_class_code_record.tax_user_override_flag := p_tax_user_override_flag    ;
  l_tax_class_code_record.overridden_tax_cls_code := p_overridden_tax_cls_code;


  ZX_API_PUB.redef_tax_classification_code
                (
                        p_api_version               ,
                        p_init_msg_list             ,
                        p_commit                    ,
                        p_validation_level          ,
                        x_msg_count                 ,
                        x_msg_data                  ,
                        x_return_status             ,
                        l_tax_class_code_record
                );

    x_tax_classification_code  := l_tax_class_code_record.x_tax_classification_code;
    x_allow_tax_code_override_flag := l_tax_class_code_record.x_allow_tax_code_override_flag;

end;

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
   ) AS

    	l_transaction_rec ZX_API_PUB.transaction_rec_type;

   BEGIN

	l_transaction_rec.APPLICATION_ID		:=p_application_id;
	l_transaction_rec.ENTITY_CODE			:=p_entity_code;
	l_transaction_rec.EVENT_CLASS_CODE		:=p_event_class_code;
	l_transaction_rec.EVENT_TYPE_CODE       	:=p_event_type_code;
	l_transaction_rec.TRX_ID		   	:=p_trx_id  ;
	l_transaction_rec.INTERNAL_ORGANIZATION_ID 	:=p_internal_organization_id;
	l_transaction_rec.HDR_TRX_USER_KEY1        	:=p_hdr_trx_user_key1;
	l_transaction_rec.HDR_TRX_USER_KEY2        	:=p_hdr_trx_user_key2;
	l_transaction_rec.HDR_TRX_USER_KEY3        	:=p_hdr_trx_user_key3;
	l_transaction_rec.HDR_TRX_USER_KEY4        	:=p_hdr_trx_user_key4;
	l_transaction_rec.HDR_TRX_USER_KEY5        	:=p_hdr_trx_user_key5;
	l_transaction_rec.HDR_TRX_USER_KEY6        	:=p_hdr_trx_user_key6;
	l_transaction_rec.FIRST_PTY_ORG_ID         	:=p_first_pty_org_id;
	l_transaction_rec.TAX_EVENT_CLASS_CODE     	:=p_tax_event_class_code;
	l_transaction_rec.TAX_EVENT_TYPE_CODE      	:=p_tax_event_type_code;
	l_transaction_rec.DOC_EVENT_STATUS         	:=p_doc_event_status;
	l_transaction_rec.APPLICATION_DOC_STATUS   	:=p_application_doc_status;


	ZX_API_PUB.calculate_tax(
					p_api_version,p_init_msg_list	,
					p_commit			,
					p_validation_level		,
					x_return_status			,
					x_msg_count			,
					x_msg_data			,
					l_transaction_rec		,
					p_quote_flag			,
					p_data_transfer_mode		,
					x_doc_level_recalc_flag
				);

   END calculate_tax_wrapper;

END ZX_WRAPPER_PKG;

/
