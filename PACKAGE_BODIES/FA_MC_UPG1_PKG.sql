--------------------------------------------------------
--  DDL for Package Body FA_MC_UPG1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_MC_UPG1_PKG" AS
/* $Header: faxmcu1b.pls 120.5.12010000.2 2009/07/19 10:05:35 glchen ship $ */

	-- commit size to control number assets to process in loop
	G_Max_Commit_Size 	CONSTANT 	NUMBER := 1000;
	G_rbook_name		VARCHAR2(30);

        g_print_debug boolean := fa_cache_pkg.fa_print_debug;

FUNCTION lock_book (
		p_book_type_code        IN      VARCHAR2,
		p_rsob_id		IN	NUMBER)
				RETURN BOOLEAN IS
/* ************************************************************************
   This function locks the book controls row in order to prevent running
   conversion utility simultaneously for the same book - reporting book
   combination. Return TRUE if lock is obtained and FALSE if unable to
   obtain a lock.
************************************************************************ */

	l_converted_flag	varchar2(1);
BEGIN
        select 	mrc_converted_flag
        into 	l_converted_flag
        from 	fa_mc_book_controls
        where 	book_type_code = p_book_type_code AND
	      	set_of_books_id = p_rsob_id
        for 	update of
		mrc_converted_flag
        NOWAIT;
	return(TRUE);
EXCEPTION
	WHEN OTHERS THEN
		fa_srvr_msg.add_sql_error (
			calling_fn => 'fa_mc_upg1_pkg.lock_book');
		return(FALSE);
END lock_book;


PROCEDURE create_drop_indexes(
			p_mode		IN	VARCHAR2) IS

 	out_oracle_schema varchar2(100);
 	out_status varchar2(100);
 	out_industry varchar2(100);
 	x boolean;
BEGIN
 	x :=  fnd_installation.get_app_info('FND', out_status,
                                out_industry, out_oracle_schema);

	IF (p_mode = 'D') THEN
           if (g_print_debug) then
                fa_debug_pkg.add('create_drop_indexes','mode',
                                'Dropping');
            end if;

           ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.drop_index,
                'drop index FA_MC_ADJUSTMENTS_N1','INDEX');

	   ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.drop_index,
                'drop index FA_MC_ADJUSTMENTS_N2','INDEX');

           ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.drop_index,
                'drop index FA_MC_ADJUSTMENTS_N3','INDEX');

           ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.drop_index,
                'drop index FA_MC_ADJUSTMENTS_N4','INDEX');

           ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.drop_index,
                'drop index FA_MC_ASSET_INVOICES_N1','INDEX');

	   ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.drop_index,
                'drop index FA_MC_BOOKS_U1','INDEX');

           ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.drop_index,
                'drop index FA_MC_BOOKS_RATES_N1','INDEX');

           ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.drop_index,
                'drop index FA_MC_BOOKS_RATES_U1','INDEX');

           ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.drop_index,
                'drop index FA_MC_BOOK_CONTROLS_U1','INDEX');

           ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.drop_index,
                'drop index FA_MC_DEFERRED_DEPRN_N1','INDEX');

           ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.drop_index,
                'drop index FA_MC_DEFERRED_DEPRN_N2','INDEX');

           ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.drop_index,
                'drop index FA_MC_DEFERRED_DEPRN_N3','INDEX');

           ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.drop_index,
                'drop index FA_MC_DEFERRED_DEPRN_N4','INDEX');

           ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.drop_index,
                'drop index FA_MC_DEPRN_DETAIL_N1','INDEX');

           ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.drop_index,
                'drop index FA_MC_DEPRN_DETAIL_N2','INDEX');

           ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.drop_index,
                'drop index FA_MC_DEPRN_DETAIL_U1','INDEX');

           ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.drop_index,
                'drop index FA_MC_DEPRN_PERIODS_U1','INDEX');

           ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.drop_index,
                'drop index FA_MC_DEPRN_PERIODS_U2','INDEX');

           ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.drop_index,
                'drop index FA_MC_DEPRN_PERIODS_U3','INDEX');

           ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.drop_index,
                'drop index FA_MC_DEPRN_SUMMARY_N1','INDEX');

           ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.drop_index,
                'drop index FA_MC_DEPRN_SUMMARY_U1','INDEX');

           ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.drop_index,
                'drop index FA_MC_RETIREMENTS_U1','INDEX');

	ELSIF (p_mode = 'C') then
	   -- create all the indexes

           if (g_print_debug) then
                fa_debug_pkg.add('create_drop_indexes','mode',
                                'Creating');
            end if;

           ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.create_index,
                'create index FA_MC_ADJUSTMENTS_N1 ON
                        FA_MC_ADJUSTMENTS(
				DISTRIBUTION_ID,
				BOOK_TYPE_CODE,
				PERIOD_COUNTER_CREATED,
				SOURCE_TYPE_CODE,
				ADJUSTMENT_TYPE,
				SET_OF_BOOKS_ID)', 'INDEX');

           ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.create_index,
                'create index FA_MC_ADJUSTMENTS_N2 ON
                        FA_MC_ADJUSTMENTS(
				ASSET_ID,
                                BOOK_TYPE_CODE,
                                PERIOD_COUNTER_CREATED,
                                SET_OF_BOOKS_ID)', 'INDEX');

           ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.create_index,
                'create index FA_MC_ADJUSTMENTS_N3 ON
                        FA_MC_ADJUSTMENTS(
				JE_HEADER_ID,
				JE_LINE_NUM,
                                SET_OF_BOOKS_ID)', 'INDEX');

           ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.create_index,
                'create index FA_MC_ADJUSTMENTS_N4 ON
                        FA_MC_ADJUSTMENTS(
                                BOOK_TYPE_CODE,
                                PERIOD_COUNTER_CREATED,
                                SET_OF_BOOKS_ID)', 'INDEX');


           ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.create_index,
                'create index FA_MC_ASSET_INVOICES_N1 ON
                        FA_MC_ASSET_INVOICES(
				ASSET_ID,
				ASSET_INVOICE_ID,
                                SET_OF_BOOKS_ID)', 'INDEX');

           ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.create_index,
                'create unique index FA_MC_BOOKS_U1 ON
                        FA_MC_BOOKS(
				TRANSACTION_HEADER_ID_IN,
                                SET_OF_BOOKS_ID)', 'INDEX');


           ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.create_index,
                'create index FA_MC_BOOKS_RATES_N1 ON
                        FA_MC_BOOKS_RATES(
                                SET_OF_BOOKS_ID,
                                TRANSACTION_HEADER_ID)', 'INDEX');

           ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.create_index,
                'create unique index FA_MC_BOOKS_RATES_U1 ON
                        FA_MC_BOOKS_RATES(
                                SET_OF_BOOKS_ID,
                                TRANSACTION_HEADER_ID,
                                INVOICE_TRANSACTION_ID)', 'INDEX');

           ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.create_index,
                'create unique index FA_MC_BOOK_CONTROLS_U1 ON
                        FA_MC_BOOK_CONTROLS(
                                SET_OF_BOOKS_ID,
                                BOOK_TYPE_CODE)', 'INDEX');

           ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.create_index,
                'create index FA_MC_DEFERRED_DEPRN_N1 ON
                        FA_MC_DEFERRED_DEPRN(
                                CORP_BOOK_TYPE_CODE,
				TAX_BOOK_TYPE_CODE,
				EXPENSE_JE_LINE_NUM,
                                SET_OF_BOOKS_ID)', 'INDEX');

           ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.create_index,
                'create index FA_MC_DEFERRED_DEPRN_N2 ON
                        FA_MC_DEFERRED_DEPRN(
                                CORP_BOOK_TYPE_CODE,
                                TAX_BOOK_TYPE_CODE,
                                RESERVE_JE_LINE_NUM,
                                SET_OF_BOOKS_ID)', 'INDEX');

           ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.create_index,
                'create index FA_MC_DEFERRED_DEPRN_N3 ON
                        FA_MC_DEFERRED_DEPRN(
				JE_HEADER_ID,
				EXPENSE_JE_LINE_NUM,
                                SET_OF_BOOKS_ID)', 'INDEX');

           ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.create_index,
                'create index FA_MC_DEFERRED_DEPRN_N4 ON
                        FA_MC_DEFERRED_DEPRN(
                                JE_HEADER_ID,
                                RESERVE_JE_LINE_NUM,
                                SET_OF_BOOKS_ID)', 'INDEX');

           ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.create_index,
                'create index FA_MC_DEPRN_DETAIL_N1 ON
                        FA_MC_DEPRN_DETAIL(
				ASSET_ID,
                                BOOK_TYPE_CODE,
				PERIOD_COUNTER,
                                SET_OF_BOOKS_ID)', 'INDEX');

           ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.create_index,
                'create index FA_MC_DEPRN_DETAIL_N2 ON
                        FA_MC_DEPRN_DETAIL(
                                BOOK_TYPE_CODE,
                                PERIOD_COUNTER,
                                SET_OF_BOOKS_ID)', 'INDEX');

           ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.create_index,
                'create unique index FA_MC_DEPRN_DETAIL_U1 ON
                        FA_MC_DEPRN_DETAIL(
				DISTRIBUTION_ID,
                                ASSET_ID,
                                BOOK_TYPE_CODE,
                                PERIOD_COUNTER,
                                SET_OF_BOOKS_ID)', 'INDEX');

           ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.create_index,
                'create unique index FA_MC_DEPRN_PERIODS_U1 ON
                        FA_MC_DEPRN_PERIODS(
                                BOOK_TYPE_CODE,
                                PERIOD_NAME,
                                SET_OF_BOOKS_ID)', 'INDEX');

	   ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.create_index,
                'create unique index FA_MC_DEPRN_PERIODS_U2 ON
                        FA_MC_DEPRN_PERIODS(
                                BOOK_TYPE_CODE,
				FISCAL_YEAR,
                                PERIOD_NUM,
                                SET_OF_BOOKS_ID)', 'INDEX');

           ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.create_index,
                'create unique index FA_MC_DEPRN_PERIODS_U3 ON
                        FA_MC_DEPRN_PERIODS(
                                BOOK_TYPE_CODE,
                                PERIOD_COUNTER,
                                SET_OF_BOOKS_ID)', 'INDEX');
           ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.create_index,
                'create index FA_MC_DEPRN_SUMMARY_N1 ON
                        FA_MC_DEPRN_SUMMARY(
                                BOOK_TYPE_CODE,
                                PERIOD_COUNTER,
                                SET_OF_BOOKS_ID)', 'INDEX');

           ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.create_index,
                'create unique index FA_MC_DEPRN_SUMMARY_U1 ON
                        FA_MC_DEPRN_SUMMARY(
				ASSET_ID,
                                BOOK_TYPE_CODE,
                                PERIOD_COUNTER,
                                SET_OF_BOOKS_ID)', 'INDEX');

           ad_ddl.do_ddl(out_oracle_schema, 'OFA',
                ad_ddl.create_index,
                'create unique index FA_MC_RETIREMENTS_U1 ON
                        FA_MC_RETIREMENTS(
                                SET_OF_BOOKS_ID,
                                RETIREMENT_ID)', 'INDEX');
	END IF;

EXCEPTION
 	WHEN OTHERS THEN
                fa_srvr_msg.add_sql_error (
                        calling_fn => 'fa_mc_upg1_pkg.create_drop_indexes');
END create_drop_indexes;


PROCEDURE validate_setup(
		p_book_type_code	IN	VARCHAR2,
		p_reporting_book        IN      VARCHAR2,
		X_from_currency	 OUT NOCOPY VARCHAR2,
		X_to_currency	 OUT NOCOPY VARCHAR2,
		X_rsob_id	 OUT NOCOPY NUMBER,
		X_psob_id	 OUT NOCOPY NUMBER) IS
/* ************************************************************************
   This procedure validates the set up and returns information about
   reporting book. It checks if the book being converted is an MRC
   source book, checks if reporting book is associated to the primary book
   and whether the reporting book is converted or not. If setup is not ok
   it raises the appropriate exception and errors out. If setup is ok and
   reporting book is yet to be converted, it locks the reporting books
   row.
*************************************************************************/

        l_rsob_id               number;
        l_psob_id               number;
        l_mc_source_flag        varchar2(1);
        l_mrc_converted_flag    varchar2(1);
        l_status                boolean;
	l_enabled_flag		varchar2(1);

        mc_source_error         exception;
        rbook_setup_error       exception;
        rbook_converted_error   exception;
        lock_error              exception;
	rbook_disabled_error	exception;

	CURSOR check_books IS
        	SELECT
			glsob.set_of_books_id,
			mcbc.primary_set_of_books_id,
			mcbc.currency_code,
			mcbc.primary_currency_code,
			mcbc.mrc_converted_flag,
			mcbc.enabled_flag,
			nvl(bc.mc_source_flag,'N')
        	FROM
			fa_mc_book_controls     mcbc,
                	gl_sets_of_books        glsob,
                	fa_book_controls        bc
        	WHERE
			bc.book_type_code = p_book_type_code AND
                	mcbc.book_type_code = bc.book_type_code AND
			bc.set_of_books_id = mcbc.primary_set_of_books_id AND
                	glsob.name = p_reporting_book AND
                	glsob.set_of_books_id   = mcbc.set_of_books_id AND
                	glsob.mrc_sob_type_code = 'R';

BEGIN
	G_rbook_name := p_reporting_book;
	OPEN check_books;
	FETCH check_books into X_rsob_id,
			       X_psob_id,
			       X_to_currency,
			       X_from_currency,
			       l_mrc_converted_flag,
			       l_enabled_flag,
			       l_mc_source_flag;
	IF (check_books%NOTFOUND) THEN
	   	RAISE rbook_setup_error;
	ELSIF (l_mc_source_flag = 'N') THEN
		RAISE mc_source_error;
	ELSIF (l_mrc_converted_flag = 'Y') THEN
		RAISE rbook_converted_error;
	ELSIF (l_enabled_flag = 'N') THEN
		RAISE rbook_disabled_error;
	END IF;
	CLOSE check_books;

	l_status := lock_book(p_book_type_code, X_rsob_id);

	IF (not l_status) THEN
	      RAISE lock_error;
	END IF;

        if (g_print_debug) then
                fa_debug_pkg.add('validate_setup','reporting sobid',
                                X_rsob_id);
		fa_debug_pkg.add('validate_setup','primary sobid',
				X_psob_id);
		fa_debug_pkg.add('validate_setup','to currency',
				X_to_currency);
		fa_debug_pkg.add('validate_setup','from currency',
				X_from_currency);
		fa_debug_pkg.add('validate_setup','mrc converted',
				l_mrc_converted_flag);
        end if;

EXCEPTION
	WHEN mc_source_error THEN
                fa_srvr_msg.add_message (
                	calling_fn => 'fa_mc_upg1_pkg.validate_setup',
                        name       => 'FA_MRC_NOT_SOURCE',
			token1	   => 'BOOK',
			value1	   => p_book_type_code);

                app_exception.raise_exception;

	WHEN rbook_setup_error THEN
                fa_srvr_msg.add_message (
                        calling_fn => 'fa_mc_upg1_pkg.validate_setup',
                        name       => 'FA_MRC_BOOK_NOT_ASSOCIATED',
                        token1     => 'REPORTING_BOOK',
			value1     => G_rbook_name,
			token2	   => 'BOOK',
			value2	   => p_book_type_code);
                app_exception.raise_exception;

	WHEN rbook_converted_error THEN
		fa_srvr_msg.add_message (
			calling_fn => 'fa_mc_upg1_pkg.validate_setup',
			name       => 'FA_MRC_BOOK_CONVERTED',
                        token1     => 'REPORTING_BOOK',
                        value1     => G_rbook_name,
                        token2     => 'BOOK',
                        value2     => p_book_type_code);
                app_exception.raise_exception;

	WHEN rbook_disabled_error THEN
		fa_srvr_msg.add_message (
			calling_fn => 'fa_mc_upg1_pkg.validate_setup',
			name       => 'FA_MRC_BOOK_DISABLED',
                        token1     => 'REPORTING_BOOK',
                        value1     => G_rbook_name,
                        token2     => 'BOOK',
                        value2     => p_book_type_code);
                app_exception.raise_exception;

	WHEN lock_error THEN
                fa_srvr_msg.add_sql_error (
                        calling_fn => 'fa_mc_upg1_pkg.lock_book');
                app_exception.raise_exception;

	WHEN OTHERS THEN
		fa_srvr_msg.add_sql_error(
			calling_fn => 'fa_mc_upg1_pkg.validate_setup');
                app_exception.raise_exception;

END validate_setup;


PROCEDURE validate_rate (
                p_book_type_code        IN      VARCHAR2,
                p_rsob_id               IN 	NUMBER,
		p_fixed_rate		IN	VARCHAR2,
		X_fixed_conversion OUT NOCOPY  	VARCHAR2) IS
/* ************************************************************************
   This procedure will validate fa_mc_conversion_rates table. It will
   check to see that all assets have a conversion_basis. It also checks
   to see if the conversion is a fixed rate conversion based on user input
   and raises an exception when user specifies that it is a fixed rate
   conversion and when there are variable rates for the assets. This
   procedure will return whether this is a fixed rate conversion or not.
************************************************************************ */

        l_count                 number;
        l_exchange_rate         number;
        l_conversion_basis      varchar2(1);
        fixed_rate_error        exception;
        conversion_basis_error  exception;
	cost_basis_error	exception;

	CURSOR check_rate IS
		SELECT 	distinct exchange_rate, conversion_basis
		FROM
			fa_mc_conversion_rates
		WHERE
			set_of_books_id = p_rsob_id AND
			book_type_code = p_book_type_code;
BEGIN

	-- check if conversion basis is null for any asset
	-- and raise error if it is the case

	SELECT 	count(*)
	INTO	l_count
	FROM	fa_mc_conversion_rates
	WHERE
		set_of_books_id = p_rsob_id AND
                book_type_code = p_book_type_code AND
		conversion_basis is null AND
		status in ('L','F');

	IF (l_count > 0) THEN
	   RAISE conversion_basis_error;
	END IF;

	l_count := 0;

	-- validate if all assets have fixed rate based on user input
	-- of fixed rate conversion
	-- If user indicates it is fixed rate and it is not a fixed rate
	-- then raise error

	OPEN check_rate;
	LOOP
		FETCH check_rate into
				l_exchange_rate,
				l_conversion_basis;
		exit WHEN ((check_rate%NOTFOUND) OR (l_count > 1));
		l_count := l_count + 1;
	END LOOP;
	CLOSE check_rate;

	IF (SUBSTRB(p_fixed_rate,1,1) = 'Y' AND l_count > 1) THEN
	   RAISE fixed_rate_error;
	ELSIF ((l_count = 1) AND (l_conversion_basis = 'R')) THEN
	   X_fixed_conversion := 'Y';
	ELSE X_fixed_conversion := 'N';
	END IF;

EXCEPTION

	WHEN fixed_rate_error THEN
                fa_srvr_msg.add_message (
                	calling_fn => 'fa_mc_upg1_pkg.validate_rate',
                        name       => 'FA_MRC_NOT_FIXED_RATE');
                app_exception.raise_exception;

	WHEN conversion_basis_error THEN
                fa_srvr_msg.add_message (
                        calling_fn => 'fa_mc_upg1_pkg.validate_rate',
                        name       => 'FA_MRC_NO_BASIS');
                app_exception.raise_exception;

	WHEN OTHERS THEN
		fa_srvr_msg.add_sql_error(
                        calling_fn => 'fa_mc_upg1_pkg.validate_rate');
                app_exception.raise_exception;

END validate_rate;


PROCEDURE get_conversion_info(
                        p_book_type_code        IN      VARCHAR2,
			p_psob_id		IN 	NUMBER,
                        p_rsob_id               IN      NUMBER,
                        X_start_pc              OUT NOCOPY     NUMBER,
                        X_end_pc                OUT NOCOPY     NUMBER,
			X_conv_date	 OUT NOCOPY 	DATE,
			X_conv_type	 OUT NOCOPY VARCHAR2,
			X_accounting_date OUT NOCOPY DATE) IS
/* ************************************************************************
   This procedure will get the conversion information for the reporting
   book being converted from gl_mc_book_assignments and using this info
   also retrieves the period counters to convert based on the fiscal
   year that corresponds to the First MRC Period in GL. This procedure
   return the start and end period counters, conversion date and type.
   Raises appropriate exception if it fails to retreive the conversion
   info.
************************************************************************ */

        l_start_fy              number;
        l_start_pc              number; -- period counter to start converting
        l_end_pc                number; -- current period counter
        l_prior_period_num      number;
        l_pers_per_year         number;
        l_first_mrc_date        date;
        l_first_mrc_period      varchar2(15);
	l_prior_fa_period	varchar2(15);
        l_conv_type             varchar2(30);
        l_conv_date             date;
	l_first_future_period	varchar2(15);
	l_first_period_num	number(15);

	first_mrc_period_error	exception;
	prev_period_error	exception;
        period_info_error       exception;
        conversion_info_error   exception;

	l_fa_period_count       number;
        l_gl_period_count       number;
        check_fa_gl_periods     boolean;
        l_period_type           VARCHAR2(15);
        l_period_year           number(15);

        CURSOR get_mrc_conv_info IS
          SELECT
                        glba.alc_init_date,
                        glba.alc_init_period,
                        glba.alc_initializing_rate_type,
                        glba.alc_initializing_rate_date,
                        glps.effective_period_num
                FROM
                        gl_period_statuses glps,
                        gl_ledger_relationships glba
                WHERE
                        glba.target_ledger_id = p_rsob_id AND
                        glba.source_ledger_id = p_psob_id AND
                        glps.application_id = 101 AND
                        glba.application_id = 101 AND
                        glps.ledger_id = p_psob_id AND
                        glba.relationship_type_code = 'SUBLEDGER' AND
                        glps.period_name = glba.alc_init_period;


	CURSOR check_first_mrc_period IS
		SELECT
			ps.period_name,
                        ps.period_type,
                        ps.PERIOD_YEAR
		FROM
			gl_period_statuses ps
		WHERE
			ps.application_id = 101 AND
			ps.set_of_books_id = p_psob_id AND
			ps.effective_period_num = (
					SELECT	min(ps2.effective_period_num)
					FROM	gl_period_statuses ps2
					WHERE
						ps2.application_id =
							ps.application_id AND
						ps2.set_of_books_id =
							ps.set_of_books_id AND
						ps2. closing_status in
								('F', 'N') AND
						ps2.effective_period_num > (
						SELECT ps3.effective_period_num
						FROM   gl_period_statuses ps3,
						       gl_sets_of_books sb
						WHERE  ps3.application_id =
							   ps.application_id
						AND    ps3.set_of_books_id =
							   ps.set_of_books_id
						AND    ps3.period_name =
							sb.latest_opened_period_name
						AND    sb.set_of_books_id =
							   ps.set_of_books_id));

	CURSOR get_prev_period IS
		SELECT	ps.period_name, ps.end_date
		FROM	gl_period_statuses ps
		WHERE	ps.application_id = 101 AND
			ps.set_of_books_id = p_psob_id AND
			ps.effective_period_num = (
				SELECT  max(ps2.effective_period_num)
				FROM	gl_period_statuses ps2
				WHERE	ps2.application_id =
						ps.application_id AND
					ps2.set_of_books_id =
						ps.set_of_books_id AND
					ps2.effective_period_num <
						l_first_period_num AND
					ps2.adjustment_period_flag <> 'Y');

	CURSOR start_end_periods IS
        	SELECT
			dp.fiscal_year,
                	dp.period_counter,
                	dp2.period_counter
        	FROM
                	fa_deprn_periods dp,
                	fa_deprn_periods dp2,
			fa_deprn_periods dp3,
                	fa_book_controls bc
        	WHERE
			bc.book_type_code = p_book_type_code AND
			dp3.period_name = l_prior_fa_period AND
			dp3.book_type_code = bc.book_type_code AND
			dp3.fiscal_year = dp.fiscal_year AND
                	dp.book_type_code = bc.book_type_code AND
                /* BUG# 1483489 - need to dynamically get the period_num
                    -- bridgway  10/30/00

                        dp.period_num = 1 AND
                 */
			dp.period_num =
                                (select min(period_num)
                                 from   fa_deprn_periods dp4
                                 where  dp4.book_type_code = dp.book_type_code
                                 and    dp4.fiscal_year = dp.fiscal_year) AND
                	dp2.book_type_code = bc.book_type_code AND
                	dp2.period_close_date is NULL;

BEGIN

	OPEN get_mrc_conv_info;
	FETCH get_mrc_conv_info into	l_first_mrc_date,
					l_first_mrc_period,
					X_conv_type,
					X_conv_date,
					l_first_period_num;
	IF (get_mrc_conv_info%NOTFOUND) THEN
	   RAISE conversion_info_error;
	END IF;
	CLOSE get_mrc_conv_info;

	OPEN check_first_mrc_period;
	FETCH check_first_mrc_period into l_first_future_period,
                                          l_period_type,
                                          l_period_year;
	IF ((check_first_mrc_period%NOTFOUND) OR
	    (l_first_mrc_period <> l_first_future_period)) THEN
	   RAISE first_mrc_period_error;
	END IF;
	CLOSE check_first_mrc_period;

        if (g_print_debug) then
                fa_debug_pkg.add('get_conversion_info','checking fa gl periods',
                                'check_fa_gl_periods');
        end if;

        select ct.NUMBER_PER_FISCAL_YEAR
        into   l_fa_period_count
        from fa_calendar_types ct,
             fa_book_controls bc
        where  bc.book_type_code = p_book_type_code
        and    bc.deprn_calendar = ct.CALENDAR_TYPE;

        select count(*)
        into l_gl_period_count
        from gl_period_statuses ps
        where ps.application_id = 101
        AND   ps.set_of_books_id = p_psob_id
        AND   ps.period_year = l_period_year
        AND   ps.adjustment_period_flag <> 'Y';

        if (l_fa_period_count = l_gl_period_count) then
           check_fa_gl_periods := TRUE;
        else check_fa_gl_periods := FALSE;
        end if;

     if check_fa_gl_periods then

	OPEN get_prev_period;
	FETCH get_prev_period INTO l_prior_fa_period, X_accounting_date;
	IF (get_prev_period%NOTFOUND) THEN
		RAISE prev_period_error;
	END IF;
	CLOSE get_prev_period;

	OPEN start_end_periods;
	FETCH start_end_periods into	l_start_fy,
					X_start_pc,
					X_end_pc;
	IF (start_end_periods%NOTFOUND) THEN
	   RAISE period_info_error;
	END IF;
	CLOSE start_end_periods;

     else
         -- select the first period and current open period of the
         -- current fiscal year in FA
         SELECT
               dp.fiscal_year,
               dp.period_counter,
               dp2.period_counter
         INTO  l_start_fy, X_start_pc, X_end_pc
         FROM
               fa_deprn_periods dp2,
               fa_deprn_periods dp
         WHERE dp.book_type_code = p_book_type_code
         AND   dp2.book_type_code = dp.book_type_code
         AND   dp2.period_close_date is null
         AND   dp.fiscal_year = dp2.fiscal_year
         AND   dp.period_num = 1;

     end if;

        if (g_print_debug) then
                fa_debug_pkg.add('get_conversion_info','l_first_mrc_period',
                                l_first_mrc_period);
		fa_debug_pkg.add('get_conversion_info','l_prior_fa_period',
                		l_prior_fa_period );
		fa_debug_pkg.add('get_conversion_info','start_fy', l_start_fy);
		fa_debug_pkg.add('get_conversion_info','X_start_pc',X_start_pc);
		fa_debug_pkg.add('get_conversion_info','X_end_pc', X_end_pc);
        end if;

EXCEPTION
	WHEN conversion_info_error THEN
                fa_srvr_msg.add_message (
                	calling_fn => 'fa_mc_upg1_pkg.get_conversion_info',
                        name       => 'FA_MRC_CONV_INFO_ERROR',
			token1	   => 'REPORTING_BOOK',
			value1	   => G_rbook_name);
		app_exception.raise_exception;

	WHEN first_mrc_period_error THEN
		fa_srvr_msg.add_message (
			calling_fn => 'fa_mc_upg1_pkg.get_conversion_info',
			name       => 'FA_MRC_NOT_FIRST_FUTURE',
			token1     => 'FIRST_MRC_PERIOD',
			value1     => l_first_mrc_period);
		app_exception.raise_exception;

	WHEN prev_period_error THEN
		fa_srvr_msg.add_message (
			calling_fn => 'fa_mc_upg1_pkg.get_conversion_info',
			name       => 'FA_MRC_PREV_PERIOD_ERR',
			token1     => 'FIRST_MRC_PERIOD',
                        value1     => l_first_mrc_period);
                app_exception.raise_exception;

	WHEN period_info_error THEN
                fa_srvr_msg.add_message (
                        calling_fn => 'fa_mc_upg1_pkg.get_conversion_info',
                        name       => 'FA_SHARED_SEL_DEPRN_PERIODS');
                app_exception.raise_exception;

	WHEN OTHERS THEN
                fa_srvr_msg.add_sql_error (
                        calling_fn => 'fa_mc_upg1_pkg.get_conversion_info');
                app_exception.raise_exception;

END get_conversion_info;


PROCEDURE set_conversion_status(
                p_book_type_code        IN      VARCHAR2,
                p_rsob_id               IN      NUMBER,
		p_start_pc		IN	NUMBER,
                p_end_pc                IN      NUMBER,
		p_fixed_conversion	IN	VARCHAR2,
		p_mode			IN	VARCHAR2) IS
/* ************************************************************************
    This procedure sets the conversion status in fa_mc_conversion_history
    and fa_mc_book_controls for the Primary Book - Reporting book combination.
    This procedure is called in different modes - select, running, converted.
    When called in select mode, inserts a new row into conversion history
    and sets book controls also to S. This status will then be used in
    transaction approval to prevent transactions in the Primary Book until
    conversion is completed - status of C. The conversion_status is used to
    prevent running conversion before selection. The conversion_status in
    fa_mc_conversion_history and fa_mc_book_controls will be kept in synch.
*************************************************************************/

BEGIN
	IF (p_mode = 'S') THEN

	    -- delete row from a previous run which is out of date
	    DELETE FROM fa_mc_conversion_history
	    WHERE 	set_of_books_id = p_rsob_id AND
			book_type_code = p_book_type_code;

	    INSERT INTO FA_MC_CONVERSION_HISTORY(
				set_of_books_id,
				book_type_code,
				conversion_status,
				period_counter_selected,
				last_update_date)
			VALUES(
				p_rsob_id,
				p_book_type_code,
				p_mode,
				p_end_pc,
				sysdate);

	   UPDATE	fa_mc_book_controls
	   SET		conversion_status = p_mode
	   WHERE
			set_of_books_id = p_rsob_id AND
			book_type_code = p_book_type_code;

	ELSIF (p_mode = 'R') THEN

            UPDATE      fa_mc_conversion_history
            SET         conversion_status = p_mode,
			period_counter_start = p_start_pc,
                        last_update_date = sysdate,
			fixed_rate_conversion = p_fixed_conversion
            WHERE
                        set_of_books_id = p_rsob_id AND
                        book_type_code = p_book_type_code;

           UPDATE       fa_mc_book_controls
           SET          conversion_status = p_mode
           WHERE
                        set_of_books_id = p_rsob_id AND
                        book_type_code = p_book_type_code;

	ELSIF (p_mode = 'SE') THEN

	-- called when select program ends in error. delete the record from
	-- conversion history to force rerun of selection program phase 1
	-- rollback assets that have been inserted into rates table since
	-- the last commit

	    FND_CONCURRENT.AF_ROLLBACK;
	    DELETE FROM fa_mc_conversion_history
	    WHERE	set_of_books_id = p_rsob_id AND
			book_type_code = p_book_type_code;

	    UPDATE      fa_mc_book_controls
	    SET		conversion_status = NULL
	    WHERE 	set_of_books_id = p_rsob_id AND
			book_type_code = p_book_type_code;

	ELSIF (p_mode = 'RE') THEN
	-- called when conversion program ends in error
	-- set conversion status to Error

            UPDATE  	fa_mc_conversion_history
            SET     	conversion_status = 'E'
            WHERE
                    	set_of_books_id = p_rsob_id AND
                    	book_type_code = p_book_type_code;

            UPDATE	fa_mc_book_controls
            SET         conversion_status = 'E'
            WHERE       set_of_books_id = p_rsob_id AND
                        book_type_code = p_book_type_code;

	ELSIF (p_mode = 'C') THEN

	    UPDATE 	fa_mc_conversion_history
	    SET		conversion_status = p_mode,
			period_counter_converted = p_end_pc,
			last_update_date = sysdate
	    WHERE
			set_of_books_id = p_rsob_id AND
			book_type_code = p_book_type_code;

	    UPDATE 	fa_mc_book_controls
	    SET		mrc_converted_flag = 'Y',
			last_period_counter = p_end_pc - 1,
			conversion_status = p_mode
	    WHERE
			set_of_books_id = p_rsob_id AND
                        book_type_code = p_book_type_code;
	END IF;

	FND_CONCURRENT.AF_COMMIT;

EXCEPTION
	WHEN OTHERS THEN
                fa_srvr_msg.add_sql_error (
                        calling_fn => 'fa_mc_upg1_pkg.set_conversion_status');
                app_exception.raise_exception;

END set_conversion_status;


PROCEDURE get_candidate_assets(
                p_book_type_code        IN      VARCHAR2,
		p_rsob_id		IN	NUMBER,
		p_start_pc		IN	NUMBER,
		p_end_pc		IN	NUMBER,
		p_exchange_rate		IN	NUMBER,
		p_fixed_rate		IN	VARCHAR2,
		X_total_assets	 OUT NOCOPY NUMBER) IS
/* ************************************************************************
   This procedure selects all the assets in a Primary Book that need to be
   converted  for a given reporting book and inserts them into
   fa_mc_conversion_rates.  The assets selected are those that are not
   fully retired as of the beginning of the fiscal year, represented by
   p_start_pc, being converted. All other assets will be selected.
   The assets are selected in two parts, those that have DEPRN rows in the
   year being converted and those that have their last DEPRN row in a
   prior year. LAST_PERIOD_COUNTER indicates the last period with a DEPRN row
   for each asset and helps to avoid using max later on in conversion.
   The assets are selected in a loop so that commit size does
   not get too large to prevent running out of rollback segments.
************************************************************************ */
	l_lock_status 		BOOLEAN;
	lock_error		EXCEPTION;

BEGIN

   -- lock the book controls row for book - reporting book combination
   l_lock_status := lock_book(
                         p_book_type_code,
                         p_rsob_id);
   IF (NOT l_lock_status) THEN
       RAISE lock_error;
   END IF;

    -- First delete previously selected assets since if this is
    -- called it indicates that phase 1 is being run and we will reselect
    -- all the assets again as the earlier run is out of date

    DELETE FROM fa_mc_conversion_rates
    WHERE	set_of_books_id = p_rsob_id AND
		book_type_code = p_book_type_code;

    X_total_assets := 0;

    -- Select and insert 1000 candidate assets at a time in LOOP
    LOOP
        -- First select all assets with DEPRN rows in FY being converted

        INSERT INTO FA_MC_CONVERSION_RATES(
                                        ASSET_ID,
                                        SET_OF_BOOKS_ID,
                                        BOOK_TYPE_CODE,
                                        EXCHANGE_RATE,
                                        COST,
                                        PRIMARY_CUR_COST,
                                        CONVERSION_BASIS,
                                        STATUS,
                                        LAST_PERIOD_COUNTER)
        SELECT  ad.asset_id,
                p_rsob_id,
                p_book_type_code,
		NULL,
		NULL,
                bk.cost,
                DECODE(p_fixed_rate,
			'Y', 'R',
			decode(bk.cost,
                               0, 'R',
                               NULL)),
                'F',
                ds.period_counter
        FROM
                fa_deprn_summary ds,
		fa_mc_conversion_rates cr,
                fa_books bk,
                fa_additions ad
        WHERE
                bk.date_ineffective is NULL AND
                bk.book_type_code = p_book_type_code AND
                nvl(bk.period_counter_fully_retired, p_end_pc +1) >=
                                                p_start_pc AND
                bk.asset_id = ad.asset_id AND
		cr.asset_id(+) = bk.asset_id AND
		cr.set_of_books_id(+) = p_rsob_id AND
		cr.book_type_code(+) = bk.book_type_code AND
		cr.status is NULL AND
                ds.asset_id = bk.asset_id AND
                ds.book_type_code = bk.book_type_code AND
                ds.period_counter = (
                                SELECT  max(ds2.period_counter)
                                FROM    fa_deprn_summary ds2
                                WHERE   ds2.asset_id = ds.asset_id AND
                                        ds2.book_type_code =
                                                ds.book_type_code AND
                                        ds2.period_counter between p_start_pc
                                                           and p_end_pc) AND
		rownum+0 <= G_Max_Commit_Size;

	X_total_assets := X_total_assets + SQL%ROWCOUNT;

	IF SQL%NOTFOUND THEN
		EXIT;
	END IF;
	FND_CONCURRENT.AF_COMMIT;

	-- obtain lock again after commit
	l_lock_status := lock_book(
                		p_book_type_code,
                		p_rsob_id);
	IF (NOT l_lock_status) THEN
	   RAISE lock_error;
	END IF;

    END LOOP;

    LOOP
	-- select assets with last DEPRN row in prior Fiscal Year

        INSERT INTO FA_MC_CONVERSION_RATES(
                                        ASSET_ID,
                                        SET_OF_BOOKS_ID,
                                        BOOK_TYPE_CODE,
                                        EXCHANGE_RATE,
                                        COST,
                                        PRIMARY_CUR_COST,
                                        CONVERSION_BASIS,
                                        STATUS,
                                        LAST_PERIOD_COUNTER)
        SELECT  ad.asset_id,
                p_rsob_id,
                p_book_type_code,
		NULL,
                NULL,
                bk.cost,
                DECODE(p_fixed_rate,
                        'Y', 'R',
                        decode(bk.cost,
                               0, 'R',
                               NULL)),
                'L',
                ds.period_counter
        FROM
                fa_books bk,
                fa_deprn_summary ds,
                fa_additions ad,
                fa_mc_conversion_rates cr
        WHERE
                bk.date_ineffective is NULL AND
                bk.book_type_code = p_book_type_code AND
                nvl(bk.period_counter_fully_retired, p_end_pc +1) >=
                                                p_start_pc AND
                bk.asset_id = ad.asset_id AND
                cr.asset_id(+) = bk.asset_id AND
		cr.set_of_books_id(+) = p_rsob_id AND
		cr.book_type_code(+) = p_book_type_code AND
                cr.status is NULL AND
                ds.asset_id = bk.asset_id AND
                ds.book_type_code = bk.book_type_code AND
                ds.period_counter = (
                                SELECT  max(ds2.period_counter)
                                FROM    fa_deprn_summary ds2
                                WHERE   ds2.asset_id = ds.asset_id AND
                                        ds2.book_type_code =
                                                ds.book_type_code) AND
		rownum+0 <= G_Max_Commit_Size;

	X_total_assets := X_total_assets + SQL%ROWCOUNT;

	IF SQL%NOTFOUND THEN
		EXIT;
	END IF;
	FND_CONCURRENT.AF_COMMIT;

        l_lock_status := lock_book(
                                p_book_type_code,
                                p_rsob_id);
        IF (NOT l_lock_status) THEN
           RAISE lock_error;
        END IF;

    END LOOP;

    -- update history table with number of assets selected
    UPDATE 	fa_mc_conversion_history
    SET		total_assets = X_total_assets
    WHERE	book_type_code = p_book_type_code AND
		set_of_books_id = p_rsob_id;
    FND_CONCURRENT.AF_COMMIT;

EXCEPTION
        WHEN lock_error THEN
                FND_CONCURRENT.AF_ROLLBACK ;
                set_conversion_status(
                                p_book_type_code,
                                p_rsob_id,
                                p_start_pc,
                                p_end_pc,
                                NULL,
                                'SE');
                fa_srvr_msg.add_sql_error (
                        calling_fn => 'fa_mc_upg1_pkg.get_candidate_assets');
                app_exception.raise_exception;

	WHEN OTHERS THEN
		FND_CONCURRENT.AF_ROLLBACK ;
        	set_conversion_status(
                                p_book_type_code,
                                p_rsob_id,
				p_start_pc,
                                p_end_pc,
                                NULL,
                                'SE');
                fa_srvr_msg.add_sql_error (
                	calling_fn => 'fa_mc_upg1_pkg.get_candidate_assets');
                app_exception.raise_exception;

END get_candidate_assets;


PROCEDURE get_currency_precision(
			p_to_currency 	IN 	VARCHAR2,
			X_precision OUT NOCOPY NUMBER,
			X_mau	 OUT NOCOPY NUMBER)	IS
/* ************************************************************************
   This procedure gets the minimum accountable unit and precision for the
   reporting currency which will be used in rounding currency amounts
   in the conversion
************************************************************************ */

	CURSOR precision IS
		SELECT
			fc.precision, fc.minimum_accountable_unit
		FROM
			fnd_currencies fc
        	WHERE
			fc.currency_code = p_to_currency;

	precision_error		exception;
BEGIN
	OPEN precision;
	FETCH precision into X_precision,
			     X_mau;

	IF (precision%NOTFOUND) THEN
	    RAISE precision_error;
	END IF;

	CLOSE precision;

EXCEPTION
	WHEN OTHERS THEN
                fa_srvr_msg.add_sql_error (
                     calling_fn => 'fa_mc_upg1_pkg.get_currency_precision');
                app_exception.raise_exception;

END get_currency_precision;


PROCEDURE get_rate_info(
		p_from_currency		IN	VARCHAR2,
		p_to_currency		IN	VARCHAR2,
		p_conv_date		IN	DATE,
		p_conv_type		IN 	VARCHAR2,
		X_denominator_rate  OUT NOCOPY NUMBER,
		X_numerator_rate OUT NOCOPY NUMBER,
		X_rate		 OUT NOCOPY NUMBER,
		X_relation	 OUT NOCOPY VARCHAR2,
		X_fixed_rate	 OUT NOCOPY     VARCHAR2) IS
/* ************************************************************************
   This procedure will obtain the triangulation information between the
   currency of the Primary Book and the Reporting Book based on the
   conversion date and type as defined in GL. The info is obtained by
   by calling the GL_CURRENCY_API to get the relation between the currencies
   and the exchange rate to use based on the conversion date. In cases where
   user does not provide a rate for an asset the rate obtained here will
   be used as default. In the case of conversion within EMU, the rate
   returned for denominator_rate and numerator_rate will be used.
************************************************************************ */
	l_fixed_rate	boolean;

BEGIN
	gl_currency_api.get_relation(
					p_from_currency,
				     	p_to_currency,
				     	p_conv_date,
				     	l_fixed_rate,
				     	X_relation);
	IF (l_fixed_rate) THEN
	    X_fixed_rate := 'Y';
	ELSE X_fixed_rate := 'N';
	END IF;

	-- call gl api to get the exchange rate to use for assets
	-- with conversion basis of R but no rate specified in the
 	-- exchange_rate column of fa_mc_conversion_rates. This is
	-- default exchange rate as of the init conversion date specified
	-- in gl for this reporting book. For EMU conversion, we will use
        -- X_denominator_rate and X_numerator_rate for triangulation
	gl_currency_api.get_triangulation_rate(
					p_from_currency,
                                        p_to_currency,
                                        p_conv_date,
                                        p_conv_type,
                                        X_denominator_rate,
                                        X_numerator_rate,
                                        X_rate);
	-- debug messages
	if (g_print_debug) then
		fa_debug_pkg.add('get_rate_info','fixed relation',
				l_fixed_rate);
		fa_debug_pkg.add('get_rate_info','relation',
				X_relation);
		fa_debug_pkg.add('get_rate_info','denominator_rate',
				X_denominator_rate);
		fa_debug_pkg.add('get_rate_info','numerator_rate',
				X_numerator_rate);
		fa_debug_pkg.add('get_rate_info','exchange rate', X_rate);
	end if;

EXCEPTION
	WHEN OTHERS THEN
                fa_srvr_msg.add_message (
                	calling_fn => 'fa_mc_upg1_pkg.get_rate_info',
                        name       => 'FA_MRC_CONV_RATE_ERR',
			token1     => 'REPORTING_BOOK',
			value1	   => G_rbook_name);
                fa_srvr_msg.add_sql_error (
                     calling_fn => 'fa_mc_upg1_pkg.get_rate_info');
                app_exception.raise_exception;

END get_rate_info;


PROCEDURE check_preview_status(
                p_book_type_code        IN      VARCHAR2,
                p_rsob_id               IN      NUMBER,
                p_end_pc                IN      NUMBER) IS
/* ************************************************************************
   This procudure will check to see if phase1 has been run for a given
   Primary Book - Reporting Book combination in order to prevent running
   conversion before phase 1. An exception is raised in this case. It also
   checks to make sure that selection is not out of date(this won't happen
   as we prevent transactions including depreciation from being run in the
   Primary Book).
************************************************************************ */

        invalid_select         	exception;
        no_select              	exception;
	in_process		exception;
        l_period_counter        number;
        l_count                 number;
	l_total_assets		number;
	l_status		VARCHAR2(1);

	CURSOR check_preview IS
		SELECT	period_counter_selected,
			total_assets,
			conversion_status
		FROM	fa_mc_conversion_history
		WHERE   set_of_books_id = p_rsob_id AND
			book_type_code = p_book_type_code AND
			conversion_status in ('S', 'E', 'R');

	CURSOR check_assets IS
		SELECT  count(*)
		FROM	fa_mc_conversion_rates
		WHERE	set_of_books_id = p_rsob_id AND
                        book_type_code = p_book_type_code;

BEGIN
	OPEN check_preview;
	FETCH check_preview into l_period_counter, l_total_assets, l_status;
	IF (check_preview%NOTFOUND) THEN
	   RAISE no_select;
	ELSIF (l_period_counter <> p_end_pc) THEN
	   RAISE invalid_select;
	ELSIF (l_status = 'R') THEN
	   RAISE in_process;
	ELSE
	   OPEN check_assets;
	   FETCH check_assets into l_count;
	   CLOSE check_assets;
	   IF (l_count <> l_total_assets) THEN
	       raise invalid_select;
	   END IF;
	END IF;
	CLOSE check_preview;

EXCEPTION
	WHEN invalid_select THEN
                fa_srvr_msg.add_message (
                	calling_fn => 'fa_mc_upg1_pkg.check_preview_status',
                	name       => 'FA_MRC_INVALID_SELECT',
			token1	   => 'BOOK',
			value1     => p_book_type_code,
			token2     => 'REPORTING_BOOK',
			value2     => G_rbook_name);
                app_exception.raise_exception;

	WHEN in_process THEN
		fa_srvr_msg.add_message (
			calling_fn => 'fa_mc_upg1_pkg.check_preview_status',
			name       => 'FA_MRC_CONV_RUNNING',
                        token1     => 'BOOK',
                        value1     => p_book_type_code,
                        token2     => 'REPORTING_BOOK',
                        value2     => G_rbook_name);
		app_exception.raise_exception;

	WHEN no_select THEN
                fa_srvr_msg.add_message (
                        calling_fn => 'fa_mc_upg1_pkg.check_preview_status',
                        name       => 'FA_MRC_NO_SELECT',
                        token1     => 'BOOK',
                        value1     => p_book_type_code,
                        token2     => 'REPORTING_BOOK',
                        value2     => G_rbook_name);
                app_exception.raise_exception;

	WHEN OTHERS THEN
                fa_srvr_msg.add_sql_error (
                     	calling_fn => 'fa_mc_upg1_pkg.check_preview_status');
                app_exception.raise_exception;

END check_preview_status;


PROCEDURE convert_reporting_book(
		p_book_type_code	IN	VARCHAR2,
		p_reporting_book	IN	VARCHAR2,
		p_fixed_rate		IN	VARCHAR2) IS
/* ************************************************************************
   This procedure is the main routine to convert all the assets in a
   Primary Book to the Reporting Book. It accepts the Primary and Reporting
   Book as parameters and also whether it is a fixed rate conversion or
   not. This procedure calls all the validation routines and sets the
   conversion history status before calling convert assets to actually
   convert the records.
************************************************************************ */

	l_psob_id		number;
	l_rsob_id		number;
	l_start_pc		number;
	l_end_pc		number;
	l_mau			number;
	l_precision		number;
	l_from_currency		varchar2(10);
	l_to_currency		varchar2(10);
	l_denominator_rate	number;
	l_numerator_rate	number;
	l_rate			number;
	l_relation		varchar2(15);
	l_conv_date		date;
	l_conv_type		varchar2(30);
	l_fixed_conversion	varchar2(1);
	l_fixed_rate		varchar2(1);
	l_accounting_date	date;

BEGIN

   begin

	-- Perform validation of set up
	validate_setup(	p_book_type_code,
			p_reporting_book,
			l_from_currency,
			l_to_currency,
			l_rsob_id,
			l_psob_id);

   exception

   when others then
      fa_srvr_msg.add_sql_error (
         calling_fn => 'fa_mc_upg1_pkg.convert_reporting_book=>validate_setup');
      app_exception.raise_exception;

   end;

   begin

	-- get info from gl book assignments and periods to convert
	get_conversion_info(
			p_book_type_code,
			l_psob_id,
			l_rsob_id,
			l_start_pc,
			l_end_pc,
			l_conv_date,
			l_conv_type,
			l_accounting_date);

   exception

   when others then
      fa_srvr_msg.add_sql_error (
         calling_fn => 'fa_mc_upg1_pkg.convert_reporting_book=>get_conversion_info');
      app_exception.raise_exception;

   end;

   begin

	-- get exchange rate and triangulation rate info
	get_rate_info(
			l_from_currency,
			l_to_currency,
			l_conv_date,
			l_conv_type,
			l_denominator_rate,
			l_numerator_rate,
			l_rate,
			l_relation,
			l_fixed_rate);

   exception

   when others then
      fa_srvr_msg.add_sql_error (
         calling_fn => 'fa_mc_upg1_pkg.convert_reporting_book=>get_rate_info');
      app_exception.raise_exception;

   end;

   begin

	get_currency_precision(
			l_to_currency,
			l_precision,
			l_mau);

   exception

   when others then
      fa_srvr_msg.add_sql_error (
         calling_fn => 'fa_mc_upg1_pkg.convert_reporting_book=>get_currency_precision');
      app_exception.raise_exception;

   end;

   begin

        -- check if asset selection has been run
        check_preview_status(
                        p_book_type_code,
                        l_rsob_id,
                        l_end_pc);

   exception

   when others then
      fa_srvr_msg.add_sql_error (
         calling_fn => 'fa_mc_upg1_pkg.convert_reporting_book=>check_preview_status');
      app_exception.raise_exception;

   end;

   begin

        -- validate conversion basis and rate info
        validate_rate (
                        p_book_type_code,
                        l_rsob_id,
                        p_fixed_rate,
                        l_fixed_conversion);

   exception

   when others then
      fa_srvr_msg.add_sql_error (
         calling_fn => 'fa_mc_upg1_pkg.convert_reporting_book=>validate_rate');
      app_exception.raise_exception;

   end;

   begin

	-- set conversion status to running
        set_conversion_status(
                        p_book_type_code,
                        l_rsob_id,
			l_start_pc,
                        l_end_pc,
			l_fixed_conversion,
                        'R');

   exception

   when others then
      fa_srvr_msg.add_sql_error (
         calling_fn => 'fa_mc_upg1_pkg.convert_reporting_book=>set_conversion_status');
      app_exception.raise_exception;

   end;

   begin

	-- convert all assets
	convert_assets(	l_rsob_id,
			p_book_type_code,
			l_start_pc,
	       		l_end_pc,
			l_numerator_rate,
			l_denominator_rate,
			l_mau,
			l_precision,
			l_fixed_conversion);

   exception

   when others then
      fa_srvr_msg.add_sql_error (
         calling_fn => 'fa_mc_upg1_pkg.convert_reporting_book=>convert_assets');
      app_exception.raise_exception;

   end;

EXCEPTION
        WHEN OTHERS THEN
                fa_srvr_msg.add_sql_error (
                        calling_fn => 'fa_mc_upg1_pkg.convert_reporting_book');
                app_exception.raise_exception;
END convert_reporting_book;


PROCEDURE convert_assets(
			p_rsob_id		IN 	NUMBER,
			p_book_type_code	IN	VARCHAR2,
			p_start_pc		IN 	NUMBER,
			p_end_pc		IN 	NUMBER,
			p_numerator_rate	IN	NUMBER,
			p_denominator_rate	IN	NUMBER,
			p_mau			IN	NUMBER,
			p_precision		IN	NUMBER,
			p_fixed_conversion	IN	VARCHAR2) IS
/* ************************************************************************
   This procedure will have the main processing LOOP and calls
   to procedures for converting the required tables.  We are
   converting all the tables for 1000 assets and COMMITTING.
   This is to try and prevent running out of rollback segments.
   Max commit size of 1000 is stored in the constant
   G_Max_Commit_Size.

   Select assets which have DEPRN rows for the fiscal year being
   being converted first denoted by F and THEN select the other
   assets which have their last DEPRN row in prior fiscal year
   denoted by status of L
************************************************************************ */

        l_assets_to_convert     NUMBER;  -- assets to convert in this run
        l_assets_processed      NUMBER;  -- assets processed in this run

        l_commit_size           NUMBER;  -- assets to be committed in 1
					 -- iteration of loop

        l_deprn_assets          NUMBER := 0; -- assets with DEPRN rows in fy
        l_no_deprn_assets       NUMBER := 0; -- assets with DEPRN row in pfy
        l_convert_order         VARCHAR2(1);
        l_status                VARCHAR2(2);
        l_count                 number;
        l_converted_assets      number := 0; -- assets already converted
        l_total_assets          number := 0; -- total candidate assets
	index_flag		BOOLEAN := FALSE;

	l_mesg_str		varchar2(512);

	CURSOR total_assets IS
		SELECT
			count(*),
			status
		FROM
			fa_mc_conversion_rates cr
		WHERE
			cr.set_of_books_id = p_rsob_id AND
			cr.book_type_code = p_book_type_code
		GROUP BY status;

BEGIN
	OPEN total_assets;
	LOOP
		l_count := 0;
		FETCH total_assets into l_count, l_status;
		IF (total_assets%NOTFOUND) THEN
		   exit;
		END IF;
		IF (l_status = 'F') THEN
		   l_deprn_assets := l_deprn_assets + l_count;
		ELSIF (l_status = 'L') THEN
		   l_no_deprn_assets := l_no_deprn_assets + l_count;
		ELSIF (l_status IN ('CF', 'CL')) THEN
		   l_converted_assets := l_converted_assets + l_count;
		END IF;
	END LOOP;

	CLOSE total_assets;

	l_assets_to_convert := l_deprn_assets + l_no_deprn_assets;
	l_total_assets := l_assets_to_convert + l_converted_assets;
	l_assets_processed := 0;
	l_commit_size := 0;

	if (g_print_debug) then
	 	fa_debug_pkg.add('convert_assets',
				'Number of assets with DEPRN in current fy',
				l_deprn_assets);
		fa_debug_pkg.add('convert_assets',
				'Number of assets with no DEPRN in current fy',
				l_no_deprn_assets);
		fa_debug_pkg.add('convert_assets',
				'Number of assets already converted',
				l_converted_assets);
		fa_debug_pkg.add('convert_assets',
				'Number of assets to convert in this run',
				l_assets_to_convert);
		fa_debug_pkg.add('convert_assets',
				'Total number of assets to convert',
				l_total_assets);
	end if;

	-- select 1000 assets at a time and update the status to S to
        -- indicate selected for conversion

	WHILE (l_assets_processed <> l_assets_to_convert) LOOP
/*
		IF (l_assets_to_convert > 0) THEN
		    create_drop_indexes('D');
		    index_flag := TRUE;
		END IF;
*/
		IF (l_assets_processed < l_deprn_assets) THEN

			UPDATE 	fa_mc_conversion_rates
			SET	STATUS = 'S'
			WHERE	set_of_books_id = p_rsob_id AND
				book_type_code = p_book_type_code AND
				STATUS = 'F'  AND
                                rownum <= G_Max_Commit_Size;

			l_commit_size := SQL%ROWCOUNT;
			l_convert_order := 'F';
		ELSE
			UPDATE 	fa_mc_conversion_rates
			SET	STATUS = 'S'
			WHERE	set_of_books_id = p_rsob_id AND
				book_type_code = p_book_type_code AND
				STATUS = 'L' AND
				rownum <= G_Max_Commit_Size;

			l_commit_size := SQL%ROWCOUNT;
			l_convert_order := 'L';
		END IF;

	        if (g_print_debug) then
                	fa_debug_pkg.add('convert_assets',
                                'Number of assets selected in this iteration',
                                l_commit_size);
			fa_debug_pkg.add('convert_assets',
				'Converting assets with status',
				l_convert_order);
		end if;

		fa_mc_upg2_pkg.convert_books(
				p_rsob_id,
			      	p_book_type_code,
			     	p_numerator_rate,
				p_denominator_rate,
			      	p_mau,
			      	p_precision);

		fa_mc_upg2_pkg.insert_bks_rates(
				p_rsob_id,
			    	p_book_type_code,
				p_numerator_rate,
				p_denominator_rate,
				p_precision);

		fa_mc_upg2_pkg.convert_invoices(
				p_rsob_id,
			 	p_book_type_code,
				p_numerator_rate,
				p_denominator_rate,
				p_mau,
				p_precision);

		fa_mc_upg2_pkg.convert_adjustments(
				p_rsob_id,
			   	p_book_type_code,
    			    	p_start_pc,
				p_end_pc,
				p_numerator_rate,
				p_denominator_rate,
				p_mau,
				p_precision);

		fa_mc_upg2_pkg.convert_retirements(
				p_rsob_id,
			    	p_book_type_code,
    				p_start_pc,
				p_end_pc,
				p_numerator_rate,
				p_denominator_rate,
				p_mau,
				p_precision);

		fa_mc_upg2_pkg.convert_deprn_summary(
				p_book_type_code,
			      	p_rsob_id,
  				p_start_pc,
				p_end_pc,
				l_convert_order,
				p_mau,
				p_precision);

		fa_mc_upg2_pkg.convert_deprn_detail(
				p_rsob_id,
				p_book_type_code,
				p_mau,
				p_precision);

                fa_mc_upg2_pkg.convert_deferred_deprn(
                                p_rsob_id,
                                p_book_type_code,
                                p_start_pc,
                                p_end_pc,
                                p_numerator_rate,
                                p_denominator_rate,
                                p_mau,
                                p_precision);


	-- all tables have been converted successfully for the assets selected
	-- update the status to converted and commit and increment
   	-- assets processed with the numbers of assets converted

		UPDATE 	fa_mc_conversion_rates
		SET	STATUS = DECODE(l_convert_order,
					'F', 'CF',
					'L', 'CL')
		WHERE
			set_of_books_id = p_rsob_id AND
			book_type_code = p_book_type_code AND
			STATUS = 'S';
		FND_CONCURRENT.AF_COMMIT;
		l_assets_processed := l_assets_processed + l_commit_size;

	END LOOP;  -- while LOOP

        fa_srvr_msg.add_message(
                calling_fn => 'fa_mc_upg1_pkg.convert_assets',
                name       => 'FA_SHARED_NUMBER_PROCESSED',
                token1     => 'NUMBER',
                value1     => to_char(l_assets_processed));

        if (g_print_debug) then
                fa_debug_pkg.add('convert_assets',
                                'number of assets processed in this run',
                                l_assets_processed);
	end if;

	-- After all assets are converted set conversion status to C
	-- and mrc_converted_flag to Y by calling set_conversion_status
	-- convert deprn periods after all assets are converted.

	IF ((l_converted_assets + l_assets_processed) = l_total_assets) THEN
           fa_mc_upg2_pkg.convert_deprn_periods (
                                p_rsob_id,
                                p_book_type_code,
                                p_start_pc,
                                p_end_pc);

	    set_conversion_status(
				p_book_type_code,
				p_rsob_id,
				p_start_pc,
				p_end_pc,
				p_fixed_conversion,
				'C');

	    if (g_print_debug) then
                fa_debug_pkg.add('convert_assets',
				'All assets converted for reporting book',
				l_total_assets);
	    end if;

	END IF;
/*
	IF (index_flag) THEN
	   create_drop_indexes('C');
	END IF;
*/

EXCEPTION
	WHEN OTHERS THEN
		-- rollback everything since last commit
		FND_CONCURRENT.AF_ROLLBACK ;
/*
        	IF (index_flag) THEN
           	    create_drop_indexes('C');
        	END IF;
*/

		-- set conversion_status to Error
            	set_conversion_status(
                                p_book_type_code,
                                p_rsob_id,
                                p_start_pc,
                                p_end_pc,
                                p_fixed_conversion,
                                'RE');
        	fa_srvr_msg.add_message(
                	calling_fn => 'fa_mc_upg1_pkg.convert_assets',
                	name       => 'FA_SHARED_NUMBER_PROCESSED',
                	token1     => 'NUMBER',
                	value1     => to_char(l_assets_processed));

                fa_srvr_msg.add_sql_error (
                        calling_fn => 'fa_mc_upg1_pkg.convert_assets');
                app_exception.raise_exception;

END convert_assets;

PROCEDURE  Write_ErrMsg_Log(
       		msg_count       	IN	NUMBER) IS
/* ************************************************************************
  -- For test purpose, you may set h_coded to TRUE.  Then messages will be
  -- printed out in encoded format instead of translated format.
  -- This is useful
  -- if you want to test the message, but if you have not registered your
  -- message yet in the message dictionary.
  -- Normally h_encoded should be set to FALSE.
************************************************************************ */

  h_encoded varchar2(1) := fnd_api.G_FALSE;
  --h_encoded varchar(1):= fnd_api.G_TRUE;

BEGIN


    if (msg_count <= 0) then
        NULL;
    -- Commenting out the next portion, since we do not want to print message
    -- which we are not sure whether it is in encoded or translated format.
    --elsif (msg_count = 1 and msg_data IS NOT NULL) then
    --  fa_rx_conc_mesg_pkg.log(msg_data);
    else
     fa_rx_conc_mesg_pkg.log(
			fnd_msg_pub.get(fnd_msg_pub.G_FIRST, h_encoded));
        for i in 1..(msg_count-1) loop
            fa_rx_conc_mesg_pkg.log(
			fnd_msg_pub.get(fnd_msg_pub.G_NEXT, h_encoded));
        end loop;
    end if;

/*
    -- write using dbms output for testing only
    if (msg_count <= 0) then
        NULL;
    else
        dbms_output.put_line(fnd_msg_pub.get(fnd_msg_pub.G_FIRST, h_encoded));
        for i in 1..(msg_count-1) loop
        dbms_output.put_line(fnd_msg_pub.get(fnd_msg_pub.G_NEXT, h_encoded));
        end loop;
    end if;
*/

EXCEPTION
	WHEN OTHERS THEN
                fa_srvr_msg.add_sql_error (
                        calling_fn => 'fa_mc_upg1_pkg.Write_Msg_Log');
END Write_ErrMsg_Log;

PROCEDURE  Write_DebugMsg_Log(
                p_msg_count               IN      NUMBER) IS
/* ************************************************************************
   This procedure will write all the debug messages on the debug stack to
   the log file.
************************************************************************ */


	mesg_more	boolean := TRUE;
        mesg1 		varchar2(280);
        mesg2 		varchar2(280);
        mesg3 		varchar2(280);
        mesg4 		varchar2(280);
        mesg5 		varchar2(280);
        mesg6 		varchar2(280);
        mesg7 		varchar2(280);
        mesg8 		varchar2(280);
        mesg9 		varchar2(280);
        mesg10 		varchar2(280);

BEGIN
	fa_rx_conc_mesg_pkg.log('');
	fa_rx_conc_mesg_pkg.log('*************************');
	fa_rx_conc_mesg_pkg.log('Dumping Debug Messages:');
	fa_rx_conc_mesg_pkg.log('*************************');

/*
	-- dbms output for testing only
	dbms_output.put_line('');
	dbms_output.put_line('*************************');
	dbms_output.put_line('Dumping Debug Messages:');
	dbms_output.put_line('*************************');
*/

        while mesg_more loop
		FA_DEBUG_PKG.Get_Debug_Messages(
                          mesg1,mesg2,mesg3,mesg4,mesg5,mesg6,mesg7,
                          mesg8,mesg9,mesg10,
                          mesg_more);

                fa_rx_conc_mesg_pkg.log(mesg1);
                fa_rx_conc_mesg_pkg.log(mesg2);
                fa_rx_conc_mesg_pkg.log(mesg3);
                fa_rx_conc_mesg_pkg.log(mesg4);
                fa_rx_conc_mesg_pkg.log(mesg5);
                fa_rx_conc_mesg_pkg.log(mesg6);
                fa_rx_conc_mesg_pkg.log(mesg7);
		fa_rx_conc_mesg_pkg.log(mesg8);
		fa_rx_conc_mesg_pkg.log(mesg9);
		fa_rx_conc_mesg_pkg.log(mesg10);
/*
		-- use dbms output for testing only
                dbms_output.put_line (mesg1);
                dbms_output.put_line (mesg2);
                dbms_output.put_line (mesg3);
                dbms_output.put_line (mesg4);
                dbms_output.put_line (mesg5);
                dbms_output.put_line (mesg6);
                dbms_output.put_line (mesg7);
		dbms_output.put_line (mesg8);
		dbms_output.put_line (mesg9);
		dbms_output.put_line (mesg10);
*/
         end loop;
EXCEPTION
	WHEN OTHERS THEN
                fa_srvr_msg.add_sql_error (
                        calling_fn => 'fa_mc_upg1_pkg.Write_DebugMsg_Log');
                RAISE;
END Write_DebugMsg_Log;

END FA_MC_UPG1_PKG;

/
