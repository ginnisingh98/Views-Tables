--------------------------------------------------------
--  DDL for Package Body PA_FP_PJI_INTG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_PJI_INTG_PKG" AS
--$Header: PAFPUT4B.pls 120.4 2007/02/06 10:14:23 dthakker noship $

/* Declare global variables*/
	g_debug_flag  Varchar2(10) ;

/**
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
**/
PROCEDURE PRINT_MSG(p_msg  varchar2
		   ,p_debug_flag  varchar2 default NULL) IS

BEGIN
--calc_log(p_msg);
        If (NVL(p_debug_flag,'N') = 'Y' OR g_debug_flag = 'Y') Then
		pa_debug.g_err_stage := substr('LOG:'||p_msg,1,240);
		 PA_DEBUG.write
                (x_Module       => 'PA_FP_PJI_INTG_PKG'
                ,x_Msg          => pa_debug.g_err_stage
                ,x_Log_Level    => 3);
        End If;
END;

/* This is the main api called from calculate, budget generation process to update the
 * reporting PJI data when budget lines are created,updated or deleted.
 * The following params values must be passed
 * p_activity_code             'UPDATE',/'DELETE'
 * p_calling_module            name of API, for calculate 'CALCULATE_API'
 * p_start_date                BudgetLine StartDate
 * p_end_date                  BudgetLine Enddate
 * If activity = 'UPDATE' then all the amounts and currency columns must be passed
 * if activity = 'DELETE' then -ve budgetLine amounts will be selected from DB and passed in params will be ignored
 * NOTE: BEFORE CALLING THIS API, a record must exists in pa_resource_assignments for the p_resource_assignment_id
 *       AND CALL THIS API ONLY IF THERE ARE NO REJECTION CODES STAMPED ON THE BUDGET LINES
 * NOTE: As of IPM, we ignore rejection codes stamped on budget lines for the purpose of updating PJI data.
 */
PROCEDURE update_reporting_lines
                (p_calling_module               IN      Varchar2 Default 'CALCULATE_API'
                ,p_activity_code                IN      Varchar2 Default 'UPDATE'
                ,p_budget_version_id            IN      Number
                ,p_budget_line_id               IN      Number
                ,p_resource_assignment_id       IN      Number
                ,p_start_date                   IN      Date
                ,p_end_date                     IN      Date
                ,p_period_name                  IN      Varchar2
                ,p_txn_currency_code            IN      Varchar2
                ,p_quantity                     IN      Number
                ,p_txn_raw_cost                 IN      Number
                ,p_txn_burdened_cost            IN      Number
                ,p_txn_revenue                  IN      Number
                ,p_project_currency_code        IN      Varchar2
                ,p_project_raw_cost             IN      Number
                ,p_project_burdened_cost        IN      Number
                ,p_project_revenue              IN      Number
                ,p_projfunc_currency_code       IN      Varchar2
                ,p_projfunc_raw_cost            IN      Number
                ,p_projfunc_burdened_cost       IN      Number
                ,p_projfunc_revenue             IN      Number
                ,x_msg_data                     OUT NOCOPY Varchar2
                ,x_msg_count                    OUT NOCOPY Number
                ,x_return_status                OUT NOCOPY Varchar2
                ) IS

	l_msg_count		Number := 0;
	l_msg_data		Varchar2(1000) := Null;
	l_return_status 	Varchar2(10);
	l_debug_flag		Varchar2(10);
	l_project_structure_id  Number;
	PJI_EXCEPTION           EXCEPTION;

	CURSOR strVer IS
        SELECT DECODE(nvl(pbv.wp_version_flag,'N'),'Y',pbv.project_structure_version_id,
                       PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(pbv.project_id)) project_structure_version_id
        FROM pa_budget_versions pbv
        WHERE pbv.budget_version_id = p_budget_version_id;

	CURSOR cur_pjiDetails IS
        SELECT  pbv.budget_version_id
	        ,ppa.org_id
                ,ppfo.rbs_version_id
                ,pbv.fin_plan_type_id
                /* Bug fix :3839761 ,nvl(pbv.project_structure_version_id,
                      --PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(pbv.project_id)) project_structure_version_id
		*/
                ,pbv.wp_version_flag
                ,decode(pbv.version_type, 'COST',ppfo.cost_time_phased_code,
                        	'REVENUE',ppfo.revenue_time_phased_code,
                         		ppfo.all_time_phased_code) time_phase_code
		,ra.project_id
		,ra.task_id
		,ra.rbs_element_id
		,ra.resource_class_code
		,ra.rate_based_flag
        FROM pa_projects_all        ppa
              	,pa_budget_versions     pbv
              	,pa_proj_fp_options     ppfo
		,pa_resource_assignments ra
        WHERE ppa.project_id        = pbv.project_id
        AND pbv.budget_version_id = ppfo.fin_plan_version_id
        AND pbv.budget_version_id = p_budget_version_id
	AND ra.resource_assignment_id = p_resource_assignment_id
	AND ra.budget_version_id = pbv.budget_version_id;

	pji_rec		cur_pjiDetails%ROWTYPE;
	l_pji_call_flag 	Varchar2(10);
	l_start_date		Date;
        l_end_date		Date;
        l_period_name		Varchar2(100);
        l_txn_currency_code	Varchar2(100);
        l_txn_raw_cost		Number;
        l_txn_burdened_cost	Number;
        l_txn_revenue		Number;
        l_project_currency_code Varchar2(100);
        l_project_raw_cost	Number;
        l_project_burdened_cost Number;
        l_project_revenue	Number;
        l_projfunc_currency_code Varchar2(100);
        l_projfunc_raw_cost	Number;
        l_projfunc_burdened_cost Number;
        l_projfunc_revenue	Number;
        l_quantity		Number;
        l_budget_line_id	Number;
	l_num_rows_inserted     Number;
	INVALID_PARAMS          EXCEPTION;
	l_stage                 Varchar2(100);


BEGIN
	l_return_status := 'S';
	x_return_status := 'S';
	x_msg_count := 0;
	x_msg_data  := Null;

	l_stage := 10;
	/* Initialize the error stack */
        l_debug_flag := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
	g_debug_flag := l_debug_flag;
	If g_debug_flag = 'Y' Then
		pa_debug.init_err_stack('PA_FP_PJI_INTG_PKG.update_reporting_lines');
        	PA_DEBUG.SET_PROCESS( x_process => 'PLSQL'
                      ,x_write_file     => 'LOG'
                      ,x_debug_mode      => l_debug_flag
                          );
	End If;
	print_msg('Inside Update reporting Lines api');
	/* assign the IN params to local variables*/
        l_budget_line_id	:= p_budget_line_id;
	l_start_date		:= p_start_date;
        l_end_date		:= p_end_date;
        l_period_name		:= p_period_name;
        l_txn_currency_code	:= p_txn_currency_code;
        l_txn_raw_cost		:= p_txn_raw_cost;
        l_txn_burdened_cost	:= p_txn_burdened_cost ;
        l_txn_revenue		:= p_txn_revenue;
        l_project_currency_code := p_project_currency_code ;
        l_project_raw_cost	:= p_project_raw_cost;
        l_project_burdened_cost	:= p_project_burdened_cost;
        l_project_revenue	:= p_project_revenue;
        l_projfunc_currency_code := p_projfunc_currency_code;
        l_projfunc_raw_cost	:= p_projfunc_raw_cost;
        l_projfunc_burdened_cost := p_projfunc_burdened_cost;
        l_projfunc_revenue	:= p_projfunc_revenue;
        l_quantity		:= p_quantity;

	IF p_activity_code = 'DELETE' AND p_budget_line_id is NULL Then
		l_stage := 20;
		raise invalid_params;
	End IF;
        /* bug fix: 3839761 */
        IF p_budget_version_id is NOT NULL Then
		l_project_structure_id := NULL;
                OPEN strVer;
                FETCH strVer INTO l_project_structure_id;
                CLOSE strVer;
        End If;

	If p_activity_code in ('UPDATE','DELETE') Then
		l_stage := 30;

		If p_budget_version_id is NOT NULL and p_resource_assignment_id is NOT NULL Then
			l_pji_call_flag := 'Y';
			pji_rec := NULL;
			OPEN cur_pjiDetails;
			FETCH cur_pjiDetails INTO pji_rec;
			IF cur_pjiDetails%NOTFOUND Then
				l_pji_call_flag := 'N';
			End If;
			CLOSE cur_pjiDetails;
		        l_stage := 40;
			print_msg('l_pji_call_flag['||l_pji_call_flag||']');
			IF l_pji_call_flag = 'Y' Then  --{

				IF (p_calling_module = 'BUDGET_LINE'  AND p_budget_line_id is NOT NULL) Then
				  BEGIN
					l_stage := 50;
                                        -- IPM: Removed check for budget line rejection codes.
					SELECT bl.start_date
                                        ,bl.end_date
                                        ,bl.period_name
                                        ,bl.txn_currency_code
                                        ,decode(p_activity_code,'DELETE',bl.txn_raw_cost * -1,bl.txn_raw_cost)
                                        ,decode(p_activity_code,'DELETE',bl.txn_burdened_cost *-1 , bl.txn_burdened_cost)
                                        ,decode(p_activity_code,'DELETE',bl.txn_revenue * -1 ,bl.txn_revenue)
                                        ,bl.project_currency_code
                                        ,decode(p_activity_code,'DELETE',bl.project_raw_cost * -1 ,bl.project_raw_cost)
                                        ,decode(p_activity_code,'DELETE',bl.project_burdened_cost * -1 ,bl.project_burdened_cost)
                                        ,decode(p_activity_code,'DELETE',bl.project_revenue * -1 ,bl.project_revenue)
                                        ,bl.projfunc_currency_code
                                        ,decode(p_activity_code,'DELETE',bl.raw_cost * -1 ,bl.raw_cost)
                                        ,decode(p_activity_code,'DELETE',bl.burdened_cost * -1 ,bl.burdened_cost)
                                        ,decode(p_activity_code,'DELETE',bl.revenue * -1 ,bl.revenue)
                                        ,decode(p_activity_code,'DELETE',bl.quantity * -1 ,bl.quantity)
					INTO
					l_start_date
        				,l_end_date
        				,l_period_name
        				,l_txn_currency_code
        				,l_txn_raw_cost
        				,l_txn_burdened_cost
        				,l_txn_revenue
        				,l_project_currency_code
        				,l_project_raw_cost
        				,l_project_burdened_cost
        				,l_project_revenue
        				,l_projfunc_currency_code
        				,l_projfunc_raw_cost
        				,l_projfunc_burdened_cost
        				,l_projfunc_revenue
        				,l_quantity
					FROM pa_budget_lines bl
					WHERE bl.budget_line_id = p_budget_line_id;
					l_stage := 50;
				  EXCEPTION
					WHEN NO_DATA_FOUND Then
						-- set the following columns to null so that calling pji api is bypassed
						l_stage := 60;
						l_quantity :=  NULL;
                                    		l_txn_raw_cost := NULL;
                                    		l_txn_burdened_cost := NULL;
                                    		l_txn_revenue := NULL;
				  END ;


				END IF;
                        print_msg('Calling PJI_FM_XBS_ACCUM_MAINT.plan_update api bdgtLineId['||l_budget_line_id||']');
                print_msg('AmtPassing to planUpdateAPI l_txn_currency_code['||l_txn_currency_code||']TxnRaw['||l_txn_raw_cost||']');
                print_msg('txnBd['||l_txn_burdened_cost||']TxnRev['||l_txn_revenue||']PrjCur['||l_project_currency_code||']');
                print_msg('prjRaw['||l_project_raw_cost||']prjBd['||l_project_burdened_cost||']prjrev['||l_project_revenue||']');
                print_msg('pfcur['||l_projfunc_currency_code||']pfcraw['||l_projfunc_raw_cost||']pfcBd['||l_projfunc_burdened_cost||']');
                print_msg('pfc_rev['||l_projfunc_revenue||']QTY['||l_quantity||']RbsElemt['||pji_rec.rbs_element_id||']');

				IF (l_quantity is NULL
				    and l_txn_raw_cost is NULL
				    and l_txn_burdened_cost is NULL
				    and l_txn_revenue is NULL ) THEN

					print_msg('This is newly created budgetline with NULL amts and qty from spread api no need to call pji');
					l_stage := 70;
					l_num_rows_inserted := 0;
					NUll;
				ELSE
                        	    print_msg('Calling PJI_FM_XBS_ACCUM_MAINT.plan_update api bdgtLineId['||l_budget_line_id||']');
				    /* clean up the tmp table before inserting*/
				    l_num_rows_inserted := 0;
				    /* since this is not a tmp table, deleteing will delete all the
				     * pending transactions inserted from other sessions
				     * so commenting out the code
				     * Bug fix:3803569 --DELETE FROM PJI_FM_EXTR_PLAN_LINES;
				     */

					l_stage := 80;
           			    INSERT INTO PJI_FM_EXTR_PLAN_LINES
					( PROJECT_ID
                   			,PROJECT_ORG_ID
                   			,PROJECT_ELEMENT_ID
                   			,STRUCT_VER_ID
                   			,CALENDAR_TYPE
                   			,RBS_ELEMENT_ID
                   			,RBS_VERSION_ID
                   			,PLAN_VERSION_ID
                   			,PLAN_TYPE_ID
                   			,WP_VERSION_FLAG
                   			,RESOURCE_CLASS_CODE
                   			,RATE_BASED_FLAG
                   			,ROLLUP_TYPE
                   			,START_DATE
                   			,END_DATE
                   			,PERIOD_NAME
                   			,TXN_CURRENCY_CODE
                   			,TXN_RAW_COST
                   			,TXN_BURDENED_COST
                   			,TXN_REVENUE
                   			,PRJ_CURRENCY_CODE
                   			,PRJ_RAW_COST
                   			,PRJ_BURDENED_COST
                   			,PRJ_REVENUE
                   			,PFC_CURRENCY_CODE
                   			,PFC_RAW_COST
                   			,PFC_BURDENED_COST
                   			,PFC_REVENUE
                   			,QUANTITY
                   			)
           			   VALUES (
                   			pji_rec.project_id
                   			,pji_rec.org_id
                   			,pji_rec.task_id
                   			,l_project_structure_id  --pji_rec.project_structure_version_id
                   			,pji_rec.time_phase_code
                   			,pji_rec.rbs_element_id
                   			,pji_rec.rbs_version_id
                   			,pji_rec.budget_version_id
                   			,pji_rec.fin_plan_type_id
                   			,pji_rec.wp_version_flag
                   			,pji_rec.resource_class_code
                   			,pji_rec.rate_based_flag
                   			,'W'
					,l_start_date
					,l_end_date
                   			,l_period_name
                   			,l_txn_currency_code
                   			,l_txn_raw_cost
                   			,l_txn_burdened_cost
                   			,l_txn_revenue
                   			,l_project_currency_code
                   			,l_project_raw_cost
                   			,l_project_burdened_cost
                   			,l_project_revenue
                   			,l_projfunc_currency_code
                   			,l_projfunc_raw_cost
                   			,l_projfunc_burdened_cost
                   			,l_projfunc_revenue
                   			,l_quantity
          				);
					l_num_rows_inserted := sql%rowcount;

					l_stage := 90;
				END IF;

				If l_num_rows_inserted > 0 Then
				     l_stage := 100;
				     /* added this as per PJIs request ( virangan) */
				     IF p_budget_version_id IS NOT NULL THEN
             			   	PJI_FM_XBS_ACCUM_MAINT.plan_update
					(p_plan_version_id => p_budget_version_id
					, x_msg_code => l_msg_data
        				,x_return_status  => l_return_status
             				);
				     ELSE
					PJI_FM_XBS_ACCUM_MAINT.plan_update
                                        ( x_msg_code => l_msg_data
                                        ,x_return_status  => l_return_status
                                        );
				     END IF;
					l_stage := 110;
					Print_msg('End of PJI_FM_XBS_ACCUM_MAINT.plan_update retSts['||l_return_status||']msgdata['||l_msg_data||']');
					If l_return_status <> 'S' Then
						l_stage := 120;
						x_msg_data := l_msg_data;
						Raise pji_exception;
					End If;
				End If;
			End If; --} end of l_pji_call_flag
		End If;
	End If; -- end of p_activity
	l_stage := 200;
	x_return_status := l_return_status;
	print_msg('End of updateReportingLines api retSts['||x_return_status||']');
	--reset the error stack;
	If g_debug_flag = 'Y' Then
		pa_debug.reset_err_stack;
	End If;

EXCEPTION
	WHEN INVALID_PARAMS THEN
		x_return_status := 'E';
		x_msg_count  := 1;
		x_msg_data := 'PA_FP_INVALID_PARAMS';
		print_msg(l_stage||x_msg_data,'Y');
	WHEN PJI_EXCEPTION THEN
		x_return_status := 'U';
		x_msg_count  := 1;
		fnd_msg_pub.add_exc_msg
                ( p_pkg_name       => 'PA_FP_PJI_INTG_PKG'
                ,p_procedure_name => 'update_reporting_lines:Error Occured in plan_update' );
                print_msg(l_stage||'Error occured in update_reporting_lines:Error Occured in plan_update ['||x_msg_data||']','Y');
		If g_debug_flag = 'Y' Then
                	pa_debug.reset_err_stack;
		End If;
                RAISE;

	WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                x_msg_data := SQLCODE||SQLERRM;
		x_msg_count  := 1;
                fnd_msg_pub.add_exc_msg
                ( p_pkg_name       => 'PA_FP_PJI_INTG_PKG'
                ,p_procedure_name => 'update_reporting_lines' );
                print_msg(l_stage||'Error occured in update_reporting_lines['|| substr(SQLERRM,1,240),'Y');
		If g_debug_flag = 'Y' Then
                	pa_debug.reset_err_stack;
		End If;
                RAISE;

END update_reporting_lines;

/* This is an wrapper api, which in turn calls update_reporting_lines and passes
 * each budget line to reporting api
 *This is the main api called from calculate, budget generation process to update the
 * reporting PJI data when budget lines are created,updated or deleted.
 * The following params values must be passed
 * p_activity_code             'UPDATE',/'DELETE'
 * p_calling_module            name of API, for ex: 'CALCULATE_API'
 * If activity = 'UPDATE' then +ve budgetLine amounts will be selected from DB
 * if activity = 'DELETE' then -ve budgetLine amounts will be selected from DB
 * NOTE: BEFORE CALLING THIS API, a record must exists in pa_resource_assignments for the p_resource_assignment_id
 *       AND a budget line must exists for the given p_budget_line_id
 */
PROCEDURE update_reporting_lines_frombl
                (p_calling_module               IN      Varchar2 Default 'CALCULATE_API'
                ,p_activity_code                IN      Varchar2 Default 'UPDATE'
                ,p_budget_version_id            IN      Number
                ,p_resource_assignment_id       IN      Number
                ,p_budget_line_id               IN      Number
                ,x_msg_data                     OUT NOCOPY Varchar2
                ,x_msg_count                    OUT NOCOPY Number
                ,x_return_status                OUT NOCOPY Varchar2
                ) IS

        INVALID_PARAMS          EXCEPTION;
	l_debug_flag            Varchar2(10);
	l_return_status         Varchar2(10);
	l_stage                 varchar2(100);
BEGIN
        l_return_status := 'S';
        x_return_status := 'S';
        x_msg_count := 0;
        x_msg_data  := Null;

        /* Initialize the error stack */
	l_stage := 10;
        l_debug_flag := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
        g_debug_flag := l_debug_flag;
	If g_debug_flag = 'Y' Then
        	pa_debug.init_err_stack('PA_FP_PJI_INTG_PKG.update_reporting_lines_frombl');
        	PA_DEBUG.SET_PROCESS( x_process => 'PLSQL'
                      ,x_write_file     => 'LOG'
                      ,x_debug_mode      => l_debug_flag
                          );
	End If;
	print_msg('Entered update_reporting_lines_frombl module['||p_calling_module||']Activity['||p_activity_code||']bdgtver['||p_budget_version_id||']');
	print_msg('bdgtLineId['||p_budget_line_id||']ResAssId['||p_resource_assignment_id||']');

	If p_budget_line_id is NULL OR p_resource_assignment_id is NULL OR
	   p_activity_code NOT IN ('UPDATE','DELETE') Then
		l_stage := 20;
                print_msg('Invalid params passed to update_reporting_lines_frombl');
                raise invalid_params;
	End If;

	IF p_budget_line_id is NOT NULL AND p_resource_assignment_id is NOT NULL Then

		l_stage := 30;
		update_reporting_lines
                (p_calling_module               => 'BUDGET_LINE'
                ,p_activity_code                => p_activity_code
                ,p_budget_version_id            => p_budget_version_id
                ,p_budget_line_id               => p_budget_line_id
                ,p_resource_assignment_id       => p_resource_assignment_id
                ,p_start_date                   => null
                ,p_end_date                     => null
                ,p_period_name                  => null
                ,p_txn_currency_code            => null
                ,p_quantity                     => null
                ,p_txn_raw_cost                 => null
                ,p_txn_burdened_cost            => null
                ,p_txn_revenue                  => null
                ,p_project_currency_code        => null
                ,p_project_raw_cost             => null
                ,p_project_burdened_cost        => null
                ,p_project_revenue              => null
                ,p_projfunc_currency_code       => null
                ,p_projfunc_raw_cost            => null
                ,p_projfunc_burdened_cost       => null
                ,p_projfunc_revenue             => null
                ,x_msg_data                     => x_msg_data
                ,x_msg_count                    => x_msg_count
                ,x_return_status                => x_return_status
                ) ;
		l_stage := 40;
        End IF;

        x_return_status := l_return_status;
        print_msg('End of updateReportingLines_frombl api retSts['||x_return_status||']');
        --reset the error stack;
	If g_debug_flag = 'Y' Then
        	pa_debug.reset_err_stack;
	End If;
EXCEPTION
        WHEN INVALID_PARAMS THEN
                x_return_status := 'E';
                x_msg_count  := 1;
                x_msg_data := 'Invalid params passed to update_reporting_lines_frombl';
		print_msg(l_stage||x_msg_data,'Y');
        WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                x_msg_data := SQLCODE||SQLERRM;
                x_msg_count  := 1;
                fnd_msg_pub.add_exc_msg
                ( p_pkg_name       => 'PA_FP_PJI_INTG_PKG'
                ,p_procedure_name => 'update_reporting_lines_from_bl' );
                print_msg(l_stage||'Error occured in update_reporting_lines_frombl['|| substr(SQLERRM,1,240),'Y');
		If g_debug_flag = 'Y' Then
                	pa_debug.reset_err_stack;
		End If;
                RAISE;
END update_reporting_lines_frombl;

/* This is the main api called from calculate, budget generation process to update the
 * reporting PJI data when budget lines are created,updated or deleted.
 * The following params values must be passed
 * p_activity_code             'UPDATE',/'DELETE'
 * p_calling_module            name of API, for calculate 'CALCULATE_API'
 * p_start_date                BudgetLine StartDate
 * p_end_date                  BudgetLine Enddate
 * If activity = 'UPDATE' then all the amounts and currency columns must be passed
 * if activity = 'DELETE' then -ve budgetLine amounts will be selected from DB and passed in params will be ignored
 * NOTE: BEFORE CALLING THIS API, a record must exists in pa_resource_assignments for the p_resource_assignment_id
 *       AND CALL THIS API ONLY IF THERE ARE NO REJECTION CODES STAMPED ON THE BUDGET LINES
 * NOTE: As of IPM, we ignore rejection codes stamped on budget lines for the purpose of updating PJI data.
 * THIS API IS CREATED FOR BULK PROCESS OF DATA.
 * NOTE: ALL PARAMS MUST BE PASSED , passing Null or incomplete params will error out
 * the calling API must initialize all params and pass it
 */
PROCEDURE blk_update_reporting_lines
        (p_calling_module                IN Varchar2 Default 'CALCULATE_API'
        ,p_activity_code                 IN Varchar2 Default 'UPDATE'
        ,p_budget_version_id             IN Number
        ,p_rep_budget_line_id_tab        IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
        ,p_rep_res_assignment_id_tab     IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
        ,p_rep_start_date_tab            IN SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type()
        ,p_rep_end_date_tab              IN SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type()
        ,p_rep_period_name_tab           IN SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type()
        ,p_rep_txn_curr_code_tab         IN SYSTEM.pa_varchar2_15_tbl_type := SYSTEM.pa_varchar2_15_tbl_type()
        ,p_rep_quantity_tab              IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
        ,p_rep_txn_raw_cost_tab          IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
        ,p_rep_txn_burdened_cost_tab     IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
        ,p_rep_txn_revenue_tab           IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
        ,p_rep_project_curr_code_tab     IN SYSTEM.pa_varchar2_15_tbl_type := SYSTEM.pa_varchar2_15_tbl_type()
        ,p_rep_project_raw_cost_tab      IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
        ,p_rep_project_burden_cost_tab   IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
        ,p_rep_project_revenue_tab       IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
        ,p_rep_projfunc_curr_code_tab    IN SYSTEM.pa_varchar2_15_tbl_type := SYSTEM.pa_varchar2_15_tbl_type()
        ,p_rep_projfunc_raw_cost_tab     IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
        ,p_rep_projfunc_burden_cost_tab  IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
        ,p_rep_projfunc_revenue_tab      IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
        /*
         * The following _act_ parameters contain actual amounts.
         */
        ,p_rep_act_quantity_tab          IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
        ,p_rep_txn_act_raw_cost_tab      IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
        ,p_rep_txn_act_burd_cost_tab     IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
        ,p_rep_txn_act_rev_tab           IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
        ,p_rep_prj_act_raw_cost_tab      IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
        ,p_rep_prj_act_burd_cost_tab     IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
        ,p_rep_prj_act_rev_tab           IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
        ,p_rep_pf_act_raw_cost_tab       IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
        ,p_rep_pf_act_burd_cost_tab      IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
        ,p_rep_pf_act_rev_tab            IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
	/* bug fix:5116157 */
        ,p_rep_line_mode_tab          IN SYSTEM.pa_varchar2_15_tbl_type := SYSTEM.pa_varchar2_15_tbl_type()
        ,p_rep_rate_base_flag_tab     IN SYSTEM.pa_varchar2_15_tbl_type := SYSTEM.pa_varchar2_15_tbl_type()
        ,x_msg_data                     OUT NOCOPY Varchar2
        ,x_msg_count                    OUT NOCOPY Number
        ,x_return_status                OUT NOCOPY Varchar2
        ) IS

        l_msg_count             Number := 0;
        l_msg_data              Varchar2(1000) := Null;
        l_return_status         Varchar2(10);
        l_debug_flag            Varchar2(10);
        PJI_EXCEPTION           EXCEPTION;

	l_rep_budget_line_id_tab        SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
        l_rep_res_assignment_id_tab     SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
        l_rep_start_date_tab            SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
        l_rep_end_date_tab              SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
        l_rep_period_name_tab           SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
        l_rep_txn_curr_code_tab         SYSTEM.pa_varchar2_15_tbl_type := SYSTEM.pa_varchar2_15_tbl_type();
        l_rep_quantity_tab              SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
        l_rep_txn_raw_cost_tab          SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
        l_rep_txn_burdened_cost_tab     SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
        l_rep_txn_revenue_tab           SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
        l_rep_project_curr_code_tab     SYSTEM.pa_varchar2_15_tbl_type := SYSTEM.pa_varchar2_15_tbl_type();
        l_rep_project_raw_cost_tab      SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
        l_rep_project_burden_cost_tab   SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
        l_rep_project_revenue_tab       SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
        l_rep_projfunc_curr_code_tab    SYSTEM.pa_varchar2_15_tbl_type := SYSTEM.pa_varchar2_15_tbl_type();
        l_rep_projfunc_raw_cost_tab     SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
        l_rep_projfunc_burden_cost_tab  SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
        l_rep_projfunc_revenue_tab      SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();

	/*
         * The following _act_ tables are to hold Actual amounts.
         */
        l_rep_act_quantity_tab          SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
        l_rep_txn_act_raw_cost_tab      SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
        l_rep_txn_act_burd_cost_tab     SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
        l_rep_txn_act_rev_tab           SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
        l_rep_prj_act_raw_cost_tab      SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
        l_rep_prj_act_burd_cost_tab     SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
        l_rep_prj_act_rev_tab           SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
        l_rep_pf_act_raw_cost_tab       SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
        l_rep_pf_act_burd_cost_tab      SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
        l_rep_pf_act_rev_tab            SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();

	l_rep_org_id_tab		SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
	l_rep_rbs_version_id_tab	SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
	l_rep_finplan_type_id_tab	SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
	l_rep_proj_structure_id_tab	SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
	l_rep_wp_version_flag_tab	SYSTEM.pa_varchar2_15_tbl_type := SYSTEM.pa_varchar2_15_tbl_type();
	l_rep_time_phase_code_tab       SYSTEM.pa_varchar2_15_tbl_type := SYSTEM.pa_varchar2_15_tbl_type();
	l_rep_project_id_tab		SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
	l_rep_task_id_tab		SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
	l_rep_rbs_element_id_tab	SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
	l_rep_resclass_code_tab		SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
	l_rep_rate_base_flag_tab        SYSTEM.pa_varchar2_15_tbl_type := SYSTEM.pa_varchar2_15_tbl_type();
	l_rep_line_mode_tab          	SYSTEM.pa_varchar2_15_tbl_type := SYSTEM.pa_varchar2_15_tbl_type();

        l_pji_call_flag         Varchar2(10);
	l_resAssId		Number;
        l_start_date            Date;
        l_end_date              Date;
        l_period_name           Varchar2(100);
        l_txn_currency_code     Varchar2(100);
        l_txn_raw_cost          Number;
        l_txn_burdened_cost     Number;
        l_txn_revenue           Number;
        l_project_currency_code Varchar2(100);
        l_project_raw_cost      Number;
        l_project_burdened_cost Number;
        l_project_revenue       Number;
        l_projfunc_currency_code Varchar2(100);
        l_projfunc_raw_cost     Number;
        l_projfunc_burdened_cost Number;
        l_projfunc_revenue      Number;
        l_quantity              Number;

        l_budget_line_id        Number;
        l_num_rows_inserted     Number;
        INVALID_PARAMS          EXCEPTION;
        l_stage                 Varchar2(100);

	l_project_id		Number;
        l_task_id		Number;
        l_rbs_element_id	Number;
        l_res_class_code	Varchar2(80);
        l_rate_base_flag	Varchar2(80);
        l_org_id		Number;
        l_rbs_version_id	Number;
        l_fin_plan_type_id	Number;
        l_project_structure_id	Number;
        l_wp_version_flag	Varchar2(80);
        l_time_phase_code	Varchar2(80);

	CURSOR strVer IS
	SELECT DECODE(nvl(pbv.wp_version_flag,'N'),'Y',pbv.project_structure_version_id,
                       PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(pbv.project_id)) project_structure_version_id
	FROM pa_budget_versions pbv
	WHERE pbv.budget_version_id = p_budget_version_id;


BEGIN
        l_return_status := 'S';
        x_return_status := 'S';
        x_msg_count := 0;
        x_msg_data  := Null;

        l_stage := 10;
        /* Initialize the error stack */
        l_debug_flag := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
        g_debug_flag := l_debug_flag;
	print_msg('Entered PA_FP_PJI_INTG_PKG.blk_update_reporting_lines api: Num of Trxns['||p_rep_res_assignment_id_tab.count||']','Y');
	If g_debug_flag = 'Y' Then
        	pa_debug.init_err_stack('PA_FP_PJI_INTG_PKG.blk_update_reporting_lines');
        	PA_DEBUG.SET_PROCESS( x_process => 'PLSQL'
                      ,x_write_file     => 'LOG'
                      ,x_debug_mode      => l_debug_flag
                          );
	End If;
	/* Assign the in params to local tables*/
	l_rep_budget_line_id_tab        := p_rep_budget_line_id_tab;
        l_rep_res_assignment_id_tab     := p_rep_res_assignment_id_tab;
        l_rep_start_date_tab            := p_rep_start_date_tab;
        l_rep_end_date_tab              := p_rep_end_date_tab;
        l_rep_period_name_tab           := p_rep_period_name_tab;
        l_rep_txn_curr_code_tab         := p_rep_txn_curr_code_tab;
        l_rep_quantity_tab              := p_rep_quantity_tab;
        l_rep_txn_raw_cost_tab          := p_rep_txn_raw_cost_tab;
        l_rep_txn_burdened_cost_tab     := p_rep_txn_burdened_cost_tab;
        l_rep_txn_revenue_tab           := p_rep_txn_revenue_tab;
        l_rep_project_curr_code_tab     := p_rep_project_curr_code_tab;
        l_rep_project_raw_cost_tab      := p_rep_project_raw_cost_tab;
        l_rep_project_burden_cost_tab   := p_rep_project_burden_cost_tab;
        l_rep_project_revenue_tab       := p_rep_project_revenue_tab;
        l_rep_projfunc_curr_code_tab    := p_rep_projfunc_curr_code_tab;
        l_rep_projfunc_raw_cost_tab     := p_rep_projfunc_raw_cost_tab;
        l_rep_projfunc_burden_cost_tab  := p_rep_projfunc_burden_cost_tab;
        l_rep_projfunc_revenue_tab	:= p_rep_projfunc_revenue_tab;
        l_rep_act_quantity_tab          := p_rep_act_quantity_tab;
        l_rep_txn_act_raw_cost_tab      := p_rep_txn_act_raw_cost_tab;
        l_rep_txn_act_burd_cost_tab     := p_rep_txn_act_burd_cost_tab;
        l_rep_txn_act_rev_tab           := p_rep_txn_act_rev_tab;
        l_rep_prj_act_raw_cost_tab      := p_rep_prj_act_raw_cost_tab;
        l_rep_prj_act_burd_cost_tab     := p_rep_prj_act_burd_cost_tab;
        l_rep_prj_act_rev_tab           := p_rep_prj_act_rev_tab;
        l_rep_pf_act_raw_cost_tab       := p_rep_pf_act_raw_cost_tab;
        l_rep_pf_act_burd_cost_tab      := p_rep_pf_act_burd_cost_tab;
        l_rep_pf_act_rev_tab            := p_rep_pf_act_rev_tab;
	l_rep_rate_base_flag_tab        := p_rep_rate_base_flag_tab;
	l_rep_line_mode_tab             := p_rep_line_mode_tab;

	/*=================================================================+
	 | Taking care of input tables that were not passed by the caller. |
	 | This is being done only for Actual amounts assuming plan        |
	 | amounts will always be sent.                                    |
	 +=================================================================*/
        FOR i IN l_rep_quantity_tab.FIRST ..  l_rep_quantity_tab.LAST
        LOOP
            IF NOT l_rep_act_quantity_tab.EXISTS(i)
            THEN
                l_rep_act_quantity_tab.EXTEND;
                l_rep_act_quantity_tab(i)  := NULL;
            ELSIF l_rep_act_quantity_tab(i) = fnd_api.g_miss_num
            THEN
                l_rep_act_quantity_tab(i)  := NULL;
            END IF;

            IF NOT l_rep_txn_act_raw_cost_tab.EXISTS(i)
            THEN
                l_rep_txn_act_raw_cost_tab.EXTEND;
                l_rep_txn_act_raw_cost_tab(i)  := NULL;
            ELSIF l_rep_txn_act_raw_cost_tab(i) = fnd_api.g_miss_num
            THEN
                l_rep_txn_act_raw_cost_tab(i)  := NULL;
            END IF;

            IF NOT l_rep_txn_act_burd_cost_tab.EXISTS(i)
            THEN
                l_rep_txn_act_burd_cost_tab.EXTEND;
                l_rep_txn_act_burd_cost_tab(i)  := NULL;
            ELSIF l_rep_txn_act_burd_cost_tab(i) = fnd_api.g_miss_num
            THEN
                l_rep_txn_act_burd_cost_tab(i)  := NULL;
            END IF;

            IF NOT l_rep_txn_act_rev_tab.EXISTS(i)
            THEN
                l_rep_txn_act_rev_tab.EXTEND;
                l_rep_txn_act_rev_tab(i)  := NULL;
            ELSIF l_rep_txn_act_rev_tab(i) = fnd_api.g_miss_num
            THEN
                l_rep_txn_act_rev_tab(i)  := NULL;
            END IF;

            IF NOT l_rep_prj_act_raw_cost_tab.EXISTS(i)
            THEN
                l_rep_prj_act_raw_cost_tab.EXTEND;
                l_rep_prj_act_raw_cost_tab(i)  := NULL;
            ELSIF l_rep_prj_act_raw_cost_tab(i) = fnd_api.g_miss_num
            THEN
                l_rep_prj_act_raw_cost_tab(i)  := NULL;
            END IF;
            IF NOT l_rep_prj_act_burd_cost_tab.EXISTS(i)
            THEN
                l_rep_prj_act_burd_cost_tab.EXTEND;
                l_rep_prj_act_burd_cost_tab(i)  := NULL;
            ELSIF l_rep_prj_act_burd_cost_tab(i) = fnd_api.g_miss_num
            THEN
                l_rep_prj_act_burd_cost_tab(i)  := NULL;
            END IF;
            IF NOT l_rep_prj_act_rev_tab.EXISTS(i)
            THEN
                l_rep_prj_act_rev_tab.EXTEND;
                l_rep_prj_act_rev_tab(i)  := NULL;
            ELSIF l_rep_prj_act_rev_tab(i) = fnd_api.g_miss_num
            THEN
                l_rep_prj_act_rev_tab(i)  := NULL;
            END IF;
            IF NOT l_rep_pf_act_raw_cost_tab.EXISTS(i)
            THEN
                l_rep_pf_act_raw_cost_tab.EXTEND;
                l_rep_pf_act_raw_cost_tab(i)  := NULL;
            ELSIF l_rep_pf_act_raw_cost_tab(i) = fnd_api.g_miss_num
            THEN
                l_rep_pf_act_raw_cost_tab(i)  := NULL;
            END IF;
            IF NOT l_rep_pf_act_burd_cost_tab.EXISTS(i)
            THEN
                l_rep_pf_act_burd_cost_tab.EXTEND;
                l_rep_pf_act_burd_cost_tab(i)  := NULL;
            ELSIF l_rep_pf_act_burd_cost_tab(i) = fnd_api.g_miss_num
            THEN
                l_rep_pf_act_burd_cost_tab(i)  := NULL;
            END IF;
            IF NOT l_rep_pf_act_rev_tab.EXISTS(i)
            THEN
                l_rep_pf_act_rev_tab.EXTEND;
                l_rep_pf_act_rev_tab(i)  := NULL;
            ELSIF l_rep_pf_act_rev_tab(i) = fnd_api.g_miss_num
            THEN
                l_rep_pf_act_rev_tab(i)  := NULL;
            END IF;

	    IF NOT l_rep_rate_base_flag_tab.EXISTS(i) Then
		l_rep_rate_base_flag_tab.EXTEND;
		l_rep_rate_base_flag_tab(i) := NULL;
	    END IF;

	    IF NOT l_rep_line_mode_tab.EXISTS(i) then
		l_rep_line_mode_tab.EXTEND;
		l_rep_line_mode_tab(i) := NULL;
	    END If;

        END LOOP; -- g_TXN_SOURCE_ID_sysTab.FIRST .. g_TXN_SOURCE_ID_sysTab.LAST

	IF p_activity_code = 'DELETE' AND l_rep_budget_line_id_tab.COUNT = 0 Then
		l_stage := 20;
		raise invalid_params;
	End IF;

	/* bug fix: 3839761 */
	IF p_budget_version_id is NOT NULL Then
		l_project_structure_id := null;
		OPEN strVer;
		FETCH strVer INTO l_project_structure_id;
		CLOSE strVer;
	End If;

	If p_activity_code in ('UPDATE','DELETE') Then
		l_stage := 30;
		FOR i IN l_rep_budget_line_id_tab.FIRST .. l_rep_budget_line_id_tab.LAST LOOP  --{
		    IF (p_calling_module = 'BUDGET_LINE'  AND l_rep_budget_line_id_tab(i) is NOT NULL) Then
			  BEGIN
				l_stage := 50;
			        If g_debug_flag = 'Y' Then
				print_msg('Executing sql to get -ve amts for budget line Id['||l_rep_budget_line_id_tab(i)||']');
				End If;
                                -- IPM: Removed check for budget line rejection codes.
				SELECT bl.start_date
                                        ,bl.end_date
                                        ,bl.period_name
                                        ,bl.txn_currency_code
                                        ,decode(p_activity_code,'DELETE',bl.txn_raw_cost * -1,bl.txn_raw_cost)
                                        ,decode(p_activity_code,'DELETE',bl.txn_burdened_cost *-1 , bl.txn_burdened_cost)
                                        ,decode(p_activity_code,'DELETE',bl.txn_revenue * -1 ,bl.txn_revenue)
                                        ,bl.project_currency_code
                                        ,decode(p_activity_code,'DELETE',bl.project_raw_cost * -1 ,bl.project_raw_cost)
                                        ,decode(p_activity_code,'DELETE',bl.project_burdened_cost * -1 ,bl.project_burdened_cost)
                                        ,decode(p_activity_code,'DELETE',bl.project_revenue * -1 ,bl.project_revenue)
                                        ,bl.projfunc_currency_code
                                        ,decode(p_activity_code,'DELETE',bl.raw_cost * -1 ,bl.raw_cost)
                                        ,decode(p_activity_code,'DELETE',bl.burdened_cost * -1 ,bl.burdened_cost)
                                        ,decode(p_activity_code,'DELETE',bl.revenue * -1 ,bl.revenue)
                                        ,decode(p_activity_code,'DELETE',bl.quantity * -1 ,bl.quantity)
                                        ,decode(p_activity_code,'DELETE',bl.txn_init_raw_cost * -1,bl.txn_init_raw_cost)
                                        ,decode(p_activity_code,'DELETE',bl.txn_init_burdened_cost *-1 , bl.txn_init_burdened_cost)
                                        ,decode(p_activity_code,'DELETE',bl.txn_init_revenue * -1 ,bl.txn_init_revenue)
                                        ,decode(p_activity_code,'DELETE',bl.project_init_raw_cost * -1 ,bl.project_init_raw_cost)
                                        ,decode(p_activity_code,'DELETE',bl.project_init_burdened_cost * -1 ,bl.project_init_burdened_cost)
                                        ,decode(p_activity_code,'DELETE',bl.project_init_revenue * -1 ,bl.project_init_revenue)
                                        ,decode(p_activity_code,'DELETE',bl.init_raw_cost * -1 ,bl.init_raw_cost)
                                        ,decode(p_activity_code,'DELETE',bl.init_burdened_cost * -1 ,bl.init_burdened_cost)
                                        ,decode(p_activity_code,'DELETE',bl.init_revenue * -1 ,bl.init_revenue)
                                        ,decode(p_activity_code,'DELETE',bl.init_quantity * -1 ,bl.init_quantity)
				INTO
					l_rep_start_date_tab(i)
        				,l_rep_end_date_tab(i)
        				,l_rep_period_name_tab(i)
        				,l_rep_txn_curr_code_tab(i)
        				,l_rep_txn_raw_cost_tab(i)
        				,l_rep_txn_burdened_cost_tab(i)
        				,l_rep_txn_revenue_tab(i)
        				,l_rep_project_curr_code_tab(i)
        				,l_rep_project_raw_cost_tab(i)
        				,l_rep_project_burden_cost_tab(i)
        				,l_rep_project_revenue_tab(i)
        				,l_rep_projfunc_curr_code_tab(i)
        				,l_rep_projfunc_raw_cost_tab(i)
        				,l_rep_projfunc_burden_cost_tab(i)
        				,l_rep_projfunc_revenue_tab(i)
        				,l_rep_quantity_tab(i)
                                        ,l_rep_txn_act_raw_cost_tab(i)
                                        ,l_rep_txn_act_burd_cost_tab(i)
                                        ,l_rep_txn_act_rev_tab(i)
                                        ,l_rep_prj_act_raw_cost_tab(i)
                                        ,l_rep_prj_act_burd_cost_tab(i)
                                        ,l_rep_prj_act_rev_tab(i)
                                        ,l_rep_pf_act_raw_cost_tab(i)
                                        ,l_rep_pf_act_burd_cost_tab(i)
                                        ,l_rep_pf_act_rev_tab(i)
                                        ,l_rep_act_quantity_tab(i)
				FROM pa_budget_lines bl
				WHERE bl.budget_line_id = l_rep_budget_line_id_tab(i);
				If g_debug_flag = 'Y' Then
				print_msg('Number of rows fetched:['||sql%rowcount||']');
				End If;
				l_stage := 50;
			  EXCEPTION
				WHEN NO_DATA_FOUND Then
					-- set the following columns to null so that calling pji api is bypassed
					l_stage := 60;
					l_rep_quantity_tab(i) :=  NULL;
                                    	l_rep_txn_raw_cost_tab(i) := NULL;
                                    	l_rep_txn_burdened_cost_tab(i) := NULL;
                                    	l_rep_txn_revenue_tab(i) := NULL;
					l_rep_act_quantity_tab(i) :=  NULL;
                                    	l_rep_txn_act_raw_cost_tab(i) := NULL;
                                    	l_rep_txn_act_burd_cost_tab(i) := NULL;
                                    	l_rep_txn_act_rev_tab(i) := NULL;
			  END ;
		    END IF;
		END LOOP; --}
		l_stage := 60;
		/* Insert the records into pji tmp table*/
		FOR i IN l_rep_res_assignment_id_tab.FIRST .. l_rep_res_assignment_id_tab.LAST LOOP --{
		   l_rep_org_id_tab.extend;
        	   l_rep_rbs_version_id_tab.extend;
        	   l_rep_finplan_type_id_tab.extend;
        	   l_rep_proj_structure_id_tab.extend;
        	   l_rep_wp_version_flag_tab.extend;
        	   l_rep_time_phase_code_tab.extend;
        	   l_rep_project_id_tab.extend;
        	   l_rep_task_id_tab.extend;
        	   l_rep_rbs_element_id_tab.extend;
        	   l_rep_resclass_code_tab.extend;
        	   -- bug fix: 5116157 l_rep_rate_base_flag_tab.extend;
		   If (l_resAssId is NULL or l_resAssId <> l_rep_res_assignment_id_tab(i) ) Then
			If g_debug_flag = 'Y' Then
			print_msg('Fetching Resource details for AssignmentId['||l_rep_res_assignment_id_tab(i)||']');
			End If;
			SELECT ra.project_id
                		,ra.task_id
                		,ra.rbs_element_id
                		,ra.resource_class_code
                		,ra.rate_based_flag
				,ppa.org_id
                		,ppfo.rbs_version_id
                		,pbv.fin_plan_type_id
				/* Bug fix: 3839761 --nvl(pbv.project_structure_version_id,
                      		     --PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(pbv.project_id)) project_structure_version_id
				*/
                		,pbv.wp_version_flag
                		,decode(pbv.version_type, 'COST',ppfo.cost_time_phased_code,
                                			'REVENUE',ppfo.revenue_time_phased_code,
                                        		ppfo.all_time_phased_code) time_phase_code
			INTO l_project_id
				,l_task_id
				,l_rbs_element_id
				,l_res_class_code
				,l_rate_base_flag
				,l_org_id
				,l_rbs_version_id
				,l_fin_plan_type_id
				/* bug fix: 3839761--,l_project_structure_id */
				,l_wp_version_flag
				,l_time_phase_code
			FROM pa_projects_all        ppa
                		,pa_budget_versions     pbv
                		,pa_proj_fp_options     ppfo
                		,pa_resource_assignments ra
        		WHERE ppa.project_id        = pbv.project_id
        		AND pbv.budget_version_id = ppfo.fin_plan_version_id
        		AND pbv.budget_version_id = p_budget_version_id
        		AND ra.resource_assignment_id = l_rep_res_assignment_id_tab(i)
        		AND ra.budget_version_id = pbv.budget_version_id;

			l_resAssId := l_rep_res_assignment_id_tab(i);
			l_rep_project_id_tab(i) := l_project_id;
			l_rep_task_id_tab(i) := l_task_id;
			l_rep_rbs_element_id_tab(i) := l_rbs_element_id;
			l_rep_resclass_code_tab(i) := l_res_class_code;
			IF NVL(l_rep_line_mode_tab(i),'XXX') = 'REVERSAL' Then
			   l_rep_rate_base_flag_tab(i) := NVL(l_rep_rate_base_flag_tab(i),l_rate_base_flag);
			Else
			   l_rep_rate_base_flag_tab(i) :=  l_rate_base_flag;
			End If;
			l_rep_org_id_tab(i) := l_org_id;
			l_rep_rbs_version_id_tab(i) := l_rbs_version_id;
			l_rep_finplan_type_id_tab(i) := l_fin_plan_type_id;
			l_rep_proj_structure_id_tab(i) := l_project_structure_id;
			l_rep_wp_version_flag_tab(i) := l_wp_version_flag;
			l_rep_time_phase_code_tab(i) := l_time_phase_code;
		   Else
			-- retrieve from cache
			l_resAssId := l_rep_res_assignment_id_tab(i);
                        l_rep_project_id_tab(i) := l_project_id;
                        l_rep_task_id_tab(i) := l_task_id;
                        l_rep_rbs_element_id_tab(i) := l_rbs_element_id;
                        l_rep_resclass_code_tab(i) := l_res_class_code;
			IF NVL(l_rep_line_mode_tab(i),'XXX') = 'REVERSAL' Then
                           l_rep_rate_base_flag_tab(i) := NVL(l_rep_rate_base_flag_tab(i),l_rate_base_flag);
                        Else
                           l_rep_rate_base_flag_tab(i) :=  l_rate_base_flag;
                        End If;
			l_rep_org_id_tab(i) := l_org_id;
                        l_rep_rbs_version_id_tab(i) := l_rbs_version_id;
                        l_rep_finplan_type_id_tab(i) := l_fin_plan_type_id;
                        l_rep_proj_structure_id_tab(i) := l_project_structure_id;
                        l_rep_wp_version_flag_tab(i) := l_wp_version_flag;
                        l_rep_time_phase_code_tab(i) := l_time_phase_code;
		   End If;
		END LOOP; --}

		/*Bulk insert into reporting table */
		IF l_rep_res_assignment_id_tab.COUNT > 0 Then --{
			l_num_rows_inserted := 0;
			l_stage := 80;
			If g_debug_flag = 'Y' Then
			print_msg(l_stage||': Inserting records into PJI_FM_EXTR_PLAN_LINES tmp table');
			End If;
			FORALL i IN l_rep_res_assignment_id_tab.FIRST .. l_rep_res_assignment_id_tab.LAST
           			    INSERT INTO PJI_FM_EXTR_PLAN_LINES
					( PROJECT_ID
                   			,PROJECT_ORG_ID
                   			,PROJECT_ELEMENT_ID
                   			,STRUCT_VER_ID
                   			,CALENDAR_TYPE
                   			,RBS_ELEMENT_ID
                   			,RBS_VERSION_ID
                   			,PLAN_VERSION_ID
                   			,PLAN_TYPE_ID
                   			,WP_VERSION_FLAG
                   			,RESOURCE_CLASS_CODE
                   			,RATE_BASED_FLAG
                   			,ROLLUP_TYPE
                   			,START_DATE
                   			,END_DATE
                   			,PERIOD_NAME
                   			,TXN_CURRENCY_CODE
                   			,TXN_RAW_COST
                   			,TXN_BURDENED_COST
                   			,TXN_REVENUE
                   			,PRJ_CURRENCY_CODE
                   			,PRJ_RAW_COST
                   			,PRJ_BURDENED_COST
                   			,PRJ_REVENUE
                   			,PFC_CURRENCY_CODE
                   			,PFC_RAW_COST
                   			,PFC_BURDENED_COST
                   			,PFC_REVENUE
                   			,QUANTITY
                                        ,ACT_TXN_RAW_COST
                                        ,ACT_TXN_BURDENED_COST
                                        ,ACT_TXN_REVENUE
                                        ,ACT_PRJ_RAW_COST
                                        ,ACT_PRJ_BURDENED_COST
                                        ,ACT_PRJ_REVENUE
                                        ,ACT_PFC_RAW_COST
                                        ,ACT_PFC_BURDENED_COST
                                        ,ACT_PFC_REVENUE
                                        ,ACT_QUANTITY
                   			)
           			   SELECT
                   			l_rep_project_id_tab(i)
                   			,l_rep_org_id_tab(i)
                   			,l_rep_task_id_tab(i)
                   			,l_rep_proj_structure_id_tab(i)
                   			,l_rep_time_phase_code_tab(i)
                   			,l_rep_rbs_element_id_tab(i)
                   			,l_rep_rbs_version_id_tab(i)
                   			,p_budget_version_id
                   			,l_rep_finplan_type_id_tab(i)
                   			,l_rep_wp_version_flag_tab(i)
                   			,l_rep_resclass_code_tab(i)
                   			,l_rep_rate_base_flag_tab(i)
                   			,'W'
					,l_rep_start_date_tab(i)
					,l_rep_end_date_tab(i)
                   			,l_rep_period_name_tab(i)
                   			,l_rep_txn_curr_code_tab(i)
                   			,l_rep_txn_raw_cost_tab(i)
                   			,l_rep_txn_burdened_cost_tab(i)
                   			,l_rep_txn_revenue_tab(i)
                   			,l_rep_project_curr_code_tab(i)
                   			,l_rep_project_raw_cost_tab(i)
                   			,l_rep_project_burden_cost_tab(i)
                   			,l_rep_project_revenue_tab(i)
                   			,l_rep_projfunc_curr_code_tab(i)
                   			,l_rep_projfunc_raw_cost_tab(i)
                   			,l_rep_projfunc_burden_cost_tab(i)
                   			,l_rep_projfunc_revenue_tab(i)
                   			,l_rep_quantity_tab(i)
                                        ,l_rep_txn_act_raw_cost_tab(i)
                                        ,l_rep_txn_act_burd_cost_tab(i)
                                        ,l_rep_txn_act_rev_tab(i)
                                        ,l_rep_prj_act_raw_cost_tab(i)
                                        ,l_rep_prj_act_burd_cost_tab(i)
                                        ,l_rep_prj_act_rev_tab(i)
                                        ,l_rep_pf_act_raw_cost_tab(i)
                                        ,l_rep_pf_act_burd_cost_tab(i)
                                        ,l_rep_pf_act_rev_tab(i)
                                        ,l_rep_act_quantity_tab(i)
				  FROM DUAL
				  WHERE ( l_rep_quantity_tab(i) is NOT NULL
					OR l_rep_txn_raw_cost_tab(i) is NOT NULL
					OR l_rep_txn_burdened_cost_tab(i) is NOT NULL
					OR l_rep_txn_revenue_tab(i) is NOT NULL
					OR l_rep_act_quantity_tab(i) is NOT NULL
					OR l_rep_txn_act_raw_cost_tab(i) is NOT NULL
					OR l_rep_txn_act_burd_cost_tab(i) is NOT NULL
					OR l_rep_txn_act_rev_tab(i) is NOT NULL ) ;
				  l_num_rows_inserted := sql%rowcount;
				  If g_debug_flag = 'Y' Then
				  print_msg('Number of records inserted ['||l_num_rows_inserted||']');
				  End If;
			/* end of Bulk insert */

			/* Start for dubug message*/
			/* Bug fix: 4159553 enclose the the following cursor in a debug flag */
			IF NVL(g_debug_flag,'N') = 'Y' Then
			   for j in (select pj.RBS_ELEMENT_ID 		RBS_ELEMENT_ID
					,pj.TXN_CURRENCY_CODE		TXN_CURRENCY_CODE
					,pj.RATE_BASED_FLAG             RATE_BASED_FLAG
                                        ,sum(pj.QUANTITY)		QUANTITY
                                        ,sum(pj.TXN_RAW_COST)		TXN_RAW_COST
                                        ,sum(pj.TXN_BURDENED_COST)	TXN_BURDENED_COST
                                        ,sum(pj.TXN_REVENUE)		TXN_REVENUE
                                        ,sum(pj.ACT_QUANTITY)           ACT_QUANTITY
                                        ,sum(pj.ACT_TXN_RAW_COST)       ACT_TXN_RAW_COST
                                        ,sum(pj.ACT_TXN_BURDENED_COST)  ACT_TXN_BURDENED_COST
                                        ,sum(pj.ACT_TXN_REVENUE)        ACT_TXN_REVENUE
				  from PJI_FM_EXTR_PLAN_LINES pj
				  where pj.plan_version_id = p_budget_version_id
				  Group by pj.RBS_VERSION_ID
					  ,pj.RBS_ELEMENT_ID
					  ,pj.TXN_CURRENCY_CODE
					  ,pj.RATE_BASED_FLAG ) LOOP
				null;
				print_msg('RbsElemnt['||j.RBS_ELEMENT_ID||']TxnCur['||j.TXN_CURRENCY_CODE||
                                   ']TxnQty['||j.QUANTITY||']TxnRaw['||j.TXN_RAW_COST||
                                   ']TxnBurd['||j.TXN_BURDENED_COST||']TxnReve['||j.TXN_REVENUE||
                                   ']ActTxnQty['||j.ACT_QUANTITY||']ActTxnRaw['||j.ACT_TXN_RAW_COST||
                                   ']ActTxnBurd['||j.ACT_TXN_BURDENED_COST||']ActTxnReve['||j.ACT_TXN_REVENUE||
                                   ']RateBaseFlag['||j.RATE_BASED_FLAG||']');
			   End Loop;
			END IF;
			/* end of dbug message*/

			IF l_num_rows_inserted > 0 Then
				  l_stage := 100;
				  /* added this as per PJIs request ( virangan) */
				     print_msg('Start of PJI_plan_update:['||dbms_utility.get_time||']');
                                     IF p_budget_version_id IS NOT NULL THEN
					If g_debug_flag = 'Y' Then
					print_msg('l_stage: Calling PJI_FM_XBS_ACCUM_MAINT.plan_update for budget version');
					End If;
                                        PJI_FM_XBS_ACCUM_MAINT.plan_update
                                        (p_plan_version_id => p_budget_version_id
                                        , x_msg_code => l_msg_data
                                        ,x_return_status  => l_return_status
                                        );
                                     ELSE
					If g_debug_flag = 'Y' Then
					print_msg('l_stage: Calling PJI_FM_XBS_ACCUM_MAINT.plan_update without version');
					End If;
                                        PJI_FM_XBS_ACCUM_MAINT.plan_update
                                        ( x_msg_code => l_msg_data
                                        ,x_return_status  => l_return_status
                                        );
                                     END IF;
				     print_msg('End of PJI_plan_update:['||dbms_utility.get_time||']');
                                     l_stage := 110;
				     If g_debug_flag = 'Y' Then
                                     Print_msg('End of PJI_FM_XBS_ACCUM_MAINT.plan_update retSts['||l_return_status||']msgdata['||l_msg_data||']');
				     End If;
                                     If l_return_status <> 'S' Then
                                         l_stage := 120;
                                         x_msg_data := l_msg_data;
                                         Raise pji_exception;
                                     End If;
			END IF;

		END IF; --} end of restab count > 0
        End If; -- end of p_activity
        l_stage := 200;
        x_return_status := l_return_status;
	If g_debug_flag = 'Y' Then
        print_msg('End of blk_update_reporting_lines api retSts['||x_return_status||']');
	End If;
        --reset the error stack;
	If g_debug_flag = 'Y' Then
        	pa_debug.reset_err_stack;
	End If;

EXCEPTION
        WHEN INVALID_PARAMS THEN
                x_return_status := 'E';
                x_msg_count  := 1;
                x_msg_data := 'PA_FP_INVALID_PARAMS';
                print_msg(l_stage||x_msg_data,'Y');
        WHEN PJI_EXCEPTION THEN
                x_return_status := 'U';
                x_msg_count  := 1;
                fnd_msg_pub.add_exc_msg
                ( p_pkg_name       => 'PA_FP_PJI_INTG_PKG'
                ,p_procedure_name => 'blk_update_reporting_lines:Error Occured in plan_update' );
                print_msg(l_stage||'Error occured in blk_update_reporting_lines:Error Occured in plan_update ['||x_msg_data||']','Y');
		If g_debug_flag = 'Y' Then
                	pa_debug.reset_err_stack;
		End If;
                -- Bug 4621171: Removed RAISE statement.

        WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                x_msg_data := SQLCODE||SQLERRM;
                x_msg_count  := 1;
                fnd_msg_pub.add_exc_msg
                ( p_pkg_name       => 'PA_FP_PJI_INTG_PKG'
                ,p_procedure_name => 'update_reporting_lines' );
                print_msg(l_stage||'Error occured in blk_update_reporting_lines['|| substr(SQLERRM,1,240),'Y');
		If g_debug_flag = 'Y' Then
                	pa_debug.reset_err_stack;
		End If;
                RAISE;

END blk_update_reporting_lines;

END PA_FP_PJI_INTG_PKG;

/
