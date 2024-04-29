--------------------------------------------------------
--  DDL for Package Body IGI_IAC_RETIREMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_RETIREMENT" AS
--  $Header: igiiartb.pls 120.30.12010000.5 2010/06/28 07:23:13 schakkin ship $

--global variables
    g_calling_fn                VARCHAR2(200);
    g_state_level               NUMBER;
    g_proc_level                NUMBER;
    g_event_level               NUMBER;
    g_excep_level               NUMBER;
    g_error_level               NUMBER;
    g_unexp_level               NUMBER;
    g_path                      VARCHAR2(100);
    g_latest_adjustment_id      igi_iac_transaction_headers.adjustment_id%TYPE ;
    g_latest_trx_type           igi_iac_transaction_headers.transaction_type_code%TYPE DEFAULT NULL;
    g_mass_reference_id         igi_iac_transaction_headers.mass_reference_id%TYPE ;
    g_latest_trx_id             igi_iac_transaction_headers.transaction_header_id%TYPE ;
    g_latest_adj_status         igi_iac_transaction_headers.adjustment_status%TYPE ;
    g_prd_rec                   igi_iac_types.prd_rec ;
    g_retire_prd_rec            igi_iac_types.prd_rec ;
    g_retire_rec                fa_api_types.asset_retire_rec_type ;
    g_retirement_type           VARCHAR2(4) ;
    g_retirement_period_type    VARCHAR2(10) ;
    g_ret_type_long             VARCHAR2(20) ;
    g_retirement_factor         NUMBER ;
    g_err_msg                   VARCHAR2(250) ;
    g_retirement_adjustment_id  igi_iac_transaction_headers.adjustment_id%TYPE ;
    g_asset_category_id         fa_additions_b.asset_category_id%TYPE ;
    g_rowid                     ROWID  ;
    g_sob_id                    NUMBER ;
    g_coa_id                    NUMBER ;
    g_currency                  VARCHAR2(10);
    g_precision                 NUMBER ;
    g_is_first_period           BOOLEAN;
    g_period_rec                igi_iac_types.prd_rec ;
    g_prior_prd_count           NUMBER ;
    g_retirement_prior_period   NUMBER;
    g_total_asset_units         Number;

    CURSOR c_fa_trx (p_trx_id NUMBER) IS
    SELECT transaction_date_entered,
            mass_reference_id
    FROM   fa_transaction_headers
    WHERE  transaction_header_id = p_trx_id ;

     g_fa_trx c_fa_trx%ROWTYPE;

     CURSOR c_fa_adds (p_c_asset_id NUMBER) IS
     SELECT asset_category_id
     FROM   fa_additions_b
     WHERE  asset_id = p_c_asset_id  ;


     CURSOR c_detail_balances (p_current_adjustment NUMBER) IS
     SELECT *
     FROM  igi_iac_det_balances
     WHERE adjustment_id = p_current_adjustment ;

     CURSOR c_units_per_dist (p_c_asset_id NUMBER, p_c_book_type_code VARCHAR2, p_dist_id NUMBER) IS
     SELECT units_assigned, transaction_units
     FROM   fa_distribution_history
     WHERE  asset_id = p_c_asset_id
     AND    book_type_code = p_c_book_type_code
     AND    distribution_id = p_dist_id ;

     g_units_per_dist   c_units_per_dist%ROWTYPE ;

     CURSOR c_asset_balances (p_c_asset_id NUMBER, p_c_book_type_code VARCHAR2, p_period_counter NUMBER) IS
     SELECT *
     FROM   igi_iac_asset_balances
     WHERE  asset_id = p_c_asset_id
     AND    book_type_code = p_c_book_type_code
     AND    period_counter = p_period_counter ;

     g_asset_balances_rec   igi_iac_asset_balances%ROWTYPE ;
     CURSOR c_new_distribution (p_c_retirement_id NUMBER, p_old_distribution NUMBER ) IS
     SELECT new.distribution_id
     FROM   fa_distribution_history NEW, fa_distribution_history old
     WHERE  old.retirement_id = p_c_retirement_id
     AND    old.location_id = new.location_id
     AND    old.code_combination_id = new.code_combination_id
     AND    NVL(old.assigned_to,-99) = NVL(new.assigned_to,-99)
     AND    old.transaction_header_id_out = new.transaction_header_id_in
     AND    old.distribution_id = p_old_distribution ;

     CURSOR c_total_units (p_c_asset_id NUMBER) IS
     SELECT units
     FROM   fa_asset_history
     WHERE  asset_id = p_c_asset_id
     AND    transaction_header_id_out IS NULL ;

     CURSOR c_previous_per (p_adjustment_id NUMBER) IS
     SELECT period_counter
     FROM   igi_iac_transaction_headers
     WHERE  adjustment_id = p_adjustment_id ;


      CURSOR c_fa_deprn(n_adjust_id NUMBER, n_dist_id   NUMBER,n_prd_cnt   NUMBER)
      IS
      SELECT *
      FROM  igi_iac_fa_deprn ifd
      WHERE ifd.adjustment_id = n_adjust_id
      AND   ifd.distribution_id = n_dist_id
      AND   ifd.period_counter = n_prd_cnt;


     CURSOR c_get_impacted_dist(p_asset_id Number,
                                p_retirement_id Number,
                                p_distribution_id Number  )
     IS
     SELECT *
     FROM fa_distribution_history fad
     WHERE  fad.asset_id        = p_asset_id
     AND    fad.retirement_id   = p_retirement_id
     AND    fad.distribution_id = p_distribution_id;

    CURSOR c_get_new_dist(p_asset_id            Number,
                          p_retirement_id       Number,
                          p_code_combination_id Number,
                          p_transaction_units   Number,
                          p_location_id         Number,
                          P_assigned_to           Number)
     IS
     SELECT *
     FROM fa_distribution_history fad
     WHERE  fad.asset_id            = p_asset_id
     AND    fad.code_combination_id = p_code_combination_id
     AND    fad.units_assigned      = p_transaction_units
     AND    fad.location_id         = p_location_id
     AND    NVL(fad.assigned_to,-1) = p_assigned_to
     AND    fad.transaction_header_id_out IS NULL;


     CURSOR c_check_revaluations (p_asset_id       fa_books.asset_id%TYPE,
                                  p_book_type_code fa_books.book_type_code%TYPE,
                                   p_retire_period  Number,
                                  p_current_period NUmber) IS
      SELECT *
      FROM igi_iac_transaction_headers
      WHERE book_type_code = p_book_type_code
      AND asset_id = p_asset_id
      AND period_counter >= p_retire_period
      AND period_counter <= p_current_period
      AND transaction_type_code='REVALUATION'
      AND adjustment_status='RUN';


       CURSOR c_get_all_occ_reval(p_asset_id       fa_books.asset_id%TYPE,
                                       p_book_type_code fa_books.book_type_code%TYPE,
                                       p_retire_period      Number,
                                       p_current_period     NUmber,
                                       p_distribution_id    Number ) IS
       SELECT asset_id,distribution_id,adjustment_type,SUM(DECODE(dr_cr_flag,'CR',1,-1)*Amount) amount,
                     adjustment_offset_type,report_ccid,code_combination_id,units_assigned
       FROM       igi_iac_adjustments
       WHERE book_type_code = p_book_type_code
       AND asset_id         = p_asset_id
       AND distribution_id  = p_distribution_id
       AND adjustment_id IN (SELECT adjustment_id
                                  FROM igi_iac_transaction_headers
                   		          WHERE book_type_code = p_book_type_code
                                  AND asset_id         = p_asset_id
                                  AND period_counter  >= p_retire_period
                                  AND period_counter  <= p_current_period
                                  AND transaction_type_code ='REVALUATION'
                                  AND adjustment_status     ='RUN')
       GROUP BY asset_id,distribution_id,adjustment_type,adjustment_offset_type,report_ccid,code_combination_id,units_assigned;

       CURSOR c_check_depreciations (p_asset_id       fa_books.asset_id%TYPE,
                             p_book_type_code fa_books.book_type_code%TYPE,
                              p_retire_period  Number,
                              p_current_period NUmber)  IS
       SELECT *
       FROM igi_iac_transaction_headers
       WHERE book_type_code = p_book_type_code
       AND asset_id = p_asset_id
       AND period_counter >= p_retire_period
       AND period_counter <= p_current_period
       AND transaction_type_code='DEPRECIATION'
       AND adjustment_status='COMPLETE';


      CURSOR c_get_all_prd_reval(p_asset_id       fa_books.asset_id%TYPE,
                                       p_book_type_code fa_books.book_type_code%TYPE,
                                       p_retire_period      Number,
                                       p_current_period     NUmber,
                                       p_distribution_id    Number ) IS
      SELECT asset_id,distribution_id,adjustment_type,SUM(DECODE(dr_cr_flag,'CR',1,-1)*Amount) amount,
                       adjustment_offset_type,report_ccid,code_combination_id,units_assigned
      FROM       igi_iac_adjustments
      WHERE book_type_code = p_book_type_code
      AND asset_id         = p_asset_id
      AND distribution_id  = p_distribution_id
      AND adjustment_id IN (SELECT adjustment_id
                                  FROM igi_iac_transaction_headers
                   		          WHERE book_type_code = p_book_type_code
                                  AND asset_id         = p_asset_id
                                  AND period_counter  >= p_retire_period
                                  AND period_counter  <= p_current_period
                                  AND transaction_type_code ='DEPRECIATION'
                                  AND adjustment_status     ='COMPLETE')
       GROUP BY asset_id,distribution_id,adjustment_type,adjustment_offset_type,report_ccid,code_combination_id,units_assigned;


      CURSOR C_get_prior_dist ( p_asset_id       fa_books.asset_id%TYPE,
                                  p_book_type_code fa_books.book_type_code%TYPE,
                                  p_distribution_id    Number,
                                  P_period_counter      Number) IS
      SELECT *
      FROM igi_iac_det_balances
      WHERE book_type_code = p_book_type_code
      AND  asset_id        = p_asset_id
      AND  distribution_id = p_distribution_id
      AND  adjustment_id = (SELECT MAX(adjustment_id)
                               FROM igi_iac_transaction_headers
                               WHERE asset_id = p_asset_id
                               AND book_type_code = p_book_type_code
                               AND period_counter = ( 	SELECT max(period_counter)
	                				FROM igi_iac_det_balances
				        	        WHERE book_type_code = p_book_type_code
				                        AND  asset_id        = p_asset_id
				                        AND  distribution_id = p_distribution_id
							AND  period_counter < p_period_counter  )
                               AND adjustment_status NOT IN ('PREVIEW','OBSOLETE'));



  	-- get the asset number
    Cursor C_get_asset_number(cp_asset_id Number) iS
    Select asset_number
    From fa_additions
    Where asset_id = cp_asset_id;

        e_is_asset_proc             EXCEPTION;
        e_no_latest_trans           EXCEPTION;
        e_reval_preview             EXCEPTION;
        e_no_open_prd_info          EXCEPTION;
        e_no_retire_rec             EXCEPTION;
        e_no_retire_type            EXCEPTION;
        e_no_book_gl                EXCEPTION;
        e_no_cost_retire            EXCEPTION;
        e_no_account_ccid           EXCEPTION;
        e_no_units_info             EXCEPTION;
        e_asset_balance_verify      EXCEPTION;
        e_no_new_distribution       EXCEPTION;
        e_no_asset_bals             EXCEPTION;
        e_no_retire_period          EXCEPTION;
        e_iac_fa_deprn              EXCEPTION;
      	g_path_name                 VARCHAR2(150);



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

PROCEDURE debug (p_level        IN NUMBER,
			     p_full_path    IN VARCHAR2,
			     p_string       IN VARCHAR2) IS
BEGIN
                igi_iac_debug_pkg.debug_other_string( p_level      =>p_level,
	     		                                      p_Full_path  =>P_full_path,
                                                      p_string     =>p_string);

END;

FUNCTION Cost_Retirement (    P_Asset_Id                IN NUMBER ,
                              P_Book_Type_Code          IN VARCHAR2 ,
                              P_Retirement_Id           IN NUMBER ,
                              P_retirement_type         IN VARCHAR2,
                              p_retirement_factor       IN NUMBER ,
                              p_retirement_period_type  IN VARCHAR2,
                              P_prior_period            IN NUMBER,
                              P_Current_period          IN NUMBER,
                              P_Event_Id                IN NUMBER) --R12 uptake
RETURN BOOLEAN IS

    l_rowid                           ROWID;
    l_asset_balances                  igi_iac_asset_balances%ROWTYPE;
    l_asset_balances_rec              igi_iac_asset_balances%ROWTYPE;
    l_detail_balances                 igi_iac_det_balances%ROWTYPE;
    l_detail_balances_new             igi_iac_det_balances%ROWTYPE;
    l_detail_balances_total_old       igi_iac_det_balances%ROWTYPE;
    l_detail_balances_retire          igi_iac_det_balances%ROWTYPE;
    l_detail_balances_retire_unrnd    igi_iac_det_balances%ROWTYPE;
    l_detail_balances_rnd_tot         igi_iac_det_balances%ROWTYPE;
    l_fa_deprn                        igi_iac_fa_deprn%ROWTYPE;
    l_units_per_dist                  c_units_per_dist%ROWTYPE;
    l_cost_account_ccid               NUMBER ;
    l_acc_deprn_account_ccid          NUMBER ;
    l_reval_rsv_account_ccid          NUMBER ;
    l_backlog_account_ccid            NUMBER ;
    l_nbv_retired_account_ccid        NUMBER ;
    l_reval_rsv_ret_acct_ccid         NUMBER ;
    l_deprn_exp_account_ccid          NUMBER ;
    l_account_gen_fund_ccid           NUMBER;
    l_new_units                       NUMBER ;
    l_new_distribution                NUMBER ;
    l_units_before                    NUMBER ;
    l_units_after                     NUMBER ;
    l_ret                             BOOLEAN ;
    l_total_asset_units               NUMBER ;
    l_asset_units_count               NUMBER ;
    l_previous_per                    NUMBER ;
    l_prev_adjustment_id              igi_iac_transaction_headers.adjustment_id%TYPE ;
    l_last_active_adj_id              igi_iac_transaction_headers.adjustment_id%TYPE ;
    l_db_op_acct_ytd                  igi_iac_det_balances.operating_acct_ytd%TYPE;
    l_db_deprn_ytd                    igi_iac_det_balances.deprn_ytd%TYPE;
    l_fa_deprn_prd                    igi_iac_fa_deprn.deprn_period%TYPE;
    l_fa_tot_round_deprn_prd          igi_iac_fa_deprn.deprn_period%TYPE;
    l_fa_unround_deprn_prd            igi_iac_fa_deprn.deprn_period%TYPE;
    l_fa_total_old_acc_deprn          igi_iac_fa_deprn.deprn_reserve%TYPE;
    l_fa_retire_acc_deprn             igi_iac_fa_deprn.deprn_reserve%TYPE;
    l_fa_tot_round_acc_deprn          igi_iac_fa_deprn.deprn_reserve%TYPE;
    l_fa_unround_acc_deprn            igi_iac_fa_deprn.deprn_reserve%TYPE;
    l_fa_total_new_acc_deprn          igi_iac_fa_deprn.deprn_reserve%TYPE;
    l_fa_deprn_ytd                    igi_iac_fa_deprn.deprn_ytd%TYPE;
    l_fa_tot_round_deprn_ytd          igi_iac_fa_deprn.deprn_ytd%TYPE;
    l_fa_unround_deprn_ytd            igi_iac_fa_deprn.deprn_ytd%TYPE;
    l_fa_total_new_deprn_prd          igi_iac_fa_deprn.deprn_ytd%TYPE;
    l_fa_total_new_deprn_ytd          igi_iac_fa_deprn.deprn_ytd%TYPE;
    l_fa_total_old_deprn_prd          igi_iac_fa_deprn.deprn_ytd%TYPE;
    l_fa_total_old_deprn_ytd          igi_iac_fa_deprn.deprn_ytd%TYPE;
    l_fa_retire_deprn_prd             igi_iac_fa_deprn.deprn_ytd%TYPE;
    l_fa_retire_deprn_ytd             igi_iac_fa_deprn.deprn_ytd%TYPE;
    l_op_exp_ccid                     NUMBER;
    l_Transaction_Type_Code	          igi_iac_transaction_headers.transaction_type_code%TYPE;
    l_Transaction_Id                  igi_iac_transaction_headers.transaction_header_id%TYPE;
    l_Mass_Reference_ID	              igi_iac_transaction_headers.mass_reference_id%TYPE;
    l_Adjustment_Status               igi_iac_transaction_headers.adjustment_status%TYPE;
    l_adjustment_id_out               igi_iac_adjustments.adjustment_id%TYPE;
    l_retirement_adjustment_id        NUmber;
    l_path_name                       varchar2(200);
    l_detail_balances_prior           C_get_prior_dist%ROWTYPE;
    l_max_period_counter              NUMBER;

BEGIN

l_path_name:=g_path_name ||'.Cost_Retiremet';

         /*  Initialize Asset total balance variables  */
         ------------------------
        l_asset_balances.Asset_id       :=P_Asset_Id ;
        l_asset_balances.book_type_code :=P_Book_Type_Code;
        l_asset_balances.period_counter :=P_Current_period;
        l_asset_balances.net_book_value :=0;
        l_asset_balances.adjusted_cost  :=0;
        l_asset_balances.operating_acct :=0;
        l_asset_balances.reval_reserve  :=0;
        l_asset_balances.deprn_amount   :=0;
        l_asset_balances.deprn_reserve  :=0;
        l_asset_balances.backlog_deprn_reserve:=0;
        l_asset_balances.general_fund   :=0;


        l_Transaction_Type_Code     := NULL;
        l_Transaction_Id            := NULL;
        l_Mass_Reference_ID         := NULL;
        l_adjustment_id_out         := NULL;
        l_prev_adjustment_id        := NULL;
        l_Adjustment_Status         := NULL;
        l_retirement_adjustment_id  :=NULL;

       debug(g_state_level,l_path_name,'Asset ID '||P_Asset_Id);
       -- get the latest tranaction for the asset id

       IF NOT (igi_iac_common_utils.get_latest_transaction(P_Book_Type_Code,
                                                           P_Asset_Id,
                                                           l_Transaction_Type_Code,
                                                           l_Transaction_Id,
                                                           l_Mass_Reference_ID ,
                                                           l_adjustment_id_out,
                                                           l_prev_adjustment_id,
                                                           l_Adjustment_Status )
                ) THEN
               igi_iac_debug_pkg.debug_other_string(g_error_level,l_path_name,'*** Error in fetching the latest transaction');
               RETURN FALSE;
       END IF;

       debug(g_state_level,l_path_name,'got latest transaction');
       l_last_active_adj_id := l_prev_adjustment_id ;
       debug( g_state_level,l_path_name,'not reval in preview');

       l_rowid:=NULL;
       igi_iac_trans_headers_pkg.insert_row(
	                       	    X_rowid		            => l_rowid ,
                        		X_adjustment_id	        => l_retirement_adjustment_id ,
                        		X_transaction_header_id => g_retire_rec.detail_info.transaction_header_id_in,
                        		X_adjustment_id_out	    => NULL ,
                        		X_transaction_type_code => g_ret_type_long,
                        		X_transaction_date_entered => g_fa_trx.transaction_date_entered,
                        		X_mass_refrence_id	    => g_fa_trx.mass_reference_id ,
                        		X_transaction_sub_type	=> SUBSTR(g_retirement_type,1,1),
                        		X_book_type_code	    => P_Book_Type_Code,
                        		X_asset_id		        => p_asset_id ,
                        		X_category_id		    => g_asset_category_id,
                        		X_adj_deprn_start_date	=> NULL,
                        		X_revaluation_type_flag => NULL,
                        		X_adjustment_status	    => 'COMPLETE' ,
                        		X_period_counter	    => P_Current_period,
                                X_mode                  =>'R',
                                X_event_id              => P_Event_Id) ;
          debug( g_state_level, l_path_name,'inserted trans_headers record');

          igi_iac_trans_headers_pkg.update_row(l_adjustment_id_out,
                                               l_retirement_adjustment_id,
                                              'R') ;

          debug( g_state_level,l_path_name,'updated old trans_headers record');
          debug( g_state_level,l_path_name,'Start loop');


         FOR l_detail_balances IN c_detail_balances(l_last_active_adj_id) LOOP

            -- since the equivalent row in igi_iac_fa_deprn has to handled in
           -- the same manner, retrieving the row for simultaneous processing
           OPEN c_fa_deprn( l_detail_balances.adjustment_id,
                            l_detail_balances.distribution_id,
                            l_detail_balances.period_counter);
           FETCH c_fa_deprn INTO l_fa_deprn;
           IF c_fa_deprn%NOTFOUND THEN
               CLOSE c_fa_deprn;
               RETURN FALSE;
           END IF;
          CLOSE c_fa_deprn;

          IF l_detail_balances.active_flag IS NULL THEN -- Active distributions

         	   debug( g_state_level,l_path_name,'inside loop');


             l_detail_balances_rnd_tot.adjustment_cost        :=0 ;
             l_detail_balances_rnd_tot.reval_reserve_cost     :=0 ;
             l_detail_balances_rnd_tot.deprn_reserve          :=0 ;
             l_detail_balances_rnd_tot.deprn_reserve_backlog  :=0 ;
             l_detail_balances_rnd_tot.reval_reserve_net      :=0 ;
             l_detail_balances_rnd_tot.deprn_period           :=0 ;
             l_detail_balances_rnd_tot.general_fund_acc       :=0 ;
             l_detail_balances_rnd_tot.general_fund_per       :=0 ;
             l_detail_balances_rnd_tot.reval_reserve_gen_fund :=0 ;
             l_detail_balances_rnd_tot.operating_acct_backlog :=0;
             l_detail_balances_rnd_tot.operating_acct_cost    :=0;
             l_detail_balances_rnd_tot.operating_acct_net     :=0;
             l_detail_balances_rnd_tot.reval_reserve_backlog  :=0;
             l_detail_balances_rnd_tot.deprn_ytd              :=0;


           IF (l_detail_balances.active_flag IS NULL) THEN

     	     debug( g_state_level,l_path_name,'Detail balances loop: active record dist id  '|| l_detail_balances.distribution_id);

             OPEN  c_units_per_dist(P_Asset_Id, P_Book_Type_Code, l_detail_balances.distribution_id) ;
     	     debug( g_state_level, l_path_name,'opened c_units_per_dist');
             FETCH c_units_per_dist INTO l_units_per_dist ;
             IF    c_units_per_dist%NOTFOUND THEN
                CLOSE c_units_per_dist;
		debug( g_state_level,l_path_name,'units per dist not found');
                   RAISE NO_DATA_FOUND;
             END IF ;
             CLOSE c_units_per_dist ;

     	     debug( g_state_level,l_path_name,'got units per dist');
             l_detail_balances_total_old  := l_detail_balances;

             l_fa_total_old_acc_deprn  := l_fa_deprn.deprn_reserve;

             /* Calculate retirement amounts   */
             debug( g_state_level,l_path_name,'adjustment_cost       ' || l_detail_balances.adjustment_cost);
             debug( g_state_level,l_path_name,'reval_reserve_cost    ' || l_detail_balances.reval_reserve_cost);
             debug( g_state_level,l_path_name,'deprn_reserve         ' ||l_detail_balances.deprn_reserve);
             debug( g_state_level,l_path_name,'deprn_reserve_backlog ' ||l_detail_balances.deprn_reserve_backlog);
             debug( g_state_level,l_path_name,'reval_reserve_nett    ' ||l_detail_balances.reval_reserve_net);
             debug( g_state_level,l_path_name,'operating_acct_backlog' ||l_detail_balances.operating_acct_backlog);
             debug( g_state_level,l_path_name,'operating_acct_net    ' ||l_detail_balances.operating_acct_net);
             debug( g_state_level,l_path_name,'reval_reserve_backlog ' ||l_detail_balances.reval_reserve_backlog);

            IF p_prior_period IS NULL THEN

             l_detail_balances_retire.adjustment_cost        := l_detail_balances.adjustment_cost* p_retirement_factor ;
	     do_round(l_detail_balances_retire.adjustment_cost,P_Book_Type_Code);
             l_detail_balances_retire.reval_reserve_cost     := l_detail_balances.reval_reserve_cost* p_retirement_factor ;
	     do_round(l_detail_balances_retire.reval_reserve_cost,P_Book_Type_Code);
             l_detail_balances_retire.deprn_reserve          := l_detail_balances.deprn_reserve * p_retirement_factor ;
	     do_round(l_detail_balances_retire.deprn_reserve,P_Book_Type_Code);
             l_detail_balances_retire.deprn_reserve_backlog  := l_detail_balances.deprn_reserve_backlog * p_retirement_factor ;
	     do_round(l_detail_balances_retire.deprn_reserve_backlog,P_Book_Type_Code);
             l_detail_balances_retire.reval_reserve_net      := l_detail_balances.reval_reserve_net  * p_retirement_factor ;
	     do_round(l_detail_balances_retire.reval_reserve_net,P_Book_Type_Code);
             l_detail_balances_retire.deprn_period           := l_detail_balances.deprn_period * (1 - p_retirement_factor) ;
	     do_round(l_detail_balances_retire.deprn_period,P_Book_Type_Code);
             l_detail_balances_retire.general_fund_acc       := l_detail_balances.general_fund_acc * p_retirement_factor;
	     do_round(l_detail_balances_retire.general_fund_acc,P_Book_Type_Code);
             l_detail_balances_retire.general_fund_per       := l_detail_balances.general_fund_per * p_retirement_factor;
	     do_round(l_detail_balances_retire.general_fund_per,P_Book_Type_Code);
             l_detail_balances_retire.reval_reserve_gen_fund := l_detail_balances.reval_reserve_gen_fund  * p_retirement_factor;
	     do_round(l_detail_balances_retire.reval_reserve_gen_fund,P_Book_Type_Code);
             l_detail_balances_retire.operating_acct_backlog :=l_detail_balances.operating_acct_backlog * p_retirement_factor;
	     do_round(l_detail_balances_retire.operating_acct_backlog,P_Book_Type_Code);
             l_detail_balances_retire.operating_acct_cost    :=l_detail_balances.operating_acct_cost * p_retirement_factor;
	     do_round(l_detail_balances_retire.operating_acct_cost,P_Book_Type_Code);
             l_detail_balances_retire.operating_acct_net     :=l_detail_balances.operating_acct_net * p_retirement_factor;
	     do_round(l_detail_balances_retire.operating_acct_net,P_Book_Type_Code);
             l_detail_balances_retire.reval_reserve_backlog  := l_detail_balances.reval_reserve_backlog * p_retirement_factor ;
	     do_round(l_detail_balances_retire.reval_reserve_backlog,P_Book_Type_Code);
             l_detail_balances_retire.deprn_ytd              := l_detail_balances.deprn_ytd  * p_retirement_factor;
	     do_round(l_detail_balances_retire.deprn_ytd,P_Book_Type_Code);

           ELSE
             -- get the prior record for the distribution
             OPEN C_get_prior_dist(p_asset_id,p_book_type_code,l_detail_balances.distribution_id,p_prior_period);
             FETCH c_get_prior_dist INTO l_detail_balances_prior;
             CLOSE c_get_prior_dist;

                l_detail_balances_retire.adjustment_cost        := l_detail_balances_prior.adjustment_cost* p_retirement_factor ;
		do_round(l_detail_balances_retire.adjustment_cost,P_Book_Type_Code);
                l_detail_balances_retire.reval_reserve_cost     := l_detail_balances_prior.reval_reserve_cost* p_retirement_factor ;
		do_round(l_detail_balances_retire.reval_reserve_cost,P_Book_Type_Code);
                l_detail_balances_retire.deprn_reserve          := l_detail_balances_prior.deprn_reserve * p_retirement_factor ;
		do_round(l_detail_balances_retire.deprn_reserve,P_Book_Type_Code);
                l_detail_balances_retire.deprn_reserve_backlog  := l_detail_balances_prior.deprn_reserve_backlog * p_retirement_factor ;
		do_round(l_detail_balances_retire.deprn_reserve_backlog,P_Book_Type_Code);
                l_detail_balances_retire.reval_reserve_net      := l_detail_balances_prior.reval_reserve_net  * p_retirement_factor ;
		do_round(l_detail_balances_retire.reval_reserve_net,P_Book_Type_Code);
                l_detail_balances_retire.deprn_period           := l_detail_balances.deprn_period * (1 - p_retirement_factor) ;
		do_round(l_detail_balances_retire.deprn_period,P_Book_Type_Code);
                l_detail_balances_retire.general_fund_acc       := l_detail_balances_prior.general_fund_acc * p_retirement_factor;
		do_round(l_detail_balances_retire.general_fund_acc,P_Book_Type_Code);
                l_detail_balances_retire.general_fund_per       := l_detail_balances_prior.general_fund_per * p_retirement_factor;
		do_round(l_detail_balances_retire.general_fund_per,P_Book_Type_Code);
                l_detail_balances_retire.reval_reserve_gen_fund := l_detail_balances_prior.reval_reserve_gen_fund  * p_retirement_factor;
		do_round(l_detail_balances_retire.reval_reserve_gen_fund,P_Book_Type_Code);
                l_detail_balances_retire.operating_acct_backlog := l_detail_balances_prior.operating_acct_backlog * p_retirement_factor;
		do_round(l_detail_balances_retire.operating_acct_backlog,P_Book_Type_Code);
                l_detail_balances_retire.operating_acct_cost    := l_detail_balances_prior.operating_acct_cost * p_retirement_factor;
		do_round(l_detail_balances_retire.operating_acct_cost,P_Book_Type_Code);
                l_detail_balances_retire.operating_acct_net     := l_detail_balances_prior.operating_acct_net * p_retirement_factor;
		do_round(l_detail_balances_retire.operating_acct_net,P_Book_Type_Code);
                l_detail_balances_retire.reval_reserve_backlog  := l_detail_balances_prior.reval_reserve_backlog * p_retirement_factor ;
		do_round(l_detail_balances_retire.reval_reserve_backlog,P_Book_Type_Code);
                l_detail_balances_retire.deprn_ytd              := l_detail_balances.deprn_ytd  * p_retirement_factor;
		do_round(l_detail_balances_retire.deprn_ytd,P_Book_Type_Code);
           END IF;



             l_fa_retire_acc_deprn   := l_fa_total_old_acc_deprn * p_retirement_factor;
	     do_round(l_fa_retire_acc_deprn,P_Book_Type_Code);
             l_fa_retire_deprn_prd   := l_fa_deprn.deprn_period * (1 - p_retirement_factor);
	     do_round(l_fa_retire_deprn_prd,P_Book_Type_Code);
             l_fa_retire_deprn_ytd   := l_fa_deprn.deprn_ytd    * p_retirement_factor;
	     do_round(l_fa_retire_deprn_ytd,P_Book_Type_Code);

             /*  Do roundings  */

             l_asset_units_count      := l_asset_units_count + l_units_per_dist.units_assigned ;

             IF l_asset_units_count = g_total_asset_units THEN

                 l_detail_balances_retire.adjustment_cost        := l_detail_balances.adjustment_cost        + l_detail_balances_rnd_tot.adjustment_cost;
                 l_detail_balances_retire.reval_reserve_cost     := l_detail_balances.reval_reserve_cost     + l_detail_balances_rnd_tot.reval_reserve_cost;
                 l_detail_balances_retire.deprn_reserve          := l_detail_balances.deprn_reserve          + l_detail_balances_rnd_tot.deprn_reserve ;
                 l_detail_balances_retire.deprn_reserve_backlog  := l_detail_balances.deprn_reserve_backlog  + l_detail_balances_rnd_tot.deprn_reserve_backlog ;
                 l_detail_balances_retire.reval_reserve_net      := l_detail_balances.reval_reserve_net      + l_detail_balances_rnd_tot.reval_reserve_net ;
                 l_detail_balances_retire.deprn_period           := l_detail_balances.deprn_period           + l_detail_balances_rnd_tot.deprn_period;
                 l_detail_balances_retire.general_fund_acc       := l_detail_balances.general_fund_acc       + l_detail_balances_rnd_tot.general_fund_acc;
                 l_detail_balances_retire.general_fund_per       := l_detail_balances.general_fund_per       + l_detail_balances_rnd_tot.general_fund_per;
                 l_detail_balances_retire.reval_reserve_gen_fund := l_detail_balances.reval_reserve_gen_fund + l_detail_balances_rnd_tot.reval_reserve_gen_fund;
                 l_detail_balances_retire.operating_acct_backlog :=l_detail_balances.operating_acct_backlog  + l_detail_balances_rnd_tot.operating_acct_backlog ;
                 l_detail_balances_retire.operating_acct_cost    :=l_detail_balances.operating_acct_cost     + l_detail_balances_rnd_tot.operating_acct_cost;
                 l_detail_balances_retire.operating_acct_net     :=l_detail_balances.operating_acct_net      + l_detail_balances_rnd_tot.operating_acct_net ;
                 l_detail_balances_retire.reval_reserve_backlog  := l_detail_balances.reval_reserve_backlog  + l_detail_balances_rnd_tot.reval_reserve_backlog;
                 l_detail_balances_retire.deprn_ytd              := l_detail_balances.deprn_ytd              + l_detail_balances_rnd_tot.deprn_ytd;


                l_fa_retire_acc_deprn := l_fa_retire_acc_deprn + l_fa_tot_round_acc_deprn;
                l_fa_retire_deprn_prd := l_fa_retire_deprn_prd + l_fa_tot_round_deprn_prd;
                l_fa_retire_deprn_ytd := l_fa_retire_deprn_ytd +  l_fa_tot_round_deprn_ytd;

             END IF ;

    l_detail_balances_retire_unrnd.adjustment_cost        :=l_detail_balances_retire.adjustment_cost ;
             l_detail_balances_retire_unrnd.reval_reserve_cost     :=l_detail_balances_retire.reval_reserve_cost  ;
             l_detail_balances_retire_unrnd.deprn_reserve          := l_detail_balances_retire.deprn_reserve;
             l_detail_balances_retire_unrnd.deprn_reserve_backlog  := l_detail_balances_retire.deprn_reserve_backlog;
             l_detail_balances_retire_unrnd.reval_reserve_net      := l_detail_balances_retire.reval_reserve_net ;
             l_detail_balances_retire_unrnd.deprn_period           := l_detail_balances_retire.deprn_period;
             l_detail_balances_retire_unrnd.general_fund_acc       := l_detail_balances_retire.general_fund_acc;
             l_detail_balances_retire_unrnd.general_fund_per       := l_detail_balances_retire.general_fund_per;
             l_detail_balances_retire_unrnd.reval_reserve_gen_fund := l_detail_balances_retire.reval_reserve_gen_fund;
             l_detail_balances_retire_unrnd.operating_acct_backlog := l_detail_balances_retire.operating_acct_backlog;
             l_detail_balances_retire_unrnd.operating_acct_cost    := l_detail_balances_retire.operating_acct_cost;
             l_detail_balances_retire_unrnd.operating_acct_net     := l_detail_balances_retire.operating_acct_net;
             l_detail_balances_retire_unrnd.reval_reserve_backlog  := l_detail_balances_retire.reval_reserve_backlog;
             l_detail_balances_retire_unrnd.deprn_ytd              := l_detail_balances_retire.deprn_ytd;



             l_fa_unround_acc_deprn := l_fa_retire_acc_deprn;
             l_fa_unround_deprn_prd := l_fa_retire_deprn_prd;
             l_fa_unround_deprn_ytd := l_fa_retire_deprn_ytd;


             l_ret:= igi_iac_common_utils.iac_round(l_detail_balances_retire.adjustment_cost,P_Book_Type_Code) ;
             l_ret:= igi_iac_common_utils.iac_round(l_detail_balances_retire.reval_reserve_cost,P_Book_Type_Code)  ;
             l_ret:= igi_iac_common_utils.iac_round(l_detail_balances_retire.deprn_reserve,P_Book_Type_Code) ;
             l_ret:= igi_iac_common_utils.iac_round(l_detail_balances_retire.deprn_reserve_backlog,P_Book_Type_Code)  ;
             l_ret:= igi_iac_common_utils.iac_round(l_detail_balances_retire.reval_reserve_net,P_Book_Type_Code) ;
             l_ret:= igi_iac_common_utils.iac_round(l_detail_balances_retire.deprn_period,P_Book_Type_Code)      ;
             l_ret:= igi_iac_common_utils.iac_round(l_detail_balances_retire.general_fund_acc,P_Book_Type_Code)  ;
             l_ret:= igi_iac_common_utils.iac_round(l_detail_balances_retire.general_fund_per,P_Book_Type_Code)  ;
             l_ret:= igi_iac_common_utils.iac_round(l_detail_balances_retire.reval_reserve_gen_fund,P_Book_Type_Code) ;
             l_ret:= igi_iac_common_utils.iac_round(l_detail_balances_retire.operating_acct_backlog,P_Book_Type_Code) ;
             l_ret:= igi_iac_common_utils.iac_round(l_detail_balances_retire.operating_acct_cost,P_Book_Type_Code)    ;
             l_ret:= igi_iac_common_utils.iac_round(l_detail_balances_retire.operating_acct_net,P_Book_Type_Code)     ;
             l_ret:= igi_iac_common_utils.iac_round(l_detail_balances_retire.reval_reserve_backlog,P_Book_Type_Code)  ;
             l_ret:= igi_iac_common_utils.iac_round(l_detail_balances_retire.deprn_ytd,P_Book_Type_Code)          ;

              l_ret:= igi_iac_common_utils.iac_round(l_fa_retire_acc_deprn,P_Book_Type_Code)          ;
              l_ret:= igi_iac_common_utils.iac_round(l_fa_retire_deprn_prd,P_Book_Type_Code)          ;
              l_ret:= igi_iac_common_utils.iac_round(l_fa_retire_deprn_ytd,P_Book_Type_Code)          ;

             l_detail_balances_rnd_tot.adjustment_cost:= l_detail_balances_rnd_tot.adjustment_cost;

             l_detail_balances_rnd_tot.adjustment_cost        := l_detail_balances_rnd_tot.adjustment_cost +
             (l_detail_balances_retire_unrnd.adjustment_cost - l_detail_balances_retire.adjustment_cost);
             l_detail_balances_rnd_tot.reval_reserve_cost     := l_detail_balances_rnd_tot.reval_reserve_cost +
             (l_detail_balances_retire_unrnd.reval_reserve_cost - l_detail_balances_retire.reval_reserve_cost);
             l_detail_balances_rnd_tot.deprn_reserve          := l_detail_balances_rnd_tot.deprn_reserve +
             (l_detail_balances_retire_unrnd.deprn_reserve - l_detail_balances_retire.deprn_reserve) ;
             l_detail_balances_rnd_tot.deprn_reserve_backlog  := l_detail_balances_rnd_tot.deprn_reserve_backlog +
             (l_detail_balances_retire_unrnd.deprn_reserve_backlog - l_detail_balances_retire.deprn_reserve_backlog) ;
             l_detail_balances_rnd_tot.reval_reserve_net      := l_detail_balances_rnd_tot.reval_reserve_net +
             (l_detail_balances_retire_unrnd.reval_reserve_net - l_detail_balances_retire.reval_reserve_net);
             l_detail_balances_rnd_tot.deprn_period           := l_detail_balances_rnd_tot.deprn_period +
              (l_detail_balances_retire_unrnd.deprn_period - l_detail_balances_retire.deprn_period);
             l_detail_balances_rnd_tot.general_fund_acc       := l_detail_balances_rnd_tot.general_fund_acc +
             (l_detail_balances_retire_unrnd.general_fund_acc - l_detail_balances_retire.general_fund_acc);
             l_detail_balances_rnd_tot.general_fund_per       := l_detail_balances_rnd_tot.general_fund_per +
             (l_detail_balances_retire_unrnd.general_fund_per- l_detail_balances_retire.general_fund_per);
             l_detail_balances_rnd_tot.reval_reserve_gen_fund := l_detail_balances_rnd_tot.reval_reserve_gen_fund +
             (l_detail_balances_retire_unrnd.reval_reserve_gen_fund - l_detail_balances_retire.reval_reserve_gen_fund);
             l_detail_balances_rnd_tot.operating_acct_backlog :=l_detail_balances_rnd_tot.operating_acct_backlog +
             (l_detail_balances_retire_unrnd.operating_acct_backlog - l_detail_balances_retire.operating_acct_backlog) ;
             l_detail_balances_rnd_tot.operating_acct_cost    :=l_detail_balances_rnd_tot.operating_acct_cost +
             (l_detail_balances_retire_unrnd.operating_acct_cost - l_detail_balances_retire.operating_acct_cost);
             l_detail_balances_rnd_tot.operating_acct_net     :=l_detail_balances_rnd_tot.operating_acct_net+
             (l_detail_balances_retire_unrnd.operating_acct_net - l_detail_balances_retire.operating_acct_net) ;
             l_detail_balances_rnd_tot.reval_reserve_backlog  := l_detail_balances_rnd_tot.reval_reserve_backlog +
             (l_detail_balances_retire_unrnd.reval_reserve_backlog - l_detail_balances_retire.reval_reserve_backlog);
             l_detail_balances_rnd_tot.deprn_ytd              := l_detail_balances_rnd_tot.deprn_ytd +
             (l_detail_balances_retire_unrnd.deprn_ytd - l_detail_balances_retire.deprn_ytd);


             l_fa_tot_round_acc_deprn   := l_fa_tot_round_acc_deprn   + l_fa_unround_acc_deprn   - l_fa_retire_acc_deprn ;
             l_fa_tot_round_deprn_prd   := l_fa_tot_round_deprn_prd   + l_fa_unround_deprn_prd   - l_fa_retire_deprn_prd ;
             l_fa_tot_round_deprn_ytd   := l_fa_tot_round_deprn_ytd   + l_fa_unround_deprn_ytd   - l_fa_retire_deprn_ytd ;


     	     debug( g_state_level,l_path_name,'done roundings');


             debug( g_state_level,l_path_name,'adjustment_cost     retire  ' || l_detail_balances_retire.adjustment_cost);
             debug( g_state_level,l_path_name,'reval_reserve_cost  retire  ' || l_detail_balances_retire.reval_reserve_cost);
             debug( g_state_level,l_path_name,'deprn_reserve       retire  ' ||l_detail_balances_retire.deprn_reserve);
             debug( g_state_level,l_path_name,'deprn_reserve_backlog retire' ||l_detail_balances_retire.deprn_reserve_backlog);
             debug( g_state_level,l_path_name,'reval_reserve_nett   retire ' ||l_detail_balances_retire.reval_reserve_net);
             debug( g_state_level,l_path_name,'operating_acct_backlog retire' ||l_detail_balances_retire.operating_acct_backlog);
             debug( g_state_level,l_path_name,'operating_acct_net  retire  ' ||l_detail_balances_retire.operating_acct_net);
             debug( g_state_level,l_path_name,'reval_reserve_backlog retire ' ||l_detail_balances_retire.reval_reserve_backlog);

             /* Calculate new totals  */
             l_detail_balances_new.adjustment_cost        := l_detail_balances.adjustment_cost        - l_detail_balances_retire.adjustment_cost;
             l_detail_balances_new.reval_reserve_cost     := l_detail_balances.reval_reserve_cost     - l_detail_balances_retire.reval_reserve_cost;
             l_detail_balances_new.deprn_reserve          := l_detail_balances.deprn_reserve          - l_detail_balances_retire.deprn_reserve ;
             l_detail_balances_new.deprn_reserve_backlog  := l_detail_balances.deprn_reserve_backlog  - l_detail_balances_retire.deprn_reserve_backlog ;
             l_detail_balances_new.reval_reserve_net      := l_detail_balances.reval_reserve_net      - l_detail_balances_retire.reval_reserve_net ;
             l_detail_balances_new.deprn_period           := l_detail_balances.deprn_period           - l_detail_balances_retire.deprn_period;
             l_detail_balances_new.general_fund_acc       := l_detail_balances.general_fund_acc       - l_detail_balances_retire.general_fund_acc;
             l_detail_balances_new.general_fund_per       := l_detail_balances.general_fund_per       - l_detail_balances_retire.general_fund_per;
             l_detail_balances_new.reval_reserve_gen_fund := l_detail_balances.reval_reserve_gen_fund - l_detail_balances_retire.reval_reserve_gen_fund;
             l_detail_balances_new.operating_acct_backlog :=l_detail_balances.operating_acct_backlog  - l_detail_balances_retire.operating_acct_backlog;
             l_detail_balances_new.operating_acct_cost    :=l_detail_balances.operating_acct_cost     - l_detail_balances_retire.operating_acct_cost;
             l_detail_balances_new.operating_acct_net     :=l_detail_balances.operating_acct_net      - l_detail_balances_retire.operating_acct_net ;
             l_detail_balances_new.reval_reserve_backlog  := l_detail_balances.reval_reserve_backlog  - l_detail_balances_retire.reval_reserve_backlog;
             l_detail_balances_new.deprn_ytd              := l_detail_balances.deprn_ytd              - l_detail_balances_retire.deprn_ytd;

             l_detail_balances_new.net_book_value := l_detail_balances_new.adjustment_cost - l_detail_balances_new.deprn_reserve -l_detail_balances_new.deprn_reserve_backlog  ;

             debug( g_state_level,l_path_name,'adjustment_cost   new  ' || l_detail_balances_new.adjustment_cost);
             debug( g_state_level,l_path_name,'reval_reserve_cost  new  ' || l_detail_balances_new.reval_reserve_cost);
             debug( g_state_level,l_path_name,'deprn_reserve       new  ' ||l_detail_balances_new.deprn_reserve);
             debug( g_state_level,l_path_name,'deprn_reserve_backlog new' ||l_detail_balances_new.deprn_reserve_backlog);
             debug( g_state_level,l_path_name,'reval_reserve_nett  new ' ||l_detail_balances_new.reval_reserve_net);
             debug( g_state_level,l_path_name,'operating_acct_backlog new' ||l_detail_balances_new.operating_acct_backlog);
             debug( g_state_level,l_path_name,'operating_acct_net  new  ' ||l_detail_balances_new.operating_acct_net);
             debug( g_state_level,l_path_name,'reval_reserve_backlog new ' ||l_detail_balances_new.reval_reserve_backlog);


             l_fa_total_new_acc_deprn   := l_fa_total_old_acc_deprn  - l_fa_retire_acc_deprn ;
             l_fa_total_new_deprn_prd   := l_fa_deprn.deprn_period   - l_fa_retire_deprn_prd ;
             l_fa_total_new_deprn_ytd   := l_fa_deprn.deprn_ytd      - l_fa_retire_deprn_ytd ;

             IF P_retirement_type='FULL' THEN
                l_detail_balances_new.deprn_period :=0;
                l_detail_balances_new.deprn_ytd    :=0;
                l_fa_total_new_deprn_prd           :=0;
                l_fa_total_new_deprn_ytd           :=0;
             END IF;

             --asset total;
             l_asset_balances.net_book_value :=l_asset_balances.net_book_value+l_detail_balances_new.net_book_value;
             l_asset_balances.adjusted_cost  :=l_asset_balances.adjusted_cost +l_detail_balances_new.adjustment_cost;
             l_asset_balances.operating_acct :=l_asset_balances.operating_acct+ l_detail_balances_new.operating_acct_net;
             l_asset_balances.reval_reserve  :=l_asset_balances.reval_reserve +l_detail_balances_new.reval_reserve_net;
             l_asset_balances.deprn_amount   :=l_asset_balances.deprn_amount  +l_detail_balances_new.deprn_period;
             l_asset_balances.deprn_reserve  :=l_asset_balances.deprn_reserve +l_detail_balances_new.deprn_reserve;
             l_asset_balances.backlog_deprn_reserve:=l_asset_balances.backlog_deprn_reserve+l_detail_balances_new.deprn_reserve_backlog;
             l_asset_balances.general_fund   :=l_asset_balances.general_fund +l_detail_balances_new.general_fund_acc;




             /*  Create adjustment to reverse out NOCOPY old balances  */
             IF NOT (igi_iac_common_utils.get_account_ccid(P_Book_Type_Code,P_Asset_Id,l_detail_balances.distribution_id,
                                                       'ASSET_COST_ACCT',g_retire_rec.detail_info.transaction_header_id_in,
                                                       'RETIREMENT',l_cost_account_ccid
                                                       )) THEN
                    RAISE e_no_account_ccid ;
             END IF ;

             debug( g_state_level,l_path_name,'done cost get acct ccid');
             l_rowid := NULL ;
             debug( g_state_level, l_path_name,'done cost adjustment');
         	 debug( g_state_level, l_path_name,'dist id: '||l_detail_balances.distribution_id);
             l_acc_deprn_account_ccid := NULL;
             IF NOT (igi_iac_common_utils.get_account_ccid(P_Book_Type_Code,P_Asset_Id,l_detail_balances.distribution_id,
                                                       'DEPRN_RESERVE_ACCT',g_retire_rec.detail_info.transaction_header_id_in,
                                                       'RETIREMENT',l_acc_deprn_account_ccid
                                                       )) THEN
                    RAISE e_no_account_ccid ;
             END IF ;
     	    debug( g_state_level,l_path_name,'done deprn rsv ccid');
    	    debug( g_state_level,l_path_name, '*' ||l_acc_deprn_account_ccid || '*');

           IF NOT (igi_iac_common_utils.get_account_ccid(P_Book_Type_Code,P_Asset_Id,l_detail_balances.distribution_id,
                                                       'REVAL_RESERVE_ACCT',g_retire_rec.detail_info.transaction_header_id_in,
                                                       'RETIREMENT',l_reval_rsv_account_ccid
                                                       )) THEN
             RAISE e_no_account_ccid ;
          END IF ;
     	 debug( g_state_level,l_path_name,'done reval rsv ccid');
         IF NOT (igi_iac_common_utils.get_account_ccid(P_Book_Type_Code,P_Asset_Id,l_detail_balances.distribution_id,
                                                       'BACKLOG_DEPRN_RSV_ACCT',g_retire_rec.detail_info.transaction_header_id_in,
                                                       'RETIREMENT',l_backlog_account_ccid
                                                       )) THEN
            RAISE e_no_account_ccid ;
         END IF ;
     	 debug( g_state_level,l_path_name,'done backlog ccid');

        /*  Create new adjustments for retirement part        */

        IF ((l_detail_balances_retire.adjustment_cost-l_detail_balances_retire.deprn_reserve)<> 0) OR
            (l_detail_balances_retire.deprn_reserve_backlog <> 0) THEN

         IF NOT (igi_iac_common_utils.get_account_ccid(P_Book_Type_Code,P_Asset_Id,l_detail_balances.distribution_id,
                                                       'NBV_RETIRED_GAIN_ACCT',g_retire_rec.detail_info.transaction_header_id_in,
                                                       'RETIREMENT',l_nbv_retired_account_ccid
                                                       )) THEN
            RAISE e_no_account_ccid ;
         END IF ;

     	 debug( g_state_level,l_path_name,'done nbv ret ccid');

         l_rowid := NULL ;

         igi_iac_adjustments_pkg.insert_row(
		     		    	    X_rowid                 => l_rowid ,
                                X_adjustment_id         => l_retirement_adjustment_id ,
                                X_book_type_code		=> P_Book_Type_Code ,
                                X_code_combination_id	=> l_nbv_retired_account_ccid,
                                X_set_of_books_id		=> g_sob_id ,
                                X_dr_cr_flag            => 'DR' ,
                                X_amount               	=> l_detail_balances_retire.adjustment_cost-l_detail_balances_retire.deprn_reserve,
                                X_adjustment_type      	=> 'NBV RETIRED',
                                X_transfer_to_gl_flag  	=> 'Y' ,
                                X_units_assigned		=> l_units_per_dist.units_assigned ,
                                X_asset_id		        => P_Asset_Id ,
                                X_distribution_id      	=> l_detail_balances.distribution_id ,
                                X_period_counter       	=> g_prd_rec.period_counter,
                                X_adjustment_offset_type => NULL,
                                X_report_ccid        	=>   NULL,
                                X_mode                  => 'R',
                                X_event_id              => P_Event_Id  ) ;

     	 debug( g_state_level,l_path_name,'NBV RETIRED...');

         l_rowid := NULL ;

         igi_iac_adjustments_pkg.insert_row(
		     		    	    X_rowid                 => l_rowid ,
                                X_adjustment_id         => l_retirement_adjustment_id ,
                                X_book_type_code		=> P_Book_Type_Code ,
                                X_code_combination_id	=> l_nbv_retired_account_ccid,
                                X_set_of_books_id		=> g_sob_id ,
                                X_dr_cr_flag            => 'CR' ,
                                X_amount               	=> l_detail_balances_retire.deprn_reserve_backlog,
                                X_adjustment_type      	=> 'NBV RETIRED',
                                X_transfer_to_gl_flag  	=> 'Y' ,
                                X_units_assigned		=> l_units_per_dist.units_assigned ,
                                X_asset_id		        => P_Asset_Id ,
                                X_distribution_id      	=> l_detail_balances.distribution_id ,
                                X_period_counter       	=> g_prd_rec.period_counter,
                                X_adjustment_offset_type => NULL,
                                X_report_ccid        	=>  NULL,
                                X_mode                  => 'R',
                                X_event_id              => P_Event_Id  ) ;

    debug( g_state_level,l_path_name,'NBV RETIRED...'|| l_detail_balances_retire.deprn_reserve_backlog);


     	 debug( g_state_level,l_path_name, 'done 2nd nbv ret insert');
        END IF;

         IF l_detail_balances_retire.reval_reserve_net <> 0 THEN

            IF NOT (igi_iac_common_utils.get_account_ccid(P_Book_Type_Code,P_Asset_Id,l_detail_balances.distribution_id,
                                                       'REVAL_RESERVE_RETIRED_ACCT',g_retire_rec.detail_info.transaction_header_id_in,
                                                       'RETIREMENT',l_reval_rsv_ret_acct_ccid
                                                       )) THEN
                RAISE e_no_account_ccid ;
            END IF ;
     	    debug( g_state_level,l_path_name,'done reval rsv ret ccid');
            l_rowid := NULL ;
             igi_iac_adjustments_pkg.insert_row(
		     		    	    X_rowid                 => l_rowid ,
                                X_adjustment_id         => l_retirement_adjustment_id ,
                                X_book_type_code		=> P_Book_Type_Code ,
                                X_code_combination_id	=> l_reval_rsv_ret_acct_ccid,
                                X_set_of_books_id		=> g_sob_id ,
                                X_dr_cr_flag            => 'CR' ,
                                X_amount               	=> l_detail_balances_retire.reval_reserve_net,
                                X_adjustment_type      	=> 'REVAL RSV RET',
                                X_transfer_to_gl_flag  	=> 'Y' ,
                                X_units_assigned		=> l_units_per_dist.units_assigned ,
                                X_asset_id		        => P_Asset_Id ,
                                X_distribution_id      	=> l_detail_balances.distribution_id ,
                                X_period_counter       	=> g_prd_rec.period_counter,
                                X_adjustment_offset_type => NULL,
                                X_report_ccid        	=>  NULL,
                                X_mode                  => 'R',
                                X_event_id              => P_Event_Id  ) ;

     	  debug( g_state_level,l_path_name,'REVAL RSV RETD...'|| l_detail_balances_retire.reval_reserve_net);
        END IF;

         /*  Create adjustment for new balances   */
     	 debug( g_state_level,l_path_name,'start new balances');
         l_rowid := NULL ;
         igi_iac_adjustments_pkg.insert_row(
		     		    	    X_rowid                 => l_rowid ,
                                X_adjustment_id         => l_retirement_adjustment_id ,
                                X_book_type_code		=> P_Book_Type_Code ,
                                X_code_combination_id	=> l_cost_account_ccid,
                                X_set_of_books_id		=> g_sob_id ,
                                X_dr_cr_flag            => 'CR' ,
                                X_amount               	=> l_detail_balances_retire.adjustment_cost,
                                X_adjustment_type      	=> 'COST',
                                X_transfer_to_gl_flag  	=> 'Y' ,
                                X_units_assigned		=> l_units_per_dist.units_assigned ,
                                X_asset_id		        => P_Asset_Id ,
                                X_distribution_id      	=> l_detail_balances.distribution_id ,
                                X_period_counter       	=> g_prd_rec.period_counter,
                                X_adjustment_offset_type => NULL,
                                X_report_ccid        	=>  NULL,
                                X_mode                  => 'R',
                                X_event_id              => P_Event_Id  ) ;



     	     debug( g_state_level,l_path_name,'COST...'|| l_detail_balances_retire.adjustment_cost);
             IF l_detail_balances_retire.deprn_reserve <> 0 THEN

                l_rowid := NULL ;
                 igi_iac_adjustments_pkg.insert_row(
		     		    	    X_rowid                 => l_rowid ,
                                X_adjustment_id         => l_retirement_adjustment_id ,
                                X_book_type_code		=> P_Book_Type_Code ,
                                X_code_combination_id	=> l_acc_deprn_account_ccid,
                                X_set_of_books_id		=> g_sob_id ,
                                X_dr_cr_flag            => 'DR' ,
                                X_amount               	=> l_detail_balances_retire.deprn_reserve,
                                X_adjustment_type      	=> 'RESERVE',
                                X_transfer_to_gl_flag  	=> 'Y' ,
                                X_units_assigned		=> l_units_per_dist.units_assigned ,
                                X_asset_id		        => P_Asset_Id ,
                                X_distribution_id      	=> l_detail_balances.distribution_id ,
                                X_period_counter       	=> g_prd_rec.period_counter,
                                X_adjustment_offset_type => NULL,
                                X_report_ccid        	=>  NULL,
                                X_mode                  => 'R',
                                X_event_id              => P_Event_Id  ) ;


              END IF;

              IF l_detail_balances_retire.operating_acct_backlog <> 0 THEN

                   IF NOT (igi_iac_common_utils.get_account_ccid(P_Book_Type_Code,P_Asset_Id,l_detail_balances.distribution_id,
                                                       'OPERATING_EXPENSE_ACCT',g_retire_rec.detail_info.transaction_header_id_in,
                                                       'RETIREMENT',l_op_exp_ccid
                                                       )) THEN
                       RAISE e_no_account_ccid ;
                END IF ;

                 l_rowid := NULL ;
                 igi_iac_adjustments_pkg.insert_row(
		     		    	    X_rowid                 => l_rowid ,
                                X_adjustment_id         => l_retirement_adjustment_id ,
                                X_book_type_code		=> P_Book_Type_Code ,
                                X_code_combination_id	=> l_backlog_account_ccid,
                                X_set_of_books_id		=> g_sob_id ,
                                X_dr_cr_flag            => 'DR' ,
                                X_amount               	=> l_detail_balances_retire.operating_acct_backlog,
                                X_adjustment_type      	=> 'BL RESERVE',
                                X_transfer_to_gl_flag  	=> 'Y' ,
                                X_units_assigned		=> l_units_per_dist.units_assigned ,
                                X_asset_id		        => P_Asset_Id ,
                                X_distribution_id      	=> l_detail_balances.distribution_id ,
                                X_period_counter       	=> g_prd_rec.period_counter,
                                X_adjustment_offset_type => 'OP EXPENSE',
                                X_report_ccid        	=> l_op_exp_ccid,
                                X_mode                  => 'R',
                                X_event_id              => P_Event_Id  ) ;



             	   debug( g_state_level,l_path_name,' BL reserve for OP '||l_detail_balances_retire.operating_acct_backlog );
               END IF;

            IF l_detail_balances_retire.reval_reserve_backlog <> 0 THEN

                 l_rowid := NULL ;
                 igi_iac_adjustments_pkg.insert_row(
		     		    	    X_rowid                 => l_rowid ,
                                X_adjustment_id         => l_retirement_adjustment_id ,
                                X_book_type_code		=> P_Book_Type_Code ,
                                X_code_combination_id	=> l_backlog_account_ccid,
                                X_set_of_books_id		=> g_sob_id ,
                                X_dr_cr_flag            => 'DR' ,
                                X_amount               	=> l_detail_balances_retire.reval_reserve_backlog,
                                X_adjustment_type      	=> 'BL RESERVE',
                                X_transfer_to_gl_flag  	=> 'Y' ,
                                X_units_assigned		=> l_units_per_dist.units_assigned ,
                                X_asset_id		        => P_Asset_Id ,
                                X_distribution_id      	=> l_detail_balances.distribution_id ,
                                X_period_counter       	=> g_prd_rec.period_counter,
                                X_adjustment_offset_type => 'REVAL RESERVE',
                                X_report_ccid        	=>  l_reval_rsv_account_ccid,
                                X_mode                  => 'R',
                                X_event_id              => P_Event_Id  ) ;



             	   debug( g_state_level,l_path_name,'done BL reserve for RR '||l_detail_balances_retire.reval_reserve_backlog );
               END IF;



           IF l_detail_balances_retire.reval_reserve_net <> 0 THEN

                l_rowid := NULL ;
               igi_iac_adjustments_pkg.insert_row(
		     		    	    X_rowid                 => l_rowid ,
                                X_adjustment_id         => l_retirement_adjustment_id ,
                                X_book_type_code		=> P_Book_Type_Code ,
                                X_code_combination_id	=> l_reval_rsv_account_ccid,
                                X_set_of_books_id		=> g_sob_id ,
                                X_dr_cr_flag            => 'DR' ,
                                X_amount               	=> l_detail_balances_retire.reval_reserve_net,
                                X_adjustment_type      	=> 'REVAL RESERVE',
                                X_transfer_to_gl_flag  	=> 'Y' ,
                                X_units_assigned		=> l_units_per_dist.units_assigned ,
                                X_asset_id		        => P_Asset_Id ,
                                X_distribution_id      	=> l_detail_balances.distribution_id ,
                                X_period_counter       	=> g_prd_rec.period_counter,
                                X_adjustment_offset_type => NULL,
                                X_report_ccid        	=>  NULL,
                                X_mode                  => 'R',
                                X_event_id              => P_Event_Id  ) ;

            debug( g_state_level,l_path_name,'done  reval rsv' || l_detail_balances_retire.reval_reserve_net);

            END IF;

     	   debug( g_state_level,l_path_name,'end new balances');

           /*  Insert new detail balance record for this distribution   */
         IF (g_is_first_period) THEN
           l_db_op_acct_ytd := 0;
           l_db_deprn_ytd   := 0;
         ELSE
           l_db_op_acct_ytd := l_detail_balances.operating_acct_ytd;
           l_db_deprn_ytd   := l_detail_balances.deprn_ytd;
         END IF;

     	 debug( g_state_level,l_path_name,'start insert det bal');
  	 l_rowid := NULL ;

              igi_iac_det_balances_pkg.insert_row(
                       		X_rowid                     => l_rowid ,
			     		    X_adjustment_id		        => l_retirement_adjustment_id ,
    					    X_asset_id		            => P_Asset_Id ,
	    				    X_distribution_id	        => l_detail_balances.distribution_id ,
		    			    X_book_type_code	        => P_Book_Type_Code ,
			    		    X_period_counter	        => g_prd_rec.period_counter,
				    	    X_adjustment_cost	        => l_detail_balances_new.adjustment_cost ,
                            X_net_book_value	        => l_detail_balances_new.net_book_value,
        				    X_reval_reserve_cost	    => l_detail_balances_new.reval_reserve_cost,
		    			    X_reval_reserve_backlog     => l_detail_balances_new.reval_reserve_backlog,
			    		    X_reval_reserve_gen_fund    => l_detail_balances_new.reval_reserve_gen_fund,
				    	    X_reval_reserve_net	        => l_detail_balances_new.reval_reserve_net,
                            X_operating_acct_cost	    => l_detail_balances_new.operating_acct_cost,
    					    X_operating_acct_backlog    => l_detail_balances_new.operating_acct_backlog,
	    				    X_operating_acct_net	    => l_detail_balances_new.operating_acct_net,
 		    			    X_operating_acct_ytd	    => l_detail_balances.operating_acct_ytd,
			    		    X_deprn_period		        => l_detail_balances_new.deprn_period,
 				    	    X_deprn_ytd		            => l_detail_balances_new.deprn_ytd,
                            X_deprn_reserve		        => l_detail_balances_new.deprn_reserve,
    					    X_deprn_reserve_backlog	    => l_detail_balances_new.deprn_reserve_backlog,
	    				    X_general_fund_per	        => l_detail_balances_new.general_fund_per,
		    			    X_general_fund_acc	        => l_detail_balances_new.general_fund_acc,
 			    		    X_last_reval_date	        => l_detail_balances.last_reval_date ,
				    	    X_current_reval_factor	    => l_detail_balances.current_reval_factor ,
                            X_cumulative_reval_factor   => l_detail_balances.cumulative_reval_factor ,
     					    X_active_flag		        => l_detail_balances.active_flag,
                            X_mode                      =>  'R') ;

                            debug( g_state_level,l_path_name,'CURRENT PERIOD');
			     		    debug( g_state_level,l_path_name,'X_adjustment_id		   => '||l_retirement_adjustment_id );
    					    debug( g_state_level,l_path_name,'X_asset_id		       =>'|| P_Asset_Id );
    	        			debug( g_state_level,l_path_name,'X_distribution_id	       =>'|| l_detail_balances.distribution_id );
    	        			debug( g_state_level,l_path_name,'X_book_type_code	       =>'|| P_Book_Type_Code );
    	        			debug( g_state_level,l_path_name,'X_period_counter	       =>'|| g_prd_rec.period_counter);
    	        			debug( g_state_level,l_path_name,'X_adjustment_cost	       =>'|| l_detail_balances_new.adjustment_cost );
    	        			debug( g_state_level,l_path_name,'X_net_book_value	       =>'|| l_detail_balances_new.net_book_value);
    	        			debug( g_state_level,l_path_name,'X_reval_reserve_cost	   =>'|| l_detail_balances_new.reval_reserve_cost);
    	        			debug( g_state_level,l_path_name,'X_reval_reserve_backlog  =>'|| l_detail_balances_new.reval_reserve_backlog);
    	        			debug( g_state_level,l_path_name,'X_reval_reserve_gen_fund =>'|| l_detail_balances_new.reval_reserve_gen_fund);
      	        			debug( g_state_level,l_path_name,'X_reval_reserve_net	   =>'|| l_detail_balances_new.reval_reserve_net);
                            debug( g_state_level,l_path_name,'X_operating_acct_cost	   =>'|| l_detail_balances_new.operating_acct_cost);
                            debug( g_state_level,l_path_name,'X_operating_acct_backlog =>'|| l_detail_balances_new.operating_acct_backlog);
                            debug( g_state_level,l_path_name,'X_operating_acct_net	   =>'|| l_detail_balances_new.operating_acct_net);
                            debug( g_state_level,l_path_name,'X_operating_acct_ytd	   =>'|| l_detail_balances.operating_acct_ytd);
                            debug( g_state_level,l_path_name,'X_deprn_period		   =>'|| l_detail_balances_new.deprn_period);
                            debug( g_state_level,l_path_name,'X_deprn_ytd		       =>'|| l_detail_balances_new.deprn_ytd);
                            debug( g_state_level,l_path_name,'X_deprn_reserve		   =>'|| l_detail_balances_new.deprn_reserve);
                            debug( g_state_level,l_path_name,'X_deprn_reserve_backlog  =>'|| l_detail_balances_new.deprn_reserve_backlog);
                            debug( g_state_level,l_path_name,'X_general_fund_per	   =>'|| l_detail_balances_new.general_fund_per);
                            debug( g_state_level,l_path_name,'X_general_fund_acc	   =>'|| l_detail_balances_new.general_fund_acc);
                            debug( g_state_level,l_path_name,'X_last_reval_date	       =>'|| l_detail_balances.last_reval_date );
                            debug( g_state_level,l_path_name,'X_current_reval_factor   =>'|| l_detail_balances.current_reval_factor );
                            debug( g_state_level,l_path_name,'X_cumulative_reval_factor=>'|| l_detail_balances.cumulative_reval_factor );
                            debug( g_state_level,l_path_name,'X_active_flag		       =>'|| l_detail_balances.active_flag);



     	   debug( g_state_level,l_path_name,'end insert det bals');

           IF (g_is_first_period) THEN
               l_fa_deprn.deprn_ytd   := 0;
           ELSE
               l_fa_deprn_ytd   := l_fa_deprn.deprn_ytd;
           END IF;
           -- insert into igi_iac_fa_deprn with the reinstatement adjustment_id
           IGI_IAC_FA_DEPRN_PKG.Insert_Row(
                   x_rowid                => g_rowid,
                   x_book_type_code       => p_book_type_code,
                   x_asset_id             => p_asset_id,
                   x_period_counter       => g_prd_rec.period_counter,
                   x_adjustment_id        => l_retirement_adjustment_id,
                   x_distribution_id      => l_fa_deprn.distribution_id,
                   x_deprn_period         => l_fa_total_new_deprn_prd,
                   x_deprn_ytd            => l_fa_total_new_deprn_ytd,
                   x_deprn_reserve        => l_fa_total_new_acc_deprn,
                   x_active_flag          => NULL,
                   x_mode                 => 'R'
                                      );


         END IF ;


       ELSE  -- Inactive distributions IF active_flag is NULL.  i.e. following code for active_flag = 'N'

     	 debug( g_state_level,l_path_name,'YTD record insert');
         /*  Roll forward YTD records   */
           IF (g_is_first_period) THEN
               l_fa_deprn_ytd   := 0;
           ELSE
               l_fa_deprn_ytd   := l_fa_deprn.deprn_ytd;
           END IF;

            IF p_retirement_type = 'FULL' THEN
               l_detail_balances.deprn_ytd := 0;
               l_db_deprn_ytd   := 0;
               l_fa_deprn_ytd   := 0;
           ELSE
		l_detail_balances.deprn_ytd:=   l_detail_balances.deprn_ytd * p_retirement_factor;
		do_round(l_detail_balances.deprn_ytd,P_Book_Type_Code);
                l_fa_deprn_ytd := l_fa_deprn_ytd *p_retirement_factor;
		do_round(l_fa_deprn_ytd,P_Book_Type_Code);
                l_ret:= igi_iac_common_utils.iac_round(l_detail_balances.deprn_ytd,P_Book_Type_Code);
                l_ret:= igi_iac_common_utils.iac_round(l_fa_deprn_ytd,P_Book_Type_Code);
            END IF;

              igi_iac_det_balances_pkg.insert_row(
                       		X_rowid                     => l_rowid ,
			     		    X_adjustment_id		        => l_retirement_adjustment_id ,
    					    X_asset_id		            => P_Asset_Id,
	    				    X_distribution_id	        => l_detail_balances.distribution_id ,
		    			    X_book_type_code	        => P_Book_Type_Code ,
			    		    X_period_counter	        => g_prd_rec.period_counter,
				    	    X_adjustment_cost	        => l_detail_balances.adjustment_cost ,
                            X_net_book_value	        => l_detail_balances.net_book_value,
        				    X_reval_reserve_cost	    => l_detail_balances.reval_reserve_cost,
		    			    X_reval_reserve_backlog     => l_detail_balances.reval_reserve_backlog,
			    		    X_reval_reserve_gen_fund    => l_detail_balances.reval_reserve_gen_fund,
				    	    X_reval_reserve_net	        => l_detail_balances.reval_reserve_net,
                            X_operating_acct_cost	    => l_detail_balances.operating_acct_cost,
    					    X_operating_acct_backlog    => l_detail_balances.operating_acct_backlog,
	    				    X_operating_acct_net	    => l_detail_balances.operating_acct_net,
 		    			    X_operating_acct_ytd	    => l_detail_balances.operating_acct_ytd,
			    		    X_deprn_period		        => l_detail_balances.deprn_period,
 				    	    X_deprn_ytd		            => l_detail_balances.deprn_ytd,
                            X_deprn_reserve		        => l_detail_balances.deprn_reserve,
    					    X_deprn_reserve_backlog	    => l_detail_balances.deprn_reserve_backlog,
	    				    X_general_fund_per	        => l_detail_balances.general_fund_per,
		    			    X_general_fund_acc	        => l_detail_balances.general_fund_acc,
 			    		    X_last_reval_date	        => l_detail_balances.last_reval_date ,
				    	    X_current_reval_factor	    => l_detail_balances.current_reval_factor ,
                            X_cumulative_reval_factor   => l_detail_balances.cumulative_reval_factor ,
     					    X_active_flag		        => l_detail_balances.active_flag ,
                            X_mode                      =>  'R') ;


           g_rowid := NULL ;



           IGI_IAC_FA_DEPRN_PKG.Insert_Row(
                   x_rowid                => g_rowid,
                   x_book_type_code       => p_book_type_code,
                   x_asset_id             => p_asset_id,
                   x_period_counter       => g_prd_rec.period_counter,
                   x_adjustment_id        => l_retirement_adjustment_id,
                   x_distribution_id      => l_fa_deprn.distribution_id,
                   x_deprn_period         => l_fa_deprn.deprn_period,
                   x_deprn_ytd            => l_fa_deprn_ytd,
                   x_deprn_reserve        => l_fa_deprn.deprn_reserve,
                   x_active_flag          => l_fa_deprn.active_flag,
                   x_mode                 => 'R'
                                      );
       END IF ;   -- if active_flag is Null

     END LOOP ; -- g_detail_balances
     debug( g_state_level, l_path_name, 'end loop');

      OPEN  c_asset_balances(P_Asset_Id, P_Book_Type_Code, g_prd_rec.period_counter);

      FETCH c_asset_balances INTO l_asset_balances_rec ;

      IF c_asset_balances%NOTFOUND THEN
          CLOSE c_asset_balances ;

          OPEN c_previous_per(l_last_active_adj_id) ;
          FETCH c_previous_per INTO l_previous_per ;
          IF c_previous_per%NOTFOUND THEN
	    CLOSE c_previous_per;
            RAISE NO_DATA_FOUND ;
          END IF ;
          CLOSE c_previous_per ;

          OPEN c_asset_balances(P_Asset_Id, P_Book_Type_Code, l_previous_per ) ;
          FETCH c_asset_balances INTO l_asset_balances_rec ;
          IF    c_asset_balances%NOTFOUND THEN
	    CLOSE c_asset_balances;

	-- Begin Fix for Bug 5049536
	    SELECT max(period_counter)
	    INTO l_max_period_counter
            FROM   igi_iac_asset_balances
            WHERE  asset_id = P_Asset_Id
              AND    book_type_code = P_Book_Type_Code;

           OPEN c_asset_balances(P_Asset_Id, P_Book_Type_Code, l_max_period_counter) ;
           FETCH c_asset_balances INTO l_asset_balances_rec ;
           -- RAISE e_no_asset_bals ;

	--End Fix for Bug 5049536

          END IF ;

                    igi_iac_asset_balances_pkg.insert_row(
                        X_rowid                     => l_rowid ,
		    			X_asset_id		    => p_asset_id,
				    	X_book_type_code	=> p_book_type_code ,
    					X_period_counter	=> g_prd_rec.period_counter ,
	    				X_net_book_value	=> l_asset_balances.net_book_value ,
		    			X_adjusted_cost		=> l_asset_balances.adjusted_cost ,
			    		X_operating_acct	=> l_asset_balances.operating_acct ,
				    	X_reval_reserve		=> l_asset_balances.reval_reserve ,
                        X_deprn_amount		=> l_asset_balances.deprn_amount,
    					X_deprn_reserve		=> l_asset_balances.deprn_reserve ,
	    				X_backlog_deprn_reserve => l_asset_balances.backlog_deprn_reserve ,
		    			X_general_fund		=> l_asset_balances.general_fund ,
			    		X_last_reval_date	=> l_asset_balances_rec.last_reval_date ,
				    	X_current_reval_factor	=> l_asset_balances_rec.current_reval_factor,
                        X_cumulative_reval_factor => l_asset_balances_rec.cumulative_reval_factor,
                        X_mode                   => 'R') ;



      ELSE
                  igi_iac_asset_balances_pkg.update_row(
		    			X_asset_id		    => p_asset_id,
				    	X_book_type_code	=> p_book_type_code ,
    					X_period_counter	=> g_prd_rec.period_counter ,
	    				X_net_book_value	=> l_asset_balances.net_book_value ,
		    			X_adjusted_cost		=> l_asset_balances.adjusted_cost ,
			    		X_operating_acct	=> l_asset_balances.operating_acct ,
				    	X_reval_reserve		=> l_asset_balances.reval_reserve ,
                        X_deprn_amount		=> l_asset_balances.deprn_amount,
    					X_deprn_reserve		=> l_asset_balances.deprn_reserve ,
	    				X_backlog_deprn_reserve => l_asset_balances.backlog_deprn_reserve ,
		    			X_general_fund		=> l_asset_balances.general_fund ,
			    		X_last_reval_date	=> l_asset_balances_rec.last_reval_date ,
				    	X_current_reval_factor	=> l_asset_balances_rec.current_reval_factor,
                        X_cumulative_reval_factor => l_asset_balances_rec.cumulative_reval_factor,
                        X_mode                   => 'R') ;

  END IF;
  CLOSE c_asset_balances ;

  RETURN TRUE;

  EXCEPTION
  WHEN OTHERS  THEN
    debug( g_state_level,l_path_name,'Error in Processing Cost Retirement');
    FA_SRVR_MSG.add_sql_error(Calling_Fn  => g_calling_fn);
    RETURN FALSE ;
END cost_retirement;

FUNCTION Prior_Cost_Retirement (    P_Asset_Id                IN NUMBER ,
                                    P_Book_Type_Code          IN VARCHAR2 ,
                                    P_Retirement_Id           IN NUMBER ,
                                    P_retirement_type         IN VARCHAR2,
                                    p_retirement_factor       IN NUMBER ,
                                    p_retirement_period_type  IN VARCHAR2,
                                    P_prior_period            IN NUMBER,
                                    P_Current_period          IN NUMBER,
                                    P_Event_Id                IN NUMBER) --R12 uptake

RETURN BOOLEAN IS

    l_rowid                           ROWID;
    l_asset_balances                  igi_iac_asset_balances%ROWTYPE;
    l_asset_balances_rec              igi_iac_asset_balances%ROWTYPE;
    l_detail_balances                 igi_iac_det_balances%ROWTYPE;
    l_detail_balances_new             igi_iac_det_balances%ROWTYPE;
    l_detail_balances_total_old       igi_iac_det_balances%ROWTYPE;
    l_detail_balances_retire          igi_iac_det_balances%ROWTYPE;
    l_detail_balances_retire_unrnd    igi_iac_det_balances%ROWTYPE;
    l_detail_balances_rnd_tot         igi_iac_det_balances%ROWTYPE;
    l_fa_deprn                        igi_iac_fa_deprn%ROWTYPE;
    l_units_per_dist                  c_units_per_dist%ROWTYPE;
    l_cost_account_ccid               NUMBER ;
    l_acc_deprn_account_ccid          NUMBER ;
    l_reval_rsv_account_ccid          NUMBER ;
    l_backlog_account_ccid            NUMBER ;
    l_nbv_retired_account_ccid        NUMBER ;
    l_reval_rsv_ret_acct_ccid         NUMBER ;
    l_deprn_exp_account_ccid          NUMBER ;
    l_account_gen_fund_ccid           NUMBER;
    l_new_units                       NUMBER ;
    l_new_distribution                NUMBER ;
    l_units_before                    NUMBER ;
    l_units_after                     NUMBER ;
    l_ret                             BOOLEAN ;
    l_total_asset_units               NUMBER ;
    l_asset_units_count               NUMBER ;
    l_previous_per                    NUMBER ;
    l_prev_adjustment_id              igi_iac_transaction_headers.adjustment_id%TYPE ;
    l_last_active_adj_id              igi_iac_transaction_headers.adjustment_id%TYPE ;
    l_db_op_acct_ytd                  igi_iac_det_balances.operating_acct_ytd%TYPE;
    l_db_deprn_ytd                    igi_iac_det_balances.deprn_ytd%TYPE;
    l_fa_deprn_prd                    igi_iac_fa_deprn.deprn_period%TYPE;
    l_fa_tot_round_deprn_prd          igi_iac_fa_deprn.deprn_period%TYPE;
    l_fa_unround_deprn_prd            igi_iac_fa_deprn.deprn_period%TYPE;
    l_fa_total_old_acc_deprn          igi_iac_fa_deprn.deprn_reserve%TYPE;
    l_fa_retire_acc_deprn             igi_iac_fa_deprn.deprn_reserve%TYPE;
    l_fa_tot_round_acc_deprn          igi_iac_fa_deprn.deprn_reserve%TYPE;
    l_fa_unround_acc_deprn            igi_iac_fa_deprn.deprn_reserve%TYPE;
    l_fa_total_new_acc_deprn          igi_iac_fa_deprn.deprn_reserve%TYPE;
    l_fa_deprn_ytd                    igi_iac_fa_deprn.deprn_ytd%TYPE;
    l_fa_tot_round_deprn_ytd          igi_iac_fa_deprn.deprn_ytd%TYPE;
    l_fa_unround_deprn_ytd            igi_iac_fa_deprn.deprn_ytd%TYPE;
    l_fa_total_new_deprn_prd          igi_iac_fa_deprn.deprn_ytd%TYPE;
    l_fa_total_new_deprn_ytd          igi_iac_fa_deprn.deprn_ytd%TYPE;
    l_fa_total_old_deprn_prd          igi_iac_fa_deprn.deprn_ytd%TYPE;
    l_fa_total_old_deprn_ytd          igi_iac_fa_deprn.deprn_ytd%TYPE;
    l_fa_retire_deprn_prd             igi_iac_fa_deprn.deprn_ytd%TYPE;
    l_fa_retire_deprn_ytd             igi_iac_fa_deprn.deprn_ytd%TYPE;
    l_op_exp_ccid                     NUMBER;
    l_Transaction_Type_Code	igi_iac_transaction_headers.transaction_type_code%TYPE;
    l_Transaction_Id      igi_iac_transaction_headers.transaction_header_id%TYPE;
    l_Mass_Reference_ID	  igi_iac_transaction_headers.mass_reference_id%TYPE;
    l_Adjustment_Status   igi_iac_transaction_headers.adjustment_status%TYPE;
    l_adjustment_id_out  igi_iac_adjustments.adjustment_id%TYPE;
    l_retirement_adjustment_id        NUmber;
    l_path_name                      varchar2(200);
    l_check_revaluations             c_check_revaluations%ROWTYPE;
    l_all_occ_reval                  c_get_all_occ_reval%ROWTYPE;
    l_retire_amount                  Number;
    l_check_depreciations            c_check_depreciations%ROWTYPE;
    l_all_prd_reval                  c_get_all_prd_reval%ROWTYPE;
    l_op_exp_ccid                     NUMBER;

BEGIN

        l_path_name:=g_path_name ||'.Prior_Period_Cost_Retirement';


         /*  Initialize Asset total balance variables  */
         ------------------------
        l_asset_balances.Asset_id       :=P_Asset_Id ;
        l_asset_balances.book_type_code :=P_Book_Type_Code;
        l_asset_balances.period_counter :=P_Current_period;
        l_asset_balances.net_book_value :=0;
        l_asset_balances.adjusted_cost  :=0;
        l_asset_balances.operating_acct :=0;
        l_asset_balances.reval_reserve  :=0;
        l_asset_balances.deprn_amount   :=0;
        l_asset_balances.deprn_reserve  :=0;
        l_asset_balances.backlog_deprn_reserve:=0;
        l_asset_balances.general_fund   :=0;


        l_Transaction_Type_Code := NULL;
        l_Transaction_Id        := NULL;
        l_Mass_Reference_ID     := NULL;
        l_adjustment_id_out     := NULL;
        l_prev_adjustment_id    := NULL;
        l_Adjustment_Status     := NULL;
        l_retirement_adjustment_id :=NULL;

       debug(g_state_level,l_path_name,'Asset ID '||P_Asset_Id);
       -- get the latest tranaction for the asset id

       IF NOT (igi_iac_common_utils.get_latest_transaction(P_Book_Type_Code,
                                                           P_Asset_Id,
                                                           l_Transaction_Type_Code,
                                                           l_Transaction_Id,
                                                           l_Mass_Reference_ID ,
                                                           l_adjustment_id_out,
                                                           l_prev_adjustment_id,
                                                           l_Adjustment_Status )
                ) THEN
               igi_iac_debug_pkg.debug_other_string(g_error_level,l_path_name,'*** Error in fetching the latest transaction');
               RETURN FALSE;
       END IF;

       debug(g_state_level,l_path_name,'got latest transaction');
       l_last_active_adj_id := l_prev_adjustment_id ;
       debug( g_state_level,l_path_name,'prior_period'|| p_prior_period);
       debug( g_state_level,l_path_name,'current_period'||p_current_period);

       ---check for revauations if exits between the prior perod and current period
       -- Start revaluation
        OPEN c_check_revaluations(P_asset_id,p_book_type_code,
                                  p_prior_period,p_current_period);
        FETCH c_check_revaluations INTO l_check_revaluations;
        IF c_check_revaluations%FOUND THEN -- revlautions found in betweem
            l_path_name :=l_path_name ||'.Reval' ;

               --- create a new transaction header for Revlaution retirement
            l_rowid:=NULL;
            l_retirement_adjustment_id :=NULL;
            igi_iac_trans_headers_pkg.insert_row(
	                       	    X_rowid		            => l_rowid ,
                        		X_adjustment_id	        => l_retirement_adjustment_id ,
                        		X_transaction_header_id => g_retire_rec.detail_info.transaction_header_id_in,
                        		X_adjustment_id_out	    => NULL ,
                        		X_transaction_type_code => 'REVALUATION',
                        		X_transaction_date_entered => g_fa_trx.transaction_date_entered,
                        		X_mass_refrence_id	    => g_fa_trx.mass_reference_id ,
                        		X_transaction_sub_type	=> 'RETIREMENT',
                        		X_book_type_code	    => P_Book_Type_Code,
                        		X_asset_id		        => p_asset_id ,
                        		X_category_id		    => g_asset_category_id,
                        		X_adj_deprn_start_date	=> NULL,
                        		X_revaluation_type_flag => NULL,
                        		X_adjustment_status	    => 'COMPLETE' ,
                        		X_period_counter	    => P_Current_period,
                                X_mode                  =>'R',
                                X_event_id              => P_Event_Id) ;

            debug( g_state_level, l_path_name,'inserted trans_headers record');
          debug( g_state_level, l_path_name, 'new transaction Revalaution...'||l_retirement_adjustment_id );
            igi_iac_trans_headers_pkg.update_row(l_adjustment_id_out,
                                                 l_retirement_adjustment_id,
                                                 'R') ;

            debug( g_state_level,l_path_name,'updated old trans_headers record');
            debug( g_state_level,l_path_name,'Start of Revaluations');
            --get all adjustments for occasional revaluation between current period and
            -- retire period

             FOR l_detail_balances IN c_detail_balances(l_last_active_adj_id) LOOP

                OPEN c_fa_deprn( l_detail_balances.adjustment_id,
                                 l_detail_balances.distribution_id,
                                 l_detail_balances.period_counter);
                FETCH c_fa_deprn INTO l_fa_deprn;
                IF c_fa_deprn%NOTFOUND THEN
                     CLOSE c_fa_deprn;
                     RETURN FALSE;
                END IF;
                CLOSE c_fa_deprn;

                IF l_detail_balances.active_flag IS NULL THEN -- Active distributions
                 	   debug( g_state_level,l_path_name,'inside loop');

            	     debug( g_state_level,l_path_name,'Detail balances loop: active record dist id  '|| l_detail_balances.distribution_id);

                 /*  Create adjustment to reverse out retirement factor  */

                     l_detail_balances_retire.adjustment_cost        :=0 ;
                     l_detail_balances_retire.reval_reserve_cost     :=0 ;
                     l_detail_balances_retire.deprn_reserve          :=0 ;
                     l_detail_balances_retire.deprn_reserve_backlog  :=0 ;
                     l_detail_balances_retire.reval_reserve_net      :=0 ;
                     l_detail_balances_retire.deprn_period           :=0 ;
                     l_detail_balances_retire.general_fund_acc       :=0 ;
                     l_detail_balances_retire.general_fund_per       :=0 ;
                     l_detail_balances_retire.reval_reserve_gen_fund :=0 ;
                     l_detail_balances_retire.operating_acct_backlog :=0;
                     l_detail_balances_retire.operating_acct_cost    :=0;
                     l_detail_balances_retire.operating_acct_net     :=0;
                     l_detail_balances_retire.reval_reserve_backlog  :=0;
                     l_detail_balances_retire.deprn_ytd              :=0;

                     FOR l_all_occ_reval IN  c_get_all_occ_reval(p_asset_id,p_book_type_code,
                                                                 P_prior_period,
                                                                 p_current_period,
                                                                 l_detail_balances.distribution_id ) LOOP

                              l_retire_amount := l_all_occ_reval.amount * P_retirement_factor;
			      do_round(l_retire_amount,P_Book_Type_Code);
                              l_ret:= igi_iac_common_utils.iac_round(l_retire_amount,P_Book_Type_Code) ;
                              l_rowid := NULL ;
                              igi_iac_adjustments_pkg.insert_row(
		     		         	    X_rowid                 => l_rowid ,
                                    X_adjustment_id         => l_retirement_adjustment_id ,
                                    X_book_type_code		=> P_Book_Type_Code ,
                                    X_code_combination_id	=> l_all_occ_reval.code_combination_id,
                                    X_set_of_books_id		=> g_sob_id ,
                                    X_dr_cr_flag            => 'DR',
                                    X_amount               	=> l_retire_amount,
                                    X_adjustment_type      	=> l_all_occ_reval.adjustment_type,
                                    X_transfer_to_gl_flag  	=> 'Y',
                                    X_units_assigned		=> l_all_occ_reval.units_assigned ,
                                    X_asset_id		        => p_Asset_Id ,
                                    X_distribution_id      	=> l_detail_balances.distribution_id ,
                                    X_period_counter       	=> g_prd_rec.period_counter,
                                    X_adjustment_offset_type =>l_all_occ_reval.adjustment_offset_type,
                                    X_report_ccid        	=> l_all_occ_reval.report_ccid,
                                    X_mode                  => 'R',
                                    X_event_id              => P_Event_Id) ;

             	         debug( g_state_level,l_path_name,'adjustment type '|| l_all_occ_reval.adjustment_type);
             	         debug( g_state_level,l_path_name,'amount '         || l_retire_amount);
                         debug( g_state_level,l_path_name,'distribution  '  || l_detail_balances.distribution_id);

                         -- cost entries
                         IF l_all_occ_reval.adjustment_type = 'COST' THEN
                                l_detail_balances_retire.adjustment_cost:=l_detail_balances_retire.adjustment_cost + l_retire_amount;
                         END IF;
                         IF l_all_occ_reval.adjustment_type = 'COST' AND l_all_occ_reval.adjustment_offset_type='REVAL RESERVE'  THEN
                             l_detail_balances_retire.reval_reserve_cost:= l_detail_balances_retire.reval_reserve_cost + l_retire_amount;
                         END IF;
                         IF l_all_occ_reval.adjustment_type = 'BL RESERVE' AND l_all_occ_reval.adjustment_offset_type='REVAL RESERVE'  THEN
                             l_detail_balances_retire.reval_reserve_backlog  := l_detail_balances_retire.reval_reserve_backlog - l_retire_amount;
                         END IF;
                         IF l_all_occ_reval.adjustment_type = 'GENERAL FUND' THEN
                             l_detail_balances_retire.general_fund_acc       := l_detail_balances_retire.general_fund_acc - l_retire_amount;
                             l_detail_balances_retire.reval_reserve_gen_fund := l_detail_balances_retire.reval_reserve_gen_fund - l_retire_amount;
                         END IF;
                           IF l_all_occ_reval.adjustment_type = 'REVAL RESERVE' THEN
                             l_detail_balances_retire.reval_reserve_net      := l_detail_balances_retire.reval_reserve_net - l_retire_amount;
                           END IF;
                         IF l_all_occ_reval.adjustment_type = 'COST' AND l_all_occ_reval.adjustment_offset_type='OP EXPENSE'  THEN
                             l_detail_balances_retire.operating_acct_cost:=l_detail_balances_retire.operating_acct_cost + l_retire_amount;
                         END IF;
                          IF l_all_occ_reval.adjustment_type = 'BL RESERVE' AND l_all_occ_reval.adjustment_offset_type='OP EXPENSE'  THEN
                             l_detail_balances_retire.operating_acct_backlog :=l_detail_balances_retire.operating_acct_backlog - l_retire_amount;
                         END IF;
                         IF l_all_occ_reval.adjustment_type = 'OP EXPENSE' THEN
                             l_detail_balances_retire.operating_acct_net     :=l_detail_balances_retire.operating_acct_net - l_retire_amount;
                        END IF;
                            IF l_all_occ_reval.adjustment_type = 'RESERVE' THEN
                                 l_detail_balances_retire.deprn_reserve    :=   l_detail_balances_retire.deprn_reserve - l_retire_amount;
                       END IF;
                       IF l_all_occ_reval.adjustment_type = 'BL RESERVE' THEN
                             l_detail_balances_retire.deprn_reserve_backlog  := l_detail_balances_retire.deprn_reserve_backlog - l_retire_amount;
                       END IF;
                    END LOOP; -- adjustment reversal

			/* Calculate new totals  */
                     l_detail_balances.adjustment_cost        := l_detail_balances.adjustment_cost        + l_detail_balances_retire.adjustment_cost;
                     l_detail_balances.reval_reserve_cost     := l_detail_balances.reval_reserve_cost     + l_detail_balances_retire.reval_reserve_cost;
                     l_detail_balances.deprn_reserve          := l_detail_balances.deprn_reserve          + l_detail_balances_retire.deprn_reserve ;
                     l_detail_balances.deprn_reserve_backlog  := l_detail_balances.deprn_reserve_backlog  + l_detail_balances_retire.deprn_reserve_backlog ;
                     l_detail_balances.reval_reserve_net      := l_detail_balances.reval_reserve_net      + l_detail_balances_retire.reval_reserve_net ;
                     l_detail_balances.deprn_period           := l_detail_balances.deprn_period           + l_detail_balances_retire.deprn_period;
                     l_detail_balances.general_fund_acc       := l_detail_balances.general_fund_acc       + l_detail_balances_retire.general_fund_acc;
                     l_detail_balances.general_fund_per       := l_detail_balances.general_fund_per       + l_detail_balances_retire.general_fund_per;
                     l_detail_balances.reval_reserve_gen_fund := l_detail_balances.reval_reserve_gen_fund + l_detail_balances_retire.reval_reserve_gen_fund;
                     l_detail_balances.operating_acct_backlog := l_detail_balances.operating_acct_backlog  + l_detail_balances_retire.operating_acct_backlog;
                     l_detail_balances.operating_acct_cost    :=l_detail_balances.operating_acct_cost     + l_detail_balances_retire.operating_acct_cost;
                     l_detail_balances.operating_acct_net     :=l_detail_balances.operating_acct_net      + l_detail_balances_retire.operating_acct_net ;
                     l_detail_balances.reval_reserve_backlog  := l_detail_balances.reval_reserve_backlog  + l_detail_balances_retire.reval_reserve_backlog;
                     l_detail_balances.deprn_ytd              := l_detail_balances.deprn_ytd              + l_detail_balances_retire.deprn_ytd;

                    l_detail_balances.net_book_value := l_detail_balances.adjustment_cost - l_detail_balances.deprn_reserve -l_detail_balances.deprn_reserve_backlog  ;

                    l_rowid := NULL ;


                    igi_iac_det_balances_pkg.insert_row(
                       		X_rowid                     => l_rowid ,
			     		    X_adjustment_id		        => l_retirement_adjustment_id ,
    					    X_asset_id		            => P_Asset_Id ,
	    				    X_distribution_id	        => l_detail_balances.distribution_id ,
		    			    X_book_type_code	        => P_Book_Type_Code ,
			    		    X_period_counter	        => g_prd_rec.period_counter,
				    	    X_adjustment_cost	        => l_detail_balances.adjustment_cost ,
                            X_net_book_value	        => l_detail_balances.net_book_value,
        				    X_reval_reserve_cost	    => l_detail_balances.reval_reserve_cost,
		    			    X_reval_reserve_backlog     => l_detail_balances.reval_reserve_backlog,
			    		    X_reval_reserve_gen_fund    => l_detail_balances.reval_reserve_gen_fund,
				    	    X_reval_reserve_net	        => l_detail_balances.reval_reserve_net,
                            X_operating_acct_cost	    => l_detail_balances.operating_acct_cost,
    					    X_operating_acct_backlog    => l_detail_balances.operating_acct_backlog,
	    				    X_operating_acct_net	    => l_detail_balances.operating_acct_net,
 		    			    X_operating_acct_ytd	    => l_detail_balances.operating_acct_ytd,
			    		    X_deprn_period		        => l_detail_balances.deprn_period,
 				    	    X_deprn_ytd		            => l_detail_balances.deprn_ytd,
                            X_deprn_reserve		        => l_detail_balances.deprn_reserve,
    					    X_deprn_reserve_backlog	    => l_detail_balances.deprn_reserve_backlog,
	    				    X_general_fund_per	        => l_detail_balances.general_fund_per,
		    			    X_general_fund_acc	        => l_detail_balances.general_fund_acc,
 			    		    X_last_reval_date	        => l_detail_balances.last_reval_date ,
				    	    X_current_reval_factor	    => l_detail_balances.current_reval_factor ,
                            X_cumulative_reval_factor   => l_detail_balances.cumulative_reval_factor ,
     					    X_active_flag		        => l_detail_balances.active_flag,
                            X_mode                      =>  'R') ;

                            debug( g_state_level,l_path_name,'REVALUATION  REVERSAL');
                            debug( g_state_level,l_path_name,'X_adjustment_id		   => '||l_retirement_adjustment_id );
    					    debug( g_state_level,l_path_name,'X_asset_id		       =>'|| P_Asset_Id );
    	        			debug( g_state_level,l_path_name,'X_distribution_id	       =>'|| l_detail_balances.distribution_id );
    	        			debug( g_state_level,l_path_name,'X_book_type_code	       =>'|| P_Book_Type_Code );
    	        			debug( g_state_level,l_path_name,'X_period_counter	       =>'|| g_prd_rec.period_counter);
    	        			debug( g_state_level,l_path_name,'X_adjustment_cost	       =>'|| l_detail_balances.adjustment_cost);
    	        			debug( g_state_level,l_path_name,'X_net_book_value	       =>'|| l_detail_balances.net_book_value);
    	        			debug( g_state_level,l_path_name,'X_reval_reserve_cost	   =>'|| l_detail_balances.reval_reserve_cost);
    	        			debug( g_state_level,l_path_name,'X_reval_reserve_backlog  =>'|| l_detail_balances.reval_reserve_backlog);
    	        			debug( g_state_level,l_path_name,'X_reval_reserve_gen_fund =>'|| l_detail_balances.reval_reserve_gen_fund);
      	        			debug( g_state_level,l_path_name,'X_reval_reserve_net	   =>'|| l_detail_balances.reval_reserve_net);
                            debug( g_state_level,l_path_name,'X_operating_acct_cost	   =>'|| l_detail_balances.operating_acct_cost);
                            debug( g_state_level,l_path_name,'X_operating_acct_backlog =>'|| l_detail_balances.operating_acct_backlog);
                            debug( g_state_level,l_path_name,'X_operating_acct_net	   =>'|| l_detail_balances.operating_acct_net);
                            debug( g_state_level,l_path_name,'X_operating_acct_ytd	   =>'|| l_detail_balances.operating_acct_ytd);
                            debug( g_state_level,l_path_name,'X_deprn_period		   =>'|| l_detail_balances.deprn_period);
                            debug( g_state_level,l_path_name,'X_deprn_ytd		       =>'|| l_detail_balances.deprn_ytd);
                            debug( g_state_level,l_path_name,'X_deprn_reserve		   =>'|| l_detail_balances.deprn_reserve);
                            debug( g_state_level,l_path_name,'X_deprn_reserve_backlog  =>'|| l_detail_balances.deprn_reserve_backlog);
                            debug( g_state_level,l_path_name,'X_general_fund_per	   =>'|| l_detail_balances.general_fund_per);
                            debug( g_state_level,l_path_name,'X_general_fund_acc	   =>'|| l_detail_balances.general_fund_acc);
                            debug( g_state_level,l_path_name,'X_last_reval_date	       =>'|| l_detail_balances.last_reval_date );
                            debug( g_state_level,l_path_name,'X_current_reval_factor   =>'|| l_detail_balances.current_reval_factor );
                            debug( g_state_level,l_path_name,'X_cumulative_reval_factor=>'|| l_detail_balances.cumulative_reval_factor );
                            debug( g_state_level,l_path_name,'X_active_flag		       =>'|| l_detail_balances.active_flag);

         	                debug( g_state_level,l_path_name,'end insert det bals');
                            -- insert into igi_iac_fa_deprn with the reinstatement adjustment_id
                             l_rowid:=NULL;
                             IGI_IAC_FA_DEPRN_PKG.Insert_Row(
                              x_rowid                => l_rowid,
                              x_book_type_code       => p_book_type_code,
                              x_asset_id             => p_asset_id,
                              x_period_counter       => g_prd_rec.period_counter,
                              x_adjustment_id        => l_retirement_adjustment_id,
                              x_distribution_id      => l_fa_deprn.distribution_id,
                              x_deprn_period         => l_fa_deprn.deprn_period,
                              x_deprn_ytd            => l_fa_deprn.deprn_ytd,
                              x_deprn_reserve        => l_fa_deprn.deprn_reserve,
                              x_active_flag          => NULL,
                               x_mode                 => 'R');

       ELSE  -- Inactive distributions IF active_flag is not NULL.  i.e. following code for active_flag = 'N'

         	      debug( g_state_level,l_path_name,'Inactive distributions');
                  l_rowid := NULL ;
                  igi_iac_det_balances_pkg.insert_row(
                       		X_rowid                     => l_rowid ,
			     		    X_adjustment_id		        => l_retirement_adjustment_id ,
    					    X_asset_id		            => P_Asset_Id,
	    				    X_distribution_id	        => l_detail_balances.distribution_id ,
		    			    X_book_type_code	        => P_Book_Type_Code ,
			    		    X_period_counter	        => g_prd_rec.period_counter,
				    	    X_adjustment_cost	        => l_detail_balances.adjustment_cost ,
                            X_net_book_value	        => l_detail_balances.net_book_value,
        				    X_reval_reserve_cost	    => l_detail_balances.reval_reserve_cost,
		    			    X_reval_reserve_backlog     => l_detail_balances.reval_reserve_backlog,
			    		    X_reval_reserve_gen_fund    => l_detail_balances.reval_reserve_gen_fund,
				    	    X_reval_reserve_net	        => l_detail_balances.reval_reserve_net,
                            X_operating_acct_cost	    => l_detail_balances.operating_acct_cost,
    					    X_operating_acct_backlog    => l_detail_balances.operating_acct_backlog,
	    				    X_operating_acct_net	    => l_detail_balances.operating_acct_net,
 		    			    X_operating_acct_ytd	    => l_detail_balances.operating_acct_ytd,
			    		    X_deprn_period		        => l_detail_balances.deprn_period,
 				    	    X_deprn_ytd		            => l_detail_balances.deprn_ytd,
                            X_deprn_reserve		        => l_detail_balances.deprn_reserve,
    					    X_deprn_reserve_backlog	    => l_detail_balances.deprn_reserve_backlog,
	    				    X_general_fund_per	        => l_detail_balances.general_fund_per,
		    			    X_general_fund_acc	        => l_detail_balances.general_fund_acc,
 			    		    X_last_reval_date	        => l_detail_balances.last_reval_date ,
				    	    X_current_reval_factor	    => l_detail_balances.current_reval_factor ,
                            X_cumulative_reval_factor   => l_detail_balances.cumulative_reval_factor ,
     					    X_active_flag		        => l_detail_balances.active_flag ,
                            X_mode                      =>  'R') ;

                    l_rowid := NULL ;
                    IGI_IAC_FA_DEPRN_PKG.Insert_Row(
                           x_rowid                => g_rowid,
                           x_book_type_code       => p_book_type_code,
                           x_asset_id             => p_asset_id,
                           x_period_counter       => g_prd_rec.period_counter,
                           x_adjustment_id        => l_retirement_adjustment_id,
                           x_distribution_id      => l_fa_deprn.distribution_id,
                           x_deprn_period         => l_fa_deprn.deprn_period,
                           x_deprn_ytd            => l_fa_deprn.deprn_ytd,
                           x_deprn_reserve        => l_fa_deprn.deprn_reserve,
                           x_active_flag          => NULL,
                           x_mode                 => 'R'
                                      );
                END IF ;   -- if active_flag is not  Null

           END LOOP ; -- det balances
               debug( g_state_level,l_path_name,'End of Revaluations');
               l_adjustment_id_out     :=l_retirement_adjustment_id;
               l_last_active_adj_id    :=l_retirement_adjustment_id;

       ELSE  -- no revalautions
                debug( g_state_level,l_path_name,'No Revaluations');
                NULL;
        END IF; --end revaluaionts
        CLOSE C_check_revaluations;
       -- End revaluation

       -- start deprecaition reversal
        debug( g_state_level,l_path_name,'Start of Depreciation');
        OPEN c_check_depreciations(P_asset_id,p_book_type_code,
                                  p_prior_period,p_current_period);
        FETCH c_check_depreciations INTO l_check_depreciations;
        IF c_check_depreciations%FOUND THEN -- revlautions found in betweem
            l_path_name :=l_path_name ||'.Deprn'  ;
               --- create a new transaction header for Revlaution retirement
            l_rowid:=NULL;
            l_retirement_adjustment_id :=NULL;
            igi_iac_trans_headers_pkg.insert_row(
	                       	    X_rowid		            => l_rowid ,
                        		X_adjustment_id	        => l_retirement_adjustment_id ,
                        		X_transaction_header_id => g_retire_rec.detail_info.transaction_header_id_in,
                        		X_adjustment_id_out	    => NULL ,
                        		X_transaction_type_code => 'DEPRECIATION',
                        		X_transaction_date_entered => g_fa_trx.transaction_date_entered,
                        		X_mass_refrence_id	    => g_fa_trx.mass_reference_id ,
                        		X_transaction_sub_type	=> 'RETIREMENT',
                        		X_book_type_code	    => P_Book_Type_Code,
                        		X_asset_id		        => p_asset_id ,
                        		X_category_id		    => g_asset_category_id,
                        		X_adj_deprn_start_date	=> NULL,
                        		X_revaluation_type_flag => NULL,
                        		X_adjustment_status	    => 'COMPLETE' ,
                        		X_period_counter	    => P_Current_period,
                                X_mode                  =>'R',
                                X_event_id              => P_Event_Id) ;

            debug( g_state_level, l_path_name,'inserted trans_headers record');
            debug( g_state_level, l_path_name, 'new transaction Depreciation...'||l_retirement_adjustment_id );
            igi_iac_trans_headers_pkg.update_row(l_adjustment_id_out,
                                                 l_retirement_adjustment_id,
                                                 'R') ;
            --l_adjustment_id_out     :=l_retirement_adjustment_id;
            ---l_last_active_adj_id    :=l_retirement_adjustment_id;

            debug( g_state_level,l_path_name,'updated old trans_headers record');

            --get all adjustments for occasional revaluation between current period and
            -- retire period
             FOR l_detail_balances IN c_detail_balances(l_last_active_adj_id) LOOP

                OPEN c_fa_deprn( l_detail_balances.adjustment_id,
                                 l_detail_balances.distribution_id,
                                 l_detail_balances.period_counter);
                FETCH c_fa_deprn INTO l_fa_deprn;
                IF c_fa_deprn%NOTFOUND THEN
                     CLOSE c_fa_deprn;
                     RETURN FALSE;
                END IF;
                CLOSE c_fa_deprn;

                IF l_detail_balances.active_flag IS NULL THEN -- Active distributions
                 	   debug( g_state_level,l_path_name,'inside loop');

            	     debug( g_state_level,l_path_name,'Detail balances loop: active record dist id  '|| l_detail_balances.distribution_id);

                 /*  Create adjustment to reverse out retirement factor  */

                     l_detail_balances_retire.adjustment_cost        :=0 ;
                     l_detail_balances_retire.reval_reserve_cost     :=0 ;
                     l_detail_balances_retire.deprn_reserve          :=0 ;
                     l_detail_balances_retire.deprn_reserve_backlog  :=0 ;
                     l_detail_balances_retire.reval_reserve_net      :=0 ;
                     l_detail_balances_retire.deprn_period           :=0 ;
                     l_detail_balances_retire.general_fund_acc       :=0 ;
                     l_detail_balances_retire.general_fund_per       :=0 ;
                     l_detail_balances_retire.reval_reserve_gen_fund :=0 ;
                     l_detail_balances_retire.operating_acct_backlog :=0;
                     l_detail_balances_retire.operating_acct_cost    :=0;
                     l_detail_balances_retire.operating_acct_net     :=0;
                     l_detail_balances_retire.reval_reserve_backlog  :=0;
                     l_detail_balances_retire.deprn_ytd              :=0;

                     FOR l_all_prd_reval IN  c_get_all_prd_reval(p_asset_id,p_book_type_code,
                                                                 P_prior_period,
                                                                 p_current_period,
                                                                 l_detail_balances.distribution_id ) LOOP

                              l_retire_amount := l_all_prd_reval.amount * P_retirement_factor;
			      do_round(l_retire_amount,P_Book_Type_Code);
                              l_ret:= igi_iac_common_utils.iac_round(l_retire_amount,P_Book_Type_Code) ;
                              l_rowid := NULL ;
                              igi_iac_adjustments_pkg.insert_row(
		     		         	    X_rowid                 => l_rowid ,
                                    X_adjustment_id         => l_retirement_adjustment_id ,
                                    X_book_type_code		=> P_Book_Type_Code ,
                                    X_code_combination_id	=> l_all_prd_reval.code_combination_id,
                                    X_set_of_books_id		=> g_sob_id ,
                                    X_dr_cr_flag            => 'DR',
                                    X_amount               	=> l_retire_amount,
                                    X_adjustment_type      	=> l_all_prd_reval.adjustment_type,
                                    X_transfer_to_gl_flag  	=> 'Y',
                                    X_units_assigned		=> l_all_prd_reval.units_assigned ,
                                    X_asset_id		        => p_Asset_Id ,
                                    X_distribution_id      	=> l_detail_balances.distribution_id ,
                                    X_period_counter       	=> g_prd_rec.period_counter,
                                    X_adjustment_offset_type =>l_all_prd_reval.adjustment_offset_type,
                                    X_report_ccid        	=> l_all_prd_reval.report_ccid,
                                    X_mode                  => 'R',
                                    X_event_id              => P_Event_Id ) ;

             	         debug( g_state_level,l_path_name,'adjustment type '|| l_all_prd_reval.adjustment_type);
             	         debug( g_state_level,l_path_name,'amount '         || l_retire_amount );
                         debug( g_state_level,l_path_name,'distribution  '  || l_detail_balances.distribution_id);


                         -- cost entries
                         IF l_all_prd_reval.adjustment_type = 'COST' THEN
                                l_detail_balances_retire.adjustment_cost:=l_detail_balances_retire.adjustment_cost + l_retire_amount;
                         END IF;
                         IF l_all_prd_reval.adjustment_type = 'COST' AND l_all_occ_reval.adjustment_offset_type='REVAL RESERVE'  THEN
                             l_detail_balances_retire.reval_reserve_cost:= l_detail_balances_retire.reval_reserve_cost+ l_retire_amount;
                         END IF;
                         IF l_all_prd_reval.adjustment_type = 'BL RESERVE' AND l_all_occ_reval.adjustment_offset_type='REVAL RESERVE'  THEN
                             l_detail_balances_retire.reval_reserve_backlog  := l_detail_balances_retire.reval_reserve_backlog - l_retire_amount;
                         END IF;
                         IF l_all_prd_reval.adjustment_type = 'GENERAL FUND' THEN
                             l_detail_balances_retire.general_fund_acc       := l_detail_balances_retire.general_fund_acc - l_retire_amount;
                             l_detail_balances_retire.reval_reserve_gen_fund := l_detail_balances_retire.reval_reserve_gen_fund - l_retire_amount;
                         END IF;
                           IF l_all_prd_reval.adjustment_type = 'REVAL RESERVE' THEN
                             l_detail_balances_retire.reval_reserve_net      := l_detail_balances_retire.reval_reserve_net - l_retire_amount;
                           END IF;
                         IF l_all_prd_reval.adjustment_type = 'COST' AND l_all_occ_reval.adjustment_offset_type='OP EXPENSE'  THEN
                             l_detail_balances_retire.operating_acct_cost:=l_detail_balances_retire.operating_acct_cost + l_retire_amount;
                         END IF;
                          IF l_all_prd_reval.adjustment_type = 'BL RESERVE' AND l_all_occ_reval.adjustment_offset_type='OP EXPENSE'  THEN
                             l_detail_balances_retire.operating_acct_backlog :=l_detail_balances_retire.operating_acct_backlog - l_retire_amount;
                         END IF;
                         IF l_all_prd_reval.adjustment_type = 'OP EXPENSE' THEN
                             l_detail_balances_retire.operating_acct_net     :=l_detail_balances_retire.operating_acct_net - l_retire_amount;
                        END IF;
                            IF l_all_prd_reval.adjustment_type = 'RESERVE' THEN
                                 l_detail_balances_retire.deprn_reserve    :=   l_detail_balances_retire.deprn_reserve - l_retire_amount;
                       END IF;
                       IF l_all_prd_reval.adjustment_type = 'BL RESERVE' THEN
                             l_detail_balances_retire.deprn_reserve_backlog  := l_detail_balances_retire.deprn_reserve_backlog - l_retire_amount;
                       END IF;
                    END LOOP; -- adjustment reversal



                    /* Calculate new totals  */
                     l_detail_balances.adjustment_cost        := l_detail_balances.adjustment_cost        + l_detail_balances_retire.adjustment_cost;
                     l_detail_balances.reval_reserve_cost     := l_detail_balances.reval_reserve_cost     + l_detail_balances_retire.reval_reserve_cost;
                     l_detail_balances.deprn_reserve          := l_detail_balances.deprn_reserve          + l_detail_balances_retire.deprn_reserve ;
                     l_detail_balances.deprn_reserve_backlog  := l_detail_balances.deprn_reserve_backlog  + l_detail_balances_retire.deprn_reserve_backlog ;
                     l_detail_balances.reval_reserve_net      := l_detail_balances.reval_reserve_net      + l_detail_balances_retire.reval_reserve_net ;
                     l_detail_balances.deprn_period           := l_detail_balances.deprn_period           + l_detail_balances_retire.deprn_period;
                     l_detail_balances.general_fund_acc       := l_detail_balances.general_fund_acc       + l_detail_balances_retire.general_fund_acc;
                     l_detail_balances.general_fund_per       := l_detail_balances.general_fund_per       + l_detail_balances_retire.general_fund_per;
                     l_detail_balances.reval_reserve_gen_fund := l_detail_balances.reval_reserve_gen_fund + l_detail_balances_retire.reval_reserve_gen_fund;
                     l_detail_balances.operating_acct_backlog := l_detail_balances.operating_acct_backlog  + l_detail_balances_retire.operating_acct_backlog;
                     l_detail_balances.operating_acct_cost    :=l_detail_balances.operating_acct_cost     + l_detail_balances_retire.operating_acct_cost;
                     l_detail_balances.operating_acct_net     :=l_detail_balances.operating_acct_net      + l_detail_balances_retire.operating_acct_net ;
                     l_detail_balances.reval_reserve_backlog  := l_detail_balances.reval_reserve_backlog  + l_detail_balances_retire.reval_reserve_backlog;
                     l_detail_balances.deprn_ytd              := l_detail_balances.deprn_ytd              + l_detail_balances_retire.deprn_ytd;

                    l_detail_balances.net_book_value := l_detail_balances.adjustment_cost - l_detail_balances.deprn_reserve -l_detail_balances.deprn_reserve_backlog  ;

                    l_rowid := NULL ;


                    igi_iac_det_balances_pkg.insert_row(
                       		X_rowid                     => l_rowid ,
			     		    X_adjustment_id		        => l_retirement_adjustment_id ,
    					    X_asset_id		            => P_Asset_Id ,
	    				    X_distribution_id	        => l_detail_balances.distribution_id ,
		    			    X_book_type_code	        => P_Book_Type_Code ,
			    		    X_period_counter	        => g_prd_rec.period_counter,
				    	    X_adjustment_cost	        => l_detail_balances.adjustment_cost ,
                            X_net_book_value	        => l_detail_balances.net_book_value,
        				    X_reval_reserve_cost	    => l_detail_balances.reval_reserve_cost,
		    			    X_reval_reserve_backlog     => l_detail_balances.reval_reserve_backlog,
			    		    X_reval_reserve_gen_fund    => l_detail_balances.reval_reserve_gen_fund,
				    	    X_reval_reserve_net	        => l_detail_balances.reval_reserve_net,
                            X_operating_acct_cost	    => l_detail_balances.operating_acct_cost,
    					    X_operating_acct_backlog    => l_detail_balances.operating_acct_backlog,
	    				    X_operating_acct_net	    => l_detail_balances.operating_acct_net,
 		    			    X_operating_acct_ytd	    => l_detail_balances.operating_acct_ytd,
			    		    X_deprn_period		        => l_detail_balances.deprn_period,
 				    	    X_deprn_ytd		            => l_detail_balances.deprn_ytd,
                            X_deprn_reserve		        => l_detail_balances.deprn_reserve,
    					    X_deprn_reserve_backlog	    => l_detail_balances.deprn_reserve_backlog,
	    				    X_general_fund_per	        => l_detail_balances.general_fund_per,
		    			    X_general_fund_acc	        => l_detail_balances.general_fund_acc,
 			    		    X_last_reval_date	        => l_detail_balances.last_reval_date ,
				    	    X_current_reval_factor	    => l_detail_balances.current_reval_factor ,
                            X_cumulative_reval_factor   => l_detail_balances.cumulative_reval_factor ,
     					    X_active_flag		        => l_detail_balances.active_flag,
                            X_mode                      =>  'R') ;

                            debug( g_state_level,l_path_name,'DEPRECIATION REVERSAL');
                            debug( g_state_level,l_path_name,'X_adjustment_id		   => '||l_retirement_adjustment_id );
    					    debug( g_state_level,l_path_name,'X_asset_id		       =>'|| P_Asset_Id );
    	        			debug( g_state_level,l_path_name,'X_distribution_id	       =>'|| l_detail_balances.distribution_id );
    	        			debug( g_state_level,l_path_name,'X_book_type_code	       =>'|| P_Book_Type_Code );
    	        			debug( g_state_level,l_path_name,'X_period_counter	       =>'|| g_prd_rec.period_counter);
    	        			debug( g_state_level,l_path_name,'X_adjustment_cost	       =>'|| l_detail_balances.adjustment_cost);
    	        			debug( g_state_level,l_path_name,'X_net_book_value	       =>'|| l_detail_balances.net_book_value);
    	        			debug( g_state_level,l_path_name,'X_reval_reserve_cost	   =>'|| l_detail_balances.reval_reserve_cost);
    	        			debug( g_state_level,l_path_name,'X_reval_reserve_backlog  =>'|| l_detail_balances.reval_reserve_backlog);
    	        			debug( g_state_level,l_path_name,'X_reval_reserve_gen_fund =>'|| l_detail_balances.reval_reserve_gen_fund);
      	        			debug( g_state_level,l_path_name,'X_reval_reserve_net	   =>'|| l_detail_balances.reval_reserve_net);
                            debug( g_state_level,l_path_name,'X_operating_acct_cost	   =>'|| l_detail_balances.operating_acct_cost);
                            debug( g_state_level,l_path_name,'X_operating_acct_backlog =>'|| l_detail_balances.operating_acct_backlog);
                            debug( g_state_level,l_path_name,'X_operating_acct_net	   =>'|| l_detail_balances.operating_acct_net);
                            debug( g_state_level,l_path_name,'X_operating_acct_ytd	   =>'|| l_detail_balances.operating_acct_ytd);
                            debug( g_state_level,l_path_name,'X_deprn_period		   =>'|| l_detail_balances.deprn_period);
                            debug( g_state_level,l_path_name,'X_deprn_ytd		       =>'|| l_detail_balances.deprn_ytd);
                            debug( g_state_level,l_path_name,'X_deprn_reserve		   =>'|| l_detail_balances.deprn_reserve);
                            debug( g_state_level,l_path_name,'X_deprn_reserve_backlog  =>'|| l_detail_balances.deprn_reserve_backlog);
                            debug( g_state_level,l_path_name,'X_general_fund_per	   =>'|| l_detail_balances.general_fund_per);
                            debug( g_state_level,l_path_name,'X_general_fund_acc	   =>'|| l_detail_balances.general_fund_acc);
                            debug( g_state_level,l_path_name,'X_last_reval_date	       =>'|| l_detail_balances.last_reval_date );
                            debug( g_state_level,l_path_name,'X_current_reval_factor   =>'|| l_detail_balances.current_reval_factor );
                            debug( g_state_level,l_path_name,'X_cumulative_reval_factor=>'|| l_detail_balances.cumulative_reval_factor );
                            debug( g_state_level,l_path_name,'X_active_flag		       =>'|| l_detail_balances.active_flag);

         	   debug( g_state_level,l_path_name,'end insert det bals');
               -- insert into igi_iac_fa_deprn with the reinstatement adjustment_id
               l_rowid:=NULL;
               IGI_IAC_FA_DEPRN_PKG.Insert_Row(
                       x_rowid                => l_rowid,
                       x_book_type_code       => p_book_type_code,
                       x_asset_id             => p_asset_id,
                       x_period_counter       => g_prd_rec.period_counter,
                       x_adjustment_id        => l_retirement_adjustment_id,
                       x_distribution_id      => l_fa_deprn.distribution_id,
                       x_deprn_period         => l_fa_deprn.deprn_period,
                       x_deprn_ytd            => l_fa_deprn.deprn_ytd,
                       x_deprn_reserve        => l_fa_deprn.deprn_reserve,
                       x_active_flag          => NULL,
                       x_mode                 => 'R'
                                      );

       ELSE  -- Inactive distributions IF active_flag is not NULL.  i.e. following code for active_flag = 'N'

         	      debug( g_state_level,l_path_name,'Inactive distributions');
                  l_rowid := NULL ;
                  igi_iac_det_balances_pkg.insert_row(
                       		X_rowid                     => l_rowid ,
			     		    X_adjustment_id		        => l_retirement_adjustment_id ,
    					    X_asset_id		            => P_Asset_Id,
	    				    X_distribution_id	        => l_detail_balances.distribution_id ,
		    			    X_book_type_code	        => P_Book_Type_Code ,
			    		    X_period_counter	        => g_prd_rec.period_counter,
				    	    X_adjustment_cost	        => l_detail_balances.adjustment_cost ,
                            X_net_book_value	        => l_detail_balances.net_book_value,
        				    X_reval_reserve_cost	    => l_detail_balances.reval_reserve_cost,
		    			    X_reval_reserve_backlog     => l_detail_balances.reval_reserve_backlog,
			    		    X_reval_reserve_gen_fund    => l_detail_balances.reval_reserve_gen_fund,
				    	    X_reval_reserve_net	        => l_detail_balances.reval_reserve_net,
                            X_operating_acct_cost	    => l_detail_balances.operating_acct_cost,
    					    X_operating_acct_backlog    => l_detail_balances.operating_acct_backlog,
	    				    X_operating_acct_net	    => l_detail_balances.operating_acct_net,
 		    			    X_operating_acct_ytd	    => l_detail_balances.operating_acct_ytd,
			    		    X_deprn_period		        => l_detail_balances.deprn_period,
 				    	    X_deprn_ytd		            => l_detail_balances.deprn_ytd,
                            X_deprn_reserve		        => l_detail_balances.deprn_reserve,
    					    X_deprn_reserve_backlog	    => l_detail_balances.deprn_reserve_backlog,
	    				    X_general_fund_per	        => l_detail_balances.general_fund_per,
		    			    X_general_fund_acc	        => l_detail_balances.general_fund_acc,
 			    		    X_last_reval_date	        => l_detail_balances.last_reval_date ,
				    	    X_current_reval_factor	    => l_detail_balances.current_reval_factor ,
                            X_cumulative_reval_factor   => l_detail_balances.cumulative_reval_factor ,
     					    X_active_flag		        => l_detail_balances.active_flag ,
                            X_mode                      =>  'R') ;


                    l_rowid := NULL ;
                    IGI_IAC_FA_DEPRN_PKG.Insert_Row(
                           x_rowid                => g_rowid,
                           x_book_type_code       => p_book_type_code,
                           x_asset_id             => p_asset_id,
                           x_period_counter       => g_prd_rec.period_counter,
                           x_adjustment_id        => l_retirement_adjustment_id,
                           x_distribution_id      => l_fa_deprn.distribution_id,
                           x_deprn_period         => l_fa_deprn.deprn_period,
                           x_deprn_ytd            => l_fa_deprn.deprn_ytd,
                           x_deprn_reserve        => l_fa_deprn.deprn_reserve,
                           x_active_flag          => NULL,
                           x_mode                 => 'R'
                                      );
                END IF ;   -- if active_flag is not  Null

           END LOOP ; -- det balances
             debug( g_state_level,l_path_name,'End of Depreciation');
       ELSE  -- no deprecaitions
             debug( g_state_level,l_path_name,'No Depreciations');
             NULL;
        END IF; --end deprecaitions
        CLOSE C_check_depreciations;
       -- end reversal
       RETURN TRUE;
 EXCEPTION
  WHEN OTHERS  THEN
    debug( g_state_level,l_path_name,'Error in Processing Prior Cost Retirement');
    FA_SRVR_MSG.add_sql_error(Calling_Fn  => g_calling_fn);
    RETURN FALSE ;

END prior_cost_retirement;

FUNCTION Unit_Retirement (          P_Asset_Id                IN NUMBER ,
                                    P_Book_Type_Code          IN VARCHAR2 ,
                                    P_Retirement_Id           IN NUMBER ,
                                    P_retirement_type         IN VARCHAR2,
                                    p_retirement_period_type  IN VARCHAR2,
                                    P_prior_period            IN NUMBER,
                                    P_Current_period          IN NUMBER,
                                    P_Event_Id                IN NUMBER) --R12 uptake
RETURN BOOLEAN IS


    l_rowid                           ROWID;
    l_asset_balances                  igi_iac_asset_balances%ROWTYPE;
    l_asset_balances_rec              igi_iac_asset_balances%ROWTYPE;
    l_detail_balances                 igi_iac_det_balances%ROWTYPE;
    l_detail_balances_new             igi_iac_det_balances%ROWTYPE;
    l_detail_balances_total_old       igi_iac_det_balances%ROWTYPE;
    l_detail_balances_retire          igi_iac_det_balances%ROWTYPE;
    l_detail_balances_retire_unrnd    igi_iac_det_balances%ROWTYPE;
    l_detail_balances_rnd_tot         igi_iac_det_balances%ROWTYPE;
    l_fa_deprn                        igi_iac_fa_deprn%ROWTYPE;
    l_units_per_dist                  c_units_per_dist%ROWTYPE;
    l_cost_account_ccid               NUMBER ;
    l_acc_deprn_account_ccid          NUMBER ;
    l_reval_rsv_account_ccid          NUMBER ;
    l_backlog_account_ccid            NUMBER ;
    l_nbv_retired_account_ccid        NUMBER ;
    l_reval_rsv_ret_acct_ccid         NUMBER ;
    l_deprn_exp_account_ccid          NUMBER ;
    l_account_gen_fund_ccid           NUMBER;
    l_new_units                       NUMBER ;
    l_new_distribution                NUMBER ;
    l_units_before                    NUMBER ;
    l_units_after                     NUMBER ;
    l_ret                             BOOLEAN ;
    l_total_asset_units               NUMBER ;
    l_asset_units_count               NUMBER ;
    l_previous_per                    NUMBER ;
    l_prev_adjustment_id              igi_iac_transaction_headers.adjustment_id%TYPE ;
    l_last_active_adj_id              igi_iac_transaction_headers.adjustment_id%TYPE ;
    l_db_op_acct_ytd                  igi_iac_det_balances.operating_acct_ytd%TYPE;
    l_db_deprn_ytd                    igi_iac_det_balances.deprn_ytd%TYPE;
    l_fa_deprn_prd                    igi_iac_fa_deprn.deprn_period%TYPE;
    l_fa_tot_round_deprn_prd          igi_iac_fa_deprn.deprn_period%TYPE;
    l_fa_unround_deprn_prd            igi_iac_fa_deprn.deprn_period%TYPE;
    l_fa_total_old_acc_deprn          igi_iac_fa_deprn.deprn_reserve%TYPE;
    l_fa_retire_acc_deprn             igi_iac_fa_deprn.deprn_reserve%TYPE;
    l_fa_tot_round_acc_deprn          igi_iac_fa_deprn.deprn_reserve%TYPE;
    l_fa_unround_acc_deprn            igi_iac_fa_deprn.deprn_reserve%TYPE;
    l_fa_total_new_acc_deprn          igi_iac_fa_deprn.deprn_reserve%TYPE;
    l_fa_deprn_ytd                    igi_iac_fa_deprn.deprn_ytd%TYPE;
    l_fa_tot_round_deprn_ytd          igi_iac_fa_deprn.deprn_ytd%TYPE;
    l_fa_unround_deprn_ytd            igi_iac_fa_deprn.deprn_ytd%TYPE;
    l_fa_total_new_deprn_prd          igi_iac_fa_deprn.deprn_ytd%TYPE;
    l_fa_total_new_deprn_ytd          igi_iac_fa_deprn.deprn_ytd%TYPE;
    l_fa_total_old_deprn_prd          igi_iac_fa_deprn.deprn_ytd%TYPE;
    l_fa_total_old_deprn_ytd          igi_iac_fa_deprn.deprn_ytd%TYPE;
    l_fa_retire_deprn_prd             igi_iac_fa_deprn.deprn_ytd%TYPE;
    l_fa_retire_deprn_ytd             igi_iac_fa_deprn.deprn_ytd%TYPE;
    l_impact_fa_dist                  c_get_impacted_dist%ROWTYPE;
    l_new_fa_dist                     c_get_new_dist%ROWTYPE;
    l_retirement_factor               Number;
    l_op_exp_ccid                     Number;
    l_Transaction_Type_Code	         igi_iac_transaction_headers.transaction_type_code%TYPE;
    l_Transaction_Id                 igi_iac_transaction_headers.transaction_header_id%TYPE;
    l_Mass_Reference_ID	             igi_iac_transaction_headers.mass_reference_id%TYPE;
    l_Adjustment_Status              igi_iac_transaction_headers.adjustment_status%TYPE;
    l_adjustment_id_out              igi_iac_adjustments.adjustment_id%TYPE;
    l_retirement_adjustment_id       Number;
    l_path_name                      varchar2(200);
    l_detail_balances_prior          C_get_prior_dist%rowtype;
    l_detail_balances_latest         C_get_prior_dist%rowtype;
    l_max_period_counter             NUMBER;
BEGIN

        l_path_name:=g_path_name ||'.Unit_Retiremet';

         /*  Initialize Asset total balance variables  */
         ------------------------
        l_asset_balances.Asset_id       :=P_Asset_Id ;
        l_asset_balances.book_type_code :=P_Book_Type_Code;
        l_asset_balances.period_counter :=P_Current_period;
        l_asset_balances.net_book_value :=0;
        l_asset_balances.adjusted_cost  :=0;
        l_asset_balances.operating_acct :=0;
        l_asset_balances.reval_reserve  :=0;
        l_asset_balances.deprn_amount   :=0;
        l_asset_balances.deprn_reserve  :=0;
        l_asset_balances.backlog_deprn_reserve:=0;
        l_asset_balances.general_fund   :=0;
        l_retirement_factor             :=0;



        l_Transaction_Type_Code    := NULL;
        l_Transaction_Id           := NULL;
        l_Mass_Reference_ID        := NULL;
        l_adjustment_id_out        := NULL;
        l_prev_adjustment_id       := NULL;
        l_Adjustment_Status        := NULL;
        l_retirement_adjustment_id := NULL;

       debug(g_state_level,l_path_name,'Asset ID '||P_Asset_Id);
       -- get the latest tranaction for the asset id

       IF NOT (igi_iac_common_utils.get_latest_transaction(P_Book_Type_Code,
                                                           P_Asset_Id,
                                                           l_Transaction_Type_Code,
                                                           l_Transaction_Id,
                                                           l_Mass_Reference_ID ,
                                                           l_adjustment_id_out,
                                                           l_prev_adjustment_id,
                                                           l_Adjustment_Status )
                ) THEN
               igi_iac_debug_pkg.debug_other_string(g_error_level,l_path_name,'*** Error in fetching the latest transaction');
               RETURN FALSE;
       END IF;


       debug(g_state_level,g_path_name,'got latest transaction');
       l_last_active_adj_id := l_prev_adjustment_id ;
       debug( g_state_level,g_path_name,'not reval in preview');

       l_rowid:=NULL;
       l_retirement_adjustment_id := NULL;
       igi_iac_trans_headers_pkg.insert_row(
	                       	    X_rowid		            => l_rowid ,
                        		X_adjustment_id	        => l_retirement_adjustment_id ,
                        		X_transaction_header_id => g_retire_rec.detail_info.transaction_header_id_in,
                        		X_adjustment_id_out	    => NULL ,
                        		X_transaction_type_code => g_ret_type_long,
                        		X_transaction_date_entered => g_fa_trx.transaction_date_entered,
                        		X_mass_refrence_id	    => g_fa_trx.mass_reference_id ,
                        		X_transaction_sub_type	=> SUBSTR(g_retirement_type,1,1),
                        		X_book_type_code	    => P_Book_Type_Code,
                        		X_asset_id		        => p_asset_id ,
                        		X_category_id		    => g_asset_category_id,
                        		X_adj_deprn_start_date	=> NULL,
                        		X_revaluation_type_flag => NULL,
                        		X_adjustment_status	    => 'COMPLETE' ,
                        		X_period_counter	    => P_Current_period,
                                X_mode                  =>'R',
                                X_event_id              => P_Event_Id) ;
          debug( g_state_level, l_path_name,'inserted trans_headers record');

          igi_iac_trans_headers_pkg.update_row(l_adjustment_id_out,
                                               l_retirement_adjustment_id,
                                              'R') ;

          debug( g_state_level,l_path_name,'updated old trans_headers record');
          debug( g_state_level,l_path_name,'Start loop');


         FOR l_detail_balances IN c_detail_balances(l_last_active_adj_id) LOOP

        -- since the equivalent row in igi_iac_fa_deprn has to handled in
           -- the same manner, retrieving the row for simultaneous processing
           OPEN c_fa_deprn( l_detail_balances.adjustment_id,
                            l_detail_balances.distribution_id,
                            l_detail_balances.period_counter);
           FETCH c_fa_deprn INTO l_fa_deprn;
           IF c_fa_deprn%NOTFOUND THEN
               CLOSE c_fa_deprn;
               RETURN FALSE;
           END IF;
          CLOSE c_fa_deprn;

           OPEN  c_units_per_dist(P_Asset_Id, P_Book_Type_Code, l_detail_balances.distribution_id) ;
         	        debug( g_state_level, l_path_name,'opened c_units_per_dist');
           FETCH c_units_per_dist INTO l_units_per_dist ;
           IF    c_units_per_dist%NOTFOUND THEN
		   CLOSE c_units_per_dist;
                   debug( g_state_level,l_path_name,'units per dist not found');
                   RAISE NO_DATA_FOUND;
            END IF ;
           CLOSE c_units_per_dist ;



          IF l_detail_balances.active_flag IS NULL THEN -- Active distributions

             -- find the impacted distribution because of the partial unit retirement
             OPEN c_get_impacted_dist(P_Asset_Id,P_Retirement_Id,l_detail_balances.distribution_id);
             FETCH c_get_impacted_dist INTO l_impact_fa_dist;

             IF c_get_impacted_dist%FOUND THEN -- impacted by partial nit retirement
                CLOSE c_get_impacted_dist;
             -- distribtion impacted by partial unkit retirement



        	 debug( g_state_level,l_path_name,'inside loop');

             l_detail_balances_rnd_tot.adjustment_cost        :=0 ;
             l_detail_balances_rnd_tot.reval_reserve_cost     :=0 ;
             l_detail_balances_rnd_tot.deprn_reserve          :=0 ;
             l_detail_balances_rnd_tot.deprn_reserve_backlog  :=0 ;
             l_detail_balances_rnd_tot.reval_reserve_net      :=0 ;
             l_detail_balances_rnd_tot.deprn_period           :=0 ;
             l_detail_balances_rnd_tot.general_fund_acc       :=0 ;
             l_detail_balances_rnd_tot.general_fund_per       :=0 ;
             l_detail_balances_rnd_tot.reval_reserve_gen_fund :=0 ;
             l_detail_balances_rnd_tot.operating_acct_backlog :=0;
             l_detail_balances_rnd_tot.operating_acct_cost    :=0;
             l_detail_balances_rnd_tot.operating_acct_net     :=0;
             l_detail_balances_rnd_tot.reval_reserve_backlog  :=0;
             l_detail_balances_rnd_tot.deprn_ytd              :=0;


     	     debug( g_state_level,l_path_name,'Detail balances loop: active record dist id  '|| l_detail_balances.distribution_id);


             -- get the impacted new distribution create for the retire distribution
             l_retirement_factor := 1;
             IF l_impact_fa_dist.transaction_units <> l_impact_fa_dist.units_assigned THEN

                 OPEN  c_get_new_dist(P_Asset_Id,P_Retirement_Id,
                                      l_impact_fa_dist.code_combination_id,
                                      ABS(l_impact_fa_dist.units_assigned + l_impact_fa_dist.transaction_units),
                                      l_impact_fa_dist.location_id,
                                      NVL(l_impact_fa_dist.assigned_to,-1));
             	 FETCH C_get_new_dist INTO l_new_fa_dist;
                 IF C_get_new_dist%FOUND THEN
                    l_retirement_factor := - NVL(l_impact_fa_dist.transaction_units,0)/ l_impact_fa_dist.units_assigned;
                    l_units_per_dist.units_assigned :=l_new_fa_dist.units_assigned;
                 END IF;
                 CLOSE C_get_new_dist;
             END IF;


             IF  l_retirement_factor <> 1 THEN

         	     debug( g_state_level,l_path_name,'got units per dist');
                 l_detail_balances_total_old  := l_detail_balances;

                 l_fa_total_old_acc_deprn  := l_fa_deprn.deprn_reserve;

                 /* Calculate retirement amounts   */

                     IF p_prior_period IS NULL THEN

                      l_detail_balances_retire.adjustment_cost        := l_detail_balances.adjustment_cost* l_retirement_factor ;
		      do_round(l_detail_balances_retire.adjustment_cost,P_Book_Type_Code);
                      l_detail_balances_retire.reval_reserve_cost     := l_detail_balances.reval_reserve_cost* l_retirement_factor ;
		      do_round(l_detail_balances_retire.reval_reserve_cost,P_Book_Type_Code);
                      l_detail_balances_retire.deprn_reserve          := l_detail_balances.deprn_reserve * l_retirement_factor ;
		      do_round(l_detail_balances_retire.deprn_reserve,P_Book_Type_Code);
                      l_detail_balances_retire.deprn_reserve_backlog  := l_detail_balances.deprn_reserve_backlog * l_retirement_factor ;
		      do_round(l_detail_balances_retire.deprn_reserve_backlog,P_Book_Type_Code);
                      l_detail_balances_retire.reval_reserve_net      := l_detail_balances.reval_reserve_net  * l_retirement_factor ;
		      do_round(l_detail_balances_retire.reval_reserve_net ,P_Book_Type_Code);
                      l_detail_balances_retire.deprn_period           := l_detail_balances.deprn_period * (1 - l_retirement_factor) ;
		      do_round(l_detail_balances_retire.deprn_period,P_Book_Type_Code);
                      l_detail_balances_retire.general_fund_acc       := l_detail_balances.general_fund_acc * l_retirement_factor;
		      do_round(l_detail_balances_retire.general_fund_acc,P_Book_Type_Code);
                      l_detail_balances_retire.general_fund_per       := l_detail_balances.general_fund_per * l_retirement_factor;
		      do_round(l_detail_balances_retire.general_fund_per,P_Book_Type_Code);
                      l_detail_balances_retire.reval_reserve_gen_fund := l_detail_balances.reval_reserve_gen_fund  * l_retirement_factor;
		      do_round(l_detail_balances_retire.reval_reserve_gen_fund,P_Book_Type_Code);
                      l_detail_balances_retire.operating_acct_backlog :=l_detail_balances.operating_acct_backlog * l_retirement_factor;
		      do_round(l_detail_balances_retire.operating_acct_backlog,P_Book_Type_Code);
                      l_detail_balances_retire.operating_acct_cost    :=l_detail_balances.operating_acct_cost * l_retirement_factor;
		      do_round(l_detail_balances_retire.operating_acct_cost,P_Book_Type_Code);
                      l_detail_balances_retire.operating_acct_net     :=l_detail_balances.operating_acct_net * l_retirement_factor;
		      do_round(l_detail_balances_retire.operating_acct_net,P_Book_Type_Code);
                      l_detail_balances_retire.reval_reserve_backlog  := l_detail_balances.reval_reserve_backlog * l_retirement_factor ;
		      do_round(l_detail_balances_retire.reval_reserve_backlog,P_Book_Type_Code);
                      l_detail_balances_retire.deprn_ytd              := l_detail_balances.deprn_ytd  * l_retirement_factor;
		      do_round(l_detail_balances_retire.deprn_ytd,P_Book_Type_Code);

                   ELSE
                     -- get the prior record for the distribution
                     debug( g_state_level,l_path_name,'Prior period unit processing');
                     OPEN C_get_prior_dist(p_asset_id,p_book_type_code,l_detail_balances.distribution_id,p_prior_period);
                     FETCH c_get_prior_dist INTO l_detail_balances_prior;
		     CLOSE c_get_prior_dist;



                        l_detail_balances_retire.adjustment_cost        := l_detail_balances_prior.adjustment_cost* l_retirement_factor ;
			do_round(l_detail_balances_retire.adjustment_cost,P_Book_Type_Code);
                        l_detail_balances_retire.reval_reserve_cost     := l_detail_balances_prior.reval_reserve_cost* l_retirement_factor ;
			do_round(l_detail_balances_retire.reval_reserve_cost,P_Book_Type_Code);
                        l_detail_balances_retire.deprn_reserve          := l_detail_balances_prior.deprn_reserve * l_retirement_factor ;
			do_round(l_detail_balances_retire.deprn_reserve,P_Book_Type_Code);
                        l_detail_balances_retire.deprn_reserve_backlog  := l_detail_balances_prior.deprn_reserve_backlog * l_retirement_factor ;
			do_round(l_detail_balances_retire.deprn_reserve_backlog,P_Book_Type_Code);
                        l_detail_balances_retire.reval_reserve_net      := l_detail_balances_prior.reval_reserve_net  * l_retirement_factor ;
			do_round(l_detail_balances_retire.reval_reserve_net,P_Book_Type_Code);
                        l_detail_balances_retire.deprn_period           := l_detail_balances.deprn_period * (1 - l_retirement_factor) ;
			do_round(l_detail_balances_retire.deprn_period,P_Book_Type_Code);
                        l_detail_balances_retire.general_fund_acc       := l_detail_balances_prior.general_fund_acc * l_retirement_factor;
			do_round(l_detail_balances_retire.general_fund_acc,P_Book_Type_Code);
                        l_detail_balances_retire.general_fund_per       := l_detail_balances_prior.general_fund_per * l_retirement_factor;
			do_round(l_detail_balances_retire.general_fund_per,P_Book_Type_Code);
                        l_detail_balances_retire.reval_reserve_gen_fund := l_detail_balances_prior.reval_reserve_gen_fund  * l_retirement_factor;
			do_round(l_detail_balances_retire.reval_reserve_gen_fund,P_Book_Type_Code);
                        l_detail_balances_retire.operating_acct_backlog := l_detail_balances_prior.operating_acct_backlog * l_retirement_factor;
			do_round(l_detail_balances_retire.operating_acct_backlog,P_Book_Type_Code);
                        l_detail_balances_retire.operating_acct_cost    := l_detail_balances_prior.operating_acct_cost * l_retirement_factor;
			do_round(l_detail_balances_retire.operating_acct_cost,P_Book_Type_Code);
                        l_detail_balances_retire.operating_acct_net     := l_detail_balances_prior.operating_acct_net * l_retirement_factor;
			do_round(l_detail_balances_retire.operating_acct_net,P_Book_Type_Code);
                        l_detail_balances_retire.reval_reserve_backlog  := l_detail_balances_prior.reval_reserve_backlog * l_retirement_factor ;
			do_round(l_detail_balances_retire.reval_reserve_backlog,P_Book_Type_Code);
                        l_detail_balances_retire.deprn_ytd              := l_detail_balances.deprn_ytd  * l_retirement_factor;
			do_round(l_detail_balances_retire.deprn_ytd,P_Book_Type_Code);
                       debug( g_state_level,l_path_name,'End Prior period unit processing');
                  END IF;

                 l_fa_retire_acc_deprn   := l_fa_total_old_acc_deprn * l_retirement_factor;
		 do_round(l_fa_retire_acc_deprn,P_Book_Type_Code);
                 l_fa_retire_deprn_prd   := l_fa_deprn.deprn_period * (1 - l_retirement_factor);
		 do_round(l_fa_retire_deprn_prd,P_Book_Type_Code);
                 l_fa_retire_deprn_ytd   := l_fa_deprn.deprn_ytd    * l_retirement_factor;
		 do_round(l_fa_retire_deprn_ytd,P_Book_Type_Code);

                 /*  Do roundings  */

                 l_asset_units_count      := l_asset_units_count + l_units_per_dist.units_assigned ;

                 IF (l_asset_units_count = g_total_asset_units) and (p_prior_period is null) THEN

                    l_detail_balances_retire.adjustment_cost        := l_detail_balances.adjustment_cost        + l_detail_balances_rnd_tot.adjustment_cost;
                    l_detail_balances_retire.reval_reserve_cost     := l_detail_balances.reval_reserve_cost     + l_detail_balances_rnd_tot.reval_reserve_cost;
                    l_detail_balances_retire.deprn_reserve          := l_detail_balances.deprn_reserve          + l_detail_balances_rnd_tot.deprn_reserve ;
                    l_detail_balances_retire.deprn_reserve_backlog  := l_detail_balances.deprn_reserve_backlog  + l_detail_balances_rnd_tot.deprn_reserve_backlog ;
                    l_detail_balances_retire.reval_reserve_net      := l_detail_balances.reval_reserve_net      + l_detail_balances_rnd_tot.reval_reserve_net ;
                    l_detail_balances_retire.deprn_period           := l_detail_balances.deprn_period           + l_detail_balances_rnd_tot.deprn_period;
                    l_detail_balances_retire.general_fund_acc       := l_detail_balances.general_fund_acc       + l_detail_balances_rnd_tot.general_fund_acc;
                    l_detail_balances_retire.general_fund_per       := l_detail_balances.general_fund_per       + l_detail_balances_rnd_tot.general_fund_per;
                    l_detail_balances_retire.reval_reserve_gen_fund := l_detail_balances.reval_reserve_gen_fund + l_detail_balances_rnd_tot.reval_reserve_gen_fund;
                    l_detail_balances_retire.operating_acct_backlog :=l_detail_balances.operating_acct_backlog  + l_detail_balances_rnd_tot.operating_acct_backlog ;
                    l_detail_balances_retire.operating_acct_cost    :=l_detail_balances.operating_acct_cost     + l_detail_balances_rnd_tot.operating_acct_cost;
                    l_detail_balances_retire.operating_acct_net     :=l_detail_balances.operating_acct_net      + l_detail_balances_rnd_tot.operating_acct_net ;
                    l_detail_balances_retire.reval_reserve_backlog  := l_detail_balances.reval_reserve_backlog  + l_detail_balances_rnd_tot.reval_reserve_backlog;
                    l_detail_balances_retire.deprn_ytd              := l_detail_balances.deprn_ytd              + l_detail_balances_rnd_tot.deprn_ytd;


                    l_fa_retire_acc_deprn := l_fa_retire_acc_deprn + l_fa_tot_round_acc_deprn;
                    l_fa_retire_deprn_prd := l_fa_retire_deprn_prd + l_fa_tot_round_deprn_prd;
                    l_fa_retire_deprn_ytd := l_fa_retire_deprn_ytd +  l_fa_tot_round_deprn_ytd;

                 END IF ;


                 l_detail_balances_retire_unrnd.adjustment_cost        :=l_detail_balances_retire.adjustment_cost ;
                 l_detail_balances_retire_unrnd.reval_reserve_cost     :=l_detail_balances_retire.reval_reserve_cost  ;
                 l_detail_balances_retire_unrnd.deprn_reserve          := l_detail_balances_retire.deprn_reserve;
                 l_detail_balances_retire_unrnd.deprn_reserve_backlog  := l_detail_balances_retire.deprn_reserve_backlog;
                 l_detail_balances_retire_unrnd.reval_reserve_net      := l_detail_balances_retire.reval_reserve_net ;
                 l_detail_balances_retire_unrnd.deprn_period           := l_detail_balances_retire.deprn_period;
                 l_detail_balances_retire_unrnd.general_fund_acc       := l_detail_balances_retire.general_fund_acc;
                 l_detail_balances_retire_unrnd.general_fund_per       := l_detail_balances_retire.general_fund_per;
                 l_detail_balances_retire_unrnd.reval_reserve_gen_fund := l_detail_balances_retire.reval_reserve_gen_fund;
                 l_detail_balances_retire_unrnd.operating_acct_backlog := l_detail_balances_retire.operating_acct_backlog;
                 l_detail_balances_retire_unrnd.operating_acct_cost    := l_detail_balances_retire.operating_acct_cost;
                 l_detail_balances_retire_unrnd.operating_acct_net     := l_detail_balances_retire.operating_acct_net;
                 l_detail_balances_retire_unrnd.reval_reserve_backlog  := l_detail_balances_retire.reval_reserve_backlog;
                 l_detail_balances_retire_unrnd.deprn_ytd              := l_detail_balances_retire.deprn_ytd;



                 l_fa_unround_acc_deprn := l_fa_retire_acc_deprn;
                 l_fa_unround_deprn_prd := l_fa_retire_deprn_prd;
                 l_fa_unround_deprn_ytd := l_fa_retire_deprn_ytd;


                 l_ret:= igi_iac_common_utils.iac_round(l_detail_balances_retire.adjustment_cost,P_Book_Type_Code) ;
                 l_ret:= igi_iac_common_utils.iac_round(l_detail_balances_retire.reval_reserve_cost,P_Book_Type_Code)  ;
                 l_ret:= igi_iac_common_utils.iac_round(l_detail_balances_retire.deprn_reserve,P_Book_Type_Code) ;
                 l_ret:= igi_iac_common_utils.iac_round(l_detail_balances_retire.deprn_reserve_backlog,P_Book_Type_Code)  ;
                 l_ret:= igi_iac_common_utils.iac_round(l_detail_balances_retire.reval_reserve_net,P_Book_Type_Code) ;
                 l_ret:= igi_iac_common_utils.iac_round(l_detail_balances_retire.deprn_period,P_Book_Type_Code)      ;
                 l_ret:= igi_iac_common_utils.iac_round(l_detail_balances_retire.general_fund_acc,P_Book_Type_Code)  ;
                 l_ret:= igi_iac_common_utils.iac_round(l_detail_balances_retire.general_fund_per,P_Book_Type_Code)  ;
                 l_ret:= igi_iac_common_utils.iac_round(l_detail_balances_retire.reval_reserve_gen_fund,P_Book_Type_Code) ;
                 l_ret:= igi_iac_common_utils.iac_round(l_detail_balances_retire.operating_acct_backlog,P_Book_Type_Code) ;
                 l_ret:= igi_iac_common_utils.iac_round(l_detail_balances_retire.operating_acct_cost,P_Book_Type_Code)    ;
                 l_ret:= igi_iac_common_utils.iac_round(l_detail_balances_retire.operating_acct_net,P_Book_Type_Code)     ;
                 l_ret:= igi_iac_common_utils.iac_round(l_detail_balances_retire.reval_reserve_backlog,P_Book_Type_Code)  ;
                 l_ret:= igi_iac_common_utils.iac_round(l_detail_balances_retire.deprn_ytd,P_Book_Type_Code)          ;

                  l_ret:= igi_iac_common_utils.iac_round(l_fa_retire_acc_deprn,P_Book_Type_Code)          ;
                  l_ret:= igi_iac_common_utils.iac_round(l_fa_retire_deprn_prd,P_Book_Type_Code)          ;
                  l_ret:= igi_iac_common_utils.iac_round(l_fa_retire_deprn_ytd,P_Book_Type_Code)          ;

                 l_detail_balances_rnd_tot.adjustment_cost:= l_detail_balances_rnd_tot.adjustment_cost;

                 l_detail_balances_rnd_tot.adjustment_cost        := l_detail_balances_rnd_tot.adjustment_cost +
                 (l_detail_balances_retire_unrnd.adjustment_cost - l_detail_balances_retire.adjustment_cost);
                 l_detail_balances_rnd_tot.reval_reserve_cost     := l_detail_balances_rnd_tot.reval_reserve_cost +
                 (l_detail_balances_retire_unrnd.reval_reserve_cost - l_detail_balances_retire.reval_reserve_cost);
                 l_detail_balances_rnd_tot.deprn_reserve          := l_detail_balances_rnd_tot.deprn_reserve +
                 (l_detail_balances_retire_unrnd.deprn_reserve - l_detail_balances_retire.deprn_reserve) ;
                 l_detail_balances_rnd_tot.deprn_reserve_backlog  := l_detail_balances_rnd_tot.deprn_reserve_backlog +
                 (l_detail_balances_retire_unrnd.deprn_reserve_backlog - l_detail_balances_retire.deprn_reserve_backlog) ;
                 l_detail_balances_rnd_tot.reval_reserve_net      := l_detail_balances_rnd_tot.reval_reserve_net +
                 (l_detail_balances_retire_unrnd.reval_reserve_net - l_detail_balances_retire.reval_reserve_net);
                 l_detail_balances_rnd_tot.deprn_period           := l_detail_balances_rnd_tot.deprn_period +
                 (l_detail_balances_retire_unrnd.deprn_period - l_detail_balances_retire.deprn_period);
                 l_detail_balances_rnd_tot.general_fund_acc       := l_detail_balances_rnd_tot.general_fund_acc +
                 (l_detail_balances_retire_unrnd.general_fund_acc - l_detail_balances_retire.general_fund_acc);
                 l_detail_balances_rnd_tot.general_fund_per       := l_detail_balances_rnd_tot.general_fund_per +
                 (l_detail_balances_retire_unrnd.general_fund_per- l_detail_balances_retire.general_fund_per);
                 l_detail_balances_rnd_tot.reval_reserve_gen_fund := l_detail_balances_rnd_tot.reval_reserve_gen_fund +
                 (l_detail_balances_retire_unrnd.reval_reserve_gen_fund - l_detail_balances_retire.reval_reserve_gen_fund);
                 l_detail_balances_rnd_tot.operating_acct_backlog :=l_detail_balances_rnd_tot.operating_acct_backlog +
                 (l_detail_balances_retire_unrnd.operating_acct_backlog - l_detail_balances_retire.operating_acct_backlog) ;
                 l_detail_balances_rnd_tot.operating_acct_cost    :=l_detail_balances_rnd_tot.operating_acct_cost +
                 (l_detail_balances_retire_unrnd.operating_acct_cost - l_detail_balances_retire.operating_acct_cost);
                 l_detail_balances_rnd_tot.operating_acct_net     :=l_detail_balances_rnd_tot.operating_acct_net+
                 (l_detail_balances_retire_unrnd.operating_acct_net - l_detail_balances_retire.operating_acct_net) ;
                 l_detail_balances_rnd_tot.reval_reserve_backlog  := l_detail_balances_rnd_tot.reval_reserve_backlog +
                 (l_detail_balances_retire_unrnd.reval_reserve_backlog - l_detail_balances_retire.reval_reserve_backlog);
                 l_detail_balances_rnd_tot.deprn_ytd              := l_detail_balances_rnd_tot.deprn_ytd +
                 (l_detail_balances_retire_unrnd.deprn_ytd - l_detail_balances_retire.deprn_ytd);


                 l_fa_tot_round_acc_deprn   := l_fa_tot_round_acc_deprn   + l_fa_unround_acc_deprn   - l_fa_retire_acc_deprn ;
                 l_fa_tot_round_deprn_prd   := l_fa_tot_round_deprn_prd   + l_fa_unround_deprn_prd   - l_fa_retire_deprn_prd ;
                 l_fa_tot_round_deprn_ytd   := l_fa_tot_round_deprn_ytd   + l_fa_unround_deprn_ytd   - l_fa_retire_deprn_ytd ;


         	     debug( g_state_level,l_path_name,'done roundings');

                 /* Calculate new totals  */
                l_detail_balances_new.adjustment_cost        := l_detail_balances.adjustment_cost        - l_detail_balances_retire.adjustment_cost;
                l_detail_balances_new.reval_reserve_cost     := l_detail_balances.reval_reserve_cost     - l_detail_balances_retire.reval_reserve_cost;
                l_detail_balances_new.deprn_reserve          := l_detail_balances.deprn_reserve          - l_detail_balances_retire.deprn_reserve ;
                l_detail_balances_new.deprn_reserve_backlog  := l_detail_balances.deprn_reserve_backlog  - l_detail_balances_retire.deprn_reserve_backlog ;
                l_detail_balances_new.reval_reserve_net      := l_detail_balances.reval_reserve_net      - l_detail_balances_retire.reval_reserve_net ;
                l_detail_balances_new.deprn_period           := l_detail_balances.deprn_period           - l_detail_balances_retire.deprn_period;
                l_detail_balances_new.general_fund_acc       := l_detail_balances.general_fund_acc       - l_detail_balances_retire.general_fund_acc;
                l_detail_balances_new.general_fund_per       := l_detail_balances.general_fund_per       - l_detail_balances_retire.general_fund_per;
                l_detail_balances_new.reval_reserve_gen_fund := l_detail_balances.reval_reserve_gen_fund - l_detail_balances_retire.reval_reserve_gen_fund;
                l_detail_balances_new.operating_acct_backlog :=l_detail_balances.operating_acct_backlog  - l_detail_balances_retire.operating_acct_backlog;
                l_detail_balances_new.operating_acct_cost    :=l_detail_balances.operating_acct_cost     - l_detail_balances_retire.operating_acct_cost;
                l_detail_balances_new.operating_acct_net     :=l_detail_balances.operating_acct_net      - l_detail_balances_retire.operating_acct_net ;
                l_detail_balances_new.reval_reserve_backlog  := l_detail_balances.reval_reserve_backlog  - l_detail_balances_retire.reval_reserve_backlog;
                l_detail_balances_new.deprn_ytd              := l_detail_balances.deprn_ytd              - l_detail_balances_retire.deprn_ytd;

                l_detail_balances_new.net_book_value := l_detail_balances_new.adjustment_cost - l_detail_balances_new.deprn_reserve -l_detail_balances_new.deprn_reserve_backlog  ;


                l_fa_total_new_acc_deprn   := l_fa_total_old_acc_deprn  - l_fa_retire_acc_deprn ;
                l_fa_total_new_deprn_prd   := l_fa_deprn.deprn_period   - l_fa_retire_deprn_prd ;
                l_fa_total_new_deprn_ytd   := l_fa_deprn.deprn_ytd      - l_fa_retire_deprn_ytd ;

              --asset total;
              l_asset_balances.net_book_value :=l_asset_balances.net_book_value+l_detail_balances_new.net_book_value;
              l_asset_balances.adjusted_cost  :=l_asset_balances.adjusted_cost +l_detail_balances_new.adjustment_cost;
              l_asset_balances.operating_acct :=l_asset_balances.operating_acct+ l_detail_balances_new.operating_acct_net;
              l_asset_balances.reval_reserve  :=l_asset_balances.reval_reserve +l_detail_balances_new.reval_reserve_net;
              l_asset_balances.deprn_amount   :=l_asset_balances.deprn_amount  +l_detail_balances_new.deprn_period;
              l_asset_balances.deprn_reserve  :=l_asset_balances.deprn_reserve +l_detail_balances_new.deprn_reserve;
              l_asset_balances.backlog_deprn_reserve:=l_asset_balances.backlog_deprn_reserve+l_detail_balances_new.deprn_reserve_backlog;
              l_asset_balances.general_fund   :=l_asset_balances.general_fund +l_detail_balances_new.general_fund_acc;

           END IF; -- Retirement factor <> 1 new distributions created in partial unit retirement

	     IF p_prior_period IS NOT NULL AND l_retirement_factor <> 1 THEN

                l_detail_balances_latest:=l_detail_balances ;
                l_detail_balances       := l_detail_balances_prior;

              END IF;

             /*  Create adjustment to reverse out NOCOPY old balances  */
             IF NOT (igi_iac_common_utils.get_account_ccid(P_Book_Type_Code,P_Asset_Id,l_detail_balances.distribution_id,
                                                       'ASSET_COST_ACCT',g_retire_rec.detail_info.transaction_header_id_in,
                                                       'RETIREMENT',l_cost_account_ccid
                                                       )) THEN
                    RAISE e_no_account_ccid ;
             END IF ;

             debug( g_state_level,l_path_name,'done cost get acct ccid');
             l_rowid := NULL ;
             debug( g_state_level, l_path_name,'done cost adjustment');
         	 debug( g_state_level, l_path_name,'dist id: '||l_detail_balances.distribution_id);
             l_acc_deprn_account_ccid := NULL;
             IF NOT (igi_iac_common_utils.get_account_ccid(P_Book_Type_Code,P_Asset_Id,l_detail_balances.distribution_id,
                                                       'DEPRN_RESERVE_ACCT',g_retire_rec.detail_info.transaction_header_id_in,
                                                       'RETIREMENT',l_acc_deprn_account_ccid
                                                       )) THEN
                    RAISE e_no_account_ccid ;
             END IF ;
     	    debug( g_state_level,l_path_name,'done deprn rsv ccid');
    	    debug( g_state_level,l_path_name, '*' ||l_acc_deprn_account_ccid || '*');
            IF NOT (igi_iac_common_utils.get_account_ccid(P_Book_Type_Code,P_Asset_Id,l_detail_balances.distribution_id,
                                                       'REVAL_RESERVE_ACCT',g_retire_rec.detail_info.transaction_header_id_in,
                                                       'RETIREMENT',l_reval_rsv_account_ccid
                                                       )) THEN
             RAISE e_no_account_ccid ;
          END IF ;
     	 debug( g_state_level,l_path_name,'done reval rsv ccid');

         IF NOT (igi_iac_common_utils.get_account_ccid(P_Book_Type_Code,P_Asset_Id,l_detail_balances.distribution_id,
                                                       'BACKLOG_DEPRN_RSV_ACCT',g_retire_rec.detail_info.transaction_header_id_in,
                                                       'RETIREMENT',l_backlog_account_ccid
                                                       )) THEN
            RAISE e_no_account_ccid ;
         END IF ;
     	 debug( g_state_level,l_path_name,'done backlog ccid');

        /*  Create new adjustments for retirement part        */

        IF ((l_detail_balances.adjustment_cost-l_detail_balances.deprn_reserve<>0) OR (l_detail_balances.deprn_reserve_backlog <>0)) THEN
                 IF NOT (igi_iac_common_utils.get_account_ccid(P_Book_Type_Code,P_Asset_Id,l_detail_balances.distribution_id,
                                                       'NBV_RETIRED_GAIN_ACCT',g_retire_rec.detail_info.transaction_header_id_in,
                                                       'RETIREMENT',l_nbv_retired_account_ccid
                                                           )) THEN
                RAISE e_no_account_ccid ;
             END IF ;
         	 debug( g_state_level,l_path_name,'done nbv ret ccid');
             l_rowid := NULL ;

             igi_iac_adjustments_pkg.insert_row(
		     		    	    X_rowid                 => l_rowid ,
                                X_adjustment_id         => l_retirement_adjustment_id ,
                                X_book_type_code		=> P_Book_Type_Code ,
                                X_code_combination_id	=> l_nbv_retired_account_ccid,
                                X_set_of_books_id		=> g_sob_id ,
                                X_dr_cr_flag            => 'DR' ,
                                X_amount               	=> l_detail_balances.adjustment_cost-l_detail_balances.deprn_reserve,
                                X_adjustment_type      	=> 'NBV RETIRED',
                                X_transfer_to_gl_flag  	=> 'Y' ,
                                X_units_assigned		=> l_units_per_dist.units_assigned ,
                                X_asset_id		        => P_Asset_Id ,
                                X_distribution_id      	=> l_detail_balances.distribution_id ,
                                X_period_counter       	=> g_prd_rec.period_counter,
                                X_adjustment_offset_type => NULL,
                                X_report_ccid        	=>   NULL,
                                X_mode                  => 'R',
                                X_event_id              => P_Event_Id ) ;

         	 debug( g_state_level,l_path_name,'done nbv ret insert');

             l_rowid := NULL ;

             igi_iac_adjustments_pkg.insert_row(
		     		    	    X_rowid                 => l_rowid ,
                                X_adjustment_id         => l_retirement_adjustment_id ,
                                X_book_type_code		=> P_Book_Type_Code ,
                                X_code_combination_id	=> l_nbv_retired_account_ccid,
                                X_set_of_books_id		=> g_sob_id ,
                                X_dr_cr_flag            => 'CR' ,
                                X_amount               	=> l_detail_balances.deprn_reserve_backlog,
                                X_adjustment_type      	=> 'NBV RETIRED',
                                X_transfer_to_gl_flag  	=> 'Y' ,
                                X_units_assigned		=> l_units_per_dist.units_assigned ,
                                X_asset_id		        => P_Asset_Id ,
                                X_distribution_id      	=> l_detail_balances.distribution_id ,
                                X_period_counter       	=> g_prd_rec.period_counter,
                                X_adjustment_offset_type => NULL,
                                X_report_ccid        	=>  NULL,
                                X_mode                  => 'R',
                                X_event_id              => P_Event_Id ) ;

         	 debug( g_state_level,l_path_name, 'done 2nd nbv ret insert');
         END IF;


         IF l_detail_balances.reval_reserve_net <> 0 THEN
                IF NOT (igi_iac_common_utils.get_account_ccid(P_Book_Type_Code,P_Asset_Id,l_detail_balances.distribution_id,
                                                       'REVAL_RESERVE_RETIRED_ACCT',g_retire_rec.detail_info.transaction_header_id_in,
                                                       'RETIREMENT',l_reval_rsv_ret_acct_ccid
                                                       )) THEN
                RAISE e_no_account_ccid ;
            END IF ;
     	    debug( g_state_level,l_path_name,'done reval rsv ret ccid');
            l_rowid := NULL ;
            igi_iac_adjustments_pkg.insert_row(
		     		    	    X_rowid                 => l_rowid ,
                                X_adjustment_id         => l_retirement_adjustment_id ,
                                X_book_type_code		=> P_Book_Type_Code ,
                                X_code_combination_id	=> l_reval_rsv_ret_acct_ccid,
                                X_set_of_books_id		=> g_sob_id ,
                                X_dr_cr_flag            => 'CR' ,
                                X_amount               	=> l_detail_balances.reval_reserve_net,
                                X_adjustment_type      	=> 'REVAL RSV RET',
                                X_transfer_to_gl_flag  	=> 'Y' ,
                                X_units_assigned		=> l_units_per_dist.units_assigned ,
                                X_asset_id		        => P_Asset_Id ,
                                X_distribution_id      	=> l_detail_balances.distribution_id ,
                                X_period_counter       	=> g_prd_rec.period_counter,
                                X_adjustment_offset_type => NULL,
                                X_report_ccid        	=>  NULL,
                                X_mode                  => 'R',
                                X_event_id              => P_Event_Id ) ;

         	 debug( g_state_level,l_path_name,'done reval rsv ret insert');
         END IF;

         /*  Create adjustment for new balances   */
     	 debug( g_state_level,l_path_name,'start new balances');
         l_rowid := NULL ;
         igi_iac_adjustments_pkg.insert_row(
		     		    	    X_rowid                 => l_rowid ,
                                X_adjustment_id         => l_retirement_adjustment_id ,
                                X_book_type_code		=> P_Book_Type_Code ,
                                X_code_combination_id	=> l_cost_account_ccid,
                                X_set_of_books_id		=> g_sob_id ,
                                X_dr_cr_flag            => 'CR' ,
                                X_amount               	=> l_detail_balances.adjustment_cost,
                                X_adjustment_type      	=> 'COST',
                                X_transfer_to_gl_flag  	=> 'Y' ,
                                X_units_assigned		=> l_units_per_dist.units_assigned ,
                                X_asset_id		        => P_Asset_Id ,
                                X_distribution_id      	=> l_detail_balances.distribution_id ,
                                X_period_counter       	=> g_prd_rec.period_counter,
                                X_adjustment_offset_type => NULL,
                                X_report_ccid        	=>  NULL,
                                X_mode                  => 'R',
                                X_event_id              => P_Event_Id ) ;



     	     debug( g_state_level,l_path_name,'done new cost');
             IF l_detail_balances.deprn_reserve <> 0 THEN

                l_rowid := NULL ;
                 igi_iac_adjustments_pkg.insert_row(
		     		    	    X_rowid                 => l_rowid ,
                                X_adjustment_id         => l_retirement_adjustment_id ,
                                X_book_type_code		=> P_Book_Type_Code ,
                                X_code_combination_id	=> l_acc_deprn_account_ccid,
                                X_set_of_books_id		=> g_sob_id ,
                                X_dr_cr_flag            => 'DR' ,
                                X_amount               	=> l_detail_balances.deprn_reserve,
                                X_adjustment_type      	=> 'RESERVE',
                                X_transfer_to_gl_flag  	=> 'Y' ,
                                X_units_assigned		=> l_units_per_dist.units_assigned ,
                                X_asset_id		        => P_Asset_Id ,
                                X_distribution_id      	=> l_detail_balances.distribution_id ,
                                X_period_counter       	=> g_prd_rec.period_counter,
                                X_adjustment_offset_type => NULL,
                                X_report_ccid        	=>  NULL,
                                X_mode                  => 'R',
                                X_event_id              => P_Event_Id ) ;

            END IF;

            IF l_detail_balances.operating_acct_backlog <> 0 THEN

               IF NOT (igi_iac_common_utils.get_account_ccid(P_Book_Type_Code,P_Asset_Id,l_detail_balances.distribution_id,
                                                       'OPERATING_EXPENSE_ACCT',g_retire_rec.detail_info.transaction_header_id_in,
                                                       'RETIREMENT',l_op_exp_ccid
                                                       )) THEN
                       RAISE e_no_account_ccid ;
                END IF ;

                 l_rowid := NULL ;
                 igi_iac_adjustments_pkg.insert_row(
		     		    	    X_rowid                 => l_rowid ,
                                X_adjustment_id         => l_retirement_adjustment_id ,
                                X_book_type_code		=> P_Book_Type_Code ,
                                X_code_combination_id	=> l_backlog_account_ccid,
                                X_set_of_books_id		=> g_sob_id ,
                                X_dr_cr_flag            => 'DR' ,
                                X_amount               	=> l_detail_balances.operating_acct_backlog,
                                X_adjustment_type      	=> 'BL RESERVE',
                                X_transfer_to_gl_flag  	=> 'Y' ,
                                X_units_assigned		=> l_units_per_dist.units_assigned ,
                                X_asset_id		        => P_Asset_Id ,
                                X_distribution_id      	=> l_detail_balances.distribution_id ,
                                X_period_counter       	=> g_prd_rec.period_counter,
                                X_adjustment_offset_type => 'OP EXPENSE',
                                X_report_ccid        	=> l_op_exp_ccid,
                                X_mode                  => 'R',
                                X_event_id              => P_Event_Id ) ;



         	   debug( g_state_level,l_path_name,'done BL reserve for OP ');
           END IF;

           IF l_detail_balances.reval_reserve_backlog <> 0 THEN

             l_rowid := NULL ;
             igi_iac_adjustments_pkg.insert_row(
		     		    	    X_rowid                 => l_rowid ,
                                X_adjustment_id         => l_retirement_adjustment_id ,
                                X_book_type_code		=> P_Book_Type_Code ,
                                X_code_combination_id	=> l_backlog_account_ccid,
                                X_set_of_books_id		=> g_sob_id ,
                                X_dr_cr_flag            => 'DR' ,
                                X_amount               	=> l_detail_balances.reval_reserve_backlog,
                                X_adjustment_type      	=> 'BL RESERVE',
                                X_transfer_to_gl_flag  	=> 'Y' ,
                                X_units_assigned		=> l_units_per_dist.units_assigned ,
                                X_asset_id		        => P_Asset_Id ,
                                X_distribution_id      	=> l_detail_balances.distribution_id ,
                                X_period_counter       	=> g_prd_rec.period_counter,
                                X_adjustment_offset_type => 'REVAL RESERVE',
                                X_report_ccid        	=>  l_reval_rsv_account_ccid,
                                X_mode                  => 'R',
                                X_event_id              => P_Event_Id   ) ;



         	   debug( g_state_level,l_path_name,'done BL reserve for OP ');
           END IF;

           IF l_detail_balances.reval_reserve_net<> 0 THEN

                l_rowid := NULL ;
               igi_iac_adjustments_pkg.insert_row(
		     		    	    X_rowid                 => l_rowid ,
                                X_adjustment_id         => l_retirement_adjustment_id ,
                                X_book_type_code		=> P_Book_Type_Code ,
                                X_code_combination_id	=> l_reval_rsv_account_ccid,
                                X_set_of_books_id		=> g_sob_id ,
                                X_dr_cr_flag            => 'DR' ,
                                X_amount               	=> l_detail_balances.reval_reserve_net,
                                X_adjustment_type      	=> 'REVAL RESERVE',
                                X_transfer_to_gl_flag  	=> 'Y' ,
                                X_units_assigned		=> l_units_per_dist.units_assigned ,
                                X_asset_id		        => P_Asset_Id ,
                                X_distribution_id      	=> l_detail_balances.distribution_id ,
                                X_period_counter       	=> g_prd_rec.period_counter,
                                X_adjustment_offset_type => NULL,
                                X_report_ccid        	=>  NULL,
                                X_mode                  => 'R',
                                X_event_id              => P_Event_Id   ) ;

               debug( g_state_level,l_path_name,'done  reval rsv');

            END IF;
     	   debug( g_state_level,l_path_name,'end new balances');


           IF p_prior_period IS NOT NULL AND l_retirement_factor <> 1 THEN
                    l_detail_balances:=l_detail_balances_latest;
           END IF;

           /*  Insert new detail balance record for this distribution   */
         IF (g_is_first_period) THEN
           l_db_op_acct_ytd := 0;
           l_db_deprn_ytd   := 0;
         ELSE
           l_db_op_acct_ytd := l_detail_balances.operating_acct_ytd;
           l_db_deprn_ytd   := l_detail_balances.deprn_ytd;
         END IF;

           	 debug( g_state_level,l_path_name,'start insert det bal');

            IF l_retirement_factor = 1 THEN
                l_detail_balances.deprn_ytd:=0;
                l_fa_deprn.deprn_ytd :=0;
            ELSE
                l_detail_balances.deprn_ytd:=l_detail_balances.deprn_ytd *(1-l_retirement_factor);
		do_round(l_detail_balances.deprn_ytd,P_Book_Type_Code);
                l_ret:= igi_iac_common_utils.iac_round(l_detail_balances.deprn_ytd,P_Book_Type_Code);
                l_fa_deprn.deprn_ytd:=l_fa_deprn.deprn_ytd *(1-l_retirement_factor);
		do_round(l_fa_deprn.deprn_ytd,P_Book_Type_Code);
                l_ret:= igi_iac_common_utils.iac_round(l_fa_deprn.deprn_ytd,P_Book_Type_Code);
            END IF;

             l_rowid := NULL ;

              igi_iac_det_balances_pkg.insert_row(
                       		X_rowid                     => l_rowid ,
			     		    X_adjustment_id		        => l_retirement_adjustment_id ,
    					    X_asset_id		            => P_Asset_Id ,
	    				    X_distribution_id	        => l_detail_balances.distribution_id ,
		    			    X_book_type_code	        => P_Book_Type_Code ,
			    		    X_period_counter	        => g_prd_rec.period_counter,
				    	    X_adjustment_cost	        => 0,
                           		    X_net_book_value	        => 0,
        				    X_reval_reserve_cost	    => 0,
		    			    X_reval_reserve_backlog     => 0,
			    		    X_reval_reserve_gen_fund    => 0,
				    	    X_reval_reserve_net	        => 0,
                           		    X_operating_acct_cost	    => 0,
    					    X_operating_acct_backlog    => 0,
	    				    X_operating_acct_net	    => 0,
 		    			    X_operating_acct_ytd	    => 0,
			    		    X_deprn_period		        => 0,
 				    	    X_deprn_ytd		            => l_detail_balances.deprn_ytd,
                            		    X_deprn_reserve		        => 0,
    					    X_deprn_reserve_backlog	    => 0,
	    				    X_general_fund_per	        => 0,
		    			    X_general_fund_acc	        => 0,
 			    		    X_last_reval_date	        => l_detail_balances.last_reval_date ,
				    	    X_current_reval_factor	    => l_detail_balances.current_reval_factor ,
		                            X_cumulative_reval_factor   => l_detail_balances.cumulative_reval_factor ,
     					    X_active_flag		        => 'N',
                		            X_mode                      =>  'R') ;



     	   debug( g_state_level,l_path_name,'end insert det bals');
           debug( g_state_level,l_path_name,'CURRENT PERIOD -- inactive');
	   debug( g_state_level,l_path_name,'X_adjustment_id		   => '||l_retirement_adjustment_id );
    	   debug( g_state_level,l_path_name,'X_asset_id		       =>'|| P_Asset_Id );
    	   debug( g_state_level,l_path_name,'X_distribution_id	       =>'|| l_detail_balances.distribution_id );
    	   debug( g_state_level,l_path_name,'X_book_type_code	       =>'|| P_Book_Type_Code );
    	   debug( g_state_level,l_path_name,'X_period_counter	       =>'|| g_prd_rec.period_counter);
    	   debug( g_state_level,l_path_name,'X_deprn_ytd		       =>'|| l_detail_balances_new.deprn_ytd);
           debug( g_state_level,l_path_name,'X_active_flag		       =>'|| 'N');


           IF (g_is_first_period) THEN
               l_fa_deprn.deprn_ytd   := 0;
           ELSE
               l_fa_deprn_ytd   := l_fa_deprn.deprn_ytd;
           END IF;
           -- insert into igi_iac_fa_deprn with the reinstatement adjustment_id

             l_rowid := NULL ;
               IGI_IAC_FA_DEPRN_PKG.Insert_Row(
                   x_rowid                => g_rowid,
                   x_book_type_code       => p_book_type_code,
                   x_asset_id             => p_asset_id,
                   x_period_counter       => g_prd_rec.period_counter,
                   x_adjustment_id        => l_retirement_adjustment_id,
                   x_distribution_id      => l_fa_deprn.distribution_id,
                   x_deprn_period         => 0,
                   x_deprn_ytd            => l_fa_deprn.deprn_ytd,
                   x_deprn_reserve        => 0,
                   x_active_flag          => 'N',
                   x_mode                 => 'R');

           IF l_retirement_factor <> 1 THEN -- for new distribution created

                    --Create balances and adjustments  for new distriution create in partial retirement
                    l_cost_account_ccid:=NULL;
                    IF NOT (igi_iac_common_utils.get_account_ccid(P_Book_Type_Code,P_Asset_Id,l_new_fa_dist.distribution_id,
                                                       'ASSET_COST_ACCT',g_retire_rec.detail_info.transaction_header_id_in,
                                                       'RETIREMENT',l_cost_account_ccid
                                                       )) THEN
                                RAISE e_no_account_ccid ;
                     END IF ;

                     debug( g_state_level,l_path_name,'done cost get acct ccid for new dist');
                     l_rowid := NULL ;
                     debug( g_state_level, l_path_name,'done cost adjustment for new dist');

                     l_acc_deprn_account_ccid := NULL;

                     IF NOT (igi_iac_common_utils.get_account_ccid(P_Book_Type_Code,P_Asset_Id,l_new_fa_dist.distribution_id,
                                                       'DEPRN_RESERVE_ACCT',g_retire_rec.detail_info.transaction_header_id_in,
                                                       'RETIREMENT',l_acc_deprn_account_ccid
                                                       )) THEN
                            RAISE e_no_account_ccid ;
                     END IF ;
             	    debug( g_state_level,l_path_name,'done deprn rsv ccid for new dist');
    	            debug( g_state_level,l_path_name, '*' ||l_acc_deprn_account_ccid || '*');
                    IF NOT (igi_iac_common_utils.get_account_ccid(P_Book_Type_Code,P_Asset_Id,l_new_fa_dist.distribution_id,
                                                       'REVAL_RESERVE_ACCT',g_retire_rec.detail_info.transaction_header_id_in,
                                                       'RETIREMENT',l_reval_rsv_account_ccid
                                                           )) THEN
                     RAISE e_no_account_ccid ;
                  END IF ;
     	          debug( g_state_level,l_path_name,'done reval rsv ccid for new dist');
                  IF NOT (igi_iac_common_utils.get_account_ccid(P_Book_Type_Code,P_Asset_Id,l_new_fa_dist.distribution_id,
                                                       'BACKLOG_DEPRN_RSV_ACCT',g_retire_rec.detail_info.transaction_header_id_in,
                                                       'RETIREMENT',l_backlog_account_ccid
                                                       )) THEN
                       RAISE e_no_account_ccid ;
                  END IF ;
                  debug( g_state_level,l_path_name,'done backlog ccid for new dist');
                   debug( g_state_level,l_path_name,'start new balances for new dist');

             IF ((l_detail_balances_new.adjustment_cost-l_detail_balances_new.deprn_reserve<>0) OR (l_detail_balances_new.deprn_reserve_backlog <>0)) THEN -- Kaps

             l_rowid := NULL ;
             igi_iac_adjustments_pkg.insert_row(
		     		    	    X_rowid                 => l_rowid ,
                                X_adjustment_id         => l_retirement_adjustment_id ,
                                X_book_type_code		=> P_Book_Type_Code ,
                                X_code_combination_id	=> l_nbv_retired_account_ccid,
                                X_set_of_books_id		=> g_sob_id ,
                                X_dr_cr_flag            => 'CR' ,
                                X_amount               	=> l_detail_balances_new.adjustment_cost-l_detail_balances_new.deprn_reserve,
                                X_adjustment_type      	=> 'NBV RETIRED',
                                X_transfer_to_gl_flag  	=> 'Y' ,
                                X_units_assigned		=> l_units_per_dist.units_assigned ,
                                X_asset_id		        => P_Asset_Id ,
                                X_distribution_id      	=> l_new_fa_dist.distribution_id ,
                                X_period_counter       	=> g_prd_rec.period_counter,
                                X_adjustment_offset_type => NULL,
                                X_report_ccid        	=>   NULL,
                                X_mode                  => 'R',
                                X_event_id              => P_Event_Id   ) ;

         	 debug( g_state_level,l_path_name,'done nbv ret insert');

             l_rowid := NULL ;

             igi_iac_adjustments_pkg.insert_row(
		     		    	    X_rowid                 => l_rowid ,
                                X_adjustment_id         => l_retirement_adjustment_id ,
                                X_book_type_code		=> P_Book_Type_Code ,
                                X_code_combination_id	=> l_nbv_retired_account_ccid,
                                X_set_of_books_id		=> g_sob_id ,
                                X_dr_cr_flag            => 'DR' ,
                                X_amount               	=> l_detail_balances_new.deprn_reserve_backlog,
                                X_adjustment_type      	=> 'NBV RETIRED',
                                X_transfer_to_gl_flag  	=> 'Y' ,
                                X_units_assigned		=> l_units_per_dist.units_assigned ,
                                X_asset_id		        => P_Asset_Id ,
                                X_distribution_id      	=> l_new_fa_dist.distribution_id ,
                                X_period_counter       	=> g_prd_rec.period_counter,
                                X_adjustment_offset_type => NULL,
                                X_report_ccid        	=>  NULL,
                                X_mode                  => 'R',
                                X_event_id              => P_Event_Id   ) ;

         	 debug( g_state_level,l_path_name, 'done 2nd nbv ret insert');
         END IF;


         IF l_detail_balances_new.reval_reserve_net <> 0 THEN

     	    debug( g_state_level,l_path_name,'done reval rsv ret ccid');
            l_rowid := NULL ;
            igi_iac_adjustments_pkg.insert_row(
		     		    	    X_rowid                 => l_rowid ,
                                X_adjustment_id         => l_retirement_adjustment_id ,
                                X_book_type_code		=> P_Book_Type_Code ,
                                X_code_combination_id	=> l_reval_rsv_ret_acct_ccid,
                                X_set_of_books_id		=> g_sob_id ,
                                X_dr_cr_flag            => 'DR' ,
                                X_amount               	=> l_detail_balances_new.reval_reserve_net,
                                X_adjustment_type      	=> 'REVAL RSV RET',
                                X_transfer_to_gl_flag  	=> 'Y' ,
                                X_units_assigned		=> l_units_per_dist.units_assigned ,
                                X_asset_id		        => P_Asset_Id ,
                                X_distribution_id      	=> l_new_fa_dist.distribution_id ,
                                X_period_counter       	=> g_prd_rec.period_counter,
                                X_adjustment_offset_type => NULL,
                                X_report_ccid        	=>  NULL,
                                X_mode                  => 'R',
                                X_event_id              => P_Event_Id   ) ;

         	 debug( g_state_level,l_path_name,'done reval rsv ret insert');
         END IF;

                   l_rowid := NULL ;
                   igi_iac_adjustments_pkg.insert_row(
		     		    	    X_rowid                 => l_rowid ,
                                X_adjustment_id         => l_retirement_adjustment_id ,
                                X_book_type_code		=> P_Book_Type_Code ,
                                X_code_combination_id	=> l_cost_account_ccid,
                                X_set_of_books_id		=> g_sob_id ,
                                X_dr_cr_flag            => 'DR' ,
                                X_amount               	=> l_detail_balances_new.adjustment_cost,
                                X_adjustment_type      	=> 'COST',
                                X_transfer_to_gl_flag  	=> 'Y' ,
                                X_units_assigned		=> l_units_per_dist.units_assigned ,
                                X_asset_id		        => P_Asset_Id ,
                                X_distribution_id      	=> l_new_fa_dist.distribution_id,
                                X_period_counter       	=> g_prd_rec.period_counter,
                                X_adjustment_offset_type => NULL,
                                X_report_ccid        	=>  NULL,
                                X_mode                  => 'R',
                                X_event_id              => P_Event_Id   ) ;

                          	     debug( g_state_level,l_path_name,'done new cost for new dist');
             l_rowid := NULL ;
             igi_iac_adjustments_pkg.insert_row(
		     		    	    X_rowid                 => l_rowid ,
                                X_adjustment_id         => l_retirement_adjustment_id ,
                                X_book_type_code		=> P_Book_Type_Code ,
                                X_code_combination_id	=> l_acc_deprn_account_ccid,
                                X_set_of_books_id		=> g_sob_id ,
                                X_dr_cr_flag            => 'CR' ,
                                X_amount               	=> l_detail_balances_new.deprn_reserve,
                                X_adjustment_type      	=> 'RESERVE',
                                X_transfer_to_gl_flag  	=> 'Y' ,
                                X_units_assigned		=> l_units_per_dist.units_assigned ,
                                X_asset_id		        => P_Asset_Id ,
                                X_distribution_id      	=> l_new_fa_dist.distribution_id,
                                X_period_counter       	=> g_prd_rec.period_counter,
                                X_adjustment_offset_type => NULL,
                                X_report_ccid        	=>  NULL,
                                X_mode                  => 'R',
                                X_event_id              => P_Event_Id   ) ;
             l_rowid := NULL ;
             igi_iac_adjustments_pkg.insert_row(
		     		    	    X_rowid                 => l_rowid ,
                                X_adjustment_id         => l_retirement_adjustment_id ,
                                X_book_type_code		=> P_Book_Type_Code ,
                                X_code_combination_id	=> l_backlog_account_ccid,
                                X_set_of_books_id		=> g_sob_id ,
                                X_dr_cr_flag            => 'CR' ,
                                X_amount               	=> l_detail_balances_new.deprn_reserve_backlog,
                                X_adjustment_type      	=> 'BL RESERVE',
                                X_transfer_to_gl_flag  	=> 'Y' ,
                                X_units_assigned		=> l_units_per_dist.units_assigned ,
                                X_asset_id		        => P_Asset_Id ,
                                X_distribution_id      	=> l_new_fa_dist.distribution_id,
                                X_period_counter       	=> g_prd_rec.period_counter,
                                X_adjustment_offset_type => NULL,
                                X_report_ccid        	=>  NULL,
                                X_mode                  => 'R',
                                X_event_id              => P_Event_Id   ) ;


     	               debug( g_state_level,l_path_name,'done BL reserve for new dist');
                      l_rowid := NULL ;
                     igi_iac_adjustments_pkg.insert_row(
		     		    	    X_rowid                 => l_rowid ,
                                X_adjustment_id         => l_retirement_adjustment_id ,
                                X_book_type_code		=> P_Book_Type_Code ,
                                X_code_combination_id	=> l_reval_rsv_account_ccid,
                                X_set_of_books_id		=> g_sob_id ,
                                X_dr_cr_flag            => 'CR' ,
                                X_amount               	=> l_detail_balances_new.reval_reserve_net,
                                X_adjustment_type      	=> 'REVAL RESERVE',
                                X_transfer_to_gl_flag  	=> 'Y' ,
                                X_units_assigned		=> l_units_per_dist.units_assigned ,
                                X_asset_id		        => P_Asset_Id ,
                                X_distribution_id      	=> l_new_fa_dist.distribution_id,
                                X_period_counter       	=> g_prd_rec.period_counter,
                                X_adjustment_offset_type => NULL,
                                X_report_ccid        	=>  NULL,
                                X_mode                  => 'R',
                                X_event_id              => P_Event_Id   ) ;

                          debug( g_state_level,l_path_name,'done  reval rsv for new dist');







                         l_rowid := NULL ;
                        igi_iac_det_balances_pkg.insert_row(
                       	    	X_rowid                     => l_rowid ,
			     		        X_adjustment_id		        => l_retirement_adjustment_id ,
        					    X_asset_id		            => P_Asset_Id ,
	        				    X_distribution_id	        => l_new_fa_dist.distribution_id,
		        			    X_book_type_code	        => P_Book_Type_Code ,
			        		    X_period_counter	        => g_prd_rec.period_counter,
				        	    X_adjustment_cost	        => l_detail_balances_new.adjustment_cost ,
                                X_net_book_value	        => l_detail_balances_new.net_book_value,
        				        X_reval_reserve_cost	    => l_detail_balances_new.reval_reserve_cost,
		    			        X_reval_reserve_backlog     => l_detail_balances_new.reval_reserve_backlog,
    			    		    X_reval_reserve_gen_fund    => l_detail_balances_new.reval_reserve_gen_fund,
	    			    	    X_reval_reserve_net	        => l_detail_balances_new.reval_reserve_net,
                                X_operating_acct_cost	    => l_detail_balances_new.operating_acct_cost,
    		    			    X_operating_acct_backlog    => l_detail_balances_new.operating_acct_backlog,
	    		    		    X_operating_acct_net	    => l_detail_balances_new.operating_acct_net,
 		    		    	    X_operating_acct_ytd	    => l_detail_balances.operating_acct_ytd,
			    		        X_deprn_period		        => l_detail_balances_new.deprn_period,
 				    	        X_deprn_ytd		            => 0,
                                X_deprn_reserve		        => l_detail_balances_new.deprn_reserve,
        					    X_deprn_reserve_backlog	    => l_detail_balances_new.deprn_reserve_backlog,
	        				    X_general_fund_per	        => l_detail_balances_new.general_fund_per,
		        			    X_general_fund_acc	        => l_detail_balances_new.general_fund_acc,
 			        		    X_last_reval_date	        => l_detail_balances.last_reval_date ,
				        	    X_current_reval_factor	    => l_detail_balances.current_reval_factor ,
                                X_cumulative_reval_factor   => l_detail_balances.cumulative_reval_factor ,
     					        X_active_flag		        => l_detail_balances.active_flag,
                                X_mode                      =>  'R') ;

                            debug( g_state_level,l_path_name,'CURRENT PERIOD');
			     		    debug( g_state_level,l_path_name,'X_adjustment_id		   => '||l_retirement_adjustment_id );
    					    debug( g_state_level,l_path_name,'X_asset_id		       =>'|| P_Asset_Id );
    	        			debug( g_state_level,l_path_name,'X_distribution_id	       =>'|| l_new_fa_dist.distribution_id );
    	        			debug( g_state_level,l_path_name,'X_book_type_code	       =>'|| P_Book_Type_Code );
    	        			debug( g_state_level,l_path_name,'X_period_counter	       =>'|| g_prd_rec.period_counter);
    	        			debug( g_state_level,l_path_name,'X_adjustment_cost	       =>'|| l_detail_balances_new.adjustment_cost );
    	        			debug( g_state_level,l_path_name,'X_net_book_value	       =>'|| l_detail_balances_new.net_book_value);
    	        			debug( g_state_level,l_path_name,'X_reval_reserve_cost	   =>'|| l_detail_balances_new.reval_reserve_cost);
    	        			debug( g_state_level,l_path_name,'X_reval_reserve_backlog  =>'|| l_detail_balances_new.reval_reserve_backlog);
    	        			debug( g_state_level,l_path_name,'X_reval_reserve_gen_fund =>'|| l_detail_balances_new.reval_reserve_gen_fund);
      	        			debug( g_state_level,l_path_name,'X_reval_reserve_net	   =>'|| l_detail_balances_new.reval_reserve_net);
                            debug( g_state_level,l_path_name,'X_operating_acct_cost	   =>'|| l_detail_balances_new.operating_acct_cost);
                            debug( g_state_level,l_path_name,'X_operating_acct_backlog =>'|| l_detail_balances_new.operating_acct_backlog);
                            debug( g_state_level,l_path_name,'X_operating_acct_net	   =>'|| l_detail_balances_new.operating_acct_net);
                            debug( g_state_level,l_path_name,'X_operating_acct_ytd	   =>'|| l_detail_balances.operating_acct_ytd);
                            debug( g_state_level,l_path_name,'X_deprn_period		   =>'|| l_detail_balances_new.deprn_period);
                            debug( g_state_level,l_path_name,'X_deprn_ytd		       =>'|| l_detail_balances_new.deprn_ytd);
                            debug( g_state_level,l_path_name,'X_deprn_reserve		   =>'|| l_detail_balances_new.deprn_reserve);
                            debug( g_state_level,l_path_name,'X_deprn_reserve_backlog  =>'|| l_detail_balances_new.deprn_reserve_backlog);
                            debug( g_state_level,l_path_name,'X_general_fund_per	   =>'|| l_detail_balances_new.general_fund_per);
                            debug( g_state_level,l_path_name,'X_general_fund_acc	   =>'|| l_detail_balances_new.general_fund_acc);
                            debug( g_state_level,l_path_name,'X_last_reval_date	       =>'|| l_detail_balances.last_reval_date );
                            debug( g_state_level,l_path_name,'X_current_reval_factor   =>'|| l_detail_balances.current_reval_factor );
                            debug( g_state_level,l_path_name,'X_cumulative_reval_factor=>'|| l_detail_balances.cumulative_reval_factor );
                            debug( g_state_level,l_path_name,'X_active_flag		       =>'|| l_detail_balances.active_flag);



                 	   debug( g_state_level,l_path_name,'end insert det bals for new dist');

                       IF (g_is_first_period) THEN
                           l_fa_deprn.deprn_ytd   := 0;
                       ELSE
                           l_fa_deprn_ytd   := l_fa_deprn.deprn_ytd;
                       END IF;

                   -- insert into igi_iac_fa_deprn with the reinstatement adjustment_id
                       l_rowid:=NULL;
                       IGI_IAC_FA_DEPRN_PKG.Insert_Row(
                           x_rowid                => l_rowid,
                           x_book_type_code       => p_book_type_code,
                           x_asset_id             => p_asset_id,
                           x_period_counter       => g_prd_rec.period_counter,
                           x_adjustment_id        => l_retirement_adjustment_id,
                           x_distribution_id      => l_new_fa_dist.distribution_id,
                           x_deprn_period         => l_fa_deprn.deprn_period,
                           x_deprn_ytd            => 0,
                           x_deprn_reserve        => l_fa_total_new_acc_deprn,
                           x_active_flag          => NULL,
                           x_mode                 => 'R');

                  END IF ; -- for new distributon cerated


        ELSE -- active distribution not impacted by partial unit retirement
            	 debug( g_state_level,l_path_name,'Non Imapcted Active distributions insertion');
                 CLOSE c_get_impacted_dist;
             /*  Roll forward YTD records   */
               IF (g_is_first_period) THEN
                   l_fa_deprn_ytd   := 0;
               ELSE
                   l_fa_deprn_ytd   := l_fa_deprn.deprn_ytd;
               END IF;

              l_asset_units_count      := l_asset_units_count + l_units_per_dist.units_assigned ;

              l_rowid := NULL ;
              igi_iac_det_balances_pkg.insert_row(
                       		X_rowid                     => l_rowid ,
			     		    X_adjustment_id		        => l_retirement_adjustment_id ,
    					    X_asset_id		            => P_Asset_Id,
	    				    X_distribution_id	        => l_detail_balances.distribution_id ,
		    			    X_book_type_code	        => P_Book_Type_Code ,
			    		    X_period_counter	        => g_prd_rec.period_counter,
				    	    X_adjustment_cost	        => l_detail_balances.adjustment_cost ,
                            X_net_book_value	        => l_detail_balances.net_book_value,
        				    X_reval_reserve_cost	    => l_detail_balances.reval_reserve_cost,
		    			    X_reval_reserve_backlog     => l_detail_balances.reval_reserve_backlog,
			    		    X_reval_reserve_gen_fund    => l_detail_balances.reval_reserve_gen_fund,
				    	    X_reval_reserve_net	        => l_detail_balances.reval_reserve_net,
                            X_operating_acct_cost	    => l_detail_balances.operating_acct_cost,
    					    X_operating_acct_backlog    => l_detail_balances.operating_acct_backlog,
	    				    X_operating_acct_net	    => l_detail_balances.operating_acct_net,
 		    			    X_operating_acct_ytd	    => l_detail_balances.operating_acct_ytd,
			    		    X_deprn_period		        => l_detail_balances.deprn_period,
 				    	    X_deprn_ytd		            => l_detail_balances.deprn_ytd,
                            X_deprn_reserve		        => l_detail_balances.deprn_reserve,
    					    X_deprn_reserve_backlog	    => l_detail_balances.deprn_reserve_backlog,
	    				    X_general_fund_per	        => l_detail_balances.general_fund_per,
		    			    X_general_fund_acc	        => l_detail_balances.general_fund_acc,
 			    		    X_last_reval_date	        => l_detail_balances.last_reval_date ,
				    	    X_current_reval_factor	    => l_detail_balances.current_reval_factor ,
                            X_cumulative_reval_factor   => l_detail_balances.cumulative_reval_factor ,
     					    X_active_flag		        => l_detail_balances.active_flag ,
                            X_mode                      =>  'R') ;


               l_rowid := NULL ;
               IGI_IAC_FA_DEPRN_PKG.Insert_Row(
                           x_rowid                => g_rowid,
                           x_book_type_code       => p_book_type_code,
                           x_asset_id             => p_asset_id,
                           x_period_counter       => g_prd_rec.period_counter,
                           x_adjustment_id        => l_retirement_adjustment_id,
                           x_distribution_id      => l_fa_deprn.distribution_id,
                           x_deprn_period         => l_fa_deprn.deprn_period,
                           x_deprn_ytd            => l_fa_deprn_ytd,
                           x_deprn_reserve        => l_fa_deprn.deprn_reserve,
                           x_active_flag          => l_fa_deprn.active_flag,
                           x_mode                 => 'R');

             --asset total;
             l_asset_balances.net_book_value :=l_asset_balances.net_book_value+l_detail_balances.net_book_value;
             l_asset_balances.adjusted_cost  :=l_asset_balances.adjusted_cost +l_detail_balances.adjustment_cost;
             l_asset_balances.operating_acct :=l_asset_balances.operating_acct+ l_detail_balances.operating_acct_net;
             l_asset_balances.reval_reserve  :=l_asset_balances.reval_reserve +l_detail_balances.reval_reserve_net;
             l_asset_balances.deprn_amount   :=l_asset_balances.deprn_amount  +l_detail_balances.deprn_period;
             l_asset_balances.deprn_reserve  :=l_asset_balances.deprn_reserve +l_detail_balances.deprn_reserve;
             l_asset_balances.backlog_deprn_reserve:=l_asset_balances.backlog_deprn_reserve+l_detail_balances.deprn_reserve_backlog;
             l_asset_balances.general_fund   :=l_asset_balances.general_fund +l_detail_balances.general_fund_acc;


           END IF ;   -- if active_flag is Null and not impacted partial unot retirement

       ELSE  -- Inactive distributions IF active_flag is NULL.  i.e. following code for active_flag = 'N'

     	 debug( g_state_level,l_path_name,'Non Imapcted InActive distributions insertion');
         /*  Roll forward YTD records   */
           IF (g_is_first_period) THEN
               l_fa_deprn_ytd   := 0;
           ELSE
               l_fa_deprn_ytd   := l_fa_deprn.deprn_ytd;
           END IF;

                           l_rowid:=NULL  ;
                          igi_iac_det_balances_pkg.insert_row(
                       		X_rowid                     => l_rowid ,
			     		    X_adjustment_id		        => l_retirement_adjustment_id ,
    					    X_asset_id		            => P_Asset_Id,
	    				    X_distribution_id	        => l_detail_balances.distribution_id ,
		    			    X_book_type_code	        => P_Book_Type_Code ,
			    		    X_period_counter	        => g_prd_rec.period_counter,
				    	    X_adjustment_cost	        => l_detail_balances.adjustment_cost ,
                            X_net_book_value	        => l_detail_balances.net_book_value,
        				    X_reval_reserve_cost	    => l_detail_balances.reval_reserve_cost,
		    			    X_reval_reserve_backlog     => l_detail_balances.reval_reserve_backlog,
			    		    X_reval_reserve_gen_fund    => l_detail_balances.reval_reserve_gen_fund,
				    	    X_reval_reserve_net	        => l_detail_balances.reval_reserve_net,
                            X_operating_acct_cost	    => l_detail_balances.operating_acct_cost,
    					    X_operating_acct_backlog    => l_detail_balances.operating_acct_backlog,
	    				    X_operating_acct_net	    => l_detail_balances.operating_acct_net,
 		    			    X_operating_acct_ytd	    => l_detail_balances.operating_acct_ytd,
			    		    X_deprn_period		        => l_detail_balances.deprn_period,
 				    	    X_deprn_ytd		            => l_detail_balances.deprn_ytd,
                            X_deprn_reserve		        => l_detail_balances.deprn_reserve,
    					    X_deprn_reserve_backlog	    => l_detail_balances.deprn_reserve_backlog,
	    				    X_general_fund_per	        => l_detail_balances.general_fund_per,
		    			    X_general_fund_acc	        => l_detail_balances.general_fund_acc,
 			    		    X_last_reval_date	        => l_detail_balances.last_reval_date ,
				    	    X_current_reval_factor	    => l_detail_balances.current_reval_factor ,
                            X_cumulative_reval_factor   => l_detail_balances.cumulative_reval_factor ,
     					    X_active_flag		        => l_detail_balances.active_flag ,
                            X_mode                      =>  'R') ;


                   l_rowid:=NULL;
                   IGI_IAC_FA_DEPRN_PKG.Insert_Row(
                   x_rowid                => l_rowid,
                   x_book_type_code       => p_book_type_code,
                   x_asset_id             => p_asset_id,
                   x_period_counter       => g_prd_rec.period_counter,
                   x_adjustment_id        => l_retirement_adjustment_id,
                   x_distribution_id      => l_fa_deprn.distribution_id,
                   x_deprn_period         => l_fa_deprn.deprn_period,
                   x_deprn_ytd            => l_fa_deprn_ytd,
                   x_deprn_reserve        => l_fa_deprn.deprn_reserve,
                   x_active_flag          => l_fa_deprn.active_flag,
                   x_mode                 => 'R'
                                      );
       END IF ;   -- if active_flag is Null

     END LOOP ; -- g_detail_balances
     debug( g_state_level, l_path_name, 'end loop');

      OPEN  c_asset_balances(P_Asset_Id, P_Book_Type_Code, g_prd_rec.period_counter);

      FETCH c_asset_balances INTO l_asset_balances_rec ;

      IF c_asset_balances%NOTFOUND THEN
          CLOSE c_asset_balances ;

          OPEN c_previous_per(l_last_active_adj_id) ;
          FETCH c_previous_per INTO l_previous_per ;
          IF c_previous_per%NOTFOUND THEN
		CLOSE c_previous_per;
            RAISE NO_DATA_FOUND ;
          END IF ;
          CLOSE c_previous_per ;

          OPEN c_asset_balances(P_Asset_Id, P_Book_Type_Code, l_previous_per ) ;
          FETCH c_asset_balances INTO l_asset_balances_rec ;
          IF    c_asset_balances%NOTFOUND THEN
	    CLOSE c_asset_balances;

	--Begin Fix for Bug 5049536
	    SELECT max(period_counter)
	    INTO l_max_period_counter
            FROM   igi_iac_asset_balances
            WHERE  asset_id = P_Asset_Id
              AND    book_type_code = P_Book_Type_Code;

           OPEN c_asset_balances(P_Asset_Id, P_Book_Type_Code, l_max_period_counter) ;
           FETCH c_asset_balances INTO l_asset_balances_rec ;
           --RAISE e_no_asset_bals ;
	--End fix for Bug 5049536
          END IF ;

                    igi_iac_asset_balances_pkg.insert_row(
                        X_rowid                     => l_rowid ,
		    			X_asset_id		    => p_asset_id,
				    	X_book_type_code	=> p_book_type_code ,
    					X_period_counter	=> g_prd_rec.period_counter ,
	    				X_net_book_value	=> l_asset_balances.net_book_value ,
		    			X_adjusted_cost		=> l_asset_balances.adjusted_cost ,
			    		X_operating_acct	=> l_asset_balances.operating_acct ,
				    	X_reval_reserve		=> l_asset_balances.reval_reserve ,
                        X_deprn_amount		=> l_asset_balances.deprn_amount,
    					X_deprn_reserve		=> l_asset_balances.deprn_reserve ,
	    				X_backlog_deprn_reserve => l_asset_balances.backlog_deprn_reserve ,
		    			X_general_fund		=> l_asset_balances.general_fund ,
			    		X_last_reval_date	=> l_asset_balances_rec.last_reval_date ,
				    	X_current_reval_factor	=> l_asset_balances_rec.current_reval_factor,
                        X_cumulative_reval_factor => l_asset_balances_rec.cumulative_reval_factor,
                        X_mode                   => 'R') ;



      ELSE
                  igi_iac_asset_balances_pkg.update_row(
		    			X_asset_id		    => p_asset_id,
				    	X_book_type_code	=> p_book_type_code ,
    					X_period_counter	=> g_prd_rec.period_counter ,
	    				X_net_book_value	=> l_asset_balances.net_book_value ,
		    			X_adjusted_cost		=> l_asset_balances.adjusted_cost ,
			    		X_operating_acct	=> l_asset_balances.operating_acct ,
				    	X_reval_reserve		=> l_asset_balances.reval_reserve ,
                        X_deprn_amount		=> l_asset_balances.deprn_amount,
    					X_deprn_reserve		=> l_asset_balances.deprn_reserve ,
	    				X_backlog_deprn_reserve => l_asset_balances.backlog_deprn_reserve ,
		    			X_general_fund		=> l_asset_balances.general_fund ,
			    		X_last_reval_date	=> l_asset_balances_rec.last_reval_date ,
				    	X_current_reval_factor	=> l_asset_balances_rec.current_reval_factor,
                        X_cumulative_reval_factor => l_asset_balances_rec.cumulative_reval_factor,
                        X_mode                   => 'R') ;

  END IF;
  CLOSE c_asset_balances ;

  RETURN TRUE;

  EXCEPTION
  WHEN OTHERS  THEN
    debug( g_state_level,l_path_name,'Error in Processing Unit Retirement');
    FA_SRVR_MSG.add_sql_error(Calling_Fn  => g_calling_fn);
    RETURN FALSE ;

END unit_retirement;

      FUNCTION Prior_Unit_Retirement (P_Asset_Id                IN NUMBER ,
                                    P_Book_Type_Code          IN VARCHAR2 ,
                                    P_Retirement_Id           IN NUMBER ,
                                    P_retirement_type         IN VARCHAR2,
                                    p_retirement_period_type  IN VARCHAR2,
                                    P_prior_period            IN NUMBER,
                                    P_Current_period          IN NUMBER,
                                    P_Event_Id                IN NUMBER ) --R12 uptake
RETURN BOOLEAN IS
    l_rowid                           ROWID;
    l_asset_balances                  igi_iac_asset_balances%ROWTYPE;
    l_asset_balances_rec              igi_iac_asset_balances%ROWTYPE;
    l_detail_balances                 igi_iac_det_balances%ROWTYPE;
    l_detail_balances_new             igi_iac_det_balances%ROWTYPE;
    l_detail_balances_total_old       igi_iac_det_balances%ROWTYPE;
    l_detail_balances_retire          igi_iac_det_balances%ROWTYPE;
    l_detail_balances_retire_unrnd    igi_iac_det_balances%ROWTYPE;
    l_detail_balances_rnd_tot         igi_iac_det_balances%ROWTYPE;
    l_fa_deprn                        igi_iac_fa_deprn%ROWTYPE;
    l_units_per_dist                  c_units_per_dist%ROWTYPE;
    l_cost_account_ccid               NUMBER ;
    l_acc_deprn_account_ccid          NUMBER ;
    l_reval_rsv_account_ccid          NUMBER ;
    l_backlog_account_ccid            NUMBER ;
    l_nbv_retired_account_ccid        NUMBER ;
    l_reval_rsv_ret_acct_ccid         NUMBER ;
    l_deprn_exp_account_ccid          NUMBER ;
    l_account_gen_fund_ccid           NUMBER;
    l_new_units                       NUMBER ;
    l_new_distribution                NUMBER ;
    l_units_before                    NUMBER ;
    l_units_after                     NUMBER ;
    l_ret                             BOOLEAN ;
    l_total_asset_units               NUMBER ;
    l_asset_units_count               NUMBER ;
    l_previous_per                    NUMBER ;
    l_prev_adjustment_id              igi_iac_transaction_headers.adjustment_id%TYPE ;
    l_last_active_adj_id              igi_iac_transaction_headers.adjustment_id%TYPE ;
    l_db_op_acct_ytd                  igi_iac_det_balances.operating_acct_ytd%TYPE;
    l_db_deprn_ytd                    igi_iac_det_balances.deprn_ytd%TYPE;
    l_fa_deprn_prd                    igi_iac_fa_deprn.deprn_period%TYPE;
    l_fa_tot_round_deprn_prd          igi_iac_fa_deprn.deprn_period%TYPE;
    l_fa_unround_deprn_prd            igi_iac_fa_deprn.deprn_period%TYPE;
    l_fa_total_old_acc_deprn          igi_iac_fa_deprn.deprn_reserve%TYPE;
    l_fa_retire_acc_deprn             igi_iac_fa_deprn.deprn_reserve%TYPE;
    l_fa_tot_round_acc_deprn          igi_iac_fa_deprn.deprn_reserve%TYPE;
    l_fa_unround_acc_deprn            igi_iac_fa_deprn.deprn_reserve%TYPE;
    l_fa_total_new_acc_deprn          igi_iac_fa_deprn.deprn_reserve%TYPE;
    l_fa_deprn_ytd                    igi_iac_fa_deprn.deprn_ytd%TYPE;
    l_fa_tot_round_deprn_ytd          igi_iac_fa_deprn.deprn_ytd%TYPE;
    l_fa_unround_deprn_ytd            igi_iac_fa_deprn.deprn_ytd%TYPE;
    l_fa_total_new_deprn_prd          igi_iac_fa_deprn.deprn_ytd%TYPE;
    l_fa_total_new_deprn_ytd          igi_iac_fa_deprn.deprn_ytd%TYPE;
    l_fa_total_old_deprn_prd          igi_iac_fa_deprn.deprn_ytd%TYPE;
    l_fa_total_old_deprn_ytd          igi_iac_fa_deprn.deprn_ytd%TYPE;
    l_fa_retire_deprn_prd             igi_iac_fa_deprn.deprn_ytd%TYPE;
    l_fa_retire_deprn_ytd             igi_iac_fa_deprn.deprn_ytd%TYPE;
    l_op_exp_ccid                     NUMBER;
    l_Transaction_Type_Code	          igi_iac_transaction_headers.transaction_type_code%TYPE;
    l_Transaction_Id                  igi_iac_transaction_headers.transaction_header_id%TYPE;
    l_Mass_Reference_ID	              igi_iac_transaction_headers.mass_reference_id%TYPE;
    l_Adjustment_Status               igi_iac_transaction_headers.adjustment_status%TYPE;
    l_adjustment_id_out               igi_iac_adjustments.adjustment_id%TYPE;
    l_retirement_adjustment_id        NUMBER;
    l_path_name                       varchar2(200);
    l_check_revaluations              c_check_revaluations%ROWTYPE;
    l_all_occ_reval                   c_get_all_occ_reval%ROWTYPE;
    l_retire_amount                   Number;
    l_check_depreciations             c_check_depreciations%ROWTYPE;
    l_all_prd_reval                   c_get_all_prd_reval%ROWTYPE;
    l_retirement_factor               number;
    l_impact_fa_dist                  c_get_impacted_dist%ROWTYPE;
    l_new_fa_dist                     c_get_new_dist%ROWTYPE;
BEGIN

        l_path_name:=g_path_name ||'.Prior_Period_Unit_Retirement';
         /*  Initialize Asset total balance variables  */
         ------------------------
        l_asset_balances.Asset_id       :=P_Asset_Id ;
        l_asset_balances.book_type_code :=P_Book_Type_Code;
        l_asset_balances.period_counter :=P_Current_period;
        l_asset_balances.net_book_value :=0;
        l_asset_balances.adjusted_cost  :=0;
        l_asset_balances.operating_acct :=0;
        l_asset_balances.reval_reserve  :=0;
        l_asset_balances.deprn_amount   :=0;
        l_asset_balances.deprn_reserve  :=0;
        l_asset_balances.backlog_deprn_reserve:=0;
        l_asset_balances.general_fund   :=0;


        l_Transaction_Type_Code     := NULL;
        l_Transaction_Id            := NULL;
        l_Mass_Reference_ID         := NULL;
        l_adjustment_id_out         := NULL;
        l_prev_adjustment_id        := NULL;
        l_Adjustment_Status         := NULL;
        l_retirement_adjustment_id  :=NULL;

       debug(g_state_level,l_path_name,'Asset ID '||P_Asset_Id);
       -- get the latest tranaction for the asset id

       IF NOT (igi_iac_common_utils.get_latest_transaction(P_Book_Type_Code,
                                                           P_Asset_Id,
                                                           l_Transaction_Type_Code,
                                                           l_Transaction_Id,
                                                           l_Mass_Reference_ID ,
                                                           l_adjustment_id_out,
                                                           l_prev_adjustment_id,
                                                           l_Adjustment_Status )) THEN
               igi_iac_debug_pkg.debug_other_string(g_error_level,l_path_name,'*** Error in fetching the latest transaction');
               RETURN FALSE;
       END IF;

       debug(g_state_level,l_path_name,'got latest transaction');
       l_last_active_adj_id := l_prev_adjustment_id ;
       debug( g_state_level,l_path_name,'not reval in preview');

       ---check for revauations if exits between the prior perod and current period
       -- Start revaluation
        OPEN c_check_revaluations(P_asset_id,p_book_type_code,
                                  p_prior_period,p_current_period);
        FETCH c_check_revaluations INTO l_check_revaluations;
        IF c_check_revaluations%FOUND THEN -- revlautions found in betweem
            l_path_name :=l_path_name ||'.Reval Reversal' ;

            --- create a new transaction header for Revlaution retirement
            l_rowid:=NULL;
            l_retirement_adjustment_id :=NULL;
            igi_iac_trans_headers_pkg.insert_row(
	                       	    X_rowid		            => l_rowid ,
                        		X_adjustment_id	        => l_retirement_adjustment_id ,
                        		X_transaction_header_id => g_retire_rec.detail_info.transaction_header_id_in,
                        		X_adjustment_id_out	    => NULL ,
                        		X_transaction_type_code => 'REVALUATION',
                        		X_transaction_date_entered => g_fa_trx.transaction_date_entered,
                        		X_mass_refrence_id	    => g_fa_trx.mass_reference_id ,
                        		X_transaction_sub_type	=> 'RETIREMENT',
                        		X_book_type_code	    => P_Book_Type_Code,
                        		X_asset_id		        => p_asset_id ,
                        		X_category_id		    => g_asset_category_id,
                        		X_adj_deprn_start_date	=> NULL,
                        		X_revaluation_type_flag => NULL,
                        		X_adjustment_status	    => 'COMPLETE' ,
                        		X_period_counter	    => P_Current_period,
                                X_mode                  =>'R',
                                X_event_id              => P_Event_Id) ;

            debug( g_state_level, l_path_name,'inserted trans_headers record');

            igi_iac_trans_headers_pkg.update_row(l_adjustment_id_out,
                                                 l_retirement_adjustment_id,
                                                 'R') ;

            debug( g_state_level,l_path_name,'updated old trans_headers record');

            --get all adjustments for occasional revaluation between current period and
            -- retire period
             FOR l_detail_balances IN c_detail_balances(l_last_active_adj_id) LOOP

          	    debug( g_state_level,l_path_name,'Inside loop ');
                debug( g_state_level,l_path_name,'Detail balances loop: '|| l_detail_balances.distribution_id);

                OPEN c_fa_deprn( l_detail_balances.adjustment_id,
                                 l_detail_balances.distribution_id,
                                 l_detail_balances.period_counter);
                FETCH c_fa_deprn INTO l_fa_deprn;
                IF c_fa_deprn%NOTFOUND THEN
                     CLOSE c_fa_deprn;
                     RETURN FALSE;
                END IF;
                CLOSE c_fa_deprn;

                IF l_detail_balances.active_flag IS NULL THEN -- Active distributions

                	  debug( g_state_level,l_path_name,'Active dist ');
               	      debug( g_state_level,l_path_name,'Detail balances loop: active record dist id  '|| l_detail_balances.distribution_id);
                      OPEN  c_units_per_dist(P_Asset_Id, P_Book_Type_Code, l_detail_balances.distribution_id) ;
                 	        debug( g_state_level, l_path_name,'opened c_units_per_dist');
                       FETCH c_units_per_dist INTO l_units_per_dist ;
                       IF    c_units_per_dist%NOTFOUND THEN
			    CLOSE c_units_per_dist;
                           debug( g_state_level,l_path_name,'units per dist not found');
                           RAISE NO_DATA_FOUND;
                        END IF ;
                       CLOSE c_units_per_dist ;


      -- find the impacted distribution because of the partial unit retirement
                     OPEN c_get_impacted_dist(P_Asset_Id,P_Retirement_Id,l_detail_balances.distribution_id);
                     FETCH c_get_impacted_dist INTO l_impact_fa_dist;
                     IF c_get_impacted_dist%FOUND THEN -- impacted by partial nit retirement
                             --CLOSE c_get_impacted_dist;
                            --- distribtion impacted by partial unkit retirement
                             l_detail_balances_retire.adjustment_cost        :=0 ;
                             l_detail_balances_retire.reval_reserve_cost     :=0 ;
                             l_detail_balances_retire.deprn_reserve          :=0 ;
                             l_detail_balances_retire.deprn_reserve_backlog  :=0 ;
                             l_detail_balances_retire.reval_reserve_net      :=0 ;
                             l_detail_balances_retire.deprn_period           :=0 ;
                             l_detail_balances_retire.general_fund_acc       :=0 ;
                             l_detail_balances_retire.general_fund_per       :=0 ;
                             l_detail_balances_retire.reval_reserve_gen_fund :=0 ;
                             l_detail_balances_retire.operating_acct_backlog :=0;
                             l_detail_balances_retire.operating_acct_cost    :=0;
                             l_detail_balances_retire.operating_acct_net     :=0;
                             l_detail_balances_retire.reval_reserve_backlog  :=0;
                             l_detail_balances_retire.deprn_ytd              :=0;

                           -- get the impacted new distribution create for the retire distribution
                            l_retirement_factor := 1;
                            IF l_impact_fa_dist.transaction_units <> l_impact_fa_dist.units_assigned THEN

                            OPEN  c_get_new_dist(P_Asset_Id,P_Retirement_Id,l_impact_fa_dist.code_combination_id,
                                                ABS(l_impact_fa_dist.units_assigned + l_impact_fa_dist.transaction_units),l_impact_fa_dist.location_id,
                                                  NVL(l_impact_fa_dist.assigned_to,-1));
                  	         FETCH C_get_new_dist INTO l_new_fa_dist;
                              IF C_get_new_dist%FOUND THEN
                                   l_retirement_factor := - NVL(l_impact_fa_dist.transaction_units,0)/ l_impact_fa_dist.units_assigned;
                                   l_units_per_dist.units_assigned :=l_new_fa_dist.units_assigned;
                              END IF;
                              CLOSE C_get_new_dist;
                            END IF;


                            FOR l_all_occ_reval IN  c_get_all_occ_reval(p_asset_id,p_book_type_code,
                                                                         P_prior_period,
                                                                         p_current_period,
                                                                         l_detail_balances.distribution_id ) LOOP


                                  l_retire_amount:=l_all_occ_reval.amount;
                                  --l_ret:= igi_iac_common_utils.iac_round(l_retire_amount,P_Book_Type_Code);
                                  l_rowid := NULL ;
                                  igi_iac_adjustments_pkg.insert_row(
		     		                     	    X_rowid                 => l_rowid ,
                                                X_adjustment_id         => l_retirement_adjustment_id ,
                                                X_book_type_code		=> P_Book_Type_Code ,
                                                X_code_combination_id	=> l_all_occ_reval.code_combination_id,
                                                X_set_of_books_id		=> g_sob_id ,
                                                X_dr_cr_flag            => 'DR',
                                                X_amount               	=> l_all_occ_reval.amount,
                                                X_adjustment_type      	=> l_all_occ_reval.adjustment_type,
                                                X_transfer_to_gl_flag  	=> 'Y',
                                                X_units_assigned		=> l_all_occ_reval.units_assigned ,
                                                X_asset_id		        => p_Asset_Id ,
                                                X_distribution_id      	=> l_detail_balances.distribution_id ,
                                                X_period_counter       	=> g_prd_rec.period_counter,
                                                X_adjustment_offset_type =>l_all_occ_reval.adjustment_offset_type,
                                                X_report_ccid        	=> l_all_occ_reval.report_ccid,
                                                X_mode                  => 'R',
                                                X_event_id              => P_Event_Id   ) ;

                                   debug( g_state_level,l_path_name,'adjustment type '|| l_all_occ_reval.adjustment_type);
                                   debug( g_state_level,l_path_name,'amount '         || l_all_occ_reval.amount);
                                   debug( g_state_level,l_path_name,'distribution  '  || l_detail_balances.distribution_id);


                                    IF  l_retirement_factor <> 1 THEN

                                            l_retire_amount:=l_all_occ_reval.amount * l_retirement_factor ;
					    do_round(l_retire_amount,P_Book_Type_Code);
                                            l_ret:= igi_iac_common_utils.iac_round(l_retire_amount,P_Book_Type_Code);

                                            l_rowid := NULL ;
                                            igi_iac_adjustments_pkg.insert_row(
		                     		         	    X_rowid                 => l_rowid ,
                                                    X_adjustment_id         => l_retirement_adjustment_id ,
                                                    X_book_type_code		=> P_Book_Type_Code ,
                                                    X_code_combination_id	=> l_all_occ_reval.code_combination_id,
                                                    X_set_of_books_id		=> g_sob_id ,
                                                    X_dr_cr_flag            => 'CR',
                                                    X_amount               	=> l_retire_amount,
                                                    X_adjustment_type      	=> l_all_occ_reval.adjustment_type,
                                                    X_transfer_to_gl_flag  	=> 'Y',
                                                    X_units_assigned		=> l_new_fa_dist.units_assigned ,
                                                    X_asset_id		        => p_Asset_Id ,
                                                    X_distribution_id      	=> l_new_fa_dist.distribution_id ,
                                                    X_period_counter       	=> g_prd_rec.period_counter,
                                                    X_adjustment_offset_type =>l_all_occ_reval.adjustment_offset_type,
                                                    X_report_ccid        	=> l_all_occ_reval.report_ccid,
                                                    X_mode                  => 'R',
                                                    X_event_id              => P_Event_Id   ) ;
                                                   debug( g_state_level,l_path_name,'adjustment type '|| l_all_occ_reval.adjustment_type);
                                                   debug( g_state_level,l_path_name,'amount '         || l_retire_amount);
                                                   debug( g_state_level,l_path_name,'distribution  '  || l_new_fa_dist.distribution_id);

                                      END IF;

                                           IF l_all_occ_reval.adjustment_type = 'COST' THEN
                                                l_detail_balances_retire.adjustment_cost:=l_detail_balances_retire.adjustment_cost + l_retire_amount;
                                           END IF;
                                           IF l_all_occ_reval.adjustment_type = 'COST' AND l_all_occ_reval.adjustment_offset_type='REVAL RESERVE'  THEN
                                                 l_detail_balances_retire.reval_reserve_cost:= l_detail_balances_retire.reval_reserve_cost + l_retire_amount;
                                           END IF;
                                           IF l_all_occ_reval.adjustment_type = 'BL RESERVE' AND l_all_occ_reval.adjustment_offset_type='REVAL RESERVE'  THEN
                                                 l_detail_balances_retire.reval_reserve_backlog  := l_detail_balances_retire.reval_reserve_backlog - l_retire_amount;
                                           END IF;
                                           IF l_all_occ_reval.adjustment_type = 'GENERAL FUND' THEN
                                                 l_detail_balances_retire.general_fund_acc       := l_detail_balances_retire.general_fund_acc - l_retire_amount;
                                                 l_detail_balances_retire.reval_reserve_gen_fund := l_detail_balances_retire.reval_reserve_gen_fund - l_retire_amount;
                                           END IF;
                                           IF l_all_occ_reval.adjustment_type = 'REVAL RESERVE' THEN
                                               l_detail_balances_retire.reval_reserve_net      := l_detail_balances_retire.reval_reserve_net - l_retire_amount;
                                           END IF;
                                           IF l_all_occ_reval.adjustment_type = 'COST' AND l_all_occ_reval.adjustment_offset_type='OP EXPENSE'  THEN
                                                 l_detail_balances_retire.operating_acct_cost:=l_detail_balances_retire.operating_acct_cost + l_retire_amount;
                                           END IF;
                                           IF l_all_occ_reval.adjustment_type = 'BL RESERVE' AND l_all_occ_reval.adjustment_offset_type='OP EXPENSE'  THEN
                                                 l_detail_balances_retire.operating_acct_backlog :=l_detail_balances_retire.operating_acct_backlog - l_retire_amount;
                                           END IF;
                                           IF l_all_occ_reval.adjustment_type = 'OP EXPENSE' THEN
                                                 l_detail_balances_retire.operating_acct_net     :=l_detail_balances_retire.operating_acct_net - l_retire_amount;
                                          END IF;
                                          IF l_all_occ_reval.adjustment_type = 'RESERVE' THEN
                                                l_detail_balances_retire.deprn_reserve    :=   l_detail_balances_retire.deprn_reserve - l_retire_amount;
                                          END IF;
                                          IF l_all_occ_reval.adjustment_type = 'BL RESERVE' THEN
                                               l_detail_balances_retire.deprn_reserve_backlog  := l_detail_balances_retire.deprn_reserve_backlog - l_retire_amount;
                                          END IF;

                            END LOOP; -- adjustment reversal

                    /* Calculate new totals  */
                     l_detail_balances.adjustment_cost        := l_detail_balances.adjustment_cost        + l_detail_balances_retire.adjustment_cost;
                     l_detail_balances.reval_reserve_cost     := l_detail_balances.reval_reserve_cost     + l_detail_balances_retire.reval_reserve_cost;
                     l_detail_balances.deprn_reserve          := l_detail_balances.deprn_reserve          + l_detail_balances_retire.deprn_reserve ;
                     l_detail_balances.deprn_reserve_backlog  := l_detail_balances.deprn_reserve_backlog  + l_detail_balances_retire.deprn_reserve_backlog ;
                     l_detail_balances.reval_reserve_net      := l_detail_balances.reval_reserve_net      + l_detail_balances_retire.reval_reserve_net ;
                     l_detail_balances.deprn_period           := l_detail_balances.deprn_period           + l_detail_balances_retire.deprn_period;
                     l_detail_balances.general_fund_acc       := l_detail_balances.general_fund_acc       + l_detail_balances_retire.general_fund_acc;
                     l_detail_balances.general_fund_per       := l_detail_balances.general_fund_per       + l_detail_balances_retire.general_fund_per;
                     l_detail_balances.reval_reserve_gen_fund := l_detail_balances.reval_reserve_gen_fund + l_detail_balances_retire.reval_reserve_gen_fund;
                     l_detail_balances.operating_acct_backlog := l_detail_balances.operating_acct_backlog  + l_detail_balances_retire.operating_acct_backlog;
                     l_detail_balances.operating_acct_cost    :=l_detail_balances.operating_acct_cost     + l_detail_balances_retire.operating_acct_cost;
                     l_detail_balances.operating_acct_net     :=l_detail_balances.operating_acct_net      + l_detail_balances_retire.operating_acct_net ;
                     l_detail_balances.reval_reserve_backlog  := l_detail_balances.reval_reserve_backlog  + l_detail_balances_retire.reval_reserve_backlog;
                     l_detail_balances.deprn_ytd              := l_detail_balances.deprn_ytd              + l_detail_balances_retire.deprn_ytd;

                    l_detail_balances.net_book_value := l_detail_balances.adjustment_cost - l_detail_balances.deprn_reserve -l_detail_balances.deprn_reserve_backlog  ;

                    l_rowid := NULL ;
                     igi_iac_det_balances_pkg.insert_row(
                       	    	X_rowid                     => l_rowid ,
			     		        X_adjustment_id		        => l_retirement_adjustment_id ,
        					    X_asset_id		            => P_Asset_Id ,
	        				    X_distribution_id	        => l_detail_balances.distribution_id,
		        			    X_book_type_code	        => P_Book_Type_Code ,
			        		    X_period_counter	        => g_prd_rec.period_counter,
				        	    X_adjustment_cost	        => l_detail_balances.adjustment_cost ,
                                X_net_book_value	        => l_detail_balances.net_book_value,
        				        X_reval_reserve_cost	    => l_detail_balances.reval_reserve_cost,
		    			        X_reval_reserve_backlog     => l_detail_balances.reval_reserve_backlog,
    			    		    X_reval_reserve_gen_fund    => l_detail_balances.reval_reserve_gen_fund,
	    			    	    X_reval_reserve_net	        => l_detail_balances.reval_reserve_net,
                                X_operating_acct_cost	    => l_detail_balances.operating_acct_cost,
    		    			    X_operating_acct_backlog    => l_detail_balances.operating_acct_backlog,
	    		    		    X_operating_acct_net	    => l_detail_balances.operating_acct_net,
 		    		    	    X_operating_acct_ytd	    => l_detail_balances.operating_acct_ytd,
			    		        X_deprn_period		        => l_detail_balances.deprn_period,
 				    	        X_deprn_ytd		            => l_detail_balances.DEPRN_YTD,
                                X_deprn_reserve		        => l_detail_balances.deprn_reserve,
        					    X_deprn_reserve_backlog	    => l_detail_balances.deprn_reserve_backlog,
	        				    X_general_fund_per	        => l_detail_balances.general_fund_per,
		        			    X_general_fund_acc	        => l_detail_balances.general_fund_acc,
 			        		    X_last_reval_date	        => l_detail_balances.last_reval_date ,
				        	    X_current_reval_factor	    => l_detail_balances.current_reval_factor ,
                                X_cumulative_reval_factor   => l_detail_balances.cumulative_reval_factor ,
     					        X_active_flag		        => l_detail_balances.active_flag,
                                X_mode                      =>  'R') ;
                     	   debug( g_state_level,l_path_name,'end insert det bals for new dist');
                            debug( g_state_level,l_path_name,'REVALUATION  REVERSAL');
                            debug( g_state_level,l_path_name,'X_adjustment_id		   => '||l_retirement_adjustment_id );
    					    debug( g_state_level,l_path_name,'X_asset_id		       =>'|| P_Asset_Id );
    	        			debug( g_state_level,l_path_name,'X_distribution_id	       =>'|| l_detail_balances.distribution_id );
    	        			debug( g_state_level,l_path_name,'X_book_type_code	       =>'|| P_Book_Type_Code );
    	        			debug( g_state_level,l_path_name,'X_period_counter	       =>'|| g_prd_rec.period_counter);
    	        			debug( g_state_level,l_path_name,'X_adjustment_cost	       =>'|| l_detail_balances.adjustment_cost);
    	        			debug( g_state_level,l_path_name,'X_net_book_value	       =>'|| l_detail_balances.net_book_value);
    	        			debug( g_state_level,l_path_name,'X_reval_reserve_cost	   =>'|| l_detail_balances.reval_reserve_cost);
    	        			debug( g_state_level,l_path_name,'X_reval_reserve_backlog  =>'|| l_detail_balances.reval_reserve_backlog);
    	        			debug( g_state_level,l_path_name,'X_reval_reserve_gen_fund =>'|| l_detail_balances.reval_reserve_gen_fund);
      	        			debug( g_state_level,l_path_name,'X_reval_reserve_net	   =>'|| l_detail_balances.reval_reserve_net);
                            debug( g_state_level,l_path_name,'X_operating_acct_cost	   =>'|| l_detail_balances.operating_acct_cost);
                            debug( g_state_level,l_path_name,'X_operating_acct_backlog =>'|| l_detail_balances.operating_acct_backlog);
                            debug( g_state_level,l_path_name,'X_operating_acct_net	   =>'|| l_detail_balances.operating_acct_net);
                            debug( g_state_level,l_path_name,'X_operating_acct_ytd	   =>'|| l_detail_balances.operating_acct_ytd);
                            debug( g_state_level,l_path_name,'X_deprn_period		   =>'|| l_detail_balances.deprn_period);
                            debug( g_state_level,l_path_name,'X_deprn_ytd		       =>'|| l_detail_balances.deprn_ytd);
                            debug( g_state_level,l_path_name,'X_deprn_reserve		   =>'|| l_detail_balances.deprn_reserve);
                            debug( g_state_level,l_path_name,'X_deprn_reserve_backlog  =>'|| l_detail_balances.deprn_reserve_backlog);
                            debug( g_state_level,l_path_name,'X_general_fund_per	   =>'|| l_detail_balances.general_fund_per);
                            debug( g_state_level,l_path_name,'X_general_fund_acc	   =>'|| l_detail_balances.general_fund_acc);

                           -- insert into igi_iac_fa_deprn with the new adjustment_id
                           l_rowid:=NULL;
                           IGI_IAC_FA_DEPRN_PKG.Insert_Row(
                               x_rowid                => l_rowid,
                               x_book_type_code       => p_book_type_code,
                               x_asset_id             => p_asset_id,
                               x_period_counter       => g_prd_rec.period_counter,
                               x_adjustment_id        => l_retirement_adjustment_id,
                               x_distribution_id      => l_detail_balances.distribution_id,
                               x_deprn_period         => l_fa_deprn.deprn_period,
                               x_deprn_ytd            => l_fa_deprn.deprn_ytd,
                               x_deprn_reserve        => l_fa_deprn.deprn_reserve,
                               x_active_flag          => NULL,
                               x_mode                 => 'R');

                            debug(g_state_level,l_path_name,'Inserted FA deprn record for dist'||l_detail_balances.distribution_id );

          ELSE -- not impacted by retiretment -- active distribution

                           l_rowid := NULL ;
                           igi_iac_det_balances_pkg.insert_row(
                           		X_rowid                     => l_rowid ,
		    	     		    X_adjustment_id		        => l_retirement_adjustment_id ,
    		    			    X_asset_id		            => P_Asset_Id ,
	    		    		    X_distribution_id	        => l_detail_balances.distribution_id ,
		    		    	    X_book_type_code	        => P_Book_Type_Code ,
			    		        X_period_counter	        => g_prd_rec.period_counter,
    				    	    X_adjustment_cost	        => l_detail_balances.adjustment_cost ,
                                X_net_book_value	        => l_detail_balances.net_book_value,
            				    X_reval_reserve_cost	    => l_detail_balances.reval_reserve_cost,
	    	    			    X_reval_reserve_backlog     => l_detail_balances.reval_reserve_backlog,
			        		    X_reval_reserve_gen_fund    => l_detail_balances.reval_reserve_gen_fund,
			    	    	    X_reval_reserve_net	        => l_detail_balances.reval_reserve_net,
                                X_operating_acct_cost	    => l_detail_balances.operating_acct_cost,
    					        X_operating_acct_backlog    => l_detail_balances.operating_acct_backlog,
	    				        X_operating_acct_net	    => l_detail_balances.operating_acct_net,
     		    			    X_operating_acct_ytd	    => l_detail_balances.operating_acct_ytd,
			    		        X_deprn_period		        => l_detail_balances.deprn_period,
 				    	        X_deprn_ytd		            => l_detail_balances.deprn_ytd,
                                X_deprn_reserve		        => l_detail_balances.deprn_reserve,
        					    X_deprn_reserve_backlog	    => l_detail_balances.deprn_reserve_backlog,
	        				    X_general_fund_per	        => l_detail_balances.general_fund_per,
		        			    X_general_fund_acc	        => l_detail_balances.general_fund_acc,
 			        		    X_last_reval_date	        => l_detail_balances.last_reval_date ,
				        	    X_current_reval_factor	    => l_detail_balances.current_reval_factor ,
                                X_cumulative_reval_factor   => l_detail_balances.cumulative_reval_factor ,
     					        X_active_flag		        => l_detail_balances.active_flag,
                                X_mode                      =>  'R') ;



                 	   debug( g_state_level,l_path_name,'end insert det bals..not impacted distribution');
                       -- insert into igi_iac_fa_deprn with the reinstatement adjustment_id
                           l_rowid:=NULL;
                           IGI_IAC_FA_DEPRN_PKG.Insert_Row(
                           x_rowid                => l_rowid,
                           x_book_type_code       => p_book_type_code,
                           x_asset_id             => p_asset_id,
                           x_period_counter       => g_prd_rec.period_counter,
                           x_adjustment_id        => l_retirement_adjustment_id,
                           x_distribution_id      => l_fa_deprn.distribution_id,
                           x_deprn_period         => l_fa_deprn.deprn_period,
                           x_deprn_ytd            => l_fa_deprn.deprn_ytd,
                           x_deprn_reserve        => l_fa_deprn.deprn_reserve,
                           x_active_flag          => NULL,
                           x_mode                 => 'R' );

            END IF; -- impacted distribution
            CLOSE c_get_impacted_dist;
       ELSE  -- Inactive distributions IF active_flag is not NULL.  i.e. following code for active_flag = 'N'

         	      debug( g_state_level,l_path_name,'Inactive distributions');
                  l_rowid := NULL ;
                  igi_iac_det_balances_pkg.insert_row(
                       		X_rowid                     => l_rowid ,
			     		    X_adjustment_id		        => l_retirement_adjustment_id ,
    					    X_asset_id		            => P_Asset_Id,
	    				    X_distribution_id	        => l_detail_balances.distribution_id ,
		    			    X_book_type_code	        => P_Book_Type_Code ,
			    		    X_period_counter	        => g_prd_rec.period_counter,
				    	    X_adjustment_cost	        => l_detail_balances.adjustment_cost ,
                            X_net_book_value	        => l_detail_balances.net_book_value,
        				    X_reval_reserve_cost	    => l_detail_balances.reval_reserve_cost,
		    			    X_reval_reserve_backlog     => l_detail_balances.reval_reserve_backlog,
			    		    X_reval_reserve_gen_fund    => l_detail_balances.reval_reserve_gen_fund,
				    	    X_reval_reserve_net	        => l_detail_balances.reval_reserve_net,
                            X_operating_acct_cost	    => l_detail_balances.operating_acct_cost,
    					    X_operating_acct_backlog    => l_detail_balances.operating_acct_backlog,
	    				    X_operating_acct_net	    => l_detail_balances.operating_acct_net,
 		    			    X_operating_acct_ytd	    => l_detail_balances.operating_acct_ytd,
			    		    X_deprn_period		        => l_detail_balances.deprn_period,
 				    	    X_deprn_ytd		            => l_detail_balances.deprn_ytd,
                            X_deprn_reserve		        => l_detail_balances.deprn_reserve,
    					    X_deprn_reserve_backlog	    => l_detail_balances.deprn_reserve_backlog,
	    				    X_general_fund_per	        => l_detail_balances.general_fund_per,
		    			    X_general_fund_acc	        => l_detail_balances.general_fund_acc,
 			    		    X_last_reval_date	        => l_detail_balances.last_reval_date ,
				    	    X_current_reval_factor	    => l_detail_balances.current_reval_factor ,
                            X_cumulative_reval_factor   => l_detail_balances.cumulative_reval_factor ,
     					    X_active_flag		        => l_detail_balances.active_flag ,
                            X_mode                      =>  'R') ;

                    l_rowid := NULL ;
                    IGI_IAC_FA_DEPRN_PKG.Insert_Row(
                           x_rowid                => g_rowid,
                           x_book_type_code       => p_book_type_code,
                           x_asset_id             => p_asset_id,
                           x_period_counter       => g_prd_rec.period_counter,
                           x_adjustment_id        => l_retirement_adjustment_id,
                           x_distribution_id      => l_fa_deprn.distribution_id,
                           x_deprn_period         => l_fa_deprn.deprn_period,
                           x_deprn_ytd            => l_fa_deprn.deprn_ytd,
                           x_deprn_reserve        => l_fa_deprn.deprn_reserve,
                           x_active_flag          => l_fa_deprn.active_flag,
                           x_mode                 => 'R');
                END IF ;   -- if active_flag is not  Null
           END LOOP ; -- det balances
                debug( g_state_level,l_path_name,'End of Revaluations');
                l_adjustment_id_out     :=l_retirement_adjustment_id;
                l_last_active_adj_id    :=l_retirement_adjustment_id;
       ELSE  -- no revalautions
                debug( g_state_level,l_path_name,'No Revaluations');
                NULL;
        END IF; --end revaluaionts
        CLOSE C_check_revaluations;
       -- End revaluation

       -- start deprecaition reversal
        debug( g_state_level,l_path_name,'Start of Depreciation');
        OPEN c_check_depreciations(P_asset_id,p_book_type_code,
                                  p_prior_period,p_current_period);
        FETCH c_check_depreciations INTO l_check_depreciations;
        IF c_check_depreciations%FOUND THEN -- revlautions found in betweem
            l_path_name :=l_path_name ||'.Deprn'  ;
               --- create a new transaction header for Revlaution retirement
            l_rowid:=NULL;
            l_retirement_adjustment_id :=NULL;
            igi_iac_trans_headers_pkg.insert_row(
	                       	    X_rowid		            => l_rowid ,
                        		X_adjustment_id	        => l_retirement_adjustment_id ,
                        		X_transaction_header_id => g_retire_rec.detail_info.transaction_header_id_in,
                        		X_adjustment_id_out	    => NULL ,
                        		X_transaction_type_code => 'DEPRECIATION',
                        		X_transaction_date_entered => g_fa_trx.transaction_date_entered,
                        		X_mass_refrence_id	    => g_fa_trx.mass_reference_id ,
                        		X_transaction_sub_type	=> 'RETIREMENT',
                        		X_book_type_code	    => P_Book_Type_Code,
                        		X_asset_id		        => p_asset_id ,
                        		X_category_id		    => g_asset_category_id,
                        		X_adj_deprn_start_date	=> NULL,
                        		X_revaluation_type_flag => NULL,
                        		X_adjustment_status	    => 'COMPLETE' ,
                        		X_period_counter	    => P_Current_period,
                                X_mode                  =>'R',
                                X_event_id              => P_Event_Id) ;

            debug( g_state_level, l_path_name,'inserted trans_headers record');

            igi_iac_trans_headers_pkg.update_row(l_adjustment_id_out,
                                                 l_retirement_adjustment_id,
                                                 'R') ;
            --l_adjustment_id_out     :=l_retirement_adjustment_id;
            ---l_last_active_adj_id    :=l_retirement_adjustment_id;

            debug( g_state_level,l_path_name,'updated old trans_headers record');

            --get all adjustments for occasional revaluation between current period and
            -- retire period
             FOR l_detail_balances IN c_detail_balances(l_last_active_adj_id) LOOP

                OPEN c_fa_deprn( l_detail_balances.adjustment_id,
                                 l_detail_balances.distribution_id,
                                 l_detail_balances.period_counter);
                FETCH c_fa_deprn INTO l_fa_deprn;
                IF c_fa_deprn%NOTFOUND THEN
                     CLOSE c_fa_deprn;
                     RETURN FALSE;
                END IF;
                CLOSE c_fa_deprn;

                IF l_detail_balances.active_flag IS NULL THEN -- Active distributions
                 	   debug( g_state_level,l_path_name,'inside loop');

            	     debug( g_state_level,l_path_name,'Detail balances loop: active record dist id  '|| l_detail_balances.distribution_id);

                     -- find the impacted distribution because of the partial unit retirement
                     OPEN c_get_impacted_dist(P_Asset_Id,P_Retirement_Id,l_detail_balances.distribution_id);
                     FETCH c_get_impacted_dist INTO l_impact_fa_dist;
                     IF c_get_impacted_dist%FOUND THEN -- impacted by partial nit retirement
                            --CLOSE c_get_impacted_dist;
                            --- distribtion impacted by partial unkit retirement
                             l_detail_balances_retire.adjustment_cost        :=0 ;
                             l_detail_balances_retire.reval_reserve_cost     :=0 ;
                             l_detail_balances_retire.deprn_reserve          :=0 ;
                             l_detail_balances_retire.deprn_reserve_backlog  :=0 ;
                             l_detail_balances_retire.reval_reserve_net      :=0 ;
                             l_detail_balances_retire.deprn_period           :=0 ;
                             l_detail_balances_retire.general_fund_acc       :=0 ;
                             l_detail_balances_retire.general_fund_per       :=0 ;
                             l_detail_balances_retire.reval_reserve_gen_fund :=0 ;
                             l_detail_balances_retire.operating_acct_backlog :=0;
                             l_detail_balances_retire.operating_acct_cost    :=0;
                             l_detail_balances_retire.operating_acct_net     :=0;
                             l_detail_balances_retire.reval_reserve_backlog  :=0;
                             l_detail_balances_retire.deprn_ytd              :=0;

                           -- get the impacted new distribution create for the retire distribution
                            l_retirement_factor := 1;
                            IF l_impact_fa_dist.transaction_units <> l_impact_fa_dist.units_assigned THEN

                            OPEN  c_get_new_dist(P_Asset_Id,P_Retirement_Id,l_impact_fa_dist.code_combination_id,
                                                ABS(l_impact_fa_dist.units_assigned + l_impact_fa_dist.transaction_units),l_impact_fa_dist.location_id,
                                                  NVL(l_impact_fa_dist.assigned_to,-1));
                  	         FETCH C_get_new_dist INTO l_new_fa_dist;
                              IF C_get_new_dist%FOUND THEN
                                   l_retirement_factor := - NVL(l_impact_fa_dist.transaction_units,0)/ l_impact_fa_dist.units_assigned;
                                   l_units_per_dist.units_assigned :=l_new_fa_dist.units_assigned;
                              END IF;
                              CLOSE C_get_new_dist;
                            END IF;



                             -- get the impact of the distribution --  new distribution created



                             FOR l_all_prd_reval IN  c_get_all_prd_reval(p_asset_id,p_book_type_code,
                                                                         P_prior_period,
                                                                         p_current_period,
                                                                         l_detail_balances.distribution_id ) LOOP

                                  l_retire_amount:=l_all_prd_reval.amount;
                                  --l_ret:= igi_iac_common_utils.iac_round(l_retire_amount,P_Book_Type_Code);
                                  l_rowid := NULL ;
                                  igi_iac_adjustments_pkg.insert_row(
		     		                     	    X_rowid                 => l_rowid ,
                                                X_adjustment_id         => l_retirement_adjustment_id ,
                                                X_book_type_code		=> P_Book_Type_Code ,
                                                X_code_combination_id	=> l_all_prd_reval.code_combination_id,
                                                X_set_of_books_id		=> g_sob_id ,
                                                X_dr_cr_flag            => 'DR',
                                                X_amount               	=> l_all_prd_reval.amount,
                                                X_adjustment_type      	=> l_all_prd_reval.adjustment_type,
                                                X_transfer_to_gl_flag  	=> 'Y',
                                                X_units_assigned		=> l_all_prd_reval.units_assigned ,
                                                X_asset_id		        => p_Asset_Id ,
                                                X_distribution_id      	=> l_detail_balances.distribution_id ,
                                                X_period_counter       	=> g_prd_rec.period_counter,
                                                X_adjustment_offset_type =>l_all_prd_reval.adjustment_offset_type,
                                                X_report_ccid        	=> l_all_prd_reval.report_ccid,
                                                X_mode                  => 'R',
                                                X_event_id              => P_Event_Id   ) ;

                                   debug( g_state_level,l_path_name,'adjustment type '|| l_all_prd_reval.adjustment_type);
                                   debug( g_state_level,l_path_name,'amount '         || l_all_prd_reval.amount);
                                   debug( g_state_level,l_path_name,'distribution  '  || l_all_prd_reval.distribution_id);


                                    IF  l_retirement_factor <> 1 THEN

                                            l_retire_amount:=l_all_prd_reval.amount * l_retirement_factor ;
					    do_round(l_retire_amount,P_Book_Type_Code);
                                            l_ret:= igi_iac_common_utils.iac_round(l_retire_amount,P_Book_Type_Code);

                                            l_rowid := NULL ;
                                            igi_iac_adjustments_pkg.insert_row(
		                     		         	    X_rowid                 => l_rowid ,
                                                    X_adjustment_id         => l_retirement_adjustment_id ,
                                                    X_book_type_code		=> P_Book_Type_Code ,
                                                    X_code_combination_id	=> l_all_prd_reval.code_combination_id,
                                                    X_set_of_books_id		=> g_sob_id ,
                                                    X_dr_cr_flag            => 'CR',
                                                    X_amount               	=> l_retire_amount,
                                                    X_adjustment_type      	=> l_all_prd_reval.adjustment_type,
                                                    X_transfer_to_gl_flag  	=> 'Y',
                                                    X_units_assigned		=> l_new_fa_dist.units_assigned ,
                                                    X_asset_id		        => p_Asset_Id ,
                                                    X_distribution_id      	=> l_new_fa_dist.distribution_id ,
                                                    X_period_counter       	=> g_prd_rec.period_counter,
                                                    X_adjustment_offset_type =>l_all_prd_reval.adjustment_offset_type,
                                                    X_report_ccid        	=> l_all_prd_reval.report_ccid,
                                                    X_mode                  => 'R',
                                                    X_event_id              => P_Event_Id   ) ;
                                                   debug( g_state_level,l_path_name,'adjustment type '|| l_all_prd_reval.adjustment_type);
                                                   debug( g_state_level,l_path_name,'amount '         || l_retire_amount);
                                                   debug( g_state_level,l_path_name,'distribution  '  || l_new_fa_dist.distribution_id);

                                           END IF;

                                           IF l_all_prd_reval.adjustment_type = 'COST' THEN
                                                l_detail_balances_retire.adjustment_cost:=l_detail_balances_retire.adjustment_cost + l_retire_amount;
                                           END IF;
                                           IF l_all_prd_reval.adjustment_type = 'COST' AND l_all_occ_reval.adjustment_offset_type='REVAL RESERVE'  THEN
                                                 l_detail_balances_retire.reval_reserve_cost:= l_detail_balances_retire.reval_reserve_cost + l_retire_amount;
                                           END IF;
                                           IF l_all_prd_reval.adjustment_type = 'BL RESERVE' AND l_all_occ_reval.adjustment_offset_type='REVAL RESERVE'  THEN
                                                 l_detail_balances_retire.reval_reserve_backlog  := l_detail_balances_retire.reval_reserve_backlog - l_retire_amount;
                                           END IF;
                                           IF l_all_prd_reval.adjustment_type = 'GENERAL FUND' THEN
                                                 l_detail_balances_retire.general_fund_acc       := l_detail_balances_retire.general_fund_acc - l_retire_amount;
                                                 l_detail_balances_retire.reval_reserve_gen_fund := l_detail_balances_retire.reval_reserve_gen_fund - l_retire_amount;
                                           END IF;
                                           IF l_all_prd_reval.adjustment_type = 'REVAL RESERVE' THEN
                                               l_detail_balances_retire.reval_reserve_net      := l_detail_balances_retire.reval_reserve_net - l_retire_amount;
                                           END IF;
                                           IF l_all_prd_reval.adjustment_type = 'COST' AND l_all_occ_reval.adjustment_offset_type='OP EXPENSE'  THEN
                                                 l_detail_balances_retire.operating_acct_cost:=l_detail_balances_retire.operating_acct_cost + l_retire_amount;
                                           END IF;
                                           IF l_all_prd_reval.adjustment_type = 'BL RESERVE' AND l_all_occ_reval.adjustment_offset_type='OP EXPENSE'  THEN
                                                 l_detail_balances_retire.operating_acct_backlog :=l_detail_balances_retire.operating_acct_backlog - l_retire_amount;
                                           END IF;
                                           IF l_all_prd_reval.adjustment_type = 'OP EXPENSE' THEN
                                                 l_detail_balances_retire.operating_acct_net     :=l_detail_balances_retire.operating_acct_net - l_retire_amount;
                                          END IF;
                                          IF l_all_prd_reval.adjustment_type = 'RESERVE' THEN
                                                l_detail_balances_retire.deprn_reserve    :=   l_detail_balances_retire.deprn_reserve - l_retire_amount;
                                          END IF;
                                          IF l_all_prd_reval.adjustment_type = 'BL RESERVE' THEN
                                               l_detail_balances_retire.deprn_reserve_backlog  := l_detail_balances_retire.deprn_reserve_backlog - l_retire_amount;
                                          END IF;

                    END LOOP; -- adjustment reversal
       /* Calculate new totals  */
                     l_detail_balances.adjustment_cost        := l_detail_balances.adjustment_cost        + l_detail_balances_retire.adjustment_cost;
                     l_detail_balances.reval_reserve_cost     := l_detail_balances.reval_reserve_cost     + l_detail_balances_retire.reval_reserve_cost;
                     l_detail_balances.deprn_reserve          := l_detail_balances.deprn_reserve          + l_detail_balances_retire.deprn_reserve ;
                     l_detail_balances.deprn_reserve_backlog  := l_detail_balances.deprn_reserve_backlog  + l_detail_balances_retire.deprn_reserve_backlog ;
                     l_detail_balances.reval_reserve_net      := l_detail_balances.reval_reserve_net      + l_detail_balances_retire.reval_reserve_net ;
                     l_detail_balances.deprn_period           := l_detail_balances.deprn_period           + l_detail_balances_retire.deprn_period;
                     l_detail_balances.general_fund_acc       := l_detail_balances.general_fund_acc       + l_detail_balances_retire.general_fund_acc;
                     l_detail_balances.general_fund_per       := l_detail_balances.general_fund_per       + l_detail_balances_retire.general_fund_per;
                     l_detail_balances.reval_reserve_gen_fund := l_detail_balances.reval_reserve_gen_fund + l_detail_balances_retire.reval_reserve_gen_fund;
                     l_detail_balances.operating_acct_backlog := l_detail_balances.operating_acct_backlog  + l_detail_balances_retire.operating_acct_backlog;
                     l_detail_balances.operating_acct_cost    :=l_detail_balances.operating_acct_cost     + l_detail_balances_retire.operating_acct_cost;
                     l_detail_balances.operating_acct_net     :=l_detail_balances.operating_acct_net      + l_detail_balances_retire.operating_acct_net ;
                     l_detail_balances.reval_reserve_backlog  := l_detail_balances.reval_reserve_backlog  + l_detail_balances_retire.reval_reserve_backlog;
                     l_detail_balances.deprn_ytd              := l_detail_balances.deprn_ytd              + l_detail_balances_retire.deprn_ytd;

                    l_detail_balances.net_book_value := l_detail_balances.adjustment_cost - l_detail_balances.deprn_reserve -l_detail_balances.deprn_reserve_backlog  ;

                    l_rowid := NULL ;
                     igi_iac_det_balances_pkg.insert_row(
                       	    	X_rowid                     => l_rowid ,
			     		        X_adjustment_id		        => l_retirement_adjustment_id ,
        					    X_asset_id		            => P_Asset_Id ,
	        				    X_distribution_id	        => l_detail_balances.distribution_id,
		        			    X_book_type_code	        => P_Book_Type_Code ,
			        		    X_period_counter	        => g_prd_rec.period_counter,
				        	    X_adjustment_cost	        => l_detail_balances.adjustment_cost ,
                                X_net_book_value	        => l_detail_balances.net_book_value,
        				        X_reval_reserve_cost	    => l_detail_balances.reval_reserve_cost,
		    			        X_reval_reserve_backlog     => l_detail_balances.reval_reserve_backlog,
    			    		    X_reval_reserve_gen_fund    => l_detail_balances.reval_reserve_gen_fund,
	    			    	    X_reval_reserve_net	        => l_detail_balances.reval_reserve_net,
                                X_operating_acct_cost	    => l_detail_balances.operating_acct_cost,
    		    			    X_operating_acct_backlog    => l_detail_balances.operating_acct_backlog,
	    		    		    X_operating_acct_net	    => l_detail_balances.operating_acct_net,
 		    		    	    X_operating_acct_ytd	    => l_detail_balances.operating_acct_ytd,
			    		        X_deprn_period		        => l_detail_balances.deprn_period,
 				    	        X_deprn_ytd		            => l_detail_balances.DEPRN_YTD,
                                X_deprn_reserve		        => l_detail_balances.deprn_reserve,
        					    X_deprn_reserve_backlog	    => l_detail_balances.deprn_reserve_backlog,
	        				    X_general_fund_per	        => l_detail_balances.general_fund_per,
		        			    X_general_fund_acc	        => l_detail_balances.general_fund_acc,
 			        		    X_last_reval_date	        => l_detail_balances.last_reval_date ,
				        	    X_current_reval_factor	    => l_detail_balances.current_reval_factor ,
                                X_cumulative_reval_factor   => l_detail_balances.cumulative_reval_factor ,
     					        X_active_flag		        => l_detail_balances.active_flag,
                                X_mode                      =>  'R') ;
                     	   debug( g_state_level,l_path_name,'end insert det bals for new dist');
                            debug( g_state_level,l_path_name,'DEPREVALUATION  REVERSAL');
                            debug( g_state_level,l_path_name,'X_adjustment_id		   => '||l_retirement_adjustment_id );
    					    debug( g_state_level,l_path_name,'X_asset_id		       =>'|| P_Asset_Id );
    	        			debug( g_state_level,l_path_name,'X_distribution_id	       =>'|| l_detail_balances.distribution_id );
    	        			debug( g_state_level,l_path_name,'X_book_type_code	       =>'|| P_Book_Type_Code );
    	        			debug( g_state_level,l_path_name,'X_period_counter	       =>'|| g_prd_rec.period_counter);
    	        			debug( g_state_level,l_path_name,'X_adjustment_cost	       =>'|| l_detail_balances.adjustment_cost);
    	        			debug( g_state_level,l_path_name,'X_net_book_value	       =>'|| l_detail_balances.net_book_value);
    	        			debug( g_state_level,l_path_name,'X_reval_reserve_cost	   =>'|| l_detail_balances.reval_reserve_cost);
    	        			debug( g_state_level,l_path_name,'X_reval_reserve_backlog  =>'|| l_detail_balances.reval_reserve_backlog);
    	        			debug( g_state_level,l_path_name,'X_reval_reserve_gen_fund =>'|| l_detail_balances.reval_reserve_gen_fund);
      	        			debug( g_state_level,l_path_name,'X_reval_reserve_net	   =>'|| l_detail_balances.reval_reserve_net);
                            debug( g_state_level,l_path_name,'X_operating_acct_cost	   =>'|| l_detail_balances.operating_acct_cost);
                            debug( g_state_level,l_path_name,'X_operating_acct_backlog =>'|| l_detail_balances.operating_acct_backlog);
                            debug( g_state_level,l_path_name,'X_operating_acct_net	   =>'|| l_detail_balances.operating_acct_net);
                            debug( g_state_level,l_path_name,'X_operating_acct_ytd	   =>'|| l_detail_balances.operating_acct_ytd);
                            debug( g_state_level,l_path_name,'X_deprn_period		   =>'|| l_detail_balances.deprn_period);
                            debug( g_state_level,l_path_name,'X_deprn_ytd		       =>'|| l_detail_balances.deprn_ytd);
                            debug( g_state_level,l_path_name,'X_deprn_reserve		   =>'|| l_detail_balances.deprn_reserve);
                            debug( g_state_level,l_path_name,'X_deprn_reserve_backlog  =>'|| l_detail_balances.deprn_reserve_backlog);
                            debug( g_state_level,l_path_name,'X_general_fund_per	   =>'|| l_detail_balances.general_fund_per);
                            debug( g_state_level,l_path_name,'X_general_fund_acc	   =>'|| l_detail_balances.general_fund_acc);
                            debug( g_state_level,l_path_name,'X_last_reval_date	       =>'|| l_detail_balances.last_reval_date );
                            debug( g_state_level,l_path_name,'X_current_reval_factor   =>'|| l_detail_balances.current_reval_factor );
                            debug( g_state_level,l_path_name,'X_cumulative_reval_factor=>'|| l_detail_balances.cumulative_reval_factor );
                            debug( g_state_level,l_path_name,'X_active_flag		       =>'|| l_detail_balances.active_flag);

                           -- insert into igi_iac_fa_deprn with the reinstatement adjustment_id
                           l_rowid:=NULL;
                           IGI_IAC_FA_DEPRN_PKG.Insert_Row(
                               x_rowid                => l_rowid,
                               x_book_type_code       => p_book_type_code,
                               x_asset_id             => p_asset_id,
                               x_period_counter       => g_prd_rec.period_counter,
                               x_adjustment_id        => l_retirement_adjustment_id,
                               x_distribution_id      => l_detail_balances.distribution_id,
                               x_deprn_period         => l_fa_deprn.deprn_period,
                               x_deprn_ytd            => l_fa_deprn.deprn_ytd,
                               x_deprn_reserve        => l_fa_deprn.deprn_reserve,
                               x_active_flag          => NULL,
                               x_mode                 => 'R');
          ELSE -- not impacted by retiretment -- active distribution

                           l_rowid := NULL ;
                           igi_iac_det_balances_pkg.insert_row(
                           		X_rowid                     => l_rowid ,
		    	     		    X_adjustment_id		        => l_retirement_adjustment_id ,
    		    			    X_asset_id		            => P_Asset_Id ,
	    		    		    X_distribution_id	        => l_detail_balances.distribution_id ,
		    		    	    X_book_type_code	        => P_Book_Type_Code ,
			    		        X_period_counter	        => g_prd_rec.period_counter,
    				    	    X_adjustment_cost	        => l_detail_balances.adjustment_cost ,
                                X_net_book_value	        => l_detail_balances.net_book_value,
            				    X_reval_reserve_cost	    => l_detail_balances.reval_reserve_cost,
	    	    			    X_reval_reserve_backlog     => l_detail_balances.reval_reserve_backlog,
			        		    X_reval_reserve_gen_fund    => l_detail_balances.reval_reserve_gen_fund,
			    	    	    X_reval_reserve_net	        => l_detail_balances.reval_reserve_net,
                                X_operating_acct_cost	    => l_detail_balances.operating_acct_cost,
    					        X_operating_acct_backlog    => l_detail_balances.operating_acct_backlog,
	    				        X_operating_acct_net	    => l_detail_balances.operating_acct_net,
     		    			    X_operating_acct_ytd	    => l_detail_balances.operating_acct_ytd,
			    		        X_deprn_period		        => l_detail_balances.deprn_period,
 				    	        X_deprn_ytd		            => l_detail_balances.deprn_ytd,
                                X_deprn_reserve		        => l_detail_balances.deprn_reserve,
        					    X_deprn_reserve_backlog	    => l_detail_balances.deprn_reserve_backlog,
	        				    X_general_fund_per	        => l_detail_balances.general_fund_per,
		        			    X_general_fund_acc	        => l_detail_balances.general_fund_acc,
 			        		    X_last_reval_date	        => l_detail_balances.last_reval_date ,
				        	    X_current_reval_factor	    => l_detail_balances.current_reval_factor ,
                                X_cumulative_reval_factor   => l_detail_balances.cumulative_reval_factor ,
     					        X_active_flag		        => l_detail_balances.active_flag,
                                X_mode                      =>  'R') ;



                 	   debug( g_state_level,l_path_name,'end insert det bals');
                       -- insert into igi_iac_fa_deprn with the reinstatement adjustment_id
                       l_rowid:=NULL;
                   IGI_IAC_FA_DEPRN_PKG.Insert_Row(
                           x_rowid                => l_rowid,
                           x_book_type_code       => p_book_type_code,
                           x_asset_id             => p_asset_id,
                           x_period_counter       => g_prd_rec.period_counter,
                           x_adjustment_id        => l_retirement_adjustment_id,
                           x_distribution_id      => l_fa_deprn.distribution_id,
                           x_deprn_period         => l_fa_deprn.deprn_period,
                           x_deprn_ytd            => l_fa_deprn.deprn_ytd,
                           x_deprn_reserve        => l_fa_deprn.deprn_reserve,
                           x_active_flag          => NULL,
                           x_mode                 => 'R' );

            END IF; -- impacted distribution
            CLOSE c_get_impacted_dist;
          ELSE  -- Inactive distributions IF active_flag is not NULL.  i.e. following code for active_flag = 'N'

         	      debug( g_state_level,l_path_name,'Inactive distributions');
                  l_rowid := NULL ;
                  igi_iac_det_balances_pkg.insert_row(
                       		X_rowid                     => l_rowid ,
			     		    X_adjustment_id		        => l_retirement_adjustment_id ,
    					    X_asset_id		            => P_Asset_Id,
	    				    X_distribution_id	        => l_detail_balances.distribution_id ,
		    			    X_book_type_code	        => P_Book_Type_Code ,
			    		    X_period_counter	        => g_prd_rec.period_counter,
				    	    X_adjustment_cost	        => l_detail_balances.adjustment_cost ,
                            X_net_book_value	        => l_detail_balances.net_book_value,
        				    X_reval_reserve_cost	    => l_detail_balances.reval_reserve_cost,
		    			    X_reval_reserve_backlog     => l_detail_balances.reval_reserve_backlog,
			    		    X_reval_reserve_gen_fund    => l_detail_balances.reval_reserve_gen_fund,
				    	    X_reval_reserve_net	        => l_detail_balances.reval_reserve_net,
                            X_operating_acct_cost	    => l_detail_balances.operating_acct_cost,
    					    X_operating_acct_backlog    => l_detail_balances.operating_acct_backlog,
	    				    X_operating_acct_net	    => l_detail_balances.operating_acct_net,
 		    			    X_operating_acct_ytd	    => l_detail_balances.operating_acct_ytd,
			    		    X_deprn_period		        => l_detail_balances.deprn_period,
 				    	    X_deprn_ytd		            => l_detail_balances.deprn_ytd,
                            X_deprn_reserve		        => l_detail_balances.deprn_reserve,
    					    X_deprn_reserve_backlog	    => l_detail_balances.deprn_reserve_backlog,
	    				    X_general_fund_per	        => l_detail_balances.general_fund_per,
		    			    X_general_fund_acc	        => l_detail_balances.general_fund_acc,
 			    		    X_last_reval_date	        => l_detail_balances.last_reval_date ,
				    	    X_current_reval_factor	    => l_detail_balances.current_reval_factor ,
                            X_cumulative_reval_factor   => l_detail_balances.cumulative_reval_factor ,
     					    X_active_flag		        => l_detail_balances.active_flag ,
                            X_mode                      =>  'R') ;

                    l_rowid := NULL ;
                    IGI_IAC_FA_DEPRN_PKG.Insert_Row(
                           x_rowid                => g_rowid,
                           x_book_type_code       => p_book_type_code,
                           x_asset_id             => p_asset_id,
                           x_period_counter       => g_prd_rec.period_counter,
                           x_adjustment_id        => l_retirement_adjustment_id,
                           x_distribution_id      => l_fa_deprn.distribution_id,
                           x_deprn_period         => l_fa_deprn.deprn_period,
                           x_deprn_ytd            => l_fa_deprn.deprn_ytd,
                           x_deprn_reserve        => l_fa_deprn.deprn_reserve,
                           x_active_flag          => l_fa_deprn.active_flag,
                           x_mode                 => 'R'
                                      );
                END IF ;   -- if active_flag is not  Null

           END LOOP ; -- det balances
             debug( g_state_level,l_path_name,'End of Depreciation');
       ELSE  -- no deprecaitions
             debug( g_state_level,l_path_name,'No Depreciations');
             NULL;
        END IF; --end deprecaitions
        CLOSE C_check_depreciations;
       -- end reversal
       debug( g_state_level,l_path_name,'Prior unit sucess');
       RETURN TRUE;

 EXCEPTION
  WHEN OTHERS  THEN
    debug( g_state_level,l_path_name,'Error in Processing Prior Unit Retirement');
    FA_SRVR_MSG.add_sql_error(Calling_Fn  => g_calling_fn);
    RETURN FALSE ;

END  Prior_Unit_Retirement;
--functions

FUNCTION Do_IAC_Retirement (
                              P_Asset_Id         IN NUMBER ,
                              P_Book_Type_Code   IN VARCHAR2 ,
                              P_Retirement_Id    IN NUMBER ,
                              P_Calling_Function IN VARCHAR2,
                              P_Event_Id         IN NUMBER ) --R12 uptake
RETURN BOOLEAN IS

         -- Sekhar
         -- Status for adjustments in a period
	l_asset_number  C_get_asset_number%rowtype;
        l_allowed_date  Date;
         FUNCTION Get_Adjustment_Status(
            X_book_type_code IN VARCHAR2,
            X_asset_id       IN NUMBER,
            X_Period_Counter IN NUMBER,
            X_allowed_date   OUT NOCOPY DATE )
         RETURN BOOLEAN IS

        Cursor c_get_prior_transactions(p_book_type_code varchar2, p_asset_id number,p_period_counter number)
	    is select MAX(period_counter)  period_counter
	    from igi_iac_transaction_headers
	    where asset_id = p_asset_id
	    and  book_type_code = p_book_type_code
	    and   period_counter >= p_period_counter
	    and not (transaction_type_code='DEPRECIATION' and transaction_sub_type is null)
	    and not (transaction_type_code='REVALUATION' and transaction_sub_type in ('OCCASSIONAL','PRFOESSIONAL'));


          l_asset_id  number;
	      l_prd_rec   igi_iac_types.prd_rec;
           l_iac_transaction c_get_prior_transactions%rowtype;


         BEGIN
            x_allowed_date :=Null;
            open c_get_prior_transactions( X_book_type_code,X_asset_id ,X_Period_Counter);
			fetch c_get_prior_transactions into l_iac_transaction;
			If l_iac_transaction.period_counter is not null  Then
				close c_get_prior_transactions;
				l_iac_transaction.period_counter := l_iac_transaction.period_counter + 1;
				IF not igi_iac_common_utils.get_period_info_for_counter(X_book_type_code,l_iac_transaction.period_counter
								     ,l_prd_rec) THEN
					Null;

				END iF;
				x_allowed_date := l_prd_rec.period_start_date;
                RETURN FALSE;

    		else

				close c_get_prior_transactions;
                RETURN TRUE;
			end  if;

         END Get_Adjustment_Status;


BEGIN

      	  g_path_name := g_path||'.Do_IAC_Retirement';

          IF NOT (igi_iac_common_utils.is_asset_proc(P_Book_Type_Code,P_Asset_Id)) THEN
                RAISE e_is_asset_proc ;
          END IF ;
          debug( g_state_level,g_path_name,'asset processed by IAC');

          -- if no entries exist for the book in the table
          IF NOT igi_iac_common_utils.populate_iac_fa_deprn_data(p_book_type_code,'RETIREMENT') THEN
          	debug( g_error_level,g_path_name,'Problems creating rows in igi_iac_fa_deprn');
            RAISE e_iac_fa_deprn;
          END IF;

          IF NOT (igi_iac_common_utils.get_open_period_info(P_Book_Type_Code,g_prd_rec)) THEN
             RAISE e_no_open_prd_info ;
          END IF ;
         debug( g_state_level,g_path_name,'got open period info');

         IF NOT igi_iac_common_utils.get_period_info_for_counter(p_book_type_code,g_prd_rec.period_counter,
                                                                 g_period_rec)  THEN
           	  debug( g_state_level,g_path_name,
	          'Could not retreive period information for the current period  '||g_prd_rec.period_counter);
               RETURN FALSE;
          END IF;



         g_retire_rec.retirement_id := p_retirement_id ;

         IF NOT (fa_util_pvt.get_asset_retire_rec(px_asset_retire_rec => g_retire_rec,
                                                  p_mrc_sob_type_code => NULL,
                                                  p_set_of_books_id => g_sob_id )) THEN
-- Bug 8762275 Added g_sob_id
            RAISE e_no_retire_rec ;
         END IF ;
         debug( g_state_level,g_path_name,'got retirement record');

         IF NOT (igi_iac_common_utils.get_period_info_for_date(P_Book_Type_Code,
                                                               g_retire_rec.date_retired,
                                                                g_retire_prd_rec )) THEN
             RAISE e_no_retire_period ;
         END IF ;
         debug( g_state_level, g_path_name,'got retirement period info');

 	If g_prd_rec.period_counter <> g_retire_prd_rec.period_counter THEN
                --- Check if adjustment has been processed in the prior  period
              IF NOT Get_Adjustment_Status(p_book_type_code,P_Asset_Id,g_retire_prd_rec.period_counter,l_allowed_date) THEN


                  -- gett the asset number for asset and call the error message
                      open  C_get_asset_number( P_Asset_Id);
                      fetch c_get_asset_number into l_asset_number;
                      Close C_get_asset_number;


                  FA_SRVR_MSG.Add_Message(
	                    Calling_FN 	=> p_calling_function ,
            	        Name 		=> 'IGI_IAC_OVERLAP_RETIRE',
        	            TOKEN1		=> 'NUMBER',
        	            VALUE1		=> l_asset_number.asset_number,
           	            TOKEN2		=> 'DATE',
        	            VALUE2		=> l_allowed_date,
        	            TRANSLATE => TRUE,
                        APPLICATION => 'IGI');
                   RETURN FALSE;

          END IF;
        END IF;

         g_prior_prd_count := g_prd_rec.period_counter - g_retire_prd_rec.period_counter ;

         IF NOT (igi_iac_common_utils.get_retirement_type(P_Book_Type_Code,
                                                           P_Asset_id,
                                                           P_Retirement_Id,
                                                           g_retirement_type)) THEN
                RAISE e_no_retire_type ;
         END IF ;
         debug( g_state_level,g_path_name,'got retirement type');

        IF g_prior_prd_count > 0    THEN
             g_retirement_period_type:='PRIOR';
             g_retirement_prior_period := g_retire_prd_rec.period_counter;
          ELSE
             g_retirement_period_type:='CURRENT';
             g_retirement_prior_period:= NULL;
         END IF;

         IF g_retirement_type = 'FULL' THEN
            g_ret_type_long := 'FULL RETIREMENT';
            ELSE
            g_ret_type_long := 'PARTIAL RETIRE';
          END IF ;

          g_retire_rec.retirement_id := p_retirement_id ;

          OPEN  c_fa_trx(g_retire_rec.detail_info.transaction_header_id_in) ;
          FETCH c_fa_trx INTO g_fa_trx ;
          IF    c_fa_trx%NOTFOUND THEN
              CLOSE c_fa_trx ;
              RAISE NO_DATA_FOUND ;
          END IF ;
          CLOSE c_fa_trx ;

          debug( g_state_level,g_path_name,'c_fa_trx OK');

          OPEN  c_fa_adds(P_Asset_Id) ;
          FETCH c_fa_adds INTO g_asset_category_id ;
          IF    c_fa_adds%NOTFOUND THEN
               CLOSE c_fa_adds ;
                RAISE NO_DATA_FOUND ;
         END IF ;
        CLOSE c_fa_adds ;

        debug( g_state_level,g_path_name,'c_fa_adds OK');

         g_rowid := NULL ;

            -- now find out NOCOPY if the period is the first period for the fiscal year
          IF (g_period_rec.period_num = 1) THEN
                 g_is_first_period := TRUE;
          ELSE
                 g_is_first_period := FALSE;
          END IF;


        IF NOT (igi_iac_common_utils.get_book_gl_info(P_Book_Type_Code,
                                                g_sob_id,
                                                g_coa_id,
                                                g_currency,
                                                g_precision
                                                )) THEN
             RAISE e_no_book_gl  ;
        END IF ;
        debug( g_state_level,g_path_name,'got gl book info');



        /*  Get total number of units for the asset  */
         OPEN  c_total_units(P_Asset_Id);
         FETCH c_total_units INTO g_total_asset_units ;
         IF    c_total_units%NOTFOUND THEN
		CLOSE c_total_units;
            RAISE e_no_units_info ;
         END IF ;
         CLOSE c_total_units ;


        IF g_retirement_type IN('FULL','COST') THEN

            -- get the reitement factor partial cost or retirement
            IF g_retirement_type <> 'FULL' THEN
                    IF NOT (igi_iac_common_utils.get_cost_retirement_factor(P_Book_Type_Code,
                                                                            P_Asset_Id,
                                                                            P_Retirement_Id,
                                                                            g_retirement_factor)) THEN
                           RAISE e_no_cost_retire ;
                    END IF ;
            ELSE
                      g_retirement_factor:=1;
            END IF;

     	    debug( g_state_level,g_path_name,'got cost retirement factor'||g_retirement_factor);
            IF g_prior_prd_count > 0  THEN
             -- call prior period processing for retirement
                IF NOT Prior_cost_retirement( P_Asset_Id                =>  p_asset_id    ,
                                              P_Book_Type_Code          => p_book_type_code ,
                                              P_Retirement_Id           => p_retirement_id ,
                                              P_retirement_type         => g_retirement_type ,
                                              p_retirement_factor       => g_retirement_factor,
                                              p_retirement_period_type  => g_retirement_period_type,
                                              P_prior_period            => g_retirement_prior_period,
                                              P_Current_period          => g_prd_rec.period_counter,
                                              P_Event_Id                => P_Event_Id ) THEN


                       debug( g_state_level,g_path_name,'Failed in prior period cost retirement ');
                       RETURN FALSE;
                END IF;

            END IF;
           -- call current period processing for retirement
                IF NOT cost_retirement(       P_Asset_Id                =>  p_asset_id    ,
                                              P_Book_Type_Code          => p_book_type_code ,
                                              P_Retirement_Id           => p_retirement_id ,
                                              P_retirement_type         => g_retirement_type ,
                                              p_retirement_factor       => g_retirement_factor,
                                              p_retirement_period_type  => g_retirement_period_type,
                                              P_prior_period            => g_retirement_prior_period,
                                              P_Current_period          => g_prd_rec.period_counter,
                                              P_Event_Id                => P_Event_Id) THEN


                       debug( g_state_level,g_path_name,'Failed in Current period cost retirement ');
                       RETURN FALSE;
                END IF;


        ELSE -- Partial Unit retirement
        -- call prior period processing for retirement
              IF g_prior_prd_count > 0  THEN
             -- call prior period processing for retirement
                IF NOT Prior_unit_retirement( P_Asset_Id                =>  p_asset_id    ,
                                              P_Book_Type_Code          => p_book_type_code ,
                                              P_Retirement_Id           => p_retirement_id ,
                                              P_retirement_type         => g_retirement_type ,
                                              p_retirement_period_type  => g_retirement_period_type,
                                              P_prior_period            => g_retirement_prior_period,
                                              P_Current_period          => g_prd_rec.period_counter,
                                              P_Event_Id                => P_Event_Id) THEN


                       debug( g_state_level,g_path_name,'Failed in prior period cost retirement ');
                       RETURN FALSE;
                END IF;

              END IF;
             -- call current period processing for retirement
              IF NOT Unit_retirement(       P_Asset_Id                =>  p_asset_id    ,
                                              P_Book_Type_Code          => p_book_type_code ,
                                              P_Retirement_Id           => p_retirement_id ,
                                              P_retirement_type         => g_retirement_type ,
                                              p_retirement_period_type  => g_retirement_period_type,
                                              P_prior_period            => g_retirement_prior_period,
                                              P_Current_period          => g_prd_rec.period_counter,
                                              P_Event_Id                => P_Event_Id ) THEN


                       debug( g_state_level,g_path_name,'Failed in prior period cost retirement ');
                       RETURN FALSE;
                END IF;

        END IF;

     debug( g_state_level,g_path_name,'IAC Retirement sucess ');
    -- RETURN FALSE ;
     RETURN TRUE ;
EXCEPTION
  WHEN e_is_asset_proc THEN
    debug( g_state_level,g_path_name,'IGI_IAC_NO_IAC_EFFECT');
    FA_SRVR_MSG.add_message(Calling_Fn    =>  g_calling_fn, Name=>'IGI_IAC_NO_IAC_EFFECT');
    RETURN TRUE  ;

  WHEN e_iac_fa_deprn THEN
    debug( g_state_level,g_path_name,'problems inserting rows into igi_iac_fa_deprn');
    FA_SRVR_MSG.add_message(Calling_Fn    =>  g_calling_fn,
                             Name          =>  'IGI_IAC_FA_DEPR_CREATE_PROB',
                             Token1        => 'BOOK',
                             Value1        => p_book_type_code);
    RETURN TRUE;

  WHEN e_no_open_prd_info THEN
    debug( g_state_level,g_path_name,'cannot get open period info');
    FA_SRVR_MSG.add_message(Calling_Fn    =>  g_calling_fn,Name=>'IGI_IAC_NO_PERIOD_INFO');
    RETURN FALSE ;

  WHEN e_no_retire_rec THEN
    debug( g_state_level,g_path_name,'cannot get retirement record');
    FA_SRVR_MSG.add_message(Calling_Fn    =>  g_calling_fn,Name=>  'IGI_IAC_NO_RETIRE_EFFECT');
    RETURN FALSE ;

  WHEN e_no_retire_type THEN
    debug( g_state_level,g_path_name,'cannot get retirement type');
    FA_SRVR_MSG.add_message(Calling_Fn    =>  g_calling_fn,Name=>  'IGI_IAC_INDEF_RETIRE_TYPE');
    RETURN FALSE ;

  WHEN e_no_book_gl THEN
    debug( g_state_level,g_path_name,'cannot get gl book info');
    RETURN FALSE ;

  WHEN e_no_cost_retire THEN
    debug( g_state_level,g_path_name,'no cost retirement ingo');
    FA_SRVR_MSG.add_message(Calling_Fn    =>  g_calling_fn,Name=>  'IGI_IAC_NO_COST_RETIRE_FACTOR');
    RETURN FALSE ;

  WHEN e_no_account_ccid THEN
    debug( g_state_level,g_path_name,'get_account_ccid failure');
    FA_SRVR_MSG.add_message(Calling_Fn    =>  g_calling_fn,Name=>'IGI_IAC_NO_WF_FAILED_CCID');
    RETURN FALSE ;

  WHEN e_no_units_info THEN
    debug( g_state_level,g_path_name,'no units info');
    FA_SRVR_MSG.add_message(Calling_Fn    =>  g_calling_fn,Name=>  'IGI_IAC_NO_UNITS_INFO');
    RETURN FALSE ;

  WHEN e_no_asset_bals THEN
     debug( g_state_level,g_path_name,'no asset balances');
        IF c_asset_balances%ISOPEN THEN
          CLOSE c_asset_balances ;
        END IF ;
    FA_SRVR_MSG.add_message(Calling_Fn    =>  g_calling_fn,Name=>  'IGI_IAC_NO_ASSET_BALS');
    RETURN FALSE ;

  WHEN OTHERS THEN
    igi_iac_debug_pkg.debug_unexpected_msg( g_path_name);
    -- close any open cursors
    IF c_asset_balances%ISOPEN THEN
      CLOSE c_asset_balances ;
    END IF ;
    IF c_fa_trx%ISOPEN THEN
      CLOSE c_fa_trx ;
    END IF ;
    IF c_fa_adds%ISOPEN THEN
      CLOSE c_fa_adds ;
    END IF ;
    IF c_units_per_dist%ISOPEN THEN
      CLOSE c_units_per_dist ;
    END IF ;
    FA_SRVR_MSG.add_SQL_error(Calling_Fn  => g_calling_fn);
    RETURN FALSE ;

END Do_IAC_Retirement ;



BEGIN

    g_calling_fn         := 'IGI_IAC_RETIREMENT.Do_IAC_Retirement';
    g_state_level 	     :=	FND_LOG.LEVEL_STATEMENT;
    g_proc_level  	     :=	FND_LOG.LEVEL_PROCEDURE;
    g_event_level 	     :=	FND_LOG.LEVEL_EVENT;
    g_excep_level 	     :=	FND_LOG.LEVEL_EXCEPTION;
    g_error_level 	     :=	FND_LOG.LEVEL_ERROR;
    g_unexp_level 	     :=	FND_LOG.LEVEL_UNEXPECTED;
    g_path                := 'IGI.PLSQL.igiiartb.igi_iac_retirement';


END igi_iac_retirement; --package spec

/
