--------------------------------------------------------
--  DDL for Package Body FA_MC_UPG3_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_MC_UPG3_PKG" AS
/* $Header: faxmcu3b.pls 120.5.12010000.3 2009/07/19 10:08:18 glchen ship $  */

	-- Global types and variables

	-- record to hold the total entered and accounted amts for a ccid
	TYPE ccid_table_rec IS RECORD (
		ccid		NUMBER(15),
		entered_dr	NUMBER,		-- functional amount
		entered_cr	NUMBER,
		accounted_dr	NUMBER,		-- reporting amount
		accounted_cr 	NUMBER);

	-- array of records to hold all the ccid's and amounts
	TYPE ccid_table is TABLE of ccid_table_rec
		INDEX BY BINARY_INTEGER;

	-- array to hold the coa structure with all columns
	TYPE flex_table IS TABLE OF VARCHAR2(25)
		INDEX BY BINARY_INTEGER;

	-- Count variables to hold the number of entries in all
  	-- ccid arrays

	G_drsv_ccid_count	NUMBER := 0;
	G_dexp_ccid_count	NUMBER := 0;
	G_rrsv_ccid_count	NUMBER := 0;
	G_ramo_ccid_count	NUMBER := 0;
	G_adj_ccid_count 	NUMBER := 0;
	G_dfrsv_ccid_count	NUMBER := 0;
	G_dfexp_ccid_count	NUMBER := 0;
	G_flex_seg_count	NUMBER := 0;

	-- ccid arrays
	deprn_reserve_ccids	ccid_table;
	deprn_expense_ccids	ccid_table;
	reval_reserve_ccids	ccid_table;
	reval_amort_ccids	ccid_table;
	adjustments_ccids	ccid_table;
	def_deprn_rsv_ccids	ccid_table;
	def_deprn_exp_ccids	ccid_table;

	G_book_class		VARCHAR2(15);
	G_rbook_name		VARCHAR2(30);
	G_coa_id		NUMBER;
	G_re_ccid		NUMBER;
	coa_structure		flex_table;
	G_flex_buf		VARCHAR2(750);
	G_bal_seg_col		VARCHAR2(25);
	G_insert_buf		VARCHAR2(4000); -- holds dynamic insert stmt
	G_start_pc		NUMBER;
	G_end_pc		NUMBER;

	G_category_name		VARCHAR2(25);
	G_source_name		VARCHAR2(25);
	G_accounting_date	DATE;
	G_group_id		NUMBER;
	G_actual_flag		VARCHAR2(1) := 'A';
	G_status		VARCHAR2(50) := 'NEW';
	G_from_currency		VARCHAR2(15);

g_print_debug boolean := fa_cache_pkg.fa_print_debug;

PROCEDURE check_conversion_status (
			p_rsob_id               IN      NUMBER,
			p_book_type_code        IN      VARCHAR2) IS
/* ************************************************************************
   This procedure checks to see if conversion has been run the given
   Primary Book - Reporting Book combination. Calculation of balances
   and transferring to GL can only be run after conversion has completed
   successfully and the conversion was not a fixed rate conversion.
   This procedure raises an exception if conversion has not completed or
   conversion was done using a fixed rate. We also retrieve the period
   information from conversion history table.
************************************************************************ */

	l_status		VARCHAR2(1);
	l_fixed_conversion	VARCHAR2(1);

	conversion_error	EXCEPTION;
	fixed_rate_error	EXCEPTION;

	CURSOR get_status IS
		SELECT
			conversion_status,
			period_counter_start,
			period_counter_converted,
			fixed_rate_conversion
		FROM
			fa_mc_conversion_history
		WHERE
			set_of_books_id = p_rsob_id AND
			book_type_code = p_book_type_code;
BEGIN

	OPEN get_status;
	FETCH get_status INTO
			l_status,
			G_start_pc,
			G_end_pc,
			l_fixed_conversion;
	IF (get_status%NOTFOUND) THEN
	   RAISE conversion_error;
	ELSIF (l_status <> 'C') THEN
	   RAISE conversion_error;
	ELSIF (l_fixed_conversion = 'Y') THEN
	   RAISE fixed_rate_error;
	END IF;

EXCEPTION
	WHEN conversion_error THEN
		fa_srvr_msg.add_message(
			calling_fn  => 'fa_mc_upg3_pkg.check_conversion_status',
			name 	    => 'FA_MRC_NO_CONVERSION',
			token1	    => 'BOOK',
			value1	    => p_book_type_code,
			token2      => 'REPORTING_BOOK',
			value2	    => G_rbook_name);
                app_exception.raise_exception;

	WHEN fixed_rate_error THEN
		fa_srvr_msg.add_message(
			calling_fn  => 'fa_mc_upg3_pkg.check_conversion_status',
			name 	    => 'FA_MRC_FIXED_RATE_CONVERSION',
                        token1      => 'REPORTING_BOOK',
                        value1      => G_rbook_name);
                app_exception.raise_exception;

	WHEN OTHERS THEN
                fa_srvr_msg.add_sql_error (
                        calling_fn => 'fa_mc_upg3_pkg.check_conversion_status');
                app_exception.raise_exception;

END check_conversion_status;


PROCEDURE calculate_balances(
			p_reporting_book	IN 	VARCHAR2,
                        p_book_type_code        IN      VARCHAR2) IS
/* ************************************************************************
   This procedure is the driving routine to calculate balances for all
   the unique CCIDS that transactions to the candidate assets have been
   posted to. Get the conversion info, check conversion status and ensure
   that all periods have been posted to in the Primary Book before
   calculating balances. After the balances have been obtained for all the
   CCIDS, we will create rows in GL_INTERFACE for them to be posted.
   Any out of balance entries for a balancing segment caused due to
   activity to revenue/expense accounts for past years will be plugged
   into retained earnings account for that balancing segment.
************************************************************************ */

        l_psob_id               NUMBER;
        l_rsob_id               NUMBER;
        l_to_currency           VARCHAR2(10);
        l_start_pc              NUMBER;
        l_end_pc                NUMBER;
        l_conv_date             date;
        l_conv_type             VARCHAR2(15);
	l_accounting_date	DATE;

	book_info_error		EXCEPTION;

	CURSOR get_book_info IS
		SELECT
			mbc.primary_set_of_books_id,
			gls.set_of_books_id,
			mbc.primary_currency_code,
			bc.book_class
		FROM
			gl_sets_of_books gls,
			fa_book_controls bc,
			fa_mc_book_controls mbc
		WHERE
			mbc.book_type_code = p_book_type_code AND
			mbc.set_of_books_id = gls.set_of_books_id AND
			bc.book_type_code = mbc.book_type_code AND
			gls.name = p_reporting_book;

BEGIN

        if not fa_cache_pkg.fazcbc(X_book => p_book_type_code) then
           RAISE  book_info_error;
        end if;

	G_rbook_name := p_reporting_book;
	OPEN get_book_info;
	FETCH get_book_info INTO
			l_psob_id,
			l_rsob_id,
			G_from_currency,
			G_book_class;

	IF (get_book_info%NOTFOUND) THEN
	   RAISE  book_info_error;
	END IF;
	CLOSE get_book_info;

	check_conversion_status(
			l_rsob_id,
			p_book_type_code);

        fa_mc_upg1_pkg.get_conversion_info(
                        p_book_type_code,
                        l_psob_id,
                        l_rsob_id,
                        l_start_pc,
                        l_end_pc,
                        l_conv_date,
                        l_conv_type,
			l_accounting_date);

	G_accounting_date := l_accounting_date;
	-- G_accounting_date := sysdate;

        if (g_print_debug) then
           fa_debug_pkg.add('calculate_balances',
                            'Accounting Date to post to GL',
                            G_accounting_date);
        end if;


	-- check if all periods in primary book have been posted to GL
	check_period_posted(
			p_book_type_code,
			l_start_pc,
			l_end_pc);
        get_adj_balances(
			l_rsob_id,
                        p_book_type_code);

	get_deprn_reserve_balances(
			l_rsob_id,
                        p_book_type_code);

	get_deprn_exp_balances(
                        l_rsob_id,
                        p_book_type_code);

        get_reval_rsv_balances(
                        l_rsob_id,
                        p_book_type_code);

        get_reval_amort_balances(
                        l_rsob_id,
                        p_book_type_code);

	IF (G_book_class = 'TAX') THEN
	    get_def_rsv_balances(
				l_rsob_id,
				p_book_type_code);
	    get_def_exp_balances(
				l_rsob_id,
				p_book_type_code);
	END IF;

	get_coa_info(
		p_book_type_code,
		l_rsob_id);

	insert_balances(
			l_rsob_id);

	insert_ret_earnings(
			p_book_type_code,
			l_rsob_id);

	COMMIT;

EXCEPTION
	WHEN book_info_error THEN
		fa_srvr_msg.add_message(
			calling_fn 	=> 'fa_mc_upg3_pkg.calculate_balances',
			name 		=> 'FA_MRC_BOOK_NOT_ASSOCIATED',
			token1 		=> 'REPORTING_BOOK',
			value1		=> G_rbook_name,
			token2		=> 'BOOK',
			value2		=> p_book_type_code);
                app_exception.raise_exception;

	WHEN OTHERS THEN
	 	fa_srvr_msg.add_sql_error (
                	calling_fn => 'fa_mc_upg3_pkg.calculate_balances');
                app_exception.raise_exception;

END calculate_balances;


PROCEDURE check_period_posted(
                        p_book_type_code	IN	VARCHAR2,
                        p_start_pc		IN	NUMBER,
                        p_end_pc		IN	NUMBER) IS
/* ************************************************************************
   This procedure checks to see if all periods in the Primary Book have
   been posted to GL. To initialize balances for all the depreciation
   expense and reserve accounts in the fiscal year being converted all
   periods must be posted.
************************************************************************ */

	l_allow_posting		VARCHAR2(3);
	l_count			NUMBER;
	unposted_error		EXCEPTION;
--commented for bug# 5190890
/*	CURSOR unposted_periods IS
		SELECT	count(*)
		FROM
			fa_book_controls bc,
			fa_deprn_periods dp
		WHERE
			bc.book_type_code = p_book_type_code AND
			dp.book_type_code = p_book_type_code AND
			dp.period_counter between
				(bc.initial_period_counter + 1) and
				 p_end_pc - 1 AND
			(dp.depreciation_batch_id is NULL AND
			 dp.retirement_batch_id is NULL AND
			 dp.reclass_batch_id is NULL AND
			 dp.transfer_batch_id is NULL AND
			 dp.addition_batch_id is NULL AND
			 dp.adjustment_batch_id is NULL AND
			 dp.deferred_deprn_batch_id is NULL AND
			 dp.cip_addition_batch_id is NULL AND
			 dp.cip_adjustment_batch_id is NULL AND
			 dp.cip_reclass_batch_id is NULL AND
			 dp.cip_retirement_batch_id is NULL AND
			 dp.cip_reval_batch_id is NULL AND
			 dp.cip_transfer_batch_id is NULL AND
			 dp.reval_batch_id is NULL AND
			 dp.deprn_adjustment_batch_id is NULL);*/

BEGIN
	SELECT 	bc.gl_posting_allowed_flag
	INTO	l_allow_posting
	FROM	fa_book_controls bc
	WHERE 	bc.book_type_code = p_book_type_code;
--added for bug# 5190890
        SELECT 	count(*)
	INTO	l_count
	FROM	fa_deprn_periods dp
	WHERE 	dp.book_type_code = p_book_type_code
	and     nvl(gl_transfer_flag,'N')<>'Y'
	and period_close_date  is not null
        and deprn_run is not null;

	IF (l_allow_posting = 'YES') THEN
	   IF (l_count > 0) THEN
	      RAISE unposted_error;
	   END IF;
	END IF;

EXCEPTION
	WHEN unposted_error THEN
                fa_srvr_msg.add_message(
                        calling_fn 	=> 'fa_mc_upg3_pkg.check_period_posted',
                        name 		=> 'FA_MRC_PERIODS_NOT_POSTED',
			token1		=> 'BOOK',
			value1		=> p_book_type_code);
                app_exception.raise_exception;
	WHEN OTHERS THEN
                fa_srvr_msg.add_sql_error (
                        calling_fn => 'fa_mc_upg3_pkg.check_period_posted');
                app_exception.raise_exception;

END check_period_posted;


PROCEDURE get_adj_balances(
                        p_rsob_id               IN      NUMBER,
                        p_book_type_code        IN      VARCHAR2) IS
/* ************************************************************************
   This procedure gets the balances for all the unique CCID's except for
   EXPENSE, RESERVE and REVAL RESERVE CCID's. The total debit and credit
   amounts for each CCID retrieved is stored in an array and each CCID
   will have 1 entry in the array and running total is maintained. The
   sum from FA_ADJUSTMENTS will give the entered balances and the sum
   from FA_MC_ADJUSTMENTS will give the accounted balances.
************************************************************************ */
 -- join conditions added to the cursor inorder to resolve MRC Upgrade issue
	CURSOR adj_bal IS
                SELECT  nvl(sum(maj.adjustment_amount),0),
			nvl(sum(aj.adjustment_amount),0),
                        aj.code_combination_id,
                        aj.debit_credit_flag
                FROM
                        fa_mc_adjustments maj,
			fa_adjustments aj,
                        fa_mc_conversion_rates cr
                WHERE
                        cr.set_of_books_id = p_rsob_id AND
                        maj.set_of_books_id = cr.set_of_books_id AND
                        cr.book_type_code = p_book_type_code AND
                        maj.book_type_code = cr.book_type_code AND
			aj.period_counter_created = maj.period_counter_created AND
			aj.period_counter_adjusted = maj.period_counter_adjusted AND
			aj.source_type_code = maj.source_type_code AND
			aj.transaction_header_id = maj.transaction_header_id  AND
			aj.asset_id = cr.asset_id AND
			aj.code_combination_id = maj.code_combination_id AND
			aj.debit_credit_flag  = maj.debit_credit_flag AND
			aj.distribution_id = maj.distribution_id AND
			aj.asset_id = maj.asset_id AND
			aj.book_type_code = cr.book_type_code AND
			aj.adjustment_type = maj.adjustment_type AND
			aj.adjustment_type not in ('RESERVE',
						   'EXPENSE',
						   'REVAL RESERVE')
                GROUP BY
                         aj.code_combination_id,
                         aj.debit_credit_flag;

                l_balance               NUMBER;
                l_ccid                  NUMBER;
                l_dr_cr_flag            VARCHAR2(2);
		l_rbalance		NUMBER;
		l_fbalance		NUMBER;

		l_found			BOOLEAN;
		l_index			NUMBER;
BEGIN
        if (g_print_debug) then
           fa_debug_pkg.add('calculate_balances',
                            'Getting Balances from FA_ADJUSTMENTS',
                            'start');
        end if;

	OPEN adj_bal;
        LOOP
       	   FETCH adj_bal into
                      	l_rbalance,
			l_fbalance,
                        l_ccid,
                        l_dr_cr_flag;

           if (adj_bal%NOTFOUND) then
               exit;
           end if;

/*
dbms_output.put_line('l_rbalance: ' || l_rbalance);
dbms_output.put_line('l_fbalance ' || l_fbalance);
dbms_output.put_line('l_ccid: ' || l_ccid);
dbms_output.put_line('l_dr_cr_flag: ' || l_dr_cr_flag);
*/
	   find_ccid(
		l_ccid,
                'ADJUSTMENTS',
                l_found,
                l_index);

	   IF (l_found) THEN
		IF (l_dr_cr_flag = 'DR') THEN
		   adjustments_ccids(l_index).entered_dr :=
			adjustments_ccids(l_index).entered_dr + l_fbalance;
		   adjustments_ccids(l_index).accounted_dr :=
			adjustments_ccids(l_index).accounted_dr + l_rbalance;
		ELSE
		   adjustments_ccids(l_index).entered_cr :=
			adjustments_ccids(l_index).entered_cr + l_fbalance;
		   adjustments_ccids(l_index).accounted_cr :=
			 adjustments_ccids(l_index).accounted_cr + l_rbalance;
		END IF;
	   ELSE
		G_adj_ccid_count := G_adj_ccid_count + 1;

		adjustments_ccids(G_adj_ccid_count).entered_dr := 0;
		adjustments_ccids(G_adj_ccid_count).accounted_dr := 0;
		adjustments_ccids(G_adj_ccid_count).entered_cr := 0;
		adjustments_ccids(G_adj_ccid_count).accounted_cr := 0;

		IF (l_dr_cr_flag = 'DR') THEN
		    adjustments_ccids(G_adj_ccid_count).entered_dr :=
			adjustments_ccids(G_adj_ccid_count).entered_dr +
							l_fbalance;
		    adjustments_ccids(G_adj_ccid_count).accounted_dr :=
			adjustments_ccids(G_adj_ccid_count).accounted_dr +
							l_rbalance;
		ELSE
                    adjustments_ccids(G_adj_ccid_count).entered_cr :=
                        adjustments_ccids(G_adj_ccid_count).entered_cr +
							l_fbalance;
                    adjustments_ccids(G_adj_ccid_count).accounted_cr :=
                        adjustments_ccids(G_adj_ccid_count).accounted_cr +
							l_rbalance;
		END IF;
		adjustments_ccids(G_adj_ccid_count).ccid := l_ccid;
	   END IF;

	END LOOP;
	CLOSE adj_bal;

        if (g_print_debug) then
           fa_debug_pkg.add('calculate_balances',
                            'Getting Balances from FA_ADJUSTMENTS',
                            'success');
        end if;

/*  Debug Statements to print contents of adjustments ccid array
****************************************************************************
dbms_output.put_line('Printing Contents of Adjustments Array:');
dbms_output.put_line('Total Number of array entries: ' || G_adj_ccid_count);
dbms_output.put_line('*******************************************');

for i in 1 .. G_adj_ccid_count LOOP

dbms_output.put_line('CCID and amount: ' ||
	adjustments_ccids(i).ccid || ',' || adjustments_ccids(i).entered_dr);
dbms_output.put_line('CCID and amount: ' ||
	adjustments_ccids(i).ccid || ',' || adjustments_ccids(i).accounted_dr);
dbms_output.put_line('CCID and amount: ' ||
        adjustments_ccids(i).ccid || ',' || adjustments_ccids(i).entered_cr);
dbms_output.put_line('CCID and amount: ' ||
        adjustments_ccids(i).ccid || ',' || adjustments_ccids(i).accounted_cr);

dbms_output.put_line('-----------------------------------------------');
end LOOP;
**************************************************************************** */

EXCEPTION
	WHEN OTHERS THEN
		fa_srvr_msg.add_sql_error (
                        calling_fn => 'fa_mc_upg3_pkg.get_adj_balances');
                app_exception.raise_exception;

END get_adj_balances;


PROCEDURE get_deprn_reserve_balances(
                       	p_rsob_id               IN      NUMBER,
                       	p_book_type_code        IN      VARCHAR2) IS
/* ************************************************************************
   This procedure gets the DEPRN_RESERVE balances for all reserve CCIDS.
   For all the reserve ccid's of assets that depreciated in the fiscal
   year converted, the ccid is obtained from gl_je_lines. For assets
   with their last DEPRN row in a prior year, we look at gl_je_lines
   first and if not found the reserve CCID will be flexbuilt. The
   reserve balances are stored in a global array.
************************************************************************ */

        l_line_num              NUMBER;
	l_header_id		NUMBER;
        l_dist_ccid             NUMBER;
        l_dist_id       	NUMBER;
        l_pc                    NUMBER;
        l_rsv_account           VARCHAR2(25);
        l_account_ccid          NUMBER;
        l_calculated_ccid       NUMBER;
        l_ccid                  NUMBER;
        l_total_func_rsv        NUMBER;
        l_total_rep_rsv         NUMBER;

	l_found			BOOLEAN;
	l_index			NUMBER;

	invalid_ccid		EXCEPTION;
	reserve_error		EXCEPTION;


        CURSOR get_periods IS
                SELECT  distinct last_period_counter
                FROM    fa_mc_conversion_rates
                WHERE
                        set_of_books_id = p_rsob_id AND
                        book_type_code = p_book_type_code;

        CURSOR reserve_line_num IS
                SELECT  distinct deprn_reserve_je_line_num, je_header_id
                FROM    fa_mc_deprn_detail
                where   period_counter = l_pc AND
                        book_type_code = p_book_type_code AND
                        set_of_books_id = p_rsob_id AND
			deprn_reserve_je_line_num is not null AND
			je_header_id is not null;

        CURSOR get_ccid IS
                select
			gjl.code_combination_id
                from
			gl_je_lines gjl
                where
                        gjl.je_header_id = l_header_id AND
                        gjl.je_line_num = l_line_num;

        CURSOR ccid_total IS
                SELECT
			sum(mdd.deprn_reserve),
			sum(dd.deprn_reserve)
                FROM
			fa_deprn_detail dd,
			fa_mc_deprn_detail mdd,
			fa_mc_conversion_rates cr
                WHERE
			cr.last_period_counter = l_pc AND
			cr.set_of_books_id = p_rsob_id AND
			cr.book_type_code = p_book_type_code AND
			mdd.period_counter = cr.last_period_counter AND
                        mdd.set_of_books_id = cr.set_of_books_id AND
                        mdd.book_type_code = cr.book_type_code AND
                        mdd.deprn_reserve_je_line_num = l_line_num AND
			dd.deprn_reserve_je_line_num =
					mdd.deprn_reserve_je_line_num AND
			dd.period_counter = mdd.period_counter AND
			dd.book_type_code = mdd.book_type_code AND
			mdd.asset_id = cr.asset_id AND
			dd.asset_id = mdd.asset_id AND
			dd.distribution_id = mdd.distribution_id;

BEGIN
        if (g_print_debug) then
            fa_debug_pkg.add('calculate_balances',
                            'Getting deprn reserve from balances',
                            'start');
        end if;

	OPEN get_periods;
	LOOP
	   FETCH get_periods into l_pc;
	   if (get_periods%NOTFOUND) then
	       exit;
	   end if;
-- dbms_output.put_line('Processing period counter: ' || l_pc);
	   OPEN reserve_line_num;
	   	LOOP
		   FETCH reserve_line_num into l_line_num, l_header_id;
		   if (reserve_line_num%NOTFOUND) then
		      exit;
		   end if;

-- dbms_output.put_line('Processing je line num: ' || l_line_num);
-- dbms_output.put_line('Processing je header id: ' || l_header_id);

		   OPEN get_ccid;
		   FETCH get_ccid into l_ccid;

-- dbms_output.put_line('Fetched ccid: ' || l_ccid);

		   IF (get_ccid%NOTFOUND) THEN

-- dbms_output.put_line('Could not find ccid in gl_je_lines');
-- dbms_output.put_line('Calling FAFBGCC');

		      -- could not find the ccid in gl_je_lines
		      -- need to flexbuild the reserve account
		      -- need one distribution_id to build the account
		      -- even if there are several assets with different
		      -- distribution_id's, the fact that they have the same
		      -- reserve line num means they went to the same account
		      -- as a result we can minimize flexbuild as much as
		      -- as possible

		      SELECT
				dd.distribution_id,
				dh.code_combination_id,
                        	cb.deprn_reserve_acct,
                        	cb.reserve_account_ccid
		      INTO
				l_dist_id,
				l_dist_ccid,
				l_rsv_account,
				l_account_ccid
		      FROM
				fa_deprn_detail dd,
				fa_category_books cb,
				fa_asset_history ah,
				fa_distribution_history dh
		      WHERE
				dd.book_type_code = p_book_type_code AND
				dd.period_counter = l_pc AND
				dd.deprn_reserve_je_line_num = l_line_num AND
				dd.distribution_id = dh.distribution_id AND
				dd.asset_id = ah.asset_id AND
				ah.category_id = cb.category_id AND
				ah.date_ineffective is null AND
				cb.book_type_code = dd.book_type_code AND
				rownum = 1;

                      IF (not FA_GCCID_PKG.fafbgcc(
                                X_book_type_code=>p_book_type_code,
                                X_fn_trx_code=>'DEPRN_RESERVE_ACCT',
                                X_dist_ccid=>l_dist_ccid,
                                X_acct_segval=>l_rsv_account,
                                X_account_ccid=>l_account_ccid,
                                X_distribution_id=>l_dist_id,
                                X_rtn_ccid=>l_ccid)) THEN
                   	    RAISE invalid_ccid;
		      END IF;
-- dbms_output.put_line('After FAFBGCC ccid is: ' || to_char(l_ccid));
		   END IF;
		CLOSE get_ccid;

		OPEN ccid_total;
		FETCH ccid_total into
				l_total_rep_rsv,
				l_total_func_rsv;

-- dbms_output.put_line('Total rep_rsv: ' || l_total_rep_rsv);
-- dbms_output.put_line('Total func_rsv: '|| l_total_func_rsv);

		IF (ccid_total%NOTFOUND) THEN
			RAISE reserve_error;
		END IF;
		CLOSE ccid_total;

           	find_ccid(
                	l_ccid,
                	'RESERVE',
                	l_found,
                	l_index);

           	IF (l_found) THEN
                   deprn_reserve_ccids(l_index).entered_cr :=
                        deprn_reserve_ccids(l_index).entered_cr +
							l_total_func_rsv;
                   deprn_reserve_ccids(l_index).accounted_cr :=
                        deprn_reserve_ccids(l_index).accounted_cr +
							l_total_rep_rsv;
                ELSE

                   G_drsv_ccid_count := G_drsv_ccid_count + 1;

                   deprn_reserve_ccids(G_drsv_ccid_count).entered_dr := 0;
                   deprn_reserve_ccids(G_drsv_ccid_count).accounted_dr := 0;
                   deprn_reserve_ccids(G_drsv_ccid_count).entered_cr := 0;
                   deprn_reserve_ccids(G_drsv_ccid_count).accounted_cr := 0;

                   deprn_reserve_ccids(G_drsv_ccid_count).entered_cr :=
                    	deprn_reserve_ccids(G_drsv_ccid_count).entered_cr
						+ l_total_func_rsv;
                   deprn_reserve_ccids(G_drsv_ccid_count).accounted_cr :=
                     	deprn_reserve_ccids(G_drsv_ccid_count).accounted_cr
						+ l_total_rep_rsv;
                   deprn_reserve_ccids(G_drsv_ccid_count).ccid := l_ccid;

		END IF;
	    end LOOP;
	    CLOSE reserve_line_num;
	end LOOP;
	CLOSE get_periods;

        if (g_print_debug) then
            fa_debug_pkg.add('calculate_balances',
                            'Getting deprn reserve balances',
                            'success');
        end if;

/* Debug Statements to print contents of deprn reeserve ccid array
****************************************************************************
dbms_output.put_line('Printing Contents of Deprn Reserve  Array:');
dbms_output.put_line('Total Number of array entries: ' || G_drsv_ccid_count);
dbms_output.put_line('*******************************************');

for i in 1 .. G_drsv_ccid_count LOOP

dbms_output.put_line('CCID and amount: ' ||
        deprn_reserve_ccids(i).ccid || ',' || deprn_reserve_ccids(i).entered_dr);
dbms_output.put_line('CCID and amount: ' ||
        deprn_reserve_ccids(i).ccid || ',' || deprn_reserve_ccids(i).accounted_dr);
dbms_output.put_line('CCID and amount: ' ||
        deprn_reserve_ccids(i).ccid || ',' || deprn_reserve_ccids(i).entered_cr);
dbms_output.put_line('CCID and amount: ' ||
        deprn_reserve_ccids(i).ccid || ',' || deprn_reserve_ccids(i).accounted_cr);

dbms_output.put_line('-----------------------------------------------');
end LOOP;
**************************************************************************** */

EXCEPTION
	WHEN invalid_ccid THEN
             if (g_print_debug) then
                fa_debug_pkg.add('get_deprn_reserve_balances',
                                 'Error Getting reserve ccid ',
                                 'failure');
             end if;

             fa_srvr_msg.add_sql_error (
                   calling_fn => 'fa_mc_upg3_pkg.get_deprn_reserve_balances');
             app_exception.raise_exception;

	WHEN reserve_error THEN
             if (g_print_debug) then
                fa_debug_pkg.add('get_deprn_reserve_balances',
                                 'Error Getting reserve for period ',
                                 l_pc);
                fa_debug_pkg.add('get_deprn_reserve_balances',
                                 'Error Getting reserve for line num ',
                                 l_line_num);
             end if;
	     fa_srvr_msg.add_sql_error (
		   calling_fn => 'fa_mc_upg3_pkg.get_deprn_reserve_balances');
             app_exception.raise_exception;

        WHEN OTHERS THEN
                fa_srvr_msg.add_sql_error (
                   calling_fn => 'fa_mc_upg3_pkg.get_deprn_reserve_balances');
                app_exception.raise_exception;

END get_deprn_reserve_balances;


PROCEDURE get_deprn_exp_balances(
                        p_rsob_id               IN      NUMBER,
                        p_book_type_code        IN      VARCHAR2) IS
/* ************************************************************************
   This procedure gets the DEPRN_AMOUNT balances for all expense CCIDS.
   For all the expense ccid's of assets that depreciated in the fiscal
   year converted, the ccid is obtained from gl_je_lines. Depreciation
   Expense only needs to be calculated for the periods in the fiscal year
   converted since prior years expense will go into retained earnings
************************************************************************ */

	l_total_func_exp	NUMBER;
	l_total_rep_exp		NUMBER;
	l_pc			NUMBER;
	l_line_num		NUMBER;
	l_header_id		NUMBER;
	l_ccid			NUMBER;
	l_found			BOOLEAN;
	l_index			NUMBER;

        CURSOR exp_line_num IS
                SELECT  distinct deprn_expense_je_line_num, je_header_id
                FROM    fa_mc_deprn_detail
                where   period_counter = l_pc AND
                        book_type_code = p_book_type_code AND
                        set_of_books_id = p_rsob_id and
			deprn_expense_je_line_num is not null and
			je_header_id is not null;

        CURSOR get_ccid IS
                SELECT
			gjl.code_combination_id
                FROM
			gl_je_lines gjl
                WHERE
                        gjl.je_header_id = l_header_id AND
                        gjl.je_line_num = l_line_num;

        CURSOR ccid_total IS
                SELECT
			nvl(sum(dd.deprn_amount),0),
			nvl(sum(mdd.deprn_amount),0)
                FROM
			fa_deprn_detail dd,
			fa_mc_deprn_detail mdd
                WHERE
			mdd.period_counter = l_pc AND
                        mdd.set_of_books_id = p_rsob_id AND
                        mdd.book_type_code = p_book_type_code AND
                        mdd.deprn_expense_je_line_num = l_line_num AND
			dd.period_counter = mdd.period_counter AND
			dd.book_type_code = mdd.book_type_code AND
			dd.deprn_expense_je_line_num =
					mdd.deprn_expense_je_line_num AND
			mdd.asset_id = dd.asset_id AND
			mdd.distribution_id = dd.distribution_id;

BEGIN
        if (g_print_debug) then
            fa_debug_pkg.add('calculate_balances',
                            'Getting deprn expense balances',
                            'start');
        end if;

        FOR i IN G_start_pc .. G_end_pc LOOP
		l_pc := i;
-- dbms_output.put_line('Processing period counter: ' || l_pc);
        	OPEN exp_line_num;
                LOOP
                        FETCH exp_line_num into l_line_num, l_header_id;
                        IF (exp_line_num%NOTFOUND) then
                            exit;
                        END IF;
-- dbms_output.put_line('Processing je line num: ' || l_line_num);
-- dbms_output.put_line('Processing je header id: ' || l_header_id);
                        OPEN get_ccid;
                        FETCH get_ccid into l_ccid;
                        CLOSE get_ccid;
-- dbms_output.put_line('Fetched ccid: ' || l_ccid);
                        OPEN ccid_total;
                        FETCH ccid_total into
					l_total_func_exp,
					l_total_rep_exp;
-- dbms_output.put_line('Total rep_exp: ' || l_total_rep_exp);
-- dbms_output.put_line('Total func_exp: '|| l_total_func_exp);

                        CLOSE ccid_total;
                find_ccid(
                        l_ccid,
                        'EXPENSE',
                        l_found,
                        l_index);

                IF (l_found) THEN
-- dbms_output.put_line('CCID found in array: ' || 'TRUE');
                   deprn_expense_ccids(l_index).entered_dr :=
                        deprn_expense_ccids(l_index).entered_dr +
                                                        l_total_func_exp;
                   deprn_expense_ccids(l_index).accounted_dr :=
                        deprn_expense_ccids(l_index).accounted_dr +
                                                        l_total_rep_exp;
                ELSE
-- dbms_output.put_line('CCID found in array: ' || 'FALSE');
                   G_dexp_ccid_count := G_dexp_ccid_count + 1;

                   deprn_expense_ccids(G_dexp_ccid_count).entered_dr := 0;
                   deprn_expense_ccids(G_dexp_ccid_count).accounted_dr := 0;
                   deprn_expense_ccids(G_dexp_ccid_count).entered_cr := 0;
                   deprn_expense_ccids(G_dexp_ccid_count).accounted_cr := 0;

                   deprn_expense_ccids(G_dexp_ccid_count).entered_dr :=
                      deprn_expense_ccids(G_dexp_ccid_count).entered_dr +
                                                   l_total_func_exp;
                   deprn_expense_ccids(G_dexp_ccid_count).accounted_dr :=
                      deprn_expense_ccids(G_dexp_ccid_count).accounted_dr +
                                                   l_total_rep_exp;
                   deprn_expense_ccids(G_dexp_ccid_count).ccid := l_ccid;
		END IF;
		END LOOP;
                CLOSE exp_line_num;
        END LOOP;

        if (g_print_debug) then
            fa_debug_pkg.add('calculate_balances',
                            'Getting deprn expense balances',
                            'success');
        end if;

/* Debug Statements to print contents of deprn expense ccid array
*****************************************************************************
dbms_output.put_line('Printing Contents of Deprn Expense  Array:');
dbms_output.put_line('Total Number of array entries: ' || G_dexp_ccid_count);
dbms_output.put_line('*******************************************');

for i in 1 .. G_dexp_ccid_count LOOP

dbms_output.put_line('CCID and amount: ' ||
deprn_expense_ccids(i).ccid || ',' || deprn_expense_ccids(i).entered_dr);
dbms_output.put_line('CCID and amount: ' ||
deprn_expense_ccids(i).ccid || ',' || deprn_expense_ccids(i).accounted_dr);
dbms_output.put_line('CCID and amount: ' ||
deprn_expense_ccids(i).ccid || ',' || deprn_expense_ccids(i).entered_cr);
dbms_output.put_line('CCID and amount: ' ||
deprn_expense_ccids(i).ccid || ',' || deprn_expense_ccids(i).accounted_cr);
dbms_output.put_line('-----------------------------------------------');
end LOOP;
**************************************************************************** */

EXCEPTION
        WHEN OTHERS THEN
                fa_srvr_msg.add_sql_error (
                        calling_fn => 'fa_mc_upg3_pkg.get_deprn_exp_balances');
                app_exception.raise_exception;

END get_deprn_exp_balances;


PROCEDURE get_reval_rsv_balances(
                        p_rsob_id               IN      NUMBER,
                        p_book_type_code        IN      VARCHAR2) IS
/* ************************************************************************
   This procedure gets the REVAL_RESERVE balances.
   For all the reval reserve ccid's of assets that depreciated in the fiscal
   year converted, the ccid is obtained from FA_ADJUSTMENTS. When a
   revaluation is perfomed REVAL RESERVE rows are created in FA_ADJUSTMENTS
   for each active distribution. If REVAL RESERVE is transferred, or retired
   there will still be a row in FA_ADJUSTMENTS for the new distribution
************************************************************************ */

	l_balance               NUMBER;
        l_ccid                  NUMBER;
        l_dr_cr_flag            VARCHAR2(2);
        l_rbalance              NUMBER;
        l_fbalance              NUMBER;
        l_found                 BOOLEAN;
        l_index                 NUMBER;

	CURSOR reval_rsv_bal IS
		SELECT
			aj.code_combination_id,
			nvl(sum(dd.reval_reserve),0),
			nvl(sum(mdd.reval_reserve),0)
		FROM
			fa_adjustments aj,
			fa_deprn_detail dd,
			fa_mc_deprn_detail mdd,
			fa_mc_conversion_rates cr
		WHERE
			cr.set_of_books_id = p_rsob_id AND
			cr.book_type_code = p_book_type_code AND
			cr.asset_id = dd.asset_id AND
			cr.last_period_counter = dd.period_counter AND
			dd.book_type_code = p_book_type_code AND
			dd.asset_id = aj.asset_id AND
			dd.book_type_code = aj.book_type_code AND
			dd.distribution_id = aj.distribution_id AND
			mdd.period_counter = dd.period_counter AND
			mdd.book_type_code = dd.book_type_code AND
			mdd.asset_id = dd.asset_id AND
			mdd.distribution_id = dd.distribution_id AND
			mdd.set_of_books_id = p_rsob_id AND
			aj.adjustment_type = 'REVAL RESERVE'
		GROUP BY
			aj.code_combination_id;

BEGIN
        if (g_print_debug) then
            fa_debug_pkg.add('calculate_balances',
                            'Getting reval reserve balances',
                            'start');
        end if;

        OPEN reval_rsv_bal;
        LOOP
                FETCH reval_rsv_bal into
                                l_ccid,
                                l_rbalance,
                                l_fbalance;

                IF (reval_rsv_bal%NOTFOUND) THEN
                     EXIT;
                END IF;
-- dbms_output.put_line('Reval rsv ccid is: ' || to_char(l_ccid));
-- dbms_output.put_line('Reval rsv l_fbalance: ' || to_char(l_fbalance));
-- dbms_output.put_line('Reval rsv l_rbalance: ' || to_char(l_rbalance));


                find_ccid(
                        l_ccid,
                        'REVAL RESERVE',
                        l_found,
                        l_index);

                IF (l_found) THEN
                   reval_reserve_ccids(l_index).entered_cr :=
                        reval_reserve_ccids(l_index).entered_cr +
                                                        l_fbalance;
                   reval_reserve_ccids(l_index).accounted_cr :=
                        reval_reserve_ccids(l_index).accounted_cr +
                                                        l_rbalance;
                ELSE
                   G_rrsv_ccid_count := G_rrsv_ccid_count + 1;
                   reval_reserve_ccids(G_rrsv_ccid_count).entered_dr := 0;
                   reval_reserve_ccids(G_rrsv_ccid_count).accounted_dr := 0;
                   reval_reserve_ccids(G_rrsv_ccid_count).entered_cr := 0;
                   reval_reserve_ccids(G_rrsv_ccid_count).accounted_cr := 0;

                   reval_reserve_ccids(G_rrsv_ccid_count).entered_cr :=
                        reval_reserve_ccids(G_rrsv_ccid_count).entered_cr
                                                + l_fbalance;
                   reval_reserve_ccids(G_rrsv_ccid_count).accounted_cr :=
                        reval_reserve_ccids(G_rrsv_ccid_count).accounted_cr
                                                + l_rbalance;
                   reval_reserve_ccids(G_rrsv_ccid_count).ccid := l_ccid;

                END IF;
        END LOOP;
	CLOSE reval_rsv_bal;

        if (g_print_debug) then
            fa_debug_pkg.add('calculate_balances',
                            'Getting reval reserve balances',
                            'success');
        end if;

EXCEPTION
        WHEN OTHERS THEN
                fa_srvr_msg.add_sql_error (
                        calling_fn => 'fa_mc_upg3_pkg.get_reval_rsv_balances');
                app_exception.raise_exception;

END get_reval_rsv_balances;


PROCEDURE get_reval_amort_balances(
                        p_rsob_id               IN      NUMBER,
                        p_book_type_code        IN      VARCHAR2) IS
/* ************************************************************************
   This procedure gets the REVAL AMORTIZATION balances.
   For all the reval_amort ccid's of assets that depreciated in the fiscal
   year converted, the ccid is obtained from gl_je_lines. Reval Amortization
   only needs to be calculated for the periods in the fiscal year.
************************************************************************ */

	l_pc		NUMBER;
	l_line_num	NUMBER;
	l_ccid		NUMBER;
	l_fbalance	NUMBER;
	l_rbalance	NUMBER;
        l_found         BOOLEAN;
        l_index         NUMBER;


        CURSOR amort_line_num IS
                SELECT  distinct reval_amort_je_line_num
                FROM    fa_mc_deprn_detail
                where   period_counter = l_pc AND
                        book_type_code = p_book_type_code AND
                        set_of_books_id = p_rsob_id AND
			reval_amort_je_line_num is not null;

        CURSOR get_ccid IS
                SELECT
                        gs.code_combination_id
                FROM
                        gl_je_lines gs,
                        gl_je_headers gh,
                        gl_je_batches gb,
                        fa_deprn_periods dp
                WHERE
                        dp.period_counter = l_pc AND
                        dp.book_type_code = p_book_type_code AND
                        dp.reval_batch_id = gb.je_batch_id AND
                        gh.je_batch_id = gb.je_batch_id AND
                        gs.je_header_id = gh.je_header_id AND
                        gs.je_line_num = l_line_num;

        CURSOR ccid_total IS
                SELECT
                        nvl(sum(dd.reval_amortization),0),
                        nvl(sum(mdd.reval_amortization),0)
                FROM
                        fa_mc_deprn_detail mdd,
                        fa_deprn_detail dd
                WHERE
                        mdd.book_type_code = p_book_type_code AND
                        mdd.period_counter = l_pc AND
                        mdd.set_of_books_id = p_rsob_id AND
                        mdd.reval_amort_je_line_num = l_line_num AND
                        dd.book_type_code = mdd.book_type_code AND
                        dd.period_counter = mdd.period_counter AND
                        dd.reval_amort_je_line_num =
                                        mdd.reval_amort_je_line_num AND
                        mdd.asset_id = dd.asset_id AND
                        mdd.distribution_id = dd.distribution_id;

BEGIN
        if (g_print_debug) then
            fa_debug_pkg.add('calculate_balances',
                            'Getting reval amort balances',
                            'start');
        end if;

        FOR l_pc IN G_start_pc .. G_end_pc LOOP
                OPEN amort_line_num;
                LOOP
                   FETCH amort_line_num into l_line_num;
                   IF (amort_line_num%NOTFOUND) THEN
                       EXIT;
                   END IF;
                   OPEN get_ccid;
                   FETCH get_ccid into l_ccid;
                   CLOSE get_ccid;
                   OPEN ccid_total;
                   FETCH ccid_total into
                                   l_fbalance,
                                   l_rbalance;
                   CLOSE ccid_total;
                   find_ccid(
                       	l_ccid,
                       	'REVAL AMORT',
                       	l_found,
                       	l_index);

                   IF (l_found) THEN
                     reval_amort_ccids(l_index).entered_cr :=
                       	reval_amort_ccids(l_index).entered_cr +
                                                       l_fbalance;
                     reval_amort_ccids(l_index).accounted_cr :=
                       	reval_amort_ccids(l_index).accounted_cr +
                                                       l_rbalance;
                   ELSE
                     G_ramo_ccid_count := G_ramo_ccid_count + 1;

                     reval_amort_ccids(G_ramo_ccid_count).entered_dr := 0;
                     reval_amort_ccids(G_ramo_ccid_count).accounted_dr := 0;
                     reval_amort_ccids(G_ramo_ccid_count).entered_cr := 0;
                     reval_amort_ccids(G_ramo_ccid_count).accounted_cr := 0;

               	     reval_amort_ccids(G_ramo_ccid_count).entered_cr :=
                       	reval_amort_ccids(G_ramo_ccid_count).entered_cr
                                                + l_fbalance;
                     reval_amort_ccids(G_ramo_ccid_count).accounted_cr :=
                       	reval_amort_ccids(G_ramo_ccid_count).accounted_cr
                                                + l_rbalance;
                     reval_amort_ccids(G_ramo_ccid_count).ccid := l_ccid;
                   END IF;
                END LOOP;
                CLOSE amort_line_num;
        END LOOP;

        if (g_print_debug) then
            fa_debug_pkg.add('calculate_balances',
                            'Getting reval amort balances',
                            'success');
        end if;

EXCEPTION
        WHEN OTHERS THEN
                fa_srvr_msg.add_sql_error (
                        calling_fn => 'fa_mc_upg3_pkg.get_reval_amort_balances');
                app_exception.raise_exception;

END get_reval_amort_balances;



PROCEDURE get_def_rsv_balances (
                        p_rsob_id               IN      NUMBER,
                        p_book_type_code        IN      VARCHAR2) IS
/* ************************************************************************
   This procedure gets the deferred depreciation reserve balances.
   We will get the deferred reserve for all years since we only store
   period reserve balances for each row and to get the total reserve
   we have to past years as well. This is required since this is a
   balance sheet account
************************************************************************ */


	l_frsv 		NUMBER;
	l_rrsv 		NUMBER;
	l_ccid		NUMBER;

	CURSOR def_rsv_balances IS
		SELECT
			nvl(sum(dd.deferred_deprn_reserve_amount),0),
			nvl(sum(mdd.deferred_deprn_reserve_amount),0),
			dd.deferred_deprn_reserve_ccid
		FROM
			fa_deferred_deprn dd,
			fa_mc_deferred_deprn mdd,
			fa_mc_conversion_rates cr
		WHERE
			cr.set_of_books_id = p_rsob_id AND
			cr.book_type_code = p_book_type_code AND
			cr.asset_id = dd.asset_id AND
			dd.tax_book_type_code = cr.book_type_code AND
			mdd.tax_book_type_code = cr.book_type_code AND
			mdd.asset_id = dd.asset_id AND
			mdd.deferred_deprn_reserve_ccid =
					dd.deferred_deprn_reserve_ccid AND
			dd.distribution_id = mdd.distribution_id AND
			dd.tax_period_counter = mdd.tax_period_counter AND
			dd.corp_period_counter = mdd.corp_period_counter AND
			dd.je_header_id = mdd.je_header_id AND
			dd.reserve_je_line_num = mdd.reserve_je_line_num
		GROUP BY
			dd.deferred_deprn_reserve_ccid;
BEGIN
        if (g_print_debug) then
           fa_debug_pkg.add('calculate_balances',
                            'Getting deferred deprn reserve balances',
                            'start');
        end if;

	OPEN def_rsv_balances;
	LOOP
	   	FETCH def_rsv_balances into l_frsv,
				       	    l_rrsv,
				            l_ccid;
		IF (def_rsv_balances%NOTFOUND) THEN
		   EXIT;
		END IF;

		G_dfrsv_ccid_count := G_dfrsv_ccid_count + 1;

		def_deprn_rsv_ccids(G_dfrsv_ccid_count).entered_cr := 0;
		def_deprn_rsv_ccids(G_dfrsv_ccid_count).entered_dr := 0;
		def_deprn_rsv_ccids(G_dfrsv_ccid_count).accounted_cr := 0;
		def_deprn_rsv_ccids(G_dfrsv_ccid_count).accounted_dr := 0;

		def_deprn_rsv_ccids(G_dfrsv_ccid_count).entered_cr :=
			def_deprn_rsv_ccids(G_dfrsv_ccid_count).entered_cr +
					l_frsv;
		def_deprn_rsv_ccids(G_dfrsv_ccid_count).accounted_cr :=
			def_deprn_rsv_ccids(G_dfrsv_ccid_count).accounted_cr +
					l_rrsv;
		def_deprn_rsv_ccids(G_dfrsv_ccid_count).ccid := l_ccid;
	END LOOP;
	CLOSE def_rsv_balances;

        if (g_print_debug) then
           fa_debug_pkg.add('calculate_balances',
                            'Getting deferred deprn reserve balances',
                            'success');
        end if;

EXCEPTION
  	WHEN OTHERS THEN
                fa_srvr_msg.add_sql_error (
                        calling_fn => 'fa_mc_upg3_pkg.get_def_rsv_balances');
                app_exception.raise_exception;
END get_def_rsv_balances;



PROCEDURE get_def_exp_balances (
                        p_rsob_id               IN      NUMBER,
                        p_book_type_code        IN      VARCHAR2) IS
/* ************************************************************************
   This procedure gets the deferred depreciation expense balances.
   We will get the deferred expense only for the fiscal year converted
   since deferred deprn expense is a expense account and past year balances
   will go to retained earnings.
************************************************************************ */


	l_fexp 		NUMBER;
	l_rexp		NUMBER;
	l_ccid		NUMBER;

	CURSOR def_exp_balances IS
                SELECT
                        nvl(sum(dd.deferred_deprn_expense_amount),0),
                        nvl(sum(mdd.deferred_deprn_expense_amount),0),
                        dd.deferred_deprn_expense_ccid
                FROM
                        fa_deferred_deprn dd,
                        fa_mc_deferred_deprn mdd,
                        fa_mc_conversion_rates cr
                WHERE
                        cr.set_of_books_id = p_rsob_id AND
                        cr.book_type_code = p_book_type_code AND
                        cr.asset_id = dd.asset_id AND
                        dd.tax_book_type_code = cr.book_type_code AND
                        mdd.tax_book_type_code = cr.book_type_code AND
                        mdd.asset_id = dd.asset_id AND
                        mdd.deferred_deprn_expense_ccid =
                                        dd.deferred_deprn_expense_ccid AND
                        dd.distribution_id = mdd.distribution_id AND
                        dd.tax_period_counter = mdd.tax_period_counter AND
                        dd.corp_period_counter = mdd.corp_period_counter AND
                        dd.je_header_id = mdd.je_header_id AND
                        dd.expense_je_line_num = mdd.expense_je_line_num AND
			dd.tax_period_counter between G_start_pc and
						      G_end_pc
                GROUP BY
                        dd.deferred_deprn_expense_ccid;
BEGIN
        if (g_print_debug) then
           fa_debug_pkg.add('calculate_balances',
                            'Getting deferred deprn exp balances',
                            'start');
        end if;

	OPEN def_exp_balances;
        LOOP
                FETCH def_exp_balances into l_fexp,
                                            l_rexp,
                                            l_ccid;
                IF (def_exp_balances%NOTFOUND) THEN
                   EXIT;
                END IF;

                G_dfexp_ccid_count := G_dfexp_ccid_count + 1;

                def_deprn_exp_ccids(G_dfexp_ccid_count).entered_cr := 0;
                def_deprn_exp_ccids(G_dfexp_ccid_count).entered_dr := 0;
                def_deprn_exp_ccids(G_dfexp_ccid_count).accounted_cr := 0;
                def_deprn_exp_ccids(G_dfexp_ccid_count).accounted_dr := 0;

                def_deprn_exp_ccids(G_dfexp_ccid_count).entered_dr :=
                        def_deprn_exp_ccids(G_dfexp_ccid_count).entered_dr +
                                        l_fexp;
                def_deprn_exp_ccids(G_dfexp_ccid_count).accounted_dr :=
                        def_deprn_exp_ccids(G_dfexp_ccid_count).accounted_dr +
                                        l_rexp;
                def_deprn_exp_ccids(G_dfexp_ccid_count).ccid := l_ccid;
        END LOOP;
        CLOSE def_exp_balances;

        if (g_print_debug) then
           fa_debug_pkg.add('calculate_balances',
                            'Getting deferred deprn exp balances',
                            'success');
        end if;

EXCEPTION
        WHEN OTHERS THEN
                fa_srvr_msg.add_sql_error (
                        calling_fn => 'fa_mc_upg3_pkg.get_def_exp_balances');
                app_exception.raise_exception;
END get_def_exp_balances;



PROCEDURE find_ccid(
			p_ccid			IN	NUMBER,
			p_adjustment_type	IN	VARCHAR2,
			X_found 	 OUT NOCOPY 	BOOLEAN,
			X_index		 OUT NOCOPY NUMBER) IS
/* ************************************************************************
   This procedure will search for a CCID within an array and returns
   the index at which the CCID was found and whether a CCID was found
   in the global array or not.
************************************************************************ */

	tmp_ccids	ccid_table;  -- temp copy of global array
	tmp_count	NUMBER;      -- temp size of global array
BEGIN
	X_found := FALSE;
	X_index := 0;

	IF (p_adjustment_type = 'RESERVE') THEN
	   tmp_ccids := deprn_reserve_ccids;
	   tmp_count := G_drsv_ccid_count;
	ELSIF (p_adjustment_type = 'EXPENSE') THEN
	   tmp_ccids := deprn_expense_ccids;
	   tmp_count := G_dexp_ccid_count;
	ELSIF (p_adjustment_type = 'REVAL RESERVE') THEN
	   tmp_ccids := reval_reserve_ccids;
	   tmp_count := G_rrsv_ccid_count;
	ELSIF (p_adjustment_type = 'REVAL AMORT') THEN
	   tmp_ccids := reval_amort_ccids;
	   tmp_count := G_ramo_ccid_count;
	ELSIF (p_adjustment_type = 'ADJUSTMENTS') THEN
	   tmp_ccids := adjustments_ccids;
	   tmp_count := G_adj_ccid_count;
	END IF;

	FOR i IN 1 .. tmp_count LOOP
	    IF (tmp_ccids(i).ccid = p_ccid) THEN
		X_index := i;
	        X_found := TRUE;
	    END IF;
	END LOOP;

EXCEPTION
        WHEN OTHERS THEN
                fa_srvr_msg.add_sql_error (
                        calling_fn => 'fa_mc_upg3_pkg.find_ccid');
                app_exception.raise_exception;

END find_ccid;

PROCEDURE get_coa_info(
                        p_book_type_code        IN      VARCHAR2,
                        p_rsob_id               IN      NUMBER) IS
/* ************************************************************************
   This procedure will obtain the Chart of Accounts Info for the reporting
   book for which we are initializing the account balances. We get the
   balancing segment for the coa and all the active segments in a buffer
   which will be used to dynamically build the retained earnings account
   when creating the balancing entry to retained earnings in GL_INTERFACE
************************************************************************ */

        l_bal_seg_num   	NUMBER;
        l_segcount      	NUMBER;
	l_seg_name		VARCHAR2(30);
	l_appcol_name		VARCHAR2(25);
	l_prompt		VARCHAR2(80);
	l_value_set_name 	VARCHAR2(60);

	coa_exception		EXCEPTION;
	seginfo_exception	EXCEPTION;
BEGIN
        if (g_print_debug) then
            fa_debug_pkg.add('calculate_balances',
                            'Getting chart of accounts info',
                            'start');
        end if;

        SELECT
                gls.chart_of_accounts_id,
		gls.ret_earn_code_combination_id
        INTO    G_coa_id,
		G_re_ccid
        FROM
                gl_sets_of_books gls,
                fa_mc_book_controls bc
        WHERE
                bc.book_type_code = p_book_type_code AND
		bc.set_of_books_id = p_rsob_id AND
                gls.set_of_books_id = bc.primary_set_of_books_id;

    -- Get the balancing segment NUMBER
        IF (NOT fnd_flex_apis.get_qualifier_segnum(
                appl_id                 => 101,
                key_flex_code           => 'GL#',
                structure_NUMBER        => G_coa_id,
                flex_qual_name          => 'GL_BALANCING',
                segment_NUMBER          => l_bal_seg_num)) THEN
            RAISE coa_exception;
        END IF;

    -- Get the NUMBER of segments
        SELECT count(*)
        INTO   l_segcount
        FROM   fnd_id_flex_segments
        WHERE  enabled_flag = 'Y'
        AND    id_flex_num = G_coa_id
        AND    application_id = 101
        AND    id_flex_code = 'GL#';

	G_flex_buf := '';

	-- LOOP thro all segments and build segment buffer
        FOR segnum IN 1..l_segcount LOOP
            IF (NOT fnd_flex_apis.get_segment_info(
                x_application_id        => 101,
                x_id_flex_code          => 'GL#',
                x_id_flex_num           => G_coa_id,
                x_seg_num               => segnum,
                x_appcol_name           => l_appcol_name,
                x_seg_name              => l_seg_name,
                x_prompt                => l_prompt,
                x_value_set_name        => l_value_set_name)) THEN
               RAISE seginfo_exception;
            END IF;

 	    G_flex_seg_count := G_flex_seg_count + 1;
	    coa_structure(segnum) := l_appcol_name;

            IF (segnum = l_bal_seg_num) THEN
               	G_bal_seg_col := l_appcol_name;
            END IF;
            G_flex_buf := G_flex_buf || l_appcol_name || ', ';
        END LOOP;

        if (g_print_debug) then
            fa_debug_pkg.add('calculate_balances',
                            'Getting chart of accounts info',
                            'success');
        end if;

-- dbms_output.put_line('The COA structure is: ' || G_flex_buf);

EXCEPTION
	WHEN coa_exception THEN
                fa_srvr_msg.add_sql_error (
                        calling_fn => 'fa_mc_upg3_pkg.get_coa_info');
                app_exception.raise_exception;

	WHEN seginfo_exception THEN
		fa_srvr_msg.add_message(
			calling_fn => 'fa_mc_upg3_pkg.get_coa_info',
			name       => 'FA_SHARED_FLEX_SEGCOLUMNS',
			token1	   => 'STRUCT_ID',
			value1	   => to_char(G_coa_id),
			token2	   => 'FLEX_CODE',
			value2	   => 'GL#');
		app_exception.raise_exception;

        WHEN OTHERS THEN
                fa_srvr_msg.add_sql_error (
                        calling_fn => 'fa_mc_upg3_pkg.get_coa_info');
                app_exception.raise_exception;

END get_coa_info;


PROCEDURE insert_rec(
			p_rsob_id		IN 	NUMBER,
			p_entered_cr		IN	NUMBER,
			p_entered_dr		IN	NUMBER,
			p_accounted_cr		IN	NUMBER,
			p_accounted_dr		IN	NUMBER,
			p_ccid			IN	NUMBER) IS
/* ************************************************************************
   This procedure inserts a row into gl_interface and obtains the segment
   values from gl_code_combination using the CCID. We get all the segment
   values for each CCID since it is required for the GROUP BY in
   insert_ret_earnings procedure. We insert the entered and accounted
   amounts for each CCID.
************************************************************************ */

BEGIN
	INSERT INTO gl_interface (
		set_of_books_id,
		status,
		code_combination_id,
		user_je_source_name,
		user_je_category_name,
		date_created,
		accounting_date,
		entered_cr,
		entered_dr,
		accounted_cr,
		accounted_dr,
		currency_code,
		actual_flag,
		created_by,
		group_id,
		segment1,
		segment2,
		segment3,
		segment4,
		segment5,
		segment6,
		segment7,
		segment8,
		segment9,
		segment10,
		segment11,
		segment12,
		segment13,
		segment14,
		segment15,
		segment16,
		segment17,
		segment18,
		segment19,
		segment20,
		segment21,
		segment22,
		segment23,
		segment24,
		segment25,
		segment26,
		segment27,
		segment28,
		segment29,
		segment30)
	SELECT
		p_rsob_id,
		G_status,
		p_ccid,
		G_source_name,
		G_category_name,
		sysdate,
		G_accounting_date,
		p_entered_cr,
		p_entered_dr,
		p_accounted_cr,
		p_accounted_dr,
		G_from_currency,
		G_actual_flag,
		-1,
		G_group_id,
		glcc.segment1,
		glcc.segment2,
		glcc.segment3,
		glcc.segment4,
		glcc.segment5,
		glcc.segment6,
		glcc.segment7,
		glcc.segment8,
		glcc.segment9,
		glcc.segment10,
		glcc.segment11,
		glcc.segment12,
		glcc.segment13,
		glcc.segment14,
		glcc.segment15,
		glcc.segment16,
		glcc.segment17,
		glcc.segment18,
		glcc.segment19,
		glcc.segment20,
		glcc.segment21,
		glcc.segment22,
		glcc.segment23,
		glcc.segment24,
		glcc.segment25,
		glcc.segment26,
		glcc.segment27,
		glcc.segment28,
		glcc.segment29,
		glcc.segment30

	FROM 	gl_code_combinations glcc
	WHERE	glcc.code_combination_id = p_ccid AND
		glcc.chart_of_accounts_id = G_coa_id;
EXCEPTION
        WHEN OTHERS THEN
                fa_srvr_msg.add_sql_error (
                        calling_fn => 'fa_mc_upg3_pkg.insert_rec');
                app_exception.raise_exception;

END insert_rec;

PROCEDURE insert_ret_earnings (
			p_book_type_code        IN      VARCHAR2,
			p_rsob_id		IN	NUMBER) IS
/* ************************************************************************
   This procedure created the balancing entry to retained earnings for a
   given balancing segment. After all the CCID balances have been obtained
   and inserted into GL_INTERFACE, we will have to balance each balancing
   segment. This is because we do not obtain the balances of revenue/expense
   accounts for past years and this will cause the entries in GL_INTERFACE
   to be out of balance. We use the template RE ccid in gl_sets_of_books
   in the dynamic sql and group by the balancing segment to create the plug
   to the correct retained earning account.
************************************************************************ */

	insert_cursor 	INTEGER;  -- Handles the insert cursor
	l_row_count 	NUMBER;  -- Number of rows returned by FETCH

	buf1		VARCHAR2(255);
	buf2		VARCHAR2(255);
	buf3		VARCHAR2(255);
	buf4		VARCHAR2(255);
	buf5		VARCHAR2(255);
	buf6		VARCHAR2(255);
	buf7		VARCHAR2(255);
	buf8		VARCHAR2(255);
	buf9		VARCHAR2(255);
	buf10		VARCHAR2(255);

BEGIN
        if (g_print_debug) then
            fa_debug_pkg.add('calculate_balances',
                            'Inserting retained earnings in GL_INTERFACE',
                            'start');
	end if;

	G_insert_buf := '';
	G_insert_buf := G_insert_buf ||
                        'INSERT INTO gl_interface(' ||
                                        'status,' ||
                                        'set_of_books_id,' ||
                                        'user_je_source_name,' ||
                                        'user_je_category_name,' ||
                                        'currency_code,' ||
					'date_created,' ||
					'created_by,' ||
					'accounting_date,' ||
                                        'actual_flag,' ||
					'entered_cr,' ||
					'entered_dr,' ||
					'accounted_cr,' ||
					'accounted_dr,' ||
                                        G_flex_buf ||
                                        'group_id) ' ;

        G_insert_buf := G_insert_buf ||
			'SELECT ' ||
                                ':status' || ',' ||
                                ':rsob_id' || ',' ||
                                ':source' || ',' ||
                                ':category' || ',' ||
                                ':fcurrency' || ',' ||
				':date_created' || ',' ||
				-1 || ',' ||
				':acc_date'|| ',' ||
                                ':actual_flag' || ',' ||
				'decode(sign(sum(nvl(gli.entered_dr, 0) - ' ||
				   'nvl(gli.entered_cr, 0))), 1, ' ||
				   '(sum(nvl(gli.entered_dr, 0) - ' ||
				   'nvl(gli.entered_cr,0))), 0), ' ||
				'decode(sign(sum(nvl(gli.entered_dr, 0) - ' ||
			           'nvl(gli.entered_cr, 0))), -1, ' ||
				   '(sum(nvl(gli.entered_cr, 0) - ' ||
				   'nvl(gli.entered_dr, 0))), 0), ' ||
				'decode(sign(sum(nvl(gli.accounted_dr, 0) - ' ||
				   'nvl(gli.accounted_cr, 0))), 1, ' ||
				   'sum(nvl(gli.accounted_dr, 0) - ' ||
				   'nvl(gli.accounted_cr, 0)), 0), '||
				'decode(sign(sum(nvl(gli.accounted_dr, 0) - ' ||
				   'nvl(gli.accounted_cr, 0))), -1, ' ||
				   'sum(nvl(gli.accounted_cr, 0) - ' ||
				   'nvl(gli.accounted_dr, 0)), 0), ';

        FOR i in 1..G_flex_seg_count LOOP
                IF (coa_structure(i) = G_bal_seg_col) THEN
                   G_insert_buf := G_insert_buf ||
                                'min(gli.' || G_bal_seg_col || '),';
                ELSE
                   G_insert_buf := G_insert_buf ||
                                'min(glcc.' ||
                                   coa_structure(i) || '),';
                END IF;
        END LOOP;

        G_insert_buf := G_insert_buf || ':group_id' ;
        G_insert_buf := G_insert_buf ||
                        ' FROM ' ||
                                    'gl_code_combinations glcc,' ||
                                    'gl_interface gli ' ||
                        'WHERE ' ||
                                'gli.user_je_source_name = :source and ' ||
                                'gli.set_of_books_id = :rsob_id and ' ||
                                'gli.group_id = :group_id and ' ||
                                'glcc.chart_of_accounts_id = :coa_id and ' ||
                                'glcc.template_id is NULL and ' ||
                                'glcc.code_combination_id = :re_ccid ' ||
                        'GROUP BY ' ||
                                'gli.' || G_bal_seg_col ;

	-- write buffer to log when run in debug mode
	if (g_print_debug) then
	    	buf1 := SUBSTRB(G_insert_buf,200,200);
		buf2 := SUBSTRB(G_insert_buf,400,200);
		buf3 := SUBSTRB(G_insert_buf,600,200);
		buf4 := SUBSTRB(G_insert_buf,800,200);
		buf5 := SUBSTRB(G_insert_buf,1000,200);
		buf6 := SUBSTRB(G_insert_buf,1200,200);
		buf7 := SUBSTRB(G_insert_buf,1400,200);
		buf8 := SUBSTRB(G_insert_buf,1600,200);
		buf9 := SUBSTRB(G_insert_buf,1800,200);
		buf10 := SUBSTRB(G_insert_buf,2000,200);

		fa_rx_conc_mesg_pkg.log('Insert buf is: ' ||
					SUBSTRB(G_insert_buf,1,199));
		fa_rx_conc_mesg_pkg.log(buf1);
		fa_rx_conc_mesg_pkg.log(buf2);
		fa_rx_conc_mesg_pkg.log(buf3);
		fa_rx_conc_mesg_pkg.log(buf4);
		fa_rx_conc_mesg_pkg.log(buf5);
		fa_rx_conc_mesg_pkg.log(buf6);
		fa_rx_conc_mesg_pkg.log(buf7);
		fa_rx_conc_mesg_pkg.log(buf8);
		fa_rx_conc_mesg_pkg.log(buf9);
		fa_rx_conc_mesg_pkg.log(buf10);
	end if;
/*
dbms_output.put_line('Insert buf is: ' || SUBSTRB(G_insert_buf,1,199));
dbms_output.put_line(buf1);
dbms_output.put_line(buf2);
dbms_output.put_line(buf3);
dbms_output.put_line(buf4);
dbms_output.put_line(buf5);
dbms_output.put_line(buf6);
dbms_output.put_line(buf7);
dbms_output.put_line(buf8);
dbms_output.put_line(buf9);
dbms_output.put_line(buf10);
*/

	-- OPEN the insert cursor
	insert_cursor := dbms_sql.open_cursor;

        if (g_print_debug) then
            fa_debug_pkg.add('insert_ret_earnings',
                            'Open cursor',
                            'success');
        end if;
	-- parse the insert smt
	dbms_sql.parse(insert_cursor, G_insert_buf, dbms_sql.v7);

        if (g_print_debug) then
            fa_debug_pkg.add('insert_ret_earnings',
                            'Parse cursor',
                            'success');
        end if;

	-- bind all input variables

	dbms_sql.bind_variable(insert_cursor, ':category',G_category_name );
	dbms_sql.bind_variable(insert_cursor, ':status', G_status);
	dbms_sql.bind_variable(insert_cursor, ':actual_flag', G_actual_flag);
	dbms_sql.bind_variable(insert_cursor, ':fcurrency', G_from_currency);
	dbms_sql.bind_variable(insert_cursor, ':date_created', sysdate);
	dbms_sql.bind_variable(insert_cursor, ':acc_date',G_accounting_date);
	dbms_sql.bind_variable(insert_cursor, ':source',G_source_name );
	dbms_sql.bind_variable(insert_cursor, ':group_id', G_group_id);
	dbms_sql.bind_variable(insert_cursor, ':rsob_id', p_rsob_id);
	dbms_sql.bind_variable(insert_cursor, ':coa_id', G_coa_id);
	dbms_sql.bind_variable(insert_cursor, ':re_ccid', G_re_ccid);

	l_row_count := dbms_sql.execute(insert_cursor);

        if (g_print_debug) then
            fa_debug_pkg.add('insert_ret_earnings',
                            'Number of retained earnings rows inserted',
                            l_row_count);
        end if;
	dbms_sql.close_cursor(insert_cursor);

        if (g_print_debug) then
            fa_debug_pkg.add('calculate_balances',
                            'Inserting retained earnings in GL_INTERFACE',
                            'success');
	end if;
EXCEPTION
        WHEN OTHERS THEN
                fa_srvr_msg.add_sql_error (
                        calling_fn => 'fa_mc_upg3_pkg.insert_ret_earnings');
                app_exception.raise_exception;

END insert_ret_earnings;


PROCEDURE insert_balances(
		p_rsob_id               IN      NUMBER) IS
/* ************************************************************************
   This procedure loops thro each of the global arrays that hold the CCID's
   and the entered and accounted amounts and calls inert_rec to insert the
   row in GL_INTERFACE.
************************************************************************ */

BEGIN
        if (g_print_debug) then
            fa_debug_pkg.add('calculate_balances',
                            'Inserting account balances in GL_INTERFACE',
                            'start');
        end if;

	-- get the group_id from sequence
	SELECT	gl_interface_control_s.nextval
	INTO	G_group_id
	FROM 	dual;

-- dbms_output.put_line('Group id is: ' || G_group_id);

	-- get the category name
        SELECT  user_je_category_name
        INTO    G_category_name
        FROM    GL_JE_CATEGORIES
        WHERE   je_category_name = 'MRC Open Balances';

	-- get the source name
        SELECT  user_je_source_name
        INTO    G_source_name
        FROM    GL_JE_SOURCES
        WHERE   je_source_name = 'Assets';

	-- LOOP thro all ccid arrays and insert rows into gl_interface

	FOR i IN 1..G_adj_ccid_count LOOP
	    insert_rec(
		p_rsob_id,
		adjustments_ccids(i).entered_cr,
		adjustments_ccids(i).entered_dr,
		adjustments_ccids(i).accounted_cr,
		adjustments_ccids(i).accounted_dr,
		adjustments_ccids(i).ccid);
	END LOOP;

	FOR i IN 1..G_drsv_ccid_count LOOP
            insert_rec(
		p_rsob_id,
                deprn_reserve_ccids(i).entered_cr,
                deprn_reserve_ccids(i).entered_dr,
                deprn_reserve_ccids(i).accounted_cr,
                deprn_reserve_ccids(i).accounted_dr,
                deprn_reserve_ccids(i).ccid);
	END LOOP;

 	FOR i IN 1..G_dexp_ccid_count LOOP
            insert_rec(
		p_rsob_id,
                deprn_expense_ccids(i).entered_cr,
                deprn_expense_ccids(i).entered_dr,
                deprn_expense_ccids(i).accounted_cr,
                deprn_expense_ccids(i).accounted_dr,
                deprn_expense_ccids(i).ccid);

	END LOOP;

	FOR i IN 1..G_rrsv_ccid_count LOOP
            insert_rec(
		p_rsob_id,
                reval_reserve_ccids(i).entered_cr,
                reval_reserve_ccids(i).entered_dr,
                reval_reserve_ccids(i).accounted_cr,
                reval_reserve_ccids(i).accounted_dr,
                reval_reserve_ccids(i).ccid);
        END LOOP;

	FOR i IN 1..G_ramo_ccid_count LOOP
            insert_rec(
		p_rsob_id,
                reval_amort_ccids(i).entered_cr,
                reval_amort_ccids(i).entered_dr,
                reval_amort_ccids(i).accounted_cr,
                reval_amort_ccids(i).accounted_dr,
                reval_amort_ccids(i).ccid);
        END LOOP;

        FOR i IN 1..G_dfrsv_ccid_count LOOP
            insert_rec(
                p_rsob_id,
                def_deprn_rsv_ccids(i).entered_cr,
                def_deprn_rsv_ccids(i).entered_dr,
                def_deprn_rsv_ccids(i).accounted_cr,
                def_deprn_rsv_ccids(i).accounted_dr,
                def_deprn_rsv_ccids(i).ccid);
        END LOOP;

        FOR i IN 1..G_dfexp_ccid_count LOOP
            insert_rec(
                p_rsob_id,
                def_deprn_exp_ccids(i).entered_cr,
                def_deprn_exp_ccids(i).entered_dr,
                def_deprn_exp_ccids(i).accounted_cr,
                def_deprn_exp_ccids(i).accounted_dr,
                def_deprn_exp_ccids(i).ccid);
        END LOOP;

        if (g_print_debug) then
            fa_debug_pkg.add('calculate_balances',
                            'Inserting account balances in GL_INTERFACE',
                            'success');
        end if;
EXCEPTION
        WHEN OTHERS THEN
                fa_srvr_msg.add_sql_error (
                        calling_fn => 'fa_mc_upg3_pkg.insert_balances');
                app_exception.raise_exception;

END insert_balances;

END FA_MC_UPG3_PKG;

/
