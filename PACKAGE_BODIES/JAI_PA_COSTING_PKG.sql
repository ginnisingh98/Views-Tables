--------------------------------------------------------
--  DDL for Package Body JAI_PA_COSTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_PA_COSTING_PKG" as
/* $Header: jai_pa_costing.plb 120.4.12010000.6 2010/04/15 10:56:01 boboli ship $*/
/*------------------------------------------------------------------------------------------------------------
  CHANGE HISTORY
  ------------------------------------------------------------------------------------------------------------
  Sl.No.          Date          Developer   BugNo       Version        Remarks
  ------------------------------------------------------------------------------------------------------------
  1.              17/JAN/2007   brathod     5765161     115.0          Created the initial version
  2.              05/APR/2007   cbabu       5765161     115.1          Changes done as required for Budget07

  1.              24-APR-2007    cbabu      6012567     120.0         Forward ported to R12 from R11i taking 115.1 version
  2.              08/Aug/2007    brathod    6321215     120.1         Using deiver transaction quantity instead of
                                                                      quantity as populated in PA_TRANSACTION_INTERFACE
                                                                      for deriving the apportion factor

  3.              28-SEP-2007   Bgowrava	  6452772			120.3					For the Transaction type as 'RETURN TO RECEIVING'
                                                                      the non recoverable tax amount is returned as negative.
  4.              27-NOV-2007   Jia Li                                Changed function get_nonrec_tax_amount
                                                                      for Tax inclusive Computations.
  5.              24-Jun-2009   mbremkum    8400140                   Modified the code in the procedure
                                                                      update_interface_costs. Added the cursors
                                                                      c_get_non_rec_taxes and c_ja_in_rcv_trx.
  6.              09-Jul-2009   mbremkum    8660365                   Appropriation factor was calculated using quantity from Base
                                                                      Project Line. In R12 Projects populates amounts into Quantity.
                                                                      Hence replaced it with the Delivered Quantity.

  7.             15-Apr-2010    Bo Li       9305067                    Replace the old attribute_category columns for JAI_RCV_TRANSACTIONS
                                                                       with new meaningful one

--------------------------------------------------------------------------------------------------------------*/
/*----------------------------------------- PRIVATE MEMBERS DECLRATION -------------------------------------*/

  /** Package level variables used in debug package*/
  lv_object_name  jai_cmn_debug_contexts.log_context%type := 'JAI_PA_COSTING_PKG';
  lv_member_name  jai_cmn_debug_contexts.log_context%type;
  lv_context      jai_cmn_debug_contexts.log_context%type;
  --
  -- Global variables used throught the package
  --
  lv_user_id  fnd_user.user_id%type     default fnd_global.user_id;
  lv_login_id fnd_logins.login_id%type  default fnd_global.login_id;

  -- Package constants
  GV_TRX_SRC_PO_RECEIPT         constant    varchar2  (30)  :=  'PO RECEIPT';
  GV_TRX_SRC_PO_RCPT_PRICE_ADJ  constant    varchar2  (30)  :=  'PO RECEIPT PRICE ADJ';

  gn_func_amount  number;
  gn_trx_amount   number;
  gv_trx_source   varchar2(100);
  gv_line_type    varchar2(30);
  gn_trx_id       number;


  procedure set_debug_context
  is

  begin
    lv_context  := rtrim(lv_object_name || '.'||lv_member_name,'.');
  end set_debug_context;


  function get_func_curr_indicator return varchar2 is
  begin
    return gv_functional_currency;
  end get_func_curr_indicator;

  function get_trx_curr_indicator return varchar2 is
  begin
    return gv_transaction_currency;
  end get_trx_curr_indicator;

  function get_nonrec_tax_amount(

    pv_transaction_source         in  varchar2,
    pv_line_type                  in  varchar2,
    pn_transaction_header_id      in  number,
    pn_transaction_dist_id        in  number,                   /* One of PO_REQ_DISTRIBUTIONS_ALL.distribution_id, PO_DISTRIBUTIONS_ALL.po_distribution_id, RCV_TRANSACTIONS.transaction_id, AP_INVOICE_DISTRIBUTIONS_ALL.invoice_distribution_id */
    pv_currency_of_return_tax_amt in  varchar2  default null,   /* no value is passed, then tax amount in transaction currency is returned */
    pv_transaction_uom            in  varchar2  default null,   /* if not given, then conversion of UOM w.r.to main transaction will not be performed */
    pn_transaction_qty            in  number    default null,
    pn_currency_conv_rate         in  number    default null

  ) return number is

    ln_nonreco_tax_amt              number;
    ln_trx_nonreco_tax_amt          number;
    ln_func_nonreco_tax_amt         number;

    ln_currency_conv_rate           number;
    lv_currency_of_return_tax_amt   varchar2(30);

    ln_apportion_factor             number;
    lv_src_type_rtr                 VARCHAR2(50);  --bgowrava for Bug#6452772

    cursor c_get_reqn_dist_dtl(pn_req_dist_id in number) is
      select requisition_line_id, req_line_quantity
      from po_req_distributions_all
      where distribution_id = pn_req_dist_id;
    r_get_reqn_dist_dtl     c_get_reqn_dist_dtl%rowtype;

    cursor c_get_reqn_line_dtl(pn_req_line_id in number) is
      select quantity
      from po_requisition_lines_all
      where requisition_line_id = pn_req_line_id;
    r_get_reqn_line_dtl     c_get_reqn_line_dtl%rowtype;

    cursor c_get_po_dist_dtl(pn_po_dist_id in number) is
      select line_location_id, quantity_ordered
      from po_distributions_all
      where po_distribution_id = pn_po_dist_id;
    r_get_po_dist_dtl     c_get_po_dist_dtl%rowtype;

    cursor c_get_po_line_loc_dtl(pn_line_loc_id in number) is
      select quantity
      from po_line_locations_all
      where line_location_id = pn_line_loc_id;
    r_get_po_line_loc_dtl     c_get_po_line_loc_dtl%rowtype;

    cursor c_ja_in_rcv_trx(cp_transaction_id in number) is
      select *
      from JAI_RCV_TRANSACTIONS
      where transaction_id = cp_transaction_id;
    r_ja_in_receive_trx                 c_ja_in_rcv_trx%rowtype;
    r_ja_in_deliver_trx                 c_ja_in_rcv_trx%rowtype;

    ln_reg_id   number;

    -- Added by Jia Li for Tax inclusive Computations on 2007/11/27, Begin
    -- TD16-Changed Project Costing
    -- these variables storage inclusive reco and non-reco tax amt
    -----------------------------------------------------------------------
    ln_trx_inclu_reco_tax_amt      NUMBER;
    ln_func_inclu_reco_tax_amt     NUMBER;
    ---------------------------------------------------------------------------------------
    -- Added by Jia Li for Tax inclusive Computations on 2007/11/27, End

  begin
    lv_src_type_rtr := 'RETURN TO RECEIVING';   --bgowrava for Bug#6452772
    lv_member_name := 'GET_NONREC_TAX_AMOUNT';
    set_debug_context;
    jai_cmn_debug_contexts_pkg.register ( pv_context => lv_context
                                        , pn_reg_id  => ln_reg_id
                                        );
    if pn_currency_conv_rate is null or pn_currency_conv_rate = 0 then
      ln_currency_conv_rate       := 1;
    else
      ln_currency_conv_rate       := nvl(pn_currency_conv_rate, 1);
    end if;
    lv_currency_of_return_tax_amt := nvl(pv_currency_of_return_tax_amt, gv_transaction_currency);

    jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'lv_currency_of_return_tax_amt='||lv_currency_of_return_tax_amt );

    /* this logic is to avoid recalculation of amounts if called multiple times for the same transaction dtls consecutively*/
    if gv_trx_source = pv_transaction_source
      and gv_line_type = pv_line_type
      and gn_trx_id = pn_transaction_dist_id
    then
      ln_func_nonreco_tax_amt := gn_func_amount;
      ln_trx_nonreco_tax_amt  := gn_trx_amount;
      ln_func_inclu_reco_tax_amt := gn_func_amount;  -- Added by Jia Li for Tax inclusive Computations on 2007/11/27
      ln_trx_inclu_reco_tax_amt  := gn_trx_amount;   -- Added by Jia Li for Tax inclusive Computations on 2007/11/27
      goto return_amount;
    else
      gv_trx_source   := pv_transaction_source;
      gv_line_type    := pv_line_type;
      gn_trx_id       := pn_transaction_dist_id;
    end if;


    /* find the apportion factor */
    /* apportion should consider only quantity */
    -- NULL;

    /* calculate the non recoverable tax */
    /* this should consider currency, recoverable percentage and apportion factor when calculating the tax */

    jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'pv_line_type='||pv_line_type || ', pv_transaction_source='||pv_transaction_source);

    if pv_transaction_source = JAI_PA_COSTING_PKG.gv_src_oracle_purchasing then

      /* 1 - REQUISITONS */
      if pv_line_type = JAI_PA_COSTING_PKG.gv_line_type_requisition then

        open c_get_reqn_dist_dtl(pn_transaction_dist_id);
        fetch c_get_reqn_dist_dtl into r_get_reqn_dist_dtl;
        close c_get_reqn_dist_dtl;

        select
          nvl(
            sum(
            decode(nvl(a.currency, 'INR'), 'INR',
              a.tax_amount * decode( nvl(a.modvat_flag, 'N'), 'N', 1, (1- nvl(b.mod_cr_percentage,0)/100)),
              a.tax_amount * decode( nvl(a.modvat_flag, 'N'), 'N', 1, (1- nvl(b.mod_cr_percentage,0)/100)) * ln_currency_conv_rate
            )
          ),0) functional_tax_amount ,
          nvl(
            sum(
            decode(nvl(a.currency, 'INR'), 'INR',
              a.tax_amount * decode( nvl(a.modvat_flag, 'N'), 'N', 1, (1- nvl(b.mod_cr_percentage,0)/100)) / ln_currency_conv_rate,
              a.tax_amount * decode( nvl(a.modvat_flag, 'N'), 'N', 1, (1- nvl(b.mod_cr_percentage,0)/100))
            )
          ),0) transaction_tax_amount
        into ln_func_nonreco_tax_amt, ln_trx_nonreco_tax_amt
        from JAI_PO_REQ_LINE_TAXES a, JAI_CMN_TAXES_ALL b
        where a.tax_id = b.tax_id
        and (
                ( pn_transaction_dist_id is not null and a.requisition_line_id = r_get_reqn_dist_dtl.requisition_line_id )
            or  (pn_transaction_dist_id is null and a.requisition_header_id = pn_transaction_header_id)
          );

        -- Added by Jia Li for Tax inclusive Computations on 2007/11/27, Begin
        -- TD16-Changed Project Costing
        -- Get inclusive tax amount
        -----------------------------------------------------------------------
        SELECT
          NVL(
            SUM( DECODE(NVL(a.currency, 'INR'), 'INR', a.tax_amount,
                          a.tax_amount * ln_currency_conv_rate)
                ),0) functional_tax_amount,
          NVL(
            SUM( DECODE(NVL(a.currency, 'INR'), 'INR', a.tax_amount/ln_currency_conv_rate,
                          a.tax_amount)
                ),0) transaction_tax_amount
        INTO
          ln_func_inclu_reco_tax_amt
        , ln_trx_inclu_reco_tax_amt
        FROM
          jai_po_req_line_taxes a
        , jai_cmn_taxes_all b
        WHERE a.tax_id = b.tax_id
          AND NVL(b.inclusive_tax_flag, 'N') = 'Y'
          AND ( ( pn_transaction_dist_id IS NOT NULL
                 AND
                  a.requisition_line_id = r_get_reqn_dist_dtl.requisition_line_id )
               OR
                ( pn_transaction_dist_id IS NULL
                 AND
                  a.requisition_header_id = pn_transaction_header_id )
               );
        ---------------------------------------------------------------------------------------
        -- Added by Jia Li for Tax inclusive Computations on 2007/11/27, End

        open c_get_reqn_line_dtl(r_get_reqn_dist_dtl.requisition_line_id);
        fetch c_get_reqn_line_dtl into r_get_reqn_line_dtl;
        close c_get_reqn_line_dtl;

        jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'pn_transaction_qty='||pn_transaction_qty ||',r_get_reqn_line_dtl.quantity='||r_get_reqn_line_dtl.quantity );

        if pn_transaction_qty is not null
          and pn_transaction_qty <> 0
          and r_get_reqn_line_dtl.quantity is not null
          and r_get_reqn_line_dtl.quantity <> 0
          and r_get_reqn_line_dtl.quantity <> pn_transaction_qty
        then
          ln_apportion_factor := pn_transaction_qty / r_get_reqn_line_dtl.quantity;
        else
          ln_apportion_factor := 1;
        end if;

        jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'ln_apportion_factor='||ln_apportion_factor);

        ln_func_nonreco_tax_amt := ln_func_nonreco_tax_amt * ln_apportion_factor;
        ln_trx_nonreco_tax_amt  := ln_trx_nonreco_tax_amt * ln_apportion_factor;

        ln_func_inclu_reco_tax_amt := ln_func_inclu_reco_tax_amt * ln_apportion_factor; -- Added by Jia Li for Tax inclusive Computations on 2007/11/27
        ln_trx_inclu_reco_tax_amt  := ln_trx_inclu_reco_tax_amt * ln_apportion_factor;  -- Added by Jia Li for Tax inclusive Computations on 2007/11/27


      /* 2 - PURCHASE ORDERS */
      elsif pv_line_type = JAI_PA_COSTING_PKG.gv_line_type_purchasing then

        open c_get_po_dist_dtl(pn_transaction_dist_id);
        fetch c_get_po_dist_dtl into r_get_po_dist_dtl;
        close c_get_po_dist_dtl;

        select
          nvl(
            sum(
            decode(nvl(a.currency, 'INR'), 'INR',
              a.tax_amount * decode( nvl(a.modvat_flag, 'N'), 'N', 1,(1- nvl(b.mod_cr_percentage,0)/100)),
              a.tax_amount * decode( nvl(a.modvat_flag, 'N'), 'N', 1,(1- nvl(b.mod_cr_percentage,0)/100)) * ln_currency_conv_rate
            )
          ),0) functional_tax_amount ,
          nvl(
            sum(
            decode(nvl(a.currency, 'INR'), 'INR',
              a.tax_amount * decode( nvl(a.modvat_flag, 'N'), 'N', 1,(1- nvl(b.mod_cr_percentage,0)/100)) / ln_currency_conv_rate,
              a.tax_amount * decode( nvl(a.modvat_flag, 'N'), 'N', 1,(1- nvl(b.mod_cr_percentage,0)/100))
            )
          ),0) transaction_tax_amount
        into ln_func_nonreco_tax_amt, ln_trx_nonreco_tax_amt
        from JAI_PO_TAXES a, JAI_CMN_TAXES_ALL b
        where a.tax_id = b.tax_id
        and (
                ( pn_transaction_dist_id is not null and a.line_location_id = r_get_po_dist_dtl.line_location_id )
            or  ( pn_transaction_dist_id is null and a.po_header_id = pn_transaction_header_id)
          );

        -- Added by Jia Li for Tax inclusive Computations on 2007/11/27, Begin
        -- TD16-Changed Project Costing
        -- Get inclusive tax amount
        -----------------------------------------------------------------------
        SELECT
          NVL(
            SUM( DECODE(NVL(a.currency, 'INR'), 'INR', a.tax_amount ,
                          a.tax_amount * ln_currency_conv_rate)
                ),0) functional_tax_amount ,
          NVL(
            SUM( DECODE(NVL(a.currency, 'INR'), 'INR', a.tax_amount/ln_currency_conv_rate,
                          a.tax_amount)
                ),0) transaction_tax_amount
        INTO
          ln_func_inclu_reco_tax_amt
        , ln_trx_inclu_reco_tax_amt
        FROM
          jai_po_taxes      a
        , jai_cmn_taxes_all b
        WHERE a.tax_id = b.tax_id
          AND NVL(b.inclusive_tax_flag, 'N') = 'Y'
          AND ( ( pn_transaction_dist_id IS NOT NULL
                 AND
                  a.line_location_id = r_get_po_dist_dtl.line_location_id )
               OR
                ( pn_transaction_dist_id IS NULL
                 AND
                  a.po_header_id = pn_transaction_header_id )
               );
        ---------------------------------------------------------------------------------------
        -- Added by Jia Li for Tax inclusive Computations on 2007/11/27, End

        open c_get_po_line_loc_dtl(r_get_po_dist_dtl.line_location_id);
        fetch c_get_po_line_loc_dtl into r_get_po_line_loc_dtl;
        close c_get_po_line_loc_dtl;

        jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'pn_transaction_qty='||pn_transaction_qty ||',r_get_po_line_loc_dtl.quantity='||r_get_po_line_loc_dtl.quantity);

        if pn_transaction_qty is not null
          and pn_transaction_qty <> 0
          and r_get_po_line_loc_dtl.quantity is not null
          and r_get_po_line_loc_dtl.quantity <> 0
          and r_get_po_line_loc_dtl.quantity <> pn_transaction_qty
        then
          ln_apportion_factor := pn_transaction_qty / r_get_po_line_loc_dtl.quantity;
        else
          ln_apportion_factor := 1;
        end if;

        jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'ln_apportion_factor='||ln_apportion_factor);

        ln_func_nonreco_tax_amt := ln_func_nonreco_tax_amt * ln_apportion_factor;
        ln_trx_nonreco_tax_amt  := ln_trx_nonreco_tax_amt * ln_apportion_factor;

        ln_func_inclu_reco_tax_amt := ln_func_inclu_reco_tax_amt * ln_apportion_factor; -- Added by Jia Li for Tax inclusive Computations on 2007/11/27
        ln_trx_inclu_reco_tax_amt  := ln_trx_inclu_reco_tax_amt * ln_apportion_factor;  -- Added by Jia Li for Tax inclusive Computations on 2007/11/27

      /* 3 - PURCHASE RECEIPTS */
      elsif pv_line_type = JAI_PA_COSTING_PKG.gv_line_type_po_receipt then


        open c_ja_in_rcv_trx(pn_transaction_dist_id);
        fetch c_ja_in_rcv_trx into r_ja_in_deliver_trx;
        close c_ja_in_rcv_trx;

        select
          /* functional tax amount calc */
          nvl(
           sum(
            decode(nvl(a.currency, 'INR'), 'INR',
              a.tax_amount
              * decode(
                  decode(
                    r_ja_in_deliver_trx.cenvat_costed_flag, 'Y', --Modified by Bo Li for bug9305067 replace the attribute2 with cenvat_costed_flag
                        decode(upper(b.tax_type), 'EXCISE', 'N', 'OTHER EXCISE', 'N', 'ADDL. EXCISE', 'N'
                                              , 'CVD', 'N', 'EXCISE_EDUCATION_CESS', 'N', 'CVD_EDUCATION_CESS', 'N'
                                              , 'ADDITIONAL_CVD', 'N'
                                              , jai_constants.tax_type_sh_exc_edu_cess, 'N'
                                              , jai_constants.tax_type_sh_cvd_edu_cess, 'N'
                                              , a.modvat_flag)
                    , a.modvat_flag
                  ),
                  'N', 1,(1- nvl(b.mod_cr_percentage,0)/100)),
              /* if not INR, then following logic will be applied */
              a.tax_amount
              * decode(
                  decode(
                    r_ja_in_deliver_trx.cenvat_costed_flag, 'Y',--Modified by Bo Li for bug9305067 replace the attribute2 with cenvat_costed_flag
                        decode(upper(b.tax_type), 'EXCISE', 'N', 'OTHER EXCISE', 'N', 'ADDL. EXCISE', 'N'
                                              , 'CVD', 'N', 'EXCISE_EDUCATION_CESS', 'N', 'CVD_EDUCATION_CESS', 'N'
                                              , 'ADDITIONAL_CVD', 'N'
                                              , jai_constants.tax_type_sh_exc_edu_cess, 'N'
                                              , jai_constants.tax_type_sh_cvd_edu_cess, 'N'
                                              , a.modvat_flag)
                    , a.modvat_flag
                  ),
                  'N', 1,(1- nvl(b.mod_cr_percentage,0)/100)
                )
              * ln_currency_conv_rate
           )
          ),0) functional_tax_amount ,
          /* transaction tax amount calc */
          nvl(
           sum(
            decode(nvl(a.currency, 'INR'), 'INR',
              a.tax_amount
              * decode(
                  decode(
                    r_ja_in_deliver_trx.cenvat_costed_flag, 'Y',--Modified by Bo Li for bug9305067 replace the attribute2 with cenvat_costed_flag
                        decode(upper(b.tax_type), 'EXCISE', 'N', 'OTHER EXCISE', 'N', 'ADDL. EXCISE', 'N'
                                              , 'CVD', 'N', 'EXCISE_EDUCATION_CESS', 'N', 'CVD_EDUCATION_CESS', 'N'
                                              , 'ADDITIONAL_CVD', 'N'
                                              , jai_constants.tax_type_sh_exc_edu_cess, 'N'
                                              , jai_constants.tax_type_sh_cvd_edu_cess, 'N'
                                              , a.modvat_flag)
                    , a.modvat_flag
                  ),
                  'N', 1,(1- nvl(b.mod_cr_percentage,0)/100))
              / ln_currency_conv_rate,
              /* if not INR, then following logic will be applied */
              a.tax_amount
              * decode(
                  decode(
                    r_ja_in_deliver_trx.cenvat_costed_flag, 'Y',--Modified by Bo Li for bug9305067 replace the attribute2 with cenvat_costed_flag
                        decode(upper(b.tax_type), 'EXCISE', 'N', 'OTHER EXCISE', 'N', 'ADDL. EXCISE', 'N'
                                              , 'CVD', 'N', 'EXCISE_EDUCATION_CESS', 'N', 'CVD_EDUCATION_CESS', 'N'
                                              , 'ADDITIONAL_CVD', 'N'
                                              , jai_constants.tax_type_sh_exc_edu_cess, 'N'
                                              , jai_constants.tax_type_sh_cvd_edu_cess, 'N'
                                              , a.modvat_flag)
                    , a.modvat_flag
                  ),
                  'N', 1,(1- nvl(b.mod_cr_percentage,0)/100)
                )
           )
          ),0) transaction_tax_amount
        into ln_func_nonreco_tax_amt, ln_trx_nonreco_tax_amt
        from JAI_RCV_LINE_TAXES a, JAI_CMN_TAXES_ALL b
        where a.tax_id = b.tax_id
        and (
--                ( pn_transaction_dist_id is not null and a.transaction_id = r_ja_in_deliver_trx.tax_transaction_id )
                ( pn_transaction_dist_id is not null and a.shipment_line_id = r_ja_in_deliver_trx.shipment_line_id )
            or  ( pn_transaction_dist_id is null and a.shipment_header_id = pn_transaction_header_id)
          );


        -- Added by Jia Li for Tax inclusive Computations on 2007/11/27, Begin
        -- TD16-Changed Project Costing
        -- Get inclusive tax amount
        -----------------------------------------------------------------------
        SELECT
          /* functional inclusive tax amount calc */
          NVL(
           SUM(
            DECODE(NVL(a.currency, 'INR'), 'INR', a.tax_amount ,
                    a.tax_amount * ln_currency_conv_rate)
              ), 0) functional_tax_amount ,
          /* transaction inclusive tax amount calc */
          NVL(
           SUM(
            DECODE(NVL(a.currency, 'INR'), 'INR', a.tax_amount / ln_currency_conv_rate,
                     a.tax_amount)
              ), 0) transaction_tax_amount
        INTO
          ln_func_inclu_reco_tax_amt
        , ln_trx_inclu_reco_tax_amt
        FROM
          jai_rcv_line_taxes a
        , jai_cmn_taxes_all  b
        WHERE a.tax_id = b.tax_id
          AND NVL(b.inclusive_tax_flag, 'N') = 'Y'
          AND ( ( pn_transaction_dist_id IS NOT NULL
--                  AND a.transaction_id = r_ja_in_deliver_trx.tax_transaction_id )
                  AND a.shipment_line_id = r_ja_in_deliver_trx.shipment_line_id )
               OR
                ( pn_transaction_dist_id IS NULL
                  AND a.shipment_header_id = pn_transaction_header_id)
               );
        ---------------------------------------------------------------------------------------
        -- Added by Jia Li for Tax inclusive Computations on 2007/11/27, End


        open c_ja_in_rcv_trx(r_ja_in_deliver_trx.tax_transaction_id);
        fetch c_ja_in_rcv_trx into r_ja_in_receive_trx;
        close c_ja_in_rcv_trx;

        /* Cases to be taken care
           1. Non bonded delivery -- Implemented in the SELECT query for amounts itself using attribute2 of DELIVER transaction
           2. UOM Conversion
           3. Quantity change between receive and deliver  -- Implemented with below apportion code
        */

        -- Bug# 6321215
        -- Changed pn_transaction_qty to r_ja_in_receive_trx.quantity.  This is done because in R12 PA populates amount
        -- for quantity column if expenditure_type is not rate enabled.  Hence refering to DELIVER quantity to determine the
        -- apportion factor
        jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'r_ja_in_deliver_trx.quantity='||r_ja_in_deliver_trx.quantity ||
                                                   ', r_ja_in_receive_trx.quantity='||r_ja_in_receive_trx.quantity ||
                                                   ', pn_transaction_qty =' || pn_transaction_qty
                                          );


        if    r_ja_in_deliver_trx.quantity is not null
          and r_ja_in_deliver_trx.quantity <> 0
          and r_ja_in_receive_trx.quantity is not null
          and r_ja_in_receive_trx.quantity <> 0
          and r_ja_in_receive_trx.quantity <> r_ja_in_deliver_trx.quantity
        then
          ln_apportion_factor := r_ja_in_deliver_trx.quantity  / r_ja_in_receive_trx.quantity;
        else
          ln_apportion_factor := 1;
        end if;
        -- End Bug 6321215

        jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'ln_apportion_factor='||ln_apportion_factor);

        ln_func_nonreco_tax_amt := ln_func_nonreco_tax_amt * ln_apportion_factor;
        ln_trx_nonreco_tax_amt  := ln_trx_nonreco_tax_amt * ln_apportion_factor;

        ln_func_inclu_reco_tax_amt := ln_func_inclu_reco_tax_amt * ln_apportion_factor; -- Added by Jia Li for Tax inclusive Computations on 2007/11/27
        ln_trx_inclu_reco_tax_amt  := ln_trx_inclu_reco_tax_amt * ln_apportion_factor;  -- Added by Jia Li for Tax inclusive Computations on 2007/11/27

        /*START, Bgowrava for Bug#6452772*/
        IF r_ja_in_deliver_trx.transaction_type = lv_src_type_rtr THEN
           ln_func_nonreco_tax_amt := ln_func_nonreco_tax_amt*-1;
           ln_trx_nonreco_tax_amt := ln_trx_nonreco_tax_amt*-1;

          ln_func_inclu_reco_tax_amt := ln_func_inclu_reco_tax_amt * -1; -- Added by Jia Li for Tax inclusive Computations on 2007/11/27
          ln_trx_inclu_reco_tax_amt  := ln_trx_inclu_reco_tax_amt * -1;  -- Added by Jia Li for Tax inclusive Computations on 2007/11/27

        END IF;
        /*END, Bgowrava for Bug#6452772*/

      end if;

    /* 4 - PAYABLE INVOICES */
    elsif pv_transaction_source = JAI_PA_COSTING_PKG.gv_src_oracle_payables
      and pv_line_type = JAI_PA_COSTING_PKG.gv_line_type_invoice
    then

      select
        nvl(sum(a.base_amount),0) functional_tax_amount,
        nvl(sum(a.tax_amount),0)  transaction_tax_amount
      into ln_func_nonreco_tax_amt, ln_trx_nonreco_tax_amt
      from JAI_AP_MATCH_INV_TAXES a, JAI_CMN_TAXES_ALL b
      where a.tax_id = b.tax_id
      and nvl(b.mod_cr_percentage, 0) = 0
      and (a.invoice_id, a.parent_invoice_distribution_id) =
        ( select invoice_id, invoice_distribution_id from ap_invoice_distributions_all
          where invoice_id = pn_transaction_header_id and distribution_line_number = pn_transaction_dist_id);

      -- Added by Jia Li for Tax inclusive Computations on 2007/11/27, Begin
      -- TD16-Changed Project Costing
      -- Get inclusive recoverable tax amount
      -----------------------------------------------------------------------
      SELECT
        NVL(SUM(a.base_amount),0) functional_tax_amount,
        NVL(SUM(a.tax_amount),0)  transaction_tax_amount
      INTO
        ln_func_inclu_reco_tax_amt
      , ln_trx_inclu_reco_tax_amt
      FROM
        jai_ap_match_inv_taxes a
      , jai_cmn_taxes_all      b
      WHERE a.tax_id = b.tax_id
        AND NVL(b.inclusive_tax_flag, 'N') = 'Y'
        AND a.recoverable_flag = 'Y'
        AND ( a.invoice_id, a.parent_invoice_distribution_id) =
              ( SELECT
                  invoice_id
                , invoice_distribution_id
                FROM
                  ap_invoice_distributions_all
                WHERE invoice_id = pn_transaction_header_id
                  AND distribution_line_number = pn_transaction_dist_id);
      ---------------------------------------------------------------------------------------
      -- Added by Jia Li for Tax inclusive Computations on 2007/11/27, End

    end if;

    -- Added by Jia Li for Tax inclusive Computations on 2007/11/27, Begin
    ------------------------------------------------------------------------
    ln_func_nonreco_tax_amt := ln_func_nonreco_tax_amt - ln_func_inclu_reco_tax_amt;
    ln_trx_nonreco_tax_amt := ln_trx_nonreco_tax_amt - ln_trx_inclu_reco_tax_amt;
    ------------------------------------------------------------------------------
    -- Added by Jia Li for Tax inclusive Computations on 2007/11/27, End
    gn_func_amount  := ln_func_nonreco_tax_amt ;
    gn_trx_amount   := ln_trx_nonreco_tax_amt ;

    <<return_amount>>

    if pv_currency_of_return_tax_amt is null
      or pv_currency_of_return_tax_amt = JAI_PA_COSTING_PKG.gv_transaction_currency
    then
      return (ln_trx_nonreco_tax_amt);
    else
      return (ln_func_nonreco_tax_amt);
    end if;

  end get_nonrec_tax_amount;


  /*------------------------------------------------------------------------------------------------------------*/
  procedure pre_process
            ( p_transaction_source    in  varchar2,
              p_batch                 in  varchar2,
              p_xface_id              in  number,
              p_user_id               in  number
            )
  is
    lv_process_flag      varchar2 (2);
    lv_process_message   varchar2 (2000);
    ln_reg_id            number;

  begin <<pre_process>>
    lv_member_name := 'PRE_PROCESS';
    set_debug_context;
    jai_cmn_debug_contexts_pkg.register ( pv_context => lv_context
                                        , pn_reg_id  => ln_reg_id
                                        );

    jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Call Parameters:'   ||                        fnd_global.local_chr(10)     ||
                                                 'p_transaction_source='||  p_transaction_source  ||fnd_global.local_chr(10) ||
                                                 'p_batch             ='||  p_batch               ||fnd_global.local_chr(10) ||
                                                 'p_xface_id          ='||  p_xface_id            ||fnd_global.local_chr(10) ||
                                                 'p_user_id           ='||  p_user_id
                                     );

    if p_transaction_source not in (GV_TRX_SRC_PO_RECEIPT)
        -- This source need not be implemented as it is for retroactive pricing functionality, GV_TRX_SRC_PO_RCPT_PRICE_ADJ)
    then
      return;
    end if;

   -- delegate call to update_interface_costs
    update_interface_costs ( p_transaction_source => p_transaction_source
                           , p_batch              => p_batch
                           , p_xface_id           => p_xface_id
                           , p_process_flag       => lv_process_flag
                           , p_process_message    => lv_process_message
                           );
    if lv_process_flag <> jai_constants.SUCCESSFUL then
      jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'lv_process_flag='||lv_process_flag ||',Message='||lv_process_message);
      return;
    end if;
  /** Deregister procedure and return*/
    <<deregister_and_return>>
    jai_cmn_debug_contexts_pkg.deregister (pn_reg_id => ln_reg_id);

  exception
    when others then
      jai_cmn_debug_contexts_pkg.print(ln_reg_id,lv_context||'->'||sqlerrm,jai_cmn_debug_contexts_pkg.summary);
      jai_cmn_debug_contexts_pkg.print_stack;

  end pre_process;

  /*------------------------------------------------------------------------------------------------------------*/

  procedure update_interface_costs
            ( p_transaction_source    in          varchar2
            , p_batch                 in          varchar2
            , p_xface_id              in          varchar2
            , p_process_flag          out nocopy  varchar2
            , p_process_message       out nocopy  varchar2
            )
  is

    cursor c_pa_trx_xface_records
    is
      select *
      from   pa_transaction_interface_all
      where  transaction_source = p_transaction_source
      and    batch_name         = p_batch
      and    transaction_status_code  =  'P'
      and    interface_id       = p_xface_id;

    /*Bug 8400140 - Start*/

    Cursor c_get_non_rec_taxes ( cp_tax_transaction_id IN JAI_RCV_LINE_TAXES.transaction_id%type,
                                 cp_attribute2  IN VARCHAR2,
                                 cp_curr_conv_rate In NUMBER)
    IS
      select
       a.vendor_id , /*Added by nprashar for bug # 8691525*/
        /* functional tax amount calc */
        nvl(
          decode(nvl(a.currency, 'INR'), 'INR',
            a.tax_amount
            * decode(
                decode(
                  cp_attribute2, 'Y',
                      decode(upper(b.tax_type), 'EXCISE', 'N', 'OTHER EXCISE', 'N', 'ADDL. EXCISE', 'N'
                                            , 'CVD', 'N', 'EXCISE_EDUCATION_CESS', 'N', 'CVD_EDUCATION_CESS', 'N'
                                            , 'ADDITIONAL_CVD', 'N'
                                            , jai_constants.tax_type_sh_exc_edu_cess, 'N'
                                            , jai_constants.tax_type_sh_cvd_edu_cess, 'N'
                                            , a.modvat_flag)
                  , a.modvat_flag
                ),
                'N', 1,(1- nvl(b.mod_cr_percentage,0)/100)),
            /* if not INR, then following logic will be applied */
            a.tax_amount
            * decode(
                decode(
                  cp_attribute2, 'Y',
                      decode(upper(b.tax_type), 'EXCISE', 'N', 'OTHER EXCISE', 'N', 'ADDL. EXCISE', 'N'
                                            , 'CVD', 'N', 'EXCISE_EDUCATION_CESS', 'N', 'CVD_EDUCATION_CESS', 'N'
                                            , 'ADDITIONAL_CVD', 'N'
                                            , jai_constants.tax_type_sh_exc_edu_cess, 'N'
                                            , jai_constants.tax_type_sh_cvd_edu_cess, 'N'
                                            , a.modvat_flag)
                  , a.modvat_flag
                ),
                'N', 1,(1- nvl(b.mod_cr_percentage,0)/100)
              )
            * cp_curr_conv_rate
        ),0) functional_tax_amount ,
        /* transaction tax amount calc */
        nvl(
          decode(nvl(a.currency, 'INR'), 'INR',
            a.tax_amount
            * decode(
                decode(
                  cp_attribute2, 'Y',
                      decode(upper(b.tax_type), 'EXCISE', 'N', 'OTHER EXCISE', 'N', 'ADDL. EXCISE', 'N'
                                            , 'CVD', 'N', 'EXCISE_EDUCATION_CESS', 'N', 'CVD_EDUCATION_CESS', 'N'
                                            , 'ADDITIONAL_CVD', 'N'
                                            , jai_constants.tax_type_sh_exc_edu_cess, 'N'
                                            , jai_constants.tax_type_sh_cvd_edu_cess, 'N'
                                            , a.modvat_flag)
                  , a.modvat_flag
                ),
                'N', 1,(1- nvl(b.mod_cr_percentage,0)/100))
            / cp_curr_conv_rate,
            /* if not INR, then following logic will be applied */
            a.tax_amount
            * decode(
                decode(
                  cp_attribute2, 'Y',
                      decode(upper(b.tax_type), 'EXCISE', 'N', 'OTHER EXCISE', 'N', 'ADDL. EXCISE', 'N'
                                            , 'CVD', 'N', 'EXCISE_EDUCATION_CESS', 'N', 'CVD_EDUCATION_CESS', 'N'
                                            , 'ADDITIONAL_CVD', 'N'
                                            , jai_constants.tax_type_sh_exc_edu_cess, 'N'
                                            , jai_constants.tax_type_sh_cvd_edu_cess, 'N'
                                            , a.modvat_flag)
                  , a.modvat_flag
                ),
                'N', 1,(1- nvl(b.mod_cr_percentage,0)/100)
              )
        ),0) transaction_tax_amount
      from JAI_RCV_LINE_TAXES a, JAI_CMN_TAXES_ALL b
      where a.tax_id = b.tax_id
      and a.transaction_id = cp_tax_transaction_id;

    cursor c_ja_in_rcv_trx(cp_transaction_id in number) is
      select *
      from jai_rcv_transactions
      where transaction_id = cp_transaction_id;
    r_ja_in_receive_trx                 c_ja_in_rcv_trx%rowtype;
    r_ja_in_deliver_trx                 c_ja_in_rcv_trx%rowtype;
    ln_apportion_factor                 number;

    /*Bug 8400140 - End*/

    ln_reg_id   number;
    ln_apportioned_txn_tax_amt  number;
    ln_apportioned_func_tax_amt number;

  begin <<update_interface_costs>>

    lv_member_name := 'UPDATE_INTERFACE_COSTS';
    set_debug_context;

    jai_cmn_debug_contexts_pkg.register (lv_context, ln_reg_id);
    for r_po_rcpt in c_pa_trx_xface_records
    loop

      ln_apportioned_func_tax_amt := 0;
      ln_apportioned_txn_tax_amt := 0;

      /*Commented for Bug 8400140*/
      /*
      jai_cmn_debug_contexts_pkg.print
                         ( ln_reg_id
                         , 'r_po_rcpt.cdl_system_reference4 (rcv_transaction_id)='||r_po_rcpt.cdl_system_reference4 || fnd_global.local_chr(10) ||
                           'r_po_rcpt.unit_of_measure='||r_po_rcpt.unit_of_measure|| fnd_global.local_chr(10) ||
                           'r_po_rcpt.quantity='||r_po_rcpt.quantity              || fnd_global.local_chr(10) ||
                           'r_po_rcpt.txn_interface_id='||r_po_rcpt.txn_interface_id
                         );
      ln_apportioned_txn_tax_amt := JAI_PA_COSTING_PKG.get_nonrec_tax_amount
                                    (   pv_transaction_source    => JAI_PA_COSTING_PKG.GV_SRC_ORACLE_PURCHASING
                                      , pv_line_type             => JAI_PA_COSTING_PKG.GV_LINE_TYPE_PO_RECEIPT
                                      , pn_transaction_header_id => null -- ''
                                      , pn_transaction_dist_id   => r_po_rcpt.cdl_system_reference4   --> rcv_transaction_id
                                      , pv_currency_of_return_tax_amt => JAI_PA_COSTING_PKG.gv_transaction_currency
                                      , pv_transaction_uom       => r_po_rcpt.unit_of_measure
                                      , pn_transaction_qty       => r_po_rcpt.quantity
                                      , pn_currency_conv_rate    => r_po_rcpt.receipt_exchange_rate
                                    );

      ln_apportioned_func_tax_amt := JAI_PA_COSTING_PKG.get_nonrec_tax_amount
                                    (   pv_transaction_source    => JAI_PA_COSTING_PKG.GV_SRC_ORACLE_PURCHASING
                                      , pv_line_type             => JAI_PA_COSTING_PKG.GV_LINE_TYPE_PO_RECEIPT
                                      , pn_transaction_header_id => null -- ''
                                      , pn_transaction_dist_id   => r_po_rcpt.cdl_system_reference4   --> rcv_transaction_id
                                      , pv_currency_of_return_tax_amt => JAI_PA_COSTING_PKG.gv_functional_currency
                                      , pv_transaction_uom       => r_po_rcpt.unit_of_measure -- this value is not being populated by costing. so we need to fetch from JAI_RCV_TRANSACTIONS
                                      , pn_transaction_qty       => r_po_rcpt.quantity
                                      , pn_currency_conv_rate    => r_po_rcpt.receipt_exchange_rate
                                    );

      jai_cmn_debug_contexts_pkg.print
                         ( ln_reg_id
                         , 'ln_apportioned_txn_tax_amt='||ln_apportioned_txn_tax_amt
                            ||', ln_apportioned_func_tax_amt='||ln_apportioned_func_tax_amt
                         );

      jai_cmn_debug_contexts_pkg.print
                         ( ln_reg_id
                         ,'Before update pa_transaction_interface_all'
                         );
      */
      /*
      update   pa_transaction_interface_all
      set      raw_cost         =   raw_cost       + nvl(ln_apportioned_tax_amt,0)
              -- commented after talking to PROJECTs DEV team
              -- ,receipt_currency_amount = receipt_currency_amount + nvl(ln_apportioned_tax_amt,0)
              , denom_raw_cost   =   denom_raw_cost + nvl(ln_apportioned_tax_amt,0)
              , acct_raw_cost    =   acct_raw_cost  + nvl(ln_apportioned_tax_amt,0)
      where    txn_interface_id =   r_po_rcpt.txn_interface_id ;
      */

      -- Commented the above code and added the following for Bug 8400140

      open c_ja_in_rcv_trx(r_po_rcpt.cdl_system_reference4);
      fetch c_ja_in_rcv_trx into r_ja_in_deliver_trx;
      close c_ja_in_rcv_trx;

      FOR rec_get_non_rec_taxes IN c_get_non_rec_taxes(r_ja_in_deliver_trx.tax_transaction_id,
                                                       r_ja_in_deliver_trx.cenvat_costed_flag,--Modified by Bo Li for bug9305067 replace the attribute2 with cenvat_costed_flag
                                                       nvl(r_po_rcpt.receipt_exchange_rate,1))
      LOOP
        open c_ja_in_rcv_trx(r_ja_in_deliver_trx.tax_transaction_id);
        fetch c_ja_in_rcv_trx into r_ja_in_receive_trx;
        close c_ja_in_rcv_trx;

        /* Cases to be taken care
           1. Non bonded delivery -- Implemented in the SELECT query for amounts itself using attribute2 of DELIVER transaction
           2. UOM Conversion
           3. Quantity change between receive and deliver  -- Implemented with below apportion code
        */
        if r_po_rcpt.quantity is not null
          and r_po_rcpt.quantity <> 0
          and r_ja_in_receive_trx.quantity is not null
          and r_ja_in_receive_trx.quantity <> 0
          and r_ja_in_receive_trx.quantity <> r_po_rcpt.quantity
        then
          /*Bug 8660365 - Replaced r_po_rcpt.quantity with r_ja_in_deliver_trx.quantity as Projects update amounts in Quantity in R12*/
          ln_apportion_factor := r_ja_in_deliver_trx.quantity / r_ja_in_receive_trx.quantity;
        else
          ln_apportion_factor := 1;
        end if;

        ln_apportioned_func_tax_amt := rec_get_non_rec_taxes.functional_tax_amount * ln_apportion_factor;
        ln_apportioned_txn_tax_amt  := rec_get_non_rec_taxes.transaction_tax_amount * ln_apportion_factor;

        IF nvl(ln_apportioned_txn_tax_amt,0) <> 0 THEN

        -- Bug 8400140 - End

          INSERT INTO pa_transaction_interface_all(
          TRANSACTION_SOURCE           ,
          BATCH_NAME                   ,
          EXPENDITURE_ENDING_DATE      ,
          EMPLOYEE_NUMBER              ,
          ORGANIZATION_NAME            ,
          EXPENDITURE_ITEM_DATE        ,
          PROJECT_NUMBER               ,
          TASK_NUMBER                  ,
          EXPENDITURE_TYPE             ,
          NON_LABOR_RESOURCE           ,
          NON_LABOR_RESOURCE_ORG_NAME  ,
          QUANTITY                     ,
          RAW_COST                     ,
          EXPENDITURE_COMMENT          ,
          TRANSACTION_STATUS_CODE      ,
          TRANSACTION_REJECTION_CODE   ,
          EXPENDITURE_ID               ,
          ORIG_TRANSACTION_REFERENCE   ,
          ATTRIBUTE_CATEGORY           ,
          ATTRIBUTE1                   ,
          ATTRIBUTE2                   ,
          ATTRIBUTE3                   ,
          ATTRIBUTE4                   ,
          ATTRIBUTE5                   ,
          ATTRIBUTE6                   ,
          ATTRIBUTE7                   ,
          ATTRIBUTE8                   ,
          ATTRIBUTE9                   ,
          ATTRIBUTE10                  ,
          RAW_COST_RATE                ,
          INTERFACE_ID                 ,
          UNMATCHED_NEGATIVE_TXN_FLAG  ,
          EXPENDITURE_ITEM_ID          ,
          ORG_ID                       ,
          DR_CODE_COMBINATION_ID       ,
          CR_CODE_COMBINATION_ID       ,
          CDL_SYSTEM_REFERENCE1        ,
          CDL_SYSTEM_REFERENCE2        ,
          CDL_SYSTEM_REFERENCE3        ,
          GL_DATE                      ,
          BURDENED_COST                ,
          BURDENED_COST_RATE           ,
          SYSTEM_LINKAGE               ,
          TXN_INTERFACE_ID             ,
          USER_TRANSACTION_SOURCE      ,
          CREATED_BY                   ,
          CREATION_DATE                ,
          LAST_UPDATED_BY              ,
          LAST_UPDATE_DATE             ,
          RECEIPT_CURRENCY_AMOUNT      ,
          RECEIPT_CURRENCY_CODE        ,
          RECEIPT_EXCHANGE_RATE        ,
          DENOM_CURRENCY_CODE          ,
          DENOM_RAW_COST               ,
          DENOM_BURDENED_COST          ,
          ACCT_RATE_DATE               ,
          ACCT_RATE_TYPE               ,
          ACCT_EXCHANGE_RATE           ,
          ACCT_RAW_COST                ,
          ACCT_BURDENED_COST           ,
          ACCT_EXCHANGE_ROUNDING_LIMIT ,
          PROJECT_CURRENCY_CODE        ,
          PROJECT_RATE_DATE            ,
          PROJECT_RATE_TYPE            ,
          PROJECT_EXCHANGE_RATE        ,
          ORIG_EXP_TXN_REFERENCE1      ,
          ORIG_EXP_TXN_REFERENCE2      ,
          ORIG_EXP_TXN_REFERENCE3      ,
          ORIG_USER_EXP_TXN_REFERENCE  ,
          VENDOR_NUMBER                ,
          OVERRIDE_TO_ORGANIZATION_NAME,
          REVERSED_ORIG_TXN_REFERENCE  ,
          BILLABLE_FLAG                ,
          PERSON_BUSINESS_GROUP_NAME   ,
          PROJFUNC_CURRENCY_CODE       ,
          PROJFUNC_COST_RATE_TYPE      ,
          PROJFUNC_COST_RATE_DATE      ,
          PROJFUNC_COST_EXCHANGE_RATE  ,
          PROJECT_RAW_COST             ,
          PROJECT_BURDENED_COST        ,
          ASSIGNMENT_NAME              ,
          WORK_TYPE_NAME               ,
          CDL_SYSTEM_REFERENCE4        ,
          ACCRUAL_FLAG                 ,
          PROJECT_ID                   ,
          TASK_ID                      ,
          PERSON_ID                    ,
          ORGANIZATION_ID              ,
          NON_LABOR_RESOURCE_ORG_ID    ,
          VENDOR_ID                    ,
          OVERRIDE_TO_ORGANIZATION_ID  ,
          ASSIGNMENT_ID                ,
          WORK_TYPE_ID                 ,
          PERSON_BUSINESS_GROUP_ID     ,
          INVENTORY_ITEM_ID            ,
          WIP_RESOURCE_ID              ,
          UNIT_OF_MEASURE
          ) VALUES (
          r_po_rcpt.TRANSACTION_SOURCE           , -- 'PO RECEIPT NRTAX', --
          r_po_rcpt.BATCH_NAME                   ,
          r_po_rcpt.EXPENDITURE_ENDING_DATE      ,
          r_po_rcpt.EMPLOYEE_NUMBER              ,
          r_po_rcpt.ORGANIZATION_NAME            ,
          r_po_rcpt.EXPENDITURE_ITEM_DATE        ,
          r_po_rcpt.PROJECT_NUMBER               ,
          r_po_rcpt.TASK_NUMBER                  ,
          r_po_rcpt.EXPENDITURE_TYPE             ,
          r_po_rcpt.NON_LABOR_RESOURCE           ,
          r_po_rcpt.NON_LABOR_RESOURCE_ORG_NAME  ,
          0                                      , /*Bug 8623928 - Quantity must be zero for Tax Lines*/
          decode(r_po_rcpt.RAW_COST, null, null, nvl(ln_apportioned_txn_tax_amt,0)),
          r_po_rcpt.EXPENDITURE_COMMENT          ,
          r_po_rcpt.TRANSACTION_STATUS_CODE      ,
          r_po_rcpt.TRANSACTION_REJECTION_CODE   ,
          r_po_rcpt.EXPENDITURE_ID               ,
          r_po_rcpt.ORIG_TRANSACTION_REFERENCE   ,
          r_po_rcpt.ATTRIBUTE_CATEGORY           ,
          r_po_rcpt.ATTRIBUTE1                   ,
          r_po_rcpt.ATTRIBUTE2                   ,
          r_po_rcpt.ATTRIBUTE3                   ,
          r_po_rcpt.ATTRIBUTE4                   ,
          r_po_rcpt.ATTRIBUTE5                   ,
          r_po_rcpt.ATTRIBUTE6                   ,
          r_po_rcpt.ATTRIBUTE7                   ,
          r_po_rcpt.ATTRIBUTE8                   ,
          r_po_rcpt.ATTRIBUTE9                   ,
          'INDIA LOCALIZATION'                   , -- r_po_rcpt.ATTRIBUTE10                  ,
          r_po_rcpt.RAW_COST_RATE                ,
          r_po_rcpt.INTERFACE_ID                 ,
          r_po_rcpt.UNMATCHED_NEGATIVE_TXN_FLAG  ,
          r_po_rcpt.EXPENDITURE_ITEM_ID          ,
          r_po_rcpt.ORG_ID                       ,
          r_po_rcpt.DR_CODE_COMBINATION_ID       ,
          r_po_rcpt.CR_CODE_COMBINATION_ID       ,
          rec_get_non_rec_taxes.vendor_id , /*Added by nprashar for bug # 8563187, replaced this value r_po_rcpt.CDL_SYSTEM_REFERENCE1 by Vendor_id*/
          r_po_rcpt.CDL_SYSTEM_REFERENCE2        ,
          r_po_rcpt.CDL_SYSTEM_REFERENCE3        ,
          r_po_rcpt.GL_DATE                      ,
          r_po_rcpt.BURDENED_COST                ,
          r_po_rcpt.BURDENED_COST_RATE           ,
          r_po_rcpt.SYSTEM_LINKAGE               ,
               pa_txn_interface_s.nextval              ,
          r_po_rcpt.USER_TRANSACTION_SOURCE      ,
          r_po_rcpt.CREATED_BY                   ,
          r_po_rcpt.CREATION_DATE                ,
          r_po_rcpt.LAST_UPDATED_BY              ,
          r_po_rcpt.LAST_UPDATE_DATE             ,
          r_po_rcpt.RECEIPT_CURRENCY_AMOUNT      ,
          r_po_rcpt.RECEIPT_CURRENCY_CODE        ,
          r_po_rcpt.RECEIPT_EXCHANGE_RATE        ,
          r_po_rcpt.DENOM_CURRENCY_CODE          ,
          decode(r_po_rcpt.DENOM_RAW_COST, null,null, nvl(ln_apportioned_txn_tax_amt,0)),
          r_po_rcpt.DENOM_BURDENED_COST          ,
          r_po_rcpt.ACCT_RATE_DATE               ,
          r_po_rcpt.ACCT_RATE_TYPE               ,
          r_po_rcpt.ACCT_EXCHANGE_RATE           ,
          decode(r_po_rcpt.ACCT_RAW_COST,null, null, nvl(ln_apportioned_func_tax_amt,0))                ,
          r_po_rcpt.ACCT_BURDENED_COST           ,
          r_po_rcpt.ACCT_EXCHANGE_ROUNDING_LIMIT ,
          r_po_rcpt.PROJECT_CURRENCY_CODE        ,
          r_po_rcpt.PROJECT_RATE_DATE            ,
          r_po_rcpt.PROJECT_RATE_TYPE            ,
          r_po_rcpt.PROJECT_EXCHANGE_RATE        ,
          r_po_rcpt.ORIG_EXP_TXN_REFERENCE1      ,
          r_po_rcpt.ORIG_EXP_TXN_REFERENCE2      ,
          r_po_rcpt.ORIG_EXP_TXN_REFERENCE3      ,
          r_po_rcpt.ORIG_USER_EXP_TXN_REFERENCE  ,
          r_po_rcpt.VENDOR_NUMBER                ,
          r_po_rcpt.OVERRIDE_TO_ORGANIZATION_NAME,
          r_po_rcpt.REVERSED_ORIG_TXN_REFERENCE  ,
          r_po_rcpt.BILLABLE_FLAG                ,
          r_po_rcpt.PERSON_BUSINESS_GROUP_NAME   ,
          r_po_rcpt.PROJFUNC_CURRENCY_CODE       ,
          r_po_rcpt.PROJFUNC_COST_RATE_TYPE      ,
          r_po_rcpt.PROJFUNC_COST_RATE_DATE      ,
          r_po_rcpt.PROJFUNC_COST_EXCHANGE_RATE  ,
          r_po_rcpt.PROJECT_RAW_COST             ,
          r_po_rcpt.PROJECT_BURDENED_COST        ,
          r_po_rcpt.ASSIGNMENT_NAME              ,
          r_po_rcpt.WORK_TYPE_NAME               ,
          r_po_rcpt.CDL_SYSTEM_REFERENCE4        ,
          r_po_rcpt.ACCRUAL_FLAG                 ,
          r_po_rcpt.PROJECT_ID                   ,
          r_po_rcpt.TASK_ID                      ,
          r_po_rcpt.PERSON_ID                    ,
          r_po_rcpt.ORGANIZATION_ID              ,
          r_po_rcpt.NON_LABOR_RESOURCE_ORG_ID    ,
          rec_get_non_rec_taxes.vendor_id , /*Added by nprashar for bug # 8563187, Referring vendor id from table ja_in_receipt_tax_lines r_po_rcpt.VENDOR_ID */
           r_po_rcpt.OVERRIDE_TO_ORGANIZATION_ID  ,
          r_po_rcpt.ASSIGNMENT_ID                ,
          r_po_rcpt.WORK_TYPE_ID                 ,
          r_po_rcpt.PERSON_BUSINESS_GROUP_ID     ,
          r_po_rcpt.INVENTORY_ITEM_ID            ,
          r_po_rcpt.WIP_RESOURCE_ID              ,
          r_po_rcpt.UNIT_OF_MEASURE
          );

        END IF;  -- Added for Bug 8400140

      jai_cmn_debug_contexts_pkg.print
                         ( ln_reg_id
                         , 'Number of rows updated='||sql%rowcount
                         );

      END LOOP;  -- Added for Bug 8400140
    end loop;

    /** Deregister procedure and return*/
    <<deregister_and_return>>
    jai_cmn_debug_contexts_pkg.deregister (pn_reg_id => ln_reg_id);

  exception
    when others then
      p_process_flag    := jai_constants.UNEXPECTED_ERROR;
    p_process_message := sqlerrm;
      jai_cmn_debug_contexts_pkg.print(ln_reg_id,lv_context||'->'||sqlerrm,jai_cmn_debug_contexts_pkg.summary);
      jai_cmn_debug_contexts_pkg.print_stack;

  end update_interface_costs;

end jai_pa_costing_pkg;

/
