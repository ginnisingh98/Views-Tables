--------------------------------------------------------
--  DDL for Package Body JAI_RGM_THHOLD_PROC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_RGM_THHOLD_PROC_PKG" AS
/*$Header: jai_rgm_thld_prc.plb 120.4.12000000.1 2007/07/24 06:56:10 rallamse noship $ */

/* ----------------------------------------------------------------------------

   CHANGE HISTORY:
	 -------------------------------------------------------------------------------
	 S.No      Date         Author and Details
	 -------------------------------------------------------------------------------
	  1.       01/02/2007    Created by Bgowrava for forward porting bug#5631784. Version#120.0.
	                        This was Directly created from 11i version 115.9

	  2.       16/04/2007   Bgowrava for Forwrad porting Bug#5989740, 11i bug#5907436, version 120.1
		  		                ENH : HANDLING SECONDARY AND HIGHER EDUCATION CESS
		            					additional cess of 1% on all taxes to be levied to fund secondary education and higher
					                education .
				                  Changes - -
				                  Changes is done to capture Secondary and Higher cess .
			                    Most of places , we added secondary cess with normal cess

	3	18/06/2007	bduvarag for the bug#6127213, File version of 120.3
				FP of 6084533
		4.			 28/06/2007		CSahoo for BUG#6156619, File Version 120.4
													added a AND condition in the cursor c_get_cust_typ_lkup_code.
    ---------------------------------------------------------------------------- */

  /*----------------------------------------- PRIVATE MEMBERS DECLRATION -------------------------------------*/

      /** Package level variables used in debug package*/
      lv_object_name  jai_cmn_debug_contexts.log_context%type default 'TCS.JAI_RGM_THHOLD_PROC_PKG';
      lv_member_name  jai_cmn_debug_contexts.log_context%type;
      lv_context      jai_cmn_debug_contexts.log_context%type;

  procedure set_debug_context
  is

  begin
    lv_context  := rtrim(lv_object_name || '.'||lv_member_name,'.');
  end set_debug_context;
  /*------------------------------------------END - PRIVATE MEMBERS DECLRATION --------------------------------*/
  procedure generate_consolidated_doc
                                (p_threshold_id        in           jai_rgm_thresholds.threshold_id%type
                                ,p_transaction_id      in           jai_rgm_refs_all.transaction_id%type
                                ,p_org_id              in           jai_rgm_refs_all.org_id%type
                                ,p_process_flag        out nocopy   varchar2
                                ,p_process_message     out nocopy   varchar2
                                )
  is

    /*-------------------------------DECLARE SECTION OF GENERATE_CONSOLIDATED_DOC ---------------------------*/

    ln_reg_id                   number;
    lr_dtl_record               jai_rgm_threshold_dtls%rowtype;
    ln_threshold_slab_id        jai_rgm_thresholds.threshold_slab_id%type;
    ln_threshold_tax_cat_id     jai_ap_tds_thhold_taxes.tax_category_id%type;

    ln_surcharge_doc_amt        number;
    ln_surcharge_doc_cess_amt   number;
    ln_surcharge_line_no        number;
    ln_surcharge_cess_line_no   number;
    ln_surcharge_tax_id         jai_rgm_taxes.tax_id%type;
    ln_surcharge_cess_tax_id    jai_rgm_taxes.tax_id%type;
    ln_surcharge_tax_rate       jai_rgm_taxes.tax_rate%type;
    ln_surcharge_cess_tax_rate  jai_rgm_taxes.tax_rate%type;

    ln_trx_ref_id               jai_rgm_refs_all.trx_ref_id%type;
    ln_currency_code            jai_rgm_taxes.currency_code%type;

    ln_user_id                  fnd_user.user_id%type   :=  fnd_global.user_id;
    ln_login_id                 fnd_logins.login_id%type :=  fnd_global.login_id;

    -- start, Bgowrava for Forward porting Bug#5989740
		    ln_surcharge_sh_cess_tax_id    jai_rgm_taxes.tax_id%type;
		    ln_surcharge_sh_cess_tax_rate  jai_rgm_taxes.tax_rate%type;
		    ln_surcharge_sh_cess_line_no   number;
		    ln_surcharge_doc_sh_cess_amt   number;
		-- end Bgowrava for Forward porting Bug#5989740


    cursor c_get_thhold_info
    is
    select hdr.regime_id
          ,hdr.threshold_slab_id
          ,dtls.threshold_dtl_id
          ,dtls.threshold_base_amt
          ,dtls.item_classification
          ,nvl(dtls.manual_surcharge_amt,0) manual_surcharge_amt
          ,nvl(dtls.system_surcharge_amt,0) system_surcharge_amt
          ,nvl(dtls.system_surcharge_cess_amt,0) system_surcharge_cess_amt
          ,nvl(dtls.system_surcharge_sh_cess_amt,0) system_surcharge_sh_cess_amt --Bgowrava for forward porting bug#5989740
    from   jai_rgm_threshold_dtls dtls
          ,jai_rgm_thresholds hdr
    where  hdr.threshold_id   = p_threshold_id
    and    dtls.threshold_id   = hdr.threshold_id ;

    cursor c_curr_code (cp_org_id   jai_rgm_refs_all.org_id%type)
      is
      select currency_code
      from    gl_sets_of_books gsb
            , hr_operating_units hou
      where  gsb.set_of_books_id = hou.set_of_books_id
      and    hou.organization_id = cp_org_id;

      cursor c_get_ref_dtls (cp_transaction_id  jai_rgm_refs_all.transaction_id%type default null
                            ,cp_trx_ref_id      jai_rgm_refs_all.trx_ref_id%type default null
                            )
      is
        select *
        from   jai_rgm_refs_all
        where  (  (cp_transaction_id is not null and transaction_id = cp_transaction_id)
              or  (cp_trx_ref_id     is not null and trx_ref_id = cp_trx_ref_id)
               );

      cursor c_get_taxes_for_last_doc ( cp_org_tan_no    jai_rgm_refs_all.org_tan_no%type
                                      , cp_party_id      jai_rgm_refs_all.party_id%type
                                      , cp_fin_year            jai_rgm_refs_all.fin_year%type
                                      , cp_item_classification   jai_rgm_refs_all.item_classification%type
                                      )
      is
        select tax_id
              ,tax_type
              ,tax_rate
        from  jai_rgm_taxes
        where trx_ref_id = ( select max(trx_ref_id)
                             from   jai_rgm_refs_all
                             where  source_document_id  =  jai_constants.tcs_surcharge_id
                             and    org_tan_no          = cp_org_tan_no
                             and    fin_year            = cp_fin_year
                             and    party_id            = cp_party_id
                             and    item_classification = cp_item_classification
                             and    party_type          = jai_constants.party_type_customer
                            );


     r_ref_dtls             c_get_ref_dtls%rowtype;
     ln_transaction_id      JAI_RGM_REFS_ALL.TRANSACTION_ID%TYPE;

     /*
     || Generate the transaction_id from the sequence
     */
     CURSOR cur_get_transaction_id
     IS
     SELECT
             jai_rgm_refs_all_s2.nextval
     FROM
             dual;


    /*-------------------------------BEGIN LOCAL METHOD CALCULATE_TCS_DOC_AMOUNT  -----------------------------*/

    procedure calculate_tcs_doc_amount
                    ( p_threshold_tax_cat_id        in          jai_ap_tds_thhold_taxes.tax_category_id%type
                    , p_tcs_amt                     in          number
                    , p_manual_surcharge_amt        in          jai_rgm_threshold_dtls.manual_surcharge_amt%type
                    , p_system_surcharge_amt        in          jai_rgm_threshold_dtls.system_surcharge_amt%type
                    , p_system_surcharge_cess_amt   in          jai_rgm_threshold_dtls.system_surcharge_cess_amt%type
                    , p_system_surcharge_sh_cess_amt   in          jai_rgm_threshold_dtls.system_surcharge_sh_cess_amt%type --Bgowrava for forward porting bug#5989740
                    , p_surcharge_doc_amt           out nocopy  number
                    , p_surcharge_doc_cess_amt      out nocopy  number
                    , p_surcharge_doc_sh_cess_amt   out nocopy  number --Bgowrava for forward porting bug#5989740
                    , p_process_flag                out nocopy  varchar2
                    , p_process_message             out nocopy  varchar2
                    )
    is

      ln_tax_rate                 JAI_CMN_TAXES_ALL.tax_rate%type;
      ln_rounding_factor          JAI_CMN_TAXES_ALL.rounding_factor%type;
      ln_tax_id                   JAI_CMN_TAXES_ALL.tax_id%type;

      cursor c_get_surcharge_taxes (cp_tax_type   JAI_CMN_TAXES_ALL.tax_type%type
                                   ,cp_line_no    number default null
                                   )
      is
        select  tax.tax_rate
              , tax.rounding_factor
              , tax.tax_id
              , cat.line_no
        from   JAI_CMN_TAXES_ALL tax
              ,JAI_CMN_TAX_CTG_LINES cat
        where  cat.tax_id = tax.tax_id
        and    cat.tax_category_id = p_threshold_tax_cat_id
        and    tax.tax_type = cp_tax_type
        and    cat.precedence_1 = nvl(cp_line_no, cat.precedence_1);     -- This will check that for CESS precedence should be of surcharge

    begin

      p_process_flag     := jai_constants.successful;
      p_process_message  := null;

  /*    jai_cmn_debug_contexts_pkg.print ( ln_reg_id,'Begin CALCULATE_TCS_DOC_AMOUNT');
      jai_cmn_debug_contexts_pkg.print ( ln_reg_id
                              ,'p_threshold_tax_cat_id        ='||p_threshold_tax_cat_id
                             ||'p_tcs_amt                     ='||p_tcs_amt
                             ||'p_manual_surcharge_amt        ='||p_manual_surcharge_amt
                             ||'p_system_surcharge_amt        ='||p_system_surcharge_amt
                             ||'p_system_surcharge_cess_amt   ='||p_system_surcharge_cess_amt
                             );*/ --commented by bgowrava for bug#5631784

      p_surcharge_doc_amt       := 0;
      p_surcharge_doc_cess_amt  := 0;

      if p_threshold_tax_cat_id = -1 then

        /*
          No slab is applicable and hence no surcharge needs to be paid.
          All system generated  surcharge / cess needs to be reversed
        */

        p_surcharge_doc_amt       := -1 * p_system_surcharge_amt;
        p_surcharge_doc_cess_amt  := -1 * p_system_surcharge_cess_amt;
        return;

      end if;

      /*
          Get details regarding surcharge type of tax attached to the category.
      */
   /*   jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Open/Fetch/Close C_GET_SURCHARGE_TAXES'); */ --commented by bgowrava for bug#5631784
      open  c_get_surcharge_taxes (cp_tax_type => jai_constants.tax_type_tcs_surcharge );
      fetch c_get_surcharge_taxes into ln_tax_rate
                                      ,ln_rounding_factor
                                      ,ln_surcharge_tax_id
                                      ,ln_surcharge_line_no;
      close c_get_surcharge_taxes ;

      if ln_tax_rate is null then
        p_process_flag    :=  jai_constants.expected_error;
        p_process_message :=  'Cannot find surcharge type of taxes for tax_id ='||ln_tax_id||', tax_category_id='||p_threshold_tax_cat_id;
        return;
      end if;


      ln_rounding_factor    := nvl(ln_rounding_factor,0);
      ln_surcharge_tax_rate := ln_tax_rate;

  /*    jai_cmn_debug_contexts_pkg.print (ln_reg_id
                                   ,'ln_surcharge_line_no='||ln_surcharge_line_no||'
                                     , ln_surcharge_tax_rate='||ln_surcharge_tax_rate||'
                                     , ln_rounding_factor='||ln_rounding_factor
                                   );			*/ --commented by bgowrava for bug#5631784

      /*
        Calculate surcharge amount by using following equation
        ----------------------------------------------------------------
        Surcharge      =  TCS Amount * Tax Rate (Surcharge type of tax)
        ----------------------------------------------------------------
      */

      p_surcharge_doc_amt  :=  round( p_tcs_amt * (ln_tax_rate/100), ln_rounding_factor);

      /*
        Document amount may be different from surcharge amount because of either system deducted surcharge
        or manually deducated surcharge.  Document amount is calculated using following equation

        ------------------------------------------------------------------------------------------------------------------
        Document Amount = (SurchargeAmount [What needs to be paid]) - (System+Manual Surcharge) [What is already deducted])
        ------------------------------------------------------------------------------------------------------------------

        In case if document amount is less than surcharge amount we should reverse deduction amounts

        Assumption:  We can only reverse system surcharge amount and we should never reverse manual surcharge
      */

      p_surcharge_doc_amt     := p_surcharge_doc_amt - (p_system_surcharge_amt + p_manual_surcharge_amt);

  /*    jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'p_surcharge_doc_amt='||p_surcharge_doc_amt);*/ --commented by bgowrava for bug#5631784

      if p_surcharge_doc_amt < 0 then
        /* Document amount is negative means we need to initiate reversal (only for system surcharge amount). */

        if (p_system_surcharge_amt + p_surcharge_doc_amt ) >= 0 then
          /* System surcharge has potential for reversal */
          p_surcharge_doc_amt := p_system_surcharge_amt + p_surcharge_doc_amt ;
        else
          /* System surcharge is not sufficient to reverse the complete document amount hence reverse only whatever is system surcharge amount */
          p_surcharge_doc_amt := -1 * p_system_surcharge_amt ;
        end if;
      end if;

      /*
        Get details regarding surcharge cess type of taxes
      */
      ln_tax_rate        := null;
      ln_rounding_factor := null;

      /*
      ||  Get tax details for CESS which is defined for Surcharge
      */
  /*    jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Open/Fetch/Close C_GET_SURCHARGE_TAXES'); */ --commented by bgowrava for bug#5631784
      open  c_get_surcharge_taxes (cp_tax_type => jai_constants.tax_type_tcs_cess
                                  ,cp_line_no  => ln_surcharge_line_no
                                  );
      fetch c_get_surcharge_taxes into ln_tax_rate
                                      ,ln_rounding_factor
                                      ,ln_surcharge_cess_tax_id
                                      ,ln_surcharge_cess_line_no;
      close c_get_surcharge_taxes ;

      if ln_tax_rate is null then
        ln_tax_rate := 0;
 /*       jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Surcharge Cess is not available, continuing with zero cess');*/ --commented by bgowrava for bug#5631784
      end if;

      ln_rounding_factor := nvl(ln_rounding_factor,0);
      ln_surcharge_cess_tax_rate := ln_tax_rate;

   /*   jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'ln_surcharge_cess_tax_rate='||ln_surcharge_cess_tax_rate||', ln_rounding_factor='||ln_rounding_factor);*/ --commented by bgowrava for bug#5631784

      /*
        Calculate document cess amount by using following equation
        ------------------------------------------------------------------------------
        Cess on Doc.Amount  =  Document Amount * Tax Rate (Surcharge Cess type of tax)
        ------------------------------------------------------------------------------
      */
      p_surcharge_doc_cess_amt  :=  round( p_surcharge_doc_amt * (ln_tax_rate/100), ln_rounding_factor);

      -- start,	Bgowrava for forward porting bug#5989740

			  ln_tax_rate        := null;
			  ln_rounding_factor := null;

			  open  c_get_surcharge_taxes (cp_tax_type => jai_constants.tax_type_sh_tcs_edu_cess
			                              ,cp_line_no  => ln_surcharge_line_no
			                              );
			  fetch c_get_surcharge_taxes into ln_tax_rate
			                                  ,ln_rounding_factor
			                                  ,ln_surcharge_sh_cess_tax_id
			                                  ,ln_surcharge_sh_cess_line_no;
			  close c_get_surcharge_taxes ;

			  if ln_tax_rate is null then
			    ln_tax_rate := 0;
			  end if;
			  ln_rounding_factor := nvl(ln_rounding_factor,0);
			  ln_surcharge_sh_cess_tax_rate := ln_tax_rate;

			  p_surcharge_doc_sh_cess_amt  :=  round( p_surcharge_doc_amt * (ln_tax_rate/100), ln_rounding_factor);

			-- end Bgowrava for forward porting bug#5989740



  /*    jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'p_surcharge_doc_amt='||p_surcharge_doc_amt);
      jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'p_surcharge_doc_cess_amt='||p_surcharge_doc_cess_amt);		*/--commented by bgowrava for bug#5631784

    end calculate_tcs_doc_amount;

    /*-------------------------------END LOCAL METHOD CALCULATE_TCS_DOC_AMOUNT  -----------------------------*/

  /*------------------------------------ BEGIN GENERATE_CONSOLIDATED_DOC ------------------------------------*/
  begin

    /*----------------------------------------------------------------------
        Aim:  Calculate Surcharge Amount and Generate a Consolidated Document
    ------------------------------------------------------------------------*/

    /** Initialize process variables */
    p_process_flag    := jai_constants.successful;
    p_process_message := null;

    /** Register procedure for debuging */
    lv_member_name        := 'GENERATE_CONSOLIDATED_DOC';
    set_debug_context;
    /*jai_cmn_debug_contexts_pkg.register ( pv_context => lv_context
                               , pn_reg_id  => ln_reg_id
                               );	 */

 /*   jai_cmn_debug_contexts_pkg.print ( ln_reg_id
                            ,'GENERATE_CONSOLIDATED_DOC Call Parameters:'
                             ||'p_threshold_id='||p_threshold_id
                             ||'p_org_id='||p_org_id
                            ,jai_cmn_debug_contexts_pkg.summary
                            );			 */ --commented by bgowrava for bug#5631784

    /**  For TCS, Surcharge document needs to be generated for each of the item classification */
    for r_thhold_info in c_get_thhold_info
    loop
      if r_thhold_info.threshold_slab_id is null then
        /**
            THRESHOLD_SLAB_ID is null means, no surcharge slab is applicable. Hence any amount in system surcharge
            must be reverted by generating a credit memo.
        */
        /*
          Setting threshold_tax_cat_id to a value which never exists, so calculate_tcs_doc_amount (see below) will be able to process
          reversal for system surcharge / cess amount
        */
        ln_threshold_tax_cat_id := -1;
      end if;

      /**
        if this is the first iteration, get tax category for the slab .  In other way if we already have tax_category_id (say -1) don't
        even make a call to get_threshold_tax_cat_id API
       */
      jai_cmn_debug_contexts_pkg.print ( ln_reg_id, 'Before: JAI_RGM_THHOLD_PROC_PKG.GET_THRESHOLD_TAX_CAT_ID');

      if ln_threshold_tax_cat_id is null then
        /** Control will never come here if THRESHOLD_SLAB_ID is null (i.e. if no slab is applicable) */
        jai_rgm_thhold_proc_pkg.get_threshold_tax_cat_id
                                ( p_threshold_slab_id     =>    r_thhold_info.threshold_slab_id
                                , p_org_id                =>    p_org_id
                                , p_threshold_tax_cat_id 	=>    ln_threshold_tax_cat_id
                                , p_process_flag          =>    p_process_flag
                                , p_process_message       =>    p_process_message
                                );

      end if;

  /*    jai_cmn_debug_contexts_pkg.print ( ln_reg_id, 'After: JAI_RGM_THHOLD_PROC_PKG.GET_THRESHOLD_TAX_CAT_ID');
      jai_cmn_debug_contexts_pkg.print ( ln_reg_id, 'p_process_flag='||p_process_flag||', p_process_message='||p_process_message); */ --commented by bgowrava for bug#5631784

      if p_process_flag <> jai_constants.successful then
        return;
      end if;

  /*    jai_cmn_debug_contexts_pkg.print ( ln_reg_id, 'Before: CALCULATE_TCS_DOC_AMOUNT');*/ --commented by bgowrava for bug#5631784
      calculate_tcs_doc_amount ( p_threshold_tax_cat_id       =>    ln_threshold_tax_cat_id
                               , p_tcs_amt                    =>    r_thhold_info.threshold_base_amt
                               , p_manual_surcharge_amt       =>    r_thhold_info.manual_surcharge_amt
                               , p_system_surcharge_amt       =>    r_thhold_info.system_surcharge_amt
                               , p_system_surcharge_cess_amt  =>    r_thhold_info.system_surcharge_cess_amt
                               , p_system_surcharge_sh_cess_amt  =>    r_thhold_info.system_surcharge_sh_cess_amt --Bgowrava for forward porting bug#5989740
                               , p_surcharge_doc_amt          =>    ln_surcharge_doc_amt
                               , p_surcharge_doc_cess_amt     =>    ln_surcharge_doc_cess_amt
                               , p_surcharge_doc_sh_cess_amt     =>    ln_surcharge_doc_sh_cess_amt --Bgowrava for forward porting bug#5989740
                               , p_process_flag               =>    p_process_flag
                               , p_process_message            =>    p_process_message
                               );
     /* jai_cmn_debug_contexts_pkg.print ( ln_reg_id, 'After: CALCULATE_TCS_DOC_AMOUNT');
      jai_cmn_debug_contexts_pkg.print ( ln_reg_id, 'p_process_flag='||p_process_flag||', p_process_message='||p_process_message); */ --commented by bgowrava for bug#5631784

      if p_process_flag <> jai_constants.successful then
        return;
      end if;

      /*
      --  Check if document amount is not zero.  If it is zero, no need to generate document and hence no need create repository references
      */

      if (ln_surcharge_doc_amt + ln_surcharge_doc_cess_amt + ln_surcharge_doc_sh_cess_amt) = 0 then			-- Added ln_surcharge_doc_sh_cess_amt, Bgowrava for forward porting bug#5989740
        goto update_and_return;
      end if;

      /*
        If threshold is down we will not be able to get tax category and hence tax details, so we should look at the last consolidated document and
        to find out the tax structure
      */

      open  c_get_ref_dtls (cp_transaction_id => p_transaction_id);
      fetch c_get_ref_dtls  into r_ref_dtls;
      close c_get_ref_dtls;


      if r_thhold_info.threshold_slab_id is null then
  /*      jai_cmn_debug_contexts_pkg.print ( ln_reg_id
                                         , 'For loop of C_GET_TAXES_FOR_LAST_DOC'||chr(10)||
                                           'cp_org_tan_no= '||r_ref_dtls.org_tan_no||chr(10)||
                                           'cp_party_id  = '||r_ref_dtls.party_id  ||chr(10)||
                                           'cp_fin_year  = '||r_ref_dtls.fin_year  ||chr(10)||
                                           'cp_item_classification= '||r_ref_dtls.item_classification||chr(10)||
                                           'jai_constants.tcs_surcharge_id='||jai_constants.tcs_surcharge_id||chr(10)||
                                           'jai_constants.party_type_customer='||jai_constants.party_type_customer
                                         );			*/ --commented by bgowrava for bug#5631784

        for r_taxes_for_last_doc in  c_get_taxes_for_last_doc
                                      ( cp_org_tan_no => r_ref_dtls.org_tan_no
                                       ,cp_party_id   => r_ref_dtls.party_id
                                       ,cp_fin_year   => r_ref_dtls.fin_year
                                       ,cp_item_classification => r_ref_dtls.item_classification
                                      )
        loop
        /*  jai_cmn_debug_contexts_pkg.print ( ln_reg_id
                                           , 'Inside For: r_taxes_for_last_doc.tax_type='||r_taxes_for_last_doc.tax_type
                                           );			*/ --commented by bgowrava for bug#5631784
          if r_taxes_for_last_doc.tax_type = jai_constants.tax_type_tcs_surcharge then
            ln_surcharge_tax_id   := r_taxes_for_last_doc.tax_id;
            ln_surcharge_tax_rate := r_taxes_for_last_doc.tax_rate;
          elsif r_taxes_for_last_doc.tax_type = jai_constants.tax_type_tcs_cess then
            ln_surcharge_cess_tax_id  := r_taxes_for_last_doc.tax_id;
            ln_surcharge_cess_tax_rate:= r_taxes_for_last_doc.tax_rate;
          -- start Bgowrava for forward porting bug#5989740
          elsif r_taxes_for_last_doc.tax_type = jai_constants.tax_type_sh_tcs_edu_cess then
            ln_surcharge_sh_cess_tax_id  := r_taxes_for_last_doc.tax_id;
            ln_surcharge_sh_cess_tax_rate:= r_taxes_for_last_doc.tax_rate;
          -- end Bgowrava for forward porting bug#5989740
          end if;
        end loop;

        if ln_surcharge_tax_id is null or ln_surcharge_cess_tax_id is null or  ln_surcharge_sh_cess_tax_id is null then --Bgowrava for forward porting bug#5989740
          p_process_flag := jai_constants.expected_error;
          p_process_message := 'Unable to find tax structure to generate a consolidated document, tax_id(SURCH)='||ln_surcharge_tax_id||', tax_id(CESS)='||ln_surcharge_cess_tax_id;
          return;
        end if;
      end if; /*  r_thhold_info.threshold_slab_id is null */

      /*
      ||Get the sequence generated unique key for the transaction
      */
      OPEN  cur_get_transaction_id ;
      FETCH cur_get_transaction_id INTO ln_transaction_id ;
      CLOSE cur_get_transaction_id ;

      /*
      || Insert repository reference for the document to be generated
      */

  /*    jai_cmn_debug_contexts_pkg.print ( ln_reg_id, 'Before: JAI_AR_TCS_REP_PKG.INSERT_REPOSITORY_REFERENCES',jai_cmn_debug_contexts_pkg.summary);*/ --commented by bgowrava for bug#5631784
      jai_ar_tcs_rep_pkg.insert_repository_references
          ( p_regime_id                  =>              r_thhold_info.regime_id
          , p_transaction_id             =>              ln_transaction_id
          , p_source_ref_document_id     =>              r_ref_dtls.source_ref_document_id
          , p_source_ref_document_type   =>              r_ref_dtls.source_ref_document_type
          , p_parent_transaction_id      =>              r_ref_dtls.parent_transaction_id
          , p_org_tan_no                 =>              r_ref_dtls.org_tan_no
          , p_document_id                =>              jai_constants.tcs_surcharge_id
          , p_document_type              =>              jai_constants.tcs_event_surcharge
          , p_document_line_id           =>              jai_constants.tcs_surcharge_id
          , p_document_date              =>              r_ref_dtls.source_document_date
          , p_table_name                 =>              jai_constants.jai_rgm_thresholds
          , p_line_amount                =>              (ln_surcharge_doc_amt + ln_surcharge_doc_cess_amt + ln_surcharge_doc_sh_cess_amt) --Bgowrava for forward porting bug#5989740
          , p_document_amount            =>              (ln_surcharge_doc_amt + ln_surcharge_doc_cess_amt + ln_surcharge_doc_sh_cess_amt) --Bgowrava for forward porting bug#5989740
          , p_org_id                     =>              r_ref_dtls.org_id
          , p_organization_id            =>              r_ref_dtls.organization_id
          , p_party_id                   =>              r_ref_dtls.party_id
          , p_party_site_id              =>              r_ref_dtls.party_site_id
          , p_item_classification        =>              r_thhold_info.item_classification
          , p_trx_ref_id                 =>              ln_trx_ref_id
          , p_process_flag               =>              p_process_flag
          , p_process_message            =>              p_process_message
          );
  /*    jai_cmn_debug_contexts_pkg.print ( ln_reg_id, 'After: JAI_AR_TCS_REP_PKG.INSERT_REPOSITORY_REFERENCES',jai_cmn_debug_contexts_pkg.summary);
      jai_cmn_debug_contexts_pkg.print ( ln_reg_id, 'p_process_flag='||p_process_flag||', p_process_message='||p_process_message,jai_cmn_debug_contexts_pkg.summary);*/ --commented by bgowrava for bug#5631784

      if p_process_flag <> jai_constants.successful then
        return;
      end if;

      open  c_curr_code (cp_org_id => r_ref_dtls.org_id);
      fetch c_curr_code  into ln_currency_code;
      close c_curr_code  ;

      /*
      || Insert repository taxes
      */
      /*
        Insert surcharge type of tax
      */

 /*     jai_cmn_debug_contexts_pkg.print ( ln_reg_id, 'Before Surcharge Tax: JAI_AR_TCS_REP_PKG.INSERT_REPOSITORY_TAXES',jai_cmn_debug_contexts_pkg.summary);*/ --commented by bgowrava for bug#5631784
      jai_ar_tcs_rep_pkg.insert_repository_taxes
        (
           p_trx_ref_id       =>   ln_trx_ref_id
        ,  p_tax_id           =>   ln_surcharge_tax_id
        ,  p_tax_type         =>   jai_constants.tax_type_tcs_surcharge
        ,  p_tax_rate         =>   ln_surcharge_tax_rate
        ,  p_tax_amount       =>   ln_surcharge_doc_amt
        ,  p_func_tax_amount  =>   ln_surcharge_doc_amt /* Functional currency is same as trx currency */
        ,  p_currency_code    =>   ln_currency_code
        ,  p_process_flag     =>   p_process_flag
        ,  p_process_message  =>   p_process_message
        );
  /*     jai_cmn_debug_contexts_pkg.print ( ln_reg_id, 'After Surcharge Tax: JAI_AR_TCS_REP_PKG.INSERT_REPOSITORY_TAXES',jai_cmn_debug_contexts_pkg.summary);
       jai_cmn_debug_contexts_pkg.print ( ln_reg_id, 'p_process_flag='||p_process_flag||', p_process_message='||p_process_message,jai_cmn_debug_contexts_pkg.summary);*/ --commented by bgowrava for bug#5631784

       if p_process_flag <> jai_constants.successful then
        return;
       end if;

  /*    jai_cmn_debug_contexts_pkg.print ( ln_reg_id, 'Before Surcharge Cess : JAI_AR_TCS_REP_PKG.INSERT_REPOSITORY_TAXES',jai_cmn_debug_contexts_pkg.summary);*/ --commented by bgowrava for bug#5631784
       /* Insert surcharge cess type of tax */
      jai_ar_tcs_rep_pkg.insert_repository_taxes
        (
           p_trx_ref_id       =>   ln_trx_ref_id
        ,  p_tax_id           =>   ln_surcharge_cess_tax_id
        ,  p_tax_type         =>   jai_constants.tax_type_tcs_cess
        ,  p_tax_rate         =>   ln_surcharge_cess_tax_rate
        ,  p_tax_amount       =>   ln_surcharge_doc_cess_amt
        ,  p_func_tax_amount  =>   ln_surcharge_doc_cess_amt /* Functional currency is same as trx currency */
        ,  p_currency_code    =>   ln_currency_code
        ,  p_process_flag     =>   p_process_flag
        ,  p_process_message  =>   p_process_message
        );
   /*     jai_cmn_debug_contexts_pkg.print ( ln_reg_id, 'After Surcharge Cess : JAI_AR_TCS_REP_PKG.INSERT_REPOSITORY_TAXES',jai_cmn_debug_contexts_pkg.summary);
        jai_cmn_debug_contexts_pkg.print ( ln_reg_id, 'p_process_flag='||p_process_flag||', p_process_message='||p_process_message,jai_cmn_debug_contexts_pkg.summary);*/ --commented by bgowrava for bug#5631784

       if p_process_flag <> jai_constants.successful then
        return;
       end if;

     -- start Bgowrava for forward porting bug#5989740

		       jai_cmn_debug_contexts_pkg.print ( ln_reg_id, 'Before Secondary and higher Surcharge Cess : JAI_AR_TCS_REP_PKG.INSERT_REPOSITORY_TAXES',jai_cmn_debug_contexts_pkg.summary);
		        /* Insert surcharge cess type of tax */
		       jai_ar_tcs_rep_pkg.insert_repository_taxes
		         (
		            p_trx_ref_id       =>   ln_trx_ref_id
		         ,  p_tax_id           =>   ln_surcharge_cess_tax_id
		         ,  p_tax_type         =>   jai_constants.tax_type_sh_tcs_edu_cess
		         ,  p_tax_rate         =>   ln_surcharge_cess_tax_rate
		         ,  p_tax_amount       =>   ln_surcharge_doc_sh_cess_amt
		         ,  p_func_tax_amount  =>   ln_surcharge_doc_sh_cess_amt /* Functional currency is same as trx currency */
		         ,  p_currency_code    =>   ln_currency_code
		         ,  p_process_flag     =>   p_process_flag
		         ,  p_process_message  =>   p_process_message
		         );
		         jai_cmn_debug_contexts_pkg.print ( ln_reg_id, 'After Surcharge Cess : JAI_AR_TCS_REP_PKG.INSERT_REPOSITORY_TAXES',jai_cmn_debug_contexts_pkg.summary);
		         jai_cmn_debug_contexts_pkg.print ( ln_reg_id, 'p_process_flag='||p_process_flag||', p_process_message='||p_process_message,jai_cmn_debug_contexts_pkg.summary);

		        if p_process_flag <> jai_constants.successful then
		         return;
		        end if;

   -- end Bgowrava for forward porting bug#5989740

      /** Generate document */

   /*     jai_cmn_debug_contexts_pkg.print ( ln_reg_id, 'Before : JAI_AR_TCS_REP_PKG.GENERATE_DOCUMENT',jai_cmn_debug_contexts_pkg.summary);*/ --commented by bgowrava for bug#5631784

        /*
        || Get Repository Reference for consolidated document record inserted above
        */
        open  c_get_ref_dtls (cp_trx_ref_id => ln_trx_ref_id) ;
        fetch c_get_ref_dtls  into r_ref_dtls;
        close c_get_ref_dtls;

        jai_ar_tcs_rep_pkg.generate_document
          (   p_rgm_ref               =>  r_ref_dtls
          ,   p_total_tax_amt         =>  (ln_surcharge_doc_amt + ln_surcharge_doc_cess_amt + ln_surcharge_doc_sh_cess_amt ) --Bgowrava for forward porting bug#5989740
          ,   p_process_flag          =>  p_process_flag
          ,   p_process_message       =>  p_process_message
          );
   /*     jai_cmn_debug_contexts_pkg.print ( ln_reg_id, 'After : JAI_AR_TCS_REP_PKG.GENERATE_DOCUMENT',jai_cmn_debug_contexts_pkg.summary);
        jai_cmn_debug_contexts_pkg.print ( ln_reg_id, 'p_process_flag='||p_process_flag||', p_process_message='||p_process_message,jai_cmn_debug_contexts_pkg.summary);*/ --commented by bgowrava for bug#5631784

        if p_process_flag <> jai_constants.successful then
          return;
        end if;


      /*
      --  This must be the last statement in the loop as update should happen only if all the above processing is completed successfully
      */
      <<update_and_return>>
      /** Update System surcharge/cess amouts */
      update  jai_rgm_threshold_dtls
      set     system_surcharge_amt      =   system_surcharge_amt      + ln_surcharge_doc_amt
      ,       system_surcharge_cess_amt =   system_surcharge_cess_amt + ln_surcharge_doc_cess_amt
      ,       system_surcharge_sh_cess_amt =   system_surcharge_sh_cess_amt + ln_surcharge_doc_sh_cess_amt --Bgowrava for forward porting bug#5989740
      ,       last_update_date          =   sysdate
      ,       last_updated_by           =   ln_user_id
      ,       last_update_login         =   ln_login_id
      where   threshold_dtl_id          =   r_thhold_info.threshold_dtl_id;


    end loop; /** r_thhold_info */

    /** Deregister procedure and return*/
    <<deregister_and_return>>
 /*   jai_cmn_debug_contexts_pkg.deregister (pn_reg_id => ln_reg_id);	  */ --commented by bgowrava for bug#5631784
    return;
  exception
    when others then
      p_process_flag    := jai_constants.unexpected_error;
      p_process_message := lv_context||'->'||sqlerrm;
   /*   jai_cmn_debug_contexts_pkg.print(ln_reg_id,lv_context||'->'||sqlerrm,jai_cmn_debug_contexts_pkg.summary);
      jai_cmn_debug_contexts_pkg.print_stack;*/ -- */ --commented by bgowrava for bug#5631784

  end generate_consolidated_doc ;

  /*------------------------------------------------------------------------------------------------------------*/

  /*---------------------------------------------PUBLIC SECTION-------------------------------------------------*/
  /**
     get_threshold_slab_id - returns identifier for current threshold slab as out parameter
     IN
          p_regime_id         - A valid regime_id from jai_rgm_thresholds.
          p_org_tan_no        - Organiztion TAN as defined in the regime setup
          p_organization_id   - Inventory organization defined in the regime setup
          p_party_type        - Party type.  Can be either CUSTOMER or VENDOR.  Currently only CUSTOMER is valid.
          p_party_id          - Party identifier.
          p_fin_year          - Financial year
          p_org_id            - Optional parameter.  If fin_year is not given, operating unit is used to derive the fin_year
          p_source_trx_date   - Optional parameter.  If fin_year is not given, transaction date is used to derive the fin_year
      OUT
          p_threshold_slab_id - Current threshold slab identifier
          p_process_flag      - Flag indicates the process status, can be either
                                   Successful        (SS)
                                   Expected Error    (EE)
                                   Unexpected Error  (UE)
          p_process_message   - Message to be passed to caller of the api.  It can be null in case of p_process_flag = 'SS'
  */
  /*------------------------------------------------------------------------------------------------------------*/
  procedure get_threshold_slab_id
            (
              p_regime_id               in            jai_rgm_thresholds.regime_id%type
            , p_org_tan_no              in            JAI_RGM_REGISTRATIONS.attribute_value%type default null
            , p_organization_id         in            hr_organization_units.organization_id%type default null
            , p_party_type              in            jai_rgm_thresholds.party_type%type
            , p_party_id                in            jai_rgm_thresholds.party_id%type
            , p_fin_year                in            jai_rgm_thresholds.fin_year%type default null
            , p_org_id                  in            jai_ap_tds_thhold_taxes.operating_unit_id%type default null
            , p_source_trx_date         in            date     default null
            , p_called_from             in            varchar2 default null
            , p_threshold_slab_id  		  out  nocopy   jai_rgm_thresholds.threshold_slab_id%type
            , p_process_flag            out  nocopy   varchar2
            , p_process_message         out  nocopy   varchar2
            )
  is
    ln_reg_id                     number;
    ln_org_tan_no                 JAI_RGM_REGISTRATIONS.attribute_value%type;
    ln_fin_year                   jai_rgm_thresholds.fin_year%type;
    lv_customer_type_lkup_code    jai_ap_tds_thhold_hdrs.customer_type_lookup_code%type;

    /** cursor will fetch org_tan_no from regime setup */
    cursor c_get_rgm_attribute ( cp_regime_id             JAI_RGM_DEFINITIONS.regime_id%type
                               , cp_attribute_type_code   JAI_RGM_REGISTRATIONS.attribute_type_code%type
                               , cp_attribute_code        JAI_RGM_REGISTRATIONS.attribute_code%type
                               , cp_organization_id       jai_rgm_parties.organization_id%type
                               )
    is
    select
           attribute_value org_tan_no
    from
           JAI_RGM_ORG_REGNS_V rgm_attr_v
    where
           rgm_attr_v.regime_id           =   cp_regime_id
    and    rgm_attr_v.attribute_code      =   cp_attribute_code
    and    rgm_attr_v.attribute_type_code =   cp_attribute_type_code
    and    rgm_attr_v.organization_id     =   cp_organization_id;

    /**
       Following cursor will derrive threshold_slab_id for a given combination of
       fin_year, org_tan_no, party_type and party_id form the threshold setup
    */
    cursor c_get_threshold_slab   ( cp_fin_year                   jai_rgm_thresholds.fin_year%type
                                  , cp_org_tan_no                 jai_rgm_thresholds.org_tan_no%type
                                  , cp_party_type                 jai_rgm_thresholds.party_type%type
                                  , cp_party_id                   jai_rgm_thresholds.party_id%type
                                  , cp_customer_type_lkup_code    jai_ap_tds_thhold_hdrs.customer_type_lookup_code%type
                                  )
    is
    select
            thslbs.threshold_slab_id
    from
            jai_ap_tds_thhold_slabs thslbs
           ,jai_ap_tds_thhold_types thtyps
           ,jai_ap_tds_thhold_hdrs  thhdrs
           ,jai_rgm_thresholds      rgmths
    where
            thslbs.threshold_type_id  = thtyps.threshold_type_id
     and    thtyps.threshold_hdr_id   = thhdrs.threshold_hdr_id
     and    thhdrs.regime_id          = rgmths.regime_id
     and    thtyps.threshold_type     = jai_constants.thhold_typ_cumulative
     and    rgmths.fin_year           = cp_fin_year
     and    rgmths.party_id           = cp_party_id
     and    rgmths.org_tan_no         = cp_org_tan_no
     and    rgmths.party_type         = cp_party_type
     and    thhdrs.customer_type_lookup_code = cp_customer_type_lkup_code
     and    trunc(p_source_trx_date)      between thtyps.from_date
                                          and     nvl(thtyps.to_date, trunc(p_source_trx_date))
     and    rgmths.total_threshold_amt    between thslbs.from_amount
                                          and nvl(thslbs.to_amount,rgmths.total_threshold_amt);

   cursor c_get_thhold_hdr_slab   ( cp_fin_year               jai_rgm_thresholds.fin_year%type
                                  , cp_org_tan_no            jai_rgm_thresholds.org_tan_no%type
                                  , cp_party_type             jai_rgm_thresholds.party_type%type
                                  , cp_party_id               jai_rgm_thresholds.party_id%type
                                  )
   is
    select threshold_slab_id
    from   jai_rgm_thresholds
    where  fin_year     =   cp_fin_year
    and    org_tan_no   =   cp_org_tan_no
    and    party_type   =   cp_party_type
    and    party_id     =   cp_party_id
    and    regime_id    =   p_regime_id;

    cursor c_get_cust_typ_lkup_code
    is
      select tcs_customer_type
      from   JAI_CMN_CUS_ADDRESSES
      where  customer_id  = p_party_id
      AND tcs_customer_type IS NOT NULL;  --added the AND condition for bug#6156619



  begin
    /** Initialize process variables */
    p_process_flag        := jai_constants.successful ;--'SS';
    p_process_message     := null;
    p_threshold_slab_id   := null;


    /** Register procedure for debuging */
    lv_member_name        := 'GET_THRESHOLD_SLAB_ID';
    set_debug_context;
  /*  jai_cmn_debug_contexts_pkg.register ( pv_context => lv_context
                               , pn_reg_id  => ln_reg_id
                               ); */ -- */ --commented by bgowrava for bug#5631784

 /*   jai_cmn_debug_contexts_pkg.print (ln_reg_id
                              ,'Call Parameters:
                                 P_REGIME_ID='||p_regime_id
                             ||' P_org_tan_no='||p_org_tan_no
                             ||' P_ORGANIZATION_ID='||p_organization_id
                             ||' P_PARTY_TYPE='||p_party_type
                             ||' P_PARTY_ID='||p_party_id
                             ||' P_FIN_YEAR='||p_fin_year
                             ||' P_ORG_ID='||p_org_id
                             ||' P_SOURCE_TRX_DATE='||p_source_trx_date
                              ,jai_cmn_debug_contexts_pkg.detail
                              ); */ -- */ --commented by bgowrava for bug#5631784

    if p_org_tan_no is null then
      if p_organization_id is not null then
        /** Get org_tan_no using inventory organization from regime setup */
        open  c_get_rgm_attribute ( cp_regime_id            =>  p_regime_id
                                  , cp_attribute_type_code  =>  jai_constants.rgm_attr_type_code_primary /* PRIMARY */
                                  , cp_attribute_code       =>  jai_constants.rgm_attr_code_org_tan /*ORG_TAN_NUM */
                                  , cp_organization_id      =>  p_organization_id
                                  );
        fetch c_get_rgm_attribute into ln_org_tan_no;
        close c_get_rgm_attribute;
      else
        /** Both org_tan_no and organization_id are null */
        p_process_flag      :=  jai_constants.expected_error;
        p_process_message   :=  'P_ORG_TAN_NO and P_ORGANIZATION_ID both cannot be null';
        return;
      end if;
    else
      /** Use the p_org_tan_no  */
      ln_org_tan_no := p_org_tan_no;
    end if;

    /** Assumption: If org_tan_no is null cannot derrive threshold amount*/
    if ln_org_tan_no is null then
      p_process_flag      := jai_constants.expected_error;
      p_process_message   := 'Unable to get mandatory attribute ORG_TAN_NUM using the arguments
                             ||  P_REGIME_ID='||p_regime_id
                             ||' P_ORGANIZATION_ID=' || p_organization_id;
      return;
    end if;

    if p_fin_year is null then
      if p_org_id is not null then
        /** Fin_year is not given but org_id is available.  Hence derive fin_year using org_id and trx_date */

        open    jai_ar_tcs_rep_pkg.get_tcs_fin_year ( cp_org_id       =>  p_org_id
                                                    , cp_trx_date     =>  p_source_trx_date
                                                    );
        fetch   jai_ar_tcs_rep_pkg.get_tcs_fin_year into ln_fin_year;
        close   jai_ar_tcs_rep_pkg.get_tcs_fin_year;

      else
        /** Both fin_year and org_id are null*/
        p_process_flag    := jai_constants.expected_error;
        p_process_message := 'Both P_FIN_YEAR and P_ORG_ID cannot be null';
        return;
      end if;
    else
      ln_fin_year := p_fin_year;
    end if;

    /** Assumption: If fin_year is null cannot a unique threshold hdr record */
    if ln_fin_year is null then
      p_process_flag      := jai_constants.expected_error;
      p_process_message   := 'Unable to derive mandatory LN_FIN_YEAR using the given arguments'
                             ||' P_FIN_YEAR='||p_fin_year
                             ||' P_ORG_ID='||p_organization_id
                             ||' P_SOURCE_TRX_DATE='||p_source_trx_date;
      return;
    end if;

 /*   jai_cmn_debug_contexts_pkg.print (ln_reg_id
                            ,   'ln_fin_year= '||ln_fin_year
                               ||'ln_org_tan_no='||ln_org_tan_no
                               ||'party_type='||jai_constants.party_type_customer
                               ||'p_party_id='||p_party_id
                            ,jai_cmn_debug_contexts_pkg.detail
                            );		*/ -- */ --commented by bgowrava for bug#5631784

    if  p_called_from is not null
    and p_called_from = jai_constants.tcs_event_surcharge then
    /** This is an internal call.  Hence fetch the applicable slab id for amount updated in the jai_rgm_thresholds */

      /**
        Assumption: To fetch slab from the setup transaction date is mandatory
      */
      if p_source_trx_date is null then
        p_process_flag    := jai_constants.expected_error;
        p_process_message := 'When deriving the threshold slab from setup, P_SOURCE_TRX_DATE cannot be null.  P_SOURCE_TRX_DATE='||nvl(to_char(p_source_trx_date),'null');
        return;
      end if;

      open  c_get_cust_typ_lkup_code;
      fetch c_get_cust_typ_lkup_code into lv_customer_type_lkup_code;
      close c_get_cust_typ_lkup_code;

      /**
        Assumption:  Party classification cannot be null for a customer as it is one of
                     the attribute used to derrive the slab
      */
      if lv_customer_type_lkup_code is null then
        p_process_flag    :=  jai_constants.expected_error;
        p_process_message  :=  'Unable to derive party classification for party_id='||p_party_id;
        return;
      end if;

      /** Get threshold slab for the current threshold amount for combination of
          org_tan_num, fin_year, party_type and party_id

          Assumption: for TCS, party_type will be CUSTOMER only
      */
  /*    jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'lv_customer_type_lkup_code='||lv_customer_type_lkup_code, jai_cmn_debug_contexts_pkg.detail);*/ -- */ --commented by bgowrava for bug#5631784
      open  c_get_threshold_slab ( cp_fin_year                   => ln_fin_year
                                 , cp_org_tan_no                 => ln_org_tan_no
                                 , cp_party_type                 => jai_constants.party_type_customer
                                 , cp_party_id                   => p_party_id
                                 , cp_customer_type_lkup_code    => lv_customer_type_lkup_code
                                 );
      fetch  c_get_threshold_slab into p_threshold_slab_id;
      close  c_get_threshold_slab ;

    else /** p_called_from is null means the call is from outside.  So, fetch the threshold slab from jai_rgm_thresholds and return */

      open  c_get_thhold_hdr_slab ( cp_fin_year              => ln_fin_year
                                  , cp_org_tan_no           => ln_org_tan_no
                                  , cp_party_type            => jai_constants.party_type_customer
                                  , cp_party_id              => p_party_id
                                  );
      fetch c_get_thhold_hdr_slab into p_threshold_slab_id;
      close c_get_thhold_hdr_slab;

    end if;

 /*   jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'P_THRESHOLD_SLAB_ID='||p_threshold_slab_id,jai_cmn_debug_contexts_pkg.detail);*/ -- */ --commented by bgowrava for bug#5631784

    /** Process completed successfully */
    p_process_flag    := jai_constants.successful; --'SS'
    p_process_message := null;

    /** Deregister procedure and return*/
    <<deregister_and_return>>
  /*  jai_cmn_debug_contexts_pkg.deregister (pn_reg_id => ln_reg_id);*/ -- */ --commented by bgowrava for bug#5631784
    return;
  exception
    when others then
      p_process_flag    := jai_constants.unexpected_error;
      p_process_message := lv_context||'->'||sqlerrm;
  /*    jai_cmn_debug_contexts_pkg.print(ln_reg_id,sqlerrm,jai_cmn_debug_contexts_pkg.summary);
      jai_cmn_debug_contexts_pkg.print_stack;*/ -- */ --commented by bgowrava for bug#5631784

  end get_threshold_slab_id;

  /*------------------------------------------------------------------------------------------------------------*/
  /*
      get_threshold_tax_cat_id    - returns tax category defined in the threshold setup as out parameter
      IN
          p_threshold_slab_id     - Threshold slab identifier
          p_org_id                - Operating unit
      OUT
          p_threshold_tax_cat_id  - Tax category identifier
          p_process_flag          - Flag indicates the process status, can be either
                                      Successful        (SS)
                                      Expected Error    (EE)
                                      Unexpected Error  (UE)
          p_process_message       - Message to be passed to caller of the api.  It can be null in case of
                                    p_process_flag = 'SS'
  */
  /*------------------------------------------------------------------------------------------------------------*/
  procedure get_threshold_tax_cat_id
            (
               p_threshold_slab_id       in           jai_rgm_thresholds.threshold_slab_id%type
            ,  p_org_id                  in           jai_ap_tds_thhold_taxes.operating_unit_id%type
            ,  p_threshold_tax_cat_id 	 out  nocopy  jai_ap_tds_thhold_taxes.tax_category_id%type
            ,  p_process_flag            out  nocopy  varchar2
            ,  p_process_message         out  nocopy  varchar2
            )
  is
    ln_reg_id       number;
    /** Get tax category attached to the operating unit */
    cursor c_get_threshold_tax_cat_id
    is
    select
            thtaxes.tax_category_id
    from
            jai_ap_tds_thhold_taxes thtaxes
    where
            thtaxes.threshold_slab_id = p_threshold_slab_id
    and     operating_unit_id         = p_org_id;

  begin
    /** Initialize process variables */
    p_process_flag        := jai_constants.successful; --'SS'
    p_process_message     := null;

    /** Register this procedure for debuging */
    lv_member_name        := 'GET_THRESHOLD_TAX_CAT_ID';
    set_debug_context;
  /*  jai_cmn_debug_contexts_pkg.register ( pv_context => lv_context
                               , pn_reg_id  => ln_reg_id
                               )   ;
    jai_cmn_debug_contexts_pkg.print (ln_reg_id
                            , 'Opening and fetching c_get_threshold_tax_cat_id
                               p_threshold_slab_id='||p_threshold_slab_id
                            ||'p_org_id='||p_org_id
                            ,jai_cmn_debug_contexts_pkg.detail
                            );			*/ --commented by bgowrava for bug#5631784

    if p_threshold_slab_id is null then
      p_threshold_tax_cat_id := -1;
      goto deregister_and_return;
    end if;

    open  c_get_threshold_tax_cat_id;
    fetch c_get_threshold_tax_cat_id into p_threshold_tax_cat_id;
    close c_get_threshold_tax_cat_id;
    jai_cmn_debug_contexts_pkg.print (ln_reg_id, '(Out) P_THRESHOLD_TAX_CAT_ID='||p_threshold_tax_cat_id,jai_cmn_debug_contexts_pkg.detail);

    /** Deregister and return */
    <<deregister_and_return>>
  /*  jai_cmn_debug_contexts_pkg.deregister (pn_reg_id => ln_reg_id);*/ --commented by bgowrava for bug#5631784
    return;

  exception

    when others then
      p_process_flag    := jai_constants.unexpected_error;
      p_process_message := lv_context||'->'||sqlerrm;
      jai_cmn_debug_contexts_pkg.print(ln_reg_id,sqlerrm,jai_cmn_debug_contexts_pkg.summary);
      jai_cmn_debug_contexts_pkg.print_stack;

  end get_threshold_tax_cat_id;

  /*------------------------------------------------------------------------------------------------------------*/
  /*
      default_thhold_taxes       - defaults threshold taxes defined by the tax category
      IN
          p_source_trx_id        -   transaction identifier
          p_source_trx_line_id   -   transaction line identifier
          p_source_event         -   Event for which taxes to be defaulted. Currently only 'SHIPPING'
          p_source_action        -   Action on which taxes are defaulted.  Currently only 'CONFIRM'
          p_tax_base_line_number -   Line number to be used as base line when calculating taxes.  Default is 0
          p_last_line_number     -   Line number after which threshold taxes to be defaulted
          p_threshold_tax_cat_id -   Tax category identifier for taxes to be defaulted

      OUT
          p_process_flag         -   Flag indicates the process status, can be either
                                       Successful        (SS)
                                       Expected Error    (EE)
                                       Unexpected Error  (UE)
          p_process_message      -   Message to be passed to caller of the api.  It can be null in case of p_process_flag = 'SS'
  */
  /*------------------------------------------------------------------------------------------------------------*/
  procedure default_thhold_taxes
            (
              p_source_trx_id             in            number
            , p_source_trx_line_id        in            number
            , p_source_event              in            varchar2
            , p_action                    in            varchar2
            , p_threshold_tax_cat_id      in            jai_ap_tds_thhold_taxes.tax_category_id%type
            , p_tax_base_line_number      in            number   default 0
            , p_last_line_number          in            number   default 0
            , p_currency_code             in            varchar2 default null
            , p_currency_conv_rate        in            number   default null
            , p_quantity                  in            number   default null
            , p_base_tax_amt              in            number   default null
            , p_assessable_value          in            number   default null
            , p_inventory_item_id         in            number   default null
            , p_uom_code                  in            varchar2 default null
            , p_vat_assessable_value      in            number   default null
            , p_process_flag              out  nocopy   varchar2
            , p_process_message           out  nocopy   varchar2
            )
  is
    ln_reg_id             number;
    ln_base               number := 0;

    type ref_cur_typ      is ref cursor;
    refc_tax_cur          ref_cur_typ;

    r_taxes               jai_cmn_tax_defaultation_pkg.tax_rec_typ;

    ln_tax_amount       number ;
    ln_user_id          fnd_user.user_id%type       :=    fnd_global.user_id;
    ln_login_id         fnd_logins.login_id%type    :=    fnd_global.login_id;
    lv_currency         fnd_currencies.currency_code%type;
    ln_curr_conv_factor number;
    ln_exists           number(2);

  begin
    /** Initialize process variables */
    p_process_flag        := jai_constants.successful; --'SS'
    p_process_message     := null;

    /** Register this procedure for debuging */
    lv_member_name        := 'DEFAULT_THHOLD_TAXES';
    set_debug_context;
 /*   jai_cmn_debug_contexts_pkg.register ( pv_context => lv_context
                               , pn_reg_id  => ln_reg_id
                               ) ;
    jai_cmn_debug_contexts_pkg.print
                      ( ln_reg_id
                      , '  Call Parameters:
                           p_source_trx_id         ='||p_source_trx_id         ||'
                         , p_source_trx_line_id    ='||p_source_trx_line_id    ||'
                         , p_source_event          ='||p_source_event          ||'
                         , p_action                ='||p_action                ||'
                         , p_threshold_tax_cat_id  ='||p_threshold_tax_cat_id  ||'
                         , p_tax_base_line_number  ='||p_tax_base_line_number  ||'
                         , p_last_line_number      ='||p_last_line_number      ||'
                         , p_currency_code         ='||p_currency_code         ||'
                         , p_currency_conv_rate    ='||p_currency_conv_rate    ||'
                         , p_quantity              ='||p_quantity              ||'
                         , p_base_tax_amt          ='||p_base_tax_amt          ||'
                         , p_assessable_value      ='||p_assessable_value      ||'
                         , p_inventory_item_id     ='||p_inventory_item_id     ||'
                         , p_uom_code              ='||p_uom_code              ||'
                         , p_vat_assessable_value  ='||p_vat_assessable_value  ||'
                         , p_process_flag          ='||p_process_flag          ||'
                         , p_process_message       ='||p_process_message
                      , jai_cmn_debug_contexts_pkg.summary
                       );			 */ --commented by bgowrava for bug#5631784
        ln_exists := null;
        if p_source_event = jai_constants.source_ttype_delivery then
          /* Temporary pl-sql block to check if surcharge/surcharge-cess type of tax already exists in the picking line */
          declare
            cursor c_chk_picking_tax_exists
            is
              select 1
              from   JAI_OM_WSH_LINE_TAXES line, JAI_CMN_TAX_CTG_LINES cat
              where  line.tax_id              =   cat.tax_id
              and    line.delivery_detail_id  =   p_source_trx_line_id
              and    cat.tax_category_id      =   p_threshold_tax_cat_id;
          begin
            open  c_chk_picking_tax_exists;
            fetch c_chk_picking_tax_exists  into ln_exists;
            close c_chk_picking_tax_exists ;
          end;
        elsif p_source_event = jai_constants.bill_only_invoice then
        /* Temporary pl-sql block to check if surcharge/surcharge-cess type of tax already exists in the ra_customer_trx_lines */

          declare
            cursor c_chk_ra_trx_tax_exists
            is
              select 1
              from   JAI_AR_TRX_TAX_LINES line, JAI_CMN_TAX_CTG_LINES cat
              where  line.tax_id                    =   cat.tax_id
              and    line.link_to_cust_trx_line_id  =   p_source_trx_line_id
              and    cat.tax_category_id            =   p_threshold_tax_cat_id;
          begin
            open  c_chk_ra_trx_tax_exists ;
            fetch c_chk_ra_trx_tax_exists   into ln_exists;
            close c_chk_ra_trx_tax_exists  ;
          end;

        end if; /* p_source_event */

        if ln_exists is not null then
          -- Tax is already present hence no need to default it
          p_process_flag    := jai_constants.successful;
          p_process_message := null;
     /*     jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Skipping surcharge tax defaultaion as one of the tax is already present in the transaction');*/ --commented by bgowrava for bug#5631784
          return;
        end if;

    --for r_taxes in c_get_taxes_from_category
    jai_cmn_tax_defaultation_pkg.get_tax_cat_taxes_cur
            (p_tax_category_id        => -1 -- pass the value which never exists in JAI_CMN_TAX_CTG_LINES
            ,p_threshold_tax_cat_id   =>  p_threshold_tax_cat_id
            ,p_max_tax_line           =>  p_last_line_number
            ,p_max_rgm_tax_line       =>  p_tax_base_line_number
            ,p_base                   =>  0--p_last_line_number/*bduvarag for the bug#6081966, FP of 6084563*/
            ,p_refc_tax_cat_taxes_cur =>  refc_tax_cur
            );
    loop
      fetch refc_tax_cur into r_taxes;
      exit when refc_tax_cur%notfound;

      if p_source_event = jai_constants.source_ttype_delivery then
    /*    jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'r_taxes.tax_id='||r_taxes.tax_id||', ln_exists='||ln_exists);     */ --commented by bgowrava for bug#5631784
        insert into JAI_OM_WSH_LINE_TAXES
                    (    picking_line_id
                     ,   tax_line_no
                     ,   precedence_1
                     ,   precedence_2
                     ,   precedence_3
                     ,   precedence_4
                     ,   precedence_5
                     ,   tax_id
                     ,   tax_rate
                     ,   qty_rate
                     ,   uom
                     ,   tax_amount
                     ,   func_tax_amount
                     ,   base_tax_amount
                     ,   creation_date
                     ,   created_by
                     ,   last_update_date
                     ,   last_updated_by
                     ,   last_update_login
                     ,   delivery_detail_id
                     ,   precedence_6
                     ,   precedence_7
                     ,   precedence_8
                     ,   precedence_9
                     ,   precedence_10
                    )
        values      (    null
                    ,    r_taxes.lno
                    ,    r_taxes.p_1
                    ,    r_taxes.p_2
                    ,    r_taxes.p_3
                    ,    r_taxes.p_4
                    ,    r_taxes.p_5
                    ,    r_taxes.tax_id
                    ,    r_taxes.tax_rate
                    ,    null
                    ,    r_taxes.tax_amount
                    ,    r_taxes.uom_code
                    ,    null
                    ,    null
                    ,    sysdate
                    ,    ln_user_id
                    ,    sysdate
                    ,    ln_user_id
                    ,    ln_login_id
                    ,    p_source_trx_line_id
                    ,    r_taxes.p_6
                    ,    r_taxes.p_7
                    ,    r_taxes.p_8
                    ,    r_taxes.p_9
                    ,    r_taxes.p_10
                    );
      elsif p_source_event = jai_constants.bill_only_invoice then
        insert into JAI_AR_TRX_TAX_LINES
                  (
                     tax_line_no
                    ,customer_trx_line_id
                    ,link_to_cust_trx_line_id
                    ,precedence_1
                    ,precedence_2
                    ,precedence_3
                    ,precedence_4
                    ,precedence_5
                    ,tax_id
                    ,tax_rate
                    ,qty_rate
                    ,uom
                    ,tax_amount
                    ,invoice_class
                    ,func_tax_amount
                    ,base_tax_amount
                    ,creation_date
                    ,created_by
                    ,last_update_date
                    ,last_updated_by
                    ,last_update_login
                    ,precedence_6
                    ,precedence_7
                    ,precedence_8
                    ,precedence_9
                    ,precedence_10
                  )
          values  (
                     r_taxes.lno                                  --tax_line_no
                   , ra_customer_trx_lines_s.nextval              --customer_trx_line_id
                   , p_source_trx_line_id                         --link_to_cust_trx_line_id
                   , r_taxes.p_1                                  --precedence_1
                   , r_taxes.p_2                                  --precedence_2
                   , r_taxes.p_3                                  --precedence_3
                   , r_taxes.p_4                                  --precedence_4
                   , r_taxes.p_5                                  --precedence_5
                   , r_taxes.tax_id                               --tax_id
                   , r_taxes.tax_rate                             --tax_rate
                   , null                                         --qty_rate
                   , r_taxes.uom_code                             --uom
                   , null                                         --tax_amount
                   , null                                         --invoice_class
                   , null                                         --func_tax_amount
                   , null                                         --base_tax_amount
                   , sysdate                                      --creation_date
                   , ln_user_id                                   --created_by
                   , sysdate                                      --last_update_date
                   , ln_user_id                                   --last_updated_by
                   , ln_login_id                                  --last_update_login
                   , r_taxes.p_6                                  --precedence_6
                   , r_taxes.p_7                                  --precedence_7
                   , r_taxes.p_8                                  --precedence_8
                   , r_taxes.p_9                                  --precedence_9
                   , r_taxes.p_10                                 --precedence_10
                  );
      end if; /** p_source_event */

    end loop;
    /*
    ||  Close the reference cursor.  This will acutally close the cursor object in the server memory
    */
    close refc_tax_cur;

   /* jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Before: jai_cmn_tax_defaultation_pkg.JA_IN_CALC_PREC_TAXES', jai_cmn_debug_contexts_pkg.summary);*/ --commented by bgowrava for bug#5631784
    /** Call ja_in_calc_prec_taxes procedure in recalculate taxes mode to recalculate taxes and update the related table */
    ln_tax_amount := p_base_tax_amt ;
    jai_cmn_tax_defaultation_pkg.ja_in_calc_prec_taxes
                (  transaction_name        =>    p_source_event
                ,  p_tax_category_id       =>    -1  /** Pass normal tax category as negative value so it will not be considered */
                ,  p_header_id             =>    p_source_trx_id
                ,  p_line_id               =>    p_source_trx_line_id
                ,  p_assessable_value      =>    p_assessable_value
                ,  p_tax_amount            =>    ln_tax_amount  /** Final calculated tax amount is returned in this variable */
                ,  p_inventory_item_id     =>    p_inventory_item_id
                ,  p_line_quantity         =>    p_quantity
                ,  p_uom_code              =>    p_uom_code
                ,  p_vendor_id             =>    ''
                ,  p_currency              =>    p_currency_code
                ,  p_currency_conv_factor  =>    p_currency_conv_rate
                ,  p_creation_date         =>    sysdate
                ,  p_created_by            =>    ln_user_id
                ,  p_last_update_date      =>    sysdate
                ,  p_last_updated_by       =>    ln_user_id
                ,  p_last_update_login     =>    ln_login_id
                ,  p_vat_assessable_value  =>    p_vat_assessable_value
                ,  p_thhold_cat_base_tax_typ=>   jai_constants.tax_type_tcs
                ,  p_threshold_tax_cat_id  =>    p_threshold_tax_cat_id
                ,  p_source_trx_type       =>    p_source_event
                ,  p_action                =>    jai_constants.recalculate_taxes
                );
/*    jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'After: jai_cmn_tax_defaultation_pkg.JA_IN_CALC_PREC_TAXES', jai_cmn_debug_contexts_pkg.summary);*/ --commented by bgowrava for bug#5631784

    /** Deregister and return */
    <<deregister_and_return>>
/*    jai_cmn_debug_contexts_pkg.deregister (pn_reg_id => ln_reg_id);*/ --commented by bgowrava for bug#5631784
    return;

  exception

    when others then
      p_process_flag    := jai_constants.unexpected_error;
      p_process_message := lv_context||'->'||sqlerrm;
 /*     jai_cmn_debug_contexts_pkg.print(ln_reg_id,sqlerrm,jai_cmn_debug_contexts_pkg.summary);
      jai_cmn_debug_contexts_pkg.print_stack;*/ --commented by bgowrava for bug#5631784

  end default_thhold_taxes;

  /*------------------------------------------------------------------------------------------------------------*/
  procedure maintain_threshold
            ( p_transaction_id        in        jai_rgm_refs_all.transaction_id%type
            , p_last_line_flag    in            varchar2 default jai_constants.yes
            , p_process_flag      out nocopy    varchar2
            , p_process_message   out nocopy    varchar2
            )
  is

    ln_reg_id       number;

    cursor c_get_trx_details
    is
      select regime_id
           , org_tan_no
           , party_id
           , party_type
           , fin_year
           , item_classification
           , source_document_type
           , sum(nvl(source_document_amt,0)) source_document_amt
           , source_document_date
           , org_id
      from  jai_rgm_refs_all trxref
      where trxref.transaction_id = p_transaction_id
      group by
             regime_id
           , org_tan_no
           , party_id
           , party_type
           , fin_year
           , item_classification
           , source_document_type
           , source_document_date
           , org_id;

    cursor c_get_threshold_id  (  cp_regime_id      jai_rgm_thresholds.regime_id%type
                               ,  cp_org_tan_no     jai_rgm_thresholds.org_tan_no%type
                               ,  cp_party_type     jai_rgm_thresholds.party_type%type
                               ,  cp_party_id       jai_rgm_thresholds.party_id%type
                               ,  cp_fin_year       jai_rgm_thresholds.fin_year%type
                               )
    is
      select  threshold_id
            , threshold_slab_id
      from    jai_rgm_thresholds
      where   regime_id   = cp_regime_id
      and     org_tan_no  = cp_org_tan_no
      and     party_id    = cp_party_id
      and     party_type  = cp_party_type
      and     fin_year    = cp_fin_year;

    cursor c_get_threshold_dtl   ( cp_threshold_id         jai_rgm_threshold_dtls.threshold_id%type
                                 , cp_item_classification  jai_rgm_threshold_dtls.item_classification%type
                                 )
    is
      select  threshold_dtl_id
            , invoice_amt
            , cash_receipt_amt
            , application_amt
            , unapplication_amt
            , reversal_amt
            , threshold_base_amt
            , manual_surcharge_amt
            , system_surcharge_amt
            , system_surcharge_cess_amt
            , system_surcharge_sh_cess_amt --Bgowrava for forward porting bug#5989740
      from   jai_rgm_threshold_dtls
      where  threshold_id         = cp_threshold_id
      and    item_classification  = cp_item_classification;

    cursor c_get_customer_pan (cp_customer_id    JAI_CMN_CUS_ADDRESSES.customer_id%type)
    is
      select   pan_no
      from     JAI_CMN_CUS_ADDRESSES
      where    customer_id = cp_customer_id
      and      confirm_pan = jai_constants.yes;

    cursor c_get_ref_thhold_base_amt (cp_base_tax_type    jai_rgm_taxes.tax_type%type)
    is
      select   sum(rtax.func_tax_amt)
      from     jai_rgm_taxes rtax
             , jai_rgm_refs_all refs
      where    rtax.trx_ref_id     = refs.trx_ref_id
      and      refs.transaction_id = p_transaction_id
      and      rtax.tax_type       = cp_base_tax_type;

    cursor c_get_surcharge_amt (cp_tax_type         varchar2
                               ,cp_tax_modified_by  varchar2
                               )
    is
      select   sum(rtax.func_tax_amt)
      from     jai_rgm_taxes        rtax
             , jai_rgm_refs_all     refs
      where    rtax.trx_ref_id      = refs.trx_ref_id
      and      rtax.tax_type        = cp_tax_type
      and      refs.transaction_id  = p_transaction_id
      and      rtax.tax_modified_by = nvl(cp_tax_modified_by,rtax.tax_modified_by);


    /*
    ||  Following cursor will derive tax amount from the TCS reporsitory taxes for SURCHARGE CESS.  Technically, SURCHARGE CESS can be identified by
    ||  looking at tax_type and precedence_1 (which should be line number of TCS_SURCHARGE type of tax ).  Functionally, SURCHARGE_CESS should depende
    ||  upon SURCHARGE type of tax
    */

    cursor c_get_surcharge_cess (cp_thhold_tax_cat_id  jai_ap_tds_thhold_taxes.tax_category_id%type)
    is
      select  sum(rtax.func_tax_amt)
      from    jai_rgm_taxes             rtax
            , jai_rgm_refs_all          refs
            , JAI_CMN_TAX_CTG_LINES  srch
            , JAI_CMN_TAX_CTG_LINES  srchcess
            , JAI_CMN_TAXES_ALL           tax
      where   rtax.trx_ref_id      = refs.trx_ref_id
      and     rtax.tax_type        = jai_constants.tax_type_tcs_cess
      and     srch.tax_category_id = cp_thhold_tax_cat_id
      and     srchcess.tax_category_id = srch.tax_category_id
      and     srchcess.precedence_1 = srch.line_no
      and     srchcess.tax_id       = rtax.tax_id
      and     srch.tax_id           = tax.tax_id
      and     tax.tax_type          = jai_constants.tax_type_tcs_surcharge
      and     refs.transaction_id   = p_transaction_id;

-- start Bgowrava for forward porting bug#5989740

    cursor c_get_surcharge_sh_cess (cp_thhold_tax_cat_id  jai_ap_tds_thhold_taxes.tax_category_id%type)
    is
      select  sum(rtax.func_tax_amt)
      from    jai_rgm_taxes             rtax
            , jai_rgm_refs_all          refs
            , JAI_CMN_TAX_CTG_LINES  srch
            , JAI_CMN_TAX_CTG_LINES  srchcess
            , JAI_CMN_TAXES_ALL           tax
      where   rtax.trx_ref_id      = refs.trx_ref_id
      and     rtax.tax_type        = jai_constants.tax_type_sh_tcs_edu_cess
      and     srch.tax_category_id = cp_thhold_tax_cat_id
      and     srchcess.tax_category_id = srch.tax_category_id
      and     srchcess.precedence_1 = srch.line_no
      and     srchcess.tax_id       = rtax.tax_id
      and     srch.tax_id           = tax.tax_id
      and     tax.tax_type          = jai_constants.tax_type_tcs_surcharge
      and     refs.transaction_id   = p_transaction_id;

-- end Bgowrava for forward porting bug#5989740



    ln_threshold_id                 jai_rgm_thresholds.threshold_id%type;
    ln_threshold_dtl_id             jai_rgm_threshold_dtls.threshold_dtl_id%type;
    lr_hdr_record                   jai_rgm_thresholds%rowtype;
    lr_dtl_record                   jai_rgm_threshold_dtls%rowtype;
    lx_row_id                       rowid;
    ln_ref_thhold_base_amt          number;
    /*
    ln_manual_surcharge_amt         number;
    ln_system_surcharge_amt         number;
    ln_system_surcharge_cess_amt    number;
    */
    ln_surcharge_amt                number;
    ln_surcharge_cess_amt           number;
    ln_surcharge_sh_cess_amt           number; --Bgowrava for forward porting bug#5989740
    lv_thhold_slab_change_flag      varchar2(2);
    ln_new_thhold_slab_id           jai_rgm_thresholds.threshold_slab_id%type;
    ln_thhold_tax_cat_id            jai_ap_tds_thhold_taxes.tax_category_id%type;


    ln_user_id                fnd_user.user_id%type := fnd_global.user_id;
    ln_login_id               fnd_logins.login_id%type := fnd_global.login_id;



  begin
    /** Initialize process variables */
    p_process_flag        := jai_constants.successful;
    p_process_message     := null;

    /** Register this procedure for debuging */
    lv_member_name        := 'MAINTAIN_THRESHOLD';
    set_debug_context;
    /*jai_cmn_debug_contexts_pkg.register ( pv_context => lv_context
                               , pn_reg_id  => ln_reg_id
                               ) ;	*/

 /*   jai_cmn_debug_contexts_pkg.print (ln_reg_id
                            , 'Call Parameters:-' ||chr(10)
                            ||'p_transaction_id ='||p_transaction_id||chr(10)
                            ||'p_last_line_flag=' ||p_last_line_flag
                            ,jai_cmn_debug_contexts_pkg.summary
                            );*/ --commented by bgowrava for bug#5631784

    for r_trx_lines in c_get_trx_details
    loop

      /** Check for combination of ORG_TAN_NO, PARTY_ID, FIN_YEAR a record exists in the jai_rgm_thresholds table */
      open  c_get_threshold_id
                  (  cp_regime_id    =>  r_trx_lines.regime_id
                  ,  cp_org_tan_no   =>  r_trx_lines.org_tan_no
                  ,  cp_party_type   =>  jai_constants.party_type_customer
                  ,  cp_party_id     =>  r_trx_lines.party_id
                  ,  cp_fin_year     =>  r_trx_lines.fin_year
                  );
      fetch c_get_threshold_id into ln_threshold_id
                                   ,lr_hdr_record.threshold_slab_id;
      close c_get_threshold_id ;

   /*   jai_cmn_debug_contexts_pkg.print ( ln_reg_id
                              , 'ln_threshold_id='||ln_threshold_id
                              , jai_cmn_debug_contexts_pkg.detail
                              );*/ --commented by bgowrava for bug#5631784

      /**************************************************************************************
      ||Part -1 :- FIRST TIME HEADER CREATION IN TABLE JAI_RGM_THRESHOLDS
      ***************************************************************************************/

      if ln_threshold_id is null then

        /** Record does not exists for the combination, so create a header record */
        /** Initialize loop variables*/

    /*    jai_cmn_debug_contexts_pkg.print (ln_reg_id
                                ,'Threshold header does not exists for combination of ORG_TAN_NO, PARTY_ID and FIN_YEAR. Creating ...'
                                );	*/ --commented by bgowrava for bug#5631784
        lr_hdr_record:=null;

        /** Populate header record */

        lr_hdr_record.threshold_id              :=  ln_threshold_id         ;
        lr_hdr_record.regime_id                 :=  r_trx_lines.regime_id   ;
        lr_hdr_record.org_tan_no                :=  r_trx_lines.org_tan_no ;
        lr_hdr_record.party_id                  :=  r_trx_lines.party_id    ;
        lr_hdr_record.party_type                :=  r_trx_lines.party_type  ;

    /*    jai_cmn_debug_contexts_pkg.print (ln_reg_id
                                ,'Open/Fetch/Close cursor C_GET_CUSTOMER_PAN'
                                ); */ --commented by bgowrava for bug#5631784

        open  c_get_customer_pan (cp_customer_id => r_trx_lines.party_id);
        fetch c_get_customer_pan into lr_hdr_record.party_pan_no;
        close c_get_customer_pan;
        /**
          Assumption: Customer must have the PAN and it must be confirmed
        */
        if  lr_hdr_record.party_pan_no is null then
          p_process_flag    := jai_constants.expected_error;
          p_process_message := 'Cannot find a confirmed PAN for customer_id='||r_trx_lines.party_id
                             ||'.Please define a confirmed PAN for the customer in the customer setup';
          return;
        end if;

        lr_hdr_record.threshold_slab_id         :=  null                    ;
        lr_hdr_record.fin_year                  :=  r_trx_lines.fin_year    ;
        lr_hdr_record.total_threshold_amt       :=  null                    ;
        lr_hdr_record.total_threshold_base_amt  :=  null                    ;
        lr_hdr_record.creation_date             :=  sysdate                 ;
        lr_hdr_record.created_by                :=  ln_user_id              ;
        lr_hdr_record.last_update_date          :=  sysdate                 ;
        lr_hdr_record.last_updated_by           :=  ln_user_id              ;
        lr_hdr_record.last_update_login         :=  ln_login_id             ;


  /*      jai_cmn_debug_contexts_pkg.print ( ln_reg_id
                                , 'Before insert into jai_rgm_thresholds'    || chr(10)
                                ||'lr_hdr_record.threshold_id              ='||lr_hdr_record.threshold_id             ||  chr(10)
                                ||'lr_hdr_record.regime_id                 ='||lr_hdr_record.regime_id                ||  chr(10)
                                ||'lr_hdr_record.org_tan_no                ='||lr_hdr_record.org_tan_no               ||  chr(10)
                                ||'lr_hdr_record.party_id                  ='||lr_hdr_record.party_id                 ||  chr(10)
                                ||'lr_hdr_record.party_type                ='||lr_hdr_record.party_type               ||  chr(10)
                                ||'lr_hdr_record.party_pan_no              ='||lr_hdr_record.party_pan_no             ||  chr(10)
                                ||'lr_hdr_record.threshold_slab_id         ='||lr_hdr_record.threshold_slab_id        ||  chr(10)
                                ||'lr_hdr_record.fin_year                  ='||lr_hdr_record.fin_year                 ||  chr(10)
                                ||'lr_hdr_record.total_threshold_amt       ='||lr_hdr_record.total_threshold_amt      ||  chr(10)
                                ||'lr_hdr_record.total_threshold_base_amt  ='||lr_hdr_record.total_threshold_base_amt ||  chr(10)
                                ||'lr_hdr_record.creation_date             ='||lr_hdr_record.creation_date            ||  chr(10)
                                ||'lr_hdr_record.created_by                ='||lr_hdr_record.created_by               ||  chr(10)
                                ||'lr_hdr_record.last_update_date          ='||lr_hdr_record.last_update_date         ||  chr(10)
                                ||'lr_hdr_record.last_updated_by           ='||lr_hdr_record.last_updated_by          ||  chr(10)
                                ||'lr_hdr_record.last_update_login         ='||lr_hdr_record.last_update_login        ||  chr(10)
                                );*/ --commented by bgowrava for bug#5631784

        insert_threshold_hdr   (  p_record          =>    lr_hdr_record
                                , p_threshold_id    =>    ln_threshold_id
                                , p_row_id          =>    lx_row_id
                               );

      end if; /** ln_threshold_id is null */


      /**************************************************************************************
      ||Part -2 :- CREATE OR UPDATE TABLE JAI_RGM_THRESHOLD_DTLS
      ***************************************************************************************/
      /**
        Assumption:  When control comes here ln_threshold_id should NOT BE NULL.
      */
      if ln_threshold_id is null then
        p_process_flag    :=  jai_constants.expected_error;
        p_process_message :=  'Cannot create threshold header record in jai_rgm_thresholds';
        return;
      end if;

      /** Initialize record  */
       lr_dtl_record                   := null;
       lr_dtl_record.invoice_amt       := 0;
       lr_dtl_record.cash_receipt_amt  := 0;
       lr_dtl_record.application_amt   := 0;
       lr_dtl_record.unapplication_amt := 0;
       lr_dtl_record.reversal_amt      := 0;
       lr_dtl_record.threshold_base_amt:= 0;

   /*   jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Open/Fetch/Close cursor c_get_threshold_dtl');*/ --commented by bgowrava for bug#5631784

      /** Check if for the given threshold header and item classification a record is already present */
      open  c_get_threshold_dtl    ( cp_threshold_id         => ln_threshold_id
                                   , cp_item_classification  => r_trx_lines.item_classification
                                   );
      fetch c_get_threshold_dtl    into  lr_dtl_record.threshold_dtl_id
                                       , lr_dtl_record.invoice_amt
                                       , lr_dtl_record.cash_receipt_amt
                                       , lr_dtl_record.application_amt
                                       , lr_dtl_record.unapplication_amt
                                       , lr_dtl_record.reversal_amt
                                       , lr_dtl_record.threshold_base_amt
                                       , lr_dtl_record.manual_surcharge_amt
                                       , lr_dtl_record.system_surcharge_amt
                                       , lr_dtl_record.system_surcharge_cess_amt
                                       , lr_dtl_record.system_surcharge_sh_cess_amt; --Bgowrava for forward porting bug#5989740
      close c_get_threshold_dtl ;

   /*   jai_cmn_debug_contexts_pkg.print ( ln_reg_id
                         ,'Before Assignment:'||chr(10)
                          ||'  lr_dtl_record.threshold_dtl_id='||lr_dtl_record.threshold_dtl_id||chr(10)
                          ||', lr_dtl_record.invoice_amt    ='||lr_dtl_record.invoice_amt       ||chr(10)
                          ||', lr_dtl_record.cash_receipt_amt='|| lr_dtl_record.cash_receipt_amt||chr(10)
                          ||', lr_dtl_record.application_amt ='|| lr_dtl_record.application_amt ||chr(10)
                          ||', lr_dtl_record.unapplication_amt='|| lr_dtl_record.unapplication_amt ||chr(10)
                          ||', lr_dtl_record.reversal_amt ='||lr_dtl_record.reversal_amt           ||chr(10)
                          ||', lr_dtl_record.threshold_base_amt='||lr_dtl_record.threshold_base_amt||chr(10)
                          ||', lr_dtl_record.manual_surcharge_amt='||lr_dtl_record.manual_surcharge_amt ||chr(10)
                          ||', lr_dtl_record.system_surcharge_amt='||lr_dtl_record.system_surcharge_amt ||chr(10)
                          ||', lr_dtl_record.system_surcharge_cess_amt='||lr_dtl_record.system_surcharge_cess_amt
                        );	*/ --commented by bgowrava for bug#5631784

      /** Assign value to amount holders based on the source trx (document) type */
      if r_trx_lines.source_document_type    in (jai_constants.trx_type_inv_comp, jai_constants.trx_type_inv_incomp ) then

        lr_dtl_record.invoice_amt    :=    nvl(lr_dtl_record.invoice_amt,0) + r_trx_lines.source_document_amt       ;


      elsif r_trx_lines.source_document_type =  jai_constants.ar_cash_tax_confirmed then

        lr_dtl_record.cash_receipt_amt :=    nvl(lr_dtl_record.cash_receipt_amt,0) + r_trx_lines.source_document_amt;

      elsif r_trx_lines.source_document_type in (jai_constants.trx_type_rct_app , jai_constants.trx_type_cm_app) then

        lr_dtl_record.application_amt  :=    nvl(lr_dtl_record.application_amt,0) + r_trx_lines.source_document_amt;

      elsif r_trx_lines.source_document_type in (jai_constants.trx_type_rct_unapp, jai_constants.trx_type_cm_unapp) then

        lr_dtl_record.unapplication_amt  :=   nvl(lr_dtl_record.unapplication_amt,0) + r_trx_lines.source_document_amt;

      elsif r_trx_lines.source_document_type = jai_constants.trx_type_rct_rvs  then

        lr_dtl_record.reversal_amt       :=  nvl (lr_dtl_record.reversal_amt,0) + r_trx_lines.source_document_amt;

      end if;

      /** Get threshold base amount (sum of tax amount for tcs type of taxes) for current trx line */

  /*    jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Open/Fetch/Close cursor C_GET_REF_THHOLD_BASE_AMT');*/ --commented by bgowrava for bug#5631784
      open  c_get_ref_thhold_base_amt (cp_base_tax_type => jai_constants.tax_type_tcs);
      fetch c_get_ref_thhold_base_amt into ln_ref_thhold_base_amt;
      close c_get_ref_thhold_base_amt;

      lr_dtl_record.threshold_base_amt   :=     nvl (lr_dtl_record.threshold_base_amt,0)
                                              + nvl (ln_ref_thhold_base_amt,0);

      /*---------------------------------------------------------------------------------------------------------------
        Following code is intentionally kept commented.  It can be used whenever there is strong req. to distinguish
        between MANUAL and SYSTEM surcharge
      -----------------------------------------------------------------------------------------------------------------*/

      /** Get manual surcharge amount if any */
      /*jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Open/Fetch/Close cursor C_GET_SURCHARGE_AMT to get MANUAL surcharge');
      open  c_get_surcharge_amt (cp_tax_type        =>  jai_constants.tax_type_tcs_surcharge
                                ,cp_tax_modified_by =>  jai_constants.tax_modified_by_user
                                );
      fetch c_get_surcharge_amt into ln_manual_surcharge_amt;
      close c_get_surcharge_amt ;

      lr_dtl_record.manual_surcharge_amt   :=   nvl (lr_dtl_record.manual_surcharge_amt,0)
                                              + nvl (ln_manual_surcharge_amt,0);
      */
      /** Get system surcharge amount if any */
      /*
      jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Open/Fetch/Close cursor C_GET_SURCHARGE_AMT to get SYSTEM surcharge');
      open  c_get_surcharge_amt (cp_tax_type        =>  jai_constants.tax_type_tcs_surcharge
                                ,cp_tax_modified_by =>  jai_constants.tax_modified_by_system
                                );
      fetch c_get_surcharge_amt into ln_system_surcharge_amt;
      close c_get_surcharge_amt ;

      lr_dtl_record.system_surcharge_amt   :=   nvl (lr_dtl_record.system_surcharge_amt,0)
                                              + nvl (ln_system_surcharge_amt,0);
      */
      /** Get system surcharge cess amount if any */
      /*
      jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Open/Fetch/Close cursor C_GET_SURCHARGE_AMT to get SYSTEM surcharge cess');
      open  c_get_surcharge_amt (cp_tax_type        =>  jai_constants.tax_type_tcs_surcharge_cess
                                ,cp_tax_modified_by =>  jai_constants.tax_modified_by_system
                                );
      fetch c_get_surcharge_amt into ln_system_surcharge_cess_amt;
      close c_get_surcharge_amt ;


      lr_dtl_record.system_surcharge_cess_amt  :=   nvl (lr_dtl_record.system_surcharge_cess_amt,0)
                                                  + nvl (ln_system_surcharge_cess_amt,0);
      */

      /*
      || Get the SURCHARGE tax amount
      */
  /*    jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Open/Fetch/Close cursor C_GET_SURCHARGE_AMT');*/ --commented by bgowrava for bug#5631784
      open  c_get_surcharge_amt (cp_tax_type        =>  jai_constants.tax_type_tcs_surcharge
                                ,cp_tax_modified_by =>  null
                                );
      fetch c_get_surcharge_amt into ln_surcharge_amt;
      close c_get_surcharge_amt ;

      /*
      || Get the SURCHARGE CESS tax amount
      || To get surcharge cess,
      || 1.  First get tax_cat_id for the current threshold_slab_id
      || 2.  Find out tax of type TCS_CESS which has precedence 1 defined as TCS_SURCHARGE
      */

 /*     jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Calling GET_THRESHOLD_TAX_CAT_ID to get tax category for current slab='||lr_hdr_record.threshold_slab_id );*/ --commented by bgowrava for bug#5631784

      if lr_hdr_record.threshold_slab_id is not null then
        jai_rgm_thhold_proc_pkg.get_threshold_tax_cat_id
            (
               p_threshold_slab_id       => lr_hdr_record.threshold_slab_id
            ,  p_org_id                  => r_trx_lines.org_id
            ,  p_threshold_tax_cat_id 	 => ln_thhold_tax_cat_id
            ,  p_process_flag            => p_process_flag
            ,  p_process_message         => p_process_message
            );

        if p_process_flag  <> jai_constants.successful then
          return;
        end if;


        if ln_thhold_tax_cat_id = -1 then
          p_process_flag    := jai_constants.expected_error;
          p_process_message := 'Cannot find tax category for active threshold slab. Please check the threshold setup';
          return;
        end if;

  /*      jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Open/Fetch/Close cursor C_GET_SURCHARGE_CESS');*/ --commented by bgowrava for bug#5631784

        open  c_get_surcharge_cess (cp_thhold_tax_cat_id => ln_thhold_tax_cat_id);
        fetch c_get_surcharge_cess into ln_surcharge_cess_amt;
        close c_get_surcharge_cess;



   -- start 5907436
	         open  c_get_surcharge_sh_cess (cp_thhold_tax_cat_id => ln_thhold_tax_cat_id);
	         fetch c_get_surcharge_sh_cess into ln_surcharge_sh_cess_amt;
	         close c_get_surcharge_sh_cess ;
	 -- end 5907436


      end if;

      /*
      || If current threshold_slab_id is not null means it is a system surcharge. Otherwise (when slab is not applicable) it is a MANUAL
      || surcharge
      */
      if lr_hdr_record.threshold_slab_id is not null then

        lr_dtl_record.system_surcharge_amt   :=   nvl (lr_dtl_record.system_surcharge_amt,0)
                                                + nvl (ln_surcharge_amt,0);

        lr_dtl_record.system_surcharge_cess_amt  :=   nvl (lr_dtl_record.system_surcharge_cess_amt,0)
                                                    + nvl (ln_surcharge_cess_amt,0);

        lr_dtl_record.system_surcharge_sh_cess_amt  :=   nvl (lr_dtl_record.system_surcharge_sh_cess_amt,0)
        					       + nvl (ln_surcharge_sh_cess_amt,0) ; --Bgowrava for forward porting bug#5989740


      else

        lr_dtl_record.manual_surcharge_amt   :=   nvl (lr_dtl_record.manual_surcharge_amt,0)
                                                + nvl (ln_surcharge_amt,0);

      end if;



      lr_dtl_record.threshold_id         :=   ln_threshold_id ;
      lr_dtl_record.item_classification  :=   r_trx_lines.item_classification;
      lr_dtl_record.creation_date        :=   sysdate;
      lr_dtl_record.created_by           :=   ln_user_id;
      lr_dtl_record.last_update_date     :=   sysdate;
      lr_dtl_record.last_updated_by      :=   ln_user_id;
      lr_dtl_record.last_update_login    :=   ln_login_id;


  /*    jai_cmn_debug_contexts_pkg.print
               ( ln_reg_id
               ,'After Assignment: ' ||chr(10)
                ||'  lr_dtl_record.threshold_dtl_id='||lr_dtl_record.threshold_dtl_id         ||chr(10)
                ||', lr_dtl_record.invoice_amt    ='||lr_dtl_record.invoice_amt               ||chr(10)
                ||', lr_dtl_record.cash_receipt_amt='|| lr_dtl_record.cash_receipt_amt        ||chr(10)
                ||', lr_dtl_record.application_amt ='|| lr_dtl_record.application_amt         ||chr(10)
                ||', lr_dtl_record.unapplication_amt='|| lr_dtl_record.unapplication_amt      ||chr(10)
                ||', lr_dtl_record.reversal_amt ='||lr_dtl_record.reversal_amt                ||chr(10)
                ||', lr_dtl_record.threshold_base_amt='||lr_dtl_record.threshold_base_amt     ||chr(10)
                ||', lr_dtl_record.manual_surcharge_amt='||lr_dtl_record.manual_surcharge_amt ||chr(10)
                ||', lr_dtl_record.system_surcharge_amt='||lr_dtl_record.system_surcharge_amt ||chr(10)
                ||', lr_dtl_record.system_surcharge_cess_amt='||lr_dtl_record.system_surcharge_cess_amt||chr(10)
                ||', lr_dtl_record.item_classification='|| lr_dtl_record.item_classification
              ); */ --commented by bgowrava for bug#5631784

      if lr_dtl_record.threshold_dtl_id is null then

        insert_threshold_dtl  ( p_record              =>  lr_dtl_record
                              , p_threshold_dtl_id    =>  ln_threshold_dtl_id
                              , p_row_id              =>  lx_row_id
                              );

      else  /** Threshold detils record already exists.  Hence update the existing record to increment
            per item classificaton amounts */

    /*    jai_cmn_debug_contexts_pkg.print (ln_reg_id
                                ,'Updating JAI_RGM_THRESHOLD_DTLS' || chr(10)
                                ||'invoice_amt               ='||lr_dtl_record.invoice_amt          ||  chr(10)
                                ||'cash_receipt_amt          ='||lr_dtl_record.cash_receipt_amt     ||  chr(10)
                                ||'application_amt           ='||lr_dtl_record.application_amt      ||  chr(10)
                                ||'unapplication_amt         ='||lr_dtl_record.unapplication_amt    ||  chr(10)
                                ||'reversal_amt              ='||lr_dtl_record.reversal_amt         ||  chr(10)
                                ||'manual_surcharge_amt      ='||lr_dtl_record.manual_surcharge_amt ||  chr(10)
                                ||'system_surcharge_amt      ='||lr_dtl_record.system_surcharge_amt ||  chr(10)
                                ||'system_surcharge_cess_amt ='||lr_dtl_record.system_surcharge_cess_amt ||  chr(10)
                                ||'threshold_base_amt        ='||lr_dtl_record.threshold_base_amt   ||  chr(10)
                                ||'last_update_date          ='||sysdate                            ||  chr(10)
                                ||'last_updated_by           ='||ln_user_id                         ||  chr(10)
                                ||'last_update_login         ='||ln_login_id                        ||  chr(10)
                                ||'last_update_login         ='||ln_threshold_dtl_id
                                );	*/ --commented by bgowrava for bug#5631784

        update jai_rgm_threshold_dtls
        set           invoice_amt                 =       lr_dtl_record.invoice_amt
                    , cash_receipt_amt            =       lr_dtl_record.cash_receipt_amt
                    , application_amt             =       lr_dtl_record.application_amt
                    , unapplication_amt           =       lr_dtl_record.unapplication_amt
                    , reversal_amt                =       lr_dtl_record.reversal_amt
                    , manual_surcharge_amt        =       lr_dtl_record.manual_surcharge_amt
                    , system_surcharge_amt        =       lr_dtl_record.system_surcharge_amt
                    , system_surcharge_cess_amt   =       lr_dtl_record.system_surcharge_cess_amt
                    , system_surcharge_sh_cess_amt   =       lr_dtl_record.system_surcharge_sh_cess_amt --Bgowrava for forward porting bug#5989740
                    , threshold_base_amt          =       lr_dtl_record.threshold_base_amt
                    , last_update_date            =       sysdate
                    , last_updated_by             =       ln_user_id
                    , last_update_login           =       ln_login_id
        where       threshold_dtl_id              =       lr_dtl_record.threshold_dtl_id;

      end if;  /** lr_dtl_record.threshold_dtl_id is null */

      if p_last_line_flag = jai_constants.yes then
        /*
        ||  This is the last line of the document, so update the summary amounts maintained by header table.
        ||  As repository package is always making a call at document level (not at line level), this flag will
        ||  always be yes
        */
   /*     jai_cmn_debug_contexts_pkg.print ( ln_reg_id, 'Before : sync_threshold_header'); */ --commented by bgowrava for bug#5631784

        ln_new_thhold_slab_id      := null;
        lv_thhold_slab_change_flag := jai_constants.no;

        sync_threshold_header
                    ( p_threshold_id            => ln_threshold_id
                    , p_source_trx_date         => r_trx_lines.source_document_date
                    , p_thhold_slab_change_flag => lv_thhold_slab_change_flag
                    , p_new_thhold_slab_id      => ln_new_thhold_slab_id
                    , p_process_flag            => p_process_flag
                    , p_process_message         => p_process_message
                    ) ;
  /*      jai_cmn_debug_contexts_pkg.print ( ln_reg_id, 'After: sync_threshold_header');
        jai_cmn_debug_contexts_pkg.print ( ln_reg_id, 'p_process_flag='||p_process_flag||',p_process_message='||p_process_message);*/ --commented by bgowrava for bug#5631784

        if p_process_flag  <> jai_constants.successful then
          return;
        end if;

        /** Update jai_rgm_refs_all to punch the threshold_slab_id against all the transaction lines */

        if ln_new_thhold_slab_id is not null then
          update jai_rgm_refs_all
          set    threshold_slab_id = ln_new_thhold_slab_id
          where  transaction_id    = p_transaction_id;
        end if;

        if lv_thhold_slab_change_flag = jai_constants.yes then
          /**
            The threshold slab has changed hence delegate the call to generate_consolidated_doc.
            Based on the new slab consolidated document needs to be generated which can be either DM or CM.
            The API generate_consolidated_doc will calculate document amount and will decide which document
            to generate.
          */
  /*        jai_cmn_debug_contexts_pkg.print ( ln_reg_id, 'Before : generate_consolidated_doc');*/ --commented by bgowrava for bug#5631784
          generate_consolidated_doc ( p_threshold_id    =>    ln_threshold_id
                                    , p_transaction_id  =>    p_transaction_id
                                    , p_org_id          =>    r_trx_lines.org_id
                                    , p_process_flag    =>    p_process_flag
                                    , p_process_message =>    p_process_message
                                    );
    /*      jai_cmn_debug_contexts_pkg.print ( ln_reg_id, 'After : generate_consolidated_doc');
          jai_cmn_debug_contexts_pkg.print ( ln_reg_id, 'p_process_flag='||p_process_flag||',p_process_message='||p_process_message);*/ --commented by bgowrava for bug#5631784

          if p_process_flag <> jai_constants.successful then
            return;
          end if;

        end if; /** lv_thhold_slab_change_flag = jai_constants.yes */

      end if; /** p_last_line_flag = jai_constants.yes */

    end loop;   /**  r_trx_lines */

   /* jai_cmn_debug_contexts_pkg.print ( ln_reg_id,' MAINTAIN_THRESHOLD completed successfully',jai_cmn_debug_contexts_pkg.summary) ;*/ --commented by bgowrava for bug#5631784
    /** Deregister and return */
    <<deregister_and_return>>
   /* jai_cmn_debug_contexts_pkg.deregister (pn_reg_id => ln_reg_id);*/ --commented by bgowrava for bug#5631784
    return;

  exception

    when others then
      p_process_flag    := jai_constants.unexpected_error;
      p_process_message := lv_context||'->'||sqlerrm;
      jai_cmn_debug_contexts_pkg.print(ln_reg_id,sqlerrm,jai_cmn_debug_contexts_pkg.summary);
      jai_cmn_debug_contexts_pkg.print_stack;

  end maintain_threshold;

  /*------------------------------------------------------------------------------------------------------------*/
   procedure insert_threshold_dtl ( p_record              in          jai_rgm_threshold_dtls%rowtype
                                  , p_threshold_dtl_id    out nocopy  jai_rgm_threshold_dtls.threshold_dtl_id%type
                                  , p_row_id              out nocopy  rowid
                                  )
   is

   begin

    if p_record.threshold_dtl_id is null then
      select  jai_rgm_thresholds_s.nextval
      into    p_threshold_dtl_id
      from    dual;
    end if;
         /** Threshold detail  record does not exists */
        insert into jai_rgm_threshold_dtls
                    ( threshold_dtl_id
                    , threshold_id
                    , item_classification
                    , invoice_amt
                    , cash_receipt_amt
                    , application_amt
                    , unapplication_amt
                    , reversal_amt
                    , manual_surcharge_amt
                    , system_surcharge_amt
                    , system_surcharge_cess_amt
                    , system_surcharge_sh_cess_amt --Bgowrava for forward porting bug#5989740
                    , threshold_base_amt
                    , creation_date
                    , created_by
                    , last_update_date
                    , last_updated_by
                    , last_update_login
                    )
        values
                    (
                      p_threshold_dtl_id
                    , p_record.threshold_id
                    , p_record.item_classification
                    , p_record.invoice_amt
                    , p_record.cash_receipt_amt
                    , p_record.application_amt
                    , p_record.unapplication_amt
                    , p_record.reversal_amt
                    , p_record.manual_surcharge_amt
                    , p_record.system_surcharge_amt
                    , p_record.system_surcharge_cess_amt
                    , p_record.system_surcharge_sh_cess_amt --Bgowrava for forward porting bug#5989740
                    , p_record.threshold_base_amt
                    , p_record.creation_date
                    , p_record.created_by
                    , p_record.last_update_date
                    , p_record.last_updated_by
                    , p_record.last_update_login
                    )
                    returning   rowid
                               ,threshold_dtl_id
                        into    p_row_id
                               ,p_threshold_dtl_id ;
  exception
  when others then
    p_row_id := null;
    p_threshold_dtl_id := null;
    raise;

   end insert_threshold_dtl;
   /*------------------------------------------------------------------------------------------------------------*/
  procedure insert_threshold_hdr   ( p_record          in            jai_rgm_thresholds%rowtype
                                    , p_threshold_id    out nocopy    jai_rgm_thresholds.threshold_id%type
                                    , p_row_id          out nocopy    rowid
                                    )
  is
  begin

    if p_record.threshold_id is null then
      select jai_rgm_thresholds_s.nextval
      into   p_threshold_id
      from   dual;
    end if;

    insert into jai_rgm_thresholds
                ( threshold_id
                , regime_id
                , org_tan_no
                , party_id
                , party_type
                , party_pan_no
                , threshold_slab_id
                , fin_year
                , total_threshold_amt
                , total_threshold_base_amt
                , creation_date
                , created_by
                , last_update_date
                , last_updated_by
                , last_update_login
                )
         values
                ( p_threshold_id
                , p_record.regime_id
                , p_record.org_tan_no
                , p_record.party_id
                , p_record.party_type
                , p_record.party_pan_no
                , p_record.threshold_slab_id
                , p_record.fin_year
                , p_record.total_threshold_amt
                , p_record.total_threshold_base_amt
                , p_record.creation_date
                , p_record.created_by
                , p_record.last_update_date
                , p_record.last_updated_by
                , p_record.last_update_login
                )
                returning   rowid
                           ,threshold_id
                    into    p_row_id
                           ,p_threshold_id ;
  exception
  when others then
    p_row_id := null;
    p_threshold_id := null;
    raise;
  end insert_threshold_hdr;

  /*------------------------------------------------------------------------------------------------------------*/
  procedure sync_threshold_header
              ( p_threshold_id            in            jai_rgm_thresholds.threshold_id%type
              , p_source_trx_date         in            date
              , p_thhold_slab_change_flag out nocopy    varchar2
              , p_new_thhold_slab_id      out nocopy    jai_rgm_thresholds.threshold_slab_id%type
              , p_process_flag            out nocopy    varchar2
              , p_process_message         out nocopy    varchar2
              )

  is
    ln_reg_id           number;
    cursor c_get_thhold_summary
    is
      select sum (   nvl(invoice_amt        ,0)
                   + nvl(cash_receipt_amt   ,0)
                   + nvl(application_amt    ,0)
                   + nvl(unapplication_amt  ,0)
                   + nvl(reversal_amt       ,0)
                  )         total_threshold_amt
            ,sum (   nvl(threshold_base_amt ,0)
                 )          total_threshold_base_amt
      from jai_rgm_threshold_dtls
      where threshold_id = p_threshold_id;

    cursor c_get_thhold_hdr_info
    is
      select regime_id
            ,org_tan_no
            ,party_type
            ,party_id
            ,fin_year
            ,threshold_slab_id
      from  jai_rgm_thresholds
      where threshold_id = p_threshold_id;

    ln_regime_id        jai_rgm_thresholds.regime_id%type;
    lv_org_tan_no       jai_rgm_thresholds.org_tan_no%type;
    lv_party_type       jai_rgm_thresholds.party_type%type;
    ln_party_id         jai_rgm_thresholds.party_id%type;
    ln_fin_year         jai_rgm_thresholds.fin_year%type;

    ln_curr_thhold_slab_id    jai_rgm_thresholds.threshold_slab_id%type;
    ln_new_thhold_slab_id     jai_rgm_thresholds.threshold_slab_id%type;

    ln_total_thhold_amt           jai_rgm_thresholds.total_threshold_amt%type;
    ln_total_thhold_base_amt      jai_rgm_thresholds.total_threshold_base_amt%type;

    ln_user_id                fnd_user.user_id%type := fnd_global.user_id;
    ln_login_id               fnd_logins.login_id%type := fnd_global.login_id;


  begin
    /** Initialize process variables */
    p_process_flag            := jai_constants.successful;
    p_process_message         := null;
    p_thhold_slab_change_flag := jai_constants.no;

    /** Register this procedure for debuging */
    lv_member_name        := 'SYNC_THRESHOLD_HEADER';
    set_debug_context;
  /*  jai_cmn_debug_contexts_pkg.register ( pv_context => lv_context
                               , pn_reg_id  => ln_reg_id
                               ) ;
    jai_cmn_debug_contexts_pkg.print ( ln_reg_id
                            , 'SYNC_THRESHOLD_HEADER Call Parameters:'
                            ||'p_threshold_id='||p_threshold_id
                            ||'p_source_trx_date='||p_source_trx_date
                            ,jai_cmn_debug_contexts_pkg.summary
                            );	 */ --commented by bgowrava for bug#5631784
    /** Fetch the summary information for a particular threshold_id */
    open  c_get_thhold_summary ;
    fetch c_get_thhold_summary into ln_total_thhold_amt
                                  , ln_total_thhold_base_amt;
    close c_get_thhold_summary ;

    ln_total_thhold_amt      := nvl(ln_total_thhold_amt      ,0);
    ln_total_thhold_base_amt := nvl(ln_total_thhold_base_amt ,0);

    update jai_rgm_thresholds
    set    total_threshold_amt      =   ln_total_thhold_amt
          ,total_threshold_base_amt =   ln_total_thhold_base_amt
          ,last_updated_by          =   ln_user_id
          ,last_update_date         =   sysdate
          ,last_update_login        =   ln_login_id
    where threshold_id = p_threshold_id;

  /*  jai_cmn_debug_contexts_pkg.print ( ln_reg_id, 'ln_total_thhold_amt='||ln_total_thhold_amt||', ln_total_thhold_base_amt='||ln_total_thhold_base_amt);*/ --commented by bgowrava for bug#5631784

    /** Updating a threshold amount may change threshold slab */

    /** Fetch threshold header information to call get_thrthe API */
    open  c_get_thhold_hdr_info;
    fetch c_get_thhold_hdr_info into  ln_regime_id
                                     ,lv_org_tan_no
                                     ,lv_party_type
                                     ,ln_party_id
                                     ,ln_fin_year
                                     ,ln_curr_thhold_slab_id;
    close c_get_thhold_hdr_info;

    /** Get what is new threshold_slab_id*/

 /*   jai_cmn_debug_contexts_pkg.print ( ln_reg_id, 'Before JAI_RGM_THHOLD_PROC_PKG.GET_THRESHOLD_SLAB_ID');    */ --commented by bgowrava for bug#5631784
    jai_rgm_thhold_proc_pkg.get_threshold_slab_id
                            (  p_regime_id              =>    ln_regime_id
                             , p_org_tan_no             =>    lv_org_tan_no
                             , p_party_type             =>    lv_party_type
                             , p_party_id               =>    ln_party_id
                             , p_fin_year               =>    ln_fin_year
                             , p_source_trx_date        =>    p_source_trx_date
                             , p_called_from            =>    jai_constants.tcs_event_surcharge
                             , p_threshold_slab_id  		=>    ln_new_thhold_slab_id
                             , p_process_flag           =>    p_process_flag
                             , p_process_message        =>    p_process_message
                            );
  /*  jai_cmn_debug_contexts_pkg.print ( ln_reg_id, 'After JAI_RGM_THHOLD_PROC_PKG.GET_THRESHOLD_SLAB_ID');
    jai_cmn_debug_contexts_pkg.print ( ln_reg_id, 'p_process_flag='||p_process_flag||',p_process_message='||p_process_message);*/ --commented by bgowrava for bug#5631784
    if p_process_flag <> jai_constants.successful then
      return;
    end if;

    p_new_thhold_slab_id      := ln_new_thhold_slab_id;

    if nvl(ln_new_thhold_slab_id,-9999) <> nvl(ln_curr_thhold_slab_id,-9999) then
      /** Slab is changed.  Hence update threshold slab in the jai_rgm_thresholds */
      update jai_rgm_thresholds
      set    threshold_slab_id  =  ln_new_thhold_slab_id
            ,last_update_date   =  sysdate
            ,last_updated_by    =  ln_user_id
            ,last_update_login  =  ln_login_id
      where  threshold_id       =  p_threshold_id;

      p_thhold_slab_change_flag := jai_constants.yes;

    end if;

    /** Deregister and return */
    <<deregister_and_return>>
 /*   jai_cmn_debug_contexts_pkg.deregister (pn_reg_id => ln_reg_id);*/ --commented by bgowrava for bug#5631784
    return;

  exception

    when others then
      p_thhold_slab_change_flag := null;
      p_new_thhold_slab_id      := null;
      p_process_flag    := jai_constants.unexpected_error;
      p_process_message := lv_context||'->'||sqlerrm;
 /*     jai_cmn_debug_contexts_pkg.print(ln_reg_id,sqlerrm,jai_cmn_debug_contexts_pkg.summary);
      jai_cmn_debug_contexts_pkg.print_stack; */ --commented by bgowrava for bug#5631784

  end sync_threshold_header;
  /*------------------------------------------------------------------------------------------------------------*/

end jai_rgm_thhold_proc_pkg;

/
