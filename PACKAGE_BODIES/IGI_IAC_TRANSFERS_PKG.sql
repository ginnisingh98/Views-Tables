--------------------------------------------------------
--  DDL for Package Body IGI_IAC_TRANSFERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_TRANSFERS_PKG" AS
--  $Header: igiiatfb.pls 120.25.12010000.3 2010/06/25 05:00:19 schakkin ship $


 --===========================FND_LOG.START=====================================

 g_state_level NUMBER;
 g_proc_level  NUMBER;
 g_event_level NUMBER;
 g_excep_level NUMBER;
 g_error_level NUMBER;
 g_unexp_level NUMBER;
 g_path        VARCHAR2(100);

 --===========================FND_LOG.END=======================================

 -- package level variables
 p_trans_rec        FA_API_TYPES.trans_rec_type;
 p_asset_hdr_rec    FA_API_TYPES.asset_hdr_rec_type;
 p_asset_cat_rec    FA_API_TYPES.asset_cat_rec_type;

 g_prior_period     BOOLEAN;

 -- define asset rec type
 TYPE asset_rec_type IS RECORD (asset_id                NUMBER,
                                book_type_code          VARCHAR2(15),
                                period_counter          NUMBER,
                                net_book_value          NUMBER,
                                adjusted_cost           NUMBER,
                                operating_acct          NUMBER,
                                reval_reserve           NUMBER,
                                deprn_amount            NUMBER,
                                deprn_reserve           NUMBER,
                                backlog_deprn_reserve   NUMBER,
                                general_fund            NUMBER,
                                last_reval_date         DATE,
                                current_reval_factor    NUMBER,
                                cumulative_reval_factor NUMBER,
                                reval_reserve_backlog   NUMBER,
                                operating_acct_backlog  NUMBER,
                                general_fund_per        NUMBER,
                                ytd_deprn               NUMBER,
                                dep_expense_catchup     NUMBER,
                                op_expense_catchup      NUMBER
                               );

 TYPE iac_fa_deprn_rec_type IS RECORD (asset_id                NUMBER,
                                       book_type_code          VARCHAR2(15),
                                       period_counter          NUMBER,
                                       deprn_period            NUMBER,
                                       deprn_reserve           NUMBER,
                                       deprn_ytd               NUMBER,
                                       dep_expense_catchup     NUMBER
                                      );

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

-- ===============================================================================
--	Procedure to insert data into IGI_IAC_ADJUSTMENTS
-- ===============================================================================
 PROCEDURE  insert_data_adj(p_adjustment_id 	  in igi_iac_adjustments.adjustment_id%type,
                            p_book_type_code      in igi_iac_adjustments.book_type_code%type,
                            p_code_combination_id in igi_iac_adjustments.code_combination_id%type,
                            p_set_of_books_id     in igi_iac_adjustments.set_of_books_id%type,
                            p_dr_cr_flag          in igi_iac_adjustments.dr_cr_flag%type,
                            p_amount              in igi_iac_adjustments.amount%type,
                            p_adjustment_type     in igi_iac_adjustments.adjustment_type%type,
                            p_units_assigned      in igi_iac_adjustments.units_assigned%type,
                            p_asset_id            in igi_iac_adjustments.asset_id%type,
                            p_distribution_id     in igi_iac_adjustments.distribution_id%type,
                            p_period_counter      in igi_iac_adjustments.period_counter%type,
                            p_adj_offset_type     IN igi_iac_adjustments.adjustment_offset_type%TYPE,
                            p_report_ccid         IN igi_iac_adjustments.report_ccid%TYPE,
                            p_event_id            IN number
                           )
 IS
	l_rowid ROWID;

	l_mesg	VARCHAR2(500);
	l_path varchar2(150);
    BEGIN

       l_path := g_path||'insert_data_adj';

       IF  p_amount <> 0 THEN
          -- Call to TBH for insert into IGI_IAC_ADJUSTMENTS
          IGI_IAC_ADJUSTMENTS_PKG.insert_row(
    			x_rowid                             =>l_rowid,
    			x_adjustment_id                     =>p_adjustment_id,
    			x_book_type_code                    =>p_book_type_code,
    			x_code_combination_id               =>p_code_combination_id,
    			x_set_of_books_id                   =>p_set_of_books_id,
    			x_dr_cr_flag                        =>p_dr_cr_flag,
    			x_amount                            =>p_amount,
    			x_adjustment_type                   =>p_adjustment_type,
    			x_adjustment_offset_type            =>p_adj_offset_type,
    			x_transfer_to_gl_flag               =>'Y',
    			x_units_assigned                    =>p_units_assigned,
    			x_asset_id                          =>p_asset_id,
    			x_distribution_id                   =>p_distribution_id,
    			x_period_counter                    =>p_period_counter,
                x_report_ccid                       =>p_report_ccid,
    			x_mode                              =>'R',
    			x_event_id                          => p_event_id
                                               );

        END IF;

   EXCEPTION
    	WHEN OTHERS THEN
    	l_mesg:=SQLERRM;
        igi_iac_debug_pkg.debug_unexpected_msg(l_path);
    	FA_SRVR_MSG.Add_Message(
	                Calling_FN 	=> 'IGI_IAC_TRANSFER_PKG.Do_Transfer',
        	        Name 		=> 'IGI_IAC_EXCEPTION',
        	        TOKEN1		=> 'PACKAGE',
        	        VALUE1		=> 'Transfers',
        	        TOKEN2		=> 'ERROR_MESSAGE',
        	        VALUE2		=> l_mesg);
        ROLLBACK;
 END insert_data_adj;

-- ===============================================================================
--	Procedure to insert data into IGI_IAC_DET_BALANCES
-- ===============================================================================
   PROCEDURE insert_data_det(p_adjustment_id            in IGI_IAC_DET_BALANCES.adjustment_id%type,
                             p_asset_id                 in IGI_IAC_DET_BALANCES.asset_id%type,
                             p_distribution_id          in IGI_IAC_DET_BALANCES.distribution_id%type,
                             p_period_counter           in IGI_IAC_DET_BALANCES.period_counter%type,
                             p_book_type_code           in IGI_IAC_DET_BALANCES.book_type_code%type,
                             p_adjusted_cost            in IGI_IAC_DET_BALANCES.adjustment_cost%type,
                             p_net_book_value           in IGI_IAC_DET_BALANCES.net_book_value%type,
                             p_reval_reserve            in IGI_IAC_DET_BALANCES.reval_reserve_cost%type,
                             p_reval_reserve_gen_fund   in IGI_IAC_DET_BALANCES.reval_reserve_gen_fund%type,
                             p_reval_reserve_backlog	in IGI_IAC_DET_BALANCES.reval_reserve_backlog%type,
                             p_op_acct                  in IGI_IAC_DET_BALANCES.operating_acct_cost%type,
                             p_deprn_reserve            in IGI_IAC_DET_BALANCES.deprn_reserve%type,
                             p_deprn_reserve_backlog 	in IGI_IAC_DET_BALANCES.deprn_reserve_backlog%type,
                             p_deprn_ytd                in IGI_IAC_DET_BALANCES.deprn_ytd%type,
                             p_deprn_period             in IGI_IAC_DET_BALANCES.deprn_period%type,
                             p_gen_fund_acc             in IGI_IAC_DET_BALANCES.general_fund_acc%type,
                             p_gen_fund_per             in IGI_IAC_DET_BALANCES.general_fund_acc%type,
                             p_current_reval_factor     in IGI_IAC_DET_BALANCES.current_reval_factor%type,
                             p_cumulative_reval_factor  in IGI_IAC_DET_BALANCES.cumulative_reval_factor%type,
                             p_reval_flag               in IGI_IAC_DET_BALANCES.active_flag%type,
                             p_op_acct_ytd              in IGI_IAC_DET_BALANCES.operating_acct_ytd%type,
                             p_operating_acct_backlog   in IGI_IAC_DET_BALANCES.operating_acct_backlog%type,
                             p_last_reval_date          in IGI_IAC_DET_BALANCES.last_reval_date%type
    			             )
   IS

      l_rowid   VARCHAR2(25);
      l_mesg    VARCHAR2(500);
      l_path    varchar2(150);
   BEGIN

      l_path    := g_path||'insert_data_det';

      -- Call to TBH for insert into IGI_IAC_DET_BALANCES
      IGI_IAC_DET_BALANCES_PKG.insert_row(
                    x_rowid                     =>l_rowid,
                    x_adjustment_id             =>p_adjustment_id,
                    x_asset_id                  =>p_asset_id,
                    x_distribution_id           =>p_distribution_id,
                    x_book_type_code            =>p_book_type_code,
                    x_period_counter            =>p_period_counter,
                    x_adjustment_cost           =>p_adjusted_cost,
                    x_net_book_value            =>p_net_book_value,
                    x_reval_reserve_cost        =>(p_reval_reserve+p_reval_reserve_backlog+p_reval_reserve_gen_fund),
                    x_reval_reserve_backlog     =>p_reval_reserve_backlog,
                    x_reval_reserve_gen_fund    =>p_reval_reserve_gen_fund,
                    x_reval_reserve_net         =>p_reval_reserve,
                    x_operating_acct_cost       =>(p_op_acct+p_operating_acct_backlog),
                    x_operating_acct_backlog    =>p_operating_acct_backlog,
                    x_operating_acct_net       	=>p_op_acct,
                    x_operating_acct_ytd     	=>p_op_acct_ytd,
                    x_deprn_period              =>p_deprn_period,
                    x_deprn_ytd                 =>p_deprn_ytd,
                    x_deprn_reserve             =>p_deprn_reserve,
                    x_deprn_reserve_backlog     =>p_deprn_reserve_backlog,
                    x_general_fund_per          =>p_gen_fund_per,
                    x_general_fund_acc          =>p_gen_fund_acc,
                    x_last_reval_date           =>p_last_reval_date,
                    x_current_reval_factor      =>p_current_reval_factor,
                    x_cumulative_reval_factor   =>p_cumulative_reval_factor,
                    x_active_flag               =>p_reval_flag,
                    x_mode                      =>'R'
    						                  );

   EXCEPTION
    	WHEN OTHERS THEN
    	l_mesg:=SQLERRM;
     	FA_SRVR_MSG.Add_Message(
	                Calling_FN 	=> 'IGI_IAC_TRANSFER_PKG.Do_Transfer',
        	        Name 		=> 'IGI_IAC_EXCEPTION',
        	        TOKEN1		=> 'PACKAGE',
        	        VALUE1		=> 'Transfers',
        	        TOKEN2		=> 'ERROR_MESSAGE',
        	        VALUE2		=> l_mesg);
        igi_iac_debug_pkg.debug_unexpected_msg(l_path);
        rollback;
  END insert_data_det;

-- ===============================================================================+
--	Procedure to prorate the amounts based on the units assigned		|
-- ================================================================================+
  PROCEDURE Prorate_amount_for_dist(
                                      p_dist_id             IN fa_distribution_history.distribution_id%TYPE,
                                      p_units_dist          IN fa_distribution_history.units_assigned%TYPE,
                                      p_units_total         IN NUMBER,
                                      p_ab_amounts          IN  asset_rec_type,
                                      p_reval_reserve       out NOCOPY number,
                                      p_general_fund        out NOCOPY number,
                                      P_backlog_deprn       out NOCOPY number,
                                      P_deprn_reserve       out NOCOPY number,
                                      P_adjusted_cost       out NOCOPY number,
                                      P_net_book_value      out NOCOPY number,
                                      P_deprn_per           out NOCOPY number,
                                      P_op_acct             out NOCOPY number,
                                      p_ytd_deprn           out NOCOPY number,
                                      p_op_acct_ytd         out NOCOPY number,
                                      p_rr_blog             out NOCOPY number,
                                      p_op_blog             out NOCOPY number,
                                      p_gf_per              out NOCOPY number
			                          )
 IS

	prorate_factor 	number;
    l_book_type_code FA_DISTRIBUTION_HISTORY.BOOK_TYPE_CODE%TYPE;
	l_mesg		VARCHAR2(500);

    l_path varchar2(150);
 BEGIN

    l_path := g_path||'Prorate_amount_for_dist';
    select book_type_code into l_book_type_code from FA_DISTRIBUTION_HISTORY
    where DISTRIBUTION_ID=p_dist_id;

 -- Prorate the various amounts between for the given distribution
	prorate_factor   := p_units_dist/p_units_total;
	igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'prorate_factor: ' || prorate_factor);
	p_reval_reserve  := p_ab_amounts.reval_reserve* Prorate_factor  ;
    do_round(p_reval_reserve,l_book_type_code);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_reval_reserve: ' || p_reval_reserve);
    P_general_fund   := P_ab_amounts.general_fund * Prorate_factor ;
    do_round(P_general_fund,l_book_type_code);
	igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'P_general_fund: ' || P_general_fund);
	P_backlog_deprn  := p_ab_amounts.backlog_deprn_reserve* Prorate_factor ;
	do_round(P_backlog_deprn,l_book_type_code);
	igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'P_backlog_deprn: ' || P_backlog_deprn);
	P_deprn_reserve  := p_ab_amounts.deprn_reserve* Prorate_factor ;
	do_round(P_deprn_reserve,l_book_type_code);
	igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'P_deprn_reserve: ' || P_deprn_reserve);
	P_adjusted_cost  := p_ab_amounts.adjusted_cost* Prorate_factor ;
	do_round(P_adjusted_cost,l_book_type_code);
	igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'P_adjusted_cost: ' || P_adjusted_cost);
	P_net_book_value := p_ab_amounts.net_book_value* Prorate_factor  ;
	do_round(P_net_book_value,l_book_type_code);
	igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'P_net_book_value: ' || P_net_book_value);
	P_deprn_per      := p_ab_amounts.deprn_amount* Prorate_factor;
	do_round(P_deprn_per,l_book_type_code);
	igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'P_deprn_per: ' || P_deprn_per);
	P_op_acct        := p_ab_amounts.operating_acct*Prorate_factor;
	do_round(P_op_acct,l_book_type_code);
	igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'P_op_acct: ' || P_op_acct);
	P_ytd_deprn      := p_ab_amounts.ytd_deprn*Prorate_factor;
	do_round(P_ytd_deprn,l_book_type_code);
	igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'P_ytd_deprn: ' || P_ytd_deprn);
	P_op_acct_ytd    := 0; --p_ab_op_acct_ytd*Prorate_factor;
	igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'P_op_acct_ytd: ' || P_op_acct_ytd);

    p_rr_blog        := p_ab_amounts.reval_reserve_backlog*Prorate_factor;
    do_round(p_rr_blog,l_book_type_code);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_rr_blog: ' || p_rr_blog);
    p_op_blog        := p_ab_amounts.operating_acct_backlog*Prorate_factor;
    do_round(p_op_blog,l_book_type_code);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_op_blog: ' || p_op_blog);
    p_gf_per         := p_ab_amounts.general_fund_per*Prorate_factor;
    do_round(p_gf_per,l_book_type_code);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_gf_per: ' || p_gf_per);

    EXCEPTION
      WHEN OTHERS THEN
    	l_mesg:=SQLERRM;
	    P_reval_reserve  :=  0;
	    P_general_fund   :=  0;
	    P_backlog_deprn  :=  0;
	    P_deprn_reserve  :=  0;
	    P_adjusted_cost  :=  0;
	    P_net_book_value :=  0;
	    P_deprn_per      :=  0;
	    P_op_acct	     :=  0;
	    p_ytd_deprn	     :=  0;
	    p_op_acct_ytd    :=  0;

        p_rr_blog     :=  0;
        p_op_blog     :=  0;
        p_gf_per      :=  0;

        igi_iac_debug_pkg.debug_unexpected_msg(l_path);
    	FA_SRVR_MSG.Add_Message(
	                Calling_FN 	=> 'IGI_IAC_TRANSFER_PKG.Do_Transfer',
        	        Name 		=> 'IGI_IAC_EXCEPTION',
        	        TOKEN1		=> 'PACKAGE',
        	        VALUE1		=> 'Transfers',
        	        TOKEN2		=> 'ERROR_MESSAGE',
        	        VALUE2		=> l_mesg);

 END prorate_amount_for_dist;

-- ===============================================================================
--	Procedure to prorate the amounts based on the units assigned
-- ===============================================================================
  PROCEDURE Prorate_amount_for_fa_dist(P_dist_id       in FA_DISTRIBUTION_HISTORY.DISTRIBUTION_ID%type,
                                       P_units_dist    in number,
                                       P_units_total   in number,
                                       P_ab_amounts    IN iac_fa_deprn_rec_type,
                                       P_deprn_period  OUT NOCOPY number,
                                       P_deprn_ytd     OUT NOCOPY number,
                                       P_deprn_reserve OUT NOCOPY number
                                       )
  IS

	l_prorate_factor        number;
	l_mesg                  VARCHAR2(500);
	P_deprn_period_old      number;
	P_deprn_ytd_old         number;
	P_deprn_reserve_old     number;
    l_book_type_code FA_DISTRIBUTION_HISTORY.BOOK_TYPE_CODE%TYPE;

    l_path varchar2(150);
  BEGIN

        l_path := g_path||'Prorate_amount_for_fa_dist';
    select book_type_code into l_book_type_code from FA_DISTRIBUTION_HISTORY
    where DISTRIBUTION_ID=p_dist_id;

        P_deprn_period_old      := P_ab_amounts.deprn_period;
	P_deprn_ytd_old         := P_ab_amounts.deprn_ytd;
	P_deprn_reserve_old     := P_ab_amounts.deprn_reserve;

	-- Prorate the various amounts between for the given distribution

	l_Prorate_factor        := p_units_dist/p_units_total;
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_Prorate_factor: ' || l_Prorate_factor);
	P_deprn_period          := P_ab_amounts.deprn_period * l_Prorate_factor  ;
    do_round(P_deprn_period,l_book_type_code);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'P_deprn_period: ' || P_deprn_period);
	P_deprn_ytd             := P_ab_amounts.deprn_ytd * l_Prorate_factor ;
    do_round(P_deprn_ytd,l_book_type_code);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'P_deprn_ytd: ' || P_deprn_ytd);
	P_deprn_reserve         := P_ab_amounts.deprn_reserve * l_Prorate_factor ;
    do_round(P_deprn_reserve,l_book_type_code);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'P_deprn_reserve: ' || P_deprn_reserve);

    EXCEPTION
    	WHEN OTHERS THEN
    	l_mesg:=SQLERRM;

    	-- reverting back to old values.
    	P_deprn_period      := P_deprn_period_old;
        P_deprn_ytd         := P_deprn_ytd_old;
        P_deprn_reserve     := P_deprn_reserve_old;

        igi_iac_debug_pkg.debug_unexpected_msg(l_path);

    	FA_SRVR_MSG.Add_Message(
	                Calling_FN 	=> 'IGI_IAC_TRANSFER_PKG.Do_Transfer',
        	        Name 		=> 'IGI_IAC_EXCEPTION',
        	        TOKEN1		=> 'PACKAGE',
        	        VALUE1		=> 'Transfers',
        	        TOKEN2		=> 'ERROR_MESSAGE',
        	        VALUE2		=> l_mesg);

  END prorate_amount_for_fa_dist;

-- ===============================================================================
-- PROCEDURE Prorate_Catchup_Amounts: Procedure for prorating catchup amounts like
-- deprn_expense and op_expense
-- ===============================================================================
  PROCEDURE Prorate_Catchup_Amounts(p_dist_id             IN fa_distribution_history.distribution_id%TYPE,
                                    p_units_dist          IN fa_distribution_history.units_assigned%TYPE,
                                    p_transfer_units      IN NUMBER,
                                    p_ab_dep_exp          IN NUMBER,
                                    p_ab_op_exp           IN NUMBER,
                                    p_fa_ab_dep_exp       IN NUMBER,
                                    p_dist_dep_exp        OUT NOCOPY NUMBER,
                                    p_dist_op_exp         OUT NOCOPY NUMBER,
                                    p_fa_dist_dep_exp     OUT NOCOPY NUMBER
                                   )
 IS

	prorate_factor 	number;
    l_book_type_code FA_DISTRIBUTION_HISTORY.BOOK_TYPE_CODE%TYPE;
	l_mesg		VARCHAR2(500);

    l_path varchar2(150);
 BEGIN

    l_path := g_path||'Prorate_amount_for_dist';
    select book_type_code into l_book_type_code from FA_DISTRIBUTION_HISTORY
    where DISTRIBUTION_ID=p_dist_id;

    -- Prorate the various amounts between for the given distribution
	prorate_factor   := p_units_dist/p_transfer_units;
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'prorate_factor :'||prorate_factor);

    p_dist_dep_exp  := 0;
    p_dist_op_exp   := 0;
    p_fa_dist_dep_exp := 0;

    IF g_prior_period THEN
       p_dist_dep_exp  := p_ab_dep_exp*Prorate_factor;
       do_round(p_dist_dep_exp,l_book_type_code);
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_dist_dep_exp :'||p_dist_dep_exp);
       p_dist_op_exp   := p_ab_op_exp*Prorate_factor;
       do_round(p_dist_op_exp,l_book_type_code);
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_dist_op_exp :'||p_dist_op_exp);
       p_fa_dist_dep_exp  := p_fa_ab_dep_exp*Prorate_factor;
       do_round(p_fa_dist_dep_exp,l_book_type_code);
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_fa_dist_dep_exp :'||p_fa_dist_dep_exp);
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
    	l_mesg:=SQLERRM;
        igi_iac_debug_pkg.debug_unexpected_msg(l_path);
    	FA_SRVR_MSG.Add_Message(
	                Calling_FN 	=> 'IGI_IAC_TRANSFER_PKG.Do_Transfer',
        	        Name 		=> 'IGI_IAC_EXCEPTION',
        	        TOKEN1		=> 'PACKAGE',
        	        VALUE1		=> 'Transfers',
        	        TOKEN2		=> 'ERROR_MESSAGE',
        	        VALUE2		=> l_mesg);

 END Prorate_Catchup_Amounts;

-- ===============================================================================
--	Procedure to find the distribution ccid's for various types of accounts
-- ===============================================================================
 PROCEDURE find_ccid(p_book_type_code         in FA_BOOKS.book_type_code%TYPE,
                     p_asset_id               in FA_BOOKS.asset_id%TYPE,
                     p_transaction_header_id  in FA_DISTRIBUTION_HISTORY.transaction_header_id_in%TYPE,
                     p_dist_id 	 		      in number,
                     p_reval_ccid             out NOCOPY number,
                     p_Gen_fund_ccid	      out NOCOPY number,
                     p_Backlog_ccid           out NOCOPY number,
                     p_deprn_ccid             out NOCOPY number,
                     p_cost_ccid              out NOCOPY number,
                     p_op_expense_ccid        out NOCOPY NUMBER,
                     p_expense_ccid           out NOCOPY NUMBER
                    )
 IS
       l_return_value 	BOOLEAN;
       l_mesg		VARCHAR2(500);
       l_path varchar2(150);
 BEGIN

    l_path := g_path||'find_ccid';

    -- For reval reserve  get the ccid into p_reval_ccid
    l_return_value:=IGI_IAC_COMMON_UTILS.get_account_ccid(p_book_type_code,
                                                          p_asset_id,
                                                          p_dist_id,
                                                          'REVAL_RESERVE_ACCT',
                                                          p_transaction_header_id,
                                                          'TRANSFER',
                                                          p_reval_ccid);


    -- For general fund  get the ccid into p_gen_fund_ccid
	l_return_value:=IGI_IAC_COMMON_UTILS.get_account_ccid(p_book_type_code,
                                                          p_asset_id,
                                                          p_dist_id,
                                                          'GENERAL_FUND_ACCT',
                                                          p_transaction_header_id,
                                                          'TRANSFER',
                                                          p_Gen_fund_ccid);

    -- For backlog deprn reserve  get the ccid into p_backlog_ccid
    l_return_value:=IGI_IAC_COMMON_UTILS.get_account_ccid(p_book_type_code,
                                                          p_asset_id,
                                                          p_dist_id,
                                                          'BACKLOG_DEPRN_RSV_ACCT',
                                                          p_transaction_header_id,
                                                          'TRANSFER',
                                                          p_backlog_ccid);

    -- For deprn reserve  get the ccid into p_deprn_ccid
    l_return_value:=IGI_IAC_COMMON_UTILS.get_account_ccid(p_book_type_code,
                                                          p_asset_id,
                                                          p_dist_id,
                                                          'DEPRN_RESERVE_ACCT',
                                                          p_transaction_header_id,
                                                          'TRANSFER',
                                                          p_deprn_ccid);

    -- For asset cost  get the ccid into p_cost_ccid
    l_return_value:=IGI_IAC_COMMON_UTILS.get_account_ccid(p_book_type_code,
                                                          p_asset_id,
                                                          p_dist_id,
                                                          'ASSET_COST_ACCT',
                                                          p_transaction_header_id,
                                                          'TRANSFER',
                                                          p_cost_ccid);

    -- For operating expense get the ccid into p_op_expense_ccid
    l_return_value:=IGI_IAC_COMMON_UTILS.get_account_ccid(p_book_type_code,
                                                          p_asset_id,
                                                          p_dist_id,
                                                          'OPERATING_EXPENSE_ACCT',
                                                          p_transaction_header_id,
                                                          'TRANSFER',
                                                          p_op_expense_ccid);

    -- get the account info for the DEPRN_EXPENSE_ACCT
    l_return_value:=IGI_IAC_COMMON_UTILS.get_account_ccid(p_book_type_code,
                                                          p_asset_id,
                                                          p_dist_id,
                                                          'DEPRN_EXPENSE_ACCT',
                                                          p_transaction_header_id,
                                                          'TRANSFER',
                                                          p_expense_ccid
                                                         );
 EXCEPTION
    WHEN OTHERS THEN
    	l_mesg:=SQLERRM;

        p_reval_ccid      := NULL;
        P_gen_fund_ccid   := NULL;
        P_backlog_ccid    := NULL;
        p_deprn_ccid      := NULL;
        p_cost_ccid       := NULL;
        p_op_expense_ccid := NULL;

        igi_iac_debug_pkg.debug_unexpected_msg(l_path);
    	FA_SRVR_MSG.Add_Message(
	                Calling_FN 	=> 'IGI_IAC_TRANSFER_PKG.Do_Transfer',
        	        Name 		=> 'IGI_IAC_EXCEPTION',
        	        TOKEN1		=> 'PACKAGE',
        	        VALUE1		=> 'Transfers',
        	        TOKEN2		=> 'ERROR_MESSAGE',
        	        VALUE2		=> l_mesg);

 END find_ccid;

 -- ===============================================================================
 -- FUNCTION Calc_Asset_Amounts: Calculate the asset level amounts for the asset
 -- ===============================================================================
 FUNCTION Calc_Asset_Amounts(p_adjustment_id   IN igi_iac_transaction_headers.adjustment_id%TYPE,
                             p_asset_id        IN igi_iac_transaction_headers.asset_id%TYPE,
                             p_book_type_code  IN igi_iac_transaction_headers.book_type_code%TYPE,
                             p_curr_prd_cntr   IN igi_iac_transaction_headers.period_counter%TYPE,
                             p_tfr_prd_cntr    IN igi_iac_transaction_headers.period_counter%TYPE,
                             p_hist_cost       IN fa_books.cost%TYPE,
                             p_salvage_value   IN fa_books.salvage_value%TYPE,
                             p_trx_header_id   IN igi_iac_transaction_headers.transaction_header_id%TYPE,
                             p_asset_units     IN fa_distribution_history.units_assigned%TYPE,
                             p_transfer_units  IN fa_distribution_history.units_assigned%TYPE,
                             l_asset_rec       OUT NOCOPY asset_rec_type,
                             l_iac_fa_dep_rec  OUT NOCOPY iac_fa_deprn_rec_type
                             )
 RETURN BOOLEAN
 IS
 	-- Get the asset amounts that need to be transferred to the new  dist
	-- created by transfer (keep)
    CURSOR c_amounts
    IS
    SELECT iab.asset_id,
           iab.book_type_code,
           iab.period_counter,
           iab.net_book_value,
           iab.adjusted_cost,
           iab.operating_acct,
           iab.reval_reserve,
           iab.deprn_amount,
           iab.deprn_reserve,
           iab.backlog_deprn_reserve,
           iab.general_fund,
           iab.last_reval_date,
           iab.current_reval_factor,
           iab.cumulative_reval_factor
    FROM   igi_iac_asset_balances iab,
           (SELECT a.book_type_code,
                   a.asset_id,
                   max(a.period_counter) period_counter
            FROM igi_iac_asset_balances a
            WHERE  a.asset_id= p_asset_id
            AND    a.book_type_code= p_book_type_code
            GROUP BY a.book_type_code, a.asset_id) mpc
    WHERE  iab.asset_id= p_asset_id
    AND    iab.book_type_code= p_book_type_code
    AND	   iab.asset_id = mpc.asset_id
    AND    iab.book_type_code = mpc.book_type_code
    AND    iab.period_counter = mpc.period_counter;

	 -- Calculate the reval reserve backlog,op acct backlog, gen fund per and YTD deprn
     -- for the adjustment
     -- (for asset level amounts)
     CURSOR	c_backlog_data(cp_adjustment_id igi_iac_transaction_headers.adjustment_id%TYPE)
     IS
     SELECT  nvl(sum(iadb.reval_reserve_backlog), 0) reval_reserve_backlog,
             nvl(sum(iadb.operating_acct_backlog), 0) operating_acct_backlog,
             nvl(sum(iadb.general_fund_per), 0) general_fund_per,
             nvl(sum(iadb.deprn_ytd), 0) ytd_deprn
     FROM	 igi_iac_det_balances iadb
     WHERE   iadb.adjustment_id = cp_adjustment_id
     AND     iadb.active_flag IS NULL;

     -- Calculate the iac fa depreciation data for an adjustment
     CURSOR c_iac_fa_deprn(cp_adjustment_id igi_iac_transaction_headers.adjustment_id%TYPE)
     IS
     SELECT  nvl(sum(iadb.deprn_period), 0) deprn_period,
             nvl(sum(iadb.deprn_reserve), 0) deprn_reserve,
             nvl(sum(iadb.deprn_ytd), 0) deprn_ytd
     FROM	 igi_iac_fa_deprn iadb
     WHERE   iadb.adjustment_id = cp_adjustment_id
     AND     iadb.active_flag IS NULL;

     --To fetch depreciation expense from fa_adjustments for the transfer transaction (keep)
     CURSOR c_get_deprn_expense(cp_period_counter fa_deprn_detail.period_counter%TYPE)
     IS
     SELECT sum(deprn_amount-deprn_adjustment_amount ) deprn_amount
     FROM   fa_deprn_detail
     WHERE  book_type_code = p_book_type_code
     AND    period_counter = cp_period_counter
     AND    asset_id = p_asset_id;

     -- cursor to get the operating expense amount
     CURSOR c_op_expense_amt(cp_asset_id          igi_iac_adjustments.asset_id%TYPE,
                             cp_book_type_code    igi_iac_adjustments.book_type_code%TYPE,
                             cp_tfr_prd_counter   igi_iac_adjustments.period_counter%TYPE,
                             cp_cur_prd_counter   igi_iac_adjustments.period_counter%TYPE
                            )
     IS
     SELECT nvl(sum(decode(aj.dr_cr_flag, 'CR', 1, -1) *AJ.Amount), 0)  op_expense_amt
     FROM    igi_iac_adjustments aj,
             igi_iac_transaction_headers ith
     WHERE   aj.asset_id = cp_asset_id
     AND     aj.book_type_code = cp_book_type_code
     AND     aj.period_counter BETWEEN cp_tfr_prd_counter AND cp_cur_prd_counter
     AND     aj.adjustment_type = 'OP EXPENSE'
     AND     aj.adjustment_id = ith.adjustment_id
     AND     ith.transaction_type_code = 'REVALUATION'
     AND     ith.adjustment_status NOT IN ('PREVIEW', 'OBSOLETE');

    -- local variables
     l_ab_amounts       c_amounts%ROWTYPE;
     l_ab_backlog_data  c_backlog_data%ROWTYPE;
     l_iac_fa_deprn     c_iac_fa_deprn%ROWTYPE;

	 l_historic_deprn_expense   fa_deprn_summary.deprn_amount%TYPE;
	 l_expense_diff			    igi_iac_det_balances.deprn_period%TYPE;
     l_ab_op_exp                igi_iac_asset_balances.operating_acct%TYPE;

     l_mesg	            VARCHAR2(500);
     l_path varchar2(150);

     -- exceptions
     e_salvage_val_corr_err  EXCEPTION;
 BEGIN

    l_path := g_path||'Calc_Asset_Amounts';

    -- Get the IAC position for the asset for the current period counter
    -- from igi_iac_asset_balances
    OPEN c_amounts;
    FETCH c_amounts INTO l_ab_amounts;
    IF c_amounts%NOTFOUND THEN
       RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c_amounts;
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_ab_amounts.period_counter: ' || l_ab_amounts.period_counter);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_ab_amounts.net_book_value: ' || l_ab_amounts.net_book_value);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_ab_amounts.adjusted_cost: ' || l_ab_amounts.adjusted_cost);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_ab_amounts.operating_acct: ' || l_ab_amounts.operating_acct);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_ab_amounts.reval_reserve: ' || l_ab_amounts.reval_reserve);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_ab_amounts.deprn_amount: ' || l_ab_amounts.deprn_amount);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_ab_amounts.deprn_reserve: ' || l_ab_amounts.deprn_reserve);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_ab_amounts.backlog_deprn_reserve: ' || l_ab_amounts.backlog_deprn_reserve);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_ab_amounts.general_fund: ' || l_ab_amounts.general_fund);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_ab_amounts.last_reval_date: ' || l_ab_amounts.last_reval_date);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_ab_amounts.current_reval_factor: ' || l_ab_amounts.current_reval_factor);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_ab_amounts.cumulative_reval_factor: ' || l_ab_amounts.cumulative_reval_factor);

    -- fetch asset level backlog and general fund periodic amounts
    -- for the latest adjustment_id
    OPEN c_backlog_data(p_adjustment_id);
    FETCH c_backlog_data INTO l_ab_backlog_data;
    IF c_backlog_data%NOTFOUND THEN
       RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c_backlog_data;
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_ab_backlog_data.reval_reserve_backlog: ' || l_ab_backlog_data.reval_reserve_backlog);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_ab_backlog_data.operating_acct_backlog: ' || l_ab_backlog_data.operating_acct_backlog);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_ab_backlog_data.general_fund_per: ' || l_ab_backlog_data.general_fund_per);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_ab_backlog_data.ytd_deprn: ' || l_ab_backlog_data.ytd_deprn);

    -- set the asset info
    l_asset_rec.asset_id                := l_ab_amounts.asset_id;
    l_asset_rec.book_type_code          := l_ab_amounts.book_type_code;
    l_asset_rec.period_counter          := l_ab_amounts.period_counter;
    l_asset_rec.net_book_value          := l_ab_amounts.net_book_value;
    l_asset_rec.adjusted_cost           := l_ab_amounts.adjusted_cost;
    l_asset_rec.operating_acct          := l_ab_amounts.operating_acct;
    l_asset_rec.reval_reserve           := l_ab_amounts.reval_reserve;
    l_asset_rec.deprn_amount            := l_ab_amounts.deprn_amount;
    l_asset_rec.deprn_reserve           := l_ab_amounts.deprn_reserve;
    l_asset_rec.backlog_deprn_reserve   := l_ab_amounts.backlog_deprn_reserve;
    l_asset_rec.general_fund            := l_ab_amounts.general_fund;
    l_asset_rec.last_reval_date         := l_ab_amounts.last_reval_date;
    l_asset_rec.current_reval_factor    := l_ab_amounts.current_reval_factor;
    l_asset_rec.cumulative_reval_factor := l_ab_amounts.cumulative_reval_factor;
    l_asset_rec.reval_reserve_backlog   := l_ab_backlog_data.reval_reserve_backlog;
    l_asset_rec.operating_acct_backlog  := l_ab_backlog_data.operating_acct_backlog;
    l_asset_rec.general_fund_per        := l_ab_backlog_data.general_fund_per;
    l_asset_rec.ytd_deprn               := l_ab_backlog_data.ytd_deprn;

    -- calculate the asset level catchup amounts
    l_asset_rec.dep_expense_catchup := 0;
    l_asset_rec.op_expense_catchup := 0;
    IF g_prior_period THEN
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Processing prior period data	');
       -- l_historic_deprn_expense will be calculated from fa_adjustments
     --  OPEN c_get_deprn_expense (p_trans_rec.transaction_header_id);
       OPEN c_get_deprn_expense(p_curr_prd_cntr - 1);
       FETCH c_get_deprn_expense INTO l_historic_deprn_expense;

       IF c_get_deprn_expense%NOTFOUND THEN
          l_historic_deprn_expense:=0;
          CLOSE c_get_deprn_expense;
       ELSE
	igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_historic_deprn_expense: ' || l_historic_deprn_expense);
          -- do salvage value correction for l_historic_deprn_expense
          IF NOT IGI_IAC_SALVAGE_PKG.Correction(
                                                P_asset_id        => p_asset_id,
                                                P_book_type_code  => p_book_type_code,
                                                P_value           => l_historic_deprn_expense,
                                                P_cost            => p_hist_cost,
                                                P_salvage_value   => p_salvage_value,
                                                p_calling_program => 'IGI_IAC_TRANSFERS_PKG.Do_transfer'
                                               )
          THEN
             RAISE e_salvage_val_corr_err;
          END IF;
          CLOSE c_get_deprn_expense;
        END IF;
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Historic Expense Amount		:'||l_historic_deprn_expense);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Cumulative Reval Factor		:'||l_ab_amounts.cumulative_reval_factor);

        -- calculate the additional IAC expense
        l_asset_rec.dep_expense_catchup :=l_historic_deprn_expense*(l_ab_amounts.cumulative_reval_factor - 1);
	do_round(l_asset_rec.dep_expense_catchup,p_book_type_code);
	igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_asset_rec.dep_expense_catchup :'||l_asset_rec.dep_expense_catchup);
        l_asset_rec.dep_expense_catchup := l_asset_rec.dep_expense_catchup*(p_curr_prd_cntr - p_tfr_prd_cntr);
	do_round(l_asset_rec.dep_expense_catchup,p_book_type_code);
	igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_asset_rec.dep_expense_catchup :'||l_asset_rec.dep_expense_catchup);
        l_asset_rec.dep_expense_catchup := l_asset_rec.dep_expense_catchup*(p_transfer_units/p_asset_units);
	do_round(l_asset_rec.dep_expense_catchup,p_book_type_code);
	igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_asset_rec.dep_expense_catchup :'||l_asset_rec.dep_expense_catchup);

        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Additional IAC Expense		:'||l_expense_diff);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'No of Catch up periods		:'||(p_curr_prd_cntr-p_tfr_prd_cntr));

        -- if asset has been revalued between the transfer period and current period
        -- the calculate the operating expense amount
        OPEN c_op_expense_amt(cp_asset_id          => p_asset_id,
                              cp_book_type_code    => p_book_type_code,
                              cp_tfr_prd_counter   => p_tfr_prd_cntr,
                              cp_cur_prd_counter   => p_curr_prd_cntr
                              );
        FETCH c_op_expense_amt INTO l_asset_rec.op_expense_catchup;
        IF c_op_expense_amt%NOTFOUND THEN
          RAISE NO_DATA_FOUND;
        END IF;
        CLOSE c_op_expense_amt;

        l_asset_rec.op_expense_catchup := l_asset_rec.op_expense_catchup*(p_transfer_units/p_asset_units);
	do_round(l_asset_rec.op_expense_catchup,p_book_type_code);
	igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_asset_rec.op_expense_catchup :'||l_asset_rec.op_expense_catchup);

     END IF;
    -- end calculation of catchup amounts

    -- calculate asset iac fa deprn amounts
    OPEN c_iac_fa_deprn(p_adjustment_id);
    FETCH c_iac_fa_deprn INTO l_iac_fa_deprn;
    IF c_iac_fa_deprn%NOTFOUND THEN
       RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c_iac_fa_deprn;
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_iac_fa_deprn.deprn_period :'||l_iac_fa_deprn.deprn_period);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_iac_fa_deprn.deprn_reserve :'||l_iac_fa_deprn.deprn_reserve);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_iac_fa_deprn.deprn_ytd :'||l_iac_fa_deprn.deprn_ytd);

    l_iac_fa_dep_rec.asset_id          := l_ab_amounts.asset_id;
    l_iac_fa_dep_rec.book_type_code    := l_ab_amounts.book_type_code;
    l_iac_fa_dep_rec.period_counter    := l_ab_amounts.period_counter;
    l_iac_fa_dep_rec.deprn_period      := l_iac_fa_deprn.deprn_period;
    l_iac_fa_dep_rec.deprn_reserve     := l_iac_fa_deprn.deprn_reserve;
    l_iac_fa_dep_rec.deprn_ytd         := l_iac_fa_deprn.deprn_ytd;

    -- calculate the historic depreciation catchup amount
    l_iac_fa_dep_rec.dep_expense_catchup := l_historic_deprn_expense*(p_curr_prd_cntr - p_tfr_prd_cntr);
    do_round(l_iac_fa_dep_rec.dep_expense_catchup,p_book_type_code);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_iac_fa_dep_rec.dep_expense_catchup :'||l_iac_fa_dep_rec.dep_expense_catchup);
    l_iac_fa_dep_rec.dep_expense_catchup := l_iac_fa_dep_rec.dep_expense_catchup*(p_transfer_units/p_asset_units);
    do_round(l_iac_fa_dep_rec.dep_expense_catchup,p_book_type_code);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_iac_fa_dep_rec.dep_expense_catchup :'||l_iac_fa_dep_rec.dep_expense_catchup);

    RETURN TRUE;
 EXCEPTION
   WHEN e_salvage_val_corr_err THEN
		FA_SRVR_MSG.Add_Message(
	                Calling_FN 	=> 'IGI_IAC_TRANSFER_PKG.Do_Transfer',
        	        Name 		=> 'IGI_IAC_SALVAGE_CORR_ERR',
        	        TOKEN1		=> 'PROCESS',
        	        VALUE1		=> 'IGI_IAC_TRANSFER_PKG.Do_Transfer');
	        igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'Salvage Value correction error');
        RETURN FALSE;

    WHEN OTHERS THEN
    	l_mesg:=SQLERRM;
        igi_iac_debug_pkg.debug_unexpected_msg(l_path);
    	FA_SRVR_MSG.Add_Message(
	                Calling_FN 	=> 'IGI_IAC_TRANSFER_PKG.Calc_Asset_Amounts',
        	        Name 		=> 'IGI_IAC_EXCEPTION',
        	        TOKEN1		=> 'PACKAGE',
        	        VALUE1		=> 'Transfers',
        	        TOKEN2		=> 'ERROR_MESSAGE',
        	        VALUE2		=> l_mesg);
        RETURN FALSE;
 END Calc_Asset_Amounts;

-- ================================================================================
-- PROCEDURE Roll_Inactive_Forward: This procedure will roll all the inactive
-- distributions of the current adjustment_id to the new transfers adjustment_id
-- ================================================================================
 PROCEDURE Roll_Inactive_Forward(p_adjustment_id  IN igi_iac_det_balances.adjustment_id%TYPE,
                                 p_new_adj_id     IN igi_iac_det_balances.adjustment_id%TYPE,
                                 p_book_type_code IN igi_iac_det_balances.book_type_code%TYPE,
                                 p_asset_id       IN igi_iac_det_balances.asset_id%TYPE,
                                 p_curr_prd_cntr  IN igi_iac_det_balances.period_counter%TYPE
                                )
 IS
	-- Select all inactive distributions created by the previous transaction (keep)
    CURSOR c_inactive_dist(c_adjustment_id IGI_IAC_TRANSACTION_HEADERS.adjustment_id%TYPE)
    IS
    SELECT *
    FROM   igi_iac_det_balances
    WHERE  adjustment_id=c_adjustment_id
    AND     book_type_code = p_book_type_code
    AND     asset_id = p_asset_id
    AND	active_flag='N';

    -- get fa inactive rows for a distribution (keep)
    CURSOR c_fa_inactive_dist(cp_adjustment_id igi_iac_transaction_headers.adjustment_id%TYPE)
    IS
    SELECT  *
    FROM    igi_iac_fa_deprn
    WHERE   adjustment_id = cp_adjustment_id
    AND     book_type_code = p_book_type_code
    AND     asset_id = p_asset_id
    AND     active_flag = 'N';

    l_rowid  ROWID;

 BEGIN
 	-- Carry forward the inactive distributions from the previous period
	FOR l_inactive_dist IN c_inactive_dist(p_adjustment_id)
	LOOP
		insert_data_det(p_new_adj_id,
				l_inactive_dist.asset_id,
				l_inactive_dist.distribution_id,
				p_curr_prd_cntr,
				l_inactive_dist.book_type_code,
				l_inactive_dist.adjustment_cost,
				l_inactive_dist.net_book_value,
				l_inactive_dist.reval_reserve_net,
				l_inactive_dist.general_fund_acc,
				l_inactive_dist.reval_reserve_backlog,
				l_inactive_dist.operating_acct_net,
				l_inactive_dist.deprn_reserve,
				l_inactive_dist.deprn_reserve_backlog,
				l_inactive_dist.deprn_ytd,
				l_inactive_dist.deprn_period,
				l_inactive_dist.general_fund_acc,
				l_inactive_dist.general_fund_per,
				l_inactive_dist.current_reval_factor,
				l_inactive_dist.cumulative_reval_factor,
				l_inactive_dist.active_flag,
				l_inactive_dist.operating_acct_ytd,
				l_inactive_dist.operating_acct_backlog,
				l_inactive_dist.last_reval_date
				);
	END LOOP;

	FOR l_fa_inactive_dist IN c_fa_inactive_dist(p_adjustment_id)
	LOOP
			l_rowid := NULL;
			igi_iac_fa_deprn_pkg.insert_row(
                      x_rowid              => l_rowid,
                      x_book_type_code     => l_fa_inactive_dist.book_type_code,
                      x_asset_id           => l_fa_inactive_dist.asset_id,
                      x_distribution_id    => l_fa_inactive_dist.distribution_id,
                      x_period_counter     => p_curr_prd_cntr,
                      x_adjustment_id      => p_new_adj_id,
                      x_deprn_period       => l_fa_inactive_dist.deprn_period,
                      x_deprn_ytd          => l_fa_inactive_dist.deprn_ytd ,
                      x_deprn_reserve      => l_fa_inactive_dist.deprn_reserve,
                      x_active_flag	       => l_fa_inactive_dist.active_flag,
                      x_mode               => 'R');
	END LOOP;
 EXCEPTION
    WHEN OTHERS THEN
        igi_iac_debug_pkg.debug_unexpected_msg(sqlerrm);
    	FA_SRVR_MSG.Add_Message(
	                Calling_FN 	=> 'IGI_IAC_TRANSFER_PKG.Roll_Inactive_Forward',
        	        Name 		=> 'IGI_IAC_EXCEPTION',
        	        TOKEN1		=> 'PACKAGE',
        	        VALUE1		=> 'Transfers',
        	        TOKEN2		=> 'ERROR_MESSAGE',
        	        VALUE2		=> sqlerrm);

 END Roll_Inactive_Forward;

/************************************MAIN***********************************/
-- =================================================================================
--	Function Do_transfer transfers the data from the old distribution to the new
--	distribution(s).Along with the transfer of old distribution to the new ,it
--	maintains the other active distributions of the asset with the latest adjustment
--	id.
-- ==================================================================================

 FUNCTION Do_Transfer(p_trans_rec		FA_API_TYPES.trans_rec_type,
                      p_asset_hdr_rec	FA_API_TYPES.asset_hdr_rec_type,
                      p_asset_cat_rec	FA_API_TYPES.asset_cat_rec_type,
                      p_calling_function	varchar2,
                      p_event_id            number    --R12 uptake
                     )
 RETURN BOOLEAN
 IS
    -- local cursors
	-- Select all distributions for an asset that are active and the distribution
	-- impacted by the transfer (keep)
    CURSOR 	c_all_dist
    IS
    SELECT  distribution_id,
            transaction_header_id_in,
            units_assigned,
            transaction_header_id_out,
            transaction_units
    FROM    fa_distribution_history
    WHERE   asset_id=p_asset_hdr_rec.asset_id
    AND	    book_type_code=p_asset_hdr_rec.book_type_code
    AND	    (transaction_header_id_out IS NULL OR
			  transaction_header_id_out=p_trans_rec.transaction_header_id);

	-- Cursor to find out the number of ACtive Distributions (keep)
	CURSOR	c_no_of_imp IS
    SELECT  count(*) counter
    FROM    fa_distribution_history
    WHERE   asset_id=p_asset_hdr_rec.asset_id
    AND     book_type_code=p_asset_hdr_rec.book_type_code
 --   AND     transaction_header_id_in=p_trans_rec.transaction_header_id;
    AND     transaction_header_id_out IS NULL;

	-- Cursor to find out the number of ACtive Distributions created by the Transfer(keep)
	CURSOR	c_no_of_active IS
    SELECT  count(*) counter
    FROM    fa_distribution_history
    WHERE   asset_id=p_asset_hdr_rec.asset_id
    AND     book_type_code=p_asset_hdr_rec.book_type_code
    AND     transaction_header_id_in=p_trans_rec.transaction_header_id;

	-- Cursor to find out the number of Inative Distributions created by the Transfer(keep)
	CURSOR	c_no_of_inactive IS
    SELECT  count(*) counter
    FROM    fa_distribution_history
    WHERE   asset_id=p_asset_hdr_rec.asset_id
    AND     book_type_code=p_asset_hdr_rec.book_type_code
    AND     transaction_header_id_out=p_trans_rec.transaction_header_id;

    -- Find period counter of transfer period in case of prior period transfer
	-- (keep)
    CURSOR c_prior_period_counter(c_trx_date IN FA_DEPRN_PERIODS.period_open_date%TYPE)
    IS
    SELECT 	period_counter
    FROM    fa_deprn_periods
    WHERE   c_trx_date BETWEEN period_open_date AND period_close_date
    AND     book_type_code=p_asset_hdr_rec.book_type_code;

	-- find the total number of units for the asset itself ( active) (keep)
    CURSOR 	c_units
    IS
    SELECT units
    FROM   fa_asset_history
    WHERE  asset_id = p_asset_hdr_rec.asset_id
    AND    transaction_header_id_out IS NULL;

    -- find the number of units involved in the transfer
    CURSOR c_transfer_units
    IS
    SELECT  sum(units_assigned)
    FROM    fa_distribution_history
    WHERE   asset_id=p_asset_hdr_rec.asset_id
    AND     book_type_code=p_asset_hdr_rec.book_type_code
    AND     transaction_header_id_in=p_trans_rec.transaction_header_id;

	-- select the start period number for a given fiscal year (keep)
    CURSOR c_start_period_counter(c_fiscal_year FA_DEPRN_PERIODS.fiscal_year%TYPE)
    IS
    SELECT (number_per_fiscal_year*c_fiscal_year)+1
    FROM	fa_calendar_types
    WHERE   calendar_type=(SELECT deprn_calendar
                           FROM fa_book_controls
                           WHERE book_type_code=p_asset_hdr_rec.book_type_code);

	-- Find the asset number for the asset_id (for exception messages) (keep)
    CURSOR  c_asset_num
    IS
    SELECT 	asset_number
    FROM    fa_additions
    WHERE   asset_id=p_asset_hdr_rec.asset_id;

    -- retrieve salvage value and cost of the asset from fa_books (keep)
    CURSOR c_get_asset_book(p_asset_id    fa_books.asset_id%TYPE,
                            p_book_type_code  fa_books.book_type_code%TYPE)
    IS
    SELECT cost,
           salvage_value,
           period_counter_fully_reserved
    FROM fa_books
    WHERE asset_id = p_asset_id
    AND   book_type_code = p_book_type_code
    AND   date_ineffective IS NULL
    AND   transaction_header_id_out IS NULL;

    -- check to see if intercompany accounting entries have been created by FA
    -- for the transaction
    CURSOR c_get_interco (p_book_type_code varchar2,
                          p_asset_id number,
                          p_distribution_id number,
                          p_transaction_header_id number)
    IS
    SELECT count(*) interco_count
    FROM FA_ADJUSTMENTS adj,
         FA_BOOK_CONTROLS bc
    WHERE adj.book_type_code = p_book_type_code
    AND adj.ASSET_ID = p_asset_id
    AND adj.SOURCE_TYPE_CODE = 'TRANSFER'
    AND adj.ADJUSTMENT_TYPE IN ('INTERCO AP','INTERCO AR')
    AND adj.TRANSACTION_HEADER_ID=p_transaction_header_id
    AND bc.book_type_code = p_book_type_code
    AND nvl(bc.intercompany_posting_flag,'Y') = 'Y';

 	-- Cursor to select the fa amounts for a distribution (keep)
   CURSOR  c_fa_dist_data(cp_adjustment_id igi_iac_fa_deprn.adjustment_id%TYPE,
                          cp_dist_id igi_iac_fa_deprn.distribution_id%TYPE)
   IS
   SELECT  *
   FROM    igi_iac_fa_deprn
   WHERE   book_type_code = p_asset_hdr_rec.book_type_code
   AND     adjustment_id = cp_adjustment_id
   AND     asset_id = p_asset_hdr_rec.asset_id
   AND     distribution_id = cp_dist_id;

    -- retrieve a row from igi_iac_det_balances
    CURSOR c_iac_dist(cp_dist_id     igi_iac_det_balances.distribution_id%TYPE,
                      cp_adj_id      igi_iac_det_balances.adjustment_id%TYPE)
    IS
    SELECT *
    FROM   igi_iac_det_balances
    WHERE  adjustment_id = cp_adj_id
    AND    distribution_id = cp_dist_id;

    -- local variables
    l_rowid                     ROWID;
    i                           NUMBER ;
    act_cnt                     NUMBER ;
    inact_cnt                   NUMBER ;
    l_return_value              BOOLEAN;

    l_adj_id_out                igi_iac_transaction_headers.adjustment_id_out%TYPE;
    l_new_adj_id                igi_iac_transaction_headers.adjustment_id%TYPE;
    l_adj_id                    igi_iac_transaction_headers.adjustment_id%TYPE;
    l_current_period_counter 	fa_deprn_periods.period_counter%TYPE;
    l_start_period_counter      fa_deprn_periods.period_counter%TYPE;
    l_prior_period_counter      fa_deprn_periods.period_counter%TYPE;
    l_prd_rec                   igi_iac_types.prd_rec;
    l_prd_rec_prior             igi_iac_types.prd_rec;
    l_all_dist                  c_all_dist%ROWTYPE;
    l_iac_dist                  c_iac_dist%ROWTYPE;
    l_old_dist                  fa_distribution_history.distribution_id%TYPE;
    l_impacted_dist             fa_distribution_history.distribution_id%TYPE;
    l_impacted_units            fa_distribution_history.units_assigned%TYPE;
    l_no_of_imp			c_no_of_imp%ROWTYPE;
    l_no_of_active              NUMBER;
    l_no_of_inactive            NUMBER;

    l_ab_amounts                asset_rec_type;
    l_iac_fa_dep_amounts        iac_fa_deprn_rec_type;

    l_asset_num                 FA_ADDITIONS.asset_number%TYPE;
    l_units	                FA_DISTRIBUTION_HISTORY.units_assigned%TYPE;
    l_transfer_units            FA_DISTRIBUTION_HISTORY.units_assigned%TYPE;

    l_interco_count         	NUMBER;
    l_interco_amount 		NUMBER ;
    l_interco_ccid              igi_iac_adjustments.code_combination_id%TYPE;
    l_interco_drcr_flag         igi_iac_adjustments.dr_cr_flag%TYPE;

    l_reval_reserve             IGI_IAC_DET_BALANCES.reval_reserve_cost%type;
    l_general_fund              IGI_IAC_DET_BALANCES.general_fund_acc%type;
    l_Backlog_deprn_reserve     IGI_IAC_DET_BALANCES.deprn_reserve_backlog%type;
    l_deprn_reserve             IGI_IAC_DET_BALANCES.deprn_reserve%type;
    l_adjusted_cost             IGI_IAC_DET_BALANCES.adjustment_cost%type;
    l_net_book_value            IGI_IAC_DET_BALANCES.net_book_value%type;
    l_deprn_per                 IGI_IAC_DET_BALANCES.deprn_period%type;
    l_ytd_deprn                 IGI_IAC_DET_BALANCES.deprn_ytd%type;
    l_op_acct                   IGI_IAC_DET_BALANCES.operating_acct_ytd%type;
    l_op_acct_ytd               IGI_IAC_DET_BALANCES.operating_acct_ytd%type;
    l_general_fund_per          IGI_IAC_DET_BALANCES.general_fund_per%type;
    l_reval_reserve_backlog     IGI_IAC_DET_BALANCES.reval_reserve_backlog%type;
    l_operating_acct_backlog    IGI_IAC_DET_BALANCES.operating_acct_backlog%type;

    l_transaction_header_id     IGI_IAC_TRANSACTION_HEADERS.transaction_header_id%type;
    l_transaction_type_code     IGI_IAC_TRANSACTION_HEADERS.transaction_type_code%type;
    l_mass_reference_id	        IGI_IAC_TRANSACTION_HEADERS.mass_reference_id%type;
    l_adjustment_id	        IGI_IAC_TRANSACTION_HEADERS.adjustment_id%type;
    l_prev_adjustment_id        IGI_IAC_TRANSACTION_HEADERS.adjustment_id%type;
    l_adjustment_status         IGI_IAC_TRANSACTION_HEADERS.adjustment_status%type;

    l_reval_reserve_sum		  igi_iac_det_balances.reval_reserve_cost%TYPE    ;
    l_general_fund_sum 		  igi_iac_det_balances.general_fund_acc%TYPE      ;
    l_Backlog_deprn_reserve_sum   igi_iac_det_balances.deprn_reserve_backlog%TYPE ;
    l_deprn_reserve_sum		  igi_iac_det_balances.deprn_reserve%TYPE         ;
    l_adjusted_cost_sum		  igi_iac_det_balances.adjustment_cost%TYPE       ;
    l_net_book_value_sum	  igi_iac_det_balances.net_book_value%TYPE        ;
    l_deprn_per_sum	 	  igi_iac_det_balances.deprn_period%TYPE          ;
    l_ytd_deprn_sum 		  igi_iac_det_balances.deprn_ytd%TYPE             ;
    l_op_acct_sum 	          igi_iac_det_balances.operating_acct_ytd%TYPE    ;
    l_op_acct_ytd_sum		  igi_iac_det_balances.operating_acct_ytd%TYPE    ;
    l_general_fund_per_sum	  igi_iac_det_balances.general_fund_per%TYPE      ;
    l_reval_reserve_backlog_sum	  igi_iac_det_balances.reval_reserve_backlog%TYPE ;
    l_operating_acct_backlog_sum  igi_iac_det_balances.operating_acct_backlog%TYPE;

    l_reval_ccid              igi_iac_adjustments.code_combination_id%TYPE;
    l_gen_fund_ccid           igi_iac_adjustments.code_combination_id%TYPE;
    l_backlog_ccid            igi_iac_adjustments.code_combination_id%TYPE;
    l_deprn_ccid              igi_iac_adjustments.code_combination_id%TYPE;
    l_cost_ccid               igi_iac_adjustments.code_combination_id%TYPE;
    l_op_expense_ccid         igi_iac_adjustments.code_combination_id%TYPE;
    l_expense_ccid            igi_iac_adjustments.code_combination_id%TYPE;

    l_sob_id                  igi_iac_adjustments.set_of_books_id%TYPE;
    l_coa_id                  NUMBER;
    l_currency                VARCHAR2(15);
    l_precision               NUMBER;

    l_prorate_factor         NUMBER;
    l_deprn_expense          NUMBER;
    l_deprn_expense_old_sum  NUMBER;
    l_deprn_expense_imp_sum  NUMBER;
    l_dist_op_exp            igi_iac_adjustments.amount%TYPE;
    l_dist_op_exp_old_sum    igi_iac_adjustments.amount%TYPE;
    l_dist_op_exp_imp_sum    igi_iac_adjustments.amount%TYPE;
    l_fa_deprn_expense          NUMBER;
    l_fa_deprn_expense_old_sum  NUMBER;
    l_fa_deprn_expense_imp_sum  NUMBER;

    l_fa_dist_data          igi_iac_fa_deprn%ROWTYPE;
    l_fa_deprn_period       igi_iac_fa_deprn.deprn_period%TYPE;
    l_fa_deprn_ytd          igi_iac_fa_deprn.deprn_ytd%TYPE;
    l_fa_deprn_reserve	    igi_iac_fa_deprn.deprn_reserve%TYPE;
    l_fa_deprn_period_sum   igi_iac_fa_deprn.deprn_period%TYPE;
    l_fa_deprn_ytd_sum	    igi_iac_fa_deprn.deprn_ytd%TYPE;
    l_fa_deprn_reserve_sum  igi_iac_fa_deprn.deprn_reserve%TYPE;

    l_get_asset_book            c_get_asset_book%ROWTYPE;
    l_iac_deprn_period_amount   NUMBER;
    l_fa_deprn_period_amount    NUMBER;
    l_deprn_amount              igi_iac_asset_balances.deprn_amount%TYPE;

    l_adj_offset_type        igi_iac_adjustments.adjustment_offset_type%TYPE;
    l_report_ccid            igi_iac_adjustments.report_ccid%TYPE;

    l_path  VARCHAR2(150);
    l_mesg  VARCHAR2(500);

    -- exceptions
    e_iac_not_enabled          EXCEPTION;
    e_not_iac_book             EXCEPTION;
    e_asset_not_revalued       EXCEPTION;
    e_no_gl_info               EXCEPTION;
    l_exists                   BOOLEAN;

    cursor c_exists ( cp_period_counter   in number
                , cp_asset_id         in number
                , cp_book_type_code   in varchar2
                ) is
     select cumulative_reval_factor, current_reval_factor
     from   igi_iac_asset_balances
     where  asset_id       = cp_asset_id
     and    book_type_code = cp_book_type_code
     and    period_counter = cp_period_counter
     ;

 BEGIN

    i                           := 0;
    act_cnt                     := 0;
    inact_cnt                   := 0;
    l_interco_amount 		:= 0;
    l_reval_reserve_sum		  := 0;
    l_general_fund_sum 		  := 0;
    l_Backlog_deprn_reserve_sum   := 0;
    l_deprn_reserve_sum		  := 0;
    l_adjusted_cost_sum		  := 0;
    l_net_book_value_sum	  := 0;
    l_deprn_per_sum	 	  := 0;
    l_ytd_deprn_sum 		  := 0;
    l_op_acct_sum 	          := 0;
    l_op_acct_ytd_sum		  := 0;
    l_general_fund_per_sum	  := 0;
    l_reval_reserve_backlog_sum	  := 0;
    l_operating_acct_backlog_sum  := 0;
    l_deprn_expense_old_sum  := 0;
    l_deprn_expense_imp_sum  := 0;
    l_dist_op_exp_old_sum    := 0;
    l_dist_op_exp_imp_sum    := 0;
    l_fa_deprn_expense_old_sum  := 0;
    l_fa_deprn_expense_imp_sum  := 0;
    l_fa_deprn_period_sum   := 0;
    l_fa_deprn_ytd_sum	    := 0;
    l_fa_deprn_reserve_sum  := 0;
    l_path  := g_path||'Do_Transfer';
    l_exists := false;

    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'*****************************************************************************');
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'	Processing Transfers on book 	'||p_asset_hdr_rec.book_type_code);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'	Asset Id		   :'||p_asset_hdr_rec.asset_id);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'	Transaction Header Id	   :'||p_trans_rec.transaction_header_id);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'	Mass Reference Id 	   :'||p_trans_rec.mass_reference_id);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'	Transaction type code	   :'||p_trans_rec.transaction_type_code);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'	Transaction Date	   :'||p_trans_rec.transaction_date_entered);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'	Category Id		   :'||p_asset_cat_rec.category_id);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,' Transaction date entered   :'||p_trans_rec.transaction_date_entered);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,' Mass Reference Id  entered :'||p_trans_rec.mass_reference_id);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,' Mass Reference Id  entered :'||p_asset_hdr_rec.set_of_books_id);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'******************************************************************************');

    -- Check If IAC is enabled
    IF NOT  igi_gen.is_req_installed('IAC') THEN
       RAISE e_iac_not_enabled;
	END IF;

    -- Check If Book is an IAC book
    IF NOT igi_iac_common_utils.is_iac_book(p_asset_hdr_rec.book_type_code) THEN
       RAISE e_not_iac_book;
    END IF;

    -- check if the asset has been revalued atleast once
    IF NOT igi_iac_common_utils.is_asset_proc(p_asset_hdr_rec.book_type_code,
	                                          p_asset_hdr_rec.asset_id)
	THEN
	    RAISE e_asset_not_revalued;
    END IF;

    -- get the GL set of books id if p_asset_hdr_rec.set_of_books_id is null
    IF p_asset_hdr_rec.set_of_books_id is NULL THEN
          IF NOT igi_iac_common_utils.get_book_GL_info(p_asset_hdr_rec.book_type_code,
                                                       l_sob_id,
                                                       l_coa_id,
                                                       l_currency,
                                                       l_precision)
          THEN
             RAISE e_no_gl_info;
          END IF;
    END IF;

    -- populate igi_iac_fa_deprn table with asset detials if no rows exist for that
    -- asset
    IF NOT igi_iac_common_utils.populate_iac_fa_deprn_data(p_asset_hdr_rec.book_type_code,
                                                           'TRANSFER') THEN
       igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'*** Error in Synchronizing Depreciation Data ***');
       RETURN FALSE;
    END IF;

	--Fetch the latest transaction = prev trans if latest is revaluation-preview or obsolete
    IF igi_iac_common_utils.get_latest_transaction (p_asset_hdr_rec.book_type_code,
                                                    p_asset_hdr_rec.asset_id,
                                                    l_transaction_type_code,
                                                    l_transaction_header_id,
                                                    l_mass_reference_id,
                                                    l_adjustment_id,
                                                    l_prev_adjustment_id,
                                                    l_adjustment_status
                                                    )
    THEN
		NULL;
    END IF;
    -- set the adjustment_id_out
    l_adj_id_out := l_adjustment_id;

    -- check if latest adjustment is a REVALUATION in PREVIEW or OBSOLETE status
    -- and set
   /* not reqd as l_prev_adjustment_id is always the last active adjustment for the asset
    IF (l_transaction_type_code = 'REVALUATION'
                         AND l_adjustment_status IN ('PREVIEW', 'OBSOLETE')) THEN
         l_adjustment_id := l_prev_adjustment_id;
    END IF; */
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Prev adj: '||l_prev_adjustment_id||' Current: '||l_adjustment_id);

	-- Get the current open period counter
    IF igi_iac_common_utils.get_open_period_info(p_asset_hdr_rec.book_type_code,
                                                 l_prd_rec)
    THEN
       l_current_period_counter:=l_prd_rec.period_counter;
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Current Period Counter		:'||l_current_period_counter);
    END IF;

    -- Check whether adjustments exist in the open period
    -- If Adjustments exists then stop the Transfer
    IF IGI_IAC_COMMON_UTILS.Is_Asset_Adjustment_Done(p_asset_hdr_rec.book_type_code,
                                 p_asset_hdr_rec.asset_id) THEN

         FA_SRVR_MSG.Add_Message(
	                Calling_FN 	=> 'IGI_IAC_TRANSFERS_PKG.Do_Transfer' ,
        	        Name 		=> 'IGI_IAC_ADJUSTMENT_EXCEPTION',
        	        TRANSLATE => TRUE,
                    APPLICATION => 'IGI');
         RETURN FALSE;
    END IF;

    -- check if this is a prior period transfer
    g_prior_period := FALSE;
    -- get the period counter for the transfer date period
    IF igi_iac_common_utils.get_period_info_for_date(p_asset_hdr_rec.book_type_code,
                                                     p_trans_rec.transaction_date_entered,
                                                     l_prd_rec_prior)
    THEN
       l_prior_period_counter:=l_prd_rec_prior.period_counter;
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Prior Period Counter		:'||l_prior_period_counter);
    END IF;

    -- set the Prior_Period flag
    IF (l_prior_period_counter < l_current_period_counter) THEN
		   g_prior_period:= TRUE;
		   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Need to Process prior period transfers');
    ELSE
		   g_prior_period:= FALSE;
    END IF;

       -- create a new row in igi_iac_transaction_headers with transaction type code
       -- TRANSFERS
       -- initailise the new adjustment id
       l_adj_id := null;

       IGI_IAC_TRANS_HEADERS_PKG.Insert_Row(
               x_rowid                     => l_rowid,
               x_adjustment_id             => l_adj_id, -- out NOCOPY parameter
               x_transaction_header_id     => p_trans_rec.transaction_header_id, -- bug 3391000 null,
               x_adjustment_id_out         => NULL,
               x_transaction_type_code     => p_trans_rec.transaction_type_code,
               x_transaction_date_entered  => p_trans_rec.transaction_date_entered,
               x_mass_refrence_id          => p_trans_rec.mass_reference_id,
               x_transaction_sub_type      => NULL,
               x_book_type_code            => p_asset_hdr_rec.book_type_code,
               x_asset_id                  => p_asset_hdr_rec.Asset_id,
               x_category_id               => p_asset_cat_rec.category_id,
               x_adj_deprn_start_date      => NULL,
               x_revaluation_type_flag     => NULL,
               x_adjustment_status         => 'COMPLETE',
               x_period_counter            => l_current_period_counter,
               x_event_id                  => p_event_id
                                           );
	   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Data inserted into transaction headers');

       -- Get the start period counter for the fiscal year
       OPEN c_start_period_counter(l_prd_rec.fiscal_year);
       FETCH c_start_period_counter INTO l_start_period_counter;
       IF c_start_period_counter%NOTFOUND THEN
          RAISE NO_DATA_FOUND;
       END IF;
       CLOSE c_start_period_counter;
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_start_period_counter = ' || l_start_period_counter);

	   -- fetch the Distribution(s) involved in the transfer (old and new) and the non
       -- impacted ones
	   OPEN c_no_of_imp;
	   FETCH c_no_of_imp INTO l_no_of_imp;
       IF c_no_of_imp%NOTFOUND THEN
          RAISE NO_DATA_FOUND;
       END IF;
	   CLOSE c_no_of_imp;
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_no_of_imp = ' || l_no_of_imp.counter);

	   OPEN c_no_of_active;
	   FETCH c_no_of_active INTO l_no_of_active;
       IF c_no_of_active%NOTFOUND THEN
          RAISE NO_DATA_FOUND;
       END IF;
	   CLOSE c_no_of_active;
	igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_no_of_active = ' || l_no_of_active);

	   OPEN c_no_of_inactive;
	   FETCH c_no_of_inactive INTO l_no_of_inactive;
       IF c_no_of_inactive%NOTFOUND THEN
          RAISE NO_DATA_FOUND;
       END IF;
	   CLOSE c_no_of_inactive;
	igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_no_of_inactive = ' || l_no_of_inactive);

       -- Get the total number of units for the asset
       OPEN c_units;
	   FETCH c_units INTO l_units;
       IF c_units%NOTFOUND THEN
          RAISE NO_DATA_FOUND;
       END IF;
       CLOSE c_units;
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Asset total units: '||l_units);

       -- get the number of units involved in the transfer
       OPEN c_transfer_units;
       FETCH c_transfer_units INTO l_transfer_units;
       IF c_transfer_units%NOTFOUND THEN
          RAISE NO_DATA_FOUND;
       END IF;
       CLOSE c_transfer_units;
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_transfer_units: '||l_transfer_units);

       -- fetch historic salvage value and cost for the asset
       OPEN c_get_asset_book(p_asset_hdr_rec.asset_id,
                             p_asset_hdr_rec.book_type_code);
       FETCH c_get_asset_book INTO l_get_asset_book;
       IF c_get_asset_book%NOTFOUND THEN
          RAISE NO_DATA_FOUND;
       END IF;
       CLOSE c_get_asset_book;
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_get_asset_book- Cost: '||l_get_asset_book.cost);
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_get_asset_book- salvage_value: '||l_get_asset_book.salvage_value);
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path
       		,'l_get_asset_book- period_counter_fully_reserved: '||l_get_asset_book.period_counter_fully_reserved);


       -- get asset amounts
       IF NOT Calc_Asset_Amounts(l_prev_adjustment_id,
                                 p_asset_hdr_rec.asset_id,
                                 p_asset_hdr_rec.book_type_code,
                                 l_current_period_counter,
                                 l_prior_period_counter,
                                 l_get_asset_book.cost,
                                 l_get_asset_book.salvage_value,
                                 p_trans_rec.transaction_header_id,
                                 l_units,
                                 l_transfer_units,
                                 l_ab_amounts,
                                 l_iac_fa_dep_amounts)
       THEN
          RAISE NO_DATA_FOUND;
       END IF;

	i := 0;
	FOR l_all_dist in c_all_dist
	LOOP
		igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'----------Loop : '||i||'-----------------');
		igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_all_dist.distribution_id: '||l_all_dist.distribution_id);
		igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_all_dist.transaction_header_id_in: '||l_all_dist.transaction_header_id_in);
		igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_all_dist.units_assigned: '||l_all_dist.units_assigned);
		igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_all_dist.transaction_header_id_out: '||l_all_dist.transaction_header_id_out);
		igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_all_dist.transaction_units: '||l_all_dist.transaction_units);
		i:=i+1;
	END LOOP;

       -- process all the distributions involved in the transfer
       i := 0;
       FOR l_all_dist in c_all_dist
	   LOOP
		   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Distribution id 	:'||l_all_dist.distribution_id);
		   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Units for dist:'||l_all_dist.units_assigned);

           -- this distribution_id value is set when transaction_header_id_out is the
           -- p_trans_rec.transaction_header_id
           IF (l_all_dist.transaction_header_id_out = p_trans_rec.transaction_header_id) THEN
               l_old_dist := l_all_dist.distribution_id;
               inact_cnt := inact_cnt + 1;
           ELSE
               l_old_dist := NULL;
           END IF;
	   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_old_dist: '||l_old_dist);
	   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'inact_cnt: '||inact_cnt);

           -- Get the impacted distribution values
           -- this distribution_id value is set when transaction_header_id_in is the
           -- p_trans_rec.transaction_header_id
           IF (l_all_dist.transaction_header_id_in = p_trans_rec.transaction_header_id) THEN
              l_impacted_dist := l_all_dist.distribution_id;
              l_impacted_units := l_all_dist.units_assigned;
           -- increment counter for impacted active dists
              act_cnt := act_cnt + 1;
           ELSIF (l_all_dist.transaction_header_id_in <> p_trans_rec.transaction_header_id
                    AND l_all_dist.transaction_header_id_out IS NULL) THEN
              -- dist is active but was not involved in the transfer
              l_impacted_dist := NULL;
              l_impacted_units := NULL;
           END IF;
	   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_impacted_dist: '||l_impacted_dist);
	   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_impacted_units: '||l_impacted_units);
	   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'act_cnt: '||act_cnt);

           -- keep a count of the active rows for rounding difference
           IF (l_all_dist.transaction_header_id_out IS NULL) THEN
              i := i + 1;
           END IF;
	   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'i: '||i);

           -- prorate asset balance and ytd values for the distribution
           -- in parameters are asset level values
           -- out params are prorated dist values
           IF (l_all_dist.distribution_id = l_impacted_dist) THEN
              -- proration is for an impacted active new distribution
              -- created by the Transfer process
              Prorate_amount_for_dist(
                                      p_dist_id            => l_all_dist.distribution_id,
                                      p_units_dist         => l_all_dist.units_assigned,
                                      p_units_total        => l_units,
                                      p_ab_amounts         => l_ab_amounts,
                                      p_reval_reserve      => l_reval_reserve,
                                      p_general_fund       => l_general_fund,
                                      p_backlog_deprn      => l_Backlog_deprn_reserve,
                                      p_deprn_reserve      => l_deprn_reserve,
                                      p_adjusted_cost      => l_adjusted_cost,
                                      p_net_book_value     => l_net_book_value,
                                      p_deprn_per          => l_deprn_per,
                                      p_op_acct            => l_op_acct,
                                      p_ytd_deprn          => l_ytd_deprn,
                                      p_op_acct_ytd        => l_op_acct_ytd,
                                      p_rr_blog            => l_reval_reserve_backlog,
                                      p_op_blog            => l_operating_acct_backlog,
                                      p_gf_per             => l_general_fund_per
		                             );

                -- now prorate for the impacted dist in igi_iac_fa_deprn
                Prorate_amount_for_fa_dist(P_dist_id       => l_all_dist.distribution_id,
                                           P_units_dist    => l_all_dist.units_assigned,
                                           P_units_total   => l_units,
                                           P_ab_amounts    => l_iac_fa_dep_amounts,
                                           P_deprn_period  => l_fa_deprn_period,
                                           P_deprn_ytd 	   => l_fa_deprn_ytd,
                                           P_deprn_reserve => l_fa_deprn_reserve);

            ELSE
               -- for other distributions which are active but not affected by
               -- Transfers and the distributions which will be made ineffective by
               -- the Transfers process, retrieve the amounts for the distribution from
               -- igi_iac_det_balances table
               OPEN c_iac_dist(l_all_dist.distribution_id,
                               l_prev_adjustment_id
                              );
               FETCH c_iac_dist INTO l_iac_dist;
               IF c_iac_dist%NOTFOUND THEN
                  RAISE NO_DATA_FOUND;
               END IF;
               CLOSE c_iac_dist;
	       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_iac_dist.ADJUSTMENT_ID: '||l_iac_dist.ADJUSTMENT_ID);
	       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_iac_dist.DISTRIBUTION_ID: '||l_iac_dist.DISTRIBUTION_ID);
	       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_iac_dist.PERIOD_COUNTER: '||l_iac_dist.PERIOD_COUNTER);
	       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_iac_dist.NET_BOOK_VALUE: '||l_iac_dist.NET_BOOK_VALUE);
	       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_iac_dist.ADJUSTMENT_COST: '||l_iac_dist.ADJUSTMENT_COST);
	       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_iac_dist.REVAL_RESERVE_COST: '||l_iac_dist.REVAL_RESERVE_COST);
	       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_iac_dist.REVAL_RESERVE_BACKLOG: '||l_iac_dist.REVAL_RESERVE_BACKLOG);
	       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_iac_dist.REVAL_RESERVE_GEN_FUND: '||l_iac_dist.REVAL_RESERVE_GEN_FUND);
	       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_iac_dist.REVAL_RESERVE_NET: '||l_iac_dist.REVAL_RESERVE_NET);
	       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_iac_dist.OPERATING_ACCT_COST: '||l_iac_dist.OPERATING_ACCT_COST);
	       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_iac_dist.OPERATING_ACCT_BACKLOG: '||l_iac_dist.OPERATING_ACCT_BACKLOG);
	       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_iac_dist.OPERATING_ACCT_NET: '||l_iac_dist.OPERATING_ACCT_NET);
	       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_iac_dist.OPERATING_ACCT_YTD: '||l_iac_dist.OPERATING_ACCT_YTD);
	       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_iac_dist.DEPRN_PERIOD: '||l_iac_dist.DEPRN_PERIOD);
	       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_iac_dist.DEPRN_YTD: '||l_iac_dist.DEPRN_YTD);
	       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_iac_dist.DEPRN_RESERVE: '||l_iac_dist.DEPRN_RESERVE);
	       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_iac_dist.DEPRN_RESERVE_BACKLOG: '||l_iac_dist.DEPRN_RESERVE_BACKLOG);
	       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_iac_dist.GENERAL_FUND_PER: '||l_iac_dist.GENERAL_FUND_PER);
	       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_iac_dist.GENERAL_FUND_ACC: '||l_iac_dist.GENERAL_FUND_ACC);
	       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_iac_dist.LAST_REVAL_DATE: '||l_iac_dist.LAST_REVAL_DATE);
	       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_iac_dist.CURRENT_REVAL_FACTOR: '||l_iac_dist.CURRENT_REVAL_FACTOR);
	       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_iac_dist.CUMULATIVE_REVAL_FACTOR: '||l_iac_dist.CUMULATIVE_REVAL_FACTOR);

               l_reval_reserve         := l_iac_dist.reval_reserve_net;
               l_general_fund          := l_iac_dist.general_fund_acc;
               l_backlog_deprn_reserve := l_iac_dist.deprn_reserve_backlog;
               l_deprn_reserve         := l_iac_dist.deprn_reserve;
               l_adjusted_cost         := l_iac_dist.adjustment_cost;
               l_net_book_value        := l_iac_dist.net_book_value;
               l_deprn_per             := l_iac_dist.deprn_period;
               l_ytd_deprn             := l_iac_dist.deprn_ytd;
               l_op_acct               := l_iac_dist.operating_acct_net;
               l_op_acct_ytd           := l_iac_dist.operating_acct_ytd;
               l_general_fund_per      := l_iac_dist.general_fund_per;
               l_reval_reserve_backlog := l_iac_dist.reval_reserve_backlog;
               l_operating_acct_backlog:= l_iac_dist.operating_acct_backlog;

               -- retrieve the values from igi_iac_fa_deprn
               OPEN c_fa_dist_data(l_prev_adjustment_id,
                                   l_all_dist.distribution_id
                                  );
               FETCH c_fa_dist_data INTO l_fa_dist_data;
               IF c_fa_dist_data%NOTFOUND THEN
                  RAISE NO_DATA_FOUND;
               END IF;
               CLOSE c_fa_dist_data;

            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_fa_dist_data.ADJUSTMENT_ID: '||l_fa_dist_data.ADJUSTMENT_ID);
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_fa_dist_data.DISTRIBUTION_ID: '||l_fa_dist_data.DISTRIBUTION_ID);
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_fa_dist_data.DEPRN_PERIOD: '||l_fa_dist_data.DEPRN_PERIOD);
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_fa_dist_data.DEPRN_YTD: '||l_fa_dist_data.DEPRN_YTD);
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_fa_dist_data.DEPRN_RESERVE: '||l_fa_dist_data.DEPRN_RESERVE);

               l_fa_deprn_period   := l_fa_dist_data.deprn_period;
               l_fa_deprn_reserve  := l_fa_dist_data.deprn_reserve;
               l_fa_deprn_ytd      := l_fa_dist_data.deprn_ytd;
            END IF; -- end proration

            -- calculate dist catchup amounts
            IF (g_prior_period AND
                 l_all_dist.distribution_id IN (l_impacted_dist, l_old_dist)) THEN
                     Prorate_Catchup_Amounts(p_dist_id => l_all_dist.distribution_id,
                                             p_units_dist       => l_all_dist.units_assigned,
                                             p_transfer_units   => l_transfer_units,
                                             p_ab_dep_exp       => l_ab_amounts.dep_expense_catchup,
                                             p_ab_op_exp        => l_ab_amounts.op_expense_catchup,
                                             p_fa_ab_dep_exp    => l_iac_fa_dep_amounts.dep_expense_catchup,
                                             p_dist_dep_exp     => l_deprn_expense,
                                             p_dist_op_exp      => l_dist_op_exp,
                                             p_fa_dist_dep_exp  => l_fa_deprn_expense
                                            );
            ELSE
               l_deprn_expense := 0;
               l_dist_op_exp   := 0;
               l_fa_deprn_expense := 0;
            END IF;
    	    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_deprn_expense: '||l_deprn_expense);
    	    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_dist_op_exp: '||l_dist_op_exp);
    	    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_fa_deprn_expense: '||l_fa_deprn_expense);

            -- find all the account ccids for the distribution
            find_ccid(p_asset_hdr_rec.book_type_code,
                      p_asset_hdr_rec.asset_id,
                      p_trans_rec.transaction_header_id,
                      l_all_dist.distribution_id,
                      l_reval_ccid,
                      l_gen_fund_ccid,
                      l_backlog_ccid,
                      l_deprn_ccid,
                      l_cost_ccid,
                      l_op_expense_ccid,
                      l_expense_ccid
                      );

            -- prepare distribution data for igi_iac_det_balances
            -- igi_iac_fa_deprn and igi_iac_adjustments
            -- Rounding All amounts
            IF IGI_IAC_COMMON_UTILS.Iac_round(l_reval_reserve,
                                              p_asset_hdr_rec.book_type_code) THEN
               null;
            END IF;
            IF IGI_IAC_COMMON_UTILS.Iac_round(l_general_fund,
                                              p_asset_hdr_rec.book_type_code) THEN
               null;
            END IF;
            IF IGI_IAC_COMMON_UTILS.Iac_round(l_backlog_deprn_reserve,
                                              p_asset_hdr_rec.book_type_code) THEN
               null;
            END IF;
            IF IGI_IAC_COMMON_UTILS.Iac_round(l_deprn_reserve,
                                              p_asset_hdr_rec.book_type_code) THEN
               null;
            END IF;
            IF IGI_IAC_COMMON_UTILS.Iac_round(l_adjusted_cost,
                                              p_asset_hdr_rec.book_type_code) THEN
               null;
            END IF;
            IF IGI_IAC_COMMON_UTILS.Iac_round(l_op_acct,
                                              p_asset_hdr_rec.book_type_code) THEN
               null;
            END IF;
            IF IGI_IAC_COMMON_UTILS.Iac_round(l_net_book_value,
                                              p_asset_hdr_rec.book_type_code) THEN
               null;
            END IF;
            IF IGI_IAC_COMMON_UTILS.Iac_round(l_deprn_per,
                                              p_asset_hdr_rec.book_type_code) THEN
               null;
            END IF;
            IF IGI_IAC_COMMON_UTILS.Iac_round(l_ytd_deprn,
                                              p_asset_hdr_rec.book_type_code) THEN
               null;
            END IF;
            IF IGI_IAC_COMMON_UTILS.Iac_round(l_op_acct_ytd,
                                              p_asset_hdr_rec.book_type_code) THEN
               null;
            END IF;
            IF IGI_IAC_COMMON_UTILS.Iac_round(l_reval_reserve_backlog,
                                              p_asset_hdr_rec.book_type_code) THEN
               null;
            END IF;
            IF IGI_IAC_COMMON_UTILS.Iac_round(l_operating_acct_backlog,
                                              p_asset_hdr_rec.book_type_code) THEN
               null;
            END IF;
            IF IGI_IAC_COMMON_UTILS.Iac_round(l_general_fund_per,
                                              p_asset_hdr_rec.book_type_code) THEN
               null;
            END IF;
            IF IGI_IAC_COMMON_UTILS.Iac_round(l_fa_deprn_period,
                                              p_asset_hdr_rec.book_type_code) THEN
               null;
            END IF;
            IF IGI_IAC_COMMON_UTILS.Iac_round(l_fa_deprn_reserve,
                                              p_asset_hdr_rec.book_type_code) THEN
               null;
            END IF;
            IF IGI_IAC_COMMON_UTILS.Iac_round(l_fa_deprn_ytd,
                                              p_asset_hdr_rec.book_type_code) THEN
               null;
            END IF;

            IF g_prior_period THEN
               -- do currency rounding for the catchup amounts
               IF IGI_IAC_COMMON_UTILS.Iac_round(l_deprn_expense,
                                                 p_asset_hdr_rec.book_type_code) THEN
					NULL;
               END IF;
               IF IGI_IAC_COMMON_UTILS.Iac_round(l_dist_op_exp,
                                                 p_asset_hdr_rec.book_type_code) THEN
					NULL;
               END IF;
            END IF; -- prior period

            IF l_all_dist.distribution_id <> nvl(l_old_dist, -1) THEN
              -- maintain running total for the active distributions
              l_reval_reserve_sum          :=l_reval_reserve+l_reval_reserve_sum;
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_reval_reserve_sum: '||l_reval_reserve_sum);
              l_general_fund_sum           :=l_general_fund+l_general_fund_sum;
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_general_fund_sum: '||l_general_fund_sum);
              l_Backlog_deprn_reserve_sum  :=l_Backlog_deprn_reserve+l_Backlog_deprn_reserve_sum;
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_Backlog_deprn_reserve_sum: '||l_Backlog_deprn_reserve_sum);
              l_deprn_reserve_sum		    :=l_deprn_reserve+l_deprn_reserve_sum;
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_deprn_reserve_sum: '||l_deprn_reserve_sum);
              l_adjusted_cost_sum          :=l_adjusted_cost+l_adjusted_cost_sum;
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_adjusted_cost_sum: '||l_adjusted_cost_sum);
              l_net_book_value_sum         :=l_net_book_value+l_net_book_value_sum;
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_net_book_value_sum: '||l_net_book_value_sum);
              l_deprn_per_sum              :=l_deprn_per+l_deprn_per_sum;
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_deprn_per_sum: '||l_deprn_per_sum);
              l_ytd_deprn_sum              :=l_ytd_deprn+l_ytd_deprn_sum;
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_ytd_deprn_sum: '||l_ytd_deprn_sum);
              l_op_acct_sum                :=l_op_acct+l_op_acct_sum;
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_op_acct_sum: '||l_op_acct_sum);
              l_general_fund_per_sum       :=l_general_fund_per+l_general_fund_per_sum;
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_general_fund_per_sum: '||l_general_fund_per_sum);
              l_reval_reserve_backlog_sum  :=l_reval_reserve_backlog+l_reval_reserve_backlog_sum;
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_reval_reserve_backlog_sum: '||l_reval_reserve_backlog_sum);
              l_operating_acct_backlog_sum :=l_operating_acct_backlog+l_operating_acct_backlog_sum;
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_operating_acct_backlog_sum: '||l_operating_acct_backlog_sum);
              l_general_fund_per_sum       :=l_general_fund_per+l_general_fund_per_sum;
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_general_fund_per_sum: '||l_general_fund_per_sum);
              l_fa_deprn_period_sum        := l_fa_deprn_period_sum + l_fa_deprn_period;
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_fa_deprn_period_sum: '||l_fa_deprn_period_sum);
              l_fa_deprn_reserve_sum       := l_fa_deprn_reserve_sum + l_fa_deprn_reserve;
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_fa_deprn_reserve_sum: '||l_fa_deprn_reserve_sum);
              l_fa_deprn_ytd_sum           := l_fa_deprn_ytd_sum + l_fa_deprn_ytd;
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_fa_deprn_ytd_sum: '||l_fa_deprn_ytd_sum);

              -- add rounding diff to the last distribution
              IF (i = l_no_of_imp.counter) THEN
                  l_reval_reserve:= l_reval_reserve +
                              (l_ab_amounts.reval_reserve - l_reval_reserve_sum);
				  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_reval_reserve: '||l_reval_reserve);
                  l_general_fund:=l_general_fund +
                              (l_ab_amounts.general_fund -l_general_fund_sum);
				  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_general_fund: '||l_general_fund);
                  l_Backlog_deprn_reserve:=l_backlog_deprn_reserve +
                              (l_ab_amounts.backlog_deprn_reserve-l_Backlog_deprn_reserve_sum);
				  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_Backlog_deprn_reserve: '||l_Backlog_deprn_reserve);
                  l_deprn_reserve:=l_deprn_reserve +
                              (l_ab_amounts.deprn_reserve -l_deprn_reserve_sum);
                  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_deprn_reserve: '||l_deprn_reserve);
                  l_adjusted_cost:=l_adjusted_cost + (l_ab_amounts.adjusted_cost -l_adjusted_cost_sum);
                  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_adjusted_cost: '||l_adjusted_cost);
                  l_net_book_value:=l_net_book_value +
                              (l_ab_amounts.net_book_value -l_net_book_value_sum);
                  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_net_book_value: '||l_net_book_value);
                  l_deprn_per:=l_deprn_per +
                              (l_ab_amounts.deprn_amount -l_deprn_per_sum);
                  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_deprn_per: '||l_deprn_per);
                  l_op_acct:=l_op_acct +
                              (l_ab_amounts.operating_acct -l_op_acct_sum);
                  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_op_acct: '||l_op_acct);
                  l_reval_reserve_backlog:=l_reval_reserve_backlog +
                              (l_ab_amounts.reval_reserve_backlog -l_reval_reserve_backlog_sum);
                  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_reval_reserve_backlog: '||l_reval_reserve_backlog);
                  l_operating_acct_backlog:=l_operating_acct_backlog +
                              (l_ab_amounts.operating_acct_backlog -l_operating_acct_backlog_sum);
                  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_operating_acct_backlog: '||l_operating_acct_backlog);
                  l_general_fund_per:=l_general_fund_per +
                              (l_ab_amounts.general_fund_per -l_general_fund_per_sum);
                  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_general_fund_per: '||l_general_fund_per);
                  l_ytd_deprn:=l_ytd_deprn +
                              (l_ab_amounts.ytd_deprn -l_ytd_deprn_sum);
                  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_ytd_deprn: '||l_ytd_deprn);
                  l_fa_deprn_period :=l_fa_deprn_period +
                              (l_iac_fa_dep_amounts.deprn_period -l_fa_deprn_period_sum);
                  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_fa_deprn_period: '||l_fa_deprn_period);
                  l_fa_deprn_reserve :=l_fa_deprn_reserve +
                              (l_iac_fa_dep_amounts.deprn_reserve -l_fa_deprn_reserve_sum);
                  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_fa_deprn_reserve: '||l_fa_deprn_reserve);
                  l_fa_deprn_ytd :=l_fa_deprn_ytd +
                              (l_iac_fa_dep_amounts.deprn_ytd -l_fa_deprn_ytd_sum);
                  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_fa_deprn_ytd: '||l_fa_deprn_ytd);
              END IF;
            END IF; -- active dist rounding

            -- catchup roundings
            IF g_prior_period THEN
               IF (l_all_dist.distribution_id = l_old_dist) THEN
                  l_deprn_expense_old_sum:=l_deprn_expense+l_deprn_expense_old_sum;
		  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_deprn_expense_old_sum: '||l_deprn_expense_old_sum);
                  l_dist_op_exp_old_sum:= l_dist_op_exp_old_sum + l_dist_op_exp;
		  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_dist_op_exp_old_sum: '||l_dist_op_exp_old_sum);
                  l_fa_deprn_expense_old_sum:=l_fa_deprn_expense + l_fa_deprn_expense_old_sum;
		  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_fa_deprn_expense_old_sum: '||l_fa_deprn_expense_old_sum);
                  IF (inact_cnt = l_no_of_inactive) THEN
                      l_deprn_expense := l_deprn_expense +
                                          (l_ab_amounts.dep_expense_catchup - l_deprn_expense_old_sum);
                      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_deprn_expense: '||l_deprn_expense);
                      l_dist_op_exp := l_dist_op_exp +
                                          (l_ab_amounts.op_expense_catchup - l_dist_op_exp_old_sum);
                      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_dist_op_exp: '||l_dist_op_exp);
                      l_fa_deprn_expense := l_fa_deprn_expense +
                                          (l_iac_fa_dep_amounts.dep_expense_catchup - l_fa_deprn_expense_old_sum);
                      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_fa_deprn_expense: '||l_fa_deprn_expense);
                  END IF;
               ELSIF (l_all_dist.distribution_id = l_impacted_dist) THEN
                  l_deprn_expense_imp_sum:=l_deprn_expense+l_deprn_expense_imp_sum;
		  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_deprn_expense_imp_sum: '||l_deprn_expense_imp_sum);
                  l_dist_op_exp_imp_sum:= l_dist_op_exp_imp_sum + l_dist_op_exp;
		  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_dist_op_exp_imp_sum: '||l_dist_op_exp_imp_sum);
                  l_fa_deprn_expense_imp_sum:=l_fa_deprn_expense + l_fa_deprn_expense_imp_sum;
		  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_fa_deprn_expense_imp_sum: '||l_fa_deprn_expense_imp_sum);
                  IF (act_cnt = l_no_of_active) THEN
                      l_deprn_expense := l_deprn_expense +
                                          (l_ab_amounts.dep_expense_catchup - l_deprn_expense_imp_sum);
					  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_deprn_expense: '||l_deprn_expense);
                      l_dist_op_exp := l_dist_op_exp +
                                          (l_ab_amounts.op_expense_catchup - l_dist_op_exp_imp_sum);
                      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_dist_op_exp: '||l_dist_op_exp);
                      l_fa_deprn_expense := l_fa_deprn_expense +
                                          (l_iac_fa_dep_amounts.dep_expense_catchup - l_fa_deprn_expense_imp_sum);
                      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_fa_deprn_expense: '||l_fa_deprn_expense);
                   END IF;
               END IF;
            ELSE
               l_deprn_expense := 0;
	       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_deprn_expense: '||l_deprn_expense);
               l_dist_op_exp   := 0;
	       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_dist_op_exp: '||l_dist_op_exp);
               l_fa_deprn_expense := 0;
	       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_fa_deprn_expense: '||l_fa_deprn_expense);
            END IF;  -- catchup roundings end

            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Amounts after rounding for dist id:  '||l_all_dist.distribution_id);
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Adjusted Cost		:'||l_adjusted_cost);
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Net Book Value		:'||l_net_book_value);
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Reval Reserve		:'||l_reval_reserve);
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'General Fund		:'||l_general_fund);
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Reval Reserve Backlog	:'||l_reval_reserve_backlog);
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Operating Account	:'||l_op_acct);
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Deprn Reserve		:'||l_deprn_reserve);
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Backlog Deprn Reserce	:'||l_backlog_deprn_reserve);
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Deprn Reserve		:'||l_deprn_reserve);
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'YTD Deprn		:'||l_ytd_deprn);
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Generl Fund		:'||l_general_fund);

            -- create the catchup accounting entries
            IF g_prior_period THEN
               -- create the accounting entries for prior period
               IF l_impacted_dist = l_all_dist.distribution_id  THEN
				  insert_data_adj(l_adj_id,
					              p_asset_hdr_rec.book_type_code,
					              l_expense_ccid,
					              nvl(p_asset_hdr_rec.set_of_books_id,l_sob_id),
					              'DR',
					              l_deprn_expense,
					              'EXPENSE',
					              l_all_dist.units_assigned,
					              p_asset_hdr_rec.asset_id,
					              l_all_dist.distribution_id,
					              l_current_period_counter,
                                  null,
                                  null,
                                  p_event_id => p_event_id
					              );
--                   IF (l_ab_amounts.cumulative_reval_factor < 1) THEN
                      -- operating expense
    		          insert_data_adj(l_adj_id,
					                  p_asset_hdr_rec.book_type_code,
					                  l_op_expense_ccid,
					                  nvl(p_asset_hdr_rec.set_of_books_id,l_sob_id),
					                  'CR',
					                  l_dist_op_exp,
					                  'OP EXPENSE',
					                  l_all_dist.units_assigned,
					                  p_asset_hdr_rec.asset_id,
					                  l_all_dist.distribution_id,
					                  l_current_period_counter,
                                      null,
                                      null,
                                      p_event_id => p_event_id
					                  );
--                  END IF;
                  -- set the periodic deprn values
               ELSIF l_old_dist = l_all_dist.distribution_id  THEN
                  -- inactive distribution
				  insert_data_adj(l_adj_id,
					              p_asset_hdr_rec.book_type_code,
					              l_expense_ccid,
					              nvl(p_asset_hdr_rec.set_of_books_id,l_sob_id),
					              'CR',
					              l_deprn_expense,
					              'EXPENSE',
					              l_all_dist.units_assigned,
					              p_asset_hdr_rec.asset_id,
					              l_all_dist.distribution_id,
					              l_current_period_counter,
                                  null,
                                  null,
                                  p_event_id => p_event_id
					              );
 --                 IF (l_ab_amounts.cumulative_reval_factor < 1) THEN
                      -- operating expense
                      insert_data_adj(l_adj_id,
                                      p_asset_hdr_rec.book_type_code,
                                      l_op_expense_ccid,
                                      nvl(p_asset_hdr_rec.set_of_books_id,l_sob_id),
                                      'DR',
                                      l_dist_op_exp,
                                      'OP EXPENSE',
                                      l_all_dist.units_assigned,
                                      p_asset_hdr_rec.asset_id,
                                      l_all_dist.distribution_id,
                                      l_current_period_counter,
                                      null,
                                      null,
                                      p_event_id => p_event_id
                                      );
   --               END IF;
               END IF;-- catchup acct entries
            END IF; -- end of prior period catchup calc

            -- create accounting netries for the new distributions
            -- offset the old dist(s)
            IF l_all_dist.distribution_id = l_impacted_dist THEN
                  -- For Reval reserve
                  insert_data_adj(l_adj_id,
                                  p_asset_hdr_rec.book_type_code,
                                  l_reval_ccid,
                                  nvl(p_asset_hdr_rec.set_of_books_id,l_sob_id),
                                  'CR',
                                  l_reval_reserve,
                                  'REVAL RESERVE',
                                  l_all_dist.units_assigned,
                                  p_asset_hdr_rec.asset_id,
                                  l_all_dist.distribution_id,
                                  l_current_period_counter,
                                  null,
                                  null,
                                  p_event_id => p_event_id
					              );

                  -- For General fund
                  insert_data_adj(l_adj_id,
                                  p_asset_hdr_rec.book_type_code,
                                  l_gen_fund_ccid,
                                  nvl(p_asset_hdr_rec.set_of_books_id,l_sob_id),
                                  'CR',
                                  l_general_fund,
                                  'GENERAL FUND',
                                  l_all_dist.units_assigned,
                                  p_asset_hdr_rec.asset_id,
                                  l_all_dist.distribution_id,
                                  l_current_period_counter,
                                  'REVAL RESERVE',
                                  l_reval_ccid, --null
                                  p_event_id => p_event_id
                                  );

			      -- For backlog depreciation reserve
                   insert_data_adj(l_adj_id,
                                   p_asset_hdr_rec.book_type_code,
                                   l_backlog_ccid,
                                   nvl(p_asset_hdr_rec.set_of_books_id,l_sob_id),
                                   'CR',
                                   l_reval_reserve_backlog, -- l_backlog_deprn_reserve,
                                   'BL RESERVE',
                                   l_all_dist.units_assigned,
                                   p_asset_hdr_rec.asset_id,
                                   l_all_dist.distribution_id,
                                   l_current_period_counter,
                                   'REVAL RESERVE',
                                   l_reval_ccid,
                                   p_event_id => p_event_id
                                   );

                   insert_data_adj(l_adj_id,
                                   p_asset_hdr_rec.book_type_code,
                                   l_backlog_ccid,
                                   nvl(p_asset_hdr_rec.set_of_books_id,l_sob_id),
                                   'CR',
                                   l_operating_acct_backlog, --l_backlog_deprn_reserve,
                                   'BL RESERVE',
                                   l_all_dist.units_assigned,
                                   p_asset_hdr_rec.asset_id,
                                   l_all_dist.distribution_id,
                                   l_current_period_counter,
                                   'OP EXPENSE',
                                   l_op_expense_ccid,
                                   p_event_id => p_event_id
                                   );

			      -- depriciation reserve
                  insert_data_adj(l_adj_id,
                                  p_asset_hdr_rec.book_type_code,
                                  l_deprn_ccid,
                                  nvl(p_asset_hdr_rec.set_of_books_id,l_sob_id),
                                  'CR',
                                  l_deprn_reserve,
                                  'RESERVE',
                                  l_all_dist.units_assigned,
                                  p_asset_hdr_rec.asset_id,
                                  l_all_dist.distribution_id,
                                  l_current_period_counter,
                                  null,
                                  null,
                                  p_event_id => p_event_id
                                  );
			      -- For cost account
                  IF (l_ab_amounts.cumulative_reval_factor >= 1) THEN
                    l_adj_offset_type := 'REVAL RESERVE';
                    l_report_ccid := l_reval_ccid;
                  ELSE
                    l_adj_offset_type := 'OP EXPENSE';
                    l_report_ccid := l_op_expense_ccid;
                  END IF;

                  insert_data_adj(l_adj_id,
                                  p_asset_hdr_rec.book_type_code,
                                  l_cost_ccid,
                                  nvl(p_asset_hdr_rec.set_of_books_id,l_sob_id),
                                  'DR',
                                  l_adjusted_cost,
                                  'COST',
                                  l_all_dist.units_assigned,
                                  p_asset_hdr_rec.asset_id,
                                  l_all_dist.distribution_id,
                                  l_current_period_counter,
                                  l_adj_offset_type,
                                  l_report_ccid,
                                  p_event_id => p_event_id
                                  );

		    ELSIF l_all_dist.distribution_id=l_old_dist THEN

			      -- For Reval reserve
                  insert_data_adj(l_adj_id,
                                  p_asset_hdr_rec.book_type_code,
                                  l_reval_ccid,
                                  nvl(p_asset_hdr_rec.set_of_books_id,l_sob_id),
                                  'DR',
                                  l_reval_reserve,
                                  'REVAL RESERVE',
                                  l_all_dist.units_assigned,
                                  p_asset_hdr_rec.asset_id,
                                  l_all_dist.distribution_id,
                                  l_current_period_counter,
                                  null,
                                  null,
                                  p_event_id => p_event_id
                                  );
			      -- For General fund
                  insert_data_adj(l_adj_id,
                                  p_asset_hdr_rec.book_type_code,
                                  l_gen_fund_ccid,
                                  nvl(p_asset_hdr_rec.set_of_books_id,l_sob_id),
                                  'DR',
                                  l_general_fund,
                                  'GENERAL FUND',
                                  l_all_dist.units_assigned,
                                  p_asset_hdr_rec.asset_id,
                                  l_all_dist.distribution_id,
                                  l_current_period_counter,
                                  'REVAL RESERVE',
                                  l_reval_ccid, -- null
                                  p_event_id => p_event_id
                                  );
			      -- For backlog deprn reserve
                  insert_data_adj(l_adj_id,
                                  p_asset_hdr_rec.book_type_code,
                                  l_backlog_ccid,
                                  nvl(p_asset_hdr_rec.set_of_books_id,l_sob_id),
                                  'DR',
                                  l_reval_reserve_backlog, --l_backlog_deprn_reserve,
                                  'BL RESERVE',
                                  l_all_dist.units_assigned,
                                  p_asset_hdr_rec.asset_id,
                                  l_all_dist.distribution_id,
                                  l_current_period_counter,
                                  'REVAL RESERVE',
                                  l_reval_ccid,
                                  p_event_id => p_event_id
                                  );

                  insert_data_adj(l_adj_id,
                                  p_asset_hdr_rec.book_type_code,
                                  l_backlog_ccid,
                                  nvl(p_asset_hdr_rec.set_of_books_id,l_sob_id),
                                  'DR',
                                  l_operating_acct_backlog, --l_backlog_deprn_reserve,
                                  'BL RESERVE',
                                  l_all_dist.units_assigned,
                                  p_asset_hdr_rec.asset_id,
                                  l_all_dist.distribution_id,
                                  l_current_period_counter,
                                  'OP EXPENSE',
                                  l_op_expense_ccid,
                                  p_event_id => p_event_id
                                  );

			      -- For deprn reserve
                  insert_data_adj(l_adj_id,
                                  p_asset_hdr_rec.book_type_code,
                                  l_deprn_ccid,
                                  nvl(p_asset_hdr_rec.set_of_books_id,l_sob_id),
                                  'DR',
                                  l_deprn_reserve,
                                  'RESERVE',
                                  l_all_dist.units_assigned,
                                  p_asset_hdr_rec.asset_id,
                                  l_all_dist.distribution_id,
                                  l_current_period_counter,
                                  null,
                                  null,
                                  p_event_id => p_event_id
					              );
			      -- For cost account
                  IF (l_ab_amounts.cumulative_reval_factor >= 1) THEN
                    l_adj_offset_type := 'REVAL RESERVE';
                    l_report_ccid := l_reval_ccid;
                  ELSE
                    l_adj_offset_type := 'OP EXPENSE';
                    l_report_ccid := l_op_expense_ccid;
                  END IF;

                  insert_data_adj(l_adj_id,
                                  p_asset_hdr_rec.book_type_code,
                                  l_cost_ccid,
                                  nvl(p_asset_hdr_rec.set_of_books_id,l_sob_id),
                                  'CR',
                                  l_adjusted_cost,
                                  'COST',
                                  l_all_dist.units_assigned,
                                  p_asset_hdr_rec.asset_id,
                                  l_all_dist.distribution_id,
                                  l_current_period_counter,
                                  l_adj_offset_type,
                                  l_report_ccid,
                                  p_event_id => p_event_id
                                  );
		    END IF; --end of if impacted loop

		    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Data inserted into adjustments for various accounts');
            -- Check if it the transfer is inter company
            l_interco_amount := 0;
            l_interco_count := 0;
            OPEN c_get_interco(p_asset_hdr_rec.book_type_code,
                               p_asset_hdr_rec.asset_id,
                               l_all_dist.distribution_id,
                               p_trans_rec.transaction_header_id);
            FETCH c_get_interco INTO l_interco_count;
            CLOSE c_get_interco;

            IF l_interco_count > 0 THEN
               -- calculate the intercompany amount
               l_interco_amount := l_adjusted_cost - l_deprn_reserve - l_backlog_deprn_reserve
                                   - l_reval_reserve - l_general_fund + l_deprn_expense
                                   - l_dist_op_exp ;
               IF (l_all_dist.distribution_id = l_old_dist) THEN
                  -- old distribution
                  -- get ccid
                  -- get the ccod for interco ar
                  l_return_value:=IGI_IAC_COMMON_UTILS.get_account_ccid(p_asset_hdr_rec.book_type_code,
                                                                        p_asset_hdr_rec.asset_id,
                                                                        l_all_dist.distribution_id,
                                                                        'INTERCO_AR_ACCT',
                                                                        p_trans_rec.transaction_header_id,
                                                                        'TRANSFER',
                                                                        l_interco_ccid);

                  -- insert the accounting entry
                  insert_data_adj(l_adj_id,
                                  p_asset_hdr_rec.book_type_code,
                                  l_interco_ccid, -- l_interco_data.code_combination_id,
                                  nvl(p_asset_hdr_rec.set_of_books_id,l_sob_id),
                                  'DR', -- l_interco_data.debit_credit_flag,
                                  l_interco_amount,
                                  'INTERCO AR', --l_interco_data.adjustment_type,
                                  l_all_dist.units_assigned,
                                  p_asset_hdr_rec.asset_id,
                                  l_all_dist.distribution_id,
                                  l_current_period_counter,
                                  null,
                                  null,
                                  p_event_id => p_event_id
                                  );
               ELSIF (l_all_dist.distribution_id = l_impacted_dist) THEN
                  -- new distribution
                  -- get the ccod for interco ap
                  l_return_value:=IGI_IAC_COMMON_UTILS.get_account_ccid(p_asset_hdr_rec.book_type_code,
                                                                        p_asset_hdr_rec.asset_id,
                                                                        l_all_dist.distribution_id,
                                                                        'INTERCO_AP_ACCT',
                                                                        p_trans_rec.transaction_header_id,
                                                                        'TRANSFER',
                                                                        l_interco_ccid);

                   -- accounting entry
                   insert_data_adj(l_adj_id,
                                   p_asset_hdr_rec.book_type_code,
                                   l_interco_ccid, -- l_interco_data.code_combination_id,
                                   nvl(p_asset_hdr_rec.set_of_books_id,l_sob_id),
                                   'CR', -- l_interco_data.debit_credit_flag,
                                   l_interco_amount,
                                   'INTERCO AP', --l_interco_data.adjustment_type,
                                   l_all_dist.units_assigned,
                                   p_asset_hdr_rec.asset_id,
                                   l_all_dist.distribution_id,
                                   l_current_period_counter,
                                   null,
                                   null,
                                   p_event_id => p_event_id
                                   );
               END IF; -- dist old or impacted
            END IF; -- l_interco_data

            -- inserting data into the detail balances tables
            IF l_all_dist.distribution_id = l_old_dist THEN
               IF g_prior_period THEN
                 l_ytd_deprn := l_ytd_deprn - l_deprn_expense;
                 l_fa_deprn_ytd  := l_fa_deprn_ytd - l_fa_deprn_expense;
               END IF;
		       -- Impacted old distribution
               -- create inactive distribution
			   insert_data_det(l_adj_id,
					p_asset_hdr_rec.asset_id,
					l_all_dist.distribution_id,
					l_current_period_counter,
					p_asset_hdr_rec.book_type_code,
					0,
					0,
					0,
					0,
					0,
					0, -- l_op_acct,
					0,
					0,
					l_ytd_deprn,
					0,
					0,
					0,
					l_ab_amounts.current_reval_factor,
					l_ab_amounts.cumulative_reval_factor,
					'N',
					0, -- l_op_acct_ytd,
					0, --l_operating_acct_backlog,
					l_ab_amounts.last_reval_date
					);

               l_rowid := NULL;
			   igi_iac_fa_deprn_pkg.insert_row(
                          x_rowid			=> l_rowid,
                          x_book_type_code	=> p_asset_hdr_rec.book_type_code,
                          x_asset_id		=> p_asset_hdr_rec.asset_id,
                          x_distribution_id	=> l_all_dist.distribution_id,
                          x_period_counter	=> l_current_period_counter,
                          x_adjustment_id	=> l_adj_id,
                          x_deprn_period	=> 0,
                          x_deprn_ytd		=> l_fa_deprn_ytd ,
                          x_deprn_reserve	=> 0,
                          x_active_flag		=> 'N',
                          x_mode			=> 'R');

            ELSIF l_all_dist.distribution_id= l_impacted_dist THEN

               IF g_prior_period THEN
			      l_deprn_per:=l_deprn_expense;
			      l_general_fund_per:= l_deprn_per;
			      l_ytd_deprn:=l_deprn_per;
                  l_fa_deprn_ytd := l_fa_deprn_expense;
               ELSE
                  --This check will reset values to zero in case of new distributions for
                  --current period transfers
			      l_deprn_per:=0;
			      l_general_fund_per:=0;
			      l_ytd_deprn:=0;
                  l_fa_deprn_ytd := 0;
               END IF;
               -- new distribution, create an active row
               IF l_get_asset_book.period_counter_fully_reserved IS NULL THEN
                  l_iac_deprn_period_amount := l_deprn_per;
               ELSE
                  l_iac_deprn_period_amount := 0;
               END IF;

               insert_data_det(l_adj_id,
					p_asset_hdr_rec.asset_id,
					l_all_dist.distribution_id,
					l_current_period_counter,
					p_asset_hdr_rec.book_type_code,
					l_adjusted_cost,
					l_net_book_value,
					l_reval_reserve,
					l_general_fund,
					l_reval_reserve_backlog,
					l_op_acct, --0,
					l_deprn_reserve,
					l_backlog_deprn_reserve,
					l_ytd_deprn, --0,
					l_iac_deprn_period_amount,
					l_general_fund,
					l_general_fund_per,
					l_ab_amounts.current_reval_factor,
					l_ab_amounts.cumulative_reval_factor,
					null,
					0, -- l_op_acct_ytd is no longer maintained
					l_operating_acct_backlog, --0,
					l_ab_amounts.last_reval_date
					);

               -- insert into igi_iac_fa_deprn
               IF l_get_asset_book.period_counter_fully_reserved IS NULL THEN
                	    l_fa_deprn_period_amount := l_fa_deprn_period;
               ELSE
                	    l_fa_deprn_period_amount := 0;
               END IF;

               l_rowid := NULL;
               igi_iac_fa_deprn_pkg.insert_row(
                         x_rowid            => l_rowid,
                         x_book_type_code   => p_asset_hdr_rec.book_type_code,
                         x_asset_id	        => p_asset_hdr_rec.asset_id,
                         x_distribution_id  => l_all_dist.distribution_id,
                         x_period_counter   => l_current_period_counter,
                         x_adjustment_id    => l_adj_id,
                         x_deprn_period     => l_fa_deprn_period_amount,
                         x_deprn_ytd        => l_fa_deprn_ytd, -- 0,
                         x_deprn_reserve    => l_fa_deprn_reserve,
                         x_active_flag      => NULL,
                         x_mode             => 'R');

		    ELSIF l_all_dist.distribution_id NOT IN (nvl(l_impacted_dist, -1),nvl(l_old_dist, -1)) THEN

               -- active dist, not involved in transfer, being rolled forward
               IF l_get_asset_book.period_counter_fully_reserved IS NULL THEN
                  l_iac_deprn_period_amount := l_deprn_per;
               ELSE
                  l_iac_deprn_period_amount := 0;
               END IF;

               insert_data_det(l_adj_id,
                           p_asset_hdr_rec.asset_id,
                           l_all_dist.distribution_id,
                           l_current_period_counter,
                           p_asset_hdr_rec.book_type_code,
                           l_adjusted_cost,
                           l_net_book_value,
                           l_reval_reserve,
                           l_general_fund,
                           l_reval_reserve_backlog,
                           l_op_acct,
                           l_deprn_reserve,
                           l_backlog_deprn_reserve,
                           l_ytd_deprn,
                           l_iac_deprn_period_amount,
                           l_general_fund,
                           l_general_fund_per,
                           l_ab_amounts.current_reval_factor,
                           l_ab_amounts.cumulative_reval_factor,
                           null,
                           0, -- l_op_acct_ytd, iac no longer maintains this value
                           l_operating_acct_backlog,
                           l_ab_amounts.last_reval_date
                            );

               -- insert into igi_iac_fa_deprn
               IF l_get_asset_book.period_counter_fully_reserved IS NULL THEN
                  l_fa_deprn_period_amount := l_fa_dist_data.deprn_period;
               ELSE
                  l_fa_deprn_period_amount := 0;
               END IF;

               l_rowid := NULL;
               igi_iac_fa_deprn_pkg.insert_row(
                         x_rowid           => l_rowid,
                         x_book_type_code  => p_asset_hdr_rec.book_type_code,
                         x_asset_id	       => p_asset_hdr_rec.asset_id,
                         x_distribution_id => l_all_dist.distribution_id,
                         x_period_counter  => l_current_period_counter,
                         x_adjustment_id   => l_adj_id,
                         x_deprn_period    => l_fa_deprn_period_amount,
                         x_deprn_ytd       => l_fa_deprn_ytd ,
                         x_deprn_reserve   => l_fa_deprn_reserve,
                         x_active_flag     => NULL,
                         x_mode            => 'R');

		    END IF;
		-- End of loop for insert into det_balances table
      	igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Data inserted into detail balances');
	   END LOOP;
	   -- End of loop for all active distributions
       -- Roll the inactive distributions forward for the new adjustment id
       Roll_Inactive_Forward(p_adjustment_id  => l_prev_adjustment_id,
                             p_new_adj_id     => l_adj_id,
                             p_book_type_code => p_asset_hdr_rec.book_type_code,
                             p_asset_id       => p_asset_hdr_rec.asset_id,
                             p_curr_prd_cntr  => l_current_period_counter
                             );

      for l_ex in c_exists  (cp_period_counter => l_current_period_counter
                      , cp_asset_id      => p_asset_hdr_rec.asset_id
                      , cp_book_type_code => p_asset_hdr_rec.book_type_code
                      )
      loop
          l_exists := true;
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_exists = true');
      end loop;
       -- update asset balances table with transfer info
       IF l_ab_amounts.period_counter = l_current_period_counter THEN
           -- this is a current period transfer
       	   IF (g_Prior_period) THEN
              IF l_get_asset_book.period_counter_fully_reserved IS NULL THEN
                 l_iac_deprn_period_amount := l_ab_amounts.dep_expense_catchup;
              ELSE
                 l_iac_deprn_period_amount := 0;
              END IF;

              IGI_IAC_ASSET_BALANCES_PKG.update_row (
  		    		x_asset_id                          =>p_asset_hdr_rec.asset_id,
    				x_book_type_code                    =>p_asset_hdr_rec.book_type_code,
    				x_period_counter                    =>l_current_period_counter,
    				x_net_book_value                    =>l_ab_amounts.net_book_value,
    				x_adjusted_cost                     =>l_ab_amounts.adjusted_cost,
    				x_operating_acct                    =>l_ab_amounts.operating_acct,
    				x_reval_reserve                     =>l_ab_amounts.reval_reserve,
    				x_deprn_amount                      =>l_iac_deprn_period_amount,
    				x_deprn_reserve                     =>l_ab_amounts.deprn_reserve,
    				x_backlog_deprn_reserve             =>l_ab_amounts.backlog_deprn_reserve,
    				x_general_fund                      =>l_ab_amounts.general_fund,
    				x_last_reval_date                   =>l_ab_amounts.last_reval_date,
    				x_current_reval_factor              =>l_ab_amounts.current_reval_factor,
    				x_cumulative_reval_factor           =>l_ab_amounts.cumulative_reval_factor,
    				x_mode                              =>'R'
 				 );

      	        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Data Updated in Asset balances for the catch up');
	       END IF;

       ELSE
           -- this is a prior period transfer
           IF (g_Prior_period) THEN
               l_deprn_amount := l_ab_amounts.dep_expense_catchup;
           ELSE
               l_deprn_amount := l_ab_amounts.deprn_amount;
           END IF;

           -- set deprn amount
           IF l_get_asset_book.period_counter_fully_reserved IS NULL THEN
              l_iac_deprn_period_amount := l_deprn_amount;
           ELSE
              l_iac_deprn_period_amount := 0;
           END IF;
           l_rowid := NULL;
       IF l_exists THEN
            IGI_IAC_ASSET_BALANCES_PKG.update_row (
  		    		x_asset_id                          =>p_asset_hdr_rec.asset_id,
    				x_book_type_code                    =>p_asset_hdr_rec.book_type_code,
    				x_period_counter                    =>l_current_period_counter,
    				x_net_book_value                    =>l_ab_amounts.net_book_value,
    				x_adjusted_cost                     =>l_ab_amounts.adjusted_cost,
    				x_operating_acct                    =>l_ab_amounts.operating_acct,
    				x_reval_reserve                     =>l_ab_amounts.reval_reserve,
    				x_deprn_amount                      =>l_iac_deprn_period_amount,
    				x_deprn_reserve                     =>l_ab_amounts.deprn_reserve,
    				x_backlog_deprn_reserve             =>l_ab_amounts.backlog_deprn_reserve,
    				x_general_fund                      =>l_ab_amounts.general_fund,
    				x_last_reval_date                   =>l_ab_amounts.last_reval_date,
    				x_current_reval_factor              =>l_ab_amounts.current_reval_factor,
    				x_cumulative_reval_factor           =>l_ab_amounts.cumulative_reval_factor,
    				x_mode                              =>'R'
 				 );
	    ELSE
	       IGI_IAC_ASSET_BALANCES_PKG.insert_row (
                    x_rowid                             => l_rowid,
	                x_asset_id                          =>p_asset_hdr_rec.asset_id,
    				x_book_type_code                    =>p_asset_hdr_rec.book_type_code,
    				x_period_counter                    =>l_current_period_counter,
    				x_net_book_value                    =>l_ab_amounts.net_book_value,
    				x_adjusted_cost                     =>l_ab_amounts.adjusted_cost,
    				x_operating_acct                    =>l_ab_amounts.operating_acct,
    				x_reval_reserve                     =>l_ab_amounts.reval_reserve,
    				x_deprn_amount                      =>l_iac_deprn_period_amount,
    				x_deprn_reserve                     =>l_ab_amounts.deprn_reserve,
    				x_backlog_deprn_reserve             =>l_ab_amounts.backlog_deprn_reserve,
    				x_general_fund                      =>l_ab_amounts.general_fund,
    				x_last_reval_date                   =>l_ab_amounts.last_reval_date,
    				x_current_reval_factor              =>l_ab_amounts.current_reval_factor,
    				x_cumulative_reval_factor           =>l_ab_amounts.cumulative_reval_factor,
    				x_mode                              =>'R'
                                                 );
       	        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Data Inserted in Asset balances');
       	END IF;
       END IF;

       -- update the previous active row for the asset in igi_iac_transaction_headers
       -- in order to make it inactive by setting adjustment_id_out= adjustment_id of
       -- the active row in igi_iac_transaction_headers
       IGI_IAC_TRANS_HEADERS_PKG.Update_Row(
              x_prev_adjustment_id        => l_adj_id_out,
              x_adjustment_id             => l_adj_id
                                        );

    -- transfer processing completed successfully
	RETURN TRUE;

 EXCEPTION
   WHEN e_iac_not_enabled THEN
        FA_SRVR_MSG.Add_Message(
                 Calling_FN    => 'IGI_IAC_TRANSFER_PKG.Do_Transfer',
                 Name          => 'IGI_IAC_NOT_INSTALLED'
                               );
        RETURN TRUE;

    WHEN e_not_iac_book THEN
         FA_SRVR_MSG.Add_Message(
                 Calling_FN    => 'IGI_IAC_TRANSFER_PKG.Do_Transfer',
                 Name          => 'IGI_IAC_NOT_IAC_BOOK'
                               );
        RETURN TRUE;

    WHEN e_asset_not_revalued THEN
        OPEN c_asset_num;
        FETCH c_asset_num INTO l_asset_num;
        CLOSE c_asset_num;
        FA_SRVR_MSG.Add_Message(
                    Calling_FN 	=> 'IGI_IAC_TRANSFER_PKG.Do_Transfer',
                    Name 		=> 'IGI_IAC_ASSET_NOT_REVALUED',
                    TOKEN1		=> 'ASSET_NUM',
                    VALUE1		=> l_asset_num);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'This asset has not been revalued');

        RETURN(TRUE);

    WHEN e_no_gl_info THEN

  	 igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		                                  p_full_path => l_path,
		                                  p_string => 'Could not retrive GL information for Book');

     FA_SRVR_MSG.add_message(
                Calling_Fn  => 'IGI_IAC_TRANSFER_PKG.Do_Transfer',
                Name        => 'IGI_IAC_NO_GL_INFO'
                            );
     RETURN FALSE;


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN	-- This occurs when distribution doesn't have IMPACTED or OLD link
    		RETURN(FALSE);	-- Ensures that data is rolled back;calling procedure rolls back on error, no need of rollback here

    WHEN others THEN
	    l_mesg:=SQLERRM;
	    igi_iac_debug_pkg.debug_unexpected_msg(l_path);
	    FA_SRVR_MSG.Add_Message(
	                Calling_FN 	=> 'IGI_IAC_TRANSFER_PKG.Do_Transfer',
        	        Name 		=> 'IGI_IAC_EXCEPTION',
        	        TOKEN1		=> 'PACKAGE',
        	        VALUE1		=> 'Transfers',
        	        TOKEN2		=> 'ERROR_MESSAGE',
        	        VALUE2		=> l_mesg);
        RETURN(FALSE);
 END Do_transfer;

--+=======================================================================================+
--|	Function Do_prior_transfer is called from the FA deprn Run .This would inturn   |
--|	call the do_transfer to insert data for current period counter.The additional   |
--|	catch up (deprn expense) is calculated in this function and the detail balances |
--|	are updated accordingly								|
-- ========================================================================================+

  FUNCTION  Do_prior_transfer(p_book_type_code         fa_books.book_type_code%type,
                              p_asset_id               fa_additions_b.asset_id%type,
                              p_category_id            fa_categories.category_id%type,
                              p_transaction_header_id  fa_transaction_headers.transaction_header_id%type,
                              p_cost                   fa_books.cost%type,
                              p_adjusted_cost          fa_books.adjusted_cost%type,
                              p_salvage_value          fa_books.salvage_value%type,
                              p_current_units          fa_additions_b.current_units%type,
                              p_life_in_months         fa_books.life_in_months%type,
                              p_calling_function       varchar2,
                              p_event_id               number    --R12 uptake
                             )
 RETURN BOOLEAN
 IS
   -- Cursor to select transaction data for transaction header_rec type */

    	CURSOR	c_trans_data IS
    		SELECT	transaction_date_entered,
    			mass_reference_id,
    			transaction_type_code
    		FROM	fa_transaction_headers
    		WHERE	transaction_header_id=p_transaction_header_id;

    	/* Cursor to select asset data for asset header rec */

    	CURSOR	c_asset_data IS
    		SELECT 	set_of_books_id
    		FROM	fa_book_controls
    		WHERE	book_type_code=p_book_type_code;

 	l_trans_rec			FA_API_TYPES.trans_rec_type;
	l_asset_hdr_rec			FA_API_TYPES.asset_hdr_rec_type;
	l_asset_cat_rec			FA_API_TYPES.asset_cat_rec_type;

	l_trans_data			c_trans_data%rowtype;
	l_asset_data			c_asset_data%rowtype;

	l_mesg				VARCHAR2(500);

	l_path varchar2(150);
	BEGIN

	l_path := g_path||'Do_prior_transfer';

	/* Retreive data for transaction header record (not available as input parameter)*/
	Open c_trans_data;
	Fetch c_trans_data into l_trans_data;
	close c_trans_data;

	/* Retreive data for asset header record(not available as input parameter) */
	Open c_asset_data;
	Fetch c_asset_data into l_asset_data;
	close c_asset_data;

	l_trans_rec.transaction_header_id:=p_transaction_header_id;
	l_trans_rec.transaction_date_entered:=l_trans_data.transaction_date_entered;
	l_trans_rec.transaction_type_code:=l_trans_data.transaction_type_code;
	l_trans_rec.mass_reference_id:=l_trans_data.mass_reference_id;

	l_asset_hdr_rec.book_type_code:=p_book_type_code;
	l_asset_hdr_rec.asset_id:=p_asset_id;
	l_asset_hdr_rec.set_of_books_id:=l_asset_data.set_of_books_id;

	l_asset_cat_rec.category_id:=p_category_id;

        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'============================================================');
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Start Of Prior Period Processing');
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'============================================================');
	/* Call the Do_Transfer process to insert data for current open period */
	IF NOT(Do_transfer(l_trans_rec,
        	  	       l_asset_hdr_rec,
	  	               l_asset_cat_rec,
	                   'IGI_IAC_TRANSFERS_PKG.Do_prior_transfer',
                       p_event_id))THEN

	     	app_exception.raise_exception;
	 END IF;

	RETURN(TRUE);

	EXCEPTION
	WHEN OTHERS THEN

		l_mesg:=SQLERRM;
		FA_SRVR_MSG.Add_Message(
	                Calling_FN 	=> 'IGI_IAC_TRANSFER_PKG.Do_Transfer',
        	        Name 		=> 'IGI_IAC_EXCEPTION',
        	        TOKEN1		=> 'PACKAGE',
        	        VALUE1		=> 'Transfers',
        	        TOKEN2		=> 'ERROR_MESSAGE',
        	        VALUE2		=> l_mesg);

        igi_iac_debug_pkg.debug_unexpected_msg(l_path);
	RETURN(FALSE);

	END Do_prior_transfer;

/*
+=======================================================================================+
|	Function Do_Rollback_Deprn is called from the FA Rollback deprn.This would 	|
|	rollback the data inserted by prior transfers in the latest depreciation run if |
|	any in that depreciation run .							|
========================================================================================+
*/
	FUNCTION Do_Rollback_Deprn(
   				   p_book_type_code                 VARCHAR2,
   				   p_period_counter                 NUMBER,
   				   p_calling_function               VARCHAR2
				  ) return BOOLEAN  IS
	/* Cursor to select data from transaction headers which need to be rolled back */

	CURSOR  c_trans_headers IS
    		SELECT  *
    		FROM  	igi_iac_transaction_headers
    		WHERE	book_type_code=p_book_type_code
    		AND	period_counter=p_period_counter
    		AND	transaction_type_code='TRANSFER';


	CURSOR 	c_deprn_expense(cp_asset_id igi_iac_det_balances.asset_id%TYPE,
				cp_adjustment_id  IGI_IAC_DET_BALANCES.adjustment_id%type) IS
	        SELECT 	sum(deprn_period)
	        FROM 	igi_iac_det_balances
	        WHERE 	book_type_code = p_book_type_code
	        AND   	asset_id = cp_asset_id
	        AND	adjustment_id = cp_adjustment_id;

	/* Cursor to select the previous data */

	CURSOR 	c_prev_data(c_adjustment_id igi_iac_transaction_headers.adjustment_id%type) IS
		SELECT 	*
		FROM 	igi_iac_transaction_headers
		WHERE	adjustment_id_out=c_adjustment_id;

	/* Cursor  to find the amounts that need to be transferred to the new  dist
	 created by transfer */

	CURSOR 	c_amounts(c_period_counter in IGI_IAC_ASSET_BALANCES.period_counter%type,
			  cp_asset_id	IGI_IAC_ASSET_BALANCES.asset_id%TYPE) IS
		SELECT	*
		FROM	igi_iac_asset_balances
		WHERE 	asset_id = cp_asset_id
                AND     book_type_code = p_book_type_code
		AND	period_counter = p_period_counter;

	/* Cursor to select impacted distributions for roll back */

	CURSOR c_dist(c_adjustment_id igi_iac_adjustments.adjustment_id%type) IS
	 	SELECT 	distribution_id
	 	FROM 	igi_iac_det_balances
	 	WHERE	adjustment_id=c_adjustment_id;

	CURSOR c_fa_dist(cp_adjustment_id igi_iac_adjustments.adjustment_id%type,
			 cp_asset_id	igi_iac_fa_deprn.asset_id%TYPE) IS
	 	SELECT 	book_type_code,asset_id,period_counter,distribution_id,adjustment_id
	 	FROM 	igi_iac_fa_deprn
	 	WHERE	asset_id = cp_asset_id
	 	AND	book_type_code = p_book_type_code
	 	AND	adjustment_id = cp_adjustment_id;



	l_trans_headers				c_trans_headers%rowtype;
	l_amounts				c_amounts%rowtype;
	l_prd_rec_prior				igi_iac_types.prd_rec;

	l_deprn_expense 			FA_DEPRN_SUMMARY.deprn_amount%type;
	l_Expense_diff				IGI_IAC_DET_BALANCES.deprn_period%type;
	l_prior_period_counter			IGI_IAC_DET_BALANCES.period_counter%type;
	l_current_period_counter		IGI_IAC_DET_BALANCES.period_counter%type;
	l_prev_adjustment			igi_iac_transaction_headers%ROWTYPE;

	l_path varchar2(150);
    	BEGIN

	        l_path := g_path||'Do_Rollback_Deprn';

		igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'*****************************************************************');
	        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'	Rollback of Transactions 	');
	        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'*****************************************************************');

	        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Processing For book		'||p_book_type_code);
	        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Current Period Counter		:'||p_period_counter);


    		FOR l_trans_headers in c_trans_headers
    		LOOP
		        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Transaction header Id		:'||l_trans_headers.transaction_header_id);
		        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Transaction Date Entered	:'||l_trans_headers.transaction_date_entered);
		        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Adjustment Id			:'||l_trans_headers.adjustment_id);
		        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Asset Id			:'||l_trans_headers.asset_id);


			/*Check If it is Prior Period Transfer*/
			IF (IGI_IAC_COMMON_UTILS.get_period_info_for_date(p_book_type_code,
							   l_trans_headers.transaction_date_entered,
							   l_prd_rec_prior)) THEN
				l_prior_period_counter:=l_prd_rec_prior.period_counter;
			END IF;


		        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Period counter			:'||l_prior_period_counter);

    			IF l_prior_period_counter is not null AND (L_prior_period_counter< p_period_counter) THEN

			        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Processing prior period data on this asset');

			        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'============================================================');
			        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Deleting From detail balances...');
			        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'============================================================');

    				/*DELETE  from igi_iac_det_balances
    				WHERE	book_type_code=p_book_type_code
    				AND 	period_counter=p_period_counter
    				AND	adjustment_id=l_trans_headers.adjustment_id;*/


    				FOR l_dist in c_dist(l_trans_headers.adjustment_id)
    				loop
    				IGI_IAC_DET_BALANCES_PKG.delete_row(
    					x_adjustment_id			=>l_trans_headers.adjustment_id,
    					x_asset_id			=>l_trans_headers.asset_id,
    					x_distribution_id		=>l_dist.distribution_id,
    					x_book_type_code		=>l_trans_headers.book_type_code,
    					x_period_counter		=>p_period_counter
    					);
    				End loop;

    				FOR l_fa_dist IN c_fa_dist(l_trans_headers.adjustment_id,l_trans_headers.asset_id) LOOP
    					IGI_IAC_FA_DEPRN_PKG.delete_row(
    					x_adjustment_id			=>l_fa_dist.adjustment_id,
    					x_asset_id			=>l_fa_dist.asset_id,
    					x_distribution_id		=>l_fa_dist.distribution_id,
    					x_book_type_code		=>l_fa_dist.book_type_code,
    					x_period_counter		=>l_fa_dist.period_counter
    					);
    				END LOOP;

			        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'============================================================');
			        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Deleting From adjustments...');
			        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'============================================================');

    				/* DELETE  from igi_iac_adjustments
    				WHERE	book_type_code=p_book_type_code
    				AND 	period_counter=p_period_counter
    				AND	adjustment_id=l_trans_headers.adjustment_id; */

    				IGI_IAC_ADJUSTMENTS_PKG.delete_row(
    					x_adjustment_id			   =>l_trans_headers.adjustment_id
    					);

				OPEN c_prev_data(l_trans_headers.adjustment_id);
				FETCH c_prev_data INTO l_prev_adjustment;
				CLOSE c_prev_data;

    				open c_deprn_expense(l_trans_headers.asset_id,l_prev_adjustment.adjustment_id);
				fetch c_deprn_expense into l_deprn_expense;
				close c_deprn_expense;

			        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Expense Amount to be adjusted  :'||l_deprn_expense);

    	     			open c_amounts(p_period_counter,l_trans_headers.asset_id);
	     			fetch c_amounts into l_amounts;
	     			close c_amounts;

			        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'============================================================');
			        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Updating Asset balances ...');
			        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'============================================================');

	     			IGI_IAC_ASSET_BALANCES_PKG.update_row (
  		    			x_asset_id                          =>l_trans_headers.asset_id,
    					x_book_type_code                    =>p_book_type_code,
    					x_period_counter                    =>p_period_counter,
    					x_net_book_value                    =>l_amounts.net_book_value,
    					x_adjusted_cost                     =>l_amounts.adjusted_cost,
    					x_operating_acct                    =>l_amounts.operating_acct,
    					x_reval_reserve                     =>l_amounts.reval_reserve,
    					x_deprn_amount                      =>l_deprn_expense,
    					x_deprn_reserve                     =>l_amounts.deprn_reserve,
    					x_backlog_deprn_reserve             =>l_amounts.backlog_deprn_reserve,
    					x_general_fund                      =>l_amounts.general_fund,
    					x_last_reval_date                   =>l_amounts.last_reval_date,
    					x_current_reval_factor              =>l_amounts.current_reval_factor,
    					x_cumulative_reval_factor           =>l_amounts.cumulative_reval_factor,
    					x_mode                              =>'R'
 				 					);


			        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'============================================================');
			        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Updating transaction headers...');
			        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'============================================================');

 				FOR l_prev_data in c_prev_data(l_trans_headers.adjustment_id)
 				LOOP
 					IGI_IAC_TRANS_HEADERS_PKG.update_row (
  						x_prev_adjustment_id                =>l_prev_data.adjustment_id,
    						x_adjustment_id                     =>null,
    						x_mode                              =>'R'
  								);
				END LOOP;


			        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'============================================================');
			        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Deleting From transaction headers...');
			        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'============================================================');

	      			IGI_IAC_TRANS_HEADERS_PKG.delete_row (
					    x_adjustment_id  =>l_trans_headers.adjustment_id
							  );

		   	END IF;


    		END LOOP; -- End of First for

	        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'*****************************************************************');
	        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'	Rollback completed successfully 	');
	        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'*****************************************************************');

		RETURN(TRUE);
	END Do_rollback_deprn;

BEGIN

 --===========================FND_LOG.START=====================================

 g_state_level 	     :=	FND_LOG.LEVEL_STATEMENT;
 g_proc_level  	     :=	FND_LOG.LEVEL_PROCEDURE;
 g_event_level 	     :=	FND_LOG.LEVEL_EVENT;
 g_excep_level 	     :=	FND_LOG.LEVEL_EXCEPTION;
 g_error_level 	     :=	FND_LOG.LEVEL_ERROR;
 g_unexp_level 	     :=	FND_LOG.LEVEL_UNEXPECTED;
 g_path              := 'IGI.PLSQL.igiiatfb.IGI_IAC_TRANSFERS_PKG.';

 --===========================FND_LOG.END=====================================



END IGI_IAC_TRANSFERS_PKG;

/
