--------------------------------------------------------
--  DDL for Package Body IGI_IAC_ADJ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_ADJ_PKG" AS
-- $Header: igiiadjb.pls 120.8.12000000.2 2007/10/16 14:17:36 sharoy noship $


    g_debug_adj boolean := FALSE;
    g_output_dir varchar2(255);
    g_debug_log varchar2(255);
    g_debug_output varchar2(255);
    g_debug_print boolean := FALSE;
    g_number number:=0;

    -- global vlaue for allow reval index and prof flag
    g_asset_iac_info                 igi_iac_types.iac_adj_asset_info_tab;
    g_asset_iac_adj_info             igi_iac_types.iac_adj_hist_asset_info;
    g_asset_iac_dist_info            igi_iac_types.iac_adj_dist_info_tab;
    g_category_id_g                  number :=0;
    g_asset_idx1                     binary_integer DEFAULT 0;
    g_dist_idx2                      binary_integer DEFAULT 0;
    g_calling_function               varchar2(250) := 'do_adjustments';

    --===========================FND_LOG.START=====================================

    g_state_level NUMBER	     :=	FND_LOG.LEVEL_STATEMENT;
    g_proc_level  NUMBER	     :=	FND_LOG.LEVEL_PROCEDURE;
    g_event_level NUMBER	     :=	FND_LOG.LEVEL_EVENT;
    g_excep_level NUMBER	     :=	FND_LOG.LEVEL_EXCEPTION;
    g_error_level NUMBER	     :=	FND_LOG.LEVEL_ERROR;
    g_unexp_level NUMBER	     :=	FND_LOG.LEVEL_UNEXPECTED;
    g_path        VARCHAR2(100)      := 'IGI.PLSQL.igiiadjb.igi_iac_adj_pkg.';

    --===========================FND_LOG.END=====================================

-- ======================================================================
-- adjustments
-- ======================================================================
/*=========================================================================+
 | function name:                                                          |
 |    do_adjusments
 |                                                                         |
 | description:                                                            |
 |    this iac  function is to record adjutsments for iac and              |
 |    called from adjutsments api                       .                  |
 |                                                                         |
 +=========================================================================*/

FUNCTION Do_Record_Adjustments(
   p_trans_rec                      fa_api_types.trans_rec_type,
   p_asset_hdr_rec                  fa_api_types.asset_hdr_rec_type,
   p_asset_cat_rec                  fa_api_types.asset_cat_rec_type,
   p_asset_desc_rec                 fa_api_types.asset_desc_rec_type,
   p_asset_type_rec                 fa_api_types.asset_type_rec_type,
   p_asset_fin_rec                  fa_api_types.asset_fin_rec_type,
   p_asset_deprn_rec                fa_api_types.asset_deprn_rec_type,
   p_calling_function               varchar2
) RETURN boolean IS

    -- cursor to get asset category
     CURSOR c_get_category IS
     SELECT asset_category_id
     FROM fa_additions
     WHERE asset_id =p_asset_hdr_rec.asset_id;


     -- to get fa_books previous entry before current adjustment
     CURSOR c_get_fa_book_info(p_book_type_code
                                fa_transaction_headers.book_type_code%TYPE,
                                p_asset_id  fa_transaction_headers.asset_id%TYPE,
                                p_transaction_header_id
                                fa_transaction_headers.transaction_header_id%TYPE ) IS
    SELECT *
    FROM fa_books
    WHERE book_type_code = p_book_type_code
    AND asset_id = p_asset_id
    AND transaction_header_id_out = p_transaction_header_id;


     -- to verify adjustments for an asset in the same period
     CURSOR c_get_asset_adj (p_book_type_code   fa_transaction_headers.book_type_code%TYPE,
                                p_asset_id  fa_transaction_headers.asset_id%TYPE,
                                p_period_counter number) IS
      SELECT *
      FROM igi_iac_adjustments_history
      WHERE book_type_code = p_book_type_code
      AND period_counter = p_period_counter
      AND asset_id = p_asset_id
      AND NVL(active_flag,'N') = 'N' ;

    l_get_asset_adj             c_get_asset_adj%ROWTYPE;
    l_set_of_books_id		    number :=0;
    l_chart_of_accounts_id      number :=0;
    l_currency				    varchar2(5);
    l_precision 			    number:=0;
    l_category_id               number;
    l_amort_period_info         igi_iac_types.prd_rec;
    l_open_period               igi_iac_types.prd_rec;
    l_iac_adjustment_history    igi_iac_adjustments_history%ROWTYPE;
    l_get_fa_book_info          fa_books%ROWTYPE;
    l_last_update_date          date;
    l_last_updated_by           number;
    l_last_update_login         number;
    l_creation_date             date;
    l_created_by                number;
    l_period_rec                fa_api_types.period_rec_type;


    cat_not_defined_failed      EXCEPTION;
    period_info_failed          EXCEPTION;
    book_row_failed             EXCEPTION;
    Multiple_Adjustments        EXCEPTION;
    Amortization_Fiscal_year    EXCEPTION;

    l_path_name VARCHAR2(150) := g_path||'do_record_adjustments';

   /* this function returns true if asset is revalued atleast once in iac else returns false */
     FUNCTION is_asset_revalued_once(p_asset_id igi_iac_asset_balances.asset_id%TYPE,
                        p_book_type_code igi_iac_asset_balances.book_type_code%TYPE )
     RETURN boolean IS
	    /* this function returns true if asset is revalued atleast once in iac else returns false */
      CURSOR c_asset_reval_info IS
      SELECT COUNT(*)
      FROM igi_iac_asset_balances
      WHERE asset_id = p_asset_id
      AND   book_type_code = p_book_type_code ;

      l_reval_count number;

      BEGIN
            	OPEN c_asset_reval_info;
            	FETCH c_asset_reval_info INTO l_reval_count;
            	CLOSE c_asset_reval_info;

            	IF (l_reval_count > 0) THEN
            	    RETURN TRUE;
            	ELSE
            	    RETURN FALSE;
            	END IF;
      END is_asset_revalued_once;

      /* this function checks if the category is attched to the book in iac setup */
       FUNCTION is_iac_cat_book_defined(l_book_type_code varchar2,
                                     l_category_id    number)
       RETURN boolean IS

        CURSOR c_cat_book_defined IS
        SELECT 'x'
        FROM igi_iac_category_books
        WHERE book_type_code = l_book_type_code
        AND   category_id = l_category_id
        AND   ROWNUM = 1;

        l_dummy varchar2(1) DEFAULT NULL;
        BEGIN
            OPEN c_cat_book_defined;
            FETCH c_cat_book_defined INTO l_dummy;

            IF c_cat_book_defined%FOUND THEN
	            CLOSE c_cat_book_defined;
	            RETURN TRUE;
            ELSE
	            CLOSE c_cat_book_defined;
            	RETURN  FALSE;
            END IF;

            EXCEPTION
                WHEN others THEN
                   RETURN FALSE ;
        END is_iac_cat_book_defined;

       PROCEDURE print_parameter_values IS
  	    l_path_name VARCHAR2(150) := g_path||'print_parameter_values';
       BEGIN
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '+paramter values received to do_adjustments');
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     +asset_trans_hdr_rec');
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +transaction_header_id.......... '||p_trans_rec.transaction_header_id );
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +transaction_type_code.......... '||p_trans_rec.transaction_type_code );
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +transaction_date_entered....... '||p_trans_rec.transaction_date_entered );
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +transaction_name............... '||p_trans_rec.transaction_name);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +source_transaction_header_id... '||p_trans_rec.source_transaction_header_id);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +mass_reference_id.............. '|| p_trans_rec.mass_reference_id);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +transaction_subtype............ '|| p_trans_rec.transaction_subtype);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +transaction_key................ '|| p_trans_rec.transaction_key);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +amortization_start_date........ '||p_trans_rec.amortization_start_date);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +calling_interface.............. '||p_trans_rec.calling_interface);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +mass_transaction_id............ '||p_trans_rec.mass_transaction_id);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     +asset_hdr_rec');
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +asset_id....................... '|| p_asset_hdr_rec.asset_id );
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +book_type_code................. '|| p_asset_hdr_rec.book_type_code );
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +set_of_books_id................ '|| p_asset_hdr_rec.set_of_books_id);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +period_of_addition............. '||p_asset_hdr_rec.period_of_addition);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +asset_fin_rec_type');
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +set_of_books_id........................'||p_asset_fin_rec.set_of_books_id);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +date_placed_in_service                                        ........................'||p_asset_fin_rec.date_placed_in_service);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +deprn_start_date             			      ........................'||p_asset_fin_rec.deprn_start_date);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +deprn_method_code            			    ........................'||p_asset_fin_rec. deprn_method_code);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +life_in_months              			      ........................'||p_asset_fin_rec.life_in_months);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +rate_adjustment_factor      			      ........................'||p_asset_fin_rec.rate_adjustment_factor);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +adjusted_cost               			      ........................'||p_asset_fin_rec.adjusted_cost);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +cost                        			      ........................'||p_asset_fin_rec.cost);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +original_cost               			      ........................'||p_asset_fin_rec.original_cost);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +salvage_value               			      ........................'||p_asset_fin_rec.salvage_value);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +prorate_convention_code     			      ........................'||p_asset_fin_rec.prorate_convention_code);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +prorate_date               			      ........................'||p_asset_fin_rec.prorate_date);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +cost_change_flag           			      ........................'||p_asset_fin_rec.cost_change_flag);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +adjustment_required_status 			      ........................'||p_asset_fin_rec.adjustment_required_status);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +capitalize_flag               			      ........................'||p_asset_fin_rec.capitalize_flag);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +retirement_pending_flag      			      ........................'||p_asset_fin_rec.retirement_pending_flag);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +depreciate_flag              			      ........................'||p_asset_fin_rec.depreciate_flag);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +itc_amount_id                			      ........................'||p_asset_fin_rec.itc_amount_id);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +itc_amount                   			      ........................'||p_asset_fin_rec.itc_amount);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +retirement_id                			      ........................'||p_asset_fin_rec.retirement_id);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +tax_request_id               			      ........................'||p_asset_fin_rec.tax_request_id);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +itc_basis                    			      ........................'||p_asset_fin_rec.itc_basis);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +basic_rate                   			      ........................'||p_asset_fin_rec.basic_rate);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +adjusted_rate                			      ........................'||p_asset_fin_rec.adjusted_rate);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +bonus_rule                   			      ........................'||p_asset_fin_rec.bonus_rule);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +ceiling_name                 			      ........................'||p_asset_fin_rec.ceiling_name);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +recoverable_cost             			      ........................'||p_asset_fin_rec.recoverable_cost);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +adjusted_capacity            			      ........................'||p_asset_fin_rec.adjusted_capacity);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +fully_rsvd_revals_counter    			      ........................'||p_asset_fin_rec.fully_rsvd_revals_counter);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +idled_flag                   			      ........................'||p_asset_fin_rec.idled_flag);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +period_counter_capitalized   			      ........................'||p_asset_fin_rec.period_counter_capitalized);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +period_counter_fully_reserved 			      ........................'||p_asset_fin_rec.period_counter_fully_reserved);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +period_counter_fully_retired  			      ........................'||p_asset_fin_rec.period_counter_fully_retired);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +production_capacity           			      ........................'||p_asset_fin_rec.production_capacity);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +reval_amortization_basis      			      ........................'||p_asset_fin_rec.reval_amortization_basis);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +reval_ceiling                 			      ........................'||p_asset_fin_rec.reval_ceiling);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +unit_of_measure               			      ........................'||p_asset_fin_rec.unit_of_measure);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +unrevalued_cost               			      ........................'||p_asset_fin_rec.unrevalued_cost);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +annual_deprn_rounding_flag    			      ........................'||p_asset_fin_rec.annual_deprn_rounding_flag);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +percent_salvage_value         			      ........................'||p_asset_fin_rec.percent_salvage_value);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +allowed_deprn_limit           			      ........................'||p_asset_fin_rec.allowed_deprn_limit);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +allowed_deprn_limit_amount    			      ........................'||p_asset_fin_rec.allowed_deprn_limit_amount);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +period_counter_life_complete  			      ........................'||p_asset_fin_rec.period_counter_life_complete);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +adjusted_recoverable_cost     			      ........................'||p_asset_fin_rec.adjusted_recoverable_cost);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +annual_rounding_flag          			      ........................'||p_asset_fin_rec.annual_rounding_flag);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +eofy_adj_cost                 			      ........................'||p_asset_fin_rec.eofy_adj_cost);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +eofy_formula_factor           			      ........................'||p_asset_fin_rec.eofy_formula_factor);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +short_fiscal_year_flag        			      ........................'||p_asset_fin_rec.short_fiscal_year_flag);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +conversion_date               			      ........................'||p_asset_fin_rec.conversion_date);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +orig_deprn_start_date         			      ........................'||p_asset_fin_rec.orig_deprn_start_date);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +remaining_life1               			      ........................'||p_asset_fin_rec.remaining_life1);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +remaining_life2               			      ........................'||p_asset_fin_rec.remaining_life2);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +group_asset_id                			      ........................'||p_asset_fin_rec.group_asset_id);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +old_adjusted_cost       			      ........................'||p_asset_fin_rec.old_adjusted_cost);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +formula_factor                             ........................'||p_asset_fin_rec.formula_factor );
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     +asset_deprn_rec_type');
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +set_of_books_id           			       ........................'||p_asset_deprn_rec.set_of_books_id);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +deprn_amount             			      ........................'||p_asset_deprn_rec.deprn_amount);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +ytd_deprn               			      ........................'||p_asset_deprn_rec.ytd_deprn);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +deprn_reserve           			      ........................'||p_asset_deprn_rec.deprn_reserve);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +prior_fy_expense        			      ........................'||p_asset_deprn_rec.prior_fy_expense);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +bonus_deprn_amount      			      ........................'||p_asset_deprn_rec.bonus_deprn_amount);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +bonus_ytd_deprn         			      ........................'||p_asset_deprn_rec.bonus_ytd_deprn);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +bonus_deprn_reserve     			      ........................'||p_asset_deprn_rec.bonus_deprn_reserve);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +prior_fy_bonus_expense  			      ........................'||p_asset_deprn_rec.prior_fy_bonus_expense);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +reval_amortization      			      ........................'||p_asset_deprn_rec.reval_amortization);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +reval_amortization_basis			      ........................'||p_asset_deprn_rec.reval_amortization_basis);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +reval_deprn_expense     			      ........................'||p_asset_deprn_rec.reval_deprn_expense);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +reval_ytd_deprn         			      ........................'||p_asset_deprn_rec.reval_ytd_deprn);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +reval_deprn_reserve     			      ........................'||p_asset_deprn_rec.reval_deprn_reserve);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +production              			      ........................'||p_asset_deprn_rec.production);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +ytd_production          			      ........................'||p_asset_deprn_rec.ytd_production);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +ltd_production                        			      ........................'||p_asset_deprn_rec.ltd_production);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     +asset_type_rec');
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +asset_type..................... '|| p_asset_type_rec.asset_type );
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     +calling function................... ' || p_calling_function);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '+paramter values received to do_adjustments');
    END;

   BEGIN -- do_record_adjustments

       IF fnd_profile.value('PRINT_DEBUG') = 'Y'  THEN
           SELECT SUBSTR(VALUE,1,DECODE ((INSTR(VALUE,',', 1, 1)-1),0,LENGTH(VALUE)
                    ,(INSTR(VALUE,',', 1, 1)-1)))
                   INTO g_output_dir
             FROM v$parameter
                WHERE name LIKE 'utl%';
                g_debug_log := 'iacadj.log';
                g_debug_output := 'iacadj.out';
                g_debug_print := TRUE;
        ELSE
               g_debug_print := FALSE;
        END IF;

  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'creating a message log file for adjustments');
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'calling function '||p_calling_function);

       --validate the iac book
        IF NOT (igi_iac_common_utils.is_iac_book(p_asset_hdr_rec.book_type_code)) THEN
  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'not an iac book ..'||p_asset_hdr_rec.book_type_code);
                RETURN TRUE;
        END IF;

        -- check if the adjusment is in period of addition
        IF ( p_asset_hdr_rec.period_of_addition ='Y') THEN
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'No iac adjustments required since current period addition');
            RETURN TRUE;
        END IF ;

        -- check if asset is revalued atleast ocnce to verify asset is in place in iac

         IF  NOT  is_asset_revalued_once(p_asset_hdr_rec.asset_id,p_asset_hdr_rec.book_type_code) THEN
  	       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		    	 	p_full_path => l_path_name,
		     		p_string => 'Asset not revalued by iac');
               FA_SRVR_MSG.Add_Message(
                          CALLING_FN => p_calling_function,
                          NAME => 'IGI_IAC_NO_IAC_EFFECT',
                          TRANSLATE => TRUE,
                          APPLICATION => 'IGI');
               RETURN TRUE;
        END IF;

        -- debug messages
        print_parameter_values;

        OPEN c_get_category;
        FETCH c_get_category INTO l_category_id;
        CLOSE c_get_category;

        -- validate category
        g_category_id_g := l_category_id;
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'category id .... '|| g_category_id_g);
        IF NOT is_iac_cat_book_defined(p_asset_hdr_rec.book_type_code,
                                        g_category_id_g) THEN

  	    igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     		p_full_path => l_path_name,
		     		p_string => '*** error the category is not set up for book in iac options');
            RAISE cat_not_defined_failed;
        END IF;

        IF NOT igi_iac_common_utils.get_open_period_info(p_asset_hdr_rec.book_type_code,
                                                                         l_open_period) THEN
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     		p_full_path => l_path_name,
		     		p_string => '*** error in fetching open period info for book');
            RAISE period_info_failed;
        END IF;
        l_iac_adjustment_history.current_period_amortization:=NULL;

         IF  (p_trans_rec.transaction_subtype = 'AMORTIZED') THEN

            -- Prevent backdate amortizations to previous fiscal year

             IF NOT igi_iac_common_utils.get_period_info_for_date( p_asset_hdr_rec.book_type_code ,
                                                     p_trans_rec.amortization_start_date,
                                                     l_amort_period_info
                                                     )     THEN
  		igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     		p_full_path => l_path_name,
		     		p_string => '*** error in fetching period info');
                RAISE period_info_failed;
            END IF;

            IF  (l_open_period.fiscal_year <> l_amort_period_info.fiscal_year) THEN
  	       igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     		p_full_path => l_path_name,
		     		p_string => 'amortization adjustment backdate previous fiscal year');
                -- not in same year raise exception
                 RAISE amortization_fiscal_year;
            END IF;

            IF (l_open_period.period_counter=l_amort_period_info.period_counter) THEN
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'current period amortization not processed by iac');
             -- set the current flag;
             l_iac_adjustment_history.current_period_amortization := 'Y';
           END IF;
        END IF;

        OPEN c_get_fa_book_info(p_asset_hdr_rec.book_type_code,
                                p_asset_hdr_rec.asset_id,
                                p_trans_rec.transaction_header_id);
        FETCH c_get_fa_book_info INTO l_get_fa_book_info;
         IF c_get_fa_book_info%NOTFOUND THEN
  	       igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     		p_full_path => l_path_name,
		     		p_string => '*** error cannot find record in fa_book');
              CLOSE c_get_fa_book_info;
              RAISE book_row_failed;
         END IF;
         CLOSE c_get_fa_book_info;

         -- verify if cost adjustment
            IF p_asset_fin_rec.cost <> l_get_fa_book_info.cost THEN
              -- set the cost adjustment
              l_iac_adjustment_history.adjustment_reval_type := 'C';
            ELSE
              l_iac_adjustment_history.adjustment_reval_type := 'D';
            END IF;

            l_iac_adjustment_history.book_type_code:=  p_asset_hdr_rec.book_type_code;
            l_iac_adjustment_history.asset_id:= p_asset_hdr_rec.asset_id;
            l_iac_adjustment_history.category_id:=  l_category_id;
            l_iac_adjustment_history.date_placed_in_service:=p_asset_fin_rec.date_placed_in_service;
            l_iac_adjustment_history.period_counter:=  l_open_period.period_counter;
            l_iac_adjustment_history.transaction_type_code:=p_trans_rec.transaction_type_code;
            l_iac_adjustment_history.transaction_subtype  :=p_trans_rec.transaction_subtype;
            l_iac_adjustment_history.amortization_start_date:=p_trans_rec.amortization_start_date;
            l_iac_adjustment_history.transaction_header_id_in :=p_trans_rec.transaction_header_id;
            l_iac_adjustment_history.transaction_header_id_out:=NULL;
            l_iac_adjustment_history.pre_life_in_months:=l_get_fa_book_info.life_in_months;
            l_iac_adjustment_history.pre_rate_adjustment_factor:=l_get_fa_book_info.rate_adjustment_factor;
            l_iac_adjustment_history.pre_adjusted_cost:=l_get_fa_book_info.cost;
            l_iac_adjustment_history.pre_salvage_value:=l_get_fa_book_info.salvage_value;
            l_iac_adjustment_history.life_in_months:=p_asset_fin_rec.life_in_months;
            l_iac_adjustment_history.rate_adjustment_factor:=p_asset_fin_rec.rate_adjustment_factor;
            l_iac_adjustment_history.adjusted_cost:=p_asset_fin_rec.cost;
            l_iac_adjustment_history.salvage_value:=p_asset_fin_rec.salvage_value;
            l_iac_adjustment_history.adjustment_id:=NULL;
            l_iac_adjustment_history.active_flag:=NULL;

  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'adjustment details .....');
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'book_type_code..........'|| l_iac_adjustment_history.book_type_code);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'asset_id................'|| l_iac_adjustment_history.asset_id      );
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'category_id.............'|| l_iac_adjustment_history.category_id     );
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'date_placed_in_service..'||l_iac_adjustment_history.date_placed_in_service);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'period_counter..........'||l_iac_adjustment_history.period_counter          );
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'transaction_type_code...'||l_iac_adjustment_history.transaction_type_code     );
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'transaction_subtype.....'||l_iac_adjustment_history.transaction_subtype         );
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'current_period_amortization'||l_iac_adjustment_history.current_period_amortization);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'amortization_start_date....'||l_iac_adjustment_history.amortization_start_date      );
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'transaction_header_id_in....'||l_iac_adjustment_history.transaction_header_id_in      );
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'transaction_header_id_out...'|| l_iac_adjustment_history.transaction_header_id_out      );
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'pre_life_in_months..........'|| l_iac_adjustment_history.pre_life_in_months            );
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'pre_rate_adjustment_factor..'||l_iac_adjustment_history.pre_rate_adjustment_factor     );
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'pre_adjusted_cost...........'||l_iac_adjustment_history.pre_adjusted_cost              );
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'pre_salvage_value...........'||l_iac_adjustment_history.pre_salvage_value              );
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'life_in_months..............'||l_iac_adjustment_history.life_in_months                 );
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'rate_adjustment_factor......'||l_iac_adjustment_history.rate_adjustment_factor         );
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'adjusted_cost...............'||l_iac_adjustment_history.adjusted_cost                  );
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'salvage_value...............'||l_iac_adjustment_history.salvage_value                  );
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'adjustment_id...............'||l_iac_adjustment_history.adjustment_id                  );
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'active_flag.................'||l_iac_adjustment_history.active_flag                  );
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'Reval type.................'||l_iac_adjustment_history.adjustment_reval_type     );

            OPEN c_get_asset_adj( l_iac_adjustment_history.book_type_code,
                                  l_iac_adjustment_history.asset_id,
                                   l_iac_adjustment_history.period_counter);
            FETCH c_get_asset_adj INTO l_get_asset_adj;
            IF    c_get_asset_adj%FOUND THEN

                    CLOSE c_get_asset_adj;
                     IF  (p_trans_rec.transaction_subtype = 'AMORTIZED') AND
                         (l_get_asset_adj.transactioN_subtype='EXPENSED') THEN

  			 igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     			p_full_path => l_path_name,
		     			p_string => 'Amortization and Expensed adjustments are not allowed in same period');
                         RAISE multiple_adjustments;
                     END IF;

                     IF l_get_asset_adj.adjustment_reval_type = 'C'  THEN
                          -- set the cost adjustment
                           l_iac_adjustment_history.adjustment_reval_type := 'C';
                    END IF;

                     UPDATE igi_iac_adjustments_history
                     SET active_flag = 'Y'
                     WHERE asset_id = l_iac_adjustment_history.asset_id
                     AND book_type_code =l_iac_adjustment_history.book_type_code
                     AND period_counter = l_iac_adjustment_history.period_counter;
             ELSE
                    CLOSE c_get_asset_adj;
             END IF;

            l_last_update_date := SYSDATE;
            l_creation_date    := SYSDATE;
            l_created_by       := fnd_global.user_id;
           IF (l_created_by IS NULL) THEN
                 l_created_by    := -1;
           END IF;
           l_last_updated_by := fnd_global.user_id;
           IF (l_last_updated_by IS NULL) THEN
                l_last_updated_by := -1;
           END IF;
           l_last_update_login := fnd_global.login_id;
           IF (l_last_update_login IS NULL) THEN
            l_last_update_login := -1;
           END IF;

            INSERT INTO igi_iac_adjustments_history
            (book_type_code,
            asset_id        ,
            category_id      ,
            date_placed_in_service,
            period_counter        ,
            transaction_type_code  ,
            transaction_subtype     ,
            current_period_amortization,
            amortization_start_date    ,
            transaction_header_id_in    ,
            transaction_header_id_out   ,
            pre_life_in_months          ,
            pre_rate_adjustment_factor  ,
            pre_adjusted_cost           ,
            pre_salvage_value            ,
            life_in_months               ,
            rate_adjustment_factor       ,
            adjusted_cost                ,
            salvage_value                ,
            adjustment_id                ,
            active_flag,
            created_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            adjustment_reval_type
            )
            VALUES
            (l_iac_adjustment_history.book_type_code,
            l_iac_adjustment_history.asset_id        ,
            l_iac_adjustment_history.category_id      ,
            l_iac_adjustment_history.date_placed_in_service,
            l_iac_adjustment_history.period_counter         ,
            l_iac_adjustment_history.transaction_type_code,
            l_iac_adjustment_history.transaction_subtype,
            l_iac_adjustment_history.current_period_amortization,
            l_iac_adjustment_history.amortization_start_date,
            l_iac_adjustment_history.transaction_header_id_in,
            l_iac_adjustment_history.transaction_header_id_out,
            l_iac_adjustment_history.pre_life_in_months,
            l_iac_adjustment_history.pre_rate_adjustment_factor,
            l_iac_adjustment_history.pre_adjusted_cost,
            l_iac_adjustment_history.pre_salvage_value,
            l_iac_adjustment_history.life_in_months,
            l_iac_adjustment_history.rate_adjustment_factor,
            l_iac_adjustment_history.adjusted_cost,
            l_iac_adjustment_history.salvage_value,
            l_iac_adjustment_history.adjustment_id,
            l_iac_adjustment_history.active_flag,
            l_creation_date,
            l_created_by,
            l_last_update_date,
            l_last_updated_by,
            l_last_update_login,
            l_iac_adjustment_history.adjustment_reval_type);

        RETURN TRUE;

       --  return false;

        EXCEPTION

        WHEN Amortization_fiscal_year THEN
                FA_SRVR_MSG.Add_Message(
                          CALLING_FN => p_calling_function,
                          NAME => 'IGI_IAC_AMORT_NOT_FISCAL_YEAR',
                          TRANSLATE => TRUE,
                          APPLICATION => 'IGI');

           RETURN FALSE;

        WHEN Multiple_Adjustments  THEN

             FA_SRVR_MSG.Add_Message(
                          CALLING_FN => p_calling_function,
                          NAME => 'IGI_IAC_NO_MULTIPLE_TYPE_ADJ',
                          TRANSLATE => TRUE,
                          APPLICATION => 'IGI');
             RETURN FALSE;

         WHEN period_info_failed THEN
          fa_srvr_msg.add_message(
	                calling_fn 	=> p_calling_function ,
        	        name 		=> 'IGI_IAC_EXCEPTION',
        	        token1		=> 'PACKAGE',
        	        value1		=> 'adjustments',
        	        token2		=> 'ERROR_MESSAGE',
        	        value2		=> 'Error while getting period information for record',
                    TRANSLATE => TRUE,
                    application => 'IGI');
             RETURN FALSE;

        WHEN book_row_failed THEN
          fa_srvr_msg.add_message(
	                calling_fn 	=> p_calling_function ,
        	        name 		=> 'IGI_IAC_EXCEPTION',
        	        token1		=> 'PACKAGE',
        	        value1		=> 'adjustments',
        	        token2		=> 'ERROR_MESSAGE',
        	        value2		=> 'Error while fetching the books row prior to adjustment',
                    TRANSLATE => TRUE,
                    application => 'IGI');
             RETURN FALSE;

       WHEN cat_not_defined_failed THEN
          fa_srvr_msg.add_message(
	                calling_fn 	=> p_calling_function ,
        	        name 		=> 'IGI_IAC_EXCEPTION',
        	        token1		=> 'PACKAGE',
        	        value1		=> 'adjustments',
        	        token2		=> 'ERROR_MESSAGE',
        	        value2		=> 'Category not defined for Inflation Accounting',
                    TRANSLATE => TRUE,
                    application => 'IGI');
             RETURN FALSE;

         WHEN others THEN
                  fa_srvr_msg.add_message(
	                calling_fn 	=> p_calling_function ,
        	        name 		=> 'IGI_IAC_EXCEPTION',
        	        token1		=> 'PACKAGE',
        	        value1		=> 'adjustments',
        	        token2		=> 'ERROR_MESSAGE',
        	        value2		=> 'Error while recording adjustments in Inflation Accounting',
                    TRANSLATE => TRUE,
                    application => 'IGI');
             RETURN FALSE;

END do_record_adjustments;


FUNCTION Prepare_Adjustment(p_book_type_code igi_iac_det_balances.book_type_code%TYPE,
                               p_period_counter igi_iac_det_balances.period_counter%TYPE,
                               p_asset_id       igi_iac_det_balances.asset_id%TYPE,
                               p_adjustment_type igi_iac_adjustments_history.transaction_subtype%TYPE
                               ,p_asset_iac_adj_info  IN OUT NOCOPY igi_iac_types.iac_adj_hist_asset_info
                               ,p_asset_dist_iac_adj_info IN OUT NOCOPY igi_iac_types.iac_adj_dist_info_tab
                               ,p_asset_adj_hist_info  igi_iac_adjustments_history%ROWTYPE)

                               RETURN boolean IS

     CURSOR c_get_fa_book_info(p_book_type_code   fa_transaction_headers.book_type_code%TYPE,
                               p_asset_id  fa_transaction_headers.asset_id%TYPE
                                ) IS
         SELECT *
         FROM fa_books
         WHERE book_type_code = p_book_type_code
         AND asset_id = p_asset_id
         AND transaction_header_id_out IS NULL;

     CURSOR c_get_fa_headers_info(p_book_type_code   fa_transaction_headers.book_type_code%TYPE,
                               p_asset_id  fa_transaction_headers.asset_id%TYPE,
                               p_transaction_header_id fa_transaction_headers.transaction_header_id%TYPE
                                ) IS
         SELECT *
         FROM fa_transaction_headers
         WHERE book_type_code = p_book_type_code
         AND asset_id = p_asset_id
         AND transaction_header_id = p_transaction_header_id;

      CURSOR c_get_fa_deprn_summary(p_book_type_code   fa_transaction_headers.book_type_code%TYPE,
                                    p_asset_id          fa_transaction_headers.asset_id%TYPE,
                                    p_period_counter   fa_deprn_summary.period_counter%TYPE
                                ) IS
         SELECT *
         FROM fa_deprn_summary
         WHERE book_type_code = p_book_type_code
         AND asset_id = p_asset_id
         AND period_counter = p_period_counter;

      CURSOR  c_get_sum_fa_deprn(p_book_type_code   fa_transaction_headers.book_type_code%TYPE,
                                    p_asset_id          fa_transaction_headers.asset_id%TYPE,
                                    p_period_counter   fa_deprn_summary.period_counter%TYPE
                                ) IS
      SELECT SUM(nvl(deprn_amount,0)) depreciation_amount,
            SUM(nvl(deprn_adjustment_amount,0)) depreciation_adjustment_amount,
            SUM(nvl(deprn_reserve,0)) depreciation_reserve
      FROM fa_deprn_detail
      WHERE book_type_code = p_book_type_code
      AND asset_id = p_asset_id
      AND period_counter = p_period_counter;


      CURSOR c_get_fa_deprn_detail
      IS
         SELECT *
         FROM fa_deprn_detail
         WHERE book_type_code = p_book_type_code
         AND asset_id = p_asset_id
         AND period_counter = p_period_counter;


        l_get_fa_book_info         c_get_fa_book_info%ROWTYPE;
        l_get_fa_deprn_summary     c_get_fa_deprn_summary%ROWTYPE;
--        p_asset_iac_adj_info       igi_iac_types.iac_adj_hist_asset_info;
        l_get_fa_deprn_detail      c_get_fa_deprn_detail%ROWTYPE;
        l_get_fa_headers_info      c_get_fa_headers_info%ROWTYPE;
        l_adj_prd_rec              igi_iac_types.prd_rec;
        l_get_sum_fa_deprn         c_get_sum_fa_deprn%ROWTYPE;

        l_path_name VARCHAR2(150) := g_path||'prepare_adjustment';

        PROCEDURE debug_adj_asset(p_asset igi_iac_types.iac_adj_hist_asset_info) IS
    	       l_path_name VARCHAR2(150) := g_path||'debug_adj_asset';
            BEGIN
  	       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'prepare adj:asset_id...............'|| p_asset.asset_id);
  	       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'prepare adj:book_type_code.........'|| p_asset.book_type_code);
  	       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'prepare adj:cost...................'|| p_asset.cost );
  	       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'prepare adj:original_cost..........'|| p_asset.original_cost);
  	       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'prepare adj:adjusted_cost..........'|| p_asset.adjusted_cost );
  	       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'prepare adj:salvage_value..........'|| p_asset.salvage_value );
  	       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'prepare adj:life_in_months.........'|| p_asset.life_in_months);
  	       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'prepare adj:rate_adjustment_factor..'||p_asset.rate_adjustment_factor);
  	       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'prepare adj:period_counter_fully_reserved '|| p_asset.period_counter_fully_reserved);
  	       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'prepare adj:recoverable_cost.......'|| p_asset.recoverable_cost);
  	       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'prepare adj:date_placed_in_service..'||p_asset.date_placed_in_service);
  	       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'prepare adj:deprn_start_date........'||p_asset.deprn_start_date);
  	       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'prepare adj:deprn_periods_elapsed...'||p_asset.deprn_periods_elapsed);
  	       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'prepare adj:deprn_periods_current_year..'||p_asset.deprn_periods_current_year);
  	       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'prepare adj: prior year periods..'|| p_asset.deprn_periods_prior_year);
  	       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'prepare adj:last_period_counter.........'|| p_asset.last_period_counter);
  	       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'prepare adj:ytd_deprn...................'|| p_asset.ytd_deprn);
  	       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'prepare adj:deprn_reserve................'|| p_asset.deprn_reserve);
  	       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'prepare adj:pys_deprn_reserve............'|| p_asset.pys_deprn_reserve);
  	       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'prepare adj:deprn_amount................'|| p_asset.deprn_amount);
  	       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'prepare adj:depreciate_flag................'|| p_asset.depreciate_flag);
  	       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'prepare adj:deprn_adjustment_amount................'|| p_asset.deprn_adjustment_amount);

          END debug_adj_asset;
    BEGIN -- prepare adjustments
       g_asset_idx1:=0;
       g_dist_idx2 :=0;

       OPEN c_get_fa_book_info(p_book_type_code,p_asset_id);
       FETCH c_get_fa_book_info INTO l_get_fa_book_info;
        IF c_get_fa_book_info%NOTFOUND THEN
  	       igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     	p_full_path => l_path_name,
		    	 p_string => '*** error cannot find record in fa_book');
              CLOSE c_get_fa_book_info;
              RETURN FALSE;
        END IF;

        CLOSE c_get_fa_book_info;

       g_asset_idx1:=g_asset_idx1 +1;


       p_asset_iac_adj_info.asset_id := l_get_fa_book_info.asset_id;
       p_asset_iac_adj_info.book_type_code := l_get_fa_book_info.book_type_code;
       p_asset_iac_adj_info.cost := l_get_fa_book_info.cost;
       p_asset_iac_adj_info.original_cost := l_get_fa_book_info.original_cost;
       p_asset_iac_adj_info.adjusted_cost := l_get_fa_book_info.adjusted_cost;
       p_asset_iac_adj_info.salvage_value := l_get_fa_book_info.salvage_value;
       p_asset_iac_adj_info.life_in_months := l_get_fa_book_info.life_in_months;
       p_asset_iac_adj_info.rate_adjustment_factor := l_get_fa_book_info.rate_adjustment_factor;
       p_asset_iac_adj_info.period_counter_fully_reserved := l_get_fa_book_info.period_counter_fully_reserved;
       p_asset_iac_adj_info.recoverable_cost := l_get_fa_book_info.recoverable_cost;
       p_asset_iac_adj_info.date_placed_in_service  := l_get_fa_book_info.date_placed_in_service;
       p_asset_iac_adj_info.deprn_start_date:=l_get_fa_book_info.deprn_start_date;
       p_asset_iac_adj_info.last_period_counter :=p_period_counter;
       p_asset_iac_adj_info.deprn_amount:=0;
       p_asset_iac_adj_info.depreciate_flag:=l_get_fa_book_info.depreciate_flag;
       p_asset_iac_adj_info.deprn_adjustment_amount:=0;
       p_asset_iac_adj_info.deprn_periods_elapsed := 0;
       p_asset_iac_adj_info.deprn_periods_current_year :=0;
       p_asset_iac_adj_info.ytd_deprn:=0;
       p_asset_iac_adj_info.deprn_reserve:=0;
       p_asset_iac_adj_info.pys_deprn_reserve:=0;


       debug_adj_asset( p_asset_iac_adj_info);

       IF p_asset_iac_adj_info.depreciate_flag = 'YES' THEN

        IF p_adjustment_type = 'AMORTIZED'  THEN

              OPEN c_get_sum_fa_deprn (p_book_type_code,p_asset_id,p_period_counter);
               FETCH c_get_sum_fa_deprn INTO l_get_sum_fa_deprn;
                IF c_get_sum_fa_deprn%NOTFOUND THEN
  		     igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     		p_full_path => l_path_name,
		     		p_string => 'prepare adj:*** error cannot find record in fa_book');
                      CLOSE c_get_sum_fa_deprn;
                      RETURN FALSE;
                 ELSE
  		       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     			p_full_path => l_path_name,
		     			p_string => 'prepare adj: fa deprn summary');
                 END IF;
                 CLOSE c_get_sum_fa_deprn;
                 p_asset_iac_adj_info.deprn_adjustment_amount:=l_get_sum_fa_deprn.depreciation_adjustment_amount;
                 p_asset_iac_adj_info.deprn_amount := l_get_sum_fa_deprn.depreciation_amount;
                 p_asset_iac_adj_info.deprn_reserve := l_get_sum_fa_deprn.depreciation_reserve;
                 /* salvage value correction */
                  If l_get_fa_book_info.salvage_value <> 0 Then
  			igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     			p_full_path => l_path_name,
		     			p_string => '     FA Deprn adj amount for period before salvage correction:'||p_asset_iac_adj_info.deprn_adjustment_amount);
                        IF NOT igi_iac_salvage_pkg.correction(p_asset_id => l_get_fa_book_info.asset_id,
                                                      P_book_type_code =>l_get_fa_book_info.book_type_code,
                                                      P_value=>p_asset_iac_adj_info.deprn_adjustment_amount,
                                                      P_cost=>l_get_fa_book_info.cost,
                                                      P_salvage_value=>l_get_fa_book_info.salvage_value,
                                                      P_calling_program=>'ADJUSTMENTS') THEN
  			     igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     			p_full_path => l_path_name,
		     			p_string => '+Salvage Value Correction Failed : ');
                             return false;
                        END IF;
  			igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     			p_full_path => l_path_name,
		     			p_string => '     FA Deprn adj amount for period after salvage correction:'||p_asset_iac_adj_info.deprn_adjustment_amount);
                END IF;
            /* salvage value correction */


        ELSIF p_adjustment_type = 'EXPENSED' THEN

              OPEN c_get_fa_deprn_summary(p_book_type_code,p_asset_id,p_period_counter);
               FETCH c_get_fa_deprn_summary INTO l_get_fa_deprn_summary;
                IF c_get_fa_deprn_summary%NOTFOUND THEN
  		     igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     			p_full_path => l_path_name,
		     			p_string => 'prepare adj:*** error cannot find record in fa_book');
                      CLOSE c_get_fa_deprn_summary;
                      RETURN FALSE;
                 ELSE
  		       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     			p_full_path => l_path_name,
		     			p_string => 'prepare adj: fa deprn summary');
                 END IF;
                   CLOSE c_get_fa_deprn_summary;
          p_asset_iac_adj_info.deprn_reserve:=l_get_fa_deprn_summary.deprn_reserve - l_get_fa_deprn_summary.system_deprn_amount;
          p_asset_iac_adj_info.deprn_amount:=l_get_fa_deprn_summary.system_deprn_amount;
          /* salvage value correction */
           If l_get_fa_book_info.salvage_value <> 0 Then
  			igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     			p_full_path => l_path_name,
		     			p_string => '     FA Deprn reserve amount for period before salvage correction:'||p_asset_iac_adj_info.deprn_reserve);
                           IF NOT igi_iac_salvage_pkg.correction(p_asset_id => l_get_fa_book_info.asset_id,
                                                        P_book_type_code =>l_get_fa_book_info.book_type_code,
                                                    P_value=>p_asset_iac_adj_info.deprn_reserve,
                                                          P_cost=>l_get_fa_book_info.cost,
                                                      P_salvage_value=>l_get_fa_book_info.salvage_value,
                                                      P_calling_program=>'ADJUSTMENTS') THEN
  			     igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     			p_full_path => l_path_name,
		     			p_string => '+Salvage Value Correction Failed : ');
                             return false;
                        END IF;
  			igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     			p_full_path => l_path_name,
		     			p_string => '     FA Deprn reserve amount for period after salvage correction:'||p_asset_iac_adj_info.deprn_reserve);
  			igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     			p_full_path => l_path_name,
		     			p_string => '     FA Deprn  amount for period before salvage correction:'||p_asset_iac_adj_info.deprn_amount);
                        IF NOT igi_iac_salvage_pkg.correction(p_asset_id => l_get_fa_book_info.asset_id,
                                                      P_book_type_code =>l_get_fa_book_info.book_type_code,
                                                      P_value=>p_asset_iac_adj_info.deprn_amount,
                                                      P_cost=>l_get_fa_book_info.cost,
                                                      P_salvage_value=>l_get_fa_book_info.salvage_value,
                                                      P_calling_program=>'ADJUSTMENTS') THEN
  			     igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     			p_full_path => l_path_name,
		     			p_string => '+Salvage Value Correction Failed : ');
                             return false;
                        END IF;
  			igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     			p_full_path => l_path_name,
		     			p_string => '     FA Deprn  amount for period after salvage correction:'||p_asset_iac_adj_info.deprn_amount);

                END IF;
            /* salvage value correction */

       END IF;

      END IF;

       debug_adj_asset( p_asset_iac_adj_info);


       --- get the distributions and for the asset from fa_deprn_detail

       FOR l_get_fa_deprn_detail IN c_get_fa_deprn_detail
       LOOP
          -- increment the index and copy the details into pl/sql table
          g_dist_idx2:=g_dist_idx2 + 1;

          p_asset_dist_iac_adj_info(g_dist_idx2).asset_id:=l_get_fa_deprn_detail.asset_id;
          p_asset_dist_iac_adj_info(g_dist_idx2).book_type_code:=l_get_fa_deprn_detail.book_type_code;
          p_asset_dist_iac_adj_info(g_dist_idx2).distribution_id:=l_get_fa_deprn_detail.distribution_id;
          p_asset_dist_iac_adj_info(g_dist_idx2).period_counter :=l_get_fa_deprn_detail.period_counter;

          p_asset_dist_iac_adj_info(g_dist_idx2).deprn_amount :=l_get_fa_deprn_detail.deprn_amount;
          p_asset_dist_iac_adj_info(g_dist_idx2).ytd_deprn :=l_get_fa_deprn_detail.ytd_deprn;
          p_asset_dist_iac_adj_info(g_dist_idx2).deprn_reserve :=l_get_fa_deprn_detail.deprn_reserve;
          p_asset_dist_iac_adj_info(g_dist_idx2).deprn_adjustment_amount :=l_get_fa_deprn_detail.deprn_adjustment_amount;

          p_asset_dist_iac_adj_info(g_dist_idx2).deprn_periods_elapsed :=0;
          p_asset_dist_iac_adj_info(g_dist_idx2).deprn_periods_current_year :=0;
          p_asset_dist_iac_adj_info(g_dist_idx2).deprn_periods_prior_year :=0;
          p_asset_dist_iac_adj_info(g_dist_idx2).start_period_counter := 0;
          p_asset_dist_iac_adj_info(g_dist_idx2).last_period_counter :=0;
          p_asset_dist_iac_adj_info(g_dist_idx2).pys_deprn_reserve :=0;
          p_asset_dist_iac_adj_info(g_dist_idx2).current_deprn_reserve :=0;


  	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'prepare adj:asset_id.................'|| p_asset_dist_iac_adj_info(g_dist_idx2).asset_id);
  	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'prepare adj:book_type_code...........'|| p_asset_dist_iac_adj_info(g_dist_idx2).book_type_code);
  	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'prepare adj:distribution_id..........'|| p_asset_dist_iac_adj_info(g_dist_idx2).distribution_id);
  	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'prepare adj:period_counter...........'|| p_asset_dist_iac_adj_info(g_dist_idx2).period_counter );-- tested
  	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'prepare adj:deprn_amount.............'|| p_asset_dist_iac_adj_info(g_dist_idx2).deprn_amount );
  	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'prepare adj:ytd_deprn................'|| p_asset_dist_iac_adj_info(g_dist_idx2).ytd_deprn);
  	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'prepare adj:deprn_reserve............'|| p_asset_dist_iac_adj_info(g_dist_idx2).deprn_reserve);
  	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'prepare adj:deprn_adjustment_amount..'|| p_asset_dist_iac_adj_info(g_dist_idx2).deprn_adjustment_amount);
  	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'prepare adj:deprn_periods_elapsed....'|| p_asset_dist_iac_adj_info(g_dist_idx2).deprn_periods_elapsed );
  	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'prepare adj:deprn_periods_current_year..'||p_asset_dist_iac_adj_info(g_dist_idx2).deprn_periods_current_year);
  	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'prepare adj:deprn_periods_prior_year....'||p_asset_dist_iac_adj_info(g_dist_idx2).deprn_periods_prior_year );
  	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'prepare adj:start_period_counter......'|| p_asset_dist_iac_adj_info(g_dist_idx2).start_period_counter   );
  	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'prepare adj:last_period_counter.......'|| p_asset_dist_iac_adj_info(g_dist_idx2).last_period_counter );
  	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'prepare adj:pys_deprn_reserve.........'|| p_asset_dist_iac_adj_info(g_dist_idx2).pys_deprn_reserve );
  	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'prepare adj:current_deprn_reserve....'||  p_asset_dist_iac_adj_info(g_dist_idx2).current_deprn_reserve);

       END LOOP;

     RETURN TRUE;

END prepare_adjustment;


FUNCTION Do_Process_Adjustments(
          p_book_type_code                 varchar2,
          p_period_counter                 number ,
          p_calling_function               varchar2
         ) RETURN boolean IS

        CURSOR c_get_asset_adj IS
        SELECT *
        FROM igi_iac_adjustments_history
        WHERE book_type_code = p_book_type_code
        AND period_counter = p_period_counter
        AND NVL(active_flag,'N') = 'N' ;

        l_get_asset_adj c_get_asset_adj%ROWTYPE;
        l_last_update_date           date;
        l_last_updated_by            number;
        l_last_update_login          number;
        l_user_id                    number;
        l_login_id                   number;
        l_path_name VARCHAR2(150) := g_path||'do_process_adjustments';
        p_event_id                       number(15);   --R12 uptake
BEGIN

        -- start preparation for iac adjutsments processing
        IF fnd_profile.value('PRINT_DEBUG') = 'Y'  THEN
           SELECT SUBSTR(VALUE,1,DECODE ((INSTR(VALUE,',', 1, 1)-1),0,LENGTH(VALUE)
                    ,(INSTR(VALUE,',', 1, 1)-1)))
                   INTO g_output_dir
             FROM v$parameter
                WHERE name LIKE 'utl%';
                g_debug_log := 'iacadj.log';
                g_debug_output := 'iacadj.out';
                g_debug_print := TRUE;
         ELSE
               g_debug_print := FALSE;
        END IF;

        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'creating a message log file for adjustments from depreciation');
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'calling function '||p_calling_function);
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => ' in iac adjustments');
        l_user_id := fnd_global.user_id;
        l_login_id := fnd_global.login_id;

        FOR l_get_asset_adj IN c_get_asset_adj
        LOOP
                    select event_id into p_event_id from fa_deprn_summary
                    where asset_id=l_get_asset_adj.asset_id
                    and book_type_code=p_book_type_code
                    and period_counter=p_period_counter;

                    IF NOT  prepare_adjustment(p_book_type_code,
                                             p_period_counter,
                                             l_get_asset_adj.asset_id,
                                             l_get_asset_adj.transaction_subtype,
                                             g_asset_iac_adj_info,
                                             g_asset_iac_dist_info,
                                             l_get_asset_adj  ) THEN
                         RETURN FALSE;
                    END IF;

                    IF l_get_asset_adj.adjustment_reval_type ='C' THEN
                         -- call cost adjustments package
                         IF  NOT IGI_IAC_ADJ_COST_REVAL_PKG.Do_Cost_Revaluation(
                                             g_asset_iac_adj_info,
                                             g_asset_iac_dist_info,
                                             l_get_asset_adj,
                                             p_event_id)  THEN --- function to process cost

                             RETURN FALSE;
                         END IF;

                    END IF;
                    IF g_asset_iac_adj_info.Depreciate_flag = 'YES' THEN
                        If l_get_asset_adj.transaction_subtype = 'AMORTIZED' THEN
                            -- Call amortization processing depreciation revalution.
                              IF Not IGI_IAC_ADJ_AMORT_PKG. Do_Amort_Deprn_Reval(
                                             g_asset_iac_adj_info,
                                             g_asset_iac_dist_info,
                                             l_get_asset_adj,
                                             p_event_id)
                                               THEN --- function to process amortization depreciation

                                 RETURN FALSE;
                              END IF;

                         ELSIF l_get_asset_adj.transaction_subtype = 'EXPENSED' THEN
                               IF Not IGI_IAC_ADJ_EXPENSED_PKG.Do_Expensed_Adj (
                                             g_asset_iac_adj_info,
                                             g_asset_iac_dist_info,
                                             l_get_asset_adj,
                                             p_event_id)  THEN --- function to process expensed depreciation

                                RETURN FALSE;
                                END IF;

                       END IF;
                   END IF;

                    l_last_update_date := SYSDATE;
                    l_last_updated_by := l_user_id;
                   IF (l_last_updated_by IS NULL) THEN
                        l_last_updated_by := -1;
                   END IF;
                   l_last_update_login := l_login_id;
                   IF (l_last_update_login IS NULL) THEN
                      l_last_update_login := -1;
                   END IF;

                    UPDATE igi_iac_adjustments_history
                    SET active_flag = 'Y',
                        last_updated_by = l_last_updated_by,
                        last_update_date =l_last_update_date,
                        last_update_login =l_last_update_login
                    WHERE asset_id = l_get_asset_adj.asset_id
                    AND book_type_code = l_get_asset_adj.book_type_code;

        END LOOP;
                RETURN TRUE;
               --return false;

END do_process_adjustments;


END igi_iac_adj_pkg;

/
