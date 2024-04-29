--------------------------------------------------------
--  DDL for Package Body IGI_IMP_IAC_EXCEP_INER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IMP_IAC_EXCEP_INER_PKG" AS
-- $Header: igiiaerb.pls 120.13.12000000.1 2007/08/01 16:15:16 npandya noship $

--===========================FND_LOG.START=====================================

g_state_level NUMBER	     :=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER	     :=	FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER	     :=	FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER	     :=	FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER	     :=	FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER	     :=	FND_LOG.LEVEL_UNEXPECTED;
g_path        VARCHAR2(100)  := 'IGI.PLSQL.igiiaerb.IGI_IMP_IAC_EXCEP_INER_PKG.';

--===========================FND_LOG.END=====================================

  l_message varchar2(1000);
  l_concat_asset_key	VARCHAR2(200);
  l_period_name		VARCHAR2(15);
  l_company_name	VARCHAR2(30);
  l_fiscal_year_name	VARCHAR2(30);
  l_currency_code       VARCHAR2(15);
  l_g_loc_struct	NUMBER;
  l_g_asset_key_struct	NUMBER;
  l_g_cat_struct 	NUMBER;
  l_concat_loc		VARCHAR2(200);
  l_loc_segs		fa_rx_shared_pkg.Seg_Array;
  l_asset_segs		fa_rx_shared_pkg.Seg_Array;
  l_sob_name   VARCHAR2(30);
  l_asset_cat_id	NUMBER(15);
  l_concat_cat         VARCHAR2(500);
  l_cat_segs           fa_rx_shared_pkg.Seg_Array;
  p_asset_id  number;

    FUNCTION get_period_name (p_book	IN	VARCHAR2
                            ,p_period	IN	VARCHAR2)
    RETURN BOOLEAN IS

        CURSOR c_period (cp_bookType VARCHAR2, cp_period VARCHAR2) IS
        SELECT period_name
        FROM   fa_deprn_periods
        WHERE  Book_Type_Code = cp_bookType
        AND period_counter = TO_NUMBER(cp_period);

        l_selOk		BOOLEAN := FALSE;
        l_path varchar2(100) := g_path||'get_period_name';
    BEGIN
        FOR l_period in c_period (p_book, p_period) LOOP
            l_period_name := l_period.period_name;
            l_selOk := TRUE;
        END LOOP;

        IF NOT l_selOk THEN
            RETURN FALSE;
        END IF;

        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_period_name ' || l_period_name);
        RETURN TRUE;

    EXCEPTION
        WHEN OTHERS THEN
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Exception within "get_period_name" : '|| sqlerrm);
        RETURN FALSE;
    END get_period_name;

    FUNCTION get_flex_segments (p_book IN VARCHAR2 )
    RETURN BOOLEAN IS

        CURSOR c_flex(cp_bookType VARCHAR2) IS
        SELECT
            sob.name,
            sc.Company_Name,
            sc.Category_Flex_Structure,
            sc.Location_Flex_Structure,
            sc.asset_key_flex_structure,
            bc.Accounting_Flex_Structure,
            ct.fiscal_year_name,
            sob.Currency_Code
        FROM
            fa_system_controls	sc,
            fa_book_controls 	bc,
            gl_sets_of_books 	sob,
            fa_calendar_types       ct
        WHERE
            bc.Book_Type_Code = cp_bookType
            AND	sob.Set_Of_Books_ID = BC.Set_Of_Books_ID
            AND bc.deprn_calendar = ct.calendar_type;

        l_cat_struct		NUMBER;
        l_loc_struct		NUMBER;
        l_asset_key_struct		NUMBER;
        l_acct_struct		NUMBER;
        l_selOk			BOOLEAN := FALSE;
        l_path varchar2(100) := g_path||'get_flex_segments';
    BEGIN
        FOR l_flex in c_flex (p_book) LOOP
            l_sob_name   := l_flex.name;
            l_company_name := l_flex.Company_Name;
            l_cat_struct := l_flex.Category_Flex_Structure;
            l_loc_struct := l_flex.Location_Flex_Structure;
            l_asset_key_struct := l_flex.asset_key_flex_structure;
            l_acct_struct := l_flex.Accounting_Flex_Structure;
            l_fiscal_year_name := l_flex.fiscal_year_name;
            l_currency_code := l_flex.Currency_Code;
            l_selOk := TRUE;
        END LOOP;

        IF NOT l_selOk THEN
            RETURN FALSE;
        END IF;

        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_company_name ' || l_company_name);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_cat_struct ' || l_cat_struct);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_loc_struct ' || l_loc_struct);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_asset_key_struct ' || l_asset_key_struct);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_acct_struct ' || l_acct_struct);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_fiscal_year_name ' || l_fiscal_year_name);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_currency_code ' || l_currency_code);

        l_g_loc_struct := l_loc_struct;
        l_g_asset_key_struct := l_asset_key_struct;
        l_g_cat_struct := l_cat_struct;
        RETURN TRUE;
    EXCEPTION
        WHEN OTHERS THEN
        igi_iac_debug_pkg.debug_other_string(g_unexp_level,l_path,'Exception within "get_flex_segments" : '|| sqlerrm);
        RETURN FALSE;

    END get_flex_segments;

    PROCEDURE run_report (p_book                IN      VARCHAR2
                         ,p_period              IN      VARCHAR2
                         ,p_request_id          IN      NUMBER
                         ,p_retcode             OUT NOCOPY NUMBER
                         ,p_errbuf              OUT NOCOPY VARCHAR2) IS

        -- bug 3464589, change cursor to obtain depreciation information
        -- for corporate book
        CURSOR C_Corp_Book_Info(p_book in varchar2, p_period in varchar2) IS
        SELECT  DISTINCT  a.asset_id,
            a.book_type_code,
            a.date_placed_in_service,
            a.life_in_months,
            nvl(a.cost,0) cost,
            nvl(a.adjusted_cost,0) adjusted_cost,
            nvl(a.original_cost,0) original_cost,
            nvl(a.salvage_value,0) salvage_value,
            nvl(a.adjusted_recoverable_cost, 0) adjusted_recoverable_cost,
            nvl(a.recoverable_cost,0) recoverable_cost,
            a.deprn_start_date,
            a.cost_change_flag,
            a.rate_adjustment_factor,
            a.depreciate_flag,
            a.fully_rsvd_revals_counter,
            a.period_counter_fully_reserved,
            a.period_counter_fully_retired ,
            ad.asset_number,
            ad.description,
            b.deprn_reserve,
            b.ytd_deprn
        FROM    fa_books a,
                fa_additions ad,
                fa_deprn_summary b
        WHERE   a.book_type_code = p_book
        AND     ad.asset_id = a.asset_id
        AND     a.date_ineffective IS NULL
        AND     b.asset_id = a.asset_id
        AND     b.book_type_code = a.book_type_code
        AND     b.period_counter = (SELECT MAX(period_counter)
                                    FROM fa_deprn_summary
                                    WHERE book_type_code = a.book_type_code
                                    AND asset_id = a.asset_id);

        Cursor C_Mhca_Book_Info(p_book in varchar2,  p_asset_id in number) Is
        select  a.asset_id ,
            a.book_type_code,
            a.date_placed_in_service,
            a.life_in_months,
            nvl(a.cost,0) cost,
            nvl(a.adjusted_cost,0) adjusted_cost,
            nvl(a.original_cost,0) original_cost,
            nvl(a.salvage_value,0) salvage_value,
            nvl(a.adjusted_recoverable_cost, 0) adjusted_recoverable_cost,
            nvl(a.recoverable_cost,0) recoverable_cost,
            a.deprn_start_date,
            a.cost_change_flag,
            a.rate_adjustment_factor,
            a.depreciate_flag,
            a.fully_rsvd_revals_counter,
            a.period_counter_fully_reserved,
            a.period_counter_fully_retired,
            ad.asset_number,
            ad.description,
            ad.asset_category_id,
            b.period_counter,
            b.deprn_reserve,
            b.ytd_deprn
        from  fa_books a ,
            fa_deprn_summary b,
            fa_additions ad
        Where       a.book_type_code = p_book
        and         a.asset_id = p_asset_id
        and         ad.asset_id = a.asset_id
        and         a.book_type_code = b.book_type_code
        and         b.asset_id = a.asset_id
        and         b.period_counter = (select max(period_counter)
                                        from fa_deprn_summary
                                        where book_type_code =p_book
                                        and asset_id =p_asset_id)
        and         a.date_ineffective is null;

        Cursor C_Tax_Book_Info (p_book in varchar2) Is
        Select book_type_code
        from  igi_mhc_book_controls
        where book_type_code in (Select book_type_code
                                from fa_book_controls
                                where book_class ='TAX'
                                and distribution_source_book =p_book)
                                Order by book_type_code;

        Cursor C_Mhca_Reval_Summary_Info (cp_tax_book in varchar2, p_asset_id in number) Is
        Select         distinct asset_id,
                nvl(original_cost,0) original_cost,
                nvl(new_asset_cost,0) new_asset_cost,
                nvl(new_salvage_value,0) new_salvage_value,
                original_life,
                current_life,
                nvl(old_accum_deprn,0) old_accum_deprn,
                nvl(new_accum_deprn,0) new_accum_deprn,
                nvl(old_reval_reserve,0) old_reval_reserve,
                nvl(new_reval_reserve,0) new_reval_reserve,
                nvl(new_curr_yr_expense,0) new_curr_yr_expense,
                nvl(new_backlog_deprn,0) new_backlog_deprn
        From    igi_mhc_reval_summary_pl_v
        Where   book_type_code = cp_tax_book
        and     asset_id = p_asset_id
        and        period_counter = (select Max(period_counter) from igi_mhc_reval_summary_pl_v
                                Where   book_type_code = cp_tax_book
                                and asset_id = p_asset_id)
        and     reval_mode = 'INDEXED'
        and     active_flag= 'Y'
        and     Run_mode = 'L';

        Cursor C_Concat_Category_Info(p_book in varchar) Is
        Select  category_id
        From    fa_category_books
        Where   book_type_code = p_book;

        -- bug 3442275, start 1
        -- get the depreciation aclendar
        CURSOR c_get_deprn_calendar(cp_book_type_code fa_book_controls.book_type_code%TYPE)
        IS
        SELECT deprn_calendar
        FROM fa_book_controls
        WHERE book_type_code = cp_book_type_code;

        CURSOR c_get_periods_in_year(cp_calendar_type fa_calendar_types.calendar_type%TYPE)
        IS
        SELECT number_per_fiscal_year
        FROM fa_calendar_types
        WHERE calendar_type = cp_calendar_type;

        CURSOR c_get_reval_period(cp_book_type_code igi_iac_book_controls.book_type_code%TYPE)
        IS
        SELECT period_num_for_catchup
        FROM igi_iac_book_controls
        WHERE book_type_code = cp_book_type_code;

        l_deprn_calendar       fa_book_controls.deprn_calendar%TYPE;
        l_num_per_fiscal_year  fa_calendar_types.number_per_fiscal_year%TYPE;
        l_iac_reval_period_num igi_iac_book_controls.period_num_for_catchup%TYPE;

        l_curr_period          igi_iac_types.prd_rec;

        l_curr_period_num      igi_iac_book_controls.period_num_for_catchup%TYPE;
        l_curr_fiscal_year     fa_deprn_periods.fiscal_year%TYPE;
        l_curr_prd_counter     fa_deprn_periods.period_counter%TYPE;
        l_reval_prd_counter    fa_deprn_periods.period_counter%TYPE;

        l_dpis_period          igi_iac_types.prd_rec;
        l_dpis_prd_counter     fa_deprn_periods.period_counter%TYPE;
        l_ret                  BOOLEAN;
        -- bug 3442275, end 1

        l_initial_flag varchar2(1) :='N';
        l_path varchar2(100) := g_path||'run_report';

    BEGIN

        delete  from IGI_IMP_IAC_EXCEP_REP_ITF ;

        -- mh, If  get_flex_segments (p_book)THEN
        IF NOT  get_flex_segments (p_book) THEN
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Failed to get  the Flex Segments period name - will continue.... ');
        End If;

        -- mh, If  get_period_name ( p_book, p_period)THEN
        IF NOT get_period_name ( p_book, p_period) THEN
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Failed to get  the period name - will continue.... ');
        End If;


        -- bug 3442275, start 2
        -- get the depreciation calendar
        OPEN c_get_deprn_calendar(p_book);
        FETCH c_get_deprn_calendar INTO l_deprn_calendar;
        IF c_get_deprn_calendar%NOTFOUND THEN
           RAISE NO_DATA_FOUND;
        END IF;
        CLOSE c_get_deprn_calendar;

        -- get the period numbers per fiscal year for the depreciation calendar
        OPEN c_get_periods_in_year(l_deprn_calendar);
        FETCH c_get_periods_in_year INTO l_num_per_fiscal_year;
        IF c_get_periods_in_year%NOTFOUND THEN
           RAISE NO_DATA_FOUND;
        END IF;
        CLOSE c_get_periods_in_year;

        -- get the iac revlaution period number
        OPEN c_get_reval_period(p_book);
        FETCH c_get_reval_period INTO l_iac_reval_period_num;
        IF c_get_reval_period%NOTFOUND THEN
           l_iac_reval_period_num := 0;
        END IF;
        CLOSE c_get_reval_period;

        -- process only if asset has been registered as IAC Book
        IF (l_iac_reval_period_num > 0) THEN
               -- get period information for the current open period
               l_ret := igi_iac_common_utils.get_period_info_for_name(p_book,
                                                                      l_period_name,
                                                                      l_curr_period);

               l_curr_period_num  := l_curr_period.period_num;
               l_curr_fiscal_year := l_curr_period.fiscal_year;
               l_curr_prd_counter := l_curr_period.period_counter;

               -- calculate the period counter for the reval period of the
               -- current fiscal year
               l_reval_prd_counter := l_curr_period.fiscal_year*l_num_per_fiscal_year
                                       +  l_iac_reval_period_num;

               -- if l_reval_prd_counter is greater than current period counter
               -- get the previous reval period counter
               IF (l_reval_prd_counter > l_curr_prd_counter) THEN
                  l_reval_prd_counter := l_reval_prd_counter - l_num_per_fiscal_year;
               END IF;
        END IF;
        -- bug 3442275, end 2

        --         For C_Corp_Book_Info_Rec in C_Corp_Book_Info(p_book, p_period) Loop
        For C_Corp_Book_Info_Rec in C_Corp_Book_Info(p_book, p_period) Loop
            l_initial_flag := 'N';

            For   C_Tax_Book_Info_Rec in C_Tax_Book_Info(C_Corp_Book_Info_Rec.book_type_code) Loop

                For C_Mhca_Book_Info_Rec In C_Mhca_Book_Info(C_Tax_Book_Info_Rec.book_type_code, C_Corp_Book_Info_Rec.asset_id) Loop

                    l_asset_cat_id := C_Mhca_Book_Info_Rec.asset_category_id;

                    -- for you new cu
                    -- This will get the CONCATANATED LOCATION
                    /* mh, commentiong out as conactenated location not in ITF table
                    fa_rx_shared_pkg.concat_location (
                            struct_id =>  l_g_loc_struct
                            ,ccid => C_Mhca_Book_Info_Rec.location_id
                            ,concat_string => l_concat_loc
                            ,segarray => l_loc_segs); */

                    -- This gets the CONCATENATED CATEGORY NAME
                    fa_rx_shared_pkg.concat_category (
                           struct_id       => l_g_cat_struct,
                           ccid            => l_asset_cat_id,
                           concat_string   => l_concat_cat,
                           segarray        => l_cat_segs);


                    -- This will get the CONCATANATED ASSETKEY
                    /* mh, commenting out as conactenated asset key not in ITF table
                    fa_rx_shared_pkg.concat_asset_key (
                            struct_id => l_g_asset_key_struct
                            ,ccid => l_asset_cat_id
                            ,concat_string => l_concat_asset_key
                            ,segarray => l_asset_segs); */

                    -- bug 3442275, start 3
                    -- process only if asset has been registered as IAC Book
                    IF (l_iac_reval_period_num > 0) THEN

                       -- get the period information for the asset DPIS
                       l_ret:= igi_iac_common_utils.get_period_info_for_date(C_Mhca_Book_Info_Rec.book_type_code,
                                                                             C_Mhca_Book_Info_Rec.date_placed_in_service,
                                                                             l_dpis_period);

                       -- get the DPIS period counter
                       l_dpis_prd_counter := l_dpis_period.period_counter;

                       IF (l_dpis_prd_counter > l_reval_prd_counter AND
                              l_dpis_prd_counter <= l_curr_prd_counter) THEN

                           -- list the asset as an exception
                           FND_MESSAGE.SET_Name ('IGI', 'IGI_IMP_DPIS_REVAL_EXCEPTION');
                           igi_iac_debug_pkg.debug_other_msg(g_state_level,l_path,FALSE);
                           l_message := Fnd_message.get;

                           INSERT INTO IGI_IMP_IAC_EXCEP_REP_ITF (
                                request_id,
                                sob_book,
                                organisation_name,
                                corp_book,
                                tax_book,
                                PERIOD ,
                                FISCAL_YEAR_NAME ,
                                warning_message ,
                                warning_message_code ,
                                ASSET_NUMBER,
                                ASSET_DESCRIPTION ,
                                FUNCTIONAL_CURRENCY_CODE,
                                DPIS_CORP,
                                DPIS_TAX   ,
                                ASSET_LIFE_CORP ,
                                ASSET_LIFE_TAX    ,
                                CONCAT_CATEGORY ,
                                HIST_COST_CORP ,
                                HIST_COST_TAX  ,
                                SALVAGE_VALUE_CORP ,
                                SALVAGE_VALUE_TAX )
                           VALUES (
                                p_request_id,
                                l_sob_name,
                                l_company_name,
                                C_Corp_Book_Info_Rec.book_type_code,
                                C_Tax_Book_Info_Rec.book_type_code,
                                l_period_name,
                                l_fiscal_year_name,
                                l_message,
                                'P',
                                C_Mhca_Book_Info_Rec.asset_number,
                                C_Mhca_Book_Info_Rec.description,
                                l_currency_code,
                                C_Corp_Book_Info_Rec.date_placed_in_service,
                                C_Mhca_Book_Info_Rec.date_placed_in_service,
                                C_Corp_Book_Info_Rec.life_in_months,
                                C_Mhca_Book_Info_Rec.life_in_months ,
                                l_concat_cat,
                                C_Corp_Book_Info_Rec.original_cost,
                                C_Mhca_Book_Info_Rec.original_cost ,
                                C_Corp_Book_Info_Rec.salvage_value,
                                C_Mhca_Book_Info_Rec.salvage_value );

                           l_initial_flag := 'Y';
                        END IF;
                    END IF; -- registered as IAC book
                    -- bug 3442275, 3nd 3

                    IF  l_initial_flag ='N'   then
                       If C_Mhca_Book_Info_Rec.period_counter_fully_retired is not null then
                           FND_MESSAGE.SET_Name ('IGI', 'IGI_IMP_FULLY_RETRIED');
                           igi_iac_debug_pkg.debug_other_msg(g_state_level,l_path,FALSE);
                           l_message := Fnd_message.get;

                           insert into IGI_IMP_IAC_EXCEP_REP_ITF (
                                request_id,
                                sob_book,
                                organisation_name,
                                corp_book,
                                tax_book,
                                PERIOD ,
                                FISCAL_YEAR_NAME ,
                                warning_message ,
                                warning_message_code ,
                                ASSET_NUMBER,
                                ASSET_DESCRIPTION ,
                                FUNCTIONAL_CURRENCY_CODE,
                                DPIS_CORP,
                                DPIS_TAX   ,
                                ASSET_LIFE_CORP ,
                                ASSET_LIFE_TAX    ,
                                CONCAT_CATEGORY ,
                                HIST_COST_CORP ,
                                HIST_COST_TAX  ,
                                SALVAGE_VALUE_CORP ,
                                SALVAGE_VALUE_TAX )
                           values (
                                p_request_id,
                                l_sob_name,
                                l_company_name,
                                C_Corp_Book_Info_Rec.book_type_code,
                                C_Tax_Book_Info_Rec.book_type_code,
                                l_period_name,
                                l_fiscal_year_name,
                                l_message,
                                'K',
                                C_Mhca_Book_Info_Rec.asset_number,
                                C_Mhca_Book_Info_Rec.description,
                                l_currency_code,
                                C_Corp_Book_Info_Rec.date_placed_in_service,
                                C_Mhca_Book_Info_Rec.date_placed_in_service,
                                C_Corp_Book_Info_Rec.life_in_months,
                                C_Mhca_Book_Info_Rec.life_in_months ,
                                l_concat_cat,
                                C_Corp_Book_Info_Rec.original_cost,
                                C_Mhca_Book_Info_Rec.original_cost ,
                                C_Corp_Book_Info_Rec.salvage_value,
                                C_Mhca_Book_Info_Rec.salvage_value );

                             l_initial_flag := 'Y';
		               End if;
                    END IF;

                    IF  l_initial_flag ='N'   then
                        If sign(C_Mhca_Book_Info_Rec.cost) = -1 then
                            FND_MESSAGE.SET_Name ('IGI', 'IGI_IMP_NEGATIVE_COST');
                            igi_iac_debug_pkg.debug_other_msg(g_state_level,l_path,FALSE);
                            l_message := Fnd_message.get;

                            insert into IGI_IMP_IAC_EXCEP_REP_ITF (
                                                request_id,
                                                sob_book,
                                                organisation_name,
                                                corp_book,
                                                tax_book,
			                        PERIOD,
			                        FISCAL_YEAR_NAME,
			                        warning_message  ,
			                        warning_message_code ,
			                        ASSET_NUMBER,
			                        ASSET_DESCRIPTION ,
			                        FUNCTIONAL_CURRENCY_CODE,
			                        DPIS_CORP   ,
			                        DPIS_TAX   ,
			                        ASSET_LIFE_CORP  ,
			                        ASSET_LIFE_TAX ,
			                        CONCAT_CATEGORY ,
			                        HIST_COST_CORP ,
			                        HIST_COST_TAX   ,
			                        SALVAGE_VALUE_CORP ,
			                        SALVAGE_VALUE_TAX)
			                values
			                       (p_request_id,
                                                l_sob_name,
                                                l_company_name,
                                                C_Corp_Book_Info_Rec.book_type_code,
			                        C_Tax_Book_Info_Rec.book_type_code,
			                        l_period_name,
			                        l_fiscal_year_name,
			                        l_message,
			                        'M',
			                        C_Mhca_Book_Info_Rec.asset_number,
			                        C_Mhca_Book_Info_Rec.description,
			                        l_currency_code,
			                        C_Corp_Book_Info_Rec.date_placed_in_service,
			                        C_Mhca_Book_Info_Rec.date_placed_in_service,
			                        C_Corp_Book_Info_Rec.life_in_months,
			                        C_Mhca_Book_Info_Rec.life_in_months,
			                        l_concat_cat,
			                        C_Corp_Book_Info_Rec.original_cost,
			                        C_Mhca_Book_Info_Rec.original_cost,
			                        C_Corp_Book_Info_Rec.salvage_value,
			                        C_Mhca_Book_Info_Rec.salvage_value );
		                    l_initial_flag := 'Y';

                        End if;
                    End if;

                    IF  l_initial_flag ='N'   then
                        If (C_Corp_Book_Info_Rec.life_in_months - C_Mhca_Book_Info_Rec.life_in_months )<> 0 then
                            FND_MESSAGE.SET_Name ('IGI', 'IGI_IMP_ASSET_LIFE');
                            igi_iac_debug_pkg.debug_other_msg(g_state_level,l_path,FALSE);
                            l_message := Fnd_message.get;

                            insert into IGI_IMP_IAC_EXCEP_REP_ITF (
                                                    request_id,
                                                    sob_book,
                                                    organisation_name,
                                                    corp_book,
                                                    tax_book,
			                            PERIOD,
			                            FISCAL_YEAR_NAME,
			                            warning_message  ,
			                            warning_message_code ,
			                            ASSET_NUMBER,
			                            ASSET_DESCRIPTION ,
			                            FUNCTIONAL_CURRENCY_CODE,
			                            DPIS_CORP   ,
			                            DPIS_TAX   ,
			                            ASSET_LIFE_CORP  ,
			                            ASSET_LIFE_TAX ,
			                            CONCAT_CATEGORY ,
			                            HIST_COST_CORP ,
			                            HIST_COST_TAX   ,
			                            SALVAGE_VALUE_CORP ,
			                            SALVAGE_VALUE_TAX)
			                values
			                           (p_request_id,
                                                    l_sob_name,
                                                    l_company_name,
                                                    C_Corp_Book_Info_Rec.book_type_code,
			                            C_Tax_Book_Info_Rec.book_type_code,
			                            l_period_name,
			                            l_fiscal_year_name,
			                            l_message,
			                            'L',
			                            C_Mhca_Book_Info_Rec.asset_number,
			                            C_Mhca_Book_Info_Rec.description,
			                            l_currency_code, -- mh, l_concat_cat,
			                            C_Corp_Book_Info_Rec.date_placed_in_service,
			                            C_Mhca_Book_Info_Rec.date_placed_in_service,
			                            C_Corp_Book_Info_Rec.life_in_months,
			                            C_Mhca_Book_Info_Rec.life_in_months,
			                            l_concat_cat, -- mh, l_concat_loc,
			                            C_Corp_Book_Info_Rec.original_cost,
			                            C_Mhca_Book_Info_Rec.original_cost,
			                            C_Corp_Book_Info_Rec.salvage_value,
			                            C_Mhca_Book_Info_Rec.salvage_value );
                            l_initial_flag := 'Y';

		                End if;
            	    End if;

                    IF  l_initial_flag ='N'   then
                        If trunc(C_Mhca_Book_Info_Rec.date_placed_in_service) <> trunc(C_Corp_Book_Info_Rec.date_placed_in_service)then
                            FND_MESSAGE.SET_Name ('IGI', 'IGI_IMP_ASSET_DPIS');
                            igi_iac_debug_pkg.debug_other_msg(g_state_level,l_path,FALSE);
                            l_message := Fnd_message.get;

                            insert into IGI_IMP_IAC_EXCEP_REP_ITF (
                                                    request_id,
                                                    sob_book,
                                                    organisation_name,
                                                    corp_book,
                                                    tax_book,
			                            PERIOD,
			                            FISCAL_YEAR_NAME,
			                            warning_message  ,
			                            warning_message_code ,
			                            ASSET_NUMBER,
			                            ASSET_DESCRIPTION ,
			                            FUNCTIONAL_CURRENCY_CODE,
			                            DPIS_CORP   ,
			                            DPIS_TAX   ,
			                            ASSET_LIFE_CORP  ,
			                            ASSET_LIFE_TAX ,
			                            CONCAT_CATEGORY ,
			                            HIST_COST_CORP ,
			                            HIST_COST_TAX   ,
			                            SALVAGE_VALUE_CORP ,
			                            SALVAGE_VALUE_TAX)
			                values
			                           (p_request_id,
                                                    l_sob_name,
                                                    l_company_name,
                                                    C_Corp_Book_Info_Rec.book_type_code,
                                                    C_Tax_Book_Info_Rec.book_type_code,
			                            l_period_name,
			                            l_fiscal_year_name,
			                            l_message,
			                            'D',
			                            C_Mhca_Book_Info_Rec.asset_number,
			                            C_Mhca_Book_Info_Rec.description,
			                            l_currency_code,
			                            C_Corp_Book_Info_Rec.date_placed_in_service,
			                            C_Mhca_Book_Info_Rec.date_placed_in_service,
			                            C_Corp_Book_Info_Rec.life_in_months,
			                            C_Mhca_Book_Info_Rec.life_in_months,
			                            l_concat_cat,
			                            C_Corp_Book_Info_Rec.original_cost,
			                            C_Mhca_Book_Info_Rec.original_cost,
			                            C_Corp_Book_Info_Rec.salvage_value,
			                            C_Mhca_Book_Info_Rec.salvage_value);
                            l_initial_flag := 'Y';

                        End if;
                    End if;

                    IF l_initial_flag ='N'   then
                        If (C_Mhca_Book_Info_Rec.salvage_value - C_Corp_Book_Info_Rec.salvage_value) <> 0 then
                            FND_MESSAGE.SET_Name ('IGI', 'IGI_IMP_ASSET_SALVAGE');
                            igi_iac_debug_pkg.debug_other_msg(g_state_level,l_path,FALSE);
                            l_message := Fnd_message.get;

                            insert into IGI_IMP_IAC_EXCEP_REP_ITF (
                                        request_id,
                                        sob_book,
                                        organisation_name,
                                        corp_book,
                                        tax_book,
                                        PERIOD,
                                        FISCAL_YEAR_NAME,
                                        warning_message  ,
                                        warning_message_code ,
                                        ASSET_NUMBER,
                                        ASSET_DESCRIPTION ,
                                        FUNCTIONAL_CURRENCY_CODE,
                                        DPIS_CORP   ,
                                        DPIS_TAX   ,
                                        ASSET_LIFE_CORP  ,
                                        ASSET_LIFE_TAX ,
                                        CONCAT_CATEGORY ,
                                        HIST_COST_CORP ,
                                        HIST_COST_TAX   ,
                                        SALVAGE_VALUE_CORP ,
                                        SALVAGE_VALUE_TAX)
                            values
                                        (p_request_id,
                                        l_sob_name,
                                        l_company_name,
                                        C_Corp_Book_Info_Rec.book_type_code,
                                        C_Tax_Book_Info_Rec.book_type_code,
                                        l_period_name,
                                        l_fiscal_year_name,
                                        l_message,
                                        'S',
                                        C_Mhca_Book_Info_Rec.asset_number,
                                        C_Mhca_Book_Info_Rec.description,
                                        l_currency_code,
                                        C_Corp_Book_Info_Rec.date_placed_in_service,
                                        C_Mhca_Book_Info_Rec.date_placed_in_service,
                                        C_Corp_Book_Info_Rec.life_in_months,
                                        C_Mhca_Book_Info_Rec.life_in_months,
                                        l_concat_cat,
                                        C_Corp_Book_Info_Rec.original_cost,
                                        C_Mhca_Book_Info_Rec.original_cost,
                                        C_Corp_Book_Info_Rec.salvage_value,
                                        C_Mhca_Book_Info_Rec.salvage_value );
                            l_initial_flag := 'Y';
                        End if;
                    End if;

                    IF  l_initial_flag ='N'   then
                        -- bug 3464589, start 1
                        -- bug 3451572, start 1
                        -- If (C_Mhca_Book_Info_Rec.depreciate_flag ='N'
                        IF (C_Corp_Book_Info_Rec.depreciate_flag ='NO' OR
                              C_Mhca_Book_Info_Rec.depreciate_flag = 'NO') THEN
                        -- bug 3451572, end 1
                            IF  (nvl(C_Mhca_Book_Info_Rec.deprn_reserve,0) <> 0
                                  OR nvl(C_Mhca_Book_Info_Rec.ytd_deprn,0) <> 0
                                    OR nvl(c_corp_book_info_rec.deprn_reserve,0) <> 0
                                      OR nvl(c_corp_book_info_rec.ytd_deprn,0) <> 0) THEN
                         -- bug 3464589, end 1

                            FND_MESSAGE.SET_Name ('IGI', 'IGI_IMP_NONDEPRN_ASSET');
                            igi_iac_debug_pkg.debug_other_msg(g_state_level,l_path,FALSE);
                            l_message := Fnd_message.get;

                            INSERT INTO IGI_IMP_IAC_EXCEP_REP_ITF (
                                        request_id,
                                        sob_book,
                                        organisation_name,
                                        corp_book,
                                        tax_book,
                                        PERIOD,
                                        FISCAL_YEAR_NAME,
                                        warning_message  ,
                                        warning_message_code ,
                                        ASSET_NUMBER,
                                        ASSET_DESCRIPTION ,
                                        FUNCTIONAL_CURRENCY_CODE,
                                        DPIS_CORP   ,
                                        DPIS_TAX   ,
                                        ASSET_LIFE_CORP  ,
                                        ASSET_LIFE_TAX ,
                                        CONCAT_CATEGORY ,
                                        HIST_COST_CORP ,
                                        HIST_COST_TAX   ,
                                        SALVAGE_VALUE_CORP ,
                                        SALVAGE_VALUE_TAX)
                            VALUES
                                        (p_request_id,
                                        l_sob_name,
                                        l_company_name,
                                        C_Corp_Book_Info_Rec.book_type_code,
                                        C_Tax_Book_Info_Rec.book_type_code,
                                        l_period_name,
                                        l_fiscal_year_name,
                                        l_message,
                                        'L',
                                        C_Mhca_Book_Info_Rec.asset_number,
                                        C_Mhca_Book_Info_Rec.description,
                                        l_currency_code,
                                        C_Corp_Book_Info_Rec.date_placed_in_service,
                                        C_Mhca_Book_Info_Rec.date_placed_in_service,
                                        C_Corp_Book_Info_Rec.life_in_months,
                                        C_Mhca_Book_Info_Rec.life_in_months,
                                        l_concat_cat,
                                        C_Corp_Book_Info_Rec.original_cost,
                                        C_Mhca_Book_Info_Rec.original_cost,
                                        C_Corp_Book_Info_Rec.salvage_value,
                                        C_Mhca_Book_Info_Rec.salvage_value);
                            l_initial_flag := 'Y';

                        END IF; -- check depreciation amounts
                      -- bug 3464589, start 2
                      END IF; -- check depreciate flag
                      -- bug 3464589, end 2
                    END IF;

                    For C_Mhca_Reval_Summary_Info_Rec In C_Mhca_Reval_Summary_Info(C_Tax_Book_Info_Rec.book_type_code, C_Corp_Book_Info_Rec.asset_id ) Loop

                        IF  l_initial_flag ='N'   then
                            If (abs((nvl(C_Mhca_Reval_Summary_Info_Rec.new_asset_cost,0) - nvl(C_Mhca_Reval_Summary_Info_Rec.new_reval_reserve,0))
                                - C_Corp_Book_Info_Rec.cost )  > 0.05 ) then

                                FND_MESSAGE.SET_Name ('IGI', 'IGI_IMP_ASSET_COST');
                                igi_iac_debug_pkg.debug_other_msg(g_state_level,l_path,FALSE);
                                l_message := Fnd_message.get;

                                insert into IGI_IMP_IAC_EXCEP_REP_ITF (
                                            request_id,
                                            sob_book,
                                            organisation_name,
                                            corp_book,
                                            tax_book,
                                            PERIOD,
                                            FISCAL_YEAR_NAME,
                                            warning_message  ,
                                            warning_message_code ,
                                            ASSET_NUMBER,
                                            ASSET_DESCRIPTION ,
                                            FUNCTIONAL_CURRENCY_CODE,
                                            DPIS_CORP   ,
                                            DPIS_TAX   ,
                                            ASSET_LIFE_CORP  ,
                                            ASSET_LIFE_TAX ,
                                            CONCAT_CATEGORY ,
                                            HIST_COST_CORP ,
                                            HIST_COST_TAX   ,
                                            SALVAGE_VALUE_CORP ,
                                            SALVAGE_VALUE_TAX)
                                values
                                            (p_request_id,
                                            l_sob_name,
                                            l_company_name,
                                            C_Corp_Book_Info_Rec.book_type_code,
                                            C_Tax_Book_Info_Rec.book_type_code,
                                            l_period_name,
                                            l_fiscal_year_name,
                                            l_message,
                                            'L',
                                            C_Mhca_Book_Info_Rec.asset_number,
                                            C_Mhca_Book_Info_Rec.description,
                                            l_currency_code,
                                            C_Corp_Book_Info_Rec.date_placed_in_service,
                                            C_Mhca_Book_Info_Rec.date_placed_in_service,
                                            C_Corp_Book_Info_Rec.life_in_months,
                                            C_Mhca_Book_Info_Rec.life_in_months,
                                            l_concat_cat,
                                            C_Corp_Book_Info_Rec.original_cost,
                                            C_Mhca_Book_Info_Rec.original_cost,
                                            C_Corp_Book_Info_Rec.salvage_value,
                                            C_Mhca_Book_Info_Rec.salvage_value);
                                l_initial_flag := 'Y';

                            End if;
                        End if;
                    End Loop; -- end Mhca Reval Summary loop
                End Loop; -- MHca Book Info loop end
            End Loop; -- Tax Book Info loop end

            -- bug 3442275, start 4
            -- process only if asset has been registered as IAC Book
            IF  l_initial_flag ='N'   THEN
               IF (l_iac_reval_period_num > 0) THEN

                  -- get the period information for the asset DPIS
                  l_ret := igi_iac_common_utils.get_period_info_for_date(C_Corp_Book_Info_Rec.book_type_code,
                                                                         C_Corp_Book_Info_Rec.date_placed_in_service,
                                                                         l_dpis_period);

                  -- get the DPIS period counter
                  l_dpis_prd_counter := l_dpis_period.period_counter;

                  IF (l_dpis_prd_counter > l_reval_prd_counter AND
                           l_dpis_prd_counter <= l_curr_prd_counter) THEN

                         -- list the asset as an exception
                        FND_MESSAGE.SET_Name ('IGI', 'IGI_IMP_DPIS_REVAL_EXCEPTION');
                        igi_iac_debug_pkg.debug_other_msg(g_state_level,l_path,TRUE);
                        l_message := Fnd_message.get;

                        INSERT INTO IGI_IMP_IAC_EXCEP_REP_ITF (
                                request_id,
                                sob_book,
                                organisation_name,
                                corp_book,
                                tax_book,
                                PERIOD ,
                                FISCAL_YEAR_NAME ,
                                warning_message ,
                                warning_message_code ,
                                ASSET_NUMBER,
                                ASSET_DESCRIPTION ,
                                FUNCTIONAL_CURRENCY_CODE,
                                DPIS_CORP,
                                DPIS_TAX   ,
                                ASSET_LIFE_CORP ,
                                ASSET_LIFE_TAX    ,
                                CONCAT_CATEGORY ,
                                HIST_COST_CORP ,
                                HIST_COST_TAX  ,
                                SALVAGE_VALUE_CORP ,
                                SALVAGE_VALUE_TAX )
                        VALUES (
                                p_request_id,
                                l_sob_name,
                                l_company_name,
                                C_Corp_Book_Info_Rec.book_type_code,
                                NULL,
                                l_period_name,
                                l_fiscal_year_name,
                                l_message,
                                'P',
                                C_Corp_Book_Info_Rec.asset_number,
                                C_Corp_Book_Info_Rec.description,
                                l_currency_code,
                                C_Corp_Book_Info_Rec.date_placed_in_service,
                                NULL,
                                C_Corp_Book_Info_Rec.life_in_months,
                                NULL,
                                l_concat_cat,
                                C_Corp_Book_Info_Rec.original_cost,
                                NULL,
                                C_Corp_Book_Info_Rec.salvage_value,
                                NULL);

                       l_initial_flag := 'Y';
                   END IF;
               END IF; -- process if IAC Book only
            END IF; -- l_initial_flag
            -- bug 3442275, end 4


            -- bug 3476361, start 1
            IF  l_initial_flag ='N'   THEN
            -- bug 3476361, end 1
               If C_Corp_Book_Info_Rec.period_counter_fully_retired is not null then
                   FND_MESSAGE.SET_Name ('IGI', 'IGI_IMP_FULLY_RETRIED');
                   igi_iac_debug_pkg.debug_other_msg(g_state_level,l_path,FALSE);
                   l_message := Fnd_message.get;

                   insert into IGI_IMP_IAC_EXCEP_REP_ITF (
                                 request_id,
                                 sob_book,
                                 organisation_name,
                                 corp_book,
                                 tax_book,
			          PERIOD ,
			          FISCAL_YEAR_NAME ,
			          warning_message  ,
			          warning_message_code ,
			          ASSET_NUMBER,
			          ASSET_DESCRIPTION ,
			          FUNCTIONAL_CURRENCY_CODE,
			          DPIS_CORP,
			          DPIS_TAX   ,
			          ASSET_LIFE_CORP ,
			          ASSET_LIFE_TAX    ,
			          CONCAT_CATEGORY ,
			          HIST_COST_CORP ,
			          HIST_COST_TAX  ,
			          SALVAGE_VALUE_CORP ,
			          SALVAGE_VALUE_TAX )
                   values
                                (p_request_id,
                                 l_sob_name,
                                 l_company_name,
                                 C_Corp_Book_Info_Rec.book_type_code,
			         NULL,
			         l_period_name,
			         l_fiscal_year_name,
			         l_message,
			         'K',
			          C_Corp_Book_Info_Rec.asset_number,
			          C_Corp_Book_Info_Rec.description,
			          l_currency_code,
			          C_Corp_Book_Info_Rec.date_placed_in_service,
			          NULL,
			          C_Corp_Book_Info_Rec.life_in_months  ,
			          NULL ,
			          l_concat_cat, -- l_concat_loc,
			          C_Corp_Book_Info_Rec.original_cost,
			          NULL ,
			          C_Corp_Book_Info_Rec.salvage_value,
			          NULL);
                    l_initial_flag := 'Y';

               End if;
            -- bug 3476361, start 2
            END IF;
            -- bug 3476361, end 2

            IF  l_initial_flag ='N'   then
                If sign(C_Corp_Book_Info_Rec.cost) = -1 then
                        FND_MESSAGE.SET_Name ('IGI', 'IGI_IMP_NEGATIVE_COST');
                        igi_iac_debug_pkg.debug_other_msg(g_state_level,l_path,FALSE);
                        l_message := Fnd_message.get;


                        insert into IGI_IMP_IAC_EXCEP_REP_ITF (
                                request_id,
                                sob_book,
                                organisation_name,
                                corp_book,
                                tax_book,
                                PERIOD,
                                FISCAL_YEAR_NAME,
                                warning_message  ,
                                warning_message_code ,
                                ASSET_NUMBER,
                                ASSET_DESCRIPTION ,
                                FUNCTIONAL_CURRENCY_CODE,
                                DPIS_CORP   ,
                                DPIS_TAX   ,
                                ASSET_LIFE_CORP  ,
                                ASSET_LIFE_TAX ,
                                CONCAT_CATEGORY ,
                                HIST_COST_CORP ,
                                HIST_COST_TAX   ,
                                SALVAGE_VALUE_CORP ,
                                SALVAGE_VALUE_TAX)
                        values
                                (p_request_id,
                                l_sob_name,
                                l_company_name,
                                C_Corp_Book_Info_Rec.book_type_code,
                                null,
                                l_period_name,
                                l_fiscal_year_name,
                                l_message,
                                'M',
                                C_Corp_Book_Info_Rec.asset_number,
                                C_Corp_Book_Info_Rec.description,
                                l_currency_code,
                                C_Corp_Book_Info_Rec.date_placed_in_service,
                                NULL,
                                C_Corp_Book_Info_Rec.life_in_months,
                                NULL,
                                l_concat_cat,
                                C_Corp_Book_Info_Rec.original_cost,
                                NULL,
                                C_Corp_Book_Info_Rec.salvage_value,
                                NULL);
                        l_initial_flag := 'Y';

                End if;
            End if;

            -- bug 3476361, start 3
            -- for non depreciating assets
            IF  l_initial_flag ='N'   THEN

                IF (C_Corp_Book_Info_Rec.depreciate_flag ='NO') THEN
                    IF (nvl(c_corp_book_info_rec.deprn_reserve,0) <> 0
                         OR nvl(c_corp_book_info_rec.ytd_deprn,0) <> 0) THEN


                            FND_MESSAGE.SET_NAME ('IGI', 'IGI_IMP_NONDEPRN_ASSET');
                            igi_iac_debug_pkg.debug_other_msg(g_state_level,l_path,FALSE);
                            l_message := Fnd_message.get;


                            INSERT INTO IGI_IMP_IAC_EXCEP_REP_ITF (
                                        request_id,
                                        sob_book,
                                        organisation_name,
                                        corp_book,
                                        tax_book,
                                        PERIOD,
                                        FISCAL_YEAR_NAME,
                                        warning_message  ,
                                        warning_message_code ,
                                        ASSET_NUMBER,
                                        ASSET_DESCRIPTION ,
                                        FUNCTIONAL_CURRENCY_CODE,
                                        DPIS_CORP   ,
                                        DPIS_TAX   ,
                                        ASSET_LIFE_CORP  ,
                                        ASSET_LIFE_TAX ,
                                        CONCAT_CATEGORY ,
                                        HIST_COST_CORP ,
                                        HIST_COST_TAX   ,
                                        SALVAGE_VALUE_CORP ,
                                        SALVAGE_VALUE_TAX)
                            VALUES
                                        (p_request_id,
                                        l_sob_name,
                                        l_company_name,
                                        C_Corp_Book_Info_Rec.book_type_code,
                                        null,
                                        l_period_name,
                                        l_fiscal_year_name,
                                        l_message,
                                        'L',
                                        C_Corp_Book_Info_Rec.asset_number,
                                        C_Corp_Book_Info_Rec.description,
                                        l_currency_code,
                                        C_Corp_Book_Info_Rec.date_placed_in_service,
                                        null,
                                        C_Corp_Book_Info_Rec.life_in_months,
                                        null,
                                        l_concat_cat,
                                        C_Corp_Book_Info_Rec.original_cost,
                                        null,
                                        C_Corp_Book_Info_Rec.salvage_value,
                                        null);
                            l_initial_flag := 'Y';

                     END IF; -- check depreciation amounts
                END IF; -- check depreciate flag
            END IF;

            -- bug 3476361, end 3
        End Loop; -- end Corp Book loop
    EXCEPTION
      WHEN OTHERS THEN
        p_errbuf := sqlerrm;
        p_retcode := 2;
    END run_report;

END IGI_IMP_IAC_EXCEP_INER_PKG ; -- Package Body

/
