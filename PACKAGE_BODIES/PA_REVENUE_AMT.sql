--------------------------------------------------------
--  DDL for Package Body PA_REVENUE_AMT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_REVENUE_AMT" AS
/*$Header: PAXIIRSB.pls 120.4.12010000.3 2009/06/19 11:10:24 kmaddi ship $ */

-- 1. Procedure calls the client labor billing extension for calculating
--    bill amount
-- 2. Procedure calls the IRS api for populating raw revenue
--    and bill amount, irs rate sch rev id for revenue/invoice in
--    pa_expenditure_items_all table.
--    This procedure verifies whether 'Indirect rate schedule'
--    this applicable for an ei or not and if applicable then it calls the
--    cost plus api to compute the Indirect amount which later on gets added
--    to raw revenue and bill amount.

g1_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

PROCEDURE get_irs_amt
(
 process_irs                        OUT   NOCOPY  VARCHAR2,
 process_bill_rate                  OUT   NOCOPY  VARCHAR2,
 message_code                       OUT   NOCOPY  VARCHAR2,
 rows_this_time			    IN     INTEGER,
 error_code			    IN OUT  NOCOPY    t_int,
 reason				    OUT     NOCOPY t_varchar_30,
 bill_amount			    OUT      NOCOPY t_varchar_100,  /* for bug 8593881 */
 rev_amount			    OUT     NOCOPY t_varchar_30,
 inv_amount			    OUT     NOCOPY t_varchar_30,
 d_rule_decode			    IN OUT     NOCOPY t_int,
 sl_function			    IN OUT     NOCOPY t_int,
 ei_id			    	    IN OUT     NOCOPY t_int,
 t_rev_irs_id		    	    IN OUT     NOCOPY t_int,
 t_inv_irs_id		    	    IN OUT     NOCOPY t_int,
 rev_comp_set_id	    	    IN OUT     NOCOPY t_int,
 inv_comp_set_id	    	    IN OUT     NOCOPY t_int,
 bill_rate_markup		    OUT     NOCOPY t_varchar_2,
 t_lab_sch			    IN     t_varchar_2,
 t_nlab_sch			    IN     t_varchar_2,
 p_mcb_flag                         IN     VARCHAR2,
 x_bill_trans_currency_code         IN OUT  NOCOPY t_varchar_15,        /* MCB Chnages start */
 x_bill_txn_bill_rate               IN OUT  NOCOPY t_varchar_30,
 x_rate_source_id                   IN OUT  NOCOPY t_int,
 x_markup_percentage                IN OUT  NOCOPY t_varchar_30,         /* MCB Changes end */
 x_exp_type                         IN             t_varchar_30,        /*change for nonlabor client extension */
 x_nl_resource                      IN             t_varchar_20,
 x_nl_res_org_id                    IN             t_int            /*End of change for nonlabor client extension */

)
IS

/*-----------------------------------------------------------------------------
 declare all the memory variables.
 ----------------------------------------------------------------------------*/

    client_extn_system_error  EXCEPTION;
    cost_plus_system_error    EXCEPTION;
    amount                    number;
    rate_sch_rev_id           number;
    compiled_set_id           number;
    status                    number;
    stage                     number;
    bill_rate_flag            varchar2(2);
    sys_linkage_func          varchar2(30);
    insert_error_message      boolean;
    fetched_amount            boolean;
    l_ind_cost_acct           NUMBER := NULL;
    l_ind_cost_denm           NUMBER := NULL;
    j			      INTEGER;


    l_indirect_cost_project   NUMBER := NULL;    /* EPP Changes */


  /*** MCB Changes : Declare the out variable for the function Call_Calc_Bill_Amount ***/

    l_x_bill_trans_currency_code      VARCHAR2(15);
    l_x_bill_trans_bill_rate          NUMBER;
    l_x_rate_source_id                NUMBER;
    l_x_markup_percentage             NUMBER;

  /*** End MCB Changes ***/
 l_mcb_cost_flag    varchar2(50);   /* Added for bug 2638840 */
--NOCOPY Changes
l_process_irs	      VARCHAR2(50);
l_process_bill_rate   VARCHAR2(50);
l_message_code        VARCHAR2(2000);

  BEGIN

  IF g1_debug_mode  = 'Y' THEN
  	PA_MCB_INVOICE_PKG.log_message('get_irs_amt: ' || 'Entering the get IRS procedure .....');
  END IF;


/*-----------------------------------------------------------------------------
 initialize array index j to 1,
 initialize flags which determine whether irs, bill rate
 schedules need to be processed or not
 ----------------------------------------------------------------------------*/

     j  := 1;
     l_process_irs := 'N';
     l_process_bill_rate := 'N';
     l_message_code := 'No errors while processing IRS....';

/* Added for bug 2638840 */

IF ( nvl(p_mcb_flag,'N') = 'Y' ) THEN

  IF  (j <= rows_this_time) THEN

  BEGIN
 /* Added the following nvl so that code doesn't break even if upgrade script fails - For bug 2724185 */

         SELECT  nvl(BTC_COST_BASE_REV_CODE,'EXP_TRANS_CURR')
          INTO   l_mcb_cost_flag
         FROM pa_projects_all
         WHERE  project_id =(select project_id from pa_expenditure_items_all
                                     where expenditure_item_id=ei_id(1));
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     IF g1_debug_mode  = 'Y' THEN
  	PA_MCB_INVOICE_PKG.log_message('get_irs_amt: ' || 'No Data Found for the ei_id:' ||  ei_id(1));
     END IF;
    RAISE ;
  END;

 IF g1_debug_mode  = 'Y' THEN
 	PA_MCB_INVOICE_PKG.log_message('get_irs_amt: ' || 'BTC_COST_BASE_REV_CODE  :' || l_mcb_cost_flag);
 END IF;
END IF;
END IF;

/* End of Changes done for bug 2638840 */

/*-----------------------------------------------------------------------------
 loop until all 100 ei's are processed
 ----------------------------------------------------------------------------*/

     WHILE j <= rows_this_time LOOP

          error_code( j ) := 0;

      /*    l_mcb_cost_flag := NULL;   Added for bug 2638840 and later commented for bug 2638840 */
          rate_sch_rev_id := NULL;
          compiled_set_id := NULL;
          amount := NULL;
          insert_error_message := FALSE;
          fetched_amount := FALSE;

/*-----------------------------------------------------------------------------
  Call a client extension to fetch the bill amount for the ei.
  This has to be done for Labor exp items which have WORK
  distribution rule for Revenue or Invoice.
 ----------------------------------------------------------------------------*/

         bill_amount( j )      := NULL;
         bill_rate_markup( j ) := NULL;

        /* MCB Changes : Initialize the out variables */

           x_bill_trans_currency_code( j ) := NULL;
           x_bill_txn_bill_rate( j )       := NULL;
           x_rate_source_id( j )           := NULL;
           x_markup_percentage( j )        := NULL;


         IF ( ( d_rule_decode(j) > 0   )/*   AND
              ( sl_function( j ) < 2   ) */) THEN   /*commented out  for nonlabor client extension*/
              amount         := NULL;
              status         := 0;
              bill_rate_flag := ' ';
/** Added new values for new system linkages in proj. manf. **/


              IF sl_function( j ) = 0 THEN
                  sys_linkage_func := 'ST';
              ELSIF sl_function( j ) = 1 THEN
                  sys_linkage_func := 'OT';
              ELSIF sl_function( j ) = 2 THEN
                  sys_linkage_func := 'ER';
              ELSIF sl_function( j ) = 3 THEN
                  sys_linkage_func := 'USG';
              ELSIF sl_function( j ) = 4 THEN
                  sys_linkage_func := 'VI';
              ELSIF sl_function( j ) = 5 THEN
                  sys_linkage_func := 'WIP';
              ELSIF sl_function( j ) = 6 THEN
                  sys_linkage_func := 'BTC';
              ELSIF sl_function( j ) = 7 THEN
                  sys_linkage_func := 'PJ';
              ELSIF sl_function( j ) = 8 THEN
                  sys_linkage_func := 'INV';
              ELSE
                  sys_linkage_func := NULL;
              END IF;


              IF g1_debug_mode  = 'Y' THEN
              	PA_MCB_INVOICE_PKG.log_message('get_irs_amt: ' || 'Calling call_calc_bill_amount procedure ' || ei_id(j));
              END IF;
If ( sl_function( j ) < 2   )  THEN  /*change for nonlabor client extension*/

              pa_billing.Call_Calc_Bill_Amount( 'ACTUAL',ei_id( j ),
                                                       sys_linkage_func,
                                                       amount,
                                                       bill_rate_flag,
                                                       status,
                                                       l_x_bill_trans_currency_code,
                                                       l_x_bill_trans_bill_rate,
                                                       l_x_markup_percentage,
                                                       l_x_rate_source_id
                                                );


              IF g1_debug_mode  = 'Y' THEN
              	PA_MCB_INVOICE_PKG.log_message('get_irs_amt: ' || 'After Calling call_calc_bill_amount procedure ' || ei_id(j));
              	PA_MCB_INVOICE_PKG.log_message('get_irs_amt: ' || 'Amount :' || to_char(amount));
              	PA_MCB_INVOICE_PKG.log_message('get_irs_amt: ' || 'Bill Rate Flag : ' || bill_rate_flag);
              	PA_MCB_INVOICE_PKG.log_message('get_irs_amt: ' || 'Bill Trans Currency code :' || l_x_bill_trans_currency_code);
              	PA_MCB_INVOICE_PKG.log_message('get_irs_amt: ' || 'Bill Trans Bill Rate :' || l_x_bill_trans_bill_rate);
              	PA_MCB_INVOICE_PKG.log_message('get_irs_amt: ' || 'Markup Percentage :' || l_x_markup_percentage);
              	PA_MCB_INVOICE_PKG.log_message('get_irs_amt: ' || 'Rate source Id :' || l_x_rate_source_id);
              	PA_MCB_INVOICE_PKG.log_message('get_irs_amt: ' || 'Status :' || status);
              END IF;

ELSE    /*change for nonlabor client extension
         Else part of sl_function<2*/

     pa_billing.Call_Calc_Non_Labor_Bill_Amt
                                  (
                                      x_transaction_type=>'ACTUAL',
                                      x_expenditure_item_id=>ei_id( j ),
                                      x_sys_linkage_function=>sys_linkage_func,
                                      x_amount=>amount,
                                      x_expenditure_type=>x_exp_type(j),
                                      x_non_labor_resource=>x_nl_resource(j),
                                      x_non_labor_res_org=>x_nl_res_org_id(j),
                                      x_bill_rate_flag=>bill_rate_flag,
                                      x_status=>status,
                                      x_bill_trans_currency_code=>l_x_bill_trans_currency_code,
                                      x_bill_txn_bill_rate=>l_x_bill_trans_bill_rate,
                                      x_markup_percentage=>l_x_markup_percentage,
                                      x_rate_source_id=>l_x_rate_source_id);
            IF g1_debug_mode  = 'Y' THEN
                PA_MCB_INVOICE_PKG.log_message('get_irs_amt: ' || 'After Calling call_calc_non_labor_bill_amt procedure ' || ei_id(j));
                PA_MCB_INVOICE_PKG.log_message('get_irs_amt: ' || 'Amount :' || to_char(amount));
                PA_MCB_INVOICE_PKG.log_message('get_irs_amt: ' || 'Bill Rate Flag : ' || bill_rate_flag);
                PA_MCB_INVOICE_PKG.log_message('get_irs_amt: ' || 'Bill Trans Currency code :' || l_x_bill_trans_currency_code);
                PA_MCB_INVOICE_PKG.log_message('get_irs_amt: ' || 'Bill Trans Bill Rate :' || l_x_bill_trans_bill_rate);
                PA_MCB_INVOICE_PKG.log_message('get_irs_amt: ' || 'Markup Percentage :' || l_x_markup_percentage);
                PA_MCB_INVOICE_PKG.log_message('get_irs_amt: ' || 'Rate source Id :' || l_x_rate_source_id);
                PA_MCB_INVOICE_PKG.log_message('get_irs_amt: ' || 'Status :' || status);
              END IF;

END IF;
/*end of change for nonlabor client extension*/
              IF ( ( status = 0              OR
                     status is null )        AND
                     amount is null        ) THEN
                   null;
              ELSIF ( (status = 0 OR status is null)
                     and amount is not null ) THEN
                       bill_amount( j ) := to_char(amount);
                        fetched_amount := TRUE;
                       l_process_irs := 'Y';

                      /* MCB Changes : Assign the value to the out variable to pass into pro*c */

                         x_bill_trans_currency_code( j )  := l_x_bill_trans_currency_code;
                         x_bill_txn_bill_rate( j )        := l_x_bill_trans_bill_rate;
                         x_rate_source_id( j )            := l_x_rate_source_id;
                         x_markup_percentage( j )         := l_x_markup_percentage;

                      /* End MCB Changes */


                   IF ( bill_rate_flag = 'B' ) THEN
                       bill_rate_markup(j ) := 'B';
                   ELSE
                       bill_rate_markup( j ) := NULL;
                   END IF;
              ELSIF ( status > 0 and sl_function(j)<2) THEN
                   fetched_amount := TRUE;
                   reason( j ) := 'CALC_BILL_AMOUNT_EXT_FAIL';
                   error_code( j ) := 1;
              ELSIF ( status > 0 and sl_function(j)>1) THEN/*Change for nonlabor client extension*/
                   fetched_amount := TRUE;
                   reason( j ) := 'CALC_BILL_AMT_NL_EXT_FAIL';  /* for bug 6262893 'CALC_BILL_AMOUNT_NL_EXT_FAIL'; */
                   error_code( j ) := 1;
              ELSE
                   RAISE client_extn_system_error;
              END IF;

        END IF;

/*----------------------------------------------------------------------------
 For Revenue :
 check whether revenue distribution is WORK, labor/non labor
 schedule type is Indirect, irs sch id exists and ei is labor/
 non labor. If all of this is true only then call the api to
 calculate the indirect cost for Revenue.

 For Labor/non Labor expenditure items :
 ----------------------------------------------------------------------------*/

           IF (  (d_rule_decode(j) = 1 OR d_rule_decode(j) =2)                               AND
                 t_rev_irs_id( j ) IS NOT NULL                    AND
              (( t_lab_sch( j ) = 'I'                             AND
                 sl_function( j ) < 2                        )    OR
               ( t_nlab_sch( j ) = 'I'                            AND
                 sl_function( j ) > 1                        ))   AND
                 NOT fetched_amount                               ) THEN


                 l_ind_cost_acct := NULL;
                 l_ind_cost_denm := NULL;
                 l_indirect_cost_project := NULL;     /* EPP Changes */

          IF g1_debug_mode  = 'Y' THEN
          	PA_MCB_INVOICE_PKG.log_message('get_irs_amt: ' || 'Calling Procedure get_exp_item_indirect_cost for Revenue');
          END IF;


                 pa_cost_plus.get_exp_item_indirect_cost(
                 ei_id( j ), 'R', amount,
                 l_ind_cost_acct,l_ind_cost_denm,
                 l_indirect_cost_project,             /* EPP Changes */
                 rate_sch_rev_id, compiled_set_id,
                 status, stage );

/* ---------------------------------------------------------------------------
 Check for success/failure of the called api :
 check whether indirect amount and sch rev id were retrieved successfully,
 if yes then assign these values to the host array variables for indirect
 amount and rate sct rev id respectively, else set error code to 1 which
 stands for 'NO COMPILED MULTIPLIER'.
 ----------------------------------------------------------------------------*/
                 IF ( status = 100 and stage <> 400 ) THEN
                      rev_comp_set_id( j ) := NULL;
                      rev_amount(j ) := NULL;
                      error_code(j ) := 1;
                      l_message_code :=
                          'Error encountered during processing IRS....' ;
                      insert_error_message := TRUE;

/*-----------------------------------------------------------------------------
  NO_COST_BASE case whereby raw_revenue amount should be populated with
  raw_cost.
  ---------------------------------------------------------------------------*/
                 ELSIF ( status = 100 and stage = 400 ) THEN
                         rev_comp_set_id(j ):= 0;
                         rev_amount(j ) :=  '0';
                         l_process_irs := 'Y';

/*-----------------------------------------------------------------------------
  If everything is retrieved as expected which means success.
  ---------------------------------------------------------------------------*/
                 ELSIF ( rate_sch_rev_id IS NOT NULL AND
                         compiled_set_id IS NOT NULL AND
                         amount          IS NOT NULL AND
                         status = 0 ) THEN
                         rev_comp_set_id( j ):= compiled_set_id;

                        /* MCB Changes : If MCB enabled then take the denom cost other wise
                                         raw cost */

                         IF p_mcb_flag = 'Y' THEN

                        /* Commented for bug 2638840
                       rev_amount( j ) :=  to_char(l_ind_cost_denm); */

     /* Bug 2638840 : Get the BTC_COST_BASE_REV_CODE from pa_projects_all table */
/* Moved the following code added for bug 2638840 out of the while loop and
   added the same before the start of while, as each call of  get_irs_amt
   has EIs that belong to the same project and hence retrieving the
   btc_cost_base_rev_code once for each call of get_irs_amt would be sufficient

BEGIN

   select BTC_COST_BASE_REV_CODE
   into l_mcb_cost_flag
   from pa_projects_all
   where project_id =(select project_id from pa_expenditure_items_all where expenditure_item_id=ei_id(j));

EXCEPTION
  WHEN NO_DATA_FOUND THEN
  IF g1_debug_mode  = 'Y' THEN
  	PA_MCB_INVOICE_PKG.log_message('get_irs_amt: ' || 'No Data Found for the ei_id:' ||  ei_id(j));
  END IF;
  RAISE ;
END;

     IF g1_debug_mode  = 'Y' THEN
     	PA_MCB_INVOICE_PKG.log_message('get_irs_amt: ' || 'BTC_COST_BASE_REV_CODE  :' || l_mcb_cost_flag);
     END IF; */



      IF g1_debug_mode  = 'Y' THEN
      	PA_MCB_INVOICE_PKG.log_message('get_irs_amt: ' || 'mcb_cost_bug l_ind_cost_denm ' || l_ind_cost_denm);
      	PA_MCB_INVOICE_PKG.log_message('get_irs_amt: ' || 'mcb_cost_bug l_ind_cost_acct ' || l_ind_cost_acct);
      	PA_MCB_INVOICE_PKG.log_message('get_irs_amt: ' || 'mcb_cost_bug amount ' || amount);
      	PA_MCB_INVOICE_PKG.log_message('get_irs_amt: ' || 'mcb_cost_bug l_indirect_cost_project ' || l_indirect_cost_project);
      END IF;

                            IF (l_mcb_cost_flag = 'EXP_TRANS_CURR') THEN

                                rev_amount( j ) :=  to_char(l_ind_cost_denm);

                            ELSIF (l_mcb_cost_flag = 'EXP_FUNC_CURR') THEN

                                rev_amount( j ) :=   to_char(l_ind_cost_acct);

                            ELSIF (l_mcb_cost_flag = 'PROJ_FUNC_CURR') THEN

                                rev_amount( j ) :=   to_char(amount);

                            ELSIF (l_mcb_cost_flag = 'PROJECT_CURR') THEN

                                rev_amount( j ) :=   to_char(l_indirect_cost_project);

                            END IF;


      IF g1_debug_mode  = 'Y' THEN
      	PA_MCB_INVOICE_PKG.log_message('get_irs_amt: ' || 'mcb_cost_bug rev_amount ' || rev_amount(j));
      END IF;
         /*End of Changes for bug 2638840 */

                         ELSE

                          rev_amount( j ) :=  to_char(amount);

                         END IF;

                         l_process_irs := 'Y';
/*-----------------------------------------------------------------------------
  This case maynot arise, but has been added for safety reasons.
  ---------------------------------------------------------------------------*/
                 ELSE
                         RAISE cost_plus_system_error;
                 END IF;
/*----------------------------------------------------------------------------
 if no condition satisfies which indirectly means that we need to process
 for bill rate schedule.
 ---------------------------------------------------------------------------*/
            ELSE
                 l_process_bill_rate := 'Y';
                 rev_comp_set_id( j ) := NULL;
                 rev_amount( j ) := NULL;
            END IF;

            rate_sch_rev_id := NULL;
            compiled_set_id := NULL;
            amount := NULL;
/*----------------------------------------------------------------------------
 For Invoice

 check whether invoice distribution is WORK, labor/non labor schedule
 type is Indirect, irs sch id exists and ei is labor/non labor. If
 all of this is true only then call the api to calculate the indirect
 cost for Invoice.

 For Labor/Non Labor expenditure items.
 ----------------------------------------------------------------------------*/

           IF (  (d_rule_decode(j) = 1 OR d_rule_decode(j) = 3)  AND
                 t_inv_irs_id(j) IS NOT NULL                     AND
              (( t_lab_sch(j ) = 'I'                          AND
                 sl_function(j ) < 2                      )   OR
               ( t_nlab_sch( j ) = 'I'                         AND
                 sl_function( j ) > 1                      ))  AND
                 NOT fetched_amount                            ) THEN


            l_ind_cost_acct := NULL;
            l_ind_cost_denm := NULL;
            l_indirect_cost_project := NULL;      /* EPP Changes */

       IF g1_debug_mode  = 'Y' THEN
       	PA_MCB_INVOICE_PKG.log_message('get_irs_amt: ' || 'Calling Procedure get_exp_item_indirect_cost for Invoice');
       END IF;


	    pa_cost_plus.get_exp_item_indirect_cost(
                 ei_id( j ), 'I', amount,
                 l_ind_cost_acct, l_ind_cost_denm,
                 l_indirect_cost_project,              /* EPP Changes */
                 rate_sch_rev_id, compiled_set_id,
                 status, stage );

/*----------------------------------------------------------------------------

 Check for success/failure of the called api :

 check whether indirect amount and sch rev id were retrieved successfully,
 if yes then assign these values to the host array variables for indirect
 amount and rate sct rev id respectively, else set error code to 1 which
 stands for 'NO COMPILED MULTIPLIER'.

 status = 100 ==> indicates that Compiled Multiplier does not exist.
 'stage' indicates the logical step within the procedure
 pa_cost_plus.get_exp_item_indirect_cost.

 ---------------------------------------------------------------------------*/
                 IF ( status = 100 and stage <> 400 ) THEN
                     inv_comp_set_id(j) := NULL;
                     inv_amount( j ) := NULL;
                     error_code( j ) := 1;
                     l_message_code :=
                         'Error encountered during processing IRS....' ;
                     insert_error_message := TRUE;
/*-----------------------------------------------------------------------------
  NO_COST_BASE case whereby raw_revenue amount should be populated with
  raw_cost.
  ---------------------------------------------------------------------------*/
                 ELSIF ( status = 100 and stage = 400 ) THEN
                         inv_comp_set_id(j ) := 0;
                         inv_amount( j ) := '0';
                         l_process_irs := 'Y';
/*-----------------------------------------------------------------------------
  If everything is retrieved as expected which means success.
  ---------------------------------------------------------------------------*/
                 ELSIF ( rate_sch_rev_id IS NOT NULL AND
                         compiled_set_id IS NOT NULL AND
                         amount          IS NOT NULL AND
                         status = 0 ) THEN
                         inv_comp_set_id(j ) := compiled_set_id;

                        /* MCB Changes : If MCB enabled then take the denom cost other wise
                                         raw cost */

                         IF p_mcb_flag = 'Y' THEN

                          /* Commented for bug 2638840
                   inv_amount( j ) :=  to_char(l_ind_cost_denm); */

/* Bug 2638840 : Get the BTC_COST_BASE_REV_CODE from pa_projects_all table */
  /* Moved the following code added for bug 2638840 out of the while loop and
   added the same before the start of while, as each call of  get_irs_amt
   has EIs that belong to the same project and hence retrieving the
   btc_cost_base_rev_code once for each call of get_irs_amt would be sufficient

   l_mcb_cost_flag := NULL;
BEGIN

   select BTC_COST_BASE_REV_CODE
   into l_mcb_cost_flag
   from pa_projects_all
   where project_id =(select project_id from pa_expenditure_items_all where expenditure_item_id=ei_id(j));

EXCEPTION
WHEN NO_DATA_FOUND THEN
   IF g1_debug_mode  = 'Y' THEN
   	PA_MCB_INVOICE_PKG.log_message('get_irs_amt: ' || 'No Data Found for the ei_id:' ||  ei_id(j));
   END IF;
    RAISE ;
END;

     IF g1_debug_mode  = 'Y' THEN
     	PA_MCB_INVOICE_PKG.log_message('get_irs_amt: ' || 'BTC_COST_BASE_REV_CODE  :' || l_mcb_cost_flag);
     END IF; */

                            IF (l_mcb_cost_flag = 'EXP_TRANS_CURR') THEN

                                inv_amount( j ) :=  to_char(l_ind_cost_denm);

                            ELSIF (l_mcb_cost_flag = 'EXP_FUNC_CURR') THEN

                                inv_amount( j ) :=   to_char(l_ind_cost_acct);

                            ELSIF (l_mcb_cost_flag = 'PROJ_FUNC_CURR') THEN

                                inv_amount( j ) :=   to_char(amount);

                            ELSIF (l_mcb_cost_flag = 'PROJECT_CURR') THEN

                                inv_amount( j ) :=   to_char(l_indirect_cost_project);

                            END IF;
                       /* End of Changes for bug 2638840 */
                         ELSE

                          inv_amount( j ) :=  to_char(amount);

                         END IF;

                         l_process_irs := 'Y';

/*-----------------------------------------------------------------------------
  This case maynot arise, but has been added for safety reasons.
  ---------------------------------------------------------------------------*/
                 ELSE
                         RAISE cost_plus_system_error;
/*                       inv_comp_set_id(j) := NULL;
                         inv_amount(j) := NULL;
                         error_code(j ) := 1;
                         l_message_code := 'Error encountered during processing IRS....' ;
*/
                 END IF;

/*----------------------------------------------------------------------------
   if no condition satisfies which indirectly means that we need to process
   for bill rate schedule.
 ----------------------------------------------------------------------------*/
             ELSE
                    l_process_bill_rate := 'Y';
                    inv_comp_set_id( j ) := NULL;
                    inv_amount( j ) := NULL;
             END IF;
/*-----------------------------------------------------------------------------
   Rejection code error message which would be eventually populated in
   pa_expenditure_items_all table.
 ----------------------------------------------------------------------------*/

       IF ( insert_error_message ) THEN
            IF (stage = 200) THEN
               reason( j ) := 'NO_IND_RATE_SCH_REVISION';
            ELSIF (stage = 300) THEN
               reason( j ) := 'NO_COST_PLUS_STRUCTURE';
            ELSIF (stage = 500) THEN
               reason( j ) := 'NO_ORGANIZATION';
            ELSIF (stage = 600) THEN
               reason( j ) := 'NO_COMPILED_MULTIPLIER';/* BUG 5884742 */
            ELSIF (stage = 700) THEN
               reason( j ) := 'NO_ACTIVE_COMPILED_SET';
            ELSE
               reason( j ) := 'GET_INDIRECT_COST_FAIL';
            END IF;
       END IF;

       j := j + 1;

      END LOOP;

     IF g1_debug_mode  = 'Y' THEN
     	PA_MCB_INVOICE_PKG.log_message('get_irs_amt: ' || 'Leaving Procedure get_irs_amount');
     END IF;
--NOCOPY CHanges
message_code      := l_message_code;
process_irs       := l_process_irs;
process_bill_rate := l_process_bill_rate;

EXCEPTION
      WHEN client_extn_system_error THEN
          message_code := 'ORA error encountered while processing pa_client_extn_billing.calc_bill_amount';

      WHEN cost_plus_system_error THEN
          message_code := 'ORA error encountered while processing pa_cost_plus.get_exp_item_indirect_cost';

      WHEN OTHERS THEN
          message_code := sqlerrm( sqlcode );
END get_irs_amt;

/* The following Overloaded procedure get_irs_amt is added for Bug 2517675 .
 !!!This is overloaded procedure for compilation of pro*c files of Patchset H.
 !!!Note: This .pls with overload function should not be sent along with the patch for Patchset H customers */


PROCEDURE get_irs_amt
(
 process_irs                        OUT   NOCOPY  VARCHAR2,
 process_bill_rate                  OUT   NOCOPY  VARCHAR2,
 message_code                       OUT   NOCOPY VARCHAR2,
 rows_this_time                     IN     INTEGER,
 error_code                         IN OUT  NOCOPY    t_int,
 reason                             OUT     NOCOPY t_varchar_30,
 bill_amount                        OUT     NOCOPY t_varchar_30,
 rev_amount                         OUT     NOCOPY t_varchar_30,
 inv_amount                         OUT     NOCOPY t_varchar_30,
 d_rule_decode                      IN OUT     NOCOPY t_int,
 sl_function                        IN OUT     NOCOPY t_int,
 ei_id                              IN OUT     NOCOPY t_int,
 t_rev_irs_id                       IN OUT     NOCOPY t_int,
 t_inv_irs_id                       IN OUT     NOCOPY t_int,
 rev_comp_set_id                    IN OUT     NOCOPY t_int,
 inv_comp_set_id                    IN OUT     NOCOPY t_int,
 bill_rate_markup                   OUT     NOCOPY t_varchar_2,
 t_lab_sch                          IN      t_varchar_2,
 t_nlab_sch                         IN     t_varchar_2
)
IS
 BEGIN
    null;
 END;
/* End of overload for Patchset H */

/*This procedure is overloaded for patchset L changes(nonlabor client extension)*/
PROCEDURE get_irs_amt
(
 process_irs                        OUT NOCOPY    VARCHAR2,
 process_bill_rate                  OUT NOCOPY    VARCHAR2,
 message_code                       OUT NOCOPY    VARCHAR2,
 rows_this_time                     IN     INTEGER,
 error_code                         IN OUT  NOCOPY    t_int,
 reason                             OUT     NOCOPY t_varchar_30,
 bill_amount                        OUT     NOCOPY t_varchar_30,
 rev_amount                         OUT     NOCOPY t_varchar_30,
 inv_amount                         OUT     NOCOPY t_varchar_30,
 d_rule_decode                      IN OUT     NOCOPY t_int,
 sl_function                        IN OUT     NOCOPY t_int,
 ei_id                              IN OUT     NOCOPY t_int,
 t_rev_irs_id                       IN OUT     NOCOPY t_int,
 t_inv_irs_id                       IN OUT     NOCOPY t_int,
 rev_comp_set_id                    IN OUT     NOCOPY t_int,
 inv_comp_set_id                    IN OUT     NOCOPY t_int,
 bill_rate_markup                   OUT     NOCOPY t_varchar_2,
 t_lab_sch                          IN     t_varchar_2,
 t_nlab_sch                         IN     t_varchar_2,
 p_mcb_flag                         IN     VARCHAR2,
 x_bill_trans_currency_code         IN OUT  NOCOPY t_varchar_15,        /* MCB Chnages start */
 x_bill_txn_bill_rate               IN OUT  NOCOPY t_varchar_30,
 x_rate_source_id                   IN OUT  NOCOPY t_int,
 x_markup_percentage                IN OUT  NOCOPY t_varchar_30)         /* MCB Changes end */
IS
 BEGIN
   null;
end;


/* Added adjust_rounding_error procedure for solving bug#658088
This procedure is called from pardfp.lpc program library.

OBJECTIVE :
 - Obective of procedure is to identify all those expenditure items for a
   given request_id and project_id, which have ROUNDING_OF_ERROR and adjust
   the rounding amount against any one of the agreements used to fund the
   expenditure items.

*/

PROCEDURE adjust_rounding_error
(
 p_project_id         IN     NUMBER,
 p_request_id         IN     NUMBER,
 p_task_level_funding IN     NUMBER,
 x_max_items_allowed  IN     NUMBER,          /* Maximum size of array in ProC   */
 x_message_code       OUT   NOCOPY  VARCHAR2,
 x_total_exp_items    OUT   NOCOPY NUMBER,
 x_exp_item_list      OUT  NOCOPY    t_varchar_100 )
IS                                            /*   This is to control the size from calling place */



/* --------------------------------------------------------------------
  top_task_cur  will pick up tasks for a project having task level funding
   -------------------------------------------------------------------- */
 CURSOR top_task_cur ( p_project_id IN NUMBER, p_request_id IN NUMBER,
        p_task_level_funding IN NUMBER )  IS
 SELECT
        t.top_task_id TOP_TASK_ID,
        max(dr.draft_revenue_num) DRAFT_REVENUE_NUM
 FROM   pa_tasks t,pa_draft_revenues_all dr
 WHERE  p_task_level_funding = 1  /* for task level funding projects only */
 AND    dr.project_id = p_project_id
 AND    t.project_id = dr.project_id
 AND    dr.request_id   = p_request_id
 AND    EXISTS
         ( SELECT NULL
           FROM pa_expenditure_items_all x,
                pa_cust_rev_dist_lines_all rdl
           WHERE x.request_id+0 = dr.request_id
           AND   x.task_id      = t.task_id
           AND   x.revenue_distributed_flag||'' = 'A'
           AND   x.raw_revenue    = x.accrued_revenue
           AND   x.raw_revenue     is not NULL
           AND   x.accrued_revenue is not NULL
           AND nvl(rdl.function_code,'*') not in ('LRL','LRB','URL','URB')
           AND rdl.line_num_reversed+0 is null
           AND nvl(rdl.reversed_flag, 'N' ) = 'N'
           AND rdl.expenditure_item_id = x.expenditure_item_id+0
           AND rdl.draft_revenue_num   = dr.draft_revenue_num
           AND rdl.project_id+0        = dr.project_id
           AND rdl.request_id+0        = dr.request_id)
 GROUP BY t.top_task_id
 UNION ALL
 SELECT  max(to_number(NULL)) TOP_TASK_ID,
         max(dr2.draft_revenue_num) DRAFT_REVENUE_NUM
 FROM    pa_draft_revenues_all dr2
 WHERE   p_task_level_funding = 0 /* for project level funding only */
 AND     dr2.project_id    = p_project_id
 AND     dr2.request_id+0    = p_request_id
 AND    EXISTS
         ( SELECT NULL
           FROM pa_expenditure_items_all ei2,
                pa_cust_rev_dist_lines_all rdl2
           WHERE ei2.request_id   = rdl2.request_id
           AND rdl2.expenditure_item_id = ei2.expenditure_item_id
           AND ei2.raw_revenue     is not NULL
           AND ei2.accrued_revenue is not NULL
           AND ei2.revenue_distributed_flag||'' = decode(dr2.project_id,NULL,'A','A')
           AND ei2.raw_revenue    = ei2.accrued_revenue
           AND nvl(rdl2.function_code,'*') not in ('LRL','LRB','URL','URB')
           AND rdl2.line_num_reversed+0 is null
           AND nvl(rdl2.reversed_flag, 'N' ) = 'N'
           AND rdl2.draft_revenue_num   = dr2.draft_revenue_num
           AND rdl2.project_id          = dr2.project_id
           AND rdl2.request_id+0        = dr2.request_id);
/* GROUP BY to_number(NULL); */



/* --------------------------------------------------------------

exp_cur picks up all those expenditure  items
   - Having raw_revenue <> accrued revenue and there exist
     atleast one expenditure having raw_revenue = accrued revenue
     from the set of processed expenditure items for a project_id,
     task_id( if task level funding is there ).
   -
   -------------------------------------------------------------- */

 CURSOR  exp_cur ( p_project_id         IN NUMBER,
                   p_request_id         IN NUMBER,
                   p_top_task_id        IN NUMBER ,
                   p_draft_revenue_num  IN NUMBER ) IS
 select ei.expenditure_item_id,
        rdl.draft_revenue_item_line_num,
        rdl.draft_revenue_num,
        ei.accrued_revenue ,
        ei.raw_revenue
 from   pa_cust_rev_dist_lines_all rdl,pa_expenditure_items_all ei,
        pa_tasks t
 where  p_top_task_id is not NULL
 AND    ei.request_id+0  = p_request_id
 AND    ei.raw_revenue     is not NULL
 AND    ei.accrued_revenue is not NULL
 AND    ei.revenue_distributed_flag||'' = 'A'
 AND    ei.expenditure_item_id = rdl.expenditure_item_id
 AND    ei.raw_revenue <> ei.accrued_revenue
 AND    rdl.request_id+0  = ei.request_id
 AND    rdl.project_id   = t.project_id
 AND    nvl(rdl.function_code,'*') not in ('LRL','LRB','URL','URB')
 AND    rdl.line_num_reversed+0 is null
 AND    nvl(rdl.reversed_flag, 'N' ) = 'N'
 AND    t.project_id   = p_project_id
 AND    t.task_id      = ei.task_id
 AND    t.top_task_id  = p_top_task_id
 AND rdl.draft_revenue_num+0 = p_draft_revenue_num
 UNION
 select ei.expenditure_item_id,
        rdl.draft_revenue_item_line_num,
        rdl.draft_revenue_num,
        ei.accrued_revenue ,
        ei.raw_revenue
 from   pa_cust_rev_dist_lines_all rdl,pa_expenditure_items_all ei
 where  p_top_task_id is NULL
 AND    ei.request_id+0  = p_request_id
 AND    ei.raw_revenue     is not NULL
 AND    ei.accrued_revenue is not NULL
 AND    ei.revenue_distributed_flag||'' = 'A'||''
 AND    ei.expenditure_item_id = rdl.expenditure_item_id
 AND    ei.raw_revenue <> ei.accrued_revenue
 AND    rdl.request_id+0  = ei.request_id
 AND    rdl.project_id   = p_project_id
 AND    nvl(rdl.function_code,'*') not in ('LRL','LRB','URL','URB')
 AND    rdl.line_num_reversed+0 is null
 AND    nvl(rdl.reversed_flag, 'N' ) = 'N'
 AND rdl.draft_revenue_num   = p_draft_revenue_num;

top_task_cur_rec               top_task_cur%ROWTYPE;
exp_cur_rec                    exp_cur%ROWTYPE;
roundoff_amount                NUMBER;
total_exp_items_processed       NUMBER;
total_round_positive            NUMBER;
total_round_negative           NUMBER;
j                              INTEGER;
dummy_x                        VARCHAR2(1);

l_message_code                 VARCHAR2(2000);
l_total_exp_items 		NUMBER;
BEGIN
l_total_exp_items := x_total_exp_items;
l_message_code    := x_message_code;

        l_total_exp_items := 0;
        total_exp_items_processed := 0;
        total_round_positive := 0;
        total_round_negative := 0;
        j                    := 1;

        l_message_code := 'Error in processing top_task_cur  cursor';

	FOR top_task_cur_rec IN top_task_cur
                             ( p_project_id,
                               p_request_id,
                               p_task_level_funding ) LOOP


             l_message_code := 'Error in processing exp_cur  cursor';

         BEGIN
/* bug#2190645: Joined the t.project_id and rdl_project_id  and
		Removed the suppression of index on rdl.draft_revenue_num  */
          IF p_task_level_funding = 1  THEN
            select 'X'
            into   dummy_x
            from   pa_cust_rev_dist_lines_all rdl,pa_expenditure_items_all ei,
                   pa_tasks t
            where  ei.request_id+0  = p_request_id
            AND    ei.raw_revenue     is not NULL
            AND    ei.accrued_revenue is not NULL
            AND    ei.revenue_distributed_flag||'' = 'A'
            AND    ei.expenditure_item_id = rdl.expenditure_item_id
            AND    ei.raw_revenue <> ei.accrued_revenue
            AND    rdl.request_id+0  = ei.request_id
            AND    rdl.project_id   = t.project_id
            AND    nvl(rdl.function_code,'*') not in ('LRL','LRB','URL','URB')
            AND    rdl.line_num_reversed+0 is null
            AND    nvl(rdl.reversed_flag, 'N' ) = 'N'
            AND    t.project_id   = rdl.project_id
            AND    rdl.project_id   = p_project_id
            AND    t.task_id      = ei.task_id
            AND    t.top_task_id  =  top_task_cur_rec.TOP_TASK_ID
            AND rdl.draft_revenue_num = top_task_cur_rec.DRAFT_REVENUE_NUM
            having sum(ei.accrued_revenue) = sum(ei.raw_revenue);
         ELSE

            select 'X'
            into   dummy_x
            from   pa_cust_rev_dist_lines_all rdl,pa_expenditure_items_all ei
            where  ei.request_id+0  = p_request_id
            AND    ei.raw_revenue     is not NULL
            AND    ei.accrued_revenue is not NULL
            AND    ei.revenue_distributed_flag||''     = 'A'||''
            AND    ei.expenditure_item_id = rdl.expenditure_item_id
            AND    ei.raw_revenue <> ei.accrued_revenue
            AND    rdl.request_id+0  = ei.request_id
            AND    rdl.project_id   = p_project_id
            AND    nvl(rdl.function_code,'*') not in ('LRL','LRB','URL','URB')
            AND    rdl.line_num_reversed+0 is null
            AND    nvl(rdl.reversed_flag, 'N' ) = 'N'
            AND rdl.draft_revenue_num   = top_task_cur_rec.DRAFT_REVENUE_NUM
            having sum(ei.accrued_revenue) = sum(ei.raw_revenue);
         END IF;

             FOR exp_cur_rec IN exp_cur
                  ( p_project_id,
                    p_request_id,
                    top_task_cur_rec.TOP_TASK_ID,
                    top_task_cur_rec.DRAFT_REVENUE_NUM ) LOOP

                  roundoff_amount := exp_cur_rec.ACCRUED_REVENUE -
                                    exp_cur_rec.RAW_REVENUE;

             IF ( l_total_exp_items < x_max_items_allowed ) THEN
               x_exp_item_list( j ) := 'Exp_Id : '||
                    to_char(exp_cur_rec.EXPENDITURE_ITEM_ID,999999999999)||
                    '  Accrued_revenue : '||
                    to_char( exp_cur_rec.ACCRUED_REVENUE,999999999999999.9999)||
                    ' Raw_revenue : '||
                    to_char(exp_cur_rec.RAW_REVENUE,999999999999999.9999);
               l_total_exp_items := l_total_exp_items + 1;
               j := j + 1;
             END IF;

               total_exp_items_processed := total_exp_items_processed +1;
               if ( roundoff_amount > 0 ) then
                 total_round_positive := total_round_positive   + roundoff_amount;
               else
                 total_round_negative := total_round_negative + roundoff_amount;
               end if;

               BEGIN

                  l_message_code := 'Error in update on pa_cut_rev_dist_lines_all';

                  UPDATE pa_cust_rev_dist_lines_all l
                     SET l.amount = PA_CURRENCY.ROUND_CURRENCY_AMT(l.amount -
                         DECODE(code_combination_id, -1, roundoff_amount,
                                                     -2, roundoff_amount,
                                                     -roundoff_amount)),
                         l.projfunc_revenue_amount =                            -- Below lines added for Bug 5042421
                         DECODE(l.revproc_currency_code, l.projfunc_currency_code,
                              PA_CURRENCY.ROUND_CURRENCY_AMT(l.amount -
                                  DECODE(code_combination_id, -1, roundoff_amount,
                                                     -2, roundoff_amount,
                                                     -roundoff_amount)),
                                projfunc_revenue_amount),
                         l.project_revenue_amount =
                         DECODE(l.revproc_currency_code, l.project_currency_code,
                              PA_CURRENCY.ROUND_CURRENCY_AMT(l.amount -
                                  DECODE(code_combination_id, -1, roundoff_amount,
                                                     -2, roundoff_amount,
                                                     -roundoff_amount)),
                                project_revenue_amount),
                         l.funding_revenue_amount =
                         DECODE(l.revproc_currency_code, l.funding_currency_code,
                              PA_CURRENCY.ROUND_CURRENCY_AMT(l.amount -
                                  DECODE(code_combination_id, -1, roundoff_amount,
                                                     -2, roundoff_amount,
                                                     -roundoff_amount)),
                                funding_revenue_amount),
                         l.revtrans_amount =
                         DECODE(l.revproc_currency_code, l.revtrans_currency_code,
                              PA_CURRENCY.ROUND_CURRENCY_AMT(l.amount -
                                  DECODE(code_combination_id, -1, roundoff_amount,
                                                     -2, roundoff_amount,
                                                     -roundoff_amount)),
                                revtrans_amount)                               -- End of Bug 5042421
                   WHERE l.expenditure_item_id =
                                     exp_cur_rec.EXPENDITURE_ITEM_ID
                     AND l.draft_revenue_num =
                                     exp_cur_rec.DRAFT_REVENUE_NUM
                     AND l.draft_revenue_item_line_num =
                                     exp_cur_rec.DRAFT_REVENUE_ITEM_LINE_NUM;

                l_message_code := 'Error in update on pa_draft_revenue_items';

                  UPDATE pa_draft_revenue_items i
                     SET i.amount = i.amount - roundoff_amount,
                         i.projfunc_revenue_amount =	                   -- Below lines added for Bug 5042421
                          DECODE(i.revproc_currency_code, i.projfunc_currency_code,
                                   i.amount - roundoff_amount,
                                i.projfunc_revenue_amount),
                         i.project_revenue_amount =
                          DECODE(i.revproc_currency_code, i.project_currency_code,
                                   i.amount - roundoff_amount,
                                i.project_revenue_amount),
                         i.funding_revenue_amount =
                          DECODE(i.revproc_currency_code, i.funding_currency_code,
                                   i.amount - roundoff_amount,
                                i.funding_revenue_amount),
                         i.revtrans_amount =
                          DECODE(i.revproc_currency_code, i.revtrans_currency_code,
                                   i.amount - roundoff_amount,
                                i.revtrans_amount)				-- End of Bug 5042421
                   WHERE i.project_id = p_project_id
                     AND i.draft_revenue_num =
                                  exp_cur_rec.DRAFT_REVENUE_NUM
                     AND i.line_num =
                                  exp_cur_rec.DRAFT_REVENUE_ITEM_LINE_NUM;

                l_message_code := 'Error in update on pa_expenditure_items_all';

                  UPDATE pa_expenditure_items_all x
                     SET x.accrued_revenue
                            = x.accrued_revenue - roundoff_amount
                   WHERE x.expenditure_item_id =
                                 exp_cur_rec.EXPENDITURE_ITEM_ID;
               EXCEPTION
                 WHEN OTHERS  THEN
                  RAISE;
               END;

             END LOOP;

          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                null;
             WHEN OTHERS THEN
               RAISE;
          END;
        END LOOP;
        l_message_code := 'OK toal_exp_items_processed : '||
             to_char(total_exp_items_processed)||' tot_pos : '||
             to_char(total_round_positive)||' tot_neg : '||
             to_char(total_round_negative);

x_message_code    :=  l_message_code;
x_total_exp_items :=  l_total_exp_items;

EXCEPTION
  WHEN OTHERS THEN
x_message_code := NULL;
x_total_exp_items := NULL;
    RAISE;
END adjust_rounding_error;


procedure rev_ccid_chk (P_rec_ccid      IN  NUMBER,
                        P_rev_ccid      IN  NUMBER,
                        P_rg_ccid       IN  NUMBER,
                        P_rl_ccid       IN  NUMBER,
                        P_ou_reval_flag IN  VARCHAR2,
                        P_out_status    OUT  NOCOPY VARCHAR2
                        )
IS

   l_dummy  VARCHAR2(1);

BEGIN

    SELECT 'x'
    INTO   l_dummy
    FROM   gl_code_combinations
    WHERE  code_combination_id = P_Rec_ccid;

    SELECT 'x'
    INTO   l_dummy
    FROM   gl_code_combinations
    WHERE  code_combination_id = P_Rev_ccid;

  IF P_ou_reval_flag ='Y' then

    SELECT 'x'
    INTO   l_dummy
    FROM   gl_code_combinations
    WHERE  code_combination_id = P_rg_ccid;

    SELECT 'x'
    INTO   l_dummy
    FROM   gl_code_combinations
    WHERE  code_combination_id = P_rl_ccid;

  END IF;

    p_out_status:='Y';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
         p_out_status:='N';
    WHEN OTHERS THEN
	p_out_status := NULL;
         Raise;

END rev_ccid_chk;

END pa_revenue_amt;

/
