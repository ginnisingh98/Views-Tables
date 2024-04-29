--------------------------------------------------------
--  DDL for Package Body IGI_IAC_RXI_I_WRAP_ASSET_BAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_RXI_I_WRAP_ASSET_BAL" AS
/* $Header: igiiaxcb.pls 120.1.12000000.1 2007/08/01 16:20:09 npandya noship $ */

    --===========================FND_LOG.START=====================================
    g_state_level NUMBER;
    g_proc_level  NUMBER;
    g_event_level NUMBER;
    g_excep_level NUMBER;
    g_error_level NUMBER;
    g_unexp_level NUMBER;
    g_path        VARCHAR2(100);
    --===========================FND_LOG.END=======================================

    /****** Start Forward Declarations *****/

    FUNCTION get_flex_segments (p_bookType IN VARCHAR2 )
    RETURN BOOLEAN;

    FUNCTION get_period_name (p_bookType		IN	VARCHAR2
                            ,p_period		IN	VARCHAR2)
    RETURN BOOLEAN;

    FUNCTION run_s_deprec_report  ( p_bookType	IN	VARCHAR2
				,p_period	IN	VARCHAR2
				,p_categoryId	IN	VARCHAR2
				,p_request_id	IN	NUMBER
				,l_user_id	IN	NUMBER
				,p_login_id	IN	VARCHAR2)
    RETURN BOOLEAN;

    FUNCTION run_d_deprec_report  ( p_bookType	IN	VARCHAR2
				,p_period	IN	VARCHAR2
				,p_categoryId	IN	VARCHAR2
				,p_from_cc	IN	VARCHAR2
				,p_to_cc	IN	VARCHAR2
				,p_from_asset	IN	VARCHAR2
				,p_to_asset	IN	VARCHAR2
				,p_request_id	IN	NUMBER
				,l_user_id	IN	NUMBER
				,p_login_id	IN	VARCHAR2)
    RETURN BOOLEAN;

    FUNCTION run_s_operating_report( p_bookType	IN	VARCHAR2
				,p_period	IN	VARCHAR2
				,p_categoryId	IN	VARCHAR2
				,p_request_id	IN	NUMBER
				,l_user_id	IN	NUMBER
				,p_login_id	IN	VARCHAR2)
    RETURN BOOLEAN;

    FUNCTION run_d_operating_report( p_bookType	IN	VARCHAR2
				,p_period	IN	VARCHAR2
				,p_categoryId	IN	VARCHAR2
				,p_from_cc	IN	VARCHAR2
				,p_to_cc	IN	VARCHAR2
				,p_from_asset	IN	VARCHAR2
				,p_to_asset	IN	VARCHAR2
				,p_request_id	IN	NUMBER
				,l_user_id	IN	NUMBER
				,p_login_id	IN	VARCHAR2)
    RETURN BOOLEAN;

    FUNCTION run_s_reval_report    ( p_bookType	IN	VARCHAR2
				,p_period	IN	VARCHAR2
				,p_categoryId	IN	VARCHAR2
				,p_request_id	IN	NUMBER
				,l_user_id	IN	NUMBER
				,p_login_id	IN	VARCHAR2)
    RETURN BOOLEAN;

    FUNCTION run_d_reval_report    ( p_bookType	IN	VARCHAR2
				,p_period	IN	VARCHAR2
				,p_categoryId	IN	VARCHAR2
				,p_from_cc	IN	VARCHAR2
				,p_to_cc	IN	VARCHAR2
				,p_from_asset	IN	VARCHAR2
				,p_to_asset	IN	VARCHAR2
				,p_request_id	IN	NUMBER
				,l_user_id	IN	NUMBER
				,p_login_id	IN	VARCHAR2)
    RETURN BOOLEAN;

    FUNCTION run_s_summary_report  ( p_bookType	IN	VARCHAR2
				,p_period	IN	VARCHAR2
				,p_categoryId	IN	VARCHAR2
				,p_request_id	IN	NUMBER
				,l_user_id	IN	NUMBER
				,p_login_id	IN	VARCHAR2)
    RETURN BOOLEAN;

    FUNCTION run_d_summary_report  ( p_bookType	IN	VARCHAR2
				,p_period	IN	VARCHAR2
				,p_categoryId	IN	VARCHAR2
				,p_from_cc	IN	VARCHAR2
				,p_to_cc	IN	VARCHAR2
				,p_from_asset	IN	VARCHAR2
				,p_to_asset	IN	VARCHAR2
				,p_request_id	IN	NUMBER
				,l_user_id	IN	NUMBER
				,p_login_id	IN	VARCHAR2)
    RETURN BOOLEAN;

    FUNCTION get_acct_seg_values ( p_bookType		IN	VARCHAR2
            ,p_categoryId		IN	NUMBER
            ,p_deprn_res_acct	IN OUT	NOCOPY fa_category_books.deprn_reserve_acct%TYPE
            ,p_deprn_exp_acct	IN OUT	NOCOPY fa_category_books.deprn_expense_acct%TYPE)
    RETURN BOOLEAN;

    FUNCTION get_acct_seg_val_from_ccid ( p_bookType		IN	VARCHAR2
					,p_categoryId		IN	NUMBER
					,p_deprn_backlog	IN OUT	NOCOPY VARCHAR2
					,p_gen_fund_acct	IN OUT	NOCOPY VARCHAR2
					,p_oper_exp_acct	IN OUT  NOCOPY VARCHAR2
					,p_reval_rsv_acct	IN OUT  NOCOPY VARCHAR2)
    RETURN BOOLEAN;

    FUNCTION Delete_Zero_Rows(p_bookType  IN  VARCHAR2,
                            p_request_id    IN  NUMBER,
                            p_reptShrtName  IN  VARCHAR2)
    RETURN BOOLEAN;
    /****** End Forward Declarations *****/

    /****** Start of local Global variables ******/
    l_g_loc_struct	NUMBER;
    l_g_asset_key_struct	NUMBER;
    l_g_cat_struct	NUMBER;

    balancing_seg_no  VARCHAR2(50);
    cost_ctr_seg_no   VARCHAR2(50);
    account_seg_no    VARCHAR2(50);
    major_cat_seg_no  VARCHAR2(50);
    minor_cat_seg_no  VARCHAR2(50);

    l_company_name	VARCHAR2(30);
    l_fiscal_year_name	VARCHAR2(30);
    l_currency_code       VARCHAR2(15);
    l_period_name		VARCHAR2(15);
    l_fiscal_year     NUMBER(4);
    /****** End of local Global variables *****/

    PROCEDURE run_report ( p_reptShrtName 	IN	VARCHAR2
			,p_bookType		IN	VARCHAR2
			,p_period		IN	VARCHAR2
			,p_categoryId		IN	VARCHAR2
			,p_chartOfAccts		IN	VARCHAR2 DEFAULT NULL
			,p_from_cc		IN	VARCHAR2 DEFAULT NULL
			,p_to_cc		IN	VARCHAR2 DEFAULT NULL
			,p_from_asset_num	IN	VARCHAR2 DEFAULT NULL
			,p_to_asset_num		IN	VARCHAR2 DEFAULT NULL
			,p_request_id		IN	NUMBER
			,p_retcode		OUT NOCOPY NUMBER
			,p_errbuf		OUT NOCOPY VARCHAR2)
    IS

    l_login_id            NUMBER;
    l_user_id		NUMBER;
    l_finalCategoryId	VARCHAR(50);
    l_from_cc		VARCHAR2(25);
    l_to_cc		VARCHAR2(25);
    l_from_asset		VARCHAR2(25);
    l_to_asset		VARCHAR2(25);
    l_path 		VARCHAR2(150);

    CURSOR c_get_fiscal_year IS
    SELECT fiscal_year
    FROM fa_deprn_periods
    WHERE book_type_code = p_bookType
    AND period_counter = p_period;

    BEGIN

        l_path 		:= g_path||'run_report';

        -- Enable this for write to log file when testing or debug!!
        --fa_rx_util_pkg.enable_debug; -- Does not now follow debug standards!!!
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_reptShrtName' || p_reptShrtName);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_bookType' || p_bookType);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_period ' || p_period);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_categoryId' || p_categoryId);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_chartOfAccts' || p_chartOfAccts);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_from_cc' || p_from_cc);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_to_cc' || p_to_cc);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_from_asset_num' || p_from_asset_num);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_to_asset_num ' || p_to_asset_num);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_request_id' || p_request_id);

        l_login_id := NVL(to_number(fnd_profile.value('LOGIN_ID')),-1);
        l_user_id  := NVL(to_number(fnd_profile.value('USER_ID' )),-1);

        IF get_flex_segments (p_bookType) AND get_period_name (p_bookType, p_period) THEN
            IF p_categoryId IS NULL THEN
                l_finalCategoryId := 'cf.category_id'; -- Do all categories
            ELSE
                l_finalCategoryId := p_categoryId;
            END IF;

            OPEN c_get_fiscal_year;
            FETCH c_get_fiscal_year INTO l_fiscal_year;
            CLOSE c_get_fiscal_year;

            -- Ensure correct value is passed variable cursor, otherwise query will fail
            IF p_from_cc IS NULL THEN
                l_from_cc := 'NULL';
            ELSE
                l_from_cc := p_from_cc;
            END IF;

            IF p_to_cc IS NULL THEN
                l_to_cc := 'NULL';
            ELSE
                l_to_cc := p_to_cc;
            END IF;

            IF p_from_asset_num IS NULL THEN
                l_from_asset := 'NULL';
            ELSE
                l_from_asset := p_from_asset_num;
            END IF;

            IF p_to_asset_num IS NULL THEN
                l_to_asset := 'NULL';
            ELSE
                l_to_asset := p_to_asset_num;
            END IF;

            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'run_s_deprec_report');
            --  Process Summary Depreciation report
            IF p_reptShrtName = 'RXIGIIAK' THEN
                IF NOT run_s_deprec_report  ( p_bookType
                                        ,p_period
                                        ,l_finalCategoryId
                                        ,p_request_id
                                        ,l_user_id
                                        ,l_login_id)
                THEN
                    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_reptShrtName' || p_reptShrtName);
                    p_retcode := 2;
                ELSE
                    IF NOT Delete_Zero_Rows(p_bookType,p_request_id,p_reptShrtName) THEN
                        p_retcode := 2;
                    END IF;
                END IF;
            --  Process Detailed Depreciation report
            ELSIF p_reptShrtName = 'RXIGIIAD' THEN
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'run_d_deprec_report');
                IF NOT run_d_deprec_report(p_bookType
                                        ,p_period
                                        ,l_finalCategoryId
                                        ,l_from_cc
                                        ,l_to_cc
                                        ,l_from_asset
                                        ,l_to_asset
                                        ,p_request_id
                                        ,l_user_id
                                        ,l_login_id)
                THEN
                    p_retcode := 2;
                ELSE
                    IF NOT Delete_Zero_Rows(p_bookType,p_request_id,p_reptShrtName) THEN
                        p_retcode := 2;
                    END IF;
                END IF;
            --  Process Summary Operating report
            ELSIF p_reptShrtName = 'RXIGIIAM' THEN
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'run_s_operating_report');
                IF NOT run_s_operating_report(p_bookType
                                        ,p_period
                                        ,l_finalCategoryId
                                        ,p_request_id
                                        ,l_user_id
                                        ,l_login_id)
                THEN
                    p_retcode := 2;
                ELSE
                    IF NOT Delete_Zero_Rows(p_bookType,p_request_id,p_reptShrtName) THEN
                        p_retcode := 2;
                    END IF;
                END IF;
            --  Process Detailed Operating report
            ELSIF p_reptShrtName = 'RXIGIIAO' THEN
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'run_d_operating_report');
                IF NOT run_d_operating_report(p_bookType
                                        ,p_period
                                        ,l_finalCategoryId
                                        ,l_from_cc
                                        ,l_to_cc
                                        ,l_from_asset
                                        ,l_to_asset
                                        ,p_request_id
                                        ,l_user_id
                                        ,l_login_id)
                THEN
                    p_retcode := 2;
                ELSE
                    IF NOT Delete_Zero_Rows(p_bookType,p_request_id,p_reptShrtName) THEN
                        p_retcode := 2;
                    END IF;
                END IF;
            --  Process Summary Revaluation report
            ELSIF p_reptShrtName = 'RXIGIIAL' THEN
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'run_s_reval_report');
                IF NOT run_s_reval_report(p_bookType
                                        ,p_period
                                        ,l_finalCategoryId
                                        ,p_request_id
                                        ,l_user_id
                                        ,l_login_id)
                THEN
                    p_retcode := 2;
                ELSE
                    IF NOT Delete_Zero_Rows(p_bookType,p_request_id,p_reptShrtName) THEN
                        p_retcode := 2;
                    END IF;
                END IF;
            --  Process Detailed Revaluation report
            ELSIF p_reptShrtName = 'RXIGIIAR' THEN
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'run_d_reval_report');
                IF NOT run_d_reval_report(p_bookType
                                        ,p_period
                                        ,l_finalCategoryId
                                        ,l_from_cc
                                        ,l_to_cc
                                        ,l_from_asset
                                        ,l_to_asset
                                        ,p_request_id
                                        ,l_user_id
                                        ,l_login_id)
                THEN
                    p_retcode := 2;
                ELSE
                    IF NOT Delete_Zero_Rows(p_bookType,p_request_id,p_reptShrtName) THEN
                        p_retcode := 2;
                    END IF;
                END IF;
            --  Process Summary Summary report
            ELSIF p_reptShrtName = 'RXIGIIAJ' THEN
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'run_s_summary_report');
                IF NOT run_s_summary_report( p_bookType
                                        ,p_period
                                        ,l_finalCategoryId
                                        ,p_request_id
                                        ,l_user_id
                                        ,l_login_id)
                THEN
                    p_retcode := 2;
                ELSE
                    IF NOT Delete_Zero_Rows(p_bookType,p_request_id,p_reptShrtName) THEN
                        p_retcode := 2;
                    END IF;
                END IF;
            --  Process Detailed summary report
            ELSIF p_reptShrtName = 'RXIGIIAB' THEN
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'run_d_summary_report');
                IF NOT run_d_summary_report( p_bookType
                                        ,p_period
                                        ,l_finalCategoryId
                                        ,l_from_cc
                                        ,l_to_cc
                                        ,l_from_asset
                                        ,l_to_asset
                                        ,p_request_id
                                        ,l_user_id
                                        ,l_login_id)
                THEN
                    p_retcode := 2;
                ELSE
                    IF NOT Delete_Zero_Rows(p_bookType,p_request_id,p_reptShrtName) THEN
                        p_retcode := 2;
                    END IF;
                END IF;
            ELSE
                p_retcode := 0; -- Nothing to process!!!
            END IF;

        ELSE
            p_retcode := 2;
        END IF;
        p_retcode := 0;

        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,' ** END ** ');

    EXCEPTION WHEN OTHERS THEN
        IF SQLCODE <> 0 THEN
            igi_iac_debug_pkg.debug_unexpected_msg(l_path);
        END IF;
        p_retcode := 2;

    END run_report;

    FUNCTION get_flex_segments (p_bookType IN VARCHAR2 )
    RETURN BOOLEAN IS

        CURSOR c_flex(cp_bookType VARCHAR2) IS
        SELECT
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
        l_selOk			BOOLEAN;
        l_path 			VARCHAR2(150);
    BEGIN
        l_selOk			:= FALSE;
        l_path 			:= g_path||'get_flex_segments';

        FOR l_flex in c_flex (p_bookType) LOOP
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
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path, 'l_fiscal_year_name ' || l_fiscal_year_name);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_currency_code ' || l_currency_code);

        l_g_loc_struct := l_loc_struct;
        l_g_asset_key_struct := l_asset_key_struct;
        l_g_cat_struct := l_cat_struct;

        BEGIN
        balancing_seg_no :=
            fa_rx_flex_pkg.flex_sql(p_application_id => 101,
                                    p_id_flex_code => 'GL#',
                                    p_id_flex_num => l_acct_struct,
                                    p_table_alias => 'cc',
                                    p_mode => 'SELECT',
                                    p_qualifier => 'GL_BALANCING');

        EXCEPTION
            WHEN OTHERS THEN
            igi_iac_debug_pkg.debug_other_string(g_unexp_level,l_path,'Unable to get "Balancing Segment No" : '|| sqlerrm);
            IF c_flex%ISOPEN THEN
                CLOSE c_flex;
            END IF;
            RETURN FALSE;
        END;

        BEGIN
        cost_ctr_seg_no :=
            fa_rx_flex_pkg.flex_sql(p_application_id => 101,
                                    p_id_flex_code => 'GL#',
                                    p_id_flex_num => l_acct_struct,
                                    p_table_alias => 'cc',
                                    p_mode => 'SELECT',
                                    p_qualifier => 'FA_COST_CTR');

        EXCEPTION
            WHEN OTHERS THEN
            -- bug 3421784, start 1
            IF c_flex%ISOPEN THEN
                CLOSE c_flex;
            END IF;
            -- bug 3421784, end 1
            igi_iac_debug_pkg.debug_other_string(g_unexp_level,l_path,'Unable to get "Cost Centre Segment No" : '|| sqlerrm);
            RETURN FALSE;
        END;

        BEGIN
        account_seg_no :=
            fa_rx_flex_pkg.flex_sql(p_application_id => 101,
                                    p_id_flex_code => 'GL#',
                                    p_id_flex_num => l_acct_struct,
                                    p_table_alias => 'cc',
                                    p_mode => 'SELECT',
                                    p_qualifier => 'GL_ACCOUNT');

        EXCEPTION
            WHEN OTHERS THEN
            igi_iac_debug_pkg.debug_other_string(g_unexp_level,l_path,'Unable to get "Account Segment No" : '|| sqlerrm);
            IF c_flex%ISOPEN THEN
                CLOSE c_flex;
            END IF;
            RETURN FALSE;
        END;
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'company_seg_no is: ' || balancing_seg_no);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'cost_ctr_seg_no is: ' || cost_ctr_seg_no);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'account_seg_no is: ' || account_seg_no);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_acct_struct is: ' || l_acct_struct);

        BEGIN
            major_cat_seg_no :=
                fa_rx_flex_pkg.flex_sql(p_application_id => 140,
                                        p_id_flex_code => 'CAT#',
                                        p_id_flex_num => l_cat_struct,
                                        p_table_alias => 'cf',
                                        p_mode => 'SELECT',
                                        p_qualifier => 'BASED_CATEGORY');

        EXCEPTION
            WHEN OTHERS THEN
            -- bug 3421784, start 2
            IF c_flex%ISOPEN THEN
                CLOSE c_flex;
            END IF;
            -- bug 3421784, end 2
            igi_iac_debug_pkg.debug_other_string(g_unexp_level,l_path,'Unable to get "Major Category Segment No" : '|| sqlerrm);
            RETURN FALSE;
        END;
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'major_cat_seg_no is: ' || major_cat_seg_no);

        BEGIN
            minor_cat_seg_no :=
                fa_rx_flex_pkg.flex_sql(p_application_id => 140,
                                        p_id_flex_code => 'CAT#',
                                        p_id_flex_num => l_cat_struct,
                                        p_table_alias => 'cf',
                                        p_mode => 'SELECT',
                                        p_qualifier => 'MINOR_CATEGORY');

                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'minor_cat_seg_no is: ' || minor_cat_seg_no);
        EXCEPTION
            WHEN OTHERS THEN
            -- bug 3421784, start 3
            IF c_flex%ISOPEN THEN
                CLOSE c_flex;
            END IF;
            -- bug 3421784, end 3

            igi_iac_debug_pkg.debug_other_string(g_unexp_level,l_path,'Unable to get "Minor Category Segment No" : '|| sqlerrm);
            RETURN FALSE;
        END;

        RETURN TRUE;

    EXCEPTION
        WHEN OTHERS THEN
        -- bug 3421784, start 4
        IF c_flex%ISOPEN THEN
            CLOSE c_flex;
        END IF;
        -- bug 3421784, end 4

        igi_iac_debug_pkg.debug_other_string(g_unexp_level,l_path,'Exception within "get_flex_segments" : '|| sqlerrm);
        RETURN FALSE;

    END get_flex_segments;

    FUNCTION get_period_name (p_bookType	IN	VARCHAR2
                            ,p_period	IN	VARCHAR2)
    RETURN BOOLEAN IS

        CURSOR c_period (cp_bookType VARCHAR2, cp_period VARCHAR2) IS
        SELECT	period_name
        FROM	fa_deprn_periods
        WHERE	Book_Type_Code = cp_bookType
        AND period_counter = TO_NUMBER(cp_period);

        l_selOk		BOOLEAN      ;
        l_path 	 	VARCHAR2(150);
    BEGIN
        l_selOk		:= FALSE;
        l_path 	 	:= g_path||'get_period_name';

        FOR l_period in c_period (p_bookType, p_period) LOOP
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
        -- bug 3421784, start 5
        IF c_period%ISOPEN THEN
            CLOSE c_period;
        END IF;
        -- bug 3421784, end 5

        igi_iac_debug_pkg.debug_other_string(g_unexp_level,l_path, 'Exception within "get_period_name" : '|| sqlerrm);
        RETURN FALSE;
    END get_period_name;

    FUNCTION run_s_deprec_report  ( p_bookType	IN	VARCHAR2
				,p_period	IN	VARCHAR2
				,p_categoryId	IN	VARCHAR2
				,p_request_id	IN	NUMBER
				,l_user_id	IN	NUMBER
				,p_login_id	IN	VARCHAR2)
    RETURN BOOLEAN IS

        l_select_statement	VARCHAR2(15000);
        TYPE var_cur IS REF CURSOR;
        ret_lines	var_cur;

        l_cost_center	VARCHAR2(25);
        l_book_code		VARCHAR2(15);
        l_reval_cost		NUMBER;
        l_gl_code_seg1	VARCHAR2(25);
        l_gl_code_seg2	VARCHAR2(25);
        l_gl_code_seg3   VARCHAR2(25);
        l_fa_cat_seg1	VARCHAR2(25);
        l_fa_cat_seg2	VARCHAR2(25);
        l_deprn_period	NUMBER;
        l_ytd_deprn		NUMBER;
        l_deprn_resv		NUMBER;
        l_deprn_backlog	NUMBER;
        l_deprn_total	NUMBER;
        l_asset_cat_id	NUMBER(15);
        l_asset_tag				fa_additions.tag_number%TYPE;
        l_serial_number			fa_additions.serial_number%TYPE;
        l_life_in_months			fa_Books.life_in_months%TYPE;
        l_date_placed_in_service		fa_Books.date_placed_in_service%TYPE;
        l_depreciation_reserve_account	fa_category_books.deprn_reserve_acct%TYPE;
        l_depreciation_method		fa_Books.deprn_method_code%TYPE;
        l_location_id			fa_distribution_history.location_id%TYPE;
        l_asset_key_ccid         fa_asset_keywords.code_combination_id%TYPE;
        l_asset_cost_account			fa_category_books.asset_cost_acct%TYPE;
        l_deprn_res_acct	fa_category_books.deprn_reserve_acct%TYPE;
        l_dep_backlog	NUMBER;
        l_gen_fund_acct	NUMBER;
        l_oper_exp_acct	NUMBER;
        l_reval_rsv_acct NUMBER;
        l_concat_loc		VARCHAR2(200);
        l_concat_asset_key	VARCHAR2(200);
        l_concat_cat         VARCHAR2(500);
        l_loc_segs		fa_rx_shared_pkg.Seg_Array;
        l_asset_segs		fa_rx_shared_pkg.Seg_Array;
        l_cat_segs           fa_rx_shared_pkg.Seg_Array;
        l_stl_rate		NUMBER;
        l_CFDescription	VARCHAR2(40);
        l_path 		VARCHAR2(150);

    BEGIN
        l_path 		:= g_path||'run_s_deprec_report';

        l_select_statement := 'SELECT ' ||
            balancing_seg_no    || ', ' ||
            cost_ctr_seg_no     || ', ' ||
            account_seg_no      || ', ' ||
            major_cat_seg_no    || ', ' ||
            minor_cat_seg_no    || ', ' ||
            'bk.book_type_Code book_type_code,
            ah.category_id asset_category_id,
            cf.description category_description,
            ad.asset_key_ccid asset_key_ccid,
            bk.deprn_method_code depreciation_method,
            dh.location_id location_id,
            cb.deprn_reserve_acct depreciation_reserve_account,
            cb.asset_cost_acct asset_cost_account,
            sum(nvl(dd.cost,0))  Reval_Cost,
            sum(decode(dd.period_counter,'||p_period||',nvl(dd.deprn_amount,0)-nvl(dd.deprn_adjustment_amount,0),0))  Period_Deprn,
            sum(nvl(dd.ytd_deprn,0)) YTD_Deprn,
            sum(nvl(dd.deprn_reserve,0)) Acc_Deprn_Normal,
            0 Acc_Deprn_backlog,
            sum(nvl(dd.deprn_reserve,0)) Acc_Deprn_Total
        FROM fa_additions ad,
            fa_Books bk,
            fa_distribution_history dh,
            fa_deprn_Detail dd,
            gl_code_combinations cc,
            fa_categories cf,
            fa_asset_history ah,
            fa_category_books cb,
            fa_book_controls fb,
            fa_deprn_periods fdp
        WHERE ad.asset_id = bk.asset_id
        AND cf.category_id = ah.category_id
        AND   cb.category_id = ah.category_id
        AND bk.book_type_code = :v_bookType
        AND cf.category_id = ' || p_categoryId || '
        AND fdp.book_type_code = bk.book_type_code
        AND fdp.period_counter = :v_period
        AND   nvl(bk.period_counter_fully_retired,fdp.period_counter+1) > fdp.period_counter
        AND dd.asset_id = bk.asset_id
        AND dd.book_type_code = bk.book_type_code
        AND cb.book_type_code = bk.book_type_code
        AND dh.distribution_id = dd.distribution_id
        AND dh.code_combination_id = cc.code_combination_id
        AND dh.asset_id = ah.asset_id
        AND   dh.transaction_header_id_in >= ah.transaction_header_id_in
        AND   dh.transaction_header_id_in < nvl(ah.transaction_header_id_out,dh.transaction_header_id_in+1)
        AND fb.book_type_code = bk.book_type_code
        AND dd.period_counter =
            (SELECT max(period_counter)
            FROM fa_deprn_detail ids
            WHERE asset_id = bk.asset_id
            AND book_type_code = bk.book_type_code
            AND period_counter <= fdp.period_counter )
        AND     bk.transaction_header_id_in = (SELECT max(ifb.transaction_header_id_in)
                                                FROM fa_books ifb
                                                WHERE ifb.book_type_code = bk.book_type_code
                                                AND ifb.asset_id = bk.asset_id
                                                AND ifb.date_effective < nvl(fdp.period_close_date,sysdate))
        AND bk.asset_id not in
            (SELECT asset_id
            FROM igi_iac_asset_balances
            WHERE book_type_code = bk.book_type_code
            AND asset_id = bk.asset_id)
        GROUP BY bk.book_type_Code , ' ||
                balancing_seg_no    || ', ' ||
                cost_ctr_seg_no     || ', ' ||
                account_seg_no      || ', ' ||
                major_cat_seg_no    || ', ' ||
                'ah.category_id,
                cf.description,
                ad.asset_key_ccid, '   ||
                minor_cat_seg_no    || ', ' ||
                'bk.deprn_method_code ,
                dh.location_id ,
                cb.deprn_reserve_acct ,
                cb.asset_cost_acct ' ||

        ' UNION
        SELECT ' ||
            balancing_seg_no    || ', ' ||
            cost_ctr_seg_no     || ', ' ||
            account_seg_no      || ', ' ||
            major_cat_seg_no    || ', ' ||
            minor_cat_seg_no    || ', ' ||
            'bk.book_type_Code book_type_code,
            ah.category_id asset_category_id ,
            cf.description category_description,
            ad.asset_key_ccid asset_key_ccid,
            bk.deprn_method_code depreciation_method,
            dh.location_id location_id,
            cb.deprn_reserve_acct depreciation_reserve_account,
            cb.asset_cost_acct asset_cost_account,
            sum(nvl(( id.adjustment_cost + dd.cost), 0)) Reval_Cost,
            sum(decode(id.period_counter,'||p_period||',nvl(id.Deprn_Period+ifd.Deprn_Period, 0),0)) Period_Deprn,
            sum(decode(fd.fiscal_year,'||l_fiscal_year||',nvl(id.Deprn_YTD+ifd.deprn_ytd, 0),0)) 		YTD_Deprn,
            sum(nvl(id.Deprn_Reserve + dd.deprn_Reserve, 0)) Acc_Deprn_Normal ,
            sum(nvl(id.Deprn_Reserve_backlog, 0) ) 		Acc_Deprn_Backlog ,
            sum(nvl(id.Deprn_Reserve+dd.deprn_reserve+id.deprn_Reserve_backlog, 0))  Acc_Deprn_Total
        FROM    fa_additions ad ,
            fa_Books bk ,
            fa_distribution_history dh,
            fa_deprn_Detail dd ,
            igi_iac_det_balances id,
            igi_iac_fa_deprn ifd,
            gl_code_combinations cc,
            fa_categories cf,
            fa_asset_history ah,
            fa_category_books cb,
            fa_book_controls fb,
            fa_deprn_periods fd,
            fa_deprn_periods fdp
        WHERE ad.asset_id = bk.asset_id
        AND cf.category_id = ah.category_id
        AND   cb.category_id = ah.category_id
        AND     bk.book_Type_code = :v_bookType1
        AND  fdp.book_type_code = bk.book_type_code
        AND  fdp.period_counter = :v_period1
        AND   nvl(bk.period_counter_fully_retired,fdp.period_counter+1) > fdp.period_counter
        AND     dh.book_type_Code = bk.book_type_code
        AND    dh.book_type_code = dd.book_type_code
        AND     cb.book_type_Code = bk.book_type_code
        AND    cf.category_id = ' || p_categoryId || '
        AND   dh.asset_id  = dd.asset_id
        AND   dh.distribution_id = dd.distribution_id
        AND   dh.asset_id = ah.asset_id
        AND   dh.transaction_header_id_in >= ah.transaction_header_id_in
        AND   dh.transaction_header_id_in < nvl(ah.transaction_header_id_out,dh.transaction_header_id_in+1)
        AND   fb.book_type_code = bk.book_type_code
        AND   dd.period_counter = (SELECT MAX(period_counter)
                                FROM fa_deprn_detail ids
                                WHERE asset_id = bk.asset_id
                                AND book_type_code = bk.book_type_code
                                AND ids.distribution_id = dd.distribution_id
                                AND period_counter <= fdp.period_counter )
        AND     bk.transaction_header_id_in = (SELECT max(ifb.transaction_header_id_in)
                                                FROM fa_books ifb
                                                WHERE ifb.book_type_code = bk.book_type_code
                                                AND ifb.asset_id = bk.asset_id
                                                AND ifb.date_effective < nvl(fdp.period_close_date,sysdate))
        AND     dh.distribution_id = id.distribution_id
        AND     dh.code_Combination_id = cc.code_combination_id
        AND     id.adjustment_id = ifd.adjustment_id
        AND     id.distribution_id = ifd.distribution_id
        AND     id.period_counter = ifd.period_counter
        AND     id.adjustment_id =       ( SELECT max(adjustment_id)
                                    FROM  igi_iac_transaction_headers it
                                    WHERE it.asset_id = bk.asset_id
                                    AND   it.book_type_code = bk.book_type_Code
                                    AND it.period_counter <= fdp.period_counter
                                    AND adjustment_status not in (''PREVIEW'', ''OBSOLETE''))
        AND     fd.period_counter = id.period_counter
        AND     fd.book_type_code = bk.book_type_code
        GROUP BY bk.book_type_Code , ' ||
                balancing_seg_no    || ', ' ||
                cost_ctr_seg_no     || ', ' ||
                account_seg_no      || ', ' ||
                major_cat_seg_no    || ', ' ||
                'ah.category_id,
                cf.description,
                ad.asset_key_ccid, '   ||
                minor_cat_seg_no    || ', ' ||
                'bk.deprn_method_code ,
                dh.location_id ,
                cb.deprn_reserve_acct ,
                cb.asset_cost_acct ';

        -- bug 3421784, start 6
        -- commenting out
        -- igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_select_statement ' || l_select_statement);
        -- bug 3421784, end 6

        /* Bug 3490402 */
        OPEN ret_lines FOR l_select_statement USING p_bookType,      /* :v_bookType    */
                                               p_period,        /* :v_period      */
                                               p_bookType,      /* :v_bookType1   */
                                               p_period;        /* :v_period1     */

        LOOP

            fetch ret_lines into
                l_gl_code_seg1,
                l_gl_code_seg2,
                l_gl_code_seg3,
                l_fa_cat_seg1,
                l_fa_cat_seg2,
                l_book_code,
                l_asset_cat_id,
                l_CFDescription,
                l_asset_key_ccid,
                l_depreciation_method,
                l_location_id,
                l_depreciation_reserve_account,
                l_asset_cost_account,
                l_reval_cost,
                l_deprn_period,
                l_ytd_deprn,
                l_deprn_resv,
                l_deprn_backlog,
                l_deprn_total;

            IF (ret_lines%NOTFOUND) THEN
                EXIT;
            END IF;

            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'after fetch ');

            -- This will get the CONCATANATED LOCATION
            fa_rx_shared_pkg.concat_location (
				struct_id => l_g_loc_struct
				,ccid => l_location_id
				,concat_string => l_concat_loc
				,segarray => l_loc_segs);

            -- This will get the CONCATANATED ASSETKEY
            fa_rx_shared_pkg.concat_asset_key (
				struct_id => l_g_asset_key_struct
				,ccid => l_asset_key_ccid
				,concat_string => l_concat_asset_key
				,segarray => l_asset_segs);

            -- This gets the CONCATENATED CATEGORY NAME
            fa_rx_shared_pkg.concat_category (
                                       struct_id       => l_g_cat_struct,
                                       ccid            => l_asset_cat_id,
                                       concat_string   => l_concat_cat,
                                       segarray        => l_cat_segs);

            /*IF NOT get_acct_seg_val_from_ccid ( p_bookType
					,l_asset_cat_id
					,l_dep_backlog
					,l_gen_fund_acct
					,l_oper_exp_acct
					,l_reval_rsv_acct
					)
            THEN
                igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'Failed to get Account segement values - will continue.... ');
            END IF;*/

            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_stl_rate ' || l_stl_rate);
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_concat_loc ' || l_concat_loc);
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_concat_asset_key ' || l_concat_asset_key);
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_asset_cat_id ' || l_asset_cat_id);
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_concat_cat ' || l_concat_cat);
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_dep_backlog ' || l_dep_backlog);
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_gen_fund_acct ' || l_gen_fund_acct);
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_oper_exp_acct ' || l_oper_exp_acct);
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_reval_rsv_acct ' || l_reval_rsv_acct);

            INSERT INTO igi_iac_asset_rep_itf (
                request_id,
                company_name,
                book_type_code,
                period,
                fiscal_year_name,
                major_category,
                cost_center,
                depreciation_method,
                conc_asset_key,
                conc_location,
                --deprn_exp_acct,
                --deprn_res_acct,
                cost_acct,
                --iac_reval_resv_acct,
                balancing_segment,
                --deprn_backlog_acct,
                --gen_fund_acct,
                --oper_exp_acct,
                concat_category,
                reval_cost,
                minor_category,
                deprn_period,
                ytd_deprn,
                deprn_resv,
                deprn_backlog,
                deprn_total,
                functional_currency_code,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login
                )
            VALUES
            (
                p_request_id,
                l_company_name,
                l_book_code,
                l_period_name,
                l_fiscal_year_name,
                l_fa_cat_seg1,
                l_gl_code_seg2,
                l_depreciation_method,
                l_concat_asset_key,
                l_concat_loc,
                --l_gl_code_seg3,
                --l_depreciation_reserve_account,
                l_asset_cost_account,
                --l_reval_rsv_acct,
                l_gl_code_seg1,
                --l_dep_backlog,
                --l_gen_fund_acct,
                --l_oper_exp_acct,
                l_concat_cat,
                l_reval_cost,
                l_fa_cat_seg2,
                l_deprn_period,
                l_ytd_deprn,
                l_deprn_resv,
                l_deprn_backlog,
                l_deprn_total,
                l_currency_code,
                l_user_id,
                sysdate,
                l_user_id,
                sysdate,
                p_login_id
                );

        END LOOP;
        CLOSE ret_lines;
        RETURN TRUE;
    EXCEPTION
        WHEN OTHERS THEN
        -- bug 3421784, start 7
        IF ret_lines%ISOPEN THEN
           CLOSE ret_lines;
        END IF;
        -- bug 3421784, end 7

        igi_iac_debug_pkg.debug_other_string(g_unexp_level,l_path,'Exception in run_s_deprec_report: '|| sqlerrm);
        RETURN FALSE;
    END run_s_deprec_report;

    FUNCTION run_d_deprec_report  ( p_bookType	IN	VARCHAR2
				,p_period	IN	VARCHAR2
				,p_categoryId	IN	VARCHAR2
				,p_from_cc	IN	VARCHAR2
				,p_to_cc	IN	VARCHAR2
				,p_from_asset	IN	VARCHAR2
				,p_to_asset	IN	VARCHAR2
				,p_request_id	IN	NUMBER
				,l_user_id	IN	NUMBER
				,p_login_id	IN	VARCHAR2)
    RETURN BOOLEAN IS

        l_select_statement	VARCHAR2(15000);
        TYPE var_cur IS REF CURSOR;
        ret_lines	var_cur;

        l_cost_center	VARCHAR2(25);
        l_book_code		VARCHAR2(15);
        l_reval_cost		NUMBER;
        l_asset_number	VARCHAR2(15);
        l_gl_code_seg1	VARCHAR2(25);
        l_gl_code_seg2	VARCHAR2(25);
        l_gl_code_seg3   VARCHAR2(25);
        l_fa_cat_seg1	VARCHAR2(25);
        l_fa_cat_seg2	VARCHAR2(25);
        l_deprn_period	NUMBER;
        l_ytd_deprn		NUMBER;
        l_deprn_resv		NUMBER;
        l_deprn_backlog	NUMBER;
        l_deprn_total	NUMBER;
        l_asset_cat_id	NUMBER(15);
        l_asset_tag				fa_additions.tag_number%TYPE;
        l_parent_id				fa_additions.parent_asset_id%TYPE;
        l_parent_no				VARCHAR2(15);
        l_serial_number			fa_additions.serial_number%TYPE;
        l_life_in_months			fa_Books.life_in_months%TYPE;
        l_date_placed_in_service		fa_Books.date_placed_in_service%TYPE;
        l_depreciation_reserve_account	fa_category_books.deprn_reserve_acct%TYPE;
        l_depreciation_method		fa_Books.deprn_method_code%TYPE;
        l_location_id			fa_distribution_history.location_id%TYPE;
        l_asset_key_ccid         fa_asset_keywords.code_combination_id%TYPE;
        l_asset_cost_account			fa_category_books.asset_cost_acct%TYPE;
        l_deprn_res_acct	fa_category_books.deprn_reserve_acct%TYPE;
        l_dep_backlog	NUMBER;
        l_gen_fund_acct	NUMBER;
        l_oper_exp_acct	NUMBER;
        l_reval_rsv_acct	NUMBER;
        l_concat_loc		     VARCHAR2(240);
        l_concat_asset_key	 VARCHAR2(240);
        l_concat_cat          VARCHAR2(600);
        l_loc_segs		fa_rx_shared_pkg.Seg_Array;
        l_asset_segs		fa_rx_shared_pkg.Seg_Array;
        l_cat_segs           fa_rx_shared_pkg.Seg_Array;
        l_stl_rate		NUMBER;
        l_CFDescription	VARCHAR2(40);
        l_ADDescription	fa_additions.description%type;
        l_from_asset         VARCHAR2(100);
        l_to_asset           VARCHAR2(100);
        l_from_cc            VARCHAR2(100);
        l_to_cc              VARCHAR2(100);
        l_path		VARCHAR2(150);

   BEGIN
        l_path		:= g_path||'run_d_deprec_report';

        l_select_statement := 'SELECT ' ||
            balancing_seg_no    || ', ' ||
            cost_ctr_seg_no     || ', ' ||
            account_seg_no      || ', ' ||
            major_cat_seg_no    || ', ' ||
            minor_cat_seg_no    || ', ' ||
            'bk.book_type_Code book_type_code,
            ah.category_id asset_category_id,
            cf.description category_description,
            ad.asset_number asset_number,
            ad.description asset_description,
            ad.tag_number asset_tag,
            ad.parent_asset_id parent_id,
            ad.serial_number serial_number,
            ad.asset_key_ccid asset_key_ccid,
            bk.life_in_months life_in_months,
            bk.date_placed_in_service date_placed_in_service,
            bk.deprn_method_code depreciation_method,
            dh.location_id location_id,
            cb.deprn_reserve_acct depreciation_reserve_account,
            cb.asset_cost_acct asset_cost_account,
            sum(nvl(dd.cost,0))  Reval_Cost,
            sum(decode(dd.period_counter,'||p_period||',nvl(dd.deprn_amount,0)-nvl(dd.deprn_adjustment_amount,0),0))  Period_Deprn,
            sum(nvl(dd.ytd_deprn,0)) YTD_Deprn,
            sum(nvl(dd.deprn_reserve,0)) Acc_Deprn_Normal,
            0 Acc_Deprn_backlog,
            sum(nvl(dd.deprn_reserve,0)) Acc_Deprn_Total
        FROM fa_additions ad,
            fa_Books bk,
            fa_distribution_history dh,
            fa_deprn_Detail dd,
            gl_code_combinations cc,
            fa_categories cf,
            fa_asset_history ah,
            fa_category_books cb,
            fa_book_controls fb,
            fa_deprn_periods fdp
        WHERE ad.asset_id = bk.asset_id
        AND cf.category_id = ah.category_id
        AND   cb.category_id = ah.category_id
        AND bk.book_type_code = :v_bookType
	AND NOT EXISTS
		(SELECT 1
		 FROM igi_iac_det_balances db
	         WHERE db.book_type_code = bk.book_type_code
	         AND db.asset_id = bk.asset_id)
        AND fdp.period_counter = :v_period
        AND fdp.book_type_code = bk.book_type_code
        AND cf.category_id = ' || p_categoryId || '
        AND   nvl(bk.period_counter_fully_retired,fdp.period_counter+1) > fdp.period_counter
        AND dd.asset_id = bk.asset_id
        AND dd.book_type_code = bk.book_type_code
        AND cb.book_type_code = bk.book_type_code
	AND dh.book_type_code = bk.book_type_code
        AND dh.asset_id = bk.asset_id
        AND dh.distribution_id = dd.distribution_id
        AND dh.code_combination_id = cc.code_combination_id
        AND ah.asset_id = bk.asset_id
        AND dh.transaction_header_id_in >= ah.transaction_header_id_in
        AND dh.transaction_header_id_in < nvl(ah.transaction_header_id_out,dh.transaction_header_id_in+1)
        AND fb.book_type_code = bk.book_type_code
        AND dd.period_counter =
            (SELECT max(period_counter)
            FROM fa_deprn_detail ids
            WHERE asset_id = bk.asset_id
            AND book_type_code = bk.book_type_code
            AND period_counter <= fdp.period_counter )
        AND     bk.transaction_header_id_in = (SELECT max(ifb.transaction_header_id_in)
                                                FROM fa_books ifb
                                                WHERE ifb.book_type_code = bk.book_type_code
                                                AND ifb.asset_id = bk.asset_id
                                                AND ifb.date_effective < nvl(fdp.period_close_date,sysdate))
        AND ' || cost_ctr_seg_no || ' between nvl( :v_from_cc, ' || cost_ctr_seg_no || ' )
        AND nvl( :v_to_cc,' || cost_ctr_seg_no || ')
        AND ad.asset_number between nvl( :v_from_asset, ad.asset_number)
        AND  nvl( :v_to_asset, ad.asset_number)
        GROUP BY bk.book_type_Code , ' ||
                balancing_seg_no    || ', ' ||
                cost_ctr_seg_no     || ', ' ||
                account_seg_no      || ', ' ||
                major_cat_seg_no    || ', ' ||
                'ah.category_id,
                cf.description, '   ||
                minor_cat_seg_no    || ', ' ||
                'ad.asset_number,
                ad.description,
                ad.tag_number ,
                ad.parent_asset_id ,
                ad.serial_number ,
                ad.asset_key_ccid ,
                bk.life_in_months ,
                bk.date_placed_in_service ,
                bk.deprn_method_code ,
                dh.location_id ,
                cb.deprn_reserve_acct ,
                cb.asset_cost_acct ' ||
        ' UNION
        SELECT ' ||
            balancing_seg_no    || ', ' ||
            cost_ctr_seg_no     || ', ' ||
            account_seg_no      || ', ' ||
            major_cat_seg_no    || ', ' ||
            minor_cat_seg_no    || ', ' ||
            'bk.book_type_Code book_type_code,
            ah.category_id asset_category_id ,
            cf.description category_description,
            ad.asset_number asset_number ,
            ad.description asset_description,
            ad.tag_number asset_tag,
            ad.parent_asset_id parent_id,
            ad.serial_number serial_number,
            ad.asset_key_ccid asset_key_ccid,
            bk.life_in_months life_in_months,
            bk.date_placed_in_service date_placed_in_service,
            bk.deprn_method_code depreciation_method,
            dh.location_id location_id,
            cb.deprn_reserve_acct depreciation_reserve_account,
            cb.asset_cost_acct asset_cost_account,
            sum (nvl((id.adjustment_cost + dd.cost), 0))  Reval_Cost,
            sum(nvl(decode(id.period_counter,'||p_period||',id.Deprn_Period+ifd.Deprn_Period,0), 0)) Period_Deprn,
            sum(nvl(decode(fd.fiscal_year,'||l_fiscal_year||',id.Deprn_YTD+ifd.deprn_ytd, 0),0)) 		YTD_Deprn,
            sum(nvl(id.Deprn_Reserve + dd.deprn_Reserve, 0)) Acc_Deprn_Normal ,
            sum(nvl(id.Deprn_Reserve_backlog, 0) ) 		Acc_Deprn_Backlog ,
            sum(nvl(id.Deprn_Reserve+dd.deprn_reserve+id.deprn_Reserve_backlog, 0))  Acc_Deprn_Total
        FROM    fa_additions ad ,
            fa_Books bk ,
            fa_distribution_history dh,
            fa_deprn_Detail dd ,
            igi_iac_det_balances id,
            igi_iac_fa_deprn ifd,
            gl_code_combinations cc,
            fa_categories cf,
            fa_asset_history ah,
            fa_category_books cb,
            fa_book_controls fb,
            fa_deprn_periods fd,
            fa_deprn_periods fdp
        WHERE   ad.asset_id = bk.asset_id
	AND   bk.transaction_header_id_out IS NULL
        AND cf.category_id = ah.category_id
        AND   cb.category_id = ah.category_id
        AND     bk.book_Type_code = :v_bookType1
        AND fdp.book_type_code = bk.book_type_code
        AND fdp.period_counter = :v_period1
        AND     dh.book_type_Code = bk.book_type_code
        AND    dd.book_type_code = bk.book_type_code
        AND     cb.book_type_Code = bk.book_type_code
        AND    cf.category_id = ' || p_categoryId || '
        AND   dd.asset_id  = bk.asset_id
        AND   dh.distribution_id = dd.distribution_id
        AND   nvl(bk.period_counter_fully_retired,fdp.period_counter+1) > fdp.period_counter
        AND   dh.asset_id = bk.asset_id
        AND   dh.asset_id = ah.asset_id
	AND   dh.transaction_header_id_in >= ah.transaction_header_id_in
        AND   dh.transaction_header_id_in < nvl(ah.transaction_header_id_out,dh.transaction_header_id_in+1)
        AND   fb.book_type_code = bk.book_type_code
        AND   dd.period_counter = (SELECT MAX(period_counter)
                                        FROM fa_deprn_detail ids
                                        WHERE ids.asset_id = bk.asset_id
                                        AND ids.book_type_code = bk.book_type_code
                                        AND ids.distribution_id = dd.distribution_id
                                        AND ids.period_counter <= fdp.period_counter )
        AND     bk.transaction_header_id_in = (SELECT max(ifb.transaction_header_id_in)
                                                FROM fa_books ifb
                                                WHERE ifb.book_type_code = bk.book_type_code
                                                AND ifb.asset_id = bk.asset_id
                                                AND ifb.date_effective < nvl(fdp.period_close_date,sysdate))
        AND     id.distribution_id = dd.distribution_id
        AND     dh.code_Combination_id = cc.code_combination_id
        AND     id.adjustment_id = ifd.adjustment_id
        AND     id.distribution_id = ifd.distribution_id
        AND     id.period_counter = ifd.period_counter
        AND     id.adjustment_id =       ( SELECT max(adjustment_id)
                                        FROM  igi_iac_transaction_headers it
                                        WHERE it.asset_id = bk.asset_id
                                        AND   it.book_type_code = bk.book_type_Code
                                        AND it.period_counter <= fdp.period_counter
                                        AND it.adjustment_status not in( ''PREVIEW'', ''OBSOLETE''))
        AND ' || cost_ctr_seg_no || ' between nvl( :v_from_cc1, ' || cost_ctr_seg_no || ' )
        AND nvl( :v_to_cc1,' || cost_ctr_seg_no || ')
        AND ad.asset_number between nvl( :v_from_asset1, ad.asset_number)
        AND  nvl( :v_to_asset1, ad.asset_number)
        AND fd.period_counter = id.period_counter
        AND fd.book_type_code = bk.book_type_code
        GROUP BY bk.book_type_Code , ' ||
            balancing_seg_no    || ', ' ||
            cost_ctr_seg_no     || ', ' ||
            account_seg_no      || ', ' ||
            major_cat_seg_no    || ', ' ||
            'ah.category_id,
            cf.description, '   ||
            minor_cat_seg_no    || ', ' ||
            'ad.asset_number,
            ad.description,
            ad.tag_number ,
            ad.parent_asset_id ,
            ad.serial_number ,
            ad.asset_key_ccid,
            bk.life_in_months ,
            bk.date_placed_in_service ,
            bk.deprn_method_code ,
            dh.location_id ,
            cb.deprn_reserve_acct ,
            cb.asset_cost_acct';

        -- bug 3421784, start 8
        -- commenting out
             --igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_select_statement ' || l_select_statement);
        -- bug 3421784, end 8

        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,' ** After l_select ** ');
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_categoryId --> ' || p_categoryId);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_bookType   --> ' || p_bookType);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_period     --> ' || p_period);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_from_cc    --> ' || nvl(p_from_cc,1));
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_to_cc      --> ' || nvl(p_to_cc,1));
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_from_asset --> ' || nvl(p_from_asset,1));
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_to_asset   --> ' || nvl(p_to_asset,1));

        IF p_from_asset = 'NULL' THEN
            l_from_asset := NULL;
        ELSE
            l_from_asset := p_from_asset;
        END IF;

        IF p_to_asset = 'NULL' THEN
            l_to_asset := NULL;
        ELSE
            l_to_asset := p_to_asset;
        END IF;

        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_from_asset --> ' || nvl(l_from_asset,1));
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_to_asset   --> ' || nvl(l_to_asset,1));

        IF p_from_cc = 'NULL' THEN
            l_from_cc := NULL;
        ELSE
            l_from_cc := p_from_cc;
        END IF;

        IF p_to_cc = 'NULL' THEN
            l_to_cc := NULL;
        ELSE
            l_to_cc := p_to_cc;
        END IF;

        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_from_cc --> ' || nvl(l_from_cc,1));
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_to_cc   --> ' || nvl(l_to_cc,1));

        /* Bug 3490402 */
        OPEN ret_lines FOR l_select_statement USING p_bookType,       /* :v_bookType         */
                                               p_period,         /* :v_period           */
                                               l_from_cc,        /* :v_from_cc          */
                                               l_to_cc,          /* :v_to_cc,           */
                                               l_from_asset,     /* :v_from_asset       */
                                               l_to_asset,       /* :v_to_asset         */
                                               p_bookType,       /* :v_bookType1        */
                                               p_period,         /* :v_period1          */
                                               l_from_cc,        /* :v_from_cc1         */
                                               l_to_cc,          /* :v_to_cc1           */
                                               l_from_asset,     /* :v_from_asset1      */
                                               l_to_asset;       /* :v_to_asset1        */

        LOOP
            fetch ret_lines into
                l_gl_code_seg1,
                l_gl_code_seg2,
                l_gl_code_seg3,
                l_fa_cat_seg1,
                l_fa_cat_seg2,
                l_book_code,
                l_asset_cat_id,
                l_CFDescription,
                l_asset_number,
                l_ADDescription,
                l_asset_tag,
                l_parent_id,
                l_serial_number,
                l_asset_key_ccid,
                l_life_in_months,
                l_date_placed_in_service,
                l_depreciation_method,
                l_location_id,
                l_depreciation_reserve_account,
                l_asset_cost_account,
                l_reval_cost,
                l_deprn_period,
                l_ytd_deprn,
                l_deprn_resv,
                l_deprn_backlog,
                l_deprn_total;

            IF (ret_lines%NOTFOUND) THEN
                EXIT;
            END IF;

            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'after fetch ');

            /* StatReq - The following if statement has been added to calculate the annual depreciation rate
                for straight-line, calculated depreciation methods */

            -- Calculate STL_RATE from life_in_months
            IF (l_life_in_months > 0)
            THEN
                l_stl_rate := 12 / l_life_in_months * 100;
            ELSE
                l_stl_rate := NULL;
            END IF;

            -- This will get the CONCATANATED LOCATION
            fa_rx_shared_pkg.concat_location (
				struct_id => l_g_loc_struct
				,ccid => l_location_id
				,concat_string => l_concat_loc
				,segarray => l_loc_segs);

            -- This will get the CONCATANATED ASSETKEY
            fa_rx_shared_pkg.concat_asset_key (
				struct_id => l_g_asset_key_struct
				,ccid => l_asset_key_ccid
				,concat_string => l_concat_asset_key
				,segarray => l_asset_segs);

            -- This gets the CONCATENATED CATEGORY NAME
            fa_rx_shared_pkg.concat_category (
                                       struct_id       => l_g_cat_struct,
                                       ccid            => l_asset_cat_id,
                                       concat_string   => l_concat_cat,
                                       segarray        => l_cat_segs);

            /*IF NOT get_acct_seg_val_from_ccid ( p_bookType
					,l_asset_cat_id
					,l_dep_backlog
					,l_gen_fund_acct
					,l_oper_exp_acct
					,l_reval_rsv_acct
					)
            THEN
                igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'Failed to get Account segement values - will continue.... ');
            END IF;*/

            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_asset_number ' || l_asset_number);
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_parent_id ' || l_parent_id);
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_stl_rate ' || l_stl_rate);
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_concat_loc ' || l_concat_loc);
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_concat_asset_key ' || l_concat_asset_key);
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_asset_cat_id ' || l_asset_cat_id);
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path, 'l_concat_cat ' || l_concat_cat);
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_dep_backlog ' || l_dep_backlog);
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_oper_exp_acct ' || l_oper_exp_acct);
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path, 'l_reval_rsv_acct ' || l_reval_rsv_acct);

            l_parent_no := NULL;

            IF l_parent_id IS NOT NULL THEN
                l_parent_no := l_asset_number;
            END IF;

            INSERT INTO igi_iac_asset_rep_itf (
                    request_id,
                    company_name,
                    book_type_code,
                    period,
                    fiscal_year_name,
                    major_category,
                    cost_center,
                    asset_number,
                    asset_description,
                    asset_tag,
                    parent_no,
                    serial_no,
                    life_months,
                    stl_rate,
                    dpis,
                    depreciation_method,
                    conc_asset_key,
                    conc_location,
                    --deprn_exp_acct,
                    --deprn_res_acct,
                    cost_acct,
                    --iac_reval_resv_acct,
                    balancing_segment,
                    --deprn_backlog_acct,
                    --gen_fund_acct,
                    --oper_exp_acct,
                    concat_category,
                    reval_cost,
                    minor_category,
                    deprn_period,
                    ytd_deprn,
                    deprn_resv,
                    deprn_backlog,
                    deprn_total,
                    functional_currency_code,
                    created_by,
                    creation_date,
                    last_updated_by,
                    last_update_date,
                    last_update_login
                    )
            VALUES
            (
                    p_request_id,
                    l_company_name,
                    l_book_code,
                    l_period_name,
                    l_fiscal_year_name,
                    l_fa_cat_seg1,
                    l_gl_code_seg2,
                    l_asset_number,
                    l_ADDescription,
                    l_asset_tag,
                    l_parent_no,
                    l_serial_number,
                    l_life_in_months,
                    l_stl_rate,
                    l_date_placed_in_service,
                    l_depreciation_method,
                    l_concat_asset_key,
                    l_concat_loc,
                    --l_gl_code_seg3,
                    --l_depreciation_reserve_account,
                    l_asset_cost_account,
                    --l_reval_rsv_acct,
                    l_gl_code_seg1,
                    --l_dep_backlog,
                    --l_gen_fund_acct,
                    --l_oper_exp_acct,
                    l_concat_cat,
                    l_reval_cost,
                    l_fa_cat_seg2,
                    l_deprn_period,
                    l_ytd_deprn,
                    l_deprn_resv,
                    l_deprn_backlog,
                    l_deprn_total,
                    l_currency_code,
                    l_user_id,
                    sysdate,
                    l_user_id,
                    sysdate,
                    p_login_id
            );

        END LOOP;
        CLOSE ret_lines;

        RETURN TRUE;

    EXCEPTION
        WHEN OTHERS THEN
        -- bug 3421784, start 9
        IF ret_lines%ISOPEN THEN
           CLOSE ret_lines;
        END IF;
        -- bug 3421784, end 9

        igi_iac_debug_pkg.debug_other_string(g_unexp_level,l_path,'Exception in run_d_deprec_report: '|| sqlerrm);
        RETURN FALSE;
    END run_d_deprec_report;

    FUNCTION run_s_operating_report( p_bookType	IN	VARCHAR2
				,p_period	IN	VARCHAR2
				,p_categoryId	IN	VARCHAR2
				,p_request_id	IN	NUMBER
				,l_user_id	IN	NUMBER
				,p_login_id	IN	VARCHAR2)
    RETURN BOOLEAN IS

        l_select_statement	VARCHAR2(15000);
        TYPE var_cur IS REF CURSOR;
        ret_lines	var_cur;

        l_cost_center		VARCHAR2(25);
        l_book_code		VARCHAR2(15);
        l_reval_cost		NUMBER;
        l_gl_code_seg1	VARCHAR2(25);
        l_gl_code_seg2	VARCHAR2(25);
        l_gl_code_seg3   VARCHAR2(25);
        l_fa_cat_seg1		VARCHAR2(25);
        l_fa_cat_seg2		VARCHAR2(25);
        l_oper_exp		NUMBER;
        l_oper_exp_backlog	NUMBER;
        l_oper_exp_net	NUMBER;
        l_asset_cat_id	NUMBER(15);
        l_asset_tag				fa_additions.tag_number%TYPE;
        l_serial_number			fa_additions.serial_number%TYPE;
        l_life_in_months			fa_Books.life_in_months%TYPE;
        l_date_placed_in_service		fa_Books.date_placed_in_service%TYPE;
        l_depreciation_reserve_account	fa_category_books.deprn_reserve_acct%TYPE;
        l_depreciation_method		fa_Books.deprn_method_code%TYPE;
        l_location_id			fa_distribution_history.location_id%TYPE;
        l_asset_key_ccid         fa_asset_keywords.code_combination_id%TYPE;
        l_asset_cost_account			fa_category_books.asset_cost_acct%TYPE;
        l_deprn_res_acct	fa_category_books.deprn_reserve_acct%TYPE;
        l_dep_backlog	NUMBER;
        l_gen_fund_acct	NUMBER;
        l_oper_exp_acct	NUMBER;
        l_reval_rsv_acct	NUMBER;
        l_concat_loc		VARCHAR2(200);
        l_concat_asset_key	VARCHAR2(200);
        l_concat_cat         VARCHAR2(500);
        l_loc_segs		fa_rx_shared_pkg.Seg_Array;
        l_asset_segs		fa_rx_shared_pkg.Seg_Array;
        l_cat_segs           fa_rx_shared_pkg.Seg_Array;
        l_stl_rate		NUMBER;
        l_CFDescription	VARCHAR2(40);
        l_path		VARCHAR2(150);

    BEGIN
        l_path		:= g_path||'run_s_operating_report';

        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,' ** START  run_s_operating_report ** ');

        l_select_statement := 'SELECT ' ||
                balancing_seg_no    || ', ' ||
                cost_ctr_seg_no     || ', ' ||
                account_seg_no      || ', ' ||
                major_cat_seg_no    || ', ' ||
                minor_cat_seg_no    || ', ' ||
                'bk.book_type_Code book_type_code,
                ah.category_id category_id,
                cf.description category_description,
                ad.asset_key_ccid asset_key_ccid,
                bk.deprn_method_code depreciation_method,
                dh.location_id location_id,
                cb.deprn_reserve_acct depreciation_reserve_account,
                cb.asset_cost_acct asset_cost_account,
                sum(nvl(dd.cost,0))  Reval_Cost,
                0  Oper_Acct_Cost,
                0  Oper_Acct_Backlog,
                0  Oper_Acct_Net
        FROM fa_additions ad,
                fa_Books bk,
                fa_distribution_history dh,
                fa_deprn_Detail dd,
                gl_code_combinations cc,
                fa_categories cf,
                fa_category_books cb,
                fa_book_controls fb,
                fa_deprn_periods fdp,
                fa_asset_history ah
        WHERE ad.asset_id = bk.asset_id
        AND  ah.asset_id = bk.asset_id
        AND  cf.category_id=ah.category_id
        AND   cb.category_id = ah.category_id
        AND  cf.category_id = ' || p_categoryId || '
        AND  bk.book_type_code = :v_bookType
        AND fdp.book_type_code = bk.book_type_code
        AND fdp.period_counter = :v_period
        AND   nvl(bk.period_counter_fully_retired,fdp.period_counter+1) > fdp.period_counter
        AND     bk.transaction_header_id_in = (SELECT max(ifb.transaction_header_id_in)
                                                FROM fa_books ifb
                                                WHERE ifb.book_type_code = bk.book_type_code
                                                AND ifb.asset_id = bk.asset_id
                                                AND ifb.date_effective < nvl(fdp.period_close_date,sysdate))
        AND  dd.asset_id = bk.asset_id
        AND  dd.book_type_code = bk.book_type_code
        AND  cb.book_type_code = bk.book_type_code
        AND  dh.distribution_id = dd.distribution_id
        AND  nvl(dh.date_ineffective,sysdate) >= nvl(fdp.period_close_date,sysdate)
        AND   dh.transaction_header_id_in >= ah.transaction_header_id_in
        AND   dh.transaction_header_id_in < nvl(ah.transaction_header_id_out,dh.transaction_header_id_in+1)
        AND  dh.code_combination_id = cc.code_combination_id
        AND  fb.book_type_code = bk.book_type_code
        AND  dd.period_counter =
                (SELECT max(period_counter)
                FROM fa_deprn_summary
                WHERE asset_id = bk.asset_id
                AND book_type_code = bk.book_type_code
                AND period_counter <= fdp.period_counter )
        AND bk.asset_id not in
                (SELECT asset_id
                FROM igi_iac_asset_balances
                WHERE book_type_code = bk.book_type_code
                AND asset_id = bk.asset_id)
        GROUP BY ' || minor_cat_seg_no   || ', ' ||
                'bk.book_type_Code ,
                ah.category_id,
                cf.description ,
                ad.asset_key_ccid , ' ||
                balancing_seg_no    || ', ' ||
                cost_ctr_seg_no     || ', ' ||
                account_seg_no      || ', ' ||
                major_cat_seg_no   || ', ' ||
                'bk.deprn_method_code ,
                dh.location_id ,
                cb.deprn_reserve_acct ,
                cb.asset_cost_acct ' ||
        ' UNION
        SELECT ' ||
                balancing_seg_no    || ', ' ||
                cost_ctr_seg_no     || ', ' ||
                account_seg_no      || ', ' ||
                major_cat_seg_no    || ', ' ||
                minor_cat_seg_no    || ', ' ||
                'bk.book_type_Code book_type_code,
                ah.category_id category_id,
                cf.description category_description,
                ad.asset_key_ccid asset_key_ccid,
                bk.deprn_method_code depreciation_method,
                dh.location_id location_id,
                cb.deprn_reserve_acct depreciation_reserve_account,
                cb.asset_cost_acct asset_cost_account,
                sum (nvl((id.adjustment_cost + dd.cost), 0))  Reval_Cost,
                sum(nvl(id.operating_acct_cost * -1,0)) Oper_Acct_Cost,
                sum(nvl(id.operating_acct_backlog * -1 ,0)) Oper_Acct_Backlog,
                sum(nvl(id.operating_acct_net * -1 ,0)) Oper_Acct_Net
        FROM    fa_additions ad ,
                fa_Books bk ,
                fa_distribution_history dh,
                fa_deprn_Detail dd ,
                igi_iac_det_balances id ,
                gl_code_combinations cc,
                fa_categories cf,
                fa_category_books cb,
                fa_book_controls fb,
                fa_deprn_periods fdp,
                fa_asset_history ah
        WHERE ad.asset_id = bk.asset_id
        AND      ad.asset_id =dh.asset_id
        AND  ah.asset_id = bk.asset_id
        AND  cf.category_id=ah.category_id
        AND   cb.category_id = ah.category_id
        AND     cf.category_id = ' || p_categoryId || '
        AND     bk.book_Type_code = :v_bookType1
        AND fdp.book_type_code = bk.book_type_code
        AND fdp.period_counter = :v_period1
        AND   nvl(bk.period_counter_fully_retired,fdp.period_counter+1) > fdp.period_counter
        AND     bk.transaction_header_id_in = (SELECT max(ifb.transaction_header_id_in)
                                                FROM fa_books ifb
                                                WHERE ifb.book_type_code = bk.book_type_code
                                                AND ifb.asset_id = bk.asset_id
                                                AND ifb.date_effective < nvl(fdp.period_close_date,sysdate))
        AND     dh.book_type_Code = bk.book_type_code
        AND    dh.book_type_code = dd.book_type_code
        AND     cb.book_type_Code = bk.book_type_code
        AND   dh.asset_id  = dd.asset_id
        AND   dh.distribution_id = dd.distribution_id
        AND  nvl(dh.date_ineffective,sysdate) >= nvl(fdp.period_close_date,sysdate)
        AND   dh.transaction_header_id_in >= ah.transaction_header_id_in
        AND   dh.transaction_header_id_in < nvl(ah.transaction_header_id_out,dh.transaction_header_id_in+1)
        AND   fb.book_type_code = bk.book_type_code
        AND   dd.period_counter = (SELECT MAX(period_counter)
                        FROM fa_deprn_summary
                        WHERE asset_id = bk.asset_id
                        AND book_type_code = bk.book_type_code
                        AND period_counter <= fdp.period_counter )
        AND     dh.distribution_id = id.distribution_id
        AND     dh.code_Combination_id = cc.code_combination_id
        AND     id.adjustment_id =
                        ( SELECT max(adjustment_id)
                        FROM igi_iac_transaction_headers it
                        WHERE it.asset_id = bk.asset_id
                        AND it.book_type_code = bk.book_type_Code
                        AND period_counter <= fdp.period_counter
                        AND adjustment_status not in (''PREVIEW'', ''OBSOLETE''))
        GROUP BY ' || minor_cat_seg_no   || ', ' ||
                'bk.book_type_Code ,
                ah.category_id,
                cf.description ,
                ad.asset_key_ccid,
                bk.deprn_method_code ,
                dh.location_id ,
                cb.deprn_reserve_acct ,
                cb.asset_cost_acct, ' ||
                balancing_seg_no    || ', ' ||
                cost_ctr_seg_no     || ', ' ||
                account_seg_no      || ', ' ||
                major_cat_seg_no;

        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'after select ');
        -- bug 3421784, start 10
        -- commenting out
        --     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_select_statement ' || l_select_statement);
        -- bug 3421784, end 10

        /* Bug 3490402 */
        OPEN ret_lines FOR l_select_statement USING p_bookType,      /* :v_bookType    */
                                               p_period,        /* :v_period      */
                                               p_bookType,      /* :v_bookType1   */
                                               p_period;        /* :v_period1     */
        LOOP
            FETCH ret_lines INTO
                l_gl_code_seg1,
                l_gl_code_seg2,
                l_gl_code_seg3,
                l_fa_cat_seg1,
                l_fa_cat_seg2,
                l_book_code,
                l_asset_cat_id,
                l_CFDescription,
                l_asset_key_ccid,
                l_depreciation_method,
                l_location_id,
                l_depreciation_reserve_account,
                l_asset_cost_account,
                l_reval_cost,
                l_oper_exp,
                l_oper_exp_backlog,
                l_oper_exp_net;

            IF (ret_lines%NOTFOUND) THEN
                EXIT;
            END IF;

            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'after fetch ');

            -- This will get the CONCATANATED LOCATION
            fa_rx_shared_pkg.concat_location (
				struct_id => l_g_loc_struct
				,ccid => l_location_id
				,concat_string => l_concat_loc
				,segarray => l_loc_segs);

            -- This will get the CONCATANATED ASSETKEY
            fa_rx_shared_pkg.concat_asset_key (
				struct_id => l_g_asset_key_struct
				,ccid => l_asset_key_ccid
				,concat_string => l_concat_asset_key
				,segarray => l_asset_segs);



            -- This gets the CONCATENATED CATEGORY NAME
            fa_rx_shared_pkg.concat_category (
                                       struct_id       => l_g_cat_struct,
                                       ccid            => l_asset_cat_id,
                                       concat_string   => l_concat_cat,
                                       segarray        => l_cat_segs);

            /*IF NOT get_acct_seg_val_from_ccid ( p_bookType
					,l_asset_cat_id
					,l_dep_backlog
					,l_gen_fund_acct
					,l_oper_exp_acct
					,l_reval_rsv_acct
					)
            THEN
                igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'Failed to get Account segement values - will continue.... ');
            END IF;*/
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_stl_rate ' || l_stl_rate);
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_concat_loc ' || l_concat_loc);
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_concat_asset_key ' || l_concat_asset_key);
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_asset_cat_id ' || l_asset_cat_id);
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_concat_cat ' || l_concat_cat);
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_dep_backlog ' || l_dep_backlog);
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_gen_fund_acct ' || l_gen_fund_acct);
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_oper_exp_acct ' || l_oper_exp_acct);
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_reval_rsv_acct ' || l_reval_rsv_acct);

            INSERT INTO igi_iac_asset_rep_itf (
                    request_id,
                    company_name,
                    book_type_code,
                    period,
                    fiscal_year_name,
                    major_category,
                    cost_center,
                    depreciation_method,
                    conc_asset_key,
                    conc_location,
                    --deprn_exp_acct,
                    --deprn_res_acct,
                    cost_acct,
                    --iac_reval_resv_acct,
                    balancing_segment,
                    --deprn_backlog_acct,
                    --gen_fund_acct,
                    --oper_exp_acct,
                    concat_category,
                    reval_cost,
                    minor_category,
                    oper_exp,
                    oper_exp_backlog,
                    oper_exp_net,
                    functional_currency_code,
                    created_by,
                    creation_date,
                    last_updated_by,
                    last_update_date,
                    last_update_login
                    )
            VALUES
            (
                    p_request_id,
                    l_company_name,
                    l_book_code,
                    l_period_name,
                    l_fiscal_year_name,
                    l_fa_cat_seg1,
                    l_gl_code_seg2,
                    l_depreciation_method,
                    l_concat_asset_key,
                    l_concat_loc,
                    --l_gl_code_seg3,
                    --l_depreciation_reserve_account,
                    l_asset_cost_account,
                    --l_reval_rsv_acct,
                    l_gl_code_seg1,
                    --l_dep_backlog,
                    --l_gen_fund_acct,
                    --l_oper_exp_acct,
                    l_concat_cat,
                    l_reval_cost,
                    l_fa_cat_seg2,
                    l_oper_exp,
                    l_oper_exp_backlog,
                    l_oper_exp_net,
                    l_currency_code,
                    l_user_id,
                    sysdate,
                    l_user_id,
                    sysdate,
                    p_login_id
                    );
        END LOOP;
        CLOSE ret_lines;
        RETURN TRUE;
    EXCEPTION
        WHEN OTHERS THEN
        -- bug 3421784, start 11
        IF ret_lines%ISOPEN THEN
           CLOSE ret_lines;
        END IF;
        -- bug 3421784, start 12
        igi_iac_debug_pkg.debug_other_string(g_unexp_level,l_path,'Exception within run_s_operating_report: '|| sqlerrm);
        RETURN FALSE;
    END run_s_operating_report;

    FUNCTION run_d_operating_report( p_bookType	IN	VARCHAR2
				,p_period	IN	VARCHAR2
				,p_categoryId	IN	VARCHAR2
				,p_from_cc	IN	VARCHAR2
				,p_to_cc	IN	VARCHAR2
				,p_from_asset	IN	VARCHAR2
				,p_to_asset	IN	VARCHAR2
				,p_request_id	IN	NUMBER
				,l_user_id	IN	NUMBER
				,p_login_id	IN	VARCHAR2)
    RETURN BOOLEAN IS

        l_select_statement	VARCHAR2(15000);
        TYPE var_cur IS REF CURSOR;
        ret_lines	var_cur;

        l_cost_center		VARCHAR2(25);
        l_book_code		VARCHAR2(15);
        l_reval_cost		NUMBER;
        l_asset_number	VARCHAR2(15);
        l_gl_code_seg1	VARCHAR2(25);
        l_gl_code_seg2	VARCHAR2(25);
        l_gl_code_seg3   VARCHAR2(25);
        l_fa_cat_seg1		VARCHAR2(25);
        l_fa_cat_seg2		VARCHAR2(25);
        l_oper_exp		NUMBER;
        l_oper_exp_backlog	NUMBER;
        l_oper_exp_net	NUMBER;
        l_asset_cat_id	NUMBER(15);
        l_asset_tag				fa_additions.tag_number%TYPE;
        l_parent_id                          fa_additions.parent_asset_id%TYPE;
        l_parent_no                          VARCHAR2(15);
        l_serial_number			fa_additions.serial_number%TYPE;
        l_life_in_months			fa_Books.life_in_months%TYPE;
        l_date_placed_in_service		fa_Books.date_placed_in_service%TYPE;
        l_depreciation_reserve_account	fa_category_books.deprn_reserve_acct%TYPE;
        l_depreciation_method		fa_Books.deprn_method_code%TYPE;
        l_location_id			fa_distribution_history.location_id%TYPE;
        l_asset_key_ccid         fa_asset_keywords.code_combination_id%TYPE;
        l_asset_cost_account			fa_category_books.asset_cost_acct%TYPE;
        l_deprn_res_acct	fa_category_books.deprn_reserve_acct%TYPE;
        l_dep_backlog	NUMBER;
        l_gen_fund_acct	NUMBER;
        l_oper_exp_acct	NUMBER;
        l_reval_rsv_acct	NUMBER;
        l_concat_loc		VARCHAR2(240);
        l_concat_asset_key	VARCHAR2(240);
        l_concat_cat         VARCHAR2(600);
        l_loc_segs		fa_rx_shared_pkg.Seg_Array;
        l_asset_segs		fa_rx_shared_pkg.Seg_Array;
        l_cat_segs           fa_rx_shared_pkg.Seg_Array;
        l_stl_rate		NUMBER;
        l_CFDescription	VARCHAR2(40);
        l_ADDescription	fa_additions.description%type;
        l_from_asset         VARCHAR2(100);
        l_to_asset           VARCHAR2(100);
        l_from_cc            VARCHAR2(100);
        l_to_cc              VARCHAR2(100);
        l_path 			 VARCHAR2(150);

    BEGIN
        l_path 			 := g_path||'run_d_operating_report';

        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,' ** START  run_d_operating_report ** ');

        l_select_statement := 'SELECT ' ||
                balancing_seg_no    || ', ' ||
                cost_ctr_seg_no     || ', ' ||
                account_seg_no      || ', ' ||
                major_cat_seg_no    || ', ' ||
                minor_cat_seg_no    || ', ' ||
                'bk.book_type_Code book_type_code,
                ah.category_id category_id,
                cf.description category_description,
                ad.asset_number asset_number,
                ad.description asset_description,
                ad.tag_number asset_tag,
                ad.parent_asset_id parent_id,
                ad.serial_number serial_number,
                ad.asset_key_ccid asset_key_ccid,
                bk.life_in_months life_in_months,
                bk.date_placed_in_service date_placed_in_service,
                bk.deprn_method_code depreciation_method,
                dh.location_id location_id,
                cb.deprn_reserve_acct depreciation_reserve_account,
                cb.asset_cost_acct asset_cost_account,
                sum(nvl(dd.cost,0))  Reval_Cost,
                0  Oper_Acct_Cost,
                0  Oper_Acct_Backlog,
                0  Oper_Acct_Net
        FROM fa_additions ad,
                fa_Books bk,
                fa_distribution_history dh,
                fa_deprn_Detail dd,
                gl_code_combinations cc,
                fa_categories cf,
                fa_category_books cb,
                fa_book_controls fb,
                fa_deprn_periods fdp,
                fa_asset_history ah
        WHERE ad.asset_id = bk.asset_id
        AND  ah.asset_id = bk.asset_id
        AND  cf.category_id=ah.category_id
        AND   cb.category_id = ah.category_id
        AND  cf.category_id = ' || p_categoryId || '
        AND  bk.book_type_code = :v_bookType
        AND fdp.book_type_code = bk.book_type_code
        AND fdp.period_counter = :v_period
        AND   nvl(bk.period_counter_fully_retired,fdp.period_counter+1) > fdp.period_counter
        AND     bk.transaction_header_id_in = (SELECT max(ifb.transaction_header_id_in)
                                                FROM fa_books ifb
                                                WHERE ifb.book_type_code = bk.book_type_code
                                                AND ifb.asset_id = bk.asset_id
                                                AND ifb.date_effective < nvl(fdp.period_close_date,sysdate))
        AND  dd.asset_id = bk.asset_id
        AND  dd.book_type_code = bk.book_type_code
        AND  cb.book_type_code = bk.book_type_code
        AND  dh.distribution_id = dd.distribution_id
        AND  nvl(dh.date_ineffective,sysdate) >= nvl(fdp.period_close_date,sysdate)
        AND   dh.transaction_header_id_in >= ah.transaction_header_id_in
        AND   dh.transaction_header_id_in < nvl(ah.transaction_header_id_out,dh.transaction_header_id_in+1)
        AND  dh.code_combination_id = cc.code_combination_id
        AND  fb.book_type_code = bk.book_type_code
        AND  dd.period_counter =
                (SELECT max(period_counter)
                FROM fa_deprn_summary
                WHERE asset_id = bk.asset_id
                AND book_type_code = bk.book_type_code
                AND period_counter <= fdp.period_counter )
        AND bk.asset_id not in
                (SELECT asset_id
                FROM igi_iac_asset_balances
                WHERE book_type_code = bk.book_type_code
                AND asset_id = bk.asset_id)
        AND ' || cost_ctr_seg_no || ' between nvl( :v_from_cc, ' || cost_ctr_seg_no || ' )
        AND nvl( :v_to_cc,' || cost_ctr_seg_no || ')
        AND ad.asset_number between nvl( :v_from_asset, ad.asset_number)
        AND  nvl( :v_to_asset, ad.asset_number)
        GROUP BY ad.asset_number ,
                ad.description , ' ||
                minor_cat_seg_no   || ', ' ||
                'bk.book_type_Code ,
                ah.category_id,
                cf.description , ' ||
                balancing_seg_no    || ', ' ||
                cost_ctr_seg_no     || ', ' ||
                account_seg_no      || ', ' ||
                major_cat_seg_no   || ', ' ||
                'ad.tag_number ,
                ad.parent_asset_id ,
                ad.serial_number ,
                ad.asset_key_ccid ,
                bk.life_in_months ,
                bk.date_placed_in_service ,
                bk.deprn_method_code ,
                dh.location_id ,
                cb.deprn_reserve_acct ,
                cb.asset_cost_acct ' ||

        ' UNION
        SELECT ' ||
                balancing_seg_no    || ', ' ||
                cost_ctr_seg_no     || ', ' ||
                account_seg_no      || ', ' ||
                major_cat_seg_no    || ', ' ||
                minor_cat_seg_no    || ', ' ||
                'bk.book_type_Code book_type_code,
                ah.category_id category_id,
                cf.description category_description,
                ad.asset_number asset_number,
                ad.description asset_description,
                ad.tag_number asset_tag,
                ad.parent_asset_id parent_id,
                ad.serial_number serial_number,
                ad.asset_key_ccid asset_key_ccid,
                bk.life_in_months life_in_months,
                bk.date_placed_in_service date_placed_in_service,
                bk.deprn_method_code depreciation_method,
                dh.location_id location_id,
                cb.deprn_reserve_acct depreciation_reserve_account,
                cb.asset_cost_acct asset_cost_account,
                sum (nvl( id.adjustment_cost,0) + dd.cost)  Reval_Cost,
                sum(nvl(id.operating_acct_cost * -1 ,0)) Oper_Acct_Cost,
                sum(nvl(id.operating_acct_backlog * -1,0)) Oper_Acct_Backlog,
                sum(nvl(id.operating_acct_net * -1 ,0)) Oper_Acct_Net
        FROM    fa_additions ad ,
                fa_Books bk ,
                fa_distribution_history dh,
                fa_deprn_Detail dd ,
                igi_iac_det_balances id ,
                gl_code_combinations cc,
                fa_categories cf,
                fa_category_books cb,
                fa_book_controls fb,
                fa_deprn_periods fdp,
                fa_asset_history ah
        WHERE ad.asset_id = bk.asset_id
        AND    ad.asset_id = id.asset_id
        AND  ah.asset_id = bk.asset_id
        AND  cf.category_id=ah.category_id
        AND   cb.category_id = ah.category_id
        AND     cf.category_id = ' || p_categoryId || '
        AND     bk.book_Type_code = :v_bookType1
        AND fdp.book_type_code = bk.book_type_code
        AND fdp.period_counter = :v_period1
        AND   nvl(bk.period_counter_fully_retired,fdp.period_counter+1) > fdp.period_counter
        AND     bk.transaction_header_id_in = (SELECT max(ifb.transaction_header_id_in)
                                                FROM fa_books ifb
                                                WHERE ifb.book_type_code = bk.book_type_code
                                                AND ifb.asset_id = bk.asset_id
                                                AND ifb.date_effective < nvl(fdp.period_close_date,sysdate))
        AND     dh.book_type_Code = bk.book_type_code
        AND    dh.book_type_code = dd.book_type_code
        AND     cb.book_type_Code = bk.book_type_code
        AND   dh.asset_id  = dd.asset_id
        AND   dh.distribution_id = dd.distribution_id
        AND  nvl(dh.date_ineffective,sysdate) >= nvl(fdp.period_close_date,sysdate)
        AND   dh.transaction_header_id_in >= ah.transaction_header_id_in
        AND   dh.transaction_header_id_in < nvl(ah.transaction_header_id_out,dh.transaction_header_id_in+1)
        AND   fb.book_type_code = bk.book_type_code
        AND   dd.period_counter = (SELECT MAX(period_counter)
                FROM fa_deprn_summary
                WHERE asset_id = bk.asset_id
                AND book_type_code = bk.book_type_code
                AND period_counter <= fdp.period_counter )
        AND     dh.distribution_id = id.distribution_id
        AND     dh.code_Combination_id = cc.code_combination_id
        AND     id.adjustment_id =
                ( SELECT max(adjustment_id)
                FROM igi_iac_transaction_headers it
                WHERE it.asset_id = bk.asset_id
                AND it.book_type_code = bk.book_type_Code
                AND period_counter <= fdp.period_counter
                AND it.adjustment_status not in ( ''PREVIEW'', ''OBSOLETE''))
                AND ' || cost_ctr_seg_no || ' between nvl( :v_from_cc1, ' || cost_ctr_seg_no || ' )
                AND nvl( :v_to_cc1,' || cost_ctr_seg_no || ')
                AND ad.asset_number between nvl( :v_from_asset1, ad.asset_number)
                AND  nvl( :v_to_asset1, ad.asset_number)
        GROUP BY ad.asset_number ,
                ad.description , ' ||
                minor_cat_seg_no   || ', ' ||
                'bk.book_type_Code ,
                ah.category_id,
                cf.description ,
                ad.tag_number ,
                ad.parent_asset_id ,
                ad.serial_number ,
                ad.asset_key_ccid ,
                bk.life_in_months ,
                bk.date_placed_in_service ,
                bk.deprn_method_code ,
                dh.location_id ,
                cb.deprn_reserve_acct ,
                cb.asset_cost_acct, ' ||
                balancing_seg_no    || ', ' ||
                cost_ctr_seg_no     || ', ' ||
                account_seg_no      || ', ' ||
                major_cat_seg_no;

        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'after select ');

        -- bug 3421784, start 12
        -- commenting out
        --     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_select_statement ' || l_select_statement);
        -- bug 3421784, end 12
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,' ** After l_select ** ');

        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_categoryId --> ' || p_categoryId);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_bookType   --> ' || p_bookType);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_period     --> ' || p_period);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_from_cc    --> ' || nvl(p_from_cc,1));
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_to_cc      --> ' || nvl(p_to_cc,1));
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_from_asset --> ' || nvl(p_from_asset,1));
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_to_asset   --> ' || nvl(p_to_asset,1));

        IF p_from_asset = 'NULL' THEN
            l_from_asset := NULL;
        ELSE
            l_from_asset := p_from_asset;
        END IF;

        IF p_to_asset = 'NULL' THEN
            l_to_asset := NULL;
        ELSE
            l_to_asset := p_to_asset;
        END IF;

        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_from_asset --> ' || nvl(l_from_asset,1));
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_to_asset   --> ' || nvl(l_to_asset,1));

        IF p_from_cc = 'NULL' THEN
            l_from_cc := NULL;
        ELSE
            l_from_cc := p_from_cc;
        END IF;

        IF p_to_cc = 'NULL' THEN
            l_to_cc := NULL;
        ELSE
            l_to_cc := p_to_cc;
        END IF;

        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_from_cc --> ' || nvl(l_from_cc,1));
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_to_cc   --> ' || nvl(l_to_cc,1));

        /* Bug 3490402 */
        OPEN ret_lines FOR l_select_statement USING p_bookType,       /* :v_bookType         */
                                               p_period,         /* :v_period           */
                                               l_from_cc,        /* :v_from_cc          */
                                               l_to_cc,          /* :v_to_cc,           */
                                               l_from_asset,     /* :v_from_asset       */
                                               l_to_asset,       /* :v_to_asset         */
                                               p_bookType,       /* :v_bookType1        */
                                               p_period,         /* :v_period1          */
                                               l_from_cc,        /* :v_from_cc1         */
                                               l_to_cc,          /* :v_to_cc1           */
                                               l_from_asset,     /* :v_from_asset1      */
                                               l_to_asset;       /* :v_to_asset1        */
        LOOP
        FETCH ret_lines INTO
            l_gl_code_seg1,
            l_gl_code_seg2,
            l_gl_code_seg3,
            l_fa_cat_seg1,
            l_fa_cat_seg2,
            l_book_code,
            l_asset_cat_id,
            l_CFDescription,
            l_asset_number,
            l_ADDescription,
            l_asset_tag,
            l_parent_id,
            l_serial_number,
            l_asset_key_ccid,
            l_life_in_months,
            l_date_placed_in_service,
            l_depreciation_method,
            l_location_id,
            l_depreciation_reserve_account,
            l_asset_cost_account,
            l_reval_cost,
            l_oper_exp,
            l_oper_exp_backlog,
            l_oper_exp_net;

        IF (ret_lines%NOTFOUND) THEN
            EXIT;
        END IF;

        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'after fetch ');

        /* StatReq - The following if statement has been added to calculate the annual depreciation rate
                for straight-line, calculated depreciation methods */

        -- Calculate STL_RATE from life_in_months
        IF (l_life_in_months > 0)
        THEN
            l_stl_rate := 12 / l_life_in_months * 100;
        ELSE
            l_stl_rate := NULL;
        END IF;

        -- This will get the CONCATANATED LOCATION
        fa_rx_shared_pkg.concat_location (
				struct_id => l_g_loc_struct
				,ccid => l_location_id
				,concat_string => l_concat_loc
				,segarray => l_loc_segs);

        -- This will get the CONCATANATED ASSETKEY
        fa_rx_shared_pkg.concat_asset_key (
				struct_id => l_g_asset_key_struct
				,ccid => l_asset_key_ccid
				,concat_string => l_concat_asset_key
				,segarray => l_asset_segs);

        -- This gets the CONCATENATED CATEGORY NAME
        fa_rx_shared_pkg.concat_category (
                                       struct_id       => l_g_cat_struct,
                                       ccid            => l_asset_cat_id,
                                       concat_string   => l_concat_cat,
                                       segarray        => l_cat_segs);

        /*IF NOT get_acct_seg_val_from_ccid ( p_bookType
					,l_asset_cat_id
					,l_dep_backlog
					,l_gen_fund_acct
					,l_oper_exp_acct
					,l_reval_rsv_acct
					)
        THEN
            igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'Failed to get Account segement values - will continue.... ');
        END IF;*/

        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_stl_rate ' || l_stl_rate);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_concat_loc ' || l_concat_loc);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_concat_asset_key ' || l_concat_asset_key);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_asset_cat_id ' || l_asset_cat_id);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_concat_cat ' || l_concat_cat);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_dep_backlog ' || l_dep_backlog);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_gen_fund_acct ' || l_gen_fund_acct);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_oper_exp_acct ' || l_oper_exp_acct);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_reval_rsv_acct ' || l_reval_rsv_acct);

        l_parent_no := NULL;
        IF l_parent_id IS NOT NULL THEN
            l_parent_no := l_asset_number;
        END IF;

        INSERT INTO igi_iac_asset_rep_itf (
                request_id,
                company_name,
                book_type_code,
                period,
                fiscal_year_name,
                major_category,
                cost_center,
                asset_number,
                asset_description,
                asset_tag,
                parent_no,
                serial_no,
                life_months,
                stl_rate,
                dpis,
                depreciation_method,
                conc_asset_key,
                conc_location,
                --deprn_exp_acct,
                --deprn_res_acct,
                cost_acct,
                --iac_reval_resv_acct,
                balancing_segment,
                --deprn_backlog_acct,
                --gen_fund_acct,
                --oper_exp_acct,
                concat_category,
                reval_cost,
                minor_category,
                oper_exp,
                oper_exp_backlog,
                oper_exp_net,
                functional_currency_code,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login
                )
        VALUES
        (
                p_request_id,
                l_company_name,
                l_book_code,
                l_period_name,
                l_fiscal_year_name,
                l_fa_cat_seg1,
                l_gl_code_seg2,
                l_asset_number,
                l_ADDescription,
                l_asset_tag,
                l_parent_no,
                l_serial_number,
                l_life_in_months,
                l_stl_rate,
                l_date_placed_in_service,
                l_depreciation_method,
                l_concat_asset_key,
                l_concat_loc,
                --l_gl_code_seg3,
                --l_depreciation_reserve_account,
                l_asset_cost_account,
                --l_reval_rsv_acct,
                l_gl_code_seg1,
                --l_dep_backlog,
                --l_gen_fund_acct,
                --l_oper_exp_acct,
                l_concat_cat,
                l_reval_cost,
                l_fa_cat_seg2,
                l_oper_exp,
                l_oper_exp_backlog,
                l_oper_exp_net,
                l_currency_code,
                l_user_id,
                sysdate,
                l_user_id,
                sysdate,
                p_login_id
                );

        END LOOP;
        CLOSE ret_lines;
        RETURN TRUE;

    EXCEPTION
        WHEN OTHERS THEN
        -- bug 3421784, start 13
        IF ret_lines%ISOPEN THEN
           CLOSE ret_lines;
        END IF;
        -- bug 3421784, end 13
        igi_iac_debug_pkg.debug_other_string(g_unexp_level,l_path,'Exception within run_d_operating_report: '|| sqlerrm);
        RETURN FALSE;
    END run_d_operating_report;

    FUNCTION run_s_reval_report    ( p_bookType	IN	VARCHAR2
				,p_period	IN	VARCHAR2
				,p_categoryId	IN	VARCHAR2
				,p_request_id	IN	NUMBER
				,l_user_id	IN	NUMBER
				,p_login_id	IN	VARCHAR2)
    RETURN BOOLEAN IS

        l_select_statement	VARCHAR2(15000);
        TYPE var_cur IS REF CURSOR;
        ret_lines	var_cur;

        l_cost_center		VARCHAR2(25);
        l_book_code		VARCHAR2(15);
        l_reval_cost		NUMBER;
        l_reval_resv_cost	NUMBER;
        l_reval_resv_blog	NUMBER;
        l_reval_resv_gen_fund	NUMBER;
        l_gen_fund		NUMBER;
        l_reval_resv_net	NUMBER;
        l_depr_reserve	NUMBER;
        l_oper_acct		NUMBER;
        l_backlog		NUMBER;
        l_gl_code_seg1	VARCHAR2(25);
        l_gl_code_seg2	VARCHAR2(25);
        l_gl_code_seg3   VARCHAR2(25);
        l_fa_cat_seg1		VARCHAR2(25);
        l_fa_cat_seg2		VARCHAR2(25);
        l_deprn_period	NUMBER;
        l_ytd_deprn		NUMBER;
        l_deprn_backlog	NUMBER;
        l_deprn_total		NUMBER;
        l_asset_cat_id	NUMBER(15);
        l_asset_tag				fa_additions.tag_number%TYPE;
        l_serial_number			fa_additions.serial_number%TYPE;
        l_life_in_months			fa_Books.life_in_months%TYPE;
        l_date_placed_in_service		fa_Books.date_placed_in_service%TYPE;
        l_depreciation_reserve_account	fa_category_books.deprn_reserve_acct%TYPE;
        l_depreciation_method		fa_Books.deprn_method_code%TYPE;
        l_location_id			fa_distribution_history.location_id%TYPE;
        l_asset_key_ccid         fa_asset_keywords.code_combination_id%TYPE;
        l_asset_cost_account			fa_category_books.asset_cost_acct%TYPE;
        l_deprn_res_acct	fa_category_books.deprn_reserve_acct%TYPE;
        l_dep_backlog	NUMBER;
        l_gen_fund_acct	NUMBER;
        l_oper_exp_acct	NUMBER;
        l_reval_rsv_acct	NUMBER;
        l_concat_loc		VARCHAR2(200);
        l_concat_asset_key	VARCHAR2(200);
        l_concat_cat         VARCHAR2(500);
        l_loc_segs		fa_rx_shared_pkg.Seg_Array;
        l_asset_segs		fa_rx_shared_pkg.Seg_Array;
        l_cat_segs           fa_rx_shared_pkg.Seg_Array;
        l_stl_rate		NUMBER;
        l_CFDescription	VARCHAR2(40);
        l_path 		VARCHAR2(150);

    BEGIN
        l_path 		:= g_path||'run_s_reval_report';
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,' ** START  run_s_reval_report ** ');

        l_select_statement := 'SELECT ' ||
                balancing_seg_no    || ', ' ||
                cost_ctr_seg_no     || ', ' ||
                account_seg_no      || ', ' ||
                major_cat_seg_no    || ', ' ||
                minor_cat_seg_no    || ', ' ||
                'bk.book_type_Code book_type_code,
                ah.category_id category_id,
                cf.description category_description,
                ad.asset_key_ccid asset_key_ccid,
                bk.deprn_method_code depreciation_method,
                dh.location_id location_id,
                cb.deprn_reserve_acct depreciation_reserve_account,
                cb.asset_cost_acct asset_cost_account,
                sum(nvl(dd.cost,0))  Reval_Cost,
                0  Reval_Reserve_Cost,
                0  Reval_Reserve_Backlog,
                0  Reval_Reserve_Gen_Fund,
                0  Reval_Reserve_Net
        FROM fa_additions ad,
                fa_Books bk,
                fa_distribution_history dh,
                fa_deprn_Detail dd,
                gl_code_combinations cc,
                fa_categories cf,
                fa_category_books cb,
                fa_book_controls fb,
                fa_deprn_periods fdp,
                fa_asset_history ah
        WHERE ad.asset_id = bk.asset_id
        AND  ah.asset_id = bk.asset_id
        AND  cf.category_id=ah.category_id
        AND   cb.category_id = ah.category_id
        AND cf.category_id = ' || p_categoryId || '
        AND bk.book_type_code = :v_bookType
        AND fdp.book_type_code = bk.book_type_code
        AND fdp.period_counter = :v_period
        AND   nvl(bk.period_counter_fully_retired,fdp.period_counter+1) > fdp.period_counter
        AND     bk.transaction_header_id_in = (SELECT max(ifb.transaction_header_id_in)
                                                FROM fa_books ifb
                                                WHERE ifb.book_type_code = bk.book_type_code
                                                AND ifb.asset_id = bk.asset_id
                                                AND ifb.date_effective < nvl(fdp.period_close_date,sysdate))
        AND dd.asset_id = bk.asset_id
        AND dd.book_type_code = bk.book_type_code
        AND cb.book_type_code = bk.book_type_code
        AND dh.distribution_id = dd.distribution_id
        AND  nvl(dh.date_ineffective,sysdate) >= nvl(fdp.period_close_date,sysdate)
        AND   dh.transaction_header_id_in >= ah.transaction_header_id_in
        AND   dh.transaction_header_id_in < nvl(ah.transaction_header_id_out,dh.transaction_header_id_in+1)
        AND dh.code_combination_id = cc.code_combination_id
        AND fb.book_type_code = bk.book_type_code
        AND dd.period_counter =
                (SELECT max(period_counter)
                FROM fa_deprn_summary
                WHERE asset_id = bk.asset_id
                AND book_type_code = bk.book_type_code
                AND period_counter <= fdp.period_counter)
        AND bk.asset_id not in
                (SELECT asset_id
                FROM igi_iac_asset_balances
                WHERE book_type_code = bk.book_type_code
                AND asset_id = bk.asset_id)
        GROUP BY ' || balancing_seg_no    || ', ' ||
                cost_ctr_seg_no     || ', ' ||
                account_seg_no      || ', ' ||
                'bk.book_type_code,
                ah.category_id,
                cf.description,
                ad.asset_key_ccid, ' ||
                major_cat_seg_no    || ', ' ||
                minor_cat_seg_no    || ', ' ||
                'bk.deprn_method_code ,
                dh.location_id ,
                cb.deprn_reserve_acct ,
                cb.asset_cost_acct ' ||

        ' UNION
        SELECT ' ||
                balancing_seg_no    || ', ' ||
                cost_ctr_seg_no     || ', ' ||
                account_seg_no      || ', ' ||
                major_cat_seg_no    || ', ' ||
                minor_cat_seg_no    || ', ' ||
                'bk.book_type_Code book_type_code ,
                ah.category_id category_id,
                cf.description category_description,
                ad.asset_key_ccid asset_key_ccid,
                bk.deprn_method_code depreciation_method,
                dh.location_id location_id,
                cb.deprn_reserve_acct depreciation_reserve_account,
                cb.asset_cost_acct asset_cost_account,
                sum (nvl((id.adjustment_cost + dd.cost), 0))  Reval_Cost,
                sum(nvl(id.reval_reserve_cost, 0) )   Reval_Reserve_Cost,
                sum(nvl(id.reval_reserve_backlog, 0) )   Reval_Reserve_Backlog,
                sum(nvl(id.reval_reserve_gen_fund, 0))   Reval_Reserve_Gen_Fund,
                sum(nvl(id.reval_reserve_net, 0) )   Reval_Reserve_Net
        FROM    fa_additions ad ,
                fa_Books bk ,
                fa_distribution_history dh         ,
                fa_deprn_Detail dd ,
                igi_iac_det_balances id ,
                gl_code_combinations cc,
                fa_categories cf,
                fa_category_books cb,
                fa_book_controls fb,
                fa_deprn_periods fdp,
                fa_asset_history ah
        WHERE   ad.asset_id = dh.asset_id
        AND  ah.asset_id = bk.asset_id
        AND  cf.category_id=ah.category_id
        AND   cb.category_id = ah.category_id
        AND cf.category_id = ' || p_categoryId || '
        AND     bk.book_Type_code = :v_bookType1
        AND fdp.book_type_code = bk.book_type_code
        AND fdp.period_counter = :v_period1
        AND   nvl(bk.period_counter_fully_retired,fdp.period_counter+1) > fdp.period_counter
        AND     bk.transaction_header_id_in = (SELECT max(ifb.transaction_header_id_in)
                                                FROM fa_books ifb
                                                WHERE ifb.book_type_code = bk.book_type_code
                                                AND ifb.asset_id = bk.asset_id
                                                AND ifb.date_effective < nvl(fdp.period_close_date,sysdate))
        AND    bk.asset_id = ad.asset_id
        AND     dh.book_type_Code = bk.book_type_code
        AND    dh.book_type_code = dd.book_type_code
        AND     cb.book_type_Code = bk.book_type_code
        AND   dh.asset_id  = dd.asset_id
        AND   dh.distribution_id = dd.distribution_id
        AND  nvl(dh.date_ineffective,sysdate) >= nvl(fdp.period_close_date,sysdate)
        AND   dh.transaction_header_id_in >= ah.transaction_header_id_in
        AND   dh.transaction_header_id_in < nvl(ah.transaction_header_id_out,dh.transaction_header_id_in+1)
        AND   fb.book_type_code = bk.book_type_code
        AND   dd.period_counter = (SELECT MAX(period_counter)
                                    FROM fa_deprn_summary
                                    WHERE asset_id =bk.asset_id
                                    AND book_type_code = bk.book_type_code
                                    AND period_counter <= fdp.period_counter )
        AND     dh.distribution_id = id.distribution_id
        AND     dh.code_Combination_id = cc.code_combination_id
        AND     id.adjustment_id =       ( SELECT max(adjustment_id)
                                    FROM  igi_iac_transaction_headers it
                                    WHERE it.asset_id = bk.asset_id
                                    AND   it.book_type_code = bk.book_type_Code
                                    AND it.period_counter <= fdp.period_counter
                                    AND adjustment_status not in (''PREVIEW'', ''OBSOLETE''))
        GROUP BY ' || balancing_seg_no    || ', ' ||
                cost_ctr_seg_no     || ', ' ||
                account_seg_no      || ', ' ||
                'bk.book_type_Code ,
                ah.category_id,
                cf.description,
                ad.asset_key_ccid, '  ||
                major_cat_seg_no   || ', ' ||
                minor_cat_seg_no   || ', ' ||
                'bk.deprn_method_code ,
                dh.location_id ,
                cb.deprn_reserve_acct ,
                cb.asset_cost_acct';

        -- bug 3421784, start 14
        -- commenting out
        --     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_select_statement ' || l_select_statement);
        -- bug 3421784, end 14

        /* Bug 3490402 */
        OPEN ret_lines FOR l_select_statement USING p_bookType,      /* :v_bookType    */
                                               p_period,        /* :v_period      */
                                               p_bookType,      /* :v_bookType1   */
                                               p_period;        /* :v_period1     */

        LOOP
        FETCH ret_lines INTO
                l_gl_code_seg1,
                l_gl_code_seg2,
                l_gl_code_seg3,
                l_fa_cat_seg1,
                l_fa_cat_seg2,
                l_book_code,
                l_asset_cat_id,
                l_CFDescription,
                l_asset_key_ccid,
                l_depreciation_method,
                l_location_id,
                l_depreciation_reserve_account,
                l_asset_cost_account,
                l_reval_cost,
                l_reval_resv_cost,
                l_reval_resv_blog,
                l_reval_resv_gen_fund,
                l_reval_resv_net;

        IF (ret_lines%NOTFOUND) THEN
            EXIT;
        END IF;

        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'after fetch ');

        -- This will get the CONCATANATED LOCATION
        fa_rx_shared_pkg.concat_location (
				struct_id => l_g_loc_struct
				,ccid => l_location_id
				,concat_string => l_concat_loc
				,segarray => l_loc_segs);

        -- This will get the CONCATANATED ASSETKEY
        fa_rx_shared_pkg.concat_asset_key (
				struct_id => l_g_asset_key_struct
				,ccid => l_asset_key_ccid
				,concat_string => l_concat_asset_key
				,segarray => l_asset_segs);



        -- This gets the CONCATENATED CATEGORY NAME
        fa_rx_shared_pkg.concat_category (
                                       struct_id       => l_g_cat_struct,
                                       ccid            => l_asset_cat_id,
                                       concat_string   => l_concat_cat,
                                       segarray        => l_cat_segs);

        /*IF NOT get_acct_seg_val_from_ccid ( p_bookType
					,l_asset_cat_id
					,l_dep_backlog
					,l_gen_fund_acct
					,l_oper_exp_acct
					,l_reval_rsv_acct
					)
        THEN
            igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'Failed to get Account segement values - will continue.... ');
        END IF;*/
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_stl_rate ' || l_stl_rate);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_concat_loc ' || l_concat_loc);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_concat_asset_key ' || l_concat_asset_key);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_asset_cat_id ' || l_asset_cat_id);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_concat_cat ' || l_concat_cat);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_dep_backlog ' || l_dep_backlog);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_gen_fund_acct ' || l_gen_fund_acct);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_oper_exp_acct ' || l_oper_exp_acct);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_reval_rsv_acct ' || l_reval_rsv_acct);

        INSERT INTO igi_iac_asset_rep_itf (
                request_id,
                company_name,
                book_type_code,
                period,
                fiscal_year_name,
                major_category,
                cost_center,
                depreciation_method,
                conc_asset_key,
                conc_location,
                --deprn_exp_acct,
                --deprn_res_acct,
                cost_acct,
                --iac_reval_resv_acct,
                balancing_segment,
                --deprn_backlog_acct,
                --gen_fund_acct,
                --oper_exp_acct,
                concat_category,
                reval_cost,
                minor_category,
                reval_resv_cost,
                reval_resv_blog,
                reval_resv_gen_fund,
                reval_resv_net,
                functional_currency_code,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login
                )
        VALUES
        (
                p_request_id,
                l_company_name,
                l_book_code,
                l_period_name,
                l_fiscal_year_name,
                l_fa_cat_seg1,
                l_gl_code_seg2,
                l_depreciation_method,
                l_concat_asset_key,
                l_concat_loc,
                --l_gl_code_seg3,
                --l_depreciation_reserve_account,
                l_asset_cost_account,
                --l_reval_rsv_acct,
                l_gl_code_seg1,
                --l_dep_backlog,
                --l_gen_fund_acct,
                --l_oper_exp_acct,
                l_concat_cat,
                l_reval_cost,
                l_fa_cat_seg2,
                l_reval_resv_cost,
                l_reval_resv_blog,
                l_reval_resv_gen_fund,
                l_reval_resv_net,
                l_currency_code,
                l_user_id,
                sysdate,
                l_user_id,
                sysdate,
                p_login_id
                );

    END LOOP;
    CLOSE ret_lines;
    RETURN TRUE;

    EXCEPTION
        WHEN OTHERS THEN
        -- bug 3421784, start 15
        IF ret_lines%ISOPEN THEN
            CLOSE ret_lines;
        END IF;
        -- bug 3421784, end 15
        igi_iac_debug_pkg.debug_other_string(g_unexp_level,l_path,'Exception within run_s_reval_report : '|| sqlerrm);
        RETURN FALSE;
    END run_s_reval_report;

    FUNCTION run_d_reval_report    ( p_bookType	IN	VARCHAR2
				,p_period	IN	VARCHAR2
				,p_categoryId	IN	VARCHAR2
				,p_from_cc	IN	VARCHAR2
				,p_to_cc	IN	VARCHAR2
				,p_from_asset	IN	VARCHAR2
				,p_to_asset	IN	VARCHAR2
				,p_request_id	IN	NUMBER
				,l_user_id	IN	NUMBER
				,p_login_id	IN	VARCHAR2)
    RETURN BOOLEAN IS

    l_select_statement	VARCHAR2(15000);
    TYPE var_cur IS REF CURSOR;
    ret_lines	var_cur;

        l_cost_center		VARCHAR2(25);
        l_book_code		VARCHAR2(15);
        l_reval_cost		NUMBER;
        l_reval_resv_cost	NUMBER;
        l_reval_resv_blog	NUMBER;
        l_reval_resv_gen_fund	NUMBER;
        l_gen_fund		NUMBER;
        l_reval_resv_net	NUMBER;
        l_depr_reserve	NUMBER;
        l_oper_acct		NUMBER;
        l_backlog		NUMBER;
        l_asset_number	VARCHAR2(15);
        l_gl_code_seg1	VARCHAR2(25);
        l_gl_code_seg2	VARCHAR2(25);
        l_gl_code_seg3   VARCHAR2(25);
        l_fa_cat_seg1		VARCHAR2(25);
        l_fa_cat_seg2		VARCHAR2(25);
        l_deprn_period	NUMBER;
        l_ytd_deprn		NUMBER;
        l_deprn_backlog	NUMBER;
        l_deprn_total		NUMBER;
        l_asset_cat_id	NUMBER(15);
        l_asset_tag				fa_additions.tag_number%TYPE;
        l_parent_id                          fa_additions.parent_asset_id%TYPE;
        l_parent_no                          VARCHAR2(15);
        l_serial_number			fa_additions.serial_number%TYPE;
        l_life_in_months			fa_Books.life_in_months%TYPE;
        l_date_placed_in_service		fa_Books.date_placed_in_service%TYPE;
        l_depreciation_reserve_account	fa_category_books.deprn_reserve_acct%TYPE;
        l_depreciation_method		fa_Books.deprn_method_code%TYPE;
        l_location_id			fa_distribution_history.location_id%TYPE;
        l_asset_key_ccid         fa_asset_keywords.code_combination_id%TYPE;
        l_asset_cost_account			fa_category_books.asset_cost_acct%TYPE;
        l_deprn_res_acct	fa_category_books.deprn_reserve_acct%TYPE;
        l_dep_backlog	NUMBER;
        l_gen_fund_acct	NUMBER;
        l_oper_exp_acct	NUMBER;
        l_reval_rsv_acct	NUMBER;
        l_concat_loc		VARCHAR2(240);
        l_concat_asset_key	VARCHAR2(240);
        l_concat_cat         VARCHAR2(600);
        l_loc_segs		fa_rx_shared_pkg.Seg_Array;
        l_asset_segs		fa_rx_shared_pkg.Seg_Array;
        l_cat_segs           fa_rx_shared_pkg.Seg_Array;
        l_stl_rate		NUMBER;
        l_CFDescription	VARCHAR2(40);
        l_ADDescription	fa_additions.description%type;
        l_from_asset         VARCHAR2(100);
        l_to_asset           VARCHAR2(100);
        l_from_cc            VARCHAR2(100);
        l_to_cc              VARCHAR2(100);
        l_path		VARCHAR2(150);

    BEGIN
        l_path		:= g_path||'run_d_reval_report';
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,' ** START  run_d_reval_report ** ');

        l_select_statement := 'SELECT ' ||
                balancing_seg_no    || ', ' ||
                cost_ctr_seg_no     || ', ' ||
                account_seg_no      || ', ' ||
                major_cat_seg_no    || ', ' ||
                minor_cat_seg_no    || ', ' ||
                'bk.book_type_Code book_type_code,
                ah.category_id category_id,
                cf.description category_description,
                ad.asset_number asset_number,
                ad.description asset_description,
                ad.tag_number asset_tag,
                ad.parent_asset_id parent_id,
                ad.serial_number serial_number,
                ad.asset_key_ccid asset_key_ccid,
                bk.life_in_months life_in_months,
                bk.date_placed_in_service date_placed_in_service,
                bk.deprn_method_code depreciation_method,
                dh.location_id location_id,
                cb.deprn_reserve_acct depreciation_reserve_account,
                cb.asset_cost_acct asset_cost_account,
                sum(nvl(dd.cost,0))  Reval_Cost,
                0  Reval_Reserve_Cost,
                0  Reval_Reserve_Backlog,
                0  Reval_Reserve_Gen_Fund,
                0  Reval_Reserve_Net
        FROM fa_additions ad,
            fa_Books bk,
            fa_distribution_history dh,
            fa_deprn_Detail dd,
            gl_code_combinations cc,
            fa_categories cf,
            fa_category_books cb,
            fa_book_controls fb,
                fa_deprn_periods fdp,
                fa_asset_history ah
        WHERE ad.asset_id = bk.asset_id
        AND  ah.asset_id = bk.asset_id
        AND  cf.category_id=ah.category_id
        AND   cb.category_id = ah.category_id
        AND cf.category_id = ' || p_categoryId || '
        AND bk.book_type_code = :v_bookType
        AND fdp.book_type_code = bk.book_type_code
        AND fdp.period_counter = :v_period
        AND   nvl(bk.period_counter_fully_retired,fdp.period_counter+1) > fdp.period_counter
        AND     bk.transaction_header_id_in = (SELECT max(ifb.transaction_header_id_in)
                                                FROM fa_books ifb
                                                WHERE ifb.book_type_code = bk.book_type_code
                                                AND ifb.asset_id = bk.asset_id
                                                AND ifb.date_effective < nvl(fdp.period_close_date,sysdate))
        AND dd.asset_id = bk.asset_id
        AND dd.book_type_code = bk.book_type_code
        AND cb.book_type_code = bk.book_type_code
        AND dh.distribution_id = dd.distribution_id
        AND  nvl(dh.date_ineffective,sysdate) >= nvl(fdp.period_close_date,sysdate)
        AND   dh.transaction_header_id_in >= ah.transaction_header_id_in
        AND   dh.transaction_header_id_in < nvl(ah.transaction_header_id_out,dh.transaction_header_id_in+1)
        AND dh.code_combination_id = cc.code_combination_id
        AND fb.book_type_code = bk.book_type_code
        AND dd.period_counter =
                (SELECT max(period_counter)
                FROM fa_deprn_summary
                WHERE asset_id = bk.asset_id
                AND book_type_code = bk.book_type_code
                AND period_counter <= fdp.period_counter)
        AND bk.asset_id not in
                (SELECT asset_id
                FROM igi_iac_asset_balances
                WHERE book_type_code = bk.book_type_code
                AND asset_id = bk.asset_id)
        AND ' || cost_ctr_seg_no || ' between nvl( :v_from_cc, ' || cost_ctr_seg_no || ' )
        AND nvl( :v_to_cc,' || cost_ctr_seg_no || ')
        AND ad.asset_number between nvl( :v_from_asset, ad.asset_number)
        AND  nvl( :v_to_asset, ad.asset_number)
        GROUP BY  ad.asset_number,
                ad.description , ' ||
                balancing_seg_no    || ', ' ||
                cost_ctr_seg_no     || ', ' ||
                account_seg_no      || ', ' ||
                'bk.book_type_code,
                ah.category_id,
                cf.description, ' ||
                major_cat_seg_no    || ', ' ||
                minor_cat_seg_no    || ', ' ||
                'ad.tag_number ,
                ad.parent_asset_id ,
                ad.serial_number ,
                ad.asset_key_ccid ,
                bk.life_in_months ,
                bk.date_placed_in_service ,
                bk.deprn_method_code ,
                dh.location_id ,
                cb.deprn_reserve_acct ,
                cb.asset_cost_acct ' ||

        ' UNION
        SELECT ' ||
                balancing_seg_no    || ', ' ||
                cost_ctr_seg_no     || ', ' ||
                account_seg_no      || ', ' ||
                major_cat_seg_no    || ', ' ||
                minor_cat_seg_no    || ', ' ||
                'bk.book_type_Code book_type_code ,
                ah.category_id category_id,
                cf.description category_description,
                ad.asset_number asset_number ,
                ad.description asset_description,
                ad.tag_number asset_tag,
                ad.parent_asset_id parent_id,
                ad.serial_number serial_number,
                ad.asset_key_ccid asset_key_ccid,
                bk.life_in_months life_in_months,
                bk.date_placed_in_service date_placed_in_service,
                bk.deprn_method_code depreciation_method,
                dh.location_id location_id,
                cb.deprn_reserve_acct depreciation_reserve_account,
                cb.asset_cost_acct asset_cost_account,
                sum (nvl((id.adjustment_cost + dd.cost), 0))  Reval_Cost,
                sum(nvl(id.reval_reserve_cost, 0) )   Reval_Reserve_Cost,
                sum(nvl(id.reval_reserve_backlog, 0) )   Reval_Reserve_Backlog,
                sum(nvl(id.reval_reserve_gen_fund, 0))   Reval_Reserve_Gen_Fund,
                sum(nvl(id.reval_reserve_net, 0) )   Reval_Reserve_Net
        FROM    fa_additions ad ,
                fa_Books bk ,
                fa_distribution_history dh         ,
                fa_deprn_Detail dd ,
                igi_iac_det_balances id ,
                gl_code_combinations cc,
                fa_categories cf,
                fa_category_books cb,
                fa_book_controls fb,
                fa_deprn_periods fdp,
                fa_asset_history ah
        WHERE   ad.asset_id = dh.asset_id
        AND  ah.asset_id = bk.asset_id
        AND  cf.category_id=ah.category_id
        AND   cb.category_id = ah.category_id
        AND cf.category_id = ' || p_categoryId || '
        AND     bk.book_Type_code = :v_bookType1
        AND fdp.book_type_code = bk.book_type_code
        AND fdp.period_counter = :v_period1
        AND   nvl(bk.period_counter_fully_retired,fdp.period_counter+1) > fdp.period_counter
        AND     bk.transaction_header_id_in = (SELECT max(ifb.transaction_header_id_in)
                                                FROM fa_books ifb
                                                WHERE ifb.book_type_code = bk.book_type_code
                                                AND ifb.asset_id = bk.asset_id
                                                AND ifb.date_effective < nvl(fdp.period_close_date,sysdate))
        AND    bk.asset_id = ad.asset_id
        AND     dh.book_type_Code = bk.book_type_code
        AND    dh.book_type_code = dd.book_type_code
        AND     cb.book_type_Code = bk.book_type_code
        AND   dh.asset_id  = dd.asset_id
        AND   dh.distribution_id = dd.distribution_id
        AND  nvl(dh.date_ineffective,sysdate) >= nvl(fdp.period_close_date,sysdate)
        AND   dh.transaction_header_id_in >= ah.transaction_header_id_in
        AND   dh.transaction_header_id_in < nvl(ah.transaction_header_id_out,dh.transaction_header_id_in+1)
        AND   fb.book_type_code = bk.book_type_code
        AND   dd.period_counter = (SELECT MAX(period_counter)
                                    FROM fa_deprn_summary
                                    WHERE asset_id =bk.asset_id
                                    AND book_type_code = bk.book_type_code
                                    AND period_counter <= fdp.period_counter )
        AND     dh.distribution_id = id.distribution_id
        AND     dh.code_Combination_id = cc.code_combination_id
        AND     id.adjustment_id =       ( SELECT max(adjustment_id)
                                    FROM  igi_iac_transaction_headers it
                                    WHERE it.asset_id = bk.asset_id
                                    AND   it.book_type_code = bk.book_type_Code
                                    AND it.period_counter <= fdp.period_counter
                                    AND adjustment_status not in (''PREVIEW'', ''OBSOLETE''))
        AND ' || cost_ctr_seg_no || ' between nvl( :v_from_cc1, ' || cost_ctr_seg_no || ' )
        AND nvl( :v_to_cc1,' || cost_ctr_seg_no || ')
        AND ad.asset_number between nvl( :v_from_asset1, ad.asset_number)
        AND  nvl( :v_to_asset1, ad.asset_number)
        GROUP BY ad.asset_number ,
                ad.description , ' ||
                balancing_seg_no    || ', ' ||
                cost_ctr_seg_no     || ', ' ||
                account_seg_no      || ', ' ||
                'bk.book_type_Code ,
                ah.category_id,
                cf.description, '  ||
                major_cat_seg_no   || ', ' ||
                minor_cat_seg_no   || ', ' ||
                'ad.tag_number ,
                ad.parent_asset_id ,
                ad.serial_number ,
                ad.asset_key_ccid ,
                bk.life_in_months ,
                bk.date_placed_in_service ,
                bk.deprn_method_code ,
                dh.location_id ,
                cb.deprn_reserve_acct ,
                cb.asset_cost_acct' ;

        -- bug 3421784, start 16
        -- commenting out
        --     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_select_statement ' || l_select_statement);
        -- bug 3421784, end 16

        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,' ** After l_select ** ');
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_categoryId --> ' || p_categoryId);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_bookType   --> ' || p_bookType);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_period     --> ' || p_period);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_from_cc    --> ' || nvl(p_from_cc,1));
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_to_cc      --> ' || nvl(p_to_cc,1));
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_from_asset --> ' || nvl(p_from_asset,1));
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_to_asset   --> ' || nvl(p_to_asset,1));

        IF p_from_asset = 'NULL' THEN
            l_from_asset := NULL;
        ELSE
            l_from_asset := p_from_asset;
        END IF;

        IF p_to_asset = 'NULL' THEN
            l_to_asset := NULL;
        ELSE
            l_to_asset := p_to_asset;
        END IF;

        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_from_asset --> ' || nvl(l_from_asset,1));
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_to_asset   --> ' || nvl(l_to_asset,1));

        IF p_from_cc = 'NULL' THEN
            l_from_cc := NULL;
        ELSE
            l_from_cc := p_from_cc;
        END IF;

        IF p_to_cc = 'NULL' THEN
            l_to_cc := NULL;
        ELSE
            l_to_cc := p_to_cc;
        END IF;

        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_from_cc --> ' || nvl(l_from_cc,1));
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_to_cc   --> ' || nvl(l_to_cc,1));

        /* Bug 3490402 */
        OPEN ret_lines FOR l_select_statement USING p_bookType,       /* :v_bookType         */
                                               p_period,         /* :v_period           */
                                               l_from_cc,        /* :v_from_cc          */
                                               l_to_cc,          /* :v_to_cc,           */
                                               l_from_asset,     /* :v_from_asset       */
                                               l_to_asset,       /* :v_to_asset         */
                                               p_bookType,       /* :v_bookType1        */
                                               p_period,         /* :v_period1          */
                                               l_from_cc,        /* :v_from_cc1         */
                                               l_to_cc,          /* :v_to_cc1           */
                                               l_from_asset,     /* :v_from_asset1      */
                                               l_to_asset;       /* :v_to_asset1        */
        LOOP
        FETCH ret_lines INTO
                l_gl_code_seg1,
                l_gl_code_seg2,
                l_gl_code_seg3,
                l_fa_cat_seg1,
                l_fa_cat_seg2,
                l_book_code,
                l_asset_cat_id,
                l_CFDescription,
                l_asset_number,
                l_ADDescription,
                l_asset_tag,
                l_parent_id,
                l_serial_number,
                l_asset_key_ccid,
                l_life_in_months,
                l_date_placed_in_service,
                l_depreciation_method,
                l_location_id,
                l_depreciation_reserve_account,
                l_asset_cost_account,
                l_reval_cost,
                l_reval_resv_cost,
                l_reval_resv_blog,
                l_reval_resv_gen_fund,
                l_reval_resv_net;

        IF (ret_lines%NOTFOUND) THEN
            EXIT;
        END IF;

        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'after fetch ');
        /* StatReq - The following if statement has been added to calculate the annual depreciation rate
                for straight-line, calculated depreciation methods */

        -- Calculate STL_RATE from life_in_months
        IF (l_life_in_months > 0)
        THEN
            l_stl_rate := 12 / l_life_in_months * 100;
        ELSE
            l_stl_rate := NULL;
        END IF;

        -- This will get the CONCATANATED LOCATION
        fa_rx_shared_pkg.concat_location (
				struct_id => l_g_loc_struct
				,ccid => l_location_id
				,concat_string => l_concat_loc
				,segarray => l_loc_segs);

        -- This will get the CONCATANATED ASSETKEY
        fa_rx_shared_pkg.concat_asset_key (
				struct_id => l_g_asset_key_struct
				,ccid => l_asset_key_ccid
				,concat_string => l_concat_asset_key
				,segarray => l_asset_segs);

        -- This gets the CONCATENATED CATEGORY NAME
        fa_rx_shared_pkg.concat_category (
                                       struct_id       => l_g_cat_struct,
                                       ccid            => l_asset_cat_id,
                                       concat_string   => l_concat_cat,
                                       segarray        => l_cat_segs);

        /*IF NOT get_acct_seg_val_from_ccid ( p_bookType
					,l_asset_cat_id
					,l_dep_backlog
					,l_gen_fund_acct
					,l_oper_exp_acct
					,l_reval_rsv_acct
					)
        THEN
            igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'Failed to get Account segement values - will continue.... ');
        END IF;*/
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_stl_rate ' || l_stl_rate);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_concat_loc ' || l_concat_loc);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_concat_asset_key ' || l_concat_asset_key);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_asset_cat_id ' || l_asset_cat_id);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_concat_cat ' || l_concat_cat);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_dep_backlog ' || l_dep_backlog);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_gen_fund_acct ' || l_gen_fund_acct);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_oper_exp_acct ' || l_oper_exp_acct);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_reval_rsv_acct ' || l_reval_rsv_acct);

        l_parent_no := NULL;

        IF l_parent_id IS NOT NULL THEN
            l_parent_no := l_asset_number;
        END IF;

        INSERT INTO igi_iac_asset_rep_itf (
                request_id,
                company_name,
                book_type_code,
                period,
                fiscal_year_name,
                major_category,
                cost_center,
                asset_number,
                asset_description,
                asset_tag,
                parent_no,
                serial_no,
                life_months,
                stl_rate,
                dpis,
                depreciation_method,
                conc_asset_key,
                conc_location,
                --deprn_exp_acct,
                --deprn_res_acct,
                cost_acct,
                --iac_reval_resv_acct,
                balancing_segment,
                --deprn_backlog_acct,
                --gen_fund_acct,
                --oper_exp_acct,
                concat_category,
                reval_cost,
                minor_category,
                reval_resv_cost,
                reval_resv_blog,
                reval_resv_gen_fund,
                reval_resv_net,
                functional_currency_code,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login
                )
        VALUES
        (
                p_request_id,
                l_company_name,
                l_book_code,
                l_period_name,
                l_fiscal_year_name,
                l_fa_cat_seg1,
                l_gl_code_seg2,
                l_asset_number,
                l_ADDescription,
                l_asset_tag,
                l_parent_no,
                l_serial_number,
                l_life_in_months,
                l_stl_rate,
                l_date_placed_in_service,
                l_depreciation_method,
                l_concat_asset_key,
                l_concat_loc,
                --l_gl_code_seg3,
                --l_depreciation_reserve_account,
                l_asset_cost_account,
                --l_reval_rsv_acct,
                l_gl_code_seg1,
                --l_dep_backlog,
                --l_gen_fund_acct,
                --l_oper_exp_acct,
                l_concat_cat,
                l_reval_cost,
                l_fa_cat_seg2,
                l_reval_resv_cost,
                l_reval_resv_blog,
                l_reval_resv_gen_fund,
                l_reval_resv_net,
                l_currency_code,
                l_user_id,
                sysdate,
                l_user_id,
                sysdate,
                p_login_id
                );

        END LOOP;
        CLOSE ret_lines;
        RETURN TRUE;

    EXCEPTION
        WHEN OTHERS THEN
        -- bug 3421784, start 17
        IF ret_lines%ISOPEN THEN
            CLOSE ret_lines;
        END IF;
        -- bug 3421784, end 17
        igi_iac_debug_pkg.debug_other_string(g_unexp_level,l_path,'Exception within run_d_reval_report : '|| sqlerrm);
        RETURN FALSE;
    END run_d_reval_report;

    FUNCTION run_s_summary_report  ( p_bookType	IN	VARCHAR2
				,p_period	IN	VARCHAR2
				,p_categoryId	IN	VARCHAR2
				,p_request_id	IN	NUMBER
				,l_user_id	IN	NUMBER
				,p_login_id	IN	VARCHAR2)
    RETURN BOOLEAN IS

        l_select_statement	VARCHAR2(15000);
        TYPE var_cur	IS REF CURSOR;
        ret_lines	var_cur;

        l_cost_center		VARCHAR2(25);
        l_book_code		VARCHAR2(15);
        l_reval_cost		NUMBER;
        l_reval_reserve	NUMBER;
        l_general_fund	NUMBER;
        l_oper_acct		NUMBER;
        l_deprn_resv		NUMBER;
        l_backlog		NUMBER;
        l_gl_code_seg1	VARCHAR2(25);
        l_gl_code_seg2	VARCHAR2(25);
        l_gl_code_seg3   VARCHAR2(25);
        l_fa_cat_seg1		VARCHAR2(25);
        l_fa_cat_seg2		VARCHAR2(25);
        l_deprn_period	NUMBER;
        l_ytd_deprn		NUMBER;
        l_deprn_backlog	NUMBER;
        l_deprn_total		NUMBER;
        l_asset_cat_id	NUMBER(15);
        l_asset_tag				fa_additions.tag_number%TYPE;
        l_serial_number			fa_additions.serial_number%TYPE;
        l_life_in_months			fa_Books.life_in_months%TYPE;
        l_date_placed_in_service		fa_Books.date_placed_in_service%TYPE;
        l_depreciation_reserve_account	fa_category_books.deprn_reserve_acct%TYPE;
        l_depreciation_method		fa_Books.deprn_method_code%TYPE;
        l_location_id			fa_distribution_history.location_id%TYPE;
        l_asset_key_ccid         fa_asset_keywords.code_combination_id%TYPE;
        l_asset_cost_account			fa_category_books.asset_cost_acct%TYPE;
        l_deprn_res_acct	fa_category_books.deprn_reserve_acct%TYPE;
        l_dep_backlog	NUMBER;
        l_gen_fund_acct	NUMBER;
        l_oper_exp_acct	NUMBER;
        l_reval_rsv_acct	NUMBER;
        l_concat_loc		VARCHAR2(200);
        l_concat_asset_key	VARCHAR2(200);
        l_concat_cat         VARCHAR2(500);
        l_loc_segs		fa_rx_shared_pkg.Seg_Array;
        l_asset_segs		fa_rx_shared_pkg.Seg_Array;
        l_cat_segs           fa_rx_shared_pkg.Seg_Array;
        l_stl_rate		NUMBER;
        l_CFDescription	VARCHAR2(40);
        l_path		VARCHAR2(150);

    BEGIN
        l_path		:= g_path||'run_s_summary_report';
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,' ** START  run_s_summary_report ** ');

        l_select_statement := 'SELECT ' ||
                balancing_seg_no    || ', ' ||
                cost_ctr_seg_no     || ', ' ||
                account_seg_no      || ', ' ||
                major_cat_seg_no    || ', ' ||
                minor_cat_seg_no    || ', ' ||
                'bk.book_type_Code book_type_code,
                ah.category_id category_id,
                cf.description category_description,
                ad.asset_key_ccid asset_key_ccid,
                bk.deprn_method_code depreciation_method,
                dh.location_id location_id,
                cb.deprn_reserve_acct depreciation_reserve_account,
                cb.asset_cost_acct asset_cost_account,
                sum(nvl(dd.cost,0))  Reval_Cost,
                0  Reval_Reserve,
                0  Gen_Fund,
                0  Operating_Acct,
                sum(nvl(dd.deprn_reserve,0)) Acct_Deprn,
                0  Backlog
        FROM fa_additions ad,
                fa_Books bk,
                fa_distribution_history dh,
                fa_deprn_Detail dd,
                gl_code_combinations cc,
                fa_categories cf,
                fa_category_books cb,
                fa_book_controls fb,
                fa_deprn_periods fdp,
                fa_asset_history ah
        WHERE ad.asset_id = bk.asset_id
        AND  ah.asset_id = bk.asset_id
        AND  cf.category_id=ah.category_id
        AND   cb.category_id = ah.category_id
        AND cf.category_id = ' || p_categoryId || '
        AND bk.book_type_code = :v_bookType
        AND fdp.book_type_code = bk.book_type_code
        AND fdp.period_counter = :v_period
        AND   nvl(bk.period_counter_fully_retired,fdp.period_counter+1) > fdp.period_counter
        AND     bk.transaction_header_id_in = (SELECT max(ifb.transaction_header_id_in)
                                                FROM fa_books ifb
                                                WHERE ifb.book_type_code = bk.book_type_code
                                                AND ifb.asset_id = bk.asset_id
                                                AND ifb.date_effective < nvl(fdp.period_close_date,sysdate))
        AND dd.asset_id = bk.asset_id
        AND dd.book_type_code = bk.book_type_code
        AND cb.book_type_code = bk.book_type_code
        AND dh.distribution_id = dd.distribution_id
        AND  nvl(dh.date_ineffective,sysdate) >= nvl(fdp.period_close_date,sysdate)
        AND   dh.transaction_header_id_in >= ah.transaction_header_id_in
        AND   dh.transaction_header_id_in < nvl(ah.transaction_header_id_out,dh.transaction_header_id_in+1)
        AND dh.code_combination_id = cc.code_combination_id
        AND fb.book_type_code = bk.book_type_code
        AND dd.period_counter =
                (SELECT max(period_counter)
                FROM fa_deprn_summary
                WHERE asset_id = bk.asset_id
                AND book_type_code = bk.book_type_code
                AND period_counter <= fdp.period_counter)
        AND bk.asset_id not in
                (SELECT asset_id
                FROM igi_iac_asset_balances
                WHERE book_type_code = bk.book_type_code
                AND asset_id = bk.asset_id)
        GROUP BY ' || balancing_seg_no    || ', ' ||
                cost_ctr_seg_no     || ', ' ||
                account_seg_no      || ', ' ||
                'bk.book_type_code,
                ah.category_id,
                cf.description,
                ad.asset_key_ccid, ' ||
                major_cat_seg_no    || ', ' ||
                minor_cat_seg_no    || ', ' ||
                'bk.deprn_method_code ,
                dh.location_id ,
                cb.deprn_reserve_acct ,
                cb.asset_cost_acct ' ||

        ' UNION
        SELECT ' ||
                balancing_seg_no    || ', ' ||
                cost_ctr_seg_no     || ', ' ||
                account_seg_no      || ', ' ||
                major_cat_seg_no    || ', ' ||
                minor_cat_seg_no    || ', ' ||
                'bk.book_type_Code book_type_code ,
                ah.category_id category_id,
                cf.description category_description,
                ad.asset_key_ccid asset_key_ccid,
                bk.deprn_method_code depreciation_method,
                dh.location_id location_id,
                cb.deprn_reserve_acct depreciation_reserve_account,
                cb.asset_cost_acct asset_cost_account,
                sum(nvl(( (id.adjustment_cost) + dd.cost), 0))  Reval_Cost,
                sum(nvl(id.reval_reserve_net, 0) ) Reval_Reserve,
                sum(nvl(id.reval_reserve_gen_fund, 0)) Gen_Fund,
                sum(nvl(id.operating_acct_net * -1, 0)) Operating_Acct,
                sum(nvl(id.deprn_reserve + dd.deprn_reserve, 0) ) Acct_Deprn,
                sum(nvl( id.deprn_reserve_backlog , 0)) Backlog
        FROM    fa_additions ad ,
                fa_Books bk ,
                fa_distribution_history dh,
                fa_deprn_Detail dd ,
                igi_iac_det_balances id ,
                gl_code_combinations cc,
                fa_categories cf,
                fa_category_books cb,
                fa_book_controls fb,
                fa_deprn_periods fdp,
                fa_asset_history ah
        WHERE   ad.asset_id = dh.asset_id
        AND  ah.asset_id = bk.asset_id
        AND  cf.category_id=ah.category_id
        AND   cb.category_id = ah.category_id
        AND cf.category_id = ' || p_categoryId || '
        AND     bk.book_Type_code = :v_bookType1
        AND fdp.book_type_code = bk.book_type_code
        AND fdp.period_counter = :v_period1
        AND   nvl(bk.period_counter_fully_retired,fdp.period_counter+1) > fdp.period_counter
        AND     bk.transaction_header_id_in = (SELECT max(ifb.transaction_header_id_in)
                                                FROM fa_books ifb
                                                WHERE ifb.book_type_code = bk.book_type_code
                                                AND ifb.asset_id = bk.asset_id
                                                AND ifb.date_effective < nvl(fdp.period_close_date,sysdate))
        AND    bk.asset_id = ad.asset_id
        AND     dh.book_type_Code = bk.book_type_code
        AND    dh.book_type_code = dd.book_type_code
        AND     cb.book_type_Code = bk.book_type_code
        AND   dh.asset_id  = dd.asset_id
        AND   dh.distribution_id = dd.distribution_id
        AND  nvl(dh.date_ineffective,sysdate) >= nvl(fdp.period_close_date,sysdate)
        AND   dh.transaction_header_id_in >= ah.transaction_header_id_in
        AND   dh.transaction_header_id_in < nvl(ah.transaction_header_id_out,dh.transaction_header_id_in+1)
        AND fb.book_type_code = bk.book_type_code
        AND   dd.period_counter = (SELECT MAX(period_counter)
                                    FROM fa_deprn_summary
                                    WHERE asset_id =bk.asset_id
                                    AND book_type_code = bk.book_type_code
                                    AND period_counter <= fdp.period_counter )
        AND     dh.distribution_id = id.distribution_id
        AND     dh.code_Combination_id = cc.code_combination_id
        AND     id.adjustment_id =       ( SELECT max(adjustment_id)
                                    FROM  igi_iac_transaction_headers it
                                    WHERE it.asset_id = bk.asset_id
                                    AND   it.book_type_code = bk.book_type_Code
                                    AND it.period_counter <= fdp.period_counter
                                    AND adjustment_status not in (''PREVIEW'', ''OBSOLETE''))
        GROUP BY ' || balancing_seg_no    || ', ' ||
                cost_ctr_seg_no     || ', ' ||
                account_seg_no      || ', ' ||
                'bk.book_type_Code ,
                ah.category_id,
                cf.description,
                ad.asset_key_ccid, '  ||
                major_cat_seg_no   || ', ' ||
                minor_cat_seg_no   || ', ' ||
                'bk.deprn_method_code ,
                dh.location_id ,
                cb.deprn_reserve_acct ,
                cb.asset_cost_acct';

        -- bug 3421784, start 18
        -- commenting out
        --     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_select_statement ' || l_select_statement);
        -- bug 3421784, end 18

        /* Bug 3490402 */
        OPEN ret_lines FOR l_select_statement USING p_bookType,      /* :v_bookType    */
                                               p_period,        /* :v_period      */
                                               p_bookType,      /* :v_bookType1   */
                                               p_period;        /* :v_period1     */
        LOOP
        FETCH ret_lines INTO
                l_gl_code_seg1,
                l_gl_code_seg2,
                l_gl_code_seg3,
                l_fa_cat_seg1,
                l_fa_cat_seg2,
                l_book_code,
                l_asset_cat_id,
                l_CFDescription,
                l_asset_key_ccid,
                l_depreciation_method,
                l_location_id,
                l_depreciation_reserve_account,
                l_asset_cost_account,
                l_reval_cost,
                l_reval_reserve,
                l_general_fund,
                l_oper_acct,
                l_deprn_resv,
                l_backlog;

        IF (ret_lines%NOTFOUND) THEN
            EXIT;
        END IF;
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'after fetch ');

        -- This will get the CONCATANATED LOCATION
        fa_rx_shared_pkg.concat_location (
				struct_id => l_g_loc_struct
				,ccid => l_location_id
				,concat_string => l_concat_loc
				,segarray => l_loc_segs);

        -- This will get the CONCATANATED ASSETKEY
        fa_rx_shared_pkg.concat_asset_key (
				struct_id => l_g_asset_key_struct
				,ccid => l_asset_key_ccid
				,concat_string => l_concat_asset_key
				,segarray => l_asset_segs);



        -- This gets the CONCATENATED CATEGORY NAME
        fa_rx_shared_pkg.concat_category (
                                       struct_id       => l_g_cat_struct,
                                       ccid            => l_asset_cat_id,
                                       concat_string   => l_concat_cat,
                                       segarray        => l_cat_segs);

        /*IF NOT get_acct_seg_val_from_ccid ( p_bookType
					,l_asset_cat_id
					,l_dep_backlog
					,l_gen_fund_acct
					,l_oper_exp_acct
					,l_reval_rsv_acct
					)
        THEN
            igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'Failed to get Account segement values - will continue.... ');
        END IF;*/
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_stl_rate ' || l_stl_rate);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_concat_loc ' || l_concat_loc);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_concat_asset_key ' || l_concat_asset_key);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_asset_cat_id ' || l_asset_cat_id);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_concat_cat ' || l_concat_cat);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_dep_backlog ' || l_dep_backlog);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_gen_fund_acct ' || l_gen_fund_acct);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_oper_exp_acct ' || l_oper_exp_acct);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_reval_rsv_acct ' || l_reval_rsv_acct);

        INSERT INTO igi_iac_asset_rep_itf (
                request_id,
                company_name,
                book_type_code,
                period,
                fiscal_year_name,
                major_category,
                cost_center,
                depreciation_method,
                conc_asset_key,
                conc_location,
                --deprn_exp_acct,
                --deprn_res_acct,
                cost_acct,
                --iac_reval_resv_acct,
                balancing_segment,
                --deprn_backlog_acct,
                --gen_fund_acct,
                --oper_exp_acct,
                concat_category,
                reval_cost,
                minor_category,
                reval_reserve,
                general_fund,
                oper_acct,
                deprn_resv,
                backlog,
                functional_currency_code,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login
                )
        VALUES
        (
                p_request_id,
                l_company_name,
                l_book_code,
                l_period_name,
                l_fiscal_year_name,
                l_fa_cat_seg1,
                l_gl_code_seg2,
                l_depreciation_method,
                l_concat_asset_key,
                l_concat_loc,
                --l_gl_code_seg3,
                --l_depreciation_reserve_account,
                l_asset_cost_account,
                --l_reval_rsv_acct,
                l_gl_code_seg1,
                --l_dep_backlog,
                --l_gen_fund_acct,
                --l_oper_exp_acct,
                l_concat_cat,
                l_reval_cost,
                l_fa_cat_seg2,
                l_reval_reserve,
                l_general_fund,
                l_oper_acct,
                l_deprn_resv,
                l_backlog,
                l_currency_code,
                l_user_id,
                sysdate,
                l_user_id,
                sysdate,
                p_login_id
                );

        END LOOP;
        CLOSE ret_lines;
        RETURN TRUE;
    EXCEPTION
        WHEN OTHERS THEN
        -- bug 3421784, start 19
        IF ret_lines%ISOPEN THEN
            CLOSE ret_lines;
        END IF;
        -- bug 3421784, end 19
        igi_iac_debug_pkg.debug_other_string(g_unexp_level,l_path,'Exception within run_s_summary_report : '|| sqlerrm);
        RETURN FALSE;
    END run_s_summary_report;

    FUNCTION run_d_summary_report  ( p_bookType	IN	VARCHAR2
				,p_period	IN	VARCHAR2
				,p_categoryId	IN	VARCHAR2
				,p_from_cc	IN	VARCHAR2
				,p_to_cc	IN	VARCHAR2
				,p_from_asset	IN	VARCHAR2
				,p_to_asset	IN	VARCHAR2
				,p_request_id	IN	NUMBER
				,l_user_id	IN	NUMBER
				,p_login_id	IN	VARCHAR2)
    RETURN BOOLEAN IS

        l_select_statement	VARCHAR2(15000);
        TYPE var_cur	IS REF CURSOR;
        ret_lines	var_cur;

        l_cost_center		VARCHAR2(25);
        l_book_code		VARCHAR2(15);
        l_reval_cost		NUMBER;
        l_reval_reserve	NUMBER;
        l_general_fund	NUMBER;
        l_oper_acct		NUMBER;
        l_deprn_resv		NUMBER;
        l_backlog		NUMBER;
        l_asset_number	VARCHAR2(15);
        l_gl_code_seg1	VARCHAR2(25);
        l_gl_code_seg2	VARCHAR2(25);
        l_gl_code_seg3   VARCHAR2(25);
        l_fa_cat_seg1		VARCHAR2(25);
        l_fa_cat_seg2		VARCHAR2(25);
        l_deprn_period	NUMBER;
        l_ytd_deprn		NUMBER;
        l_deprn_backlog	NUMBER;
        l_deprn_total		NUMBER;
        l_asset_cat_id	NUMBER(15);
        l_asset_tag				fa_additions.tag_number%TYPE;
        l_parent_id                          fa_additions.parent_asset_id%TYPE;
        l_parent_no                          VARCHAR2(15);
        l_serial_number			fa_additions.serial_number%TYPE;
        l_life_in_months			fa_Books.life_in_months%TYPE;
        l_date_placed_in_service		fa_Books.date_placed_in_service%TYPE;
        l_depreciation_reserve_account	fa_category_books.deprn_reserve_acct%TYPE;
        l_depreciation_method		fa_Books.deprn_method_code%TYPE;
        l_location_id			fa_distribution_history.location_id%TYPE;
        l_asset_key_ccid         fa_asset_keywords.code_combination_id%TYPE;
        l_asset_cost_account			fa_category_books.asset_cost_acct%TYPE;
        l_deprn_res_acct	fa_category_books.deprn_reserve_acct%TYPE;
        l_dep_backlog	NUMBER;
        l_gen_fund_acct	NUMBER;
        l_oper_exp_acct	NUMBER;
        l_reval_rsv_acct	NUMBER;
        l_concat_loc		VARCHAR2(200);
        l_concat_asset_key	VARCHAR2(200);
        l_concat_cat         VARCHAR2(500);
        l_loc_segs		fa_rx_shared_pkg.Seg_Array;
        l_asset_segs		fa_rx_shared_pkg.Seg_Array;
        l_cat_segs           fa_rx_shared_pkg.Seg_Array;
        l_stl_rate		NUMBER;
        l_CFDescription	VARCHAR2(40);
        l_ADDescription	fa_additions.description%type;
        l_from_asset         VARCHAR2(100);
        l_to_asset           VARCHAR2(100);
        l_from_cc            VARCHAR2(100);
        l_to_cc              VARCHAR2(100);
        l_path 		VARCHAR2(150);

    BEGIN
        l_path 		:= g_path||'run_d_summary_report';
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,' ** START run_d_summary_report ** ');

        l_select_statement := 'SELECT ' ||
                balancing_seg_no    || ', ' ||
                cost_ctr_seg_no     || ', ' ||
                account_seg_no      || ', ' ||
                major_cat_seg_no    || ', ' ||
                minor_cat_seg_no    || ', ' ||
                'bk.book_type_Code book_type_code,
                ah.category_id category_id,
                cf.description category_description,
                ad.asset_number asset_number,
                ad.description asset_description,
                ad.tag_number asset_tag,
                ad.parent_asset_id parent_id,
                ad.serial_number serial_number,
                ad.asset_key_ccid asset_key_ccid,
                bk.life_in_months life_in_months,
                bk.date_placed_in_service date_placed_in_service,
                bk.deprn_method_code depreciation_method,
                dh.location_id location_id,
                cb.deprn_reserve_acct depreciation_reserve_account,
                cb.asset_cost_acct asset_cost_account,
                sum(nvl(dd.cost,0))  Reval_Cost,
                0  Reval_Reserve,
                0  Gen_Fund,
                0  Operating_Acct,
                sum(nvl(dd.deprn_reserve,0)) Acct_Deprn,
                0  Backlog
        FROM fa_additions ad,
                fa_Books bk,
                fa_distribution_history dh,
                fa_deprn_Detail dd,
                gl_code_combinations cc,
                fa_categories cf,
                fa_category_books cb,
                fa_book_controls fb,
                fa_deprn_periods fdp,
                fa_asset_history ah
        WHERE ad.asset_id = bk.asset_id
        AND  ah.asset_id = bk.asset_id
        AND  cf.category_id=ah.category_id
        AND   cb.category_id = ah.category_id
        AND cf.category_id = ' || p_categoryId || '
        AND bk.book_type_code =  :v_bookType
        AND fdp.book_type_code = bk.book_type_code
        AND fdp.period_counter = :v_period
        AND   nvl(bk.period_counter_fully_retired,fdp.period_counter+1) > fdp.period_counter
        AND     bk.transaction_header_id_in = (SELECT max(ifb.transaction_header_id_in)
                                                FROM fa_books ifb
                                                WHERE ifb.book_type_code = bk.book_type_code
                                                AND ifb.asset_id = bk.asset_id
                                                AND ifb.date_effective < nvl(fdp.period_close_date,sysdate))
        AND dd.asset_id = bk.asset_id
        AND dd.book_type_code = bk.book_type_code
        AND cb.book_type_code = bk.book_type_code
        AND dh.distribution_id = dd.distribution_id
        AND  nvl(dh.date_ineffective,sysdate) >= nvl(fdp.period_close_date,sysdate)
        AND   dh.transaction_header_id_in >= ah.transaction_header_id_in
        AND   dh.transaction_header_id_in < nvl(ah.transaction_header_id_out,dh.transaction_header_id_in+1)
        AND dh.code_combination_id = cc.code_combination_id
        AND fb.book_type_code = bk.book_type_code
        AND dd.period_counter =
                (SELECT max(period_counter)
                FROM fa_deprn_summary
                WHERE asset_id = bk.asset_id
                AND book_type_code = bk.book_type_code
                AND period_counter <= fdp.period_counter)
        AND bk.asset_id not in
                (SELECT asset_id
                FROM igi_iac_asset_balances
                WHERE book_type_code = bk.book_type_code
                AND asset_id = bk.asset_id)
        AND ' || cost_ctr_seg_no || ' between nvl( :v_from_cc  , ' || cost_ctr_seg_no || ' )
        AND nvl(  :v_to_cc  ,' || cost_ctr_seg_no || ')
        AND ad.asset_number between nvl( :v_from_asset  , ad.asset_number) AND nvl( :v_to_asset  , ad.asset_number)
        GROUP BY  ad.asset_number,
                ad.description , '  ||
                balancing_seg_no    || ', ' ||
                cost_ctr_seg_no     || ', ' ||
                account_seg_no      || ', ' ||
                'bk.book_type_code,
                ah.category_id,
                cf.description, ' ||
                major_cat_seg_no    || ', ' ||
                minor_cat_seg_no    || ', ' ||
                'ad.tag_number ,
                ad.parent_asset_id ,
                ad.serial_number ,
                ad.asset_key_ccid,
                bk.life_in_months ,
                bk.date_placed_in_service ,
                bk.deprn_method_code ,
                dh.location_id ,
                cb.deprn_reserve_acct ,
                cb.asset_cost_acct ' ||

        ' UNION
        SELECT ' ||
                balancing_seg_no    || ', ' ||
                cost_ctr_seg_no     || ', ' ||
                account_seg_no      || ', ' ||
                major_cat_seg_no    || ', ' ||
                minor_cat_seg_no    || ', ' ||
                'bk.book_type_Code book_type_code ,
                ah.category_id category_id,
                cf.description category_description,
                ad.asset_number asset_number ,
                ad.description asset_description,
                ad.tag_number asset_tag,
                ad.parent_asset_id parent_id,
                ad.serial_number serial_number,
                ad.asset_key_ccid asset_key_ccid,
                bk.life_in_months life_in_months,
                bk.date_placed_in_service date_placed_in_service,
                bk.deprn_method_code depreciation_method,
                dh.location_id location_id,
                cb.deprn_reserve_acct depreciation_reserve_account,
                cb.asset_cost_acct asset_cost_account,
                sum(nvl(( id.adjustment_cost + dd.cost), 0))  Reval_Cost,
                sum(nvl(id.reval_reserve_net, 0) ) Reval_Reserve,
                sum(nvl(id.reval_reserve_gen_fund, 0)) Gen_Fund,
                sum(nvl(id.operating_acct_net * -1, 0)) Operating_Acct,
                sum(nvl(id.deprn_reserve + dd.deprn_reserve, 0) ) Acct_Deprn,
                sum(nvl( id.deprn_reserve_backlog , 0)) Backlog
        FROM    fa_additions ad ,
                fa_Books bk ,
                fa_distribution_history dh,
                fa_deprn_Detail dd ,
                igi_iac_det_balances id ,
                gl_code_combinations cc,
                fa_categories cf,
                fa_category_books cb,
                fa_book_controls fb,
                fa_deprn_periods fdp,
                fa_asset_history ah
        WHERE   ad.asset_id = dh.asset_id
        AND  ah.asset_id = bk.asset_id
        AND  cf.category_id=ah.category_id
        AND   cb.category_id = ah.category_id
        AND cf.category_id = ' || p_categoryId || '
        AND     bk.book_Type_code = :v_bookType1
        AND fdp.book_type_code = bk.book_type_code
        AND fdp.period_counter = :v_period1
        AND   nvl(bk.period_counter_fully_retired,fdp.period_counter+1) > fdp.period_counter
        AND     bk.transaction_header_id_in = (SELECT max(ifb.transaction_header_id_in)
                                                FROM fa_books ifb
                                                WHERE ifb.book_type_code = bk.book_type_code
                                                AND ifb.asset_id = bk.asset_id
                                                AND ifb.date_effective < nvl(fdp.period_close_date,sysdate))
        AND    bk.asset_id = ad.asset_id
        AND     dh.book_type_Code = bk.book_type_code
        AND    dh.book_type_code = dd.book_type_code
        AND     cb.book_type_Code = bk.book_type_code
        AND   dh.asset_id  = dd.asset_id
        AND   dh.distribution_id = dd.distribution_id
        AND  nvl(dh.date_ineffective,sysdate) >= nvl(fdp.period_close_date,sysdate)
        AND   dh.transaction_header_id_in >= ah.transaction_header_id_in
        AND   dh.transaction_header_id_in < nvl(ah.transaction_header_id_out,dh.transaction_header_id_in+1)
        AND   fb.book_type_code = bk.book_type_code
        AND   dd.period_counter = (SELECT MAX(period_counter)
                                    FROM fa_deprn_summary
                                    WHERE asset_id =bk.asset_id
                                    AND book_type_code =  bk.book_type_code
                                    AND period_counter <= fdp.period_counter )
        AND     dh.distribution_id = id.distribution_id
        AND     dh.code_Combination_id = cc.code_combination_id
        AND     id.adjustment_id =       ( SELECT max(adjustment_id)
                                    FROM  igi_iac_transaction_headers it
                                    WHERE it.asset_id = bk.asset_id
                                    AND   it.book_type_code = bk.book_type_Code
                                    AND it.period_counter <= fdp.period_counter
                                    AND adjustment_status not in (''PREVIEW'', ''OBSOLETE''))
        AND ' || cost_ctr_seg_no || ' between nvl(  :v_from_cc1  , ' || cost_ctr_seg_no || ' )
        AND nvl(  :v_to_cc1  ,' || cost_ctr_seg_no || ')
        AND ad.asset_number between nvl( :v_from_asset1  , ad.asset_number) AND nvl(  :v_to_asset1  , ad.asset_number)
        GROUP BY ad.asset_number ,
                ad.description , ' ||
                balancing_seg_no    || ', ' ||
                cost_ctr_seg_no     || ', ' ||
                account_seg_no      || ', ' ||
                'bk.book_type_Code ,
                ah.category_id,
                cf.description, '  ||
                major_cat_seg_no   || ', ' ||
                minor_cat_seg_no   || ', ' ||
                'ad.tag_number ,
                ad.parent_asset_id ,
                ad.serial_number ,
                ad.asset_key_ccid,
                bk.life_in_months ,
                bk.date_placed_in_service ,
                bk.deprn_method_code ,
                dh.location_id ,
                cb.deprn_reserve_acct ,
                cb.asset_cost_acct';

        -- bug 3421784, start 20
        -- commenting out
        --     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_select_statement ' || l_select_statement);
        -- bug 3421784, end 20

        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,' ** After l_select ** ');
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_categoryId --> ' || p_categoryId);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_bookType   --> ' || p_bookType);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_period     --> ' || p_period);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_from_cc    --> ' || nvl(p_from_cc,1));
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_to_cc      --> ' || nvl(p_to_cc,1));
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_from_asset --> ' || nvl(p_from_asset,1));
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_to_asset   --> ' || nvl(p_to_asset,1));

        IF p_from_asset = 'NULL' THEN
            l_from_asset := NULL;
        ELSE
            l_from_asset := p_from_asset;
        END IF;

        IF p_to_asset = 'NULL' THEN
            l_to_asset := NULL;
        ELSE
            l_to_asset := p_to_asset;
        END IF;

        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_from_asset --> ' || nvl(l_from_asset,1));
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_to_asset   --> ' || nvl(l_to_asset,1));

        IF p_from_cc = 'NULL' THEN
            l_from_cc := NULL;
        ELSE
            l_from_cc := p_from_cc;
        END IF;

        IF p_to_cc = 'NULL' THEN
            l_to_cc := NULL;
        ELSE
            l_to_cc := p_to_cc;
        END IF;

        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_from_cc --> ' || nvl(l_from_cc,1));
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_to_cc   --> ' || nvl(l_to_cc,1));

        /* Bug 3490402 */
        OPEN ret_lines FOR l_select_statement USING p_bookType,       /* :v_bookType         */
                                               p_period,         /* :v_period           */
                                               l_from_cc,        /* :v_from_cc          */
                                               l_to_cc,          /* :v_to_cc,           */
                                               l_from_asset,     /* :v_from_asset       */
                                               l_to_asset,       /* :v_to_asset         */
                                               p_bookType,       /* :v_bookType1        */
                                               p_period,         /* :v_period1          */
                                               l_from_cc,        /* :v_from_cc1         */
                                               l_to_cc,          /* :v_to_cc1           */
                                               l_from_asset,     /* :v_from_asset1      */
                                               l_to_asset;       /* :v_to_asset1        */
        LOOP
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'FETCH');
        FETCH ret_lines INTO
                l_gl_code_seg1,
                l_gl_code_seg2,
                l_gl_code_seg3,
                l_fa_cat_seg1,
                l_fa_cat_seg2,
                l_book_code,
                l_asset_cat_id,
                l_CFDescription,
                l_asset_number,
                l_ADDescription,
                l_asset_tag,
                l_parent_id,
                l_serial_number,
                l_asset_key_ccid,
                l_life_in_months,
                l_date_placed_in_service,
                l_depreciation_method,
                l_location_id,  -- number
                l_depreciation_reserve_account,
                l_asset_cost_account,
                l_reval_cost,
                l_reval_reserve,
                l_general_fund,
                l_oper_acct,
                l_deprn_resv,
                l_backlog;

        IF (ret_lines%NOTFOUND) THEN
            EXIT;
        END IF;

        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'after fetch ');

        /* StatReq - The following if statement has been added to calculate the annual depreciation rate
                for straight-line, calculated depreciation methods */

        -- Calculate STL_RATE from life_in_months
        IF (l_life_in_months > 0)
        THEN
            l_stl_rate := 12 / l_life_in_months * 100;
        ELSE
            l_stl_rate := NULL;
        END IF;

        -- This will get the CONCATANATED LOCATION
        fa_rx_shared_pkg.concat_location (
				struct_id => l_g_loc_struct
				,ccid => l_location_id
				,concat_string => l_concat_loc
				,segarray => l_loc_segs);

        -- This will get the CONCATANATED ASSETKEY
        fa_rx_shared_pkg.concat_asset_key (
				struct_id => l_g_asset_key_struct
				,ccid => l_asset_key_ccid
				,concat_string => l_concat_asset_key
				,segarray => l_asset_segs);

        -- This gets the CONCATENATED CATEGORY NAME
        fa_rx_shared_pkg.concat_category (
                                       struct_id       => l_g_cat_struct,
                                       ccid            => l_asset_cat_id,
                                       concat_string   => l_concat_cat,
                                       segarray        => l_cat_segs);

        /*IF NOT get_acct_seg_val_from_ccid ( p_bookType
					,l_asset_cat_id
					,l_dep_backlog
					,l_gen_fund_acct
					,l_oper_exp_acct
					,l_reval_rsv_acct
					)
        THEN
            igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'Failed to get Account segement values - will continue.... ');
        END IF;*/
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_stl_rate ' || l_stl_rate);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_concat_loc ' || l_concat_loc);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_concat_asset_key ' || l_concat_asset_key);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_asset_cat_id ' || l_asset_cat_id);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_concat_cat ' || l_concat_cat);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_dep_backlog ' || l_dep_backlog);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_gen_fund_acct ' || l_gen_fund_acct);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_oper_exp_acct ' || l_oper_exp_acct);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_reval_rsv_acct ' || l_reval_rsv_acct);
        l_parent_no := NULL;

        IF l_parent_id IS NOT NULL THEN
            l_parent_no := l_asset_number;
        END IF;

        INSERT INTO igi_iac_asset_rep_itf (
                request_id,
                company_name,
                book_type_code,
                period,
                fiscal_year_name,
                major_category,
                cost_center,
                asset_number,
                asset_description,
                asset_tag,
                parent_no,
                serial_no,
                life_months,
                stl_rate,
                dpis,
                depreciation_method,
                conc_asset_key,
                conc_location,
                --deprn_exp_acct,
                --deprn_res_acct,
                cost_acct,
                --iac_reval_resv_acct,
                balancing_segment,
                --deprn_backlog_acct,
                --gen_fund_acct,
                --oper_exp_acct,
                concat_category,
                reval_cost,
                minor_category,
                reval_reserve,
                general_fund,
                oper_acct,
                deprn_resv,
                backlog,
                functional_currency_code,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login
                )
        VALUES
        (
                p_request_id,
                l_company_name,
                l_book_code,
                l_period_name,
                l_fiscal_year_name,
                l_fa_cat_seg1,
                l_gl_code_seg2,
                l_asset_number,
                l_ADDescription,
                l_asset_tag,
                l_parent_no,
                l_serial_number,
                l_life_in_months,
                l_stl_rate,
                l_date_placed_in_service,
                l_depreciation_method,
                l_concat_asset_key,
                l_concat_loc,
                --l_gl_code_seg3,
                --l_depreciation_reserve_account,
                l_asset_cost_account,
                --l_reval_rsv_acct,
                l_gl_code_seg1,
                --l_dep_backlog,
                --l_gen_fund_acct,
                --l_oper_exp_acct,
                l_concat_cat,
                l_reval_cost,
                l_fa_cat_seg2,
                l_reval_reserve,
                l_general_fund,
                l_oper_acct,
                l_deprn_resv,
                l_backlog,
                l_currency_code,
                l_user_id,
                sysdate,
                l_user_id,
                sysdate,
                p_login_id
                );

        END LOOP;
        CLOSE ret_lines;
        RETURN TRUE;

    EXCEPTION
        WHEN OTHERS THEN
        -- bug 3421784, start 21
        IF ret_lines%ISOPEN THEN
            CLOSE ret_lines;
        END IF;
        -- bug 3421784, end 21
        igi_iac_debug_pkg.debug_other_string(g_unexp_level,l_path,'Exception within run_d_summary_report : '|| sqlerrm);
        RETURN FALSE;
    END run_d_summary_report;

    FUNCTION Delete_Zero_Rows(p_bookType  IN  VARCHAR2,
                            p_request_id    IN  NUMBER,
                            p_reptShrtName  IN  VARCHAR2)
    RETURN BOOLEAN IS
        l_path VARCHAR2(150);
    BEGIN
        l_path := g_path||'Delete_Zero_Rows';
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Deleting rows with all zero values');
        IF p_reptShrtName IN ('RXIGIIAK','RXIGIIAD') THEN
            DELETE FROM igi_iac_asset_rep_itf
            WHERE book_type_code = p_bookType
            AND request_id = p_request_id
            AND reval_cost = 0
            AND deprn_period = 0
            AND ytd_deprn = 0
            AND deprn_resv = 0
            AND deprn_backlog = 0
            AND deprn_total = 0;
        ELSIF p_reptShrtName IN ('RXIGIIAM','RXIGIIAO') THEN
            DELETE FROM igi_iac_asset_rep_itf
            WHERE book_type_code = p_bookType
            AND request_id = p_request_id
            AND reval_cost = 0
            AND oper_exp = 0
            AND oper_exp_backlog = 0
            AND oper_exp_net = 0;
        ELSIF p_reptShrtName IN ('RXIGIIAL','RXIGIIAR') THEN
            DELETE FROM igi_iac_asset_rep_itf
            WHERE book_type_code = p_bookType
            AND request_id = p_request_id
            AND reval_cost = 0
            AND reval_resv_cost = 0
            AND reval_resv_blog = 0
            AND reval_resv_gen_fund = 0
            AND reval_resv_net = 0;
        ELSIF p_reptShrtName IN ('RXIGIIAJ','RXIGIIAB') THEN
            DELETE FROM igi_iac_asset_rep_itf
            WHERE book_type_code = p_bookType
            AND request_id = p_request_id
            AND reval_cost = 0
            AND reval_reserve = 0
            AND general_fund = 0
            AND oper_acct = 0
            AND deprn_resv = 0
            AND backlog = 0;
        END IF;
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Deleted rows with all zero values');
    EXCEPTION
        WHEN OTHERS THEN
        igi_iac_debug_pkg.debug_other_string(g_unexp_level,l_path,'Exception within Delete_Zero_Rows : '|| sqlerrm);
        RETURN FALSE;
    END Delete_Zero_Rows;

    FUNCTION get_acct_seg_values ( p_bookType		IN	VARCHAR2
				,p_categoryId		IN	NUMBER
				,p_deprn_res_acct	IN OUT	NOCOPY
					fa_category_books.deprn_reserve_acct%TYPE
				,p_deprn_exp_acct	IN OUT	NOCOPY
					fa_category_books.deprn_expense_acct%TYPE)
    RETURN BOOLEAN IS

        CURSOR c_acct(cp_bookType VARCHAR2, cp_categoryId NUMBER) IS
        SELECT fc.deprn_reserve_acct,
           fc.deprn_expense_acct
        FROM fa_category_books  fc
        WHERE fc.Book_Type_Code = cp_bookType
        AND   fc.Category_id = cp_categoryId;

        l_retVal	BOOLEAN;
        l_path 	VARCHAR2(150);
    BEGIN

        l_retVal	:= FALSE;
        l_path 	:= g_path||'get_acct_seg_values';

        FOR l_acct in c_acct (p_bookType, p_categoryId ) LOOP
            p_deprn_res_acct := l_acct.deprn_reserve_acct ;
            p_deprn_exp_acct := l_acct.deprn_expense_acct;
            l_retVal := TRUE;
        END LOOP;
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_deprn_res_acct ' || p_deprn_res_acct);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_deprn_exp_acct ' || p_deprn_exp_acct);
        RETURN l_retVal;
    EXCEPTION
        WHEN OTHERS THEN
        -- bug 3421784, start 21
        IF c_acct%ISOPEN THEN
            CLOSE c_acct;
        END IF;
        -- bug 3421784, end 21
        igi_iac_debug_pkg.debug_other_string(g_unexp_level,l_path,'Exception within get_acct_seg_values : '|| sqlerrm);
        RETURN FALSE;
    END get_acct_seg_values;

    FUNCTION get_acct_seg_val_from_ccid ( p_bookType		IN	VARCHAR2
					,p_categoryId		IN	NUMBER
					,p_deprn_backlog	IN OUT	NOCOPY VARCHAR2
					,p_gen_fund_acct	IN OUT	NOCOPY VARCHAR2
					,p_oper_exp_acct	IN OUT  NOCOPY VARCHAR2
					,p_reval_rsv_acct	IN OUT  NOCOPY VARCHAR2)
    RETURN BOOLEAN IS

        CURSOR c_acct(cp_bookType VARCHAR2, cp_categoryId NUMBER) IS
        SELECT	cb.backlog_deprn_rsv_ccid,
            cb.general_fund_ccid,
            cb.operating_expense_ccid,
            cb.reval_rsv_ccid
        FROM igi_iac_category_books  cb
        WHERE cb.Book_Type_Code = cp_bookType
        AND	cb.Category_id = cp_categoryId;

        l_backlog_deprn_rsv_ccid	NUMBER;
        l_general_fund_ccid		NUMBER;
        l_operating_expense_ccid	NUMBER;
        l_reval_rsv_ccid    NUMBER;
        l_set_of_books_id	NUMBER;
        l_chart_of_accts	NUMBER;
        l_currency		VARCHAR2(50);
        l_precision		NUMBER;
        l_path 		VARCHAR2(150);

    BEGIN
        l_backlog_deprn_rsv_ccid	:= -1;
        l_general_fund_ccid		:= -1;
        l_operating_expense_ccid	:= -1;
        l_reval_rsv_ccid := -1;

        l_path 		:= g_path||'get_acct_seg_val_from_ccid';

        FOR l_acct in c_acct (p_bookType, p_categoryId ) LOOP
            l_backlog_deprn_rsv_ccid := l_acct.backlog_deprn_rsv_ccid ;
            l_general_fund_ccid      := l_acct.general_fund_ccid;
            l_operating_expense_ccid := l_acct.operating_expense_ccid;
            l_reval_rsv_ccid         := l_acct.reval_rsv_ccid;
        END LOOP;

        IF (l_backlog_deprn_rsv_ccid = -1 OR l_general_fund_ccid = -1 OR
            l_operating_expense_ccid = -1 OR l_reval_rsv_ccid = -1) THEN
            RETURN FALSE;
        END IF;

        IF NOT IGI_IAC_COMMON_UTILS.Get_Book_GL_Info (
			p_bookType
			,l_set_of_books_id
			,l_chart_of_accts
			,l_currency
			,l_precision
			)
        THEN
            RETURN FALSE;
        ELSE
            IF NOT IGI_IAC_COMMON_UTILS.Get_Account_Segment_Value (
							l_set_of_books_id
							,l_backlog_deprn_rsv_ccid
							,'GL_ACCOUNT'
							,p_deprn_backlog
								)
            THEN
                p_deprn_backlog := NULL;
            END IF;

            IF NOT IGI_IAC_COMMON_UTILS.Get_Account_Segment_Value (
							l_set_of_books_id
							,l_general_fund_ccid
							,'GL_ACCOUNT'
							,p_gen_fund_acct
								)
            THEN
                p_gen_fund_acct := NULL;
            END IF;

            IF NOT IGI_IAC_COMMON_UTILS.Get_Account_Segment_Value (
							l_set_of_books_id
							,l_operating_expense_ccid
							,'GL_ACCOUNT'
							,p_oper_exp_acct
								)
            THEN
                p_oper_exp_acct := NULL;
            END IF;

            IF NOT IGI_IAC_COMMON_UTILS.Get_Account_Segment_Value (
							l_set_of_books_id
							,l_reval_rsv_ccid
							,'GL_ACCOUNT'
							,p_reval_rsv_acct
								)
            THEN
                p_reval_rsv_acct := NULL;
            END IF;

        END IF;

        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_set_of_books_id ' || l_set_of_books_id);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_chart_of_accts ' || l_chart_of_accts);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_deprn_backlog ' || p_deprn_backlog);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_gen_fund_acct ' || p_gen_fund_acct);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_oper_exp_acct ' || p_oper_exp_acct);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_reval_rsv_acct ' || p_reval_rsv_acct);

        RETURN TRUE;

    EXCEPTION
        WHEN OTHERS THEN
        -- bug 3421784, start 22
        IF c_acct%ISOPEN THEN
            CLOSE c_acct;
        END IF;
        -- bug 3421784, end 22

        igi_iac_debug_pkg.debug_other_string(g_unexp_level,l_path,'Exception within get_acct_seg_val_from_ccid : '|| sqlerrm);
        RETURN FALSE;
    END get_acct_seg_val_from_ccid;

BEGIN
    --===========================FND_LOG.START=====================================
    g_state_level 	     :=	FND_LOG.LEVEL_STATEMENT;
    g_proc_level  	     :=	FND_LOG.LEVEL_PROCEDURE;
    g_event_level 	     :=	FND_LOG.LEVEL_EVENT;
    g_excep_level 	     :=	FND_LOG.LEVEL_EXCEPTION;
    g_error_level 	     :=	FND_LOG.LEVEL_ERROR;
    g_unexp_level 	     :=	FND_LOG.LEVEL_UNEXPECTED;
    g_path              := 'IGI.PLSQL.igiiaxcb.igi_iac_rxi_i_wrap_asset_bal.';
 --===========================FND_LOG.END=====================================

END igi_iac_rxi_i_wrap_asset_bal;

/
