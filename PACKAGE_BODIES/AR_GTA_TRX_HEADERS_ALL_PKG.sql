--------------------------------------------------------
--  DDL for Package Body AR_GTA_TRX_HEADERS_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_GTA_TRX_HEADERS_ALL_PKG" AS
--$Header: ARGUGHAB.pls 120.0.12010000.3 2010/01/19 09:12:38 choli noship $
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     ARUGHAB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|      This package provides table handers for                          |
--|      table AR_GTA_TRX_HEADERS_ALL,these handlers                     |
--|      will be called by 'Golden Tax Workbench' form and 'Golden Tax    |
--|      invoie import' program to operate data in table                  |
--|      AR_GTA_TRX_HEADERS_ALL                                          |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|      PROCEDURE Insert_Row                                             |
--|      PROCEDURE Update_Row                                             |
--|      PROCEDURE Lock_Row                                               |
--|      PROCEDURE Delete_Row                                             |
--|      PROCEDURE Query_Row                                              |
--|                                                                       |
--| HISTORY                                                               |
--|     05/17/05 Donghai Wang       Created                               |
--|     06/21/05 Jogen Hu           Added procedure Query_Row             |
--|     09/26/05 Donghai Wang       Add parameters for procedures         |
--|                                 'Insert_Row','Update_Row' and         |
--|                                 'Lock_Row'
--|     01/02/08 Subba              Modified for R12.1,
--|                                 Added invoice_type parameter to all   |
--|				    procedures.                           |
--      13/Jul/2009 Allen Yang     added procedure Unmerge_Row for bug 8605196:
--                                 ENHANCEMENT FOR GOLDEN TAX ADAPTER R12.1.2
--+======================================================================*/

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
--           p_invoice_type             Invoice type   --added by subba for R12.1
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
--           02-JAN-2008 Subba   added p_invoice_type parameter
--           20-Jul-2009 Yao Zhang modified for bug#8605196 consolidate invoices
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
,p_invoice_type                      IN   VARCHAR2    --added by subba for R12.1
--Yao Zhang add begin for bug#8605196 consolidate invoices
,p_consolidation_id                  IN   NUMBER
,p_consolidation_flag                IN   VARCHAR2
,p_consolidation_trx_num             IN   VARCHAR2
--Yao Zhang add end for bug#8605196 consolidate invoices
)
IS
l_procedure_name    VARCHAR2(100)   :='Insert_Row';
l_dbg_level         NUMBER          :=FND_LOG.G_Current_Runtime_Level;
l_proc_level        NUMBER          :=FND_LOG.Level_Procedure;
CURSOR C IS
SELECT
  ROWID
FROM
  ar_gta_trx_headers_all
WHERE
  gta_trx_header_id=p_gta_trx_header_id;
BEGIN

 --log for debug
  IF( l_proc_level >= l_dbg_level)
  THEN

    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.begin'
                  ,'Enter procedure'
                  );

  END IF;  --( l_proc_level >= l_dbg_level)


  --Insert data into table AR_GTA_TRX_HEADERS_ALL
  INSERT INTO ar_gta_trx_headers_all(
     ra_gl_date
    ,ra_gl_period
    ,set_of_books_id
    ,bill_to_customer_id
    ,bill_to_customer_number
    ,bill_to_customer_name
    ,source
    ,org_id
    ,legal_entity_id
    ,rule_header_id
    ,gta_trx_header_id
    ,gta_trx_number
    ,group_number
    ,version
    ,latest_version_flag
    ,transaction_date
    ,ra_trx_id
    ,ra_trx_number
    ,description
    ,customer_address
    ,customer_phone
    ,customer_address_phone
    ,bank_account_name
    ,bank_account_number
    ,bank_account_name_number
    ,fp_tax_registration_number
    ,tp_tax_registration_number
    ,ra_currency_code
    ,conversion_type
    ,conversion_date
    ,conversion_rate
    ,gta_batch_number
    ,gt_invoice_number
    ,gt_invoice_date
    ,gt_invoice_net_amount
    ,gt_invoice_tax_amount
    ,status
    ,sales_list_flag
    ,cancel_flag
    ,gt_invoice_type
    ,gt_invoice_class
    ,gt_tax_month
    ,issuer_name
    ,reviewer_name
    ,payee_name
    ,tax_code
    ,tax_rate
    ,generator_id
    ,export_request_id
    ,request_id
    ,program_application_id
    ,program_id
    ,program_update_date
    ,attribute_category
    ,attribute1
    ,attribute2
    ,attribute3
    ,attribute4
    ,attribute5
    ,attribute6
    ,attribute7
    ,attribute8
    ,attribute9
    ,attribute10
    ,attribute11
    ,attribute12
    ,attribute13
    ,attribute14
    ,attribute15
    ,creation_date
    ,created_by
    ,last_update_date
    ,last_updated_by
    ,last_update_login
    ,invoice_type                 --added by subba for R12.1
--Yao Zhang add begin for bug#8605196 consolidate invoices
    ,consolidation_flag
    ,consolidation_id
    ,consolidation_trx_num
--Yao Zhang add end for bug#8605196 consolidate invoices
    )
  VALUES(
     p_ra_gl_date
    ,P_ra_gl_period
    ,p_set_of_books_id
    ,p_bill_to_customer_id
    ,p_bill_to_customer_number
    ,p_bill_to_customer_name
    ,p_source
    ,p_org_id
    ,p_legal_entity_id
    ,p_rule_header_id
    ,p_gta_trx_header_id
    ,p_gta_trx_number
    ,p_group_number
    ,p_version
    ,p_latest_version_flag
    ,p_transaction_date
    ,p_ra_trx_id
    ,p_ra_trx_number
    ,p_description
    ,p_customer_address
    ,p_customer_phone
    ,p_customer_address_phone
    ,p_bank_account_name
    ,p_bank_account_number
    ,p_bank_account_name_number
    ,p_fp_tax_registration_number
    ,p_tp_tax_registration_number
    ,p_ra_currency_code
    ,p_conversion_type
    ,p_conversion_date
    ,p_conversion_rate
    ,p_gta_batch_number
    ,p_gt_invoice_number
    ,p_gt_invoice_date
    ,p_gt_invoice_net_amount
    ,P_gt_invoice_tax_amount
    ,p_status
    ,p_sales_list_flag
    ,p_cancel_flag
    ,p_gt_invoice_type
    ,p_gt_invoice_class
    ,p_gt_tax_month
    ,p_issuer_name
    ,p_reviewer_name
    ,p_payee_name
    ,p_tax_code
    ,p_tax_rate
    ,p_generator_id
    ,p_export_request_id
    ,p_request_id
    ,p_program_application_id
    ,p_program_id
    ,p_program_update_date
    ,p_attribute_category
    ,p_attribute1
    ,p_attribute2
    ,p_attribute3
    ,p_attribute4
    ,p_attribute5
    ,p_attribute6
    ,p_attribute7
    ,p_attribute8
    ,p_attribute9
    ,p_attribute10
    ,p_attribute11
    ,p_attribute12
    ,p_attribute13
    ,p_attribute14
    ,p_attribute15
    ,p_creation_date
    ,p_created_by
    ,p_last_update_date
    ,p_last_updated_by
    ,p_last_update_login
    ,p_invoice_type      --added by subba for R12.1
--Yao Zhang add begin for bug#8605196 consolidate invoices
    ,p_consolidation_flag
    ,p_consolidation_id
    ,p_consolidation_trx_num
--Yao Zhang add end for bug#8605196 consolidate invoices
    );

  --In case of insert failed, raise error
  OPEN c;
  FETCH c INTO p_row_id;
  IF (c%NOTFOUND)
  THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF; --(c%NOTFOUND)
  CLOSE C;
--The following code is add by Yao Zhang for exception handle
EXCEPTION
 WHEN OTHERS THEN
  fnd_file.PUT_LINE(fnd_file.LOG,'Exception from header insert row'||SQLCODE || SQLERRM);
     IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.String(FND_LOG.LEVEL_UNEXPECTED,
                     G_MODULE_PREFIX || l_procedure_name ||
                     '. OTHER_EXCEPTION ',
                     'Unknown error' || SQLCODE || SQLERRM);

    END IF;
   RAISE;
 --log for debug
  IF( l_proc_level >= l_dbg_level)
  THEN

    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.end'
                  ,'Exit procedure'
                  );

  END IF;  --( l_proc_level >= l_dbg_level)

END Insert_Row;

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
--           p_invoice_type                Invoice type  --added by Subba for R12.1.
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
--           02-JAN-2008  Subba  added p_invoice_type parameter
--===========================================================================
PROCEDURE Update_Row
(p_row_id                        IN  OUT NOCOPY   VARCHAR2
,p_ra_gl_date                    IN  DATE
,P_ra_gl_period                  IN  VARCHAR
,p_set_of_books_id               IN  NUMBER
,p_bill_to_customer_id           IN  NUMBER
,p_bill_to_customer_number       IN	 VARCHAR2
,p_bill_to_customer_name         IN	 VARCHAR2
,p_source                        IN	 VARCHAR2
,p_org_id                        IN	 NUMBER
,p_legal_entity_id               IN  NUMBER
,p_rule_header_id                IN  NUMBER
,p_gta_trx_header_id             IN	 NUMBER
,p_gta_trx_number                IN	 VARCHAR2
,p_group_number                  IN	 NUMBER
,p_version                       IN	 NUMBER
,p_latest_version_flag           IN  VARCHAR2
,p_transaction_date              IN	 DATE
,p_ra_trx_id                     IN	 NUMBER
,p_ra_trx_number                 IN  VARCHAR2
,p_description                   IN  VARCHAR2
,p_customer_address              IN	 VARCHAR2
,p_customer_phone                IN	 VARCHAR2
,p_customer_address_phone        IN	 VARCHAR2
,p_bank_account_name             IN	 VARCHAR2
,p_bank_account_number           IN	 VARCHAR2
,p_bank_account_name_number      IN	 VARCHAR2
,p_fp_tax_registration_number    IN  VARCHAR2
,p_tp_tax_registration_number    IN  VARCHAR2
,p_ra_currency_code              IN	 VARCHAR2
,p_conversion_type               IN	 VARCHAR2
,p_conversion_date               IN	 DATE
,p_conversion_rate               IN	 NUMBER
,p_gta_batch_number              IN	 VARCHAR2
,p_gt_invoice_number             IN	 VARCHAR2
,p_gt_invoice_date               IN	 DATE
,p_gt_invoice_net_amount         IN	 NUMBER
,P_gt_invoice_tax_amount         IN	 NUMBER
,p_status                        IN	 VARCHAR2
,p_sales_list_flag               IN	 VARCHAR2
,p_cancel_flag                   IN	 VARCHAR2
,p_gt_invoice_type               IN  VARCHAR2
,p_gt_invoice_class              IN  VARCHAR2
,p_gt_tax_month                  IN  VARCHAR2
,p_issuer_name                   IN	 VARCHAR2
,p_reviewer_name                 IN	 VARCHAR2
,p_payee_name                    IN	 VARCHAR2
,p_tax_code                      IN	 VARCHAR2
,p_tax_rate                      IN	 NUMBER
,p_generator_id  	               IN	 NUMBER
,p_export_request_id             IN  NUMBER
,p_request_id                    IN	 NUMBER
,p_program_application_id        IN	 NUMBER
,p_program_id                    IN	 NUMBER
,p_program_update_date           IN	 DATE
,p_attribute_category            IN	 VARCHAR2
,p_attribute1                    IN	 VARCHAR2
,p_attribute2                    IN	 VARCHAR2
,p_attribute3                    IN	 VARCHAR2
,p_attribute4                    IN	 VARCHAR2
,p_attribute5                    IN	 VARCHAR2
,p_attribute6                    IN	 VARCHAR2
,p_attribute7                    IN	 VARCHAR2
,p_attribute8                    IN	 VARCHAR2
,p_attribute9                    IN	 VARCHAR2
,p_attribute10                   IN	 VARCHAR2
,p_attribute11                   IN	 VARCHAR2
,p_attribute12                   IN	 VARCHAR2
,p_attribute13                   IN	 VARCHAR2
,p_attribute14                   IN	 VARCHAR2
,p_attribute15                   IN	 VARCHAR2
,p_creation_date                 IN  DATE
,p_created_by                    IN  NUMBER
,p_last_update_date              IN  DATE
,p_last_updated_by               IN  NUMBER
,p_last_update_login             IN  NUMBER
,p_invoice_type                  IN  VARCHAR2  --added by subba for R12.1
)
IS
l_procedure_name    VARCHAR2(100)   :='Update_Row';
l_dbg_level         NUMBER          :=FND_LOG.G_Current_Runtime_Level;
l_proc_level        NUMBER          :=FND_LOG.Level_Procedure;
BEGIN

 --log for debug
  IF( l_proc_level >= l_dbg_level)
  THEN

    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.begin'
                  ,'Enter procedure'
                  );

  END IF;  --( l_proc_level >= l_dbg_level)

--Update data on table AR_GTA_TRX_HEADERS_ALL
  UPDATE ar_gta_trx_headers_all
     SET
       ra_gl_date   	           =	    p_ra_gl_date
      ,ra_gl_period  	           =	    p_ra_gl_period
      ,set_of_books_id	           =	    p_set_of_books_id
      ,bill_to_customer_id	   =	    p_bill_to_customer_id
      ,bill_to_customer_number	   =	    p_bill_to_customer_number
      ,bill_to_customer_name	   =	    p_bill_to_customer_name
      ,source       	           =	    p_source
      ,org_id       	           =	    p_org_id
      ,legal_entity_id           =      p_legal_entity_id
      ,rule_header_id 	           =	    p_rule_header_id
      ,gta_trx_header_id	   =	    p_gta_trx_header_id
      ,gta_trx_number	           =	    p_gta_trx_number
      ,group_number 	           =	    p_group_number
      ,version      	           =	    p_version
      ,latest_version_flag         =	    p_latest_version_flag
      ,transaction_date	           =	    p_transaction_date
      ,ra_trx_id    	           =	    p_ra_trx_id
      ,ra_trx_number               =        p_ra_trx_number
      ,description  	           =	    p_description
      ,customer_address	           =	    p_customer_address
      ,customer_phone	           =	    p_customer_phone
      ,customer_address_phone	   =	    p_customer_address_phone
      ,bank_account_name	   =	    p_bank_account_name
      ,bank_account_number	   =	    p_bank_account_number
      ,bank_account_name_number    =	    p_bank_account_name_number
      ,fp_tax_registration_number  =      p_fp_tax_registration_number
      ,tp_tax_registration_number  =      p_tp_tax_registration_number
      ,ra_currency_code	           =	    p_ra_currency_code
      ,conversion_type	           =	    p_conversion_type
      ,conversion_date	           =	    p_conversion_date
      ,conversion_rate             =	    p_conversion_rate
      ,gta_batch_number	           =	    p_gta_batch_number
      ,gt_invoice_number	   =	    p_gt_invoice_number
      ,gt_invoice_date	           =	    p_gt_invoice_date
      ,gt_invoice_net_amount	   =	    p_gt_invoice_net_amount
      ,gt_invoice_tax_amount	   =	    P_gt_invoice_tax_amount
      ,status       	           =	    p_status
      ,sales_list_flag	           =	    p_sales_list_flag
      ,cancel_flag  	           =	    p_cancel_flag
      ,gt_invoice_type             =	    p_gt_invoice_type
      ,gt_invoice_class            =	    p_gt_invoice_class
      ,gt_tax_month                =	    p_gt_tax_month
      ,issuer_name  	           =	    p_issuer_name
      ,reviewer_name	           =	    p_reviewer_name
      ,payee_name   	           =	    p_payee_name
      ,tax_code     	           =	    p_tax_code
      ,tax_rate     	           =	    p_tax_rate
      ,generator_id  	           =	    p_generator_id
      ,export_request_id           =        p_export_request_id
      ,request_id   	           =	    p_request_id
      ,program_application_id	   =	    p_program_application_id
      ,program_id   	           =	    p_program_id
      ,program_update_date	   =	    p_program_update_date
      ,attribute_category	   =	    p_attribute_category
      ,attribute1   	           =	    p_attribute1
      ,attribute2   	           =	    p_attribute2
      ,attribute3   	           =	    p_attribute3
      ,attribute4   	           =	    p_attribute4
      ,attribute5   	           =	    p_attribute5
      ,attribute6   	           =	    p_attribute6
      ,attribute7   	           =	    p_attribute7
      ,attribute8   	           =	    p_attribute8
      ,attribute9   	           =	    p_attribute9
      ,attribute10   	           =	    p_attribute10
      ,attribute11   	           =	    p_attribute11
      ,attribute12   	           =	    p_attribute12
      ,attribute13   	           =	    p_attribute13
      ,attribute14   	           =	    p_attribute14
      ,attribute15   	           =	    p_attribute15
      ,creation_date               =	    p_creation_date
      ,created_by                  =	    p_created_by
      ,last_update_date            =	    p_last_update_date
      ,last_updated_by             =	    p_last_updated_by
      ,last_update_login	   =	    p_last_update_login
      ,invoice_type                =        p_invoice_type    --added by subba for R12.1
  WHERE ROWID=p_row_id;

  --In case of update failed, raise error
  IF (SQL%NOTFOUND)
  THEN
    RAISE NO_DATA_FOUND;
  END IF; --(SQL%NOTFOUND)

 --log for debug
  IF( l_proc_level >= l_dbg_level)
  THEN

    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.end'
                  ,'Exit procedure'
                  );

  END IF;  --( l_proc_level >= l_dbg_level)


END Update_Row;



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
--           p_invoice_type                Invoice type   --added by subba for R12.1
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
--           02-JAN-2008 Subba added p_invoice_type parameter.
--           13-Jul-2009 Allen Yang modified for bug 8605196: ENHANCEMENT FOR GOLDEN TAX ADAPTER R12.1.2
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
,p_invoice_type                IN  VARCHAR2  --added by subba for R12.1
)
IS
l_procedure_name    VARCHAR2(100)   :='Lock_Row';
l_dbg_level         NUMBER          :=FND_LOG.G_Current_Runtime_Level;
l_proc_level        NUMBER          :=FND_LOG.Level_Procedure;

CURSOR c IS
SELECT
  *
FROM
  ar_gta_trx_headers_all
WHERE ROWID=p_row_id
FOR UPDATE OF gta_trx_header_id NOWAIT;

recinfo c%ROWTYPE;
BEGIN

 --log for debug
  IF( l_proc_level >= l_dbg_level)
  THEN

    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.begin'
                  ,'Begin procedure'
                  );

  END IF;  --( l_proc_level >= l_dbg_level)

  --If a record has been deleted as form tries to excute dml operation
  --on that record,then raise error to form
  OPEN c;
  FETCH c INTO recinfo;
  IF (c%NOTFOUND)
  THEN
    CLOSE c;
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.Raise_Exception;
  END IF;  --(c%NOTFOUND)
  CLOSE c;

  --To judge if a record has been changed by other programs as the form
  --tries to execute DML operation on that record,if 'Yes', raise error,
  --else the form will be able to do DML operation on the record.
  IF (
   (recinfo.ra_gl_date=p_ra_gl_date)
      AND
      (rtrim(recinfo.ra_gl_period)=p_ra_gl_period)
      AND
      (recinfo.set_of_books_id=p_set_of_books_id)
      AND
      (recinfo.bill_to_customer_id=p_bill_to_customer_id)
      AND
      (
       (rtrim(recinfo.bill_to_customer_number)=p_bill_to_customer_number)
       OR
       (
        (rtrim(recinfo.bill_to_customer_number) IS NULL)
        AND
        (p_bill_to_customer_number IS NULL)
       )
      )
      AND
      (rtrim(recinfo.bill_to_customer_name)=p_bill_to_customer_name)
      AND
      (rtrim(recinfo.SOURCE)=p_source)
      AND
      (recinfo.org_id=p_org_id)
      AND
      (recinfo.legal_entity_id=p_legal_entity_id)
      -- modified by Allen Yang 13/Jul/2009 for bug 8605196: ENHANCEMENT FOR GOLDEN TAX ADAPTER R12.1.2
      AND
      --(recinfo.rule_header_id=p_rule_header_id)
      (
       (recinfo.rule_header_id=p_rule_header_id)
       OR
       (
        (recinfo.rule_header_id IS NULL)
        AND
        (p_rule_header_id IS NULL)
       )
      )
      -- end modified by allen
      AND
      (recinfo.gta_trx_header_id=p_gta_trx_header_id)
      AND
      (rtrim(recinfo.gta_trx_number)=p_gta_trx_number)
      AND
      (
       (rtrim(recinfo.group_number)=p_group_number)
       OR
       (
        (rtrim(recinfo.group_number) IS NULL)
        AND
        (p_group_number IS NULL)
       )
      )
      AND
      (recinfo.version=p_version)
      AND
      (rtrim(recinfo.latest_version_flag)=p_latest_version_flag)
      AND
      (recinfo.transaction_date=p_transaction_date)
      -- modified by Allen Yang 13/Jul/2009 for bug 8605196: ENHANCEMENT FOR GOLDEN TAX ADAPTER R12.1.2
      AND
      --(recinfo.ra_trx_id=p_ra_trx_id)
      (
       (recinfo.ra_trx_id=p_ra_trx_id)
       OR
       (
        (recinfo.ra_trx_id IS NULL)
        AND
        (p_ra_trx_id IS NULL)
       )
      )
      -- end modified by allen
      AND
      (
       (rtrim(recinfo.ra_trx_number)=p_ra_trx_number)
       OR
       (
        (rtrim(recinfo.ra_trx_number) IS NULL)
        AND
        (p_ra_trx_number IS NULL)
       )
      )
      AND
      (
       (rtrim(recinfo.description)=p_description)
       OR
       (
        (rtrim(recinfo.description) IS NULL)
        AND
        (p_description IS NULL)
       )
      )
      AND
      (
       (rtrim(recinfo.customer_address)=p_customer_address)
       OR
       (
        (rtrim(recinfo.customer_address) IS NULL)
        AND
        (p_customer_address IS NULL)
       )
      )
      AND
      (
       (rtrim(recinfo.customer_phone)=p_customer_phone)
       OR
       (
        (rtrim(recinfo.customer_phone) IS NULL)
        AND
        (p_customer_phone IS NULL)
       )
      )
      AND
      (
       (rtrim(recinfo.customer_address_phone)=rtrim(p_customer_address_phone))
       OR
       (
        (recinfo.customer_address_phone IS NULL)
        AND
        (p_customer_address_phone IS NULL)
       )
      )
      AND
      (
       (rtrim(recinfo.bank_account_name)=p_bank_account_name)
       OR
       (
        (rtrim(recinfo.bank_account_name) IS NULL)
        AND
        (p_bank_account_name IS NULL)
       )
      )
      AND
      (
       (rtrim(recinfo.bank_account_number)=p_bank_account_number)
       OR
       (
        (rtrim(recinfo.bank_account_number) IS NULL)
        AND
        (p_bank_account_number IS NULL)
       )
      )
      AND
      (
       (rtrim(recinfo.bank_account_name_number)=p_bank_account_name_number)
       OR
       (
        (rtrim(recinfo.bank_account_name_number) IS NULL)
        AND
        (p_bank_account_name_number IS NULL)
       )
      )
      AND
      (
       (rtrim(recinfo.fp_tax_registration_number)=p_fp_tax_registration_number)
       OR
       (
        (rtrim(recinfo.fp_tax_registration_number) IS NULL)
        AND
        (p_fp_tax_registration_number IS NULL)
       )
      )
      AND
      (
       (rtrim(recinfo.tp_tax_registration_number)=p_tp_tax_registration_number)
       OR
       (
        (rtrim(recinfo.tp_tax_registration_number) IS NULL)
        AND
        (p_tp_tax_registration_number IS NULL)
       )
      )
      AND
      (
       (rtrim(recinfo.ra_currency_code)=p_ra_currency_code)
       OR
       (
        (rtrim(recinfo.ra_currency_code) IS NULL)
        AND
        (p_ra_currency_code IS NULL)
       )
      )
      AND
      (
       (rtrim(recinfo.conversion_type)=p_conversion_type)
       OR
       (
        (rtrim(recinfo.conversion_type) IS NULL)
        AND
        (p_conversion_type IS NULL)
       )
      )
      AND
      (
       (recinfo.conversion_date=p_conversion_date)
       OR
       (
        (recinfo.conversion_date IS NULL)
        AND
        (p_conversion_date IS NULL)
       )
      )
      AND
      (
       (recinfo.conversion_rate=p_conversion_rate)
       OR
       (
        (recinfo.conversion_rate IS NULL)
        AND
        (p_conversion_rate IS NULL)
       )
      )
      AND
      (
       (rtrim(recinfo.gta_batch_number)=p_gta_batch_number)
       OR
       (
        (rtrim(recinfo.gta_batch_number) IS NULL)
        AND
        (p_gta_batch_number IS NULL)
       )
      )
      AND
      (
       (rtrim(recinfo.gt_invoice_number)=p_gt_invoice_number)
       OR
       (
        (rtrim(recinfo.gt_invoice_number) IS NULL)
        AND
        (p_gt_invoice_number IS NULL)
       )
      )
      AND
      (
       (recinfo.gt_invoice_date=p_gt_invoice_date)
       OR
       (
        (recinfo.gt_invoice_date IS NULL)
        AND
        (p_gt_invoice_date IS NULL)
       )
      )
      AND
      (
       (recinfo.gt_invoice_net_amount=p_gt_invoice_net_amount)
       OR
       (
        (recinfo.gt_invoice_net_amount IS NULL)
        AND
        (p_gt_invoice_net_amount IS NULL)
       )
      )
      AND
      (
       (recinfo.gt_invoice_tax_amount=p_gt_invoice_tax_amount)
       OR
       (
        (recinfo.gt_invoice_tax_amount IS NULL)
        AND
        (p_gt_invoice_tax_amount IS NULL)
       )
      )
      AND
      (rtrim(recinfo.status)=p_status)
      AND
      (
       (rtrim(recinfo.sales_list_flag)=p_sales_list_flag)
       OR
       (
        (rtrim(recinfo.sales_list_flag) IS NULL)
        AND
        (p_sales_list_flag IS NULL)
       )
      )
      AND
      (
       (recinfo.cancel_flag=p_cancel_flag)
       OR
       (
        (recinfo.cancel_flag IS NULL)
        AND
        (p_cancel_flag IS NULL)
       )
      )
      AND
      (
       (rtrim(recinfo.gt_invoice_type)=p_gt_invoice_type)
       OR
       (
        (rtrim(recinfo.gt_invoice_type) IS NULL)
        AND
        (p_gt_invoice_type IS NULL)
       )
      )
      AND
      (
       (rtrim(recinfo.gt_invoice_class)=p_gt_invoice_class)
       OR
       (
        (rtrim(recinfo.gt_invoice_class) IS NULL)
        AND
        (p_gt_invoice_class IS NULL)
       )
      )
      AND
      (
       (rtrim(recinfo.gt_tax_month)=p_gt_tax_month)
       OR
       (
        (rtrim(recinfo.gt_tax_month) IS NULL)
        AND
        (p_gt_tax_month IS NULL)
       )
      )
      AND
      (
       (rtrim(recinfo.issuer_name)=p_issuer_name)
       OR
       (
        (rtrim(recinfo.issuer_name) IS NULL)
        AND
        (p_issuer_name IS NULL)
       )
      )
      AND
      (
       (rtrim(recinfo.reviewer_name)=p_reviewer_name)
       OR
       (
        (rtrim(recinfo.reviewer_name) IS NULL)
        AND
        (p_reviewer_name IS NULL)
       )
      )
      AND
      (
       (rtrim(recinfo.payee_name)=p_payee_name)
       OR
       (
        (rtrim(recinfo.payee_name) IS NULL)
        AND
        (p_payee_name IS NULL)
       )
      )
      AND
      (
       (recinfo.tax_code=p_tax_code)
       OR
       (
        (rtrim(recinfo.tax_code) IS NULL)
        AND
        (p_tax_code IS NULL)
       )
      )
     AND
      (
       (recinfo.tax_rate=p_tax_rate)
       OR
       (
        (recinfo.tax_rate IS NULL)
        AND
        (p_tax_rate IS NULL)
       )
      )
      AND
      (
       (recinfo.generator_id=p_generator_id)
       OR
       (
        (recinfo.generator_id IS NULL)
        AND
        (p_generator_id IS NULL)
       )
      )
      AND
      (
       (recinfo.export_request_id=p_export_request_id)
       OR
       (
        (recinfo.export_request_id IS NULL)
        AND
        (p_export_request_id IS NULL)
       )
      )
      AND
      (recinfo.creation_date=p_creation_date)
      AND
      (recinfo.created_by=p_created_by)
      AND
      (recinfo.last_update_date=p_last_update_date)
      AND
      (recinfo.last_updated_by=p_last_updated_by)
      AND
      (
       (recinfo.last_update_login=p_last_update_login)
       OR
       (
        (recinfo.last_update_login IS NULL)
        AND
        (p_last_update_login IS NULL)
       )
      )
      AND
      (
       (recinfo.request_id=p_request_id)
       OR
       (
        (recinfo.request_id IS NULL)
        AND
        (p_request_id IS NULL)
       )
      )
      AND
      (
       (recinfo.program_application_id=p_program_application_id)
       OR
       (
        (recinfo.program_application_id IS NULL)
        AND
        (p_program_application_id IS NULL)
       )
      )
      AND
      (
       (recinfo.program_id=p_program_id)
       OR
       (
        (recinfo.program_id IS NULL)
        AND
        (p_program_id IS NULL)
       )
      )
      AND
      (
       (recinfo.program_update_date=p_program_update_date)
       OR
       (
        (recinfo.program_update_date IS NULL)
        AND
        (p_program_update_date IS NULL)
       )
      )
      AND
      (
       (rtrim(recinfo.attribute_category)=p_attribute_category)
       OR
       (
        (rtrim(recinfo.attribute_category) IS NULL)
        AND
        (p_attribute_category IS NULL)
       )
      )
      AND
      (
       (rtrim(recinfo.attribute1)=p_attribute1)
       OR
       (
        (rtrim(recinfo.attribute1) IS NULL)
        AND
        (p_attribute1 IS NULL)
       )
      )
      AND
      (
       (rtrim(recinfo.attribute2)=p_attribute2)
       OR
       (
        (rtrim(recinfo.attribute2) IS NULL)
        AND
        (p_attribute2 IS NULL)
       )
      )
      AND
      (
       (rtrim(recinfo.attribute3)=p_attribute3)
       OR
       (
        (rtrim(recinfo.attribute3) IS NULL)
        AND
        (p_attribute3 IS NULL)
       )
      )
      AND
      (
       (rtrim(recinfo.attribute4)=p_attribute4)
       OR
       (
        (rtrim(recinfo.attribute4) IS NULL)
        AND
        (p_attribute4 IS NULL)
       )
      )
      AND
      (
       (rtrim(recinfo.attribute5)=p_attribute5)
       OR
       (
        (rtrim(recinfo.attribute5) IS NULL)
        AND
        (p_attribute5 IS NULL)
       )
      )
      AND
      (
       (rtrim(recinfo.attribute6)=p_attribute6)
       OR
       (
        (rtrim(recinfo.attribute6) IS NULL)
        AND
        (p_attribute6 IS NULL)
       )
      )
      AND
      (
       (rtrim(recinfo.attribute7)=p_attribute7)
       OR
       (
        (rtrim(recinfo.attribute7) IS NULL)
        AND
        (p_attribute7 IS NULL)
       )
      )
      AND
      (
       (rtrim(recinfo.attribute8)=p_attribute8)
       OR
       (
        (rtrim(recinfo.attribute8) IS NULL)
        AND
        (p_attribute8 IS NULL)
       )
      )
      AND
      (
       (rtrim(recinfo.attribute9)=p_attribute9)
       OR
       (
        (rtrim(recinfo.attribute9) IS NULL)
        AND
        (p_attribute9 IS NULL)
       )
      )
      AND
      (
       (rtrim(recinfo.attribute10)=p_attribute10)
       OR
       (
        (rtrim(recinfo.attribute10) IS NULL)
        AND
        (p_attribute10 IS NULL)
       )
      )
      AND
      (
       (rtrim(recinfo.attribute11)=p_attribute11)
       OR
       (
        (rtrim(recinfo.attribute11) IS NULL)
        AND
        (p_attribute11 IS NULL)
       )
      )
      AND
      (
       (rtrim(recinfo.attribute12)=p_attribute12)
       OR
       (
        (rtrim(recinfo.attribute12) IS NULL)
        AND
        (p_attribute12 IS NULL)
       )
      )
      AND
      (
       (rtrim(recinfo.attribute13)=p_attribute13)
       OR
       (
        (rtrim(recinfo.attribute13) IS NULL)
        AND
        (p_attribute13 IS NULL)
       )
      )
      AND
      (
       (rtrim(recinfo.attribute14)=p_attribute14)
       OR
       (
        (rtrim(recinfo.attribute14) IS NULL)
        AND
        (p_attribute14 IS NULL)
       )
      )
      AND
      (
       (rtrim(recinfo.attribute15)=p_attribute15)
       OR
       (
        (rtrim(recinfo.attribute15) IS NULL)
        AND
        (p_attribute15 IS NULL)
       )
      )
      AND (rtrim(recinfo.invoice_type) = p_invoice_type)   --added by subba for R12.1
  )
  THEN
    RETURN;
   ELSE
     FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
     APP_EXCEPTION.Raise_Exception;
  END IF;  --((recinfo.ra_gl_date=p_ra_gl_date) ...

   --log for debug
  IF( l_proc_level >= l_dbg_level)
  THEN

    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.end'
                  ,'Exit procedure'
                  );

  END IF;  --( l_proc_level >= l_dbg_level)
END Lock_Row;

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
--      In:
--
--  In Out:  p_row_id                   Row id of a table record
--
--
--  DESIGN REFERENCES:
--    GTA_Workbench_Form_TD.doc
--
--  CHANGE HISTORY:
--
--           17-MAY-2005	Donghai Wang created
--           13/Jul/2009  Allen Yang modified for bug 8605196:
--                        ENHANCEMENT FOR GOLDEN TAX ADAPTER R12.1.2
--           05/Sep/2009  Allen Yang modified for bug 8882568
--===========================================================================
PROCEDURE Delete_Row
(p_rowid                         IN OUT NOCOPY VARCHAR2
)
IS
l_procedure_name    VARCHAR2(100)   :='Delete_Row';
l_dbg_level         NUMBER          :=FND_LOG.G_Current_Runtime_Level;
l_proc_level        NUMBER          :=FND_LOG.Level_Procedure;
-- added by Allen Yang for bug 8605196: ENHANCEMENT FOR GOLDEN TAX ADAPTER R12.1.2
-----------------------------------------------------------------------------------
l_consolidation_flag  AR_GTA_TRX_HEADERS_ALL.CONSOLIDATION_FLAG%TYPE;
l_consol_trx_num      AR_GTA_TRX_HEADERS_ALL.CONSOLIDATION_TRX_NUM%TYPE;
-----------------------------------------------------------------------------------
BEGIN

 --log for debug
  IF( l_proc_level >= l_dbg_level)
  THEN

    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.begin'
                  ,'Begin procedure'
                  );

  END IF;  --( l_proc_level >= l_dbg_level)

  -- added by Allen Yang for bug 8605196: ENHANCEMENT FOR GOLDEN TAX ADAPTER R12.1.2
  ----------------------------------------------------------------------------------
  -- get current consolidation invoice number
  SELECT gta_trx_number
       , consolidation_flag
  INTO   l_consol_trx_num
        ,l_consolidation_flag
  FROM  AR_GTA_TRX_HEADERS_ALL
  WHERE rowid = p_rowid;

  -- set all consolidated invoices as stats 'DRAFT' and consolidation_flag NULL
  IF NVL(l_consolidation_flag, ' ') = '0'
  THEN
    UPDATE AR_GTA_TRX_HEADERS_ALL
    SET STATUS = 'DRAFT'
       ,CONSOLIDATION_FLAG = NULL
       ,CONSOLIDATION_TRX_NUM = NULL
       -- modified by Allen Yang for bug #8882568 concurrency control 05-Sep-2009
       -------------------------------------------------------------------
       ,CONSOLIDATION_REQUEST_ID = NULL
       ,CONSOLIDATION_ID = NULL
       -------------------------------------------------------------------
    WHERE CONSOLIDATION_TRX_NUM = l_consol_trx_num
    AND   CONSOLIDATION_FLAG = '1';
  END IF;  --  NVL(l_consolidation_flag, ' ') = '0'
  --------------------------------------------------------------------------

  --Delete row from table AR_GTA_TRX_HEADERS_ALL
  DELETE
  FROM
    ar_gta_trx_headers_all
  WHERE rowid = p_rowid;

  --In case of delete failed,raise error
  IF (SQL%NOTFOUND)
  THEN
    RAISE NO_DATA_FOUND;
  END IF; --(SQL%NOTFOUND)

 --log for debug
  IF( l_proc_level >= l_dbg_level)
  THEN

    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.end'
                  ,'Exit procedure'
                  );

  END IF;  --( l_proc_level >= l_dbg_level)

END Delete_Row;

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
--           26-Sep-2005  Donghai Wang   Add three columns 'LEGAL_ENTITY_ID'
--                                                         'FP_TAX_REGISTRATION_NUMBER
--                                                         'TP_TAX_REGISTRATON_NUMBER
--           02-JAN-2008 Subba  Added new column 'invoice_type' for R12.1
--===========================================================================
PROCEDURE Query_Row
(p_header_id      IN NUMBER
,x_trx_header_rec OUT NOCOPY AR_GTA_TRX_UTIL.Trx_Header_Rec_Type
)
IS
l_procedure_name    VARCHAR2(100)   :='Query_Row';
l_dbg_level         NUMBER          :=FND_LOG.G_Current_Runtime_Level;
l_proc_level        NUMBER          :=FND_LOG.Level_Procedure;
BEGIN

 --log for debug
  IF( l_proc_level >= l_dbg_level)
  THEN

    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.begin'
                  ,'Begin procedure'
                  );

  END IF;  --( l_proc_level >= l_dbg_level)

  --Retrive data from AR_GTA_TRX_HEADERS_ALL and store them into PL/SQL record
  SELECT
    ra_gl_date
   ,ra_gl_period
   ,set_of_books_id
   ,bill_to_customer_id
   ,bill_to_customer_number
   ,bill_to_customer_name
   ,source
   ,org_id
   ,legal_entity_id
   ,rule_header_id
   ,gta_trx_header_id
   ,gta_trx_number
   ,group_number
   ,version
   ,latest_version_flag
   ,transaction_date
   ,ra_trx_id
   ,ra_trx_number
   ,description
   ,customer_address
   ,customer_phone
   ,customer_address_phone
   ,bank_account_name
   ,bank_account_number
   ,bank_account_name_number
   ,fp_tax_registration_number
   ,tp_tax_registration_number
   ,ra_currency_code
   ,conversion_type
   ,conversion_date
   ,conversion_rate
   ,gta_batch_number
   ,gt_invoice_number
   ,gt_invoice_date
   ,gt_invoice_net_amount
   ,gt_invoice_tax_amount
   ,status
   ,sales_list_flag
   ,cancel_flag
   ,gt_invoice_type
   ,gt_invoice_class
   ,gt_tax_month
   ,issuer_name
   ,reviewer_name
   ,payee_name
   ,tax_code
   ,tax_rate
   ,generator_id
   ,request_id
   ,program_application_id
   ,program_id
   ,program_update_date
   ,attribute_category
   ,attribute1
   ,attribute2
   ,attribute3
   ,attribute4
   ,attribute5
   ,attribute6
   ,attribute7
   ,attribute8
   ,attribute9
   ,attribute10
   ,attribute11
   ,attribute12
   ,attribute13
   ,attribute14
   ,attribute15
   ,creation_date
   ,created_by
   ,last_update_date
   ,last_updated_by
   ,last_update_login
   ,invoice_type    --added by subba for R12.1
   --Yao Zhang add for bug8605196
   ,consolidation_flag
   ,consolidation_id
   ,consolidation_trx_num
  INTO
    x_trx_header_rec.ra_gl_date
   ,x_trx_header_rec.ra_gl_period
   ,x_trx_header_rec.set_of_books_id
   ,x_trx_header_rec.bill_to_customer_id
   ,x_trx_header_rec.bill_to_customer_number
   ,x_trx_header_rec.bill_to_customer_name
   ,x_trx_header_rec.source
   ,x_trx_header_rec.org_id
   ,x_trx_header_rec.legal_entity_id
   ,x_trx_header_rec.rule_header_id
   ,x_trx_header_rec.gta_trx_header_id
   ,x_trx_header_rec.gta_trx_number
   ,x_trx_header_rec.group_number
   ,x_trx_header_rec.version
   ,x_trx_header_rec.latest_version_flag
   ,x_trx_header_rec.transaction_date
   ,x_trx_header_rec.ra_trx_id
   ,x_trx_header_rec.ra_trx_number
   ,x_trx_header_rec.description
   ,x_trx_header_rec.customer_address
   ,x_trx_header_rec.customer_phone
   ,x_trx_header_rec.customer_address_phone
   ,x_trx_header_rec.bank_account_name
   ,x_trx_header_rec.bank_account_number
   ,x_trx_header_rec.bank_account_name_number
   ,x_trx_header_rec.fp_tax_registration_number
   ,x_trx_header_rec.tp_tax_registration_number
   ,x_trx_header_rec.ra_currency_code
   ,x_trx_header_rec.conversion_type
   ,x_trx_header_rec.conversion_date
   ,x_trx_header_rec.conversion_rate
   ,x_trx_header_rec.gta_batch_number
   ,x_trx_header_rec.gt_invoice_number
   ,x_trx_header_rec.gt_invoice_date
   ,x_trx_header_rec.gt_invoice_net_amount
   ,x_trx_header_rec.gt_invoice_tax_amount
   ,x_trx_header_rec.status
   ,x_trx_header_rec.sales_list_flag
   ,x_trx_header_rec.cancel_flag
   ,x_trx_header_rec.gt_invoice_type
   ,x_trx_header_rec.gt_invoice_class
   ,x_trx_header_rec.gt_tax_month
   ,x_trx_header_rec.issuer_name
   ,x_trx_header_rec.reviewer_name
   ,x_trx_header_rec.payee_name
   ,x_trx_header_rec.tax_code
   ,x_trx_header_rec.tax_rate
   ,x_trx_header_rec.generator_id
   ,x_trx_header_rec.request_id
   ,x_trx_header_rec.program_application_id
   ,x_trx_header_rec.program_id
   ,x_trx_header_rec.program_update_date
   ,x_trx_header_rec.attribute_category
   ,x_trx_header_rec.attribute1
   ,x_trx_header_rec.attribute2
   ,x_trx_header_rec.attribute3
   ,x_trx_header_rec.attribute4
   ,x_trx_header_rec.attribute5
   ,x_trx_header_rec.attribute6
   ,x_trx_header_rec.attribute7
   ,x_trx_header_rec.attribute8
   ,x_trx_header_rec.attribute9
   ,x_trx_header_rec.attribute10
   ,x_trx_header_rec.attribute11
   ,x_trx_header_rec.attribute12
   ,x_trx_header_rec.attribute13
   ,x_trx_header_rec.attribute14
   ,x_trx_header_rec.attribute15
   ,x_trx_header_rec.creation_date
   ,x_trx_header_rec.created_by
   ,x_trx_header_rec.last_update_date
   ,x_trx_header_rec.last_updated_by
   ,x_trx_header_rec.last_update_login
   ,x_trx_header_rec.invoice_type     --added by subba for R12.1
   --Yao Zhang add for bug8605196
   ,x_trx_header_rec.consolidation_flag
   ,x_trx_header_rec.consolidation_id
   ,x_trx_header_rec.consolidation_trx_num

  FROM
    ar_gta_trx_headers_all
  WHERE gta_trx_header_id=p_header_id;

 --log for debug
  IF( l_proc_level >= l_dbg_level)
  THEN

    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.end'
                  ,'Exit procedure'
                  );

  END IF;  --( l_proc_level >= l_dbg_level)

END query_row;

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
--           05-Sep-2009  Allen Yang modified for bug 8882568
--===========================================================================
PROCEDURE Unmerge_Row
(p_rowid               IN OUT NOCOPY VARCHAR2
)
IS
l_procedure_name    VARCHAR2(100)   :='Unmerge_Row';
l_dbg_level         NUMBER          :=FND_LOG.G_Current_Runtime_Level;
l_proc_level        NUMBER          :=FND_LOG.Level_Procedure;
l_consol_trx_num    AR_GTA_TRX_HEADERS_ALL.GTA_TRX_NUMBER%TYPE;
BEGIN

  --log for debug
  IF( l_proc_level >= l_dbg_level)
  THEN
    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.begin'
                  ,'Begin procedure'
                  );
  END IF;  --( l_proc_level >= l_dbg_level)

  -- get current consolidation invoice number
  SELECT gta_trx_number
  INTO   l_consol_trx_num
  FROM   AR_GTA_TRX_HEADERS_ALL
  WHERE  rowid = p_rowid;

  -- set status of consolidated invoices as 'DRAFT' and consolidation_flag as null
  UPDATE AR_GTA_TRX_HEADERS_ALL
  SET STATUS = 'DRAFT'
    , CONSOLIDATION_FLAG = NULL
    , CONSOLIDATION_TRX_NUM = NULL
    -- added by Allen Yang for bug #8882568 concurrency control 05-Sep-2009
    -------------------------------------------------------------------
    , CONSOLIDATION_REQUEST_ID = NULL
    , CONSOLIDATION_ID = NULL
    -------------------------------------------------------------------
  WHERE CONSOLIDATION_TRX_NUM = l_consol_trx_num
  AND   CONSOLIDATION_FLAG = '1';

  -- need to delete data from AR_GTA_TRX_HEADERS_V first?????
  --Delete row from table AR_GTA_TRX_HEADERS_ALL
  /* will delete_record in form trigger, so remove the logic here
  DELETE
  FROM
    ar_gta_trx_headers_all
  WHERE rowid = p_rowid;
  */
  --In case of update failed,raise error
  IF (SQL%NOTFOUND)
  THEN
    RAISE NO_DATA_FOUND;
  END IF; --(SQL%NOTFOUND)

  --log for debug
  IF( l_proc_level >= l_dbg_level)
  THEN
    FND_LOG.String(l_proc_level
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.end'
                  ,'Exit procedure'
                  );
  END IF;  --( l_proc_level >= l_dbg_level)
END Unmerge_Row;


END ar_gta_trx_headers_all_pkg;

/
