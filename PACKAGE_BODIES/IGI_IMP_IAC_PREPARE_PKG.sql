--------------------------------------------------------
--  DDL for Package Body IGI_IMP_IAC_PREPARE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IMP_IAC_PREPARE_PKG" AS
-- $Header: igiimpdb.pls 120.24.12000000.2 2007/10/22 13:51:43 gkumares ship $

    Cursor C_Asset_Category(p_book in varchar) Is
    Select  category_id
    From    fa_category_books
    Where   book_type_code = p_book;

    Cursor C_Book_Info(p_book in varchar2, p_category_id in number) Is
    Select  bk.asset_id,
            bk.date_placed_in_service,
            bk.life_in_months,
            nvl(bk.cost,0) cost,
            nvl(bk.adjusted_cost,0) adjusted_cost,
            nvl(bk.original_cost,0) original_cost,
            nvl(bk.salvage_value,0) salvage_value,
            nvl(bk.adjusted_recoverable_cost, 0) adjusted_recoverable_cost,
            nvl(bk.recoverable_cost,0) recoverable_cost,
            bk.deprn_start_date,
            bk.cost_change_flag,
            bk.rate_adjustment_factor,
            bk.depreciate_flag,
            bk.fully_rsvd_revals_counter,
            bk.period_counter_fully_reserved,
            bk.period_counter_fully_retired,
            ad.asset_number,
            ad.asset_type
    From    fa_books bk,
            fa_additions ad
    Where   bk.book_type_code = p_book
    and     bk.asset_id = ad.asset_id
    and     bk.transaction_header_id_out is null
    and     ad.asset_category_id = p_category_id;

    Cursor C_Fiscal_Year(p_book in varchar2, p_period_counter in number) Is
    Select  fiscal_year
    From    fa_deprn_periods dp
    Where   book_type_code = p_book
    and     period_counter = p_period_counter;

    Cursor C_Corp_Book_Info(p_book in varchar2, p_asset_id in number) Is
    Select  asset_id,
            date_placed_in_service,
            life_in_months,
            nvl(cost,0) cost,
            nvl(adjusted_cost,0) adjusted_cost,
            nvl(original_cost,0) original_cost,
            nvl(salvage_value,0) salvage_value,
            nvl(adjusted_recoverable_cost, 0) adjusted_recoverable_cost,
            nvl(recoverable_cost,0) recoverable_cost,
            deprn_start_date,
            cost_change_flag,
            rate_adjustment_factor,
            depreciate_flag,
            fully_rsvd_revals_counter,
            period_counter_fully_reserved,
            period_counter_fully_retired
    From    fa_books
    Where   book_type_code = p_book
    and     date_ineffective is null
    and     asset_id = p_asset_id;

    Cursor C_Corp_Deprn_Details(p_book in varchar2,
                                p_asset_id in number,
                                p_period_counter in number) Is
    Select  nvl(sum(deprn_amount),0) deprn_amount,
            nvl(sum(deprn_reserve),0) deprn_reserve,
            nvl(sum(cost),0) cost,
            nvl(sum(reval_reserve),0) reval_reserve,
            nvl(sum(ytd_deprn),0) ytd_deprn,
            nvl(sum(deprn_adjustment_amount),0) deprn_adjustment_amount
    From    fa_deprn_detail
    Where   book_type_code = p_book
    and     period_counter = p_period_counter
    and     asset_id = p_asset_id
    and     deprn_source_code = 'D'
    Group by asset_id;

    Cursor C_Corp_Deprn_Summary(p_book in varchar2,
                                p_asset_id in number,
                                p_period_counter in number) Is
    Select  nvl(deprn_amount,0) deprn_amount,
            nvl(ytd_deprn,0) ytd_deprn,
            nvl(deprn_reserve,0) deprn_reserve,
            deprn_source_code,
            nvl(reval_reserve,0) reval_reserve,
            nvl(adjusted_cost,0) adjusted_cost
    From    fa_deprn_summary
    Where   book_type_code = p_book
    and     period_counter = p_period_counter
    and     asset_id = p_asset_id
    and     deprn_source_code = 'DEPRN';

    Cursor C_Corp_Max_Period_Counter(p_book in varchar2,
                                     p_asset_id in number) Is
    Select max(Period_counter) period_counter
    From   fa_deprn_summary
    Where  book_type_code = p_book
    and     asset_id = p_asset_id
    and     deprn_source_code = 'DEPRN';

    l_rec_ctr number;
    l_max_records number;
    l_group_id number;
    l_cat_records number;
    l_fiscal_year number;
    l_book_last_per_counter number;
    l_corp_last_per_counter number;
    l_exception_code varchar2(1);
    l_exception_flag varchar2(1);

    l_corp_book_info C_Corp_Book_Info%Rowtype;
    l_corp_deprn_details C_Corp_Deprn_Details%Rowtype;
    l_corp_deprn_summary C_Corp_Deprn_Summary%Rowtype;
    l_imp_interface igi_imp_iac_interface%Rowtype;
    l_hist_info igi_iac_types.fa_hist_asset_info;

    --===========================FND_LOG.START=====================================
    g_state_level NUMBER;
    g_proc_level  NUMBER;
    g_event_level NUMBER;
    g_excep_level NUMBER;
    g_error_level NUMBER;
    g_unexp_level NUMBER;
    g_path        VARCHAR2(100);
    --===========================FND_LOG.END=======================================

    Prepare_Data_Error Exception;


    Procedure Set_Process_Status(p_book in varchar2, p_flag in varchar2) Is
        l_path_name VARCHAR2(150);
    Begin

        l_path_name := g_path||'set_process_status';

        Update igi_imp_iac_controls
        Set Request_status =  p_flag,
            Request_id = fnd_global.conc_request_id,
            Request_date = sysdate,
            Last_updated_by = fnd_global.user_id,
            last_update_date = sysdate,
            last_update_login = fnd_global.login_id
        Where book_type_code = p_book;
        If Sql%found Then
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'igi_imp_iac_controls updated, Request_status set to '
				    || p_flag  || ' for Book ' || p_book);
        End If;
    Exception
        When Others Then
	   igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     	p_full_path => l_path_name,
		     	p_string => 'Error during update of Request Status to ' || p_flag);
           Raise;
    End;

    Procedure Populate_Interface(p_interface_rec igi_imp_iac_interface%Rowtype) Is
        l_path_name VARCHAR2(150);
    Begin

        l_path_name  := g_path||'populate_interface';

	Insert into igi_imp_iac_interface(
            Asset_id,
            Asset_number,
            Book_type_code,
            Category_id,
            Hist_salvage_value,
            Life_in_months,
            Cost_hist,
            Cost_mhca,
            Deprn_exp_hist,
            Deprn_exp_mhca,
            Ytd_hist,
            Ytd_mhca,
            Accum_deprn_hist,
            Accum_deprn_mhca,
            Reval_reserve_hist,
            Reval_reserve_mhca,
            Backlog_hist,
            Backlog_mhca,
            General_fund_hist,
            General_fund_mhca,
            General_fund_per_hist,
            General_fund_per_mhca,
            Operating_account_hist,
            Operating_account_mhca,
            Operating_account_ytd_hist,
            Operating_account_ytd_mhca,
            Operating_account_cost,
            Operating_account_backlog,
            Nbv_hist,
            Nbv_mhca,
            Transferred_flag,
            Selected_Flag,
            Exception_Flag,
            Exception_code,
            Group_id,
            Export_file,
            Export_date,
            Import_file,
            Import_date,
            Created_by,
            Creation_date,
            Last_updated_by,
            Last_update_date,
            Last_update_login,
            Request_id,
            Program_application_id,
            Program_id,
            Program_update_date,
            Valid_flag) -- Added as a part of fix for Bug 5137813
        Values(
            p_interface_rec.Asset_id,
            p_interface_rec.Asset_number,
            p_interface_rec.Book_type_code,
            p_interface_rec.Category_id,
            p_interface_rec.Hist_salvage_value,
            p_interface_rec.Life_in_months,
            p_interface_rec.Cost_hist,
            p_interface_rec.Cost_mhca,
            p_interface_rec.Deprn_exp_hist,
            p_interface_rec.Deprn_exp_mhca,
            p_interface_rec.Ytd_hist,
            p_interface_rec.Ytd_mhca,
            p_interface_rec.Accum_deprn_hist,
            p_interface_rec.Accum_deprn_mhca,
            p_interface_rec.Reval_reserve_hist,
            p_interface_rec.Reval_reserve_mhca,
            p_interface_rec.Backlog_hist,
            p_interface_rec.Backlog_mhca,
            p_interface_rec.General_fund_hist,
            p_interface_rec.General_fund_mhca,
            p_interface_rec.General_fund_per_hist,
            p_interface_rec.General_fund_per_mhca,
            p_interface_rec.Operating_account_hist,
            p_interface_rec.Operating_account_mhca,
            p_interface_rec.Operating_account_ytd_hist,
            p_interface_rec.Operating_account_ytd_mhca,
            p_interface_rec.Operating_account_cost,
            p_interface_rec.Operating_account_backlog,
            p_interface_rec.Nbv_hist,
            p_interface_rec.Nbv_mhca,
            p_interface_rec.Transferred_flag,
            p_interface_rec.Selected_Flag,
            p_interface_rec.Exception_Flag,
            p_interface_rec.Exception_code,
            p_interface_rec.Group_id,
            p_interface_rec.Export_file,
            p_interface_rec.Export_date,
            p_interface_rec.Import_file,
            p_interface_rec.Import_date,
            p_interface_rec.Created_by,
            p_interface_rec.Creation_date,
            p_interface_rec.Last_updated_by,
            p_interface_rec.Last_update_date,
            p_interface_rec.Last_update_login,
            p_interface_rec.Request_id,
            p_interface_rec.Program_application_id,
            p_interface_rec.Program_id,
            p_interface_rec.Program_update_date,
            p_interface_rec.Valid_flag); -- Added as a part of fix for Bug 5137813
        If Sql%found Then
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'Created a record in igi_imp_iac_interface, Book Type Code : ' ||
                		    p_interface_rec.Book_type_code ||
                		    ' ,Asset Id : ' || p_interface_rec.Asset_id ||
                		    ' ,Asset Number : ' || p_interface_rec.Asset_number ||
                		    ' ,Category Id : ' || p_interface_rec.Category_id);
        End If;
    Exception
        When Others Then
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     	p_full_path => l_path_name,
		     	p_string => 'Error during creation of record in igi_imp_iac_interface, '
				    ||'Book Type Code : ' ||p_interface_rec.Book_type_code
				    ||' ,Asset Id : ' || p_interface_rec.Asset_id
				    ||' ,Asset Number : ' || p_interface_rec.Asset_number
				    ||' ,Category Id : ' || p_interface_rec.Category_id);
           Raise;
   End;

   Procedure Populate_Interface_control( p_book in varchar2, p_category_id in number) Is
        l_path_name VARCHAR2(150);
   Begin

        l_path_name  := g_path||'populate_interface_data';

        Insert into igi_imp_iac_interface_ctrl(
            book_type_code,
            category_id,
            created_by,
            creation_date,
            transfer_Status ,
            last_updated_by,
            last_update_date,
            last_update_login)
        Values(
            p_book,
            p_category_id,
            fnd_global.user_id,
            sysdate,
            'N' ,
            fnd_global.user_id,
            sysdate,
            fnd_global.login_id);
            If Sql%found Then
  	        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	    p_full_path => l_path_name,
		            p_string => 'Created a record in igi_imp_iac_interface_ctrl for Book ' || p_book );
            End if;
    Exception
        When Others Then
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     	    p_full_path => l_path_name,
		    	    p_string => ' Error during creation of record in igi_imp_iac_interface_ctrl for Book ' || p_book);
            Raise;
    End;

    Procedure Initialise_Variables(p_corp_book_info        in out NOCOPY C_Corp_Book_Info%Rowtype,
                                   p_corp_deprn_details    in out NOCOPY C_Corp_Deprn_Details%Rowtype,
                                   p_corp_deprn_summary    in out NOCOPY C_Corp_Deprn_Summary%Rowtype,
                                   p_imp_interface         in out NOCOPY igi_imp_iac_interface%Rowtype,
                                   p_hist_info             in out NOCOPY igi_iac_types.fa_hist_asset_info,
                                   p_fiscal_year           in out NOCOPY number,
                                   p_book_last_per_counter in out NOCOPY number,
                                   p_corp_last_per_counter in out NOCOPY number,
                                   p_exception_code        in out NOCOPY varchar2,
                                   p_exception_flag        in out NOCOPY varchar2) Is

        l_initialise_corp_book    C_Corp_Book_Info%Rowtype;
        l_initialise_corp_details C_Corp_Deprn_Details%Rowtype;
        l_initialise_corp_summary C_Corp_Deprn_Summary%Rowtype;
        l_initialise_interface    igi_imp_iac_interface%Rowtype;
        l_initialise_hist_info    igi_iac_types.fa_hist_asset_info;


        p_corp_book_info_old        C_Corp_Book_Info%Rowtype;
        p_corp_deprn_details_old    C_Corp_Deprn_Details%Rowtype;
        p_corp_deprn_summary_old    C_Corp_Deprn_Summary%Rowtype;
        p_imp_interface_old         igi_imp_iac_interface%Rowtype;
        p_hist_info_old             igi_iac_types.fa_hist_asset_info;
        p_fiscal_year_old           number;
        p_book_last_per_counter_old number;
        p_corp_last_per_counter_old number;
        p_exception_code_old            varchar2(1);
        p_exception_flag_old        varchar2(1);
        l_path_name VARCHAR2(150);

    Begin

       l_path_name  := g_path||'initialise_variables';

       -- copying old values.
       p_corp_book_info_old        :=  p_corp_book_info;
       p_corp_deprn_details_old    :=  p_corp_deprn_details;
       p_corp_deprn_summary_old    :=  p_corp_deprn_summary;
       p_imp_interface_old         :=  p_imp_interface;
       p_hist_info_old             :=  p_hist_info;
       p_fiscal_year_old           :=  p_fiscal_year;
       p_book_last_per_counter_old :=  p_book_last_per_counter;
       p_corp_last_per_counter_old :=  p_corp_last_per_counter;
       p_exception_code_old        :=  p_exception_code;
       p_exception_flag_old        :=  p_exception_flag;

        p_corp_book_info        := l_initialise_corp_book;
        p_corp_deprn_details    := l_initialise_corp_details;
        p_corp_deprn_summary    := l_initialise_corp_summary;
        p_imp_interface         := l_initialise_interface;
        p_hist_info             := l_initialise_hist_info;
        p_fiscal_year           := NULL;
        p_book_last_per_counter := NULL;
        p_corp_last_per_counter := NULL;
        p_exception_code        := NULL;
        p_exception_flag        := 'N';

    Exception
        When Others Then

             p_corp_book_info        :=  p_corp_book_info_old;
             p_corp_deprn_details    :=  p_corp_deprn_details_old;
             p_corp_deprn_summary    :=  p_corp_deprn_summary_old;
             p_imp_interface         :=  p_imp_interface_old;
             p_hist_info             :=  p_hist_info_old;
             p_fiscal_year           :=  p_fiscal_year_old;
             p_book_last_per_counter :=  p_book_last_per_counter_old;
             p_corp_last_per_counter :=  p_corp_last_per_counter_old;
             p_exception_code        :=  p_exception_code_old;
             p_exception_flag        :=  p_exception_flag_old;

  	    igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     	    p_full_path => l_path_name,
		     	    p_string => 'Error during initialising of variables ');
            Raise;
  End;


    Procedure Prepare_Data (errbuf out NOCOPY VARCHAR2,
                            retcode out NOCOPY NUMBER,
                            p_book_class in  VARCHAR2 ,
                            p_book_type_code in  VARCHAR2 ) Is

        Cursor C_Period_Info IS
        Select  bk.last_period_counter book_last_per_counter,
                dp1.fiscal_year book_per_fiscal_year,
                ict.corp_book corp_book,
                ict.period_counter -1 corp_last_per_counter,
                dp2.fiscal_year corp_per_fiscal_year,
                dp2.period_num  corp_curr_period_num
        From    igi_imp_iac_controls ict,
                fa_book_controls bk,
                fa_deprn_periods dp1,
                fa_deprn_periods dp2
        Where   ict.book_type_code = p_book_type_code
        and     bk.book_type_code  = ict.book_type_code
        and     dp1.book_type_code = ict.book_type_code
        and     dp1.period_counter = bk.last_period_counter + 1
        and     dp2.book_type_code = ict.corp_book
        and     dp2.period_counter = ict.period_counter;

        l_path_name VARCHAR2(150);
    Begin

        l_path_name := g_path||'prepare_data';

        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '********************************************************'
				    ||' Start of IAC Implementation :  Data Preparation Process'
				    ||'********************************************************');
        Set_Process_Status(p_book_type_code,'R');
        Commit;
        For C_Period_Info_Rec In C_Period_Info Loop
            IF p_book_class = 'TAX' Then
                If Prepare_Mhca_Data(p_book_type_code,
                                     C_Period_Info_Rec.book_last_per_counter,
                                     C_Period_Info_Rec.book_per_fiscal_year,
                                     C_Period_Info_Rec.corp_book,
                                     C_Period_Info_Rec.corp_last_per_counter,
                                     C_Period_Info_Rec.corp_per_fiscal_year,
                                     C_Period_Info_Rec.corp_curr_period_num,
                                     errbuf) Then
                    Set_Process_Status(p_book_type_code, 'C');
                Else
                    Set_Process_Status(p_book_type_code,'E');
                    retcode := 2;
                End if;
            Elsif p_book_class = 'CORPORATE' Then
                If Prepare_Corp_Data(p_book_type_code,
                                     C_Period_Info_Rec.corp_last_per_counter,
                                     C_Period_Info_Rec.corp_per_fiscal_year,
                                     C_Period_Info_Rec.corp_curr_period_num,
                                     errbuf) Then
                    Set_Process_Status(p_book_type_code, 'C');
                Else
                    Set_Process_Status(p_book_type_code,'E');
                    retcode := 2;
                End if;
            End if;
            Commit;
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '********************************************************'
				    ||' End of IAC Implementation :  Data Preparation Process'
				    ||'********************************************************');
        End Loop;
    Exception
        When Others Then
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     	    p_full_path => l_path_name,
		     	    p_string => '*** Error in IAC Implementation :  Data Preparation Process *** '
					|| sqlerrm);
            retcode := 2;
    End Prepare_Data;

    Function Prepare_Mhca_Data(p_book in varchar2,
                               p_book_last_per_counter in number,
                               p_book_curr_fiscal_year in number,
                               p_corp_book             in varchar2,
                               p_corp_last_per_counter in number,
                               p_corp_curr_fiscal_year in number,
                               p_corp_curr_period_num  in number,
                               p_out_message out NOCOPY varchar2 ) Return Boolean Is

        Cursor  C_Mhca_Reval_Details(p_asset_id in number,
                                     p_period_counter in number) Is
        Select  sum(number_of_units_assigned) units,
                nvl(sum(asset_cost),0) asset_cost,
                nvl(sum(accumulated_depreciation),0) accumulated_depreciation,
                nvl(sum(prior_yrs_accum_depreciation),0) prior_yrs_accum_depreciation,
                nvl(sum(ytd_depreciation_reserve),0) ytd_depreciation_reserve,
                nvl(sum(curr_mhc_prd_backlog_deprn),0) curr_mhc_prd_backlog_deprn,
                nvl(sum(accumulated_backlog_deprn),0) accumulated_backlog_deprn,
                nvl(sum(net_book_value),0) net_book_value,
                nvl(sum(revaluation_reserve),0) revaluation_reserve,
                nvl(sum(depreciation_expense),0) depreciation_expense,
                nvl(sum(curr_yr_prior_prds_deprn),0) curr_yr_prior_prds_deprn,
                nvl(sum(curr_yr_prior_prds_deprn_reval) ,0) curr_yr_prior_prds_deprn_reval,
                nvl(sum(prior_year_operating_expense),0) prior_year_operating_expense,
                nvl(sum(general_fund),0) general_fund,
                nvl(sum(accumulated_general_fund),0) accumulated_general_fund
        From    igi_mhc_revaluation_detail
        Where   book_type_code = p_book
        And     period_counter = p_period_counter
        And     asset_id = p_asset_id
        And     reval_mode = 'INDEXED'
        And     active_flag= 'Y'
        And     Run_mode = 'L'
        Group by asset_id;

        Cursor C_Max_Period_Counter(p_asset_id in number) Is
        Select  max(period_counter) period_counter
        From    igi_mhc_revaluation_summary
        Where   book_type_code = p_book
        and     asset_id = p_asset_id
        and     reval_mode = 'INDEXED'
        and     active_flag= 'Y'
        and     run_mode = 'L';

        Cursor C_Mhca_Reval_Summary(p_asset_id in number,
                                    p_period_counter in number) Is
        Select  nvl(original_cost,0) original_cost,
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
        From    igi_mhc_revaluation_summary
        Where   book_type_code = p_book
        and     period_counter = p_period_counter
        and     asset_id = p_asset_id
        and     reval_mode = 'INDEXED'
        and     active_flag= 'Y'
        and     Run_mode = 'L';


        l_mhca_reval_details C_Mhca_Reval_Details%Rowtype;
        l_mhca_reval_summary C_Mhca_Reval_Summary%Rowtype;

        l_initialise_reval_details C_Mhca_Reval_Details%Rowtype;
        l_initialise_reval_summary C_Mhca_Reval_Summary%Rowtype;
        l_path_name VARCHAR2(150);
    Begin

        l_path_name := g_path||'prepare_mhca_data';

        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '*** Start of Prepare Mhca Data ***'
				    ||'*** Parameter Last Period Counter for Mhca Book is : '
				    || p_book_last_per_counter
				    ||'*** Parameter Last Period Counter for Corp Book is : '
				    || p_corp_last_per_counter);

        For C_Asset_Category_Rec In C_Asset_Category(p_book) Loop
            l_cat_records := 0;
            l_rec_ctr := 1;
            For C_Book_Info_Rec in C_Book_Info(p_book, C_Asset_Category_Rec.category_id) Loop
  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'Processing Asset for Book : ' || p_book ||
				    ' ,Category Id : ' || C_Asset_Category_Rec.category_id ||
				    ' ,Asset Number : ' || C_Book_Info_Rec.Asset_number ||
				    ' ,Asset Id : ' || C_Book_Info_Rec.Asset_id);

                Initialise_Variables(l_corp_book_info,
                                     l_corp_deprn_details,
                                     l_corp_deprn_summary,
                                     l_imp_interface,
                                     l_hist_info,
                                     l_fiscal_year,
                                     l_book_last_per_counter,
                                     l_corp_last_per_counter,
                                     l_exception_code,
                                     l_exception_flag);
                l_mhca_reval_details := l_initialise_reval_details;
                l_mhca_reval_summary := l_initialise_reval_summary;


                If l_rec_ctr > l_max_records then
                    l_rec_ctr := 1;
                End if;
                If l_rec_ctr = 1 then
                    Select igi_imp_iac_interface_group_s.nextval
                    Into l_group_id
                    From dual;
                End if;

                IF C_Book_Info_Rec.asset_type = 'CIP' THEN
                    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     			p_full_path => l_path_name,
		     			p_string => 'Asset is a CIP asset, Ignoring the asset');
                    goto Next_Record;
                END IF;

                IF C_Book_Info_Rec.cost < 0 THEN
                    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     			p_full_path => l_path_name,
		     			p_string => 'Asset is a negative asset, Ignoring the asset');
                    goto Next_Record;
                END IF;

                If C_Book_Info_Rec.period_counter_fully_retired is not null then

  		                igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     			p_full_path => l_path_name,
		     			p_string => 'Asset is fully retired in MHCA book, Ignoring the asset');

                       goto Next_Record;
                Else
                    l_book_last_per_counter := p_book_last_per_counter;
                End If;

  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '*** New Last Period Counter for Mhca Book is : '
					    || l_book_last_per_counter );

  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '*** Opening Cursor C_Mhca_Reval_Details for the asset ' ||
					    C_Book_Info_Rec.asset_id || ' ,Period Counter : '
					    || l_book_last_per_counter);

                Open C_Mhca_Reval_Details(C_Book_Info_Rec.asset_id,
                                          l_book_last_per_counter);
                Fetch C_Mhca_Reval_Details into l_MHca_reval_details;
                If C_Mhca_Reval_Details%notfound Then
  		    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		    		 p_full_path => l_path_name,
		     		 p_string => '??? C_Mhca_Reval_Details not found');
                End if;
                Close C_Mhca_Reval_Details;

  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '*** Opening Cursor C_Mhca_Reval_Details for the asset ' ||
					    C_Book_Info_Rec.asset_id || ' ,Period Counter : '
					    || l_book_last_per_counter);

                Open C_Mhca_Reval_Summary(C_Book_Info_Rec.asset_id,
                                          l_book_last_per_counter);
                Fetch C_Mhca_Reval_Summary Into l_mhca_reval_summary;
                If C_Mhca_Reval_Summary%notfound Then
  		    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		    		 p_full_path => l_path_name,
		     		 p_string => '??? C_Mhca_Reval_Summary not found');
                End if;
                Close C_Mhca_Reval_Summary;

  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '*** Opening Cursor C_Corp_Book_Info for the asset ' ||
					    C_Book_Info_Rec.asset_id || ' ,Book : ' || p_corp_book);

                Open C_Corp_Book_Info(p_corp_book, C_Book_Info_Rec.asset_id);
                Fetch C_Corp_Book_Info Into l_corp_book_info;
                If C_Corp_Book_Info%notfound then
  		    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		    		 p_full_path => l_path_name,
		     		 p_string => '??? C_Corp_book_Info not found');
                End if;
                Close C_Corp_Book_Info;

                IF l_Corp_Book_Info.cost < 0 THEN
                    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     			p_full_path => l_path_name,
		     			p_string => 'Asset is a negative asset, Ignoring the asset');
                    goto Next_Record;
                END IF;

                If l_Corp_Book_Info.period_counter_fully_retired is not null then
  		            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'Asset is fully retired in Corp book, Ignoring the asset');

                    goto Next_Record;

                Else
                    If l_Corp_Book_Info.period_counter_fully_reserved is not null then
  		        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		    		     p_full_path => l_path_name,
		     		     p_string => 'Asset in the Corp Book is fully reserved');

                        l_corp_last_per_counter := l_Corp_Book_Info.period_counter_fully_reserved;
                    Else
                       If upper(l_Corp_Book_Info.depreciate_flag) = 'NO' Then
  		          igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		    		     p_full_path => l_path_name,
		     		     p_string => 'Asset has depreciate flag set to No');

  		          igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		    		     p_full_path => l_path_name,
		     		     p_string => '*** Opening Cursor C_Corp_Max_Deprn_Ctr for Book : ' ||
						 p_corp_book || ' ,Asset Id : ' || C_Book_Info_Rec.asset_id);

                          Open C_Corp_Max_Period_Counter(p_corp_book,
                                                         C_Book_Info_Rec.asset_id);
                          Fetch C_Corp_Max_Period_Counter into l_Corp_last_per_counter;
                          If C_Corp_Max_Period_Counter%notfound then
  		             igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		    		     p_full_path => l_path_name,
		     		     p_string => '??? C_Corp_Max_Period_Counter not found');
                          End if;
                          Close C_Corp_Max_Period_Counter;
                       Else
                          l_corp_last_per_counter := p_corp_last_per_counter;
                       End if;
                    End if;
                End if;

	        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '*** New Last Period Counter for Corp Book is : '
					    || l_corp_last_per_counter);

	        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '*** Opening Cursor C_Corp_Deprn_Details for Book : '
					    || p_corp_book || ' ,Asset Id : ' || C_Book_Info_Rec.asset_id
					    || ' ,Period Counter : ' || l_corp_last_per_counter);

                Open C_Corp_Deprn_Details(p_corp_book,
                                          C_book_info_rec.asset_id,
                                          l_corp_last_per_counter);
                Fetch C_Corp_Deprn_Details Into l_corp_deprn_details;
                If C_Corp_Deprn_Details%notfound then
	            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '??? C_Corp_Deprn_Details not found');
                End if;
                Close C_Corp_Deprn_Details;

	        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string =>  '*** Opening Cursor C_Corp_Deprn_Summary for Book : '
					     || p_corp_book|| ' ,Asset Id : ' || C_Book_Info_Rec.asset_id
		                             || ' ,Period Counter : ' || l_corp_last_per_counter);

                Open C_Corp_Deprn_Summary(p_corp_book,
                                          C_book_info_rec.asset_id,
                                          l_corp_last_per_counter);
                Fetch C_Corp_Deprn_Summary Into l_corp_deprn_summary;
                If C_Corp_Deprn_Summary%notfound then
	            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'C_Corp_Deprn_Summary not found');
                End if;
                Close C_Corp_Deprn_Summary;


                If (abs((nvl(l_mhca_reval_summary.new_asset_cost,0) - nvl(l_mhca_reval_summary.new_reval_reserve,0))
                      - l_corp_book_info.cost )  <= 0.05 ) Then
                    null;
                Else
	            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'Cost Difference Exception flagged  for the Asset');

                    l_exception_code := 'C';
                    l_exception_flag := 'Y';
                End if;

                If l_exception_flag = 'N' Then
                   If trunc(C_Book_Info_Rec.date_placed_in_service) = trunc(l_corp_book_info.date_placed_in_service) Then
                      null;
                   Else
	              igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'DPIS Difference Exception flagged for the Asset');

                      l_exception_code := 'D';
                      l_exception_flag := 'Y';
                   End if;
                End if;

                If l_exception_flag = 'N' Then
                   If C_Book_Info_Rec.life_in_months = l_corp_book_info.life_in_months  Then
                      null;
                   Else
	              igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'Life Difference Exception flagged for the Asset');

                      l_exception_code := 'L';
                      l_exception_flag := 'Y';
                   End if;
                End if;

                If l_exception_flag = 'N' Then
                   If C_Book_Info_Rec.salvage_value = l_corp_book_info.salvage_value Then
                      null;
                   Else
	              igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'Salvage Value Difference Exception flagged for the Asset');

                      l_exception_code := 'S';
                      l_exception_flag := 'Y';
                   End if;
                End if;

                l_imp_interface.asset_id := C_Book_Info_Rec.asset_id;
                l_imp_interface.asset_number := C_Book_Info_Rec.asset_number;
                l_imp_interface.book_type_code := p_book;
                l_imp_interface.category_id :=  C_Asset_Category_Rec.category_id;
                l_imp_interface.hist_salvage_value := l_corp_book_info.salvage_value;
                l_imp_interface.life_in_months :=  C_Book_Info_Rec.life_in_months;
                l_imp_interface.cost_hist := l_corp_book_info.cost;
                l_imp_interface.cost_mhca :=  l_mhca_reval_summary.New_asset_cost;

                IF l_Corp_Book_Info.period_counter_fully_reserved is null then
                    l_imp_interface.deprn_exp_hist := l_corp_deprn_details.deprn_amount - l_corp_deprn_details.deprn_adjustment_amount;
                    l_imp_interface.deprn_exp_mhca := l_mhca_reval_details.depreciation_expense;
                ELSE
                    l_imp_interface.deprn_exp_hist := 0;
                    l_imp_interface.deprn_exp_mhca := 0;
                END IF;

                l_hist_info.cost := l_corp_book_info.cost;
                l_hist_info.adjusted_cost := l_corp_book_info.adjusted_cost;
                l_hist_info.original_cost := l_corp_book_info.original_cost;
                l_hist_info.salvage_value := l_corp_book_info.salvage_value;
                l_hist_info.life_in_months := l_corp_book_info.life_in_months;
                l_hist_info.rate_adjustment_factor := l_corp_book_info.rate_adjustment_factor;
                l_hist_info.period_counter_fully_reserved := l_corp_book_info.period_counter_fully_reserved;
                l_hist_info.adjusted_recoverable_cost := l_corp_book_info.adjusted_recoverable_cost;
                l_hist_info.recoverable_cost := l_corp_book_info.recoverable_cost;
                l_hist_info.date_placed_in_service := l_corp_book_info.date_placed_in_service;
                l_hist_info.last_period_counter := l_corp_last_per_counter;
                l_hist_info.gl_posting_allowed_flag := NULL;
                l_hist_info.ytd_deprn  := l_Corp_Deprn_Summary.ytd_deprn;
                l_hist_info.deprn_reserve := l_corp_deprn_summary.deprn_reserve;
                l_hist_info.deprn_amount := l_corp_deprn_summary.deprn_amount;
                l_hist_info.deprn_start_date :=  l_corp_book_info.deprn_start_date;
                l_fiscal_year := NULL;
                Open C_Fiscal_Year(p_corp_book, l_corp_last_per_Counter);
                Fetch C_Fiscal_Year Into l_fiscal_year;
                Close C_Fiscal_Year;

                If p_corp_curr_fiscal_year <> l_fiscal_year then
                   l_imp_interface.ytd_hist := 0;
                Else
                   If p_corp_curr_period_num = 1 Then
                      l_imp_interface.ytd_hist := 0;
                   Else
                      If igi_iac_reval_utilities.Populate_depreciation(
                              C_book_info_rec.asset_id,
                              p_corp_book,
                              l_corp_last_per_counter,
                              l_hist_info ) Then
                         L_imp_interface.ytd_hist :=
                           ( l_Corp_Deprn_Summary.deprn_reserve
                             * (l_hist_info.deprn_periods_current_year/l_hist_info.deprn_periods_elapsed));
                      Else
                         fnd_message.set_name ('IGI', 'IGI_IMP_IAC_PREP_ERROR');
                         fnd_message.set_token('ROUTINE','igi_iac_reval_utilities.Populate_depreciation');
  			 igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		  			p_full_path => l_path_name,
		 			p_remove_from_stack => FALSE);
                         p_out_message := fnd_message.get;
                         Raise Prepare_Data_Error;
                      End if;
                   End if;
                End if;

                l_imp_interface.ytd_mhca := l_mhca_reval_details.ytd_depreciation_reserve;
                l_imp_interface.accum_deprn_hist := l_corp_deprn_summary.deprn_reserve;
                l_imp_interface.accum_deprn_mhca := l_mhca_reval_summary.new_accum_deprn - l_mhca_reval_summary.new_backlog_deprn;
                l_imp_interface.reval_reserve_hist :=  l_corp_deprn_summary.reval_reserve;
                l_imp_interface.reval_reserve_mhca := l_mhca_reval_summary.new_reval_reserve - l_mhca_reval_summary.New_backlog_deprn;
                l_imp_interface.backlog_hist := 0 ;
                l_imp_interface.backlog_mhca :=  l_mhca_reval_summary.new_backlog_deprn;
                l_imp_interface.general_fund_hist :=  0;
                l_imp_interface.general_fund_mhca := 0;
                l_imp_interface.general_fund_per_hist := 0;
                l_imp_interface.general_fund_per_mhca := 0;
                l_imp_interface.operating_account_hist := 0;
                l_imp_interface.operating_account_mhca :=0;
                l_imp_interface.operating_account_ytd_hist := 0;
                l_imp_interface.operating_account_ytd_mhca :=0;
                l_imp_interface.operating_account_cost :=  0;
                l_imp_interface.operating_account_backlog :=  0;
                l_imp_interface.nbv_hist :=  l_corp_book_info.cost - l_corp_deprn_summary.deprn_reserve;
                l_imp_interface.nbv_mhca := l_mhca_reval_details.net_book_value ;
                l_imp_interface.transferred_Flag := 'N';
                l_imp_interface.valid_flag := 'Y'; -- Added as a part of fix for Bug 5137813
                l_imp_interface.selected_Flag :=  'N';
                l_imp_interface.exception_Flag := l_exception_flag;
                l_imp_interface.exception_Code := l_exception_code;
                l_imp_interface.group_id := l_group_id;
                l_imp_interface.export_file :=  NULL;
                l_imp_interface.export_date := NULL;
                l_imp_interface.import_file :=  NULL;
                l_imp_interface.import_date :=  NULL;
                l_imp_interface.created_by :=  fnd_global.user_id;
                l_imp_interface.creation_date := sysdate;
                l_imp_interface.last_updated_by := fnd_global.user_id;
                l_imp_interface.last_update_date := sysdate;
                l_imp_interface.last_update_login := fnd_global.login_id;
                l_imp_interface.request_id := fnd_global.conc_request_id;
                l_imp_interface.program_application_id := fnd_global.prog_appl_id;
                l_imp_interface.program_id := fnd_global.conc_program_id;
                l_imp_interface.program_update_date := sysdate;

                Populate_Interface(l_imp_interface);
                l_cat_records := l_cat_records + 1;
                l_rec_ctr := l_rec_ctr + 1;
                <<Next_Record>>
                    Null;
            End Loop;
            If l_cat_records > 0 then
               Populate_Interface_control( p_book, C_Asset_Category_Rec.category_id);
            End if;
        End Loop;
        Return TRUE;
    Exception
        When Prepare_Data_Error Then
            If C_Fiscal_Year%isopen then
                Close C_Fiscal_Year;
            End if;
            If C_Max_Period_Counter%isopen Then
                Close C_Max_Period_Counter;
            End if;
            If C_Mhca_Reval_Details%isopen Then
                Close C_Mhca_Reval_Details;
            End if;
            If C_Mhca_Reval_Summary%isopen Then
                Close C_Mhca_Reval_Summary;
            End if;
            If C_Corp_Book_Info%isopen Then
                Close C_Corp_Book_Info;
            End if;
            If C_Corp_Deprn_Details%isopen Then
                Close C_Corp_Deprn_Details;
            End if;
            If C_Corp_Deprn_Summary%isopen Then
                Close C_Corp_Deprn_Summary;
            End if;
            If C_Corp_Max_Period_Counter%isopen Then
                Close C_Corp_Max_Period_Counter;
            End if;
            Rollback work;
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     	p_full_path => l_path_name,
		    	p_string => 'Error : ' || p_out_message);
	    fnd_file.put_line(fnd_file.log, p_out_message);
            Return False;
        When Others Then
            If C_Fiscal_Year%isopen Then
                Close C_Fiscal_Year;
            End if;
            If C_Max_Period_Counter%isopen Then
                Close C_Max_Period_Counter;
            End if;
            If C_Mhca_Reval_Details%isopen Then
                Close C_Mhca_Reval_Details;
            End if;
            If C_Mhca_Reval_Summary%isopen Then
                Close C_Mhca_Reval_Summary;
            End if;
            If C_Corp_Book_Info%isopen Then
                Close C_Corp_Book_Info;
            End if;
            If C_Corp_Deprn_Details%isopen Then
                Close C_Corp_Deprn_Details;
            End if;
            If C_Corp_Deprn_Summary%isopen Then
                Close C_Corp_Deprn_Summary;
            End if;
            If C_Corp_Max_Period_Counter%isopen Then
                Close C_Corp_Max_Period_Counter;
            End if;
            Rollback work;
  	    igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
            Return FALSE;
    End Prepare_Mhca_Data;

    FUNCTION Prepare_Corp_Data (
        p_corp_book              in  varchar2,
        p_corp_last_per_counter  in  number,
        p_corp_curr_fiscal_year  in  number,
        p_corp_curr_period_num   in number,
        p_out_message            out NOCOPY varchar2  ) Return Boolean Is

	/* Bug 2961656 vgadde 08-jul-03 start(1) */
        CURSOR C_Get_User_Deprn(p_asset_id in number ) IS
        SELECT period_counter, deprn_reserve, ytd_deprn
        FROM fa_deprn_summary
        WHERE book_type_code = p_corp_book
        AND asset_id = p_asset_id
        AND deprn_source_code = 'BOOKS';
	/* Bug 2961656 vgadde 08-jul-03 end(1) */

        Cursor C_Prior_Add(p_book in varchar2,
                           p_category_id in number,
                           p_asset_id in number) Is
        Select
            Asset_id,
            Asset_number,
            Book_type_code,
            Category_id,
            Period_counter,
            Net_book_value,
            Adjusted_cost,
            Operating_acct,
            Reval_reserve,
            Deprn_amount,
            Deprn_reserve,
            Backlog_deprn_reserve,
            General_fund,
            Hist_cost,
            Hist_deprn_expense,
            Hist_ytd,
            Hist_accum_deprn,
            Hist_life_in_months,
            Hist_nbv,
            Hist_salvage_value,
            General_fund_Periodic,
            Operating_account_ytd,
            cummulative_reval_factor,
            current_reval_factor
        From igi_imp_iac_interface_py_add
        Where book_type_code = p_book
              and category_id = p_category_id
              and asset_id = p_asset_id;

        l_deprn_acc number;
	/* Bug 2961656 vgadde 08-jul-03 start(2) */
        l_deprn_ytd number;
        l_booksrow_counter number;
        l_booksrow_period igi_iac_types.prd_rec;
	/* Bug 2961656 vgadde 08-jul-03 end(2) */
        l_prior_addition c_prior_add%Rowtype;
        l_initialise_addition c_prior_add%Rowtype;
        l_dpis_period_counter   number;
        l_current_year_addition boolean;
        l_path_name VARCHAR2(150);
        l_fa_ytd_derpn  number;
        l_last_deprn_period igi_iac_types.prd_rec;

    Begin

        l_current_year_addition := TRUE;
        l_path_name := g_path||'prepare_corp_data';

        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '*** Start of Prepare Corp Data ***' );

  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '*** Parameter Last Period Counter for Corp Book is : '
				 || p_corp_last_per_counter);

        For C_Asset_Category_Rec In C_Asset_Category(p_corp_book) Loop
            l_cat_records := 0;
            l_rec_ctr := 1;
            For C_Book_Info_Rec in C_Book_Info(p_corp_book, C_Asset_Category_Rec.category_id) Loop
              		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		        	p_full_path => l_path_name,
		     		p_string => 'Processing Asset for Book : ' || p_corp_book ||
					    ' ,Category Id : ' || C_Asset_Category_Rec.category_id ||
					    ' ,Asset Number : ' || C_Book_Info_Rec.Asset_number ||
					    ' ,Asset Id : ' || C_Book_Info_Rec.Asset_id);

                Initialise_Variables(l_corp_book_info,
                                     l_corp_deprn_details,
                                     l_corp_deprn_summary,
                                     l_imp_interface,
                                     l_hist_info,
                                     l_fiscal_year,
                                     l_book_last_per_counter,
                                     l_corp_last_per_counter,
                                     l_exception_code,
                                     l_exception_flag);
                l_deprn_acc := NULL;
                l_prior_addition := l_initialise_addition;

                If l_rec_ctr > l_max_records then
                    l_rec_ctr := 1;
                End if;
                If l_rec_ctr = 1 then
                    Select igi_imp_iac_interface_group_s.nextval
                    Into l_group_id
                    From dual;
              		    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		         		p_full_path => l_path_name,
		    	    	p_string => 'The new group Id is : ' || l_group_id);
                End if;

                l_current_year_addition := True;

                IF C_Book_Info_Rec.asset_type = 'CIP' THEN
                    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     			p_full_path => l_path_name,
		     			p_string => 'Asset is a CIP asset, Ignoring the asset');
                    goto Next_Record;
                END IF;

                IF C_Book_Info_Rec.cost < 0 THEN
                        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     			p_full_path => l_path_name,
		     			p_string => 'Asset is a negative asset, Ignoring the asset');
                    goto Next_Record;
                END IF;

                If C_Book_Info_Rec.period_counter_fully_retired is not null then
      		            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	    	            p_full_path => l_path_name,
		        		p_string => 'Asset is fully retired, Ignoring the asset');
                        goto Next_Record;
                Else
                    If C_Book_Info_Rec.period_counter_fully_reserved is not null then

          		            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		             		p_full_path => l_path_name,
		    	        	p_string => 'Asset in the Corp_book is fully reserved');

                        l_corp_last_per_counter := C_Book_Info_Rec.period_counter_fully_reserved;

                    Else

                       If upper(C_Book_Info_Rec.depreciate_flag) = 'NO' Then

              		          igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
    		     	          	p_full_path => l_path_name,
		        		        p_string => 'Asset has depreciate flag set to No');

              		          igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		             		   p_full_path => l_path_name,
    		    		        p_string => '*** Opening Cursor C_Corp_Max_Deprn_Ctr for Book : '
	        				    || p_corp_book|| ' ,Asset Id : ' || C_Book_Info_Rec.asset_id);

                              Open C_Corp_Max_Period_Counter(p_corp_book,
                                                             C_Book_Info_Rec.asset_id);
                              Fetch C_Corp_Max_Period_Counter into l_Corp_last_per_counter;
                              If C_Corp_Max_Period_Counter%notfound then
  			                      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
    		             			p_full_path => l_path_name,
	        	         	    		p_string => '??? C_Corp_Max_Period_Counter not found');
                              End if;
                              Close C_Corp_Max_Period_Counter;

                	      IF l_Corp_last_per_counter IS NULL THEN

                    	   	   Select max(Period_counter)
                    		   Into   l_Corp_last_per_counter
                          	   From   fa_deprn_summary
                                   Where  book_type_code = p_corp_book
                                     and  asset_id = C_Book_Info_Rec.asset_id;

         	    	      END IF;

                              IF NOT igi_iac_common_utils.get_period_info_for_counter(
                                                        p_corp_book,
                                                        l_Corp_last_per_counter,
                                                       l_last_deprn_period) THEN
                                    fnd_message.set_name ('IGI', 'IGI_IMP_IAC_PREP_ERROR');
                                    fnd_message.set_token('ROUTINE','igi_iac_common_utils.get_period_info_for_counter');
      			                    igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		  			                p_full_path => l_path_name,
		  			                p_remove_from_stack => FALSE);
                                    p_out_message := fnd_message.get;
                                    Raise Prepare_Data_Error;
                            END IF;
                       Else
                            l_corp_last_per_counter := p_corp_last_per_counter;
                       End if;
                    End if;
                End if;
    		/* Bug 2961656 vgadde 08-jul-03 start(3) */
  		        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			    p_full_path => l_path_name,
		     	    p_string => '*** Opening Cursor C_Corp_Deprn_Summary for Book : ' || p_corp_book
					|| ' ,Asset Id : ' || C_Book_Info_Rec.asset_id
					|| ' ,Period Counter : ' || l_corp_last_per_counter);

                Open C_Corp_Deprn_Summary(p_corp_book,
                                          C_book_info_rec.asset_id,
                                          l_corp_last_per_counter);
                Fetch C_Corp_Deprn_Summary Into l_corp_deprn_summary;
                If C_Corp_Deprn_Summary%notfound then
  		           igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'C_Corp_Deprn_Summary not found');
                    l_corp_deprn_summary.deprn_reserve := 0;
                    l_corp_deprn_summary.ytd_deprn := 0;
                End if;
                Close C_Corp_Deprn_Summary;

		  IF (upper(C_Book_Info_Rec.depreciate_flag) = 'NO') THEN

               		 IF ((l_last_deprn_period.fiscal_year < p_corp_curr_fiscal_year)
                   	 ) THEN

                   	 l_corp_deprn_summary.ytd_deprn := 0;
                       	 igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
    	         		p_full_path => l_path_name,
	    	     		p_string => 'Non Dpreciating C_Corp_Deprn_Summary found'|| l_corp_deprn_summary.ytd_deprn);

                	END IF;
             END IF;

  		           igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			        p_full_path => l_path_name,
		     		p_string => '*** Opening Cursor C_Get_User_Deprn for Asset Id : '
					    || C_Book_Info_Rec.asset_id);

                Open C_Get_User_Deprn(C_book_info_rec.asset_id);
                Fetch C_Get_User_Deprn Into l_booksrow_counter, l_deprn_acc, l_deprn_ytd;
                If C_Get_User_Deprn%notfound Then
                    l_booksrow_counter := NULL;
                    l_deprn_acc := NULL;
                    l_deprn_ytd := NULL;
          		    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		    		 p_full_path => l_path_name,
		     		 p_string => '??? C_Get_User_Deprn not found');
                End if;
                Close C_Get_User_Deprn;

                IF l_booksrow_counter IS NOT NULL THEN
                    l_booksrow_counter := l_booksrow_counter + 1;
                    IF NOT igi_iac_common_utils.get_period_info_for_counter(
                                                        p_corp_book,
                                                        l_booksrow_counter,
                                                        l_booksrow_period) THEN
                        fnd_message.set_name ('IGI', 'IGI_IMP_IAC_PREP_ERROR');
                        fnd_message.set_token('ROUTINE','igi_iac_common_utils.get_period_info_for_counter');
  			            igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		  			        p_full_path => l_path_name,
		  			    p_remove_from_stack => FALSE);
                        p_out_message := fnd_message.get;
                        Raise Prepare_Data_Error;
                    END IF;

                    IF (l_booksrow_period.fiscal_year <> p_corp_curr_fiscal_year) OR
                        (nvl(l_deprn_acc,0) = 0) THEN
                        l_fa_ytd_derpn :=     l_corp_deprn_summary.ytd_deprn;
                        l_corp_deprn_summary.ytd_deprn := NULL;
                        l_current_year_addition := FALSE;
                    END IF;
                END IF;

                If Not IGI_IAC_ADDITIONS_PKG.Do_Addition(
                                                    p_corp_book,
                                                    C_Book_Info_Rec.asset_id,
                                                    C_Asset_Category_Rec.category_id,
                                                    null, null,null,null,null,null,
                                                    l_corp_deprn_summary.deprn_reserve,
                                                    l_corp_deprn_summary.ytd_deprn,
                                                    'UPGRADE',NULL)Then
                        fnd_message.set_name ('IGI', 'IGI_IMP_IAC_PREP_ERROR');
                        fnd_message.set_token('ROUTINE','igi_iac_additions_pkg.do_prior_addition');
              			igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		  	        		p_full_path => l_path_name,
		  		        	p_remove_from_stack => FALSE);
                             p_out_message := fnd_message.get;
                        Raise Prepare_Data_Error;
                Else
  			            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     			p_full_path => l_path_name,
		     			p_string => 'Prior Addition is successful');

  	            		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
    		        	p_full_path => l_path_name,
		     			p_string => '*** Opening Cursor C_Prior_add for Book : ' || p_corp_book
						    || ' ,Asset Id : ' || C_Book_Info_Rec.asset_id
						    || ' ,Category Id ' || C_Asset_Category_Rec.category_id);

                        Open C_Prior_Add(p_corp_book,
                                         C_Asset_Category_Rec.category_id,
                                         C_Book_Info_Rec.asset_id);
                        Fetch C_Prior_Add Into l_prior_addition;

                        If C_Prior_Add%notfound Then
          			    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     			p_full_path => l_path_name,
		     			p_string => '??? C_Prior_Add not found, Skipping the Asset');
                           Close C_Prior_Add;
                           Goto Next_Record;
                        End if;
                        Close C_Prior_Add;
                End if;
		/* Bug 2961656 vgadde 08-jul-03 end(3) */

                        IF l_corp_deprn_summary.ytd_deprn is null Then
                                l_corp_deprn_summary.ytd_deprn:=  l_fa_ytd_derpn;

                        End if;


          		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '*** New Last Period Counter for Corp Book is : '
					    || l_corp_last_per_counter);
  		            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '*** Opening Cursor C_Corp_Deprn_Details for Book : '
					    || p_corp_book|| ' ,Asset Id : ' || C_Book_Info_Rec.asset_id
					    || ' ,Period Counter : ' || l_corp_last_per_counter);
                Open C_Corp_Deprn_Details(p_corp_book,
                                          C_book_info_rec.asset_id,
                                          l_corp_last_per_counter);
                Fetch C_Corp_Deprn_Details Into l_corp_deprn_details;
                If C_Corp_Deprn_Details%notfound then
  	            	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
    		    		 p_full_path => l_path_name,
		     		 p_string => '??? C_Corp_Deprn_Details not found');
                End if;
                Close C_Corp_Deprn_Details;

                l_imp_interface.Asset_id := l_prior_addition.Asset_id;
                l_imp_interface.Asset_number :=  l_prior_addition.Asset_number;
                l_imp_interface.Book_type_code := p_corp_book;
                l_imp_interface.Category_Id :=  l_prior_addition.Category_id;
                l_imp_interface.Hist_salvage_value := l_prior_addition.Hist_salvage_value;
                l_imp_interface.Life_in_months :=  l_prior_addition.Hist_life_in_months;
                l_imp_interface.Cost_hist := l_prior_addition.Hist_cost;
                l_imp_interface.Cost_mhca :=  l_prior_addition.Hist_cost + l_prior_addition.Adjusted_cost;
                IF C_book_info_rec.period_counter_fully_reserved IS NULL THEN
                    l_imp_interface.Deprn_exp_hist := l_prior_addition.Hist_deprn_expense;
                    l_imp_interface.Deprn_exp_mhca := l_prior_addition.Hist_deprn_expense  + l_prior_addition.Deprn_amount;
                ELSE
                    l_imp_interface.deprn_exp_hist := 0;
                    l_imp_interface.deprn_exp_mhca := 0;
                END IF;



                l_hist_info.cost := C_book_info_rec.cost;
                l_hist_info.adjusted_cost := C_book_info_rec.adjusted_cost;
                l_hist_info.original_cost := C_book_info_rec.original_cost;
                l_hist_info.salvage_value := C_book_info_rec.salvage_value;
                l_hist_info.life_in_months := C_book_info_rec.life_in_months;
                l_hist_info.rate_adjustment_factor := C_book_info_rec.rate_adjustment_factor;
                l_hist_info.period_counter_fully_reserved := C_book_info_rec.period_counter_fully_reserved;
                l_hist_info.adjusted_recoverable_cost := C_book_info_rec.adjusted_recoverable_cost;
                l_hist_info.recoverable_cost := C_book_info_rec.recoverable_cost;
                l_hist_info.date_placed_in_service := C_book_info_rec.date_placed_in_service;
                l_hist_info.last_period_counter := l_corp_last_per_counter;
                l_hist_info.gl_posting_allowed_flag := NULL;
                l_hist_info.ytd_deprn  := 0;
                l_hist_info.deprn_reserve := l_corp_deprn_summary.deprn_reserve;
                l_hist_info.deprn_amount := 0;
                l_hist_info.deprn_start_date := C_book_info_rec.deprn_start_date;
                l_hist_info.depreciate_flag  := C_book_info_rec.depreciate_flag;

                IF NOT l_current_year_addition THEN
                	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		    			 p_full_path => l_path_name,
			                          p_string => ' Depreciation Reserve:'||l_hist_info.deprn_reserve);

	            	IF  ( NOT l_hist_info.salvage_value is Null) or (NOT  l_hist_info.salvage_value=0) THEn
                        	IF NOT igi_iac_salvage_pkg.correction(C_book_info_rec.asset_id,
                                                      l_imp_interface.Book_type_code,
                                                      l_hist_info.deprn_reserve,
                                                      l_hist_info.cost,
                                                      l_hist_info.salvage_value,
                                                      P_calling_program=>'IMPLEMENTATTION') THEN

	                     	return false;
        	         END IF;
                      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		    			 p_full_path => l_path_name,
		    			 p_string => ' Depreciation Reserve Salvage value corrected:'||l_hist_info.deprn_reserve);
                    EnD IF;

                      IF NOT igi_iac_ytd_engine.Calculate_YTD
                                ( p_corp_book,
                                C_book_info_rec.asset_id,
                                l_hist_info,
                                l_dpis_period_counter,
                                l_corp_last_per_counter,
                                'UPGRADE') THEN

                         fnd_message.set_name ('IGI', 'IGI_IMP_IAC_PREP_ERROR');
                         fnd_message.set_token('ROUTINE','igi_iac_ytd_engine.Calculate_YTD');
          		         igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		      		   	p_full_path => l_path_name,
		  	    		p_remove_from_stack => FALSE);
                         p_out_message := fnd_message.get;
                          Raise Prepare_Data_Error;
                      END IF;

    		        l_imp_interface.ytd_hist := l_hist_info.ytd_deprn;
               Else
                    l_hist_info.ytd_deprn  :=l_corp_deprn_summary.ytd_deprn;
                    --- salvage value YTD --
                                        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		    			 p_full_path => l_path_name,
		    			 p_string => ' YTD before salvage corrected:'||l_hist_info.ytd_deprn );

                    IF  ( NOT l_hist_info.salvage_value is Null) or (NOT  l_hist_info.salvage_value=0) THEn
                        	IF NOT igi_iac_salvage_pkg.correction(C_book_info_rec.asset_id,
                                                      l_imp_interface.Book_type_code,
                                                      l_hist_info.ytd_deprn,
                                                      l_hist_info.cost,
                                                      l_hist_info.salvage_value,
                                                      P_calling_program=>'IMPLEMENTATTION') THEN

	                     	return false;
        	         END IF;
                         igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		    			 p_full_path => l_path_name,
		    			 p_string => ' YTD Salvage value corrected:'||l_hist_info.ytd_deprn );
                    END IF;
                    l_imp_interface.ytd_hist := l_hist_info.ytd_deprn;
                END IF;
          		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			        p_full_path => l_path_name,
            		p_string => ' Historic Depreciation YTD :'||l_imp_interface.ytd_hist);




  	            	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			        p_full_path => l_path_name,
		     		p_string => ' IAC Depreciation YTD      :'||l_imp_interface.ytd_mhca);

                IF NOT( Igi_Iac_Common_Utils.Iac_Round (  l_imp_interface.Deprn_exp_hist             ,
                                                      p_corp_book )) THEN
                   null;
                END IF;

                IF NOT( Igi_Iac_Common_Utils.Iac_Round (  l_imp_interface.Deprn_exp_mhca             ,
                                                      p_corp_book )) THEN
                   null;
                END IF;

                l_imp_interface.Accum_deprn_hist := l_corp_deprn_summary.deprn_reserve;
                l_imp_interface.Accum_deprn_mhca := l_corp_deprn_summary.deprn_reserve + l_prior_addition.Deprn_reserve  ;
                l_imp_interface.Reval_reserve_hist :=  l_corp_deprn_summary.Reval_reserve;
                l_imp_interface.Reval_reserve_mhca := l_prior_addition.Reval_reserve;
                l_imp_interface.Backlog_hist :=  0;
                l_imp_interface.Backlog_mhca :=  l_prior_addition.Backlog_Deprn_reserve;
                l_imp_interface.General_fund_hist :=  0;
                l_imp_interface.General_fund_mhca := l_prior_addition.General_fund;
                l_imp_interface.General_fund_per_hist := 0;
                l_imp_interface.General_fund_per_mhca := l_prior_addition.Deprn_amount;
                l_imp_interface.Operating_account_hist := 0;
                l_imp_interface.Operating_account_mhca := l_prior_addition.Operating_acct;
                l_imp_interface.Operating_account_ytd_hist := 0;
                l_imp_interface.Operating_account_ytd_mhca :=0;

                If l_imp_interface.Cost_mhca > l_prior_addition.Hist_cost then
                   l_imp_interface.Operating_account_cost := 0;
                Else
                   l_imp_interface.Operating_account_cost := l_prior_addition.Adjusted_cost;
                End if;

                    l_fiscal_year := NULL;
                    Open C_Fiscal_Year(p_corp_book, l_corp_last_per_Counter);
                    Fetch C_Fiscal_Year Into l_fiscal_year;
                    Close C_Fiscal_Year;

                 -- For non depreciating asset interface and FA have same values
                    If upper(C_Book_Info_Rec.depreciate_flag) = 'NO' THEN
                        l_imp_interface.ytd_hist:= l_corp_deprn_summary.ytd_deprn;
                        l_imp_interface.Ytd_mhca := l_imp_interface.ytd_hist;
                        l_imp_interface.Accum_deprn_hist := l_corp_deprn_summary.deprn_reserve;
                        l_imp_interface.Accum_deprn_mhca := l_corp_deprn_summary.deprn_reserve;
                    ELSE
                        l_imp_interface.Ytd_mhca := nvl(l_imp_interface.ytd_hist,0) * (l_prior_addition.cummulative_reval_factor -1) ;
                        -- get back the FA YTD to interface table
                         l_imp_interface.ytd_hist:= l_corp_deprn_summary.ytd_deprn;
                         l_imp_interface.Ytd_mhca :=l_imp_interface.ytd_hist +  Nvl(l_imp_interface.Ytd_mhca,0);
                End if;

                If p_corp_curr_fiscal_year <> l_fiscal_year then
                          l_imp_interface.ytd_hist := 0;
                          l_imp_interface.Ytd_mhca := 0;
                 Else
                          If p_corp_curr_period_num = 1 Then
                            l_imp_interface.ytd_hist := 0;
                              l_imp_interface.Ytd_mhca := 0;
                          End if;
                End if;

                l_imp_interface.Operating_account_backlog :=
                                l_imp_interface.Operating_account_cost - l_imp_interface.Operating_account_mhca;

                l_imp_interface.Nbv_hist := l_prior_addition.hist_nbv;
                l_imp_interface.Nbv_mhca := l_prior_addition.hist_nbv + l_prior_addition.Net_book_value;
                l_imp_interface.Transferred_flag := 'N';
                l_imp_interface.Valid_flag := 'Y'; -- Added as a part of fix for Bug 5137813
                l_imp_interface.Selected_flag :=  'Y';
                l_imp_interface.Exception_flag := l_exception_flag;
                l_imp_interface.Exception_code := l_exception_code;
                l_imp_interface.Group_id := l_group_id;
                l_imp_interface.Export_file :=  NULL;
                l_imp_interface.Export_date := NULL;
                l_imp_interface.Import_file :=  NULL;
                l_imp_interface.Import_date :=  NULL;
                l_imp_interface.Created_by :=  fnd_global.user_id;
                l_imp_interface.Creation_date := sysdate;
                l_imp_interface.Last_Updated_by := fnd_global.user_id;
                l_imp_interface.Last_Update_date := sysdate;
                l_imp_interface.Last_update_login := fnd_global.login_id;
                l_imp_interface.Request_id := fnd_global.conc_request_id;
                l_imp_interface.Program_application_id := fnd_global.prog_appl_id;
                l_imp_interface.Program_id := fnd_global.conc_program_id;
                l_imp_interface.Program_update_date := sysdate;


                 If C_Book_Info_Rec.period_counter_fully_reserved is not null then
                     l_imp_interface.Accum_deprn_mhca := l_imp_interface.Accum_deprn_mhca +  l_prior_addition.Net_book_value;
                     l_imp_interface.General_fund_mhca:= l_imp_interface.Reval_reserve_mhca+
                                                         l_imp_interface.General_fund_mhca;
                     l_imp_interface.Reval_reserve_mhca:=0;
                     l_prior_addition.Net_book_value:=0;
                     l_imp_interface.Nbv_mhca := l_prior_addition.hist_nbv + l_prior_addition.Net_book_value;
                 End if;


                 IF NOT( Igi_Iac_Common_Utils.Iac_Round (  l_imp_interface.ytd_hist             ,
                                                    p_corp_book )) THEN
                   null;
                END IF;
                IF NOT( Igi_Iac_Common_Utils.Iac_Round (  l_imp_interface.Ytd_mhca             ,
                                                      p_corp_book )) THEN
                   null;
                END IF;


                Populate_Interface(l_imp_interface);
                l_cat_records := l_cat_records + 1;
                l_rec_ctr := l_rec_ctr + 1;
                <<Next_Record>>
                    Null;
            End Loop;
            If l_cat_records > 0 then
               Populate_Interface_control( p_corp_book, C_Asset_Category_Rec.category_id);
            End if;
        End Loop;
        Return TRUE;


        Exception
            When Prepare_Data_Error Then
                If C_Fiscal_Year%isopen Then
                    Close C_Fiscal_Year;
                End if;
                If C_Get_User_Deprn%isopen Then
                    Close C_Get_User_Deprn;
                End if;
                If C_Prior_Add%isopen Then
                    Close C_Prior_Add;
                End if;
                If C_Corp_Deprn_Details%isopen Then
                    Close C_Corp_Deprn_Details;
                End if;
                If C_Corp_Deprn_Summary%isopen Then
                    Close C_Corp_Deprn_Summary;
                End if;
                If C_Corp_Max_Period_Counter%isopen Then
                   Close C_Corp_Max_Period_Counter;
                End if;
                Rollback work;
  		igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     		p_full_path => l_path_name,
		     		p_string => 'Error : ' || p_out_message);
		fnd_file.put_line(fnd_file.log, p_out_message);
                Return False;
            When Others Then
                If C_Fiscal_Year%isopen Then
                    Close C_Fiscal_Year;
                End if;
                If C_Get_User_Deprn%isopen Then
                    Close C_Get_User_Deprn;
                End if;
                If C_Prior_Add%isopen Then
                    Close C_Prior_Add;
                End if;
                If C_Corp_Deprn_Details%isopen Then
                    Close C_Corp_Deprn_Details;
                End if;
                If C_Corp_Deprn_Summary%isopen Then
                    Close C_Corp_Deprn_Summary;
                End if;
                If C_Corp_Max_Period_Counter%isopen Then
                   Close C_Corp_Max_Period_Counter;
                End if;
                Rollback work;
  		igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
                Return FALSE;

    End Prepare_corp_data;

BEGIN

 l_max_records := 10000;
 --===========================FND_LOG.START=====================================

 g_state_level 	     :=	FND_LOG.LEVEL_STATEMENT;
 g_proc_level  	     :=	FND_LOG.LEVEL_PROCEDURE;
 g_event_level 	     :=	FND_LOG.LEVEL_EVENT;
 g_excep_level 	     :=	FND_LOG.LEVEL_EXCEPTION;
 g_error_level 	     :=	FND_LOG.LEVEL_ERROR;
 g_unexp_level 	     :=	FND_LOG.LEVEL_UNEXPECTED;
 g_path              := 'IGI.PLSQL.igiimpdb.igi_imp_iac_prepare_pkg.';
 --===========================FND_LOG.END=====================================


END IGI_IMP_IAC_PREPARE_PKG; -- Package Body

/
