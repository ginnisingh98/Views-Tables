--------------------------------------------------------
--  DDL for Package Body PA_FUNDS_CONTROL_PKG1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FUNDS_CONTROL_PKG1" as
-- $Header: PABCPKTB.pls 120.58.12010000.2 2008/08/22 16:07:54 mumohan ship $

-------------------------------------------------------------------------------------
-- Declare Global variables
--------------------------------------------------------------------------------------
	g_error_stage 		varchar2(1000);
	g_doc_type		varchar2(1000);
	g_base_pre_task_id   	number := null;
	g_base_pre_exp_type  	varchar2(100) := null;
	g_base_pre_ei_date   	date   := null;
	g_pre_base       	varchar2(100) := null;
	g_pre_cp_structure      varchar2(100) := null;
	g_base_error_msg_code 	varchar2(100) := null;
	g_base_return_status  	varchar2(100) := null;
	g_acct_currency_code  	varchar2(100);
	g_cache_period_sob	number := null;
	g_cache_period_pa_date	date  := null;
	g_cache_period_name	varchar2(100) := null;

	/** added these variables to cache the start and end dates  bug fix : 1992734 **/
	g_sd_project_id         number := null;
	g_sd_bdgt_version_id    number := null;
	g_sd_tm_phase_code      varchar2(100) := null;
	g_sd_amt_type           varchar2(100) := null;
	g_sd_boundary_code      varchar2(100) := null;
	g_sd_sob                number  := null;
	g_start_date            date := null;
	g_end_date            date := null;
	g_sd_result_code        varchar2(100);
	g_var_invoice_id        Number := NUll;
        g_var_dist_line_num     Number := NUll;
	g_amt_var                Number := Null;
	g_amt_base_var          Number := Null;

---------------------------------------------------------------------------------
-- declare plsql tables to hold values during the funds check process
---------------------------------------------------------------------
        g_tab_budget_version_id                 pa_plsql_datatypes.IdTabTyp;
        g_tab_budget_line_id                    pa_plsql_datatypes.IdTabTyp;
        g_tab_budget_ccid                       pa_plsql_datatypes.NumTabTyp;
        g_tab_project_id                        pa_plsql_datatypes.IdTabTyp;
        g_tab_task_id                           pa_plsql_datatypes.IdTabTyp;
        g_tab_exp_type                          pa_plsql_datatypes.char50TabTyp;
        g_tab_exp_org_id                        pa_plsql_datatypes.IdTabTyp;
        g_tab_exp_item_date                     pa_plsql_datatypes.DateTabTyp;
        g_tab_set_of_books_id 			pa_plsql_datatypes.Idtabtyp;
        g_tab_je_source_name 			pa_plsql_datatypes.char50TabTyp;
        g_tab_je_category_name   		pa_plsql_datatypes.char50TabTyp;
        g_tab_doc_type                          pa_plsql_datatypes.Char50TabTyp;
        g_tab_doc_header_id                     pa_plsql_datatypes.IdTabTyp;
        g_tab_doc_line_id                       pa_plsql_datatypes.IdTabTyp;
        g_tab_doc_distribution_id               pa_plsql_datatypes.IdTabTyp;
        g_tab_inv_distribution_id               pa_plsql_datatypes.IdTabTyp;
        g_tab_actual_flag                       pa_plsql_datatypes.char50TabTyp;
        g_tab_result_code                       pa_plsql_datatypes.char50TabTyp;
        g_tab_status_code                       pa_plsql_datatypes.char50TabTyp;
        g_tab_entered_dr                        pa_plsql_datatypes.NumTabTyp;
        g_tab_entered_cr                        pa_plsql_datatypes.NumTabTyp;
        g_tab_accounted_dr                      pa_plsql_datatypes.NumTabTyp;
        g_tab_accounted_cr                      pa_plsql_datatypes.NumTabTyp;
        g_tab_balance_posted_flag		pa_plsql_datatypes.char50TabTyp;
        g_tab_funds_process_mode		pa_plsql_datatypes.char50TabTyp;
        g_tab_burden_cost_flag			pa_plsql_datatypes.char50TabTyp;
        g_tab_org_id				pa_plsql_datatypes.Idtabtyp;

        -------->6599207 ------As part of CC Enhancements
	------------------------------------------------------------------------
	/*  Added the following Global Variables which are used in
	    populate_plsql_tabs_CBC, create_CBC_pkt_lines          */
        ------------------------------------------------------------------------
	g_tab_reference1                        pa_plsql_datatypes.char80TabTyp;
        g_tab_reference2                        pa_plsql_datatypes.char80TabTyp;
        g_tab_reference3                        pa_plsql_datatypes.char80TabTyp;
	g_tab_period_year                       pa_plsql_datatypes.NumTabTyp;
	g_tab_period_num                        pa_plsql_datatypes.NumTabTyp;
        g_tab_reference5                        pa_plsql_datatypes.char80TabTyp;
        g_tab_reference4                        pa_plsql_datatypes.char80TabTyp;
	g_tab_rowid                             pa_plsql_datatypes.RowidTabTyp;
	g_tab_last_update_date			pa_plsql_datatypes.datetabtyp;
        g_tab_last_updated_by			pa_plsql_datatypes.NumTabTyp;
	------------------------------------------------------------------------
	-------->6599207 ------END

        g_tab_pkt_reference1             	pa_plsql_datatypes.char80TabTyp;
        g_tab_pkt_reference2             	pa_plsql_datatypes.char80TabTyp;
        g_tab_pkt_reference3             	pa_plsql_datatypes.char80TabTyp;
        g_tab_event_id                          pa_plsql_datatypes.Idtabtyp;
	g_tab_vendor_id                         pa_plsql_datatypes.Idtabtyp;
        g_tab_burden_method_code                pa_plsql_datatypes.char30TabTyp;
        g_tab_main_or_backing_code              pa_plsql_datatypes.char30TabTyp;
        g_tab_source_event_id                   pa_plsql_datatypes.Idtabtyp;
        g_tab_trxn_ccid                         pa_plsql_datatypes.Idtabtyp;
        g_tab_p_bc_packet_id                    pa_plsql_datatypes.IdTabTyp;
	g_tab_fck_reqd_flag			pa_plsql_datatypes.char50TabTyp;
        g_tab_ap_quantity_variance              pa_plsql_datatypes.NumTabTyp;
        g_tab_ap_amount_variance                pa_plsql_datatypes.NumTabTyp;
        g_tab_ap_base_qty_variance              pa_plsql_datatypes.NumTabTyp;
        g_tab_ap_base_amount_variance           pa_plsql_datatypes.NumTabTyp;
        g_tab_ap_po_distribution_id             pa_plsql_datatypes.IdTabTyp;
	g_tab_gl_date                           pa_plsql_datatypes.DateTabTyp;
	g_tab_period_name                       pa_plsql_datatypes.char15TabTyp;
	g_tab_entered_amount                    pa_plsql_datatypes.NumTabTyp;
	g_tab_accted_amount                     pa_plsql_datatypes.NumTabTyp;
	g_tab_event_type_code                   pa_plsql_datatypes.char30TabTyp;
	g_tab_po_release_id                     pa_plsql_datatypes.IdTabTyp;
	g_tab_distribution_type                 pa_plsql_datatypes.char30TabTyp;
	g_tab_enc_type_id                       pa_plsql_datatypes.IdTabTyp;
	g_line_type_lookup_code                 pa_plsql_datatypes.char30TabTyp;
	g_tab_rate                              pa_plsql_datatypes.NumTabTyp; -- Bug 5665232
        g_tab_bc_packet_id                      pa_plsql_datatypes.IdTabTyp; -- Bug 5406690
	g_tab_parent_reversal_id                pa_plsql_datatypes.IdTabTyp; -- Bug 5406690

        -- Bug 5403775 : Added below columns to derive pa bc pkts reference columns for PO backing docs
	g_tab_orig_sequence_num                 pa_plsql_datatypes.NumTabTyp;
	g_tab_applied_to_dist_id_2              pa_plsql_datatypes.NumTabTyp;

        -- Bug 5169409 : R12 Funds management Uptake : This nested table introduced
        -- in patype01.sql
	g_ap_inv_dist_id                        T_PROJ_BC_AP_DIST := T_PROJ_BC_AP_DIST();
        g_ap_line_type_lkup                     pa_plsql_datatypes.char30TabTyp;

	-- Bug : 3703180 changes.
	g_cwk_po_unreserve                      varchar2(1) ;
	g_doc_line_id_tab                       pa_plsql_datatypes.IdTabTyp;
	g_bdamt_balance_tab                     pa_plsql_datatypes.NumTabTyp;
	g_project_id_tab                        pa_plsql_datatypes.IdTabTyp ;
	g_task_id_tab                           pa_plsql_datatypes.IdTabTyp ;
	g_burden_type_tab                       pa_plsql_datatypes.char15TabTyp;

--------------------------------------------------------------------------
-- This api initializes the pl/sql tables
--------------------------------------------------------------------------
PROCEDURE init_plsql_tabs  IS

BEGIN
        g_tab_budget_version_id.delete;
        g_tab_budget_line_id.delete;
        g_tab_budget_ccid.delete;
        g_tab_project_id.delete;
        g_tab_task_id.delete;
        g_tab_exp_type.delete;
        g_tab_exp_org_id.delete;
        g_tab_exp_item_date.delete;
        g_tab_set_of_books_id.delete;
        g_tab_je_source_name.delete;
        g_tab_je_category_name.delete;
        g_tab_doc_type.delete;
        g_tab_doc_header_id.delete;
        g_tab_doc_line_id.delete;
        g_tab_doc_distribution_id.delete;
	g_tab_inv_distribution_id.delete;
        g_tab_actual_flag.delete;
        g_tab_result_code.delete;
        g_tab_status_code.delete;
        g_tab_entered_dr.delete;
        g_tab_entered_cr.delete;
        g_tab_accounted_dr.delete;
        g_tab_accounted_cr.delete;
        g_tab_balance_posted_flag.delete;
        g_tab_funds_process_mode.delete;
        g_tab_burden_cost_flag.delete;
        g_tab_org_id.delete;
        g_tab_pkt_reference1.delete;
        g_tab_pkt_reference2.delete;
        g_tab_pkt_reference3.delete;
        g_tab_event_id.delete;
	g_tab_vendor_id.delete;
        g_tab_burden_method_code.delete;
        g_tab_main_or_backing_code.delete;
        g_tab_source_event_id.delete;
        g_tab_trxn_ccid.delete;
        g_tab_p_bc_packet_id.delete;
	g_tab_fck_reqd_flag.delete;
        g_tab_ap_quantity_variance.delete;
        g_tab_ap_amount_variance.delete;
        g_tab_ap_base_qty_variance.delete;
        g_tab_ap_base_amount_variance.delete;
        g_tab_ap_po_distribution_id.delete;
	g_tab_gl_date.delete;
	g_tab_period_name.delete;
 	g_tab_entered_amount.delete;
	g_tab_accted_amount.delete;
	g_tab_event_type_code.delete;
        g_tab_po_release_id.delete;
	g_tab_distribution_type.delete;
        g_tab_enc_type_id.delete;
	g_line_type_lookup_code.delete;
	g_ap_line_type_lkup.delete;
	g_tab_orig_sequence_num.delete;  -- Bug 5403775
	g_tab_applied_to_dist_id_2.delete;
	g_tab_rate.delete; -- Bug 5665232
        g_tab_bc_packet_id.delete; -- Bug 5406690
	g_tab_parent_reversal_id.delete; -- Bug 5406690

        -------->6599207 ------As part of CC Enhancements
	g_tab_reference1.delete;
	g_tab_reference2.delete;
	g_tab_reference3.delete;
	g_tab_reference4.delete;
	g_tab_reference5.delete;
	g_tab_rowid.delete;
	g_tab_period_num.delete;
	g_tab_period_year.delete;
	g_tab_last_update_date.delete;
	g_tab_last_updated_by.delete;
        -------->6599207 ------END

EXCEPTION

        WHEN OTHERS THEN
                --commit;
                RAISE;
END init_plsql_tabs;

PROCEDURE init_globals IS

BEGIN

	g_base_pre_task_id    := null;
	g_base_pre_exp_type   := null;
	g_base_pre_ei_date    := null;
	g_pre_base            := null;
	g_pre_cp_structure    := null;
	g_base_error_msg_code := null;
	g_base_return_status  := null;
        g_cache_period_sob    := null;
        g_cache_period_pa_date := null;
        g_cache_period_name    := null;

	g_sd_project_id         := null;
	g_sd_bdgt_version_id    := null;
	g_sd_tm_phase_code      := null;
	g_sd_amt_type           := null;
	g_sd_boundary_code      := null;
	g_sd_sob                := null;
	g_start_date            := null;
	g_end_date              := null;
	g_sd_result_code        := null;

END init_globals;

procedure print_msg(p_msg_token1 in varchar2) IS

begin
	--dbms_output.put_line(p_msg_token1);
	null;
end;

-------->6599207 ------As part of CC Enhancements -- Added parameter p_calling_module
-- forward declaration
PROCEDURE Load_pkts (p_packet_id IN NUMBER,
                     p_bc_mode   IN VARCHAR2,
		     p_calling_module IN VARCHAR2 DEFAULT NULL) ;
-------->6599207 ------END

PROCEDURE update_cwk_pkt_lines(p_calling_module   IN varchar2,
                               p_packet_id        IN NUMBER);

-----------------------------------------------------------------------------------------------------
-- R12:Funds Managment Uptake: Deleting obsolete function get_period_name definition

-- R12:Funds Managment Uptake: Deleting obsolete PROCEDURE checkCWKbdExp definition


/* The APi will return the compiled multiplier that needs to be stamped on the summary
 * record line for the contingent worker transactions
 */
FUNCTION get_cwk_multiplier(p_project_id 	IN Number
			,p_task_id              IN Number
			,p_budget_version_id    IN Number
			,p_document_line_id     IN Number
			,p_document_type        IN Varchar2
			,p_expenditure_type     IN Varchar2
			,p_bd_disp_method       IN Varchar2
			,p_reference 		IN Varchar2  default 'GL'
			) Return Number IS

	l_cwk_multiplier  Number :=0;
	l_combdamt        Number :=0;
	l_comrawamt       Number :=0;
	l_pktbdamt        Number :=0;
	l_pktrawamt       Number :=0;
	l_tot_rawamt      Number :=0;
	l_tot_bdamt       Number :=0;
BEGIN
	pa_funds_control_pkg.log_message(p_msg_token1 => 'Inside get_cwk_multiplier API');
	If p_reference = 'GL' Then

         	select sum(decode(com.parent_bc_packet_id, NULL, 0
                                ,decode(p_bd_disp_method,'D', decode(com.expenditure_type,p_expenditure_type
                                                        ,(nvl(com.accounted_dr,0) - nvl(com.accounted_cr,0)),0)
                                             ,(nvl(com.accounted_dr,0) - nvl(com.accounted_cr,0)))
                          ))   ComBdAmt
                      ,sum(decode(com.parent_bc_packet_id, NULL,(nvl(com.accounted_dr,0) - nvl(com.accounted_cr,0)),0)
                          )   ComRawAmt
		Into 	l_combdamt
			,l_comrawamt
		from pa_bc_commitments_all com
		where com.project_id = p_project_id
		and   com.task_id   = p_task_id
		and   com.budget_version_id = p_budget_version_id
		and   com.document_line_id = p_document_line_id
		and   com.document_type =  p_document_type ;

                select sum(decode(pkt.parent_bc_packet_id, NULL, 0
				,decode(p_bd_disp_method,'D', decode(pkt.expenditure_type,p_expenditure_type
                    				 	,(nvl(pkt.accounted_dr,0) - nvl(pkt.accounted_cr,0)),0)
		  			     ,(nvl(pkt.accounted_dr,0) - nvl(pkt.accounted_cr,0)))
           		  ))   pktBdAmt
        	      ,sum(decode(pkt.parent_bc_packet_id, NULL,(nvl(pkt.accounted_dr,0) - nvl(pkt.accounted_cr,0)),0)
                          )   pktRawAmt
                Into    l_pktbdamt
                        ,l_pktrawamt
                from pa_bc_packets pkt
		Where pkt.project_id = p_project_id
                and   pkt.task_id = p_task_id
                and   pkt.budget_version_id = p_budget_version_id
                and   pkt.document_line_id = p_document_line_id
                and   pkt.document_type = p_document_type
                and   pkt.status_code in ('A','C')
                and   nvl(pkt.balance_posted_flag,'N') <> 'Y'
		and   nvl(pkt.funds_process_mode,'N') = 'T'
                and   substr(nvl(pkt.result_code,'P'),1,1) = 'P';

		l_tot_rawamt := NVL(l_comrawamt,0) + nvl(l_pktrawamt,0);
		l_tot_bdamt  := nvl(l_combdamt,0)  + nvl(l_pktbdamt,0) ;

		pa_funds_control_pkg.log_message(p_msg_token1 => 'l_comrawamt['||l_comrawamt||']l_pktrawamt['||l_pktrawamt||
				']l_combdamt['||l_combdamt||']l_pktbdamt['||l_pktbdamt||']' );
		If l_tot_rawamt = 0 Then
			--divisor is zero so return the multiplier zero
			l_cwk_multiplier := 0;
		Else
			l_cwk_multiplier := l_tot_bdamt / l_tot_rawamt ;
		End If;

	END If;

	pa_funds_control_pkg.log_message(p_msg_token1 => 'End of cwk Multiplier Value['||l_cwk_multiplier||']');

	RETURN l_cwk_multiplier;
EXCEPTION

	WHEN OTHERS THEN
		pa_funds_control_pkg.log_message(p_msg_token1 => 'Failed in cwk Multiplier API');
		RAISE;

END get_cwk_multiplier;
-----------------------------------------------------------------------------
-- This API checks whether the given expenditure is part of the
-- the cost base or not if not then Expenditure is no burdening
-- hence the burden lines will not populated.
-- The Out parmas x_return_status = 'S' for Success
----------------------------------------------------------------------------
PROCEDURE   check_exp_of_cost_base(p_task_id    IN  number,
                                   p_exp_type   IN  varchar2,
                                   p_ei_date    IN  date,
                                   p_sch_type   IN  varchar2 default 'C',
                                   x_base             OUT NOCOPY varchar2,
                                   x_cp_structure     OUT NOCOPY varchar2,
                                   x_return_status    OUT NOCOPY varchar2,
                                   x_error_msg_code   OUT NOCOPY varchar2) IS

        l_sch_id    NUMBER;
        l_sch_date  date;
        l_base      VARCHAR2(100);
        l_rate_sch_rev_id NUMBER;
        l_cp_structure  varchar2(100) ;
        l_return_status  varchar2(1000);
        l_stage   varchar2(100);

BEGIN

        x_base  := NULL;
        x_return_status := 'S';
        x_error_msg_code  := null;

        pa_funds_control_pkg.log_message(p_msg_token1 =>
                'Inside check_exp_of_cost_base api In parms are  task id ['||
                 p_task_id||']exp_type ['||p_exp_type||'] ei_date[ '||p_ei_date||']' );

        IF (g_base_pre_task_id is null or g_base_pre_task_id <> p_task_id) OR
           (g_base_pre_exp_type is null or g_base_pre_exp_type <> p_exp_type) OR
           (g_base_pre_ei_date is null or trunc(g_base_pre_ei_date) <> trunc(p_ei_date) ) THEN
                pa_funds_control_pkg.log_message(p_msg_token1 =>'Inside if condition differnt ');

         If p_sch_type  = 'C' then
                BEGIN
			-- Select the Task level schedule override if not found
                        -- then select the Project level override
                        SELECT irs.ind_rate_sch_id,
                                t.cost_ind_sch_fixed_date
                        INTO   l_sch_id,l_sch_date
                        FROM   pa_tasks t,
                                pa_ind_rate_schedules irs
                        WHERE  t.task_id = p_task_id
                        AND    t.task_id = irs.task_id
                        AND    irs.cost_ovr_sch_flag = 'Y';

                EXCEPTION

                        WHEN NO_DATA_FOUND then
                                -- Select the project level sch override
                                BEGIN
                                        SELECT irs.ind_rate_sch_id,
                                                p.cost_ind_sch_fixed_date
                                        INTO   l_sch_id,l_sch_date
                                        FROM   pa_tasks t,
                                                pa_projects_all p,
                                                pa_ind_rate_schedules irs
                                        WHERE  t.task_id = p_task_id
                                        AND    t.project_id = p.project_id
                                        AND    t.project_id = irs.project_id
                                        AND    irs.cost_ovr_sch_flag = 'Y'
                                        AND    irs.task_id is null;
                                EXCEPTION

                                        WHEN NO_DATA_FOUND THEN
                                                -- select the schedule at the task
                                                BEGIN
                                                    SELECT  t.cost_ind_rate_sch_id,
                                                        t.cost_ind_sch_fixed_date
                                                    INTO    l_sch_id ,l_sch_date
                                                    FROM    pa_tasks t,
                                                        pa_ind_rate_schedules irs
                                                    WHERE   t.task_id = p_task_id
                                                    AND     t.cost_ind_rate_sch_id = irs.ind_rate_sch_id;
                                                EXCEPTION

                                                        WHEN OTHERS THEN
								x_error_msg_code := 'NO_IND_RATE_SCH_ID';
								x_base  := NULL;
								x_return_status := 'F';

                                                END;
                                END;

                        WHEN OTHERS THEN

                                x_error_msg_code := 'NO_IND_RATE_SCH_ID';
                                x_base  := NULL;
                                x_return_status := 'F';
                END;

                --pa_funds_control_pkg.log_message(p_msg_token1=>'sch id = '||l_sch_id);
                If  l_sch_id is NOT NULL then
                        pa_funds_control_pkg.log_message(p_msg_token1=>
                                'calling pa_cost_plus.get_revision_by_date');

                        pa_cost_plus.get_revision_by_date
                                (l_sch_id
                                ,l_sch_date
                                ,p_ei_date
                                ,l_rate_sch_rev_id
                                ,l_return_status
                                ,l_stage);
                        /** pa_funds_control_pkg.log_message(p_msg_token1 =>
                                'sch rev id = '||l_rate_sch_rev_id||' status ='||l_return_status); **/
                        IF l_rate_sch_rev_id is NULL then
                                x_error_msg_code :=  'NO_IND_RATE_SCH_REVISION';
                                x_base  := NULL;
                                x_return_status := 'F';
                        END IF;
                END IF;
                pa_funds_control_pkg.log_message(p_msg_token1=>'sch rev id = '||l_rate_sch_rev_id);
                IF l_rate_sch_rev_id is NOT NULL then
                        pa_cost_plus.get_cost_plus_structure
                        (rate_sch_rev_id  =>l_rate_sch_rev_id
                         ,cp_structure    =>l_cp_structure
                         ,status           =>l_return_status
                         ,stage            =>l_stage);

                        IF l_cp_structure is NULL then
                                x_error_msg_code := 'NO_COST_PLUS_STRUCTURE';
                                x_base  := NULL;
                                x_return_status := 'F';

                        End if;
                End IF;
                pa_funds_control_pkg.log_message(p_msg_token1=>'cost plus structure ='||l_cp_structure);
                l_base := null;
                IF l_cp_structure is NOT NULL and p_exp_type is NOT NULL then
                        pa_cost_plus.get_cost_base
                        (exp_type         => p_exp_type
                         ,cp_structure     => l_cp_structure
                         ,c_base           => l_base
                         ,status           => l_return_status
                         ,stage            => l_stage);
                        pa_funds_control_pkg.log_message(p_msg_token1=>'l_base ='||l_base);
                        x_base := l_base;
			x_cp_structure := l_cp_structure;
                        If l_base is NULL then
                                -- the expenditure type is not part of the
                                -- cost base so burdened cost is same as raw cost
                                -- or burden cost is zero
                                x_return_status := 'S';
                                x_error_msg_code := null;
                        End if;

                END IF;

                End if; --end of schedule type
                g_base_return_status := x_return_status;
                g_base_error_msg_code := x_error_msg_code;
                g_base_pre_task_id := p_task_id;
                g_base_pre_ei_date := p_ei_date;
                g_base_pre_exp_type := p_exp_type;
                g_pre_base := x_base;
		g_pre_cp_structure := x_cp_structure;

        Else  -- pre cache
                pa_funds_control_pkg.log_message(p_msg_token1=>'Pre cached values');
                x_return_status := g_base_return_status;
                x_error_msg_code := g_base_error_msg_code;
                x_base   := g_pre_base;
		x_cp_structure := g_pre_cp_structure;
        End if;

                pa_funds_control_pkg.log_message(p_msg_token1=>'x_msg_code[ '||x_error_msg_code||
                ']x_retun status [ '||x_return_status||']x_base ['||x_base||
                ']g_base_return_status ['||g_base_return_status|| ']g_base_error_msg_code['||g_base_error_msg_code||
                ']g_base_pre_task_id ['||g_base_pre_task_id||']g_base_pre_ei_date['||g_base_pre_ei_date||
                ']g_base_pre_exp_type['||g_base_pre_exp_type||'] cp structure['||g_pre_cp_structure||']' );

        RETURN;

EXCEPTION

        WHEN OTHERS THEN
                pa_funds_control_pkg.log_message
                (p_msg_token2 => 'Failed in check_exp_of_cost_base api');
                pa_funds_control_pkg.log_message
                (p_msg_token2 => sqlcode||sqlerrm);

                --R12: NOCOPY changes
	        x_base  := NULL;
		x_cp_structure := NULL;
                x_return_status := 'F';
                x_error_msg_code  := SQLCODE||SQLERRM;

                RAISE;
END check_exp_of_cost_base;

/* This api will update the summary level flag, compiled multiplier etc
 * attributes required for contingent worker related transactions
 */
PROCEDURE upd_cwk_attributes(p_calling_module  varchar2
			,p_packet_id   number
			,p_mode        varchar2
			,p_reference   varchar2
			,x_return_status OUT NOCOPY varchar2 )


IS
	--PRAGMA AUTONOMOUS_TRANSACTION;
        l_rows_updated   Number := 0;
        l_commsummrec    Varchar2(1) := 'N';
        l_pktsummrec     Varchar2(1) := 'N';
	l_cwk_multiplier Number;
	l_po_exists      Varchar2(1) := 'N';
	l_stage          varchar2(1000);
	l_comm_raw_amt       	Number ;
        l_comm_bd_amt		Number ;
        l_relvd_comm_raw_amt	Number ;
        l_relvd_comm_bd_amt	Number ;

	-- curosr to check po record exists in packets before updating the summary record flag
        cursor cur_potrxs IS
	select 'Y'
	from dual
	where exists (select null
		      from pa_bc_packets pkt
		      where pkt.packet_id = p_packet_id
		      and  pkt.document_type = 'PO'
		     );

	--cursor to select distinct cwk records in current pkt
	cursor cur_cwkRecs IS
	select  pkt.project_id
		,pkt.task_id
		,pkt.budget_version_id
		,pkt.document_line_id
		,NVL(pt.burden_amt_display_method,'N') burden_amt_display_method
		,decode(pt.burden_amt_display_method,'D'
			,decode(pkt.parent_bc_packet_id,NULL,NULL,pkt.expenditure_type)
				,NULL) expenditure_type
		,decode(pt.burden_amt_display_method,'D'
			,decode(pkt.parent_bc_packet_id,NULL,'RAW','BURDEN')
			 	,'RAW')  line_type
	from pa_bc_packets pkt
	    ,pa_projects_all pp
	    ,pa_project_types_all pt
	where pkt.packet_id = p_packet_id
	and   pkt.document_line_id is NOT NULL -- with R12 this check is not sufficient to find if the PO is an CWK PO
	and   pa_funds_control_utils2.is_CWK_PO(pkt.document_header_id,pkt.document_line_id
						  ,pkt.document_distribution_id,pkt.org_id) = 'Y' -- R12 Funds management uptake
	and   pkt.document_type in ('PO') --,'EXP')
	and   pkt.status_code in ('P','A','C','I')
	and   substr(NVL(pkt.result_code,'P'),1,1) = 'P'
	and   pt.project_type = pp.project_type
	and   pt.org_id = pp.org_id  --R12 Ledger change : Removed NVL clause
	and   pp.project_id = pkt.project_id
	Group By
		pkt.project_id
                ,pkt.task_id
                ,pkt.budget_version_id
                ,pkt.document_line_id
                ,NVL(pt.burden_amt_display_method,'N')
                ,decode(pt.burden_amt_display_method,'D'
                        ,decode(pkt.parent_bc_packet_id,NULL,NULL,pkt.expenditure_type)
                                ,NULL)
                ,decode(pt.burden_amt_display_method,'D'
                        ,decode(pkt.parent_bc_packet_id,NULL,'RAW','BURDEN')
                                ,'RAW');

	--cursor to check summary record exists in bc_commitments
	cursor cur_commsummrec (l_project_id Number
				,l_task_id Number
				,l_budget_version_id Number
				,l_document_line_id  Number
				,l_expenditure_type varchar2
				,l_bd_disp_method varchar2
				,l_line_type      varchar2 ) IS
	select 'Y'
	from dual
	Where exists
		(select null
		from pa_bc_commitments_all comm
		where comm.project_id = l_project_id
		and   comm.task_id = l_task_id
		and   comm.budget_version_id = l_budget_version_id
		and   comm.document_line_id = l_document_line_id
		and   comm.summary_record_flag = 'Y'
		and   comm.document_type = 'PO'
		and   ((l_bd_disp_method = 'D'
			and comm.expenditure_type = l_expenditure_type
			and comm.parent_bc_packet_id is NOT NULL)
			OR ( l_bd_disp_method = 'D'
			    and comm.parent_bc_packet_id is NULL
			    and l_line_type = 'RAW' )
			OR
			( l_bd_disp_method <> 'D')
		      )
		);

	--cursor to check summary record exists in pkts which is not yet swept
	cursor cur_pktsummrec (l_project_id Number
                                ,l_task_id Number
                                ,l_budget_version_id Number
				,l_document_line_id  Number
				,l_expenditure_type varchar2
                                ,l_bd_disp_method varchar2
				,l_line_type  varchar2 ) IS
	select 'Y'
	from dual
	where exists
                (select null
                from pa_bc_packets pkts1
                where pkts1.document_line_id is NOT NULL
		and   pkts1.status_code in ('A','P','C','I')
		and   substr(NVL(pkts1.result_code,'P'),1,1) = 'P'
		and   nvl(pkts1.funds_process_mode,'T') <> 'B'
		and   nvl(pkts1.balance_posted_flag,'N') <> 'Y'
		and   pkts1.project_id = l_project_id
		and   pkts1.task_id = l_task_id
		and   pkts1.budget_version_id = l_budget_version_id
		and   pkts1.document_line_id = l_document_line_id
		and   pkts1.document_type = 'PO'
		and   pkts1.summary_record_flag = 'Y'
		and   ((l_bd_disp_method = 'D'
                        and pkts1.expenditure_type = l_expenditure_type
			and pkts1.parent_bc_packet_id is NOT NULL)
                        OR ( l_bd_disp_method = 'D'
                            and pkts1.parent_bc_packet_id is NULL
			    and l_line_type = 'RAW' )
                        OR
                        (l_bd_disp_method <> 'D')
                      )
                );

	-- cursor brings the commitments amounts for the given summary record, which needs to be stamped if the
	-- packet staus is success.
	CURSOR cur_cwk_amts(lv_project_id Number
			,lv_budget_version_id Number
			,lv_task_id  Number
			,lv_document_line_id Number
			,lv_expenditure_type varchar2
			,lv_bd_disp_method  varchar2) IS
	SELECT 	sum((nvl(accounted_dr,0) - nvl(accounted_cr,0)) *
			decode(pkt.document_type,'PO',decode(pkt.parent_bc_packet_id,NULL,1,0),0)) comm_raw_amt
		,sum((nvl(accounted_dr,0) - nvl(accounted_cr,0)) *
			decode(pkt.document_type,'PO'
			  ,decode(pkt.parent_bc_packet_id, NULL ,0
			    ,decode(lv_bd_disp_method, 'D'
			      ,decode(pkt.expenditure_type,lv_expenditure_type,1,0),1)),0)) comm_bd_amt
		,sum((nvl(accounted_dr,0) - nvl(accounted_cr,0)) *
			decode(pkt.document_type,'PO',decode(pkt.parent_bc_packet_id,NULL,1,0),0)) relevd_comm_raw_amt
                ,sum((nvl(accounted_dr,0) - nvl(accounted_cr,0)) *
                        decode(pkt.document_type,'PO'
                          ,decode(pkt.parent_bc_packet_id,NULL ,0
                            ,decode(lv_bd_disp_method, 'D'
                              ,decode(pkt.expenditure_type,lv_expenditure_type,1,0),1)),0)) relevd_comm_bd_amt
        FROM   pa_bc_packets pkt
        WHERE  pkt.project_id = lv_project_id
        AND    pkt.budget_version_id = lv_budget_version_id
        AND    pkt.task_id = lv_task_id
        AND    pkt.document_line_id = lv_document_line_id
        AND    substr(nvl(pkt.result_code,'P'),1,1) = 'P'
        AND    pkt.status_code in ('A','C','B')
        AND    pkt.document_type in ('PO') --,'EXP')
        AND    nvl(pkt.balance_posted_flag,'N') = 'N'
        AND    nvl(pkt.funds_process_mode,'N') = 'T'
        AND    pkt.packet_id = p_packet_id ;

BEGIN
	x_return_status := 'S';

	/* Logic: if the summary level record already exists in bc_commitments_all table
	 * then update the record with amt columns, If no record exists in bc_commiemtns or
	 * the record exists in bc_packets which is not yet swept then update the amts only
	 * If the summary record is creating first time then update all the relevent columns
	 */
 	pa_funds_control_pkg.log_message(p_msg_token1 =>'Inside upd_cwk_attributes API params:packetId['||p_packet_id||
			']mode['||p_mode||']callingModule['||p_calling_module||']Reference['||p_reference||']');

	IF p_calling_module NOT IN ('CBC','CHECK_BASELINE','RESERVE_BASELINE') Then

        -- initialize the accounting currency code,
        pa_multi_currency.init;

        --Get the accounting currency into a global variable.
        g_acct_currency_code := pa_multi_currency.g_accounting_currency_code;

	  --loop through each project, task, document line and expenditure type and update the cwk attributes
	  FOR cwk IN cur_cwkRecs LOOP


		OPEN cur_commsummrec(l_project_id  => cwk.project_id
                                ,l_task_id 	   => cwk.task_id
                                ,l_budget_version_id => cwk.budget_version_id
                                ,l_document_line_id  => cwk.document_line_id
                                ,l_expenditure_type  => cwk.expenditure_type
                                ,l_bd_disp_method    => cwk.burden_amt_display_method
				,l_line_type         => cwk.line_type );
		FETCH cur_commsummrec INTO l_commsummrec;
		IF cur_commsummrec%NOTFOUND Then
			OPEN cur_pktsummrec(l_project_id  => cwk.project_id
                                ,l_task_id         => cwk.task_id
                                ,l_budget_version_id => cwk.budget_version_id
                                ,l_document_line_id  => cwk.document_line_id
                                ,l_expenditure_type  => cwk.expenditure_type
                                ,l_bd_disp_method    => cwk.burden_amt_display_method
				,l_line_type         => cwk.line_type ) ;
			FETCH cur_pktsummrec INTO l_pktsummrec;
			IF cur_pktsummrec%NOTFOUND Then
				l_pktsummrec := 'N';
			End If;
			CLOSE cur_pktsummrec;
		End If;
		CLOSE cur_commsummrec;

		OPEN cur_potrxs;
		FETCH cur_potrxs INTO l_po_exists;
		CLOSE cur_potrxs;

	    pa_funds_control_pkg.log_message(p_msg_token1 =>'Project['||cwk.project_id||']Task['||cwk.task_id||
						']Budgetver['||cwk.budget_version_id||']DocLineid['||cwk.document_line_id||
						']ExpType['||cwk.expenditure_type||']BurdDispMethod['||cwk.burden_amt_display_method||
						']CommSumRecflag['||l_commsummrec||']PktSumRecflag['||l_pktsummrec||
						']poexistsflag['||l_po_exists||']line_type['||cwk.line_type||']');

	    IF p_calling_module in ('GL','DISTCWKST') and p_reference  = 'UPD_AMTS'
		and p_mode in ('R','F','U') Then

		l_rows_updated := 0;
		IF l_commsummrec = 'Y' Then
			l_stage := 'Updating commitments cwk amounts';
			OPEN cur_cwk_amts(cwk.project_id,cwk.budget_version_id,cwk.task_id,cwk.document_line_id
					,cwk.expenditure_type,cwk.burden_amt_display_method);
			FETCH cur_cwk_amts INTO l_comm_raw_amt
						,l_comm_bd_amt
						,l_relvd_comm_raw_amt
						,l_relvd_comm_bd_amt ;
			CLOSE cur_cwk_amts;
			pa_funds_control_pkg.log_message(p_msg_token1 => 'CommRawAmt['||l_comm_raw_amt||']CommbdAmt['||l_comm_bd_amt||
						']RelvdComm['||l_relvd_comm_raw_amt||']RelvdBd['||l_relvd_comm_bd_amt||']');
			l_rows_updated := 0;
		     	UPDATE pa_bc_commitments_all com
		      	SET com.comm_tot_raw_amt = nvl(com.comm_tot_raw_amt,0) +
						decode(p_calling_module,'GL',decode(cwk.line_type,'RAW',nvl(l_comm_raw_amt,0),0),0)
		   	,com.comm_tot_bd_amt = nvl(com.comm_tot_bd_amt,0) +
						decode(p_calling_module,'GL'
                                                 ,decode(cwk.burden_amt_display_method,'D'
                                                        ,decode(cwk.line_type,'BURDEN',nvl(l_comm_bd_amt,0),0)
                                                                ,nvl(l_comm_bd_amt,0)),0)
		   	,com.comm_raw_amt_relieved = nvl(com.comm_raw_amt_relieved,0) -
						   decode(p_calling_module,'DISTCWKST'
                                                         ,decode(cwk.line_type,'RAW',nvl(l_relvd_comm_raw_amt,0),0),0)
		   	,com.comm_bd_amt_relieved = nvl(com.comm_bd_amt_relieved,0) -
							decode(p_calling_module,'DISTCWKST'
                                                 	 ,decode(cwk.burden_amt_display_method,'D'
                                                        	,decode(cwk.line_type,'BURDEN',nvl(l_relvd_comm_bd_amt,0),0)
                                                         	   ,nvl(l_relvd_comm_bd_amt,0)),0)
			WHERE com.summary_record_flag = 'Y'
			AND   com.document_type = 'PO'
			AND   com.document_line_id is not null
			AND   com.project_id = cwk.project_id
			AND   com.task_id = cwk.task_id
			AND   com.budget_version_id = cwk.budget_version_id
			AND   com.document_line_id = cwk.document_line_id
                        AND (( -- burden lines should be stamped with summary record info if display method is different
                                com.parent_bc_packet_id is NOT NULL
                                and com.expenditure_type = cwk.expenditure_type
                                and cwk.line_type = 'BURDEN'
                                and cwk.burden_amt_display_method = 'D'
                             )
                              OR
                             ( -- Sep line burden raw(only one line) should be stamped with summary record info
                                com.parent_bc_packet_id is NULL
                                and cwk.burden_amt_display_method = 'D'
                                and cwk.line_type = 'RAW'
                                and com.summary_record_flag = 'Y'
                             )
                              OR
                               ( -- same line burden raw line should be stamped with summary record info if display method is same
                                com.parent_bc_packet_id is NULL
                                and cwk.burden_amt_display_method  <> 'D'
                               )
                            );

			l_rows_updated := sql%rowcount;


		ELSIF l_pktsummrec = 'Y' Then

			l_stage := 'Updatng packets cwk amount';
                        OPEN cur_cwk_amts(cwk.project_id,cwk.budget_version_id,cwk.task_id,cwk.document_line_id
                                        ,cwk.expenditure_type,cwk.burden_amt_display_method);
                        FETCH cur_cwk_amts INTO l_comm_raw_amt
                                                ,l_comm_bd_amt
                                                ,l_relvd_comm_raw_amt
                                                ,l_relvd_comm_bd_amt ;
                        CLOSE cur_cwk_amts;
 			pa_funds_control_pkg.log_message(p_msg_token1 => 'CommRawAmt['||l_comm_raw_amt||']CommbdAmt['||l_comm_bd_amt||
                                                ']RelvdComm['||l_relvd_comm_raw_amt||']RelvdBd['||l_relvd_comm_bd_amt||']');
			l_rows_updated := 0;
			UPDATE pa_bc_packets pkt
			SET pkt.comm_tot_raw_amt = nvl(pkt.comm_tot_raw_amt,0) +
                                                decode(p_calling_module,'GL',decode(cwk.line_type,'RAW',nvl(l_comm_raw_amt,0),0),0)
                        ,pkt.comm_tot_bd_amt = nvl(pkt.comm_tot_bd_amt,0) +
                                                decode(p_calling_module,'GL'
						 ,decode(cwk.burden_amt_display_method,'D'
							,decode(cwk.line_type,'BURDEN',nvl(l_comm_bd_amt,0),0)
								,nvl(l_comm_bd_amt,0)),0)
                        ,pkt.comm_raw_amt_relieved = nvl(pkt.comm_raw_amt_relieved,0) -
                                                decode(p_calling_module,'DISTCWKST'
							 ,decode(cwk.line_type,'RAW',nvl(l_relvd_comm_raw_amt,0),0),0)
                        ,pkt.comm_bd_amt_relieved = nvl(pkt.comm_bd_amt_relieved,0) -
                                                decode(p_calling_module,'DISTCWKST'
						 ,decode(cwk.burden_amt_display_method,'D'
                                                        ,decode(cwk.line_type,'BURDEN',nvl(l_relvd_comm_bd_amt,0),0)
							 ,nvl(l_relvd_comm_bd_amt,0)),0)
			WHERE pkt.document_line_id is NOT NULL
			AND   pkt.document_type = 'PO'
			AND   NVL(pkt.summary_record_flag,'N') = 'Y'
			AND   substr(NVL(pkt.result_code,'P'),1,1) = 'P'
			AND   nvl(pkt.balance_posted_flag,'N' ) <> 'Y'
			AND   nvl(pkt.funds_process_mode,'N') = 'T'
			AND   pkt.status_code in ('A','B','C')
			AND   pkt.project_id = cwk.project_id
                        AND   pkt.task_id = cwk.task_id
                        AND   pkt.budget_version_id = cwk.budget_version_id
                        AND   pkt.document_line_id = cwk.document_line_id
                        AND (( -- burden lines should be stamped with summary record info if display method is different
                                pkt.parent_bc_packet_id is NOT NULL
                                and pkt.expenditure_type = cwk.expenditure_type
				and cwk.line_type = 'BURDEN'
                                and cwk.burden_amt_display_method = 'D'
                             )
			      OR
                             ( -- Sep line burden raw(only one line) should be stamped with summary record info
                                pkt.parent_bc_packet_id is NULL
                                and cwk.burden_amt_display_method = 'D'
				and cwk.line_type = 'RAW'
				and pkt.summary_record_flag = 'Y'
                             )
                              OR
                               ( -- same line burden raw line should be stamped with summary record info if display method is same
                                pkt.parent_bc_packet_id is NULL
                                and cwk.burden_amt_display_method  <> 'D'
                               )
                            );
			l_rows_updated := sql%rowcount;
		END IF; -- end of summrecamt

	ELSIF p_reference  = 'UPD_FLAG' and p_calling_module = 'GL' and p_mode in ('R','F','U') Then

	    l_rows_updated := 0;
	    IF nvl(l_commsummrec,'N') = 'N' and nvl(l_pktsummrec,'N') = 'N' and l_po_exists = 'Y' Then
		l_stage := 'Updating packets summary record flag';
		pa_funds_control_pkg.log_message(p_msg_token1=> l_stage);
		UPDATE pa_bc_packets pkt
		SET pkt.summary_record_flag = decode (pkt.summary_record_flag,NULL,'Y',pkt.summary_record_flag)
		WHERE pkt.packet_id = p_packet_id
		AND   pkt.document_type = 'PO'
		AND   nvl(pkt.funds_process_mode,'N') = 'T'
		AND   nvl(pkt.balance_posted_flag,'N') <> 'Y'
		AND   pkt.summary_record_flag is NULL
		AND   pkt.project_id = cwk.project_id
                AND   pkt.task_id = cwk.task_id
                AND   pkt.budget_version_id = cwk.budget_version_id
                AND   pkt.document_line_id = cwk.document_line_id
		AND   decode(pkt.parent_bc_packet_id,NULL,'RAW','BURDEN') = cwk.line_type
                AND (( -- sep line burden cost codes should be stamped with summary record info if display method is different
                	pkt.parent_bc_packet_id is NOT NULL
                	and pkt.expenditure_type = cwk.expenditure_type
                	and cwk.burden_amt_display_method = 'D'
			and pkt.bc_packet_id = (select min(pkt1.bc_packet_id)
					        from pa_bc_packets pkt1
						where pkt1.packet_id = pkt.packet_id
						and   pkt1.project_id = pkt.project_id
						and   pkt1.task_id = pkt.task_id
						and   pkt1.budget_version_id = pkt.budget_version_id
						and   pkt1.document_line_id = pkt.document_line_id
						and   pkt1.expenditure_type = pkt.expenditure_type
						and   pkt1.document_type = pkt.document_type
						and   pkt1.parent_bc_packet_id is NOT NULL
					       )
                     )
		      OR
			( -- sep line burden lines only one raw line should be stamped with summary record info
                        pkt.parent_bc_packet_id is NULL
                        and cwk.burden_amt_display_method = 'D'
                        and pkt.bc_packet_id = (select min(pkt1.bc_packet_id)
                                                from pa_bc_packets pkt1
                                                where pkt1.packet_id = pkt.packet_id
                                                and   pkt1.project_id = pkt.project_id
                                                and   pkt1.task_id = pkt.task_id
                                                and   pkt1.budget_version_id = pkt.budget_version_id
                                                and   pkt1.document_line_id = pkt.document_line_id
                                                --and   pkt1.expenditure_type = pkt.expenditure_type
                                                and   pkt1.document_type = pkt.document_type
                                                and   pkt1.parent_bc_packet_id is NULL
                                               )
                     )
                      OR
                     ( -- raw line should be stamped with summary record info if display method is same
                	pkt.parent_bc_packet_id is NULL
                	and cwk.burden_amt_display_method  <> 'D'
			and pkt.bc_packet_id = (select min(pkt1.bc_packet_id)
                                                from pa_bc_packets pkt1
                                                where pkt1.packet_id = pkt.packet_id
                                                and   pkt1.project_id = pkt.project_id
                                                and   pkt1.task_id = pkt.task_id
                                                and   pkt1.budget_version_id = pkt.budget_version_id
                                                and   pkt1.document_line_id = pkt.document_line_id
                                                and   pkt1.document_type = pkt.document_type
						and   pkt1.parent_bc_packet_id is NULL
                                               )
                     )
                   );
			l_rows_updated := sql%rowcount;
	     END IF;

	   ELSIF p_reference  = 'UPD_MULTIPLIER' and p_calling_module = 'GL' and p_mode in ('R','F','U') Then
		l_rows_updated := 0;
		IF l_commsummrec = 'Y' Then
			l_stage  := 'Updating commitments cwk multiplier';
			l_cwk_multiplier := get_cwk_multiplier(cwk.project_id
                                            ,cwk.task_id
                                            ,cwk.budget_version_id
                                            ,cwk.document_line_id
                                            ,'PO'
                                            ,cwk.expenditure_type
					    ,cwk.burden_amt_display_method
                                            ,'GL');
                        If l_cwk_multiplier is NOT NULL Then
                                 l_cwk_multiplier := pa_currency.round_trans_currency_amt
                                                    (l_cwk_multiplier,g_acct_currency_code);
                        End If;
			UPDATE pa_bc_commitments_all cmt
			SET cmt.compiled_multiplier = decode (cmt.document_line_id,NULL,cmt.compiled_multiplier,
							l_cwk_multiplier)
			WHERE cmt.summary_record_flag  = 'Y'
        		AND  cmt.document_line_id is NOT NULL
        		AND  cmt.document_type = 'PO'
        		AND  cmt.project_id = cwk.project_id
        		ANd  cmt.task_id = cwk.task_id
        		AND  cmt.budget_version_id = cwk.budget_version_id
        		AND  cmt.document_line_id = cwk.document_line_id
        		AND (( -- burden lines should be stamped with summary record info if display method is different
                		cmt.parent_bc_packet_id is NOT NULL
                		and cmt.expenditure_type = cwk.expenditure_type
                		and cwk.burden_amt_display_method = 'D'
             			)
            			OR
             			( -- raw line should be stamped with summary record info if display method is same
                			cmt.parent_bc_packet_id is NULL
                			and  cwk.burden_amt_display_method <> 'D'
             			)
           		   );
		       l_rows_updated := sql%rowcount;

		ELsif l_pktsummrec = 'Y' Then
			l_stage  := 'Updating packets cwk multiplier';
                        l_cwk_multiplier := get_cwk_multiplier(cwk.project_id
                                             ,cwk.task_id
                                             ,cwk.budget_version_id
                                             ,cwk.document_line_id
                                             ,'PO'
                                             ,cwk.expenditure_type
					     ,cwk.burden_amt_display_method
                                             ,'GL');
			If l_cwk_multiplier is NOT NULL Then
				l_cwk_multiplier := pa_currency.round_trans_currency_amt
							(l_cwk_multiplier,g_acct_currency_code);
			 End If;
                        UPDATE pa_bc_packets cmt
                        SET cmt.compiled_multiplier = decode (cmt.document_line_id,NULL,cmt.compiled_multiplier
                                                                	,l_cwk_multiplier)
                        WHERE cmt.summary_record_flag  = 'Y'
                        AND  cmt.document_line_id is NOT NULL
                        AND  cmt.document_type = 'PO'
                        AND  cmt.project_id = cwk.project_id
                        ANd  cmt.task_id = cwk.task_id
                        AND  cmt.budget_version_id = cwk.budget_version_id
                        AND  cmt.document_line_id = cwk.document_line_id
			AND  NVL(cmt.balance_posted_flag,'N') <> 'Y'
        		AND  nvl(cmt.funds_process_mode,'N') = 'T'
			AND  cmt.status_code IN ('A','C')
        		AND  substr(nvl(cmt.result_code,'P'),1,1) = 'P'
                        AND (( -- burden lines should be stamped with summary record info if display method is different
                                cmt.parent_bc_packet_id is NOT NULL
                                and cmt.expenditure_type = cwk.expenditure_type
                                and cwk.burden_amt_display_method = 'D'
                                )
                                OR
                                ( -- raw line should be stamped with summary record info if display method is same
                                        cmt.parent_bc_packet_id is NULL
                                        and  cwk.burden_amt_display_method <> 'D'
                                )
                           );

		       l_rows_updated := sql%rowcount;

		End if ; -- end of sum record flag

	   END IF; -- end of p_mode

	   pa_funds_control_pkg.log_message(p_msg_token1 =>l_stage||'- Num of Rows cwk attribute Updated['||l_rows_updated||']');

	 END LOOP; -- end of cur_cwkRecs cursor

	END IF;  -- end of calling module

	--COMMIT;

EXCEPTION

	WHEN OTHERS THEN
		x_return_status := 'T';
		ROLLBACK;
		RAISE;



END upd_cwk_attributes;

----------------------------------------------------------------------------------------
-- This Function checks whether the given invoice line is based on PO or NOT
-- the return paramter is varchar2 of PO in case of PO or INV in case of invoice
----------------------------------------------------------------------------------------
-- Obsolete FUNCTION check_encum_type

----------------------------------------------------------------------------------------
--This api copies the unreserved transaction into to the packet.
-- when the calling mode is unreserved then copy all the transactions from pa_bc_packets
-- for the old packet id(which is funds cheked and approved) to new packet by swapping the amount
-- columns and all other columns values remain same. Approve the packets with status Approved
-- donot create encumbrance liquidation as GL funds checker will create reversing lines
-- for the old packet id and donot populate burden rows / donot check for the unreserved packet
--------------------------------------------------------------------------------------------------------
FUNCTION create_unrsvd_lines
        ( x_packet_id           IN OUT NOCOPY    NUMBER
	,p_mode			IN      VARCHAR2
        ,p_calling_module       IN      VARCHAR2
        ,p_reference1           IN      varchar2 default null
        ,p_reference2           IN      varchar2 default null
        )  RETURN BOOLEAN AS

        PRAGMA AUTONOMOUS_TRANSACTION;

	l_packet_id 	number;

	CURSOR cur_packet IS
	SELECT gl_bc_packets_s.nextval
	FROM dual;

        l_request_id      NUMBER := fnd_global.conc_request_id();
        l_program_id      NUMBER := fnd_global.conc_program_id();
        l_program_application_id NUMBER:= fnd_global.prog_appl_id();
        l_update_login    NUMBER := FND_GLOBAL.login_id;
        l_num_rows        NUMBER := 0;
        l_return_status    VARCHAR2(1);
	l_debug_mode      VARCHAR2(10);


 BEGIN

        PA_DEBUG.set_curr_function
        ('PA_FUNDS_CONTROL_PKG1.create_unrrsvd_lines');

        fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
        l_debug_mode := NVL(l_debug_mode, 'N');

        PA_DEBUG.SET_PROCESS( x_process => 'PLSQL'
                 ,x_write_file     => 'LOG'
                 ,x_debug_mode      => l_debug_mode
                  );

	pa_funds_control_pkg.log_message(p_msg_token1 => 'Inside the create_unreserve_pkt api');

        If l_request_id is null then
                l_request_id := -1;
        End if;

        if l_program_id is null then
                l_program_id := -1;
        End if;
        If l_program_application_id is null then
                l_program_application_id := -1;
        End if;

        If l_update_login is null then
                l_update_login := -1;
        End if;

	If p_calling_module = 'GL' and p_mode in ('U')  then -- unreserved
		OPEN cur_packet ;
		FETCH cur_packet INTO l_packet_id;
		CLOSE cur_packet;


                INSERT INTO pa_bc_packets
                        ( ---- who columns------
                        request_id,
                        program_id,
                        program_application_id,
                        program_update_date,
                        last_update_date,
                        last_updated_by,
                        created_by,
                        creation_date,
                        last_update_login,
                        ------ main columns-----------
                        packet_id,
                        bc_packet_id,
                        budget_version_id,
                        project_id,
                        task_id,
                        expenditure_type,
                        expenditure_organization_id,
                        expenditure_item_date,
                        set_of_books_id,
                        je_source_name,
                        je_category_name,
                        document_type,
                        document_header_id,
                        document_distribution_id,
                        actual_flag,
                        period_name,
                        period_year,
                        period_num,
                        result_code,
                        status_code,
                        entered_dr,
                        entered_cr,
                        accounted_dr,
                        accounted_cr,
                        gl_row_number,
                        balance_posted_flag,
                        funds_process_mode,
                        txn_ccid,
                        encumbrance_type_id,
                        burden_cost_flag,
                        org_id,
			parent_resource_id,
			resource_list_member_id,
			proj_encumbrance_type_id,
			budget_ccid,
			document_line_id,
			reference1,
			reference2,
			reference3,
			-- R12 Funds Management Uptake: Newly added columns
			bc_event_id,
			budget_line_id,
			session_id,
			serial_id,
			vendor_id,
			main_or_backing_code,
                        burden_method_code,
                        source_event_id,
                        document_distribution_type,
			document_header_id_2
                        )
                SELECT
                        l_request_id,
                        l_program_id,
                        l_program_application_id,
                        sysdate,
                        sysdate,
                        l_update_login,
                        l_update_login,
                        sysdate,
                        l_update_login,
                        l_packet_id,
                        pa_bc_packets_s.nextval,
                        pbc.budget_version_id,
                        pbc.project_id,
                        pbc.task_id,
                        pbc.expenditure_type,
                        pbc.expenditure_organization_id,
                        trunc(pbc.expenditure_item_date),
                        pbc.set_of_books_id,
                        pbc.je_source_name,
                        pbc.je_category_name,
                        pbc.document_type,
                        pbc.document_header_id,
                        pbc.document_distribution_id,
                        pbc.actual_flag,
                        pbc.period_name,
                        pbc.period_year,
                        pbc.period_num,
                        pbc.result_code,
                        'P', -- status_code,
                        NVL(pbc.entered_cr,0),
                        NVL(pbc.entered_dr,0),
                        NVL(pbc.accounted_cr,0),
                        NVL(pbc.accounted_dr,0),
                        pbc.gl_row_number,
                        pbc.balance_posted_flag,
                        pbc.funds_process_mode ,
                        pbc.txn_ccid,
                        pbc.encumbrance_type_id,
                        pbc.burden_cost_flag,
                        pbc.org_id,
                        pbc.parent_resource_id,
                        pbc.resource_list_member_id,
                        pbc.proj_encumbrance_type_id,
                        pbc.budget_ccid,
			pbc.document_line_id,
	                pbc.reference1,
                        pbc.reference2,
                        pbc.reference3,
			-- R12 Funds Management Uptake: Newly added columns
			pbc.bc_event_id,
			pbc.budget_line_id,
			pbc.session_id,
			pbc.serial_id,
			pbc.vendor_id,
			pbc.main_or_backing_code,
                        pbc.burden_method_code,
                        pbc.source_event_id,
                        pbc.document_distribution_type,
			pbc.document_header_id_2
		FROM
			pa_bc_packets pbc
		WHERE   pbc.packet_id = x_packet_id;

		If sql%rowcount > 0 then
			--assign the new packet id to out parameter
			pa_funds_control_pkg.log_message(p_msg_token1 => 'New packet id ='|| x_packet_id);
			x_packet_id := l_packet_id;
		End if;

        Elsif p_calling_module = 'CBC' and p_mode in ('U')
		and p_reference1 is not  null and  p_reference2 is not null then -- unreserved
                OPEN cur_packet ;
                FETCH cur_packet INTO l_packet_id;
                CLOSE cur_packet;
                INSERT INTO pa_bc_packets
                        ( ---- who columns------
                        request_id,
                        program_id,
                        program_application_id,
                        program_update_date,
                        last_update_date,
                        last_updated_by,
                        created_by,
                        creation_date,
                        last_update_login,
                        ------ main columns-----------
                        packet_id,
                        bc_packet_id,
                        budget_version_id,
                        project_id,
                        task_id,
                        expenditure_type,
                        expenditure_organization_id,
                        expenditure_item_date,
                        set_of_books_id,
                        je_source_name,
                        je_category_name,
                        document_type,
                        document_header_id,
                        document_distribution_id,
                        actual_flag,
                        period_name,
                        period_year,
                        period_num,
                        result_code,
                        status_code,
                        entered_dr,
                        entered_cr,
                        accounted_dr,
                        accounted_cr,
                        gl_row_number,    --gl_row_bc_packet_row_id
                        balance_posted_flag,
                        funds_process_mode,
                        txn_ccid,
                        encumbrance_type_id,
                        burden_cost_flag,
                        org_id,
                        parent_resource_id,
                        resource_list_member_id,
                        proj_encumbrance_type_id,
                        budget_ccid,
			document_line_id,
                        reference1,
                        reference2,
                        reference3,
			-- R12 Funds Management Uptake: Newly added columns
			bc_event_id,
			budget_line_id,
			session_id,
			serial_id,
			vendor_id,
			main_or_backing_code,
                        burden_method_code,
                        source_event_id,
                        document_distribution_type,
			document_header_id_2
                        )
                SELECT
                        l_request_id,
                        l_program_id,
                        l_program_application_id,
                        sysdate,
                        sysdate,
                        l_update_login,
                        l_update_login,
                        sysdate,
                        l_update_login,
                        l_packet_id,
                        pa_bc_packets_s.nextval,
                        pbc.budget_version_id,
                        pbc.project_id,
                        pbc.task_id,
                        pbc.expenditure_type,
                        pbc.expenditure_organization_id,
                        trunc(pbc.expenditure_item_date),
                        pbc.set_of_books_id,
                        pbc.je_source_name,
                        pbc.je_category_name,
                        pbc.document_type,
                        pbc.document_header_id,
                        pbc.document_distribution_id,
                        pbc.actual_flag,
                        pbc.period_name,
                        pbc.period_year,
                        pbc.period_num,
                        pbc.result_code,
                        'P', -- status_code,
                        NVL(pbc.entered_cr,0),
                        NVL(pbc.entered_dr,0),
                        NVL(pbc.accounted_cr,0),
                        NVL(pbc.accounted_dr,0),
                        pbc.gl_row_number,
                        pbc.balance_posted_flag,
                        pbc.funds_process_mode ,
                        pbc.txn_ccid,
                        pbc.encumbrance_type_id,
                        pbc.burden_cost_flag,
                        pbc.org_id,
                        pbc.parent_resource_id,
                        pbc.resource_list_member_id,
                        pbc.proj_encumbrance_type_id,
                        pbc.budget_ccid,
			pbc.document_line_id,
                        pbc.reference1,
                        pbc.reference2,
                        pbc.reference3,
			-- R12 Funds Management Uptake: Newly added columns
			pbc.bc_event_id,
			pbc.budget_line_id,
			pbc.session_id,
			pbc.serial_id,
			pbc.vendor_id,
			pbc.main_or_backing_code,
                        pbc.burden_method_code,
                        pbc.source_event_id,
                        pbc.document_distribution_type,
			pbc.document_header_id_2
                FROM
                        pa_bc_packets pbc
                WHERE   pbc.packet_id = x_packet_id
		AND	document_type in ('CC_C_CO','CC_P_CO')
		AND	document_header_id = p_reference2;

                If sql%rowcount > 0 then
                        --assign the new packet id to out parameter
                        x_packet_id := l_packet_id;
                End if;

	END IF;
	IF cur_packet%isopen then
		close cur_packet;
	End if;
	commit; -- autonmous transaction to end
	RETURN TRUE;
EXCEPTION
	WHEN OTHERS THEN
		IF cur_packet%isopen then
			close cur_packet;
		End if;
		RAISE;
END create_unrsvd_lines;

------------------------------------------------------------------------------------
--This Api checks whether the Purchase order is based on the requisiton if
-- the period and commitment id from pa_bc_commitments
------------------------------------------------------------------------------------
FUNCTION   is_req_based_po( p_req_distribution_id    IN NUMBER
			   ,p_req_header_id          IN NUMBER
			   ,p_req_prevent_enc_flipped IN VARCHAR2
			   ,x_result_code	     IN OUT NOCOPY varchar2
			   ,x_status_code	     IN OUT NOCOPY varchar2
	  		   ,x_reference1   	     OUT NOCOPY varchar2
			   ,x_reference2             OUT NOCOPY varchar2
			   ,x_reference3             OUT NOCOPY varchar2
			)
			RETURN VARCHAR2 IS

	l_return_flag           varchar2(10) := 'N';
	l_req_found_flag        varchar2(1) := 'N';
	l_parent_bc_packet_id   PA_BC_PACKETS.PARENT_BC_PACKET_ID%TYPE;

	-- This cursor picks the po details for the given requisition
	CURSOR get_podetails Is
	SELECT 'PO'
	      ,po_header_id
	      ,po_distribution_id
	FROM po_distributions_all pod
	WHERE pod.req_distribution_id = p_req_distribution_id ;

	CURSOR c_req_raw_burden IS
	SELECT parent_bc_packet_id
        FROM   ( SELECT comm.bc_commitment_id,
	                comm.parent_bc_packet_id
                   FROM pa_bc_commitments comm
                  WHERE comm.document_distribution_id = p_req_distribution_id
                    AND comm.document_header_id = p_req_header_id
                    AND comm.document_type = 'REQ'
        	UNION ALL
                SELECT null bc_commitment_id,
	               pbc.parent_bc_packet_id
                  FROM pa_bc_packets pbc
                 WHERE pbc.document_distribution_id = p_req_distribution_id
                   AND pbc.document_header_id = p_req_header_id
                   AND pbc.document_type = 'REQ'
                   AND pbc.balance_posted_flag = 'N'
                   AND pbc.status_code in ('A','C')
                   AND substr(nvl(result_code,'P'),1,1) = 'P');

BEGIN

        IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
           pa_funds_control_pkg.log_message(p_msg_token1 => ' IS_REQ_BASED_PO - Start');
           pa_funds_control_pkg.log_message(p_msg_token1 => ' IS_REQ_BASED_PO - Value of p_req_distribution_id '||p_req_distribution_id );
           pa_funds_control_pkg.log_message(p_msg_token1 => ' IS_REQ_BASED_PO - Value of p_req_prevent_enc_flipped '||p_req_prevent_enc_flipped );
           pa_funds_control_pkg.log_message(p_msg_token1 => ' IS_REQ_BASED_PO - Value of x_status_code '||x_status_code );
           pa_funds_control_pkg.log_message(p_msg_token1 => ' IS_REQ_BASED_PO - Value of x_result_code '||x_result_code );
        End if;

        l_return_flag :='N';

        -- Check if its backing rquisition

	OPEN get_podetails;
	FETCH get_podetails INTO
			x_reference1
			,x_reference2
			,x_reference3;
	CLOSE get_podetails;

        l_req_found_flag := 'N';

        IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
           pa_funds_control_pkg.log_message(p_msg_token1 => ' x_reference1 = '||x_reference1);
           pa_funds_control_pkg.log_message(p_msg_token1 => ' x_reference2 = '||x_reference2);
           pa_funds_control_pkg.log_message(p_msg_token1 => ' x_reference3 = '||x_reference3);
        End if;

	OPEN c_req_raw_burden;
	LOOP
	   FETCH c_req_raw_burden INTO l_parent_bc_packet_id;
           IF c_req_raw_burden%notfound then
	      IF l_req_found_flag = 'N' THEN
	       IF p_req_prevent_enc_flipped = 'Y' THEN
	          -- Bug 5475128 : IF Requisition was sourced to BPA then it was never Fundscheck
		  -- IN this scenario return with success status.
	          NULL;
               ELSE
	         x_result_code := 'F137' ; -- No matching requisition record found
	         x_status_code := 'R';
	       END IF;
              END IF;
              IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
                 pa_funds_control_pkg.log_message(p_msg_token1 => 'No matching requisition record found ');
              End if;
	      EXIT;
           END IF;

	   -- Found Requisition Record
	   l_req_found_flag := 'Y';

           -- If burden record is found then intialize x_bc_commitment_id OUT variable
	   IF l_parent_bc_packet_id IS NOT NULL THEN
	      l_return_flag := 'Y';
              IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
                 pa_funds_control_pkg.log_message(p_msg_token1 => 'l_parent_bc_packet_id = '||l_parent_bc_packet_id);
              End if;
	      EXIT;
	   END IF;

        END LOOP;
	CLOSE c_req_raw_burden;

      IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
           pa_funds_control_pkg.log_message(p_msg_token1 => ' IS_REQ_BASED_PO - End l_return_flag ='||l_return_flag);
           pa_funds_control_pkg.log_message(p_msg_token1 => ' IS_REQ_BASED_PO - End  x_status_code '||x_status_code );
           pa_funds_control_pkg.log_message(p_msg_token1 => ' IS_REQ_BASED_PO - End  x_result_code '||x_result_code );
      End if;

      return l_return_flag;

EXCEPTION
WHEN OTHERS THEN
      IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
           pa_funds_control_pkg.log_message(p_msg_token1 => ' IS_REQ_BASED_PO - Exception'||SQLERRM);
      End if;

      Raise;
END is_req_based_po;

--R12 Ledger Changes : Obsoleted FUNCTION GetAmtVariance as its a dangling procedure

--------------------------------------------------------------------------------
--This api checks whether the Invoice is based on the Purchase order
-- if so then it takes the po_header_id,po_distribution_id,period_name
-- and bc_commitment_id from pa_bc_commitments
--------------------------------------------------------------------------------
FUNCTION  is_po_based_invoice( p_po_distribution_id          IN NUMBER
                                ,p_po_header_id              IN NUMBER
                                ,p_po_release_id             IN NUMBER
			        ,x_result_code               IN OUT NOCOPY varchar2
			        ,x_status_code               IN OUT NOCOPY varchar2
			     ) RETURN VARCHAR2 IS

	l_po_found_flag         VARCHAR2(1) := 'N';
	l_cc_found_flag         VARCHAR2(1) := 'N';
	l_return_flag           VARCHAR2(1) := 'N';
	l_cc_det_pf_line_id     varchar2(30); --Bug 6393954 changed from number to varchar2
	L_PARENT_BC_PACKET_ID   PA_BC_PACKETS.PARENT_BC_PACKET_ID%TYPE;
	L_CC_HEADER_ID          varchar2(30); --Bug 6393954 changed from PO_DISTRIBUTIONS_ALL.PO_HEADER_ID%TYPE <number> to varchar2
	L_PO_DESTINATION_TYPE   PO_DISTRIBUTIONS_ALL.DESTINATION_TYPE_CODE%TYPE;

        -- this cursor checks whehter the AP is based on Purchase Order  if so then
        -- take the calculated burden amount from pa_bc_commitments table
        CURSOR po_cur is
        SELECT po.req_header_reference_num
	       ,po.req_line_reference_num
	       ,po.destination_type_code
        FROM  po_distributions_all po
        WHERE po.po_distribution_id = p_po_distribution_id;

	CURSOR c_po_raw_burden(p_distribution_id NUMBER,
	                       p_header_id       NUMBER,
			       p_document_type   VARCHAR2) IS
	SELECT parent_bc_packet_id
        FROM   ( SELECT comm.parent_bc_packet_id
                   FROM pa_bc_commitments comm
                  WHERE comm.document_distribution_id = p_distribution_id
                    AND comm.document_header_id = p_header_id
                    AND comm.document_type = p_document_type
                    AND NVL(comm.document_header_id_2 ,-99) = NVL(p_po_release_id,-99)
        	UNION ALL
                SELECT pbc.parent_bc_packet_id
                  FROM pa_bc_packets pbc
                 WHERE pbc.document_distribution_id = p_distribution_id
                   AND pbc.document_header_id = p_header_id
                   AND pbc.document_type = p_document_type
                   AND pbc.balance_posted_flag = 'N'
                   AND pbc.status_code in ('A','C')
                   AND substr(nvl(result_code,'P'),1,1) = 'P'
                   AND NVL(pbc.document_header_id_2 ,-99) = NVL(p_po_release_id,-99));

BEGIN

        IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
           pa_funds_control_pkg.log_message(p_msg_token1 => ' IS_PO_BASED_INVOICE - Start');
        End if;

	OPEN  po_cur;
	FETCH po_cur INTO
		l_cc_header_id,
		l_cc_det_pf_line_id,
		l_po_destination_type;
        CLOSE po_cur;

        IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
           pa_funds_control_pkg.log_message(p_msg_token1 => ' l_cc_header_id ='||l_cc_header_id);
           pa_funds_control_pkg.log_message(p_msg_token1 => ' l_cc_det_pf_line_id ='||l_cc_det_pf_line_id);
           pa_funds_control_pkg.log_message(p_msg_token1 => ' l_po_destination_type ='||l_po_destination_type);
        End if;

        IF nvl(l_po_destination_type,'EXPENSE') in('INVENTORY','SHOP FLOOR') then

            IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
              pa_funds_control_pkg.log_message(p_msg_token1 => ' PO is Inventory based so update status code to S');
            End if;

            x_result_code := 'P113';
            x_status_code := 'V';
	    return 'N';

	ElSE

             l_po_found_flag := 'N';

             OPEN c_po_raw_burden(p_po_distribution_id,p_po_header_id,'PO') ;
    	     LOOP
	         FETCH c_po_raw_burden INTO l_parent_bc_packet_id;
                 IF c_po_raw_burden%notfound then
	            IF l_po_found_flag = 'N' THEN
	               x_result_code := 'F138'; -- No matching PO record found for this Invoice
	               x_status_code := 'R';
                  END IF;
                  IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
                     pa_funds_control_pkg.log_message(p_msg_token1 => ' No matching PO record found for this Invoice - F138');
                  End if;
	          EXIT;
                 END IF;

	         -- Found PO Record
	         l_po_found_flag := 'Y';

                 -- If burden record is found then intialize x_bc_commitment_id OUT variable
	         IF l_parent_bc_packet_id IS NOT NULL THEN
	            l_return_flag := 'Y';
                    IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
                     pa_funds_control_pkg.log_message(p_msg_token1 => ' l_parent_bc_packet_id ='||l_parent_bc_packet_id);
                    End if;
	            EXIT;
	         END IF;

             END LOOP;
	     CLOSE c_po_raw_burden;


             -- Code supporting existing CC flow
             IF l_po_found_flag = 'N' and l_cc_header_id is not null and l_cc_det_pf_line_id is not null then

		   l_cc_found_flag := 'N';

		   OPEN c_po_raw_burden(p_po_distribution_id,p_po_header_id,'CC_C_PAY') ;
		     LOOP
			 FETCH c_po_raw_burden INTO l_parent_bc_packet_id;
			 IF c_po_raw_burden%notfound then
			    IF l_cc_found_flag = 'N' THEN
			       x_result_code := 'F138'; -- No matching CC record found for this Invoice
			       x_status_code := 'R';
			    END IF;
                            IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
                               pa_funds_control_pkg.log_message(p_msg_token1 => 'No matching CC record found for this Invoice');
                            End if;
			  EXIT;
			 END IF;

			 -- Found cc Record
			 l_cc_found_flag := 'Y';

			 -- If burden record is found then intialize x_bc_commitment_id OUT variable
			 IF l_parent_bc_packet_id IS NOT NULL THEN
			    l_return_flag := 'Y';
                            IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
                               pa_funds_control_pkg.log_message(p_msg_token1 => ' Parent PO burden record found');
                            End if;
			    EXIT;
			 END IF;

		     END LOOP;
		     CLOSE c_po_raw_burden;
             END IF;  --IF l_po_found_flag = 'N' and l_cc_header_id is not null and l_cc_det_pf_line_id is not null then
        END IF;    --IF nvl(l_po_destination_type,'EXPENSE') in('INVENTORY','SHOP FLOOR') then

        IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
           pa_funds_control_pkg.log_message(p_msg_token1 => ' IS_PO_BASED_INVOICE - End l_return_flag =' ||l_return_flag);
        End if;

	Return l_return_flag;

EXCEPTION
WHEN OTHERS THEN

        IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
           pa_funds_control_pkg.log_message(p_msg_token1 => ' IS_PO_BASED_INVOICE - Exception'||SQLERRM);
        End if;

	Raise;

END is_po_based_invoice;

PROCEDURE COPY_AP_RECORD (p_copy_from_index    IN NUMBER,
                          p_new_rec_index      IN NUMBER) IS
BEGIN

       IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
         pa_funds_control_pkg.log_message(p_msg_token1 => 'COPY_AP_RECORD - Start');
       End if;

        g_tab_budget_version_id(p_new_rec_index)        :=  g_tab_budget_version_id(p_copy_from_index);
        g_tab_budget_line_id(p_new_rec_index)           :=  g_tab_budget_line_id(p_copy_from_index);
        g_tab_budget_ccid(p_new_rec_index)              :=  g_tab_budget_ccid(p_copy_from_index);
        g_tab_project_id(p_new_rec_index)               :=  g_tab_project_id(p_copy_from_index);
        g_tab_task_id(p_new_rec_index)                  :=  g_tab_task_id(p_copy_from_index);
        g_tab_exp_type(p_new_rec_index)                 :=  g_tab_exp_type(p_copy_from_index);
        g_tab_exp_org_id(p_new_rec_index)               :=  g_tab_exp_org_id(p_copy_from_index);
        g_tab_exp_item_date(p_new_rec_index)            :=  g_tab_exp_item_date(p_copy_from_index) ;
        g_tab_set_of_books_id(p_new_rec_index)          :=  g_tab_set_of_books_id(p_copy_from_index);
        g_tab_je_source_name(p_new_rec_index)           :=  g_tab_je_source_name(p_copy_from_index);
        g_tab_je_category_name(p_new_rec_index)         :=  g_tab_je_category_name(p_copy_from_index);
        g_tab_doc_type(p_new_rec_index)                 :=  g_tab_doc_type(p_copy_from_index);
        g_tab_doc_header_id(p_new_rec_index)            :=  g_tab_doc_header_id(p_copy_from_index);
        g_tab_doc_line_id(p_new_rec_index)              :=  g_tab_doc_line_id(p_copy_from_index);
        g_tab_doc_distribution_id(p_new_rec_index)      :=  g_tab_doc_distribution_id(p_copy_from_index);
	g_tab_inv_distribution_id(p_new_rec_index)      :=  g_tab_inv_distribution_id(p_copy_from_index);
        g_tab_actual_flag(p_new_rec_index)              :=  g_tab_actual_flag(p_copy_from_index);
        g_tab_result_code(p_new_rec_index)              :=  g_tab_result_code(p_copy_from_index);
        g_tab_status_code(p_new_rec_index)              :=  g_tab_status_code(p_copy_from_index);
        g_tab_balance_posted_flag(p_new_rec_index)      :=  g_tab_balance_posted_flag(p_copy_from_index);
        g_tab_funds_process_mode(p_new_rec_index)       :=  g_tab_funds_process_mode(p_copy_from_index);
        g_tab_burden_cost_flag(p_new_rec_index)         :=  g_tab_burden_cost_flag(p_copy_from_index);
        g_tab_org_id(p_new_rec_index)                   :=  g_tab_org_id(p_copy_from_index) ;
        g_tab_pkt_reference1(p_new_rec_index)           :=  g_tab_pkt_reference1(p_copy_from_index);
        g_tab_pkt_reference2(p_new_rec_index)           :=  g_tab_pkt_reference2(p_copy_from_index);
        g_tab_pkt_reference3(p_new_rec_index)           :=  g_tab_pkt_reference3(p_copy_from_index);
        g_tab_event_id(p_new_rec_index)                 :=  g_tab_event_id(p_copy_from_index);
	g_tab_vendor_id(p_new_rec_index)                :=  g_tab_vendor_id(p_copy_from_index);
        g_tab_burden_method_code(p_new_rec_index)       :=  g_tab_burden_method_code(p_copy_from_index);
        g_tab_main_or_backing_code(p_new_rec_index)     :=  g_tab_main_or_backing_code(p_copy_from_index);
        g_tab_source_event_id(p_new_rec_index)          :=  g_tab_source_event_id(p_copy_from_index);
        g_tab_trxn_ccid(p_new_rec_index)                :=  g_tab_trxn_ccid(p_copy_from_index);
        g_tab_p_bc_packet_id(p_new_rec_index)           :=  g_tab_p_bc_packet_id(p_copy_from_index);
	g_tab_fck_reqd_flag(p_new_rec_index)            :=  g_tab_fck_reqd_flag(p_copy_from_index);
	g_tab_entered_amount(p_new_rec_index)           :=  g_tab_entered_amount(p_copy_from_index);
	g_tab_accted_amount(p_new_rec_index)            :=  g_tab_accted_amount(p_copy_from_index);
        g_tab_ap_quantity_variance(p_new_rec_index)     :=  NULL;
        g_tab_ap_amount_variance(p_new_rec_index)       :=  NULL;
        g_tab_ap_base_qty_variance(p_new_rec_index)     :=  NULL;
        g_tab_ap_base_amount_variance(p_new_rec_index)  :=  NULL;
        g_tab_ap_po_distribution_id(p_new_rec_index)    :=  g_tab_ap_po_distribution_id(p_copy_from_index);
	g_tab_gl_date(p_new_rec_index)                  :=  g_tab_gl_date(p_copy_from_index);
	g_tab_distribution_type(p_new_rec_index)        :=  g_tab_distribution_type(p_copy_from_index);
	g_tab_po_release_id(p_new_rec_index)            :=  g_tab_po_release_id(p_copy_from_index);
	g_tab_enc_type_id(p_new_rec_index)              :=  g_tab_enc_type_id(p_copy_from_index);
	g_tab_period_name(p_new_rec_index)              :=  g_tab_period_name(p_copy_from_index);
        g_tab_parent_reversal_id(p_new_rec_index)       :=  g_tab_parent_reversal_id(p_copy_from_index); -- Bug 5406690

        -- Bug 5406690
	select pa_bc_packets_s.nextval
	into g_tab_bc_packet_id(p_new_rec_index)
	from dual;

       IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
         pa_funds_control_pkg.log_message(p_msg_token1 => 'COPY_AP_RECORD - End');
       End if;

EXCEPTION
WHEN OTHERS THEN

  IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
      pa_funds_control_pkg.log_message(p_msg_token1 => 'COPY_AP_RECORD - EXception'||SQLERRM);
  End if;

  RAISE;

END COPY_AP_RECORD;


PROCEDURE CREATE_AP_PO_RECORD (p_copy_from_index          IN NUMBER,
                               p_new_rec_index            IN NUMBER ) IS

        -- Cursor to fetch PO details for PO relieving record
        CURSOR c_po_details_cur(p_po_distribution_id  NUMBER) IS
        SELECT po.po_line_id                        po_line_id,
               po.po_header_id ,
	       (SELECT encumbrance_type_id
	          FROM gl_encumbrance_types
		 WHERE encumbrance_type_KEY = 'Obligation') po_encumbrance_type_id ,
               po.rate -- Bug 5665232
          FROM po_distributions_all po
         WHERE po.po_distribution_id = p_po_distribution_id;


        CURSOR c_po_dist_type (p_po_header_id  NUMBER,
	                       p_po_release_id NUMBER) IS
        SELECT type_lookup_code
          FROM po_headers_all po
         WHERE po.po_header_id = p_po_header_id
	   AND p_po_release_id IS NULL
	UNION
        SELECT release_type
          FROM po_releases_all po
         WHERE po.po_release_id = p_po_release_id
	   AND p_po_release_id IS NOT NULL;

BEGIN

	 IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
            pa_funds_control_pkg.log_message(p_msg_token1 => 'CREATE_AP_PO_RECORD - Start');
            pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of parameter p_copy_from_index ='||p_copy_from_index);
            pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of parameter p_new_rec_index ='||p_new_rec_index);
            pa_funds_control_pkg.log_message(p_msg_token1 => 'Calling COPY_AP_RECORD');
         End if;

         COPY_AP_RECORD (p_copy_from_index,p_new_rec_index);

	 IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
            pa_funds_control_pkg.log_message(p_msg_token1 => 'After Calling COPY_AP_RECORD');
            pa_funds_control_pkg.log_message(p_msg_token1 => 'Overwriting few of PO column values');
         End if;

         g_tab_doc_distribution_id(p_new_rec_index) :=  g_tab_ap_po_distribution_id(p_copy_from_index);
         g_tab_je_source_name(p_new_rec_index)      := 'Purchasing';
         IF g_tab_po_release_id(p_new_rec_index) IS NOT NULL THEN
            g_tab_je_category_name(p_new_rec_index)    := 'Release';
         ELSE
            g_tab_je_category_name(p_new_rec_index)    := 'Purchases';
         END IF;
         g_tab_doc_type(p_new_rec_index)            := 'PO';
         g_tab_pkt_reference1(p_new_rec_index)      := 'AP';
         g_tab_pkt_reference2(p_new_rec_index)      := g_tab_doc_header_id(p_copy_from_index); --Ap invoice associated with this backing PO
         g_tab_pkt_reference3(p_new_rec_index)      := g_tab_doc_distribution_id(p_copy_from_index); --Ap distribution associated with this backing PO

         OPEN  c_po_details_cur(g_tab_ap_po_distribution_id(p_new_rec_index));
         FETCH c_po_details_cur INTO g_tab_doc_line_id(p_new_rec_index) ,g_tab_doc_header_id(p_new_rec_index) ,
				     g_tab_enc_type_id(p_new_rec_index) ,g_tab_rate(p_new_rec_index) ; -- Bug 5665232
         CLOSE c_po_details_cur;

	 OPEN c_po_dist_type(g_tab_doc_header_id(p_new_rec_index),g_tab_po_release_id(p_copy_from_index));
	 FETCH c_po_dist_type INTO g_tab_distribution_type(p_new_rec_index) ;
	 CLOSE c_po_dist_type;

         -- Open issue for variance and ovematch AP-PO cases.

         g_tab_entered_dr(p_new_rec_index)              := g_tab_entered_cr(p_copy_from_index);
         g_tab_entered_cr(p_new_rec_index)              := g_tab_entered_dr(p_copy_from_index);

         /* Bug 5665232 :
	    If the rate on the PO distribution is not null then
	      Calculate accounted amounts for PO relieving record from its entered amounts and rate
            Else
	      Copy accounted amounts for PO relieving record from those on the invoice */

         If g_tab_rate(p_new_rec_index) is NOT NULL then
	   IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
             pa_funds_control_pkg.log_message(p_msg_token1 => 'Calculating accounted amounts for PO relieving record from its entered amounts and rate');
	     pa_funds_control_pkg.log_message(p_msg_token1 => 'Rate : '||g_tab_rate(p_new_rec_index));
           End if;
           g_tab_accounted_dr(p_new_rec_index)  := g_tab_entered_dr(p_new_rec_index) * g_tab_rate(p_new_rec_index);
	   g_tab_accounted_cr(p_new_rec_index)  := g_tab_entered_cr(p_new_rec_index) * g_tab_rate(p_new_rec_index);
         else
	   IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
             pa_funds_control_pkg.log_message(p_msg_token1 => 'Copying accounted amounts for PO relieving record from those on the invoice');
           End if;
           g_tab_accounted_dr(p_new_rec_index)            := g_tab_accounted_cr(p_copy_from_index);
           g_tab_accounted_cr(p_new_rec_index)            := g_tab_accounted_dr(p_copy_from_index);
         end if;
	 IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
           pa_funds_control_pkg.log_message(p_msg_token1 => 'Accounted_dr : '||g_tab_accounted_dr(p_new_rec_index));
	   pa_funds_control_pkg.log_message(p_msg_token1 => 'Accounted_cr : '||g_tab_accounted_cr(p_new_rec_index));
         End if;

         g_tab_ap_po_distribution_id(p_new_rec_index)   := NULL;

	 IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
            pa_funds_control_pkg.log_message(p_msg_token1 => 'After overwriting few of PO column values');
            pa_funds_control_pkg.log_message(p_msg_token1 => 'Before calling is_po_based_invoice');
         End if;

         -- Fetch parent_bc_packet_id for PO record
         IF  is_po_based_invoice (p_po_distribution_id             => g_tab_doc_distribution_id(p_new_rec_index)
                                  ,p_po_header_id                  => g_tab_doc_header_id(p_new_rec_index)
                                  ,p_po_release_id                 => g_tab_po_release_id(p_copy_from_index)
		                  ,x_result_code	           => g_tab_result_code(p_new_rec_index)
			          ,x_status_code		   => g_tab_status_code(p_new_rec_index))
                                  = 'Y' THEN

           IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
              pa_funds_control_pkg.log_message(p_msg_token1 => 'In is_po_based_invoice ');
           End if;

           g_tab_p_bc_packet_id(p_new_rec_index) := -1 ;

         END IF;

	 IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
            pa_funds_control_pkg.log_message(p_msg_token1 => 'After calling is_po_based_invoice');
            pa_funds_control_pkg.log_message(p_msg_token1 => 'CREATE_AP_PO_RECORD - End');
         End if;

EXCEPTION
WHEN OTHERS THEN

  IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
      pa_funds_control_pkg.log_message(p_msg_token1 => 'CREATE_AP_PO_RECORD - EXception'||SQLERRM);
  End if;

  RAISE;

END CREATE_AP_PO_RECORD;


PROCEDURE CREATE_APVAR_RECORD (p_copy_from_index          IN NUMBER,
                               p_new_rec_index            IN OUT NOCOPY NUMBER,
			       p_cwk_po_flag              IN VARCHAR2,
			       p_accrue_on_receipt_flag   IN VARCHAR2,
			       p_variance                 IN NUMBER,
			       p_base_variance            IN NUMBER ) IS

        -- Cursor to fetch AP variance details for AP variance record
        CURSOR ap_var_amt_cur IS
        SELECT DECODE(SIGN(p_variance),-1,0, p_variance) entered_dr,
	       DECODE(SIGN(p_variance),-1,ABS(p_variance),0)  entered_cr,
               DECODE(SIGN(p_base_variance),-1,0, p_base_variance) accounted_dr,
	       DECODE(SIGN(p_base_variance),-1,ABS(p_base_variance),0)  accounted_cr
          FROM dual;

BEGIN

	 IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
            pa_funds_control_pkg.log_message(p_msg_token1 => 'CREATE_APVAR_RECORD - Start');
            pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of parameter p_copy_from_index ='||p_copy_from_index);
            pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of parameter p_new_rec_index ='||p_new_rec_index);
            pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of parameter p_cwk_po_flag ='||p_cwk_po_flag);
            pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of parameter p_accrue_on_receipt_flag ='||p_accrue_on_receipt_flag);
            pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of parameter p_variance ='||p_variance);
            pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of parameter p_base_variance ='||p_base_variance);
            pa_funds_control_pkg.log_message(p_msg_token1 => 'Check if its a CWK OR accrure on receipt PO');
         End if;

         IF (p_cwk_po_flag = 'Y' OR p_accrue_on_receipt_flag = 'Y') THEN

            IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
              pa_funds_control_pkg.log_message(p_msg_token1 => 'Its a CWK OR accrue on receipt PO hence relieve only the variance for AP');
              pa_funds_control_pkg.log_message(p_msg_token1 => 'Overwriting main AP record amount columns ');
            End if;

            -- As only AP variance should be fundschecked , updating AP distribution amount columns with
	    -- varaince amount

	    OPEN ap_var_amt_cur;
            FETCH ap_var_amt_cur INTO g_tab_entered_dr(p_copy_from_index),
	                              g_tab_entered_cr(p_copy_from_index),
                                      g_tab_accounted_dr(p_copy_from_index),
				      g_tab_accounted_cr(p_copy_from_index);
            CLOSE ap_var_amt_cur;

          ELSE -- IF (p_cwk_po_flag = 'Y' OR p_accrue_on_receipt_flag = 'Y') THEN

            IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
              pa_funds_control_pkg.log_message(p_msg_token1 => 'Its NOT a CWK OR accrue on receipt PO hence create new record for ap variance');
              pa_funds_control_pkg.log_message(p_msg_token1 => 'Calling COPY_AP_RECORD');
            End if;

 	     -- As AP variance should be fundschecked in addition to AP distribution,
	     -- creating new record for AP varaince line

       	    COPY_AP_RECORD (p_copy_from_index,p_new_rec_index );

            g_tab_entered_amount(p_new_rec_index)           :=  p_variance;
	    g_tab_accted_amount(p_new_rec_index)            :=  p_base_variance;

	    OPEN ap_var_amt_cur;
            FETCH ap_var_amt_cur INTO g_tab_entered_dr(p_new_rec_index),
	                              g_tab_entered_cr(p_new_rec_index),
                                      g_tab_accounted_dr(p_new_rec_index),
				      g_tab_accounted_cr(p_new_rec_index);
            CLOSE ap_var_amt_cur;

          END IF; -- IF (p_cwk_po_flag = 'Y' OR p_accrue_on_receipt_flag = 'Y') THEN

	 IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
            pa_funds_control_pkg.log_message(p_msg_token1 => 'CREATE_APVAR_RECORD - End');
         End if;

EXCEPTION
WHEN OTHERS THEN

  IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
      pa_funds_control_pkg.log_message(p_msg_token1 => 'CREATE_APVAR_RECORD - Exception'||SQLERRM);
  End if;

  RAISE;

END CREATE_APVAR_RECORD;

-----------------------------------------------------------------------------------
-- R12 Funds management Uptake : New procedure to create additional records
-- for associated PO/RELEASE/AMOUNT variance/Quantity Variance while
-- fundschecking AP records.
-----------------------------------------------------------------------------------

PROCEDURE CREATE_BACKING_PO_APVAR_REC (p_copy_from_index    IN NUMBER) IS

       l_cwk_po_flag               VARCHAR2(1);
       l_accrue_on_receipt_flag    VARCHAR2(1);
       l_new_rec_index             NUMBER;

        -- Cursor to fetch PO details for PO relieving record
        CURSOR c_po_cwk_accrue_details_cur(p_po_distribution_id  NUMBER) IS
        SELECT pa_funds_control_utils2.is_CWK_PO
	                (po.po_header_id,
			 po.po_line_id,
			 po.po_distribution_id,
			 po.org_id)                 cwk_po_flag,
               NVL(po.accrue_on_receipt_flag,'N')   accrue_on_receipt_flag
          FROM po_distributions_all po
         WHERE po.po_distribution_id = p_po_distribution_id;

BEGIN

       IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
         pa_funds_control_pkg.log_message(p_msg_token1 => 'CREATE_BACKING_PO_APVAR_REC - p_copy_from_index = '
            ||p_copy_from_index);
         pa_funds_control_pkg.log_message(p_msg_token1 => 'CREATE_BACKING_PO_APVAR_REC - Start');
       End if;

       -- Below is the logic of splitting AP line into multiple bc records
       -- 1.IF po_distribution id populated then create PO relieving record
       --   a. IF amount variance exists then
       --         IF (CWK PO and interface CWK PO to projects is enabled at implementation level)  OR
       --            (accrue on receipt is YES) THEN
       --           update AP line amounts to variance amount as only variance is eligible for FC
       --         ELSE
       --           Create new BC record for variance line since both AP line and variance
       --           are eligible for FC
       --         END IF;
       --   b. IF quantity varaince exists then
       --           Create new BC record for variance line since both main AP line and variance
       --           are eligible for FC .-- Functionality to be verified.

       OPEN  c_po_cwk_accrue_details_cur(g_tab_ap_po_distribution_id(p_copy_from_index));
       FETCH c_po_cwk_accrue_details_cur INTO l_cwk_po_flag,
				              l_accrue_on_receipt_flag;
       CLOSE c_po_cwk_accrue_details_cur;

       IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
            pa_funds_control_pkg.log_message(p_msg_token1 => 'CREATE_BACKING_PO_APVAR_REC - l_cwk_po_flag ='||l_cwk_po_flag );
            pa_funds_control_pkg.log_message(p_msg_token1 => 'CREATE_BACKING_PO_APVAR_REC - l_accrue_on_receipt_flag ='||l_accrue_on_receipt_flag );
       End if;

       -- Calling procedure to relieve PO record only if non-CWK PO/ accrue on recipt is unchecked
       IF l_cwk_po_flag <> 'Y' AND l_accrue_on_receipt_flag <> 'Y' THEN

          IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
             pa_funds_control_pkg.log_message(p_msg_token1 => 'CREATE_BACKING_PO_APVAR_REC - before CREATE_AP_PO_RECORD');
          End if;

          l_new_rec_index  := g_tab_doc_header_id.count + 1  ;

          CREATE_AP_PO_RECORD (p_copy_from_index,
                               l_new_rec_index );

          IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
             pa_funds_control_pkg.log_message(p_msg_token1 => 'CREATE_BACKING_PO_APVAR_REC - After CREATE_AP_PO_RECORD');
          End if;

       END IF; --IF l_cwk_po_flag <> 'Y' AND l_accrue_on_receipt_flag <> 'Y' THEN


       IF NVL(g_tab_ap_amount_variance(p_copy_from_index),0) <> 0 THEN

          IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
             pa_funds_control_pkg.log_message(p_msg_token1 => 'CREATE_BACKING_PO_APVAR_REC - before CREATE_APVAR_RECORD for amount variance');
          End if;

          l_new_rec_index  := g_tab_doc_header_id.count + 1  ;

          CREATE_APVAR_RECORD (p_copy_from_index          => p_copy_from_index,
                               p_new_rec_index            => l_new_rec_index,
			       p_cwk_po_flag              => l_cwk_po_flag ,
			       p_accrue_on_receipt_flag   => l_accrue_on_receipt_flag,
			       p_variance                 => g_tab_ap_amount_variance(p_copy_from_index),
			       p_base_variance            => g_tab_ap_base_amount_variance(p_copy_from_index));

          IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
             pa_funds_control_pkg.log_message(p_msg_token1 => 'CREATE_BACKING_PO_APVAR_REC - before CREATE_APVAR_RECORD');
          End if;

       END IF; --IF NVL(g_tab_ap_amount_variance(p_copy_from_index),0) <> 0 THEN


       IF NVL(g_tab_ap_quantity_variance(p_copy_from_index),0) <> 0 THEN

          IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
             pa_funds_control_pkg.log_message(p_msg_token1 => 'CREATE_BACKING_PO_APVAR_REC - before CREATE_APVAR_RECORD for QTY variance');
          End if;

          l_new_rec_index  := g_tab_doc_header_id.count + 1  ;

          CREATE_APVAR_RECORD (p_copy_from_index          => p_copy_from_index,
                               p_new_rec_index            => l_new_rec_index,
			       p_cwk_po_flag              => l_cwk_po_flag ,
			       p_accrue_on_receipt_flag   => l_accrue_on_receipt_flag,
			       p_variance                 => g_tab_ap_quantity_variance(p_copy_from_index),
			       p_base_variance            => g_tab_ap_base_qty_variance(p_copy_from_index));

          IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
             pa_funds_control_pkg.log_message(p_msg_token1 => 'CREATE_BACKING_PO_APVAR_REC - before CREATE_APVAR_RECORD');
          End if;

       END IF;

   IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
      pa_funds_control_pkg.log_message(p_msg_token1 => ' CREATE_BACKING_PO_APVAR_REC - End  ');
   End if;

EXCEPTION
WHEN OTHERS THEN

  IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
      pa_funds_control_pkg.log_message(p_msg_token1 => 'CREATE_BACKING_PO_APVAR_REC - Exception'||SQLERRM);
  End if;

  RAISE;

END CREATE_BACKING_PO_APVAR_REC;

-----------------------------------------------------------------------------------
-- R12 Funds Management Uptake
-- Procedure to derive budget_ccid and budget_line_id for AP/PO/REQ trnsactions
-------------------------------------------------------------------------------------

PROCEDURE DERIVE_PKT_RLMI_BUDGET_CCID (p_packet_id IN NUMBER,
                                       p_bc_mode IN VARCHAR2) IS

 PRAGMA AUTONOMOUS_TRANSACTION;

 CURSOR c_pkt_SOB IS
 SELECT DISTINCT pbc.set_of_books_id
  FROM  pa_bc_packets pbc
 WHERE  pbc.packet_id = p_packet_id
   AND pbc.status_code = 'I'
   AND substr(nvl(pbc.result_code,'P'),1,1) not in ('R','F');

 CURSOR c_pkt_details IS
 SELECT DISTINCT
        pbc.project_id,
        pbc.task_id,
        pbc.period_name,
        pbc.gl_date,
        pbc.set_of_books_id,
        pbc.budget_version_id,
        pm.entry_level_code,
        DECODE(pm.entry_level_code,'P',0,pt.top_task_id) top_task_id,
        pbc.resource_list_member_id
  FROM  pa_bc_packets pbc,
        pa_tasks pt,
        pa_budget_versions bv,
        pa_budget_entry_methods pm
 WHERE  pbc.packet_id = p_packet_id
   AND pbc.budget_version_id = bv.budget_version_id
   AND bv.budget_entry_method_code = pm.budget_entry_method_code
   AND pbc.status_code = 'I'
   --AND substr(nvl(pbc.result_code,'P'),1,1) not in ('R','F')
   AND pt.task_id = pbc.task_id
   and nvl(ext_bdgt_flag,'N') = 'Y';


CURSOR c_get_gl_start_date (p_period_name VARCHAR2,
                            p_sob_id  NUMBER ) IS
SELECT gl.start_date
 FROM  gl_period_statuses gl
 WHERE gl.application_id = 101
   AND gl.set_of_books_id = p_sob_id
   AND gl.period_name  = p_period_name;

l_budget_line_id     pa_bc_packets.budget_line_id%TYPE;
l_budget_ccid        pa_bc_packets.budget_ccid%TYPE;
l_return_status      VARCHAR2(10) := 'S';
l_error_message_code VARCHAR2(200) := NULL;
l_gl_start_date      DATE;

BEGIN

  IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
      pa_funds_control_pkg.log_message(p_msg_token1 => 'DERIVE_PKT_RLMI_BUDGET_CCID - Start');
  End if;

  -- This will loop only once as a packet_id will have only one distinct SOB
  FOR c_sob IN c_pkt_SOB LOOP

      IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
         pa_funds_control_pkg.log_message(p_msg_token1 => 'Calling pa_funds_control_pkg.derive_rlmi for c_sob.set_of_books_id '||c_sob.set_of_books_id);
      End if;

      pa_funds_control_pkg.derive_rlmi
           ( p_packet_id      => p_packet_id,
             p_mode           => 'R',
             p_sob            => c_sob.set_of_books_id,
       	     p_calling_module => 'GL');

  END LOOP;


  FOR c_pkt in c_pkt_details LOOP

      IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
         pa_funds_control_pkg.log_message(p_msg_token1 => 'Calling PA_FUNDS_CONTROL_UTILS.Get_Budget_CCID ');
      End if;

      OPEN c_get_gl_start_date(c_pkt.period_name,c_pkt.set_of_books_id);
      FETCH c_get_gl_start_date INTO l_gl_start_date;
      CLOSE c_get_gl_start_date;


      PA_FUNDS_CONTROL_UTILS.Get_Budget_CCID (
                 p_project_id 		=> c_pkt.project_id,
                 p_task_id    		=> c_pkt.task_id,
                 p_res_list_mem_id 	=> c_pkt.resource_list_member_id,
                 --p_period_name  	=> c_pkt.period_name,
		 p_start_date		=> l_gl_start_date,
                 p_budget_version_id 	=> c_pkt.budget_version_id,
		 p_top_task_id		=> c_pkt.top_task_id,
		 p_entry_level_code     => c_pkt.entry_level_code,
                 x_budget_ccid  	=> l_budget_ccid,
                 x_budget_line_id       => l_budget_line_id,
                 x_return_status 	=> l_return_status,
                 x_error_message_code 	=> l_error_message_code);

      IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
         pa_funds_control_pkg.log_message(p_msg_token1 => 'After PA_FUNDS_CONTROL_UTILS.Get_Budget_CCID ');
         pa_funds_control_pkg.log_message(p_msg_token1 => 'c_pkt.project_id = '||c_pkt.project_id);
         pa_funds_control_pkg.log_message(p_msg_token1 => 'c_pkt.task_id = '||c_pkt.task_id);
         pa_funds_control_pkg.log_message(p_msg_token1 => 'c_pkt.resource_list_member_id = '||c_pkt.resource_list_member_id);
         pa_funds_control_pkg.log_message(p_msg_token1 => 'c_pkt.gl_date = '||c_pkt.gl_date);
         pa_funds_control_pkg.log_message(p_msg_token1 => 'c_pkt.budget_version_id = '||c_pkt.budget_version_id);
         pa_funds_control_pkg.log_message(p_msg_token1 => 'c_pkt.top_task_id = '||c_pkt.top_task_id);
         pa_funds_control_pkg.log_message(p_msg_token1 => 'c_pkt.entry_level_code = '||c_pkt.entry_level_code);
         pa_funds_control_pkg.log_message(p_msg_token1 => 'l_budget_ccid = '||l_budget_ccid);
         pa_funds_control_pkg.log_message(p_msg_token1 => 'l_budget_line_id = '||l_budget_line_id);
         pa_funds_control_pkg.log_message(p_msg_token1 => 'l_return_status = '||l_return_status);
         pa_funds_control_pkg.log_message(p_msg_token1 => 'l_error_message_code = '||l_error_message_code);
      End if;

      -- Fail pa bc packets if there is any error while deriving the budget ccid value
      IF l_return_status = 'E' OR NVL(l_budget_ccid,-999) = -999 OR NVL(l_budget_line_id,-999) = -999  THEN


         UPDATE  pa_bc_packets
            set  budget_ccid              = l_budget_ccid,
                 budget_line_id           = l_budget_line_id,
                 status_code              = DECODE(status_code,'F',status_code,'R',status_code,'T',status_code,DECODE(p_bc_mode,'C','F','R')),
                 result_code              = DECODE(substr(result_code,1,1),'F',result_code,'F132'),
                 PROJECT_RESULT_CODE      = DECODE(substr(PROJECT_RESULT_CODE,1,1),'F',PROJECT_RESULT_CODE,'F132'),
                 TASK_RESULT_CODE         = DECODE(substr(TASK_RESULT_CODE,1,1),'F',TASK_RESULT_CODE,'F132'),
                 RES_GRP_RESULT_CODE      = DECODE(substr(RES_GRP_RESULT_CODE,1,1),'F',RES_GRP_RESULT_CODE,'F132'),
                 RES_RESULT_CODE          = DECODE(substr(RES_RESULT_CODE,1,1),'F',RES_RESULT_CODE,'F132'),
                 TOP_TASK_RESULT_CODE     = DECODE(substr(TOP_TASK_RESULT_CODE,1,1),'F',TOP_TASK_RESULT_CODE,'F132'),
                 PROJECT_ACCT_RESULT_CODE = DECODE(substr(PROJECT_ACCT_RESULT_CODE,1,1),'F',PROJECT_ACCT_RESULT_CODE,'F132')
           WHERE packet_id = p_packet_id
             AND status_code ='I'
             AND project_id = c_pkt.project_id
             AND task_id = c_pkt.task_id
             AND resource_list_member_id = c_pkt.resource_list_member_id
             AND NVL(period_name,'X')  = NVL(c_pkt.period_name,'X')
             AND gl_date = c_pkt.gl_date ;

          IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
             pa_funds_control_pkg.log_message(p_msg_token1 => 'DERIVE_PKT_RLMI_BUDGET_CCID - # of records updated to F132='||SQL%ROWCOUNT);
          End if;

      ELSE


         UPDATE  pa_bc_packets
            set  budget_ccid              = l_budget_ccid,
                 budget_line_id           = l_budget_line_id
           WHERE packet_id = p_packet_id
             AND status_code ='I'
             AND project_id = c_pkt.project_id
             AND task_id = c_pkt.task_id
             AND resource_list_member_id = c_pkt.resource_list_member_id
             AND NVL(period_name,'X')  = NVL(c_pkt.period_name,'X')
             AND gl_date = c_pkt.gl_date ;

          IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
             pa_funds_control_pkg.log_message(p_msg_token1 => 'DERIVE_PKT_RLMI_BUDGET_CCID - # of records updated with budget ccid info='||SQL%ROWCOUNT);
          End if;

      END IF;

   END LOOP;

  COMMIT;

  IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
      pa_funds_control_pkg.log_message(p_msg_token1 => 'DERIVE_PKT_RLMI_BUDGET_CCID - End');
  End if;

EXCEPTION
WHEN OTHERS THEN

  IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
      pa_funds_control_pkg.log_message(p_msg_token1 => 'DERIVE_PKT_RLMI_BUDGET_CCID - EXception'||SQLERRM);
  End if;

  RAISE;

END DERIVE_PKT_RLMI_BUDGET_CCID;

-----------------------------------------------------------------------------------
-- R12 Funds Management Uptake
-- Procedure to derive entered_dr,entered_cr,accounted_dr,accounted_cr columns
-- for PO and REQ  distributions
-------------------------------------------------------------------------------------
PROCEDURE DERIVE_DR_CR IS
BEGIN

    IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
       pa_funds_control_pkg.log_message(p_msg_token1 => 'Start of DERIVE_DR_CR ');
    End if;

   FOR l_index IN 1..g_tab_set_of_books_id.Last LOOP

     g_tab_entered_dr(l_index)   := 0;
     g_tab_entered_cr(l_index)   := 0 ;
     g_tab_accounted_dr(l_index) := 0 ;
     g_tab_accounted_cr(l_index) := 0 ;

     IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
       pa_funds_control_pkg.log_message(p_msg_token1 => 'value of  g_tab_main_or_backing_code '||g_tab_main_or_backing_code(l_index));
       pa_funds_control_pkg.log_message(p_msg_token1 => 'value of  g_tab_event_type_code '||g_tab_event_type_code(l_index));
       pa_funds_control_pkg.log_message(p_msg_token1 => 'value of  g_tab_distribution_type '||g_tab_distribution_type(l_index));
     End if;

     -- Below function returns 1 if the amount should be populated in debit columns
     -- and -1 if amounts should be populated in credit columns

     IF PA_FUNDS_CONTROL_UTILS.DERIVE_PO_REQ_AMT_SIDE
                               (g_tab_event_type_code(l_index) ,
                                g_tab_main_or_backing_code(l_index),
                                g_tab_distribution_type(l_index) ) = 1 THEN

   	g_tab_entered_dr(l_index)   := g_tab_entered_amount(l_index);
    	g_tab_accounted_dr(l_index) := g_tab_accted_amount (l_index);

    ELSE
    	g_tab_entered_cr(l_index)   := g_tab_entered_amount(l_index);
     	g_tab_accounted_cr(l_index) := g_tab_accted_amount (l_index);
    END IF;

    IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
       pa_funds_control_pkg.log_message(p_msg_token1 => 'value of  g_tab_entered_dr '||g_tab_entered_dr(l_index));
       pa_funds_control_pkg.log_message(p_msg_token1 => 'value of  g_tab_entered_cr '||g_tab_entered_cr(l_index));
       pa_funds_control_pkg.log_message(p_msg_token1 => 'value of  g_tab_accounted_dr '||g_tab_accounted_dr(l_index));
       pa_funds_control_pkg.log_message(p_msg_token1 => 'value of  g_tab_accounted_cr '||g_tab_accounted_cr(l_index));
    End if;

  END LOOP;

    IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
       pa_funds_control_pkg.log_message(p_msg_token1 => 'End of DERIVE_DR_CR ');
    End if;

END DERIVE_DR_CR;

-----------------------------------------------------------------------------------
-- R12 Funds Management Uptake
-- Procedure to fail records in FULL mode if any error during insert API
-------------------------------------------------------------------------------------

PROCEDURE FULL_MODE_FAILURE (p_packet_id     IN NUMBER,
                             p_bc_mode       IN VARCHAR2,
                             x_return_code   OUT NOCOPY VARCHAR2) IS

PRAGMA AUTONOMOUS_TRANSACTION;

CURSOR c_pkt_status IS
SELECT 1
  FROM pa_bc_packets
 WHERE packet_id = p_packet_id
   AND (status_code in ('F','T','R')
        OR SUBSTR (result_code,1,1) = 'F');

l_counter                   NUMBER := 0;

BEGIN

 IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
    pa_funds_control_pkg.log_message(p_msg_token1 => 'FULL_MODE_FAILURE : Start ');
 END IF;

 x_return_code := 'S' ;

 OPEN c_pkt_status;
 FETCH c_pkt_status INTO l_counter;
 CLOSE c_pkt_status;

 IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
    pa_funds_control_pkg.log_message(p_msg_token1 => 'FULL_MODE_FAILURE : l_counter  '||l_counter);
 END IF;

 IF l_counter > 0 THEN

     x_return_code := 'F' ;

     UPDATE pa_bc_packets a
        SET  a.status_code            = DECODE(p_bc_mode,'C','F','R'),
             a.result_code            = DECODE( SUBSTR (result_code,1,1),'F',result_code,'F170'),
             res_result_code          = DECODE(substr(res_result_code,1,1),'F',res_result_code,'F170'),
             res_grp_result_code      = DECODE(substr(res_grp_result_code,1,1),'F',res_grp_result_code,'F170'),
             task_result_code         = DECODE(substr(task_result_code,1,1),'F',task_result_code,'F170'),
             top_task_result_code     = DECODE(substr(top_task_result_code,1,1),'F',top_task_result_code,'F170'),
             project_result_code      = DECODE(substr(project_result_code,1,1),'F',project_result_code,'F170'),
             project_acct_result_code = DECODE(substr(project_acct_result_code,1,1),'F',project_acct_result_code,'F170')
      WHERE  a.status_code = 'I'
        AND  a.status_code <> 'F'
        AND  a.packet_id = p_packet_id;

     IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
        pa_funds_control_pkg.log_message(p_msg_token1 => 'FULL_MODE_FAILURE : number of records failed in full mode  '||SQL%ROWCOUNT);
     END IF;

 END IF;

 IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
    pa_funds_control_pkg.log_message(p_msg_token1 => 'FULL_MODE_FAILURE : End');
 END IF;

 COMMIT;

END;

-----------------------------------------------------------------------------------
-- R12 Funds Management Uptake
-- Autonomous Procedure to fail bc records which have no bc event generated
-------------------------------------------------------------------------------------

PROCEDURE FAIL_NULL_EVENT_PKTS (p_packet_id     IN NUMBER,
                                p_bc_mode       IN VARCHAR2) IS

PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

 IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
    pa_funds_control_pkg.log_message(p_msg_token1 => 'FAIL_NULL_EVENT_PKTS : Start ');
 END IF;

UPDATE pa_bc_packets a
   SET a.status_code = DECODE(p_bc_mode,'C','F','R'),
       a.result_code = 'F168' ,
       res_result_code          = DECODE(substr(res_result_code,1,1),'F',res_result_code,'F168'),
       res_grp_result_code      = DECODE(substr(res_grp_result_code,1,1),'F',res_grp_result_code,'F168'),
       task_result_code         = DECODE(substr(task_result_code,1,1),'F',task_result_code,'F168'),
       top_task_result_code     = DECODE(substr(top_task_result_code,1,1),'F',top_task_result_code,'F168'),
       project_result_code      = DECODE(substr(project_result_code,1,1),'F',project_result_code,'F168'),
       project_acct_result_code = DECODE(substr(project_acct_result_code,1,1),'F',project_acct_result_code,'F168')
 WHERE a.status_code = 'I'
   AND a.ext_bdgt_flag = 'Y'
   AND a.packet_id = p_packet_id
   AND a.bc_event_id is null;

 COMMIT;

 IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
    pa_funds_control_pkg.log_message(p_msg_token1 => 'FAIL_NULL_EVENT_PKTS : End');
 END IF;

END;


-----------------------------------------------------------------------------------
-- R12 Funds Management Uptake
-- Autonomous Procedure to fail all dangling bc records created in previous run
-------------------------------------------------------------------------------------

PROCEDURE FAIL_DANGLING_PKTS (p_packet_id     IN NUMBER) IS

PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

 IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
    pa_funds_control_pkg.log_message(p_msg_token1 => 'FAIL_DANGLING_PKTS : Start ');
 END IF;

UPDATE pa_bc_packets
   SET status_code = 'T',
       result_code = 'F142',
       res_result_code          = DECODE(substr(res_result_code,1,1),'F',res_result_code,'F142'),
       res_grp_result_code      = DECODE(substr(res_grp_result_code,1,1),'F',res_grp_result_code,'F142'),
       task_result_code         = DECODE(substr(task_result_code,1,1),'F',task_result_code,'F142'),
       top_task_result_code     = DECODE(substr(top_task_result_code,1,1),'F',top_task_result_code,'F142'),
       project_result_code      = DECODE(substr(project_result_code,1,1),'F',project_result_code,'F142'),
       project_acct_result_code = DECODE(substr(project_acct_result_code,1,1),'F',project_acct_result_code,'F142')
WHERE  packet_id <> p_packet_id
  AND  status_code = 'I';

 COMMIT;

 IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
    pa_funds_control_pkg.log_message(p_msg_token1 => 'FAIL_DANGLING_PKTS : End');
 END IF;

END;

-----------------------------------------------------------------------------------
-- R12 Funds Management Uptake --rshaik
-- ----------------------------
-- Called from PSA_BC_XLA_PVT.Budgetary_control after creating events for AP/PO/REQ.
-- and before It performs following tasks :
-- 1. Driving table for this procedure is psa_bc_xla_events_gt .Picks all AP/PO/REQ events
--    created by BCPSA FC engine.
-- 2. Inserts raw records into pa_bc_packets by fetching PO/REQ data from po_bc_distributions
--    and AP data from ap_invoice_distributions_all table for all events in psa_bc_xla_events_gt.
-- 3. Fires populate_burden_cost procedure to Insert burden records for above raw components
-- 4. Fires pa_funds_control_pkg.derive_rlmi to derive resource_list_member_id on bc packets
-- 5. Fires pa_funds_control_utils.get_budegt_ccid to derive budget_ccid and budget_line_id
-- 6. Finally calls pa_xla_interface_pkg.create_events to create events for project
--    encumbrance data and populate BC GT table.
-------------------------------------------------------------------------------------

PROCEDURE CREATE_PROJ_ENCUMBRANCE_EVENTS  (p_application_id      IN         NUMBER ,
                               		   p_partial_flag        IN         VARCHAR2 DEFAULT 'N' ,
                                           p_bc_mode             IN         VARCHAR2 DEFAULT 'C' ,
                                           x_return_code         OUT NOCOPY VARCHAR2 ) IS

        l_return_status    VARCHAR2(100);
	l_debug_mode       VARCHAR2(10);
	l_err_msg_code      VARCHAR2(2000);

        -- R12 funds management uptake : Cursor to fetch PO data from po_bc_distributions.
	-- This global temporary table has records for PO and also for requisition which
	-- needs to be unreserved

	CURSOR cur_po_bc_dist IS
	    SELECT NULL                                                      budget_version_id,
	           NULL                                                      budget_line_id,
	           NULL                                                      budget_ccid,
 		   pobc.pa_project_id                                        project_id,
		   pobc.pa_task_id                                           task_id,
		   pobc.pa_exp_type                                          expenditure_type,
		   pobc.pa_exp_org_id                                        expenditure_organization_id,
		   pobc.pa_exp_item_date                                     expenditure_item_date,
		   pobc.ledger_id                                            set_of_books_id,
 		   -- The below hardcoded values for Je_source_name and Je_category_name columns
		   -- are based on SLA seed data for PO and REQ. These values are later
		   -- updated by pa_funds_check API to synch up with gl_bc_packets if different
                   'Purchasing'                                              je_source_name,
   		   DECODE(pobc.distribution_type,
			       'REQUISITION','Requisitions',
                               'BLANKET'   ,'Release',
        		       'SCHEDULED' ,'Release',
			       'Purchases')                                  je_category_name,
                   DECODE(pobc.distribution_type,'REQUISITION','REQ','PO')   document_type,
                   pobc.header_id	                                     document_header_id,
		   -- Populated for PA Purchasing extracts.And with this change document_line_id
		   -- is no longer a unique way of identifying if the BC packet is associated with CWK
                   pobc.line_id                                              document_line_id,
		   pobc.distribution_id                                      document_distribution_id,
		   'E'                                                       actual_flag,
		   NULL                                                      result_code,
		   'I'                                                       status_code,
		   pobc.event_type_code                                      event_type_code,
                   pobc.entered_amt                                          entered_amount,
                   pobc.accounted_amt                                        accounted_amount,
                   'N'                                                       balance_posted_flag,
                   'T'                                                       funds_process_mode,
                   'N'                                                       burden_cost_flag,
  		   NULL                                                      org_id,
		   DECODE(pobc.distribution_type,'REQUISITION','REQ','PO')   reference1,
		   pobc.header_id                                            reference2,
		   pobc.distribution_id                                      reference3,
                   NULL                                                      bc_event_id,
		   NULL                                                      vendor_id,
		   pa_funds_control_pkg.check_bdn_on_sep_item
		                                 (pobc.pa_project_id)        burden_method_code,
		   pobc.main_or_backing_code                                 main_or_backing_code,
                   pobc.ae_event_id                                          source_event_id,
		   pobc.CODE_COMBINATION_ID                                  txn_ccid,
		   NULL                                                      parent_bc_packet_id,
                   pa_funds_control_utils.get_fnd_reqd_flag
			           (pobc.pa_project_id,'STD')                fck_reqd_flag,
                   pobc.gl_date                                              gl_date,
                   pogt.period_name                                          period_name,
                   -- Below code is added to handle Requisition adjusment scenario :
                   -- If REQ adjusted line has adjustment type as 'OLD' then amount previously reserved should be relieved
                   -- else if REQ adjusted line has adjustment type as 'NEW' then new amount should be reserved
                   -- i.e. IF distribution_type = 'REQUISITION_ADJUSTED_OLD' then CR
                   --      IF distribution_type = 'REQUISITION_ADJUSTED_NEW' then DR
                   DECODE(event_type_code, 'REQ_ADJUSTED',
		           DECODE(pobc.main_or_backing_code,'M',
		                  DECODE(pobc.adjustment_status
				         ,'OLD',pobc.distribution_type||'_ADJUSTED_OLD'
		                         ,'NEW',pobc.distribution_type||'_ADJUSTED_NEW'
		                         ,pobc.distribution_type),
		                  pobc.distribution_type),
		          pobc.distribution_type)                            distribution_type,
                   DECODE(pobc.distribution_type,'SCHEDULED',pobc.po_release_id
		                                ,'BLANKET',pobc.po_release_id
						,NULL)                       release_id,
                   DECODE(pobc.distribution_type,'REQUISITION'
		                                ,1000
						,decode(pobc.main_or_backing_code, 'B_REQ', 1000, 1001)) encumbrance_type_id,
		   -- Bug 5403775 : Added below columns to derive pkt reference columns for backing docs such that
		   -- they will point to the main doc
		   POBC.origin_sequence_num,
		   pobc.applied_to_dist_id_2,
		   pa_bc_packets_s.nextval                                   bc_packet_id -- Bug 5406690
             FROM  po_bc_distributions pobc ,
                   po_encumbrance_gt   pogt,
	           psa_bc_xla_events_gt xlaevt
            WHERE  pobc.ae_event_id = xlaevt.event_id
    	      AND  pobc.pa_project_id IS NOT NULL
    	      AND  pogt.distribution_id = pobc.distribution_id
    	      AND  pogt.distribution_type = pobc.distribution_type
              AND  EXISTS ( SELECT 1
		                FROM  po_requisition_lines_all porl
				WHERE nvl(porl.DESTINATION_TYPE_CODE,'EXPENSE') = 'EXPENSE'
				  AND porl.requisition_line_id = pobc.line_id
				  AND pobc.distribution_type = 'REQUISITION'
                               UNION ALL
			       SELECT 1
		                FROM  po_distributions_all pord
				WHERE nvl(pord.DESTINATION_TYPE_CODE,'EXPENSE') = 'EXPENSE'
				  AND pord.po_distribution_id = pobc.distribution_id
				  AND pobc.distribution_type <> 'REQUISITION' )
              /** Bug fix : 2347699 added this check to make sure that project is not cross charged **/
	      /** BugFix : If grants and projects enables in the same ou then errors with no data found in cursors*/
       	      AND  EXISTS (SELECT  1
                                FROM  pa_projects_all pp,
 				      pa_implementations_all imp
                	       WHERE  pp.project_id = pobc.pa_project_id
	        	         AND  pp.org_id  = imp.org_id
			         AND  imp.set_of_books_id = pobc.ledger_id )
              AND EXISTS ( SELECT 'Project Bdgt Ctrl enabled'
                                 FROM pa_budget_types bdgttype
                                      ,pa_budgetary_control_options pbct
                                WHERE pbct.project_id = pobc.pa_project_id
                                  AND pbct.BDGT_CNTRL_FLAG = 'Y'
                                  AND (pbct.EXTERNAL_BUDGET_CODE = 'GL' OR
                                       pbct.EXTERNAL_BUDGET_CODE is NULL
                                      )
                                  AND pbct.BUDGET_TYPE_CODE = bdgttype.budget_type_code
                                  AND bdgttype.budget_amount_code = 'C'
                              );

        -- R12 funds management uptake : This cursor is introduced for performance reasons.
	-- This is used to fetch all eligible project related ap invoice distributions getting
	-- processed in this run and then fetch data from bulky AP extracts (cursor cur_ap_bc_dist)
	-- based on the invoice_distribution_id's
	-- Note : This cursor fetches only the AP dist record ,it doesnt fetch associated
	-- PO/RELEASE that has to be unreserved.

        CURSOR c_proj_ap_dist IS
	   SELECT  apd.invoice_distribution_id,
	           DECODE(apd.line_type_lookup_code -- Bug 5490378
		          ,'NONREC_TAX',DECODE(apd.prepay_distribution_id,NULL,apd.line_type_lookup_code,'PREPAY')
			  ,apd.line_type_lookup_code)
             FROM  ap_invoice_distributions_all apd ,
	           psa_bc_xla_events_gt xlaevt,
		   ap_invoices_all apinv
            WHERE  apd.bc_event_id = xlaevt.event_id
	      AND  apd.project_id IS NOT NULL
	      AND  NVL(apd.pa_addition_flag, 'X' ) <> 'T'
	      AND  apinv.invoice_id = apd.invoice_id
	      AND  apinv.invoice_type_lookup_code <> 'EXPENSE REPORT'
	      AND  apd.line_type_lookup_code <> 'REC_TAX'
	      -- R12 : Prepayments mathed to PO will not be fundschecked
	      AND  ((apinv.invoice_type_lookup_code = 'PREPAYMENT'
	             AND apd.po_distribution_id IS NULL )
		     OR apinv.invoice_type_lookup_code <> 'PREPAYMENT')
	      --R12 : Application of Prepayment matched to PO will not be fundschecked
	      --Bug 5490378 : NONREC_TAX associated with prepay line should be filtered out
              AND  NOT EXISTS
	           ( SELECT 1
		       FROM dual
		      WHERE apd.line_type_lookup_code IN ('PREPAY','NONREC_TAX')
			AND apd.prepay_distribution_id IS NOT NULL
			AND apd.po_distribution_id IS NOT NULL)
              -- Bug 5562245 : As part of PSA bug 5563122 fix ,code logic has been modified such that
	      -- Variances on AP matched to PO with accrue on receipt will not be fundschecked.
              -- Bug 5494476 : AP ITEM Distribution matched to CWK PO will be fundschecked only for the
              -- the amout/quantity variance amount.If no variance stamped on the ITEM distribution then
	      -- filter out those distributions.
	      -- Bug 5533290 : AP TAX Distribution matched to CWK PO will be fundschecked only for the
              -- the variance amount.Even tough AP TAX is eligible for interface to projects,the commitment amount
	      -- will remain with PO and during interface will be relieved from PO bucket
	      AND NOT EXISTS ( SELECT 1
	                         FROM po_distributions_all pod
				WHERE pod.po_distribution_id = apd.po_distribution_id
				  AND apd.po_distribution_id IS NOT NULL
				  AND ((NVL(pod.accrue_on_receipt_flag,'N') = 'Y' -- Bug 5348212
				        AND apd.line_type_lookup_code IN ('ITEM','ACCRUAL','NONREC_TAX'))
				        OR
                                        (pa_funds_control_utils2.is_CWK_PO -- Bug 5494476
				                (pod.po_header_id,pod.po_line_id,pod.po_distribution_id,pod.org_id) = 'Y'
				         AND apd.line_type_lookup_code IN ('ITEM','NONREC_TAX') -- Bug 5533290
                                         AND NVL(apd.amount_variance,0)= 0
 	     			         AND NVL(apd.base_amount_variance,0)=0
				         AND NVL(apd.quantity_variance,0)=0
				         AND NVL(apd.base_quantity_variance,0)=0
					 )
				       )
             		      )
              /** Bug fix : 2347699 added this check to make sure that project is not cross charged **/
	      /** BugFix : If grants and projects enables in the same ou then errors with no data found in cursors*/
       	      AND  EXISTS (SELECT  1
                                FROM  pa_projects_all pp,
 				      pa_implementations_all imp
                	       WHERE  pp.project_id = apd.project_id
	        	         AND  pp.org_id  = imp.org_id
			         AND  imp.set_of_books_id = apd.set_of_books_id )
              AND  EXISTS ( SELECT 'Project Bdgt Ctrl enabled'
                                 FROM pa_budget_types bdgttype
                                      ,pa_budgetary_control_options pbct
                                WHERE pbct.project_id = apd.project_id
                                  AND pbct.BDGT_CNTRL_FLAG = 'Y'
                                  AND (pbct.EXTERNAL_BUDGET_CODE = 'GL' OR
                                       pbct.EXTERNAL_BUDGET_CODE is NULL
                                      )
                                  AND pbct.BUDGET_TYPE_CODE = bdgttype.budget_type_code
                                  AND bdgttype.budget_amount_code = 'C'
                              );

        -- R12 Funds Management Uptake : This is the main cursor to fetch records from ap extracts
	-- for all eligible invoice distribution id's. This cursor fetches data for Standard Invoices
	-- and prepayments. Note : For prepayments there will be multiple lines for each invoice
	-- distribution as data is fetched from AP_PREPAY_APP_DISTS.
	-- Note : This cursor fetches only the AP dist record ,it doesnt fetch associated
	-- PO/RELEASE that has to be unreserved.

                   /* Bug 5203226 : AP's amount calculation logic for all type of invoices
		      (except prepay application) for populating entered and accounted amounts

		   distribution type  accounted_amt             entered_amt
		   ----------------------------------------------------------------
		   ERV                ENCUMBRANCE_BASE_AMOUNT    ENCUMBRANCE_AMOUNT
		   TERV               AID_EXTRA_PO_ERV/          ENCUMBRANCE_AMOUNT
		                      ENCUMBRANCE_BASE_AMOUNT
		   ITEM               ENCUMBRANCE_BASE_AMOUNT    ENCUMBRANCE_AMOUNT
		   IPV                ENCUMBRANCE_BASE_AMOUNT    ENCUMBRANCE_AMOUNT
		   MISCELLANEOUS      ENCUMBRANCE_BASE_AMOUNT    ENCUMBRANCE_AMOUNT
		   FREIGHT            ENCUMBRANCE_BASE_AMOUNT    ENCUMBRANCE_AMOUNT
		   NONREC_TAX         ENCUMBRANCE_BASE_AMOUNT    ENCUMBRANCE_AMOUNT
		   TIPV               ENCUMBRANCE_BASE_AMOUNT    ENCUMBRANCE_AMOUNT
		   TRV                ENCUMBRANCE_BASE_AMOUNT    ENCUMBRANCE_AMOUNT
		   FREIGHT            ENCUMBRANCE_BASE_AMOUNT    ENCUMBRANCE_AMOUNT
		   Item/tax amt var   AID_BASE_AMOUNT_VARIANCE   AID_AMOUNT_VARIANCE
		   Item/tax qty var   AID_BASE_QUANTITY_VARIANCE AID_QUANTITY_VARIANCE
                   backing PO         ENCUMBRANCE_BASE_AMOUNT    ENCUMBRANCE_AMOUNT

		   Note:
		   ENCUMBRANCE_BASE_AMOUNT = NVL(AID.base_amount,AID.amount) - NVL
		   (AID.base_amount_variance,nvl(AID.amount_variance,0)) - NVL(AID.
		   base_quantity_variance,NVL(AID.quantity_variance,0))

                   ENCUMBRANCE_AMOUNT =NVL(AID.amount,0) - NVL(AID.amount_variance,0) -
		   NVL(AID.quantity_variance,0)
		   */

	CURSOR cur_ap_bc_dist (p_stdinvoice_exists VARCHAR2,
	                       p_prepay_exists     VARCHAR2) IS
	    SELECT NULL                                                        budget_version_id,
	           NULL                                                        budget_line_id,
	           NULL                                                        budget_ccid,
 		   apext.aid_project_id                                        project_id,
		   apext.aid_task_id                                           task_id,
		   apext.aid_expenditure_type                                  expenditure_type,
		   apext.aid_expenditure_org_id                                expenditure_organization_id,
 		   -- The below hardcoded values for Je_source_name and Je_category_name columns
		   -- are based on SLA seed data for PO and REQ. These values are later
		   -- updated by pa_funds_check API to synch up with gl_bc_packets if different
                   'Payables'                                                  je_source_name,
   		   'Purchase Invoices'                                         je_category_name,
                   'AP'                                                        document_type,
                   apext.bus_flow_inv_id                                       document_header_id,
                   apext.aid_invoice_line_number                               document_line_id,
		   apext.aid_invoice_dist_id                                   document_distribution_id,
		   -- For standard invoice this is always same as document_distribution_id
		   apext.aid_invoice_dist_id                                   invoice_distribution_id,
		   'E'                                                         actual_flag,
		   NULL                                                        result_code,
		   'I'                                                         status_code,
		   ENCUMBRANCE_AMOUNT                                          entered_amount,	--Bug 5203226/5498978
		   ENCUMBRANCE_BASE_AMOUNT                                     accounted_amount, --Bug 5203226/5498978
                   'N'                                                         balance_posted_flag,
                   'T'                                                         funds_process_mode,
                   'N'                                                         burden_cost_flag,
                   --Below decode ensures that PO is relieved only when attached to ITEM/ACCRUAL line
		   DECODE(apext.AID_LINE_TYPE_LOOKUP_CODE
		          ,'ITEM',DECODE(apext.po_distribution_id,NULL,'AP','PO')
		          ,'ACCRUAL',DECODE(apext.po_distribution_id,NULL,'AP','PO')
                          ,'NONREC_TAX',DECODE(apext.po_distribution_id,NULL,'AP','PO') -- Bug 5523570
		          ,NULL)                                               reference1,
		   DECODE(apext.AID_LINE_TYPE_LOOKUP_CODE
		          ,'ITEM', DECODE(apext.po_distribution_id
			           ,NULL,apext.bus_flow_inv_id
				   ,apext.bus_flow_po_doc_id)
		          ,'ACCRUAL',DECODE(apext.po_distribution_id
			                    ,NULL,apext.bus_flow_inv_id
					    ,apext.bus_flow_po_doc_id)
                          ,'NONREC_TAX',DECODE(apext.po_distribution_id   -- Bug 5523570
			                    ,NULL,apext.bus_flow_inv_id
					    ,apext.bus_flow_po_doc_id)
		          , NULL)                                              reference2,
		   DECODE(apext.AID_LINE_TYPE_LOOKUP_CODE
		          ,'ITEM', DECODE(apext.po_distribution_id
			                  ,NULL,apext.aid_invoice_dist_id
					  ,apext.po_distribution_id)
                          ,'ACCRUAL',DECODE(apext.po_distribution_id
			                    ,NULL,apext.aid_invoice_dist_id
					    ,apext.po_distribution_id)
                          ,'NONREC_TAX',DECODE(apext.po_distribution_id        -- Bug 5523570
			                    ,NULL,apext.aid_invoice_dist_id
					    ,apext.po_distribution_id)
                          , NULL)                                              reference3,
                   NULL                                                        bc_event_id,
		   pa_funds_control_pkg.check_bdn_on_sep_item
		                                 (apext.aid_project_id)        burden_method_code,
		   NULL                                                        main_or_backing_code,
                   apext.event_id                                              source_event_id,
		   apext.aid_dist_ccid                                         txn_ccid,
		   NULL                                                        parent_bc_packet_id,
                   pa_funds_control_utils.get_fnd_reqd_flag
			                      (apext.aid_project_id ,'STD')    fck_reqd_flag,
		   apext.aid_quantity_variance                                 ap_quantity_variance,
		   apext.aid_amount_variance                                   ap_amount_variance,
		   apext.aid_base_quantity_variance                            ap_base_quantity_variance,
		   apext.aid_base_amount_variance                              ap_base_amount_variance,
		   /* Bug 5406564 : Below decode ensures that PO is relieved only when attached to ITEM/ACCRUAL/NONREC_TAX line
		      and not for variance records. */
		   DECODE(apext.AID_LINE_TYPE_LOOKUP_CODE
		          ,'ITEM',apext.po_distribution_id
		          ,'ACCRUAL',apext.po_distribution_id
			  ,'NONREC_TAX',apext.po_distribution_id
		          , NULL)                                              ap_po_distribution_id,
		   apext.aid_accounting_date                                   gl_date,
            	   -- Bug 5238282 : Prepayment application will be treated as standard invoice line for check funds
		   -- as there will be no data in ap_prepay_app_dists table.This table is populated during invoice
		   -- validation.
		   DECODE(p_bc_mode,'C'
		                   ,DECODE(apext.AID_LINE_TYPE_LOOKUP_CODE
				           ,'PREPAY','STANDARD'
					   ,apext.AID_LINE_TYPE_LOOKUP_CODE)
                                   ,apext.AID_LINE_TYPE_LOOKUP_CODE)           distribution_type,
		   DECODE(apext.AID_LINE_TYPE_LOOKUP_CODE
		          ,'ITEM',DECODE(apext.bus_flow_po_entity_code
			                 ,'RELEASE',apext.bus_flow_po_doc_id,NULL)
                          ,'ACCRUAL',DECODE(apext.bus_flow_po_entity_code
			                 ,'RELEASE',apext.bus_flow_po_doc_id,NULL)
                          ,'NONREC_TAX',DECODE(apext.bus_flow_po_entity_code -- Bug 5523570
                                         ,'RELEASE',apext.bus_flow_po_doc_id,NULL)
                          , NULL)                                              release_id,
		   -- R12 Funds Management Uptake: Currently this column is not available in AP extract
		   -- hence added below logic to fetch encumbrance_type_id for invoices
		   (SELECT encumbrance_type_id
		      FROM gl_encumbrance_types
		     WHERE encumbrance_type_KEY = 'Invoices')                  encumbrance_type_id,
                   --pa_utils2.get_gl_period_name(apd.accounting_date,apd.org_id)
                   apext.aid_period_name                                       period_name,
		   apext.AID_PARENT_REVERSAL_ID                                parent_reversal_id -- Bug 5406690
             FROM  ap_extract_invoice_dtls_bc_v apext -- Bug 5500126
            WHERE  apext.aid_invoice_dist_id IN (select Column_Value from Table(g_ap_inv_dist_id))
	      AND  apext.event_id in ( SELECT event_id FROM psa_bc_xla_events_gt)
  	      AND  (p_bc_mode ='C'
	            OR (apext.aid_line_type_lookup_code <> 'PREPAY' AND p_bc_mode <>'C')) -- Bug 5238282
              AND  NOT EXISTS ( --Bug 5490378 : Filter out Tax associated with prepay lines for reserve action
	            SELECT 1
		      FROM ap_invoice_distributions_all apd1
		     WHERE apd1.invoice_distribution_id = apext.charge_applicable_to_dist_id
		       AND apext.aid_line_type_lookup_code = 'NONREC_TAX'
		       AND apext.charge_applicable_to_dist_id IS NOT NULL
		       AND p_bc_mode <> 'C'
		       AND apd1.line_type_lookup_code = 'PREPAY')
	      AND  p_stdinvoice_exists = 'Y'
            UNION ALL
            SELECT NULL                                                        budget_version_id,
	           NULL                                                        budget_line_id,
	           NULL                                                        budget_ccid,
                   AID.project_id                                              project_id,
                   AID.task_id                                                 task_id,
                   AID.expenditure_type                                        expenditure_type,
                   AID.expenditure_organization_id                             expenditure_organization_id,
 		   -- The below hardcoded values for Je_source_name and Je_category_name columns
		   -- are based on SLA seed data for PO and REQ. These values are later
		   -- updated by pa_funds_check API to synch up with gl_bc_packets if different
                   'Payables'                                                  je_source_name,
	           'Purchase Invoices'                                         je_category_name,
                   'AP'                                                        document_type,
                   AID.invoice_id                                              document_header_id,
                   AID.INVOICE_LINE_NUMBER                                     document_line_id,
                   APAD.Prepay_App_Distribution_ID                             document_distribution_id,
                   AID.invoice_distribution_id                                 invoice_distribution_id,
	       	   'E'                                                         actual_flag,
		   NULL                                                        result_code,
		   'I'                                                         status_code,
                   APAD.AMOUNT                                                  entered_amount,
                   nvl(APAD.Base_amount, APAD.amount)                          accounted_amount,
                   'N'                                                         balance_posted_flag,
                   'T'                                                         funds_process_mode,
                   'N'                                                         burden_cost_flag,
                   -- For prepayment application reference columns will refer prepayment dist which
                   -- needs to be reversed.There wont be any fundscheck for prepayments matched to PO
                   'AP'                                                        reference1,
                   APPH.PREPAY_INVOICE_ID                                      reference2,
                   AID.PREPAY_DISTRIBUTION_ID                                  reference3,
                   NULL                                                        bc_event_id,
 		   pa_funds_control_pkg.check_bdn_on_sep_item
		                             (AID.project_id)                  burden_method_code,
		   NULL                                                        main_or_backing_code,
                   APPH.bc_event_id                                            source_event_id,
                   AID.Dist_code_combination_id                                txn_ccid,
		   NULL                                                        parent_bc_packet_id,
                   pa_funds_control_utils.get_fnd_reqd_flag(AID.project_id
			                                 ,'STD')               fck_reqd_flag,
       	           NULL                                                        ap_quantity_variance,
		   NULL                                                        ap_amount_variance,
		   NULL                                                        ap_base_quantity_variance,
		   NULL                                                        ap_base_amount_variance,
                   AID.po_distribution_id                                      ap_po_distribution_id,
                   AID.ACCOUNTING_DATE                                         gl_date,
                   APAD.prepay_dist_lookup_code                                distribution_type,
                   AIL.po_release_id                                           release_id,
                   -- R12 Funds Management Uptake: Currently this column
                   -- is not available in AP extract
                   -- hence added below logic to fetch encumbrance_type_id for invoices
                   (SELECT encumbrance_type_id
                      FROM gl_encumbrance_types
                     WHERE encumbrance_type_KEY = 'Invoices')                  encumbrance_type_id,
                   AID.PERIOD_NAME                                             period_name,
		   AID.parent_reversal_id                                      parent_reversal_id -- Bug 5406690
              FROM AP_PREPAY_HISTORY_ALL APPH,
                   AP_PREPAY_APP_DISTS APAD,
                   AP_INVOICE_LINES_ALL AIL,
                   AP_INVOICE_DISTRIBUTIONS_ALL AID
             WHERE AID.bc_event_id = APPH.bc_Event_id
               AND APPH.prepay_history_id = APAD.prepay_history_id
               AND AID.invoice_line_number = AIL.line_number
               AND AID.invoice_id = AIL.invoice_id
               AND AID.line_type_lookup_code IN ( 'PREPAY' ,'NONREC_TAX' ) --Bug 5490378
               and APPH.bc_Event_id IN ( SELECT event_id FROM psa_bc_xla_events_gt)
               and AID.invoice_distribution_id IN (select Column_Value from Table(g_ap_inv_dist_id))
               AND p_prepay_exists = 'Y'
               and aid.invoice_distribution_id = apad.prepay_app_distribution_id;

        -- R12 Funds Management Uptake : This cursor fetches additional required information
	-- which is not provided by AP extracts ap_invoice_extract_details_v/
	-- AP_PREPAYAPP_EXTRACT_DETAILS_V.

        CURSOR c_ap_details (p_inv_dist_id NUMBER) IS
        SELECT apd.set_of_books_id,
	       apd.expenditure_item_date,
	       apd.org_id,
	       apinv.vendor_id
          FROM ap_invoice_distributions_all apd,
	       ap_invoices_all apinv
         WHERE apd.invoice_distribution_id = p_inv_dist_id
	   AND apinv.invoice_id = apd.invoice_id;

        --R12 Funds Management Uptake:Deleted CBC related logic

        -- Cursor to fetch Vendor and organization details for REQ line
    	CURSOR cur_req_vend_org_details (p_req_line_id  IN NUMBER )IS
	SELECT  pov.vendor_id,
	        porl.org_id
          FROM  po_vendors pov,
	        po_requisition_lines_all porl
         WHERE  pov.vendor_name (+) = porl.suggested_vendor_name
	   AND  porl.REQUISITION_LINE_ID =p_req_line_id;

        -- Cursor to fetch Vendor and organization details for PO line
	CURSOR cur_po_vend_org_details (p_header_id  NUMBER )IS
	SELECT  poh.vendor_id,
	        poh.org_id
          FROM  po_headers_all poh
         WHERE  poh.po_header_id = p_header_id;


	CURSOR c_count_success_recs(p_packet_id NUMBER) IS
	SELECT count(*)
	  FROM pa_bc_packets
	 WHERE packet_id = p_packet_id
	   AND (NVL(status_code,'I') NOT IN ('F','T','R')
		AND SUBSTR (NVL(result_code,'P'),1,1) <> 'F');

        -- Bug 5403775: Cursor to fetch main document details  associated with backing document
    	CURSOR cur_po_main_doc_details (p_req_event_id IN NUMBER,
	                                p_req_origin_seq_num IN NUMBER )IS
	SELECT  DECODE(ORIG.distribution_type ,'SCHEDULED','REL'
                                              ,'BLANKET','REL'
                                              ,'PO'),
	        DECODE(ORIG.distribution_type ,'SCHEDULED',ORIG.po_release_id
                                              ,'BLANKET',ORIG.po_release_id
                                              ,ORIG.header_id)
          FROM  PO_BC_DISTRIBUTIONS ORIG
         WHERE  ORIG.sequence_number= p_req_origin_seq_num
	   AND  ORIG.ae_event_id = p_req_event_id;

       l_index                     NUMBER;
       l_count_success_rec         NUMBER;

       l_old_req_line_id           PO_REQUISITION_LINES_ALL.REQUISITION_LINE_ID%TYPE;
       l_old_po_header_id          PO_HEADERS_ALL.po_HEADER_ID%TYPE;
       l_req_vendor_id             PO_HEADERS_ALL.VENDOR_ID%TYPE;
       l_req_org_id                PO_HEADERS_ALL.ORG_ID%TYPE;
       l_Po_vendor_id              PO_HEADERS_ALL.VENDOR_ID%TYPE;
       l_po_org_id                 PO_HEADERS_ALL.ORG_ID%TYPE;
       l_packet_id                 pa_bc_packets.packet_id%TYPE;
       l_prepay_exists             VARCHAR2(1);
       l_stdinvoice_exists         VARCHAR2(1);

BEGIN

        --- Initialize the error statck
        PA_DEBUG.init_err_stack ('PA_FUNDS_CONTROL_PKG1.CREATE_PROJ_ENCUMBRANCE_EVENTS');

        fnd_profile.get('PA_DEBUG_MODE',PA_FUNDS_CONTROL_PKG.g_debug_mode);
        PA_FUNDS_CONTROL_PKG.g_debug_mode := NVL(PA_FUNDS_CONTROL_PKG.g_debug_mode, 'N');

        PA_DEBUG.SET_PROCESS( x_process        => 'PLSQL'
                             ,x_write_file     => 'LOG'
                             ,x_debug_mode     => PA_FUNDS_CONTROL_PKG.g_debug_mode);


	-- Bug 5354715 : Added the "PA IMPLEMENTED IN OU" check.
        IF PA_FUNDS_CONTROL_PKG.IS_PA_INSTALL_IN_OU = 'N' then
                x_return_code := 'S';

		If pa_funds_control_pkg.g_debug_mode = 'Y' then
			pa_funds_control_pkg.log_message(p_msg_token1=>'PA NOT INSTALLED IN THIS OU.return code='
				||x_return_code);
		end if;
                PA_DEBUG.Reset_err_stack;
		Return;
        END IF;

    -- Bug#6645995 Made this code applicable only for the applications
    -- Purchasing / Payables/ Contract Commitments
    -- as we do funds check for only transactions coming from the above applications.

    -- Moved this initialization before the if statement to ensure that any call made
    -- from other than Purchasing / Payables/ Contract Commitments
    -- will get 'S'uccess status code.

    x_return_code := 'S';

    IF p_application_id in (200, 201, 8407) THEN

	IF pa_budget_fund_pkg.g_processing_mode IN ('YEAR_END','CHECK_FUNDS','BASELINE') THEN
           RETURN;
        END IF;

	IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
 	  pa_funds_control_pkg.log_message(p_msg_token1 => 'CREATE_PROJ_ENCUMBRANCE_EVENTS : In start ');
 	  pa_funds_control_pkg.log_message(p_msg_token1 => 'CREATE_PROJ_ENCUMBRANCE_EVENTS : p_application_id = '||p_application_id);
 	  pa_funds_control_pkg.log_message(p_msg_token1 => 'CREATE_PROJ_ENCUMBRANCE_EVENTS : p_partial_flag = '||p_partial_flag);
 	  pa_funds_control_pkg.log_message(p_msg_token1 => 'Calling init_plsql_tabs to initialize the pl/sql tabs ');
	End if;

	-- Initialize the pl/sql table which stores pa_bc_packets records
	init_plsql_tabs;

	IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
 	  pa_funds_control_pkg.log_message(p_msg_token1 => 'Calling init_util_variables');
	End if;

	--Initialize the funds control util package global variables
	PA_FUNDS_CONTROL_UTILS.init_util_variables;

	-- initialize the accounting currency code,
        pa_multi_currency.init;

       --Get the accounting currency into a global variable.
        g_acct_currency_code := pa_multi_currency.g_accounting_currency_code;

        -------->6599207 ------As part of CC Enhancements
	-- The following call is to create bcpackets for GL budget.

	IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
 	  pa_funds_control_pkg.log_message(p_msg_token1 => 'Calling populate_plsql_tabs_CBC');
	End if;

	IF p_application_id = 8407 THEN --Calling application is Contract Commitments
	   populate_plsql_tabs_CBC(NULL,'GL','','',p_bc_mode);
	END IF;

	IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
 	  pa_funds_control_pkg.log_message(p_msg_token1 => 'After Calling populate_plsql_tabs_CBC');
	End if;
	-------->6599207 ------END

	IF p_application_id = 200 THEN --Calling application is Payables

           	IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
 	           pa_funds_control_pkg.log_message(p_msg_token1 => 'Fetching eligible distributions from ap_invoice_distributions_all');
         	End if;

                OPEN  c_proj_ap_dist;
		FETCH c_proj_ap_dist BULK COLLECT INTO  g_ap_inv_dist_id,g_ap_line_type_lkup;
                CLOSE c_proj_ap_dist;

           	IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
 	           pa_funds_control_pkg.log_message(p_msg_token1 => 'Number of AP distribuions fetched ='||g_ap_inv_dist_id.count);
         	End if;

		IF g_ap_inv_dist_id.count <> 0 THEN

		   l_prepay_exists := 'N';
                   l_stdinvoice_exists := 'N';

                   FOR i in 1..g_ap_line_type_lkup.count LOOP
		     -- Bug 5238282 : Prepayment application will be treated as standard invoice line for check funds
		     -- as there will be no data in ap_prepay_app_dists table.This table is populated during invoice
		     -- validation.
		     IF g_ap_line_type_lkup(i) = 'PREPAY' AND p_bc_mode <> 'C' THEN
		        l_prepay_exists := 'Y';
                     ELSE
		        l_stdinvoice_exists := 'Y';
		     END IF;
                     -- Exit the loop if both prepay and standard invoices exists.
		     IF l_prepay_exists= 'Y' AND l_stdinvoice_exists = 'Y' THEN
		        EXIT;
                     END IF;

		   END LOOP;

                   IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
   	              pa_funds_control_pkg.log_message(p_msg_token1 => 'For current run there exists PREPAY distribution ? '||l_prepay_exists);
 	              pa_funds_control_pkg.log_message(p_msg_token1 => 'For current run there exists Std Invoice distribution ? '||l_stdinvoice_exists);
                   End if;

           	   IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
 	              pa_funds_control_pkg.log_message(p_msg_token1 => 'Fetching required data from AP extract into plsql tables');
         	   End if;

		   OPEN cur_ap_bc_dist(l_stdinvoice_exists,l_prepay_exists);
		   FETCH cur_ap_bc_dist BULK COLLECT INTO
					g_tab_budget_version_id,
					g_tab_budget_line_id,
					g_tab_budget_ccid,
					g_tab_project_id,
					g_tab_task_id,
					g_tab_exp_type,
					g_tab_exp_org_id,
					g_tab_je_source_name,
					g_tab_je_category_name,
					g_tab_doc_type,
					g_tab_doc_header_id,
					g_tab_doc_line_id,
					g_tab_doc_distribution_id,
					g_tab_inv_distribution_id,
					g_tab_actual_flag,
					g_tab_result_code,
					g_tab_status_code,
                                     	g_tab_entered_amount,
                	                g_tab_accted_amount,
					g_tab_balance_posted_flag,
					g_tab_funds_process_mode,
					g_tab_burden_cost_flag,
					g_tab_pkt_reference1,
					g_tab_pkt_reference2,
					g_tab_pkt_reference3,
					g_tab_event_id,
					g_tab_burden_method_code,
					g_tab_main_or_backing_code,
					g_tab_source_event_id,
					g_tab_trxn_ccid,
					g_tab_p_bc_packet_id,
					g_tab_fck_reqd_flag,
					g_tab_ap_quantity_variance,
					g_tab_ap_amount_variance,
					g_tab_ap_base_qty_variance,
					g_tab_ap_base_amount_variance,
					g_tab_ap_po_distribution_id,
                                        g_tab_gl_date,
					g_tab_distribution_type,
                                        g_tab_po_release_id,
					g_tab_enc_type_id,
                                        g_tab_period_name,
					g_tab_parent_reversal_id; -- Bug 5406690
					/***** Any additional columns added here should also be added in COPY_AP_RECORD procedure
					       as COPY_AP_RECOR proc creates new records in plsql tables for backing PO and
					       variance records and if any new plsql variables are not initialized for these new
					       records the code will raise exception *****/
                   CLOSE cur_ap_bc_dist ;

                   -- Bug 5406690
                   FOR i IN 1..g_tab_doc_header_id.count LOOP
		      select pa_bc_packets_s.nextval
		      into g_tab_bc_packet_id(i)
		      from dual;
                   END LOOP;

           	   IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
 	              pa_funds_control_pkg.log_message(p_msg_token1 => 'Number of records fetched from AP extract into plsql tables'||g_tab_doc_header_id.count);
         	   End if;

                   -- AP extract returns one record for an AP distribution with PO/quantity variance and amount
	  	   -- variance columns populated. Hence AP line with this information populated should be split into
		   -- multiple bc packet records.

                   IF pa_funds_control_pkg.g_debug_mode = 'Y' AND g_tab_doc_header_id.count<>0  THEN

  		      FOR l_index IN 1..g_tab_doc_header_id.last LOOP

 	                pa_funds_control_pkg.log_message(p_msg_token1 => '***Start of record-'||l_index||' fetched from AP extract***');
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_budget_version_id = '||g_tab_budget_version_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_budget_line_id = '||g_tab_budget_line_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_budget_ccid = '||g_tab_budget_ccid(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_project_id = '||g_tab_project_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_task_id = '||g_tab_task_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_exp_type = '||g_tab_exp_type(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_exp_org_id = '||g_tab_exp_org_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_je_source_name = '||g_tab_je_source_name(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_je_category_name = '||g_tab_je_category_name(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_doc_type = '||g_tab_doc_type(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_doc_header_id = '||g_tab_doc_header_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_doc_line_id = '||g_tab_doc_line_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_doc_distribution_id = '||g_tab_doc_distribution_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_inv_distribution_id = '||g_tab_inv_distribution_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_actual_flag = '||g_tab_actual_flag(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_result_code = '||g_tab_result_code(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_status_code = '||g_tab_status_code(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_entered_amount = '||g_tab_entered_amount(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_accted_amount = '||g_tab_accted_amount(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_balance_posted_flag = '||g_tab_balance_posted_flag(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_funds_process_mode = '||g_tab_funds_process_mode(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_burden_cost_flag = '||g_tab_burden_cost_flag(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_pkt_reference1 = '||g_tab_pkt_reference1(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_pkt_reference2 = '||g_tab_pkt_reference2(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_pkt_reference3 = '||g_tab_pkt_reference3(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_event_id = '||g_tab_event_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_burden_method_code = '||g_tab_burden_method_code(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_main_or_backing_code = '||g_tab_main_or_backing_code(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_source_event_id = '||g_tab_source_event_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_trxn_ccid = '||g_tab_trxn_ccid(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_p_bc_packet_id = '||g_tab_p_bc_packet_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_fck_reqd_flag = '||g_tab_fck_reqd_flag(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_ap_quantity_variance = '||g_tab_ap_quantity_variance(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_ap_amount_variance = '||g_tab_ap_amount_variance(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_ap_base_qty_variance = '||g_tab_ap_base_qty_variance(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_ap_base_amount_variance = '||g_tab_ap_base_amount_variance(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_ap_po_distribution_id = '||g_tab_ap_po_distribution_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_gl_date = '||g_tab_gl_date(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_distribution_type = '||g_tab_distribution_type(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_po_release_id = '||g_tab_po_release_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_enc_type_id = '||g_tab_enc_type_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_period_name = '||g_tab_period_name(l_index));
                        pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_bc_packet_id = '||g_tab_bc_packet_id(l_index));
			pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_parent_reversal_id = '||g_tab_parent_reversal_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => '****End of record-'||l_index||' fetched from AP extract***');

  		      END LOOP;

        	    End if;

  		  IF g_tab_doc_header_id.count <> 0 THEN

                   FOR l_index IN 1..g_tab_doc_header_id.last LOOP

             	     IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Before fetching c_ap_details');
         	     End if;

		     OPEN  c_ap_details (g_tab_inv_distribution_id(l_index));
		     FETCH c_ap_details INTO g_tab_set_of_books_id(l_index),
		                             g_tab_exp_item_date(l_index),
					     g_tab_org_id(l_index),
					     g_tab_vendor_id(l_index);
		     CLOSE c_ap_details;

             	     IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'After fetching c_ap_details');
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Deriving DR and CR column ');
         	     End if;

		     IF NVL(g_tab_entered_amount(l_index),0) <0 THEN
		        g_tab_entered_dr(l_index) := 0;
		        g_tab_entered_cr(l_index) := ABS(NVL(g_tab_entered_amount(l_index),0));
                     ELSE
		        g_tab_entered_cr(l_index) := 0;
		        g_tab_entered_dr(l_index) := NVL(g_tab_entered_amount(l_index),0);
		     END IF;

		     IF NVL(g_tab_accted_amount(l_index),0) <0 THEN
		        g_tab_accounted_dr(l_index) := 0;
		        g_tab_accounted_cr(l_index) := ABS(NVL(g_tab_accted_amount(l_index),0));
                     ELSE
		        g_tab_accounted_cr(l_index) := 0;
		        g_tab_accounted_dr(l_index) := NVL(g_tab_accted_amount(l_index),0);
		     END IF;

             	     IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'After deriving DR and CR column ');
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Calling pa_funds_control_utils2.GET_DRAFTORBASELINE_BDGTVER');
         	     End if;

		    -- Code to populate budget_version_id
                    g_tab_budget_version_id(l_index)
			                 := pa_funds_control_utils2.GET_DRAFTORBASELINE_BDGTVER
                                                                     (g_tab_project_id(l_index),'GL','BASELINE');
                    If (g_tab_budget_version_id(l_index) is NULL ) Then

                           IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
	                        pa_funds_control_pkg.log_message(p_msg_token1 => 'Budget derivation failed marking to F166 ');
        	           End if;
                           g_tab_result_code(l_index)   := 'F166';
                           g_tab_status_code(l_index)   := 'R';
                           g_tab_fck_reqd_flag(l_index) := 'Y';
                           g_tab_budget_version_id(l_index) := NVL(pa_funds_control_utils2.GET_DRAFTORBASELINE_BDGTVER
                                                (g_tab_project_id(l_index),'GL','DRAFT'),-9999);

                           GOTO END_OF_AP_LOOP; -- process next record

                    End If; --If (g_tab_budget_version_id(l_index) is NULL ) Then
		    --End of code to populate budget_version_id

                   IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of derived Budget Version Id  ='||g_tab_budget_version_id(l_index));
        	   End if;

                   -- Code to check if there exists associated PO/Release and if exists create records
		   -- to relieve amount variance/quantitiy variance AND PO .

  	           IF g_tab_ap_po_distribution_id(l_index) IS NOT NULL THEN

                       IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
	                  pa_funds_control_pkg.log_message(p_msg_token1 => 'Calling CREATE_BACKING_PO_APVAR_REC ');
            	       End if;

                       -- Creating PO relieving record by copying AP line record and overwriting required column values

		       CREATE_BACKING_PO_APVAR_REC(p_copy_from_index  => l_index);

  	            END IF; --IF g_tab_ap_po_distribution_id(l_index) IS NOT NULL THEN

                   << END_OF_AP_LOOP>>
		   NULL;
		   END LOOP;

		END IF;

                IF pa_funds_control_pkg.g_debug_mode = 'Y' AND g_tab_doc_header_id.count<>0  THEN

  		      FOR l_index IN 1..g_tab_doc_header_id.last LOOP

 	                pa_funds_control_pkg.log_message(p_msg_token1 => '***Start of record-'||l_index||' records after firing AP fetching logic ***');
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_budget_version_id = '||g_tab_budget_version_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_budget_line_id = '||g_tab_budget_line_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_budget_ccid = '||g_tab_budget_ccid(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_project_id = '||g_tab_project_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_task_id = '||g_tab_task_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_exp_type = '||g_tab_exp_type(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_exp_org_id = '||g_tab_exp_org_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_je_source_name = '||g_tab_je_source_name(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_je_category_name = '||g_tab_je_category_name(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_doc_type = '||g_tab_doc_type(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_doc_header_id = '||g_tab_doc_header_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_doc_line_id = '||g_tab_doc_line_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_doc_distribution_id = '||g_tab_doc_distribution_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_inv_distribution_id = '||g_tab_inv_distribution_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_actual_flag = '||g_tab_actual_flag(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_result_code = '||g_tab_result_code(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_status_code = '||g_tab_status_code(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_entered_amount = '||g_tab_entered_amount(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_accted_amount = '||g_tab_accted_amount(l_index));
                        pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_entered_dr = '||g_tab_entered_dr(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_entered_cr = '||g_tab_entered_cr(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_accounted_dr = '||g_tab_accounted_dr(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_accounted_cr = '||g_tab_accounted_cr(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_balance_posted_flag = '||g_tab_balance_posted_flag(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_funds_process_mode = '||g_tab_funds_process_mode(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_burden_cost_flag = '||g_tab_burden_cost_flag(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_pkt_reference1 = '||g_tab_pkt_reference1(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_pkt_reference2 = '||g_tab_pkt_reference2(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_pkt_reference3 = '||g_tab_pkt_reference3(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_event_id = '||g_tab_event_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_burden_method_code = '||g_tab_burden_method_code(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_main_or_backing_code = '||g_tab_main_or_backing_code(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_source_event_id = '||g_tab_source_event_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_trxn_ccid = '||g_tab_trxn_ccid(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_p_bc_packet_id = '||g_tab_p_bc_packet_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_fck_reqd_flag = '||g_tab_fck_reqd_flag(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_ap_quantity_variance = '||g_tab_ap_quantity_variance(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_ap_amount_variance = '||g_tab_ap_amount_variance(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_ap_base_qty_variance = '||g_tab_ap_base_qty_variance(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_ap_base_amount_variance = '||g_tab_ap_base_amount_variance(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_ap_po_distribution_id = '||g_tab_ap_po_distribution_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_gl_date = '||g_tab_gl_date(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_distribution_type = '||g_tab_distribution_type(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_po_release_id = '||g_tab_po_release_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_enc_type_id = '||g_tab_enc_type_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_period_name = '||g_tab_period_name(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_set_of_books_id = '||g_tab_set_of_books_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_exp_item_date = '||g_tab_exp_item_date(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_org_id = '||g_tab_org_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_vendor_id = '||g_tab_vendor_id(l_index));
                        pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_bc_packet_id = '||g_tab_bc_packet_id(l_index));
			pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_parent_reversal_id = '||g_tab_parent_reversal_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => '****End of record-'||l_index||' records after firing AP fetching logic***');

  		      END LOOP;

        	 End if;

		END IF; --IF g_ap_inv_dist_id.count <> 0 THEN

        END IF; -- IF p_application_id = 200 THEN

	IF p_application_id = 201 THEN -- Calling application is Purchasing

           	IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
 	           pa_funds_control_pkg.log_message(p_msg_token1 => 'Fetching PO/REQ data ');
         	End if;

		OPEN cur_po_bc_dist ;
		FETCH cur_po_bc_dist BULK COLLECT INTO
					g_tab_budget_version_id,
					g_tab_budget_line_id,
					g_tab_budget_ccid,
					g_tab_project_id,
					g_tab_task_id,
					g_tab_exp_type,
					g_tab_exp_org_id,
					g_tab_exp_item_date,
					g_tab_set_of_books_id,
					g_tab_je_source_name,
					g_tab_je_category_name,
					g_tab_doc_type,
					g_tab_doc_header_id,
					g_tab_doc_line_id,
					g_tab_doc_distribution_id,
					g_tab_actual_flag,
					g_tab_result_code,
					g_tab_status_code,
					g_tab_event_type_code,
                                     	g_tab_entered_amount,
                	                g_tab_accted_amount,
					g_tab_balance_posted_flag,
					g_tab_funds_process_mode,
					g_tab_burden_cost_flag,
					g_tab_org_id,
					g_tab_pkt_reference1,
					g_tab_pkt_reference2,
					g_tab_pkt_reference3,
					g_tab_event_id,
					g_tab_vendor_id,
					g_tab_burden_method_code,
					g_tab_main_or_backing_code,
					g_tab_source_event_id,
					g_tab_trxn_ccid,
					g_tab_p_bc_packet_id,
					g_tab_fck_reqd_flag,
					/*g_tab_bc_commitment_id,
					g_tab_ap_quantity_variance,
					g_tab_ap_amount_variance,
					g_tab_ap_base_qty_variance,
					g_tab_ap_base_amount_variance,
					g_tab_ap_po_distribution_id,*/
					g_tab_gl_date,
                                        g_tab_period_name,
					g_tab_distribution_type,
					g_tab_po_release_id,
					g_tab_enc_type_id,
                                     	g_tab_orig_sequence_num,
                                 	g_tab_applied_to_dist_id_2,
					g_tab_bc_packet_id; -- Bug 5406690

		CLOSE cur_po_bc_dist ;

           	IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
 	           pa_funds_control_pkg.log_message(p_msg_token1 => 'Number of AP distributions fetched for FC ='||g_tab_set_of_books_id.count);
         	End if;

               IF pa_funds_control_pkg.g_debug_mode = 'Y' AND g_tab_doc_header_id.count<>0 THEN

  		      FOR l_index IN 1..g_tab_doc_header_id.last LOOP

 	                pa_funds_control_pkg.log_message(p_msg_token1 => '***Start of record-'||l_index||' records after fetching data from po_bc_distributions ***');
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_budget_version_id = '||g_tab_budget_version_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_budget_line_id = '||g_tab_budget_line_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_budget_ccid = '||g_tab_budget_ccid(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_project_id = '||g_tab_project_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_task_id = '||g_tab_task_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_exp_type = '||g_tab_exp_type(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_exp_org_id = '||g_tab_exp_org_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_je_source_name = '||g_tab_je_source_name(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_je_category_name = '||g_tab_je_category_name(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_doc_type = '||g_tab_doc_type(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_doc_header_id = '||g_tab_doc_header_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_doc_line_id = '||g_tab_doc_line_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_doc_distribution_id = '||g_tab_doc_distribution_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_actual_flag = '||g_tab_actual_flag(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_result_code = '||g_tab_result_code(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_status_code = '||g_tab_status_code(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_entered_amount = '||g_tab_entered_amount(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_accted_amount = '||g_tab_accted_amount(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_balance_posted_flag = '||g_tab_balance_posted_flag(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_funds_process_mode = '||g_tab_funds_process_mode(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_burden_cost_flag = '||g_tab_burden_cost_flag(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_pkt_reference1 = '||g_tab_pkt_reference1(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_pkt_reference2 = '||g_tab_pkt_reference2(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_pkt_reference3 = '||g_tab_pkt_reference3(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_event_id = '||g_tab_event_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_burden_method_code = '||g_tab_burden_method_code(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_main_or_backing_code = '||g_tab_main_or_backing_code(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_source_event_id = '||g_tab_source_event_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_trxn_ccid = '||g_tab_trxn_ccid(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_p_bc_packet_id = '||g_tab_p_bc_packet_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_fck_reqd_flag = '||g_tab_fck_reqd_flag(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_gl_date = '||g_tab_gl_date(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_distribution_type = '||g_tab_distribution_type(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_po_release_id = '||g_tab_po_release_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_enc_type_id = '||g_tab_enc_type_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_period_name = '||g_tab_period_name(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_set_of_books_id = '||g_tab_set_of_books_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_exp_item_date = '||g_tab_exp_item_date(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_org_id = '||g_tab_org_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_vendor_id = '||g_tab_vendor_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_orig_sequence_num = '||g_tab_orig_sequence_num(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_applied_to_dist_id_2 = '||g_tab_applied_to_dist_id_2(l_index));
                        pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_bc_packet_id = '||g_tab_bc_packet_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => '****End of record-'||l_index||' records after fetching data from po_bc_distributions***');
  		      END LOOP;

        	 End if;

		-- Code to fetch Vendor_id and Org_id for PO/REQ records
		IF g_tab_set_of_books_id.count <> 0 THEN

                   l_old_req_line_id  := 0;
		   l_req_vendor_id    := 0;
		   l_req_org_id       := 0;

                   l_old_po_header_id := 0;
		   l_po_vendor_id     := 0;
		   l_po_org_id        := 0;

                   IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
                      pa_funds_control_pkg.log_message(p_msg_token1 => 'Calling DERIVE_DR_CR ');
                   End if;

		   DERIVE_DR_CR;

		   FOR l_index IN 1..g_tab_set_of_books_id.Last LOOP

                    IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Inside LOOP - document type = '||g_tab_doc_type(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Inside LOOP - distribution Id = '||g_tab_doc_distribution_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Inside LOOP - Entered Dr = '||g_tab_entered_dr(l_index));
	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Inside LOOP - Entered Cr = '||g_tab_entered_cr(l_index));
        	    End if;

		    -- Code to populate budget_version_id
                    g_tab_budget_version_id(l_index)
			                 := pa_funds_control_utils2.GET_DRAFTORBASELINE_BDGTVER
                                                                     (g_tab_project_id(l_index),'GL','BASELINE');
                    If (g_tab_budget_version_id(l_index) is NULL ) Then
                           IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
	                        pa_funds_control_pkg.log_message(p_msg_token1 => 'Budget derivation failed marking to F166 ');
        	           End if;
                           g_tab_result_code(l_index)   := 'F166';
                           g_tab_status_code(l_index)   := 'R';
                           g_tab_fck_reqd_flag(l_index) := 'Y';
                           g_tab_budget_version_id(l_index) := NVL(pa_funds_control_utils2.GET_DRAFTORBASELINE_BDGTVER
                                                (g_tab_project_id(l_index),'GL','DRAFT'),-9999);

                           GOTO END_OF_REQ_LOOP;

                    End If; --If (g_tab_budget_version_id(l_index) is NULL ) Then
		    --End of code to populate budget_version_id

                   IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Budget Version Id derived = '||g_tab_budget_version_id(l_index));
        	   End if;

                    IF g_tab_doc_type(l_index) ='REQ' THEN

			 -- Code to populate vendor_id and org_id

                         IF l_old_req_line_id <> g_tab_doc_line_id(l_index) THEN

	  	            OPEN cur_req_vend_org_details(g_tab_doc_line_id(l_index));
		            FETCH cur_req_vend_org_details INTO
			                 l_req_vendor_id,
					 l_req_org_id;
                            CLOSE cur_req_vend_org_details;
                            l_old_req_line_id := g_tab_doc_line_id(l_index);

                            IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
	                       pa_funds_control_pkg.log_message(p_msg_token1 => 'Vendor detials : l_req_vendor_id  = '||l_req_vendor_id||' l_req_org_id = '||l_req_org_id);
        	            End if;

                         END IF; --IF l_old_req_line_id <> g_tab_doc_line_id(l_index) THEN

                         g_tab_vendor_id(l_index) := l_req_vendor_id;
			 g_tab_org_id(l_index) := l_req_org_id ;

			 -- End of Code to populate vendor_id and org_id

                         IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
	                   pa_funds_control_pkg.log_message(p_msg_token1 => 'main_or_backing_code = '||g_tab_main_or_backing_code(l_index));
           	         End if;

			 -- Code to populate information for backing requisition
		         IF g_tab_main_or_backing_code(l_index) = 'B_REQ' THEN

			   IF is_req_based_po   (p_req_distribution_id => g_tab_doc_distribution_id(l_index),
						 p_req_header_id => g_tab_doc_header_id(l_index),
						 p_req_prevent_enc_flipped => PO_DOCUMENT_FUNDS_PVT.is_req_enc_flipped
						                              (g_tab_doc_distribution_id(l_index),g_tab_source_event_id(l_index)),
						 x_result_code => g_tab_result_code(l_index),
						 x_status_code => g_tab_status_code(l_index),
						 x_reference1  => g_tab_pkt_reference1(l_index),
						 x_reference2  => g_tab_pkt_reference2(l_index),
						 x_reference3  => g_tab_pkt_reference3(l_index)
						) = 'Y' then
				g_tab_p_bc_packet_id(l_index)  := -1;
		           END IF;
                         END IF;
			 -- End of Code to populate information for backing requisition

                    ELSIF g_tab_doc_type(l_index) ='PO' THEN

			 -- Code to populate vendor_id and org_id
                         IF l_old_po_header_id <> g_tab_doc_header_id(l_index) THEN

	  	            OPEN cur_po_vend_org_details(g_tab_doc_header_id(l_index));
		            FETCH cur_po_vend_org_details INTO
			                 l_po_vendor_id,
					 l_po_org_id;
                            CLOSE cur_po_vend_org_details;
                            l_old_po_header_id := g_tab_doc_header_id(l_index);

                            IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
	                       pa_funds_control_pkg.log_message(p_msg_token1 => 'Vendor detials : l_po_vendor_id  = '||l_po_vendor_id||' l_po_org_id = '||l_po_org_id);
        	            End if;

                         END IF; --IF l_old_po_header_id <> g_tab_doc_header_id(l_index) THEN

                         g_tab_vendor_id(l_index) := l_po_vendor_id;
			 g_tab_org_id(l_index) := l_po_org_id ;

			 -- End of Code to populate vendor_id and org_id

                    END IF; --IF g_pa_bc_packets_tab(l_index).document_type ='REQ' THEN

		   -- Bug 5403775 : Below logic derives reference columns on backing documents such that
		   -- they will point to main document
		   -- Eg :
		   -- a. for autocreated PO , PO record will have reference column mapping to
		   -- itself and the B_REQ record will have reference columns mapping to PO .
		   -- b. for release matched to PO, Release will have reference column mapping to
		   -- itself and the B_PO record will have reference columns mapping to Release .

		    IF g_tab_main_or_backing_code(l_index) <> 'M' AND NVL(g_tab_orig_sequence_num(l_index),0) <> 0 THEN

         		OPEN cur_po_main_doc_details(g_tab_source_event_id(l_index),g_tab_orig_sequence_num(l_index));
			FETCH cur_po_main_doc_details INTO g_tab_pkt_reference1(l_index),g_tab_pkt_reference2(l_index);
			CLOSE cur_po_main_doc_details;

			g_tab_pkt_reference3(l_index) := g_tab_applied_to_dist_id_2(l_index);

                    END IF;

	          <<END_OF_REQ_LOOP>>
		  NULL;
                  END LOOP;

              END IF; --IF g_tab_set_of_books_id.count <> 0 THEN

              IF pa_funds_control_pkg.g_debug_mode = 'Y' AND g_tab_doc_header_id.count<>0  THEN

  		      FOR l_index IN 1..g_tab_doc_header_id.last LOOP

 	                pa_funds_control_pkg.log_message(p_msg_token1 => '***Start of record-'||l_index||' records after firing PO fetching logic ***');
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_budget_version_id = '||g_tab_budget_version_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_budget_line_id = '||g_tab_budget_line_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_budget_ccid = '||g_tab_budget_ccid(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_project_id = '||g_tab_project_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_task_id = '||g_tab_task_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_exp_type = '||g_tab_exp_type(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_exp_org_id = '||g_tab_exp_org_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_je_source_name = '||g_tab_je_source_name(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_je_category_name = '||g_tab_je_category_name(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_doc_type = '||g_tab_doc_type(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_doc_header_id = '||g_tab_doc_header_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_doc_line_id = '||g_tab_doc_line_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_doc_distribution_id = '||g_tab_doc_distribution_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_actual_flag = '||g_tab_actual_flag(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_result_code = '||g_tab_result_code(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_status_code = '||g_tab_status_code(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_entered_amount = '||g_tab_entered_amount(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_accted_amount = '||g_tab_accted_amount(l_index));
                        pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_entered_dr = '||g_tab_entered_dr(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_entered_cr = '||g_tab_entered_cr(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_accounted_dr = '||g_tab_accounted_dr(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_accounted_cr = '||g_tab_accounted_cr(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_balance_posted_flag = '||g_tab_balance_posted_flag(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_funds_process_mode = '||g_tab_funds_process_mode(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_burden_cost_flag = '||g_tab_burden_cost_flag(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_pkt_reference1 = '||g_tab_pkt_reference1(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_pkt_reference2 = '||g_tab_pkt_reference2(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_pkt_reference3 = '||g_tab_pkt_reference3(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_event_id = '||g_tab_event_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_burden_method_code = '||g_tab_burden_method_code(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_main_or_backing_code = '||g_tab_main_or_backing_code(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_source_event_id = '||g_tab_source_event_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_trxn_ccid = '||g_tab_trxn_ccid(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_p_bc_packet_id = '||g_tab_p_bc_packet_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_fck_reqd_flag = '||g_tab_fck_reqd_flag(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_gl_date = '||g_tab_gl_date(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_distribution_type = '||g_tab_distribution_type(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_po_release_id = '||g_tab_po_release_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_enc_type_id = '||g_tab_enc_type_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_period_name = '||g_tab_period_name(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_set_of_books_id = '||g_tab_set_of_books_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_exp_item_date = '||g_tab_exp_item_date(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_org_id = '||g_tab_org_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_vendor_id = '||g_tab_vendor_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_orig_sequence_num = '||g_tab_orig_sequence_num(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_applied_to_dist_id_2 = '||g_tab_applied_to_dist_id_2(l_index));
                        pa_funds_control_pkg.log_message(p_msg_token1 => 'Value of g_tab_bc_packet_id = '||g_tab_bc_packet_id(l_index));
 	                pa_funds_control_pkg.log_message(p_msg_token1 => '****End of record-'||l_index||' records after firing PO fetching logic***');
  		      END LOOP;

        	End if;

        END IF; --IF p_application_id = 201 THEN

	IF g_tab_set_of_books_id.count <> 0 THEN

		SELECT gl_bc_packets_s.nextval
		INTO l_packet_id
		FROM dual;

                IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
	           pa_funds_control_pkg.log_message(p_msg_token1 => 'l_packet_id = '||l_packet_id);
                End if;

/* Commented for Bug 5726535
               -- Updating dangling records created in previous run to 'T' status
               FAIL_DANGLING_PKTS(l_packet_id);

                IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
	           pa_funds_control_pkg.log_message(p_msg_token1 => 'Updated I status records created in last run to T status '||SQL%ROWCOUNT);
	           pa_funds_control_pkg.log_message(p_msg_token1 => 'Calling Load_pkts ');
                End if;
*/

	        Load_pkts(l_packet_id,p_bc_mode); -- to create bc records in autonomous mode;

                IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
	           pa_funds_control_pkg.log_message(p_msg_token1 => 'Calling update_cwk_pkt_lines ');
                End if;

		-- To update CWK related columns of pa_bc_packets PO records
		update_cwk_pkt_lines (p_calling_module   => 'GL',
				      p_packet_id        =>  l_packet_id);

                IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
	           pa_funds_control_pkg.log_message(p_msg_token1 => 'Calling Populate_burden_cost');
                End if;

		Populate_burden_cost
			(p_packet_id            => l_packet_id
			,p_calling_module       => 'GL'
			,x_return_status        => l_return_status
			,x_err_msg_code         => l_err_msg_code);

                IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
	           pa_funds_control_pkg.log_message(p_msg_token1 => 'After Populate_burden_cost l_return_status ='||l_return_status);
	           pa_funds_control_pkg.log_message(p_msg_token1 => 'After Populate_burden_cost l_err_msg_code ='||l_err_msg_code);
	           pa_funds_control_pkg.log_message(p_msg_token1 => 'Calling DERIVE_PKT_RLMI_BUDGET_CCID ');
                End if;

		-- Add code to handle exceptions

		DERIVE_PKT_RLMI_BUDGET_CCID(p_packet_id => l_packet_id,
                                            p_bc_mode   => p_bc_mode);

                -- When there is a failure in PA processing in full mode,
		-- then do not call create_events and return a failure status
		-- back to the calling program.

                IF p_partial_flag = 'N' THEN
                   FULL_MODE_FAILURE (p_packet_id   => l_packet_id,
                                      p_bc_mode     => p_bc_mode,
                                      x_return_code => x_return_code);
	        ELSE

		   OPEN c_count_success_recs(l_packet_id);
		   FETCH c_count_success_recs INTO l_count_success_rec;
		   CLOSE c_count_success_recs;

		   IF l_count_success_rec = 0 THEN
		      IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
                         pa_funds_control_pkg.log_message(p_msg_token1 => 'In partial mode returning F status as all records have failed insert validation');
                      End if;
                      x_return_code := 'F';
		   END IF;

                END IF;

	        IF x_return_code <> 'F' THEN

                  -------->6599207 ------As part of CC Enhancements -- Imposed the if condition.
		  IF p_application_id <> 8407 THEN

                   IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
                      pa_funds_control_pkg.log_message(p_msg_token1 => 'Calling pa_xla_interface_pkg.create_events ');
                   End if;

		   pa_xla_interface_pkg.create_events(p_calling_module  => 'FUNDS_CHECK',
		               			      p_data_set_id     => l_packet_id,
						      x_result_code     => l_return_status);

                   IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
	              pa_funds_control_pkg.log_message(p_msg_token1 => 'After pa_xla_interface_pkg.create_events l_return_status ='||l_return_status);
                   End if;

                   --Failing records with null bc_event_id
                   FAIL_NULL_EVENT_PKTS (l_packet_id,p_bc_mode);

                  END IF;
		  -------->6599207 ------END

                   IF p_partial_flag = 'N' THEN
                      FULL_MODE_FAILURE (p_packet_id   => l_packet_id,
                                         p_bc_mode     => p_bc_mode,
                                         x_return_code => x_return_code);
	           ELSE

		      OPEN c_count_success_recs(l_packet_id);
		      FETCH c_count_success_recs INTO l_count_success_rec;
		      CLOSE c_count_success_recs;

		      IF l_count_success_rec = 0 THEN
		         IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
                            pa_funds_control_pkg.log_message(p_msg_token1 => 'In partial mode returning F status as all records have failed insert validation');
                         End if;
                         x_return_code := 'F';
		      END IF;

                   END IF;

               END IF; --IF x_return_code <> 'F' THEN

	END IF; -- IF g_tab_set_of_books_id.count THEN

      END IF; -- IF p_application_id in (200, 201, 8407) THEN

        IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
            pa_funds_control_pkg.log_message(p_msg_token1 => 'CREATE_PROJ_ENCUMBRANCE_EVENTS : End ;Value of x_return_code '||x_return_code);
        End if;

 	RETURN;

EXCEPTION
	WHEN OTHERS THEN

                IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
                  pa_funds_control_pkg.log_message(p_msg_token1 => 'CREATE_PROJ_ENCUMBRANCE_EVENTS : EXCEPTION '||SQLERRM);
                End if;

                -- have to put proper result code
 		PA_FUNDS_CONTROL_PKG.result_status_code_update
			( p_status_code            => 'T',
             	      	p_result_code              => 'F09',
             		p_res_result_code          => 'F09',
             		p_res_grp_result_code      => 'F09',
             		p_task_result_code         => 'F09',
             		p_top_task_result_code     => 'F09',
             		p_project_result_code      => 'F09',
			p_proj_acct_result_code    => 'F09',
             		p_packet_id                => l_packet_id
  			);

		x_return_code := 'F';

		IF CUR_AP_BC_DIST%ISOPEN THEN
			CLOSE CUR_AP_BC_DIST;
		END IF;

		IF CUR_PO_BC_DIST%ISOPEN THEN
			CLOSE CUR_PO_BC_DIST;
		END IF;

		RAISE;

END CREATE_PROJ_ENCUMBRANCE_EVENTS;

----------------------------------------------------------------------------------
--This is an Autonmous api which inserts records into the pa bc packets from
-- plsql tables and commits
---------------------------------------------------------------------------------
PROCEDURE Load_pkts (p_packet_id IN NUMBER,
                     p_bc_mode   IN VARCHAR2,
		     p_calling_module IN VARCHAR2 DEFAULT NULL) IS

	PRAGMA AUTONOMOUS_TRANSACTION;
        l_request_id      NUMBER := fnd_global.conc_request_id();
        l_program_id      NUMBER := fnd_global.conc_program_id();
        l_program_application_id NUMBER:= fnd_global.prog_appl_id();
        l_update_login    NUMBER := FND_GLOBAL.login_id;
        l_num_rows        NUMBER := 0;
        l_return_status    VARCHAR2(1);

 BEGIN

        IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
            pa_funds_control_pkg.log_message(p_msg_token1 => 'LOAD_PKTS : Start ');
        End if;

        If l_request_id is null then
                l_request_id := -1;
        End if;

        if l_program_id is null then
                l_program_id := -1;
        End if;
        If l_program_application_id is null then
                l_program_application_id := -1;
        End if;

        If l_update_login is null then
                l_update_login := -1;
        End if;

	FORALL i in 1 .. g_tab_set_of_books_id.count
		INSERT INTO PA_BC_PACKETS (
                        request_id,
                        program_id,
                        program_application_id,
                        program_update_date,
                        last_update_date,
                        last_updated_by,
                        created_by,
                        creation_date,
                        last_update_login,
                        ------ main columns-----------
                        packet_id,
                        bc_packet_id,
                        budget_version_id,
                        project_id,
                        task_id,
                        expenditure_type,
                        expenditure_organization_id,
                        expenditure_item_date,
                        set_of_books_id,
                        je_source_name,
                        je_category_name,
                        document_type,
                        document_header_id,
                        document_distribution_id,
                        actual_flag,
                        result_code,
                        status_code,
                        entered_dr,
                        entered_cr,
                        accounted_dr,
                        accounted_cr,
                        balance_posted_flag,
                        funds_process_mode,
                        txn_ccid,
                        burden_cost_flag,
                        org_id,
			parent_bc_packet_id
			,document_line_id
			,reference1
			,reference2
			,reference3
			-- R12 Funds management Uptake : Newly added columns
			,bc_event_id
			,vendor_id
			,main_or_backing_code
			,burden_method_code
			,budget_line_id
			,source_event_id
			,ext_bdgt_flag
			,gl_date
			,period_name
			,document_distribution_type
			,DOCUMENT_HEADER_ID_2
			,encumbrance_type_id
			,proj_encumbrance_type_id
			)
                SELECT
                        l_request_id,
                        l_program_id,
                        l_program_application_id,
                        sysdate,
                        sysdate,
                        l_update_login,
                        l_update_login,
                        sysdate,
                        l_update_login,
                        p_packet_id,
                        g_tab_bc_packet_id(i), -- Bug 5406690
                        g_tab_budget_version_id(i),
                        g_tab_project_id(i),
                        g_tab_task_id(i),
                        g_tab_exp_type(i),
                        g_tab_exp_org_id(i),
                        g_tab_exp_item_date(i),
			g_tab_set_of_books_id(i),
			g_tab_je_source_name(i),
			g_tab_je_category_name(i),
			g_tab_doc_type(i),
			g_tab_doc_header_id(i),
			g_tab_doc_distribution_id(i),
			g_tab_actual_flag(i),
			g_tab_result_code(i),
			g_tab_status_code(i),
                        NVL(pa_currency.round_trans_currency_amt(g_tab_entered_dr(i),g_acct_currency_code),0),
                        NVL(pa_currency.round_trans_currency_amt(g_tab_entered_cr(i),g_acct_currency_code),0),
                        NVL(pa_currency.round_trans_currency_amt(g_tab_accounted_dr(i),g_acct_currency_code),0),
                        NVL(pa_currency.round_trans_currency_amt(g_tab_accounted_cr(i),g_acct_currency_code),0),
			g_tab_balance_posted_flag(i),
			g_tab_funds_process_mode(i),
			g_tab_trxn_ccid(i),
			g_tab_burden_cost_flag(i),
			g_tab_org_id(i),
                        g_tab_p_bc_packet_id(i),
			g_tab_doc_line_id(i),
			g_tab_pkt_reference1(i),
			g_tab_pkt_reference2(i),
			g_tab_pkt_reference3(i),
			g_tab_event_id(i),
			g_tab_vendor_id(i),
			g_tab_main_or_backing_code(i),
			g_tab_burden_method_code(i),
                        g_tab_budget_line_id(i),
			g_tab_source_event_id(i),
			PA_FUNDS_CONTROL_UTILS.get_bdgt_link(g_tab_project_id(i),'STD' ),
                        g_tab_gl_date(i),
			g_tab_period_name(i),
                     	g_tab_distribution_type(i),
			DECODE(g_tab_doc_type(i),'PO',g_tab_po_release_id(i),NULL),
			g_tab_enc_type_id(i),
			PA_FUNDS_CONTROL_UTILS.get_encum_type_id(g_tab_project_id(i),'STD')
		FROM
			dual
		WHERE   g_tab_fck_reqd_flag(i) in ('R','Y')
			-- fck_reqd_flag R - year end rollover
		AND     ( nvl(g_tab_status_code(i),'P') <> 'V'
			 and nvl(g_tab_result_code(i),'P') <> 'P113'
		        );


        /* Added for Bug fix: 3086398 */
	Update pa_bc_packets
           set status_code              = DECODE(status_code,'F',status_code,'R',status_code,'T',status_code,DECODE(p_bc_mode,'C','F','R')),
	       res_result_code          = DECODE(substr(res_result_code,1,1),'F',res_result_code,result_code),
               res_grp_result_code      = DECODE(substr(res_grp_result_code,1,1),'F',res_grp_result_code,result_code),
               task_result_code         = DECODE(substr(task_result_code,1,1),'F',task_result_code,result_code),
               top_task_result_code     = DECODE(substr(top_task_result_code,1,1),'F',top_task_result_code,result_code),
               project_result_code      = DECODE(substr(project_result_code,1,1),'F',project_result_code,result_code),
               project_acct_result_code = DECODE(substr(project_acct_result_code,1,1),'F',project_acct_result_code,result_code)
        Where packet_id = p_packet_id
        AND   SUBSTR(result_code,1,1) = 'F'
        ANd   status_code = 'I';

        IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
            pa_funds_control_pkg.log_message(p_msg_token1 => 'NUmber of records updated to Failed status ='||SQL%ROWCOUNT);
        End if;

        -------->6599207 ------As part of CC Enhancements
	---- Updating the ROWID on reference column so as to use
	---- the same while creating liquidation entries in IGC interface table.

	IF p_calling_module = 'CBC' THEN
	FORALL I in 1..g_tab_rowid.count
	Update pa_bc_packets set gl_row_number = g_tab_rowid(i)
	where bc_packet_id = g_tab_bc_packet_id (i); END IF;

        -------->6599207 ------END

        /* End of bug fix :3086398 */

	commit;

        IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
            pa_funds_control_pkg.log_message(p_msg_token1 => 'LOAD_PKTS : End ');
        End if;

EXCEPTION
WHEN OTHERS THEN
        IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
            pa_funds_control_pkg.log_message(p_msg_token1 => 'LOAD_PKTS : Exception '||SQLERRM);
        End if;

	RAISE;

END Load_pkts;

-------->6599207 ------As part of CC Enhancements
PROCEDURE assign_plsql_tabs(p_counter IN NUMBER,
                            p_fck_reqd_flag  varchar2 default null);
-------->6599207 ------END


-----------------------------------------------------------------------------
--This is the main api which derives the project attributes such as
-- project id, task id, exp item date, exp type, exp org for the
-- transaction entered in gl bc packets or igc interface table
-- R12 funds management uptake : renamed create_pkt_lines to update_cwk_pkt_lines
-- as with r12 this is used to only process and update CWK related PO records
----------------------------------------------------------------------------
PROCEDURE update_cwk_pkt_lines(p_calling_module   IN varchar2 ,
                               p_packet_id        IN NUMBER) IS

	l_counter   NUMBER := 0;
	l_doc_type  varchar2(100);
	l_doc_dist_id  number;
	l_doc_header_id number;
	l_period_name   varchar2(100);
	l_bc_commitment_id   number;
	l_return_status  varchar2(1000);
        l_project_id            number;
        l_task_id               number;
        l_exp_type              varchar2(50);
        l_exp_item_date         date;
        l_exp_org_id            number;
        l_fck_reqd_flag         varchar2(10);
	l_gl_amt_flag 		varchar2(10);
	l_result_code		varchar2(10);
	l_status_code		varchar2(10);
	l_pkt_reference1        varchar2(100);
        l_pkt_reference2        varchar2(100);
        l_pkt_reference3        varchar2(100);
        /* Bug 3703180 **/
        l_doc_line_id_tab        pa_plsql_datatypes.IdTabTyp;
	l_po_header_id_tab       pa_plsql_datatypes.IdTabTyp ;
	l_po_distribution_id_tab pa_plsql_datatypes.IdTabTyp ;
	l_bc_packet_id_tab       pa_plsql_datatypes.IdTabTyp ;
	l_raw_amount_tab         pa_plsql_datatypes.NumTabTyp ;
	l_amt_balance_tab        pa_plsql_datatypes.NumTabTyp;
	l_entered_dr_tab        pa_plsql_datatypes.NumTabTyp;
	l_entered_cr_tab        pa_plsql_datatypes.NumTabTyp;
	l_accounted_dr_tab        pa_plsql_datatypes.NumTabTyp;
	l_accounted_cr_tab        pa_plsql_datatypes.NumTabTyp;
	l_cr_amount               number ;
        l_burd_exists_flag         VARCHAR2(1); --Bug 3749551

        -- R12 Funds management uptake: commented CBC related code

        /* Bug 3703180 **/
	CURSOR is_cwk_po_unreserve is
	  select distinct pbc.document_header_id,
	                  pbc.document_line_id,
			  org_id
            from pa_bc_packets pbc
           where packet_id     = p_packet_id
	     and document_type = 'PO'
	     and (nvl(accounted_dr,0) - nvl(accounted_cr,0)) < 0
	     and not exists ( select 1
                                from pa_bc_packets
                               where packet_id     = p_packet_id
	                         and document_type <> 'PO') ;

       PROCEDURE Rate_PO_Unreserve( p_packet_id        number,
                                    p_bc_packet_id_tab pa_plsql_datatypes.IdTabTyp,
                                    p_entered_cr_tab   pa_plsql_datatypes.NumTabTyp,
                                    p_accounted_cr_tab pa_plsql_datatypes.NumTabTyp) is
	PRAGMA AUTONOMOUS_TRANSACTION;
        begin
	     FORALL i IN p_bc_packet_id_tab.first .. p_bc_packet_id_tab.last
	        update pa_bc_packets
		       set entered_cr   = p_entered_cr_tab(i),
		           accounted_cr = p_accounted_cr_tab(i),
			   entered_dr   = 0,
			   accounted_dr = 0
                 where packet_id    = p_packet_id
		   and bc_packet_id = p_bc_packet_id_tab(i) ;

             commit ;
        end Rate_PO_Unreserve ;

BEGIN

        -- R12 Funds management uptake: commented CBC related code

        /**** 3703180 ***/
	/*
	/* Issue : CWK PO was created for a project and using a web adi timecard was brought in
	**         as actuals. In this case po receipt is not created and po cancellation
	**         would liquidate without considering the cwk timecards. This is resulting
	**         into -ve balance.
	** Resolution :
	**         We are finding out the summary amounts from pa bc packets or bc commitments
	**         for a po line. Summary record has total raw amount and total amout relieved
	**         we are checking if the po credit is creted in bc packets and comparing the
	**         credit amount with the po balance at line level in the summary record.
	**         BC packet record is updated with the amount ( whichever is less credit amount or
	**         summary balance ) for a project, task and a po line.
	** ***************************************************************************************/
	g_cwk_po_unreserve := 'N' ;
        FOR c_rate_po in is_cwk_po_unreserve LOOP

	   IF pa_funds_control_utils2.is_cwk_po(c_rate_po.document_header_id,
                                                c_rate_po.document_line_id,
                                                NULL,
                                                c_rate_po.org_id) = 'Y' THEN
		g_project_id_tab.delete ;
		g_task_id_tab.delete ;
		l_raw_amount_tab.delete ;
		l_amt_balance_tab.delete ;
		g_doc_line_id_tab.delete ;
		g_bdamt_balance_tab.delete ;
		g_burden_type_tab.delete ;

		g_cwk_po_unreserve := 'Y' ;
                /*
		** 3703180 : Determine the summary record amounts.. for a line
		*/
		select distinct pbc.project_id,
				pbc.task_id,
				(nvl(pbc.comm_tot_raw_amt,0) - nvl(pbc.comm_raw_amt_relieved,0)) amount,
				(nvl(pbc.comm_tot_bd_amt,0)  - nvl(pbc.comm_bd_amt_relieved,0) ) bd_amount,
				pbc.document_line_id,
                                decode(NVL(ppt.burden_cost_flag, 'N'),
                                           'Y',
                                           decode(NVL(ppt.burden_amt_display_method,'S'), 'S','SAME','D','DIFFERENT'),'NONE')
                  bulk collect into g_project_id_tab,
		                    g_task_id_tab,
				    l_amt_balance_tab,
				    g_bdamt_balance_tab,
				    g_doc_line_id_tab,
                                    g_burden_type_tab
		  from pa_bc_packets     pbc ,
		       pa_projects_all   pp,
		       pa_project_types  ppt
		 where pbc.document_type       = 'PO'
		   and pbc.summary_record_flag = 'Y'
		   and pbc.document_line_id    = c_rate_po.document_line_id
		   and pbc.document_header_id  = c_rate_po.document_header_id
		   and pbc.status_code         in ('A', 'C')
		   and pbc.parent_bc_packet_id is NULL
		   and pbc.project_id          = pp.project_id
		   and pp.project_type         = ppt.project_type
		   and (pbc.project_id, task_id)  in  ( select distinct project_id, task_id
		                                          from pa_bc_packets
                                                         where packet_id           = p_packet_id
							   and document_header_id  = c_rate_po.document_header_id
							   and document_line_id    = c_rate_po.document_line_id )
		   and pbc.packet_id           < p_packet_id ;

		 IF g_project_id_tab.count = 0 THEN
			select distinct pbc.project_id,
					pbc.task_id,
					(nvl(pbc.comm_tot_raw_amt,0) - nvl(pbc.comm_raw_amt_relieved,0)) amount,
				        (nvl(pbc.comm_tot_bd_amt,0)  - nvl(pbc.comm_bd_amt_relieved,0) ) bd_amount,
					pbc.document_line_id,
                                        decode(NVL(ppt.burden_cost_flag, 'N'),
                                           'Y',
                                           decode(NVL(ppt.burden_amt_display_method,'S'), 'S','SAME','D','DIFFERENT'),'NONE')
                          bulk collect into g_project_id_tab,
		                            g_task_id_tab,
				            l_amt_balance_tab,
				            g_bdamt_balance_tab,
				            g_doc_line_id_tab,
					    g_burden_type_tab
			  from pa_bc_commitments pbc,
		               pa_projects_all   pp,
		               pa_project_types  ppt
			 where pbc.document_type       = 'PO'
			   and pbc.summary_record_flag = 'Y'
		           --and pbc.burden_cost_flag  = 'N'
		           and pbc.parent_bc_packet_id is NULL
			   and pbc.document_line_id    = c_rate_po.document_line_id
		           and pbc.document_header_id  = c_rate_po.document_header_id
		           and pbc.project_id          = pp.project_id
		           and pp.project_type         = ppt.project_type
		           and (pbc.project_id, pbc.task_id)  in  ( select distinct project_id, task_id
		                                                      from pa_bc_packets
                                                                     where packet_id           = p_packet_id
								       and document_header_id  = c_rate_po.document_header_id
							               and document_line_id    = c_rate_po.document_line_id )
			   and pbc.packet_id           < p_packet_id ;

		 END IF ;


		 IF g_project_id_tab.count > 0 THEN
		    for line_indx in 1..g_project_id_tab.count LOOP

		         l_bc_packet_id_tab.delete ;
			 l_entered_dr_tab.delete ;
			 l_entered_cr_tab.delete ;
			 l_accounted_dr_tab.delete ;
			 l_accounted_cr_tab.delete ;

			/*
			** 3703180 : fetch bc packet records for a project, task and po line.
			*/
			 select bc_packet_id,
				entered_dr,
				entered_cr,
				accounted_dr,
				accounted_cr
                           bulk collect into  l_bc_packet_id_tab,
			                      l_entered_dr_tab,
					      l_entered_cr_tab,
					      l_accounted_dr_tab,
					      l_accounted_cr_tab
			   from pa_bc_packets
			  where packet_id          = p_packet_id
			    and document_line_id   = g_doc_line_id_tab(line_indx)
			    and document_header_id = c_rate_po.document_header_id
			    and project_id         = g_project_id_tab(line_indx)
			    and task_id            = g_task_id_tab(line_indx) ;

			/*
			** 3703180 : Determine the credit amounts for a bc packets based on the summary
			**           record amount relieved and balance amount.
			*/
                          IF l_bc_packet_id_tab.count > 0 THEN

			     for pkt_rec in 1..l_bc_packet_id_tab.count loop

			       l_cr_amount := nvl(l_accounted_dr_tab(pkt_rec), 0) - nvl(l_accounted_cr_tab(pkt_rec),0) ;
			       --
			       -- Make sure signs are correct so that accounted_cr can be populated with the correct signs.
			       --
			       l_cr_amount := -1 * nvl(l_cr_amount,0) ;

			       if l_amt_balance_tab(line_indx) <= 0 then

				  l_entered_cr_tab(pkt_rec)   := 0 ;
				  l_entered_dr_tab(line_indx) := 0 ;

			       elsif l_cr_amount < l_amt_balance_tab(line_indx) then

				  l_amt_balance_tab(line_indx)  := l_amt_balance_tab(line_indx) - nvl(l_cr_amount,0) ;
				  l_entered_cr_tab(pkt_rec)     := l_cr_amount ;
				  l_accounted_cr_tab(pkt_rec)   := l_cr_amount ;

			       elsif l_cr_amount >= l_amt_balance_tab(line_indx) then
				  l_entered_cr_tab(pkt_rec)   := l_amt_balance_tab(line_indx) ;
				  l_accounted_cr_tab(pkt_rec) := l_amt_balance_tab(line_indx);
				  l_amt_balance_tab(line_indx)  := 0 ;
			       end if ;
			     end loop ;
			     /*
			     ** 3703180 : Update the bc packet with the correct credit amount.
			     */
                             rate_po_unreserve ( p_packet_id,
			                         l_bc_packet_id_tab,
                                                 l_entered_cr_tab,
                                                 l_accounted_cr_tab ) ;

			  end if ;
		    end loop ; -- Line level summary record
		 END IF ;  -- Summary record found.
	   END IF ; -- Rate Based PO end if.
       END LOOP ; -- End of PO credit cursor.
      /*
      ** 3703180 : End of Changes
      */

       -- This object will be obsolete
	If p_calling_module = 'GL' and g_doc_type = 'AP' then
		pa_funds_control_pkg.log_message(p_msg_token1 => 'check invoice is interfaced');
                PA_FUNDS_CONTROL_PKG.is_ap_from_project
                (p_packet_id        => p_packet_id,
                p_calling_module    => 'GL',
                x_return_status     => l_return_status);
        End if;



EXCEPTION

	when others then

                PA_FUNDS_CONTROL_PKG.log_message
                (p_msg_token1 => 'failed in create bc pkt lines SQLERR :'||sqlcode||sqlerrm);
		Raise;

END update_cwk_pkt_lines;

------------------------------------------------------------------------------
--/* This procedure creates burden transaction for the calling module
-- * distribute Expense report and Transaction Import programs
-- * this api uses the two Insert into select based on the project
-- * type which is of burden on same ei or burden on different ei
-- * the following api is created for the performance issue
-- */
------------------------------------------------------------------------------
PROCEDURE trxn_dister_burden_lines
          (p_packet_id  IN number,
	   p_calling_module  IN varchar2,
	   p_mode       IN varchar2 default 'R' )  IS

	 PRAGMA AUTONOMOUS_TRANSACTION;

        l_request_id      NUMBER := fnd_global.conc_request_id();
        l_program_id      NUMBER := fnd_global.conc_program_id();
        l_program_application_id NUMBER := fnd_global.prog_appl_id();
        l_update_login    NUMBER := NVL(FND_GLOBAL.login_id,-1);
        l_userid          NUMBER := NVL(fnd_global.user_id,-1);
	l_return_status   Varchar2(1000);


BEGIN

	If p_calling_module in ('DISTBTC','TRXNIMPORT','DISTVIADJ','DISTERADJ','TRXIMPORT','DISTCWKST')
	     AND p_mode not in ('A','U') then

		/* PA.M changes for contingent worker functionality */
		/* This check is not required as this is done even before inserting the record into pa_bc_packets
		 * during distribute process. Having this check is redudant
		If p_calling_module = 'DISTCWKST' then
			pa_funds_control_pkg.log_message(p_msg_token1 => 'Calling checkCWKbdExp Api to check burden cost codes');
			-- check for the burden cost codes changed if so error out the transactions
			checkCWKbdExp(p_packet_id  => p_packet_id
                        	,p_calling_module  => p_calling_module
                        	,x_return_status   => l_return_status
                        	);
			pa_funds_control_pkg.log_message(p_msg_token1 => 'End of checkCWKbdExp Api');
		End If;
	       ***/
                                /* This Query insert records into pa_bc_packets
                                 * for the projects which is of burden on same
                                 * expenditure item
                                 */

                                INSERT INTO pa_bc_packets
                                        ( ---- who columns------
                                        request_id,
                                        program_id,
                                        program_application_id,
                                        program_update_date,
                                        last_update_date,
                                        last_updated_by,
                                        created_by,
                                        creation_date,
                                        last_update_login,
                                        ------ main columns-----------
                                        packet_id,
                                        bc_packet_id,
                                        budget_version_id,
                                        project_id,
                                        task_id,
                                        expenditure_type,
                                        expenditure_organization_id,
                                        expenditure_item_date,
                                        set_of_books_id,
                                        je_source_name,
                                        je_category_name,
                                        document_type,
                                        document_header_id,
                                        document_distribution_id,
                                        actual_flag,
                                        period_name,
                                        period_year,
                                        period_num,
                                        result_code,
                                        status_code,
                                        entered_dr,
                                        entered_cr,
                                        accounted_dr,
                                        accounted_cr,
                                        gl_row_number,    --gl_row_bc_packet_row_id
                                        balance_posted_flag,
                                        funds_process_mode,
                                        txn_ccid,
                                        parent_bc_packet_id,
                                        encumbrance_type_id,
                                        burden_cost_flag,
                                        org_id,
                                        gl_date,
                                        pa_date,
					document_line_id,
					compiled_multiplier,
					reference1,
					reference2,
					reference3,
					exp_item_id
                                        )
                                SELECT
                                        l_request_id,
                                        l_program_id,
                                        l_program_application_id,
                                        sysdate,
                                        sysdate,
                                        l_userid,
                                        l_userid,
                                        sysdate,
                                        l_update_login,
                                        ------ main columns-----------
                                        pbc.packet_id,
                                        pa_bc_packets_s.nextval,
                                        pbc.budget_version_id,
                                        pbc.project_id,
                                        pbc.task_id,
                                        pbc.expenditure_type,
                                        pbc.expenditure_organization_id,
                                        pbc.expenditure_item_date,
                                        pbc.set_of_books_id,
                                        pbc.je_source_name,
                                        pbc.je_category_name,
                                        pbc.document_type,
                                        pbc.document_header_id,
                                        pbc.document_distribution_id,
                                        pbc.actual_flag,
                                        --decode(pbc.document_type,'AP',(
                                        /** pagl period enhancement changes instead of passing pa date
                                            pass transaction date to derive the period name
                                        pa_funds_control_pkg1.get_period_name(pa_utils2.get_pa_date
                                          (pbc.expenditure_item_date,NULL,pbc.org_id),pbc.set_of_books_id),
                                                -- ),pbc.period_name),
                                        **/
					/** Bug fix:2905892 As per discussions with Barbara , Dinakar, Prithi
                                         *  for Transaction import process the period name is to derived
                                         * based on the orginal raw line for the burden transactions
                                         * so reverting back to changes made earlier
                                         *pa_funds_control_pkg1.get_period_name
                                         * (pbc.expenditure_item_date,pbc.set_of_books_id),**/
					pbc.period_name,
					/** End of bug fix: 2905892 ***/
                                        pbc.period_year,
                                        pbc.period_num,
                                        pbc.result_code,
                                        pbc.status_code,
                                        pa_currency.round_trans_currency_amt(
                                        DECODE ( NVL ( pbc.entered_dr, 0 ), 0, 0,
                                                (( NVL (pbc.entered_dr ,0) *
                                                NVL (pa_funds_control_utils.get_fc_compiled_multiplier
                                                        (  pbc.expenditure_organization_id,
                                                           pbc.task_id,
                                                          pbc.expenditure_item_date,
                                                           'C',
                                                          pbc.expenditure_type
                                                        ), 0)))),g_acct_currency_code),
                                        pa_currency.round_trans_currency_amt(
                                        DECODE ( NVL ( pbc.entered_cr, 0 ), 0, 0,
                                                (( NVL (pbc.entered_cr ,0) *
                                                NVL (pa_funds_control_utils.get_fc_compiled_multiplier
                                                        (  pbc.expenditure_organization_id,
                                                           pbc.task_id,
                                                          pbc.expenditure_item_date,
                                                           'C',
                                                           pbc.expenditure_type
                                                ), 0)))),g_acct_currency_code),
                                        pa_currency.round_trans_currency_amt(
                                        DECODE ( NVL ( pbc.accounted_dr, 0 ), 0, 0,
                                                (( NVL (pbc.accounted_dr ,0) *
                                                NVL (pa_funds_control_utils.get_fc_compiled_multiplier
                                                        (  pbc.expenditure_organization_id,
                                                           pbc.task_id,
                                                          pbc.expenditure_item_date,
                                                           'C',
                                                          pbc.expenditure_type
                                                        ), 0)))),g_acct_currency_code),
                                        pa_currency.round_trans_currency_amt(
                                        DECODE ( NVL ( pbc.accounted_cr, 0 ), 0, 0,
                                                (( NVL (pbc.accounted_cr ,0) *
                                                NVL (pa_funds_control_utils.get_fc_compiled_multiplier
                                                        (  pbc.expenditure_organization_id,
                                                           pbc.task_id,
                                                          pbc.expenditure_item_date,
                                                           'C',
                                                           pbc.expenditure_type
                                                ), 0)))),g_acct_currency_code),

                                        NULL,    --gl_row_bc_packet_row_id
                                        pbc.balance_posted_flag,
                                        pbc.funds_process_mode,
                                        pbc.txn_ccid,
                                        pbc.bc_packet_id,
                                        pbc.encumbrance_type_id,
                                        'O',
                                        pbc.org_id,
                                        pbc.gl_date,
                                        pbc.pa_date,
					pbc.document_line_id,
					pa_funds_control_utils.get_fc_compiled_multiplier
                                                        (  pbc.expenditure_organization_id,
                                                           pbc.task_id,
                                                           pbc.expenditure_item_date,
                                                           'C',
                                                          pbc.expenditure_type
                                                        )
				,pbc.reference1
				,pbc.reference2
				,pbc.reference3
				,pbc.exp_item_id
                                FROM pa_bc_packets pbc
                                WHERE  pbc.packet_id = p_packet_id
                                AND pbc.parent_bc_packet_id = -1
                                AND substr(nvl(pbc.result_code,'X'),1,1) <> 'F'
                                AND pa_funds_control_pkg.check_bdn_on_sep_item
                                        (pbc.project_id ) = 'S'
                                AND NVL (pa_funds_control_utils.get_fc_compiled_multiplier
                                                        (  pbc.expenditure_organization_id,
                                                           pbc.task_id,
                                                          pbc.expenditure_item_date,
                                                           'C',
                                                           pbc.expenditure_type
                                                ), 0) <> 0;

				pa_funds_control_pkg.log_message(p_msg_token1 =>
					'Num of records inserted ='||sql%rowcount);

				/* This Query insert records into pa_bc_packets
				 * for the projects which is of burden on different
				 * expenditure item
				 */

                                INSERT INTO pa_bc_packets
                                        ( ---- who columns------
                                        request_id,
                                        program_id,
                                        program_application_id,
                                        program_update_date,
                                        last_update_date,
                                        last_updated_by,
                                        created_by,
                                        creation_date,
                                        last_update_login,
                                        ------ main columns-----------
                                        packet_id,
                                        bc_packet_id,
                                        budget_version_id,
                                        project_id,
                                        task_id,
                                        expenditure_type,
                                        expenditure_organization_id,
                                        expenditure_item_date,
                                        set_of_books_id,
                                        je_source_name,
                                        je_category_name,
                                        document_type,
                                        document_header_id,
                                        document_distribution_id,
                                        actual_flag,
                                        period_name,
                                        period_year,
                                        period_num,
                                        result_code,
                                        status_code,
                                        entered_dr,
                                        entered_cr,
                                        accounted_dr,
                                        accounted_cr,
                                        gl_row_number,    --gl_row_bc_packet_row_id
                                        balance_posted_flag,
                                        funds_process_mode,
                                        txn_ccid,
                                        parent_bc_packet_id,
                                        encumbrance_type_id,
                                        burden_cost_flag,
                                        org_id,
                                        gl_date,
                                        pa_date,
					document_line_id,
					compiled_multiplier,
					reference1,
					reference2,
					reference3,
					exp_item_id
                                        )
                                SELECT
                                        l_request_id,
                                        l_program_id,
                                        l_program_application_id,
                                        sysdate,
                                        sysdate,
                                        l_userid,
                                        l_userid,
                                        sysdate,
                                        l_update_login,
                                        ------ main columns-----------
                                        pbc.packet_id,
                                        pa_bc_packets_s.nextval,
                                        pbc.budget_version_id,
                                        pbc.project_id,
                                        pbc.task_id,
                                        et.expenditure_type,
                                        pbc.expenditure_organization_id,
                                        pbc.expenditure_item_date,
                                        pbc.set_of_books_id,
                                        pbc.je_source_name,
                                        pbc.je_category_name,
                                        pbc.document_type,
                                        pbc.document_header_id,
                                        pbc.document_distribution_id,
                                        pbc.actual_flag,
                                        /** pagl period enhancement changes instead of passing pa date
                                            pass transaction date to derive the period name
                                        pa_funds_control_pkg1.get_period_name(pa_utils2.get_pa_date
                                          (pbc.expenditure_item_date,NULL,pbc.org_id),pbc.set_of_books_id),
                                        **/
                                        /** Bug fix:2905892 As per discussions with Barbara , Dinakar, Prithi
                                         *  for Transaction import process the period name is to derived
                                         * based on the orginal raw line for the burden transactions
                                         * so reverting back to changes made earlier
                                         *  pa_funds_control_pkg1.get_period_name
                                         * (pbc.expenditure_item_date,pbc.set_of_books_id), --pbc.period_name, **/
                                        pbc.period_name,
                                        /** End of bug fix: 2905892 **/
                                        pbc.period_year,
                                        pbc.period_num,
                                        pbc.result_code,
                                        pbc.status_code,
                                        pa_currency.round_trans_currency_amt(
                                        decode(nvl(pbc.entered_dr,0),0,0,(nvl(pbc.entered_dr,0)*
                                                cm.compiled_multiplier)),g_acct_currency_code),
                                        pa_currency.round_trans_currency_amt(
                                        decode(nvl(pbc.entered_cr,0),0,0,(nvl(pbc.entered_cr,0)*
                                                cm.compiled_multiplier)),g_acct_currency_code),
                                        pa_currency.round_trans_currency_amt(
                                        decode(nvl(pbc.accounted_dr,0),0,0,(nvl(pbc.accounted_dr,0)*
                                                cm.compiled_multiplier)),g_acct_currency_code),
                                        pa_currency.round_trans_currency_amt(
                                        decode(nvl(pbc.accounted_cr,0),0,0,(nvl(pbc.accounted_cr,0)*
                                                cm.compiled_multiplier)),g_acct_currency_code),
                                        NULL,    --gl_row_bc_packet_row_id
                                        pbc.balance_posted_flag,
                                        pbc.funds_process_mode,
                                        pbc.txn_ccid,
                                        pbc.bc_packet_id,
                                        pbc.encumbrance_type_id,
                                        'O',
                                        pbc.org_id,
                                        pbc.gl_date,
                                        pbc.pa_date,
					pbc.document_line_id,
					cm.compiled_multiplier,
					pbc.reference1,
					pbc.reference2,
					pbc.reference3,
					pbc.exp_item_id
                                FROM
                                        pa_ind_rate_sch_revisions irsr,
                                        pa_cost_bases cb,
                                        pa_expenditure_types et,
                                        pa_ind_cost_codes icc,
                                        pa_cost_base_exp_types cbet,
                                        pa_ind_rate_schedules_all_bg irs,
                                        pa_ind_compiled_sets ics,
                                        pa_compiled_multipliers cm,
                                        pa_bc_packets pbc
                                WHERE irsr.cost_plus_structure = cbet.cost_plus_structure
                                AND cb.cost_base = cbet.cost_base
                                AND cb.cost_base_type = cbet.cost_base_type
                                AND et.expenditure_type = icc.expenditure_type
                                AND icc.ind_cost_code = cm.ind_cost_code
                                AND cbet.cost_base = cm.cost_base
                                AND cbet.cost_base_type = 'INDIRECT COST'
                                AND cbet.expenditure_type = pbc.expenditure_type
                                AND irs.ind_rate_sch_id = irsr.ind_rate_sch_id
                                AND ics.ind_rate_sch_revision_id = irsr.ind_rate_sch_revision_id
                                AND ics.organization_id = pbc.expenditure_organization_id
                                AND ics.ind_compiled_set_id =
                                        pa_funds_control_utils.get_fc_compiled_set_id
                                          (pbc.task_id,
                                          pbc.expenditure_item_date,
                                          pbc.expenditure_organization_id,
                                          'C'
					  , 'COMPILE_SET_ID'
					  ,pbc.expenditure_type)  -- Added for burdening changes
				AND ics.cost_base = cb.cost_base -- Added for burdening changes
                                AND cm.ind_compiled_set_id = ics.ind_compiled_set_id
                                AND cm.compiled_multiplier <> 0
                                AND pbc.packet_id = p_packet_id
                                AND pbc.parent_bc_packet_id  = -1
                                AND substr(nvl(pbc.result_code,'X'),1,1) <> 'F'
				AND pa_funds_control_pkg.check_bdn_on_sep_item
					(pbc.project_id ) = 'D';

                                pa_funds_control_pkg.log_message(p_msg_token1 =>
                                        'Num of records inserted ='||sql%rowcount);


	End if;

	commit;
	return;

EXCEPTION

	WHEN OTHERS THEN
		RAISE;

END trxn_dister_burden_lines;

--
-- Bug : 3703180
-- PJ.M:B5:P1:QA:CWK: PAXBLRSL- -VE COMMITMENT CREATED WHEN PO CANCELLED AFTER
-- Resolution : Compare the burden cost calculated with the summary record in
-- pa_bc_packets /pa_bc_commitments_all. We are using the amounts in the summary
-- table if summary has amounts less than the calculated in pa bc packets.
-- If we have zero burden in pa bc packets then we use the entire amounts in
-- the summary record.
--
PROCEDURE update_cwk_po_burden(p_packet_id NUMBER ) is
	   PRAGMA AUTONOMOUS_TRANSACTION;

        /* Bug 3703180 **/
	l_project_id        NUMBER ;
	l_task_id           NUMBER ;
	l_doc_line_id       NUMBER ;
	l_bdamt_balance     NUMBER ;
	l_index             NUMBER ;
	l_cr_amount         NUMBER ;
	l_bc_packet_id_tab  pa_plsql_datatypes.IdTabTyp ;
	l_entered_dr_tab    pa_plsql_datatypes.NumTabTyp;
	l_entered_cr_tab    pa_plsql_datatypes.NumTabTyp;
	l_accounted_dr_tab  pa_plsql_datatypes.NumTabTyp;
	l_accounted_cr_tab  pa_plsql_datatypes.NumTabTyp;
	l_exp_type_tab      pa_plsql_datatypes.char50TabTyp;

BEGIN

    IF  g_project_id_tab.count > 0 THEN
        for line_indx in 1..g_project_id_tab.count LOOP

	    if g_burden_type_tab(line_indx) = 'SAME' then
	       l_bdamt_balance := g_bdamt_balance_tab(line_indx) ;
	       l_bc_packet_id_tab.delete ;
	       l_entered_dr_tab.delete ;
	       l_entered_cr_tab.delete ;
	       l_accounted_dr_tab.delete ;
	       l_accounted_cr_tab.delete ;

               /* Bug 3703180
	          spool the descending burden amounts in pl sql array.
	       **/
	       select bc_packet_id,
		      entered_dr,
		      entered_cr,
		      accounted_dr,
		      accounted_cr
		 bulk collect into  l_bc_packet_id_tab,
		                    l_entered_dr_tab,
				    l_entered_cr_tab,
				    l_accounted_dr_tab,
				    l_accounted_cr_tab
	         from pa_bc_packets
		where packet_id        = p_packet_id
		  and document_line_id = g_doc_line_id_tab(line_indx)
		  and project_id       = g_project_id_tab(line_indx)
		  and task_id          = g_task_id_tab(line_indx)
		  and parent_bc_packet_id is not NULL
		 order by abs(nvl(accounted_dr,0) - nvl(accounted_cr,0))  desc;

	       IF l_bc_packet_id_tab.count > 0 THEN
	       --
	       -- bug 3703180
	       -- compare the burden cost with the summary record and use the summary burden cost
	       -- if calculated burden is ZERO or less then the pa bc packets burden.
	       --

	          for pkt_rec in 1..l_bc_packet_id_tab.count loop

		      l_cr_amount := NVL(l_accounted_dr_tab(pkt_rec),0) - NVL(l_accounted_cr_tab(pkt_rec),0)  ;
		      -- Make sure signs are correct ...
		      l_cr_amount := -1 * NVL(l_cr_amount,0) ;

		      if l_bdamt_balance <= 0 then

			 l_entered_cr_tab(pkt_rec)   := 0 ;
			 l_accounted_cr_tab(pkt_rec) := 0 ;

		      elsif l_cr_amount <= l_bdamt_balance then

			    l_bdamt_balance             := l_bdamt_balance - l_cr_amount ;
			    l_entered_cr_tab(pkt_rec)   := l_cr_amount ;
			    l_accounted_cr_tab(pkt_rec) := l_cr_amount ;

		      elsif l_cr_amount > l_bdamt_balance then
		            l_entered_cr_tab(pkt_rec)   := l_bdamt_balance ;
			    l_accounted_cr_tab(pkt_rec) := l_bdamt_balance;
			    l_bdamt_balance             := 0 ;
		      end if ;
		      if l_cr_amount = 0 and l_bdamt_balance > 0 THEN
		         l_entered_cr_tab(pkt_rec)   := l_bdamt_balance ;
			 l_accounted_cr_tab(pkt_rec) := l_bdamt_balance;
			 l_bdamt_balance  := 0 ;
		      end if ;
	          end loop ;

	          --
	          -- BUG 3703180
	          -- Update the calculated burden cost to pa bc packets.
	          --
		  FORALL i IN l_bc_packet_id_tab.first .. l_bc_packet_id_tab.last
		       update pa_bc_packets
		          set entered_cr   = l_entered_cr_tab(i),
			      accounted_cr = l_accounted_cr_tab(i),
			      entered_dr   = 0,
			      accounted_dr = 0
			where packet_id    = p_packet_id
			  and bc_packet_id = l_bc_packet_id_tab(i) ;
	       END IF ; -- l_bc_packet_id_tab.count > 0

	    --
	    -- BUG 3703180
	    -- Different line burdening setup.
	    -- We determine the summary record from pa bc packets or pa bc commitments all table.
	    -- compare the summary amounts with the pa bc packets burden and use the one less than
	    -- the other. If pa bc packets burden cost is ZERO than we use the burden cost from the
	    -- summary table record.
	    --
	    elsif g_burden_type_tab(line_indx) = 'DIFFERENT' then

              l_exp_type_tab.delete ;

	      --
	      -- BUG 3703180
	      -- Determine the burden expenditure type from pa bc packets.
	      --
              select distinct pbc.expenditure_type
                bulk collect into  l_exp_type_tab
                from pa_bc_packets pbc
                where packet_id     = p_packet_id
                  and document_type = 'PO'
                  and parent_bc_packet_id is not NULL
		  and project_id    = g_project_id_tab(line_indx)
		  and task_id       = g_task_id_tab(line_indx)
		  and document_line_id = g_doc_line_id_tab(line_indx) ;

              IF l_exp_type_tab.count > 0 THEN
	         --
	         -- BUG 3703180
		 -- Determine the summary amounts from pa bc packets or pa bc commitments table.
		 --
                 for indx in 1..l_exp_type_tab.count loop

		    g_bdamt_balance_tab.delete ;
                    /*
                    ** 3703180 : Determine the summary record amounts.. for a line
                    */
                    select (nvl(comm_tot_bd_amt,0)  - nvl(comm_bd_amt_relieved,0) ) bd_amount
                      bulk collect into g_bdamt_balance_tab
                      from pa_bc_packets
                     where document_type       = 'PO'
                       and summary_record_flag = 'Y'
                       and document_line_id    = g_doc_line_id_tab(line_indx)
                       and status_code         in ('A', 'C')
                       --and burden_cost_flag    = 'O'
		       and parent_bc_packet_id is not NULL
                       and project_id          = g_project_id_tab(line_indx)
                       and task_id             = g_task_id_tab(line_indx)
                       and expenditure_type    = l_exp_type_tab(indx)
                       and packet_id           < p_packet_id ;

                    IF g_bdamt_balance_tab.count = 0 THEN
                       select (nvl(comm_tot_bd_amt,0)  - nvl(comm_bd_amt_relieved,0) ) bd_amount
                         bulk collect into g_bdamt_balance_tab
                         from pa_bc_commitments
                        where document_type       = 'PO'
			  and summary_record_flag = 'Y'
			   -- and burden_cost_flag    = 'O'
		          and parent_bc_packet_id is not NULL
			  and document_line_id    = g_doc_line_id_tab(line_indx)
			  and project_id          = g_project_id_tab(line_indx)
			  and task_id             = g_task_id_tab(line_indx)
			  and expenditure_type    = l_exp_type_tab(indx)
			  and packet_id           < p_packet_id ;
                    END IF ;

                    if g_bdamt_balance_tab.count > 0 then
	               l_bdamt_balance := g_bdamt_balance_tab(1) ;
                    else
	               l_bdamt_balance := 0 ;
                    end if ;

		    l_bc_packet_id_tab.delete ;
		    l_entered_dr_tab.delete ;
		    l_entered_cr_tab.delete ;
		    l_accounted_dr_tab.delete ;
		    l_accounted_cr_tab.delete ;

	            --
	            -- BUG 3703180
		    -- Get the pa bc packets burden cost in the descending order
		    --
		    select bc_packet_id,
		           entered_dr,
			   entered_cr,
			   accounted_dr,
			   accounted_cr
		      bulk collect into  l_bc_packet_id_tab,
			   l_entered_dr_tab,
			   l_entered_cr_tab,
			   l_accounted_dr_tab,
			   l_accounted_cr_tab
		      from pa_bc_packets
		     where packet_id         = p_packet_id
		       and document_line_id  = g_doc_line_id_tab(line_indx)
		       and project_id        = g_project_id_tab(line_indx)
		       and task_id           = g_task_id_tab(line_indx)
		       and parent_bc_packet_id is not NULL
		       and expenditure_type  = l_exp_type_tab(indx)
		     order by abs(nvl(entered_dr,0) - nvl(entered_cr,0))  desc;

	            --
	            -- BUG 3703180
		    -- Compare the burden cost with the summary table record.
		    --
                    IF l_bc_packet_id_tab.count > 0 THEN
                       for pkt_rec in 1..l_bc_packet_id_tab.count loop

			   l_cr_amount := nvl(l_accounted_dr_tab(pkt_rec),0) - nvl(l_accounted_cr_tab(pkt_rec),0) ;
			   -- Make sure that signs are correct.
			   --
			   l_cr_amount := nvl(l_cr_amount,0) * -1 ;

                           if l_bdamt_balance <= 0 then
                              l_entered_cr_tab(pkt_rec)   := 0 ;
                              l_accounted_cr_tab(pkt_rec) := 0 ;
                           elsif l_cr_amount <= l_bdamt_balance then

                              l_bdamt_balance            := l_bdamt_balance - l_cr_amount ;
			      l_entered_cr_tab(pkt_rec)  := l_cr_amount ;
			      l_accounted_cr_tab(pkt_rec):= l_cr_amount ;

                           elsif l_cr_amount > l_bdamt_balance then

                              l_entered_cr_tab(pkt_rec)   := l_bdamt_balance ;
                              l_accounted_cr_tab(pkt_rec) := l_bdamt_balance;
                              l_bdamt_balance             := 0 ;
                           end if ;

		           if l_cr_amount = 0 and l_bdamt_balance > 0 THEN

			      l_entered_cr_tab(pkt_rec)     := l_bdamt_balance ;
			      l_accounted_cr_tab(pkt_rec)   := l_bdamt_balance;
			      l_bdamt_balance               := 0 ;

		           end if ;
                       end loop ;

	               --
	               -- BUG 3703180
		       -- Update the burden cost to pa bc packets.
		       --
                       FORALL i IN l_bc_packet_id_tab.first .. l_bc_packet_id_tab.last
			  update pa_bc_packets
			     set entered_cr   = l_entered_cr_tab(i),
			         accounted_cr = l_accounted_cr_tab(i),
				 entered_dr   = 0,
				 accounted_dr = 0
			  where packet_id    = p_packet_id
			    and bc_packet_id = l_bc_packet_id_tab(i) ;
                    END IF ;

		 end loop ; -- l_exp_type_tab loop
	      end if ; --  l_exp_type_tab.count

	    end if ;   -- g_burden_type_tab(line_indx)

	end loop ; --g_project_id_tab.count LOOP
    END IF ;       -- g_project_id_tab.count

    COMMIT ;

END update_cwk_po_burden ;
--
-- 3703180 : end of changes


---------------------------------------------------------------------
-- this api creates the burden lines for the purchase order and
-- supplier invoice lines in pa_bc_packets
---------------------------------------------------------------------
FUNCTION  create_ap_po_bdn_lines
		(p_packet_id  	  IN  NUMBER,
		 p_bc_packet_id   IN  NUMBER,
		 p_burden_type    IN  VARCHAR2,
		 P_entered_dr     IN  NUMBER,
		 P_entered_cr     IN  NUMBER,
		 P_period_name    IN  VARCHAR2,
		 p_doc_type       IN  VARCHAR2,
		 p_related_link   IN  VARCHAR2,
                 p_exp_type       IN  VARCHAR2,
		 p_accounted_dr   IN  NUMBER,
		 p_accounted_cr   IN  NUMBER,
		 p_compiled_multiplier IN NUMBER
		) RETURN boolean is
	PRAGMA AUTONOMOUS_TRANSACTION;

        l_request_id      NUMBER := fnd_global.conc_request_id();
        l_program_id      NUMBER := fnd_global.conc_program_id();
        l_program_application_id NUMBER := fnd_global.prog_appl_id();
        l_update_login    NUMBER := NVL(FND_GLOBAL.login_id,-1);
        l_userid          NUMBER := NVL(fnd_global.user_id,-1);
	-- bug : 3717214
	-- Declare variables and cursors to determine if existing multipliers should be used
	--
	l_count            NUMBER  ;
	l_max_packet_id    NUMBER ;
	l_max_packet_id_b  NUMBER ;
	l_amount           NUMBER ;
	l_prev_multiplier  varchar2(1) ;
	l_tab_multiplier   pa_plsql_datatypes.NumTabTyp ;
	l_tab_icc_exp_type pa_plsql_datatypes.char50TabTyp;
	l_doc_header_id       pa_bc_packets.document_header_id%TYPE ;
	l_doc_distribution_id pa_bc_packets.document_distribution_id%TYPE ;

         /* Commented as part of Bug 5406690
	 CURSOR C_ap_parent_reversal_dist IS --Bug 5515095
	 SELECT parent_reversal_id
	   FROM ap_invoice_distributions_all ap
	  WHERE ap.invoice_distribution_id = l_doc_distribution_id
	    AND parent_reversal_id IS NOT NULL;  */

         l_ap_parent_dist_id  ap_invoice_distributions_all.parent_reversal_id%TYPE;

BEGIN
	PA_FUNDS_CONTROL_PKG.log_message(p_msg_token1 =>
	' burden type for ap po = '||p_burden_type||' - related link -'||p_related_link);

	-- bug : 3717214
	-- Determine if we need to use existing idc multipliers for PO or REQs
	-- Following scenarios are covered
	-- Requisition cancellations
	-- PO funds reservations ( PO autocreated from REQ )
	-- PO cancellations
	-- PO Credits/Debits ( AP matching to PO approvals )
	-- ==
        l_prev_multiplier := 'N' ;
       l_tab_multiplier.DELETE ;
       l_tab_icc_exp_type.DELETE ;

        pa_funds_control_pkg.log_message(p_msg_token1 =>'Use Existing Multiplier init :'||l_prev_multiplier);
	IF p_doc_type in ( 'PO', 'REQ' , 'AP' ) THEN

              select document_header_id ,
                     document_distribution_id ,
		     (nvl(entered_dr,0) - NVL(entered_cr,0)) amount
	        into l_doc_header_id,
	             l_doc_distribution_id,
		     l_amount
                from pa_bc_packets
               where packet_id     = p_packet_id
	         and bc_packet_id  = p_bc_packet_id ;

	      IF p_doc_type = 'AP' THEN

                 IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
                    pa_funds_control_pkg.log_message(p_msg_token1 =>'Checking if AP distribution is reversal/cancelled distribution') ;
   	         END IF ;

                 /* Bug 5406690 : Changed the logic for checking if AP distribution is reversal/cancelled distribution.
		                  The old logic i.e cursor C_ap_parent_reversal_dist was not able to read uncommitted
				  data from the main session. Now the logic is changed to use global plsql tables
				  that are populated from the main session (i.e PROCEDURE CREATE_PROJ_ENCUMBRANCE_EVENTS). */
		 for i in 1 .. g_tab_bc_packet_id.count loop
                      if ((g_tab_bc_packet_id(i)=p_bc_packet_id) and (g_tab_parent_reversal_id(i) IS NOT NULL)) then
		         l_doc_distribution_id := g_tab_parent_reversal_id(i);
                         l_prev_multiplier     := 'Y' ;
			 IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
                           pa_funds_control_pkg.log_message(p_msg_token1 =>'Parent AP distribution id '||l_doc_distribution_id) ;
   	                 END IF ;
		      end if;
		 end loop;

                 /* Commented as part of Bug 5406690
                 --Bug 5515095: Below code added to fetch burden multiplier from parent transaction
	         OPEN  C_ap_parent_reversal_dist;
		 FETCH C_ap_parent_reversal_dist INTO l_ap_parent_dist_id;
		 IF C_ap_parent_reversal_dist%FOUND THEN
		    l_doc_distribution_id := l_ap_parent_dist_id;
                    l_prev_multiplier     := 'Y' ;
                    IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
                       pa_funds_control_pkg.log_message(p_msg_token1 =>'Parent AP distribution id '||l_doc_distribution_id) ;
   	            END IF ;
		 END IF;
		 CLOSE C_ap_parent_reversal_dist; */

              END IF;

	END IF ;

	-- Bug 5511059 : For AP, below logic should get fired only if its reversal/cancel scenario (i.e l_prev_multiplier
	-- is set to 'Y' by above if condition) Note : For credit and debit memos l_amount will be negative

	IF ( (p_doc_type in ( 'PO', 'REQ' ) AND (l_amount < 0 and p_related_link = 'N')) OR
	     (p_doc_type = 'AP' AND (l_prev_multiplier = 'Y' and p_related_link = 'N')))   then

              l_prev_multiplier     := 'Y' ;
              pa_funds_control_pkg.log_message(p_msg_token1 =>'Use Existing Multiplier Credit found :'||l_prev_multiplier);

              select NVL(max(pbc.packet_id) ,0)
                into l_max_packet_id
                from pa_bc_commitments pbc
               where pbc.document_header_id       = l_doc_header_id
                 and pbc.document_distribution_id = l_doc_distribution_id
                 and pbc.document_type            = p_doc_type
                 and pbc.packet_id                <> p_packet_id ;

              pa_funds_control_pkg.log_message(p_msg_token1 =>'OLD Multiplier: pa_bc_commitments packet id '||l_max_packet_id);

              select max(packet_id)
                into l_max_packet_id_b
                from pa_bc_packets gbc1
               where packet_id               <> p_packet_id
                 and packet_id                > NVL(l_max_packet_id,0)
                 and document_type            = p_doc_type
                 and document_header_id       = l_doc_header_id
                 and document_distribution_id = l_doc_distribution_id
                 and status_code in ( 'A','C') ;

              pa_funds_control_pkg.log_message(p_msg_token1 =>'OLD Multiplier: pa_bc_packets packet id '||l_max_packet_id_b);
	      -- bug : 3717214
	      -- Spool the existing multipliers.
              BEGIN
	         IF NVL(l_max_packet_id,0) >= nvl(l_max_packet_id_b,0) THEN
                    select compiled_multiplier ,
	                   expenditure_type
                      bulk collect into l_tab_multiplier,
	                                l_tab_icc_exp_type
                      from pa_bc_commitments
                     where packet_id                = l_max_packet_id
		       and document_header_id       = l_doc_header_id
		       and document_distribution_id = l_doc_distribution_id
		       and document_type            = p_doc_type
                       -- and parent_bc_packet_id is not NULL ;
		       -- Bug 5514074 : For AP with qty/amount variance there will be multiple RAW records in
		       -- pa_bc_packets/bc commitments with same header_id and distribution_id.In such scenario
		       -- we should pick burden lines against one of the raw line else it will result in burden
		       -- duplication
                       and parent_bc_packet_id      IN  ( SELECT bc1.bc_packet_id -- SQL to fetch single raw record
                                                            FROM pa_bc_commitments bc1
                                                           WHERE bc1.packet_id                = l_max_packet_id
		                                             AND bc1.document_header_id       = l_doc_header_id
		                                             AND bc1.document_distribution_id = l_doc_distribution_id
		                                             AND bc1.document_type            = p_doc_type
                                                             AND bc1.parent_bc_packet_id IS NULL
							     AND ROWNUM = 1 );

                     pa_funds_control_pkg.log_message(p_msg_token1 =>'OLD Multiplier: pa_bc_commitments multiplier used');
		 ELSE

                    select compiled_multiplier ,
	                   expenditure_type
                      bulk collect into l_tab_multiplier,
	                                l_tab_icc_exp_type
                      from pa_bc_packets
                     where packet_id                = l_max_packet_id_b
		       and document_header_id       = l_doc_header_id
		       and document_distribution_id = l_doc_distribution_id
		       and document_type            = p_doc_type
                       -- and parent_bc_packet_id is not NULL ;
		       -- Bug 5514074 : For AP with qty/amount variance there will be multiple RAW records in
		       -- pa_bc_packets/bc commitments with same header_id and distribution_id.In such scenario
		       -- we should pick burden lines against one of the raw line else it will result in burden
		       -- duplication
                       and parent_bc_packet_id      IN  ( SELECT bc1.bc_packet_id -- SQL to fetch single raw record
                                                            FROM pa_bc_packets bc1
                                                           WHERE bc1.packet_id                = l_max_packet_id_b
		                                             AND bc1.document_header_id       = l_doc_header_id
		                                             AND bc1.document_distribution_id = l_doc_distribution_id
		                                             AND bc1.document_type            = p_doc_type
                                                             AND bc1.parent_bc_packet_id IS NULL
							     AND ROWNUM = 1 );

                     pa_funds_control_pkg.log_message(p_msg_token1 =>'OLD Multiplier: pa_bc_packets multiplier used');

		 END IF ;
              EXCEPTION
	       when no_data_found then
	            NULL ;
	      END ;

	      -- bug : 3717214
	      -- Prior to Patchset M compiled multiplier was not stored so we can not use
	      -- previous multiplier for data created prior to patch sets M.
	      --
	      IF l_tab_multiplier.count > 0 THEN
	         IF l_tab_multiplier(1) is NULL THEN
	            l_prev_multiplier := 'N' ;
                    pa_funds_control_pkg.log_message(p_msg_token1 =>'OLD Multiplier: Prior to PAM Data');
                    pa_funds_control_pkg.log_message(p_msg_token1 =>'OLD Multiplier: Calculate Multiplier');
	         END IF ; -- l_tab_multiplier(1) is null
	      END IF ;    -- l_tab_multiplier.count
	END IF; -- IF ( (p_doc_type in ( 'PO', 'REQ' ) AND (l_amount < 0 and p_related_link = 'N')) OR ..



    -- bug : 3717214
    -- Calculate the new multipliers...
    --
    IF l_prev_multiplier = 'N' THEN
       pa_funds_control_pkg.log_message(p_msg_token1 =>'OLD Multiplier: Calculate Multiplier for p_burden_type '||p_burden_type);
       IF p_burden_type = 'SAME' THEN

          SELECT  NVL (pa_funds_control_utils.get_fc_compiled_multiplier
                    (  pbc.expenditure_organization_id,
                       pbc.task_id,
                       pbc.expenditure_item_date,
                       'C',
                       pbc.expenditure_type
                      ), 0),
                  expenditure_type
            BULK COLLECT into l_tab_multiplier ,
                              l_tab_icc_exp_type
            FROM pa_bc_packets pbc
           WHERE pbc.packet_id = p_packet_id
             AND pbc.bc_packet_id = p_bc_packet_id
             AND pbc.document_type = p_doc_type
             AND substr(nvl(pbc.result_code,'X'),1,1) <> 'F'
  	     AND NVL (pa_funds_control_utils.get_fc_compiled_multiplier
                    (  pbc.expenditure_organization_id,
                       pbc.task_id,
                       pbc.expenditure_item_date,
                       'C',
                       pbc.expenditure_type
                      ), 0) <> 0;
       ELSE
          select et.expenditure_type,
                 cm.compiled_multiplier
           bulk  collect into l_tab_icc_exp_type,
                              l_tab_multiplier
           FROM
                 pa_ind_rate_sch_revisions irsr,
                 pa_cost_bases cb,
                 pa_expenditure_types et,
                 pa_ind_cost_codes icc,
                 pa_cost_base_exp_types cbet,
                 pa_ind_rate_schedules_all_bg irs,
                 pa_ind_compiled_sets ics,
                 pa_compiled_multipliers cm,
                 pa_bc_packets pbc
           WHERE irsr.cost_plus_structure = cbet.cost_plus_structure
             AND cb.cost_base             = cbet.cost_base
             AND cb.cost_base_type        = cbet.cost_base_type
             AND et.expenditure_type      = icc.expenditure_type
             AND icc.ind_cost_code        = cm.ind_cost_code
             AND cbet.cost_base           = cm.cost_base
             AND cbet.cost_base_type      = 'INDIRECT COST'
             AND cbet.expenditure_type    = pbc.expenditure_type
             AND irs.ind_rate_sch_id      = irsr.ind_rate_sch_id
             AND ics.ind_rate_sch_revision_id = irsr.ind_rate_sch_revision_id
             AND ics.organization_id      = pbc.expenditure_organization_id
             AND ics.ind_compiled_set_id  =
				pa_funds_control_utils.get_fc_compiled_set_id
                                          (pbc.task_id,
                                          pbc.expenditure_item_date,
					  pbc.expenditure_organization_id,
                                          'C'
					  , 'COMPILE_SET_ID'
					  ,pbc.expenditure_type)  -- Added for burdening changes
  		   AND ics.cost_base = cb.cost_base -- Added for burdening changes
           AND cm.ind_compiled_set_id = ics.ind_compiled_set_id
           AND cm.compiled_multiplier <> 0
           AND pbc.packet_id = p_packet_id
           AND pbc.bc_packet_id  = p_bc_packet_id
           AND substr(nvl(pbc.result_code,'X'),1,1) <> 'F';
       END IF ; -- p_burden_type = 'SAME'

    END IF ; -- l_prev_multiplier = 'N'

IF p_burden_type = 'SAME' THEN
		If p_related_link = 'N' then
                   IF l_tab_multiplier.count > 0 THEN
		      forall indx in 1..l_tab_multiplier.count
                                INSERT INTO pa_bc_packets
                                        ( ---- who columns------
                                        request_id,
                                        program_id,
                                        program_application_id,
                                        program_update_date,
                                        last_update_date,
                                        last_updated_by,
                                        created_by,
                                        creation_date,
                                        last_update_login,
                                        ------ main columns-----------
                                        packet_id,
                                        bc_packet_id,
                                        budget_version_id,
                                        project_id,
                                        task_id,
                                        expenditure_type,
                                        expenditure_organization_id,
                                        expenditure_item_date,
                                        set_of_books_id,
                                        je_source_name,
                                        je_category_name,
                                        document_type,
                                        document_header_id,
                                        document_distribution_id,
                                        actual_flag,
                                        period_name,
                                        period_year,
                                        period_num,
                                        result_code,
                                        status_code,
                                        entered_dr,
                                        entered_cr,
					accounted_dr,
					accounted_cr,
                                        gl_row_number,    --gl_row_bc_packet_row_id
                                        balance_posted_flag,
                                        funds_process_mode,
                                        txn_ccid,
                                        parent_bc_packet_id,
					encumbrance_type_id,
					burden_cost_flag,
					org_id,
					gl_date,
					pa_date,
					document_line_id,
					compiled_multiplier,
					reference1,
					reference2,
					reference3,
					exp_item_id,
					bc_event_id,
					budget_line_id,
					vendor_id,
					main_or_backing_code,
					burden_method_code,
					source_event_id,
					ext_bdgt_flag,
					document_distribution_type,
					document_header_id_2,
					proj_encumbrance_type_id
                                        )
                                SELECT
                                        l_request_id,
                                        l_program_id,
                                        l_program_application_id,
                                        sysdate,
                                        sysdate,
                                        l_userid,
                                        l_userid,
                                        sysdate,
                                        l_update_login,
                                        ------ main columns-----------
                                        pbc.packet_id,
                                        pa_bc_packets_s.nextval,
                                        pbc.budget_version_id,
                                        pbc.project_id,
                                        pbc.task_id,
                                        pbc.expenditure_type,
                                        pbc.expenditure_organization_id,
                                        pbc.expenditure_item_date,
                                        pbc.set_of_books_id,
                                        pbc.je_source_name,
                                        pbc.je_category_name,
                                        pbc.document_type,
                                        pbc.document_header_id,
                                        pbc.document_distribution_id,
                                        pbc.actual_flag,
                                        /** pagl period enhancement changes instead of passing pa date
                                            pass transaction date to derive the period name
                                        --decode(pbc.document_type,'AP',(
					pa_funds_control_pkg1.get_period_name(pa_utils2.get_pa_date
					  (pbc.expenditure_item_date,NULL,pbc.org_id),pbc.set_of_books_id),
						-- ),pbc.period_name),
                                        **/
                                        /** Bug fix:2905892 As per discussions with Barbara , Dinakar, Prithi
                                         *  the period name should be derived
                                         * based on the orginal raw line for the burden transactions
                                         * so reverting back to changes made earlier
                                         *pa_funds_control_pkg1.get_period_name
                                         * (pbc.expenditure_item_date,pbc.set_of_books_id),**/
                                        pbc.period_name,
                                        /** End of bug fix: 2905892 ***/
                                        pbc.period_year,
                                        pbc.period_num,
                                        pbc.result_code,
                                        pbc.status_code,
					pa_currency.round_trans_currency_amt(
                                        DECODE ( NVL ( pbc.entered_dr, 0 ), 0, 0,
                                                (( NVL (pbc.entered_dr ,0) *
                                                l_tab_multiplier(indx)))),g_acct_currency_code),
					pa_currency.round_trans_currency_amt(
                                        DECODE ( NVL ( pbc.entered_cr, 0 ), 0, 0,
                                                (( NVL (pbc.entered_cr ,0) *
						l_tab_multiplier(indx) ))),g_acct_currency_code),
					pa_currency.round_trans_currency_amt(
                                        DECODE ( NVL ( pbc.accounted_dr, 0 ), 0, 0,
                                                (( NVL (pbc.accounted_dr ,0) *
						   l_tab_multiplier(indx)))),g_acct_currency_code),
					pa_currency.round_trans_currency_amt(
                                        DECODE ( NVL ( pbc.accounted_cr, 0 ), 0, 0,
                                                (( NVL (pbc.accounted_cr ,0) *
						   l_tab_multiplier(indx)))),g_acct_currency_code),
                                        NULL,    --gl_row_bc_packet_row_id
                                        pbc.balance_posted_flag,
                                        pbc.funds_process_mode,
                                        pbc.txn_ccid,
                                        pbc.bc_packet_id,
					pbc.encumbrance_type_id,
					'O',
					pbc.org_id,
					pbc.gl_date,
					pbc.pa_date,
					pbc.document_line_id,
					l_tab_multiplier(indx)
					,pbc.reference1
					,pbc.reference2
					,pbc.reference3
					,pbc.exp_item_id
					,pbc.bc_event_id
					,pbc.budget_line_id
					,pbc.vendor_id
					,pbc.main_or_backing_code
					,pbc.burden_method_code
					,pbc.source_event_id
					,pbc.ext_bdgt_flag
					,pbc.document_distribution_type
					,pbc.document_header_id_2
					,pbc.proj_encumbrance_type_id
                                FROM pa_bc_packets pbc
                                WHERE  pbc.packet_id = p_packet_id
                                AND pbc.bc_packet_id = p_bc_packet_id
                                AND pbc.document_type = p_doc_type
                                AND substr(nvl(pbc.result_code,'X'),1,1) <> 'F' ;
                                --If sql%Notfound then
				IF SQL%BULK_ROWCOUNT(1) = 0 THEN
                                        PA_FUNDS_CONTROL_PKG.log_message
					(p_msg_token1 => 'Transaction failed to populate burden cost',
                                          p_msg_token2 => 'bc_packet_id = '||to_char(p_bc_packet_id));

                                        -- Error msg : 'F114 = Transaction Failed to populate burden cost'
                                        PA_FUNDS_CONTROL_PKG.result_status_code_update
						(p_packet_id => p_packet_id,
                                                p_bc_packet_id => p_bc_packet_id,
                                                p_result_code   => 'F114',
                                                p_res_result_code => 'F114',
                                                p_res_grp_result_code => 'F114',
                                                p_task_result_code => 'F114',
                                                p_top_task_result_code => 'F114',
                                                p_project_result_code => 'F114',
                                                p_proj_acct_result_code => 'F114');
                                End if;
				IF SQL%BULK_ROWCOUNT(1) > 0 THEN
                                --IF sql%found then
                                        PA_FUNDS_CONTROL_PKG.log_message
					(p_msg_token1 =>'No of bdn lines created ='||sql%bulk_rowcount(1)  );
                                End if;

		   END IF ; -- l_tab_multiplier.count endif
		Elsif p_related_link = 'Y' then
                                INSERT INTO pa_bc_packets
                                        ( ---- who columns------
                                        request_id,
                                        program_id,
                                        program_application_id,
                                        program_update_date,
                                        last_update_date,
                                        last_updated_by,
                                        created_by,
                                        creation_date,
                                        last_update_login,
                                        ------ main columns-----------
                                        packet_id,
                                        bc_packet_id,
                                        budget_version_id,
                                        project_id,
                                        task_id,
                                        expenditure_type,
                                        expenditure_organization_id,
                                        expenditure_item_date,
                                        set_of_books_id,
                                        je_source_name,
                                        je_category_name,
                                        document_type,
                                        document_header_id,
                                        document_distribution_id,
                                        actual_flag,
                                        period_name,
                                        period_year,
                                        period_num,
                                        result_code,
                                        status_code,
                                        entered_dr,
                                        entered_cr,
					accounted_dr,
					accounted_cr,
                                        gl_row_number,    --gl_row_bc_packet_row_id
                                        balance_posted_flag,
                                        funds_process_mode,
                                        txn_ccid,
                                        parent_bc_packet_id,
					encumbrance_type_id,
					burden_cost_flag,
					org_id,
					gl_date,
					pa_date,
					document_line_id,
					compiled_multiplier,
					reference1,
					reference2,
					reference3,
					exp_item_id,
					bc_event_id,
					budget_line_id,
					vendor_id,
					main_or_backing_code,
					burden_method_code,
					source_event_id,
					ext_bdgt_flag,
					document_distribution_type,
					document_header_id_2,
					proj_encumbrance_type_id)
                                SELECT
                                        l_request_id,
                                        l_program_id,
                                        l_program_application_id,
                                        sysdate,
                                        sysdate,
                                        l_userid,
                                        l_userid,
                                        sysdate,
                                        l_update_login,
                                        ------ main columns-----------
                                        pbc.packet_id,
                                        pa_bc_packets_s.nextval,
                                        pbc.budget_version_id,
                                        pbc.project_id,
                                        pbc.task_id,
                                        pbc.expenditure_type,  --- p_exp_type
                                        pbc.expenditure_organization_id,
                                        pbc.expenditure_item_date,
                                        pbc.set_of_books_id,
                                        pbc.je_source_name,
                                        pbc.je_category_name,
                                        pbc.document_type,
                                        pbc.document_header_id,
                                        pbc.document_distribution_id,
                                        pbc.actual_flag,
                                        /** pagl period enhancement changes instead of passing pa date
                                            pass transaction date to derive the period name
                                        pa_funds_control_pkg1.get_period_name(pa_utils2.get_pa_date
                                          (pbc.expenditure_item_date,NULL,pbc.org_id),pbc.set_of_books_id),
                                        --P_period_name,
                                        **/
                                        /** Bug fix:2905892 As per discussions with Barbara , Dinakar, Prithi
                                         *  the period name should be derived
                                         * based on the orginal raw line for the burden transactions
                                         * so reverting back to changes made earlier
                                         *pa_funds_control_pkg1.get_period_name
                                         * (pbc.expenditure_item_date,pbc.set_of_books_id),**/
                                        pbc.period_name,
                                        /** End of bug fix: 2905892 ***/
                                        pbc.period_year,
                                        pbc.period_num,
                                        pbc.result_code,
                                        pbc.status_code,
					/* Incorrect Burden amts Bug fix:
                                        pa_currency.round_trans_currency_amt
					(p_entered_cr,g_acct_currency_code),
						  -- amount from pa_bc_commitments (flip the amts)
					pa_currency.round_trans_currency_amt
                                        (p_entered_dr,g_acct_currency_code),  -- amount from pa_bc_commitments
					pa_currency.round_trans_currency_amt
					(p_accounted_cr,g_acct_currency_code),-- amount from pa_bc_commitments
					pa_currency.round_trans_currency_amt
					(p_accounted_dr,g_acct_currency_code), -- amount from pa_bc_commitments
					End Of bug fix:  */
                                        pa_currency.round_trans_currency_amt
                                        (p_entered_dr,g_acct_currency_code),
                                        pa_currency.round_trans_currency_amt
                                        (p_entered_cr,g_acct_currency_code),
                                        pa_currency.round_trans_currency_amt
                                        (p_accounted_dr,g_acct_currency_code),
                                        pa_currency.round_trans_currency_amt
                                        (p_accounted_cr,g_acct_currency_code),
                                        NULL,    --gl_row_bc_packet_row_id to be updated later
                                        pbc.balance_posted_flag,
                                        pbc.funds_process_mode,
                                        pbc.txn_ccid,
                                        pbc.bc_packet_id,
					pbc.encumbrance_type_id,
					'O',
					pbc.org_id,
					pbc.gl_date,
					pbc.pa_date,
					pbc.document_line_id,
					p_compiled_multiplier,
					pbc.reference1,
					pbc.reference2,
					pbc.reference3,
					pbc.exp_item_id,
					pbc.bc_event_id,
					pbc.budget_line_id,
					pbc.vendor_id,
					pbc.main_or_backing_code,
					pbc.burden_method_code,
					pbc.source_event_id,
					pbc.ext_bdgt_flag,
					pbc.document_distribution_type,
					pbc.document_header_id_2,
					pbc.proj_encumbrance_type_id
                                FROM pa_bc_packets pbc
                                WHERE pbc.packet_id = p_packet_id
                                AND pbc.bc_packet_id = p_bc_packet_id
                                AND pbc.document_type = p_doc_type
                                AND substr(nvl(pbc.result_code,'X'),1,1) <> 'F';
                                If sql%Notfound then
                                        PA_FUNDS_CONTROL_PKG.log_message
					  (p_msg_token1 => 'Transaction failed to populate burden cost',
                                           p_msg_token2 => 'bc_packet_id = '||to_char(p_bc_packet_id));

                                        -- Error msg : 'F114 = Transaction Failed to populate burden cost'
                                        PA_FUNDS_CONTROL_PKG.result_status_code_update
						(p_packet_id => p_packet_id,
                                                p_bc_packet_id => p_bc_packet_id,
                                                p_result_code   => 'F114',
                                                p_res_result_code => 'F114',
                                                p_res_grp_result_code => 'F114',
                                                p_task_result_code => 'F114',
                                                p_top_task_result_code => 'F114',
                                                p_project_result_code => 'F114',
                                                p_proj_acct_result_code => 'F114');
                                End if;
                                IF sql%found then
                                        PA_FUNDS_CONTROL_PKG.log_message
					(p_msg_token1 =>'No of bdn lines created ='||sql%rowcount);
                                End if;


		End if;


	ELSIF p_burden_type = 'DIFFERENT' then
		If p_related_link = 'N' then
		   IF l_tab_multiplier.COUNT > 0 THEN
		      forall indx in 1..l_tab_multiplier.COUNT
                                INSERT INTO pa_bc_packets
                                        ( ---- who columns------
                                        request_id,
                                        program_id,
                                        program_application_id,
                                        program_update_date,
                                        last_update_date,
                                        last_updated_by,
                                        created_by,
                                        creation_date,
                                        last_update_login,
                                        ------ main columns-----------
                                        packet_id,
                                        bc_packet_id,
                                        budget_version_id,
                                        project_id,
                                        task_id,
                                        expenditure_type,
                                        expenditure_organization_id,
                                        expenditure_item_date,
                                        set_of_books_id,
                                        je_source_name,
                                        je_category_name,
                                        document_type,
                                        document_header_id,
                                        document_distribution_id,
                                        actual_flag,
                                        period_name,
                                        period_year,
                                        period_num,
                                        result_code,
                                        status_code,
                                        entered_dr,
                                        entered_cr,
					accounted_dr,
					accounted_cr,
                                        gl_row_number,    --gl_row_bc_packet_row_id
                                        balance_posted_flag,
                                        funds_process_mode,
                                        txn_ccid,
                                        parent_bc_packet_id,
					encumbrance_type_id,
					burden_cost_flag,
					org_id,
					gl_date,
					pa_date,
					document_line_id,
					compiled_multiplier
					,reference1
					,reference2
					,reference3
					,exp_item_id
					,bc_event_id
					,budget_line_id
					,vendor_id
					,main_or_backing_code
					,burden_method_code
					,source_event_id
					,ext_bdgt_flag
					,document_distribution_type
					,document_header_id_2
					,proj_encumbrance_type_id
                                        )
                                SELECT
                                        l_request_id,
                                        l_program_id,
                                        l_program_application_id,
                                        sysdate,
                                        sysdate,
                                        l_userid,
                                        l_userid,
                                        sysdate,
                                        l_update_login,
                                        ------ main columns-----------
                                        pbc.packet_id,
                                        pa_bc_packets_s.nextval,
                                        pbc.budget_version_id,
                                        pbc.project_id,
                                        pbc.task_id,
					l_tab_icc_exp_type(indx),
                                        --et.expenditure_type,
                                        pbc.expenditure_organization_id,
                                        pbc.expenditure_item_date,
                                        pbc.set_of_books_id,
                                        pbc.je_source_name,
                                        pbc.je_category_name,
                                        pbc.document_type,
                                        pbc.document_header_id,
                                        pbc.document_distribution_id,
                                        pbc.actual_flag,
                                        /** added the pagl enhancement changes pass ei date instead of pa date
                                         *  to get glperiod name
                                        pa_funds_control_pkg1.get_period_name(pa_utils2.get_pa_date
                                          (pbc.expenditure_item_date,NULL,pbc.org_id),pbc.set_of_books_id),
                                        --pbc.period_name,
                                         */
                                        /** Bug fix:2905892 As per discussions with Barbara , Dinakar, Prithi
                                         *  the period name should be derived
                                         * based on the orginal raw line for the burden transactions
                                         * so reverting back to changes made earlier
                                         *pa_funds_control_pkg1.get_period_name
                                         * (pbc.expenditure_item_date,pbc.set_of_books_id),**/
                                        pbc.period_name,
                                        /** End of bug fix: 2905892 ***/
                                        pbc.period_year,
                                        pbc.period_num,
                                        pbc.result_code,
                                        pbc.status_code,
					pa_currency.round_trans_currency_amt(
                                        decode(nvl(pbc.entered_dr,0),0,0,(nvl(pbc.entered_dr,0)*
                                                l_tab_multiplier(indx))),g_acct_currency_code),
					pa_currency.round_trans_currency_amt(
                                        decode(nvl(pbc.entered_cr,0),0,0,(nvl(pbc.entered_cr,0)*
                                                l_tab_multiplier(indx))),g_acct_currency_code),
					pa_currency.round_trans_currency_amt(
                                        decode(nvl(pbc.accounted_dr,0),0,0,(nvl(pbc.accounted_dr,0)*
                                                l_tab_multiplier(indx))),g_acct_currency_code),
					pa_currency.round_trans_currency_amt(
                                        decode(nvl(pbc.accounted_cr,0),0,0,(nvl(pbc.accounted_cr,0)*
                                                l_tab_multiplier(indx))),g_acct_currency_code),
                                        NULL,    --gl_row_bc_packet_row_id
                                        pbc.balance_posted_flag,
                                        pbc.funds_process_mode,
                                        pbc.txn_ccid,
                                        pbc.bc_packet_id,
					pbc.encumbrance_type_id,
					'O',
					pbc.org_id,
					pbc.gl_date,
					pbc.pa_date,
					pbc.document_line_id,
					--cm.compiled_multiplier
					l_tab_multiplier(indx)
					,pbc.reference1
					,pbc.reference2
					,pbc.reference3
					,pbc.exp_item_id
					,pbc.bc_event_id
					,pbc.budget_line_id
					,pbc.vendor_id
					,pbc.main_or_backing_code
					,pbc.burden_method_code
					,pbc.source_event_id
					,ext_bdgt_flag
					,pbc.document_distribution_type
					,pbc.document_header_id_2
					,pbc.proj_encumbrance_type_id
                                FROM pa_bc_packets pbc
                                WHERE pbc.packet_id = p_packet_id
                                AND pbc.bc_packet_id  = p_bc_packet_id
                                AND substr(nvl(pbc.result_code,'X'),1,1) <> 'F';

				FOR indx in 1..l_tab_multiplier.count LOOP
				    IF SQL%BULK_ROWCOUNT(indx) = 0 THEN
                                        PA_FUNDS_CONTROL_PKG.log_message
					   (p_msg_token1 => 'Transaction failed to populate burden cost',
                                           p_msg_token2 => 'bc_packet_id = '||to_char(p_bc_packet_id));

                                        -- Error msg : 'F114 = Transaction Failed to populate burden cost'
                                        PA_FUNDS_CONTROL_PKG.result_status_code_update
						(p_packet_id => p_packet_id,
                                                p_bc_packet_id => p_bc_packet_id,
                                                p_result_code   => 'F114',
                                                p_res_result_code => 'F114',
                                                p_res_grp_result_code => 'F114',
                                                p_task_result_code => 'F114',
                                                p_top_task_result_code => 'F114',
                                                p_project_result_code => 'F114',
                                                p_proj_acct_result_code => 'F114');
                                    End if;
				    l_count := l_count + SQL%BULK_ROWCOUNT(indx) ;
                                END LOOP ;

                                IF l_count > 0  then
                                        PA_FUNDS_CONTROL_PKG.log_message
					(p_msg_token1 =>'No of bdn lines created ='||l_count);
                                End if;


		   END IF ; -- endif for  l_tab_multiplier.COUNT
		Elsif p_related_link = 'Y' then
                                INSERT INTO pa_bc_packets
                                        ( ---- who columns------
                                        request_id,
                                        program_id,
                                        program_application_id,
                                        program_update_date,
                                        last_update_date,
                                        last_updated_by,
                                        created_by,
                                        creation_date,
                                        last_update_login,
                                        ------ main columns-----------
                                        packet_id,
                                        bc_packet_id,
                                        budget_version_id,
                                        project_id,
                                        task_id,
                                        expenditure_type,
                                        expenditure_organization_id,
                                        expenditure_item_date,
                                        set_of_books_id,
                                        je_source_name,
                                        je_category_name,
                                        document_type,
                                        document_header_id,
                                        document_distribution_id,
                                        actual_flag,
                                        period_name,
                                        period_year,
                                        period_num,
                                        result_code,
                                        status_code,
                                        entered_dr,
                                        entered_cr,
					accounted_dr,
					accounted_cr,
                                        gl_row_number,    --gl_row_bc_packet_row_id
                                        balance_posted_flag,
                                        funds_process_mode,
                                        txn_ccid,
                                        parent_bc_packet_id,
					encumbrance_type_id,
					burden_cost_flag,
					org_id,
					gl_date,
					pa_date,
					document_line_id,
					compiled_multiplier
					,reference1
					,reference2
					,reference3
					,bc_event_id
					,budget_line_id
					,vendor_id
					,main_or_backing_code
					,burden_method_code
					,source_event_id
					,ext_bdgt_flag
					,document_distribution_type
					,document_header_id_2
					,proj_encumbrance_type_id
                                        )
                                SELECT
                                        l_request_id,
                                        l_program_id,
                                        l_program_application_id,
                                        sysdate,
                                        sysdate,
                                        l_userid,
                                        l_userid,
                                        sysdate,
                                        l_update_login,
                                        ------ main columns-----------
                                        pbc.packet_id,
                                        pa_bc_packets_s.nextval,
                                        pbc.budget_version_id,
                                        pbc.project_id,
                                        pbc.task_id,
					/* Bug fix:3026988
					 --when REQ becomes PO, the Exp type for reversing REQ is getting
					 --exp type from raw line instead of icc.cost_codes exp type from original
                                         --burden line
                                        --pbc.expenditure_type,
					-- to be confirmed with sandeep to consider the old exp type
					*/
					p_exp_type,
					/* end of bug fix:3026988 */
                                        pbc.expenditure_organization_id,
                                        pbc.expenditure_item_date,
                                        pbc.set_of_books_id,
                                        pbc.je_source_name,
                                        pbc.je_category_name,
                                        pbc.document_type,
                                        pbc.document_header_id,
                                        pbc.document_distribution_id,
                                        pbc.actual_flag,
                                        /** pagl period enhancement changes instead of passing pa date
                                            pass transaction date to derive the period name
                                        pa_funds_control_pkg1.get_period_name(pa_utils2.get_pa_date
                                          (pbc.expenditure_item_date,NULL,pbc.org_id),pbc.set_of_books_id),
                                        **/
                                        /** Bug fix:2905892 As per discussions with Barbara , Dinakar, Prithi
                                         *  the period name should be derived
                                         * based on the orginal raw line for the burden transactions
                                         * so reverting back to changes made earlier
                                         *pa_funds_control_pkg1.get_period_name
                                         * (pbc.expenditure_item_date,pbc.set_of_books_id),**/
                                        pbc.period_name,
                                        /** End of bug fix: 2905892 ***/
                                        pbc.period_year,
                                        pbc.period_num,
                                        pbc.result_code,
                                        pbc.status_code,
					/* Incorrect Burden amts Bug fix:
                                        pa_currency.round_trans_currency_amt
					(p_entered_cr,g_acct_currency_code),
					  -- amount from pa_bc_commitments (flip amts)
                                        pa_currency.round_trans_currency_amt
					(p_entered_dr,g_acct_currency_code),  -- amount from pa_bc_commitments
					pa_currency.round_trans_currency_amt
					(p_accounted_cr,g_acct_currency_code), -- amount from pa_bc_commitments
					pa_currency.round_trans_currency_amt
					(p_accounted_dr,g_acct_currency_code), -- amount from pa_bc_commitments
					End of Bug fix:  */
                                        pa_currency.round_trans_currency_amt
                                        (p_entered_dr,g_acct_currency_code),
                                        pa_currency.round_trans_currency_amt
                                        (p_entered_cr,g_acct_currency_code),
                                        pa_currency.round_trans_currency_amt
                                        (p_accounted_dr,g_acct_currency_code),
                                        pa_currency.round_trans_currency_amt
                                        (p_accounted_cr,g_acct_currency_code),
                                        NULL,    --gl_row_bc_packet_row_id to be updated later
                                        pbc.balance_posted_flag,
                                        pbc.funds_process_mode,
                                        pbc.txn_ccid,
                                        pbc.bc_packet_id,
					pbc.encumbrance_type_id,
					'O',
					pbc.org_id,
					pbc.gl_date,
					pbc.pa_date,
					pbc.document_line_id,
					p_compiled_multiplier,
					pbc.reference1,
					pbc.reference2,
					pbc.reference3,
					pbc.bc_event_id,
					pbc.budget_line_id,
					pbc.vendor_id,
					pbc.main_or_backing_code,
					pbc.burden_method_code,
					pbc.source_event_id,
					ext_bdgt_flag,
					pbc.document_distribution_type,
					pbc.document_header_id_2,
					pbc.proj_encumbrance_type_id
                                FROM pa_bc_packets pbc
                                WHERE  pbc.packet_id = p_packet_id
                                AND pbc.bc_packet_id = p_bc_packet_id
                                AND pbc.document_type = p_doc_type
                                AND substr(nvl(pbc.result_code,'X'),1,1) <> 'F';
                                If sql%Notfound then
                                        PA_FUNDS_CONTROL_PKG.log_message
					  (p_msg_token1 => 'Transaction failed to populate burden cost',
                                           p_msg_token2 => 'bc_packet_id = '||to_char(p_bc_packet_id));

                                        -- Error msg : 'F114 = Transaction Failed to populate burden cost'
                                        PA_FUNDS_CONTROL_PKG.result_status_code_update
						(p_packet_id => p_packet_id,
                                                p_bc_packet_id => p_bc_packet_id,
                                                p_result_code   => 'F114',
                                                p_res_result_code => 'F114',
                                                p_res_grp_result_code => 'F114',
                                                p_task_result_code => 'F114',
                                                p_top_task_result_code => 'F114',
                                                p_project_result_code => 'F114',
                                                p_proj_acct_result_code => 'F114');
                                End if;
                                IF sql%found then
                                        PA_FUNDS_CONTROL_PKG.log_message
					(p_msg_token1 =>'No of bdn lines created ='||sql%rowcount);
                                End if;



		End if;
	END IF;
	commit;  -- to end an active autonmous transaction
	Return True;
EXCEPTION
	WHEN OTHERS THEN
                PA_FUNDS_CONTROL_PKG.log_message
			(p_msg_token1 => 'failed in create ap po bdn lines api SQLERR :'||sqlcode||sqlerrm);
		commit;
		RAISE;

END create_ap_po_bdn_lines;

------------------------------------------------------------------------------------------------------------------
--This  Api insert new records into pa bc packets if the project type is burdened.If the PO is based on REQ, or
--Invoice is based on PO  then  it takes the burden amount for the REQ or PO from pa_bc_commitments table
--and ensures that for  req or po the old burden amount is used when reversing lines are passed in gl_bc_packets
------------------------------------------------------------------------------------------------------------------
PROCEDURE   Populate_burden_cost
 	(p_packet_id     	IN NUMBER
	,p_calling_module	IN  VARCHAR2
 	,x_return_status	OUT  NOCOPY VARCHAR2
 	,x_err_msg_code  	OUT  NOCOPY VARCHAR2
 	)  IS

	PRAGMA AUTONOMOUS_TRANSACTION;

 	l_burden_method     	VARCHAR2(20) := 'NONE';
 	l_bc_packet_id         	NUMBER;
	l_parent_bc_packet_id	NUMBER;
 	l_doc_type        		VARCHAR2(30);
        l_request_id      NUMBER := fnd_global.conc_request_id();
        l_program_id      NUMBER := fnd_global.conc_program_id();
        l_program_application_id NUMBER:= fnd_global.prog_appl_id();
        l_update_login    NUMBER := NVL(FND_GLOBAL.login_id,-1);
        l_num_rows        NUMBER := 0;
	l_userid	  NUMBER := NVL(fnd_global.user_id,-1);
	l_exp_type	  VARCHAR2(100);
	l_expenditure_type  VARCHAR2(100);
	l_entered_dr	  NUMBER;
	l_entered_cr	  NUMBER;
        l_accounted_dr    NUMBER;
        l_accounted_cr    NUMBER;
        l_compiled_multiplier NUMBER;
	l_period_name	  VARCHAR2(30);
	l_req_id	  NUMBER;
	l_related_link    VARCHAR2(1);
	l_req_header_id   NUMBER;
	l_po_header_id    NUMBER;
	l_status_flag     VARCHAR2(1)  := 'N';
	l_commitment_rows_flag  VARCHAR2(10) := 'N';
	l_pkt_rows_flag   VARCHAR2(10) := 'N';
	l_doc_header_id	  PA_BC_PACKETS.document_header_id%type;
	l_doc_distribution_id PA_BC_PACKETS.document_header_id%type;
	l_task_id	  NUMBER;
	l_ei_date	  date;
	l_base		  VARCHAR2(100);
	l_cp_structure	  VARCHAR2(100);
	l_return_status   VARCHAR2(100);
	l_err_msg_code    VARCHAR2(100);
	l_debug_mode	  VARCHAR2(10);

	/*** Bug Fix : 1904319 added this for burden proportional calculations
	 *   cursor po_amount and pkt_po_amount is modified to calculate burden cost
	 *   if the invoice line is partially matched to purchase order
         **/
        -- this cursor picks up the burden amount and details from pa_bc_commitments table
        -- for the given  distribution id ,document type and document header id
        CURSOR pkt_po_amount(l_req_id        NUMBER,
                         l_bc_packet_id  NUMBER,
                         l_po_header_id  NUMBER,
                         l_comm_doc_type VARCHAR2) is
        SELECT pktburd.period_name,
              nvl(pkttrx.entered_dr,0) * decode(nvl(pkttrx.entered_dr,0),0,0,
                                                          get_ratio(pkttrx.document_header_id,
                                                          pkttrx.document_distribution_id,
                                                          pkttrx.document_type,
                                                          'BCCMT',
                                                          'E')) entered_dr,
              nvl(pkttrx.entered_cr,0) * decode(nvl(pkttrx.entered_cr,0),0,0,
                                                          get_ratio(pkttrx.document_header_id,
                                                          pkttrx.document_distribution_id,
                                                          pkttrx.document_type,
                                                          'BCCMT',
                                                          'E')) entered_cr,
              nvl(pkttrx.accounted_dr,0) * decode(nvl(pkttrx.accounted_dr,0),0,0,
                                                          get_ratio(pkttrx.document_header_id,
                                                          pkttrx.document_distribution_id,
                                                          pkttrx.document_type,
                                                          'BCCMT',
                                                          'A')) accounted_dr,
              nvl(pkttrx.accounted_cr,0) * decode(nvl(pkttrx.accounted_cr,0),0,0,
                                                get_ratio(pkttrx.document_header_id,
                                                          pkttrx.document_distribution_id,
                                                          pkttrx.document_type,
                                                          'BCCMT',
                                                          'A')) accounted_cr,
                pktburd.expenditure_type,
		pktburd.compiled_multiplier
        FROM    pa_bc_commitments_all pktburd
                ,pa_bc_commitments_all pktraw
                ,pa_bc_packets pkttrx
        WHERE  pktburd.document_distribution_id = l_req_id
        AND    pktburd.document_header_id = l_po_header_id
        AND    pktburd.document_type = l_comm_doc_type
        AND    pktburd.parent_bc_packet_id is NOT NULL
        AND    (pktburd.packet_id ,pktburd.parent_bc_packet_id ) in
                ( SELECT max(comm.packet_id),max(comm.bc_packet_id)
                  FROM  pa_bc_commitments comm
                  WHERE  comm.document_distribution_id = pktburd.document_distribution_id
                  ANd    comm.document_header_id = pktburd.document_header_id
                  AND    comm.document_type = pktburd.document_type
                  AND    comm.parent_bc_packet_id is NULL
                )
        AND   pktburd.packet_id = pktraw.packet_id
        AND   pktraw.parent_bc_packet_id is null
        AND   pktraw.document_distribution_id = pktburd.document_distribution_id
        AND   pktraw.document_header_id = pktburd.document_header_id
        AND   pktraw.document_type = pktburd.document_type
        AND   pktburd.parent_bc_packet_id = pktraw.bc_packet_id
        AND   pkttrx.packet_id = p_packet_id
        AND   pkttrx.bc_packet_id = l_bc_packet_id;


        -- this cursor picks up the burden amount and details from pa_bc_packets table
        -- for the given  distribution id ,document type and document header id
        -- the transactions which are approved but not yet swept
        CURSOR po_amount(l_req_id        NUMBER,
                         l_bc_packet_id  NUMBER,
                         l_po_header_id  NUMBER,
                         l_pkt_doc_type VARCHAR2) is
        SELECT pktburd.period_name,
              nvl(pkttrx.entered_dr,0) * decode(nvl(pkttrx.entered_dr,0),0,0,
                                                          get_ratio(pkttrx.document_header_id,
                                                          pkttrx.document_distribution_id,
                                                          pkttrx.document_type,
                                                          'BCPKT',
                                                          'E')) entered_dr,
              nvl(pkttrx.entered_cr,0) * decode(nvl(pkttrx.entered_cr,0),0,0,
                                                          get_ratio(pkttrx.document_header_id,
                                                          pkttrx.document_distribution_id,
                                                          pkttrx.document_type,
                                                          'BCPKT',
                                                          'E')) entered_cr,
              nvl(pkttrx.accounted_dr,0) * decode(nvl(pkttrx.accounted_dr,0),0,0,
                                                          get_ratio(pkttrx.document_header_id,
                                                          pkttrx.document_distribution_id,
                                                          pkttrx.document_type,
                                                          'BCPKT',
                                                          'A')) accounted_dr,
              nvl(pkttrx.accounted_cr,0) * decode(nvl(pkttrx.accounted_cr,0),0,0,
                                                get_ratio(pkttrx.document_header_id,
                                                          pkttrx.document_distribution_id,
                                                          pkttrx.document_type,
                                                          'BCPKT',
                                                          'A')) accounted_cr,
                pktburd.expenditure_type,
		pktburd.compiled_multiplier
        FROM    pa_bc_packets pktburd
                ,pa_bc_packets pktraw
                ,pa_bc_packets pkttrx
        WHERE  pktburd.document_distribution_id = l_req_id
        AND    pktburd.document_header_id = l_po_header_id
        AND    pktburd.document_type = l_pkt_doc_type
        AND    pktburd.parent_bc_packet_id is NOT NULL
        AND    pktburd.balance_posted_flag in ('N')
        AND    pktburd.status_code in ('A','C')
        AND    substr(nvl(pktburd.result_code,'P'),1,1) = 'P'
        AND    (pktburd.packet_id,pktburd.parent_bc_packet_id) in
                ( SELECT MAX(pbc.packet_id),max(bc_packet_id)
                  FROM  pa_bc_packets pbc
                  WHERE  pbc.document_distribution_id = pktburd.document_distribution_id
                  AND    pbc.document_header_id = pktburd.document_header_id
                  AND    pbc.document_type = pktburd.document_type
                  AND    pbc.parent_bc_packet_id is NULL
                  AND    pbc.balance_posted_flag in ('N')
                  AND    pbc.status_code in ('A','C')
                  AND    substr(nvl(pbc.result_code,'P'),1,1) = 'P'
               )
        AND   pktburd.packet_id = pktraw.packet_id
        AND   pktraw.parent_bc_packet_id is null
        AND   pktraw.document_distribution_id = pktburd.document_distribution_id
        AND   pktraw.document_header_id = pktburd.document_header_id
        AND   pktraw.document_type = pktburd.document_type
        and   pktburd.parent_bc_packet_id = pktraw.bc_packet_id
        AND   pkttrx.packet_id = p_packet_id
        AND   pkttrx.bc_packet_id = l_bc_packet_id;



 	CURSOR  burden_type  is
 	SELECT decode(NVL(ppt.burden_cost_flag, 'N'),'Y',
 			decode(NVL(burden_amt_display_method,'S'), 'S','SAME','D','DIFFERENT'),'NONE'),
 		pbc.bc_packet_id ,
 		pbc.document_type,
		pbc.parent_bc_packet_id,
		pbc.document_header_id,
		pbc.document_distribution_id ,
		pbc.task_id,
		pbc.expenditure_item_date,
		pbc.expenditure_type
 	FROM    pa_project_types  ppt,
 		 pa_projects_all  pp,
 		 pa_tasks  ptk,
 		 pa_bc_packets  pbc
 	WHERE
 		ppt.project_type = pp.project_type
 	AND	pp.project_id  = pbc.project_id
 	AND     ptk.project_id = pbc.project_id
 	AND   	ptk.task_id     =  pbc.task_id
 	AND      pbc.packet_id = p_packet_id
	AND     ((pbc.parent_bc_packet_id is null
                  and p_calling_module IN ('GL','CBC','EXPENDITURE'))
                 OR (pbc.parent_bc_packet_id = -1 and p_calling_module
                   in  ('DISTBTC','GL','TRXIMPORT','DISTERADJ','DISTVIADJ','INTERFACER'
			,'INTERFACVI','TRXNIMPORT','DISTCWKST'))
		)
	AND    pbc.status_code IN ('P', 'I');

BEGIN
 	-- Initialize the error stack
 	PA_DEBUG.init_err_stack('PA_FUNDS_CONTROL_PKG1.populate_burden_cost');

        fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
        l_debug_mode := NVL(l_debug_mode, 'N');

        PA_DEBUG.SET_PROCESS( x_process => 'PLSQL'
                             ,x_write_file     => 'LOG'
                            ,x_debug_mode      => l_debug_mode
                            );

 	--Initialize the return status to success
 	x_return_status :=  'S';

        -- initialize the accounting currency code,
        pa_multi_currency.init;

        --Get the accounting currency into a global variable.
        g_acct_currency_code := pa_multi_currency.g_accounting_currency_code;

	pa_funds_control_pkg.log_message(p_msg_token1 => 'Inside Populate burden api');

	-- Initialize global variables
	init_globals;

        IF p_calling_module IN ('GL','CBC','EXPENDITURE') then

 	OPEN  burden_type;
	PA_FUNDS_CONTROL_PKG.log_message(p_msg_token1 =>'opened cursor');
 	LOOP
 	     FETCH burden_type  INTO
			l_burden_method
			,l_bc_packet_id
			,l_doc_type
			,l_parent_bc_packet_id
			,l_doc_header_id
			,l_doc_distribution_id
			,l_task_id
			,l_ei_date
			,l_expenditure_type;
	     --dbms_output.put_line('burden type '||l_burden_method);
 	     EXIT WHEN burden_type%NOTFOUND;
		-- Check whether the expenditure type is part of burdening if not
		-- then donot call populate burden lines
		-- if the expenditure type is part of burden but fails to populate
		-- burden lines then raise error
		IF l_burden_method in ('SAME','DIFFERENT') then
				check_exp_of_cost_base
				  (p_task_id    	=> l_task_id
                                   ,p_exp_type   	=> l_expenditure_type
                                   ,p_ei_date    	=> l_ei_date
                                   ,p_sch_type   	=> 'C'
                                   ,x_base       	=> l_base
				   ,x_cp_structure      => l_cp_structure
                                   ,x_return_status 	=> l_return_status
                                   ,x_error_msg_code  	=> l_err_msg_code);

			IF l_base is NULL and l_return_status = 'S' then
				-- expenditure type is not part of the burdening
				-- so raw cost = burdened cose
				l_status_flag := 'N';
				l_related_link := 'N';
				GOTO END_OF_BURDEN;

			Elsif l_base is NULL and l_return_status <> 'S' then
                                -- expenditure type is  part of the burdening
                                -- but there is error for this expenditure type
				-- either the schedule id is not found or
				-- schedule revision id is null so assign the error
				pa_funds_control_pkg.log_message(p_msg_token2 =>
					'Burden error '||l_err_msg_code);
                                l_status_flag := 'Y';
                                l_related_link := 'Y';
                                GOTO END_OF_BURDEN;
			Elsif l_base is NOT NULL then
				pa_funds_control_pkg.log_message(p_msg_token2 =>
					'cost Base type ='||l_base);
                                l_status_flag := 'N';
                                l_related_link := 'N';
					null;
			END IF;
		END IF;

	     PA_FUNDS_CONTROL_PKG.log_message(p_msg_token1 => 'burden type ['||l_burden_method||
	     ']bc_packet id ['||l_bc_packet_id||']' );

 		IF l_burden_method  = 'SAME'  and  l_bc_packet_id is NOT NULL then

 			IF l_doc_type  IN ( 'CC_C_PAY','CC_P_PAY','CC','CC_C_CO','CC_P_CO' )  THEN
		----------------------------------------------------------------------------------
 		--- insert into pa_bc_packets for the burden cost  as a separate bc packet record
		--- after the funds check these records may be inserted into gl_bc_packets
 		-----------------------------------------------------------------------------
                                If l_parent_bc_packet_id = -1 then
                                        l_related_link := 'Y';
                                        OPEN po_amount(l_doc_distribution_id
                                                        ,l_bc_packet_id
                                                        ,l_doc_header_id
							,l_doc_type);
                                        FETCH po_amount into l_period_name
                                                ,l_entered_dr,l_entered_cr
                                                ,l_accounted_dr,l_accounted_cr,l_exp_type,l_compiled_multiplier;
                                        If po_amount%NOTFOUND then
                                                OPEN pkt_po_amount(l_doc_distribution_id
                                                                   ,l_bc_packet_id
                                                                   ,l_doc_header_id
								   ,l_doc_type);
                                                FETCH pkt_po_amount into l_period_name
                                                ,l_entered_dr,l_entered_cr
                                                ,l_accounted_dr,l_accounted_cr,l_exp_type,l_compiled_multiplier;
                                                If pkt_po_amount%found then
                                                       PA_FUNDS_CONTROL_PKG.log_message(p_msg_token1 => '
                                                            cc amount got from bc packets');
                                                End if;
                                                If pkt_po_amount%NOTFOUND then
                                                        l_status_flag := 'Y';
                                                        GOTO END_OF_BURDEN;
                                                End if;
                                                CLOSE pkt_po_amount;
                                        End if;
                                          If po_amount%found then
                                                PA_FUNDS_CONTROL_PKG.log_message
                                                (p_msg_token1 => 'cc amount got from commitments');
                                          End if;
                                        CLOSE po_amount;

                                Else
                                        PA_FUNDS_CONTROL_PKG.log_message
                                        (p_msg_token1 => 'Not related link N');
                                        l_related_link := 'N';
                                End if;
                                If Not create_ap_po_bdn_lines
                                        (p_packet_id      => p_packet_id
                                        ,p_bc_packet_id   => l_bc_packet_id
                                        ,p_burden_type    => 'SAME'
                                        ,P_entered_dr     => l_entered_dr
                                        ,P_entered_cr     => l_entered_cr
                                        ,P_period_name    => l_period_name
                                        ,p_doc_type       => l_doc_type
                                        ,p_related_link   => l_related_link
                                        ,p_exp_type       => l_exp_type
                                        ,p_accounted_dr   => l_accounted_dr
                                        ,p_accounted_cr   => l_accounted_cr
					,p_compiled_multiplier => l_compiled_multiplier
                                        ) then
                                        --RETURN FALSE;
                                        NULL;
                                end If;
			ELSIF l_doc_type  =  'REQ' then

				If l_parent_bc_packet_id = -1 then
                                        l_related_link := 'Y';
                                        OPEN po_amount(l_doc_distribution_id
							,l_bc_packet_id
							,l_doc_header_id
							,l_doc_type);
                                        FETCH po_amount into l_period_name
                                                ,l_entered_dr,l_entered_cr
                                                ,l_accounted_dr,l_accounted_cr,l_exp_type,l_compiled_multiplier;
                                        If po_amount%NOTFOUND then
                                                OPEN pkt_po_amount(l_doc_distribution_id
								   ,l_bc_packet_id
								   ,l_doc_header_id
								   ,l_doc_type);
                                                FETCH pkt_po_amount into l_period_name
                                                ,l_entered_dr,l_entered_cr
                                                ,l_accounted_dr,l_accounted_cr,l_exp_type,l_compiled_multiplier;
                                                If pkt_po_amount%found then
                                                       PA_FUNDS_CONTROL_PKG.log_message(p_msg_token1 => '
                                                            burden amount got from bc packets');
                                                End if;
                                                If pkt_po_amount%NOTFOUND then
                                                        l_status_flag := 'Y';
                                                        GOTO END_OF_BURDEN;
                                                End if;
                                                CLOSE pkt_po_amount;
                                        End if;
                                          If po_amount%found then
                                                PA_FUNDS_CONTROL_PKG.log_message
                                                (p_msg_token1 => ' amount got from commitments');
                                          End if;
                                        CLOSE po_amount;

                                Else
                                        PA_FUNDS_CONTROL_PKG.log_message
                                        (p_msg_token1 => 'Not related link N');
                                        l_related_link := 'N';
                                End if;
                                If Not create_ap_po_bdn_lines
                                        (p_packet_id      => p_packet_id
                                        ,p_bc_packet_id   => l_bc_packet_id
                                        ,p_burden_type    => 'SAME'
                                        ,P_entered_dr     => l_entered_dr
                                        ,P_entered_cr     => l_entered_cr
                                        ,P_period_name    => l_period_name
                                        ,p_doc_type       => l_doc_type
                                        ,p_related_link   => l_related_link
                                        ,p_exp_type       => l_exp_type
                                        ,p_accounted_dr   => l_accounted_dr
                                        ,p_accounted_cr   => l_accounted_cr
					,p_compiled_multiplier => l_compiled_multiplier
                                        ) then
                                        --RETURN FALSE;
                                        NULL;
                                end If;


	----------------------------------------------------------------------------------------------------
	-- if the document is po and this po is based on Requistions then take the burden amount
	-- for the requisition from the pa_bc_commitment table for the given po_distribution_id
	-- if the burden lines not found in commitment table then look at pa bc packet table where
	-- status code is approved and balance posted flag is  N ie is not yet swept if not found then
	-- error out the transaction
	----------------------------------------------------------------------------------------------------------
			Elsif  l_doc_type = 'PO' then
                                If l_parent_bc_packet_id = -1  THEN
                                        l_related_link := 'Y';
                                        OPEN po_amount( l_doc_distribution_id
							,l_bc_packet_id
							,l_doc_header_id
						        ,l_doc_type);
                                        FETCH po_amount into l_period_name,l_entered_dr,l_entered_cr,
                                                       l_accounted_dr,l_accounted_cr,l_exp_type,l_compiled_multiplier;
                                        If po_amount%found then
                                           PA_FUNDS_CONTROL_PKG.log_message
                                                (p_msg_token1 => 'amounts got from commitments ');
                                        End if;
                                        If po_amount%NOTFOUND then
                                                OPEN pkt_po_amount(l_doc_distribution_id
                                                        	  ,l_bc_packet_id
                                                        	  ,l_doc_header_id
								  ,l_doc_type);
                                                FETCH pkt_po_amount into l_period_name,l_entered_dr,l_entered_cr,
                                                       l_accounted_dr,l_accounted_cr,l_exp_type,l_compiled_multiplier;
                                                If pkt_po_amount%found then
                                                PA_FUNDS_CONTROL_PKG.log_message
                                                (p_msg_token1 => 'amounts got from bc packets ');
                                                End if;
                                                If pkt_po_amount%NOTFOUND then
                                                        l_status_flag := 'Y';
                                                        GOTO END_OF_BURDEN;
                                                End if;
                                                CLOSE pkt_po_amount;
                                        End IF;
                                        CLOSE po_amount;
                                Else
                                        PA_FUNDS_CONTROL_PKG.log_message
                                        (p_msg_token1 => 'Not related link N');
                                        l_related_link := 'N';
                                End if;
				If Not create_ap_po_bdn_lines
                			(p_packet_id      => p_packet_id
                 		 	,p_bc_packet_id   => l_bc_packet_id
                 			,p_burden_type    => 'SAME'
                 			,P_entered_dr     => l_entered_dr
                 			,P_entered_cr     => l_entered_cr
                 			,P_period_name    => l_period_name
                 			,p_doc_type       => l_doc_type
                 			,p_related_link   => l_related_link
                                        ,p_exp_type       => l_exp_type
					,p_accounted_dr   => l_accounted_dr
					,p_accounted_cr   => l_accounted_cr
					,p_compiled_multiplier => l_compiled_multiplier
                			) then
					--RETURN FALSE;
					NULL;
				end If;

			Elsif  l_doc_type = 'AP' then
                                        l_related_link := 'N';
                                If Not create_ap_po_bdn_lines
                                        (p_packet_id      => p_packet_id
                                        ,p_bc_packet_id   => l_bc_packet_id
                                        ,p_burden_type    => 'SAME'
                                        ,P_entered_dr     => l_entered_dr
                                        ,P_entered_cr     => l_entered_cr
                                        ,P_period_name    => l_period_name
                                        ,p_doc_type       => l_doc_type
                                        ,p_related_link   => l_related_link
                                        ,p_exp_type       => l_exp_type
					,p_accounted_dr   => l_accounted_dr
					,p_accounted_cr   => l_accounted_cr
					,p_compiled_multiplier => l_compiled_multiplier
                                        ) then
                                        --RETURN FALSE;
					NULL;
                                end If;


 			END IF;

 		ELSIF l_burden_method  = 'DIFFERENT' and  l_bc_packet_id is NOT NULL then
 			IF l_doc_type  IN ( 'CC_C_PAY','CC_P_PAY','CC','CC_C_CO','CC_P_CO' )  THEN
                                If l_parent_bc_packet_id = -1 then
                                        l_related_link := 'Y';
                                        l_commitment_rows_flag := 'N';
                                        l_pkt_rows_flag  := 'N';
                                        -- open the cursor check whether the records exits  if so
                                        -- update the flag to y else check at the pa bc packet cursor
                                        -- if no rows found at pabc packets then mark the transaction
                                        -- as failed
                                        OPEN po_amount(l_doc_distribution_id
                                                        ,l_bc_packet_id
                                                        ,l_doc_header_id
							,l_doc_type);
                                        FETCH po_amount into l_period_name,l_entered_dr,l_entered_cr
                                                ,l_accounted_dr,l_accounted_cr,l_exp_type,l_compiled_multiplier;
                                        If po_amount%FOUND then
                                                l_commitment_rows_flag  := 'Y';
                                        End if;
                                        CLOSE po_amount;

                                        If l_commitment_rows_flag  = 'N' then
                                           OPEN pkt_po_amount(l_doc_distribution_id
                                                                ,l_bc_packet_id
                                                                ,l_doc_header_id
								,l_doc_type);
                                           FETCH pkt_po_amount into l_period_name,l_entered_dr,l_entered_cr
                                                ,l_accounted_dr,l_accounted_cr,l_exp_type,l_compiled_multiplier;
                                            If pkt_po_amount%FOUND then
                                                  l_pkt_rows_flag := 'Y';
                                            Else
                                                  l_status_flag := 'Y';
                                                  GOTO END_OF_BURDEN;
                                            End if;
                                            CLOSE pkt_po_amount;
                                        End if;

                                        If l_commitment_rows_flag  = 'Y' then
                                           OPEN po_amount(l_doc_distribution_id
                                                        ,l_bc_packet_id
                                                        ,l_doc_header_id
							,l_doc_type);
                                           LOOP
                                                FETCH po_amount into l_period_name
                                                        ,l_entered_dr,l_entered_cr
                                                        ,l_accounted_dr,l_accounted_cr,l_exp_type,l_compiled_multiplier;
                                                EXIT when po_amount%NOTFOUND;
                                                PA_FUNDS_CONTROL_PKG.log_message
                                                (p_msg_token1 => 'amount found from commitment');
                                                If Not create_ap_po_bdn_lines
                                                        (p_packet_id      => p_packet_id
                                                        ,p_bc_packet_id   => l_bc_packet_id
                                                        ,p_burden_type    => 'DIFFERENT'
                                                        ,P_entered_dr     => l_entered_dr
                                                        ,P_entered_cr     => l_entered_cr
                                                        ,P_period_name    => l_period_name
                                                        ,p_doc_type       => l_doc_type
                                                        ,p_related_link   => l_related_link
                                                        ,p_exp_type       => l_exp_type
                                                        ,p_accounted_dr   => l_accounted_dr
                                                        ,p_accounted_cr   => l_accounted_cr
							,p_compiled_multiplier => l_compiled_multiplier
                                                        ) then
                                                        --RETURN FALSE;
                                                        NULL;
                                                End if;
                                            END LOOP;
                                            CLOSE po_amount;
                                         End if;
                                        If l_pkt_rows_flag  = 'Y' then
                                           OPEN pkt_po_amount(l_doc_distribution_id
                                                                ,l_bc_packet_id
                                                                ,l_doc_header_id
								,l_doc_type);
                                           LOOP
                                                FETCH pkt_po_amount into l_period_name
                                                        ,l_entered_dr,l_entered_cr
                                                        ,l_accounted_dr,l_accounted_cr,l_exp_type,l_compiled_multiplier;
                                                EXIT when pkt_po_amount%NOTFOUND;
                                                If Not create_ap_po_bdn_lines
                                                        (p_packet_id      => p_packet_id
                                                        ,p_bc_packet_id   => l_bc_packet_id
                                                        ,p_burden_type    => 'DIFFERENT'
                                                        ,P_entered_dr     => l_entered_dr
                                                        ,P_entered_cr     => l_entered_cr
                                                        ,P_period_name    => l_period_name
                                                        ,p_doc_type       => l_doc_type
                                                        ,p_related_link   => l_related_link
                                                        ,p_exp_type       => l_exp_type
                                                        ,p_accounted_dr   => l_accounted_dr
                                                        ,p_accounted_cr   => l_accounted_cr
							,p_compiled_multiplier => l_compiled_multiplier
                                                        ) then
                                                        --RETURN FALSE;
                                                        NULL;
                                                End if;
                                            END LOOP;
                                            CLOSE pkt_po_amount;
                                         End if;
                                Else
                                        PA_FUNDS_CONTROL_PKG.log_message
                                        (p_msg_token1 => 'not related link = N ');
                                        l_related_link := 'N';

                                End if;
                                If l_related_link = 'N'  then
                                        If Not create_ap_po_bdn_lines
                                        (p_packet_id      => p_packet_id
                                        ,p_bc_packet_id   => l_bc_packet_id
                                        ,p_burden_type    => 'DIFFERENT'
                                        ,P_entered_dr     => l_entered_dr
                                        ,P_entered_cr     => l_entered_cr
                                        ,P_period_name    => l_period_name
                                        ,p_doc_type       => l_doc_type
                                        ,p_related_link   => l_related_link
                                        ,p_exp_type       => l_exp_type
                                        ,p_accounted_dr   => l_accounted_dr
                                        ,p_accounted_cr   => l_accounted_cr
					,p_compiled_multiplier => l_compiled_multiplier
                                        ) then
                                        --RETURN FALSE;
                                        NULL;
                                        end If;
                                End if;



			Elsif  l_doc_type = 'REQ' then
                                If l_parent_bc_packet_id = -1 then
                                        l_related_link := 'Y';
                                        l_commitment_rows_flag := 'N';
                                        l_pkt_rows_flag  := 'N';
                                        -- open the cursor check whether the records exits  if so
                                        -- update the flag to y else check at the pa bc packet cursor
                                        -- if no rows found at pabc packets then mark the transaction
                                        -- as failed
                                        OPEN po_amount(l_doc_distribution_id
							,l_bc_packet_id
							,l_doc_header_id
							,l_doc_type);
                                        FETCH po_amount into l_period_name,l_entered_dr,l_entered_cr
                                                ,l_accounted_dr,l_accounted_cr,l_exp_type,l_compiled_multiplier;
                                        If po_amount%FOUND then
                                                l_commitment_rows_flag  := 'Y';
                                        End if;
                                        CLOSE po_amount;

                                        If l_commitment_rows_flag  = 'N' then
                                           OPEN pkt_po_amount(l_doc_distribution_id
								,l_bc_packet_id
								,l_doc_header_id
								,l_doc_type);
                                           FETCH pkt_po_amount into l_period_name,l_entered_dr,l_entered_cr
                                                ,l_accounted_dr,l_accounted_cr,l_exp_type,l_compiled_multiplier;
                                            If pkt_po_amount%FOUND then
                                                  l_pkt_rows_flag := 'Y';
                                            Else
                                                  l_status_flag := 'Y';
                                                  GOTO END_OF_BURDEN;
                                            End if;
                                            CLOSE pkt_po_amount;
                                        End if;

                                        If l_commitment_rows_flag  = 'Y' then
                                           OPEN po_amount(l_doc_distribution_id
                                                        ,l_bc_packet_id
                                                        ,l_doc_header_id
							,l_doc_type);
                                           LOOP
                                                FETCH po_amount into l_period_name
                                                        ,l_entered_dr,l_entered_cr
                                                        ,l_accounted_dr,l_accounted_cr,l_exp_type,l_compiled_multiplier;
                                                EXIT when po_amount%NOTFOUND;
                                                PA_FUNDS_CONTROL_PKG.log_message
                                                (p_msg_token1 => 'amount found from commitment');
                                                If Not create_ap_po_bdn_lines
                                                        (p_packet_id      => p_packet_id
                                                        ,p_bc_packet_id   => l_bc_packet_id
                                                        ,p_burden_type    => 'DIFFERENT'
                                                        ,P_entered_dr     => l_entered_dr
                                                        ,P_entered_cr     => l_entered_cr
                                                        ,P_period_name    => l_period_name
                                                        ,p_doc_type       => l_doc_type
                                                        ,p_related_link   => l_related_link
                                                        ,p_exp_type       => l_exp_type
                                                        ,p_accounted_dr   => l_accounted_dr
                                                        ,p_accounted_cr   => l_accounted_cr
							,p_compiled_multiplier => l_compiled_multiplier
                                                        ) then
                                                        --RETURN FALSE;
                                                        NULL;
                                                End if;
                                            END LOOP;
                                            CLOSE po_amount;
                                         End if;
                                        If l_pkt_rows_flag  = 'Y' then
                                           OPEN pkt_po_amount(l_doc_distribution_id
                                                                ,l_bc_packet_id
                                                                ,l_doc_header_id
								,l_doc_type);
                                           LOOP
                                                FETCH pkt_po_amount into l_period_name
                                                        ,l_entered_dr,l_entered_cr
                                                        ,l_accounted_dr,l_accounted_cr,l_exp_type,l_compiled_multiplier;
                                                EXIT when pkt_po_amount%NOTFOUND;
                                                PA_FUNDS_CONTROL_PKG.log_message
                                                (p_msg_token1 => 'amount found from packets');
                                                If Not create_ap_po_bdn_lines
                                                        (p_packet_id      => p_packet_id
                                                        ,p_bc_packet_id   => l_bc_packet_id
                                                        ,p_burden_type    => 'DIFFERENT'
                                                        ,P_entered_dr     => l_entered_dr
                                                        ,P_entered_cr     => l_entered_cr
                                                        ,P_period_name    => l_period_name
                                                        ,p_doc_type       => l_doc_type
                                                        ,p_related_link   => l_related_link
                                                        ,p_exp_type       => l_exp_type
                                                        ,p_accounted_dr   => l_accounted_dr
                                                        ,p_accounted_cr   => l_accounted_cr
							,p_compiled_multiplier => l_compiled_multiplier
                                                        ) then
                                                        --RETURN FALSE;
                                                        NULL;
                                                End if;
                                            END LOOP;
                                            CLOSE pkt_po_amount;
                                         End if;
                                Else
                                        PA_FUNDS_CONTROL_PKG.log_message
                                        (p_msg_token1 => ' not related link = N ');
                                        l_related_link := 'N';

                                End if;
                                If l_related_link = 'N'  then
                                        If Not create_ap_po_bdn_lines
                                        (p_packet_id      => p_packet_id
                                        ,p_bc_packet_id   => l_bc_packet_id
                                        ,p_burden_type    => 'DIFFERENT'
                                        ,P_entered_dr     => l_entered_dr
                                        ,P_entered_cr     => l_entered_cr
                                        ,P_period_name    => l_period_name
                                        ,p_doc_type       => l_doc_type
                                        ,p_related_link   => l_related_link
                                        ,p_exp_type       => l_exp_type
                                        ,p_accounted_dr   => l_accounted_dr
                                        ,p_accounted_cr   => l_accounted_cr
					,p_compiled_multiplier => l_compiled_multiplier
                                        ) then
                                        --RETURN FALSE;
                                        NULL;
                                        end If;
                                End if;



                        Elsif  l_doc_type = 'PO' then
                                If l_parent_bc_packet_id = -1  THEN
                                        l_related_link := 'Y';
                                        l_commitment_rows_flag := 'N';
                                        l_pkt_rows_flag  := 'N';
                                        -- open the cursor check whether the records exits  if so
                                        -- update the flag to y else check at the pa bc packet cursor
                                        -- if no rows found at pabc packets then mark the transaction
                                        -- as failed
                                        OPEN po_amount(l_doc_distribution_id
						      ,l_bc_packet_id
						      ,l_doc_header_id
						      ,l_doc_type);
                                        FETCH po_amount into l_period_name,l_entered_dr,l_entered_cr
                                                ,l_accounted_dr,l_accounted_cr,l_exp_type,l_compiled_multiplier;
                                                If po_amount%FOUND THEN
                                                        l_commitment_rows_flag := 'Y';
                                                End if;
                                        CLOSE po_amount;
                                        If l_commitment_rows_flag = 'N' then
                                                OPEN pkt_po_amount(l_doc_distribution_id
                                                      		  ,l_bc_packet_id
                                                      		  ,l_doc_header_id
								  ,l_doc_type);
                                                FETCH pkt_po_amount into l_period_name,l_entered_dr,l_entered_cr
                                                      ,l_accounted_dr,l_accounted_cr,l_exp_type,l_compiled_multiplier;
                                                If pkt_po_amount%FOUND THEN
                                                        l_pkt_rows_flag := 'Y';
                                                Else
                                                        l_status_flag := 'Y';
                                                        GOTO END_OF_BURDEN;
                                                End if;
                                                CLOSE pkt_po_amount;
                                        End if;


                                        If l_commitment_rows_flag = 'Y' then

                                             OPEN po_amount(l_doc_distribution_id
                                                      	   ,l_bc_packet_id
                                                      	   ,l_doc_header_id
							   ,l_doc_type);
                                             LOOP
                                                FETCH po_amount into l_period_name
                                                        ,l_entered_dr,l_entered_cr
                                                        ,l_accounted_dr,l_accounted_cr,l_exp_type,l_compiled_multiplier;
                                                EXIT when po_amount%NOTFOUND;
                                                PA_FUNDS_CONTROL_PKG.log_message
                                                (p_msg_token1 => 'amount found from commitments');
                                                If Not create_ap_po_bdn_lines
                                                        (p_packet_id      => p_packet_id
                                                        ,p_bc_packet_id   => l_bc_packet_id
                                                        ,p_burden_type    => 'DIFFERENT'
                                                        ,P_entered_dr     => l_entered_dr
                                                        ,P_entered_cr     => l_entered_cr
                                                        ,P_period_name    => l_period_name
                                                        ,p_doc_type       => l_doc_type
                                                        ,p_related_link   => l_related_link
                                                        ,p_exp_type       => l_exp_type
                                                        ,p_accounted_dr   => l_accounted_dr
                                                        ,p_accounted_cr   => l_accounted_cr
							,p_compiled_multiplier => l_compiled_multiplier
                                                        ) then
                                                        NULL;
                                                        --RETURN FALSE;
                                                End if;
                                             END LOOP;
                                             CLOSE po_amount;
                                        End if;
                                        If l_pkt_rows_flag = 'Y' then

                                             OPEN pkt_po_amount(l_doc_distribution_id
                                                      		,l_bc_packet_id
                                                      		,l_doc_header_id
								,l_doc_type);
                                             LOOP
                                                FETCH pkt_po_amount into l_period_name
                                                        ,l_entered_dr,l_entered_cr
                                                        ,l_accounted_dr,l_accounted_cr,l_exp_type,l_compiled_multiplier;
                                                EXIT when pkt_po_amount%NOTFOUND;
                                                PA_FUNDS_CONTROL_PKG.log_message
                                                (p_msg_token1 => 'amount found from commitments');
                                                If Not create_ap_po_bdn_lines
                                                        (p_packet_id      => p_packet_id
                                                        ,p_bc_packet_id   => l_bc_packet_id
                                                        ,p_burden_type    => 'DIFFERENT'
                                                        ,P_entered_dr     => l_entered_dr
                                                        ,P_entered_cr     => l_entered_cr
                                                        ,P_period_name    => l_period_name
                                                        ,p_doc_type       => l_doc_type
                                                        ,p_related_link   => l_related_link
                                                        ,p_exp_type       => l_exp_type
                                                        ,p_accounted_dr   => l_accounted_dr
                                                        ,p_accounted_cr   => l_accounted_cr
							,p_compiled_multiplier => l_compiled_multiplier
                                                        ) then
                                                        NULL;
                                                        --RETURN FALSE;
                                                End if;
                                             END LOOP;
                                             CLOSE pkt_po_amount;
                                        End if;

                                Else
                                         PA_FUNDS_CONTROL_PKG.log_message
                                        (p_msg_token1 => ' Not invoice based po ');
                                        l_related_link := 'N';

                                End if;

				If l_related_link = 'N'  then
                                	If Not create_ap_po_bdn_lines
                                        (p_packet_id      => p_packet_id
                                        ,p_bc_packet_id   => l_bc_packet_id
                                        ,p_burden_type    => 'DIFFERENT'
                                        ,P_entered_dr     => l_entered_dr
                                        ,P_entered_cr     => l_entered_cr
                                        ,P_period_name    => l_period_name
                                        ,p_doc_type       => l_doc_type
                                        ,p_related_link   => l_related_link
                                        ,p_exp_type       => l_exp_type
					,p_accounted_dr   => l_accounted_dr
					,p_accounted_cr   => l_accounted_cr
					,p_compiled_multiplier => l_compiled_multiplier
                                        ) then
                                        --RETURN FALSE;
					NULL;
                                	end If;
				End if;

                        Elsif  l_doc_type = 'AP' then
				 PA_FUNDS_CONTROL_PKG.log_message
				(p_msg_token1 => ' doc type is ap related  link N');
                                   l_related_link := 'N';
				If l_related_link = 'N' then
                                	If Not create_ap_po_bdn_lines
                                        (p_packet_id      => p_packet_id
                                        ,p_bc_packet_id   => l_bc_packet_id
                                        ,p_burden_type    => 'DIFFERENT'
                                        ,P_entered_dr     => l_entered_dr
                                        ,P_entered_cr     => l_entered_cr
                                        ,P_period_name    => l_period_name
                                        ,p_doc_type       => l_doc_type
                                        ,p_related_link   => l_related_link
                                        ,p_exp_type       => l_exp_type
					,p_accounted_dr   => l_accounted_dr
					,p_accounted_cr   => l_accounted_cr
					,p_compiled_multiplier => l_compiled_multiplier
                                        ) then
                                        --RETURN FALSE;
					NULL;
                                	end If;
				End if;

 			END IF;  --- for document type

 		END IF; --- for  burden method type


	   <<END_OF_BURDEN>>
		PA_FUNDS_CONTROL_PKG.log_message(p_msg_token1 => 'End of Burden Process');
		-- if the burden rows are not found for the po based on requision
		-- or invoice based on purchase orders then update the transaction
		-- with error status transaction failed to populate burden cost
		If l_status_flag = 'Y' and l_related_link = 'Y' then
 			PA_FUNDS_CONTROL_PKG.result_status_code_update
				(p_packet_id => p_packet_id,
                                 p_bc_packet_id => l_bc_packet_id,
                                 p_result_code   => 'F114',
                                 p_res_result_code => 'F114',
                                 p_res_grp_result_code => 'F114',
                                 p_task_result_code => 'F114',
                                 p_top_task_result_code => 'F114',
                                 p_project_result_code => 'F114',
                                 p_proj_acct_result_code => 'F114');
			l_status_flag := 'N';
			l_related_link := 'N';
			If po_amount%isopen then
				close po_amount;
			end if;
			If pkt_po_amount%isopen then
				close pkt_po_amount;
			End if;
		End if;
 	END LOOP;
 	CLOSE burden_type;

        ELSIF p_calling_module in ('DISTBTC','TRXNIMPORT','DISTVIADJ','DISTERADJ','TRXIMPORT','DISTCWKST') then
        ---------------------------------------------------------------------------------------
        -- pick all the records where the parent bc packet id is minus one (-1)
        -- and populate the burden lines with document type as EXP
        -- check if the burden display method is same or different
        -- if the calling module is TRXNIMPORT then burden components should be calculated
        -- as the funds check process is called before the creation of cdls and eis
        -- if the calling module is DISTERADJ, OR DISTVIADJ then if the bdn is on same line
        -- burden amount can be get it from cdl as the funds check process is called after the
        -- creation of cdls
        ----------------------------------------------------------------------------------------
		trxn_dister_burden_lines
          		(p_packet_id  		=> p_packet_id
           		 ,p_calling_module  	=>p_calling_module);

	END IF;
	IF p_calling_module in ('DISTBTC','TRXNIMPORT','DISTVIADJ','DISTERADJ','GL','TRXIMPORT','DISTCWKST') then
		-- update the bc packets set the parent bc packet id to null
		-- after derving the burden components for the raw lines
		UPDATE pa_bc_packets
		SET parent_bc_packet_id = null
		WHERE packet_id = p_packet_id
		AND   parent_bc_packet_id = -1;
	END IF;

	/* CWK changes for patchset PAM */
	--update the cwk summary record flag info for contingent worker transactions only
	--for the first occurance of the record ie. project, task and po line
	IF p_calling_module = 'GL' Then

                /* 3703180 */
		IF g_cwk_po_unreserve = 'Y' THEN
		   update_cwk_po_burden(p_packet_id) ;
		END IF ;

		pa_funds_control_pkg.log_message(p_msg_token1=>'Calling upd_cwk_attributes for Summary record flag');
		pa_funds_control_pkg1.upd_cwk_attributes(
		        p_calling_module  => p_calling_module
                        ,p_packet_id      => p_packet_id
                        ,p_mode           => 'R'
                        ,p_reference      => 'UPD_FLAG'
                        ,x_return_status  => x_return_status
			);
		 pa_funds_control_pkg.log_message(p_msg_token1=>'end of upd_cwk_attributes for Summary record flag'||
			'RetSts['||x_return_status||']');


	End If;
 	--re set the error stack
 	PA_DEBUG.reset_err_stack;
	commit; -- to end an active autonmous transaction
	return;

 EXCEPTION
 	WHEN OTHERS THEN
 		If  burden_type%ISOPEN then
 			close burden_type;
 		End if;

 		PA_FUNDS_CONTROL_PKG.log_message
		(p_msg_token1 => 'PA_FUNDS_CONTROL.populate_burden_cost UNEXPECTED ERROR');
		--error msg : 'F140 = Funds check failed because of insert burden cost'
 		PA_FUNDS_CONTROL_PKG.result_status_code_update
			( p_status_code=> 'T',
             	      	p_result_code              => 'F140',
             		p_res_result_code          => 'F140',
             		p_res_grp_result_code      => 'F140',
             		p_task_result_code         => 'F140',
             		p_top_task_result_code     => 'F140',
             		p_project_result_code        => 'F140',
			p_proj_acct_result_code    => 'F140',
             		p_packet_id                => p_packet_id
  			);

                        If po_amount%isopen then
                                close po_amount;
                        end if;
                        If pkt_po_amount%isopen then
                                close pkt_po_amount;
                        End if;

 		x_return_status := 'T';
                PA_FUNDS_CONTROL_PKG.log_message
			(p_msg_token1 => 'failed in populate burden cost api SQLERR :'||sqlcode||sqlerrm);
		PA_FUNDS_CONTROL_PKG.log_message
			(p_error_msg => sqlcode ||sqlerrm);
		--commit;
 		Raise;
END Populate_burden_cost;

----------------------------------------------------------------------------------------
-- This Api gets the Start and End date based on amount type and boundary code
-- set up for the project. funds availability will be checked based on this
-- start and end dates.
-- The following combinations are supported
-- Amount Type       Boundary Code
-- ==============   ==============
-- Project           Project to Date
-- Project           Year to Date
-- Project           Period to Date
-- Year              Year to Date
-- Year              Period to Date
-- Period            Period to Date
-- ========================================
PROCEDURE setup_start_end_date (
        p_packet_id                IN       NUMBER,
        p_bc_packet_id             IN       NUMBER,
        p_project_id               IN       pa_bc_packets.project_id%TYPE,
        p_budget_version_id        IN       pa_bc_packets.budget_version_id%TYPE,
        p_time_phase_type_code     IN       pa_budget_entry_methods.time_phased_type_code%TYPE,
        p_expenditure_item_date    IN       DATE,
        p_amount_type              IN       pa_budgetary_control_options.amount_type%TYPE,
        p_boundary_code            IN       pa_budgetary_control_options.boundary_code%TYPE,
        p_set_of_books_id          IN       pa_bc_packets.set_of_books_id%TYPE,
        x_start_date               OUT      NOCOPY DATE,
        x_end_date                 OUT      NOCOPY DATE,
        x_error_code               OUT      NOCOPY NUMBER,
        x_err_buff                 OUT      NOCOPY VARCHAR2,
        x_return_status            OUT      NOCOPY VARCHAR2,
        x_result_code              OUT      NOCOPY VARCHAR2 ) IS


        l_project_start_date     DATE;
        l_project_end_date       DATE;
        l_year_start_date        DATE;
        l_year_end_date          DATE;
        l_pa_period_start_date   DATE;
        l_pa_period_end_date     DATE;
        l_gl_period_start_date   DATE;
        l_gl_period_end_date     DATE;
        l_dr_period_start_date   DATE;
        l_dr_period_end_date     DATE;
        l_gs_start_date          DATE;
        l_gs_end_date            DATE;
        l_gb_end_date            DATE;
        l_pa_date                DATE;
        l_bal_end_date           DATE;
	l_debug_mode		 VARCHAR2(10);
BEGIN

        PA_FUNDS_CONTROL_PKG.log_message(p_msg_token1 => 'Inside the setup start and end date api');

        -- Inialize the error stack
        PA_DEBUG.init_err_stack('PA_FUNDS_CONTROL_PKG1.setup_start_end_dates');
        -- set the return status to success
        x_return_status := 'S';

        fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
        l_debug_mode := NVL(l_debug_mode, 'N');

        PA_DEBUG.SET_PROCESS( x_process => 'PLSQL'
                             ,x_write_file     => 'LOG'
                             ,x_debug_mode      => l_debug_mode
                             );
        PA_FUNDS_CONTROL_PKG.log_message(p_msg_token1 =>'amount_type ['||p_amount_type||']boundary_code ['
			||p_boundary_code||'] time_phase_type_code['||p_time_phase_type_code||']' );

        PA_FUNDS_CONTROL_PKG.log_message(p_msg_token1 =>'p_set_of_books_id ['||p_set_of_books_id||']p_expenditure_item_date ['
			||p_expenditure_item_date||'] p_budget_version_id['||p_budget_version_id||']' );


        x_error_code := 0;  -- initialize error code
        IF (    p_time_phase_type_code = 'N'
                OR p_amount_type = 'PJTD'
                OR p_boundary_code = 'J' ) THEN
                g_error_stage := 'Project Start and End Date';
                PA_FUNDS_CONTROL_PKG.log_message(p_msg_token1 =>'Project Start and End Date');
                SELECT start_date,
                        completion_date
                INTO    l_project_start_date,
                        l_project_end_date
                FROM pa_projects_all
                WHERE project_id = p_project_id;

		IF p_time_phase_type_code in ('P','G') and l_project_start_date is NULL then
                        SELECT MIN ( start_date )
                        INTO l_project_start_date
                        FROM pa_bc_balances
                        WHERE budget_version_id = p_budget_version_id
                        AND project_id = p_project_id
                        AND balance_type = 'BGT';

		End if;

                IF ( l_project_end_date IS NULL ) THEN
                        SELECT MAX ( end_date )
                        INTO l_bal_end_date
                        FROM pa_bc_balances
                        WHERE budget_version_id = p_budget_version_id
                        AND project_id = p_project_id
                        AND balance_type = 'BGT';

                        IF p_expenditure_item_date  > l_bal_end_date THEN
                                l_project_end_date := p_expenditure_item_date ;
                        ELSE
                                l_project_end_date := l_bal_end_date ;
                        END IF;
                END IF;
        END IF;

        -- get Financial year start and end dates

        IF (    p_amount_type = 'YTD'
                OR p_boundary_code = 'Y' ) THEN
                g_error_stage := 'Year Start and End Date';
                PA_FUNDS_CONTROL_PKG.log_message(p_msg_token1 =>'Year Start and End Date');

                SELECT gps.year_start_date
                INTO l_year_start_date
                FROM gl_period_statuses gps
                WHERE gps.application_id = 101
                AND gps.set_of_books_id = p_set_of_books_id
                AND p_expenditure_item_date BETWEEN gps.start_date AND gps.end_date
                AND gps.adjustment_period_flag = 'N';

                l_year_end_date := ADD_MONTHS ( l_year_start_date, 12 ) - 1;
        END IF;

        -- get period start and end dates
        PA_FUNDS_CONTROL_PKG.log_message(p_msg_token1 =>'get period start and end dates');

        IF p_time_phase_type_code = 'G' THEN
                                    -- FOR GL period
                g_error_stage := 'Time Phase = G';
                PA_FUNDS_CONTROL_PKG.log_message(p_msg_token1 =>'Time Phase = G');
                SELECT TRUNC ( gps.start_date ),
                        TRUNC ( gps.end_date )
                INTO    l_gl_period_start_date,
                        l_gl_period_end_date
                FROM gl_period_statuses gps
                WHERE gps.application_id = 101
                AND gps.set_of_books_id = p_set_of_books_id
                AND p_expenditure_item_date BETWEEN gps.start_date AND gps.end_date
                AND gps.adjustment_period_flag = 'N';
        ELSIF p_time_phase_type_code = 'P' THEN
                                    -- FOR PA period
                g_error_stage := 'Time Phase = P';
                PA_FUNDS_CONTROL_PKG.log_message(p_msg_token1 =>'Time Phase =  P');
                SELECT TRUNC ( start_date ),
                        TRUNC ( end_date )
                INTO    l_pa_period_start_date,
                        l_pa_period_end_date
                FROM pa_periods gpa
                WHERE p_expenditure_item_date BETWEEN gpa.start_date AND gpa.end_date;
        ELSIF p_time_phase_type_code = 'R' THEN
                                   -- FOR DATE RANGE
                g_error_stage := 'Time Phase R';
                 PA_FUNDS_CONTROL_PKG.log_message(p_msg_token1 =>'Time Phase =  R');
                SELECT TRUNC ( MAX ( start_date ))
                INTO l_dr_period_start_date
                FROM pa_bc_balances
                WHERE project_id = p_project_id
                AND budget_version_id = p_budget_version_id
                AND balance_type = 'BGT'
                AND start_date <= p_expenditure_item_date;

                SELECT TRUNC ( MIN ( end_date ))
                INTO l_dr_period_end_date
                FROM pa_bc_balances
                WHERE project_id = p_project_id
                AND budget_version_id = p_budget_version_id
                AND balance_type = 'BGT'
                AND end_date >= p_expenditure_item_date;
        END IF;

        -- Find the p_start_date and x_end_date

        IF p_time_phase_type_code = 'N' THEN   -- for no time phase
                IF (    p_amount_type <> 'PJTD'
                        OR p_boundary_code <> 'J' ) THEN
                        -- Error msg : F123 = Invalid Amount type and Boundary code for No time phase
                        PA_FUNDS_CONTROL_PKG.log_message(p_msg_token1 =>'Invalid amount type boundary code');

                        x_result_code := 'F123';
                        x_return_status := 'F';
			PA_DEBUG.reset_err_stack;
                        Return;

                ELSE
                        x_start_date := l_project_start_date;
                        x_end_date := l_project_end_date;
                END IF;
        ELSIF p_time_phase_type_code IN ( 'P', 'G', 'R' ) THEN
                --Project to Date Start and End Date Calculations
                -- start date calc - PJTD

                IF p_amount_type = 'PJTD' THEN
                        IF p_time_phase_type_code = 'P' THEN
                                g_error_stage := 'PJTD- P';
                                PA_FUNDS_CONTROL_PKG.log_message(p_msg_token1 =>' PJTD- P');
                                BEGIN
                                        SELECT TRUNC ( start_date )
                                        INTO l_gs_start_date
                                        FROM pa_periods gpa
                                        WHERE l_project_start_date BETWEEN gpa.start_date AND gpa.end_date;
                                EXCEPTION
                                        WHEN NO_DATA_FOUND THEN
                                                SELECT TRUNC ( MIN ( start_date ))
                                                INTO l_gs_start_date
                                                FROM pa_bc_balances
                                                WHERE project_id = p_project_id
                                                AND budget_version_id = p_budget_version_id
                                                AND balance_type = 'BGT';
                                END;
                        ELSIF p_time_phase_type_code = 'G' THEN
                                g_error_stage := 'PJTD-G';
                                PA_FUNDS_CONTROL_PKG.log_message(p_msg_token1 =>'PJTD-G');
                                BEGIN
                                        SELECT TRUNC ( gps.start_date )
                                        INTO l_gs_start_date
                                        FROM gl_period_statuses gps
                                        WHERE gps.application_id = 101
                                        AND gps.set_of_books_id = p_set_of_books_id
                                        AND l_project_start_date BETWEEN gps.start_date AND gps.end_date
                                        AND gps.adjustment_period_flag = 'N';
                                EXCEPTION
                                        WHEN NO_DATA_FOUND THEN
                                                SELECT TRUNC ( MIN ( start_date ))
                                                INTO l_gs_start_date
                                                FROM pa_bc_balances
                                                WHERE project_id = p_project_id
                                                AND budget_version_id = p_budget_version_id
                                                AND balance_type = 'BGT';
                                END;
                        ELSIF p_time_phase_type_code = 'R' THEN
                                g_error_stage := 'PJTD-R';
                                PA_FUNDS_CONTROL_PKG.log_message(p_msg_token1 =>'PJTD-R');
                                SELECT TRUNC ( MIN ( start_date ))
                                INTO l_gs_start_date
                                FROM pa_bc_balances
                                WHERE project_id = p_project_id
                                AND budget_version_id = p_budget_version_id
                                AND balance_type = 'BGT';

                        END IF;
                        IF l_gs_start_date < l_project_start_date THEN
                                x_start_date := l_gs_start_date;
                        ELSE
                                x_start_date := l_project_start_date;
                        END IF;

                        -- end date calc for PJTD - Project
                         PA_FUNDS_CONTROL_PKG.log_message(p_msg_token1 =>' end date calc for PJTD ');

                        IF p_boundary_code = 'J' THEN
                                IF p_time_phase_type_code = 'P' THEN
                                        g_error_stage := 'PJTD_J-P';
                                        PA_FUNDS_CONTROL_PKG.log_message(p_msg_token1 =>'PJTD_J-P');
                                        BEGIN
                                                SELECT TRUNC ( end_date )
                                                INTO l_gs_end_date
                                                FROM pa_periods gpa
                                                WHERE l_project_end_date BETWEEN gpa.start_date AND gpa.end_date;
                                        EXCEPTION
                                                WHEN NO_DATA_FOUND THEN
                                                        SELECT TRUNC ( MAX ( end_date ))
                                                        INTO l_gs_end_date
                                                        FROM pa_bc_balances
                                                        WHERE project_id = p_project_id
                                                        AND budget_version_id = p_budget_version_id
                                                        AND balance_type = 'BGT';
                                        END;
                                        IF l_gs_end_date > l_project_end_date THEN
                                                x_end_date := l_gs_end_date;
                                        ELSE
                                                x_end_date := l_project_end_date;
                                        END IF;
                                ELSIF p_time_phase_type_code = 'G' THEN
                                        g_error_stage := 'PJTD_J-G';
                                         PA_FUNDS_CONTROL_PKG.log_message(p_msg_token1 =>'PJTD_J-G');
                                        BEGIN
                                                SELECT TRUNC ( gps.end_date )
                                                INTO l_gs_end_date
                                                FROM gl_period_statuses gps
                                                WHERE gps.application_id = 101
                                                AND gps.set_of_books_id = p_set_of_books_id
                                                AND l_project_end_date BETWEEN gps.start_date AND gps.end_date
                                                AND gps.adjustment_period_flag = 'N';
                                        EXCEPTION
                                                WHEN NO_DATA_FOUND THEN
                                                        SELECT TRUNC ( MAX ( end_date ))
                                                        INTO l_gs_end_date
                                                        FROM pa_bc_balances
                                                        WHERE project_id = p_project_id
                                                        AND budget_version_id = p_budget_version_id
                                                        AND balance_type = 'BGT';
                                        END;
                                        IF l_gs_end_date > l_project_end_date THEN
                                                x_end_date := l_gs_end_date;
                                        ELSE
                                                x_end_date := l_project_end_date;
                                        END IF;
                                ELSIF p_time_phase_type_code = 'R' THEN
                                        g_error_stage := 'PJTD_J-R';
                                         PA_FUNDS_CONTROL_PKG.log_message(p_msg_token1 =>'PJTD_J-R');
                                        x_end_date := l_project_end_date;
                                END IF;
                        -- end date calc for PJTD - Year

                        ELSIF p_boundary_code = 'Y' THEN
                                IF p_time_phase_type_code = 'P' THEN
                                        g_error_stage := 'PJTD-Y-P';
                                        PA_FUNDS_CONTROL_PKG.log_message(p_msg_token1 =>'PJTD-Y-P');
                                        BEGIN
                                                SELECT p.end_date
                                                INTO l_gs_end_date
                                                FROM pa_periods p
                                                WHERE l_year_end_date BETWEEN p.start_date AND p.end_date;
                                                x_end_date := l_gs_end_date;
                                        EXCEPTION
                                                WHEN NO_DATA_FOUND THEN
                                                        x_end_date := l_year_end_date;
                                        END;
                                ELSIF p_time_phase_type_code = 'G' THEN
                                        g_error_stage := 'PJTD-Y-G';
                                        PA_FUNDS_CONTROL_PKG.log_message(p_msg_token1 =>'PJTD-Y-G');
                                        x_end_date := l_year_end_date;
                                ELSIF p_time_phase_type_code = 'R' THEN
                                        g_error_stage := 'PJTD-Y-R';
                                         PA_FUNDS_CONTROL_PKG.log_message(p_msg_token1 =>'PJTD-Y-R');
                                        x_end_date := l_year_end_date;
                                END IF;
                        -- end date calc for PJTD - period
                          PA_FUNDS_CONTROL_PKG.log_message(p_msg_token1 =>'end date calc for PJTD - period');

                        ELSIF p_boundary_code = 'P' THEN
                                g_error_stage := 'PJTD-P';
                                PA_FUNDS_CONTROL_PKG.log_message(p_msg_token1 =>'PJTD-P');
                                IF p_time_phase_type_code = 'P' THEN
                                        x_end_date := l_pa_period_end_date;
                                ELSIF p_time_phase_type_code = 'G' THEN
                                        x_end_date := l_gl_period_end_date;
                                ELSIF p_time_phase_type_code = 'R' THEN
                                        x_end_date := l_dr_period_end_date;
                                END IF;
                        ELSE  -- end date calc for PJTD - period
                                -- error msg : F124 = Invalid Boundary code for Project to Date
                                 PA_FUNDS_CONTROL_PKG.log_message
                                (p_msg_token1 =>'Invalid Boundary code for Project to Date');
                                x_result_code := 'F124';
                                x_return_status := 'F';
				PA_DEBUG.reset_err_stack;
                                Return;
                                NULL;
                        END IF;
                -- Year to Date - start and End date calculation
                -- start date calc - YTD
                 PA_FUNDS_CONTROL_PKG.log_message(p_msg_token1 =>'start date calc - YTD');

                ELSIF p_amount_type = 'YTD' THEN

                        IF p_time_phase_type_code = 'P' THEN
                                g_error_stage := 'YTD1-P';
                                PA_FUNDS_CONTROL_PKG.log_message(p_msg_token1 =>'YTD1-P');
                                BEGIN
                                        SELECT p.start_date
                                        INTO l_gs_start_date
                                        FROM pa_periods p
                                        WHERE l_year_start_date BETWEEN p.start_date AND p.end_date;
                                        x_start_date := l_gs_start_date;
                                EXCEPTION
                                        WHEN NO_DATA_FOUND THEN
                                                x_start_date := l_year_start_date;
                                END;
                        ELSIF p_time_phase_type_code = 'G' THEN
                                g_error_stage := 'YTD2-G';
                                PA_FUNDS_CONTROL_PKG.log_message
                                        (p_msg_token1 =>'YTD2-G');
                                x_start_date := l_year_start_date;
                        ELSIF p_time_phase_type_code = 'R' THEN
                                g_error_stage := 'YTD3-R';
                                PA_FUNDS_CONTROL_PKG.log_message
                                                (p_msg_token1 =>'YTD3-R');
                                x_start_date := l_year_start_date;
                        END IF;

                        -- end date calc for YTD - year
                        PA_FUNDS_CONTROL_PKG.log_message
                                        (p_msg_token1 =>'end date calc for YTD - year');
                        IF p_boundary_code = 'Y' THEN
                                IF p_time_phase_type_code = 'P' THEN
                                        g_error_stage := 'YTD-Y-P';
                                        PA_FUNDS_CONTROL_PKG.log_message
                                        (p_msg_token1 =>'YTD-Y-P');
                                        BEGIN
                                                SELECT p.end_date
                                                INTO l_gs_end_date
                                                FROM pa_periods p
                                                WHERE l_year_end_date BETWEEN p.start_date AND p.end_date;
                                                x_end_date := l_gs_end_date;
                                        EXCEPTION
                                                WHEN NO_DATA_FOUND THEN
                                                        x_end_date := l_year_end_date;
                                        END;
                                ELSIF p_time_phase_type_code = 'G' THEN
                                        g_error_stage := 'YTD-Y-G';
                                        PA_FUNDS_CONTROL_PKG.log_message
                                                (p_msg_token1 =>'YTD-Y-G');
                                        x_end_date := l_year_end_date;
                                ELSIF p_time_phase_type_code = 'R' THEN
                                        g_error_stage := 'YTD-Y-R';
                                        PA_FUNDS_CONTROL_PKG.log_message
                                                (p_msg_token1 =>'YTD-Y-R');
                                        x_end_date := l_year_end_date;
                                END IF;
                                -- end date calc for YTD - period
                        ELSIF p_boundary_code = 'P' THEN
                                g_error_stage := 'YTD-P';
                                 PA_FUNDS_CONTROL_PKG.log_message
                                        (p_msg_token1 => 'YTD-P');
                                IF p_time_phase_type_code = 'P' THEN
                                        x_end_date := l_pa_period_end_date;
                                ELSIF p_time_phase_type_code = 'G' THEN
                                        x_end_date := l_gl_period_end_date;
                                ELSIF p_time_phase_type_code = 'R' THEN
                                        x_end_date := l_dr_period_end_date;
                                END IF;

                        ELSE
                                -- Error msg : F125 = Invalid boundary code for YTD
                                 PA_FUNDS_CONTROL_PKG.log_message
                                        (p_msg_token1 =>'Invalid boundary code for YTD');
                                x_result_code := 'F125';
                                x_return_status := 'F';
				PA_DEBUG.reset_err_stack;
                                Return;
                                NULL;

                        END IF;
                        --For Period to Date Period

                ELSIF p_amount_type = 'PTD' THEN
                        IF p_boundary_code = 'P' THEN
                                g_error_stage := 'PTD-P';
                                PA_FUNDS_CONTROL_PKG.log_message(p_msg_token1 =>'PTD-P');
                                IF p_time_phase_type_code = 'P' THEN
                                        x_start_date := l_pa_period_start_date;
                                        x_end_date := l_pa_period_end_date;
                                ELSIF p_time_phase_type_code = 'G' THEN
                                        x_start_date := l_gl_period_start_date;
                                        x_end_date := l_gl_period_end_date;
                                ELSIF p_time_phase_type_code = 'R' THEN
                                        x_start_date := l_dr_period_start_date;
                                        x_end_date := l_dr_period_end_date;
                                END IF;
                        ELSE
                                -- error msg : F127 = Invalid boundary code for PTD
                                PA_FUNDS_CONTROL_PKG.log_message
                                (p_msg_token1 =>'Invalid boundary code for PTD');
                                x_result_code := 'F127';
                                x_return_status := 'F';
				PA_DEBUG.reset_err_stack;
                                Return;
                                NULL;
                        END IF;
                ELSE
                                -- error msg : F122 = Invalid Amount type boundary code
                                PA_FUNDS_CONTROL_PKG.log_message
                                (p_msg_token1 =>'Invalid Amount type boundary code');
                                x_result_code := 'F122';
                                x_return_status := 'F';
				PA_DEBUG.reset_err_stack;
                                Return;
                        NULL;

                END IF;

        ELSE
                 -- error msg : F122 = Invalid Amount type boundary code
                PA_FUNDS_CONTROL_PKG.log_message
                (p_msg_token1 =>'Invalid Amount type boundary code');
                x_result_code := 'F122';
                x_return_status := 'F';
		PA_DEBUG.reset_err_stack;
                Return;
                NULL;
        END IF;

        --('After Date Check Process');

        IF    x_start_date IS NULL OR x_end_date IS NULL THEN
                PA_FUNDS_CONTROL_PKG.log_message
                (p_msg_token1 =>'x_start_date IS NULL OR x_end_date IS NULL');
                IF p_time_phase_type_code = 'R' THEN
                        --error msg : F129 = Start and end date is null for Date range
                        x_result_code     := 'F129';
                        x_return_status := 'F';
                ELSIF p_time_phase_type_code = 'G' THEN
                        -- Error msg : F134 Start and end date is null for GL period
                        x_result_code  := 'F134';
                        x_return_status := 'F';
                ELSIF p_time_phase_type_code = 'P' THEN
                        -- Error msg : F130 Start and end date is null for PA period
                        x_result_code := 'F130';
                        x_return_status := 'F';
                END IF;

                x_error_code := 2;
        END IF;
        PA_FUNDS_CONTROL_PKG.log_message
        (p_msg_token1 =>'End of setup start and end date');

	PA_DEBUG.reset_err_stack;
        Return;
EXCEPTION

        WHEN NO_DATA_FOUND THEN
                PA_FUNDS_CONTROL_PKG.log_message(p_msg_token1 =>'Exception: No Data Found - F136');
                --Error msg : F136 = Funds check failed at Start and End Date Calculations;
                x_result_code := 'F136';
		PA_DEBUG.reset_err_stack;
                Return;

        WHEN OTHERS THEN
		PA_DEBUG.reset_err_stack;
                x_result_code := 'T';
         	RAISE;
END setup_start_end_date;

/** This api returns the start date or end date for the given amount type boundary code
 *  conditions, this in turn make calls the setup_start_end_date api
 *  if p_type param is START_DATE then this api returns start-date if p_type param is END_DATE
 *  then this api returns end date  bug fix :1992734
 */

FUNCTION get_start_or_end_date(
        p_packet_id                IN       NUMBER,
        p_bc_packet_id             IN       NUMBER,
        p_project_id               IN       pa_bc_packets.project_id%TYPE,
        p_budget_version_id        IN       pa_bc_packets.budget_version_id%TYPE,
        p_time_phase_type_code     IN       pa_budget_entry_methods.time_phased_type_code%TYPE,
        p_expenditure_item_date    IN       DATE,
        p_amount_type              IN       pa_budgetary_control_options.amount_type%TYPE,
        p_boundary_code            IN       pa_budgetary_control_options.boundary_code%TYPE,
        p_set_of_books_id          IN       pa_bc_packets.set_of_books_id%TYPE,
	p_type                     IN       varchar2  -- START_DATE or END_DATE OR RESULT_CODE
	) return DATE  is

	l_start_date       date;
	l_end_date         date;
        x_error_code       varchar2(1000);
        x_err_buff         varchar2(1000);
        x_return_status    varchar2(100);
        x_result_code      varchar2(100);


BEGIN

	If  g_sd_project_id  is null or g_sd_project_id <> p_project_id OR
	    g_sd_bdgt_version_id  is null  or g_sd_bdgt_version_id <> p_budget_version_id  OR
            g_sd_tm_phase_code    is null or g_sd_tm_phase_code <> p_time_phase_type_code OR
            g_sd_amt_type  is  null or g_sd_amt_type <> p_amount_type OR
            g_sd_boundary_code  is  null or g_sd_boundary_code <> p_boundary_code OR
            g_sd_sob  is null or g_sd_sob <> p_set_of_books_id then

		pa_funds_control_pkg.log_message(p_msg_token1 => 'Different 1 '||p_type);

			setup_start_end_date (
        		p_packet_id                => p_packet_id
        		,p_bc_packet_id             => p_bc_packet_id
        		,p_project_id               => p_project_id
        		,p_budget_version_id        => p_budget_version_id
        		,p_time_phase_type_code     => p_time_phase_type_code
        		,p_expenditure_item_date    => p_expenditure_item_date
        		,p_amount_type              => p_amount_type
        		,p_boundary_code            => p_boundary_code
        		,p_set_of_books_id          => p_set_of_books_id
        		,x_start_date               => l_start_date
        		,x_end_date                 => l_end_date
        		,x_error_code               => x_error_code
        		,x_err_buff                 => x_err_buff
        		,x_return_status            => x_return_status
        		,x_result_code              => x_result_code);

			g_start_date  := l_start_date;
			g_end_date    := l_end_date;
			g_sd_result_code := x_result_code;
			g_sd_project_id := p_project_id;
			g_sd_bdgt_version_id := p_budget_version_id;
			g_sd_amt_type  := p_amount_type;
			g_sd_boundary_code := p_boundary_code;
			g_sd_sob      := p_set_of_books_id;
			g_sd_tm_phase_code := p_time_phase_type_code;

	Else
		If g_start_date is not null and g_end_date is not null and
		trunc(p_expenditure_item_date) between trunc(g_start_date) and trunc(g_end_date) then
			l_start_date := g_start_date;
			l_end_date   := g_end_date;
			x_result_code := g_sd_result_code;
			pa_funds_control_pkg.log_message(p_msg_token1 => 'Same '||p_type);

		Else
			pa_funds_control_pkg.log_message(p_msg_token1 => 'Different 2');
                        setup_start_end_date (
                        p_packet_id                => p_packet_id
                        ,p_bc_packet_id             => p_bc_packet_id
                        ,p_project_id               => p_project_id
                        ,p_budget_version_id        => p_budget_version_id
                        ,p_time_phase_type_code     => p_time_phase_type_code
                        ,p_expenditure_item_date    => p_expenditure_item_date
                        ,p_amount_type              => p_amount_type
                        ,p_boundary_code            => p_boundary_code
                        ,p_set_of_books_id          => p_set_of_books_id
                        ,x_start_date               => l_start_date
                        ,x_end_date                 => l_end_date
                        ,x_error_code               => x_error_code
                        ,x_err_buff                 => x_err_buff
                        ,x_return_status            => x_return_status
                        ,x_result_code              => x_result_code);

			g_start_date := l_start_date;
			g_end_date   := l_end_date;
			g_sd_result_code := x_result_code;
		End if;

	End if;

	IF p_type = 'START_DATE' then
		Return l_start_date;
	Elsif p_type = 'END_DATE' then
		Return l_end_date;
	End if;

EXCEPTION

	when others then
		pa_funds_control_pkg.log_message(p_msg_token1 =>
			'Failed in the get_start_date api');
		raise;

END get_start_or_end_date;

-- R12 Funds Management Uptake : This tieback procedure is called from PSA_BC_XLA_PVT.Budgetary_control
-- if SLA accounting fails.This API will mark the pa_bc_packet records to failed status.

PROCEDURE TIEBACK_FAILED_ACCT_STATUS (p_bc_mode  IN VARCHAR2 DEFAULT 'C') IS

 CURSOR C_PRINT_EVENT_STATUS IS
 SELECT event_id, b.result_code
   FROM PSA_BC_XLA_EVENTS_GT b;

 BEGIN

        -- Bug 5354715 : Added the "PA IMPLEMENTED IN OU" check.
        IF PA_FUNDS_CONTROL_PKG.IS_PA_INSTALL_IN_OU = 'N' then

		If pa_funds_control_pkg.g_debug_mode = 'Y' then
			pa_funds_control_pkg.log_message(p_msg_token1=>'PA NOT INSTALLED IN THIS OU');
		end if;
                Return;
        END IF;

   IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
      pa_funds_control_pkg.log_message(p_msg_token1 => 'TIEBACK_FAILED_ACCT_STATUS : Start ');
   End if;

   IF pa_budget_fund_pkg.g_processing_mode IN ('YEAR_END','CHECK_FUNDS','BASELINE') THEN
      RETURN;
   END IF;

   IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
      FOR i IN C_PRINT_EVENT_STATUS LOOP
        pa_funds_control_pkg.log_message(p_msg_token1 => 'TIEBACK_FAILED_ACCT_STATUS : Result Code of event_id '||i.event_id||' = '||i.result_code);
      END LOOP;
   End if;


   UPDATE pa_bc_packets a
      SET  status_code = DECODE(p_bc_mode,'C','F','R'),
          result_code  = DECODE(substr(result_code,1,1),'F',result_code,'F172')
   WHERE  status_code in ('P','I','A','S')
     AND  source_event_id IN
            (SELECT  event_id
               FROM  PSA_BC_XLA_EVENTS_GT
              WHERE upper(result_code) in ('XLA_ERROR','FATAL','XLA_UNPROCESSED','XLA_NO_JOURNAL'));

   UPDATE pa_bc_packets a
      SET  status_code  = DECODE(p_bc_mode,'C','F','R'),
           result_code  = DECODE(substr(result_code,1,1),'F',result_code,'F172')
   WHERE  status_code in ('P','I','A','S')
     AND  bc_event_id IN
            (SELECT  event_id
               FROM  PSA_BC_XLA_EVENTS_GT
              WHERE upper(result_code) in ('XLA_ERROR','FATAL','XLA_UNPROCESSED','XLA_NO_JOURNAL'));

   IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
          pa_funds_control_pkg.log_message(p_msg_token1 => 'TIEBACK_FAILED_ACCT_STATUS : End ');
   End if;

END TIEBACK_FAILED_ACCT_STATUS;

-- R12 Funds Management Uptake : This Procedure is called from "PRC: Generate Cost accounting events"
-- Process. After events are generated for BTC/TBC actuals which are eligible to get interfaced to SLA ,
-- The below procedure stamps these events on the associated commitments .

PROCEDURE INTERFACE_TBC_BTC_COMT_UPDATE (p_calling_module IN VARCHAR2,
                                         P_request_id     IN NUMBER  ,
					 x_result_code    OUT NOCOPY VARCHAR2) IS

-- Variables to store eligible CDL data
 l_Exp_Item_Id_tbl              PA_PLSQL_DATATYPES.IDTabTyp;
 l_cdl_gl_Date_tbl              PA_PLSQL_DATATYPES.DateTabTyp;
 l_Burd_Sum_Dest_Run_Id_tbl     PA_PLSQL_DATATYPES.IDTabTyp;
 l_doc_header_id_tbl            PA_PLSQL_DATATYPES.IDTabTyp;
 l_doc_distribution_id_tbl      PA_PLSQL_DATATYPES.IDTabTyp;
 l_cdl_line_type_tbl            PA_PLSQL_DATATYPES.Char1TabTyp;
 l_system_linkage_function_tbl  PA_PLSQL_DATATYPES.Char3TabTyp;
 l_expenditure_type_tbl         PA_PLSQL_DATATYPES.Char30TabTyp;
 l_cdl_acct_event_id_tbl        PA_PLSQL_DATATYPES.IDTabTyp;
 l_acct_source_code_tbl         PA_PLSQL_DATATYPES.Char30TabTyp;
 l_count_of_records             NUMBER;
 l_Return_Status                VARCHAR2(100);
 l_Msg_Data                     VARCHAR2(2000);

 -- Below variables added for bug 5263721
 l_billable_flag_tbl		PA_PLSQL_DATATYPES.Char1TabTyp;
 l_project_id_tbl		PA_PLSQL_DATATYPES.IDTabTyp;
 l_task_id_tbl			PA_PLSQL_DATATYPES.IDTabTyp;
 l_pa_period_name_tbl		PA_PLSQL_DATATYPES.Char30TabTyp;
 l_denom_currency_code_tbl	PA_PLSQL_DATATYPES.Char30TabTyp;
 l_acct_currency_code_tbl	PA_PLSQL_DATATYPES.Char30TabTyp;
 l_project_currency_code_tbl	PA_PLSQL_DATATYPES.Char30TabTyp;
 l_projfunc_currency_code_tbl	PA_PLSQL_DATATYPES.Char30TabTyp;
 l_system_reference1_tbl	PA_PLSQL_DATATYPES.Char30TabTyp;
 l_person_type_tbl		PA_PLSQL_DATATYPES.Char30TabTyp;
 l_po_line_id_tbl		PA_PLSQL_DATATYPES.IDTabTyp;
 l_attribute1_tbl		PA_PLSQL_DATATYPES.Char150TabTyp;
 l_attribute2_tbl		PA_PLSQL_DATATYPES.Char150TabTyp;
 l_attribute3_tbl		PA_PLSQL_DATATYPES.Char150TabTyp;
 l_attribute4_tbl		PA_PLSQL_DATATYPES.Char150TabTyp;
 l_attribute5_tbl		PA_PLSQL_DATATYPES.Char150TabTyp;
 l_attribute6_tbl		PA_PLSQL_DATATYPES.Char150TabTyp;
 l_attribute7_tbl		PA_PLSQL_DATATYPES.Char150TabTyp;
 l_attribute8_tbl		PA_PLSQL_DATATYPES.Char150TabTyp;
 l_attribute9_tbl		PA_PLSQL_DATATYPES.Char150TabTyp;
 l_attribute10_tbl		PA_PLSQL_DATATYPES.Char150TabTyp;
 l_attribute_category_tbl	PA_PLSQL_DATATYPES.Char30TabTyp;
 l_expenditure_item_date_tbl	PA_PLSQL_DATATYPES.DateTabTyp;
 l_ACCT_RATE_DATE_tbl		PA_PLSQL_DATATYPES.DateTabTyp;
 l_ACCT_RATE_TYPE_tbl		PA_PLSQL_DATATYPES.Char30TabTyp;
 l_ACCT_EXCHANGE_RATE_tbl	PA_PLSQL_DATATYPES.NumTabTyp;
 l_PROJECT_RATE_DATE_tbl	PA_PLSQL_DATATYPES.DateTabTyp;
 l_PROJECT_RATE_TYPE_tbl	PA_PLSQL_DATATYPES.Char30TabTyp;
 l_PROJECT_EXCHANGE_RATE_tbl	PA_PLSQL_DATATYPES.NumTabTyp;
 l_PROJFUNC_COST_RATE_DATE_tbl	PA_PLSQL_DATATYPES.DateTabTyp;
 l_PROJFUNC_COST_RATE_TYPE_tbl	PA_PLSQL_DATATYPES.Char30TabTyp;
 l_pfc_ex_rate_tbl		PA_PLSQL_DATATYPES.NumTabTyp;
 l_job_id_tbl			PA_PLSQL_DATATYPES.IDTabTyp;
 l_non_labor_resource_tbl	PA_PLSQL_DATATYPES.Char30TabTyp;
 l_nl_res_orgn_id_tbl		PA_PLSQL_DATATYPES.IDTabTyp;
 l_wip_resource_id_tbl		PA_PLSQL_DATATYPES.IDTabTyp;
 l_incurred_by_person_id_tbl	PA_PLSQL_DATATYPES.IDTabTyp;
 l_inventory_item_id_tbl	PA_PLSQL_DATATYPES.IDTabTyp;

 -- Bug 5680236 : Added below new variables
 l_budget_line_id_tbl	        PA_PLSQL_DATATYPES.IDTabTyp;
 l_budget_version_id_tbl	PA_PLSQL_DATATYPES.IDTabTyp;
 l_doc_line_number_tbl          PA_PLSQL_DATATYPES.IDTabTyp;
 l_transaction_source_tbl       PA_PLSQL_DATATYPES.Char30TabTyp;
 l_cdl_rowid_tbl                PA_PLSQL_DATATYPES.RowidTabTyp;

 l_bc_commitment_id_tbl         PA_PLSQL_DATATYPES.IDTabTyp;
 l_bc_project_id_tbl            PA_PLSQL_DATATYPES.IDTabTyp;
 l_bc_task_id_tbl               PA_PLSQL_DATATYPES.IDTabTyp;
 l_bc_res_list_mem_id_tbl       PA_PLSQL_DATATYPES.IDTabTyp;
 l_bc_top_task_id_tbl           PA_PLSQL_DATATYPES.IDTabTyp;
 l_bc_budget_version_id_tbl	PA_PLSQL_DATATYPES.IDTabTyp;
 l_bc_budget_line_id_tbl	PA_PLSQL_DATATYPES.IDTabTyp;
 l_bc_entry_level_code_tbl      PA_PLSQL_DATATYPES.Char30TabTyp;
 l_bc_gl_start_date_tbl         PA_PLSQL_DATATYPES.DateTabTyp;
 l_bc_exp_item_id_tbl	        PA_PLSQL_DATATYPES.IDTabTyp;
 l_bc_transfer_sts_code_tbl     PA_PLSQL_DATATYPES.Char30TabTyp;

 l_cdl_top_task_id              pa_tasks.top_task_id%TYPE;
 l_cdl_budget_version_id        pa_budget_versions.budget_version_id%TYPE;
 l_cdl_entry_level_code         pa_budget_entry_methods.entry_level_code%TYPE;
 l_budget_line_id               pa_bc_packets.budget_line_id%TYPE;
 l_budget_ccid                  pa_bc_packets.budget_ccid%TYPE;
 l_error_message_code           VARCHAR2(200) := NULL;

 -- Bug 5680236 : End of variable declaration

 /* Cursor to fetch CDL data associated with TBC and BTC lines
    Picks BTC expenditures and TBC lines generated on 'VI'/'ST'/'OT' expenditure items.
    This cursor picks even those expenditure items which are marked to 'A' status in this
    run because of implementation level allow interface flags set to 'N'  */

 CURSOR CDL_CUR IS
 SELECT CDL.Expenditure_Item_Id,
        CDL.Gl_Date,
	ITEM.Burden_Sum_Dest_Run_Id,
	ITEM.document_header_id,
	ITEM.document_distribution_id ,
	CDL.line_type,
	ITEM.system_linkage_function,
        ITEM.expenditure_type,
        CDL.acct_event_id,
 -- Below columns added for bug 5263721
        CDL.billable_flag,
        CDL.project_id,
        CDL.task_id,
        CDL.pa_period_name,
        ITEM.denom_currency_code,
        ITEM.acct_currency_code,
        ITEM.project_currency_code,
        ITEM.projfunc_currency_code,
        CDL.system_reference1,
        EXP.person_type,
        ITEM.po_line_id,
	ITEM.attribute1,
	ITEM.attribute2,
	ITEM.attribute3,
	ITEM.attribute4,
	ITEM.attribute5,
	ITEM.attribute6,
	ITEM.attribute7,
	ITEM.attribute8,
	ITEM.attribute9,
	ITEM.attribute10,
	ITEM.attribute_category,
	ITEM.expenditure_item_date,
	CDL.acct_rate_date,
	CDL.acct_rate_type,
	CDL.acct_exchange_rate,
	CDL.project_rate_date,
	CDL.project_rate_type,
	CDL.project_exchange_rate,
	CDL.projfunc_cost_rate_date,
	CDL.projfunc_cost_rate_type,
	CDL.projfunc_cost_exchange_rate,
	ITEM.job_id,
	ITEM.non_labor_resource,
	ITEM.organization_id non_labor_resource_orgn_id,
	ITEM.wip_resource_id,
	EXP.incurred_by_person_id,
	ITEM.inventory_item_id,
	-- Columns added for Bug 5680236
	cdl.budget_line_id,
	cdl.budget_version_id,
	ITEM.document_line_number,
	ITEM.transaction_source,
	cdl.rowid
 FROM   PA_Cost_Distribution_Lines CDL,
        pa_expenditure_items_all ITEM,
	pa_expenditures_all EXP
 WHERE  CDL.transfer_status_code in ('A', 'G')
   AND  CDL.request_id = p_request_id
   AND  item.expenditure_item_id = cdl.expenditure_item_id
   AND  ITEM.expenditure_id = EXP.expenditure_id
   AND    ( (p_calling_module = 'BTC' AND item.system_linkage_function = 'BTC' AND CDL.line_type = 'R' ) OR
            (p_calling_module = 'TBC' AND CDL.line_type = 'D' AND item.system_linkage_function IN ('VI','ST','OT')) OR
            (p_calling_module = 'Cost' AND ((item.system_linkage_function = 'BTC'  AND CDL.line_type = 'R') OR
						     (CDL.line_type = 'D' AND item.system_linkage_function IN ('VI','ST','OT'))))
          )
   AND  NVL(CDL.liquidate_encum_flag,'N') = 'Y'
ORDER BY  CDL.Expenditure_Item_Id,CDL.line_num;


-- Bug 5680236 : Cursor to fetch  bc_commitment records associated with CDL's
CURSOR  c_bc_com_details       (p_doc_header_id         NUMBER,
                                p_doc_line_number       NUMBER,
			        p_doc_distribution_id   NUMBER,
			        p_transaction_source    VARCHAR2,
			        p_cdl_line_type         VARCHAR2,
				p_expenditure_type      VARCHAR2,
				p_expenditure_item_date DATE) IS
SELECT pbc.bc_commitment_id,
       pbc.project_id,
       pbc.task_id,
       pbc.resource_list_member_id,
       DECODE(pm.entry_level_code,'P',0,pt.top_task_id) top_task_id,
       bv.budget_version_id,
       pbc.budget_line_id,
       pm.entry_level_code,
       (SELECT gl.start_date
          FROM  gl_period_statuses gl
         WHERE gl.application_id  = 101
           AND gl.set_of_books_id = pbc.set_of_books_id
           AND gl.period_name     = pbc.period_name) gl_start_date,
       pbc.exp_item_id,
       pbc.transfer_status_code
  FROM pa_bc_commitments_all pbc,
       pa_tasks pt,
       pa_budget_versions bv,
       pa_budget_entry_methods pm
 WHERE pbc.document_header_id = p_doc_header_id
   AND pbc.document_distribution_id = DECODE(substr(p_transaction_source,1,10),'PO RECEIPT',p_doc_line_number,p_doc_distribution_id)
   AND pbc.expenditure_type = p_expenditure_type
   AND pbc.expenditure_item_date = p_expenditure_item_date
   --AND  pbc.transfer_status_code in ('P','R','X')
   AND pbc.document_type in ('AP','PO')
   AND pbc.burden_cost_flag = 'R'
   AND ((pbc.parent_bc_packet_id is not null AND p_cdl_line_type ='R') OR  p_cdl_line_type ='D')
   AND pt.task_id = pbc.task_id
   AND bv.budget_version_id = pbc.budget_version_id
   AND bv.budget_entry_method_code = pm.budget_entry_method_code;

-- Bug 5680236 : Cursor to fetch budget version details for a task on CDL's
CURSOR c_budget_details (p_task_id    NUMBER) IS
SELECT DECODE(pm.entry_level_code,'P',0,pt.top_task_id) top_task_id,
       bv.budget_version_id,
       pm.entry_level_code
  FROM pa_tasks pt,
       pa_budget_versions bv,
       Pa_Budget_Types bt,
       pa_budgetary_control_options pbct,
       pa_budget_entry_methods pm
 WHERE pt.task_id = p_task_id
   AND bv.project_id = pt.project_id
   AND bv.BUDGET_STATUS_CODE = 'B'
   AND bt.budget_type_Code = bv.budget_type_Code
   and bt.budget_amount_code = 'C'
   and bv.current_flag = 'Y'
   and pbct.project_id = bv.project_id
   and pbct.BDGT_CNTRL_FLAG = 'Y'
   and pbct.BUDGET_TYPE_CODE = bv.budget_type_code
   and (pbct.EXTERNAL_BUDGET_CODE = 'GL'
        OR
        pbct.EXTERNAL_BUDGET_CODE is NULL
       )
   AND  bv.budget_entry_method_code = pm.budget_entry_method_code;

BEGIN

        --- Initialize the error statck
	x_result_code := 'Success';

        PA_DEBUG.init_err_stack ('PA_FUNDS_CONTROL_PKG1.INTERFACE_TBC_BTC_COMT_UPDATE');


        fnd_profile.get('PA_DEBUG_MODE',PA_FUNDS_CONTROL_PKG.g_debug_mode);
        PA_FUNDS_CONTROL_PKG.g_debug_mode := NVL(PA_FUNDS_CONTROL_PKG.g_debug_mode, 'N');

        PA_DEBUG.SET_PROCESS( x_process        => 'PLSQL'
                             ,x_write_file     => 'LOG'
                             ,x_debug_mode     => PA_FUNDS_CONTROL_PKG.g_debug_mode);

	IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
 	  pa_funds_control_pkg.log_message(p_msg_token1 => 'INTERFACE_TBC_BTC_COMT_UPDATE : In start ');
 	  pa_funds_control_pkg.log_message(p_msg_token1 => 'INTERFACE_TBC_BTC_COMT_UPDATE:  p_calling_module = '||p_calling_module);
 	  pa_funds_control_pkg.log_message(p_msg_token1 => 'INTERFACE_TBC_BTC_COMT_UPDATE : P_request_id = '||P_request_id);
	End if;

        -----------------------------------------------------------------------------------+
        -- Invoke the Sweeper process to sweep all the encumbrance etries
        -- from PA_BC_PACKETS to PA_BC_BALANCES and PA_BC_COMMITMENTS
        -----------------------------------------------------------------------------------+
        PA_Sweeper.Update_Act_Enc_Balance (
                  X_Return_Status              => l_Return_Status,
                  X_Error_Message_Code         => l_Msg_Data
         );

        IF l_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
          IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
             pa_funds_control_pkg.log_message(p_msg_token1 => 'Error occured while running sweeper process PA_Sweeper.Update_Act_Enc_Balance');
             pa_funds_control_pkg.log_message(p_msg_token1 => 'X_Error_Message_Code:'||l_Msg_Data);
          END IF;
	  x_result_code := 'Error';
          RETURN;
        END IF;

	IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
 	  pa_funds_control_pkg.log_message(p_msg_token1 => 'INTERFACE_TBC_BTC_COMT_UPDATE : Opening cursor CDL_CUR ');
        End if;

        OPEN CDL_CUR ;
        FETCH CDL_CUR BULK COLLECT INTO
		l_Exp_Item_Id_tbl,
		l_cdl_gl_Date_tbl,
		l_Burd_Sum_Dest_Run_Id_tbl,
		l_doc_header_id_tbl,
		l_doc_distribution_id_tbl,
		l_cdl_line_type_tbl,
		l_system_linkage_function_tbl,
		l_expenditure_type_tbl,
		l_cdl_acct_event_id_tbl,
 -- Below columns added for bug 5263721
		l_billable_flag_tbl,
		l_project_id_tbl,
		l_task_id_tbl,
		l_pa_period_name_tbl,
		l_denom_currency_code_tbl,
		l_acct_currency_code_tbl,
		l_project_currency_code_tbl,
		l_projfunc_currency_code_tbl,
		l_system_reference1_tbl,
		l_person_type_tbl,
		l_po_line_id_tbl,
		l_attribute1_tbl,
		l_attribute2_tbl,
		l_attribute3_tbl,
		l_attribute4_tbl,
		l_attribute5_tbl,
		l_attribute6_tbl,
		l_attribute7_tbl,
		l_attribute8_tbl,
		l_attribute9_tbl,
		l_attribute10_tbl,
		l_attribute_category_tbl,
		l_expenditure_item_date_tbl,
		l_acct_rate_date_tbl,
		l_acct_rate_type_tbl,
		l_acct_exchange_rate_tbl,
		l_project_rate_date_tbl,
		l_project_rate_type_tbl,
		l_project_exchange_rate_tbl,
		l_projfunc_cost_rate_date_tbl,
		l_projfunc_cost_rate_type_tbl,
		l_pfc_ex_rate_tbl,
		l_job_id_tbl,
		l_non_labor_resource_tbl,
		l_nl_res_orgn_id_tbl,
		l_wip_resource_id_tbl,
		l_incurred_by_person_id_tbl,
		l_inventory_item_id_tbl,
                l_budget_line_id_tbl,
                l_budget_version_id_tbl,
		l_doc_line_number_tbl,
		l_transaction_source_tbl,
		l_cdl_rowid_tbl;

        CLOSE CDL_CUR;

        l_count_of_records := l_Exp_Item_Id_tbl.count;

	IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
 	  pa_funds_control_pkg.log_message(p_msg_token1 => 'INTERFACE_TBC_BTC_COMT_UPDATE : NUmber of records fethced '||l_count_of_records);
        End if;

       IF l_count_of_records <> 0 THEN

         -- Bug 5680236 : Columns used by R12 fundscheck logic which were not populated prior R12
	 -- Table name                   column name             Prior FP.M     In FP.M
         -- -----------------------------------------------------------------------------
	 -- pa_cost_distribution_line    budget_version_id       Not Supported  Not Supported
	 --                              budget_line_id          Not Supported  Not Supported
	 -- pa_bc_commitments            budget_line_id          Not Supported  Not Supported
	 --                              exp_item_id             Not Supported  Supported

         -- Below logic has been added to populate above columns for expenditures interfaced to
	 -- projects prior R12

	 FOR cdl_rec in 1..l_count_of_records LOOP

	    IF l_budget_line_id_tbl(cdl_rec) IS NULL OR l_budget_version_id_tbl(cdl_rec) is NULL THEN

           	IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
 	           pa_funds_control_pkg.log_message(p_msg_token1 => 'INTERFACE_TBC_BTC_COMT_UPDATE : Data interfaced prior R12');
                End if;

                OPEN c_bc_com_details       (l_doc_header_id_tbl(cdl_rec),
                                             l_doc_line_number_tbl(cdl_rec),
			                     l_doc_distribution_id_tbl(cdl_rec),
			                     l_transaction_source_tbl(cdl_rec),
			                     l_cdl_line_type_tbl(cdl_rec),
				             l_expenditure_type_tbl(cdl_rec),
					     l_expenditure_item_date_tbl(cdl_rec));
                FETCH c_bc_com_details       BULK COLLECT INTO
                                             l_bc_commitment_id_tbl,
                                             l_bc_project_id_tbl,
                                             l_bc_task_id_tbl,
                                             l_bc_res_list_mem_id_tbl,
                                             l_bc_top_task_id_tbl,
                                             l_bc_budget_version_id_tbl,
                                             l_bc_budget_line_id_tbl,
                                             l_bc_entry_level_code_tbl,
                                             l_bc_gl_start_date_tbl,
                                             l_bc_exp_item_id_tbl,
                                             l_bc_transfer_sts_code_tbl;
                CLOSE c_bc_com_details;

           	IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
 	           pa_funds_control_pkg.log_message(p_msg_token1 => 'INTERFACE_TBC_BTC_COMT_UPDATE : # of records fetched from CDL'||l_bc_commitment_id_tbl.count);
                End if;

                l_budget_line_id := NULL;

                -- Check if budget_line_id was already derived and stamped on any of the bc commitment record
                -- IF exists then we just need to stamp the same budget_line_id on CDL and other bc commitment records.
		-- IF NULL then need to derive budget line id
		-- Note : Based on the filters provided to fetch data from above cursor c_bc_com_details all records
		-- will have same budget line id

                FOR bccomm_rec in 1..l_bc_commitment_id_tbl.count LOOP
                    IF l_bc_budget_line_id_tbl(bccomm_rec) IS NOT NULL THEN
		       l_budget_line_id := l_bc_budget_line_id_tbl(bccomm_rec);
		       EXIT;
		    END IF;
                END LOOP;

          	IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
 	           pa_funds_control_pkg.log_message(p_msg_token1 => 'INTERFACE_TBC_BTC_COMT_UPDATE : budget line id on bc comt'||l_budget_line_id);
                End if;

		IF l_budget_line_id IS NULL THEN

                   -- Calling below procedure to derive budget_line_id for bc commitments data
                   PA_FUNDS_CONTROL_UTILS.Get_Budget_CCID (
                                       p_project_id 		=> l_bc_project_id_tbl(1),
                                       p_task_id    		=> l_bc_task_id_tbl(1),
                                       p_res_list_mem_id 	=> l_bc_res_list_mem_id_tbl(1),
		                       p_start_date		=> l_bc_gl_start_date_tbl(1),
                                       p_budget_version_id 	=> l_bc_budget_version_id_tbl(1),
		                       p_top_task_id		=> l_bc_top_task_id_tbl(1),
		                       p_entry_level_code       => l_bc_entry_level_code_tbl(1),
                                       x_budget_ccid  	        => l_budget_ccid,
                                       x_budget_line_id         => l_budget_line_id,
                                       x_return_status 	        => l_return_status,
                                       x_error_message_code 	=> l_error_message_code);

              	  IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
 	             pa_funds_control_pkg.log_message(p_msg_token1 => 'INTERFACE_TBC_BTC_COMT_UPDATE : derived budget line id on bc comt'||l_budget_line_id);
                  End if;

                END IF;

                FORALL i in 1..l_bc_commitment_id_tbl.count
                UPDATE pa_bc_commitments
		   SET budget_line_id = l_budget_line_id
		 WHERE bc_commitment_id = l_bc_commitment_id_tbl(i)
		   AND budget_line_id IS NULL;

         	IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
 	             pa_funds_control_pkg.log_message(p_msg_token1 => 'INTERFACE_TBC_BTC_COMT_UPDATE : # of bc comt records updated'||SQL%ROWCOUNT);
                End if;

      	        -- Check if Project/task on CDL has ben modified i.e. different from the one stamped
		-- on bc commitments.In this case rederive budget version details and then
		-- derive budget_line_id for CDL

                l_cdl_budget_version_id := NULL;
		IF l_bc_project_id_tbl(1) <> l_project_id_tbl(cdl_rec) OR
		   l_bc_task_id_tbl(1)    <> l_task_id_tbl(cdl_rec)       THEN

                         l_budget_line_id := NULL;

                         OPEN  c_budget_details(l_task_id_tbl(cdl_rec));
                         FETCH c_budget_details INTO
                                             l_cdl_top_task_id ,
                                             l_cdl_budget_version_id,
                                             l_cdl_entry_level_code;
                         CLOSE c_budget_details;

                         PA_FUNDS_CONTROL_UTILS.Get_Budget_CCID (
                                       p_project_id 		=> l_project_id_tbl(cdl_rec),
                                       p_task_id    		=> l_task_id_tbl(cdl_rec),
                                       p_res_list_mem_id 	=> l_bc_res_list_mem_id_tbl(1),
		                       p_start_date		=> l_bc_gl_start_date_tbl(1),
                                       p_budget_version_id 	=> l_cdl_budget_version_id,
		                       p_top_task_id		=> l_cdl_top_task_id,
		                       p_entry_level_code       => l_cdl_entry_level_code,
                                       x_budget_ccid  	        => l_budget_ccid,
                                       x_budget_line_id         => l_budget_line_id,
                                       x_return_status    	=> l_return_status,
                                       x_error_message_code 	=> l_error_message_code);

              	         IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
 	                    pa_funds_control_pkg.log_message(p_msg_token1 => 'INTERFACE_TBC_BTC_COMT_UPDATE : derived budget line id on cdl'||l_budget_line_id);
                         End if;
                END IF;

		UPDATE pa_cost_distribution_lines_all cdl
		   SET cdl.budget_version_id = NVL(l_cdl_budget_version_id,l_bc_budget_version_id_tbl(1)),
		       cdl.budget_line_id    = l_budget_line_id
 		 WHERE cdl.rowid = l_cdl_rowid_tbl(cdl_rec);

         	IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
                   pa_funds_control_pkg.log_message(p_msg_token1 => 'INTERFACE_TBC_BTC_COMT_UPDATE : # of cdl records updated'||SQL%ROWCOUNT);
                End if;

                FORALL i in 1..l_bc_commitment_id_tbl.count
                UPDATE pa_bc_commitments
		   SET exp_item_id = l_Exp_Item_Id_tbl(cdl_rec)
		 WHERE bc_commitment_id = l_bc_commitment_id_tbl(i)
		   AND exp_item_id IS NULL
		   AND transfer_status_code in ('P','R','X');

         	IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
 	             pa_funds_control_pkg.log_message(p_msg_token1 => 'INTERFACE_TBC_BTC_COMT_UPDATE : # of bc comt records updated'||SQL%ROWCOUNT);
                End if;

	    END IF; --IF l_budget_line_id_tbl(cdl_rec) IS NULL OR l_budget_version_id_tbl(cdl_rec) is NULL THEN
         END LOOP; --FOR cdl_rec in 1..l_count_of_records LOOP
         -- End of logic added for Bug 5680236

 	 IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
 	  pa_funds_control_pkg.log_message(p_msg_token1 => 'INTERFACE_TBC_BTC_COMT_UPDATE : updating eligible AP commitments for liq encumbrance ');
         End if;

         FORALL i in 1..l_count_of_records
         UPDATE  pa_bc_commitments bc_cm
            SET  bc_cm.bc_event_id = l_cdl_acct_event_id_tbl(i),
  	         bc_cm.transfer_status_code = 'A',
	         bc_cm.request_id  = p_request_id,
	  	 bc_cm.transferred_date = SYSDATE,
		 bc_cm.liquidate_gl_date = l_cdl_gl_Date_tbl(i),
		 bc_cm.exp_item_id = DECODE (l_cdl_line_type_tbl(i),'R',l_Exp_Item_Id_tbl(i),bc_cm.exp_item_id) -- Bug 5076612
          WHERE ( bc_cm.document_header_id,bc_cm.document_distribution_id,expenditure_type)
		   IN ( SELECT exp.document_header_id,exp.document_distribution_id,l_expenditure_type_tbl(i)
		          FROM PA_Cost_Distribution_lines  cdl_raw,
			       pa_expenditure_items_all  exp ,
			       pa_expenditures_all expend
			      WHERE cdl_raw.burden_sum_source_run_id = l_Burd_Sum_Dest_Run_Id_tbl(i)
				AND exp.expenditure_item_id = cdl_raw.expenditure_item_id
				AND cdl_raw.line_num = 1
				AND l_cdl_line_type_tbl(i) ='R'
 -- Below join conditions added for bug 5263721
				AND exp.expenditure_id = expend.expenditure_id
				AND nvl(l_billable_flag_tbl(i), -1) = nvl(cdl_raw.billable_flag, -1)
				AND nvl(l_project_id_tbl(i), -1) = nvl(cdl_raw.project_id, -1)
				AND nvl(l_task_id_tbl(i), -1) = nvl(cdl_raw.task_id, -1)
				AND nvl(l_pa_period_name_tbl(i), -1) = nvl(cdl_raw.pa_period_name, -1)
				AND nvl(l_denom_currency_code_tbl(i), -1) = nvl(exp.denom_currency_code, -1)
				AND nvl(l_acct_currency_code_tbl(i), -1) = nvl(exp.acct_currency_code, -1)
				AND nvl(l_project_currency_code_tbl(i), -1) = nvl(exp.project_currency_code, -1)
				AND nvl(l_projfunc_currency_code_tbl(i), -1) = nvl(exp.projfunc_currency_code, -1)
				/* AND nvl(l_system_reference1_tbl(i), -1) = nvl(cdl_raw.system_reference1, -1) bug 5453131*/
				AND nvl(l_person_type_tbl(i), -1) = nvl(expend.person_type, -1)
				AND nvl(l_po_line_id_tbl(i), -1) = nvl(exp.po_line_id, -1)
				AND nvl(PA_CLIENT_EXTN_BURDEN_SUMMARY.CLIENT_GROUPING(
					null,
					null,
					l_attribute1_tbl(i),
					l_attribute2_tbl(i),
					l_attribute3_tbl(i),
					l_attribute4_tbl(i),
					l_attribute5_tbl(i),
					l_attribute6_tbl(i),
					l_attribute7_tbl(i),
					l_attribute8_tbl(i),
					l_attribute9_tbl(i),
					l_attribute10_tbl(i),
					l_attribute_category_tbl(i),
					l_expenditure_item_date_tbl(i),
					l_acct_rate_date_tbl(i),
					l_acct_rate_type_tbl(i),
					l_acct_exchange_rate_tbl(i),
					l_project_rate_date_tbl(i),
					l_project_rate_type_tbl(i),
					l_project_exchange_rate_tbl(i),
					l_projfunc_cost_rate_date_tbl(i),
					l_projfunc_cost_rate_type_tbl(i),
					l_pfc_ex_rate_tbl(i)),-1) =
					    nvl(PA_CLIENT_EXTN_BURDEN_SUMMARY.CLIENT_GROUPING(
						null,
						null,
						exp.attribute1,
						exp.attribute2,
						exp.attribute3,
						exp.attribute4,
						exp.attribute5,
						exp.attribute6,
						exp.attribute7,
						exp.attribute8,
						exp.attribute9,
						exp.attribute10,
						exp.attribute_category,
						exp.expenditure_item_date,
						exp.acct_rate_date,
						exp.acct_rate_type,
						exp.acct_exchange_rate,
						exp.project_rate_date,
						exp.project_rate_type,
						exp.project_exchange_rate,
						exp.projfunc_cost_rate_date,
						exp.projfunc_cost_rate_type,
						exp.projfunc_cost_exchange_rate),-1)
				AND nvl(PA_CLIENT_EXTN_BURDEN_RESOURCE.CLIENT_GROUPING(
					l_job_id_tbl(i),
					l_non_labor_resource_tbl(i),
					l_nl_res_orgn_id_tbl(i),
					l_wip_resource_id_tbl(i),
					l_incurred_by_person_id_tbl(i),
					l_inventory_item_id_tbl(i)), -1) =
					   nvl(PA_CLIENT_EXTN_BURDEN_RESOURCE.CLIENT_GROUPING(
						exp.job_id,
						exp.non_labor_resource,
						exp.organization_id,
						exp.wip_resource_id,
						expend.incurred_by_person_id,
						exp.inventory_item_id),-1)
		         UNION ALL
		        SELECT l_doc_header_id_tbl(i),l_doc_distribution_id_tbl(i),l_expenditure_type_tbl(i)
		          FROM dual
		         WHERE l_cdl_line_type_tbl(i)  ='D' )
            AND bc_cm.transfer_status_code in ('P','R','X')
            AND bc_cm.document_type = 'AP'
            AND bc_cm.burden_cost_flag = 'R'
            AND ((bc_cm.parent_bc_packet_id IS NOT NULL AND l_cdl_line_type_tbl(i) ='R') OR l_cdl_line_type_tbl(i) ='D');

 	 IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
 	  pa_funds_control_pkg.log_message(p_msg_token1 => 'INTERFACE_TBC_BTC_COMT_UPDATE :Number of AP commitments updated '||SQL%ROWCOUNT);
 	  pa_funds_control_pkg.log_message(p_msg_token1 => 'INTERFACE_TBC_BTC_COMT_UPDATE : updating eligible AP commitments for liq encumbrance ');
	 End if;

    	    FORALL i in 1..l_count_of_records
	    UPDATE  pa_bc_commitments bc_cm
	       SET  bc_cm.bc_event_id = l_cdl_acct_event_id_tbl(i),
	            bc_cm.transfer_status_code = 'A',
		    bc_cm.request_id  = p_request_id,
		    bc_cm.transferred_date = SYSDATE,
		    bc_cm.liquidate_gl_date = l_cdl_gl_Date_tbl(i),
		    bc_cm.exp_item_id = DECODE (l_cdl_line_type_tbl(i),'R',l_Exp_Item_Id_tbl(i),bc_cm.exp_item_id)-- Bug 5076612
	     WHERE (bc_cm.exp_item_id,bc_cm.expenditure_type)
		IN ( SELECT peia.expenditure_item_id ,l_expenditure_type_tbl(i) -- Bug 5663343 : Handled transfer/split cases
                     FROM pa_expenditure_items_all peia
                     WHERE peia.TRANSFERRED_FROM_EXP_ITEM_ID IS NULL
                     START WITH peia.expenditure_item_id in (
	                     SELECT  cdl_raw.expenditure_item_id
		               FROM  PA_Cost_Distribution_lines  cdl_raw,
			             Pa_Expenditure_Items ei_raw,
			             pa_expenditures_all expend
		              WHERE  cdl_raw.burden_sum_source_run_id = l_Burd_Sum_Dest_Run_Id_tbl(i)
		                AND  cdl_raw.line_num = 1
		                AND  cdl_raw.expenditure_item_id = ei_raw.expenditure_item_id
		                AND  ei_raw.system_linkage_function in ('ST','OT','VI')
		                AND  l_cdl_line_type_tbl(i) ='R'
                                -- Below join conditions added for bug 5263721
				AND ei_raw.expenditure_id = expend.expenditure_id
				AND nvl(l_billable_flag_tbl(i), -1) = nvl(cdl_raw.billable_flag, -1)
				AND nvl(l_project_id_tbl(i), -1) = nvl(cdl_raw.project_id, -1)
				AND nvl(l_task_id_tbl(i), -1) = nvl(cdl_raw.task_id, -1)
				AND nvl(l_pa_period_name_tbl(i), -1) = nvl(cdl_raw.pa_period_name, -1)
				AND nvl(l_denom_currency_code_tbl(i), -1) = nvl(ei_raw.denom_currency_code, -1)
				AND nvl(l_acct_currency_code_tbl(i), -1) = nvl(ei_raw.acct_currency_code, -1)
				AND nvl(l_project_currency_code_tbl(i), -1) = nvl(ei_raw.project_currency_code, -1)
				AND nvl(l_projfunc_currency_code_tbl(i), -1) = nvl(ei_raw.projfunc_currency_code, -1)
				/* AND nvl(l_system_reference1_tbl(i), -1) = nvl(cdl_raw.system_reference1, -1) bug 5453131*/
				AND nvl(l_person_type_tbl(i), -1) = nvl(expend.person_type, -1)
				AND nvl(l_po_line_id_tbl(i), -1) = nvl(ei_raw.po_line_id, -1)
				AND nvl(PA_CLIENT_EXTN_BURDEN_SUMMARY.CLIENT_GROUPING(
					null,
					null,
					l_attribute1_tbl(i),
					l_attribute2_tbl(i),
					l_attribute3_tbl(i),
					l_attribute4_tbl(i),
					l_attribute5_tbl(i),
					l_attribute6_tbl(i),
					l_attribute7_tbl(i),
					l_attribute8_tbl(i),
					l_attribute9_tbl(i),
					l_attribute10_tbl(i),
					l_attribute_category_tbl(i),
					l_expenditure_item_date_tbl(i),
					l_acct_rate_date_tbl(i),
					l_acct_rate_type_tbl(i),
					l_acct_exchange_rate_tbl(i),
					l_project_rate_date_tbl(i),
					l_project_rate_type_tbl(i),
					l_project_exchange_rate_tbl(i),
					l_projfunc_cost_rate_date_tbl(i),
					l_projfunc_cost_rate_type_tbl(i),
					l_pfc_ex_rate_tbl(i)),-1) =
					    nvl(PA_CLIENT_EXTN_BURDEN_SUMMARY.CLIENT_GROUPING(
						null,
						null,
						ei_raw.attribute1,
						ei_raw.attribute2,
						ei_raw.attribute3,
						ei_raw.attribute4,
						ei_raw.attribute5,
						ei_raw.attribute6,
						ei_raw.attribute7,
						ei_raw.attribute8,
						ei_raw.attribute9,
						ei_raw.attribute10,
						ei_raw.attribute_category,
						ei_raw.expenditure_item_date,
						ei_raw.acct_rate_date,
						ei_raw.acct_rate_type,
						ei_raw.acct_exchange_rate,
						ei_raw.project_rate_date,
						ei_raw.project_rate_type,
						ei_raw.project_exchange_rate,
						ei_raw.projfunc_cost_rate_date,
						ei_raw.projfunc_cost_rate_type,
						ei_raw.projfunc_cost_exchange_rate),-1)
				AND nvl(PA_CLIENT_EXTN_BURDEN_RESOURCE.CLIENT_GROUPING(
					l_job_id_tbl(i),
					l_non_labor_resource_tbl(i),
					l_nl_res_orgn_id_tbl(i),
					l_wip_resource_id_tbl(i),
					l_incurred_by_person_id_tbl(i),
					l_inventory_item_id_tbl(i)), -1) =
					   nvl(PA_CLIENT_EXTN_BURDEN_RESOURCE.CLIENT_GROUPING(
						ei_raw.job_id,
						ei_raw.non_labor_resource,
						ei_raw.organization_id,
						ei_raw.wip_resource_id,
						expend.incurred_by_person_id,
						ei_raw.inventory_item_id),-1)
		     )
                     CONNECT BY PRIOR peia.transferred_from_exp_item_id = peia.expenditure_item_id
		     UNION ALL
		     select l_Exp_Item_Id_tbl(i),l_expenditure_type_tbl(i)
		       from  dual
		      where l_system_linkage_function_tbl(i) IN ('ST','OT','VI')
		        AND l_cdl_line_type_tbl(i) ='D')
	       and bc_cm.transfer_status_code in ('P','R','X')
	       and bc_cm.document_type = 'PO'
	       and bc_cm.burden_cost_flag = 'R'
	       and ((bc_cm.parent_bc_packet_id is not null AND l_cdl_line_type_tbl(i) ='R') OR  l_cdl_line_type_tbl(i) ='D');

 	 IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
 	  pa_funds_control_pkg.log_message(p_msg_token1 => 'INTERFACE_TBC_BTC_COMT_UPDATE :Number of PO commitments updated '||SQL%ROWCOUNT);
 	  pa_funds_control_pkg.log_message(p_msg_token1 => 'INTERFACE_TBC_BTC_COMT_UPDATE : End');
	 End if;

       END IF; --IF l_count_of_records <> 0 THEN

EXCEPTION
WHEN OTHERS THEN
   IF pa_funds_control_pkg.g_debug_mode = 'Y' THEN
      pa_funds_control_pkg.log_message(p_msg_token1 => 'INTERFACE_TBC_BTC_COMT_UPDATE :Exception '||SQLERRM);
      x_result_code := 'Error';
  End if;

END INTERFACE_TBC_BTC_COMT_UPDATE;

-- ----------------------------------------------------------------------------+
-- Function get_ratio will determine the burden to raw ratio.
-- This is used in cursor po_amounts and pkt_po_amounts in procedure
-- populate_burden_cost
-- ----------------------------------------------------------------------------+
Function get_ratio(p_document_header_id       in number,
                   p_document_distribution_id in number,
                   p_document_type            in varchar2,
                   p_mode                     in varchar2,
                   p_dr_cr                    in varchar2)
                   return number
is
 l_document_header_id           pa_bc_packets.document_header_id%type;
 l_document_distribution_id     pa_bc_packets.document_distribution_id%type;
 l_document_type                pa_bc_packets.document_type%type;
 l_ratio                        pa_bc_packets.accounted_dr%type;
Begin

 If (p_document_header_id       <> nvl(l_document_header_id,-1) and
     p_document_distribution_id <> nvl(l_document_distribution_id,-1) and
     p_document_type            <> nvl(l_document_type,'XX')
     ) then

     l_document_header_id       := p_document_header_id;
     l_document_distribution_id := p_document_distribution_id;
     l_document_type            := p_document_type;

      If p_mode ='BCPKT' then
         -- Burden/Raw ...
         SELECT sum(decode(parent_bc_packet_id,null,0,
                           decode(p_dr_cr,'A',abs(nvl(accounted_dr,0)-nvl(accounted_cr,0)),
                                  'E',abs(nvl(entered_dr,0)-nvl(entered_cr,0)))))/
                sum(decode(parent_bc_packet_id,null,
                           decode(p_dr_cr,'A',abs(nvl(accounted_dr,0)-nvl(accounted_cr,0)),
                                  'E',abs(nvl(entered_dr,0)-nvl(entered_cr,0)))
                           ,0))
         INTO   l_ratio
         FROM   pa_bc_packets pbc1
         WHERE  pbc1.packet_id = ( SELECT max(pbc.packet_id)
                                   FROM   pa_bc_packets pbc
                                   WHERE  pbc.document_distribution_id = l_document_distribution_id
                                   AND    pbc.document_header_id = l_document_header_id
                                   AND    pbc.document_type = l_document_type
                                   AND    pbc.parent_bc_packet_id is NULL
                                   AND    pbc.balance_posted_flag in ('N')
                                   AND    pbc.status_code in ('A','C')
                                   AND    substr(nvl(pbc.result_code,'P'),1,1) = 'P')
         AND  pbc1.document_distribution_id = l_document_distribution_id
         AND  pbc1.document_header_id = l_document_header_id
         AND  pbc1.document_type = l_document_type
         AND  pbc1.balance_posted_flag in ('N')
         AND  pbc1.status_code in ('A','C')
         AND  substr(nvl(pbc1.result_code,'P'),1,1) = 'P';

      ElsIf p_mode ='BCCMT' then

         SELECT sum(decode(parent_bc_packet_id,null,0,
                           decode(p_dr_cr,'A',abs(nvl(accounted_dr,0)-nvl(accounted_cr,0)),
                                  'E',abs(nvl(entered_dr,0)-nvl(entered_cr,0)))))/
                sum(decode(parent_bc_packet_id,null,
                           decode(p_dr_cr,'A',abs(nvl(accounted_dr,0)-nvl(accounted_cr,0)),
                                  'E',abs(nvl(entered_dr,0)-nvl(entered_cr,0)))
                           ,0))
         INTO   l_ratio
         FROM pa_bc_commitments comm1
         WHERE comm1.packet_id = ( SELECT max(comm.packet_id)
                                   FROM pa_bc_commitments comm
                                   WHERE comm.document_distribution_id = l_document_distribution_id
                                   AND comm.document_header_id = l_document_header_id
                                   AND comm.document_type = l_document_type
                                   AND comm.parent_bc_packet_id is NULL)
         AND  comm1.document_distribution_id = l_document_distribution_id
         AND  comm1.document_header_id = l_document_header_id
         AND  comm1.document_type = l_document_type;

      End If;
   return l_ratio;

 Else

     return l_ratio;

 End If;

End get_ratio;

-------->6599207 ------As part of CC Enhancements
PROCEDURE populate_plsql_tabs_CBC
		(p_packet_id  IN number
		,p_calling_module  IN varchar2
		,p_reference1  IN  varchar2
		,p_reference2  IN  varchar2
		,p_mode        IN  varchar2) IS

        l_request_id      NUMBER := fnd_global.conc_request_id();
        l_program_id      NUMBER := fnd_global.conc_program_id();
        l_program_application_id NUMBER:= fnd_global.prog_appl_id();
        l_update_login    NUMBER := FND_GLOBAL.login_id;
        l_num_rows        NUMBER := 0;
        l_return_status    VARCHAR2(1);
	l_debug_mode       VARCHAR2(10);

	/*CURSOR cur_gl_pkts IS
                SELECT  decode('Confirmed','CC_C_PAY',
                                'Provisional','CC_P_PAY'
                                ) document_type,
                        gl.last_update_date,
                        gl.last_updated_by,
                        gl.ledger_id set_of_books_id,
                        gl.je_source_name,
                        gl.je_category_name,
                        gl.reference1,
                        gl.reference2,
                        gl.reference3,
			gl.reference4,
			gl.reference5,
                        gl.actual_flag,
                        gl.period_name,
                        gl.period_year,
                        gl.period_num,
                        NVL(gl.entered_dr,0),
                        NVL(gl.entered_cr,0),
                        NVL(gl.accounted_dr,0),
                        NVL(gl.accounted_cr,0),
                        gl.ROWID,    --gl_row_bc_packet_row_id
                        gl.code_combination_id,
			NULL , --reference1
			NULL , --reference2
			NULL  --reference3
                FROM  gl_bc_packets gl
                WHERE gl.packet_id = p_packet_id
                AND   gl.je_source_name = 'Contract Commitment'
               		and gl.je_category_name in ('Confirmed','Provisional')
               		and EXISTS
              		( SELECT  'Project Related'
                	FROM    pa_tasks  pkt,
                        	pa_projects_all pp,
                        	igc_cc_acct_lines igc,
                        	igc_cc_det_pf igcpf,
                        	igc_cc_headers_all igchead,
				pa_implementations_all imp
                	WHERE igc.cc_header_id = gl.reference1
                	AND igchead.cc_header_id = igc.cc_header_id
                	AND igcpf.cc_det_pf_line_id = gl.reference4
                	AND igc.cc_acct_line_id = igcpf.cc_acct_line_id
                	AND igc.project_id IS NOT NULL
                	AND igc.project_id = pp.project_id
                	AND igc.task_id = pkt.task_id
                	AND pkt.project_id = pp.project_id
                	AND nvl(pp.org_id, -99)  = nvl(imp.org_id, -99)
                	AND imp.set_of_books_id = gl.ledger_Id
                        AND EXISTS
                              ( select 'Project Bdgt Ctrl enabled'
                                from  pa_budget_types bdgttype
                                  ,pa_budgetary_control_options pbct
                                where pbct.project_id = pp.project_id
                                and pbct.BDGT_CNTRL_FLAG = 'Y'
                                and (pbct.EXTERNAL_BUDGET_CODE = 'GL'
                                  OR
                                  pbct.EXTERNAL_BUDGET_CODE is NULL
                                 )
                                and pbct.BUDGET_TYPE_CODE = bdgttype.budget_type_code
                                and bdgttype.budget_amount_code = 'C'
                             )
                	);*/

     CURSOR cur_gl_pkts IS
     SELECT  decode(igchead.CC_STATE,'PR','CC_P_PAY','CC_C_PAY') document_type,
             igc.last_update_date,
             igc.last_updated_by,
             igc.set_of_books_id,
             'Contract Commitment' JeSourceName,
             decode(igchead.CC_STATE,'PR','Provisional','Confirmed') Category,
             to_char(igc.cc_header_id),
             NULL,
             NULL,
             to_char(igc.cc_det_pf_line_id),
	     NULL,
	     igc.CC_TRANSACTION_DATE gl_date,
             igc.actual_flag,
             glp.period_name,
             glp.period_year,
             glp.period_num,
             NVL(igc.cc_func_dr_amt,0) entered_dr,
             NVL(igc.cc_func_cr_amt,0) entered_cr,
             NVL(igc.cc_func_dr_amt,0) accounted_dr,
             NVL(igc.cc_func_cr_amt,0) accounted_cr,
             igc.ROWID,
             igc.code_combination_id,
	     igc.event_id,
             NULL ,
             NULL ,
             NULL
    FROM     igc_cc_interface igc,
             igc_cc_headers_all igchead,
             psa_bc_xla_events_gt pbgt,
             gl_period_statuses glp
    WHERE    pbgt.event_id = igc.event_id
    and      igc.cc_header_id = igchead.cc_header_id
    and      igc.budget_dest_flag = 'S'
    and      glp.application_id = 101
    and      glp.closing_status = 'O'
    and      glp.adjustment_period_flag = 'N'
    and      igc.cc_transaction_date between glp.start_date and glp.end_date
    and      glp.set_of_books_id = igc.set_of_books_id
    and      exists (select 1 from igc_cc_acct_lines igcc where igcc.cc_acct_line_id = igc.cc_acct_line_id
                     and project_id >0);


BEGIN

        fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
        l_debug_mode := NVL(l_debug_mode, 'N');

        PA_DEBUG.SET_PROCESS( x_process => 'PLSQL'
                             ,x_write_file     => 'LOG'
                             ,x_debug_mode      => l_debug_mode
                             );
	-- Initialize the pl/sql tabs
	init_plsql_tabs;

	IF p_calling_module = 'GL' then

		OPEN cur_gl_pkts;
		FETCH cur_gl_pkts BULK COLLECT INTO
                        g_tab_doc_type,
                        g_tab_last_update_date,
                        g_tab_last_updated_by,
                        g_tab_set_of_books_id,
                        g_tab_je_source_name,
                        g_tab_je_category_name,
                        g_tab_reference1,
                        g_tab_reference2,
                        g_tab_reference3,
                        g_tab_reference4,
                        g_tab_reference5,
			g_tab_gl_date,
                        g_tab_actual_flag,
                        g_tab_period_name,
                        g_tab_period_year,
                        g_tab_period_num,
                        g_tab_entered_dr,
                        g_tab_entered_cr,
                        g_tab_accounted_dr,
                        g_tab_accounted_cr,
                        g_tab_rowid,
                        g_tab_trxn_ccid,
			g_tab_event_id,
			g_tab_pkt_reference1,
                        g_tab_pkt_reference2,
                        g_tab_pkt_reference3;


		CLOSE cur_gl_pkts;
		pa_funds_control_pkg.log_message
		 (p_msg_token1 => 'Number of rows copied to plsql tabs :'||g_tab_rowid.count);
		If g_tab_rowid.EXISTS(1) then

			pa_funds_control_pkg.log_message
			 (p_msg_token1 => 'calling pa_multi_currency api to initialize the currency ');

        		-- initialize the accounting currency code,
        		pa_multi_currency.init;

        		--Get the accounting currency into a global variable.
        		g_acct_currency_code := pa_multi_currency.g_accounting_currency_code;

                        --insert these records into pa bc packets
                        pa_funds_control_pkg.log_message
                        (p_msg_token1 => 'calling create pkt lines api');

			create_CBC_pkt_lines
			   (p_calling_module   => p_calling_module
                           ,p_packet_id       => p_packet_id
                           ,p_reference1      => null
                           ,p_reference2      => null
			   ,p_mode            => p_mode);
		End if;

	ELSIF p_calling_module = 'CBC' and p_reference2 is NOT NULL then


                        pa_funds_control_pkg.log_message
                         (p_msg_token1 => 'calling pa_multi_currency api to initialize the currency ');

                        -- initialize the accounting currency code,
                        pa_multi_currency.init;

                        --Get the accounting currency into a global variable.
                        g_acct_currency_code := pa_multi_currency.g_accounting_currency_code;

                        --insert these records into pa bc packets
                        pa_funds_control_pkg.log_message
                        (p_msg_token1 => 'calling create pkt lines api');

			create_CBC_pkt_lines
			   (p_calling_module   => p_calling_module
                           ,p_packet_id       => p_packet_id
                           ,p_reference1      => p_reference1
                           ,p_reference2      => p_reference2
			   ,p_mode            => p_mode);

	END IF;

	RETURN;

EXCEPTION
	WHEN OTHERS THEN
		if cur_gl_pkts%isopen then
			close cur_gl_pkts;
		end if;
		RAiSE;

END populate_plsql_tabs_CBC;
-------->6599207 ------END

-------->6599207 ------As part of CC Enhancements
-- This procedure is created to initialize plsql tables
-- so as to use them while creating bcpackets.
PROCEDURE create_CBC_pkt_lines(p_calling_module   IN varchar2,
			   p_packet_id        IN number
			   ,p_reference1      IN VARCHAR2
			   ,p_reference2      IN VARCHAR2
			   ,p_mode            IN  varchar2) IS

        l_counter NUMBER :=0;

	CURSOR cur_igc_details( p_reference1    IN varchar2
                                ,p_reference2   IN varchar2
                                ,p_reference3   IN varchar2
                                ,p_reference4   IN varchar2
                                ,p_reference5   IN varchar2
                                ,p_doc_type     IN varchar2)  IS
                SELECT  p_reference1 document_header_id,
                        igc.cc_acct_line_id document_distribution_id,
                        NULL budget_version_id,
                        igc.project_id,
                        igc.task_id,
                        igc.expenditure_type,
                        igc.expenditure_org_id,
                        trunc(igc.expenditure_item_date),
                        igchead.org_id,
                        'N' balance_posted_flag,
                        'T' funds_process_mode,
                        'N' burden_cost_flag,
                        NULL  result_code,
                        'I' status_code,
                        pa_funds_control_utils.get_fnd_reqd_flag(pp.project_id ,'STD') fck_reqd_flag,
			null parent_bc_packet_id,
	                NULL main_or_backing_code,
	                pa_funds_control_pkg.check_bdn_on_sep_item(igc.project_id) burden_method_code,
	                NULL budget_line_id,
                        NULL source_event_id,
	                NULL distribution_type,
	                NULL po_release_Id,
	                PA_FUNDS_CONTROL_UTILS.get_encum_type_id(igc.project_id,'STD') enc_type_id,
	                igchead.vendor_id,
	                pa_bc_packets_s.nextval
                FROM    pa_tasks  pkt,
                        pa_projects_all pp,
                        igc_cc_acct_lines igc,
                        igc_cc_det_pf igcpf,
                        igc_cc_headers_all igchead
                WHERE igc.cc_header_id = p_reference1
                AND igchead.cc_header_id = igc.cc_header_id
                AND igcpf.cc_det_pf_line_id = p_reference4
                AND igc.cc_acct_line_id = igcpf.cc_acct_line_id
                AND igc.project_id IS NOT NULL
                AND igc.project_id = pp.project_id
                AND igc.task_id = pkt.task_id
                AND pkt.project_id = pp.project_id
                AND EXISTS ( select 'Project Bdgt Ctrl enabled'
                             from  pa_budget_types bdgttype
                                  ,pa_budgetary_control_options pbct
                             where pbct.project_id = pp.project_id
                             and pbct.BDGT_CNTRL_FLAG = 'Y'
                             and (pbct.EXTERNAL_BUDGET_CODE = 'GL'
                                  OR
                                  pbct.EXTERNAL_BUDGET_CODE is NULL
                                 )
                             and pbct.BUDGET_TYPE_CODE = bdgttype.budget_type_code
                             and bdgttype.budget_amount_code = 'C'
                           );


	CURSOR cur_cbc_details(p_reference1  in  varchar2
			        ,p_reference2 in varchar2) IS
                SELECT
                        igci.last_update_date,
                        igci.last_updated_by,
                        igci.last_updated_by,
                        NULL budget_version_id,
                        igc.project_id,
                        igc.task_id,
                        igc.expenditure_type,
                        igc.expenditure_org_id,
                        trunc(igc.expenditure_item_date),
                        igci.set_of_books_id,
                        'Contract Commitment' JeSourceName, -- igci.je_source_name,
                        decode(igchead.CC_STATE,'PR','Provisional','Confirmed') Category,        -- igci.je_category_name,
                        decode(decode(igchead.CC_STATE,'PR','Provisional','Confirmed'),'Confirmed','CC_C_CO',
                                                     'Provisional','CC_P_CO')
				document_type,
                        igci.cc_header_id,
                        igci.cc_acct_line_id,
                        igci.actual_flag,
 		        igci.cc_acct_line_id line_id,
			NULL event_id,
			igchead.vendor_id,
			NULL main_or_backing_code,
			pa_funds_control_pkg.check_bdn_on_sep_item(igc.project_id) burden_method_code,
			NULL budget_line_id,
			igci.event_id source_event_id,
			igc.CC_ACCT_ENCMBRNC_DATE gl_date,
			NULL distribution_type,
			NULL po_release_Id,
			PA_FUNDS_CONTROL_UTILS.get_encum_type_id(igc.project_id,'STD') enc_type_id,
                        gl.period_name, --igci.period_name,
                        NULL  period_year, --igci.period_year,
                        NULL  period_num, --igci.period_num,
                        NULL  result_code, -- result_code
                        'P'   status_code, -- status_code,
                        NVL(igci.cc_func_dr_amt,0),
                        NVL(igci.cc_func_cr_amt,0),
                        NVL(igci.cc_func_dr_amt,0),
                        NVL(igci.cc_func_cr_amt,0),
                        igci.ROWID,    --gl_row_bc_packet_row_id
                        'N' balance_posted_flag,
                        'T' funds_process_mode, -- T - transaction B- base line
                        igci.code_combination_id,
                        'N'  burden_cost_flag,  -- original transaction (raw)
                        igchead.org_id,
                        pa_funds_control_utils.get_fnd_reqd_flag
                        (pp.project_id ,'STD') fck_reqd_flag,
                        null parent_bc_packet_id,
                        decode(igci.je_category_name,'Confirmed','CC_C_CO',
                                                     'Provisional','CC_P_CO')
                                pkt_reference1,
                        igci.cc_header_id pkt_reference2,
                        igci.cc_acct_line_id pkt_reference3,
			pa_bc_packets_s.nextval
                FROM
                        pa_tasks  pkt,
                        pa_projects_all pp,
                        igc_cc_interface  igci,
                        igc_cc_acct_lines igc,
                        igc_cc_headers_all igchead,
			gl_period_statuses gl,
			pa_implementations_all imp
                WHERE igc.cc_header_id = p_reference2
                AND p_reference1 = 'CC'
                AND igchead.cc_header_id = igc.cc_header_id
                AND igc.project_id IS NOT NULL
                AND igc.project_id = pp.project_id
                AND igc.cc_header_id = igci.cc_header_id
                AND igc.cc_acct_line_id = igci.cc_acct_line_id
                AND pkt.task_id = igc.task_id
                AND pkt.project_id = pp.project_id
		AND gl.application_id = 101
		ANd gl.set_of_books_id = igci.set_of_books_id
		AND gl.ADJUSTMENT_PERIOD_FLAG <> 'Y'
		AND trunc(igci.cc_transaction_date)
			between gl.start_date  and gl.end_date
		AND nvl(pp.org_id, -99)  = nvl(imp.org_id, -99)
                AND imp.set_of_books_id = (SELECT imp1.set_of_books_id
					   FROM pa_implementations_all imp1 where org_id = pp.org_id)
                AND EXISTS ( select 'Project Bdgt Ctrl enabled'
                             from  pa_budget_types bdgttype
                                  ,pa_budgetary_control_options pbct
                             where pbct.project_id = pp.project_id
                             and pbct.BDGT_CNTRL_FLAG = 'Y'
                             and pbct.EXTERNAL_BUDGET_CODE = 'CC'
                             and pbct.BUDGET_TYPE_CODE = bdgttype.budget_type_code
                             and bdgttype.budget_amount_code = 'C'
                           );
BEGIN


	pa_funds_control_pkg.log_message(p_msg_token1 => 'Inside create_bc_pkt api calling module ['
					 ||p_calling_module||'] g_tab_rowid.count['||g_tab_rowid.count||']'  );

	IF p_calling_module = 'GL' and g_tab_rowid.EXISTS(1) then

		FOR i IN g_tab_rowid.FIRST ..g_tab_rowid.LAST LOOP
		        l_counter := l_counter + 1;
			pa_funds_control_pkg.log_message(p_msg_token1 => 'inside for loop l_counter'||l_counter);

                    IF g_tab_doc_type(i)  in ('CC_C_PAY','CC_P_PAY') then
                        pa_funds_control_pkg.log_message
				(p_msg_token1 =>'doc type is '||g_tab_doc_type(i));
                                g_tab_p_bc_packet_id(i) := null;
                                OPEN cur_igc_details(g_tab_reference1(i),
                                                     g_tab_reference2(i),
                                                     g_tab_reference3(i),
                                                     g_tab_reference4(i),
                                                     g_tab_reference5(i),
                                                     g_tab_doc_type(i));

                                FETCH cur_igc_details INTO
                                        g_tab_doc_header_id(i),
                                        g_tab_doc_distribution_id(i),
                                        g_tab_budget_version_id(i),
                                        g_tab_project_id(i),
                                        g_tab_task_id(i),
                                        g_tab_exp_type(i),
                                        g_tab_exp_org_id(i),
                                        g_tab_exp_item_date(i),
                                        g_tab_org_id(i),
                                        g_tab_balance_posted_flag(i),
                                        g_tab_funds_process_mode(i),
                                        g_tab_burden_cost_flag(i),
                                        g_tab_result_code(i),
                                        g_tab_status_code(i),
                                        g_tab_fck_reqd_flag(i),
					g_tab_p_bc_packet_id(i),
                                        g_tab_main_or_backing_code(i),
			                g_tab_burden_method_code(i),
			                g_tab_budget_line_id(i),
			                g_tab_source_event_id(i),
			                g_tab_distribution_type(i),
			                g_tab_po_release_id(i),
			                g_tab_enc_type_id(i),
			                g_tab_vendor_id(i),
			                g_tab_bc_packet_id(i);

                                pa_funds_control_pkg.log_message(p_msg_token1 => 'fetch cursor');
                                g_tab_p_bc_packet_id(i) := null;
				g_tab_doc_line_id(i) := NULL;
                                /* added for bug fix: 3086398 */
                                IF cur_igc_details%found then
				    g_tab_pkt_reference1(i) := g_tab_doc_type(i);
                                    g_tab_pkt_reference2(i) := g_tab_doc_header_id(i);
                                    g_tab_pkt_reference3(i) := g_tab_doc_distribution_id(i);

                                    g_tab_budget_version_id(i) := pa_funds_control_utils2.GET_DRAFTORBASELINE_BDGTVER
                                                                     (g_tab_project_id(i),'GL','BASELINE');
                                    If (g_tab_budget_version_id(i) is NULL ) Then
                                            g_tab_result_code(i)   := 'F166';
                                            g_tab_status_code(i)   := 'R';
                                            g_tab_fck_reqd_flag(i) := 'Y';
                                            g_tab_budget_version_id(i) := NVL(pa_funds_control_utils2.GET_DRAFTORBASELINE_BDGTVER
                                                (g_tab_project_id(i),'GL','DRAFT'),-9999);

                                    End If;
                                    pa_funds_control_pkg.log_message(p_msg_token1 => 'igc cursor Bdgt_Version['
						||g_tab_budget_version_id(i)||']');
                                    /* end of bug fix:3086398 */
                                Elsif cur_igc_details%NOTfound then
                                        pa_funds_control_pkg.log_message(p_msg_token1 => 'cur not found');
					assign_plsql_tabs(p_counter => l_counter,
                                                          p_fck_reqd_flag =>null);
                                End if;

                                CLOSE cur_igc_details;
				null;
			END IF;

		  END LOOP;

               /* pa_funds_control_pkg.log_message(p_msg_token1 => 'calling Load_pkt API');
                If g_tab_rowid.EXISTS(1) then
                        Load_pkts(p_packet_id, p_mode);
                End if;*/

                pa_funds_control_pkg.log_message(p_msg_token1 => 'end of create_pkt_lines api');

	ELSIF p_calling_module = 'CBC' and p_reference1 is not null and p_reference2 is NOT NULL then

		pa_funds_control_pkg.log_message(p_msg_token1 => 'calling module ['||p_calling_module||
		']p_reference1 ['||p_reference1|| ']p_reference2 ['||p_reference2|| ']opening cursor cur_cbc_details');

		OPEN cur_cbc_details(p_reference1,p_reference2);
		FETCH cur_cbc_details BULK COLLECT INTO
                        g_tab_last_update_date,
                        g_tab_last_updated_by,
                        g_tab_last_updated_by,
                        g_tab_budget_version_id,
                        g_tab_project_id,
                        g_tab_task_id,
                        g_tab_exp_type,
                        g_tab_exp_org_id,
                        g_tab_exp_item_date,
                        g_tab_set_of_books_id,
                        g_tab_je_source_name,
                        g_tab_je_category_name,
                        g_tab_doc_type,
                        g_tab_doc_header_id,
                        g_tab_doc_distribution_id,
                        g_tab_actual_flag,
			g_tab_doc_line_id,
			g_tab_event_id,
			g_tab_vendor_id,
			g_tab_main_or_backing_code,
			g_tab_burden_method_code,
			g_tab_budget_line_id,
			g_tab_source_event_id,
			g_tab_gl_date,
			g_tab_distribution_type,
			g_tab_po_release_id,
			g_tab_enc_type_id,
                        g_tab_period_name,
                        g_tab_period_year, --igci.period_year,
                        g_tab_period_num, --igci.period_num,
                        g_tab_result_code, -- result_code
                        g_tab_status_code, -- status_code,
                        g_tab_entered_dr,
                        g_tab_entered_cr,
                        g_tab_accounted_dr,
                        g_tab_accounted_cr,
                        g_tab_rowid,
                        g_tab_balance_posted_flag,
                        g_tab_funds_process_mode, -- T - transaction B- base line
                        g_tab_trxn_ccid,
                        g_tab_burden_cost_flag,  -- original transaction (raw)
                        g_tab_org_id,
                        g_tab_fck_reqd_flag,
                        g_tab_p_bc_packet_id,
			g_tab_pkt_reference1,
			g_tab_pkt_reference2,
			g_tab_pkt_reference3,
			g_tab_bc_packet_id;

		CLOSE cur_cbc_details;


		If g_tab_rowid.EXISTS(1) then
                        /* added for bug fix: 3086398 */
                        FOR i IN g_tab_rowid.FIRST .. g_tab_rowid.LAST LOOP
				  g_tab_doc_line_id(i) := NULL;
                                  g_tab_budget_version_id(i) := pa_funds_control_utils2.GET_DRAFTORBASELINE_BDGTVER
                                                                     (g_tab_project_id(i),'CC','BASELINE');
                                  If (g_tab_budget_version_id(i) is NULL ) Then
                                            g_tab_result_code(i)   := 'F166';
                                            g_tab_status_code(i)   := 'R';
                                            g_tab_fck_reqd_flag(i) := 'Y';
                                            g_tab_budget_version_id(i) := NVL(pa_funds_control_utils2.GET_DRAFTORBASELINE_BDGTVER
                                                (g_tab_project_id(i),'CC','DRAFT'),-9999);

                                  End If;
                        END LOOP;
                        /* end of bug fix:3086398 */
			pa_funds_control_pkg.log_message(p_msg_token1 =>'cur found calling Load_pkt API');
			Load_pkts(p_packet_id, p_mode, 'CBC');


		Else
			pa_funds_control_pkg.log_message(p_msg_token1 => ' cur_cbc_details not found');
			null;
		End if;
		pa_funds_control_pkg.log_message(p_msg_token1 => 'end of create_pkt_lines api');

	END IF;

END create_CBC_pkt_lines;
-------->6599207 ------END

-----------------------------------------------------------------
--This api initializes the plsql tables at the specified index
-------->6599207 ------As part of CC Enhancements
-----------------------------------------------------------------
PROCEDURE assign_plsql_tabs(p_counter IN NUMBER,
			    p_fck_reqd_flag  varchar2 default null) IS

BEGIN

	g_tab_doc_header_id(p_counter) := null;
	g_tab_doc_line_id(p_counter) := null;
	g_tab_doc_distribution_id(p_counter) := null;
	g_tab_budget_version_id(p_counter) := null;
	g_tab_project_id(p_counter) := null;
	g_tab_task_id(p_counter) := null;
	g_tab_exp_type(p_counter) := null;
	g_tab_exp_org_id(p_counter) := null;
	g_tab_exp_item_date(p_counter) := null;
	g_tab_org_id(p_counter) := null;
	g_tab_balance_posted_flag(p_counter) := null;
	g_tab_funds_process_mode(p_counter) := null;
	g_tab_burden_cost_flag(p_counter) := null;
	g_tab_result_code(p_counter) := null;
	g_tab_status_code(p_counter) := 'P';
	g_tab_p_bc_packet_id(p_counter) := null;
	g_tab_fck_reqd_flag(p_counter) := nvl(p_fck_reqd_flag,'N');

EXCEPTION

	when others then
		raise;

END assign_plsql_tabs;

END PA_FUNDS_CONTROL_PKG1;

/
