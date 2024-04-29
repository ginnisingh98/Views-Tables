--------------------------------------------------------
--  DDL for Package AR_GTA_TRX_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_GTA_TRX_UTIL" AUTHID CURRENT_USER AS
----$Header: ARGUGTAS.pls 120.0.12010000.3 2010/01/19 09:27:14 choli noship $
--+===========================================================================+
--|                    Copyright (c) 2005 Oracle Corporation
--|                      Redwood Shores, California, USA
--|                            All rights reserved.
--+===========================================================================
--|
--|  FILENAME :
--|      ARUGTAS.pls
--|
--|  DESCRIPTION:
--|      This package is a collection of  the util procedure
--|      or function.
--|
--| PROCEDURE LIST
--|      PROCEDURE    Output_Conc
--|      PROCEDURE    Create_Trxs
--|      PROCEDURE    Create_Trx
--|      FUNCTION     Get_Gtainvoice_Amount
--|      FUNCTION     Get_Gtainvoice_Original_Amount
--|      PROCEDURE    Delete_Header_Line_Cascade
--|      FUNCTION     Get_Gtainvoice_Tax_Amount
--|      FUNCTION     Check_Taxcount_Of_Arline
--|      FUNCTION     Check_Taxcount_Of_Artrx
--|      FUNCTION     Get_Arinvoice_Amount
--|      FUNCTION     Get_Arinvoice_Tax_Amount
--|      FUNCTION     Format_Date
--|      FUNCTION     Get_Primary_Phone_Number
--|      FUNCTION     Get_Operatingunit
--|      FUNCTION     Get_Customer_Name
--|      FUNCTION     Get_Arline_Amount
--|      FUNCTION     Get_Arline_Vattax_Amount
--|      FUNCTION     Get_Arline_Vattax_Rate
--|      PROCEDURE    Get_Bank_Info
--|      PROCEDURE    Verify_Tax_Line
--|      PROCEDURE    Get_Info_From_Ebtax
--|      PROCEDURE    Get_Tp_Tax_Registration_Number
--|      FUNCTION     Get_Arline_Tp_Taxreg_Number
--|      PROCEDURE    Debug_Output
--|      FUNCTION     Get_AR_Batch_Source_Name
--|      FUNCTION     To_Xsd_Date_String
--|      FUNCTION     Format_Monetary_Amount
--|      FUNCTION     Get_Invoice_Type
--|      PROCEDURE    Populate_Invoice_Type
--|      PROCEDURE    Populate_Invoice_Type_Header
--|
--|  HISTORY:
--|       20-APR-2005: Jim Zheng  Created
--|
--|     22-Aug-2005: Jim Zheng  Modify: New feature about registration
--|                                     Number
--|
--|     11-Oct-2005: Jim Zheng  Modify: modify some select tax_line_id code
--|                                     in get_info_from_ebtax
--|                                     add where entity_code = 'TRANSACTONS'.
--|
--|     13-OCt-2005: Jim Zheng  Modify: modify the parametere of
--|                                     get_tp_tax_registration. remove the
--|                                     input para p_trx_line_id, add a new
--\                                     input parameter p_tax_line_id
--|                                     add a new procedure verify_tax_line.
--|                                     add a new procedure debug_output
--|     19-Oct-2005: Jim Zheng Modify:  update the procedure
--|                                     get_info_from_ebtax, add a output
--|                                     parameter
--|                                     x_taxable_amount_org for get original
--|                                      currency amount.
--|     20-Oct-2005: Jim Zheng Modify:  Add a procedure debug_output_conc for
--|                                     dubug report. remove the hard code
--|                                     for fp_registration_number
--|                                     in get_info_from_ebtax
--|                                     Add tax_rate/100 in output value
--|                                     in get_info_from_ebtax
--|     24-Nov-2005  Donghai Wang       Modify procedure 'Get_Arline_Amount'
--|                                     to add a new parameter
--|                                     and use real code to replace dummy code
--|     24-Nov-2005  Donghai Wang       Add a new parameter for function
--|                                    'Get_Arline_Vattax_Amount'
--|     24-Nov-2005  Donghai Wang       Add a new parameter for function
--|                                     'Get_Arline_Vattax_Rate'
--|     25-Nov-2005  Donghai Wang       Add a new function
--|                                     Get_Arline_Tp_Taxreg_Number
--|     25-Nov-2005  Donghai Wang       Add a new function
--|                                     'Check_Taxcount_Of_Arline'
--|     25-Nov-2005  Donghai Wang       Add a new function
--|                                     'Check_Taxcount_Of_Artrx'
--|     25-Nov-2005  Donghai Wang       update function 'Get_Arinvoice_Amount'
--|                                     to follow ebtax logic
--|     25-Nov-2005  Donghai Wang       update functon
--|                                     'Get_Arinvoice_Tax_Amount'
--|                                     to follow ebtax logic
--|     28-Nov-2005  Jim Zheng          remove the default value of
--|                                     fp regi number, procedure
--|                                     get_info_from_ebtax
--|     28-Nov-2005  Jim Zheng          remove the default value of return
--|                                     status of procedure get_info_from_ebtax
--|     28-Nov-2005  Jim Zheng          add GTA currency code when get tax line
--|                                     in procedure verify_tax_line.
--|     01-DEC-2005  Qiang Li           add a new function Get_AR_Batch_Source_Name
--|     29-JUN-2006  Shujuan Yan        In Get_Info_From_Ebtax, Add a output
--|                                     parameter x_tax_curr_unit_price to
--|                                     store the unit price of tax currency
--|                                     for bug 5168900
--|    14-Sep-2006   Donghai Wang       Added the new function
--|                                     To_Xsd_Date_String to convert date
--|                                     values into XSD format so that they can
--|                                     be formatted correctly in XML Publisher
--|                                     Reports for bug 5521629.
--|    20-Sep-2006   Donghai Wang       Added the new function
--                                      Fomrat_Monetary_Amount
--
--|     28-Dec-2007   Subba              Added new function get_invoice_type for R12.1,
--|                                      Added new column 'invoice_type' to trx_header_rec_type
--|    01-Apr-2009    Yao Zhang          Add new function get_cm_band_info to Fix bug 8234250
--|                                      adding new bank information getting logic for Credit Memo
--|    16-Jun-2009    Yao Zhang          Modified for bug#8605196  Modify type trx_line_rec_type to support discount line
--|    20-Jul-2009    Yao Zhang          Add procedure  get_trx for bug#8605196 to query gta trx from database
--|    08-Aug-2009    Yao Zhang          Fix bug#8770356, add new para to consolparas_rec_type
--|    16-Aug-2009    Allen Yang         Add procedures Populate_Invoice_Type
--|                                      and Populate_Invoice_Type_Header to do data migration from R12.0 to R12.1.X
--+===========================================================================+

--Declare global variable for package name
g_module_prefix VARCHAR2(30) := 'ar.plsql.AR_GTA_TRX_UTIL';

--The Record for the parameters of transfer program
TYPE transferparas_rec_type IS RECORD
(customer_num_from  hz_cust_accounts.account_number%TYPE
,customer_num_to    hz_cust_accounts.account_number%TYPE
,customer_name_from hz_parties.party_name%TYPE
,customer_name_to   hz_parties.party_name%TYPE
,gl_period          VARCHAR2(30)
,gl_date_from       ra_cust_trx_line_gl_dist_all.gl_date%TYPE
,gl_date_to         ra_cust_trx_line_gl_dist_all.gl_date%TYPE
,trx_batch_from     ra_batches_all.NAME%TYPE
,trx_batch_to       ra_batches_all.NAME%TYPE
,trx_number_from    ra_customer_trx_all.trx_number%TYPE
,trx_number_to      ra_customer_trx_all.trx_number%TYPE
,trx_date_from      ra_customer_trx_all.trx_date%TYPE
,trx_date_to        ra_customer_trx_all.trx_date%TYPE
,doc_num_from       ra_customer_trx_all.doc_sequence_value%TYPE
,doc_num_to         ra_customer_trx_all.doc_sequence_value%TYPE);

--Add by Yao Zhang for bug#8605196 ER3 consolidation invoice
--The Record for the parameters of consolidation program
TYPE consolparas_rec_type IS RECORD
(consolidation_id    NUMBER
,same_pri_same_dis VARCHAR2(1)
,same_pri_diff_dis VARCHAR2(1)
,diff_pri          VARCHAR2(1)
,sales_list_flag   VARCHAR2(1)
,org_id            NUMBER(15)--yao zhang add for bug#8770356
);

TYPE condition_para_tbl_type IS TABLE OF VARCHAR2(100);

--This record is the data type of AR_GTA_TRX_HEADERS_ALL;
TYPE trx_header_rec_type IS RECORD
(row_id                     VARCHAR2(30)
,ra_gl_date                 ar_gta_trx_headers_all.ra_gl_date%TYPE
,ra_gl_period               ar_gta_trx_headers_all.ra_gl_period%TYPE
,set_of_books_id            ar_gta_trx_headers_all.set_of_books_id%TYPE
,bill_to_customer_id        ar_gta_trx_headers_all.bill_to_customer_id%TYPE
,bill_to_customer_number    ar_gta_trx_headers_all.bill_to_customer_number%TYPE
,bill_to_customer_name      ar_gta_trx_headers_all.bill_to_customer_name%TYPE
,SOURCE                     ar_gta_trx_headers_all.SOURCE%TYPE
,org_id                     ar_gta_trx_headers_all.org_id%TYPE
,rule_header_id             ar_gta_trx_headers_all.rule_header_id%TYPE
,gta_trx_header_id          ar_gta_trx_headers_all.gta_trx_header_id%TYPE
,gta_trx_number             ar_gta_trx_headers_all.gta_trx_number%TYPE
,group_number               ar_gta_trx_headers_all.group_number%TYPE
,version                    ar_gta_trx_headers_all.version%TYPE
,latest_version_flag        ar_gta_trx_headers_all.latest_version_flag%TYPE
,transaction_date           ar_gta_trx_headers_all.transaction_date%TYPE
,ra_trx_id                  ar_gta_trx_headers_all.ra_trx_id%TYPE
,ra_trx_number              ar_gta_trx_headers_all.ra_trx_number%TYPE
,description                ar_gta_trx_headers_all.description%TYPE
,customer_address           ar_gta_trx_headers_all.customer_address%TYPE
,customer_phone             ar_gta_trx_headers_all.customer_phone%TYPE
,customer_address_phone     ar_gta_trx_headers_all.customer_address_phone%TYPE
,bank_account_name          ar_gta_trx_headers_all.bank_account_name%TYPE
,bank_account_number        ar_gta_trx_headers_all.bank_account_number%TYPE
,bank_account_name_number   ar_gta_trx_headers_all.bank_account_name_number%TYPE
,fp_tax_registration_number ar_gta_trx_headers_all.fp_tax_registration_number%TYPE --fp registration number
,tp_tax_registration_number ar_gta_trx_headers_all.tp_tax_registration_number%TYPE --tp registration number
,legal_entity_id            ar_gta_trx_headers_all.legal_entity_id%TYPE -- legal entity id
,ra_currency_code           ar_gta_trx_headers_all.ra_currency_code%TYPE
,conversion_type            ar_gta_trx_headers_all.conversion_type%TYPE
,conversion_date            ar_gta_trx_headers_all.conversion_date%TYPE
,conversion_rate            ar_gta_trx_headers_all.conversion_rate%TYPE
,gta_batch_number           ar_gta_trx_headers_all.gta_batch_number%TYPE
,gt_invoice_number          ar_gta_trx_headers_all.gt_invoice_number%TYPE
,gt_invoice_date            ar_gta_trx_headers_all.gt_invoice_date%TYPE
,gt_invoice_net_amount      ar_gta_trx_headers_all.gt_invoice_net_amount%TYPE
,gt_invoice_tax_amount      ar_gta_trx_headers_all.gt_invoice_tax_amount%TYPE
,status                     ar_gta_trx_headers_all.status%TYPE
,sales_list_flag            ar_gta_trx_headers_all.sales_list_flag%TYPE
,cancel_flag                ar_gta_trx_headers_all.cancel_flag%TYPE
,gt_invoice_type            ar_gta_trx_headers_all.gt_invoice_type%TYPE
,gt_invoice_class           ar_gta_trx_headers_all.gt_invoice_class%TYPE
,gt_tax_month               ar_gta_trx_headers_all.gt_tax_month%TYPE
,issuer_name                ar_gta_trx_headers_all.issuer_name%TYPE
,reviewer_name              ar_gta_trx_headers_all.reviewer_name%TYPE
,payee_name                 ar_gta_trx_headers_all.payee_name%TYPE
,tax_code                   ar_gta_trx_headers_all.tax_code%TYPE
,tax_rate                   ar_gta_trx_headers_all.tax_rate%TYPE
,generator_id               ar_gta_trx_headers_all.generator_id%TYPE
,export_request_id          ar_gta_trx_headers_all.export_request_id%TYPE
,request_id                 ar_gta_trx_headers_all.request_id%TYPE
,program_application_id     ar_gta_trx_headers_all.program_application_id%TYPE
,program_id                 ar_gta_trx_headers_all.program_id%TYPE
,program_update_date        ar_gta_trx_headers_all.program_update_date%TYPE
,attribute_category         ar_gta_trx_headers_all.attribute_category%TYPE
,attribute1                 ar_gta_trx_headers_all.attribute1%TYPE
,attribute2                 ar_gta_trx_headers_all.attribute2%TYPE
,attribute3                 ar_gta_trx_headers_all.attribute3%TYPE
,attribute4                 ar_gta_trx_headers_all.attribute4%TYPE
,attribute5                 ar_gta_trx_headers_all.attribute5%TYPE
,attribute6                 ar_gta_trx_headers_all.attribute6%TYPE
,attribute7                 ar_gta_trx_headers_all.attribute7%TYPE
,attribute8                 ar_gta_trx_headers_all.attribute8%TYPE
,attribute9                 ar_gta_trx_headers_all.attribute9%TYPE
,attribute10                ar_gta_trx_headers_all.attribute10%TYPE
,attribute11                ar_gta_trx_headers_all.attribute11%TYPE
,attribute12                ar_gta_trx_headers_all.attribute12%TYPE
,attribute13                ar_gta_trx_headers_all.attribute13%TYPE
,attribute14                ar_gta_trx_headers_all.attribute14%TYPE
,attribute15                ar_gta_trx_headers_all.attribute15%TYPE
,creation_date              ar_gta_trx_headers_all.creation_date%TYPE
,created_by                 ar_gta_trx_headers_all.created_by%TYPE
,last_update_date           ar_gta_trx_headers_all.last_update_date%TYPE
,last_updated_by            ar_gta_trx_headers_all.last_updated_by%TYPE
,last_update_login          ar_gta_trx_headers_all.last_update_login%TYPE
,invoice_type               ar_gta_trx_headers_all.invoice_type%TYPE    --added by subba for R12.1
--Yao Zhang add begin for bug8605196 ER3 consolidation invoice
,consolidation_flag         ar_gta_trx_headers_all.consolidation_flag%TYPE
,consolidation_id           ar_gta_trx_headers_all.consolidation_id%TYPE
,consolidation_trx_num      ar_gta_trx_headers_all.consolidation_trx_num%TYPE
--Yao Zhang add end for bug8605196 ER3 consolidation invoice
);

--This record is the data type of AR_GTA_TRX_LINES_ALL;
TYPE trx_line_rec_type IS RECORD
  (
   row_id                   VARCHAR2(30)
  ,org_id                   ar_gta_trx_lines_all.org_id%TYPE
  ,gta_trx_header_id        ar_gta_trx_lines_all.gta_trx_header_id%TYPE
  ,gta_trx_line_id          ar_gta_trx_lines_all.gta_trx_line_id%TYPE
  ,matched_flag             ar_gta_trx_lines_all.matched_flag%TYPE
  ,line_number              ar_gta_trx_lines_all.line_number%TYPE
  ,ar_trx_line_id           ar_gta_trx_lines_all.ar_trx_line_id%TYPE
  ,inventory_item_id        ar_gta_trx_lines_all.inventory_item_id%TYPE
  ,item_number              VARCHAR2(30)--ar_gta_trx_lines_all.item_number%TYPE
  ,item_description         ar_gta_trx_lines_all.item_description%TYPE
  ,item_model               ar_gta_trx_lines_all.item_model%TYPE
  ,item_tax_denomination    ar_gta_trx_lines_all.item_tax_denomination%TYPE
  ,tax_rate                 ar_gta_trx_lines_all.tax_rate%TYPE
  ,uom                      ar_gta_trx_lines_all.uom%TYPE
  ,uom_name                 ar_gta_trx_lines_all.uom_name%TYPE
  ,quantity                 ar_gta_trx_lines_all.quantity%TYPE
  ,price_flag               ar_gta_trx_lines_all.price_flag%TYPE
  ,unit_price               ar_gta_trx_lines_all.unit_price%TYPE
  ,unit_tax_price           ar_gta_trx_lines_all.unit_tax_price%TYPE
  ,amount                   ar_gta_trx_lines_all.amount%TYPE
  ,original_currency_amount ar_gta_trx_lines_all.original_currency_amount%TYPE
  ,tax_amount               ar_gta_trx_lines_all.tax_amount%TYPE
  ,discount_flag            ar_gta_trx_lines_all.discount_flag%TYPE
  ,enabled_flag             ar_gta_trx_lines_all.enabled_flag%TYPE
  ,request_id               ar_gta_trx_lines_all.request_id%TYPE
  ,program_applicaton_id    ar_gta_trx_lines_all.program_application_id%TYPE
  ,program_id               ar_gta_trx_lines_all.program_id%TYPE
  ,program_update_date      ar_gta_trx_lines_all.program_update_date%TYPE
  ,attribute_category       ar_gta_trx_lines_all.attribute_category%TYPE
  ,attribute1               ar_gta_trx_lines_all.attribute1%TYPE
  ,attribute2               ar_gta_trx_lines_all.attribute2%TYPE
  ,attribute3               ar_gta_trx_lines_all.attribute3%TYPE
  ,attribute4               ar_gta_trx_lines_all.attribute4%TYPE
  ,attribute5               ar_gta_trx_lines_all.attribute5%TYPE
  ,attribute6               ar_gta_trx_lines_all.attribute6%TYPE
  ,attribute7               ar_gta_trx_lines_all.attribute7%TYPE
  ,attribute8               ar_gta_trx_lines_all.attribute8%TYPE
  ,attribute9               ar_gta_trx_lines_all.attribute9%TYPE
  ,attribute10              ar_gta_trx_lines_all.attribute10%TYPE
  ,attribute11              ar_gta_trx_lines_all.attribute11%TYPE
  ,attribute12              ar_gta_trx_lines_all.attribute12%TYPE
  ,attribute13              ar_gta_trx_lines_all.attribute13%TYPE
  ,attribute14              ar_gta_trx_lines_all.attribute14%TYPE
  ,attribute15              ar_gta_trx_lines_all.attribute15%TYPE
  ,creation_date            ar_gta_trx_lines_all.creation_date%TYPE
  ,created_by               ar_gta_trx_lines_all.created_by%TYPE
  ,last_update_date         ar_gta_trx_lines_all.last_update_date%TYPE
  ,last_updated_by          ar_gta_trx_lines_all.last_updated_by%TYPE
  ,last_update_login        ar_gta_trx_lines_all.last_update_login%TYPE
  ,fp_tax_registration_number VARCHAR2(50)
  ,tp_tax_registration_number VARCHAR2(50)
  --add begin by Yao Zhang for bug#8605196  to support discount line
  ,discount_amount          ar_gta_trx_lines_all.discount_amount%TYPE
  ,discount_tax_amount      ar_gta_trx_lines_all.discount_tax_amount%TYPE
  ,discount_rate            ar_gta_trx_lines_all.discount_rate%TYPE
  --add end by Yao Zhang for bug#8605196 to support discount line
  );

-- This type is a group of  TRX_line_rec_TYPE;
TYPE trx_line_tbl_type IS TABLE OF trx_line_rec_type;

-- This Type is a invoice which include a header record and a group of line record;
TYPE trx_rec_type IS RECORD(
   trx_header trx_header_rec_type
  ,trx_lines  trx_line_tbl_type);

--This type is a group of TRX_Tbl_TYPE; in fact it is a group of invoice.
TYPE trx_tbl_type IS TABLE OF trx_rec_type;

--==========================================================================
--  PROCEDURE NAME:
--
--    Output_Conc                        Public
--
--  DESCRIPTION:
--
--      This procedure write data to concurrent output file
--      the data can be longer than 4000
--
--  PARAMETERS:
--      In:  p_clob         the content which need output to concurrent output
--
--
--  DESIGN REFERENCES:
--
--
--  CHANGE HISTORY:
--
--           30-APR-2005: qugen.hu   Created.
--
--===========================================================================
PROCEDURE output_conc(p_clob IN CLOB);


--==========================================================================
--  PROCEDURE NAME:
--
--    debug_output_conc                        Public
--
--  DESCRIPTION:
--
--      This procedure write data to concurrent output file
--      the data can be longer than 4000
--
--  PARAMETERS:
--      In:  p_clob         the content which need output to concurrent output
--
--
--  DESIGN REFERENCES:
--
--
--  CHANGE HISTORY:
--
--           30-APR-2005: Jim.zheng   Created.
--
--===========================================================================
PROCEDURE debug_output_conc(p_clob IN CLOB);

--==========================================================================
--  PROCEDURE NAME:
--
--    Create_Trxs                        Public
--
--  DESCRIPTION:
--
--      This package can insert a set of trx to AR_GTA_TRX_HEADS_ALL
--     AND AR_GTA_TRX_LINES_ALL.
--
--  PARAMETERS:
--      In:   p_gta_trxs        trx_tbl_type
--
--
--  DESIGN REFERENCES:
--      GTA-TRANSFER-PROGRAM-TD.doc
--
--  CHANGE HISTORY:
--
--           30-APR-2005: Jim Zheng   Created.
--
--===========================================================================
PROCEDURE create_trxs(p_gta_trxs IN trx_tbl_type);

--==========================================================================
--  PROCEDURE NAME:
--
--    Create_Trx                         Public
--
--  DESCRIPTION:
--
--      This procedure is to insert a GTA transaction
--
--  PARAMETERS:
--      In:   p_gta_trx        Standard API parameter
--
--
--  DESIGN REFERENCES:
--      GTA-TRANSFER-PROGRAM-TD.doc
--
--  CHANGE HISTORY:
--
--           30-APR-2005: Jim Zheng   Created.
--
--===========================================================================
PROCEDURE create_trx(p_gta_trx IN trx_rec_type);
--==========================================================================
--  PROCEDURE NAME:
--
--    Get_Trx                         Public
--
--  DESCRIPTION:
--
--      This procedure is to get GTA transaction by trx header id
--
--  PARAMETERS:
--      In:   p_trx_header_id    Identifier of GTA invoice header
--      Out:  x_trx_rec          Record to store gta transaction
--
--  DESIGN REFERENCES:
--      GTA_12.1.2_Technical_Design.doc
--
--  CHANGE HISTORY:
--
--           30-Jun-2009: Yao Zhang  Created.
--===========================================================================
PROCEDURE Get_Trx
(p_trx_header_id IN  NUMBER
,x_trx_rec       OUT NOCOPY trx_rec_type
);

--==========================================================================
--  FUNCTION NAME:
--
--    Get_Gtainvoice_Amount                   Public
--
--  DESCRIPTION:
--
--      This procedure is to calculate total amount of a GTA invoice
--
--  PARAMETERS:
--      In:   p_header_id     Identifier of GTA Invoice header
--
--  Return:   NUMBER
--
--  DESIGN REFERENCES:
--      GTA-TRANSFER-PROGRAM-TD.doc
--
--  CHANGE HISTORY:
--
--           30-APR-2005: Jim Zheng   Created.
--
--===========================================================================
FUNCTION get_gtainvoice_amount(p_header_id IN NUMBER) RETURN NUMBER;

--==========================================================================
--  FUNCTION NAME:
--
--    Get_Gtainvoice_Original_Amount              Public
--
--  DESCRIPTION:
--
--      This procedure is to calculate total amount of a GTA invoice
--      in original currency code
--
--  PARAMETERS:
--      In:   p_header_id     Identifier of GTA Invoice header
--
--  Return: NUMBER
--
--  DESIGN REFERENCES:
--      GTA-TRANSFER-PROGRAM-TD.doc
--
--  CHANGE HISTORY:
--
--           30-APR-2005: Jim Zheng   Created.
--
--===========================================================================
FUNCTION get_gtainvoice_original_amount(p_header_id IN NUMBER) RETURN NUMBER;

--==========================================================================
--  PROCEDURE NAME:
--
--    Delete_Header_Line_Cascade              Public
--
--  DESCRIPTION:
--
--      This procedure  is to cascade delete a special GTA/GT
--      invoice header with all lines associated with it
--
--  PARAMETERS:
--      In:   p_gta_trx_header_id   GTA/GT invoice header identifier
--
--  DESIGN REFERENCES:
--      GTA-PURGE-PROGRAM-TD.doc
--
--  CHANGE HISTORY:
--
--           8-MAY-2005: Qiang Li   Created
--
--===========================================================================
PROCEDURE delete_header_line_cascade(p_gta_trx_header_id IN NUMBER);

--==========================================================================
--  FUNCTION NAME:
--
--    Get_Gtainvoice_Tax_Amount              Public
--
--  DESCRIPTION:
--
--      This procedure Get Gtainvoice Tax Amount
--
--  PARAMETERS:
--      In:   p_header_id        identifier of Gta Invoice
--
--  Return:   NUMBER
--
--  DESIGN REFERENCES:
--      GTA_Reports_TD.doc
--
--  CHANGE HISTORY:
--
--           8-MAY-2005: Qiang Li   Created
--
--===========================================================================
FUNCTION get_gtainvoice_tax_amount(p_header_id IN NUMBER) RETURN NUMBER;


--==========================================================================
--  FUNCTION NAME:
--
--    Check_Taxcount_Of_Arline                Public
--
--  DESCRIPTION:
--
--      This function is used to check if one AR line has multiple tax line per
--      Tax type and GT currency defined on GTA system option form
--
--  PARAMETERS:
--      In:   p_org_id                   Identifier of operating unit
--            p_customer_trx_line_id     Identifier of transaction line id
--
--  Return:   BOOLEAN
--
--  DESIGN REFERENCES:
--      GTA_Reports_TD.doc
--
--  CHANGE HISTORY:
--
--           25-Nov-2005: Donghai Wang  Created
--
--===========================================================================
FUNCTION Check_Taxcount_Of_Arline
(p_org_id                IN NUMBER
,p_customer_trx_line_id  IN NUMBER
)
RETURN BOOLEAN;

--==========================================================================
--  FUNCTION NAME:
--
--    Check_Taxcount_Of_Artrx               Public
--
--  DESCRIPTION:
--
--      This function is used to check if  AR lines belong to one AR transaction
--      have multiple tax line per Tax type and GT currency defined on GTA system
--      option form.
--
--  PARAMETERS:
--      In:   p_org_id                   Identifier of operating unit
--            p_customer_trx_id          Identifier of AR transaciton
--
--  Return:   BOOLEAN
--
--  DESIGN REFERENCES:
--      GTA_Reports_TD.doc
--
--  CHANGE HISTORY:
--
--           25-Nov-2005: Donghai Wang  Created
--
--===========================================================================
FUNCTION Check_Taxcount_Of_Artrx
(p_org_id                IN NUMBER
,p_customer_trx_id       IN NUMBER
)
RETURN BOOLEAN;

--==========================================================================
--  FUNCTION NAME:
--
--    Get_Arinvoice_Amount              Public
--
--  DESCRIPTION:
--
--     This Function is to get taxable amount of an AR transaction per VAT tax
--     type and GT currency code defind in GTA 'system options' form
--
--  PARAMETERS:
--      In:   p_org_id            identifier of operating unit
--            p_customer_trx_id   identifier of AR transaction
--
--  Return:   NUMBER
--
--  DESIGN REFERENCES:
--      GTA_Reports_TD.doc
--
--  CHANGE HISTORY:
--
--           8-MAY-2005: Qiang Li        Created
--          25-Nov-2005: Donghai Wang    update code due to ebtax requirement
--===========================================================================
FUNCTION Get_Arinvoice_Amount
(p_org_id              IN NUMBER
,p_customer_trx_id     IN NUMBER
)
RETURN NUMBER;

--==========================================================================
--  FUNCTION NAME:
--
--    Get_Arinvoice_Tax_Amount              Public
--
--  DESCRIPTION:
--
--     This Function is to get tax amount of an AR transaction per VAT tax
--     type and GT currency code defind in GTA 'system options' form
--
--  PARAMETERS:
--      In:  p_org_id            identifier of operating unit
--           p_customer_trx_id   identifier of AR transaction
--
--  Return:   Number
--
--  DESIGN REFERENCES:
--      GTA_Reports_TD.doc
--
--  CHANGE HISTORY:
--
--           8-MAY-2005: Qiang Li        Created
--          25-Nov-2005: Donghai Wang    update code due to ebtax requirement
--===========================================================================
FUNCTION Get_Arinvoice_Tax_Amount
(p_org_id              IN NUMBER
,p_customer_trx_id     IN NUMBER
)
RETURN NUMBER;

--==========================================================================
--  FUNCTION NAME:
--
--    Format_Date                  Public
--
--  DESCRIPTION:
--
--      This funtion is to get appropriate format string for
--      a given date according the ICX_DATE_FORMAT_MASK profile
--
--  PARAMETERS:
--      In:   p_date               The date to be formate
--
--  Return:   VARCHAR2
--
--  DESIGN REFERENCES:
--      GTA_Reports_TD.doc
--
--  CHANGE HISTORY:
--
--           23-MAy-2005: Qiang Li  Creation
--
--===========================================================================
FUNCTION format_date(p_date IN DATE) RETURN VARCHAR2;

--==========================================================================
--  FUNCTION NAME:
--
--    Get_Primary_Phone_Number                Public
--
--  DESCRIPTION:
--
--      This procedure is to get primary phone number for a given customer
--
--  PARAMETERS:
--      In:   p_customer_id        Customer identifier
--
--  Return:   VARCHAR2
--
--  DESIGN REFERENCES:
--      GTA_Reports_TD.doc
--
--  CHANGE HISTORY:
--
--           23-MAy-2005: Donghai Wang  Created
--
--===========================================================================
FUNCTION get_primary_phone_number(p_customer_id IN NUMBER) RETURN VARCHAR2;

--==========================================================================
--  FUNCTION NAME:
--
--    Get_Operatingunit                Public
--
--  DESCRIPTION:
--
--      This function is to get operating unit for a given org_id
--
--  PARAMETERS:
--      In:   p_org_id        Identifier of Operating Unit
--
--  Return:   VARCHAR2
--
--  DESIGN REFERENCES:
--      GTA_Reports_TD.doc
--
--  CHANGE HISTORY:
--
--           23-MAy-2005: Qiang Li  Creation
--
--=========================================================================
FUNCTION get_operatingunit(p_org_id IN NUMBER) RETURN VARCHAR2;

--==========================================================================
--  FUNCTION NAME:
--
--    Get_Customer_Name                Public
--
--  DESCRIPTION:
--
--      This function is to get Customer name for a given customer id
--
--  PARAMETERS:
--      In:    p_customer_id        customer identifier
--
--  Return:   VARCHAR2
--
--  DESIGN REFERENCES:
--      GTA_Reports_TD.doc
--
--  CHANGE HISTORY:
--
--           23-MAy-2005: Qiang Li  Creation
--
--=========================================================================
FUNCTION get_customer_name(p_customer_id IN NUMBER) RETURN VARCHAR2;

--==========================================================================
--  FUNCTION NAME:
--
--    Get_Arline_Amount               Public
--
--  DESCRIPTION:
--
--      This function is used to get line amount per Golden Tax currency for
--      one AR line
--
--
--  PARAMETERS:
--      In:   p_org_id                   identifier of operating unit
--            p_customer_trx_line_id     AR line identifier
--  Return:   NUMBER
--
--  DESIGN REFERENCES:
--      GTA_Reports_TD.doc
--
--  CHANGE HISTORY:
--
--           13-Jun-2005: Donghai Wang  Creation
--           24-Nov-2005: Donghai Wang  Add a new parameter
--                                     'p_org_id'
--
--
--=========================================================================
FUNCTION Get_Arline_Amount
(p_org_id              IN NUMBER
,p_customer_trx_line_id IN NUMBER
)
RETURN NUMBER;

--==========================================================================
--  FUNCTION NAME:
--
--    Get_Arline_Vattax_Amount               Public
--
--  DESCRIPTION:
--
--      This function is used to get VAT amount based on one AR line
--      per Golden Tax currency
--
--  PARAMETERS:
--      In:   p_org_id                   Identifier of operating unit
--            p_customer_trx_line_id     AR line identifier
--
--  Return:   NUMBER
--
--  DESIGN REFERENCES:
--      GTA_Reports_TD.doc
--
--  CHANGE HISTORY:
--
--           13-Jun-2005: Donghai Wang  Creation
--
--=========================================================================
FUNCTION Get_Arline_Vattax_Amount
(p_org_id               IN NUMBER
,p_customer_trx_line_id IN NUMBER
)
RETURN NUMBER;

--==========================================================================
--  FUNCTION NAME:
--
--    Get_Arline_Vattax_Rate               Public
--
--  DESCRIPTION:
--
--      This function is used to get VAT rate for one AR line
--
--  PARAMETERS:
--      In:   p_org_id                   Identifier of Operating Unit
--            p_customer_trx_line_id     AR line identifier
--
--  Return:   NUMBER
--
--  DESIGN REFERENCES:
--      GTA_Reports_TD.doc
--
--  CHANGE HISTORY:
--
--           13-Jun-2005: Donghai Wang  Creation
--
--=========================================================================
FUNCTION Get_Arline_Vattax_Rate
(p_org_id               IN NUMBER
,p_customer_trx_line_id IN NUMBER
)
RETURN NUMBER;

--==========================================================================
--  Procedure NAME:
--
--    get_bank_info              Public
--
--  DESCRIPTION:
--
--      This function get bank infomations by cust_Trx_id, if the bank info from AR
--      is null. then get bank infomations by customer_id
--
--  PARAMETERS:
--      In:
--        p_customer_trx_id       IN              NUMBER
--        p_org_id                in              NUMBER
--     OUT:
--       x_bank_name             OUT NOCOPY      VARCHAR2
--       x_bank_branch_name      OUT NOCOPY      VARCHAR2
--       x_bank_account_name     OUT NOCOPY      VARCHAR2
--       x_bank_account_num      OUT NOCOPY      VARCHAR2
--
--
--  DESIGN REFERENCES:
--
--
--  CHANGE HISTORY:
--
--           17-AUG-2005: JIM.Zheng   Created
--
--===========================================================================
PROCEDURE get_bank_info
( p_customer_trx_id       IN              NUMBER
, p_org_id                IN              NUMBER
, x_bank_name             OUT NOCOPY      VARCHAR2
, x_bank_branch_name      OUT NOCOPY      VARCHAR2
, x_bank_account_name     OUT NOCOPY      VARCHAR2
, x_bank_account_num      OUT NOCOPY      VARCHAR2
);
--==========================================================================
--  Procedure NAME:
--
--    get_CM_bank_info              Public
--
--  DESCRIPTION:
--
--      This function get bank infomations for Credit Memos which is
--      created by crediting AR invoice.
--
--  PARAMETERS:
--      In:
--        p_org_id                IN              NUMBER
--        p_customer_trx_id       IN              NUMBER
--        p_original_trx_id       IN              NUMBER
--     OUT:
--       x_bank_name             OUT NOCOPY      VARCHAR2
--       x_bank_branch_name      OUT NOCOPY      VARCHAR2
--       x_bank_account_name     OUT NOCOPY      VARCHAR2
--       x_bank_account_num      OUT NOCOPY      VARCHAR2
--
--
--  DESIGN REFERENCES:
--
--
--  CHANGE HISTORY:
--
--           31-Mar-2009: Yao Zhang   Created
--
--===========================================================================
PROCEDURE Get_CM_Bank_Info
( p_org_id                IN              NUMBER
, p_customer_trx_id       IN              NUMBER
, p_original_trx_id       IN              NUMBER
, x_bank_name             OUT NOCOPY      VARCHAR2
, x_bank_branch_name      OUT NOCOPY      VARCHAR2
, x_bank_account_name     OUT NOCOPY      VARCHAR2
, x_bank_account_num      OUT NOCOPY      VARCHAR2
);

--==========================================================================
--  Procedure NAME:
--
--    verify_tax_line              Public
--
--  DESCRIPTION:
--
--      Verify the tax lines number of a trx line, is it is not 1 , return fail
--
--  PARAMETERS:

--      p_trx_line_id            IN          NUMBER
--      p_tax_type_code          IN          VARCHAR2
--      p_currency_code          in          varchar2
--      x_status                 OUT NOCOPY  NUMBER
--      x_tax_line_id            OUT NOCOPY  zx_lines.tax_line_id%TYPE
--
--
--  DESIGN REFERENCES:
--
--
--  CHANGE HISTORY:
--
--           13-Oct-2005: JIM.Zheng   Created
--
--===========================================================================
PROCEDURE verify_tax_line
(p_trx_line_id      IN          NUMBER
, p_tax_type_code   IN          VARCHAR2
, p_currency_code   IN          VARCHAR2
, x_status          OUT NOCOPY  NUMBER
, x_tax_line_id     OUT NOCOPY  zx_lines.tax_line_id%TYPE
);
--==========================================================================
--  Procedure NAME:
--
--    get_info_from_ebtax              Public
--
--  DESCRIPTION:
--
--      This function get data from ebtax
--
--  PARAMETERS:
--      p_org_id                 IN          NUMBER
--      p_trx_id                 IN          NUMBER
--      p_trx_line_id            IN          NUMBER
--      p_tax_type_code          IN          VARCHAR2
--      x_tax_amount             OUT NOCOPY  NUMBER
--      x_taxable_amount         OUT NOCOPY  NUMBER
--      x_trx_line_quantity      OUT NOCOPY  NUMBER
--      x_tax_rate               OUT NOCOPY  NUMBER
--      x_unit_selling_price     OUT NOCOPY  NUMBER
--      x_taxable_amount         OUT NOCOPY  NUMBER
--      x_fp_registration_number OUT NOCOPY  VARCHAR2
--      x_tp_registration_number OUT NOCOPY  VARCHAR2
--      x_status                 OUT NOCOPY  NUMBER
--      x_error_buffer           OUT NOCOPY  VARCHAR2
--
--
--  DESIGN REFERENCES:
--
--
--  CHANGE HISTORY:
--
--           17-SEP-2005: JIM.Zheng   Created
--
--===========================================================================
-- 29-JUN-2006 Added a parameter x_tax_curr_unit_price to store the unit
-- price of tax currency by Shujuan for bug 5168900
PROCEDURE Get_Info_From_Ebtax
(p_org_id                 IN          NUMBER
,p_trx_id                 IN          NUMBER
,p_trx_line_id            IN          NUMBER
,p_tax_type_code          IN          VARCHAR2
,x_tax_amount             OUT NOCOPY  NUMBER
,x_taxable_amount         OUT NOCOPY  NUMBER
,x_trx_line_quantity      OUT NOCOPY  NUMBER
,x_tax_rate               OUT NOCOPY  NUMBER
,x_unit_selling_price     OUT NOCOPY  NUMBER
,x_tax_curr_unit_price    OUT NOCOPY  NUMBER
,x_taxable_amount_org     OUT NOCOPY  NUMBER
,x_fp_registration_number OUT NOCOPY  VARCHAR2
,x_tp_registration_number OUT NOCOPY  VARCHAR2
,x_status                 OUT NOCOPY  NUMBER
,x_invoice_type           OUT NOCOPY  VARCHAR2
,x_error_buffer           OUT NOCOPY  VARCHAR2
);

--==========================================================================
--  Procedure NAME:
--
--    get_tp_tax_registration_number              Public
--
--  DESCRIPTION:
--
--      This function third party registration number by trx line id
--
--  PARAMETERS:
--      In:
--        p_trx_id       IN              NUMBER
--        p_tax_line_id  in              number
--     OUT:
--       x_tp_tax_registration_number             OUT NOCOPY      VARCHAR2
--
--
--
--  DESIGN REFERENCES:
--
--
--  CHANGE HISTORY:
--
--           17-AUG-2005: JIM.Zheng   Created
--
--===========================================================================
PROCEDURE get_tp_tax_registration_number
( p_trx_id                        IN          NUMBER
, p_tax_line_id                   IN          NUMBER
, x_tp_tax_registration_number    OUT NOCOPY  VARCHAR2
);

--==========================================================================
--  Procedure NAME:
--
--    Get_Arline_Tp_Taxreg_Number              Public
--
--  DESCRIPTION:
--
--      This function is to get third party tax registration number upon one
--      AR line according to GTA logic
--
--  PARAMETERS:
--      In:    p_org_id                 Identifier of operating unit
--             p_customer_trx_id        Identifier of AR transaction
--             p_customer_trx_line_id   Identifier of AR transaction line
--
--     Out:
--
--  Return:
--             VARCHAR2
--
--
--
--  DESIGN REFERENCES:
--     GTA_Reports_TD.doc
--
--  CHANGE HISTORY:
--
--           25-Nov-2005: Donghai Wang   Created
--
--===========================================================================
FUNCTION Get_Arline_Tp_Taxreg_Number
(p_org_id               IN NUMBER
,p_customer_trx_id      IN NUMBER
,p_customer_trx_line_id IN NUMBER
)
RETURN VARCHAR2;

--========================================================================
-- PROCEDURE : debug_output    PUBLIC
-- PARAMETERS: p_output_to            Identifier of where to output to
--             p_log_level            log level
--             p_api_name             the called api name
--             p_message              the message that need to be output
-- COMMENT   : the debug output, for using in readonly UT environment
-- PRE-COND  :
-- EXCEPTIONS:
--========================================================================
PROCEDURE debug_output
( p_output_to IN VARCHAR2
, p_log_level IN NUMBER
, p_api_name  IN VARCHAR2
, p_message   IN VARCHAR2
);

--==========================================================================
--  FUNCTION NAME:
--
--    Get_AR_Batch_Source_Name                Public
--
--  DESCRIPTION:
--
--      This function is to get AR Batch Source Name for a given org_id and
--      source id
--
--  PARAMETERS:
--      In:   p_org_id        Identifier of Operating Unit
--      In:   p_source_id     AR batch source id
--  Return:   VARCHAR2
--
--  DESIGN REFERENCES:
--      GTA_Reports_TD.doc
--
--  CHANGE HISTORY:
--
--           01-Dec-2005: Qiang Li  Creation
--
--=========================================================================
FUNCTION Get_AR_Batch_Source_Name
( p_org_id IN NUMBER
, p_source_id IN NUMBER
)
RETURN VARCHAR2;

--==========================================================================
--  FUNCTION NAME:
--
--    To_Xsd_Date_String                 Public
--
--  DESCRIPTION:
--
--      Convert an Oracle DB Date Object to a date string represented
--      in the XSD Date Format.  This is mainly for use by the
--      XML Publisher Reports.
--
--  PARAMETERS:
--      In:    p_date        Oracle Date to be converted to XSD Date Format
--
--  Return:   VARCHAR2       A String representing the passed in Date in XSD
--                           Date Format
--
--  DESIGN REFERENCES:
--
--
--  CHANGE HISTORY:
--
--           14-Sep-2006: Donghai Wang Creation
--
--=========================================================================
FUNCTION To_Xsd_Date_String
( p_date IN DATE
)
RETURN VARCHAR2;

--==========================================================================
--  FUNCTION NAME:
--
--    Format_Monetary_Amount          Public
--
--  DESCRIPTION:
--
--      Convert monetory amount with the format mask what is determined
--      by VAT currency code and related profile values.
--
--  PARAMETERS:
--      In:    p_org_id      Identifier of Operating Unit
--             p_amount      Monetary amount
--
--  Return:   VARCHAR2
--
--
--  DESIGN REFERENCES:
--
--
--  CHANGE HISTORY:
--
--           20-Sep-2006: Donghai Wang Creation
--
--=========================================================================
FUNCTION Format_Monetary_Amount
(p_org_id  IN NUMBER
,p_amount  IN NUMBER
)
RETURN VARCHAR2;

--=============================================================
--  FUNCTION NAME:
--
--    get_invoice_type                Public
--
--  DESCRIPTION:
--
--  This function is to get invoice type for a given customer_trx_id and -- tax registration number.

--  PARAMETERS:

--      In:    p_org_id                   Business Unit identifier.
--      In:    p_customer_trx_id        AR transaction identifier.
--      In:    p_fp_tax_registration_num  fisrt party registration number
--  Return:   VARCHAR2
--
--CHANGE HISTORY:
--            28-Dec-2007: Subba Created.
--=============================================================

FUNCTION get_invoice_type
(p_org_id IN NUMBER
,p_customer_trx_id IN NUMBER
,p_fp_tax_registration_num IN NUMBER
)
RETURN VARCHAR2;

--==========================================================================
--  PROCEDURE NAME:
--
--    Populate_Invoice_Type                    Public
--
--  DESCRIPTION:
--
--      This procedure is to populate invoice type column for Transfer Rule
--      and System Option tables to do the data migration from R12.0 to
--      R12.1.X.
--
--  PARAMETERS:
--      In: p_org_id     NUMBER
--      Out:
--
--  DESIGN REFERENCES:
--      GTA_12.1.2_Technical_Design.doc
--
--  CHANGE HISTORY:
--
--           16-Aug-2009: Allen Yang   Created.
--
--===========================================================================
PROCEDURE Populate_Invoice_Type(p_org_id IN NUMBER);

--==========================================================================
--  PROCEDURE NAME:
--
--    Populate_Invoice_Type_To_Header                    Public
--
--  DESCRIPTION:
--
--      This procedure is to populate invoice type column for GTA Invoice Header
--      table to do the data migration from R12.0 to R12.1.X.
--
--  PARAMETERS:
--      In:  p_org_id    NUMBER
--      Out:
--
--  DESIGN REFERENCES:
--      GTA_12.1.2_Technical_Design.doc
--
--  CHANGE HISTORY:
--
--           16-Aug-2009: Allen Yang   Created.
--
--===========================================================================
PROCEDURE Populate_Invoice_Type_Header(p_org_id IN NUMBER);

END AR_GTA_TRX_UTIL;

/
