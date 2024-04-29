--------------------------------------------------------
--  DDL for Package Body FA_C_INSURE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_C_INSURE" AS
/* $Header: faxinsub.pls 120.8.12010000.2 2009/07/19 10:29:15 glchen ship $ */

g_log_level_rec fa_api_types.log_level_rec_type;

PROCEDURE plsqlmsg     (p_msg                      IN            VARCHAR2);

PROCEDURE plsqlmsg_put (p_msg                      IN            VARCHAR2);

PROCEDURE Get_Period_Counters_Proc
                       (p_asset_book               IN            VARCHAR2,
                        p_year                     IN            VARCHAR2,
                        px_last_period_closed      IN OUT NOCOPY NUMBER,
                        px_last_period_closed_date IN OUT NOCOPY DATE,
                        px_year_date_start         IN OUT NOCOPY DATE,
                        px_year_counter_start      IN OUT NOCOPY NUMBER,
                        px_year_date_end           IN OUT NOCOPY DATE,
                        px_year_counter_end        IN OUT NOCOPY NUMBER,
                        px_year_effective_end      IN OUT NOCOPY DATE,
                        px_year_effective_start    IN OUT NOCOPY DATE,
                        px_year_prev_end_date      IN OUT NOCOPY DATE
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

PROCEDURE insert_values_record
                       (p_pol_asset_policy_id      IN            NUMBER,
                        px_indexation_id           IN OUT NOCOPY NUMBER,
                        p_pol_vendor_id            IN            NUMBER,
                        p_pol_policy_number        IN            VARCHAR2,
                        p_pol_asset_id             IN            NUMBER,
                        p_year                     IN            NUMBER,
                        p_last_period_closed_date  IN            DATE,
                        p_pol_price_index_id       IN            NUMBER,
                        p_pol_price_index_value    IN            NUMBER,
                        p_cal_insurance_value      IN            NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

PROCEDURE update_policies_record
                       (p_pol_asset_policy_id      IN            NUMBER,
                        p_pol_policy_number        IN            VARCHAR2,
                        p_pol_asset_id             IN            NUMBER,
                        p_cal_insurance_value      IN            NUMBER,
                        p_indexation_id            IN            NUMBER,
                        p_new_price_index_value    IN            NUMBER,
                        p_pol_retirement_value     IN            NUMBER,
                        p_last_period_closed_date  IN            DATE
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

PROCEDURE Get_New_Price_index_Proc
                       (p_pol_price_index_id       IN            NUMBER,
                        px_price_index_value       IN OUT NOCOPY NUMBER,
                        px_price_index_id          IN OUT NOCOPY NUMBER,
                        p_year_date_end            IN            DATE
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

PROCEDURE process_adjustments
                       (transaction_id                           NUMBER,
                        pol_asset_id                             NUMBER,
                        pol_policy_number                        VARCHAR2,
                        last_period_closed                       NUMBER,
                        last_period_closed_date                  DATE,
                        p_asset_book               IN            VARCHAR2,
                        p_year                     IN            VARCHAR2,
                        pol_calculation_method                   VARCHAR2,
                        px_pol_insurance_value     IN OUT NOCOPY NUMBER,
                        year_counter_end                         NUMBER,
                        pol_swiss_building                       VARCHAR2,
                        px_cal_insurance_value     IN OUT NOCOPY NUMBER,
                        pol_price_index_value                    NUMBER,
                        new_price_index_value                    NUMBER,
                        pol_base_index_year                      VARCHAR2,
                        pol_price_index_id                       NUMBER,
                        pol_base_index_date                      DATE,
                        px_cmv_null_flag           IN OUT NOCOPY VARCHAR2,
                        pol_indexation_date                      DATE,
			px_pol_retirement_value	   IN OUT NOCOPY NUMBER,
			pol_period_fully_reserved                NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

PROCEDURE process_retirements
                       (pol_asset_id                             NUMBER,
                        pol_policy_number                        VARCHAR2,
                        last_period_closed                       NUMBER,
                        last_period_closed_date                  DATE,
                        p_asset_book               IN            VARCHAR2,
                        p_year                     IN            VARCHAR2,
                        pol_calculation_method                   VARCHAR2,
                        px_pol_insurance_value     IN OUT NOCOPY NUMBER,
                        year_counter_end                         NUMBER,
                        pol_swiss_building                       VARCHAR2,
                        px_cal_insurance_value     IN OUT NOCOPY NUMBER,
                        pol_price_index_value                    NUMBER,
                        new_price_index_value                    NUMBER,
                        pol_base_index_year                      VARCHAR2,
                        pol_price_index_id                       NUMBER,
                        pol_base_index_date                      DATE,
                        px_cmv_null_flag           IN OUT NOCOPY VARCHAR2,
                        pol_indexation_date                      DATE,
                        transaction_type                         VARCHAR2,
                        bks_cost                                 NUMBER,
                        transaction_id                           NUMBER,
                        px_pol_retirement_value    IN OUT NOCOPY NUMBER,
                        px_reinstatement_ret_type  IN OUT NOCOPY VARCHAR2,
                        px_retirement_date         IN OUT NOCOPY DATE,
			px_reinstatement_without_ret
                                                   IN OUT NOCOPY VARCHAR2,
                        pol_period_fully_reserved                NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

PROCEDURE Get_base_index_value
                       (p_asset_book               IN            VARCHAR2,
                        pol_asset_id                             NUMBER,
                        pol_base_index_date                      DATE,
                        px_base_price_index_value  IN OUT NOCOPY NUMBER,
                        pol_price_index_id                       NUMBER,
                        px_base_price_index_id     IN OUT NOCOPY NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

PROCEDURE Calculate_Insurance_Value_Proc
                       (pol_asset_id                             NUMBER,
                        pol_policy_number                        VARCHAR2,
                        last_period_closed                       NUMBER,
                        last_period_closed_date                  DATE,
                        p_asset_book               IN            VARCHAR2,
                        p_year                     IN            VARCHAR2,
                        pol_calculation_method                   VARCHAR2,
                        px_pol_insurance_value     IN OUT NOCOPY NUMBER,
                        year_counter_end                         NUMBER,
                        pol_swiss_building                       VARCHAR2,
                        px_cal_insurance_value     IN OUT NOCOPY NUMBER,
                        pol_price_index_value                    NUMBER,
                        new_price_index_value                    NUMBER,
                        pol_base_index_year                      VARCHAR2,
                        pol_price_index_id                       NUMBER,
                        pol_base_index_date                      DATE,
                        px_cmv_null_flag           IN OUT NOCOPY VARCHAR2,
                        pol_indexation_date                      DATE,
                        px_pol_retirement_value    IN OUT NOCOPY NUMBER,
                        retirement_flag                          VARCHAR2,
                        pol_period_fully_reserved                NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

PROCEDURE insurance  (       Errbuf                  OUT NOCOPY VARCHAR2,
                        Retcode                 OUT NOCOPY NUMBER,
                        P_Asset_book            VARCHAR2,
                        P_Year                  VARCHAR2,
                        P_Ins_company_id        NUMBER,
                        P_Asset_start           VARCHAR2,
                        P_Asset_end             VARCHAR2) IS

year_date_start                         DATE;
year_date_end                           DATE;
year_counter_start                      NUMBER;
year_counter_end                        NUMBER;
last_period_closed                      NUMBER;
last_period_closed_date			DATE;
year_effective_end                      DATE;
year_effective_start                    DATE;
year_prev_end_date                      DATE;
c_request_id                            NUMBER(15);
c_appid                                 NUMBER(15);
c_program_id                            NUMBER(15);
c_user_id                               NUMBER(15);
pol_asset_number			VARCHAR2(15);
pol_asset_policy_id			NUMBER(18);
pol_vendor_id                           NUMBER(18);
pol_policy_number                       VARCHAR2(18);
pol_asset_id                            NUMBER;
pol_retirement_value				NUMBER;
pol_calculation_method                  VARCHAR2(30);
pol_last_indexation_id                  NUMBER;
pol_insurance_value                     NUMBER;
pol_swiss_indexation_date			DATE;
pol_indexation_year                     VARCHAR2(4);
pol_indexation_date                     DATE;
pol_day_after_indexation				DATE;
pol_indexation_record_type              VARCHAR2(2);
pol_price_index_id                      NUMBER;
pol_price_index_value                   NUMBER;
pol_base_index_year                     NUMBER;
pol_base_index_date                     DATE;
pol_swiss_building                      VARCHAR2(1);
new_price_index_value                   NUMBER;
new_price_index_id                      NUMBER;
price_index_value                       NUMBER;
price_index_id                          NUMBER;
base_price_index_value                  NUMBER;
base_price_index_id                     NUMBER;
cal_insurance_value                     NUMBER;
bks_cost		                       NUMBER;
transaction_date					DATE;
transaction_type					VARCHAR2(1);
retirement_adjustment_amount			NUMBER;
transaction_id					     NUMBER(15);
reinstatement_ret_type				VARCHAR2(1);
retirement_date					DATE;
cal_ret_reserve                         NUMBER;
cal_ret_type                            VARCHAR2(1);
indexation_id						NUMBER;
cmv_null_flag                           VARCHAR2(1);
asset_status						VARCHAR2(40);
msg                                     VARCHAR2(80);
process_policy_flag					VARCHAR2(1);
transactions_flag					VARCHAR2(1);
reinstatement_without_ret			VARCHAR2(1);
already_indexed					VARCHAR2(1);
pol_period_fully_reserved               NUMBER(15);


/* Cursor to select policy details entered via FA Insurance form - FAIS */

CURSOR Policy  (        P_Asset_start       VARCHAR2,
                        P_Asset_end         VARCHAR2,
                        P_Ins_company_id    NUMBER,
                        P_Asset_book        VARCHAR2,
                        year_date_end       DATE
                ) IS

        SELECT  pol.asset_policy_id,
		mpol.vendor_id,
                pol.policy_number,
                pol.asset_id,
		fad.asset_number,
			 pol.swiss_building,
                mpol.calculation_method,
                pol.last_indexation_id,
                TO_CHAR(pol.base_index_date,'YYYY') pol_base_index_year,
                pol.base_index_date,
                nvl(pol.current_insurance_value,
                        pol.base_insurance_value),
                pol.last_indexation_date,
			 pol.last_indexation_date + 1,
                pol.current_price_index_id,
			 pol.value_before_retirement,
			 nvl(pol.last_price_index_value,pii.price_index_value),
                bks.period_counter_fully_reserved
        FROM    fa_additions                    fad,
			 fa_books				bks,
                fa_ins_policies   pol,
		      fa_ins_mst_pols mpol,
                fa_price_index_values   pii
        WHERE   fad.asset_number BETWEEN NVL(p_asset_start, fad.asset_number)
                                        AND NVL(p_asset_end,fad.asset_number)
        AND     pol.asset_policy_id = mpol.asset_policy_id
	   AND     pol.asset_id = bks.asset_id
	   AND     bks.book_type_code = p_asset_book
	   AND	 bks.period_counter_fully_retired is null
	   AND     bks.date_ineffective is null
	   AND     bks.transaction_header_id_out is null
        AND     fad.asset_id = pol.asset_id
        AND     pol.book_type_code = p_asset_book
        AND     mpol.vendor_id = NVL(p_ins_company_id,mpol.vendor_id)
        AND     pii.price_index_id(+)  = pol.current_price_index_id
        AND     NVL(pol.last_indexation_date,pol.base_index_date)
                          BETWEEN pii.from_date(+) AND pii.to_date(+)
        ORDER BY pol.asset_id,pol.asset_policy_id
        FOR UPDATE OF pol.last_indexation_id, pol.current_insurance_value;

/* Cursor to select Reirement details */

CURSOR Get_Transactions (P_Asset_book	VARCHAR2,
				     pol_asset_id   NUMBER,
					pol_day_after_indexation DATE,
					last_period_closed_date DATE) IS

        SELECT  DECODE(fth.transaction_type_code,
					'PARTIAL RETIREMENT', 'P',
					'FULL RETIREMENT', 'F',
					'REINSTATEMENT', 'R', 'A'),
                fth.transaction_header_id,
			 fth.transaction_date_entered,
			 bks.cost
        FROM    fa_transaction_headers          fth,
                fa_books                        bks
        WHERE   bks.date_ineffective is not null
        AND     fth.transaction_date_entered BETWEEN
                    nvl(pol_day_after_indexation,fth.transaction_date_entered)
                    AND last_period_closed_date
        AND     bks.book_type_code = fth.book_type_code
        AND     bks.asset_id       = fth.asset_id
        AND     bks.asset_id       = pol_asset_id
        AND     fth.book_type_code =  p_asset_book
        AND     fth.transaction_header_id = bks.transaction_header_id_out
        AND     fth.transaction_type_code IN
                     ('FULL RETIREMENT','PARTIAL RETIREMENT', 'REINSTATEMENT',
                      'ADJUSTMENT', 'CIP ADJUSTMENT')
        ORDER BY fth.transaction_header_id;


/* Cursor to get details of any additions */

CURSOR Additions        (       p_asset_book    VARCHAR2,
                                pol_Asset_id   NUMBER,
                                pol_day_after_indexation DATE,
						  last_period_closed_date DATE
                         ) IS

     SELECT  DECODE(adj.DEBIT_CREDIT_FLAG ,
                               'CR', -1 * nvl(adj.adjustment_amount,0),
                NVL(adj.adjustment_amount,0))
        FROM    fa_adjustments          adj,
                fa_transaction_headers  fth,
                fa_books                bks
        WHERE   bks.date_ineffective is not null
        AND     fth.transaction_date_entered BETWEEN
                    nvl(pol_day_after_indexation,fth.transaction_date_entered)
                    AND last_period_closed_date
        AND     fth.transaction_header_id = adj.transaction_header_id
        AND     bks.transaction_header_id_out = fth.transaction_header_id
        AND     bks.book_type_code = fth.book_type_code
        AND     bks.asset_id       = fth.asset_id
        AND     bks.asset_id       = pol_asset_id
        AND     fth.book_type_code = p_asset_book
        AND     fth.transaction_type_code = 'ADJUSTMENT'
        AND     adj.source_type_code     =  'ADJUSTMENT'
        AND     adj.adjustment_type      =  'COST'
        AND     adj.book_type_code       = p_asset_book
        AND     adj.asset_id             = pol_asset_id;

	   current_loop			number := 0;
	   num_loops			number;
	   loop_pol_price_index_value 	number;
	   loop_new_price_index_value 	number;


BEGIN

plsqlmsg('Started : ' || to_char(sysdate,'HH:MI:SS'));
retcode := 0;


   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         Raise_Application_Error(-20000, 'log init failed');
      end if;
   end if;

Get_Period_Counters_Proc  	       ( P_Asset_book,
                                         P_year,
                                         last_period_closed,
					 			 last_period_closed_date,
                                         year_date_start,
                                         year_counter_start,
                                         year_date_end,
                                         year_counter_end,
                                         year_effective_end,
                                         year_effective_start,
                                         year_prev_end_date,
                                         g_log_level_rec
                                        );

--
-- start looping round the  asset policies
--


plsqlmsg('Running Indexation for ' || to_char(last_period_closed_date,'DD-MM-RRRR'));


OPEN    Policy  ( p_asset_start,
                  p_asset_end,
                  p_ins_company_id,
                  p_asset_book,
                  year_date_end
                );

LOOP

  asset_status := '';
  pol_price_index_id := NULL;
  new_price_index_id := NULL;
  new_price_index_value := NULL;
  pol_price_index_value := NULL;
  pol_retirement_value := NULL;
  retirement_adjustment_amount := NULL;
  retirement_date := NULL;
  process_policy_flag := 'Y';
  transactions_flag := 'Y';
  reinstatement_without_ret := 'N';
  already_indexed := 'N';


        FETCH   Policy
        INTO    pol_asset_policy_id,
		      pol_vendor_id,
                pol_policy_number,
                pol_asset_id,
			 pol_asset_number,
			 pol_swiss_building,
                pol_calculation_method,
                pol_last_indexation_id,
                pol_base_index_year,
                pol_base_index_date,
                pol_insurance_value,
                pol_indexation_date,
			 pol_day_after_indexation,
                pol_price_index_id,
			 pol_retirement_value,
                pol_price_index_value,
                pol_period_fully_reserved;

        IF policy%NOTFOUND and policy%rowcount = 0 THEN
           CLOSE Policy;
           Raise_Application_Error(-20000, 'ERROR: No Policy Information.');

        ELSIF policy%NOTFOUND THEN
		 EXIT;
        END IF;


        plsqlmsg_put ('Processing ' || rpad(pol_asset_number,19,' ' ) || rpad(pol_policy_number,18,' ') || '...');

        plsqlmsg(' ');


        IF pol_base_index_date > last_period_closed_date THEN

               asset_status := 'Index Date > Last Period Closed Date';
               process_policy_flag := 'N';

        ELSIF  pol_indexation_date = last_period_closed_date THEN
               process_policy_flag := 'N';
                asset_status := 'Already Indexed';

        ELSIF pol_base_index_date is null THEN

               asset_status := 'No Base Index Date';
               process_policy_flag := 'N';

        END IF;

        IF process_policy_flag = 'Y' THEN

           cmv_null_flag := 'N';

           Get_New_Price_index_Proc (pol_price_index_id,
                                     new_price_index_value,
                                     new_price_index_id,
                                     last_period_closed_date,
                                     g_log_level_rec);


	   IF pol_swiss_building = 'Y' AND
	      pol_base_index_date >= pol_indexation_date THEN

	       pol_day_after_indexation :=  pol_base_index_date + 1;

           END IF;


	   IF pol_calculation_method <> 'CMV' or
	     (pol_calculation_method = 'CMV' and pol_swiss_building = 'Y') THEN

		Select count(*)
		Into num_loops
        	FROM    fa_transaction_headers          fth,
                	fa_books                        bks
        	WHERE   bks.date_ineffective is not null
	        AND     fth.transaction_date_entered BETWEEN
                    nvl(pol_day_after_indexation,fth.transaction_date_entered)
                    AND last_period_closed_date
	        AND     bks.book_type_code = fth.book_type_code
	        AND     bks.asset_id       = fth.asset_id
	        AND     bks.asset_id       = pol_asset_id
	        AND     fth.book_type_code =  p_asset_book
	        AND     fth.transaction_header_id = bks.transaction_header_id_out
	        AND     fth.transaction_type_code IN
                     ('FULL RETIREMENT','PARTIAL RETIREMENT', 'REINSTATEMENT',
                      'ADJUSTMENT', 'CIP ADJUSTMENT');


               OPEN get_transactions (p_asset_book,
                             		   pol_asset_id,
                                      pol_day_after_indexation,
                                      last_period_closed_date);

               LOOP

		 transaction_type := NULL;
        	 transaction_id := NULL;
		 bks_cost       := NULL;
                 transaction_date := NULL;
		 current_loop := current_loop + 1;

                 FETCH  get_transactions
                 INTO   transaction_type,
		        transaction_id,
                        transaction_date,
                        bks_cost;

-- bug 5631765. Only apply the rate when all adjustments and retirements are looped through.

			if num_loops > current_loop then
			   loop_pol_price_index_value := 1;
			   loop_new_price_index_value := 1;
			else
			   loop_pol_price_index_value := pol_price_index_value;
			   loop_new_price_index_value := new_price_index_value;
			end if;
--

                  IF get_transactions%NOTFOUND THEN

			      transactions_flag := 'N';

				 IF get_transactions%rowcount = 0 THEN

  				    Calculate_Insurance_Value_Proc (pol_asset_id,
                                              pol_policy_number,
                                              last_period_closed,
                                              last_period_closed_date,
                                              P_Asset_book,
                                              P_Year,
                                              pol_calculation_method,
                                              pol_insurance_value,
                                              year_counter_end,
                                              pol_swiss_building,
                                              cal_insurance_value,
                                              pol_price_index_value,
                                              new_price_index_value,
                                              pol_base_index_year,
                                              pol_price_index_id,
                                              pol_base_index_date,
                                              cmv_null_flag,
                                              pol_indexation_date,
					      pol_retirement_value,
					      'N',
                                              pol_period_fully_reserved,
                                              g_log_level_rec);



                     		END IF;

                  ELSIF transaction_type IN ('P', 'R') THEN

			         process_retirements (pol_asset_id,
                               pol_policy_number ,
                               last_period_closed,
                               last_period_closed_date,
                               P_Asset_book,
                               P_Year,
                               pol_calculation_method,
                               pol_insurance_value,
                               year_counter_end,
                               pol_swiss_building,
                               cal_insurance_value,
                               loop_pol_price_index_value, --
                               loop_new_price_index_value, --
                               pol_base_index_year,
                               pol_price_index_id,
                               pol_base_index_date,
                               cmv_null_flag,
                               pol_indexation_date,
                               transaction_type,
						 bks_cost,
                               transaction_id,
                               pol_retirement_value,
                               reinstatement_ret_type,
                               retirement_date,
			       reinstatement_without_ret,
                               pol_period_fully_reserved,
                               g_log_level_rec);

                     ELSE

                         process_adjustments (transaction_id,
                               pol_asset_id,
                               pol_policy_number,
                               last_period_closed,
                               last_period_closed_date,
                               P_Asset_book,
                               P_Year,
                               pol_calculation_method,
                               pol_insurance_value,
                               year_counter_end,
                               pol_swiss_building,
                               cal_insurance_value,
                               loop_pol_price_index_value, --
                               loop_new_price_index_value, --
                               pol_base_index_year,
                               pol_price_index_id,
                               pol_base_index_date,
                               cmv_null_flag,
                               pol_indexation_date,
			       pol_retirement_value,
                               pol_period_fully_reserved,
                               g_log_level_rec);


                     END IF;

                     IF transactions_flag = 'N' or
				    reinstatement_without_ret = 'Y' THEN

			        EXIT;

                     END IF;

                  END LOOP;

                  CLOSE get_transactions;

              ELSE

                   Calculate_Insurance_Value_Proc (pol_asset_id,
					                     pol_policy_number,
                                              last_period_closed,
					    				 last_period_closed_date,
                                              P_Asset_book,
                                              P_Year,
			                      pol_calculation_method,
					      pol_insurance_value,
					      year_counter_end,
                                              pol_swiss_building,
                                              cal_insurance_value,
                                              pol_price_index_value,
                                              new_price_index_value,
                                              pol_base_index_year,
                                              pol_price_index_id,
                                              pol_base_index_date,
					      cmv_null_flag,
					      pol_indexation_date,
					      pol_retirement_value,
					      'N',
                                              pol_period_fully_reserved,
                                              g_log_level_rec);


             END IF;

 		   IF cmv_null_flag = 'N' and reinstatement_without_ret = 'N' THEN

		      asset_status := 'Indexed';


			 insert_values_record ( pol_asset_policy_id,
					               indexation_id,
                                        pol_vendor_id,
                                        pol_policy_number,
                                        pol_asset_id,
                                        p_year,
                                        last_period_closed_date,
                                        pol_price_index_id,
								pol_price_index_value,
                                        cal_insurance_value,
                                        g_log_level_rec);


			 update_policies_record (pol_asset_policy_id,
                                   pol_policy_number,
                                   pol_asset_id,
                                   cal_insurance_value,
                                   indexation_id,
                                   new_price_index_value,
                                   pol_retirement_value,
                                   last_period_closed_date,
                                   g_log_level_rec);

                 /* commenting this for bug fix 2051129 */
               -- COMMIT;

            ELSE

                IF reinstatement_without_ret = 'Y' THEN
			    asset_status := 'No Retirement to Reinstatement';
                ELSE
		         asset_status := 'Not Depreciated';
                END IF;

		  END IF;

        END IF;

      plsqlmsg(asset_status);

END LOOP;

/* adding this for bug fix 2051129 */
COMMIT;

CLOSE Policy;

 retcode := 0;

 plsqlmsg('Ended : ' || to_char(sysdate,'HH:MI:SS'));


END insurance;

PROCEDURE get_market_value
                       (pol_asset_id                             NUMBER,
                        last_period_closed                       NUMBER,
                        px_market_value            IN OUT NOCOPY NUMBER,
                        px_market_ytd_deprn        IN OUT NOCOPY NUMBER,
                        px_cmv_null_flag           IN OUT NOCOPY VARCHAR2,
                        pol_period_fully_reserved                NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

CURSOR Get_market_value (       pol_asset_id            NUMBER,
                                last_period_closed      NUMBER
                        ) IS
        SELECT  bks.cost- fdd.deprn_reserve,
                fdd.ytd_deprn
        FROM    fa_books                        bks,
                fa_deprn_summary         fdd
        WHERE   bks.book_type_code = fdd.book_type_code
        AND     bks.asset_id = fdd.asset_id
        AND     fdd.asset_id = pol_asset_id
        AND     fdd.deprn_source_code = 'DEPRN'
        AND     fdd.period_counter = last_period_closed
        AND     date_ineffective is null;

BEGIN

        OPEN    Get_Market_Value (pol_asset_id, last_period_closed);
        FETCH   get_market_value
        INTO    px_market_value,
                px_market_ytd_deprn;

       IF get_market_value%NOTFOUND and pol_period_fully_reserved IS NULL THEN

           px_cmv_null_flag := 'Y';

       ELSE

           px_cmv_null_flag := 'N';

       END IF;

END get_market_value;

PROCEDURE get_remaining_life
                       (p_asset_book               IN            VARCHAR2,
                        pol_asset_id                             NUMBER,
                        pol_indexation_date                      DATE,
                        px_asset_total_life        IN OUT NOCOPY NUMBER,
                        px_asset_remaining_life    IN OUT NOCOPY NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

CURSOR get_asset_life_details (p_asset_book VARCHAR2,
                               pol_asset_id NUMBER)
IS

    SELECT     bks.life_in_months   asset_total_life,
               bks.life_in_months -
                       floor(months_between(fdp.calendar_period_close_date,
                                        bks.date_placed_in_service))
                                        asset_remaining_life
   FROM        fa_books  bks,
               fa_deprn_periods fdp
   WHERE       bks.book_type_code = P_asset_book
   AND         fdp.book_type_code = P_asset_book
   AND         bks.book_type_code = fdp.book_type_code
   AND         bks.asset_id = pol_asset_id
   AND         bks.date_ineffective is null
   AND         fdp.period_close_date is null;


CURSOR get_last_indexation_tot_life (P_asset_book VARCHAR2,
                                                      pol_asset_id NUMBER,
                                                 pol_indexation_date DATE)
IS
/* 1 is added to the figure subtracted from the life_in_months to create a
remaining life at last indexation date that would equate to the remaining life
shown on the FA view transaction screen at that time */

    SELECT     (bks.life_in_months -
                       floor(months_between(fdp.calendar_period_close_date,
                                        bks.date_placed_in_service)+1))
   FROM        fa_books  bks,
               fa_deprn_periods fdp
   WHERE       bks.book_type_code = P_asset_book
   AND         fdp.book_type_code = P_asset_book
   AND         bks.asset_id = pol_asset_id
   AND         pol_indexation_date between
               fdp.calendar_period_open_date and fdp.calendar_period_close_date;


BEGIN


  OPEN get_asset_life_details (P_asset_book,
                               pol_asset_id);

  FETCH get_asset_life_details
  INTO px_asset_total_life,
       px_asset_remaining_life;

  CLOSE get_asset_life_details;

  IF pol_indexation_date is not NULL THEN

     OPEN get_last_indexation_tot_life (P_asset_book,
                                        pol_asset_id,
                                        pol_indexation_date
                                      );

     FETCH get_last_indexation_tot_life
  	INTO px_asset_total_life;

  	CLOSE get_last_indexation_tot_life;


  END IF;


END get_remaining_life;


PROCEDURE process_van  (pol_asset_id                             NUMBER,
                        last_period_closed                       NUMBER,
                        px_market_value            IN OUT NOCOPY NUMBER,
                        px_market_ytd_deprn        IN OUT NOCOPY NUMBER,
                        px_cmv_null_flag           IN OUT NOCOPY VARCHAR2,
                        px_cal_insurance_value     IN OUT NOCOPY NUMBER,
                        px_pol_insurance_value     IN OUT NOCOPY NUMBER,
                        new_price_index_value                    NUMBER,
                        pol_price_index_value                    NUMBER,
			px_pol_retirement_value    IN OUT NOCOPY NUMBER,
			retirement_flag                          VARCHAR2,
                        pol_period_fully_reserved                NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

BEGIN

/* Check market value purely to see if asset has been depreciated */

        Get_Market_Value (pol_asset_id, last_period_closed, px_market_value,
                          px_market_ytd_deprn, px_cmv_null_flag,
                          pol_period_fully_reserved,
                          p_log_level_rec);

        IF px_cmv_null_flag = 'N' THEN

	    IF retirement_flag = 'Y' THEN

	       px_pol_retirement_value := nvl(px_pol_insurance_value,0)/
                                          nvl(pol_price_index_value,1);
            END IF;

            px_cal_insurance_value := nvl(px_pol_insurance_value,0) *
                                (nvl(new_price_index_value,1)/
                                  nvl(pol_price_index_value,1)
                                  );

        END IF;
END process_van;

PROCEDURE process_cmv  (p_asset_book               IN            VARCHAR2,
                        pol_asset_id                             NUMBER,
                        last_period_closed                       NUMBER,
                        px_market_value            IN OUT NOCOPY NUMBER,
                        px_market_ytd_deprn        IN OUT NOCOPY NUMBER,
                        px_cmv_null_flag           IN OUT NOCOPY VARCHAR2,
                        px_cal_insurance_value     IN OUT NOCOPY NUMBER,
                        px_base_price_index_value  IN OUT NOCOPY NUMBER,
                        pol_price_index_id                       NUMBER,
                        px_base_price_index_id     IN OUT NOCOPY NUMBER,
                        pol_base_index_date                      DATE,
                        new_price_index_value                    NUMBER,
			px_pol_retirement_value    IN OUT NOCOPY NUMBER,
			retirement_flag                          VARCHAR2,
                        pol_period_fully_reserved                NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

BEGIN


        Get_Market_Value (pol_asset_id, last_period_closed, px_market_value,
                          px_market_ytd_deprn, px_cmv_null_flag,
                          pol_period_fully_reserved,
                          p_log_level_rec);

        IF px_cmv_null_flag = 'N' THEN

               Get_base_index_value (p_asset_book,
                                     pol_asset_id,
                                     pol_base_index_date,
                                     px_base_price_index_value,
                                     pol_price_index_id,
                                     px_base_price_index_id,
                                     p_log_level_rec
                                    );

               px_cal_insurance_value := nvl(px_market_value,0) *
                                (nvl(new_price_index_value,1)/
                                   nvl(px_base_price_index_value,1)
                                    );


         END IF;

END process_cmv;


PROCEDURE process_cmv_swiss
                       (p_asset_book               IN            VARCHAR2,
                        pol_asset_id                             NUMBER,
                        pol_indexation_date                      DATE,
                        last_period_closed_date                  DATE,
                        last_period_closed                       NUMBER,
                        px_market_value            IN OUT NOCOPY NUMBER,
                        px_market_ytd_deprn        IN OUT NOCOPY NUMBER,
                        px_cmv_null_flag           IN OUT NOCOPY VARCHAR2,
                        pol_insurance_value                      NUMBER,
                        px_cal_insurance_value     IN OUT NOCOPY NUMBER,
                        px_base_price_index_value  IN OUT NOCOPY NUMBER,
                        pol_price_index_id                       NUMBER,
                        pol_price_index_value                    NUMBER,
                        px_base_price_index_id     IN OUT NOCOPY NUMBER,
                        pol_base_index_date                      DATE,
                        new_price_index_value                    NUMBER,
 			px_pol_retirement_value    IN OUT NOCOPY NUMBER,
			retirement_flag                          VARCHAR2,
                        pol_period_fully_reserved                NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

asset_total_life                        NUMBER;
asset_remaining_life                    NUMBER;

BEGIN

	   get_remaining_life (P_Asset_book ,
                            pol_asset_id ,
                            pol_indexation_date ,
                            asset_total_life ,
                            asset_remaining_life ,
                            p_log_level_rec);

       if last_period_closed_date >= pol_base_index_date and
          pol_base_index_date >= pol_indexation_date THEN

               Get_base_index_value (p_asset_book,
                                     pol_asset_id,
                                     pol_base_index_date,
                                     px_base_price_index_value,
                                     pol_price_index_id,
                                     px_base_price_index_id,
                                     p_log_level_rec
                                    );

	   IF retirement_flag = 'Y' THEN
	      px_pol_retirement_value := nvl(pol_insurance_value,0) /
                   (nvl(px_base_price_index_value,1) * nvl(asset_total_life,1));
           END IF;

           px_cal_insurance_value := (nvl(pol_insurance_value,0) *
                                     (nvl(new_price_index_value,1)/
                                      nvl(px_base_price_index_value,1))) *
                                     (nvl(asset_remaining_life,0)/
                                      nvl(asset_total_life,1));

      ELSE

      IF retirement_flag = 'Y' THEN
	    px_pol_retirement_value := nvl(pol_insurance_value,0) /
                   (nvl(pol_price_index_value,1) * nvl(asset_total_life,1));
      END IF;

      px_cal_insurance_value := (nvl(pol_insurance_value,0) *
                                (nvl(new_price_index_value,1)/
                                 nvl(pol_price_index_value,1))) *
                                    (asset_remaining_life/asset_total_life);
   END IF;

END process_cmv_swiss;


PROCEDURE process_van_swiss
                       (p_asset_book               IN            VARCHAR2,
                        pol_asset_id                             NUMBER,
                        last_period_closed                       NUMBER,
                        px_market_value            IN OUT NOCOPY NUMBER,
                        px_market_ytd_deprn        IN OUT NOCOPY NUMBER,
                        px_cmv_null_flag           IN OUT NOCOPY VARCHAR2,
                        px_cal_insurance_value     IN OUT NOCOPY NUMBER,
                        px_pol_insurance_value     IN OUT NOCOPY NUMBER,
                        px_base_price_index_value  IN OUT NOCOPY NUMBER,
                        pol_price_index_id                       NUMBER,
                        px_base_price_index_id     IN OUT NOCOPY NUMBER,
                        new_price_index_value                    NUMBER,
                        pol_base_index_date                      DATE,
                        pol_price_index_value                    NUMBER,
			px_pol_retirement_value    IN OUT NOCOPY NUMBER,
			retirement_flag                          VARCHAR2,
                        pol_period_fully_reserved                NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

BEGIN

/* Check market value purely to see if asset has been depreciated */

        Get_Market_Value (pol_asset_id, last_period_closed, px_market_value,
                          px_market_ytd_deprn, px_cmv_null_flag,
                          pol_period_fully_reserved,
                          p_log_level_rec);

        IF px_cmv_null_flag = 'N' THEN

              Get_base_index_value (p_asset_book,
                                    pol_asset_id,
                                    pol_base_index_date,
                                    px_base_price_index_value,
                                    pol_price_index_id,
                                    px_base_price_index_id,
                                    p_log_level_rec);

               IF retirement_flag = 'Y' THEN
                  px_pol_retirement_value := nvl(px_pol_insurance_value,0) /
                                             nvl(px_base_price_index_value,1);
               END IF;

               px_cal_insurance_value := nvl(px_pol_insurance_value,0) *
                                        (nvl(new_price_index_value,1) /
                                         nvl(px_base_price_index_value,1));

        END IF;

END process_van_swiss;

PROCEDURE Get_Period_Counters_Proc
                    (p_asset_book               IN            VARCHAR2,
                     p_year                     IN            VARCHAR2,
                     px_last_period_closed      IN OUT NOCOPY NUMBER,
                     px_last_period_closed_date IN OUT NOCOPY DATE,
                     px_year_date_start         IN OUT NOCOPY DATE,
                     px_year_counter_start      IN OUT NOCOPY NUMBER,
                     px_year_date_end           IN OUT NOCOPY DATE,
                     px_year_counter_end        IN OUT NOCOPY NUMBER,
                     px_year_effective_end      IN OUT NOCOPY DATE,
                     px_year_effective_start    IN OUT NOCOPY DATE,
                     px_year_prev_end_date      IN OUT NOCOPY DATE
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS


CURSOR Get_Period_Counters      (       P_Asset_book    VARCHAR2,
                                        P_Year          VARCHAR2
                                 ) IS

        SELECT          fdp1.calendar_period_open_date,
                        fdp1.period_counter,
                        fdp2.calendar_period_close_date,
                        fdp2.period_counter,
                        fdp2.period_close_date,
                        fdp1.period_open_date,
                        fdp1.calendar_period_open_date - 1
        FROM            fa_Deprn_periods fdp1,
                        fa_Deprn_periods fdp2
        WHERE           fdp1.period_counter =
                                (SELECT   MIN(x.period_counter)
                                 FROM     fa_Deprn_periods x
                                 WHERE    x.fiscal_year = p_year
                                 AND      x.book_type_code = p_asset_book
                                )
       AND             fdp2.period_counter =
                                (SELECT   MAX(x.period_counter)
                                 FROM     fa_Deprn_periods x
                                 WHERE    x.fiscal_year = p_year
                                 AND      x.book_type_code = p_asset_book
                                )
        AND             fdp2.book_type_code = fdp1.book_type_code
        AND             fdp2.fiscal_year = fdp1.fiscal_year
        AND             fdp1.fiscal_year = p_year
        AND             fdp1.book_type_code = p_asset_book;


CURSOR  Get_Last_Period_Closed (    P_Asset_book   VARCHAR2,
                                    P_Year         VARCHAR2
                               ) IS
        SELECT      fdp1.CALENDAR_PERIOD_CLOSE_DATE,
               fdp1.period_counter
     FROM      fa_deprn_periods fdp1
     WHERE     fdp1.book_type_code = p_asset_book
     AND       fdp1.fiscal_year = p_year
     AND       fdp1.period_counter =
                    (SELECT   MAX(fdp.period_counter)
                     FROM     fa_deprn_periods fdp
                     WHERE    fdp.book_type_code = p_asset_book
                     AND      fdp.fiscal_year = p_year
                     AND      fdp.period_close_date IS NOT NULL
                    );


BEGIN

        OPEN            get_period_counters(p_asset_book, p_year);
        FETCH           get_period_counters
        INTO            px_year_date_start,
                        px_year_counter_start,
                        px_year_date_end,
                        px_year_counter_end,
                        px_year_effective_end,
                        px_year_effective_start,
                        px_year_prev_end_date;

        IF SQL%NOTFOUND THEN
           CLOSE        get_period_counters;
           raise_application_error(-20000, 'ERROR: Get Period Counters.');
        END IF;

        CLOSE           get_period_counters;

        OPEN            get_last_period_closed(p_asset_book, p_year);
        FETCH           get_last_period_closed
        INTO            px_last_period_closed_date,
                        px_last_period_closed;

        IF SQL%NOTFOUND THEN

           CLOSE        get_last_period_closed;
           raise_application_error(-20000, 'ERROR: Get Last Period Closed.');

        END IF;

        CLOSE        get_last_period_closed;

END Get_Period_Counters_Proc;


PROCEDURE Get_New_Price_index_Proc
                       (p_pol_price_index_id       IN            NUMBER,
                        px_price_index_value       IN OUT NOCOPY NUMBER,
                        px_price_index_id          IN OUT NOCOPY NUMBER,
                        p_year_date_end            IN            DATE
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

CURSOR Get_new_price_index (    pol_price_index_id      NUMBER,
                                year_date_end           DATE
                           ) IS

        SELECT  pii.price_index_id,
                pii.price_index_value
        FROM    fa_price_index_values    pii
        WHERE   pii.price_index_id = nvl(p_pol_price_index_id,0)
        AND     year_date_end BETWEEN pii.from_date AND pii.to_date;

CURSOR Get_last_price_index (pol_price_index_id NUMBER) IS
        SELECT  pii.price_index_id,
                pii.price_index_value
        FROM    fa_price_index_values    pii
        WHERE   pii.price_index_id = nvl(p_pol_price_index_id,0)
        AND     pii.to_date = (SELECT max(pii2.to_date)
                      FROM fa_price_index_values pii2
                      WHERE pii2.price_index_id = pii.price_index_id);

BEGIN

        OPEN get_new_price_index (p_pol_price_index_id , p_year_date_end);

        FETCH get_new_price_index
        INTO  px_price_index_id,
              px_price_index_value;

        IF get_new_price_index%NOTFOUND THEN

           OPEN get_last_price_index (p_pol_price_index_id);

           FETCH get_last_price_index
           INTO  px_price_index_id,
                 px_price_index_value;

           CLOSE get_last_price_index;

        END IF;

        CLOSE        get_new_price_index;


END Get_New_Price_index_Proc;


PROCEDURE Calculate_Insurance_Value_Proc
                       (pol_asset_id                             NUMBER,
                        pol_policy_number                        VARCHAR2,
                        last_period_closed                       NUMBER,
                        last_period_closed_date                  DATE,
                        p_asset_book               IN            VARCHAR2,
                        p_year                     IN            VARCHAR2,
                        pol_calculation_method                   VARCHAR2,
                        px_pol_insurance_value     IN OUT NOCOPY NUMBER,
                        year_counter_end                         NUMBER,
                        pol_swiss_building                       VARCHAR2,
                        px_cal_insurance_value     IN OUT NOCOPY NUMBER,
                        pol_price_index_value                    NUMBER,
                        new_price_index_value                    NUMBER,
                        pol_base_index_year                      VARCHAR2,
                        pol_price_index_id                       NUMBER,
                        pol_base_index_date                      DATE,
                        px_cmv_null_flag           IN OUT NOCOPY VARCHAR2,
                        pol_indexation_date                      DATE,
                        px_pol_retirement_value    IN OUT NOCOPY NUMBER,
                        retirement_flag                          VARCHAR2,
                        pol_period_fully_reserved                NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

market_value                            NUMBER;
market_ytd_deprn                        NUMBER;
base_price_index_value             NUMBER;
base_price_index_id           NUMBER;


BEGIN

  IF pol_calculation_method = 'CMV' THEN

     IF pol_swiss_building = 'Y' THEN

        process_cmv_swiss ( P_Asset_book,
                         pol_asset_id,
                         pol_indexation_date,
                         last_period_closed_date,
                        last_period_closed,
                        market_value,
                         market_ytd_deprn,
                         px_cmv_null_flag,
                         px_pol_insurance_value,
                         px_cal_insurance_value,
                         base_price_index_value,
                         pol_price_index_id,
                         pol_price_index_value,
                         base_price_index_id,
                         pol_base_index_date,
                         new_price_index_value,
		         px_pol_retirement_value,
			 retirement_flag,
                         pol_period_fully_reserved,
                         p_log_level_rec);

     ELSE

        process_cmv ( P_Asset_book,
                         pol_asset_id,
                        last_period_closed,
                        market_value,
                         market_ytd_deprn,
                         px_cmv_null_flag,
                         px_cal_insurance_value,
                         base_price_index_value,
                         pol_price_index_id,
                         base_price_index_id,
                         pol_base_index_date,
                         new_price_index_value,
			 px_pol_retirement_value,
			 retirement_flag,
                         pol_period_fully_reserved,
                         p_log_level_rec);

     END IF;

  ELSIF pol_calculation_method = 'VAN' and pol_swiss_building = 'Y' THEN

      IF pol_base_index_date > pol_indexation_date THEN

         process_van_swiss ( P_Asset_book,
                             pol_asset_id,
                        last_period_closed,
                        market_value,
                         market_ytd_deprn,
                         px_cmv_null_flag,
                         px_cal_insurance_value,
                         px_pol_insurance_value,
                         base_price_index_value,
                         pol_price_index_id,
                         base_price_index_id,
                         new_price_index_value,
                         pol_base_index_date,
                         pol_price_index_value,
		         px_pol_retirement_value,
		         retirement_flag,
                         pol_period_fully_reserved,
                         p_log_level_rec);
      ELSE

              process_van ( pol_asset_id,
                        last_period_closed,
                        market_value,
                         market_ytd_deprn,
                         px_cmv_null_flag,
                         px_cal_insurance_value,
                         px_pol_insurance_value,
                         new_price_index_value,
                         pol_price_index_value,
                         px_pol_retirement_value,
                         retirement_flag,
                         pol_period_fully_reserved,
                         p_log_level_rec);


      END IF;

  ELSIF (pol_calculation_method = 'MNL' AND
               pol_base_index_date <= last_period_closed_date)
               OR pol_calculation_method = 'VAN'  THEN

      process_van ( pol_asset_id,
                        last_period_closed,
                        market_value,
                         market_ytd_deprn,
                         px_cmv_null_flag,
                         px_cal_insurance_value,
                         px_pol_insurance_value,
                         new_price_index_value,
                         pol_price_index_value,
		         px_pol_retirement_value,
			 retirement_flag,
                         pol_period_fully_reserved,
                         p_log_level_rec);


   END IF;

END Calculate_Insurance_Value_Proc;


PROCEDURE process_adjustments
                       (transaction_id                           NUMBER,
                        pol_asset_id                             NUMBER,
                        pol_policy_number                        VARCHAR2,
                        last_period_closed                       NUMBER,
                        last_period_closed_date                  DATE,
                        p_asset_book               IN            VARCHAR2,
                        p_year                     IN            VARCHAR2,
                        pol_calculation_method                   VARCHAR2,
                        px_pol_insurance_value     IN OUT NOCOPY NUMBER,
                        year_counter_end                         NUMBER,
                        pol_swiss_building                       VARCHAR2,
                        px_cal_insurance_value     IN OUT NOCOPY NUMBER,
                        pol_price_index_value                    NUMBER,
                        new_price_index_value                    NUMBER,
                        pol_base_index_year                      VARCHAR2,
                        pol_price_index_id                       NUMBER,
                        pol_base_index_date                      DATE,
                        px_cmv_null_flag           IN OUT NOCOPY VARCHAR2,
                        pol_indexation_date                      DATE,
                        px_pol_retirement_value    IN OUT NOCOPY NUMBER,
                        pol_period_fully_reserved                NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

CURSOR Additions        (transaction_id NUMBER,
                         p_book_type_code VARCHAR2,
                         p_asset_id       NUMBER) IS

     SELECT     SUM(DECODE(adj.DEBIT_CREDIT_FLAG ,
                               'CR', -1 * nvl(adj.adjustment_amount,0),
                NVL(adj.adjustment_amount,0)))
        FROM    fa_adjustments          adj
        WHERE   adj.transaction_header_id = transaction_id
        AND     adj.source_type_code     =  'ADJUSTMENT'
        AND     adj.adjustment_type      =  'COST'
        AND     adj.book_type_code       =  p_book_type_code
        AND     adj.asset_id             =  p_asset_id;

addition_adjustment_amount NUMBER;

BEGIN

  OPEN additions (transaction_id, p_asset_book, pol_asset_id);

  FETCH Additions
  INTO addition_adjustment_amount;

  CLOSE additions;

-- bug 5631765. Placed it before call to calculate_insurance_value_proc
--              instead of after.
  px_cal_insurance_value := px_cal_insurance_value +
					 nvl(addition_adjustment_amount,0);

     Calculate_Insurance_Value_Proc (pol_asset_id,
                                              pol_policy_number,
                                              last_period_closed,
                                              last_period_closed_date,
                                              P_Asset_book,
                                              P_Year,
                                              pol_calculation_method,
                                              px_pol_insurance_value,
                                              year_counter_end,
                                              pol_swiss_building,
                                              px_cal_insurance_value,
                                              pol_price_index_value,
                                              new_price_index_value,
                                              pol_base_index_year,
                                              pol_price_index_id,
                                              pol_base_index_date,
                                              px_cmv_null_flag,
                                              pol_indexation_date,
					      px_pol_retirement_value,
					      'N',
                                              pol_period_fully_reserved,
                                              p_log_level_rec);


  px_pol_insurance_value := px_cal_insurance_value;

END process_adjustments;

PROCEDURE process_reinstatements(P_Asset_book VARCHAR2,
						   pol_asset_id NUMBER,
						   pol_indexation_date DATE,
						   pol_calculation_method VARCHAR2,
						   pol_swiss_building VARCHAR2,
						   pol_retirement_value NUMBER,
						   new_price_index_value NUMBER,
						   cal_insurance_value IN OUT NOCOPY NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS


asset_total_life                        NUMBER;
asset_remaining_life                    NUMBER;

BEGIN

IF pol_swiss_building = 'Y' THEN

   IF pol_calculation_method IN ('VAN', 'MNL') THEN

      /* pol_retirement_value would have been set to insurance_value / base_index_value
         when the asset was retired. Therefore to reinstate it - multiply by the
         current new index value */

      cal_insurance_value := pol_retirement_value * new_price_index_value;

   ELSE

      /* pol_retirement_value would have been set to (insurance_value / base_index_value)/
         remaining life at last indexation date when the asset was retired.
	    Therefore to reinstate it - multiply by the current new index value x Current
         remaing life */

      get_remaining_life (P_Asset_book ,
                          pol_asset_id ,
                          pol_indexation_date ,
                          asset_total_life ,
                          asset_remaining_life ,
                          p_log_level_rec);

      cal_insurance_value := pol_retirement_value *
                                 new_price_index_value * asset_remaining_life;

   END IF;

ELSE

      /* pol_retirement_value would have been set to insurance_value / base_index_value
         when the asset was retired. Therefore to reinstate it - multiply by the
         current new index value */

   cal_insurance_value := pol_retirement_value * new_price_index_value;

END IF;

END process_reinstatements;

PROCEDURE process_retirements
                       (pol_asset_id                             NUMBER,
                        pol_policy_number                        VARCHAR2,
                        last_period_closed                       NUMBER,
                        last_period_closed_date                  DATE,
                        p_asset_book               IN            VARCHAR2,
                        p_year                     IN            VARCHAR2,
                        pol_calculation_method                   VARCHAR2,
                        px_pol_insurance_value     IN OUT NOCOPY NUMBER,
                        year_counter_end                         NUMBER,
                        pol_swiss_building                       VARCHAR2,
                        px_cal_insurance_value     IN OUT NOCOPY NUMBER,
                        pol_price_index_value                    NUMBER,
                        new_price_index_value                    NUMBER,
                        pol_base_index_year                      VARCHAR2,
                        pol_price_index_id                       NUMBER,
                        pol_base_index_date                      DATE,
                        px_cmv_null_flag           IN OUT NOCOPY VARCHAR2,
                        pol_indexation_date                      DATE,
                        transaction_type                         VARCHAR2,
                        bks_cost                                 NUMBER,
                        transaction_id                           NUMBER,
                        px_pol_retirement_value    IN OUT NOCOPY NUMBER,
                        px_reinstatement_ret_type  IN OUT NOCOPY VARCHAR2,
                        px_retirement_date         IN OUT NOCOPY DATE,
                        px_reinstatement_without_ret
                                                   IN OUT NOCOPY VARCHAR2,
                        pol_period_fully_reserved                NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

Cursor retirements ( transaction_id NUMBER) IS

       SELECT  nvl(ret.cost_retired,0)
       FROM    fa_retirements                  ret
       WHERE   ret.transaction_header_id_in (+) = transaction_id
       ;

Cursor Get_reinstatement_Details ( transaction_id NUMBER) IS

       SELECT  DECODE(fth.transaction_type_code, 'FULL_RETIREMENT','F',
                                               'PARTIAL RETIREMENT','P','R'),
               nvl(ret.cost_retired,0),
			nvl(bks.cost,0)
       FROM    fa_retirements                  ret,
                fa_transaction_headers          fth,
			 fa_books					bks
       WHERE   ret.transaction_header_id_out = transaction_id
       AND     ret.transaction_header_id_in = fth.transaction_header_id
	  AND	bks.transaction_header_id_out = fth.transaction_header_id
       ;



cost_retired	NUMBER;
reinst_cost_retired NUMBER;
reinst_bks_cost NUMBER;

BEGIN

  OPEN retirements (transaction_id);

  FETCH retirements
  INTO  cost_retired;

  CLOSE retirements;

  IF transaction_type = 'R' THEN

     OPEN Get_reinstatement_details (transaction_id);

     FETCH Get_reinstatement_details
     INTO  px_reinstatement_ret_type,
           reinst_cost_retired,
           reinst_bks_cost;

     CLOSE Get_reinstatement_details;

     IF px_reinstatement_ret_type = 'P' THEN

	   IF px_pol_retirement_value = 1 THEN
              px_reinstatement_without_ret := 'Y';

           ELSE
	      process_reinstatements(p_asset_book,
                                 pol_asset_id,
                                 pol_indexation_date,
                                 pol_calculation_method,
                                 pol_swiss_building,
                                 px_pol_retirement_value,
                                 new_price_index_value,
                                 px_cal_insurance_value,
                                 p_log_level_rec);

        END IF;
     ELSE

        Calculate_Insurance_Value_Proc (pol_asset_id,
                                              pol_policy_number,
                                              last_period_closed,
                                              last_period_closed_date,
                                              P_Asset_book,
                                              P_Year,
                                              pol_calculation_method,
                                              px_pol_insurance_value,
                                              year_counter_end,
                                              pol_swiss_building,
                                              px_cal_insurance_value,
                                              pol_price_index_value,
                                              new_price_index_value,
                                              pol_base_index_year,
                                              pol_price_index_id,
                                              pol_base_index_date,
                                              px_cmv_null_flag,
                                              pol_indexation_date,
                                              px_pol_retirement_value,
                                              'N',
                                              pol_period_fully_reserved,
                                              p_log_level_rec);

     END IF;

  ELSE

        Calculate_Insurance_Value_Proc (pol_asset_id,
                                              pol_policy_number,
                                              last_period_closed,
                                              last_period_closed_date,
                                              P_Asset_book,
                                              P_Year,
                                              pol_calculation_method,
                                              px_pol_insurance_value,
                                              year_counter_end,
                                              pol_swiss_building,
                                              px_cal_insurance_value,
                                              pol_price_index_value,
                                              new_price_index_value,
                                              pol_base_index_year,
                                              pol_price_index_id,
                                              pol_base_index_date,
                                              px_cmv_null_flag,
                                              pol_indexation_date,
					      px_pol_retirement_value,
					      'Y',
                                              pol_period_fully_reserved,
                                              p_log_level_rec);

       px_cal_insurance_value := px_cal_insurance_value *
                                             (1-(cost_retired/bks_cost));
    END IF;

    px_pol_insurance_value := px_cal_insurance_value;

END process_retirements;


PROCEDURE update_policies_record
                       (p_pol_asset_policy_id      IN            NUMBER,
                        p_pol_policy_number        IN            VARCHAR2,
                        p_pol_asset_id             IN            NUMBER,
                        p_cal_insurance_value      IN            NUMBER,
                        p_indexation_id            IN            NUMBER,
                        p_new_price_index_value    IN            NUMBER,
                        p_pol_retirement_value     IN            NUMBER,
                        p_last_period_closed_date  IN            DATE
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

BEGIN

    UPDATE      fa_ins_policies pol
    SET         pol.current_insurance_value = round(p_cal_insurance_value,2),
                pol.last_indexation_id = p_indexation_id,
                pol.last_price_index_value = nvl(p_new_price_index_value,1),
                pol.value_before_retirement = nvl(p_pol_retirement_value,-1),
                pol.last_indexation_date = p_last_period_closed_date
    WHERE       pol.asset_policy_id = p_pol_asset_policy_id
    AND		pol.policy_number = p_pol_policy_number
    AND         pol.asset_id = p_pol_asset_id;

END update_policies_record;

PROCEDURE insert_values_record
                       (p_pol_asset_policy_id      IN            NUMBER,
                        px_indexation_id           IN OUT NOCOPY NUMBER,
                        p_pol_vendor_id            IN            NUMBER,
                        p_pol_policy_number        IN            VARCHAR2,
                        p_pol_asset_id             IN            NUMBER,
                        p_year                     IN            NUMBER,
                        p_last_period_closed_date  IN            DATE,
                        p_pol_price_index_id       IN            NUMBER,
                        p_pol_price_index_value    IN            NUMBER,
                        p_cal_insurance_value      IN            NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

BEGIN

    SELECT FA_INDEXATION_S.nextval
    INTO   px_indexation_id
    FROM   dual;

    INSERT INTO  fa_ins_values
          (       asset_policy_id,
                  indexation_id,
                  vendor_id,
                  policy_number,
                  asset_id,
                  indexation_year,
                  indexation_date,
                  price_index_id,
                  last_price_index_value,
                  insurance_value,
                  created_by,
                  creation_date,
                  last_updated_by,
                  last_update_date,
                  last_update_login,
                  request_id,
                  program_application_id,
                  program_id,
                  program_update_date
    ) VALUES (
                  p_pol_asset_policy_id,
                  px_indexation_id,
                  p_pol_vendor_id,
                  p_pol_policy_number,
                  p_pol_asset_id,
                  p_year,
                  p_last_period_closed_date,
                  p_pol_price_index_id,
                  p_pol_price_index_value,
                  round(p_cal_insurance_value,2),
                  TO_NUMBER(FND_PROFILE.Value('USER_ID')),
                  SYSDATE,
                  TO_NUMBER(FND_PROFILE.Value('USER_ID')),
                  SYSDATE,
                  TO_NUMBER(FND_PROFILE.Value('LOGIN_ID')),
                  TO_NUMBER(FND_PROFILE.Value('CONC_REQUEST_ID')),
                  TO_NUMBER(FND_PROFILE.Value('CONC_PROGRAM_APPLICATION_ID')),
                  TO_NUMBER(FND_PROFILE.Value('CONC_PROGRAM_ID')),
                  SYSDATE);

END insert_values_record;

PROCEDURE Get_base_index_value
                       (p_asset_book               IN            VARCHAR2,
                        pol_asset_id                             NUMBER,
                        pol_base_index_date                      DATE,
                        px_base_price_index_value  IN OUT NOCOPY NUMBER,
                        pol_price_index_id                       NUMBER,
                        px_base_price_index_id     IN OUT NOCOPY NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

BEGIN
           Get_New_Price_Index_Proc(pol_price_index_id,
                                    px_base_price_index_value,
                                    px_base_price_index_id,
                                    pol_base_index_date,
                                    p_log_level_rec);

END Get_base_index_value;


PROCEDURE plsqlmsg (p_msg IN VARCHAR2) IS
/* This is an R11 AOL routine to allow messages to be written to the */
/* log (set the first parameter = 1) or an output file (set the first */
/* parameter = 2).                                                     */

BEGIN
    fnd_file.put_line(1, p_msg);
END plsqlmsg;

PROCEDURE plsqlmsg_put (p_msg IN VARCHAR2) IS
/* This is an R11 AOL routine to allow messages to be written to the */
/* log (set the first parameter = 1) or an output file (set the first */
/* parameter = 2).                                                     */

 BEGIN
	fnd_file.put(1, p_msg);
 END plsqlmsg_put ;

END FA_C_INSURE;

/
