--------------------------------------------------------
--  DDL for Package Body JAI_CMN_RGM_VAT_ACCNT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_CMN_RGM_VAT_ACCNT_PKG" 
/* $Header: jai_cmn_rgm_vat.plb 120.11.12010000.6 2010/06/10 03:01:48 boboli ship $ */
/*****************************************************************************************************************************************************************
Created By       : aiyer
Created Date     : 17-Mar-2005
Enhancement Bug  : 4247989
Purpose          : Process the VAT Tax AR records (Invoice,Debit Memo and Credit memo) and populate the jai_rgms_trx_records and gl_interface appropriately.

                   Dependency Due To The Current Bug :
                   This object has been newly created with as a part of the VAT enhancement.
                   Needs to be always released along with the bug 4247989.Lot of Datamodel changes in this enhancement.
                   For details refer base bug 4247989

116.2                08-Jun-2005  Version 116.2 jai_cmn_rgm_vat -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
          as required for CASE COMPLAINCE.

13-Jun-2005    File Version: 116.3
               Ramananda for bug#4428980. Removal of SQL LITERALs is done

7     24/04/2007   Vijay Shankar for Bug#6012570 (5876390), Version:120.2 (115.8 )
                     Forward Porting to R12:
                       Modified the code to hit repository + GL for Projects Billing
                       Modified the main cursor cur_get_deliveries and related code to handle projects billing

3     14-jun-2007    sacsethi for bug 6072461 file version 120.3

		     This bug is used to fp 11i bug 5183031 for vat reveresal
		     Problem - Vat Reversal Enhancement not forward ported
		     Solution - Changes has been done to make it compatible for vat reversal functioanlity also.

  		     Changed the two queries to include VAT REVERSAL tax type
                     Changed the logic to charge recovery and expense accounts if the tax type is VAT REVERSAL

4   28-jun-2007      ssumaith - bug#6147385

		     changed the width of the variable lv_source from 30 to 100

5.  01-08-2007       rchandan for bug#6030615 , Version 120.5
                     Issue : Inter org Forward porting

6.  21-aug-2007	     vkaranam for bug#6030615 ,File version 120.6
                     Changes are done as part of the performance issue.

7.  27-Jul-2009     VUMAASHA for bug 8657720
					Modified ln_credit_amount to ln_debit_amount for VAT reversal scenario in case of OM, Manual AR and interorg transactions.

Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )

----------------------------------------------------------------------------------------------------------------------------------------------------
Current Version       Current Bug    Dependent         Dependency On Files       Version   Author   Date         Remarks
Of File                              On Bug/Patchset
jai_cmn_rgm_vat_accnt_pkg_pkg_b.sql
----------------------------------------------------------------------------------------------------------------------------------------------------
115.0                  4247989       IN60106 +                                            Aiyer   17-Mar-2005   4146708 is the release bug for SERVICE/CESS
                                     4146708 +                                                                             enhancement.
                                     4245089                                                                    4245089 - Base bug for VAT Enhancement.

----------------------------------------------------------------------------------------------------------------------------------------------------

7.  19-Sep-2007	     Bug 5739005. Added by vkantamn ,Version 120.7
		     Included source, source_trx_type and source_table_name in the
		     inner query of the cursor cur_get_deliveries and
		     cur_get_man_ar_inv_taxes for performance issue
		     reported.
		     It increased the performance
		     as these columns have index defined on them in
		     jai_rgm_trx_records.

8. 02-Apr-2010  Allen Yang modified for bug 9485355 (12.1.3 non-shippable Enhancement)
    added parameter p_order_line_id in procedure process_order_invoice and modified
    procedure process_order_invoice to process non-shippable lines.
    Version 120.11.12010000.3

9. 2010/04/14 Bo Li   For bug9305067
                  	 The procedure jai_cmn_rgm_recording_pkg.insert_vat_repository_entry has been called
                  	 in the package JAI_CMN_VAT_ACCNT_PKG. Because of the change of the jai_cmn_rgm_recording_pkg.insert_vat_repository_entry,
                  	 the package JAI_CMN_VAT_ACCNT_PKG should be modified.
                  	 The attribute column of JAI_RGM_TRX_RECORDS are also used. To follow the development standard, they should be
                  	  replaced by new columns with new meaningful ones

10. 20-Apr-2010  Allen Yang modified for bug 9602968
   Modified procedure definition of process_order_invoice added 'DEFAULT NULL' for p_order_line_id
   Version 120.11.12010000.4

11. 09-JUN-2010  Bo Li modified for bug#9766552
                 Issue - Account_name column in table jai_rgm_trx_records is null for VAT tax of
                         non-shippable RMA.
                 Fix   - Give the account name "RECOVERY" for the transaction type "Credit Memo"
*****************************************************************************************************************************************************************/
AS
/*  */

PROCEDURE record_debug_messages ( p_message VARCHAR2 )
/**************************************************************************
Created By       : aiyer
Created Date     : 17-Mar-2005
Enhancement Bug  : 4247989
Purpose          : write debug messages into the request log
Called From      :
***************************************************************************/
AS

BEGIN
  IF nvl(upper(p_record_debug),'N') = 'Y' THEN
    fnd_file.put_line(fnd_file.LOG,p_message);
  END IF;
END record_debug_messages;

PROCEDURE process_order_invoice
(
    p_regime_id               IN      JAI_RGM_DEFINITIONS.REGIME_ID%TYPE                               ,
    p_source                  IN      VARCHAR2                                                 ,
    p_organization_id         IN      JAI_OM_WSH_LINES_ALL.ORGANIZATION_id%TYPE              ,
    p_location_id             IN      JAI_OM_WSH_LINES_ALL.LOCATION_ID%TYPE                  ,
    p_delivery_id             IN      JAI_OM_WSH_LINES_ALL.DELIVERY_ID%TYPE                  ,
    -- added by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), begin
    -- 20-Apr-2010, add 'DEFAULT NULL' by Allen Yang for bug 9602968, begin
    p_order_line_id           IN      JAI_OM_WSH_LINES_ALL.ORDER_LINE_ID%TYPE   DEFAULT NULL ,
    -- 20-Apr-2010, add 'DEFAULT NULL' by Allen Yang for bug 9602968, end
    -- added by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), end
    p_customer_trx_id         IN      RA_CUSTOMER_TRX_ALL.CUSTOMER_TRX_ID%TYPE                 ,
    p_transaction_type        IN      RA_CUST_TRX_TYPES.TYPE%TYPE, -- DEFAULT 'INV'   /* This parameter is used only for AR Accounting */ File.Sql.35 by Brathod
    p_vat_invoice_no          IN      JAI_OM_WSH_LINES_ALL.VAT_INVOICE_NO%TYPE               ,
    p_default_invoice_date    IN      DATE                                                     ,
    p_batch_id                IN      NUMBER                                                   ,
    p_called_from             IN      VARCHAR2                                                 ,
    p_debug                   IN      VARCHAR2,   -- DEFAULT 'N'   File.Sql.35 by Brathod
    p_process_flag    OUT NOCOPY      VARCHAR2                                                 ,
    p_process_message OUT NOCOPY      VARCHAR2
)
/****************************************************************************************************
Created By       : aiyer
Created Date     : 17-Mar-2005
Enhancement Bug  : 4247989
Purpose          : Process the VAT Tax AR records (Invoice,Debit Memo and Credit memo)
                   and populate the jai_rgms_trx_records and gl_interface appropriately.

Called From      : India VAT Invoice Number/Accounting Concurrent Program:-
                   =====================================================
                   Procedure ja_.process

                   AR Invoice Completion:-
                   =======================
                    Trigger ja_in_loc_ar_hdr_update_trg for Invoice and Debit Memo
                    Trigger ja_in_loc_ar_hdr_update_trg_vat for Credit Memo

Changed History:

1.	09-APR-2008	JMEENA for bug#6944839 File Version 120.1.12000000.4
			Modified the cursor cur_get_man_ar_inv_taxes, Changed jrttv1.tax_type to jrttv1.regime_code in where clause.
2.  02-Apr-2010  Allen Yang modified for bug 9485355 (12.1.3 non-shippable Enhancement)
    added parameter p_order_line_id in procedure process_order_invoice and modified
    procedure process_order_invoice to process non-shippable lines.
3.  20-Apr-2010  Allen Yang modified for bug 9602968
    add 'DEFAULT NULL' for parameter p_order_line_id.
***************************************************************************************************/
AS

  ln_repository_id                  JAI_RGM_TRX_RECORDS.REPOSITORY_ID%TYPE                          ;
  ln_liab_acct_ccid                 GL_CODE_COMBINATIONS.code_combination_id%TYPE                   ;
  ln_intliab_acct_ccid              GL_CODE_COMBINATIONS.code_combination_id%TYPE                   ;
  ln_charge_ac_id                   GL_CODE_COMBINATIONS.code_combination_id%TYPE                   ;
  ln_balancing_ac_id                GL_CODE_COMBINATIONS.code_combination_id%TYPE                   ;

  lv_process_flag                   VARCHAR2(2)                                                     ;
  lv_process_message                VARCHAR2(1996)                                                  ;
  ln_debit_amount                   JAI_RGM_TRX_RECORDS.DEBIT_AMOUNT%TYPE                           ;
  ln_credit_amount                  JAI_RGM_TRX_RECORDS.CREDIT_AMOUNT%TYPE                          ;

  --Date 14/06/2007 by sacsethi for bug 6072461 (for VAT Reversal)
  ln_recov_acct_ccid                 GL_CODE_COMBINATIONS.code_combination_id%TYPE                  ;
  ln_expense_acct_ccid               GL_CODE_COMBINATIONS.code_combination_id%TYPE                  ;
  lc_account_name                    VARCHAR2(50);
  -- End 6072461
  /*added the below cursors for performance issue,for bug#6030615*/
      --start
  CURSOR c_chk_rgm_trxs(cp_transaction_header_id in number,cp_transaction_temp_id in number,cp_tax_id in number) IS
  SELECT 1
          FROM
          jai_rgm_trx_records jrtr
          WHERE
           jrtr.trx_reference1         = cp_transaction_header_id         AND -- Modifiied By Bo Li for replaceing the attribute1 with trx_reference1
           jrtr.source_document_id = cp_transaction_temp_id   AND
           jrtr.reference_id       = cp_tax_id AND
           jrtr.organization_id    = p_organization_id AND
           jrtr.location_id        = p_location_id;
ln_rgm_cnt number;

  --end
  /*added by rchandan for bug #6030615*/
/*
||Fetch the information from jai_mtl_trxs and jai_cmn_document_taxes
*/
CURSOR cur_get_mtltxns
IS
SELECT
	 jtc.tax_type,
	 jtc.tax_rate,
	 jtc.tax_id,
	 jmt.transaction_temp_id,
	 jmt.transaction_header_id,
	 jmt.vat_assessable_value,
	 jmt.creation_date,
	 jcdt.tax_amt
FROM
	 jai_mtl_trxs jmt,
	 jai_cmn_document_taxes jcdt,
	 jai_cmn_taxes_all jtc,
	 jai_rgm_registrations jrg,
         jai_rgm_definitions jrr
WHERE
	 jmt.from_organization   = p_organization_id
			--   AND jmt.location_id        = p_location_id
	 AND jmt.transaction_header_id  = p_delivery_id
	 AND jmt.transaction_header_id=jcdt.source_doc_id
	 AND jmt.transaction_temp_id=jcdt.source_doc_line_id
	 AND jcdt.tax_id=jtc.tax_id
	 AND jtc.tax_type= jrg.attribute_code
	AND jrr.regime_code = jai_constants.vat_regime
	AND jrg.regime_id = jrr.regime_id
	AND jrg.registration_type = 'TAX_TYPES' ;


  /*
  || Fetch the delivery information from JAI_OM_WSH_LINES_ALL and JAI_OM_WSH_LINE_TAXES
  */
  /* Bug 5739005. Added by vkantamn
     * Included source, source_trx_type and source_table_name in the inner
     * query for performance issue reported.
  */
  CURSOR cur_get_deliveries
    ( cp_source                  IN jai_rgm_trx_records.source%TYPE,
       cp_source_trx_type	 IN jai_rgm_trx_records.source_trx_type%TYPE,
       cp_source_table_name      IN jai_rgm_trx_records.source_table_name%TYPE
    )
  IS
  SELECT
        jspl.delivery_id                                        ,
        jspl.delivery_detail_id                                 ,
        jspl.vat_assessable_value                               ,
        nvl(jspl.vat_exemption_flag,'N') vat_exemption_flag     ,
        jspl.order_line_id                                      ,
        jsptl.tax_id                                            ,
        jsptl.tax_rate                                          ,
        /* Bug# 6012570 (5876390)  jsptl.tax_amount                                        ,  */
        jsptl.func_tax_amount                                   ,
        jsptl.creation_date                                     ,
        jtc.tax_type
  FROM
        JAI_OM_WSH_LINES_ALL       jspl              ,
        JAI_OM_WSH_LINE_TAXES      jsptl             ,
        JAI_CMN_TAXES_ALL          jtc               ,
	 ( --Date 14/06/2007 by sacsethi for bug 6072461 , View is replaced by subquery with vat reversal
               SELECT jrttv1.tax_type  tax_type
               FROM   jai_regime_tax_types_v  jrttv1
               WHERE  jrttv1.regime_code = jai_constants.vat_regime --Modified by JMEENA from jrttv1.tax_type to jrttv1.regime_code for bug#6944839
               UNION
               SELECT 'VAT REVERSAL' tax_type FROM DUAL
         ) jrttv
  WHERE
        jspl.organization_id    = p_organization_id                                                AND
        jspl.location_id        = p_location_id                                                    AND
        -- modified by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), begin
        -- jspl.delivery_id        = p_delivery_id                                                    AND
        -- jspl.delivery_detail_id = jsptl.delivery_detail_id                                         AND
        ((jspl.delivery_id = p_delivery_id AND jspl.delivery_detail_id = jsptl.delivery_detail_id)  OR
        (jspl.order_line_id = p_order_line_id AND jspl.order_line_id = jsptl.order_line_id))        AND
        -- modified by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), end
        jsptl.tax_id            = jtc.tax_id                                                       AND
        jtc.tax_type            = jrttv.tax_type                                                   AND
     -- jrttv.regime_code       = jai_constants.vat_regime                                         AND --Date 14/06/2007 by sacsethi for bug 6072461
        NOT EXISTS                 ( SELECT 1
                                     FROM jai_rgm_trx_records jrtr
                                     WHERE
						-- Bug 5739005. Added by vkantamn
						jrtr.source             = cp_source AND
						jrtr.source_trx_type    =   cp_source_trx_type AND
						jrtr.organization_id    =  p_organization_id AND
						jrtr.location_id        =  p_location_id  AND
						jrtr.source_table_name  =  cp_source_table_name AND
					        -- End for bug 5739005.
            -- modified by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), begin
						-- jrtr.attribute1         = jspl.delivery_id          AND
						-- jrtr.source_document_id = jspl.delivery_detail_id   AND
						-- Modifiied By Bo Li for replaceing the attribute1, attribute2 with trx_reference1, reference2 Begin
           ((jrtr.trx_reference1 = jspl.delivery_id  AND jrtr.source_document_id = jspl.delivery_detail_id) OR
            (jrtr.trx_reference2 = jspl.order_line_id AND jrtr.source_document_id  = jspl.order_line_id))   AND
            -- Modifiied By Bo Li for replaceing the attribute1, attribute2 with trx_reference1, reference2 Begin
            -- modified by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), end
						jrtr.reference_id       = jsptl.tax_id
                                   )
      -- modified by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), begin
      -- AND cp_source =  jai_constants.source_wsh /* Bug# 6012570 (5876390) */
      AND (cp_source =  jai_constants.source_wsh OR cp_source =  jai_constants.source_nsh)
      -- modified by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), end

     /* start. bug#Bug# 6012570 (5876390). added the union condition */
     UNION
     SELECT
             jpdi.draft_invoice_id                                       ,
             null                             delivery_detail_id         ,
             sum(jpdil.line_amt)              vat_assessable_value       ,
             'N'                              vat_exemption_flag         ,
             null                             order_line_id              ,
             jcdt.tax_id                      tax_id                     ,
             jcdt.tax_rate                    tax_rate                   ,
             /* Bug# 6012570 (5876390) null                             tax_amount                 , */
             sum(jcdt.func_tax_amt)           func_tax_amount            ,
             max(jpdi.last_update_date)       creation_date              ,
             jcdt.tax_type                    tax_type
       FROM
             jai_pa_draft_invoices           jpdi                        ,
             jai_pa_draft_invoice_lines      jpdil                       ,
             jai_cmn_document_taxes          jcdt                        ,
             (
               SELECT jrttv1.tax_type  tax_type
               FROM   jai_regime_tax_types_v  jrttv1
               WHERE  jrttv1.regime_code = jai_constants.vat_regime
               UNION
               SELECT 'VAT REVERSAL' tax_type FROM DUAL
             ) jrttv
       WHERE cp_source                 = jai_pa_billing_pkg.gv_source_projects
       AND   jpdi.draft_invoice_id     = jpdil.draft_invoice_id
       AND   jpdil.draft_invoice_line_id =  jcdt.source_doc_line_id
       AND   jcdt.source_doc_id        = jpdi.draft_invoice_id
       AND   jcdt.source_doc_type      = jai_pa_billing_pkg.gv_source_projects
       AND   jcdt.tax_type             = jrttv.tax_type
       AND   jpdi.draft_invoice_id     = p_delivery_id
       GROUP BY jpdi.draft_invoice_id, jcdt.tax_type, jcdt.tax_id, jcdt.tax_rate;
       /* end bug# 6012570 (5876390) */
  /*
  || Fetch the invoice information from ja_in_ra_customer_trx_tax_lines so_picking_lines and JAI_OM_WSH_LINE_TAXES
  */
   /* Bug 5739005. Added by vkantamn
   * Included source, source_trx_type and source_table_name in the inner
   * query for performance issue reported.
   */
  CURSOR cur_get_man_ar_inv_taxes
  ( cp_source                  IN jai_rgm_trx_records.source%TYPE,
       cp_source_trx_type     IN jai_rgm_trx_records.source_trx_type%TYPE,
       cp_source_table_name IN jai_rgm_trx_records.source_table_name%TYPE
     )
  IS
  SELECT
        jctl.customer_trx_id                                    ,
        jctl.vat_assessable_value                               ,
        nvl(jctl.vat_exemption_flag,'N') vat_exemption_flag     ,
        jcttl.customer_trx_line_id                              ,
        jcttl.tax_id                                            ,
        jcttl.link_to_cust_trx_line_id                          ,
        jcttl.func_tax_amount                                   ,
        jcttl.creation_date                                     ,
        jtc.tax_type                                            ,
        jcttl.tax_rate
  FROM
        JAI_AR_TRX_LINES jctl  ,
        JAI_AR_TRX_TAX_LINES jcttl ,
        JAI_CMN_TAXES_ALL              jtc  ,
         ( --Date 14/06/2007 by sacsethi for bug 6072461 , View is replaced by subquery with vat reversal
          SELECT jrttv1.tax_type  tax_type
          FROM   jai_regime_tax_types_v  jrttv1
          WHERE  jrttv1.regime_code  = jai_constants.vat_regime
          UNION
          SELECT 'VAT REVERSAL' tax_type
          FROM DUAL
         ) jrttv
  WHERE
        jctl.customer_trx_id      = p_customer_trx_id               AND
        jctl.customer_trx_line_id = jcttl.link_to_cust_trx_line_id  AND
        jcttl.tax_id              = jtc.tax_id                      AND
        jtc.tax_type              = jrttv.tax_type                  AND
        NOT EXISTS                 ( SELECT
                                               1
                                     FROM
                                               jai_rgm_trx_records jrtr
                                     WHERE
                                               -- Bug 5739005. Added by vkantamn
   						jrtr.source             = cp_source AND
						jrtr.source_trx_type    = cp_source_trx_type AND
						jrtr.organization_id    =  p_organization_id AND
						jrtr.location_id        =  p_location_id AND
						jrtr.source_table_name  =  cp_source_table_name AND
						-- End for bug 5739005
					        jrtr.trx_reference1         = p_customer_trx_id            AND -- Modifiied By Bo Li for replaceing the attribute1 with trx_reference1
                                                jrtr.source_document_id = jcttl.customer_trx_line_id   AND
                                                jrtr.reference_id       = jcttl.tax_id
                                   ) ;


  /* Following variables added for Projects Billing. Bug# 6012570 (5876390) */
  lv_source_trx_type    jai_rgm_trx_records.source_trx_type%type;
  lv_source_table_name  VARCHAR2(30);
  lv_called_from        VARCHAR2(100); /*ssumaith - changed the width to 100 from 30 */
  lv_attribute_context  VARCHAR2(30);
  ln_source_id          NUMBER(15);

BEGIN

  record_debug_messages ('**********************1- START OF jai_cmn_rgm_processing_pkg.PROCESS_ORDER_INVOICE-P_DELIVERY ID ->'||p_delivery_id||' **********************');

  record_debug_messages ('2- Input parameters passed are p_called_from ->'||p_called_from
                                                   ||', p_regime_id  -> '           || p_regime_id
                                                   ||', p_source -> '           || p_source
                                                   ||', p_organization_id -> '  || p_organization_id
                                                   ||', p_location_id -> '      || p_location_id
                                                   ||', p_delivery_id -> '      || p_delivery_id
                                                   ||', p_customer_trx_id -> '  || p_customer_trx_id
                                                   ||', p_transaction_type-> '  || p_transaction_type
                                                   ||', p_vat_invoice_no ->'    || p_vat_invoice_no
                                                   ||', p_batch_id -> '         || p_batch_id

                        );


  /******************************************************************************************
  ||Variable Initialization
  ******************************************************************************************/

  lv_process_flag       := jai_constants.successful     ;
  lv_process_message    := null                         ;

  p_process_flag        := lv_process_flag              ;
  p_process_message     := lv_process_message           ;

  p_record_debug        := p_debug                      ;
  ln_debit_amount       := NULL                         ;
  ln_credit_amount      := NULL                         ;



  /******************************************************************************************
  || Validate input parameters
  ******************************************************************************************/

  IF p_regime_id IS NULL THEN
    record_debug_messages('2.1 REGIME ID cannot be null');
    p_process_flag    := jai_constants.expected_error;
    p_process_message := 'Invalid REGIME';
    return;
  END IF;

  /*
  || Validate that organization and location cannot be null
  */

  IF p_organization_id IS NULL OR
     p_location_id     IS NULL
  THEN
    record_debug_messages('3 Organization_id or Location_id cannot be null. Please provide a valid value for these fields');
    p_process_flag    := jai_constants.expected_error;
    p_process_message := 'Organization_id or Location_id cannot be null. Please provide a valid value for these fields';
    return;
  END IF;


  /*
  || Validate that organization and location cannot be null
  */
  IF p_delivery_id     IS NULL AND
     -- added by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), begin
     p_order_line_id   IS NULL AND
     -- added by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), end
     p_customer_trx_id IS NULL
  THEN
    -- modified by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), begin
    record_debug_messages(' 4 Delivery ID/Order Line ID/Customer_trx_id both cannot be null. Please provide a valid value for either one of the three');
    -- record_debug_messages(' 4 Delivery ID/Customer_trx_id both cannot be null. Please provide a valid value for either one of the two');
    p_process_flag    := jai_constants.expected_error;
    -- p_process_message := 'Delivery ID/Customer_trx_id both cannot be null. Please provide a valid value for either one of the two';
    p_process_message := 'Delivery ID/Order Line ID/Customer_trx_id both cannot be null. Please provide a valid value for either one of the three';
    -- modified by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), end
    return;
  END IF;

  /*
  || Validate vat invoice number is passed
  || Only in case of a CM the vat invoice number can be null (i.e called from JA_IN_LOC_AR_HDR_UPD_TRG_VAT )in all other
  || cases if found as null then stop processing
  */
  IF p_vat_invoice_no          IS NULL                              AND
     nvl(p_called_from,'####') <> 'JA_IN_LOC_AR_HDR_UPD_TRG_VAT'
     AND  nvl(p_transaction_type ,'####') <> 'DRAFT_INVOICE_CM'   /* bug#6012570 (5876390) introduced for Projects Billing Implementation */
  THEN
    record_debug_messages('5 Vat Invoice Number cannot be null. Please provide a valid VAT Invoice Number');
    p_process_flag    := jai_constants.expected_error;
    p_process_message := nvl(p_transaction_type ,'####') /* bug#6012570 (5876390) */
                            || 'Vat Invoice Number cannot be null. Please provide a valid VAT Invoice Number';
    return;
  END IF;


  /******************************************************************************************
  || Process the Deliver (In case of OM) and the Manual Invoice (in case of AR) and pass suitable
  || accounting entries.
  ******************************************************************************************/

  IF upper(p_source) in (
                             upper(jai_constants.source_wsh)
                             -- added by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), begin
                             ,upper(jai_constants.source_nsh)
                             -- added by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), end
                             , jai_pa_billing_pkg.gv_source_projects     /* Bug# 6012570 (5876390) */
                           )
  THEN

    if jai_pa_billing_pkg.gv_debug then
      jai_cmn_utils_pkg.print_log ( jai_pa_billing_pkg.file, '3 rgm_om_ar_vat_accnt_pkg.process_order_invoice . Psource:'||p_source);
    end if;

    /* Start Bug# 6012570 (5876390) */
    if upper(p_source) =  upper(jai_constants.source_wsh) then
      record_debug_messages ('6 Delivery PROCESSING');
      lv_source_trx_type    := jai_constants.source_ttype_delivery;
      lv_source_table_name  := jai_constants.tname_dlry_dtl;
      lv_called_from        := jai_constants.vat_repo_call_from_om_ar;
      lv_attribute_context  := jai_constants.contxt_delivery;

    elsif p_source = jai_pa_billing_pkg.gv_source_projects then
      record_debug_messages ('6 Projects Draft Invoice PROCESSING');
      lv_source_trx_type    := jai_pa_billing_pkg.gv_trx_type_draft_invoice;    -- 'DRAFT_INVOICE';
      lv_source_table_name  := jai_pa_billing_pkg.gv_draft_invoice_table;       -- 'JAI_PA_DRAFT_INVOICES';
      lv_called_from        := p_called_from;
      lv_attribute_context  := jai_pa_billing_pkg.gv_draft_invoice_release;     -- 'DRAFT_INVOICE_RELEASE';
    -- added by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), begin
    elsif p_source = upper(jai_constants.source_nsh) then
      record_debug_messages ('6 Non-Shippable Item PROCESSING');
      lv_source_trx_type    := jai_constants.source_ttype_non_shippable;
      lv_source_table_name  := jai_constants.tname_order_lines_all;
      lv_called_from        := jai_constants.vat_repo_call_from_om_ar;
      lv_attribute_context  := jai_constants.contxt_non_shippable;
     -- added by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), end
    end if;

    /* End Bug# 6012570 (5876390) */


    /*
    || Process Orders - OM side processing
    */
    /* Bug# 6012570 (5876390) FOR  rec_cur_get_deliveries IN cur_get_deliveries */
    /* Bug 5739005 vkantamn --Parameters needed in cur_get_deliveries */
    FOR  rec_cur_get_deliveries IN cur_get_deliveries(p_source, lv_source_trx_type, lv_source_table_name)
    LOOP

      if jai_pa_billing_pkg.gv_debug then
        jai_cmn_utils_pkg.print_log ( jai_pa_billing_pkg.file, '4 rgm_om_ar_vat_accnt_pkg.process_order_invoice. Loop TaxId:'||rec_cur_get_deliveries.tax_id);
      end if;

      record_debug_messages (' ************7 PROCESSING Delivery id -> '|| p_delivery_id||'Delivery Details ID -> '||rec_cur_get_deliveries.delivery_detail_id||' ************' );
      /*******************************
      ||Variable Initialization
      *******************************/
      ln_liab_acct_ccid    := null;
      ln_intliab_acct_ccid := null;
      ln_debit_amount      := rec_cur_get_deliveries.func_tax_amount;

      /* Start - sacsethi, Added w.r.t BUG#6072461 ( for VAT Reversal)*/
      ln_credit_amount     := null;
      ln_debit_amount      := null;
      ln_recov_acct_ccid   := null;
      ln_expense_acct_ccid := null;
      ln_charge_ac_id      := null;
      ln_balancing_ac_id   := null;
      lc_account_name      := null;
      /* End - sacsethi, Added w.r.t BUG#6072461 ( for VAT Reversal)*/

      /* Start Bug# 6012570 (5876390) */
       if upper(p_source) =  upper(jai_constants.source_wsh) then
         ln_source_id  := rec_cur_get_deliveries.delivery_detail_id;

       elsif p_source = jai_pa_billing_pkg.gv_source_projects then
         ln_source_id  := rec_cur_get_deliveries.delivery_id;  /* this is draft_invoice_id */
       -- added by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), begin
       elsif p_source = upper(jai_constants.source_nsh) then
         ln_source_id  := rec_cur_get_deliveries.order_line_id;
       -- added by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), end
       end if;
       /* End Bug# 6012570 (5876390) */

      record_debug_messages ('8 Variables Initialised');


      IF ( rec_cur_get_deliveries.tax_type = 'VAT REVERSAL' ) THEN
        /* Start - sacsethi, Added w.r.t BUG#6072461 ( for VAT Reversal)*/
        /*******************************
        ||Get the code combination id
        ||for the "RECOVERY ACCOUNT"
        *******************************/
        ln_recov_acct_ccid   :=    jai_cmn_rgm_recording_pkg.get_account(
                                                                          p_regime_id         => p_regime_id                        ,
                                                                          p_organization_type => jai_constants.orgn_type_io         ,
                                                                          p_organization_id   => p_organization_id                  ,
                                                                          p_location_id       => p_location_id                      ,
                                                                          p_tax_type          => rec_cur_get_deliveries.tax_type    ,
                                                                          p_account_name      => jai_constants.recovery
                                                                        ) ;

        /*******************************
        || Get the code combination id
        || for the "EXPENSE ACCOUNT"
        *******************************/
        ln_expense_acct_ccid :=    jai_cmn_rgm_recording_pkg.get_account(
                                                                          p_regime_id         => p_regime_id                        ,
                                                                          p_organization_type => jai_constants.orgn_type_io         ,
                                                                          p_organization_id   => p_organization_id                  ,
                                                                          p_location_id       => p_location_id                      ,
                                                                          p_tax_type          => rec_cur_get_deliveries.tax_type    ,
                                                                          p_account_name      => jai_constants.expense
                                                                        ) ;
        lc_account_name       := jai_constants.recovery;
        ln_charge_ac_id       := ln_recov_acct_ccid;
        ln_balancing_ac_id    := ln_expense_acct_ccid;
        ln_debit_amount      := rec_cur_get_deliveries.func_tax_amount; /* Modified ln_credit_amount to ln_debit_amount for bug 8657720 by vumaasha */

        IF  ln_charge_ac_id  IS NULL OR
            ln_balancing_ac_id IS NULL
        THEN
          record_debug_messages('9 VAT delivery accounting entries cannot be passed. Please set up the Recovery account and the Expense account for VAT Reversal');
          p_process_flag    := jai_constants.expected_error;
          p_process_message := 'VAT delivery accounting entries cannot be passed. Please set up the Recovery account and the Expense account for VAT reversal';
          return;
        END IF;
        /* End - sacsethi, Added w.r.t BUG#6072461 ( for VAT Reversal)*/
      ELSE

      /*******************************
      ||Get the code combination id
      ||for the "LIABILITY ACCOUNT"
      *******************************/
      ln_liab_acct_ccid    :=    jai_cmn_rgm_recording_pkg.get_account(
                                                                          p_regime_id         => p_regime_id                        ,
                                                                          p_organization_type => jai_constants.orgn_type_io         ,
                                                                          p_organization_id   => p_organization_id                  ,
                                                                          p_location_id       => p_location_id                      ,
                                                                          p_tax_type          => rec_cur_get_deliveries.tax_type    ,
                                                                          p_account_name      => jai_constants.liability
                                                                      ) ;

      /*******************************
      || Get the code combination id
      || for the "INTERIM LIABILITY ACCOUNT"
      *******************************/
      ln_intliab_acct_ccid :=    jai_cmn_rgm_recording_pkg.get_account(
                                                                          p_regime_id         => p_regime_id                        ,
                                                                          p_organization_type => jai_constants.orgn_type_io         ,
                                                                          p_organization_id   => p_organization_id                  ,
                                                                          p_location_id       => p_location_id                      ,
                                                                          p_tax_type          => rec_cur_get_deliveries.tax_type    ,
                                                                          p_account_name      => jai_constants.liability_interim
                                                                      ) ;


        /* Start - sacsethi, Added w.r.t BUG#6072461 ( for VAT Reversal)*/
        lc_account_name       := jai_constants.liability;
        ln_charge_ac_id       := ln_liab_acct_ccid;
        ln_balancing_ac_id    := ln_intliab_acct_ccid;
        ln_debit_amount       := rec_cur_get_deliveries.func_tax_amount;
        IF  ln_charge_ac_id    IS NULL OR
            ln_balancing_ac_id IS NULL
        THEN
          record_debug_messages('9 VAT delivery accounting entries cannot be passed. Please set up the Liability account and the Interim Liability account for the corresponding VAT regime');
          p_process_flag    := jai_constants.expected_error;
          p_process_message := 'VAT delivery accounting entries cannot be passed. Please set up the Liability account and the Interim Liability account for the corresponding VAT regime';
          return;
        END IF;
      END IF;

      --Date 14/06/2007 by sacsethi for bug 6072461
	      -- FOR VAT REVERSAL

      /*
      || Validate that if any one of the liability account or interim liability account is not defined then error our
      */
      /*
      IF ln_liab_acct_ccid    IS NULL OR
         ln_intliab_acct_ccid IS NULL
      THEN
        record_debug_messages('9 VAT delivery accouting entries cannot be passed. Please set up the Liability account and the Interim Liability account for the corresponding VAT regime');
        p_process_flag    := jai_constants.expected_error;
        p_process_message := 'VAT delivery accouting entries cannot be passed. Please set up the Liability account and the Interim Liability account for the corresponding VAT regime';
        return;
      END IF;
      END IF ;
   */

      record_debug_messages ('10 Processing the delivery, parameters are delivery_id -> '           || rec_cur_get_deliveries.delivery_id
                                           ||', source_document_type_id i.e delivery_detail_id -> ' || rec_cur_get_deliveries.delivery_detail_id
                                           ||', rec_cur_get_deliveries.tax_type  -> '               || rec_cur_get_deliveries.tax_type
                                           ||', p_organization_id -> '                              || p_organization_id
                                           ||', p_location_id -> '                                  || p_location_id
                                           ||', vat_exemption_flag -> '                             || rec_cur_get_deliveries.vat_exemption_flag
                                           ||', pn_assessable_value ->'                             || rec_cur_get_deliveries.vat_assessable_value
                                           ||', account_name -> '                                   || jai_constants.liability
                                           ||', p_charge_account_id-> '                             || ln_liab_acct_ccid
                                           ||', p_balancing_account_id-> '                          || ln_intliab_acct_ccid
                                           ||',ln_debit_amount -> '                                 || ln_debit_amount
                                           ||',ln_credit_amount -> '                                || ln_credit_amount
                                           ||', p_amount-> '                                        || rec_cur_get_deliveries.func_tax_amount
                                           ||', p_trx_amount-> '                                    || rec_cur_get_deliveries.func_tax_amount
                                           ||', p_tax_rate -> '                                     || rec_cur_get_deliveries.tax_rate
                                           ||', p_reference_id  i.e tax_id -> '                     || rec_cur_get_deliveries.tax_id
                                           ||', p_inv_organization_id -> '                          || p_organization_id
                                           ||', p_attribute1 i.e delivery_id -> '                   || rec_cur_get_deliveries.delivery_id
                                           ||', p_attribute2 i.e order_line_id -> '                 || rec_cur_get_deliveries.order_line_id
                                           ||', p_attribute_context -> '                            || jai_constants.contxt_delivery
                            );

      record_debug_messages ('11 Before call to jai_cmn_rgm_recording_pkg.insert_vat_repository_entry');


       if jai_pa_billing_pkg.gv_debug then
         jai_cmn_utils_pkg.print_log ( jai_pa_billing_pkg.file, '6 rgm_om_ar_vat_accnt_pkg.process_order_invoice. Bef jai_cmn_rgm_recording_pkg.insert_vat_repository_entry');
       end if;

       jai_cmn_rgm_recording_pkg.insert_vat_repository_entry (
            pn_repository_id            => ln_repository_id                                                   ,
            pn_regime_id                => p_regime_id                                                        ,
            pv_tax_type                 => rec_cur_get_deliveries.tax_type                                    ,
            pv_organization_type        => jai_constants.orgn_type_io                                         ,
            pn_organization_id          => p_organization_id                                                  ,
            pn_location_id              => p_location_id                                                      ,
            pv_source                   => p_source                                                           ,
            pv_source_trx_type          => lv_source_trx_type,  /* Bug# 6012570 (5876390) jai_constants.source_ttype_delivery                                , */
            pv_source_table_name        => lv_source_table_name, /* Bug# 6012570 (5876390) jai_constants.tname_dlry_dtl                                       , */
            pn_source_id                => ln_source_id,          /* Bug# 6012570 (5876390) rec_cur_get_deliveries.delivery_detail_id                          , */
            pd_transaction_date         => rec_cur_get_deliveries.creation_date                               ,
/*  Date 14/06/2007 by sacsethi for bug 6072461
	    pv_account_name             => jai_constants.liability                                            ,
            pn_charge_account_id        => ln_liab_acct_ccid                                                  ,
            pn_balancing_account_id     => ln_intliab_acct_ccid                                               ,
    Changes in account name , charge account id and balancing account id      */
            pv_account_name             => lc_account_name                                                    ,
            pn_charge_account_id        => ln_charge_ac_id                                                    ,
            pn_balancing_account_id     => ln_balancing_ac_id                                                 ,
            pn_credit_amount            => ln_credit_amount                                                   ,
            pn_debit_amount             => ln_debit_amount                                                    ,
            pn_assessable_value         => rec_cur_get_deliveries.vat_assessable_value                        ,
            pn_tax_rate                 => rec_cur_get_deliveries.tax_rate                                    ,
            pn_reference_id             => rec_cur_get_deliveries.tax_id                                      ,
            pn_batch_id                 => p_batch_id                                                         ,
            pn_inv_organization_id      => p_organization_id                                                  ,
            pv_invoice_no               => p_vat_invoice_no                                                   ,
            pd_invoice_date             => nvl(p_default_invoice_date,rec_cur_get_deliveries.creation_date)   ,
            pv_called_from              => lv_called_from,    /* Bug# 6012570 (5876390) jai_constants.vat_repo_call_from_om_ar                                  , */
            pv_process_flag             => lv_process_flag                                                    ,
            pv_process_message          => lv_process_message                                                 ,
            --Modified by Bo Li for replacing old attribtue columns with new ones Begin
            -----------------------------------------------------------------------------------------------------------------
            pv_trx_reference_context        => lv_attribute_context,    /* Bug# 6012570 (5876390) jai_constants.contxt_delivery                                      , */
            pv_trx_reference1               => rec_cur_get_deliveries.delivery_id                                 ,
            pv_trx_reference2               => rec_cur_get_deliveries.order_line_id                               ,
            pv_trx_reference3               => NULL                                                               ,
            pv_trx_reference4               => NULL                                                               ,
            pv_trx_reference5               => NULL
            -----------------------------------------------------------------------------------------------------------------
            --Modified by Bo Li for replacing old attribtue columns with new ones End
      );

        if jai_pa_billing_pkg.gv_debug then
          jai_cmn_utils_pkg.print_log ( jai_pa_billing_pkg.file, '7 rgm_om_ar_vat_accnt_pkg.process_order_invoice. After callto insert_vat_repository_entry'
              ||', ln_repository_id:'||ln_repository_id
              ||', lv_process_flag:'||lv_process_flag
              ||', lv_process_message:'||lv_process_message
          );
        end if;

        IF lv_process_flag = jai_constants.expected_error    OR
           lv_process_flag = jai_constants.unexpected_error
        THEN
          /*
          || As Returned status is an error hence:-
          ||1. Delivery processing should be terminated,Rollback the insert and exit Loop
          ||2. Set out variables p_process_flag and p_process_message accordingly
          ||3. Return from the procedure
          */
          record_debug_messages(' 12 Error in call to jai_cmn_rgm_recording_pkg.insert_vat_repository_entry - lv_process_flag '||lv_process_flag
                                            ||', lv_process_message'     || lv_process_message
                                            ||', Delivery id -  '        || rec_cur_get_deliveries.delivery_id
                                            ||', Delivery_details_id -> '|| rec_cur_get_deliveries.delivery_detail_id
                                            -- added by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), begin
                                            ||', Order_Line_Id -> '      || rec_cur_get_deliveries.order_line_id
                                            -- added by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), end
                                            ||', Tax_amount -> '         || rec_cur_get_deliveries.func_tax_amount
                                            ||', Tax_id -> '             || rec_cur_get_deliveries.tax_id
                                            ||', Tax_type -> '           || rec_cur_get_deliveries.tax_type
                           );
          p_process_flag    := lv_process_flag    ;
          p_process_message := lv_process_message ;
          return;
        END IF;

        record_debug_messages ('13 Returned from jai_cmn_rgm_recording_pkg.insert_vat_repository_entry and ');

        IF rec_cur_get_deliveries.vat_exemption_flag = 'N' THEN
          record_debug_messages ('13.1 before call to jai_cmn_rgm_recording_pkg.do_vat_accounting');


          record_debug_messages ('14 Processing the delivery,parameters are delivery_id -> '            || rec_cur_get_deliveries.delivery_id
                           ||', source_document_type_id i.e delivery_detail_id -> ' || rec_cur_get_deliveries.delivery_detail_id
                           ||', rec_cur_get_deliveries.tax_type  -> '               || rec_cur_get_deliveries.tax_type
                           ||', p_organization_id -> '                              || p_organization_id
                           ||', p_location_id -> '                                  || p_location_id
                           ||', vat_exemption_flag -> '                             || rec_cur_get_deliveries.vat_exemption_flag
                           ||', pn_assessable_value ->'                             || rec_cur_get_deliveries.vat_assessable_value
                           ||', account_name -> '                                   || jai_constants.liability
                           ||', p_charge_account_id-> '                             || ln_liab_acct_ccid
                           ||', p_balancing_account_id-> '                          || ln_intliab_acct_ccid
                           ||', ln_debit_amount -> '                                || ln_debit_amount
                           ||', ln_credit_amount -> '                               || ln_credit_amount
                           ||', p_amount-> '                                        || rec_cur_get_deliveries.func_tax_amount
                           ||', p_trx_amount-> '                                    || rec_cur_get_deliveries.func_tax_amount
                           ||', p_tax_rate -> '                                     || rec_cur_get_deliveries.tax_rate
                           ||', accounting_date -> '                                || nvl(p_default_invoice_date,rec_cur_get_deliveries.creation_date)
                           ||', p_reference_id  i.e tax_id -> '                     || rec_cur_get_deliveries.tax_id
                           ||', p_inv_organization_id -> '                          || p_organization_id
                           ||', p_attribute1 i.e delivery_id -> '                   || rec_cur_get_deliveries.delivery_id
                           ||', p_attribute2 i.e order_line_id -> '                 || rec_cur_get_deliveries.order_line_id
                           ||', p_attribute_context -> '                            || jai_constants.contxt_delivery
            );


          if jai_pa_billing_pkg.gv_debug then
            jai_cmn_utils_pkg.print_log ( jai_pa_billing_pkg.file, '9 rgm_om_ar_vat_accnt_pkg.process_order_invoice. Before callto jai_cmn_rgm_recording_pkg.do_vat_accounting.');
          end if;

          jai_cmn_rgm_recording_pkg.do_vat_accounting (
              pn_regime_id            =>  p_regime_id                                                       ,
              pn_repository_id        =>  ln_repository_id                                                  ,
              pv_organization_type    =>  jai_constants.orgn_type_io                                        ,
              pn_organization_id      =>  p_organization_id                                                 ,
              /*Check with support whether this should be transaction date or sysdate */
              pd_accounting_date      =>  nvl(p_default_invoice_date,rec_cur_get_deliveries.creation_date)  ,
              pd_transaction_date     =>  rec_cur_get_deliveries.creation_date                              ,
/*   --Date 14/06/2007 by sacsethi for bug 6072461
	      pn_credit_amount        =>  ln_debit_amount                                                   ,
              pn_debit_amount         =>  ln_debit_amount                                                   ,
              pn_credit_ccid          =>  ln_liab_acct_ccid                                                 ,
              pn_debit_ccid           =>  ln_intliab_acct_ccid                                              ,
*/            pn_credit_amount        =>  nvl(ln_debit_amount,ln_credit_amount)                             ,
              pn_debit_amount         =>  nvl(ln_debit_amount,ln_credit_amount)                             ,
              pn_credit_ccid          =>  ln_charge_ac_id                                                   ,
              pn_debit_ccid           =>  ln_balancing_ac_id                                                ,
              pv_called_from          =>  lv_called_from,   /* Bug# 6012570 (5876390) jai_constants.vat_repo_call_from_om_ar                                 , */
              pv_process_flag         =>  lv_process_flag                                                   ,
              pv_process_message      =>  lv_process_message                                                ,
              pv_tax_type             =>  rec_cur_get_deliveries.tax_type                                   ,
              pv_source               =>  p_source                                                          ,
              pv_source_trx_type      =>  lv_source_trx_type,   /* Bug# 6012570 (5876390) jai_constants.source_ttype_delivery                               ,*/
              pv_source_table_name    =>  lv_source_table_name,   /* Bug# 6012570 (5876390) jai_constants.tname_dlry_dtl                                      ,*/
              pn_source_id            =>  ln_source_id,     /* Bug# 6012570 (5876390) rec_cur_get_deliveries.delivery_detail_id                         ,*/
              pv_reference_name       =>  /*jai_constants.JAI_CMN_TAXES_ALL*/'JA_IN_TAX_CODES'                ,
              pn_reference_id         =>  rec_cur_get_deliveries.tax_id
             );

          if jai_pa_billing_pkg.gv_debug then
            jai_cmn_utils_pkg.print_log ( jai_pa_billing_pkg.file, '9 rgm_om_ar_vat_accnt_pkg.process_order_invoice. After callto do_vat_accounting.'
              ||', lv_process_flag:'||lv_process_flag
              ||', lv_process_message:'||lv_process_message
            );
          end if;


          IF lv_process_flag = jai_constants.expected_error    OR
             lv_process_flag = jai_constants.unexpected_error
          THEN
            /*
            || As Returned status is an error hence:-
            ||1. Delivery processing should be terminated,Rollback the insert and exit Loop
            ||2. Set out variables p_process_flag and p_process_message accordingly
            ||3. Return from the procedure
            */
            record_debug_messages(' 15 Error in call to jai_cmn_rgm_recording_pkg.do_vat_accounting - lv_process_flag '||lv_process_flag
                                              ||', lv_process_message'     || lv_process_message
                                              ||', Delivery id -  '        || rec_cur_get_deliveries.delivery_id
                                              ||', Delivery_details_id -> '|| rec_cur_get_deliveries.delivery_detail_id
                                              ||', Tax_amount -> '         || rec_cur_get_deliveries.func_tax_amount
                                              ||', Tax_id -> '             || rec_cur_get_deliveries.tax_id
                                              ||', Tax_type -> '           || rec_cur_get_deliveries.tax_type
                             );
            p_process_flag    := lv_process_flag    ;
            p_process_message := lv_process_message ;
            return;
          END IF;

          record_debug_messages ('16 Returned from jai_cmn_rgm_recording_pkg.do_vat_accounting');
        END IF; /* End IF of Vat Exemption Flag*/

    END LOOP;

 /*added by rchandan for bug#6030615*/
	 ELSIF p_source='INTERORG_XFER' THEN
	 --jai_constants.source_intxfer
				 /*
		 || Process Interorg Transfers - INV side processing
		 */
		 ln_rgm_cnt := 0;
		 FOR  rec_cur_get_mtl_txns IN cur_get_mtltxns
		 LOOP
		  open c_chk_rgm_trxs(rec_cur_get_mtl_txns.transaction_header_id,rec_cur_get_mtl_txns.transaction_temp_id,rec_cur_get_mtl_txns.tax_id);
		  fetch c_chk_rgm_trxs into ln_rgm_cnt;
	          close c_chk_rgm_trxs;

	          if nvl(ln_rgm_cnt,0) = 0 then
			 record_debug_messages (' ************7 PROCESSING Delivery id -> '|| p_delivery_id||'Delivery Details ID -> '||rec_cur_get_mtl_txns.transaction_temp_id||' ************' );
			 /*******************************
			 ||Variable Initialization
			 *******************************/
			 ln_liab_acct_ccid    := null;
			 ln_intliab_acct_ccid := null;
			 ln_credit_amount     := null;
			 ln_debit_amount      := null;
			 ln_recov_acct_ccid   := null;
			 ln_expense_acct_ccid := null;
			 ln_charge_ac_id      := null;
			 ln_balancing_ac_id:= null;
			 lc_account_name      := null;
			 record_debug_messages ('8 Variables Initialised');
			 IF ( rec_cur_get_mtl_txns.tax_type = 'VAT REVERSAL' ) THEN
				 /*******************************
				 ||Get the code combination id
				 ||for the "RECOVERY ACCOUNT"
				 *******************************/
				 ln_recov_acct_ccid   :=    jai_cmn_rgm_recording_pkg.get_account(
																																					 p_regime_id         => p_regime_id                        ,
																																					 p_organization_type => jai_constants.orgn_type_io         ,
																																					 p_organization_id   => p_organization_id                  ,
																																					 p_location_id       => p_location_id                      ,
																																					 p_tax_type          => rec_cur_get_mtl_txns.tax_type    ,
																																					 p_account_name      => jai_constants.recovery
																																				 ) ;
				 /*******************************
				 || Get the code combination id
				 || for the "EXPENSE ACCOUNT"
				 *******************************/
				 ln_expense_acct_ccid :=    jai_cmn_rgm_recording_pkg.get_account(
																																					 p_regime_id         => p_regime_id                        ,
																																					 p_organization_type => jai_constants.orgn_type_io         ,
																																					 p_organization_id   => p_organization_id                  ,
																																					 p_location_id       => p_location_id                      ,
																																					 p_tax_type          => rec_cur_get_mtl_txns.tax_type    ,
																																					 p_account_name      => jai_constants.expense
																																				 ) ;
				 lc_account_name       := jai_constants.recovery;
				 ln_charge_ac_id       := ln_recov_acct_ccid;
				 ln_balancing_ac_id    := ln_expense_acct_ccid;
				 ln_debit_amount      := rec_cur_get_mtl_txns.tax_amt; /* Modified ln_credit_amount to ln_debit_amount for bug 8657720 by vumaasha */

				 IF  ln_charge_ac_id  IS NULL OR
						 ln_balancing_ac_id IS NULL
				 THEN
					 record_debug_messages('9 VAT delivery accounting entries cannot be passed. Please set up the Recovery account and the Expense account for VAT Reversal');
					 p_process_flag    := jai_constants.expected_error;
					 p_process_message := 'VAT delivery accounting entries cannot be passed. Please set up the Recovery account and the Expense account for VAT reversal';
					 return;
				 END IF;
			 ELSE
				 /*******************************
				 ||Get the code combination id
				 ||for the "LIABILITY ACCOUNT"
				 *******************************/
				 ln_liab_acct_ccid    :=    jai_cmn_rgm_recording_pkg.get_account(
																																					 p_regime_id         => p_regime_id                        ,
																																					 p_organization_type => jai_constants.orgn_type_io         ,
																																					 p_organization_id   => p_organization_id                  ,
																																					 p_location_id       => p_location_id                      ,
																																					 p_tax_type          => rec_cur_get_mtl_txns.tax_type    ,
																																					 p_account_name      => jai_constants.liability
																																				 ) ;
				 /*******************************
				 || Get the code combination id
				 || for the "INTERIM LIABILITY ACCOUNT"
				 *******************************/
				 ln_intliab_acct_ccid :=    jai_cmn_rgm_recording_pkg.get_account(
																																					 p_regime_id         => p_regime_id                        ,
																																					 p_organization_type => jai_constants.orgn_type_io         ,
																																					 p_organization_id   => p_organization_id                  ,
																																					 p_location_id       => p_location_id                      ,
																																					 p_tax_type          => rec_cur_get_mtl_txns.tax_type    ,
																																					 p_account_name      => jai_constants.liability_interim
																																				 ) ;
				 lc_account_name       := jai_constants.liability;
				 ln_charge_ac_id       := ln_liab_acct_ccid;
				 ln_balancing_ac_id    := ln_intliab_acct_ccid;
				 ln_debit_amount       := rec_cur_get_mtl_txns.tax_amt;
				 IF  ln_charge_ac_id    IS NULL OR
						 ln_balancing_ac_id IS NULL
				 THEN
					 record_debug_messages('9 VAT delivery accounting entries cannot be passed. Please set up the Liability account and the Interim Liability account for the corresponding VAT regime');
					 p_process_flag    := jai_constants.expected_error;
					 p_process_message := 'VAT delivery accounting entries cannot be passed. Please set up the Liability account and the Interim Liability account for the corresponding VAT regime';
					 return;
				 END IF;
			 END IF;
			 record_debug_messages ('10 Processing the delivery, parameters are delivery_id -> '           || rec_cur_get_mtl_txns.transaction_header_id
																						||', source_document_type_id i.e delivery_detail_id -> ' || rec_cur_get_mtl_txns.transaction_temp_id
																						||', rec_cur_get_deliveries.tax_type  -> '               || rec_cur_get_mtl_txns.tax_type
																						||', p_organization_id -> '                              || p_organization_id
																						||', p_location_id -> '                                  || p_location_id
																						||', vat_exemption_flag -> '                             || null
																						||', pn_assessable_value ->'                             || rec_cur_get_mtl_txns.vat_assessable_value
																						||', account_name -> '                                   || lc_account_name
																						||', p_charge_account_id-> '                             || ln_charge_ac_id
																						||', p_balancing_account_id-> '                          || ln_balancing_ac_id
																						||',ln_debit_amount -> '                                 || ln_debit_amount
																						||',ln_credit_amount -> '                                || ln_credit_amount
																						||', p_amount-> '                                        || rec_cur_get_mtl_txns.tax_amt
																						||', p_trx_amount-> '                                    || rec_cur_get_mtl_txns.tax_amt
																						||', p_tax_rate -> '                                     || rec_cur_get_mtl_txns.tax_rate
																						||', p_reference_id  i.e tax_id -> '                     || rec_cur_get_mtl_txns.tax_id
																						||', p_inv_organization_id -> '                          || p_organization_id
																						||', p_attribute1 i.e delivery_id -> '                   || rec_cur_get_mtl_txns.transaction_header_id
																						||', p_attribute2 i.e order_line_id -> '                 || null
																						||', p_attribute_context -> '                            || jai_constants.contxt_delivery
														 );
			 record_debug_messages ('11 Before call to jai_cmn_rgm_recording_pkg.insert_repository_entry');
				jai_cmn_rgm_recording_pkg.insert_vat_repository_entry (
																																		 pn_repository_id            => ln_repository_id                                                   ,
																																		 pn_regime_id                => p_regime_id                                                        ,
																																		 pv_tax_type                 => rec_cur_get_mtl_txns.tax_type                                    ,
																																		 pv_organization_type        => jai_constants.orgn_type_io                                         ,
																																		 pn_organization_id          => p_organization_id                                                  ,
																																		 pn_location_id              => p_location_id                                                      ,
																																		 pv_source                   => p_source                                                           ,
																																		 pv_source_trx_type          => jai_constants.source_ttype_delivery                                ,
																																		 pv_source_table_name        => jai_constants.tname_dlry_dtl                                       ,
																																		 pn_source_id                => rec_cur_get_mtl_txns.transaction_temp_id                         ,
																																		 pd_transaction_date         => rec_cur_get_mtl_txns.creation_date                               ,
																																		 pv_account_name             => lc_account_name                                                    ,
																																		 pn_charge_account_id        => ln_charge_ac_id                                                    ,
																																		 pn_balancing_account_id     => ln_balancing_ac_id                                                 ,
																																		 pn_credit_amount            => LN_CREDIT_AMOUNT                                                   ,
																																		 pn_debit_amount             => ln_debit_amount                                                    ,
																																		 pn_assessable_value         => rec_cur_get_mtl_txns.vat_assessable_value                        ,
																																		 pn_tax_rate                 => rec_cur_get_mtl_txns.tax_rate                                    ,
																																		 pn_reference_id             => rec_cur_get_mtl_txns.tax_id                                      ,
																																		 pn_batch_id                 => p_batch_id                                                         ,
																																		 pn_inv_organization_id      => p_organization_id                                                  ,
																																		 pv_invoice_no               => p_vat_invoice_no                                                   ,
																																		 pd_invoice_date             => nvl(p_default_invoice_date,rec_cur_get_mtl_txns.creation_date)   ,
																																		 pv_called_from              => jai_constants.vat_repo_call_from_om_ar                                  ,
																																		 pv_process_flag             => lv_process_flag                                                    ,
																																		 pv_process_message          => lv_process_message                                                 ,
																																		 --Modified by Bo Li for replacing old attribtue columns with new ones Begin
                                                                     -----------------------------------------------------------------------------------------------------------------
																																		 pv_trx_reference_context        => jai_constants.contxt_delivery                                      ,
																																		 pv_trx_reference1               => rec_cur_get_mtl_txns.transaction_header_id                                ,
																																		 pv_trx_reference2               => NULL                              ,
																																		 pv_trx_reference3               => NULL                                                               ,
																																		 pv_trx_reference4               => NULL                                                               ,
																																		 pv_trx_reference5               => NULL
                                                                     -----------------------------------------------------------------------------------------------------------------
                                                                     --Modified by Bo Li for replacing old attribtue columns with new ones End
																															 );
				 IF lv_process_flag = jai_constants.expected_error    OR
						lv_process_flag = jai_constants.unexpected_error
				 THEN
					 /*
					 || As Returned status is an error hence:-
					 ||1. Delivery processing should be terminated,Rollback the insert and exit Loop
					 ||2. Set out variables p_process_flag and p_process_message accordingly
					 ||3. Return from the procedure
					 */
					 record_debug_messages(' 12 Error in call to jai_cmn_rgm_recording_pkg.insert_vat_repository_entry - lv_process_flag '||lv_process_flag
																						 ||', lv_process_message'     || lv_process_message
																						 ||', Delivery id -  '        ||rec_cur_get_mtl_txns.transaction_header_id
																						 ||', Delivery_details_id -> '|| rec_cur_get_mtl_txns.transaction_temp_id
																						 ||', Tax_amount -> '         || rec_cur_get_mtl_txns.tax_amt
																						 ||', Tax_id -> '             || rec_cur_get_mtl_txns.tax_id
																						 ||', Tax_type -> '           || rec_cur_get_mtl_txns.tax_type
														);
					 p_process_flag    := lv_process_flag    ;
					 p_process_message := lv_process_message ;
					 return;
				 END IF;
				 record_debug_messages ('13 Returned from jai_cmn_rgm_recording_pkg.insert_vat_repository_entry and ');
					 record_debug_messages ('13.1 before call to jai_cmn_rgm_recording_pkg.do_vat_accounting');
					 record_debug_messages ('14 Processing the delivery,parameters are delivery_id -> '            || rec_cur_get_mtl_txns.transaction_header_id
																								||', source_document_type_id i.e delivery_detail_id -> ' || rec_cur_get_mtl_txns.transaction_temp_id
																								||', rec_cur_get_deliveries.tax_type  -> '               || rec_cur_get_mtl_txns.tax_type
																								||', p_organization_id -> '                              || p_organization_id
																								||', p_location_id -> '                                  || p_location_id
																								||', vat_exemption_flag -> '                             || 'N'
																								||', account_name -> '                                   || lc_account_name
																								||', p_charge_account_id-> '                             || ln_charge_ac_id
																								||', p_balancing_account_id-> '                          || ln_balancing_ac_id
																								||', ln_debit_amount -> '                                || ln_debit_amount
																								||', ln_credit_amount -> '                               || ln_credit_amount
																								||', p_amount-> '                                        || rec_cur_get_mtl_txns.tax_amt
																								||', p_trx_amount-> '                                    || rec_cur_get_mtl_txns.tax_amt
																								||', p_tax_rate -> '                                     || rec_cur_get_mtl_txns.tax_rate
																								||', p_reference_id  i.e tax_id -> '                     || rec_cur_get_mtl_txns.tax_id
																								||', p_inv_organization_id -> '                          || p_organization_id
																								||', p_attribute1 i.e delivery_id -> '                   || rec_cur_get_mtl_txns.transaction_header_id
																								||', p_attribute2 i.e order_line_id -> '                 || null
																								||', p_attribute_context -> '                            || jai_constants.contxt_delivery
																 );
																 /*commented by vasavi*/
																 /*
					 jai_cmn_rgm_recording_pkg.do_vat_accounting (
																													 pn_regime_id            =>  p_regime_id                                                       ,
																													 pn_repository_id        =>  ln_repository_id                                                  ,
																													 pv_organization_type    =>  jai_constants.orgn_type_io                                        ,
																													 pn_organization_id      =>  p_organization_id                                                 ,
																													 pd_accounting_date      =>  nvl(p_default_invoice_date,rec_cur_get_mtl_txns.creation_date)  ,
																													 pd_transaction_date     =>  rec_cur_get_mtl_txns.creation_date                              ,
																													 pn_credit_amount        =>  nvl(ln_debit_amount,ln_credit_amount)                             ,
																													 pn_debit_amount         =>  nvl(ln_debit_amount,ln_credit_amount)                             ,
																													 pn_credit_ccid          =>  ln_charge_ac_id                                                   ,
																													 pn_debit_ccid           =>  ln_balancing_ac_id                                                ,
																													 pv_called_from          =>  jai_constants.vat_repo_call_from_om_ar                                 ,
																													 pv_process_flag         =>  lv_process_flag                                                   ,
																													 pv_process_message      =>  lv_process_message                                                ,
																													 pv_tax_type             =>  rec_cur_get_mtl_txns.tax_type                                   ,
																													 pv_source               =>  p_source                                                          ,
																													 pv_source_trx_type      =>  jai_constants.source_ttype_delivery                               ,
																													 pv_source_table_name    =>  jai_constants.tname_dlry_dtl                                      ,
																													 pn_source_id            =>  rec_cur_get_mtl_txns.transaction_temp_id                         ,
																													 pv_reference_name       =>  'JA_IN_TAX_CODES'                ,
																													 pn_reference_id         =>  rec_cur_get_mtl_txns.tax_id
																													);
					 IF lv_process_flag = jai_constants.expected_error    OR
							lv_process_flag = jai_constants.unexpected_error
					 THEN
						 record_debug_messages(' 15 Error in call to jai_cmn_rgm_recording_pkg.do_vat_accounting - lv_process_flag '||lv_process_flag
																							 ||', lv_process_message'     || lv_process_message
																							 ||', Delivery id -  '        || rec_cur_get_mtl_txns.transaction_header_id
																							 ||', Delivery_details_id -> '|| rec_cur_get_mtl_txns.transaction_temp_id
																							 ||', Tax_amount -> '         || rec_cur_get_mtl_txns.tax_amt
																							 ||', Tax_id -> '             || rec_cur_get_mtl_txns.tax_id
																							 ||', Tax_type -> '           || rec_cur_get_mtl_txns.tax_type
															);
						 p_process_flag    := lv_process_flag    ;
						 p_process_message := lv_process_message ;
						 return;
					 END IF;
					 record_debug_messages ('16 Returned from jai_cmn_rgm_recording_pkg.do_vat_accounting');
				 --END IF;
				 */
          end if;---ln_rgm_cnt if
	 END LOOP;

  ELSIF upper(p_source) = upper(jai_constants.source_ar) THEN

      record_debug_messages ('17 Manual AR processing for customer_trx_id -> '||p_customer_trx_id);
    /*
    || Process Invoices - AR side processing
    */
    /*  Bug 5739005. Added by vkantamn
     * Included parameters for the cursor.
     */
    FOR rec_cur_get_man_ar_inv_taxes IN cur_get_man_ar_inv_taxes(upper(p_source),jai_constants.source_ttype_man_ar_inv,jai_constants.tname_cus_trx_lines)
    LOOP
      record_debug_messages (' ************18 PROCESSING customer_trx_id -> '|| p_customer_trx_id
        ||'link_to_cust_trx_line_id -> '||rec_cur_get_man_ar_inv_taxes.link_to_cust_trx_line_id
        ||'customer_trx_line_id ->'||rec_cur_get_man_ar_inv_taxes.customer_trx_line_id
        ||' ************' );

      /*******************************
      ||Variable Initialization
      *******************************/
      ln_liab_acct_ccid    := null;
      ln_intliab_acct_ccid := null;
      ln_charge_ac_id      := null;
      ln_balancing_ac_id   := null;

      /* Start - sacsethi, Added w.r.t BUG#6072461 ( for VAT Reversal)*/
      ln_credit_amount     := null;
      ln_debit_amount      := null;
      ln_recov_acct_ccid   := null;
      ln_expense_acct_ccid := null;
      lc_account_name      := null;
      /* End -  sacsethi, Added w.r.t BUG#6072461 ( for VAT Reversal)*/

      record_debug_messages ('19 Variables Initialised');

      IF ( rec_cur_get_man_ar_inv_taxes.tax_type = 'VAT REVERSAL' ) THEN
        /* Start - sacsethi, Added w.r.t BUG#6072461 ( for VAT Reversal)*/
        /*******************************
        ||Get the code combination id
        ||for the "RECOVERY ACCOUNT"
        *******************************/
        ln_recov_acct_ccid   :=    jai_cmn_rgm_recording_pkg.get_account(
                                                                          p_regime_id         => p_regime_id                        ,
                                                                          p_organization_type => jai_constants.orgn_type_io         ,
                                                                          p_organization_id   => p_organization_id                  ,
                                                                          p_location_id       => p_location_id                      ,
                                                                          p_tax_type          => rec_cur_get_man_ar_inv_taxes.tax_type,
                                                                          p_account_name      => jai_constants.recovery
                                                                        ) ;

        /*******************************
        || Get the code combination id
        || for the "EXPENSE ACCOUNT"
        *******************************/
        ln_expense_acct_ccid :=    jai_cmn_rgm_recording_pkg.get_account(
                                                                          p_regime_id         => p_regime_id                        ,
                                                                          p_organization_type => jai_constants.orgn_type_io         ,
                                                                          p_organization_id   => p_organization_id                  ,
                                                                          p_location_id       => p_location_id                      ,
                                                                          p_tax_type          => rec_cur_get_man_ar_inv_taxes.tax_type,
                                                                          p_account_name      => jai_constants.expense
                                                                        ) ;
        IF  ln_recov_acct_ccid   IS NULL OR
            ln_expense_acct_ccid IS NULL
        THEN
          record_debug_messages('20 VAT receivables accouting entries cannot be passed. Please set up the Recovery account and the Expense account for VAT Reversal');
          p_process_flag    := jai_constants.expected_error;
          p_process_message := 'VAT receivables accouting entries cannot be passed. Please set up the Recovery account and the Expense account for VAT Reversal';
          return;
        END IF;
        /* End - sacsethi, Added w.r.t BUG#6072461 ( for VAT Reversal)*/
       ELSE

      /*******************************
      ||Get the code combination id
      ||for the "LIABILITY ACCOUNT"
      *******************************/
      ln_liab_acct_ccid    :=    jai_cmn_rgm_recording_pkg.get_account(
                                                                          p_regime_id         => p_regime_id                                ,
                                                                          p_organization_type => jai_constants.orgn_type_io                 ,
                                                                          p_organization_id   => p_organization_id                          ,
                                                                          p_location_id       => p_location_id                              ,
                                                                          p_tax_type          => rec_cur_get_man_ar_inv_taxes.tax_type      ,
                                                                          p_account_name      => jai_constants.liability
                                                                      ) ;

      /*******************************
      || Get the code combination id
      || for the "INTERIM LIABILITY ACCOUNT"
      *******************************/
      ln_intliab_acct_ccid :=    jai_cmn_rgm_recording_pkg.get_account(
                                                                          p_regime_id         => p_regime_id                                ,
                                                                          p_organization_type => jai_constants.orgn_type_io                 ,
                                                                          p_organization_id   => p_organization_id                          ,
                                                                          p_location_id       => p_location_id                              ,
                                                                          p_tax_type          => rec_cur_get_man_ar_inv_taxes.tax_type      ,
                                                                          p_account_name      => jai_constants.liability_interim
                                                                      ) ;


      /*
      || Validate that if any one of the liability account or interim liability account is not defined then error our
      */
      IF ln_liab_acct_ccid    IS NULL OR
         ln_intliab_acct_ccid IS NULL
      THEN
        record_debug_messages('20 VAT receivable accouting entries cannot be passed. Please set up the Liability account and the Interim Liability account for the corresponding VAT regime');
        p_process_flag    := jai_constants.expected_error;
        p_process_message := 'VAT receivable accouting entries cannot be passed. Please set up the Liability account and the Interim Liability account for the corresponding VAT regime';
        return;
      END IF;
     END IF;

      /*********************************************************************************************************************************
      || Population of Credit and debit amounts and CCID in case Invoice and Credit Memo
      +=============================================================================================================================+
      ||                 ||||<---------------VAT REPOSITORY ENTRY--------------->||||<-------------GL INTERFACE---------------->
      ||================ ||||====================================================||||==================================================
      ||Transaction Type ||||CHARGE A/C     ||  BALANCING A/C  ||   CR  ||   DR  ||||Slno || Account ID    || CR    ||   DR  ||
      ||================ ||||============   ||=================||=======||=======||||=====||===============||=======||=======||
      ||  Invoice/       ||||  Liab A/C     ||  Int Liab A/C   ||   0   ||  100  ||||1.   || Liab A/C      || 100   ||   0   ||
      ||  Debit Memo     ||||               ||                 ||       ||       ||||2.   || Int Liab A/C  ||   0   || 100   ||
      ||                 ||||               ||                 ||       ||       ||||     ||               ||       ||       ||
      ||=================||||===============||=================||=======||=======||||=====||===============||=======||=======||
      ||                 ||||               ||                 ||       ||       ||||     ||               ||       ||       ||
      ||  Credit Memo    |||| Int Liab A/C  ||  Liab A/C       || 100   ||    0  ||||1.   ||  Int Liab A/C ||  100  ||   0   ||
      ||                 ||||               ||                 ||       ||       ||||2.   ||  Liab A/C     ||  0    || 100   ||
      +==============================================================================================================================+

      *********************************************************************************************************************************/


       IF p_transaction_type IN ('INV','DM') THEN
           /* Start - sacsethi, Added w.r.t 6072461 ( for VAT Reversal)*/
          IF ( rec_cur_get_man_ar_inv_taxes.tax_type = 'VAT REVERSAL' ) THEN
            lc_account_name         :=    jai_constants.recovery                                ;
            ln_charge_ac_id         :=    ln_recov_acct_ccid                                    ;
            ln_balancing_ac_id      :=    ln_expense_acct_ccid                                  ;
            ln_credit_amount         :=    null                                                 ;
            ln_debit_amount        :=    abs(rec_cur_get_man_ar_inv_taxes.func_tax_amount)     ; /* modified for bug 8657720 by vumaasha */

          ELSE
            lc_account_name         :=    jai_constants.liability                               ;
          /* End - sacsethi, Added w.r.t 6072461 ( for VAT Reversal)*/
            ln_charge_ac_id         :=    ln_liab_acct_ccid                                     ;
            ln_balancing_ac_id      :=    ln_intliab_acct_ccid                                  ;
            ln_debit_amount         :=    abs(rec_cur_get_man_ar_inv_taxes.func_tax_amount)     ;
            ln_credit_amount        :=    null                                                  ;
          END IF;

       ELSIF p_transaction_type = 'CM' THEN
        lc_account_name         :=    jai_constants.recovery                                ; -- Added By Bo Li for Bug#9766552 on 2010-06-09
        ln_charge_ac_id         :=    ln_intliab_acct_ccid                                  ;
        ln_balancing_ac_id      :=    ln_liab_acct_ccid                                     ;
        ln_debit_amount         :=    null                                                  ;
        ln_credit_amount        :=    abs(rec_cur_get_man_ar_inv_taxes.func_tax_amount)     ;
       END IF;



      record_debug_messages ('21 Processing the manual_ar_invoice , Parameters passed are for the customer_trx_id  -> ' || p_customer_trx_id
                                           ||', line.customer_trx_line_id  -> '                         || rec_cur_get_man_ar_inv_taxes.link_to_cust_trx_line_id
                                           ||', source_document_type_id tax.customer_trx_line_id -> '   || rec_cur_get_man_ar_inv_taxes.customer_trx_line_id
                                           ||', rec_cur_get_man_ar_inv_taxes.tax_type  -> '             || rec_cur_get_man_ar_inv_taxes.tax_type
                                           ||', p_organization_id -> '                                  || p_organization_id
                                           ||', p_location_id -> '                                      || p_location_id
                                           ||', vat_exemption_flag -> '                                 || rec_cur_get_man_ar_inv_taxes.vat_exemption_flag
                                           ||', pn_assessable_value ->'                                 || rec_cur_get_man_ar_inv_taxes.vat_assessable_value
                                           ||', account_name -> '                                       || jai_constants.liability
                                           ||', p_charge_account_id-> '                                 || ln_charge_ac_id
                                           ||', p_balancing_account_id-> '                              || ln_balancing_ac_id
                                           ||', ln_debit_amount -> '                                    || ln_debit_amount
                                           ||', ln_credit_amount -> '                                   || ln_credit_amount
                                           ||', p_amount-> '                                            || rec_cur_get_man_ar_inv_taxes.func_tax_amount
                                           ||', p_trx_amount-> '                                        || rec_cur_get_man_ar_inv_taxes.func_tax_amount
                                           ||', p_tax_rate -> '                                         || rec_cur_get_man_ar_inv_taxes.tax_rate
                                           ||', p_reference_id  i.e tax_id -> '                         || rec_cur_get_man_ar_inv_taxes.tax_id
                                           ||', p_inv_organization_id -> '                              || p_organization_id
                                           ||', p_attribute1 i.e customer_trx_id -> '                   || rec_cur_get_man_ar_inv_taxes.customer_trx_id
                                           ||', p_attribute2 i.e link_to_cust_trx_line_id -> '          || rec_cur_get_man_ar_inv_taxes.link_to_cust_trx_line_id
                                           ||', p_attribute_context -> '                                || jai_constants.contxt_manual_ar
                            );


      record_debug_messages ('22 Before call to jai_cmn_rgm_recording_pkg.insert_vat_repository_entry');


      jai_cmn_rgm_recording_pkg.insert_vat_repository_entry (
                                                               pn_repository_id            =>  ln_repository_id                                                         ,
                                                               pn_regime_id                =>  p_regime_id                                                              ,
                                                               pv_tax_type                 =>  rec_cur_get_man_ar_inv_taxes.tax_type                                    ,
                                                               pv_organization_type        =>  jai_constants.orgn_type_io                                               ,
                                                               pn_organization_id          =>  p_organization_id                                                        ,
                                                               pn_location_id              =>  p_location_id                                                            ,
                                                               pv_source                   =>  p_source                                                                 ,
                                                               pv_source_trx_type          =>  jai_constants.source_ttype_man_ar_inv                                    ,
                                                               pv_source_table_name        =>  jai_constants.tname_cus_trx_lines                                        ,
                                                               pn_source_id                =>  rec_cur_get_man_ar_inv_taxes.customer_trx_line_id                        ,
                                                               pd_transaction_date         =>  rec_cur_get_man_ar_inv_taxes.creation_date                               ,
                                                               pv_account_name             =>  lc_account_name                                                          ,  --Date 14/06/2007 by sacsethi for bug 6072461
                                                               pn_charge_account_id        =>  ln_charge_ac_id                                                          ,
                                                               pn_balancing_account_id     =>  ln_balancing_ac_id                                                       ,
                                                               pn_credit_amount            =>  ln_credit_amount                                                         ,
                                                               pn_debit_amount             =>  ln_debit_amount                                                          ,
                                                               pn_assessable_value         =>  rec_cur_get_man_ar_inv_taxes.vat_assessable_value                        ,
                                                               pn_tax_rate                 =>  rec_cur_get_man_ar_inv_taxes.tax_rate                                    ,
                                                               pn_reference_id             =>  rec_cur_get_man_ar_inv_taxes.tax_id                                      ,
                                                               pn_batch_id                 =>  p_batch_id                                                               ,
                                                               pn_inv_organization_id      =>  p_organization_id                                                        ,
                                                               pv_invoice_no               =>  p_vat_invoice_no                                                         ,
                                                               pd_invoice_date             =>  nvl(p_default_invoice_date,rec_cur_get_man_ar_inv_taxes.creation_date)   ,
                                                               pv_called_from              =>  jai_constants.vat_repo_call_from_om_ar                                   ,
                                                               pv_process_flag             =>  lv_process_flag                                                          ,
                                                               pv_process_message          =>  lv_process_message                                                       ,
                                                               --Modified by Bo Li for replacing old attribtue columns with new ones Begin
                                                               -----------------------------------------------------------------------------------------------------------------
                                                               pv_trx_reference_context        =>  jai_constants.contxt_manual_ar                                           ,
                                                               pv_trx_reference1               =>  rec_cur_get_man_ar_inv_taxes.customer_trx_id                             ,
                                                               pv_trx_reference2               =>  rec_cur_get_man_ar_inv_taxes.link_to_cust_trx_line_id                    ,
                                                               pv_trx_reference3               =>  NULL                                                                     ,
                                                               pv_trx_reference4               =>  NULL                                                                     ,
                                                               pv_trx_reference5               =>  NULL
                                                               -----------------------------------------------------------------------------------------------------------------
                                                               --Modified by Bo Li for replacing old attribtue columns with new ones End
                                                           );



      IF lv_process_flag = jai_constants.expected_error    OR
         lv_process_flag = jai_constants.unexpected_error
      THEN
        /*
        || As Returned status is an error hence:-
        ||1. Delivery processing should be terminated,Rollback the insert and exit Loop
        ||2. Set out variables p_process_flag and p_process_message accordingly
        ||3. Return from the procedure
        */
        record_debug_messages(' 23 Error in call to jai_cmn_rgm_recording_pkg.insert_vat_repository_entry - lv_process_flag '||lv_process_flag
                                          ||', lv_process_message'            || lv_process_message
                                          ||', customer_trx_id -  '           || p_customer_trx_id
                                          ||', customer_trx_line_id -> '      || rec_cur_get_man_ar_inv_taxes.customer_trx_line_id
                                          ||', link_to_cust_trx_line_id -> '  || rec_cur_get_man_ar_inv_taxes.link_to_cust_trx_line_id
                                          ||', Tax_amount -> '                || rec_cur_get_man_ar_inv_taxes.func_tax_amount
                                          ||', Tax_id -> '                    || rec_cur_get_man_ar_inv_taxes.tax_id
                                          ||', Tax_type -> '                  || rec_cur_get_man_ar_inv_taxes.tax_type
                         );
        p_process_flag    := lv_process_flag    ;
        p_process_message := lv_process_message ;
        return;
      END IF;

      record_debug_messages (' 24 Returned from jai_cmn_rgm_recording_pkg.insert_vat_repository_entry');
      IF rec_cur_get_man_ar_inv_taxes.vat_exemption_flag = 'N' THEN

        record_debug_messages ('25 Parameters passed to  jai_cmn_rgm_recording_pkg.do_vat_accounting, customer_trx_id  -> '            || p_customer_trx_id
                                             ||', line.customer_trx_line_id  -> '                         || rec_cur_get_man_ar_inv_taxes.link_to_cust_trx_line_id
                                             ||', source_document_type_id tax.customer_trx_line_id -> '   || rec_cur_get_man_ar_inv_taxes.customer_trx_line_id
                                             ||', rec_cur_get_man_ar_inv_taxes.tax_type  -> '             || rec_cur_get_man_ar_inv_taxes.tax_type
                                             ||', p_organization_id -> '                                  || p_organization_id
                                             ||', p_location_id -> '                                      || p_location_id
                                             ||', vat_exemption_flag -> '                                 || rec_cur_get_man_ar_inv_taxes.vat_exemption_flag
                                             ||', pn_assessable_value ->'                                 || rec_cur_get_man_ar_inv_taxes.vat_assessable_value
                                             ||', account_name -> '                                       || jai_constants.liability
                                             ||', pn_credit_ccid-> '                                      || ln_charge_ac_id
                                             ||', pn_debit_ccid         -> '                              || ln_balancing_ac_id
                                             ||', ln_debit_amount -> '                                    || ln_debit_amount
                                             ||', ln_credit_amount -> '                                   || ln_credit_amount
                                             ||', p_amount-> '                                            || rec_cur_get_man_ar_inv_taxes.func_tax_amount
                                             ||', p_trx_amount-> '                                        || rec_cur_get_man_ar_inv_taxes.func_tax_amount
                                             ||', p_tax_rate -> '                                         || rec_cur_get_man_ar_inv_taxes.tax_rate
                                             ||', p_reference_id  i.e tax_id -> '                         || rec_cur_get_man_ar_inv_taxes.tax_id
                                             ||', p_inv_organization_id -> '                              || p_organization_id
                                             ||', p_attribute1 i.e customer_trx_id -> '                   || rec_cur_get_man_ar_inv_taxes.customer_trx_id
                                             ||', p_attribute2 i.e link_to_cust_trx_line_id -> '          || rec_cur_get_man_ar_inv_taxes.link_to_cust_trx_line_id
                                             ||', p_attribute_context -> '                                || jai_constants.contxt_manual_ar
                              );



        jai_cmn_rgm_recording_pkg.do_vat_accounting (
          pn_regime_id            =>  p_regime_id                                                               ,
          pn_repository_id        =>  ln_repository_id                                                          ,
          pv_organization_type    =>  jai_constants.orgn_type_io                                                ,
          pn_organization_id      =>  p_organization_id                                                         ,
          /*Check with support whether this should be transaction date or sysdate */
          pd_accounting_date      =>  nvl(p_default_invoice_date,rec_cur_get_man_ar_inv_taxes.creation_date)    ,
          pd_transaction_date     =>  rec_cur_get_man_ar_inv_taxes.creation_date                                ,
          pn_credit_amount        =>  nvl(ln_credit_amount,ln_debit_amount)                                     ,
          pn_debit_amount         =>  nvl(ln_debit_amount,ln_credit_amount)                                     ,
          pn_credit_ccid          =>  ln_charge_ac_id                                                           ,
          pn_debit_ccid           =>  ln_balancing_ac_id                                                        ,
          pv_called_from          =>  jai_constants.vat_repo_call_from_om_ar                                    ,
          pv_process_flag         =>  lv_process_flag                                                           ,
          pv_process_message      =>  lv_process_message                                                        ,
          pv_tax_type             =>  rec_cur_get_man_ar_inv_taxes.tax_type                                     ,
          pv_source               =>  p_source                                                                  ,
          pv_source_trx_type      =>  jai_constants.source_ttype_man_ar_inv                                     ,
          pv_source_table_name    =>  jai_constants.tname_cus_trx_lines                                         ,
          pn_source_id            =>  rec_cur_get_man_ar_inv_taxes.customer_trx_line_id                         ,
          pv_reference_name       =>  /*jai_constants.JAI_CMN_TAXES_ALL*/ 'JA_IN_TAX_CODES'                       ,
          pn_reference_id         =>  rec_cur_get_man_ar_inv_taxes.tax_id
         );

        IF lv_process_flag = jai_constants.expected_error    OR
           lv_process_flag = jai_constants.unexpected_error
        THEN
          /*
          || As Returned status is an error hence:-
          ||1. Delivery processing should be terminated,Rollback the insert and exit Loop
          ||2. Set out variables p_process_flag and p_process_message accordingly
          ||3. Return from the procedure
          */
        record_debug_messages(' 26 Error in call to jai_cmn_rgm_recording_pkg.do_vat_accounting - lv_process_flag '||lv_process_flag
                                          ||', lv_process_message'            || lv_process_message
                                          ||', customer_trx_id -  '           || p_customer_trx_id
                                          ||', customer_trx_line_id -> '      || rec_cur_get_man_ar_inv_taxes.customer_trx_line_id
                                          ||', link_to_cust_trx_line_id -> '  || rec_cur_get_man_ar_inv_taxes.link_to_cust_trx_line_id
                                          ||', Tax_amount -> '                || rec_cur_get_man_ar_inv_taxes.func_tax_amount
                                          ||', Tax_id -> '                    || rec_cur_get_man_ar_inv_taxes.tax_id
                                          ||', Tax_type -> '                  || rec_cur_get_man_ar_inv_taxes.tax_type
                         );
          p_process_flag    := lv_process_flag    ;
          p_process_message := lv_process_message ;
          return;
        END IF;

        record_debug_messages ('27 Returned from jai_cmn_rgm_recording_pkg.do_vat_accounting');
        END IF; /* ENd if OF VAT Exemption = 'N'*/

    END LOOP;

  END IF;

  record_debug_messages ('28 ********************************END OF PROCESS_ORDER_INVOICE********************************');

EXCEPTION
  WHEN OTHERS THEN
    record_debug_messages (' 29 In Exception Section - SQLERRM ->'||substr(sqlerrm,1,300) );
    p_process_flag        := jai_constants.unexpected_error ;
    p_process_message     := 'Unexpeced error occured in procedure process_order_invoice for document_id -> '||
    -- modified by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), begin
    -- nvl(p_delivery_id,p_customer_trx_id)
    nvl(p_delivery_id, NVL(p_order_line_id, p_customer_trx_id))
    -- modified by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), begin
    ||substr(SQLERRM,1,300);

END process_order_invoice;

END jai_cmn_rgm_vat_accnt_pkg;

/
