--------------------------------------------------------
--  DDL for Package Body AR_GTA_ARTRX_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_GTA_ARTRX_PROC" AS
  --$Header: ARGRARTB.pls 120.0.12010000.5 2010/06/22 05:36:04 yaozhan noship $
  --+===========================================================================+
  --|                    Copyright (c) 2005 Oracle Corporation
  --|                      Redwood Shores, California, USA
  --|                            All rights reserved.
  --+===========================================================================
  --|
  --|  FILENAME :
  --|                    ARRARTB.pls
  --|
  --|  DESCRIPTION:
  --|                    This package provide the functionality to retrieve
  --|                    transaction data from Oracle Receivable against the
  --|                    condition defined in Setup Form.
  --|
  --|
  --|
  --|  HISTORY:
  --|                    20-APR-2005: Jim Zheng
  --|                    30-sep-2005: Jim zheng modify because registration
  --|                                 issue.
  --|                    10-Oct_2005: Jim Zheng. Fix a collection init bug
  --|                                 Add some log clause for UT debug.
  --|                    11-Oct-2005: Jim Zheng. add a procedure
  --|                    get_uom_name. Modify procedure Retrieve_AR_trxs
  --|                    19-Oct-2005: Jim Zheng. change select condition of get max amount when
  --|                                 the exception AR_GTA_UNITPRICE_ERROR.
  --|                                 change the source of orginal currency amount from AR line
  --|                                 to ebtax
  --|                                 add l_tax_rate/100 when get tax rate
  --|                                 change the type of item_number
  --|                    20-Oct-2005: Jim Zheng. add debug message into procedure Generate_XML_output
  --|                    21-Oct-2005: Jim Zheng add xml element in generate_XML_output
  --|                    16-Nov-2005: Jim zheng Remove the complete flag check in Get_AR_SQL
  --|                    24-Nov-2005: Jim Zheng Change the select condition period_type in procedure Get_AR_SQL
  --|                    28-Nov-2005: Jim Zheng Change the select sql for get pervious Cust_trx_id of Credit memo
  --|                                           Retrieve_AR_Trxs
  --|                    28-Nov-2005: Jim Zheng Add complete flag into Dynamic sql Get_AR_SQL.
  --|                    28-Nov-2005: Jim Zheng Fix a bug of 'missing right parenthesis' in procedure get_AR_flex_Cond
  --|                    28-Nov-2005: Jim ZHeng Delete the 'return' when exception in procedure get_AR_Currency_Cond
  --|                    28-Nov-2005: Jim Zheng Add select condition in procedure get_inventory_item_Number
  --|                                           Because the number of attribute is from 1 to 30
  --|                    29-Nov-2005: Jim Zheng Fix a code bug of when check third party regi number. Retrieve_AR_Trxs
  --|                    29-Nov-2005: Jim Zheng Add a where condition app.display = 'Y' to credit memo check.Retrieve_AR_Trxs
  --|                    30-Nov-2005: Jim Zheng Change message name from AR_GTA_CRMEMO_MISSING_ARINV to AR_GTA_CRMEMO_MULREF_ARINV
  --|                    30-Nov-2005: Jim Zheng change code for Credit memo, When there are 0 or >1 reference invoice in GTA.
  --|                                           Retrieve_AR_TRXs
  --|                    01-Dec-2005: Jim Zheng Add UOM and Quantity Check for AR transaction and Credit memo in procedure Retrieve_AR_Trxs
  --|                    01-Dec-2005: Jim Zheng Chenge exception status to Warning when reference inv is 0 or >1 in GTA
  --|                                           Retrieve_AR_TRXs
  --|                    02-Dec-2005: Jim Zheng Add a item id check in procedure get_inv_item_model
  --|                    02-Dec-2005: Jim Zheng Don't throw a exception when the FP regi number is not exist in system option.
  --|                    02-Dec-2005: Jim Zheng Change the Gta_row number for Sucessful not for all in procedure Generate_XML_output
  --|                    08-Dec-2005: Jim Zheng Verify message of Retrieve_AR_TRXs
  --|                    08-Dec-2005: Jim Zheng Add log for support
  --|                    15-Dec-2005: Jim Zheng add gta invoice number for XML output in procedure Generate_XML_output
  --|                    26-Dec-2005: Jim Zheng change code in percedure Retrieve_AR_TRXS for fix permance issue.
  --|                    20-Jan-2005: Jim Zheng update code for credit memo line quantity issue. the quantity of credit memo stored in
  --|                                           different column with invoice
  --|                    24-Jam-2005: Jim Zheng Update code for credit memo uT, The invocie source is 'GT' when it is imported
  --|                                               into GTA from GT
  --|                    17-Feb-2006: Jogen Hu  fix bug of error report when no AR transaction tax line (bug:5092042)
  --|                    21/03/2006   Jogen Hu  Change data range from trunc
  --|                                           parameters to DB columns by bug 5107043
  --|                    04/04/2006   Jogen Hu  Change Generate_XML_Output procedure
  --|                                           to add close unclosed cursor in bug 5135169
  --|                    12/04/2006   Jogen Hu   Add function get_gta_number and modify generate_xml_output
  --|                                            against bug 5144561
  --|                    17/04/2006   Jogen Hu   Change Generate_XML_Output procedure: "CurreneyCode"->"CurrencyCode"
  --|                                            against bug 5168003
  --|                    09/06/2006 Shujuan Yan Change the token value from
  --|                               AR_GTA_UNITPRICE_ERROR to
  --|                               AR_GTA_UNITPRICE_EXCEED in the procedure
  --|                               Retrieve_AR_TRXs for bug 5263215
  --|                    09/06/2006 Shujuan Yan Add transaction number to GTA
  --|                               invoice description in the procedure
  --|                               Retrieve_AR_TRXs for bug 5255993
  --|                    11/06/2006 Shujuan Yan Change message code from
  --|                               AR_GTA_CRMEMO_MISSING_ARINV to
  --|                               AR_GTA_CRMEMO_MISSING_GTINV in the
  --|                               procedure Retrieve_AR_TRXs for bug 5263308
  --|                    11/06/2006 Shujuan Yan Delete the process when else
  --|                               l_item_inventry_id is not null in the
  --|                               procedure Retrieve_AR_TRXs for bug 5224923
  --|                    12/06/2006 Shujuan Yan Modify the procedure
  --|                               Retrieve_AR_TRXs, Get line_number from
  --|                               ra_customer_trx_lines_all, Change Change
  --|                               the token value by "fnd_message.set_token
  --|                               ('NUM', l_customer_trx_line_number)"
  --|                               instead of "fnd_message.set_token('NUM',
  --|                               l_customer_trx_line_id)" for bug 5230712
  --|                    12/06/2006 Shujuan Yan Modify the procedure Retrieve
  --|                               _AR_TRXs, Change the token value by
  --|                               "fnd_message.set_token('ITEM', l_inventory
  --|                               _item_name )" instead of "fnd_message.set
  --|                               _token('ITEM', l_inventory_item_id)" for
  --                                bug 5230712
  --|                    29/06/2006 Shujuan Yan Modify the procedure Retrieve
  --|                               _AR_TRXs,Add if l_ctt_class = 'CM' clause,
  --|                               when transaction type is credit memo, get
  --|                               the bank information according to the
  --|                               corresponding invoice for bug 5263131
  --|                    29/06/2006 Shujuan Yan Modify the procedure Retrieve
  --|                               _AR_TRXs, Get line_number from ra_customer
  --|                               _trx_lines_all, Change the token value by
  --|                               "fnd_message.set_token('NUM', l_customer_
  --|                               trx_line_number)" instead of "fnd_message
  --|                               .set_token('NUM', l_customer_trx_line_id)"
  --|                               for bug 5258522
  --|                    29/06/2006 Shujuan Yan Modify Retrieve_AR_TRXs, get l_
  --|                               tax_curr_unit_price from procedure Get_Info
  --|                               _From_Ebtax of package AR_GTA_TRX_UTIL, and
  --|                               compare it with max amount for bug 5168900.
  --|                    12/07/2006 Shujuan Yan Added l_trx_line.item_description
  --|                               := l_description when l_item_inventry_id is
  --|                               null in the procedure Retrieve_AR_TRXs
  --|                               for bug 5224923
  --|                    20/07/2006 Shujuan Yan Added the length of
  --|                               l_inventory_item_name from 60 characters to
  --|                               240 characters for bug 5400805.
  --|                    08/08/2006 Shujuan Yan Modify Retrieve_AR_TRXs,
  --|                               the variable unit_price should  be assigned
  --|                               the unit price of GTA currency for 5446456
  --|                    08/09/2006 Shujuan Yan in procedure Get_AR_FLEX_COND,
  --|                               Added the sql condition 'l_ATTRIBUTE_COLUMN
  --|                               IS NULL'for bug 5443909
  --|                    28/12/2007 Subba, Added the new procedure 'Get_Invoice_Type'.
  --|                               This procedure returns the WHERE clause about
  --|                               Invoice Type using the
  --|                               Invoice Type,Transaction Type mapping
  --|                               relationship defined in GTA System Option Form.
  --|                    24/11/2008 Brian, Disable the validation that Credit memo must
  --|                               be associated with a VAT invoice for bug 7591365
  --|                               This change is compliance with GT 6.10.
  --|                    25/11/2008 Brian,Remove the Credit Memo from the validation that
  --|                               UOM cannot be null for the invoice line for bug 7594218
  --|                    10/12/2008 Yao Zhang fix bug 7629877. Remove Credit Memo validation for Special
  --|                               and Recycle VAT.For Common VAT, Credit Memo Validation followed the following rules.
  --|                               1 On account Credit Memo can be transferd to GTA with warning
  --|                               2 Credit Memo credited with AR invoice which is not transfered to GTA can not be transfered
  --|                               3 Credit Memo credited with AR invoice which is transfered to GTA with split can be transfered with warning.
  --|                               4 Credit Memo credited with AR invoice which is transfered to GTA without split
  --|                                 can be transfered only when the GTA invoice is generated for the AR invoice.
  --|                               Remove the validation that the UOM and Quantity cannot be null
  --|                               for all the transactions.
  --|                    16/12/2008 Yao Zhang fix bug 7644235 CreditMemo should not be transfered or splited when
  --|                               exceed the limition of max amount or max lines.
  --|                    24/12/2008 Yao Zhang fix bug 7667709 AR transfer to GTA program completed with warning,and output file
  --|                               has error about:'The following tags were not closed: TransferReport'
  --|                    26/12/2008 Yao Zhang fix bug 7670543 CM CREDITING A INV THAT HAS COMPLETED WITHOUT SPLIT CANNOT BE TRANSFERRED
  --|                    30/12/2008 Yao Zhang fix bug 7675165 CREDIT MEMO TRANSFER TOG TA,THE WARNING MESSAGE IS DUPLICATED.
  --|                    05/01/2009 Yao Zhang fix bug 7684662 COMMON CM CAN BE TRANSFERED WITHOUT WARNING WHEN SEVERAL CMS TRANSFERED TOGETHER
  --|                    06/01/2009 Yao Zhang fix bug 7685610 Description cannot correctly be populated by
  --|                               transfer program for the credit memo reference to Common VAT invoice, which
  --|                               original transaction has been transferred to GTA without splitting and
  --|                               corresponding GT invoice has been transferred back to GTA.
  --|                    20/Jan/2009 Yao Zhang fix bug 7721035 RECEIVABLE TO GOLDEN TAX INVOICE TRANSFER FAILED
  --|                    22/Jan/2009 Yao Zhang fix bug 	7829039 ITEM NAME ON GTA INVOICE LINE IS NULL
  --|                    23/jan/2009 Yao Zhang fix bug  7758496 CreditMemo whose line num exceeds max line number limitation
  --|                                                              should be transfered when sales list is enabled
  --|                    01-ARP-2009 Yao Zhang Fix bug 8234250,Modifiy bank information getting logic
  --|                                                          for Credit Memo.
  --|                    02-APR-2009 Yao Zhang Fix bug 8241752 CM WITH MULTI LINES,TRANSFERRED TO GTA with WARING DUPLICATE
  --|                    28-APR-2009 Yao Zhang Fix bug 7832675 WHEN AR FOREIGN CURRECY TRANSACTION TO GTA,
  --|                                                          EXCHANGE RATE and EXCHANGE RATE TYPE IS NULL
  --|                    16-Jun-2009 Yao Zhang Fix bug#8605196 ENHANCEMENT FOR GOLDEN TAX ADAPTER R12.1.2
  --|                                                          ER1 Support discount lines
  --|                                                          ER2 Support customer name,address,bank info in Chinese
  --|                    18-Aug-2009 Yao Zhang Fix bug#8769687 CUSTOMER PHONE NUMBER IS NOT PUBLISHED AFTER TRANSFERRED TO GTA
  --|                    19-Aug-2009 Yao Zhang Fix bug#8809860 'Continue' can not be used in pl/sql package
  --|                    21-Sep-2009 Yao Zhang Fix bug#8920239 TRANSFER RECYCLE INVOICE WITH DISCOUNT WITH ERROR
  --|                    18-Nov-2009 Yao Zhang Fix bug#9045187 CREDIT MEMO WITH DISCOUNT AMOUNT TRANSFER AMOUNT LIMIT ISSUE
  --|                    20-Nov-2009 Yao Zhang Fix bug#9132371 DISCOUNT AMOUNT IS NOT EXCHANGED IN FOREIGN CURRENCY GTA INVOICE
  --|                    22-Jun-2010 Yao fix bug#9830678 when OE_DISCOUNT_DETAILS_ON_INVOICE is set to 'No', sales order with
  --|                                                    discount failed to transfer to GTA.
  --+===========================================================================+

  --=============================================================================
  --  PROCEDURE NAME:
  --         log
  --  TYPE:
  --         private
  --
  --  DESCRIPTION :
  --         This procedure log message
  --  PARAMETERS    :
  --                p_level   IN VARCHAR2
  --                p_module  IN VARCHAR2
  --                p_message IN VARCHAR2
  --
  -- HISTORY:
  --            10-MAY-2005 : Jim.Zheng  Create
  --=============================================================================
  PROCEDURE log(p_level   IN VARCHAR2,
                p_module  IN VARCHAR2,
                p_message IN VARCHAR2) IS
  BEGIN
    IF (p_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.STRING(LOG_LEVEL => p_level,
                     MODULE    => p_module,
                     MESSAGE   => p_message);
    END IF;
  END;

  --==========================================================================
  --  PROCEDURE NAME:
  --               retrive_valid_AR_TRXs
  --
  --  DESCRIPTION:
  --               This procedure is for invoices transfer concurrent
  --               implementation from Receivable to GTA
  --
  --  PARAMETERS:
  --               In: P_ORG_ID            NUMBER
  --                   P_transfer_rule     NUMBER
  --                   p_conc_parameters   AR_GTA_TRX_UTIL.transferParas_rec_type
  --                   p_DEBUG             VARCHAR2
  --               OUT: errbuf             varchar2
  --                    retcode            VARCHAR2

  --  DESIGN REFERENCES:
  --               GTA-TRANSFER-PROGRAM-TD.doc
  --
  --  CHANGE HISTORY:
  --               20-APR-2005: Jim Zheng   Created.
  --===========================================================================
  PROCEDURE Transfer_AR_To_GTA(errbuf            OUT NOCOPY VARCHAR2,
                               retcode           OUT NOCOPY VARCHAR2,
                               p_org_id          IN NUMBER,
                               p_transfer_id     IN NUMBER,
                               p_conc_parameters IN AR_GTA_TRX_UTIL.transferParas_rec_type) IS
    l_procedure_name   VARCHAR2(30) := 'transfer_AR_to_GTA';
    l_gta_trx_tbl_4ar  ar_gta_trx_util.trx_tbl_type := ar_gta_trx_util.trx_tbl_type();
    l_gta_trx_tbl_4gta ar_gta_trx_util.trx_tbl_type := ar_gta_trx_util.trx_tbl_type();
  BEGIN
    FND_LOG.G_CURRENT_RUNTIME_LEVEL := FND_LOG.LEVEL_STATEMENT;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.STRING(fnd_log.LEVEL_PROCEDURE,
                     G_MODULE_PREFIX || l_procedure_name,
                     'Begin Procedure. ');
    END IF;

    retrive_valid_AR_TRXs(p_org_id          => p_org_id,
                          p_transfer_id     => p_transfer_id,
                          p_conc_parameters => p_conc_parameters,
                          x_GTA_TRX_Tbl     => l_GTA_trx_tbl_4AR);

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'End Retrive_valid_ar_trx......');
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'l_gta_trx_tbl_4ar.count:' || l_GTA_trx_tbl_4AR.COUNT);
    END IF;

    ar_gta_split_trx_proc.split_Transactions(p_org_id      => p_org_id,
                                              p_transfer_id => p_transfer_id,
                                              p_gta_trx_tbl => l_gta_trx_tbl_4ar,
                                              x_gta_trx_tbl => l_gta_trx_tbl_4gta);
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'End Split_transactions......' || l_gta_trx_tbl_4gta.COUNT);
    END IF;

    ar_gta_trx_util.create_TRXs(p_gta_trxs => l_gta_trx_tbl_4gta);

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'End Create_trxs......');
    END IF;

    --generated XML string from temporary table
    --and put it out to concurrent output
    generate_XML_output(p_org_id          => p_org_id,
                        p_transfer_id     => p_transfer_id,
                        p_conc_parameters => p_conc_parameters);

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'End generate_XML_output......');
    END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.String(fnd_log.LEVEL_PROCEDURE,
                     G_MODULE_PREFIX || l_procedure_name,
                     'END procedure. ');
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.String(FND_LOG.LEVEL_UNEXPECTED,
                       G_MODULE_PREFIX || l_procedure_name ||
                       '. UNEXPECTED_ERROR',
                       'Unexpected error' || SQLCODE || SQLERRM);
      END IF;
      RAISE;

    WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                       G_MODULE_PREFIX || l_procedure_name ||
                       '. OTHER_EXCEPTION ',
                       'Unknown error' || SQLCODE || SQLERRM);

      END IF;
      RAISE;
  END transfer_AR_to_GTA;

  --==========================================================================
  --  PROCEDURE NAME:
  --                get_gta_number
  --
  --  DESCRIPTION:
  --                This function get concated GTA number by a AR trx ID
  --
  --  PARAMETERS:
  --                p_ar_trxId       IN             NUMBER
  --  RETURN:
  --                varchar2             concated GTA number
  --
  --  DESIGN REFERENCES:
  --                GTA-TRANSFER-PROGRAM-TD.doc
  --
  --  CHANGE HISTORY:
  --                12-APR-2006: Jogen Hu   Created.
  --===========================================================================
  FUNCTION get_gta_number(p_ar_trxId IN NUMBER) RETURN VARCHAR2 IS
    gta_trx_number VARCHAR2(2000);
    CURSOR get_gta_inv_number_c(p_ra_trx_id IN NUMBER) IS
      SELECT gta_trx_number
        FROM ar_gta_trx_headers_all
       WHERE ra_trx_id = p_ra_trx_id;
  BEGIN

    FOR r_number IN get_gta_inv_number_c(p_ar_trxId) LOOP
      gta_trx_number := gta_trx_number || ',' || r_number.gta_trx_number;
    END LOOP;
    RETURN gta_trx_number;

  END get_gta_number;

  --==========================================================================
  --  PROCEDURE NAME:
  --             Generate_XML_output
  --
  --  DESCRIPTION:
  --             This procedure generate XML string as concurrent output
  --             from temporary table
  --
  --  PARAMETERS:
  --             In:  P_ORG_ID           NUMBER
  --                  p_transfer_id      NUMBER
  --                  p_conc_parameters  AR_GTA_TRX_UTIL.transferParas_rec_type
  --
  --  DESIGN REFERENCES:
  --             GTA-TRANSFER-PROGRAM-TD.doc
  --
  --  CHANGE HISTORY:
  --             20-APR-2005: Jim Zheng   Created.
  --             24-Dec-2008: Yao Zhang   Changed for bug 7667709
  --===========================================================================

  PROCEDURE Generate_XML_Output(p_org_id          IN NUMBER,
                                p_transfer_id     IN NUMBER,
                                p_conc_parameters IN AR_GTA_TRX_UTIL.transferParas_rec_type) IS
    l_currency             VARCHAR2(30);
    l_reportFailed         xmltype;
    l_FailedWithParameters xmltype;
    l_parameter            XMLType;
    l_summary              XMLType;
    l_failed               XMLType;
    l_warning              xmltype;
    l_succeeded            XMLType;
    l_report_XML           XMLType;

    --l_date_format       VARCHAR2(11):=fnd_profile.VALUE('ICX_DATE_FORMAT_MASK');

    l_succ_rows      NUMBER;
    l_failed_rows    NUMBER;
    l_warning_rows   NUMBER;
    l_GTA_rows       NUMBER;
    l_succ_amount    NUMBER;
    l_failed_amount  NUMBER;
    l_warning_amount NUMBER;

    l_transaction_id  NUMBER;
    l_gta_inv_number  VARCHAR2(50);
    l_gta_inv_num_all VARCHAR2(2000);

    l_length NUMBER;

    l_operation_unit hr_operating_units.name%TYPE;
    l_transfer_rule  ar_gta_rule_headers_all.rule_name%TYPE;
    l_final_output   CLOB;
    -- parameters
    l_customer_num_from  VARCHAR2(30) := nvl(p_conc_parameters.CUSTOMER_NUM_FROM,
                                             ' ');
    l_customer_num_to    VARCHAR2(30) := nvl(p_conc_parameters.CUSTOMER_NUM_TO,
                                             ' ');
    l_customer_name_from VARCHAR2(360) := nvl(p_conc_parameters.CUSTOMER_NAME_FROM,
                                              ' ');
    l_customer_name_to   VARCHAR2(360) := nvl(p_conc_parameters.CUSTOMER_NAME_TO,
                                              ' ');
    l_gl_period          VARCHAR2(100) := nvl(p_conc_parameters.GL_PERIOD,
                                              ' ');
    --l_gl_date_from               VARCHAR2(20)  := nvl(to_char(p_conc_parameters.GL_DATE_FROM), ' ');
    l_gl_date_from VARCHAR2(20) := nvl(AR_GTA_TRX_UTIL.To_Xsd_Date_String(p_conc_parameters.GL_DATE_FROM),
                                       ' ');
    --l_gl_date_to                 VARCHAR2(20)  := nvl(to_char(p_conc_parameters.GL_DATE_TO), ' ');
    l_gl_date_to      VARCHAR2(20) := nvl(AR_GTA_TRX_UTIL.To_Xsd_Date_String(p_conc_parameters.GL_DATE_TO),
                                          ' ');
    l_trx_batch_from  VARCHAR2(50) := nvl(p_conc_parameters.TRX_BATCH_FROM,
                                          ' ');
    l_trx_batch_to    VARCHAR2(50) := nvl(p_conc_parameters.TRX_BATCH_TO,
                                          ' ');
    l_trx_number_from VARCHAR2(20) := nvl(p_conc_parameters.TRX_NUMBER_FROM,
                                          ' ');
    l_trx_number_to   VARCHAR2(20) := nvl(p_conc_parameters.TRX_NUMBER_TO,
                                          ' ');
    --l_trx_date_from              VARCHAR2(20)  := nvl(to_char(p_conc_parameters.TRX_DATE_FROM), ' ');
    l_trx_date_from VARCHAR2(20) := nvl(AR_GTA_TRX_UTIL.To_Xsd_Date_String(p_conc_parameters.TRX_DATE_FROM),
                                        ' ');
    --l_trx_date_to                VARCHAR2(20)  := nvl(to_char(p_conc_parameters.TRX_DATE_TO), ' ');
    l_trx_date_to  VARCHAR2(20) := nvl(AR_GTA_TRX_UTIL.To_Xsd_Date_String(p_conc_parameters.TRX_DATE_TO),
                                       ' ');
    l_doc_num_from VARCHAR2(30) := nvl(to_char(p_conc_parameters.DOC_NUM_FROM),
                                       ' ');
    l_doc_num_to   VARCHAR2(30) := nvl(to_char(p_conc_parameters.DOC_NUM_TO),
                                       ' ');

    l_procedure_name VARCHAR2(30) := 'Generate_XML_output';

    --12/04/2006   Jogen Hu  bug 5144561
    /*
    -- for add the gta_inv_number
    CURSOR report_temp_c
    IS
    SELECT
      transaction_id
    FROM
      ar_gta_transfer_temp
    WHERE SUCCEEDED='Y';

    -- for  add the gta inv number
    CURSOR get_gta_inv_number_c(p_ra_trx_id  IN NUMBER)
    IS
    SELECT
      gta_trx_number
    FROM
      ar_gta_trx_headers_all
    WHERE
      ra_trx_id = p_ra_trx_id;
      */
    --12/04/2006   Jogen Hu  bug 5144561

  BEGIN

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.STRING(fnd_log.LEVEL_PROCEDURE,
                     G_MODULE_PREFIX || l_procedure_name,
                     'Begin Procedure. ');
    END IF;

    SELECT GT_CURRENCY_CODE
      INTO l_currency
      FROM ar_gta_system_parameters_all
     WHERE org_id = p_org_id;

    --get rult name by rule id
    BEGIN
      SELECT rule.rule_name
        INTO l_transfer_rule
        FROM ar_gta_rule_headers_all rule
       WHERE rule.rule_header_id = p_transfer_id;
    EXCEPTION
      WHEN no_data_found THEN

        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_log.String(fnd_log.LEVEL_EXCEPTION,
                         G_MODULE_PREFIX || l_procedure_name,
                         'No data found ');
        END IF;
        RAISE;
    END;

    -- get org name by org id
    BEGIN
      SELECT OU.NAME
        INTO l_operation_unit
        FROM HR_ALL_ORGANIZATION_UNITS O, HR_ALL_ORGANIZATION_UNITS_TL OU
       WHERE O.ORGANIZATION_ID = OU.ORGANIZATION_ID
         AND OU.LANGUAGE = USERENV('LANG')
         AND O.ORGANIZATION_ID = p_org_id;

    EXCEPTION
      WHEN no_data_found THEN

        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_log.String(fnd_log.LEVEL_EXCEPTION,
                         G_MODULE_PREFIX || l_procedure_name,
                         'No data found ');
        END IF;
        RAISE;
    END;

    -- sum the count of successed , failed and warning trx
    SELECT COUNT(*), SUM(nvl(amount, 0))
      INTO l_succ_rows, l_succ_amount
      FROM AR_gta_transfer_temp
     WHERE SUCCEEDED = 'Y';

    --12/04/2006   Jogen Hu  bug 5144561
    /*
    --begin insert the gta invoice number into temp
    --get the transaction_id from temp table
    OPEN report_temp_c;
    LOOP
      FETCH
        report_temp_c
      INTO
        l_transaction_id;

      EXIT WHEN report_temp_c%NOTFOUND;

        fnd_file.PUT_LINE(fnd_file.log,'|||----111----||'||l_transaction_id);
      -- init gta invoice number all
      l_gta_inv_num_all := '';

      --get the gta_inv_number
      OPEN get_gta_inv_number_c(l_transaction_id);
      LOOP
        FETCH
          get_gta_inv_number_c
        INTO
          l_gta_inv_number;

        EXIT WHEN get_gta_inv_number_c%NOTFOUND;

        fnd_file.PUT_LINE(fnd_file.log,'|||----222----||'||l_gta_inv_number);

        IF l_gta_inv_num_all IS NULL
        THEN
          l_gta_inv_num_all :=  l_gta_inv_num_all;
        ELSE
          l_gta_inv_num_all := l_gta_inv_num_all||','||l_gta_inv_number;
        END IF;

      END LOOP;--OPEN get_gta_inv_number_c(l_transaction_id)
      CLOSE get_gta_inv_number_c;--jogen Hu Apr-4, 2006 bug 5135169

      BEGIN
        UPDATE
          ar_gta_transfer_temp
        SET
          gta_invoice_num = l_gta_inv_num_all
        WHERE
          transaction_id = l_transaction_id;

      EXCEPTION
        WHEN OTHERS THEN
        fnd_file.PUT_LINE(fnd_file.log,'|||----333----||'||l_transaction_id);

          IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
          THEN
            FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                          , G_MODULE_PREFIX || l_procedure_name || '. OTHER_EXCEPTION '
                          , 'Unknown error'||SQLCODE||SQLERRM);

          END IF;

      END;

    END LOOP;--OPEN report_temp_c

    CLOSE report_temp_c;--jogen Hu Apr-4, 2006 bug 5135169
    */
    --12/04/2006   Jogen Hu  bug 5144561
    --end insert the gta invoice number into temp

    SELECT COUNT(*), SUM(nvl(amount, 0))
      INTO l_failed_rows, l_failed_amount
      FROM AR_gta_transfer_temp
     WHERE SUCCEEDED = 'N';

    SELECT COUNT(*), SUM(nvl(amount, 0))
      INTO l_warning_rows, l_warning_amount
      FROM ar_gta_transfer_temp
     WHERE SUCCEEDED = 'W';

    SELECT COUNT(*)
      INTO l_GTA_rows
      FROM ar_gta_transfer_temp
     WHERE SUCCEEDED = 'W'
        OR SUCCEEDED = 'Y';

    -- generate validate xml string
    SELECT xmlelement("ReportFailed", 'N') INTO l_Reportfailed FROM dual;

    SELECT xmlelement("FailedWithParameters", 'N')
      INTO l_FailedWithParameters
      FROM dual;

    -- generate xmlsring of parameters of transfer program
    SELECT xmlelement("Parameters",
                      xmlforest(l_operation_unit AS "OperationUnit",
                                l_transfer_rule AS "TransferRule",
                                l_customer_num_from AS "CustomerNumberFrom",
                                l_customer_num_to AS "CustomerNumberTo",
                                l_customer_name_from AS "CustomerNameFrom",
                                l_customer_name_to AS "CustomerNameTo",
                                l_gl_period AS "GLPeriod",
                                l_gl_date_from AS "GLDateFrom",
                                l_gl_date_to AS "GLDateTo",
                                l_trx_batch_from AS "TransactionBatchFrom",
                                l_trx_batch_to AS "TransactionBatchTo",
                                l_trx_number_from AS "TransactionNumberFrom",
                                l_trx_number_to AS "TransactionNumberTo",
                                l_trx_date_from AS "TransactionDateFrom",
                                l_trx_date_to AS "TransactionDateTo",
                                l_doc_num_from AS "DocNumberFrom",
                                l_doc_num_to AS "DocNumberTo"))
      INTO l_parameter
      FROM dual;

    --generate summary section
    SELECT xmlelement("Summary",
                      xmlforest(l_succ_rows AS "NumOfSucc",
                                l_failed_rows AS "NumOfFailed",
                                l_warning_rows AS "NumOfWarning",
                                l_GTA_rows AS "NumOfGTA",
                                l_succ_amount AS "AmountSucc",
                                l_failed_amount AS "AmountWarning",
                                l_warning_amount AS "AmountFail"))
      INTO l_summary
      FROM dual;

    -- generate the xmltype for failed inv
    SELECT XMLElement("Invoices",
                      xmlagg(xmlelement("Invoice",
                                        xmlforest(seq AS "sequence",
                                                  Transaction_Num AS
                                                  "TransactionNum",
                                                  Transaction_Type AS
                                                  "TransactionType",
                                                  Customer_Name AS
                                                  "CustomerName",
                                                  Amount AS "Amount",
                                                  FailedReason AS
                                                  "FailedReason"))))
      INTO l_failed
      FROM AR_gta_transfer_temp
     WHERE SUCCEEDED = 'N';

    -- generate the xmltype for warning inv
    SELECT XMLElement("Invoices",
                      xmlagg(xmlelement("Invoice",
                                        xmlforest(seq AS "sequence",
                                                  Transaction_Num AS
                                                  "TransactionNum",
                                                  Transaction_Type AS
                                                  "TransactionType",
                                                  Customer_Name AS
                                                  "CustomerName",
                                                  Amount AS "Amount",
                                                  FailedReason AS
                                                  "WarningReason"))))
      INTO l_warning
      FROM AR_gta_transfer_temp
     WHERE SUCCEEDED = 'W';

    --generate the xmltype for succ inv
    SELECT XMLElement("Invoices",
                      xmlagg(xmlelement("Invoice",
                                        xmlforest(SEQ AS "sequence",
                                                  Transaction_Num AS
                                                  "TransactionNum",
                                                  Transaction_Type AS
                                                  "TransactionType",
                                                  Customer_Name AS
                                                  "CustomerName",
                                                  Amount AS "Amount"
                                                  --12/04/2006   Jogen Hu  bug 5144561
                                                  /*gta_invoice_num   AS "GTAInvoiceNum"*/,
                                                  get_gta_number(transaction_id) AS
                                                  "GTAInvoiceNum"
                                                  --12/04/2006   Jogen Hu  bug 5144561
                                                  ))))
      INTO l_succeeded
      FROM AR_gta_transfer_temp
     WHERE SUCCEEDED = 'Y';

    --generate the final report
    SELECT xmlelement("TransferReport",
                      xmlforest(l_reportFailed AS "ReportFailed",
                                l_FailedWithParameters AS
                                "FailedWithParameters",
                                AR_GTA_TRX_UTIL.To_Xsd_Date_String(SYSDATE) AS
                                "ReqDate"
                                --, to_char(SYSDATE, l_date_format)    AS   "ReqDate"
                                ,
                                l_currency AS "CurrencyCode",
                                l_parameter AS "Parameters",
                                l_summary AS "Summary",
                                l_failed AS "FailedInvoices",
                                l_warning AS "WarningInvoices",
                                l_succeeded AS "SuccInvoices"))
      INTO l_report_XML
      FROM dual;

    -- concurrent output
    AR_GTA_TRX_UTIL.output_conc(l_report_XML.Getclobval);

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      AR_GTA_TRX_UTIL.debug_output_conc(l_report_XML.Getclobval);
    END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.String(fnd_log.LEVEL_PROCEDURE,
                     G_MODULE_PREFIX || l_procedure_name,
                     'END procedure. ');
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

  --==========================================================================
  --  PROCEDURE NAME:
  --                Retrive_Valid_AR_TRXs
  --
  --  DESCRIPTION:
  --                This procedure retrive and validate AR transaction
  --
  --  PARAMETERS:
  --              p_org_id            IN          NUMBER
  --              p_transfer_id       IN          NUMBER
  --              p_conc_parameters   IN          AR_GTA_TRX_UTIL.transferParas_rec_type
  --              x_GTA_TRX_Tbl       OUT NOCOPY  AR_GTA_TRX_UTIL.TRX_TBL_TYPE
  --
  --  DESIGN REFERENCES:
  --                GTA-TRANSFER-PROGRAM-TD.doc
  --
  --  CHANGE HISTORY:
  --                20-APR-2005: Jim Zheng   Created.
  --                16-Dec-2008  Yao Zhang   Changed for bug 7644235
  --                23-01-2008   Yao Zhang   Changed for bug  7758496
  --===========================================================================
  PROCEDURE Retrive_Valid_AR_TRXs(p_org_id          IN NUMBER,
                                  p_transfer_id     IN NUMBER,
                                  p_conc_parameters IN AR_GTA_TRX_UTIL.transferParas_rec_type,
                                  x_GTA_TRX_Tbl     OUT NOCOPY AR_GTA_TRX_UTIL.TRX_TBL_TYPE) IS
    l_sql_exec          VARCHAR2(4000);
    l_procedure_name    VARCHAR2(30) := 'retrive_valid_AR_TRXs';
    l_trxtype_parameter AR_GTA_TRX_UTIL.Condition_para_tbl_type := AR_GTA_TRX_UTIL.Condition_para_tbl_type();
    l_flex_parameter    AR_GTA_TRX_UTIL.Condition_para_tbl_type := AR_GTA_TRX_UTIL.Condition_para_tbl_type();
    l_other_parameter   AR_GTA_TRX_UTIL.Condition_para_tbl_type := AR_GTA_TRX_UTIL.Condition_para_tbl_type();
    l_currency_code     ar_gta_system_parameters_all.gt_currency_code%TYPE;
    l_gta_trx_tbl         ar_gta_trx_util.trx_tbl_type:= ar_gta_trx_util.trx_tbl_type();
    l_invoice_type_code VARCHAR2(1);
  BEGIN

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(fnd_log.LEVEL_PROCEDURE,
                     G_MODULE_PREFIX || l_procedure_name,
                     'Begin Procedure. ');
    END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'Begin Retrive_valid_ar_trx......');
    END IF;

    GET_AR_SQL(P_ORG_ID            => P_ORG_ID,
               p_transfer_id       => p_transfer_id,
               p_conc_parameters   => p_conc_parameters,
               x_QUERY_SQL         => l_sql_exec,
               x_trxtype_parameter => l_trxtype_parameter,
               x_flex_parameter    => l_flex_parameter,
               x_other_parameter   => l_other_parameter,
               x_currency_code     => l_currency_code);

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'End get AR sql......');
    END IF;

    Retrieve_AR_TRXs(p_org_id             => p_org_id,
                     p_transfer_id        => p_transfer_id,
                     P_query_SQL          => l_sql_exec,
                     P_trxtype_query_para => l_trxtype_parameter,
                     p_flex_query_para    => l_flex_parameter,
                     p_other_query_para   => l_other_parameter,
                     p_currency_code      => l_currency_code,
                     x_GTA_TRX_TBL        => x_GTA_TRX_Tbl);

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'End retrieve_ar_trxs......');
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'l_GTA_TRX_Tbl:' || x_GTA_TRX_Tbl.COUNT);
    END IF;

  --following code is recovered by Yao Zhang for bug 7644235
    -- file the credit memo which the max amount or max line exceed
    --commented by subba for R12.1, becoz of new credit memo process..
    l_gta_Trx_tbl:=x_GTA_TRX_Tbl;
    ar_gta_split_trx_proc.filter_credit_memo(p_org_id     => p_org_id
     , p_transfer_id => p_transfer_id--yao zhang changed for bug 7758496
     , p_gta_trx_tbl => l_gta_Trx_tbl
     , x_gta_Trx_tbl => x_gta_trx_tbl
    );
  -- recovered by Yao Zhang for bug 7644235 end
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'End filter_credit_memo......');
    END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(fnd_log.LEVEL_PROCEDURE,
                     G_MODULE_PREFIX || l_procedure_name,
                     'END procedure. ');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                       G_MODULE_PREFIX || l_procedure_name ||
                       '. OTHER_EXCEPTION ',
                       'Unknown error' || SQLCODE || SQLERRM);
      END IF;
      RAISE;

  End retrive_valid_AR_TRXs;

  --==========================================================================
  --  PROCEDURE NAME:
  --               Get_AR_SQL
  --
  --  DESCRIPTION:
  --               This procedure returns the SQL for Receivable
  --               VAT transaction retrieval
  --
  --  PARAMETERS:
  --   In:  P_ORG_ID              NUMBER
  --        p_transfer_id         VARCHAR2
  --        p_conc_parameters       AR_GTA_TRX_UTIL.transferParas_rec_type
  --   OUT: x_query_sql             VARCHAR2
  --        x_trxtype_parameter     AR_GTA_TRX_UTIL.Condition_para_tbl_type
  --        x_flex_parameter        AR_GTA_TRX_UTIL.Condition_para_tbl_type
  --        x_other_parameter       AR_GTA_TRX_UTIL.Condition_para_tbl_type
  --        x_currency_code         VARCHAR2

  --  DESIGN REFERENCES:
  --               GTA-TRANSFER-PROGRAM-TD.doc
  --
  --  CHANGE HISTORY:
  --               20-APR-2005: Jim Zheng   Created.
  --               24-Nov-2005: Jim Zheng   Change the period_type select
  --                                        condition in dynamic SQL
  --               28-Dec-2007: Subba  Changed, included condition for invoice type
  --                            to support new tax regulation change in R12.1
  --===========================================================================
  PROCEDURE Get_AR_SQL(P_ORG_ID            IN NUMBER,
                       p_transfer_id       IN NUMBER,
                       p_conc_parameters   IN AR_GTA_TRX_UTIL.transferParas_rec_type,
                       x_query_sql         OUT NOCOPY VARCHAR2,
                       x_trxtype_parameter OUT NOCOPY AR_GTA_TRX_UTIL.Condition_para_tbl_type,
                       x_flex_parameter    OUT NOCOPY AR_GTA_TRX_UTIL.Condition_para_tbl_type,
                       x_other_parameter   OUT NOCOPY AR_GTA_TRX_UTIL.Condition_para_tbl_type,
                       x_currency_code     OUT NOCOPY VARCHAR2) IS
    l_select_sql VARCHAR2(4000);

    l_TRX_TYPE_condition     VARCHAR2(2000);
    l_flex_condition         VARCHAR2(2000);
    l_other_condition        VARCHAR2(2000);
    l_currency_condition     VARCHAR2(500);
    l_invoice_type_condition VARCHAR2(2000); --Newly added by Subba for R12.1
    l_error_string           VARCHAR2(400);
    l_procedure_name         VARCHAR2(30) := 'Get_AR_SQL';

  BEGIN

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.STRING(fnd_log.LEVEL_PROCEDURE,
                     G_MODULE_PREFIX || l_procedure_name,
                     'Begin Procedure. ');
    END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'Begin get AR sql......');
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'P_ORG_ID: ' || P_ORG_ID);
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'p_transfer_id: ' || p_transfer_id);
    END IF;

    l_select_sql := 'SELECT h.customer_trx_id
                   FROM
                     ra_customer_trx_all h
                     , ra_cust_trx_types_all ctt
                     , ra_batches_all b
                     , Ra_Cust_Trx_Line_Gl_Dist_All gd
                     , Hz_Parties RAC_BILL_PARTY
                     , Hz_Cust_Accounts RAC_BILL
                     , GL_PERIODS GP
                   WHERE h.complete_flag = ''Y''
                     AND h.CUST_TRX_TYPE_ID = ctt.CUST_TRX_TYPE_ID(+)
                     AND ctt.TYPE IN (''INV'', ''CM'', ''DM'')
                     AND h.batch_id             = b.batch_id(+)
                     AND GD.CUSTOMER_TRX_ID     = h.CUSTOMER_TRX_ID
                     AND GD.ACCOUNT_CLASS       = ''REC''
                     AND GD.LATEST_REC_FLAG     = ''Y''
                     AND h.bill_to_customer_id  = RAC_BILL.CUST_ACCOUNT_ID
                     AND rac_bill.party_id      = RAC_BILL_PARTY.Party_Id
                     AND h.Org_Id = gd.Org_Id
                     AND h.Org_Id = ctt.Org_Id
                     AND h.Org_Id =:p_org_id
                     AND GP.PERIOD_SET_NAME =  (SELECT period_set_name
                                                FROM Gl_Sets_Of_Books
                                                WHERE set_of_books_id = h.set_of_books_id)
                     AND gp.period_type = (SELECT accounted_period_type
                                           FROM Gl_Sets_Of_Books
                                           WHERE set_of_books_id = h.set_of_books_id)
                     AND gp.adjustment_period_flag = ''N''
                     AND gp.start_date <= gd.GL_DATE
                     AND gp.end_date >= gd.gl_date ';

    -- generate dynamic sql for trxtype condition
    GET_AR_TRXTYPE_COND(P_ORG_ID          => P_ORG_ID,
                        p_transfer_id     => p_transfer_id,
                        x_condition_sql   => l_TRX_TYPE_condition,
                        x_query_parameter => x_trxtype_parameter);

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'End GET_AR_TRXTYPE_COND......');
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'l_TRX_TYPE_condition:' || l_TRX_TYPE_condition);
    END IF;

    -- generate dynamic sql for flex field condition
    GET_AR_FLEX_COND(P_ORG_ID          => P_ORG_ID,
                     p_transfer_id     => p_transfer_id,
                     x_condition_sql   => l_flex_condition,
                     x_query_parameter => x_flex_parameter);

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'End GET_AR_FLEX_COND......');
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'l_flex_condition:' || l_flex_condition);
    END IF;

    -- generate dynamic sql for parameter condition
    GET_PARAM_COND(P_ORG_ID          => P_ORG_ID,
                   p_transfer_id     => p_transfer_id,
                   p_conc_parameters => p_conc_parameters,
                   x_condition_sql   => l_other_condition,
                   x_query_parameter => x_other_parameter);

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'End GET_param_COND......');
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'l_other_condition:' || l_other_condition);
    END IF;

    --generate dynamic sql for currency code condition
    Get_AR_Currency_Cond(p_ORG_ID        => p_org_id,
                         p_transfer_id   => p_transfer_id,
                         x_condition_sql => l_currency_condition,
                         x_currency_code => x_currency_code);

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'End Get_AR_Currency_Cond......');
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'l_currency_condition:' || l_currency_condition);
    END IF;

    --generate dynamic sql for invoice type, Added by Subba

    Get_Invoice_Type(p_ORG_ID        => p_org_id,
                     p_transfer_id   => p_transfer_id,
                     x_condition_sql => l_invoice_type_condition);

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'End Get_Invoice_Type......');
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'l_invoice_type_condition:' || l_invoice_type_condition);
    END IF;

    -- concatenate dynamic sql
    -- l_trx_type_condition
    IF (l_TRX_TYPE_condition IS NOT NULL) THEN
      l_select_sql := l_select_sql || l_TRX_TYPE_condition;
    END IF;

    -- l_flex_condition
    IF (l_flex_condition IS NOT NULL) THEN
      l_select_sql := l_select_sql || l_flex_condition;
    END IF;

    -- l_other_condition
    IF (l_other_condition IS NOT NULL) THEN
      l_select_sql := l_select_sql || l_other_condition;
    END IF;

    -- l_currency_condition
    IF (l_currency_condition IS NOT NULL) THEN
      l_select_sql := l_select_sql || l_currency_condition;
    END IF;

    -- l_invoice_type_condition, added by Subba
    IF (l_invoice_type_condition IS NOT NULL) THEN
      l_select_sql := l_select_sql || l_invoice_type_condition;
    END IF;

    x_query_sql := l_select_sql;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'l_select_sql:' || l_select_sql);
    END IF;

    -- log output the ar sql
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.STRING(fnd_log.LEVEL_PROCEDURE,
                     G_MODULE_PREFIX || l_procedure_name,
                     l_select_sql);
    END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.STRING(fnd_log.LEVEL_PROCEDURE,
                     G_MODULE_PREFIX || l_procedure_name,
                     'END procedure. ');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                       G_MODULE_PREFIX || l_procedure_name ||
                       '. OTHER_EXCEPTION ',
                       'Unknown error' || SQLCODE || SQLERRM);

      END IF;
      RAISE;
  END Get_AR_SQL;

  --============================================================================

  -- PROCEDURE NAME:
  --                 Get_Invoice_Type
  --
  -- DESCRIPTION:
  --               This procedure returns the WHERE clause about Invoice Type using the
  --               Invoice Type,Transaction Type mapping relationship defined in GTA
  --               System Option.
  --  PARAMETERS:
  --           In:  P_ORG_ID                NUMBER
  --                p_transfer_id           VARCHAR2

  --           OUT: x_condition_sql         Varchar2
  --  CHANGE HISTORY:
  --               28-Dec-2007: Subba   Created.
  --               24-Dec-2008  Yao Zhang Changed for bug 7667709
  -- ===========================================================================

  PROCEDURE Get_Invoice_Type(p_ORG_ID        IN NUMBER,
                             p_transfer_id   IN NUMBER,
                             x_condition_sql OUT NOCOPY VARCHAR2) IS
    l_procedure_name    VARCHAR2(50) := 'Get_Invoice_Type';
    l_error_string      VARCHAR2(2000);
    l_invoice_type_code ar_gta_tax_limits_all.invoice_type%TYPE;

    l_transaction_type_cnt NUMBER;

  BEGIN

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.STRING(fnd_log.LEVEL_PROCEDURE,
                     G_MODULE_PREFIX || l_procedure_name,
                     'Begin Procedure. ');
    END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'Begin Get_Invoice_Type......');
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'p_org_id:' || p_org_id || '  ' || 'p_transfer_id:' ||
          p_transfer_id);
    END IF;

    -- select invoice type from transfer rule setup

    -- BEGIN

    SELECT jgrha.invoice_type
      INTO l_invoice_type_code
      FROM ar_gta_rule_headers_all jgrha
     WHERE jgrha.rule_header_id = p_transfer_id;

    /*    EXCEPTION
              -- no data found , raise a data error
               WHEN no_data_found THEN
                    fnd_message.SET_NAME('AR', 'AR_GTA_RULE_MISSING_ERROR');
                    l_error_string := fnd_message.get();
               -- output error
                    fnd_file.put_line(fnd_file.output, '<?xml version="1.0" encoding="UTF-8" ?>
                                       <TransferReport>
                                       <ReportFailed>Y</ReportFailed>
                                       <ReportFailedMsg>'||l_error_string
                                       ||'</ReportFailedMsg>
                                       <TransferReport>');

                    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                          fnd_log.STRING(fnd_log.LEVEL_UNEXPECTED
                                        ,G_MODULE_PREFIX || l_procedure_name
                                        , 'no data found when select invoice_type.');
                    END IF;
                    RAISE;
    END;*/

    -- if invoice type is A, set concatenating sql string as NULL

    -- else get transaction type id by actual invoice type, if no data found, raise an

    -- error.

    IF l_invoice_type_code IS NOT NULL THEN

      IF l_invoice_type_code = 'A' THEN
        x_condition_sql := NULL;

      ELSE
        BEGIN
          SELECT count(jgtm.transaction_type_id)
            INTO l_transaction_type_cnt
            FROM ar_gta_type_mappings jgtm, ar_gta_tax_limits_all jgtla
           WHERE jgtla.limitation_id = jgtm.limitation_id
             AND jgtla.invoice_type = l_invoice_type_code
             AND jgtla.org_id = p_org_id;

        EXCEPTION

          -- no data found, raise a data error
          WHEN no_data_found THEN
            fnd_message.SET_NAME('AR', 'AR_GTA_TRX_TYP_MAP_MISSING');
            l_error_string := fnd_message.get();
            -- output error
            fnd_file.put_line(fnd_file.output,
                              '<?xml version="1.0" encoding="UTF-8" ?>
                                     <TransferReport>
                                     <ReportFailed>Y</ReportFailed>
                                     <ReportFailedMsg>' ||
                              l_error_string ||
                              '</ReportFailedMsg>
                                     </TransferReport>');--Modified by Yao Zhang for bug 7667709


            IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              fnd_log.STRING(fnd_log.LEVEL_UNEXPECTED,
                             G_MODULE_PREFIX || l_procedure_name,
                             'no data found when select invoice_type.');
            END IF;
            RAISE;

            RETURN;
        END;

        -- set concatenating sql where clause
        x_condition_sql := ' AND h.cust_trx_type_id IN
                           (SELECT jgtm.transaction_type_id
                            FROM  ar_gta_type_mappings  jgtm
                                  ,ar_gta_tax_limits_all  jgtla
                            WHERE jgtm.limitation_id = jgtla.limitation_id
                            AND   jgtla.invoice_type = ''' ||
                           l_invoice_type_code || '''
                            AND   jgtla.org_id = :p_org_id)';

      END IF; /*l_invoice_type_code = 'A'*/

    END IF; /*l_invoice_type_code IS NOT NULL*/

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.STRING(fnd_log.LEVEL_PROCEDURE,
                     G_MODULE_PREFIX || l_procedure_name,
                     'END procedure. ');
    END IF;
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'End Get_Invoice_Type......');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                       G_MODULE_PREFIX || l_procedure_name ||
                       '. OTHER_EXCEPTION ',
                       'Unknown error' || SQLCODE || SQLERRM);

      END IF;
      RAISE;
  END Get_Invoice_Type;

  --==========================================================================
  --  PROCEDURE NAME:
  --               Get_AR_TrxType_Cond
  --
  --  DESCRIPTION:
  --               This procedure returns the WHERE clause
  --               about transaction type
  --
  --  PARAMETERS:
  --           In:  P_ORG_ID                NUMBER
  --                    p_transfer_id           VARCHAR2

  --           OUT: x_condition_sql         Varchar2
  --                x_query_parameter  AR_GTA_TRX_UTIL.Condition_para_tbl_type

  --  DESIGN REFERENCES:
  --               GTA-TRANSFER-PROGRAM-TD.doc
  --
  --  CHANGE HISTORY:
  --               20-APR-2005: Jim Zheng   Created.
  --===========================================================================
  PROCEDURE Get_AR_TrxType_Cond(p_ORG_ID          IN NUMBER,
                                p_transfer_id     IN NUMBER,
                                x_condition_sql   OUT NOCOPY VARCHAR2,
                                x_query_parameter OUT NOCOPY AR_GTA_TRX_UTIL.Condition_para_tbl_type) IS
    l_procedure_name   VARCHAR2(50) := 'Get_AR_TrxType_Cond';
    l_parameter_prefix VARCHAR2(10) := ':trxtype';
    l_parameter_suffix NUMBER;
    l_include_flag     VARCHAR2(5);
    l_cust_trx_type_id VARCHAR2(30);

    CURSOR trx_type_cond_i IS
      SELECT l.cust_trx_type_id
        FROM AR_GTA_RULE_TRX_TYPES_ALL l
       WHERE l.rule_header_id = p_transfer_id
         AND l.condition_rule = 'I';

    CURSOR trx_type_cond_e IS
      SELECT l.cust_trx_type_id
        FROM ar_gta_rule_trx_types_all l
       WHERE l.rule_header_id = p_transfer_id
         AND l.condition_rule = 'E';

  BEGIN

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.STRING(fnd_log.LEVEL_PROCEDURE,
                     G_MODULE_PREFIX || l_procedure_name,
                     'Begin Procedure. ');
    END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'Begin  Get_AR_TrxType_Cond......');
    END IF;

    -- init the sql string and parameter table.
    x_query_parameter  := AR_GTA_TRX_UTIL.Condition_para_tbl_type();
    l_parameter_suffix := 0;

    -- Generate the dynamic sql which condition_rule is 'I'
    OPEN trx_type_cond_i;

    -- fetch first line because the first line is different with others
    FETCH trx_type_cond_i
      INTO l_cust_trx_type_id;

    IF l_cust_trx_type_id IS NOT NULL THEN
      x_query_parameter.EXTEND;
      x_query_parameter(x_query_parameter.COUNT) := l_cust_trx_type_id;
      x_condition_sql := x_condition_sql || ' AND ( h.cust_trx_type_id = ' ||
                         l_parameter_prefix || (l_parameter_suffix + 1);
      l_parameter_suffix := l_parameter_suffix + 1;
    END IF;

    LOOP
      FETCH trx_type_cond_i
        INTO l_cust_trx_type_id;
      EXIT WHEN trx_type_cond_i%NOTFOUND;
      x_query_parameter.EXTEND;
      x_query_parameter(x_query_parameter.COUNT) := l_cust_trx_type_id;

      x_condition_sql    := x_condition_sql || ' OR ' ||
                            ' h.cust_trx_type_id = ' || l_parameter_prefix ||
                            (l_parameter_suffix + 1);
      l_parameter_suffix := l_parameter_suffix + 1;
    END LOOP;

    -- add the right bracket
    IF x_condition_sql IS NOT NULL THEN
      x_condition_sql := x_condition_sql || ' ) ';
    END IF;

    CLOSE trx_type_cond_i;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'End  trx_type_cond_i......');
    END IF;

    -- Generate the dynamic sql which condition_rule is 'I'
    OPEN trx_type_cond_e;
    LOOP
      FETCH trx_type_cond_e
        INTO l_cust_trx_type_id;
      EXIT WHEN trx_type_cond_e%NOTFOUND;
      x_query_parameter.EXTEND;
      x_query_parameter(x_query_parameter.COUNT) := l_cust_trx_type_id;
      x_condition_sql := x_condition_sql || ' AND (NOT ' ||
                         'h.cust_trx_type_id = ' || l_parameter_prefix ||
                         (l_parameter_suffix + 1) || ')';
      l_parameter_suffix := l_parameter_suffix + 1;
    END LOOP;
    CLOSE trx_type_cond_e;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.STRING(fnd_log.LEVEL_PROCEDURE,
                     G_MODULE_PREFIX || l_procedure_name,
                     'END procedure. ');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                       G_MODULE_PREFIX || l_procedure_name ||
                       '. OTHER_EXCEPTION ',
                       'Unknown error' || SQLCODE || SQLERRM);

      END IF;
      RAISE;

  END Get_AR_TrxType_Cond;

  --==========================================================================
  --  PROCEDURE NAME:
  --               Get_AR_FLEX_COND
  --
  --  DESCRIPTION:
  --               This procedure returns the WHERE clause
  --               about flexfield condition
  --
  --  PARAMETERS:
  --       In:  P_ORG_ID                NUMBER
  --            p_transfer_id           VARCHAR2

  --        OUT: x_condition_sql         Varchar2
  --             x_query_parameter  AR_GTA_TRX_UTIL.Condition_para_tbl_type

  --  DESIGN REFERENCES:
  --               GTA-TRANSFER-PROGRAM-TD.doc
  --
  --  CHANGE HISTORY:
  --               20-APR-2005: Jim Zheng   Created.
  --===========================================================================
  PROCEDURE Get_AR_FLEX_COND(P_ORG_ID          IN NUMBER,
                             p_transfer_id     IN NUMBER,
                             x_condition_sql   OUT NOCOPY VARCHAR2,
                             x_query_parameter OUT NOCOPY AR_GTA_TRX_UTIL.Condition_para_tbl_type) IS
    l_procedure_name   VARCHAR2(50) := 'Get_AR_FLEX_COND';
    l_parameter_prefix VARCHAR2(10) := ':flex';
    l_parameter_suffix NUMBER;

    l_include_flag     VARCHAR2(5);
    l_CONTEXT_CODE     AR_GTA_RULE_DFFS_ALL.Context_Code%TYPE;
    l_ATTRIBUTE_COLUMN AR_GTA_RULE_DFFS_ALL.Attribute_Column%TYPE;
    l_ATTRIBUTE_value  AR_GTA_RULE_DFFS_ALL.Attribute_Value%TYPE;

    CURSOR flex_cond_i IS
      SELECT l.context_code, l.attribute_column, l.attribute_value
        FROM AR_GTA_RULE_DFFS_ALL l
       WHERE l.org_id = P_ORG_ID
         AND l.rule_header_id = p_transfer_id
         AND l.condition_rule = 'I';

    CURSOR flex_cond_e IS
      SELECT l.context_code, l.attribute_column, l.attribute_value
        FROM ar_gta_rule_dffs_all l
       WHERE l.Org_Id = P_ORG_ID
         AND l.rule_header_id = p_transfer_id
         AND l.condition_rule = 'E';

  BEGIN

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.STRING(fnd_log.LEVEL_PROCEDURE,
                     G_MODULE_PREFIX || l_procedure_name,
                     'Begin Procedure. ');
    END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'begin get_ar_flex......');
    END IF;

    x_query_parameter  := AR_GTA_TRX_UTIL.Condition_para_tbl_type();
    l_parameter_suffix := 0;

    -- Generate the dynamic sql for flex filed which the condition rule is 'I'
    OPEN flex_cond_i;
    -- fetch the first line because the first line's dynamic sql
    --is different with the others
    FETCH flex_cond_i
      INTO l_CONTEXT_CODE, l_ATTRIBUTE_COLUMN, l_ATTRIBUTE_value;

    IF l_context_code IS NOT NULL THEN
      x_query_parameter.EXTEND;
      x_query_parameter(x_query_parameter.COUNT) := l_context_code;
      x_query_parameter.EXTEND;
      x_query_parameter(x_query_parameter.COUNT) := l_attribute_value;
      x_condition_sql := x_condition_sql ||
                         ' AND ( (h.attribute_category = ' ||
                         l_parameter_prefix || (l_parameter_suffix + 1) ||
                         ' AND h.' || l_ATTRIBUTE_COLUMN || ' = ' ||
                         l_parameter_prefix || (l_parameter_suffix + 2) || ')';
      l_parameter_suffix := l_parameter_suffix + 2;
    END IF;

    LOOP
      FETCH flex_cond_i
        INTO l_CONTEXT_CODE, l_ATTRIBUTE_COLUMN, l_ATTRIBUTE_value;
      EXIT WHEN flex_cond_i%NOTFOUND;
      x_query_parameter.EXTEND;
      x_query_parameter(x_query_parameter.COUNT) := l_context_code;
      x_query_parameter.EXTEND;
      x_query_parameter(x_query_parameter.COUNT) := l_attribute_value;
      x_condition_sql := x_condition_sql || ' OR (h.attribute_category = ' ||
                         l_parameter_prefix || (l_parameter_suffix + 1) ||
                         ' AND h.' || l_ATTRIBUTE_COLUMN || ' = ' ||
                         l_parameter_prefix || (l_parameter_suffix + 2) || ')';
      l_parameter_suffix := l_parameter_suffix + 2;

    END LOOP;

    -- add the right bracket
    IF x_condition_sql IS NOT NULL THEN
      x_condition_sql := x_condition_sql || ')';
    END IF;
    CLOSE flex_cond_i;

    -- Generate the dynamic sql for flex filed which the condition rule is 'E'
    OPEN flex_cond_e;
    LOOP
      FETCH flex_cond_e
        INTO l_CONTEXT_CODE, l_ATTRIBUTE_COLUMN, l_ATTRIBUTE_value;
      EXIT WHEN flex_cond_e%NOTFOUND;
      x_query_parameter.EXTEND;
      x_query_parameter(x_query_parameter.COUNT) := l_context_code;
      x_query_parameter.EXTEND;
      x_query_parameter(x_query_parameter.COUNT) := l_attribute_value;

      x_condition_sql := x_condition_sql ||
                         ' AND (NOT (h.attribute_category = ' ||
                         l_parameter_prefix || (l_parameter_suffix + 1) ||
                         ' AND h.' || l_ATTRIBUTE_COLUMN || '=' ||
                         l_parameter_prefix || (l_parameter_suffix + 2) || ')';
      --Added by Shujuan for bug 5443909
      --When dff attribution is null, should transfer the invoice
      x_condition_sql    := x_condition_sql || ' OR h.' ||
                            l_ATTRIBUTE_COLUMN || ' IS NULL)';
      l_parameter_suffix := l_parameter_suffix + 2;

    END LOOP;

    CLOSE flex_cond_e;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.STRING(fnd_log.LEVEL_PROCEDURE,
                     G_MODULE_PREFIX || l_procedure_name,
                     'END procedure. ');
    END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'End get_ar_flex......');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                       G_MODULE_PREFIX || l_procedure_name ||
                       '. OTHER_EXCEPTION ',
                       'Unknown error');

      END IF;
      RAISE;

  END Get_AR_FLEX_COND;

  --==========================================================================
  --  PROCEDURE NAME:
  --               Get_Param_Cond
  --
  --  DESCRIPTION:
  --               This procedure returns the WHERE clause
  --               about request parameter and fixed condition
  --
  --  PARAMETERS:
  --     In:  P_ORG_ID             NUMBER
  --          p_transfer_id        VARCHAR2
  --          p_conc_parameters    AR_GTA_TRX_UTIL.transferParas_rec_type

  --     OUT: x_condition_sql      Varchar2
  --          x_query_parameter    AR_GTA_TRX_UTIL.Condition_para_tbl_type

  --  DESIGN REFERENCES:
  --               GTA-TRANSFER-PROGRAM-TD.doc
  --
  --  CHANGE HISTORY:
  --               20-APR-2005: Jim Zheng   Created.
  --
  --===========================================================================
  PROCEDURE Get_Param_Cond(P_ORG_ID          IN NUMBER,
                           p_transfer_id     IN NUMBER,
                           p_conc_parameters IN AR_GTA_TRX_UTIL.transferParas_rec_type,
                           x_condition_sql   OUT NOCOPY VARCHAR2,
                           x_query_parameter OUT NOCOPY AR_GTA_TRX_UTIL.Condition_para_tbl_type) IS
    l_procedure_name   VARCHAR2(30) := 'Get_Param_Cond';
    l_parameter_prefix VARCHAR2(10) := ':para';
    l_parameter_suffix NUMBER;

  BEGIN

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.STRING(fnd_log.LEVEL_PROCEDURE,
                     G_MODULE_PREFIX || l_procedure_name,
                     'Begin Procedure. ');
    END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'begin get_param_cond......');
    END IF;

    -- init
    x_condition_sql    := '';
    x_query_parameter  := AR_GTA_TRX_UTIL.Condition_para_tbl_type();
    l_parameter_suffix := 0;

    -- if the from parameter and to parameter is null
    --and don't add the condition to dynamic sql
    IF NOT (p_conc_parameters.CUSTOMER_NUM_FROM IS NULL AND
        p_conc_parameters.CUSTOMER_NUM_TO IS NULL) THEN
      x_query_parameter.EXTEND;
      x_query_parameter(x_query_parameter.COUNT) := nvl(p_conc_parameters.CUSTOMER_NUM_FROM,
                                                        ' ');
      x_query_parameter.EXTEND;
      x_query_parameter(x_query_parameter.COUNT) := nvl(p_conc_parameters.CUSTOMER_NUM_TO,
                                                        rpad('z', 30, 'z'));

      x_condition_sql    := x_condition_sql ||
                            ' AND RAC_BILL.ACCOUNT_NUMBER BETWEEN ' ||
                            l_parameter_prefix || (l_parameter_suffix + 1) ||
                            ' AND ' || l_parameter_prefix ||
                            (l_parameter_suffix + 2);
      l_parameter_suffix := l_parameter_suffix + 2;
    END IF;

    IF NOT (p_conc_parameters.CUSTOMER_NAME_FROM IS NULL AND
        p_conc_parameters.CUSTOMER_NAME_TO IS NULL) THEN
      x_query_parameter.EXTEND;
      x_query_parameter(x_query_parameter.COUNT) := nvl(p_conc_parameters.CUSTOMER_NAME_FROM,
                                                        ' ');
      x_query_parameter.EXTEND;
      x_query_parameter(x_query_parameter.COUNT) := nvl(p_conc_parameters.CUSTOMER_NAME_FROM,
                                                        rpad('z', 30, 'z'));

      x_condition_sql    := x_condition_sql ||
                            ' AND RAC_BILL_PARTY.Party_Name BETWEEN ' ||
                            l_parameter_prefix || (l_parameter_suffix + 1) ||
                            ' AND ' || l_parameter_prefix ||
                            (l_parameter_suffix + 2);
      l_parameter_suffix := l_parameter_suffix + 2;
    END IF;

    IF p_conc_parameters.GL_PERIOD IS NOT NULL THEN
      x_query_parameter.EXTEND;
      x_query_parameter(x_query_parameter.COUNT) := p_conc_parameters.GL_PERIOD;

      x_condition_sql    := x_condition_sql || ' AND GP.period_name = ' ||
                            l_parameter_prefix || (l_parameter_suffix + 1);
      l_parameter_suffix := l_parameter_suffix + 1;
    END IF;

    IF NOT (p_conc_parameters.GL_DATE_FROM IS NULL AND
        p_conc_parameters.GL_DATE_TO IS NULL) THEN
      x_query_parameter.EXTEND;
      x_query_parameter(x_query_parameter.COUNT) := nvl(p_conc_parameters.GL_DATE_FROM,
                                                        to_date('1900-01-01',
                                                                'RRRR-MM-DD'));
      x_query_parameter.EXTEND;
      x_query_parameter(x_query_parameter.COUNT) := nvl(p_conc_parameters.GL_DATE_TO,
                                                        to_date('2100-01-01',
                                                                'RRRR-MM-DD'));

      --bug 5107043, Jogen Mar-22,2006
      x_condition_sql := x_condition_sql ||
                         ' AND trunc(gd.gl_date,''DDD'') BETWEEN ' ||
                         l_parameter_prefix || (l_parameter_suffix + 1) ||
                         ' AND ' || l_parameter_prefix ||
                         (l_parameter_suffix + 2);

      l_parameter_suffix := l_parameter_suffix + 2;
    END IF;

    IF NOT (p_conc_parameters.TRX_BATCH_FROM IS NULL AND
        p_conc_parameters.TRX_BATCH_TO IS NULL) THEN
      x_query_parameter.EXTEND;
      x_query_parameter(x_query_parameter.COUNT) := nvl(p_conc_parameters.TRX_BATCH_FROM,
                                                        ' ');
      x_query_parameter.EXTEND;
      x_query_parameter(x_query_parameter.COUNT) := nvl(p_conc_parameters.TRX_BATCH_TO,
                                                        rpad('z', 30, 'z'));

      x_condition_sql    := x_condition_sql || ' AND b.name BETWEEN ' ||
                            l_parameter_prefix || (l_parameter_suffix + 1) ||
                            ' AND ' || l_parameter_prefix ||
                            (l_parameter_suffix + 2);
      l_parameter_suffix := l_parameter_suffix + 2;
    END IF;

    IF NOT (p_conc_parameters.TRX_NUMBER_FROM IS NULL AND
        p_conc_parameters.TRX_NUMBER_TO IS NULL) THEN
      x_query_parameter.EXTEND;
      x_query_parameter(x_query_parameter.COUNT) := nvl(p_conc_parameters.TRX_NUMBER_FROM,
                                                        ' ');
      x_query_parameter.EXTEND;
      x_query_parameter(x_query_parameter.COUNT) := nvl(p_conc_parameters.TRX_NUMBER_TO,
                                                        rpad('z', 30, 'z'));

      x_condition_sql := x_condition_sql || ' AND h.trx_number BETWEEN ' ||
                         l_parameter_prefix || (l_parameter_suffix + 1) ||
                         ' AND ' || l_parameter_prefix ||
                         (l_parameter_suffix + 2);

      l_parameter_suffix := l_parameter_suffix + 2;
    END IF;

    IF NOT (p_conc_parameters.TRX_DATE_FROM IS NULL AND
        p_conc_parameters.TRX_DATE_TO IS NULL) THEN
      x_query_parameter.EXTEND;
      x_query_parameter(x_query_parameter.COUNT) := nvl(p_conc_parameters.TRX_DATE_FROM,
                                                        to_date('1900-01-01',
                                                                'RRRR-MM-DD'));
      x_query_parameter.EXTEND;
      x_query_parameter(x_query_parameter.COUNT) := nvl(p_conc_parameters.TRX_DATE_TO,
                                                        to_date('2100-01-01',
                                                                'RRRR-MM-DD'));
      --bug 5107043, Jogen Mar-22,2006
      x_condition_sql    := x_condition_sql ||
                            ' AND trunc(h.trx_date,''DDD'') BETWEEN ' ||
                            l_parameter_prefix || (l_parameter_suffix + 1) ||
                            ' AND ' || l_parameter_prefix ||
                            (l_parameter_suffix + 2);
      l_parameter_suffix := l_parameter_suffix + 2;
    END IF;

    IF NOT (p_conc_parameters.DOC_NUM_FROM IS NULL AND
        p_conc_parameters.DOC_NUM_TO IS NULL) THEN
      x_query_parameter.EXTEND;
      x_query_parameter(x_query_parameter.COUNT) := nvl(p_conc_parameters.DOC_NUM_FROM,
                                                        0);
      x_query_parameter.EXTEND;
      x_query_parameter(x_query_parameter.COUNT) := nvl(p_conc_parameters.DOC_NUM_TO,
                                                        10E16);

      x_condition_sql := x_condition_sql ||
                         ' AND h.DOC_SEQUENCE_VALUE BETWEEN ' ||
                         l_parameter_prefix || (l_parameter_suffix + 1) ||
                         ' AND ' || l_parameter_prefix ||
                         (l_parameter_suffix + 2);

    END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.STRING(fnd_log.LEVEL_PROCEDURE,
                     G_MODULE_PREFIX || l_procedure_name,
                     'END procedure. ');
    END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'End get_ar_flex......');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                       G_MODULE_PREFIX || l_procedure_name ||
                       '.OTHER_EXCEPTION.',
                       '.Unknown .error.' || SQLCODE || SQLERRM);

      END IF;
      RAISE;

  END Get_Param_Cond;

  --==========================================================================
  --  PROCEDURE NAME:
  --               Get_AR_Currency_Cond
  --
  --  DESCRIPTION:
  --               This procedure returns the WHERE clause
  --               about transaction Currency code
  --
  --  PARAMETERS:
  --               In:  P_ORG_ID                NUMBER
  --                    p_transfer_id           VARCHAR2

  --               OUT: x_condition_sql         Varchar2
  --                    x_currency_code         VARCHAR2

  --  DESIGN REFERENCES:
  --               GTA-TRANSFER-PROGRAM-TD.doc
  --
  --  CHANGE HISTORY:
  --               17-AUG-2005: Jim Zheng   Created.
  --               24-Dec-2008  Yao Zhang Changed for bug 7667709
  --===========================================================================
  PROCEDURE Get_AR_Currency_Cond(p_ORG_ID        IN NUMBER,
                                 p_transfer_id   IN NUMBER,
                                 x_condition_sql OUT NOCOPY VARCHAR2,
                                 x_currency_code OUT NOCOPY VARCHAR2) IS
    l_procedure_name VARCHAR2(50) := 'Get_AR_Currency_Cond';
    l_error_string   VARCHAR2(500);

    l_parameter_token  VARCHAR2(10) := ':currency';
    l_ar_currency_code ra_customer_trx_all.Invoice_Currency_Code%TYPE;

    l_specific_currency_code ar_gta_rule_headers_all.specific_currency_code%TYPE;
    l_gta_currency_code      ar_gta_system_parameters_all.gt_currency_code%TYPE;

    --  if currency_option = A then the rule is transfer all AR trx
    --  if currency_option = G
    --  then the rule is transfer AR trx which currency code is same as gta
    --  if currency_option = O
    --  then the rule is transfer AR trx which currency code is not same as gta
    --  if currency_option = S
    --  then the rule is transfer AR trx which currency code is specific.
    l_gta_currency_option ar_gta_rule_headers_all.currency_option%TYPE;
  BEGIN

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.STRING(fnd_log.LEVEL_PROCEDURE,
                     G_MODULE_PREFIX || l_procedure_name,
                     'Begin Procedure. ');
    END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'Begin Get_AR_Currency_Cond......');
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'p_org_id:' || p_org_id || '  ' || 'p_transfer_id:' ||
          p_transfer_id);
    END IF;

    --select currency option and specific  currency code.
    BEGIN
      SELECT rule.currency_option, rule.specific_currency_code
        INTO l_gta_currency_option, l_specific_currency_code
        FROM ar_gta_rule_headers_all rule
       WHERE rule.rule_header_id = p_transfer_id;
    EXCEPTION
      -- no data found , raise a data error
      WHEN no_data_found THEN
        fnd_message.SET_NAME('AR', 'AR_GTA_MISSING_ERROR');
        l_error_string := fnd_message.get();

        -- output error
        fnd_file.put_line(fnd_file.output,
                          '<?xml version="1.0" encoding="UTF-8" ?>
                                     <TransferReport>
                                     <ReportFailed>Y</ReportFailed>
                                     <ReportFailedMsg>' ||
                          l_error_string ||
                          '</ReportFailedMsg>
                                     </TransferReport>');--Modified by Yao Zhang for bug 7667709

        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_log.STRING(fnd_log.LEVEL_UNEXPECTED,
                         G_MODULE_PREFIX || l_procedure_name,
                         'no data found when select sales_list_flag.');
        END IF;

        RAISE;
    END;

    -- get gta_currency code
    BEGIN
      SELECT op.gt_currency_code
        INTO l_gta_currency_code
        FROM ar_gta_system_parameters_all op
       WHERE op.org_id = p_ORG_ID;
    EXCEPTION
      -- no data found , raise a data error
      WHEN no_data_found THEN
        fnd_message.SET_NAME('AR', 'AR_GTA_SYS_CONFIG_MISSING');
        fnd_message.set_token('Tax_Regis_Number', ' ');
        l_error_string := fnd_message.get();

        -- output error
        fnd_file.put_line(fnd_file.output,
                          '<?xml version="1.0" encoding="UTF-8" ?>
                                     <TransferReport>
                                     <ReportFailed>Y</ReportFailed>
                                     <ReportFailedMsg>' ||
                          l_error_string ||
                          '</ReportFailedMsg>
                                     </TransferReport>');--Modified By Yao Zhang for bug 7667709

        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_log.STRING(fnd_log.LEVEL_UNEXPECTED,
                         G_MODULE_PREFIX || l_procedure_name,
                         'no data found when select sales_list_flag.');
        END IF;

        RAISE;
    END;

    IF l_gta_currency_option IS NOT NULL THEN
      IF l_gta_currency_option = 'A' THEN
        x_condition_sql := NULL;
      ELSIF l_gta_currency_option = 'G' THEN
        x_condition_sql := ' AND h.Invoice_Currency_Code = ' ||
                           l_parameter_token;
        x_currency_code := l_gta_currency_code;
      ELSIF l_gta_currency_option = 'O' THEN
        x_condition_sql := ' AND (NOT h.Invoice_Currency_Code = ' ||
                           l_parameter_token || ')';
        x_currency_code := l_gta_currency_code;
      ELSIF l_gta_currency_option = 'S' THEN
        x_condition_sql := ' AND h.Invoice_Currency_Code = ' ||
                           l_parameter_token;
        x_currency_code := l_specific_currency_code;
      END IF;
    END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.STRING(fnd_log.LEVEL_PROCEDURE,
                     G_MODULE_PREFIX || l_procedure_name,
                     'END procedure. ');
    END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'End Get_AR_Currency_Cond......');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                       G_MODULE_PREFIX || l_procedure_name ||
                       '. OTHER_EXCEPTION ',
                       'Unknown error' || SQLCODE || SQLERRM);

      END IF;
      RAISE;

  END Get_AR_Currency_Cond;

  --==========================================================================
  --  PROCEDURE NAME:
  --               Retrieve_AR_TRXs
  --
  --  DESCRIPTION:
  --               This procedure retrieve Receivable VAT transaction
  --
  --  PARAMETERS:
  --               In:  P_ORG_ID        NUMBER
  --                    p_transfer_id   VARCHAR2
  --                    P_trxtype_para  AR_GTA_TRX_UTIL.Condition_para_tbl_type
  --                    p_flex_para     AR_GTA_TRX_UTIL.Condition_para_tbl_type
  --                    p_other_para    AR_GTA_TRX_UTIL.Condition_para_tbl_type
  --                    p_currency_code VARCHAR2
  --               OUT: x_GTA_Trx_Tbl   AR_GTA_TRX_UTIL.TRX_TBL_TYPE

  --  DESIGN REFERENCES:
  --               GTA-TRANSFER-PROGRAM-TD.doc
  --
  --  CHANGE HISTORY:
  --               20-APR-2005: Jim Zheng   Created.
  --               28-Dec-2007: Subba Changed for R12.1.
  --               24-Nov-2008  Modified by Brian for bug 7591365
  --               25-Nov-2008  Modified by Brian for bug 7594218
  --               10-Dec-2008  Modified by Yao Zhang for bug 7629877
  --               24-Dec-2008  Modified by Yao Zhang for bug 7667709
  --               26-Dec-2008  Modified by Yao Zhang fix bug 7670543
  --               30-Dec-2008  Modified by Yao Zhang fix bug 7675165
  --               05-Jan-2009  Modified by Yao Zhang fix bug 7684662
  --               06-Jan-2009  Modified by Yao Zhang fix bug 7685610
  --               20-Jan-2009: Yao Zhang  Modified for bug 7721035
  --               22-Jan-2009  Yao Zhang  modified for bug 7829039
  --               01-APR-2009  Yao Zhang  modified for bug 8234250
  --               02-APR-2009  Yao Zhang  modified for bug 8241752
  --               28-APR-2009  Yao Zhang  modified for bug 7832675
  --               16-Jun-2009  Yao Zhang  modified for bug 8605196
  --               18-Aug-2009  Yao Zhang  modified for bug 8769687
  --               19-Aug-2009  Yao Zhang  modified for bug#8809860
  --               21-Sep-2009  Yao Zhang  modified for bug#8920239
  --               20-Nov-2009  Yao Zhang  modified for bug#9132371
  --               22-Jun-2010  Yao fix bug#9830678
  --===========================================================================
  PROCEDURE Retrieve_AR_TRXs(p_org_id             IN NUMBER,
                             p_transfer_id        IN NUMBER,
                             P_query_SQL          IN VARCHAR2,
                             P_trxtype_query_para IN AR_GTA_TRX_UTIL.Condition_para_tbl_type,
                             p_flex_query_para    IN AR_GTA_TRX_UTIL.Condition_para_tbl_type,
                             p_other_query_para   IN AR_GTA_TRX_UTIL.Condition_para_tbl_type,
                             p_currency_code      IN VARCHAR2,
                             x_GTA_TRX_TBL        OUT NOCOPY AR_GTA_TRX_UTIL.TRX_TBL_TYPE) IS

    l_normal_exception EXCEPTION;
    l_repeat_exception EXCEPTION;
    l_no_tax_line_exception EXCEPTION;
    l_procedure_name  VARCHAR2(30) := 'Retrieve_AR_TRXs';
    l_cursor          NUMBER;
    l_sql_exec_ret    NUMBER;
    l_trx_header      AR_GTA_TRX_UTIL.TRX_header_rec_TYPE;
    l_trx_header_init AR_GTA_TRX_UTIL.TRX_header_rec_TYPE;
    l_trx_line        AR_GTA_TRX_UTIL.TRX_line_rec_TYPE;
    l_trx_line_init   AR_GTA_TRX_UTIL.TRX_line_rec_TYPE;
    l_trx_lines       AR_GTA_TRX_UTIL.TRX_line_tbl_TYPE := AR_GTA_TRX_UTIL.TRX_line_tbl_TYPE();
    l_trx_rec         AR_GTA_TRX_UTIL.TRX_REC_TYPE;
    l_trx_rec_init    AR_GTA_TRX_UTIL.TRX_REC_TYPE;
    l_log_str         VARCHAR2(4000);
    l_error_string    VARCHAR2(1000);
    l_error_flag      NUMBER := 0;

    --credit memo
    l_gt_invoice_number AR_Gta_Trx_Headers_All.gt_invoice_number%TYPE; --VARCHAR2(30);
    l_gt_invoice_class  AR_Gta_Trx_Headers_All.GT_INVOICE_CLASS%TYPE; --VARCHAR2(10);
    l_origin_trx_id     NUMBER(15);
    l_gta_invoice_count NUMBER(15);
    l_gt_invoice_count  NUMBER(15); --added by subba for credit memo check for R12.1
    l_ar_inv_cnt        NUMBER(15);
    l_cm_excep          VARCHAR2(15);
    l_cm_excep_ar       VARCHAR2(15);
    --add begin by Yao Zhang for bug 7629877
    l_ar_inv_excep     boolean;
    l_gt_inv_excep     boolean;
    l_cm_warn          boolean;
    l_pre_cus_trxid    number;
    l_ar_invoice_count number;
    --add end by Yao Zhang or bug 7629877
    l_cm_warn2        BOOLEAN;--Yao Zhang add for bug#8605196
    l_max_amount                 NUMBER;
    l_max_num_of_line            NUMBER;
    l_vat_tax_type               ar_gta_system_parameters_all.vat_tax_type_code%TYPE;
    l_trx_line_split_flag        ar_gta_system_parameters_all.trx_line_split_flag%TYPE;
    l_gt_currency_code           ar_gta_system_parameters_all.gt_currency_code%TYPE;
    l_item_name_source_flag      ar_gta_system_parameters_all.item_name_source_flag%TYPE;
    l_cross_reference_type       ar_gta_system_parameters_all.cross_reference_type%TYPE;
    l_master_item_default_flag   ar_gta_system_parameters_all.master_item_default_flag%TYPE;
    l_latest_ref_default_flag    ar_gta_system_parameters_all.latest_ref_default_flag%TYPE;
    l_ra_line_context_code       ar_gta_system_parameters_all.ra_line_context_code%TYPE;
    l_ra_model_attribute_column  ar_gta_system_parameters_all.ra_model_attribute_column%TYPE;
    l_ra_tax_attribute_column    ar_gta_system_parameters_all.ra_tax_attribute_column%TYPE;
    l_inv_item_context_code      ar_gta_system_parameters_all.inv_item_context_code%TYPE;
    l_inv_model_attribute_column ar_gta_system_parameters_all.inv_model_attribute_column%TYPE;
    l_inv_tax_attribute_column   ar_gta_system_parameters_all.Inv_Tax_Attribute_Column%TYPE;
    l_currency_code              ar_gta_system_parameters_all.gt_currency_code%TYPE;
    l_cross_rows                 NUMBER;
    --29-JUN-2006 Updated by shujuan
    l_cross_reference MTL_CROSS_REFERENCES_B.cross_reference%TYPE;
    l_sales_list_flag VARCHAR2(1);
    -- 20-JUL-2006 Shujuan Added length from 60 to 240 for bug 5400805
    l_inventory_item_name          mtl_system_items_b.description%TYPE;
    l_inventory_attribute_category mtl_system_items_b.attribute_category%TYPE;

    -- 29-JUN-2006 Added a parameter to store the unit price of tax currency
    -- by Shujuan for bug 5168900
    p_tax_curr_unit_price NUMBER;

    -- a prefix of parameter in bind_variable command of dbms sql.
    l_arg VARCHAR2(10);

    -- a flag which adjust the trx record is new,
    -- if dul_flag>1, the trx record is old ,else is new
    l_dul_flag NUMBER := 0;

    l_customer_trx_id       ra_customer_trx_all.customer_trx_id%TYPE;
    l_trx_number            ra_customer_trx_all.trx_number%TYPE;
    l_gl_date               Ra_Cust_Trx_Line_Gl_Dist_All.Gl_Date%TYPE;
    l_set_of_books_id       ra_customer_trx_all.Set_Of_Books_Id%TYPE;
    l_bill_to_customer_id   ra_customer_trx_all.bill_to_customer_id%TYPE;
    l_trx_date              ra_customer_trx_all.trx_date%TYPE;
    l_invoice_Currency_code ra_customer_trx_all.invoice_currency_code%TYPE;
    l_exchange_rate_type    ra_customer_trx_all.exchange_rate_type%TYPE;
    l_exchange_rate         ra_customer_trx_all.exchange_rate%TYPE;
    l_ctt_class             ra_cust_trx_types_all.type%TYPE;
    l_period_name           GL_PERIODS.Period_Name%TYPE;
    l_ct_reference          ra_customer_trx_all.ct_reference%TYPE;

    l_invoice_type ar_gta_tax_limits_all.invoice_type%TYPE;

    l_raa_bill_to_concat_address VARCHAR2(500);
    l_cust_addr_excep            VARCHAR2(20); --added by subba for R12.1
    l_cust_phone_exp             VARCHAR2(20);
    l_phone_number               Hz_Contact_Points.Phone_Number%TYPE;
    l_apb_customer_bank_name     CE_Bank_Branches_V.Bank_Name%TYPE;
    l_apb_bank_branch_name       CE_Bank_Branches_V.Bank_Branch_Name%TYPE;
    l_apba_bank_account_num      CE_Bank_Accounts.Bank_Account_num%TYPE;
    l_apba_bank_account_name     CE_Bank_Accounts.Bank_Account_Name%TYPE;

    l_rac_bill_to_customer_name Hz_Parties.PARTY_NAME%TYPE;
    l_rac_bill_to_customer_num  Hz_Cust_Accounts.ACCOUNT_NUMBER%TYPE;
    l_bill_to_taxpayer_id       Hz_Parties.JGZZ_FISCAL_CODE%TYPE;

    l_customer_trx_line_id   ra_customer_trx_lines_all.customer_trx_line_id%TYPE;
    l_description            ra_customer_trx_lines_all.description%TYPE;
    l_inventory_item_id      ra_customer_trx_lines_all.inventory_item_id%TYPE;
    l_interface_line_context ra_customer_trx_lines_all.interface_line_context%TYPE;
    l_uom_code               ra_customer_trx_lines_all.uom_code%TYPE;
    l_unit_of_measure        mtl_units_of_measure_vl.unit_of_measure%TYPE;
    l_quantity_credited      ra_customer_trx_lines_all.quantity_credited%TYPE;

    --12/06/2006   Added a parameter to instore the transaction line number
    --by Shujuan Yan for bug 5230712
    l_customer_trx_line_number ra_customer_trx_lines_all.line_number%TYPE;

    l_amount ra_customer_trx_lines_all.taxable_amount%TYPE;

    -- for get bank info by customer id
    l_site_use_id       hz_cust_site_uses.SITE_USE_ID%TYPE;
    l_cust_acct_site_id hz_cust_acct_sites.CUST_ACCT_SITE_ID%TYPE;

    l_cm_export_iv        VARCHAR2(500);
    l_cm_export_nr        VARCHAR2(500);
    l_index               NUMBER; -- index of the nested table
    l_cust_trx_id_count   NUMBER; -- the trx count of
    l_trx_id_cancel_count NUMBER; -- the trx count of Statuts is 'CANCEL'
    l_trx_line_num        NUMBER;
    l_conc_succ           BOOLEAN; -- the status of concurrent
    l_warning_count       NUMBER;

    -- for split test
    l_quantity_invoiced  NUMBER;
    l_unit_selling_price NUMBER;

    l_tax_line_count  NUMBER;
    l_legal_entity_id ra_customer_trx_all.legal_entity_id%TYPE;

    -- the data get from ebtax
    l_tax_amount_func_curr     zx_lines.tax_amt_funcl_curr%TYPE;
    l_taxable_amount_func_curr zx_lines.taxable_amt_funcl_curr%TYPE;
    l_line_quantity            zx_lines.trx_line_quantity%TYPE;
    l_tax_rate                 zx_lines.tax_rate%TYPE;
    l_unit_price               zx_lines.unit_price%TYPE;
    l_fp_registration_number   zx_lines.tax_registration_number%TYPE;
    l_tp_registration_number   zx_lines.tax_registration_number%TYPE;

    -- for get the error message from get_info_from_ebtax
    l_status             NUMBER;
    l_proce_error_buffer VARCHAR2(180);

    -- for check the third party tax registration number
    l_tp_regi_number_first zx_lines.tax_registration_number%TYPE;
    l_trx_line_index       NUMBER;
    l_tp_regi_number       zx_lines.tax_registration_number%TYPE;
    l_trx_typ              ra_cust_trx_types_all.name%TYPE; --added by subba
    l_cm_desc1             varchar2(50);--added by Yao Zhang for bug 7685610
    l_cm_desc2             varchar2(50);--added by Yao Zhang for bug 7685610
    l_master_org           HR_ORGANIZATION_UNITS.organization_id%TYPE; --yao zhang add for bug 7721035

    --Yao Zhang Add for bug#8605196 to support discount line
    l_discount_amount           ar_gta_trx_lines_all.discount_amount%TYPE;
    l_discount_tax_amount       ar_gta_trx_lines_all.discount_tax_amount%TYPE;
    l_discount_rate             ar_gta_trx_lines_all.discount_rate%TYPE;
    l_discount_tax_rate         ar_gta_trx_lines_all.discount_rate%TYPE;
    l_order_number              ra_customer_trx_lines_all.interface_line_attribute1%TYPE;
    l_om_line_id                ra_customer_trx_lines_all.interface_line_attribute1%TYPE;
    l_discount_adjustment_id    ra_customer_trx_lines_all.interface_line_attribute11%TYPE;
    l_price_adjustment_id       ra_customer_trx_lines_all.interface_line_attribute1%TYPE;
    l_adjustment_type           OE_PRICE_ADJUSTMENTS.list_line_type_code%TYPE;
    l_discount_cust_trx_line_id ra_customer_trx_lines_all.customer_trx_line_id%TYPE;
    l_discount_flag             ar_gta_trx_lines_all.discount_flag%TYPE;
    l_tax_amount                ar_gta_trx_lines_all.tax_amount%TYPE;
    l_discount_amount_func_curr  ar_gta_trx_lines_all.discount_amount%TYPE;--Yao add for bug#9132371
   -- Yao Modified for bug#8605196 to support discount line
   l_actual_unit_price        NUMBER;--yao add for bug 9045187
   l_discount_on_invoice      VARCHAR2(1); --Yao add for bug#9830678
    CURSOR c_ra_lines(l_header_id IN NUMBER) IS
      SELECT l.customer_trx_line_id,
             l.description,
             l.inventory_item_id,
             l.interface_line_context,
             l.uom_code,
             l.revenue_amount,
             l.unit_selling_price,
             l.quantity_invoiced,
             l.quantity_credited,
             l.line_number, --12/06/2006 line number,Added by Shujuan bug 5230712
             --Add by Yao Zhang begin for bug#8605196 to support Discount line
             l.interface_line_attribute1,--order number
             l.interface_line_attribute6,--line id
             l.interface_line_attribute11--price adjustment id
             --Add by Yao Zhang end for bug#8605196 to support Discount line
        FROM ra_customer_trx_lines_all l
       WHERE l.line_type = 'LINE'
         AND l.customer_trx_id = l_header_id;
  --Yao Zhang Add for bug#8605196 to support discount line
  --c_discount_lines used to query discount lines for ar transaction line.
	CURSOR c_discount_lines(l_line_id IN NUMBER) IS
       SELECT opa.price_adjustment_id
         FROM oe_price_adjustments opa
        WHERE opa.line_id = l_line_id
          AND opa.list_line_type_code = 'DIS';

  BEGIN

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.STRING(fnd_log.LEVEL_PROCEDURE,
                     G_MODULE_PREFIX || l_procedure_name,
                     'Begin Procedure. ');
    END IF;

    -- init x_GTA_TRX_TBL
    x_GTA_TRX_TBL := AR_GTA_TRX_UTIL.TRX_TBL_TYPE();

    l_log_str := p_query_sql;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                     G_MODULE_PREFIX || l_procedure_name || '.DYNAMIC SQL ',
                     l_log_str);
    END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'Begin Retrieve_AR_TRXs......');
    END IF;

    -- begin select parameters
    --select parameters from AR_GTA_SYSTEM_PARAMETERS_ALL dependence org_id
    BEGIN
      SELECT vat_tax_type_code,
             trx_line_split_flag,
             gt_currency_code,
             item_name_source_flag,
             cross_reference_type,
             master_item_default_flag,
             latest_ref_default_flag,
             ra_line_context_code,
             ra_model_attribute_column,
             ra_tax_attribute_column,
             inv_item_context_code,
             inv_model_attribute_column,
             inv_tax_attribute_column,
             gt_currency_code
        INTO l_vat_tax_type,
             l_trx_line_split_flag,
             l_gt_currency_code,
             l_item_name_source_flag,
             l_cross_reference_type,
             l_master_item_default_flag,
             l_latest_ref_default_flag,
             l_ra_line_context_code,
             l_ra_model_attribute_column,
             l_ra_tax_attribute_column,
             l_inv_item_context_code,
             l_inv_model_attribute_column,
             l_inv_tax_attribute_column,
             l_currency_code
        FROM ar_gta_system_parameters_all
       WHERE org_id = p_org_id;

    EXCEPTION
      WHEN no_data_found THEN
        --report AR_GTA_MISSING_ERROR
        fnd_message.set_name('AR', 'AR_GTA_SYS_CONFIG_MISSING');
        fnd_message.set_token('Tax_Regis_Number', ' ');
        l_error_string := fnd_message.get();
        -- output this error
        fnd_file.put_line(fnd_file.output,
                          '<?xml version="1.0" encoding="UTF-8"?>
                        <TransferReport>
                        <ReportFailed>Y</ReportFailed>
                        <ReportFailedMsg>' ||
                          l_error_string ||
                          '</ReportFailedMsg>
                        </TransferReport>');--Modified By Yao Zhang for bug 7667709

        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_log.STRING(fnd_log.LEVEL_UNEXPECTED,
                         G_MODULE_PREFIX || l_procedure_name,
                         l_error_string);
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        RETURN;
    END;

    -- select sales_list_flag from rule_table
    BEGIN
      SELECT sales_list_flag
        INTO l_sales_list_flag
        FROM ar_gta_rule_headers_all
       WHERE ar_gta_rule_headers_all.rule_header_id = p_transfer_id;
    EXCEPTION
      -- no data found , raise a data error
      WHEN no_data_found THEN
        fnd_message.SET_NAME('AR', 'AR_GTA_SYS_CONFIG_MISSING');
        fnd_message.set_token('Tax_Regis_Number', ' ');
        l_error_string := fnd_message.get();
        -- output error
        fnd_file.put_line(fnd_file.output,
                          '<?xml version="1.0" encoding="UTF-8"?>
                        <TransferReport>
                        <ReportFailed>Y</ReportFailed>
                        <ReportFailedMsg>' ||
                          l_error_string ||
                          '</ReportFailedMsg>
                        </TransferReport>');--Modified By Yao Zhang for bug 7667709

        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_log.STRING(fnd_log.LEVEL_UNEXPECTED,
                         G_MODULE_PREFIX || l_procedure_name,
                         'no data found when select sales_list_flag.');
        END IF;
        RAISE;
        RETURN;
    END;
    --end select parameters

    --open cursor
    l_cursor := dbms_sql.open_cursor;

    --parse the sql string;
    dbms_sql.parse(l_cursor, p_query_sql, dbms_sql.v7);

    -- bind variable;
    dbms_sql.bind_variable(l_cursor, 'p_org_id', p_org_id);

    -- bind trxtype_query_para
    l_index := p_trxtype_query_para.FIRST;

    WHILE l_index IS NOT NULL LOOP
      l_arg := 'trxtype' || l_index;
      dbms_sql.bind_variable(l_cursor,
                             l_arg,
                             p_trxtype_query_para(l_index));
      l_index := P_trxtype_query_para.NEXT(l_index);
    END LOOP;

    -- bind flex_query_para
    l_index := p_flex_query_para.FIRST;
    WHILE l_index IS NOT NULL LOOP
      l_arg := 'flex' || l_index;
      dbms_sql.bind_variable(l_cursor, l_arg, p_flex_query_para(l_index));
      l_index := p_flex_query_para.NEXT(l_index);
    END LOOP;

    -- bind other_query_para
    l_index := p_other_query_para.FIRST;
    WHILE l_index IS NOT NULL LOOP
      l_arg := 'para' || l_index;
      dbms_sql.bind_variable(l_cursor, l_arg, p_other_query_para(l_index));
      l_index := p_other_query_para.NEXT(l_index);
    END LOOP;

    -- bind the condition of currency code.
    IF p_currency_code IS NOT NULL THEN
      dbms_sql.bind_variable(l_cursor, 'currency', p_currency_code);
    END IF;

    --define column
    dbms_sql.define_column(l_cursor, 1, l_customer_trx_id);

    --EXECUTE!
    l_sql_exec_ret := dbms_sql.EXECUTE(l_cursor);

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'Begin cursor loop......');
    END IF;

    LOOP
      BEGIN
        -- for l_normal_exception

        l_sql_exec_ret := dbms_sql.fetch_rows(l_cursor);

        --initializing all the varibales required for exception
        l_ar_inv_excep      := null;
        l_cm_excep          := null;
        l_cust_addr_excep   := null;
        l_cust_phone_exp    := null;
        l_ar_inv_cnt        := 0;
        l_gta_invoice_count := 0;
        l_gt_invoice_count  := 0;

        IF l_sql_exec_ret = 0 THEN
          EXIT;
        END IF;

        -- init trx header and trx lines
        l_trx_header := l_trx_header_init;
        l_trx_lines  := AR_GTA_TRX_UTIL.TRX_line_tbl_TYPE();
        l_error_flag := 0;

        -- get customer_trx_id of the AR_trx_header
        dbms_sql.column_value(l_cursor, 1, l_customer_trx_id);

        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          log(FND_LOG.LEVEL_PROCEDURE,
              G_MODULE_PREFIX || l_procedure_name,
              '****************************************');
          log(FND_LOG.LEVEL_PROCEDURE,
              G_MODULE_PREFIX || l_procedure_name,
              'l_customer_trx_id : ' || l_customer_trx_id);
          log(FND_LOG.LEVEL_PROCEDURE,
              G_MODULE_PREFIX || l_procedure_name,
              '****************************************');
        END IF;

        -- select this customer_trx_id in GTA, if there is existing of this id,
        -- Select the status of it, if the status of 'CANCEL',
        -- and Last_update_flag is 'Y', and version > 1; then delete the record
        -- and retransfer it , else if the cust_trx_id exist, don't transfer it,
        -- else if the cust_trx_id is not exist, transfer it.
        SELECT COUNT(*)
          INTO l_cust_trx_id_count
          FROM ar_gta_trx_headers_all h
         WHERE h.ra_trx_id = l_customer_trx_id;

        IF l_cust_trx_id_count > 0 THEN
          SELECT COUNT(*)
            INTO l_trx_id_cancel_count
            FROM ar_gta_trx_headers_all h
           WHERE h.ra_trx_id = l_customer_trx_id
             AND h.latest_version_flag = 'Y'
             AND h.status = 'CANCEL'
             AND h.version > 1;

          IF l_trx_id_cancel_count > 0 THEN
            DELETE ar_gta_trx_headers_all h
             WHERE h.ra_trx_id = l_customer_trx_id
               AND h.latest_version_flag = 'Y'
               AND h.status = 'CANCEL'
               AND h.version > 1;
          ELSE
            RAISE l_repeat_exception;
          END IF;

        END IF;

        SELECT COUNT(*)
          INTO l_trx_line_num
          FROM ra_customer_trx_lines_all l
         WHERE l.customer_trx_id = l_customer_trx_id;

        IF l_trx_line_num = 0 THEN
          RAISE l_repeat_exception;
        END IF;

        -- begin select other information by customer_trx_id

        -- select other columns and address, phone, etc.
        -- select header info
        BEGIN
          SELECT h.trx_number,
                 gd.gl_date,
                 h.set_of_books_id,
                 h.bill_to_customer_id,
                 h.trx_date,
                 h.Invoice_Currency_Code,
                 h.exchange_rate_type,
                 h.exchange_rate,
                 h.legal_entity_id,
                 h.ct_reference,
                 ctt.TYPE,
                 gp.period_name
            INTO l_trx_number,
                 l_gl_date,
                 l_set_of_books_id,
                 l_bill_to_customer_id,
                 l_trx_date,
                 l_invoice_Currency_code,
                 l_exchange_rate_type,
                 l_exchange_rate,
                 l_legal_entity_id,
                 l_ct_reference,
                 l_ctt_class,
                 l_period_name
            FROM ra_customer_trx_all          h,
                 ra_cust_trx_types_all        ctt,
                 ra_batches_all               b,
                 Ra_Cust_Trx_Line_Gl_Dist_All gd,
                 Hz_Parties                   RAC_BILL_PARTY,
                 Hz_Cust_Accounts             RAC_BILL,
                 GL_PERIODS                   GP -- period
           WHERE h.complete_flag = 'Y'
             AND h.CUST_TRX_TYPE_ID = ctt.CUST_TRX_TYPE_ID(+)
             AND ctt.TYPE IN ('INV', 'CM', 'DM')
             AND h.batch_id = b.batch_id(+)
             AND GD.CUSTOMER_TRX_ID = h.CUSTOMER_TRX_ID
             AND GD.ACCOUNT_CLASS = 'REC'
             AND GD.LATEST_REC_FLAG = 'Y'
             AND h.bill_to_customer_id = RAC_BILL.CUST_ACCOUNT_ID
             AND rac_bill.party_id = RAC_BILL_PARTY.Party_Id
             AND h.Org_Id = gd.Org_Id
             AND h.Org_Id = ctt.Org_Id
             AND h.Org_Id = p_org_id
             AND GP.PERIOD_SET_NAME =
                 (SELECT period_set_name
                    FROM Gl_Sets_Of_Books
                   WHERE set_of_books_id = h.set_of_books_id)
             AND gp.period_type =
                 (SELECT accounted_period_type
                    FROM Gl_Sets_Of_Books
                   WHERE set_of_books_id = h.set_of_books_id)
             AND gp.adjustment_period_flag = 'N'
             AND gp.start_date <= gd.GL_DATE
             AND gp.end_date >= gd.gl_date
             AND h.customer_trx_id = l_customer_trx_id;

        EXCEPTION
          WHEN no_data_found THEN
            IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              fnd_log.STRING(fnd_log.LEVEL_EXCEPTION,
                             G_MODULE_PREFIX || l_procedure_name,
                             'no date found when select header info');
            END IF;
            RAISE;
        END;

        -- select l_raa_bill_to_concat_address
        BEGIN
          SELECT
          --Modified by Yao to support customer address in Chinese
          DECODE(RAA_BILL.CUST_ACCT_SITE_ID,
                        NULL,
                        NULL,
                        decode(RAA_BILL_LOC.Address_Lines_Phonetic,
                               null,
                        ARH_ADDR_PKG.ARXTW_FORMAT_ADDRESS(RAA_BILL_LOC.ADDRESS_STYLE,
                                                          RAA_BILL_LOC.ADDRESS1,
                                                          RAA_BILL_LOC.ADDRESS2,
                                                          RAA_BILL_LOC.ADDRESS3,
                                                          RAA_BILL_LOC.ADDRESS4,
                                                          RAA_BILL_LOC.CITY,
                                                          RAA_BILL_LOC.COUNTY,
                                                          RAA_BILL_LOC.STATE,
                                                          RAA_BILL_LOC.PROVINCE,
                                                          RAA_BILL_LOC.POSTAL_CODE,
                                                          FT_BILL.TERRITORY_SHORT_NAME),
                                                          RAA_BILL_LOC.Address_Lines_Phonetic))
            INTO l_raa_bill_to_concat_address
            FROM HZ_CUST_SITE_USES_ALL  SU_BILL,
                 Hz_Cust_Acct_Sites_All RAA_BILL,
                 HZ_PARTY_SITES         RAA_BILL_PS,
                 Hz_Locations           RAA_BILL_LOC,
                 FND_TERRITORIES_VL     FT_BILL,
                 ra_customer_trx_all    h
           WHERE h.BILL_TO_SITE_USE_ID = SU_BILL.SITE_USE_ID
             AND SU_BILL.CUST_ACCT_SITE_ID = RAA_BILL.CUST_ACCT_SITE_ID
             AND RAA_BILL.PARTY_SITE_ID = RAA_BILL_PS.PARTY_SITE_ID
             AND RAA_BILL_PS.LOCATION_ID = RAA_BILL_LOC.LOCATION_ID
             AND RAA_BILL_LOC.COUNTRY = FT_BILL.TERRITORY_CODE(+)
             AND h.customer_trx_id = l_customer_trx_id;
        EXCEPTION
          WHEN no_data_found THEN
            IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              fnd_log.STRING(fnd_log.LEVEL_EXCEPTION,
                             G_MODULE_PREFIX || l_procedure_name,
                             'no date found when select l_raa_bill_to_concat_address');
            END IF;
            --modified by subba for R12.1
            -- RAISE;
            l_cust_addr_excep := 'true';
        END;

        -- 29/06/2006 Deleted by Shujuan Yan for bug 5263131,
        -- Since if tansaction type is credit memo, the paying customer is null,
        -- can not get bank information.
        /*
          -- call util procedure to get bank info
          ar_gta_trx_util.get_bank_info( p_customer_trx_id => l_customer_trx_id
                                     ,p_org_id            => p_org_id
                                     ,x_bank_name         => l_apb_customer_bank_name
                                     ,x_bank_branch_name  => l_apb_bank_branch_name
                                     ,x_bank_account_name => l_apba_bank_account_name
                                     ,x_bank_account_num  => l_apba_bank_account_num
                                         );
        */
        --29/06/2006 end for bug 5263131

        -- select phone number
        BEGIN
          SELECT p.phone_number
            INTO l_phone_number
            FROM Hz_Contact_Points   p
                 --Yao delete for bug#8769687 begin
                 --,Hz_Cust_Accounts    RAC_BILL
                 --,Hz_Parties          RAC_BILL_PARTY
                 --Yao delete end for bug#8769687
                 ,ra_customer_trx_all h
                 --Yao add for bug#8769687
                 ,hz_party_sites        hps
                 ,hz_cust_acct_sites_all hcasa
                 ,hz_cust_site_uses_all  hcsua
                 --Yao add end
           WHERE -- h.bill_to_customer_id can find by customer trx id
           --h.bill_to_customer_id = RAC_BILL.CUST_ACCOUNT_ID
          -- AND rac_bill.party_id = RAC_BILL_PARTY.Party_Id
           --AND RAC_BILL_PARTY.Party_Id = p.owner_table_id(+)
          --Yao Zhang add for bug#8769687 begin
               h.bill_to_site_use_id=hcsua.SITE_USE_ID
           AND hcsua.cust_acct_site_id =hcasa.cust_acct_site_id
           AND hps.party_site_id=hcasa.party_site_id
           AND p.owner_table_id(+)=hcasa.party_site_id
           --Yao add or bug#8769687 end
           AND p.owner_table_name(+) = 'HZ_PARTY_SITES'
           AND p.CONTACT_POINT_TYPE(+) = 'PHONE'
           AND p.primary_flag(+) = 'Y'
           AND h.customer_trx_id = l_customer_trx_id;

        EXCEPTION
          WHEN no_data_found THEN
            IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              fnd_log.STRING(fnd_log.LEVEL_EXCEPTION,
                             G_MODULE_PREFIX || l_procedure_name,
                             'no date found when select phone number');
            END IF;

            --modified by subba for R12.1
            --RAISE;
            l_cust_phone_exp := 'true';
        END;

        BEGIN
          --select rac information
          SELECT
          --Modified by Yao begin for bug#8605196 to support customer name in Chinese
          --RAC_BILL_PARTY.PARTY_NAME,
                 decode(RAC_BILL_PARTY.Known_As
                        ,null,RAC_BILL_PARTY.PARTY_NAME
                        ,RAC_BILL_PARTY.Known_As),
          --Modified by Yao end for bug#8605196 to support customer name in Chinese
                 RAC_BILL.ACCOUNT_NUMBER,
                 RAC_BILL_PARTY.JGZZ_FISCAL_CODE
            INTO l_rac_bill_to_customer_name,
                 l_rac_bill_to_customer_num,
                 l_bill_to_taxpayer_id
            FROM ra_customer_trx_all h,
                 Hz_Cust_Accounts    rac_bill,
                 Hz_Parties          rac_bill_party
           WHERE h.customer_trx_id = l_customer_trx_id
             AND h.bill_to_customer_id = RAC_BILL.CUST_ACCOUNT_ID
             AND rac_bill.party_id = RAC_BILL_PARTY.Party_Id;

        EXCEPTION
          WHEN no_data_found THEN
            IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              fnd_log.STRING(fnd_log.LEVEL_EXCEPTION,
                             G_MODULE_PREFIX || l_procedure_name,
                             'no data found when select rac information');
            END IF;
            RAISE;
        END;
        -- end select other information by customer_trx_id

        --28/12/2007 changed the code by subba for R12.1, becoz we need to remove validation on credit memo

        -- 11/06/2006 Changed message code from AR_GTA_CRMEMO_MISSING_ARINV
        -- to AR_GTA_CRMEMO_MISSING_GTINV by Shujuan Yan for bug 5263308
        -- begin creidt memo exception validate

        -- Modified by brian for bug 7591365
        /*IF l_ctt_class = 'CM' THEN

              IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
              THEN
                log(FND_LOG.LEVEL_PROCEDURE,G_MODULE_PREFIX
                                          || l_procedure_name,
                                          '****************************************');
                log(FND_LOG.LEVEL_PROCEDURE,G_MODULE_PREFIX
                                          || l_procedure_name,
                                          'is CM');
                log(FND_LOG.LEVEL_PROCEDURE,G_MODULE_PREFIX
                                          || l_procedure_name,
                                          '****************************************');
              END IF;
                            --checking whether CM is associated with AR invoice or not

              SELECT count(*)
              INTO  l_ar_inv_cnt
              FROM AR_RECEIVABLE_APPLICATIONS_ALL APP
              , AR_PAYMENT_SCHEDULES_ALL PS_INV
              WHERE APP.APPLIED_PAYMENT_SCHEDULE_ID = PS_INV.PAYMENT_SCHEDULE_ID
              AND app.ORG_ID = p_org_id
              AND app.CUSTOMER_TRX_ID  = l_customer_trx_id
              AND app.display = 'Y';

               IF l_ar_inv_cnt = 0 THEN     --no AR inv for CM

                   l_ar_inv_excep := 'true';


               ELSE

               FOR l_ar_cur IN (SELECT  PS_INV.CUSTOMER_TRX_ID trx_id
              FROM AR_RECEIVABLE_APPLICATIONS_ALL APP
              , AR_PAYMENT_SCHEDULES_ALL PS_INV
              WHERE APP.APPLIED_PAYMENT_SCHEDULE_ID = PS_INV.PAYMENT_SCHEDULE_ID
              AND app.ORG_ID = p_org_id
              AND app.CUSTOMER_TRX_ID  = l_customer_trx_id
                  AND app.display = 'Y')
               LOOP

               l_origin_trx_id := l_ar_cur.trx_id;   --taking the AR trx id for which credit memo assigned for getting Bank info

                     --Try to select VAT invoice details for all AR invoices associated with credit memo.

                SELECT
                    count(*)
                INTO
                  l_gta_invoice_count

                FROM
                  AR_Gta_Trx_Headers_All
                WHERE ra_trx_id=l_ar_cur.trx_id
                  AND SOURCE = 'AR';

                IF l_gta_invoice_count > 0 THEN   --credit memo associated to AR invoice which is transferred to GTA

                    --checking AR invoice processed in Workbench or not

            SELECT
                count(*)
            INTO
              l_gt_invoice_count

            FROM
              AR_Gta_Trx_Headers_All
            WHERE ra_trx_id=l_ar_cur.trx_id
              AND SOURCE = 'GT';

               IF l_gt_invoice_count = 0 THEN   --AR trx is in workbench but VAT not generated.

               l_cm_excep := 'true';
               EXIT;

                END IF;--/*IF l_gt_invoice_number = 0 THEN

           END IF;  --/*  IF l_gta_invoice_count > 0 THEN

               END LOOP; --/* cusrsor end

            END IF; --/*IF l_ar_inv_cnt = 0 THEN

          END IF; --/*end if l_ctt_class= 'CM'
        */

        -- Above commented by Brian for bug 7591365

        -- end validate CM trx
        -- 11/06/2006 Ended for bug 5263308

        --end relaxing validation on CM for R12.1

        -- begin insert value into l_trx_header
        SELECT ar_gta_trx_headers_all_s.NEXTVAL
          INTO l_trx_header.gta_trx_header_id
          FROM dual;

  --yao zhang add for bug 8234250 begin
          SELECT previous_customer_trx_id
          INTO l_origin_trx_id
          FROM ra_customer_trx_all
          WHERE customer_trx_id = l_customer_trx_id;
  --yao zhang add end for bug 8234250

        --29/06/2006 Added by Shujuan Yan for bug 5263131
        IF l_origin_trx_id IS NOT NULL THEN
          -- call util procedure to get bank info for 'CM',
          -- since paying customer is null, have to use the original invoice
          --The following code is changed by Yao Zhang for bug 8234250
      ar_gta_trx_util.get_cm_bank_info(p_customer_trx_id   => l_customer_trx_id,
                                         p_org_id            => p_org_id,
                                         p_original_trx_id  => l_origin_trx_id,
                                         x_bank_name         => l_apb_customer_bank_name,
                                         x_bank_branch_name  => l_apb_bank_branch_name,
                                         x_bank_account_name => l_apba_bank_account_name,
                                         x_bank_account_num  => l_apba_bank_account_num);
       --Yao Zhang changed end for bug 8234250
        ELSE

          ar_gta_trx_util.get_bank_info(p_customer_trx_id   => l_customer_trx_id,
                                         p_org_id            => p_org_id,
                                         x_bank_name         => l_apb_customer_bank_name,
                                         x_bank_branch_name  => l_apb_bank_branch_name,
                                         x_bank_account_name => l_apba_bank_account_name,
                                         x_bank_account_num  => l_apba_bank_account_num);
        END IF; /*l_origin_trx_id IS NOT NULL  THEN*/

        l_trx_header.ra_gl_date              := l_gl_date;
        l_trx_header.ra_gl_period            := l_period_name;
        l_trx_header.set_of_books_id         := l_set_of_books_id;
        l_trx_header.bill_to_customer_id     := l_bill_to_customer_id;
        l_trx_header.bill_to_customer_number := l_rac_bill_to_customer_num;
        l_trx_header.bill_to_customer_name   := l_rac_bill_to_customer_name;
        l_trx_header.SOURCE                  := 'AR';
        l_trx_header.org_id                  := p_org_id;
        l_trx_header.rule_header_id          := p_transfer_id;

        l_trx_header.group_number        := 1;
        l_trx_header.version             := 1;
        l_trx_header.latest_version_flag := 'Y';
        l_trx_header.transaction_date    := l_trx_date;
        l_trx_header.ra_trx_id           := l_customer_trx_id;
        l_trx_header.ra_trx_number       := l_trx_number;

        --09/06/2006  Updated by Shujuan Yan for bug 5255993
        --Added transaction number to the header description
        --modified by subba for R12.1

        --IF l_ctt_class <> 'CM'
        --THEN
        l_trx_header.description := l_ct_reference || l_trx_number;
        --END IF;--l_ctt_class <> 'CM'

        l_trx_header.customer_address         := l_raa_bill_to_concat_address;
        l_trx_header.customer_phone           := l_phone_number;
        l_trx_header.customer_address_phone   := l_raa_bill_to_concat_address || ' ' ||
                                                 l_phone_number; -- a + b
        l_trx_header.bank_account_name        := l_apb_customer_bank_name || ' ' ||
                                                 l_apb_bank_branch_name;
        l_trx_header.bank_account_number      := l_apba_bank_account_num;
        l_trx_header.bank_account_name_number := l_apb_customer_bank_name || ' ' ||
                                                 l_apb_bank_branch_name || ' ' ||
                                                 l_apba_bank_account_num;
        l_trx_header.legal_entity_id          := l_legal_entity_id;
        l_trx_header.ra_currency_code         := l_invoice_Currency_code;
        l_trx_header.conversion_date          := l_trx_date;
        l_trx_header.status                   := 'DRAFT';
        l_trx_header.sales_list_flag          := l_sales_list_flag;
        l_trx_header.cancel_flag              := 'N';
        l_trx_header.request_id               := fnd_global.CONC_REQUEST_ID();
        l_trx_header.program_application_id   := fnd_global.PROG_APPL_ID();
        l_trx_header.program_id               := fnd_global.CONC_PROGRAM_ID;
        l_trx_header.program_update_date      := SYSDATE;
        l_trx_header.creation_date            := SYSDATE;
        l_trx_header.created_by               := fnd_global.LOGIN_ID();
        l_trx_header.last_update_date         := SYSDATE;
        l_trx_header.last_updated_by          := fnd_global.LOGIN_ID();
        l_trx_header.last_update_login        := fnd_global.LOGIN_ID();
        --Yao Zhang fix bug 7832675 add begin.
        l_trx_header.conversion_type          :=l_exchange_rate_type;
        l_trx_header.conversion_rate          :=l_exchange_rate;
        --Yao Zhang fix bug 7832675 add end

        -- end insert data into trx_header

        -- begin fetch lines, and insert all value into trx_line;
        -- init l_trx_lines
        l_trx_lines := AR_GTA_TRX_UTIL.TRX_line_tbl_TYPE();
         --Yao add for bug#9830678
         BEGIN
          SELECT parameter_value
            INTO l_discount_on_invoice
            FROM oe_sys_parameters_all
           WHERE org_id = p_org_id
             AND parameter_code = 'OE_DISCOUNT_DETAILS_ON_INVOICE';
         EXCEPTION
            WHEN OTHERS THEN
            IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                       G_MODULE_PREFIX || l_procedure_name ||
                       '. OTHER_EXCEPTION ',
                       'Unknown error' || SQLCODE || SQLERRM);
            END IF;
            RAISE;
         END;
        --Yao add end for bug#9830678
        OPEN c_ra_lines(l_customer_trx_id);
        LOOP
          -- init l_trx_line
          l_trx_line := l_trx_line_init;
          FETCH c_ra_lines
            INTO l_customer_trx_line_id
            , l_description
            , l_inventory_item_id
            , l_interface_line_context
            , l_uom_code
            , l_amount
            , l_unit_selling_price
            , l_quantity_invoiced
            , l_quantity_credited
            , l_customer_trx_line_number
            --add by Yao for bug#8605196 to support discount line
            , l_order_number
            , l_om_line_id
            , l_price_adjustment_id;

          EXIT WHEN c_ra_lines%NOTFOUND;
          --init variables
          l_discount_amount:=NULL;
          l_discount_tax_rate:=NULL;
          l_discount_tax_amount:=NULL;
          l_discount_rate:=NULL;
          l_adjustment_type:=null;
          l_tax_amount:=NULL;
          l_discount_flag:=NULL;
          l_discount_amount_func_curr:=NULL;--yao add for bug#9132371
--The following code is added by Yao Zhang for bug#8605196 to support discount line
        IF l_discount_on_invoice='Y'
        THEN
          IF(l_interface_line_context='ORDER ENTRY' and l_price_adjustment_id=0)
          THEN--the original transction line
            OPEN c_discount_lines(l_om_line_id);
            LOOP
              FETCH c_discount_lines INTO l_discount_adjustment_id;
              EXIT WHEN c_discount_lines%NOTFOUND;
              l_discount_flag:='1';
          --calculate discount amount
          BEGIN
               SELECT rctl.revenue_amount + nvl(l_discount_amount, 0),
                      tax.taxable_amt_tax_curr +   --yao add for bug 9132371
                      nvl(l_discount_amount_func_curr, 0),
                      rctl.customer_trx_line_id
                 INTO l_discount_amount,
                      l_discount_amount_func_curr,
                      l_discount_cust_trx_line_id
                 FROM ra_customer_trx_lines_all rctl, zx_lines tax
                WHERE rctl.customer_trx_id = l_customer_trx_id
                  AND rctl.line_type = 'LINE'
                  AND rctl.interface_line_attribute11 =
                      l_discount_adjustment_id
                  AND rctl.customer_trx_line_id = tax.trx_line_id
                  --yao add begin for bug 9132371
                  AND tax.entity_code = 'TRANSACTIONS'
                  AND tax.application_id = 222
                  AND tax.trx_level_type = 'LINE'
                  AND tax.tax_currency_code = l_currency_code
                  AND tax.tax_type_code = l_vat_tax_type
                  AND tax.trx_id = l_customer_trx_id;
                 --yao add end for bug#9132371
          --Calculate the tax discount amount
               SELECT tax.tax_amt_tax_curr + nvl(l_discount_tax_amount, 0)
                 INTO l_discount_tax_amount
                 FROM zx_lines tax
                WHERE tax.trx_line_id = l_discount_cust_trx_line_id
                  AND tax.entity_code = 'TRANSACTIONS'
                  AND tax.application_id = 222
                  AND tax.trx_level_type = 'LINE'
                  AND tax.tax_currency_code = l_currency_code
                  AND tax.tax_type_code = l_vat_tax_type
                  AND tax.trx_id = l_customer_trx_id;
            --Yao add for bug#9830678
            EXCEPTION
            WHEN no_data_found THEN
            NULL;
            WHEN OTHERS THEN
            IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                       G_MODULE_PREFIX || l_procedure_name ||
                       '. OTHER_EXCEPTION ',
                       'Unknown error' || SQLCODE || SQLERRM);
            END IF;
            RAISE;
            END;
            --Yao add end for bug#9830678
            END LOOP;/*c_discount_lines*/
            CLOSE c_discount_lines;
          --Get tax amount
            SELECT tax.tax_amt_tax_curr + nvl(l_tax_amount, 0)
              INTO l_tax_amount
              FROM zx_lines tax
             WHERE tax.trx_line_id = l_customer_trx_line_id
               AND tax.entity_code = 'TRANSACTIONS'
               AND application_id = 222
               AND tax.trx_level_type = 'LINE'
               AND tax.tax_currency_code = l_currency_code
               AND tax.tax_type_code = l_vat_tax_type
               AND tax.trx_id = l_customer_trx_id;

            l_discount_rate:=round(l_discount_amount/l_amount,5);
            --l_discount_tax_rate:=round(l_discount_tax_amount/l_tax_amount,5); delete for bug#8920239
            l_discount_tax_rate:=l_discount_rate;  --Yao add for bug#8920239
          --If the discount rate is different for the invoice line amount and tax amount, an exception will appear
            IF --ABS(l_discount_rate-l_discount_tax_rate)>0.001 delete for bug#8920239
               ABS(l_discount_tax_amount-l_discount_tax_rate*l_tax_amount)>0.01
            THEN
            fnd_message.SET_NAME('AR', 'AR_GTA_DIF_DIS_RATE');
                          l_error_string := fnd_message.GET();
              -- begin log
              IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
              THEN
                log(FND_LOG.LEVEL_PROCEDURE,
                    G_MODULE_PREFIX || l_procedure_name,
                    'AR_GTA_INCONSISTANT_DISCOUNT_RATE');
              END IF;/*(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)*/
              CLOSE c_ra_lines;
              RAISE l_normal_exception;
            END IF;/*l_discount_rate<>l_discount_tax_rate*/
          END IF;/*(l_interface_line_context='ORDER ENTRY' and l_price_adjustment_id=0)*/

           --Skip the Discount Lines
          IF(l_interface_line_context='ORDER ENTRY'AND l_price_adjustment_id<>0)
          THEN
              BEGIN
                SELECT opa.list_line_type_code
                  INTO l_adjustment_type
                  FROM oe_price_adjustments opa
                 WHERE opa.price_adjustment_id = l_price_adjustment_id;
              EXCEPTION
                WHEN  no_data_found THEN
                  CLOSE c_ra_lines;
                  RAISE l_normal_exception;
              END;
             --Yao Zhang fix bug#8809860 comment
              /*IF l_adjustment_type='DIS'
              THEN
                CONTINUE;
              END IF;l_adjustment_type='DIS'*/
          END IF;/*(l_interface_line_context='ORDER ENTRY'AND l_price_adjustment_id<>0)*/
     END IF;--l_discount_on_invoice='Y'
--The above code is added by Yao for bug#8605196 to support discount line

          -- check the UOM and Quentity of The AR transaction Line,
          -- if one of it is null ,
          -- Skip this transaction. and show a message

          -- Modified by Brian for bug 7594218
          --UOM is not mandatory for the transaction with class credit memo
          --*********************************************************************
          --commented by Yao Zhang  begin for bug 7629877 for UOM can be null
          /*IF l_ctt_class <> 'CM'
          THEN

            IF l_uom_code IS NULL
               OR (l_quantity_invoiced IS NULL AND l_quantity_credited IS NULL)
            THEN

              fnd_message.SET_NAME('AR', 'AR_GTA_MISSING_FIELD');
              --fnd_message.set_token('NUM', l_customer_trx_line_id);
              l_error_string := fnd_message.GET();

              -- begin log
              IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
              THEN
                log(FND_LOG.LEVEL_PROCEDURE,
                    G_MODULE_PREFIX || l_procedure_name,
                    'AR_GTA_MISSING_FIELD');
              END IF;
              -- end log

              IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
              THEN
                fnd_log.STRING(fnd_log.LEVEL_EXCEPTION,
                               G_MODULE_PREFIX || l_procedure_name,
                               l_error_string);
              END IF;
              CLOSE c_ra_lines;
              RAISE l_normal_exception;
            END IF;
          END IF; --l_ctt_class <> 'CM'*/
      --Yao Zhang fix bug#8809860 add
      IF  l_adjustment_type IS NULL OR l_adjustment_type<>'DIS'
      THEN
          --commented by Yao Zhang end for bug 7629877
          --yao zhang fix bug 7829039 add the following code
        BEGIN
          SELECT parameter_value
            INTO l_master_org
            FROM oe_sys_parameters_all
           WHERE org_id = p_org_id
             AND parameter_code = 'MASTER_ORGANIZATION_ID';
      EXCEPTION
        WHEN no_data_found THEN
            l_master_org := NULL;
      END;
          --yao zhang fix bug 7829039 add end

          BEGIN

            -- begin log
            IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              log(FND_LOG.LEVEL_PROCEDURE,
                  G_MODULE_PREFIX || l_procedure_name,
                  '************************************');
              log(FND_LOG.LEVEL_PROCEDURE,
                  G_MODULE_PREFIX || l_procedure_name,
                  'l_customer_trx_line_id:' || l_customer_trx_line_id); --exception 05
              log(FND_LOG.LEVEL_PROCEDURE,
                  G_MODULE_PREFIX || l_procedure_name,
                  '************************************');
            END IF;
            -- end log

            -- 29-JUN-2006 Modified by Shujuan for bug 5168900,
            -- Added return parameter p_tax_curr_unit_price
            -- in order to get the unit price of tax currency
            ar_gta_trx_util.get_info_from_ebtax(p_org_id                 => p_org_id,
                                                 p_trx_id                 => l_customer_trx_id,
                                                 p_trx_line_id            => l_customer_trx_line_id,
                                                 p_tax_type_code          => l_vat_tax_type,
                                                 x_tax_amount             => l_tax_amount_func_curr,
                                                 x_taxable_amount         => l_taxable_amount_func_curr,
                                                 x_taxable_amount_org     => l_amount,
                                                 x_trx_line_quantity      => l_line_quantity,
                                                 x_tax_rate               => l_tax_rate,
                                                 x_unit_selling_price     => l_unit_price,
                                                 x_tax_curr_unit_price    => p_tax_curr_unit_price,
                                                 x_fp_registration_number => l_fp_registration_number,
                                                 x_tp_registration_number => l_tp_registration_number,
                                                 x_invoice_type           => l_invoice_type, --added by subba for R12.1
                                                 x_status                 => l_status,
                                                 x_error_buffer           => l_proce_error_buffer);

            -- begin log
            IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              log(FND_LOG.LEVEL_PROCEDURE,
                  G_MODULE_PREFIX || l_procedure_name,
                  'ebtax p_org_id:' || p_org_id);
              log(FND_LOG.LEVEL_PROCEDURE,
                  G_MODULE_PREFIX || l_procedure_name,
                  'ebtax l_customer_trx_id:' || l_customer_trx_id);
              log(FND_LOG.LEVEL_PROCEDURE,
                  G_MODULE_PREFIX || l_procedure_name,
                  'ebtax l_customer_trx_line_id:' || l_customer_trx_line_id);
              log(FND_LOG.LEVEL_PROCEDURE,
                  G_MODULE_PREFIX || l_procedure_name,
                  'ebtax l_vat_tax_type:' || l_vat_tax_type);
              log(FND_LOG.LEVEL_PROCEDURE,
                  G_MODULE_PREFIX || l_procedure_name,
                  'ebtax l_tax_amount_func_curr:' || l_tax_amount_func_curr);
              log(FND_LOG.LEVEL_PROCEDURE,
                  G_MODULE_PREFIX || l_procedure_name,
                  'ebtax l_taxable_amount_func_curr:' ||
                  l_taxable_amount_func_curr);
              log(FND_LOG.LEVEL_PROCEDURE,
                  G_MODULE_PREFIX || l_procedure_name,
                  'ebtax l_line_quantity:' || l_line_quantity);
              log(FND_LOG.LEVEL_PROCEDURE,
                  G_MODULE_PREFIX || l_procedure_name,
                  'ebtax l_tax_rate:' || l_tax_rate);
              log(FND_LOG.LEVEL_PROCEDURE,
                  G_MODULE_PREFIX || l_procedure_name,
                  'ebtax l_unit_price:' || l_unit_price);
              log(FND_LOG.LEVEL_PROCEDURE,
                  G_MODULE_PREFIX || l_procedure_name,
                  'ebtax l_fp_registration_number:' ||
                  l_fp_registration_number);
              log(FND_LOG.LEVEL_PROCEDURE,
                  G_MODULE_PREFIX || l_procedure_name,
                  'ebtax l_tp_registration_number:' ||
                  l_tp_registration_number);
              log(FND_LOG.LEVEL_PROCEDURE,
                  G_MODULE_PREFIX || l_procedure_name,
                  'ebtax l_status:' || l_status);
              log(FND_LOG.LEVEL_PROCEDURE,
                  G_MODULE_PREFIX || l_procedure_name,
                  'ebtax l_proce_error_buffer:' || l_proce_error_buffer);
            END IF;
            -- end log

            -- Yao zhang add for bug 7629877
            --For Common VAT type,validate CM invoice
            IF (l_invoice_type = '2' and l_ctt_class = 'CM')
            THEN
              --log begin
              l_ar_inv_excep     := false;
              l_gt_inv_excep     := false;
              l_cm_warn          := false;
              l_cm_warn2         := FALSE;
              l_pre_cus_trxid    := null;
              l_ar_invoice_count := 0;
              l_gt_invoice_count := 0;
              IF (FND_LOG.LEVEL_EXCEPTION >=
                 FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                log(FND_LOG.LEVEL_PROCEDURE,
                    G_MODULE_PREFIX || l_procedure_name,
                    '****************************************');
                log(FND_LOG.LEVEL_PROCEDURE,
                    G_MODULE_PREFIX || l_procedure_name,
                    'is CM');
                log(FND_LOG.LEVEL_PROCEDURE,
                    G_MODULE_PREFIX || l_procedure_name,
                    '****************************************');
              END IF;/*(l_invoice_type = '2' and l_ctt_class = 'CM')*/
              --checking whether CM is associated with AR invoice or not
              SELECT previous_customer_trx_id
                INTO l_pre_cus_trxid
                FROM ra_customer_trx_all
               WHERE customer_trx_id = l_customer_trx_id;
              IF (l_pre_cus_trxid is not null) then
                -- this credit memo is credited with AR invoice
                --Select all AR invoices associated with credit memo.
                SELECT COUNT(*)
                  INTO l_ar_invoice_count
                  FROM ar_gta_trx_headers_all
                 WHERE ra_trx_id = l_pre_cus_trxid
                   AND SOURCE = 'AR';
                IF l_ar_invoice_count = 0 THEN
                  --AR invoice has not been transfered to GTA
                  l_ar_inv_excep := true;
                ELSIF l_ar_invoice_count >= 2
                THEN
                  --credit memo associated to AR invoice which is transferred to GTA with split
                  l_cm_warn := true;
                ELSIF l_ar_invoice_count = 1
                --credit memo associated to AR invoice which is transferred to GTA without split
                THEN
                --check whether the GT invoice has been imported.
                  SELECT count(*)
                    INTO l_gt_invoice_count
                    FROM AR_Gta_Trx_Headers_All
                   WHERE ra_trx_id = l_pre_cus_trxid
                     AND source='GT';  --Yao Zhang Modified fix bug 7670543

                  IF l_gt_invoice_count = 0
                  THEN
                    --AR trx is in workbench but VAT not generated.
                  --l_ar_inv_excep := true;--Commented by Yao Zhang for 12.1.2 new credit memo logic
                  l_cm_warn2 := true;--Added by Yao Zhang for 12.1.2 new credit memo logic
                 --Yao Zhang add begin for bug 7685610--
                  ELSE--VAT is generated for AR transaction
                  SELECT gt_invoice_number,gt_invoice_class
                    INTO l_gt_invoice_number,l_gt_invoice_class
                    FROM AR_Gta_Trx_Headers_All
                   WHERE ra_trx_id = l_pre_cus_trxid
                     AND source='GT';
                  fnd_message.SET_NAME('AR', 'AR_GTA_CREDMEMO_EXPORT_IV');
                  l_cm_desc1:=fnd_message.GET();
                  fnd_message.SET_NAME('AR', 'AR_GTA_CREDMEMO_EXPORT_NR');
                  l_cm_desc2:=fnd_message.GET();
                  l_trx_header.description :=l_cm_desc1||l_gt_invoice_class||' '||l_cm_desc2||l_gt_invoice_number;
                  --Yao Zhang add end for bug 7685610--
                  END IF; /*l_gt_invoice_count = 0 */
                END IF; /*  l_ar_invoice_count =0*/

              ELSE
                l_cm_warn := true; --on account cm can be transfered with warning
              END IF; --/l_pre_cus_trxid is not null

              IF (l_cm_warn = TRUE OR l_cm_warn2= TRUE) THEN
                --if credit memo not associated with any AR inv or associated with multi AR inv
                IF l_cm_warn = TRUE
                THEN
                fnd_message.SET_NAME('AR', 'AR_GTA_CRMEMO_DES_NULL');
                l_error_string := fnd_message.GET();
                IF (FND_LOG.LEVEL_UNEXPECTED >=
                   FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  log(FND_LOG.LEVEL_PROCEDURE,
                      G_MODULE_PREFIX || l_procedure_name,
                      'AR_GTA_CRMEMO_DES_NULL');
                END IF;
                IF (FND_LOG.LEVEL_EXCEPTION >=
                   FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  fnd_log.STRING(fnd_log.LEVEL_EXCEPTION,
                                 G_MODULE_PREFIX || l_procedure_name,
                                 l_error_string);
                END IF;
                END IF;--l_cm_warn = TRUE

                IF l_cm_warn2 = TRUE
                THEN fnd_message.SET_NAME('AR', 'AR_GTA_TRS_NO_GT_INV');
                l_error_string := fnd_message.GET();
                  IF (FND_LOG.LEVEL_UNEXPECTED >=
                    FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    log(FND_LOG.LEVEL_PROCEDURE,
                    G_MODULE_PREFIX || l_procedure_name,
                    'AR_GTA_TRS_NO_GT_INV');
                  END IF;
                  IF (FND_LOG.LEVEL_EXCEPTION >=
                    FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    fnd_log.STRING(fnd_log.LEVEL_EXCEPTION,
                                 G_MODULE_PREFIX || l_procedure_name,
                                 l_error_string);
                  END IF;
                END IF;--l_cm_warn2 = TRUE


                DELETE FROM ar_gta_transfer_temp temp
                WHERE temp.transaction_id = l_customer_trx_id
                AND temp.succeeded = 'W'
                --and temp.tax_reg_num=l_tp_registration_number;--Modified by Yao Zhang for bug 7684662
                   AND (temp.tax_reg_num = l_tp_registration_number OR
                       decode(l_tp_registration_number,
                               NULL,
                               temp.tax_reg_num,
                               l_tp_registration_number) IS NULL); --Yao Zhang changed for bug 8241752
                INSERT INTO ar_gta_transfer_temp t
                  (t.seq,
                   t.transaction_id,
                   t.succeeded,
                   t.transaction_num,
                   t.transaction_type,
                   t.customer_name,
                   t.amount,
                   t.failedreason,
                   t.gta_invoice_num,
                   t.tax_reg_num)
                  SELECT ar_gta_transfer_temp_s.NEXTVAL,
                         l_customer_trx_id,
                         'W',
                         l_trx_number,
                         l_ctt_class,
                         l_rac_bill_to_customer_name,
                         NULL,
                         l_error_string,
                         NULL,
                         l_tp_registration_number--added by Yao Zhang for bug 7644235
                                                 -- to distinguish different tax reg number on trx lines.
                    FROM dual;

              END IF; -- IF (l_cm_warn = TRUE OR l_cm_warn2= TRUE)

              IF (l_gt_inv_excep = true or l_ar_inv_excep = true) THEN
                --if credit memo associated with AR and in GTA but not VAT generated for non-common VAT
                --rasie correspoding AR transation not in GT warning.
                fnd_message.SET_NAME('AR', 'AR_GTA_CRMEMO_MISSING_GTINV');
                l_error_string := fnd_message.GET();
                IF (FND_LOG.LEVEL_UNEXPECTED >=
                   FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  log(FND_LOG.LEVEL_PROCEDURE,
                      G_MODULE_PREFIX || l_procedure_name,
                      'AR_GTA_CRMEMO_MISSING_GTINV');
                END IF;
                IF (FND_LOG.LEVEL_EXCEPTION >=
                   FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  fnd_log.STRING(fnd_log.LEVEL_EXCEPTION,
                                 G_MODULE_PREFIX || l_procedure_name,
                                 l_error_string);
                END IF;
                CLOSE c_ra_lines;
                RAISE l_normal_exception; --Raise normal exception to skip this credit memo
              END IF; /*(l_gt_inv_excep = true or l_ar_inv_excep = true)*/
            END IF; --/(l_invoice_type = '2' and l_ctt_class = 'CM')
            --Yao Zhang add end for bug 7629877.

            --following code added by subba for R12.1, check for the cust address,phone no, bank details exception
            --Raise exception if invoice type is not common.
            IF (l_invoice_type <> '2') THEN
              --If invoice type is not common VAT
              IF (l_cust_addr_excep = 'true') THEN
                --if customer address is null
                IF (FND_LOG.LEVEL_EXCEPTION >=
                   FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  fnd_log.STRING(fnd_log.LEVEL_EXCEPTION,
                                 G_MODULE_PREFIX || l_procedure_name,
                                 'no data found when select cust address for non-common VAT invoice');
                END IF;
                l_error_string := 'no data found when select cust address for non-common VAT invoice';
                CLOSE c_ra_lines;
                RAISE l_normal_exception;
              END IF; -- IF (l_cust_addr_excep = 'true') THEN
              IF (l_cust_phone_exp = 'true') THEN
                --if customer phone is null
                IF (FND_LOG.LEVEL_EXCEPTION >=
                   FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  fnd_log.STRING(fnd_log.LEVEL_EXCEPTION,
                                 G_MODULE_PREFIX || l_procedure_name,
                                 'no data found when select customer phone number for non-common VAT invoice');
                END IF;
                l_error_string := 'no data found when select customer phone number for non-common VAT invoice';
                CLOSE c_ra_lines;
                RAISE l_normal_exception;

              END IF; /*IF (l_cust_phone_exp = 'true')*/
              --Yao Zhang Commented for bug 7629877 there is no necessary to check cm for non-common invoice
              /*IF (l_ar_inv_excep = 'true') THEN    --if credit memo not associated with any AR inv for NON-Common VAT

              IF(FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)  THEN
                       fnd_log.STRING(fnd_log.LEVEL_EXCEPTION
                                   , G_MODULE_PREFIX || l_procedure_name
                                   , l_error_string);
                    END IF;

                    l_error_string := 'No AR invoice associated with this credit memo';
                    RAISE l_normal_exception;

                  END IF;   /*IF (l_ar_inv_excep = 'true') THEN*/

              /*IF (l_cm_excep = 'true') THEN     --if credit memo associated with AR and in GTA but not VAT generated for NON-common VAT

              --rasie correspoding AR transation not in GT warning.


              l_error_string := 'There is no corresponding VAT invoice in workbench to process this credit memo';
                    -- begin log
              IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
                    THEN
                log(FND_LOG.LEVEL_PROCEDURE,G_MODULE_PREFIX ||
                                                l_procedure_name,
                                                'AR_GTA_CRMEMO_MISSING_GTAINV');
                    END IF;
              -- end log

              IF(FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
              THEN
                fnd_log.STRING(fnd_log.LEVEL_EXCEPTION
                   , G_MODULE_PREFIX || l_procedure_name
                   , l_error_string);
              END IF;

              RAISE l_normal_exception ;  --Raise normal exception to skip this credit memo

                   END IF; /*IF (l_cm_excep = 'true') THEN*/
              --Yao Zhang Commented end for bug 7629877

            END IF; /*IF (l_invoice_type <> 2) THEN*/

            -- throw exception is l_status is -1 , 1 , or 2
            -- if status is -1 then the tax line count is 0 and skip this trx
            -- if status is 1 then the tax line is more than one
            -- or fp/tp registratioin number is null
            -- throw a exception and skip this trx
            -- is status is 2 then is a system opertion error , exit the program.
            IF l_status = -1 THEN
              RAISE l_no_tax_line_exception;
            ELSIF l_status = 1 THEN
              --29/06/2006 Updated by Shujuan Yan for bug 5258522
              --Should display line number instead of line id.
              --Use line number as token value
              --modifed by subba for R12.1

              IF l_proce_error_buffer = 'AR_GTA_MISSING_INVOICE_TYPE' THEN

                SELECT name
                  INTO l_trx_typ
                  FROM ra_cust_trx_types_all rctt, ra_customer_trx_all rct
                 WHERE rct.cust_trx_type_id = rctt.cust_trx_type_id(+)
                   AND rct.org_id = rctt.org_id(+)
                   AND rct.customer_trx_id = l_customer_trx_id
                   AND rct.org_id = p_org_id;

                fnd_message.SET_NAME('AR', l_proce_error_buffer);
                fnd_message.set_token('TRX_TYP', l_trx_typ);
                fnd_message.set_token('TAX_REG_NUM',
                                      l_fp_registration_number);
                l_error_string := fnd_message.GET();
                -- begin log
                IF (FND_LOG.LEVEL_PROCEDURE >=
                   FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  log(FND_LOG.LEVEL_PROCEDURE,
                      G_MODULE_PREFIX || l_procedure_name,
                      'exception missing transaction type association' ||
                      l_proce_error_buffer);
                END IF;
                -- end log
              ELSIF l_proce_error_buffer = 'AR_GTA_TAX_ERROR_RECYCLE' THEN
                fnd_message.SET_NAME('AR', l_proce_error_buffer);
                l_error_string := fnd_message.GET();
                -- begin log
                IF (FND_LOG.LEVEL_PROCEDURE >=
                   FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  log(FND_LOG.LEVEL_PROCEDURE,
                      G_MODULE_PREFIX || l_procedure_name,
                      'exception tax rate and tax amount for Recycle Invoice Type' ||
                      l_proce_error_buffer);
                END IF;
                -- end log
              ELSE
                fnd_message.SET_NAME('AR', l_proce_error_buffer);
                fnd_message.set_token('NUM', l_customer_trx_line_number);
                fnd_message.set_token('TAXTYPE', l_vat_tax_type);
                l_error_string := fnd_message.GET();

                -- begin log
                IF (FND_LOG.LEVEL_PROCEDURE >=
                   FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  log(FND_LOG.LEVEL_PROCEDURE,
                      G_MODULE_PREFIX || l_procedure_name,
                      'exception registration number' ||
                      l_proce_error_buffer);
                END IF;
                -- end log
              END IF;

              IF (FND_LOG.LEVEL_EXCEPTION >=
                 FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_log.STRING(fnd_log.LEVEL_EXCEPTION,
                               G_MODULE_PREFIX || l_procedure_name,
                               l_error_string);
              END IF;
              CLOSE c_ra_lines;
              RAISE l_normal_exception;
            ELSIF l_status = 2 THEN
              fnd_message.SET_NAME('AR', 'AR_GTA_SYS_CONFIG_MISSING');
              fnd_message.set_token('Tax_Regis_Number',
                                    l_fp_registration_number);
              l_error_string := fnd_message.get();

              -- begin log
              IF (FND_LOG.LEVEL_PROCEDURE >=
                 FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                log(FND_LOG.LEVEL_PROCEDURE,
                    G_MODULE_PREFIX || l_procedure_name,
                    'AR_GTA_SYS_CONFIG_MISSING');
                log(FND_LOG.LEVEL_PROCEDURE,
                    G_MODULE_PREFIX || l_procedure_name,
                    'First Party tax registartion number is not exist in System Option');
              END IF;
              -- end log
              CLOSE c_ra_lines;
              RAISE l_normal_exception;
            END IF;
            --unit price validate. This will throw a exception AR_GTA_UNITPRICE_ERROR
            BEGIN
              SELECT limits.max_amount, limits.max_num_of_line
                INTO l_max_amount, l_max_num_of_line
                FROM ar_gta_tax_limits_all limits
               WHERE limits.fp_tax_registration_number =
                     l_fp_registration_number
                 AND limits.invoice_type = l_invoice_type
                 AND limits.org_id = p_org_id;
              -- 29-JUN-2006 deleted by Shujuan for bug 5168900
              -- Since it is possible that the currency l_unit_selling_price is
              -- different with the currency l_max_amount.
              --IF l_unit_selling_price > l_max_amount

              -- 09/06/2006  Updated by Shujuan Yan for bug 5263215
              -- Change message code from AR_GTA_UNITPRICE_ERROR
              -- into AR_GTA_UNITPRICE_EXCEED
              -- 12/06/2006  Updated by Shujuan Yan for bug 5230712
              -- Should display line number instead of line id.
              -- Use line number as token value
              -- 29-JUN-2006 Added by Shujuan for bug 5168900,
              -- Since the currency of tax unit price is same with
              -- the currency of max amount of GTA
              --Yao add for bug9045187
              l_actual_unit_price:=(l_taxable_amount_func_curr+nvl(l_discount_amount_func_curr,0))/l_quantity_invoiced;

              IF  ABS(l_actual_unit_price)> l_max_amount THEN
              --Yao add end for bug9045187
                fnd_message.SET_NAME('AR', 'AR_GTA_UNITPRICE_EXCEED');
                fnd_message.set_token('NUM', l_customer_trx_line_number);
                l_error_string := fnd_message.GET();

                -- begin log
                IF (FND_LOG.LEVEL_PROCEDURE >=
                   FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  log(FND_LOG.LEVEL_PROCEDURE,
                      G_MODULE_PREFIX || l_procedure_name,
                      'AR_GTA_UNITPRICE_EXCEED');
                END IF;
                -- end log

                IF (FND_LOG.LEVEL_EXCEPTION >=
                   FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  fnd_log.STRING(fnd_log.LEVEL_EXCEPTION,
                                 G_MODULE_PREFIX || l_procedure_name,
                                 l_error_string);
                END IF;
                CLOSE c_ra_lines;
                RAISE l_normal_exception;
              END IF; /*(l_unit_price IS NOT NULL) AND l_unit_price > l_max_amount*/
            EXCEPTION
              WHEN no_data_found THEN
                IF (FND_LOG.LEVEL_UNEXPECTED >=
                   FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  fnd_log.STRING(fnd_log.LEVEL_UNEXPECTED,
                                 G_MODULE_PREFIX || l_procedure_name,
                                 'no data found');
                END IF;
                fnd_message.set_name('AR', 'AR_GTA_SYS_CONFIG_MISSING');

                IF (FND_LOG.LEVEL_UNEXPECTED >=
                   FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  fnd_log.STRING(fnd_log.LEVEL_UNEXPECTED,
                                 G_MODULE_PREFIX || l_procedure_name,
                                 fnd_message.get());

                END IF;
                RAISE;
                RETURN;
            END;

            -- begin validate the flexfield
            -- Begin get item name , so l_trx_line.item_description
            -- 12/06/2006  Updated by Shujuan Yan for bug 5230712
            -- should display line number and item name instead of line id and item id.
            IF (l_item_name_source_flag = 'R') THEN
              -- if the description of AR is null then report a error
              IF (l_description IS NULL) THEN
                --report AR_GTA_AR_DESC_MISS
                fnd_message.set_name('AR', 'AR_GTA_MISSING_FIELD');
                fnd_message.set_token('NUM', l_customer_trx_line_number);
                fnd_message.set_token('TrxNum',
                                      l_trx_header.gta_trx_header_id);
                l_error_string := fnd_message.get();

                -- begin log
                IF (FND_LOG.LEVEL_PROCEDURE >=
                   FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  log(FND_LOG.LEVEL_PROCEDURE,
                      G_MODULE_PREFIX || l_procedure_name,
                      'AR_GTA_MISSING_FIELD');
                END IF;
                -- end log

                IF (FND_LOG.LEVEL_EXCEPTION >=
                   FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  fnd_log.STRING(fnd_log.LEVEL_EXCEPTION,
                                 G_MODULE_PREFIX || l_procedure_name,
                                 l_error_string);
                END IF;

                CLOSE c_ra_lines;
                RAISE l_normal_exception;

              ELSE
                /*(l_description IS NULL)*/
                l_trx_line.item_description := l_description;

              END IF; /*(l_description IS NULL)*/

            ELSE
              /* (l_ITEM_NAME_SOURCE_FLAG is not 'R')*/
              --get item name from Inventory Item cross reference or description
              IF l_inventory_item_id IS NOT NULL THEN
              --The following code is added by Yao Zhang to retrive Item Validation Organization for ou
                BEGIN
                  SELECT parameter_value
                    INTO l_master_org
                    FROM oe_sys_parameters_all
                   WHERE org_id = p_org_id
                     AND parameter_code = 'MASTER_ORGANIZATION_ID';
               EXCEPTION
                  WHEN no_data_found THEN
                    fnd_message.set_name('AR',
                                         'AR_GTA_MISSING_CROSS_REF');
                    fnd_message.set_token('NUM',
                                          l_customer_trx_line_number);
                        l_error_string := fnd_message.get();
          -- log
                    IF (fnd_log.level_exception >=
                       fnd_log.g_current_runtime_level) THEN
                      fnd_log.STRING(fnd_log.level_exception,
                                     g_module_prefix || l_procedure_name,
                           l_error_string);
          END IF;
                    CLOSE c_ra_lines;
          RAISE l_normal_exception;
      END;
              --yao zhang add end for bug 7721035
             --get record number in cross reference. Only retrive item cross reference on master inv org
                SELECT COUNT(*)
                  INTO l_cross_rows
                  FROM MTL_CROSS_REFERENCES
                 WHERE (organization_id IS NULL OR
                       organization_id = l_master_org)--yao zhang modified for bug 7721035
                   AND inventory_item_id = l_inventory_item_id
                   AND cross_reference_type = l_cross_reference_type;

                --get latest cross reference
                IF l_cross_rows > 0 THEN
                  SELECT MAX(cross_reference)
                    INTO l_cross_reference
                    FROM MTL_CROSS_REFERENCES
                   WHERE (organization_id IS NULL OR
                         organization_id = l_master_org)--yao zhang modified for bug 7721035
                     AND inventory_item_id = l_inventory_item_id
                     AND cross_reference_type = l_cross_reference_type
                     AND last_update_date =
                         (SELECT MAX(last_update_date)
                            FROM MTL_CROSS_REFERENCES
                           WHERE (organization_id IS NULL OR
                                 organization_id = l_master_org)--yao zhang modified for bug 7721035
                             AND inventory_item_id = l_inventory_item_id
                             AND cross_reference_type =
                                 l_cross_reference_type);
                ELSE
                  /*l_cross_rows > 0*/
                  l_cross_reference := null;
                END IF; /*l_cross_rows > 0*/

                BEGIN
                  SELECT DESCRIPTION, attribute_category
                    INTO l_inventory_item_name,
                         l_inventory_attribute_category
                    FROM mtl_system_items_b
                   WHERE organization_id = l_master_org--yao zhang modified for bug 7721035
                     AND inventory_item_id = l_inventory_item_id;

                EXCEPTION
                  WHEN no_data_found THEN
                    fnd_message.set_name('AR',
                                         'AR_GTA_MISSING_CROSS_REF');
                    fnd_message.set_token('NUM',
                                          l_customer_trx_line_number);
                    l_error_string := fnd_message.get();

                    -- log
                    IF (FND_LOG.LEVEL_EXCEPTION >=
                       FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      fnd_log.STRING(fnd_log.LEVEL_EXCEPTION,
                                     G_MODULE_PREFIX || l_procedure_name,
                                     l_error_string);
                    END IF;

                    CLOSE c_ra_lines;
                    RAISE l_normal_exception;
                END;
                --multi-lines cross reference and setup not allow it
                IF (l_latest_ref_default_flag = 'N' AND l_cross_rows > 1) THEN
                  --report AR_GTA_MISSING_CROSS_REF
                  fnd_message.SET_NAME('AR', 'AR_GTA_MULTIPLE_REF');
                  fnd_message.SET_TOKEN('NUM', l_customer_trx_line_number);
                  l_error_string := fnd_message.get();
                  -- log
                  IF (FND_LOG.LEVEL_EXCEPTION >=
                     FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    fnd_log.STRING(fnd_log.LEVEL_EXCEPTION,
                                   G_MODULE_PREFIX || l_procedure_name,
                                   l_error_string);
                  END IF;
                  CLOSE c_ra_lines;
                  RAISE l_normal_exception;

                ELSE
                  /*(l_latest_ref_default_flag ='N' AND l_cross_rows>1 )*/
                  IF l_cross_reference IS NULL THEN
                    IF (l_MASTER_ITEM_DEFAULT_FLAG = 'Y') THEN
                      l_trx_line.item_description := l_inventory_item_name;
                    ELSE
                      /*(l_MASTER_ITEM_DEFAULT_FLAG = 'Y') */
                      fnd_message.SET_NAME('AR',
                                           'AR_GTA_MISSING_CROSS_REF');
                      fnd_message.SET_TOKEN('NUM',
                                            l_customer_trx_line_number);
                      l_error_string := fnd_message.get();
                      -- log
                      IF (FND_LOG.LEVEL_EXCEPTION >=
                         FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        fnd_log.STRING(fnd_log.LEVEL_EXCEPTION,
                                       G_MODULE_PREFIX || l_procedure_name,
                                       l_error_string);
                      END IF;
                      CLOSE c_ra_lines;
                      RAISE l_normal_exception;
                    END IF; /*(l_MASTER_ITEM_DEFAULT_FLAG = 'Y') */
                  ELSE
                    /*l_cross_reference IS NULL*/
                    l_trx_line.item_description := l_cross_reference;
                  END IF; /*l_cross_reference IS NULL*/
                END IF; /*(l_latest_ref_default_flag ='N' AND l_cross_rows>1 )*/
              ELSE
                --12/07/2006 Added by Shujuan Yan for bug 5224923
                -- When item is not inventory item, item_description
                -- should be assigned the value of AR transaction line description.
                l_trx_line.item_description := l_description;
                --11/06/2006 deleted by Shujuan Yan for bug 5224923
                /* ELSE /*l_inventory_item_id IS NOT NULL*/
                /* fnd_message.SET_NAME('AR', 'AR_GTA_MISSING_CROSS_REF');
                  fnd_message.set_token('NUM', l_customer_trx_line_number);
                   l_error_string := fnd_message.get;

                   -- log
                   IF(FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
                   THEN
                     fnd_log.STRING(fnd_log.LEVEL_EXCEPTION
                                    , G_MODULE_PREFIX || l_procedure_name
                                    , l_error_string);
                   END IF;

                   CLOSE c_ra_lines;
                   RAISE l_normal_exception;
                END IF; /*l_inventory_item_id IS NOT NULL*/
              END IF; /*l_inventory_item_id IS NOT NULL*/
            END IF; /* (l_ITEM_NAME_SOURCE_FLAG is not 'R')*/
            -- End get item name

            -- Begin get item model tax demination
            --get item model and tax denomination
            --12/06/2006  Updated by Shujuan Yan for bug 5230712
            --should display line number and item name instead of line id and item id.
            IF l_interface_line_context <> l_ra_line_context_code OR
               l_interface_line_context IS NULL THEN
              IF l_inventory_attribute_category <> l_inv_item_context_code THEN
                --report AR_GTA_ARTRX_FLEX_MISSING
                fnd_message.SET_NAME('AR', 'AR_GTA_MISSING_MODEL');
                fnd_message.set_token('NUM', l_customer_trx_line_number);
                fnd_message.set_token('ITEM', l_inventory_item_name);
                l_error_string := fnd_message.get();

                -- log
                IF (FND_LOG.LEVEL_EXCEPTION >=
                   FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  fnd_log.STRING(fnd_log.LEVEL_EXCEPTION,
                                 G_MODULE_PREFIX || l_procedure_name,
                                 l_error_string);
                END IF;

                CLOSE c_ra_lines;
                RAISE l_normal_exception;
              ELSE
                /*l_interface_line_context <> l_inv_item_context_code*/
                IF l_inv_model_attribute_column IS NULL THEN
                  fnd_message.SET_NAME('AR', 'AR_GTA_MISSING_MODEL');
                  fnd_message.set_token('NUM', l_customer_trx_line_number);
                  fnd_message.set_token('ITEM', l_inventory_item_name);
                  l_error_string := fnd_message.get;

                  -- log
                  IF (FND_LOG.LEVEL_EXCEPTION >=
                     FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    fnd_log.STRING(fnd_log.LEVEL_EXCEPTION,
                                   G_MODULE_PREFIX || l_procedure_name,
                                   l_error_string);
                  END IF;

                  CLOSE c_ra_lines;
                  RAISE l_normal_exception;
                ELSE
                  /*l_inv_model_attribute_column IS NULL*/
                  get_inv_item_model(p_item_master_org_id  => l_master_org,--yao zhang changed fix bug 7829039
                                     p_inventory_item_id => l_inventory_item_id,
                                     p_attribute_column  => l_inv_model_attribute_column,
                                     x_attribute_value   => l_trx_line.item_model);

                END IF; /*l_inv_model_attribute_column IS NULL*/

                IF l_inv_tax_attribute_column IS NULL THEN
                  fnd_message.SET_NAME('AR', 'AR_GTA_MISSING_TAX_DENOM');
                  fnd_message.set_token('NUM', l_customer_trx_line_number);
                  fnd_message.set_token('ITEM', l_inventory_item_name);
                  l_error_string := fnd_message.get();
                  -- log
                  IF (FND_LOG.LEVEL_PROCEDURE >=
                     FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    fnd_log.STRING(fnd_log.LEVEL_PROCEDURE,
                                   G_MODULE_PREFIX || l_procedure_name,
                                   l_error_string);
                  END IF;
                  CLOSE c_ra_lines;
                  RAISE l_normal_exception;

                ELSE
                  get_inv_item_model(p_item_master_org_id    => l_master_org,--yao zhang changed fix bug 7829039
                                     p_inventory_item_id => l_inventory_item_id,
                                     p_attribute_column  => l_inv_tax_attribute_column,
                                     x_attribute_value   => l_trx_line.item_tax_denomination);

                END IF; --/* end if  l_inv_tax_attribute_column IS NULL*/
              END IF; --/*l_column_type.attribute_category <> l_inv_item_context_code*/

            ELSE   /*l_interface_line_context <> l_ra_line_context_code*/
              get_ra_item_model(p_ra_line_id       => l_customer_trx_line_id,
                                p_attribute_column => l_ra_model_attribute_column,
                                x_attribute_value  => l_trx_line.item_model);
              -- begin log
              IF (FND_LOG.LEVEL_PROCEDURE >=
                 FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                log(FND_LOG.LEVEL_PROCEDURE,
                    G_MODULE_PREFIX || l_procedure_name,
                    'item_model:' || l_trx_line.item_model);
              END IF;
              -- end log

              IF l_trx_line.item_model IS NULL THEN
                IF l_inventory_attribute_category <>
                   l_inv_item_context_code THEN
                  fnd_message.SET_NAME('AR', 'AR_GTA_MISSING_MODEL');
                  fnd_message.set_token('NUM', l_customer_trx_line_number);
                  fnd_message.set_token('ITEM', l_inventory_item_name);
                  l_error_string := fnd_message.get();
                  -- log
                  IF (FND_LOG.LEVEL_EXCEPTION >=
                     FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    fnd_log.STRING(fnd_log.LEVEL_EXCEPTION,
                                   G_MODULE_PREFIX || l_procedure_name,
                                   l_error_string);
                  END IF;
                  CLOSE c_ra_lines;
                  RAISE l_normal_exception;

                ELSE/*l_ra_model_attribute_column IS NULL*/
                  get_inv_item_model(p_item_master_org_id  => l_master_org,--yao zhang changed fix bug 7829039
                                     p_inventory_item_id => l_inventory_item_id,
                                     p_attribute_column  => l_inv_model_attribute_column,
                                     x_attribute_value   => l_trx_line.item_model);
                END IF; --/*l_column_type.attribute_category<>l_inv_item_context_code*/
              END IF; -- /*end if l_ra_model_attribute_column IS NULL*/
              -- begin get tax denmo
              get_ra_item_model(p_ra_line_id       => l_customer_trx_line_id,
                                p_attribute_column => l_ra_tax_attribute_column,
                                x_attribute_value  => l_trx_line.item_tax_denomination);
              -- begin log
              IF (FND_LOG.LEVEL_PROCEDURE >=
                 FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                log(FND_LOG.LEVEL_PROCEDURE,
                    G_MODULE_PREFIX || l_procedure_name,
                    'item_tax_denomination:' ||
                    l_trx_line.item_tax_denomination);
              END IF;
              -- end log

              --12/06/2006  Updated by Shujuan Yan for bug 5230712
              --Should display line number and item name instead of line id and item id.
              IF l_trx_line.item_tax_denomination IS NULL THEN
                IF l_inventory_attribute_category <>
                   l_inv_item_context_code THEN
                  fnd_message.SET_NAME('AR', 'AR_GTA_MISSING_TAX_DENOM');
                  fnd_message.set_token('NUM', l_customer_trx_line_number);
                  fnd_message.set_token('ITEM', l_inventory_item_name);
                  l_error_string := fnd_message.get();
                  -- log
                  IF (FND_LOG.LEVEL_EXCEPTION >=
                     FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    fnd_log.STRING(fnd_log.LEVEL_EXCEPTION,
                                   G_MODULE_PREFIX || l_procedure_name,
                                   l_error_string);
                  END IF;
                  CLOSE c_ra_lines;
                  RAISE l_normal_exception;
                ELSE
                  get_inv_item_model(p_item_master_org_id => l_master_org,--yao zhang changed fix bug 7829039
                                     p_inventory_item_id => l_inventory_item_id,
                                     p_attribute_column  => l_inv_tax_attribute_column,
                                     x_attribute_value   => l_trx_line.item_tax_denomination);
                END IF; --l_column_type.attribute_category <> l_inv_item_context_code

              END IF; -- l_ra_tax_attribute_column IS NULL

            END IF; /*l_column_type.attribute_category <>l_ra_line_context_code*/
            --end validate flexfield

            -- begin check the itme description and item tax denomination,
            -- if either of their is null, Then throw AR_GTA_MESSING_TRX_DENOM
            -- message or AR_GTA_MISSING_CROSS_REF message.
            -- 12/06/2006  Updated by Shujuan Yan for bug 5230712
            -- Should display line number and item name instead of line id and item id.
            IF l_trx_line.item_tax_denomination IS NULL THEN
              fnd_message.SET_NAME('AR', 'AR_GTA_MISSING_TAX_DENOM');
              fnd_message.set_token('NUM', l_customer_trx_line_number);
              fnd_message.set_token('ITEM', l_inventory_item_name);
              l_error_string := fnd_message.get();
              -- log
              IF (FND_LOG.LEVEL_UNEXPECTED >=
                 FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_log.STRING(fnd_log.LEVEL_UNEXPECTED,
                               G_MODULE_PREFIX || l_procedure_name,
                               l_error_string);
              END IF;
              CLOSE c_ra_lines;
              RAISE l_normal_exception;

            END IF; /*l_trx_lline.itme_tax_denomination IS NULL*/

            IF l_trx_line.item_description IS NULL THEN
              fnd_message.SET_NAME('AR', 'AR_GTA_MISSING_CROSS_REF');
              fnd_message.set_token('NUM', l_customer_trx_line_number);
              l_error_string := fnd_message.get();
              -- log
              IF (FND_LOG.LEVEL_UNEXPECTED >=
                 FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_log.STRING(fnd_log.LEVEL_UNEXPECTED,
                               G_MODULE_PREFIX || l_procedure_name,
                               l_error_string);
              END IF;
              CLOSE c_ra_lines;
              RAISE l_normal_exception;

            END IF; /*l_trx_lline.itme_tax_denomination IS NULL*/
            -- end item description and item tax denomination check

            --get item_inventory_code
            get_inventory_item_number(p_inventory_item_id   => l_inventory_item_id,
                                      p_item_master_org_id  => l_master_org,--yao zhang changed fix bug 7829039
                                      x_inventory_item_code => l_trx_line.item_number);

            -- begin log
            IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              log(FND_LOG.LEVEL_PROCEDURE,
                  G_MODULE_PREFIX || l_procedure_name,
                  'get_inventory_item_number end ');
            END IF;
            -- end log

            -- the quantity stored in different column of ra_customer_trx_lines_all.
            IF l_ctt_class = 'CM' THEN
              l_trx_line.quantity := l_quantity_credited;
            ELSE
              l_trx_line.quantity := l_quantity_invoiced;
            END IF;

            -- begin insert data into trx lines
            l_trx_line.org_id            := p_org_id;
            l_trx_line.gta_trx_header_id := l_trx_header.gta_trx_header_id;
            l_trx_line.line_number       := '1';
            l_trx_line.ar_trx_line_id    := l_customer_trx_line_id;
            l_trx_line.inventory_item_id := l_inventory_item_id;

            --EBTAX value
            l_trx_line.original_currency_amount := l_amount;
            l_trx_line.tax_rate                 := l_tax_rate;
            l_trx_line.uom                      := l_uom_code;
            -- get uom_name by uom_code
            -- modified by Brian for bug 7594218
            -- UOM may be null for transaction with class credit memo
            -- If UOM is null, get_uom_name needn't be called anymore
            -- IF l_ctt_class ='CM' AND l_uom_code IS not NULL
            IF l_uom_code is not null THEN
              get_uom_name(p_uom_code => l_uom_code,
                           x_uom_name => l_unit_of_measure);
            END IF; --l_cct_class ='CM' AND l_uom_code IS NULL

            l_trx_line.uom_name := l_unit_of_measure;
            --12/06/2006 Updated by shujuan for bug 5446456
            l_trx_line.unit_price                 := ROUND(p_tax_curr_unit_price,
                                                           2); --l_unit_price;
            l_trx_line.amount                     := ROUND(l_taxable_amount_func_curr,
                                                           2);
            l_trx_line.tax_amount                 := l_tax_amount_func_curr;
            l_trx_line.fp_tax_registration_number := l_fp_registration_number;
            l_trx_line.tp_tax_registration_number := l_tp_registration_number;
            --Yao add for bug#8605196 to support discount line
            l_trx_line.discount_flag              := l_discount_flag;
            l_trx_line.discount_amount            := ROUND(l_discount_amount_func_curr,2);--Yao modified for bug9132371
            l_trx_line.discount_tax_amount       := l_discount_tax_amount;
            l_trx_line.discount_rate              := ABS(l_discount_rate);
            --Yao add for bug#8605196 end to support discount line
            l_trx_line.enabled_flag          := 'Y';
            l_trx_line.request_id            := fnd_global.CONC_REQUEST_ID();
            l_trx_line.program_applicaton_id := fnd_global.PROG_APPL_ID();
            l_trx_line.program_id            := fnd_global.CONC_PROGRAM_ID;
            l_trx_line.program_update_date   := SYSDATE;
            l_trx_line.creation_date         := SYSDATE;
            l_trx_line.created_by            := fnd_global.CONC_LOGIN_ID();
            l_trx_line.last_update_date      := SYSDATE;
            l_trx_line.last_updated_by       := fnd_global.LOGIN_ID();
            l_trx_line.last_update_login     := fnd_global.CONC_LOGIN_ID();

            -- begin log
            IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              log(FND_LOG.LEVEL_PROCEDURE,
                  G_MODULE_PREFIX || l_procedure_name,
                  'Add a new line !!' || l_customer_trx_line_id);
            END IF;
            -- end log

            l_trx_lines.EXTEND;
            l_trx_lines(l_trx_lines.COUNT) := l_trx_line;
            -- end insert data into trx_line

          EXCEPTION
            WHEN l_no_tax_line_exception THEN
              IF (FND_LOG.LEVEL_UNEXPECTED >=
                 FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                               G_MODULE_PREFIX || l_procedure_name,
                               'this line' || l_customer_trx_line_id ||
                               'have not one tax line');
                log(FND_LOG.LEVEL_PROCEDURE,
                    G_MODULE_PREFIX || l_procedure_name,
                    'This line have not one tax line');
              END IF;
          END;
          --Yao Zhang fix bug#8809860 add
          END IF;-- l_adjustment_type IS NULL OR l_adjustment_type<>'DIS'
        END LOOP; /*  c_ra_lines%NOTFOUND */
        -- close cursor c_ra_lines
        CLOSE c_ra_lines;
        -- check the tp_tax_registration_number of every line.
        -- if a trx have more then one tp_tax_regi_number, throw a exception
        IF l_trx_lines.COUNT > 0 THEN
          l_trx_line_index       := l_trx_lines.FIRST;
          l_tp_regi_number_first := l_trx_lines(l_trx_line_index)
                                   .tp_tax_registration_number;
          WHILE l_trx_line_index IS NOT NULL LOOP
            l_tp_regi_number := l_trx_lines(l_trx_line_index)
                               .tp_tax_registration_number;
            IF l_tp_regi_number <> l_tp_regi_number_first THEN
              fnd_message.SET_NAME('AR', 'AR_GTA_MULTI_TP_TAXREG');
              l_error_string := fnd_message.get;
              RAISE l_normal_exception;
            END IF; /*l_tp_regi_number <> l_tp_regi_number_first*/

            l_trx_line_index := l_trx_lines.NEXT(l_trx_line_index);
          END LOOP;

          --Jogen Hu 2006.2.17
          -- init record
          l_trx_rec            := l_trx_rec_init;
          l_trx_rec.trx_header := l_trx_header;
          l_trx_rec.trx_lines  := l_trx_lines;
          x_GTA_TRX_TBL.EXTEND;
          x_GTA_TRX_TBL(x_gta_trx_tbl.COUNT) := l_trx_rec;
          --Jogen Hu 2006.2.17

        END IF; /*l_trx_lines.COUNT > 0*/

        --Jogen Hu 2006.2.17
        /*
        -- init record
        l_trx_rec := l_trx_rec_init;

        l_trx_rec.trx_header := l_trx_header;
        l_trx_rec.trx_lines  := l_trx_lines;
        x_GTA_TRX_TBL.EXTEND;
        x_GTA_TRX_TBL(x_gta_trx_tbl.COUNT) := l_trx_rec;
        */
        --Jogen Hu 2006.2.17
      EXCEPTION
        WHEN l_normal_exception THEN
          --delete warning data from ar_gta_transfer_temp
          DELETE ar_gta_transfer_temp temp
           WHERE temp.transaction_id = l_customer_trx_id
             AND temp.succeeded = 'W';

          INSERT INTO ar_gta_transfer_temp t
            (t.seq,
             t.transaction_id,
             t.succeeded,
             t.transaction_num,
             t.transaction_type,
             t.customer_name,
             t.amount,
             t.failedreason,
             t.gta_invoice_num)
            SELECT ar_gta_transfer_temp_s.NEXTVAL,
                   l_customer_trx_id,
                   'N',
                   l_trx_number,
                   l_ctt_class,
                   l_rac_bill_to_customer_name,
                   NULL,
                   l_error_string,
                   NULL
              FROM dual;
        WHEN l_repeat_exception THEN
          IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                           G_MODULE_PREFIX || l_procedure_name,
                           '. REPEAT_EXCEPTION ' || l_customer_trx_id);
          END IF;

        WHEN OTHERS THEN

          CLOSE c_ra_lines;
          RAISE;
      END;

    END LOOP;

    -- close dynamic sql cursor
    dbms_sql.close_cursor(l_cursor);

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.STRING(fnd_log.LEVEL_PROCEDURE,
                     G_MODULE_PREFIX || l_procedure_name,
                     'END procedure. ');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                       G_MODULE_PREFIX || l_procedure_name ||
                       '. OTHER_EXCEPTION',
                       Sqlcode || Sqlerrm);
      END IF;
      RAISE;

  END Retrieve_AR_TRXs;

  --==========================================================================
  --  PROCEDURE NAME:
  --                get_inv_item_model
  --
  --  DESCRIPTION:
  --                This procedure get_item model
  --                by p_inventory_item_id and org_id
  --
  --  PARAMETERS:   p_org_id                 IN                  NUMBER
  --                p_inventory_item_id      IN                  NUMBER
  --                p_attribute_column       IN                  VARCHAR2
  --                x_attribute_value        OUT NOCOPY          VARCHAR2

  --  DESIGN REFERENCES:
  --                GTA-TRANSFER-PROGRAM-TD.doc
  --
  --  CHANGE HISTORY:
  --                20-APR-2005: Jim Zheng   Created.
  --                22/Jan/2009  Yao Zhang  modified for bug 7829039
  --===========================================================================
  PROCEDURE get_inv_item_model(p_item_master_org_id            IN NUMBER,--yao zhang changed fix bug 7829039
                               p_inventory_item_id IN NUMBER,
                               p_attribute_column  IN VARCHAR2,
                               x_attribute_value   OUT NOCOPY VARCHAR2) IS
    l_procedure_name VARCHAR2(30) := 'get_item_model';

    l_inventory_attribute1  mtl_system_items_b.attribute1%TYPE;
    l_inventory_attribute2  mtl_system_items_b.attribute2%TYPE;
    l_inventory_attribute3  mtl_system_items_b.attribute3%TYPE;
    l_inventory_attribute4  mtl_system_items_b.attribute4%TYPE;
    l_inventory_attribute5  mtl_system_items_b.attribute5%TYPE;
    l_inventory_attribute6  mtl_system_items_b.attribute6%TYPE;
    l_inventory_attribute7  mtl_system_items_b.attribute7%TYPE;
    l_inventory_attribute8  mtl_system_items_b.attribute8%TYPE;
    l_inventory_attribute9  mtl_system_items_b.attribute9%TYPE;
    l_inventory_attribute10 mtl_system_items_b.attribute10%TYPE;
    l_inventory_attribute11 mtl_system_items_b.attribute11%TYPE;
    l_inventory_attribute12 mtl_system_items_b.attribute12%TYPE;
    l_inventory_attribute13 mtl_system_items_b.attribute13%TYPE;
    l_inventory_attribute14 mtl_system_items_b.attribute14%TYPE;
    l_inventory_attribute15 mtl_system_items_b.attribute15%TYPE;
    l_inventory_attribute16 mtl_system_items_b.attribute1%TYPE;
    l_inventory_attribute17 mtl_system_items_b.attribute2%TYPE;
    l_inventory_attribute18 mtl_system_items_b.attribute3%TYPE;
    l_inventory_attribute19 mtl_system_items_b.attribute4%TYPE;
    l_inventory_attribute20 mtl_system_items_b.attribute5%TYPE;
    l_inventory_attribute21 mtl_system_items_b.attribute6%TYPE;
    l_inventory_attribute22 mtl_system_items_b.attribute7%TYPE;
    l_inventory_attribute23 mtl_system_items_b.attribute8%TYPE;
    l_inventory_attribute24 mtl_system_items_b.attribute9%TYPE;
    l_inventory_attribute25 mtl_system_items_b.attribute10%TYPE;
    l_inventory_attribute26 mtl_system_items_b.attribute11%TYPE;
    l_inventory_attribute27 mtl_system_items_b.attribute12%TYPE;
    l_inventory_attribute28 mtl_system_items_b.attribute13%TYPE;
    l_inventory_attribute29 mtl_system_items_b.attribute14%TYPE;
    l_inventory_attribute30 mtl_system_items_b.attribute15%TYPE;

  BEGIN

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.STRING(fnd_log.LEVEL_PROCEDURE,
                     G_MODULE_PREFIX || l_procedure_name,
                     'Begin Procedure. ');
    END IF;

    -- begin log
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'Begin get_inv_item_model');
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'p_item_master_org_id:' || p_item_master_org_id);
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'p_inventory_item_id:' || p_inventory_item_id);
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'p_attribute_column:' || p_attribute_column);
    END IF;
    -- end log

    IF p_inventory_item_id IS NOT NULL THEN

      BEGIN
        SELECT attribute1,
               attribute2,
               attribute3,
               attribute4,
               attribute5,
               attribute6,
               attribute7,
               attribute8,
               attribute9,
               attribute10,
               attribute11,
               attribute12,
               attribute13,
               attribute14,
               attribute15,
               attribute16,
               attribute17,
               attribute18,
               attribute19,
               attribute20,
               attribute21,
               attribute22,
               attribute23,
               attribute24,
               attribute25,
               attribute26,
               attribute27,
               attribute28,
               attribute29,
               attribute30
          INTO l_inventory_attribute1,
               l_inventory_attribute2,
               l_inventory_attribute3,
               l_inventory_attribute4,
               l_inventory_attribute5,
               l_inventory_attribute6,
               l_inventory_attribute7,
               l_inventory_attribute8,
               l_inventory_attribute9,
               l_inventory_attribute10,
               l_inventory_attribute11,
               l_inventory_attribute12,
               l_inventory_attribute13,
               l_inventory_attribute14,
               l_inventory_attribute15,
               l_inventory_attribute16,
               l_inventory_attribute17,
               l_inventory_attribute18,
               l_inventory_attribute19,
               l_inventory_attribute20,
               l_inventory_attribute21,
               l_inventory_attribute22,
               l_inventory_attribute23,
               l_inventory_attribute24,
               l_inventory_attribute25,
               l_inventory_attribute26,
               l_inventory_attribute27,
               l_inventory_attribute28,
               l_inventory_attribute29,
               l_inventory_attribute30
          FROM mtl_system_items_b
         WHERE organization_id = p_item_master_org_id--yao zhang modified for bug 7829039
           AND inventory_item_id = p_inventory_item_id;
      EXCEPTION
        WHEN no_data_found THEN
          IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_log.STRING(fnd_log.LEVEL_EXCEPTION,
                           G_MODULE_PREFIX || l_procedure_name,
                           'no date found ');
          END IF;
          RAISE;
      END;

    ELSE
      -- return  null
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.STRING(fnd_log.LEVEL_PROCEDURE,
                       G_MODULE_PREFIX || l_procedure_name,
                       'The item id is null ');
        log(FND_LOG.LEVEL_PROCEDURE,
            G_MODULE_PREFIX || l_procedure_name,
            l_procedure_name || ' The item id is null');
      END IF;

    END IF;

    IF p_attribute_column = 'ATTRIBUTE1' THEN
      x_attribute_value := l_inventory_attribute1;
    ELSIF p_attribute_column = 'ATTRIBUTE2' THEN
      x_attribute_value := l_inventory_attribute2;
    ELSIF p_attribute_column = 'ATTRIBUTE3' THEN
      x_attribute_value := l_inventory_attribute3;
    ELSIF p_attribute_column = 'ATTRIBUTE4' THEN
      x_attribute_value := l_inventory_attribute4;
    ELSIF p_attribute_column = 'ATTRIBUTE5' THEN
      x_attribute_value := l_inventory_attribute5;
    ELSIF p_attribute_column = 'ATTRIBUTE6' THEN
      x_attribute_value := l_inventory_attribute6;
    ELSIF p_attribute_column = 'ATTRIBUTE7' THEN
      x_attribute_value := l_inventory_attribute7;
    ELSIF p_attribute_column = 'ATTRIBUTE8' THEN
      x_attribute_value := l_inventory_attribute8;
    ELSIF p_attribute_column = 'ATTRIBUTE9' THEN
      x_attribute_value := l_inventory_attribute9;
    ELSIF p_attribute_column = 'ATTRIBUTE10' THEN
      x_attribute_value := l_inventory_attribute10;
    ELSIF p_attribute_column = 'ATTRIBUTE11' THEN
      x_attribute_value := l_inventory_attribute11;
    ELSIF p_attribute_column = 'ATTRIBUTE12' THEN
      x_attribute_value := l_inventory_attribute12;
    ELSIF p_attribute_column = 'ATTRIBUTE13' THEN
      x_attribute_value := l_inventory_attribute13;
    ELSIF p_attribute_column = 'ATTRIBUTE14' THEN
      x_attribute_value := l_inventory_attribute14;
    ELSIF p_attribute_column = 'ATTRIBUTE15' THEN
      x_attribute_value := l_inventory_attribute15;
    ELSIF p_attribute_column = 'ATTRIBUTE16' THEN
      x_attribute_value := l_inventory_attribute16;
    ELSIF p_attribute_column = 'ATTRIBUTE17' THEN
      x_attribute_value := l_inventory_attribute17;
    ELSIF p_attribute_column = 'ATTRIBUTE18' THEN
      x_attribute_value := l_inventory_attribute18;
    ELSIF p_attribute_column = 'ATTRIBUTE19' THEN
      x_attribute_value := l_inventory_attribute19;
    ELSIF p_attribute_column = 'ATTRIBUTE20' THEN
      x_attribute_value := l_inventory_attribute20;
    ELSIF p_attribute_column = 'ATTRIBUTE21' THEN
      x_attribute_value := l_inventory_attribute21;
    ELSIF p_attribute_column = 'ATTRIBUTE22' THEN
      x_attribute_value := l_inventory_attribute22;
    ELSIF p_attribute_column = 'ATTRIBUTE23' THEN
      x_attribute_value := l_inventory_attribute23;
    ELSIF p_attribute_column = 'ATTRIBUTE24' THEN
      x_attribute_value := l_inventory_attribute24;
    ELSIF p_attribute_column = 'ATTRIBUTE25' THEN
      x_attribute_value := l_inventory_attribute25;
    ELSIF p_attribute_column = 'ATTRIBUTE26' THEN
      x_attribute_value := l_inventory_attribute26;
    ELSIF p_attribute_column = 'ATTRIBUTE27' THEN
      x_attribute_value := l_inventory_attribute27;
    ELSIF p_attribute_column = 'ATTRIBUTE28' THEN
      x_attribute_value := l_inventory_attribute28;
    ELSIF p_attribute_column = 'ATTRIBUTE29' THEN
      x_attribute_value := l_inventory_attribute29;
    ELSIF p_attribute_column = 'ATTRIBUTE30' THEN
      x_attribute_value := l_inventory_attribute30;
    ELSE

      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.STRING(fnd_log.LEVEL_UNEXPECTED,
                       G_MODULE_PREFIX || l_procedure_name,
                       'not found data in get_inv_item_model');
      END IF;
    END IF;

    -- begin log
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'x_attribute_value:' || x_attribute_value);
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'End get_inv_item_model');
    END IF;
    -- end log

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.STRING(fnd_log.LEVEL_PROCEDURE,
                     G_MODULE_PREFIX || l_procedure_name,
                     'END procedure. ');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                       G_MODULE_PREFIX || l_procedure_name ||
                       '. OTHER_EXCEPTION ',
                       Sqlcode || Sqlerrm);
      END IF;
      RAISE;
  END get_inv_item_model;

  --==========================================================================
  --  PROCEDURE NAME:
  --                get_ra_item_model
  --
  --  DESCRIPTION:
  --                This procedure get_item model from ra line by ra_line_id and
  --                attribute_column.  This procedure replace the dynamic sql
  --
  --  PARAMETERS:
  --                p_ra_line_id             IN          NUMBER
  --                p_attribute_column       IN          VARCHAR2
  --                x_attribute_value        OUT NOCOPY  VARCHAR2

  --  DESIGN REFERENCES:
  --                GTA-TRANSFER-PROGRAM-TD.doc
  --
  --  CHANGE HISTORY:
  --                20-APR-2005: Jim Zheng   Created.
  --
  --===========================================================================
  PROCEDURE Get_Ra_Item_Model(p_ra_line_id       IN NUMBER,
                              p_attribute_column IN VARCHAR2,
                              x_attribute_value  OUT NOCOPY VARCHAR2) IS
    l_procedure_name VARCHAR2(50) := 'get_ra_item_model';

    l_attribute1  ra_customer_trx_lines_all.Interface_Line_Attribute1%TYPE;
    l_attribute2  ra_customer_trx_lines_all.Interface_Line_Attribute2%TYPE;
    l_attribute3  ra_customer_trx_lines_all.Interface_Line_Attribute3%TYPE;
    l_attribute4  ra_customer_trx_lines_all.Interface_Line_Attribute4%TYPE;
    l_attribute5  ra_customer_trx_lines_all.Interface_Line_Attribute5%TYPE;
    l_attribute6  ra_customer_trx_lines_all.Interface_Line_Attribute6%TYPE;
    l_attribute7  ra_customer_trx_lines_all.Interface_Line_Attribute7%TYPE;
    l_attribute8  ra_customer_trx_lines_all.Interface_Line_Attribute8%TYPE;
    l_attribute9  ra_customer_trx_lines_all.Interface_Line_Attribute9%TYPE;
    l_attribute10 ra_customer_trx_lines_all.Interface_Line_Attribute10%TYPE;
    l_attribute11 ra_customer_trx_lines_all.Interface_Line_Attribute11%TYPE;
    l_attribute12 ra_customer_trx_lines_all.Interface_Line_Attribute12%TYPE;
    l_attribute13 ra_customer_trx_lines_all.Interface_Line_Attribute13%TYPE;
    l_attribute14 ra_customer_trx_lines_all.Interface_Line_Attribute14%TYPE;
    l_attribute15 ra_customer_trx_lines_all.Interface_Line_Attribute15%TYPE;

  BEGIN

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.STRING(fnd_log.LEVEL_PROCEDURE,
                     G_MODULE_PREFIX || l_procedure_name,
                     'Begin Procedure. ');
    END IF;

    -- begin log
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'Begin Get_Ra_Item_Model');
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'p_ra_line_id:' || p_ra_line_id);
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'p_attribute_column:' || p_attribute_column);
    END IF;
    -- end log

    BEGIN
      SELECT interface_line_attribute1,
             interface_line_attribute2,
             interface_line_attribute3,
             interface_line_attribute4,
             interface_line_attribute5,
             interface_line_attribute6,
             interface_line_attribute7,
             interface_line_attribute8,
             interface_line_attribute9,
             interface_line_attribute10,
             interface_line_attribute11,
             interface_line_attribute12,
             interface_line_attribute13,
             interface_line_attribute14,
             interface_line_attribute15
        INTO l_attribute1,
             l_attribute2,
             l_attribute3,
             l_attribute4,
             l_attribute5,
             l_attribute6,
             l_attribute7,
             l_attribute8,
             l_attribute9,
             l_attribute10,
             l_attribute11,
             l_attribute12,
             l_attribute13,
             l_attribute14,
             l_attribute15
        FROM ra_customer_trx_lines_all l
       WHERE l.customer_trx_line_id = p_ra_line_id;

    EXCEPTION
      WHEN no_data_found THEN
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_log.STRING(fnd_log.LEVEL_EXCEPTION,
                         G_MODULE_PREFIX || l_procedure_name,
                         'no date found ');
        END IF;
        RAISE;
    END;

    IF p_attribute_column = 'INTERFACE_LINE_ATTRIBUTE1' THEN
      x_attribute_value := l_attribute1;
    ELSIF p_attribute_column = 'INTERFACE_LINE_ATTRIBUTE2' THEN
      x_attribute_value := l_attribute2;
    ELSIF p_attribute_column = 'INTERFACE_LINE_ATTRIBUTE3' THEN
      x_attribute_value := l_attribute3;
    ELSIF p_attribute_column = 'INTERFACE_LINE_ATTRIBUTE4' THEN
      x_attribute_value := l_attribute4;
    ELSIF p_attribute_column = 'INTERFACE_LINE_ATTRIBUTE5' THEN
      x_attribute_value := l_attribute5;
    ELSIF p_attribute_column = 'INTERFACE_LINE_ATTRIBUTE6' THEN
      x_attribute_value := l_attribute6;
    ELSIF p_attribute_column = 'INTERFACE_LINE_ATTRIBUTE7' THEN
      x_attribute_value := l_attribute7;
    ELSIF p_attribute_column = 'INTERFACE_LINE_ATTRIBUTE8' THEN
      x_attribute_value := l_attribute8;
    ELSIF p_attribute_column = 'INTERFACE_LINE_ATTRIBUTE9' THEN
      x_attribute_value := l_attribute9;
    ELSIF p_attribute_column = 'INTERFACE_LINE_ATTRIBUTE10' THEN
      x_attribute_value := l_attribute10;
    ELSIF p_attribute_column = 'INTERFACE_LINE_ATTRIBUTE11' THEN
      x_attribute_value := l_attribute11;
    ELSIF p_attribute_column = 'INTERFACE_LINE_ATTRIBUTE12' THEN
      x_attribute_value := l_attribute12;
    ELSIF p_attribute_column = 'INTERFACE_LINE_ATTRIBUTE13' THEN
      x_attribute_value := l_attribute13;
    ELSIF p_attribute_column = 'INTERFACE_LINE_ATTRIBUTE14' THEN
      x_attribute_value := l_attribute14;
    ELSIF p_attribute_column = 'INTERFACE_LINE_ATTRIBUTE15' THEN
      x_attribute_value := l_attribute15;
    ELSE
      -- report a error
      x_attribute_value := NULL;

      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.STRING(fnd_log.LEVEL_UNEXPECTED,
                       G_MODULE_PREFIX || l_procedure_name,
                       'no data found in get_ra_item_model');
      END IF;
    END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.STRING(fnd_log.LEVEL_PROCEDURE,
                     G_MODULE_PREFIX || l_procedure_name,
                     'END procedure. ');
    END IF;

    -- begin log
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'End Get_Ra_Item_Model');
    END IF;
    -- end log

  EXCEPTION
    WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                       G_MODULE_PREFIX || l_procedure_name ||
                       '. OTHER_EXCEPTION ',
                       Sqlcode || Sqlerrm);
      END IF;
      RAISE;
  END get_ra_item_model;

  --==========================================================================
  --  FUNCTION NAME:
  --                get_inventory_item_number
  --
  --  DESCRIPTION:
  --                This procedure get item number by inventory_item_id
  --
  --  PARAMETERS:
  --                p_inventory_item_id      IN                  NUMBER
  --                p_org_id                 IN                  NUMBER
  --                x_inventory_item_code    OUT NOCOPY          VARCHAR2
  --
  --  DESIGN REFERENCES:
  --                GTA-TRANSFER-PROGRAM-TD.doc
  --
  --  CHANGE HISTORY:
  --                20-APR-2005: Jim Zheng   Created.
  --                22/Jan/2009  Yao Zhang  modified for bug 7829039
  --===========================================================================
  PROCEDURE Get_Inventory_Item_Number(p_inventory_item_id   IN NUMBER,
                                      p_item_master_org_id  IN NUMBER,--yao zhang changed fix bug 7829039
                                      x_inventory_item_code OUT NOCOPY VARCHAR2) IS
    l_inventory_item_code MTL_SYSTEM_ITEMS_B_KFV.concatenated_segments%TYPE;
    l_procedure_name      VARCHAR2(50) := 'get_inventory_item_number';
  BEGIN

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.STRING(fnd_log.LEVEL_PROCEDURE,
                     G_MODULE_PREFIX || l_procedure_name,
                     'Begin procedure. ');
    END IF;

    -- begin log
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'Begin get_inventory_item_number');
    END IF;
    -- end log

    IF p_inventory_item_id IS NULL THEN
      x_inventory_item_code := NULL;
    ELSE
      SELECT msv.concatenated_segments
        INTO l_inventory_item_code
        FROM MTL_SYSTEM_ITEMS_B_KFV msv
       WHERE msv.inventory_item_id = p_inventory_item_id--yao zhang changed fix bug 7829039
         AND msv.organization_id = p_item_master_org_id;

      -- begin log
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        log(FND_LOG.LEVEL_PROCEDURE,
            G_MODULE_PREFIX || l_procedure_name,
            'l_inventory_item_code:' || l_inventory_item_code);
      END IF;
      -- end log

      x_inventory_item_code := l_inventory_item_code;
    END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.STRING(fnd_log.LEVEL_PROCEDURE,
                     G_MODULE_PREFIX || l_procedure_name,
                     'END procedure. ');
    END IF;

    -- begin log
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      log(FND_LOG.LEVEL_PROCEDURE,
          G_MODULE_PREFIX || l_procedure_name,
          'End get_inventory_item_number');
    END IF;
    -- end log

  EXCEPTION
    WHEN no_data_found THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                       G_MODULE_PREFIX || l_procedure_name ||
                       '. OTHER_EXCEPTION ',
                       'item_code not be found ' || Sqlcode || Sqlerrm);
      END IF;
    WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                       G_MODULE_PREFIX || l_procedure_name ||
                       '. OTHER_EXCEPTION ',
                       Sqlcode || Sqlerrm);
      END IF;
      RAISE;

  END get_inventory_item_number;

  --==========================================================================
  --  FUNCTION NAME:
  --                get_uom_name
  --
  --  DESCRIPTION:
  --                This procedure get item number by inventory_item_id
  --
  --  PARAMETERS:
  --          p_uom_code   IN         VARCHAR2
  --          x_uom_name   OUT NOCOPY VARCHAR2
  --
  --  DESIGN REFERENCES:
  --                GTA-TRANSFER-PROGRAM-TD.doc
  --
  --  CHANGE HISTORY:
  --                11-Oct2005: Jim Zheng   Created.
  --===========================================================================
  PROCEDURE get_uom_name(p_uom_code IN VARCHAR2,
                         x_uom_name OUT NOCOPY VARCHAR2) IS
    l_unit_of_measure mtl_units_of_measure_tl.unit_of_measure%TYPE;
    l_procedure_name  VARCHAR2(30) := 'get_uom_name';
  BEGIN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.STRING(fnd_log.LEVEL_PROCEDURE,
                     G_MODULE_PREFIX || l_procedure_name,
                     'Begin procedure. ');
    END IF;

    BEGIN
      SELECT uom.unit_of_measure
        INTO l_unit_of_measure
        FROM mtl_units_of_measure_tl uom
       WHERE uom.uom_code = p_uom_code
         AND uom.LANGUAGE = userenv('LANG');

    EXCEPTION
      WHEN no_data_found THEN
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_log.STRING(FND_LOG.LEVEL_EXCEPTION,
                         G_MODULE_PREFIX || l_procedure_name,
                         'no data found when select receiving_routing_id by line_location_id' ||
                         SQLCODE || SQLERRM);
        END IF;
        RAISE;
    END;

    x_uom_name := l_unit_of_measure;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.STRING(fnd_log.LEVEL_PROCEDURE,
                     G_MODULE_PREFIX || l_procedure_name,
                     'END procedure. ');
    END IF;

  EXCEPTION

    WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                       G_MODULE_PREFIX || l_procedure_name ||
                       '. OTHER_EXCEPTION ',
                       Sqlcode || Sqlerrm);
      END IF;
      RAISE;
  END;

END AR_GTA_ARTRX_PROC;

/
