--------------------------------------------------------
--  DDL for Package Body PA_FIN_PLAN_UTILS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FIN_PLAN_UTILS2" AS
/* $Header: PAFPUT2B.pls 120.8.12010000.3 2009/06/25 11:02:56 rthumma ship $ */

G_FpTaskBillable_Tab    PA_FIN_PLAN_UTILS2.BillableTab;

g_debug_flag  Varchar2(1);
/** Forward declaration */
P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
PROCEDURE checkUserRateAllowed
                (p_From_curr_code IN Varchar2
                ,p_To_curr_code   IN Varchar2
                ,p_Conversion_Date IN Date
                ,p_To_Curr_Rate_Type IN Varchar2
                ,p_To_Curr_Exchange_Rate IN Number
		,p_calling_mode    IN Varchar2
		,p_calling_context IN Varchar2
                ,x_return_status  OUT NOCOPY Varchar2
                ,x_error_msg_code OUT NOCOPY Varchar2
                );
/******/
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
PROCEDURE print_msg(p_debug_flag   varchar2
		   ,p_proc_name    varchar2
		   ,p_msg          varchar2 ) IS

	l_module varchar2(1000) := 'PA_FIN_PLAN_UTILS2.'||p_proc_name;

BEGIN
	--calc_log(p_msg);
	If p_debug_flag = 'Y' Then
		PA_DEBUG.write
                (x_Module       => l_module
                ,x_Msg          => substr('LOG:'||p_msg,1,240)
                ,x_Log_Level    => 3);
	End If;
END print_msg;

/* This API will be called from view to derive rejection flags based on the
 * given start and end dates
 */
FUNCTION get_bdgt_start_date Return DATE IS
BEGIN
	return g_bdgt_start_date;
END get_bdgt_start_date;
/* This API will be called from view to derive rejection flags based on the
 * given start and end dates
 */
FUNCTION get_bdgt_end_date Return DATE IS
BEGIN
        return g_bdgt_end_date;
END get_bdgt_end_date;

/* This API will derive the rate based flag and UOM for the planning transaction
 * This should be called while updating the planning resource transaction
 * Based on the IN params the new rate based flag and UOM will be derived
 * If old and new rate base flag values are different then x_rate_based_flag_changed_tab will be set to 'Y'
 * If old and new UOM values are different then x_uom_changed_flag_tab will be set to 'Y'
 * NOTE: Since this is PLSQL table LOOPING , this api should be called in batch of 100 records only
 */
PROCEDURE Get_UOM_RateBasedFlag (
		p_resource_class_code_tab        IN      	 SYSTEM.PA_VARCHAR2_30_TBL_TYPE
		,p_inventory_item_id_tab         IN      	 SYSTEM.PA_NUM_TBL_TYPE
		,p_rate_organization_id_tab      IN      	 SYSTEM.PA_NUM_TBL_TYPE
		,p_expenditure_type_tab          IN      	 SYSTEM.PA_VARCHAR2_30_TBL_TYPE
		,p_rate_expenditure_type_tab     IN      	 SYSTEM.PA_VARCHAR2_30_TBL_TYPE
		,p_old_UOM_tab           	 IN              SYSTEM.PA_VARCHAR2_30_TBL_TYPE
		,p_old_rate_based_flag_tab       IN              SYSTEM.PA_VARCHAR2_1_TBL_TYPE
		,x_New_UOM_tab           	 OUT NOCOPY      SYSTEM.PA_VARCHAR2_30_TBL_TYPE
		,x_uom_changed_flag_tab          OUT NOCOPY      SYSTEM.PA_VARCHAR2_1_TBL_TYPE
		,x_new_rate_based_flag_tab       OUT NOCOPY      SYSTEM.PA_VARCHAR2_1_TBL_TYPE
		,x_rate_based_flag_changed_tab   OUT NOCOPY      SYSTEM.PA_VARCHAR2_1_TBL_TYPE
		,x_return_status                 OUT NOCOPY      VARCHAR2
		) IS

	l_debug_flag  		Varchar2(100);
	l_stage 		Varchar2(1000);
	l_new_rate_based_flag   Varchar2(100);
	l_new_uom		Varchar2(100);
	l_return_status         Varchar2(100) := 'S';
	l_dummy_rate_based_flag Varchar2(100);

	l_proc_name             varchar2(100) := 'Get_UOM_RateBasedFlag';


	CURSOR cur_expRateFlag(p_exp_type  varchar2) IS
	SELECT NVL(c.cost_rate_flag,'N') Cost_rate_flag
		,Unit_Of_measure
        FROM pa_expenditure_types c
        WHERE c.expenditure_type = p_exp_type;

	CURSOR cur_ItemUom(p_item_id Number,p_organization_id Number) IS
	SELECT primary_uom_code
        FROM mtl_system_items_b items
        WHERE items.inventory_item_id = p_item_id
        AND items.organization_id = p_organization_id
	AND rownum = 1;



BEGIN
        --- Initialize the error statck
	IF p_pa_debug_mode = 'Y' THEN
        	PA_DEBUG.init_err_stack ('PA_FIN_PLAN_UTILS2.Get_UOM_RateBasedFlag');
	END IF;
        fnd_profile.get('PA_DEBUG_MODE',l_debug_flag);
        l_debug_flag := NVL(l_debug_flag, 'N');

	IF p_pa_debug_mode = 'Y' THEN
        PA_DEBUG.SET_PROCESS( x_process => 'PLSQL'
                      ,x_write_file     => 'LOG'
                      ,x_debug_mode      => l_debug_flag
                          );
	END IF;
	x_return_status := 'S';

	l_stage := 'Begin of Get_UOM_RateBasedFlag Table Count['||p_resource_class_code_tab.count||']';
	print_msg(l_debug_flag,l_proc_name,l_stage);

	x_New_UOM_tab                   := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
        x_uom_changed_flag_tab          := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
        x_new_rate_based_flag_tab       := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
        x_rate_based_flag_changed_tab   := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();

	x_New_UOM_tab.extend(p_resource_class_code_tab.count);
        x_uom_changed_flag_tab.extend(p_resource_class_code_tab.count);
        x_new_rate_based_flag_tab.extend(p_resource_class_code_tab.count);
        x_rate_based_flag_changed_tab.extend(p_resource_class_code_tab.count);

	/* Bug fix:3610888 removed the nvl(p_rate_expenditure_type_tab,p_rate_expenditure_type_tab
         * the param p_rate_expenditure_type_tab WILL BE IGNORED */
	IF p_resource_class_code_tab.count > 0  THEN
		FOR i IN p_resource_class_code_tab.FIRST .. p_resource_class_code_tab.LAST LOOP
		    l_stage := 'Inside the Loop Index['||i||']: ResClass['||p_resource_class_code_tab(i)||
				']InvItem['||p_inventory_item_id_tab(i)||
				']OldRateFlag['||p_old_rate_based_flag_tab(i)||
				']OldUom['||p_old_UOM_tab(i)||
				']ExpType['||p_expenditure_type_tab(i)||
				']RateExpType['||p_rate_expenditure_type_tab(i)||
				']RateOrganzId['||p_rate_organization_id_tab(i)||
				']';
		        print_msg(l_debug_flag,l_proc_name,l_stage);
			l_new_rate_based_flag := NVL(p_old_rate_based_flag_tab(i),'N');
			l_new_uom := NVL(p_old_UOM_tab(i),'DOLLARS');

			/* Derive the new Rate Based flag */
			IF p_resource_class_code_tab(i) in ('PEOPLE','EQUIPMENT') Then
				l_new_rate_based_flag := 'Y';
				l_new_uom := 'HOURS';
			Elsif p_resource_class_code_tab(i) in ('MATERIAL_ITEMS') Then
				If p_inventory_item_id_tab(i) is NOT NULL Then
					/* for inventory items the rate based flag is always Y */
					l_new_rate_based_flag := 'Y';
					OPEN cur_ItemUom(p_inventory_item_id_tab(i),p_rate_organization_id_tab(i));
					FETCH cur_ItemUom INTO
						l_new_uom ;
					CLOSE cur_ItemUom;
					If l_new_uom is NULL Then
						/* derive uom based on the expenditure type */
						If p_expenditure_type_tab(i) is NOT NULL Then
						    OPEN cur_expRateFlag(p_expenditure_type_tab(i));
						    FETCH cur_expRateFlag INTO
							l_dummy_rate_based_flag
							,l_new_uom ;
						    CLOSE cur_expRateFlag;
						End If;
					End If;
				Elsif p_expenditure_type_tab(i) is NOT NULL Then
					OPEN cur_expRateFlag(p_expenditure_type_tab(i));
					FETCH cur_expRateFlag INTO
						l_new_rate_based_flag
						,l_new_uom ;
					CLOSE cur_expRateFlag;
				Else
					l_new_rate_based_flag := 'N' ;
				End If;
			ElsIf p_resource_class_code_tab(i) in ('FINANCIAL_ELEMENTS') Then
				IF p_expenditure_type_tab(i) is NOT NULL Then
					OPEN cur_expRateFlag(p_expenditure_type_tab(i));
                                        FETCH cur_expRateFlag INTO
                                                l_new_rate_based_flag
						,l_new_uom ;
                                        CLOSE cur_expRateFlag;
				Else 	--!!!!expenditure type is null
					l_new_rate_based_flag := 'N' ;
					l_new_uom := p_old_UOM_tab(i);
				End If;

			Else -- no resource class
				l_new_rate_based_flag := 'N' ;
			End If;
			/* Assign the local variable to Out param */
			x_new_rate_based_flag_tab(i) := l_new_rate_based_flag;
			x_rate_based_flag_changed_tab(i) := 'N';
			If NVL(p_old_rate_based_flag_tab(i),'N') <> NVL(x_new_rate_based_flag_tab(i),'N') Then
				x_rate_based_flag_changed_tab(i) := 'Y';
			End If;

			If l_new_uom is NULL Then
			        l_new_uom := NVL(p_old_UOM_tab(i),'DOLLARS');
			End IF;
			x_new_uom_tab(i) := l_new_uom;
			x_uom_changed_flag_tab(i) := 'N';
			If NVL(p_old_uom_tab(i),'DOLLARS') <> NVL(x_new_uom_tab(i),'DOLLARS') Then
				x_uom_changed_flag_tab(i) := 'Y';
			End IF;
			l_stage := 'OutParams Are NewUOM['||x_new_uom_tab(i)||
				']NewRateFlag['||x_new_rate_based_flag_tab(i)||
				']UomChangedFlag['||x_uom_changed_flag_tab(i)||
				']RateChangedFlag['||x_rate_based_flag_changed_tab(i)||
				']';
			print_msg(l_debug_flag,l_proc_name,l_stage);
		END LOOP;
	END IF;

	x_return_status := l_return_status;
	l_stage := 'End of Get_UOM_RateBasedFlag RetnSts['||x_return_status||']';
	print_msg(l_debug_flag,l_proc_name,l_stage);

IF p_pa_debug_mode = 'Y' THEN
	PA_DEBUG.reset_err_stack;
END IF;
EXCEPTION
	WHEN OTHERS THEN
IF p_pa_debug_mode = 'Y' THEN
		PA_DEBUG.write_file('LOG','Failed in Get_UOM_RateBasedFlag['||SQLCODE||SQLERRM);
END IF;
		print_msg(l_debug_flag,l_proc_name,'Failed in Get_UOM_RateBasedFlag['||SQLCODE||SQLERRM);
IF p_pa_debug_mode = 'Y' THEN
		PA_DEBUG.reset_err_stack;
END IF;
		Raise;

END Get_UOM_RateBasedFlag;

/* This API derives the rejection code flags from budget lines for the given
 * resource_assignment_id and txn_currency_code
 * The out variables will be set to 'Y' if there is any rejection else it is 'N'
 */
PROCEDURE Get_BdgtLineRejFlags
		(p_resource_assignment_id   IN  Number
		,p_txn_currency_code        IN  Varchar2
		,p_budget_version_id        IN  Number
	        ,p_start_date               IN  Date    default Null
                ,p_end_date                 IN  Date    default Null
		,x_cost_rejection_flag      OUT NOCOPY  Varchar2
		,x_burden_rejection_flag    OUT NOCOPY  Varchar2
		,x_revenue_rejection_flag   OUT NOCOPY  Varchar2
		,x_pc_conv_rejection_flag   OUT NOCOPY  Varchar2
		,x_pfc_conv_rejection_flag  OUT NOCOPY  Varchar2
		,x_other_rejection_flag     OUT NOCOPY  Varchar2
		,x_return_status            OUT NOCOPY  Varchar2
		) IS

	l_stage  varchar2(1000);
	l_cost_rejection_flag      Varchar2(10);
        l_burden_rejection_flag    Varchar2(10);
        l_revenue_rejection_flag   Varchar2(10);
        l_pc_conv_rejection_flag   Varchar2(10);
        l_pfc_conv_rejection_flag  Varchar2(10);
        l_other_rejection_flag     Varchar2(10);
	l_proc_name                Varchar2(100) := 'Get_BdgtLineRejFlags';

	CURSOR cur_bdgtRejFlags IS
	SELECT DISTINCT NVL(bl.cost_rejection_flag,'N')
	      ,NVL(bl.burden_rejection_flag,'N')
	      ,NVL(bl.revenue_rejection_flag,'N')
	      ,NVL(bl.pc_conv_rejection_flag,'N')
	      ,NVL(bl.pfc_conv_rejection_flag,'N')
	      ,NVL(bl.other_rejection_flag,'N')
	FROM pa_fp_budget_line_rejections_v bl
	WHERE bl.budget_version_id = p_budget_version_id
	AND   bl.resource_assignment_id = p_resource_assignment_id
	AND   bl.txn_currency_code = p_txn_currency_code
        AND   (bl.cost_rejection_code is NOT NULL
		OR bl.burden_rejection_code is NOT NULL
		OR bl.revenue_rejection_code is NOT NULL
		OR bl.pc_cur_conv_rejection_code is NOT NULL
		OR bl.pfc_cur_conv_rejection_code is NOT NULL
                OR bl.other_rejection_code is NOT NULL -- Bug 5203622
	      );

        CURSOR cur_bdgtPeriodRejFlags IS
        SELECT DISTINCT NVL(bl.period_cost_rejection_flag,'N')
              ,NVL(bl.period_burden_rejection_flag,'N')
              ,NVL(bl.period_revenue_rejection_flag,'N')
              ,NVL(bl.period_pc_conv_rejection_flag,'N')
              ,NVL(bl.period_pfc_conv_rejection_flag,'N')
              ,NVL(bl.period_other_rejection_flag,'N')
        FROM pa_fp_budget_line_rejections_v bl
        WHERE bl.budget_version_id = p_budget_version_id
        AND   bl.resource_assignment_id = p_resource_assignment_id
        AND   bl.txn_currency_code = p_txn_currency_code
	AND   bl.start_date between trunc(p_start_date) AND trunc(p_end_date)
	AND   bl.end_date between trunc(p_start_date) AND trunc(p_end_date)
        AND   (bl.cost_rejection_code is NOT NULL
                OR bl.burden_rejection_code is NOT NULL
                OR bl.revenue_rejection_code is NOT NULL
                OR bl.pc_cur_conv_rejection_code is NOT NULL
                OR bl.pfc_cur_conv_rejection_code is NOT NULL
                OR bl.other_rejection_code is NOT NULL -- Bug 5203622
              );


BEGIN
	l_stage := 'Begin Get_BdgtLineRejFlags IN Params:ResAssn['||p_resource_assignment_id||
		  ']TxnCurr['||p_txn_currency_code||']BdgtVer['||p_budget_version_id||']';
	print_msg(g_debug_flag,l_proc_name,l_stage);

	x_return_status := 'S';

	/* open the cursor and fetch values into out variables */
	IF p_start_date is NULL OR p_end_date is NULL Then
		OPEN cur_bdgtRejFlags;
		FETCH cur_bdgtRejFlags INTO
			l_cost_rejection_flag
              		,l_burden_rejection_flag
              		,l_revenue_rejection_flag
              		,l_pc_conv_rejection_flag
              		,l_pfc_conv_rejection_flag
              		,l_other_rejection_flag ;
		CLOSE cur_bdgtRejFlags;
	Else
		/* set the start and end dates for the global variables to return to the function */
		pa_fin_plan_utils2.g_bdgt_start_date := p_start_date;
		pa_fin_plan_utils2.g_bdgt_end_date   := p_end_date;

                OPEN cur_bdgtPeriodRejFlags;
                FETCH cur_bdgtPeriodRejFlags INTO
                        l_cost_rejection_flag
                        ,l_burden_rejection_flag
                        ,l_revenue_rejection_flag
                        ,l_pc_conv_rejection_flag
                        ,l_pfc_conv_rejection_flag
                        ,l_other_rejection_flag ;
                CLOSE cur_bdgtPeriodRejFlags;
	End If;

	/* set the values to N in case of cursor not found */
	x_cost_rejection_flag     := NVL(l_cost_rejection_flag,'N');
        x_burden_rejection_flag   := NVL(l_burden_rejection_flag,'N');
        x_revenue_rejection_flag  := NVL(l_revenue_rejection_flag,'N');
        x_pc_conv_rejection_flag  := NVL(l_pc_conv_rejection_flag,'N');
        x_pfc_conv_rejection_flag := NVL(l_pfc_conv_rejection_flag,'N');
        x_other_rejection_flag    := NVL(l_other_rejection_flag,'N');

	l_stage := 'End of Get_BdgtLineRejFlags: Cost['||x_cost_rejection_flag||']Burden['||x_burden_rejection_flag||
		']revenue['||x_revenue_rejection_flag ||']PC['||x_pc_conv_rejection_flag ||']PFC['||x_pfc_conv_rejection_flag||
		']Others['||x_other_rejection_flag||']' ;
	print_msg(g_debug_flag,l_proc_name,l_stage);
	Return;

EXCEPTION
	WHEN OTHERS THEN
		x_return_status := 'U';
		RAISE;

END Get_BdgtLineRejFlags;


/* This API derives the rejection reason from budget lines for the given
 * resource_assignment_id and txn_currency_code,Start_date, end_date
 * The out variable will be an array of messages corresponding to the
 * budget line rejection codes
 */
PROCEDURE Get_BdgtLineRejctions
                (p_resource_assignment_id   IN  Number
                ,p_txn_currency_code        IN  Varchar2
                ,p_budget_version_id        IN  Number
		,p_start_date               IN  Date
		,p_end_date                 IN  Date
		,x_period_name_tab              OUT NOCOPY  SYSTEM.PA_VARCHAR2_80_TBL_TYPE
                ,x_cost_rejection_data_tab      OUT NOCOPY  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE
                ,x_burden_rejection_data_tab    OUT NOCOPY  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE
                ,x_revenue_rejection_data_tab   OUT NOCOPY  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE
                ,x_pc_conv_rejection_data_tab   OUT NOCOPY  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE
                ,x_pfc_conv_rejection_data_tab  OUT NOCOPY  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE
                ,x_other_rejection_data_tab     OUT NOCOPY  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE
                ,x_return_status                OUT NOCOPY  Varchar2
                ) IS
	l_stage 			VARCHAR2(2000);
	l_tab_project_id 		SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
	l_tab_budget_version_id   	SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
	l_tab_res_assignment_id   	SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
	l_tab_period_name         	SYSTEM.PA_VARCHAR2_80_TBL_TYPE := SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
	l_tab_start_date                SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE();
	l_tab_end_date                  SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE();
	l_tab_cost_rejection_code 	SYSTEM.PA_VARCHAR2_80_TBL_TYPE := SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
	l_tab_burd_rejection_code 	SYSTEM.PA_VARCHAR2_80_TBL_TYPE := SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
	l_tab_revn_rejection_code 	SYSTEM.PA_VARCHAR2_80_TBL_TYPE := SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
	l_tab_pc_rejection_code   	SYSTEM.PA_VARCHAR2_80_TBL_TYPE := SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
	l_tab_pfc_rejection_code  	SYSTEM.PA_VARCHAR2_80_TBL_TYPE := SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
	l_tab_othr_rejection_code 	SYSTEM.PA_VARCHAR2_80_TBL_TYPE := SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
    	l_tab_cost_rejection_data       SYSTEM.PA_VARCHAR2_2000_TBL_TYPE := SYSTEM.PA_VARCHAR2_2000_TBL_TYPE();
    	l_tab_burd_rejection_data       SYSTEM.PA_VARCHAR2_2000_TBL_TYPE := SYSTEM.PA_VARCHAR2_2000_TBL_TYPE();
    	l_tab_revn_rejection_data       SYSTEM.PA_VARCHAR2_2000_TBL_TYPE := SYSTEM.PA_VARCHAR2_2000_TBL_TYPE();
    	l_tab_pc_rejection_data         SYSTEM.PA_VARCHAR2_2000_TBL_TYPE := SYSTEM.PA_VARCHAR2_2000_TBL_TYPE();
    	l_tab_pfc_rejection_data        SYSTEM.PA_VARCHAR2_2000_TBL_TYPE := SYSTEM.PA_VARCHAR2_2000_TBL_TYPE();
    	l_tab_othr_rejection_data       SYSTEM.PA_VARCHAR2_2000_TBL_TYPE := SYSTEM.PA_VARCHAR2_2000_TBL_TYPE();

	l_proc_name   varchar2(100) := 'Get_BdgtLineRejctions';

	CURSOR cur_BdgtRejctions IS
	SELECT  bl.project_id
		,bl.budget_version_id
        	,bl.resource_assignment_id
        	,bl.period_name
        	,bl.start_date
        	,bl.end_date
        	,bl.cost_rejection_code
        	,bl.burden_rejection_code
        	,bl.revenue_rejection_code
        	,bl.pc_cur_conv_rejection_code
        	,bl.pfc_cur_conv_rejection_code
        	,bl.other_rejection_code
        	,decode(bl.cost_rejection_code,NULL,NULL,
			bl.period_name||':'||(substr(bl.cost_rejection_msg_data,instr(bl.cost_rejection_msg_data,';',-1)+1)))
        	,decode(bl.burden_rejection_code,NULL,NULL,
			bl.period_name||':'||(substr(bl.burden_rejection_msg_data,instr(bl.burden_rejection_msg_data,';',-1)+1)))
        	,decode(bl.revenue_rejection_code,NULL,NULL,
			bl.period_name||':'||(substr(bl.revenue_rejection_msg_data,instr(bl.revenue_rejection_msg_data,';',-1)+1)))
        	,decode(bl.pc_cur_conv_rejection_code,NULL,NULL,
			bl.period_name||':'||(substr(bl.pc_conv_rejection_msg_data,instr(bl.pc_conv_rejection_msg_data,';',-1)+1)))
        	,decode(bl.pfc_cur_conv_rejection_code,NULL,NULL,
			bl.period_name||':'||(substr(bl.pfc_conv_rejection_msg_data,instr(bl.pfc_conv_rejection_msg_data,';',-1)+1)))
        	,decode(bl.other_rejection_code,NULL,NULL,
			bl.period_name||':'||(substr(bl.other_rejection_msg_data,instr(bl.other_rejection_msg_data,';',-1)+1)))
        FROM pa_fp_budget_line_rejections_v bl
        WHERE bl.budget_version_id = p_budget_version_id
        AND   bl.resource_assignment_id = p_resource_assignment_id
        AND   bl.txn_currency_code = p_txn_currency_code
	AND   bl.start_date BETWEEN trunc(p_start_date) AND trunc(p_end_date)
	AND   bl.end_date   BETWEEN trunc(p_start_date) AND trunc(p_end_date) ;

BEGIN
        l_stage := 'Begin Get_BdgtLineRejctions IN Params:ResAssn['||p_resource_assignment_id||
                  ']TxnCurr['||p_txn_currency_code||']BdgtVer['||p_budget_version_id||']SD['||p_start_date||
		  ']ED['||p_end_date||']';
        print_msg(g_debug_flag,l_proc_name,l_stage);

        x_return_status := 'S';
	/* Initialize the out varrys */
	x_period_name_tab              := system.PA_VARCHAR2_80_TBL_TYPE();
	x_cost_rejection_data_tab      := system.PA_VARCHAR2_2000_TBL_TYPE();
    	x_burden_rejection_data_tab    := system.PA_VARCHAR2_2000_TBL_TYPE();
    	x_revenue_rejection_data_tab   := system.PA_VARCHAR2_2000_TBL_TYPE();
    	x_pc_conv_rejection_data_tab   := system.PA_VARCHAR2_2000_TBL_TYPE();
    	x_pfc_conv_rejection_data_tab  := system.PA_VARCHAR2_2000_TBL_TYPE();
    	x_other_rejection_data_tab     := system.PA_VARCHAR2_2000_TBL_TYPE();


		OPEN cur_BdgtRejctions;
		FETCH cur_BdgtRejctions BULK COLLECT INTO
		 	l_tab_project_id
        		,l_tab_budget_version_id
        		,l_tab_res_assignment_id
        		,l_tab_period_name
        		,l_tab_start_date
        		,l_tab_end_date
        		,l_tab_cost_rejection_code
        		,l_tab_burd_rejection_code
        		,l_tab_revn_rejection_code
        		,l_tab_pc_rejection_code
        		,l_tab_pfc_rejection_code
        		,l_tab_othr_rejection_code
        		,l_tab_cost_rejection_data
        		,l_tab_burd_rejection_data
        		,l_tab_revn_rejection_data
        		,l_tab_pc_rejection_data
        		,l_tab_pfc_rejection_data
        		,l_tab_othr_rejection_data
			;
		CLOSE cur_BdgtRejctions;

	l_stage := 'Num Of Rows Fetched ['||l_tab_res_assignment_id.count||']';
	print_msg(g_debug_flag,l_proc_name,l_stage);


	/* assign the values to OUT varry */
	x_period_name_tab              := l_tab_period_name;
        x_cost_rejection_data_tab      := l_tab_cost_rejection_data;
        x_burden_rejection_data_tab    := l_tab_burd_rejection_data;
        x_revenue_rejection_data_tab   := l_tab_revn_rejection_data;
        x_pc_conv_rejection_data_tab   := l_tab_pc_rejection_data;
        x_pfc_conv_rejection_data_tab  := l_tab_pfc_rejection_data;
        x_other_rejection_data_tab     := l_tab_othr_rejection_data;


	l_stage := 'End Get_BdgtLineRejections';
	print_msg(g_debug_flag,l_proc_name,l_stage);

EXCEPTION
	WHEN OTHERS THEN
		x_return_status := 'U';
		print_msg('Y',l_proc_name,l_stage||SQLCODE||SQLERRM);
		Raise;

END Get_BdgtLineRejctions;

/* This API returns the default resource list for the given project and Plan type
 * based on the finplan option level code = 'PLAN_TYPE'
 * By Default it gives the Cost resource list attached at the plan type
 * if not found then it returns the Revenue resource list
 */
PROCEDURE Get_Default_FP_Reslist
		(p_project_id  		IN  Number
		,p_fin_plan_type_id  	IN Number   DEFAULT NULL
		,x_res_list_id          OUT NOCOPY  NUMBER
		,x_res_list_name        OUT NOCOPY  Varchar2)
IS
	CURSOR cur_fpReslist IS
	SELECT fp_resource_list_id
	      ,fp_resource_list_type
	FROM pa_fp_options_Reslists_v
	WHERE project_id = p_project_id
	AND   fin_plan_type_id = p_fin_plan_type_id ;

	/* This cursor derives the default resource list associated with the project
         * Logic: get the ResList from project fp options based on the approved cost Plan type
                  for the given project. If no rows found or resList is null then Get the reslist
                  from the current budget versions for the approved cost budget version, if no rows found
                  then get the Resource List from the ResourceList Assignments where default flag is Y
         */
	CURSOR cur_projReslist IS
	select  fp.project_id
       		,1  default_level  --just for ordering purpose
       		,NVL(fp.cost_resource_list_id,fp.all_resource_list_id) Resource_list_id
	from 	pa_proj_fp_options fp
       		,pa_fin_plan_types_b  typ
	where fp.project_id = p_project_id
	and   fp.fin_plan_type_id = typ.fin_plan_type_id
	and   typ.plan_class_code = 'BUDGET'
	and   fp.fin_plan_option_level_code = 'PLAN_TYPE'
	and   NVL(fp.cost_resource_list_id,fp.all_resource_list_id) is NOT NULL
	and   fp.approved_cost_plan_type_flag = 'Y'
	and   rownum = 1
	UNION
	select bv.project_id
      		,2 default_level
      		,bv.resource_list_id
	from pa_budget_versions bv
     		,pa_budget_types bt
	where bv.fin_plan_type_id is Null
	and  bv.budget_type_code = bt.budget_type_code
	and  bt.budget_amount_code = 'C'
	and  bv.current_flag = 'Y'
	and  bv.project_id = p_project_id
	and  rownum =1
	UNION
	Select pp.project_id
	      ,3 Default_level
	      ,rla.resource_list_id
	from  pa_resource_list_assignments rla
              ,pa_resource_list_uses rlu
     	      ,pa_projects_all pp
	where pp.project_id = p_project_id
	and   rla.project_id = pp.project_id
	and   rlu.resource_list_assignment_id = rla.resource_list_assignment_id
	and   rlu.default_flag = 'Y'
	and   rownum = 1
        ORDER BY 1,2;


	l_resource_list_id  Number;
	l_resource_list_type Varchar2(1000);
	l_resource_list_name pa_resource_lists_tl.name%type;
	l_project_id  Number;
	l_default_level  Number;

BEGIN

	If p_fin_plan_type_id is NOT NULL Then
		OPEN cur_fpReslist;
		FETCH cur_fpReslist INTO
			l_resource_list_id
			,l_resource_list_type ;
		CLOSE cur_fpReslist;
	Else
                OPEN cur_ProjReslist;
                FETCH cur_ProjReslist INTO
			l_project_id
			,l_default_level
                        ,l_resource_list_id;
                CLOSE cur_ProjReslist;
	End If;

	x_res_list_id:= l_resource_list_id;

   	If l_resource_list_id is NOT NULL Then
         	select name
         	into   l_resource_list_name
         	from   pa_resource_lists_tl
         	where  resource_list_id = l_resource_list_id
                and    language = userenv('LANG');


		x_res_list_name:= l_resource_list_name;
	End If;

END Get_Default_FP_Reslist;

/* This API derives the default Resource list used in the WorkPlan structure
 * for the given project Id
 */
-- Changed this api structure for bugfix # 3680252.
PROCEDURE Get_Default_WP_ResList
        (p_project_id           IN Number
        ,p_wps_version_id       IN Number default NULL
        ,x_res_list_id          OUT NOCOPY  NUMBER
        ,x_res_list_name        OUT NOCOPY  Varchar2)
IS

	l_resource_list_id   Number;
	l_resource_list_name pa_resource_lists_tl.name%type;

BEGIN
        l_resource_list_id := PA_TASK_ASSIGNMENT_UTILS.Get_WP_Resource_List_Id(p_project_id);

        If l_resource_list_id is not null then
           select name
           into   l_resource_list_name
           from   pa_resource_lists_v
           where  resource_list_id = l_resource_list_id;
        End if;

	x_res_list_id  := l_resource_list_id;
	x_res_list_name:= l_resource_list_name;

END Get_Default_WP_ResList;

/* This cursor derives the default resource list associated with the project
 * Logic: get the ResList from project fp options based on the approved cost Plan type
          for the given project. If no rows found or resList is null then Get the reslist
          from the current budget versions for the approved cost budget version, if no rows found
          then get the Resource List from the project_types
*/
PROCEDURE Get_Default_Project_ResList
                (p_project_id           IN  Number
                ,x_res_list_id          OUT NOCOPY  NUMBER
                ,x_res_list_name        OUT NOCOPY  Varchar2) IS

BEGIN
 	PA_FIN_PLAN_UTILS2.Get_Default_FP_Reslist
                (p_project_id           => p_project_id
                ,p_fin_plan_type_id     => NULL
                ,x_res_list_id          => x_res_list_id
                ,x_res_list_name        => x_res_list_name
		);

END Get_Default_Project_ResList;

/* This API adds the messages to the error stack */
PROCEDURE AddMsgtoStack
	(p_msg_code 		IN VARCHAR2
        ,p_project_token 	IN VARCHAR2
        ,p_task_token 		IN VARCHAR2
        ,p_budgt_token 		IN VARCHAR2
        ,p_resource_token 	IN VARCHAR2
        ,p_currency_token 	IN VARCHAR2
        ,p_date_token     	IN DATE
        ) IS

BEGIN

	pa_utils.Add_Message( p_app_short_name	=> 'PA'
		,p_msg_name	=> p_msg_code
		,p_token1	=> 'PROJECT'
		,p_value1	=> p_project_token
		,p_token2	=> 'TASK'
		,p_value2	=> p_task_token
		,p_token3	=> 'RESOURCE'
		,p_value3	=> p_resource_token
		,p_token4	=> 'CURRENCY'
		,p_value4       => p_currency_token
		,p_token5	=> 'START DATE'
		,p_value5	=> to_char(p_date_token)
			);
EXCEPTION
	WHEN OTHERS THEN
		RAISE;

END AddMsgtoStack;

/* This API derives the rejection reason from budget lines for the given
 * budget version id.The out variable will be an array of messages corresponding to the
 * budget line rejection codes.
 * This procedure is called from AMG apis.
 * x_return_status will be 'S' in case of successful execution 'U' incase of 'Unexpected errors'
 */
PROCEDURE Get_AMG_BdgtLineRejctions
                (p_budget_version_id            IN  Number
		,x_budget_line_id_tab		OUT NOCOPY  PA_PLSQL_DATATYPES.IdTabTyp
                ,x_cost_rejection_data_tab      OUT NOCOPY  PA_PLSQL_DATATYPES.Char2000TabTyp
                ,x_burden_rejection_data_tab    OUT NOCOPY  PA_PLSQL_DATATYPES.Char2000TabTyp
                ,x_revenue_rejection_data_tab   OUT NOCOPY  PA_PLSQL_DATATYPES.Char2000TabTyp
                ,x_pc_conv_rejection_data_tab   OUT NOCOPY  PA_PLSQL_DATATYPES.Char2000TabTyp
                ,x_pfc_conv_rejection_data_tab  OUT NOCOPY  PA_PLSQL_DATATYPES.Char2000TabTyp
                ,x_other_rejection_data_tab     OUT NOCOPY  PA_PLSQL_DATATYPES.Char2000TabTyp
                ,x_return_status                OUT NOCOPY  Varchar2
                ) IS
	l_stage 			VARCHAR2(2000);
	l_tab_project_id 		PA_PLSQL_DATATYPES.IdTabTyp := PA_PLSQL_DATATYPES.EmptyIdTab;
	l_tab_task_id                   PA_PLSQL_DATATYPES.IdTabTyp := PA_PLSQL_DATATYPES.EmptyIdTab;
	l_tab_budget_version_id   	PA_PLSQL_DATATYPES.IdTabTyp := PA_PLSQL_DATATYPES.EmptyIdTab;
	l_tab_budget_line_id   		PA_PLSQL_DATATYPES.IdTabTyp := PA_PLSQL_DATATYPES.EmptyIdTab;
	l_tab_res_assignment_id   	PA_PLSQL_DATATYPES.IdTabTyp := PA_PLSQL_DATATYPES.EmptyIdTab;
	l_tab_period_name         	PA_PLSQL_DATATYPES.Char80TabTyp := PA_PLSQL_DATATYPES.EmptyChar80Tab;
	l_tab_curr_code          	PA_PLSQL_DATATYPES.Char80TabTyp := PA_PLSQL_DATATYPES.EmptyChar80Tab;
	l_tab_start_date                PA_PLSQL_DATATYPES.DateTabTyp := PA_PLSQL_DATATYPES.EmptyDateTab;
	l_tab_end_date                  PA_PLSQL_DATATYPES.DateTabTyp := PA_PLSQL_DATATYPES.EmptyDateTab;
	l_tab_resource_name  		PA_PLSQL_DATATYPES.Char80TabTyp := PA_PLSQL_DATATYPES.EmptyChar80tab;
	l_tab_cost_rejection_code 	PA_PLSQL_DATATYPES.Char80TabTyp := PA_PLSQL_DATATYPES.EmptyChar80tab;
	l_tab_burd_rejection_code 	PA_PLSQL_DATATYPES.Char80TabTyp := PA_PLSQL_DATATYPES.EmptyChar80tab;
	l_tab_revn_rejection_code 	PA_PLSQL_DATATYPES.Char80TabTyp := PA_PLSQL_DATATYPES.EmptyChar80tab;
	l_tab_pc_rejection_code   	PA_PLSQL_DATATYPES.Char80TabTyp := PA_PLSQL_DATATYPES.EmptyChar80tab;
	l_tab_pfc_rejection_code  	PA_PLSQL_DATATYPES.Char80TabTyp := PA_PLSQL_DATATYPES.EmptyChar80tab;
	l_tab_othr_rejection_code 	PA_PLSQL_DATATYPES.Char80TabTyp := PA_PLSQL_DATATYPES.EmptyChar80tab;
    	l_tab_cost_rejection_data       PA_PLSQL_DATATYPES.Char2000TabTyp := PA_PLSQL_DATATYPES.EmptyChar2000tab;
    	l_tab_burd_rejection_data       PA_PLSQL_DATATYPES.Char2000TabTyp := PA_PLSQL_DATATYPES.EmptyChar2000tab;
    	l_tab_revn_rejection_data       PA_PLSQL_DATATYPES.Char2000TabTyp := PA_PLSQL_DATATYPES.EmptyChar2000tab;
    	l_tab_pc_rejection_data         PA_PLSQL_DATATYPES.Char2000TabTyp := PA_PLSQL_DATATYPES.EmptyChar2000tab;
    	l_tab_pfc_rejection_data        PA_PLSQL_DATATYPES.Char2000TabTyp := PA_PLSQL_DATATYPES.EmptyChar2000tab;
    	l_tab_othr_rejection_data       PA_PLSQL_DATATYPES.Char2000TabTyp := PA_PLSQL_DATATYPES.EmptyChar2000tab;

	CURSOR cur_AmgBdgtRejctions IS
	SELECT  bl.project_id
		,bl.task_id
		,bl.budget_version_id
		,bl.budget_line_id
        	,bl.resource_assignment_id
		,bl.resource_list_member_name
		,bl.txn_currency_code
        	,bl.period_name
        	,bl.start_date
        	,bl.end_date
        	,bl.cost_rejection_code
        	,bl.burden_rejection_code
        	,bl.revenue_rejection_code
        	,bl.pc_cur_conv_rejection_code
        	,bl.pfc_cur_conv_rejection_code
        	,bl.other_rejection_code
        	,decode(bl.cost_rejection_code,NULL,NULL,
			  msg1.message_text||':'||bl.project_id||'; '||msg2.message_text||':'||bl.task_id||'; '
		 	||msg3.message_text||':'||bl.resource_list_member_name||'; '||msg4.message_text||':'
			||bl.txn_currency_code||'; '||msg5.message_text||':'||bl.start_date||'; '
			||(substr(bl.cost_rejection_msg_data,instr(bl.cost_rejection_msg_data,';',-1)+1)))
        	,decode(bl.burden_rejection_code,NULL,NULL,
			msg1.message_text||':'||bl.project_id||'; '||msg2.message_text||':'||bl.task_id||'; '
			||msg3.message_text||':'||bl.resource_list_member_name||'; '||msg4.message_text||':'
			||bl.txn_currency_code||'; '||msg5.message_text||':'||bl.start_date||'; '
			||(substr(bl.burden_rejection_msg_data,instr(bl.burden_rejection_msg_data,';',-1)+1)))
        	,decode(bl.revenue_rejection_code,NULL,NULL,
			msg1.message_text||':'||bl.project_id||'; '||msg2.message_text||':'||bl.task_id||'; '
			||msg3.message_text||':'||bl.resource_list_member_name||'; '||msg4.message_text||':'
			||bl.txn_currency_code||'; '||msg5.message_text||':'||bl.start_date||'; '
			||(substr(bl.revenue_rejection_msg_data,instr(bl.revenue_rejection_msg_data,';',-1)+1)))
        	,decode(bl.pc_cur_conv_rejection_code,NULL,NULL,
			msg1.message_text||':'||bl.project_id||'; '||msg2.message_text||':'||bl.task_id||'; '
			||msg3.message_text||':'||bl.resource_list_member_name||'; '||msg4.message_text||':'
			||bl.txn_currency_code||'; '||msg5.message_text||':'||bl.start_date||'; '
			||(substr(bl.pc_conv_rejection_msg_data,instr(bl.pc_conv_rejection_msg_data,';',-1)+1)))
        	,decode(bl.pfc_cur_conv_rejection_code,NULL,NULL,
			msg1.message_text||':'||bl.project_id||'; '||msg2.message_text||':'||bl.task_id||'; '
			||msg3.message_text||':'||bl.resource_list_member_name||'; '||msg4.message_text||':'
			||bl.txn_currency_code||'; '||msg5.message_text||':'||bl.start_date||'; '
			||(substr(bl.pfc_conv_rejection_msg_data,instr(bl.pfc_conv_rejection_msg_data,';',-1)+1)))
        	,decode(bl.other_rejection_code,NULL,NULL,
			msg1.message_text||':'||bl.project_id||'; '||msg2.message_text||':'||bl.task_id||'; '
			||msg3.message_text||':'||bl.resource_list_member_name||'; '||msg4.message_text||':'
			||bl.txn_currency_code||'; '||msg5.message_text||':'||bl.start_date||'; '
			||(substr(bl.other_rejection_msg_data,instr(bl.other_rejection_msg_data,';',-1)+1)))
        FROM pa_fp_budget_line_rejections_v bl
		,fnd_new_messages msg1
		,fnd_new_messages msg2
		,fnd_new_messages msg3
		,fnd_new_messages msg4
		,fnd_new_messages msg5
        WHERE bl.budget_version_id = p_budget_version_id
        and   msg1.message_name = 'PA_FP_PROJ_LABEL'
        and   msg1.application_id = 275
        and   msg1.language_code = userenv('LANG')
        and   msg2.message_name = 'PA_FP_TASK_LABEL'
        and   msg2.application_id = 275
        and   msg2.language_code = userenv('LANG')
        and   msg3.message_name = 'PA_FP_RES_LABEL'
        and   msg3.application_id = 275
        and   msg3.language_code = userenv('LANG')
        and   msg4.message_name = 'PA_FP_CURR_LABEL'
        and   msg4.application_id = 275
        and   msg4.language_code = userenv('LANG')
        and   msg5.message_name = 'PA_FP_DATE_LABEL'
        and   msg5.application_id = 275
        and   msg5.language_code = userenv('LANG')
	and  ( bl.cost_rejection_code is NOT NULL
	     OR bl.burden_rejection_code is NOT NULL
             OR bl.revenue_rejection_code is NOT NULL
             OR bl.pc_cur_conv_rejection_code is NOT NULL
             OR bl.pfc_cur_conv_rejection_code is NOT NULL
             OR bl.other_rejection_code is NOT NULL
	     );

	l_proc_name    varchar2(200) := 'Get_AMG_BdgtLineRejctions';

BEGIN
        l_stage := 'Begin Get_AMGBdgtLineRejctions IN Params:BdgtVer['||p_budget_version_id||']';
        print_msg(g_debug_flag,l_proc_name,l_stage);
        x_return_status := 'S';
	/* Initialize the out varrys */
	x_budget_line_id_tab.delete;
	x_cost_rejection_data_tab.delete;
    	x_burden_rejection_data_tab.delete;
    	x_revenue_rejection_data_tab.delete;
    	x_pc_conv_rejection_data_tab.delete;
    	x_pfc_conv_rejection_data_tab.delete;
    	x_other_rejection_data_tab.delete;

		OPEN cur_AmgBdgtRejctions;
		FETCH cur_AmgBdgtRejctions BULK COLLECT INTO
		 	l_tab_project_id
			,l_tab_task_id
        		,l_tab_budget_version_id
			,l_tab_budget_line_id
        		,l_tab_res_assignment_id
			,l_tab_resource_name
			,l_tab_curr_code
        		,l_tab_period_name
        		,l_tab_start_date
        		,l_tab_end_date
        		,l_tab_cost_rejection_code
        		,l_tab_burd_rejection_code
        		,l_tab_revn_rejection_code
        		,l_tab_pc_rejection_code
        		,l_tab_pfc_rejection_code
        		,l_tab_othr_rejection_code
        		,l_tab_cost_rejection_data
        		,l_tab_burd_rejection_data
        		,l_tab_revn_rejection_data
        		,l_tab_pc_rejection_data
        		,l_tab_pfc_rejection_data
        		,l_tab_othr_rejection_data
			;
		CLOSE cur_AmgBdgtRejctions;

	l_stage := 'Num Of Rows Fetched ['||l_tab_res_assignment_id.count||']';
	print_msg(g_debug_flag,l_proc_name,l_stage);

	/* loop through each plsql tables and add it to error msg stack if there is any error */
	/****** this is commented out as the calling api will add it to the msg stack
	FOR i IN l_tab_budget_version_id.FIRST .. l_tab_budget_version_id.LAST LOOP
		If l_tab_cost_rejection_code(i) is NOT NULL Then
			AddMsgtoStack(p_msg_code 	=> l_tab_cost_rejection_code(i)
				,p_project_token 	=> l_tab_project_id(i)
				,p_task_token 		=> l_tab_task_id(i)
				,p_budgt_token 		=> l_tab_budget_version_id(i)
				,p_resource_token 	=> l_tab_resource_name(i)
				,p_currency_token 	=> l_tab_curr_code(i)
				,p_date_token     	=> l_tab_start_date(i)
				);
		End If;
		If l_tab_burd_rejection_code(i) is NOT NULL Then
                        AddMsgtoStack(p_msg_code 	=> l_tab_burd_rejection_code(i)
                                ,p_project_token 	=> l_tab_project_id(i)
                                ,p_task_token 		=> l_tab_task_id(i)
                                ,p_budgt_token 		=> l_tab_budget_version_id(i)
                                ,p_resource_token 	=> l_tab_resource_name(i)
                                ,p_currency_token 	=> l_tab_curr_code(i)
                                ,p_date_token     	=> l_tab_start_date(i)
                                );
		End If;
		If l_tab_revn_rejection_code(i) is NOT NULL then
                        AddMsgtoStack(p_msg_code 	=> l_tab_revn_rejection_code(i)
                                ,p_project_token 	=> l_tab_project_id(i)
                                ,p_task_token 		=> l_tab_task_id(i)
                                ,p_budgt_token 		=> l_tab_budget_version_id(i)
                                ,p_resource_token 	=> l_tab_resource_name(i)
                                ,p_currency_token 	=> l_tab_curr_code(i)
                                ,p_date_token     	=> l_tab_start_date(i)
                                );
		End If;
		If l_tab_pc_rejection_code(i) is NOT NULL Then
                        AddMsgtoStack(p_msg_code 	=> l_tab_pc_rejection_code(i)
                                ,p_project_token 	=> l_tab_project_id(i)
                                ,p_task_token 		=> l_tab_task_id(i)
                                ,p_budgt_token 		=> l_tab_budget_version_id(i)
                                ,p_resource_token 	=> l_tab_resource_name(i)
                                ,p_currency_token 	=> l_tab_curr_code(i)
                                ,p_date_token     	=> l_tab_start_date(i)
                                );
		End If;
		If l_tab_pfc_rejection_code(i) is NOT NULL Then
                        AddMsgtoStack(p_msg_code 	=> l_tab_pfc_rejection_code(i)
                                ,p_project_token 	=> l_tab_project_id(i)
                                ,p_task_token 		=> l_tab_task_id(i)
                                ,p_budgt_token 		=> l_tab_budget_version_id(i)
                                ,p_resource_token 	=> l_tab_resource_name(i)
                                ,p_currency_token 	=> l_tab_curr_code(i)
                                ,p_date_token     	=> l_tab_start_date(i)
                                );
		End If;
		If l_tab_othr_rejection_code(i) is NOT NULL Then
                        AddMsgtoStack(p_msg_code 	=> l_tab_othr_rejection_code(i)
                                ,p_project_token 	=> l_tab_project_id(i)
                                ,p_task_token 		=> l_tab_task_id(i)
                                ,p_budgt_token 		=> l_tab_budget_version_id(i)
                                ,p_resource_token 	=> l_tab_resource_name(i)
                                ,p_currency_token 	=> l_tab_curr_code(i)
                                ,p_date_token     	=> l_tab_start_date(i)
                                );
		End If;
	END LOOP;
	*/

	/* assign the values to OUT varry */
	x_budget_line_id_tab 	       := l_tab_budget_line_id;
        x_cost_rejection_data_tab      := l_tab_cost_rejection_data;
        x_burden_rejection_data_tab    := l_tab_burd_rejection_data;
        x_revenue_rejection_data_tab   := l_tab_revn_rejection_data;
        x_pc_conv_rejection_data_tab   := l_tab_pc_rejection_data;
        x_pfc_conv_rejection_data_tab  := l_tab_pfc_rejection_data;
        x_other_rejection_data_tab     := l_tab_othr_rejection_data;

	l_stage := 'End Get_BdgtLineRejections';
	print_msg(g_debug_flag,l_proc_name,l_stage);

EXCEPTION
	WHEN OTHERS THEN
		x_return_status := 'U';
		print_msg('Y',l_proc_name,l_stage||SQLCODE||SQLERRM);
		Raise;

END Get_AMG_BdgtLineRejctions;

FUNCTION GetPeriodMask(p_period_name  IN VARCHAR2)
RETURN varchar2 IS

BEGIN
	Return p_period_name;

END GetPeriodMask;

/* THIS API is called from EditBudgetLineDetails.java page
 * This api validates the currency conversion parameters and updates the pa_budget_lines table
 * if there is any changes in the currency conversion attributes, it calls calculate api ()
 * THIS API SHOULD NOT BE CALLED FROM ANY OTHER SOURCE, IF SO ALL THE PARAMETER VALUES MUST BE PASSED
 * This api will not default any parameter values. This is similar to a table handler
 */
PROCEDURE validateAndUpdateBdgtLine(
			p_budget_line_id                        IN Number
                       ,p_BDGT_VERSION_ID             		IN Number
                       ,p_RES_ASSIGNMENT_ID           		IN Number
                       ,p_TXN_CURRENCY_CODE           		IN Varchar2
                       ,p_START_DATE                  		IN Date
                       ,p_END_DATE                    		IN Date
                       ,P_CALLING_CONTEXT             		IN Varchar2
                       ,P_ORG_ID                      		IN Number
                       ,p_PLAN_VERSION_TYPE           		IN Varchar2
                       ,p_PROJFUNC_CURRENCY_CODE     		IN Varchar2
                       ,p_PROJFUNC_COST_RATE_TYPE     		IN Varchar2
                       ,p_PROJFUNC_COST_EXCHANGE_RATE 		IN Number
                       ,p_PROJFUNC_COST_RATE_DATE_TYPE		IN Varchar2
                       ,p_PROJFUNC_COST_RATE_DATE      		IN Date
                       ,p_PROJFUNC_REV_RATE_TYPE       		IN Varchar2
                       ,p_PROJFUNC_REV_EXCHANGE_RATE   		IN Number
                       ,p_PROJFUNC_REV_RATE_DATE_TYPE  		IN Varchar2
                       ,p_PROJFUNC_REV_RATE_DATE       		IN Date
                       ,p_PROJECT_CURRENCY_CODE        		IN Varchar2
                       ,p_PROJECT_COST_RATE_TYPE       		IN Varchar2
                       ,p_PROJECT_COST_EXCHANGE_RATE   		IN Number
                       ,p_PROJECT_COST_RATE_DATE_TYPE  		IN Varchar2
                       ,p_PROJECT_COST_RATE_DATE       		IN Date
                       ,p_PROJECT_REV_RATE_TYPE        		IN Varchar2
                       ,p_PROJECT_REV_EXCHANGE_RATE    		IN Number
                       ,p_PROJECT_REV_RATE_DATE_TYPE  		IN Varchar2
                       ,p_PROJECT_REV_RATE_DATE        		IN Date
                       ,p_CHANGE_REASON_CODE           		IN Varchar2
                       ,p_DESCRIPTION                  		IN Varchar2
                       ,p_ATTRIBUTE_CATEGORY           		IN Varchar2
                       ,p_ATTRIBUTE1                   		IN Varchar2
                       ,p_ATTRIBUTE2                  		IN Varchar2
                       ,p_ATTRIBUTE3                            IN Varchar2
                       ,p_ATTRIBUTE4                            IN Varchar2
                       ,p_ATTRIBUTE5                            IN Varchar2
                       ,p_ATTRIBUTE6                            IN Varchar2
                       ,p_ATTRIBUTE7                            IN Varchar2
                       ,p_ATTRIBUTE8                            IN Varchar2
                       ,p_ATTRIBUTE9                            IN Varchar2
                       ,p_ATTRIBUTE10                           IN Varchar2
                       ,p_ATTRIBUTE11                           IN Varchar2
                       ,p_ATTRIBUTE12                           IN Varchar2
                       ,p_ATTRIBUTE13                           IN Varchar2
                       ,p_ATTRIBUTE14                           IN Varchar2
                       ,p_ATTRIBUTE15                           IN Varchar2
                       ,p_CI_ID                                 IN Number
                       ,x_return_status                         OUT NOCOPY Varchar2
                       ,x_msg_data                              OUT NOCOPY Varchar2
                       ,x_msg_count                             OUT NOCOPY Number
			) IS

	cursor check_bdgtLine_changed IS
        SELECT 	project_currency_code
		,project_cost_rate_type
		,project_cost_rate_date
                ,project_cost_rate_date_type
		,project_cost_exchange_rate
                ,project_rev_rate_type
                ,project_rev_rate_date
                ,project_rev_rate_date_type
                ,project_rev_exchange_rate
		,projfunc_currency_code
                ,projfunc_cost_rate_type
                ,projfunc_cost_rate_date
                ,projfunc_cost_rate_date_type
                ,projfunc_cost_exchange_rate
                ,projfunc_rev_rate_type
                ,projfunc_rev_rate_date
                ,projfunc_rev_rate_date_type
                ,projfunc_rev_exchange_rate
	FROM pa_budget_lines
	Where budget_line_id = p_budget_line_id;

	Cursor projDetails IS
	Select bv.project_id
		,bv.etc_start_date
		,bv.version_type
	From pa_budget_versions bv
	Where bv.budget_version_id = p_bdgt_version_id;

	l_stage    varchar2(1000);
	l_call_calculate_api   Varchar2(1) := 'N';
	l_error_msg_code       Varchar2(1000) := Null;
	l_msg_count            Number := 0;
	l_return_status        Varchar2(100) := 'S';
	l_msg_index_out        Number := 0;
	l_rowcount             Number := 0;
	l_project_id           Number := 0;
	l_etc_start_date       Date;
	l_plan_version_type    Varchar2(100);

	l_resource_assignment_tab system.pa_num_tbl_type   := system.pa_num_tbl_type();
        l_txn_currency_code_tab   system.pa_varchar2_15_tbl_type := system.pa_varchar2_15_tbl_type();
        l_line_start_date_tab     SYSTEM.pa_date_tbl_type        := SYSTEM.pa_date_tbl_type();
        l_line_end_date_tab       SYSTEM.pa_date_tbl_type        := SYSTEM.pa_date_tbl_type();

	/* Bug fix: 3964805 Declare the local variables as IN params cannot be assigned */
        l_PROJFUNC_COST_RATE_TYPE               Varchar2(100);
        l_PROJFUNC_COST_EXCHANGE_RATE           Number;
        l_PROJFUNC_COST_RATE_DATE_TYPE          Varchar2(100);
        l_PROJFUNC_COST_RATE_DATE               Date;
        l_PROJFUNC_REV_RATE_TYPE                Varchar2(100);
        l_PROJFUNC_REV_EXCHANGE_RATE            Number;
        l_PROJFUNC_REV_RATE_DATE_TYPE           Varchar2(100);
        l_PROJFUNC_REV_RATE_DATE                Date;

        l_PROJECT_COST_RATE_TYPE                Varchar2(100);
        l_PROJECT_COST_EXCHANGE_RATE            Number;
        l_PROJECT_COST_RATE_DATE_TYPE           Varchar2(100);
        l_PROJECT_COST_RATE_DATE                Date;
        l_PROJECT_REV_RATE_TYPE                 Varchar2(100);
        l_PROJECT_REV_EXCHANGE_RATE             Number;
        l_PROJECT_REV_RATE_DATE_TYPE            Varchar2(100);
        l_PROJECT_REV_RATE_DATE                 Date;


	l_proc_name   varchar2(100) := 'validateAndUpdateBdgtLine';

	FUNCTION getMsgtext(p_msg_name IN Varchar2) Return Varchar2 IS

        	Cursor getMsgDetails IS
        	Select substr(msg.message_text,instr(msg.message_text,';',-1)+1) message_text
        	From fnd_new_messages msg
        	Where msg.application_id = 275
        	And   msg.message_name = p_msg_name
        	And   msg.language_code = userenv('LANG');

		l_msg_text   Varchar2(1000);
	BEGIN
		OPEN getMsgDetails;
		FETCH getMsgDetails INTO l_msg_text;
		CLOSE getMsgDetails;
		RETURN l_msg_text;

	END getMsgtext ;
BEGIN
        --- Initialize the error statck
	IF p_pa_debug_mode = 'Y' THEN
        	PA_DEBUG.init_err_stack ('PA_FIN_PLAN_UTILS2.validateAndUpdateBdgtLine');
	END IF;
        fnd_profile.get('PA_DEBUG_MODE',g_debug_flag);
        g_debug_flag := NVL(g_debug_flag, 'N');

	IF p_pa_debug_mode = 'Y' THEN
        PA_DEBUG.SET_PROCESS( x_process => 'PLSQL'
                      ,x_write_file     => 'LOG'
                      ,x_debug_mode      => g_debug_flag
                          );
	END IF;
	/* Initialize the out params */
	x_return_status := 'S';
	x_msg_data := Null;
	x_msg_count := 0;

        /** clear the message stack **/
        fnd_msg_pub.INITIALIZE;

	l_stage := 'Inside validateAndUpdateBdgtLine API BdgtLineId['||p_budget_line_id||']ResAssingID['||p_res_assignment_id||
		']txnCurrCode['||p_txn_currency_code||']StartDate['||p_start_date||']EndDate['||p_end_date||']BdgtVerId['||p_BDGT_VERSION_ID||
		 ']PlanVerType['||p_plan_version_type||']Callingcontext['||p_calling_context||']';
	print_msg(g_debug_flag,l_proc_name,l_stage);

        OPEN projDetails;
        FETCH projDetails INTO
		l_project_id
		,l_etc_start_date
		,l_plan_version_type;
        CLOSE projDetails;

	/* Bug fix: 3964805 Initialize the local variables */
        l_PROJFUNC_COST_RATE_TYPE := p_PROJFUNC_COST_RATE_TYPE;
        l_PROJFUNC_COST_EXCHANGE_RATE := p_PROJFUNC_COST_EXCHANGE_RATE;
        l_PROJFUNC_COST_RATE_DATE_TYPE := p_PROJFUNC_COST_RATE_DATE_TYPE;
        l_PROJFUNC_COST_RATE_DATE := p_PROJFUNC_COST_RATE_DATE;
        l_PROJFUNC_REV_RATE_TYPE := p_PROJFUNC_REV_RATE_TYPE;
        l_PROJFUNC_REV_EXCHANGE_RATE := p_PROJFUNC_REV_EXCHANGE_RATE;
        l_PROJFUNC_REV_RATE_DATE_TYPE := p_PROJFUNC_REV_RATE_DATE_TYPE;
        l_PROJFUNC_REV_RATE_DATE :=p_PROJFUNC_REV_RATE_DATE;

        l_PROJECT_COST_RATE_TYPE := p_PROJECT_COST_RATE_TYPE;
        l_PROJECT_COST_EXCHANGE_RATE := p_PROJECT_COST_EXCHANGE_RATE;
        l_PROJECT_COST_RATE_DATE_TYPE := p_PROJECT_COST_RATE_DATE_TYPE;
        l_PROJECT_COST_RATE_DATE := p_PROJECT_COST_RATE_DATE;
        l_PROJECT_REV_RATE_TYPE := p_PROJECT_REV_RATE_TYPE;
        l_PROJECT_REV_EXCHANGE_RATE :=p_PROJECT_REV_EXCHANGE_RATE;
        l_PROJECT_REV_RATE_DATE_TYPE := p_PROJECT_REV_RATE_DATE_TYPE;
        l_PROJECT_REV_RATE_DATE := p_PROJECT_REV_RATE_DATE;

	 l_stage := 'BudgetVersionType['||l_PLAN_VERSION_TYPE||']';
	 l_stage := 'Values PassedIn FuncstRatTyp['||l_PROJFUNC_COST_RATE_TYPE||']FuncstRate['||l_PROJFUNC_COST_EXCHANGE_RATE||']';
	 l_stage := l_stage||'Funcstdttype['||l_PROJFUNC_COST_RATE_DATE_TYPE||']Funcdt['||l_PROJFUNC_COST_RATE_DATE||']';
	 l_stage := l_stage||'FuncRevTyp['||l_PROJFUNC_REV_RATE_TYPE||']FuncRt['||l_PROJFUNC_REV_EXCHANGE_RATE||']';
	 l_stage := l_stage||'FuncDttyp['||l_PROJFUNC_REV_RATE_DATE_TYPE||']FuncDt['||l_PROJFUNC_REV_RATE_DATE||']';
	 print_msg(g_debug_flag,l_proc_name,l_stage);

	 l_stage := 'ProjCstRtTyp['||l_PROJECT_COST_RATE_TYPE||']Rate['||l_PROJECT_COST_EXCHANGE_RATE||']Dttyp['||l_PROJECT_COST_RATE_DATE_TYPE||']';
	 l_stage := l_stage||'RtDt['||l_PROJECT_COST_RATE_DATE||']ProjRevRtTyp['||l_PROJECT_REV_RATE_TYPE||']Rt['||l_PROJECT_REV_EXCHANGE_RATE||']';
	 l_stage := l_stage||'RrDtTyp['||l_PROJECT_REV_RATE_DATE_TYPE||']RvDt['||l_PROJECT_REV_RATE_DATE||']';
	 print_msg(g_debug_flag,l_proc_name,l_stage);

	If (p_budget_line_id is not null AND
	    (p_txn_currency_code <> p_project_currency_code OR
             p_txn_currency_code <> p_projfunc_currency_code)) then

		/* Bug fix: 3964805 If PC = PFC then UI should display PFC attributes only and backend copy the
		 * PFC attributes to PC attributes
		 */
		IF p_project_currency_code = p_projfunc_currency_code Then
			-- ignore any changes made to project currency attributes. copy pfc attributes to pc attributes
			l_stage := 'Proj and ProjFunc currencies are Same';
			print_msg(g_debug_flag,l_proc_name,l_stage);
			IF l_PLAN_VERSION_TYPE in ('COST','ALL') Then
				l_PROJECT_COST_RATE_TYPE 	:= l_PROJFUNC_COST_RATE_TYPE;
        			l_PROJECT_COST_EXCHANGE_RATE 	:= l_PROJFUNC_COST_EXCHANGE_RATE;
        			l_PROJECT_COST_RATE_DATE_TYPE 	:= l_PROJFUNC_COST_RATE_DATE_TYPE;
        			l_PROJECT_COST_RATE_DATE 	:= l_PROJFUNC_COST_RATE_DATE;
			End If;

			IF l_PLAN_VERSION_TYPE in ('REVENUE','ALL') Then
        			l_PROJECT_REV_RATE_TYPE 	:= l_PROJFUNC_REV_RATE_TYPE;
        			l_PROJECT_REV_EXCHANGE_RATE 	:= l_PROJFUNC_REV_EXCHANGE_RATE;
        			l_PROJECT_REV_RATE_DATE_TYPE 	:= l_PROJFUNC_REV_RATE_DATE_TYPE;
        			l_PROJECT_REV_RATE_DATE 	:= l_PROJFUNC_REV_RATE_DATE;
                	End If;
		End If;
		/* End of bug fix:3964805 */

		l_stage := 'Trxn Currency PC / PFC are different';
        	print_msg(g_debug_flag,l_proc_name,l_stage);
		FOR i IN check_bdgtLine_changed LOOP
			l_msg_count := 0;
			l_stage := 'Validate currency attributes';
			print_msg(g_debug_flag,l_proc_name,l_stage);
                        IF (NVL(i.project_cost_rate_type,'XX') <> NVL(l_project_cost_rate_type,'XX') OR
                           NVL(i.project_cost_rate_date,trunc(sysdate)) <> NVL(l_project_cost_rate_date,trunc(sysdate)) OR
                           NVL(i.project_cost_rate_date_type,'XX') <> NVL(l_project_cost_rate_date_type,'XX') OR
                           NVL(i.project_cost_exchange_rate,0) <> NVL(l_project_cost_exchange_rate,0)) Then
				l_call_calculate_api := 'Y';
				If NVL(l_project_cost_rate_type,'XX') = 'User' Then
					l_stage := 'Calling checkUserRateAllowed For l_project_cost_rate_type';
					checkUserRateAllowed
                			(p_From_curr_code     => p_txn_currency_code
                			,p_To_curr_code       => p_project_currency_code
                			,p_Conversion_Date    => p_start_date
                			,p_To_Curr_Rate_Type  => l_project_cost_rate_type
                			,p_To_Curr_Exchange_Rate => l_project_cost_exchange_rate
					,p_calling_mode       => 'PC'
					,p_calling_context    => 'COST'
                			,x_return_status      => l_return_status
                			,x_error_msg_code     => l_error_msg_code
                			) ;
				    l_stage :='ReturnSTst['||l_return_status||']l_error_msg_code['||l_error_msg_code||']';
				    print_msg(g_debug_flag,l_proc_name,l_stage);

                                    If l_return_status <> 'S' and nvl(l_error_msg_code,'X') <> 'X' then
				       --l_error_msg_code := getMsgtext(p_msg_name =>l_error_msg_code);
                                       PA_UTILS.ADD_MESSAGE
					    ( p_app_short_name => 'PA'
                                             ,p_msg_name  =>l_error_msg_code
                                            );
                                            l_msg_count := l_msg_count +1;
                		    End if;
				Elsif NVL(l_project_cost_rate_type,'XX') <>  'User' Then
					l_project_cost_exchange_rate := NULL;
				End If; -- end of projcostratetype
			  END IF;

			  IF (NVL(i.project_rev_rate_type,'XX') <> NVL(l_project_rev_rate_type,'XX') OR
                           NVL(i.project_rev_rate_date,trunc(sysdate)) <> NVL(l_project_rev_rate_date,trunc(sysdate)) OR
                           NVL(i.project_rev_rate_date_type,'XX') <> NVL(l_project_rev_rate_date_type,'XX') OR
                           NVL(i.project_rev_exchange_rate,0) <> NVL(l_project_rev_exchange_rate,0)) Then
				l_call_calculate_api := 'Y';
				If NVL(l_project_rev_rate_type,'XX') = 'User' Then
                                        l_stage := 'Calling checkUserRateAllowed For l_project_rev_rate_type';
					print_msg(g_debug_flag,l_proc_name,l_stage);
                                        checkUserRateAllowed
                                        (p_From_curr_code     => p_txn_currency_code
                                        ,p_To_curr_code       => p_project_currency_code
                                        ,p_Conversion_Date    => p_start_date
                                        ,p_To_Curr_Rate_Type  => l_project_rev_rate_type
                                        ,p_To_Curr_Exchange_Rate => l_project_rev_exchange_rate
					,p_calling_mode       => 'PC'
					,p_calling_context    => 'REV'
                                        ,x_return_status      => l_return_status
                                        ,x_error_msg_code     => l_error_msg_code
                                        ) ;
                                    l_stage :='ReturnSTst['||l_return_status||']l_error_msg_code['||l_error_msg_code||']';
                                    print_msg(g_debug_flag,l_proc_name,l_stage);

                                    If l_return_status <> 'S' and nvl(l_error_msg_code,'X') <> 'X' then
				       --l_error_msg_code := getMsgtext(p_msg_name =>l_error_msg_code);
                                       PA_UTILS.ADD_MESSAGE
                                            ( p_app_short_name => 'PA'
                                             ,p_msg_name  =>l_error_msg_code
                                            );
                                            l_msg_count := l_msg_count +1;
                                    End if;
				Elsif NVL(l_project_rev_rate_type,'XX') <> 'User' Then
					l_project_rev_exchange_rate := NULL;
				End If;
			  END IF;

			  IF (NVL(i.projfunc_cost_rate_type,'XX') <> NVL(l_projfunc_cost_rate_type,'XX') OR
                           NVL(i.projfunc_cost_rate_date,trunc(sysdate)) <> NVL(l_projfunc_cost_rate_date,trunc(sysdate)) OR
                           NVL(i.projfunc_cost_rate_date_type,'XX') <> NVL(l_projfunc_cost_rate_date_type,'XX') OR
                           NVL(i.projfunc_cost_exchange_rate,0) <> NVL(l_projfunc_cost_exchange_rate,0)) THEN
				l_call_calculate_api := 'Y';
				If NVL(l_projfunc_cost_rate_type,'XX') = 'User' Then
                                        l_stage := 'Calling checkUserRateAllowed For l_projfunc_cost_rate_type';
					print_msg(g_debug_flag,l_proc_name,l_stage);
                                        checkUserRateAllowed
                                        (p_From_curr_code     => p_txn_currency_code
                                        ,p_To_curr_code       => p_projfunc_currency_code
                                        ,p_Conversion_Date    => p_start_date
                                        ,p_To_Curr_Rate_Type  => l_projfunc_cost_rate_type
                                        ,p_To_Curr_Exchange_Rate => l_projfunc_cost_exchange_rate
					,p_calling_mode       => 'PFC'
					,p_calling_context    => 'COST'
                                        ,x_return_status      => l_return_status
                                        ,x_error_msg_code     => l_error_msg_code
                                        ) ;
                                    l_stage :='ReturnSTst['||l_return_status||']l_error_msg_code['||l_error_msg_code||']';
                                    print_msg(g_debug_flag,l_proc_name,l_stage);

                                    If l_return_status <> 'S' and nvl(l_error_msg_code,'X') <> 'X' then
				       --l_error_msg_code := getMsgtext(p_msg_name =>l_error_msg_code);
                                       PA_UTILS.ADD_MESSAGE
                                            ( p_app_short_name => 'PA'
                                             ,p_msg_name  =>l_error_msg_code
                                            );
                                            l_msg_count := l_msg_count +1;
                                    End if;
				Elsif NVL(l_projfunc_cost_rate_type,'XX') <> 'User' Then
					l_projfunc_cost_exchange_rate := NULL;
				End If;
			  END IF;


			  IF (NVL(i.projfunc_rev_rate_type,'XX') <> NVL(l_projfunc_rev_rate_type,'XX') OR
                           NVL(i.projfunc_rev_rate_date,trunc(sysdate)) <> NVL(l_projfunc_rev_rate_date,trunc(sysdate)) OR
                           NVL(i.projfunc_rev_rate_date_type,'XX') <> NVL(l_projfunc_rev_rate_date_type,'XX') OR
                           NVL(i.projfunc_rev_exchange_rate ,0) <> NVL(l_projfunc_rev_exchange_rate ,0)) THEN
				l_call_calculate_api := 'Y';
				If NVL(l_projfunc_rev_rate_type,'XX') = 'User' Then
                                        l_stage := 'Calling checkUserRateAllowed For l_projfunc_rev_rate_type';
					print_msg(g_debug_flag,l_proc_name,l_stage);
                                        checkUserRateAllowed
                                        (p_From_curr_code     => p_txn_currency_code
                                        ,p_To_curr_code       => p_projfunc_currency_code
                                        ,p_Conversion_Date    => p_start_date
                                        ,p_To_Curr_Rate_Type  => l_projfunc_rev_rate_type
                                        ,p_To_Curr_Exchange_Rate => l_projfunc_rev_exchange_rate
					,p_calling_mode       => 'PFC'
					,p_calling_context    => 'REV'
                                        ,x_return_status      => l_return_status
                                        ,x_error_msg_code     => l_error_msg_code
                                        ) ;
                                    l_stage :='ReturnSTst['||l_return_status||']l_error_msg_code['||l_error_msg_code||']';
                                    print_msg(g_debug_flag,l_proc_name,l_stage);

                                    If l_return_status <> 'S' and nvl(l_error_msg_code,'X') <> 'X' then
				       --l_error_msg_code := getMsgtext(p_msg_name =>l_error_msg_code);
                                       PA_UTILS.ADD_MESSAGE
                                            ( p_app_short_name => 'PA'
                                             ,p_msg_name  =>l_error_msg_code
                                            );
                                            l_msg_count := l_msg_count +1;
                                    End if;
				Elsif NVL(l_projfunc_rev_rate_type,'XX') <> 'User' Then
					l_projfunc_rev_exchange_rate := NULL;
				End If;
			  END IF;
			/* Retrive the msg from stack */
			l_stage := 'Message Count['||l_msg_count||']';
			print_msg(g_debug_flag,l_proc_name,l_stage);
           		If l_msg_count = 1 then
                		  pa_interface_utils_pub.get_messages
                                  ( p_encoded       => FND_API.G_TRUE
                                   ,p_msg_index     => 1
                                   ,p_data          => x_msg_data
                                   ,p_msg_index_out => l_msg_index_out
                                  );
                                   x_return_status := 'E';
                        Elsif l_msg_count > 1 then
                                   x_return_status := 'E';
                                   x_msg_count := l_msg_count;
                                   x_msg_data := null;
                        End if;

		END LOOP;
	End if;

	IF ( x_return_status = 'S' and
           p_res_assignment_id is NOT NULL and
           p_txn_currency_code is NOT NULL and
           p_start_date is NOT NULL and
           p_end_date is NOT NULL ) Then
		l_stage := 'Updateing the budget lines with currency attributes';
		print_msg(g_debug_flag,l_proc_name,l_stage);
		UPDATE pa_budget_lines bl
		SET bl.description = nvl(p_description,bl.description)
		,bl.change_reason_code = nvl(p_change_reason_code,bl.change_reason_code)
		,bl.attribute_category = nvl(p_attribute_category,bl.attribute_category)
		,bl.attribute1 = nvl(p_attribute1,bl.attribute1)
		,bl.attribute2 = nvl(p_attribute2,bl.attribute2)
		,bl.attribute3 = nvl(p_attribute3,bl.attribute3)
		,bl.attribute4 = nvl(p_attribute4,bl.attribute4)
		,bl.attribute5 = nvl(p_attribute5,bl.attribute5)
		,bl.attribute6 = nvl(p_attribute6,bl.attribute6)
		,bl.attribute7 = nvl(p_attribute7,bl.attribute7)
		,bl.attribute8 = nvl(p_attribute8,bl.attribute8)
		,bl.attribute9 = nvl(p_attribute9,bl.attribute9)
		,bl.attribute10 = nvl(p_attribute10,bl.attribute10)
		,bl.attribute11 = nvl(p_attribute11,bl.attribute11)
		,bl.attribute12 = nvl(p_attribute12,bl.attribute12)
		,bl.attribute13 = nvl(p_attribute13,bl.attribute13)
		,bl.attribute14 = nvl(p_attribute14,bl.attribute14)
		,bl.attribute15 = nvl(p_attribute15,bl.attribute15)
		---- cost attributes
		,bl.project_cost_rate_type = decode(p_txn_currency_code,p_project_currency_code,bl.project_cost_rate_type
						,decode(l_plan_version_type,'COST'
						,l_project_cost_rate_type
						,'ALL',l_project_cost_rate_type
						,bl.project_cost_rate_type))
		,bl.project_cost_rate_date_type = decode(p_txn_currency_code,p_project_currency_code,
						 bl.project_cost_rate_date_type,decode(l_plan_version_type,'COST'
						,l_project_cost_rate_date_type
						,'ALL',l_project_cost_rate_date_type
						,bl.project_cost_rate_date_type))
		,bl.project_cost_rate_date = decode(p_txn_currency_code,p_project_currency_code,
						bl.project_cost_rate_date,decode(l_plan_version_type,'COST'
						,l_project_cost_rate_date
						,'ALL',l_project_cost_rate_date
						,bl.project_cost_rate_date ))
                ,bl.project_cost_exchange_rate = decode(p_txn_currency_code,p_project_currency_code,
						bl.project_cost_exchange_rate,decode(l_plan_version_type,'COST'
						 ,l_project_cost_exchange_rate
						 ,'ALL',l_project_cost_exchange_rate
						 ,bl.project_cost_exchange_rate))
                ,bl.projfunc_cost_rate_type = decode(p_txn_currency_code,p_projfunc_currency_code,
						bl.projfunc_cost_rate_type,decode(l_plan_version_type,'COST'
						,l_projfunc_cost_rate_type
                                                ,'ALL',l_projfunc_cost_rate_type
                                                ,bl.projfunc_cost_rate_type))
                ,bl.projfunc_cost_rate_date_type = decode(p_txn_currency_code,p_projfunc_currency_code,
						bl.projfunc_cost_rate_date_type,decode(l_plan_version_type,'COST'
                                                ,l_projfunc_cost_rate_date_type
                                                ,'ALL',l_projfunc_cost_rate_date_type
                                                ,bl.projfunc_cost_rate_date_type))
                ,bl.projfunc_cost_rate_date =  decode(p_txn_currency_code,p_projfunc_currency_code,
						bl.projfunc_cost_rate_date,decode(l_plan_version_type,'COST'
                                                ,l_projfunc_cost_rate_date
                                                ,'ALL',l_projfunc_cost_rate_date
                                                ,bl.projfunc_cost_rate_date ))
                ,bl.projfunc_cost_exchange_rate = decode(p_txn_currency_code,p_projfunc_currency_code,
						bl.projfunc_cost_exchange_rate,decode(l_plan_version_type,'COST'
                                                 ,l_projfunc_cost_exchange_rate
                                                 ,'ALL',l_projfunc_cost_exchange_rate
                                                 ,bl.projfunc_cost_exchange_rate))
		--revenue attributes
                ,bl.project_rev_rate_type = decode(p_txn_currency_code,p_project_currency_code,
						bl.project_rev_rate_type,decode(l_plan_version_type,'REVENUE'
						,l_project_rev_rate_type
                                                ,'ALL',l_project_rev_rate_type
                                                ,bl.project_rev_rate_type))
                ,bl.project_rev_rate_date_type = decode(p_txn_currency_code,p_project_currency_code,
						 bl.project_rev_rate_date_type,decode(l_plan_version_type,'REVENUE'
                                                ,l_project_rev_rate_date_type
                                                ,'ALL',l_project_rev_rate_date_type
                                                ,bl.project_rev_rate_date_type))
                ,bl.project_rev_rate_date = decode(p_txn_currency_code,p_project_currency_code,
						bl.project_rev_rate_date,decode(l_plan_version_type,'REVENUE'
                                                ,l_project_rev_rate_date
                                                ,'ALL',l_project_rev_rate_date
                                                ,bl.project_rev_rate_date ))
                ,bl.project_rev_exchange_rate = decode(p_txn_currency_code,p_project_currency_code,
						bl.project_rev_exchange_rate,decode(l_plan_version_type,'REVENUE'
                                                 ,l_project_rev_exchange_rate
                                                 ,'ALL',l_project_rev_exchange_rate
                                                 ,bl.project_rev_exchange_rate))
                ,bl.projfunc_rev_rate_type = decode(p_txn_currency_code,p_projfunc_currency_code,
						bl.projfunc_rev_rate_type,decode(l_plan_version_type,'REVENUE'
						,l_projfunc_rev_rate_type
						,'ALL',l_projfunc_rev_rate_type
                                                ,bl.projfunc_rev_rate_type))
                ,bl.projfunc_rev_rate_date_type = decode(p_txn_currency_code,p_projfunc_currency_code,
						bl.projfunc_rev_rate_date_type,decode(l_plan_version_type,'REVENUE'
                                                 ,l_projfunc_rev_rate_date_type
                                                 ,'ALL',l_projfunc_rev_rate_date_type
                                                 ,bl.projfunc_rev_rate_date_type))
                ,bl.projfunc_rev_rate_date = decode(p_txn_currency_code,p_projfunc_currency_code,
					         bl.projfunc_rev_rate_date,decode(l_plan_version_type,'REVENUE'
                                                ,l_projfunc_rev_rate_date
                                                ,'ALL',l_projfunc_rev_rate_date
                                                ,bl.projfunc_rev_rate_date ))
                ,bl.projfunc_rev_exchange_rate = decode(p_txn_currency_code,p_projfunc_currency_code,
						bl.projfunc_rev_exchange_rate,decode(l_plan_version_type,'REVENUE'
                                                 ,l_projfunc_rev_exchange_rate
                                                 ,'ALL',l_projfunc_rev_exchange_rate
                                                 ,bl.projfunc_rev_exchange_rate))
		WHERE bl.resource_assignment_id = p_res_assignment_id
		AND  bl.txn_currency_code = p_txn_currency_code
		AND  bl.start_date BETWEEN trunc(p_start_date) and trunc(p_end_date)
		AND  bl.end_date BETWEEN  trunc(p_start_date) and trunc(p_end_date)
		AND (l_etc_start_date is NULL
		     OR (l_etc_start_date is NOT NULL
			and ((l_etc_start_date  between bl.start_date and bl.end_date)
			    or (bl.start_date > l_etc_start_date))
			)
		    );

		l_rowcount := sql%rowcount;
		l_stage := 'Number of BudgetLines Updated['||l_rowcount||']';
		print_msg(g_debug_flag,l_proc_name,l_stage);

		If l_rowcount  > 0 Then

		  IF x_return_status = 'S' AND l_call_calculate_api = 'Y' Then
			l_stage := 'Calling Calculate API';
                	print_msg(g_debug_flag,l_proc_name,l_stage);
			/* Initialize the arrays to pass to the calculate api */
			l_resource_assignment_tab.extend;
			l_resource_assignment_tab(1) := p_res_assignment_id;
			l_txn_currency_code_tab.extend;
			l_txn_currency_code_tab(1) := p_txn_currency_code;
			l_line_start_date_tab.extend;
			l_line_start_date_tab(1) := p_start_date;
			l_line_end_date_tab.extend;
			l_line_end_date_tab(1) := p_end_date;
			PA_FP_CALC_PLAN_PKG.CALCULATE
				(p_project_id      		=> l_project_id
				,p_budget_version_id 		=> p_BDGT_VERSION_ID
                      		,p_refresh_conv_rates_flag      => 'Y'
				,p_source_context 		=> 'BUDGET_LINE'
				,p_resource_assignment_tab 	=> l_resource_assignment_tab
				,p_txn_currency_code_tab	=> l_txn_currency_code_tab
				,p_line_start_date_tab		=> l_line_start_date_tab
				,p_line_end_date_tab		=> l_line_end_date_tab
				,x_return_status                => x_return_status
				,x_msg_count			=> x_msg_count
				,x_msg_data			=> x_msg_data
				);
			l_stage := 'End of Calculate API ReturnSTatus['||x_return_status||']MsgCt['||x_msg_count||']MsgData['
					||x_msg_data||']';
                	print_msg(g_debug_flag,l_proc_name,l_stage);
		  End IF;

		End IF;

	End if;

	l_stage := 'End of validateAndUpdateBdgtLine API msgCt['||x_msg_count||']RetSts['||x_return_status||']';
        print_msg(g_debug_flag,l_proc_name,l_stage);
	If x_return_status = 'S' Then
		COMMIT;
	Else
		ROLLBACK;
	End If;
IF p_pa_debug_mode = 'Y' THEN
	pa_debug.reset_err_stack;
END IF;
	Return;

EXCEPTION
	WHEN OTHERS THEN
		x_return_status := 'U';
		x_msg_data := SQLCODE||SQLERRM;
		x_msg_count := 1;
                print_msg('Y',l_proc_name,l_stage||SQLCODE||SQLERRM);
		FND_MSG_PUB.add_exc_msg
                           ( p_pkg_name       => 'PA_FIN_PLAN_UTILS2'
                            ,p_procedure_name => 'validateAndUpdateBdgtLine');
IF p_pa_debug_mode = 'Y' THEN
                PA_DEBUG.reset_err_stack;
END IF;
                Raise;


END  validateAndUpdateBdgtLine;

/* This API returns the period mask to be displayed on the edit budgetline details page
 * NOTE: donot use this API for any other purpose
 */
PROCEDURE setMaskName(p_period_Mask  IN Varchar2) IS

BEGIN
	PA_FIN_PLAN_UTILS2.period_mask_display := p_period_Mask;

END setMaskName;

/* This API returns the period mask to be displayed on the edit budgetline details page
 * NOTE: donot use this API for any other purpose
 */
FUNCTION getMaskName Return Varchar2 IS

BEGIN
        RETURN PA_FIN_PLAN_UTILS2.period_mask_display;

END getMaskName;

PROCEDURE checkUserRateAllowed
		(p_From_curr_code IN Varchar2
		,p_To_curr_code   IN Varchar2
		,p_Conversion_Date IN Date
		,p_To_Curr_Rate_Type IN Varchar2
		,p_To_Curr_Exchange_Rate IN Number
		,p_calling_mode    IN Varchar2
		,p_calling_context IN Varchar2
		,x_return_status  OUT NOCOPY Varchar2
		,x_error_msg_code OUT NOCOPY Varchar2
		) IS
	l_usrRateAllowed   Varchar2(10);
	l_stage 	Varchar2(1000);
	l_calling_mode  Varchar2(100) := p_calling_mode;
	l_calling_context Varchar2(100) := p_calling_context;
	l_proc_name     Varchar2(100) := 'checkUserRateAllowed';
BEGIN
	x_return_status := 'S';
	x_error_msg_code := NULL;

        If p_To_Curr_Rate_Type = 'User' Then
              -- check if the user rate type is allowed for this currency
	      l_stage := 'Calling pa_multi_currency.is_user_rate_type_allowed API()';
	      print_msg(g_debug_flag,l_proc_name,l_stage);
              l_usrRateAllowed := pa_multi_currency.is_user_rate_type_allowed
                    (P_from_currency   => p_From_curr_code
                    ,P_to_currency     => p_To_curr_code
                    ,P_conversion_date => p_Conversion_Date );
	      l_stage := 'End of pa_multi_currency API() UserRateAllowedFlag['||l_usrRateAllowed||']';
	      print_msg(g_debug_flag,l_proc_name,l_stage);
              If NVL(l_usrRateAllowed,'N') = 'Y' Then
                    If p_To_Curr_Exchange_Rate is NULL Then
                         x_return_status := 'E';
                         If l_calling_mode = 'PC' Then
			   If l_calling_context = 'COST' Then
                              x_error_msg_code := 'PA_FP_PROJ_MISS_COST_RATE';
			   Else
                              x_error_msg_code := 'PA_FP_PROJ_MISS_REV_RATE';
			   End If;
                         Else
                           If l_calling_context = 'COST' Then
                              x_error_msg_code := 'PA_FP_PROJFUNC_MISS_COST_RATE';
			   Else
                              x_error_msg_code := 'PA_FP_PROJFUNC_MISS_REV_RATE';
			   End If;
                         End If;
                    End If;

              Else  -- user rate type is not allowed so error out
                    x_return_status := 'E';
                    If l_calling_mode = 'PC' Then
                         x_error_msg_code := 'PA_FP_PROJ_USR_NOT_ALLOWED';
                    Else
                         x_error_msg_code := 'PA_FP_PROJFUNC_USR_NOT_ALLOWED';
                    End If;

	      End If;
	End If;
	l_stage := 'End of checkUserRateAllowed RetSts['||x_return_status||']MsgCode['||x_error_msg_code||']';
	print_msg(g_debug_flag,l_proc_name,l_stage);
	Return;

EXCEPTION
	WHEN OTHERS THEN
		x_return_status := 'U';
		x_error_msg_code :=l_stage||sqlcode||sqlerrm;
		print_msg('Y',l_proc_name,l_stage);

END checkUserRateAllowed;

/*
 * This API provides the budget line rejections for the given Project STructure
 * Version Id and Task Str Version Id
 * IN Params:
 * p_project_id    IN Number  Required
 * p_calling_mode  IN Varchar2 Default 'PROJ_STR_VER'
 *                 the possible values are 'PROJ_STR_VER' or 'TASK_STR_VER'
 * p_proj_str_version_id   IN Number Required
 * p_Task_str_version_id   IN Number If calling mode is TASK_STR_VER then it is reqd
 * p_start_date            IN Date
 *    If calling mode is TASK_STR_VER then it is reqd.
 *    value should be periodmask or task start date
 * p_end_date              IN Date
 *    If calling mode is TASK_STR_VER then it is reqd.
 *    value should be periodmask or task end date
 * OUT Params:
 * x_return_status  will be 'U' - in case of unexpected error
 *                          'E' - in case of expected error - invalid params
 *                          'S' - in case of success
 * If calling mode 'PROJ_STR_VER' then
 *   x_projstrlvl_rejn_flag will populated
 * ElsIf calling mode 'TASK_STR_VER'
 *   the following out variables will be populated
 *   x_cost_rejn_flag
 *   x_burden_rejn_flag
 *   x_revenue_rejn_flag
 *   x_pc_conv_rejn_flag
 *   x_pfc_conv_rejn_flag
 * End If;
 *
 */
PROCEDURE Get_WbsBdgtLineRejns
	(p_project_id           	IN Number
        ,p_calling_mode         	IN Varchar2 Default 'PROJ_STR_VER'
	,p_proj_str_version_id  	IN Number
	,p_Task_str_version_id  	IN Number   Default Null
	,p_start_date           	IN Date     Default Null
	,p_end_date             	IN Date     Default Null
        ,x_cost_rejn_flag               OUT NOCOPY  Varchar2
        ,x_burden_rejn_flag             OUT NOCOPY  Varchar2
        ,x_revenue_rejn_flag            OUT NOCOPY  Varchar2
        ,x_pc_conv_rejn_flag            OUT NOCOPY  Varchar2
        ,x_pfc_conv_rejn_flag           OUT NOCOPY  Varchar2
        ,x_projstrlvl_rejn_flag         OUT NOCOPY  Varchar2
        ,x_return_status                OUT NOCOPY  Varchar2
        ,p_budget_version_id    IN Number   Default Null --Bug 5611909
        ) IS

	l_proc_name             VARCHAR2(100) := 'Get_WbsBdgtLineRejns';
   	l_stage 	        VARCHAR2(2000);
	l_return_status         VARCHAR2(10);
	l_budget_version_id     Number;
	l_bdgtProjStrRejFlag    Varchar2(10);
	l_bdgtCstRejFlag        Varchar2(10);
	l_bdgtBdnRejFlag        Varchar2(10);
	l_bdgtRevnRejFlag       Varchar2(10);
	l_bdgtPcConvRejFlag     Varchar2(10);
	l_bdgtPfcConvRejFlag    Varchar2(10);
	l_debug_flag            Varchar2(10);


        CURSOR cur_bdgtProjStrRejFlag IS
	SELECT 'Y'
	FROM DUAL
	WHERE EXISTS
		(SELECT null
		FROM pa_budget_lines bl
		WHERE bl.budget_version_id = l_budget_version_id
		AND (bl.cost_rejection_code is NOT NULL
                    OR bl.burden_rejection_code is NOT NULL
                    OR bl.revenue_rejection_code is NOT NULL
                    OR bl.pc_cur_conv_rejection_code is NOT NULL
                    OR bl.pfc_cur_conv_rejection_code is NOT NULL)
               );

        CURSOR cur_bdgtCstRejFlag IS
        SELECT 'Y'
        FROM DUAL
        WHERE EXISTS
                (SELECT null
                FROM pa_budget_lines bl
		    ,pa_resource_assignments ra
                WHERE ra.budget_version_id = l_budget_version_id
		and ra.wbs_element_version_id = p_task_str_version_id
		and bl.resource_assignment_id = ra.resource_assignment_id
                and bl.cost_rejection_code is NOT NULL
		and bl.start_date between NVL(p_start_date,bl.start_date)
			AND NVL(p_end_date,bl.end_date)
		and bl.end_date between NVL(p_start_date,bl.start_date)
			AND NVL(p_end_date,bl.end_date)
               );

        CURSOR cur_bdgtBdnRejFlag IS
        SELECT 'Y'
        FROM DUAL
        WHERE EXISTS
                (SELECT null
                FROM pa_budget_lines bl
                    ,pa_resource_assignments ra
                WHERE ra.budget_version_id = l_budget_version_id
		and ra.wbs_element_version_id = p_task_str_version_id
		and bl.resource_assignment_id = ra.resource_assignment_id
                and bl.burden_rejection_code is NOT NULL
                and bl.start_date between NVL(p_start_date,bl.start_date)
                        AND NVL(p_end_date,bl.end_date)
                and bl.end_date between NVL(p_start_date,bl.start_date)
                        AND NVL(p_end_date,bl.end_date)
               );

        CURSOR cur_bdgtRevnRejFlag IS
        SELECT 'Y'
        FROM DUAL
        WHERE EXISTS
                (SELECT null
                FROM pa_budget_lines bl
                    ,pa_resource_assignments ra
                WHERE ra.budget_version_id = l_budget_version_id
		and ra.wbs_element_version_id = p_task_str_version_id
		and bl.resource_assignment_id = ra.resource_assignment_id
                and bl.revenue_rejection_code is NOT NULL
                and bl.start_date between NVL(p_start_date,bl.start_date)
                        AND NVL(p_end_date,bl.end_date)
                and bl.end_date between NVL(p_start_date,bl.start_date)
                        AND NVL(p_end_date,bl.end_date)
               );

        CURSOR cur_bdgtPcConvRejFlag IS
        SELECT 'Y'
        FROM DUAL
        WHERE EXISTS
                (SELECT null
                FROM pa_budget_lines bl
                    ,pa_resource_assignments ra
                WHERE ra.budget_version_id = l_budget_version_id
		and ra.wbs_element_version_id = p_task_str_version_id
		and bl.resource_assignment_id = ra.resource_assignment_id
                and bl.pc_cur_conv_rejection_code is NOT NULL
                and bl.start_date between NVL(p_start_date,bl.start_date)
                        AND NVL(p_end_date,bl.end_date)
                and bl.end_date between NVL(p_start_date,bl.start_date)
                        AND NVL(p_end_date,bl.end_date)
               );

        CURSOR cur_bdgtPfcConvRejFlag IS
        SELECT 'Y'
        FROM DUAL
        WHERE EXISTS
                (SELECT null
                FROM pa_budget_lines bl
                    ,pa_resource_assignments ra
                WHERE ra.budget_version_id = l_budget_version_id
		and ra.wbs_element_version_id = p_task_str_version_id
		and bl.resource_assignment_id = ra.resource_assignment_id
                and bl.pfc_cur_conv_rejection_code is NOT NULL
                and bl.start_date between NVL(p_start_date,bl.start_date)
                        AND NVL(p_end_date,bl.end_date)
                and bl.end_date between NVL(p_start_date,bl.start_date)
                        AND NVL(p_end_date,bl.end_date)
               );

BEGIN
        --- Initialize the error statck
	IF p_pa_debug_mode = 'Y' THEN
        	PA_DEBUG.init_err_stack ('PA_FIN_PLAN_UTILS2.Get_WbsBdgtLineRejns');
	END IF;
        fnd_profile.get('PA_DEBUG_MODE',l_debug_flag);
        l_debug_flag := NVL(l_debug_flag, 'N');

	IF p_pa_debug_mode = 'Y' THEN
        PA_DEBUG.SET_PROCESS( x_process => 'PLSQL'
                      ,x_write_file     => 'LOG'
                      ,x_debug_mode      => l_debug_flag
                          );
	END IF;
	x_return_status := 'S';
	l_stage := 'Inside Get_WbsBdgtLineRejns API: In Paramsare Proj Id['||p_project_id||
		']projStrver['||p_proj_str_version_id||']TaskstrVer['||p_task_str_version_id||
		']SD['||p_start_date||']ED['||p_end_date||']callinMode['||p_calling_mode||']';
	print_msg(l_debug_flag,l_proc_name,l_stage);

	-- Validate In params
	IF p_project_id is NULL OR p_proj_str_version_id is NULL Then
		x_return_status := 'E';
		l_stage := 'Insufficent params to get the Bdgt Rejections';
		print_msg(l_debug_flag,l_proc_name,l_stage);
IF p_pa_debug_mode = 'Y' THEN
		pa_debug.reset_err_stack;
END IF;
		Return;
	END IF;
    If p_budget_version_id is NULL then  --Bug 5611909
	l_budget_version_id := Pa_Fp_wp_gen_amt_utils.get_wp_version_id
			(p_project_id       => p_project_id
                         ,p_plan_type_id    => null
                         ,p_proj_str_ver_id => p_proj_str_version_id
			);
    else
    l_budget_version_id := p_budget_version_id;  --Bug 5611909
    end if;
	l_stage := 'Budget version for the projStrVersionid['||l_budget_version_id||']';
        print_msg(l_debug_flag,l_proc_name,l_stage);

	If p_calling_mode  = 'PROJ_STR_VER' Then
		OPEN cur_bdgtProjStrRejFlag;
		FETCH cur_bdgtProjStrRejFlag INTO l_bdgtProjStrRejFlag;
		CLOSE cur_bdgtProjStrRejFlag;
	ELSE
		OPEN cur_bdgtCstRejFlag ;
		FETCH cur_bdgtCstRejFlag INTO l_bdgtCstRejFlag;
		CLOSE cur_bdgtCstRejFlag;

                OPEN cur_bdgtBdnRejFlag ;
                FETCH cur_bdgtBdnRejFlag INTO l_bdgtBdnRejFlag;
                CLOSE cur_bdgtBdnRejFlag;

                OPEN cur_bdgtRevnRejFlag ;
                FETCH cur_bdgtRevnRejFlag INTO l_bdgtRevnRejFlag;
                CLOSE cur_bdgtRevnRejFlag;

                OPEN cur_bdgtpcConvRejFlag ;
                FETCH cur_bdgtPcConvRejFlag INTO l_bdgtPcConvRejFlag;
                CLOSE cur_bdgtPcConvRejFlag;

                OPEN cur_bdgtpfcConvRejFlag ;
                FETCH cur_bdgtPfcConvRejFlag INTO l_bdgtPfcConvRejFlag;
                CLOSE cur_bdgtPfcConvRejFlag;

	END IF;

	x_cost_rejn_flag         := NVL(l_bdgtCstRejFlag,'N');
        x_burden_rejn_flag       := NVL(l_bdgtBdnRejFlag,'N');
        x_revenue_rejn_flag      := NVL(l_bdgtRevnRejFlag,'N');
        x_pc_conv_rejn_flag      := NVL(l_bdgtPcConvRejFlag,'N');
        x_pfc_conv_rejn_flag     := NVL(l_bdgtPfcConvRejFlag,'N');
        x_projstrlvl_rejn_flag   := NVL(l_bdgtProjStrRejFlag,'N');

	l_stage := 'OUT Params CstRej['||x_cost_rejn_flag||']BdRej['||x_burden_rejn_flag||
		']RevRej['||x_revenue_rejn_flag||']PcRej['||x_pc_conv_rejn_flag||
		']PfcRej['||x_pfc_conv_rejn_flag||']ProjStrRej['||x_projstrlvl_rejn_flag||']';
	print_msg(l_debug_flag,l_proc_name,l_stage);
IF p_pa_debug_mode = 'Y' THEN
	pa_debug.reset_err_stack;
END IF;
	Return;

EXCEPTION
	WHEN OTHERS THEN
		x_return_status := 'U';
		l_stage := 'Unexpected error Occured ['||SQLCODE||SQLERRM||']';
		print_msg('Y',l_proc_name,l_stage);
		FND_MSG_PUB.add_exc_msg
                      ( p_pkg_name       => 'PA_FIN_PLAN_UTILS2'
                       ,p_procedure_name => 'Get_WbsBdgtLineRejns');
	IF p_pa_debug_mode = 'Y' THEN
                PA_DEBUG.reset_err_stack;
	END IF;
		Raise;

END Get_WbsBdgtLineRejns;

/* This API provides the budget line Actual Start Date and End Date
 * for the given budget version and resource assignment id
 * Logic: Derive Actual SDate as derive the MIN(budget_line.Start_date) where
 *        actuals on the budget lines are populated.
 *        similarly for EDate derive the ETC start date from budget versions for the given resource assignment
 *        if etc start date is null then derive the MAX(budget_line.end_date) where
 *        actuals on the budget lines are populated.
 * The PARAMS :
 * p_budget_version_id       IN Number   Required
 * p_resource_assignment_id  IN Number   Required
 * x_bl_actual_start_date    OUT DATE
 * x_bl_actual_end_date      OUT DATE
 * x_return_status           OUT Varchar2
 * Note : if ETC start date and actual values donot exists then the out params
 *  x_bl_actual_start_date and x_bl_actual_end_date will be passed as NULL
 * Rule:
 * 1. If x_bl_actual_start_date is NULL and x_bl_actual_end_date is NULL
 *     then planning trx start date and end date can be shifted.
 * 2. if x_bl_actual_end_date is NOT NULL then planning trx end date can't be shifted earlier than x_bl_actual_end_date
 * 3. if x_bl_actual_start_date is NOT NULL then planning trx start date can't be shifted later than x_bl_actual_start_date
 */
PROCEDURE get_blactual_Dates
	(p_budget_version_id  IN Number
	,p_resource_assignment_id IN Number
	,x_bl_actual_start_date OUT NOCOPY date
	,x_bl_actual_end_date   OUT NOCOPY date
	,x_return_status        OUT NOCOPY varchar2
	,x_error_msg_code       OUT NOCOPY varchar2
	) IS

	cursor cur_etc IS
	select bv.etc_start_date
	from pa_budget_versions bv
	where bv.budget_version_id = p_budget_version_id
	and  Exists ( select null
		      from pa_budget_lines bl
		      where bl.resource_assignment_id = p_resource_assignment_id
		      and bl.budget_version_id = bv.budget_version_id
		) ;

	cursor cur_se_date IS
	select MIN(bl.start_date)
		,MAX(bl.end_date)
	from pa_budget_lines bl
	where bl.resource_assignment_id = p_resource_assignment_id
	and   bl.budget_version_id = p_budget_version_id
	and  (bl.init_quantity is NOT NULL
	     or bl.txn_init_raw_cost is NOT NULL
	     or bl.txn_init_burdened_cost is NOT NULL
	     or bl.txn_init_revenue is NOT NULL
	     );

	l_etc_start_date   Date;
	l_bl_start_date    Date;
	l_bl_end_date      Date;

BEGIN
	x_return_status := 'S';
	x_error_msg_code := NULL;
	OPEN cur_etc;
	FETCH cur_etc INTO l_etc_start_date;
	CLOSE cur_etc;

	OPEN cur_se_date;
	FETCH cur_se_date INTO
		l_bl_start_date
		,l_bl_end_date;
	CLOSE cur_se_date;

	If l_bl_end_date is NOT NULL Then
		If l_etc_start_date is NOT NULL Then
			IF l_etc_start_date > l_bl_end_date Then
				x_bl_actual_end_date := l_etc_start_date;
			Else
				x_bl_actual_end_date := l_bl_end_date;
			End If;
		Else
			x_bl_actual_end_date := l_bl_end_date;
		End If;
	Else
		x_bl_actual_end_date := l_etc_start_date;
	End if;

	x_bl_actual_start_date := l_bl_start_date;
	RETURN;

EXCEPTION
	WHEN OTHERS THEN
		x_return_status := 'U';
		x_error_msg_code := SQLCODE||SQLERRM;
		RAISE;
END get_blactual_Dates;

/* This API returns the Agreement currency for the given change order budget version
 * If the currency is null Or budget version is not part of the change order then
 * the api returns the NULL
 */
FUNCTION get_Agreement_Currency(p_budget_version_id  IN Number)
	RETURN varchar2 IS

	l_calling_mode  varchar2(100);
	l_agr_curr_code varchar2(100);
	l_return_status varchar2(100);
	l_agr_conv_reqd_flag  varchar2(100);
BEGIN
	PA_FIN_PLAN_UTILS2.Get_Agreement_Details
        (p_budget_version_id  => p_budget_version_id
        ,p_calling_mode       => 'FUNCTION_CALL'
        ,x_agr_curr_code      => l_agr_curr_code
	,x_AGR_CONV_REQD_FLAG => l_agr_conv_reqd_flag
	,x_return_status      => l_return_status
	);

	If l_return_status <> 'S' Then
		l_agr_curr_code := null;
	End If;
	RETURN l_agr_curr_code;

END get_Agreement_Currency;

/* This API provides the agreement related details
 * Bug fix: 3679142 Change order versions which have revenue impact should also be in agreement
 * currency. This means all change order versions with version type as ALL or REVENUE
 * should ultimately have the planning txns and budget lines in AGR CURRENCY.
*/
PROCEDURE Get_Agreement_Details
        (p_budget_version_id  IN Number
	,p_calling_mode       IN Varchar2  DEFAULT 'CALCULATE_API'
        ,x_agr_curr_code      OUT NOCOPY Varchar2
	,x_AGR_CONV_REQD_FLAG OUT NOCOPY Varchar2
        ,x_return_status      OUT NOCOPY Varchar2 ) IS

        Cursor cur_bv IS
        SELECT bv.agreement_id
                ,bv.ci_id
                ,bv.version_type
                ,bv.version_name
                ,bv.approved_rev_plan_type_flag -- Bug 5845142
        FROM pa_budget_versions bv
        WHERE bv.budget_version_id = p_budget_version_id;

        CURSOR cur_agr(p_agr_id  Number) IS
        SELECT agr.agreement_currency_code
        FROM pa_agreements_all agr
        WHERE agr.agreement_id = p_agr_id;


        l_agreement_id Number;
        l_ci_id       Number;
        l_agr_curr_code Varchar2(100);
        l_agr_con_reqd_flag varchar2(1) := 'N';
        l_version_name   pa_budget_versions.version_name%type;
        l_version_type   pa_budget_versions.version_type%type;
        l_error_msg_code Varchar2(100);
        INVALID_EXCEPTION  EXCEPTION;
        l_debug_flag     varchar2(100);
        l_proc_name      varchar2(100) := 'Get_Agreement_Details';
        G_AGR_CONV_REQD_FLAG   varchar2(1) := 'N';
        G_AGR_CURRENCY_CODE    varchar2(100);

        --Bug 5845142
        l_approved_rev_plan_type_flag   pa_budget_versions.approved_rev_plan_type_flag%TYPE;

BEGIN
	IF p_pa_debug_mode = 'Y' THEN
        pa_debug.init_err_stack('PA_FIN_PLAN_UTILS2.Get_Agreement_Details');
	END IF;
        fnd_profile.get('PA_DEBUG_MODE',l_debug_flag);
        l_debug_flag := NVL(l_debug_flag, 'N');

	IF p_pa_debug_mode = 'Y' THEN
        PA_DEBUG.SET_PROCESS( x_process => 'PLSQL'
                      ,x_write_file     => 'LOG'
                      ,x_debug_mode      => l_debug_flag
                          );
	END IF;
        print_msg(l_debug_flag,l_proc_name,'Entered Get_Agreement_Details Api');

        x_return_status := 'S';
        OPEN cur_bv;
        FETCH cur_bv INTO
                l_agreement_id
                ,l_ci_id
                ,l_version_type
                ,l_version_name
                ,l_approved_rev_plan_type_flag; -- Bug 5845142
        CLOSE cur_bv ;
        l_agr_con_reqd_flag := 'N';
	l_agr_curr_code := Null;
        print_msg(l_debug_flag,l_proc_name,'VersionType['||l_version_type||']CiId['||l_ci_id||']AgrId['||l_agreement_id||']');
        -- Bug 5845142. Amounts should be in agreement currency only for approved revenue impacts.
        IF ( l_version_type in ('ALL','REVENUE') AND
             l_approved_rev_plan_type_flag ='Y' ) Then
                If l_ci_id is NOT NULL Then
                        print_msg(l_debug_flag,l_proc_name,'This is a change order/change request budget');
                        IF l_agreement_id is NULL Then
                                -- add error msg to stack
                                l_error_msg_code := 'PA_FP_MISSING_AGR_REV_IMPACT';
                                x_return_status := 'E';
                                raise INVALID_EXCEPTION;
                         ELSE
                                OPEN cur_agr(l_agreement_id);
                                FETCH cur_agr INTO l_agr_curr_code;
                                CLOSE cur_agr;
                                print_msg(l_debug_flag,l_proc_name,'Agreement Currency code['||l_agr_curr_code||']');
                                IF l_agr_curr_code is NULL Then
                                        l_error_msg_code := 'PA_FP_MISSING_AGR_CURCODE';
                                        l_agr_con_reqd_flag := 'N';
					l_agr_curr_code := null;
                                        x_return_status := 'E';
                                        raise INVALID_EXCEPTION;
                                Else
                                        l_agr_con_reqd_flag := 'Y';
                                        x_agr_curr_code := l_agr_curr_code;
					x_AGR_CONV_REQD_FLAG := l_agr_con_reqd_flag;
                                End IF;
                        End IF;
                Else
                        l_agr_con_reqd_flag := 'N';
			l_agr_curr_code := null;
                End If;
        END IF;

        /* Set the global varaibles to call conv rates api*/
        G_AGR_CONV_REQD_FLAG := l_agr_con_reqd_flag;
        G_AGR_CURRENCY_CODE  := x_agr_curr_code;
        print_msg(l_debug_flag,l_proc_name,'Leaving Get_Agreement_Details G_AGR_CONV_REQD_FLAG['||G_AGR_CONV_REQD_FLAG||']G_AGR_CURRENCY_CODE['||G_AGR_CURRENCY_CODE||']');
	/* set the output variables */
	x_agr_curr_code := G_AGR_CURRENCY_CODE;
	x_AGR_CONV_REQD_FLAG := G_AGR_CONV_REQD_FLAG;
        -- reset error stack
IF p_pa_debug_mode = 'Y' THEN
        pa_debug.reset_err_stack;
END IF;
EXCEPTION
        WHEN INVALID_EXCEPTION THEN
	    If p_calling_mode = 'CALCULATE_API' Then
                pa_utils.Add_Message
                  (p_app_short_name => 'PA'
		  ,p_msg_name       => l_error_msg_code
                  ,p_token1         => 'BUDGET_VERSION_ID'
                  ,p_value1         => p_budget_version_id
                  ,p_token2         => 'VERSIONNAME'
                  ,p_value2         => l_version_name
                  );
                x_return_status := 'E';
		x_agr_curr_code := NULL;
		x_AGR_CONV_REQD_FLAG  := 'N';
                RAISE ;
	    ELSE
		x_return_status := 'S';
		x_agr_curr_code := NULL;
		x_AGR_CONV_REQD_FLAG  := 'N';
	    END IF;

        WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		x_agr_curr_code := NULL;
                fnd_msg_pub.add_exc_msg
                ( p_pkg_name       => 'PA_FIN_PLAN_UTILS2'
                 ,p_procedure_name => 'Get_Agreement_Details' );
                print_msg(l_debug_flag,l_proc_name,'Failed in Get_Agreement_Details substr(SQLERRM,1,240) => '|| substr(SQLERRM,1,240));
IF p_pa_debug_mode = 'Y' THEN
                pa_debug.reset_err_stack;
END IF;
                RAISE;
END Get_Agreement_Details;

/* This API rounds off the given quantity to 5 decimal places.  This API should be called for rounding the quantity
 * for rate based planning transaction only.
 * This API accepts the following parameters
 */
FUNCTION round_quantity
        (P_quantity     IN Number
        ) RETURN NUMBER IS

	l_rounded_quantity Number := P_quantity;
BEGIN
	If P_quantity is NOT NULL Then

		l_rounded_quantity :=  round(P_quantity,5);
	End If;
	RETURN l_rounded_quantity;

EXCEPTION
	WHEN OTHERS THEN
		RAISE;

END round_quantity;

/* This API checks the given financial Task is billable or not
 * If task is billable, it returns 'Y' else 'N'
 */
FUNCTION IsFpTaskBillable(p_project_id   NUMBER
			 ,p_task_id   NUMBER) RETURN varchar2 IS

	CURSOR cur_TaskBillable IS
	SELECT NVL(t.billable_flag,'N')
	FROM pa_tasks t
	WHERE t.task_id = p_task_id
	AND   t.project_id = p_project_id;

	X_billable_flag 	Varchar2(10);
        l_RecFound		BOOLEAN         := FALSE;
	l_projTaskId            NUMBER;
BEGIN
	/* Note: As suggested by venkatesh for project level always set the billable flag as Y */
	IF p_project_id is NOT NULL AND NVL(p_task_id,0) = 0 Then
		X_billable_flag := 'Y';
	ELSIF p_project_id is NOT NULL AND NVL(p_task_id,0) <> 0 THEN --{
	    /* l_projTaskId := p_project_id||p_task_id; This is not required as this may lead to corruption
	     * P1||T1 = 33||3 similarly P1||T1 = 3||33 will give the same results*/
	    l_projTaskId := p_task_id;
	    --print_msg('Y','IsFpTaskBillable','l_projTaskId['||l_projTaskId||']Count['||G_FpTaskBillable_Tab.COUNT||']');
            If G_FpTaskBillable_Tab.COUNT > 0 Then
              Begin
                /*Get the Project Number from the pl/sql table.
                 *If there is no index with the value of the project_id passed
                 *in then an ora-1403: no_data_found is generated.
		 */
                X_billable_flag := G_FpTaskBillable_Tab(l_projTaskId).Billable_Flag;
                l_RecFound := TRUE;

              Exception
                When No_Data_Found Then
                        l_RecFound := FALSE;
                When Others Then
                        Raise;

              End;
	    End If;

            If Not l_RecFound Then
		--print_msg('Y','IsFpTaskBillable','l_projTaskId['||l_projTaskId||']Executing cursor to get BillableFlag');
                -- Since the project has not been cached yet, will need to add it.
                -- So check to see if there are already 200 records in the pl/sql table.
                If G_FpTaskBillable_Tab.COUNT > 199 Then
                        G_FpTaskBillable_Tab.Delete;
                End If;
		X_billable_flag := 'N';
                OPEN cur_TaskBillable;
		FETCH cur_TaskBillable INTO X_billable_flag;
		IF cur_TaskBillable%NOTFOUND Then
			X_billable_flag := 'N';
		End If;
		CLOSE cur_TaskBillable;

                -- Add the billable Flag to the pl/sql table using the project_id||TaskId combination
		G_FpTaskBillable_Tab(l_projTaskId).Billable_Flag := NVL(X_billable_flag,'N');

	    End If;

	END IF; --}
	--print_msg('Y','IsFpTaskBillable','X_billable_flag['||X_billable_flag||']');
	RETURN NVL(X_billable_flag,'N');

EXCEPTION
	WHEN OTHERS THEN
		fnd_msg_pub.add_exc_msg
                ( p_pkg_name       => 'PA_FIN_PLAN_UTILS2'
                 ,p_procedure_name => 'IsFpTaskBillable');
                print_msg('Y','IsFpTaskBillable','Failed in IsFpTaskBillable => '|| substr(SQLERRM,1,240));
                RAISE;

END IsFpTaskBillable;

PROCEDURE  populate_res_details
	( p_calling_module              IN VARCHAR2
        ,p_source_context               IN VARCHAR2
        ,p_project_id                   IN NUMBER
	,p_project_type			IN VARCHAR2
        ,p_budget_version_id            IN NUMBER
        ,p_resource_list_member_Id_tab  IN SYSTEM.PA_NUM_TBL_TYPE
	,p_plsql_index_tab		IN SYSTEM.PA_NUM_TBL_TYPE
	,p_ra_date_tab                  IN SYSTEM.PA_DATE_TBL_TYPE
        ,p_task_id_tab                  IN SYSTEM.PA_NUM_TBL_TYPE
        ,p_quantity_tab                 IN SYSTEM.PA_NUM_TBL_TYPE
        ,p_txn_currency_code_tab        IN SYSTEM.PA_VARCHAR2_15_TBL_TYPE
        ,p_txn_currency_code_ovr_tab    IN SYSTEM.PA_VARCHAR2_15_TBL_TYPE
        ,p_cost_rate_override_tab       IN SYSTEM.PA_NUM_TBL_TYPE
        ,p_burden_rate_override_tab     IN SYSTEM.PA_NUM_TBL_TYPE
        ,p_bill_rate_override_tab       IN SYSTEM.PA_NUM_TBL_TYPE
	,x_return_status		OUT NOCOPY VARCHAR2
	) IS

 --Start of variables for Variable for Resource Attributes
   l_resource_class_flag_tbl         SYSTEM.PA_VARCHAR2_1_TBL_TYPE     := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
   l_resource_class_code_tbl         SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
   l_resource_class_id_tbl           SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
   l_res_type_code_tbl               SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
   l_incur_by_res_type_tbl               SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
   l_job_id_tbl                      SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
   l_person_id_tbl                   SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
   l_person_type_code_tbl            SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
   l_named_role_tbl                  SYSTEM.PA_VARCHAR2_80_TBL_TYPE    := SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
   l_bom_resource_id_tbl             SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
   l_non_labor_resource_tbl          SYSTEM.PA_VARCHAR2_20_TBL_TYPE    := SYSTEM.PA_VARCHAR2_20_TBL_TYPE();
   l_inventory_item_id_tbl           SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
   l_item_category_id_tbl            SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
   l_project_role_id_tbl             SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
   l_organization_id_tbl             SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
   l_fc_res_type_code_tbl            SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
   l_expenditure_type_tbl            SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
   l_expenditure_category_tbl        SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
   l_event_type_tbl                  SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
   l_revenue_category_code_tbl       SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
   l_supplier_id_tbl                 SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
   l_unit_of_measure_tbl             SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
   l_spread_curve_id_tbl             SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
   l_etc_method_code_tbl             SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
   l_mfc_cost_type_id_tbl            SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
   l_procure_resource_flag_tbl       SYSTEM.PA_VARCHAR2_1_TBL_TYPE     := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
   l_incurred_by_res_flag_tbl        SYSTEM.PA_VARCHAR2_1_TBL_TYPE     := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
   l_Incur_by_res_class_code_tbl     SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
   l_Incur_by_role_id_tbl            SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
   l_org_id_tbl                      SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
   l_rate_based_flag_tbl             SYSTEM.PA_VARCHAR2_1_TBL_TYPE     := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
   l_rate_expenditure_type_tbl       SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
   l_rate_func_curr_code_tbl         SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
   l_resource_assignment_id_tbl      SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
   l_assignment_description_tbl      SYSTEM.PA_VARCHAR2_240_TBL_TYPE   := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
   l_planning_resource_alias_tbl     SYSTEM.PA_VARCHAR2_80_TBL_TYPE    := SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
   l_resource_name_tbl               SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
   l_project_role_name_tbl           SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
   l_organization_name_tbl           SYSTEM.PA_VARCHAR2_240_TBL_TYPE   := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
   l_financial_category_code_tbl     SYSTEM.PA_VARCHAR2_80_TBL_TYPE    := SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
   l_project_assignment_id_tbl       SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
   l_use_task_schedule_flag_tbl      SYSTEM.PA_VARCHAR2_1_TBL_TYPE     := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
   l_planning_start_date_tbl         SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
   l_planning_end_date_tbl           SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
   l_total_quantity_tbl              SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
   l_override_currency_code_tbl      SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
   l_billable_percent_tbl            SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
   l_cost_rate_override_tbl          SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
   l_burdened_rate_override_tbl      SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
   l_sp_fixed_date_tbl               SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
   l_financial_category_name_tbl     SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
   l_supplier_name_tbl               SYSTEM.PA_VARCHAR2_240_TBL_TYPE   := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
  --End of variables for Variable for Resource Attributes
	l_msg_data 		Varchar2(1000);
	l_msg_count		Number;
	l_return_status		Varchar2(1) := 'S';

BEGIN
	x_return_status := 'S';
 	--This api derives the resource defaults
	IF p_resource_list_member_Id_tab.COUNT > 0 THEN --{
		print_msg(p_pa_debug_mode,'populate_res_details','Calling get_resource_defaults');
 		PA_PLANNING_RESOURCE_UTILS.get_resource_defaults(
 		p_resource_list_members        =>  p_resource_list_member_Id_tab
 		,p_project_id                   =>  p_project_id
 		,x_resource_class_flag          =>  l_resource_class_flag_tbl
 		,x_resource_class_code          =>  l_resource_class_code_tbl
 		,x_resource_class_id            =>  l_resource_class_id_tbl
 		,x_res_type_code                =>  l_res_type_code_tbl
 		,x_incur_by_res_type            =>  l_incur_by_res_type_tbl
 		,x_person_id                    =>  l_person_id_tbl
 		,x_job_id                       =>  l_job_id_tbl
 		,x_person_type_code             =>  l_person_type_code_tbl
 		,x_named_role                   =>  l_named_role_tbl
 		,x_bom_resource_id              =>  l_bom_resource_id_tbl
 		,x_non_labor_resource           =>  l_non_labor_resource_tbl
 		,x_inventory_item_id            =>  l_inventory_item_id_tbl
 		,x_item_category_id             =>  l_item_category_id_tbl
 		,x_project_role_id              =>  l_project_role_id_tbl
 		,x_organization_id              =>  l_organization_id_tbl
 		,x_fc_res_type_code             =>  l_fc_res_type_code_tbl
 		,x_expenditure_type             =>  l_expenditure_type_tbl
 		,x_expenditure_category         =>  l_expenditure_category_tbl
 		,x_event_type                   =>  l_event_type_tbl
 		,x_revenue_category_code        =>  l_revenue_category_code_tbl
 		,x_supplier_id                  =>  l_supplier_id_tbl
 		,x_unit_of_measure              =>  l_unit_of_measure_tbl
 		,x_spread_curve_id              =>  l_spread_curve_id_tbl
 		,x_etc_method_code              =>  l_etc_method_code_tbl
 		,x_mfc_cost_type_id             =>  l_mfc_cost_type_id_tbl
 		,x_incurred_by_res_flag         =>  l_incurred_by_res_flag_tbl
 		,x_incur_by_res_class_code      =>  l_incur_by_res_class_code_tbl
 		,x_Incur_by_role_id             =>  l_Incur_by_role_id_tbl
 		,x_org_id                       =>  l_org_id_tbl
 		,X_rate_based_flag              =>  l_rate_based_flag_tbl
 		,x_rate_expenditure_type        =>  l_rate_expenditure_type_tbl
 		,x_rate_func_curr_code          =>  l_rate_func_curr_code_tbl
 		,x_msg_data                     =>  l_msg_data
 		,x_msg_count                    =>  l_msg_count
 		,x_return_status                =>  l_return_status
		);
		print_msg(p_pa_debug_mode,'populate_res_details','RetunSts['||l_return_status||']MsgData['||l_msg_data||']');

	    IF NVL(l_return_status,'S') = 'S' Then
		print_msg(p_pa_debug_mode,'populate_res_details','populating res assignments tmp');
		FORALL i IN p_resource_list_member_Id_tab.FIRST  .. p_resource_list_member_Id_tab.LAST
                        INSERT INTO pa_fp_res_assignments_tmp
                        (project_id
                        ,budget_version_id
			,resource_assignment_id
                        ,resource_list_member_id
                        ,unit_of_measure
                        ,resource_class_code
                        ,organization_id
                        ,job_id
                        ,person_id
                        ,expenditure_type
                        ,expenditure_category
                        ,non_labor_resource
                        ,bom_resource_id
                        ,inventory_item_id
                        ,item_category_id
                        ,mfc_cost_type_id
                        --,rate_job_id
                        ,rate_expenditure_type
                        ,rate_based_flag
                        ,rate_expenditure_org_id
                        --,res_format_id
                        ,project_type
			,org_id
			,rbs_element_id
                        ) VALUES
			(p_project_id
			,NVL(p_budget_version_id,-9999)
			,-9999  --raid
			,p_resource_list_member_Id_tab(i)
			,l_unit_of_measure_tbl(i)
			,l_resource_class_code_tbl(i)
			,l_organization_id_tbl(i)
			,l_job_id_tbl(i)
			,l_person_id_tbl(i)
			,l_expenditure_type_tbl(i)
			,l_expenditure_category_tbl(i)
			,l_non_labor_resource_tbl(i)
			,l_bom_resource_id_tbl(i)
                        ,l_inventory_item_id_tbl(i)
                        ,l_item_category_id_tbl(i)
                        ,l_mfc_cost_type_id_tbl(i)
                        --,l_rate_job_id_tbl(i)
                        ,l_rate_expenditure_type_tbl(i)
                        ,l_rate_based_flag_tbl(i)
                        ,l_org_id_tbl(i)    --l_rate_expenditure_org_id_tbl(i)
                        --,to_number(null) --l_res_format_id_tbl(i)
                        ,p_project_type
                        ,l_org_id_tbl(i)
			,p_plsql_index_tab(i)
			)
			;

		/* Now Update the tmp table with rates and currencys passed */
		FORALL i IN p_resource_list_member_Id_tab.FIRST  .. p_resource_list_member_Id_tab.LAST
		UPDATE pa_fp_res_assignments_tmp TMP
		SET tmp.txn_currency_code 	= p_txn_currency_code_tab(i)
		  ,txn_currency_code_override   = p_txn_currency_code_ovr_tab(i)
                  ,rw_cost_rate_override	= p_cost_rate_override_tab(i)
                  ,burden_cost_rate_override	= p_burden_rate_override_tab(i)
                  ,bill_rate_override		= p_bill_rate_override_tab(i)
                  ,task_id			= p_task_id_tab(i)
		  ,txn_plan_quantity            = p_quantity_tab(i)
		  ,line_start_date              = NVL(p_ra_date_tab(i),trunc(sysdate))
		WHERE tmp.budget_version_id = NVL(p_budget_version_id,-9999)
		AND  tmp.resource_list_member_id = p_resource_list_member_Id_tab(i);

	    END IF;

	END IF; --}
	x_return_status := l_return_status;
	print_msg(p_pa_debug_mode,'populate_res_details','End of populate_res_details retSts['||x_return_status||']');

EXCEPTION
	WHEN OTHERS THEN
		print_msg('Y','populate_res_details','Error occured at populate_res_details: '||sqlcode||sqlerrm);
		x_return_status := 'U';
		RAISE;
END populate_res_details;

PROCEDURE  populate_ra_details
	( p_calling_module              IN VARCHAR2
        ,p_source_context               IN VARCHAR2
        ,p_project_id                   IN NUMBER
	,p_project_type                 IN VARCHAR2
        ,p_budget_version_id            IN NUMBER
        ,p_resource_assignment_id_tab   IN SYSTEM.PA_NUM_TBL_TYPE
	,p_plsql_index_tab		IN SYSTEM.PA_NUM_TBL_TYPE
	,p_ra_date_tab			IN SYSTEM.PA_DATE_TBL_TYPE
        ,p_task_id_tab                  IN SYSTEM.PA_NUM_TBL_TYPE
        ,p_quantity_tab                 IN SYSTEM.PA_NUM_TBL_TYPE
        ,p_txn_currency_code_tab        IN SYSTEM.PA_VARCHAR2_15_TBL_TYPE
        ,p_txn_currency_code_ovr_tab    IN SYSTEM.PA_VARCHAR2_15_TBL_TYPE
        ,p_cost_rate_override_tab       IN SYSTEM.PA_NUM_TBL_TYPE
        ,p_burden_rate_override_tab     IN SYSTEM.PA_NUM_TBL_TYPE
        ,p_bill_rate_override_tab       IN SYSTEM.PA_NUM_TBL_TYPE
	,x_return_status 		OUT NOCOPY  VARCHAR2
	) IS

BEGIN
	x_return_status := 'S';
	IF p_resource_assignment_id_tab.COUNT > 0 Then
		print_msg(p_pa_debug_mode,'populate_ra_details','bulk insert to res_assignments_tmp table');
                        FORALL i IN p_resource_assignment_id_tab.FIRST  .. p_resource_assignment_id_tab.LAST
                        INSERT INTO pa_fp_res_assignments_tmp
                        (project_id
                        ,budget_version_id
                        ,resource_assignment_id
                        ,resource_list_member_id
			,line_start_date
                        ,txn_currency_code
                        ,txn_currency_code_override
                        ,rw_cost_rate_override
                        ,burden_cost_rate_override
                        ,bill_rate_override
                        ,task_id
                        ,unit_of_measure
                        ,resource_class_code
                        ,organization_id
                        ,job_id
                        ,person_id
                        ,expenditure_type
                        ,expenditure_category
                        ,non_labor_resource
                        ,bom_resource_id
                        ,inventory_item_id
                        ,item_category_id
                        ,mfc_cost_type_id
                        ,rate_job_id
                        ,rate_expenditure_type
                        ,rate_based_flag
                        ,rate_expenditure_org_id
                        ,project_type
			,rbs_element_id
                        ) SELECT
                        p_project_id
                        ,NVL(p_budget_version_id,-9999)
                        ,p_resource_assignment_id_tab(i)
                        ,ra.resource_list_member_id
			,NVL(p_ra_date_tab(i),trunc(sysdate))
                        ,p_txn_currency_code_tab(i)
                        ,p_txn_currency_code_ovr_tab(i)
                        ,p_cost_rate_override_tab(i)
                        ,p_burden_rate_override_tab(i)
                        ,p_bill_rate_override_tab(i)
                        ,ra.task_id
                        ,ra.unit_of_measure
                        ,ra.resource_class_code
                        ,ra.organization_id
                        ,ra.job_id
                        ,ra.person_id
                        ,ra.expenditure_type
                        ,ra.expenditure_category
                        ,ra.non_labor_resource
                        ,ra.bom_resource_id
                        ,ra.inventory_item_id
                        ,ra.item_category_id
                        ,ra.mfc_cost_type_id
                        ,ra.rate_job_id
                        ,ra.rate_expenditure_type
                        ,NVL(ra.rate_based_flag,'N') rate_based_flag
                        ,ra.rate_expenditure_org_id
                        ,p_project_type
			,p_plsql_index_tab(i)
                        FROM pa_resource_assignments ra
                        WHERE ra.resource_assignment_id = p_resource_assignment_id_tab(i);

	END IF;
	print_msg(p_pa_debug_mode,'populate_ra_details','End of populate_ra_details retSts['||x_return_status||']');
EXCEPTION
	WHEN OTHERS THEN
		x_return_status := 'U';
		print_msg('Y','populate_ra_details','Error occured at populate_ra_details: '||sqlcode||sqlerrm);
		RAISE;
END populate_ra_details;

/* Bug Fix:4621597: Added new generic api to derive rates for RA / RLMI
 * This is a generic wrapper API to call the get planning rates to derive raw cost rate, burden rate and bill rates
 * The default and possible values for the IN params
 * p_calling_module              IN VARCHAR2 := 'MSP'
 * p_source_context              IN VARCHAR2 := 'RLMI' -- Resource List member context
 *                                              'RA'   -- Resource assignment context
 * if p_budget_version_id is NULL Then it will be treated as the 'COST' only version and attributes will be defaulted from the
 *  project level.
 * p_porject_id   is NOT NULL param
 * If p_source_context = 'RLMI' then p_resource_list_member_Id_tab must be passed
 * If p_source_context = 'RA' then p_resource_assignment_id_tab must be passed
 * OUT PARAMS:
 * API provides two set of txn currency, x_cost_txn_curr_code_tab - for Cost currency
 *                                       x_rev_txn_curr_code_tab  - for Revenue currency
 * Its calling APIs responsibiltiy to convert these currency into Txn currency
 */
PROCEDURE Get_Resource_Rates
	( p_calling_module          	IN VARCHAR2 := 'MSP'
	,p_source_context               IN VARCHAR2 := 'RLMI'
	,p_project_id			IN NUMBER
	,p_budget_version_id		IN NUMBER
	,p_resource_assignment_id_tab   IN SYSTEM.PA_NUM_TBL_TYPE 	  DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
	,p_resource_list_member_Id_tab  IN SYSTEM.PA_NUM_TBL_TYPE 	  DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
	,p_ra_date_tab                  IN SYSTEM.PA_DATE_TBL_TYPE        DEFAULT SYSTEM.PA_DATE_TBL_TYPE()
	,p_task_id_tab                  IN SYSTEM.PA_NUM_TBL_TYPE         DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
	,p_quantity_tab			IN SYSTEM.PA_NUM_TBL_TYPE 	  DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
	,p_txn_currency_code_ovr_tab	IN SYSTEM.PA_VARCHAR2_15_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_15_TBL_TYPE()
	,p_cost_rate_override_tab       IN SYSTEM.PA_NUM_TBL_TYPE 	  DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
	,p_burden_rate_override_tab     IN SYSTEM.PA_NUM_TBL_TYPE 	  DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
	,p_bill_rate_override_tab       IN SYSTEM.PA_NUM_TBL_TYPE 	  DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
	,x_resource_assignment_id_tab   OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE
	,x_resource_list_member_Id_tab  OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE
	,x_expenditure_ou_tab           OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE
	,x_raw_cost_rate_tab		OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE
	,x_burden_cost_rate_tab         OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE
	,x_burden_multiplier_tab        OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE
	,x_ind_compiled_set_id_tab      OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE
	,x_bill_rate_tab                OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE
	,x_markup_percent_tab           OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE
	,x_txn_currency_code_tab        OUT NOCOPY SYSTEM.PA_VARCHAR2_15_TBL_TYPE
	,x_cost_txn_curr_code_tab        OUT NOCOPY SYSTEM.PA_VARCHAR2_15_TBL_TYPE
	,x_rev_txn_curr_code_tab        OUT NOCOPY SYSTEM.PA_VARCHAR2_15_TBL_TYPE
	,x_cost_rejection_code_tab      OUT NOCOPY SYSTEM.PA_VARCHAR2_30_TBL_TYPE
	,x_burden_rejection_code_tab    OUT NOCOPY SYSTEM.PA_VARCHAR2_30_TBL_TYPE
	,x_revenue_rejection_code_tab   OUT NOCOPY SYSTEM.PA_VARCHAR2_30_TBL_TYPE
	,x_return_status                OUT NOCOPY VARCHAR2
	,x_msg_data			OUT NOCOPY VARCHAR2
	,x_msg_count			OUT NOCOPY NUMBER
	) IS

	l_plsql_index_tab		SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
        l_resource_assignment_id_tab   	SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
	l_resource_list_member_Id_tab   SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
	l_task_id_tab                   SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
        l_quantity_tab                 	SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
        l_txn_currency_code_tab         SYSTEM.PA_VARCHAR2_15_TBL_TYPE := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();
        l_txn_currency_code_ovr_tab    	SYSTEM.PA_VARCHAR2_15_TBL_TYPE := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();
        l_curr_conv_reqd_flag_tab      	SYSTEM.PA_VARCHAR2_15_TBL_TYPE := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();
        l_cost_rate_override_tab       	SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
        l_burden_rate_override_tab     	SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
        l_bill_rate_override_tab	SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
	l_ra_date_tab                   SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE();
	l_rowid_tab			SYSTEM.PA_VARCHAR2_2000_TBL_TYPE := SYSTEM.PA_VARCHAR2_2000_TBL_TYPE();
	x_rw_cost_rate_override_tab	SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
        x_burden_rate_override_tab SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
        x_bill_rate_override_tab	SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();

        p_activity_code            Varchar2(100) := 'CALCULATE';
	l_return_status          VArchar2(1) := 'S';
	l_billable_flag          Varchar2(1) := 'Y';
	l_calculate_mode         Varchar2(100);
	l_txn_currency_code_override  Varchar2(100);
	l_stage          Varchar2(1000);
	l_task_id         Number;
	RATEAPI_UNEXPECTED_ERRORS    EXCEPTION;
	L_TXNCONVRATE_ERROR          EXCEPTION;
	l_invalid_params		EXCEPTION;
	l_plsql_Tab_Ct		Number;

	x_dummy_curr_code  Varchar2(100);
    	x_dummy_rate_date  Date;
    	x_dummy_rate_type  Varchar2(100);
    	x_dummy_exch_rate  Number;
    	x_dummy_cost       Number;
    	x_Final_Txn_raw_cost               Number;
	x_Final_Txn_quantity               Number;
	x_Final_txn_exch_rate              Number;
	x_final_txn_rate_type              Varchar2(100);
	x_final_txn_rate_date              Date;
	l_Cntr             Number := 0;

	CURSOR CUR_projDetails IS
        SELECT to_number(null)  res_class_bill_rate_sch_id
          ,to_number(null) res_class_raw_cost_sch_id
          ,'N' use_planning_rates_flag
          ,to_number(null) rev_job_rate_sch_id
          ,to_number(null) cost_job_rate_sch_id
          ,to_number(null) rev_emp_rate_sch_id
          ,to_number(null) cost_emp_rate_sch_id
          ,to_number(null) rev_non_labor_res_rate_sch_id
          ,to_number(null) cost_non_labor_res_rate_sch_id
          ,to_number(null) cost_burden_rate_sch_id
          ,'Y' track_workplan_costs_flag
          ,'COST'  fp_budget_version_type
          ,to_number(null)  resource_list_id
          ,'N' approved_rev_plan_type_flag
          ,'N'    plan_in_multi_curr_flag
          ,to_date(null) etc_start_date
          ,'N' wp_version_flag
      	  ,pp.assign_precedes_task
          ,pp.bill_job_group_id
          ,pp.carrying_out_organization_id
          ,nvl(pp.multi_currency_billing_flag,'N') multi_currency_billing_flag
          ,pp.org_id
          ,pp.non_labor_bill_rate_org_id
          ,pp.project_currency_code
          ,pp.non_labor_schedule_discount
          ,pp.non_labor_schedule_fixed_date
          ,pp.non_lab_std_bill_rt_sch_id
          ,pp.project_type
          ,pp.projfunc_currency_code
          ,pp.emp_bill_rate_schedule_id
          ,pp.job_bill_rate_schedule_id
          ,pp.labor_bill_rate_org_id
          ,pp.labor_sch_type
          ,pp.non_labor_sch_type
      	  ,to_number(null) project_structure_version_id
      	  ,pp.project_id
	  ,pp.segment1		project_name
        FROM pa_projects_all pp
        WHERE pp.project_id = p_project_id;

	CURSOR CUR_VersionDts IS
        SELECT decode(nvl(pfo.use_planning_rates_flag,'N'),'N',pfo.res_class_bill_rate_sch_id,
                          decode(bv.version_type,'REVENUE',pfo.rev_res_class_rate_sch_id,
                                                 'ALL'    ,pfo.rev_res_class_rate_sch_id,
                                                           NULL)) res_class_bill_rate_sch_id
          ,decode(nvl(pfo.use_planning_rates_flag,'N'),'N',pfo.res_class_raw_cost_sch_id,
                          decode(bv.version_type,'COST',pfo.cost_res_class_rate_sch_id,
                                                 'ALL' ,pfo.cost_res_class_rate_sch_id,
                                                           NULL)) res_class_raw_cost_sch_id
          ,nvl(pfo.use_planning_rates_flag,'N') use_planning_rates_flag
          ,decode(nvl(pfo.use_planning_rates_flag,'N'),'N',null,
                          decode(bv.version_type,'REVENUE',pfo.rev_job_rate_sch_id,
                                                 'ALL'    ,pfo.rev_job_rate_sch_id,
                                                 NULL))    rev_job_rate_sch_id
          ,decode(nvl(pfo.use_planning_rates_flag,'N'),'N',null,
                          decode(bv.version_type,'COST'   ,pfo.cost_job_rate_sch_id,
                                                 'ALL'    ,pfo.cost_job_rate_sch_id,
                                                 NULL))     cost_job_rate_sch_id
          ,decode(nvl(pfo.use_planning_rates_flag,'N'),'N',null,
                          decode(bv.version_type,'REVENUE',pfo.rev_emp_rate_sch_id,
                                                 'ALL'    ,pfo.rev_emp_rate_sch_id,
                                                 NULL))    rev_emp_rate_sch_id
          ,decode(nvl(pfo.use_planning_rates_flag,'N'),'N',null,
                          decode(bv.version_type,'COST'   ,pfo.cost_emp_rate_sch_id,
                                                 'ALL'    ,pfo.cost_emp_rate_sch_id,
                                                 NULL))     cost_emp_rate_sch_id
          ,decode(nvl(pfo.use_planning_rates_flag,'N'),'N',null,
                          decode(bv.version_type,'REVENUE',pfo.rev_non_labor_res_rate_sch_id,
                                                 'ALL'    ,pfo.rev_non_labor_res_rate_sch_id,
                                                 NULL))     rev_non_labor_res_rate_sch_id
          ,decode(nvl(pfo.use_planning_rates_flag,'N'),'N',null,
                          decode(bv.version_type,'COST'   ,pfo.cost_non_labor_res_rate_sch_id,
                                                 'ALL'    ,pfo.cost_non_labor_res_rate_sch_id,
                                                 NULL))     cost_non_labor_res_rate_sch_id
          ,decode(nvl(pfo.use_planning_rates_flag,'N'),'N',null,
                          decode(bv.version_type,'COST'   ,pfo.cost_burden_rate_sch_id,
                                                 'ALL'    ,pfo.cost_burden_rate_sch_id,
                                                 NULL))     cost_burden_rate_sch_id
          ,decode(nvl(bv.wp_version_flag,'N'),'Y',NVL(pfo.track_workplan_costs_flag,'N'),'Y') track_workplan_costs_flag
          ,bv.version_type fp_budget_version_type
          ,bv.resource_list_id
          ,nvl(bv.approved_rev_plan_type_flag,'N') approved_rev_plan_type_flag
          ,nvl(pfo.plan_in_multi_curr_flag,'N')    plan_in_multi_curr_flag
          ,bv.etc_start_date
          ,nvl(bv.wp_version_flag,'N') wp_version_flag
      	  ,pp.assign_precedes_task
          ,pp.bill_job_group_id
          ,pp.carrying_out_organization_id
          ,nvl(pp.multi_currency_billing_flag,'N') multi_currency_billing_flag
          ,pp.org_id
          ,pp.non_labor_bill_rate_org_id
          ,pp.project_currency_code
          ,pp.non_labor_schedule_discount
          ,pp.non_labor_schedule_fixed_date
          ,pp.non_lab_std_bill_rt_sch_id
          ,pp.project_type
          ,pp.projfunc_currency_code
          ,pp.emp_bill_rate_schedule_id
          ,pp.job_bill_rate_schedule_id
          ,pp.labor_bill_rate_org_id
          ,pp.labor_sch_type
          ,pp.non_labor_sch_type
      	  ,bv.project_structure_version_id
      	  ,bv.project_id
	  ,pp.segment1		project_name
        FROM pa_proj_fp_options pfo
            ,pa_budget_versions bv
            ,pa_projects_all pp
        WHERE pfo.fin_plan_version_id = bv.budget_version_id
        AND bv.budget_version_id = p_budget_version_id
    	AND pp.project_id = bv.project_id
    	AND pfo.project_id = pp.project_id;
    	rate_rec  CUR_VersionDts%ROWtype;


	CURSOR CUR_RateApi_Attrbs IS
        SELECT tmp.rowid
	   ,tmp.rbs_element_id
	   ,tmp.resource_assignment_id
       	   ,tmp.txn_currency_code
           ,NVL(tmp.txn_plan_quantity,1) 	quantity
           ,tmp.line_start_date			start_date
           ,tmp.burden_cost_rate_override
           ,tmp.rw_cost_rate_override
           ,tmp.bill_rate_override
	   ,tmp.txn_currency_code_override
           ,tmp.task_id
           ,tmp.resource_list_member_id
           ,tmp.unit_of_measure
           ,tmp.resource_class_code
           ,tmp.organization_id
           ,tmp.job_id
           ,tmp.person_id
           ,tmp.expenditure_type
           ,tmp.expenditure_category
       	   ,tmp.revenue_category_code
           ,tmp.event_type
           ,tmp.supplier_id
           ,tmp.non_labor_resource
           ,tmp.bom_resource_id
           ,tmp.inventory_item_id
           ,tmp.item_category_id
           ,tmp.billable_percent
           ,tmp.mfc_cost_type_id
           ,tmp.incurred_by_res_flag
           ,tmp.rate_job_id
           ,tmp.rate_expenditure_type
           ,tmp.sp_fixed_date
           ,tmp.person_type_code
           ,NVL(tmp.rate_based_flag,'N') 	rate_based_flag
           ,tmp.rate_exp_func_curr_code
           ,tmp.rate_expenditure_org_id
           ,tmp.incur_by_res_class_code
           ,tmp.project_role_id
       	   ,tmp.resource_class_flag
       	   ,to_number(null)                     res_format_id --tmp.res_format_id
	   ,tmp.task_bill_rate_org_id     	non_labor_bill_rate_org_id
           ,tmp.task_sch_discount         	non_labor_schedule_discount
           ,tmp.task_sch_date             	non_labor_schedule_fixed_date
           ,tmp.task_std_bill_rate_sch    	non_lab_std_bill_rt_sch_id
           ,tmp.emp_bill_rate_schedule_id
           ,tmp.job_bill_rate_schedule_id
           ,tmp.labor_bill_rate_org_id
           ,tmp.labor_sch_type
           ,tmp.non_labor_sch_type
           ,tmp.top_task_id
	   ,NVL(tmp.billable_flag,'N') 		billable_flag
	   ,to_number(null) 			budget_line_id
	   ,tmp.task_name
	   ,tmp.resource_name
        FROM pa_fp_res_assignments_tmp tmp
        WHERE tmp.budget_version_id = NVL(p_budget_version_id,-9999)
	ORDER BY tmp.rbs_element_id ; /* added this to ensure that In and Out plsql table indexes are mapped */

	l_txn_currency_code                 Varchar2(100);
        l_txn_plan_quantity                 Number;
        l_budget_lines_start_date           Date;
        l_budget_line_id                    Number;
        l_burden_cost_rate_override         Number;
        l_rw_cost_rate_override             Number;
        l_bill_rate_override                Number;
        l_txn_raw_cost                      Number;
        l_txn_burdened_cost                 Number;
        l_txn_revenue               	    Number;
    	x_bill_rate                         Number;
        x_cost_rate                         Number;
        x_burden_cost_rate                  Number;
        x_raw_cost                          Number;
        x_burden_cost                       Number;
        x_raw_revenue                       Number;
        x_bill_markup_percentage            Number;
        l_bill_markup_percentage            Number;
        x_cost_txn_curr_code                Varchar2(100);
        x_rev_txn_curr_code                 Varchar2(100);
        x_raw_cost_rejection_code           Varchar2(100);
        x_burden_cost_rejection_code        Varchar2(100);
        x_revenue_rejection_code            Varchar2(100);
        x_cost_ind_compiled_set_id          Number;
	x_projfunc_rejection_code           Varchar2(100);
	x_project_rejection_code            Varchar2(100);
	X_BURDEN_MULTIPLIER                 Number;
	l_cost_rate_multiplier             CONSTANT pa_labor_cost_multipliers.multiplier%TYPE := 1;
    	l_bill_rate_multiplier             CONSTANT pa_labor_cost_multipliers.multiplier%TYPE := 1;
    	l_cost_sch_type                    VARCHAR2(30) := 'COST';
    	l_mfc_cost_source                  CONSTANT NUMBER := 2;
    	x_stage                            varchar2(1000);
	l_status			   varchar2(100);

    	l_labor_sch_type           pa_projects_all.labor_sch_type%TYPE;
    	l_non_labor_sch_type           pa_projects_all.labor_sch_type%TYPE;

    	/* Added these variables for bug fix: 3681314,3828998 */
	l_override_organization_id         Number;
	l_debug_flag		Varchar2(1) := 'N';
	l_proc_name		VARCHAR2(100) := 'GET_RESOURCE_RATES';

BEGIN

    	l_return_status := 'S';
    	x_return_status := 'S';
	fnd_profile.get('PA_DEBUG_MODE',l_debug_flag);
        l_debug_flag := NVL(l_debug_flag, 'N');

	l_stage := '10:Entered Get_Res_Rates API:ProjId['||p_project_id||']BdgtVer['||p_budget_version_id||']CallingModule['||p_calling_module||']';
	l_stage := l_stage||' SourceContext['||p_source_context||']';
    	print_msg(l_debug_flag,l_proc_name,l_stage);

	/* Initialize tmp tables */
	DELETE FROM PA_FP_RES_ASSIGNMENTS_TMP;
	DELETE FROM PA_FP_ROLLUP_TMP;

	/* Validate Input Params */
	l_resource_assignment_id_tab    := p_resource_assignment_id_tab;
        l_resource_list_member_Id_tab   := p_resource_list_member_Id_tab;
	l_task_id_tab                   := p_task_id_tab;
        l_quantity_tab                  := p_quantity_tab;
        --l_txn_currency_code_tab         := p_txn_currency_code_tab;
        l_txn_currency_code_ovr_tab     := p_txn_currency_code_ovr_tab;
        --l_curr_conv_reqd_flag_tab       := p_curr_conv_reqd_flag_tab;
        l_cost_rate_override_tab        := p_cost_rate_override_tab;
        l_burden_rate_override_tab      := p_burden_rate_override_tab;
        l_bill_rate_override_tab	:= p_bill_rate_override_tab;
	l_ra_date_tab                   := p_ra_date_tab;

	IF NVL(p_project_id,0) = 0 AND NVL(p_budget_version_id,0) = 0 Then
		l_stage := '11: Project and Budget Version is NULL';
        	print_msg(l_debug_flag,l_proc_name,l_stage);
		l_return_status := 'E';
	END If;

	IF ((p_source_context = 'RA' AND l_resource_assignment_id_tab.COUNT = 0 ) OR
	    (p_source_context = 'RLMI' AND l_resource_list_member_Id_tab.COUNT = 0)) Then
		l_stage := '12: RA and RLMI is NULL';
                print_msg(l_debug_flag,l_proc_name,l_stage);
		l_return_status := 'E';
	END IF;

	/* Now Extend the passed in the plsql tables if param is not passed. This has to be done to avoid no data found error*/
	IF (p_source_context = 'RA' AND l_resource_assignment_id_tab.COUNT > 0 ) Then
		l_plsql_Tab_Ct := l_resource_assignment_id_tab.COUNT;
	ElsIf (p_source_context = 'RLMI' AND l_resource_list_member_Id_tab.COUNT > 0) Then
		l_plsql_Tab_Ct :=  l_resource_list_member_Id_tab.COUNT;
	End If;

	FOR i IN 1 .. l_plsql_Tab_Ct LOOP
		If NOT l_plsql_index_tab.exists(i) Then
			l_plsql_index_tab.extend;
			l_plsql_index_tab(i) := i;
		End If;
        	If NOT l_quantity_tab.exists(i) Then
			l_quantity_tab.extend;
			l_quantity_tab(i) := NULL;
		End If;

        	If NOT l_txn_currency_code_tab.exists(i) Then
			l_txn_currency_code_tab.extend;
			l_txn_currency_code_tab(i) := NULL;
                End If;

        	If NOT l_txn_currency_code_ovr_tab.exists(i) Then
			l_txn_currency_code_ovr_tab.extend;
			l_txn_currency_code_ovr_tab(i) := NULL;
                End If;
        	If NOT l_curr_conv_reqd_flag_tab.exists(i) Then
			l_curr_conv_reqd_flag_tab.extend;
			l_curr_conv_reqd_flag_tab(i) := 'N';
                End If;
        	If NOT l_cost_rate_override_tab.exists(i) Then
			l_cost_rate_override_tab.extend;
			l_cost_rate_override_tab(i) := NULL;
                End If;
       		If NOT l_burden_rate_override_tab.exists(i) Then
			l_burden_rate_override_tab.extend;
			l_burden_rate_override_tab(i) := NULL;
                End If;
       		If NOT l_bill_rate_override_tab.exists(i) Then
			l_bill_rate_override_tab.extend;
			l_bill_rate_override_tab(i) := NULL;
                End If;

		If NOT l_task_id_tab.exists(i) Then
			l_task_id_tab.extend;
			l_task_id_tab(i) := NULL;
		End If;

		IF NOT l_ra_date_tab.exists(i) Then
			l_ra_date_tab.extend;
			l_ra_date_tab(i) := NULL;
		End If;
		IF l_txn_currency_code_ovr_tab(i) IS NULL AND
		   (l_cost_rate_override_tab(i) is NOT NULL OR
		   l_burden_rate_override_tab(i) is NOT NULL OR
		   l_bill_rate_override_tab(i) is NOT NULL ) THEN
			l_return_status := 'E';
		END If;
	END LOOP;

	IF l_return_status <> 'S' Then
		Raise l_invalid_params;
	End If;


    	rate_rec := NULL;
	IF p_budget_version_id is NOT NULL Then
    		OPEN CUR_VersionDts;
    		FETCH CUR_VersionDts INTO rate_rec;
    		CLOSE CUR_VersionDts;
	Else
    		OPEN CUR_projDetails;
    		FETCH CUR_projDetails INTO rate_rec;
    		CLOSE CUR_projDetails;
	End If;


	IF l_return_status = 'S' Then
		If (p_source_context = 'RA' AND l_resource_assignment_id_tab.COUNT > 0 ) Then
			l_stage := '13: Calling populate_ra_details API';
                	print_msg(l_debug_flag,l_proc_name,l_stage);
			populate_ra_details
                        ( p_calling_module              => p_calling_module
                        ,p_source_context               => p_source_context
                        ,p_project_id                   => p_project_id
                        ,p_project_type                 => rate_rec.project_type
                        ,p_budget_version_id            => p_budget_version_id
                        ,p_resource_assignment_id_tab   => l_resource_assignment_id_tab
			,p_plsql_index_tab		=> l_plsql_index_tab
                        ,p_task_id_tab                  => l_task_id_tab
			,p_ra_date_tab                  => l_ra_date_tab
                        ,p_quantity_tab                 => l_quantity_tab
                        ,p_txn_currency_code_tab        => l_txn_currency_code_tab
                        ,p_txn_currency_code_ovr_tab    => l_txn_currency_code_ovr_tab
                        ,p_cost_rate_override_tab       => l_cost_rate_override_tab
                        ,p_burden_rate_override_tab     => l_burden_rate_override_tab
                        ,p_bill_rate_override_tab       => l_bill_rate_override_tab
                        ,x_return_status                => l_return_status
                        );
		ELSIF (p_source_context = 'RLMI' AND l_resource_list_member_Id_tab.COUNT > 0) THEN
			-- Call resource defaults to get the resource attributes.
			l_stage := '14: Calling populate_res_details';
                        print_msg(l_debug_flag,l_proc_name,l_stage);
			populate_res_details
        		( p_calling_module              => p_calling_module
        		,p_source_context               => p_source_context
        		,p_project_id                   => p_project_id
        		,p_project_type                 => rate_rec.project_type
        		,p_budget_version_id            => p_budget_version_id
        		,p_resource_list_member_Id_tab  => l_resource_list_member_Id_tab
			,p_plsql_index_tab		=> l_plsql_index_tab
        		,p_task_id_tab                  => l_task_id_tab
			,p_ra_date_tab                  => l_ra_date_tab
        		,p_quantity_tab                 => l_quantity_tab
        		,p_txn_currency_code_tab        => l_txn_currency_code_tab
        		,p_txn_currency_code_ovr_tab    => l_txn_currency_code_ovr_tab
        		,p_cost_rate_override_tab       => l_cost_rate_override_tab
        		,p_burden_rate_override_tab     => l_burden_rate_override_tab
        		,p_bill_rate_override_tab       => l_bill_rate_override_tab
        		,x_return_status                => l_return_status
        		);
		End If;


	END If;

	IF l_return_status = 'S' Then
		l_stage := '15: Update tmp table with task level details';
                print_msg(l_debug_flag,l_proc_name,l_stage);
		/* update the task details */
		UPDATE pa_fp_res_assignments_tmp tmp
		SET (tmp.task_bill_rate_org_id          ---non_labor_bill_rate_org_id
           	   	,tmp.task_sch_discount          ---non_labor_schedule_discount
           		,tmp.task_sch_date              ---non_labor_schedule_fixed_date
           		,tmp.task_std_bill_rate_sch     ---non_lab_std_bill_rt_sch_id
           		,tmp.emp_bill_rate_schedule_id
           		,tmp.job_bill_rate_schedule_id
           		,tmp.labor_bill_rate_org_id
           		,tmp.labor_sch_type
           		,tmp.non_labor_sch_type
           		,tmp.top_task_id
			,tmp.billable_flag
			,tmp.task_name ) =
				(SELECT t.non_labor_bill_rate_org_id
                        		,t.non_labor_schedule_discount
                        		,t.non_labor_schedule_fixed_date
                        		,t.non_lab_std_bill_rt_sch_id
                        		,t.emp_bill_rate_schedule_id
                        		,t.job_bill_rate_schedule_id
                        		,t.labor_bill_rate_org_id
                        		,t.labor_sch_type
                        		,t.non_labor_sch_type
                        		,t.top_task_id
					,NVL(t.billable_flag,'Y')
					,t.task_name
				FROM pa_tasks t
				WHERE t.task_id = tmp.task_id
				AND  t.project_id = p_project_id
				)
		WHERE tmp.budget_version_id = p_budget_version_id
		AND (tmp.task_id is NOT NULL OR tmp.task_id <> 0 )
		AND  EXISTS (select null
			    from pa_tasks t1
			    Where t1.task_id = tmp.task_id
			    and t1.project_id = p_project_id
			    );
	END If;

    	/* for each resource assignment in calctmp open the task cursor */
        IF rate_rec.fp_budget_version_type = 'REVENUE' THEN
            l_calculate_mode  := 'REVENUE';
        ELSIF rate_rec.fp_budget_version_type = 'COST' THEN
            l_calculate_mode  := 'COST';
        ELSIF rate_rec.fp_budget_version_type = 'ALL' THEN
            l_calculate_mode  := 'COST_REVENUE';
        END IF;

	x_resource_assignment_id_tab   := SYSTEM.PA_NUM_TBL_TYPE();
	x_resource_list_member_Id_tab  := SYSTEM.PA_NUM_TBL_TYPE();
	x_raw_cost_rate_tab		:= SYSTEM.PA_NUM_TBL_TYPE();
	x_burden_cost_rate_tab         := SYSTEM.PA_NUM_TBL_TYPE();
	x_burden_multiplier_tab        := SYSTEM.PA_NUM_TBL_TYPE();
	x_ind_compiled_set_id_tab      := SYSTEM.PA_NUM_TBL_TYPE();
	x_bill_rate_tab                := SYSTEM.PA_NUM_TBL_TYPE();
	x_markup_percent_tab           := SYSTEM.PA_NUM_TBL_TYPE();
	x_txn_currency_code_tab        := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();
	x_cost_txn_curr_code_tab       := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();
	x_rev_txn_curr_code_tab        := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();
	x_cost_rejection_code_tab      := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
	x_burden_rejection_code_tab    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
	x_revenue_rejection_code_tab   := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
	x_expenditure_ou_tab           := SYSTEM.PA_NUM_TBL_TYPE();
	/* loop through the tmp table and call rate api for each line */
	l_Cntr := 0;
    	FOR z IN CUR_RateApi_Attrbs LOOP --{
		/* Initialize the out params */
		l_Cntr := l_Cntr +1;

		/* initialize the out params */
		l_rowid_tab.extend;
		x_resource_assignment_id_tab.extend;
        	x_resource_list_member_Id_tab.extend;
        	x_raw_cost_rate_tab.extend;
        	x_burden_cost_rate_tab.extend;
        	x_burden_multiplier_tab.extend;
        	x_ind_compiled_set_id_tab.extend;
        	x_bill_rate_tab.extend;
        	x_markup_percent_tab.extend;
        	x_txn_currency_code_tab.extend;
		x_cost_txn_curr_code_tab.extend;
		x_rev_txn_curr_code_tab.extend;
        	x_cost_rejection_code_tab.extend;
        	x_burden_rejection_code_tab.extend;
        	x_revenue_rejection_code_tab.extend;
		x_rw_cost_rate_override_tab.extend;
                x_burden_rate_override_tab.extend;
		x_bill_rate_override_tab.extend;
		x_expenditure_ou_tab.extend;

		l_rowid_tab(l_Cntr) := z.rowid;
		x_resource_assignment_id_tab(l_Cntr) := z.resource_assignment_id;
        	x_resource_list_member_Id_tab(l_Cntr) := z.resource_list_member_Id;
		x_expenditure_ou_tab(l_Cntr) :=         nvl(z.rate_expenditure_org_id,rate_rec.org_id);
        	x_raw_cost_rate_tab(l_Cntr) := 		null;
        	x_burden_cost_rate_tab(l_Cntr) :=    	null;
        	x_burden_multiplier_tab(l_Cntr) :=      null;
        	x_ind_compiled_set_id_tab(l_Cntr) :=   	null;
        	x_bill_rate_tab(l_Cntr) :=      	null;
        	x_markup_percent_tab(l_Cntr) :=       	null;
        	x_txn_currency_code_tab(l_Cntr) :=      null;
		x_cost_txn_curr_code_tab(l_Cntr) :=     null;
		x_rev_txn_curr_code_tab(l_Cntr) :=      null;
        	x_cost_rejection_code_tab(l_Cntr) :=    null;
        	x_burden_rejection_code_tab(l_Cntr) :=  null;
        	x_revenue_rejection_code_tab(l_Cntr) := null;
		x_rw_cost_rate_override_tab(l_Cntr) :=          null;
                x_burden_rate_override_tab(l_Cntr) :=       null;
		x_bill_rate_override_tab(l_Cntr) :=       null;

    		/* setting the quantity to null to avoid call to rate api with 0 qty */
        	l_txn_plan_quantity := 	z.quantity;
        	l_rw_cost_rate_override := z.rw_cost_rate_override;
        	l_burden_cost_rate_override := z.burden_cost_rate_override;
        	l_bill_rate_override := z.bill_rate_override;
		l_txn_currency_code_override := z.txn_currency_code_override;
        	l_txn_raw_cost := NULL;
        	l_txn_burdened_cost := NULL;
        	l_txn_revenue := NULL;
        	x_raw_cost    := NULL;
        	x_burden_cost := NULL;
        	x_raw_revenue := NULL;
        	x_bill_rate   := NULL;
        	x_cost_rate   := NULL;
        	x_burden_cost_rate := NULL;
        	x_burden_multiplier := NULL;
		x_bill_markup_percentage := NULL;
                x_cost_txn_curr_code := NULL;
                x_rev_txn_curr_code := NULL;
                x_raw_cost_rejection_code := NULL;
                x_burden_cost_rejection_code := NULL;
                x_revenue_rejection_code := NULL;
                x_cost_ind_compiled_set_id := NULL;

		IF NVL(z.rate_based_flag,'N') = 'N' Then
			IF rate_rec.fp_budget_version_type in ('COST','ALL') Then
				l_txn_currency_code_override := NVL(l_txn_currency_code_override,rate_rec.project_currency_code);
				x_cost_txn_curr_code := NVL(l_txn_currency_code_override,rate_rec.project_currency_code);
				x_cost_rate := 1;
				l_rw_cost_rate_override := 1;
			Else
				l_txn_currency_code_override := NVL(l_txn_currency_code_override,rate_rec.project_currency_code);
				x_rev_txn_curr_code :=  NVL(l_txn_currency_code_override,rate_rec.project_currency_code);
				x_bill_rate := 1;
				l_bill_rate_override := 1;
			End IF;
		End If;
        	l_override_organization_id := NULL;
            	IF l_override_organization_id is NULL Then
                	l_stage := 'Calling Override_exp_organization ';
                        pa_cost.Override_exp_organization
                        (P_item_date                  => z.start_date
                        ,P_person_id                  => z.person_id
                        ,P_project_id                 => p_project_id
                        ,P_incurred_by_organz_id      => z.organization_id
                        ,P_Expenditure_type           => nvl(z.expenditure_type,z.rate_expenditure_type)
                        ,X_overr_to_organization_id   => l_override_organization_id
                        ,X_return_status              => l_return_status
                        ,X_msg_count                  => x_msg_count
                        ,X_msg_data                   => x_msg_data
                        );
                        l_stage := 'End of Override_exp_organization retSts['||l_return_status||']';
               End If;
        BEGIN
         l_task_id := z.task_id;
         If l_task_id = 0 Then
            l_task_id := NULL;
         End If;

        /* Bug fix:4133047 pass the Task level or project level labor and non-labor sch types to bill rate api in order to
        * derive the markup based on burden schedule or bill rate schedule
        */
        If l_task_id IS NOT NULL THEN
                    l_labor_sch_type:= z.labor_sch_type;
                    l_non_labor_sch_type  := z.non_labor_sch_type;
        Else
                    l_labor_sch_type:= rate_rec.labor_sch_type;
                    l_non_labor_sch_type  := rate_rec.non_labor_sch_type;
        End If;

	    l_stage := 'Calling get_planning_rates API for lineId ['||z.rbs_element_id||']';
       print_msg(l_debug_flag,l_proc_name,' **REQUIRED** = MUST BE PASSED TO RATE API');
       print_msg(l_debug_flag,l_proc_name,' p_project_id                => '||p_project_id);
       print_msg(l_debug_flag,l_proc_name,' p_task_id                   => '||l_task_id);
       print_msg(l_debug_flag,l_proc_name,' p_top_task_id               => '||z.top_task_id);
       print_msg(l_debug_flag,l_proc_name,' p_person_id                 => '||z.person_id);
       print_msg(l_debug_flag,l_proc_name,' p_job_id                    => '||z.job_id);
       print_msg(l_debug_flag,l_proc_name,' p_bill_job_grp_id           => '||rate_rec.bill_job_group_id);
       print_msg(l_debug_flag,l_proc_name,' p_project_organz_id         => '||rate_rec.carrying_out_organization_id);
       print_msg(l_debug_flag,l_proc_name,' p_rev_res_class_rate_sch_id => '||rate_rec.res_class_bill_rate_sch_id);
       print_msg(l_debug_flag,l_proc_name,' p_cost_res_class_rate_sch_id=> '||rate_rec.res_class_raw_cost_sch_id);
       print_msg(l_debug_flag,l_proc_name,' p_rev_task_nl_rate_sch_id   => '||z.non_lab_std_bill_rt_sch_id);
       print_msg(l_debug_flag,l_proc_name,' p_rev_proj_nl_rate_sch_id   => '||rate_rec.non_lab_std_bill_rt_sch_id);
       print_msg(l_debug_flag,l_proc_name,' p_rev_job_rate_sch_id       => '||nvl(z.job_bill_rate_schedule_id,rate_rec.job_bill_rate_schedule_id));
       print_msg(l_debug_flag,l_proc_name,' p_rev_emp_rate_sch_id       => '||nvl(z.emp_bill_rate_schedule_id,rate_rec.emp_bill_rate_schedule_id));
       print_msg(l_debug_flag,l_proc_name,' p_plan_rev_job_rate_sch_id  => '||rate_rec.rev_job_rate_sch_id);
       print_msg(l_debug_flag,l_proc_name,' p_plan_cost_job_rate_sch_id => '||rate_rec.cost_job_rate_sch_id);
       print_msg(l_debug_flag,l_proc_name,' p_plan_rev_emp_rate_sch_id  => '||rate_rec.rev_emp_rate_sch_id);
       print_msg(l_debug_flag,l_proc_name,' p_plan_cost_emp_rate_sch_id => '||rate_rec.cost_emp_rate_sch_id);
       print_msg(l_debug_flag,l_proc_name,' p_plan_rev_nlr_rate_sch_id  => '||rate_rec.rev_non_labor_res_rate_sch_id);
       print_msg(l_debug_flag,l_proc_name,' p_plan_cost_nlr_rate_sch_id => '||rate_rec.cost_non_labor_res_rate_sch_id);
       print_msg(l_debug_flag,l_proc_name,' p_plan_burden_cost_sch_id   => '||rate_rec.cost_burden_rate_sch_id);
       print_msg(l_debug_flag,l_proc_name,' p_calculate_mode            => '||l_calculate_mode);
       print_msg(l_debug_flag,l_proc_name,' p_mcb_flag                  => '||rate_rec.multi_currency_billing_flag);
       print_msg(l_debug_flag,l_proc_name,' p_cost_rate_multiplier      => '||l_cost_rate_multiplier);
       print_msg(l_debug_flag,l_proc_name,' p_bill_rate_multiplier      => '||l_bill_rate_multiplier);
       print_msg(l_debug_flag,l_proc_name,' p_cost_sch_type             => '||l_cost_sch_type);
       print_msg(l_debug_flag,l_proc_name,' p_labor_sch_type            => '||rate_rec.labor_sch_type);
       print_msg(l_debug_flag,l_proc_name,' p_non_labor_sch_type        => '||rate_rec.non_labor_sch_type);
       print_msg(l_debug_flag,l_proc_name,' p_labor_schdl_discnt        => '||NULL);
       print_msg(l_debug_flag,l_proc_name,' p_labor_bill_rate_org_id    => '||rate_rec.labor_bill_rate_org_id);
       print_msg(l_debug_flag,l_proc_name,' p_labor_std_bill_rate_schdl => '||NULL);
       print_msg(l_debug_flag,l_proc_name,' p_labor_schdl_fixed_date    => '||NULL);
       print_msg(l_debug_flag,l_proc_name,' p_project_org_id            => '||rate_rec.org_id);
       print_msg(l_debug_flag,l_proc_name,' p_project_type              => '||rate_rec.project_type);
       print_msg(l_debug_flag,l_proc_name,' p_expenditure_type          => '||nvl(z.expenditure_type,z.rate_expenditure_type));
       print_msg(l_debug_flag,l_proc_name,' p_non_labor_resource        => '||z.non_labor_resource);
       print_msg(l_debug_flag,l_proc_name,' p_incurred_by_organz_id     => '||z.organization_id);
       print_msg(l_debug_flag,l_proc_name,' p_override_to_organz_id     => '||l_override_organization_id);
       print_msg(l_debug_flag,l_proc_name,' p_expenditure_org_id        => '||nvl(z.rate_expenditure_org_id,rate_rec.org_id));
       print_msg(l_debug_flag,l_proc_name,' p_assignment_precedes_task  => '||rate_rec.assign_precedes_task);
       print_msg(l_debug_flag,l_proc_name,' p_planning_transaction_id   => '||z.budget_line_id);
       print_msg(l_debug_flag,l_proc_name,' p_task_bill_rate_org_id     => '||z.non_labor_bill_rate_org_id);
       print_msg(l_debug_flag,l_proc_name,' p_project_bill_rate_org_id  => '||rate_rec.non_labor_bill_rate_org_id);
       print_msg(l_debug_flag,l_proc_name,' p_nlr_organization_id       => '||z.organization_id);
       print_msg(l_debug_flag,l_proc_name,' p_project_sch_date          => '||rate_rec.non_labor_schedule_fixed_date);
       print_msg(l_debug_flag,l_proc_name,' p_task_sch_date             => '||z.non_labor_schedule_fixed_date);
       print_msg(l_debug_flag,l_proc_name,' p_project_sch_discount      => '||rate_rec.non_labor_schedule_discount);
       print_msg(l_debug_flag,l_proc_name,' p_task_sch_discount         => '||z.non_labor_schedule_discount);
       print_msg(l_debug_flag,l_proc_name,' p_inventory_item_id         => '||z.inventory_item_id);
       print_msg(l_debug_flag,l_proc_name,' p_BOM_resource_Id           => '||z.bom_resource_id);
       print_msg(l_debug_flag,l_proc_name,' P_mfc_cost_type_id          => '||z.mfc_cost_type_id);
       print_msg(l_debug_flag,l_proc_name,' P_item_category_id          => '||z.item_category_id);
       print_msg(l_debug_flag,l_proc_name,' p_mfc_cost_source           => '||l_mfc_cost_source);
       print_msg(l_debug_flag,l_proc_name,' ** p_assignment_id             => '||z.resource_assignment_id);
       print_msg(l_debug_flag,l_proc_name,' ** p_rlmi_id                   => '||z.resource_list_member_id);
       print_msg(l_debug_flag,l_proc_name,' ** p_resource_class            => '||z.resource_class_code);
       print_msg(l_debug_flag,l_proc_name,' ** p_planning_resource_format  => '||z.res_format_id);
       print_msg(l_debug_flag,l_proc_name,' ** p_use_planning_rates_flag   => '||rate_rec.use_planning_rates_flag);
       print_msg(l_debug_flag,l_proc_name,' ** p_rate_based_flag           => '||z.rate_based_flag);
       print_msg(l_debug_flag,l_proc_name,' ** p_uom                       => '||z.unit_of_measure);
       print_msg(l_debug_flag,l_proc_name,' ** p_quantity                  => '||l_txn_plan_quantity);
       print_msg(l_debug_flag,l_proc_name,' ** p_item_date                 => '||z.start_date);
       print_msg(l_debug_flag,l_proc_name,' ** p_cost_override_rate        => '||l_rw_cost_rate_override);
       print_msg(l_debug_flag,l_proc_name,' ** p_revenue_override_rate     => '||l_bill_rate_override);
       print_msg(l_debug_flag,l_proc_name,' ** p_override_burden_cost_rate => '||l_burden_cost_rate_override);
       print_msg(l_debug_flag,l_proc_name,' ** p_override_currency_code    => '||l_txn_currency_code_override);
       print_msg(l_debug_flag,l_proc_name,' ** p_txn_currency_code         => '||l_txn_currency_code);
       print_msg(l_debug_flag,l_proc_name,' ** p_raw_cost                  => '||l_txn_raw_cost);
       print_msg(l_debug_flag,l_proc_name,' ** p_burden_cost               => '||l_txn_burdened_cost);
       print_msg(l_debug_flag,l_proc_name,' ** p_raw_revenue               => '||l_txn_revenue);
       print_msg(l_debug_flag,l_proc_name,' ** p_billable_flag             => '||l_billable_flag);
            pa_plan_revenue.Get_planning_Rates
                (
                                p_project_id                           =>  p_project_id
                                ,p_task_id                              => l_task_id
                                ,p_top_task_id                          => z.top_task_id
                                ,p_person_id                            => z.person_id
                                ,p_job_id                               => z.job_id
                                ,p_bill_job_grp_id                      => rate_rec.bill_job_group_id
                                ,p_resource_class                       => z.resource_class_code
                                ,p_planning_resource_format             => z.res_format_id
                                ,p_use_planning_rates_flag              => NVL(rate_rec.use_planning_rates_flag,'N')
                                ,p_rate_based_flag                      => NVL(z.rate_based_flag,'N')
                                ,p_uom                                  => z.unit_of_measure
                                ,p_system_linkage                       => NULL
                                ,p_project_organz_id                    => rate_rec.carrying_out_organization_id
                                ,p_rev_res_class_rate_sch_id            => rate_rec.res_class_bill_rate_sch_id
                                ,p_cost_res_class_rate_sch_id           => rate_rec.res_class_raw_cost_sch_id
                                ,p_rev_task_nl_rate_sch_id              => z.non_lab_std_bill_rt_sch_id
                                ,p_rev_proj_nl_rate_sch_id              => rate_rec.non_lab_std_bill_rt_sch_id
                                ,p_rev_job_rate_sch_id                  => rate_rec.job_bill_rate_schedule_id
                                ,p_rev_emp_rate_sch_id                  => rate_rec.emp_bill_rate_schedule_id
                                ,p_plan_rev_job_rate_sch_id             => rate_rec.rev_job_rate_sch_id
                                ,p_plan_cost_job_rate_sch_id            => rate_rec.cost_job_rate_sch_id
                                ,p_plan_rev_emp_rate_sch_id             => rate_rec.rev_emp_rate_sch_id
                                ,p_plan_cost_emp_rate_sch_id            => rate_rec.cost_emp_rate_sch_id
                                ,p_plan_rev_nlr_rate_sch_id             => rate_rec.rev_non_labor_res_rate_sch_id
                                ,p_plan_cost_nlr_rate_sch_id            => rate_rec.cost_non_labor_res_rate_sch_id
                                ,p_plan_burden_cost_sch_id              => rate_rec.cost_burden_rate_sch_id
                                ,p_calculate_mode                       => l_calculate_mode
                                ,p_mcb_flag                             => rate_rec.multi_currency_billing_flag
                                ,p_cost_rate_multiplier                 => l_cost_rate_multiplier
                                ,p_bill_rate_multiplier                 => l_bill_rate_multiplier
                                ,p_quantity                             => l_txn_plan_quantity
                                ,p_item_date                            => z.start_date
                                ,p_cost_sch_type                        => l_cost_sch_type
                                ,p_labor_sch_type                       => l_labor_sch_type
                                ,p_non_labor_sch_type                   => l_non_labor_sch_type
                                ,p_labor_schdl_discnt                   => NULL
                                ,p_labor_bill_rate_org_id               => rate_rec.labor_bill_rate_org_id
                                ,p_labor_std_bill_rate_schdl            => NULL
                                ,p_labor_schdl_fixed_date               => NULL
                                ,p_assignment_id                        => z.resource_assignment_id
                                ,p_project_org_id                       => rate_rec.org_id
                                ,p_project_type                         => rate_rec.project_type
                                ,p_expenditure_type                     => nvl(z.expenditure_type,z.rate_expenditure_type)
                                ,p_non_labor_resource                   => z.non_labor_resource
                                ,p_incurred_by_organz_id                => z.organization_id
                                ,p_override_to_organz_id                => l_override_organization_id
                                ,p_expenditure_org_id                   => nvl(z.rate_expenditure_org_id,rate_rec.org_id)
                                ,p_assignment_precedes_task             => rate_rec.assign_precedes_task
                                ,p_planning_transaction_id              => z.budget_line_id
                                ,p_task_bill_rate_org_id                => z.non_labor_bill_rate_org_id
                                ,p_project_bill_rate_org_id             => rate_rec.non_labor_bill_rate_org_id
                                ,p_nlr_organization_id                  => z.organization_id
                                ,p_project_sch_date                     => rate_rec.non_labor_schedule_fixed_date
                                ,p_task_sch_date                        => z.non_labor_schedule_fixed_date
                                ,p_project_sch_discount                 => rate_rec.non_labor_schedule_discount
                                ,p_task_sch_discount                    => z.non_labor_schedule_discount
                                ,p_inventory_item_id                    => z.inventory_item_id
                                ,p_BOM_resource_Id                      => z.bom_resource_id
                                ,P_mfc_cost_type_id                     => z.mfc_cost_type_id
                                ,P_item_category_id                     => z.item_category_id
                                ,p_mfc_cost_source                      => l_mfc_cost_source
                                ,p_cost_override_rate                   => l_rw_cost_rate_override
                                ,p_revenue_override_rate                => l_bill_rate_override
                                ,p_override_burden_cost_rate            => l_burden_cost_rate_override
                                ,p_override_currency_code               => l_txn_currency_code_override
                                ,p_txn_currency_code                    => l_txn_currency_code
                                ,p_raw_cost                             => l_txn_raw_cost
                                ,p_burden_cost                          => l_txn_burdened_cost
                                ,p_raw_revenue                          => l_txn_revenue
				,p_billability_flag                     => l_billable_flag
                                ,x_bill_rate                            => x_bill_rate
                                ,x_cost_rate                            => x_cost_rate
                                ,x_burden_cost_rate                     => x_burden_cost_rate
                                ,x_burden_multiplier                    => x_burden_multiplier
                                ,x_raw_cost                             => x_raw_cost
                                ,x_burden_cost                          => x_burden_cost
                                ,x_raw_revenue                          => x_raw_revenue
                                ,x_bill_markup_percentage               => x_bill_markup_percentage
                                ,x_cost_txn_curr_code                   => x_cost_txn_curr_code
                                ,x_rev_txn_curr_code                    => x_rev_txn_curr_code
                                ,x_raw_cost_rejection_code              => x_raw_cost_rejection_code
                                ,x_burden_cost_rejection_code           => x_burden_cost_rejection_code
                                ,x_revenue_rejection_code               => x_revenue_rejection_code
                                ,x_cost_ind_compiled_set_id             => x_cost_ind_compiled_set_id
                                ,x_return_status                        => l_return_status
                                ,x_msg_data                             => x_msg_data
                                ,x_msg_count                            => x_msg_count
                                );

			/* in the msp flow, if the rates are not found then show it as zero, may not be possible to show the
			 * cost /burden rejections
			 */
			If p_calling_module = 'MSP' Then
				If l_return_status = 'E' then
					l_return_status := 'S';
					x_msg_count := 0;
				End If;
			End If;
            		l_stage := 'Return Sts of Rate API['||l_return_status||']msgData['||x_msg_data||']';
			If l_return_status = 'U' Then
			   x_return_status := l_return_status;
                           pa_utils.add_message
                          (p_app_short_name => 'PA'
                          ,p_msg_name       => 'PA_FP_ERROR_FROM_RATE_API_CALL'
                          ,p_token1         => 'G_PROJECT_NAME'
                          ,p_value1         => rate_rec.project_name
                          ,p_token2         => 'G_TASK_NAME'
                          ,p_value2         => z.task_name
                          ,p_token3         => 'G_RESOURCE_NAME'
                          ,p_value3         => z.resource_name
                          ,p_token4         => 'TO_CHAR(L_TXN_CURRENCY_CODE)'
                          ,p_value4         => l_txn_currency_code
                          ,p_token5         => 'TO_CHAR(L_BUDGET_LINES_START_DATE)'
                          ,p_value5         => to_char(z.start_date));
			  RAISE RATEAPI_UNEXPECTED_ERRORS;
			End If;

	   EXCEPTION
		WHEN OTHERS THEN
			l_stage := 'Unexpected error from Rate API['||l_return_status||']msgData['||x_msg_data||']';
                	x_raw_cost_rejection_code      := substr('PA_FP_ERROR_FROM_RATE_API_CALL',1,30);
                	x_burden_cost_rejection_code   := substr(SQLERRM,1,30);
                	x_revenue_rejection_code       := substr('PA_FP_ERROR_FROM_RATE_API_CALL',1,30);
                	   x_return_status := l_return_status;
             		   pa_utils.add_message
                          (p_app_short_name => 'PA'
                          ,p_msg_name       => 'PA_FP_ERROR_FROM_RATE_API_CALL'
                          ,p_token1         => 'G_PROJECT_NAME'
                          ,p_value1         => rate_rec.project_name
                          ,p_token2         => 'G_TASK_NAME'
                          ,p_value2         => z.task_name
                          ,p_token3         => 'G_RESOURCE_NAME'
                          ,p_value3         => z.resource_name
                          ,p_token4         => 'TO_CHAR(L_TXN_CURRENCY_CODE)'
                          ,p_value4         => l_txn_currency_code
                          ,p_token5         => 'TO_CHAR(L_BUDGET_LINES_START_DATE)'
                          ,p_value5         => to_char(z.start_date));
                        RAISE RATEAPI_UNEXPECTED_ERRORS;
	   END;

	   IF l_rw_cost_rate_override is NOT NULL Then
		x_cost_rate := l_rw_cost_rate_override;
		x_cost_txn_curr_code := l_txn_currency_code_override;
	   End If;
	   If l_burden_cost_rate_override is NOT NULL Then
		x_burden_cost_rate := l_burden_cost_rate_override;
	   End If;
	   If l_bill_rate_override is NOT NULL Then
		x_bill_rate := l_bill_rate_override;
	   End If;

	   l_stage := 'RawValues returned from Rate API:x_cost_txn_curr_code['||x_cost_txn_curr_code||']x_cost_rate['||x_cost_rate||']';
	   l_stage := l_stage||']x_burden_cost_rate['||x_burden_cost_rate||']x_burden_multiplier['||x_burden_multiplier||']';
	   l_stage := l_stage||'x_rev_txn_curr_code['||x_rev_txn_curr_code||']x_bill_rate['||x_bill_rate||']';
	   print_msg(l_debug_flag,l_proc_name,l_stage);
	   l_stage := 'CostRejection['||x_raw_cost_rejection_code||']BurdRejection['||x_burden_cost_rejection_code||']';
	   l_stage := l_stage||']x_revenue_rejection_code['||x_revenue_rejection_code||']';
	   print_msg(l_debug_flag,l_proc_name,l_stage);

		IF x_cost_rate is NOT NULL AND x_burden_cost_rejection_code is NULL AND l_return_status = 'S' Then --{

			--convert the cost amounts to burden currency if burden rate is passed
			IF l_burden_cost_rate_override is NOT NULL and l_txn_currency_code_override is NOT NULL Then
				IF x_cost_rate is NOT NULL and
				   x_cost_txn_curr_code <> l_txn_currency_code_override Then
				   	x_dummy_curr_code := l_txn_currency_code_override;
					l_stage := 'Calling multi currency api to convert raw to burden currency';
					x_final_txn_exch_rate := NULL;
					x_final_txn_rate_type := NULL;
					x_final_txn_rate_date := NULL;
					x_final_txn_raw_cost  := NULL;
					print_msg(l_debug_flag,l_proc_name,l_stage);
        				pa_multi_currency_txn.get_currency_amounts (
                       			p_project_id                  => p_project_id
                       			,p_exp_org_id                  => nvl(z.rate_expenditure_org_id,rate_rec.org_id)
                       			,p_calling_module              => 'WORKPLAN'
                       			,p_task_id                     => z.task_id
                       			,p_ei_date                     => z.start_date
                       			,p_denom_raw_cost              => 1
                       			,p_denom_curr_code             => x_cost_txn_curr_code
                       			,p_acct_curr_code              => x_dummy_curr_code
                       			,p_accounted_flag              => 'N'
                       			,p_acct_rate_date              => x_dummy_rate_date
                       			,p_acct_rate_type              => x_dummy_rate_type
                       			,p_acct_exch_rate              => x_dummy_exch_rate
                       			,p_acct_raw_cost               => x_dummy_cost
                       			,p_project_curr_code           => l_txn_currency_code_override
                       			,p_project_rate_type           => x_final_txn_rate_type
                       			,p_project_rate_date           => x_final_txn_rate_date
                       			,p_project_exch_rate           => x_final_txn_exch_rate
                       			,p_project_raw_cost            => x_final_txn_raw_cost
                       			,p_projfunc_curr_code          => x_dummy_curr_code
                       			,p_projfunc_cost_rate_type     => x_dummy_rate_type
                       			,p_projfunc_cost_rate_date     => x_dummy_rate_date
                       			,p_projfunc_cost_exch_rate     => x_dummy_exch_rate
                       			,p_projfunc_raw_cost           => x_dummy_cost
                       			,p_system_linkage              => 'NER'
               				,p_structure_version_id        => rate_rec.project_structure_version_id
                       			,p_status                      => l_status
                       			,p_stage                       => x_stage) ;

					l_stage := 'x_final_txn_exch_rate['||x_final_txn_exch_rate||']status['||l_status||']';
					print_msg(l_debug_flag,l_proc_name,l_stage);
			             IF x_final_txn_exch_rate is NULL OR l_status is NOT NULL Then
                            		x_return_status := 'U';
                            		l_return_status := 'U';
                            		pa_utils.add_message
                            		( p_app_short_name => 'PA'
                            		,p_msg_name       => 'PA_FP_PROJ_NO_TXNCONVRATE'
                            		,p_token1         => 'G_PROJECT_NAME'
                            		,p_value1         =>  rate_rec.project_name
                            		,p_token2         => 'FROMCURRENCY'
                            		,p_value2         => x_cost_txn_curr_code
                            		,p_token3         => 'TOCURRENCY'
                            		,p_value3         => l_txn_currency_code_override
                			,p_token4         => 'CONVERSION_TYPE'
                			,p_value4         => x_final_txn_rate_type
                			,p_token5         => 'CONVERSION_DATE'
                			,p_value5         => x_final_txn_rate_date
                            		);
                            		x_msg_data := 'PA_FP_PROJ_NO_TXNCONVRATE';
					RAISE L_TXNCONVRATE_ERROR;
                       		    END IF;
				    IF NVL(l_return_status,'S') = 'S' Then
					x_cost_rate := x_final_txn_exch_rate * x_cost_rate;
                                        x_cost_txn_curr_code := l_txn_currency_code_override;
				    End If;

				End If;
			END IF;
		END IF; --}
		/* Assign derived values to the out params */
		l_stage := 'Assigning derived values to out params:'||x_cost_rate||':'||x_burden_cost_rate||':'||x_bill_rate;
		x_raw_cost_rate_tab(l_Cntr) :=          x_cost_rate;
                x_burden_cost_rate_tab(l_Cntr) :=       x_burden_cost_rate;
                x_burden_multiplier_tab(l_Cntr) :=      x_burden_multiplier;
                x_ind_compiled_set_id_tab(l_Cntr) :=    x_cost_ind_compiled_set_id;
                x_bill_rate_tab(l_Cntr) :=              x_bill_rate;
                x_markup_percent_tab(l_Cntr) :=         x_bill_markup_percentage;
                x_txn_currency_code_tab(l_Cntr) :=      null;
		x_cost_txn_curr_code_tab(l_Cntr):=      x_cost_txn_curr_code;
		x_rev_txn_curr_code_tab(l_Cntr):=       x_rev_txn_curr_code;
                x_cost_rejection_code_tab(l_Cntr) :=    x_raw_cost_rejection_code;
                x_burden_rejection_code_tab(l_Cntr) :=  x_burden_cost_rejection_code;
                x_revenue_rejection_code_tab(l_Cntr) := x_revenue_rejection_code;

     END LOOP; --}
	print_msg(l_debug_flag,l_proc_name,'End of rate api loop');
	/*** Not required as re arrangig the plsql indexes
	IF l_rowid_tab.COUNT > 0 Then
		l_stage := 'Inserting rate api values into rollup tmp table';
		FORALL i IN l_rowid_tab.FIRST .. l_rowid_tab.LAST
		INSERT INTO pa_fp_rollup_tmp tmp
		(resource_assignment_id
		,system_reference1
		,txn_currency_code
		,cost_rate
		,rw_cost_rate_override
		,burden_cost_rate
		,burden_cost_rate_override
		,bill_rate
		,bill_rate_override
		,burden_multiplier
		,bill_markup_percentage
		,cost_txn_curr_code
		,rev_txn_curr_code
		,cost_ind_compiled_set_id
		,cost_rejection_code
		,burden_rejection_code
		,revenue_rejection_code
		) VALUES
		(x_resource_assignment_id_tab(i)
		,x_resource_list_member_id_tab(i)
		,x_txn_currency_code_tab(i)
		,x_raw_cost_rate_tab(i)
		,x_rw_cost_rate_override_tab(i)
		,x_burden_cost_rate_tab(i)
		,x_burden_rate_override_tab(i)
		,x_bill_rate_tab(i)
		,x_bill_rate_override_tab(i)
		,x_burden_multiplier_tab(i)
		,x_markup_percent_tab(i)
		,x_cost_txn_curr_code_tab(i)
		,x_rev_txn_curr_code_tab(i)
		,x_ind_compiled_set_id_tab(i)
		,x_cost_rejection_code_tab(i)
                ,x_burden_rejection_code_tab(i)
                ,x_revenue_rejection_code_tab(i)
		);
	END IF;
	***/

	x_return_status := l_return_status;
	l_stage := 'Return status of Get_resource_Rates['||x_return_status||']';
	print_msg(l_debug_flag,l_proc_name,l_stage);
	/* added this to avoid msg added in the stack during bill rate api */
	IF x_return_status = 'S' then
		FND_MSG_PUB.initialize;
	End If;
EXCEPTION

	WHEN L_INVALID_PARAMS THEN
		PRINT_msg('Y',l_proc_name,'INVALID PARAMS FOR PROCESSING');
                x_return_status := 'E';
		RAISE;

	WHEN RATEAPI_UNEXPECTED_ERRORS then
		PRINT_msg('Y',l_proc_name,'Rate API returned with unexpected error');
		x_return_status := 'U';
		RAISE;
	WHEN L_TXNCONVRATE_ERROR THEN
		PRINT_msg('Y',l_proc_name,'Error from Multi-Currency API');
                x_return_status := 'U';
                RAISE;

	WHEN OTHERS THEN
		PRINT_msg('Y',l_proc_name,'EXCEPTIONS: '||SQLCODE||SQLERRM);
		x_return_status := 'U';
		RAISE;

END Get_Resource_Rates;

/** MRC Elimination: Moved this procedure from pa_mrc_finplan pkg to utils as
 *  package itself is dropped
 */
PROCEDURE POPULATE_BL_MAP_TMP
	(p_source_fin_plan_version_id  IN PA_BUDGET_LINES.budget_version_id%TYPE
          ,x_return_status   OUT NOCOPY VARCHAR2
          ,x_msg_count       OUT NOCOPY NUMBER
          ,x_msg_data        OUT NOCOPY VARCHAR2
         ) IS

  CURSOR C_TMP_BUDGET_LINE IS
      SELECT
           budget_line_id
          ,pa_budget_lines_s.nextval

       FROM
           pa_budget_lines
       WHERE
           budget_version_id = p_source_fin_plan_version_id ;



 l_msg_count       NUMBER := 0;
 l_data            VARCHAR2(2000);
 l_msg_data        VARCHAR2(2000);
 l_error_msg_code  VARCHAR2(30);
 l_msg_index_out   NUMBER;
 l_debug_mode      VARCHAR2(30);
 g_module_name VARCHAR2(30) := 'pa.plsql.PA_FIN_PLAN_UTILS2';
 g_plsql_max_array_size NUMBER := 200 ;

 TYPE l_budget_line_id_tbl_typ  IS TABLE OF
           pa_budget_lines.BUDGET_LINE_ID%TYPE INDEX BY BINARY_INTEGER ;

 l_source_budget_line_id_tbl  l_budget_line_id_tbl_typ ;
 l_target_budget_line_id_tbl  l_budget_line_id_tbl_typ ;


BEGIN

     -- Set the error stack.
        pa_debug.set_err_stack('PA_MRC_FINPLAN.POPULATE_BL_MAP_TMP');

     -- Get the Debug mode into local variable and set it to 'Y'if its NULL
        fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
        l_debug_mode := NVL(l_debug_mode, 'Y');

     -- Initialize the return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        pa_debug.set_process('PLSQL','LOG',l_debug_mode);

        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage := 'In PA_MRC_FINPLAN.POPULATE_BL_MAP_TMP ';
            pa_debug.write('POPULATE_BL_MAP_TMP: ' || g_module_name,pa_debug.g_err_stage,3);
        END IF;

    --  Validate the input parameters.

        IF  p_source_fin_plan_version_id IS NULL THEN

            IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.g_err_stage := 'Mandatory input parameter is null.';
                pa_debug.write('POPULATE_BL_MAP_TMP: ' || g_module_name,pa_debug.g_err_stage,5);

                pa_debug.g_err_stage := 'Source Budget Version Id  = ' || p_source_fin_plan_version_id;
                pa_debug.write('POPULATE_BL_MAP_TMP: ' || g_module_name,pa_debug.g_err_stage,5);
            END IF;

            x_return_status := FND_API.G_RET_STS_ERROR;

            PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA'
                                ,p_msg_name            => 'PA_FP_INV_PARAM_PASSED');

            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

        END IF;

        -- Clear the  PA_FP_BL_MAP_TMP before inserting fresh records
        DELETE FROM  PA_FP_BL_MAP_TMP;

        OPEN C_TMP_BUDGET_LINE ;

        LOOP
          -- Doing bulk fetch
		l_source_budget_line_id_tbl.delete;
 		l_target_budget_line_id_tbl.delete;
             FETCH  C_TMP_BUDGET_LINE BULK COLLECT INTO
                      l_source_budget_line_id_tbl
                     ,l_target_budget_line_id_tbl
             LIMIT g_plsql_max_array_size;

             /* Commented for bug# 2629138:
             EXIT WHEN C_TMP_BUDGET_LINE%NOTFOUND; */

             IF NVL(l_target_budget_line_id_tbl.last,0) >= 1 THEN

          -- Only if something is fetched

              FORALL i in l_target_budget_line_id_tbl.first..l_target_budget_line_id_tbl.last

                INSERT INTO PA_FP_BL_MAP_TMP
                          ( source_budget_line_id
                           ,target_budget_line_id
                           )
                  VALUES  ( l_source_budget_line_id_tbl(i)
                           ,l_target_budget_line_id_tbl(i)
                           );

          END IF;

          --exit loop if the recent fetch size is less than 200

          EXIT WHEN NVL(l_target_budget_line_id_tbl.last,0)<g_plsql_max_array_size;

      END LOOP;
      	CLOSE C_TMP_BUDGET_LINE; -- Added for bug#6320022
      --Bug 2628051:- stack should be reset at the end of the api
      pa_debug.reset_err_stack;

EXCEPTION

 WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count = 1 THEN
           PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE
                  ,p_msg_index      => 1
                  ,p_msg_count      => l_msg_count
                  ,p_msg_data       => l_msg_data
                  ,p_data           => l_data
                  ,p_msg_index_out  => l_msg_index_out);
           x_msg_data := l_data;
           x_msg_count := l_msg_count;
      ELSE
          x_msg_count := l_msg_count;
      END IF;
       x_return_status := FND_API.G_RET_STS_ERROR;
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.write('POPULATE_BL_MAP_TMP: ' || g_module_name,'Invalid Arguments Passed. ' || x_msg_data,5);
          pa_debug.write_file('POPULATE_BL_MAP_TMP: Invalid Arguments Passed. ' || x_msg_data);
       END IF;
       pa_debug.reset_err_stack;
       RAISE;

 WHEN Others THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_MRC_FINPLAN'
                              ,p_procedure_name => 'POPULATE_BL_MAP_TMP'
                              ,p_error_text     => SQLERRM);
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('POPULATE_BL_MAP_TMP: ' || g_module_name,x_msg_data,4);
         pa_debug.write_file('POPULATE_BL_MAP_TMP: ' || x_msg_data);
      END IF;
      pa_debug.reset_err_stack;
      RAISE ;--FND_API.G_EXC_UNEXPECTED_ERROR;

END POPULATE_BL_MAP_TMP ;

END PA_FIN_PLAN_UTILS2 ;

/
