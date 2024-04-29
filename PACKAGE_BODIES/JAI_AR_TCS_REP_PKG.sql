--------------------------------------------------------
--  DDL for Package Body JAI_AR_TCS_REP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_AR_TCS_REP_PKG" AS
/* $Header: jai_tcs_repo_pkg.plb 120.11.12010000.13 2010/04/15 11:22:15 vkaranam ship $ */


  /** Package level variables used in debug package*/
  lv_object_name      jai_cmn_debug_contexts.LOG_CONTEXT%TYPE DEFAULT 'TCS.JAI_AR_TCS_REP_PKG';
  lv_member_name      jai_cmn_debug_contexts.LOG_CONTEXT%TYPE;
  lv_context          jai_cmn_debug_contexts.LOG_CONTEXT%TYPE;
  /****
  || Get the primary key
  || for the table jai_rgm_refs_all
  *****/
  CURSOR cur_get_trx_ref_id
  IS
  SELECT
          jai_rgm_refs_all_s1.nextval
  FROM
          dual;

  /****
  || Get the primary key
  || for the table jai_rgm_taxes
  *****/
  CURSOR cur_get_tax_det_id
  IS
  SELECT
          jai_rgm_taxes_s.nextval
  FROM
          dual;

  /*
  ||Get the parent reference_id of source document , This gives the last line of the source document. (needs to be discussed )
  */
  CURSOR cur_get_parent_transaction  ( cp_source_document_id    JAI_RGM_REFS_ALL.SOURCE_DOCUMENT_ID%TYPE   ,
                                       cp_source_document_type  JAI_RGM_REFS_ALL.SOURCE_DOCUMENT_TYPE%TYPE
                                     )
  IS
  SELECT
        max(transaction_id) parent_transaction_id
  FROM
        jai_rgm_refs_all
  WHERE
        source_document_id    = cp_source_document_id
  AND   source_document_type  = cp_source_document_type;

  /*
  || Generate the transaction_id from the sequence
  */
  CURSOR cur_get_transaction_id
  IS
  SELECT
          jai_rgm_refs_all_s2.nextval
  FROM
          dual;

 ln_event              VARCHAR2(100); /*package private variable*/
 ln_transaction_id     JAI_RGM_REFS_ALL.TRANSACTION_ID%TYPE      ;

 PROCEDURE set_debug_context
 IS
 BEGIN
   lv_context  := rtrim(lv_object_name || '.'||lv_member_name,'.');
 END set_debug_context;

PROCEDURE wsh_interim_accounting (  p_delivery_id         IN            JAI_OM_WSH_LINES_ALL.DELIVERY_ID%TYPE            ,
                                    p_delivery_detail_id  IN            JAI_OM_WSH_LINES_ALL.DELIVERY_DETAIL_ID%TYPE     ,
                                    p_order_header_id     IN            JAI_OM_WSH_LINES_ALL.ORDER_HEADER_ID%TYPE        ,
                                    p_organization_id     IN            JAI_OM_WSH_LINES_ALL.ORGANIZATION_ID%TYPE        ,
                                    p_location_id         IN            JAI_OM_WSH_LINES_ALL.LOCATION_ID%TYPE            ,
                                    p_currency_code       IN            VARCHAR2                                           ,
                                    p_process_flag        OUT NOCOPY    VARCHAR2                                           ,
                                    p_process_message     OUT NOCOPY    VARCHAR2
                                 )

IS
  ln_reg_id           NUMBER;
  CURSOR cur_get_picking_taxes
  IS
  SELECT
           jsptl.*        ,
           jrttv.regime_id,
           jtc.tax_type
  FROM
          JAI_OM_WSH_LINES_ALL       jspl ,
          JAI_OM_WSH_LINE_TAXES   jsptl,
          JAI_CMN_TAXES_ALL              jtc  ,
          jai_regime_tax_types_v       jrttv
  WHERE
          jspl.delivery_detail_id   = jsptl.delivery_detail_id
  AND     jspl.delivery_id          = p_delivery_id
  AND     jspl.delivery_detail_id   = p_delivery_detail_id
  AND     jsptl.tax_id              = jtc.tax_id
  AND     jtc.tax_type              = jrttv.tax_type
  AND     jrttv.regime_code         = jai_constants.tcs_regime;

  CURSOR cur_get_order_num( cp_hdr_id JAI_OM_WSH_LINES_ALL.ORDER_HEADER_ID%TYPE)
  IS
  SELECT
          order_number
  FROM
          oe_order_headers_all
  WHERE
          header_id = cp_hdr_id;

  v_ref_10    GL_INTERFACE.REFERENCE10%TYPE                                                   ;
  v_std_text  VARCHAR2(50)                     ; -- bug # 3158976
  v_ref_23    GL_INTERFACE.REFERENCE23%TYPE    ; -- holds the object name -- 'ja_in_wsh_dlry_rg'
  v_ref_24    GL_INTERFACE.REFERENCE24%TYPE    ; -- holds the table name  -- ' wsh_new_deliveries'
  v_ref_25    GL_INTERFACE.REFERENCE25%TYPE    ; -- holds the column name -- 'delivery_id'
  v_ref_26    GL_INTERFACE.REFERENCE26%TYPE                                                   ; -- holds the column value -- eg -- 13645

  ln_order_number   OE_ORDER_HEADERS_ALL.ORDER_NUMBER%TYPE ;
  lv_source_name    VARCHAR2(100)                              ;
  lv_category_name  VARCHAR2(100)                ;

  v_int_liab_acc_ccid  NUMBER;
  v_liab_acc_ccid      NUMBER;
BEGIN
  /*########################################################################################################
  || VARIABLES INITIALIZATION - PART -1
  ########################################################################################################*/
   lv_member_name        := 'WSH_INTERIM_ACCOUNTING';
   v_std_text := 'India Localization Entry for sales order #' ;
   v_ref_23   := 'jai_ar_tcs_rep_pkg.wsh_interim_accounting';
   v_ref_24  := 'wsh_new_deliveries';
   v_ref_25   := 'delivery_id';
  -- lv_source_name := jai_constants.tcs_source  ;  -- modified by csahoo for bug#6155839
  -- lv_category_name := 'Receivables India'  ;  -- modified by csahoo for bug#6155839

 lv_source_name := 'Receivables India'  ; --bug#9587338
 lv_category_name :=jai_constants.tcs_source; --bug#9587338

   set_debug_context;


   /*commented by csahoo for bug# 6401388
   jai_cmn_debug_contexts_pkg.register ( pv_context => lv_context  ,
                                pn_reg_id  => ln_reg_id
                              );*/
  p_process_flag         := jai_constants.successful   ;
  p_process_message      := null                       ;

  OPEN  cur_get_order_num( cp_hdr_id  => p_order_header_id );
  FETCH cur_get_order_num INTO ln_order_number;
  CLOSE cur_get_order_num ;

  v_ref_26 := p_delivery_id  ;


  --|| Added the delivery_id to the v_Ref_10 variable so that delivery id can also be seen
  --|| in the journal screen when the gl import is done.

  v_ref_10 := v_std_text || ln_order_number || ' and Delivery id :' || p_delivery_id || ' and Delivery Detail id :' || p_delivery_detail_id ;


  FOR rec_cur_get_picking_taxes IN cur_get_picking_taxes
  LOOP


    /*********************************************************************************************************
    || Get the code combination id from the Organization/Regime Registration setup
    || by calling the function jai_cmn_rgm_recording_pkg.get_account
    *********************************************************************************************************/

/*commented by csahoo for bug# 6401388
jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                        pv_log_msg  =>  'Before call to jai_cmn_rgm_recording_pkg.get_account for int liab'
                                     );*/
    v_liab_acc_ccid     := jai_cmn_rgm_recording_pkg.get_account  (
                                                                    p_regime_id             => rec_cur_get_picking_taxes.regime_id  ,
                                                                    p_organization_type     => jai_constants.orgn_type_io           ,
                                                                    p_organization_id       => p_organization_id                    ,
                                                                    p_location_id           => p_location_id                        ,
                                                                    p_tax_type              => rec_cur_get_picking_taxes.tax_type   ,
                                                                    p_account_name          => jai_constants.liability
                                                                 );

    /*commented by csahoo for bug# 6401388
    jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                        pv_log_msg  =>  'Before call to jai_cmn_rgm_recording_pkg.get_account for liab'
                                     );*/
    v_int_liab_acc_ccid := jai_cmn_rgm_recording_pkg.get_account (
                                                                    p_regime_id         => rec_cur_get_picking_taxes.regime_id      ,
                                                                    p_organization_type => jai_constants.orgn_type_io               ,
                                                                    p_organization_id   => p_organization_id                        ,
                                                                    p_location_id       => p_location_id                            ,
                                                                    p_tax_type          => rec_cur_get_picking_taxes.tax_type       ,
                                                                    p_account_name      => jai_constants.liability_interim
                                                                 );



    IF v_int_liab_acc_ccid IS NULL OR
       v_liab_acc_ccid     IS NULL
    THEN
      /**********************************************************************************************************
      || Code Combination id has been returned as null from the function jai_cmn_rgm_recording_pkg.get_account
      || This is an error condition and the current processing has to be stopped
      **********************************************************************************************************/
     /*commented by csahoo for bug# 6401388
     jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                          pv_log_msg  =>  'Error in call to jai_cmn_rgm_recording_pkg.get_account'
                                       );*/
      p_process_flag      := jai_constants.expected_error;
      p_process_message   := 'Invalid Code combination ,please check the TCS Tax - Tax Accounting Setup';
      return;
    END IF;


    /*
    ||Credit the liability account
    */
    /*commented by csahoo for bug# 6401388
     jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                        PV_LOG_MSG  =>  'CREDIT MEMO ENTRIES GETTING PASSED TO jai_cmn_gl_pkg.create_gl_entry ARE :- ' ||fnd_global.local_chr(10)
                                        ||', p_organization_id           -> '|| p_organization_id                                     ||fnd_global.local_chr(10)
                                        ||', p_currency_code             -> '|| p_currency_code                                       ||fnd_global.local_chr(10)
                                        ||', p_credit_amount             -> '|| round(rec_cur_get_picking_taxes.func_tax_amount)      ||fnd_global.local_chr(10)
                                        ||', p_debit_amount              -> '|| 0                                                     ||fnd_global.local_chr(10)
                                        ||', p_cc_id                     -> '|| v_liab_acc_ccid                                       ||fnd_global.local_chr(10)
                                        ||', p_je_source_name            -> '|| lv_source_name                                        ||fnd_global.local_chr(10)
                                        ||', p_je_category_name          -> '|| lv_category_name                                      ||fnd_global.local_chr(10)
                                        ||', p_created_by                -> '|| rec_cur_get_picking_taxes.created_by                  ||fnd_global.local_chr(10)
                                        ||', p_accounting_date           -> '|| trunc(sysdate)                                        ||fnd_global.local_chr(10)
                                        ||', p_currency_conversion_date  -> '|| NULL                                                  ||fnd_global.local_chr(10)
                                        ||', p_currency_conversion_type  -> '|| NULL                                                  ||fnd_global.local_chr(10)
                                        ||', p_currency_conversion_rate  -> '|| NULL                                                  ||fnd_global.local_chr(10)
                                        ||', p_reference_10              -> '|| v_ref_10                                              ||fnd_global.local_chr(10)
                                        ||', p_reference_23              -> '|| v_ref_23                                              ||fnd_global.local_chr(10)
                                        ||', p_reference_24              -> '|| v_ref_24                                              ||fnd_global.local_chr(10)
                                        ||', p_reference_25              -> '|| v_ref_25                                              ||fnd_global.local_chr(10)
                                        ||', p_reference_26              -> '|| v_ref_26
                                     );*/


    jai_cmn_gl_pkg.create_gl_entry
              (p_organization_id              => p_organization_id                                    ,
               p_currency_code                => p_currency_code                                      ,
               p_credit_amount                => round(rec_cur_get_picking_taxes.func_tax_amount)     ,
               p_debit_amount                 => 0                                                    ,
               p_cc_id                        => v_liab_acc_ccid                                      ,
               p_je_source_name               => lv_source_name                                       ,
               p_je_category_name             => lv_category_name                                     ,
               p_created_by                   => rec_cur_get_picking_taxes.created_by                 ,
               p_accounting_date              => trunc(sysdate)                                       ,
               p_currency_conversion_date     => NULL                                                 ,
               p_currency_conversion_type     => NULL                                                 ,
               p_currency_conversion_rate     => NULL                                                 ,
               p_reference_10                 => v_ref_10                                             ,
               p_reference_23                 => v_ref_23                                             ,
               p_reference_24                 => v_ref_24                                             ,
               p_reference_25                 => v_ref_25                                             ,
               p_reference_26                 => v_ref_26
               );

    /*
    ||Debit the Interim liability account
    */
    /*
    jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                        pv_log_msg  =>  'DEBIT MEMO ENTRIES GETTING PASSED TO jai_cmn_gl_pkg.create_gl_entry ARE :- '||fnd_global.local_chr(10)
                                        ||', p_organization_id           -> '|| p_organization_id                                   ||fnd_global.local_chr(10)
                                        ||', p_currency_code             -> '|| p_currency_code                                     ||fnd_global.local_chr(10)
                                        ||', p_credit_amount             -> '|| 0                                                   ||fnd_global.local_chr(10)
                                        ||', p_debit_amount              -> '|| round(rec_cur_get_picking_taxes.func_tax_amount)    ||fnd_global.local_chr(10)
                                        ||', p_cc_id                     -> '|| v_int_liab_acc_ccid                                 ||fnd_global.local_chr(10)
                                        ||', p_je_source_name            -> '|| lv_source_name                                      ||fnd_global.local_chr(10)
                                        ||', p_je_category_name          -> '|| lv_category_name                                    ||fnd_global.local_chr(10)
                                        ||', p_created_by                -> '|| rec_cur_get_picking_taxes.created_by                ||fnd_global.local_chr(10)
                                        ||', p_accounting_date           -> '|| trunc(sysdate)                                      ||fnd_global.local_chr(10)
                                        ||', p_currency_conversion_date  -> '|| NULL                                                ||fnd_global.local_chr(10)
                                        ||', p_currency_conversion_type  -> '|| NULL                                                ||fnd_global.local_chr(10)
                                        ||', p_currency_conversion_rate  -> '|| NULL                                                ||fnd_global.local_chr(10)
                                        ||', p_reference_10              -> '|| v_ref_10                                            ||fnd_global.local_chr(10)
                                        ||', p_reference_23              -> '|| v_ref_23                                            ||fnd_global.local_chr(10)
                                        ||', p_reference_24              -> '|| v_ref_24                                            ||fnd_global.local_chr(10)
                                        ||', p_reference_25              -> '|| v_ref_25                                            ||fnd_global.local_chr(10)
                                        ||', p_reference_26              -> '|| v_ref_26
                                     );*/
    jai_cmn_gl_pkg.create_gl_entry
              (p_organization_id              => p_organization_id                                      ,
               p_currency_code                => p_currency_code                                        ,
               p_credit_amount                => 0                                                      ,
               p_debit_amount                 => round(rec_cur_get_picking_taxes.func_tax_amount)       ,
               p_cc_id                        => v_int_liab_acc_ccid                                    ,
               p_je_source_name               => lv_source_name                                         ,
               p_je_category_name             => lv_category_name                                       ,
               p_created_by                   => rec_cur_get_picking_taxes.created_by                   ,
               p_accounting_date              => trunc(sysdate)                                         ,
               p_currency_conversion_date     => NULL                                                   ,
               p_currency_conversion_type     => NULL                                                   ,
               p_currency_conversion_rate     => NULL                                                   ,
               p_reference_10                 => v_ref_10                                               ,
               p_reference_23                 => v_ref_23                                               ,
               p_reference_24                 => v_ref_24                                               ,
               p_reference_25                 => v_ref_25                                               ,
               p_reference_26                 => v_ref_26
               );

  END LOOP;

  /*commented by csahoo for bug# 6401388
  jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                      pv_log_msg  =>  '**************** WSH_INTERIM_ACCOUNTING SUCCESSFULLY COMPLETED ****************'
                                   );
  jai_cmn_debug_contexts_pkg.deregister (pn_reg_id => ln_reg_id);*/

EXCEPTION
  WHEN OTHERS THEN
    p_process_flag      := jai_constants.unexpected_error;
    p_process_message   := 'Unexpected error in the jai_ar_tcs_rep_pkg.wsh_interim_accounting '||substr(sqlerrm,1,300);

END wsh_interim_accounting;

PROCEDURE ar_accounting (     p_ract              IN            RA_CUSTOMER_TRX_ALL%ROWTYPE       DEFAULT NULL  ,
                              p_ractl             IN            RA_CUSTOMER_TRX_LINES_ALL%ROWTYPE DEFAULT NULL  ,
                              p_process_flag      OUT NOCOPY    VARCHAR2                                        ,
                              p_process_message   OUT NOCOPY    VARCHAR2
                         )

IS
  ln_reg_id           NUMBER;
  CURSOR cur_get_inv_det   ( cp_customer_trx_id         RA_CUSTOMER_TRX_ALL.CUSTOMER_TRX_ID%TYPE                         ,
                             cp_customer_trx_line_id    RA_CUSTOMER_TRX_LINES_ALL.CUSTOMER_TRX_LINE_ID%TYPE  DEFAULT NULL
                           )
  IS
  SELECT
           jrcttl.*              ,
           jrct.organization_id  ,
           jrct.location_id      ,
           jrttv.regime_id       ,
           jtc.tax_type
  FROM
          JAI_AR_TRXS        jrct   ,
          JAI_AR_TRX_LINES  jrctl  ,
          JAI_AR_TRX_TAX_LINES  jrcttl ,
          JAI_CMN_TAXES_ALL              jtc    ,
          jai_regime_tax_types_v       jrttv

  WHERE
          jrct.customer_trx_id        = jrctl.customer_trx_id
  AND     jrctl.customer_trx_line_id  = jrcttl.link_to_cust_trx_line_id
  AND     jrcttl.tax_id               = jtc.tax_id
  AND     jtc.tax_type                = jrttv.tax_type
  AND     jrttv.regime_code           = jai_constants.tcs_regime
  AND     jrct.customer_trx_id        = cp_customer_trx_id
  AND     jrctl.customer_trx_line_id  = nvl( cp_customer_trx_line_id , jrctl.customer_trx_line_id );

  /* Added for Bug 6734317 - Start */
  CURSOR c_dist_gl_date(cp_customer_trx_id ra_cust_trx_line_gl_dist_all.customer_trx_id%type)
  IS
  SELECT max(gl_date) gl_date
  FROM   ra_cust_trx_line_gl_dist_all
  WHERE  customer_trx_id = cp_customer_trx_id ;

  ld_dist_gl_date   ra_cust_trx_line_gl_dist_all.gl_date%TYPE ;
  /* Added for Bug 6734317 - End */

  v_ref_10    GL_INTERFACE.REFERENCE10%TYPE                                                       ;
  v_std_text  VARCHAR2(50)                                                                        ;
  v_ref_23    GL_INTERFACE.REFERENCE23%TYPE   ; -- holds the object name
  v_ref_24    GL_INTERFACE.REFERENCE24%TYPE   ; -- holds the table name
  v_ref_25    GL_INTERFACE.REFERENCE25%TYPE   ; -- holds the column name
  v_ref_26    GL_INTERFACE.REFERENCE26%TYPE                                                       ; -- holds the column value -- eg -- 13645

  lv_source_name    VARCHAR2(100)                        ;
  lv_category_name  VARCHAR2(100)                         ;

  v_int_liab_acc_ccid  NUMBER;
  v_liab_acc_ccid      NUMBER;
BEGIN
  /*########################################################################################################
  || VARIABLES INITIALIZATION - PART -1
  ########################################################################################################*/
   lv_member_name        := 'AR_ACCOUNTING';
   v_ref_23 := 'jai_ar_tcs_rep_pkg.ar_accounting';
   v_ref_24 := 'ra_customer_trx_all'             ;
   v_ref_25 := 'customer_trx_id'                 ;
  -- lv_source_name     := jai_constants.tcs_source   ;    -- modified by csahoo for bug#6155839 commented for bug#9587338
  -- lv_category_name   := 'Receivables India'  ;   -- modified by csahoo for bug#6155839 commented for bug#9587338

  lv_source_name := 'Receivables India'  ; --bug#9587338
  lv_category_name :=jai_constants.tcs_source; --bug#9587338

   set_debug_context;


  /* jai_cmn_debug_contexts_pkg.register ( pv_context => lv_context  ,
                                pn_reg_id  => ln_reg_id
                              ); --commmented by CSahoo, BUG#5631784*/
  p_process_flag         := jai_constants.successful   ;
  p_process_message      := null                       ;

  v_ref_26 := nvl(p_ract.customer_trx_id,p_ractl.customer_trx_id)  ;

  IF p_ract.customer_trx_id IS NOT NULL THEN
    v_std_text := 'India Localization Entry for Manual Invoices#'  ;
  ELSIF p_ractl.customer_trx_id IS NOT NULL THEN
    v_std_text := 'India Localization Entry for Bill Only Invoices#'  ;
  END IF;

  v_ref_10 := v_std_text || p_ract.trx_number || ' and customer_trx_id :' || nvl(p_ract.customer_trx_id,p_ractl.customer_trx_id) ;


  FOR rec_cur_get_inv_det IN cur_get_inv_det (  cp_customer_trx_id       =>  nvl(p_ract.customer_trx_id,p_ractl.customer_trx_id ),
                                                cp_customer_trx_line_id  =>  p_ractl.customer_trx_line_id
                                             )

  LOOP


    /*********************************************************************************************************
    || Get the code combination id from the Organization/Regime Registration setup
    || by calling the function jai_cmn_rgm_recording_pkg.get_account
    *********************************************************************************************************/

    /*commented by csahoo for bug# 6401388
    jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                        pv_log_msg  =>  'Before call to jai_cmn_rgm_recording_pkg.get_account for int liab'
                                     );*/
    v_liab_acc_ccid     := jai_cmn_rgm_recording_pkg.get_account  (
                                                                    p_regime_id             => rec_cur_get_inv_det.regime_id        ,
                                                                    p_organization_type     => jai_constants.orgn_type_io           ,
                                                                    p_organization_id       => rec_cur_get_inv_det.organization_id  ,
                                                                    p_location_id           => rec_cur_get_inv_det.location_id      ,
                                                                    p_tax_type              => rec_cur_get_inv_det.tax_type         ,
                                                                    p_account_name          => jai_constants.liability
                                                                 );

   /*commented by csahoo for bug# 6401388
   jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                        pv_log_msg  =>  'Before call to jai_cmn_rgm_recording_pkg.get_account for liab'
                                     );*/
    v_int_liab_acc_ccid := jai_cmn_rgm_recording_pkg.get_account (
                                                                    p_regime_id         => rec_cur_get_inv_det.regime_id         ,
                                                                    p_organization_type => jai_constants.orgn_type_io            ,
                                                                    p_organization_id   => rec_cur_get_inv_det.organization_id   ,
                                                                    p_location_id       => rec_cur_get_inv_det.location_id       ,
                                                                    p_tax_type          => rec_cur_get_inv_det.tax_type          ,
                                                                    p_account_name      => jai_constants.liability_interim
                                                                 );



    IF v_int_liab_acc_ccid IS NULL OR
       v_liab_acc_ccid     IS NULL
    THEN
      /**********************************************************************************************************
      || Code Combination id has been returned as null from the function jai_cmn_rgm_recording_pkg.get_account
      || This is an error condition and the current processing has to be stopped
      **********************************************************************************************************/
      /*commented by csahoo for bug# 6401388
      jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                          pv_log_msg  =>  'Error in call to jai_cmn_rgm_recording_pkg.get_account'
                                       );*/
      p_process_flag      := jai_constants.expected_error;
      p_process_message   := 'Invalid Code combination ,please check the TCS Tax - Tax Accounting Setup';
      return;
    END IF;

    /* Added for Bug 6734317 */
    OPEN  c_dist_gl_date(nvl(p_ract.customer_trx_id, p_ractl.customer_trx_id)) ;
    FETCH c_dist_gl_date INTO ld_dist_gl_date;
    CLOSE c_dist_gl_date ;

    /*
    ||Credit the liability account
    */
    /*commented by csahoo for bug# 6401388
    jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                        PV_LOG_MSG  =>  'CREDIT MEMO ENTRIES GETTING PASSED TO jai_cmn_gl_pkg.create_gl_entry ARE :- ' ||fnd_global.local_chr(10)
                                        ||', p_organization_id           -> '|| rec_cur_get_inv_det.organization_id                   ||fnd_global.local_chr(10)
                                        ||', p_currency_code             -> '|| p_ract.invoice_currency_code                          ||fnd_global.local_chr(10)
                                        ||', p_credit_amount             -> '|| round(rec_cur_get_inv_det.func_tax_amount)            ||fnd_global.local_chr(10)
                                        ||', p_debit_amount              -> '|| 0                                                     ||fnd_global.local_chr(10)
                                        ||', p_cc_id                     -> '|| v_liab_acc_ccid                                       ||fnd_global.local_chr(10)
                                        ||', p_je_source_name            -> '|| lv_source_name                                        ||fnd_global.local_chr(10)
                                        ||', p_je_category_name          -> '|| lv_category_name                                      ||fnd_global.local_chr(10)
                                        ||', p_created_by                -> '|| rec_cur_get_inv_det.created_by                        ||fnd_global.local_chr(10)
                                        ||', p_accounting_date           -> '|| trunc(sysdate)                                        ||fnd_global.local_chr(10)
                                        ||', p_currency_conversion_date  -> '|| NULL                                                  ||fnd_global.local_chr(10)
                                        ||', p_currency_conversion_type  -> '|| NULL                                                  ||fnd_global.local_chr(10)
                                        ||', p_currency_conversion_rate  -> '|| NULL                                                  ||fnd_global.local_chr(10)
                                        ||', p_reference_10              -> '|| v_ref_10                                              ||fnd_global.local_chr(10)
                                        ||', p_reference_23              -> '|| v_ref_23                                              ||fnd_global.local_chr(10)
                                        ||', p_reference_24              -> '|| v_ref_24                                              ||fnd_global.local_chr(10)
                                        ||', p_reference_25              -> '|| v_ref_25                                              ||fnd_global.local_chr(10)
                                        ||', p_reference_26              -> '|| v_ref_26
                                     );*/

    jai_cmn_gl_pkg.create_gl_entry
              (p_organization_id              => rec_cur_get_inv_det.organization_id            ,
               p_currency_code                => p_ract.invoice_currency_code                   ,
               p_credit_amount                => round(rec_cur_get_inv_det.func_tax_amount)     ,
               p_debit_amount                 => 0                                              ,
               p_cc_id                        => v_liab_acc_ccid                                ,
               p_je_source_name               => lv_source_name                                 ,
               p_je_category_name             => lv_category_name                               ,
               p_created_by                   => rec_cur_get_inv_det.created_by                 ,
               p_accounting_date              => ld_dist_gl_date                                , /*Replaced sysdate with ld_dist_gl_date - Bug 6734317*/
               p_currency_conversion_date     => NULL                                           ,
               p_currency_conversion_type     => NULL                                           ,
               p_currency_conversion_rate     => NULL                                           ,
               p_reference_10                 => v_ref_10                                       ,
               p_reference_23                 => v_ref_23                                       ,
               p_reference_24                 => v_ref_24                                       ,
               p_reference_25                 => v_ref_25                                       ,
               p_reference_26                 => v_ref_26
               );


    /*
    ||Debit the Interim liability account
    */
    /*commented by csahoo for bug# 6401388
    jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                        pv_log_msg  =>  'DEBIT MEMO ENTRIES GETTING PASSED TO jai_cmn_gl_pkg.create_gl_entry ARE :- '||fnd_global.local_chr(10)
                                        ||', p_organization_id           -> '|| rec_cur_get_inv_det.organization_id                 ||fnd_global.local_chr(10)
                                        ||', p_currency_code             -> '|| p_ract.invoice_currency_code                        ||fnd_global.local_chr(10)
                                        ||', p_credit_amount             -> '|| 0                                                   ||fnd_global.local_chr(10)
                                        ||', p_debit_amount              -> '|| round(rec_cur_get_inv_det.func_tax_amount)          ||fnd_global.local_chr(10)
                                        ||', p_cc_id                     -> '|| v_int_liab_acc_ccid                                 ||fnd_global.local_chr(10)
                                        ||', p_je_source_name            -> '|| lv_source_name                                      ||fnd_global.local_chr(10)
                                        ||', p_je_category_name          -> '|| lv_category_name                                    ||fnd_global.local_chr(10)
                                        ||', p_created_by                -> '|| rec_cur_get_inv_det.created_by                      ||fnd_global.local_chr(10)
                                        ||', p_accounting_date           -> '|| trunc(sysdate)                                      ||fnd_global.local_chr(10)
                                        ||', p_currency_conversion_date  -> '|| NULL                                                ||fnd_global.local_chr(10)
                                        ||', p_currency_conversion_type  -> '|| NULL                                                ||fnd_global.local_chr(10)
                                        ||', p_currency_conversion_rate  -> '|| NULL                                                ||fnd_global.local_chr(10)
                                        ||', p_reference_10              -> '|| v_ref_10                                            ||fnd_global.local_chr(10)
                                        ||', p_reference_23              -> '|| v_ref_23                                            ||fnd_global.local_chr(10)
                                        ||', p_reference_24              -> '|| v_ref_24                                            ||fnd_global.local_chr(10)
                                        ||', p_reference_25              -> '|| v_ref_25                                            ||fnd_global.local_chr(10)
                                        ||', p_reference_26              -> '|| v_ref_26
                                     );*/

    jai_cmn_gl_pkg.create_gl_entry
              (p_organization_id              => rec_cur_get_inv_det.organization_id            ,
               p_currency_code                => p_ract.invoice_currency_code                   ,
               p_credit_amount                => 0                                              ,
               p_debit_amount                 => round(rec_cur_get_inv_det.func_tax_amount)     ,
               p_cc_id                        => v_int_liab_acc_ccid                            ,
               p_je_source_name               => lv_source_name                                 ,
               p_je_category_name             => lv_category_name                               ,
               p_created_by                   => rec_cur_get_inv_det.created_by                 ,
               p_accounting_date              => ld_dist_gl_date                                , /*Replaced sysdate with ld_dist_gl_date - Bug 6734317*/
               p_currency_conversion_date     => NULL                                           ,
               p_currency_conversion_type     => NULL                                           ,
               p_currency_conversion_rate     => NULL                                           ,
               p_reference_10                 => v_ref_10                                       ,
               p_reference_23                 => v_ref_23                                       ,
               p_reference_24                 => v_ref_24                                       ,
               p_reference_25                 => v_ref_25                                       ,
               p_reference_26                 => v_ref_26
               );

  END LOOP;

 /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                      pv_log_msg  =>  '**************** MAN_AR_COMPLETION_ACCOUNTING SUCCESSFULLY COMPLETED ****************'
                                   );
  jai_cmn_debug_contexts_pkg.deregister (pn_reg_id => ln_reg_id);*/

EXCEPTION
  WHEN OTHERS THEN
    p_process_flag      := jai_constants.unexpected_error;
    p_process_message   := 'Unexpected error in the jai_ar_tcs_rep_pkg.man_ar_completion_accounting '||substr(sqlerrm,1,300);

END ar_accounting;


PROCEDURE validate_sales_order  (  p_ooh              IN             OE_ORDER_HEADERS_ALL%ROWTYPE ,
                                   p_process_flag     OUT NOCOPY     VARCHAR2                     ,
                                   p_process_message  OUT NOCOPY     VARCHAR2
                                )
IS
   ln_reg_id           NUMBER;

  /*
  || Check that the document has has TCS type of tax.
  */
  CURSOR cur_chk_tcs_applicable ( cp_header_id JAI_OM_OE_SO_LINES.HEADER_ID%TYPE )
  IS
  SELECT
          1
  FROM
          JAI_OM_OE_SO_LINES           jsl  ,
          JAI_OM_OE_SO_TAXES       jstl ,
          JAI_CMN_TAXES_ALL          jtc  ,
          jai_regime_tax_types_v   jrttv
  WHERE
          jsl.header_id        =   cp_header_id
  AND     jsl.line_id          =   jstl.line_id
  AND     jtc.tax_id           =   jstl.tax_id
  AND     jtc.tax_type         =   jrttv.tax_type
  AND     jrttv.regime_code    =   jai_constants.tcs_regime; /* Applied to doc has got TCS type of tax*/



  /*
  ||Now that some lines have got TCS type of taxes , check that all lines have got tcs type of taxes
  ||if any one line does not have TCS type of tax then throw an error
  */
   CURSOR cur_chk_tcs_for_all_lines ( cp_header_id JAI_OM_OE_SO_LINES.HEADER_ID%TYPE )
   IS
   SELECT
          1
   FROM
          JAI_OM_OE_SO_LINES           jsl, oe_order_lines_all oola
   WHERE
          jsl.header_id        =   cp_header_id
   /*9154563 - Added clause to check for canceled_flag also*/
   AND    oola.header_id       =   jsl.header_id
   AND    oola.line_id         =   jsl.line_id
   AND    oola.cancelled_flag  =   'N'
   AND   NOT EXISTS  (
                        SELECT
                                1
                        FROM
                                JAI_OM_OE_SO_TAXES       jstl ,
                                JAI_CMN_TAXES_ALL          jtc  ,
                                jai_regime_tax_types_v   jrttv
                        WHERE
                                jsl.line_id          =   jstl.line_id
                        AND     jtc.tax_id           =   jstl.tax_id
                        AND     jtc.tax_type         =   jrttv.tax_type
                        AND     jrttv.regime_code    =   jai_constants.tcs_regime /* Applied to doc has got TCS type of tax*/
                     );

  /*******
  || Validate that the inventory_items for all lines of the sales order  should have the same TCS item classification
  || for the same has already been settled
  ********/
  CURSOR cur_validate_all_items ( cp_header_id JAI_OM_OE_SO_LINES.HEADER_ID%TYPE )
  IS
  SELECT
         inventory_item_id
  FROM
          JAI_OM_OE_SO_LINES           jsl
   WHERE
          jsl.header_id        =   cp_header_id;

  lv_object_name      jai_cmn_debug_contexts.LOG_CONTEXT%TYPE ;
  lv_member_name      jai_cmn_debug_contexts.LOG_CONTEXT%TYPE;
  lv_context          jai_cmn_debug_contexts.LOG_CONTEXT%TYPE;

  ln_exists                 NUMBER                                          ;
  lv_first_itm_class        JAI_RGM_REFS_ALL.ITEM_CLASSIFICATION%TYPE       ;
  lv_item_classification    JAI_RGM_REFS_ALL.ITEM_CLASSIFICATION%TYPE       ;

  lv_process_flag           VARCHAR2(2)                                     ;
  lv_process_message        VARCHAR2(4000)                                  ;

BEGIN

  /*########################################################################################################
  || VARIABLES INITIALIZATION - PART -1
  ########################################################################################################*/
   lv_member_name        := 'VALIDATE_SALES_ORDER';
   lv_object_name :=  'TCS.JAI_AR_TCS_REP_PKG';
   set_debug_context;
  /*commented by csahoo for bug# 6401388
   jai_cmn_debug_contexts_pkg.register ( pv_context => lv_context  ,
                                pn_reg_id  => ln_reg_id
                              );*/
  lv_process_flag         := jai_constants.successful   ;
  lv_process_message      := null                       ;

  p_process_flag          := lv_process_flag            ;
  p_process_message       := lv_process_message         ;

  /*########################################################################################################
  || SALES ORDER TCS APPLICABILITY CHECK - PART - 1
  ########################################################################################################*/

  /*
  ||Check that the order has a flow status code as booked else skip the transaction
  */
  IF ln_event = jai_constants.order_booked AND
     p_ooh.flow_status_code <> jai_constants.order_booked
  THEN
/*commented by csahoo for bug# 6401388
    jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                               pv_log_msg  =>  ' Skip the transaction as order has a flow status code as '|| p_ooh.flow_status_code ||' which is different from BOOKED '
                             );*/
    p_process_flag := jai_constants.not_applicable ;
    return;

  END IF;

  /*
  || Check that for sales order TCS applicability
  || IF no then return
  */

  OPEN cur_chk_tcs_applicable ( cp_header_id => p_ooh.header_id ) ;
  FETCH cur_chk_tcs_applicable INTO ln_exists ;
  IF CUR_CHK_TCS_APPLICABLE%NOTFOUND THEN
  /*commented by csahoo for bug# 6401388
    jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                               pv_log_msg  =>  ' Skip as order does not have TCS type of taxes '
                             );*/
    p_process_flag := jai_constants.not_applicable ;
    return;
  END IF;
  CLOSE cur_chk_tcs_applicable;



  /*########################################################################################################
  || VALIDATE THAT ALL LINES SHOULD HAVE TCS OR NIETHER SHOUD HAVE ANY - PART - 2
  ########################################################################################################*/
  IF  ln_event IN ( jai_constants.order_booked ,
                    jai_constants.wsh_ship_confirm
                  )
  THEN

    /****************
    || Event is Sales Order Booking
    || Validate that all lines have TCS type of taxes
    || if no then error out
    *****************/

    OPEN  cur_chk_tcs_for_all_lines ( cp_header_id => p_ooh.header_id ) ;
    FETCH cur_chk_tcs_for_all_lines INTO ln_exists;
    IF CUR_CHK_TCS_FOR_ALL_LINES%FOUND THEN
      /*
      ||Rows with no TCS type of taxes exists hence error out
      */
      CLOSE cur_chk_tcs_for_all_lines ;
     /*commented by csahoo for bug# 6401388
     jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                 pv_log_msg  =>  'Error :- Cannot Book/ship the sales order if some lines have TCS type of tax and some dont '||fnd_global.local_chr(10)
                                               ||', lv_process_flag     -> '|| lv_process_flag  ||fnd_global.local_chr(10)
                                               ||', lv_process_message  -> '||lv_process_message
                              );*/
      p_process_flag    := jai_constants.expected_error;
      p_process_message := 'Cannot Book/Ship the Sales Order as some lines do not have TCS type of taxes ';
      return;
      CLOSE cur_chk_tcs_for_all_lines ;
    END IF;

    /*########################################################################################################
    || VALIDATE THAT THE INVENTORY_ITEMS FOR ALL LINES OF THE SALES ORDER
    || SHOULD HAVE THE SAME TCS ITEM CLASSIFICATION - PART - 3
    ########################################################################################################*/

    lv_first_itm_class     := null;
    lv_item_classification := null;
    FOR rec_cur_validate_all_items IN cur_validate_all_items ( cp_header_id => p_ooh.header_id )
    LOOP

      /*
      ||Get the value for the item classification pertaining to the IO and inventory item combination
      */
      jai_inv_items_pkg.jai_get_attrib (
                                       p_regime_code         => jai_constants.tcs_regime                     ,
                                       p_organization_id     => p_ooh.ship_from_org_id                       , -- Organization id of the Selling organization (warehouse_id)
                                       p_inventory_item_id   => rec_cur_validate_all_items.inventory_item_id ,
                                       p_attribute_code      => jai_constants.rgm_attr_cd_itm_class          ,
                                       p_attribute_value     => lv_item_classification                       ,
                                       p_process_flag        => lv_process_flag                              ,
                                       p_process_msg         => lv_process_message
                                    );

      IF lv_process_flag = jai_constants.expected_error    OR                      ---------A2
         lv_process_flag = jai_constants.unexpected_error
      THEN
        /*
        || As Returned status is an error/not applicable hence:-
        || Set out variables p_process_flag and p_process_message accordingly
        */
        --call to debug package
        /*commented by csahoo for bug# 6401388
        jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                   pv_log_msg  =>  'Error In processing of jai_inv_items_pkg.jai_get_attrib'||fnd_global.local_chr(10)
                                                 ||', lv_process_flag     -> '|| lv_process_flag  ||fnd_global.local_chr(10)
                                                 ||', lv_process_message  -> '||lv_process_message
                                );*/

        p_process_flag    := lv_process_flag    ;
        p_process_message := lv_process_message ;
        return;
      END IF;                                                                      ---------A2

      IF lv_first_itm_class IS NULL THEN
        /*
        ||First time assignment
        */
        lv_first_itm_class := lv_item_classification;
      END IF;

      /*
      ||IF any one of the lines do not match with the item TCS classification of the first line
      || then stop the transaction and throw an error.
      */
      IF nvl(lv_first_itm_class,'$$') <> nvl(lv_item_classification,'###') THEN
        /*commented by csahoo for bug# 6401388
        jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                   pv_log_msg  =>  'Error :- Cannot Book/Ship the sales order as as all lines do not belong to the same Item Classification '||fnd_global.local_chr(10)
                                                ||', lv_process_flag     -> '|| lv_process_flag  ||fnd_global.local_chr(10)
                                                ||', lv_process_message  -> '||lv_process_message
                               );*/

        p_process_flag    := jai_constants.expected_error   ;
        p_process_message := 'Cannot Book/Ship the sales order. All lines should either have the same TCS item classification or none of the line should have TCS type of taxes' ;
        return;
      END IF;
    END LOOP;

  END IF;

  /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                             pv_log_msg  =>  '**************** VALIDATE_SALES_ORDER SUCCESSFULLY COMPLETED ****************'
                          );
  jai_cmn_debug_contexts_pkg.deregister (pn_reg_id => ln_reg_id);*/


END validate_sales_order ;

 PROCEDURE validate_invoice      (  p_ract             IN             RA_CUSTOMER_TRX_ALL%ROWTYPE    ,
                                    p_document_type    OUT NOCOPY     VARCHAR2                       ,
                                    p_process_flag     OUT NOCOPY     VARCHAR2                       ,
                                    p_process_message  OUT NOCOPY     VARCHAR2
                                 )
 IS
   ln_reg_id           NUMBER;
  /*
  || Check that the document has has TCS type of tax.
  */
  CURSOR cur_chk_tcs_applicable ( cp_customer_trx_id JAI_AR_TRXS.CUSTOMER_TRX_ID%TYPE )
  IS
  SELECT
          gl_dist.gl_date       ,
          jrct.organization_id
  FROM
          ra_cust_trx_line_gl_dist_all gl_dist ,
          JAI_AR_TRXS        jrct    ,
          JAI_AR_TRX_LINES  jrctl   ,
          JAI_AR_TRX_TAX_LINES  jrcttl  ,
          JAI_CMN_TAXES_ALL              jtc     ,
          jai_regime_tax_types_v       jrttv
  WHERE
          gl_dist.customer_trx_id      =   jrct.customer_trx_id
  AND     gl_dist.account_class        =   jai_constants.account_class_rec
  AND     gl_dist.latest_rec_flag      =   jai_constants.yes
  AND     jrct.customer_trx_id         =   cp_customer_trx_id
  AND     jrct.customer_trx_id         =   jrctl.customer_trx_id
  AND     jrctl.customer_trx_line_id   =   jrcttl.link_to_cust_trx_line_id
  AND     jtc.tax_id                   =   jrcttl.tax_id
  AND     jtc.tax_type                 =   jrttv.tax_type
  AND     jrttv.regime_code            =   jai_constants.tcs_regime; /* Applied to doc has got TCS type of tax*/


 /*
 ||Get the trx type of the document
 */
 CURSOR cur_get_doc_det ( cp_cust_trx_type_id RA_CUST_TRX_TYPES_ALL.CUST_TRX_TYPE_ID%TYPE )
 IS
 SELECT
        type
 FROM
        ra_cust_trx_types_all
 WHERE
       cust_trx_type_id   =  cp_cust_trx_type_id;

 /*
 ||Check whether TCS on the invoice/DEbit memo have been settled.
 */
 CURSOR cur_chk_tcs_settlement ( cp_customer_trx_id JAI_AR_TRXS.CUSTOMER_TRX_ID%TYPE )
 IS
 SELECT
        '1'
  FROM
        jai_rgm_refs_all
  WHERE
        source_document_id = cp_customer_trx_id
  AND   settlement_id      IS NOT NULL            ;

  /*
  ||Now that some lines have got TCS type of taxes , check that all lines have got tcs type of taxes
  ||if any one line does not have TCS type of tax then throw an error
  */
   CURSOR cur_chk_tcs_for_all_lines (cp_customer_trx_id JAI_AR_TRXS.CUSTOMER_TRX_ID%TYPE )
   IS
   SELECT
          1
   FROM
        JAI_AR_TRX_LINES  jrctl,
  ra_customer_trx_lines_all rctla  --Added by JMEENA to filter discount line. for bug#8241099
   WHERE
jrctl.customer_trx_id  = cp_customer_trx_id
AND jrctl.customer_trx_id = rctla.customer_trx_id
AND jrctl.customer_trx_line_id = rctla.customer_trx_line_id
AND NVL (rctla.interface_line_attribute11,0) = 0 --Added by JMEENA to filter discount line. for bug#8241099, discount line will have interface_line_attribute11 greater than zero.
   AND   NOT EXISTS  ( SELECT   /*Check that TCS type of taxes are not  */
                              1
                       FROM
                             JAI_AR_TRX_TAX_LINES  jrcttl  ,
                             JAI_CMN_TAXES_ALL              jtc     ,
                             jai_regime_tax_types_v       jrttv
                       WHERE
                             jrctl.customer_trx_line_id   =   jrcttl.link_to_cust_trx_line_id
                       AND   jtc.tax_id                   =   jrcttl.tax_id
                       AND   jtc.tax_type                 =   jrttv.tax_type
                       AND   jrttv.regime_code            =   jai_constants.tcs_regime
                     );


  /*
  ||Check tcs surcharge applicability on document
  */
  CURSOR cur_chk_tcs_sur_tax ( cp_customer_trx_id  JAI_AR_TRX_LINES.CUSTOMER_TRX_ID%TYPE )
  IS
  SELECT
         count(*) surcharge_cnt
  FROM
         JAI_AR_TRX_LINES jrctl   ,
         JAI_AR_TRX_TAX_LINES jrcttl  ,
         JAI_CMN_TAXES_ALL              jtc     ,
         jai_regime_tax_types_v       jrttv
  WHERE
         jrctl.customer_trx_id      =  cp_customer_trx_id
  AND    jrctl.customer_trx_line_id =  jrcttl.link_to_cust_trx_line_id
  AND    jrcttl.tax_id              =  jtc.tax_id
  AND    jtc.tax_type               =  jrttv.tax_type
  AND    jrttv.tax_type             =  jai_constants.tax_type_tcs_surcharge
  AND    jrttv.regime_code          =  jai_constants.tcs_regime;



     /*******
     || Validate that the inventory_items for all lines of the invoice should have the same TCS item classification
     || for the same has already been settled
     ********/
     CURSOR cur_validate_all_items ( cp_customer_trx_id JAI_AR_TRXS.CUSTOMER_TRX_ID%TYPE )
     IS
     SELECT
            organization_id        ,
            inventory_item_id
     FROM
            JAI_AR_TRXS        jrct  ,
            JAI_AR_TRX_LINES  jrctl
     WHERE
            jrct.customer_trx_id  = cp_customer_trx_id
     AND    jrct.customer_trx_id  = jrctl.customer_trx_id;

   lv_trx_type               RA_CUST_TRX_TYPES_ALL.TYPE%TYPE                ;
   lv_doc_type               VARCHAR2(100)                                  ;
   ln_regime_id              JAI_RGM_DEFINITIONS.REGIME_ID%TYPE                     ;
   lv_org_tan_no             JAI_RGM_REGISTRATIONS.ATTRIBUTE_VALUE%TYPE             ;
   ln_threshold_slab_id      JAI_RGM_REFS_ALL.THRESHOLD_SLAB_ID%TYPE        ;
   ln_exists                 NUMBER(2)                                      ;
   lv_first_itm_class        JAI_RGM_REFS_ALL.ITEM_CLASSIFICATION%TYPE      ;
   lv_item_classification    JAI_RGM_REFS_ALL.ITEM_CLASSIFICATION%TYPE      ;
   lv_process_flag           VARCHAR2(2)                                    ;
   lv_process_message        VARCHAR2(4000)                                 ;
   ln_organization_id        JAI_RGM_REFS_ALL.ORGANIZATION_ID%TYPE          ;
   ln_surcharge_cnt          NUMBER(2)                                := 0  ;
   ld_source_doc_date        RA_CUST_TRX_LINE_GL_DIST_ALL.GL_DATE%TYPE      ;
 BEGIN

   /*########################################################################################################
   || VARIABLES INITIALIZATION - PART -1
   ########################################################################################################*/
   lv_member_name        := 'VALIDATE_INVOICE';
   set_debug_context;

    /*commented by csahoo for bug# 6401388
   jai_cmn_debug_contexts_pkg.register ( pv_context => lv_context  ,
                                pn_reg_id  => ln_reg_id
                              );*/

   lv_process_flag         := jai_constants.successful   ;
   lv_process_message      := null                       ;

   p_process_flag          := lv_process_flag            ;
   p_process_message       := lv_process_message         ;

   /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                       pv_log_msg  =>  ' Validating the Document '||fnd_global.local_chr(10)
                                                     ||', p_ract.trx_number      -> '||p_ract.trx_number  ||fnd_global.local_chr(10)
                                                     ||', p_ract.customer_trx_id -> '||p_ract.customer_trx_id
                                    );*/
   /*########################################################################################################
   || CHECK TCS APPLICABILITY PART -2
   ########################################################################################################*/
    /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                               pv_log_msg  =>  ' Check TCS applicability '
                            );*/
   /*
   || Check whether the TCS is applicable on the document if no
   || do not process
   */
   OPEN  cur_chk_tcs_applicable ( cp_customer_trx_id => p_ract.customer_trx_id );
   FETCH cur_chk_tcs_applicable INTO ld_source_doc_date ,ln_organization_id;
   IF cur_chk_tcs_applicable%NOTFOUND THEN
  /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id  =>  ln_reg_id ,
                                        pv_log_msg  =>  ' TCS taxes not present on Invoice '
                                      );*/
     CLOSE cur_chk_tcs_applicable ;
     /*
     ||Check whether the invoice has been created due to the secondary creation
     || IF yes punch/reset to null, the customer_trx_id into jai_rgm_item_gen_docs.generated_doc_id based on the
     ||complete flag
     */
     /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                         pv_log_msg  =>  'Call to procedure update_item_gen_docs to check whether this is the TCS secondary document'
                                      );*/

     update_item_gen_docs  ( p_trx_number        => p_ract.trx_number      ,
                             p_customer_trx_id   => p_ract.customer_trx_id ,
                             p_complete_flag     => p_ract.complete_flag   ,
                             p_org_id            => p_ract.org_id          ,
                             p_process_flag      => lv_process_flag        ,
                             p_process_message   => lv_process_message
                           );
     /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                         pv_log_msg  =>  'returned from update_item_gen_docs lv_process_flag -> '||fnd_global.local_chr(10)
                                                       ||', lv_process_flag    -> '|| lv_process_flag     || fnd_global.local_chr(10)
                                                       ||', lv_process_message -> '|| lv_process_message  || fnd_global.local_chr(10)
                                      );*/

     /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                         pv_log_msg  =>  'Skip furthur processing as Invoice does not have TCS type of taxes '
                                      );*/

     p_process_flag    := lv_process_flag    ;
     p_process_message := lv_process_message ;

     return;

   END IF;
   CLOSE cur_chk_tcs_applicable ;

    /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                               pv_log_msg  =>  ' Document Parameters '||fnd_global.local_chr(10)
                                              ||', source_doc_date      -> '||ld_source_doc_date  ||fnd_global.local_chr(10)
                                              ||', organization_id-> '||ln_organization_id
                            );*/
   /*########################################################################################################
   || SKIP FOR CM PART -3
   ########################################################################################################*/

   OPEN  cur_get_doc_det   ( cp_cust_trx_type_id => p_ract.cust_trx_type_id );
   FETCH cur_get_doc_det INTO lv_trx_type;
   CLOSE cur_get_doc_det ;

    /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                               pv_log_msg  =>  ' Current document type is '||lv_trx_type
                            );*/
   /*
   || Return if document type is a credit memo
   || as there is no functionality around a Credit Memo Completion/Incompletion
   */
   IF lv_trx_type = 'CM' THEN
    /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                               pv_log_msg  =>  ' Current document is a CM hence SKIP'
                            );*/
     p_process_flag := jai_constants.not_applicable;
     return;
   END IF;

   /*########################################################################################################
   || VALIDATIONS FOR INVOICE COMPLETION PART - 4
   ########################################################################################################*/

   IF ln_event = jai_constants.trx_event_completion THEN

     /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                pv_log_msg  =>  ' Event is -> '||ln_event
                             );*/

     /*########################################################################################################
     || DERIVE DOCUMENT TYPE - PART - 4.1
     ########################################################################################################*/


     IF p_ract.complete_flag = jai_constants.yes THEN

      /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                  pv_log_msg  =>  ' Complete -> '||p_ract.complete_flag
                               );*/

       IF lv_trx_type IN (jai_constants.ar_invoice_type_inv,jai_constants.ar_doc_type_dm) THEN
         /*
         ||Invoice/DM completion
         */
         lv_doc_type := jai_constants.trx_type_inv_comp;
       ELSE
        /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                    pv_log_msg  =>  ' Skip as type -> '||lv_trx_type ||' not applicable for TCS processing '
                                 );*/
         p_process_flag := jai_constants.not_applicable;
         return;
       END IF;

     ELSIF p_ract.complete_flag = jai_constants.no THEN
       /*
       ||
       */
       IF lv_trx_type IN (jai_constants.ar_invoice_type_inv,jai_constants.ar_doc_type_dm) THEN
         /*
         ||Invoice/DM incompletion
         */
         lv_doc_type := jai_constants.trx_type_inv_incomp;
       ELSE
       /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                    pv_log_msg  =>  ' Skip as type -> '||lv_trx_type ||' not applicable for TCS processing '
                                 );*/
         p_process_flag := jai_constants.not_applicable;
         return;
       END IF;
     END IF;


     /*########################################################################################################
     || INVOICE INCOMPLETION VALIDATIONS - PART - 4.2
     ########################################################################################################*/


     /*******
     || Validate that an invoice cannot be incompleted if the TCS
     || for the same has already been settled
     ********/
     IF  lv_trx_type IN ( jai_constants.ar_invoice_type_inv,
                          jai_constants.ar_doc_type_dm
                        )                                   AND
         lv_doc_type  = jai_constants.trx_type_inv_incomp

     THEN                                                                                             -----------------A1
       /*
       ||Trx type is invoice or Debit memo
       */
       OPEN  cur_chk_tcs_settlement ( cp_customer_trx_id => p_ract.customer_trx_id );
       FETCH cur_chk_tcs_settlement INTO ln_exists;
       IF CUR_CHK_TCS_SETTLEMENT%FOUND THEN
         /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                     pv_log_msg  =>  'Error :- Cannot Incomplete the invoice if it has already been settled  '||fnd_global.local_chr(10)
                                                   ||', lv_process_flag     -> '|| lv_process_flag  ||fnd_global.local_chr(10)
                                                   ||', lv_process_message  -> '||lv_process_message
                                  );*/
         p_process_flag    := jai_constants.expected_error;
         p_process_message := 'Cannot incomplete the Invoice/Debit Memo as TCS taxes have already been settled';
         return;
       END IF;
       CLOSE cur_chk_tcs_settlement;
       END IF;                                                                                               -----------------A2
     END IF;


     /*########################################################################################################
     || INVOICE COMPLETION VALIDATIONS - PART - 4.2
     ########################################################################################################*/
     IF  lv_trx_type IN ( jai_constants.ar_invoice_type_inv,
                          jai_constants.ar_doc_type_dm
                        )                                   AND
        lv_doc_type  = jai_constants.trx_type_inv_comp
     THEN                                              -----------------A3
       /****************
       || Event is completion
       || Validate that all lines have TCS type of taxes
       || if no then error out
       *****************/

       OPEN  cur_chk_tcs_for_all_lines ( cp_customer_trx_id => p_ract.customer_trx_id );
       FETCH cur_chk_tcs_for_all_lines INTO ln_exists;
       IF CUR_CHK_TCS_FOR_ALL_LINES%FOUND THEN
         /*
         ||Rows with no TCS type of taxes exists hence error out
         */
         CLOSE cur_chk_tcs_for_all_lines ;
          /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                     pv_log_msg  =>  'Error :- Cannot complete the invoice if some lines have TCS type of tax and some dont '||fnd_global.local_chr(10)
                                                   ||', lv_process_flag     -> '|| lv_process_flag  ||fnd_global.local_chr(10)
                                                   ||', lv_process_message  -> '||lv_process_message
                                  );*/
         p_process_flag    := jai_constants.expected_error;
         p_process_message := 'Cannot complete the Invoice/Debit Memo as some lines of the document do not have TCS type of taxes ';
         return;
         CLOSE cur_chk_tcs_for_all_lines ;
       END IF;

       /*******
       || Validate that the inventory_items for all lines of the invoice should have the same TCS item classification
       ********/
       lv_first_itm_class     := null;
       lv_item_classification := null;
       FOR rec_cur_validate_all_items IN cur_validate_all_items ( cp_customer_trx_id => p_ract.customer_trx_id )
       LOOP

         /*
         ||Get the value for the item classification pertaining to the IO and inventory item combination
         */
         jai_inv_items_pkg.jai_get_attrib (
                                          p_regime_code         => jai_constants.tcs_regime                     ,
                                          p_organization_id     => rec_cur_validate_all_items.organization_id   ,
                                          p_inventory_item_id   => rec_cur_validate_all_items.inventory_item_id ,
                                          p_attribute_code      => jai_constants.rgm_attr_cd_itm_class          ,
                                          p_attribute_value     => lv_item_classification                       ,
                                          p_process_flag        => lv_process_flag                              ,
                                          p_process_msg         => lv_process_message
                                        );

         IF lv_process_flag = jai_constants.expected_error    OR                      ---------A2
            lv_process_flag = jai_constants.unexpected_error
         THEN
           /*
           || As Returned status is an error/not applicable hence:-
           || Set out variables p_process_flag and p_process_message accordingly
           */
           --call to debug package
          /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                      pv_log_msg  =>  'Error In processing of jai_inv_items_pkg.jai_get_attrib'||fnd_global.local_chr(10)
                                                    ||', lv_process_flag     -> '|| lv_process_flag  ||fnd_global.local_chr(10)
                                                    ||', lv_process_message  -> '||lv_process_message
                                   );*/

           p_process_flag    := lv_process_flag    ;
           p_process_message := lv_process_message ;
           return;
         END IF;                                                                      ---------A2

         IF lv_first_itm_class IS NULL THEN
           /*
           ||First time assignment
           */
           lv_first_itm_class := lv_item_classification;
         END IF;

         /*
         ||IF any one of the lines do not match with the item TCS classification of the first line
         || then stop the transaction and throw an error.
         */
         IF nvl(lv_first_itm_class,'$$') <> nvl(lv_item_classification,'###') THEN
           /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                      pv_log_msg  =>  'Error :- Cannot complete as all lines do not belong to the same Item Classification '||fnd_global.local_chr(10)
                                                    ||', lv_process_flag     -> '|| lv_process_flag  ||fnd_global.local_chr(10)
                                                    ||', lv_process_message  -> '||lv_process_message
                                   );*/

           p_process_flag    := jai_constants.expected_error   ;
           p_process_message := 'Cannot complete invoice. All lines should either have the same TCS item classification or none of the line should have TCS type of taxes' ;
           return;
         END IF;

       END LOOP;

     /*########################################################################################################
     || THRESHOLD VALIDATIONS - PART - 4.3
     ########################################################################################################*/

     OPEN  cur_chk_tcs_sur_tax ( cp_customer_trx_id  => p_ract.customer_trx_id );
     FETCH cur_chk_tcs_sur_tax INTO ln_surcharge_cnt;
     CLOSE cur_chk_tcs_sur_tax ;

     OPEN c_get_rgm_attribute (   cp_regime_code           =>   jai_constants.tcs_regime                  ,
                                  cp_attribute_code        =>   jai_constants.rgm_attr_code_org_tan       ,
                                  cp_organization_id       =>   ln_organization_id
                              ) ;
     FETCH c_get_rgm_attribute INTO ln_regime_id, lv_org_tan_no ;
     CLOSE c_get_rgm_attribute;

     jai_rgm_thhold_proc_pkg.get_threshold_slab_id   (
                                                        p_regime_id           =>    ln_regime_id                                               ,
                                                        p_org_tan_no          =>    lv_org_tan_no                                              ,
                                                        p_party_type          =>    jai_constants.party_type_customer                          ,
                                                        p_party_id            =>    nvl(p_ract.ship_to_customer_id,p_ract.bill_to_customer_id) ,
                                                        p_source_trx_date     =>    ld_source_doc_date                                         ,
                                                        p_org_id              =>    p_ract.org_id                                              ,
                                                        p_threshold_slab_id   =>    ln_threshold_slab_id                                       ,
                                                        p_process_flag        =>    lv_process_flag                                            ,
                                                        p_process_message     =>    lv_process_message
                                                    );

     IF lv_process_flag = jai_constants.expected_error    OR                      ---------A2
        lv_process_flag = jai_constants.unexpected_error  OR
        lv_process_flag = jai_constants.not_applicable
     THEN
       /*
       || As Returned status is an error/not applicable hence:-
       || Set out variables p_process_flag and p_process_message accordingly
       */
        --call to debug package
       p_process_flag    := lv_process_flag    ;
       p_process_message := lv_process_message ;
       return;
     END IF;                                                                      ---------A2


     IF ln_threshold_slab_id IS NOT NULL  THEN
       /*
       ||IF threshold level is up and surcharge type of taxes not present
       || on the invoice line then error
       */
       IF ln_surcharge_cnt  = 0 THEN        /* Surcharge does not exist */
         p_process_flag    := jai_constants.expected_error ;
         p_process_message := 'Cannot complete invoice as surcharge is applicable however TCS Surcharge tax is not found on the document' ;
         return;
       END IF;
     ELSE
       /*
       ||IF threshold level is down and surcharge type of taxes are present
       || on the invoice line then error
       */
       IF ln_surcharge_cnt  = 1 THEN        /* Surcharge exist */
         p_process_flag    := jai_constants.expected_error ;
         p_process_message := 'Cannot complete invoice as surcharge is not applicable however TCS Surcharge tax is found on the document' ;
         return;
       END IF;
     END IF;
   END IF;   /*Event is Completion  and document type is invoice or DM*/                           -----------------A3

   p_document_type := lv_doc_type;

   /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                              pv_log_msg  =>  '**************** END OF VALIDATE_INVOICE ****************'
                           );
   jai_cmn_debug_contexts_pkg.deregister (pn_reg_id => ln_reg_id);*/
 END validate_invoice;



PROCEDURE  validate_app_unapp (
                                 p_araa                      IN              AR_RECEIVABLE_APPLICATIONS_ALL%ROWTYPE     ,
                                 p_document_type OUT NOCOPY VARCHAR2                                   ,
                                 p_item_classification       OUT NOCOPY      JAI_RGM_REFS_ALL.ITEM_CLASSIFICATION%TYPE  ,
                                 p_process_flag              OUT NOCOPY      VARCHAR2                                   ,
                                 p_process_message           OUT NOCOPY      VARCHAR2
                              )
AS
  ln_reg_id           NUMBER;
  /*
  || Applied to Document of the receivable application has TCS type of tax.
  */
  CURSOR cur_chk_tcs_applicable (cp_customer_trx_id RA_CUSTOMER_TRX_ALL.CUSTOMER_TRX_ID%TYPE )
  IS
  SELECT
          jrct.organization_id    ,
          jrctl.inventory_item_id ,
          gl_dist.amount
  FROM
          ra_customer_trx_all          rcta    ,
          ra_cust_trx_line_gl_dist_all gl_dist ,
          JAI_AR_TRXS        jrct    ,
          JAI_AR_TRX_LINES  jrctl   ,
          JAI_AR_TRX_TAX_LINES  jrcttl  ,
          JAI_CMN_TAXES_ALL              jtc     ,
          jai_regime_tax_types_v       jrttv
  WHERE
          rcta.complete_flag           =   jai_constants.yes
  AND     rcta.customer_trx_id         =   cp_customer_trx_id
  AND     gl_dist.customer_trx_id      =   rcta.customer_trx_id
  AND     gl_dist.account_class        =   jai_constants.account_class_rec
  AND     gl_dist.latest_rec_flag      =   jai_constants.yes
  AND     rcta.customer_trx_id         =   jrct.customer_trx_id
  AND     jrct.customer_trx_id         =   jrctl.customer_trx_id
  AND     jrctl.customer_trx_line_id   =   jrcttl.link_to_cust_trx_line_id
  AND     jtc.tax_id                   =   jrcttl.tax_id
  AND     jrttv.tax_type               =   jtc.tax_type /* Applied to doc has got TCS type of tax*/
  AND     jrttv.regime_code            =   jai_constants.tcs_regime;

  /*
  ||Get the sign of the Cash receipt document
  */
  CURSOR cur_get_cr_sign (cp_cash_receipt_id JAI_AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE )
  IS
  SELECT
        sign (nvl(amount,0)) app_fr_sign
  FROM
        ar_cash_receipts_all
  WHERE
        cash_receipt_id = cp_cash_receipt_id;

  /*
  ||Get the sign of the Credit Memo document
  */
  CURSOR cur_get_cm_sign (cp_cm_customer_trx_id  RA_CUST_TRX_LINE_GL_DIST_ALL.CUSTOMER_TRX_ID%TYPE )
  IS
  SELECT
        sign(nvl(amount,0)) app_fr_sign
  FROM
        ra_cust_trx_line_gl_dist_all
  WHERE
        account_class    = jai_constants.account_class_rec
  AND   latest_rec_flag  = jai_constants.yes
  AND   customer_trx_id  = cp_cm_customer_trx_id;

  /*
  || Check that the Cash receipt has got TCS type of confirmed taxes
  */
  CURSOR cur_chk_crtcs_applicable ( cp_cash_receipt_id  JAI_AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE )
  IS
  SELECT
           jcra.item_classification,
           acra.amount
  FROM
           ar_cash_receipts_all     acra ,
           jai_ar_cash_receipts_all jcra ,
           jai_cmn_document_taxes   jdt  ,
           jai_regime_tax_types_v   jrttv
  WHERE
           jcra.cash_receipt_id   =   acra.cash_receipt_id
  AND      jcra.cash_receipt_id   =   cp_cash_receipt_id
  AND      jcra.cash_receipt_id   =   jdt.source_doc_id
  AND      jdt.source_table_name  =   jai_constants.jai_cash_rcpts   /* 'JAI_AR_CASH_RECEIPTS_ALL' */
  AND      jcra.confirm_flag      =   jai_constants.yes
  AND      jdt.tax_type           =   jrttv.tax_type /* Applied to doc has got TCS type of tax*/
  AND      jrttv.regime_code      = jai_constants.tcs_regime
  AND      jdt.source_doc_type  = JAI_CONSTANTS.ar_cash;    --added by eric for a bug


  /*
  || Get the application details for the current unapplications from the repository
  */
  CURSOR  cur_chk_parent_rec ( cp_applied_fr_doc_id   JAI_RGM_REFS_ALL.APP_FROM_DOCUMENT_ID%TYPE ,
                               cp_applied_to_doc_id   JAI_RGM_REFS_ALL.APP_TO_DOCUMENT_ID%TYPE
                             )
  IS
  SELECT
        trx_ref_id               ,
        settlement_id
  FROM
        jai_rgm_refs_all
  WHERE
        app_from_document_id = cp_applied_fr_doc_id
  AND   app_to_document_id   = cp_applied_to_doc_id ;

  ln_sign_of_app_fr_doc           NUMBER(3)                                           ;
  ln_sign_of_app                  NUMBER(3)                                           ;
  lv_exists                       VARCHAR2(1)                                         ;
  ln_app_fr_itm_class             JAI_AR_CASH_RECEIPTS_ALL.ITEM_CLASSIFICATION%TYPE   ;
  ln_app_fr_organization_id       JAI_AR_TRXS.ORGANIZATION_ID%TYPE          ;
  ln_app_fr_inventory_item_id     JAI_AR_TRX_LINES.INVENTORY_ITEM_ID%TYPE  ;
  ln_app_fr_amount                RA_CUST_TRX_LINE_GL_DIST_ALL.AMOUNT%TYPE            ;

  ln_app_to_amount                RA_CUST_TRX_LINE_GL_DIST_ALL.AMOUNT%TYPE            ;
  ln_app_to_itm_class             JAI_AR_CASH_RECEIPTS_ALL.ITEM_CLASSIFICATION%TYPE   ;
  ln_app_to_organization_id       JAI_AR_TRXS.ORGANIZATION_ID%TYPE          ;
  ln_app_to_inventory_item_id     JAI_AR_TRX_LINES.INVENTORY_ITEM_ID%TYPE  ;

  lv_app_doc_type                 VARCHAR2(100)                                       ;
  rec_cur_chk_parent_rec          CUR_CHK_PARENT_REC%ROWTYPE                          ;
  lv_process_flag                 VARCHAR2(2)                                         ;
  lv_process_message              VARCHAR2(4000)                                      ;


BEGIN

  /*########################################################################################################
  || VARIABLES INITIALIZATION - PART -1
  ########################################################################################################*/

  lv_member_name        := 'VALIDATE_APP_UNAPP';
  set_debug_context;

 /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.register ( pv_context => lv_context  ,
                               pn_reg_id  => ln_reg_id
                             );*/

  lv_process_flag         := jai_constants.successful   ;
  lv_process_message      := null                       ;

  p_process_flag          := lv_process_flag            ;
  p_process_message       := lv_process_message         ;
  ln_sign_of_app_fr_doc   := null                       ;
  ln_sign_of_app          := sign(nvl(p_araa.amount_applied,0));

   /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                      pv_log_msg  =>  ' Processing the APPLICATION record ' ||fnd_global.local_chr(10)
                                           ||', receivable_application_id -> '  ||p_araa.receivable_application_id    ||fnd_global.local_chr(10)
                                           ||', application_type          -> '  ||p_araa.application_type             ||fnd_global.local_chr(10)
                                           ||', status                    -> '  ||p_araa.status                       ||fnd_global.local_chr(10)
                                           ||', display                   -> '  ||p_araa.display                      ||fnd_global.local_chr(10)
                                           ||', cash_receipt_id           -> '  ||p_araa.cash_receipt_id              ||fnd_global.local_chr(10)
                                           ||', amount_applied            -> '  ||p_araa.amount_applied               ||fnd_global.local_chr(10)
                                           ||', applied_customer_trx_id   -> '  ||p_araa.applied_customer_trx_id
                                    );*/


  /*########################################################################################################
  || CHECK TCS APPLICABILITY ON APPLIED FROM DOCUMENTS AND DERIVE APPLICATION TYPE - PART -2
  ########################################################################################################*/

  IF p_araa.application_type IN  (jai_constants.ar_cash              ,
                                  jai_constants.ar_status_activity
                                 )                                   AND                            -------------A1
     p_araa.cash_receipt_id  IS NOT NULL
  THEN
    /*
    || Application is CASH
    || Check that cash receipt has tcs type of taxes which have been confirmed
    || Exit processing if the same is not found
    */
    /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                        pv_log_msg  =>  ' Checking TCS applicability On applied from documents'
                                      );*/
    OPEN  cur_chk_crtcs_applicable (cp_cash_receipt_id => p_araa.cash_receipt_id );
    FETCH cur_chk_crtcs_applicable INTO ln_app_fr_itm_class, ln_app_fr_amount;

    IF cur_chk_crtcs_applicable%NOTFOUND THEN
     /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                         pv_log_msg  =>  ' Skip As TCS not applicable ON Derived from documents '
                                      );*/
      CLOSE cur_chk_crtcs_applicable;
      p_process_flag := jai_constants.not_applicable ;
      return ;
    ELSE
      /*
      ||Check for ACTIVITY I.E receipt to receipt or receipt to credit memo any other type of application other than Receipt/CM to INV or DM
      */
       /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                           pv_log_msg  =>  'TCS is applicable'
                                          );*/

      IF p_araa.status = jai_constants.ar_status_activity THEN
        /*
        || As current receivable application is an activity indicating a receipt to receipt getting applied to another receipt
        || or Credit Memo hence stop this processing as otherwise this would lead to down stream TCS data corruption.
        */
        /*commented by csahoo for bug# 6401388
        jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                            pv_log_msg  =>  'Cannot apply a RECEIPT to any other document (any of them having TCS applicability) other than a Invoice or Debit Memo'
                                          );*/
        p_process_flag    := jai_constants.expected_error;
        p_process_message := 'Cannot apply a RECEIPT to any other document (any of them having TCS applicability) other than a Invoice or Debit Memo';
        return;

      END IF;
    END IF;

    CLOSE cur_chk_crtcs_applicable;

    /*
    ||Get the sign of the cash receipt
    */
    OPEN  cur_get_cr_sign ( cp_cash_receipt_id  => p_araa.cash_receipt_id );
    FETCH cur_get_cr_sign INTO ln_sign_of_app_fr_doc ;
    CLOSE cur_get_cr_sign;

    /*
    || IF sign of amount field of receivable application is the same as the sign of the cash receipt amount
    || then application is receipt application else it would be receipt un application
    */
    IF ln_sign_of_app = ln_sign_of_app_fr_doc THEN
      lv_app_doc_type := jai_constants.trx_type_rct_app ;  /* Event is 'RECEIPT_APPLICATION' */
    ELSE
      lv_app_doc_type :=  jai_constants.trx_type_rct_unapp ;/* Event is 'RECEIPT_UNAPPLICATION' */
    END IF;


  ELSIF p_araa.application_type  = jai_constants.ar_invoice_type_cm  AND                            -------------A1
        p_araa.customer_trx_id  IS NOT NULL
  THEN
    /*
    ||Application is Credit Memo
    */
    OPEN  cur_chk_tcs_applicable( cp_customer_trx_id => p_araa.customer_trx_id );
    FETCH cur_chk_tcs_applicable INTO  ln_app_fr_organization_id, ln_app_fr_inventory_item_id, ln_app_fr_amount;

     /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                        pv_log_msg  =>  'Application type is '||p_araa.application_type
                                      );*/

    IF CUR_CHK_TCS_APPLICABLE%NOTFOUND THEN
     /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                        pv_log_msg  =>  ' Skip As TCS not applicable ON Derived from documents '
                                      );*/
     CLOSE cur_chk_tcs_applicable;
     p_process_flag := jai_constants.not_applicable ;
     return;
    END IF;
    CLOSE cur_chk_tcs_applicable;

    /*
    ||Get the sign of the Credit Memo
    */
    OPEN  cur_get_cm_sign ( cp_cm_customer_trx_id  =>  p_araa.customer_trx_id ) ;
    FETCH cur_get_cm_sign INTO ln_sign_of_app_fr_doc;
    CLOSE cur_get_cm_sign;

    /*
    || IF sign of amount field of receivable application is the same as the sign of the Credit Memo amount
    || then application is Credit Memo Application else it would be Credit Memo Unapplication
    */
    IF ln_sign_of_app = ln_sign_of_app_fr_doc THEN
      lv_app_doc_type := jai_constants.trx_type_cm_app ;  /* Event is 'CREDIT_MEMO_APPLICATION' */
    ELSE
      lv_app_doc_type := jai_constants.trx_type_cm_unapp ;/* Event is 'CREDIT_MEMO_UNAPPLICATION' */
    END IF;

   /*
    ||Get the value for the item classification pertaining to the IO and inventory item combination
    */
    jai_inv_items_pkg.jai_get_attrib (
                                    p_regime_code         => jai_constants.tcs_regime              ,
                                    p_organization_id     => ln_app_fr_organization_id             ,
                                    p_inventory_item_id   => ln_app_fr_inventory_item_id           ,
                                    p_attribute_code      => jai_constants.rgm_attr_cd_itm_class   ,
                                    p_attribute_value     => ln_app_fr_itm_class                   ,
                                    p_process_flag        => lv_process_flag                       ,
                                    p_process_msg         => lv_process_message
                                  );

    IF lv_process_flag = jai_constants.expected_error    OR                      ---------A2
       lv_process_flag = jai_constants.unexpected_error
    THEN
      /*
      || As Returned status is an error hence:-
      || Set out variables p_process_flag and p_process_message accordingly
      */
      --call to debug package
     /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                        pv_log_msg  =>  ' Error in getting the item attribute'||fnd_global.local_chr(10)
                                        ||', p_process_flag      -> '|| p_process_flag
                                        ||', lv_process_message  -> '|| lv_process_message
                                      );*/
      p_process_flag    := lv_process_flag    ;
      p_process_message := lv_process_message ;
      return;
    END IF;                                                                      ---------A2

  ELSE                                                                -------------A1
     /*
     ||Return in case the scenario is niether CASH nor CM
     */
     /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                        pv_log_msg  =>  ' Skip as scenario is niether CASH nor CM '
                                      );*/
     p_process_flag := jai_constants.not_applicable ;
     return;
  END IF;                                                             -------------A1

  /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                      pv_log_msg  =>  ' Application document type is '||lv_app_doc_type
                                    );*/


  /*########################################################################################################
  || Derive APPLIED TO DOCUMENT VALUES AND CHECK TCS APPLICABILITY ON APPLIED TO DOCUMENTS - PART -3
  ########################################################################################################*/

  /*
  || Check that the applied to document has been completed and has got TCS type of taxes.
  || IF no then return
  */
  OPEN  cur_chk_tcs_applicable( cp_customer_trx_id => p_araa.applied_customer_trx_id );
  FETCH cur_chk_tcs_applicable INTO ln_app_to_organization_id, ln_app_to_inventory_item_id, ln_app_to_amount ;

  IF CUR_CHK_TCS_APPLICABLE%NOTFOUND THEN
   CLOSE cur_chk_tcs_applicable;
   p_process_flag := jai_constants.not_applicable ;
   /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                      pv_log_msg  =>  ' Skip the processing as TCS is not applicable on the transaction'
                                    );*/
   return;
  END IF;
  CLOSE cur_chk_tcs_applicable;

  /*
  ||Get the value for the item classification pertaining to the IO and inventory item combination
  */
  jai_inv_items_pkg.jai_get_attrib (
                                  p_regime_code         => jai_constants.tcs_regime               ,
                                  p_organization_id     => ln_app_to_organization_id              ,
                                  p_inventory_item_id   => ln_app_to_inventory_item_id            ,
                                  p_attribute_code      => jai_constants.rgm_attr_cd_itm_class    ,
                                  p_attribute_value     => ln_app_to_itm_class                    ,
                                  p_process_flag        => lv_process_flag                        ,
                                  p_process_msg         => lv_process_message
                                );

  IF lv_process_flag = jai_constants.expected_error    OR                      ---------A2
     lv_process_flag = jai_constants.unexpected_error
  THEN
    /*
    || As Returned status is an error hence:-
    || Set out variables p_process_flag and p_process_message accordingly
    */
    --call to debug package
     /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                        pv_log_msg  =>  ' Error in getting the item classification '||fnd_global.local_chr(10)
                                        ||', p_process_flag      -> '|| p_process_flag
                                        ||', lv_process_message  -> '|| lv_process_message
                                      );*/
    p_process_flag    := lv_process_flag    ;
    p_process_message := lv_process_message ;
    return;
  END IF;                                                                      ---------A2


  /*########################################################################################################
  || RESTRICTIONS ON APPLICATION - PART -4
  ########################################################################################################*/

  /*
  || All lines of the applied from and to documents should belong to the same item classification.
  || Do not allow a transaction if this rule is not followed.
  */

  IF lv_app_doc_type IN  ( jai_constants.trx_type_rct_app ,
                           jai_constants.trx_type_cm_app
                         )
  THEN
    IF ln_app_fr_itm_class <> ln_app_to_itm_class THEN

     /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                        pv_log_msg  =>  ' Item classification for the application from and to item class do not match hence error '||fnd_global.local_chr(10)
                                        ||', p_process_flag      -> '|| p_process_flag
                                        ||', lv_process_message  -> '|| lv_process_message
                                      );*/
      p_process_flag    := jai_constants.expected_error ;
      p_process_message := 'Application is not allowed as the APPLIED FROM and TO DOCUMENTS have different item classifications.';
      return;
    END IF;
  END IF;

  /*
  ||Do not allow overapplication transactions in case they both have TCS type of taxes
  */
  IF nvl(p_araa.amount_applied,0) >  nvl(ln_app_to_amount,0) THEN
     /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                         pv_log_msg  => 'Case for Overapplication detected , Stop '||fnd_global.local_chr(10)
                                                      ||', p_araa.amount_applied -> '|| p_araa.amount_applied     ||fnd_global.local_chr(10)
                                                      ||', applied to amount     -> '|| ln_app_to_amount          ||fnd_global.local_chr(10)
                                                      ||', p_process_flag        -> '|| p_process_flag            ||fnd_global.local_chr(10)
                                                      ||', lv_process_message    -> '|| lv_process_message
                                      );*/
    p_process_flag    := jai_constants.expected_error ;
    p_process_message := 'Over Application of a document to other is not allowed if both the taxes have TCS type of taxes .';
    return;
  END IF;

  /*
  ||Do not allow a receipt to be applied to another receipt in case both have TCS type of taxes
  */


  /*########################################################################################################
  || RESTRICTIONS ON RECEIPT UNAPPLICATION
  ########################################################################################################*/

  IF lv_app_doc_type = jai_constants.trx_type_rct_unapp THEN
   /*
   ||Validate that the parent receipt application record is present in the repository.
   */
    OPEN cur_chk_parent_rec ( cp_applied_fr_doc_id  => p_araa.cash_receipt_id ,
                              cp_applied_to_doc_id  => p_araa.applied_customer_trx_id
                            );
    FETCH cur_chk_parent_rec INTO rec_cur_chk_parent_rec;

    IF CUR_CHK_PARENT_REC%NOTFOUND THEN
      /*
      ||Exit processing as original application did not hit the repository.
      */
       CLOSE cur_chk_parent_rec;
      /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                           pv_log_msg  => 'Skip,case For unapplication,  Parent transaction record is not present in the repository'||fnd_global.local_chr(10)
                                                        ||', p_process_flag        -> '|| p_process_flag            ||fnd_global.local_chr(10)
                                        );*/

       p_process_flag := jai_constants.not_applicable ;
       return;
    END IF;

    CLOSE cur_chk_parent_rec;

    IF rec_cur_chk_parent_rec.settlement_id is NOT NULL THEN
      /*
      || Original Application already settled hence
      */
       p_process_flag    := jai_constants.expected_error ;
       p_process_message := 'Parent application has already been settled. hence cannot unapply';
       /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                          pv_log_msg  =>  ' Error :-Parent application has already been settled. hence cannot unapply'||fnd_global.local_chr(10)
                                          ||', p_process_flag      -> '|| p_process_flag
                                          ||', lv_process_message  -> '|| lv_process_message
                                        );*/

       return;
    END IF;

  END IF;


  /*########################################################################################################
  || RESTRICTIONS ON CREDIT MEMO UNAPPLICATION
  ########################################################################################################*/

  IF lv_app_doc_type = jai_constants.trx_type_cm_unapp THEN
    /*
    ||Validate that the parent credit memo application record is present in the repository.
    */
    OPEN cur_chk_parent_rec ( cp_applied_fr_doc_id  => p_araa.customer_trx_id         ,
                              cp_applied_to_doc_id  => p_araa.applied_customer_trx_id
                            );
    FETCH cur_chk_parent_rec INTO rec_cur_chk_parent_rec;
    IF CUR_CHK_PARENT_REC%NOTFOUND THEN
      /*
      ||Exit processing as original application did not hit the repository.
      */
     /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                        pv_log_msg  =>  ' Skip the processing as TCS is not applicable on the transaction'||fnd_global.local_chr(10)
                                        ||', p_process_flag      -> '|| p_process_flag
                                      );*/
       CLOSE cur_chk_parent_rec;
       p_process_flag := jai_constants.not_applicable ;
       return;
    END IF;

    CLOSE cur_chk_parent_rec;

    IF rec_cur_chk_parent_rec.settlement_id is NOT NULL THEN
      /*
      || Original Application already settled hence
      */
       /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                          pv_log_msg  =>  ' Error :-Parent application has already been settled. hence cannot unapply'||fnd_global.local_chr(10)
                                          ||', p_process_flag      -> '|| p_process_flag
                                          ||', lv_process_message  -> '|| lv_process_message
                                        );*/
       p_process_flag := jai_constants.expected_error ;
       p_process_message := 'Parent application has already been settled. hence cannot unapply';
       return;
    END IF;
  END IF;


  /*########################################################################################################
  || Assign values to return variables
  ########################################################################################################*/

  p_document_type       := lv_app_doc_type        ;
  p_item_classification := ln_app_to_itm_class    ;

  /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                             pv_log_msg  =>  '**************** PROCEDURE VALIDATE_APP_UNAPP SUCCESSFUL ****************'
                          );

  jai_cmn_debug_contexts_pkg.deregister (pn_reg_id => ln_reg_id);*/

END validate_app_unapp;

PROCEDURE validate_receipts  (  p_acra             IN            AR_CASH_RECEIPTS_ALL%ROWTYPE  ,
                                p_document_type    IN           VARCHAR2                      ,
                                p_process_flag     OUT NOCOPY    VARCHAR2                     ,
                                p_process_message  OUT NOCOPY    VARCHAR2
                                               )
IS
  ln_reg_id                 NUMBER;
  lv_process_flag           VARCHAR2(2)                               ;
  lv_process_message        VARCHAR2(2000)                            ;

  /*
  || Check that the document has has TCS type of tax.
  */
  CURSOR cur_chk_tcs_applicable (cp_cash_receipt_id JAI_AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE )
  IS
  SELECT
          1
  FROM
          jai_ar_cash_receipts_all  jcra   ,
          jai_cmn_document_taxes    jdt    ,
          jai_regime_tax_types_v    jrttv
  WHERE
          jcra.cash_receipt_id         =   cp_cash_receipt_id
  AND     jcra.cash_receipt_id         =   jdt.source_doc_id
  AND     jdt.tax_type                 =   jrttv.tax_type  /* Applied to doc has got TCS type of tax*/
  AND     jrttv.regime_code            =   jai_constants.tcs_regime
  AND     jcra.confirm_flag            =   jai_constants.yes
  AND     jdt.source_doc_type  = JAI_CONSTANTS.ar_cash;    --added by eric for a bug

 /*
 ||Get the last record pertaining to the cash receipt confirmation
 */
 CURSOR cur_chk_tcs_settlement ( cp_source_document_id   jai_rgm_refs_all.source_document_id%TYPE   ,
                                 cp_source_document_type jai_rgm_refs_all.source_document_type%TYPE
                               )
  IS
 SELECT
        trx_ref_id        ,
        settlement_id
  FROM
        jai_rgm_refs_all a
  WHERE
        trx_ref_id   =  ( SELECT
                                 max(trx_ref_id)
                          FROM
                                 jai_rgm_refs_all b
                          WHERE
                                 b.source_document_id   = cp_source_document_id
                          AND    b.source_document_type = cp_source_document_type
                        );

  ln_exists                        NUMBER(2)                           ;
  ln_settlement_id                 JAI_RGM_REFS_ALL.SETTLEMENT_ID%TYPE ;
  rec_cur_chk_tcs_settlement       CUR_CHK_TCS_SETTLEMENT%ROWTYPE      ;
BEGIN

  /*########################################################################################################
  || VARIABLES INITIALIZATION
  ########################################################################################################*/

  lv_member_name        := 'VALIDATE_RECEIPTS';
  set_debug_context;
  /*commented by csahoo for bug# 6401388
  jai_cmn_debug_contexts_pkg.register ( pv_context => lv_context
                             , pn_reg_id  => ln_reg_id
                             ); --commmented by CSahoo, BUG#5631784


  /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                             pv_log_msg  =>  ' PARAMETERS VALUES PASSED TO VALIDATE_RECEIPTS : - '   ||fnd_global.local_chr(10)
                                           ||', p_acra.receipt_number  -> '||p_acra.receipt_number   ||fnd_global.local_chr(10)
                                           ||', p_acra.cash_receipt_id -> '||p_acra.cash_receipt_id  ||fnd_global.local_chr(10)
                                           ||', p_acra.amount          -> '||p_acra.amount           ||fnd_global.local_chr(10)
                                           ||', p_acra.type            -> '||p_acra.type             ||fnd_global.local_chr(10)
                          );*/

  lv_process_flag       := jai_constants.successful   ;
  lv_process_message    := null                       ;

  p_process_flag        := lv_process_flag            ;
  p_process_message     := lv_process_message         ;


  /*########################################################################################################
  || CHECK TCS APPLICABILITY PART -2
  ########################################################################################################*/
   /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                               pv_log_msg  =>  ' Check TCS applicability '
                            );*/
  /*
  || Check whether the TCS is applicable on the document if no
  || do not process
  */
  OPEN  cur_chk_tcs_applicable ( cp_cash_receipt_id => p_acra.cash_receipt_id );
  FETCH cur_chk_tcs_applicable INTO ln_exists;
  IF cur_chk_tcs_applicable%NOTFOUND THEN
    CLOSE cur_chk_tcs_applicable ;
    p_process_flag := jai_constants.not_applicable;
   return;
  END IF;
  CLOSE cur_chk_tcs_applicable ;

  /*########################################################################################################
  || VALIDATIONS FOR RECEIPT REVERSAL
  ########################################################################################################*/

  IF p_document_type = jai_constants.trx_type_rct_rvs THEN  /* 'RECEIPT_REVERSAL' */
    /*
    || Check that an original record with cash receipt confirmation exists in the repository.
    || In case it does not exist, then error out the record as it need not hit the repository
    || If it exists then check whether it has been settled . If yes then throw an error
    */
   /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                               pv_log_msg  =>  'Validate for Receipt Reversal '
                            );*/
    OPEN  cur_chk_tcs_settlement ( cp_source_document_id   =>  p_acra.cash_receipt_id                 ,
                                   cp_source_document_type =>  jai_constants.ar_cash_tax_confirmed
                                 );
    FETCH cur_chk_tcs_settlement INTO rec_cur_chk_tcs_settlement;
    IF CUR_CHK_TCS_SETTLEMENT%NOTFOUND THEN
      /*
      ||Original receipt not found in repository hence throw an error
      */
      /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                  pv_log_msg  =>  'Original Receipt Confirmation records does not exists in the repository. Cannot reverse receipt'
                               );*/
      CLOSE cur_chk_tcs_settlement;
      p_process_flag    := jai_constants.expected_error;
      p_process_message := 'Cannot reverse the receipt as the receipt confirmation record does not exists in the repository ';
      return;
    ELSE
      /*
      ||Check whether the TCS tax has been settled.
      */
      IF rec_cur_chk_tcs_settlement.settlement_id IS NOT NULL THEN
        /*
        || TCS taxes pertaining to the receipt have already been settled
        || Cannot allow receipt to be reversed.
        */
        /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                    pv_log_msg  =>  ' TCS On the original confirmed receipt has been settled. CAnnot reverse the receipt'
                                 );*/
        p_process_flag    := jai_constants.expected_error;
        p_process_message := 'Cannot reverse the receipt as the tcs taxes pertaining to the receipt have been confirmed ';
        return;
      END IF;
    END IF;
    CLOSE cur_chk_tcs_settlement;
  END IF; /* Receipt reversal */

  /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                             pv_log_msg  =>  '**************** END OF VALIDATE_RECEIPTS ****************'
                          );

  jai_cmn_debug_contexts_pkg.deregister (pn_reg_id => ln_reg_id);*/
END validate_receipts;

PROCEDURE process_invoices   (   p_ract             IN             RA_CUSTOMER_TRX_ALL%ROWTYPE               ,
                                 p_document_type                   VARCHAR2                                  ,
                                 p_process_flag     OUT NOCOPY     VARCHAR2                                  ,
                                 p_process_message  OUT NOCOPY     VARCHAR2
                               )
  IS

    ln_reg_id           NUMBER;
    /*****
    ||Get the line invoice_total amount
    *****/
    CURSOR cur_get_inv_amt_date
    IS
    SELECT
      -- nvl(acctd_amount,0)  total_invoice_amount ,  --deleted by eric for inclusive tax
      --NVL(jatl.total_amount,0) total_invoice_amount , --added by eric for inclusive tax on 26-dec,2007
      NVL(jatl.line_amount,0) total_invoice_amount , --added by Jia Li for inclusive tax on 2008-01-18
      rct.gl_date
    FROM
      ra_cust_trx_line_gl_dist_all rct
    , jai_ar_trx_lines             jatl                     --added by eric for inclusive tax
    WHERE   jatl.customer_trx_id  =  rct.customer_trx_id    --added by eric for inclusive tax
      AND   rct.customer_trx_id   =  p_ract.customer_trx_id
      AND   rct.account_class     =  jai_constants.account_class_rec
      AND   rct.latest_rec_flag   =  jai_constants.yes;

    -- Added by Jia Li for inclusive taxes on 2008-01-18
    ----------------------------------------------------------------
    CURSOR cur_get_inv_exclu_amt
    IS
      SELECT
        SUM(a.func_tax_amount)
      FROM
        jai_ar_trx_tax_lines a
      , jai_cmn_taxes_all b
      WHERE  link_to_cust_trx_line_id IN
        ( SELECT
            customer_trx_line_id
          FROM
            jai_ar_trx_lines
          WHERE customer_trx_id = p_ract.customer_trx_id )
        AND a.tax_id = b.tax_id
        AND NVL(b.inclusive_tax_flag,'N') = 'N';
    ln_total_inv_exclu_amt  jai_ar_trx_tax_lines.func_tax_amount%TYPE;
    ------------------------------------------------------------------

    /*****
    || Get the invoice line details
    *****/
    CURSOR cur_get_inv_line_det
    IS
    SELECT
           rctla.customer_trx_line_id           ,
           jrct.organization_id                 ,
           rctla.extended_amount   line_amount  ,
           rctla.inventory_item_id
    FROM
           JAI_AR_TRXS        jrct ,
           ra_customer_trx_lines_all    rctla
    WHERE
          jrct.customer_trx_id  = rctla.customer_trx_id
    AND   jrct.customer_trx_id  = p_ract.customer_trx_id
    AND   rctla.customer_trx_id = rctla.customer_trx_id
    AND   rctla.line_type       = 'LINE';

    /*****
    ||Get the Invoice tax details
    ******/
    CURSOR cur_get_inv_taxes (cp_customer_trx_line_id JAI_AR_TRX_LINES.CUSTOMER_TRX_LINE_ID%TYPE )
    IS
    SELECT
           jrcttl.customer_trx_line_id ,
           jrcttl.tax_id               ,
           jrcttl.tax_rate             ,
           jtc.tax_type                ,
           jrcttl.tax_amount           ,
           jrcttl.func_tax_amount
    FROM
           JAI_AR_TRX_TAX_LINES jrcttl ,
           JAI_CMN_TAXES_ALL             jtc    ,
           jai_regime_tax_types_v      jrttv
    WHERE
           jrcttl.link_to_cust_trx_line_id  = cp_customer_trx_line_id
    AND    jrcttl.tax_id                    = jtc.tax_id
    AND    jrttv.tax_type                   = jtc.tax_type
    AND    jrttv.regime_code                = jai_constants.tcs_regime;

    CURSOR cur_get_no_of_rows
    IS
    SELECT
          count(*) no_of_rows
    FROM
          JAI_AR_TRX_LINES
    WHERE
         customer_trx_id = p_ract.customer_trx_id ;

    ln_row_count              NUMBER(3)                                  ;
    ln_line_counter           NUMBER(3) := 0                             ;
    ln_last_line_flag         VARCHAR2(1) := jai_constants.no            ;
    lv_process_flag           VARCHAR2(2)                                ;
    lv_process_message        VARCHAR2(2000)                             ;
    lv_document_type          VARCHAR2(100)                              ;
    ln_trx_ref_id             JAI_RGM_REFS_ALL.TRX_REF_ID%TYPE           ;
    ln_apportion_factor       NUMBER(3)                                  ;
    lv_item_classification    JAI_RGM_REFS_ALL.ITEM_CLASSIFICATION%TYPE  ;
    ln_total_inv_amount       RA_CUST_TRX_LINE_GL_DIST_ALL.AMOUNT%TYPE   ;
    ld_document_date          JAI_RGM_REFS_ALL.SOURCE_DOCUMENT_DATE%TYPE ;
  BEGIN
    /*########################################################################################################
    || VARIABLES INITIALIZATION
    ########################################################################################################*/

    lv_member_name        := 'PROCESS_INVOICES';
    set_debug_context;
    /*commented by csahoo for bug# 6401388
   jai_cmn_debug_contexts_pkg.register ( pv_context => lv_context
                               , pn_reg_id  => ln_reg_id
                               );*/

    lv_process_flag       := jai_constants.successful   ;
    lv_process_message    := null                       ;

    p_process_flag        := lv_process_flag            ;
    p_process_message     := lv_process_message         ;
    ln_apportion_factor   := 1                          ;

    /******
    ||Check that the document is of type
    ||Confirmed cash receipt
    *******/

    IF p_document_type IN ( jai_constants.trx_type_inv_comp   ,
                            jai_constants.trx_type_inv_incomp
                          )
    THEN            ---------A1
      /*########################################################################################################
      || DERIVE VALUES AND INSERT COMPLETED INVOICES INTO JAI_RGM_TRX_REFS_ALL TABLE  ---- PART -1
      ########################################################################################################*/

      /*
      ||Get the receivable amount which is the would be the total invoice amount
      */
      OPEN  cur_get_inv_amt_date ;
      FETCH cur_get_inv_amt_date INTO ln_total_inv_amount,ld_document_date;
      CLOSE cur_get_inv_amt_date;

      -- Added by Jia Li for inclusive taxes on 2008-01-18
      ---------------------------------------------------------------------
      OPEN cur_get_inv_exclu_amt;
      FETCH cur_get_inv_exclu_amt INTO ln_total_inv_exclu_amt;
      CLOSE cur_get_inv_exclu_amt;

      ln_total_inv_amount := ln_total_inv_amount + ln_total_inv_exclu_amt;
      ----------------------------------------------------------------------

      IF p_document_type = jai_constants.trx_type_inv_incomp THEN
        /*
        ||Reverse the sign of the amount if the invoice is gettin incompleted.
        */
        ln_total_inv_amount := ln_total_inv_amount * (-1);
      END IF;

      /*
      || Loop through each line and fetch its details
      || At this point of time it needs not be checked that a line has TCS type of taxes as it has been already validated in
      || the validate_process procedure
      */
      FOR rec_cur_get_inv_line_det IN cur_get_inv_line_det
      LOOP
        /*
        ||Get the value for the item classification pertaining to the IO and inventory item combination
        */
        jai_inv_items_pkg.jai_get_attrib (
                                        p_regime_code         => jai_constants.tcs_regime                   ,
                                        p_organization_id     => rec_cur_get_inv_line_det.organization_id   ,
                                        p_inventory_item_id   => rec_cur_get_inv_line_det.inventory_item_id ,
                                        p_attribute_code      => jai_constants.rgm_attr_cd_itm_class        ,
                                        p_attribute_value     => lv_item_classification                     ,
                                        p_process_flag        => lv_process_flag                            ,
                                        p_process_msg         => lv_process_message
                                      );


        IF lv_process_flag = jai_constants.expected_error    OR                      ---------A2
           lv_process_flag = jai_constants.unexpected_error
        THEN
          /*
          || As Returned status is an error/not applicable hence:-
          || Set out variables p_process_flag and p_process_message accordingly
        */
          --call to debug package
          p_process_flag    := lv_process_flag    ;
          p_process_message := lv_process_message ;
          return;
        END IF;                                                                      ---------A2

        IF p_document_type = jai_constants.trx_type_inv_incomp THEN
          /*
          ||Reverse the sign of the amount if the invoice is getting incompleted.
          */
          rec_cur_get_inv_line_det.line_amount  := rec_cur_get_inv_line_det.line_amount * (-1);
        END IF;

        /*
        ||Get the sequence generated unique key for the transaction
        */
        OPEN  cur_get_transaction_id ;
        FETCH cur_get_transaction_id INTO ln_transaction_id ;
        CLOSE cur_get_transaction_id ;

        /*
        ||Insert into the repository.
        */
        insert_repository_references (
                                        p_regime_id                   =>   NULL                                                                    ,
                                        p_transaction_id              =>   ln_transaction_id                                                       ,
                                        p_source_ref_document_id      =>   p_ract.customer_trx_id                                                  ,
                                        p_source_ref_document_type    =>   p_document_type                                                         ,
                                        p_app_from_document_id        =>   NULL                                                                    ,
                                        p_app_from_document_type      =>   NULL                                                                    ,
                                        p_app_to_document_id          =>   NULL                                                                    ,
                                        p_app_to_document_type        =>   NULL                                                                    ,
                                        p_parent_transaction_id       =>   NULL                                                                    ,
                                        p_org_tan_no                  =>   NULL                                                                    ,
                                        p_document_id                 =>   p_ract.customer_trx_id                                                  ,
                                        p_document_type               =>   p_document_type                                                         ,
                                        p_document_line_id            =>   rec_cur_get_inv_line_det.customer_trx_line_id                           ,
                                        p_document_date               =>   ld_document_date                                                        ,
                                        p_table_name                  =>   jai_constants.ar_inv_lines_table                                        ,
                                        p_line_amount                 =>   rec_cur_get_inv_line_det.line_amount * nvl( p_ract.exchange_rate , 1 )  ,
                                        p_document_amount             =>   ln_total_inv_amount                                                     ,
                                        p_org_id                      =>   p_ract.org_id                                                           ,
                                        p_organization_id             =>   rec_cur_get_inv_line_det.organization_id                                ,
                                        p_party_id                    =>   nvl(p_ract.bill_to_customer_id,p_ract.ship_to_customer_id)              ,
                                        p_party_site_id               =>   nvl(p_ract.bill_to_site_use_id,p_ract.ship_to_site_use_id)              ,
                                        p_item_classification         =>   lv_item_classification                                                  ,
                                        p_trx_ref_id                  =>   ln_trx_ref_id                                                           ,
                                        p_process_flag                =>   lv_process_flag                                                         ,
                                        p_process_message             =>   lv_process_message
                                    );

        IF lv_process_flag = jai_constants.expected_error    OR                      ---------A2
           lv_process_flag = jai_constants.unexpected_error
        THEN
          /*
          || As Returned status is an error/not applicable hence:-
          || Set out variables p_process_flag and p_process_message accordingly
          */
          --call to debug package
          p_process_flag    := lv_process_flag    ;
          p_process_message := lv_process_message ;
          return;
        END IF;                                                                      ---------A2

        /*########################################################################################################
        || INSERT INVOICE TAXES INTO JAI_RGM_TAXES TABLE  ---- PART -2
        ########################################################################################################*/

        IF p_document_type = jai_constants.trx_type_inv_incomp THEN
          /*
          ||Reverse the sign of the amount if the invoice is getting incompleted.
          */
          ln_apportion_factor  := -1;
        END IF;
        /*
        || Copy the taxes from the invoice/DM transaction to the TCS tax repository
        */
        copy_taxes_from_source  ( p_source_document_type      =>  p_document_type                                 ,
                                  p_source_document_id        =>  p_ract.customer_trx_id                          ,
                                  p_source_document_line_id   =>  rec_cur_get_inv_line_det.customer_trx_line_id   ,
                                  p_apportion_factor          =>  ln_apportion_factor                             ,
                                  p_trx_ref_id                =>  ln_trx_ref_id                                   ,
                                  p_process_flag              =>  lv_process_flag                                 ,
                                  p_process_message           =>  lv_process_message
                                );

        IF lv_process_flag = jai_constants.expected_error    OR                      ---------A2
           lv_process_flag = jai_constants.unexpected_error  OR
           lv_process_flag = jai_constants.not_applicable
        THEN
          /*
          || As Returned status is an error/not applicable hence:-
          || Set out variables p_process_flag and p_process_message accordingly
          */
          --call to debug package
          p_process_flag    := lv_process_flag    ;
          p_process_message := lv_process_message ;
          return;
        END IF;                                                                      ---------A2

      END LOOP;   /*End loop for invoice lines */

    END IF; /* Invoice completion / Incompletion*/

  /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                             pv_log_msg  =>  '**************** END OF PROCESS_INVOICES ****************'
                          );
    jai_cmn_debug_contexts_pkg.deregister (pn_reg_id => ln_reg_id);*/
  END process_invoices;


  procedure  process_receipts        (  p_acra                            AR_CASH_RECEIPTS_ALL%ROWTYPE      ,
                                        p_document_type                   VARCHAR2                          ,
                                        p_process_flag    OUT NOCOPY      VARCHAR2                          ,
                                        p_process_message OUT NOCOPY      VARCHAR2
                                     )
  IS
     ln_reg_id           NUMBER;
    /*****
    || Get the details of the cash_receipts
    *****/
    CURSOR cur_get_cr_details ( cp_cash_receipt_id JAI_AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE )
    IS
    SELECT
            jcra.customer_id          ,
            jcra.organization_id      ,
            jcra.gl_date              ,
            jcra.item_classification
    FROM
            jai_ar_cash_receipts_all    jcra
    WHERE
            jcra.cash_receipt_id      = cp_cash_receipt_id ;

    /*****
    ||Get the receipt tax details
    *****/
    CURSOR cur_get_rcpt_taxes
    IS
    SELECT
           jdt.tax_id                         ,
           jdt.tax_rate                       ,
           jtc.tax_type                       ,
           jdt.tax_amt                        ,
           jdt.func_tax_amt
    FROM
           jai_cmn_document_taxes     jdt     ,
           JAI_CMN_TAXES_ALL            jtc     ,
           jai_regime_tax_types_v     jrttv
    WHERE
           jdt.tax_id        = jtc.tax_id
    AND    jtc.tax_type      = jrttv.tax_type
    AND    jdt.source_doc_id = p_acra.cash_receipt_id
    AND    jrttv.regime_code = jai_constants.tcs_regime
    AND    jdt.source_doc_type  = JAI_CONSTANTS.ar_cash;    --added by eric for a bug

    /*****
    || Get all the applications for which Cash Receipt has got TCS type of taxes
    || and the corresponding invoice also have got TCS type of tax.
    || Unapplications needs not be considered as there applications also would not have gone
    *****/
    CURSOR cur_get_ar_rec_app_all  (cp_cash_receipt_id AR_RECEIVABLE_APPLICATIONS_ALL.CASH_RECEIPT_ID%TYPE)
    IS
    SELECT
           ra.*
    FROM
           ar_receivable_applications_all ra    ,
           jai_ar_cash_receipts_all   jcra
    WHERE
           ra.cash_receipt_id   = jcra.cash_receipt_id
    AND    ra.cash_receipt_id   = cp_cash_receipt_id
    AND    ra.status            = 'APP'
    AND    ra.application_type  = 'CASH'
    AND    ra.display           = jai_constants.yes
    AND    jcra.confirm_flag    = jai_constants.yes
    AND    exists  ( SELECT     /* TCS type of taxes exist for the receipt */
                            1
                     FROM
                            jai_cmn_document_taxes   jdt  ,
                            jai_regime_tax_types_v   jrttv
                     WHERE
                            jdt.source_doc_id     = jcra.cash_receipt_id
                     AND    jdt.source_table_name = jai_constants.jai_cash_rcpts /* 'JAI_AR_CASH_RECEIPTS_ALL' */
                     AND    jdt.tax_type          = jrttv.tax_type
                     AND    jrttv.regime_code     = jai_constants.tcs_regime
                     AND    jdt.source_doc_type  = JAI_CONSTANTS.ar_cash     --added by eric for a bug
                  )
    AND    exists ( SELECT    /* TCS type of taxes exist for the corresponding Invoice */
                            1
                    FROM
                            JAI_AR_TRX_LINES     jrctl ,
                            JAI_AR_TRX_TAX_LINES     jrcttl,
                            JAI_CMN_TAXES_ALL                 jtc   ,
                            jai_regime_tax_types_v          jrttv
                    WHERE
                            jrctl.customer_trx_id       = ra.applied_customer_trx_id
                    AND     jrctl.customer_trx_line_id  = jrcttl.link_to_cust_trx_line_id
                    AND     jrcttl.tax_id               = jtc.tax_id
                    AND     jtc.tax_type                = jrttv.tax_type
                    AND     jrttv.regime_code           = jai_constants.tcs_regime
                  );

    /********
    || Get the details of the source receipt
    || from the repository
    ********/
    CURSOR cur_copy_src_rcpt (cp_source_document_id JAI_RGM_REFS_ALL.SOURCE_DOCUMENT_ID%TYPE)
    IS
    SELECT
            *
    FROM
            jai_rgm_refs_all
    WHERE
            source_document_id = cp_source_document_id;

    /********
    || Get the details of the source receipt taxes
    || from the repository
    ********/
    CURSOR cur_copy_tax_rcpt_rev ( cp_trx_ref_id JAI_RGM_REFS_ALL.TRX_REF_ID%TYPE )
    IS
    SELECT
          *
    FROM
          jai_rgm_taxes
    WHERE
          trx_ref_id = cp_trx_ref_id;

    p_araa                    AR_RECEIVABLE_APPLICATIONS_ALL%ROWTYPE      ;
    rec_cur_get_cr_details    CUR_GET_CR_DETAILS%ROWTYPE                  ;
    rec_cur_copy_src_rcpt     CUR_COPY_SRC_RCPT%ROWTYPE                   ;
    ln_rcpt_amount            JAI_RGM_REFS_ALL.SOURCE_DOCUMENT_AMT%TYPE   ;
    lv_process_flag           VARCHAR2(2)                                 ;
    lv_process_message        VARCHAR2(2000)                              ;
    lv_document_type          VARCHAR2(100)                               ;
    ln_trx_ref_id             JAI_RGM_REFS_ALL.TRX_REF_ID%TYPE            ;
    ln_apportion_factor       NUMBER(3)                                   ;
    ln_local_transaction_id   JAI_RGM_REFS_ALL.TRANSACTION_ID%TYPE        ;
    ln_parent_transaction_id  JAI_RGM_REFS_ALL.PARENT_TRANSACTION_ID%TYPE ;

  BEGIN

    /*########################################################################################################
    || VARIABLES INITIALIZATION
    ########################################################################################################*/
    lv_member_name        := 'PROCESS_RECEIPTS';
    set_debug_context;
    /*commented by csahoo for bug# 6401388
    jai_cmn_debug_contexts_pkg.register ( pv_context => lv_context
                               , pn_reg_id  => ln_reg_id
                               );*/

    lv_process_flag       := jai_constants.successful                      ;
    lv_process_message    := null                                          ;

    p_process_flag        := lv_process_flag                               ;
    p_process_message     := lv_process_message                            ;

    ln_rcpt_amount        := p_acra.amount * nvl(p_acra.exchange_rate ,1 ) ;
    ln_apportion_factor   := 1                                             ;

    /******
    ||Check that the document is of type
    ||Confirmed cash receipt

    *******/

    IF p_document_type = jai_constants.ar_cash_tax_confirmed  THEN            ---------C1
      /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                 pv_log_msg  =>  ' Confirmation processing for the receipts with the following details'||fnd_global.local_chr(10)
                                              ||', p_acra.receipt_number ->  '||p_acra.receipt_number   ||fnd_global.local_chr(10)
                                              ||', p_acra.cash_receipt_id -> '||p_acra.cash_receipt_id  ||fnd_global.local_chr(10)
                                              ||', p_acra.amount          -> '||p_acra.amount          ||fnd_global.local_chr(10)
                                              ||', p_acra.type            -> '||p_acra.type
                             );*/
      OPEN  cur_get_cr_details ( cp_cash_receipt_id => p_acra.cash_receipt_id );
      FETCH cur_get_cr_details INTO rec_cur_get_cr_details;
      CLOSE cur_get_cr_details;

      /*########################################################################################################
      || INSERT CASH RECEIPTS INTO JAI_RGM_TRX_REFS_ALL TABLE  ---- PART -1
      ########################################################################################################*/

      /*
      ||Get the sequence generated unique key for the transaction
      */
      OPEN  cur_get_transaction_id ;
      FETCH cur_get_transaction_id INTO ln_transaction_id ;
      CLOSE cur_get_transaction_id ;

      ln_local_transaction_id := ln_transaction_id;

     /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                          pv_log_msg  =>  ' Before call to insert_repository_references '
                                      );*/

      insert_repository_references (
                                      p_regime_id                 =>   NULL                                           ,
                                      p_transaction_id            =>   ln_transaction_id                              ,
                                      p_source_ref_document_id    =>   p_acra.cash_receipt_id                         ,
                                      p_source_ref_document_type  =>   p_document_type                                ,
                                      p_app_from_document_id      =>   NULL                                           ,
                                      p_app_from_document_type    =>   NULL                                           ,
                                      p_app_to_document_id        =>   NULL                                           ,
                                      p_app_to_document_type      =>   NULL                                           ,
                                      p_parent_transaction_id     =>   NULL                                           ,
                                      p_org_tan_no                =>   NULL                                           ,
                                      p_document_id               =>   p_acra.cash_receipt_id                         ,
                                      p_document_type             =>   p_document_type                                ,
                                      p_document_line_id          =>   p_acra.cash_receipt_id                         ,
                                      p_document_date             =>   rec_cur_get_cr_details.gl_date                 ,
                                      p_table_name                =>   jai_constants.jai_cash_rcpts                   ,
                                      p_line_amount               =>   ln_rcpt_amount                                 ,
                                      p_document_amount           =>   ln_rcpt_amount                                 ,
                                      p_org_id                    =>   p_acra.org_id                                  ,
                                      p_organization_id           =>   rec_cur_get_cr_details.organization_id         ,
                                      p_party_id                  =>   rec_cur_get_cr_details.customer_id             ,
                                      p_party_site_id             =>   p_acra.customer_site_use_id                    ,
                                      p_item_classification       =>   rec_cur_get_cr_details.item_classification     ,
                                      p_trx_ref_id                =>   ln_trx_ref_id                                  ,
                                      p_process_flag              =>   lv_process_flag                                ,
                                      p_process_message           =>   lv_process_message
                                  );

     /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                 pv_log_msg  =>  ' Return from insert_repository_references '
                           );*/

      IF lv_process_flag = jai_constants.expected_error    OR                      ---------A2
         lv_process_flag = jai_constants.unexpected_error  OR
         lv_process_flag = jai_constants.not_applicable
      THEN
        /*
        || As Returned status is an error/not applicable hence:-
        || Set out variables p_process_flag and p_process_message accordingly
        */
        --call to debug package
         /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                    pv_log_msg  =>  ' Error : - lv_process_flag -> '||lv_process_flag||' - '||lv_process_message
                                 );*/

        p_process_flag    := lv_process_flag    ;
        p_process_message := lv_process_message ;
        return;
      END IF;                                                                      ---------A2


      /*########################################################################################################
      || INSERT CASH RECEIPTS INTO JAI_RGM_TAXES TABLE  ---- PART -2
      ########################################################################################################*/

      /*
      || Copy the taxes from the invoice/DM transaction to the TCS tax repository
      */
      /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                 pv_log_msg  =>  ' Before call to copy_taxes_from_source '
                              );*/

      copy_taxes_from_source  ( p_source_document_type      =>  p_document_type         ,
                                p_source_document_id        =>  p_acra.cash_receipt_id  ,
                                p_apportion_factor          =>  ln_apportion_factor     ,
                                p_trx_ref_id                =>  ln_trx_ref_id           ,
                                p_process_flag              =>  lv_process_flag         ,
                                p_process_message           =>  lv_process_message
                              );
      /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                          pv_log_msg  =>  ' Return from copy_taxes_from_source '
                                       );*/
      IF lv_process_flag = jai_constants.expected_error    OR                      ---------A2
         lv_process_flag = jai_constants.unexpected_error  OR
         lv_process_flag = jai_constants.not_applicable
      THEN
        /*
        || As Returned status is an error/not applicable hence:-
        || Set out variables p_process_flag and p_process_message accordingly
        */
        --call to debug package
        /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                   pv_log_msg  =>  ' Error : - lv_process_flag -> '||lv_process_flag||' - '||lv_process_message
                                );*/

        p_process_flag    := lv_process_flag    ;
        p_process_message := lv_process_message ;
        return;
      END IF;

      /*########################################################################################################
      || PROCESS AR CASH RECEIPT APPLICATIONS/UNAPPLICATIONS ---- PART -3
      ########################################################################################################*/
      /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                 pv_log_msg  =>  ' Cash receipt application processing '
                              );*/
      /******
      ||Fetch all the latest applications related to the cash receipt
      *******/
      FOR rec_get_ar_rec_app_all IN cur_get_ar_rec_app_all ( cp_cash_receipt_id => p_acra.cash_receipt_id )
      LOOP
         p_araa := rec_get_ar_rec_app_all ;
        /*********
        || Consider only the latest applications
        **********/

        /*******************************************
        || Call the procedure to process
        || cash receipt applications/unapplications
        *******************************************/
       /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                            pv_log_msg  =>  ' before call to jai_ar_tcs_rep_pkg.process_transactions '
                                          );*/
        jai_ar_tcs_rep_pkg.process_transactions (  p_araa                =>  p_araa                   ,
                                                   p_event               =>  p_araa.application_type  ,
                                                   -- p_called_from         =>  lv_document_type      ,
                                                   p_process_flag        =>  lv_process_flag          ,
                                                   p_process_message     =>  lv_process_message
                                                );
        /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                   pv_log_msg  =>  ' Return from jai_ar_tcs_rep_pkg.process_transactions '
                                );*/
        IF lv_process_flag = jai_constants.expected_error    OR                      ---------A2
           lv_process_flag = jai_constants.unexpected_error  OR
           lv_process_flag = jai_constants.not_applicable
        THEN
          /*
          || As Returned status is an error/not applicable hence:-
          || Set out variables p_process_flag and p_process_message accordingly
          */
          --call to debug package
          /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                     pv_log_msg  =>  ' Error : - lv_process_flag -> '||lv_process_flag||' - '||lv_process_message
                                  );*/

          p_process_flag    := lv_process_flag    ;
          p_process_message := lv_process_message ;
          return;
        END IF;                                                                      ---------A2


      END LOOP;

      /*
      ||Reset the receipt transaction ln_transaction_id from ln_local_transaction_id
      */
      ln_transaction_id := ln_local_transaction_id ;

      /*########################################################################################################
      || PROCESS AR CASH RECEIPT REVERSALS ---- PART -4
      ########################################################################################################*/

    ELSIF p_document_type = jai_constants.trx_type_rct_rvs  THEN            ---------C1
     /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                pv_log_msg  =>  ' Start of receipt reversal processing '
                             );*/
      OPEN cur_get_parent_transaction ( cp_source_document_id    => p_acra.cash_receipt_id                ,
                                        cp_source_document_type  => jai_constants.ar_cash_tax_confirmed
                                      ) ;

      FETCH cur_get_parent_transaction INTO ln_parent_transaction_id;
      /*
      || Check that the source receipt confirmation record has been found in the TCS repository.
      || If not found then receipt reversal also need not hit the repository.
      */
      IF CUR_GET_PARENT_TRANSACTION%FOUND THEN
        /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                            pv_log_msg  =>  ' Parent receipt confirmation record found parent_transaction_id -> '||ln_parent_transaction_id
                                         );*/

        copy_references (  p_parent_transaction_id   => ln_parent_transaction_id   ,
                           p_new_document_id         => p_acra.cash_receipt_id     ,
                           p_new_document_type       => p_document_type            ,
                           p_new_document_date       => p_acra.reversal_date       ,
                           p_apportion_factor        => -1                         ,/* As reversal cannot be partial  */
                           p_process_flag            => lv_process_flag            ,
                           p_process_message         => lv_process_message
                        );
        IF lv_process_flag = jai_constants.expected_error    OR                      ---------A2
           lv_process_flag = jai_constants.unexpected_error  OR
           lv_process_flag = jai_constants.not_applicable
        THEN
          /*
          || As Returned status is an error/not applicable hence:-
          || Set out variables p_process_flag and p_process_message accordingly
          */
          CLOSE cur_get_parent_transaction ;
          /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                              pv_log_msg  =>  ' Error : - lv_process_flag -> '||lv_process_flag||' - '||lv_process_message
                                           );*/

          p_process_flag    := lv_process_flag    ;
          p_process_message := lv_process_message ;
          return;
        END IF;                                                                      ---------A2
      END IF;
      CLOSE cur_get_parent_transaction ;
    END IF;
   /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                               pv_log_msg  =>  '**************** END OF PROCESS_RECEIPTS ****************'
                            );

    jai_cmn_debug_contexts_pkg.deregister (pn_reg_id => ln_reg_id);*/
  END process_receipts;


PROCEDURE process_applications  (   p_araa                            IN              AR_RECEIVABLE_APPLICATIONS_ALL%ROWTYPE      ,
                                    p_document_type                   IN              VARCHAR2                                    ,
                                    p_item_classification             IN              JAI_RGM_REFS_ALL.ITEM_CLASSIFICATION%TYPE   ,
                                    p_process_flag                    OUT NOCOPY      VARCHAR2                                    ,
                                    p_process_message                 OUT NOCOPY      VARCHAR2
                                  )
  IS
     ln_reg_id           NUMBER;
      /*
    ||Get the application and applied to document details
    */
    CURSOR cur_get_app_to_det (cp_applied_customer_trx_id  AR_RECEIVABLE_APPLICATIONS_ALL.APPLIED_CUSTOMER_TRX_ID%TYPE )
    IS
    SELECT
            trx_types.type                                app_to_doc_type                ,
            --nvl(gl_dist.acctd_amount,0)                 app_to_doc_amt                 ,--Deleted by eric for inclusive tax
            --NVL(jrctl.total_amount,0)                     app_to_doc_amt                 ,--Added by eric for inclusive tax for 26-Dec,2007
            NVL(jrctl.line_amount,0)                      app_to_doc_amt                 , --Added by Jia Li for inclusive tax for 2008-01-18
            rcta.org_id                                   app_to_org_id                  ,
            jrct.organization_id                          app_to_organization_id         ,
            nvl(bill_to_customer_id, ship_to_customer_id) app_to_customer_id             , -- Bug 6132484
            nvl(bill_to_site_use_id,ship_to_site_use_id)  app_to_customer_site_use_id      -- Bug 6132484
    FROM
            ra_customer_trx_all                 rcta                                    ,
            ra_cust_trx_types_all               trx_types                               ,
            ra_cust_trx_line_gl_dist_all        gl_dist                                 ,
            JAI_AR_TRXS               jrct                                    ,
            JAI_AR_TRX_LINES         jrctl                                   ,
            JAI_AR_TRX_TAX_LINES         jrcttl                                  ,
            JAI_CMN_TAXES_ALL                     jtc                                     ,
            jai_regime_tax_types_v              jrttv
    WHERE
            rcta.customer_trx_id            =   cp_applied_customer_trx_id
    AND     rcta.complete_flag              =   jai_constants.yes
    AND     rcta.customer_trx_id            =   gl_dist.customer_trx_id
    AND     gl_dist.account_class           =   jai_constants.account_class_rec
    AND     gl_dist.latest_rec_flag         =   jai_constants.yes
    AND     trx_types.cust_trx_type_id      =   rcta.cust_trx_type_id
    AND     rcta.customer_trx_id            =   jrct.customer_trx_id
    AND     jrct.customer_trx_id            =   jrctl.customer_trx_id
    AND     jrctl.customer_trx_line_id      =   jrcttl.link_to_cust_trx_line_id
    AND     jrcttl.tax_id                   =   jtc.tax_id
    AND     jtc.tax_type                    =   jrttv.tax_type
    AND     jrttv.regime_code               =   jai_constants.tcs_regime
    AND     trx_types.type                 IN  (  jai_constants.ar_invoice_type_inv      ,  /* Applied to doc has to be either a invoice or DM or CM */
                                                  jai_constants.ar_invoice_type_cm       ,
                                                  jai_constants.ar_doc_type_dm
                                                );

    -- Added by Jia Li for inclusive taxes on 2008-01-18
    ----------------------------------------------------------------
    CURSOR cur_get_exclu_amt(cp_customer_trx_id RA_CUST_TRX_LINE_GL_DIST_ALL.CUSTOMER_TRX_ID%TYPE )
    IS
      SELECT
        SUM(a.func_tax_amount)
      FROM
        jai_ar_trx_tax_lines a
      , jai_cmn_taxes_all b
      WHERE  link_to_cust_trx_line_id IN
        ( SELECT
            customer_trx_line_id
          FROM
            jai_ar_trx_lines
          WHERE customer_trx_id = cp_customer_trx_id )
        AND a.tax_id = b.tax_id
        AND NVL(b.inclusive_tax_flag,'N') = 'N';
    ln_total_exclu_amt  jai_ar_trx_tax_lines.func_tax_amount%TYPE;
    ------------------------------------------------------------------

    /*
    ||Get the type of the document
    */
    CURSOR cur_get_doc_type ( cp_customer_trx_id  RA_CUSTOMER_TRX_ALL.CUSTOMER_TRX_ID%TYPE )
    IS
    SELECT
           trx_types.type
    FROM
          ra_customer_trx_all    ract,
          ra_cust_trx_types_all  trx_types
    WHERE
          ract.cust_trx_type_id  =  trx_types.cust_trx_type_id
    AND   ract.customer_trx_id   =  cp_customer_trx_id;

    /*
    ||Get the applied to document cash receipt details
    */
    CURSOR cur_get_cr_details ( cp_cash_receipt_id AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE )
    IS
    SELECT
           nvl(acra.amount,0) * nvl(acra.exchange_rate , 1 )   app_fr_doc_amt           ,
           nvl(acra.exchange_rate,1)                           exchange_rate            ,
           arps.gl_date                                        app_fr_doc_date          ,
           jcra.organization_id                                app_fr_organization_id   ,
           acra.pay_from_customer                                                       ,
           acra.customer_site_use_id                                                    ,
           acra.org_id
    FROM
           ar_cash_receipts_all     acra ,
           ar_payment_schedules_all arps ,
           jai_ar_cash_receipts_all jcra ,
           jai_cmn_document_taxes   jdt  ,
           jai_regime_tax_types_v   jrttv
    WHERE
           acra.cash_receipt_id = arps.cash_receipt_id
    AND    acra.cash_receipt_id = jcra.cash_receipt_id
    AND    jcra.cash_receipt_id = jdt.source_doc_id
    AND    jdt.tax_type         = jrttv.tax_type
    AND    acra.cash_receipt_id = cp_cash_receipt_id
    AND    jrttv.regime_code    = jai_constants.tcs_regime
    AND    jcra.confirm_flag    = jai_constants.yes
    AND    jdt.source_doc_type  = JAI_CONSTANTS.ar_cash;    --added by eric for a bug
    /*
    ||Get the applied to document CM details
    */
    CURSOR cur_get_cm_details (cp_customer_trx_id RA_CUST_TRX_LINE_GL_DIST_ALL.CUSTOMER_TRX_ID%TYPE)
    IS
    SELECT
          --nvl(gl_dist.acctd_amount,0)                       app_fr_doc_amt                 ,--Deleted by eric for inclusive tax
          --NVL(jrctl.total_amount,0)                         app_fr_doc_amt                   ,--Added by eric for Inclusisve Tax on 26-dec,2007
          NVL(jrctl.line_amount,0)                          app_fr_doc_amt                 ,--Added by Jia Li for Inclusisve Tax on 2008-01-18
          nvl(rcta.exchange_rate,1)                         exchange_rate                  ,
          gl_dist.gl_date                                   app_fr_doc_date                ,
          rcta.org_id                                       app_to_org_id                  ,
          jrct.organization_id                              app_to_organization_id         ,
          nvl( bill_to_customer_id , ship_to_customer_id )  app_to_customer_id             ,
          nvl( bill_to_site_use_id , ship_to_site_use_id )  app_to_customer_site_use_id
    FROM
          ra_customer_trx_all                 rcta                                      ,
          ra_cust_trx_types_all               trx_types                                 ,
          ra_cust_trx_line_gl_dist_all        gl_dist                                   ,
          JAI_AR_TRXS               jrct                                      ,
          JAI_AR_TRX_LINES         jrctl                                     ,
          JAI_AR_TRX_TAX_LINES         jrcttl                                    ,
          JAI_CMN_TAXES_ALL                     jtc                                       ,
          jai_regime_tax_types_v              jrttv
    WHERE
          rcta.complete_flag              =   jai_constants.yes
    AND   trx_types.cust_trx_type_id      =   rcta.cust_trx_type_id
    AND   trx_types.type                  =   jai_constants.ar_invoice_type_cm
    AND   rcta.customer_trx_id            =   gl_dist.customer_trx_id
    AND   gl_dist.account_class           =   jai_constants.account_class_rec
    AND   gl_dist.latest_rec_flag         =   jai_constants.yes
    AND   rcta.customer_trx_id            =   jrct.customer_trx_id
    AND   jrct.customer_trx_id            =   jrctl.customer_trx_id
    AND   jrctl.customer_trx_line_id      =   jrcttl.link_to_cust_trx_line_id
    AND   jrcttl.tax_id                   =   jtc.tax_id
    AND   jtc.tax_type                    =   jrttv.tax_type
    AND   rcta.customer_trx_id            =   cp_customer_trx_id
    AND   jrttv.regime_code               =   jai_constants.tcs_regime;

    ln_app_fr_doc_amt             NUMBER                                            ;
    ld_app_fr_doc_date            DATE                                              ;
    ln_app_fr_doc_id              JAI_RGM_REFS_ALL.SOURCE_DOCUMENT_ID%TYPE          ;
    ln_app_fr_doc_type            JAI_RGM_REFS_ALL.SOURCE_DOCUMENT_TYPE%TYPE        ;
    ln_app_fr_doc_table           JAI_RGM_REFS_ALL.SOURCE_TABLE_NAME%TYPE           ;
    ln_fr_organization_id         JAI_RGM_REFS_ALL.ORGANIZATION_ID%TYPE             ;
    ln_fr_party_id                JAI_RGM_REFS_ALL.PARTY_ID%TYPE                    ;
    ln_fr_party_site_id           JAI_RGM_REFS_ALL.PARTY_SITE_ID%TYPE               ;

    ln_app_to_doc_amt             NUMBER                                            ;
    ld_app_to_doc_date            DATE                                              ;
    ln_app_to_doc_id              JAI_RGM_REFS_ALL.SOURCE_DOCUMENT_ID%TYPE          ;
    ln_app_to_doc_type            JAI_RGM_REFS_ALL.SOURCE_DOCUMENT_TYPE%TYPE        ;
    ln_app_to_doc_table           JAI_RGM_REFS_ALL.SOURCE_TABLE_NAME%TYPE           ;
    ln_to_organization_id         JAI_RGM_REFS_ALL.ORGANIZATION_ID%TYPE             ;
    ln_to_party_id                JAI_RGM_REFS_ALL.PARTY_ID%TYPE                    ;
    ln_to_party_site_id           JAI_RGM_REFS_ALL.PARTY_SITE_ID%TYPE               ;


    ln_app_amount                 NUMBER                                            ;
    ln_apportion_factor           NUMBER                                            ;
    ln_app_ref_doc_id             JAI_RGM_REFS_ALL.SOURCE_REF_DOCUMENT_ID%TYPE      ;
    ln_app_ref_doc_type           JAI_RGM_REFS_ALL.SOURCE_REF_DOCUMENT_TYPE%TYPE    ;
    ln_app_ref_doc_table          JAI_RGM_REFS_ALL.SOURCE_TABLE_NAME%TYPE           ;
    ld_source_document_date       JAI_RGM_REFS_ALL.SOURCE_DOCUMENT_DATE%TYPE        ;
    ln_parent_transaction_id      JAI_RGM_REFS_ALL.parent_transaction_id%TYPE       ;
    ln_organization_id            JAI_RGM_REFS_ALL.ORGANIZATION_ID%TYPE             ;
    ln_trx_ref_id                 JAI_RGM_REFS_ALL.TRX_REF_ID%TYPE                  ;
    ln_party_id                   JAI_RGM_REFS_ALL.PARTY_ID%TYPE                    ;
    ln_party_site_id              JAI_RGM_REFS_ALL.PARTY_SITE_ID%TYPE               ;
    ln_exchange_rate              NUMBER                                            ;
    rec_cur_get_app_to_det        CUR_GET_APP_TO_DET%ROWTYPE                        ;
    rec_cur_get_cr_details        CUR_GET_CR_DETAILS%ROWTYPE                        ;
    rec_cur_get_cm_details        CUR_GET_CM_DETAILS%ROWTYPE                        ;
    lv_process_flag               VARCHAR2(2)                                       ;
    lv_process_message            VARCHAR2(4000)                                    ;

  BEGIN
    /*########################################################################################################
    || Initialize Variables ---- PART -1
    ########################################################################################################*/
    lv_member_name        := 'PROCESS_APPLICATIONS';
    set_debug_context;
    /*commented by csahoo for bug# 6401388
    jai_cmn_debug_contexts_pkg.register ( pv_context => lv_context ,
                                          pn_reg_id  => ln_reg_id
                                        );*/

   /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                      pv_log_msg  =>  ' Processing the APPLICATION record ' ||fnd_global.local_chr(10)
                                           ||', receivable_application_id -> '  ||p_araa.receivable_application_id    ||fnd_global.local_chr(10)
                                           ||', application_type          -> '  ||p_araa.application_type             ||fnd_global.local_chr(10)
                                           ||', status                    -> '  ||p_araa.status                       ||fnd_global.local_chr(10)
                                           ||', display                   -> '  ||p_araa.display                     ||fnd_global.local_chr(10)
                                           ||', cash_receipt_id           -> '  ||p_araa.cash_receipt_id              ||fnd_global.local_chr(10)
                                           ||', customer_trx_id           -> '  ||p_araa.customer_trx_id              ||fnd_global.local_chr(10)
                                           ||', applied_customer_trx_id   -> '  ||p_araa.applied_customer_trx_id      ||fnd_global.local_chr(10)
                                           ||', amount_applied            -> '  ||p_araa.amount_applied               ||fnd_global.local_chr(10)
                                           ||', gl_date                   -> '  ||p_araa.gl_date                      ||fnd_global.local_chr(10)
                                           ||', org_id                    -> '  ||p_araa.org_id
                                    );*/
    lv_process_flag               := jai_constants.successful                       ;
    lv_process_message            := null                                           ;
    p_process_flag                := lv_process_flag                                ;
    p_process_message             := lv_process_message                             ;
    ln_app_fr_doc_amt             := NULL                                           ;
    ld_app_fr_doc_date            := NULL                                           ;
    ln_parent_transaction_id      := NULL                                           ;

    /*########################################################################################################
    || GET APPLICATION and APPLIED TO DOCUMENT DETAILS ---- PART -2
    ########################################################################################################*/
    OPEN  cur_get_app_to_det (cp_applied_customer_trx_id => p_araa.applied_customer_trx_id ) ;
    FETCH cur_get_app_to_det INTO rec_cur_get_app_to_det                                     ;
    CLOSE cur_get_app_to_det                                                                 ;

    -- Added by Jia Li for inclusive taxes on 2008-01-18
    ---------------------------------------------------------------------
    OPEN cur_get_exclu_amt (cp_customer_trx_id => p_araa.applied_customer_trx_id );
    FETCH cur_get_exclu_amt INTO ln_total_exclu_amt;
    CLOSE cur_get_exclu_amt;
    ----------------------------------------------------------------------

    ln_app_to_doc_amt         := rec_cur_get_app_to_det.app_to_doc_amt + ln_total_exclu_amt  ; -- Modified by Jia Li for inclusive tax on 2008-01-18
    ld_app_to_doc_date        := p_araa.gl_date                                              ;
    ln_app_to_doc_id          := p_araa.applied_customer_trx_id                              ;

    /*
    || Derive the to Document type from the application information
    || APPLIED TO DOCUMENT BEING CASH NOT HANDLED CURRENTLY  - STOP AND VALIDATION TIME
    */
    OPEN  cur_get_doc_type ( cp_customer_trx_id => p_araa.applied_customer_trx_id )          ;
    FETCH cur_get_doc_type INTO ln_app_to_doc_type                                           ;
    CLOSE cur_get_doc_type                                                                   ;

    ln_app_to_doc_table       := jai_constants.ar_inv_lines_table                            ; /* table JAI_AR_TRX_LINES */
    ln_app_to_doc_type        := rec_cur_get_app_to_det.app_to_doc_type                      ;
    ln_to_organization_id     := rec_cur_get_app_to_det.app_to_organization_id               ;
    ln_to_party_id            := rec_cur_get_app_to_det.app_to_customer_id                   ;
    ln_to_party_site_id       := rec_cur_get_app_to_det.app_to_customer_site_use_id          ;

    /*########################################################################################################
    || VALIDATE AND GET APPLIED FROM DOCUMENT DETAILS ---- PART -3
    ########################################################################################################*/
    IF p_document_type = jai_constants.trx_type_rct_app   THEN                                                  -----------A1
      /*
      ||Applied from document type is Cash Receipt Application
      */
      OPEN  cur_get_cr_details ( cp_cash_receipt_id => p_araa.cash_receipt_id  )    ;
      FETCH cur_get_cr_details INTO rec_cur_get_cr_details                          ;
      CLOSE cur_get_cr_details                                                      ;

      ld_app_fr_doc_date      :=  rec_cur_get_cr_details.app_fr_doc_date            ;
      ln_app_fr_doc_amt       :=  rec_cur_get_cr_details.app_fr_doc_amt             ;
      ln_exchange_rate        :=  rec_cur_get_cr_details.exchange_rate              ;

      ln_app_fr_doc_id        :=  p_araa.cash_receipt_id                            ;
      ln_app_fr_doc_type      :=  jai_constants.ar_cash_tax_confirmed               ;  /* Receipt confirmation */
      ln_app_fr_doc_table     :=  jai_constants.jai_cash_rcpts                      ; /* table JAI_AR_CASH_RECEIPTS_ALL */

      ln_fr_organization_id  :=  rec_cur_get_cr_details.app_fr_organization_id      ;
      ln_fr_party_id         :=  rec_cur_get_cr_details.pay_from_customer           ;
      ln_fr_party_site_id    :=  rec_cur_get_cr_details.customer_site_use_id        ;

    ELSIF p_document_type = jai_constants.trx_type_cm_app THEN

      OPEN  cur_get_cm_details ( cp_customer_trx_id => p_araa.customer_trx_id  )    ;
      FETCH cur_get_cm_details INTO rec_cur_get_cm_details                          ;
      CLOSE cur_get_cm_details                                                      ;

      -- Added by Jia Li for inclusive taxes on 2008-01-18
      ---------------------------------------------------------------------
      OPEN cur_get_exclu_amt (cp_customer_trx_id => p_araa.customer_trx_id );
      FETCH cur_get_exclu_amt INTO ln_total_exclu_amt;
      CLOSE cur_get_exclu_amt;
      ----------------------------------------------------------------------
      ld_app_fr_doc_date     :=   rec_cur_get_cm_details.app_fr_doc_date            ;
      ln_app_fr_doc_amt      :=   rec_cur_get_cm_details.app_fr_doc_amt + ln_total_exclu_amt;-- Modified by Jia Li for inclusive tax on 2008-01-18
      ln_exchange_rate        :=  rec_cur_get_cm_details.exchange_rate              ;

      ln_app_fr_doc_id       :=   p_araa.customer_trx_id                            ;
      ln_app_fr_doc_type     :=   jai_constants.ar_invoice_type_cm                                ;  /* 'CM' */
      ln_app_fr_doc_table    :=   jai_constants.ar_inv_lines_table                  ; /* table JAI_AR_CASH_RECEIPTS_ALL */

      ln_fr_organization_id  :=  rec_cur_get_cm_details.app_to_organization_id      ;
      ln_fr_party_id         :=  rec_cur_get_cm_details.app_to_customer_id          ;
      ln_fr_party_site_id    :=  rec_cur_get_cm_details.app_to_customer_site_use_id ;

    END IF;

    ln_app_amount             := nvl(p_araa.amount_applied,0) * ln_exchange_rate    ;


   /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                       pv_log_msg  =>  ' Values for the Internal FROm and TO variables are ' ||fnd_global.local_chr(10)
                                                     ||', ln_app_to_doc_id      -> '  ||ln_app_to_doc_id       ||fnd_global.local_chr(10)
                                                     ||', ln_app_to_doc_type    -> '  ||ln_app_to_doc_type     ||fnd_global.local_chr(10)
                                                     ||', ln_app_to_doc_table   -> '  ||ln_app_to_doc_table    ||fnd_global.local_chr(10)
                                                     ||', ln_app_to_doc_amt     -> '  ||ln_app_to_doc_amt      ||fnd_global.local_chr(10)
                                                     ||', ld_app_to_doc_date    -> '  ||ld_app_to_doc_date     ||fnd_global.local_chr(10)
                                                     ||', ln_to_organization_id -> '  ||ln_to_organization_id  ||fnd_global.local_chr(10)
                                                     ||', ln_to_party_id        -> '  ||ln_to_party_id         ||fnd_global.local_chr(10)
                                                     ||', ln_to_party_site_id   -> '  ||ln_to_party_site_id    ||fnd_global.local_chr(10)
                                                     ||', ln_app_fr_doc_id      -> '  ||ln_app_fr_doc_id       ||fnd_global.local_chr(10)
                                                     ||', ln_app_to_doc_type    -> '  ||ln_app_to_doc_type     ||fnd_global.local_chr(10)
                                                     ||', ln_app_fr_doc_table   -> '  ||ln_app_fr_doc_table    ||fnd_global.local_chr(10)
                                                     ||', ln_app_fr_doc_amt     -> '  ||ln_app_fr_doc_amt      ||fnd_global.local_chr(10)
                                                     ||', ld_app_fr_doc_date    -> '  ||ld_app_fr_doc_date     ||fnd_global.local_chr(10)
                                                     ||', ln_fr_organization_id -> '  ||ln_fr_organization_id  ||fnd_global.local_chr(10)
                                                     ||', ln_fr_party_id        -> '  ||ln_fr_party_id         ||fnd_global.local_chr(10)
                                                     ||', ln_fr_party_site_id   -> '  ||ln_fr_party_site_id    ||fnd_global.local_chr(10)
                                                     ||', ln_exchange_rate      -> '  ||ln_exchange_rate       ||fnd_global.local_chr(10)
                                                     ||', ln_app_amount         -> '  ||ln_app_amount          ||fnd_global.local_chr(10)
                                    );*/

    /*########################################################################################################
    || DERIVE DATE AS PER LATER DOCUMENT ---- PART -4
    ########################################################################################################*/

    /*****
    || Derive the document date based on the date of
    || the later document
    || Also get the tcs amount based on the later document date
    ******/
    IF ld_app_fr_doc_date      >=  ld_app_to_doc_date THEN                                 -----------A2
     /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                          pv_log_msg  => '  From date >= To date '||fnd_global.local_chr(10)
                                                       ||', ld_app_fr_doc_date ->  '||ld_app_fr_doc_date
                                                       ||', ld_app_to_doc_date =>  '|| ld_app_to_doc_date  ||fnd_global.local_chr(10)
                                       );*/
      ln_app_ref_doc_id        := ln_app_fr_doc_id                        ;
      ln_app_ref_doc_type      := ln_app_fr_doc_type                      ;
      ln_app_ref_doc_table     := ln_app_fr_doc_table                     ;
      ld_source_document_date  := ld_app_fr_doc_date                      ;
      --added the IF block for bug#7393380
      -- for receipt application, the apportion factor should be negative.
      IF p_document_type = jai_constants.trx_type_rct_app   THEN
        ln_apportion_factor      := -1 * ln_app_amount/nvl(ln_app_fr_doc_amt,1)  ;
      ELSE
        ln_apportion_factor      := ln_app_amount/nvl(ln_app_fr_doc_amt,1)  ;
      END IF;

      ln_organization_id       := ln_fr_organization_id                   ;
      ln_party_id              := ln_fr_party_id                          ;
      ln_party_site_id         := ln_fr_party_site_id                     ;

    ELSE                                                                                            -----------A2
      /*
      || Applied To document is later
      */

     /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                          pv_log_msg  => '  To date is greater than from date '||fnd_global.local_chr(10)
                                                       ||', ld_app_fr_doc_date ->  '||ld_app_fr_doc_date ||fnd_global.local_chr(10)
                                                       ||', ld_app_to_doc_date =>  '|| ld_app_to_doc_date
                                       );*/

      ln_app_ref_doc_id        := ln_app_to_doc_id                        ;
      ln_app_ref_doc_type      := ln_app_to_doc_type ;
      ln_app_ref_doc_table     := ln_app_to_doc_table;
      ld_source_document_date  := ld_app_to_doc_date;
      --added the IF block for bug#7393380
      IF p_document_type = jai_constants.trx_type_rct_app   THEN
        ln_apportion_factor      := -1 * (ln_app_amount/nvl(ln_app_to_doc_amt,1)) ;
      ELSE
        ln_apportion_factor      := ln_app_amount/nvl(ln_app_to_doc_amt,1) ;
      END IF;

      ln_organization_id       := ln_to_organization_id ;
      ln_party_id              := ln_to_party_id        ;
      ln_party_site_id         := ln_to_party_site_id   ;

    END IF;                                                                                         -----------A2


    /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                        pv_log_msg  =>  ' based on later date derivation logic values derived are ' ||fnd_global.local_chr(10)
                                                      ||', ln_app_ref_doc_id       -> '  ||ln_app_ref_doc_id        ||fnd_global.local_chr(10)
                                                      ||', ln_app_ref_doc_type     -> '  ||ln_app_ref_doc_type      ||fnd_global.local_chr(10)
                                                      ||', ln_app_ref_doc_table    -> '  ||ln_app_ref_doc_table     ||fnd_global.local_chr(10)
                                                      ||', ld_source_document_date -> '  ||ld_source_document_date  ||fnd_global.local_chr(10)
                                                      ||', ln_apportion_factor     -> '  ||ln_apportion_factor      ||fnd_global.local_chr(10)
                                                      ||', ln_organization_id      -> '  ||ln_organization_id       ||fnd_global.local_chr(10)
                                                      ||', ln_party_id             -> '  ||ln_party_id              ||fnd_global.local_chr(10)
                                                      ||', ln_party_site_id        -> '  ||ln_party_site_id
                                    );*/


    /*########################################################################################################
    || DERIVE TCS AMOUNT IN CASE OF OVERAPPLICATION ---- CURRENTLY COMMENTED PART -5
    ########################################################################################################


    -- || Derive the tcs tax amount according to the below formula :-
    -- || Check if application_amount > applied to amount
    -- || IF yes then it indicates overapplication else it is normal application

    IF abs(ln_app_amount) > abs(ln_app_to_doc_amt) THEN

    --      || Case is OVERAPPLICATION
    --    || Hence consider the tcs amount from the APPLIED TO DOCUMENT

      ln_app_amount        := ln_app_to_doc_amt;
      ln_app_ref_doc_id    := ln_app_to_doc_id   ;
      ln_app_ref_doc_type      := ln_app_to_doc_type ;
      ln_app_ref_doc_table := ln_app_to_doc_table;
      ln_apportion_factor  := 1 ;
    END IF;                                                                                         -----------A2
  */

    /*########################################################################################################
    || DERIVE THE PARENT DOCUMENT REFERENCE ---- PART -5
    ########################################################################################################*/

    OPEN cur_get_parent_transaction ( cp_source_document_id    => ln_app_ref_doc_id     ,
                                      cp_source_document_type  => ln_app_ref_doc_type
                                    );
    FETCH cur_get_parent_transaction INTO ln_parent_transaction_id;
    CLOSE cur_get_parent_transaction  ;
    /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                        pv_log_msg  =>  ' parent transaction id is (ln_parent_transaction_id)' ||ln_parent_transaction_id
                                     );*/


    /*########################################################################################################
    || INSERT APPLICATION RECORDS  INTO JAI_RGM_TRX_REFS_ALL TABLE  ---- PART -1
    ########################################################################################################*/
    /*
    ||Get the sequence generated unique key for the transaction
    */
    OPEN  cur_get_transaction_id ;
    FETCH cur_get_transaction_id INTO ln_transaction_id ;
    CLOSE cur_get_transaction_id ;

   /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                        pv_log_msg  =>  ' Before call to insert_repository_references '
                                     );*/
    insert_repository_references     (
                                                      p_regime_id                     =>   NULL                                           ,
                                                      p_transaction_id                =>   ln_transaction_id                              ,
                                                      p_source_ref_document_id        =>   ln_app_ref_doc_id                              ,
                                                      p_source_ref_document_type      =>   ln_app_ref_doc_type                            ,
                                                      p_app_from_document_id          =>   ln_app_fr_doc_id                               ,
                                                      p_app_from_document_type        =>   ln_app_fr_doc_type                             ,
                                                      p_app_to_document_id            =>   ln_app_to_doc_id                               ,
                                                      p_app_to_document_type          =>   ln_app_to_doc_type                             ,
                                                      p_parent_transaction_id         =>   ln_parent_transaction_id                       ,
                                                      p_org_tan_no                    =>   NULL                                           ,
                                                      p_document_id                   =>   p_araa.receivable_application_id               ,
                                                      p_document_type                 =>   p_document_type                                ,
                                                      p_document_line_id              =>   p_araa.receivable_application_id               ,
                                                      p_document_date                 =>   ld_source_document_date                        ,
                                                      p_table_name                    =>   jai_constants.ar_receipt_app                   ,
                                                      p_line_amount                   =>   ln_app_amount                                  ,
                                                      p_document_amount               =>   ln_app_amount                                  ,
                                                      p_org_id                        =>   p_araa.org_id                                  ,
                                                      p_organization_id               =>   ln_organization_id                             ,
                                                      p_party_id                      =>   ln_party_id                                    ,
                                                      p_party_site_id                 =>   ln_party_site_id                               ,
                                                      p_item_classification           =>   p_item_classification                          ,
                                                      p_trx_ref_id                    =>   ln_trx_ref_id                                  ,
                                                      p_process_flag                  =>   lv_process_flag                                ,
                                                      p_process_message               =>   lv_process_message
                                       );


     /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                          pv_log_msg  =>  ' Returned from call to insert_repository_references, lv_process_flag -> '||lv_process_flag
                                       );*/
    IF lv_process_flag = jai_constants.expected_error    OR                      ---------A2
       lv_process_flag = jai_constants.unexpected_error  OR
       lv_process_flag = jai_constants.not_applicable
    THEN
      /*
      || As Returned status is an error/not applicable hence:-
      || Set out variables p_process_flag and p_process_message accordingly
      */
      --call to debug package
    /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                        pv_log_msg  =>  ' Error in procedure insert_repository_references '
                                        ||', p_process_flag      -> '|| p_process_flag
                                        ||', lv_process_message  -> '|| lv_process_message
                                      );*/
      p_process_flag    := lv_process_flag    ;
      p_process_message := lv_process_message ;
      return;
    END IF;                                                                      ---------A2

    /*########################################################################################################
    || COPY APPLICATION TAXES FROM SOURCE TRANSACTION TABLES INTO JAI_RGM_TAXES TABLE  ---- PART -2
    ########################################################################################################*/
      /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                          pv_log_msg  =>  ' Before call to copy_taxes_from_source '
                                       );*/
    copy_taxes_from_source    (  p_source_document_type  =>  ln_app_ref_doc_type  ,
                                 p_source_document_id    =>  ln_app_ref_doc_id    ,
                                 p_apportion_factor      =>  ln_apportion_factor  ,
                                 p_trx_ref_id            =>  ln_trx_ref_id        ,
                                 p_process_flag          =>  lv_process_flag      ,
                                 p_process_message       =>  lv_process_message
                               );

   /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                        pv_log_msg  =>  ' Returned from call to copy_taxes_from_source, lv_process_flag -> '||lv_process_flag
                                     );*/
    IF lv_process_flag = jai_constants.expected_error    OR                      ---------A2
       lv_process_flag = jai_constants.unexpected_error  OR
       lv_process_flag = jai_constants.not_applicable
    THEN
      /*
      || As Returned status is an error/not applicable hence:-
      || Set out variables p_process_flag and p_process_message accordingly
      */
      --call to debug package
    /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                        pv_log_msg  =>  ' Error in procedure copy_taxes_from_source '
                                        ||', p_process_flag      -> '|| p_process_flag
                                        ||', lv_process_message  -> '|| lv_process_message
                                      );*/
      p_process_flag    := lv_process_flag    ;
      p_process_message := lv_process_message ;
      return;
    END IF;                                                                      ---------A2
  /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                             pv_log_msg  =>  '**************** PROCEDURE PROCESS_APPLICATIONS SUCCESSFULLY COMPLETED ****************'
                          );
    jai_cmn_debug_contexts_pkg.deregister (pn_reg_id => ln_reg_id);*/
  END process_applications;


PROCEDURE process_unapp_rcpt_rev (  p_araa                      IN              AR_RECEIVABLE_APPLICATIONS_ALL%ROWTYPE   DEFAULT NULL  ,
                                    p_acra                      IN              AR_CASH_RECEIPTS_ALL%ROWTYPE             DEFAULT NULL  ,
                                    p_document_type             IN              VARCHAR2                                               ,
                                    p_process_flag              OUT NOCOPY      VARCHAR2                                               ,
                                    p_process_message           OUT NOCOPY      VARCHAR2
                                  )

IS

  ln_reg_id           NUMBER;
  /*
  ||Get the parent record for an type of record
  */
  CURSOR cur_get_parent_trx ( cp_source_document_id     JAI_RGM_REFS_ALL.SOURCE_DOCUMENT_ID%TYPE   DEFAULT NULL     ,
                              cp_source_document_type   JAI_RGM_REFS_ALL.SOURCE_DOCUMENT_TYPE%TYPE                  ,
                              cp_app_from_document_id   JAI_RGM_REFS_ALL.APP_FROM_DOCUMENT_ID%TYPE DEFAULT NULL     ,
                              cp_app_to_document_id     JAI_RGM_REFS_ALL.APP_TO_DOCUMENT_ID%TYPE   DEFAULT NULL
                             )
  IS
  SELECT
          to_number(max(transaction_id)) parent_transaction_id
  FROM
          jai_rgm_refs_all
  WHERE
          source_document_id      =  nvl(cp_source_document_id  , source_document_id)
  AND     source_document_type    =  cp_source_document_type
  AND     app_from_document_id    =  nvl(app_from_document_id   , app_from_document_id )
  AND     app_to_document_id      =  nvl(app_to_document_id     , app_to_document_id   ) ;

  ln_new_document_id        JAI_RGM_REFS_ALL.SOURCE_DOCUMENT_ID%TYPE    ;
  ln_source_document_id     JAI_RGM_REFS_ALL.SOURCE_DOCUMENT_ID%TYPE    ;
  ld_new_document_date      JAI_RGM_REFS_ALL.SOURCE_DOCUMENT_DATE%TYPE  ;
  lv_source_document_type   JAI_RGM_REFS_ALL.SOURCE_DOCUMENT_TYPE%TYPE  ;
  ln_app_from_document_id   JAI_RGM_REFS_ALL.APP_FROM_DOCUMENT_ID%TYPE  ;
  ln_app_to_document_id     JAI_RGM_REFS_ALL.APP_TO_DOCUMENT_ID%TYPE    ;
  ln_parent_transaction_id  JAI_RGM_REFS_ALL.TRANSACTION_ID%TYPE        ;
  lv_process_flag           VARCHAR2(2)                                 ;
  lv_process_message        VARCHAR2(2000)                              ;

BEGIN
  /*########################################################################################################
  || VARIABLES INITIALIZATION
  ########################################################################################################*/
  lv_member_name        := 'PROCESS_UNAPP_RCPT_REV';
  set_debug_context;
  /*commented by csahoo for bug# 6401388
  jai_cmn_debug_contexts_pkg.register ( pv_context => lv_context
                             , pn_reg_id  => ln_reg_id
                             );*/

  lv_process_flag       := jai_constants.successful   ;
  lv_process_message    := null                       ;

  p_process_flag        := lv_process_flag            ;
  p_process_message     := lv_process_message         ;

 /* IF p_document_type In ( jai_constants.trx_type_rct_unapp  ,
                          jai_constants.trx_type_cm_unapp
                        )
  THEN
   jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                      pv_log_msg  =>  ' Processing the UN APPLICATION record ' ||fnd_global.local_chr(10)
                                           ||', p_document_type           -> '  ||p_document_type                     ||fnd_global.local_chr(10)
                                           ||', receivable_application_id -> '  ||p_araa.receivable_application_id    ||fnd_global.local_chr(10)
                                           ||', application_type          -> '  ||p_araa.application_type             ||fnd_global.local_chr(10)
                                           ||', status                    -> '  ||p_araa.status                       ||fnd_global.local_chr(10)
                                           ||', display                   -> '  ||p_araa.display                      ||fnd_global.local_chr(10)
                                           ||', cash_receipt_id           -> '  ||p_araa.cash_receipt_id              ||fnd_global.local_chr(10)
                                           ||', customer_trx_id           -> '  ||p_araa.customer_trx_id              ||fnd_global.local_chr(10)
                                           ||', applied_customer_trx_id   -> '  ||p_araa.applied_customer_trx_id      ||fnd_global.local_chr(10)
                                           ||', amount_applied            -> '  ||p_araa.amount_applied               ||fnd_global.local_chr(10)
                                           ||', gl_date                   -> '  ||p_araa.gl_date                      ||fnd_global.local_chr(10)
                                           ||', org_id                    -> '  ||p_araa.org_id
                                    );
  ELSIF p_document_type  = jai_constants.trx_type_rct_rvs  THEN
   jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                       pv_log_msg  =>  ' Processing the Receipt reversal record ' ||fnd_global.local_chr(10)
                                           ||', p_document_type           -> '  ||p_document_type                     ||fnd_global.local_chr(10)
                                           ||', cash_receipt_id -> '  ||p_acra.cash_receipt_id||fnd_global.local_chr(10)
                                           ||', receipt_number  -> '  ||p_acra.cash_receipt_id||fnd_global.local_chr(10)
                                           ||', amount          -> '  ||p_acra.cash_receipt_id||fnd_global.local_chr(10)
                                    );

  END IF;


  /*########################################################################################################
  || DERIVE VALUES BASED ON APPLICATION TYPE
  ########################################################################################################*/

  IF p_document_type  = jai_constants.trx_type_rct_rvs  THEN
    ln_new_document_id      := p_acra.cash_receipt_id                 ;  /* New document id to be created */
    ld_new_document_date    := p_acra.reversal_date                   ;

    ln_source_document_id   := p_acra.cash_receipt_id                 ;
    lv_source_document_type := jai_constants.ar_cash_tax_confirmed    ;  /* Parent Document type */


  ELSIF  p_document_type = jai_constants.trx_type_rct_unapp  THEN
    ln_new_document_id      := p_araa.receivable_application_id       ;  /* New document id to be created */
    ld_new_document_date    := p_araa.apply_date                      ;

    lv_source_document_type := jai_constants.trx_type_rct_app         ;  /* Parent Document type */
    ln_app_from_document_id := p_araa.cash_receipt_id                 ;
    ln_app_to_document_id   := p_araa.applied_customer_trx_id         ;


  ELSIF  p_document_type = jai_constants.trx_type_cm_unapp THEN
    ln_new_document_id      := p_araa.receivable_application_id       ; /* New document id to be created */
    ld_new_document_date    := p_araa.apply_date                      ;

    lv_source_document_type := jai_constants.trx_type_cm_app          ; /* Parent Document type */
    ln_app_from_document_id := p_araa.customer_trx_id                 ;
    ln_app_to_document_id   := p_araa.applied_customer_trx_id        ;

  END IF;


   /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                       pv_log_msg  =>  ' Values derived for an application/reversal are ' ||fnd_global.local_chr(10)
                                           ||', ln_new_document_id       -> '  ||ln_new_document_id       ||fnd_global.local_chr(10)
                                           ||', ld_new_document_date     -> '  ||ld_new_document_date     ||fnd_global.local_chr(10)
                                           ||', ln_source_document_id    -> '  ||ln_source_document_id    ||fnd_global.local_chr(10)
                                           ||', lv_source_document_type  -> '  ||lv_source_document_type  ||fnd_global.local_chr(10)
                                           ||', ln_app_from_document_id  -> '  ||ln_app_from_document_id  ||fnd_global.local_chr(10)
                                           ||', ln_app_to_document_id    -> '  ||ln_app_to_document_id
                                    );*/


  /*
  ||Get the parent transaction for the receipt reversal/Unapplication
  */

  OPEN cur_get_parent_trx ( cp_source_document_id     => ln_source_document_id   ,
                            cp_source_document_type   => lv_source_document_type ,
                            cp_app_from_document_id   => ln_app_from_document_id ,
                            cp_app_to_document_id     => ln_app_to_document_id
                          ) ;
  FETCH cur_get_parent_trx INTO ln_parent_transaction_id ;

   /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                       pv_log_msg  =>  ' Parent transaction is ->' ||ln_parent_transaction_id
                                    );*/
  /*
  || Check that the source receipt confirmation record has been found in the TCS repository.
  || If not found then receipt reversal also need not hit the repository.
  */
  IF CUR_GET_PARENT_TRX%FOUND THEN
    CLOSE  cur_get_parent_trx ;
    /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                       pv_log_msg  =>  ' Parent transaction found, Before call to copy_references '
                                    );*/
    copy_references (  p_parent_transaction_id   => ln_parent_transaction_id   ,
                       p_new_document_id         => ln_new_document_id         ,
                       p_new_document_type       => p_document_type            ,
                       p_new_document_date       => ld_new_document_date       ,
                       p_apportion_factor        => -1                         ,/* As reversal cannot be partial  */
                       p_process_flag            => lv_process_flag            ,
                       p_process_message         => lv_process_message
                    );

    /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                       pv_log_msg  =>  ' returned from call to copy_references lv_process_flag -> '||lv_process_flag
                                    );*/
    IF lv_process_flag = jai_constants.expected_error    OR                      ---------A2
       lv_process_flag = jai_constants.unexpected_error  OR
       lv_process_flag = jai_constants.not_applicable
    THEN
      /*
      || As Returned status is an error/not applicable hence:-
      || Set out variables p_process_flag and p_process_message accordingly
      */
      --call to debug package
     /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                          pv_log_msg  =>  ' Error in processing copy references ' ||fnd_global.local_chr(10)
                                                        ||',lv_process_flag -> '||lv_process_flag    ||fnd_global.local_chr(10)
                                                        ||',lv_process_message -> '||lv_process_message
                                    );*/
      p_process_flag    := lv_process_flag    ;
      p_process_message := lv_process_message ;
      return;
    END IF;                                                                      ---------A2
  ELSE
    /*
    ||Base document not found hence skip the document
    */
     p_process_flag := jai_constants.not_applicable;
  END IF; /* Parent transaction found*/
 /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                             pv_log_msg  =>  '**************** PROCEDURE PROCESS_UNAPP_RCPT_REV SUCCESSFULLY COMPLETED ****************'
                          );
  jai_cmn_debug_contexts_pkg.deregister (pn_reg_id => ln_reg_id);*/
END process_unapp_rcpt_rev ;


  procedure insert_repository_references (  p_regime_id                  IN            JAI_RGM_DEFINITIONS.REGIME_ID%TYPE                      DEFAULT NULL    ,
                                            p_transaction_id             IN            JAI_RGM_REFS_ALL.TRANSACTION_ID%TYPE                            ,
                                            p_source_ref_document_id     IN            JAI_RGM_REFS_ALL.SOURCE_REF_DOCUMENT_ID%TYPE    DEFAULT NULL    ,
                                            p_source_ref_document_type   IN            JAI_RGM_REFS_ALL.SOURCE_REF_DOCUMENT_TYPE%TYPE                  ,
                                            p_app_from_document_id       IN            JAI_RGM_REFS_ALL.APP_FROM_DOCUMENT_ID%TYPE      DEFAULT NULL    ,
                                            p_app_from_document_type     IN            JAI_RGM_REFS_ALL.APP_FROM_DOCUMENT_TYPE%TYPE    DEFAULT NULL    ,
                                            p_app_to_document_id         IN            JAI_RGM_REFS_ALL.APP_TO_DOCUMENT_ID%TYPE        DEFAULT NULL    ,
                                            p_app_to_document_type       IN            JAI_RGM_REFS_ALL.APP_TO_DOCUMENT_TYPE%TYPE      DEFAULT NULL    ,
                                            p_parent_transaction_id      IN            JAI_RGM_REFS_ALL.PARENT_TRANSACTION_ID%TYPE     DEFAULT NULL    ,
                                            p_org_tan_no                 IN            JAI_RGM_REFS_ALL.ORG_TAN_NO%TYPE                DEFAULT NULL    ,
                                            p_document_id                IN            NUMBER                                                          ,
                                            p_document_type              IN            VARCHAR2                                                        ,
                                            p_document_line_id           IN            NUMBER                                                          ,
                                            p_document_date              IN            DATE                                                            ,
                                            p_table_name                 IN            VARCHAR2                                                        ,
                                            p_line_amount                IN            NUMBER                                                          ,
                                            p_document_amount            IN            NUMBER                                                          ,
                                            p_org_id                     IN            NUMBER                                                          ,
                                            p_organization_id            IN            NUMBER                                                          ,
                                            p_party_id                   IN            NUMBER                                                          ,
                                            p_party_site_id              IN            NUMBER                                                          ,
                                            p_item_classification        IN            VARCHAR2                                                        ,
                                            p_trx_ref_id                 OUT NOCOPY    JAI_RGM_REFS_ALL.TRX_REF_ID%TYPE                                ,
                                            p_process_flag               OUT NOCOPY    VARCHAR2                                                        ,
                                            p_process_message            OUT NOCOPY    VARCHAR2
                                        )

  IS

    /****
    ||Get the primary key
    || for the table jai_rgm_refs_all
    *****/
    ln_reg_id           NUMBER;
    ln_regime_id                    JAI_RGM_DEFINITIONS.REGIME_ID%TYPE                        ;
    lv_org_tan_no                   JAI_RGM_REGISTRATIONS.ATTRIBUTE_VALUE%TYPE                ;
    ln_trx_ref_id                   JAI_RGM_REFS_ALL.TRX_REF_ID%TYPE                  ;
    lv_process_flag                 VARCHAR2(2)                                       ;
    lv_process_message              VARCHAR2(2000)                                    ;
    ln_user_id                      JAI_RGM_REFS_ALL.CREATED_BY%TYPE                  ;
    ln_login_id                     JAI_RGM_REFS_ALL.LAST_UPDATE_LOGIN%TYPE           ;
    ln_fin_year                     JAI_AP_TDS_YEARS.FIN_YEAR%TYPE                 ;
    ln_source_ref_document_id       JAI_RGM_REFS_ALL.SOURCE_REF_DOCUMENT_ID%TYPE      ;
    ln_source_ref_document_type     JAI_RGM_REFS_ALL.SOURCE_REF_DOCUMENT_TYPE%TYPE    ;
    ln_threshold_slab_id            JAI_RGM_REFS_ALL.THRESHOLD_SLAB_ID%TYPE           ;
  BEGIN

  /*################################################################################################################
  || Initialize the variables
  ################################################################################################################*/
  lv_member_name        := 'INSERT_REPOSITORY_REFERENCES';
  set_debug_context;
  /*commented by csahoo for bug# 6401388
  jai_cmn_debug_contexts_pkg.register ( pv_context => lv_context
                             , pn_reg_id  => ln_reg_id
                             );*/

  /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                             pv_log_msg  =>  ' PARAMETERS VALUES PASSED TO INSERT_REPOSITORY_REFERENCES : - '  ||fnd_global.local_chr(10)
                                           ||', p_regime_id                   -> '||p_regime_id                ||fnd_global.local_chr(10)
                                           ||', p_transaction_id              -> '||p_transaction_id           ||fnd_global.local_chr(10)
                                           ||', p_source_ref_document_id      -> '||p_source_ref_document_id   ||fnd_global.local_chr(10)
                                           ||', p_source_ref_document_type    -> '||p_source_ref_document_type ||fnd_global.local_chr(10)
                                           ||', p_app_from_document_id        -> '||p_app_from_document_id     ||fnd_global.local_chr(10)
                                           ||', p_app_from_document_type      -> '||p_app_from_document_type   ||fnd_global.local_chr(10)
                                           ||', p_app_to_document_id          -> '||p_app_to_document_id       ||fnd_global.local_chr(10)
                                           ||', p_app_to_document_type        -> '||p_app_to_document_type     ||fnd_global.local_chr(10)
                                           ||', p_parent_transaction_id       -> '||p_parent_transaction_id    ||fnd_global.local_chr(10)
                                           ||', p_org_tan_no                  -> '||p_org_tan_no              ||fnd_global.local_chr(10)
                                           ||', p_document_id                 -> '||p_document_id              ||fnd_global.local_chr(10)
                                           ||', p_document_type               -> '||p_document_type            ||fnd_global.local_chr(10)
                                           ||', p_document_line_id            -> '||p_document_line_id         ||fnd_global.local_chr(10)
                                           ||', p_document_date               -> '||p_document_date            ||fnd_global.local_chr(10)
                                           ||', p_table_name                  -> '||p_table_name               ||fnd_global.local_chr(10)
                                           ||', p_line_amount                 -> '||p_line_amount              ||fnd_global.local_chr(10)
                                           ||', p_document_amount             -> '||p_document_amount          ||fnd_global.local_chr(10)
                                           ||', p_org_id                      -> '||p_org_id                   ||fnd_global.local_chr(10)
                                           ||', p_organization_id             -> '||p_organization_id          ||fnd_global.local_chr(10)
                                           ||', p_party_id                    -> '||p_party_id                 ||fnd_global.local_chr(10)
                                           ||', p_party_site_id               -> '||p_party_site_id            ||fnd_global.local_chr(10)
                                           ||', p_item_classification         -> '||p_item_classification      ||fnd_global.local_chr(10)
                                           ||', p_trx_ref_id                  -> '||p_trx_ref_id               ||fnd_global.local_chr(10)
                          );*/


    lv_process_flag    := jai_constants.successful   ;
    lv_process_message := null                       ;

    p_process_flag     := lv_process_flag            ;
    p_process_message  := lv_process_message         ;

    ln_user_id         := fnd_global.user_id         ;
    ln_login_id        := fnd_global.login_id        ;

   OPEN  cur_get_trx_ref_id ;
   FETCH cur_get_trx_ref_id INTO ln_trx_ref_id ;
   CLOSE cur_get_trx_ref_id ;

   /**********
   || IF source_ref_document_id and source_ref_document_type  are null then they should be same as
   || trx_ref_id.
   || The value for source_ref_document_id and source_ref_document_type would be different from trx_ref_id only in case of reversal,application and unapplication
   || in which case it would be same as the corresponding source receipt or invoice
   ************/
   p_trx_ref_id     := ln_trx_ref_id     ;

   ln_source_ref_document_id := NVL(p_source_ref_document_id,p_document_id) ;

   OPEN  get_tcs_fin_year(  cp_org_id    => p_org_id         ,
                            cp_trx_date  => p_document_date
                         );

   FETCH get_tcs_fin_year INTO ln_fin_year;
   CLOSE get_tcs_fin_year;

  /*********
  || Get the regime_id and org_tan_no in case the p_regime_id or p_org_tan_no is null
  *********/
   IF p_regime_id   IS NULL OR
      p_org_tan_no IS NULL
   THEN
    /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                pv_log_msg  => ' Derive regime values as they are null  '
                              );*/
     OPEN c_get_rgm_attribute (   cp_regime_code           =>   jai_constants.tcs_regime                  ,
                                  cp_attribute_code        =>   jai_constants.rgm_attr_code_org_tan       ,
                                  cp_organization_id       =>   p_organization_id
                               ) ;
     FETCH c_get_rgm_attribute INTO ln_regime_id, lv_org_tan_no ;
     IF C_GET_RGM_ATTRIBUTE%NOTFOUND THEN
       CLOSE c_get_rgm_attribute;
       p_process_flag     := jai_constants.expected_error;
       p_process_message  := 'Org Tan Number needs to be defined for the TCS regime ';
       return;
     END IF;
     CLOSE c_get_rgm_attribute;

     /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                pv_log_msg  => 'Regime values are '
                                ||', ln_regime_id   -> '||ln_regime_id
                                ||', lv_org_tan_no -> '||lv_org_tan_no
                              );*/

    ELSE
      ln_regime_id    := p_regime_id   ;
      lv_org_tan_no   := p_org_tan_no ;
    END IF;

     /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                pv_log_msg  => 'Regime values are '
                                ||', ln_regime_id   -> '||ln_regime_id
                                ||', lv_org_tan_no -> '||lv_org_tan_no
                              );*/

  /*################################################################################################################
  || INSERT THE DOCUMENT RECORD INTO THE TCS REPOSITORY
  ################################################################################################################*/


      /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                 pv_log_msg  =>  ' VALUES insert into JAI_RGM_REFS_ALL are : - ' ||fnd_global.local_chr(10)
                                               ||', trx_ref_id                -> '||p_trx_ref_id                      ||fnd_global.local_chr(10)
                                               ||', regime_id                 -> '||ln_regime_id                      ||fnd_global.local_chr(10)
                                               ||', transaction_id            -> '||p_transaction_id                  ||fnd_global.local_chr(10)
                                               ||', source_ref_document_id    -> '||ln_source_ref_document_id         ||fnd_global.local_chr(10)
                                               ||', source_ref_document_type  -> '||p_source_ref_document_type        ||fnd_global.local_chr(10)
                                               ||', app_from_document_id      -> '||p_app_from_document_id            ||fnd_global.local_chr(10)
                                               ||', app_from_document_ty      -> '||p_app_from_document_type          ||fnd_global.local_chr(10)
                                               ||', app_to_document_id        -> '||p_app_to_document_id              ||fnd_global.local_chr(10)
                                               ||', app_to_document_type      -> '||p_app_to_document_type            ||fnd_global.local_chr(10)
                                               ||', parent_transaction_id     -> '||p_parent_transaction_id           ||fnd_global.local_chr(10)
                                               ||', org_tan_no                -> '||lv_org_tan_no                     ||fnd_global.local_chr(10)
                                               ||', source_document_id        -> '||p_document_id                     ||fnd_global.local_chr(10)
                                               ||', source_document_line      -> '||p_document_line_id                ||fnd_global.local_chr(10)
                                               ||', source_document_type      -> '||p_document_type                   ||fnd_global.local_chr(10)
                                               ||', source_document_date      -> '||p_document_date                   ||fnd_global.local_chr(10)
                                               ||', source_table_name         -> '||p_table_name                      ||fnd_global.local_chr(10)
                                               ||', line_amt                  -> '||p_line_amount                     ||fnd_global.local_chr(10)
                                               ||', source_document_amt       -> '||p_document_amount                 ||fnd_global.local_chr(10)
                                               ||', total_tax_amt             -> '||NULL                              ||fnd_global.local_chr(10)
                                               ||', party_id                  -> '||p_party_id                        ||fnd_global.local_chr(10)
                                               ||', party_type                -> '||jai_constants.party_type_customer ||fnd_global.local_chr(10)
                                               ||', party_site_id             -> '||p_party_site_id                   ||fnd_global.local_chr(10)
                                               ||', item_classification       -> '||p_item_classification             ||fnd_global.local_chr(10)
                                               ||', org_id                    -> '||p_org_id                          ||fnd_global.local_chr(10)
                                               ||', organization_id           -> '||p_organization_id                 ||fnd_global.local_chr(10)
                                               ||', fin_year                  -> '||ln_fin_year                       ||fnd_global.local_chr(10)
                                               ||', threshold_slab_id         -> '||ln_threshold_slab_id              ||fnd_global.local_chr(10)
                                               ||', created_by                -> '||ln_user_id                        ||fnd_global.local_chr(10)
                                               ||', creation_date             -> '||sysdate                           ||fnd_global.local_chr(10)
                                               ||', last_updated_by           -> '||ln_user_id                        ||fnd_global.local_chr(10)
                                               ||', last_update_date          -> '||sysdate                           ||fnd_global.local_chr(10)
                                               ||', last_update_login         -> '||ln_login_id                       ||fnd_global.local_chr(10)
                                               ||', settlement_id             -> '||NULL                              ||fnd_global.local_chr(10)
                                               ||', certificate_id            -> '||NULL
                              );*/

   INSERT into jai_rgm_refs_all (
                                    trx_ref_id                                  ,
                                    regime_id                                   ,
                                    transaction_id                              ,
                                    source_ref_document_id                      ,
                                    source_ref_document_type                    ,
                                    app_from_document_id                        ,
                                    app_from_document_type                      ,
                                    app_to_document_id                          ,
                                    app_to_document_type                        ,
                                    parent_transaction_id                       ,
                                    org_tan_no                                  ,
                                    source_document_id                          ,
                                    source_document_line_id                     ,
                                    source_document_type                        ,
                                    source_document_date                        ,
                                    source_table_name                           ,
                                    line_amt                                    ,
                                    source_document_amt                         ,
                                    total_tax_amt                               ,
                                    party_id                                    ,
                                    party_type                                  ,
                                    party_site_id                               ,
                                    item_classification                         ,
                                    org_id                                      ,
                                    organization_id                             ,
                                    fin_year                                    ,
                                    threshold_slab_id                           ,
                                    created_by                                  ,
                                    creation_date                               ,
                                    last_updated_by                             ,
                                    last_update_date                            ,
                                    last_update_login                           ,
                                    settlement_id                               ,
                                    certificate_id
                                )
                        VALUES  (
                                    p_trx_ref_id                               ,
                                    ln_regime_id                               ,
                                    p_transaction_id                           ,
                                    ln_source_ref_document_id                  ,
                                    p_source_ref_document_type                 ,
                                    p_app_from_document_id                     ,
                                    p_app_from_document_type                   ,
                                    p_app_to_document_id                       ,
                                    p_app_to_document_type                     ,
                                    p_parent_transaction_id                    ,
                                    lv_org_tan_no                              ,
                                    p_document_id                              ,
                                    p_document_line_id                         ,
                                    p_document_type                            ,
                                    p_document_date                            ,
                                    p_table_name                               ,
                                    p_line_amount                              ,
                                    p_document_amount                          ,
                                    NULL                                       ,
                                    p_party_id                                 ,
                                    jai_constants.party_type_customer          ,
                                    p_party_site_id                            ,
                                    p_item_classification                      ,
                                    p_org_id                                   ,
                                    p_organization_id                          ,
                                    ln_fin_year                                ,
                                    ln_threshold_slab_id                       ,
                                    ln_user_id                                 ,
                                    sysdate                                    ,
                                    ln_user_id                                 ,
                                    sysdate                                    ,
                                    ln_login_id                                ,
                                    NULL                                       ,
                                    NULL
                                );

   /*commented by csahoo for bug# 6401388
   jai_cmn_debug_contexts_pkg.deregister (pn_reg_id => ln_reg_id);*/
  END insert_repository_references;

  procedure insert_repository_taxes (
                                     p_trx_ref_id                         JAI_RGM_REFS_ALL.TRX_REF_ID%TYPE                  ,
                                     p_tax_id                             JAI_RGM_TAXES.TAX_ID%TYPE                         ,
                                     p_tax_type                           JAI_RGM_TAXES.TAX_TYPE%TYPE                       ,
                                     p_tax_rate                           JAI_RGM_TAXES.TAX_RATE%TYPE                       ,
                                     p_tax_amount                         JAI_RGM_TAXES.TAX_AMT%TYPE                        ,
                                     p_func_tax_amount                    JAI_RGM_TAXES.FUNC_TAX_AMT%TYPE                   ,
                                     p_tax_modified_by                    JAI_RGM_TAXES.TAX_MODIFIED_BY%TYPE DEFAULT NULL   ,
                                     p_currency_code                      JAI_RGM_TAXES.CURRENCY_CODE%TYPE                  ,
                                     p_process_flag        OUT NOCOPY     VARCHAR2                                          ,
                                     p_process_message     OUT NOCOPY     VARCHAR2
                                    )


  IS
     ln_reg_id           NUMBER;
    /****
    || Get the orig_tax_percenatge for the tax_id
    || and determine the exemption flag value
    *****/
    CURSOR cur_get_exemption_value
    IS
    SELECT
          orig_tax_percentage
    FROM
          JAI_CMN_TAXES_ALL
    WHERE
          tax_id  = p_tax_id;

    ln_tax_det_id               JAI_RGM_TAXES.TAX_DET_ID%TYPE             ;
    lv_process_flag             VARCHAR2(2)                               ;
    lv_process_message          VARCHAR2(2000)                            ;
    ln_user_id                  JAI_RGM_TAXES.CREATED_BY%TYPE             ;
    ln_login_id                 JAI_RGM_TAXES.LAST_UPDATE_LOGIN%TYPE      ;
    ln_orig_tax_rate            JAI_CMN_TAXES_ALL.ORIG_TAX_PERCENTAGE%TYPE  ;
    ln_exempted_flag            JAI_RGM_TAXES.EXEMPTED_FLAG%TYPE          ;
    ln_tax_modified_by          JAI_RGM_TAXES.TAX_MODIFIED_BY%TYPE        ;
  BEGIN




/***************************************************************************************************
-- #
-- # Change History -


1.  01/02/2007   CSahoo for bug#5631784. File Version 120.0
                 Forward Porting of 11i BUG#4742259 (TAX COLLECTION AT SOURCE IN RECEIVABLES)

2.  15/06/2007   brahtod, bug#6132484, File Version 120.1
                 Issue: ERROR WHILE TRYING TO APPLY  INVOICE TO CASH RECEIPT .
                 Fix:  cursor cur_get_app_to_det is changed in process_application to fetch bill_to_site_use_id

3.  19/-6/2007   sacsethi , bug 6137956 File version 120.2

     Problem - In Auto Invoice master  program  , Transaction number created for TCS Type of receipt method was
               not coming

           Solution -In Table RA_CUSTOMER_TRX_LINES_ALL , Org_id column was null
4.  10-Sep-2007  CSahoo for bug#6401388, File Version120.4.12000000.7
                  commented the code related to jai_cmn_debug_context_pkg package.
                  removed all the debug messages meant for debugging.

5.  19-Feb-2009  CSahoo for bug#8214204, File Version 120.11.12010000.3
                 added the code to insert into the table ra_interface_salescredits_all
                 in the procedure generate_document.
6.  20-Feb-2009  JMEENA for bug#8241099
      Modified cursor cur_chk_tcs_for_all_lines in procedure validate_invoice and added condition to filter discount lines while validating TCS taxes.

7.  23-Feb-2009  CSahoo for bug#8214204, File Version 120.11.12010000.6
                 Reverted back the changes made for the bug in file version 120.11.12010000.3

8.  11-Sep-2008  CSahoo for bug#7393380, File Version 120.11.12010000.7
                 ISSUE: TCS CREDIT MEMO IS GETTING DEBITED IN THE SETTLEMENT INSTEAD OF GETTING CREDITED
                 FIX:  modified the code in the procedure process_applications. Here the ln_apportion_factor
                       should be negative for receipt application
9.  18-May-2009  CSahoo for bug#8517919, File Version 120.11.12010000.8
                 Modified the code in generate_document procedure. Replaced the Localization tax_code by NULL
                 in the insert statement.

10.  15-APR-2010 vkaranam for bug#9587338
                 issue:
                 wrong journal source and category passed for TCS taxes.
                 fix:
                 changes are done in ar_accounting,wsh_interim_Accounting

                 source='Receivables India'
                 category ='India Tax Collected'.

*******************************************************************************************************/

    /*################################################################################################################
    || Initialize the variables
    ################################################################################################################*/
    lv_member_name        := 'INSERT_REPOSITORY_TAXES';
    set_debug_context;
    /*commented by csahoo for bug# 6401388
   jai_cmn_debug_contexts_pkg.register ( pv_context => lv_context
                               , pn_reg_id  => ln_reg_id
                               );*/

  /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                             pv_log_msg  =>  ' PARAMETERS VALUES PASSED TO INSERT_REPOSITORY_TAXES : - '||fnd_global.local_chr(10)
                                           ||', p_trx_ref_id       -> '||p_trx_ref_id      ||fnd_global.local_chr(10)
                                           ||', p_tax_id           -> '||p_tax_id          ||fnd_global.local_chr(10)
                                           ||', p_tax_type         -> '||p_tax_type        ||fnd_global.local_chr(10)
                                           ||', p_tax_rate         -> '||p_tax_rate        ||fnd_global.local_chr(10)
                                           ||', p_tax_amount       -> '||p_tax_amount      ||fnd_global.local_chr(10)
                                           ||', p_func_tax_amount  -> '||p_func_tax_amount ||fnd_global.local_chr(10)
                                           ||', p_tax_modified_by  -> '||p_tax_modified_by ||fnd_global.local_chr(10)
                                           ||', p_currency_code    -> '||p_currency_code   ||fnd_global.local_chr(10)
                                           ||', p_process_flag     -> '||p_process_flag    ||fnd_global.local_chr(10)
                                           ||', p_process_message  -> '||p_process_message ||fnd_global.local_chr(10)
                          );*/


    lv_process_flag    := jai_constants.successful   ;
    lv_process_message := null                       ;

    p_process_flag     := lv_process_flag            ;
    p_process_message  := lv_process_message         ;

    ln_user_id         := fnd_global.user_id         ;
    ln_login_id        := fnd_global.login_id        ;

    /*******
    || Get the tax_det_id - primary key for
    || the table jai_rgm_taxes
    *******/
    OPEN  cur_get_tax_det_id ;
    FETCH cur_get_tax_det_id INTO ln_tax_det_id;
    CLOSE cur_get_tax_det_id;

    /*################################################################################################################
    || DETERMINE THE VALUE FOR TAX EXEMPTION FLAG
    ################################################################################################################*/

    /*******
    || Get the orig_ta_rate of the tax_id
    || the table jai_rgm_taxes
    *******/
    OPEN  cur_get_exemption_value;
    FETCH cur_get_exemption_value INTO ln_orig_tax_rate;
    CLOSE cur_get_exemption_value;

    /********************************************************************************************
    || Determine the tax exemption flag - this value would classify a tax as being of
    || Standard Rate ('SR'), Lower Rate ('LR') or Zero Rate ('ZR').
    || TCS reports would group by this and query
    ||=====================================================================================
    ||                         || RATE  || ORIG_TAX_PERCENTAGE|| Exempted_flag ||
    ||                         ||-------||--------------------||---------------||
    ||          Standard Rate  ||   10  ||    10 or Null      || 'SR'          ||
    ||          Lower Rate     ||   5   ||    10              || 'LR'          ||
    ||          Zero Rate      ||   0   ||   Null or not null || 'ZR'          ||
    ||=====================================================================================
    **********************************************************************************************/
    IF ln_orig_tax_rate IS NULL        OR
       ln_orig_tax_rate  = p_tax_rate
    THEN

      ln_exempted_flag := jai_constants.tax_exmpt_flag_std_rate    ;

    ELSIF ln_orig_tax_rate > p_tax_rate THEN /*rchandan for bug#4742259*/

      ln_exempted_flag := jai_constants.tax_exmpt_flag_lower_rate  ;

    ELSIF p_tax_rate = 0 THEN
      ln_exempted_flag := jai_constants.tax_exmpt_flag_zero_rate   ;
    END IF;



   /*
   || Determine the Tax modified by flag flag in case it is null
   */
   ln_tax_modified_by := nvl(p_tax_modified_by ,jai_constants.tax_modified_by_system );

  /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                             pv_log_msg  =>  ' VALUES insert into JAI_RGM_TAXES are : - '                 ||fnd_global.local_chr(10)
                                           ||', tax_det_id        -> '||ln_tax_det_id                     ||fnd_global.local_chr(10)
                                           ||', trx_ref_id        -> '||p_trx_ref_id                      ||fnd_global.local_chr(10)
                                           ||', tax_type          -> '||p_tax_type                        ||fnd_global.local_chr(10)
                                           ||', tax_amt           -> '||round(nvl(p_tax_amount,0))        ||fnd_global.local_chr(10)
                                           ||', tax_id            -> '||p_tax_id                          ||fnd_global.local_chr(10)
                                           ||', func_tax_amt      -> '||round(nvl(p_func_tax_amount,0))   ||fnd_global.local_chr(10)
                                           ||', currency_code     -> '||p_currency_code                   ||fnd_global.local_chr(10)
                                           ||', exempted_flag     -> '||ln_exempted_flag                  ||fnd_global.local_chr(10)
                                           ||', tax_modified_by   -> '||ln_tax_modified_by                ||fnd_global.local_chr(10)
                                           ||', created_by        -> '||ln_user_id                        ||fnd_global.local_chr(10)
                                           ||', creation_date     -> '||sysdate                           ||fnd_global.local_chr(10)
                                           ||', last_updated_by   -> '||ln_user_id                        ||fnd_global.local_chr(10)
                                           ||', last_update_date  -> '||sysdate                           ||fnd_global.local_chr(10)
                                           ||', last_update_login -> '||ln_login_id
                         );*/


     INSERT into jai_rgm_taxes (
                                  tax_det_id                        ,
                                  trx_ref_id                        ,
                                  tax_type                          ,
                                  tax_amt                           ,
                                  tax_id                            ,
                                  tax_rate                          ,
                                  func_tax_amt                      ,
                                  currency_code                     ,
                                  tax_modified_by                   ,
                                  exempted_flag                     ,
                                  created_by                        ,
                                  creation_date                     ,
                                  last_updated_by                   ,
                                  last_update_date                  ,
                                  last_update_login
                                )
                         VALUES (
                                  ln_tax_det_id                     ,
                                  p_trx_ref_id                      ,
                                  p_tax_type                        ,
                                  round(nvl(p_tax_amount,0))        ,
                                  p_tax_id                          ,
                                  p_tax_rate                        ,
                                  round(nvl(p_func_tax_amount,0))   ,
                                  p_currency_code                   ,
                                  ln_tax_modified_by                ,
                                  ln_exempted_flag                  ,
                                  ln_user_id                        ,
                                  sysdate                           ,
                                  ln_user_id                        ,
                                  sysdate                           ,
                                  ln_login_id
                               );

   /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                               pv_log_msg  =>  ' Insert successful'
                            );*/
     UPDATE
            jai_rgm_refs_all
     SET
            total_tax_amt  = nvl(total_tax_amt,0) + nvl(p_tax_amount,0)
     WHERE
            trx_ref_id = p_trx_ref_id;

   /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                               pv_log_msg  =>  ' jai_rgm_refs_all.total_tax_amt successfully updated  '
                            );*/
  /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                             pv_log_msg  =>  '**************** END OF INSERT_REPOSITORY_TAXES ****************'
                          );
    jai_cmn_debug_contexts_pkg.deregister (pn_reg_id => ln_reg_id);*/
  END insert_repository_taxes ;


PROCEDURE copy_taxes_from_source  ( p_source_document_type    IN            JAI_RGM_REFS_ALL.SOURCE_DOCUMENT_TYPE%TYPE                    ,
                                    p_source_document_id      IN            JAI_RGM_REFS_ALL.SOURCE_DOCUMENT_ID%TYPE                      ,
                                    p_source_document_line_id IN            JAI_RGM_REFS_ALL.SOURCE_DOCUMENT_LINE_ID%TYPE  DEFAULT NULL   ,
                                    p_apportion_factor        IN            NUMBER                                         DEFAULT NULL   ,
                                    p_trx_ref_id              IN            JAI_RGM_REFS_ALL.TRX_REF_ID%TYPE                              ,
                                    p_process_flag            OUT NOCOPY    VARCHAR2                                                      ,
                                    p_process_message         OUT NOCOPY    VARCHAR2
                                  )
IS

  ln_reg_id           NUMBER;
  /*****
  ||Get the Invoice tax details
  ******/
  CURSOR cur_get_inv_taxes ( cp_customer_trx_id      JAI_AR_TRX_LINES.CUSTOMER_TRX_ID%TYPE     ,
                             cp_customer_trx_line_id JAI_AR_TRX_LINES.CUSTOMER_TRX_LINE_ID%TYPE
                           )
  IS
  SELECT
         jrcttl.customer_trx_line_id                      ,
         jrcttl.tax_id                                    ,
         jrcttl.tax_rate                                  ,
         jtc.tax_type                                     ,
         jrcttl.tax_amount                                ,
         jrcttl.func_tax_amount                           ,
         jrct.invoice_currency_code       currency_code
  FROM
         JAI_AR_TRXS            jrct            ,
         JAI_AR_TRX_LINES      jrctl           ,
         JAI_AR_TRX_TAX_LINES      jrcttl          ,
         JAI_CMN_TAXES_ALL                  jtc             ,
         jai_regime_tax_types_v           jrttv
  WHERE
         jrct.customer_trx_id             = cp_customer_trx_id
  AND    jrct.customer_trx_id             = jrctl.customer_trx_id
  AND    jrctl.customer_trx_line_id       = jrcttl.link_to_cust_trx_line_id
  AND    jrctl.customer_trx_line_id       = nvl( cp_customer_trx_line_id , jrctl.customer_trx_line_id )
  AND    jrcttl.tax_id                    = jtc.tax_id
  AND    jrttv.tax_type                   = jtc.tax_type
  AND    jrttv.regime_code                = jai_constants.tcs_regime;


  /*****
  ||Get the receipt tax details
  *****/
  CURSOR cur_get_rcpt_taxes (cp_source_doc_id  jai_cmn_document_taxes.SOURCE_DOC_ID%TYPE )
  IS
  SELECT
         jdt.tax_id                      ,
         jdt.tax_rate                    ,
         jdt.tax_type                    ,
         jdt.tax_amt                     ,
         jdt.func_tax_amt                ,
         jdt.currency_code
  FROM
         jai_cmn_document_taxes     jdt  ,
         jai_regime_tax_types_v     jrttv
  WHERE
         jdt.tax_type      = jrttv.tax_type
  AND    jdt.source_doc_id = cp_source_doc_id
  AND    jrttv.regime_code = jai_constants.tcs_regime
  AND    jdt.source_doc_type = JAI_CONSTANTS.ar_cash;  --added by eric for a bug

  lv_process_flag           VARCHAR2(2)         ;
  lv_process_message        VARCHAR2(2000)      ;
  ln_apportion_factor       NUMBER              ;
BEGIN
  /*########################################################################################################
  || VARIABLES INITIALIZATION
  ########################################################################################################*/
  lv_member_name        := 'COPY_TAXES_FROM_SOURCE';
  set_debug_context;
  /*commented by csahoo for bug# 6401388
  jai_cmn_debug_contexts_pkg.register ( pv_context => lv_context
                               , pn_reg_id  => ln_reg_id
                               );*/

  /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                             pv_log_msg  =>  ' PARAMETERS VALUES PASSED TO COPY_TAXES_FROM_SOURCE : - '  ||fnd_global.local_chr(10)
                                           ||', p_source_document_type     -> '||p_source_document_type    ||fnd_global.local_chr(10)
                                           ||', p_source_document_id       -> '||p_source_document_id      ||fnd_global.local_chr(10)
                                           ||', p_source_document_line_id  -> '||p_source_document_line_id ||fnd_global.local_chr(10)
                                           ||', p_apportion_factor         -> '||p_apportion_factor        ||fnd_global.local_chr(10)
                                           ||', p_trx_ref_id               -> '||p_trx_ref_id              ||fnd_global.local_chr(10)
                          );*/

  lv_process_flag    := jai_constants.successful   ;
  lv_process_message := null                       ;

  p_process_flag     := lv_process_flag            ;
  p_process_message  := lv_process_message         ;

  ln_apportion_factor:= nvl(p_apportion_factor,1);


  /*########################################################################################################
  || Default taxes from Invoice
  ########################################################################################################*/


  IF p_source_document_type IN (                                                   --------------------------A1
                                 jai_constants.trx_type_inv_comp   ,   /* From  Invoice completion */
                                 jai_constants.trx_type_inv_incomp ,   /* From  Invoice Incompletion */
                                 jai_constants.ar_invoice_type_inv ,   /* From  Application */
                                 jai_constants.ar_doc_type_dm      ,  /* From  Application */
                                 jai_constants.ar_invoice_type_cm     /* From  Application */
                               )
  THEN
    /***
    || Source is INVOICE/DM/CM
    || Loop through each tax line of the invoice to hit
    || the TCS tax repository table jai_rgm_taxes
    ***/

   /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                               pv_log_msg  =>  ' copy TAXES From JAI_AR_TRX_TAX_LINES - p_source_document_type -> '||p_source_document_type
                            );*/
    FOR rec_cur_get_inv_taxes IN cur_get_inv_taxes (  cp_customer_trx_id      => p_source_document_id          ,
                                                      cp_customer_trx_line_id => p_source_document_line_id
                                                   )
    LOOP

      insert_repository_taxes  (
                                  p_trx_ref_id          =>  p_trx_ref_id                                                  ,
                                  p_tax_id              =>  rec_cur_get_inv_taxes.tax_id                                  ,
                                  p_tax_type            =>  rec_cur_get_inv_taxes.tax_type                                ,
                                  p_tax_rate            =>  rec_cur_get_inv_taxes.tax_rate                                ,
                                  p_tax_amount          =>  rec_cur_get_inv_taxes.tax_amount      * ln_apportion_factor   ,
                                  p_func_tax_amount     =>  rec_cur_get_inv_taxes.func_tax_amount * ln_apportion_factor   ,
                                  p_currency_code       =>  rec_cur_get_inv_taxes.currency_code                           ,
                                  p_process_flag        =>  lv_process_flag                                               ,
                                  p_process_message     =>  lv_process_message
                               );

      IF lv_process_flag = jai_constants.expected_error    OR                      ---------A2
         lv_process_flag = jai_constants.unexpected_error  OR
         lv_process_flag = jai_constants.not_applicable
      THEN
        /*
        || As Returned status is an error/not applicable hence:-
        || Set out variables p_process_flag and p_process_message accordingly
        */
        --call to debug package
      /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                  pv_log_msg  =>  ' Error : - lv_process_flag -> '||lv_process_flag||' - '||lv_process_message
                                );*/

        p_process_flag    := lv_process_flag    ;
        p_process_message := lv_process_message ;
        return;
      END IF;                                                                      ---------A2
    END LOOP;

  ELSIF p_source_document_type = jai_constants.ar_cash_tax_confirmed THEN
    /*
    ||Source is receipt
    */
   /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                               pv_log_msg  =>  ' copy TAXES From jai_cmn_document_taxes - p_source_document_id -> '||p_source_document_id
                                              ||', p_source_document_type -> '||p_source_document_type
                            );*/
      FOR rec_cur_get_rcpt_taxes IN cur_get_rcpt_taxes (cp_source_doc_id  => p_source_document_id )
      LOOP

        insert_repository_taxes  (
                                    p_trx_ref_id          =>  p_trx_ref_id                                                  ,
                                    p_tax_id              =>  rec_cur_get_rcpt_taxes.tax_id                                 ,
                                    p_tax_type            =>  rec_cur_get_rcpt_taxes.tax_type                               ,
                                    p_tax_rate            =>  rec_cur_get_rcpt_taxes.tax_rate                               ,
                                    p_tax_amount          =>  rec_cur_get_rcpt_taxes.tax_amt      * ln_apportion_factor     ,
                                    p_func_tax_amount     =>  rec_cur_get_rcpt_taxes.func_tax_amt * ln_apportion_factor     ,
                                    p_currency_code       =>  rec_cur_get_rcpt_taxes.currency_code                          ,
                                    p_process_flag        =>  lv_process_flag                                               ,
                                    p_process_message     =>  lv_process_message
                                 );

        IF lv_process_flag = jai_constants.expected_error    OR                      ---------A3
           lv_process_flag = jai_constants.unexpected_error  OR
           lv_process_flag = jai_constants.not_applicable
        THEN
          /*
          || As Returned status is an error/not applicable hence:-
          || Set out variables p_process_flag and p_process_message accordingly
          */
          --call to debug package
        /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                    pv_log_msg  =>  ' Error : - lv_process_flag -> '||lv_process_flag||' - '||lv_process_message
                                  );*/

          p_process_flag    := lv_process_flag    ;
          p_process_message := lv_process_message ;
          return;
        END IF;                                                                      ---------A3
      END LOOP;

  END IF;                                                                                --------------------------A1

   /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                               pv_log_msg  =>  '****************COPY_TAXES_FROM_SOURCE ENDS SUCCESSFULLY ****************'
                          );
    jai_cmn_debug_contexts_pkg.deregister (pn_reg_id => ln_reg_id);*/
END copy_taxes_from_source;

PROCEDURE copy_references (    p_parent_transaction_id   IN               JAI_RGM_REFS_ALL.PARENT_TRANSACTION_ID%TYPE DEFAULT NULL  ,
                               p_new_document_id         IN               JAI_RGM_REFS_ALL.SOURCE_DOCUMENT_ID%TYPE                  ,
                               p_new_document_type       IN               JAI_RGM_REFS_ALL.SOURCE_DOCUMENT_TYPE%TYPE                ,
                               p_new_document_date       IN               DATE                                                      ,
                               p_apportion_factor        IN               NUMBER                                     DEFAULT 1      ,
                               p_process_flag            OUT NOCOPY       VARCHAR2                                                  ,
                               p_process_message         OUT NOCOPY       VARCHAR2
                          )
  IS

  ln_reg_id           NUMBER;
  CURSOR cur_get_refs
  IS
  SELECT
         *
  FROM
        jai_rgm_refs_all
  WHERE
       transaction_id = p_parent_transaction_id;

  CURSOR cur_get_rgm_taxes ( cp_trx_ref_id JAI_RGM_TAXES.TRX_REF_ID%TYPE )
  IS
  SELECT
         *
  FROM
        jai_rgm_taxes
  WHERE
       trx_ref_id = cp_trx_ref_id;

  rec_cur_get_refs        CUR_GET_REFS%ROWTYPE                     ;
  ln_trx_ref_id           JAI_RGM_REFS_ALL.TRX_REF_ID%TYPE         ;
  ln_tax_det_id           JAI_RGM_TAXES.TAX_DET_ID%TYPE            ;
  ln_apportion_ratio      NUMBER                                   ;
  ln_user_id              JAI_RGM_REFS_ALL.CREATED_BY%TYPE         ;
  ln_login_id             JAI_RGM_REFS_ALL.LAST_UPDATE_LOGIN%TYPE  ;
  ln_regime_id            JAI_RGM_DEFINITIONS.REGIME_ID%TYPE               ;
  lv_org_tan_no           JAI_RGM_REGISTRATIONS.ATTRIBUTE_VALUE%TYPE       ;
  ln_threshold_slab_id    JAI_RGM_REFS_ALL.THRESHOLD_SLAB_ID%TYPE  ;
  lv_process_flag         VARCHAR2(2)                              ;
  lv_process_message      VARCHAR2(4000)                           ;
BEGIN

    /*################################################################################################################
    || Initialize the variables
    ################################################################################################################*/

    lv_member_name        := 'COPY_REFERENCES';
    set_debug_context;
    /*commented by csahoo for bug# 6401388
   jai_cmn_debug_contexts_pkg.register ( pv_context => lv_context
                                 , pn_reg_id  => ln_reg_id
                                 );*/

   /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                              pv_log_msg  =>  ' PARAMETERS VALUES PASSED TO COPY_REFERENCES : - '      ||fnd_global.local_chr(10)
                                            ||', p_parent_transaction_id  -> '||p_parent_transaction_id  ||fnd_global.local_chr(10)
                                            ||', p_new_document_id        -> '||p_new_document_id        ||fnd_global.local_chr(10)
                                            ||', p_new_document_type      -> '||p_new_document_type      ||fnd_global.local_chr(10)
                                            ||', p_new_document_date      -> '||p_new_document_date      ||fnd_global.local_chr(10)
                                            ||', p_apportion_factor       -> '||p_apportion_factor       ||fnd_global.local_chr(10)
                           );*/

    lv_process_flag    := jai_constants.successful   ;
    lv_process_message := null                       ;

    p_process_flag     := lv_process_flag            ;
    p_process_message  := lv_process_message         ;

    ln_user_id         := fnd_global.user_id         ;
    ln_login_id        := fnd_global.login_id        ;


    /*########################################################################################################
    || POPULATE JAI_RGM_REFS_ALL ---- PART -2
    ########################################################################################################*/

    /*
    ||Get the sequence generated unique key for the transaction
    */
    OPEN  cur_get_transaction_id ;
    FETCH cur_get_transaction_id INTO ln_transaction_id ;
    CLOSE cur_get_transaction_id ;

    FOR rec_cur_get_refs IN cur_get_refs
    LOOP

      /*
      ||Header needs to be copied from source
      */
      OPEN  cur_get_trx_ref_id ;
      FETCH cur_get_trx_ref_id INTO ln_trx_ref_id ;
      CLOSE cur_get_trx_ref_id ;


     /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                          pv_log_msg  =>  ' VALUES insert into JAI_RGM_REFS_ALL are : - '                                       ||fnd_global.local_chr(10)
                                               ||', regime_id                   -> '||rec_cur_get_refs.regime_id                                ||fnd_global.local_chr(10)
                                               ||', trx_ref_id                  -> '||ln_trx_ref_id                                             ||fnd_global.local_chr(10)
                                               ||', transaction_id              -> '||ln_transaction_id                                         ||fnd_global.local_chr(10)
                                               ||', parent_transaction_id       -> '||p_parent_transaction_id                                   ||fnd_global.local_chr(10)
                                               ||', org_tan_no                  -> '||rec_cur_get_refs.org_tan_no                               ||fnd_global.local_chr(10)
                                               ||', source_document_id          -> '||p_new_document_id                                         ||fnd_global.local_chr(10)
                                               ||', source_document_line_id     -> '||p_new_document_id                                         ||fnd_global.local_chr(10)
                                               ||', source_document_type        -> '||p_new_document_type                                       ||fnd_global.local_chr(10)
                                               ||', source_document_date        -> '||p_new_document_date                                       ||fnd_global.local_chr(10)
                                               ||', source_table_name           -> '||rec_cur_get_refs.source_table_name                        ||fnd_global.local_chr(10)
                                               ||', line_amt                    -> '||p_apportion_factor * rec_cur_get_refs.line_amt            ||fnd_global.local_chr(10)
                                               ||', source_document_amt         -> '||p_apportion_factor * rec_cur_get_refs.source_document_amt ||fnd_global.local_chr(10)
                                               ||', total_tax_amt               -> '||p_apportion_factor * rec_cur_get_refs.total_tax_amt       ||fnd_global.local_chr(10)
                                               ||', source_ref_document_id      -> '||rec_cur_get_refs.source_ref_document_id                   ||fnd_global.local_chr(10)
                                               ||', source_ref_document_type    -> '||rec_cur_get_refs.source_ref_document_type                 ||fnd_global.local_chr(10)
                                               ||', app_from_document_id        -> '||rec_cur_get_refs.app_from_document_id                     ||fnd_global.local_chr(10)
                                               ||', app_from_document_type      -> '||rec_cur_get_refs.app_from_document_type                   ||fnd_global.local_chr(10)
                                               ||', app_to_document_id          -> '||rec_cur_get_refs.app_to_document_id                       ||fnd_global.local_chr(10)
                                               ||', app_to_document_type        -> '||rec_cur_get_refs.app_to_document_type                     ||fnd_global.local_chr(10)
                                               ||', party_id                    -> '||rec_cur_get_refs.party_id                                 ||fnd_global.local_chr(10)
                                               ||', party_type                  -> '||rec_cur_get_refs.party_type                               ||fnd_global.local_chr(10)
                                               ||', party_site_id               -> '||rec_cur_get_refs.party_site_id                            ||fnd_global.local_chr(10)
                                               ||', item_classification         -> '||rec_cur_get_refs.item_classification                      ||fnd_global.local_chr(10)
                                               ||', org_id                      -> '||rec_cur_get_refs.org_id                                   ||fnd_global.local_chr(10)
                                               ||', organization_id             -> '||rec_cur_get_refs.organization_id                          ||fnd_global.local_chr(10)
                                               ||', fin_year                    -> '||rec_cur_get_refs.fin_year                                 ||fnd_global.local_chr(10)
                                               ||', threshold_slab_id           -> '||NULL                                                      ||fnd_global.local_chr(10)
                                               ||', created_by                  -> '||ln_user_id                                                ||fnd_global.local_chr(10)
                                               ||', creation_date               -> '||sysdate                                                   ||fnd_global.local_chr(10)
                                               ||', last_updated_by             -> '||ln_user_id                                                ||fnd_global.local_chr(10)
                                               ||', last_update_date            -> '||sysdate                                                   ||fnd_global.local_chr(10)
                                               ||', last_update_login           -> '||ln_login_id                                               ||fnd_global.local_chr(10)
                                               ||', settlement_id               -> '||NULL
                                               ||', certificate_id              -> '||NULL
                                       );*/

      INSERT into jai_rgm_refs_all (
                                       trx_ref_id                                                             ,
                                       regime_id                                                              ,
                                       transaction_id                                                         ,
                                       parent_transaction_id                                                  ,
                                       org_tan_no                                                             ,
                                       source_document_id                                                     ,
                                       source_document_line_id                                                ,
                                       source_document_type                                                   ,
                                       source_document_date                                                   ,
                                       source_table_name                                                      ,
                                       line_amt                                                               ,
                                       source_document_amt                                                    ,
                                       total_tax_amt                                                          ,
                                       source_ref_document_id                                                 ,
                                       source_ref_document_type                                               ,
                                       app_from_document_id                                                   ,
                                       app_from_document_type                                                 ,
                                       app_to_document_id                                                     ,
                                       app_to_document_type                                                   ,
                                       party_id                                                               ,
                                       party_type                                                             ,
                                       party_site_id                                                          ,
                                       item_classification                                                    ,
                                       org_id                                                                 ,
                                       organization_id                                                        ,
                                       fin_year                                                               ,
                                       threshold_slab_id                                                      ,
                                       created_by                                                             ,
                                       creation_date                                                          ,
                                       last_updated_by                                                        ,
                                       last_update_date                                                       ,
                                       last_update_login                                                      ,
                                       settlement_id                                                          ,
                                       certificate_id
                                    )
                            VALUES  (
                                       ln_trx_ref_id                                                          ,
                                       rec_cur_get_refs.regime_id                                             ,
                                       ln_transaction_id                                                      ,
                                       p_parent_transaction_id                                                ,
                                       rec_cur_get_refs.org_tan_no                                            ,
                                       p_new_document_id                                                      ,
                                       p_new_document_id                                                      ,
                                       p_new_document_type                                                    ,
                                       p_new_document_date                                                    ,
                                       rec_cur_get_refs.source_table_name                                     ,
                                       p_apportion_factor * rec_cur_get_refs.line_amt                         ,
                                       p_apportion_factor * rec_cur_get_refs.source_document_amt              ,
                                       p_apportion_factor * rec_cur_get_refs.total_tax_amt                    ,
                                       rec_cur_get_refs.source_ref_document_id                                ,
                                       rec_cur_get_refs.source_ref_document_type                              ,
                                       rec_cur_get_refs.app_from_document_id                                  ,
                                       rec_cur_get_refs.app_from_document_type                                ,
                                       rec_cur_get_refs.app_to_document_id                                    ,
                                       rec_cur_get_refs.app_to_document_type                                  ,
                                       rec_cur_get_refs.party_id                                              ,
                                       rec_cur_get_refs.party_type                                            ,
                                       rec_cur_get_refs.party_site_id                                         ,
                                       rec_cur_get_refs.item_classification                                   ,
                                       rec_cur_get_refs.org_id                                                ,
                                       rec_cur_get_refs.organization_id                                       ,
                                       rec_cur_get_refs.fin_year                                              ,
                                       NULL                                                                   ,
                                       ln_user_id                                                             ,
                                       sysdate                                                                ,
                                       ln_user_id                                                             ,
                                       sysdate                                                                ,
                                       ln_login_id                                                            ,
                                       NULL                                                                   ,
                                       NULL
                                    );

      /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                          pv_log_msg  =>  ' After Insert into jai_rgm_refs_all'
                                       );*/

      /*
      ||Taxes needs to be copied from source
      */
      FOR rec_cur_get_rgm_taxes IN cur_get_rgm_taxes ( cp_trx_ref_id => rec_cur_get_refs.trx_ref_id )
      LOOP
        /*******
        || Get the tax_det_id - primary key for
        || the table jai_rgm_taxes
        *******/
        OPEN  cur_get_tax_det_id ;
        FETCH cur_get_tax_det_id INTO ln_tax_det_id;
        CLOSE cur_get_tax_det_id;

     /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                 pv_log_msg  =>  ' VALUES insert into JAI_RGM_REFS_ALL are : - ' ||fnd_global.local_chr(10)
                                               ||', tax_det_id          -> '||ln_tax_det_id                                                    ||fnd_global.local_chr(10)
                                               ||', trx_ref_id          -> '||ln_trx_ref_id                                                    ||fnd_global.local_chr(10)
                                               ||', tax_type            -> '||rec_cur_get_rgm_taxes.tax_type                                   ||fnd_global.local_chr(10)
                                               ||', tax_amt             -> '||round( p_apportion_factor * rec_cur_get_rgm_taxes.tax_amt )      ||fnd_global.local_chr(10)
                                               ||', tax_id              -> '||rec_cur_get_rgm_taxes.tax_id                                     ||fnd_global.local_chr(10)
                                               ||', func_tax_amt        -> '||round(p_apportion_factor * rec_cur_get_rgm_taxes.func_tax_amt )  ||fnd_global.local_chr(10)
                                               ||', currency_code       -> '||rec_cur_get_rgm_taxes.currency_code                              ||fnd_global.local_chr(10)
                                               ||', exempted_flag       -> '||rec_cur_get_rgm_taxes.exempted_flag                              ||fnd_global.local_chr(10)
                                               ||', created_by          -> '||ln_user_id                                                       ||fnd_global.local_chr(10)
                                               ||', creation_date       -> '||sysdate                                                          ||fnd_global.local_chr(10)
                                               ||', last_updated_by     -> '||ln_user_id                                                       ||fnd_global.local_chr(10)
                                               ||', last_update_date    -> '||sysdate                                                          ||fnd_global.local_chr(10)
                                               ||', last_update_login   -> '||ln_user_id
                              );*/

        INSERT into jai_rgm_taxes  (
                                    tax_det_id                                                          ,
                                    trx_ref_id                                                          ,
                                    tax_type                                                            ,
                                    tax_amt                                                             ,
                                    tax_id                                                              ,
                                    tax_rate                                                            ,
                                    func_tax_amt                                                        ,
                                    currency_code                                                       ,
                                    tax_modified_by                                                     ,
                                    exempted_flag                                                       ,
                                    created_by                                                          ,
                                    creation_date                                                       ,
                                    last_updated_by                                                     ,
                                    last_update_date                                                    ,
                                    last_update_login
                                  )
                           VALUES (
                                    ln_tax_det_id                                                       ,
                                    ln_trx_ref_id                                                       ,
                                    rec_cur_get_rgm_taxes.tax_type                                      ,
                                    round( p_apportion_factor * rec_cur_get_rgm_taxes.tax_amt )         ,
                                    rec_cur_get_rgm_taxes.tax_id                                        ,
                                    rec_cur_get_rgm_taxes.tax_rate                                      ,
                                    round(p_apportion_factor * rec_cur_get_rgm_taxes.func_tax_amt )     ,
                                    rec_cur_get_rgm_taxes.currency_code                                 ,
                                    rec_cur_get_rgm_taxes.tax_modified_by                               ,
                                    rec_cur_get_rgm_taxes.exempted_flag                                 ,
                                    ln_user_id                                                          ,
                                    sysdate                                                             ,
                                    ln_user_id                                                          ,
                                    sysdate                                                             ,
                                    ln_user_id
                                  );



      /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                 pv_log_msg  =>  ' After Insert into jai_rgm_taxes '
                              );*/
      END LOOP; /* End of tax population */
    END LOOP; /*End of jai_rgm_refs_all population */

   /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                             pv_log_msg  =>  '**************** END OF COPY_REFERENCES ****************'
                          );

    jai_cmn_debug_contexts_pkg.deregister (pn_reg_id => ln_reg_id);*/
  END copy_references;


PROCEDURE   update_item_gen_docs  ( p_trx_number         IN  RA_CUSTOMER_TRX_ALL.TRX_NUMBER%TYPE      ,
                                    p_customer_trx_id    IN  RA_CUSTOMER_TRX_ALL.CUSTOMER_TRX_ID%TYPE ,
                                    p_complete_flag      IN  RA_CUSTOMER_TRX_ALL.COMPLETE_FLAG%TYPE   ,
                                    p_org_id             IN  RA_CUSTOMER_TRX_ALL.ORG_ID%TYPE          ,
                                    p_process_flag       OUT NOCOPY     VARCHAR2                      ,
                                    p_process_message    OUT NOCOPY     VARCHAR2
                                  )
IS
  ln_reg_id                 NUMBER             ;

  CURSOR cur_upd_gen_docs
  IS
  SELECT
          jrigd.rowid            ,
          jrigd.generated_doc_id
  FROM
        jai_rgm_item_gen_docs jrigd,
        jai_rgm_refs_all      jrra
  WHERE
        jrigd.generated_doc_trx_number = p_trx_number
  AND   jrra.transaction_id            = jrigd.transaction_id
  AND   jrra.org_id                    = p_org_id
  FOR UPDATE OF jrigd.generated_doc_id NOWAIT;

  lv_rowid              ROWID                                       ;
  ln_generated_doc_id   JAI_RGM_ITEM_GEN_DOCS.GENERATED_DOC_ID%TYPE ;
  ln_user_id            JAI_RGM_REFS_ALL.CREATED_BY%TYPE            ;
  ln_login_id           JAI_RGM_REFS_ALL.LAST_UPDATE_LOGIN%TYPE     ;

BEGIN

  /*################################################################################################################
  || Initialize the variables
  ################################################################################################################*/

  lv_member_name        := 'UPDATE_ITEM_GEN_DOCS';
  set_debug_context;
  /*commented by csahoo for bug# 6401388
  jai_cmn_debug_contexts_pkg.register ( pv_context => lv_context ,
                                        pn_reg_id  => ln_reg_id
                                      );

 jai_cmn_debug_contexts_pkg.print (  pn_reg_id =>  ln_reg_id ,
                                      pv_log_msg  =>  'VALUES PASSED TO UPDATE_ITEM_GEN_DOCS ARE :- ' ||fnd_global.local_chr(10)
                                                    ||', p_trx_number      -> '||p_trx_number         ||fnd_global.local_chr(10)
                                                    ||', p_customer_trx_id -> '||p_customer_trx_id    ||fnd_global.local_chr(10)
                                                    ||', p_complete_flag   -> '||p_complete_flag      ||fnd_global.local_chr(10)
                                                    ||', p_org_id          -> '||p_org_id
                                   );*/

  p_process_flag    := jai_constants.successful   ;
  p_process_message := null                       ;

  ln_user_id         := fnd_global.user_id        ;
  ln_login_id        := fnd_global.login_id       ;

  /*################################################################################################################
  || UPDATE THE TABLE JAI_RGM_ITEM_GEN_DOCS
  ################################################################################################################*/

  OPEN  cur_upd_gen_docs ;
  FETCH cur_upd_gen_docs INTO lv_rowid, ln_generated_doc_id;


  IF cur_upd_gen_docs%FOUND THEN
    IF p_complete_flag = jai_constants.yes THEN
      /*
      || Complete flag is 'Y', Invoice is getting COMPLETED
      || Set the generated_doc_id to null in case it is not null
      */

      ln_generated_doc_id := p_customer_trx_id;
    ELSE
      /*
      || Complete flag is 'N', Invoice is getting INCOMPLETED
      */
      IF ln_generated_doc_id IS NOT NULL THEN
        /*
        || Set the generated_doc_id to null in case it is not null
        */
        ln_generated_doc_id := NULL;
      ELSE
        /*
        ||Do nothing if the generated_doc_id is null and invoice is getting incompleted
        */
       /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id =>  ln_reg_id ,
                                            pv_log_msg  =>  'Skip the TCS ITEM GENDOCS update as :- '            ||fnd_global.local_chr(10)
                                                          ||', p_complete_flag       -> '||p_complete_flag       ||fnd_global.local_chr(10)
                                                          ||', ln_generated_doc_id   -> '||ln_generated_doc_id
                                         );*/
        p_process_flag := jai_constants.not_applicable;
        return;
      END IF;
    END IF;

    /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                        pv_log_msg  =>  'valid transaction record found in table jai_rgm_item_gen_docs. Updating the table jai_rgm_item_gen_docs with ' ||fnd_global.local_chr(10)
                                                      ||', generated_doc_id -> '||ln_generated_doc_id
                                     );*/
    UPDATE jai_rgm_item_gen_docs
    SET
        generated_doc_id  = ln_generated_doc_id ,
        last_updated_by   = ln_user_id          ,
        last_update_date  = sysdate             ,
        last_update_login = ln_login_id
    WHERE
        rowid = lv_rowid;
  END IF;
  CLOSE cur_upd_gen_docs;

 /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                      pv_log_msg  =>  '**************** END OF UPDATE_ITEM_GEN_DOCS ****************'
                                   );

  jai_cmn_debug_contexts_pkg.deregister (pn_reg_id => ln_reg_id);*/

END update_item_gen_docs;


PROCEDURE generate_document (
                                p_rgm_ref            IN             JAI_RGM_REFS_ALL%ROWTYPE ,
                                p_total_tax_amt      IN             NUMBER                   ,
                                p_process_flag       OUT NOCOPY     VARCHAR2                 ,
                                p_process_message    OUT NOCOPY     VARCHAR2
                            )
IS
    ln_reg_id                 NUMBER             ;
    ln_msg_count              NUMBER             ;
    lv_msg_data               VARCHAR2(2000)     ;
    ln_customer_trx_id        NUMBER             ;
    lv_return_status          VARCHAR2(80)       ;

  /*
  ||Customer would create a batch source with name TCS Debit Memo And TCS Credit Memo
  */
  CURSOR cur_get_batch_source ( cp_org_id  JAI_RGM_REFS_ALL.ORG_ID%TYPE   ,
                                cp_name    RA_BATCH_SOURCES_ALL.NAME%TYPE
                               )
  IS
  SELECT
         bsa.batch_source_id          ,
         bsa.default_inv_trx_type     ,
         rctt.type                    ,
         rctt.name                    ,
         rctt.default_term            ,
         rctt.gl_id_rec               ,
         rctt.creation_sign
  FROM
         ra_batch_sources_all   bsa ,
         ra_cust_trx_types_all  rctt
  WHERE
         bsa.default_inv_trx_type = rctt.cust_trx_type_id
  AND    bsa.org_id               = rctt.org_id
  AND    bsa.org_id               = cp_org_id
  AND    bsa.name                 = cp_name  ;

  CURSOR cur_get_part_det ( cp_party_id         JAI_RGM_REFS_ALL.PARTY_ID%TYPE      ,
                            cp_party_site_id    JAI_RGM_REFS_ALL.PARTY_SITE_ID%TYPE
                          )
  IS
  SELECT
          hzcas.cust_acct_site_id   bill_to_address_id
  FROM
          hz_cust_accounts hca         ,
          hz_cust_acct_sites_all hzcas ,
          hz_cust_site_uses_all  hzcsu
  WHERE
          hca.cust_account_id       = hzcas.cust_account_id
  AND     hzcas.cust_acct_site_id   = hzcsu.cust_acct_site_id
  AND     hzcsu.site_use_code       = jai_constants.site_use_bill_to
  AND     hca.cust_account_id       = cp_party_id
  AND     hzcsu.site_use_id         = cp_party_site_id ;-- site_use_id is the party_site_id ;

  CURSOR cur_get_sob ( cp_org_id jai_rgm_refs_all.org_id%TYPE )
  IS
  SELECT
        set_of_books_id
  FROM
        hr_operating_units
  WHERE
        organization_id  = cp_org_id                                              ;

  /*--added for bug#8214204,start
  CURSOR cur_get_salesrep_req_flag (cp_org_id jai_rgm_refs_all.org_id%TYPE )
  IS
    SELECT  salesrep_required_flag
    from    ar_system_parameters_all
    where   org_id = cp_org_id;
  lv_salesrep_flag              VARCHAR2(1);
  --bug#8214204,end*/

  lv_batch_src_dm               JAI_RGM_REGISTRATIONS.ATTRIBUTE_VALUE%TYPE                ;
  lv_batch_src_cm               JAI_RGM_REGISTRATIONS.ATTRIBUTE_VALUE%TYPE                ;
  ln_regime_id                  JAI_RGM_DEFINITIONS.REGIME_ID%TYPE                        ;
  lv_batch_src_name             JAI_RGM_REGISTRATIONS.ATTRIBUTE_VALUE%TYPE                ;
  ln_term_id                    RA_CUST_TRX_TYPES_ALL.DEFAULT_TERM%TYPE           ;
  ln_bill_to_address_id         hz_cust_acct_sites_all.cust_acct_site_id%type     ;
  lv_trx_number                 RA_CUSTOMER_TRX_ALL.TRX_NUMBER%TYPE               ;
  ln_ccid_tax_type_tcs          NUMBER                                            ;
  rec_cur_get_batch_source      CUR_GET_BATCH_SOURCE%ROWTYPE                      ;
  lv_set_of_books_id            HR_OPERATING_UNITS.SET_OF_BOOKS_ID%TYPE           ;
  ln_amount                     NUMBER                                            ;
  ln_user_id                    JAI_RGM_REFS_ALL.CREATED_BY%TYPE                  ;
  ln_login_id                   JAI_RGM_REFS_ALL.LAST_UPDATE_LOGIN%TYPE           ;
  lv_process_message            VARCHAR2(4000)                                    ;

BEGIN

  /*################################################################################################################
  || Initialize the variables
  ################################################################################################################*/

  lv_member_name        := 'GENERATE_DOCUMENT';
  set_debug_context;
  /*commented by csahoo for bug# 6401388
  jai_cmn_debug_contexts_pkg.register ( pv_context => lv_context    ,
                                        pn_reg_id  => ln_reg_id
                                       );

   jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                      pv_log_msg  =>  'Parameter passed to GENERATE_DOCUMENT are -> '                 ||fnd_global.local_chr(10)
                                                    ||', transaction_id          -> '||p_rgm_ref.transaction_id       ||fnd_global.local_chr(10)
                                                    ||', p_total_tax_amt         -> '||p_total_tax_amt                ||fnd_global.local_chr(10)
                                                    ||', source_document_type is -> '||p_rgm_ref.source_document_type ||fnd_global.local_chr(10)
                                                    ||', org_id                  -> '||p_rgm_ref.org_id
                                  );*/
  lv_process_message:= null                       ;
  p_process_flag    := jai_constants.successful   ;
  p_process_message := lv_process_message         ;

  ln_user_id         := fnd_global.user_id         ;
  ln_login_id        := fnd_global.login_id        ;

  /*################################################################################################################
  ||Skip the transaction if p_total_tax_amt is 0
  ################################################################################################################*/
  IF nvl(p_total_tax_amt,0) = 0 THEN
    /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                        pv_log_msg  =>  'As transaction total_tax_amt is -> '||p_total_tax_amt||' hence skipping the transaction.'
                                      );*/
    p_process_flag := jai_constants.not_applicable ;
    return;
  END IF;

  /*################################################################################################################
  ||Get batch source information
  ################################################################################################################*/

  /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                      pv_log_msg  =>  ' Deriving the batch source information '
                                   );*/

   /*
   ||Get the value for the Batch Source Debit Memo
   */
   OPEN c_get_rgm_attribute (  cp_regime_code           =>   jai_constants.tcs_regime                    ,
                               cp_attribute_code        =>   jai_constants.batch_src_dm                  ,
                               cp_organization_id       =>   p_rgm_ref.organization_id
                            );
  FETCH c_get_rgm_attribute INTO ln_regime_id ,lv_batch_src_dm;
  CLOSE c_get_rgm_attribute ;


  /*
  ||Get the value for the Batch Source Credit Memo
  */
  OPEN c_get_rgm_attribute (  cp_regime_code           =>   jai_constants.tcs_regime                    ,
                              cp_attribute_code        =>   jai_constants.batch_src_cm                  ,
                              cp_organization_id       =>   p_rgm_ref.organization_id
                           );
  FETCH c_get_rgm_attribute INTO ln_regime_id ,lv_batch_src_cm;
  CLOSE c_get_rgm_attribute ;


  /*################################################################################################################
  || Derive the batch source name based on the document type
  ################################################################################################################*/

  /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                      pv_log_msg  =>  ' Deriving the batch source name based on the document type'
                                   );*/

  IF p_rgm_ref.source_document_type  in  ( jai_constants.ar_cash_tax_confirmed , /* Receipt confirmation */
                                           jai_constants.trx_type_rct_unapp    , /* Receipt unapplication*/
                                           jai_constants.trx_type_cm_app         /* CM application*/
                                          )
  THEN
    lv_batch_src_name           := lv_batch_src_dm; /* TCS Debit Memo */
    lv_trx_number               := jai_constants.tcs_dm_prefix;   --'TCS-DM'                     ;

  ELSIF p_rgm_ref.source_document_type in ( jai_constants.trx_type_rct_app ,
                                            jai_constants.trx_type_rct_rvs   ,
                                            jai_constants.trx_type_cm_unapp
                                           )

  THEN
    lv_batch_src_name := lv_batch_src_cm; /* TCS Credit Memo */
    lv_trx_number     := jai_constants.tcs_cm_prefix; --'TCS-CM';

  ELSIF p_rgm_ref.source_document_type = jai_constants.tcs_event_surcharge THEN
    /*
    ||Document generation is invoked by surcharge.  Document type will be derrived from the sign of the document amount.
    ||If sign is +VE then it should be a Debit Memo, otherwise it should be a Credit Memo
    */

    IF sign (p_total_tax_amt) = -1 THEN

      /* Credit Memo */
      lv_batch_src_name := lv_batch_src_cm;
      lv_trx_number     := jai_constants.tcs_cm_prefix; --'TCS-CM';
    ELSIF sign (p_total_tax_amt) = 1 THEN

      /* Debit Memo */
      lv_batch_src_name := lv_batch_src_dm;
      lv_trx_number     := jai_constants.tcs_dm_prefix; --'TCS-DM'
    END IF;
  ELSE
    /*
    ||Skip the transaction
    */
    /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                        pv_log_msg  =>  'Skip the transaction '
                                  );*/
    p_process_flag    := jai_constants.not_applicable;
    p_process_message := null;
    return ;
  END IF;

  /*################################################################################################################
  ||VALIDATE BATCH SOURCES FOR TCS
  ################################################################################################################*/

  /*
  || Error out if the batch source name is null i.e regime party setup for
  */
  IF lv_batch_src_name IS NULL THEN
    /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                        pv_log_msg  =>  'Batch source definition has not be defined for the inventory organization '||p_rgm_ref.organization_id
                                      );*/

    p_process_flag    := jai_constants.expected_error;
    lv_process_message := 'Batch source definition has not be defined for the inventory organization '||p_rgm_ref.organization_id;
    p_process_message := lv_process_message ;
    return;
  END IF;


  /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                      pv_log_msg  =>  'Document Type is lv_batch_src_name -> '||lv_batch_src_name
                                   );*/

  OPEN cur_get_batch_source  (  cp_org_id  => p_rgm_ref.org_id ,
                                cp_name    => lv_batch_src_name
                             );

  FETCH cur_get_batch_source INTO rec_cur_get_batch_source;
  IF cur_get_batch_source%NOTFOUND THEN
    /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                        pv_log_msg  =>  'TCS batch source has not been defined '
                                     );*/
    CLOSE cur_get_batch_source  ;
    p_process_flag    := jai_constants.expected_error;
    lv_process_message := 'TCS batch source has not been defined for '||lv_batch_src_name ||'. Cannot process transaction ';
    p_process_message := lv_process_message ;
    return;
  END IF;
  CLOSE cur_get_batch_source  ;

  /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                      pv_log_msg  =>  'batch source details are:- '                                                          ||fnd_global.local_chr(10)
                                      ||', lv_batch_src_name                             -> '||lv_batch_src_name                             ||fnd_global.local_chr(10)
                                      ||', rec_cur_get_batch_source.batch_source_id      -> '||rec_cur_get_batch_source.batch_source_id      ||fnd_global.local_chr(10)
                                      ||', rec_cur_get_batch_source.default_inv_trx_type -> '||rec_cur_get_batch_source.default_inv_trx_type ||fnd_global.local_chr(10)
                                      ||', rec_cur_get_batch_source.type                 -> '||rec_cur_get_batch_source.type                 ||fnd_global.local_chr(10)
                                      ||', rec_cur_get_batch_source.name                 -> '||rec_cur_get_batch_source.name                 ||fnd_global.local_chr(10)
                                      ||', rec_cur_get_batch_source.creation_sign        -> '||rec_cur_get_batch_source.creation_sign
                                   );*/
  /*################################################################################################################
  || DERIVE THE TERM FOR DM'S ONLY
  ################################################################################################################*/

  IF rec_cur_get_batch_source.type = jai_constants.ar_doc_type_dm THEN
    ln_term_id := rec_cur_get_batch_source.default_term;
    /*
    || Throw an error if the term has not been defined for the debit memo Transaction type .
    || This check is not required in case of credit memo
    */
    IF ln_term_id        IS NULL  THEN
      /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                          pv_log_msg  =>  'Error:- Default term is not defined in the transction type -> '||rec_cur_get_batch_source.name
                                       );*/
      p_process_flag    := jai_constants.expected_error;
      lv_process_message := 'Cannot process transaction. A default term needs to be defined FOR the Transaction TYPE '||rec_cur_get_batch_source.name ;
      p_process_message := lv_process_message ;
      return;
    END IF;
  END IF;

  /*################################################################################################################
  || DERIVE THE SOB
  ################################################################################################################*/

  OPEN  cur_get_sob ( cp_org_id => p_rgm_ref.org_id );
  FETCH cur_get_sob INTO lv_set_of_books_id;
  CLOSE cur_get_sob ;
  /*
  ||Throw an error if the Set of books has not been defined
  */
  IF lv_set_of_books_id IS NULL THEN
   /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                        pv_log_msg  =>  'Error:- Set of books not defined for org_id -> '||p_rgm_ref.org_id
                                     );*/

    p_process_flag     := jai_constants.expected_error;
    lv_process_message := 'Set of books not defined for the org id.';
    p_process_message  := lv_process_message ;
    return;
  END IF;


  /*################################################################################################################
  || DERIVE THE ADDRESS
  ################################################################################################################*/

  OPEN  cur_get_part_det ( cp_party_id      =>   p_rgm_ref.party_id              ,
                           cp_party_site_id =>   p_rgm_ref.party_site_id
                           );
  FETCH cur_get_part_det INTO ln_bill_to_address_id;
  CLOSE cur_get_part_det ;
  /*
  ||Throw an error if the bill to address has not been defined
  */

  IF ln_bill_to_address_id IS NULL THEN

   /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                        pv_log_msg  =>  'Error:- Bill to address not defined for the customer id -> '||p_rgm_ref.party_id
                                                     ||' customer site -> '||p_rgm_ref.party_site_id
                                     );*/

    p_process_flag     := jai_constants.expected_error;
    lv_process_message := 'Bill to address not defined for the customer id -> '||p_rgm_ref.party_id ||' customer site -> '||p_rgm_ref.party_site_id;
    p_process_message  := lv_process_message ;
    return;
  END IF;

  lv_trx_number := lv_trx_number||p_rgm_ref.transaction_id ;

  /*################################################################################################################
  || DERIVE THE SIGN OF THE APPLICATION AND SECONDARY DOCUMENT VALUE
  ################################################################################################################*/

  /*
  ||Amount is :-
  ||  1.+ve if the creation sign of the document is positive
  ||  1.-ve if the creation sign of the document is -ve
  || If the sign is any sign then for a DM create a +ve amount and CM would ve created with a -ve amount
  */
  IF rec_cur_get_batch_source.creation_sign = jai_constants.creation_sign_positive THEN
    ln_amount := abs(p_total_tax_amt) * 1;

  ELSIF rec_cur_get_batch_source.creation_sign = jai_constants.creation_sign_negative    THEN
      ln_amount := abs(p_total_tax_amt) * -1;

  ELSIF rec_cur_get_batch_source.creation_sign = jai_constants.creation_sign_any THEN

    IF rec_cur_get_batch_source.type = jai_constants.ar_doc_type_dm THEN
      ln_amount := abs(p_total_tax_amt) ;

    ELSIF rec_cur_get_batch_source.type = jai_constants.ar_invoice_type_cm THEN
      ln_amount := abs(p_total_tax_amt) * -1;
    END IF;
  END IF;


  /*################################################################################################################
  || INSERT INTO RA_INTERFACE_LINES_ALL TABLE
  ################################################################################################################*/

 /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                      pv_log_msg  =>  'Before inserting into the interface tables, Values are :- '                     || fnd_global.local_chr(10)
                                                    ||', interface_line_id             -> '||  p_rgm_ref.transaction_id                || fnd_global.local_chr(10)
                                                    ||', i/p tax amount                -> '||  p_total_tax_amt                         || fnd_global.local_chr(10)
                                                    ||', document creation amount      -> '||  ln_amount                               || fnd_global.local_chr(10)
                                                    ||', description                   -> '||  lv_batch_src_name                       || fnd_global.local_chr(10)
                                                    ||', orig_system_bill_customer_id  -> '||  p_rgm_ref.party_id                      || fnd_global.local_chr(10)
                                                    ||', orig_system_bill_address_id   -> '||  ln_bill_to_address_id                   || fnd_global.local_chr(10)
                                                    ||', set_of_books_id               -> '||  lv_set_of_books_id                      || fnd_global.local_chr(10)
                                                    ||', trx_date                      -> '||  p_rgm_ref.source_document_date          || fnd_global.local_chr(10)
                                                    ||', trx_number                    -> '||  lv_trx_number                           || fnd_global.local_chr(10)
                                                    ||', batch_source_name             -> '||  lv_batch_src_name                       || fnd_global.local_chr(10)
                                                    ||', cust_trx_type_name            -> '||  rec_cur_get_batch_source.name           || fnd_global.local_chr(10)
                                                    ||', line_type                     -> '||  jai_constants.line_type_line            || fnd_global.local_chr(10)
                                                    ||', conversion_rate               -> '||  1                                       || fnd_global.local_chr(10)
                                                    ||', conversion_type               -> '||  jai_constants.conversion_type_user      || fnd_global.local_chr(10)
                                                    ||', interface_line_context        -> '||  lv_batch_src_name                       || fnd_global.local_chr(10)
                                                    ||', interface_line_attribute2     -> '||  p_rgm_ref.transaction_id                || fnd_global.local_chr(10)
                                                    ||', currency_code                 -> '||  jai_constants.func_curr                 || fnd_global.local_chr(10)
                                                    ||', primary_salesrep_id           -> '||  -3                                      || fnd_global.local_chr(10)
                                                    ||', tax_code                      -> '||  jai_constants.tax_code_localization     || fnd_global.local_chr(10)
                                                    ||', term_id                       -> '||  ln_term_id                              || fnd_global.local_chr(10)
                                                    ||', warehouse_id                  -> '||  p_rgm_ref.organization_id               || fnd_global.local_chr(10)
                                                    ||', quantity                      -> '||  1                                       || fnd_global.local_chr(10)
                                                    ||', unit_selling_price            -> '||  ln_amount                               || fnd_global.local_chr(10)
                                                    ||', created_by                    -> '||  ln_user_id                              || fnd_global.local_chr(10)
                                                    ||', creation_date                 -> '||  sysdate                                 || fnd_global.local_chr(10)
                                                    ||', last_updated_by               -> '||  ln_user_id                              || fnd_global.local_chr(10)
                                                    ||', last_update_date              -> '||  sysdate                                 || fnd_global.local_chr(10)
                                                    ||', last_update_login             -> '||  ln_login_id                             || fnd_global.local_chr(10)
                           );*/
  INSERT INTO ra_interface_lines_all
                  (
                      interface_line_id                         ,
                      amount                                    ,
                      description                               ,
                      orig_system_bill_customer_id              ,
                      orig_system_bill_address_id               ,
                      set_of_books_id                           ,
                      trx_date                                  ,
                      trx_number                                ,
                      batch_source_name                         ,
                      cust_trx_type_name                        ,
                      line_type                                 ,
                      conversion_rate                           ,
                      conversion_type                           ,
                      interface_line_context                    ,
                      interface_line_attribute2                 ,
                      currency_code                             ,
                      primary_salesrep_id                       ,
                      tax_code                                  ,
                      term_id                                   ,
                      warehouse_id                              ,
                      org_id                              ,        -- Date 19-jun-2007 by sacsethi for bug 6137956
                      quantity                                  ,
                      unit_selling_price                        ,
                      created_by                                ,
                      creation_date                             ,
                      last_updated_by                           ,
                      last_update_date                          ,
                      last_update_login
                  )
          VALUES  (
                      p_rgm_ref.transaction_id                  ,
                      ln_amount                                 ,
                      lv_batch_src_name                         ,
                      p_rgm_ref.party_id                        ,
                      ln_bill_to_address_id                     ,
                      lv_set_of_books_id                        ,
                      p_rgm_ref.source_document_date            ,
                      lv_trx_number                             ,
                      lv_batch_src_name                         ,
                      rec_cur_get_batch_source.name             ,
                      jai_constants.line_type_line              ,
                      1                                         ,
                      jai_constants.conversion_type_user        ,
                      lv_batch_src_name                         ,
                      p_rgm_ref.transaction_id                  ,
                      jai_constants.func_curr                   ,
                      -3                                        ,
                      --jai_constants.tax_code_localization       ,
                      --commented the above and added the following for bug#8517919
                      NULL                                      ,
                      ln_term_id                                ,
                      p_rgm_ref.organization_id                 ,
                      p_rgm_ref.org_id                          , -- Date 19-jun-2007 by sacsethi for bug 6137956
                      1                                         ,
                      ln_amount                                 ,
                      ln_user_id                                ,
                      sysdate                                   ,
                      ln_user_id                                ,
                      sysdate                                   ,
                      ln_login_id
                   );

  /*--added for bug#8214204 , start
  OPEN cur_get_salesrep_req_flag (p_rgm_ref.org_id);
  FETCH cur_get_salesrep_req_flag INTO lv_salesrep_flag;
  CLOSE cur_get_salesrep_req_flag;

  IF lv_salesrep_flag = 'Y' THEN
    INSERT INTO RA_INTERFACE_SALESCREDITS_ALL
                     ( interface_salescredit_id,
                       interface_line_id,
                       sales_credit_percent_split,
                       salesrep_id,
                       sales_credit_type_id,
                       org_id,
                       created_by,
                       creation_date,
                       last_updated_by,
                       last_update_date)
               values( RA_CUST_TRX_LINE_SALESREPS_S.nextval,
                       p_rgm_ref.transaction_id,
                       100,
                       -3,
                       1,
                       p_rgm_ref.org_id,
                       ln_user_id,
                       sysdate,
                       ln_user_id,
                       sysdate);
  END IF;
  --bug#8214204,end*/

  /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                      pv_log_msg  =>  'After Insert statement of the interface tables '
                                   );*/


  /*********************************************************************************************************
  || Get the code combination id from the Organization/Regime Registration setup
  || by calling the function jai_cmn_rgm_recording_pkg.get_account
  *********************************************************************************************************/

  ln_ccid_tax_type_tcs := jai_cmn_rgm_recording_pkg.get_account (
                                                                  p_regime_id          => p_rgm_ref.regime_id        ,
                                                                  p_organization_type  => jai_constants.orgn_type_io ,
                                                                  p_organization_id    => p_rgm_ref.organization_id  ,
                                                                  p_location_id        => null                       ,
                                                                  p_tax_type           => jai_constants.tax_type_tcs ,
                                                                  p_account_name       => jai_constants.liability
                                                                );
  IF ln_ccid_tax_type_tcs IS NULL THEN
    /**********************************************************************************************************
    || Code Combination id has been returned as null from the function jai_cmn_rgm_recording_pkg.get_account
    || This is an error condition and the current processing has to be stopped
    **********************************************************************************************************/
   /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print ( pn_reg_id =>  ln_reg_id ,
                              pv_log_msg  =>  'Invalid code combination of TCS tax Accounting'
                            );*/
    p_process_flag := jai_constants.expected_error;
    lv_process_message  := 'Invalid Code combination ,please check the TCS Tax - Tax Accounting Setup';
    p_process_message := lv_process_message ;
    rollback;
    return;
  END IF;

    /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                        pv_log_msg  =>  'Inserting values into ra_interface_distributions_all for REV row:- '||fnd_global.local_chr(10)
                                                      ||', interface_line_id          -> '|| p_rgm_ref.transaction_id        ||fnd_global.local_chr(10)
                                                      ||', interface_line_context     -> '|| lv_batch_src_name               ||fnd_global.local_chr(10)
                                                      ||', interface_line_attribute2  -> '|| p_rgm_ref.transaction_id        ||fnd_global.local_chr(10)
                                                      ||', account_class              -> '|| jai_constants.account_class_rev ||fnd_global.local_chr(10)
                                                      ||', amount                     -> '|| ln_amount                       ||fnd_global.local_chr(10)
                                                      ||', code_combination_id        -> '|| ln_ccid_tax_type_tcs            ||fnd_global.local_chr(10)
                                                      ||', acctd_amount               -> '|| ln_amount                       ||fnd_global.local_chr(10)
                                                      ||', created_by                 -> '|| ln_user_id                      ||fnd_global.local_chr(10)
                                                      ||', creation_date              -> '|| sysdate                         ||fnd_global.local_chr(10)
                                                      ||', last_updated_by            -> '|| ln_user_id                      ||fnd_global.local_chr(10)
                                                      ||', last_update_date           -> '|| sysdate                         ||fnd_global.local_chr(10)
                                                      ||', last_update_login          -> '|| ln_login_id                     ||fnd_global.local_chr(10)
                                                      ||', org_id                     -> '|| p_rgm_ref.org_id
                                     );*/

    INSERT INTO ra_interface_distributions_all
                                           (
                                              interface_line_id                   ,
                                              interface_line_context              ,
                                              interface_line_attribute2           ,
                                              account_class                       ,
                                              amount                              ,
                                              code_combination_id                 ,
                                              acctd_amount                        ,
                                              created_by                          ,
                                              creation_date                       ,
                                              last_updated_by                     ,
                                              last_update_date                    ,
                                              last_update_login                   ,
                                              org_id
                                           )
                                   Values  (
                                              p_rgm_ref.transaction_id            ,
                                              lv_batch_src_name                   ,
                                              p_rgm_ref.transaction_id            ,
                                              jai_constants.account_class_rev     ,
                                              ln_amount                           ,
                                              ln_ccid_tax_type_tcs                ,
                                              ln_amount                           ,
                                              ln_user_id                          ,
                                              sysdate                             ,
                                              ln_user_id                          ,
                                              sysdate                             ,
                                              ln_login_id                         ,
                                              p_rgm_ref.org_id
                                          );



    /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                        pv_log_msg  =>  'Inserting values into jai_rgm_item_gen_docs :- '                           ||fnd_global.local_chr(10)
                                                      ||', transaction_id             -> '||p_rgm_ref.transaction_id                ||fnd_global.local_chr(10)
                                                      ||', source_document_id         -> '||p_rgm_ref.source_document_id            ||fnd_global.local_chr(10)
                                                      ||', source_document_type       -> '||p_rgm_ref.source_document_type          ||fnd_global.local_chr(10)
                                                      ||', item_classification        -> '||p_rgm_ref.item_classification           ||fnd_global.local_chr(10)
                                                      ||', generated_doc_trx_number   -> '||lv_trx_number                           ||fnd_global.local_chr(10)
                                                      ||', generated_doc_id           -> '||ln_customer_trx_id                      ||fnd_global.local_chr(10)
                                                      ||', generated_doc_type         -> '||rec_cur_get_batch_source.type           ||fnd_global.local_chr(10)
                                                      ||', generated_doc_amt          -> '||ln_amount
                                     );*/

  /*################################################################################################################
  || INSERT INTO JAI_RGM_ITEM_GEN_DOCS TABLE
  ################################################################################################################*/

    INSERT INTO jai_rgm_item_gen_docs   ( transaction_id                    ,
                                          source_document_id                ,
                                          source_document_type              ,
                                          item_classification               ,
                                          generated_doc_trx_number          ,
                                          generated_doc_id                  ,
                                          generated_doc_type                ,
                                          generated_doc_amt                 ,
                                          created_by                        ,
                                          creation_date                     ,
                                          last_updated_by                   ,
                                          last_update_date                  ,
                                          last_update_login
                                        )
                               VALUES   ( p_rgm_ref.transaction_id          ,
                                          p_rgm_ref.source_document_id      ,
                                          p_rgm_ref.source_document_type    ,
                                          p_rgm_ref.item_classification     ,
                                          lv_trx_number                     ,
                                          ln_customer_trx_id                ,
                                          rec_cur_get_batch_source.type     ,
                                          ln_amount                         ,
                                          ln_user_id                        ,
                                          sysdate                           ,
                                          ln_user_id                        ,
                                          sysdate                           ,
                                          ln_login_id
                                        );

     /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                          pv_log_msg  =>  'Data successfully inserted into jai_rgm_item_gen_docs'
                                       );


  jai_cmn_debug_contexts_pkg.deregister (pn_reg_id => ln_reg_id);*/
EXCEPTION
WHEN OTHERS THEN
    p_process_flag    := jai_constants.unexpected_error;
    p_process_message := ' Unexpected error occured while processing jai_ar_tcs_rep_pkg.generate_document'||substr(SQLERRM,1,300) ;
   /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                        pv_log_msg  =>  'Unexpected error occured while processing jai_ar_tcs_rep_pkg.generate_document -> '||substr(SQLERRM,1,300)
                                     );*/

END generate_document;

PROCEDURE process_transactions (
                                    p_event            IN           VARCHAR2                                                               ,
                                    p_document_type    IN           VARCHAR2                                Default Null                   ,
                                    p_ooh              IN           OE_ORDER_HEADERS_ALL%ROWTYPE            Default Null                   ,
                                    p_ract             IN           RA_CUSTOMER_TRX_ALL%ROWTYPE             Default Null                   ,
                                    p_acra             IN           AR_CASH_RECEIPTS_ALL%ROWTYPE            Default Null                   ,
                                    p_araa             IN           AR_RECEIVABLE_APPLICATIONS_ALL%ROWTYPE  Default Null                   ,
                                    p_process_flag     OUT NOCOPY   VARCHAR2                                                               ,
                                    p_process_message  OUT NOCOPY   VARCHAR2
                               )
IS

  ln_reg_id           NUMBER;
  /* **************************************************************************
   Creation Date          : 09-Sep-2006
   Created By             : Aiyer
   Bug Number             : 4742259
   Purpose                : Validate and insert the TCS repository with appropriate transaction based entries
   Called From            :
   Parameter Description  :
                            p_document_id    - Unique identifier of the document:-
                                                1. customer_trx_id                - Invoice/Credit Memo identifier
                                                2. cash_receipt_id                - cash receipt Identifier
                                                3. ar_receivable_applications_id  - Unique identifier for a Cash receipt /Credit Memo application to an Invoice/DM

                            p_document_type  - Indicates the type of document eg
                                                1. INVOICE_COMPLETION             - Invoice Completion
                                                2. CASH_TAX_CONFIRMED             - Cash Receipt tax Confirmation
                                                3. CREDIT_MEMO_APPLICATION        - CM application to Invoice
                                                4. CREDIT_MEMO_UNAPPLICATION      - CM Invoice Unapplication
                                                5. RECEIPT_APPLICATION            - Cash receipt application to Invoice
                                                6. RECEIPT_UNAPPLICATION          - Cash receipt unapplication to Invoice
                                                7. RECEIPT_REVERSAL               - Cash receipt reversal

                           p_process_flag
                           p_process_message
CHANGE HISTORY:
S.No      Date      Author and Details
========================================
1.      01-AUG-2008 JMEENA for bug#7277211
        Created new  procedure process_sales_order and added code to call process_sales_order when p_event is  BOOKED

  ***************************************************************************/


  CURSOR cur_get_refs (cp_transaction_id JAI_RGM_REFS_ALL.TRANSACTION_ID%TYPE )
  IS
  SELECT
        *
  FROM
         jai_rgm_refs_all ref
  WHERE
    transaction_id = cp_transaction_id;


  CURSOR cur_get_total_tax (cp_transaction_id JAI_RGM_REFS_ALL.TRANSACTION_ID%TYPE )
  IS
  SELECT
        sum(nvl(jrt.func_tax_amt,0)) total_tax_amount
  FROM
       jai_rgm_refs_all jrra,
       jai_rgm_taxes jrt
  WHERE
           jrra.trx_ref_id = jrt.trx_ref_id
AND         jrra.transaction_id = cp_transaction_id;

  rec_cur_get_refs          CUR_GET_REFS%ROWTYPE                       ;
  ln_tax_tot_amt            NUMBER                                     ;
  lv_document_type          VARCHAR2(100)                              ;
  lv_item_classification    JAI_RGM_REFS_ALL.ITEM_CLASSIFICATION%TYPE  ;
  lv_process_flag           VARCHAR2(2)                                ;
  lv_process_message        VARCHAR2(2000)                             ;

  /* Added by JMEENA for TCS issue bug#7277211*/
PROCEDURE process_sales_order (p_ooh              IN             OE_ORDER_HEADERS_ALL%ROWTYPE ,
                               p_process_flag     OUT NOCOPY     VARCHAR2                     ,
                               p_process_message  OUT NOCOPY     VARCHAR2
              )
IS
/* **************************************************************************
   Creation Date          : 01-Aug-2008
   Created By             : JMEENA
   Bug Number             : 7277211
   Purpose                :  Insert the record in jai_rgm_thresholds while booking the sales order
   Called From            :  PROCESS_TRANSACTION when p_event is BOOKED (sales order booked)
  CHANGE HISTORY:
 S.No      Date      Author and Details

**************************************************************************/

    cursor c_get_customer_pan (cp_customer_id    JAI_CMN_CUS_ADDRESSES.customer_id%type)
    IS
    select   pan_no
    from     JAI_CMN_CUS_ADDRESSES
    where    customer_id = cp_customer_id
    and      confirm_pan = jai_constants.yes;

  cursor c_get_cust_typ_lkup_code(cp_customer_id    JAI_CMN_CUS_ADDRESSES.customer_id%type)
    IS
    select tcs_customer_type
    from   JAI_CMN_CUS_ADDRESSES
    where  customer_id  = cp_customer_id
    AND tcs_customer_type IS NOT NULL;

    cursor c_get_threshold_slab   ( cp_regime_id                   jai_rgm_thresholds.regime_id%type,
                cp_customer_type_lkup_code    JAI_CMN_CUS_ADDRESSES.tcs_customer_type%type,
                cp_source_trx_date        DATE
                               )
    IS
    select
            thslbs.threshold_slab_id
    from
            jai_ap_tds_thhold_slabs thslbs
           ,jai_ap_tds_thhold_types thtyps
           ,jai_ap_tds_thhold_hdrs  thhdrs
     where
            thslbs.threshold_type_id  = thtyps.threshold_type_id
     and    thtyps.threshold_hdr_id   = thhdrs.threshold_hdr_id
     and    thhdrs.regime_id          = cp_regime_id
     and    thtyps.threshold_type     = jai_constants.thhold_typ_cumulative
     and    thhdrs.customer_type_lookup_code = cp_customer_type_lkup_code
     and    trunc(cp_source_trx_date)      between thtyps.from_date
                                      and     nvl(thtyps.to_date, trunc(cp_source_trx_date))
     and    NVL(thslbs.from_amount,0) = 0;


  cursor get_jai_rgm_thresholds_count (   cp_fin_year   jai_rgm_thresholds.fin_year%type,
                      cp_org_tan_no jai_rgm_thresholds.org_tan_no%type,
                                          cp_party_type jai_rgm_thresholds.party_type%type,
                                          cp_party_id   jai_rgm_thresholds.party_id%type,
                      cp_regime_id  jai_rgm_thresholds.regime_id%type
                    )
  IS
  select count(*)
  from jai_rgm_thresholds
   where  fin_year     =   cp_fin_year
    and    org_tan_no   =   cp_org_tan_no
    and    party_type   =   cp_party_type
    and    party_id     =   cp_party_id
    and    regime_id    =   cp_regime_id;

  lx_row_id                   rowid;
  ln_regime_id            jai_rgm_thresholds.regime_id%type;
    ln_org_tan_no           jai_rgm_thresholds.org_tan_no%type;
    ln_party_id             jai_rgm_thresholds.party_id%type;
  ln_party_type       jai_rgm_thresholds.party_type%type;
    ln_fin_year             jai_rgm_thresholds.fin_year%type;
  ln_party_pan_no       JAI_CMN_CUS_ADDRESSES.pan_no%type;
  ln_customer_type_lkup_code  JAI_CMN_CUS_ADDRESSES.tcs_customer_type%type;
  ln_threshold_slab_id    jai_ap_tds_thhold_slabs.threshold_slab_id%type default NULL;
  lr_hdr_record                   jai_rgm_thresholds%rowtype;
  ln_user_id          fnd_user.user_id%type       :=    fnd_global.user_id;
    ln_login_id         fnd_logins.login_id%type    :=    fnd_global.login_id;
  ln_count      NUMBER;
  ln_threshold_id   jai_rgm_thresholds.threshold_id%type default NULL;
 BEGIN

    OPEN  get_tcs_fin_year(  cp_org_id    => p_ooh.org_id  ,
                            cp_trx_date  => p_ooh.creation_date
                         );

    FETCH get_tcs_fin_year INTO ln_fin_year;
    CLOSE get_tcs_fin_year;

    OPEN c_get_rgm_attribute (    cp_regime_code           =>   jai_constants.tcs_regime                  ,
                                  cp_attribute_code        =>   jai_constants.rgm_attr_code_org_tan       ,
                                  cp_organization_id       =>   p_ooh.ship_from_org_id
                               ) ;
    FETCH c_get_rgm_attribute INTO ln_regime_id, ln_org_tan_no ;
    IF C_GET_RGM_ATTRIBUTE%NOTFOUND THEN
    CLOSE c_get_rgm_attribute;
      p_process_flag     := jai_constants.expected_error;
        p_process_message  := 'Org Tan Number needs to be defined for the TCS regime ';
        return;
    END IF;
    CLOSE c_get_rgm_attribute;

  OPEN c_get_customer_pan (cp_customer_id => p_ooh.sold_to_org_id );
  FETCH c_get_customer_pan INTO ln_party_pan_no;

  IF c_get_customer_pan%NOTFOUND THEN
    CLOSE c_get_customer_pan;
      p_process_flag := jai_constants.expected_error;
      p_process_message  := 'Party pan no is not available for this party';
      RETURN;
  END IF;
  CLOSE c_get_customer_pan;



  OPEN c_get_cust_typ_lkup_code (cp_customer_id => p_ooh.sold_to_org_id );
  FETCH c_get_cust_typ_lkup_code INTO ln_customer_type_lkup_code;

  IF c_get_cust_typ_lkup_code%NOTFOUND THEN
    CLOSE c_get_cust_typ_lkup_code;
      p_process_flag := jai_constants.expected_error;
      p_process_message  := 'Customer type lookup code is not available for this party';
      RETURN;
  END IF;
  CLOSE c_get_cust_typ_lkup_code;

  OPEN c_get_threshold_slab (cp_regime_id                => ln_regime_id,
                           cp_customer_type_lkup_code  => ln_customer_type_lkup_code,
                           cp_source_trx_date     => p_ooh.creation_date

                );
  FETCH c_get_threshold_slab INTO ln_threshold_slab_id;
  CLOSE c_get_threshold_slab;

  ln_count :=0;

  OPEN get_jai_rgm_thresholds_count ( cp_fin_year => ln_fin_year,
                                      cp_org_tan_no => ln_org_tan_no,
                                      cp_party_type => jai_constants.party_type_customer,
                                      cp_party_id   => p_ooh.sold_to_org_id ,
                                      cp_regime_id  => ln_regime_id
                                  );
  FETCH get_jai_rgm_thresholds_count INTO ln_count;
  CLOSE get_jai_rgm_thresholds_count;

      lr_hdr_record.threshold_id              :=  ln_threshold_id   ;
        lr_hdr_record.regime_id                 :=  ln_regime_id;
        lr_hdr_record.org_tan_no                :=  ln_org_tan_no ;
        lr_hdr_record.party_id                  :=  p_ooh.sold_to_org_id;
        lr_hdr_record.party_type                :=  jai_constants.party_type_customer ;
        lr_hdr_record.threshold_slab_id         :=  ln_threshold_slab_id    ;
        lr_hdr_record.fin_year                  :=  ln_fin_year         ;
        lr_hdr_record.total_threshold_amt       :=  null                    ;
        lr_hdr_record.total_threshold_base_amt  :=  null                    ;
        lr_hdr_record.creation_date             :=  sysdate                 ;
        lr_hdr_record.created_by                :=  ln_user_id              ;
        lr_hdr_record.last_update_date          :=  sysdate                 ;
        lr_hdr_record.last_updated_by           :=  ln_user_id              ;
        lr_hdr_record.last_update_login         :=  ln_login_id             ;
    lr_hdr_record.party_pan_no        :=ln_party_pan_no;
    --Insert in jai_rgm_thresholds only if records does not exists.
    IF NVL(ln_count,0) = 0 THEN

        jai_rgm_thhold_proc_pkg.insert_threshold_hdr   (  p_record          =>    lr_hdr_record
                                , p_threshold_id    =>    ln_threshold_id
                                , p_row_id          =>    lx_row_id
                               );
  END IF;

END process_sales_order;
---End of process_sales_order bug#7277211

BEGIN

  /*########################################################################################################
  || VARIABLES INITIALIZATION
  ########################################################################################################*/

  /** Register procedure for debuging */

  lv_member_name        := 'PROCESS_TRANSACTIONS';
  set_debug_context;
  /*commented by csahoo for bug# 6401388
   jai_cmn_debug_contexts_pkg.register ( pv_context => lv_context ,
                                     pn_reg_id  => ln_reg_id
                                   );*/
  lv_process_flag    := jai_constants.successful   ;
  lv_process_message := null                       ;

  p_process_flag     := lv_process_flag            ;
  p_process_message  := lv_process_message         ;
  ln_event           := p_event                    ;


  /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                             pv_log_msg  =>  '******************Start of JAI_AR_TC_SREP_PKG.PROCESS_TRANSACTIONS***************, Event is '||p_event
                          );*/


  /*########################################################################################################
  || PROCESS COMPLETED INVOICES ( DEBIT MEMO'S ALSO INCLUDED)
  ########################################################################################################*/
  IF p_event  = jai_constants.order_booked  OR
     p_event  = jai_constants.wsh_ship_confirm
  THEN                   ---------A1
   /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                        pv_log_msg  =>  '******************Before call to VALIDATE_SALES_ORDER/SHIP CONFIRM  ***************, lv_document_type '||lv_document_type
                                     );*/
    validate_sales_order  ( p_ooh              =>  p_ooh               ,
                            p_process_flag     =>  lv_process_flag     ,
                            p_process_message  =>  lv_process_message
                          );

    /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                        pv_log_msg  =>  '******************Returned from call to VALIDATE_SALES_ORDER/SHIP CONFIRM ***************, lv_process_flag '||lv_process_flag
                                     );*/

    IF lv_process_flag = jai_constants.not_applicable THEN
      /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                          pv_log_msg  =>  'Skip the transaction'
                                       );*/
      return;
    END IF;

    IF lv_process_flag = jai_constants.expected_error    OR                            ---------A2
       lv_process_flag = jai_constants.unexpected_error
    THEN
      /*
      || As Returned status is an error/not applicable hence:-
      || Set out variables p_process_flag and p_process_message accordingly
      */
        --call to debug package
     /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                 pv_log_msg  =>  ' Error : - lv_process_flag -> '||lv_process_flag||' - '||lv_process_message
                              );*/

      p_process_flag    := lv_process_flag    ;
      p_process_message := lv_process_message ;
      return;
    END IF;                                                                            --------A1

--Added by JMEENA for bug#7277211
IF p_event  = jai_constants.order_booked THEN
    process_sales_order ( p_ooh              =>  p_ooh               ,
                            p_process_flag     =>  lv_process_flag     ,
                            p_process_message  =>  lv_process_message
                          );

 IF lv_process_flag = jai_constants.expected_error    OR                            ---------A2
       lv_process_flag = jai_constants.unexpected_error
    THEN
      p_process_flag    := lv_process_flag    ;
      p_process_message := lv_process_message ;
      return;
    END IF;
END IF;
--End for bug#7277211

  END IF;

  /*########################################################################################################
  || PROCESS COMPLETED INVOICES ( DEBIT MEMO'S ALSO INCLUDED)
  ########################################################################################################*/
  IF p_event = jai_constants.trx_event_completion  THEN                   ---------B1

  /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                             pv_log_msg  =>  '******************Before call to VALIDATE_INVOICE ***************, lv_document_type '||lv_document_type
                          );*/
    validate_invoice      ( p_ract             =>  p_ract              ,
                            p_document_type    =>  lv_document_type     ,
                            p_process_flag     =>  lv_process_flag     ,
                            p_process_message  =>  lv_process_message
                          );

  /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                             pv_log_msg  =>  '******************Returned from call to VALIDATE_INVOICE ***************, lv_process_flag '||lv_process_flag
                          );*/
    IF lv_process_flag = jai_constants.not_applicable THEN
     /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                 pv_log_msg  =>  'Skip the transaction'
                              );*/
      return;
    END IF;

    IF lv_process_flag = jai_constants.expected_error    OR                            ---------B2
       lv_process_flag = jai_constants.unexpected_error
    THEN
      /*
      || As Returned status is an error/not applicable hence:-
      || Set out variables p_process_flag and p_process_message accordingly
      */
        --call to debug package
      /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                 pv_log_msg  =>  ' Error : - lv_process_flag -> '||lv_process_flag||' - '||lv_process_message
                              );*/

      p_process_flag    := lv_process_flag    ;
      p_process_message := lv_process_message ;
      return;
    END IF;                                                                            ---------B2

    process_invoices      ( p_ract             =>  p_ract              ,
                            p_document_type    =>  lv_document_type    ,
                            p_process_flag     =>  lv_process_flag     ,
                            p_process_message  =>  lv_process_message
                          );

    IF lv_process_flag = jai_constants.not_applicable THEN
     /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                 pv_log_msg  =>  'Skip the transaction'
                              );*/

      return;
    END IF;


    IF lv_process_flag = jai_constants.expected_error    OR                            ---------B3
       lv_process_flag = jai_constants.unexpected_error
    THEN
      /*
      || As Returned status is an error/not applicable hence:-
      || Set out variables p_process_flag and p_process_message accordingly
      */
      --call to debug package
     /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                 pv_log_msg  =>  ' Error : - lv_process_flag -> '||lv_process_flag||' - '||lv_process_message
                              );*/

      p_process_flag    := lv_process_flag    ;
      p_process_message := lv_process_message ;
      return;
    END IF;                                                                            ---------B3
  END IF;                                                                      ---------B1

  /*########################################################################################################
  || PROCESS CONFIRMED RECEIPTS HAVING TCS APPLICABILITY
  ########################################################################################################*/

  IF p_event  IN ( jai_constants.ar_cash_tax_confirmed ,              ---------C1
                   jai_constants.trx_type_rct_rvs
                 )
  THEN
    lv_document_type := p_event;

    /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                               pv_log_msg  =>  ' Before call to validate_receipts : - p_event -> '||p_event
                            );*/
    validate_receipts ( p_acra             =>  p_acra             ,
                        p_document_type    =>  lv_document_type   ,
                        p_process_flag     =>  lv_process_flag    ,
                        p_process_message  =>  lv_process_message
                      );

   /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                               pv_log_msg  =>  ' Returned from validate_receipts lv_process_flag: '||lv_process_flag
                            );*/
    IF lv_process_flag = jai_constants.not_applicable THEN
      /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                 pv_log_msg  =>  'Skip the transaction'
                              );*/

      return;
    END IF;

    IF lv_process_flag = jai_constants.expected_error    OR                            ---------C2
       lv_process_flag = jai_constants.unexpected_error
    THEN
      /*
      || As Returned status is an error/not applicable hence:-
      || Set out variables p_process_flag and p_process_message accordingly
      */
      --call to debug package
      /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                 pv_log_msg  =>  ' Error : - lv_process_flag -> '||lv_process_flag||' - '||lv_process_message
                              );*/

      p_process_flag    := lv_process_flag    ;
      p_process_message := lv_process_message ;
      return;
    END IF;                                                                            ---------C2
    /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                               pv_log_msg  =>  ' Before call to process_receipts : - p_event -> '||p_event
                            );*/

    process_receipts   (  p_acra              =>  p_acra             ,
                          p_document_type     =>  p_event            ,
                          p_process_flag      =>  lv_process_flag    ,
                          p_process_message   =>  lv_process_message
                       );
    /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                               pv_log_msg  =>  ' Returned from process_receipts lv_process_flag: '||lv_process_flag
                            );*/

    IF  lv_process_flag = jai_constants.not_applicable THEN
     /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                 pv_log_msg  =>  'Skip the transaction'
                              );*/

      return;
    END IF;

    IF lv_process_flag = jai_constants.expected_error    OR                            ---------C3
       lv_process_flag = jai_constants.unexpected_error
    THEN
      /*
      || As Returned status is an error/not applicable hence:-
      || Set out variables p_process_flag and p_process_message accordingly
      */
      --call to debug package
     /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                 pv_log_msg  =>  ' Error : - lv_process_flag -> '||lv_process_flag||' - '||lv_process_message
                              );*/

      p_process_flag    := lv_process_flag    ;
      p_process_message := lv_process_message ;
      return;
    END IF;                                                                            ---------C3
  END IF;                                                                     ---------C1

  /*########################################################################################################
  || PROCESS ALL RECEIPT AND CREDIT MEMO APPLICATIONS/UNAPPLICATIONS
  ########################################################################################################*/

  IF p_event IN ( jai_constants.ar_cash   ,                                                        ---------D1
                  jai_constants.ar_invoice_type_cm
                )
  THEN

    /***********
    ||Validate application and unapplications
    ***********/
    /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                               pv_log_msg  =>  ' Before call to validate_app_unapp : - p_event -> '||p_event
                            );*/

    validate_app_unapp (
                            p_araa                =>  p_araa                    ,
                            p_document_type       =>  lv_document_type          ,
                            p_item_classification =>  lv_item_classification    ,
                            p_process_flag        =>  lv_process_flag           ,
                            p_process_message     =>  lv_process_message
                       );

    /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                               pv_log_msg  =>  ' Returned from validate_app_unapp lv_process_flag: '||lv_process_flag
                            );*/

    IF  lv_process_flag = jai_constants.not_applicable THEN
     /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                 pv_log_msg  =>  'Skip the transaction'
                              );*/
      return;
    END IF;


    IF lv_process_flag = jai_constants.expected_error    OR                                 ---------D2
       lv_process_flag = jai_constants.unexpected_error
    THEN
      /*
      || As Returned status is an error/not applicable hence:-
      || Set out variables p_process_flag and p_process_message accordingly
      */
      --call to debug package
      /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                 pv_log_msg  =>  ' Error : - lv_process_flag -> '||lv_process_flag||' - '||lv_process_message
                              );*/

      p_process_flag    := lv_process_flag    ;
      p_process_message := lv_process_message ;
      return;
    END IF;                                                                                 ---------D2


    IF lv_document_type IN ( jai_constants.trx_type_rct_app,                                ---------D3
                             jai_constants.trx_type_cm_app
                           )
    THEN
   /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                               pv_log_msg  =>  ' Before call to process_applications : - p_event -> '||p_event
                            );*/

      process_applications  ( p_araa                =>  p_araa                    ,
                              p_document_type       =>  lv_document_type          ,
                              p_item_classification =>  lv_item_classification    ,
                              p_process_flag        =>  lv_process_flag           ,
                              p_process_message     =>  lv_process_message
                           );
    /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                               pv_log_msg  =>  ' Returned from process_applications lv_process_flag: '||lv_process_flag
                            );*/

    ELSIF  lv_document_type  IN ( jai_constants.trx_type_rct_unapp,                        ---------D3
                                  jai_constants.trx_type_cm_unapp
                                )
    THEN
    /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                               pv_log_msg  =>  ' Before call to process_unapp_rcpt_rev : - p_event -> '||p_event
                            );*/

      process_unapp_rcpt_rev (  p_araa               =>     p_araa                ,
                                p_acra               =>     p_acra                ,
                                p_document_type      =>     lv_document_type      ,
                                p_process_flag       =>     lv_process_flag       ,
                                p_process_message    =>     lv_process_message
                             );

    /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                               pv_log_msg  =>  ' Returned from process_unapp_rcpt_rev lv_process_flag: '||lv_process_flag
                            );*/

    END IF;                                                                               ---------D3

    IF  lv_process_flag = jai_constants.not_applicable THEN                               ---------D4
     /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                 pv_log_msg  =>  'Skip the transaction'
                              );*/

      return;
    END IF;                                                                               ---------D4

    IF lv_process_flag = jai_constants.expected_error    OR                                     ---------D2
       lv_process_flag = jai_constants.unexpected_error
    THEN
      /*
      || As Returned status is an error/not applicable hence:-
      || Set out variables p_process_flag and p_process_message accordingly
      */
      --call to debug package
      /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                 pv_log_msg  =>  ' Error : - lv_process_flag -> '||lv_process_flag||' - '||lv_process_message
                              );*/

      p_process_flag    := lv_process_flag    ;
      p_process_message := lv_process_message ;
      return;
    END IF;                                                                                     ---------D2
  END IF;                                                                                ---------D1


  /*########################################################################################################
  || CALL PROCEDURE TO GENERATE DOCUMENTS FOR ALL EVENTS EXCEPT INVOICE/DEBIT_MEMO/CREDIT_MEMO_APPLICATION
  ########################################################################################################*/

  IF p_event IN ( jai_constants.ar_cash_tax_confirmed ,              ---------C1
                  jai_constants.trx_type_rct_rvs      ,
                  jai_constants.ar_cash               ,                                   ---------D1
                  jai_constants.ar_invoice_type_cm
                )
  THEN
    /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                               pv_log_msg  =>  ' Before call to generate_document : - p_event -> '||p_event
                            );*/


  OPEN cur_get_refs  (cp_transaction_id => ln_transaction_id );
  FETCH cur_get_refs INTO rec_cur_get_refs;
  CLOSE cur_get_refs ;

  OPEN  cur_get_total_tax (cp_transaction_id => ln_transaction_id );
  FETCH cur_get_total_tax INTO ln_tax_tot_amt;
  CLOSE cur_get_total_tax ;

  generate_document (  p_rgm_ref               => rec_cur_get_refs    ,
                       p_total_tax_amt         => ln_tax_tot_amt      ,
                      --p_transaction_id        => ln_transaction_id   ,
                       p_process_flag          => lv_process_flag     ,
                       p_process_message       => lv_process_message
                    );

    /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                        pv_log_msg  =>  ' Returned from generate_document lv_process_flag: '||lv_process_flag
                                     );*/

    IF  lv_process_flag = jai_constants.not_applicable THEN                               ---------D4
     /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                          pv_log_msg  =>  'Skip the transaction'
                                        );*/

      return;
    END IF;                                                                               ---------D4

    IF lv_process_flag = jai_constants.expected_error    OR                                     ---------D2
       lv_process_flag = jai_constants.unexpected_error
    THEN
      /*
      || As Returned status is an error/not applicable hence:-
      || Set out variables p_process_flag and p_process_message accordingly
      */
      --call to debug package
     /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                          pv_log_msg  =>  ' Error : - lv_process_flag -> '||lv_process_flag||' - '||lv_process_message
                                       );*/

      p_process_flag    := lv_process_flag    ;
      p_process_message := lv_process_message ;
      return;
    END IF;                                                                                     ---------D2
  END IF;                                                                                ---------D1

  /*########################################################################################################
  || CALL FOR SURCHARGE PROCESSING
  ########################################################################################################*/

  /*
  ||Call to surcharge package to update the threshold level accordingly
  */
  IF ln_transaction_id IS NOT NULL THEN

    /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                               pv_log_msg  =>  ' Before call to jai_rgm_thhold_proc_pkg.maintain_threshold : - p_event -> '||p_event
                               ||', ln_transaction_id -> '||ln_transaction_id
                            );*/

    jai_rgm_thhold_proc_pkg.maintain_threshold ( p_transaction_id   => ln_transaction_id   ,
                                                 p_process_flag     => lv_process_flag     ,
                                                 p_process_message  => lv_process_message
                                               );

    /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                               pv_log_msg  =>  ' Returned from jai_rgm_thhold_proc_pkg.maintain_threshold lv_process_flag: '||lv_process_flag
                            );*/

    IF  lv_process_flag = jai_constants.not_applicable THEN
     /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                 pv_log_msg  =>  'Skip the transaction'
                              );*/

      return;
    END IF;

    IF lv_process_flag = jai_constants.expected_error    OR                                     ---------D2
       lv_process_flag = jai_constants.unexpected_error
    THEN
      /*
      || As Returned status is an error/not applicable hence:-
      || Set out variables p_process_flag and p_process_message accordingly
      */
      --call to debug package
     /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                 pv_log_msg  =>  ' Error : - lv_process_flag -> '||lv_process_flag||' - '||lv_process_message
                              );*/

      p_process_flag    := lv_process_flag    ;
      p_process_message := lv_process_message ;
      return;
    END IF;                                                                                     ---------D2
  END IF;

 /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                             pv_log_msg  =>  '**************** END OF PROCESS TRANSACTION ****************'
                          );


  jai_cmn_debug_contexts_pkg.deregister (pn_reg_id => ln_reg_id);*/
EXCEPTION
  WHEN OTHERS THEN
    p_process_flag    := jai_constants.unexpected_error;
    p_process_message := lv_context||' Unexpected error occured while processing jai_ar_tcs_rep_pkg.process_transactions'||SQLERRM ;
    /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print( pn_reg_id           => ln_reg_id                   ,
                                      pv_log_msg          => p_process_message           ,
                                      pn_statement_level  => jai_cmn_debug_contexts_pkg.summary
                                   );

 jai_cmn_debug_contexts_pkg.print_stack;*/

END process_transactions ;

  PROCEDURE update_pan_for_tcs          ( p_return_code             OUT NOCOPY          VARCHAR2                                                          ,
                                          p_errbuf                  OUT NOCOPY          VARCHAR2                                                          ,
                                          p_party_id                IN                  JAI_RGM_REFS_ALL.PARTY_ID%TYPE                                    ,
                                          p_old_pan_no              IN                  JAI_CMN_CUS_ADDRESSES.PAN_NO%TYPE                              ,
                                          p_new_pan_no              IN                  JAI_CMN_CUS_ADDRESSES.PAN_NO%TYPE

                                        )
  AS
   ln_reg_id                 NUMBER             ;

   ln_request_id             NUMBER             ;
BEGIN

  /*################################################################################################################
  || Initialize the variables
  ################################################################################################################*/

  lv_member_name        := 'UPDATE_PAN_FOR_TCS';
  set_debug_context;
  /*commented by csahoo for bug# 6401388
  jai_cmn_debug_contexts_pkg.register ( pv_context => lv_context    ,
                                        pn_reg_id  => ln_reg_id
                                       );

   jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                      pv_log_msg  =>  'Parameter passed to update_pan_for_tcs are -> '    ||fnd_global.local_chr(10)
                                                    ||', p_party_id        -> '||p_party_id               ||fnd_global.local_chr(10)
                                                    ||', p_old_pan_no      -> '||p_old_pan_no             ||fnd_global.local_chr(10)
                                                    ||', p_new_pan_no      -> '||p_new_pan_no
                                   );*/

  p_return_code := 0                         ;
  p_errbuf      := Null                      ;
  ln_request_id := fnd_global.conc_request_id;


  /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                      pv_log_msg  =>  'Updating the table JAI_CMN_CUS_ADDRESSES'
                                    );*/

  /*
  ||Update the JAI_CMN_CUS_ADDRESSES table . Set the Old pan number with the new pan number as specified in the input.
  */
  UPDATE
        JAI_CMN_CUS_ADDRESSES
  SET
        pan_no = p_new_pan_no
  WHERE
        customer_id = p_party_id
  AND   pan_no      = p_old_pan_no ;

  /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                      pv_log_msg  =>  'Update to table JAI_CMN_CUS_ADDRESSES successful. Now updating the table jai_rgm_thresholds '
                                   );*/


  /*
  ||Update the JAI_CMN_CUS_ADDRESSES table . Set the Old pan number with the new pan number as specified in the input.
  */
  UPDATE
        jai_rgm_thresholds
  SET
        party_pan_no  = p_new_pan_no
  WHERE
        party_id      = p_party_id
  AND   party_pan_no  = p_old_pan_no ;


  /*commented by csahoo for bug# 6401388
 jai_cmn_debug_contexts_pkg.print (  pn_reg_id   =>  ln_reg_id ,
                                      pv_log_msg  =>  '**************** UPDATE_PAN_FOR_TCS SUCCESSFULLY COMPLETED ****************'
                                   );
  jai_cmn_debug_contexts_pkg.deregister (pn_reg_id => ln_reg_id);*/

EXCEPTION
  WHEN OTHERS THEN
    p_return_code := 2;
    p_errbuf      := 'Unexpected error in the jai_ar_tcs_rep_pkg.update_pan_for_tcs '||substr(sqlerrm,1,300);

END update_pan_for_tcs;
END jai_ar_tcs_rep_pkg;

/
