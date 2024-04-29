--------------------------------------------------------
--  DDL for Package AR_GTA_TRX_HEADERS_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_GTA_TRX_HEADERS_ALL_PKG" AUTHID CURRENT_USER AS
--$Header: ARGUGHAS.pls 120.0.12010000.3 2010/01/19 09:07:30 choli noship $
--+=======================================================================+
--|               Copyright (c) 2005 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     ARUGHAS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|      This package provides table handers for                          |
--|      table AR_GTA_TRX_HEADERS_ALL,these handlers                     |
--|      will be called by 'Golden Tax Workbench' form and 'Golden Tax    |
--|      invoie import' program to operate data in table                  |
--|      AR_GTA_TRX_HEADERS_ALL                                          |
--|                                                                       |
--| HISTORY                                                               |
--|     05/17/05 Donghai Wang       Created                               |
--|     06/21/05 Jogen Hu           Added procedure Query_Row             |
--|     09/26/05 Donghai Wang       Add parameters for procedures         |
--|                                 'Insert_Row','Update_Row' and         |
--|                                 'Lock_Row'                            |
--|     06/18/07 Donghai Wang       Update G_MODULE_PREFIX to follow      |
--|                                 FND log standard
--|     01/02/07 Subba              Added parameter 'Invoice_Type'to all  |
--|                                 procedures                            |
--|   13/Jul/2009 Allen Yang        added procedure Unmerge_Row for bug 8605196: |
--|                                 ENHANCEMENT FOR GOLDEN TAX ADAPTER R12.1.2
--|  20/Jul/2009 Yao Zhang          Modifed for bug#8605196 consolidate invoice|
--+======================================================================*/

--Declare global variable for package name
G_MODULE_PREFIX VARCHAR2(50) :='ar.plsql.AR_GTA_TRX_HEADERS_ALL_PKG';

--==========================================================================
--  PROCEDURE NAME:
--
--    Insert_Row                        Public
--
--  DESCRIPTION:
--
--    This procedure is to insert data that are passed in by parameters into
--    table AR_GTA_TRX_HEADERS_ALL to create a new record
--
--  PARAMETERS:
--      In:  p_ra_gl_date                 GL date
--           p_ra_gl_period               GL Period
--           p_set_of_books_id            Identifier of a GL book
--           p_bill_to_customer_id        Identifier of bill to customer
--           p_bill_to_customer_number    Customer number
--           p_bill_to_customer_name      Customer name
--           p_source                     Source of GTA invoice, alternative
--                                        value is 'AR' or 'GT'
--           p_org_id                     Identifier of operating unit
--           p_legal_entity_id            Identifier of legal entity
--           p_rule_header_id             Identifier of transfer rule
--           p_gta_trx_header_id          Identifier of GTA invoice header
--           p_gta_trx_numbe              Number of GTA invoice
--           p_group_number               Identifier of group split
--           p_version                    Version of  a GTA invoice
--           p_latest_version_flag        Flag to identify if a GTA invoice
--                                        is the one with maximum version number
--           p_transaction_date           AR transaction date
--           p_ra_trx_id                  Identifier  of AR transaction
--           p_ra_trx_number              Number of AR transaction
--           p_description                Description of a GTA invoice
--           p_customer_address           Customer address
--           p_customer_phone             Phone number of a customer
--           p_customer_address_phone     Address and phone number of a customer
--           p_bank_account_name          Bank account name
--           p_bank_account_number        Bank account number
--           p_bank_account_name_number   Bank account name and number
--           p_fp_tax_registration_number Tax Registration Number of First Party
--           p_tp_tax_registration_number Tax Registratioin Number of Third Party
--           p_ra_currency_code         Currency code of an AR transaction
--           p_conversion_type          Conversion type of currency
--           p_conversion_date          Currency conversion date
--           p_conversion_rate          exchange rate of currency
--           p_gta_batch_number	        Batch number of GTA invoices
--           p_gt_invoice_number        GT invoice number
--           p_gt_invoice_date          GT invoice date
--           p_gt_invoice_net_amount    Net amount of a GT invoice
--           P_gt_invoice_tax_amount    Tax amount of a GT invoice
--           p_status                   Status of GTA invoice or GT invoice,
--                                      acceptable values is :'DRAFT',
--                                                            'GENERATED',
--                                                            'CANCELLED',
--                                                            'FAILED',
--                                                            'COMPLETED'
--           p_sales_list_flag          Flag to identify if a GTA invoice is
--                                      sale list enbaled
--           p_cancel_flag              Flag to identify if a GT invoice is
--                                      Cancelled or not
--           p_gt_invoice_type          Type of GT invoice
--           p_gt_invoice_class         Class of GT invoice
--           p_gt_tax_month             Tax month of GT invoice
--           p_issuer_name              Issuer name of GT invoice
--           p_reviewer_name            Reviewer name of GT invoice
--           p_payee_name               Payee name of GT invoice
--           p_tax_code                 Tax code
--           p_generator_id             Generator id
--           p_export_request_id        Conc request id of GTA invoice
--                                      export program
--           p_request_id               Conc request id
--           p_program_application_id   Program application id
--           p_program_id               Program id
--           p_program_update_date      Program update date
--           p_attribute_category       Attribute category of
--                                      descriptive flexfield
--           p_attribute1               Attribute1
--           p_attribute2               Attribute2
--           p_attribute3               Attribute3
--           p_attribute4               Attribute4
--           p_attribute5               Attribute5
--           p_attribute6               Attribute6
--           p_attribute7               Attribute7
--           p_attribute8               Attribute8
--           p_attribute9               Attribute9
--           p_attribute10              Attribute10
--           p_attribute11              Attribute11
--           p_attribute12              Attribute12
--           p_attribute13              Attribute13
--           p_attribute14              Attribute14
--           p_attribute15              Attribute15
--           p_creation_date            Creation date
--           p_created_by               Identifier of user that creates
--                                      the record
--           p_last_update_date         Last update date of the record
--           p_last_updated_by          Last update by
--           p_last_update_login        Last update login
--           p_invoice_type             Invoice Type
--
--   In Out: p_row_id                   Row id of a table record
--
--
--  DESIGN REFERENCES:
--    GTA_Workbench_Form_TD.doc
--
--  CHANGE HISTORY:
--
--           17-MAY-2005	Donghai Wang  created
--           26-SEP-2005  Donghai Wang  add three parameters:
--                                        p_legal_entity_id
--                                        p_fp_tax_registration_number
--                                        p_tp_tax_registration_number
--           02-JAN-2008 Subba          add parameter 'invoice_type'
--           20-Jul-2009 Yao Zhang  Modified for bug#8605196 consolidation invoices
--===========================================================================
PROCEDURE Insert_Row
(p_row_id                            IN   OUT NOCOPY  VARCHAR2
,p_ra_gl_date                        IN   DATE
,P_ra_gl_period                      IN   VARCHAR
,p_set_of_books_id                   IN   NUMBER
,p_bill_to_customer_id               IN   NUMBER
,p_bill_to_customer_number           IN	  VARCHAR2
,p_bill_to_customer_name             IN	  VARCHAR2
,p_source                            IN	  VARCHAR2
,p_org_id                            IN	  NUMBER
,p_legal_entity_id                   IN   NUMBER
,p_rule_header_id                    IN   NUMBER
,p_gta_trx_header_id                 IN	  NUMBER
,p_gta_trx_number                    IN	  VARCHAR2
,p_group_number                      IN	  NUMBER
,p_version                           IN	  NUMBER
,p_latest_version_flag               IN   VARCHAR2
,p_transaction_date                  IN	  DATE
,p_ra_trx_id                         IN	  NUMBER
,p_ra_trx_number                     IN   VARCHAR2
,p_description                       IN   VARCHAR2
,p_customer_address                  IN	  VARCHAR2
,p_customer_phone                    IN	  VARCHAR2
,p_customer_address_phone            IN	  VARCHAR2
,p_bank_account_name                 IN	  VARCHAR2
,p_bank_account_number               IN	  VARCHAR2
,p_bank_account_name_number          IN	  VARCHAR2
,p_fp_tax_registration_number        IN   VARCHAR2
,p_tp_tax_registration_number        IN   VARCHAR2
,p_ra_currency_code                  IN	  VARCHAR2
,p_conversion_type                   IN	  VARCHAR2
,p_conversion_date                   IN	  DATE
,p_conversion_rate                   IN	  NUMBER
,p_gta_batch_number                  IN	  VARCHAR2
,p_gt_invoice_number                 IN	  VARCHAR2
,p_gt_invoice_date                   IN	  DATE
,p_gt_invoice_net_amount             IN	  NUMBER
,P_gt_invoice_tax_amount             IN	  NUMBER
,p_status                            IN	  VARCHAR2
,p_sales_list_flag                   IN	  VARCHAR2
,p_cancel_flag                       IN	  VARCHAR2
,p_gt_invoice_type                   IN   VARCHAR2
,p_gt_invoice_class                  IN   VARCHAR2
,p_gt_tax_month                      IN   VARCHAR2
,p_issuer_name                       IN	  VARCHAR2
,p_reviewer_name                     IN	  VARCHAR2
,p_payee_name                        IN	  VARCHAR2
,p_tax_code                          IN	  VARCHAR2
,p_tax_rate                          IN	  NUMBER
,p_generator_id                      IN	  NUMBER
,p_export_request_id                 IN   NUMBER
,p_request_id                        IN	  NUMBER
,p_program_application_id            IN	  NUMBER
,p_program_id                        IN	  NUMBER
,p_program_update_date               IN	  DATE
,p_attribute_category                IN	  VARCHAR2
,p_attribute1                        IN	  VARCHAR2
,p_attribute2                        IN   VARCHAR2
,p_attribute3                        IN	  VARCHAR2
,p_attribute4                        IN	  VARCHAR2
,p_attribute5                        IN	  VARCHAR2
,p_attribute6                        IN	  VARCHAR2
,p_attribute7                        IN	  VARCHAR2
,p_attribute8                        IN	  VARCHAR2
,p_attribute9                        IN	  VARCHAR2
,p_attribute10                       IN	  VARCHAR2
,p_attribute11                       IN	  VARCHAR2
,p_attribute12                       IN	  VARCHAR2
,p_attribute13                       IN	  VARCHAR2
,p_attribute14                       IN	  VARCHAR2
,p_attribute15                       IN	  VARCHAR2
,p_creation_date                     IN   DATE
,p_created_by                        IN   NUMBER
,p_last_update_date                  IN   DATE
,p_last_updated_by                   IN   NUMBER
,p_last_update_login                 IN   NUMBER
,p_invoice_type                      IN   VARCHAR2
--Yao Zhang add begin for bug#8605196 consolidation invoices
,p_consolidation_id                  IN   NUMBER
,p_consolidation_flag                IN   VARCHAR2
,p_consolidation_trx_num             IN   VARCHAR2
--Yao Zhang add end for bug#8605196 consolidation invoices
);


--==========================================================================
--  PROCEDURE NAME:
--
--    Update_Row                        Public
--
--  DESCRIPTION:
--
--    This procedure is used to update data in table AR_GTA_TRX_HEADERS_ALL
--    according to parameters passed in
--
--  PARAMETERS:
--      In:  p_ra_gl_date                  GL date
--           p_ra_gl_period                GL Period
--           p_set_of_books_id             Identifier of a GL book
--           p_bill_to_customer_id         Identifier of bill to customer
--           p_bill_to_customer_number     Customer number
--           p_bill_to_customer_name       Customer name
--           p_source                      Source of GTA invoice, alternative
--                                         value is 'AR' or 'GT'
--           p_org_id                      Identifier of operating unit
--           p_legal_entity_id             Identifier of legal entity id
--           p_rule_header_id              Identifier of transfer rule
--           p_gta_trx_header_id           Identifier of GTA invoice header
--           p_gta_trx_numbe               Number of GTA invoice
--           p_group_number                Identifier of group split
--           p_version                     Version of  a GTA invoice
--           p_latest_version_flag         Flag to identify if a GTA invoice
--                                         is the one with maximum version number
--           p_transaction_date            AR transaction date
--           p_ra_trx_id                   Identifier  of AR transaction
--           p_ra_trx_number               Number of AR transaction
--           p_description                 Description of a GTA invoice
--           p_customer_address            Customer address
--           p_customer_phone              Phone number of a customer
--           p_customer_address_phone      Address and phone number of a customer
--           p_bank_account_name           Bank account name
--           p_bank_account_number         Bank account number
--           p_bank_account_name_number    Bank account name and number
--           p_fp_tax_registration_number  Tax Registration Number of First Party
--           p_tp_tax_registration_number  Tax Registration Number of Third Party
--           p_ra_currency_code            Currency code of an AR transaction
--           p_conversion_type             Conversion type of currency
--           p_conversion_date             Currency conversion date
--           p_conversion_rate             Exchange rate of currency
--           p_gta_batch_number	           Batch number of GTA invoices
--           p_gt_invoice_number           GT invoice number
--           p_gt_invoice_date             GT invoice date
--           p_gt_invoice_net_amount       Net amount of a GT invoice
--           P_gt_invoice_tax_amount       Tax amount of a GT invoice
--           p_status                      Status of GTA invoice or GT invoice,
--                                         acceptable values is :'DRAFT',
--                                                               'GENERATED',
--                                                               'CANCELLED',
--                                                               'FAILED',
--                                                               'COMPLETED'
--           p_sales_list_flag             Flag to identify if a GTA invoice is
--                                         sale list enbaled
--           p_cancel_flag                 Flag to identify if a GT invoice is
--                                         Cancelled or not
--           p_gt_invoice_type             Type of GT invoice
--           p_gt_invoice_class            Class of GT invoice
--           p_gt_tax_month                Tax month of GT invoice
--           p_issuer_name                 Issuer name of GT invoice
--           p_reviewer_name               Reviewer name of GT invoice
--           p_payee_name                  Payee name of GT invoice
--           p_tax_code                    Tax code
--           p_generator_id                Generator id
--           p_export_request_id           Conc request id of GTA invoice
--                                         export program
--           p_request_id                  Conc request id
--           p_program_application_id      Program application id
--           p_program_id                  Program id
--           p_program_update_date         Program update date
--           p_attribute_category          Attribute category of
--                                         descriptive flexfield
--           p_attribute1                  Attribute1
--           p_attribute2                  Attribute2
--           p_attribute3                  Attribute3
--           p_attribute4                  Attribute4
--           p_attribute5                  Attribute5
--           p_attribute6                  Attribute6
--           p_attribute7                  Attribute7
--           p_attribute8                  Attribute8
--           p_attribute9                  Attribute9
--           p_attribute10                 Attribute10
--           p_attribute11                 Attribute11
--           p_attribute12                 Attribute12
--           p_attribute13                 Attribute13
--           p_attribute14                 Attribute14
--           p_attribute15                 Attribute15
--           p_creation_date               Creation date
--           p_created_by                  Identifier of user that creates
--                                         the record
--           p_last_update_date            Last update date of the record
--           p_last_updated_by             Last update by
--           p_last_update_login           Last update login
--           p_invoice_type                Invoice type
--
--  In Out:  p_row_id                      Row id of a table record
--
--
--  DESIGN REFERENCES:
--    GTA_Workbench_Form_TD.doc
--
--  CHANGE HISTORY:
--
--           17-MAY-2005	Donghai Wang created
--           26-SEP-2005  Donghai Wang  add three parameters:
--                                        p_legal_entity_id
--                                        p_fp_tax_registration_number
--                                        p_tp_tax_registration_number
--           02-JAN-2008  Subba         add parameter invoice_type
--===========================================================================
PROCEDURE Update_Row
(p_row_id                      IN  OUT NOCOPY   VARCHAR2
,p_ra_gl_date                  IN  DATE
,P_ra_gl_period                IN  VARCHAR
,p_set_of_books_id             IN  NUMBER
,p_bill_to_customer_id         IN  NUMBER
,p_bill_to_customer_number     IN	 VARCHAR2
,p_bill_to_customer_name       IN	 VARCHAR2
,p_source                      IN	 VARCHAR2
,p_org_id                      IN	 NUMBER
,p_legal_entity_id             IN  NUMBER
,p_rule_header_id              IN  NUMBER
,p_gta_trx_header_id           IN	 NUMBER
,p_gta_trx_number              IN	 VARCHAR2
,p_group_number                IN	 NUMBER
,p_version                     IN	 NUMBER
,p_latest_version_flag         IN  VARCHAR2
,p_transaction_date            IN	 DATE
,p_ra_trx_id                   IN	 NUMBER
,p_ra_trx_number               IN  VARCHAR2
,p_description                 IN  VARCHAR2
,p_customer_address            IN	 VARCHAR2
,p_customer_phone              IN	 VARCHAR2
,p_customer_address_phone      IN	 VARCHAR2
,p_bank_account_name           IN	 VARCHAR2
,p_bank_account_number         IN	 VARCHAR2
,p_bank_account_name_number    IN	 VARCHAR2
,p_fp_tax_registration_number  IN  VARCHAR2
,p_tp_tax_registration_number  IN  VARCHAR2
,p_ra_currency_code            IN	 VARCHAR2
,p_conversion_type             IN	 VARCHAR2
,p_conversion_date             IN	 DATE
,p_conversion_rate             IN	 NUMBER
,p_gta_batch_number            IN	 VARCHAR2
,p_gt_invoice_number           IN	 VARCHAR2
,p_gt_invoice_date             IN	 DATE
,p_gt_invoice_net_amount       IN	 NUMBER
,P_gt_invoice_tax_amount       IN	 NUMBER
,p_status                      IN	 VARCHAR2
,p_sales_list_flag             IN	 VARCHAR2
,p_cancel_flag                 IN	 VARCHAR2
,p_gt_invoice_type             IN  VARCHAR2
,p_gt_invoice_class            IN  VARCHAR2
,p_gt_tax_month                IN  VARCHAR2
,p_issuer_name                 IN	 VARCHAR2
,p_reviewer_name               IN	 VARCHAR2
,p_payee_name                  IN	 VARCHAR2
,p_tax_code                    IN	 VARCHAR2
,p_tax_rate                    IN	 NUMBER
,p_generator_id  	             IN	 NUMBER
,p_export_request_id           IN  NUMBER
,p_request_id                  IN	 NUMBER
,p_program_application_id      IN	 NUMBER
,p_program_id                  IN	 NUMBER
,p_program_update_date         IN	 DATE
,p_attribute_category          IN	 VARCHAR2
,p_attribute1                  IN	 VARCHAR2
,p_attribute2                  IN	 VARCHAR2
,p_attribute3                  IN	 VARCHAR2
,p_attribute4                  IN	 VARCHAR2
,p_attribute5                  IN	 VARCHAR2
,p_attribute6                  IN	 VARCHAR2
,p_attribute7                  IN	 VARCHAR2
,p_attribute8                  IN	 VARCHAR2
,p_attribute9                  IN	 VARCHAR2
,p_attribute10                 IN	 VARCHAR2
,p_attribute11                 IN	 VARCHAR2
,p_attribute12                 IN	 VARCHAR2
,p_attribute13                 IN	 VARCHAR2
,p_attribute14                 IN	 VARCHAR2
,p_attribute15                 IN	 VARCHAR2
,p_creation_date               IN  DATE
,p_created_by                  IN  NUMBER
,p_last_update_date            IN  DATE
,p_last_updated_by             IN  NUMBER
,p_last_update_login           IN  NUMBER
,p_invoice_type                IN  VARCHAR2
);

--==========================================================================
--  PROCEDURE NAME:
--
--    Lock_Row                          Public
--
--  DESCRIPTION:
--
--    This procedure is used to update implement lock on row level on table
--    AR_GTA_TRX_HEADERS_ALL
--
--  PARAMETERS:
--      In:  p_ra_gl_date                  GL date
--           p_ra_gl_period                GL Period
--           p_set_of_books_id             Identifier of a GL book
--           p_bill_to_customer_id         Identifier of bill to customer
--           p_bill_to_customer_number     Customer number
--           p_bill_to_customer_name       Customer name
--           p_source                      Source of GTA invoice, alternative
--                                         value is 'AR' or 'GT'
--           p_org_id                      Identifier of operating unit
--           p_legal_entity_id             Idnetifier of Legal Entity
--           p_rule_header_id              Identifier of transfer rule
--           p_gta_trx_header_id           identifier of GTA invoice header
--           p_gta_trx_numbe               Number of GTA invoice
--           p_group_number                Identifier of group split
--           p_version                     Version of  a GTA invoice
--           p_latest_version_flag         Flag to identify if a GTA invoice
--                                         is the one with maximum version number
--           p_transaction_date            AR transaction date
--           p_ra_trx_id                   Identifier  of AR transaction
--           p_ra_trx_number               Number of AR transaction
--           p_description                 Description of a GTA invoice
--           p_customer_address            Customer address
--           p_customer_phone              Phone number of a customer
--           p_customer_address_phone      Address and phone number of a customer
--           p_bank_account_name           Bank account name
--           p_bank_account_number         Bank account number
--           p_bank_account_name_number    Bank account name and number
--           p_fp_tax_registration_number  Tax Registration Number of First Party
--           p_tp_tax_registration_number  Tax Registration Number of Third Party
--           p_ra_currency_code            Currency code of an AR transaction
--           p_conversion_type             Conversion type of currency
--           p_conversion_date             Currency conversion date
--           p_conversion_rate             Exchange rate of currency
--           p_gta_batch_number	           Batch number of GTA invoices
--           p_gt_invoice_number           GT invoice number
--           p_gt_invoice_date             GT invoice date
--           p_gt_invoice_net_amount       Net amount of a GT invoice
--           P_gt_invoice_tax_amount       Tax amount of a GT invoice
--           p_status                      Status of GTA invoice or GT invoice,
--                                         acceptable values is :'DRAFT',
--                                                               'GENERATED',
--                                                               'CANCELLED',
--                                                               'FAILED',
--                                                               'COMPLETED'
--           p_sales_list_flag             Flag to identify if a GTA invoice is
--                                         sale list enbaled
--           p_cancel_flag                 Flag to identify if a GT invoice is
--                                         Cancelled or not
--           p_gt_invoice_type             Type of GT invoice
--           p_gt_invoice_class            Class of GT invoice
--           p_gt_tax_month                Tax month of GT invoice
--           p_issuer_name                 Issuer name of GT invoice
--           p_reviewer_name               Reviewer name of GT invoice
--           p_payee_name                  Payee name of GT invoice
--           p_tax_code                    Tax code
--           p_generator_id                Generator id
--           p_export_request_id           Conc request id of GTA invoice
--                                         export program
--           p_request_id                  Conc request id
--           p_program_application_id      Program application id
--           p_program_id                  Program id
--           p_program_update_date         Program update date
--           p_attribute_category          Attribute category of
--                                         descriptive flexfield
--           p_attribute1                  Attribute1
--           p_attribute2                  Attribute2
--           p_attribute3                  Attribute3
--           p_attribute4                  Attribute4
--           p_attribute5                  Attribute5
--           p_attribute6                  Attribute6
--           p_attribute7                  Attribute7
--           p_attribute8                  Attribute8
--           p_attribute9                  Attribute9
--           p_attribute10                 Attribute10
--           p_attribute11                 Attribute11
--           p_attribute12                 Attribute12
--           p_attribute13                 Attribute13
--           p_attribute14                 Attribute14
--           p_attribute15                 Attribute15
--           p_creation_date               Creation date
--           p_created_by                  Identifier of user that creates
--                                         the record
--           p_last_update_date            Last update date of the record
--           p_last_updated_by             Last update by
--           p_last_update_login           Last update login
--           p_invoice_type                Invoice type
--
--  In Out:  p_row_id                      Row id of a table record
--
--
--  DESIGN REFERENCES:
--    GTA_Workbench_Form_TD.doc
--
--  CHANGE HISTORY:
--
--           17-MAY-2005	Donghai Wang created
--           26-SEP-2005  Donghai Wang  add three parameters:
--                                        p_legal_entity_id
--                                        p_fp_tax_registration_number
--                                        p_tp_tax_registration_number
--           02-JAN-2008  Subba         add parameter invoice_type
--===========================================================================
PROCEDURE Lock_Row
(p_row_id                      IN  OUT NOCOPY   VARCHAR2
,p_ra_gl_date                  IN  DATE
,P_ra_gl_period                IN  VARCHAR
,p_set_of_books_id	           IN  NUMBER
,p_bill_to_customer_id         IN  NUMBER
,p_bill_to_customer_number     IN  VARCHAR2
,p_bill_to_customer_name       IN  VARCHAR2
,p_source                      IN  VARCHAR2
,p_org_id                      IN  NUMBER
,p_legal_entity_id             IN  NUMBER
,p_rule_header_id              IN  NUMBER
,p_gta_trx_header_id           IN  NUMBER
,p_gta_trx_number              IN  VARCHAR2
,p_group_number                IN  NUMBER
,p_version                     IN  NUMBER
,p_latest_version_flag         IN  VARCHAR2
,p_transaction_date            IN  DATE
,p_ra_trx_id                   IN  NUMBER
,p_ra_trx_number               IN  VARCHAR2
,p_description                 IN  VARCHAR2
,p_customer_address            IN  VARCHAR2
,p_customer_phone              IN  VARCHAR2
,p_customer_address_phone      IN  VARCHAR2
,p_bank_account_name           IN  VARCHAR2
,p_bank_account_number         IN  VARCHAR2
,p_bank_account_name_number    IN  VARCHAR2
,p_fp_tax_registration_number  IN  VARCHAR2
,p_tp_tax_registration_number  IN  VARCHAR2
,p_ra_currency_code            IN  VARCHAR2
,p_conversion_type             IN  VARCHAR2
,p_conversion_date             IN  DATE
,p_conversion_rate             IN  NUMBER
,p_gta_batch_number            IN  VARCHAR2
,p_gt_invoice_number           IN  VARCHAR2
,p_gt_invoice_date             IN  DATE
,p_gt_invoice_net_amount       IN  NUMBER
,P_gt_invoice_tax_amount       IN  NUMBER
,p_status                      IN  VARCHAR2
,p_sales_list_flag             IN  VARCHAR2
,p_cancel_flag                 IN  VARCHAR2
,p_gt_invoice_type             IN  VARCHAR2
,p_gt_invoice_class            IN  VARCHAR2
,p_gt_tax_month                IN  VARCHAR2
,p_issuer_name                 IN  VARCHAR2
,p_reviewer_name               IN  VARCHAR2
,p_payee_name                  IN  VARCHAR2
,p_tax_code                    IN  VARCHAR2
,p_tax_rate                    IN  NUMBER
,p_generator_id                IN  NUMBER
,p_export_request_id           IN  NUMBER
,p_request_id                  IN  NUMBER
,p_program_application_id      IN  NUMBER
,p_program_id                  IN  NUMBER
,p_program_update_date         IN  DATE
,p_attribute_category          IN  VARCHAR2
,p_attribute1                  IN  VARCHAR2
,p_attribute2                  IN  VARCHAR2
,p_attribute3                  IN  VARCHAR2
,p_attribute4                  IN  VARCHAR2
,p_attribute5                  IN  VARCHAR2
,p_attribute6                  IN  VARCHAR2
,p_attribute7                  IN  VARCHAR2
,p_attribute8                  IN  VARCHAR2
,p_attribute9                  IN  VARCHAR2
,p_attribute10                 IN  VARCHAR2
,p_attribute11                 IN  VARCHAR2
,p_attribute12                 IN  VARCHAR2
,p_attribute13                 IN  VARCHAR2
,p_attribute14                 IN  VARCHAR2
,p_attribute15                 IN  VARCHAR2
,p_creation_date               IN  DATE
,p_created_by                  IN  NUMBER
,p_last_update_date            IN  DATE
,p_last_updated_by             IN  NUMBER
,p_last_update_login           IN  NUMBER
,p_invoice_type                IN  VARCHAR2
);

--==========================================================================
--  PROCEDURE NAME:
--
--    Delete_Row                        Public
--
--  DESCRIPTION:
--
--    This procedure is used to delete record from table
--    AR_GTA_TRX_HEADERS_ALL
--
--  PARAMETERS:
--
--      In Out:  p_row_id                   Row id of a table record
--
--
--  DESIGN REFERENCES:
--    GTA_Workbench_Form_TD.doc
--
--  CHANGE HISTORY:
--
--           17-MAY-2005	Donghai Wang created
--
--===========================================================================
PROCEDURE Delete_Row
(p_rowid                         IN OUT NOCOPY VARCHAR2
);

--==========================================================================
--  PROCEDURE NAME:
--
--      Query_Row                       Public
--
--  DESCRIPTION:
--
--    This procedure is used to retrieve record by parameter p_header
--    from table AR_GTA_TRX_HEADERS_ALL
--
--  PARAMETERS:
--      In:   p_header_id                Identifier of GTA invoice header
--
--      Out:  x_trx_header_rec           record to store a row fetched from
--                                       table AR_GTA_TRX_HEADERS_ALL
--
--
--  DESIGN REFERENCES:
--    GTA-Txt-Interface-TD.doc
--
--  CHANGE HISTORY:
--
--           21-Jun-2005	Jogen Hu created
--
--===========================================================================
PROCEDURE Query_Row
( p_header_id      IN NUMBER
, x_trx_header_rec OUT NOCOPY AR_GTA_TRX_UTIL.Trx_Header_Rec_Type
);

--==========================================================================
--  PROCEDURE NAME:
--
--    Unmerge_Row                        Public
--
--  DESCRIPTION:
--
--    	This procedure is to delete current consolidation invoice and
--      change status of its consolidated invoices to 'DRAFT'.
--
--
--  PARAMETERS:
--
--      In Out:  p_rowid                   Row id of a table record
--
--
--  DESIGN REFERENCES:
--           GTA_12.1.2_Technical_Design.doc
--
--  CHANGE HISTORY:
--
--           13-Jul-2009	Allen Yang created
--
--===========================================================================
PROCEDURE Unmerge_Row
(p_rowid                         IN OUT NOCOPY VARCHAR2
);
END  AR_GTA_TRX_HEADERS_ALL_PKG;


/
