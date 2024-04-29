--------------------------------------------------------
--  DDL for Package Body FA_MC_UPG2_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_MC_UPG2_PKG" AS
/* $Header: faxmcu2b.pls 120.4.12010000.3 2009/08/04 19:57:05 bridgway ship $  */

g_print_debug boolean := fa_cache_pkg.fa_print_debug;

PROCEDURE convert_books(
		p_rsob_id 		IN 	NUMBER,
		p_book_type_code 	IN	VARCHAR2,
		p_numerator_rate	IN	NUMBER,
		p_denominator_rate	IN	NUMBER,
		p_mau			IN	NUMBER,
		p_precision		IN	NUMBER) IS

	l_count number;
/* ************************************************************************
   This procedure will select all the rows in fa_books for each asset being
   converted and insert them into fa_mc_books. All amount columns will be
   converted either with the exchange rate or a derived rate of
   cost/primary_cur_cost based on the conversion basis of R or C.
   The converted amounts will also be rounded using the precision and
   minimum accountable unti of the reporting currency
************************************************************************ */

BEGIN

	if (g_print_debug) then
        fa_debug_pkg.add('convert_assets',
                         'Converting FA_BOOKS records',
                         'start');
        end if;

	INSERT INTO fa_mc_books(
				set_of_books_id,
				asset_id,
 				book_type_code,
 				transaction_header_id_in,
 				transaction_header_id_out,
 				adjusted_cost,
 				cost,
 				source_cost,
 				original_cost,
 				source_original_cost,
 				salvage_value,
 				adjustment_required_status,
 				retirement_pending_flag,
 				last_update_date,
 				last_updated_by,
 				itc_amount,
 				itc_basis,
 				recoverable_cost,
 				last_update_login,
 				reval_ceiling,
 				period_counter_fully_reserved,
 				unrevalued_cost,
 				allowed_deprn_limit_amount,
 				period_counter_lIFe_complete,
 				adjusted_recoverable_cost,
 				converted_flag,
 				annual_deprn_rounding_flag,
                                itc_amount_id,
                                retirement_id,
                                tax_request_id,
                                basic_rate,
                                adjusted_rate,
                                bonus_rule,
                                ceiling_name,
                                adjusted_capacity,
                                fully_rsvd_revals_counter,
                                idled_flag,
                                period_counter_capitalized,
                                period_counter_fully_retired,
                                production_capacity,
                                unit_of_measure,
                                percent_salvage_value,
                                allowed_deprn_limit,
                                annual_rounding_flag,
                                global_attribute1,
                                global_attribute2,
                                global_attribute3,
                                global_attribute4,
                                global_attribute5,
                                global_attribute6,
                                global_attribute7,
                                global_attribute8,
                                global_attribute9,
                                global_attribute10,
                                global_attribute11,
                                global_attribute12,
                                global_attribute13,
                                global_attribute14,
                                global_attribute15,
                                global_attribute16,
                                global_attribute17,
                                global_attribute18,
                                global_attribute19,
                                global_attribute20,
                                global_attribute_category,
                                date_placed_in_service,
                                date_effective,
                                deprn_start_date,
                                deprn_method_code,
                                life_in_months,
                                rate_adjustment_factor,
                                prorate_convention_code,
                                prorate_date,
                                cost_change_flag,
                                capitalize_flag,
                                depreciate_flag,
                                date_ineffective,
                                conversion_date,
                                original_deprn_start_date,
                                salvage_type,
                                deprn_limit_type,
				allocate_to_fully_ret_flag,
				allocate_to_fully_rsv_flag,
				cash_generating_unit_id,
				depreciation_option,
				disabled_flag,
				eofy_formula_factor,
				eop_formula_factor,
				excess_allocation_option,
				exclude_fully_rsv_flag,
				exclude_proceeds_from_basis,
				formula_factor,
				group_asset_id,
				limit_proceeds_flag,
				member_rollup_flag,
				old_adjusted_capacity,
				over_depreciate_option,
				recapture_reserve_flag,
				recognize_gain_loss,
				reduce_addition_flag,
				reduce_adjustment_flag,
				reduce_retirement_flag,
				reduction_rate,
				remaining_life1,
				remaining_life2,
				retirement_deprn_option,
				short_fiscal_year_flag,
				super_group_id,
				terminal_gain_loss,
				terminal_gain_loss_flag,
				tracking_method
)
	SELECT 	p_rsob_id,
		bk.asset_id,
		bk.book_type_code,
		bk.transaction_header_id_in,
		bk.transaction_header_id_out,
		DECODE(p_mau,
                        NULL, ROUND(
                                DECODE(cr.conversion_basis,
                                        'C', (bk.adjusted_cost *
                                             (cr.cost/cr.primary_cur_cost)),

                                        'R', (bk.adjusted_cost/
						p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate)
                                    ), p_precision),
                        ROUND(
                              DECODE(cr.conversion_basis,
                                        'C', (bk.adjusted_cost *
                                             (cr.cost/cr.primary_cur_cost)),
                                        'R', (bk.adjusted_cost/
						p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate))
                             / p_mau) * p_mau),
                DECODE(p_mau,
                        NULL, ROUND(
                                DECODE(cr.conversion_basis,
                                        'C', (bk.cost *
                                             (cr.cost/cr.primary_cur_cost)),

                                        'R', (bk.cost/
						p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate)
                                    ), p_precision),
                        ROUND(
                              DECODE(cr.conversion_basis,
                                        'C', (bk.cost *
                                             (cr.cost/cr.primary_cur_cost)),
                                        'R', (bk.cost/
						p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate))
                             / p_mau) * p_mau),
		bk.cost,
                DECODE(p_mau,
                        NULL, ROUND(
                                DECODE(cr.conversion_basis,
                                        'C', (bk.original_cost *
                                             (cr.cost/cr.primary_cur_cost)),
                                        'R', (bk.original_cost/
						p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate)
                                    ), p_precision),
                        ROUND(
                              DECODE(cr.conversion_basis,
                                        'C', (bk.original_cost *
                                             (cr.cost/cr.primary_cur_cost)),
                                        'R', (bk.original_cost/
						p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate))
                             / p_mau) * p_mau),

		bk.original_cost,
                DECODE(p_mau,
                        NULL, ROUND(
                                DECODE(cr.conversion_basis,
                                        'C', (bk.salvage_value *
                                             (cr.cost/cr.primary_cur_cost)),
                                        'R', (bk.salvage_value/
						p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate)
                                    ), p_precision),
                        ROUND(
                              DECODE(cr.conversion_basis,
                                        'C', (bk.salvage_value *
                                             (cr.cost/cr.primary_cur_cost)),
                                        'R', (bk.salvage_value/
						p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate))
                             / p_mau) * p_mau),
		bk.adjustment_required_status,
		bk.retirement_pending_flag,
		bk.last_update_date,
		bk.last_updated_by,
                DECODE(p_mau,
                        NULL, ROUND(
                                DECODE(cr.conversion_basis,
                                        'C', (bk.itc_amount *
                                             (cr.cost/cr.primary_cur_cost)),
                                        'R', (bk.itc_amount /
					      p_denominator_rate )
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate)
                                    ), p_precision),
                        ROUND(
                              DECODE(cr.conversion_basis,
                                        'C', (bk.itc_amount *
                                             (cr.cost/cr.primary_cur_cost)),
                                        'R',   (bk.itc_amount/
						p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate))
                             / p_mau) * p_mau),
		bk.itc_basis,
                DECODE(p_mau,
                        NULL, ROUND(
                                DECODE(cr.conversion_basis,
                                        'C', (bk.recoverable_cost *
                                             (cr.cost/cr.primary_cur_cost)),
                                        'R',  (bk.recoverable_cost/
						p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate)
                                    ), p_precision),
                        ROUND(
                              DECODE(cr.conversion_basis,
                                        'C', (bk.recoverable_cost *
                                             (cr.cost/cr.primary_cur_cost)),
                                        'R', (bk.recoverable_cost/
						p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate))
                             / p_mau) * p_mau),

		bk.last_update_login,
                DECODE(p_mau,
                        NULL, ROUND(
                                DECODE(cr.conversion_basis,
                                        'C', (bk.reval_ceiling *
                                             (cr.cost/cr.primary_cur_cost)),
                                        'R', (bk.reval_ceiling/
						p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate)
                                    ), p_precision),
                        ROUND(
                              DECODE(cr.conversion_basis,
                                        'C', (bk.reval_ceiling *
                                             (cr.cost/cr.primary_cur_cost)),
                                        'R', (bk.reval_ceiling/
						p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate))
                             / p_mau) * p_mau),
		bk.period_counter_fully_reserved,
                DECODE(p_mau,
                        NULL, ROUND(
                                DECODE(cr.conversion_basis,
                                        'C', (bk.unrevalued_cost *
                                             (cr.cost/cr.primary_cur_cost)),
                                        'R',  bk.unrevalued_cost/
                                                p_denominator_rate
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate)
                                    ), p_precision),
                        ROUND(
                              DECODE(cr.conversion_basis,
                                        'C', (bk.unrevalued_cost *
                                             (cr.cost/cr.primary_cur_cost)),
                                        'R', (bk.unrevalued_cost/
                                                p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate))
                             / p_mau) * p_mau),

                DECODE(p_mau,
                        NULL, ROUND(
                                DECODE(cr.conversion_basis,
                                        'C', (bk.allowed_deprn_limit_amount *
                                             (cr.cost/cr.primary_cur_cost)),

                                        'R', (bk.allowed_deprn_limit_amount/
						p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate)
                                    ), p_precision),
                        ROUND(
                              DECODE(cr.conversion_basis,
                                        'C', (bk.allowed_deprn_limit_amount *
                                             (cr.cost/cr.primary_cur_cost)),
                                        'R', (bk.allowed_deprn_limit_amount/
						p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate))
                             / p_mau) * p_mau),
		bk.period_counter_lIFe_complete,
                DECODE(p_mau,
                        NULL, ROUND(
                                DECODE(cr.conversion_basis,
                                        'C', (bk.adjusted_recoverable_cost *
                                             (cr.cost/cr.primary_cur_cost)),

                                        'R', (bk.adjusted_recoverable_cost/
                                                p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate)
                                    ), p_precision),
                        ROUND(
                              DECODE(cr.conversion_basis,
                                        'C', (bk.adjusted_recoverable_cost *
                                             (cr.cost/cr.primary_cur_cost)),
                                        'R', (bk.adjusted_recoverable_cost/
                                                p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate))
                             / p_mau) * p_mau),
		'Y',
		bk.annual_deprn_rounding_flag,
                bk.itc_amount_id,
                bk.retirement_id,
                bk.tax_request_id,
                bk.basic_rate,
                bk.adjusted_rate,
                bk.bonus_rule,
                bk.ceiling_name,
                bk.adjusted_capacity,
                bk.fully_rsvd_revals_counter,
                bk.idled_flag,
                bk.period_counter_capitalized,
                bk.period_counter_fully_retired,
                bk.production_capacity,
                bk.unit_of_measure,
                bk.percent_salvage_value,
                bk.allowed_deprn_limit,
                bk.annual_rounding_flag,
                bk.global_attribute1,
                bk.global_attribute2,
                bk.global_attribute3,
                bk.global_attribute4,
                bk.global_attribute5,
                bk.global_attribute6,
                bk.global_attribute7,
                bk.global_attribute8,
                bk.global_attribute9,
                bk.global_attribute10,
                bk.global_attribute11,
                bk.global_attribute12,
                bk.global_attribute13,
                bk.global_attribute14,
                bk.global_attribute15,
                bk.global_attribute16,
                bk.global_attribute17,
                bk.global_attribute18,
                bk.global_attribute19,
                bk.global_attribute20,
                bk.global_attribute_category,
                bk.date_placed_in_service,
                bk.date_effective,
                bk.deprn_start_date,
                bk.deprn_method_code,
                bk.life_in_months,
                bk.rate_adjustment_factor,
                bk.prorate_convention_code,
                bk.prorate_date,
                bk.cost_change_flag,
                bk.capitalize_flag,
                bk.depreciate_flag,
                bk.date_ineffective,
                bk.conversion_date,
                bk.original_deprn_start_date,
                bk.salvage_type,
                bk.deprn_limit_type,
		bk.allocate_to_fully_ret_flag,
		bk.allocate_to_fully_rsv_flag,
		bk.cash_generating_unit_id,
		bk.depreciation_option,
		bk.disabled_flag,
		bk.eofy_formula_factor,
		bk.eop_formula_factor,
		bk.excess_allocation_option,
		bk.exclude_fully_rsv_flag,
		bk.exclude_proceeds_from_basis,
		bk.formula_factor,
		bk.group_asset_id,
		bk.limit_proceeds_flag,
		bk.member_rollup_flag,
		bk.old_adjusted_capacity,
		bk.over_depreciate_option,
		bk.recapture_reserve_flag,
		bk.recognize_gain_loss,
		bk.reduce_addition_flag,
		bk.reduce_adjustment_flag,
		bk.reduce_retirement_flag,
		bk.reduction_rate,
		bk.remaining_life1,
		bk.remaining_life2,
		bk.retirement_deprn_option,
		bk.short_fiscal_year_flag,
		bk.super_group_id,
		bk.terminal_gain_loss,
		bk.terminal_gain_loss_flag,
		bk.tracking_method
	FROM
			fa_books bk,
			fa_mc_conversion_rates cr
	WHERE
			cr.asset_id = bk.asset_id AND
			cr.set_of_books_id = p_rsob_id AND
			cr.book_type_code = p_book_type_code AND
			bk.book_type_code = cr.book_type_code AND
			cr.status = 'S';

        if (g_print_debug) then
            fa_debug_pkg.add('convert_assets',
                             'Converted FA_BOOKS records',
                             'success');
        end if;


EXCEPTION
	WHEN OTHERS THEN
                fa_srvr_msg.add_sql_error (
                             	calling_fn => 'fa_mc_upg_pkg2.convert_books');

                app_exception.raise_exception;

END convert_books;


PROCEDURE convert_invoices (
			p_rsob_id		IN 	NUMBER,
    			p_book_type_code	IN	VARCHAR2,
	                p_numerator_rate        IN      NUMBER,
       		        p_denominator_rate      IN      NUMBER,
			p_mau			IN	NUMBER,
			p_precision		IN	NUMBER) IS
/* ************************************************************************
   This procedure will select all the rows in fa_asset_invoices for each
   asset being converted and insert them into fa_mc_asset_invoices.
   All amount columns will be
   converted either with the exchange rate or a derived rate of
   cost/primary_cur_cost based on the conversion basis of R or C.
   The converted amounts will also be rounded using the precision and
   minimum accountable unti of the reporting currency
************************************************************************ */

l_book_class	 varchar2(15);

BEGIN

	if (g_print_debug) then
           fa_debug_pkg.add('convert_assets',
                            'Converting FA_ASSET_INVOICES records',
                            'start');
        end if;

        SELECT  book_class
        INTO    l_book_class
        FROM    fa_book_controls
        WHERE   book_type_code = p_book_type_code;

	-- Only convert fa_asset_invoices when run for corporate books. When
	-- run for tax books can result in duplicate invoice lines in
	-- reporting book
        IF (l_book_class = 'CORPORATE') THEN
	INSERT INTO fa_mc_asset_invoices(
				set_of_books_id,
				exchange_rate,
                                asset_id,
                                asset_invoice_id,
                                invoice_transaction_id_in,
				fixed_assets_cost,
				payables_cost,
				unrevalued_cost,
                                po_vendor_id,
                                date_effective,
                                date_ineffective,
                                invoice_transaction_id_out,
                                deleted_flag,
                                po_number,
                                invoice_number,
                                payables_batch_name,
                                payables_code_combination_id,
                                feeder_system_name,
                                create_batch_date,
                                create_batch_id,
                                invoice_date,
                                post_batch_id,
                                invoice_id,
                                ap_distribution_line_number,
                                payables_units,
                                split_merged_code,
                                description,
                                parent_mass_addition_id,
                                last_update_date,
                                last_updated_by,
                                created_by,
                                creation_date,
                                last_update_login,
                                attribute1,
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
                                attribute_category_code,
                                merged_code,
                                split_code,
                                merge_parent_mass_additions_id,
                                split_parent_mass_additions_id,
                                project_asset_line_id,
                                project_id,
                                task_id,
                                source_line_id,
                                invoice_distribution_id,
                                invoice_line_number,
                                po_distribution_id
)
	SELECT
		p_rsob_id,
		DECODE(cr.conversion_basis,
		       'C', cr.cost/cr.primary_cur_cost,
		       'R', decode(cr.exchange_rate,
				   NULL, p_numerator_rate/p_denominator_rate,
				   cr.exchange_rate),
		       p_numerator_rate/p_denominator_rate),
                ai.asset_id,
                ai.asset_invoice_id,
           	ai.invoice_transaction_id_in,
                DECODE(p_mau,
                        NULL, ROUND(
                                DECODE(cr.conversion_basis,
                                        'C', (ai.fixed_assets_cost *
					     (cr.cost/cr.primary_cur_cost)),
                                        'R', (ai.fixed_assets_cost/
					   	p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate)
                                    ), p_precision),
                        ROUND(
                              DECODE(cr.conversion_basis,
                                        'C', (ai.fixed_assets_cost *
                                             (cr.cost/cr.primary_cur_cost)),
                                        'R', (ai.fixed_assets_cost/
						p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate))
                             / p_mau) * p_mau),
                DECODE(p_mau,
                        NULL, ROUND(
                                DECODE(cr.conversion_basis,
                                        'C', (ai.payables_cost *
                                             (cr.cost/cr.primary_cur_cost)),
                                        'R', (ai.payables_cost /
                                                p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate)
                                    ), p_precision),
                        ROUND(
                              DECODE(cr.conversion_basis,
                                        'C', (ai.payables_cost *
                                             (cr.cost/cr.primary_cur_cost)),
                                        'R', (ai.payables_cost/
                                                p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate))
                             / p_mau) * p_mau),
                DECODE(p_mau,
                        NULL, ROUND(
                                DECODE(cr.conversion_basis,
                                        'C', (ai.unrevalued_cost *
                                             (cr.cost/cr.primary_cur_cost)),
                                        'R', (ai.unrevalued_cost/
                                                p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate)
                                    ), p_precision),
                        ROUND(
                              DECODE(cr.conversion_basis,
                                        'C', (ai.unrevalued_cost *
                                             (cr.cost/cr.primary_cur_cost)),
                                        'R', (ai.unrevalued_cost/
                                                p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate))
                             / p_mau) * p_mau),
                ai.po_vendor_id,
             	ai.date_effective,
                ai.date_ineffective,
                ai.invoice_transaction_id_out,
                ai.deleted_flag,
                ai.po_number,
                ai.invoice_number,
                ai.payables_batch_name,
                ai.payables_code_combination_id,
                ai.feeder_system_name,
                ai.create_batch_date,
                ai.create_batch_id,
                ai.invoice_date,
                ai.post_batch_id,
                ai.invoice_id,
                ai.ap_distribution_line_number,
                ai.payables_units,
                ai.split_merged_code,
                ai.description,
                ai.parent_mass_addition_id,
                ai.last_update_date,
                ai.last_updated_by,
                ai.created_by,
                ai.creation_date,
                ai.last_update_login,
                ai.attribute1,
                ai.attribute2,
		ai.attribute3,
                ai.attribute4,
                ai.attribute5,
                ai.attribute6,
                ai.attribute7,
                ai.attribute8,
                ai.attribute9,
                ai.attribute10,
                ai.attribute11,
                ai.attribute12,
                ai.attribute13,
                ai.attribute14,
                ai.attribute15,
                ai.attribute_category_code,
                ai.merged_code,
                ai.split_code,
                ai.merge_parent_mass_additions_id,
                ai.split_parent_mass_additions_id,
                ai.project_asset_line_id,
                ai.project_id,
                ai.task_id,
                ai.source_line_id,
                ai.invoice_distribution_id,
                ai.invoice_line_number,
                ai.po_distribution_id
	FROM
		fa_asset_invoices ai,
		fa_mc_conversion_rates cr
	WHERE
		ai.asset_id = cr.asset_id AND
		cr.set_of_books_id = p_rsob_id AND
		cr.book_type_code = p_book_type_code AND
		cr.status = 'S';

	END IF;  -- l_book_class

        if (g_print_debug) then
            fa_debug_pkg.add('convert_assets',
                             'Converted FA_ASSET_INVOICES records',
                             'success');
        end if;


EXCEPTION
        WHEN OTHERS THEN
                fa_srvr_msg.add_sql_error (
                        calling_fn => 'fa_mc_upg2_pkg.convert_invoices');
                app_exception.raise_exception;

END convert_invoices;


PROCEDURE insert_bks_rates(
			p_rsob_id		IN	NUMBER,
			p_book_type_code	IN	VARCHAR2,
                	p_numerator_rate        IN      NUMBER,
                	p_denominator_rate      IN      NUMBER,
			p_precision		IN	NUMBER) IS
/* ************************************************************************
   This procedure will insert a row for each asset converted to reporting
   book. It will contain the transaction_header_id_in from the active row
   fa_books at the time of conversion and has the rate that was used
   to convert the asset transactions. This is the ratio of the cost in
   reporting book divided by the cost in primary book. For assets that
   have a cost of 0 we will use the exchange_rate as of the initial
   conversion date for the Reporting Book
************************************************************************ */

BEGIN

       if (g_print_debug) then
          fa_debug_pkg.add('convert_assets',
                           'Inserting into FA_MC_BOOKS_RATES',
                           'start');
       end if;

	INSERT INTO fa_mc_books_rates
			       (set_of_books_id,
				asset_id,
				book_type_code,
				transaction_header_id,
				invoice_transaction_id,
				transaction_date_entered,
				cost,
				exchange_rate,
				avg_exchange_rate,
				last_updated_by,
				last_update_date,
				last_update_login,
				complete)
	SELECT 	p_rsob_id,
		mcbk.asset_id,
		p_book_type_code,
		mcbk.transaction_header_id_in,
		NULL,
		bk.date_effective,
		bk.cost,
                DECODE(cr.conversion_basis,
                       'R', decode(cr.exchange_rate,
                                   NULL, (p_numerator_rate/
                                          p_denominator_rate),
                                   decode(bk.cost,
                                          0, cr.exchange_rate,
                                          (mcbk.cost/bk.cost))),
                        decode(bk.cost,
                               0, (p_numerator_rate/
                                   p_denominator_rate),
                                  (mcbk.cost/bk.cost))),
                DECODE(cr.conversion_basis,
                       'R', decode(cr.exchange_rate,
                                   NULL, (p_numerator_rate/
                                          p_denominator_rate),
                                   decode(bk.cost,
                                          0, cr.exchange_rate,
                                          (mcbk.cost/bk.cost))),
                        decode(bk.cost,
                               0, (p_numerator_rate/
                                   p_denominator_rate),
                                  (mcbk.cost/bk.cost))),
		mcbk.last_updated_by,
		mcbk.last_update_date,
		mcbk.last_update_login,
		'Y'
	FROM
		fa_mc_books mcbk,
		fa_books bk,
		fa_mc_conversion_rates cr

	WHERE
		cr.status = 'S' AND
		cr.asset_id = bk.asset_id AND
		bk.asset_id = mcbk.asset_id AND
		cr.set_of_books_id = p_rsob_id AND
		bk.date_ineffective is NULL AND
		bk.transaction_header_id_in =
				mcbk.transaction_header_id_in AND
		cr.book_type_code = p_book_type_code AND
		bk.book_type_code = cr.book_type_code AND
		mcbk.set_of_books_id = cr.set_of_books_id AND
		mcbk.book_type_code = bk.book_type_code;

        if (g_print_debug) then
            fa_debug_pkg.add('convert_assets',
                             'Insered into FA_MC_BOOKS_RATES',
                             'success');
            end if;


EXCEPTION
        WHEN OTHERS THEN
                fa_srvr_msg.add_sql_error (
                         calling_fn => 'fa_mc_upg2_pkg.insert_books_rates');

                app_exception.raise_exception;
END insert_bks_rates;



PROCEDURE convert_adjustments(
			p_rsob_id		IN	NUMBER,
      			p_book_type_code	IN	VARCHAR2,
      			p_start_pc		IN	NUMBER,
      			p_end_pc		IN	NUMBER,
	                p_numerator_rate        IN      NUMBER,
       		        p_denominator_rate      IN      NUMBER,
			p_mau			IN	NUMBER,
			p_precision		IN	NUMBER) IS
/* ************************************************************************
   This procedure will convert all rows in fa_adjustments in the fiscal
   being converted and all rows in prior fiscal years related to balance
   sheet accounts for the candidate assets. The first insert will insert
   all rows in the fiscal year being converted and the second insert
   inserts all prior years rows.
************************************************************************ */

BEGIN
      	if (g_print_debug) then
           fa_debug_pkg.add('convert_assets',
                          'Converting FA_ADJUSTMENTS records',
                          'start');
        end if;


	-- convert everything in fa_adjustments in the fiscal year being
	-- converted

	INSERT INTO fa_mc_adjustments(
				set_of_books_id,
				transaction_header_id,
				source_type_code,
				adjustment_type,
				debit_credit_flag,
				code_combination_id,
				book_type_code,
				asset_id,
				adjustment_amount,
				distribution_id,
				last_update_date,
				last_updated_by,
				last_update_login,
				annualized_adjustment,
				je_header_id,
				je_line_num,
				period_counter_adjusted,
				period_counter_created,
				asset_invoice_id,
				global_attribute1,
				global_attribute2,
				global_attribute3,
				global_attribute4,
				global_attribute5,
				global_attribute6,
				global_attribute7,
				global_attribute8,
				global_attribute9,
				global_attribute10,
				global_attribute11,
				global_attribute12,
				global_attribute13,
				global_attribute14,
				global_attribute15,
				global_attribute16,
				global_attribute17,
				global_attribute18,
				global_attribute19,
				global_attribute20,
				global_attribute_category,
				converted_flag,
				adjustment_line_id,
				deprn_override_flag,
				track_member_flag,
                                source_line_id,
                                source_dest_code
)
	SELECT
		p_rsob_id,
                aj.transaction_header_id,
                aj.source_type_code,
                aj.adjustment_type,
                aj.debit_credit_flag,
                aj.code_combination_id,
                aj.book_type_code,
                aj.asset_id,
                DECODE(p_mau,
                        NULL, ROUND(
                                DECODE(cr.conversion_basis,
                                        'C', (aj.adjustment_amount *
                                             (cr.cost/cr.primary_cur_cost)),

                                        'R', (aj.adjustment_amount/
                                                p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate)
                                    ), p_precision),
                        ROUND(
                              DECODE(cr.conversion_basis,
                                        'C', (aj.adjustment_amount *
                                             (cr.cost/cr.primary_cur_cost)),
                                        'R', (aj.adjustment_amount/
                                                p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate))
                             / p_mau) * p_mau),

                aj.distribution_id,
                aj.last_update_date,
                aj.last_updated_by,
                aj.last_update_login,
                DECODE(p_mau,
                        NULL, ROUND(
                                DECODE(cr.conversion_basis,
                                        'C', (aj.annualized_adjustment *
                                             (cr.cost/cr.primary_cur_cost)),

                                        'R', (aj.annualized_adjustment/
                                                p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate)
                                    ), p_precision),
                        ROUND(
                              DECODE(cr.conversion_basis,
                                        'C', (aj.annualized_adjustment *
                                             (cr.cost/cr.primary_cur_cost)),
                                        'R', (aj.annualized_adjustment/
                                                p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate))
                             / p_mau) * p_mau),
                aj.je_header_id,
                aj.je_line_num,
                aj.period_counter_adjusted,
                aj.period_counter_created,
                aj.asset_invoice_id,
                aj.global_attribute1,
                aj.global_attribute2,
                aj.global_attribute3,
                aj.global_attribute4,
                aj.global_attribute5,
                aj.global_attribute6,
                aj.global_attribute7,
                aj.global_attribute8,
                aj.global_attribute9,
                aj.global_attribute10,
                aj.global_attribute11,
                aj.global_attribute12,
                aj.global_attribute13,
                aj.global_attribute14,
                aj.global_attribute15,
                aj.global_attribute16,
                aj.global_attribute17,
                aj.global_attribute18,
                aj.global_attribute19,
                aj.global_attribute20,
                aj.global_attribute_category,
                'Y',
		fa_adjustments_s.nextval,
		aj.deprn_override_flag,
		aj.track_member_flag,
                aj.source_line_id,
                aj.source_dest_code
	FROM
		fa_adjustments aj,
		fa_mc_conversion_rates cr

	WHERE
		cr.set_of_books_id = p_rsob_id AND
		cr.book_type_code = p_book_type_code AND
		cr.asset_id = aj.asset_id AND
		aj.book_type_code = cr.book_type_code AND
		aj.period_counter_created between p_start_pc
					and p_end_pc AND
		cr.status = 'S';

	-- convert all balance sheet relevant accounts in the
	-- past years as well for the assets being converted.

        INSERT INTO fa_mc_adjustments(
                                set_of_books_id,
                                transaction_header_id,
                                source_type_code,
                                adjustment_type,
                                debit_credit_flag,
                                code_combination_id,
                                book_type_code,
                                asset_id,
                                adjustment_amount,
                                distribution_id,
                                last_update_date,
                                last_updated_by,
                                last_update_login,
                                annualized_adjustment,
                                je_header_id,
                                je_line_num,
                                period_counter_adjusted,
                                period_counter_created,
                                asset_invoice_id,
                                global_attribute1,
                                global_attribute2,
                                global_attribute3,
                                global_attribute4,
                                global_attribute5,
                                global_attribute6,
                                global_attribute7,
                                global_attribute8,
                                global_attribute9,
                                global_attribute10,
                                global_attribute11,
                                global_attribute12,
                                global_attribute13,
                                global_attribute14,
                                global_attribute15,
                                global_attribute16,
                                global_attribute17,
                                global_attribute18,
                                global_attribute19,
                                global_attribute20,
                                global_attribute_category,
                                converted_flag,
				adjustment_line_id,
				deprn_override_flag,
				track_member_flag,
                                source_line_id,
                                source_dest_code
)
        SELECT
                p_rsob_id,
                aj.transaction_header_id,
                aj.source_type_code,
                aj.adjustment_type,
                aj.debit_credit_flag,
                aj.code_combination_id,
                aj.book_type_code,
                aj.asset_id,
                DECODE(p_mau,
                        NULL, ROUND(
                                DECODE(cr.conversion_basis,
                                        'C', (aj.adjustment_amount *
                                             (cr.cost/cr.primary_cur_cost)),

                                        'R', (aj.adjustment_amount/
                                                p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate)
                                    ), p_precision),
                        ROUND(
                              DECODE(cr.conversion_basis,
                                        'C', (aj.adjustment_amount *
                                             (cr.cost/cr.primary_cur_cost)),
                                        'R', (aj.adjustment_amount/
                                                p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate))
                             / p_mau) * p_mau),
                aj.distribution_id,
                aj.last_update_date,
                aj.last_updated_by,
                aj.last_update_login,
                DECODE(p_mau,
                        NULL, ROUND(
                                DECODE(cr.conversion_basis,
                                        'C', (aj.annualized_adjustment *
                                             (cr.cost/cr.primary_cur_cost)),

                                        'R', (aj.annualized_adjustment/
                                                p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate)
                                    ), p_precision),
                        ROUND(
                              DECODE(cr.conversion_basis,
                                        'C', (aj.annualized_adjustment *
                                             (cr.cost/cr.primary_cur_cost)),
                                        'R', (aj.annualized_adjustment/
                                                p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate))
                             / p_mau) * p_mau),
                aj.je_header_id,
                aj.je_line_num,
                aj.period_counter_adjusted,
                aj.period_counter_created,
                aj.asset_invoice_id,
                aj.global_attribute1,
                aj.global_attribute2,
                aj.global_attribute3,
                aj.global_attribute4,
                aj.global_attribute5,
                aj.global_attribute6,
                aj.global_attribute7,
                aj.global_attribute8,
                aj.global_attribute9,
                aj.global_attribute10,
                aj.global_attribute11,
                aj.global_attribute12,
                aj.global_attribute13,
                aj.global_attribute14,
                aj.global_attribute15,
                aj.global_attribute16,
                aj.global_attribute17,
                aj.global_attribute18,
                aj.global_attribute19,
                aj.global_attribute20,
                aj.global_attribute_category,
                'Y',
		fa_adjustments_s.nextval,
		aj.deprn_override_flag,
		aj.track_member_flag,
                aj.source_line_id,
                aj.source_dest_code
  	FROM
		fa_adjustments aj,
		fa_mc_conversion_rates cr
	WHERE
		cr.set_of_books_id = p_rsob_id AND
		cr.book_type_code = p_book_type_code AND
		cr.asset_id = aj.asset_id AND
		aj.book_type_code = cr.book_type_code AND
		aj.period_counter_created < p_start_pc AND
		aj.adjustment_type IN (	'COST',
					'COST CLEARING',
					'CIP COST',
					'RESERVE',
					'REVAL RESERVE',
					'DEPRN ADJUST',
					'INTERCO AP',
					'INTERCO AR',
					'PROCEEDS CLR',
					'REMOVALCOST CLR') AND
		cr.status = 'S';

        if (g_print_debug) then
            fa_debug_pkg.add('convert_assets',
                             'Converted FA_ADJUSTMENTS records',
                             'success');
        end if;


EXCEPTION
        WHEN OTHERS THEN
                fa_srvr_msg.add_sql_error (
                        calling_fn => 'fa_mc_upg2_pkg.convert_adjustments');
                app_exception.raise_exception;

END convert_adjustments;


PROCEDURE round_retirements(
                        p_book_type_code        IN      VARCHAR2,
                        p_rsob_id               IN      NUMBER,
                        p_start_pc              IN      NUMBER) IS
/* ************************************************************************
   This procedure rounds all retirement rows for the candidate assets.
   We round all the retirements that have happened in the current fiscal
   year being converted. We are only concerned with those retirement_id's
   that have not been reinstated. Rounding is to set NBV_RETIRED TO
   COST - RESERVE.
************************************************************************ */

        l_trx_id        NUMBER;
        l_nbv_retired   NUMBER;
        l_cost_retired  NUMBER;
        l_gain_loss     NUMBER;
        l_proceeds      NUMBER;
        l_cor           NUMBER;
        l_reval_rsv     NUMBER;
	l_rsv_retired	NUMBER;
        l_maj_rowid     ROWID;
        l_mrt_rowid     ROWID;

        CURSOR get_retirements IS
                SELECT
                        maj.rowid,
                        mrt.cost_retired,
                        mrt.rowid,
                        mrt.reval_reserve_retired,
                        mrt.proceeds_of_sale,
                        mrt.cost_of_removal,
                        maj.transaction_header_id
                FROM
                        fa_mc_adjustments maj,
			fa_deprn_periods dp,
                        fa_mc_retirements mrt,
                        fa_retirements rt,
			fa_mc_conversion_rates cr
                WHERE
			cr.book_type_code = p_book_type_code AND
			cr.set_of_books_id = p_rsob_id AND
			cr.status = 'S' AND
			cr.asset_id = rt.asset_id AND
                        mrt.retirement_id = rt.retirement_id AND
                        rt.book_type_code = cr.book_type_code AND
                        rt.date_effective >= dp.period_open_date AND
                        dp.book_type_code = rt.book_type_code AND
                        dp.period_counter = p_start_pc AND
                        nvl(mrt.nbv_retired,0) <> 0 AND
                        maj.set_of_books_id = p_rsob_id AND
                        maj.book_type_code = rt.book_type_code AND
			maj.asset_id = rt.asset_id AND
                        maj.transaction_header_id =
                                        rt.transaction_header_id_in AND
                        rt.transaction_header_id_out is NULL AND
                        maj.adjustment_type = 'NBV RETIRED';

        CURSOR reserve_retired IS
                SELECT
                        nvl(sum(decode(maj.debit_credit_flag,
                                       'DR', maj.adjustment_amount,
                                       'CR', -1 * maj.adjustment_amount)),0)
                FROM
                        fa_mc_adjustments maj
                WHERE
                        maj.set_of_books_id = p_rsob_id AND
                        maj.book_type_code = p_book_type_code AND
                        maj.transaction_header_id = l_trx_id AND
                        maj.adjustment_type = 'RESERVE';
BEGIN

       if (g_print_debug) then
           fa_debug_pkg.add('convert_assets',
                            'Round Retirements',
                            'start');
       end if;

        OPEN get_retirements;
        LOOP
                FETCH get_retirements INTO
                                l_maj_rowid,
                                l_cost_retired,
                                l_mrt_rowid,
                                l_reval_rsv,
                                l_proceeds,
                                l_cor,
                                l_trx_id;
                IF (get_retirements%NOTFOUND) THEN
                   EXIT;
                END IF;
                OPEN reserve_retired;
                FETCH reserve_retired INTO l_rsv_retired;
                CLOSE reserve_retired;

                l_nbv_retired := l_cost_retired - l_rsv_retired;
                l_gain_loss := l_proceeds - l_cor - l_nbv_retired +
                               l_reval_rsv;

                UPDATE  fa_mc_adjustments
                SET     adjustment_amount = l_nbv_retired
                WHERE   rowid = l_maj_rowid;

                UPDATE  fa_mc_retirements
                SET     gain_loss_amount = l_gain_loss,
			nbv_retired = l_nbv_retired
                WHERE   rowid = l_mrt_rowid;
        END LOOP;
        CLOSE get_retirements;


EXCEPTION
        WHEN OTHERS THEN
                fa_srvr_msg.add_sql_error (
                        calling_fn => 'fa_mc_upg2_pkg.round_retirements');
                app_exception.raise_exception;
END round_retirements;


PROCEDURE convert_retirements(
			p_rsob_id		IN	NUMBER,
      			p_book_type_code	IN	VARCHAR2,
      			p_start_pc		IN	NUMBER,
			p_end_pc		IN	NUMBER,
			p_numerator_rate        IN      NUMBER,
			p_denominator_rate      IN      NUMBER,
			p_mau			IN	NUMBER,
			p_precision		IN	NUMBER) IS
/* ************************************************************************
   This procedure converts all retirement rows for the candidate assets
   being converted.
************************************************************************ */

	l_period_num		NUMBER;

BEGIN

        if (g_print_debug) then
           fa_debug_pkg.add('convert_assets',
                            'Converting FA_RETIREMENTS records',
                            'start');
        end if;

	INSERT INTO fa_mc_retirements(
				set_of_books_id,
				retirement_id,
				cost_retired,
				status,
				last_update_date,
				last_updated_by,
				cost_of_removal,
				nbv_retired,
				gain_loss_amount,
				proceeds_of_sale,
				itc_recaptured,
				stl_deprn_amount,
				last_update_login,
				reval_reserve_retired,
				unrevalued_cost_retired,
				converted_flag,
                                book_type_code,
                                asset_id,
                                transaction_header_id_in,
                                transaction_header_id_out,
                                date_retired,
                                date_effective,
                                retirement_prorate_convention,
                                units,
                                gain_loss_type_code,
                                retirement_type_code,
                                itc_recapture_id,
                                reference_num,
                                sold_to,
                                trade_in_asset_id,
                                stl_method_code,
                                stl_life_in_months,
                                created_by,
                                creation_date,
                                attribute1,
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
                                attribute_category_code,
				limit_proceeds_flag,
				recapture_reserve_flag,
				recognize_gain_loss,
				reduction_rate,
				terminal_gain_loss
)
	SELECT	p_rsob_id,
		rt.retirement_id,
                DECODE(p_mau,
                        NULL, ROUND(
                                DECODE(cr.conversion_basis,
                                        'C', (rt.cost_retired *
                                             (cr.cost/cr.primary_cur_cost)),

                                        'R', (rt.cost_retired/
                                                p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate)
                                    ), p_precision),
                        ROUND(
                              DECODE(cr.conversion_basis,
                                        'C', (rt.cost_retired *
                                             (cr.cost/cr.primary_cur_cost)),
                                        'R', (rt.cost_retired/
                                                p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate))
                             / p_mau) * p_mau),
		rt.status,
		rt.last_update_date,
		rt.last_updated_by,
                DECODE(p_mau,
                        NULL, ROUND(
                                DECODE(cr.conversion_basis,
                                        'C', (rt.cost_of_removal *
                                             (cr.cost/cr.primary_cur_cost)),

                                        'R', (rt.cost_of_removal /
                                                p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate)
                                    ), p_precision),
                        ROUND(
                              DECODE(cr.conversion_basis,
                                        'C', (rt.cost_of_removal *
                                             (cr.cost/cr.primary_cur_cost)),
                                        'R', (rt.cost_of_removal /
                                                p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate))
                             / p_mau) * p_mau),
                DECODE(p_mau,
                        NULL, ROUND(
                                DECODE(cr.conversion_basis,
                                        'C', (rt.nbv_retired *
                                             (cr.cost/cr.primary_cur_cost)),

                                        'R', (rt.nbv_retired /
                                                p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate)
                                    ), p_precision),
                        ROUND(
                              DECODE(cr.conversion_basis,
                                        'C', (rt.nbv_retired *
                                             (cr.cost/cr.primary_cur_cost)),
                                        'R', (rt.nbv_retired /
                                                p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate))
                             / p_mau) * p_mau),
                DECODE(p_mau,
                        NULL, ROUND(
                                DECODE(cr.conversion_basis,
                                        'C', (rt.gain_loss_amount *
                                             (cr.cost/cr.primary_cur_cost)),

                                        'R', (rt.gain_loss_amount/
                                                p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate)
                                    ), p_precision),
                        ROUND(
                              DECODE(cr.conversion_basis,
                                        'C', (rt.gain_loss_amount *
                                             (cr.cost/cr.primary_cur_cost)),
                                        'R', (rt.gain_loss_amount /
                                                p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate))
                             / p_mau) * p_mau),
                DECODE(p_mau,
                        NULL, ROUND(
                                DECODE(cr.conversion_basis,
                                        'C', (rt.proceeds_of_sale *
                                             (cr.cost/cr.primary_cur_cost)),

                                        'R', (rt.proceeds_of_sale/
                                                p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate)
                                    ), p_precision),
                        ROUND(
                              DECODE(cr.conversion_basis,
                                        'C', (rt.proceeds_of_sale *
                                             (cr.cost/cr.primary_cur_cost)),
                                        'R', (rt.proceeds_of_sale /
                                                p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate))
                             / p_mau) * p_mau),
                DECODE(p_mau,
                        NULL, ROUND(
                                DECODE(cr.conversion_basis,
                                        'C', (rt.itc_recaptured *
                                             (cr.cost/cr.primary_cur_cost)),

                                        'R', (rt.itc_recaptured/
                                                p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate)
                                    ), p_precision),
                        ROUND(
                              DECODE(cr.conversion_basis,
                                        'C', (rt.itc_recaptured *
                                             (cr.cost/cr.primary_cur_cost)),
                                        'R', (rt.itc_recaptured /
                                                p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate))
                             / p_mau) * p_mau),
                DECODE(p_mau,
                        NULL, ROUND(
                                DECODE(cr.conversion_basis,
                                        'C', (rt.stl_deprn_amount *
                                             (cr.cost/cr.primary_cur_cost)),

                                        'R', (rt.stl_deprn_amount /
                                                p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate)
                                    ), p_precision),
                        ROUND(
                              DECODE(cr.conversion_basis,
                                        'C', (rt.stl_deprn_amount *
                                             (cr.cost/cr.primary_cur_cost)),
                                        'R', (rt.stl_deprn_amount /
                                                p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate))
                             / p_mau) * p_mau),

		rt.last_update_login,
                DECODE(p_mau,
                        NULL, ROUND(
                                DECODE(cr.conversion_basis,
                                        'C', (rt.reval_reserve_retired *
                                             (cr.cost/cr.primary_cur_cost)),

                                        'R', (rt.reval_reserve_retired /
                                                p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate)
                                    ), p_precision),
                        ROUND(
                              DECODE(cr.conversion_basis,
                                        'C', (rt.reval_reserve_retired *
                                             (cr.cost/cr.primary_cur_cost)),
                                        'R', (rt.reval_reserve_retired /
                                                p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate))
                             / p_mau) * p_mau),
                DECODE(p_mau,
                        NULL, ROUND(
                                DECODE(cr.conversion_basis,
                                        'C', (rt.unrevalued_cost_retired *
                                             (cr.cost/cr.primary_cur_cost)),

                                        'R', (rt.unrevalued_cost_retired /
                                                p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate)
                                    ), p_precision),
                        ROUND(
                              DECODE(cr.conversion_basis,
                                        'C', (rt.unrevalued_cost_retired *
                                             (cr.cost/cr.primary_cur_cost)),
                                        'R', (rt.unrevalued_cost_retired /
                                                p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate))
                             / p_mau) * p_mau),

		'Y',
                rt.book_type_code,
                rt.asset_id,
                rt.transaction_header_id_in,
                rt.transaction_header_id_out,
                rt.date_retired,
                rt.date_effective,
                rt.retirement_prorate_convention,
                rt.units,
                rt.gain_loss_type_code,
                rt.retirement_type_code,
                rt.itc_recapture_id,
                rt.reference_num,
                rt.sold_to,
                rt.trade_in_asset_id,
                rt.stl_method_code,
                rt.stl_life_in_months,
                rt.created_by,
                rt.creation_date,
                rt.attribute1,
                rt.attribute2,
                rt.attribute3,
                rt.attribute4,
                rt.attribute5,
                rt.attribute6,
                rt.attribute7,
                rt.attribute8,
                rt.attribute9,
                rt.attribute10,
                rt.attribute11,
                rt.attribute12,
                rt.attribute13,
                rt.attribute14,
                rt.attribute15,
                rt.attribute_category_code,
		rt.limit_proceeds_flag,
		rt.recapture_reserve_flag,
		rt.recognize_gain_loss,
		rt.reduction_rate,
		rt.terminal_gain_loss
	FROM
		fa_retirements rt,
		fa_mc_conversion_rates cr
	WHERE
		cr.set_of_books_id = p_rsob_id AND
		cr.book_type_code = p_book_type_code AND
		cr.asset_id = rt.asset_id AND
		rt.book_type_code = cr.book_type_code AND
		cr.status = 'S';

	SELECT 	dp.period_num
	INTO	l_period_num
	FROM
		fa_deprn_periods dp
	WHERE	dp.book_type_code = p_book_type_code AND
		period_counter = p_end_pc;

	-- if current open period is the first period of fiscal year
	-- there is no need to round retirements of the fiscal year
	-- that was converted since reinstatement cannot be done
	-- across fiscal years

	IF (l_period_num > 1) THEN
	    round_retirements(
			p_book_type_code,
			p_rsob_id,
			p_start_pc);
	END IF;

        if (g_print_debug) then
                fa_debug_pkg.add('convert_retirements',
				 'round_retirements',
                                 'success');
                fa_debug_pkg.add('convert_assets',
                                'Converted FA_RETIREMENTS records',
                                'success');
        end if;


EXCEPTION
        WHEN OTHERS THEN
                fa_srvr_msg.add_sql_error (
                        calling_fn => 'fa_mc_upg2_pkg.convert_retirements');

                app_exception.raise_exception;

END convert_retirements;


PROCEDURE convert_deprn_summary(
			p_book_type_code	IN 	VARCHAR2,
			p_rsob_id		IN	NUMBER,
			p_start_pc		IN	NUMBER,
			p_end_pc		IN	NUMBER,
			p_convert_order		IN	VARCHAR2,
			p_mau			IN	NUMBER,
			p_precision		IN	NUMBER) IS
/* ************************************************************************
   This procedure converts rows in fa_deprn_summary for each asset and
   inserts them into fa_mc_deprn_summary. First it selects and converts
   the BOOKS row for all the assets. Then depending on the convert order of
   of F or L it converts the DEPRN rows for the assets. When the convert_order
   is F, all the DEPRN rows in current year are converted and when the
   convert_order is L, only the last DEPRN in a prior fiscal year is
   converted.
   The rows in fa_deprn_summary are fetched one at a time and ordered by
   asset_id and period_counter. The deprn_amount column for pc is
   calculated using a ratio of cost in fa_mc_books * cost in fa_books/
   deprn_amount in primary currency. deprn_reserve and ytd_deprn for the
   first period_counter in the current year are also calulated the same way.
   For subsequent period counters the deprn_amount for current period is
   added to deprn_reserve of previous period. This is necessary to round
   reserve correctly as it is then used in converting and rounding
   fa_deprn_detail
************************************************************************ */

        l_last_asset_id         number;
        l_last_deprn_rsv        number;
        l_last_ytd_deprn        number;
        l_last_reval_rsv        number;
        l_last_ytd_reval_exp    number;
        l_last_book             varchar2(30);

        l_book_type_code        varchar2(30);
        l_asset_id              number;
        l_deprn_run_date        date;
        l_deprn_amount          number;
        l_ytd_deprn             number;
        l_deprn_reserve         number;
        l_deprn_source_code     varchar2(15);
        l_adjusted_cost         number;
        l_bonus_rate            number;
        l_ltd_prod              number;
        l_period_counter        number;
        l_prod                  number;
        l_reval_amort           number;
        l_reval_amort_basis     number;
        l_reval_exp             number;
        l_reval_reserve         number;
        l_ytd_prod              number;
        l_ytd_reval_exp         number;
        l_prior_fy_exp          number;

	-- adding for fix to 990059
        l_primary_rsv		number;

        -- potential fix for BUG# 1662585
        l_ret_reserve           number;
	l_deprn_override_flag   varchar2(1);

	CURSOR ds_row IS
	SELECT
                ds.book_type_code,
                ds.asset_id,
                ds.deprn_run_date,
                DECODE(p_mau,
                        NULL, ROUND(
                                (mcbk.cost * (ds.deprn_amount /
						decode(bk.cost,0,1,bk.cost))),
                                p_precision),
                        ROUND(
                                (mcbk.cost * (ds.deprn_amount /
						decode(bk.cost,0,1,bk.cost)))/
                                p_mau) * p_mau),
                DECODE(p_mau,
                        NULL, ROUND(
                                (mcbk.cost * (ds.ytd_deprn /
						decode(bk.cost,0,1,bk.cost))),
                                p_precision),
                        ROUND(
                                (mcbk.cost * (ds.ytd_deprn /
						decode(bk.cost,0,1,bk.cost))) /
                                p_mau) * p_mau),
                DECODE(p_mau,
                        NULL, ROUND(
                                (mcbk.cost * (ds.deprn_reserve/
						decode(bk.cost,0,1,bk.cost))),
                                p_precision),
                        ROUND(
                                (mcbk.cost * (ds.deprn_reserve/
						decode(bk.cost,0,1,bk.cost))) /
                                p_mau) * p_mau),
                ds.deprn_source_code,
                mcbk.adjusted_cost,
                ds.bonus_rate,
                ds.ltd_production,
                ds.period_counter,
                ds.production,
                DECODE(p_mau,
                        NULL, ROUND(
                                (mcbk.cost * (ds.reval_amortization/
						decode(bk.cost,0,1,bk.cost))),
                                p_precision),
                        ROUND(
                                (mcbk.cost * (ds.reval_amortization/
						decode(bk.cost,0,1,bk.cost)))/
                                p_mau) * p_mau),
                DECODE(p_mau,
                        NULL, ROUND(
                                (mcbk.cost * (ds.reval_amortization_basis/
                                                decode(bk.cost,0,1,bk.cost))),
                                p_precision),
                        ROUND(
                                (mcbk.cost * (ds.reval_amortization_basis/
                                                decode(bk.cost,0,1,bk.cost))) /
                                p_mau) * p_mau),
                DECODE(p_mau,
                        NULL, ROUND(
                                (mcbk.cost * (ds.reval_deprn_expense/
						decode(bk.cost,0,1,bk.cost))),
                                p_precision),
                        ROUND(
                                (mcbk.cost * (ds.reval_deprn_expense/
						decode(bk.cost,0,1,bk.cost)))/
                                p_mau) * p_mau),
                DECODE(p_mau,
                        NULL, ROUND(
                                (mcbk.cost * (ds.reval_reserve/
						decode(bk.cost,0,1,bk.cost))),
                                p_precision),
                        ROUND(
                                (mcbk.cost * (ds.reval_reserve/
						decode(bk.cost,0,1,bk.cost))) /
                                p_mau) * p_mau),
                ds.ytd_production,
                DECODE(p_mau,
                        NULL, ROUND(
                                (mcbk.cost * (ds.ytd_reval_deprn_expense/
                                                decode(bk.cost,0,1,bk.cost))),
                                p_precision),
                        ROUND(
                                (mcbk.cost * (ds.ytd_reval_deprn_expense/
                                                decode(bk.cost,0,1,bk.cost))) /
                                p_mau) * p_mau),
                DECODE(p_mau,
                        NULL, ROUND(
                                (mcbk.cost * (ds.prior_fy_expense/
						decode(bk.cost,0,1,bk.cost))),
                                p_precision),
                        ROUND(
                                (mcbk.cost * (ds.prior_fy_expense/
						decode(bk.cost,0,1,bk.cost))) /
                                p_mau) * p_mau),
		ds.deprn_reserve,
		ds.deprn_override_flag
       FROM
             	fa_deprn_summary ds,
                fa_deprn_periods dp,
                fa_mc_books mcbk,
                fa_books bk,
                fa_mc_conversion_rates cr
       WHERE
                ds.asset_id = mcbk.asset_id AND
                cr.book_type_code = p_book_type_code AND
                cr.set_of_books_id = p_rsob_id AND
                bk.asset_id = cr.asset_id AND
                bk.book_type_code = cr.book_type_code AND
                mcbk.asset_id = bk.asset_id AND
                mcbk.book_type_code = bk.book_type_code AND
                mcbk.book_type_code = dp.book_type_code AND
                ds.deprn_source_code = 'DEPRN' AND
                dp.period_counter = ds.period_counter AND
                dp.book_type_code = ds.book_type_code AND
                nvl(dp.period_CLOSE_date, sysdate)
                                 between bk.date_effective and
                                 nvl(bk.date_ineffective, sysdate) AND
                bk.transaction_header_id_in =
                            mcbk.transaction_header_id_in AND
                mcbk.set_of_books_id = cr.set_of_books_id AND
                cr.status = 'S' AND
                ds.period_counter between p_start_pc and
                                                 p_end_pc
	ORDER BY
		ds.book_type_code,
		ds.asset_id,
		ds.period_counter;

BEGIN

       if (g_print_debug) then
           fa_debug_pkg.add('convert_assets',
                            'Converting FA_DEPRN_SUMMARY records',
                            'start');
	    fa_debug_pkg.add('Convert_summary','convert_order',
			     p_convert_order);
	end if;

	INSERT INTO fa_mc_deprn_summary(set_of_books_id,
                                        book_type_code,
                                        asset_id,
                                        deprn_run_date,
                                        deprn_amount,
                                        ytd_deprn,
                                        deprn_reserve,
                                        deprn_source_code,
                                        adjusted_cost,
                                        bonus_rate,
                                        ltd_production,
                                        period_counter,
                                        production,
                                        reval_amortization,
                                        reval_amortization_basis,
                                        reval_deprn_expense,
                                        reval_reserve,
                                        ytd_production,
                                        ytd_reval_deprn_expense,
                                        prior_fy_expense,
                                        converted_flag,
					deprn_override_flag)
	SELECT
		p_rsob_id,
                ds.book_type_code,
                ds.asset_id,
                ds.deprn_run_date,
                DECODE(p_mau,
                        NULL, ROUND(
                                (mcbk.cost * (ds.deprn_amount /
                                                decode(bk.cost,0,1,bk.cost))),
                                p_precision),
                        ROUND(
                                (mcbk.cost * (ds.deprn_amount /
                                                decode(bk.cost,0,1,bk.cost)))/
                                p_mau) * p_mau),
                DECODE(p_mau,
                        NULL, ROUND(
                                (mcbk.cost * (ds.ytd_deprn /
                                                decode(bk.cost,0,1,bk.cost))),
                                p_precision),
                        ROUND(
                                (mcbk.cost * (ds.ytd_deprn /
                                                decode(bk.cost,0,1,bk.cost))) /
                                p_mau) * p_mau),
                DECODE(p_mau,
                        NULL, ROUND(
                                (mcbk.cost * (ds.deprn_reserve/
                                                decode(bk.cost,0,1,bk.cost))),
                                p_precision),
                        ROUND(
                                (mcbk.cost * (ds.deprn_reserve/
                                                decode(bk.cost,0,1,bk.cost))) /
                                p_mau) * p_mau),
                ds.deprn_source_code,
                mcbk.adjusted_cost,
                ds.bonus_rate,
                ds.ltd_production,
                ds.period_counter,
                ds.production,
                DECODE(p_mau,
                        NULL, ROUND(
                                (mcbk.cost * (ds.reval_amortization/
                                                decode(bk.cost,0,1,bk.cost))),
                                p_precision),
                        ROUND(
                                (mcbk.cost * (ds.reval_amortization/
                                                decode(bk.cost,0,1,bk.cost)))/
                                p_mau) * p_mau),
                DECODE(p_mau,
                        NULL, ROUND(
                                (mcbk.cost * (ds.reval_amortization_basis/
                                                decode(bk.cost,0,1,bk.cost))),
                                p_precision),
                        ROUND(
                                (mcbk.cost * (ds.reval_amortization_basis/
                                                decode(bk.cost,0,1,bk.cost))) /
                                p_mau) * p_mau),
                DECODE(p_mau,
                        NULL, ROUND(
                                (mcbk.cost * (ds.reval_deprn_expense/
                                                decode(bk.cost,0,1,bk.cost))),
                                p_precision),
                        ROUND(
                                (mcbk.cost * (ds.reval_deprn_expense/
                                                decode(bk.cost,0,1,bk.cost)))/
                                p_mau) * p_mau),
                DECODE(p_mau,
                        NULL, ROUND(
                                (mcbk.cost * (ds.reval_reserve/
                                                decode(bk.cost,0,1,bk.cost))),
                                p_precision),
                        ROUND(
                                (mcbk.cost * (ds.reval_reserve/
                                                decode(bk.cost,0,1,bk.cost))) /
                                p_mau) * p_mau),
		ds.ytd_production,
                DECODE(p_mau,
                        NULL, ROUND(
                                (mcbk.cost * (ds.ytd_reval_deprn_expense/
                                                decode(bk.cost,0,1,bk.cost))),
                                p_precision),
                        ROUND(
                                (mcbk.cost * (ds.ytd_reval_deprn_expense/
                                                decode(bk.cost,0,1,bk.cost))) /
                                p_mau) * p_mau),
                DECODE(p_mau,
                        NULL, ROUND(
                                (mcbk.cost * (ds.prior_fy_expense/
                                                decode(bk.cost,0,1,bk.cost))),
                                p_precision),
                        ROUND(
                                (mcbk.cost * (ds.prior_fy_expense/
                                                decode(bk.cost,0,1,bk.cost))) /
                                p_mau) * p_mau),
                'Y',
		ds.deprn_override_flag
	FROM
		fa_deprn_summary ds,
		fa_deprn_periods dp,
		fa_mc_books mcbk,
		fa_books bk,
		fa_mc_conversion_rates cr
	WHERE
                ds.asset_id = mcbk.asset_id AND
                ds.deprn_source_code = 'BOOKS' AND
                cr.book_type_code = p_book_type_code AND
                cr.set_of_books_id = p_rsob_id AND
                cr.status = 'S' AND
                bk.asset_id = cr.asset_id AND
                mcbk.asset_id = bk.asset_id AND
                mcbk.set_of_books_id = cr.set_of_books_id AND
                mcbk.book_type_code = dp.book_type_code AND
                mcbk.book_type_code = bk.book_type_code AND
                bk.book_type_code = cr.book_type_code AND
                dp.book_type_code = ds.book_type_code AND
                nvl(dp.period_close_date, sysdate)
                        between bk.date_effective and
                                nvl(bk.date_ineffective, sysdate) AND
                dp.period_counter = ds.period_counter + 1 AND
                bk.transaction_header_id_in = mcbk.transaction_header_id_in;

        if (g_print_debug) then
                fa_debug_pkg.add('Convert_summary','conversion stage',
                                'Inserted BOOKS rows');
        end if;

	-- now convert all DEPRN rows from start of current FISCAL Year

    	IF (p_convert_order = 'F') THEN

		l_last_asset_id := 0;
		l_last_deprn_rsv := 0;
		l_last_ytd_deprn := 0;
		l_last_reval_rsv := 0;
		l_last_ytd_reval_exp := 0;

	   OPEN ds_row;
	   LOOP
		FETCH ds_row into
				l_book_type_code,
				l_asset_id,
				l_deprn_run_date,
				l_deprn_amount,
				l_ytd_deprn,
				l_deprn_reserve,
				l_deprn_source_code,
				l_adjusted_cost,
				l_bonus_rate,
				l_ltd_prod,
				l_period_counter,
				l_prod,
				l_reval_amort,
				l_reval_amort_basis,
				l_reval_exp,
				l_reval_reserve,
				l_ytd_prod,
				l_ytd_reval_exp,
				l_prior_fy_exp,
				l_primary_rsv,
				l_deprn_override_flag;
		IF (ds_row%NOTFOUND) THEN
		   exit;
		END IF;

		IF ((l_asset_id = l_last_asset_id) AND
		   (l_book_type_code = l_last_book)) THEN
/*
	dbms_output.put_line('adding previous rows amounts');
	dbms_output.put_line('l_last_deprn_rsv' || l_last_deprn_rsv);
	dbms_output.put_line('l_deprn_amount' || l_deprn_amount);
	dbms_output.put_line('l_deprn_reserve' || l_deprn_reserve);
*/

                   -- Fix for Bug 990059
                   -- When asset is fully retired need to set deprn_reserve
                   -- to 0
                   IF (l_primary_rsv <> 0) then
                        -- BUG# 1662585
                        -- need to get any effects from partial retirements
                        -- and reinstatements

                        select sum(decode(debit_credit_flag,
                                          'DR', -1 * adjustment_amount,
                                          adjustment_amount))
                          into l_ret_reserve
                          from fa_mc_adjustments
                         where asset_id               = l_asset_id
                           and book_type_code         = l_book_type_code
                           and set_of_books_id        = p_rsob_id
                           and period_counter_created = l_period_counter
                           and source_type_code       = 'RETIREMENT'
                           and adjustment_type        = 'RESERVE';

                        l_deprn_reserve := l_deprn_amount + l_last_deprn_rsv +
                                           nvl(l_ret_reserve, 0);
                   END IF;
			l_ytd_deprn := l_deprn_amount + l_last_ytd_deprn;
			l_reval_reserve := l_last_reval_rsv - l_reval_exp;
			l_ytd_reval_exp := l_reval_exp + l_last_ytd_reval_exp;
		ELSE
			l_last_book := l_book_type_code;
        		l_last_asset_id := l_asset_id;
		END IF;
                l_last_deprn_rsv := l_deprn_reserve;
                l_last_ytd_deprn := l_ytd_deprn;
                l_last_reval_rsv := l_reval_reserve;
                l_last_ytd_reval_exp := l_ytd_reval_exp;


		INSERT INTO fa_mc_deprn_summary(set_of_books_id,
						book_type_code,
						asset_id,
						deprn_run_date,
						deprn_amount,
						ytd_deprn,
						deprn_reserve,
						deprn_source_code,
						adjusted_cost,
						bonus_rate,
						ltd_production,
						period_counter,
						production,
						reval_amortization,
						reval_amortization_basis,
						reval_deprn_expense,
						reval_reserve,
						ytd_production,
						ytd_reval_deprn_expense,
						prior_fy_expense,
						converted_flag,
						deprn_override_flag)
					VALUES(
						p_rsob_id,
						l_book_type_code,
						l_asset_id,
						l_deprn_run_date,
						l_deprn_amount,
						l_ytd_deprn,
						l_deprn_reserve,
						l_deprn_source_code,
						l_adjusted_cost,
						l_bonus_rate,
						l_ltd_prod,
						l_period_counter,
						l_prod,
						l_reval_amort,
						l_reval_amort_basis,
						l_reval_exp,
						l_reval_reserve,
						l_ytd_prod,
						l_ytd_reval_exp,
						l_prior_fy_exp,
						'Y',
						l_deprn_override_flag);
	   END LOOP;
	   CLOSE ds_row;
	ELSIF (p_convert_order = 'L') THEN
                INSERT INTO fa_mc_deprn_summary(set_of_books_id,
                                                book_type_code,
                                                asset_id,
                                                deprn_run_date,
                                                deprn_amount,
                                                ytd_deprn,
                                                deprn_reserve,
                                                deprn_source_code,
                                                adjusted_cost,
                                                bonus_rate,
                                                ltd_production,
                                                period_counter,
                                                production,
                                                reval_amortization,
                                                reval_amortization_basis,
                                                reval_deprn_expense,
                                                reval_reserve,
                                                ytd_production,
                                                ytd_reval_deprn_expense,
                                                prior_fy_expense,
                                                converted_flag,
						deprn_override_flag)
		SELECT
                        p_rsob_id,
                        ds.book_type_code,
                        ds.asset_id,
                        ds.deprn_run_date,
               		DECODE(p_mau,
                               NULL, ROUND(
                                (mcbk.cost * (ds.deprn_amount /
                                                decode(bk.cost,0,1,bk.cost))),
                                p_precision),
                               ROUND(
                                (mcbk.cost * (ds.deprn_amount /
                                                decode(bk.cost,0,1,bk.cost)))/
                                p_mau) * p_mau),
                	DECODE(p_mau,
                               NULL, ROUND(
                                (mcbk.cost * (ds.ytd_deprn /
                                                decode(bk.cost,0,1,bk.cost))),
                                p_precision),
                               ROUND(
                                (mcbk.cost * (ds.ytd_deprn /
                                                decode(bk.cost,0,1,bk.cost))) /
                                p_mau) * p_mau),
                	DECODE(p_mau,
                               NULL, ROUND(
                                (mcbk.cost * (ds.deprn_reserve/
                                                decode(bk.cost,0,1,bk.cost))),
                                p_precision),
                               ROUND(
                                (mcbk.cost * (ds.deprn_reserve/
                                                decode(bk.cost,0,1,bk.cost))) /
                                p_mau) * p_mau),
                        ds.deprn_source_code,
                        mcbk.adjusted_cost,
                        ds.bonus_rate,
                        ds.ltd_production,
                        ds.period_counter,
                        ds.production,
                	DECODE(p_mau,
                               NULL, ROUND(
                                (mcbk.cost * (ds.reval_amortization/
                                                decode(bk.cost,0,1,bk.cost))),
                                p_precision),
                               ROUND(
                                (mcbk.cost * (ds.reval_amortization/
                                                decode(bk.cost,0,1,bk.cost)))/
                                p_mau) * p_mau),
                	DECODE(p_mau,
                               NULL, ROUND(
                                (mcbk.cost * (ds.reval_amortization_basis/
                                                decode(bk.cost,0,1,bk.cost))),
                                p_precision),
                               ROUND(
                                (mcbk.cost * (ds.reval_amortization_basis/
                                                decode(bk.cost,0,1,bk.cost))) /
                                p_mau) * p_mau),
                	DECODE(p_mau,
                               NULL, ROUND(
                                (mcbk.cost * (ds.reval_deprn_expense/
                                                decode(bk.cost,0,1,bk.cost))),
                                p_precision),
                               ROUND(
                                (mcbk.cost * (ds.reval_deprn_expense/
                                                decode(bk.cost,0,1,bk.cost)))/
                                p_mau) * p_mau),
                	DECODE(p_mau,
                               NULL, ROUND(
                                (mcbk.cost * (ds.reval_reserve/
                                                decode(bk.cost,0,1,bk.cost))),
                                p_precision),
                               ROUND(
                                (mcbk.cost * (ds.reval_reserve/
                                                decode(bk.cost,0,1,bk.cost))) /
                                p_mau) * p_mau),
			ds.ytd_production,
                	DECODE(p_mau,
                               NULL, ROUND(
                                (mcbk.cost * (ds.ytd_reval_deprn_expense/
                                                decode(bk.cost,0,1,bk.cost))),
                                p_precision),
                               ROUND(
                                (mcbk.cost * (ds.ytd_reval_deprn_expense/
                                                decode(bk.cost,0,1,bk.cost))) /
                                p_mau) * p_mau),
                	DECODE(p_mau,
                               NULL, ROUND(
                                (mcbk.cost * (ds.prior_fy_expense/
                                                decode(bk.cost,0,1,bk.cost))),
                                p_precision),
                               ROUND(
                                (mcbk.cost * (ds.prior_fy_expense/
                                                decode(bk.cost,0,1,bk.cost))) /
                                p_mau) * p_mau),
                        'Y',
			ds.deprn_override_flag
		FROM
			fa_deprn_summary ds,
                        fa_deprn_periods dp,
                        fa_mc_books mcbk,
                        fa_books bk,
			fa_mc_conversion_rates cr
		WHERE
			cr.book_type_code = p_book_type_code AND
			cr.set_of_books_id = p_rsob_id AND
			cr.status = 'S' AND
			ds.period_counter = cr.last_period_counter AND
			ds.deprn_source_code = 'DEPRN' AND
			dp.book_type_code = mcbk.book_type_code AND
                        dp.period_counter = ds.period_counter AND
			dp.book_type_code = ds.book_type_code AND
                        nvl(dp.period_CLOSE_date, sysdate)
                                    between bk.date_effective and
                                    nvl(bk.date_ineffective, sysdate) AND
                        bk.transaction_header_id_in =
                                        mcbk.transaction_header_id_in AND
			bk.asset_id = cr.asset_id AND
			bk.asset_id = mcbk.asset_id AND
			ds.asset_id = mcbk.asset_id AND
			bk.book_type_code = cr.book_type_code AND
			mcbk.book_type_code = bk.book_type_code AND
                        mcbk.set_of_books_id = cr.set_of_books_id;

	END IF;

        if (g_print_debug) then
           fa_debug_pkg.add('convert_assets',
                            'Converted FA_DEPRN_SUMMARY records',
                            'success');
        end if;


EXCEPTION
        WHEN OTHERS THEN
                fa_srvr_msg.add_sql_error (
                        calling_fn => 'fa_mc_upg2_pkg.convert_summary');
                app_exception.raise_exception;

END convert_deprn_summary;


PROCEDURE convert_deprn_detail(
			p_rsob_id		IN	NUMBER,
       			p_book_type_code	IN	VARCHAR2,
			p_mau			IN	NUMBER,
			p_precision		IN	NUMBER) IS
/* ************************************************************************
   This procedure will convert the rows in fa_deprn_detail for the
   candidate assets. Candidate assets will have rows in fa_deprn_detail
   converted for the period_counters that were converted in
   fa_deprn_summary. All fa_deprn_detail rows will be fetched one by one
   and converted using logic similar to FAUPDD to round COST,
   DEPRN_RESERVE, REVAL_RESERVE and REVAL_AMORTIZATION to the active
   distributions at the end of a period. YTD_DEPRN will not be rounded
   as it is not used to post to GL and is used only for reporting. The
   ORDER BY clause ensures that assets will be rounded period by period.
************************************************************************ */

        l_part_cost                     number;
        l_cost                          number;
        l_app_cost                      number;

        l_part_deprn_rsv                number;
        l_deprn_rsv                     number;
        l_app_deprn_rsv                 number;

        l_total_units                   number;
        l_units_assigned                number;
        l_app_units                     number;

        l_reval_rsv                     number;
        l_app_reval_rsv                 number;
        l_part_reval_rsv                number;

        l_part_reval_amort              number;
        l_reval_amort                   number;
        l_app_reval_amort               number;

        l_part_reval_exp                number;
        l_reval_exp                     number;
        l_app_reval_exp                 number;

        l_date_ineff                    varchar2(18);
        l_p_close_date                  varchar2(18);
        l_book_type_code                varchar2(30);

        l_last_period_counter           number := 0;
        l_last_asset_id                 number := 0;
        l_last_book                     varchar2(30);
        l_asset_id                      number;

        l_total_deprn_amt               number;
        l_distribution_id               number;
        l_period_counter                number;
        l_app_deprn_amt                 number;
        l_deprn_source_code             varchar2(1);
        l_deprn_amount                  number;
        l_deprn_run_date                date;
        l_ytd_deprn                     number;
        l_deprn_adjustment_amount       number;
        l_addition_cost_to_clear        number;
        l_deprn_expense_je_line_num     number;
        l_deprn_reserve_je_line_num     number;
        l_reval_amort_je_line_num       number;
        l_reval_reserve_je_line_num     number;
        l_je_header_id                  number;
        l_ytd_reval_deprn_expense       number;
        l_prev_ytd_deprn                number;
	l_bonus_deprn_expense_ccid      number;
	l_bonus_deprn_reserve_ccid      number;
	l_deprn_expense_ccid		number;
	l_deprn_reserve_ccid		number;
	l_reval_amort_ccid		number;
	l_reval_reserve_ccid		number;

	-- cursor to select all rows from fa_deprn_detail
	CURSOR dd_row IS
		SELECT /*+ ordered leading(cr)
                           index(ds fa_mc_deprn_summary_u1)
                           index(dd fa_deprn_detail_n1)
                           index(dh fa_distribution_history_u1)
                           index(dp fa_deprn_periods_u3)
                           index(bk fa_books_n1)
                           index(mcbk fa_mc_books_u1)
                           index(ah fa_asset_history_n2) */
			dd.book_type_code,
			dd.asset_id,
			dd.distribution_id,
			dd.period_counter,
			nvl(ds.deprn_reserve,0),
			mcbk.cost,
			to_char(nvl(dh.date_ineffective, sysdate+1),
                                        'YYYYMMDD HH24:MI:SS'),
			to_char(nvl(dp.period_close_date, sysdate),
                                        'YYYYMMDD HH24:MI:SS'),
			nvl(dh.units_assigned,0),
			nvl(ah.units,0),
                        DECODE(p_mau,
                                NULL, ROUND(
                                        (mcbk.cost * (dd.deprn_amount /
						decode(bk.cost,0,1,bk.cost))),
                                        p_precision),
                                ROUND(
                                        (mcbk.cost * (dd.deprn_amount /
						decode(bk.cost,0,1,bk.cost))) /
                                        p_mau) * p_mau),
                        DECODE(p_mau,
                                NULL, ROUND(
                                        (mcbk.cost * (dd.ytd_deprn /
                                                decode(bk.cost,0,1,bk.cost))),
                                        p_precision),
                                ROUND(
                                        (mcbk.cost * (dd.ytd_deprn /
                                                decode(bk.cost,0,1,bk.cost))) /
                                        p_mau) * p_mau),
                        DECODE(p_mau,
                                NULL, ROUND(
                                        (mcbk.cost *(dd.deprn_adjustment_amount
                                               / decode(bk.cost,0,1,bk.cost))),
                                        p_precision),
                                ROUND(
                                        (mcbk.cost *(dd.deprn_adjustment_amount
                                              / decode(bk.cost,0,1,bk.cost))) /
                                        p_mau) * p_mau),
			dd.deprn_source_code,
			dd.deprn_expense_je_line_num,
			dd.deprn_reserve_je_line_num,
			dd.reval_amort_je_line_num,
			dd.reval_reserve_je_line_num,
			dd.je_header_id,
                        ds.reval_amortization,
                        ds.reval_deprn_expense,
                        ds.reval_reserve,
                        DECODE(p_mau,
                                NULL, ROUND(
                                        (mcbk.cost *(dd.ytd_reval_deprn_expense
                                              / decode(bk.cost,0,1,bk.cost))),
                                        p_precision),
                                ROUND(
                                        (mcbk.cost *(dd.ytd_reval_deprn_expense
                                             / decode(bk.cost,0,1,bk.cost))) /
                                        p_mau) * p_mau),
			ds.deprn_amount,
			dd.deprn_run_date,
			dd.bonus_deprn_expense_ccid,
			dd.bonus_deprn_reserve_ccid,
			dd.deprn_expense_ccid,
			dd.deprn_reserve_ccid,
			dd.reval_amort_ccid,
			dd.reval_reserve_ccid
		FROM
			fa_mc_deprn_summary ds,
			fa_deprn_detail dd,
                	fa_deprn_periods dp,
                	fa_books bk,
			fa_mc_books mcbk,
               		fa_distribution_history dh,
                	fa_asset_history ah,
			fa_mc_conversion_rates cr
		WHERE
                        cr.status = 'S' AND
                        cr.asset_id = ds.asset_id AND
                        cr.book_type_code = p_book_type_code AND
                        ds.book_type_code = cr.book_type_code AND
                        ds.book_type_code = dd.book_type_code AND
                        cr.set_of_books_id = p_rsob_id AND
                        ds.set_of_books_id = cr.set_of_books_id AND
                        ds.asset_id = dd.asset_id AND
                        bk.book_type_code = ds.book_type_code AND
                        mcbk.set_of_books_id = ds.set_of_books_id AND
                        bk.transaction_header_id_in =
                                        mcbk.transaction_header_id_in AND
                        ds.period_counter = dd.period_counter AND
                        dp.book_type_code = dd.book_type_code AND
                        dp.period_counter =
                                DECODE(ds.deprn_source_code,
                                        'DEPRN', dd.period_counter,
                                        'BOOKS', dd.period_counter + 1) AND
                        bk.book_type_code = dd.book_type_code AND
                        mcbk.book_type_code = bk.book_type_code AND
                        bk.asset_id = dd.asset_id AND
                        mcbk.asset_id = dd.asset_iD AND
                        nvl(dp.period_close_date, sysdate)
                                between bk.date_effective and
                                        nvl(bk.date_ineffective, sysdate) AND
                        dh.distribution_id = dd.distribution_id AND
                        ah.asset_id = dd.asset_id AND
                        nvl(dp.period_close_date, sysdate)
                                between ah.date_effective and
                                        nvl(ah.date_ineffective, sysdate)
		order by
			dd.book_type_code,
			dd.period_counter,
			dd.asset_id,
			dd.distribution_id;

BEGIN

        if (g_print_debug) then
           fa_debug_pkg.add('convert_assets',
                            'Converting FA_DEPRN_DETAIL records',
                            'start');
        end if;

	OPEN dd_row;
	LOOP
		FETCH dd_row into 	l_book_type_code,
					l_asset_id,
					l_distribution_id,
					l_period_counter,
					l_deprn_rsv,
					l_cost,
					l_date_ineff,
					l_p_close_date,
					l_units_assigned,
					l_total_units,
					l_deprn_amount,
					l_ytd_deprn,
					l_deprn_adjustment_amount,
					l_deprn_source_code,
					l_deprn_expense_je_line_num,
					l_deprn_reserve_je_line_num,
					l_reval_amort_je_line_num,
					l_reval_reserve_je_line_num,
					l_je_header_id,
					l_reval_amort,
					l_reval_exp,
					l_reval_rsv,
					l_ytd_reval_deprn_expense,
					l_total_deprn_amt,
					l_deprn_run_date,
					l_bonus_deprn_expense_ccid,
					l_bonus_deprn_reserve_ccid,
					l_deprn_expense_ccid,
					l_deprn_reserve_ccid,
					l_reval_amort_ccid,
					l_reval_reserve_ccid;

		IF (dd_row%NOTFOUND) THEN
		   exit;
		END IF;

		IF ((l_asset_id <> l_last_asset_id) OR
		    (l_period_counter <> l_last_period_counter) OR
		    (l_book_type_code <> l_last_book)) THEN

			l_app_cost := 0;
			l_app_deprn_rsv := 0;
			l_app_units := 0;

			l_app_reval_rsv	:= 0;
			l_app_reval_amort := 0;
			l_app_reval_exp := 0;
			l_app_deprn_amt := 0;

			l_last_asset_id := l_asset_id;
			l_last_period_counter := l_period_counter;
			l_last_book := l_book_type_code;

		END IF;

		-- use the active distributions to allocate cost and
		-- reserve

		-- If distribution is active at end of period

		IF (l_date_ineff > l_p_close_date) THEN
			l_app_units := l_units_assigned + l_app_units;
			l_part_deprn_rsv := (l_deprn_rsv * l_units_assigned)/
						l_total_units;

			l_part_cost := (l_cost * l_units_assigned) /
						l_total_units;
			l_part_reval_rsv := (l_reval_rsv * l_units_assigned)/
						l_total_units;
			l_part_reval_amort := (l_reval_amort * l_units_assigned)
						/ l_total_units;
			l_part_reval_exp := (l_reval_exp * l_units_assigned)/
						l_total_units;
		-- now round all the amounts

                        IF (p_mau IS NOT NULL) THEN
			   l_part_deprn_rsv :=  (ROUND( l_part_deprn_rsv/p_mau)
						* p_mau );
                           l_part_cost :=  (ROUND( l_part_cost/p_mau)
                                                * p_mau );
			   l_part_reval_rsv := (ROUND( l_part_reval_rsv/p_mau)
                                                * p_mau );
                           l_part_reval_amort := (ROUND(l_part_reval_amort/
									p_mau)
                                                * p_mau );
                           l_part_reval_exp := (ROUND(l_part_reval_exp/p_mau)
                                                * p_mau );
                        ELSE
			   l_part_deprn_rsv := ROUND( l_part_deprn_rsv,
						      p_precision);
                           l_part_cost := ROUND( l_part_cost,
                                                      p_precision );
			   l_part_reval_rsv := ROUND( l_part_reval_rsv,
                                                      p_precision );
                           l_part_reval_amort := ROUND( l_part_reval_amort,
                                                      p_precision );
                           l_part_reval_exp := ROUND( l_part_reval_exp,
                                                      p_precision );
                        END IF;

			l_app_deprn_rsv := l_part_deprn_rsv + l_app_deprn_rsv;
			l_app_cost := l_part_cost + l_app_cost;
			l_app_reval_rsv := l_part_reval_rsv + l_app_reval_rsv;
			l_app_reval_amort := l_part_reval_amort +
							l_app_reval_amort;
			l_app_reval_exp := l_part_reval_exp + l_app_reval_exp;


			IF (l_total_units = l_app_units) THEN
				l_part_cost := l_part_cost +
					(l_cost - l_app_cost);
				l_part_deprn_rsv := l_part_deprn_rsv +
					(l_deprn_rsv - l_app_deprn_rsv);
				l_part_reval_rsv := l_part_reval_rsv +
					(l_reval_rsv - l_app_reval_rsv);
				l_part_reval_amort := l_part_reval_amort +
					(l_reval_amort - l_app_reval_amort);
				l_part_reval_exp := l_part_reval_exp +
					(l_reval_exp - l_app_reval_exp);
			END IF;
		ELSE
			l_part_cost := 0;
			l_part_deprn_rsv := 0;
			l_part_reval_rsv := 0;
			l_part_reval_amort := 0;
			l_part_reval_exp := 0;
		END IF;

		l_app_deprn_amt := l_deprn_amount + l_app_deprn_amt;

		IF (l_total_units = l_app_units) THEN
		    l_deprn_amount := l_total_deprn_amt -
					(l_app_deprn_amt - l_deprn_amount);
		END IF;

/*
		IF (l_prev_ytd_deprn <> 0) THEN
		   l_ytd_deprn := l_deprn_amount + l_prev_ytd_deprn;
		END IF;
*/

/*
dbms_output.put_line('inserting set_of_books_id' || p_rsob_id);
dbms_output.put_line('inserting book_type_code' || p_book_type_code);
dbms_output.put_line('inserting asset_id ' || l_asset_id);
dbms_output.put_line('inserting period_counter' || l_period_counter);
dbms_output.put_line('inserting distribution_id' || l_distribution_id);
*/
	-- Now insert the row into FA_MC_DEPRN_DETAIL

		INSERT INTO FA_MC_DEPRN_DETAIL(
					set_of_books_id,
					book_type_code,
					asset_id,
					period_counter,
					distribution_id,
					deprn_source_code,
					deprn_run_date,
					deprn_amount,
					ytd_deprn,
					deprn_reserve,
					addition_cost_to_clear,
					cost,
					deprn_adjustment_amount,
					deprn_expense_je_line_num,
					deprn_reserve_je_line_num,
					reval_amort_je_line_num,
					reval_reserve_je_line_num,
					je_header_id,
					reval_amortization,
					reval_deprn_expense,
					reval_reserve,
					ytd_reval_deprn_expense,
					converted_flag,
					bonus_deprn_expense_ccid,
					bonus_deprn_reserve_ccid,
					deprn_expense_ccid,
					deprn_reserve_ccid,
					reval_amort_ccid,
					reval_reserve_ccid)
		VALUES(
			p_rsob_id,
			p_book_type_code,
			l_asset_id,
			l_period_counter,
			l_distribution_id,
			l_deprn_source_code,
			l_deprn_run_date,
			l_deprn_amount,
			l_ytd_deprn,
			l_part_deprn_rsv,
			DECODE(l_deprn_source_code,
				'B', l_part_cost, 0),
			DECODE(l_deprn_source_code,
                                'D', l_part_cost, 0),
			l_deprn_adjustment_amount,
			l_deprn_expense_je_line_num,
			l_deprn_reserve_je_line_num,
			l_reval_amort_je_line_num,
			l_reval_reserve_je_line_num,
			l_je_header_id,
			l_part_reval_amort,
			l_part_reval_exp,
			l_part_reval_rsv,
			l_ytd_reval_deprn_expense,
			'Y',
			l_bonus_deprn_expense_ccid,
			l_bonus_deprn_reserve_ccid,
			l_deprn_expense_ccid,
			l_deprn_reserve_ccid,
			l_reval_amort_ccid,
			l_reval_reserve_ccid
			);

	END LOOP;
	CLOSE dd_row;

        if (g_print_debug) then
           fa_debug_pkg.add('convert_assets',
                            'Converted FA_DEPRN_DETAIL records',
                            'success');
        end if;

EXCEPTION
        WHEN OTHERS THEN
                fa_srvr_msg.add_sql_error (
                        calling_fn => 'fa_mc_upg2_pkg.convert_detail');
                app_exception.raise_exception;

END convert_deprn_detail;


PROCEDURE convert_deprn_periods (
                p_rsob_id               IN      NUMBER,
                p_book_type_code        IN      VARCHAR2,
                p_start_pc              IN      NUMBER,
                p_end_pc                IN      NUMBER) IS
/* ************************************************************************
   This procedure will convert fa_deprn_periods records for the Primary
   Book to the reporting book. All existing records in fa_mc_deprn_periods
   for the reporting book are first deleted. To preserve the trail as to
   when the reporting book was first set up, fa_deprn_period rows will be
   fetched using the first period counter in fa_mc_deprn_periods all the
   way upto the current open period. This will ensure that the primary
   book and reporting book have the same open periods after conversion
   is completed.
************************************************************************ */

	l_pc	number;
BEGIN
        if (g_print_debug) then
           fa_debug_pkg.add('convert_assets',
                            'Converting FA_DEPRN_PERIODS records',
                            'start');
        end if;

	SELECT 	min(period_counter)
	INTO	l_pc
	FROM 	fa_mc_deprn_periods
	WHERE
		set_of_books_id = p_rsob_id AND
		book_type_code = p_book_type_code;

	DELETE FROM fa_mc_deprn_periods
	WHERE
		set_of_books_id = p_rsob_id AND
                book_type_code = p_book_type_code;

	INSERT INTO fa_mc_deprn_periods(
			set_of_books_id,
			book_type_code,
			period_name,
			period_counter,
			fiscal_year,
			period_num,
			period_open_date,
			period_close_date,
			depreciation_batch_id,
			retirement_batch_id,
			reclass_batch_id,
			transfer_batch_id,
			addition_batch_id,
			adjustment_batch_id,
			deferred_deprn_batch_id,
			calendar_period_open_date,
			calendar_period_close_date,
			cip_addition_batch_id,
			cip_adjustment_batch_id,
			cip_reclass_batch_id,
			cip_retirement_batch_id,
			cip_reval_batch_id,
			cip_transfer_batch_id,
			reval_batch_id,
			deprn_adjustment_batch_id)
	SELECT
		p_rsob_id,
		dp.book_type_code,
		dp.period_name,
		dp.period_counter,
		dp.fiscal_year,
		dp.period_num,
		dp.period_open_date,
		dp.period_close_date,
		dp.depreciation_batch_id,
		dp.retirement_batch_id,
		dp.reclass_batch_id,
		dp.transfer_batch_id,
		dp.addition_batch_id,
		dp.adjustment_batch_id,
		dp.deferred_deprn_batch_id,
		dp.calendar_period_open_date,
		dp.calendar_period_close_date,
		dp.cip_addition_batch_id,
		dp.cip_adjustment_batch_id,
		dp.cip_reclass_batch_id,
		dp.cip_retirement_batch_id,
		dp.cip_reval_batch_id,
		dp.cip_transfer_batch_id,
		dp.reval_batch_id,
		dp.deprn_adjustment_batch_id
	FROM
		fa_deprn_periods dp
	WHERE
		dp.book_type_code = p_book_type_code AND
		dp.period_counter between l_pc and p_end_pc;

        if (g_print_debug) then
           fa_debug_pkg.add('convert_assets',
                            'Converted FA_DEPRN_PERIODS records',
                            'success');
        end if;

EXCEPTION
        WHEN OTHERS THEN
                fa_srvr_msg.add_sql_error (
                        calling_fn => 'fa_mc_upg2_pkg.convert_deprn_periods');
                app_exception.raise_exception;

END convert_deprn_periods;


PROCEDURE convert_deferred_deprn (
                	p_rsob_id               IN      NUMBER,
                	p_book_type_code        IN      VARCHAR2,
                	p_start_pc              IN      NUMBER,
                	p_end_pc                IN      NUMBER,
                	p_numerator_rate        IN      NUMBER,
                	p_denominator_rate      IN      NUMBER,
                	p_mau                   IN      NUMBER,
                	p_precision             IN      NUMBER) IS
/* ************************************************************************
   This procedure will convert all rows in fa_deferred_deprn to the
   reporting book. fa_deferred_deprn will only be converted if the Primary
   Book is a TAX book since deferred deprn is relevant to the difference
   in depreciation between tax and corporate book for a given period.
   deferred deprn information is posted to the GL set of books that
   TAX book is associated to in the primary book and thus this only
   needs to be converted for candidate assets in a TAX book with reporting
   books associated to it.
************************************************************************ */

        l_book_class            varchar2(15);
BEGIN

        if (g_print_debug) then
           fa_debug_pkg.add('convert_assets',
                            'Converting FA_DEFERRED_DEPRN records',
                            'start');
        end if;

        SELECT  book_class
        INTO    l_book_class
        FROM    fa_book_controls
        WHERE   book_type_code = p_book_type_code;

        IF (l_book_class = 'TAX') THEN

                INSERT INTO fa_mc_deferred_deprn(
                                set_of_books_id,
                                corp_book_type_code,
                                tax_book_type_code,
                                asset_id,
                                distribution_id,
                                deferred_deprn_expense_ccid,
                                deferred_deprn_reserve_ccid,
                                deferred_deprn_expense_amount,
                                deferred_deprn_reserve_amount,
                                corp_period_counter,
                                tax_period_counter,
                                je_header_id,
                                expense_je_line_num,
                                reserve_je_line_num)
                SELECT
                        p_rsob_id,
                        dd.corp_book_type_code,
                        p_book_type_code,
                        dd.asset_id,
                        dd.distribution_id,
                        dd.deferred_deprn_expense_ccid,
                        dd.deferred_deprn_reserve_ccid,
                	DECODE(p_mau,
                        	NULL, ROUND(
                                    DECODE(cr.conversion_basis,
                                        'C',(dd.deferred_deprn_expense_amount *
                                            (cr.cost/cr.primary_cur_cost)),

                                        'R',(dd.deferred_deprn_expense_amount/
                                                p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate)
                                    ), p_precision),
                             	ROUND(
                                   DECODE(cr.conversion_basis,
                                        'C',(dd.deferred_deprn_expense_amount *
                                            (cr.cost/cr.primary_cur_cost)),
                                        'R',(dd.deferred_deprn_expense_amount/
                                                p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate))
                                    / p_mau) * p_mau),
                        DECODE(p_mau,
                                NULL, ROUND(
                                    DECODE(cr.conversion_basis,
                                        'C',(dd.deferred_deprn_reserve_amount *
                                            (cr.cost/cr.primary_cur_cost)),
                                        'R',(dd.deferred_deprn_reserve_amount/
                                                p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate)
                                    ), p_precision),
                                ROUND(
                                   DECODE(cr.conversion_basis,
                                        'C',(dd.deferred_deprn_reserve_amount *
                                            (cr.cost/cr.primary_cur_cost)),
                                        'R',(dd.deferred_deprn_reserve_amount/
                                                p_denominator_rate)
                                                        *
                                                DECODE(cr.exchange_rate,
                                                        NULL, p_numerator_rate,
                                                        cr.exchange_rate))
                                    / p_mau) * p_mau),
                        dd.corp_period_counter,
                        dd.tax_period_counter,
                        dd.je_header_id,
                        dd.expense_je_line_num,
                        dd.reserve_je_line_num
                FROM
                        fa_deferred_deprn dd,
                        fa_book_controls bc,
                        fa_mc_conversion_rates cr
                WHERE
                        cr.book_type_code = p_book_type_code AND
                        cr.set_of_books_id = p_rsob_id AND
                        cr.status = 'S' AND
                        bc.book_type_code = cr.book_type_code AND
                        cr.asset_id = dd.asset_id AND
                        dd.corp_book_type_code = bc.distribution_source_book AND
                        dd.tax_book_type_code = bc.book_type_code;

        END IF;

        if (g_print_debug) then
           fa_debug_pkg.add('convert_assets',
                            'Converted FA_DEFERRED_DEPRN records',
                            'success');
        end if;


EXCEPTION
        WHEN OTHERS THEN
                fa_srvr_msg.add_sql_error (
                        calling_fn => 'fa_mc_upg2_pkg.convert_deferred_deprn');
                app_exception.raise_exception;

END convert_deferred_deprn;

END FA_MC_UPG2_PKG;

/
