--------------------------------------------------------
--  DDL for Package Body AR_GTA_CONSOLIDATE_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_GTA_CONSOLIDATE_PROC" AS
--$Header: ARGRCONB.pls 120.0.12010000.6 2010/05/10 05:44:51 yaozhan noship $

--+===========================================================================
--|                    Copyright (c) 2002 Oracle Corporation
--|                       Redwood Shores, California, USA
--|                            All rights reserved.
--+===========================================================================
--|
--|  FILENAME :
--|                        ARRCONB.pls
--|
--|  DESCRIPTION:
--|                        This procedure merge GTA invoice into
--|                        Consolidatation Invoices.
--|IMPORTANT NOTES---In this package, consolidation invoice indicate to invocice
--|                  generated from consolidation program, and consolidated
--|                  invoice indicate to invoices which is consolidated.
--|
--|  HISTORY:
--|                         Created : 13-JUN-2009 : Yao Zhang
--|            04-Aug-2009 Yao Zhang Fix bug#8756943 TRANSFER AND CONSOLIDATION
--|                                  LOGIC FOR CREDIT MEMO WITH DISCOUNT LINES .
--|            08-Aug-2009:  Yao Zhang fix bug#8770356 Modified
--|            19-Aug-2009:  Yao Zhang fix bug#8785665 Modify output report of consolidation program
--|            24-Aug-2009:  Yao Zhang fix bug#8830170 support consolidation invoice lines with
--|                                                    amount=0 and quantity =0
--|            01-Sep-2009:  Yao Zhang fix bug#8858364 Modified TST1212.DST2:SAME PRICE AND DIFFERENT
--|                                                    DISCOUNT CONSOLIDATE ISSUE
--|            09-Sep-2009: Yao Zhang fix bug#8882568 CONCURRENCY CONTROL FOR EXPORT AND CONSOLIDATION
--|                                                   PROGRAM
--|            17-Sep-2009: Yao Zhang fix bug#8915838 CONSOLIDATED INVOICE LINE NUMBER EXCEED THE LIMITS
--|            17-Sep-2009: Yao Zhang fix bug#8919922 WRONG WARNING MESSAGE APPEARS FOR CONSOLIDATION
--|            21-Sep-2009: Yao Zhang Fix bug#8920239 TRANSFER RECYCLE INVOICE WITH DISCOUNT WITH ERROR
--|            22-Sep-2009: Yao Zhang fix bug#8930324 SELECT SALE LIST ENABLE BUT NOT CONSOLIDATE SUCCESSFULLY
--|            27-Sep-2009: Yao Zhang fix bug#8946609 CONSOLIDATION COUNT LINE NUMBER ISSUE
--|            22-Oct-2009: Yao Zhang fix bug#9018341 CONSOLIDATION CUNCURRENT FINISH WITH ERROR IN KOREAN
--|                                                   SESSION.
--|            17-Mar-2010: Yao Zhang fix bug#9362043 DISMATCHED AMOUNT OF CREDIT MEMO CONSOLIDATION IN GTA.
--|            10-May-2010: Yao Zhang fix bug#9655856 INVOICE WITH DIFFERENT TAX RATE SHOULD NOT BE CONSOLIDATED
--|                                                   INTO ONE INVOICE
--+===========================================================================


--==========================================================================
  --  PROCEDURE NAME:
  --             Generate_XML_output
  --
  --  DESCRIPTION:
  --             This procedure generate XML string as concurrent output
  --             from temporary table
  --
  --  PARAMETERS:
  --             In: p_conc_parameters  AR_GTA_TRX_UTIL.consolparas_rec_type
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --             30-Jun-2009: Yao Zhang  Created.
  --             19-Aug-2009: Yao Zhang Modified for bug#8785665
--===========================================================================

PROCEDURE Generate_XML_Output
(p_consolidation_paras IN AR_GTA_TRX_UTIL.consolparas_rec_type
)
IS
l_procedure_name VARCHAR2(30):='Generate_XML_output';
l_report_XML           XMLType;
l_parameter            XMLType;
l_success              XMLType;
l_warning              XMLType;
l_failed               XMLType;
l_Reportfailed         XMLType;
l_failedwithparameters XMLType;
l_summary              XMLType;
l_sameprisamedis       VARCHAR2(1);
l_samepridiffdis       VARCHAR2(1);
l_diffpri              VARCHAR2(1);
l_saleslistflag        VARCHAR2(1);
l_consolidation_id     NUMBER;
l_succ_unm             NUMBER;
l_warn_unm             NUMBER;
l_error_unm            NUMBER;
l_org_id               NUMBER(15);
l_org_name             hr_all_organization_units_tl.NAME%TYPE;

BEGIN
IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||'.'|| l_procedure_name
                  ,'Begin Procedure. ');
  END IF;
  --parameters
  l_sameprisamedis   := p_consolidation_paras.same_pri_same_dis;
  l_samepridiffdis   := p_consolidation_paras.same_pri_diff_dis;
  l_diffpri          := p_consolidation_paras.diff_pri;
  l_saleslistflag    := p_consolidation_paras.sales_list_flag;
  l_consolidation_id := p_consolidation_paras.consolidation_id;
  l_org_id           := p_consolidation_paras.org_id;

  BEGIN
  SELECT otl.NAME
    INTO l_org_name
    FROM hr_all_organization_units o, hr_all_organization_units_tl otl
   WHERE o.organization_id = otl.organization_id
     AND otl.LANGUAGE = userenv('LANG')
     AND o.organization_id = l_org_id;
  EXCEPTION
   WHEN no_data_found THEN
     IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.String(FND_LOG.LEVEL_UNEXPECTED,
                     G_MODULE_PREFIX || l_procedure_name,
                     'Wxception when retrive operating unit name' || SQLCODE || SQLERRM);
     END IF;
     RAISE;
   END;


  SELECT COUNT(*)
  INTO l_succ_unm
  FROM AR_gta_consol_temp
  WHERE status= 'S';

  SELECT COUNT(*)
  INTO l_warn_unm
  FROM AR_gta_consol_temp
  WHERE status= 'W';

  SELECT COUNT(*)
  INTO l_error_unm
  FROM AR_gta_consol_temp
  WHERE status= 'E';

  -- generate validate xml string
  SELECT xmlelement("ReportFailed", 'N') INTO l_Reportfailed FROM dual;
  SELECT xmlelement("FailedWithParameters", 'N')
    INTO l_failedwithparameters
    FROM dual;

  -- generate xmlsring of parameters of transfer program
  SELECT xmlelement("Parameters",
                    xmlforest(l_sameprisamedis AS "SamePriSameDis",
                              l_samepridiffdis AS "SamePriDiffDis",
                              l_diffpri AS "DiffPri",
                              l_saleslistflag AS "SalesList",
                              l_consolidation_id AS "ConsolidationId",
                              l_org_name AS "OrgName"
                             ))
    INTO l_parameter
    FROM dual;

  SELECT xmlelement("Summary",
                    xmlforest(l_succ_unm  AS "NumOfSucc",
                              l_warn_unm  AS "NumOfWarning",
                              l_error_unm AS "NumOfFailed"))
    INTO l_summary
    FROM dual;


  -- generate the xmltype for success inv
    SELECT xmlagg(xmlelement("ConsolidationInv",
                             xmlforest(jgct.seq                      AS "SEQ",
                                       jgct.consolidation_inv_number AS "ConsolidationInvNum",
                                       jgct.customer_name            AS "CustomerName",
                                       jgct.tp_tax_reg_num           AS "TPTaxRegNum",
                                       jgct.customer_address_phone   AS "CustomerAddrPhone",
                                       jgct.bank_account_name        AS "BankName",
                                       jgct.bank_account_num         AS "BankAccountNumber",
                                       lk.meaning                    AS "InvoiceType",
                                       jgct.amount                   AS "Amount",
                                       jgct.failed_reason            AS "FailedReason",
                                       (SELECT xmlagg(xmlelement("ConsolidatedInv",
                                                                 xmlforest(jgcit.consolidated_inv_number AS "Consolidated",
                                                                           jgcit.gl_period               AS "GLPeriod",
                                                                           jgcit.ra_trx_num              AS "RATrxNum",
                                                                           jgcit.ra_trx_type             AS "RATrxType",
                                                                           jgcit.amount                  AS "Amount")))
                                                   FROM AR_gta_consol_invs_temp jgcit
                                                   WHERE jgct.seq=jgcit.seq)
                                                                     AS "ConsolidatedInvs")))

      INTO l_success
      FROM AR_gta_consol_temp jgct, fnd_lookup_values_vl lk
     WHERE status = 'S'
       AND jgct.invoice_type = lk.lookup_code
       AND lk.lookup_type = 'AR_GTA_INVOICE_TYPE';
  --ORDER BY jgct.seq;
    -- generate the xmltype for warning inv
    SELECT xmlagg(xmlelement("ConsolidationInv",
                                        xmlforest(jgct.SEQ                       AS "SEQ"
                                                  ,jgct.consolidation_inv_number AS "ConsolidationInvNum"
                                                  ,jgct.customer_name            AS "CustomerName"
                                                  ,jgct.tp_tax_reg_num        AS "TPTaxRegNum"
                                                  ,jgct.customer_address_phone   AS "CustomerAddrPhone"
                                                  ,jgct.bank_account_name        AS "BankName"
                                                  ,jgct.bank_account_num         AS "BankAccountNumber"
                                                  ,lk.meaning                    AS "InvoiceType"
                                                  ,jgct.amount                   AS "Amount"
                                                  ,jgct.failed_reason            AS "FailedReason"
                                                  ,(SELECT xmlagg(xmlelement("ConsolidatedInv",
                                                                     xmlforest(jgcit.consolidated_inv_number AS "Consolidated"
                                                                              ,jgcit.gl_period               AS "GLPeriod"
                                                                              ,jgcit.ra_trx_num              AS "RATrxNum"
                                                                              ,jgcit.ra_trx_type             AS "RATrxType"
                                                                              ,jgcit.amount                  AS "Amount")))
                                                   FROM AR_gta_consol_invs_temp jgcit
                                                   WHERE jgct.seq=jgcit.seq)
                                                                                 AS "ConsolidatedInvs"
                       )))

      INTO l_warning
      FROM AR_gta_consol_temp jgct, fnd_lookup_values_vl lk
     WHERE status = 'W'
       AND jgct.invoice_type = lk.lookup_code
       AND lk.lookup_type = 'AR_GTA_INVOICE_TYPE';
  --ORDER BY jgct.seq;
      -- generate the xmltype for error inv
    SELECT xmlagg(xmlelement("ConsolidationInv",
                                        xmlforest(jgct.SEQ                       AS "SEQ"
                                                  ,jgct.consolidation_inv_number AS "ConsolidationInvNum"
                                                  ,jgct.customer_name            AS "CustomerName"
                                                  ,jgct.tp_tax_reg_num        AS "TPTaxRegNum"
                                                  ,jgct.customer_address_phone   AS "CustomerAddrPhone"
                                                  ,jgct.bank_account_name        AS "BankName"
                                                  ,jgct.bank_account_num         AS "BankAccountNumber"
                                                  ,lk.meaning              AS "InvoiceType"
                                                  ,jgct.amount                   AS "Amount"
                                                  ,jgct.failed_reason            AS "FailedReason"
                                                  ,(SELECT xmlagg(xmlelement("ConsolidatedInv",
                                                                     xmlforest(jgcit.consolidated_inv_number AS "Consolidated"
                                                                              ,jgcit.gl_period               AS "GLPeriod"
                                                                              ,jgcit.ra_trx_num              AS "RATrxNum"
                                                                              ,jgcit.ra_trx_type             AS "RATrxType"
                                                                              ,jgcit.amount                  AS "Amount")))
                                                   FROM AR_gta_consol_invs_temp jgcit
                                                   WHERE jgct.seq=jgcit.seq)
                                                                                 AS "ConsolidatedInvs"
                       )))

      INTO l_failed
      FROM AR_gta_consol_temp jgct, fnd_lookup_values_vl lk
     WHERE status = 'E'
       AND jgct.invoice_type = lk.lookup_code
       AND lk.lookup_type = 'AR_GTA_INVOICE_TYPE';
  --ORDER BY jgct.seq;


  --generate the final report
  SELECT xmlelement("ConsolidationReport",
                    xmlforest(l_reportfailed AS "ReportFailed",
                              l_failedwithparameters AS
                              "FailedWithParameters",
                              ar_gta_trx_util.to_xsd_date_string(SYSDATE) AS
                              "ReqDate",
                              l_parameter AS "Parameters",
                              l_summary AS "Summary",
                              l_success AS "SuccessInvs",
                              l_warning AS "WarningInvs",
                              l_failed AS "FailedInvs"
                              ))
    INTO l_report_xml
    FROM dual;

    -- concurrent output
    AR_GTA_TRX_UTIL.output_conc(l_report_XML.Getclobval);

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      AR_GTA_TRX_UTIL.debug_output_conc(l_report_XML.Getclobval);
    END IF;


  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||'.'|| l_procedure_name
                  ,'End Procedure. ');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.String(FND_LOG.LEVEL_UNEXPECTED,
                       G_MODULE_PREFIX || l_procedure_name ||
                       '. OTHER_EXCEPTION ',
                       'Unknown error' || SQLCODE || SQLERRM);

      END IF;
  RAISE;
END Generate_XML_output;

--=============================================================================
-- PROCEDURE NAME:
--                create_consol_inv
-- TYPE:
--                PUBLIC
--
-- DESCRIPTION: This procedure is used to Consolidate GTA invoices
--
--
-- PARAMETERS:
-- IN           p_consolidation_paras   AR_GTA_TRX_UTIL.consolparas_rec_type
--
--
-- HISTORY:
--                 30-Jun-2009 : Yao Zhang Create
--                 04-Aug-2009:  Yao Zhang Fix bug#8756943 Modified
--                 08-Aug-2009:  Yao Zhang fix bug#8770356 Modified
--                 24-Aug-2009:  Yao Zhang fix bug#8830170 Modified
--                 01-Sep-2009:  Yao Zhang fix bug#8858364 Modified
--                 09-Sep-2009:  Yao Zhang fix bug#8882568 Modified
--                 17-Sep-2009:  Yao Zhang fix bug#8915838 Modified
--                 17-Sep-2009:  Yao Zhang fix bug#8919922 Modified
--                 21-Sep-2009:  Yao Zhang fix bug#8920239 Modified
--                 22-Sep-2009:  Yao Zhang fix bug#8930324 Modified
--                 27-Sep-2009:  Yao Zhang fix bug#8946609 Modified
--                 22-Oct-2009:  Yao Zhang fix bug#9018341 Modified
--                 17-Mar-2010:  Yao Zhang fix bug#9362043 Modified
--                 10-May-2010:  Yao Zhang fix bug#9655856 Modified
--=============================================================================
PROCEDURE Create_Consol_Inv
(p_consolidation_paras IN AR_GTA_TRX_UTIL.consolparas_rec_type
)
IS
l_procedure_name                VARCHAR2(30):='Create_Consol_Inv';
l_consolidation_id              NUMBER;
l_same_pri_same_dis             VARCHAR2(1);
l_same_pri_diff_dis	            VARCHAR2(1);
l_diff_pri                      VARCHAR2(1);
l_sales_list_flag               VARCHAR2(1);
l_org_id                   NUMBER(15); --Yao Zhang add for bug#8770356

l_csldted_invs             ar_gta_trx_util.trx_tbl_type;
l_csldted_inv              ar_gta_trx_util.trx_rec_type;
l_csldted_inv_lines        ar_gta_trx_util.trx_line_tbl_type:=ar_gta_trx_util.trx_line_tbl_type();
l_csldted_inv_line         ar_gta_trx_util.trx_line_rec_type;
l_csldted_invs_index       NUMBER;
l_csldted_inv_lines_index  NUMBER;


l_csldtion_inv             ar_gta_trx_util.trx_rec_type;
l_csldtion_inv_lines       ar_gta_trx_util.trx_line_tbl_type:=ar_gta_trx_util.trx_line_tbl_type();
l_csldtion_inv_line        ar_gta_trx_util.trx_line_rec_type;
l_csldtion_inv_lines_index NUMBER;
l_csldtion_line_count      NUMBER;
l_csldtion_discount_line_num NUMBER;
l_csldtion_line_num          NUMBER;--Yao add for bug#8830170

l_gta_trx_header_id             ar_gta_trx_headers_all.gta_trx_header_id%TYPE;
l_bill_to_customer_name         ar_gta_trx_headers_all.bill_to_customer_name%TYPE;
l_tp_tax_registration_number    ar_gta_trx_headers_all.tp_tax_registration_number%TYPE;
l_fp_tax_registration_number    ar_gta_trx_headers_all.fp_tax_registration_number%TYPE;
l_customer_address_phone        ar_gta_trx_headers_all.customer_address_phone%TYPE;
l_bank_account_name             ar_gta_trx_headers_all.bank_account_name%TYPE;
l_bank_account_number           ar_gta_trx_headers_all.bank_account_number%TYPE;
l_invoice_type                  ar_gta_trx_headers_all.invoice_type%TYPE;
l_ra_trx_type                   Varchar2(20);
l_sum_amount                    NUMBER;
l_max_amount                    NUMBER;
l_max_line                      NUMBER;

l_consol_sign_flag              NUMBER;
l_csldtion_line_sign_flag       NUMBER;
l_result_flag                   VARCHAR2(1);

l_amount                        NUMBER;
--l_error_string                Varchar2(200);--Yao delete for bug#9018341
l_error_string                  FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;--Yao add for bug#9018341
l_consolidation_gl_period       Varchar2(20);
l_consolidation_gl_date         DATE;
l_csldted_inv_status_flag       VARCHAR2(1);--yao add for bug#8882568
l_gta_consol_temp_seq        NUMBER;
l_tax_rate                      ar_gta_trx_lines_all.tax_rate%TYPE;--Yao add for bug 9655856
CURSOR c_consolidation_groups(p_consolidation_id IN NUMBER)
IS
  SELECT jgth.fp_tax_registration_number,
         jgth.bill_to_customer_name,
         jgth.tp_tax_registration_number,
         jgth.customer_address_phone,
         jgth.bank_account_name,
         jgth.bank_account_number,
         jgth.invoice_type,
         jgtl.tax_rate --Yao add for bug9655856
    FROM ar_gta_trx_headers_all jgth, ar_gta_trx_lines_all jgtl
   WHERE jgth.consolidation_id = p_consolidation_id
   --Yao add for bug 9655856
     AND jgth.gta_trx_header_id = jgtl.gta_trx_header_id
     AND jgth.org_id = jgtl.org_id
    --Yao add end for bug 9655856
   GROUP BY jgth.fp_tax_registration_number,
            jgth.bill_to_customer_name,
            jgth.tp_tax_registration_number,
            jgth.customer_address_phone,
            jgth.bank_account_name,
            jgth.bank_account_number,
            jgth.invoice_type,
            jgtl.tax_rate; --Yao add for bug9655856
CURSOR c_consolidated_invs(p_consolidation_id           IN NUMBER,
                           p_fp_tax_registration_number IN VARCHAR2,
                           p_bill_to_customer_name      IN VARCHAR2,
                           p_tp_tax_registration_number IN VARCHAR2,
                           p_customer_address_phone     IN VARCHAR2,
                           p_bank_account_name          IN VARCHAR2,
                           p_bank_account_number        IN VARCHAR2,
                           p_invoice_type               IN VARCHAR2,
                           p_tax_rate                   IN NUMBER)--Yao add for bug 9655856
IS
  SELECT jgth.gta_trx_header_id
    FROM ar_gta_trx_headers_all jgth
   WHERE jgth.consolidation_id = p_consolidation_id
     AND jgth.fp_tax_registration_number=p_fp_tax_registration_number
     AND jgth.bill_to_customer_name = p_bill_to_customer_name
     AND (jgth.tp_tax_registration_number = p_tp_tax_registration_number OR
             decode(p_tp_tax_registration_number,
                               NULL,
                               jgth.tp_tax_registration_number,
                               p_tp_tax_registration_number) IS NULL)
     AND (jgth.customer_address_phone = p_customer_address_phone OR
             decode(p_customer_address_phone,
                               NULL,
                               jgth.customer_address_phone,
                               p_customer_address_phone) IS NULL)
     AND (jgth.bank_account_name = p_bank_account_name OR
             decode(p_bank_account_name,
                               NULL,
                              jgth.bank_account_name,
                               p_bank_account_name) IS NULL)
     AND (jgth.bank_account_number = p_bank_account_number OR
             decode(p_bank_account_number,
                               NULL,
                               jgth.bank_account_number,
                               p_bank_account_number) IS NULL)
     AND jgth.invoice_type = p_invoice_type
     --Yao add for bug 9655856

     AND jgth.gta_trx_header_id = (SELECT jgtl.gta_trx_header_id
                                     FROM ar_gta_trx_lines_all jgtl
                                    WHERE jgtl.tax_rate=p_tax_rate
                                     AND jgth.gta_trx_header_id = jgtl.gta_trx_header_id
                                     AND jgth.org_id = jgtl.org_id
                                      GROUP BY jgtl.gta_trx_header_id)
     --Yao add end for bug9655856
     ORDER BY jgth.gta_trx_number;
BEGIN
  fnd_file.PUT_LINE(fnd_file.LOG,'Begin Procedure.'||l_procedure_name);
  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||'.'|| l_procedure_name
                  ,'Begin Procedure. ');
  END IF;
  --get procedure parameters
  l_consolidation_id:=p_consolidation_paras.consolidation_id;
  l_same_pri_same_dis:=p_consolidation_paras.same_pri_same_dis;
  l_same_pri_diff_dis:=p_consolidation_paras.same_pri_diff_dis;
  l_diff_pri :=p_consolidation_paras.diff_pri ;
  l_sales_list_flag :=p_consolidation_paras.sales_list_flag ;
  l_org_id            :=p_consolidation_paras.org_id;--Yao Zhang add for bug#8770356

   OPEN c_consolidation_groups(l_consolidation_id);
   LOOP
   FETCH c_consolidation_groups INTO
   l_fp_tax_registration_number,
   l_bill_to_customer_name,
   l_tp_tax_registration_number,
   l_customer_address_phone,
   l_bank_account_name,
   l_bank_account_number,
   l_invoice_type,
   l_tax_rate;
   EXIT WHEN c_consolidation_groups%NOTFOUND;

   BEGIN
     --get max amount and max num of line
     SELECT jgtla.max_amount, jgtla.max_num_of_line
      INTO l_max_amount, l_max_line
      FROM ar_gta_tax_limits_all jgtla
      WHERE jgtla.fp_tax_registration_number =
            l_fp_tax_registration_number
        AND jgtla.invoice_type = l_invoice_type
        AND jgtla.org_id = l_org_id;--Yao Zhang add for bug#8770356
    EXCEPTION
      WHEN no_data_found THEN
         --AR_GTA_SYS_CONFIG_MISSING
           fnd_message.set_name('AR', 'AR_GTA_SYS_CONFIG_MISSING');
           l_error_string := fnd_message.get();
         -- output error
           fnd_file.put_line(fnd_file.output, '<?xml version="1.0" encoding="UTF-8" ?>
           <ConsolidationReport>
                  <ReportFailed>Y</ReportFailed>
                 <ReportFailedMsg>'||l_error_string ||'</ReportFailedMsg>
           <COnsolidationReport>');

	       IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                                  ,G_MODULE_PREFIX || l_procedure_name
                                  ,'no data found for max_amt and mx_num_line'
                                 );
         END IF;
         RAISE;
        RETURN;
    END;
    --init
    l_sum_amount:=0;
    l_csldted_invs:= ar_gta_trx_util.trx_tbl_type();
    l_csldted_inv:=NULL;
    l_result_flag:=NULL;
    l_error_string:=NULL;
    l_csldted_inv_status_flag:=NULL;--yao add for bug#8882568
    --Yao add for bug#8919922
    l_consol_sign_flag:=NULL;
    l_consolidation_gl_period:=NULL;
    l_consolidation_gl_date:=NULL;
    l_csldtion_inv:=NULL;
    l_csldtion_inv_line:=NULL;
   -- l_csldtion_line_count:=0;
    l_csldtion_inv.trx_lines:=ar_gta_trx_util.trx_line_tbl_type();
    --Yao add end for bug#8919922

    OPEN c_consolidated_invs(l_consolidation_id
                            ,l_fp_tax_registration_number
                            ,l_bill_to_customer_name
                            ,l_tp_tax_registration_number
                            ,l_customer_address_phone
                            ,l_bank_account_name
                            ,l_bank_account_number
                            ,l_invoice_type
                            ,l_tax_rate);--Yao add for bug 9655856
    LOOP
    FETCH c_consolidated_invs
    INTO l_gta_trx_header_id;
    EXIT WHEN c_consolidated_invs%NOTFOUND;
      AR_GTA_TRX_UTIL.get_trx(p_trx_header_id => l_gta_trx_header_id
                              ,x_trx_rec       => l_csldted_inv
                              );
      l_csldted_invs.EXTEND;
      l_csldted_invs(l_csldted_invs.COUNT):=l_csldted_inv;
      l_amount:=ar_gta_trx_util.get_gtainvoice_amount(l_gta_trx_header_id);
      l_sum_amount:=l_sum_amount+l_amount;
      --yao add for bug#8882568 check invoice status
      IF l_csldted_inv.trx_header.status<>'DRAFT'
      THEN
      l_csldted_inv_status_flag:='1';
      END IF;
     --check if there are both positive and negative invoice in the group
      IF l_consol_sign_flag IS NULL
      THEN
        IF l_amount>0 THEN
           l_consol_sign_flag:=1;
        ELSIF l_amount<0 THEN
           l_consol_sign_flag:=-1;
        END IF;
      ELSIF (l_amount<0 AND l_consol_sign_flag=1) OR (l_amount>0 AND l_consol_sign_flag=-1)
      THEN
      l_consol_sign_flag:=0;
      END IF;

      --check if there are invoices with different gl_period
      IF l_consolidation_gl_period IS NULL
      THEN
      l_consolidation_gl_period:=l_csldted_inv.trx_header.RA_GL_PERIOD;
      l_consolidation_gl_date:= l_csldted_inv.trx_header.ra_gl_date;
      ELSIF (l_consolidation_gl_date<> l_csldted_inv.trx_header.ra_gl_date)
      THEN
        IF(l_consolidation_gl_period<>l_csldted_inv.trx_header.RA_GL_PERIOD)
        THEN
          l_result_flag:='W';
          fnd_message.set_name('AR'
                          ,'AR_GTA_CON_DIF_PERIOD');
          l_error_string:=fnd_message.get();
        END IF;
        --consolidation_gl_date should be the latest date of consolidated invoice
        --consolidation_gl_period should be the latest gl_period of consolidated invoice
        IF(l_consolidation_gl_date< l_csldted_inv.trx_header.ra_gl_date)
        THEN
          l_consolidation_gl_date:= l_csldted_inv.trx_header.ra_gl_date;
          l_consolidation_gl_period:=l_csldted_inv.trx_header.RA_GL_PERIOD;
        END IF;
      END IF;
    END LOOP;
    CLOSE c_consolidated_invs;

   --yao add begin for bug#8882568
    IF l_csldted_inv_status_flag='1'
    THEN
     l_result_flag:='E';
     fnd_message.set_name('AR'
                          ,'AR_GTA_INV_STATUS_INVALID');
      l_error_string:=fnd_message.get();
   --yao add end for bug#8882568
    ELSIF l_csldted_invs.COUNT<=1
    THEN
      l_result_flag:='E';
      fnd_message.set_name('AR'
                          ,'AR_GTA_FAIL_ONLY_ONE_INV_C');
      l_error_string:=fnd_message.get();
    ELSIF  ABS(l_sum_amount)>l_max_amount
    THEN
      l_result_flag:='E';
      fnd_message.set_name('AR'
                          ,'AR_GTA_FAIL_EXCEED_LIMMITS');
      l_error_string:=fnd_message.get();
    ELSIF(l_consol_sign_flag=0 AND l_sum_amount<=0)
    THEN
      l_result_flag:='E';
      fnd_message.set_name('AR'
                          ,'AR_GTA_CON_FAIL_NEGTIVE');
      l_error_string:=fnd_message.get();
    ELSE--ABS(l_sum_amount)>l_max_amount OR (l_consol_sign_flag=0 AND l_sum_amount<0) and
          --l_csldted_invs.COUNT<=1 create consolidation invoice
      l_csldted_invs_index:=l_csldted_invs.FIRST;
      WHILE l_csldted_invs_index IS NOT NULL
      LOOP
      --init
      l_csldted_inv:=l_csldted_invs(l_csldted_invs_index);
      l_csldted_inv_lines:=l_csldted_inv.trx_lines;
      l_csldted_inv_lines_index:=l_csldted_inv_lines.FIRST;
        WHILE l_csldted_inv_lines_index IS NOT NULL
        LOOP
           --Yao comment begin for bug#8946609
          /*IF (l_csldtion_line_count+l_csldtion_discount_line_num)<=l_max_line OR l_sales_list_flag='Y'
          THEN*/
           --Yao comment end for bug#8946609
            l_csldted_inv_line:=l_csldted_inv_lines(l_csldted_inv_lines_index);
            l_csldtion_inv_lines_index:=l_csldtion_inv.trx_lines.FIRST;
            WHILE l_csldtion_inv_lines_index IS NOT NULL
            LOOP
              l_csldtion_inv_line:=l_csldtion_inv.trx_lines(l_csldtion_inv_lines_index);
              --trx lines with same item description, tax rate, uom, item model and tax denomination can be merged into one line.
              IF     l_csldted_inv_line.INVENTORY_ITEM_ID= l_csldtion_inv_line.INVENTORY_ITEM_ID
                 AND l_csldted_inv_line.item_number=l_csldtion_inv_line.item_number
                 AND l_csldted_inv_line.item_description=l_csldtion_inv_line.item_description
                 AND l_csldted_inv_line.tax_rate=l_csldtion_inv_line.tax_rate
                 AND (l_csldted_inv_line.uom=l_csldtion_inv_line.uom OR (l_csldted_inv_line.uom IS NULL AND l_csldtion_inv_line.uom IS NULL))
                 AND l_csldted_inv_line.item_model =l_csldtion_inv_line.item_model
                 AND l_csldted_inv_line.item_tax_denomination =l_csldtion_inv_line.item_tax_denomination
              THEN
                IF (l_diff_pri='Y'OR (l_csldted_inv_line.unit_price=l_csldtion_inv_line.unit_price
                                  AND l_same_pri_diff_dis='Y')
                                  OR (l_csldted_inv_line.unit_price=l_csldtion_inv_line.unit_price
                                  AND nvl(l_csldted_inv_line.discount_rate,0)=nvl(l_csldtion_inv_line.discount_rate,0)
                                  AND l_same_pri_same_dis='Y'))
                THEN
                  --l_csldtion_inv.trx_lines(l_csldtion_inv_lines_index).quantity            :=l_csldtion_inv_line.quantity+l_csldted_inv_line.quantity;
                  --Yao changed for bug#9362043
                  l_csldtion_inv.trx_lines(l_csldtion_inv_lines_index).quantity            :=nvl(l_csldtion_inv_line.quantity,0)+nvl(l_csldted_inv_line.quantity,0);
                  l_csldtion_inv.trx_lines(l_csldtion_inv_lines_index).amount              :=l_csldtion_inv_line.amount+l_csldted_inv_line.amount;
                  l_csldtion_inv.trx_lines(l_csldtion_inv_lines_index).discount_amount     :=nvl(l_csldtion_inv_line.discount_amount,0)+nvl(l_csldted_inv_line.discount_amount,0);
                  l_csldtion_inv.trx_lines(l_csldtion_inv_lines_index).tax_amount          :=l_csldtion_inv_line.tax_amount+l_csldted_inv_line.tax_amount;
                  l_csldtion_inv.trx_lines(l_csldtion_inv_lines_index).discount_tax_amount :=nvl(l_csldtion_inv_line.discount_tax_amount,0)+nvl(l_csldted_inv_line.discount_tax_amount,0);
                  --yao comment for bug#8830170 begin
                 /* l_csldtion_inv.trx_lines(l_csldtion_inv_lines_index).unit_price          :=round((l_csldtion_inv.trx_lines(l_csldtion_inv_lines_index).amount
                                                                                            /l_csldtion_inv.trx_lines(l_csldtion_inv_lines_index).quantity),6) ;
                  l_csldtion_inv.trx_lines(l_csldtion_inv_lines_index).discount_rate       :=ABS(round((l_csldtion_inv.trx_lines(l_csldtion_inv_lines_index).discount_amount
                                                                                           /l_csldtion_inv.trx_lines(l_csldtion_inv_lines_index).amount),5));*/
                  --Yao comment for bug#8830170 end

                  --Yao comment begin for bug#8946609
                  --The following code is changed by Yao for bug#8930324
                  /*IF (l_csldted_inv_line.discount_flag='1'
                      AND l_csldtion_inv_line.discount_flag IS NULL
                      AND l_consol_sign_flag<>-1)
                      --Comented for bug#8930324
                      --AND (l_csldtion_line_count+l_csldtion_discount_line_num)<l_max_line OR l_sales_list_flag='Y')--Yao add for bug#8915838
                  THEN
                  --add begin for bug#8930324
                    IF (l_csldtion_line_count+l_csldtion_discount_line_num)<l_max_line OR l_sales_list_flag='Y'
                  THEN
                    --l_csldtion_inv_line.discount_flag:='1';--yao comment for bug8858364
                    --yao add for bug#8858364
                    l_csldtion_inv.trx_lines(l_csldtion_inv_lines_index).discount_flag:='1';
                    l_csldtion_discount_line_num:=l_csldtion_discount_line_num+1;
                    --Yao add for bug#8915838
                    ELSE
                      l_result_flag:='E';
                      fnd_message.set_name('AR'
                          ,'AR_GTA_FAIL_EXCEED_LIMMITS');
                      l_error_string:=fnd_message.get();
                    EXIT;
                    END IF;
                    --add end for bug#8930324
                     --Yao add for bug#8915838 end
                  END IF;/*(l_csldted_inv_line.discount_flag='1'
                      AND l_csldtion_inv_line.discount_flag IS NULL
                      AND l_consol_sign_flag<>-1
                      AND (l_csldtion_line_count+l_csldtion_discount_line_num)<l_max_line)*/
                  --Yao comment end for bug#8946609

                  --Yao add begin for bug#8946609
                  IF l_csldted_inv_line.discount_flag='1'
                  THEN
                  l_csldtion_inv.trx_lines(l_csldtion_inv_lines_index).discount_flag:='1';
                  END IF;
                  --Yao add end for bug#8946609

                  EXIT;--l_csldtion_inv_lines_index
                END IF;/*(p_diff_pri='Y'OR (l_csldtion_line.unit_price=l_csldted_inv_line.unit_price
                                  AND p_same_pri_diff_dis='Y')
                              OR (l_csldtion_line.unit_price=l_csldted_inv_line.unit_price
                                  AND l_csldtion_line.discount_rate=l_csldted_inv_line.discount_rate
                                  AND p_same_pri_diff_dis='Y'))*/
              END IF;-- l_csldtion_line.item_description=l_csldted_inv_line.item_description
              l_csldtion_inv_lines_index:=l_csldtion_inv.trx_lines.NEXT(l_csldtion_inv_lines_index);
            END LOOP;--l_csldtion_inv_lines_index
            --Yao comment begin for bug#8946609
            /*IF (l_result_flag IS NULL OR l_result_flag='W')
               AND l_csldtion_inv_lines_index IS NULL
               AND ((l_csldtion_line_count+l_csldtion_discount_line_num)<l_max_line --Yao add for bug#8915838
               OR l_sales_list_flag='Y') --add for bug#8930324*/
            --Yao comment end for bug#8946609

            IF l_csldtion_inv_lines_index IS NULL--Yao add for bug#8946609
            THEN
            --Yao comment begin for bug#8946609
             /* l_csldtion_line_count                      := l_csldtion_line_count+1;
              IF (l_csldted_inv_line.discount_flag='1'AND l_consol_sign_flag<>-1)
              THEN
               --add begin for bug#8930324
                IF ((l_csldtion_line_count+l_csldtion_discount_line_num)<l_max_line OR l_sales_list_flag='Y')--Yao add for bug#8915838
              THEN
              l_csldtion_discount_line_num:=l_csldtion_discount_line_num+1;
              --Yao add for bug#8915838
                ELSE
              l_result_flag:='E';
                      fnd_message.set_name('AR'
                          ,'AR_GTA_FAIL_EXCEED_LIMMITS');
                      l_error_string:=fnd_message.get();
              EXIT;
               END IF;
                --add end for bug#8930324
              --Yao add for bug#8915838 end
              END IF;/*(l_csldted_inv_line.discount_flag='1'
                AND l_consol_sign_flag<>-1*/
              --Yao comment end for bug#8946609
              l_csldtion_inv_line.org_id                 := l_csldted_inv_line.org_id;
              --l_csldtion_inv_line.line_number            := l_csldtion_line_count;
              l_csldtion_inv_line.inventory_item_id      := l_csldted_inv_line.inventory_item_id;
              l_csldtion_inv_line.item_number            := l_csldted_inv_line.item_number;
              l_csldtion_inv_line.item_description       := l_csldted_inv_line.item_description;
              l_csldtion_inv_line.item_model             := l_csldted_inv_line.item_model;
              l_csldtion_inv_line.item_tax_denomination  := l_csldted_inv_line.item_tax_denomination;
              l_csldtion_inv_line.tax_rate               := l_csldted_inv_line.tax_rate;
              l_csldtion_inv_line.uom                    := l_csldted_inv_line.uom;
              l_csldtion_inv_line.uom_name               := l_csldted_inv_line.uom_name;
              l_csldtion_inv_line.quantity               := l_csldted_inv_line.quantity;
              l_csldtion_inv_line.price_flag             := l_csldted_inv_line.price_flag;
              l_csldtion_inv_line.unit_price             := l_csldted_inv_line.unit_price ;
              l_csldtion_inv_line.amount                 := l_csldted_inv_line.amount;
              l_csldtion_inv_line.tax_amount             := l_csldted_inv_line.tax_amount;
              l_csldtion_inv_line.discount_flag          := l_csldted_inv_line.discount_flag;
              l_csldtion_inv_line.enabled_flag           := l_csldted_inv_line.enabled_flag;
              l_csldtion_inv_line.last_update_date       :=SYSDATE;
              l_csldtion_inv_line.last_updated_by        := fnd_global.LOGIN_ID();
              l_csldtion_inv_line.creation_date          :=SYSDATE;
              l_csldtion_inv_line.created_by             := fnd_global.LOGIN_ID();
              l_csldtion_inv_line.last_update_login      := fnd_global.LOGIN_ID();
              l_csldtion_inv_line.program_id             := fnd_global.CONC_PROGRAM_ID;
              l_csldtion_inv_line.PROGRAM_APPLICATON_ID  := fnd_global.PROG_APPL_ID();
              l_csldtion_inv_line.PROGRAM_UPDATE_DATE    :=SYSDATE;
              l_csldtion_inv_line.request_id             := fnd_global.CONC_REQUEST_ID();
              l_csldtion_inv_line.discount_tax_amount    :=l_csldted_inv_line.discount_tax_amount;
              l_csldtion_inv_line.discount_amount        :=l_csldted_inv_line.discount_amount;
              l_csldtion_inv_line.discount_rate          :=l_csldted_inv_line.discount_rate;
              l_csldtion_inv.trx_lines.EXTEND;
              l_csldtion_inv.trx_lines(l_csldtion_inv.trx_lines.COUNT)  := l_csldtion_inv_line;
             --Yao comment begin for bug#8946609
             --Yao add for bug#8915838 begin
            /*ELSIF l_result_flag='E'
               OR (l_csldtion_inv_lines_index IS NULL
                   AND (l_csldtion_line_count+l_csldtion_discount_line_num)=l_max_line
                   AND l_sales_list_flag='N')
            THEN
              l_result_flag:='E';
              fnd_message.set_name('AR'
                                ,'AR_GTA_FAIL_EXCEED_LIMMITS');
              l_error_string:=fnd_message.get();
               --Yao add for bug#8915838 end
            EXIT;--l_consol_inv_lines_index*/
            --Yao comment end for bug#8946609

            END IF;--l_csldtion_inv_lines_index IS NULL AND (l_csldtion_line_count+l_csldtion_discount_line_num)<l_max_line
          --Yao comment begin for bug#8946609
          /*ELSE--(l_csldted_line_count<l_max_line)OR p_sales_list_flag='Y';
            l_result_flag:='E';
            fnd_message.set_name('AR'
                                ,'AR_GTA_FAIL_EXCEED_LIMMITS');
            l_error_string:=fnd_message.get();
            EXIT;--l_consol_inv_lines_index
          END IF;--(l_csldted_line_count<l_max_line)OR p_sales_list_flag='Y';*/
          --Yao comment end for bug#8946609
          l_csldted_inv_lines_index:=l_csldted_inv_lines.NEXT(l_csldted_inv_lines_index);
        END LOOP;--l_consol_inv_lines_index
     --Yao comment begin for bug#8946609
     /* IF l_result_flag='E'
      THEN
      EXIT;--l_csldted_invs_index
      END IF;--l_result_flag:='E'*/
      --Yao comment end for bug#8946609
      l_csldted_invs_index:=l_csldted_invs.NEXT(l_csldted_invs_index);
      END LOOP; -- l_consol_invs_index

      --Yao Zhang add for new consolidation logic, the consolidation invoice should be either posotive invoice
      --or credit memo, there should not be postive lines and negtive lines in one invoice.
       --Yao comment begin for bug#8946609
      /* IF l_result_flag IS NULL OR l_result_flag='W'
       THEN*/
       --Yao comment end for bug#8946609
        l_csldtion_inv_lines_index:=l_csldtion_inv.trx_lines.FIRST;
        l_csldtion_line_num:=0;
        l_csldtion_discount_line_num:=0;--Yao add for bug#8946609
        WHILE l_csldtion_inv_lines_index IS NOT NULL
        LOOP
         --yao zhang add for bug8830170 begin
         --Yao modified for bug9362043
         IF  --  l_csldtion_inv.trx_lines(l_csldtion_inv_lines_index).quantity<>0 AND
            l_csldtion_inv.trx_lines(l_csldtion_inv_lines_index).amount<>0
         THEN
         l_csldtion_line_num:=l_csldtion_line_num+1;
         l_csldtion_inv.trx_lines(l_csldtion_inv_lines_index).line_number:=l_csldtion_line_num;
         --Yao added for bug9362043
         IF l_csldtion_inv.trx_lines(l_csldtion_inv_lines_index).quantity=0
         THEN
         l_csldtion_inv.trx_lines(l_csldtion_inv_lines_index).quantity:=NULL;
         l_csldtion_inv.trx_lines(l_csldtion_inv_lines_index).unit_price :=NULL;
         ELSE
         l_csldtion_inv.trx_lines(l_csldtion_inv_lines_index).unit_price  :=round(l_csldtion_inv.trx_lines(l_csldtion_inv_lines_index).amount
                                                                        /l_csldtion_inv.trx_lines(l_csldtion_inv_lines_index).quantity,6);
         END IF;
         --Yao added end for bug9362043

         --if discoutn _amount or discount tax amount is 0, set it to null.
         IF l_csldtion_inv.trx_lines(l_csldtion_inv_lines_index).discount_amount=0
            AND l_csldtion_inv.trx_lines(l_csldtion_inv_lines_index).discount_tax_amount=0
         THEN
         l_csldtion_inv.trx_lines(l_csldtion_inv_lines_index).discount_amount:=NULL;
         l_csldtion_inv.trx_lines(l_csldtion_inv_lines_index).discount_tax_amount:=NULL; --Yao add for bug#8920239
         END IF;
         --Yao delete begin for bug#8920239
         /*IF l_csldtion_inv.trx_lines(l_csldtion_inv_lines_index).discount_tax_amount=0
         THEN
         l_csldtion_inv.trx_lines(l_csldtion_inv_lines_index).discount_tax_amount:=NULL;
         END IF;*/
         --Yao delete end for bug#8920239
         l_csldtion_inv.trx_lines(l_csldtion_inv_lines_index).discount_rate :=-1*round((l_csldtion_inv.trx_lines(l_csldtion_inv_lines_index).discount_amount
                                                                                           /l_csldtion_inv.trx_lines(l_csldtion_inv_lines_index).amount),5);
         --Yao add begin for bug#8946609
         IF l_csldtion_inv.trx_lines(l_csldtion_inv_lines_index).discount_flag='1'
            AND  l_consol_sign_flag<>-1
         THEN
         l_csldtion_discount_line_num:=l_csldtion_discount_line_num+1;
         END IF;
         --Yao add end for bug#8946609

         IF l_csldtion_line_sign_flag IS NULL
         THEN
           IF l_csldtion_inv.trx_lines(l_csldtion_inv_lines_index).amount>0
           THEN l_csldtion_line_sign_flag:=1;
           ELSE l_csldtion_line_sign_flag:=-1;
           END IF;
         ELSIF (l_csldtion_line_sign_flag=1 AND l_csldtion_inv.trx_lines(l_csldtion_inv_lines_index).amount<0)
            OR (l_csldtion_line_sign_flag=-1 AND l_csldtion_inv.trx_lines(l_csldtion_inv_lines_index).amount>0)
      THEN
            l_result_flag:='E';
        fnd_message.set_name('AR'
                            ,'AR_GTA_CON_NEG_INV_LINES');
        l_error_string:=fnd_message.get();
            EXIT;
         END IF;
         ELSE /*l_csldtion_inv.trx_lines(l_csldtion_inv_lines_index).quantity<>0
               AND l_csldtion_inv.trx_lines(l_csldtion_inv_lines_index).amount<>0*/
         l_csldtion_inv.trx_lines.DELETE(l_csldtion_inv_lines_index);
        END IF;/*l_csldtion_inv.trx_lines(l_csldtion_inv_lines_index).quantity<>0
           AND l_csldtion_inv.trx_lines(l_csldtion_inv_lines_index).amount<>0*/
         --yao zhang add for bug8830170 end
          l_csldtion_inv_lines_index:= l_csldtion_inv.trx_lines.NEXT(l_csldtion_inv_lines_index);
        END LOOP;
        --END IF;--l_result_flag IS NULL OR l_result_flag='W'--Yao comment for bug#8946609
      --Yao Zhang add end
      --Yao add begin for bug#8946609
      --check line number and discount count line number of invoice
      IF (l_result_flag IS NULL OR l_result_flag='W')
         AND l_csldtion_discount_line_num+l_csldtion_line_num>l_max_line
         AND l_sales_list_flag<>'Y'
      THEN
        l_result_flag:='E';
        fnd_message.set_name('AR'
                            ,'AR_GTA_FAIL_EXCEED_LIMMITS');
        l_error_string:=fnd_message.get();
      END IF;
      --Yao add end for bug#8946609


      --consolidation is successful
      IF l_result_flag IS NULL OR l_result_flag='W'
      THEN
        l_result_flag:=nvl(l_result_flag,'S');
        --new header sequence
        SELECT ar_gta_trx_headers_all_s.NEXTVAL
        INTO l_csldtion_inv.trx_header.gta_trx_header_id
        FROM dual;
        --copy trx header information
        l_csldtion_inv.trx_header.ra_gl_date                 :=l_csldted_inv.trx_header.ra_gl_date;
        l_csldtion_inv.trx_header.ra_gl_period               :=l_csldted_inv.trx_header.ra_gl_period;
        l_csldtion_inv.trx_header.set_of_books_id            :=l_csldted_inv.trx_header.set_of_books_id;
        l_csldtion_inv.trx_header.bill_to_customer_id        :=l_csldted_inv.trx_header.bill_to_customer_id;
        l_csldtion_inv.trx_header.bill_to_customer_number    :=l_csldted_inv.trx_header.bill_to_customer_number;
        l_csldtion_inv.trx_header.bill_to_customer_name      :=l_bill_to_customer_name;
        l_csldtion_inv.trx_header.SOURCE                     :='AR';
        l_csldtion_inv.trx_header.org_id                     :=l_csldted_inv.trx_header.org_id;
        l_csldtion_inv.trx_header.version                    :='1';
        l_csldtion_inv.trx_header.latest_version_flag        :='Y';
       -- l_csldtion_inv.trx_header.group_number               :='0';
        l_csldtion_inv.trx_header.transaction_date           :=l_csldted_inv.trx_header.transaction_date;
        l_csldtion_inv.trx_header.customer_address           :=l_csldted_inv.trx_header.customer_address;
        l_csldtion_inv.trx_header.customer_phone             :=l_csldted_inv.trx_header.customer_phone ;
        l_csldtion_inv.trx_header.customer_address_phone     :=l_customer_address_phone;
        l_csldtion_inv.trx_header.bank_account_name          :=l_bank_account_name;
        l_csldtion_inv.trx_header.bank_account_number        :=l_bank_account_number;
        l_csldtion_inv.trx_header.bank_account_name_number   :=l_csldted_inv.trx_header.bank_account_name_number;
        l_csldtion_inv.trx_header.status                     :='DRAFT';
        l_csldtion_inv.trx_header.sales_list_flag            :=l_sales_list_flag;
        l_csldtion_inv.trx_header.cancel_flag                :='N';
        l_csldtion_inv.trx_header.legal_entity_id            :=l_csldted_inv.trx_header.legal_entity_id;
        l_csldtion_inv.trx_header.fp_tax_registration_number :=l_fp_tax_registration_number;
        l_csldtion_inv.trx_header.tp_tax_registration_number :=l_tp_tax_registration_number;
        l_csldtion_inv.trx_header.request_id                 := fnd_global.CONC_REQUEST_ID();
        l_csldtion_inv.trx_header.program_application_id     := fnd_global.PROG_APPL_ID();
        l_csldtion_inv.trx_header.program_id                 := fnd_global.CONC_PROGRAM_ID;
        l_csldtion_inv.trx_header.program_update_date        := SYSDATE;
        l_csldtion_inv.trx_header.creation_date              := SYSDATE;
        l_csldtion_inv.trx_header.created_by                 := fnd_global.LOGIN_ID();
        l_csldtion_inv.trx_header.last_update_date           := SYSDATE;
        l_csldtion_inv.trx_header.last_updated_by            := fnd_global.LOGIN_ID();
        l_csldtion_inv.trx_header.last_update_login          := fnd_global.LOGIN_ID();
        l_csldtion_inv.trx_header.invoice_type               :=l_invoice_type;
        l_csldtion_inv.trx_header.consolidation_flag         :='0';
        --generate group number for consolidation invoice
        BEGIN
        SELECT MAX(group_number)+1
        INTO l_csldtion_inv.trx_header.group_number
        FROM ar_gta_trx_headers_all jgth
        WHERE jgth.gta_trx_number LIKE l_csldted_inv.trx_header.ra_trx_id||'-%';
        EXCEPTION
        WHEN no_data_found THEN
        l_csldtion_inv.trx_header.group_number:=1;
        END;
        l_csldtion_inv.trx_header.gta_trx_number := l_csldted_inv.trx_header.ra_trx_id
                                         || '-'
                                         || l_csldtion_inv.trx_header.group_number
                                         || '-'
                                         || l_csldtion_inv.trx_header.version;

         l_csldtion_inv_lines_index:=l_csldtion_inv.trx_lines.FIRST;
        WHILE l_csldtion_inv_lines_index IS NOT NULL
        LOOP
          SELECT ar_gta_trx_lines_all_s.NEXTVAL
            INTO l_csldtion_inv.trx_lines(l_csldtion_inv_lines_index).gta_trx_line_id
            FROM dual;
         l_csldtion_inv.trx_lines(l_csldtion_inv_lines_index).gta_trx_header_id
                                            :=l_csldtion_inv.trx_header.gta_trx_header_id;
          l_csldtion_inv_lines_index:= l_csldtion_inv.trx_lines.NEXT(l_csldtion_inv_lines_index);
        END LOOP;
        --create consolidation inv
        AR_GTA_TRX_UTIL.create_trx(l_csldtion_inv);

        l_csldted_invs_index:=l_csldted_invs.FIRST;
        WHILE l_csldted_invs_index IS NOT NULL
        LOOP
          UPDATE ar_gta_trx_headers_all
             SET status                = 'CONSOLIDATED',
                 consolidation_flag    = '1',
                 consolidation_trx_num = l_csldtion_inv.trx_header.gta_trx_number
           WHERE gta_trx_header_id = l_csldted_invs(l_csldted_invs_index).trx_header.gta_trx_header_id;
          l_csldted_invs_index := l_csldted_invs.NEXT(l_csldted_invs_index);
        END LOOP;
      END IF;--l_result_flag IS NULL OR l_result_flag='W'
    END IF;--ABS(l_sum_amount)>l_max_amount OR (l_consol_sign_flag=0 AND l_sum_amount<0) and
          --l_csldted_invs.COUNT<=1 create consolidation invoice
        SELECT AR_gta_consol_temp_s.NEXTVAL
        INTO l_gta_consol_temp_seq
        FROM dual;
        INSERT INTO AR_gta_consol_temp
        (seq
        ,status
        ,consolidation_inv_number
        ,customer_name
        ,tp_tax_reg_num
        ,customer_address_phone
        ,bank_account_name
        ,bank_account_num
        ,invoice_type
        ,amount
        ,failed_reason)
        SELECT
        l_gta_consol_temp_seq
        ,l_result_flag
        ,l_csldtion_inv.trx_header.gta_trx_number
        ,l_bill_to_customer_name
        ,l_tp_tax_registration_number
        ,l_customer_address_phone
        ,l_bank_account_name
        ,l_bank_account_number
        ,l_invoice_type
        ,l_sum_amount
        ,l_error_string
        FROM dual;
        --insert csldted invs to table ar_gta_consol_invs_temp
        --init l_csldted_invs_index
        l_csldted_invs_index:=l_csldted_invs.FIRST;
        WHILE l_csldted_invs_index IS NOT NULL
        LOOP
        BEGIN
        --set consolidation_id to be null for failed gta invoices

        IF l_result_flag='E'
        THEN
        UPDATE ar_gta_trx_headers_all
        SET consolidation_id=NULL
        WHERE GTA_TRX_HEADER_ID=l_csldted_invs(l_csldted_invs_index).trx_header.gta_trx_header_id;
        END IF;
        --get ra transaction type and amount
        SELECT jgthv.ra_trx_type
              ,jgthv.amount
        INTO l_ra_trx_type
            ,l_amount
        FROM AR_GTA_TRX_HEADERS_V jgthv
        WHERE jgthv.GTA_TRX_HEADER_ID=l_csldted_invs(l_csldted_invs_index).trx_header.gta_trx_header_id;
        EXCEPTION
        WHEN no_data_found THEN
             IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.String(FND_LOG.LEVEL_UNEXPECTED,
                     G_MODULE_PREFIX || l_procedure_name ||
                     '. Can not get Transaction Type for GTA Invoice:'
                     ||l_csldted_invs(l_csldted_invs_index).trx_header.gta_trx_header_id,
                     'Unknown error' || SQLCODE || SQLERRM);
         END IF;
         RAISE;
        END;
        INSERT INTO AR_gta_consol_invs_temp
        (seq
        ,consolidated_inv_number
        ,gl_period
        ,ra_trx_num
        ,ra_trx_type
        ,amount)
        SELECT
        l_gta_consol_temp_seq
        ,l_csldted_invs(l_csldted_invs_index).trx_header.GTA_TRX_NUMBER
        ,l_csldted_invs(l_csldted_invs_index).trx_header.ra_gl_period
        ,l_csldted_invs(l_csldted_invs_index).trx_header.RA_TRX_NUMBER
        ,l_ra_trx_type
        ,l_amount
         FROM dual;
         l_csldted_invs_index:=l_csldted_invs.NEXT(l_csldted_invs_index);
         END LOOP;


    END LOOP;
    CLOSE c_consolidation_groups;

  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||'.'|| l_procedure_name
                  ,'End Procedure. ');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.String(FND_LOG.LEVEL_UNEXPECTED,
                     G_MODULE_PREFIX || l_procedure_name ||
                     '. OTHER_EXCEPTION ',
                     'Unknown error' || SQLCODE || SQLERRM);

    END IF;
    UPDATE ar_gta_trx_headers_all
       SET consolidation_id = NULL
          ,consolidation_trx_num=NULL
          ,consolidation_flag=NULL
          ,status='DRAFT'
     WHERE consolidation_id = l_consolidation_id;
     COMMIT;
   fnd_file.PUT_LINE(fnd_file.LOG,'Update consolidation id'||l_consolidation_id);
   RAISE;
END create_consol_inv;


END AR_GTA_CONSOLIDATE_PROC;


/
