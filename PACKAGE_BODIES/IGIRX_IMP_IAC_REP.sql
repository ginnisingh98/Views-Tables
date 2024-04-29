--------------------------------------------------------
--  DDL for Package Body IGIRX_IMP_IAC_REP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGIRX_IMP_IAC_REP" AS
-- $Header: igiimrxb.pls 120.10.12000000.1 2007/08/01 16:22:03 npandya noship $

 -- global variables

  --===========================FND_LOG.START=====================================

  g_state_level NUMBER;
  g_proc_level  NUMBER;
  g_event_level NUMBER;
  g_excep_level NUMBER;
  g_error_level NUMBER;
  g_unexp_level NUMBER;
  g_path        VARCHAR2(100);

 PROCEDURE Debug_Initialize IS
 BEGIN
  g_state_level :=	FND_LOG.LEVEL_STATEMENT;
  g_proc_level  :=	FND_LOG.LEVEL_PROCEDURE;
  g_event_level :=	FND_LOG.LEVEL_EVENT;
  g_excep_level :=	FND_LOG.LEVEL_EXCEPTION;
  g_error_level :=	FND_LOG.LEVEL_ERROR;
  g_unexp_level :=	FND_LOG.LEVEL_UNEXPECTED;
  g_path        := 'IGI.PLSQL.igiimrxb.igirx_imp_iac_rep.';
 END Debug_Initialize;
  --===========================FND_LOG.END=====================================

 -- ====================================================================
 -- PROCEDURE Recreate_Intf_Data: Procedure will recreate the interface
 -- data in category -> cost center -> asset grouping
 -- procedure introduced as a fix for bug 3439808
 -- ====================================================================
 PROCEDURE Recreate_Intf_Data(p_book_type_code      VARCHAR2,
                                 p_request_id          NUMBER)
 IS
        CURSOR c_get_intf_data(cp_request_id     igi_imp_iac_itf.request_id%TYPE,
                               cp_book_type_code igi_imp_iac_itf.book_type_code%TYPE)
        IS
        SELECT book_type_code,
               request_id,
               functional_currency_code,
               set_of_books_id,
               fiscal_year_name,
               period,
               organization_name,
               major_category,
               minor_category,
               concat_category,
               category_id,
               balancing_segment,
               cost_center,
               asset_id,
               asset_number,
               asset_description,
               parent_no,
               curr_reval_factor,
               cumm_reval_factor,
               asset_tag,
               serial_no,
               dpis ,
               life_months,
               stl_rate,
               depreciation_method,
               conc_asset_key,
               conc_location,
               sum(REVAL_COST),
               sum(NET_REVAL_RESERVE),
               sum(REVAL_RES_BLOG),
               sum(REVAL_YTD_DEPRN),
               sum(REVAL_DEPRN_RESERVE),
               sum(OPER_EXP_BACKLOG),
               sum(GENERAL_FUND),
               sum(HIST_COST),
               sum(HIST_YTD_DEPRN),
               sum(HIST_ACC_DEPRN),
               sum(OPER_ACCT)
        FROM igi_imp_iac_itf
        WHERE request_id = cp_request_id
        AND   book_type_code = cp_book_type_code
        GROUP BY book_type_code,
               request_id,
               functional_currency_code,
               set_of_books_id,
               fiscal_year_name,
               period,
               organization_name,
               major_category,
               minor_category,
               concat_category,
               category_id,
               balancing_segment,
               cost_center,
               asset_id,
               asset_number,
               asset_description,
               parent_no,
               curr_reval_factor,
               cumm_reval_factor,
               asset_tag,
               serial_no,
               dpis ,
               life_months,
               stl_rate,
               depreciation_method,
               conc_asset_key,
               conc_location;


    TYPE type_book_type_code IS TABLE OF VARCHAR2(15) INDEX BY BINARY_INTEGER;
    TYPE type_curr_code IS TABLE OF VARCHAR2(15) INDEX BY BINARY_INTEGER;
    TYPE type_fiscal_year IS TABLE OF VARCHAR2(15) INDEX BY BINARY_INTEGER;
    TYPE type_period IS TABLE OF VARCHAR2(15) INDEX BY BINARY_INTEGER;
    TYPE type_asset_num IS TABLE OF VARCHAR2(15) INDEX BY BINARY_INTEGER;
    TYPE type_asset_tag IS TABLE OF VARCHAR2(15) INDEX BY BINARY_INTEGER;

    TYPE type_maj_cat IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
    TYPE type_min_cat IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
    TYPE type_bal_seg IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
    TYPE type_cost_center IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
    TYPE type_dep_method IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

    TYPE type_serial_no IS TABLE OF VARCHAR2(35) INDEX BY BINARY_INTEGER;

    TYPE type_org_name IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
    TYPE type_conc_cat IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
    TYPE type_asset_desc IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
    TYPE type_conc_asset_key IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
    TYPE type_conc_location IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;

    TYPE type_sob_id  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE type_curr_reval  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE type_cumm_reval  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE type_life_months  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE type_stl_rate  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE type_reval_cost  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE type_net_rr  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE type_rr_blog  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE type_reval_ytd_dep  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE type_reval_dep_rsv  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE type_op_exp_blog  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE type_gen_fund  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE type_hist_cost  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE type_hist_ytd_dep  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE type_hist_acc_dep  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE type_op_acct  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

    TYPE type_request_id IS TABLE OF NUMBER(15,0) INDEX BY BINARY_INTEGER;
    TYPE type_cat_id IS TABLE OF NUMBER(15,0) INDEX BY BINARY_INTEGER;
    TYPE type_asset_id IS TABLE OF NUMBER(15,0) INDEX BY BINARY_INTEGER;
    TYPE type_parent_no IS TABLE OF NUMBER(15,0) INDEX BY BINARY_INTEGER;

    TYPE type_dpis IS TABLE OF DATE INDEX BY BINARY_INTEGER;


   l_book_type_code               type_book_type_code;
   l_request_id                   type_request_id;
   l_functional_currency_code     type_curr_code;
   l_set_of_books_id              type_sob_id;
   l_fiscal_year_name             type_fiscal_year;
   l_period                       type_period;
   l_organization_name            type_org_name;
   l_major_category               type_maj_cat;
   l_minor_category               type_min_cat;
   l_concat_category              type_conc_cat;
   l_category_id                  type_cat_id;
   l_balancing_segment            type_bal_seg;
   l_cost_center                  type_cost_center;
   l_asset_id                     type_asset_id;
   l_asset_number                 type_asset_num;
   l_asset_description            type_asset_desc;
   l_parent_no                    type_parent_no;
   l_curr_reval_factor            type_curr_reval;
   l_cumm_reval_factor            type_cumm_reval;
   l_asset_tag                    type_asset_tag;
   l_serial_no                    type_serial_no;
   l_dpis                         type_dpis;
   l_life_months                  type_life_months;
   l_stl_rate                     type_stl_rate;
   l_depreciation_method          type_dep_method;
   l_conc_asset_key               type_conc_asset_key;
   l_conc_location                type_conc_location;
   l_reval_cost                   type_reval_cost;
   l_net_reval_reserve            type_net_rr;
   l_reval_res_blog               type_rr_blog;
   l_reval_ytd_deprn              type_reval_ytd_dep;
   l_reval_deprn_reserve          type_reval_dep_rsv;
   l_oper_exp_backlog             type_op_exp_blog;
   l_general_fund                 type_gen_fund;
   l_hist_cost                    type_hist_cost;
   l_hist_ytd_deprn               type_hist_ytd_dep;
   l_hist_acc_deprn               type_hist_acc_dep;
   l_oper_acct                    type_op_acct;

   l_login_id                  NUMBER;
   l_user_id                   NUMBER;

 BEGIN

   l_login_id := fnd_profile.value('LOGIN_ID');
   l_user_id  := fnd_profile.value('USER_ID');

   -- fetch data

   OPEN c_get_intf_data(p_request_id,p_book_type_code);
   FETCH c_get_intf_data BULK COLLECT INTO l_book_type_code,
                                           l_request_id,
                                           l_functional_currency_code,
                                           l_set_of_books_id,
                                           l_fiscal_year_name,
                                           l_period,
                                           l_organization_name,
                                           l_major_category,
                                           l_minor_category,
                                           l_concat_category,
                                           l_category_id,
                                           l_balancing_segment,
                                           l_cost_center,
                                           l_asset_id,
                                           l_asset_number,
                                           l_asset_description,
                                           l_parent_no,
                                           l_curr_reval_factor,
                                           l_cumm_reval_factor,
                                           l_asset_tag,
                                           l_serial_no,
                                           l_dpis,
                                           l_life_months,
                                           l_stl_rate,
                                           l_depreciation_method,
                                           l_conc_asset_key,
                                           l_conc_location,
                                           l_reval_cost,
                                           l_net_reval_reserve,
                                           l_reval_res_blog,
                                           l_reval_ytd_deprn,
                                           l_reval_deprn_reserve,
                                           l_oper_exp_backlog,
                                           l_general_fund,
                                           l_hist_cost,
                                           l_hist_ytd_deprn,
                                           l_hist_acc_deprn,
                                           l_oper_acct;

   -- delete existing data in igi_imp_iac_itf
   -- for request_id and book_type_code
   DELETE FROM igi_imp_iac_itf
   WHERE book_type_code = p_book_type_code
   AND   request_id = p_request_id;

   -- insert the data back into the interface table

   FORALL j IN l_book_type_code.FIRST..l_book_type_code.LAST
         INSERT INTO IGI_IMP_IAC_ITF(  distribution_id ,
                                    request_id ,
                                    set_of_books_id  ,
                                    asset_id,
                                    category_id,
                                    functional_currency_code ,
                                    book_type_code ,
                                    fiscal_year_name ,
                                    period  ,
                                    cost_center ,
                                    asset_number ,
                                    asset_description ,
                                    major_category ,
                                    minor_category ,
                                    concat_category ,
                                    reval_cost ,
                                    net_reval_reserve  ,
                                    reval_res_blog  ,
                                    reval_ytd_deprn  ,
                                    reval_deprn_reserve ,
                                    oper_acct   ,
                                    oper_exp_backlog ,
                                    general_fund ,
                                    parent_no  ,
                                    curr_reval_factor ,
                                    cumm_reval_factor,
                                    asset_tag  ,
                                    balancing_segment ,
                                    serial_no ,
                                    dpis    ,
                                    life_months ,
                                    stl_rate  ,
                                    depreciation_method  ,
                                    conc_asset_key  ,
                                    conc_location ,
                                    cost_acct  ,
                                    iac_reval_resv_acct   ,
                                    deprn_res_acct  ,
                                    deprn_backlog_acct ,
                                    gen_fund_acct ,
                                    deprn_exp_acct ,
                                    oper_exp_acct ,
                                    hist_cost ,
                                    hist_ytd_deprn  ,
                                    hist_acc_deprn,
                                    organization_name,
                                    created_by,
                                    creation_date,
                                    last_update_login,
                                    last_updated_by,
                                    last_update_date)
                    VALUES
                                    ( null ,
                                    l_request_id(j),
                                    l_set_of_books_id(j) ,
                                    l_asset_id(j),
                                    l_category_id(j),
                                    l_functional_currency_code(j) ,
                                    l_book_type_code(j) ,
                                    l_fiscal_year_name(j),
                                    l_period(j) ,
                                    l_cost_center(j) ,
                                    l_asset_number(j),
                                    l_asset_description(j) ,
                                    l_major_category(j),
                                    l_minor_category(j),
                                    l_concat_category(j),
                                    l_reval_cost(j),
                                    l_net_reval_reserve(j)  ,
                                    l_reval_res_blog(j),
                                    l_reval_ytd_deprn(j)   ,
                                    l_reval_deprn_reserve(j) ,
                                    l_oper_acct(j),
                                    l_oper_exp_backlog(j),
                                    l_general_fund(j),
                                    l_parent_no(j),
                                    l_curr_reval_factor(j)  ,
                                    l_cumm_reval_factor(j) ,
                                    l_asset_tag(j) ,
                                    l_balancing_segment(j)  ,
                                    l_serial_no(j) ,
                                    l_dpis(j),
                                    l_life_months(j)   ,
                                    NULL     ,
                                    l_depreciation_method(j) ,
                                    l_conc_asset_key(j) ,
                                    l_conc_location(j) ,
                                    null,
                                    null,
                                    null,
                                    null,
                                    null,
                                    null ,
                                    null,
                                    l_hist_cost(j),
                                    l_hist_ytd_deprn(j) ,
                                    l_hist_acc_deprn(j),
                                    l_organization_name(j),
                                    l_user_id,
                                    sysdate,
                                    l_login_id,
                                    l_user_id,
                                    sysdate)   ;


 END Recreate_Intf_Data;

 -- ====================================================================
 -- PROCEDURE Imp: Main procedure that will be called by the RXi
 -- outer wrapper process for IAC Implementation Reconciliation
 -- ====================================================================
    PROCEDURE imp(p_book_type_code      VARCHAR2,
		p_category_struct_id  NUMBER,
		p_category_id         NUMBER,
		p_request_id          NUMBER,
		retcode  OUT NOCOPY   NUMBER,
		errbuf   OUT NOCOPY VARCHAR2)
    IS

    -- cursors
    --get the implementation data.

        CURSOR  C_source_book IS
        SELECT distribution_source_book
        FROM fa_book_controls
        WHERE book_type_code=p_book_type_code;

        CURSOR C_YTD (p_asset_id IN NUMBER,
                  p_category_id IN NUMBER)
        IS
        SELECT  YTD_HIST,YTD_MHCA,asset_number,
    	        cost_hist,cost_mhca
        FROM   igi_imp_iac_interface ii
        WHERE
              ii.asset_id=p_asset_id                  AND
              ii.book_type_code=p_book_type_code      AND
              ii.category_id=p_category_id           ;

        CURSOR C_main ( p_category_id in NUMBER,
    	        p_distribution_id in NUMBER)
        IS
        SELECT  nvl(ii.Hist_Salvage_Value,0)  Hist_Salvage_Value,
            nvl(ii.Life_in_Months,0)  Life_in_Months,
            nvl(ct.Corp_Book,' ')  Corp_Book,
            nvl(ii.Cost_Hist * (dh.units_Assigned/ad.current_units),0) cost_hist,
            nvl(ii.Cost_MHCA * (dh.units_Assigned/ad.current_units)  ,0) cost_mhca,
            nvl(ii.Deprn_Exp_Hist * (dh.units_Assigned/ad.current_units)  ,0) deprn_exp_hist,
            nvl(ii.Deprn_Exp_MHCA * (dh.units_Assigned/ad.current_units) ,0 ) deprn_exp_mhca,
            nvl(ii.Accum_Deprn_Hist * (dh.units_Assigned/ad.current_units) ,0) Accum_Deprn_Hist,
            nvl(ii.Accum_Deprn_MHCA * (dh.units_Assigned/ad.current_units) ,0) Accum_Deprn_MHCA,
            nvl(ii.Reval_Reserve_Hist * (dh.units_Assigned/ad.current_units) ,0) Reval_Reserve_Hist,
            nvl(ii.Reval_Reserve_MHCA * (dh.units_Assigned/ad.current_units) ,0) Reval_Reserve_MHCA,
            nvl(ii.Backlog_Hist *(dh.units_Assigned/ad.current_units)  ,0) Backlog_Hist,
            nvl(ii.Backlog_MHCA *(dh.units_Assigned/ad.current_units)  ,0) Backlog_MHCA,
            nvl(ii.General_Fund_HIST * (dh.units_Assigned/ad.current_units) ,0) General_Fund_HIST,
            nvl(ii.General_Fund_MHCA * (dh.units_Assigned/ad.current_units) ,0) General_Fund_MHCA,
            nvl(ii.General_Fund_Per_Hist * (dh.units_Assigned/ad.current_units) ,0) General_Fund_Per_Hist,
            nvl(ii.General_Fund_Per_Mhca * (dh.units_Assigned/ad.current_units) ,0) General_Fund_Per_Mhca,
            nvl(ii.Operating_Account_Hist * (dh.units_Assigned/ad.current_units) ,0) Operating_Account_Hist,
            nvl(ii.Operating_Account_MHCA * (dh.units_Assigned/ad.current_units) ,0) Operating_Account_MHCA,
            nvl(ii.Operating_Account_YTD_Hist * (dh.units_Assigned/ad.current_units) ,0)  Operating_Account_YTD_Hist,
            nvl(ii.Operating_Account_YTD_MHCA * (dh.units_Assigned/ad.current_units) ,0) Operating_Account_YTD_MHCA,
            nvl(ii.Operating_Account_Cost * (dh.units_Assigned/ad.current_units) ,0) Operating_Account_Cost,
            nvl(ii.Operating_Account_Backlog * (dh.units_Assigned/ad.current_units) ,0) Operating_Account_Backlog,
            nvl(ii.NBV_Hist * (dh.units_Assigned/ad.current_units) ,0) NBV_Hist,
            nvl(ii.NBV_MHCA * (dh.units_Assigned/ad.current_units) ,0) NBV_MHCA
        FROM	Igi_Imp_Iac_Interface ii,
            Fa_Distribution_History dh,
            Fa_Additions ad,
            igi_imp_iac_controls ct
        WHERE
            ii.book_type_code=p_book_type_code                  		 		  AND
            ii.CATEGORY_ID=NVL(P_CATEGORY_ID,ii.CATEGORY_ID)     				  AND
            ct.book_type_code = ii.book_type_code                         	  		  AND
            dh.book_type_Code = ct.corp_book AND dh.asset_id = ii.asset_id  		  AND
            ad.asset_id = ii.asset_id                                                         AND
            dh.distribution_id=p_distribution_id;

        CURSOR Cur_dets(p_max_period_counter in NUMBER)
        IS
        SELECT  sc.Location_Flex_Structure,
            bc.Accounting_Flex_Structure,
            sc.asset_key_flex_structure,
            sc.company_name,
            sob.set_of_books_id,
            sob.name,
            dp.fiscal_year,
            sc.Category_Flex_Structure,
            sob.Currency_Code
        FROM    fa_system_controls      sc,
            gl_sets_of_books        sob,
            fa_book_controls        bc,
            fa_deprn_periods       dp
        WHERE
            bc.Book_Type_Code    = p_book_type_code		 AND
            sob.Set_Of_Books_ID  = bc.Set_Of_Books_ID        AND
            dp.book_type_code   =bc.Book_Type_Code           AND
            dp.period_counter=   p_max_period_counter-1;

        CURSOR C_period_counter
        IS
        SELECT  max(period_counter)
        FROM    igi_imp_iac_controls
        WHERE   Book_Type_Code  = p_book_type_code;

        CURSOR C_period (p_max_period_counter in VARCHAR2)
        IS
        SELECT	   period_name
        FROM	   fa_deprn_periods
        WHERE  	   Book_Type_Code  = p_book_type_code          AND
        	   period_counter  = p_max_period_counter-1;

        CURSOR C_counter(p_distribution_id  in NUMBER
                	,p_fiscal_year   in   NUMBER
                	,p_dist_source_book in VARCHAR2)
        IS
        SELECT 	dp.period_counter
        FROM   	fa_deprn_periods dp,
                fa_distribution_history dh
        WHERE  	dh.date_ineffective between dp.period_open_date  and dp.period_close_date       AND
            dp.book_type_code=p_book_type_code		        		        AND
            dp.fiscal_year=p_fiscal_year  							AND
            dh.book_type_code=p_dist_source_book 						AND
            dh.distribution_id=p_distribution_id;

        CURSOR Cur_acct2(p_category_id in NUMBER,
                    p_dist_source_book in VARCHAR2)
        IS
        SELECT   backlog_deprn_rsv_ccid  ,
                 general_fund_ccid ,
                operating_expense_ccid,
                reval_rsv_ccid
        FROM    igi_iac_category_books
        WHERE   book_type_code=p_dist_source_book     AND
                category_id=p_category_id;

        CURSOR cur_acct( p_asset_id  in NUMBER)
        IS
        SELECT ad.asset_key_ccid,
            ad.description,
            ad.parent_asset_id,
            ad.Tag_number,
            ad.serial_number ,
            bk.date_placed_in_service ,
            bk.deprn_method_code
        FROM   fa_books bk,
            fa_additions ad
        WHERE ad.asset_id=p_asset_id       		     AND
            ad.asset_id = bk.asset_id    		     AND
            bk.transaction_header_id_out is NULL   	     AND
            bk.book_type_code = p_book_type_code ;

        CURSOR C_dist_acct( p_distribution_id in number)
        IS
        SELECT	 asset_cost_account_ccid ,
            deprn_expense_account_ccid ,
            deprn_reserve_account_ccid
        FROM     fa_distribution_accounts
        WHERE   distribution_id=p_distribution_id        AND
            book_type_code=p_book_type_code;

        CURSOR  C_deprn( p_fiscal_year in NUMBER,
                p_asset_id in NUMBER,
                p_dist_source_book in VARCHAR2)
        IS
        SELECT  dp.calendar_period_open_date,
            dp.period_counter,
            dh.distribution_id,
            dh.code_combination_id,
            dh.date_ineffective,
            dh.location_id
        FROM    fa_distribution_history dh,
            fa_deprn_periods  dp
        WHERE   dh.asset_id= p_asset_id 						AND
            dh.book_type_code=p_dist_source_book	 				AND
            (nvl(dh.date_ineffective,dp.period_open_date)>=dp.period_open_date) 	AND
            dp.Book_type_code=p_book_type_code 	        			AND
            dp.fiscal_year=p_fiscal_year                   			AND
            dp.period_num=(SELECT min(period_num)
        		             FROM  fa_deprn_periods
               	             WHERE fiscal_year=p_fiscal_year AND
               	                   book_type_code=p_book_type_code);

        CURSOR C_asset(p_category_id  in number)
        IS
        SELECT 	asset_id
        FROM  	igi_imp_iac_interface
        WHERE
            book_type_code=p_book_type_code  AND
            category_id=p_category_id;

        CURSOR C_category(p_category_id in number)
        IS
        SELECT distinct category_id
        FROM
            igi_imp_iac_interface_ctrl
        WHERE 	book_type_code=p_book_type_code  AND
            category_id=nvl(p_category_id,category_id);


        CURSOR C_ytd_dist(p_distribution_id in number,
    		   p_asset_id in number,
               p_period_counter in number,
               p_book_type_code in varchar2)
        IS
        SELECT  ytd_deprn
        FROM    fa_deprn_detail
        WHERE   distribution_id=p_distribution_id         AND
        	book_type_code =p_book_type_code	  AND
        	asset_id  =p_asset_id			  AND
        	period_counter=p_period_counter ;

        CURSOR C_ytd_dist_non_deprn(p_distribution_id in number,
    		   p_asset_id in number,
               p_book_type_code in varchar2)
        IS
        SELECT  ytd_deprn
        FROM    fa_deprn_detail
        WHERE   distribution_id=p_distribution_id         AND
        	book_type_code =p_book_type_code	  AND
        	asset_id  =p_asset_id			  AND
        	period_counter=(select max(period_counter)
                                from fa_deprn_detail
                                   where asset_id=p_asset_id
                                   and distribution_id=p_distribution_id
			           and book_type_code =p_book_type_code);


        CURSOR C_ytd_asset(p_asset_id in number,p_max_period_counter in number,p_book_type_code in varchar2)
        IS
        SELECT    ytd_deprn
        FROM      fa_deprn_summary
        WHERE     asset_id=p_asset_id 		     AND
            book_type_code=p_book_type_code  AND
            period_counter=p_max_period_counter-1;

        CURSOR C_ytd_asset_non_dep(p_asset_id in number, p_book_type_code in varchar2)
        IS
        SELECT    ytd_deprn,fiscal_year
        FROM      fa_deprn_summary ds, fa_deprn_periods dp
        WHERE     ds.asset_id=p_asset_id 		     AND
            ds.book_type_code=p_book_type_code  AND
            ds.book_type_code = dp.book_type_code and
            ds.period_counter= (select max(period_counter)
                                from fa_deprn_summary
                                   where asset_id=p_asset_id
					and book_type_code=p_book_type_code )
            and  ds.period_counter=dp.period_counter;


        CURSOR c_inactive_dist_cat( cp_book_type_code varchar2,
                                    cp_asset_id number,
                                    cp_distribution_id number) IS
        SELECT ah.category_id
        FROM    fa_asset_history ah,
                fa_distribution_history dh
        WHERE dh.book_type_code = cp_book_type_code AND
              dh.asset_id = cp_asset_id AND
              dh.distribution_id = cp_distribution_id AND
              dh.asset_id = ah.asset_id AND
              dh.date_ineffective BETWEEN
                            ah.date_effective AND nvl(ah.date_ineffective,sysdate);


        Cursor C_asset_derpn_Info(cp_book_type_code varchar2,
                             cp_asset_id number) Is
        Select  depreciate_flag
        From    fa_books bk
        Where   bk.book_type_code = cp_book_type_code
        and     bk.asset_id =cp_asset_id
        and     bk.transaction_header_id_out is null;


        --variables
        l_dist_source_book          varchar2(15);
        l_cat_segs                  fa_rx_shared_pkg.seg_array;
        l_loc_segs                  fa_rx_shared_pkg.seg_array;
        l_asset_segs                fa_rx_shared_pkg.seg_array;
        l_asset_key_flex_struct     fa_system_controls.asset_key_flex_structure%type;
        l_cat_flex_struct           fa_system_controls.category_flex_structure%type;
        l_loc_flex_struct           fa_system_controls.location_flex_structure%type;
        l_accounting_flex_struct    fa_book_controls.accounting_flex_structure%type ;
        l_set_of_books_id           fa_book_controls.set_of_books_id%type;
        l_currency_code             gl_sets_of_books.currency_code%type;
        l_organization_name         gl_sets_of_books.name%type;
        l_ytd_hist                  number;
        l_asset_ytd_hist            number;
        l_max_period_counter        number;
        l_inactive_counter          number;
        l_fiscal_year               number(4);
        l_category_id               number(15);
        l_asset_id                  number(15);
        l_cost_hist                 number(15);
        l_cost_mhca                 number(15);
        l_current_reval_factor      number;
        l_cumulative_reval_factor   number;
        l_deprn_expense_acct        varchar2(30);
        l_asset_cost_acct           varchar2(30);
        l_deprn_reserve_acct        varchar2(30);
        l_reval_rsv_acct            varchar2(30);
        l_blog_deprn_rsv_acct       varchar2(30);
        l_general_fund_acct         varchar2(30);
        l_oper_expense_acct         varchar2(30);
        l_cost_center               varchar2(25);
        l_company_name              varchar2(30);
        l_asset_number              varchar2(15);
        l_balancing_seg             varchar2(15);
        l_concat_asset_key          varchar2(500);
        l_major_category            varchar2(50);
        l_minor_category            varchar2(50);
        l_concat_category           varchar2(500);
        l_concat_location           varchar2(500);
        l_period_name               varchar2(15);
        l_ytd_mhca                  number;
        l_asset_ytd_mhca            number;
        l_location_id               number;
        l_dist_ytd_deprn            number;
        l_asset_ytd_deprn           number;
        l_category                  c_category%rowtype;
        l_asset                     c_asset%rowtype;
        l_dist_acct                 c_dist_acct%rowtype;
        l_acct2                     cur_acct2%rowtype;
        l_acct                      cur_acct%rowtype;
        l_main                      c_main%rowtype;
        l_deprn                     c_deprn%rowtype;
        l_login_id                  NUMBER;
        l_user_id                   NUMBER;
        l_path_name                 VARCHAR2(150);
        l_deprn_flag                fa_books.depreciate_flag%type;
        l_curr_fiscal_year          fa_deprn_periods.fiscal_year%type;
        l_asset_fiscal_year         fa_deprn_periods.fiscal_year%type;
        l_YTD_prorate_dists_tab igi_iac_types.prorate_dists_tab;
        l_YTD_prorate_dists_idx     binary_integer;
        idx_YTD                     binary_integer;
        l_ytd_prorate_factor        NUMBER;

    BEGIN

        Debug_Initialize;

        l_ytd_hist :=0;
        l_asset_ytd_hist := 0;
        l_login_id := fnd_profile.value('LOGIN_ID');
        l_user_id := fnd_profile.value('USER_ID');
        l_path_name := g_path||'imp';

        OPEN C_source_book;
        FETCH C_source_book INTO l_dist_source_book;
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'after fetch c_dist_source_book ');
        CLOSE C_source_book;

        OPEN 	c_period_counter;
        FETCH 	c_period_counter into l_max_period_counter;
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'after fetch c_period_counter ');
        CLOSE 	c_period_counter;

        OPEN 	C_period(l_max_period_counter);
        FETCH 	C_period INTO l_period_name;
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'after fetch c_period ');
        CLOSE C_period;

        OPEN Cur_dets(l_max_period_counter);
        FETCH Cur_dets INTO
			l_loc_flex_struct,
			l_Accounting_Flex_Struct,
			l_asset_key_flex_struct,
			l_company_name,
			l_set_of_books_id,
			l_organization_name,
			l_fiscal_year,
			l_cat_flex_struct,
			l_Currency_Code;
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'after fetch cur_dets ');
        CLOSE cur_dets;

        l_category_id:=p_category_id;

        FOR l_category IN C_category(l_category_id)
        LOOP     							--LOOP 1
            l_category_id:=l_category.category_id;

            FOR l_asset IN C_Asset(l_category_id )
            LOOP    						 --LOOP 2
                l_asset_id:=l_asset.asset_id;

                l_cost_hist:=0;
                l_cost_mhca:=0;
                OPEN C_ytd  (l_asset_id,
                            l_category_id);
                FETCH  C_ytd
                INTO   l_asset_ytd_hist, l_asset_ytd_mhca, l_asset_number,l_cost_hist,l_cost_mhca;
                CLOSE  C_ytd;

                IF ( nvl( l_cost_hist,0) = 0 ) THEN
                    l_current_reval_factor    := 1 ;
                    l_cumulative_reval_factor := 1 ;
                ELSE
                    l_current_reval_factor    := l_cost_mhca/l_cost_hist ;
                    l_cumulative_reval_factor := l_cost_mhca/l_cost_hist ;
                END IF;

                -- get depreciate flag;
                l_deprn_flag :='YES';
                igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                        p_full_path => l_path_name,
                        p_string => 'Get depreciate flag');

                open C_asset_derpn_Info (P_book_type_code,l_asset_id);
                Fetch  C_asset_derpn_Info into l_deprn_flag;
                Close C_asset_derpn_Info;

                l_asset_ytd_deprn :=0;
                l_asset_fiscal_year:=Null;
                 igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                        p_full_path => l_path_name,
                        p_string => 'before fetch C_YTD_ASSET');

                OPEN C_ytd_asset   ( l_asset_id ,
                                     l_max_period_counter,
                                     l_dist_source_book);
                FETCH C_ytd_asset INTO  l_asset_ytd_deprn;
                IF c_ytd_asset%NotFound Then
                             OPEN C_ytd_asset_non_dep ( l_asset_id,l_dist_source_book);
                             FETCH C_ytd_asset_non_dep INTO  l_asset_ytd_deprn,l_asset_fiscal_year;
                             If C_ytd_asset_non_dep%Notfound Then
                                    l_asset_ytd_deprn:=0;
                              Else
                                if Not l_asset_fiscal_year = l_fiscal_year THen
                                    l_asset_ytd_deprn:=0;
                                End If;
                             END IF;
                            close C_ytd_asset_non_dep;
                 END IF;
                        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                        p_full_path => l_path_name,
                        p_string => 'C_YTD_ASSET'|| l_asset_ytd_deprn);
                CLOSE C_ytd_asset;

                 igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                        p_full_path => l_path_name,
                        p_string => 'after fetch C_YTD_ASSET');

                OPEN cur_acct(l_asset_id);
                FETCH cur_acct
                INTO l_acct;
                igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                    p_full_path => l_path_name,
                    p_string => 'after fetch CUR ACCT');
                CLOSE  cur_acct;

                If l_asset_fiscal_year is not Null Then
                  l_curr_fiscal_year:= l_asset_fiscal_year;
                Else
                  l_curr_fiscal_year:= l_fiscal_year;
                End if;

                IF NOT IGI_IAC_REVAL_UTILITIES.prorate_all_dists_YTD ( fp_asset_id              => l_asset_id
                       , fp_book_type_code         => l_dist_source_book
                       , fp_current_period_counter => l_max_period_counter - 1
                       , fp_prorate_dists_tab      => l_YTD_prorate_dists_tab
                       , fp_prorate_dists_idx      => l_YTD_prorate_dists_idx
                       )
                THEN
                    igi_iac_debug_pkg.debug_other_string(g_error_level,g_path,'+error IGI_IAC_REVAL_UTILITIES.prorate_all_dists_YTD');
                END IF;

                FOR l_deprn IN C_Deprn(l_curr_fiscal_year , l_asset_id , l_dist_source_book )
                LOOP  --LOOP 3

                    OPEN  C_MAIN(l_category_id,l_deprn.distribution_id);
                    FETCH C_Main INTO l_main;
                    CLOSE C_main;

                 IF nvl(l_asset_fiscal_year,l_fiscal_year) = l_fiscal_year THEN

                    IF(l_deprn.date_ineffective IS NULL)		--Active distribution
                    THEN
                        /* Fetching accounts for active distribution */
                        OPEN  Cur_acct2(l_category_id,l_dist_source_book);
                        FETCH Cur_Acct2
                        INTO  l_acct2;
                        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                                p_full_path => l_path_name,
                                p_string => 'after fetch CUR ACCT2');
                        CLOSE Cur_Acct2;

                        l_dist_ytd_deprn:=0;
                        OPEN C_ytd_dist (l_deprn.distribution_id ,
                                        l_asset_id ,
                                        l_max_period_counter-1 ,
                                        l_dist_source_book);
                        FETCH C_Ytd_Dist
                        INTO  l_dist_ytd_deprn;
                        If C_ytd_dist%NotFound THen

                                 Open  C_Ytd_Dist_non_deprn(l_deprn.distribution_id,l_asset_id, l_dist_source_book);
                                 Fetch C_Ytd_Dist_non_deprn into l_dist_ytd_deprn;
                                 IF C_Ytd_Dist_non_deprn%notfound Then
                                     l_dist_ytd_deprn:=0;
                                 end if;
                                 close C_Ytd_Dist_non_deprn;
                                igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                                p_full_path => l_path_name,
                                p_string => 'after fetch C_YTD_DIST');
                        END IF;
                        CLOSE C_Ytd_Dist;

                    ELSE                 --Inactive Distribution
                        /* Fetching category for inactive dist Bug 3430707 */
                        OPEN c_inactive_dist_cat(l_dist_source_book,l_asset_id,l_deprn.distribution_id);
                        FETCH c_inactive_dist_cat INTO l_category_id;
                        CLOSE c_inactive_dist_cat;

                        /* Fetching accounts for inactive distribution */
                        OPEN  Cur_acct2(l_category_id,l_dist_source_book);
                        FETCH Cur_Acct2
                        INTO  l_acct2;
                        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                            p_full_path => l_path_name,
                            p_string => 'after fetch CUR ACCT2');
                        CLOSE Cur_Acct2;

                        --Assign all currency fields of C_main 0
                        l_main.cost_mhca :=0;
                        l_main.reval_reserve_mhca:=0;
                        l_main.backlog_mhca :=0;
                        l_main.Accum_Deprn_MHCA :=0;
                        l_main.operating_account_cost:=0;
                        l_main.operating_account_backlog :=0;
                        l_main.general_fund_mhca:=0;
                        l_main.cost_hist:=0;
                        l_main.accum_deprn_hist:=0;

                        OPEN C_counter(  l_deprn.distribution_id,
                                l_fiscal_year,
                                l_dist_source_book);
                        FETCH C_Counter Into l_Inactive_Counter;

                        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                            p_full_path => l_path_name,
                            p_string => 'after fetch C_COUNTER');
                        CLOSE C_counter;

                        l_dist_ytd_deprn:=0;

                        OPEN C_ytd_dist ( l_deprn.distribution_id ,
                                            l_asset_id ,
                                            l_inactive_counter,
                                            l_dist_source_book);
                        FETCH C_ytd_dist INTO l_dist_ytd_deprn;
                           If C_ytd_dist%NotFound THen
                                 Open  C_Ytd_Dist_non_deprn(l_deprn.distribution_id,l_asset_id,l_dist_source_book);
                                 Fetch C_Ytd_Dist_non_deprn into l_dist_ytd_deprn;
                                 IF C_Ytd_Dist_non_deprn%notfound Then
                                     l_dist_ytd_deprn:=0;
                                 end if;
                                 close C_Ytd_Dist_non_deprn;
                                igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                                p_full_path => l_path_name,
                                p_string => 'after fetch C_Ytd_Dist');

                         END IF;
                         CLOSE C_Ytd_Dist;
                   END IF;
                   ELSE
			 OPEN  Cur_acct2(l_category_id,l_dist_source_book);
                        FETCH Cur_Acct2
                        INTO  l_acct2;
                        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                                p_full_path => l_path_name,
                                p_string => 'after fetch CUR ACCT2');
                        CLOSE Cur_Acct2;

                         l_dist_ytd_deprn:=0;
                   END IF;

                    if l_deprn_flag = 'YES' THEN
                        IF (nvl(l_asset_ytd_deprn,0)=0)
                        THEN
                            l_ytd_hist:=0;
                            l_ytd_mhca:=0;
                        ELSE
                            l_ytd_hist:=l_asset_ytd_hist*(l_dist_ytd_deprn/l_asset_ytd_deprn);

                            l_ytd_prorate_factor := 0;
                            idx_YTD := l_YTD_prorate_dists_tab.FIRST;
                            WHILE idx_YTD <= l_YTD_prorate_dists_tab.LAST LOOP
                                IF l_deprn.distribution_id = l_YTD_prorate_dists_tab(idx_YTD).distribution_id THEN
                                    l_ytd_prorate_factor := l_YTD_prorate_dists_tab(idx_YTD).ytd_prorate_factor;
                                    EXIT;
                                END IF;
                                idx_ytd := l_YTD_prorate_dists_tab.Next(idx_ytd);
                            END LOOP;
                            l_ytd_mhca:=l_asset_ytd_mhca*l_ytd_prorate_factor;

                        END IF;
                    Else
                        l_ytd_hist:=l_dist_ytd_deprn;
                        l_ytd_mhca:=l_dist_ytd_deprn;
                    ENd If;


                    OPEN 	C_dist_acct(l_deprn.distribution_id);
                    FETCH 	C_dist_acct
                    INTO  	l_dist_acct;
                    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                        p_full_path => l_path_name,
                        p_string => 'after fetch dist acct');
                    CLOSE C_Dist_Acct;

                    IF NOT igi_iac_common_utils.get_account_segment_value(l_set_of_books_id,
                                                             l_dist_acct.deprn_expense_account_ccid,
                                                             'GL_ACCOUNT',
                                                              l_deprn_expense_acct)       --the expense acct for   distribution
                    THEN
                        l_deprn_expense_acct:= 'not_found';
                    END IF;

                    IF NOT igi_iac_common_utils.get_account_segment_value(l_set_of_books_id,
                                                           l_acct2.backlog_deprn_rsv_ccid,
                                                       	  'GL_ACCOUNT',
                                                       	   l_blog_deprn_rsv_acct)
                    THEN
                        l_blog_deprn_rsv_acct:= 'not_found';
                    END IF;

                    IF NOT igi_iac_common_utils.get_account_segment_value(l_set_of_books_id,
                                                      		 l_acct2.general_fund_ccid,
                                                      		 'GL_ACCOUNT',
                                                       		 l_general_fund_acct)
                    THEN
                        l_general_fund_acct:= 'not_found';
                    END IF;

                    IF NOT  igi_iac_common_utils.get_account_segment_value(l_set_of_books_id,
                                                     		 l_acct2.operating_expense_ccid,
                                                     		  'GL_ACCOUNT',
                                                      		  l_oper_expense_acct)
                    THEN
                        l_oper_expense_acct:= 'not_found';
                    END IF;

                    IF NOT  igi_iac_common_utils.get_account_segment_value(l_set_of_books_id,
                                                       		l_dist_acct.deprn_reserve_account_ccid,
                                                       		'GL_ACCOUNT',
                                                       		 l_deprn_reserve_acct)
                    THEN
                        l_deprn_reserve_acct:= 'not_found';
                    END IF;

                    IF NOT  igi_iac_common_utils.get_account_segment_value(l_set_of_books_id,
                                                       l_acct2.reval_rsv_ccid,
                                                       'GL_ACCOUNT',
                                                        l_reval_rsv_acct)
                    THEN
                        l_reval_rsv_acct:= 'not_found';
                    END IF;

                    IF NOT  igi_iac_common_utils.get_account_segment_value(l_set_of_books_id,
                                                       l_dist_acct.asset_cost_account_ccid,
                                                       'GL_ACCOUNT',
                                                        l_asset_cost_acct)
                    THEN
                        l_asset_cost_acct:= 'not_found';
                    END IF;

                    IF NOT  igi_iac_common_utils.get_account_segment_value(l_set_of_books_id,
                                                        l_deprn.code_combination_id,
                                                       'FA_COST_CTR',
                                                        l_cost_center)
                    THEN
                        l_cost_center:= 'not_found';
                    END IF;

                    IF NOT  igi_iac_common_utils.get_account_segment_value(l_set_of_books_id,
                                                      l_deprn.code_combination_id,
                                                      'GL_BALANCING',
                                                       l_balancing_seg)
                    THEN
                        l_balancing_seg := 'not_found';
                    END IF;

                    BEGIN
                        l_major_category := fa_rx_flex_pkg.get_value(
                                                           p_application_id => 140,
                                                           p_id_flex_code   => 'CAT#',
                                                           p_id_flex_num    => l_asset_key_flex_struct,
                                                           p_qualifier      => 'BASED_CATEGORY',
                                                           p_ccid           => l_category_id);
                    EXCEPTION
                        WHEN OTHERS THEN
                        igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
                    END;

                    BEGIN
                        l_minor_category:= fa_rx_flex_pkg.get_value(
                                             p_application_id => 140,
                                             p_id_flex_code   => 'CAT#',
                                             p_id_flex_num    =>  l_asset_key_flex_struct,
                                             p_qualifier      => 'MINOR_CATEGORY',
                                             p_ccid           => l_category_id);
                    EXCEPTION
                        WHEN OTHERS THEN
                        igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
                    END;

                    --This will get the concatenated category
                    fa_rx_shared_pkg.concat_category (struct_id       => l_cat_flex_struct,
                                                        ccid            => l_category_id,
                                                        concat_string   => l_concat_category,
                                                        segarray        => l_cat_segs);

                    --This will get the concatenated location
                    fa_rx_shared_pkg.concat_location (struct_id => l_loc_flex_struct
                                                    ,ccid => l_deprn.location_id
                                                    ,concat_string => l_concat_location
                                                    ,segarray => l_loc_segs);

                    --This will get the concatenated asset key
                    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                        p_full_path => l_path_name,
                        p_string => 'ccid'||l_deprn.code_combination_id);

                    fa_rx_shared_pkg.concat_asset_key (struct_id => l_asset_key_flex_struct,
				                  ccid => l_acct.asset_key_ccid,
				         concat_string => l_concat_asset_key,
				              segarray => l_asset_segs);

                    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                        p_full_path => l_path_name,
                        p_string => 'l_concat_location ' || l_concat_location);
                    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                        p_full_path => l_path_name,
                        p_string => 'l_concat_asset_key ' || l_concat_asset_key);
                    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                        p_full_path => l_path_name,
                        p_string => 'l_category_id ' || l_category_id);
                    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                        p_full_path => l_path_name,
                        p_string => 'l_concat_category ' || l_concat_category);
                    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                        p_full_path => l_path_name,
                        p_string => 'l_currency_code ' || l_currency_code);
                    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                        p_full_path => l_path_name,
                        p_string => 'l_concat_location ' ||l_concat_location );

                    IF NOT( Igi_Iac_Common_Utils.Iac_Round (  l_main.cost_mhca          ,
                                              l_dist_source_book )) THEN
                        null;
                    END IF;

                    IF NOT( Igi_Iac_Common_Utils.Iac_Round (  l_main.reval_reserve_mhca ,
                                                            l_dist_source_book )) THEN
                        null;
                    END IF;

                    IF NOT( Igi_Iac_Common_Utils.Iac_Round (  l_main.backlog_mhca ,
                                                            l_dist_source_book )) THEN
                        null;
                    END IF;

                    IF NOT( Igi_Iac_Common_Utils.Iac_Round (  l_ytd_mhca ,
                                                        l_dist_source_book )) THEN
                        null;
                    END IF;

                    IF NOT( Igi_Iac_Common_Utils.Iac_Round (  l_main.Accum_Deprn_MHCA ,
                                                        l_dist_source_book )) THEN
                        null;
                    END IF;

                    IF NOT( Igi_Iac_Common_Utils.Iac_Round (  l_main.operating_account_cost ,
                                                        l_dist_source_book )) THEN
                        null;
                    END IF;

                    IF NOT( Igi_Iac_Common_Utils.Iac_Round (  l_main.operating_account_backlog ,
                                                        l_dist_source_book )) THEN
                        null;
                    END IF;

                    IF NOT( Igi_Iac_Common_Utils.Iac_Round (  l_main.general_fund_mhca ,
                                                        l_dist_source_book )) THEN
                        null;
                    END IF;

                    IF NOT( Igi_Iac_Common_Utils.Iac_Round (  l_main.cost_hist ,
                                                        l_dist_source_book )) THEN
                        null;
                    END IF;

                    IF NOT( Igi_Iac_Common_Utils.Iac_Round (  l_ytd_hist ,
                                                        l_dist_source_book )) THEN
                        null;
                    END IF;

                    IF NOT( Igi_Iac_Common_Utils.Iac_Round (  l_main.accum_deprn_hist ,
                                                        l_dist_source_book )) THEN
                        null;
                    END IF;

                    INSERT INTO IGI_IMP_IAC_ITF(  distribution_id ,
                                    request_id ,
                                    set_of_books_id  ,
                                    asset_id,
                                    category_id,
                                    functional_currency_code ,
                                    book_type_code ,
                                    fiscal_year_name ,
                                    period  ,
                                    cost_center ,
                                    asset_number ,
                                    asset_description ,
                                    major_category ,
                                    minor_category ,
                                    concat_category ,
                                    reval_cost ,
                                    net_reval_reserve  ,
                                    reval_res_blog  ,
                                    reval_ytd_deprn  ,
                                    reval_deprn_reserve ,
                                    oper_acct   ,
                                    oper_exp_backlog ,
                                    general_fund ,
                                    parent_no  ,
                                    curr_reval_factor ,
                                    cumm_reval_factor,
                                    asset_tag  ,
                                    balancing_segment ,
                                    serial_no ,
                                    dpis    ,
                                    life_months ,
                                    stl_rate  ,
                                    depreciation_method  ,
                                    conc_asset_key  ,
                                    conc_location ,
                                    cost_acct  ,
                                    iac_reval_resv_acct   ,
                                    deprn_res_acct  ,
                                    deprn_backlog_acct ,
                                    gen_fund_acct ,
                                    deprn_exp_acct ,
                                    oper_exp_acct ,
                                    hist_cost ,
                                    hist_ytd_deprn  ,
                                    hist_acc_deprn,
                                    organization_name,
                                    created_by,
                                    creation_date,
                                    last_update_login,
                                    last_updated_by,
                                    last_update_date)
                    VALUES
                                    ( l_deprn.distribution_id ,
                                    p_request_id,
                                    l_set_of_books_id ,
                                    l_asset_id,
                                    l_category_id,
                                    l_currency_code ,
                                    p_book_type_code ,
                                    l_fiscal_year,
                                    l_period_name ,
                                    l_cost_center ,
                                    l_asset_number ,
                                    l_acct.description ,
                                    l_major_category ,
                                    l_minor_category ,
                                    l_concat_category  ,
                                    l_main.cost_mhca   ,
                                    l_main.reval_reserve_mhca  ,
                                    l_main.backlog_mhca ,
                                    l_ytd_mhca    ,
                                    l_main.Accum_Deprn_MHCA  ,
                                    l_main.operating_account_cost * -1, --Bug 3277826
                                    l_main.operating_account_backlog * -1, --Bug 3277826
                                    l_main.general_fund_mhca,
                                    l_acct.parent_asset_id ,
                                    l_current_reval_factor  ,
                                    l_cumulative_reval_factor ,
                                    l_acct.tag_number ,
                                    l_balancing_seg  ,
                                    l_acct.serial_number ,
                                    l_acct.date_placed_in_service ,
                                    l_main.life_in_months   ,
                                    NULL     ,
                                    l_acct.deprn_method_code ,
                                    l_concat_asset_key ,
                                    l_concat_location ,
                                    l_asset_cost_acct,
                                    l_reval_rsv_acct ,
                                    l_deprn_reserve_acct ,
                                    l_blog_deprn_rsv_acct,
                                    l_general_fund_acct,
                                    l_deprn_expense_acct ,
                                    l_oper_expense_acct,
                                    l_main.cost_hist,
                                    l_ytd_hist ,
                                    l_main.accum_deprn_hist,
                                    l_organization_name,
                                    l_user_id,
                                    sysdate,
                                    l_login_id,
                                    l_user_id,
                                    sysdate)   ;

                    /* Resetting category for next active dist Bug 3430707 */
                    l_category_id:=l_category.category_id;
                END LOOP;			--END LOOP 3;
            END LOOP;			--END LOOP 2;
        END LOOP;			--END LOOP 1;

        -- Bug 3439808, start 1
	Recreate_Intf_Data(p_book_type_code,
	                   p_request_id);
        -- Bug 3439808, end 1

    EXCEPTION
        WHEN OTHERS THEN
        igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
    	    retcode:=2;
    	    errbuf:='Exception within igirx_imp_iac_rep';

        igi_iac_debug_pkg.debug_other_string(p_level => g_unexp_level,
		     p_full_path => l_path_name,
		     p_string => 'l_set_of_books_id ' || l_set_of_books_id);
        igi_iac_debug_pkg.debug_other_string(p_level => g_unexp_level,
		     p_full_path => l_path_name,
		     p_string => 'l_period_name ' || l_period_name);
        igi_iac_debug_pkg.debug_other_string(p_level => g_unexp_level,
		     p_full_path => l_path_name,
		     p_string => 'l_general_fund_acct ' || l_general_fund_acct);
        igi_iac_debug_pkg.debug_other_string(p_level => g_unexp_level,
		     p_full_path => l_path_name,
		     p_string => 'l_operating_exp_acct ' || l_oper_expense_acct);
        igi_iac_debug_pkg.debug_other_string(p_level => g_unexp_level,
		     p_full_path => l_path_name,
		     p_string => 'l_balancing_seg ' || l_balancing_seg);
        igi_iac_debug_pkg.debug_other_string(p_level => g_unexp_level,
		     p_full_path => l_path_name,
		     p_string => 'l_book_type_code ' || p_book_type_code);

    END IMP;

END igirx_imp_iac_rep;

/
