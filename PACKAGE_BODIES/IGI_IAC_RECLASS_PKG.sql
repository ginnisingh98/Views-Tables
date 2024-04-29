--------------------------------------------------------
--  DDL for Package Body IGI_IAC_RECLASS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_RECLASS_PKG" AS
/* $Header: igiiarlb.pls 120.27.12010000.2 2010/06/25 06:48:13 schakkin ship $ */
--  A Global variable to set the debug mode
    debug_reclass BOOLEAN;
    l_output_dir varchar2(255);
    l_debug_log varchar2(255);
    l_debug_output varchar2(255);
    l_debug_print Boolean;

    -- global vlaue for allow reval index and prof flag
    ALLOW_INDEX_REVAL_FLAG BOOLEAN;
    ALLOW_PROF_REVAL_FLAG  BOOLEAN;
    SAME_PRICE_INDEX_FLAG  BOOLEAN;
    DIFF_PRICE_INDEX_FLAG  BOOLEAN;

    l_trans_rec                      FA_API_TYPES.trans_rec_type;
    l_asset_hdr_rec                  FA_API_TYPES.asset_hdr_rec_type;
    l_asset_cat_rec_old              FA_API_TYPES.asset_cat_rec_type;
    l_asset_cat_rec_new              FA_API_TYPES.asset_cat_rec_type;
    l_asset_desc_rec                 FA_API_TYPES.asset_desc_rec_type;
    l_asset_type_rec                 FA_API_TYPES.asset_type_rec_type;
    l_calling_function              varchar2(250);
    l_deprn_reserve_amount   NUmber;
    chr_newline VARCHAR2(8);
    l_deprn_ytd number; --- for ytd previous old active distributions

    --===========================FND_LOG.START=====================================

    g_state_level NUMBER;
    g_proc_level  NUMBER;
    g_event_level NUMBER;
    g_excep_level NUMBER;
    g_error_level NUMBER;
    g_unexp_level NUMBER;
    g_path        VARCHAR2(100);

    --===========================FND_LOG.END=====================================

    /*
    * BOOLTOCHAR
    *
    * A utility function to convert boolean values to char to print in
    * debug statements
    */
    FUNCTION BOOLTOCHAR(value IN BOOLEAN) RETURN VARCHAR2
    IS
    BEGIN
        IF (value) THEN
            RETURN 'TRUE';
        ELSE
            RETURN 'FALSE';
        END IF;
    END BOOLTOCHAR;

    PROCEDURE do_round ( p_amount in out NOCOPY number, p_book_type_code in varchar2) is
      l_path varchar2(150) := g_path||'do_round(p_amount,p_book_type_code)';
      l_amount number     := p_amount;
      l_amount_old number := p_amount;
      --l_path varchar2(150) := g_path||'do_round';
    begin
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'--- Inside Round() ---');
       IF IGI_IAC_COMMON_UTILS.Iac_Round(X_Amount => l_amount, X_Book => p_book_type_code)
       THEN
          p_amount := l_amount;
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'IGI_IAC_COMMON_UTILS.Iac_Round is TRUE');
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_amount = '||p_amount);
       ELSE
          p_amount := round( l_amount, 2);
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'IGI_IAC_COMMON_UTILS.Iac_Round is FALSE');
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_amount = '||p_amount);
       END IF;
    exception when others then
      p_amount := l_amount_old;
      igi_iac_debug_pkg.debug_unexpected_msg(l_path);
      Raise;
    END;

-- ======================================================================
-- CATEGORY VALIDATION
-- ======================================================================
FUNCTION Do_validate_category
RETURN boolean is
    l_return_value boolean;
    l_original_category_id number;
    l_new_category_id number;
    l_old_cap_flag fa_categories.capitalize_flag%type;
    l_old_cat_type fa_categories.category_type%type;
    l_new_cap_flag fa_categories.capitalize_flag%type;
    l_new_cat_type fa_categories.category_type%type;
    l_old_index_reval_flag igi_iac_category_books.allow_indexed_reval_flag%Type;
    l_old_prof_reval_flag igi_iac_category_books.allow_prof_reval_flag%Type;
    l_new_index_reval_flag igi_iac_category_books.allow_indexed_reval_flag%Type;
    l_new_prof_reval_flag igi_iac_category_books.allow_prof_reval_flag%Type;
    l_path_name VARCHAR2(150);


     -- cursor to validate category linked to iac book
    Cursor get_category_id(c_category_id Number)is
    SELECT category_id,allow_indexed_reval_flag,allow_prof_reval_flag
    FROM igi_iac_category_books
    WHERE book_type_code = l_asset_hdr_rec.book_type_code
    AND category_id = c_category_id;

    --cursor to get the category capitalized
    Cursor get_cat_cap_flag(c_category_id Number) is
    SELECT capitalize_flag,category_type
    FROM fa_categories
    WHERE category_id = c_category_id;


BEGIN
    l_path_name := g_path||'do_validate_category';
    l_return_value := False;
    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     + Enter validate category');

     -- check if same category or null category
    IF ((l_asset_cat_rec_old.category_id = l_asset_cat_rec_new.category_id)or
        (l_asset_cat_rec_old.category_id is null or l_asset_cat_rec_new.category_id is null))
         THEN
  	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     + Same category old and new or null value');

          Return false;
    End if;
    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     + different categories old ' || l_asset_cat_rec_old.category_id
				 || 'and new' ||l_asset_cat_rec_new.category_id );

    /**
    --validate if both categories are added to IAC book controls
    **/
    -- A record should exisit in iac category books for both categories for same book_typec_code
    -- check for original category id
    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     + orinignal category id iac book test ..'||l_asset_cat_rec_old.category_id);

   Open get_category_id(l_asset_cat_rec_old.category_id);
    Fetch get_category_id into l_original_category_id,
                               l_old_index_reval_flag,
                               l_old_prof_reval_flag ;
    IF NOT get_category_id%FOUND THEN
        -- Raise error message that category is not exisiting in iac book
       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '     +error message that category is not exisiting in iac book  '||l_asset_cat_rec_old.category_id);

       Close get_category_id;
        Return false;
    END IF;
    Close get_category_id;

    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     + Original category  exisits in iac book  '||l_asset_cat_rec_old.category_id);

    Open get_category_id(l_asset_cat_rec_new.category_id);
    Fetch get_category_id into l_original_category_id,
                               l_new_index_reval_flag,
                               l_new_prof_reval_flag ;
    IF NOT get_category_id%FOUND THEN
        -- Raise error message that category is not exisiting in iac book
       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     +error message that category is not exisiting in iac book  '||l_asset_cat_rec_new.category_id);
       Close get_category_id;
        Return false;
    END IF;
    Close get_category_id;

    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     + New category  exisits in iac book  '||l_asset_cat_rec_old.category_id);

    /**
    --validate if both categories are captitalized
    **/
    -- for the old category
    open get_cat_cap_flag(l_asset_cat_rec_old.category_id);
    Fetch get_cat_cap_flag into l_old_cap_flag,
                                l_old_cat_type;
    Close get_cat_cap_flag;
    -- for new category
    open get_cat_cap_flag(l_asset_cat_rec_new.category_id);
    Fetch get_cat_cap_flag into l_new_cap_flag,
                                l_new_cat_type;
    Close get_cat_cap_flag;
    --check the category flags
    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     + check for category captilized falgs');

    IF (l_old_cap_flag = 'YES') THEN
         IF (l_old_cap_flag <> l_new_cap_flag) THEN
  		     igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '     + both the categories not captilized falgs');

                     Return False;
          End IF;
     END IF;

     igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     + check for category captilized falgs success');

    /**
    --Set the indexed and profesional flag for revaluation
    **/
    --set the allow index reval flag
     IF l_new_index_reval_flag ='Y' THEN
            allow_index_reval_flag := True;
     ELSE
            allow_index_reval_flag := False;
     END IF;
     --set the prof  reval flag
     IF l_new_prof_reval_flag ='Y' THEN
            allow_prof_reval_flag := True;
     ELSE
            allow_prof_reval_flag := False;
     END IF;

     igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     + set the indexed and prof flags ');
     igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     + set the indexed flag ' || l_new_index_reval_flag );
     igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     + set the prof flag ' ||l_new_prof_reval_flag );
     igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     + EXIT Validate category' );

   Return True;

END; -- do validate category


-- ======================================================================
-- ASSET VALIDATION
-- ======================================================================
FUNCTION Do_Validate_Asset
RETURN boolean is

    -- cursor for to check asset type
   /* Cursor to find out NOCOPY if the asset is revalued atleast once */

	CURSOR 	c_asset_revalued(c_asset_id IGI_IAC_ASSET_BALANCES.asset_id%type) IS
		SELECT 'X'
		FROM	igi_iac_asset_balances
		WHERE	asset_id=l_asset_hdr_rec.asset_id
        AND     book_type_code = l_asset_hdr_rec.book_type_code;

    l_asset_revalued c_asset_revalued%rowtype;
    l_path_name VARCHAR2(150);

BEGIN
    l_path_name := g_path||'do_validate_asset';
    -- check if revaluation atleast once
     igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     + check if revaluation atleast once' );
     igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     + check if revaluation atleast once ...' || l_asset_hdr_rec.asset_id );
     igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     + check if revaluation atleast once ...' || l_asset_hdr_rec.book_type_code);

    	/* Check IF Asset is revalued at least once */
        open c_asset_revalued(l_asset_hdr_rec.asset_id);
	    fetch c_asset_revalued into l_asset_revalued;
    	IF c_asset_revalued%NOTFOUND THEN
          	close c_asset_revalued;
  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '+ No IAC revaluation atleast once');

   		RETURN(FALSE);
         END IF;

    	close c_asset_revalued;

  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     + check if revaluation atleast once success' );

   IF NOT (l_asset_type_rec.asset_type in ('CAPITALIZED') ) THEN
        -- ERROR MESSAGE
       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     + NOT CAPITALIZED ASSET' );
       return FALSE;
    END IF;
    Return True;
END; -- do validate asset

/*
+===============================================================================+
|	Procedure To Insert Data into IGI_IAC_TRANSACTION_HEADERS		|
================================================================================+
*/
    PROCEDURE Insert_data_trans_hdr(p_adjustment_id 		in out NOCOPY IGI_IAC_TRANSACTION_HEADERS.adjustment_id%type,
    				p_transaction_header_id 	in IGI_IAC_TRANSACTION_HEADERS.transaction_header_id%type,
    				p_adjustment_id_out		in IGI_IAC_TRANSACTION_HEADERS.adjustment_id_out%type,
    				p_transaction_type_code		in IGI_IAC_TRANSACTION_HEADERS.transaction_type_code%type,
    				p_transaction_date_entered 	in IGI_IAC_TRANSACTION_HEADERS.transaction_date_entered%type,
    				p_mass_reference_id		in IGI_IAC_TRANSACTION_HEADERS.mass_reference_id%type,
    				p_book_type_code		in IGI_IAC_TRANSACTION_HEADERS.book_type_code%type,
    				p_asset_id			in IGI_IAC_TRANSACTION_HEADERS.asset_id%type,
    				p_revaluation_flag		in IGI_IAC_TRANSACTION_HEADERS.revaluation_type_flag%type,
      				p_adjustment_status		in IGI_IAC_TRANSACTION_HEADERS.adjustment_status%type,
	    			p_category_id			in IGI_IAC_TRANSACTION_HEADERS.category_id%type,
    				p_period_counter		in IGI_IAC_TRANSACTION_HEADERS.period_counter%type,
    				p_event_id              in number
    				) IS




    l_rowid 	VARCHAR2(25);
    l_mesg	VARCHAR2(500);
    l_path_name VARCHAR2(150);

    BEGIN
    l_path_name := g_path||'insert_data_trans_hdr';


    	/* Call the TBH  for inserting data into IGI_IAC_TRANSACTION_HEADERS */

    IGI_IAC_TRANS_HEADERS_PKG.insert_row(
    			x_rowid                  	    =>l_rowid,
    			x_adjustment_id                     =>p_adjustment_id ,
    			x_transaction_header_id             =>p_transaction_header_id ,
    			x_adjustment_id_out                 =>p_adjustment_id_out,
    			x_transaction_type_code             =>p_transaction_type_code	,
    			x_transaction_date_entered          =>p_transaction_date_entered ,
    			x_mass_refrence_id                  =>p_mass_reference_id,
    			x_transaction_sub_type              =>null,
    			x_book_type_code                    =>p_book_type_code,
    			x_asset_id                          =>p_asset_id,
    			x_category_id                       =>p_category_id,
    			x_adj_deprn_start_date              =>null,
    			x_revaluation_type_flag             =>p_revaluation_flag,
    			x_adjustment_status                 =>p_adjustment_status,
    			x_period_counter                    =>p_period_counter,
    			x_mode                              =>'R',
    			x_event_id                          =>p_event_id
    				);


     EXCEPTION
        WHEN OTHERS THEN
  		igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);

		l_mesg:=SQLERRM;
		FA_SRVR_MSG.Add_Message(
	                Calling_FN 	=> l_calling_function ,
        	        Name 		=> 'IGI_IAC_EXCEPTION',
        	        TOKEN1		=> 'PACKAGE',
        	        VALUE1		=> 'RECLASS',
        	        TOKEN2		=> 'ERROR_MESSAGE',
        	        VALUE2		=> l_mesg,
                        APPLICATION     => 'IGI');

		rollback;

    END insert_data_trans_hdr;



/*
+===============================================================================+
|	Procedure to insert data into IGI_IAC_DET_BALANCES			|
================================================================================+
*/

    PROCEDURE insert_data_det(p_adjustment_id	in IGI_IAC_DET_BALANCES.adjustment_id%type,
    			      p_asset_id		in IGI_IAC_DET_BALANCES.asset_id%type,
    			      p_distribution_id		in IGI_IAC_DET_BALANCES.distribution_id%type,
    			      p_period_counter		in IGI_IAC_DET_BALANCES.period_counter%type,
    			      p_book_type_code		in IGI_IAC_DET_BALANCES.book_type_code%type,
    			      p_adjusted_cost		in IGI_IAC_DET_BALANCES.adjustment_cost%type,
    			      p_net_book_value		in IGI_IAC_DET_BALANCES.net_book_value%type,
    			      p_reval_reserve		in IGI_IAC_DET_BALANCES.reval_reserve_cost%type,
    			      p_reval_reserve_gen_fund	in IGI_IAC_DET_BALANCES.reval_reserve_gen_fund%type,
    			      p_reval_reserve_backlog	in IGI_IAC_DET_BALANCES.reval_reserve_backlog%type,
                      p_reval_reserve_net in IGI_IAC_DET_BALANCES.reval_reserve_net%type,
    			      p_op_acct			in IGI_IAC_DET_BALANCES.operating_acct_cost%type,
                      p_op_acct_net			in IGI_IAC_DET_BALANCES.operating_acct_net%type,
    			      p_deprn_reserve		in IGI_IAC_DET_BALANCES.deprn_reserve%type,
    			      p_deprn_reserve_backlog 	in IGI_IAC_DET_BALANCES.deprn_reserve_backlog%type,
    			      p_deprn_ytd		in IGI_IAC_DET_BALANCES.deprn_ytd%type,
    			      p_deprn_period		in IGI_IAC_DET_BALANCES.deprn_period%type,
    			      p_gen_fund_acc		in IGI_IAC_DET_BALANCES.general_fund_acc%type,
    			      p_gen_fund_per		in IGI_IAC_DET_BALANCES.general_fund_acc%type,
    			      p_current_reval_factor	in IGI_IAC_DET_BALANCES.current_reval_factor%type,
    			      p_cumulative_reval_factor in IGI_IAC_DET_BALANCES.cumulative_reval_factor%type,
    			      p_reval_flag		in IGI_IAC_DET_BALANCES.active_flag%type,
    			      p_op_acct_ytd		in IGI_IAC_DET_BALANCES.operating_acct_ytd%type,
    			      p_operating_acct_backlog  in IGI_IAC_DET_BALANCES.operating_acct_backlog%type,
    			      p_last_reval_date		in IGI_IAC_DET_BALANCES.last_reval_date%type
    			      ) IS

	l_rowid VARCHAR2(25);
	l_mesg	VARCHAR2(500);
        l_path_name VARCHAR2(150);
    BEGIN
        l_path_name := g_path||'insert_data_det';

     	/* Call to TBH for insert into IGI_IAC_DET_BALANCES */
     	IGI_IAC_DET_BALANCES_PKG.insert_row(
			x_rowid       			=>l_rowid,
    			x_adjustment_id  		=>p_adjustment_id,
    			x_asset_id  			=>p_asset_id,
    			x_distribution_id 		=>p_distribution_id,
    			x_book_type_code 		=>p_book_type_code,
    			x_period_counter		=>p_period_counter,
    			x_adjustment_cost 		=>p_adjusted_cost,
    			x_net_book_value 		=>p_net_book_value,
    			x_reval_reserve_cost  		=>p_reval_reserve,
                x_reval_reserve_backlog  	=>p_reval_reserve_backlog,
    			x_reval_reserve_gen_fund 	=>p_reval_reserve_gen_fund,
                -- Bug 2767992 Sekhar Modified for reval reserve net
    			x_reval_reserve_net      	=>p_reval_reserve_net,
    			x_operating_acct_cost  		=>p_op_acct,
    			x_operating_acct_backlog  	=>p_operating_acct_backlog,
    			x_operating_acct_net       	=>p_op_acct_net,
    			x_operating_acct_ytd     	=>p_op_acct_ytd,
    			x_deprn_period  		=>p_deprn_period,
    			x_deprn_ytd        		=>p_deprn_ytd,
    			x_deprn_reserve     		=>p_deprn_reserve,
    			x_deprn_reserve_backlog		=>p_deprn_reserve_backlog,
    			x_general_fund_per    		=>p_gen_fund_per,
    			x_general_fund_acc              =>p_gen_fund_acc,
    			x_last_reval_date               =>p_last_reval_date,
    			x_current_reval_factor  	=>p_current_reval_factor,
    			x_cumulative_reval_factor    	=>p_cumulative_reval_factor,
    			x_active_flag   		=>p_reval_flag,
    			x_mode   			=>'R'
    						);

     	EXCEPTION
    	WHEN OTHERS THEN
  		igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);

		l_mesg:=SQLERRM;
		FA_SRVR_MSG.Add_Message(
	                Calling_FN 	=> l_calling_function ,
        	        Name 		=> 'IGI_IAC_EXCEPTION',
        	        TOKEN1		=> 'PACKAGE',
        	        VALUE1		=> 'RECLASS',
        	        TOKEN2		=> 'ERROR_MESSAGE',
        	        VALUE2		=> l_mesg,
                    	APPLICATION 	=> 'IGI');

		rollback;
    END insert_data_det;

/*
+===============================================================================+
|	Procedure to prorate the amounts based on the units assigned		|
================================================================================+
*/
    PROCEDURE Prorate_amount_for_dist(P_dist_id		in FA_DISTRIBUTION_HISTORY.DISTRIBUTION_ID%type,
			          	P_units_dist   		in number,
					P_units_total		in number,
					P_reval_reserve  	in out NOCOPY number,
					P_general_fund 		in out NOCOPY number,
					P_backlog_deprn 	in out NOCOPY number,
					P_deprn_reserve		in out NOCOPY number,
					P_adjusted_cost		in out NOCOPY number,
					P_net_book_value	in out NOCOPY number,
					P_deprn_per		in out NOCOPY number,
					P_op_acct		in out NOCOPY number,
					p_ytd_deprn		in out NOCOPY number,
					p_op_acct_ytd		in out NOCOPY number,
					p_event_id          in number

			             ) IS

	prorate_factor 	number;
	l_mesg		VARCHAR2(500);
        l_path_name VARCHAR2(150);

    BEGIN

        l_path_name := g_path||'prorate_amount_for_dist';

	/*Prorate the various amounts between for the given distribution*/

	Prorate_factor          := p_units_dist/P_units_total;
	P_reval_reserve         := P_reval_reserve* Prorate_factor  ;
	P_reval_reserve         := round(P_reval_reserve,2);
	P_general_fund          := P_general_fund * Prorate_factor ;
	P_general_fund          := round(P_general_fund,2);
	P_backlog_deprn         := P_backlog_deprn* Prorate_factor ;
	P_backlog_deprn         := round(P_backlog_deprn,2);
	P_deprn_reserve         := P_deprn_reserve* Prorate_factor ;
	P_deprn_reserve         := round(P_deprn_reserve,2);
	P_adjusted_cost         := P_adjusted_cost* Prorate_factor ;
	P_adjusted_cost         := round(P_adjusted_cost,2);
	P_net_book_value        := P_net_book_value* Prorate_factor  ;
	P_net_book_value        := round(P_net_book_value,2);
	P_deprn_per             := P_deprn_per* Prorate_factor;
	P_deprn_per             := round(P_deprn_per,2);
	P_op_acct               := p_op_acct*Prorate_factor;
	P_op_acct               := round(P_op_acct,2);
	P_ytd_deprn             := p_ytd_deprn*Prorate_factor;
	P_ytd_deprn             := round(P_ytd_deprn,2);
	P_op_acct_ytd           := p_op_acct_ytd*Prorate_factor;
	P_op_acct_ytd           := round(P_op_acct_ytd,2);

    EXCEPTION
    	WHEN OTHERS THEN
  		igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);

		l_mesg:=SQLERRM;
		FA_SRVR_MSG.Add_Message(
	                Calling_FN 	=> l_calling_function ,
        	        Name 		=> 'IGI_IAC_EXCEPTION',
        	        TOKEN1		=> 'PACKAGE',
        	        VALUE1		=> 'RECLASS',
        	        TOKEN2		=> 'ERROR_MESSAGE',
        	        VALUE2		=> l_mesg,
                    	APPLICATION 	=> 'IGI');

    END prorate_amount_for_dist;


    procedure create_acctg_entry ( l_ccid         in number
                                 , p_amount          in number
                                 , l_adjust_type  in varchar2
                                 , l_cr_dr_flag  in varchar2
                                 , l_set_of_books_id in number
                                 , fp_det_balances   in igi_iac_det_balances%rowtype
				 , l_adjust_offset_type in varchar2 Default Null
				 , l_Report_CCID	in varchar2 Default Null
				 , p_event_id       in number
                                 )
    is
       l_rowid varchar2(30);
       l_units_assigned number;
       l_path_name VARCHAR2(150);
    begin
       l_rowid := null;
       l_path_name := g_path||'create_acctg_entry';
       if p_amount = 0 then
  	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '+amount is 0, accounting entries skipped');

          return;
       end if;

       select units_assigned
       into   l_units_assigned
       from   fa_distribution_history
       where  book_type_code = fp_det_balances.book_type_code
         and  asset_id       = fp_det_balances.asset_id
         and  distribution_id = fp_det_balances.distribution_id
       ;

        IGI_IAC_ADJUSTMENTS_PKG.insert_row (
            x_rowid                   => l_rowid,
            x_adjustment_id           => fp_det_balances.adjustment_id,
            x_book_type_code          => fp_det_balances.book_type_code,
            x_code_combination_id     => l_ccid,
            x_set_of_books_id         => l_set_of_books_id,
            x_dr_cr_flag              => l_cr_dr_flag,
            x_amount                  => p_amount,
            x_adjustment_type         => l_adjust_type,
            x_transfer_to_gl_flag     => 'Y',
            x_units_assigned          => l_units_assigned,
            x_asset_id                => fp_det_balances.asset_id,
            x_distribution_id         => fp_det_balances.distribution_id,
            x_period_counter          => fp_det_balances.period_counter,
	    x_adjustment_offset_type  => l_adjust_offset_type,
	    x_report_ccid             => l_report_ccid,
            x_mode                    => 'R',
            x_event_id                => p_event_id
            ) ;

     end;

    function create_iac_acctg
         ( fp_det_balances in IGI_IAC_DET_BALANCES%ROWTYPE
          , fp_create_acctg_flag in boolean
          , fp_adjustement_type in Varchar2
       	 , l_Adjust_offset_type in varchar2 Default Null
	 , l_Report_CCID	in varchar2 Default Null
	 , p_event_id       in number
          )
    return boolean is
      l_rowid rowid;
      l_sob_id number;
      l_coa_id number;
      l_currency varchar2(30);
      l_precision number;
      l_dr_ccid  gl_code_combinations.code_combination_id%type;
      l_cr_ccid  gl_code_combinations.code_combination_id%type;
      l_revl_rsv_ccid gl_code_combinations.code_combination_id%type;
      l_blog_rsv_ccid gl_code_combinations.code_combination_id%TYPE;
      l_op_exp_ccid   gl_code_combinations.code_combination_id%TYPE;
      l_gen_fund_ccid gl_code_combinations.code_combination_id%TYPE;
      l_asset_cost_ccid gl_code_combinations.code_combination_id%TYPE;
      l_deprn_rsv_ccid gl_code_combinations.code_combination_id%TYPE;
      l_deprn_exp_ccid gl_code_combinations.code_combination_id%TYPE;
      l_cr_dr_flag_cost varchar(2);
      l_cr_dr_flag_reval_reserve varchar(2);
      l_cr_dr_flag_gen_fund varchar(2);
      l_cr_dr_flag_blog varchar(2);
      l_cr_dr_flag_op varchar(2);
      l_cr_dr_flag_exp varchar(2);
      l_cr_dr_flag_reserve varchar(2);
      l_path_name VARCHAR2(150);

      procedure check_ccid ( p_ccid_desc in varchar2) is
  	   l_path_name VARCHAR2(150);
      begin
  	    l_path_name := g_path||'check_ccid';
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '+acctg creation for '||p_ccid_desc||' failed');
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'error create_iac_acctg');
      end;

      begin
        l_path_name := g_path||'create_iac_acctg';

  	     igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'begin create_iac_acctg');
  	     igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '+        Det Balances');
  	     igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '+        book type code'||fp_det_balances.book_type_code);
  	     igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '+        asset id'||fp_det_balances.asset_id);
  	     igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '+        distribution id '||fp_det_balances.distribution_id);
  	     igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '+        adjustment id '||fp_det_balances.adjustment_id);
  	     igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '+        reval reserve '||fp_det_balances.reval_reserve_cost);
  	     igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '+        reserve backlog '||fp_det_balances.reval_reserve_backlog);
  	     igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '+        gen fund'||fp_det_balances.reval_reserve_gen_fund);
  	     igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '+        acct cost'||fp_det_balances.operating_acct_cost);
  	     igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '+        op acct backlog'||fp_det_balances.operating_acct_backlog);
  	     igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '+        deprn ytd'||fp_det_balances.deprn_ytd);
  	     igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '+        rserv back deprn '||fp_det_balances.deprn_reserve_backlog);


       if not fp_create_acctg_flag then
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '+acctg creation not allowed');
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'end create_iac_acctg');

          return true;
       end if;

       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '+acctg creation get gl information');

       if not IGI_IAC_COMMON_UTILS.GET_BOOK_GL_INFO
              ( X_BOOK_TYPE_CODE      => fp_det_balances.book_type_code
              , SET_OF_BOOKS_ID       => l_sob_id
              , CHART_OF_ACCOUNTS_ID  => l_coa_id
              , CURRENCY              => l_currency
              , PRECISION             => l_precision
              )
       then
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '+acctg creation unable to get gl info');
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'end create_iac_acctg');

          return false;
       end if;
       --
       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '+acctg creation get all accounts');
       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '+distribution id '|| fp_det_balances.distribution_id );

       IF NOT IGI_IAC_COMMON_UTILS.get_account_ccid
                    ( X_book_type_code =>  fp_det_balances.book_type_code
                    , X_asset_id       =>  fp_det_balances.asset_id
                    , X_distribution_id => fp_det_balances.distribution_id
                    ,X_TRANSACTION_HEADER_ID => l_trans_rec.TRANSACTION_HEADER_ID
                    ,X_calling_function => 'RECLASS'
                    , X_account_type    => 'REVAL_RESERVE_ACCT'
                    , account_ccid      => l_revl_rsv_ccid
                    )
       THEN
          check_ccid ( 'reval reserve');
          return false;
       END IF;
      IF NOT IGI_IAC_COMMON_UTILS.get_account_ccid
                    ( X_book_type_code => fp_det_balances.book_type_code
                    , X_asset_id       => fp_det_balances.asset_id
                    , X_distribution_id => fp_det_balances.distribution_id
                   ,X_TRANSACTION_HEADER_ID => l_trans_rec.TRANSACTION_HEADER_ID
                    ,X_calling_function => 'RECLASS'
                    , X_account_type    => 'BACKLOG_DEPRN_RSV_ACCT'
                    , account_ccid      => l_blog_rsv_ccid
                    )
       THEN
          check_ccid ( 'backlog deprn reserve');
          return false;
       END IF;
       IF NOT IGI_IAC_COMMON_UTILS.get_account_ccid
                    ( X_book_type_code => fp_det_balances.book_type_code
                    , X_asset_id       => fp_det_balances.asset_id
                    , X_distribution_id => fp_det_balances.distribution_id
                    ,X_TRANSACTION_HEADER_ID => l_trans_rec.TRANSACTION_HEADER_ID
                    ,X_calling_function => 'RECLASS'
                    , X_account_type    => 'OPERATING_EXPENSE_ACCT'
                    , account_ccid      => l_op_exp_ccid
                    )
       THEN
          check_ccid ( 'operating account');
          return false;
       END IF;
        IF NOT IGI_IAC_COMMON_UTILS.get_account_ccid
                    ( X_book_type_code => fp_det_balances.book_type_code
                    , X_asset_id       => fp_det_balances.asset_id
                    , X_distribution_id => fp_det_balances.distribution_id
                    ,X_TRANSACTION_HEADER_ID => l_trans_rec.TRANSACTION_HEADER_ID
                     ,X_calling_function => 'RECLASS'
                    , X_account_type    => 'GENERAL_FUND_ACCT'
                    , account_ccid      => l_gen_fund_ccid
                    )
       THEN
          check_ccid ( 'general fund account');
          return false;
       END IF;
        IF NOT IGI_IAC_COMMON_UTILS.get_account_ccid
                    ( X_book_type_code => fp_det_balances.book_type_code
                    , X_asset_id       => fp_det_balances.asset_id
                    , X_distribution_id => fp_det_balances.distribution_id
                    ,X_TRANSACTION_HEADER_ID => l_trans_rec.TRANSACTION_HEADER_ID
                    ,X_calling_function => 'RECLASS'
                    , X_account_type    => 'ASSET_COST_ACCT'
                    , account_ccid      => l_asset_cost_ccid
                    )
       THEN
          check_ccid ( 'asset cost account');
          return false;
       END IF;
       IF NOT IGI_IAC_COMMON_UTILS.get_account_ccid
                    ( X_book_type_code => fp_det_balances.book_type_code
                    , X_asset_id       => fp_det_balances.asset_id
                    , X_distribution_id => fp_det_balances.distribution_id
                    ,X_TRANSACTION_HEADER_ID => l_trans_rec.TRANSACTION_HEADER_ID
                    ,X_calling_function => 'RECLASS'
                    , X_account_type    => 'DEPRN_RESERVE_ACCT'
                    , account_ccid      => l_deprn_rsv_ccid
                   )
       THEN
          check_ccid ( 'deprn reserve account');
          return false;
       END IF;
       IF NOT IGI_IAC_COMMON_UTILS.get_account_ccid
                    ( X_book_type_code => fp_det_balances.book_type_code
                    , X_asset_id       => fp_det_balances.asset_id
                    , X_distribution_id => fp_det_balances.distribution_id
                    ,X_TRANSACTION_HEADER_ID => l_trans_rec.TRANSACTION_HEADER_ID
                    ,X_calling_function => 'RECLASS'
                    , X_account_type    => 'DEPRN_EXPENSE_ACCT'
                    , account_ccid      => l_deprn_exp_ccid
                    )
       THEN
          check_ccid ( 'deprn reserve account');
          return false;
       END IF;

       begin
        If fp_adjustement_type = 'OLD' Then

  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '+acctg creation cost vs reval reserve');

          /*create_acctg_entry (  l_dr_ccid        => l_asset_cost_ccid
                             , l_cr_ccid         => l_revl_rsv_ccid
                             , p_amount          => fp_det_balances.reval_reserve_cost
                             , l_dr_adjust_type  => 'COST'
                             , l_cr_adjust_type  => 'REVAL RESERVE'
                             , l_set_of_books_id => l_sob_id
                             , fp_det_balances   => fp_det_balances
                             );*/

             create_acctg_entry (  l_ccid            => l_asset_cost_ccid
                                 , p_amount          => fp_det_balances.reval_reserve_cost
                                 , l_adjust_type     => 'COST'
                                 , l_cr_dr_flag      => 'CR'
                                 , l_set_of_books_id => l_sob_id
                                , fp_det_balances   => fp_det_balances
				, l_adjust_offset_type	=> 'REVAL RESERVE'
				, l_report_ccid	=> l_revl_rsv_ccid
				, p_event_id    => p_event_id
                                );

            create_acctg_entry (  l_ccid             => l_revl_rsv_ccid
                                , p_amount          => fp_det_balances.reval_reserve_cost
                                , l_adjust_type     => 'REVAL RESERVE'
                                , l_cr_dr_flag      => 'DR'
                                , l_set_of_books_id => l_sob_id
                                , fp_det_balances   => fp_det_balances
				, l_adjust_offset_type	=> 'COST'
				, l_report_ccid	=> Null
				, p_event_id    => p_event_id
                              );

  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '+acctg creation reval reserve vs backlog reserve');

         /*create_acctg_entry (  l_dr_ccid   =>    l_revl_rsv_ccid
                             , l_cr_ccid   =>    l_blog_rsv_ccid
                             , p_amount    =>    fp_det_balances.reval_reserve_backlog
                             , l_dr_adjust_type  => 'REVAL RESERVE'
                             , l_cr_adjust_type  => 'BL RESERVE'
                             , l_set_of_books_id => l_sob_id
                             , fp_det_balances   => fp_det_balances
                             );*/
          create_acctg_entry (  l_ccid             => l_revl_rsv_ccid
                                , p_amount          => fp_det_balances.reval_reserve_backlog
                                , l_adjust_type     => 'REVAL RESERVE'
                                , l_cr_dr_flag      => 'CR'
                                , l_set_of_books_id => l_sob_id
                                , fp_det_balances   => fp_det_balances
				, l_adjust_offset_type	=> 'BL RESERVE'
				, l_report_ccid	=> Null
				, p_event_id    => p_event_id
                              );

         create_acctg_entry (  l_ccid               => l_blog_rsv_ccid
                                , p_amount          => fp_det_balances.reval_reserve_backlog
                                , l_adjust_type     => 'BL RESERVE'
                                , l_cr_dr_flag      => 'DR'
                                , l_set_of_books_id => l_sob_id
                                , fp_det_balances   => fp_det_balances
				, l_adjust_offset_type	=> 'REVAL RESERVE'
				, l_report_ccid	=> l_revl_rsv_ccid
				, p_event_id    => p_event_id
                              );

  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '+acctg creation reval reserve vs gen fund');


         /*create_acctg_entry (  l_dr_ccid   =>    l_revl_rsv_ccid
                             , l_cr_ccid   =>    l_gen_fund_ccid
                             , p_amount    =>    fp_det_balances.reval_reserve_gen_fund
                             , l_dr_adjust_type  => 'REVAL RESERVE'
                             , l_cr_adjust_type  => 'GENERAL FUND'
                             , l_set_of_books_id => l_sob_id
                             , fp_det_balances   => fp_det_balances
                             );*/
          create_acctg_entry (  l_ccid             => l_revl_rsv_ccid
                                , p_amount          => fp_det_balances.reval_reserve_gen_fund
                                , l_adjust_type     => 'REVAL RESERVE'
                                , l_cr_dr_flag      => 'CR'
                                , l_set_of_books_id => l_sob_id
                                , fp_det_balances   => fp_det_balances
				, l_adjust_offset_type	=> 'GENERAL FUND'
				, l_report_ccid	=> Null
				, p_event_id    => p_event_id
                                   );

         create_acctg_entry (  l_ccid               => l_gen_fund_ccid
                                , p_amount          => fp_det_balances.reval_reserve_gen_fund
                                , l_adjust_type     => 'GENERAL FUND'
                                , l_cr_dr_flag      => 'DR'
                                , l_set_of_books_id => l_sob_id
                                , fp_det_balances   => fp_det_balances
				, l_adjust_offset_type	=> 'REVAL RESERVE'
				, l_report_ccid	=> l_revl_rsv_ccid
				, p_event_id    => p_event_id
                              );

  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '+acctg creation op account vs cost');

         /*create_acctg_entry (  l_dr_ccid   =>    l_op_exp_ccid
                             , l_cr_ccid   =>    l_asset_cost_ccid
                             , p_amount    =>    fp_det_balances.operating_acct_cost
                             , l_dr_adjust_type  => 'OP ACCOUNT'
                             , l_cr_adjust_type  => 'COST'
                             , l_set_of_books_id => l_sob_id
                             , fp_det_balances   => fp_det_balances
                             );*/
             IF Diff_price_index_flag Then
                create_acctg_entry (  l_ccid               => l_op_exp_ccid
                                , p_amount          => fp_det_balances.operating_acct_cost
                                , l_adjust_type     => 'OP EXPENSE'
                                , l_cr_dr_flag      => 'DR'
                                , l_set_of_books_id => l_sob_id
                                , fp_det_balances   => fp_det_balances
				, l_adjust_offset_type	=> 'COST'
				, l_report_ccid	=> Null
				, p_event_id    => p_event_id
                              );
              End if;
          create_acctg_entry (  l_ccid            => l_asset_cost_ccid
                                 , p_amount          => fp_det_balances.operating_acct_cost
                                 , l_adjust_type     => 'COST'
                                 , l_cr_dr_flag      => 'CR'
                                 , l_set_of_books_id => l_sob_id
                                , fp_det_balances   => fp_det_balances
				, l_adjust_offset_type	=> 'OP EXPENSE'
				, l_report_ccid	=> l_op_exp_ccid
				, p_event_id    => p_event_id
                                );

  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '+acctg creation backlog vs op account');

         /*create_acctg_entry (  l_dr_ccid   =>    l_blog_rsv_ccid
                             , l_cr_ccid   =>    l_op_exp_ccid
                             , p_amount    =>    fp_det_balances.operating_acct_backlog
                             , l_dr_adjust_type  => 'BL RESERVE'
                             , l_cr_adjust_type  => 'OP ACCOUNT'
                             , l_set_of_books_id => l_sob_id
                             , fp_det_balances   => fp_det_balances
                             );*/
          create_acctg_entry (  l_ccid               => l_blog_rsv_ccid
                                , p_amount          => fp_det_balances.operating_acct_backlog
                                , l_adjust_type     => 'BL RESERVE'
                                , l_cr_dr_flag      => 'DR'
                                , l_set_of_books_id => l_sob_id
                                , fp_det_balances   => fp_det_balances
				, l_adjust_offset_type	=> 'OP EXPENSE'
				, l_report_ccid	=> l_op_exp_ccid
				, p_event_id    => p_event_id
                              );

             IF Diff_price_index_flag Then
              create_acctg_entry (  l_ccid               => l_op_exp_ccid
                                , p_amount          => fp_det_balances.operating_acct_backlog
                                , l_adjust_type     => 'OP EXPENSE'
                                , l_cr_dr_flag      => 'CR'
                                , l_set_of_books_id => l_sob_id
                                , fp_det_balances   => fp_det_balances
				, l_adjust_offset_type	=> 'BL RESERVE'
				, l_report_ccid	=> Null
				, p_event_id    => p_event_id
                              );
             End if;

  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '+acctg creation deprn reserve vs deprn expense');

            create_acctg_entry (  l_ccid            => l_deprn_rsv_ccid
                                , p_amount          => fp_det_balances.deprn_reserve
                                , l_adjust_type     => 'RESERVE'
                                , l_cr_dr_flag      => 'DR'
                                , l_set_of_books_id => l_sob_id
                                , fp_det_balances   => fp_det_balances
				, l_adjust_offset_type	=> 'EXPENSE'
				, l_report_ccid	=> Null
				, p_event_id    => p_event_id
                              );



          /* bug 2439006  additional dep_resrver account created old category depreciation expense negation
            entry to the new category*/
              IF Diff_price_index_flag Then

                         create_acctg_entry (  l_ccid               =>  l_deprn_exp_ccid
                                , p_amount          => fp_det_balances.deprn_reserve
                                , l_adjust_type     => 'EXPENSE'
                                , l_cr_dr_flag      => 'CR'
                                , l_set_of_books_id => l_sob_id
                                , fp_det_balances   => fp_det_balances
				, l_adjust_offset_type	=> 'RESERVE'
				, l_report_ccid	=> Null
				, p_event_id    => p_event_id
                              );

  	    		 igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     			p_full_path => l_path_name,
		     			p_string => '+acctg creation depreciation expenese for old ');

                          create_acctg_entry (  l_ccid               =>  l_deprn_exp_ccid
                                , p_amount          => fp_det_balances.deprn_reserve
                                , l_adjust_type     => 'EXPENSE'
                                , l_cr_dr_flag      => 'DR'
                                , l_set_of_books_id => l_sob_id
                                , fp_det_balances   => fp_det_balances
				, l_adjust_offset_type	=> 'RESERVE'
				, l_report_ccid	=> Null
				, p_event_id    => p_event_id
                              );

                        l_deprn_reserve_amount:=  fp_det_balances.deprn_reserve;
                  End if;

          /* bug 2439006  YTD not required now beacuse of above accounting entry*/

/*
                 debug(0,'+acctg creation depreciation expenese for YTD');
                           create_acctg_entry (  l_ccid               =>  l_deprn_exp_ccid
                                , p_amount          => fp_det_balances.deprn_ytd
                                , l_adjust_type     => 'EXPENSE'
                                , l_cr_dr_flag      => 'DR'
                                , l_set_of_books_id => l_sob_id
                                , fp_det_balances   => fp_det_balances
                              );*/


    /*         debug(0,'+acctg creation backlog reserve vs deprn reserve');

            create_acctg_entry (  l_ccid               => l_blog_rsv_ccid
                                , p_amount          => fp_det_balances.reval_reserve_backlog
                                , l_adjust_type     => 'BL RESERVE'
                                , l_cr_dr_flag      => 'CR'
                                , l_set_of_books_id => l_sob_id
                                , fp_det_balances   => fp_det_balances
                              );

                        create_acctg_entry (  l_ccid            => l_deprn_rsv_ccid
                                , p_amount          => fp_det_balances.reval_reserve_backlog
                                , l_adjust_type     => 'RESERVE'
                                , l_cr_dr_flag      => 'DR'
                                , l_set_of_books_id => l_sob_id
                                , fp_det_balances   => fp_det_balances
                              );*/
           --        end if;

           elsif  fp_adjustement_type = 'NEW' THEN

               IF Diff_price_index_flag Then

                      /* bug 2439006  YTD not required now beacuse of above accounting entry*/
    /*                 debug(0,'+acctg creation depreciation expenese for YTD');
                           create_acctg_entry (  l_ccid               =>  l_deprn_exp_ccid
                                , p_amount          => fp_det_balances.deprn_ytd
                                , l_adjust_type     => 'EXPENSE'
                                , l_cr_dr_flag      => 'CR'
                                , l_set_of_books_id => l_sob_id
                                , fp_det_balances   => fp_det_balances
                              );*/

          /* bug 2439006  additional dep_resrver account created old category depreciation expense negation
            entry to the new category*/

  	    	       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     			p_full_path => l_path_name,
		     			p_string => '+acctg creation depreciation expenese for new ');

                       create_acctg_entry (  l_ccid               =>  l_deprn_exp_ccid
                                , p_amount          =>  l_deprn_reserve_amount
                                , l_adjust_type     => 'EXPENSE'
                                , l_cr_dr_flag      => 'CR'
                                , l_set_of_books_id => l_sob_id
                                , fp_det_balances   => fp_det_balances
				, l_adjust_offset_type	=> 'RESERVE'
				, l_report_ccid	=> Null
				, p_event_id    => p_event_id
                              );


                ELSE

  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '+acctg creation cost vs reval reserve');
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '+acctg creation cost vs reval reserve');

          /*create_acctg_entry (  l_dr_ccid        => l_asset_cost_ccid
                             , l_cr_ccid         => l_revl_rsv_ccid
                             , p_amount          => fp_det_balances.reval_reserve_cost
                             , l_dr_adjust_type  => 'COST'
                             , l_cr_adjust_type  => 'REVAL RESERVE'
                             , l_set_of_books_id => l_sob_id
                             , fp_det_balances   => fp_det_balances
                             );*/

             create_acctg_entry (  l_ccid            => l_asset_cost_ccid
                                 , p_amount          => fp_det_balances.reval_reserve_cost
                                 , l_adjust_type     => 'COST'
                                 , l_cr_dr_flag      => 'DR'
                                 , l_set_of_books_id => l_sob_id
                                , fp_det_balances   => fp_det_balances
				, l_adjust_offset_type	=> 'REVAL RESERVE'
				, l_report_ccid	=> l_revl_rsv_ccid
				, p_event_id    => p_event_id
                                );
            create_acctg_entry (  l_ccid             => l_revl_rsv_ccid
                                , p_amount          => fp_det_balances.reval_reserve_cost
                                , l_adjust_type     => 'REVAL RESERVE'
                                , l_cr_dr_flag      => 'CR'
                                , l_set_of_books_id => l_sob_id
                                , fp_det_balances   => fp_det_balances
				, l_adjust_offset_type	=> 'COST'
				, l_report_ccid	=> Null
				, p_event_id    => p_event_id
                              );

  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '+acctg creation reval reserve vs backlog reserve');

         /*create_acctg_entry (  l_dr_ccid   =>    l_revl_rsv_ccid
                             , l_cr_ccid   =>    l_blog_rsv_ccid
                             , p_amount    =>    fp_det_balances.reval_reserve_backlog
                             , l_dr_adjust_type  => 'REVAL RESERVE'
                             , l_cr_adjust_type  => 'BL RESERVE'
                             , l_set_of_books_id => l_sob_id
                             , fp_det_balances   => fp_det_balances
                             );*/
          create_acctg_entry (  l_ccid             => l_revl_rsv_ccid
                                , p_amount          => fp_det_balances.reval_reserve_backlog
                                , l_adjust_type     => 'REVAL RESERVE'
                                , l_cr_dr_flag      => 'DR'
                                , l_set_of_books_id => l_sob_id
                                , fp_det_balances   => fp_det_balances
				, l_adjust_offset_type	=> 'BL RESERVE'
				, l_report_ccid	=> Null
				, p_event_id    => p_event_id
                              );

         create_acctg_entry (  l_ccid               => l_blog_rsv_ccid
                                , p_amount          => fp_det_balances.reval_reserve_backlog
                                , l_adjust_type     => 'BL RESERVE'
                                , l_cr_dr_flag      => 'CR'
                                , l_set_of_books_id => l_sob_id
                                , fp_det_balances   => fp_det_balances
				, l_adjust_offset_type	=> 'REVAL RESERVE'
				, l_report_ccid	=> l_revl_rsv_ccid
				, p_event_id    => p_event_id
                              );

  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '+acctg creation reval reserve vs gen fund');

         /*create_acctg_entry (  l_dr_ccid   =>    l_revl_rsv_ccid
                             , l_cr_ccid   =>    l_gen_fund_ccid
                             , p_amount    =>    fp_det_balances.reval_reserve_gen_fund
                             , l_dr_adjust_type  => 'REVAL RESERVE'
                             , l_cr_adjust_type  => 'GENERAL FUND'
                             , l_set_of_books_id => l_sob_id
                             , fp_det_balances   => fp_det_balances
                             );*/
          create_acctg_entry (  l_ccid             => l_revl_rsv_ccid
                                , p_amount          => fp_det_balances.reval_reserve_gen_fund
                                , l_adjust_type     => 'REVAL RESERVE'
                                , l_cr_dr_flag      => 'DR'
                                , l_set_of_books_id => l_sob_id
                                , fp_det_balances   => fp_det_balances
				, l_adjust_offset_type	=> 'GENERAL FUND'
				, l_report_ccid	=> Null
				, p_event_id    => p_event_id
                                   );

         create_acctg_entry (  l_ccid               => l_gen_fund_ccid
                                , p_amount          => fp_det_balances.reval_reserve_gen_fund
                                , l_adjust_type     => 'GENERAL FUND'
                                , l_cr_dr_flag      => 'CR'
                                , l_set_of_books_id => l_sob_id
                                , fp_det_balances   => fp_det_balances
				, l_adjust_offset_type	=> 'REVAL RESERVE'
				, l_report_ccid	=> l_revl_rsv_ccid
				, p_event_id    => p_event_id
                              );

  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '+acctg creation op account vs cost');

         /*create_acctg_entry (  l_dr_ccid   =>    l_op_exp_ccid
                             , l_cr_ccid   =>    l_asset_cost_ccid
                             , p_amount    =>    fp_det_balances.operating_acct_cost
                             , l_dr_adjust_type  => 'OP ACCOUNT'
                             , l_cr_adjust_type  => 'COST'
                             , l_set_of_books_id => l_sob_id
                             , fp_det_balances   => fp_det_balances
                             );*/

         /*  create_acctg_entry (  l_ccid               => l_op_exp_ccid
                                , p_amount          => fp_det_balances.operating_acct_cost
                                , l_adjust_type     => 'OP EXPENSE'
                                , l_cr_dr_flag      => 'CR'
                                , l_set_of_books_id => l_sob_id
                                , fp_det_balances   => fp_det_balances
                              );*/

          create_acctg_entry (  l_ccid            => l_asset_cost_ccid
                                 , p_amount          => fp_det_balances.operating_acct_cost
                                 , l_adjust_type     => 'COST'
                                 , l_cr_dr_flag      => 'DR'
                                 , l_set_of_books_id => l_sob_id
                                , fp_det_balances   => fp_det_balances
				, l_adjust_offset_type	=> 'OP EXPENSE'
				, l_report_ccid	=> l_op_exp_ccid,
				p_event_id    => p_event_id
                                );

  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '+acctg creation backlog vs op account');

         /*create_acctg_entry (  l_dr_ccid   =>    l_blog_rsv_ccid
                             , l_cr_ccid   =>    l_op_exp_ccid
                             , p_amount    =>    fp_det_balances.operating_acct_backlog
                             , l_dr_adjust_type  => 'BL RESERVE'
                             , l_cr_adjust_type  => 'OP EXPENSE'
                             , l_set_of_books_id => l_sob_id
                             , fp_det_balances   => fp_det_balances
                             );*/
          create_acctg_entry (  l_ccid               => l_blog_rsv_ccid
                                , p_amount          => fp_det_balances.operating_acct_backlog
                                , l_adjust_type     => 'BL RESERVE'
                                , l_cr_dr_flag      => 'CR'
                                , l_set_of_books_id => l_sob_id
                                , fp_det_balances   => fp_det_balances
				, l_adjust_offset_type	=> 'OP EXPENSE'
				, l_report_ccid	=> l_op_exp_ccid
				, p_event_id    => p_event_id
                              );


        /*   create_acctg_entry (  l_ccid               => l_op_exp_ccid
                                , p_amount          => fp_det_balances.operating_acct_backlog
                                , l_adjust_type     => 'OP EXPENSE'
                                , l_cr_dr_flag      => 'DR'
                                , l_set_of_books_id => l_sob_id
                                , fp_det_balances   => fp_det_balances
                              );*/

    -- removing these entries as per bug 2483321
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '+acctg creation deprn reserve vs deprn expense');

            create_acctg_entry (  l_ccid            => l_deprn_rsv_ccid
                                , p_amount          => fp_det_balances.deprn_reserve
                                , l_adjust_type     => 'RESERVE'
                                , l_cr_dr_flag      => 'CR'
                                , l_set_of_books_id => l_sob_id
                                , fp_det_balances   => fp_det_balances
				, l_adjust_offset_type	=> 'EXPENSE'
				, l_report_ccid	=> Null
				, p_event_id    => p_event_id
                              );
          /* create_acctg_entry (  l_ccid               =>  l_deprn_exp_ccid
                                , p_amount          => fp_det_balances.deprn_reserve
                                , l_adjust_type     => 'EXPENSE'
                                , l_cr_dr_flag      => 'DR'
                                , l_set_of_books_id => l_sob_id
                                , fp_det_balances   => fp_det_balances
                              );*/

        /*    debug(0,'+acctg creation depreciation expenese for YTD');
                           create_acctg_entry (  l_ccid               =>  l_deprn_exp_ccid
                                , p_amount          => fp_det_balances.deprn_ytd
                                , l_adjust_type     => 'EXPENSE'
                                , l_cr_dr_flag      => 'CR'
                                , l_set_of_books_id => l_sob_id
                                , fp_det_balances   => fp_det_balances
                              );*/


    /*     debug(0,'+acctg creation backlog reserve vs deprn reserve');

            create_acctg_entry (  l_ccid               => l_blog_rsv_ccid
                                , p_amount          => fp_det_balances.reval_reserve_backlog
                                , l_adjust_type     => 'BL RESERVE'
                                , l_cr_dr_flag      => 'CR'
                                , l_set_of_books_id => l_sob_id
                                , fp_det_balances   => fp_det_balances
                              );

                        create_acctg_entry (  l_ccid            => l_deprn_rsv_ccid
                                , p_amount          => fp_det_balances.reval_reserve_backlog
                                , l_adjust_type     => 'RESERVE'
                                , l_cr_dr_flag      => 'DR'
                                , l_set_of_books_id => l_sob_id
                                , fp_det_balances   => fp_det_balances
                              ); */
                     end if;

           end if;
          end;

  	 igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'end acctg creation');
       return true;
    end;

-- ======================================================================
-- FUNCTION Do_No_Index_Reval
-- fix for bug 3356588 - processing an asset when the new category that it
-- has been reclassified to has indexed revaluation switched off
-- Code does:
-- 1. Create a new transaction header line for the asset for the new cat
-- 2. Reverse the accounting entries for the existing dist ids.
-- 3. Does not  create accounting entries for the new dists.
-- 4. The det balances for the existing dists are brought forward only
--    with YTD values
-- 5. The det balances for the new dists are all 0 with cumulative reval
--    factor of 1
-- 6. The asset balances for the asset are all 0 with cumulative reval
-- factor of 1
-- ======================================================================
FUNCTION Do_No_Index_Reval(p_event_id in number) RETURN BOOLEAN
IS

	/* Cursor to select all distributions for an asset that are active and the distribution
	impacted by the reclass */

	CURSOR 	c_all_dist IS
	SELECT	distribution_id,
		transaction_header_id_in,
		units_assigned
	FROM 	fa_distribution_history
	WHERE	asset_id=l_asset_hdr_rec.asset_id
	AND	book_type_code=l_asset_hdr_rec.book_type_code
	AND	transaction_header_id_out=l_trans_rec.transaction_header_id;

	/* Cursor to select  the distribution(s)  undergoing the reclasss */

	CURSOR 	c_old_dist(c_dist_id IN FA_DISTRIBUTION_HISTORY.distribution_id%TYPE) IS
	SELECT	distribution_id
	FROM 	fa_distribution_history
	WHERE 	asset_id=l_asset_hdr_rec.asset_id
	AND    book_type_code=l_asset_hdr_rec.book_type_code
	AND    transaction_header_id_out=l_trans_rec.transaction_header_id
	AND    distribution_id=c_dist_id;

   	/* Cursor to select  the  new distribution(s)  undergoing the reclasss */

	CURSOR 	c_new_dist(c_dist_id IN FA_DISTRIBUTION_HISTORY.distribution_id%TYPE) IS
	SELECT	distribution_id
	FROM 	fa_distribution_history
	WHERE 	asset_id=l_asset_hdr_rec.asset_id
	AND    book_type_code=l_asset_hdr_rec.book_type_code
	AND    transaction_header_id_in=l_trans_rec.transaction_header_id
	AND    distribution_id=c_dist_id;

	/* Cursor to select the details of impacted distribution in this reclass*/

	CURSOR 	c_impacted_dist(c_imp_dist_id FA_DISTRIBUTION_HISTORY.distribution_id%TYPE) IS
	SELECT 	a.distribution_id,
			a.units_assigned
	FROM 	fa_distribution_history a, fa_distribution_history b
	WHERE	a.asset_id=l_asset_hdr_rec.asset_id
	AND    a.book_type_code=l_asset_hdr_rec.book_type_code
        AND     a.asset_id = b.asset_id
        AND     a.book_type_code = b.book_type_code
        AND     a.transaction_header_id_in=l_trans_rec.transaction_header_id
        AND     b.transaction_header_id_out = l_trans_rec.transaction_header_id
        AND 	nvl(a.location_id,-1) = nvl(b.location_id,-1)
        AND     a.units_assigned = b.units_assigned
        AND    b.distribution_id=c_imp_dist_id;

        CURSOR c_impacted_dist_new(c_imp_dist_id FA_DISTRIBUTION_HISTORY.distribution_id%TYPE ,
                                c_imp_dist_id_new FA_DISTRIBUTION_HISTORY.distribution_id%TYPE) IS
	SELECT 	a.distribution_id,
		a.units_assigned
	FROM 	fa_distribution_history a, fa_distribution_history b
	WHERE	a.asset_id=l_asset_hdr_rec.asset_id
	AND     a.book_type_code=l_asset_hdr_rec.book_type_code
        AND     a.asset_id = b.asset_id
        AND     a.book_type_code = b.book_type_code
        AND     a.transaction_header_id_in=l_trans_rec.transaction_header_id
        AND     b.transaction_header_id_out = l_trans_rec.transaction_header_id
        AND 	nvl(a.location_id,-1) = nvl(b.location_id,-1)
        AND    a.units_assigned = b.units_assigned
        AND    b.distribution_id=c_imp_dist_id
        AND  	a.distribution_id > c_imp_dist_id_new;

	/* Cursor to select adjustment_id or the previous transaction */

	CURSOR 	c_prev_data IS
	SELECT	a.rowid,a.adjustment_id
	FROM 	igi_iac_transaction_headers a
	WHERE	a.adjustment_id_out IS NULL
        AND     a.asset_id = l_asset_hdr_rec.asset_id;


	/* Cursor  to find the amounts that need to be transferres to the new  dist
	 created by reclass */

	CURSOR 	c_amounts(c_period_counter IN IGI_IAC_ASSET_BALANCES.period_counter%TYPE) IS
	SELECT	*
	FROM	igi_iac_asset_balances
	WHERE 	asset_id=l_asset_hdr_rec.asset_id
        AND     book_type_code=l_asset_hdr_rec.book_type_code
        AND     period_counter=(SELECT max(period_counter)
			        FROM   igi_iac_asset_balances
			        WHERE  asset_id=l_asset_hdr_rec.asset_id
               			AND     book_type_code=l_asset_hdr_rec.book_type_code);

	/* Cursor to find the total number of units for the asset itself ( active) */

	CURSOR 	c_units IS
	SELECT 	sum(units_assigned)
	FROM	fa_distribution_history
        WHERE   asset_id=l_asset_hdr_rec.asset_id
        AND     book_type_code=l_asset_hdr_rec.book_type_code
        AND     transaction_header_id_out IS NULL;

	/* Cursor to find the total no of units involved in the transfer of old dist to new */

	CURSOR 	c_dist_units IS
	SELECT	sum(units_assigned)
	FROM    fa_distribution_history
        WHERE   asset_id=l_asset_hdr_rec.asset_id
        AND     book_type_code=l_asset_hdr_rec.book_type_code
        AND     transaction_header_id_in=l_trans_rec.transaction_header_id;

	/* Cursor for ytd deprn */

	CURSOR 	c_ytd_deprn(c_start_counter IGI_IAC_ASSET_BALANCES.period_counter%TYPE
			           ,c_current_counter IGI_IAC_ASSET_BALANCES.period_counter%TYPE) IS
	SELECT 	nvl(sum(deprn_amount),0) deprn_amount
	FROM 	igi_iac_asset_balances
	WHERE 	book_type_code=l_asset_hdr_rec.book_type_code
	AND	asset_id=l_asset_hdr_rec.asset_id
	AND	period_counter between c_start_counter and c_current_counter;

	/* Cursor for operating account ytd */

	CURSOR 	c_op_acct_ytd(c_start_counter IGI_IAC_ASSET_BALANCES.period_counter%TYPE
			             ,c_current_counter IGI_IAC_ASSET_BALANCES.period_counter%TYPE) IS
	SELECT 	nvl(sum(operating_acct),0) operating_acct
	FROM 	igi_iac_asset_balances
	WHERE 	book_type_code=l_asset_hdr_rec.book_type_code
	AND	asset_id=l_asset_hdr_rec.asset_id
	AND	period_counter BETWEEN c_start_counter AND c_current_counter;

	/* Cursor to select the start period number for a given fiscal year */

	 CURSOR c_start_period_counter(c_fiscal_year FA_DEPRN_PERIODS.fiscal_year%TYPE) IS
	 SELECT (number_per_fiscal_year*c_fiscal_year)+1
	 FROM	fa_calendar_types
	 WHERE   calendar_type=(SELECT deprn_calendar
                                FROM fa_book_controls
	 		        WHERE book_type_code=l_asset_hdr_rec.book_type_code);

	 /* Cursor to select the adjustment_id from the sequence for a new record */

	 CURSOR	c_adj_id IS
	 SELECT igi_iac_transaction_headers_s.nextval
	 FROM	dual;

	 /*  To select the asset's deprn_expense from fa_books */

	CURSOR 	c_deprn_expense(c_period_counter FA_DEPRN_SUMMARY.period_counter%TYPE) IS
	SELECT 	deprn_amount
	FROM 	fa_deprn_summary
	WHERE 	book_type_code = l_asset_hdr_rec.book_type_code
	AND   	period_counter = c_period_counter
	AND   	asset_id=l_asset_hdr_rec.asset_id;

	 /* Cursor to select the reval reserve backlog,op acct backlog and gen fund per for the dist */

	 CURSOR	c_backlog_data(c_current_period_Counter fa_deprn_periods.period_counter%TYPE) IS
	 SELECT sum(nvl(iadb.reval_reserve_backlog,0)) reval_reserve_backlog,
	 		sum(nvl(iadb.operating_acct_backlog,0)) operating_acct_backlog,
	 		sum(nvl(iadb.general_fund_per,0)) general_fund_per
	 FROM	igi_iac_det_balances iadb,fa_distribution_history fdh
	 WHERE 	iadb.book_type_code = l_asset_hdr_rec.book_type_code
	 AND   	iadb.period_counter = c_current_period_counter
	 AND   	iadb.asset_id=l_asset_hdr_rec.asset_id
	 AND	iadb.asset_id=fdh.asset_id
	 AND	iadb.book_type_code =fdh.book_type_code
	 AND 	fdh.transaction_header_id_out=l_trans_rec.transaction_header_id
	 AND	fdh.distribution_id=iadb.distribution_id;

	/*  To find the asset number */

	CURSOR	c_asset_num IS
	SELECT 	asset_number
	FROM	fa_additions
	WHERE	asset_id=l_asset_hdr_rec.asset_id;

    /* get the closing det balances record */
    CURSOR  c_closing_det_balances( p_old_dist  IGI_IAC_ADJUSTMENTS.distribution_id%TYPE,
                                    p_adjustment_id IGI_IAC_ADJUSTMENTS.adjustment_id%TYPE)IS
    SELECT *
    FROM igi_iac_det_balances
    WHERE asset_id=l_asset_hdr_rec.asset_id
    AND book_type_code = l_asset_hdr_rec.book_type_code
    AND distribution_id = p_old_dist
    AND adjustment_id = p_adjustment_id;

    /* Cursor to get incactive distributuiions to be carried forward */
    CURSOR   get_all_prev_inactive_dist (C_prev_data_adjustment_id NUMBER)
    IS
    SELECT *
    FROM igi_iac_det_balances
    WHERE asset_id=l_asset_hdr_rec.asset_id
    AND book_type_code = l_asset_hdr_rec.book_type_code
    AND adjustment_id = C_prev_data_adjustment_id;
--    AND nvl(active_flag,'Y') = 'N';


   /* Enhancemnet 2480915 Cursor to fetch the igi_fa_deprn deatils */
    CURSOR c_get_deprn_dist (c_book_type_code VARCHAR2,
                             c_asset_id NUMBER,
                             c_distribution_id NUMBER,
                             c_adjustment_id NUMBER)
    IS
    SELECT *
    FROM IGI_IAC_FA_DEPRN
    WHERE book_type_code = c_book_type_code
    AND asset_id = c_asset_id
    AND Distribution_id = c_distribution_id
    AND adjustment_id = c_adjustment_id;


--	l_asset_revalued		    c_asset_revalued%rowtype;
	l_impacted_dist 		    c_impacted_dist%ROWTYPE;
	l_amounts 			        c_amounts%ROWTYPE;
	l_backlog_data			    c_backlog_data%ROWTYPE;
        l_get_deprn_dist             c_get_deprn_dist%ROWTYPE;
	l_old_dist			        c_old_dist%ROWTYPE;
	l_dist_units			    FA_DISTRIBUTION_HISTORY.units_assigned%TYPE;
	l_prd_rec 			        IGI_IAC_TYPES.prd_rec;
	l_prd_rec_prior			    IGI_IAC_TYPES.prd_rec;

	l_prev_data 			    c_prev_data%ROWTYPE;
	l_adj_id 			        IGI_IAC_ADJUSTMENTS.adjustment_id%TYPE;
	l_current_period_counter 	FA_DEPRN_PERIODS.period_counter%TYPE;
	l_start_period_counter		FA_DEPRN_PERIODS.period_counter%TYPE;

	l_asset_num			        FA_ADDITIONS.asset_number%TYPE;
	l_units				        FA_DISTRIBUTION_HISTORY.units_assigned%TYPE;
	l_reval_reserve 		    IGI_IAC_DET_BALANCES.reval_reserve_cost%TYPE;
	l_general_fund 			    IGI_IAC_DET_BALANCES.general_fund_acc%TYPE;
	l_Backlog_deprn_reserve 	IGI_IAC_DET_BALANCES.deprn_reserve_backlog%TYPE;
	l_deprn_reserve			    IGI_IAC_DET_BALANCES.deprn_reserve%TYPE;
	l_adjusted_cost			    IGI_IAC_DET_BALANCES.adjustment_cost%TYPE;
	l_net_book_value 		    IGI_IAC_DET_BALANCES.net_book_value%TYPE;
	l_deprn_per 			    IGI_IAC_DET_BALANCES.deprn_period%TYPE;
	l_ytd_deprn 			    IGI_IAC_DET_BALANCES.deprn_ytd%TYPE;
	l_op_acct 			        IGI_IAC_DET_BALANCES.operating_acct_ytd%TYPE;
	l_op_acct_ytd			    IGI_IAC_DET_BALANCES.operating_acct_ytd%TYPE;
	l_general_fund_per		    IGI_IAC_DET_BALANCES.general_fund_per%TYPE;
	l_reval_reserve_backlog		IGI_IAC_DET_BALANCES.reval_reserve_backlog%TYPE;
	l_operating_acct_backlog	IGI_IAC_DET_BALANCES.operating_acct_backlog%TYPE;
	l_reval_ccid 			    IGI_IAC_ADJUSTMENTS.code_combination_id%TYPE;
	l_gen_fund_ccid 		    IGI_IAC_ADJUSTMENTS.code_combination_id%TYPE;
	l_backlog_ccid 			    IGI_IAC_ADJUSTMENTS.code_combination_id%TYPE;
	l_deprn_ccid 			    IGI_IAC_ADJUSTMENTS.code_combination_id%TYPE;
	l_cost_ccid 			    IGI_IAC_ADJUSTMENTS.code_combination_id%TYPE;
	l_prior_period_counter		IGI_IAC_TRANSACTION_HEADERS.period_counter%TYPE;
	l_historic_deprn_expense 	FA_DEPRN_SUMMARY.deprn_amount%TYPE;
	l_Expense_diff			    IGI_IAC_DET_BALANCES.deprn_period%TYPE;
	l_expense_ccid			    IGI_IAC_ADJUSTMENTS.code_combination_id%TYPE;
        l_closing_det_balances      IGI_IAC_DET_BALANCES%ROWTYPE;
        l_adjustment_id             IGI_IAC_ADJUSTMENTS.adjustment_id%TYPE;
        l_get_all_prev_dist         get_all_prev_inactive_dist%ROWTYPE;

        l_rowid                     ROWID;
	l_return_value			    BOOLEAN;
	l_Prorate_factor		    NUMBER;
	l_deprn_expense			    NUMBER;
	x 				            VARCHAR2(100);
	prior_period 			    VARCHAR2(100);
	l_mesg				        VARCHAR2(500);
        l_adjustment_id_out         NUMBER;
        l_prev_adjustment_id        NUMBER;
        l_transaction_type_code     VARCHAR2(50);
        l_transaction_id            NUMBER ;
        l_mass_reference_id         NUMBER ;
        l_adjustment_status         VARCHAR2(50);
        l_path_name VARCHAR2(150);

    BEGIN
        l_transaction_type_code     := NULL;
        l_adjustment_status         := NULL ;
        l_path_name := g_path||'do_no_index_reval';

      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '     + Index revaluation OFF - In Do_No_Index_Reval');

	/* Store the previous transaction adjustment id */

    -- get the latest transaction
    IF NOT igi_iac_common_utils.Get_Latest_Transaction (
                       		X_book_type_code    => l_asset_hdr_rec.book_type_code,
                       		X_asset_id          => l_asset_hdr_rec.asset_id,
                       		X_Transaction_Type_Code	=> l_transaction_type_code,
                       		X_Transaction_Id	=> l_transaction_id,
                       		X_Mass_Reference_ID	=> l_mass_reference_id,
                       		X_Adjustment_Id		=> l_adjustment_id_out,
                       		X_Prev_Adjustment_Id => l_prev_adjustment_id,
                       		X_Adjustment_Status	=> l_adjustment_status) THEN
  	  igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     p_full_path => l_path_name,
		     p_string => '*** Error in fetching the latest transaction');
        RETURN FALSE;
    END IF;

    -- Get the current open period
	IF igi_iac_common_utils.get_open_period_info(l_asset_hdr_rec.book_type_code,l_prd_rec) THEN
		l_current_period_counter:=l_prd_rec.period_counter;
  	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '     + Current OPen Period counter' ||l_prd_rec.period_counter );
	END IF;

  	-- Fetch the adjustment id from the sequence
    OPEN c_adj_id;
    FETCH c_adj_id INTO l_adj_id;
    CLOSE c_adj_id;

  	-- Insert into transaction headers
	insert_data_trans_hdr(l_adj_id,
		              l_trans_rec.transaction_header_id,
		              NULL,
		              l_trans_rec.transaction_type_code,
		              l_trans_rec.transaction_date_entered,
		              l_trans_rec.mass_reference_id,
		              l_asset_hdr_rec.book_type_code,
		              l_asset_hdr_rec.Asset_id,
		              NULL,
		              'COMPLETE',
                              l_asset_cat_rec_old.category_id,
	                      -- l_asset_cat_rec_new.category_id,
		              l_current_period_counter,
		              p_event_id
		              );

        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '     + After Insert into trans header' );

    -- Need to close the previous transaction to pick the latest catgeory --
    IGI_IAC_TRANS_HEADERS_PKG.update_row (
    		x_prev_adjustment_id          =>l_adjustment_id_out,
    		x_adjustment_id		          =>l_adj_id,
    		x_mode                        =>'R'
				                          );

    OPEN c_units;
    FETCH c_units INTO l_units;
    CLOSE c_units;

    OPEN c_dist_units;
    FETCH c_dist_units INTO l_dist_units;
    CLOSE c_dist_units;

    l_impacted_dist := NULL;
	FOR l_all_dist IN c_all_dist
	LOOP
		OPEN c_start_period_counter(l_prd_rec.fiscal_year);
		FETCH c_start_period_counter INTO l_start_period_counter;
	        CLOSE c_start_period_counter;

		OPEN c_ytd_deprn(l_start_period_counter,l_prd_rec.period_counter);
		FETCH c_ytd_deprn INTO l_ytd_deprn;
		CLOSE c_ytd_deprn;

		OPEN c_op_acct_ytd(l_start_period_counter,l_prd_rec.period_counter);
		FETCH c_op_acct_ytd INTO l_op_acct_ytd;
		CLOSE c_op_acct_ytd;

		OPEN c_old_dist(l_all_dist.distribution_id);
		FETCH c_old_dist INTO l_old_dist;
		CLOSE c_old_dist;

        IF  (l_impacted_dist.distribution_id  IS NULL ) THEN
    		OPEN c_impacted_dist(l_all_dist.distribution_id);
	    	FETCH c_impacted_dist INTO l_impacted_dist;
  	      		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		 p_full_path => l_path_name,
		     		 p_string => '         + impacted distribution id ' || l_all_dist.distribution_id);
  	      		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		    		 p_full_path => l_path_name,
		     		 p_string => '         + new impacted distribution id ' || l_impacted_dist.distribution_id);

	    	CLOSE c_impacted_dist;
        ELSE
                OPEN c_impacted_dist_new(l_all_dist.distribution_id,l_impacted_dist.distribution_id);
	        FETCH c_impacted_dist_new INTO l_impacted_dist;
  	      		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		 p_full_path => l_path_name,
		     		 p_string => '         + impacted distribution id ' || l_all_dist.distribution_id);
  	      		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		 p_full_path => l_path_name,
		     		 p_string => '         + new impacted distribution id ' || l_impacted_dist.distribution_id);

	    	CLOSE c_impacted_dist_new;
        END IF;

	OPEN c_old_dist(l_all_dist.distribution_id);
	FETCH c_old_dist INTO l_old_dist;
        IF c_old_dist%NOTFOUND THEN
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => ' No old distribution for asset found ' || l_old_dist.distribution_id);
            CLOSE c_old_dist;
            RETURN FALSE;
        END IF;
        CLOSE c_old_dist;
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '  + no old distribution for asset ' || l_old_dist.distribution_id);

        /* get the closing det balances record form iac det balances */
        l_adjustment_id :=l_prev_adjustment_id;

        OPEN c_closing_det_balances(l_old_dist.distribution_id,l_prev_adjustment_id);
        FETCH c_closing_det_balances INTO l_closing_det_balances;
        IF c_closing_det_balances%NOTFOUND THEN
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '  +  old distruibution id ' || l_old_dist.distribution_id);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '  +  adjustement id  '||l_prev_adjustment_id);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => ' Could not  find the IAC  det balances record ');
            CLOSE c_closing_det_balances;
            RETURN FALSE;
        END IF;

  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '  +  old distruibution id ' || l_old_dist.distribution_id);
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '  +  adjustement id  '||l_prev_adjustment_id);

        CLOSE c_closing_det_balances;


        l_closing_det_balances.adjustment_id    := l_adj_id;
        l_closing_det_balances.period_counter := l_current_period_counter;
        l_deprn_reserve_amount:=  0;

        UPDATE igi_iac_transaction_headers
        SET category_id = l_asset_cat_rec_old.category_id
        WHERE adjustment_id = l_adj_id;

        -- reverse the accounting entries for the existing dist ids
        IF create_iac_acctg ( l_closing_det_balances,TRUE,'OLD',p_event_id => p_event_id) THEN
  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '+Accounting entries created for old');
        ELSE
  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'Failed to create Accounting entries');
            	RETURN FALSE;
        END IF;

        -- bring the existing dists with their YTD values
        insert_data_det(p_adjustment_id                 =>l_adj_id,
        		      p_asset_id		=>l_asset_hdr_rec.asset_id,
    			      p_distribution_id	        =>l_closing_det_balances.distribution_id,
    			      p_period_counter	        =>l_closing_det_balances.period_counter,
    			      p_book_type_code          =>l_asset_hdr_rec.book_type_code,
    			      p_adjusted_cost	        =>0,
    			      p_net_book_value      	=>0,
    			      p_reval_reserve	        =>0,
    			      p_reval_reserve_gen_fund	=>0,
    			      p_reval_reserve_backlog	=>0,
                              p_reval_reserve_net       =>0,
    			      p_op_acct			=>0,
                              p_op_acct_net             =>0,
    			      p_deprn_reserve		=>0,
    			      p_deprn_reserve_backlog 	=>0,
    			      p_deprn_ytd		=>l_closing_det_balances.DEPRN_YTD,
    			      p_deprn_period	    	=>0,
    			      p_gen_fund_acc		=>0,
    			      p_gen_fund_per		=>0,
    			      p_current_reval_factor	=>l_closing_det_balances.current_reval_factor,
    			      p_cumulative_reval_factor =>l_closing_det_balances.cumulative_reval_factor,
    			      p_reval_flag		=> 'N',
    			      p_op_acct_ytd		=>l_closing_det_balances.OPERATING_ACCT_YTD,
    			      p_operating_acct_backlog  =>0,
    			      p_last_reval_date		=>l_closing_det_balances.last_reval_date);

        -- enchancement 2480915 maintiain the ytd values ---
        OPEN  c_get_deprn_dist  (l_asset_hdr_rec.book_type_code,
                                 l_asset_hdr_rec.asset_id,
                                 l_closing_det_balances.distribution_id ,
                                 l_adjustment_id_out );
        FETCH    c_get_deprn_dist INTO l_get_deprn_dist;
        IF c_get_deprn_dist%FOUND THEN
            -- Call to TBH for insert into IGI_IAC_ADJUSTMENTS
    	    IGI_IAC_FA_DEPRN_PKG.insert_row(
    		            	x_rowid                =>l_rowid,
               			x_adjustment_id        =>l_adj_id,
    		            	x_book_type_code       =>l_asset_hdr_rec.book_type_code,
               			x_asset_id             =>l_asset_hdr_rec.asset_id,
     		            	x_distribution_id      =>l_closing_det_balances.distribution_id,
               			x_period_counter       =>l_closing_det_balances.period_counter,
                                x_deprn_period         => 0,
                                x_deprn_ytd             =>l_get_deprn_dist.deprn_ytd,
                                x_deprn_reserve        => 0,
                                x_active_flag          => 'N',
                		x_mode                 =>'R'
            		                             );

        END IF;
        CLOSE c_get_deprn_dist;
        -- enchancement 2480915 maintiain the ytd values ---
        -- before performing the new distribution entries update with new catgeory
        UPDATE igi_iac_transaction_headers
        SET category_id = l_asset_cat_rec_new.category_id
        WHERE adjustment_id = l_adj_id;

        -- create entries in igi_iac_det_balances for the new dist
        insert_data_det(p_adjustment_id  =>l_adj_id,
        		      p_asset_id		        =>l_asset_hdr_rec.asset_id,
    			      p_distribution_id	        =>l_impacted_dist.distribution_id,
    			      p_period_counter	        =>l_current_period_counter,
    			      p_book_type_code          =>l_asset_hdr_rec.book_type_code,
    			      p_adjusted_cost	        =>0,
    			      p_net_book_value      	=>0,
    			      p_reval_reserve	        =>0,
    			      p_reval_reserve_gen_fund	=>0,
    			      p_reval_reserve_backlog	=>0,
                      p_reval_reserve_net	    =>0,
    			      p_op_acct			        =>0,
                      p_op_acct_net			    =>0,
    			      p_deprn_reserve		    =>0,
    			      p_deprn_reserve_backlog 	=>0,
    			      p_deprn_ytd		        =>0,
    			      p_deprn_period	    	=>0,
    			      p_gen_fund_acc		    =>0,
    			      p_gen_fund_per		    =>0,
    			      p_current_reval_factor	=>1,
    			      p_cumulative_reval_factor =>1,
    			      p_reval_flag		        => NULL,
    			      p_op_acct_ytd		        =>0,
    			      p_operating_acct_backlog  =>0,
    			      p_last_reval_date		    =>l_closing_det_balances.last_reval_date);

         -- enchancement 2480915 maintiain the  FA YTD  values ---
         OPEN  c_get_deprn_dist  (l_asset_hdr_rec.book_type_code,
                                  l_asset_hdr_rec.asset_id,
                                  l_old_dist.distribution_id ,
                                  l_adjustment_id_out );
         FETCH    c_get_deprn_dist INTO l_get_deprn_dist;
         IF c_get_deprn_dist%FOUND THEN
            /* Call to TBH for insert into IGI_IAC_ADJUSTMENTS */
    	    IGI_IAC_FA_DEPRN_PKG.insert_row(
    		            	x_rowid           =>l_rowid,
                		x_adjustment_id   =>l_adj_id,
    		            	x_book_type_code  =>l_asset_hdr_rec.book_type_code,
                		x_asset_id        =>l_asset_hdr_rec.asset_id,
     		            	x_distribution_id =>l_impacted_dist.distribution_id,
                		x_period_counter  =>l_current_period_counter,
                                x_deprn_period    => 0,
                                x_deprn_ytd       => 0,
                                x_deprn_reserve   => 0,
                                x_active_flag     => NULL,
                		x_mode            =>'R'
            			                     );

          END IF;
          CLOSE c_get_deprn_dist;
          -- enchancement 2480915 maintiain the ytd values ---
	END LOOP;
	 /* End of loop for all active distributions */

    /* Update the asset balanaces to zero in case new category has no indexed revalutions */

    IF NOT (ALLOW_INDEX_REVAL_FLAG) THEN
            igi_iac_asset_balances_pkg.update_row(
	    			X_asset_id		          => l_asset_hdr_rec.asset_id,
					X_book_type_code	      => l_asset_hdr_rec.book_type_code,
					X_period_counter	      => l_current_period_counter ,
					X_net_book_value	      => 0,
					X_adjusted_cost		      => 0,
					X_operating_acct	      => 0,
					X_reval_reserve		      => 0,
					X_deprn_amount		      => 0,
					X_deprn_reserve		      => 0,
					X_backlog_deprn_reserve   => 0,
					X_general_fund		      => 0,
					X_last_reval_date	      => Null,
					X_current_reval_factor	  => 1,
        			X_cumulative_reval_factor => 1) ;

    END IF;

    /* get the ytd sum of the active distributiions*/
    l_deprn_ytd := 0;
    /* bring forward all the inactive distributions to the current adjustment */
    FOR  l_get_all_prev_dist in get_all_prev_inactive_dist (l_prev_adjustment_id) LOOP
        IF l_get_all_prev_dist.active_flag = 'N' THEN
                      /*create a record with new adjustment id */
            insert_data_det(p_adjustment_id     =>l_adj_id,
    			      p_asset_id		        =>l_asset_hdr_rec.asset_id,
    			      p_distribution_id	        =>l_get_all_prev_dist.distribution_id,
    			      p_period_counter	        =>l_current_period_counter,
    			      p_book_type_code          =>l_get_all_prev_dist.book_type_code,
    			      p_adjusted_cost	        =>l_get_all_prev_dist.adjustment_cost,
    			      p_net_book_value      	=>l_get_all_prev_dist.net_book_value,
    			      p_reval_reserve	        =>l_get_all_prev_dist.reval_reserve_cost,
    			      p_reval_reserve_gen_fund	=>l_get_all_prev_dist.reval_reserve_gen_fund,
    			      p_reval_reserve_backlog	=>l_get_all_prev_dist.reval_reserve_backlog,
    			      p_op_acct			        =>l_get_all_prev_dist.OPERATING_ACCT_COST,
    			      p_deprn_reserve		    =>l_get_all_prev_dist.deprn_reserve,
    			      p_deprn_reserve_backlog 	=>l_get_all_prev_dist.deprn_reserve_backlog,
    			      p_deprn_ytd		        => l_get_all_prev_dist.deprn_ytd,
                      p_reval_reserve_net	    =>l_get_all_prev_dist.reval_reserve_net,
                      p_op_acct_net			    =>l_get_all_prev_dist.OPERATING_ACCT_net,
    			      p_deprn_period	    	=>l_get_all_prev_dist.deprn_period,
    			      p_gen_fund_acc		    =>l_get_all_prev_dist.general_fund_acc,
    			      p_gen_fund_per		    =>l_get_all_prev_dist.general_fund_per,
    			      p_current_reval_factor	=>l_get_all_prev_dist.current_reval_factor,
    			      p_cumulative_reval_factor =>l_get_all_prev_dist.cumulative_reval_factor,
    			      p_reval_flag		        => l_get_all_prev_dist.active_flag,
    			      p_op_acct_ytd		        =>l_get_all_prev_dist.OPERATING_ACCT_YTD,
    			      p_operating_acct_backlog  =>l_get_all_prev_dist.OPERATING_ACCT_BACKLOG,
    			      p_last_reval_date		    =>l_get_all_prev_dist.last_reval_date);

          -- enchancement 2480915 maintiain the ytd values ---
          Open  c_get_deprn_dist  (l_asset_hdr_rec.book_type_code,
                                   l_asset_hdr_rec.asset_id,
                                   l_get_all_prev_dist.distribution_id ,
                                   l_adjustment_id_out );
          Fetch    c_get_deprn_dist into l_get_deprn_dist;
          IF c_get_deprn_dist%FOUND THEN
                           /* Call to TBH for insert into IGI_IAC_ADJUSTMENTS */
    	            IGI_IAC_FA_DEPRN_PKG.insert_row(
    		            	x_rowid                 =>l_rowid,
                			x_adjustment_id         =>l_adj_id,
    		            	x_book_type_code        =>l_asset_hdr_rec.book_type_code,
                			x_asset_id              =>l_asset_hdr_rec.asset_id,
     		            	x_distribution_id       =>l_get_all_prev_dist.distribution_id,
                			x_period_counter        =>l_closing_det_balances.period_counter,
                            x_deprn_period          => l_get_deprn_dist.deprn_period,
                            x_deprn_ytd             =>l_get_deprn_dist.deprn_ytd,
                            x_deprn_reserve         =>l_get_deprn_dist.deprn_reserve,
                            x_active_flag           => 'N',
                			x_mode                  =>'R'
            			);

           END IF;
           Close c_get_deprn_dist;
           -- enchancement 2480915 maintiain the ytd values ---
       ELSE
           l_deprn_ytd := l_deprn_ytd + l_get_all_prev_dist.deprn_ytd;
       END IF;

    END LOOP; -- inactive distributions

    RETURN(TRUE);


EXCEPTION
  WHEN OTHERS THEN
    igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
    l_mesg:=SQLERRM;
    FA_SRVR_MSG.Add_Message(
	                Calling_FN 	=> l_calling_function ,
        	        Name 		=> 'IGI_IAC_EXCEPTION',
        	        TOKEN1		=> 'PACKAGE',
        	        VALUE1		=> 'Reclass-Do_No_Index_Reval',
        	        TOKEN2		=> 'ERROR_MESSAGE',
        	        VALUE2		=> l_mesg,
                    APPLICATION => 'IGI');

    RETURN(FALSE);

END; --do_no_index_reval


-- ======================================================================
-- SAME PRICE INDEX RECLASS
-- function do all that needed for if both catgeories old and new has same
-- price index
-- ======================================================================
FUNCTION do_same_price_index(p_event_id in number)
Return boolean is

	/* Cursor to select all distributions for an asset that are active and the distribution
	impacted by the reclass */

	CURSOR 	c_all_dist IS
		SELECT	distribution_id,
			    transaction_header_id_in,
			    units_assigned
		FROM 	fa_distribution_history
		WHERE	asset_id=l_asset_hdr_rec.asset_id
		AND	book_type_code=l_asset_hdr_rec.book_type_code
		AND	transaction_header_id_out=l_trans_rec.transaction_header_id;

	/* Cursor to select  the distribution(s)  undergoing the reclasss */

	CURSOR 	c_old_dist(c_dist_id in FA_DISTRIBUTION_HISTORY.distribution_id%type) IS
		SELECT	distribution_id
		FROM 	fa_distribution_history
		WHERE 	asset_id=l_asset_hdr_rec.asset_id
		AND	    book_type_code=l_asset_hdr_rec.book_type_code
		AND	    transaction_header_id_out=l_trans_rec.transaction_header_id
		AND	    distribution_id=c_dist_id;

   	/* Cursor to select  the  new distribution(s)  undergoing the reclasss */

	CURSOR 	c_new_dist(c_dist_id in FA_DISTRIBUTION_HISTORY.distribution_id%type) IS
		SELECT	distribution_id
		FROM 	fa_distribution_history
		WHERE 	asset_id=l_asset_hdr_rec.asset_id
		AND	    book_type_code=l_asset_hdr_rec.book_type_code
		AND	    transaction_header_id_in=l_trans_rec.transaction_header_id
		AND	    distribution_id=c_dist_id;

	/* Cursor to select the details of impacted distribution in this reclass*/

	CURSOR 	c_impacted_dist(c_imp_dist_id FA_DISTRIBUTION_HISTORY.distribution_id%type) IS
		SELECT 	a.distribution_id,
			    a.units_assigned
		FROM 	fa_distribution_history a, fa_distribution_history b
		WHERE	a.asset_id=l_asset_hdr_rec.asset_id
		AND	    a.book_type_code=l_asset_hdr_rec.book_type_code
        AND     a.asset_id = b.asset_id
        AND     a.book_type_code = b.book_type_code
        AND     a.transaction_header_id_in=l_trans_rec.transaction_header_id
        AND     b.transaction_header_id_out = l_trans_rec.transaction_header_id
        AND 	nvl(a.location_id,-1) = nvl(b.location_id,-1)
        AND    a.units_assigned = b.units_assigned
        AND	    b.distribution_id=c_imp_dist_id;

      CURSOR 	c_impacted_dist_new(c_imp_dist_id FA_DISTRIBUTION_HISTORY.distribution_id%type ,
                                                       c_imp_dist_id_new FA_DISTRIBUTION_HISTORY.distribution_id%type) IS
		SELECT 	a.distribution_id,
			    a.units_assigned
		FROM 	fa_distribution_history a, fa_distribution_history b
		WHERE	a.asset_id=l_asset_hdr_rec.asset_id
		AND	    a.book_type_code=l_asset_hdr_rec.book_type_code
        AND     a.asset_id = b.asset_id
        AND     a.book_type_code = b.book_type_code
        AND     a.transaction_header_id_in=l_trans_rec.transaction_header_id
        AND     b.transaction_header_id_out = l_trans_rec.transaction_header_id
        AND 	nvl(a.location_id,-1) = nvl(b.location_id,-1)
        AND    a.units_assigned = b.units_assigned
        AND	    b.distribution_id=c_imp_dist_id
         AND  	a.distribution_id > c_imp_dist_id_new;

	/* Cursor to select adjustment_id or the previous transaction */

	CURSOR 	c_prev_data IS
		SELECT	a.rowid,a.adjustment_id
		FROM 	igi_iac_transaction_headers a
		WHERE	a.adjustment_id_out is null
        and     a.asset_id = l_asset_hdr_rec.asset_id;


	/* Cursor  to find the amounts that need to be transferres to the new  dist
	 created by reclass */

	CURSOR 	c_amounts(c_period_counter in IGI_IAC_ASSET_BALANCES.period_counter%type) IS
		SELECT	*
		FROM	igi_iac_asset_balances
		WHERE 	asset_id=l_asset_hdr_rec.asset_id
                AND     book_type_code=l_asset_hdr_rec.book_type_code
		AND	period_counter=(select max(period_counter)
					from 	igi_iac_asset_balances
					WHERE 	asset_id=l_asset_hdr_rec.asset_id
                			AND     book_type_code=l_asset_hdr_rec.book_type_code)
					;

	/* Cursor to find period counter from which the reclass is valid
	   Needed only in case of prior period transfers

	CURSOR 	c_prior_period_counter(c_trx_date in FA_DEPRN_PERIODS.period_open_date%type) IS
		SELECT 	period_counter
		FROM 	fa_deprn_periods
		WHERE 	c_trx_date between period_open_date and period_close_date
		AND 	book_type_code=p_asset_hdr_rec.book_type_code; */

	/* Cursor to find the total number of units for the asset itself ( active) */

	CURSOR 	c_units IS
		SELECT 	sum(units_assigned)
		FROM	fa_distribution_history
    	WHERE 	asset_id=l_asset_hdr_rec.asset_id
        AND     book_type_code=l_asset_hdr_rec.book_type_code
		AND	transaction_header_id_out is null;

	/* Cursor to find the total no of units involved in the transfer of old dist to new */

	CURSOR 	c_dist_units IS
		SELECT	sum(units_assigned)
		FROM    fa_distribution_history
                WHERE   asset_id=l_asset_hdr_rec.asset_id
                AND     book_type_code=l_asset_hdr_rec.book_type_code
		AND	transaction_header_id_in=l_trans_rec.transaction_header_id;

	/* Cursor for ytd deprn */

	CURSOR 	c_ytd_deprn(c_start_counter IGI_IAC_ASSET_BALANCES.period_counter%type
			   ,c_current_counter IGI_IAC_ASSET_BALANCES.period_counter%type) IS
		SELECT 	nvl(sum(deprn_amount),0) deprn_amount
		FROM 	igi_iac_asset_balances
		WHERE 	book_type_code=l_asset_hdr_rec.book_type_code
		AND	asset_id=l_asset_hdr_rec.asset_id
		AND	period_counter between c_start_counter and c_current_counter;

	/* Cursor for operating account ytd */

	CURSOR 	c_op_acct_ytd(c_start_counter IGI_IAC_ASSET_BALANCES.period_counter%type
			   ,c_current_counter IGI_IAC_ASSET_BALANCES.period_counter%type) IS
		SELECT 	nvl(sum(operating_acct),0) operating_acct
		FROM 	igi_iac_asset_balances
		WHERE 	book_type_code=l_asset_hdr_rec.book_type_code
		AND	asset_id=l_asset_hdr_rec.asset_id
		AND	period_counter between c_start_counter and c_current_counter;

	/* Cursor to select the start period number for a given fiscal year */

	 CURSOR c_start_period_counter(c_fiscal_year FA_DEPRN_PERIODS.fiscal_year%type) IS
	 	SELECT (number_per_fiscal_year*c_fiscal_year)+1
	 	FROM	fa_calendar_types
	 	WHERE   calendar_type=(select deprn_calendar from fa_book_controls
	 				where book_type_code=l_asset_hdr_rec.book_type_code);

	 /* Cursor to select the adjustment_id from the sequence for a new record */

	 CURSOR	c_adj_id IS
	 	SELECT 	igi_iac_transaction_headers_s.nextval
	 	FROM	dual;

	 /*  To select the asset's deprn_expense from fa_books */

	CURSOR 	c_deprn_expense(c_period_counter FA_DEPRN_SUMMARY.period_counter%type) IS
	        SELECT 	deprn_amount
	        FROM 	fa_deprn_summary
	        WHERE 	book_type_code = l_asset_hdr_rec.book_type_code
	        AND   	period_counter = c_period_counter
	        AND   	asset_id=l_asset_hdr_rec.asset_id;

	 /* Cursor to select the reval reserve backlog,op acct backlog and gen fund per for the dist */

	 CURSOR	c_backlog_data(c_current_period_Counter fa_deprn_periods.period_counter%type) IS
	 	SELECT 	sum(nvl(iadb.reval_reserve_backlog,0)) reval_reserve_backlog,
	 		sum(nvl(iadb.operating_acct_backlog,0)) operating_acct_backlog,
	 		sum(nvl(iadb.general_fund_per,0)) general_fund_per
	 	FROM	igi_iac_det_balances iadb,fa_distribution_history fdh
	 	WHERE 	iadb.book_type_code = l_asset_hdr_rec.book_type_code
	        AND   	iadb.period_counter = c_current_period_counter
	        AND   	iadb.asset_id=l_asset_hdr_rec.asset_id
	        AND	iadb.asset_id=fdh.asset_id
	        AND	iadb.book_type_code =fdh.book_type_code
	        AND 	fdh.transaction_header_id_out=l_trans_rec.transaction_header_id
	        AND	fdh.distribution_id=iadb.distribution_id;

	/*  To find the asset number */

	CURSOR	c_asset_num IS
		SELECT 	asset_number
		FROM	fa_additions
		WHERE	asset_id=l_asset_hdr_rec.asset_id;

    /* get the closing det balances record */
    CURSOR  c_closing_det_balances( p_old_dist  IGI_IAC_ADJUSTMENTS.distribution_id%type,
                                    p_adjustment_id IGI_IAC_ADJUSTMENTS.adjustment_id%type)is
    SELECT *
    FROM igi_iac_det_balances
    WHERE asset_id=l_asset_hdr_rec.asset_id
    AND book_type_code = l_asset_hdr_rec.book_type_code
    AND distribution_id = p_old_dist
    AND adjustment_id = p_adjustment_id;

    /* Cursor to get incactive distributuiions to be carried forward */
    CURSOR   get_all_prev_inactive_dist (C_prev_data_adjustment_id Number)
    is
    SELECT *
    FROM igi_iac_det_balances
    WHERE asset_id=l_asset_hdr_rec.asset_id
    AND book_type_code = l_asset_hdr_rec.book_type_code
    AND adjustment_id = C_prev_data_adjustment_id;
--    AND nvl(active_flag,'Y') = 'N';


   /* Enhancemnet 2480915 Cursor to fetch the igi_fa_deprn deatils */
    CURSOR c_get_deprn_dist (c_book_type_code Varchar2,
                                      c_asset_id Number,
                                      c_distribution_id Number,
                                      c_adjustment_id Number)      is
    SELECT *
    FROM IGI_IAC_FA_DEPRN
    WHERE book_type_code = c_book_type_code
    AND asset_id = c_asset_id
    AND Distribution_id = c_distribution_id
    AND adjustment_id = c_adjustment_id;


--	l_asset_revalued		    c_asset_revalued%rowtype;
	l_impacted_dist 		    c_impacted_dist%rowtype;
	l_amounts 			        c_amounts%rowtype;
	l_backlog_data			    c_backlog_data%rowtype;
    l_get_deprn_dist             c_get_deprn_dist%rowtype;
	l_old_dist			        c_old_dist%rowtype;
	l_dist_units			    FA_DISTRIBUTION_HISTORY.units_assigned%type;
	l_prd_rec 			        IGI_IAC_TYPES.prd_rec;
	l_prd_rec_prior			    IGI_IAC_TYPES.prd_rec;

	l_prev_data 			    c_prev_data%rowtype;
	l_adj_id 			        IGI_IAC_ADJUSTMENTS.adjustment_id%type;
	l_current_period_counter 	FA_DEPRN_PERIODS.period_counter%type;
	l_start_period_counter		FA_DEPRN_PERIODS.period_counter%type;

	l_asset_num			        FA_ADDITIONS.asset_number%type;
	l_units				        FA_DISTRIBUTION_HISTORY.units_assigned%type;
	l_reval_reserve 		    IGI_IAC_DET_BALANCES.reval_reserve_cost%type;
	l_general_fund 			    IGI_IAC_DET_BALANCES.general_fund_acc%type;
	l_Backlog_deprn_reserve 	IGI_IAC_DET_BALANCES.deprn_reserve_backlog%type;
	l_deprn_reserve			    IGI_IAC_DET_BALANCES.deprn_reserve%type;
	l_adjusted_cost			    IGI_IAC_DET_BALANCES.adjustment_cost%type;
	l_net_book_value 		    IGI_IAC_DET_BALANCES.net_book_value%type;
	l_deprn_per 			    IGI_IAC_DET_BALANCES.deprn_period%type;
	l_ytd_deprn 			    IGI_IAC_DET_BALANCES.deprn_ytd%type;
	l_op_acct 			        IGI_IAC_DET_BALANCES.operating_acct_ytd%type;
	l_op_acct_ytd			    IGI_IAC_DET_BALANCES.operating_acct_ytd%type;
	l_general_fund_per		    IGI_IAC_DET_BALANCES.general_fund_per%type;
	l_reval_reserve_backlog		IGI_IAC_DET_BALANCES.reval_reserve_backlog%type;
	l_operating_acct_backlog	IGI_IAC_DET_BALANCES.operating_acct_backlog%type;
	l_reval_ccid 			    IGI_IAC_ADJUSTMENTS.code_combination_id%type;
	l_gen_fund_ccid 		    IGI_IAC_ADJUSTMENTS.code_combination_id%type;
	l_backlog_ccid 			    IGI_IAC_ADJUSTMENTS.code_combination_id%type;
	l_deprn_ccid 			    IGI_IAC_ADJUSTMENTS.code_combination_id%type;
	l_cost_ccid 			    IGI_IAC_ADJUSTMENTS.code_combination_id%type;
	l_prior_period_counter		IGI_IAC_TRANSACTION_HEADERS.period_counter%type;
	l_historic_deprn_expense 	FA_DEPRN_SUMMARY.deprn_amount%type;
	l_Expense_diff			    IGI_IAC_DET_BALANCES.deprn_period%type;
	l_expense_ccid			    IGI_IAC_ADJUSTMENTS.code_combination_id%type;
      l_closing_det_balances      IGI_IAC_DET_BALANCES%ROWTYPE;
      l_adjustment_id             IGI_IAC_ADJUSTMENTS.adjustment_id%type;
      l_get_all_prev_dist   get_all_prev_inactive_dist%ROWTYPE;

      l_rowid                         rowid;
      l_return_value			    boolean;
      l_Prorate_factor		    number;
      l_deprn_expense			    number;
      x 				            varchar2(100);
      prior_period 			    Varchar2(100);
      l_mesg				        VARCHAR2(500);
      l_adjustment_id_out    Number;
      l_prev_adjustment_id Number;
      l_transaction_type_code varchar2(50);
      l_transaction_id  number ;
      l_mass_reference_id number ;
      l_adjustment_status varchar2(50);
      l_path_name VARCHAR2(150);

    BEGIN
      l_transaction_type_code := Null;
      l_adjustment_status := null ;
      l_path_name := g_path||'do_same_price_index';

      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     + Same price index begin ');

	/* Store the previous transaction adjustment id */
/*	open c_prev_data;
	fetch c_prev_data into l_prev_data;
    IF NOT c_prev_data%FOUND THEN
         debug(0,'     + Fetch the previous transaction adjustment id does not exisit');
    END IF;

	close c_prev_data;*/

           IF NOT igi_iac_common_utils.Get_Latest_Transaction (
                       		X_book_type_code    => l_asset_hdr_rec.book_type_code,
                       		X_asset_id          => l_asset_hdr_rec.asset_id,
                       		X_Transaction_Type_Code	=> l_transaction_type_code,
                       		X_Transaction_Id	=> l_transaction_id,
                       		X_Mass_Reference_ID	=> l_mass_reference_id,
                       		X_Adjustment_Id		=> l_adjustment_id_out,
                       		X_Prev_Adjustment_Id => l_prev_adjustment_id,
                       		X_Adjustment_Status	=> l_adjustment_status) THEN
  	    		igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     			p_full_path => l_path_name,
		     			p_string => '*** Error in fetching the latest transaction');

                        return FALSE;
                   END IF;

      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     + Fetch the previous transaction adjustment id '||l_prev_adjustment_id);


    /*Get the open period and create new transaction record in the transaction headers table */
	IF igi_iac_common_utils.get_open_period_info(l_asset_hdr_rec.book_type_code,l_prd_rec) THEN
		l_current_period_counter:=l_prd_rec.period_counter;
  	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '     + Current OPen Period counter' ||l_prd_rec.period_counter );

	END IF;

  	/*Fetch the adjustment id from the sequence*/
   open c_adj_id;
   fetch c_adj_id into l_adj_id;
   close c_adj_id;

      	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     + before Insert into trans header' );

  	/*Insert into transaction headers */
	insert_data_trans_hdr(l_adj_id,
			l_trans_rec.transaction_header_id,
			NULL,
			l_trans_rec.transaction_type_code,
			l_trans_rec.transaction_date_entered,
			l_trans_rec.mass_reference_id,
			l_asset_hdr_rec.book_type_code,
			l_asset_hdr_rec.Asset_id,
			null,
			'COMPLETE',
            	   	l_asset_cat_rec_old.category_id,
	       		-- l_asset_cat_rec_new.category_id,
			l_current_period_counter,
            p_event_id
			);

      	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     + After Insert into trans header' );

	/* To select the backlog data for the old distribution to be prorated into new */
       -- Bug 2588308 sekhar --
       -- Need to close the previous transaction to pick the latest catgeory --

       IGI_IAC_TRANS_HEADERS_PKG.update_row (
    		x_prev_adjustment_id                =>l_adjustment_id_out,
    		x_adjustment_id		            =>l_adj_id,
    		x_mode                              =>'R'
				  );


	open c_backlog_data(l_current_period_counter);
	fetch c_backlog_data into l_backlog_data;
	close c_backlog_data;


	/* Distribution(s) involved in the transfer (old and new) and the non impacted ones*/

		open c_amounts(l_current_period_counter);
		fetch c_amounts into l_amounts;
		close c_amounts;

		open c_units;
		fetch c_units into l_units;
		close c_units;

		open c_dist_units;
		fetch c_dist_units into l_dist_units;
		close c_dist_units;
        l_impacted_dist := Null;
	FOR l_all_dist in c_all_dist
	loop

		/*l_reval_reserve:=l_amounts.reval_reserve;
		l_general_fund:=l_amounts.general_fund;
		l_Backlog_deprn_reserve:=l_amounts.backlog_deprn_reserve;
		l_deprn_reserve:=l_amounts.deprn_reserve;
		l_adjusted_cost:=l_amounts.adjusted_cost;
		l_net_book_value:=l_amounts.net_book_value;
		l_deprn_per:=l_amounts.deprn_amount;
		l_op_acct:=l_amounts.operating_acct;*/

		open c_start_period_counter(l_prd_rec.fiscal_year);
		fetch c_start_period_counter into l_start_period_counter;
		close c_start_period_counter;


		open c_ytd_deprn(l_start_period_counter,l_prd_rec.period_counter);
		fetch c_ytd_deprn into l_ytd_deprn;
		close c_ytd_deprn;

		open c_op_acct_ytd(l_start_period_counter,l_prd_rec.period_counter);
		fetch c_op_acct_ytd into l_op_acct_ytd;
		close c_op_acct_ytd;

		open c_old_dist(l_all_dist.distribution_id);
		fetch c_old_dist into l_old_dist;
		close c_old_dist;
         If  (l_impacted_dist.distribution_id  IS NULL ) Then
    		open c_impacted_dist(l_all_dist.distribution_id);
	    	fetch c_impacted_dist into l_impacted_dist;
  	      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '         + impacted distribution id ' || l_all_dist.distribution_id);
  	      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '         + new impacted distribution id ' || l_impacted_dist.distribution_id);
	    	close c_impacted_dist;
        Else
            	open c_impacted_dist_new(l_all_dist.distribution_id,l_impacted_dist.distribution_id);
	    	fetch c_impacted_dist_new into l_impacted_dist;
  	        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '         + impacted distribution id ' || l_all_dist.distribution_id);
  	        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '         + new impacted distribution id ' || l_impacted_dist.distribution_id);

	    	close c_impacted_dist_new;
        End if;

		open c_old_dist(l_all_dist.distribution_id);
		fetch c_old_dist into l_old_dist;
        IF c_old_dist%NOTFOUND THEN
  	      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => ' No old distribution for asset found ' || l_old_dist.distribution_id);

            close c_old_dist;
            return false;
        End if;
        close c_old_dist;
  	      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '  + no old distribution for asset ' || l_old_dist.distribution_id);

        /* get the closing det balances record form iac det balances */
        l_adjustment_id :=l_prev_adjustment_id;
      --        open c_closing_det_balances(l_old_dist,l_adjustment_id);

        open c_closing_det_balances(l_old_dist.distribution_id,l_prev_adjustment_id);
        fetch c_closing_det_balances into l_closing_det_balances;
        IF c_closing_det_balances%NOTFOUND THEN
  	      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '  +  old distruibution id ' || l_old_dist.distribution_id);
  	      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '  +  adjustement id  '||l_prev_adjustment_id);
  	      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => ' Could not  find the IAC  det balances record ');

            close c_closing_det_balances;
            return false;
          End if;
  	      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '  +  old distruibution id ' || l_old_dist.distribution_id);
  	      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '  +  adjustement id  '||l_prev_adjustment_id);

        close c_closing_det_balances;


        l_closing_det_balances.adjustment_id    := l_adj_id;
        l_closing_det_balances.period_counter := l_current_period_counter;
        l_deprn_reserve_amount:=  0;

        Update igi_iac_transaction_headers
          set category_id = l_asset_cat_rec_old.category_id
          where adjustment_id = l_adj_id;

        if create_iac_acctg ( l_closing_det_balances,TRUE,'OLD',p_event_id => p_event_id) Then
  	      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '+Accounting entries created for old');
         else
  	      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'Failed to create Accounting entries');

            return false;
        end if;
                    /* IF (DIFF_PRICE_INDEX_FLAG) AND
                       (ALLOW_INDEX_REVAL_FLAG OR ALLOW_PROF_REVAL_FLAG) THEN
                           l_closing_det_balances.DEPRN_YTD := 0;
                      END IF;*/


                      insert_data_det(p_adjustment_id  =>l_adj_id,
        		      p_asset_id		        =>l_asset_hdr_rec.asset_id,
    			      p_distribution_id	        =>l_closing_det_balances.distribution_id,
    			      p_period_counter	        =>l_closing_det_balances.period_counter,
    			      p_book_type_code          =>l_asset_hdr_rec.book_type_code,
    			      p_adjusted_cost	        =>0,
    			      p_net_book_value      	=>0,
    			      p_reval_reserve	        =>0,
    			      p_reval_reserve_gen_fund	=>0,
    			      p_reval_reserve_backlog	=>0,
                      p_reval_reserve_net	        =>0,
    			      p_op_acct			        =>0,
                      p_op_acct_net			        =>0,
    			      p_deprn_reserve		    =>0,
    			      p_deprn_reserve_backlog 	=>0,
    			      p_deprn_ytd		        =>l_closing_det_balances.DEPRN_YTD,
    			      p_deprn_period	    	=>0,
    			      p_gen_fund_acc		    =>0,
    			      p_gen_fund_per		    =>0,
    			      p_current_reval_factor	=>l_closing_det_balances.current_reval_factor,
    			      p_cumulative_reval_factor =>l_closing_det_balances.cumulative_reval_factor,
    			      p_reval_flag		        => 'N',
    			      p_op_acct_ytd		        =>0,
    			      p_operating_acct_backlog  =>0,
    			      p_last_reval_date		    =>l_closing_det_balances.last_reval_date);


                   -- enchancement 2480915 maintiain the ytd values ---
                   Open  c_get_deprn_dist  (l_asset_hdr_rec.book_type_code,
                                      l_asset_hdr_rec.asset_id,
                                      l_closing_det_balances.distribution_id ,
                                      l_adjustment_id_out );
                    Fetch    c_get_deprn_dist into l_get_deprn_dist;
                    IF c_get_deprn_dist%FOUND THEN
                           /* Call to TBH for insert into IGI_IAC_ADJUSTMENTS */
    	            IGI_IAC_FA_DEPRN_PKG.insert_row(
    		            	x_rowid                             =>l_rowid,
                			x_adjustment_id                =>l_adj_id,
    		            	x_book_type_code             =>l_asset_hdr_rec.book_type_code,
                			x_asset_id                         =>l_asset_hdr_rec.asset_id,
     		            	x_distribution_id                 =>l_closing_det_balances.distribution_id,
                			x_period_counter               =>l_closing_det_balances.period_counter,
                            x_deprn_period                 => 0,
                           x_deprn_ytd                     =>l_get_deprn_dist.deprn_ytd,
                            x_deprn_reserve              => 0,
                            x_active_flag                    => 'N',
                			x_mode                              =>'R'
            			);

                    END IF;
                   Close c_get_deprn_dist;
                  -- enchancement 2480915 maintiain the ytd values ---




         -- before performing the new distribution account entries update with new catgeory
          Update igi_iac_transaction_headers
          set category_id = l_asset_cat_rec_new.category_id
          where adjustment_id = l_adj_id;


         IF (DIFF_PRICE_INDEX_FLAG) AND
           (ALLOW_INDEX_REVAL_FLAG OR ALLOW_PROF_REVAL_FLAG) THEN

               l_closing_det_balances.distribution_id := l_impacted_dist.distribution_id;
               if create_iac_acctg ( l_closing_det_balances,TRUE,'NEW',p_event_id => p_event_id) Then
  	       	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '+Accounting entries created for new ');

               else
  	       	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'Failed to create Accounting entries ');

            	return false;
               end if;
        end if;
/*                     debug(0,'Create Det balances for new dist for diff price index');
                    debug(0,'dist id'||l_closing_det_balances.distribution_id );
                    debug(0,'adjustment id '|| l_adj_id);
                    debug(0,'period counter'|| l_closing_det_balances.period_counter);*/


             /*   insert_data_det(p_adjustment_id  =>l_adj_id,
        		      p_asset_id		        =>l_asset_hdr_rec.asset_id,
    			      p_distribution_id	        =>l_impacted_dist.distribution_id,
    			      p_period_counter	        =>l_closing_det_balances.period_counter,
    			      p_book_type_code          =>l_asset_hdr_rec.book_type_code,
    			      p_adjusted_cost	        =>0,
    			      p_net_book_value      	=>0,
    			      p_reval_reserve	        =>0,
    			      p_reval_reserve_gen_fund	=>0,
    			      p_reval_reserve_backlog	=>0,
    			      p_op_acct			        =>0,
    			      p_deprn_reserve		    =>0,
    			      p_deprn_reserve_backlog 	=>0,
    			      p_deprn_ytd		        =>0,
    			      p_deprn_period	    	=>0,
    			      p_gen_fund_acc		    =>0,
    			      p_gen_fund_per		    =>0,
    			      p_current_reval_factor	=>0,
    			      p_cumulative_reval_factor =>0,
    			      p_reval_flag		        => Null,
    			      p_op_acct_ytd		        =>0,
    			      p_operating_acct_backlog  =>0,
    			      p_last_reval_date		    =>l_closing_det_balances.last_reval_date);
        END IF;*/

        /* Create a  det balances record for the new distribution only for same price index*/

        IF (SAME_PRICE_INDEX_FLAG) AND
           (ALLOW_INDEX_REVAL_FLAG OR ALLOW_PROF_REVAL_FLAG) THEN


             l_closing_det_balances.distribution_id  := l_impacted_dist.distribution_id;
             l_closing_det_balances.period_counter := l_current_period_counter;
            --accounting entry for YTD
            if create_iac_acctg ( l_closing_det_balances,TRUE,'NEW',p_event_id => p_event_id) Then
  	    	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '+Accounting entries created');

            else
  	    	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'Failed to create Accounting entries ');

                return false;
            end if;
           l_closing_det_balances.deprn_YTD := 0;

            insert_data_det(p_adjustment_id         =>l_adj_id,
    			      p_asset_id		        =>l_asset_hdr_rec.asset_id,
    			      p_distribution_id	        =>l_impacted_dist.distribution_id,
    			      p_period_counter	        =>l_current_period_counter,
    			      p_book_type_code          =>l_asset_hdr_rec.book_type_code,
    			      p_adjusted_cost	        =>l_closing_det_balances.adjustment_cost,
    			      p_net_book_value      	=>l_closing_det_balances.net_book_value,
    			      p_reval_reserve	        =>l_closing_det_balances.reval_reserve_cost,
    			      p_reval_reserve_gen_fund	=>l_closing_det_balances.reval_reserve_gen_fund,
    			      p_reval_reserve_backlog	=>l_closing_det_balances.reval_reserve_backlog,
                       -- Bug 2767992 Sekhar Modified for reval reserve net
                      p_reval_reserve_net	        =>l_closing_det_balances.reval_reserve_net,
    			      p_op_acct			        =>l_closing_det_balances.OPERATING_ACCT_COST,
                      p_op_acct_net			        =>l_closing_det_balances.OPERATING_ACCT_net,
    			      p_deprn_reserve		    =>l_closing_det_balances.deprn_reserve,
    			      p_deprn_reserve_backlog 	=>l_closing_det_balances.deprn_reserve_backlog,
    			      p_deprn_ytd		        =>l_closing_det_balances.deprn_YTD,
    			      p_deprn_period	    	=>l_closing_det_balances.deprn_period,
    			      p_gen_fund_acc		    =>l_closing_det_balances.general_fund_acc,
    			      p_gen_fund_per		    =>l_closing_det_balances.general_fund_per,
    			      p_current_reval_factor	=>l_closing_det_balances.current_reval_factor,
    			      p_cumulative_reval_factor =>l_closing_det_balances.cumulative_reval_factor,
    			      p_reval_flag		        => Null,
    			      p_op_acct_ytd		        =>l_closing_det_balances.OPERATING_ACCT_YTD,
    			      p_operating_acct_backlog  =>l_closing_det_balances.OPERATING_ACCT_BACKLOG,
    			      p_last_reval_date		    =>l_closing_det_balances.last_reval_date);


                                 -- enchancement 2480915 maintiain the ytd values ---
                   Open  c_get_deprn_dist  (l_asset_hdr_rec.book_type_code,
                                      l_asset_hdr_rec.asset_id,
                                      l_old_dist.distribution_id ,
                                      l_adjustment_id_out );
                    Fetch    c_get_deprn_dist into l_get_deprn_dist;
                    IF c_get_deprn_dist%FOUND THEN
                           /* Call to TBH for insert into IGI_IAC_ADJUSTMENTS */
    	            IGI_IAC_FA_DEPRN_PKG.insert_row(
    		            	x_rowid                             =>l_rowid,
                			x_adjustment_id                =>l_adj_id,
    		            	x_book_type_code             =>l_asset_hdr_rec.book_type_code,
                			x_asset_id                         =>l_asset_hdr_rec.asset_id,
     		            	x_distribution_id                 =>l_closing_det_balances.distribution_id,
                			x_period_counter               =>l_closing_det_balances.period_counter,
                            x_deprn_period                 => l_get_deprn_dist.deprn_period,
                           x_deprn_ytd                     =>0,
                            x_deprn_reserve              =>l_get_deprn_dist.deprn_reserve,
                            x_active_flag                    => Null,
                			x_mode                              =>'R'
            			);

                    END IF;
                   Close c_get_deprn_dist;
                  -- enchancement 2480915 maintiain the ytd values ---


  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '  +  After insert into det balances ' || l_old_dist.distribution_id);

                open c_closing_det_balances(l_impacted_dist.distribution_id,l_adj_id);
                fetch c_closing_det_balances into l_closing_det_balances;
                IF c_closing_det_balances%NOTFOUND THEN
  	    	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		    		p_full_path => l_path_name,
		    		p_string => ' Could not  find the IAC records ');

                    close c_closing_det_balances;
                    return false;
                End if;

  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		    		 p_string => '  +  old distruibution id ' || l_impacted_dist.distribution_id);
  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		    		 p_string => '  +  adjustement id  '|| l_adj_id);


                close c_closing_det_balances;

            ELSIF (NOT (ALLOW_INDEX_REVAL_FLAG OR ALLOW_PROF_REVAL_FLAG))  THEN

                    l_closing_det_balances.distribution_id  := l_impacted_dist.distribution_id;
                    insert_data_det(p_adjustment_id         =>l_adj_id,
    			      p_asset_id		        =>l_asset_hdr_rec.asset_id,
    			      p_distribution_id	        =>l_impacted_dist.distribution_id,
    			      p_period_counter	        =>l_current_period_counter,
    			      p_book_type_code          =>l_asset_hdr_rec.book_type_code,
    			      p_adjusted_cost	        =>0,
    			      p_net_book_value      	=>0,
    			      p_reval_reserve	        =>0,
                      p_reval_reserve_net	        =>0,
    			      p_reval_reserve_gen_fund	=>0,
    			      p_reval_reserve_backlog	=>0,
    			      p_op_acct			        =>0,
                      p_op_acct_net			        =>0,
    			      p_deprn_reserve		    =>0,
    			      p_deprn_reserve_backlog 	=>0,
    			      p_deprn_ytd		        =>0,
    			      p_deprn_period	    	=>0,
    			      p_gen_fund_acc		    =>0,
    			      p_gen_fund_per		    =>0,
    			      p_current_reval_factor	=>0,
    			      p_cumulative_reval_factor =>0,
    			      p_reval_flag		        => Null,
    			      p_op_acct_ytd		        =>0,
    			      p_operating_acct_backlog  =>0,
    			      p_last_reval_date		    =>l_closing_det_balances.last_reval_date);


		END IF;
		/* End of loop for insert into det_balances table */

	End Loop;
	 /* End of loop for all active distributions */


    /* Update the asset balanaces to zero in case new category is has no prof and indexed revalutions */

    IF NOT (ALLOW_INDEX_REVAL_FLAG OR ALLOW_PROF_REVAL_FLAG) THEN
            igi_iac_asset_balances_pkg.update_row(
	    			X_asset_id		          => l_asset_hdr_rec.asset_id,
					X_book_type_code	      => l_asset_hdr_rec.book_type_code,
					X_period_counter	      => l_current_period_counter ,
					X_net_book_value	      => 0,
					X_adjusted_cost		      => 0,
					X_operating_acct	      => 0,
					X_reval_reserve		      => 0,
					X_deprn_amount		      => 0,
					X_deprn_reserve		      => 0,
					X_backlog_deprn_reserve   => 0,
					X_general_fund		      => 0,
					X_last_reval_date	      => Null,
					X_current_reval_factor	  => 0,
        			X_cumulative_reval_factor => 0) ;

    END IF;

    /* get the ytd sum of the active distributiions*/
    l_deprn_ytd := 0;
    /* bring forward all the inactive distributions to the current adjustment */
    FOR  l_get_all_prev_dist in get_all_prev_inactive_dist (l_prev_adjustment_id) LOOP


                    IF l_get_all_prev_dist.active_flag = 'N' THEN
                      /*create a record with new distribution id */
                   /*IF (DIFF_PRICE_INDEX_FLAG) AND
                       (ALLOW_INDEX_REVAL_FLAG OR ALLOW_PROF_REVAL_FLAG) THEN
                            l_get_all_prev_dist.deprn_ytd := 0;
                      END IF;*/

                    insert_data_det(p_adjustment_id         =>l_adj_id,
    			      p_asset_id		        =>l_asset_hdr_rec.asset_id,
    			      p_distribution_id	        =>l_get_all_prev_dist.distribution_id,
    			      p_period_counter	        =>l_current_period_counter,
    			      p_book_type_code          =>l_get_all_prev_dist.book_type_code,
    			      p_adjusted_cost	          =>l_get_all_prev_dist.adjustment_cost,
    			      p_net_book_value      	=>l_get_all_prev_dist.net_book_value,
    			      p_reval_reserve	        =>l_get_all_prev_dist.reval_reserve_cost,
    			      p_reval_reserve_gen_fund	=>l_get_all_prev_dist.reval_reserve_gen_fund,
    			      p_reval_reserve_backlog	=>l_get_all_prev_dist.reval_reserve_backlog,
    			      p_op_acct			        =>l_get_all_prev_dist.OPERATING_ACCT_COST,
    			      p_deprn_reserve		    =>l_get_all_prev_dist.deprn_reserve,
    			      p_deprn_reserve_backlog 	=>l_get_all_prev_dist.deprn_reserve_backlog,
    			      p_deprn_ytd		        => l_get_all_prev_dist.deprn_ytd,
                       -- Bug 2767992 Sekhar Modified for reval reserve net
                      p_reval_reserve_net	        =>l_get_all_prev_dist.reval_reserve_net,
                      p_op_acct_net			        =>l_get_all_prev_dist.OPERATING_ACCT_net,
                     -- p_deprn_ytd		        => 0,
    			      p_deprn_period	    	=>l_get_all_prev_dist.deprn_period,
    			      p_gen_fund_acc		    =>l_get_all_prev_dist.general_fund_acc,
    			      p_gen_fund_per		    =>l_get_all_prev_dist.general_fund_per,
    			      p_current_reval_factor	=>l_get_all_prev_dist.current_reval_factor,
    			      p_cumulative_reval_factor =>l_get_all_prev_dist.cumulative_reval_factor,
    			      p_reval_flag		        => l_get_all_prev_dist.active_flag,
    			      p_op_acct_ytd		        =>l_get_all_prev_dist.OPERATING_ACCT_YTD,
    			      p_operating_acct_backlog  =>l_get_all_prev_dist.OPERATING_ACCT_BACKLOG,
    			      p_last_reval_date		    =>l_get_all_prev_dist.last_reval_date);

                    -- enchancement 2480915 maintiain the ytd values ---
                   Open  c_get_deprn_dist  (l_asset_hdr_rec.book_type_code,
                                      l_asset_hdr_rec.asset_id,
                                      l_get_all_prev_dist.distribution_id ,
                                      l_adjustment_id_out );
                    Fetch    c_get_deprn_dist into l_get_deprn_dist;
                    IF c_get_deprn_dist%FOUND THEN
                           /* Call to TBH for insert into IGI_IAC_ADJUSTMENTS */
    	            IGI_IAC_FA_DEPRN_PKG.insert_row(
    		            	x_rowid                             =>l_rowid,
                			x_adjustment_id                =>l_adj_id,
    		            	x_book_type_code             =>l_asset_hdr_rec.book_type_code,
                			x_asset_id                         =>l_asset_hdr_rec.asset_id,
     		            	x_distribution_id                 =>l_get_all_prev_dist.distribution_id,
                			x_period_counter               =>l_closing_det_balances.period_counter,
                            x_deprn_period                 => l_get_deprn_dist.deprn_period,
                           x_deprn_ytd                     =>l_get_deprn_dist.deprn_ytd,
                            x_deprn_reserve              =>l_get_deprn_dist.deprn_reserve,
                            x_active_flag                    => 'N',
                			x_mode                              =>'R'
            			);

                    END IF;
                   Close c_get_deprn_dist;
                  -- enchancement 2480915 maintiain the ytd values ---


                ELSE
                    l_deprn_ytd := l_deprn_ytd + l_get_all_prev_dist.deprn_ytd;
                 END IF;

    END LOOP;



    /*Terminate the previous active row with the adjustment_id_out in transaction_headers table*/
      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => ' close the prevooius adjusment');
      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'old adjusment id ' || l_adjustment_id_out);
      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'current adjusment id ' || l_adj_id);

	IGI_IAC_TRANS_HEADERS_PKG.update_row (
    		x_prev_adjustment_id                =>l_adjustment_id_out,
    		x_adjustment_id		            =>l_adj_id,
    		x_mode                              =>'R'
				  );

	RETURN(TRUE);


EXCEPTION
 WHEN OTHERS THEN
    igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
    l_mesg:=SQLERRM;
    FA_SRVR_MSG.Add_Message(
	                Calling_FN 	=> l_calling_function ,
        	        Name 		=> 'IGI_IAC_EXCEPTION',
        	        TOKEN1		=> 'PACKAGE',
        	        VALUE1		=> 'Reclass',
        	        TOKEN2		=> 'ERROR_MESSAGE',
        	        VALUE2		=> l_mesg,
                    APPLICATION => 'IGI');

    RETURN(FALSE);

END; --do_same_price_index


    PROCEDURE Debug_Period(p_period igi_iac_types.prd_rec) IS
  	  l_path_name VARCHAR2(150);
    BEGIN
  	  l_path_name := g_path||'debug_period';
  	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         Period counter :'||to_char(p_period.period_counter));
  	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         Period Num :'||to_char(p_period.period_num));
  	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         Fiscal Year :'||to_char(p_period.fiscal_year));
  	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         Period Name :'||p_period.period_name);

    END Debug_Period;

    PROCEDURE Debug_Asset(p_asset igi_iac_types.iac_reval_input_asset) IS
  	  l_path_name VARCHAR2(150);
    BEGIN
  	  l_path_name := g_path||'debug_asset';
  	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         Net book value :'||to_char(p_asset.net_book_value));
  	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         Adjusted Cost :'||to_char(p_asset.adjusted_cost));
  	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         Operating Account :'||to_char(p_asset.operating_acct));
  	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         Reval Reserve :'||to_char(p_asset.reval_reserve));
  	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         Deprn Amount :'||to_char(p_asset.deprn_amount));
  	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         Deprn Reserve :'||to_char(p_asset.deprn_reserve));
  	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         Backlog Deprn Reserve :'||to_char(p_asset.backlog_deprn_reserve));
  	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         General Fund :'||to_char(p_asset.general_fund));
  	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         Current Reval Factor :'||to_char(p_asset.current_reval_factor));
  	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         Cumulative Reval Factor :'||to_char(p_asset.Cumulative_reval_factor));

    END Debug_Asset;

-- ======================================================================
-- DIFFERENT PRICE INDEX RECLASS
-- function do all that needed for if both catgeories old and new has same
-- price index
-- ======================================================================
FUNCTION Do_Revaluation_Catchup(
        p_book_type_code                 VARCHAR2,
        p_asset_id                       NUMBER,
        p_category_id                    NUMBER,
        p_calling_function               VARCHAR2,
        p_event_id                       number
    ) return BOOLEAN IS

CURSOR c_allow_indexed_reval_flag IS
        SELECT allow_indexed_reval_flag
        FROM igi_iac_category_books
        WHERE book_type_code = p_book_type_code
        AND category_id = p_category_id;

        CURSOR c_period_num_for_catchup IS
        SELECT period_num_for_catchup
        FROM igi_iac_book_controls
        WHERE book_type_code = p_book_type_code;

        CURSOR c_prof_occ_reval_periods is
        SELECT revaluation_type,revaluation_period,revaluation_factor,new_cost,current_cost
        FROM igi_iac_revaluations rev,
             igi_iac_reval_asset_rules rul
        WHERE rev.revaluation_id = rul.revaluation_id
        AND   rev.book_type_code = l_asset_hdr_rec.BOOK_TYPE_CODE
        AND   rev.book_type_code = rul.book_type_code
        AND   rul.revaluation_type in ('O','P')
       -- bug 2844230 Sekhar
       -- Not required unable to fecth previous revaluations
      --  AND   rul.category_id = l_asset_cat_rec_new.category_id
        AND   rul.asset_id = l_asset_hdr_rec.ASSET_ID
        order by revaluation_period;

        /* Cursor to get fully reserved, fully retired info for the asset from FA */
   	    CURSOR c_fa_books(p_asset_id fa_books.asset_id%TYPE) IS
   	        SELECT salvage_value,cost
   	        FROM fa_books
   	        WHERE book_type_code = p_book_type_code
   	        AND   asset_id = p_asset_id
   	        AND   transactioN_header_id_out is NULL ;


        l_dpis_period_counter       NUMBER;
        l_open_period               igi_iac_types.prd_rec;
        l_period_info               igi_iac_types.prd_rec;
        l_allow_indexed_reval_flag  igi_iac_category_books.allow_indexed_reval_flag%TYPE;
        l_period_num_for_catchup    igi_iac_book_controls.period_num_for_catchup%TYPE;
        l_idx1                      BINARY_INTEGER;
        l_idx2                      BINARY_INTEGER;
        l_reval_control             igi_iac_types.iac_reval_control_tab;
        l_reval_asset_params        igi_iac_types.iac_reval_asset_params_tab;
        l_reval_input_asset         igi_iac_types.iac_reval_asset_tab;
        l_reval_output_asset        igi_iac_types.iac_reval_asset_tab;
        l_reval_output_asset_mvmt   igi_iac_types.iac_reval_asset_tab;
        l_reval_asset_rules         igi_iac_types.iac_reval_asset_rules_tab;
        l_prev_rate_info            igi_iac_types.iac_reval_rates_tab;
        l_curr_rate_info_first      igi_iac_types.iac_reval_rates_tab;
        l_curr_rate_info_next       igi_iac_types.iac_reval_rates_tab;
        l_curr_rate_info            igi_iac_types.iac_reval_rates_tab;
        l_reval_exceptions          igi_iac_types.iac_reval_exceptions_tab;
        l_fa_asset_info             igi_iac_types.iac_reval_fa_asset_info_tab;
        l_reval_params              igi_iac_types.iac_reval_params;
        l_reval_asset               igi_iac_types.iac_reval_input_asset;
        l_reval_asset_out           igi_iac_types.iac_reval_output_asset;
        l_revaluation_id            igi_iac_revaluations.revaluation_id%TYPE;
        l_user_id                   NUMBER;
        l_login_id                  NUMBER;
        l_current_reval_factor      igi_iac_asset_balances.current_reval_factor%TYPE;
        l_cumulative_reval_factor   igi_iac_asset_balances.cumulative_reval_factor%TYPE;
        l_last_reval_period         igi_iac_asset_balances.period_counter%TYPE;
        l_prof_occ_reval_periods    c_prof_occ_reval_periods%ROWTYPE;
        l_rowid			    VARCHAR2(25);
	/* Bug 2961656 vgadde 08-Jul-2003 Start(1) */
        l_fa_deprn_amount_py        NUMBER;
        l_fa_deprn_amount_cy        NUMBER;
        l_last_asset_period         NUMBER;
        l_salvage_value             Number;
        l_cost                      Number;
	/* Bug 2961656 vgadde 08-Jul-2003 End(1) */
        l_path_name VARCHAR2(150);
    BEGIN
        l_idx1 := 0;
        l_idx2 := 0;
        l_user_id := fnd_global.user_id;
        l_login_id := fnd_global.login_id;
        l_path_name := g_path||'do_revaluation_catchup';

  	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '=========================================');
  	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'Start of IAC Prior Additions  Processing....');
  	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '-----Parameters from FA code hook-----------');
  	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '     Book type code  :'||p_book_type_code);
  	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '     Category Id     :'||to_char(p_category_id));
  	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '     Asset Id        :'||to_char(p_asset_id));
  	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '--------------------------------------------');


        OPEN c_allow_indexed_reval_flag;
        FETCH c_allow_indexed_reval_flag INTO l_allow_indexed_reval_flag;
        CLOSE c_allow_indexed_reval_flag;

      /*  Debug('     Allow Indexed reval flag :'||l_allow_indexed_reval_flag);
        IF (l_allow_indexed_reval_flag = 'N') THEN
            return TRUE;
        END IF;*/

        IF NOT igi_iac_common_utils.get_dpis_period_counter(p_book_type_code,
                                                            p_asset_id,
                                                            l_dpis_period_counter) THEN
  	      igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     	p_full_path => l_path_name,
		     	p_string => '*** Error in Fetching DPIS period counter');
              return FALSE;
        END IF;

        IF NOT igi_iac_common_utils.get_open_period_info(p_book_type_code,
                                                         l_open_period) THEN
  	      igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     	p_full_path => l_path_name,
		     	p_string => '*** Error in Fetching Open period info for book');
              return FALSE;
        END IF;

        OPEN c_period_num_for_catchup;
        FETCH c_period_num_for_catchup INTO l_period_num_for_catchup;
        CLOSE c_period_num_for_catchup;


  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     Revaluation catchup period for the book :'||to_char(l_period_num_for_catchup));
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '------- Revaluation catchup periods for the asset -------');

        /* get the first revaluation period */
        OPEN c_prof_occ_reval_periods;
        FETCH c_prof_occ_reval_periods into l_prof_occ_reval_periods;
        IF NOT c_prof_occ_reval_periods%FOUND THEN
             l_prof_occ_reval_periods.revaluation_period :=l_open_period.period_counter-1;
        END IF;
        CLOSE  c_prof_occ_reval_periods;

        /* do revaluations till the first period of revaluations found in the asset rules*/

        FOR l_period_counter IN l_dpis_period_counter..l_open_period.period_counter-1 LOOP

            IF NOT igi_iac_common_utils.get_period_info_for_counter(p_book_type_code,
                                                                    l_period_counter,
                                                                    l_period_info) THEN
  		igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     		p_full_path => l_path_name,
		     		p_string => '*** Error in fetching period info');

                return FALSE;
            END IF;



            IF (l_period_num_for_catchup = l_period_info.period_num) THEN
                Debug_Period(l_period_info);
  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'catch up Reval period ' || to_char(l_period_counter));

                l_idx1 := l_idx1 + 1;
                l_reval_control(l_idx1).revaluation_mode := 'L'; -- Live Mode
                l_reval_asset_rules(l_idx1).revaluation_type := 'O'; -- Occasional
                l_reval_asset_params(l_idx1).asset_id := p_asset_id;
                l_reval_asset_params(l_idx1).category_id := p_category_id;
                l_reval_asset_params(l_idx1).book_type_code := p_book_type_code;
                l_reval_asset_params(l_idx1).period_counter := l_period_counter;

            END IF;
        END LOOP;

  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '------------------------------------------------------');

        /* Get the number of professional revaluations done and intialize the structure */
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'Get the number of professional revaluations done and intialize the structure');

        IF l_idx1 = 0 then
         FOR l_period_counter IN l_dpis_period_counter..l_open_period.period_counter-1 LOOP

            IF NOT igi_iac_common_utils.get_period_info_for_counter(p_book_type_code,
                                                                    l_period_counter,
                                                                    l_period_info) THEN
  		igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     		p_full_path => l_path_name,
		     		p_string => '*** Error in fetching period info');

                return FALSE;
            END IF;

            FOR l_prof_occ_reval_periods in c_prof_occ_reval_periods LOOP

                IF (l_prof_occ_reval_periods.revaluation_period = l_period_counter) THEN
                    Debug_Period(l_period_info);
  	    	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => ' Reval period ' || to_char(l_period_counter));
  	    	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => ' Reval type ' || l_prof_occ_reval_periods.revaluation_type);
  	    	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => ' Reval new cost '|| l_prof_occ_reval_periods.new_cost);
  	    	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => ' Reval current cost '|| l_prof_occ_reval_periods.current_cost);

                    l_idx1 := l_idx1 + 1;
                    l_reval_control(l_idx1).revaluation_mode := 'L'; -- Live Mode
                    l_reval_asset_rules(l_idx1).revaluation_type :=l_prof_occ_reval_periods.revaluation_type; -- Occasional
                    l_reval_asset_params(l_idx1).asset_id := p_asset_id;
                    l_reval_asset_params(l_idx1).category_id := p_category_id;
                    l_reval_asset_params(l_idx1).book_type_code := p_book_type_code;
                    l_reval_asset_params(l_idx1).period_counter := l_period_counter;
                    l_reval_asset_rules(l_idx1).new_cost := l_prof_occ_reval_periods.new_cost;
                    l_reval_asset_rules(l_idx1).current_cost :=l_prof_occ_reval_periods.current_cost;

            END IF;
           END LOOP;
        END LOOP;
        END IF;

  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '------------------------------------------------------');
        /* Get the number of professional revaluations done and intialize the structure */


        IF (l_idx1 = 0) THEN /* No catch-up required */
  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => ' No revaluation catchup periods found');

            return TRUE;
        END IF;

	/* Bug 2961656 vgadde 08-Jul-2003 Start(2) */
        IF NOT igi_iac_catchup_pkg.get_FA_Deprn_Expense(p_asset_id,
                                 p_book_type_code,
                                 l_open_period.period_counter,
                                 'RECLASS',
                                 NULL,
                                 NULL,
                                 l_fa_deprn_amount_py,
                                 l_fa_deprn_amount_cy,
                                 l_last_asset_period) THEN
  	    	igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     	p_full_path => l_path_name,
		     	p_string => '*** Error in get_FA_Deprn_Expense function');

                return FALSE;
        END IF;
	/* Bug 2961656 vgadde 08-Jul-2003 End(2) */
       /*Salavge value correction*/
                -- resreve
                OPEN c_fa_books(p_asset_id);
            	FETCH c_fa_books into   l_salvage_value,
                                        l_cost;
            	CLOSE c_fa_books;
                IF l_salvage_value <> 0 Then
  		   igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     			p_full_path => l_path_name,
		     			p_string => '+Salavge Value Correction deprn_amount_py before :' ||l_fa_deprn_amount_py);

                 -- deprn amount l_fa_deprn_amount_py
                IF NOT igi_iac_salvage_pkg.correction(p_asset_id => p_asset_id,
                                                      P_book_type_code =>p_book_type_code,
                                                      P_value=>l_fa_deprn_amount_py,
                                                      P_cost=>l_cost,
                                                      P_salvage_value=>l_salvage_value,
                                                      P_calling_program=>'RECLASS') THEN
  	    	    igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     		p_full_path => l_path_name,
		     		p_string => '+Salvage Value Correction Failed : ');

                    return false;
                END IF;

  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '+Salavge Value Correction deprn_amount_py after :' ||l_fa_deprn_amount_py );
  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '+Salavge Value Correction deprn_amount_cy before :' ||l_fa_deprn_amount_cy);


                   -- deprn l_fa_deprn_amount_cy
                   IF NOT igi_iac_salvage_pkg.correction(p_asset_id => p_asset_id,
                                                      P_book_type_code =>p_book_type_code,
                                                      P_value=>l_fa_deprn_amount_cy,
                                                      P_cost=>l_cost,
                                                      P_salvage_value=>l_salvage_value,
                                                      P_calling_program=>'RECLASS') THEN

  			igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     			p_full_path => l_path_name,
		     			p_string => '+Salvage Value Correction Failed : ');

                    return false;
                  END IF;

  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		    	 p_string => '+Salavge Value Correction deprn_amount_cy after :' ||l_fa_deprn_amount_cy);

                 END IF;
            /*salvage value correction*/

  	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '     Calling Revaluation Initialization program ');

        IF NOT igi_iac_catchup_pkg.do_reval_init_struct(l_open_period.period_counter,
                                                        l_reval_control,
                                                        l_reval_asset_params,
                                                        l_reval_input_asset,
                                                        l_reval_output_asset,
                                                        l_reval_output_asset_mvmt,
                                                        l_reval_asset_rules,
                                                        l_prev_rate_info,
                                                        l_curr_rate_info_first,
                                                        l_curr_rate_info_next,
                                                        l_curr_rate_info,
                                                        l_reval_exceptions,
                                                        l_fa_asset_info,
                                                        l_fa_deprn_amount_py, 	-- For bug 2961656
                                                        l_fa_deprn_amount_cy,	-- For bug 2961656
                                                        l_last_asset_period,	-- For bug 2961656
                                                        'RECLASS') THEN

  	      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '*** Error in catchup pkg for revaluation initialization');

            return FALSE;
        END IF;

  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     Back from Revaluation Initialization');

        FOR l_idx2 IN 1..l_idx1 LOOP

            IF (l_idx2 <> 1) THEN

                l_reval_asset := l_reval_output_asset(l_idx2 - 1);

  		  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => ' Doing depreciation catchup for the periods between revaluation');

                IF NOT igi_iac_catchup_pkg.do_deprn_catchup(l_reval_asset_params(l_idx2 - 1).period_counter +1,
                                                     l_reval_asset_params(l_idx2).period_counter  +1,
                                                     l_open_period.period_counter,
                                                     FALSE,
                                                     'RECLASS',
                                                     l_fa_deprn_amount_py, 	-- For bug 2961656
                                                     l_fa_deprn_amount_cy,	-- For bug 2961656
                                                     l_last_asset_period,	-- For bug 2961656
                                                     NULL,			-- For bug 2961656
                                                     NULL,			-- For bug 2961656
                                                     l_reval_asset ,
                                                     p_event_id => p_event_id)THEN
  			igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     			p_full_path => l_path_name,
		     			p_string => '*** Error in depreciation catchup');

                        return FALSE;
                END IF;

  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'Back from depreciation catchup');


                l_current_reval_factor := l_reval_input_asset(l_idx2).current_reval_factor;
                l_cumulative_reval_factor := l_reval_input_asset(l_idx2).cumulative_reval_factor;
                l_reval_input_asset(l_idx2) := l_reval_asset;
                l_reval_input_asset(l_idx2).current_reval_factor := l_current_reval_factor;
                l_reval_input_asset(l_idx2).cumulative_reval_factor := l_cumulative_reval_factor;
            END IF;

            IF (l_idx2 = l_idx1) THEN
                /* Last revaluation - Insert records into revaluation tables*/
       /*         SELECT igi_iac_revaluations_s.nextval
                INTO l_revaluation_id
                FROM DUAL;
                Debug(0,'Last Revaluation - Inseting into igi_iac_revaluations');
                Debug(0,'Revaluation Id :'||to_char(l_revaluation_id));



               INSERT INTO igi_iac_revaluations
                       (revaluation_id,
                        book_type_code,
                        revaluation_date,
                        revaluation_period,
                        status,
                        reval_request_id,
                        create_request_id,
                        calling_program,
                        last_update_date,
                        created_by,
                        last_update_login,
                        last_updated_by,
                        creation_date)
                VALUES (l_revaluation_id,
                        p_book_type_code,
                        sysdate,
                        l_reval_asset_params(l_idx1).period_counter,
                        'NEW',
                        NULL,
                        NULL,
                        'RECLASS',
                        sysdate,
                        l_user_id,
                        l_login_id,
                        l_user_id,
                        sysdate);

                Debug(0,'Inserting into igi_iac_reval_asset_rules');
                INSERT INTO igi_iac_reval_asset_rules
                       (revaluation_id,
                        book_type_code,
                        category_id,
                        asset_id,
                        revaluation_factor,
                        revaluation_type,
                        new_cost,
                        current_cost,
                        selected_for_reval_flag,
                        selected_for_calc_flag,
                        created_by,
                        creation_date,
                        last_update_login,
                        last_update_date,
                        last_updated_by,
                        allow_prof_update)
                VALUES (l_revaluation_id,
                        l_reval_asset_params(l_idx1).book_type_code,
                        l_reval_asset_params(l_idx1).category_id,
                        l_reval_asset_params(l_idx1).asset_id,
                        l_reval_asset_rules(l_idx1).revaluation_factor,
                        l_reval_asset_rules(l_idx1).revaluation_type,
                        l_reval_asset_rules(l_idx1).new_cost,
                        l_reval_input_asset(l_idx2).adjusted_cost,
                        'Y',
                        'N',
                        l_user_id,
                        sysdate,
                        l_login_id,
                        sysdate,
                        l_user_id,
                        NULL);*/

                        /* Last revaluation - Insert records into revaluation tables*/

  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '		Last Revaluation - Inserting into igi_iac_revaluations');


		l_rowid := NULL;
		l_revaluation_id := NULL;

                igi_iac_revaluations_pkg.insert_row
                       (l_rowid,
                       	l_revaluation_id,
                        p_book_type_code,
                        sysdate,
                        l_reval_asset_params(l_idx1).period_counter,
                        'NEW',
                        NULL,
                        NULL,
                        'ADDITION',
                        X_event_id => p_event_id);

  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '		Revaluation Id :'||to_char(l_revaluation_id));

  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '		Inserting into igi_iac_reval_asset_rules');

                l_rowid := NULL;
                igi_iac_reval_asset_rules_pkg.insert_row
                       (l_rowid,
                       	l_revaluation_id,
                        l_reval_asset_params(l_idx1).book_type_code,
                        l_reval_asset_params(l_idx1).category_id,
                        l_reval_asset_params(l_idx1).asset_id,
                        l_reval_asset_rules(l_idx1).revaluation_factor,
                        l_reval_asset_rules(l_idx1).revaluation_type,
                        l_reval_asset_rules(l_idx1).new_cost,
                        l_reval_input_asset(l_idx2).adjusted_cost,
                        'Y',
                        'N',
                        NULL);


		l_last_reval_period := l_reval_asset_params(l_idx2).period_counter;
		l_reval_asset_params(l_idx2).period_counter := l_open_period.period_counter ;
		l_reval_input_asset(l_idx2).period_counter := l_open_period.period_counter ;
		l_reval_asset_params(l_idx2).revaluation_id := l_revaluation_id;
		l_reval_asset_rules(l_idx2).revaluation_id := l_revaluation_id;

  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '		Period counter passed to Reval CRUD :'||to_char(l_open_period.period_counter ));


            END IF;

            l_reval_params.reval_control := l_reval_control(l_idx2);
            l_reval_params.reval_asset_params := l_reval_asset_params(l_idx2);
            l_reval_params.reval_input_asset := l_reval_input_asset(l_idx2);
            l_reval_params.reval_output_asset := l_reval_input_asset(l_idx2);
            l_reval_params.reval_output_asset_mvmt := l_reval_output_asset_mvmt(l_idx2);
            l_reval_params.reval_asset_rules := l_reval_asset_rules(l_idx2);
            l_reval_params.reval_prev_rate_info := l_prev_rate_info(l_idx2);
            l_reval_params.reval_curr_rate_info_first := l_curr_rate_info_first(l_idx2);
            l_reval_params.reval_curr_rate_info_next := l_curr_rate_info_next(l_idx2);
            l_reval_params.reval_asset_exceptions := l_reval_exceptions(l_idx2);
            l_reval_params.fa_asset_info := l_fa_asset_info(l_idx2);

            /* call revaluation processing function here */

  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '     Input asset balances to revaluation program');


            Debug_Asset(l_reval_input_asset(l_idx2));

            IF NOT igi_iac_reval_wrapper.do_reval_calc_asset(l_reval_params,
                                                             l_reval_asset_out) THEN
  		igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     		p_full_path => l_path_name,
		     		p_string => '*** Error in Revaluation Program');

                return FALSE;
            END IF;

            l_current_reval_factor := l_reval_output_asset(l_idx2).current_reval_factor;
            l_cumulative_reval_factor := l_reval_output_asset(l_idx2).cumulative_reval_factor;
            l_reval_output_asset(l_idx2) := l_reval_asset_out;
            l_reval_output_asset(l_idx2).current_reval_factor := l_current_reval_factor;
            l_reval_output_asset(l_idx2).cumulative_reval_factor := l_cumulative_reval_factor;

              /* Bug 2425856 vgadde 20/06/2002 Start(1) */
            BEGIN
                IF (l_idx2 = l_idx1) THEN /* Last Revaluation */
  		    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '     Last revaluation period :'||to_char(l_last_reval_period));
  		    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '     Revaluation Id :'||to_char(l_revaluation_id));


                    UPDATE igi_iac_revaluation_rates
                    SET period_counter = l_last_reval_period
                    WHERE revaluation_id =  l_revaluation_id
                    AND asset_id = p_asset_id
                    AND book_type_code = p_book_type_code;

                    IF SQL%FOUND then
  			igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     			p_full_path => l_path_name,
		     			p_string => '     Records in reval rates updated for correct period');
                    ELSE
  			igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     			p_full_path => l_path_name,
		     			p_string => '***  No record found in reval rates table to update');

                        return FALSE;
                    END IF;
                END IF;
            END;
            /* Bug 2425856 vgadde 20/06/2002 End(1) */

        END LOOP;

        IF (l_last_reval_period < l_open_period.period_counter) THEN

  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		    	 p_full_path => l_path_name,
		     	p_string => '	Doing the final catchup for depreciation');


            l_reval_asset := l_reval_output_asset(l_idx1);
            IF NOT igi_iac_catchup_pkg.do_deprn_catchup(l_last_reval_period  + 1,
                                                 l_open_period.period_counter,
                                                 l_open_period.period_counter,
                                                 TRUE,
                                                 'RECLASS',
                                                 l_fa_deprn_amount_py, 	-- For bug 2961656
                                                 l_fa_deprn_amount_cy,	-- For bug 2961656
                                                 l_last_asset_period,	-- For bug 2961656
                                                 NULL,			-- For bug 2961656
                                                 NULL,			-- For bug 2961656
                                                 l_reval_asset ,
                                                 p_event_id => p_event_id)THEN
  		igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     		p_full_path => l_path_name,
		     		p_string => '*** Error in depreciation catchup for final run'                     );

                return FALSE;
            END IF;

  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '     Output from final catchup');

            Debug_Asset(l_reval_asset);

        END IF;

        -- Code added by Venkat Gadde
        BEGIN
        UPDATE IGI_IAC_ADJUSTMENTS
        SET EVENT_ID = P_EVENT_ID
        WHERE BOOK_TYPE_CODE = P_BOOK_TYPE_CODE
        AND ASSET_ID = P_ASSET_ID
        AND PERIOD_COUNTER = l_open_period.period_counter
        AND ADJUSTMENT_ID IN (SELECT ADJUSTMENT_ID
                              FROM IGI_IAC_TRANSACTION_HEADERS
                              WHERE BOOK_TYPE_CODE = P_BOOK_TYPE_CODE
                              AND ASSET_ID = P_ASSET_ID
                              AND PERIOD_COUNTER = l_open_period.period_counter
                              AND TRANSACTION_TYPE_CODE = 'RECLASS'
                              AND EVENT_ID IS NULL);

        UPDATE IGI_IAC_TRANSACTION_HEADERS
        SET EVENT_ID = P_EVENT_ID
        WHERE BOOK_TYPE_CODE = P_BOOK_TYPE_CODE
        AND ASSET_ID = P_ASSET_ID
        AND PERIOD_COUNTER = l_open_period.period_counter
        AND TRANSACTION_TYPE_CODE = 'RECLASS'
        AND EVENT_ID IS NULL;

 	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '     Updated all reclass trasactions with event_id');
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
        END;
        -- End of code added by Venkat Gadde

        return TRUE;

        EXCEPTION
            WHEN OTHERS THEN
	  	igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
                return FALSE;


END Do_Revaluation_Catchup;


FUNCTION Do_Diff_Price_Index(p_event_id number)
Return BOOLEAN IS

      /* bug 2502128 need to update the reval rates ..only one record should have staus = 'Y'  for an asset */
     Cursor C_Reval_Rates is
      SELECT max(adjustment_id)
      FROM   igi_iac_transaction_headers ith
      WHERE  ith.book_type_code =l_asset_hdr_rec.book_type_code
      AND    ith.asset_id = l_asset_hdr_rec.asset_id
      AND    (ith.transaction_type_code = 'RECLASS' AND  ith.Transaction_sub_type ='REVALUATION');

   l_units Number;
   l_get_latest_adjustment_id number;
   l_adjustment_id_out number;
   l_transaction_type_code varchar2(50);
   l_transaction_id number ;
   l_mass_reference_id number;
   l_adjustment_status varchar2(50);
   l_path_name VARCHAR2(150);

BEGIN
   l_transaction_type_code := Null;
   l_adjustment_status := null ;
   l_path_name := g_path||'do_diff_price_index';

  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'Enter The Do different price index');

        l_get_latest_adjustment_id:=0;
        /* Create a new transaction header for RECLASS reversal of the det balances and
        create the adjustments accordingly */
        /* to do this call the same price index */
        IF Do_same_price_index(p_event_id) then
  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '+DIFF PRICE INDEX RECLASS REVERSAL SUCCESS');
        ELSE
  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'DIFFERENT PRICE INDEX RECLASS NEGATION FAILED ');

                return false;
        End IF;

        /* From the dpis to the current period to do the revalutions and professional revalutions
        call the catchup program*/
        /*revaluation program will create the entries reuiqred in det balanes and asset balances*/

        IF (DIFF_PRICE_INDEX_FLAG) AND
           (ALLOW_INDEX_REVAL_FLAG OR ALLOW_PROF_REVAL_FLAG) THEN

            IF NOT Do_Revaluation_Catchup(l_asset_hdr_rec.book_type_code,
                                 l_asset_hdr_rec.asset_id,
                                 l_asset_cat_rec_new.category_id,
                                 'RECLASS',
                                 p_event_id => p_event_id)THEN

  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'FAILED TO DO DIFFERENT PRICE INDEX RECLASSIFICATION');

                return false;
            End IF;
        END IF;

            /* bug 2502128 need to update the reval rates ..only one record should have staus = 'Y'  for an asset */
            OPEN C_Reval_Rates;
            FETCH C_Reval_Rates into l_get_latest_adjustment_id;
            CLOSE C_Reval_Rates;
            IF NOT  IGI_IAC_REVAL_CRUD.update_reval_rates (fp_adjustment_id =>  l_get_latest_adjustment_id) THEN
  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'FAILED UPDATE REVAL RATES');
             END IF;

  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'SUCESSFULL DIFF PRICE INDEX');

         return True;
END;-- do diff price index




-- ======================================================================
-- PRINT PARAMETER VALUES
-- ======================================================================
/*=========================================================================+*/
PROCEDURE Print_Parameter_values is
  	l_path_name VARCHAR2(150);
BEGIN
  	l_path_name := g_path||'print_parameter_values';
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '+PARAMTER VALUES RECEIVED TO Do_RECLASS');
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     +ASSET_TRANS_HDR_REC');
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +TRANSACTION_HEADER_ID.......... '||l_trans_rec.TRANSACTION_HEADER_ID );
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +TRANSACTION_TYPE_CODE.......... '||l_trans_rec.TRANSACTION_TYPE_CODE );
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +TRANSACTION_DATE_ENTERED....... '||l_trans_rec.TRANSACTION_DATE_ENTERED );
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +TRANSACTION_NAME............... '||l_trans_rec.TRANSACTION_NAME);
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +SOURCE_TRANSACTION_HEADER_ID... '||l_trans_rec.SOURCE_TRANSACTION_HEADER_ID);
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +MASS_REFERENCE_ID.............. '|| l_trans_rec.MASS_REFERENCE_ID);
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +TRANSACTION_SUBTYPE............ '|| l_trans_rec.TRANSACTION_SUBTYPE);
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +TRANSACTION_KEY................ '|| l_trans_rec.TRANSACTION_KEY);
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +AMORTIZATION_START_DATE........ '||l_trans_rec.AMORTIZATION_START_DATE);
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +CALLING_INTERFACE.............. '||l_trans_rec.CALLING_INTERFACE);
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +MASS_TRANSACTION_ID............ '||l_trans_rec.MASS_TRANSACTION_ID);
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     +ASSET_HDR_REC');
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +ASSET_ID....................... '|| l_asset_hdr_rec.ASSET_ID );
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +BOOK_TYPE_CODE................. '|| l_asset_hdr_rec.BOOK_TYPE_CODE );
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +SET_OF_BOOKS_ID................ '|| l_asset_hdr_rec.SET_OF_BOOKS_ID);
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +PERIOD_OF_ADDITION............. '||l_asset_hdr_rec.PERIOD_OF_ADDITION);
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     +ASSET_CAT_REC_OLD');
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +CATEGORY_ID.................... '|| l_asset_cat_rec_old.category_id);
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     +ASSET_CAT_REC_NEW');
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +CATEGORY_ID.................... '|| l_asset_cat_rec_new.category_id);
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     +ASSET_TYPE_REC');
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         +ASSET_TYPE..................... '|| l_asset_type_rec.asset_type );
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     +CALLING FUNCTION................... ' || l_calling_function);
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '+PARAMTER VALUES RECEIVED TO Do_RECLASS');
END;




-- ======================================================================
-- RECLASS
-- ======================================================================
/*=========================================================================+
 | Function Name:                                                          |
 |    Do_Reclass                                                           |
 |                                                                         |
 | Description:                                                            |
 |    This IAC hook function is to process reclassification for IAC and    |
 |    called from Reclass API(FA_RECLASS_PUB.Do_Reclass).                  |
 |                                                                         |
 +=========================================================================*/

FUNCTION Do_Reclass(
   p_trans_rec                      FA_API_TYPES.trans_rec_type,
   p_asset_hdr_rec                  FA_API_TYPES.asset_hdr_rec_type,
   p_asset_cat_rec_old              FA_API_TYPES.asset_cat_rec_type,
   p_asset_cat_rec_new              FA_API_TYPES.asset_cat_rec_type,
   p_asset_desc_rec                 FA_API_TYPES.asset_desc_rec_type,
   p_asset_type_rec                 FA_API_TYPES.asset_type_rec_type,
   p_calling_function               VARCHAR2,
   p_event_id                       number  --R12 uptake
) return BOOLEAN is

  l_old_price_index igi_iac_category_books.price_index_id%type;
  l_new_price_index igi_iac_category_books.price_index_id%type;

  -- cursor to get the price index of the asset
  Cursor get_price_index(c_category_id number) is
  SELECT price_index_id
  FROM igi_iac_category_books
  WHERE book_type_code = l_asset_hdr_rec.book_type_code
  AND category_id = c_category_id;


    l_set_of_books_id		Number;
    l_chart_of_accounts_id  Number;
    l_currency				Varchar2(5);
    l_precision 			Number;
    l_prd_rec               igi_iac_types.prd_rec;
    l_path_name VARCHAR2(150);

BEGIN
    l_set_of_books_id		:=0;
    l_chart_of_accounts_id  :=0;
    l_precision 			:=0;
    l_path_name := g_path||'do_reclass';

       /* igi_iac_debug_pkg.debug_on('RECLASS');
        igi_iac_debug_pkg.debug(0,'Creating a message log file for RECLASS');
        igi_iac_debug_pkg.debug(0,'Date '||sysdate);
        igi_iac_debug_pkg.debug(0,'Calling function '||p_calling_function);
        igi_iac_debug_pkg.debug(0,'Entry for IAC reclass');*/
     --
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'Creating a message log file for RECLASS');
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'Date '||sysdate);
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'Calling function '||p_calling_function);
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'Entry for IAC reclass');

     --validate the IAC book
        IF Not (igi_iac_common_utils.is_iac_book(p_asset_hdr_rec.book_type_code)) THEN
  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'Not an IAC book ..'||p_asset_hdr_rec.book_type_code);

                Return True;
        End if;

	IF NOT igi_iac_common_utils.populate_iac_fa_deprn_data(p_asset_hdr_rec.book_type_code,
	    							  'RECLASS') THEN
  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '*** Error in Synchronizing Depreciation Data ***');

		return FALSE;
	END IF;


        -- assign the parameters to local vlaues;
        l_trans_rec :=p_trans_rec;
        l_asset_hdr_rec := p_asset_hdr_rec;
        l_asset_cat_rec_old :=p_asset_cat_rec_old;
        l_asset_cat_rec_new :=p_asset_cat_rec_new;
        l_asset_desc_rec:= p_asset_desc_rec;
        l_asset_type_rec:= p_asset_type_rec;
        l_calling_function  := p_calling_function;

        Print_Parameter_values;

        /* return ture if the reclass being done in the same period asset added */
        IF l_asset_hdr_rec.PERIOD_OF_ADDITION = 'Y' THEN
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'RECLASS in the same period as asset Added');

            Return True;
       END IF;

        --set the default vlaues missing
        -- set of books id
        IF l_asset_hdr_rec.set_of_books_id is null then
            IF NOT igi_iac_common_utils.get_book_gl_info (l_asset_hdr_rec.book_type_code,
						l_set_of_books_id,
						l_chart_of_accounts_id,
    					l_currency,
        				l_precision ) THEN
  		  igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     		p_full_path => l_path_name,
		     		p_string => '+Set of books Failed');
                  FA_SRVR_MSG.Add_Message(
                          CALLING_FN => p_calling_function,
                          NAME => 'IGI_IAC_NO_SET_OF_BOOKS_INFO',
                          TRANSLATE => TRUE,
                          APPLICATION => 'IGI');
                  Return False;
             END IF;

  	     igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '+Set of books value is set to ....'|| l_set_of_books_id);

             l_asset_hdr_rec.set_of_books_id := l_set_of_books_id;
          END IF;

      -- validate the category
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '+Validate categories');
        IF not do_validate_category THEN
  		  igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     		p_full_path => l_path_name,
		     		p_string => '+Failed Validate categories');
                  FA_SRVR_MSG.Add_Message(
                       CALLING_FN => p_calling_function,
                       NAME => 'IGI_IAC_CATEGORY_VALIDATION',
                       TRANSLATE => TRUE,
                       APPLICATION => 'IGI');
                 Return False;
        END IF;

  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '+Validate categories successful');

      -- validate the asset
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '+Validate Asset');

        IF NOT do_validate_asset THEN
  		igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     		p_full_path => l_path_name,
		     		p_string => '+Failed Validate Asset');

                 FA_SRVR_MSG.Add_Message(
                       CALLING_FN =>p_calling_function ,
                       NAME => 'IGI_IAC_ASSET_VALIDATION',
                       TRANSLATE => TRUE,
                       APPLICATION => 'IGI');
                 Return TRUE;
        END IF;

  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '+Validate Asset successfully');

       -- Check whether adjustments exist in the open period
       -- If Adjustments exists then stop the Reclassification
       IF IGI_IAC_COMMON_UTILS.Is_Asset_Adjustment_Done(l_asset_hdr_rec.book_type_code,
                                    l_asset_hdr_rec.asset_id) THEN

            FA_SRVR_MSG.Add_Message(
	                Calling_FN 	=> l_calling_function ,
        	        Name 		=> 'IGI_IAC_ADJUSTMENT_EXCEPTION',
        	        TRANSLATE => TRUE,
                    APPLICATION => 'IGI');

            RETURN FALSE;
       END IF;
    -- compare the price indexes of the categories
    -- get the old price index
    Open get_price_index(l_asset_cat_rec_old.category_id);
    Fetch get_price_index into l_old_price_index;
    Close get_price_index;

    -- get the price index for new category
    Open get_price_index(l_asset_cat_rec_new.category_id);
    Fetch get_price_index into l_new_price_index;
    Close get_price_index;

    -- compare and call the reclass accordingly
    -- bug 3356588
    IF (ALLOW_INDEX_REVAL_FLAG) THEN

       IF l_old_price_index = l_new_Price_index THEN

           -- call the same price index
  	   igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '+SAME PRICE INDEX');


           SAME_PRICE_INDEX_FLAG := TRUE;
           DIFF_PRICE_INDEX_FLAG:= FALSE;
           IF do_same_price_index(p_event_id) THEN
  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '+SAME PRICE INDEX SUCCESS');
            ELSE
  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'SAME PRICE INDEX IAC RECLASSIFICATION FAILED');

                FA_SRVR_MSG.Add_Message(
                       CALLING_FN =>p_calling_function ,
                       NAME => 'IGI_IAC_SAME_PRICE_FAILED',
                       TRANSLATE => TRUE,
                       APPLICATION =>'IGI');
                return false;
           end if; -- do_same_price_index
           --        Null;
       ELSE
           SAME_PRICE_INDEX_FLAG := FALSE;
           DIFF_PRICE_INDEX_FLAG:= TRUE;
           IF Do_Diff_Price_Index(p_event_id => p_event_id) THEN
               -- call the different price index
  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '+DIFFERENT PRICE INDEX');

                return True;
           ELSE
  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '+DIFFERENT PRICE INDEX RETURNED FALSE');
                return false;
           END IF;
       END IF;
   ELSE -- ALLOW_INDEX_REVAL_FALG is off
      -- call do_no_index_reval function that processes the asset when
      -- the category has indexed revaluation switched off
      IF Do_No_Index_Reval(p_event_id => p_event_id) THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   END IF;
   Return TRUE;

END;
BEGIN
    debug_reclass := FALSE;
    l_debug_print := FALSE;

    -- global vlaue for allow reval index and prof flag
    ALLOW_INDEX_REVAL_FLAG := FALSE;
    ALLOW_PROF_REVAL_FLAG  := FALSE;
    SAME_PRICE_INDEX_FLAG  := FALSE;
    DIFF_PRICE_INDEX_FLAG  := FALSE;

    l_calling_function := 'FA_RECLASS_PVT.do_reclass';
    chr_newline  := fnd_global.newline;

    --===========================FND_LOG.START=====================================
    g_state_level :=	FND_LOG.LEVEL_STATEMENT;
    g_proc_level  :=	FND_LOG.LEVEL_PROCEDURE;
    g_event_level :=	FND_LOG.LEVEL_EVENT;
    g_excep_level :=	FND_LOG.LEVEL_EXCEPTION;
    g_error_level :=	FND_LOG.LEVEL_ERROR;
    g_unexp_level :=	FND_LOG.LEVEL_UNEXPECTED;
    g_path        := 'IGI.PLSQL.igiiarlb.igi_iac_reclass_pkg.';
    --===========================FND_LOG.END=====================================


END; --reclass package

/
