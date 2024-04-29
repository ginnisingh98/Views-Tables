--------------------------------------------------------
--  DDL for Package Body AR_GTA_TRX_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_GTA_TRX_UTIL" AS
--$Header: ARGUGTAB.pls 120.0.12010000.4 2010/03/17 05:52:29 yaozhan noship $
--+===========================================================================+
--|                    Copyright (c) 2005 Oracle Corporation
--|                      Redwood Shores, California, USA
--|                            All rights reserved.
--+===========================================================================
--|
--|  FILENAME :
--|      ARUGTAB.pls
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
--|      FUNCTION     Get_Invoice_Type   --added by subba for R12.1
--|      PROCEDURE    Populate_Invoice_Type
--|      PROCEDURE    Populate_Invoice_Type_Header
--|
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
--|    28-Dec-2007   Subba              Added new function Get_Invoice_Type for R12.1
--|    23-Jan-2008   Subba              Modified code of Get_invoice_Type
--|    13-Feb-2009   Yao Zhang          Fix bug 8234250,Modifiy bank information getting logic
--|                                     for Credit Memo. Add new function get_cm_bank_info to
--|                                     get bank info for credit memos which is created by crediting invoice.
--|    13-May-2009   Yao Zhang          Fix bug#5604079 FOR FOREIGN CURR. TRXN, DISCREPANCY SHOWN DUE TO CURR.
--|                                     ROUNDING ISSU
--|    16-Jun-2009   Yao Zhang          Modified for bug#8605196
--|                                     ER1 Support discount lines:added parameter for insert_row method to support discount line
--|                                     ER2 Support customer name,address,bank info in Chinese
--|    20-Jul-2009    Yao Zhang          Add procedure  get_trx for bug#8605196 to query gta trx from database
--|    16-Aug-2009    Allen Yang        Add procedures Populate_Invoice_Type and
--|                                     Populate_Invoice_Type_Header to do data migration
--|                                     from R12.0 to R12.1.X
--|    26-Aug-2009    Allen Yang        Modified procedure Populate_Invoice_Type_Header
--|                                     for bug 8839141.
--|    12-Mar-2010    Yao Zhang         Fix bug9369455 SPLITED AMOUNT IS NOT CORRECT FOR A USD INVOICE IN GTA
--+===========================================================================+



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
--  CHANGE HISTORY:
--           28-Dec-2007  Subba Created.
--=============================================================


FUNCTION get_invoice_type
(p_org_id IN NUMBER
,p_customer_trx_id IN NUMBER
,p_fp_tax_registration_num IN NUMBER
)
RETURN VARCHAR2
IS
l_procedure_name VARCHAR2(30) := 'get_invoice_type';
l_dbg_level      NUMBER := fnd_log.g_current_runtime_level;
l_proc_level     NUMBER := fnd_log.LEVEL_PROCEDURE;
l_error_string   VARCHAR2(1000);

l_invoice_type     ar_gta_tax_limits_all.invoice_type%TYPE;

BEGIN


  SELECT
    jgtla.invoice_type
  INTO
    l_invoice_type
  FROM
    ar_gta_tax_limits_all       jgtla
    ,ar_gta_type_mappings       jgtm
    ,ra_customer_trx_all         rcta
  WHERE rcta.customer_trx_id = p_customer_trx_id
    AND rcta.cust_trx_type_id = jgtm.transaction_type_id
    AND jgtm.limitation_id = jgtla.limitation_id
    AND jgtla.fp_tax_registration_number = p_fp_tax_registration_num
    AND jgtla.org_id  = p_org_id;


RETURN(l_invoice_type);


EXCEPTION
        WHEN NO_DATA_FOUND THEN

	           l_invoice_type := null;
	           l_error_string := fnd_message.get();


	      /*fnd_message.SET_NAME('AR', 'AR_GTA_MISSING_INVOICE_TYPE');
	      fnd_message.set_token('TRX_TYP',l_trx_typ);
	      fnd_message.set_token('TAX_REG_NUM',p_fp_tax_registration_num);



        -- output error                    '<?xml version="1.0" encoding="UTF-8" ?>
        fnd_file.put_line(fnd_file.output,
                  '<TransferReport>
                  <ReportFailed>Y</ReportFailed>
                  <ReportFailedMsg>'||l_error_string||'</ReportFailedMsg>
                  <FailedWithParameters>Y</FailedWithParameters>
                  </TransferReport>');*/
       -- begin log
        IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        fnd_log.STRING(fnd_log.LEVEL_UNEXPECTED
                                      ,G_MODULE_PREFIX || l_procedure_name
                                      , 'transaction type is not mapped to any invoice type.');
        END IF;
       -- end log
         --RAISE;


RETURN(l_invoice_type);

END get_invoice_type;


--=============================================================================
--  PROCEDURE NAME:
--         log
--  TYPE:
--         private
--
--  DESCRIPTION :
--         This procedure log message
--  PARAMETERS    :
--                p_message IN VARCHAR2
--
-- HISTORY:
--            10-MAY-2005 : Jim.Zheng  Create
--=============================================================================
PROCEDURE log
(p_message IN VARCHAR2)
IS
BEGIN
  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
  fnd_log.STRING(LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE
                ,MODULE    => g_module_prefix || '.Debug'
                ,MESSAGE   => p_message
                );
  END IF;
END log;
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
--           24-Aug-2006: Jogen.hu   change from search '>' to '<'
--
--===========================================================================
PROCEDURE output_conc
(p_clob IN CLOB)
IS/*
max_linesize NUMBER := 254;
l_pos_tag    NUMBER;
l_pos        NUMBER;
l_len        NUMBER;
l_tmp        NUMBER;
l_tmp1       NUMBER;
l_substr     CLOB;
BEGIN
  NULL;
  --initalize
  l_pos := 1;
  l_len := length(p_clob);

  WHILE l_pos <= l_len
  LOOP
    --get the XML tag from reverse direction
    l_tmp     := l_pos + max_linesize - 2 - l_len;
    l_pos_tag := instr(p_clob
                      ,'>'
                      ,l_tmp);

    --the pos didnot touch the end of string
    l_tmp1 := l_pos - 1;

    IF (l_pos_tag > l_tmp1)
       AND (l_tmp < 0)
    THEN
      l_tmp := l_pos_tag - l_pos + 1;
      fnd_file.put(fnd_file.output
                       ,substr(p_clob
                              ,l_pos
                              ,l_tmp));
      l_pos := l_pos_tag + 1;
    ELSE
      l_substr := substr(p_clob
                        ,l_pos);
      fnd_file.put(fnd_file.output
                       ,l_substr);
      l_pos := l_len + 1;

    END IF;

  END LOOP;*/
  --initalize
l_pos1  NUMBER;    --position for '</'
l_pos2  NUMBER;    --position for '>' follow '</'
l_pos3  NUMBER;    --position for '/>'
l_pos   NUMBER;    --latest starting postion
l_len   NUMBER;
l_prepos NUMBER;

BEGIN
  --initalize
  l_pos := 1;
  l_len := length(p_clob);

  WHILE TRUE
  LOOP
    l_prepos:=l_pos;

    l_pos1:=instr(p_clob,'</',l_prepos);
    IF l_pos1>0 THEN
       l_pos2:=instr(p_clob,'>',l_pos1);
    ELSE
       l_pos2:=0;
    END IF;

    l_pos3:=instr(p_clob,'/>',l_prepos);

    IF l_pos2>0 AND l_pos3> 0 THEN
      IF l_pos2>l_pos3 THEN
         l_pos:=l_pos3+2;
      ELSE
         l_pos:=l_pos2+1;
      END IF;
    ELSIF l_pos2>0 THEN
      l_pos:=l_pos2+1;
    ELSE
      l_pos:=l_pos3+2;
    END IF;

    IF l_pos>2 THEN
      FND_FILE.Put_Line(FND_FILE.Output
                       ,substr(p_clob
                              ,l_prepos
                              ,l_pos - l_prepos
                              )
                       );
    ELSE
      FND_FILE.Put_Line(FND_FILE.Log
                       ,substr(p_clob
                              ,l_prepos
                              )
                       );
      EXIT;
    END IF;
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END output_conc;

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
PROCEDURE debug_output_conc
(p_clob IN CLOB)
IS
max_linesize NUMBER := 254;
l_pos_tag    NUMBER;
l_pos        NUMBER;
l_len        NUMBER;
l_tmp        NUMBER;
l_tmp1       NUMBER;
l_substr     CLOB;
BEGIN
  NULL;
  --initalize
  l_pos := 1;
  l_len := length(p_clob);

  WHILE l_pos <= l_len
  LOOP
    --get the XML tag from reverse direction
    l_tmp     := l_pos + max_linesize - 2 - l_len;
    l_pos_tag := instr(p_clob
                      ,'>'
                      ,l_tmp);

    --the pos didnot touch the end of string
    l_tmp1 := l_pos - 1;

    IF (l_pos_tag > l_tmp1)
       AND (l_tmp < 0)
    THEN
      l_tmp := l_pos_tag - l_pos + 1;
      log(substr(p_clob,l_pos,l_tmp));
      l_pos := l_pos_tag + 1;
    ELSE
      l_substr := substr(p_clob
                        ,l_pos);
      log(l_substr);
      l_pos := l_len + 1;

    END IF;

  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END debug_output_conc;

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
PROCEDURE create_trxs
(p_gta_trxs IN trx_tbl_type)
IS
l_procedure_name VARCHAR2(30) := 'create_TRXs';
l_gta_trx_tbl    ar_gta_trx_util.trx_tbl_type;
l_index          NUMBER;

BEGIN
  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
  THEN
    fnd_log.STRING(fnd_log.level_procedure
                  ,g_module_prefix || l_procedure_name
                  ,'Begin Procedure. ');
  END IF;
  -- begin log
  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    log( 'begin create_trxs '||p_gta_trxs.COUNT);
  END IF;
  -- end log
  l_gta_trx_tbl := p_gta_trxs;

  -- loop by l_gta_trx_tbl, insert trx
  l_index := l_gta_trx_tbl.FIRST;

  WHILE l_index IS NOT NULL
  LOOP
    create_trx(l_gta_trx_tbl(l_index));
    l_index := l_gta_trx_tbl.NEXT(l_index);

  END LOOP;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
  THEN
    fnd_log.STRING(fnd_log.level_procedure
                  ,g_module_prefix || l_procedure_name
                  ,'End Procedure. ');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.STRING(fnd_log.level_unexpected
                    ,g_module_prefix || l_procedure_name ||
                     '. OTHER_EXCEPTION '
                    ,SQLCODE || SQLERRM);
    END IF;
    RAISE;

END create_trxs;

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
--           03-JAN-2008: Subba    added parameter for insert_row method calling
--           16-Jun-2009: Yao Zhang   Modified for bug#8605196
--                                  added parameter for insert_row method to support discount line
--           20-Jul-2009:Yao Zhang Modified for bug#8605196 ER3 consolidate invoice
--===========================================================================
PROCEDURE create_trx
(p_gta_trx IN trx_rec_type)
IS

header_row_id    VARCHAR2(30);
line_row_id      VARCHAR2(30);
l_procedure_name VARCHAR2(30) := 'create_Trx';
l_count          NUMBER;

BEGIN

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
  THEN
    fnd_log.STRING(fnd_log.level_procedure
                  ,g_module_prefix || l_procedure_name
                  ,'Begin Procedure. ');
  END IF;

  -- begin log
  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    log('begin create_trx '||p_gta_trx.trx_header.ra_trx_id);
  END IF;
  -- end log

  -- insert header
  ar_gta_trx_headers_all_pkg.insert_row
  (p_row_id                     => header_row_id
  ,p_ra_gl_date                 => p_gta_trx.trx_header.ra_gl_date
  ,p_ra_gl_period               => p_gta_trx.trx_header.ra_gl_period
  ,p_set_of_books_id            => p_gta_trx.trx_header.set_of_books_id
  ,p_bill_to_customer_id        => p_gta_trx.trx_header.bill_to_customer_id
  ,p_bill_to_customer_number    => p_gta_trx.trx_header.bill_to_customer_number
  ,p_bill_to_customer_name      => p_gta_trx.trx_header.bill_to_customer_name
  ,p_source                     => p_gta_trx.trx_header.SOURCE
  ,p_org_id                     => p_gta_trx.trx_header.org_id
  ,p_rule_header_id             => p_gta_trx.trx_header.rule_header_id
  ,p_gta_trx_header_id          => p_gta_trx.trx_header.gta_trx_header_id
  ,p_gta_trx_number             => p_gta_trx.trx_header.gta_trx_number
  ,p_group_number               => p_gta_trx.trx_header.group_number
  ,p_version                    => p_gta_trx.trx_header.version
  ,p_latest_version_flag        => p_gta_trx.trx_header.latest_version_flag
  ,p_transaction_date           => p_gta_trx.trx_header.transaction_date
  ,p_ra_trx_id                  => p_gta_trx.trx_header.ra_trx_id
  ,p_ra_trx_number              => p_gta_trx.trx_header.ra_trx_number
  ,p_description                => p_gta_trx.trx_header.description
  ,p_customer_address           => p_gta_trx.trx_header.customer_address
  ,p_customer_phone             => p_gta_trx.trx_header.customer_phone
  ,p_customer_address_phone     => p_gta_trx.trx_header.customer_address_phone
  ,p_bank_account_name          => p_gta_trx.trx_header.bank_account_name
  ,p_bank_account_number        => p_gta_trx.trx_header.bank_account_number
  ,p_bank_account_name_number   => p_gta_trx.trx_header.bank_account_name_number
  ,p_fp_tax_registration_number => p_gta_trx.trx_header.fp_tax_registration_number  -- fp registration number
  ,p_tp_tax_registration_number => p_gta_trx.trx_header.tp_tax_registration_number  -- tp registration number
  ,p_legal_entity_id            => p_gta_trx.trx_header.legal_entity_id -- legal entity id
  ,p_ra_currency_code           => p_gta_trx.trx_header.ra_currency_code
  ,p_conversion_type            => p_gta_trx.trx_header.conversion_type
  ,p_conversion_date            => p_gta_trx.trx_header.conversion_date
  ,p_conversion_rate            => p_gta_trx.trx_header.conversion_rate
  ,p_gta_batch_number           => p_gta_trx.trx_header.gta_batch_number
  ,p_gt_invoice_number          => p_gta_trx.trx_header.gt_invoice_number
  ,p_gt_invoice_date            => p_gta_trx.trx_header.gt_invoice_date
  ,p_gt_invoice_net_amount      => p_gta_trx.trx_header.gt_invoice_net_amount
  ,p_gt_invoice_tax_amount      => p_gta_trx.trx_header.gt_invoice_tax_amount
  ,p_status                     => p_gta_trx.trx_header.status
  ,p_sales_list_flag            => p_gta_trx.trx_header.sales_list_flag
  ,p_cancel_flag                => p_gta_trx.trx_header.cancel_flag
  ,p_gt_invoice_type            => p_gta_trx.trx_header.gt_invoice_type
  ,p_gt_invoice_class           => p_gta_trx.trx_header.gt_invoice_class
  ,p_gt_tax_month               => p_gta_trx.trx_header.gt_tax_month
  ,p_issuer_name                => p_gta_trx.trx_header.issuer_name
  ,p_reviewer_name              => p_gta_trx.trx_header.reviewer_name
  ,p_payee_name                 => p_gta_trx.trx_header.payee_name
  ,p_tax_code                   => p_gta_trx.trx_header.tax_code
  ,p_tax_rate                   => p_gta_trx.trx_header.tax_rate
  ,p_generator_id               => p_gta_trx.trx_header.generator_id
  ,p_export_request_id          => p_gta_trx.trx_header.export_request_id
  ,p_request_id                 => p_gta_trx.trx_header.request_id
  ,p_program_application_id     => p_gta_trx.trx_header.program_application_id
  ,p_program_id                 => p_gta_trx.trx_header.program_id
  ,p_program_update_date        => p_gta_trx.trx_header.program_update_date
  ,p_attribute_category         => p_gta_trx.trx_header.attribute_category
  ,p_attribute1                 => p_gta_trx.trx_header.attribute1
  ,p_attribute2                 => p_gta_trx.trx_header.attribute2
  ,p_attribute3                 => p_gta_trx.trx_header.attribute3
  ,p_attribute4                 => p_gta_trx.trx_header.attribute4
  ,p_attribute5                 => p_gta_trx.trx_header.attribute5
  ,p_attribute6                 => p_gta_trx.trx_header.attribute6
  ,p_attribute7                 => p_gta_trx.trx_header.attribute7
  ,p_attribute8                 => p_gta_trx.trx_header.attribute8
  ,p_attribute9                 => p_gta_trx.trx_header.attribute9
  ,p_attribute10                => p_gta_trx.trx_header.attribute10
  ,p_attribute11                => p_gta_trx.trx_header.attribute11
  ,p_attribute12                => p_gta_trx.trx_header.attribute12
  ,p_attribute13                => p_gta_trx.trx_header.attribute13
  ,p_attribute14                => p_gta_trx.trx_header.attribute14
  ,p_attribute15                => p_gta_trx.trx_header.attribute15
  ,p_creation_date              => p_gta_trx.trx_header.creation_date
  ,p_created_by                 => p_gta_trx.trx_header.created_by
  ,p_last_update_date           => p_gta_trx.trx_header.last_update_date
  ,p_last_updated_by            => p_gta_trx.trx_header.last_updated_by
  ,p_last_update_login          => p_gta_trx.trx_header.last_update_login
  ,p_invoice_type               => p_gta_trx.trx_header.invoice_type
  --Yao Zhang add begin for bug#8605196 ER3 consolidate invoice
  ,p_consolidation_flag         => p_gta_trx.trx_header.consolidation_flag
  ,p_consolidation_id           => p_gta_trx.trx_header.consolidation_id
  ,p_consolidation_trx_num      => p_gta_trx.trx_header.consolidation_trx_num
  --Yao Zhang add end for bug#8605196 ER3 consolidate invoice
  );

  -- insert rows
  l_count := p_gta_trx.trx_lines.FIRST;
  WHILE l_count IS NOT NULL
  LOOP
    -- begin log
    IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      log( 'begin create_trx_line '||p_gta_trx.trx_lines(l_count).ar_trx_line_id);
    END IF;
    -- end log

    ar_gta_trx_lines_all_pkg.insert_row
    (p_rowid                    => line_row_id
    ,p_org_id                   => p_gta_trx.trx_lines(l_count).org_id
    ,p_gta_trx_header_id        => p_gta_trx.trx_lines(l_count).gta_trx_header_id
    ,p_gta_trx_line_id          => p_gta_trx.trx_lines(l_count).gta_trx_line_id
    ,p_matched_flag             => p_gta_trx.trx_lines(l_count).matched_flag
    ,p_line_number              => p_gta_trx.trx_lines(l_count).line_number
    ,p_ar_trx_line_id           => p_gta_trx.trx_lines(l_count).ar_trx_line_id
    ,p_inventory_item_id        => p_gta_trx.trx_lines(l_count).inventory_item_id
    ,p_item_number              => p_gta_trx.trx_lines(l_count).item_number
    ,p_item_description         => p_gta_trx.trx_lines(l_count).item_description
    ,p_item_model               => p_gta_trx.trx_lines(l_count).item_model
    ,p_item_tax_denomination    => p_gta_trx.trx_lines(l_count).item_tax_denomination
    ,p_tax_rate                 => p_gta_trx.trx_lines(l_count).tax_rate
    ,p_uom                      => p_gta_trx.trx_lines(l_count).uom
    ,p_uom_name                 => p_gta_trx.trx_lines(l_count).uom_name
    ,p_quantity                 => p_gta_trx.trx_lines(l_count).quantity
    ,p_price_flag               => p_gta_trx.trx_lines(l_count).price_flag
    ,p_unit_price               => p_gta_trx.trx_lines(l_count).unit_price
    ,p_unit_tax_price           => p_gta_trx.trx_lines(l_count).unit_tax_price
    ,p_amount                   => p_gta_trx.trx_lines(l_count).amount
    ,p_original_currency_amount => p_gta_trx.trx_lines(l_count).original_currency_amount
    ,p_tax_amount               => p_gta_trx.trx_lines(l_count).tax_amount
    ,p_discount_flag            => p_gta_trx.trx_lines(l_count).discount_flag
    ,p_enabled_flag             => p_gta_trx.trx_lines(l_count).enabled_flag
    ,p_request_id               => p_gta_trx.trx_lines(l_count).request_id
    ,p_program_application_id   => p_gta_trx.trx_lines(l_count).program_applicaton_id
    ,p_program_id               => p_gta_trx.trx_lines(l_count).program_id
    ,p_program_update_date      => p_gta_trx.trx_lines(l_count).program_update_date
    ,p_attribute_category       => p_gta_trx.trx_lines(l_count).attribute_category
    ,p_attribute1               => p_gta_trx.trx_lines(l_count).attribute1
    ,p_attribute2               => p_gta_trx.trx_lines(l_count).attribute2
    ,p_attribute3               => p_gta_trx.trx_lines(l_count).attribute3
    ,p_attribute4               => p_gta_trx.trx_lines(l_count).attribute4
    ,p_attribute5               => p_gta_trx.trx_lines(l_count).attribute5
    ,p_attribute6               => p_gta_trx.trx_lines(l_count).attribute6
    ,p_attribute7               => p_gta_trx.trx_lines(l_count).attribute7
    ,p_attribute8               => p_gta_trx.trx_lines(l_count).attribute8
    ,p_attribute9               => p_gta_trx.trx_lines(l_count).attribute9
    ,p_attribute10              => p_gta_trx.trx_lines(l_count).attribute10
    ,p_attribute11              => p_gta_trx.trx_lines(l_count).attribute11
    ,p_attribute12              => p_gta_trx.trx_lines(l_count).attribute12
    ,p_attribute13              => p_gta_trx.trx_lines(l_count).attribute13
    ,p_attribute14              => p_gta_trx.trx_lines(l_count).attribute14
    ,p_attribute15              => p_gta_trx.trx_lines(l_count).attribute15
    ,p_creation_date            => p_gta_trx.trx_lines(l_count).creation_date
    ,p_created_by               => p_gta_trx.trx_lines(l_count).created_by
    ,p_last_update_date         => p_gta_trx.trx_lines(l_count).last_update_date
    ,p_last_updated_by          => p_gta_trx.trx_lines(l_count).last_updated_by
    ,p_last_update_login        => p_gta_trx.trx_lines(l_count).last_update_login
    --Yao Zhang add for bug#8605196 to support discount line
    ,p_discount_amount          => p_gta_trx.trx_lines(l_count).discount_amount
    ,p_discount_tax_amount      => p_gta_trx.trx_lines(l_count).discount_tax_amount
    ,p_discount_rate            => p_gta_trx.trx_lines(l_count).discount_rate
    );

    l_count := p_gta_trx.trx_lines.NEXT(l_count);
  END LOOP;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
  THEN
    fnd_log.STRING(fnd_log.level_procedure
                  ,g_module_prefix || l_procedure_name
                  ,'End Procedure. ');
  END IF;

EXCEPTION
  WHEN dup_val_on_index THEN
    IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)
    THEN
      fnd_log.STRING(fnd_log.level_unexpected
                    ,g_module_prefix || l_procedure_name ||
                     '. dup_val_on_index '
                    ,SQLCODE || SQLERRM);
    END IF;

  WHEN OTHERS THEN
    IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)
    THEN
      fnd_log.STRING(fnd_log.level_unexpected
                    ,g_module_prefix || l_procedure_name ||
                     '. OTHER_EXCEPTION '
                    ,'Exception occur when insert data into database' ||
                     SQLCODE || SQLERRM);

      -- begin log
      IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        log( 'Exception occur when insert data into database' ||SQLCODE || SQLERRM);
      END IF;
      -- end log

    END IF;
    RAISE;

END create_trx;
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
)
IS
l_procedure_name    VARCHAR2(100)   :='Get_Trx';
l_trx_rec           trx_rec_type;
l_line_count        NUMBER;
l_gta_trx_line_id   ar_gta_trx_lines_all.gta_trx_line_id%TYPE;
CURSOR c_trx_lines(l_header_id IN NUMBER) IS
  SELECT gta_trx_line_id
  FROM ar_gta_trx_lines_all
  WHERE gta_trx_header_id = l_header_id;

BEGIN
  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
  THEN
    fnd_log.STRING(fnd_log.level_procedure
                  ,g_module_prefix || l_procedure_name
                  ,'Begin Procedure. ');
  END IF;
  --get trx header
  l_trx_rec:=NULL;

  AR_GTA_TRX_HEADERS_ALL_PKG.Query_Row
  (p_header_id      => p_trx_header_id
  ,x_trx_header_rec => l_trx_rec.trx_header);
  --init
  l_trx_rec.trx_lines:=trx_line_tbl_type();
  --get trx lines
  OPEN c_trx_lines(p_trx_header_id);
  LOOP
  FETCH c_trx_lines INTO l_gta_trx_line_id;
  EXIT WHEN c_trx_lines%NOTFOUND;

    IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
     log('get trx_line_id: '||l_gta_trx_line_id);
    END IF;
    l_trx_rec.trx_lines.EXTEND;
    AR_GTA_TRX_LINES_ALL_PKG.Query_Row
    (p_trx_line_id  =>l_gta_trx_line_id
    ,x_trx_line_rec =>l_trx_rec.trx_lines(l_trx_rec.trx_lines.count));

  END LOOP;
  CLOSE c_trx_lines;
    -- end log
  x_trx_rec:=l_trx_rec;
  --log for debug
  IF(fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
  THEN

    FND_LOG.String(fnd_log.level_procedure
                  ,G_MODULE_PREFIX||'.'||l_procedure_name||'.end'
                  ,'Exit procedure'
                  );

  END IF;  --( l_proc_level >= l_dbg_level)

END Get_Trx;

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
--           30-APR-2005  Jim Zheng      Created.
--           04-AUG-2005  Donghai Wang   modified query clause to remove
--                                       reference to price_flag
--           06-Aug-2009  Yao Zhang     modified for bug#8605196 to support discount line
--
--===========================================================================
FUNCTION Get_Gtainvoice_Amount
(p_header_id IN NUMBER
)
RETURN NUMBER
IS
l_ret NUMBER;
BEGIN
  SELECT
    --SUM(nvl(amount,0))
    SUM(nvl(amount,0)+nvl(discount_amount,0))--Yao Modified for R12.1.2 to support discount line
  INTO
    l_ret
  FROM
    ar_gta_trx_lines_all
  WHERE gta_trx_header_id = p_header_id
    AND enabled_flag = 'Y';

  RETURN l_ret;
END Get_Gtainvoice_Amount;

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
FUNCTION get_gtainvoice_original_amount
(p_header_id IN NUMBER)
RETURN NUMBER
IS
l_ret NUMBER;
CURSOR c_original_amount IS
  SELECT
    SUM(nvl(original_currency_amount,0))
  FROM
    ar_gta_trx_lines_all
  WHERE gta_trx_header_id = p_header_id
    AND enabled_flag = 'Y';
BEGIN
  OPEN c_original_amount;
  FETCH c_original_amount
    INTO l_ret;
  CLOSE c_original_amount;

  RETURN(nvl(l_ret
            ,0));
END get_gtainvoice_original_amount;

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
PROCEDURE delete_header_line_cascade
(p_gta_trx_header_id IN NUMBER)
IS
BEGIN
  --Delete lines
  DELETE ar_gta_trx_lines_all
  WHERE  gta_trx_header_id = p_gta_trx_header_id;

  --Delete Headers
  DELETE ar_gta_trx_headers_all
  WHERE  gta_trx_header_id = p_gta_trx_header_id;
END delete_header_line_cascade;

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
--           08-Aug-2009 Yao Zhang Modified for R12.1.2 to support discount line
--===========================================================================
FUNCTION get_gtainvoice_tax_amount
(p_header_id IN NUMBER)
RETURN NUMBER
IS
l_ret NUMBER;
BEGIN
  SELECT --SUM(nvl(tax_amount,0))
         SUM(nvl(tax_amount,0)+nvl(discount_tax_amount,0))--Yao Modified for R12.1.2
  INTO   l_ret
  FROM   ar_gta_trx_lines
  WHERE  gta_trx_header_id = p_header_id
         AND enabled_flag = 'Y';
  RETURN l_ret;
END get_gtainvoice_tax_amount;

--==========================================================================
--  FUNCTION NAME:
--
--    Check_Taxcount_Of_Arline                Public
--
--  DESCRIPTION:
--
--      This function is used to check if one AR line has multiple tax line per
--      Tax type and GT currency defined on GTA system option form.
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
RETURN BOOLEAN
IS
l_tax_type_code        zx_lines.tax_type_code%TYPE;
l_taxline_count        NUMBER;
l_gt_currency_code     fnd_currencies.currency_code%TYPE;
l_trx_id               ra_customer_trx_all.customer_trx_id%TYPE;--jogen bug5212702 May-17,2006

CURSOR c_tax_type_code
IS
SELECT
  vat_tax_type_code
 ,gt_currency_code
FROM
  ar_gta_system_parameters_all
WHERE org_id=p_org_id;

CURSOR c_taxline_count(pc_trx_id NUMBER)
IS
SELECT
  COUNT(*)
FROM
  zx_lines
WHERE trx_line_id=p_customer_trx_line_id
  AND entity_code='TRANSACTIONS'
  AND application_id = 222
  AND trx_level_type='LINE'
  AND tax_type_code=l_tax_type_code
  AND tax_currency_code=l_gt_currency_code
  AND event_class_code IN ('INVOICE','CREDIT_MEMO','DEBIT_MEMO')--jogen bug5212702 May-17,2006
  AND trx_id=pc_trx_id;                                     --jogen bug5212702 May-17,2006

l_dbg_level            NUMBER       := fnd_log.g_current_runtime_level;
l_proc_level           NUMBER       := fnd_log.level_procedure;
l_procedure_name       VARCHAR2(30) := 'Check_Taxcount_Of_Arline';

BEGIN
  --logging for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || l_procedure_name || '.begin'
                  ,'Enter function');
  END IF; --l_proc_level>=l_dbg_level)


  --Get Vat tax type and GT currency coe defined in GTA system options form
  --for current operating unit
  OPEN c_tax_type_code;
  FETCH c_tax_type_code INTO l_tax_type_code,l_gt_currency_code;
  CLOSE c_tax_type_code;

  --Get count of tax line for a AR line

  ----jogen bug5212702 May-17,2006
  --  OPEN c_taxline_count;
  SELECT customer_trx_id
    INTO l_trx_id
   FROM ra_customer_trx_lines_all
   WHERE customer_trx_line_id=p_customer_trx_line_id;

  OPEN c_taxline_count(l_trx_id);
  --jogen bug5212702 May-17,2006

  FETCH c_taxline_count INTO l_taxline_count;
  CLOSE c_taxline_count;

  --logging for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || l_procedure_name || '.End'
                  ,'Exit function');
  END IF; --l_proc_level>=l_dbg_level)

  IF l_taxline_count=1
  THEN
    RETURN(TRUE);
  ELSE
    RETURN(FALSE);
  END IF;  --l_taxline_count=1

END Check_Taxcount_Of_Arline;


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
RETURN BOOLEAN
IS
l_tax_type_code        zx_lines.tax_type_code%TYPE;
l_taxline_count        NUMBER;
l_gt_currency_code     fnd_currencies.currency_code%TYPE;



CURSOR c_tax_type_code
IS
SELECT
  vat_tax_type_code
 ,gt_currency_code
FROM
  ar_gta_system_parameters_all
WHERE org_id=p_org_id;

CURSOR c_tax_line_count
IS
SELECT COUNT(*)
FROM
  (SELECT
     trx_line_id
    ,COUNT(*)
   FROM
     zx_lines
   WHERE application_id = 222
     AND trx_id=p_customer_trx_id
     AND trx_level_type='LINE'
     AND entity_code='TRANSACTIONS'
     AND tax_type_code=l_tax_type_code
     AND tax_currency_code=l_gt_currency_code
     AND event_class_code IN ('INVOICE','CREDIT_MEMO','DEBIT_MEMO')--jogen bug5212702 May-17,2006
  GROUP BY trx_line_id
  HAVING COUNT(*)>1);



l_dbg_level            NUMBER       := fnd_log.g_current_runtime_level;
l_proc_level           NUMBER       := fnd_log.level_procedure;
l_procedure_name       VARCHAR2(30) := 'Check_Taxcount_Of_Artrx';

BEGIN
  --logging for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || l_procedure_name || '.begin'
                  ,'Enter function');
  END IF; --l_proc_level>=l_dbg_level)


  --Get Vat tax type and GT currency code defined in GTA system options form
  --for current operating unit
  OPEN c_tax_type_code;
  FETCH c_tax_type_code INTO l_tax_type_code,l_gt_currency_code;
  CLOSE c_tax_type_code;

  --Get count of lines which have multiple tax lines for an AR transactions
  OPEN c_tax_line_count;
  FETCH c_tax_line_count INTO l_taxline_count;
  CLOSE c_tax_line_count;

  --logging for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || l_procedure_name || '.End'
                  ,'Exit function');
  END IF; --l_proc_level>=l_dbg_level)

  IF l_taxline_count=0
  THEN
    RETURN(TRUE);
  ELSE
    RETURN(FALSE);
  END IF;  --l_taxline_count=0

END Check_Taxcount_Of_Artrx;

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
RETURN NUMBER
IS
l_procedure_name VARCHAR2(30) := 'Get_Arinvoice_Amount';
l_dbg_level      NUMBER := fnd_log.g_current_runtime_level;
l_proc_level     NUMBER := fnd_log.level_procedure;

l_tax_type_code        zx_lines.tax_type_code%TYPE;
l_gt_currency_code     fnd_currencies.currency_code%TYPE;
l_ar_taxable_amount    NUMBER;



CURSOR c_tax_type_code
IS
SELECT
  vat_tax_type_code
 ,gt_currency_code
FROM
  ar_gta_system_parameters_all
WHERE org_id=p_org_id;

CURSOR c_ar_taxable_amount
IS
SELECT
  NVL(SUM(taxable_amt_tax_curr),0)
FROM
  zx_lines
WHERE application_id = 222
  AND trx_id=p_customer_trx_id
  AND trx_level_type='LINE'
  AND entity_code='TRANSACTIONS'
  AND tax_type_code=l_tax_type_code
  AND tax_currency_code=l_gt_currency_code
  AND event_class_code IN ('INVOICE','CREDIT_MEMO','DEBIT_MEMO'); --Donghai Wang bug5212702 May-17,2006

BEGIN
  --logging for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || l_procedure_name || '.begin'
                  ,'enter function');
  END IF;--(l_proc_level >= l_dbg_level)

  --Get Vat tax type and GT currency code defined in GTA system options form
  --for current operating unit
  OPEN c_tax_type_code;
  FETCH c_tax_type_code INTO l_tax_type_code,l_gt_currency_code;
  CLOSE c_tax_type_code;

  --Get total taxable amount of lines for an AR transactions
  OPEN c_ar_taxable_amount;
  FETCH c_ar_taxable_amount INTO l_ar_taxable_amount;
  CLOSE c_ar_taxable_amount;


  --logging for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || l_procedure_name || '.end'
                  ,'end function');
  END IF;  --(l_proc_level >= l_dbg_level)

  RETURN l_ar_taxable_amount;
END Get_Arinvoice_Amount;

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
RETURN NUMBER
IS
l_procedure_name VARCHAR2(30) := 'Get_Arinvoice_Tax_Amount';
l_dbg_level      NUMBER := fnd_log.g_current_runtime_level;
l_proc_level     NUMBER := fnd_log.level_procedure;

l_tax_type_code        zx_lines.tax_type_code%TYPE;
l_gt_currency_code     fnd_currencies.currency_code%TYPE;
l_ar_tax_amount    NUMBER;



CURSOR c_tax_type_code
IS
SELECT
  vat_tax_type_code
 ,gt_currency_code
FROM
  ar_gta_system_parameters_all
WHERE org_id=p_org_id;

CURSOR c_ar_tax_amount
IS
SELECT
  NVL(SUM(tax_amt_tax_curr),0)
FROM
  zx_lines
WHERE application_id = 222
  AND trx_id=p_customer_trx_id
  AND trx_level_type='LINE'
  AND entity_code='TRANSACTIONS'
  AND tax_type_code=l_tax_type_code
  AND tax_currency_code=l_gt_currency_code
  AND event_class_code IN ('INVOICE','CREDIT_MEMO','DEBIT_MEMO'); --Donghai Wang bug5212702 May-17,2006;

BEGIN
  --logging for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || l_procedure_name || '.begin'
                  ,'enter function');
  END IF;--(l_proc_level >= l_dbg_level)

  --Get Vat tax type and GT currency code defined in GTA system options form
  --for current operating unit
  OPEN c_tax_type_code;
  FETCH c_tax_type_code INTO l_tax_type_code,l_gt_currency_code;
  CLOSE c_tax_type_code;

  --Get total VAT tax amount of AR transaction
  OPEN c_ar_tax_amount;
  FETCH c_ar_tax_amount INTO l_ar_tax_amount ;
  CLOSE c_ar_tax_amount;


  --logging for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || l_procedure_name || '.end'
                  ,'end function');
  END IF;  --(l_proc_level >= l_dbg_level)

  RETURN l_ar_tax_amount;
END Get_Arinvoice_Tax_Amount;


--==========================================================================
--  PROCEDURE NAME:
--
--    Get_New_TRX_Num               Private
--
--  DESCRIPTION:
--
--      This procedure is to get a new trx number
--
--  PARAMETERS:
--      In:   p_trx_id            Identifier of AR transaction
--            p_group_number      Group number
--            p_version_number    Version
--            p_org_id            Identifier of operating unit
--
--     Out:   x_gta_trx_number    Number of GTA invoice
--
--  DESIGN REFERENCES:
--      GTA-TRANSFER-PROGRAM-TD.doc
--
--  CHANGE HISTORY:
--
--           23-MAy-2005: Jim.zheng  Creation
--
--===========================================================================
PROCEDURE get_new_trx_num
(p_trx_id         IN VARCHAR2
,p_group_number   IN VARCHAR2
,p_version_number IN VARCHAR2
,x_gta_trx_number OUT NOCOPY VARCHAR2
)
IS
boundary VARCHAR2(1) := '-';

BEGIN
  x_gta_trx_number := p_trx_id || boundary || p_group_number || boundary ||
                      p_version_number;
END get_new_trx_num;

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
FUNCTION format_date(p_date IN DATE) RETURN VARCHAR2 IS
l_procedure_name VARCHAR2(30) := 'Format_Date';
l_dbg_level      NUMBER := fnd_log.g_current_runtime_level;
l_proc_level     NUMBER := fnd_log.level_procedure;
l_ret            VARCHAR(40);

l_date_format fnd_profile_option_values.profile_option_value%TYPE := NULL;

BEGIN
  --logging for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || l_procedure_name || '.begin'
                  ,'enter function');
  END IF;

  fnd_profile.get('ICX_DATE_FORMAT_MASK'
                 ,l_date_format);
  l_ret := to_char(p_date
                  ,nvl(l_date_format
                      ,'Rrrr-Mm-Dd'));

  --logging for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || l_procedure_name || '.end'
                  ,'end function');
  END IF;

  RETURN l_ret;
END format_date;

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
--           23-May-2005: Donghai Wang  Created
--           26-Jun-2006: Donghai Wang  In the cursor c_phone_number, add sub
--                                      query to fetch party_id by
--                                      "bill to customer id" passed in,instead
--                                      of using "bill to customer id"
--                                      directly.
--          21-May-2006  Donghai Wang   Fix the bug 5263009
--
--===========================================================================
FUNCTION get_primary_phone_number
(p_customer_id IN NUMBER
)
RETURN VARCHAR2
IS
l_customer_id  hz_parties.party_id%TYPE := p_customer_id;
l_phone_number hz_contact_points.phone_number%TYPE;

--Fix bug 5263009, Donghai Wang
--Add the sub query to get party id by customer id
CURSOR c_phone_number
IS
SELECT
  hcp.phone_number
FROM
  hz_contact_points hcp
WHERE  hcp.contact_point_type = 'PHONE'
  AND hcp.owner_table_name = 'HZ_PARTIES'
  AND hcp.owner_table_id = (SELECT
                              party_id
                            FROM
                              hz_cust_accounts_all
                            WHERE cust_account_id=l_customer_id
                           )
  AND hcp.primary_flag = 'Y';

l_procedure_name VARCHAR2(30) := 'Get_Primary_Phone_Number';
l_dbg_level      NUMBER := fnd_log.g_current_runtime_level;
l_proc_level     NUMBER := fnd_log.level_procedure;
BEGIN

  --logging for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || l_procedure_name || '.begin'
                  ,'Enter function');
  END IF; --l_proc_level>=l_dbg_level)
  OPEN c_phone_number;
  FETCH c_phone_number
    INTO l_phone_number;
  CLOSE c_phone_number;

  --logging for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || l_procedure_name || '.End'
                  ,'Exit function');
  END IF; --l_proc_level>=l_dbg_level)

  RETURN(l_phone_number);
END get_primary_phone_number;

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
--           26-Dec-2005: Qiang Li  fix a performance issue
--=========================================================================
FUNCTION get_operatingunit(p_org_id IN NUMBER) RETURN VARCHAR2 IS
  l_procedure_name VARCHAR2(30) := 'Get_OperatingUnit';
  l_dbg_level      NUMBER := fnd_log.g_current_runtime_level;
  l_proc_level     NUMBER := fnd_log.level_procedure;

  l_operating_unit hr_operating_units.NAME%TYPE;
  CURSOR c_operating_unit IS
    SELECT OTL.NAME
      FROM HR_ALL_ORGANIZATION_UNITS O
         , HR_ALL_ORGANIZATION_UNITS_TL OTL
     WHERE O.ORGANIZATION_ID = OTL.ORGANIZATION_ID
       AND OTL.LANGUAGE = userenv('LANG')
       AND O.ORGANIZATION_ID = p_org_id;

BEGIN
  --logging for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || l_procedure_name || '.begin'
                  ,'enter function');
  END IF;

  OPEN c_operating_unit;
  FETCH
    c_operating_unit
  INTO
    l_operating_unit;

  CLOSE c_operating_unit;

  --logging for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || l_procedure_name || '.end'
                  ,'end function');
  END IF;

  RETURN(l_operating_unit);
END get_operatingunit;

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
FUNCTION get_customer_name
(p_customer_id IN NUMBER)
RETURN VARCHAR2
IS
l_procedure_name VARCHAR2(30) := 'Get_Customer_Name';
l_dbg_level      NUMBER := fnd_log.g_current_runtime_level;
l_proc_level     NUMBER := fnd_log.level_procedure;

l_customer_name hz_parties.party_name%TYPE;
CURSOR c_customer_name IS
  SELECT
    p.party_name
  FROM
    hz_parties       p
    ,hz_cust_accounts a
  WHERE a.cust_account_id = p_customer_id
    AND p.party_id = a.party_id;

BEGIN
  --logging for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || l_procedure_name || '.begin'
                  ,'enter function');
  END IF;

  OPEN c_customer_name;

  FETCH
    c_customer_name
  INTO
    l_customer_name;

  CLOSE c_customer_name;

  --logging for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || l_procedure_name || '.end'
                  ,'end function');
  END IF;

  RETURN(l_customer_name);
END get_customer_name;

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
--
--  Return:   NUMBER
--
--  DESIGN REFERENCES:
--      GTA_Reports_TD.doc
--
--  CHANGE HISTORY:
--
--           13-Jun-2005: Donghai Wang  Creation
--           24-Nov-2005: Modify program logic to get line amount per Golden
--                        Tax currency from the table zx_lines
--
--=========================================================================
FUNCTION Get_Arline_Amount
(p_org_id                IN NUMBER
,p_customer_trx_line_id  IN NUMBER
)
RETURN NUMBER
IS
l_tax_type_code        zx_lines.tax_type_code%TYPE;
l_arline_amount        NUMBER;
l_gt_currency_code     fnd_currencies.currency_code%TYPE;
l_trx_id               ra_customer_trx_all.customer_trx_id%TYPE;

CURSOR c_tax_type_code
IS
SELECT
  vat_tax_type_code
 ,gt_currency_code
FROM
  ar_gta_system_parameters_all
WHERE org_id=p_org_id;

--CURSOR c_ar_line_taxable_amount                --Donghai Wang bug5212702 May-17,2006
CURSOR c_ar_line_taxable_amount(pc_trx_id NUMBER)--Donghai Wang bug5212702 May-17,2006
IS
SELECT
  taxable_amt_tax_curr
FROM
  zx_lines
WHERE trx_line_id=p_customer_trx_line_id
  AND entity_code='TRANSACTIONS'
  AND application_id = 222
  AND trx_level_type='LINE'
  AND tax_type_code=l_tax_type_code
  AND tax_currency_code=l_gt_currency_code
  AND event_class_code IN ('INVOICE','CREDIT_MEMO','DEBIT_MEMO')--Donghai Wang bug5212702 May-17,2006
  AND trx_id=pc_trx_id
ORDER BY tax_line_id;



l_dbg_level            NUMBER       := fnd_log.g_current_runtime_level;
l_proc_level           NUMBER       := fnd_log.level_procedure;
l_procedure_name       VARCHAR2(30) := 'Get_Arline_Amount';

BEGIN
  --logging for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || l_procedure_name || '.begin'
                  ,'Enter function');
  END IF; --l_proc_level>=l_dbg_level)


  --Get Vat tax type defined in GTA system options form for current
  --operating unit
  OPEN c_tax_type_code;
  FETCH c_tax_type_code INTO l_tax_type_code,l_gt_currency_code;
  CLOSE c_tax_type_code;

  --Get taxable amount per Golden Tax Currency for one AR line
  --Donghai Wang bug5212702 May-17,2006
  --OPEN c_ar_line_taxable_amount;

  SELECT customer_trx_id
    INTO l_trx_id
   FROM ra_customer_trx_lines_all
   WHERE customer_trx_line_id=p_customer_trx_line_id;

  OPEN c_ar_line_taxable_amount(l_trx_id);
  --Donghai Wang bug5212702 May-17,2006

  FETCH c_ar_line_taxable_amount INTO l_arline_amount;
  CLOSE c_ar_line_taxable_amount;

  --logging for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || l_procedure_name || '.End'
                  ,'Exit function');
  END IF; --l_proc_level>=l_dbg_level)

  RETURN(l_arline_amount);

END Get_Arline_Amount;

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
--           24-Nov-2005: Donghai Wang  Add a new parameter 'p_org_id' and
--                                      replace dummy code to real code
--
--=========================================================================
FUNCTION Get_Arline_Vattax_Amount
(p_org_id               IN NUMBER
,p_customer_trx_line_id IN NUMBER
)
RETURN NUMBER
IS
l_tax_type_code        zx_lines.tax_type_code%TYPE;
l_arline_vatamount     NUMBER;
l_gt_currency_code     fnd_currencies.currency_code%TYPE;
l_trx_id               ra_customer_trx_all.customer_trx_id%TYPE;--Donghai Wang bug5212702 May-17,2006

CURSOR c_tax_type_code
IS
SELECT
  vat_tax_type_code
 ,gt_currency_code
FROM
  ar_gta_system_parameters_all
WHERE org_id=p_org_id;

--CURSOR c_ar_line_vatamount--Donghai Wang bug5212702 May-17,2006
CURSOR c_ar_line_vatamount(pc_trx_id NUMBER)--Donghai Wang bug5212702 May-17,2006
IS
SELECT
  tax_amt_tax_curr
FROM
  zx_lines
WHERE trx_line_id=p_customer_trx_line_id
  AND entity_code='TRANSACTIONS'
  AND application_id = 222
  AND trx_level_type='LINE'
  AND tax_type_code=l_tax_type_code
  AND tax_currency_code=l_gt_currency_code
  AND event_class_code IN ('INVOICE','CREDIT_MEMO','DEBIT_MEMO')--Donghai Wang bug5212702 May-17,2006
  AND trx_id=pc_trx_id
ORDER BY tax_line_id;



l_dbg_level            NUMBER       := fnd_log.g_current_runtime_level;
l_proc_level           NUMBER       := fnd_log.level_procedure;
l_procedure_name       VARCHAR2(30) := 'Get_Arline_Vattax_Amount';

BEGIN
  --logging for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || l_procedure_name || '.begin'
                  ,'Enter function');
  END IF; --l_proc_level>=l_dbg_level)


  --Get Vat tax type defined in GTA system options form for current
  --operating unit
  OPEN c_tax_type_code;
  FETCH c_tax_type_code INTO l_tax_type_code,l_gt_currency_code;
  CLOSE c_tax_type_code;

  --Get tax amount per Golden Tax Currency for one AR line

  --Donghai Wang bug5212702 May-17,2006

   SELECT customer_trx_id
    INTO l_trx_id
   FROM ra_customer_trx_lines_all
   WHERE customer_trx_line_id=p_customer_trx_line_id;
  --OPEN c_ar_line_vatamount;
  OPEN c_ar_line_vatamount(l_trx_id);

  --Donghai Wang bug5212702 May-17,2006

  FETCH c_ar_line_vatamount INTO l_arline_vatamount;
  CLOSE c_ar_line_vatamount;

  --logging for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || l_procedure_name || '.End'
                  ,'Exit function');
  END IF; --l_proc_level>=l_dbg_level)

  RETURN(l_arline_vatamount);
END Get_Arline_Vattax_Amount;

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
--           24-Nov-2005: Donghai Wang  Add a new parameter 'p_org_id' and
--                                      replace dummy code to real code
--
--=========================================================================
FUNCTION Get_Arline_Vattax_Rate
(p_org_id               IN NUMBER
,p_customer_trx_line_id IN NUMBER
)
RETURN NUMBER
IS
l_tax_type_code        zx_lines.tax_type_code%TYPE;
l_tax_rate             NUMBER;
l_gt_currency_code     fnd_currencies.currency_code%TYPE;
l_trx_id               ra_customer_trx_all.customer_trx_id%TYPE;--Donghai Wang bug5212702 May-17,2006

CURSOR c_tax_type_code
IS
SELECT
  vat_tax_type_code
 ,gt_currency_code
FROM
  ar_gta_system_parameters_all
WHERE org_id=p_org_id;

--CURSOR c_ar_line_tax_rate                 --Donghai Wang bug5212702 May-17,2006
CURSOR c_ar_line_tax_rate(pc_trx_id NUMBER) --Donghai Wang bug5212702 May-17,2006
IS
SELECT
  tax_rate
FROM
  zx_lines
WHERE trx_line_id=p_customer_trx_line_id
  AND entity_code='TRANSACTIONS'
  AND application_id = 222
  AND trx_level_type='LINE'
  AND tax_type_code=l_tax_type_code
  AND tax_currency_code=l_gt_currency_code
  AND event_class_code IN ('INVOICE','CREDIT_MEMO','DEBIT_MEMO')--Donghai Wang bug5212702 May-17,2006
  AND trx_id=pc_trx_id    --Donghai Wang bug5212702 May-17,2006
ORDER BY tax_line_id;



l_dbg_level            NUMBER       := fnd_log.g_current_runtime_level;
l_proc_level           NUMBER       := fnd_log.level_procedure;
l_procedure_name       VARCHAR2(30) := 'Get_Arline_Vattax_Rate';

BEGIN
  --logging for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || l_procedure_name || '.begin'
                  ,'Enter function');
  END IF; --l_proc_level>=l_dbg_level)


  --Get Vat tax type defined in GTA system options form for current
  --operating unit
  OPEN c_tax_type_code;
  FETCH c_tax_type_code INTO l_tax_type_code,l_gt_currency_code;
  CLOSE c_tax_type_code;

  --Get tax rate for one AR line
  --Donghai Wang bug5212702 May-17,2006
  SELECT customer_trx_id
    INTO l_trx_id
   FROM ra_customer_trx_lines_all
   WHERE customer_trx_line_id=p_customer_trx_line_id;

  --OPEN c_ar_line_tax_rate;
  OPEN c_ar_line_tax_rate(l_trx_id);
  --Donghai Wang bug5212702 May-17,2006

  FETCH c_ar_line_tax_rate INTO l_tax_rate;
  CLOSE c_ar_line_tax_rate;

  --logging for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || l_procedure_name || '.End'
                  ,'Exit function');
  END IF; --l_proc_level>=l_dbg_level)

  RETURN(l_tax_rate/100);
END Get_Arline_Vattax_Rate;

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
--        p_trxn_extension_id     IN              NUMBER
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
--           31-Apr2009:  Yao Zhang  Changed for bug 8234250
--           16-Jun-2009  Yao Zhang  Changed for bug 8605196
--===========================================================================
PROCEDURE Get_Bank_Info
( p_customer_trx_id       IN              NUMBER
, p_org_id                IN              NUMBER
, x_bank_name             OUT NOCOPY      VARCHAR2
, x_bank_branch_name      OUT NOCOPY      VARCHAR2
, x_bank_account_name     OUT NOCOPY      VARCHAR2
, x_bank_account_num      OUT NOCOPY      VARCHAR2
)
IS
l_procedure_name                      VARCHAR2(30) := 'Get_Bank_Info';

l_bill_to_customer_id                 ra_customer_trx_all.bill_to_customer_id%TYPE;
----Yao Zhang add begin for bug#8404856
l_bill_to_site_use_id               ra_customer_trx_all.bill_to_site_use_id%TYPE;
l_valid_customer_id                 ra_customer_trx_all.bill_to_customer_id%TYPE;
l_valid_site_use_id                 ra_customer_trx_all.bill_to_site_use_id%TYPE;
----Yao Zhang add end for bug#8404856

l_site_use_id                         hz_cust_site_uses.SITE_USE_ID%TYPE;
l_cust_acct_site_id                   hz_cust_acct_sites.CUST_ACCT_SITE_ID%TYPE;
l_currency_code                       ar_gta_system_parameters_all.gt_currency_code%TYPE;
l_error_string                        VARCHAR2(500);

l_paying_customer_id                  ra_customer_trx_all.paying_customer_id%TYPE;
l_paying_site_use_id                  ra_customer_trx_all.paying_site_use_id%TYPE;
l_paying_site_id                      hz_cust_acct_sites.CUST_ACCT_SITE_ID%TYPE;
l_paying_party_id                     HZ_CUST_ACCOUNTS.party_id%TYPE;
l_ext_payer_id                        IBY_EXTERNAL_PAYERS_ALL.ext_payer_id%TYPE;
l_bank_account_name                   IBY_EXT_BANK_ACCOUNTS.bank_account_name%TYPE;
l_bank_account_num                    IBY_EXT_BANK_ACCOUNTS.bank_account_num%TYPE;
l_bank_id                             IBY_EXT_BANK_ACCOUNTS.bank_id%TYPE;
l_bank_branch_id                      IBY_EXT_BANK_ACCOUNTS.branch_id%TYPE;
l_bank_name                           HZ_PARTIES.party_name%TYPE;
l_bank_branch_name                    HZ_PARTIES.party_name%TYPE;
l_trxn_extension_id                   ra_customer_trx_all.payment_trxn_extension_id%TYPE;

l_instrument_id                       IBY_EXT_BANK_ACCOUNTS.ext_bank_account_id%TYPE;




BEGIN
  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_procedure_name
                  ,'begin Procedure. ');
  END IF;

  BEGIN
    SELECT
      gt_currency_code
    INTO
      l_currency_code
    FROM
      ar_gta_system_parameters_all
    WHERE org_id=p_org_id;

  EXCEPTION
    WHEN no_data_found THEN
      --report AR_GTA_MISSING_ERROR
      fnd_message.set_name('AR', 'AR_GTA_MISSING_ERROR');
      l_error_string := fnd_message.get();
      -- output this error
      fnd_file.put_line(fnd_file.output, '<?xml version="1.0" encoding="UTF-8" ?>
                                     <TransferReport>
                                     <ReportFailed>Y</ReportFailed>
                                     <ReportFailedMsg>'||l_error_string||'</ReportFailedMsg>
                                     <TransferReport>');


      IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        fnd_log.STRING(fnd_log.LEVEL_UNEXPECTED
                       , G_MODULE_PREFIX || l_procedure_name
                       , l_error_string);
      END IF;
      RAISE;
  END;

  BEGIN
    SELECT
       h.paying_customer_id
      ,h.paying_site_use_id
      ,h.payment_trxn_extension_id
      --Yao Zhang add begin for bug#8404856
      ,h.bill_to_customer_id
      ,h.bill_to_site_use_id
      --Yao Zhang add end for bug#8404856
    INTO
      l_paying_customer_id
      , l_paying_site_use_id
      , l_trxn_extension_id
      --Yao Zhang add for bug#8404856
      , l_bill_to_customer_id
      , l_bill_to_site_use_id
      --Yao Zhang add end for bug#8404856
    FROM
      ra_customer_trx_all h

    WHERE  h.customer_trx_id = p_customer_trx_id ;
  EXCEPTION
    WHEN no_data_found THEN
      IF(FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        fnd_log.STRING(fnd_log.LEVEL_EXCEPTION
                       , G_MODULE_PREFIX || l_procedure_name
                       , 'no date found when select header info');
      END IF;
  END;

  -- select bank information
  IF (l_paying_customer_id is not null) and (l_trxn_extension_id IS NOT NULL)--yao zhang changed for bug 8234250
  THEN

    BEGIN
      SELECT
        u.instrument_id
        , b.bank_account_name
        --Modified by Yao begin for bug#8605196 to support Bank name in Chinese
        --, b.bank_name
        , decode(bhp.organization_name_phonetic
              ,null, bhp.party_name
              ,bhp.organization_name_phonetic)
        --, b.bank_branch_name
        , decode(brhp.organization_name_phonetic
              ,null, brhp.party_name
              ,brhp.organization_name_phonetic)
        --Modified by Yao for bug#8605196 end to support Bank name in Chinese
      INTO
        l_instrument_id
        , l_bank_account_name
        , l_bank_name
        , l_bank_branch_name
      FROM IBY_CREDITCARD            C,
           IBY_CREDITCARD_ISSUERS_VL I,
           IBY_EXT_BANK_ACCOUNTS_V   B,
           IBY_FNDCPT_PMT_CHNNLS_VL  P,
           IBY_FNDCPT_TX_EXTENSIONS  X,
           IBY_FNDCPT_TX_OPERATIONS  OP,
           IBY_PMT_INSTR_USES_ALL    U,
           HZ_PARTIES                HZP,
           FND_APPLICATION           A,
           --Add by Yao for bug#8605196 to support bank name in Chinese
           HZ_PARTIES                bhp,
           HZ_PARTIES                brhp
       WHERE (x.instr_assignment_id = u.instrument_payment_use_id(+))
         AND (DECODE(u.instrument_type, 'CREDITCARD', u.instrument_id, NULL) =
             c.instrid(+))
         AND (DECODE(u.instrument_type, 'BANKACCOUNT', u.instrument_id, NULL) =
             b.bank_account_id(+))
         AND (x.payment_channel_code = p.payment_channel_code)
         AND (c.card_issuer_code = i.card_issuer_code(+))
         AND (x.trxn_extension_id = op.trxn_extension_id(+))
         AND (c.card_owner_id = hzp.party_id(+))
         AND (x.origin_application_id = a.application_id)
         AND x.trxn_extension_id = l_trxn_extension_id
         --Add by Yao for bug#8605196 to support bank name in Chinese
         AND b.bank_party_id=bhp.party_id(+)
         AND b.branch_party_id=brhp.party_id(+);

    EXCEPTION
      WHEN no_data_found THEN
        IF(FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
          fnd_log.STRING(fnd_log.LEVEL_EXCEPTION
                         , G_MODULE_PREFIX || l_procedure_name
                         , 'no date found when select bank information');
        END IF;
    END;

    BEGIN
      SELECT
        bank_account_num
      INTO
        l_bank_account_num
      FROM
        IBY_EXT_BANK_ACCOUNTS
      WHERE
        ext_bank_account_id = l_instrument_id;
    EXCEPTION
      WHEN no_data_found THEN
        IF(FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
          fnd_log.STRING(fnd_log.LEVEL_EXCEPTION
                         , G_MODULE_PREFIX || l_procedure_name
                         , 'no date found when select bank information');
        END IF;
    END;


  END IF;/*l_trxn_extension_id IS NOT NULL*/

  -- if the bank information come from AR is null. then select bank info by customer!
  IF l_bank_account_num IS NULL
  THEN
    -- get bank info by paying customer id and paying site use id.
    --Yao Zhang add begin for bug#8404856
    IF l_paying_customer_id IS NOT NULL
    THEN
      l_valid_customer_id:=l_paying_customer_id;
      l_valid_site_use_id:=l_paying_site_use_id;
    ELSE
      l_valid_customer_id:=l_bill_to_customer_id;
      l_valid_site_use_id:=l_bill_to_site_use_id;
    END IF;
    --Yao Zhang add end for bug#8404856

    BEGIN

      -- get party id of paying customer
      SELECT
        party_id
      INTO
        l_paying_party_id
      FROM
        HZ_CUST_ACCOUNTS
      WHERE
        CUST_ACCOUNT_ID = l_valid_customer_id ;--Yao Zhang modified for bug#8404856

      -- get ext_payer_id by party id , site account id , site use id and org id.
      SELECT
        ext_payer_id
      INTO
        l_ext_payer_id
      FROM
        IBY_EXTERNAL_PAYERS_ALL
      WHERE party_id = l_paying_party_id
      AND CUST_ACCOUNT_ID = l_valid_customer_id--Yao Zhang modified for bug#8404856
      AND ACCT_SITE_USE_ID =l_valid_site_use_id--Yao Zhang modified for bug#8404856
      AND ORG_ID = p_org_id  -- org id
      AND org_type = 'OPERATING_UNIT' -- ou
      AND payment_function = 'CUSTOMER_PAYMENT';

      -- get bank account name and bank account num
      SELECT
        bank_account_name
        , bank_account_num
        , bank_id
        , branch_id
      INTO
        l_bank_account_name
        , l_bank_account_num
        , l_bank_id
        , l_bank_branch_id
      FROM (SELECT ibybanks.bank_account_name
                   , ibybanks.bank_account_num
                   , ibybanks.bank_id
                   , ibybanks.branch_id
            FROM IBY_PMT_INSTR_USES_ALL ExtPartyInstrumentsEO
            , IBY_EXT_BANK_ACCOUNTS ibybanks
            WHERE ibybanks.EXT_BANK_ACCOUNT_ID = ExtPartyInstrumentsEO.instrument_id
            AND ExtPartyInstrumentsEO.INSTRUMENT_TYPE = 'BANKACCOUNT'
            AND ExtPartyInstrumentsEO.EXT_PMT_PARTY_ID = l_ext_payer_id
            AND ExtPartyInstrumentsEO.PAYMENT_FUNCTION = 'CUSTOMER_PAYMENT'
            AND (ibybanks.currency_code = l_currency_code OR ibybanks.currency_code IS NULL)
            AND SYSDATE BETWEEN nvl(ExtPartyInstrumentsEO.START_DATE, to_date('1900-01-01','RRRR-MM-DD'))
                          AND nvl(ExtPartyInstrumentsEO.END_DATE, to_date('3000-01-01','RRRR-MM-DD'))
            ORDER BY ibybanks.currency_code,ExtPartyInstrumentsEO.ORDER_OF_PREFERENCE)
      WHERE ROWNUM =1;


      -- get bank name
      --Modified begin by Yao for bug#8605196 to support bank name in Chinese
      SELECT
        decode(organization_name_phonetic
              ,null, party_name
              ,organization_name_phonetic)
     --Modified end by Yao for bug#8605196 to support bank name in Chinese
      INTO
        l_bank_name
      FROM
        HZ_PARTIES
      WHERE
        party_id = l_bank_id;

      -- get bank branch name
      SELECT
    --Modified begin by Yao for bug#8605196 to support bank name in Chinese
       decode(organization_name_phonetic
              ,null, party_name
              ,organization_name_phonetic)
    --Modified end by Yao for bug#8605196 to support bank name in Chinese
      INTO
        l_bank_branch_name
      FROM
        HZ_PARTIES
      WHERE party_id = l_bank_branch_id;


    EXCEPTION
      WHEN no_data_found THEN
        IF(FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
          fnd_log.STRING(fnd_log.LEVEL_EXCEPTION
                         , G_MODULE_PREFIX || l_procedure_name
                         , 'no date found when select bank information');
        END IF;
    END;/*l_apba_bank_account_num IS NULL*/

  END IF;

  x_bank_name            := l_bank_name;
  x_bank_branch_name     := l_bank_branch_name;
  x_bank_account_num     := l_bank_account_num;
  x_bank_account_name    := l_bank_account_name;

  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_procedure_name
                  ,'End Procedure. ');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_procedure_name || '. OTHER_EXCEPTION '
                    , Sqlcode||Sqlerrm);
    END IF;
    RAISE;
END Get_Bank_Info;
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
---          16-Jun-2009  Yao Zhang  Changed for bug 8605196
--===========================================================================
PROCEDURE Get_CM_Bank_Info
( p_org_id                IN              NUMBER
, p_customer_trx_id       IN              NUMBER
, p_original_trx_id       IN              NUMBER
, x_bank_name             OUT NOCOPY      VARCHAR2
, x_bank_branch_name      OUT NOCOPY      VARCHAR2
, x_bank_account_name     OUT NOCOPY      VARCHAR2
, x_bank_account_num      OUT NOCOPY      VARCHAR2
)
IS
l_procedure_name                      VARCHAR2(30) := 'Get_CM_Bank_Info';

l_bill_to_customer_id                 ra_customer_trx_all.bill_to_customer_id%TYPE;
--Yao Zhang add begin for bug#8404856
l_bill_to_site_use_id               ra_customer_trx_all.bill_to_site_use_id%TYPE;
l_valid_customer_id                 ra_customer_trx_all.bill_to_customer_id%TYPE;
l_valid_site_use_id                 ra_customer_trx_all.bill_to_site_use_id%TYPE;
--Yao Zhang add end for bug#8404856
l_site_use_id                         hz_cust_site_uses.SITE_USE_ID%TYPE;
l_cust_acct_site_id                   hz_cust_acct_sites.CUST_ACCT_SITE_ID%TYPE;
l_currency_code                       ar_gta_system_parameters_all.gt_currency_code%TYPE;
l_error_string                        VARCHAR2(500);

l_paying_customer_id                  ra_customer_trx_all.paying_customer_id%TYPE;
l_paying_site_use_id                  ra_customer_trx_all.paying_site_use_id%TYPE;
l_paying_site_id                      hz_cust_acct_sites.CUST_ACCT_SITE_ID%TYPE;
l_paying_party_id                     HZ_CUST_ACCOUNTS.party_id%TYPE;
l_ext_payer_id                        IBY_EXTERNAL_PAYERS_ALL.ext_payer_id%TYPE;
l_bank_account_name                   IBY_EXT_BANK_ACCOUNTS.bank_account_name%TYPE;
l_bank_account_num                    IBY_EXT_BANK_ACCOUNTS.bank_account_num%TYPE;
l_bank_id                             IBY_EXT_BANK_ACCOUNTS.bank_id%TYPE;
l_bank_branch_id                      IBY_EXT_BANK_ACCOUNTS.branch_id%TYPE;
l_bank_name                           HZ_PARTIES.party_name%TYPE;
l_bank_branch_name                    HZ_PARTIES.party_name%TYPE;
l_trxn_extension_id                   ra_customer_trx_all.payment_trxn_extension_id%TYPE;
l_instrument_id                       IBY_EXT_BANK_ACCOUNTS.ext_bank_account_id%TYPE;

l_ori_paying_customer_id                  ra_customer_trx_all.paying_customer_id%TYPE;
l_ori_paying_site_use_id                  ra_customer_trx_all.paying_site_use_id%TYPE;
l_ori_paying_site_id                      hz_cust_acct_sites.CUST_ACCT_SITE_ID%TYPE;
l_ori_trxn_extension_id                   ra_customer_trx_all.payment_trxn_extension_id%TYPE;

BEGIN
  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_procedure_name
                  ,'begin Procedure. ');
  END IF;

  BEGIN
    SELECT
      gt_currency_code
    INTO
      l_currency_code
    FROM
      ar_gta_system_parameters_all
    WHERE org_id=p_org_id;

  EXCEPTION
    WHEN no_data_found THEN
      --report AR_GTA_MISSING_ERROR
      fnd_message.set_name('AR', 'AR_GTA_MISSING_ERROR');
      l_error_string := fnd_message.get();
      -- output this error
      fnd_file.put_line(fnd_file.output, '<?xml version="1.0" encoding="UTF-8" ?>
                                     <TransferReport>
                                     <ReportFailed>Y</ReportFailed>
                                     <ReportFailedMsg>'||l_error_string||'</ReportFailedMsg>
                                     <TransferReport>');


      IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        fnd_log.STRING(fnd_log.LEVEL_UNEXPECTED
                       , G_MODULE_PREFIX || l_procedure_name
                       , l_error_string);
      END IF;
      RAISE;
  END;

--select bank info from Credit memo payment details
  BEGIN
    SELECT
       h.paying_customer_id
      ,h.paying_site_use_id
      ,h.payment_trxn_extension_id
      --Yao Zhang add begin for bug#8404856
      ,h.bill_to_customer_id
      ,h.bill_to_site_use_id
      --Yao Zhang add end for bug#8404856
    INTO
      l_paying_customer_id
      , l_paying_site_use_id
      , l_trxn_extension_id
     --Yao Zhang add begin for bug#8404856
     ,l_bill_to_customer_id
     ,l_bill_to_site_use_id
     --Yao Zhang add end for bug#8404856
    FROM
      ra_customer_trx_all h
    WHERE  h.customer_trx_id = p_customer_trx_id ;
    EXCEPTION
    WHEN no_data_found THEN
        IF(FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
          fnd_log.STRING(fnd_log.LEVEL_EXCEPTION
                         , G_MODULE_PREFIX || l_procedure_name
                         , 'no date found when select bank information');
        END IF;
END;

  -- select bank information
  IF (l_paying_customer_id is not null) and (l_trxn_extension_id IS NOT NULL)--yao zhang changed for bug 8234250
  THEN

    BEGIN
      SELECT
        u.instrument_id
        , b.bank_account_name
        --Modified by Yao begin for bug#8605196 to support Bank name in Chinese
        --, b.bank_name
        , decode(bhp.organization_name_phonetic
              ,null, bhp.party_name
              ,bhp.organization_name_phonetic)
        --, b.bank_branch_name
        , decode(brhp.organization_name_phonetic
              ,null, brhp.party_name
              ,brhp.organization_name_phonetic)
        --Modified by Yao end for bug#8605196 to support Bank name in Chinese
      INTO
        l_instrument_id
        , l_bank_account_name
        , l_bank_name
        , l_bank_branch_name
      FROM IBY_CREDITCARD            C,
           IBY_CREDITCARD_ISSUERS_VL I,
           IBY_EXT_BANK_ACCOUNTS_V   B,
           IBY_FNDCPT_PMT_CHNNLS_VL  P,
           IBY_FNDCPT_TX_EXTENSIONS  X,
           IBY_FNDCPT_TX_OPERATIONS  OP,
           IBY_PMT_INSTR_USES_ALL    U,
           HZ_PARTIES                HZP,
           FND_APPLICATION           A,
           --Add by Yao for bug#8605196 to support bank name in Chinese
           HZ_PARTIES                bhp,
           HZ_PARTIES                brhp
       WHERE (x.instr_assignment_id = u.instrument_payment_use_id(+))
         AND (DECODE(u.instrument_type, 'CREDITCARD', u.instrument_id, NULL) =
             c.instrid(+))
         AND (DECODE(u.instrument_type, 'BANKACCOUNT', u.instrument_id, NULL) =
             b.bank_account_id(+))
         AND (x.payment_channel_code = p.payment_channel_code)
         AND (c.card_issuer_code = i.card_issuer_code(+))
         AND (x.trxn_extension_id = op.trxn_extension_id(+))
         AND (c.card_owner_id = hzp.party_id(+))
         AND (x.origin_application_id = a.application_id)
         AND x.trxn_extension_id = l_trxn_extension_id
         --Add by Yao for bug#8605196 to support bank name in Chinese
         AND b.bank_party_id=bhp.party_id(+)
         AND b.branch_party_id=brhp.party_id(+);

    EXCEPTION
      WHEN no_data_found THEN
        IF(FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
          fnd_log.STRING(fnd_log.LEVEL_EXCEPTION
                         , G_MODULE_PREFIX || l_procedure_name
                         , 'no date found when select bank information');
        END IF;
    END;

    BEGIN
      SELECT
        bank_account_num
      INTO
        l_bank_account_num
      FROM
        IBY_EXT_BANK_ACCOUNTS
      WHERE
        ext_bank_account_id = l_instrument_id;
    EXCEPTION
      WHEN no_data_found THEN
        IF(FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
          fnd_log.STRING(fnd_log.LEVEL_EXCEPTION
                         , G_MODULE_PREFIX || l_procedure_name
                         , 'no date found when select bank information');
        END IF;
    END;
END IF;/*l_trxn_extension_id IS NOT NULL*/


--If payment detail for CM is null, select bank info from AR invoice payment detail
  IF l_bank_account_num is null
  THEN
    BEGIN
  SELECT
       h.paying_customer_id
      ,h.paying_site_use_id
      ,h.payment_trxn_extension_id
    INTO
      l_ori_paying_customer_id
      , l_ori_paying_site_use_id
      , l_ori_trxn_extension_id
    FROM
      ra_customer_trx_all h

    WHERE  h.customer_trx_id = p_original_trx_id ;
  EXCEPTION
    WHEN no_data_found THEN
      IF(FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        fnd_log.STRING(fnd_log.LEVEL_EXCEPTION
                       , G_MODULE_PREFIX || l_procedure_name
                       , 'no date found when select header info');
      END IF;
  END;

  -- select bank information
  IF (l_ori_paying_customer_id is not null) and (l_ori_trxn_extension_id IS NOT NULL)--yao zhang changed for bug 8234250
  THEN
    BEGIN
      SELECT
        u.instrument_id
        , b.bank_account_name
        --Modified by Yao begin for bug#8605196 to support Bank name in Chinese
        --, b.bank_name
        , decode(bhp.organization_name_phonetic
              ,null, bhp.party_name
              ,bhp.organization_name_phonetic)
        --, b.bank_branch_name
        , decode(brhp.organization_name_phonetic
              ,null, brhp.party_name
              ,brhp.organization_name_phonetic)
        --Modified by Yao end for bug#8605196 to support Bank name in Chinese
      INTO
        l_instrument_id
        , l_bank_account_name
        , l_bank_name
        , l_bank_branch_name
      FROM IBY_CREDITCARD            C,
           IBY_CREDITCARD_ISSUERS_VL I,
           IBY_EXT_BANK_ACCOUNTS_V   B,
           IBY_FNDCPT_PMT_CHNNLS_VL  P,
           IBY_FNDCPT_TX_EXTENSIONS  X,
           IBY_FNDCPT_TX_OPERATIONS  OP,
           IBY_PMT_INSTR_USES_ALL    U,
           HZ_PARTIES                HZP,
           FND_APPLICATION           A,
           --Add by Yao for bug#8605196 to support bank name in Chinese
           HZ_PARTIES                bhp,
           HZ_PARTIES                brhp
       WHERE (x.instr_assignment_id = u.instrument_payment_use_id(+))
         AND (DECODE(u.instrument_type, 'CREDITCARD', u.instrument_id, NULL) =
             c.instrid(+))
         AND (DECODE(u.instrument_type, 'BANKACCOUNT', u.instrument_id, NULL) =
             b.bank_account_id(+))
         AND (x.payment_channel_code = p.payment_channel_code)
         AND (c.card_issuer_code = i.card_issuer_code(+))
         AND (x.trxn_extension_id = op.trxn_extension_id(+))
         AND (c.card_owner_id = hzp.party_id(+))
         AND (x.origin_application_id = a.application_id)
         AND x.trxn_extension_id = l_ori_trxn_extension_id
         --Add by Yao to for bug#8605196 support bank name in Chinese
         AND b.bank_party_id=bhp.party_id(+)
         AND b.branch_party_id=brhp.party_id(+);

    EXCEPTION
      WHEN no_data_found THEN
        IF(FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
          fnd_log.STRING(fnd_log.LEVEL_EXCEPTION
                         , G_MODULE_PREFIX || l_procedure_name
                         , 'no date found when select bank information');
        END IF;
    END;

    BEGIN
      SELECT
        bank_account_num
      INTO
        l_bank_account_num
      FROM
        IBY_EXT_BANK_ACCOUNTS
      WHERE
        ext_bank_account_id = l_instrument_id;
    EXCEPTION
      WHEN no_data_found THEN
        IF(FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
          fnd_log.STRING(fnd_log.LEVEL_EXCEPTION
                         , G_MODULE_PREFIX || l_procedure_name
                         , 'no date found when select bank information');
        END IF;
    END;

  END IF;/*l_trxn_extension_id IS NOT NULL*/

  END IF; --// IF l_bank_account_num IS NULL

  -- if the payment detail for AR invoice is null. then select CM paying customer bank info
  IF l_bank_account_num IS NULL
  THEN
    --Yao Zhang add begin for bug#8404856
    IF l_paying_customer_id IS NOT NULL
        THEN
      l_valid_customer_id:=l_paying_customer_id;
      l_valid_site_use_id:=l_paying_site_use_id;
    ELSIF l_ori_paying_customer_id IS NOT NULL
  THEN
      l_valid_customer_id:=l_ori_paying_customer_id;
      l_valid_site_use_id:=l_ori_paying_site_use_id;
    ELSE
      l_valid_customer_id:=l_bill_to_customer_id;
      l_valid_site_use_id:=l_bill_to_site_use_id;
        END IF;
    --Yao Zhang add end for bug#8404856


    BEGIN
      -- get party id of paying customer
      SELECT
        party_id
      INTO
        l_paying_party_id
      FROM
        HZ_CUST_ACCOUNTS
      WHERE
        CUST_ACCOUNT_ID = l_valid_customer_id ;--Yao Zhang modified for bug#8404856
      -- get ext_payer_id by party id , site account id , site use id and org id.
      SELECT
        ext_payer_id
      INTO
        l_ext_payer_id
      FROM
        IBY_EXTERNAL_PAYERS_ALL
      WHERE party_id = l_paying_party_id
      AND CUST_ACCOUNT_ID = l_valid_customer_id--Yao Zhang modified for bug#8404856
      AND ACCT_SITE_USE_ID = l_valid_site_use_id--Yao Zhang modified for bug#8404856
      AND ORG_ID = p_org_id  -- org id
      AND org_type = 'OPERATING_UNIT' -- ou
      AND payment_function = 'CUSTOMER_PAYMENT';

      -- get bank account name and bank account num
      SELECT
        bank_account_name
        , bank_account_num
        , bank_id
        , branch_id
      INTO
        l_bank_account_name
        , l_bank_account_num
        , l_bank_id
        , l_bank_branch_id
      FROM (SELECT ibybanks.bank_account_name
                   , ibybanks.bank_account_num
                   , ibybanks.bank_id
                   , ibybanks.branch_id
            FROM IBY_PMT_INSTR_USES_ALL ExtPartyInstrumentsEO
            , IBY_EXT_BANK_ACCOUNTS ibybanks
            WHERE ibybanks.EXT_BANK_ACCOUNT_ID = ExtPartyInstrumentsEO.instrument_id
            AND ExtPartyInstrumentsEO.INSTRUMENT_TYPE = 'BANKACCOUNT'
            AND ExtPartyInstrumentsEO.EXT_PMT_PARTY_ID = l_ext_payer_id
            AND ExtPartyInstrumentsEO.PAYMENT_FUNCTION = 'CUSTOMER_PAYMENT'
            AND (ibybanks.currency_code = l_currency_code OR ibybanks.currency_code IS NULL)
            AND SYSDATE BETWEEN nvl(ExtPartyInstrumentsEO.START_DATE, to_date('1900-01-01','RRRR-MM-DD'))
                          AND nvl(ExtPartyInstrumentsEO.END_DATE, to_date('3000-01-01','RRRR-MM-DD'))
            ORDER BY ibybanks.currency_code,ExtPartyInstrumentsEO.ORDER_OF_PREFERENCE)
      WHERE ROWNUM =1;

      -- get bank name
      --Modified begin by Yao for bug#8605196 to support bank name in Chinese
      SELECT
       decode(organization_name_phonetic
              ,null, party_name
              ,organization_name_phonetic)
     --Modified end by Yao for bug#8605196 to support bank name in Chinese
      INTO
        l_bank_name
      FROM
        HZ_PARTIES
      WHERE
        party_id = l_bank_id;

      -- get bank branch name
      SELECT
    --Modified begin by Yao for bug#8605196 to support bank name in Chinese
       decode(organization_name_phonetic
              ,null, party_name
              ,organization_name_phonetic)
    --Modified end by Yao for bug#8605196 to support bank name in Chinese
      INTO
        l_bank_branch_name
      FROM
        HZ_PARTIES
      WHERE party_id = l_bank_branch_id;
    EXCEPTION
      WHEN no_data_found THEN
        IF(FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
          fnd_log.STRING(fnd_log.LEVEL_EXCEPTION
                         , G_MODULE_PREFIX || l_procedure_name
                         , 'no date found when select bank information');
        END IF;
    END;/*l_apba_bank_account_num IS NULL*/
  END IF;

  x_bank_name            := l_bank_name;
  x_bank_branch_name     := l_bank_branch_name;
  x_bank_account_num     := l_bank_account_num;
  x_bank_account_name    := l_bank_account_name;

  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_procedure_name
                  ,'End Procedure. ');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_procedure_name || '. OTHER_EXCEPTION '
                    , Sqlcode||Sqlerrm);
    END IF;
    RAISE;
END Get_CM_Bank_Info;

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
--      x_status                 OUT NOCOPY  NUMBER
--      x_tax_line_id            OUT NOCOPY  zx_lines.tax_line_id%TYPE
--
--  DESIGN REFERENCES:
--
--
--  CHANGE HISTORY:
--
--           13-Oct-2005: JIM.Zheng   Created
--
--===========================================================================
PROCEDURE Verify_Tax_Line
(p_trx_line_id      IN          NUMBER
, p_tax_type_code   IN          VARCHAR2
, p_currency_code   IN          VARCHAR2
, x_status          OUT NOCOPY  NUMBER
, x_tax_line_id     OUT NOCOPY  zx_lines.tax_line_id%TYPE
)
IS
l_tax_line_count      NUMBER;
l_procedure_name      VARCHAR2(50) := 'verify_tax_line';
l_tax_line_id         zx_lines.tax_line_id%TYPE;
l_trx_id              ra_customer_trx_all.customer_trx_id%TYPE;--jogen bug5212702 May-17,2006

BEGIN

  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_procedure_name
                  ,'begin Procedure. ');
  END IF;

  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    log( 'Begin Verify_Tax_line---');
    log( 'p_trx_line_id :'||p_trx_line_id);
    log( 'p_tax_type_code :'||p_tax_type_code);
    log( 'p_currency_code :'||p_currency_code);
  END IF;

  -- init status
  x_status := 0 ;

  -- get the tax lines count of  Ar line which the tax type is VAT
  SELECT customer_trx_id
    INTO l_trx_id
   FROM ra_customer_trx_lines_all
   WHERE customer_trx_line_id=p_trx_line_id;

  SELECT
    COUNT(*)
  INTO
    l_tax_line_count
  FROM
    zx_lines tax
  WHERE tax.trx_line_id = p_trx_line_id
    AND tax.entity_code = 'TRANSACTIONS'
    AND application_id = 222
    AND tax.trx_level_type = 'LINE'
    AND tax.tax_currency_code = p_currency_code
    AND tax.tax_type_code = p_tax_type_code
    AND tax.event_class_code IN ('INVOICE','CREDIT_MEMO','DEBIT_MEMO')--jogen bug5212702 May-17,2006
    AND tax.trx_id=l_trx_id;                                      --jogen bug5212702 May-17,2006


  -- if the line number is 0, then x_status = -1
  -- if the line number is 1, then x_status = 0
  -- if the line number > 1 , then x_status = 1
  IF l_tax_line_count = 0
  THEN
    x_status := -1;
  ELSIF l_tax_line_count = 1
  THEN
    x_status := 0;
    BEGIN
      SELECT
        tax.tax_line_id
      INTO
        l_tax_line_id
      FROM
        zx_lines tax
      WHERE tax.trx_line_id = p_trx_line_id
        AND tax.application_id = 222
        AND tax.trx_level_type = 'LINE'
        AND tax.entity_code = 'TRANSACTIONS'
        AND tax.tax_type_code = p_tax_type_code
        AND tax.event_class_code IN ('INVOICE','CREDIT_MEMO','DEBIT_MEMO')--jogen bug5212702 May-17,2006
        AND tax.trx_id=l_trx_id;                                      --jogen bug5212702 May-17,2006
    END;
  ELSE
    x_status := 1;

  END IF;/*l_tax_line_count = 0*/

  x_tax_line_id := l_tax_line_id;

  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    log( 'x_status : '||x_status);
  END IF;

  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_procedure_name
                  ,'End Procedure. ');
  END IF;

  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    log( 'End Verify_Tax_line---');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_procedure_name || '. OTHER_EXCEPTION '
                    , Sqlcode||Sqlerrm);
    END IF;
    RAISE;


END Verify_Tax_Line;
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
--      x_invoice_type           OUT NOCOPY  VARCHAR2
--      x_error_buffer           OUT NOCOPY  VARCHAR2
--
--
--  DESIGN REFERENCES:
--
--
--  CHANGE HISTORY:
--
--           17-SEP-2005: JIM.Zheng   Created
--           28-DEC-2007: Subba Changed for R12.1
--           13-May-2009  Yao Zhang changed for bug#5604079
--           12-Mar-2010 Yao Zhang changed for bug#9369455
--===========================================================================
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
)
IS
l_procedure_name           VARCHAR2(30) := 'get_info_from_ebtax';
l_lines_status             NUMBER;
l_status                   NUMBER;
l_error_buffer             VARCHAR2(180);
l_tax_registration_number  zx_lines.tax_registration_number%TYPE;
l_tax_registration_count   NUMBER;
l_tax_line_id              zx_lines.tax_line_id%TYPE;
l_tax_rate                 zx_lines.tax_rate%TYPE;
l_unit_price               zx_lines.unit_price%TYPE;
l_trx_line_quantity        zx_lines.trx_line_quantity%TYPE;
l_tax_amount               zx_lines.tax_amt_funcl_curr%TYPE;
l_taxable_amount           zx_lines.taxable_amt_funcl_curr%TYPE;
l_tax_curr_conversion_rate zx_lines.tax_currency_conversion_rate%TYPE;
l_tp_registration_number   zx_registrations.registration_number%TYPE;
l_fp_reg_number_count      NUMBER;
l_amount                   zx_lines.taxable_amt%TYPE;
l_currency_code            VARCHAR2(30);
l_error_string             VARCHAR2(500);
      --added by subba for R12.1
l_invoice_type    ar_gta_tax_limits_all.invoice_type%type;

tax_error_for_recycle    EXCEPTION;    --exception for tax_amount check for recycle Invoice

BEGIN
  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_procedure_name
                  ,'begin Procedure. ');
    fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_procedure_name
                  ,'p_trx_line_id: '||p_trx_line_id);

  END IF;

  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    log( 'Begin Get_Info_From_Ebtax --');
    log( 'p_org_id : '||p_org_id);
    log( 'p_trx_id : '||p_trx_id);
    log( 'p_trx_line_id : '||p_trx_line_id);
    log( 'p_tax_type_code : '||p_tax_type_code);
    log( 'x_status : '||x_status);
    log( 'x_status : '||x_status);
    log( 'x_status : '||x_status);
  END IF;

  -- init status
  x_status := 0 ;

  BEGIN
    SELECT
      gt_currency_code
    INTO
      l_currency_code
    FROM
      ar_gta_system_parameters_all
    WHERE org_id=p_org_id;

  EXCEPTION
    WHEN no_data_found THEN
      --report AR_GTA_MISSING_ERROR
      fnd_message.set_name('AR', 'AR_GTA_SYS_CONFIG_MISSING');
      l_error_string := fnd_message.get();
      -- output this error
     fnd_file.put_line(fnd_file.output,'<?xml version="1.0" encoding="UTF-8"?>
                       <TransferReport>
                       <ReportFailed>Y</ReportFailed>
                       <ReportFailedMsg>'||l_error_string||'</ReportFailedMsg>
                       <TransferReport>');


      IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        fnd_log.STRING(fnd_log.LEVEL_UNEXPECTED
                       , G_MODULE_PREFIX || l_procedure_name
                       , l_error_string);
      END IF;

      RAISE;
  END;


  -- verify tax Line number.
  verify_tax_line
  (p_trx_line_id      => p_trx_line_id
  , p_tax_type_code   => p_tax_type_code
  , p_currency_code   => l_currency_code
  , x_status          => l_lines_status
  , x_tax_line_id     => l_tax_line_id
  );


  -- if the line count is 0, return -1 and the line can't be transfer and don't
  -- throw any exception
  -- if the line count > 1 , return 1 and throw exception
  -- if the line count = 1 , get data from zx_lines and transfer it to GTA
  -- 29-JUN-2006 Upated by Shujuan, insert Tax_currency_conversion_rate
  -- into l_tax_curr_conversion_rate in order to calculate the unit price of
  -- tax concurrency for bug 5168900
  IF l_lines_status = 0
  THEN
    SELECT
      tax.tax_line_id
      , tax.hq_estb_reg_number
      , tax.taxable_amt_tax_curr
      , tax.tax_rate
      , tax.tax_amt_tax_curr
      , tax.unit_price
      , tax.trx_line_quantity
      , tax.taxable_amt
      , tax.Tax_currency_conversion_rate
    INTO
      l_tax_line_id
      , l_tax_registration_number
      , l_taxable_amount
      , l_tax_rate
      , l_tax_amount
      , l_unit_price
      , l_trx_line_quantity
      , l_amount
      , l_tax_curr_conversion_rate
    FROM
      zx_lines tax
    WHERE tax.trx_line_id = p_trx_line_id
      AND tax.entity_code = 'TRANSACTIONS'
      AND application_id = 222
      AND tax.trx_level_type = 'LINE'
      AND tax.tax_currency_code = l_currency_code
      AND tax.tax_type_code = p_tax_type_code
      --jogen bug5212702 May-17,2006
      AND tax.event_class_code IN ('INVOICE','CREDIT_MEMO','DEBIT_MEMO')
      AND tax.trx_id=p_trx_id;    --jogen bug5212702 May-17,2006


    -- find the registration number from system option
    -- if the number is exist then go ahead
    -- if the number is not exist , then throw a exception
    IF l_tax_registration_number IS NULL
    THEN
      -- throw first party registion number is null exception
      x_status := 1;
      l_error_buffer := 'AR_GTA_FP_TAXREG_MISSING';
    ELSE /*l_tax_registration_number IS NULL*/
      -- find the first party registion number in parameter
      SELECT
        COUNT(*)
      INTO
        l_fp_reg_number_count
      FROM
        ar_gta_tax_limits_all
      WHERE org_id = p_org_id
        AND fp_tax_registration_number = l_tax_registration_number;

      IF l_fp_reg_number_count = 0
      THEN
        x_status := 2;
        l_error_buffer := 'AR_GTA_SYS_CONFIG_MISSING';
      ELSE
        --if there no exception when get first party registration number then
        --get third party registration number

        get_tp_tax_registration_number
        ( p_trx_id        => p_trx_id
         , p_tax_line_id  => l_tax_line_id
         , x_tp_tax_registration_number => l_tp_registration_number
         );
      END IF;/*l_fp_reg_number_count = 0*/

    --following code added by subba for R12.1

     --IF l_tax_registration_number IS NOT NULL THEN

       l_invoice_type :=  get_invoice_type( p_org_id =>   p_org_id
                                          ,p_customer_trx_id => p_trx_id
                                          ,p_fp_tax_registration_num => l_tax_registration_number );
     --END IF;

    -- throw a missing tp registration number exception when invoice type is not C


    -- 2 stands for Common Invoice, 1 for Recycle Invoice, 0 for Special Invoice.

    -- to keep consistent with the flat file format of Asino.

   IF l_invoice_type IS NULL THEN
     x_status := 1;
     l_error_buffer := 'AR_GTA_MISSING_INVOICE_TYPE';


   ELSE /*IF l_invoice_type IS NULL*/

	IF l_invoice_type <> '2' THEN    --if not common VAT Invoice

	      IF l_tp_registration_number IS NULL  THEN
	          -- throw third party registion number is null exception
		  x_status := 1;
	          l_error_buffer := 'AR_GTA_TP_TAXREG_MISSING';
	      ELSE /*l_tp_registration_number IS NULL*/
	          x_tp_registration_number := l_tp_registration_number;
	      END IF;/*l_tp_registration_number IS NULL*/
         END IF; /* l_invoice_type <>'2'*/

      --END IF;

   -- validate tax rate and tax amount are zero when invoice type is R, added by Subba for R12.1

	IF l_invoice_type = '1'             -- 1 stands for Recycle Invoice
	THEN
	      IF (l_tax_rate <> 0 OR l_tax_amount <> 0)  THEN
                 x_status := 1;
		 l_error_buffer := 'AR_GTA_TAX_ERROR_RECYCLE';

	      END IF;
	END IF;/*l_invoice_type = '1'*/

   END IF;/*IF l_invoice_type IS NULL*/

      IF l_taxable_amount IS NULL
         OR l_tax_rate IS NULL
         OR l_tax_amount IS NULL
         OR l_unit_price IS NULL
         OR l_trx_line_quantity IS NULL
      THEN
        IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
          fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                        , G_MODULE_PREFIX || l_procedure_name
                        ,'The data come from ebtax is null. ');
        END IF;
      END IF;

    END IF; /*l_tax_registration_number IS NULL*/


  ELSIF l_lines_status = -1
  THEN
    x_status := -1 ;
  ELSIF l_lines_status = 1
  THEN
    -- throw AR_GTA_MULTI_TAXLINE exception
    x_status := 1;
    l_error_buffer := 'AR_GTA_MULTI_TAXLINE';

  END IF;

  -- output the status
  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    log( 'x_status '||x_status);
  END IF;

  x_tax_amount             := l_tax_amount;
  x_taxable_amount         := l_taxable_amount;
  x_trx_line_quantity      := l_trx_line_quantity;
  x_tax_rate               := l_tax_rate/100;
  x_unit_selling_price     := l_unit_price;
  x_tax_curr_unit_price    := l_unit_price * l_tax_curr_conversion_rate;--Yao Zhang changed for bug 5604079/9369455
  x_fp_registration_number := l_tax_registration_number;
  x_tp_registration_number := l_tp_registration_number;
  x_taxable_amount_org     := l_amount;
  x_error_buffer           := l_error_buffer;
  x_invoice_type           := l_invoice_type;


 -- 29-JUN-2006 Added by Shujuan, calculate the unit price of tax currency
 -- and return it for bug 5168900
  --x_tax_curr_unit_price  := round(l_unit_price * l_tax_curr_conversion_rate);



  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    log( 'End Get_Info_From_Ebtax --');
  END IF;

  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_procedure_name
                  ,'End Procedure. ');
  END IF;

EXCEPTION
/*   WHEN tax_error_for_recycle THEN    --added by subba for R12.1

    fnd_message.SET_NAME('AR', 'AR_GTA_TAX_ERROR_RECYCLE');
    l_error_string := fnd_message.get();
    -- begin log
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_procedure_name
                    , 'tax rate and tax amount should be zero for Recycle Invoices');
    END IF;
    RAISE;

    -- end log
    RAISE;*/
  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_procedure_name || '. OTHER_EXCEPTION '
                    , Sqlcode||Sqlerrm);
    END IF;
    RAISE;

END Get_Info_From_Ebtax;

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
--           Mar-21, 2006 Jogen Hu    Bug 5088458
--===========================================================================
PROCEDURE Get_Tp_Tax_Registration_Number
( p_trx_id                        IN          NUMBER
, p_tax_line_id                   IN          NUMBER
, x_tp_tax_registration_number    OUT NOCOPY  VARCHAR2
)
IS
l_procedure_name              VARCHAR2(80) := 'get_tp_tax_registration_number';
l_bill_to_site_use_id         ra_customer_trx_all.bill_to_site_use_id%TYPE;
l_ra_cust_trx_id              ra_customer_trx_all.customer_trx_id%TYPE;
l_tax_regime_code             zx_lines.tax_regime_code%TYPE;
l_tax                         zx_lines.tax%TYPE;
l_tax_jurisdiction_code       zx_lines.tax_jurisdiction_code%TYPE;
l_tax_determine_date          zx_lines.tax_determine_date%TYPE;
l_party_tax_profile_id        zx_party_tax_profile.party_tax_profile_id%TYPE;
l_tax_registration_number     zx_registrations.registration_number%TYPE;
l_reg_tax_regime_code         zx_registrations.tax_regime_code%TYPE;
l_reg_tax                     zx_registrations.tax%TYPE;
l_reg_tax_jursidiction_code   zx_registrations.tax_jurisdiction_code%TYPE;

l_cust_acct_site_id           hz_cust_site_uses_all.cust_acct_site_id%TYPE;
l_party_site_id               hz_cust_acct_sites_all.party_site_id%TYPE;

l_tax_registration_count      NUMBER;
l_tax_profile_status          NUMBER;

l_tp_registration_number      zx_registrations.registration_number%TYPE;
l_tp_registration_number_a    zx_registrations.registration_number%TYPE;
l_tp_registration_number_b    zx_registrations.registration_number%TYPE;
l_tp_registration_number_c    zx_registrations.registration_number%TYPE;

l_return_status               VARCHAR2(200);
l_msg_count                   NUMBER;
l_msg_data                    VARCHAR2(2000);

i                             NUMBER;
l_indexO                      NUMBER;
CURSOR c_tp_reg_num
(p_party_tax_profile_id    NUMBER
,p_tax_regime_code         VARCHAR2
,p_tax                     VARCHAR2
,p_tax_jurisdiction_code   VARCHAR2
,p_tax_determine_date      Date
)
IS
  SELECT
    reg.registration_number
    ,reg.tax_regime_code
    ,reg.tax
    ,reg.tax_jurisdiction_code
  INTO
    l_tax_registration_number
    ,l_reg_tax_regime_code
    ,l_reg_tax
    ,l_reg_tax_jursidiction_code
  FROM
    zx_registrations reg
  WHERE reg.party_tax_profile_id =p_party_tax_profile_id
    AND (reg.tax is NULL or reg.tax = p_tax)
    AND reg.tax_regime_code = p_tax_regime_code  -- tax_regime_code is not null
    AND (reg.tax_jurisdiction_code is NULL or reg.tax_jurisdiction_code = p_tax_jurisdiction_code)
    AND p_tax_determine_date >= reg.effective_from
    AND (p_tax_determine_date < reg.effective_to OR reg.effective_to IS NULL)
    AND reg.registration_number IS NOT NULL;
BEGIN
  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_procedure_name
                  ,'begin Procedure. ');

  END IF;

  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    log( 'Begin Get_Info_From_Ebtax --');
    log( 'p_trx_id :'||p_trx_id);
    log( 'p_tax_line_id:' ||p_tax_line_id);
  END IF;

  --get party_site_id from trx_header
  BEGIN
    -- get site use id by trx id
    SELECT
      bill_to_site_use_id
    INTO
      l_bill_to_site_use_id
    FROM
      ra_customer_trx_all trx_header
    WHERE trx_header.customer_trx_id = p_trx_id;

    -- get cust_acct_site_id by site_use_id
    SELECT
      cust_acct_site_id
    INTO
      l_cust_acct_site_id
    FROM
      hz_cust_site_uses_all
    WHERE SITE_USE_ID = l_bill_to_site_use_id;

    --get party_site_id by cust_acct_site_id
    SELECT
      party_site_id
    INTO
      l_party_site_id
    FROM
      hz_cust_acct_sites_all
    WHERE cust_acct_site_id = l_cust_acct_site_id;
  EXCEPTION
    WHEN no_data_found THEN
      IF(FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        fnd_log.STRING(fnd_log.LEVEL_EXCEPTION
                       , G_MODULE_PREFIX || l_procedure_name
                       , l_procedure_name||'no data found ');
      END IF;/*(FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)*/
  END;

  -- get the tax_regime, tax, tax_jurisdiction by trx line id ;
  BEGIN
    SELECT
      tax.tax_regime_code
      , tax.tax
      , tax.tax_jurisdiction_code
      , tax.tax_determine_date
    INTO
      l_tax_regime_code
      , l_tax
      , l_tax_jurisdiction_code
      , l_tax_determine_date
    FROM
      zx_lines tax
    WHERE
      tax.tax_line_id = p_tax_line_id;

  EXCEPTION
    WHEN no_data_found THEN
      IF(FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        fnd_log.STRING(fnd_log.LEVEL_EXCEPTION
                       , G_MODULE_PREFIX || l_procedure_name
                       , 'no data found ');
      END IF;/*(FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)*/

  END;

  -- get tax_profile_id by party site id
  BEGIN
    SELECT
      party_tax_profile_id
    INTO
      l_party_tax_profile_id
    FROM
      zx_party_tax_profile tax_prof
    WHERE tax_prof.party_id = l_party_site_id
      AND tax_prof.party_type_code = 'THIRD_PARTY_SITE';
  EXCEPTION
    WHEN no_data_found THEN
      IF(FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        fnd_log.STRING(fnd_log.LEVEL_EXCEPTION
                       , G_MODULE_PREFIX || l_procedure_name
                       , 'no data found ');
      END IF;/*(FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)*/
    WHEN too_many_rows THEN
      IF(FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        fnd_log.STRING(fnd_log.LEVEL_EXCEPTION
                       , G_MODULE_PREFIX || l_procedure_name
                       , 'too many rows ');
      END IF;/*(FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)*/
  END;

  /*
  dbms_output.put_line('l_bill_to_site_use_id: '||l_bill_to_site_use_id);
  dbms_output.put_line('l_tax_regime_code: '||l_tax_regime_code);
  dbms_output.put_line('l_tax: '||l_tax);
  dbms_output.put_line('l_tax_jurisdiction_code: '||l_tax_jurisdiction_code);
  dbms_output.put_line('l_party_tax_profile_id: '||l_party_tax_profile_id);
  */
  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    log( 'l_bill_to_site_use_id :'||l_bill_to_site_use_id);
    log( 'l_tax_regime_code:' ||l_tax_regime_code);
    log( 'l_tax:' ||l_tax);
    log( 'l_tax_jurisdiction_code:' ||l_tax_jurisdiction_code);
    log( 'l_party_tax_profile_id:' ||l_party_tax_profile_id);
  END IF;

  IF l_tax_regime_code IS NOT NULL AND l_tax IS NOT NULL AND l_tax_determine_date IS NOT NULL
  THEN
    OPEN c_tp_reg_num (p_party_tax_profile_id    => l_party_tax_profile_id
                      ,p_tax_regime_code         => l_tax_regime_code
                      ,p_tax                     => l_tax
                      ,p_tax_jurisdiction_code   => l_tax_jurisdiction_code
                      ,p_tax_determine_date      => l_tax_determine_date
                      );

    LOOP
      FETCH
        c_tp_reg_num
      INTO
        l_tp_registration_number
        , l_reg_tax_regime_code
        , l_reg_tax
        , l_reg_tax_jursidiction_code;

     IF c_tp_reg_num%NOTFOUND
     THEN
       EXIT;
     END IF;

     IF l_reg_tax = l_tax AND l_reg_tax_jursidiction_code = l_reg_tax_jursidiction_code
     THEN
       l_tp_registration_number_a := l_tp_registration_number;
     ELSIF l_reg_tax = l_tax AND l_reg_tax_jursidiction_code IS NULL
     THEN
       l_tp_registration_number_b := l_tp_registration_number;
     ELSIF l_reg_tax IS NULL AND l_reg_tax_jursidiction_code IS NULL
     THEN
       l_tp_registration_number_c := l_tp_registration_number;
     END IF;
    END LOOP;/*fetch c_tp_reg_num*/
    CLOSE c_tp_reg_num;   --jogen Hu Apr-4, 2006 bug 5135169

    IF l_tp_registration_number_a IS NOT NULL
    THEN
      x_tp_tax_registration_number := l_tp_registration_number_a;
    ELSIF x_tp_tax_registration_number IS NULL AND  l_tp_registration_number_b IS NOT NULL
    THEN
      x_tp_tax_registration_number := l_tp_registration_number_b;
    ELSIF x_tp_tax_registration_number IS NULL AND  l_tp_registration_number_c IS NOT NULL
    THEN
      x_tp_tax_registration_number := l_tp_registration_number_c;
    END IF;/*l_tp_registration_number_a IS NOT NULL*/

  ELSE /*l_tax_regime_code IS NOT NULL AND l_tax IS NOT NULL AND l_tax_determine_date IS NOT NULL*/
    x_tp_tax_registration_number := NULL;

    IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                    , G_MODULE_PREFIX || l_procedure_name
                    ,'tax or tax_jur is null in zx_lines ');
    END IF;

  END IF;/*l_tax_regime_code IS NOT NULL AND l_tax IS NOT NULL AND l_tax_determine_date IS NOT NULL*/

  --dbms_output.put_line('registration_number: '||l_tax_registration_number);
  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    log( 'End Get_Tp_Tax_Registration_Number --');
  END IF;

  --jogen Mar-21, 2006 bug 5088458
  IF x_tp_tax_registration_number IS NULL
  THEN
    x_tp_tax_registration_number := ZX_API_PUB.get_default_tax_reg(
         p_api_version       => 1.0
       , p_init_msg_list     => NULL
       , p_commit            => NULL
       , p_validation_level  => NULL
       , x_return_status     => l_return_status
       , x_msg_count         => l_msg_count
       , x_msg_data          => l_msg_data
       , p_party_id          => l_party_site_id
       , p_party_type        => 'THIRD_PARTY_SITE'
       , p_effective_date    => SYSDATE);

     IF l_msg_count > 0
     THEN

       IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
       THEN
         fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                       , G_MODULE_PREFIX || l_procedure_name
                       , 'ZX_API_PUB.get_default_tax_reg error, see below '
                       ||'the detail error messages' );

          FOR i IN 1..l_msg_count
          LOOP
              FND_MSG_PUB.Get(i, FND_API.G_FALSE, l_msg_data, l_indexO);
              FND_MSG_PUB.Delete_Msg(l_indexO);
              fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                       , G_MODULE_PREFIX || l_procedure_name||'.ZX_API_PUB error'
                       , l_msg_data);

          END LOOP; --i IN 1..l_msg_count

       END IF;--FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL

     END if;--l_msg_count = 0

     IF x_tp_tax_registration_number IS NULL
     THEN
       x_tp_tax_registration_number := ZX_API_PUB.get_default_tax_reg(
           p_api_version       => 1.0
         , p_init_msg_list     => NULL
         , p_commit            => NULL
         , p_validation_level  => NULL
         , x_return_status     => l_return_status
         , x_msg_count         => l_msg_count
         , x_msg_data          => l_msg_data
         , p_party_id          => l_party_site_id
         , p_party_type        => 'THIRD_PARTY'
         , p_effective_date    => SYSDATE);
         IF l_msg_count > 0
         THEN

           IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
           THEN
             fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                           , G_MODULE_PREFIX || l_procedure_name
                           , 'ZX_API_PUB.get_default_tax_reg error, see below '
                           ||'the detail error messages' );

              FOR i IN 1..l_msg_count
              LOOP
                  FND_MSG_PUB.Get(i, FND_API.G_FALSE, l_msg_data, l_indexO);
                  FND_MSG_PUB.Delete_Msg(l_indexO);
                  fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                           , G_MODULE_PREFIX || l_procedure_name||'.ZX_API_PUB error'
                           , l_msg_data);

              END LOOP; --i IN 1..l_msg_count

           END IF;--FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL

         END if;--l_msg_count = 0

     END IF;--x_tp_tax_registration_number IS NULL

  END IF; --x_tp_tax_registration_number IS NULL
  --jogen Mar-21, 2006 bug 5088458

  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_procedure_name
                  ,'End Procedure. ');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_procedure_name || '. OTHER_EXCEPTION '
                    , Sqlcode||Sqlerrm);
    END IF;
    RAISE;
END Get_Tp_Tax_Registration_Number;

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
RETURN VARCHAR2
IS
l_tax_type_code                      zx_lines.tax_type_code%TYPE;
l_tax_rate                           NUMBER;
l_gt_currency_code                   fnd_currencies.currency_code%TYPE;
l_tax_line_id                        zx_lines.tax_line_id%TYPE;
l_tp_tax_registration_number         zx_registrations.registration_number%TYPE;
l_trx_id               ra_customer_trx_all.customer_trx_id%TYPE;--Donghai Wang bug5212702 May-17,2006


CURSOR c_tax_type_code
IS
SELECT
  vat_tax_type_code
 ,gt_currency_code
FROM
  ar_gta_system_parameters_all
WHERE org_id=p_org_id;

--CURSOR c_tax_line_id          --Donghai Wang bug5212702 May-17,2006
CURSOR c_tax_line_id(pc_trx_id NUMBER)--Donghai Wang bug5212702 May-17,2006
IS
SELECT
  tax_line_id
FROM
  zx_lines
  WHERE trx_line_id=p_customer_trx_line_id
  AND entity_code='TRANSACTIONS'
  AND application_id = 222
  AND trx_id = p_customer_trx_id
  AND trx_level_type='LINE'
  AND tax_type_code=l_tax_type_code
  AND tax_currency_code=l_gt_currency_code
  AND event_class_code IN ('INVOICE','CREDIT_MEMO','DEBIT_MEMO')--Donghai Wang bug5212702 May-17,2006
  AND trx_id=pc_trx_id  --Donghai Wang bug5212702 May-17,2006
ORDER BY tax_line_id;



l_dbg_level            NUMBER       := fnd_log.g_current_runtime_level;
l_proc_level           NUMBER       := fnd_log.level_procedure;
l_procedure_name       VARCHAR2(30) :='Get_Arline_Tp_Taxreg_Number';

BEGIN
  --logging for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || l_procedure_name || '.begin'
                  ,'Enter function');
  END IF; --l_proc_level>=l_dbg_level)


  --Get Vat tax type and GT currency code defined in GTA system options form
  --for current operating unit
  OPEN c_tax_type_code;
  FETCH c_tax_type_code INTO l_tax_type_code,l_gt_currency_code;
  CLOSE c_tax_type_code;

  --Get VAT tax line id for current AR line

  --Donghai Wang bug5212702 May-17,2006
  --  OPEN c_tax_line_id;
  SELECT customer_trx_id
    INTO l_trx_id
   FROM ra_customer_trx_lines_all
   WHERE customer_trx_line_id=p_customer_trx_line_id;

  OPEN c_tax_line_id(l_trx_id);
  --Donghai Wang bug5212702 May-17,2006

  FETCH c_tax_line_id INTO l_tax_line_id;
  CLOSE c_tax_line_id;

  --To get third party tax registration number for cunrrent VAT tax line
  Get_Tp_Tax_Registration_Number(p_trx_id                      =>   p_customer_trx_id
                                ,p_tax_line_id                 =>   l_tax_line_id
                                ,x_tp_tax_registration_number  =>   l_tp_tax_registration_number
                                );

  --logging for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || l_procedure_name || '.End'
                  ,'Exit function');
  END IF; --l_proc_level>=l_dbg_level)

  RETURN(l_tp_tax_registration_number);
END Get_Arline_Tp_Taxreg_Number;



--========================================================================
-- PROCEDURE : debug_output    PUBLIC
-- PARAMETERS: p_output_to            Identifier of where to output to
--             p_api_name             the called api name
--             p_log_level            log level
--             p_message              the message that need to be output
--
-- COMMENT   : the debug output, for using in readonly UT environment
--
-- PRE-COND  :
--
-- EXCEPTIONS:
--========================================================================
PROCEDURE Debug_Output
( p_output_to IN VARCHAR2
, p_log_level IN NUMBER
, p_api_name  IN VARCHAR2
, p_message   IN VARCHAR2
)
IS
l_procedure_name    VARCHAR2(30) := 'debug_output';
BEGIN

  CASE p_output_to
    WHEN 'FND_LOG.STRING' THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.STRING(FND_LOG.LEVEL_PROCEDURE
                      ,p_api_name || '.debug_output'
                      ,p_message);
      END IF;
    WHEN 'FND_FILE.OUTPUT' THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_file.put_line(fnd_file.OUTPUT
                         ,p_api_name || '.debug_output' || ': ' ||
                          p_message);
      END IF;
    WHEN 'FND_FILE.LOG' THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
        log(p_api_name || '.debug_output' || ': ' ||
                          p_message);
      END IF;
    ELSE
      NULL;
  END CASE;

EXCEPTION
  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_procedure_name || '. OTHER_EXCEPTION '
                    , Sqlcode||Sqlerrm);
    END IF;
    RAISE;

END Debug_Output;


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
RETURN VARCHAR2 IS
  l_procedure_name VARCHAR2(30) := 'Get_AR_Batch_Source_Name';
  l_dbg_level      NUMBER := fnd_log.g_current_runtime_level;
  l_proc_level     NUMBER := fnd_log.level_procedure;

  l_source_name RA_BATCH_SOURCES_all.NAME%TYPE;
  CURSOR c_source_name IS
    SELECT RA_BATCH_SOURCES_all.NAME
    FROM   RA_BATCH_SOURCES_all
    WHERE  org_id = p_org_id
      AND  BATCH_SOURCE_ID = p_source_id;

BEGIN
  --logging for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || l_procedure_name || '.begin'
                  ,'enter function');
  END IF;

  OPEN c_source_name;
  FETCH
    c_source_name
  INTO
    l_source_name;

  CLOSE c_source_name;

  --logging for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || l_procedure_name || '.end'
                  ,'end function');
  END IF;

  RETURN(l_source_name);
END Get_AR_Batch_Source_Name;

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
RETURN VARCHAR2
IS
l_xsd_date_string   VARCHAR2(40);
l_procedure_name    VARCHAR2(30) := 'To_Xsd_Date_String';
l_dbg_level         NUMBER := fnd_log.g_current_runtime_level;
l_proc_level        NUMBER := fnd_log.level_procedure;

BEGIN

 --logging for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || l_procedure_name || '.begin'
                  ,'enter function');
  END IF;

  --If input parameter is null, then returen a null string
  IF p_date IS NULL
  THEN
    IF (l_proc_level >= l_dbg_level)
    THEN
      FND_LOG.string( l_proc_level
                    , G_MODULE_PREFIX
                    , G_MODULE_PREFIX ||  l_procedure_name
                    || '.end'
                    );
    END IF;

    RETURN NULL;
  END IF; --p_date IS NULL



  SELECT TO_CHAR(p_date, 'YYYY-MM-DD')
  INTO   l_xsd_date_string
  FROM   DUAL;


  IF (l_proc_level >= l_dbg_level)
  THEN
    FND_LOG.string( l_proc_level
                  , G_MODULE_PREFIX
                  , G_MODULE_PREFIX ||  l_procedure_name
                  || '.end: Returning XSD Date = '
                  || l_xsd_date_string);
  END IF;

  l_xsd_date_string := TRIM(l_xsd_date_string);

  RETURN l_xsd_date_string;

EXCEPTION

  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_procedure_name || '. OTHER_EXCEPTION '
                    , Sqlcode||Sqlerrm);
    END IF;
    RAISE;


END To_Xsd_Date_String;

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
RETURN VARCHAR2
IS
l_procedure_name   VARCHAR2(30) := 'Format_Monetary_Amount';
l_dbg_level        NUMBER       := fnd_log.g_current_runtime_level;
l_proc_level       NUMBER       := fnd_log.level_procedure;
l_base_currency    ar_gta_system_parameters_all.gt_currency_code%TYPE;
l_format_mask      VARCHAR2(50);
l_formatted_amount VARCHAR2(50);

CURSOR c_base_currency IS
SELECT
  gt_currency_code
FROM
  ar_gta_system_parameters_all
WHERE
  org_id=p_org_id;

BEGIN

  --logging for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || l_procedure_name || '.begin'
                  ,'enter function');
  END IF;

  --Get VAT Currency code of current operating unit
  OPEN c_base_currency;
  FETCH c_base_currency INTO l_base_currency;
  CLOSE c_base_currency;

  --Get format mask for VAT currency code
  l_format_mask:=FND_CURRENCY.Get_Format_Mask(currency_code => l_base_currency
                                             ,field_length  => 30
                                             );
  l_formatted_amount:=to_char(p_amount,l_format_mask);

  --logging for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || l_procedure_name || '.end'
                  ,'end function');
  END IF;
  RETURN l_formatted_amount;

EXCEPTION

  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_procedure_name || '. OTHER_EXCEPTION '
                    , Sqlcode||Sqlerrm);
    END IF;
    RAISE;

END Format_Monetary_Amount;

--==========================================================================
--  PROCEDURE NAME:
--
--    Populate_Invoice_Type                    Public
--
--  DESCRIPTION:
--
--      This procedure is to populate invoice type column for Transfer Rule
--      and System Option tables to do the data migration from R12.0 to R12.1.X.
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
PROCEDURE Populate_Invoice_Type(p_org_id IN NUMBER)
IS
l_dbg_level            NUMBER       := fnd_log.g_current_runtime_level;
l_proc_level           NUMBER       := fnd_log.level_procedure;
l_procedure_name       VARCHAR2(30) := 'Populate_Invoice_Type';


BEGIN
  --logging for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || l_procedure_name || '.begin'
                  ,'Enter procedure');
  END IF; --l_proc_level>=l_dbg_level)
  -- initialize invoice type for System Option and Transfer Rules
  UPDATE ar_gta_tax_limits_all
  SET    invoice_type=0
  WHERE  invoice_type IS NULL
  AND    org_id = p_org_id;

  UPDATE ar_gta_rule_headers_all
  SET    invoice_type=0
  WHERE  invoice_type IS NULL
  AND    org_id = p_org_id;

  COMMIT;

  fnd_message.set_name('AR', 'AR_GTA_INV_TYPE_INIT');
  fnd_message.set_token('ORG_NAME',get_operatingunit(p_org_id));
  fnd_file.put_line(fnd_file.OUTPUT, fnd_message.get());

  --logging for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || l_procedure_name || '.end'
                  ,'end procedure');
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_procedure_name || '. OTHER_EXCEPTION '
                    , Sqlcode||Sqlerrm);
    END IF;
    RAISE;

END Populate_Invoice_Type;

--==========================================================================
--  PROCEDURE NAME:
--
--    Populate_Invoice_Type_Header                    Public
--
--  DESCRIPTION:
--
--      This procedure is to populate invoice type column for GTA Invoice Header
--      table to do the data migration from R12.0 to R12.1.X.
--
--  PARAMETERS:
--      In: p_org_id    NUMBER
--      Out:
--
--  DESIGN REFERENCES:
--      GTA_12.1.2_Technical_Design.doc
--
--  CHANGE HISTORY:
--
--           16-Aug-2009: Allen Yang   Created.
--           26-Aug-2009: Allen Yang   Modified for bug 8839141.
--===========================================================================
PROCEDURE Populate_Invoice_Type_Header(p_org_id IN NUMBER)
IS
l_dbg_level            NUMBER       := fnd_log.g_current_runtime_level;
l_proc_level           NUMBER       := fnd_log.level_procedure;
l_procedure_name       VARCHAR2(30) := 'Populate_Invoice_Type_Header';

-- all GTA invoices whose AR transaction type is not associated to invoice type
CURSOR c_inv_trx_type_no_inv_type
IS
SELECT JGTH.GTA_TRX_NUMBER, SOURCE
FROM RA_CUSTOMER_TRX_ALL RCT
   , AR_GTA_TRX_HEADERS_ALL JGTH
WHERE invoice_type is null
  AND JGTH.ORG_ID = p_org_id
  AND RCT.CUSTOMER_TRX_ID(+) = JGTH.Ra_Trx_Id
  AND NOT EXISTS (SELECT JGTL.Limitation_Id
                    FROM ar_gta_tax_limits_all JGTL
                        ,ar_gta_type_mappings  JGTM
                   WHERE JGTL.ORG_ID = JGTH.Org_Id
                     AND JGTL.FP_TAX_REGISTRATION_NUMBER = JGTH.FP_TAX_REGISTRATION_NUMBER
                     AND JGTM.Limitation_Id = JGTL.LIMITATION_ID
                     AND JGTM.TRANSACTION_TYPE_ID = RCT.CUST_TRX_TYPE_ID);

-- all GTA invoices whose AR transaction type is associated to Recycle invoice type,
-- but tax rate and amount is not zero.
CURSOR c_recycle_tax_amount_not_zero
IS
SELECT JGTH.GTA_TRX_NUMBER, SOURCE
FROM RA_CUSTOMER_TRX_ALL RCT
   , AR_GTA_TRX_HEADERS_ALL JGTH
WHERE invoice_type is null
  AND JGTH.ORG_ID = p_org_id
  AND RCT.CUSTOMER_TRX_ID(+) = JGTH.Ra_Trx_Id
  AND EXISTS (SELECT JGTL.Limitation_Id
                    FROM ar_gta_tax_limits_all JGTL
                        ,ar_gta_type_mappings  JGTM
                   WHERE JGTL.ORG_ID = JGTH.Org_Id
                     AND JGTL.FP_TAX_REGISTRATION_NUMBER = JGTH.FP_TAX_REGISTRATION_NUMBER
                     AND JGTM.Limitation_Id = JGTL.LIMITATION_ID
                     AND JGTM.TRANSACTION_TYPE_ID = RCT.CUST_TRX_TYPE_ID);

-- credit memo whose invoice type is different with invoice type of original transaction
CURSOR c_cm_inv_type_different
IS
SELECT JGTH.GTA_TRX_NUMBER, SOURCE
FROM RA_CUSTOMER_TRX_ALL     RCT,
     RA_CUST_TRX_TYPES_ALL   RCTT,
     AR_GTA_TRX_HEADERS_ALL JGTH
WHERE invoice_type is not null
  AND JGTH.ORG_ID = p_org_id
  AND RCT.CUSTOMER_TRX_ID(+) = JGTH.Ra_Trx_Id
  AND RCT.CUST_TRX_TYPE_ID = RCTT.CUST_TRX_TYPE_ID(+)
  AND RCTT.ORG_ID=JGTH.ORG_ID
  AND RCTT.TYPE = 'CM'
  AND RCT.previous_customer_trx_id is not null
  AND JGTH.invoice_type <>
      (SELECT DISTINCT invoice_type
         FROM AR_GTA_TRX_HEADERS_ALL JGTH1
        WHERE JGTH1.RA_TRX_id = RCT.previous_customer_trx_id);

-- all GTA invoices need to be updated
CURSOR c_all_inv_updated
IS
SELECT GTA_TRX_HEADER_ID
     , GTA_TRX_NUMBER
     , SOURCE
     , RA_TRX_ID
     , FP_TAX_REGISTRATION_NUMBER
     , ORG_ID
  FROM AR_GTA_TRX_HEADERS_ALL
 WHERE INVOICE_TYPE IS NULL
   AND ORG_ID = p_org_id;

l_gta_trx_number              ar_gta_trx_headers_all.GTA_TRX_NUMBER%TYPE;
l_source                      ar_gta_trx_headers_all.SOURCE%TYPE;
l_gta_trx_header_id           ar_gta_trx_headers_all.GTA_TRX_HEADER_ID%TYPE;
l_ra_trx_id                   ar_gta_trx_headers_all.RA_TRX_ID%TYPE;
l_fp_tax_registration_number  ar_gta_trx_headers_all.FP_TAX_REGISTRATION_NUMBER%TYPE;
l_org_id                      ar_gta_trx_headers_all.ORG_ID%TYPE;
l_invoice_type                ar_gta_trx_headers_all.INVOICE_TYPE%TYPE;
l_pre_trx_invoice_type        ar_gta_trx_headers_all.INVOICE_TYPE%TYPE;
l_ar_trx_type                 RA_CUST_TRX_TYPES_ALL.TYPE%TYPE;


BEGIN
  --logging for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || l_procedure_name || '.begin'
                  ,'Enter procedure');
  END IF; --l_proc_level>=l_dbg_level)

  -- log for successfully updated invoice numbers
  fnd_message.set_name('AR', 'AR_GTA_UPG_TRANSACTION_S');
  fnd_file.put_line(fnd_file.OUTPUT, fnd_message.get());

  OPEN c_all_inv_updated;
  LOOP
  FETCH c_all_inv_updated
  INTO l_gta_trx_header_id
     , l_gta_trx_number
     , l_source
     , l_ra_trx_id
     , l_fp_tax_registration_number
     , l_org_id;
  EXIT WHEN c_all_inv_updated%NOTFOUND;
    BEGIN
      SELECT JGTL.invoice_type
      INTO l_invoice_type
      FROM RA_CUSTOMER_TRX_ALL    RCT
          ,ar_gta_tax_limits_all JGTL
      WHERE RCT.CUSTOMER_TRX_ID = l_ra_trx_id
        AND JGTL.ORG_ID = l_org_id
        AND JGTL.FP_TAX_REGISTRATION_NUMBER = l_fp_tax_registration_number
        AND RCT.CUST_TRX_TYPE_ID in
            (SELECT JGTM.TRANSACTION_TYPE_ID
             FROM ar_gta_type_mappings JGTM
             WHERE JGTM.Limitation_Id = JGTL.LIMITATION_ID)
               AND (JGTL.invoice_type IN ('0', '2') OR
                    (JGTL.invoice_type = '1' AND NOT EXISTS
                     (  SELECT *
                        FROM ar_gta_trx_lines_all JGTLA
                        WHERE JGTLA.GTA_TRX_HEADER_ID = l_gta_trx_header_id
                          AND JGTLA.Org_Id = l_org_id
                          AND (JGTLA.Tax_Rate <> 0 OR
                               JGTLA.Tax_Amount <> 0))));
    EXCEPTION
    WHEN no_data_found THEN
      IF(FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        fnd_log.STRING(fnd_log.LEVEL_EXCEPTION
                       , G_MODULE_PREFIX || l_procedure_name
                       , l_procedure_name||'no data found ');
      END IF;/*(FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)*/
    END;
    IF l_invoice_type IS NOT NULL
    THEN
      BEGIN
        SELECT RCTT.TYPE
        INTO l_ar_trx_type
        FROM RA_CUST_TRX_TYPES_ALL    RCTT
            ,RA_CUSTOMER_TRX_ALL      RCT
            ,AR_GTA_TRX_HEADERS_ALL  JGTH
        WHERE JGTH.GTA_TRX_HEADER_ID = l_gta_trx_header_id
          AND RCT.CUSTOMER_TRX_ID(+) = JGTH.Ra_Trx_Id
          AND RCT.CUST_TRX_TYPE_ID = RCTT.CUST_TRX_TYPE_ID(+)
          AND RCTT.ORG_ID = l_org_id;
      EXCEPTION
      WHEN no_data_found THEN
        IF(FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
          fnd_log.STRING(fnd_log.LEVEL_EXCEPTION
                       , G_MODULE_PREFIX || l_procedure_name
                       , l_procedure_name||'no data found ');
        END IF;/*(FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)*/
      END;
      -- if AR transaction Type is Credit Memo, then check invoice type of original transaction,
      -- else this GTA invoice can be successfully updated.
      IF (NVL(l_ar_trx_type, 'INV')='CM')
      THEN
        BEGIN
          SELECT DISTINCT JGTH.invoice_type
          INTO l_pre_trx_invoice_type
          FROM AR_GTA_TRX_HEADERS_ALL  JGTH
              ,RA_CUSTOMER_TRX_ALL      RCT
          WHERE RCT.CUSTOMER_TRX_ID(+) = l_ra_trx_id
            AND JGTH.RA_TRX_id = RCT.previous_customer_trx_id;
        EXCEPTION
        WHEN no_data_found THEN
          IF(FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
          THEN
            fnd_log.STRING(fnd_log.LEVEL_EXCEPTION
                       , G_MODULE_PREFIX || l_procedure_name
                       , l_procedure_name||'no data found ');
          END IF;/*(FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)*/
        END;
        IF (l_pre_trx_invoice_type IS NOT NULL AND l_pre_trx_invoice_type = l_invoice_type)
        THEN
          fnd_file.put_line(fnd_file.OUTPUT, l_gta_trx_number||'('||l_source||')');
        END IF;
      ELSE
        fnd_file.put_line(fnd_file.OUTPUT, l_gta_trx_number||'('||l_source||')');
      END IF;
    END IF; --l_invoice_type IS NOT NULL
  END LOOP; -- c_all_inv_updated%NOTFOUND;
  CLOSE c_all_inv_updated;

  -- initialize invoice type for GTA invoices
  UPDATE AR_GTA_TRX_HEADERS_ALL JGTH
     SET invoice_type = (SELECT JGTL.invoice_type
                         FROM RA_CUSTOMER_TRX_ALL    RCT,
                              ar_gta_tax_limits_all JGTL
                        WHERE RCT.CUSTOMER_TRX_ID = JGTH.Ra_Trx_Id
                          AND JGTL.ORG_ID = JGTH.Org_Id
                          AND JGTL.FP_TAX_REGISTRATION_NUMBER =
                              JGTH.FP_TAX_REGISTRATION_NUMBER
                          AND RCT.CUST_TRX_TYPE_ID in
                              (SELECT JGTM.TRANSACTION_TYPE_ID
                                 FROM ar_gta_type_mappings JGTM
                                WHERE JGTM.Limitation_Id = JGTL.LIMITATION_ID)
                          AND (JGTL.invoice_type IN ('0', '2') OR
                              (JGTL.invoice_type = '1' AND NOT EXISTS
                               (  SELECT *
                                   FROM ar_gta_trx_lines_all JGTLA
                                  WHERE JGTLA.GTA_TRX_HEADER_ID =
                                        JGTH.GTA_TRX_HEADER_ID
                                    AND JGTH.Org_Id = JGTLA.Org_Id
                                    AND (JGTLA.Tax_Rate <> 0 OR
                                        JGTLA.Tax_Amount <> 0)))))
  WHERE invoice_type IS NULL
    AND JGTH.ORG_ID = p_org_id;
  COMMIT;

  /* commented by Allen Yang 26-Aug-2009 for bug 8839141.
  -- log for invoice type populating exceptions
  fnd_message.set_name('AR', 'AR_GTA_INV_TYPE_EXC_REASON');
  fnd_file.put_line(fnd_file.OUTPUT, fnd_message.get());
  */

  -- added by Allen Yang 26-Aug-2009 for bug 8839141.
  OPEN c_cm_inv_type_different;
  FETCH c_cm_inv_type_different INTO l_gta_trx_number, l_source;
  IF c_cm_inv_type_different%FOUND
  THEN
    fnd_message.set_name('AR', 'AR_GTA_UPG_DIF_INVOICE_TYPE');
    fnd_file.put_line(fnd_file.OUTPUT, fnd_message.get());
  END IF; --c_cm_inv_type_different%FOUND
  WHILE c_cm_inv_type_different%FOUND
  LOOP
    fnd_file.put_line(fnd_file.OUTPUT, l_gta_trx_number||'('||l_source||')');
    FETCH c_cm_inv_type_different INTO l_gta_trx_number, l_source;
  END LOOP; --c_cm_inv_type_different%FOUND
  CLOSE c_cm_inv_type_different;
  -- end added by Allen Yang

  OPEN c_inv_trx_type_no_inv_type;
  FETCH c_inv_trx_type_no_inv_type INTO l_gta_trx_number, l_source;
  IF c_inv_trx_type_no_inv_type%FOUND
  THEN
    -- modified by Allen Yang 26-Aug-2009 for bug 8839141
    --fnd_message.set_name('AR', 'AR_GTA_TRX_TYPE_NOT_ASS');
    fnd_message.set_name('AR', 'AR_GTA_UPG_NO_INVOICE_TYPE');
    -- end modified by Allen Yang
    fnd_file.put_line(fnd_file.OUTPUT, fnd_message.get());
  END IF; --c_inv_trx_type_no_inv_type%FOUND
  WHILE c_inv_trx_type_no_inv_type%FOUND
  LOOP
    fnd_file.put_line(fnd_file.OUTPUT, l_gta_trx_number||'('||l_source||')');
    FETCH c_inv_trx_type_no_inv_type INTO l_gta_trx_number, l_source;
  END LOOP; --c_inv_trx_type_no_inv_type%FOUND
  CLOSE c_inv_trx_type_no_inv_type;

  OPEN c_recycle_tax_amount_not_zero;
  FETCH c_recycle_tax_amount_not_zero INTO l_gta_trx_number, l_source;
  IF c_recycle_tax_amount_not_zero%FOUND
  THEN
    -- modified by Allen Yang 26-Aug-2009 for bug 8839141
    --fnd_message.set_name('AR', 'AR_GTA_REC_TAX_NOT_ZERO');
    fnd_message.set_name('AR', 'AR_GTA_UPG_NOZERO_TAX_R');
    -- end modified by Allen Yang
    fnd_file.put_line(fnd_file.OUTPUT, fnd_message.get());
  END IF; --c_recycle_tax_amount_not_zero%FOUND
  WHILE c_recycle_tax_amount_not_zero%FOUND
  LOOP
    fnd_file.put_line(fnd_file.OUTPUT, l_gta_trx_number||'('||l_source||')');
    FETCH c_recycle_tax_amount_not_zero INTO l_gta_trx_number, l_source;
  END LOOP; --c_recycle_tax_amount_not_zero%FOUND
  CLOSE c_recycle_tax_amount_not_zero;

  /* commented by Allen Yang 26-Aug-2009 for bug 8839141.
  OPEN c_cm_inv_type_different;
  FETCH c_cm_inv_type_different INTO l_gta_trx_number, l_source;
  IF c_cm_inv_type_different%FOUND
  THEN
    fnd_message.set_name('AR', 'AR_GTA_CM_INV_TYPE_DIFF');
    fnd_file.put_line(fnd_file.OUTPUT, fnd_message.get());
  END IF; --c_cm_inv_type_different%FOUND
  WHILE c_cm_inv_type_different%FOUND
  LOOP
    fnd_file.put_line(fnd_file.OUTPUT, l_gta_trx_number||'('||l_source||')');
    FETCH c_cm_inv_type_different INTO l_gta_trx_number, l_source;
  END LOOP; --c_cm_inv_type_different%FOUND
  CLOSE c_cm_inv_type_different;
  */

  --logging for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || l_procedure_name || '.end'
                  ,'end procedure');
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_procedure_name || '. OTHER_EXCEPTION '
                    , Sqlcode||Sqlerrm);
    END IF;
    RAISE;

END Populate_Invoice_Type_Header;

END AR_GTA_TRX_UTIL;

/
