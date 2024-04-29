--------------------------------------------------------
--  DDL for Package Body IGI_IAC_ROLLBACK_DEPRN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_ROLLBACK_DEPRN_PKG" as
/* $Header: igiacrdb.pls 120.1 2007/10/29 15:30:01 vkilambi noship $   */
--===========================FND_LOG.START=====================================

g_state_level NUMBER	  ;
g_proc_level  NUMBER	  ;
g_event_level NUMBER	  ;
g_excep_level NUMBER	  ;
g_error_level NUMBER	  ;
g_unexp_level NUMBER	  ;
g_path        VARCHAR2(1000) ;

--===========================FND_LOG.END=====================================


FUNCTION Do_Rollback_Deprn(
   p_asset_hdr_rec               fa_api_types.asset_hdr_rec_type,
   p_period_rec                  fa_api_types.period_rec_type,
   p_deprn_run_id                NUMBER,
   p_reversal_event_id           NUMBER,
   p_reversal_date               DATE,
   p_deprn_exists_count          NUMBER,
   p_calling_function            VARCHAR2
) return BOOLEAN is
begin
   --Need to Implement Event Reversal Login here
   --Need to Implement data backup (trf to history )table here
   --Need to Call Addition and Transfer Catchup rollback here
   --Need to Make Addition and Transfer Catchup rollback at asset level
   null;
end;

FUNCTION Do_Rollback_Addition(
       p_book_type_code                 VARCHAR2,
       p_period_counter                 NUMBER,
       p_calling_function               VARCHAR2
    ) return BOOLEAN IS
    CURSOR c_get_asset_add_info IS
    SELECT asset_id,adjustment_id,transaction_sub_type
    FROM igi_iac_transaction_headers
    WHERE book_type_code = p_book_type_code
    AND period_counter = p_period_counter
    AND transaction_type_code = 'ADDITION';
    CURSOR c_get_distributions(p_asset_id igi_iac_det_balances.asset_id%TYPE,
                                p_adjustment_id igi_iac_det_balances.adjustment_id%TYPE) IS
    SELECT distribution_id
    FROM igi_iac_det_balances
    WHERE book_type_code = p_book_type_code
    AND asset_id = p_asset_id;
    /* Bug 2425914 vgadde 21/06/2002 */
    /* Modified query to fecth records created by ADDITION only */
    CURSOR c_get_revaluation_info(p_asset_id igi_iac_det_balances.asset_id%TYPE) IS
    SELECT a.revaluation_id
    FROM igi_iac_revaluations r,igi_iac_reval_asset_rules a
    WHERE a.revaluation_id = r.revaluation_id
    AND a.book_type_code = p_book_type_code
    AND a.asset_id = p_asset_id
    AND r.calling_program = 'ADDITION';
    CURSOR c_get_adjustments(p_asset_id igi_iac_adjustments.asset_id%TYPE,
                            p_adjustment_id igi_iac_adjustments.adjustment_id%TYPE) IS
    SELECT 'X'
    FROM igi_iac_adjustments
    WHERE adjustment_id = p_adjustment_id
    AND book_type_code = p_book_type_code
    AND asset_id = p_asset_id
    AND rownum = 1;
    CURSOR c_get_asset_balances(p_asset_id igi_iac_asset_balances.asset_id%TYPE,
                                cp_period_counter igi_iac_asset_balances.period_counter%TYPE) IS
    SELECT 'X'
    FROM igi_iac_asset_balances
    WHERE book_type_code = p_book_type_code
    AND asset_id = p_asset_id
    AND period_counter = cp_period_counter;
    CURSOR c_get_revaluation_rates(p_asset_id igi_iac_revaluation_rates.asset_id%TYPE,
                            p_revaluation_id igi_iac_revaluation_rates.revaluation_id%TYPE) IS
    SELECT 'X'
    FROM igi_iac_revaluation_rates
    WHERE asset_id = p_asset_id
    AND book_type_code = p_book_type_code
    AND revaluation_id = p_revaluation_id;
    CURSOR c_get_fa_distributions(cp_asset_id igi_iac_det_balances.asset_id%TYPE,
                                cp_adjustment_id igi_iac_det_balances.adjustment_id%TYPE) IS
    SELECT distribution_id
    FROM igi_iac_fa_deprn
    WHERE book_type_code = p_book_type_code
    AND asset_id = cp_asset_id
    AND adjustment_id = cp_adjustment_id;
    l_revaluation_id    igi_iac_revaluations.revaluation_id%TYPE;
    l_dummy             VARCHAR2(1);
    l_path_name VARCHAR2(150) := g_path||'do_rollback_addition';
    BEGIN
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '********* Start of IAC Additions Rollback **********');
        FOR l_asset_info IN c_get_asset_add_info LOOP
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => ' Processing for Asset :'||to_char(l_asset_info.asset_id));
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => ' Adjustment           :'||to_char(l_asset_info.adjustment_id));
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => ' Transaction          :'||l_asset_info.transaction_sub_type);
            /* Delete records from igi_iac_adjustments */
            l_dummy := NULL;
            OPEN c_get_adjustments(l_asset_info.asset_id,l_asset_info.adjustment_id);
            FETCH c_get_adjustments INTO l_dummy;
            IF c_get_adjustments%FOUND THEN
  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			     p_full_path => l_path_name,
		    	     p_string => '     Deleting records from igi_iac_adjustments');
                igi_iac_adjustments_pkg.delete_row(
                        x_adjustment_id => l_asset_info.adjustment_id);
            ELSIF c_get_adjustments%NOTFOUND THEN
  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			     p_full_path => l_path_name,
		    	     p_string => '     No records found in igi_iac_adjustments for delete');
            END IF;
            CLOSE c_get_adjustments;
            /* Delete records from igi_iac_det_balances */
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '     Deleting records from igi_iac_det_balances');
            FOR l_det_balance IN c_get_distributions(l_asset_info.asset_id,
                                                    l_asset_info.adjustment_id) LOOP
                    igi_iac_det_balances_pkg.delete_row(
                        x_adjustment_id     => l_asset_info.adjustment_id,
                        x_asset_id          => l_asset_info.asset_id,
                        x_distribution_id   => l_det_balance.distribution_id,
                        x_book_type_code    => p_book_type_code,
                        x_period_counter    => p_period_counter);
            END LOOP;
            /* Delete records from igi_iac_fa_deprn */
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     Deleting records from igi_iac_fa_deprn');
            FOR l_iac_fa_det_balance IN c_get_fa_distributions(l_asset_info.asset_id,
                                                    l_asset_info.adjustment_id) LOOP
                    igi_iac_fa_deprn_pkg.delete_row(
                    	x_book_type_code    => p_book_type_code,
                        x_asset_id          => l_asset_info.asset_id,
                        x_period_counter    => p_period_counter,
                        x_adjustment_id     => l_asset_info.adjustment_id,
                        x_distribution_id   => l_iac_fa_det_balance.distribution_id);
            END LOOP;
            /* Delete records from igi_iac_asset_balances */
            IF l_asset_info.transaction_sub_type <> 'CATCHUP' THEN
                OPEN c_get_asset_balances(l_asset_info.asset_id,p_period_counter);
                FETCH c_get_asset_balances INTO l_dummy;
                IF c_get_asset_balances%FOUND THEN
  		    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '     Deleting records from igi_iac_asset_balances for current period');
                    igi_iac_asset_balances_pkg.delete_row(
                        x_asset_id          => l_asset_info.asset_id,
                        x_book_type_code    => p_book_type_code,
                        x_period_counter    => p_period_counter);
                ELSIF c_get_asset_balances%NOTFOUND THEN
  		    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '     No records found in igi_iac_asset_balances to delete');
                END IF;
                CLOSE c_get_asset_balances;
                OPEN c_get_asset_balances(l_asset_info.asset_id, p_period_counter+1);
                FETCH c_get_asset_balances INTO l_dummy;
                IF c_get_asset_balances%FOUND THEN
  		    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '     Deleting records from igi_iac_asset_balances for next period');
                    igi_iac_asset_balances_pkg.delete_row(
                        x_asset_id          => l_asset_info.asset_id,
                        x_book_type_code    => p_book_type_code,
                        x_period_counter    => p_period_counter+1);
                ELSE
  		    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '     No records found in igi_iac_asset_balances to delete');
                END IF;
                CLOSE c_get_asset_balances; -- Bug 2417394 this cursor was not gettign closed previously
            END IF;
            /* Delete records from igi_iac_transaction_headers */
  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '     Deleting records from igi_iac_transaction_headers');
                igi_iac_trans_headers_pkg.delete_row(
                        x_adjustment_id     => l_asset_info.adjustment_id);
            IF l_asset_info.transaction_sub_type <> 'CATCHUP' THEN
                l_revaluation_id := NULL;
                OPEN c_get_revaluation_info(l_asset_info.asset_id);
                FETCH c_get_revaluation_info INTO l_revaluation_id;
                CLOSE c_get_revaluation_info;
  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => ' Revaluation Id :'||to_char(l_revaluation_id));
                /* Delete records from igi_iac_reval_asset_rules */
                IF (l_revaluation_id IS NOT NULL) THEN
  		    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     			p_full_path => l_path_name,
		     			p_string => '     Deleting records from igi_iac_reval_asset_rules');
                    igi_iac_reval_asset_rules_pkg.delete_row(
                        x_asset_id          => l_asset_info.asset_id,
                        x_book_type_code    => p_book_type_code,
                        x_revaluation_id    => l_revaluation_id);
                    /* Delete records from igi_iac_revaluations */
  		    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     			p_full_path => l_path_name,
		     			p_string => '     Deleting records from igi_iac_revaluations');
                    igi_iac_revaluations_pkg.delete_row(
                        x_revaluation_id    => l_revaluation_id);
                    /* Delete records from igi_iac_revaluation_rates */
                    OPEN c_get_revaluation_rates(l_asset_info.asset_id,l_revaluation_id);
                    FETCH c_get_revaluation_rates INTO l_dummy;
                    IF c_get_revaluation_rates%FOUND THEN
  		        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     			p_full_path => l_path_name,
		     			p_string => '	    Deleting records from igi_iac_revaluation_rates');
                        DELETE FROM igi_iac_revaluation_rates
                        WHERE asset_id = l_asset_info.asset_id
                        AND book_type_code = p_book_type_code
                        AND revaluation_id = l_revaluation_id;
                    END IF;
                    CLOSE c_get_revaluation_rates;
                END IF;
            END IF;
        END LOOP;
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '********* End of IAC Additions Rollback **********');
        return TRUE;
        EXCEPTION
            WHEN OTHERS THEN
  		igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
                return FALSE;
    END Do_Rollback_Addition;

    	FUNCTION Do_Rollback_Transfer(
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
	END Do_rollback_Transfer;

BEGIN
 --===========================FND_LOG.START=====================================

    g_state_level :=	FND_LOG.LEVEL_STATEMENT;
    g_proc_level  :=	FND_LOG.LEVEL_PROCEDURE;
    g_event_level :=	FND_LOG.LEVEL_EVENT;
    g_excep_level :=	FND_LOG.LEVEL_EXCEPTION;
    g_error_level :=	FND_LOG.LEVEL_ERROR;
    g_unexp_level :=	FND_LOG.LEVEL_UNEXPECTED;
    g_path        := 'IGI.PLSQL.igiacrbb.igi_iac_rollback_deprn_pkg.';

--===========================FND_LOG.END=====================================

END IGI_IAC_ROLLBACK_DEPRN_PKG;


/
