--------------------------------------------------------
--  DDL for Package Body PA_FUNDS_CONTROL_UTILS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FUNDS_CONTROL_UTILS2" as
-- $Header: PAFUTL2B.pls 120.2 2006/07/14 06:14:44 anuagraw noship $

PROCEDURE PRINT_MSG (p_debug_flag varchar2 default 'N'
		,p_msg varchar2) IS

BEGIN
	If p_debug_flag = 'Y' Then
		--r_debug.r_msg('Log:'||p_msg);
		pa_debug.write_file('LOG',p_msg);
	End If;

END PRINT_MSG;

/* This API returs the Y if the given PO line is contingent worker PO */
FUNCTION is_CWK_PO(p_po_header_id Number
		  ,p_po_line_id   Number
                  ,p_po_dist_id   Number
                  ,p_proj_org_id  Number ) Return varchar2 IS

        l_return_CWK_flag  varchar2(1) := 'N';
        l_check_cwk_implemented  Varchar2(1) := 'N';

        Cursor check_cwk_implemented IS
        Select nvl(imp.XFACE_CWK_TIMECARDS_FLAG ,'N')
        from pa_implementations_all imp
        where imp.org_id = nvl(p_proj_org_id,-99) ;                 /*5368274*/

BEGIN
	If pa_funds_control_utils2.g_cwk_implemented_flag  is NULL Then
        	Open check_cwk_implemented;
        	Fetch check_cwk_implemented INTO l_check_cwk_implemented;
        	Close check_cwk_implemented;
		pa_funds_control_utils2.g_cwk_implemented_flag := l_check_cwk_implemented;
	Else
		l_check_cwk_implemented := pa_funds_control_utils2.g_cwk_implemented_flag ;
	End If;

        If l_check_cwk_implemented = 'Y' Then

                -- Call PO api to check the particular po line is CWK line
		l_return_CWK_flag := PA_PJC_CWK_UTILS.is_rate_based_line
			(P_Po_Line_Id          => p_po_line_id
                         ,P_Po_Distribution_Id => p_po_dist_id
			);
	Else
		l_return_CWK_flag := 'N';

        End If;
        return l_return_CWK_flag;
EXCEPTION
        when no_data_found then
                return 'N';

        when others then
                Raise;
END is_CWK_PO ;



/* This api will return the resource list member id from the summary record
 * for the given document header and line for contingent worker record
 */
FUNCTION get_CWK_RLMI(p_project_id  IN Number
                     ,p_task_id           IN Number
                     ,p_budget_version_id IN Number
                     ,p_document_header_id IN Number
                     ,p_document_dist_id IN Number
                     ,p_document_line_id IN Number
                     ,p_document_type    IN VARCHAR2
                     ,p_expenditure_type IN VARCHAR2
		     ,p_line_type        IN VARCHAR2
                     ,p_calling_module IN VARCHAR2 ) Return Number
IS
        l_cwk_rlmi Number := NULL;

        CURSOR cur_pkt_cwk_rlmi IS
        SELECT resource_list_member_id
        FROM   pa_bc_packets pkt
        WHERE  pkt.project_id = p_project_id
        AND    pkt.task_id = p_task_id
        AND    pkt.budget_version_id = p_budget_version_id
        AND    ((p_document_type = 'PO'
                 AND pkt.document_header_id = p_document_header_id)
                OR
                p_document_type = 'EXP'
               )
        AND    pkt.document_line_id = p_document_line_id
        AND    NVL(pkt.summary_record_flag,'N') = 'Y'
        AND    pkt.balance_posted_flag = 'N'
        AND    pkt.status_code in ('P','L','A','B','C')
        AND    substr(nvl(pkt.result_code,'P'),1,1) = 'P'
        AND    pkt.document_type = 'PO'
        AND    (( pkt.expenditure_type = p_expenditure_type
		 and p_line_type = 'BURDEN'
                 and EXISTS (select null
                           from pa_projects_all pp
                                ,pa_project_types_all pt
                           where pt.project_type = pp.project_type
                           and  pt.org_id = pp.org_id                        /*5368274*/
                           and  pp.project_id = pkt.project_id
                           and  NVL(pt.burden_amt_display_method,'N') = 'D'
                          ))
		 OR
		 (p_line_type = 'RAW'
		  and pkt.parent_bc_packet_id is NULL
                  and EXISTS (select null
                           from pa_projects_all pp
                                ,pa_project_types_all pt
                           where pt.project_type = pp.project_type
                           and  pt.org_id = pp.org_id                        /*5368274*/
                           and  pp.project_id = pkt.project_id
                           and  NVL(pt.burden_amt_display_method,'N') = 'D'
                          ))
                 OR
                 (EXISTS (select null
                           from pa_projects_all pp
                                ,pa_project_types_all pt
                           where pt.project_type = pp.project_type
                           and  pt.org_id = pp.org_id                        /*5368274*/
                           and  pp.project_id = pkt.project_id
                           and  NVL(pt.burden_amt_display_method,'N') <> 'D'
                          )
                )
              ) ;

        CURSOR cur_com_cwk_rlmi IS
        SELECT resource_list_member_id
        FROM pa_bc_commitments_all com
        WHERE  com.project_id = p_project_id
        AND    com.task_id = p_task_id
        AND    com.budget_version_id = p_budget_version_id
        AND    ((p_document_type = 'PO'
                 AND com.document_header_id = p_document_header_id)
                OR
                p_document_type = 'EXP'
               )
        AND    com.document_line_id = p_document_line_id
        AND    com.document_type = 'PO'
        AND    NVL(com.summary_record_flag,'N') = 'Y'
        AND    (( com.expenditure_type = p_expenditure_type
		 and p_line_type = 'BURDEN'
                 and EXISTS (select null
                           from pa_projects_all pp
                                ,pa_project_types_all pt
                           where pt.project_type = pp.project_type
                           and  pt.org_id = pp.org_id                       /*5368274*/
                           and  pp.project_id = com.project_id
                           and  NVL(pt.burden_amt_display_method,'N') = 'D'
                          ))
                 OR
                 (p_line_type = 'RAW'
		  and com.parent_bc_packet_id is NULL
                  and EXISTS (select null
                           from pa_projects_all pp
                                ,pa_project_types_all pt
                           where pt.project_type = pp.project_type
                           and  pt.org_id = pp.org_id                      /*5368274*/
                           and  pp.project_id = com.project_id
                           and  NVL(pt.burden_amt_display_method,'N') = 'D'
                          ))
		OR
                 (EXISTS (select null
                           from pa_projects_all pp
                                ,pa_project_types_all pt
                           where pt.project_type = pp.project_type
                           and  pt.org_id = pp.org_id                     /*5368274*/
                           and  pp.project_id = com.project_id
                           and  NVL(pt.burden_amt_display_method,'N') <> 'D'
                          )
                )
              ) ;

	l_debug_stage varchar2(1000);
	l_debug_mode  varchar2(100) := 'N';

BEGIN
	--Initialize the error stack
        PA_DEBUG.set_curr_function('PA_FUNDS_CONTROL_UTILS2.get_CWK_RLMI');

        fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
        l_debug_mode := NVL(l_debug_mode, 'N');

        PA_DEBUG.SET_PROCESS( x_process => 'PLSQL'
                 ,x_write_file     => 'LOG'
                 ,x_debug_mode      => l_debug_mode
                  );

        l_cwk_rlmi := NULL;

        IF p_calling_module = 'FUNDS_CHECK' THEN
                OPEN cur_com_cwk_rlmi ;
                FETCH cur_com_cwk_rlmi INTO l_cwk_rlmi;
                IF cur_com_cwk_rlmi%NOTFOUND THEN
			l_debug_stage := 'Summary Record Not Found in Commitments';
			print_msg(l_debug_mode,l_debug_stage);
                        OPEN cur_pkt_cwk_rlmi;
                        FETCH cur_pkt_cwk_rlmi INTO l_cwk_rlmi;
			If cur_pkt_cwk_rlmi%NOTFOUND THEN
				l_debug_stage := 'Summary Record Not Found in packets';
				print_msg(l_debug_mode,l_debug_stage);
			End If;
                        CLOSE cur_pkt_cwk_rlmi;
                END IF;
                CLOSE cur_com_cwk_rlmi;

        END IF;

	pa_debug.reset_curr_function; /* 4129612 */
        Return l_cwk_rlmi;

EXCEPTION
	WHEN OTHERS THEN
		print_msg(l_debug_mode,l_debug_stage);
		pa_debug.reset_err_stack;
		RAISE;
END get_CWK_RLMI;

/* This Function returns the Baseline Budget version OR Draft budget version
 * based on the calling mode 'DRAFT'/ 'BASELINE'
 */
FUNCTION get_draftORbaseLine_bdgtver(p_project_id     IN Number
                          ,p_ext_bdgt_type IN varchar2
                          ,p_mode          IN varchar2 ) RETURN Number
IS

        l_bdgt_version_id Number;
BEGIN
    IF p_mode = 'DRAFT' Then
        select max(pbv.budget_version_id)
        INTO l_bdgt_version_id
        FROM pa_budget_versions pbv
             ,pa_budget_types bdgttype
             ,pa_budgetary_control_options pbct
        WHERE pbv.project_id = p_project_id
        AND   pbv.current_flag = 'N'
        AND   pbv.budget_status_code = 'W'
        AND   bdgttype.budget_type_code = pbv.budget_type_code
        AND   bdgttype.budget_amount_code = 'C'
        AND   pbct.project_id = pbv.project_id
        AND   pbct.BDGT_CNTRL_FLAG = 'Y'
        AND   pbct.BUDGET_TYPE_CODE = pbv.budget_type_code
        AND   NVL(pbct.EXTERNAL_BUDGET_CODE,'GL') = p_ext_bdgt_type ;

    ELSE
        select max(pbv.budget_version_id)
        INTO l_bdgt_version_id
        FROM pa_budget_versions pbv
             ,pa_budget_types bdgttype
             ,pa_budgetary_control_options pbct
        WHERE pbv.project_id = p_project_id
        AND   pbv.current_flag = 'Y'
        AND   pbv.budget_status_code = 'B'
        AND   bdgttype.budget_type_code = pbv.budget_type_code
        AND   bdgttype.budget_amount_code = 'C'
        AND   pbct.project_id = pbv.project_id
        AND   pbct.BDGT_CNTRL_FLAG = 'Y'
        AND   pbct.BUDGET_TYPE_CODE = pbv.budget_type_code
        AND   NVL(pbct.EXTERNAL_BUDGET_CODE,'GL') = p_ext_bdgt_type ;

    END IF;

    RETURN l_bdgt_version_id;

EXCEPTION
        when others then
                raise;

END get_draftORbaseLine_bdgtver;


/* This API will checks the burden components for CWK transactions has been changed, if so return error
 * if the burden componenets are not same as the summary record , later we cannot
 * derive the budget ccid and resource list member id.
 * so mark the trasnaction as Error.
 * This check should be carried only for the Burden display method is different
 * Example: PO is entered for exp 'Airfare' which maps to the following cost codes
 * Cost Base   ind_cost_codes
 * -----------------------------------
 * Expenses     GA
 *              FEE
 *
 * When timecard is entered for expenditure type which maps
 * Labor       GA
 *             FEE
 *             Fringe
 *             Overhead
 * Since we cannot map RLMI for the Fringe and Overhead, later the transactions get rejected
 * so mark the bc_packet and parent_bc_packet records as rejected with reason
 * "Burden cost codes not mapping to summary record expenditure types" - F100
 *
 */
PROCEDURE checkCWKbdCostCodes( p_calling_module varchar2
			 ,p_project_id Number
                        ,p_task_id     Number
			,p_doc_line_id Number
			,p_exp_type    varchar2
			,p_exp_item_date date
                        ,x_return_status  OUT NOCOPY varchar2
			,x_result_code    OUT NOCOPY varchar2
			,x_status_code    OUT NOCOPY varchar2
                        ) IS

        l_error_flag varchar2(1) := 'N';
        l_exp_string varchar2(1000) :=  Null;
        l_cost_base   varchar2(100);
        l_cost_plus_structure varchar2(100);
        l_error_msg_code  varchar2(1000);
	l_debug_mode varchar2(100) := 'N';
	l_status_code varchar2(100);
	l_result_code varchar2(100);
	l_return_status varchar2(100) := 'S';
	l_debug_stage varchar2(1000);
	l_cwkbdCount  Number := 0;
        l_expCostCodeCount Number :=0;
	l_no_costplus_structure  Exception;

        CURSOR cur_comsumRecInfo (p_project_id Number,p_task_id Number,p_doc_line_id Number ) IS
        SELECT sm.expenditure_type
        FROM  pa_bc_commitments_all sm
              ,pa_projects_all pp
              ,pa_project_types_all pt
        WHERE sm.summary_record_flag = 'Y'
        AND   sm.project_id = p_project_id
        AND   sm.task_id    = p_task_id
        AND   sm.document_line_id = p_doc_line_id
        AND   sm.parent_bc_packet_id is not Null
	AND   nvl(sm.comm_tot_bd_amt,0) <> 0
        AND   pp.project_id = sm.project_id
        AND   pt.project_type = pp.project_type
        AND   pt.org_id = pp.org_id                          /*5368274*/
        AND   NVL(pt.burden_amt_display_method,'N') = 'D';

        CURSOR cur_pktsumRecInfo(p_project_id Number,p_task_id Number,p_doc_line_id Number ) IS
        SELECT sm.expenditure_type
        FROM  pa_bc_packets sm
              ,pa_projects_all pp
              ,pa_project_types_all pt
        WHERE sm.summary_record_flag = 'Y'
        AND   sm.project_id = p_project_id
        AND   sm.task_id    = p_task_id
        AND   sm.document_line_id = p_doc_line_id
        AND   sm.parent_bc_packet_id is not Null
        AND   sm.balance_posted_flag <> 'Y'
        AND   sm.status_code in ('A','C','B','P')
        AND   substr(sm.result_code,1,1) = 'P'
	AND   nvl(sm.comm_tot_bd_amt,0) <> 0
        AND   pp.project_id = sm.project_id
        AND   pt.project_type = pp.project_type
        AND   pt.org_id = pp.org_id                         /*5368274*/
        AND   NVL(pt.burden_amt_display_method,'N') = 'D';

BEGIN

        PA_DEBUG.set_curr_function('PA_FUNDS_CONTROL_UTILS2.checkCWKbdCostCodes');

        fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
        l_debug_mode := NVL(l_debug_mode, 'N');

        PA_DEBUG.SET_PROCESS( x_process => 'PLSQL'
                 ,x_write_file     => 'LOG'
                 ,x_debug_mode      => l_debug_mode
                  );

	-- Initialize the out variables;
	x_return_status := 'S';
	x_status_code := 'P';
	x_result_code := Null;

	l_debug_stage  := 'Inside checkCWKbdCostCodes api';
	print_msg(l_debug_mode,l_debug_stage);

        -- Check the summary record burden components count
        IF (p_project_id <> NVL(pa_funds_control_utils2.g_bd_cache_proj_id,0) OR
           p_task_id <> nvl(pa_funds_control_utils2.g_bd_cache_task_id,0) OR
           p_doc_line_id <> nvl(pa_funds_control_utils2.g_bd_cache_doc_line_id,0) OR
	    p_exp_type <> nvl(pa_funds_control_utils2.g_bd_cache_exp_type,'') OR
	    p_exp_item_date <> nvl(pa_funds_control_utils2.g_bd_cache_Ei_date,'') ) THEN
		l_debug_stage  := 'Excuting cursor to fetch the values';
		print_msg(l_debug_mode,l_debug_stage);
                l_exp_string:= null;
		l_expCostCodeCount := 0;
                FOR j in cur_comsumRecInfo(p_project_id,p_task_id,p_doc_line_id) LOOP
                      l_exp_string:= l_exp_string||j.expenditure_type||',';
			l_expCostCodeCount := l_expCostCodeCount + 1;
                END LOOP;
                If l_exp_string is NULL Then
		      l_expCostCodeCount := 0;
                      FOR j in cur_pktsumRecInfo(p_project_id,p_task_id,p_doc_line_id) LOOP
                              l_exp_string:= l_exp_string||j.expenditure_type||',';
				l_expCostCodeCount := l_expCostCodeCount + 1;
                      END LOOP;
                End If;
                l_exp_string:= substr(l_exp_string,1,length(l_exp_string)-1);
		l_debug_stage  := 'Summary Record CostCodes['||l_exp_string||']CostCodeCount['||l_expCostCodeCount||']' ;
		print_msg(l_debug_mode,l_debug_stage);
                pa_funds_control_utils2.g_bd_cache_exp_string := l_exp_string;
                pa_funds_control_utils2.g_bd_cache_proj_id := p_project_id;
                pa_funds_control_utils2.g_bd_cache_task_id := p_task_id;
                pa_funds_control_utils2.g_bd_cache_doc_line_id := p_doc_line_id;
		pa_funds_control_utils2.g_bd_cache_exp_type := p_exp_type;
		pa_funds_control_utils2.g_bd_cache_Ei_date := p_exp_item_date;
                If l_exp_string is NULL Then
                     l_error_flag := 'N';

                Elsif l_exp_string is NOT NULL Then
                     -- sumary record exists check the burden expenditure types
                     --check the burden cost codes count for the new pkt lines
		     l_debug_stage  := 'Calling check_exp_of_cost_base api';
                     print_msg(l_debug_mode,l_debug_stage);
                     pa_funds_control_pkg1.check_exp_of_cost_base
			(p_task_id   		=> p_task_id
                        ,p_exp_type             => p_exp_type
                        ,p_ei_date              => p_exp_item_date
                        ,p_sch_type             => 'C'
                        ,x_base                 => l_cost_base
                        ,x_cp_structure         => l_cost_plus_structure
                        ,x_return_status        => l_return_status
                        ,x_error_msg_code       => l_error_msg_code
                        );
			If l_return_status <> 'S' Then
				Raise l_no_costplus_structure;
			End If;
                     BEGIN
			l_debug_stage  := 'Excuting sql to check costcodes has been changed';
                        print_msg(l_debug_mode,l_debug_stage);
			/*
                        Select 'Y'
                        INTO l_error_flag
                        From Dual
                        Where Exists (Select null
                                      from  pa_cost_base_cost_codes icc
                                           ,pa_cost_base_exp_types exp
                                           ,pa_cost_bases base
                                      where icc.cost_base = exp.cost_base
                                      and   icc.cost_plus_structure = exp.cost_plus_structure
                                      and   base.cost_base = icc.cost_base
                                      and   icc.ind_cost_code NOT IN (l_exp_string)
                                      and   exp.expenditure_type = p_exp_type
                                      and   base.cost_base = l_cost_base
                                      and   icc.cost_plus_structure = l_cost_plus_structure
                                      and   icc.cost_base_type = 'INDIRECT COST') ;
			*/
			Select count(*)
			INTO l_cwkbdCount
			from  pa_cost_base_cost_codes icc
                              ,pa_cost_base_exp_types exp
                              ,pa_cost_bases base
                        where icc.cost_base = exp.cost_base
                        and   icc.cost_plus_structure = exp.cost_plus_structure
                        and   base.cost_base = icc.cost_base
                        and   icc.ind_cost_code IN (l_exp_string)
                        and   exp.expenditure_type = p_exp_type
                        and   base.cost_base = l_cost_base
                        and   icc.cost_plus_structure = l_cost_plus_structure
                        and   icc.cost_base_type = 'INDIRECT COST' ;

			If nvl(l_expCostCodeCount,0) <> 0 Then
				IF nvl(l_cwkbdCount,0) < nvl(l_expCostCodeCount,0) Then
					l_error_flag := 'Y';
				Else
					l_error_flag := 'N';
				End If;
			End If;

                     EXCEPTION
                       WHEN NO_DATA_FOUND then
                           l_error_flag := 'N';
			   l_debug_stage  := 'End of sql execution';
                           print_msg(l_debug_mode,l_debug_stage);
                       WHEN OTHERS THEN
                           Raise;
                     END;

		End If;

                If l_error_flag = 'Y' Then
                	l_result_code := 'F100';
                        l_status_code := 'R';
			l_return_status := 'E';
                Else
                        l_result_code := NULL;
                        l_status_code := 'P';
			l_return_status := 'S';
                End If;
		pa_funds_control_utils2.g_bd_cache_result_code := l_result_code;
		pa_funds_control_utils2.g_bd_cache_status_code := l_status_code;

     	ELSE
                l_exp_string := pa_funds_control_utils2.g_bd_cache_exp_string;
		l_status_code := pa_funds_control_utils2.g_bd_cache_status_code;
		l_result_code := pa_funds_control_utils2.g_bd_cache_result_code;

       	END If;
	l_debug_stage  := 'End Of checkCWKbdCostCodes Statuscode['||l_status_code||']Rescode['||l_result_code||']';
        print_msg(l_debug_mode,l_debug_stage);

	-- set the out variables values
	x_return_status := l_return_status;
	x_status_code := l_status_code;
	x_result_code := l_result_code;


	--Reset Error stack;
	pa_debug.reset_err_stack;


EXCEPTION

	when l_no_costplus_structure Then
		x_return_status := 'E';
		x_status_code := 'T';
                x_result_code := 'F100';
		pa_debug.reset_err_stack;
		RAISE;

        when others then
                x_return_status := 'U';
		x_status_code := 'T';
		x_result_code := 'F100';
		pa_funds_control_utils2.g_bd_cache_status_code := NULL;
		pa_funds_control_utils2.g_bd_cache_result_code := NULL;
		pa_funds_control_utils2.g_bd_cache_exp_string := NULL;
		pa_debug.reset_err_stack;
                RAISE;

END checkCWKbdCostCodes;

end;

/
