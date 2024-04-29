--------------------------------------------------------
--  DDL for Package Body PA_COST1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_COST1" as
-- $Header: PAXCSR1B.pls 120.1.12000000.2 2007/07/16 14:23:38 byeturi ship $

g_debug_flag   Varchar2(10) ;

/*
procedure calc_log(p_msg  varchar2) IS

        pragma autonomous_transaction ;
BEGIN
        --dbms_output.put_line(p_msg);
        --IF P_PA_DEBUG_MODE = 'Y' Then
            NULL;
            INSERT INTO PA_FP_CALCULATE_LOG
                (SESSIONID
                ,SEQ_NUMBER
                ,LOG_MESSAGE)
            VALUES
                (userenv('sessionid')
                ,HR.PAY_US_GARN_FEE_RULES_S.nextval
                ,substr(P_MSG,1,240)
                );
        --END IF;
        COMMIT;

end calc_log;
*/
PROCEDURE print_msg(p_debug_flag varchar2
                   ,p_msg varchar2 Default NULL) IS

	l_msg   varchar2(1000);
	l_module  varchar2(100) := 'PA_COST1';
BEGIN
	--calc_log(p_msg);
        If p_debug_flag = 'Y' Then
		l_msg := substr(p_msg,1,1000);
		PA_DEBUG.write
                (x_Module       => l_module
                ,x_Msg          => substr('LOG:'||p_msg,1,240)
                ,x_Log_Level    => 3);
        End If;

END print_msg ;

/* This API checks whether the given task is a financial task
 * if the given task is not exists in pa_tasks the derive the
 * burden sch details from project level
 */
FUNCTION is_workPlan_Task(p_project_id  IN Number
		      ,p_task_id   IN Number )
			RETURN VARCHAR2 IS
	l_exists_flag varchar2(10);
BEGIN
	l_exists_flag := 'N';
	If p_task_id is NOT NULL Then
		SELECT 'N'
		INTO l_exists_flag
		FROM dual
		WHERE EXISTS (select null
			from pa_tasks t
			where t.task_id = p_task_id
			and   t.project_id = p_project_id);
	End If;

	return l_exists_flag;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		l_exists_flag := 'Y';
                RETURN l_exists_flag;
	WHEN OTHERS THEN
		l_exists_flag := 'N';
		RETURN l_exists_flag;

END is_workPlan_Task;

/* This API checks whether the expenditure type is cost rate enabled or not */
FUNCTION check_expCostRateFlag
	 (p_exp_type  varchar2) Return Varchar2 IS

        Cursor cur_costrateFlag IS
        SELECT nvl(exp.cost_rate_flag,'N')
        FROM pa_expenditure_types exp
        WHERE exp.expenditure_type = p_exp_type;

	l_expCostRateFlag  Varchar2(10);

BEGIN

	OPEN cur_costrateFlag;
	FETCH cur_costrateFlag INTO l_expCostRateFlag;
	CLOSE cur_costrateFlag;

	RETURN l_expCostRateFlag;

END check_expCostRateFlag;

/* This API derives the cost rate multiplier for the given tasks */
FUNCTION get_CostRateMultiplier
	 	(p_task_id        Number
		,p_exp_item_date  Date
		) Return Number IS

	l_cost_rate_multiplier   Number := NULL;
	l_stage    Varchar2(1000);


BEGIN
        l_stage := 'Getting  labor cost multiplier ';
        SELECT lcm.multiplier
        INTO   l_cost_rate_multiplier
        FROM pa_tasks t
            ,pa_labor_cost_multipliers lcm
        WHERE t.task_id = p_task_id
        AND  t.labor_cost_multiplier_name = lcm.labor_cost_multiplier_name
        AND  trunc(P_exp_item_date) BETWEEN LCM.start_date_active AND
                          NVL(LCM.end_date_active,P_exp_item_date);

	Return l_cost_rate_multiplier;
EXCEPTION
        WHEN others THEN
             l_cost_rate_multiplier := NULL;
	     Return l_cost_rate_multiplier;

END get_CostRateMultiplier;

/* This API derives the project level burden schedule details
 * when task id is NULL.  If p_burden_sch_is is passed then
 * it dervies the sch_revision_id
 * If the sch and revision found then x_status will be set to 0 (zero)
 */
PROCEDURE get_projLevel_BurdSchds
	 (p_project_id		IN Number
	,p_task_id		IN Number Default NULL
	,p_exp_item_date        IN DATE
	,p_burden_sch_id        IN Number Default NULL
	,x_burden_sch_id	OUT NOCOPY Number
	,x_burden_sch_revision_id OUT NOCOPY Number
	,x_status		OUT NOCOPY Number ) IS

	l_stage   varchar2(1000);
	l_debug_flag   VARCHAR2(10);

BEGIN
        --- Initialize the error statck
        IF ( g_debug_flag IS NULL )
        Then
            fnd_profile.get('PA_DEBUG_MODE',g_debug_flag);
            g_debug_flag := NVL(g_debug_flag, 'N');
        End If;
        l_debug_flag := NVL(g_debug_flag,'N');
        IF ( l_debug_flag = 'Y' )
        THEN
            PA_DEBUG.init_err_stack ('PA_COST1.get_projLevel_BurdSchds');
            PA_DEBUG.SET_PROCESS( x_process     => 'PLSQL'
                                 ,x_write_file  => 'LOG'
                                 ,x_debug_mode  => l_debug_flag
                                );
        End If;

	/* Initialize the out params */
	x_status := 0;
	x_burden_sch_id := p_burden_sch_id;
	x_burden_sch_revision_id := Null;

	l_stage := 'Begin get_projLevel_BurdSchds IN Params: ProjId['||p_project_id||']ExpItemDate['||p_exp_item_date||
		 ']TaskId['||p_task_id||']BurdenSchId['||p_burden_sch_id||']' ;
        IF ( l_debug_flag = 'Y' )
        THEN
	    Print_msg(l_debug_flag,l_stage);
        END IF;

	IF (p_task_id is NOT NULL and x_burden_sch_id is NULL ) Then
	    BEGIN
                -- Select the Task level schedule override if not found
                -- then select the Project level override
                SELECT irs.ind_rate_sch_id
                INTO   x_burden_sch_id
                FROM   pa_tasks t,
                       pa_ind_rate_schedules irs
                WHERE  t.task_id = p_task_id
		AND    t.project_id = p_project_id
                AND    t.task_id = irs.task_id
                AND    irs.cost_ovr_sch_flag = 'Y';

	   EXCEPTION
		WHEN NO_DATA_FOUND THEN
		  -- check the project level override
		  BEGIN
             		SELECT irs.ind_rate_sch_id
             		INTO   x_burden_sch_id
             		FROM  pa_ind_rate_schedules irs
                  		,pa_projects_all pp
             		WHERE  pp.project_id = p_project_id
             		AND    irs.project_id = pp.project_id
             		AND    irs.cost_ovr_sch_flag = 'Y' ;
		  EXCEPTION
			WHEN NO_DATA_FOUND THEN
				-- check the task level schedule (not the override)
		  	 	BEGIN
                     			SELECT  t.cost_ind_rate_sch_id
                     			INTO    x_burden_sch_id
                     			FROM    pa_tasks t
                     			WHERE   t.task_id = p_task_id
		     			AND     t.project_id = p_project_id;

                  		EXCEPTION
                     			WHEN OTHERS THEN
                        			x_burden_sch_id := NULL;
                     		END;
		  END;
	   END;

	End IF;

	IF (p_project_id is NOT NULL and x_burden_sch_id is NULL) Then
	   BEGIN

             SELECT irs.ind_rate_sch_id
             INTO   x_burden_sch_id
             FROM  pa_ind_rate_schedules irs
		  ,pa_projects_all pp
             WHERE  pp.project_id = p_project_id
	     AND    irs.project_id = pp.project_id
             AND    irs.cost_ovr_sch_flag = 'Y' ;
	   EXCEPTION
		WHEN NO_DATA_FOUND Then
			SELECT pp.cost_ind_rate_sch_id
             		INTO   x_burden_sch_id
             		FROM  pa_projects_all pp
             		WHERE  pp.project_id = p_project_id ;

	   END;

	 End If;

	 IF x_burden_sch_id is NOT NULL Then
		Begin
                        SELECT irs.ind_rate_sch_revision_id
                        INTO  x_burden_sch_revision_id
                        FROM pa_ind_rate_sch_revisions irs
                        WHERE irs.ind_rate_sch_id = x_burden_sch_id
                        AND   irs.compiled_flag = 'Y'
                        AND   trunc(p_exp_item_date) BETWEEN irs.start_date_active
                              and NVL(irs.end_date_active ,p_exp_item_date );

                Exception
                        When NO_DATA_FOUND Then
                        	l_stage := 'No Schedule Revision found nor Compiled for given  burden Rate Schedule';
				x_burden_sch_revision_id := NULL ;
                        	x_status := -1;

                         When Others Then
				l_stage := 'Unexpected error occured in get_projLevel_BurdSchds';
                        	x_burden_sch_revision_id := NULL ;
                        	x_status := sqlcode;
                End ;
	   End If;

	IF x_burden_sch_id is NULL Then
		x_burden_sch_revision_id := NULL ;
		x_status := -1;
	End IF;

	l_stage := 'The Out params x_burden_sch_id['||x_burden_sch_id||'RevsionId['||x_burden_sch_revision_id||
		']RetrunStatus['||x_status||']' ;
        IF ( l_debug_flag = 'Y' )
        THEN
	    print_msg(l_debug_flag,l_stage);
        END IF;
	Return;

EXCEPTION

	WHEN OTHERS THEN
		l_stage := 'Unexpected error occured in get_projLevel_BurdSchds ['||SQLERRM||SQLCODE;
		x_burden_sch_revision_id := NULL ;
		x_status := sqlcode;

END get_projLevel_BurdSchds ;

/* This API derives the cost rates based on the bill rate schedules */
PROCEDURE get_RateSchDetails
		(p_schedule_type      IN Varchar2
		,p_rate_sch_id        IN Number
		,p_person_id          IN Number
		,p_job_id             IN Number
		,p_non_labor_resource IN Varchar2
		,p_expenditure_type   IN Varchar2
		,p_rate_organization_id IN Number
		,p_exp_item_date      IN Date
		,p_org_id             IN Number
		,x_currency_code      OUT NOCOPY Varchar2
		,x_cost_rate          OUT NOCOPY Number
		,x_markup_percent     OUT NOCOPY Number
		,x_return_status      OUT NOCOPY Varchar2
		,x_error_msg_code     OUT NOCOPY Varchar2 ) IS


	l_cost_rate   		Number;
	l_cost_rate_curr_code   Varchar2(30);
	l_markup_percent        Number;
	l_return_status         varchar2(100) := 'S';
	l_error_msg_code        varchar2(1000):= NULL;

        Cursor cur_nlr_sch_details IS
        SELECT sch.rate_sch_currency_code
               ,rates.rate
		,rates.markup_percentage
        FROM   pa_std_bill_rate_schedules_all sch
               ,pa_bill_rates_all rates
        WHERE  sch.bill_rate_sch_id = p_rate_sch_id
        AND    sch.schedule_type = 'NON-LABOR'
        AND    rates.bill_rate_sch_id = sch.bill_rate_sch_id
        AND    rates.expenditure_type = p_expenditure_type
        AND    ( rates.non_labor_resource is NULL
                 OR rates.non_labor_resource = p_non_labor_resource
               )
        AND    trunc(p_exp_item_date) between trunc(rates.start_date_active)
                        and trunc(nvl(rates.end_date_active,p_exp_item_date))
	/*Bug fix:3793618 This is to ensure that records with NLR and Exp combo orders first */
        ORDER BY decode(rates.non_labor_resource,p_non_labor_resource,0,1),rates.expenditure_type ;

        Cursor cur_emp_sch_details IS
        SELECT sch.rate_sch_currency_code
               ,rates.rate
		,rates.markup_percentage
        FROM   pa_std_bill_rate_schedules_all sch
               ,pa_bill_rates_all rates
        WHERE  sch.bill_rate_sch_id = p_rate_sch_id
        AND    sch.schedule_type = 'EMPLOYEE'
	AND    rates.person_id = p_person_id
        AND    rates.bill_rate_sch_id = sch.bill_rate_sch_id
        AND    trunc(p_exp_item_date) between trunc(rates.start_date_active)
                        and trunc(nvl(rates.end_date_active,p_exp_item_date));

        Cursor cur_job_sch_details IS
        SELECT sch.rate_sch_currency_code
               ,rates.rate
		,rates.markup_percentage
        FROM   pa_std_bill_rate_schedules_all sch
               ,pa_bill_rates_all rates
        WHERE  sch.bill_rate_sch_id = p_rate_sch_id
        AND    sch.schedule_type = 'JOB'
	AND    rates.job_id = pa_cross_business_grp.IsMappedToJob(p_job_id, rates.job_group_id)
        AND    rates.bill_rate_sch_id = sch.bill_rate_sch_id
        AND    trunc(p_exp_item_date) between trunc(rates.start_date_active)
                        and trunc(nvl(rates.end_date_active,p_exp_item_date));

BEGIN

	/* Initialize the out variables */
	x_return_status  := 'S';
	x_error_msg_code := Null;

	IF p_schedule_type = 'EMPLOYEE' Then
		OPEN cur_emp_sch_details;
		FETCH cur_emp_sch_details INTO
			l_cost_rate_curr_code
			,l_cost_rate
			,l_markup_percent ;
		CLOSE cur_emp_sch_details;

	Elsif p_schedule_type = 'JOB' Then
                OPEN cur_job_sch_details;
                FETCH cur_job_sch_details INTO
                        l_cost_rate_curr_code
                        ,l_cost_rate
                        ,l_markup_percent ;
                CLOSE cur_job_sch_details;
	Elsif p_schedule_type = 'NON-LABOR' Then
                OPEN cur_nlr_sch_details;
                FETCH cur_nlr_sch_details INTO
                        l_cost_rate_curr_code
                        ,l_cost_rate
                        ,l_markup_percent ;
                CLOSE cur_nlr_sch_details;
	End If;

	If (l_cost_rate_curr_code is NULL OR l_cost_rate is NULL ) Then
		x_return_status  := 'E';
		x_error_msg_code := 'No Planning Rates Setup';
	End If;
	/* Assigning the to OUT params */
        x_currency_code      := l_cost_rate_curr_code;
        x_cost_rate          := l_cost_rate;
        x_markup_percent     := l_markup_percent;

EXCEPTION
	When Others Then
		x_return_status  := 'U';
		x_error_msg_code := substr(sqlCode||sqlerrm,1,30);

END get_RateSchDetails;

/* This API derives cost rate based on expenditure Type */
FUNCTION GetExpTypeCostRate(p_exp_type      Varchar2
			   ,p_exp_item_date Date
			   ,p_org_id        Number
			   ) Return Number IS

	l_expTypeCostRate  Number;
	l_stage   varchar2(1000);
BEGIN
	If p_exp_type is NOT NULL and p_exp_item_date is NOT NULL Then

               l_stage := 'Executing sql to get Cost rates from expenditure type ';
               SELECT R.Cost_Rate
               INTO  l_expTypeCostRate
               FROM PA_Expenditure_Types T
                    ,PA_Expenditure_Cost_Rates_all R
               WHERE T.Expenditure_type = R.Expenditure_type
               AND T.Cost_Rate_Flag = 'Y'
               AND R.Expenditure_type = p_exp_type
               AND R.org_id = p_org_id --Bug#5903720
               AND trunc(p_exp_item_date)
               BETWEEN R.Start_Date_Active AND NVL(R.End_Date_Active, p_exp_item_date);

               l_stage := 'ExpCostRate['||l_expTypeCostRate||']' ;

	End If;
	Return l_expTypeCostRate;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN NULL;

	WHEN OTHERS THEN
		print_msg('Y',l_stage);
		RETURN NULL;

END;

/* This API derives the currency code for the given Operating Unit */
FUNCTION Get_curr_code(p_org_id   IN  NUMBER)

	RETURN VARCHAR2 IS

	l_currency_code      varchar2(100) := NULL ;

BEGIN

     SELECT FC.currency_code
     INTO l_currency_code
     FROM FND_CURRENCIES FC,
            GL_SETS_OF_BOOKS GB,
            PA_IMPLEMENTATIONS_ALL IMP
     WHERE FC.currency_code = DECODE(imp.set_of_books_id, NULL, NULL, GB.currency_code)
     AND GB.set_of_books_id = IMP.set_of_books_id
     AND IMP.org_id  = p_org_id; --Bug#5903720

     return l_currency_code;


EXCEPTION
   WHEN NO_DATA_FOUND THEN
	l_currency_code:= NULL;
	return l_currency_code;

   WHEN OTHERS THEN
	l_currency_code:= NULL;
        return l_currency_code;

END Get_curr_code;

/* This API checks whether the project is burdened or not and returns Y if project
 * type is burdended */
FUNCTION check_proj_burdened
         (p_project_type                IN      VARCHAR2
         ,p_project_id                  IN      NUMBER ) RETURN VARCHAR2 IS

        cursor cur_burden_flag IS
        SELECT NVL(burden_cost_flag,'N')
        FROM pa_project_types_all typ
            , pa_projects_all proj
        WHERE typ.project_type = P_project_type
        AND   proj.project_type = typ.project_type
        AND   proj.project_id = p_project_id
        AND   proj.org_id   = typ.org_id; --Bug#5903720

        l_burden_flag  varchar2(10) := 'N';
BEGIN
	/* Bug fix: 4230258 Use one-level cache logic so that executing cursor will be avoided */
	IF ((pa_cost1.g_project_type is NULL OR pa_cost1.g_project_type <> p_project_type )
	    OR (pa_cost1.g_project_id is NULL or pa_cost1.g_project_id <> p_project_id)) Then

        	OPEN cur_burden_flag;
        	FETCH cur_burden_flag INTO l_burden_flag;
        	CLOSE cur_burden_flag;
		--print_msg(g_debug_flag,'Executing cursor to get burden cost flag');
	 	pa_cost1.g_project_type := p_project_type;
		pa_cost1.g_project_id   := p_project_id;
		pa_cost1.g_burden_costFlag := l_burden_flag;
	Else
		--print_msg(g_debug_flag,'Getting from cache');
		l_burden_flag := pa_cost1.g_burden_costFlag;
	End If;
        RETURN l_burden_flag;

END check_proj_burdened;

/* This API derives transaction raw cost, burden costs in transaction currency. ie. the currency associated
 * with the rate schedule.
 * The following are the rules to derive cost rates for the planning resource
 * 1. By default the rate engine will derive the raw and burden costs based on the transaction currency.
 *     I.e. The currency associated with the rate schedule. If the transaction override currency is passed then costs will be
 *     converted from transaction currency to override currency.
 * 2. If the override cost rate is passed then rate engine will derive the actual raw cost and raw cost rates
 *   based on the override cost rate
 * 3. If the override burden multiplier is passed, the rate engine will derive the burden costs
 *   based on the override burden multiplier.
 * 4. If the parameter rate based flag is 'N' then rate engine will not derive raw cost instead,
 *  the burden costs will be derived based on the passed value transaction raw cost and transaction currency.
 * 5. Rates will be derived based on the in parameter p_exp_item_date
 * This API returns x_return_status as 'S' for successful rate 'E' if no rate found 'U' in case of unexpected errors
 *
 * NOTE: For BOM related transactions the following params needs to be passed
 * p_mfc_cost_source      Required possible values be
 *                        1 - Return item cost from valuation cost type.
 *                        2 - Return item cost from user-provided cost type.
 *                        3 - Return item cost as the list price per unit from item definition.
 *                        4 - Return item cost as average of the last 5 PO receipts of this item.
 *                            PO price includes non-recoverable tax.
 * p_mfd_cost_type_id     Optional param default is 0
 * p_exp_organization_id  Required
 * p_BOM_resource_id      Required
 * p_inventory_item_id    Required
 *
 */
PROCEDURE Get_Plan_Actual_Cost_Rates
        (p_calling_mode                 IN      	VARCHAR2 DEFAULT 'ACTUAL_RATES'
        ,p_project_type                 IN      	VARCHAR2
        ,p_project_id                   IN      	NUMBER
        ,p_task_id                      IN      	NUMBER
        ,p_top_task_id                  IN      	NUMBER
        ,p_Exp_item_date                IN      	DATE
        ,p_expenditure_type             IN      	VARCHAR2
        ,p_expenditure_OU               IN      	NUMBER
        ,p_project_OU                   IN      	NUMBER
        ,p_Quantity                     IN      	NUMBER
        ,p_resource_class               IN      	VARCHAR2
        ,p_person_id                    IN      	NUMBER     DEFAULT NULL
        ,p_non_labor_resource           IN      	VARCHAR2   DEFAULT NULL
        ,p_NLR_organization_id          IN      	NUMBER     DEFAULT NULL
        ,p_override_organization_id     IN      	NUMBER     DEFAULT NULL
        ,p_incurred_by_organization_id  IN      	NUMBER     DEFAULT NULL
        ,p_inventory_item_id            IN      	NUMBER     DEFAULT NULL
        ,p_BOM_resource_id              IN      	NUMBER     DEFAULT NULL
	,p_override_trxn_curr_code      IN      	VARCHAR2   DEFAULT NULL
	,p_override_burden_cost_rate    IN      	NUMBER     DEFAULT NULL
	,p_override_trxn_cost_rate      IN      	NUMBER     DEFAULT NULL
        ,p_override_trxn_raw_cost       IN              NUMBER     DEFAULT NULL
        ,p_override_trxn_burden_cost    IN              NUMBER     DEFAULT NULL
	,p_mfc_cost_type_id             IN              NUMBER     DEFAULT 0
        ,p_mfc_cost_source              IN              NUMBER     DEFAULT 2
	,p_item_category_id             IN      	NUMBER     DEFAULT NULL
        ,p_job_id                       IN              NUMBER     DEFAULT NULL
        ,p_plan_cost_job_rate_sch_id    IN              NUMBER     DEFAULT NULL
        ,p_plan_cost_emp_rate_sch_id    IN              NUMBER     DEFAULT NULL
        ,p_plan_cost_nlr_rate_sch_id    IN              NUMBER     DEFAULT NULL
        ,p_plan_cost_burden_sch_id      IN              NUMBER     DEFAULT NULL
        ,x_trxn_curr_code               OUT NOCOPY      VARCHAR2
        ,x_trxn_raw_cost                OUT NOCOPY      NUMBER
        ,x_trxn_raw_cost_rate           OUT NOCOPY      NUMBER
        ,x_trxn_burden_cost             OUT NOCOPY      NUMBER
        ,x_trxn_burden_cost_rate        OUT NOCOPY      NUMBER
	,x_burden_multiplier            OUT NOCOPY      NUMBER
	,x_cost_ind_compiled_set_id     OUT NOCOPY      NUMBER
	,x_raw_cost_rejection_code      OUT NOCOPY      VARCHAR2
        ,x_burden_cost_rejection_code   OUT NOCOPY      VARCHAR2
        ,x_return_status                OUT NOCOPY      VARCHAR2
        ,x_error_msg_code               OUT NOCOPY      VARCHAR2 )  IS

	l_insufficient_parms 		EXCEPTION;
	l_no_rate_found      		EXCEPTION;
	l_no_burdrate_found      	EXCEPTION;
	l_invalid_override_attributes 	EXCEPTION;
	l_invalid_currency          	EXCEPTION;
	l_cost_source           Number := p_mfc_cost_source ;

	l_stage			varchar2(1000);
	l_err_code              varchar2(1000);
	l_debug_flag            varchar2(10);
	l_msg_data              varchar2(1000);
	l_msg_count		Number;
	l_return_status         varchar2(10);
	l_job_id      	        Number;
        l_txn_curr_code         varchar2(100);
        l_txn_raw_cost          Number;
        l_txn_raw_cost_rate     Number;
        l_burden_cost           Number;
        l_burden_cost_rate      Number;
	l_burden_multiplier     Number;
	l_override_organization_id Number;
        l_cost_rate_multiplier  Number;
        l_start_date_active      Date;
        l_end_date_active        Date;
        l_org_labor_sch_rule_id  Number;
        l_costing_rule           Varchar2(100);
        l_rate_sch_id            Number;
        l_acct_rate_type         varchar2(100);
        l_acct_rate_date_code    varchar2(100);
        l_acct_exch_rate         Number;
        l_ot_project_id          Number;
        l_ot_task_id             Number;
	l_api_version            Number;
	l_burd_sch_id            Number;
        l_burd_sch_rev_id        Number;
        l_burd_sch_fixed_date    Date;
        l_burd_sch_cost_base     varchar2(150);
        l_burd_sch_cp_structure  varchar2(150);
        l_burd_ind_compiled_set_id Number;
	l_proj_flag  varchar2(1000);
	l_rate_organization_id   Number;
	l_markup_percent         Number;
	l_bill_rate_schedule_type varchar2(150);
	l_bill_rate_sch_id       Number;

	/* This is to identify the planning transactions as LABOR, NON-LABOR or BOM transactions depending on the
	 * validation of the input params*/
	l_trxn_type             varchar2(100) := NULL;

BEGIN

	--Initialize the out variables
        l_job_id := p_job_id;
        l_txn_curr_code := p_override_trxn_curr_code;
        l_txn_raw_cost := p_override_trxn_raw_cost ;
        l_txn_raw_cost_rate := p_override_trxn_cost_rate;
        l_burden_cost := p_override_trxn_burden_cost  ;
        l_burden_cost_rate := p_override_burden_cost_rate;
	l_burden_multiplier := NULL;
	l_override_organization_id := p_override_organization_id;
	l_cost_rate_multiplier := NUll;
        l_msg_data := NULL;
	l_msg_count := 0;
        l_return_status := 'S';
        x_raw_cost_rejection_code      := Null;
        x_burden_cost_rejection_code   := Null;
        x_error_msg_code               := Null;
        x_return_status := 'S';

        --- Initialize the error statck
	If g_debug_flag is NULL Then
        	fnd_profile.get('PA_DEBUG_MODE',g_debug_flag);
        	g_debug_flag := NVL(g_debug_flag, 'N');
	End If;
	l_debug_flag := NVL(g_debug_flag,'N');
	IF l_debug_flag = 'Y' Then
        	PA_DEBUG.init_err_stack ('PA_COST1.Get_Plan_Actual_Cost_Rates');
        	PA_DEBUG.SET_PROCESS( x_process => 'PLSQL'
                      ,x_write_file     => 'LOG'
                      ,x_debug_mode      => l_debug_flag
                          );
	End If;

	/* Derive the Rate Organization Id from the params*/
        l_rate_organization_id := NVL(p_override_organization_id,NVL(p_incurred_by_organization_id,p_nlr_organization_id));

	l_stage := 'Inside PA_COST1.Get_Plan_Actual_Cost_Rates API';
	l_stage := l_stage||' IN PARAMS mode['||p_calling_mode||']Proj Type['||p_project_type||
		']Proj Id['||p_project_id||']TaskId['||p_task_id||']TopTask['||p_top_task_id||
		']Ei Date['||p_Exp_item_date||']ExpType['||p_expenditure_type||
	 	']ResClass['||p_resource_class||']Personid['||p_person_id||']NLR['||p_non_labor_resource||
		']NLR Org['||p_NLR_organization_id||']ExpOU['||p_expenditure_OU||']ProjOU['||p_project_OU||
		']IncurrOrg['||p_incurred_by_organization_id||']OverrideOrg['||l_override_organization_id||
		']Qty['||p_Quantity||']InvItemId['||p_inventory_item_id||']BomRes['||p_BOM_resource_id||
		']ProjCostJobId['||p_job_id||']p_mfc_cost_type_id['||p_mfc_cost_type_id||
		']p_mfc_cost_source['||p_mfc_cost_source||']RateOrganzId['||l_rate_organization_id||
		']JobRateSch['||p_plan_cost_job_rate_sch_id||']EmpRateSch['||p_plan_cost_emp_rate_sch_id||
		']NlrRateSch['||p_plan_cost_nlr_rate_sch_id||']BurdRateSch['||p_plan_cost_burden_sch_id||']' ;
	print_msg(l_debug_flag,l_stage);

	l_stage := 'Override values override_trxn_curr_code['||p_override_trxn_curr_code||
		  ']overide Multi['||p_override_burden_cost_rate||']OverrideCostRate['||p_override_trxn_cost_rate||
        	  ']overrideRawCost['||p_override_trxn_raw_cost||']OverrideBurdCost['||p_override_trxn_burden_cost||']' ;
	print_msg(l_debug_flag,l_stage);


	/* Validate the override parameters */
	l_trxn_type := NULL;
        If ( p_override_trxn_raw_cost is NOT NULL
                and p_override_trxn_burden_cost is NOT NULL ) Then
                -- Just return the control back to calling api
		l_stage := 'Assigning override values to Out params';
		print_msg(l_debug_flag,l_stage);
                x_trxn_raw_cost      := p_override_trxn_raw_cost;
                x_trxn_burden_cost   := p_override_trxn_burden_cost;
	        x_trxn_curr_code     := p_override_trxn_curr_code;
		x_trxn_raw_cost_rate := p_override_trxn_cost_rate;
		x_trxn_burden_cost_rate := p_override_burden_cost_rate;
                x_raw_cost_rejection_code      := Null;
                x_burden_cost_rejection_code   := Null;
                x_error_msg_code               := Null;
                x_return_status := 'S';
		If l_debug_flag = 'Y' Then
			PA_DEBUG.reset_err_stack;
		End If;
                RETURN;
        ElsIf (p_override_trxn_cost_rate is NOT NULL OR p_override_trxn_raw_cost is NOT NULL ) Then
                l_stage := 'Validating override params';
                IF  p_override_trxn_curr_code is NULL Then
                	l_stage := 'Validating override params No Override Currency';
			print_msg(l_debug_flag,l_stage);
                	Raise l_invalid_override_attributes;
		Else
                	l_txn_curr_code := p_override_trxn_curr_code;
			-- if cost rate is null derive the cost rate based on quantity and amount
			If p_override_trxn_cost_rate is NULL Then
				If NVL(p_quantity,0) <> 0 Then
					l_txn_raw_cost_rate := p_override_trxn_raw_cost / NVL(p_quantity,1);
				Else
					l_txn_raw_cost_rate := 1;
				End IF;
			Else
				l_txn_raw_cost_rate := p_override_trxn_cost_rate;
			End If;

                        -- if cost is null then derive the cost based on rate and quantity
			If p_override_trxn_raw_cost is NULL Then
				If NVL(p_quantity,0) <> 0 then
				     l_txn_raw_cost := pa_currency.round_trans_currency_amt1
						(l_txn_raw_cost_rate * NVL(p_quantity,1), l_txn_curr_code );
				Else
				     l_txn_raw_cost := null;
				End If;
			Else
				l_txn_raw_cost := p_override_trxn_raw_cost;
			End If;
                	l_trxn_type := 'BURDEN';
	      End If;
        End If;

	/* Based on the resource class and input params set the transaction type as one of the following values
	 * LABOR RATE  -- for resource class is People and person or job is not null
         * BOM RESOURCE RATE  -- for resource class is people and bom resource id isnot null
         * EXP TYPE RATE   -- for resource class is people and financial category
         * NON LABOR RESOURCE RATE -- for resource class equipment
         * BOM EQUIPMENT RATE   -- for resource class equiment and inventory item is not null
         * MATERIAL ITEM RATE  -- for resource class material items and inventory items not null
         */
	-- Identify the transaction Type
	If l_trxn_type is NULL Then
	    l_stage := 'Deriving transaction type based on resource class';
	    print_msg(l_debug_flag,l_stage);

            If p_calling_mode = 'ACTUAL_RATES' Then
	    	If (p_resource_class = 'PEOPLE') Then

			If ( p_BOM_resource_id is NOT NULL and l_rate_organization_id is NOT NULL ) Then
				l_trxn_type := 'BOM RESOURCE RATE';

			ElsIf (p_person_id is NOT NULL  OR p_job_id is NOT NULL ) Then
				l_trxn_type := 'LABOR RATE' ;

			/* Elsif (p_expenditure_type is NOT NULL and check_expCostRateFlag(p_expenditure_type) = 'Y') Then
				l_trxn_type := 'EXP TYPE RATE';
			*/

			Else
				l_stage := 'Invalid People Class params';
                        	-- This is an invalid combination
                        	Raise l_insufficient_parms;
			End If;

  	    	Elsif (p_resource_class = 'EQUIPMENT') Then
			If (p_non_labor_resource is NOT NULL
			    and NVL(p_NLR_organization_id,l_rate_organization_id) is NOT NULL
			    and p_expenditure_type is NOT NULL ) Then
				l_trxn_type := 'NON LABOR RESOURCE RATE' ;

			Elsif (p_BOM_resource_id is NOT NULL  and l_rate_organization_id is NOT NULL ) Then
				l_trxn_type := 'BOM EQUIPMENT RATE';

			/* Bug fix: as per discussion with Anders and Jhonson for people and equipemnt class
                         * if rate is not found from schedule then it should pick from resource class level
			 * finally decided as we should retain  this logic */
			Elsif (p_expenditure_type is NOT NULL
				and check_expCostRateFlag(p_expenditure_type) = 'Y') Then
				l_trxn_type := 'EXP TYPE RATE';

                	Else
                        	l_stage := 'Invalid Equipment Class params';
                        	-- This is an invalid combination
                        	Raise l_insufficient_parms;
                        End If;
 	    	Elsif (p_resource_class = 'MATERIAL_ITEMS') Then

 	          	If (p_inventory_item_id is NOT NULL and l_rate_organization_id is NOT NULL ) Then
			      	l_trxn_type := 'MATERIAL ITEM RATE';
		    	Elsif (p_expenditure_type is NOT NULL
			      and check_expCostRateFlag(p_expenditure_type) = 'Y') Then
                        	l_trxn_type := 'EXP TYPE RATE';
                	Else
                        	l_stage := 'Invalid Material Itms Class params';
                        	-- This is an invalid combination
                        	Raise l_insufficient_parms;
                	End If;

	   	Elsif (p_resource_class = 'FINANCIAL_ELEMENTS' ) Then
    	          	If p_expenditure_type is NOT NULL Then
                          IF check_expCostRateFlag(p_expenditure_type) = 'Y' Then
                        	l_trxn_type := 'EXP TYPE RATE';
			  Else
				l_stage := 'Invalid Financial Elements Class params';
                                -- This is an invalid combination
                                Raise l_insufficient_parms;
			  End If;
                	  /**Else
                        	l_stage := 'Financial Elements Class params NO COST RATE';
                        	l_trxn_type := 'EXP TYPE RATE N_FLAG';
			  End IF;
			  **/
                        Else
                                l_stage := 'Invalid Financial Elements Class params';
                                -- This is an invalid combination
                                Raise l_insufficient_parms;
                	End If;
 	    	End If; -- end of resource class

         ELSIF p_calling_mode = 'PLAN_RATES' Then

	    	If (p_resource_class = 'PEOPLE') Then
                	If ( p_BOM_resource_id is NOT NULL and l_rate_organization_id is NOT NULL ) Then
                        	l_trxn_type := 'BOM RESOURCE RATE';

                	ElsIf (p_person_id is NOT NULL and  p_plan_cost_emp_rate_sch_id is NOT NULL ) Then
                        	l_trxn_type := 'LABOR SCH RATE' ;

                	Elsif (p_job_id is NOT NULL and p_plan_cost_job_rate_sch_id is NOT NULL ) Then
                        	l_trxn_type := 'JOB SCH RATE';

                	/* Elsif (p_expenditure_type is NOT NULL and p_plan_cost_nlr_rate_sch_id is NOT NULL ) Then
                        	l_trxn_type := 'NON LABOR SCH RATE';
       			*/

                	Else
                        	l_stage := 'Invalid People Class params';
                        	-- This is an invalid combination
                        	Raise l_insufficient_parms;
                	End If;
  	    	Elsif (p_resource_class = 'EQUIPMENT') Then
                	If (p_non_labor_resource is NOT NULL and p_plan_cost_nlr_rate_sch_id is NOT NULL
                        and p_expenditure_type is NOT NULL ) Then
                        	l_trxn_type := 'NON LABOR SCH RATE' ;

                	Elsif (p_BOM_resource_id is NOT NULL  and l_rate_organization_id is NOT NULL ) Then
                        	l_trxn_type := 'BOM EQUIPMENT RATE';

                	Elsif (p_expenditure_type is NOT NULL and p_plan_cost_nlr_rate_sch_id is NOT NULL ) Then
                        	l_trxn_type := 'NON LABOR SCH RATE' ;

                	Else
                        	l_stage := 'Invalid Equipment Class params';
                        	-- This is an invalid combination
                        	Raise l_insufficient_parms;
                	End If;
 	   	Elsif (p_resource_class = 'MATERIAL_ITEMS') Then

                	If (p_inventory_item_id is NOT NULL and l_rate_organization_id is NOT NULL ) Then
                        	l_trxn_type := 'MATERIAL ITEM RATE';

                	Elsif (p_expenditure_type is NOT NULL and p_plan_cost_nlr_rate_sch_id is NOT NULL ) Then
                        	l_trxn_type := 'NON LABOR SCH RATE' ;

                	Else
                        	l_stage := 'Invalid Material Itms Class params';
                        	-- This is an invalid combination
                        	Raise l_insufficient_parms;
                	End If;
	   	Elsif (p_resource_class = 'FINANCIAL_ELEMENTS' ) Then
		    	If (p_expenditure_type is NOT NULL and p_plan_cost_nlr_rate_sch_id is NOT NULL ) Then
                        	l_trxn_type := 'NON LABOR SCH RATE' ;

                	/**Else
			    If p_expenditure_type is NOT NULL Then
                                IF check_expCostRateFlag(p_expenditure_type) = 'Y' Then
                                    l_trxn_type := 'EXP TYPE RATE';
                                Else
                                    l_stage := 'Financial Elements Class params NO COST RATE';
                                    l_trxn_type := 'EXP TYPE RATE N_FLAG';
                                End IF;
			 **/
                        Else
                                l_stage := 'Invalid Financial Elements Class params';
                                -- This is an invalid combination
                                Raise l_insufficient_parms;
                            --End If;
                	End If;

         	End If;  -- end of resource class
          End If; -- end of calling mode
      End If ; -- end of transaction type null

	l_stage := 'After validating input params: Transaction Type['||l_trxn_type||']' ;
	print_msg(l_debug_flag,l_stage);

	/* Bug fix: 4232181 Derive the organization overrides from the project level */
	IF l_trxn_type IN ('LABOR SCH RATE','JOB SCH RATE','LABOR RATE') Then
		IF l_override_organization_id is NULL Then
                         l_stage := 'Calling pa_cost.Override_exp_organization api';
                         print_msg(l_debug_flag,l_stage);
                         pa_cost.Override_exp_organization
                         (P_item_date                  => p_exp_item_date
                         ,P_person_id                  => p_person_id
                         ,P_project_id                 => p_project_id
                         ,P_incurred_by_organz_id      => p_incurred_by_organization_id
                         ,P_Expenditure_type           => p_expenditure_type
                         ,X_overr_to_organization_id   => l_override_organization_id
                         ,X_return_status              => l_return_status
                         ,X_msg_count                  => l_msg_count
                         ,X_msg_data                   => l_msg_data
                         );
                         l_stage := 'Return status of pa_cost.Override_exp_organization ['||l_return_status||']';
                         l_stage := l_stage||']msgData['||l_msg_data||']OverideOrg['||l_override_organization_id||']' ;
                         print_msg(l_debug_flag,l_stage);
               End If;
	End If;

	/* Actual Rate Calculation logic starts here */
	IF l_trxn_type in ('BOM EQUIPMENT RATE', 'BOM RESOURCE RATE') Then

			-- call the api provided by PO/BOM team to dervie the cost rate
			l_cost_source  := p_mfc_cost_source ;
			l_api_version  := 1.0;
	        	IF p_BOM_resource_id is NOT NULL Then

			  BEGIN
				l_stage := 'Calling CST_ItemResourceCosts_GRP.Get_ResourceRate API';
			 	print_msg(l_debug_flag,l_stage);

				CST_ItemResourceCosts_GRP.Get_ResourceRate(
        			p_api_version            => l_api_version
        			,p_init_msg_list         => FND_API.G_FALSE
        			,p_commit                => FND_API.G_FALSE
        			,p_validation_level      => FND_API.G_VALID_LEVEL_FULL
        			,x_return_status         => l_return_status
        			,x_msg_count             => l_msg_count
        			,x_msg_data              => l_msg_data
        			,p_resource_id           => p_BOM_resource_id
        			,p_organization_id       => l_rate_organization_id
        			,p_cost_type_id          => p_mfc_cost_type_id
        			,x_resource_rate         => l_txn_raw_cost_rate
				,x_currency_code         => l_txn_curr_code
				);
                        	l_stage := 'After CST_ItemResourceCosts_GRP.Get_ResourceRate API returnStatus['||l_return_status||
                                   ']CostRate['||l_txn_raw_cost_rate||']CurrCode['||l_txn_curr_code||']msgDate['||l_msg_data||']';
			 	print_msg(l_debug_flag,l_stage);
				If ( l_return_status <> 'S' OR l_txn_curr_code is NULL ) Then
                                        If l_return_status = 'U' Then
                                        	l_stage := l_stage||'SQLERRM['||SQLCODE||SQLERRM;
                                	End If;
                        		print_msg(l_debug_flag,l_stage);
					x_raw_cost_rejection_code := 'PA_FP_MISSING_RATE';
					Raise l_no_rate_found;
				End If;

				If l_txn_curr_code is NOT NULL Then
					l_txn_raw_cost := pa_currency.round_trans_currency_amt1
						(l_txn_raw_cost_rate * NVL(p_quantity,1), l_txn_curr_code);
				End If;
			  EXCEPTION
				WHEN NO_DATA_FOUND THEN
					l_msg_data := 'PA_FP_MISSING_RATE';
					l_return_status := 'E';
					x_return_status := 'E';
					x_raw_cost_rejection_code := 'PA_FP_MISSING_RATE';
					RAISE l_no_rate_found;
				WHEN OTHERS THEN
				  	IF to_char(sqlcode) in ('00100','01403','100','1403') Then
						l_msg_data := 'PA_FP_MISSING_RATE';
                                        	l_return_status := 'E';
                        			x_return_status := 'E';
                        			x_error_msg_code := 'PA_FP_MISSING_RATE';
						x_raw_cost_rejection_code := 'PA_FP_MISSING_RATE';
						RAISE l_no_rate_found;
                			End If;
					RAISE;
			  END;

			End If;

	ElsIF l_trxn_type in ('MATERIAL ITEM RATE') Then
		IF  p_inventory_item_id is NOT NULL Then
			-- call the api provided by PO/BOM team to dervie the Raw cost
		    BEGIN
			l_stage := 'Calling CST_ItemResourceCosts_GRP.Get_ItemCost API';
			 print_msg(l_debug_flag,l_stage);
			l_cost_source  := p_mfc_cost_source ;
                        l_api_version  := 1.0;
			CST_ItemResourceCosts_GRP.Get_ItemCost
			(
        		p_api_version            => l_api_version
        		,p_init_msg_list         => FND_API.G_FALSE
        		,p_commit                => FND_API.G_FALSE
        		,p_validation_level      => FND_API.G_VALID_LEVEL_FULL
        		,x_return_status         => l_return_status
        		,x_msg_count             => l_msg_count
        		,x_msg_data              => l_msg_data
        		,p_item_id               => p_inventory_item_id
        		,p_organization_id       => l_rate_organization_id
        		,p_cost_source           => l_cost_source
        		,p_cost_type_id          => p_mfc_cost_type_id
        		/*Bug fix:4154009 ,x_item_cost             => l_txn_raw_cost */
			,x_item_cost             => l_txn_raw_cost_rate
			,x_currency_code         => l_txn_curr_code
			);
                        l_stage := 'After CST_ItemResourceCosts_GRP.Get_ItemCost API returnStatus['||l_return_status||
                                   ']MaterialCostRate['||l_txn_raw_cost_rate||']CurrCode['||l_txn_curr_code||']msgDate['||l_msg_data||']' ;
			 print_msg(l_debug_flag,l_stage);
                        If ( l_return_status <> 'S' OR l_txn_curr_code is NULL ) Then
				If l_return_status = 'U' Then
					l_stage := l_stage||'SQLERRM['||SQLCODE||SQLERRM;
				End If;
                                print_msg(l_debug_flag,l_stage);
				x_raw_cost_rejection_code := 'PA_FP_MISSING_RATE';
                                Raise l_no_rate_found;
                        End If;

			If l_txn_curr_code is NOT NULL Then
				-- this is the list price per unit
				l_txn_raw_cost := pa_currency.round_trans_currency_amt1
                                                (l_txn_raw_cost_rate * NVL(p_quantity,1), l_txn_curr_code );
			End If;
			/*i Bug fix:4154009 The Api returns the rate not the cost So need not re derive the rate
			If l_txn_raw_cost_rate is NULL Then
				-- derive the cost rate based on the item cost and quantity
				If NVL(p_quantity,1) <> 0 Then
					l_txn_raw_cost_rate := l_txn_raw_cost / NVL(p_quantity,1);
				Else
					l_txn_raw_cost_rate := l_txn_raw_cost ;
				End If;
			End If;
			**/
		     EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                        l_msg_data := 'PA_FP_MISSING_RATE';
                                        l_return_status := 'E';
					l_msg_data := 'PA_FP_MISSING_RATE';
                                        x_raw_cost_rejection_code := 'PA_FP_MISSING_RATE';
                                        RAISE l_no_rate_found;
                                WHEN OTHERS THEN
                                        IF to_char(sqlcode) in ('00100','01403','100','1403') Then
                                                l_return_status := 'E';
						l_msg_data := 'PA_FP_MISSING_RATE';
                                                x_error_msg_code := 'PA_FP_MISSING_RATE';
                                                x_raw_cost_rejection_code := 'PA_FP_MISSING_RATE';
                                                RAISE l_no_rate_found;
                                        End If;
                                        RAISE;
                     END;
		End If;


	ELSIF l_trxn_type = 'LABOR RATE'  Then
		-- call the get raw cost api for the person id is not null else call the requirement raw cost for the
		-- job and organization type transactions
		If (p_person_id is NOT NULL OR p_job_id is NOT NULL ) Then
        		/* Derive default labor cost multiplier for the given Tasks */
        		IF ( p_task_id IS NOT NULL AND l_cost_rate_multiplier is NULL ) THEN
                        	l_stage := 'Getting  labor cost multiplier name';
				l_cost_rate_multiplier := get_CostRateMultiplier
                					(p_task_id        => p_task_id
                					,p_exp_item_date  => p_exp_item_date
                					);
			End If;

			l_stage := 'Calling PA_COST_RATE_PUB.get_labor_rate API in STAFFED calling mode';
        		print_msg(l_debug_flag,l_stage);
			l_rate_organization_id := NVL(l_override_organization_id,
							NVl(p_incurred_by_organization_id,p_nlr_organization_id));
      			PA_COST_RATE_PUB.get_labor_rate
				     (p_person_id             => p_person_id
                                     ,p_txn_date              => p_Exp_item_date
                                     ,p_calling_module        =>'STAFFED'
                                     ,p_org_id                => NVL(p_expenditure_ou,p_project_OU)
                                     ,x_job_id                => l_job_id
                                     ,x_organization_id       =>l_rate_organization_id
                                     ,x_cost_rate             =>l_txn_raw_cost_rate
                                     ,x_start_date_active     =>l_start_date_active
                                     ,x_end_date_active       =>l_end_date_active
                                     ,x_org_labor_sch_rule_id =>l_org_labor_sch_rule_id
                                     ,x_costing_rule          =>l_costing_rule
                                     ,x_rate_sch_id           =>l_rate_sch_id
                                     ,x_cost_rate_curr_code   =>l_txn_curr_code
                                     ,x_acct_rate_type        =>l_acct_rate_type
                                     ,x_acct_rate_date_code   =>l_acct_rate_date_code
                                     ,x_acct_exch_rate        =>l_acct_exch_rate
                                     ,x_ot_project_id         =>l_ot_project_id
                                     ,x_ot_task_id            =>l_ot_task_id
                                     ,x_err_stage             => l_msg_data
                                     ,x_err_code              => l_err_code
                                     );

			l_stage := 'After get_labor_rate :return code['||l_err_code||']msgData['||l_msg_data||
				   ']LaborCostRate['||l_txn_raw_cost_rate||']CostCurrCode['||l_txn_curr_code||']' ;
			print_msg(l_debug_flag,l_stage);

			If l_err_code is NOT NULL OR l_txn_raw_cost_rate is NULL THEN
				l_stage := 'No Rate from Get Labor Rate(STAFFED) API:'||l_msg_data ;
				print_msg(l_debug_flag,l_stage);
                                x_raw_cost_rejection_code := 'PA_FP_MISSING_RATE';
                                RAISE l_no_rate_found;
                        End If;

			If l_txn_curr_code is NOT NULL Then
				l_txn_raw_cost_rate := l_txn_raw_cost_rate * NVL(l_cost_rate_multiplier,1);
				l_txn_raw_cost := pa_currency.round_trans_currency_amt1
						(l_txn_raw_cost_rate * NVL(p_quantity,0), l_txn_curr_code );
			End If;

		End If;

	ELSIF l_trxn_type = 'NON LABOR RESOURCE RATE' Then
		-- Call non-labor raw cost api
		l_stage := 'Calling Non Labor raw cost API';
		print_msg(l_debug_flag,l_stage);
		If (p_non_labor_resource is NOT NULL and p_expenditure_type is NOT NULL ) Then
			pa_cost1.Get_Non_Labor_raw_cost
        		(p_project_id                   => p_project_id
	        	,p_task_id                      => p_task_id
	        	,p_non_labor_resource           => p_non_labor_resource
	        	,p_nlr_organization_id          => p_nlr_organization_id
	        	,p_expenditure_type             => p_expenditure_type
	        	,p_exp_item_date                => p_exp_item_date
	        	,p_override_organization_id     => l_rate_organization_id
	        	,p_quantity                     => p_quantity
	        	,p_org_id                       => NVL(p_expenditure_ou,p_project_ou)
			,p_nlr_schedule_id              => Null
	        	,x_trxn_raw_cost_rate           => l_txn_raw_cost_rate
	        	,x_trxn_raw_cost                => l_txn_raw_cost
	        	,x_txn_currency_code            => l_txn_curr_code
	        	,x_return_status                => l_return_status
	        	,x_error_msg_code               => l_msg_data
	        	);
		 	l_stage := 'After Get_Non_Labor_raw_cost api return status['||l_return_status||']msgData['||l_msg_data||
                                ']NlrCostrate['||l_txn_raw_cost_rate||']NlrRawcost['||l_txn_raw_cost||
				']NlrCostRateCurr['||l_txn_curr_code||']' ;
                        print_msg(l_debug_flag,l_stage);

                        IF l_return_status <> 'S' OR l_txn_curr_code is NULL Then
				x_raw_cost_rejection_code := 'PA_NLR_NO_RATE_FOUND' ;
                                RAISE l_no_rate_found;
                        End If;
		End If;

	ELSIF l_trxn_type = 'EXP TYPE RATE' Then
		If ( p_exp_item_date is  NOT NULL and p_expenditure_type is NOT NULL
		     and NVL(p_expenditure_ou,p_project_ou) is NOT NULL ) Then
			/* get the currency code */
        		l_txn_curr_code := Get_curr_code(p_org_id => NVL(p_expenditure_ou,p_project_ou));
			l_txn_raw_cost_rate := GetExpTypeCostRate
                                               (p_exp_type      => p_expenditure_type
                                               ,p_exp_item_date => p_exp_item_date
                                               ,p_org_id        => NVL(p_expenditure_ou,p_project_ou)
                                               );

                        If l_txn_raw_cost_rate is NULL OR l_txn_curr_code is NULL Then
				l_stage := 'No Rate from GetExpTypeCostRate api';
                                print_msg(l_debug_flag,l_stage);
                                x_raw_cost_rejection_code := 'PA_FP_MISSING_RATE';
				RAISE l_no_rate_found;
                        End If;

			If l_txn_raw_cost_rate is NOT NULL and l_txn_curr_code is NOT NULL Then
				l_txn_raw_cost := pa_currency.round_trans_currency_amt1
                                                (l_txn_raw_cost_rate * NVL(p_quantity,0), l_txn_curr_code );
			End If;
                        l_stage := 'ExpcostRateCur['||l_txn_curr_code||']ExpCostRate['||l_txn_raw_cost_rate||']' ;
                        print_msg(l_debug_flag,l_stage);
		End If;

	ELSIF l_trxn_type = 'EXP TYPE RATE N_FLAG' Then
		If p_override_trxn_curr_code is NULL Then
		     l_txn_curr_code := Get_curr_code(p_org_id =>
					NVL(p_expenditure_ou,p_project_ou));
		Else
		     l_txn_curr_code := p_override_trxn_curr_code;
		End If;

		l_txn_raw_cost_rate := 1;
		If l_txn_raw_cost_rate is NULL OR l_txn_curr_code is NULL Then
                         l_stage := 'No Rate currency code from Get_curr_code api';
                         print_msg(l_debug_flag,l_stage);
                         x_raw_cost_rejection_code := 'PA_FP_MISSING_RATE';
                         RAISE l_no_rate_found;
                End If;

                If l_txn_raw_cost_rate is NOT NULL and l_txn_curr_code is NOT NULL Then
                        l_txn_raw_cost := pa_currency.round_trans_currency_amt1
                                          (l_txn_raw_cost_rate * NVL(p_quantity,0),
						 l_txn_curr_code );
                End If;
                l_stage := 'Get_curr_code['||l_txn_curr_code||']ExpCostRate['||
				l_txn_raw_cost_rate||']' ;
                print_msg(l_debug_flag,l_stage);

	ELSIF l_trxn_type in ('LABOR SCH RATE','JOB SCH RATE','NON LABOR SCH RATE') Then
                        /* Derive default labor cost multiplier for the given Tasks */
                        IF ( p_task_id IS NOT NULL AND l_cost_rate_multiplier is NULL
			     and l_trxn_type IN ('LABOR SCH RATE','JOB SCH RATE' )) THEN
                                l_stage := 'Getting  labor cost multiplier name';
                                l_cost_rate_multiplier := get_CostRateMultiplier
                                                        (p_task_id        => p_task_id
                                                        ,p_exp_item_date  => p_exp_item_date
                                                        );
                        End If;

                        l_rate_organization_id := NVL(l_override_organization_id,
                                                        NVl(p_incurred_by_organization_id,p_nlr_organization_id));
			If l_trxn_type = 'LABOR SCH RATE' Then
				l_bill_rate_schedule_type := 'EMPLOYEE';
				l_bill_rate_sch_id        := p_plan_cost_emp_rate_sch_id ;
			Elsif l_trxn_type = 'JOB SCH RATE' Then
				l_bill_rate_schedule_type := 'JOB';
				l_bill_rate_sch_id        := p_plan_cost_job_rate_sch_id ;
			Elsif l_trxn_type = 'NON LABOR SCH RATE' Then
				l_bill_rate_schedule_type := 'NON-LABOR';
				l_bill_rate_sch_id        := p_plan_cost_Nlr_rate_sch_id ;
				l_cost_rate_multiplier    := NULL;
			End If;
                        l_stage := 'Calling get_RateSchDetails SchType['||l_bill_rate_schedule_type||']SchId['||l_bill_rate_sch_id||']';
                        print_msg(l_debug_flag,l_stage);
			pa_cost1.get_RateSchDetails
                		(p_schedule_type        => l_bill_rate_schedule_type
                		,p_rate_sch_id          => l_bill_rate_sch_id
                		,p_person_id            => p_person_id
                		,p_job_id               => p_job_id
                		,p_non_labor_resource   => p_non_labor_resource
                		,p_expenditure_type     => p_expenditure_type
                		,p_rate_organization_id => l_rate_organization_id
                		,p_exp_item_date        => p_exp_item_date
                		,p_org_id               => NVL(p_expenditure_OU,p_project_ou)
                		,x_currency_code        => l_txn_curr_code
                		,x_cost_rate            => l_txn_raw_cost_rate
                		,x_markup_percent       => l_markup_percent
                		,x_return_status        => l_return_status
                		,x_error_msg_code       => l_msg_data );

                        l_stage := 'After Calling Get_RateSchDetails api return status['||l_return_status||
			        ']msgData['||l_msg_data||']RateSchCostrate['||l_txn_raw_cost_rate||
				']RateSchRawcost['||l_txn_raw_cost||']RateSchCurr['||l_txn_curr_code||
				']MarkupPercent['||l_markup_percent||']' ;
                        print_msg(l_debug_flag,l_stage);

			/* check if no rate found for the Employee sch then derive the
			 * rate from job schedule if the resource class is people
			 */
			IF l_return_status <> 'S' OR l_txn_curr_code is NULL Then
			     If (p_resource_class = 'PEOPLE'
				 AND l_trxn_type = 'LABOR SCH RATE'
				 AND p_job_id is NOT NULL
				 AND p_plan_cost_job_rate_sch_id is NOT NULL )  Then

				  l_trxn_type := 'JOB SCH RATE' ;
                                  l_bill_rate_schedule_type := 'JOB';
                                  l_bill_rate_sch_id  := p_plan_cost_job_rate_sch_id ;

				  l_stage := 'Calling get_RateSchDetails SchType['
					||l_bill_rate_schedule_type||']SchId['
					||l_bill_rate_sch_id||']';
                        	  print_msg(l_debug_flag,l_stage);
                                pa_cost1.get_RateSchDetails
                                (p_schedule_type        => l_bill_rate_schedule_type
                                ,p_rate_sch_id          => l_bill_rate_sch_id
                                ,p_person_id            => p_person_id
                                ,p_job_id               => p_job_id
                                ,p_non_labor_resource   => p_non_labor_resource
                                ,p_expenditure_type     => p_expenditure_type
                                ,p_rate_organization_id => l_rate_organization_id
                                ,p_exp_item_date        => p_exp_item_date
                                ,p_org_id               => NVL(p_expenditure_OU,p_project_ou)
                                ,x_currency_code        => l_txn_curr_code
                                ,x_cost_rate            => l_txn_raw_cost_rate
                                ,x_markup_percent       => l_markup_percent
                                ,x_return_status        => l_return_status
                                ,x_error_msg_code       => l_msg_data );

				l_stage := 'After Calling Get_JOBRateSchDetails api return status['||l_return_status||
                                ']msgData['||l_msg_data||']RateSchCostrate['||l_txn_raw_cost_rate||
                                ']RateSchRawcost['||l_txn_raw_cost||']RateSchCurr['||l_txn_curr_code||
                                ']MarkupPercent['||l_markup_percent||']' ;
                        	print_msg(l_debug_flag,l_stage);

			    End If;
			End If;

                        IF l_return_status <> 'S' OR l_txn_curr_code is NULL Then
                                x_raw_cost_rejection_code := 'PA_NO_PLAN_SCH_RATE_FOUND' ;
                                RAISE l_no_rate_found;
                        End If;
                        If l_txn_curr_code is NOT NULL Then
                                l_txn_raw_cost_rate := l_txn_raw_cost_rate * NVL(l_cost_rate_multiplier,1);
                                l_txn_raw_cost := pa_currency.round_trans_currency_amt1
                                                (l_txn_raw_cost_rate * NVL(p_quantity,0), l_txn_curr_code );
                        End If;

	END If; -- end of the transaction type

        --Assign the out variables
        x_trxn_curr_code               := l_txn_curr_code;
        x_trxn_raw_cost                := l_txn_raw_cost;
        x_trxn_raw_cost_rate           := l_txn_raw_cost_rate;
        l_stage := 'End of Raw Cost Calculation:RawCost['||x_trxn_raw_cost||']Rate['||x_trxn_raw_cost_rate||
		   ']CurrCode['||x_trxn_curr_code||']';
	print_msg(l_debug_flag,l_stage);
        /* End of Raw Cost calculation*/

	l_proj_flag := pa_cost1.check_proj_burdened(p_project_type,p_project_id);
	print_msg(l_debug_flag,'ProjBurdFlag['||l_proj_flag||']');
	-- Check if project type is burdened if so calculate the burdened  costs

	/**** Burden cost Calculation Starts here */

	If x_trxn_raw_cost is NOT NULL Then

		If ( p_override_trxn_burden_cost is NOT NULL OR
		    p_override_burden_cost_rate  is NOT NULL)  Then
			--assigning override burden cost to out params
			l_stage := 'Deriving burden cost from Override params';
			/* Assign burden cost*/
			If p_override_trxn_burden_cost is NOT NULL Then
				l_burden_cost := p_override_trxn_burden_cost;

			Elsif p_override_burden_cost_rate is NOT NULL Then
				-- if quantity is zero this is amount based so multiply cost * rate
				If NVL(p_quantity,0) = 0 Then
				    l_burden_cost := pa_currency.round_trans_currency_amt1
                                                (p_override_burden_cost_rate * x_trxn_raw_cost ,l_txn_curr_code ) ;
				Else
                                    l_burden_cost := pa_currency.round_trans_currency_amt1
                                                (p_override_burden_cost_rate * NVL(p_quantity,1),l_txn_curr_code ) ;
				End If;
			End If;

			/* assign burden cost rate */
			If p_override_burden_cost_rate is NOT NULL Then
				l_burden_cost_rate := p_override_burden_cost_rate;
			Else
				If NVL(P_quantity, 0) <> 0 Then
					If l_burden_cost = l_txn_raw_cost Then
						l_burden_cost_rate  := x_trxn_raw_cost_rate;
					Else
						l_burden_cost_rate :=  l_burden_cost / NVL(p_quantity,1) ;
					End If;
                		Else
                        		l_burden_cost_rate  := x_trxn_raw_cost_rate;
				End If;
			End If;

			/* derive burden multiplier */
			If NVL(l_txn_raw_cost,0) <> 0 then
				l_burden_multiplier := (l_burden_cost-l_txn_raw_cost) / l_txn_raw_cost ;
			Else
				l_burden_multiplier := 0;
			End If;

		ElsIf ( pa_cost1.check_proj_burdened(p_project_type,p_project_id) = 'Y' ) Then

			l_stage := 'Calling PA_COST1.Get_burden_sch_details API';
			print_msg(l_debug_flag,l_stage);
			pa_cost1.Get_burden_sch_details
                	(p_calling_mode                 => p_calling_mode
			,p_exp_item_id                  => NULL
                	,p_trxn_type                    => NULL
                	,p_project_type                 => p_project_type
                	,p_project_id                   => p_project_id
                	,p_task_id                      => p_task_id
                	,p_exp_organization_id          => l_rate_organization_id
			,p_overide_organization_id      => l_override_organization_id
			,p_person_id                    => p_person_id
			,p_expenditure_type             => p_expenditure_type
                	,p_schedule_type                => 'C'
                	,p_exp_item_date                => p_exp_item_date
                	,p_trxn_curr_code               => l_txn_curr_code
			,p_burden_schedule_id           => p_plan_cost_burden_sch_id
                	,x_schedule_id                  => l_burd_sch_id
                	,x_sch_revision_id              => l_burd_sch_rev_id
                	,x_sch_fixed_date               => l_burd_sch_fixed_date
                	,x_cost_base                    => l_burd_sch_cost_base
                	,x_cost_plus_structure          => l_burd_sch_cp_structure
                	,x_compiled_set_id              => l_burd_ind_compiled_set_id
                	,x_burden_multiplier            => l_burden_multiplier
                	,x_return_status                => l_return_status
                	,x_error_msg_code               => l_msg_data
				);
			l_stage := 'After Get_Burdened_cost api return status['||l_return_status||']msgData['||l_msg_data||']' ;
			print_msg(l_debug_flag,l_stage);

			If ( l_return_status <> 'S' OR l_burden_multiplier is NULL ) Then
				l_stage := 'Error while Calculating burden costs';
                        	x_burden_cost_rejection_code := substr(l_msg_data,1,30);
                        	Raise l_no_rate_found;
                	End If;

                	/* Bug fix: 4240140 l_burden_cost := (l_txn_raw_cost * l_burden_multiplier) + l_txn_raw_cost ;
			If NVL(P_quantity, 0) <> 0 Then
				--assign raw cost rate to burden cost rate if burden cost is same as raw cost
				If l_burden_cost = l_txn_raw_cost Then
					l_burden_cost_rate := x_trxn_raw_cost_rate;
				Else
              				l_burden_cost_rate  := l_burden_cost / NVL(P_quantity, 1) ;
				End If;
			Else
				l_burden_cost_rate  := x_trxn_raw_cost_rate;
			End If;
			*/
			If (NVL(P_quantity, 0) <> 0 AND NVL(l_txn_raw_cost_rate,0) <> 0 ) Then
			   l_burden_cost_rate := (l_txn_raw_cost_rate * l_burden_multiplier ) + l_txn_raw_cost_rate;
			   l_burden_cost := pa_currency.round_trans_currency_amt1((P_quantity*l_burden_cost_rate),l_txn_curr_code);
			Else
			   l_burden_cost := (l_txn_raw_cost * l_burden_multiplier) + l_txn_raw_cost ;
			   If l_burden_cost = l_txn_raw_cost Then
                                l_burden_cost_rate := l_txn_raw_cost_rate;
                           Else
				l_burden_cost_rate  := l_burden_cost / NVL(P_quantity, 1) ;
			   End If;
			End If;
			x_burden_multiplier := l_burden_multiplier;
			x_cost_ind_compiled_set_id := l_burd_ind_compiled_set_id;

		Else  -- project type is not burdened
			--copy the raw cost to the burden costs
			l_stage := 'Copying raw costs to burden costs';
			print_msg(l_debug_flag,l_stage);

			l_burden_cost := l_txn_raw_cost;
			l_burden_cost_rate := l_txn_raw_cost_rate;
			l_burden_multiplier := 0;

		End IF;

	End If; -- end of raw cost is not null
	--Assign values to the out variables
        x_trxn_burden_cost             := l_burden_cost;
        x_trxn_burden_cost_rate        := l_burden_cost_rate;
	x_burden_multiplier            := NVL(l_burden_multiplier,0);

        /* Raise invalid currency code when the derived rate sch currency code is different from
        *  passed value override currency code
        */
        If p_override_trxn_curr_code is NOT NULL Then
           If  p_override_trxn_curr_code <> NVL(l_txn_curr_code ,p_override_trxn_curr_code) Then
                        l_stage := 'Invalid override currency is passed';
			print_msg(l_debug_flag,l_stage||'[costtxncur['||l_txn_curr_code||']OvrCur['||p_override_trxn_curr_code||']');
                        Raise l_invalid_currency;
           End If;
        End if;

	l_stage := 'End of Burden Calculation burdenCost['||x_trxn_burden_cost||']burdenCostrate['||x_trxn_burden_cost_rate||
		   ']burdenMultiplier['||x_burden_multiplier||']' ;
	print_msg(l_debug_flag,l_stage);
	/* End of burden cost calculation */

        x_error_msg_code               := l_msg_data;
	x_return_status                := l_return_status;

	-- reset the error stack
	If l_debug_flag = 'Y' Then
		PA_DEBUG.reset_err_stack;
	End If;

EXCEPTION
	WHEN l_insufficient_parms  THEN
		If NVL(p_calling_mode,'ACTUAL_RATES')  = 'ACTUAL_RATES' Then
		  If p_resource_class = 'PEOPLE' Then
			x_error_msg_code := 'PA_INVALID_ACT_PEOPLE_PARAMS';
		  Elsif p_resource_class = 'EQUIPMENT' Then
			x_error_msg_code := 'PA_INVALID_ACT_EQUIP_PARAMS';
		  Elsif p_resource_class = 'MATERIAL_ITEMS' Then
			x_error_msg_code := 'PA_INVALID_ACT_MAT_PARAMS';
		  Elsif p_resource_class = 'FINANCIAL_ELEMENTS' Then
			x_error_msg_code := 'PA_INVALID_ACT_FIN_PARAMS';
		  End If;
	        Else
                  If p_resource_class = 'PEOPLE' Then
                        x_error_msg_code := 'PA_INVALID_PLAN_PEOPLE_PARAMS';
                  Elsif p_resource_class = 'EQUIPMENT' Then
                        x_error_msg_code := 'PA_INVALID_PLAN_EQUIP_PARAMS';
                  Elsif p_resource_class = 'MATERIAL_ITEMS' Then
                        x_error_msg_code := 'PA_INVALID_PLAN_MAT_PARAMS';
                  Elsif p_resource_class = 'FINANCIAL_ELEMENTS' Then
                        x_error_msg_code := 'PA_INVALID_PLAN_FIN_PARAMS';
                  End If;
		End If;
		If x_error_msg_code is NULL Then
			x_error_msg_code := 'PA_COST1_INVALID_PARAMS';
		End If;
		x_return_status := 'E';
		print_msg(l_debug_flag,l_stage);
		If l_debug_flag = 'Y' Then
	        	PA_DEBUG.write_file('LOG',l_stage);
                	PA_DEBUG.write_file('LOG','ReturnStatus['||l_return_status||']ErrMsg['||l_msg_data||']errCode['||l_err_code||']' );
			PA_DEBUG.reset_err_stack;
		End If;

        WHEN l_no_rate_found THEN
                x_error_msg_code := 'PA_FP_MISSING_RATE';
                x_return_status := 'E';
		print_msg(l_debug_flag,l_stage);
		If l_debug_flag = 'Y' Then
                	PA_DEBUG.write_file('LOG',l_stage);
                	PA_DEBUG.write_file('LOG','ReturnStatus['||l_return_status||']ErrMsg['||l_msg_data||']errCode['||l_err_code||']' );
			PA_DEBUG.reset_err_stack;
		End If;

	WHEN l_no_burdrate_found THEN
                x_error_msg_code := 'PA_CALC_BURDENED_COST_FAILED';
                x_return_status := 'E';
                print_msg(l_debug_flag,l_stage);
		If l_debug_flag = 'Y' Then
                	PA_DEBUG.write_file('LOG',l_stage);
                	PA_DEBUG.write_file('LOG','ReturnStatus['||l_return_status||']ErrMsg['||l_msg_data||']errCode['||l_err_code||']' );
                	PA_DEBUG.reset_err_stack;
		End If;

        WHEN l_invalid_override_attributes THEN
                x_error_msg_code := 'PA_INVALID_OVERRIDE_PARAM';
                x_return_status := 'E';
		print_msg(l_debug_flag,l_stage);
		If l_debug_flag = 'Y' Then
                	PA_DEBUG.write_file('LOG',l_stage);
                	PA_DEBUG.write_file('LOG','ReturnStatus['||l_return_status||']ErrMsg['||l_msg_data||']errCode['||l_err_code||']' );
			PA_DEBUG.reset_err_stack;
		End If;

	WHEN l_invalid_currency THEN
		x_error_msg_code := 'PA_INVALID_DENOM_CURRENCY';
		x_return_status := 'E';
		print_msg(l_debug_flag,l_stage);
		If l_debug_flag = 'Y' Then
                	PA_DEBUG.write_file('LOG',l_stage);
                	PA_DEBUG.write_file('LOG','ReturnStatus['||l_return_status||']ErrMsg['||l_msg_data||']errCode['||l_err_code||']' );
			PA_DEBUG.reset_err_stack;
		End If;


	WHEN OTHERS THEN
		IF to_char(sqlcode) in ('00100','01403','100','1403') Then
                        x_return_status := 'E';
                        x_error_msg_code := 'PA_FP_MISSING_RATE';
                Else
                        x_return_status := 'U';
                        x_error_msg_code := substr(SQLCODE||SQLERRM,1,30);
                End If;
		print_msg(l_debug_flag,l_stage);
		If l_debug_flag = 'Y' Then
			PA_DEBUG.write_file('LOG',l_stage);
			PA_DEBUG.write_file('LOG','ReturnStatus['||l_return_status||']sqlcode['||sqlcode||']ErrMsg['||x_error_msg_code||']');
			PA_DEBUG.reset_err_stack;
		End If;

END Get_Plan_Actual_Cost_Rates;


PROCEDURE  Get_Non_Labor_raw_cost
        (p_project_id                   IN           NUMBER
        ,p_task_id                      IN           NUMBER
        ,p_non_labor_resource           IN           VARCHAR2
        ,p_nlr_organization_id          IN           NUMBER
        ,p_expenditure_type             IN           VARCHAR2
        ,p_exp_item_date                IN           DATE
        ,p_override_organization_id     IN           NUMBER
        ,p_quantity                     IN           NUMBER
        ,p_org_id                       IN           NUMBER
        ,p_nlr_schedule_id              IN           NUMBER
	,p_nlr_trxn_cost_rate           IN           NUMBER DEFAULT NULL
	,p_nlr_trxn_raw_cost            IN           NUMBER DEFAULT NULL
	,p_nlr_trxn_currency_code       IN           VARCHAR2 DEFAULT NULL
        ,x_trxn_raw_cost_rate           OUT  NOCOPY  NUMBER
        ,x_trxn_raw_cost                OUT  NOCOPY  NUMBER
        ,x_txn_currency_code            OUT  NOCOPY  VARCHAR2
        ,x_return_status                OUT  NOCOPY  VARCHAR2
        ,x_error_msg_code               OUT  NOCOPY  VARCHAR2
        ) IS

	l_return_status    varchar2(1000) := 'S';
	l_msg_data         varchar2(1000);
	l_msg_count        Number;
	l_stage            varchar2(1000);
	l_debug_flag       varchar2(10);
	l_exp_cost_rate_flag  varchar2(100);
	l_nlr_raw_cost         Number;
	l_nlr_raw_cost_rate    Number;
	l_nlr_txn_curr_code    varchar2(100);
	l_cost_rate_curr_code varchar2(100);


	Cursor cur_nlr_sch_details IS
	SELECT sch.rate_sch_currency_code
	       ,rates.rate
        FROM   pa_std_bill_rate_schedules_all sch
	       ,pa_bill_rates_all rates
        WHERE  sch.bill_rate_sch_id = p_nlr_schedule_id
	AND    sch.schedule_type = 'NON-LABOR'
	AND    rates.bill_rate_sch_id = sch.bill_rate_sch_id
	AND    rates.expenditure_type = p_expenditure_type
	AND    ( rates.non_labor_resource is NULL
		 OR rates.non_labor_resource = p_non_labor_resource
	       )
	AND    trunc(p_exp_item_date) between trunc(rates.start_date_active)
                  and trunc(nvl(rates.end_date_active,p_exp_item_date))
	/*Bug fix:3793618 This is to ensure that records with NLR and Exp combo orders first */
        ORDER BY decode(rates.non_labor_resource,p_non_labor_resource,0,1),rates.expenditure_type ;

BEGIN
        --- Initialize the error statck
	If g_debug_flag is NULL Then
                fnd_profile.get('PA_DEBUG_MODE',g_debug_flag);
                g_debug_flag := NVL(g_debug_flag, 'N');
        End If;
        l_debug_flag := NVL(g_debug_flag,'N');
	IF l_debug_flag = 'Y' Then
        	PA_DEBUG.init_err_stack ('PA_COST1.Get_Non_Labor_raw_cost');
        	PA_DEBUG.SET_PROCESS( x_process => 'PLSQL'
                      ,x_write_file     => 'LOG'
                      ,x_debug_mode      => l_debug_flag
                          );
	End If;
	--Initialize the out varibales
	l_return_status := 'S';
	l_msg_data := Null;
	l_nlr_txn_curr_code := p_nlr_trxn_currency_code;
	l_cost_rate_curr_code := Null;

	l_exp_cost_rate_flag := check_expCostRateFlag(p_expenditure_type);

	l_stage := 'Inside PA_COST1.Get_Non_Labor_raw_cost API CostRateFlag['||l_exp_cost_rate_flag||']' ;
	print_msg(l_debug_flag,l_stage);

	/* get the currency code */
	l_stage := 'Getting currency code the for the given OU';
	print_msg(l_debug_flag,l_stage);
	l_cost_rate_curr_code := Get_curr_code(p_org_id => p_org_id );

	If l_cost_rate_curr_code is NULL Then
		l_stage :='Currency not found for the OU';
		print_msg(l_debug_flag,l_stage);
		l_return_status := 'E';
	End If;

	IF l_exp_cost_rate_flag = 'N' Then
		l_nlr_raw_cost_rate := 1;

	ELSE
		-- check the cost rates available at non labor resource level if no rate found then
		-- get the rates at expendityre type level, if no rate found then return error
	    BEGIN

		/** commented as NLR schedule is not used to derive cost rates
		If p_nlr_schedule_id is NOT NULL Then
			Open cur_nlr_sch_details;
			Fetch cur_nlr_sch_details
				INTO l_cost_rate_curr_code
				    ,l_nlr_raw_cost_rate;
			Close cur_nlr_sch_details;
		End If;
		**/

		IF l_cost_rate_curr_code IS NOT NULL Then

			/* bug fix: 3819799 changed the order of the table. Now first hit the PA_Expenditure_Cost_Rates_all instead of
                	* PA_Expenditure_Types.  This will avoid the following issue
                	* PA_USAGE_COST_RATE_OVR_ALL is being referenced more than 3 times.
                	* Single-row table count exceeds 3 for PA_USAGE_COST_RATE_OVR_ALL.
                	*/
			l_stage := 'Getting Cost rates from Usage Overrides';
			print_msg(l_debug_flag,l_stage);
			SELECT  R.Rate
			INTO l_nlr_raw_cost_rate
                	FROM PA_Expenditure_Types T,
                     		PA_Usage_Cost_Rate_Ovr_all R
                	WHERE T.Expenditure_type = R.Expenditure_type
                 	AND T.Cost_Rate_Flag = 'Y'
                 	AND R.Expenditure_type = p_expenditure_type
                 	AND R.Non_Labor_Resource = p_Non_Labor_Resource
                 	AND R.Organization_Id = NVL(p_nlr_organization_id,p_override_organization_id)
		 	AND NVL(R.org_id,-99) = NVL(p_org_id,-99)
                 	AND trunc(p_exp_item_date)
                     		BETWEEN R.Start_Date_Active
                         		AND NVL(R.End_Date_Active, p_exp_item_date);

		END If;

		l_stage := 'costRateCur['||l_cost_rate_curr_code||']RawCostRate['||l_nlr_raw_cost_rate||']' ;
		print_msg(l_debug_flag,l_stage);

 	   EXCEPTION

		WHEN NO_DATA_FOUND THEN

		     BEGIN
			l_stage := 'Getting Cost rates from expenditure type cost rates';
			print_msg(l_debug_flag,l_stage);
			l_nlr_raw_cost_rate := GetExpTypeCostRate
					(p_exp_type      => p_expenditure_type
                           		,p_exp_item_date => p_exp_item_date
                           		,p_org_id        => p_org_id
                           		);
		        l_stage := 'costRateCur['||l_cost_rate_curr_code||']RawCostRate['||l_nlr_raw_cost_rate||']' ;
                        print_msg(l_debug_flag,l_stage);

			If l_nlr_raw_cost_rate is NULL Then
				l_msg_data := 'PA_NLR_NO_RATE_FOUND';
                                l_return_status := 'E';
                                l_stage := 'No Rates found for Non-labor resources';
			End If;
		     END;

		WHEN OTHERS THEN
                    l_return_status := 'U';
                    l_msg_data := SQLCODE||SQLERRM;
	     END;

	END IF;

	If p_nlr_trxn_raw_cost is NOT NULL Then
		l_nlr_raw_cost := p_nlr_trxn_raw_cost;
	ElsIF l_cost_rate_curr_code is NOT NULL Then
	   If l_nlr_raw_cost_rate is NOT NULL Then
		 l_nlr_raw_cost := pa_currency.round_trans_currency_amt1
				   (l_nlr_raw_cost_rate * NVL(p_quantity,0), l_cost_rate_curr_code );
	   End If;

	End If;
	-- Assign the output variables with the derived values
	x_return_status     := l_return_status;
	x_error_msg_code    := l_msg_data;
	x_trxn_raw_cost     := l_nlr_raw_cost;
	x_trxn_raw_cost_rate:= l_nlr_raw_cost_rate;
	x_txn_currency_code := NVL(l_cost_rate_curr_code,l_nlr_txn_curr_code);

        -- reset the error stack
	If l_debug_flag = 'Y' Then
        	PA_DEBUG.reset_err_stack;
	End If;

EXCEPTION

        WHEN OTHERS THEN
		print_msg(l_debug_flag,l_stage);
		If l_debug_flag = 'Y' Then
                	PA_DEBUG.write_file('LOG',l_stage);
                	PA_DEBUG.write_file('LOG','ReturnStatus['||l_return_status||']ErrMsg['||l_msg_data||']' );
			PA_DEBUG.reset_err_stack;
		End If;
END Get_Non_Labor_raw_cost;

/* This is a wrapper api to derive compiled set id and burden multiplier
 * Which in turn makes calls to pa_cost_plus package
 * p_calling_mode  IN required for PLAN_RATES
 * p_burden_schedule_id IN required for PLAN_RATES
 */
PROCEDURE Get_burden_sch_details
		(p_calling_mode                 IN              VARCHAR2 DEFAULT 'ACTUAL_RATES'
		,p_exp_item_id   		IN 	 	NUMBER
		,p_trxn_type     		IN 		VARCHAR2
		,p_project_type                 IN              VARCHAR2
		,p_project_id                   IN              NUMBER
		,p_task_id                      IN      	NUMBER
		,p_exp_organization_id          IN              NUMBER
		/* bug fix:4232181 Derive organization override for burden calculate */
                ,p_overide_organization_id      IN              NUMBER   DEFAULT NULL
                ,p_person_id                    IN              NUMBER   DEFAULT NULL
                /* end of bug fix:4232181 */
		,p_expenditure_type             IN              VARCHAR2
		,p_schedule_type 		IN 		VARCHAR2 DEFAULT 'C'
		,p_exp_item_date                IN      	DATE
		,p_trxn_curr_code               IN              VARCHAR2
		,p_burden_schedule_id           IN              NUMBER DEFAULT NULL
		,x_schedule_id                  OUT NOCOPY 	NUMBER
		,x_sch_revision_id              OUT NOCOPY      NUMBER
		,x_sch_fixed_date               OUT NOCOPY      DATE
		,x_cost_base                    OUT NOCOPY      VARCHAR2
		,x_cost_plus_structure          OUT NOCOPY      VARCHAR2
		,x_compiled_set_id              OUT NOCOPY      NUMBER
		,x_burden_multiplier            OUT NOCOPY      NUMBER
		,x_return_status                OUT NOCOPY      VARCHAR2
		,x_error_msg_code               OUT NOCOPY      VARCHAR2 ) IS

		l_exp_item_id                  NUMBER := p_exp_item_id;
                l_trxn_type                    VARCHAR2(150) := p_trxn_type;
                l_project_type                 VARCHAR2(150) := p_project_type;
                l_project_id                   NUMBER := p_project_id;
                l_task_id                      NUMBER := p_task_id;
                l_exp_organization_id          NUMBER := p_exp_organization_id;
                l_overide_organization_id      NUMBER := p_overide_organization_id;
		l_person_id		       NUMBER := p_person_id;
                l_schedule_type                VARCHAR2(150) := p_schedule_type;
                l_exp_item_date                DATE := p_exp_item_date;
                l_trxn_curr_code               VARCHAR2(150) := p_trxn_curr_code;
		l_expenditure_type             VARCHAR2(150) := p_expenditure_type;
                l_schedule_id                  NUMBER          := NULL;
                l_sch_revision_id              NUMBER          := NULL;
                l_sch_fixed_date               DATE            := NULL;
                l_cost_base                    VARCHAR2(150)   := NULL;
                l_cost_plus_structure          VARCHAR2(150)   := NULL;
                l_compiled_set_id              NUMBER          := NULL;
                l_burden_multiplier            NUMBER          := NULL;
                l_return_status                VARCHAR2(100)   := 'S';
                l_error_msg_code               VARCHAR2(1000)  := NULL;
		l_stage                        VARCHAR2(1000)  := NULL;
		l_err_code                     VARCHAR2(1000)  := NULL;
		l_debug_flag                   VARCHAR2(100)   := 'N';
		l_status                       VARCHAR2(100)   := NULL;
		l_msg_count                    NUMBER  := 0;

		L_INVALID_SCHEDULE             EXCEPTION;
		L_NO_MULTIPLIER                EXCEPTION;
		L_NO_COMPILED_SET              EXCEPTION;
		L_INVALID_ERROR                EXCEPTION;
		L_NO_COST_BASE                 EXCEPTION;

BEGIN

        --- Initialize the error statck
	If g_debug_flag is NULL Then
                fnd_profile.get('PA_DEBUG_MODE',g_debug_flag);
                g_debug_flag := NVL(g_debug_flag, 'N');
        End If;
        l_debug_flag := NVL(g_debug_flag,'N');
	IF l_debug_flag = 'Y' Then
        	PA_DEBUG.init_err_stack ('PA_COST1.Get_burden_sch_details');
        	PA_DEBUG.SET_PROCESS( x_process => 'PLSQL'
                      ,x_write_file     => 'LOG'
                      ,x_debug_mode      => l_debug_flag
                          );
	End If;
	l_return_status := 'S';
	l_error_msg_code := NULL;
	x_return_status := 'S';
	x_error_msg_code := NULL;


	l_stage := 'Inside Get_burden_sch_details params ProjId['||l_project_id||']ProjType['||l_project_type||
		   ']TaskId['||l_task_id||']expOrgId['||l_exp_organization_id||']SchType['||l_schedule_type||
		   ']ExpType['||l_expenditure_type||']CurrCode['||l_trxn_curr_code||']EiDate['||l_exp_item_date||
		   ']BurdenSchId['||p_burden_schedule_id||']CallingMode['||p_calling_mode||']' ;
	print_msg(l_debug_flag,l_stage);

	If ( l_schedule_type is NOT NULL  and  check_proj_burdened (p_project_type ,p_project_id ) = 'Y')  Then
		--call the api to get the schedule info
		l_stage := 'Calling pa_cost_plus.find_rate_sch_rev_id to get sch Id and RevId';
		print_msg(l_debug_flag,l_stage);
		If l_schedule_type = 'COST' Then
			l_schedule_type := 'C';
		Elsif l_schedule_type = 'REVENUE' Then
			l_schedule_type := 'R';
		Elsif l_schedule_type is NULL Then
			l_schedule_type := 'C';
		End If;

		/* Derive the burden schedule revision based on the calling mode
		 * if calling mode is PLAN_RATES then schedule is already passed
		 * else schedule id should be derived based the given task or project */
		If p_calling_mode = 'ACTUAL_RATES' Then

		    IF (l_task_id is NULL  OR is_workPlan_Task(l_project_id,l_task_id) = 'Y') Then
			-- For Task Effort calculation the task id will be passed NULL so
			-- derive the schedule for the given project
			get_projLevel_BurdSchds
         		(p_project_id          => l_project_id
			,p_task_id             => NULL
        		,p_exp_item_date       => l_exp_item_date
        		,p_burden_sch_id       => p_burden_schedule_id
        		,x_burden_sch_id       => l_schedule_id
        		,x_burden_sch_revision_id => l_sch_revision_id
        		,x_status              => l_status
			);

		    ELSE  -- get details for the given task

			pa_cost_plus.find_rate_sch_rev_id
                        (l_exp_item_id   		--transaction_id
                        ,l_trxn_type    		--transaction_type
                        ,l_task_id      		--t_id
                        ,l_schedule_type 		--schedule_type
                        ,l_exp_item_date 		--exp_item_date
                       	,l_schedule_id           	--x_sch_id
                        ,l_sch_revision_id              --x_rate_sch_rev_id
                        ,l_sch_fixed_date               --x_sch_fixed_date
                        ,l_status                       --x_status
                        ,l_error_msg_code               --x_stage
			);

		    END IF;

		    If l_status <> 0 Then

				l_stage := 'No Schedule or Revision found';
				print_msg(l_debug_flag,l_stage);
				Raise l_invalid_schedule;
		    End If;

		ElsIf p_calling_mode = 'PLAN_RATES' Then
			/* get the schedule revision id for the given schedule
                         * For Task Effort calculation the task id will be passed NULL so
                         * derive the schedule for the given project
			 */
			l_schedule_id := p_burden_schedule_id;
                        get_projLevel_BurdSchds
                        (p_project_id          => l_project_id
			,p_task_id	       => l_task_id
                        ,p_exp_item_date       => l_exp_item_date
                        ,p_burden_sch_id       => p_burden_schedule_id
                        ,x_burden_sch_id       => l_schedule_id
                        ,x_burden_sch_revision_id => l_sch_revision_id
                        ,x_status              => l_status
                        );
                    If l_status <> 0 Then
                                l_stage := 'No Schedule Revision found nor Compiled for Planning burden Rate Schedule';
                                print_msg(l_debug_flag,l_stage);
                                Raise l_invalid_schedule;
                    End If;

		End If;

		If l_sch_revision_id is NOT NULL Then
			l_stage := 'Calling pa_cost_plus.get_cost_plus_structure api';
			print_msg(l_debug_flag,l_stage);
                        pa_cost_plus.get_cost_plus_structure
                        (l_sch_revision_id
                        ,l_cost_plus_structure
                        ,l_status
                        ,l_error_msg_code );

			If l_status <> 0 Then
				l_stage := 'No Cost Plus Structure';
				print_msg(l_debug_flag,l_stage);
                        	Raise L_INVALID_ERROR;
                	End If;
		End If;

		If l_cost_plus_structure is NOT NULL Then
			l_stage := 'Calling pa_cost_plus.get_cost_base api';
			print_msg(l_debug_flag,l_stage);
                        pa_cost_plus.get_cost_base
			(l_expenditure_type
                         ,l_cost_plus_structure
                         ,l_cost_base
                         ,l_status
                         ,l_error_msg_code );

                        If l_status <> 0 Then
                                l_stage := 'No Cost base found Status['||l_status||']';
                                print_msg(l_debug_flag,l_stage);
                                Raise L_NO_COST_BASE;
                        End If;


                End If;

		If l_cost_base is NOT NULL Then
			/* Bug fix:4232181  Get the override organization Id from the project level org overrides */
			/* sent mail to anders, if its ok to call this for all resource classes once receiving the responce
                         * the comment has to be opened
			IF l_overide_organization_id is NULL Then
                                l_stage := 'Calling pa_cost.Override_exp_organization api From Burden sch api';
                                print_msg(l_debug_flag,l_stage);
                                pa_cost.Override_exp_organization
                                (P_item_date                  => l_exp_item_date
                                ,P_person_id                  => l_person_id
                                ,P_project_id                 => l_project_id
                                ,P_incurred_by_organz_id      => l_exp_organization_id
                                ,P_Expenditure_type           => l_expenditure_type
                                ,X_overr_to_organization_id   => l_overide_organization_id
                                ,X_return_status              => l_return_status
                                ,X_msg_count                  => l_msg_count
                                ,X_msg_data                   => l_error_msg_code
                                );
                                l_stage := 'Return status of pa_cost.Override_exp_organization ['||l_return_status||']';
                                l_stage := l_stage||']msgData['||l_error_msg_code||']OverideOrg['||l_overide_organization_id||']' ;
                                print_msg(l_debug_flag,l_stage);
                        End If;
			**/
			l_stage := 'Calling pa_cost_plus.get_compiled_set_id api';
			print_msg(l_debug_flag,l_stage);
                        pa_cost_plus.get_compiled_set_id
                        (l_sch_revision_id
                        ,NVL(l_overide_organization_id,l_exp_organization_id)
                        ,l_cost_base
                        ,l_compiled_set_id
                        ,l_status
                        ,l_error_msg_code );

                        If l_status <> 0 Then
                                l_stage := 'No Cost Ind Compiled SetId exists';
				print_msg(l_debug_flag,l_stage);
                                Raise L_NO_COMPILED_SET;
                        End If;
                End If;

		IF l_compiled_set_id is NOT NULL Then
			l_stage := 'Calling pa_cost_plus.get_compiled_multiplier api';
			print_msg(l_debug_flag,l_stage);
			pa_cost_plus.get_compiled_multiplier
			(NVL(l_overide_organization_id,l_exp_organization_id)
                        ,l_cost_base
                        ,l_sch_revision_id
                        ,l_burden_multiplier
                        ,l_status
                        ,l_error_msg_code );

                        If l_status <> 0 Then
                                l_stage := 'No Compiled Multiplier exists';
				print_msg(l_debug_flag,l_stage);
                                Raise L_NO_MULTIPLIER;
                        End If;
                End If;
	End If; --end of task id not null

	--Assign the values to out params
	x_schedule_id            := l_schedule_id;
        x_sch_revision_id        := l_sch_revision_id;
        x_sch_fixed_date         := l_sch_fixed_date;
        x_cost_base              := l_cost_base;
        x_cost_plus_structure    := l_cost_plus_structure;
        x_compiled_set_id        := l_compiled_set_id;
        x_burden_multiplier      := l_burden_multiplier;
        x_return_status          := NVL(l_return_status,'S');
        x_error_msg_code         := substr(l_error_msg_code,1,30);

	l_stage := 'Out Param Values SchId['||x_schedule_id||']SchRev['||x_sch_revision_id||']Schdate['||x_sch_fixed_date||
		  ']Costbase['||x_cost_base||']CPStruc['||x_cost_plus_structure||']Compilset['||x_compiled_set_id||
		  ']BurdMulti['||x_burden_multiplier||']retSts['||x_return_status||']ErrMsg['||x_error_msg_code||']' ;
	print_msg(l_debug_flag,l_stage);

	--reset error stack
	If l_debug_flag = 'Y' Then
		PA_DEBUG.reset_err_stack;
	End If;

EXCEPTION
	WHEN l_invalid_schedule Then
		x_return_status := 'E';
		x_error_msg_code := 'PA_FCST_INVL_BURDEN_SCH_REV_ID';
		If l_debug_flag = 'Y' Then
			PA_DEBUG.write_file('ReturnSts['||l_return_status ||']ErrCode['||l_error_msg_code||']' );
			PA_DEBUG.write_file('LOG',l_stage);
			PA_DEBUG.reset_err_stack;
		End If;

        WHEN l_no_cost_base  Then
		If l_status = 100 Then
			-- ie. expenditure type is not part of the burdening
			-- so set the return status to success
			x_return_status := 'S';
			x_error_msg_code := NULL;
			x_burden_multiplier := 0;
		Else
			--ie. some unexpected error happened
			x_return_status := 'E';
			x_error_msg_code := 'PA_FCST_NO_COST_BASE';

		End If;
		If l_debug_flag = 'Y' Then
                PA_DEBUG.write_file('ReturnSts['||l_return_status ||']ErrCode['||l_error_msg_code||']' );
                PA_DEBUG.write_file('LOG',l_stage);
                PA_DEBUG.reset_err_stack;
		End If;

        WHEN l_no_compiled_set Then
		If p_exp_organization_id is NULL Then
			-- ie. expenditure organization id is not passed then
                        -- set the multiplier as zero so that burdened cost = raw cost
                        x_return_status := 'S';
                        x_error_msg_code := NULL;
                        x_burden_multiplier := 0;
		Else
                	x_return_status := 'E';
                	x_error_msg_code := 'PA_NO_COMPILED_SET_ID';
		End If;
		If l_debug_flag = 'Y' Then
                PA_DEBUG.write_file('ReturnSts['||l_return_status ||']ErrCode['||l_error_msg_code||']' );
                PA_DEBUG.write_file('LOG',l_stage);
                PA_DEBUG.reset_err_stack;
		End If;


        WHEN l_no_multiplier Then
                x_return_status := 'E';
                x_error_msg_code := 'PA_FCST_NO_COMPILED_MULTI';
		If l_debug_flag = 'Y' Then
                PA_DEBUG.write_file('ReturnSts['||l_return_status ||']ErrCode['||l_error_msg_code||']' );
                PA_DEBUG.write_file('LOG',l_stage);
                PA_DEBUG.reset_err_stack;
		End If;

	WHEN l_invalid_error Then
                x_return_status := 'E';
                x_error_msg_code := 'PA_CALC_BURDENED_COST_FAILED';
		If l_debug_flag = 'Y' Then
                PA_DEBUG.write_file('ReturnSts['||l_return_status ||']ErrCode['||l_error_msg_code||']' );
                PA_DEBUG.write_file('LOG',l_stage);
                PA_DEBUG.reset_err_stack;
		End If;

	WHEN OTHERS THEN
		IF to_char(sqlcode) in ('00100','01403','100','1403') Then
			x_return_status := 'E';
			x_error_msg_code := 'PA_CALC_BURDENED_COST_FAILED';
		Else
                	x_return_status := 'U';
			x_error_msg_code := substr(SQLCODE||SQLERRM,1,30);
		End If;
		If l_debug_flag = 'Y' Then
	        PA_DEBUG.write_file('ReturnSts['||l_return_status ||']ErrCode['||l_error_msg_code||']' );
                PA_DEBUG.write_file('LOG',l_stage);
		PA_DEBUG.reset_err_stack;
		End If;


END Get_burden_sch_details;

/* This is an internal API which will be called from Convert_COSTto PC and PFC api
 * this api does the calculation for amount conversion based on the planning conversion
 * attributes
 */
PROCEDURE Convert_amounts
   (p_calling_mode                      IN  VARCHAR2 DEFAULT 'PC'
   ,p_txn_raw_cost                      IN  NUMBER
   ,p_txn_burden_cost                   IN  NUMBER
   ,p_txn_quantity                      IN  NUMBER
   ,p_Conversion_Date                   IN  DATE
   ,p_From_curr_code                    IN  VARCHAR2
   ,p_To_curr_code                      IN  VARCHAR2
   ,p_To_Curr_Rate_Type                 IN  VARCHAR2
   ,p_To_Curr_Exchange_Rate             IN  NUMBER
   ,x_To_Curr_raw_cost                  OUT NOCOPY NUMBER
   ,x_To_Curr_raw_cost_rate             OUT NOCOPY NUMBER
   ,x_To_Curr_burden_cost               OUT NOCOPY NUMBER
   ,x_To_Curr_burden_cost_rate          OUT NOCOPY NUMBER
   ,x_To_Curr_Exchange_Rate             OUT NOCOPY NUMBER
   ,x_return_status                     OUT NOCOPY VARCHAR2
   ,x_error_msg_code                    OUT NOCOPY VARCHAR2
   ) IS

   l_denominator        Number;
   l_numerator          Number ;
   l_rate               Number ;
   l_calling_mode       Varchar2(100) := NVL(p_calling_mode,'PC');
   l_usrRateAllowed     Varchar2(100);
   INVALID_CURRENCY     Exception;
   NO_RATE              Exception;

BEGIN
	 -- Initialize the out variables
     x_return_status := 'S';
	 x_error_msg_code := NULL;

	 If p_From_curr_code = p_To_curr_code  Then
	 		x_To_Curr_raw_cost 		   := p_txn_raw_cost;
			x_To_Curr_burden_cost 		   := p_txn_burden_cost;
			x_To_Curr_Exchange_Rate 	   := p_To_Curr_Exchange_Rate ;
                        If NVL(p_txn_quantity,0) <> 0 Then
                           x_To_Curr_raw_cost_rate := x_To_Curr_raw_cost / p_txn_quantity ;
                           x_To_Curr_burden_cost_rate := x_To_Curr_burden_cost / p_txn_quantity ;
                        Else
                           x_To_Curr_raw_cost_rate      := x_To_Curr_raw_cost;
                           If NVL(p_txn_burden_cost,0) <> 0 Then
                                x_To_Curr_burden_cost_rate   := x_To_Curr_raw_cost_rate;
                           End If;
                        End If;
	 Else
	 	 If p_To_Curr_Rate_Type = 'User' Then
		 	-- check if the user rate type is allowed for this currency
			l_usrRateAllowed := pa_multi_currency.is_user_rate_type_allowed
				(P_from_currency    => p_From_curr_code
                                 ,P_to_currency     => p_To_curr_code
                                 ,P_conversion_date => p_Conversion_Date );
            		If NVL(l_usrRateAllowed,'N') = 'Y' Then
			   If p_To_Curr_Exchange_Rate is NOT NULL Then

			      x_To_Curr_raw_cost := pa_currency.round_trans_currency_amt1
						 (p_txn_raw_cost * NVL(p_To_Curr_Exchange_Rate,1),P_to_curr_code);
			      x_To_Curr_burden_cost := pa_currency.round_trans_currency_amt1
						(p_txn_burden_cost * NVL(p_To_Curr_Exchange_Rate,1),P_to_curr_code);
			      x_To_Curr_Exchange_Rate := p_To_Curr_Exchange_Rate ;

			      If NVL(p_txn_quantity,0) <> 0 Then
					x_To_Curr_raw_cost_rate := x_To_Curr_raw_cost / p_txn_quantity ;
					x_To_Curr_burden_cost_rate := x_To_Curr_burden_cost / p_txn_quantity ;
                              Else
                                        x_To_Curr_raw_cost_rate      := x_To_Curr_raw_cost;
					If NVL(p_txn_burden_cost,0) <> 0 Then
                                            x_To_Curr_burden_cost_rate   := x_To_Curr_raw_cost_rate;
					End If;
			      End If;


			   Else
			   	   x_return_status := 'E';
				   If l_calling_mode = 'PC' Then
				   	   x_error_msg_code := 'PA_FP_PJ_COST_RATE_NOT_DEFINED';
				   Else
				   	   x_error_msg_code := 'PA_FP_PF_COST_RATE_NOT_DEFINED';
				   End If;
			   End If;

			Else  -- user rate type is not allowed so error out
				x_return_status := 'E';
				If l_calling_mode = 'PC' Then
				   	   x_error_msg_code := 'PA_FP_PJC_USR_RATE_NOT_ALLOWED';
			    	Else
					   x_error_msg_code := 'PA_FP_PFC_USR_RATE_NOT_ALLOWED';
				End If;

			End If; -- End of userRateAllowed

		 ELse
		 	 -- Call GL conversion api to derive the exchagne rate
		    BEGIN
			  print_msg('Calling Gl_currency_api.get_triangulation_rate');
			  Gl_currency_api.get_triangulation_rate (
			 			   x_from_currency	=> p_From_curr_code
						  ,x_to_currency	=> p_To_Curr_code
						  ,x_conversion_date	=> p_Conversion_date
						  ,x_conversion_type	=> p_To_Curr_rate_Type
						  ,x_denominator	=> l_denominator
						  ,x_numerator		=> l_numerator
						  ,x_rate               => l_rate
							  	);
			      	  x_To_Curr_raw_cost := pa_currency.round_trans_currency_amt1
							(p_txn_raw_cost * NVL(l_rate,1),p_To_Curr_code);
			   	  x_To_Curr_burden_cost := pa_currency.round_trans_currency_amt1
							(p_txn_burden_cost * NVL(l_rate,1),p_To_Curr_code);
				  x_To_Curr_Exchange_Rate := l_rate ;

                              	  If NVL(p_txn_quantity,0) <> 0 Then
                                	x_To_Curr_raw_cost_rate := x_To_Curr_raw_cost / p_txn_quantity ;
                                	x_To_Curr_burden_cost_rate := x_To_Curr_burden_cost / p_txn_quantity ;
				  Else
					x_To_Curr_raw_cost_rate      := x_To_Curr_raw_cost;
					If NVL(p_txn_burden_cost,0) <> 0 Then
					   x_To_Curr_burden_cost_rate   := x_To_Curr_raw_cost_rate;
					End If;
                              	  End If;

			EXCEPTION
					 WHEN OTHERS then
					 	x_return_status := 'E';
						If ( l_denominator = -2 OR l_denominator = -2 ) Then
							x_error_msg_code := 'PA_FP_CURR_NOT_VALID';
						Else
							If l_calling_mode = 'PC' Then
                                                    		x_error_msg_code := 'PA_FP_NO_PJ_EXCH_RATE_EXISTS';
                                            		Else
                                                        	x_error_msg_code := 'PA_FP_NO_PF_EXCH_RATE_EXISTS';
                                                	End If;

						End If;
			END;

		 End If; -- end of User  Type

	 End If; -- End of From Curr <> To Curr

	 Return;

END Convert_amounts;



/* This API converts the cost amount from transaction currency to
 * project and project functional currency based on the
 * planning transaction currency conversion attributes
 * NOTE: Please donot use this API for actual cost conversion
 */
PROCEDURE Convert_COST_TO_PC_PFC
   (p_txn_raw_cost                      IN  NUMBER
   ,p_txn_burden_cost                   IN  NUMBER
   ,p_txn_quantity			IN  NUMBER
   ,p_txn_curr_code                     IN  VARCHAR2
   ,p_txn_date                          IN  DATE
   ,p_project_id                        IN  NUMBER
   ,p_budget_Version_id                 IN  NUMBER
   ,p_budget_Line_id                    IN  NUMBER
   ,x_project_curr_code                 OUT NOCOPY VARCHAR2
   ,x_projfunc_curr_code                OUT NOCOPY VARCHAR2
   ,x_proj_raw_cost                     OUT NOCOPY NUMBER
   ,x_proj_raw_cost_rate                OUT NOCOPY NUMBER
   ,x_proj_burdened_cost                OUT NOCOPY NUMBER
   ,x_proj_burdened_cost_rate           OUT NOCOPY NUMBER
   ,x_projfunc_raw_cost                 OUT NOCOPY NUMBER
   ,x_projfunc_raw_cost_rate            OUT NOCOPY NUMBER
   ,x_projfunc_burdened_cost            OUT NOCOPY NUMBER
   ,x_projfunc_burdened_cost_rate       OUT NOCOPY NUMBER
   ,x_return_status                     OUT NOCOPY VARCHAR2
   ,x_error_msg_code                    OUT NOCOPY VARCHAR2
   )  IS
	l_insufficient_parms                    EXCEPTION;
	l_No_budget_version			EXCEPTION;
	l_return_status      			VARCHAR2(100);
	l_error_msg_code     			VARCHAR2(100);
	l_stage              			VARCHAR2(1000);
	l_debug_flag         			VARCHAR2(10);
	l_txn_curr_code                     	VARCHAR2(100);
	l_project_id				NUMBER;
	l_budget_version_id 			NUMBER;
	l_resource_assignment_id                NUMBER;
	/* project attributes */
	l_project_curr_code  			VARCHAR2(100);
	l_project_rate_type                 	VARCHAR2(100);
	l_project_rate_date_type            	VARCHAR2(100);
	l_project_rate_date                 	DATE;
	l_project_exchange_rate             	NUMBER;
	/* project functional attributes */
    	l_projfunc_curr_code 			VARCHAR2(100);
	l_projfunc_rate_type                    VARCHAR2(100);
	l_projfunc_rate_date_type               VARCHAR2(100);
	l_projfunc_rate_date                    DATE;
	l_projfunc_exchange_rate                NUMBER;

    	l_proj_raw_cost      			NUMBER;
    	l_proj_raw_cost_rate      		NUMBER;
   	l_proj_burden_cost 			NUMBER;
   	l_proj_burden_cost_rate 		NUMBER;
	l_projfunc_raw_cost  			NUMBER;
	l_projfunc_raw_cost_rate  		NUMBER;
   	l_projfunc_burden_cost			NUMBER;
   	l_projfunc_burden_cost_rate		NUMBER;

  	CURSOR cur_currencyAttribs(lv_budget_version_id Number,lv_resource_assignment_id  Number) IS
  	SELECT  pp.project_id
		 ,bv.budget_version_id
		 ,cur.txn_currency_code                                                 txn_currency_code
		 /* budget line currency attributes selected for testing
		 --,bl.project_currency_code                                            bgl_project_curr_code
		 --,bl.projfunc_currency_code                                           bgl_projfunc_curr_code
		 --,bl.project_cost_rate_type                                           bgl_project_rate_type
 		 --,bl.project_cost_rate_date_type                                      bgl_project_rate_date_type
	     	 --,bl.start_date                                                       bgl_project_rate_date
		 --,bl.project_cost_exchange_rate                                       bgl_project_exchange_rate */
		 /* -----------Project Currency conversion Atrributes -----------------------------------------*/
		 ,NVL(bl.project_currency_code,pp.project_currency_code)                project_currency_code
		 ,NVL(bl.project_cost_rate_type,fpo.project_cost_rate_type)             project_rate_type
         	 ,decode(NVL(bl.project_cost_rate_date_type,fpo.project_cost_rate_date_type)
		           ,'User',NULL
		           ,NVL(bl.project_cost_rate_date_type,fpo.project_cost_rate_date_type))  project_rate_date_type
         	 ,decode(NVL(bl.project_cost_rate_date_type,fpo.project_cost_rate_date_type)
				    ,'START_DATE', NVL(bl.start_date,p_txn_date)
					,'END_DATE'  , NVL(bl.end_date,p_txn_date)
					, NVL(bl.project_cost_rate_date,Nvl(fpo.project_cost_rate_date,p_txn_date)))  project_rate_date
		 ,decode(bl.project_cost_exchange_rate,NULL
		 		   , decode(NVL(bl.project_cost_rate_type,fpo.project_cost_rate_type)
		           ,'User',cur.PROJECT_COST_EXCHANGE_RATE
		 		   , null ),bl.project_cost_exchange_rate)                        project_exchange_rate
         /* -------------project functinal currency conversion attributes -------------------------------*/
		 ,NVL(bl.projfunc_currency_code,pp.projfunc_currency_code)                ProjFunc_currency_code
		 ,NVL(bl.projfunc_cost_rate_type,fpo.projfunc_cost_rate_type)             projfunc_rate_type
         	 ,decode(NVL(bl.projfunc_cost_rate_date_type,fpo.projfunc_cost_rate_date_type)
		           ,'User',NULL
		           ,NVL(bl.projfunc_cost_rate_date_type,fpo.projfunc_cost_rate_date_type))  projfunc_rate_date_type
         	 ,decode(NVL(bl.projfunc_cost_rate_date_type,fpo.projfunc_cost_rate_date_type)
				    ,'START_DATE', NVL(bl.start_date, p_txn_date)
					,'END_DATE'  , NVL(bl.end_date ,p_txn_date)
					, NVL(bl.projfunc_cost_rate_date,Nvl(fpo.projfunc_cost_rate_date,p_txn_date)))  projfunc_rate_date
		 ,decode(bl.projfunc_cost_exchange_rate,NULL
		 		   , decode(NVL(bl.projfunc_cost_rate_type,fpo.projfunc_cost_rate_type)
		           ,'User',cur.PROJFUNC_COST_EXCHANGE_RATE
		 		   , null),bl.projfunc_cost_exchange_rate)                      projfunc_exchange_rate
    	from pa_budget_versions bv
        	,pa_proj_fp_options fpo
		,pa_projects_all pp
		,pa_fp_txn_currencies cur
		,pa_budget_lines bl
   	where bv.project_id = pp.project_id
	 and fpo.project_id = pp.project_id
	 and nvl(fpo.fin_plan_type_id,0) = nvl(bv.fin_plan_type_id,0)
     	 and fpo.fin_plan_version_id = bv.budget_version_id
	 and bv.budget_version_id = cur.fin_plan_version_id
	 and cur.txn_currency_code = p_txn_curr_code
	 and pp.project_id = p_project_id
	 and bv.budget_version_id = lv_budget_version_id
	 and bv.budget_version_id = bl.budget_version_id (+)
	 and ( (nvl(bl.resource_assignment_id,lv_resource_assignment_id)  = lv_resource_assignment_id
	        and trunc(p_txn_date) between trunc(bl.start_date) and nvl(bl.end_date,p_txn_date)
		and bl.txn_currency_code = p_txn_curr_code
		    ) OR
		   (NOT EXISTS
		    (select null from pa_budget_lines bl1
			 where bl1.budget_version_id = bv.budget_version_id
			 and   bl1.resource_assignment_id = lv_resource_assignment_id
			 and   trunc(p_txn_date) between trunc(bl1.start_date) and nvl(bl1.end_date,p_txn_date)
			 and bl.txn_currency_code = p_txn_curr_code
			))
		 )
     	order by bv.budget_version_id ;


BEGIN
        --- Initialize the error statck
	If g_debug_flag is NULL Then
                fnd_profile.get('PA_DEBUG_MODE',g_debug_flag);
                g_debug_flag := NVL(g_debug_flag, 'N');
        End If;
	l_debug_flag := NVL(g_debug_flag,'N');
	If l_debug_flag = 'Y' Then
        	PA_DEBUG.init_err_stack ('PA_COST1.Convert_COST_TO_PC_PFC');
        	PA_DEBUG.SET_PROCESS( x_process => 'PLSQL'
                      ,x_write_file     => 'LOG'
                      ,x_debug_mode      => l_debug_flag
                          );
	End If;

        l_return_status := 'S';
        l_error_msg_code := NULL;
	l_budget_version_id := p_budget_version_id;
        x_return_status := 'S';
        x_error_msg_code := NULL;

	l_stage := 'Inside Convert_TxnTo_PV_PFC api:TxnCost['||p_txn_raw_cost||']TxnBdCost['||p_txn_burden_cost||
   		   ']TxnCurr['||p_txn_curr_code||']TxnDate['||p_txn_date||']ProjId['||p_project_id||']BdgtLine['||p_budget_Line_id||
   	           ']BudgetVersion['||l_budget_version_id||']Quantity['||p_txn_quantity||']';
	print_msg(l_debug_flag,l_stage);

	/* Validate In Params */
	IF (( p_project_id is NULL or p_txn_curr_code is NULL or p_txn_date is NULL )
              or (p_budget_Line_id is NULL AND p_budget_version_id is NULL )
	   ) Then
		Raise l_insufficient_parms;
	End If;

	/* Get the Budget Version Id for the given Budget Line */
	Begin
	    If l_budget_version_id is NULL Then
		l_stage := 'Executing sql to get Budget Version';
		SELECT bl.budget_version_id
		      ,bl.resource_assignment_id
		INTO  l_budget_version_id
		      ,l_resource_assignment_id
		FROM pa_budget_lines bl
		WHERE bl.budget_line_id = p_budget_line_id;
	    End If;
	Exception
		When No_data_found Then
			l_stage := 'No Budget Version Found for the given Budget Line['||p_budget_line_id||']' ;
			Raise l_No_budget_version;
	End;

	IF ( NVL(p_txn_raw_cost,0) <> 0 OR NVL(p_txn_burden_cost,0) <> 0 ) Then
		l_stage := 'Opening Currency Attributes Cursor with BudgtVer['||l_budget_version_id||
			   ']ResAssn['||l_resource_assignment_id||']';
		OPEN cur_currencyAttribs(l_budget_version_id,l_resource_assignment_id);
		FETCH cur_currencyAttribs INTO
		      	l_project_id
		     	,l_budget_version_id
		     	,l_txn_curr_code
		 	/* project attributes */
			 ,l_project_curr_code
			 ,l_project_rate_type
			 ,l_project_rate_date_type
			 ,l_project_rate_date
			 ,l_project_exchange_rate
			 /* project functional attributes */
    		 	,l_projfunc_curr_code
			 ,l_projfunc_rate_type
			 ,l_projfunc_rate_date_type
			 ,l_projfunc_rate_date
			 ,l_projfunc_exchange_rate ;
		IF  cur_currencyAttribs%FOUND Then
			l_stage := 'CurrAttributes:ProjCur['||l_project_curr_code||']ProjRateType['||l_project_rate_type||
				']RateDate['||l_project_rate_date||']ProjXchange['||l_project_exchange_rate||
				']ProjFuncCur['||l_projfunc_curr_code||']PFCRateType['||l_projfunc_rate_type||
				']PFCRateDate['||l_projfunc_rate_date||']PFCXchnge['||l_projfunc_exchange_rate||']' ;
			print_msg(l_debug_flag,l_stage);

		    -- Call the conversion api for PC Amounts
			l_stage := 'Calling Convert_amounts for PC';
			Convert_amounts
   			(p_calling_mode              => 'PC'
			,p_txn_raw_cost              => p_txn_raw_cost
   			,p_txn_burden_cost           => p_txn_burden_cost
			,p_txn_quantity              => p_txn_quantity
   			,p_From_curr_code            => p_txn_curr_code
			,p_To_curr_code              => l_project_curr_code
   			,p_To_Curr_Rate_Type         => l_project_rate_type
   			,p_Conversion_Date           => l_project_rate_date
   			,p_To_Curr_Exchange_Rate     => l_project_exchange_rate
   			,x_To_Curr_raw_cost          => l_proj_raw_cost
   			,x_To_Curr_raw_cost_rate     => l_proj_raw_cost_rate
   			,x_To_Curr_burden_cost       => l_proj_burden_cost
   			,x_To_Curr_burden_cost_rate  => l_proj_burden_cost_rate
   			,x_To_Curr_Exchange_Rate     => l_project_exchange_rate
   			,x_return_status             => l_return_status
   			,x_error_msg_code            => l_error_msg_code
   			);

			If l_return_status = 'S' Then
			   l_stage := 'Calling Convert_amounts for PFC';
			   -- Call the conversion api for PFC amounts
			   Convert_amounts
   			   (p_calling_mode              => 'PFC'
			   ,p_txn_raw_cost              => p_txn_raw_cost
   			   ,p_txn_burden_cost           => p_txn_burden_cost
                           ,p_txn_quantity              => p_txn_quantity
   			   ,p_From_curr_code            => p_txn_curr_code
			   ,p_To_curr_code              => l_projfunc_curr_code
   			   ,p_To_Curr_Rate_Type         => l_projfunc_rate_type
   			   ,p_Conversion_Date           => l_projfunc_rate_date
   			   ,p_To_Curr_Exchange_Rate     => l_projfunc_exchange_rate
   			   ,x_To_Curr_raw_cost          => l_projfunc_raw_cost
			   ,x_To_Curr_raw_cost_rate     => l_projfunc_raw_cost_rate
   			   ,x_To_Curr_burden_cost       => l_projfunc_burden_cost
   			   ,x_To_Curr_burden_cost_rate  => l_projfunc_burden_cost_rate
   			   ,x_To_Curr_Exchange_Rate     => l_projfunc_exchange_rate
   			   ,x_return_status             => l_return_status
   			   ,x_error_msg_code            => l_error_msg_code
   			   );

			End If;

		Else
		    print_msg(l_debug_flag,'Cursor / No Data Found for the Given params');
		END IF;
		CLOSE cur_currencyAttribs;

	    End If;


		-- Assign out variables
		x_return_status 	   := l_return_status;
		x_error_msg_code 	   := l_error_msg_code ;
        	x_project_curr_code        := l_project_curr_code;
        	x_projfunc_curr_code       := l_projfunc_curr_code;
        	x_proj_raw_cost            := l_proj_raw_cost;
        	x_proj_raw_cost_rate       := l_proj_raw_cost_rate;
   		x_proj_burdened_cost       := l_proj_burden_cost;
   		x_proj_burdened_cost_rate  := l_proj_burden_cost_rate;
		x_projfunc_raw_cost        := l_projfunc_raw_cost;
		x_projfunc_raw_cost_rate   := l_projfunc_raw_cost_rate;
   		x_projfunc_burdened_cost   := l_projfunc_burden_cost;
   		x_projfunc_burdened_cost_rate   := l_projfunc_burden_cost_rate;

		l_stage := 'End of ConvertAmts: RetSts['||x_return_status||']Errmsg['||x_error_msg_code||
			']ProjCur['||x_project_curr_code||']ProjFunc['||x_projfunc_curr_code||']ProjRaw['||x_proj_raw_cost||
			']ProjBd['||x_proj_burdened_cost||']PFCRaw['||x_projfunc_raw_cost||']PFCBd['||x_projfunc_burdened_cost||
			']ProjRawRate['||x_proj_raw_cost_rate||']' ;

		print_msg(l_debug_flag,l_stage);


	-- Reset Err Stack
	If l_debug_flag = 'Y' Then
        	PA_DEBUG.reset_err_stack;
	End If;
EXCEPTION
        WHEN l_insufficient_parms  THEN
                x_error_msg_code := 'PA_NO_BUDGET_VERSION';
                x_return_status := 'E';
                print_msg(l_debug_flag,l_stage);
		If l_debug_flag = 'Y' Then
                PA_DEBUG.write_file('LOG',l_stage);
                PA_DEBUG.write_file('LOG','ReturnStatus['||l_return_status||']errCode['||l_error_msg_code||']' );
                PA_DEBUG.reset_err_stack;
		End If;

        WHEN l_no_budget_version THEN
                x_error_msg_code := 'PA_INV_PARAM_PASSED';
                x_return_status := 'E';
                print_msg(l_debug_flag,l_stage);
		If l_debug_flag = 'Y' Then
                PA_DEBUG.write_file('LOG',l_stage);
                PA_DEBUG.write_file('LOG','ReturnStatus['||l_return_status||']errCode['||l_error_msg_code||']' );
                PA_DEBUG.reset_err_stack;
		End If;

        WHEN OTHERS THEN
                x_return_status := 'U';
                x_error_msg_code := SQLERRM||SQLCODE;
		print_msg(l_debug_flag,l_stage||x_error_msg_code);
		If l_debug_flag = 'Y' Then
                PA_DEBUG.write_file('LOG','ReturnSts['||l_return_status ||']ErrCode['||l_error_msg_code||']' );
                PA_DEBUG.write_file('LOG',l_stage);
                PA_DEBUG.reset_err_stack;
		End If;

END Convert_COST_TO_PC_PFC;

END PA_COST1;

/
