--------------------------------------------------------
--  DDL for Package Body PA_COSTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_COSTING" AS
/* $Header: PAXCOSTB.pls 120.9 2007/02/06 12:12:00 rshaik ship $ */

-- ========================================================================
-- PROCEDURE ReverseCdl
-- ========================================================================

  PROCEDURE  ReverseCdl( X_expenditure_item_id            IN NUMBER
                       , X_billable_flag                  IN VARCHAR2
                       , X_amount                         IN NUMBER DEFAULT NULL
                       , X_quantity                       IN NUMBER DEFAULT NULL
                       , X_burdened_cost                  IN NUMBER DEFAULT NULL
                       , X_dr_ccid                        IN NUMBER DEFAULT NULL
                       , X_cr_ccid                        IN NUMBER DEFAULT NULL
                       , X_tr_source_accounted            IN VARCHAR2 DEFAULT NULL
                       , X_line_type                      IN VARCHAR2
                       , X_user                           IN NUMBER
		               , X_denom_currency_code            IN VARCHAR2
                       , X_denom_raw_cost                 IN NUMBER
                       , X_denom_burden_cost              IN NUMBER
                       , X_acct_currency_code             IN VARCHAR2
                       , X_acct_rate_date                 IN DATE
                       , X_acct_rate_type                 IN VARCHAR2
                       , X_acct_exchange_rate             IN NUMBER
                       , X_acct_raw_cost                  IN NUMBER
                       , X_acct_burdened_cost             IN NUMBER
                       , X_project_currency_code          IN VARCHAR2
                       , X_project_rate_date              IN DATE
                       , X_project_rate_type              IN VARCHAR2
                       , X_project_exchange_rate          IN NUMBER
                       , P_Projfunc_currency_code         IN VARCHAR2 default null
                       , P_Projfunc_cost_rate_date        IN DATE     default null
                       , P_Projfunc_cost_rate_type        IN VARCHAR2 default null
                       , P_Projfunc_cost_exchange_rate    IN NUMBER   default null
                       , P_project_raw_cost               IN NUMBER   default null
                       , P_project_burdened_cost          IN NUMBER   default null
                       , P_Work_Type_Id                   IN NUMBER   default null
                       , X_err_code                       IN OUT NOCOPY NUMBER
                       , X_err_stage                      IN OUT NOCOPY VARCHAR2
                       , X_err_stack                      IN OUT NOCOPY VARCHAR2
		               , p_mode                           IN VARCHAR2  default 'COSTING'
		               , X_line_num                       IN NUMBER DEFAULT NULL )   -- Bug 4374769 : A new parameter X_line_num is added.
  IS

    -- This procedure can have X_amount, X_quantity, X_burdened_cost, X_dr_ccid, X_cr_ccid parameters
    -- NULL. If it is NULL then the original values will be used while creating the new CDL.
    -- X_billable_flag will be used when called from adjustments. X_tr_source_accounted says if it
    -- is an accounted for transaction

    trx_source               VARCHAR2(30);
    gl_acct_flag             VARCHAR2(1) ;
    cdl_line_num             NUMBER ;
    max_cdl_line_num         NUMBER ;
    p_expenditure_item_id    NUMBER ;
    p_line_num               NUMBER ;
    p_transfer_status_code   VARCHAR2(30) ;
    p_amount                 NUMBER;
    p_quantity               NUMBER;
    p_billable_flag          VARCHAR2(1);
    p_request_id             NUMBER ;
    p_program_application_id NUMBER ;
    p_program_id             NUMBER ;
    p_program_update_date    DATE ;
    p_expenditure_item_date  DATE ;
    p_pa_date                DATE ;
    p_recvr_pa_date          DATE ;            /**CBGA**/
    p_dr_ccid                NUMBER  ;
    p_gl_date                DATE ;
    p_transferred_date       DATE ;
    p_transfer_rejection_reason    VARCHAR2(250);
    p_batch_name             VARCHAR2(30) ;
    p_accumulated_flag       VARCHAR2(1) ;
    p_resource_accumulated_flag       VARCHAR2(1) ;
    p_reversed_flag          VARCHAR2(1) ;
    p_line_num_reversed      NUMBER ;
    p_sys_reference1         VARCHAR2(30) ;
    p_sys_reference2         VARCHAR2(30) ;
    p_sys_reference3         VARCHAR2(30) ;
    p_cr_ccid                NUMBER;
    p_ind_compiled_set_id    NUMBER;
    p_line_type              VARCHAR2(1) ;
    p_burdened_cost          NUMBER ;
    p_denom_currency_code    VARCHAR2(15);
    p_denom_raw_cost         NUMBER;
    p_denom_burden_cost      NUMBER;
    p_acct_currency_code     VARCHAR2(15);
    p_acct_rate_date         DATE;
    p_acct_rate_type         VARCHAR2(30);
    p_acct_exchange_rate     NUMBER;
    p_acct_raw_cost          NUMBER;
    p_acct_burdened_cost     NUMBER;
    p_project_currency_code  VARCHAR2(15);
    p_project_rate_date      DATE;
    p_project_rate_type      VARCHAR2(30);
    p_project_exchange_rate  NUMBER;
    p_project_id             NUMBER;
    p_task_id                NUMBER;
    old_stack                VARCHAR2(2000);

    -- Start EPP Changes
    p_pa_period_name        VARCHAR2(15);
    p_gl_period_name        VARCHAR2(15);
    p_recvr_gl_date         DATE;
    p_recvr_gl_period_name  VARCHAR2(15);
    p_recvr_pa_period_name  VARCHAR2(15);
    -- End EPP Changes

    --Start PA-I Changes
    l_Projfunc_currency_code       VARCHAR2(15);
    l_Projfunc_cost_rate_date      DATE;
    l_Projfunc_cost_rate_type      VARCHAR2(30);
    l_Projfunc_cost_exchange_rate  NUMBER;
    l_project_raw_cost             NUMBER;
    l_project_burdened_cost        NUMBER;
    l_Work_Type_Id                 NUMBER;
    -- End PA-I Changes

    -- AP Discounts
    p_sys_reference4         VARCHAR2(30) ;
    p_sys_reference5         NUMBER ;

    /* Bug 4374769     : The l_transfer_status_code and l_line_type variables are used to set the transfer_status_code to 'G' and line_type to 'I'
                         for the reversing and new cdls created because of PJI Summarization. These variables have their default values as NULL.*/

    l_transfer_status_code   VARCHAR2(30) DEFAULT NULL ;
    l_line_type              VARCHAR2(1) DEFAULT NULL ;
    l_si_assets_addition_flag varchar2(1) default NULL ;

  BEGIN
       /* Selects the row for which a negative CDL is to be created
          Project Summarization changes : Pick up project_id, task_id and pass them to the createnewcdl procedure */

        x_err_stage := 'Get the max CDL for the exp item id' ;

       /* Bug 4374769     : The where condition in the following select statement that selects the row for which a negative CDL is to be created is modified
                           such that  when the p_mode is 'INTERFACE' it selects the line_number, that is passed to the ReverseCdl procedure through
			               the parameter X_line_num, for reversing. */


       SELECT max(cdl.line_num),
            cdl.transfer_status_code,
            cdl.amount,
            cdl.quantity,
            cdl.request_id,
            cdl.billable_flag,
            cdl.program_application_id,
            cdl.program_id,
            cdl.program_update_date,
            cdl.pa_date,
            cdl.recvr_pa_date,                /**CBGA**/
            cdl.dr_code_combination_id,
            cdl.gl_date,
            cdl.transferred_date,
            cdl.transfer_rejection_reason,
            cdl.accumulated_flag,
            cdl.resource_accumulated_flag,
            cdl.cr_code_combination_id,
            cdl.ind_compiled_set_id,
            cdl.line_type,
            NVL(cdl.burdened_cost,0) + nvl(cdl.projfunc_burdened_change,0) burdened_cost,
		    cdl.system_reference1,
		    cdl.system_reference2,
		    cdl.system_reference3,
		    cdl.denom_currency_code,
            cdl.denom_raw_cost,
		    nvl(cdl.denom_burdened_cost,0) + nvl(cdl.denom_burdened_change,0) denom_burdened_cost,
		    cdl.acct_currency_code,
		    cdl.acct_rate_date,
		    cdl.acct_rate_type,
		    cdl.acct_exchange_rate,
		    cdl.acct_raw_cost,
		    nvl(cdl.acct_burdened_cost,0) + Nvl(cdl.acct_burdened_change,0) acct_burdened_cost,
		    cdl.project_currency_code,
		    cdl.project_rate_date,
		    cdl.project_rate_type,
		    cdl.project_exchange_rate,
            cdl.project_id,
            cdl.task_id,
            cdl.pa_period_name,
            cdl.gl_period_name,
            cdl.recvr_pa_period_name,
            cdl.recvr_gl_period_name,
            cdl.recvr_gl_date,
            cdl.projfunc_currency_code,
            cdl.projfunc_cost_rate_type,
            cdl.projfunc_cost_rate_date,
            cdl.projfunc_cost_exchange_rate,
            cdl.project_raw_cost,
            nvl(cdl.project_burdened_cost,0) + nvl(cdl.project_burdened_change,0) project_burdened_cost,
            cdl.work_type_id,
            cdl.system_reference4,
            cdl.system_reference5,
	    decode(cdl.si_assets_addition_flag, 'Y','T', 'O','T', 'R', 'T',cdl.si_assets_addition_flag)
       INTO
            max_cdl_line_num                  ,
            p_transfer_status_code            ,
            p_amount                          ,
            p_quantity                        ,
            p_request_id                      ,
            p_billable_flag                   ,
            p_program_application_id          ,
            p_program_id                      ,
            p_program_update_date             ,
            p_pa_date                         ,
            p_recvr_pa_date                   ,        /**CBGA**/
            p_dr_ccid                         ,
            p_gl_date                         ,
            p_transferred_date                ,
            p_transfer_rejection_reason       ,
            p_accumulated_flag                ,
            p_resource_accumulated_flag       ,
            p_cr_ccid                         ,
            p_ind_compiled_set_id             ,
            p_line_type                       ,
            p_burdened_cost          	       ,
		    p_sys_reference1		             ,
		    p_sys_reference2		             ,
		    p_sys_reference3		             ,
    		p_denom_currency_code		       ,
    		p_denom_raw_cost    		          ,
    		p_denom_burden_cost		          ,
    		p_acct_currency_code		          ,
    		p_acct_rate_date   		          ,
    		p_acct_rate_type  		          ,
    		p_acct_exchange_rate		          ,
    		p_acct_raw_cost    		          ,
    		p_acct_burdened_cost		          ,
    		p_project_currency_code		       ,
    		p_project_rate_date   		       ,
    		p_project_rate_type  		       ,
    		p_project_exchange_rate	          ,
            p_project_id                      ,
            p_task_id
            , p_pa_period_name
            , p_gl_period_name
            , p_recvr_pa_period_name
            , p_recvr_gl_period_name
            , p_recvr_gl_date
            , l_projfunc_currency_code
            , l_projfunc_cost_rate_type
            , l_projfunc_cost_rate_date
            , l_projfunc_cost_exchange_rate
            , l_project_raw_cost
            , l_project_burdened_cost
            , l_work_type_id
            , p_sys_reference4
            , p_sys_reference5
	    , l_si_assets_addition_flag
       FROM
            -- pa_cost_distribution_lines cdl -- 12i MOAC changes
            pa_cost_distribution_lines_All cdl
       WHERE  cdl.expenditure_item_id = X_expenditure_item_id
       AND  DECODE(p_mode,'INTERFACE',NULL,cdl.line_num_reversed)   IS NULL  -- Bug 4374769
       AND  DECODE(p_mode,'INTERFACE',NULL,cdl.reversed_flag)       IS NULL  -- Bug 4374769
       AND  cdl.line_type           = X_line_type
	   AND  cdl.line_num = DECODE ( p_mode, 'INTERFACE', X_line_num, cdl.line_num) -- Bug 4374769
/* Added this Not exists Clause for the bug 5509019 */
		   AND  NOT EXISTS (select 1 from pa_cost_distribution_lines_all cdl1
		                    where  cdl1.expenditure_item_id = cdl.expenditure_item_id
				    and    cdl1.line_num_reversed = cdl.line_num
				    and    cdl1.transfer_status_code = 'G'
				    and    cdl1.line_type = 'I'
				    and    cdl1.pji_summarized_flag = 'N'
				    and    p_mode = 'INTERFACE')
GROUP BY cdl.transfer_status_code,
                cdl.amount,
                cdl.quantity,
                cdl.request_id,
                cdl.billable_flag,
                cdl.program_application_id,
                cdl.program_id,
                cdl.program_update_date,
                cdl.pa_date,
                cdl.recvr_pa_date,              /**CBGA**/
                cdl.dr_code_combination_id,
                cdl.gl_date,
                cdl.transferred_date,
                cdl.transfer_rejection_reason,
                cdl.accumulated_flag,
                cdl.resource_accumulated_flag,
                cdl.cr_code_combination_id,
                cdl.ind_compiled_set_id,
                cdl.line_type,
                nvl(cdl.burdened_cost,0) + nvl(cdl.projfunc_burdened_change,0),
			    cdl.system_reference1,
			    cdl.system_reference2,
			    cdl.system_reference3,
		 	    cdl.denom_currency_code,
                cdl.denom_raw_cost,
			    NVL(cdl.denom_burdened_cost,0) + nvl(cdl.denom_burdened_change,0),
			    cdl.acct_currency_code,
			    cdl.acct_rate_date,
			    cdl.acct_rate_type,
			    cdl.acct_exchange_rate,
			    cdl.acct_raw_cost,
			    NVL(cdl.acct_burdened_cost,0) + nvl(cdl.acct_burdened_change,0),
			    cdl.project_currency_code,
			    cdl.project_rate_date,
			    cdl.project_rate_type,
			    cdl.project_exchange_rate,
                cdl.project_id,
                cdl.task_id,
                cdl.pa_period_name,
                cdl.gl_period_name,
                cdl.recvr_pa_period_name,
                cdl.recvr_gl_period_name,
                cdl.recvr_gl_date,
                cdl.projfunc_currency_code,
                cdl.projfunc_cost_rate_type,
                cdl.projfunc_cost_rate_date,
                cdl.projfunc_cost_exchange_rate,
                cdl.project_raw_cost,
                NVL(cdl.project_burdened_cost,0) + nvl(cdl.project_burdened_change,0),
                cdl.work_type_id ,
                cdl.system_reference4,
                cdl.system_reference5,
	        decode(cdl.si_assets_addition_flag, 'Y','T', 'O','T', 'R', 'T',cdl.si_assets_addition_flag) ;

      /* Update the reverse flag of the CDL */

      x_err_stage := 'Updating the reverse flag' ;
      x_err_stack := x_err_stack||'-> Update the reverse flag';

      /* Bug 4374769     : If p_mode is 'INTERFACE' i.e if the reversing and new cdls are created because of PJI summarization then the reversed_flag is
                           kept as NULL on the original cdl. */

      If p_mode <> 'INTERFACE' Then
      UPDATE pa_cost_distribution_lines_all
      SET    reversed_flag = 'Y'
      WHERE  expenditure_item_id = X_expenditure_item_id
        AND  line_num            = max_cdl_line_num ;
      end if;

     /* Create the new reversing CDL */

	/* bug 2891527 */
	If p_mode = 'VIADJUST' Then
	p_transfer_status_code := 'G';
	end if;
	/* bug 2891527 */

/* Bug 5561542 - Start */
        If p_mode = 'WORK_TYP_ADJ' Then
          p_transfer_status_code := 'P';
        end if;
/* Bug 5561542 - End */

     x_err_stage := 'Create reverse CDL' ;
     x_err_stack := x_err_stack||'-> Create reverse CDL';

     /* Bug 4374769 :     If p_mode is 'INTERFACE' i.e if the reversing and new cdls are created because of PJI summarization , then the
                          transfer_status_code is set to 'G' and line_type to 'I' for the reversing and new cdls. */

     If P_mode = 'INTERFACE' Then
		l_transfer_status_code := 'G';
		l_line_type := 'I';
     End If;

     Pa_Costing.CreateNewCdl(
          X_expenditure_item_id         =>	X_expenditure_item_id
        , X_amount                      =>	-p_amount
        , X_dr_ccid                     =>	p_dr_ccid
        , X_cr_ccid                     =>	p_cr_ccid
        , X_transfer_status_code        =>	NVL(l_transfer_status_code, p_transfer_status_code) -- Bug 4374769
        , X_quantity                    =>	-p_quantity
        , X_billable_flag               =>	p_billable_flag
        , X_request_id                  =>	p_request_id
        , X_program_application_id      =>	p_program_application_id
        , x_program_id                  =>	p_program_id
        , x_program_update_date         =>	p_program_update_date
        , X_pa_date                     =>	p_pa_date
        , X_recvr_pa_date               =>	p_recvr_pa_date              /**CBGA**/
        , X_gl_date                     =>	p_gl_date
        , X_transferred_date            =>	p_transferred_date
        , X_transfer_rejection_reason   =>	p_transfer_rejection_reason
        , X_line_type                   =>	NVL(l_line_type,p_line_type) -- Bug 4374769
        , X_ind_compiled_set_id         =>	p_ind_compiled_set_id
        , X_burdened_cost               =>	-p_burdened_cost
        , X_line_num_reversed           =>	max_cdl_line_num
        , X_reverse_flag                =>	NULL      /* Bug 3668005 :Modified from 'Y' to NULL */
        , X_user                        =>	X_user
        , X_err_code                    =>	X_err_code
        , X_err_stage                   =>	X_err_stage
        , X_err_stack                   =>	X_err_stack
        , X_project_id                  =>	p_project_id
        , X_task_id                     =>	p_task_id
        , X_cdlsr1                      =>	p_sys_reference1
        , X_cdlsr2                      =>	p_sys_reference2
        , X_cdlsr3                      =>	p_sys_reference3
        , X_denom_currency_code         =>	p_denom_currency_code
        , X_denom_raw_cost              =>	-p_denom_raw_cost
        , X_denom_burden_cost           =>	-p_denom_burden_cost
        , X_acct_currency_code          =>	p_acct_currency_code
        , X_acct_rate_date              =>	p_acct_rate_date
        , X_acct_rate_type              =>	p_acct_rate_type
        , X_acct_exchange_rate          =>	p_acct_exchange_rate
        , X_acct_raw_cost               =>	-p_acct_raw_cost
        , X_acct_burdened_cost          =>	-p_acct_burdened_cost
        , X_project_currency_code       =>	p_project_currency_code
        , X_project_rate_date           =>	p_project_rate_date
        , X_project_rate_type           =>	p_project_rate_type
        , X_project_exchange_rate       =>	p_project_exchange_rate
        , P_PaPeriodName                =>      P_Pa_Period_Name
        , P_RecvrPaPeriodName           =>      P_Recvr_Pa_Period_Name
        , P_GlPeriodName                =>      P_Gl_Period_Name
        , P_RecvrGlDate                 =>      P_Recvr_Gl_Date
        , P_RecvrGlPeriodName           =>      P_Recvr_Gl_Period_Name
        , P_Projfunc_currency_code      =>      l_Projfunc_currency_code
        , P_Projfunc_cost_rate_date     =>      l_Projfunc_cost_rate_date
        , P_Projfunc_cost_rate_type     =>      l_Projfunc_cost_rate_type
        , P_Projfunc_cost_exchange_rate =>      l_Projfunc_cost_exchange_rate
        , P_Project_Raw_Cost            =>      -l_Project_Raw_Cost
        , P_Project_Burdened_Cost       =>      -l_Project_Burdened_Cost
        , P_Work_Type_Id                =>      l_Work_Type_Id
        , p_mode                        =>      p_mode
        , p_cdlsr4                      =>	p_sys_reference4
	, p_si_assets_addition_flag     =>      l_si_assets_addition_flag
        , p_cdlsr5                      =>      p_sys_reference5 );

     /* Assign the new values */

     if x_amount is not null then
        p_amount := x_amount ;
     end if;

     if x_dr_ccid is not null then
        p_dr_ccid := x_dr_ccid ;
     end if;

     if x_cr_ccid is not null then
        p_cr_ccid := x_cr_ccid ;
     end if;

     if nvl(x_tr_source_accounted, 'N') = 'N' then
        p_transfer_status_code := 'P' ;
     end if ;

     if x_quantity is not null then
        p_quantity := x_quantity ;
     end if;

     if x_burdened_cost is not null then
        p_burdened_cost := x_burdened_cost ;
     end if;

     if x_denom_raw_cost is not null then
        p_denom_raw_cost := x_denom_raw_cost;
     end if;

     if x_denom_burden_cost is not null then
        p_denom_burden_cost := x_denom_burden_cost;
     end if;

     if x_acct_raw_cost is not null then
        p_acct_raw_cost := x_acct_raw_cost;
     end if;

     if x_acct_burdened_cost is not null then
        p_acct_burdened_cost := x_acct_burdened_cost;
     end if;

     if p_project_raw_cost is not null then
        l_project_raw_cost := p_project_raw_cost;
     end if;

     if p_project_burdened_cost is not null then
        l_project_burdened_cost := p_project_burdened_cost;
     end if;

     if p_work_type_id is not null then
        l_work_type_id := p_work_type_id;
     end if;

     /** added this condition as the transaction adjustment api passes null for
      *  for this column for the work type adjustments
      **/
      If X_billable_flag is NOT NULL then
       p_billable_flag := X_billable_flag;
      End if;

	/* bug 2891527 */
	If p_mode = 'VIADJUST' Then
	select cost_ind_compiled_set_id
	into p_ind_compiled_set_id
	from pa_expenditure_items_all
	where expenditure_item_id = X_expenditure_item_id;
	end if;
	/* bug 2891527 */

     /* Create a new CDL                       */
     x_err_stage := 'Creating a new CDL';
     x_err_stack := x_err_stack||'-> Create new CDL';

     IF l_si_assets_addition_flag = 'N' THEN
        l_si_assets_addition_flag := 'T' ;
     END IF ;

     Pa_Costing.CreateNewCdl(
          X_expenditure_item_id         =>	X_expenditure_item_id
        , X_amount                      =>	p_amount
        , X_dr_ccid                     =>	p_dr_ccid
        , X_cr_ccid                     =>	p_cr_ccid
        , X_transfer_status_code        =>	NVL(l_transfer_status_code,p_transfer_status_code) -- Bug 4374769
        , X_quantity                    =>	p_quantity
        , X_billable_flag               =>	p_billable_flag  /** changed x_bill to p_bil **/
        , X_request_id                  =>	p_request_id
        , X_program_application_id      =>	p_program_application_id
        , x_program_id                  =>	p_program_id
        , x_program_update_date         =>	p_program_update_date
        , X_pa_date                     =>	p_pa_date
        , X_recvr_pa_date               =>	p_recvr_pa_date                /**CBGA**/
        , X_gl_date                     =>	p_gl_date
        , X_transferred_date            =>	p_transferred_date
        , X_transfer_rejection_reason   =>	p_transfer_rejection_reason
        , X_line_type                   =>	NVL(l_line_type,p_line_type) -- Bug 4374769
        , X_ind_compiled_set_id         =>	p_ind_compiled_set_id
        , X_burdened_cost               =>	p_burdened_cost
        , X_line_num_reversed           =>	NULL
        , X_reverse_flag                =>	NULL
        , X_user                        =>	X_user
        , X_err_code                    =>	X_err_code
        , X_err_stage                   =>	X_err_stage
        , X_err_stack                   =>	X_err_stack
        , X_project_id                  =>	p_project_id
        , X_task_id                     =>	p_task_id
        , X_cdlsr1                      =>	p_sys_reference1
        , X_cdlsr2                      =>	p_sys_reference2
        , X_cdlsr3                      =>	p_sys_reference3
        , X_denom_currency_code         =>	p_denom_currency_code
        , X_denom_raw_cost              =>	p_denom_raw_cost
        , X_denom_burden_cost           =>	p_denom_burden_cost
        , X_acct_currency_code          =>	p_acct_currency_code
        , X_acct_rate_date              =>	p_acct_rate_date
        , X_acct_rate_type              =>	p_acct_rate_type
        , X_acct_exchange_rate          =>	p_acct_exchange_rate
        , X_acct_raw_cost               =>	p_acct_raw_cost
        , X_acct_burdened_cost          =>	p_acct_burdened_cost
        , X_project_currency_code       =>	p_project_currency_code
        , X_project_rate_date           =>	p_project_rate_date
        , X_project_rate_type           =>	p_project_rate_type
        , X_project_exchange_rate       =>	p_project_exchange_rate
        , P_PaPeriodName                =>      P_Pa_Period_Name
        , P_RecvrPaPeriodName           =>      P_Recvr_Pa_Period_Name
        , P_GlPeriodName                =>      P_Gl_Period_Name
        , P_RecvrGlDate                 =>      P_Recvr_Gl_Date
        , P_RecvrGlPeriodName           =>      P_Recvr_Gl_Period_Name
        , P_Projfunc_currency_code      =>      l_Projfunc_currency_code
        , P_Projfunc_cost_rate_date     =>      l_Projfunc_cost_rate_date
        , P_Projfunc_cost_rate_type     =>      l_Projfunc_cost_rate_type
        , P_Projfunc_cost_exchange_rate =>      l_Projfunc_cost_exchange_rate
        , P_Project_Raw_Cost            =>      l_Project_Raw_Cost
        , P_Project_Burdened_Cost       =>      l_Project_Burdened_Cost
        , P_Work_Type_Id                =>      l_Work_Type_Id
	    , p_mode                        =>      p_mode
        , p_cdlsr4                      =>      p_sys_reference4
	, p_si_assets_addition_flag     =>      l_si_assets_addition_flag
        , p_cdlsr5                      =>      p_sys_reference5 )   ; -- Bug 5561542

      x_err_stack := old_stack ;

  EXCEPTION
    WHEN  OTHERS  THEN
      X_err_code := SQLCODE;
      RAISE;

  END  ReverseCdl;


-- ========================================================================
-- PROCEDURE CreateNewCdl  due to bug 666884. this procedure handle 3 system refs.
-- ========================================================================

  PROCEDURE  CreateNewCdl( X_expenditure_item_id         IN NUMBER
                         , X_amount                      IN NUMBER
                         , X_dr_ccid                     IN NUMBER
                         , X_cr_ccid                     IN NUMBER
                         , X_transfer_status_code        IN VARCHAR2
                         , X_quantity                    IN NUMBER
                         , X_billable_flag               IN VARCHAR2
                         , X_request_id                  IN NUMBER
                         , X_program_application_id      IN NUMBER
                         , x_program_id                  IN NUMBER
                         , x_program_update_date         IN DATE
                         , X_pa_date                     IN DATE
                         , X_recvr_pa_date               IN DATE        /**CBGA**/
                         , X_gl_date                     IN DATE
                         , X_transferred_date            IN DATE
                         , X_transfer_rejection_reason   IN VARCHAR2
                         , X_line_type                   IN VARCHAR2
                         , X_ind_compiled_set_id         IN NUMBER
                         , X_burdened_cost               IN NUMBER
                         , X_line_num_reversed           IN NUMBER
                         , X_reverse_flag                IN VARCHAR2
                         , X_user                        IN NUMBER
                         , X_err_code                    IN OUT NOCOPY NUMBER
                         , X_err_stage                   IN OUT NOCOPY VARCHAR2
                         , X_err_stack                   IN OUT NOCOPY VARCHAR2
                         , X_project_id                  IN NUMBER
                         , X_task_id                     IN NUMBER
                         , X_cdlsr1                      IN VARCHAR2 default null
                         , X_cdlsr2                      IN VARCHAR2 default null
                         , X_cdlsr3                      IN VARCHAR2 default null
		                 , X_denom_currency_code         IN VARCHAR2 default null
                         , X_denom_raw_cost              IN NUMBER   default null
                         , X_denom_burden_cost           IN NUMBER   default null
                         , X_acct_currency_code          IN VARCHAR2 default null
                         , X_acct_rate_date              IN DATE     default null
                         , X_acct_rate_type              IN VARCHAR2 default null
			             , X_acct_exchange_rate          IN NUMBER   default null
                         , X_acct_raw_cost               IN NUMBER   default null
                         , X_acct_burdened_cost          IN NUMBER   default null
                         , X_project_currency_code       IN VARCHAR2 default null
                         , X_project_rate_date           IN DATE     default null
                         , X_project_rate_type           IN VARCHAR2 default null
                         , X_project_exchange_rate       IN NUMBER   default null
                         , P_PaPeriodName              IN Varchar2 default null
                         , P_RecvrPaPeriodName         IN Varchar2 default null
                         , P_GlPeriodName              IN Varchar2 default null
                         , P_RecvrGlDate               IN DATE     default null
                         , P_RecvrGlPeriodName         IN Varchar2 default null
                         , P_Projfunc_currency_code    IN VARCHAR2 default null
                         , P_Projfunc_cost_rate_date        IN DATE     default null
                         , P_Projfunc_cost_rate_type        IN VARCHAR2 default null
                         , P_Projfunc_cost_exchange_rate    IN NUMBER   default null
                         , P_project_raw_cost          IN NUMBER   default null
                         , P_project_burdened_cost     IN NUMBER   default null
                         , P_Work_Type_Id              IN NUMBER   default null
			             , p_mode                      IN VARCHAR2 default 'COSTING'
                         , p_cdlsr4                      IN VARCHAR2 default null
			 , p_si_assets_addition_flag   IN VARCHAR2 default NULL
                         , p_cdlsr5                    IN NUMBER   default NULL
			 , P_Parent_Line_Num           IN NUMBER DEFAULT NULL)
IS

        new_cdl_line_num     NUMBER ;
        old_stack            VARCHAR2(2000);

        /* bug 3149022 */
        l_ei_date               DATE := NULL;
        l_exp_id                NUMBER := NULL;
        l_sys_link_function     VARCHAR2(3) := NULL;
        l_org_id                pa_expenditure_items.org_id%type := NULL;
        l_recvr_org_id          pa_expenditure_items.org_id%type := NULL;
        l_sob_id                NUMBER := NULL;
        l_recvr_sob_id          NUMBER := NULL;
        l_pa_date               DATE := NULL;
        l_pa_period_name        VARCHAR2(15) := NULL;
        l_gl_date               DATE := NULL;
        l_gl_period_name        VARCHAR2(15) := NULL;
        l_recvr_pa_date         DATE  := NULL;
        l_recvr_pa_period_name  VARCHAR2(15) := NULL;
        l_recvr_gl_date         DATE := NULL;
        l_recvr_gl_period_name  VARCHAR2(15) := NULL;
        /* l_err_code              NUMBER; bug fix: 3258043 */
        l_err_code              VARCHAR2(100) := NULL;
        l_err_stage             NUMBER := NULL;
        l_status                NUMBER := NULL;
        /* bug 3149022 */

  BEGIN
	-- Initialize the error stack
	pa_cc_utils.set_curr_function('PA_COSTING.CreateNewCdl');
    /* Bug 3149022 */

    SELECT ITEMS.expenditure_item_date
          ,ITEMS.org_id
          ,NVL(ITEMS.recvr_org_id , ITEMS.ORG_ID)
          ,ITEMS.system_linkage_function
          ,ITEMS.expenditure_id
    INTO   l_ei_date
          ,l_org_id
          ,l_recvr_org_id
          ,l_sys_link_function
          ,l_exp_id
    -- FROM   pa_expenditure_items ITEMS -- 12i MOAC changes
    FROM   pa_expenditure_items_All ITEMS
    WHERE  ITEMS.expenditure_item_id = X_expenditure_item_id;

    SELECT	imp1.set_of_books_id, imp2.set_of_books_id
    INTO	l_sob_id, l_recvr_sob_id
    FROM	pa_implementations_all imp1, pa_implementations_all imp2
    -- start 12i MOAC changes
    -- WHERE	nvl(imp1.org_id,-99) = nvl(l_org_id,-99)
    -- AND	    nvl(imp2.org_id,-99) = nvl(l_recvr_org_id,-99);
    WHERE   imp1.org_id = l_org_id
    AND     imp2.org_id = l_recvr_org_id;
    -- end 12i MOAC changes


-- call get_period_information only for the following cases, bug 3357936
    IF (p_mode = 'RECLASS' OR p_mode = 'WORK_TYP_ADJ' OR p_mode = 'TRXADJUST')
    THEN
	PA_UTILS2.get_period_information(
          	 p_expenditure_item_date => l_ei_date
       		,p_expenditure_id => l_exp_id
        	,p_system_linkage_function => l_sys_link_function
        	,p_line_type => x_line_type
        	,p_prvdr_raw_pa_date => X_pa_date
        	,p_recvr_raw_pa_date => X_recvr_pa_date
        	,p_prvdr_raw_gl_date => X_gl_date
        	,p_recvr_raw_gl_date => P_RecvrGlDate
        	,p_prvdr_org_id => l_org_id
        	,p_recvr_org_id => l_recvr_org_id
        	,p_prvdr_sob_id => l_sob_id
        	,p_recvr_sob_id => l_recvr_sob_id
        	,p_calling_module => 'CDL'
        	,x_prvdr_pa_date => l_pa_date
        	,x_prvdr_pa_period_name => l_pa_period_name
        	,x_prvdr_gl_date => l_gl_date
        	,x_prvdr_gl_period_name => l_gl_period_name
        	,x_recvr_pa_date => l_recvr_pa_date
        	,x_recvr_pa_period_name => l_recvr_pa_period_name
        	,x_recvr_gl_date => l_recvr_gl_date
        	,x_recvr_gl_period_name => l_recvr_gl_period_name
        	,x_error_code => l_err_code
        	,x_return_status => l_status
        	,x_error_stage => l_err_stage );

    /****** Bug 3668005 : Will be executed only during interface for NEW CDLs. ******/
    ElsIf (p_mode='INTERFACE' and X_line_num_reversed IS NULL and X_reverse_flag is NULL) Then
        Select
                pa_utils2.get_prvdr_gl_date(
                                         X_gl_date
                                        ,decode(EI.system_linkage_function
				                               , 'VI', 200
				                               , 101)  -- GL Application ID = 101 and AP Application Id = 200 .
                                        ,l_sob_id)  gl_date,
                 pa_utils2.get_gl_period_name (
                                        pa_utils2.get_prvdr_gl_date(
                                           X_gl_date
					                      ,decode(EI.system_linkage_function
                                                  , 'VI', 200
                                                  , 101)
                                          ,l_sob_id)
                                        ,EI.org_id) gl_period_name,
                 pa_utils2.get_recvr_gl_date(
                                        P_RecvrGlDate
				                       ,decode(EI.system_linkage_function
                                              , 'VI', 200
                                              , 101)
                                       ,l_recvr_sob_id) recvr_gl_date,
                 pa_utils2.get_gl_period_name (
                                        pa_utils2.get_recvr_gl_date(
                                                P_RecvrGlDate
					                           ,decode(EI.system_linkage_function
							                          , 'VI', 200
							                          , 101)
                                               ,l_recvr_sob_id)
                                        ,nvl(EI.recvr_org_id,EI.org_id)) recvr_gl_period_name
        Into l_gl_date,
             l_gl_period_name,
             l_recvr_gl_date,
             l_recvr_gl_period_name
        -- From PA_Expenditure_items EI, -- 12i MOAC changes
        From PA_Expenditure_items_All EI /* Bug 5353670 / PQE Bug 5248665
		PA_Implementations_All IMP */
        Where EI.expenditure_item_id = X_expenditure_item_id;
	           /* AND   NVL(EI.recvr_org_id,EI.ORG_ID)  = IMP.org_id;  Bug 5353670 / PQE Bug 5248665  */

    END IF;

    /****** Bug 3668005 Ends ******/

/* Bug 3149022 */

    old_stack := X_err_stack ;
    /* Get the maximum line number for the CDL             */

    X_err_stack := X_err_stack ||'->Max_line_num' ;
    X_err_stage := '-> Get new CDL line num';

    SELECT max(cdl.line_num)
      INTO new_cdl_line_num
      FROM pa_cost_distribution_lines cdl
     WHERE cdl.expenditure_item_id = X_expenditure_item_id ;

    /* Create the new reversing CDL         */

    X_err_stack := X_err_stack ||'->Max_line_num' ;
    X_err_stage := '-> Insert row in CDL table';
    pa_cc_utils.log_message('Gl Accounted Flag['||PA_TRANSACTIONS.GL_ACCOUNTED_FLAG||
			   ']l_gl_date['||l_gl_date||']x_gl_date['||x_gl_date||']');

    -- Insert into pa_cost_distribution_lines
    Insert into pa_cost_distribution_lines_All
                ( line_num
                , parent_line_num
                , expenditure_item_id
                , amount
                , dr_code_combination_id
                , cr_code_combination_id
                , line_type
                , ind_compiled_set_id
                , burdened_cost
                , transfer_status_code
                , quantity
                , billable_flag
                , creation_date
                , created_by
                , request_id
                , program_application_id
                , program_id
                , program_update_date
                , pa_date
                , recvr_pa_date                 /**CBGA**/
                , gl_date
                , transferred_date
                , transfer_rejection_reason
                , accumulated_flag
                , resource_accumulated_flag
                , reversed_flag
                , line_num_reversed
                , burden_sum_source_run_id
                , system_reference1
                , system_reference2
                , system_reference3
            	, denom_currency_code
                , denom_raw_cost
                , denom_burdened_cost
                , acct_currency_code
                , acct_rate_date
                , acct_rate_type
                , acct_exchange_rate
                , acct_raw_cost
                , acct_burdened_cost
                , project_currency_code
                , project_rate_date
                , project_rate_type
                , project_exchange_rate
                , project_id
                , task_id
                , Pa_Period_Name
                , Recvr_Pa_Period_Name
                , Gl_Period_Name
                , Recvr_Gl_Date
                , Recvr_Gl_Period_Name
                , Projfunc_currency_code
                , Projfunc_cost_rate_date
                , Projfunc_cost_rate_type
                , Projfunc_cost_exchange_rate
                , Project_raw_cost
                , Project_burdened_cost
                , Work_type_id
                , util_summarized_flag
                , system_reference4
                , system_reference5
		        , pji_summarized_flag    /* Bug 3668005 :Added */
                , org_id -- 12i MOAC changes
		, si_assets_addition_flag
                )
         Values
                ( nvl(new_cdl_line_num, 0) + 1
                , P_Parent_Line_Num
                , X_expenditure_item_id
                , x_amount
                , x_dr_ccid
                , x_cr_ccid
                , x_line_type
                , x_ind_compiled_set_id
                , x_burdened_cost
                , decode(p_mode,'TRXADJUST','G',x_transfer_status_code)
                , x_quantity
                , x_billable_flag
                , sysdate
                , X_user
                , x_request_id
                , x_program_application_id
                , x_program_id
                , x_program_update_date
                , NVL(l_pa_date, X_pa_date)		    /* X_pa_date ** bug 3357936 */
                , NVL(l_recvr_pa_date, X_recvr_pa_date)	    /* X_recvr_pa_date ** bug 3357936 */ /**CBGA**/
                , NVL(l_gl_date, X_gl_date)  /* X_gl_date ** bug 3357936 */
                , X_transferred_date
                , x_transfer_rejection_reason
                , decode(p_mode,'TRXADJUST','Y','N') -- Accumalated flag
                , decode(p_mode,'TRXADJUST','Y','N') -- Resource accumalated flag
                , x_reverse_flag
                , X_line_num_reversed
                , -9999
                , X_cdlsr1
                , X_cdlsr2
                , X_cdlsr3
		        , X_denom_currency_code
                , X_denom_raw_cost
                , X_denom_burden_cost
                , X_acct_currency_code
                , X_acct_rate_date
                , X_acct_rate_type
                , X_acct_exchange_rate
                , X_acct_raw_cost
                , X_acct_burdened_cost
                , X_project_currency_code
                , X_project_rate_date
                , X_project_rate_type
                , X_project_exchange_rate
                , X_project_id
                , X_task_id
                , NVL(l_pa_period_name,  P_PaPeriodName)	/* P_PaPeriodName ** bug 3357936 */
                , NVL(l_recvr_pa_period_name, P_RecvrPaPeriodName) /* P_RecvrPaPeriodName ** bug 3357936 */
				/* Bug fix: 3258043 added decode to populate original GL info for accounted imported trans */
                , NVL(l_gl_period_name, P_GlPeriodName)
						/* P_GlPeriodName ** bug 3357936 */
                , NVL(l_recvr_gl_date, P_RecvrGlDate)
						/* P_RecvrGlDate ** bug 3357936 */
                , NVL(l_recvr_gl_period_name, P_RecvrGlPeriodName)
						/* P_RecvrGlPeriodName ** bug 3357936 */
                , P_Projfunc_currency_code
                , P_Projfunc_cost_rate_date
                , P_Projfunc_cost_rate_type
                , P_Projfunc_cost_exchange_rate
                , P_Project_raw_cost
                , P_Project_burdened_cost
                , P_Work_type_id
		        , decode(p_mode,'TRXADJUST','N','N')
                , p_cdlsr4
                , p_cdlsr5
		        , 'N'		/* Bug 3668005 :Added */
                , l_org_id -- 12i MOAC changes
		, p_si_assets_addition_flag
                ) ;

        X_err_stack := old_stack ;

	pa_cc_utils.reset_curr_function;

  EXCEPTION
    WHEN  OTHERS  THEN
      X_err_code := SQLCODE;
      RAISE;
  END CreateNewCdl ;

-- ========================================================================
-- PROCEDURE CreateExternalCdl
-- ========================================================================

  PROCEDURE  CreateExternalCdl( X_expenditure_item_id       IN NUMBER
                        , X_ei_date                   IN DATE
                        , X_amount                    IN NUMBER
                        , X_dr_ccid                   IN NUMBER
                        , X_cr_ccid                   IN NUMBER
                        , X_transfer_status_code      IN VARCHAR2
                        , X_quantity                  IN NUMBER
                        , X_billable_flag             IN VARCHAR2
                        , X_request_id                IN NUMBER
                        , X_program_application_id    IN NUMBER
                        , x_program_id                IN NUMBER
                        , x_program_update_date       IN DATE
                        , X_pa_date                   IN DATE
                        , X_recvr_pa_date             IN DATE                  /**CBGA**/
                        , X_gl_date                   IN DATE
                        , X_transferred_date          IN DATE
                        , X_transfer_rejection_reason IN VARCHAR2
                        , X_line_type                 IN VARCHAR2
                        , X_ind_compiled_set_id       IN NUMBER
                        , X_burdened_cost             IN NUMBER
                        , X_user                      IN NUMBER
                        , X_project_id                IN NUMBER
                        , X_task_id                   IN NUMBER
                        , X_cdlsr1                    IN VARCHAR2 default null
                        , X_cdlsr2                    IN VARCHAR2 default null
                        , X_cdlsr3                    IN VARCHAR2 default null
		                , X_denom_currency_code       IN VARCHAR2 default null
                        , X_denom_raw_cost            IN NUMBER   default null
                        , X_denom_burden_cost         IN NUMBER   default null
                        , X_acct_currency_code        IN VARCHAR2 default null
                        , X_acct_rate_date            IN DATE     default null
                        , X_acct_rate_type            IN VARCHAR2 default null
                        , X_acct_exchange_rate        IN NUMBER   default null
                        , X_acct_raw_cost             IN NUMBER   default null
                        , X_acct_burdened_cost        IN NUMBER   default null
                        , X_project_currency_code     IN VARCHAR2 default null
                        , X_project_rate_date         IN DATE     default null
                        , X_project_rate_type         IN VARCHAR2 default null
                        , X_project_exchange_rate     IN NUMBER   default null
                        , P_PaPeriodName              IN Varchar2 default null
                        , P_RecvrPaPeriodName         IN Varchar2 default null
                        , P_GlPeriodName              IN Varchar2 default null
                        , P_RecvrGlDate               IN DATE     default null
                        , P_RecvrGlPeriodName         IN Varchar2 default null
                        , P_Projfunc_currency_code    IN VARCHAR2 default null
                        , P_Projfunc_cost_rate_date        IN DATE     default null
                        , P_Projfunc_cost_rate_type        IN VARCHAR2 default null
                        , P_Projfunc_cost_exchange_rate    IN NUMBER   default null
                        , P_project_raw_cost          IN NUMBER   default null
                        , P_project_burdened_cost     IN NUMBER   default null
                        , P_Work_Type_Id              IN NUMBER   default null
                        , p_cdlsr4                      IN VARCHAR2 default null
			, p_si_assets_addition_flag   in VARCHAR2 default null
                        , p_cdlsr5                    IN NUMBER   default null
		        , X_err_code                  IN OUT NOCOPY NUMBER
                        , X_err_stage                 IN OUT NOCOPY VARCHAR2
                        , X_err_stack                 IN OUT NOCOPY VARCHAR2 )
  IS
  BEGIN

/** CBGA **/
     if (x_pa_date IS NULL) then
            x_err_code := -20009 ;
            raise_application_error( -20009, 'INVALID_PA_DATE') ;
     end if;

     if (x_recvr_pa_date IS NULL) then
            x_err_code := -20010 ;
            raise_application_error( -20010, 'INVALID_RECVR_PA_DATE') ;
     end if;
     -- Insert into PA_Cost_Distribution_lines

     x_err_stage := 'Insert into PA_Cost_Disctribution_Lines';
     Pa_Costing.CreateNewCdl (
          X_expenditure_item_id         =>	x_expenditure_item_id
        , X_amount                      =>	x_amount
        , X_dr_ccid                     =>	x_dr_ccid
        , X_cr_ccid                     =>	x_cr_ccid
        , X_transfer_status_code        =>	x_transfer_status_code
        , X_quantity                    =>	x_quantity
        , X_billable_flag               =>	x_billable_flag
        , X_request_id                  =>	x_request_id
        , X_program_application_id      =>	x_program_application_id
        , x_program_id                  =>	x_program_id
        , x_program_update_date         =>	x_program_update_date
        , X_pa_date                     =>	x_pa_date
        , X_recvr_pa_date               =>	x_recvr_pa_date                         /**CBGA**/
        , X_gl_date                     =>	x_gl_date
        , X_transferred_date            =>	x_transferred_date
        , X_transfer_rejection_reason   =>	x_transfer_rejection_reason
        , X_line_type                   =>	x_line_type
        , X_ind_compiled_set_id         =>	x_ind_compiled_set_id
        , X_burdened_cost               =>	x_burdened_cost
        , X_line_num_reversed           =>	NULL
        , X_reverse_flag                =>	NULL
        , X_user                        =>	x_user
        , X_err_code                    =>	x_err_code
        , X_err_stage                   =>	x_err_stage
        , X_err_stack                   =>	x_err_stack
        , X_project_id                  =>	x_project_id
        , X_task_id                     =>	x_task_id
        , X_cdlsr1                      =>	X_cdlsr1
        , X_cdlsr2                      =>	X_cdlsr2
        , X_cdlsr3                      =>	X_cdlsr3
        , X_denom_currency_code         =>	X_denom_currency_code
        , X_denom_raw_cost              =>	X_denom_raw_cost
        , X_denom_burden_cost           =>	X_denom_burden_cost
        , X_acct_currency_code          =>	X_acct_currency_code
        , X_acct_rate_date              =>	X_acct_rate_date
        , X_acct_rate_type              =>	X_acct_rate_type
        , X_acct_exchange_rate          =>	X_acct_exchange_rate
        , X_acct_raw_cost               =>	X_acct_raw_cost
        , X_acct_burdened_cost          =>	X_acct_burdened_cost
        , X_project_currency_code       =>	X_project_currency_code
        , X_project_rate_date           =>	X_project_rate_date
        , X_project_rate_type           =>	X_project_rate_type
        , X_project_exchange_rate       =>	X_project_exchange_rate
        , P_PaPeriodName                =>  P_PaPeriodName
        , P_RecvrPaPeriodName           =>  P_RecvrPaPeriodName
        , P_GlPeriodName                =>  P_GlPeriodName
        , P_RecvrGlDate                 =>  P_RecvrGlDate
        , P_RecvrGlPeriodName           =>  P_RecvrGlPeriodName
        , P_Projfunc_currency_code      =>  P_Projfunc_currency_code
        , P_Projfunc_cost_rate_date     =>  P_Projfunc_cost_rate_date
        , P_Projfunc_cost_rate_type     =>  P_Projfunc_cost_rate_type
        , P_Projfunc_cost_exchange_rate =>  P_Projfunc_cost_exchange_rate
        , P_Project_Raw_Cost            =>  P_Project_Raw_Cost
        , P_Project_Burdened_Cost       =>  P_Project_Burdened_Cost
        , P_Work_Type_Id                =>  P_Work_Type_Id
        , p_cdlsr4                      =>  p_cdlsr4
	, p_si_assets_addition_flag     =>  p_si_assets_addition_flag
	, p_cdlsr5                      =>  p_cdlsr5)   ;

	if (x_err_code <> 0) then
	   return;
	end if;

  EXCEPTION
     When OTHERS then
         RAISE ;
  END CreateExternalCdl ;

  FUNCTION Is_Accounted(X_Transaction_Source IN VARCHAR2)
  RETURN VARCHAR2
  IS
    accounted_flag       PA_TRANSACTION_SOURCES.Gl_Accounted_Flag%TYPE;
  BEGIN
    IF  X_Transaction_Source IS NOT NULL THEN
      SELECT  TS.Gl_Accounted_Flag
      INTO    accounted_flag
      FROM    PA_TRANSACTION_SOURCES TS
      WHERE   TS.Transaction_Source = X_Transaction_source;
    ELSE
      accounted_flag := 'N';
    END IF;
    RETURN(accounted_flag);
  END Is_Accounted;

  /*
    New Procedure added under Project Summarization changes.
    This procedure is used to create a reverse cdl for a reverse ei generated during the
    adjustment of an accounted and imported transaction.
    x_exp_item_id : id of the original transaction
    x_backout_id  : id of the reverse transaction generated
   */

  PROCEDURE  CreateReverseCdl ( X_exp_item_id  IN     NUMBER,
                                X_backout_id   IN     NUMBER,
                                X_user         IN     NUMBER,
                                X_status       OUT    NOCOPY NUMBER)
  IS
     p_amount                        pa_cost_distribution_lines.amount%TYPE;
     p_dr_ccid                       pa_cost_distribution_lines.dr_code_combination_id%TYPE;
     p_cr_ccid                       pa_cost_distribution_lines.cr_code_combination_id%TYPE;
     p_transfer_status_code          pa_cost_distribution_lines.transfer_status_code%TYPE;
     p_quantity                      pa_cost_distribution_lines.quantity%TYPE;
     p_billable_flag                 pa_cost_distribution_lines.billable_flag%TYPE;
     p_request_id                    pa_cost_distribution_lines.request_id%TYPE;
     p_program_application_id        pa_cost_distribution_lines.program_application_id%TYPE;
     p_program_id                    pa_cost_distribution_lines.program_id%TYPE;
     p_program_update_date           pa_cost_distribution_lines.program_update_date%TYPE;
     p_pa_date                       pa_cost_distribution_lines.pa_date%TYPE;
     p_recvr_pa_date                 pa_cost_distribution_lines.pa_date%TYPE;   /**CBGA**/
     p_gl_date                       pa_cost_distribution_lines.gl_date%TYPE;
     p_transferred_date              pa_cost_distribution_lines.transferred_date%TYPE;
     p_transfer_rejection_reason     pa_cost_distribution_lines.transfer_rejection_reason%TYPE;
     p_line_type                     pa_cost_distribution_lines.line_type%TYPE;
     p_ind_complied_set_id           pa_cost_distribution_lines.ind_compiled_set_id%TYPE;
     p_burdened_cost                 pa_cost_distribution_lines.burdened_cost%TYPE;
     p_line_num_reversed             pa_cost_distribution_lines.line_num_reversed%TYPE;
     p_reversed_flag                 pa_cost_distribution_lines.reversed_flag%TYPE;
     p_cdlsr1                        pa_cost_distribution_lines.system_reference1%TYPE;
     p_cdlsr2                        pa_cost_distribution_lines.system_reference2%TYPE;
     p_cdlsr3                        pa_cost_distribution_lines.system_reference3%TYPE;
     p_denom_currency_code           pa_cost_distribution_lines.denom_currency_code%TYPE;
     p_denom_raw_cost                pa_cost_distribution_lines.denom_raw_cost%TYPE;
     p_denom_burdened_cost           pa_cost_distribution_lines.denom_burdened_cost%TYPE;
     p_acct_currency_code            pa_cost_distribution_lines.acct_currency_code%TYPE;
     p_acct_rate_date                pa_cost_distribution_lines.acct_rate_date%TYPE;
     p_acct_rate_type                pa_cost_distribution_lines.acct_rate_type%TYPE;
     p_acct_exchange_rate            pa_cost_distribution_lines.acct_exchange_rate%TYPE;
     p_acct_raw_cost                 pa_cost_distribution_lines.acct_raw_cost%TYPE;
     p_acct_burdened_cost            pa_cost_distribution_lines.acct_burdened_cost%TYPE;
     p_project_currency_code         pa_cost_distribution_lines.project_currency_code%TYPE;
     p_project_rate_date             pa_cost_distribution_lines.project_rate_date%TYPE;
     p_project_rate_type             pa_cost_distribution_lines.project_rate_type%TYPE;
     p_project_exchange_rate         pa_cost_distribution_lines.project_exchange_rate%TYPE;
     p_project_id                    pa_cost_distribution_lines.project_id%TYPE;
     p_task_id                       pa_cost_distribution_lines.task_id%TYPE;
     p_parent_adjusted_id            pa_expenditure_items.adjusted_expenditure_item_id%TYPE;
     p_parent_transferred_id         pa_expenditure_items.transferred_from_exp_item_id%TYPE;
     p_gl_accounted_flag             pa_transaction_sources.gl_accounted_flag%TYPE;
     p_transaction_source            pa_transaction_sources.transaction_source%TYPE;

     l_si_assets_addition_flag       pa_cost_distribution_lines.si_assets_addition_flag%TYPE ;
     p_err_code                      NUMBER;
     p_err_stage                     VARCHAR2(1000);
     p_err_stack                     VARCHAR2(1000);
     e_cdl_error                     EXCEPTION;

    -- Start EPP Changes
    p_pa_period_name        VARCHAR2(15);
    p_gl_period_name        VARCHAR2(15);
    p_recvr_gl_date         DATE;
    p_recvr_gl_period_name  VARCHAR2(15);
    p_recvr_pa_period_name  VARCHAR2(15);
    -- End EPP Changes

    -- Start Project Currency/ EI Attribute Changes
    p_projfunc_currency_code VARCHAR2(15);
    p_projfunc_cost_rate_type     VARCHAR2(30);
    p_projfunc_cost_rate_date     date;
    p_projfunc_cost_exchange_rate NUMBER;
    p_work_type_id           NUMBER;
    p_project_raw_cost       NUMBER;
    p_project_burdened_cost  NUMBER;
    -- End Project Currency/ EI Attribute Changes

    -- AP Discounts
    p_cdlsr4                        pa_cost_distribution_lines.system_reference4%TYPE;
    p_cdlsr5                        pa_cost_distribution_lines.system_reference5%TYPE;
/* bug#2361495 */
     l_pa_date                       DATE ;
     l_recvr_pa_date                 DATE ;
     l_ei_date                       DATE ;
     l_org_id                        pa_expenditure_items.org_id%type;
/* bug#2361495 */
/* bug2378505 */
     actual_cdl_line_num             pa_cost_distribution_lines.line_num%TYPE;
/* bug2378505 */
/* bug 2661921*/
        l_recvr_org_id          pa_expenditure_items.org_id%type;
        l_gl_date               DATE;
        l_recvr_gl_date         DATE;
        l_exp_id                NUMBER;
        l_sob_id                NUMBER;
        l_recvr_sob_id          NUMBER;
        l_sys_link_function     VARCHAR2(3);
        l_err_stage             NUMBER;
        l_status                NUMBER;
	l_err_code              VARCHAR2(100);
/* bug 2661921*/

  BEGIN

    SELECT ITEMS.adjusted_expenditure_item_id,
           ITEMS.transferred_from_exp_item_id,
           TRN.gl_accounted_flag,
           TRN.transaction_source
          ,ITEMS.expenditure_item_date
          ,ITEMS.org_id
/* bug 2661921*/
          ,NVL(ITEMS.recvr_org_id,ITEMS.ORG_ID)
          ,ITEMS.system_linkage_function
          ,ITEMS.expenditure_id
/* bug 2661921*/

    INTO   p_parent_adjusted_id,
           p_parent_transferred_id,
           p_gl_accounted_flag,
           p_transaction_source
          ,l_ei_date
          ,l_org_id
/* bug 2661921*/
          ,l_recvr_org_id
          ,l_sys_link_function
          ,l_exp_id
/* bug 2661921*/
    -- FROM   pa_expenditure_items ITEMS,  -- 12i MOAC changes
    FROM   pa_expenditure_items_All ITEMS,
           pa_transaction_sources TRN
    WHERE  ITEMS.transaction_source = TRN.transaction_source
    AND    ITEMS.expenditure_item_id = X_exp_item_id;

/* selecting set of books id for bug 2661921*/
	SELECT	imp1.set_of_books_id, imp2.set_of_books_id
	INTO	l_sob_id, l_recvr_sob_id
	FROM	pa_implementations_all imp1, pa_implementations_all imp2
    -- start 12i MOAC changes
	-- WHERE	nvl(imp1.org_id,-99) = nvl(l_org_id,-99)
	-- AND	nvl(imp2.org_id,-99) = nvl(l_recvr_org_id,-99);
    WHERE   imp1.org_id = l_org_id
    AND     imp2.org_id = l_recvr_org_id;
    -- end 12i MOAC changes
/* selected set of books id bug 2661921*/


    IF    p_parent_adjusted_id    IS NULL AND
          p_parent_transferred_id IS NULL AND
          p_gl_accounted_flag = 'Y' AND
/* Bug 4610677 - reversing line should not be created for all gl accounted VI and ER sources */
          l_sys_link_function not in ('VI','ER')
/* Commenting the following for Bug 4610677
          p_transaction_source NOT IN ( 'AP EXPENSE','AP INVOICE',
                                        'INTERCOMPANY_AP_INVOICES',
                                        'INTERPROJECT_AP_INVOICES',
/* Bug 4684328 - Added rest of the Purchasing and Payables transaction sources */
/* Commenting the following for Bug 4610677
                                        'AP VARIANCE', 'AP NRTAX', 'AP DISCOUNTS',
                                        'PO RECEIPT', 'PO RECEIPT NRTAX',
                                        'PO RECEIPT NRTAX PRICE ADJ', 'PO RECEIPT PRICE ADJ')*/
    THEN
/* Added for Bug 2378505 The reversing line should take the details from the latest CDL
and not from line_num = 1 as there may be some attributes which could differ which in
this case is the billable_flag */

 SELECT max(cdl.line_num)
      INTO actual_cdl_line_num
      FROM pa_cost_distribution_lines cdl
     WHERE cdl.expenditure_item_id = X_exp_item_id and cdl.line_type = 'R';

/* Addition for bug 2378505 ends */

    SELECT        amount
                , dr_code_combination_id
                , cr_code_combination_id
                , transfer_status_code
                , quantity
                , billable_flag
                , request_id
                , program_application_id
                , program_id
                , program_update_date
                , pa_date
                , gl_date
                , transferred_date
                , transfer_rejection_reason
                , line_type
                , ind_compiled_set_id
                , nvl(burdened_cost,0) + nvl(projfunc_burdened_change,0)
                , line_num_reversed
                , reversed_flag
                , system_reference1
                , system_reference2
                , system_reference3
                , denom_currency_code
                , denom_raw_cost
                , NVL(denom_burdened_cost,0) + nvl(denom_burdened_change,0)
                , acct_currency_code
                , acct_rate_date
                , acct_rate_type
                , acct_exchange_rate
                , acct_raw_cost
                , NVL(acct_burdened_cost,0) + nvl(acct_burdened_change,0)
                , project_currency_code
                , project_rate_date
                , project_rate_type
                , project_exchange_rate
                , project_id
                , task_id,
/* commenting out these columns as this information is obtained
  from pa_utils2.get_period_information for fix 2661921
                pa_period_name,
                gl_period_name,
                recvr_pa_period_name,
                recvr_gl_period_name, */
                recvr_gl_date
                , Projfunc_currency_code
                , Projfunc_cost_rate_date
                , Projfunc_cost_rate_type
                , Projfunc_cost_exchange_rate
                , Project_raw_cost
                , NVL(Project_burdened_cost,0) + nvl(project_burdened_change,0)
                , Work_type_id
                , system_reference4
                , system_reference5
		, decode(si_assets_addition_flag, 'R','T', 'O', 'T', 'Y', 'T', 'N', 'T',si_assets_addition_flag )
     INTO       p_amount,
                p_dr_ccid,
                p_cr_ccid,
                p_transfer_status_code,
                p_quantity,
                p_billable_flag,
                p_request_id,
                p_program_application_id,
                p_program_id,
                p_program_update_date,
                p_pa_date,
                p_gl_date,
                p_transferred_date,
                p_transfer_rejection_reason,
                p_line_type,
                p_ind_complied_set_id,
                p_burdened_cost,
                p_line_num_reversed,
                p_reversed_flag,
                p_cdlsr1,
                p_cdlsr2,
                p_cdlsr3,
                p_denom_currency_code,
                p_denom_raw_cost,
                p_denom_burdened_cost,
                p_acct_currency_code,
                p_acct_rate_date,
                p_acct_rate_type,
                p_acct_exchange_rate,
                p_acct_raw_cost,
                p_acct_burdened_cost,
                p_project_currency_code,
                p_project_rate_date,
                p_project_rate_type,
                p_project_exchange_rate,
                p_project_id,
                p_task_id
/* Commenting out the folliwng columns for 2661921
                , p_pa_period_name
                , p_gl_period_name
                , p_recvr_pa_period_name
                , p_recvr_gl_period_name */
                , p_recvr_gl_date
                , p_Projfunc_currency_code
                , p_Projfunc_cost_rate_date
                , p_Projfunc_cost_rate_type
                , p_Projfunc_cost_exchange_rate
                , p_Project_raw_cost
                , p_Project_burdened_cost
                , p_Work_type_id
                , p_cdlsr4
                , p_cdlsr5
		, l_si_assets_addition_flag
     -- FROM       pa_cost_distribution_lines  -- 12i MOAC changes
     FROM       pa_cost_distribution_lines_All -- 12i MOAC changes
     WHERE      expenditure_item_id = X_exp_item_id
--     AND        line_num            = 1; -- commented for bug2378505
     AND        line_num            = actual_cdl_line_num; -- bug2378505

/* bug#2361495 */
/* Commenting out the call to get_pa_date and get_recvr_pa_date
   for 2661921 as pa_date and recvr_pa_date will be obtained
   from PA_UTILS2.get_period_information

        l_pa_date := PA_UTILS2.get_pa_date(p_ei_date => l_ei_date
                                          ,p_gl_date => NULL
                                          ,p_org_id  => l_org_id );

        l_recvr_pa_date := PA_UTILS2.get_recvr_pa_date(p_ei_date => l_ei_date
                                                      ,p_gl_date => NULL
                                                      ,p_org_id  => l_org_id ); */
/* bug#2361495 */

/* Getting pa and gl period information for 2661921 */
	PA_UTILS2.get_period_information(
          	 p_expenditure_item_date => l_ei_date
       		,p_expenditure_id => l_exp_id
        	,p_system_linkage_function => l_sys_link_function
        	,p_line_type => p_line_type
        	,p_prvdr_raw_pa_date => p_pa_date
        	,p_recvr_raw_pa_date => p_recvr_pa_date
        	,p_prvdr_raw_gl_date => p_gl_date
        	,p_recvr_raw_gl_date => p_recvr_gl_date
        	,p_prvdr_org_id => l_org_id
        	,p_recvr_org_id => l_recvr_org_id
        	,p_prvdr_sob_id => l_sob_id
        	,p_recvr_sob_id => l_recvr_sob_id
        	,p_calling_module => 'CDL'
        	,x_prvdr_pa_date => l_pa_date
        	,x_prvdr_pa_period_name => p_pa_period_name
        	,x_prvdr_gl_date => l_gl_date
        	,x_prvdr_gl_period_name => p_gl_period_name
        	,x_recvr_pa_date => l_recvr_pa_date
        	,x_recvr_pa_period_name => p_recvr_pa_period_name
        	,x_recvr_gl_date => l_recvr_gl_date
        	,x_recvr_gl_period_name => p_recvr_gl_period_name
        	,x_error_code => l_err_code
        	,x_return_status => l_status
        	,x_error_stage => l_err_stage );
/* pa and gl period information fetched for 2661921*/

/* 2661921 */
        IF p_err_code IS NOT NULL THEN
          raise e_cdl_error;
        END IF;
/* 2661921 */

     PA_COSTING.CREATENEWCDL(
          X_expenditure_item_id         =>	X_backout_id
        , X_amount                      =>	-p_amount
        , X_dr_ccid                     =>	p_dr_ccid
        , X_cr_ccid                     =>	p_cr_ccid
        , X_transfer_status_code        =>	'P' /* bug 2361495 p_transfer_status_code */
        , X_quantity                    =>	-p_quantity
        , X_billable_flag               =>	p_billable_flag
        , X_request_id                  =>	p_request_id
        , X_program_application_id      =>	p_program_application_id
        , x_program_id                  =>	p_program_id
        , x_program_update_date         =>	p_program_update_date
        , X_pa_date                     =>	l_pa_date /* bug 2361495 p_pa_date */
        , X_recvr_pa_date               =>	l_recvr_pa_date /** bug 2361495 p_recvr_pa_date CBGA **/
        , X_gl_date                     =>	l_gl_date /* bug 2661921 p_gl_date */
        , X_transferred_date            =>	NULL /* bug 2361495 p_transferred_date */
        , X_transfer_rejection_reason   =>	NULL /* bug 2361495 p_transfer_rejection_reason */
        , X_line_type                   =>	p_line_type
        , X_ind_compiled_set_id         =>	p_ind_complied_set_id
        , X_burdened_cost               =>	-p_burdened_cost
        , X_line_num_reversed           =>	p_line_num_reversed
        , X_reverse_flag                =>	p_reversed_flag
        , X_user                        =>	X_user
        , X_err_code                    =>	p_err_code
        , X_err_stage                   =>	p_err_stage
        , X_err_stack                   =>	p_err_stack
        , X_project_id                  =>	p_project_id
        , X_task_id                     =>	p_task_id
        , X_cdlsr1                      =>	p_cdlsr1
        , X_cdlsr2                      =>	p_cdlsr2
        , X_cdlsr3                      =>	p_cdlsr3
        , X_denom_currency_code         =>	p_denom_currency_code
        , X_denom_raw_cost              =>	-p_denom_raw_cost
        , X_denom_burden_cost           =>	-p_denom_burdened_cost
        , X_acct_currency_code          =>	p_acct_currency_code
        , X_acct_rate_date              =>	p_acct_rate_date
        , X_acct_rate_type              =>	p_acct_rate_type
        , X_acct_exchange_rate          =>	p_acct_exchange_rate
        , X_acct_raw_cost               =>	-p_acct_raw_cost
        , X_acct_burdened_cost          =>	-p_acct_burdened_cost
        , X_project_currency_code       =>	p_project_currency_code
        , X_project_rate_date           =>	p_project_rate_date
        , X_project_rate_type           =>	p_project_rate_type
        , X_project_exchange_rate       =>	p_project_exchange_rate
        , P_PaPeriodName                =>  P_Pa_Period_Name
        , P_RecvrPaPeriodName           =>  P_Recvr_Pa_Period_Name
        , P_GlPeriodName                =>  P_Gl_Period_Name
        , P_RecvrGlDate                 =>  l_recvr_gl_date /* bug 2661921 P_Recvr_Gl_Date */
        , P_RecvrGlPeriodName           =>  P_Recvr_Gl_Period_Name
        , P_Projfunc_currency_code      =>  P_Projfunc_currency_code
        , P_Projfunc_cost_rate_date     =>  P_Projfunc_cost_rate_date
        , P_Projfunc_cost_rate_type     =>  P_Projfunc_cost_rate_type
        , P_Projfunc_cost_exchange_rate =>  P_Projfunc_cost_exchange_rate
        , P_Project_Raw_Cost            =>  -P_Project_Raw_Cost           --Bug 3315099
        , P_Project_Burdened_Cost       =>  -P_Project_Burdened_Cost      --Bug 3315099
        , P_Work_Type_Id                =>  P_Work_Type_Id
        , p_cdlsr4                      =>	p_cdlsr4
	, p_si_assets_addition_flag     => l_si_assets_addition_flag
	, p_cdlsr5                      => p_cdlsr5
	, P_Parent_Line_Num             => actual_cdl_line_num);

        IF p_err_code IS NOT NULL THEN
          raise e_cdl_error;
        END IF;

        UPDATE pa_expenditure_items
        SET    cost_distributed_flag = 'Y'
        WHERE  expenditure_item_id = X_backout_id;

     END IF;

     X_status := 0;

  EXCEPTION
   WHEN NO_DATA_FOUND THEN
     NULL;
   WHEN e_cdl_error THEN
     X_status := p_err_code;
   WHEN OTHERS THEN
     X_status := SQLCODE;
     RAISE;
  END CreateReverseCdl;

END PA_COSTING ;

/
