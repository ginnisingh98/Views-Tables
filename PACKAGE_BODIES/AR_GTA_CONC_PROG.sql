--------------------------------------------------------
--  DDL for Package Body AR_GTA_CONC_PROG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_GTA_CONC_PROG" AS
--$Header: ARGCCPGB.pls 120.0.12010000.4 2010/01/19 03:13:24 choli noship $
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     ARCCPGB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|      This package is the a collection of procedures which             |
--|      called by concurrent programs                                    |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|      PROCEDURE Transfer_AR_Transactions                               |
--|      PROCEDURE Purge_Invoice                                          |
--|      PROCEDURE Run_AR_GT_Mapping                                      |
--|      PROCEDURE Import_GT_Invoices                                     |
--|      PROCEDURE Transfer_Invoices_to_GT                                |
--|      PROCEDURE Export_Invoices_from_Workbench                         |
--|      PROCEDURE Discrepancy_Report                                     |
--|      PROCEDURE Item_Export                                            |
--|      PROCEDURE Transfer_Customers_To_GT                               |
--|      PROCEDURE Consolidate_Invoices                                   |
--|      PROCEDURE Run_Consolidation_Mapping                              |
--|      PROCEDURE Populate_Invoice_Type                                  |
--|      PROCEDURE Populate_Invoice_Type_Header                           |
--|                                                                       |
--| HISTORY                                                               |
--|      20-APR-2005: Jim Zheng                                           |
--|      08-MAY-2005: Qiang Li                                            |
--|      20-MAY-2005: Jogen Hu        add Import_GT_invoices              |
--|                                   Transfer_Invoices_to_GT             |
--|                                   Transfer_Trxs_from_workbench        |
--|      13-Jun-2005: Donghai Wang    add procedure Discrepancy_Report    |
--|                                   and Item_Export                     |
--|      01-Jul-2005: Jim Zheng       Update after code review,           |
--|                                   chang parameter type.               |
--|      25-Aug-2005: Jogen Hu        for import invoices,                |
--|                                   move clearing temporary table from  |
--|                                   AR_GTA_TXT_OPERATOR_PROC into this |
--|      28-Sep-2005: Jonge Hu        change transfer_invoices_to_gt      |
--|      18-Oct-2005: Donghai Wang    Update 'Transrfer_Invoices_To_GT'   |
--|                                   procedure to adjust order of        |
--|                                   paramerts                           |
--|      16-Nov-2005: Jim Zheng       Change the output of gta_not_Enable |
--|      16-Nov-2005: Qiang Li        Change Purge_invoice,run_AR_GT_mappi|
--|                                   ng, to set their status to warnning |
--|      23-Nov-2005: Donghai Wang    Update procedure Discrepancy_Report,|
--|                                   set its status to 'Warnning' when   |
--|                                   Profile 'GTA Not Enabled' is set to |
--|                                   'No'                                |
--|      30-Nov-2005: Qiang Li        Change set_of_books_id to ledger_id |
--|      01-Dec-2005: Qiang Li        Use function Get_AR_Batch_Source_Name
--|                                   to translate source id to source name
--|                                   in Run_AR_GT_Mapping procedure      |
--|      06-Mar-2006: Donghai Wang    Update Discrepancy_Report and       |
--|                                   Item_Eport for adding fnd log       |
--|      26-Apr-2006: Qiang Li        Update the PROCEDURE Purge_Invoice  |
--|      14-Sep-2006: Qiang Li        Update the PROCEDURE Purge_Invoice  |
--|      20-Jul-2009: Yao Zhang       Add procedure Consolidate_Invoices  |
--|                                                                       |
--|      25-Jul-2009: Allen Yang      Add procedure run_consolidation_mapping|
--|                                   for bug 8605196: ENHANCEMENT FOR    |
--|                                   GOLDEN TAX ADAPTER R12.1.2
--|      08-Aug-2009: Yao Zhang      Fix bug#8770356, add parameter org_id to
--|                                  procedure consolidate_invoices       |
--|      16-Aug-2009: Allen Yang     Add procedures Populate_Invoice_Type |
--|                                  and Populate_Invoice_Type_Header to  |
--|                                  do data migration from 12.0 to 12.1.X|
--|      02-Sep-2009  Allen Yang     modified procedure                   |
--|                                  Run_Consolidation_Mapping for bug    |
--|                                  8848798                              |
--|      19-Oct-2009  Allen Yang     modified procedure import_gt_invoices|
--|                                  for bug 9008021                      |
--+======================================================================*/

--==========================================================================
--  PROCEDURE NAME:
--
--    Transfer_AR_Transactions                     Public
--
--  DESCRIPTION:
--
--      This procedure is the main program for transfer program.
--
--  PARAMETERS:
--      In:  p_transfer_id         Transfer rule id
--           p_customer_num_from   Customer number from
--           p_customer_num_to     Customer number to
--           p_customer_name_from  Customer name from
--           p_customer_name_to    Customer name to
--           p_gl_period           GL period
--           p_gl_date_from        GL date from
--           p_gl_date_to          GL date to
--           p_trx_batch_from      Batch number from
--           p_trx_batch_to        Batch number to
--           p_trx_number_from     Trx number from
--           p_trx_number_to       Trx number to
--           p_trx_date_from       Trx date from
--           p_trx_date_to         Trx date to
--           p_doc_num_from        Doc number from
--           p_doc_num_to          Doc number to
--     Out:  errbuf
--           retcode
--
--  DESIGN REFERENCES:
--      GTA-TRANSFER-PROGRAM-TD.doc
--
--  CHANGE HISTORY:
--
--           05-MAY-2005: Jim.Zheng  Created
--
--===========================================================================
PROCEDURE transfer_ar_transactions
(errbuf               OUT NOCOPY VARCHAR2
,retcode              OUT NOCOPY VARCHAR2
,p_transfer_id        IN         VARCHAR2
,p_customer_num_from  IN         VARCHAR2
,p_customer_num_to    IN         VARCHAR2
,p_customer_name_from IN         VARCHAR2
,p_customer_name_to   IN         VARCHAR2
,p_gl_period          IN         VARCHAR2
,p_gl_date_from       IN         VARCHAR2
,p_gl_date_to         IN         VARCHAR2
,p_trx_batch_from     IN         VARCHAR2
,p_trx_batch_to       IN         VARCHAR2
,p_trx_number_from    IN         VARCHAR2
,p_trx_number_to      IN         VARCHAR2
,p_trx_date_from      IN         VARCHAR2
,p_trx_date_to        IN         VARCHAR2
,p_doc_num_from       IN         NUMBER
,p_doc_num_to         IN         NUMBER
) IS
l_procedure_name          VARCHAR2(50) := 'transfer_AR_to_GTA';
l_parameters              ar_gta_trx_util.transferparas_rec_type;
l_ar_gta_gta_not_enabled VARCHAR2(4000);
l_conc_succ               BOOLEAN;
l_errbuf                  VARCHAR2(4000);
l_retcode                 VARCHAR2(4000);
l_org_id                  NUMBER := mo_global.get_current_org_id;

BEGIN
  --begin procedure
  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
  THEN
    fnd_log.STRING(fnd_log.level_procedure
                  ,g_module_prefix || l_procedure_name
                  ,'Begin Procedure. ');
  END IF;

  -- wrap parameter to record
  IF (fnd_profile.VALUE('AR_GTA_ENABLED') = 'Y')
  THEN
    l_parameters.customer_num_from  := p_customer_num_from;
    l_parameters.customer_num_to    := p_customer_num_to;
    l_parameters.customer_name_from := p_customer_name_from;
    l_parameters.customer_name_to   := p_customer_name_to;
    l_parameters.gl_period          := p_gl_period;
    l_parameters.gl_date_from       := fnd_date.canonical_to_date(p_gl_date_from);
    l_parameters.gl_date_to         := fnd_date.canonical_to_date(p_gl_date_to);
    l_parameters.trx_batch_from     := p_trx_batch_from;
    l_parameters.trx_batch_to       := p_trx_batch_to;
    l_parameters.trx_number_from    := p_trx_number_from;
    l_parameters.trx_number_to      := p_trx_number_to;
    l_parameters.trx_date_from      := fnd_date.canonical_to_date(p_trx_date_from);
    l_parameters.trx_date_to        := fnd_date.canonical_to_date(p_trx_date_to);
    l_parameters.doc_num_from       := p_doc_num_from;
    l_parameters.doc_num_to         := p_doc_num_to;

    -- call AR_GTA_ARTRX_PROC_JIM.transfer_AR_to_GTA
    ar_gta_artrx_proc.transfer_ar_to_gta(errbuf            => l_errbuf
                                             ,retcode           => l_retcode
                                             ,p_org_id          => l_org_id
                                             ,p_transfer_id     => p_transfer_id
                                             ,p_conc_parameters => l_parameters);

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
      fnd_log.STRING(fnd_log.level_procedure
                    ,g_module_prefix || l_procedure_name
                    ,'errbuf is : ' || l_errbuf || '  retcode is :' ||
                     l_retcode);
    END IF;

  ELSE
    -- report AR_GTA_DISABLE_ERROR in xml format
    -- set concurrent status to WARNING
    fnd_message.set_name('AR'
                        ,'AR_GTA_GTA_NOT_ENABLE');
    l_ar_gta_gta_not_enabled := '<TransferReport>
                                  <ReportFailed>Y</ReportFailed>
                                  <ReportFailedMsg>' ||
                                  fnd_message.get ||
                                  '</ReportFailedMsg>
                                  <FailedWithParameters>Y</FailedWithParameters>
                                  </TransferReport>';

    fnd_file.put_line(fnd_file.output
                     ,l_ar_gta_gta_not_enabled);

    l_conc_succ := fnd_concurrent.set_completion_status(status  => 'WARNING'
                                                       ,message => l_ar_gta_gta_not_enabled);
    RETURN;
  END IF;
  -- end procedure
  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
  THEN
    fnd_log.STRING(fnd_log.level_procedure
                  ,g_module_prefix || l_procedure_name
                  ,'End Procedure. ');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)
    THEN
      fnd_log.STRING(fnd_log.level_unexpected
                    ,g_module_prefix || l_procedure_name ||
                     '. OTHER_EXCEPTION '
                    ,SQLCODE || SQLERRM);
    END IF;
    RAISE;

END transfer_ar_transactions;

--==========================================================================
--  PROCEDURE NAME:
--
--    Purge_Invoice                     Public
--
--  DESCRIPTION:
--
--      This procedure is the main program for purge program,
--      it search eligible records in GTA invoice tables first,
--      if find any, then invoke corresponding table handlers to
--      remove these records from db.
--
--  PARAMETERS:
--      In:  p_ledger_id           Ledger identifier
--           p_customer_name       Customer name
--           p_gl_date_from        GL date low range
--           p_gl_date_to          GL date high range
--
--     Out:  errbuf
--           retcode
--
--  DESIGN REFERENCES:
--      GTA-PURGE-PROGRAM-TD.doc
--
--  CHANGE HISTORY:
--
--           8-MAY-2005: Qiang Li   Created.
--           16-Nov-2005:Qiang Li   When GTA profile is not enabled,set concurrent
--                                  status to 'Warnning'
--           30-Nov-2005: Qiang Li  Change set_of_books_id to ledger_id
--           26-Jun-2006: Qiang Li  Remove the condition of GL period is closed
--           14-Sep-2006: Qiang Li  Use function To_Xsd_Date_String to replace
--                                  format_date, according to new XML template standards
--===========================================================================

PROCEDURE purge_invoice
(errbuf            OUT NOCOPY VARCHAR2
,retcode           OUT NOCOPY VARCHAR2
,p_ledger_id       IN         NUMBER
,p_customer_name   IN         VARCHAR2
,p_gl_date_from    IN         VARCHAR2
,p_gl_date_to      IN         VARCHAR2
)
IS
l_org_id                  NUMBER := mo_global.get_current_org_id;
l_procedure_name          VARCHAR2(30) := 'Purge_Invoice';
l_gl_date_from            DATE;
l_gl_date_to              DATE;
l_dbg_msg                 VARCHAR2(1000);
l_gta_header_count        NUMBER;
l_gt_header_count         NUMBER;
l_gta_line_count          NUMBER;
l_gt_line_count           NUMBER;
l_line_count              NUMBER;
l_gta_trx_header_id       ar_gta_trx_headers_all.gta_trx_header_id%TYPE;
l_source                  ar_gta_trx_headers_all.SOURCE%TYPE;
l_customer_trx_id         ra_customer_trx_all.customer_trx_id%TYPE;
l_output_msg              VARCHAR2(2000);
l_no_data_flag            VARCHAR2(1) := 'N';
l_report                  xmltype;
l_summary                 xmltype;
l_parameter               xmltype;
l_ar_gta_enabled         fnd_profile_option_values.profile_option_value%TYPE := NULL;
l_ar_gta_gta_not_enabled VARCHAR2(500);
l_no_data_message         VARCHAR2(500);
l_dbg_level               NUMBER := fnd_log.g_current_runtime_level;
l_proc_level              NUMBER := fnd_log.level_procedure;
l_conc_succ               BOOLEAN;



CURSOR c_gta_header IS
  SELECT
    jgth.gta_trx_header_id
    ,jgth.SOURCE
    ,rct.customer_trx_id
  FROM
    ar_gta_trx_headers_all jgth
    ,ra_customer_trx_all     rct
  WHERE jgth.org_id = l_org_id
    AND jgth.status IN ('FAILED', 'COMPLETED', 'CANCELLED')
    AND jgth.bill_to_customer_name LIKE nvl(p_customer_name,'%')
    AND jgth.ra_gl_date >= l_gl_date_from
    AND jgth.ra_gl_date <= l_gl_date_to
    AND jgth.ra_trx_id = rct.customer_trx_id(+)
  FOR    UPDATE;

BEGIN

  --logging for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || l_procedure_name || '.begin'
                  ,'enter procedure');
  END IF; /*IF (l_proc_level>=l_dbg_level)*/

  -- Data conversion
  l_gl_date_from     := fnd_date.canonical_to_date(p_gl_date_from);
  l_gl_date_to       := fnd_date.canonical_to_date(p_gl_date_to);
  l_gta_header_count := 0;
  l_gt_header_count  := 0;
  l_gta_line_count   := 0;
  l_gt_line_count    := 0;

  SELECT xmlelement("Parameters"
                    ,xmlforest(ar_gta_trx_util.get_operatingunit(l_org_id) AS
                              "OperationUnit"
                              ,p_customer_name AS
                              "ARCustomerName"
                              ,ar_gta_trx_util.To_Xsd_Date_String(l_gl_date_from) AS
                              "ARTrxGLDateFrom"
                              ,ar_gta_trx_util.To_Xsd_Date_String(l_gl_date_to) AS
                              "ARTrxGLDateTo"))
  INTO   l_parameter
  FROM   dual;

  fnd_profile.get('AR_GTA_ENABLED'
                 ,l_ar_gta_enabled);

  IF nvl(l_ar_gta_enabled
        ,'N') = 'N'
  THEN
    fnd_message.set_name('AR'
                        ,'AR_GTA_GTA_NOT_ENABLE');
    l_ar_gta_gta_not_enabled := fnd_message.get();

    -- Output the context of l_ar_gta_gta_not_enabled
    SELECT xmlelement("PurgeReport"
                      ,xmlconcat(xmlelement("ReportFailed"
                                           ,'Y')
                                ,xmlelement("FailedWithParameters"
                                           ,'N')
                                ,xmlelement("RepDate"
                                           ,ar_gta_trx_util.To_Xsd_Date_String(SYSDATE))
                                ,xmlelement("ReportFailedMsg"
                                           ,l_ar_gta_gta_not_enabled)
                                ,l_parameter))
    INTO   l_report
    FROM   dual;

    ar_gta_trx_util.output_conc(l_report.getclobval());
		l_conc_succ := fnd_concurrent.set_completion_status(status  => 'WARNING'
                                                       ,message => l_ar_gta_gta_not_enabled);
    RETURN;
  END IF; /*IF NVL(l_ar_gta_enabled,'N')<>'Y'*/



  --Main process for purge
  OPEN c_gta_header;
  FETCH c_gta_header
    INTO l_gta_trx_header_id, l_source, l_customer_trx_id;

  WHILE c_gta_header%FOUND
  LOOP
    IF l_customer_trx_id IS NULL
    THEN
      SELECT
        COUNT(*)
      INTO
        l_line_count
      FROM
        ar_gta_trx_lines_all
      WHERE  gta_trx_header_id = l_gta_trx_header_id;

      -- delete GTA and gt invoices inclunding headers and lines
      -- according to GTA_TRX_HEADER_ID
      ar_gta_trx_util.delete_header_line_cascade(p_gta_trx_header_id => l_gta_trx_header_id);

      IF l_source = 'AR' --count deleted GTA transaction headers and lines
      THEN
        l_gta_header_count := l_gta_header_count + 1;
        l_gta_line_count   := l_gta_line_count + l_line_count;

      ELSIF l_source = 'GT' --count deleted GT transaction headers and lines
      THEN
        l_gt_header_count := l_gt_header_count + 1;
        l_gt_line_count   := l_gt_line_count + l_line_count;
      END IF; /*IF l_source='AR'*/

      l_line_count := 0;
    END IF; /*IF l_customer_trx_id IS NULL*/

    FETCH c_gta_header
      INTO l_gta_trx_header_id, l_source, l_customer_trx_id;
  END LOOP; /*WHILE c_gta_header%FOUND*/

  CLOSE c_gta_header;

  SELECT xmlelement("Summary"
                    ,xmlforest(l_gta_header_count AS "GTATrxHeaderPurged"
                              ,l_gta_line_count AS "GTATrxLinePurged"
                              ,l_gt_header_count AS "GTTrxHeaderPurged"
                              ,l_gt_line_count AS "GTTrxLinePurged"))
  INTO   l_summary
  FROM   dual;

  --Generate Reports Xml Data
  SELECT xmlelement("PurgeReport"
                    ,xmlconcat(xmlelement("ReportFailed"
                                         ,'N')
                              ,xmlelement("FailedWithParameters"
                                         ,'N')
                              ,xmlelement("RepDate"
                                         ,ar_gta_trx_util.To_Xsd_Date_String(SYSDATE))
                              ,l_parameter
                              ,l_summary))
  INTO   l_report
  FROM   dual;

  ar_gta_trx_util.output_conc(l_report.getclobval());

  --logging for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || l_procedure_name || '.end'
                  ,'end procedure');
  END IF; /*IF (l_proc_level>=l_dbg_level)*/

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    IF fnd_log.level_unexpected >= l_dbg_level
    THEN
      fnd_log.STRING(fnd_log.level_unexpected
                  ,g_module_prefix || l_procedure_name || '.OTHER_EXCEPTION'
                  ,SQLCODE || SQLERRM);
    END IF;
    RAISE;
    ROLLBACK;
END purge_invoice;

--==========================================================================
--  PROCEDURE NAME:
--
--    Run_AR_GT_Mapping                     Public
--
--  DESCRIPTION:
--
--      This Concurrent program Generate Mapping Report Data
--
--  PARAMETERS:
--      In:  p_fp_tax_reg_num      First Party Tax Registration Number
--           p_trx_source          Transaction source,GT or AR
--           P_Customer_Id         Customer id
--           p_gt_inv_num_from     GT Invoice Number low range
--           p_gt_inv_num_to       GT Invoice Number high range
--           p_gt_inv_date_from    GT Invoice Date low range
--           p_gt_inv_date_to      GT Invoice Date high range
--           p_ar_inv_num_from     AR Invoice Number low range
--           p_ar_inv_num_to       AR Invoice Number high range
--           p_ar_inv_date_from    AR Invoice Date low range
--           p_ar_inv_date_to      AR Invoice Date high range
--
--     Out:  errbuf
--           retcode
--
--  DESIGN REFERENCES:
--      GTA_REPORTS_TD.doc
--
--  CHANGE HISTORY:
--
--           8-MAY-2005: Qiang Li   Created.
--           27-Sep-2005:Qiang Li   Add a new parameter fp_tax_reg_number
--           16-Nov-2005:Qiang Li   When GTA profile is not enabled,set concurrent
--                                  status to 'Warnning'
--
--===========================================================================
PROCEDURE run_ar_gt_mapping
(errbuf             OUT NOCOPY VARCHAR2
,retcode            OUT NOCOPY VARCHAR2
,p_fp_tax_reg_num   IN         VARCHAR2
,p_trx_source       IN         NUMBER
,p_customer_id      IN         VARCHAR2
,p_gt_inv_num_from  IN         VARCHAR2
,p_gt_inv_num_to    IN         VARCHAR2
,p_gt_inv_date_from IN         VARCHAR2
,p_gt_inv_date_to   IN         VARCHAR2
,p_ar_inv_num_from  IN         VARCHAR2
,p_ar_inv_num_to    IN         VARCHAR2
,p_ar_inv_date_from IN         VARCHAR2
,p_ar_inv_date_to   IN         VARCHAR2
)
IS
l_procedure_name          VARCHAR2(30) := 'run_AR_GT_Mapping';
l_gt_inv_date_from        DATE;
l_gt_inv_date_to          DATE;
l_ar_inv_date_from        DATE;
l_ar_inv_date_to          DATE;
l_ar_gta_enabled         fnd_profile_option_values.profile_option_value%TYPE := NULL;
l_ar_gta_gta_not_enabled VARCHAR2(500);
l_report                  xmltype;
l_parameter               xmltype;
l_dbg_msg                 VARCHAR2(500);
l_dbg_level               NUMBER := fnd_log.g_current_runtime_level;
l_proc_level              NUMBER := fnd_log.level_procedure;
l_org_id                  NUMBER := mo_global.get_current_org_id;
l_conc_succ               BOOLEAN;
BEGIN
  --logging for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || l_procedure_name || '.begin'
                  ,'enter procedure');
  END IF;

  l_gt_inv_date_from := fnd_date.canonical_to_date(p_gt_inv_date_from);
  l_gt_inv_date_to   := fnd_date.canonical_to_date(p_gt_inv_date_to);
  l_ar_inv_date_from := fnd_date.canonical_to_date(p_ar_inv_date_from);
  l_ar_inv_date_to   := fnd_date.canonical_to_date(p_ar_inv_date_to);

  fnd_profile.get('AR_GTA_ENABLED'
                 ,l_ar_gta_enabled);
  IF nvl(l_ar_gta_enabled
        ,'N') = 'N'
  THEN
    SELECT xmlelement("Parameters"
                      ,xmlforest(ar_gta_trx_util.get_operatingunit(l_org_id)
                                 AS "OperationUnit"
                                ,p_fp_tax_reg_num
                                 AS "TaxRegistrationNumber"
                                ,ar_gta_trx_util.Get_AR_Batch_Source_Name
                                ( l_org_id
                                , p_trx_source)
                                 AS "TransactionSource"
                                ,ar_gta_trx_util.get_customer_name(p_customer_id)
                                 AS "ARCustomerName"
                                ,p_gt_inv_num_from
                                 AS "GTInvoiceNumFrom"
                                ,p_gt_inv_num_to
                                 AS "GTInvoiceNumTo"
                                ,ar_gta_trx_util.To_Xsd_Date_String(l_gt_inv_date_from)
                                 AS "GTDateFrom"
                                ,ar_gta_trx_util.To_Xsd_Date_String(l_gt_inv_date_to)
                                 AS "GTDateTo"
                                ,p_ar_inv_num_from
                                 AS "ARTrxNumberFrom"
                                ,p_ar_inv_num_to
                                 AS "ARTrxNumberTo"
                                ,ar_gta_trx_util.To_Xsd_Date_String(l_ar_inv_date_from)
                                 AS "ARTrxDateFrom"
                                ,ar_gta_trx_util.To_Xsd_Date_String(l_ar_inv_date_to)
                                 AS "ARTrxDateTo"))
    INTO   l_parameter
    FROM   dual;

    fnd_message.set_name('AR'
                        ,'AR_GTA_GTA_NOT_ENABLE');
    l_ar_gta_gta_not_enabled := fnd_message.get();

    -- Output the context of l_ar_gta_gta_not_enabled
    SELECT xmlelement("MappingReport"
                      ,xmlconcat(xmlelement("ReportFailed"
                                           ,'Y')
                                ,xmlelement("FailedWithParameters"
                                           ,'N')
                                ,xmlelement("RepDate"
                                           ,ar_gta_trx_util.To_Xsd_Date_String(SYSDATE))
                                ,xmlelement("ReportFailedMsg"
                                           ,l_ar_gta_gta_not_enabled)
                                ,l_parameter))
    INTO   l_report
    FROM   dual;

    ar_gta_trx_util.output_conc(l_report.getclobval());
    l_conc_succ := fnd_concurrent.set_completion_status(status  => 'WARNING'
                                                       ,message => l_ar_gta_gta_not_enabled);
  ELSE
    NULL;

    ar_gta_reports_pkg.generate_mapping_rep(p_org_id           => l_org_id
                                            ,p_fp_tax_reg_num   => p_fp_tax_reg_num
                                            ,p_trx_source       => p_trx_source
                                            ,p_customer_id      => p_customer_id
                                            ,p_gt_inv_num_from  => p_gt_inv_num_from
                                            ,p_gt_inv_num_to    => p_gt_inv_num_to
                                            ,p_gt_inv_date_from => l_gt_inv_date_from
                                            ,p_gt_inv_date_to   => l_gt_inv_date_to
                                            ,p_ar_inv_num_from  => p_ar_inv_num_from
                                            ,p_ar_inv_num_to    => p_ar_inv_num_to
                                            ,p_ar_inv_date_from => l_ar_inv_date_from
                                            ,p_ar_inv_date_to   => l_ar_inv_date_to);

  END IF;

  --logging for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || l_procedure_name || '.end'
                  ,'end procedure');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF fnd_log.level_unexpected >= l_dbg_level
    THEN
      fnd_log.STRING(fnd_log.level_unexpected
                  ,g_module_prefix || l_procedure_name || '.OTHER_EXCEPTION'
                  ,SQLCODE || SQLERRM);
    END IF;
    RAISE;

END run_ar_gt_mapping;

--==========================================================================
--  PROCEDURE NAME:
--
--    Import_GT_Invoices                     Public
--
--  DESCRIPTION:
--
--     This procedure is program of SRS concurrent for import
--     flat file exported from Golden Tax system
--
--  PARAMETERS:
--      In:
--
--     Out:  errbuf
--           retcode
--
--  DESIGN REFERENCES:
--     GTA-Txt-Interface-TD.doc
--
--  CHANGE HISTORY:
--
--           20-MAY-2005: Jogen Hu   Created
--
--           15-AUG-2005: Jogen Hu   Move clear temporary table from
--                                   package ar_gta_txt_operator_proc
--           19-Oct-2009: Allen Yang Modified for bug 9008021
--===========================================================================
PROCEDURE import_gt_invoices
(errbuf  OUT NOCOPY VARCHAR2
,retcode OUT NOCOPY VARCHAR2
)
IS
l_procedure_name          VARCHAR2(30) := 'Import_GT_invoices';
-- modified by Allen Yang 19-Oct-2009 for bug 9008021
-----------------------------------------------------
--l_ar_gta_gta_not_enabled VARCHAR2(300);
l_ar_gta_gta_not_enabled VARCHAR2(3000);
-----------------------------------------------------
l_conc_succ               BOOLEAN;

BEGIN
  --procedure begin
  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
  THEN
    fnd_log.STRING(fnd_log.level_procedure
                  ,g_module_prefix || l_procedure_name || '.begin'
                  ,'Procedure begin');
  END IF;

  IF fnd_profile.VALUE('AR_GTA_ENABLED') = 'N'
  THEN
    fnd_message.set_name('AR'
                        ,'AR_GTA_GTA_NOT_ENABLE');

    l_ar_gta_gta_not_enabled := '<ImportReport>
                               <ReportFailed>Y</ReportFailed>
                               <ReportFailedMsg>' ||
                                 fnd_message.get ||
                                 '</ReportFailedMsg>
                               <FailedWithParameters>Y</FailedWithParameters>
                               </ImportReport>';

    -- Output the context of l_ar_gta_gta_not_enabled
    fnd_file.put_line(fnd_file.output
                     ,l_ar_gta_gta_not_enabled);
    l_conc_succ := fnd_concurrent.set_completion_status(status  => 'WARNING'
                                                       ,message => l_ar_gta_gta_not_enabled);

    ar_gta_txt_operator_proc.Clear_Imp_Temp_Table;
    RETURN;
  END IF;

  ar_gta_txt_operator_proc.import_invoices;

  ar_gta_txt_operator_proc.Clear_Imp_Temp_Table;

  --procedure end
  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
  THEN
    fnd_log.STRING(fnd_log.level_procedure
                  ,g_module_prefix || l_procedure_name || '.end'
                  ,'Procedure end');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)
    THEN
      fnd_log.STRING(fnd_log.level_unexpected
                    ,g_module_prefix || l_procedure_name ||
                     '.OTHER_EXCEPTION '
                    ,SQLCODE || SQLERRM);
    END IF;

    ar_gta_txt_operator_proc.Clear_Imp_Temp_Table;

    RAISE;
END import_gt_invoices;

--==========================================================================
--  PROCEDURE NAME:
--
--    Transfer_Invoices_to_GT                   Public
--
--  DESCRIPTION:
--
--     This procedure is a SRS concurrent program which exports GTA
--     invoices to the flat file Its output will be printed on concurrent
--     output and will be save as flat file by users.
--
--  PARAMETERS:
--      In:    p_regeneration               IN                 VARCHAR2
--             p_fp_tax_reg_num             in                 varchar2
--             p_new_batch_dummy            IN                 VARCHAR2
--             p_regeneration_dummy         IN                 VARCHAR2
--             p_transfer_rule_id           IN                 NUMBER
--             p_batch_number               IN                 VARCHAR2
--             p_customer_id_from_number    IN                 NUMBER
--             p_customer_id_from_name      IN                 NUMBER
--             p_cust_id_from_taxpayer      IN                 NUMBER
--             p_ar_trx_num_from            IN                 VARCHAR2
--             p_ar_trx_num_to              IN                 VARCHAR2
--             p_ar_trx_date_from           IN                 VARCHAR2
--             p_ar_trx_date_to             IN                 VARCHAR2
--             p_ar_trx_gl_date_from        IN                 VARCHAR2
--             p_ar_trx_gl_date_to          IN                 VARCHAR2
--             p_ar_trx_batch_from          IN                 VARCHAR2
--             p_ar_trx_batch_to            IN                 VARCHAR2
--             p_trx_class                  IN                 VARCHAR2
--             p_batch_id                   IN                 VARCHAR2
--
--     Out:  errbuf
--           retcode
--
--  DESIGN REFERENCES:
--     GTA-Txt-Interface-TD.doc
--
--  CHANGE HISTORY:
--
--           20-MAY-2005: Jogen Hu   Created
--           28-Sep-2005: Jogen Hu   add parameter p_fp_tax_reg_num
--           18-Oct-2005: Donghai Wang move the parameter 'p_fp_tax_reg_num'
--                                     behind the parameter 'p_regeneration_dummy'
--
--===========================================================================
PROCEDURE transfer_invoices_to_gt
(errbuf                    OUT NOCOPY VARCHAR2
,retcode                   OUT NOCOPY VARCHAR2
,p_regeneration            IN         VARCHAR2
,p_new_batch_dummy         IN         VARCHAR2
,p_regeneration_dummy      IN         VARCHAR2
,p_fp_tax_reg_num          IN         VARCHAR2
,p_transfer_rule_id        IN         NUMBER
,p_batch_number            IN         VARCHAR2
,p_customer_id_from_number IN         NUMBER
,p_customer_id_from_name   IN         NUMBER
,p_cust_id_from_taxpayer   IN         NUMBER
,p_ar_trx_num_from         IN         VARCHAR2
,p_ar_trx_num_to           IN         VARCHAR2
,p_ar_trx_date_from        IN         VARCHAR2
,p_ar_trx_date_to          IN         VARCHAR2
,p_ar_trx_gl_date_from     IN         VARCHAR2
,p_ar_trx_gl_date_to       IN         VARCHAR2
,p_ar_trx_batch_from       IN         VARCHAR2
,p_ar_trx_batch_to         IN         VARCHAR2
,p_trx_class               IN         VARCHAR2
,p_batch_id                IN         VARCHAR2
,p_invoice_type            IN         VARCHAR2
)
IS
l_procedure_name          VARCHAR2(30) := 'Transfer_Invoices_to_GT';
l_org_id                  NUMBER;
l_ar_trx_date_from        DATE;
l_ar_trx_date_to          DATE;
l_ar_trx_gl_date_from     DATE;
l_ar_trx_gl_date_to       DATE;
l_ar_gta_gta_not_enabled VARCHAR2(1000);
l_conc_succ               BOOLEAN;

BEGIN
  --procedure begin
  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
  THEN
    fnd_log.STRING(fnd_log.level_procedure
                  ,g_module_prefix || l_procedure_name || '.begin'
                  ,'Procedure begin');
  END IF;

  IF fnd_profile.VALUE('AR_GTA_ENABLED') = 'N'
  THEN
    fnd_message.set_name('AR'
                        ,'AR_GTA_GTA_NOT_ENABLE');
    l_ar_gta_gta_not_enabled := '//' || fnd_message.get;

    -- Output the context of l_ar_gta_gta_not_enabled
    fnd_file.put_line(fnd_file.output
                     ,l_ar_gta_gta_not_enabled);
    l_conc_succ := fnd_concurrent.set_completion_status(status  => 'WARNING'
                                                       ,message => l_ar_gta_gta_not_enabled);
    RETURN;
  END IF;

  l_ar_trx_date_from    := fnd_date.canonical_to_date(p_ar_trx_date_from);
  l_ar_trx_date_to      := fnd_date.canonical_to_date(p_ar_trx_date_to);
  l_ar_trx_gl_date_from := fnd_date.canonical_to_date(p_ar_trx_gl_date_from);
  l_ar_trx_gl_date_to   := fnd_date.canonical_to_date(p_ar_trx_gl_date_to);

  l_org_id := mo_global.get_current_org_id;

  AR_GTA_TXT_OPERATOR_PROC.Export_Invoices_From_Conc(p_org_id                  => l_org_id
                                                     ,p_regeneration            => p_regeneration
                                                     ,p_fp_tax_reg_number       => p_fp_tax_reg_num
                                                     ,p_transfer_rule_id        => p_transfer_rule_id
                                                     ,p_batch_number            => p_batch_number
                                                     ,p_customer_id_from_number => p_customer_id_from_number
                                                     ,p_customer_id_from_name   => p_customer_id_from_name
                                                     ,p_cust_id_from_taxpayer   => p_cust_id_from_taxpayer
                                                     ,p_ar_trx_num_from         => p_ar_trx_num_from
                                                     ,p_ar_trx_num_to           => p_ar_trx_num_to
                                                     ,p_ar_trx_date_from        => l_ar_trx_date_from
                                                     ,p_ar_trx_date_to          => l_ar_trx_date_to
                                                     ,p_ar_trx_gl_date_from     => l_ar_trx_gl_date_from
                                                     ,p_ar_trx_gl_date_to       => l_ar_trx_gl_date_to
                                                     ,p_ar_trx_batch_from       => p_ar_trx_batch_from
                                                     ,p_ar_trx_batch_to         => p_ar_trx_batch_to
                                                     ,p_trx_class               => p_trx_class
                                                     ,p_batch_id                => p_batch_id
                                                     ,p_invoice_type_id         => p_invoice_type
                                                     );
  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
  THEN
    fnd_log.STRING(fnd_log.level_procedure
                  ,g_module_prefix || l_procedure_name || '.end'
                  ,'Procedure end');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)
    THEN
      fnd_log.STRING(fnd_log.level_unexpected
                    ,g_module_prefix || l_procedure_name ||
                     '.OTHER_EXCEPTION '
                    ,SQLCODE || SQLERRM);
    END IF;
    RAISE;

END transfer_invoices_to_gt;

--==========================================================================
--  PROCEDURE NAME:
--
--    Export_Invoices_from_Workbench                  Public
--
--  DESCRIPTION:
--
--     This procedure is a SRS concurrent program which exports VAT
--     invoices from GTA to flat file and is invoked in workbench
--
--  PARAMETERS:
--      In:    p_org_id               IN                NUMBER
--             p_generator_ID         IN                NUMBER
--             p_batch_number         IN                VARCHAR2
--
--     Out:  errbuf
--           retcode
--
--  DESIGN REFERENCES:
--     GTA-Txt-Interface-TD.doc
--
--  CHANGE HISTORY:
--
--           20-MAY-2005: Jogen Hu   Created
--
--==========================================================================
PROCEDURE transfer_trxs_from_workbench
(errbuf         OUT NOCOPY VARCHAR2
,retcode        OUT NOCOPY VARCHAR2
,p_org_id       IN         NUMBER
,p_generator_id IN         NUMBER
,p_batch_number IN         VARCHAR2
)
IS
l_procedure_name          VARCHAR2(30) := 'Transfer_Trxs_from_workbench';
l_ar_gta_gta_not_enabled VARCHAR2(300);
l_conc_succ               BOOLEAN;

BEGIN
  --procedure begin
  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
  THEN
    fnd_log.STRING(fnd_log.level_procedure
                  ,g_module_prefix || l_procedure_name || '.begin'
                  ,'Procedure begin');
  END IF;

  IF fnd_profile.VALUE('AR_GTA_ENABLED') = 'N'
  THEN
    fnd_message.set_name('AR'
                        ,'AR_GTA_GTA_NOT_ENABLE');
    l_ar_gta_gta_not_enabled := '//' || fnd_message.get;

    -- Output the context of l_ar_gta_gta_not_enabled
    fnd_file.put_line(fnd_file.output
                     ,l_ar_gta_gta_not_enabled);
    l_conc_succ := fnd_concurrent.set_completion_status(status  => 'WARNING'
                                                       ,message => l_ar_gta_gta_not_enabled);
    RETURN;
  END IF;

  ar_gta_txt_operator_proc.export_invoices_from_workbench(p_org_id       => p_org_id
                                                          ,p_generator_id => p_generator_id
                                                          ,p_batch_id     => p_batch_number);

  --procedure end
  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
  THEN
    fnd_log.STRING(fnd_log.level_procedure
                  ,g_module_prefix || l_procedure_name || '.end'
                  ,'Procedure end');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)
    THEN
      fnd_log.STRING(fnd_log.level_unexpected
                    ,g_module_prefix || l_procedure_name ||
                     '.OTHER_EXCEPTION '
                    ,SQLCODE || SQLERRM);
    END IF;
    RAISE;
END transfer_trxs_from_workbench;

--==========================================================================
--  PROCEDURE NAME:
--
--    Discrepancy_Report                 Public
--
--  DESCRIPTION:
--
--     This procedure is called by concurren program 'Golden Tax
--     Discrepancy Report' to generte discrepancy report.
--
--  PARAMETERS:
--      In:    p_gta_batch_num_from   GTA invoice batch number low range
--             p_gta_batch_num_to     GTA invoice batch number high range
--             p_ar_transaction_type  AR transaction type
--             p_cust_num_from        Customer number low range
--             p_cust_num_to          Customer number high range
--             p_cust_name_id       Identifier of customer
--             p_gl_period            GL period name
--             p_gl_date_from         GL date low range
--             p_gl_date_to           GL date high range
--             p_ar_trx_batch_from    AR transaction batch name low range
--             p_ar_trx_batch_to      AR transaction batch name high range
--             P_ar_trx_num_from      AR transaction number low range
--             P_ar_trx_num_to        AR transaction number high range
--             p_ar_trx_date_from     AR transaction date low range
--             p_ar_trx_date_to       AR transaction date high range
--             p_ar_doc_num_from      AR document sequnce number low range
--             p_ar_doc_num_to        AR document sequnce number high range
--             p_original_curr_code   Original currency code
--             p_primary_sales        Identifier of primary salesperson
--
--     Out:  errbuf
--           retcode
--
--  DESIGN REFERENCES:
--     GTA_REPORTS_TD.doc
--
--  CHANGE HISTORY:
--
--           13-Jun-2005: Donghai Wang  Created
--           06-Mar-2006: Donghai Wang  Add fnd log
--
--==========================================================================
PROCEDURE discrepancy_report
(errbuf                OUT NOCOPY VARCHAR2
,retcode               OUT NOCOPY VARCHAR2
,p_gta_batch_num_from  IN         VARCHAR2
,p_gta_batch_num_to    IN         VARCHAR2
,p_ar_transaction_type IN         NUMBER
,p_cust_num_from       IN         VARCHAR2
,p_cust_num_to         IN         VARCHAR2
,p_cust_name_id        IN         NUMBER
,p_gl_period           IN         VARCHAR2
,p_gl_date_from        IN         VARCHAR2
,p_gl_date_to          IN         VARCHAR2
,p_ar_trx_batch_from   IN         VARCHAR2
,p_ar_trx_batch_to     IN         VARCHAR2
,p_ar_trx_num_from     IN         VARCHAR2
,p_ar_trx_num_to       IN         VARCHAR2
,p_ar_trx_date_from    IN         VARCHAR2
,p_ar_trx_date_to      IN         VARCHAR2
,p_ar_doc_num_from     IN         VARCHAR2
,p_ar_doc_num_to       IN         VARCHAR2
,p_original_curr_code  IN         VARCHAR2
,p_primary_sales       IN         NUMBER
)
IS
l_ar_gta_enabled         VARCHAR2(10);
l_dbg_msg                 VARCHAR2(500);
l_ar_gta_not_enabled_msg VARCHAR2(1000);
l_report_xml              XMLTYPE;
l_procedure_name          VARCHAR2(50);
l_dbg_level               NUMBER := fnd_log.g_current_runtime_level;
l_proc_level              NUMBER := fnd_log.level_procedure;
l_org_id                  hr_all_organization_units.organization_id%TYPE;
l_conc_succ               BOOLEAN;
BEGIN



  l_procedure_name := 'Discrepancy_Report';

  --log for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || '.' || l_procedure_name || '.begin'
                  ,'Enter procedure');

    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || '.' || l_procedure_name || '.parameters'
                  ,'p_gta_batch_num_from '||p_gta_batch_num_from);

    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || '.' || l_procedure_name || '.parameters'
                  ,'p_gta_batch_num_to '||p_gta_batch_num_to);

    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || '.' || l_procedure_name || '.parameters'
                  ,'p_ar_transaction_type '||p_ar_transaction_type);

    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || '.' || l_procedure_name || '.parameters'
                  ,'p_cust_num_from '||p_cust_num_from);

    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || '.' || l_procedure_name || '.parameters'
                  ,'p_cust_num_to '||p_cust_num_to);

    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || '.' || l_procedure_name || '.parameters'
                  ,'p_cust_name_id '||p_cust_name_id);

    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || '.' || l_procedure_name || '.parameters'
                  ,'p_gl_period '||p_gl_period);

    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || '.' || l_procedure_name || '.parameters'
                  ,'p_gl_date_from '||p_gl_date_from);

    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || '.' || l_procedure_name || '.parameters'
                  ,'p_gl_date_to '||p_gl_date_to);

    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || '.' || l_procedure_name || '.parameters'
                  ,'p_ar_trx_batch_from '||p_ar_trx_batch_from);

    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || '.' || l_procedure_name || '.parameters'
                  ,'p_ar_trx_batch_to '||p_ar_trx_batch_to);

    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || '.' || l_procedure_name || '.parameters'
                  ,'p_ar_trx_num_from '||p_ar_trx_num_from);

    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || '.' || l_procedure_name || '.parameters'
                  ,'p_ar_trx_num_to '||p_ar_trx_num_to);

    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || '.' || l_procedure_name || '.parameters'
                  ,'p_ar_trx_date_from '||p_ar_trx_date_from);

    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || '.' || l_procedure_name || '.parameters'
                  ,'p_ar_trx_date_to '||p_ar_trx_date_to);

    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || '.' || l_procedure_name || '.parameters'
                  ,'p_ar_doc_num_from '||p_ar_doc_num_from);

    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || '.' || l_procedure_name || '.parameters'
                  ,'p_ar_doc_num_to '||p_ar_doc_num_to);

    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || '.' || l_procedure_name || '.parameters'
                  ,'p_original_curr_code '||p_original_curr_code);

    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || '.' || l_procedure_name || '.parameters'
                  ,'p_primary_sales '||p_primary_sales);
  END IF; --( l_proc_level >= l_dbg_level )


  --To Get value of profile AR:Golden Tax Enabled
  l_ar_gta_enabled := fnd_profile.VALUE(NAME => 'AR_GTA_ENABLED');

  IF (l_ar_gta_enabled IS NULL)
     OR --The profile AR:Golden Tax Enabled is Null or set to 'N'
     (l_ar_gta_enabled = 'N')
  THEN

    --Display error message
    fnd_message.set_name('AR'
                        ,'AR_GTA_GTA_NOT_ENABLE');
    l_ar_gta_not_enabled_msg := fnd_message.get;
    SELECT xmlelement("DiscrepancyReport"
                      ,xmlforest('Y' AS "ReportFailed"
                                ,l_ar_gta_not_enabled_msg AS
                                "ReportFailedMsg"
                                ,'N' AS "FailedWithParameters"))
    INTO   l_report_xml
    FROM   dual;

    --output error message to concurrent output
    fnd_file.put_line(fnd_file.output
                     ,l_report_xml.getstringval());

    --Set concurrent status to 'WARNING'
    l_conc_succ := fnd_concurrent.set_completion_status(status  => 'WARNING'
                                                       ,message => l_ar_gta_not_enabled_msg);
  ELSE
    --To get org id of current session
    l_org_id:=MO_GLOBAL.Get_Current_Org_Id;

    --To call discrepancy report main program
    ar_gta_reports_pkg.generate_discrepancy_rep(p_org_id              => l_org_id
                                                ,p_gta_batch_num_from  => p_gta_batch_num_from
                                                ,p_gta_batch_num_to    => p_gta_batch_num_to
                                                ,p_ar_transaction_type => p_ar_transaction_type
                                                ,p_cust_num_from       => p_cust_num_from
                                                ,p_cust_num_to         => p_cust_num_to
                                                ,p_cust_name_id        => p_cust_name_id
                                                ,p_gl_period           => p_gl_period
                                                ,p_gl_date_from        => p_gl_date_from
                                                ,p_gl_date_to          => p_gl_date_to
                                                ,p_ar_trx_batch_from   => p_ar_trx_batch_from
                                                ,p_ar_trx_batch_to     => p_ar_trx_batch_to
                                                ,p_ar_trx_num_from     => p_ar_trx_num_from
                                                ,p_ar_trx_num_to       => p_ar_trx_num_to
                                                ,p_ar_trx_date_from    => p_ar_trx_date_from
                                                ,p_ar_trx_date_to      => p_ar_trx_date_to
                                                ,p_ar_doc_num_from     => p_ar_doc_num_from
                                                ,p_ar_doc_num_to       => p_ar_doc_num_to
                                                ,p_original_curr_code  => p_original_curr_code
                                                ,p_primary_sales       => p_primary_sales);
  END IF; --(l_ar_gta_enabled IS NULL) OR  (l_ar_gta_enabled='N')

  --log for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || '.' || l_procedure_name || '.end'
                  ,'Exit procedure');
  END IF; --( l_proc_level >= l_dbg_level )

EXCEPTION
  WHEN OTHERS THEN
    IF (fnd_log.level_unexpected >= l_dbg_level)
    THEN
      fnd_log.STRING(fnd_log.level_unexpected
                  ,g_module_prefix || l_procedure_name ||
                   '.OTHER_EXCEPTION '
                  ,SQLCODE || SQLERRM);
    END IF;

    RAISE;

END discrepancy_report;

--==========================================================================
--  PROCEDURE NAME:
--
--    Item_Export                     Public
--
--  DESCRIPTION:
--
--     This procedure is to export item information to a flat file
--
--  PARAMETERS:
--      In:    p_master_org_id           Identifier of INV master organization
--             p_item_num_from           Item number low range
--             p_item_num_to             Item number high range
--             p_category_set_id         Identifier of item category set
--             p_category_structure_id   Structure id of item category
--             p_item_category_from      Item category low range
--             p_item_category_to        Item category high range
--             p_item_name_source Source to deciede where item name is gotten
--             p_dummy                   Dummy parameter
--             p_cross_reference_type    Cross reference
--             p_item_status             Status of an item
--             p_creation_date_from      Item creation date low range
--             p_creation_date_to        Item creation date high range
--
--     Out:  errbuf
--           retcode
--
--  DESIGN REFERENCES:
--     GTA-Txt-Interface-TD.doc
--
--  CHANGE HISTORY:
--
--           13-Jun-2005: Donghai Wang  Created
--           06-Mar-2006: Donghai Wang  Add fnd log
--
--==========================================================================
PROCEDURE item_export
(errbuf                  OUT NOCOPY VARCHAR2
,retcode                 OUT NOCOPY VARCHAR2
,p_master_org_id         IN         NUMBER
,p_item_num_from         IN         VARCHAR2
,p_item_num_to           IN         VARCHAR2
,p_category_set_id       IN         NUMBER
,p_category_structure_id IN         NUMBER
,p_item_category_from    IN         VARCHAR2
,p_item_category_to      IN         VARCHAR2
,p_item_name_source      IN         VARCHAR2
,p_dummy                 IN         VARCHAR2
,p_cross_reference_type  IN         VARCHAR2
,p_item_status           IN         VARCHAR2
,p_creation_date_from    IN         VARCHAR2
,p_creation_date_to      IN         VARCHAR2
)
IS
l_procedure_name          VARCHAR2(50);
l_ar_gta_enabled         VARCHAR2(10);
l_dbg_msg                 VARCHAR2(500);
l_ar_gta_not_enabled_msg VARCHAR2(1000);
l_dbg_level               NUMBER                                          := fnd_log.g_current_runtime_level;
l_proc_level              NUMBER                                          := fnd_log.level_procedure;
l_org_id                  hr_all_organization_units.organization_id%TYPE;
l_conc_succ               BOOLEAN;

BEGIN
  l_procedure_name := 'Item_Export';
  --log for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || '.' || l_procedure_name || '.begin'
                  ,'Enter procedure');

    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || '.' || l_procedure_name || '.parameters'
                  ,'p_master_org_id '||p_master_org_id);

    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || '.' || l_procedure_name || '.parameters'
                  ,'p_item_num_from '||p_item_num_from);

    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || '.' || l_procedure_name || '.parameters'
                  ,'p_item_num_to '||p_item_num_to);

    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || '.' || l_procedure_name || '.parameters'
                  ,'p_category_set_id '||p_category_set_id);

    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || '.' || l_procedure_name || '.parameters'
                  ,'p_category_structure_id '||p_category_structure_id);

    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || '.' || l_procedure_name || '.parameters'
                  ,'p_item_category_from '||p_item_category_from);

    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || '.' || l_procedure_name || '.parameters'
                  ,'p_item_category_to '||p_item_category_to);

    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || '.' || l_procedure_name || '.parameters'
                  ,'p_item_name_source '||p_item_name_source);

    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || '.' || l_procedure_name || '.parameters'
                  ,'p_dummy '||p_dummy);

    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || '.' || l_procedure_name || '.parameters'
                  ,'p_cross_reference_type '||p_cross_reference_type);

    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || '.' || l_procedure_name || '.parameters'
                  ,'p_item_status '||p_item_status);

    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || '.' || l_procedure_name || '.parameters'
                  ,'p_creation_date_from '||p_creation_date_from);

    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || '.' || l_procedure_name || '.parameters'
                  ,'p_creation_date_to '||p_creation_date_to);


  END IF; --( l_proc_level >= l_dbg_level )

  --To Get value of profile AR:Golden Tax Enabled
  l_ar_gta_enabled := fnd_profile.VALUE(NAME => 'AR_GTA_ENABLED');

  IF (l_ar_gta_enabled IS NULL)
     OR --The profile AR:Golden Tax Enabled is Null or set to 'N'
     (l_ar_gta_enabled = 'N')
  THEN

    --Display error message
    fnd_message.set_name('AR'
                        ,'AR_GTA_GTA_NOT_ENABLE');
    l_ar_gta_not_enabled_msg := fnd_message.get;
    fnd_file.put_line(fnd_file.output
                     ,l_ar_gta_not_enabled_msg);

    --Set concurrent status to 'WARNING'
    l_conc_succ := fnd_concurrent.set_completion_status(status  => 'WARNING'
                                                       ,message => l_ar_gta_not_enabled_msg);
  ELSE

    --To get org id of current session
    l_org_id:=MO_GLOBAL.Get_Current_Org_Id;

    --To call item export main program
    ar_gta_txt_operator_proc.export_items(p_org_id                => l_org_id
                                          ,p_master_org_id         => p_master_org_id
                                          ,p_item_num_from         => p_item_num_from
                                          ,p_item_num_to           => p_item_num_to
                                          ,p_category_set_id       => p_category_set_id
                                          ,p_category_structure_id => p_category_structure_id
                                          ,p_item_category_from    => p_item_category_from
                                          ,p_item_category_to      => p_item_category_to
                                          ,p_item_name_source      => p_item_name_source
                                          ,p_cross_reference_type  => p_cross_reference_type
                                          ,p_item_status           => p_item_status
                                          ,p_creation_date_from    => p_creation_date_from
                                          ,p_creation_date_to      => p_creation_date_to);
  END IF; --(l_ar_gta_enabled IS NULL) OR (l_ar_gta_enabled='N')

  --log for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || '.' || l_procedure_name || '.end'
                  ,'Exit procedure');
  END IF; --( l_proc_level >= l_dbg_level )

EXCEPTION
  WHEN OTHERS THEN
    IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)
    THEN
      fnd_log.STRING(fnd_log.level_unexpected
                    ,g_module_prefix || l_procedure_name ||
                     '. OTHER_EXCEPTION '
                    ,'Unknown error' || SQLCODE || SQLERRM);

    END IF;
    RAISE;

END item_export;

--==========================================================================
--  PROCEDURE NAME:
--
--    Transfer_Customers_To_GT                     Public
--
--  DESCRIPTION:
--
--     This procedure convert AR customers information into a flat file
--
--  PARAMETERS:
--      In:    p_customer_num_from             IN         VARCHAR2
--             p_customer_num_to               IN         VARCHAR2
--             p_customer_name_from            IN         VARCHAR2
--             p_customer_name_to              IN         VARCHAR2
--             p_taxpayee_id                   IN         VARCHAR2
--             p_creation_date_from            IN         VARCHAR2
--             p_creation_date_to              IN         VARCHAR2
--
--     Out:  errbuf
--           retcode
--
--  DESIGN REFERENCES:
--     GTA-Txt-Interface-TD.doc
--
--  CHANGE HISTORY:
--
--          20-MAY-2005: Jim.Zheng   Created.
--          26_Jun-005   Jim Zheng   update , chanage the Date parameter to Varchar2
--          16-Nov-2005  Jim Zheng   update , change the output of gta_not_enable
--==========================================================================
PROCEDURE transfer_customers_to_gt
(errbuf               OUT NOCOPY VARCHAR2
,retcode              OUT NOCOPY VARCHAR2
,p_customer_num_from  IN         VARCHAR2
,p_customer_num_to    IN         VARCHAR2
,p_customer_name_from IN         VARCHAR2
,p_customer_name_to   IN         VARCHAR2
--,p_taxpayee_id        IN         VARCHAR2
,p_creation_date_from IN         VARCHAR2
,p_creation_date_to   IN         VARCHAR2
)
IS

l_ar_gta_gta_not_enabled VARCHAR2(1000);
l_procedure_name          VARCHAR2(50) := 'transfer_customers_to_GT';
l_conc_succ               BOOLEAN;
l_org_id                  NUMBER := mo_global.get_current_org_id;
BEGIN
  -- procedure  begin
  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
  THEN
    fnd_log.STRING(fnd_log.level_procedure
                  ,g_module_prefix || l_procedure_name
                  ,'Begin Procedure. ');
  END IF; /*FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL*/

  IF (fnd_profile.VALUE('AR_GTA_ENABLED') = 'Y')
  THEN
    ar_gta_txt_operator_proc.export_customers(p_org_id             => l_org_id
                                              ,p_customer_num_from  => p_customer_num_from
                                              ,p_customer_num_to    => p_customer_num_to
                                              ,p_customer_name_from => p_customer_name_from
                                              ,p_customer_name_to   => p_customer_name_to
                                              --,p_taxpayee_id        => p_taxpayee_id
                                              ,p_creation_date_from => fnd_date.canonical_to_date(p_creation_date_from)
                                              ,p_creation_date_to   => fnd_date.canonical_to_date(p_creation_date_to));

  ELSE
    /*FND_PROFILE.VALUE('GTA_ENABLED')='Y'*/
    -- report AR_GTA_DISABLE_ERROR in xml format
    -- set concurrent status to WARNING
    fnd_message.set_name('AR'
                        ,'AR_GTA_GTA_NOT_ENABLE');
    l_ar_gta_gta_not_enabled := fnd_message.get;

    fnd_file.put_line(fnd_file.output
                     ,l_ar_gta_gta_not_enabled);

    l_conc_succ := fnd_concurrent.set_completion_status(status  => 'WARNING'
                                                       ,message => l_ar_gta_gta_not_enabled);
    RETURN;
  END IF; /*FND_PROFILE.VALUE('GTA_ENABLED')='Y'*/
  -- procedure end
  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
  THEN
    fnd_log.STRING(fnd_log.level_procedure
                  ,g_module_prefix || l_procedure_name
                  ,'End Procedure. ');
  END IF; /*FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL*/

EXCEPTION
  WHEN OTHERS THEN
    IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)
    THEN
      fnd_log.STRING(fnd_log.level_unexpected
                    ,g_module_prefix || l_procedure_name ||
                     '. OTHER_EXCEPTION '
                    ,'Unknown error' || SQLCODE || SQLERRM);

    END IF;
    RAISE;
END transfer_customers_to_gt;
--=============================================================================
-- PROCEDURE NAME:
--                Consolidate_Invoices
-- TYPE:
--                PUBLIC
--
-- DESCRIPTION: This is the entrance procedure to merge invoice.
--
-- PARAMETERS:
--           IN :    p_same_pri_same_dis  same price and same discoout
--                   p_same_pri_diff_dis  same price with different discount
--                   p_diff_pri           different price
--                   p_sales_list_flag    salese_list_flag
--                   p_consolidation_id     consolidation id
--
-- HISTORY:
--                 30-Jun-2009 : Yao Zhang Create
--                 08-Aug-2009 : Yao Zhang Modified for bug#8770356
--=============================================================================
PROCEDURE Consolidate_Invoices
(errbuf         OUT NOCOPY VARCHAR2
,retcode        OUT NOCOPY VARCHAR2
,p_consolidation_id    IN NUMBER
,p_same_pri_same_dis IN VARCHAR2
,p_same_pri_diff_dis IN	VARCHAR2
,p_diff_pri          IN VARCHAR2
,p_sales_list_flag   IN VARCHAR2
,p_org_id            IN NUMBER --Yao Zhang add for bug#8770356
)
IS
l_procedure_name             VARCHAR2(30):='Consolidate_Invoices';
l_ar_gta_gta_not_enabled    Varchar2(200);
l_conc_succ                  BOOLEAN;
l_consol_paras               ar_gta_trx_util.consolparas_rec_type;


BEGIN
 fnd_file.PUT_LINE(fnd_file.LOG,'Begin Procedure.'||l_procedure_name);
  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||'.'|| l_procedure_name
                  ,'Begin Procedure. ');
  END IF;
  IF (fnd_profile.VALUE('AR_GTA_ENABLED') = 'Y')
  THEN
    l_consol_paras.consolidation_id    := p_consolidation_id;
    l_consol_paras.same_pri_same_dis := p_same_pri_same_dis;
    l_consol_paras.same_pri_diff_dis := p_same_pri_diff_dis;
    l_consol_paras.diff_pri          := p_diff_pri;
    l_consol_paras.sales_list_flag   := p_sales_list_flag;
    l_consol_paras.org_id            := p_org_id;--Yao Zhang add for bug#8770356

    --consolidate invoices
    AR_GTA_CONSOLIDATE_PROC.Create_consol_inv(p_consolidation_paras=>l_consol_paras);
    --generate xml output
    AR_GTA_CONSOLIDATE_PROC.Generate_XML_Output(p_consolidation_paras=>l_consol_paras);

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
      fnd_log.STRING(fnd_log.level_procedure
                    ,g_module_prefix || l_procedure_name
                    ||'. OTHER_EXCEPTION ',
                       'Unknown error' || SQLCODE || SQLERRM);
    END IF;

  ELSE
    -- report AR_GTA_DISABLE_ERROR in xml format
    -- set concurrent status to WARNING
    fnd_message.set_name('AR'
                        ,'AR_GTA_GTA_NOT_ENABLE');
    l_ar_gta_gta_not_enabled := '<ConsolidationReport>
                                  <ReportFailed>Y</ReportFailed>
                                  <ReportFailedMsg>' ||
                                  fnd_message.get ||
                                  '</ReportFailedMsg>
                                  <FailedWithParameters>Y</FailedWithParameters>
                                  </ConsolidationReport>';

    fnd_file.put_line(fnd_file.output
                     ,l_ar_gta_gta_not_enabled);

    l_conc_succ := fnd_concurrent.set_completion_status(status  => 'WARNING'
                                                       ,message => l_ar_gta_gta_not_enabled);
    RETURN;
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
END;

--=============================================================================
-- PROCEDURE NAME:
--                Run_Consolidation_Mapping
-- TYPE:
--                PUBLIC
--
-- DESCRIPTION: This is the entrance procedure for invoice consolidation mapping report.
--
-- PARAMETERS:
--           IN :    p_gl_period              GL period
--                   p_customer_num_from      customer number from
--                   p_customer_num_to        customer number to
--                   p_customer_name_from     customer name from
--                   p_customer_name_to       customer name to
--                   p_consol_trx_num_from    consolidated invoice number from
--                   p_consol_trx_num_to      consolidated invoice number to
--                   p_invoice_type           invoice type
--
-- HISTORY:
--                 25-Jul-2009 : Allen Yang created
--                 02-Sep-2009 : Allen Yang modified for bug 8848798
--=============================================================================
PROCEDURE Run_Consolidation_Mapping
(errbuf                 OUT NOCOPY VARCHAR2
,retcode                OUT NOCOPY VARCHAR2
,p_gl_period            IN VARCHAR2
,p_customer_num_from    IN VARCHAR2
,p_customer_num_to      IN VARCHAR2
,p_customer_name_from   IN VARCHAR2
,p_customer_name_to     IN VARCHAR2
,p_consol_trx_num_from  IN VARCHAR2
,p_consol_trx_num_to    IN VARCHAR2
,p_invoice_type         IN VARCHAR2
)
IS
l_procedure_name          VARCHAR2(30) := 'Run_Consolidation_Mapping';
l_ar_gta_enabled         fnd_profile_option_values.profile_option_value%TYPE := NULL;
l_ar_gta_gta_not_enabled VARCHAR2(500);
l_report                  xmltype;
l_parameter               xmltype;
l_dbg_msg                 VARCHAR2(500);
l_dbg_level               NUMBER := fnd_log.g_current_runtime_level;
l_proc_level              NUMBER := fnd_log.level_procedure;
l_org_id                  NUMBER := mo_global.get_current_org_id;
l_conc_succ               BOOLEAN;


BEGIN
  --logging for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || l_procedure_name || '.begin'
                  ,'enter procedure');
  END IF;

  fnd_profile.get('AR_GTA_ENABLED', l_ar_gta_enabled);

  IF NVL(l_ar_gta_enabled ,'N') = 'N'
  THEN
    /* commented by Allen Yang 02-Sep-2009 for bug 8848798
    SELECT xmlelement("Parameters"
                     ,xmlforest(ar_gta_trx_util.get_operatingunit(l_org_id)
                                                        AS "OperationUnit"
                              , p_gl_period             AS "GLPeriod"
                              , p_customer_num_from     AS "CustomerNumFrom"
                              , p_customer_num_to       AS "CustomerNumTo"
                              , p_customer_name_from    AS "CustomerNameFrom"
                              , p_customer_name_to      AS "CustomerNameTo"
                              , p_consol_trx_num_from   AS "ConsolidationTrxNumFrom"
                              , p_consol_trx_num_to     AS "ConsolidationTrxNumTo"
                              , p_invoice_type          AS "InvoiceType"))
    INTO    l_parameter
    FROM    dual;
    */
    fnd_message.set_name('AR', 'AR_GTA_GTA_NOT_ENABLE');
    -- modified by Allen Yang 02-Sep-2009 for bug 8848798
    ------------------------------------------------------------------------
    /*
    l_ar_gta_gta_not_enabled := fnd_message.get();
    -- Output the context of l_ar_gta_gta_not_enabled
    SELECT xmlelement("MappingReport"
                      ,xmlconcat(xmlelement("ReportFailed", 'Y')
                      ,xmlelement("FailedWithParameters",'N')
                      ,xmlelement("RepDate",ar_gta_trx_util.To_Xsd_Date_String(SYSDATE))
                      ,xmlelement("ReportFailedMsg",l_ar_gta_gta_not_enabled)
                      ,l_parameter))
    INTO   l_report
    FROM   dual;

    ar_gta_trx_util.output_conc(l_report.getclobval());
    */
    l_ar_gta_gta_not_enabled := '<ConsolidationMappingReport>
                                  <ReportFailed>Y</ReportFailed>
                                  <FailedWithParameters>Y</FailedWithParameters>
                                  <FailedMsgWithParameters>' ||
                                  fnd_message.get ||
                                  '</FailedMsgWithParameters>
                                  </ConsolidationMappingReport>';
    fnd_file.put_line(fnd_file.output
                     ,l_ar_gta_gta_not_enabled);
    --------------------------------------------------------------------------
    l_conc_succ := fnd_concurrent.set_completion_status(status  => 'WARNING'
                                                       ,message => l_ar_gta_gta_not_enabled);
  ELSE
    ar_gta_reports_pkg.Generate_Consol_Mapping_Rep
    (p_org_id              => l_org_id
   , p_gl_period           => p_gl_period
   , p_customer_num_from   => p_customer_num_from
   , p_customer_num_to     => p_customer_num_to
   , p_customer_name_from  => p_customer_name_from
   , p_customer_name_to    => p_customer_name_to
   , p_consol_trx_num_from => p_consol_trx_num_from
   , p_consol_trx_num_to   => p_consol_trx_num_to
   , p_invoice_type        => p_invoice_type);
  END IF; --NVL(l_ar_gta_enabled ,'N') = 'N'

  --logging for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    fnd_log.STRING(l_proc_level
                  ,g_module_prefix || l_procedure_name || '.end'
                  ,'end procedure');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF fnd_log.level_unexpected >= l_dbg_level
    THEN
      fnd_log.STRING(fnd_log.level_unexpected
                  ,g_module_prefix || l_procedure_name || '.OTHER_EXCEPTION'
                  ,SQLCODE || SQLERRM);
    END IF;
    RAISE;
END Run_Consolidation_Mapping;

--==========================================================================
--  PROCEDURE NAME:
--
--    Populate_Invoice_Type                     Public
--
--  DESCRIPTION:
--
--     In R12.1.1, there were 2 sql files need be manually run to migrate the
--     setup and transaction data from GTA 12.0 to GTA 12.1.
--     In R12.1.2, we convert this two sql into concurrent programs which
--     can be run by user from UI.
--     This procedure is to populate data to INVOICE_TYPE column for
--     Transfer Rule and System Option tables.
--  PARAMETERS:
--      In:
--
--     Out:  errbuf
--           retcode
--
--  DESIGN REFERENCES:
--     GTA_12.1.2_Technical_Design.doc
--
--  CHANGE HISTORY:
--
--           16-Aug-2009: Allen Yang   Created
--
--===========================================================================
PROCEDURE Populate_Invoice_Type
(errbuf  OUT NOCOPY VARCHAR2
,retcode OUT NOCOPY VARCHAR2
)
IS
l_procedure_name          VARCHAR2(30) := 'Populate_Invoice_Type';
l_ar_gta_gta_not_enabled VARCHAR2(300);
l_conc_succ               BOOLEAN;

l_org_id                  NUMBER := mo_global.get_current_org_id;

BEGIN
  --procedure begin
  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
  THEN
    fnd_log.STRING(fnd_log.level_procedure
                  ,g_module_prefix || l_procedure_name || '.begin'
                  ,'Procedure begin');
  END IF;

  IF fnd_profile.VALUE('AR_GTA_ENABLED') = 'N'
  THEN
    fnd_message.set_name('AR'
                        ,'AR_GTA_GTA_NOT_ENABLE');

    l_ar_gta_gta_not_enabled := fnd_message.get;

    -- Output the context of l_ar_gta_gta_not_enabled
    fnd_file.put_line(fnd_file.output
                     ,l_ar_gta_gta_not_enabled);
    l_conc_succ := fnd_concurrent.set_completion_status(status  => 'WARNING'
                                                       ,message => l_ar_gta_gta_not_enabled);

    RETURN;
  END IF;

  ar_gta_trx_util.Populate_Invoice_Type(l_org_id);

  --procedure end
  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
  THEN
    fnd_log.STRING(fnd_log.level_procedure
                  ,g_module_prefix || l_procedure_name || '.end'
                  ,'Procedure end');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)
    THEN
      fnd_log.STRING(fnd_log.level_unexpected
                    ,g_module_prefix || l_procedure_name ||
                     '.OTHER_EXCEPTION '
                    ,SQLCODE || SQLERRM);
    END IF;
    RAISE;
END Populate_Invoice_Type;

--==========================================================================
--  PROCEDURE NAME:
--
--    Populate_Invoice_Type_Header                     Public
--
--  DESCRIPTION:
--
--     In R12.1.1, there were 2 sql files need be manually run to migrate the
--     setup and transaction data from GTA 12.0 to GTA 12.1.
--     In R12.1.2, we convert this two sql into concurrent programs which
--     can be run by user from UI.
--     This procedure is to populate data to INVOICE_TYPE column for
--     GTA Invoice Header table.
--  PARAMETERS:
--      In:
--
--     Out:  errbuf
--           retcode
--
--  DESIGN REFERENCES:
--     GTA_12.1.2_Technical_Design.doc
--
--  CHANGE HISTORY:
--
--           16-Aug-2009: Allen Yang   Created
--
--===========================================================================
PROCEDURE Populate_Invoice_Type_Header
(errbuf  OUT NOCOPY VARCHAR2
,retcode OUT NOCOPY VARCHAR2
)
IS
l_procedure_name          VARCHAR2(30) := 'Populate_Invoice_Type_Header';
l_ar_gta_gta_not_enabled VARCHAR2(300);
l_conc_succ               BOOLEAN;

l_org_id                  NUMBER := mo_global.get_current_org_id;

BEGIN
  --procedure begin
  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
  THEN
    fnd_log.STRING(fnd_log.level_procedure
                  ,g_module_prefix || l_procedure_name || '.begin'
                  ,'Procedure begin');
  END IF;

  IF fnd_profile.VALUE('AR_GTA_ENABLED') = 'N'
  THEN
    fnd_message.set_name('AR'
                        ,'AR_GTA_GTA_NOT_ENABLE');

    l_ar_gta_gta_not_enabled := fnd_message.get;

    -- Output the context of l_ar_gta_gta_not_enabled
    fnd_file.put_line(fnd_file.output
                     ,l_ar_gta_gta_not_enabled);
    l_conc_succ := fnd_concurrent.set_completion_status(status  => 'WARNING'
                                                       ,message => l_ar_gta_gta_not_enabled);

    RETURN;
  END IF;

  ar_gta_trx_util.Populate_Invoice_Type_Header(l_org_id);

  --procedure end
  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
  THEN
    fnd_log.STRING(fnd_log.level_procedure
                  ,g_module_prefix || l_procedure_name || '.end'
                  ,'Procedure end');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)
    THEN
      fnd_log.STRING(fnd_log.level_unexpected
                    ,g_module_prefix || l_procedure_name ||
                     '.OTHER_EXCEPTION '
                    ,SQLCODE || SQLERRM);
    END IF;
    RAISE;
END Populate_Invoice_Type_Header;

END AR_GTA_CONC_PROG;

/
