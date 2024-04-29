--------------------------------------------------------
--  DDL for Package Body GMS_BUDGET_BALANCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_BUDGET_BALANCE" AS
-- $Header: gmsfcupb.pls 120.11.12010000.3 2010/01/20 05:34:15 anuragar ship $

-- To check on, whether to print debug messages in log file or not
 L_DEBUG varchar2(1) := NVL(FND_PROFILE.value('GMS_ENABLE_DEBUG_MODE'), 'N');

 G_PO_QUANTITY_BILLED  NUMBER; -- Bug 2721095
 G_PO_DISTRIBUTION_ID  NUMBER; -- Bug 2721095

 Procedure update_gms_balance (x_project_id	IN  number,
   			    	x_award_id	IN  number,
					x_mode      IN  varchar2,
			    	ERRBUF	  	OUT NOCOPY varchar2,
		   	    	RETCODE	  	OUT NOCOPY varchar2) is
-- x_baseline_flag  = 'Y' process called to base line a budget
-- x_baseline_flag  = 'N' process called to update balance
 x_sob_id			number;
 x_packet_id			number;
 x_budget_version_id 		number;
 x_e_code			varchar2(1) := null;
 x_e_stage	 		varchar2(10) := null;
 x_e_mesg	 		varchar2(2000) := null;
 x_user_id			number;
 x_user_resp_id  		number;
 x_execute			varchar2(1) := 'Y';
 x_partial			varchar2(1) := 'N';
 x_return_code  		varchar2(3);
 x_run  			number := 0;
 x_fcmode			varchar2(1) := 'R';
 x_over 			varchar2(1) := 'N';
 x_budget_total		number := 0;
 x_award_total		number := 0;
 x_temp			number;
 x_err_code		number;
 x_err_buff		varchar2(2000);
 x_fc_required_flag	varchar2(1);
 x_base_bud_version_id number;
 x_dummy 		number;

-- Variables for error handling .
   g_error_program_name     VARCHAR2 ( 30 )                 := 'GMS_BUDGET_BALANCE';
   g_error_procedure_name   VARCHAR2 ( 30 );
   g_error_stage            VARCHAR2 ( 30 );

resource_busy exception;
pragma exception_init(resource_busy,-00054);
cursor gms_bal_lock is
select end_date from gms_balances
where budget_version_id = x_budget_version_id
for update nowait;
---------------------------------------------------------------------------------------------
-- procedure to re-create the gms_balance records from GMS_BUDGET_LINES
-- and to clean up GMS_BC_PACKETs
-- Added x_project_id and x_award_id parameter : ported Bug 1703510

procedure create_gms_balance( x_budget_version_id in number, x_set_of_books_id in number,
x_project_id in number, x_award_id in number) is
begin
   delete from gms_balances where budget_version_id = x_budget_version_id;
	--Commented the above line for history purposes 11i change.

-- Added x_project_id and x_award_id to delete so that it hits N2 index : ported Bug 1703510

   delete from gms_bc_packets
   where project_id = x_project_id
   and award_id = x_award_id
   and budget_version_id = x_budget_version_id;

-- insert into gms_balances table from gms_budget_lines
  insert into gms_balances (
 	PROJECT_ID,
 	AWARD_ID,
 	TASK_ID,
	TOP_TASK_ID,
 	RESOURCE_LIST_MEMBER_ID,
	BALANCE_TYPE,
 	SET_OF_BOOKS_ID,
 	BUDGET_VERSION_ID,
 	LAST_UPDATE_DATE,
 	LAST_UPDATED_BY,
 	CREATED_BY,
 	CREATION_DATE,
 	LAST_UPDATE_LOGIN,
 	PERIOD_NAME,
 	START_DATE,
 	END_DATE,
 	PARENT_MEMBER_ID,
 	BUDGET_PERIOD_TO_DATE)
  select
	ga.project_id,
	gv.award_id,
	ga.task_id,
	pt.top_task_id,
	ga.resource_list_member_id,
	'BGT',
	x_set_of_books_id,
	gv.budget_version_id,
	sysdate,
 	FND_GLOBAL.USER_ID,
 	FND_GLOBAL.USER_ID,
 	sysdate,
 	FND_GLOBAL.LOGIN_ID,
 	gb.PERIOD_NAME,
 	gb.START_DATE,
 	gb.END_DATE,
 	rm.PARENT_MEMBER_ID,
 	gb.burdened_cost   --gb.raw_cost
  from
	gms_budget_lines gb,
	gms_resource_assignments ga,
	pa_tasks pt,
	pa_resource_list_members rm,
	gms_budget_versions gv
  where gv.budget_version_id = x_budget_version_id
  and	ga.resource_assignment_id = gb.resource_assignment_id
  and   ga.task_id = pt.task_id (+)
  and   ga.budget_version_id = gv.budget_version_id
  and	rm.resource_list_member_id = ga.resource_list_member_id;
exception
  when no_data_found then
    RETCODE := 'E';
    ERRBUF  := 'NO_DRAFT_BUDGET_BUDGET';
end create_gms_balance;
-----------------------------------------------------------------------------
--Procedure to load all the raw  transactions in GMS_BC_PACKETS for funds check
procedure create_direct_cost(x_packet_id 	IN number,
			     x_sob_id	 	in number,
			     x_project_id  	in number,
                             x_award_id 	in number,
                             x_budget_version_id 	in number) IS
x_err_code number;
x_err_buff varchar2(2000);
BEGIN
   begin
	-- ---------------------------------------------------------------
	-- TO INSERT Commitments (Requisitions)		Bug 2009836
	-- ---------------------------------------------------------------
	      --
            -- Bug : 3362016 Grants integrations with CWK and PO Services.
            -- sub select added in the from clause to use PO encumbered amount api.
		insert into gms_bc_packets (
			packet_id,
			set_of_books_id,
			je_source_name,
			je_category_name,
			actual_flag,
			period_name,
			period_year,
			period_num,
			project_id,
			task_id,
			award_id,
			status_code,
			last_update_date,
			last_updated_by,
			created_by,
			creation_date,
			last_update_login,
			entered_dr,
			entered_cr,
			expenditure_type,
			expenditure_organization_id,
			expenditure_item_date,
			document_type,
			document_header_id,
			document_distribution_id,
			transfered_flag,
			account_type,
			budget_version_id,
			bc_packet_id,
			burdenable_raw_cost,
 		    	vendor_id,			 -- Bug 2069132 ( RLMI Change)
			expenditure_category,	 -- Bug 2069132 ( RLMI Change)
			revenue_category,		 -- Bug 2069132 ( RLMI Change)
			ind_compiled_set_id	 -- Bug 2387678 ( Performance Tuning )
			)
		select
			x_packet_id,
			x_sob_id,
			'Purchasing',
			'Requisitions',
			'E',
			vw.period_name,
			vw.period_year,
			vw.period_num,
			vw.project_id,
			vw.task_id,
			vw.award_id ,
			'P',
			sysdate,
			fnd_global.user_id,
			fnd_global.user_id,
			sysdate,
			fnd_global.login_id,
			decode(sign(vw.amount), 1, vw.amount, 0),
			decode(sign(vw.amount), -1,vw.amount, 0),
			vw.expenditure_type,
			vw.expenditure_organization_id,
			vw.expenditure_item_date,
			'REQ',
			vw.requisition_header_id,
			vw.distribution_id,
			'Y',
			'E',
			x_budget_version_id,
			gms_bc_packets_s.nextval,
			vw.burdenable_raw_cost,
			vw.vendor_id,
			vw.expenditure_category,
			vw.revenue_category_code,
			vw.ind_compiled_set_id
		FROM
			( select gps.period_name,
			         gps.period_year,
			         gps.period_num,
			         adl.project_id,
			         adl.task_id,
			         adl.award_id ,
                                 PO_INTG_DOCUMENT_FUNDS_GRP.get_active_encumbrance_func
						 ('REQUISITION', RD.DISTRIBUTION_ID) amount,
			         rd.expenditure_type,
			         rd.expenditure_organization_id,
			         trunc(rd.expenditure_item_date) expenditure_item_date,
			         rd.distribution_id,
			         adl.burdenable_raw_cost,
			         pet.expenditure_category,
	            	         pet.revenue_category_code,
			         adl.ind_compiled_set_id,
                                 rd.requisition_line_id,
			         rh.requisition_header_id,
			         rl.vendor_id
			    from po_req_distributions_all  rd,
			         gms_award_distributions   adl,
			         po_requisition_lines_all   rl,
			         po_requisition_headers_all rh,
			         gl_period_statuses         gps,
			         pa_expenditure_types       pet
		         WHERE RH.REQUISITION_HEADER_ID      = RL.REQUISITION_HEADER_ID
		           AND RH.TYPE_LOOKUP_CODE           = 'PURCHASE'
		           AND NVL(RL.MODIFIED_BY_AGENT_FLAG,'N') = 'N'
		           AND RL.SOURCE_TYPE_CODE           = 'VENDOR'
		           AND RD.REQUISITION_LINE_ID        = RL.REQUISITION_LINE_ID
                           AND RD.ENCUMBERED_FLAG            = 'Y'
		           AND ADL.PROJECT_ID    	     = X_PROJECT_ID
		           AND ADL.AWARD_ID      	     = X_AWARD_Id
		           AND ADL.DISTRIBUTION_ID           = RD.DISTRIBUTION_ID
		           AND ADL.ADL_STATUS    	     = 'A'
		           AND ADL.DOCUMENT_TYPE             = 'REQ'
		           AND NVL(ADL.FC_STATUS,'N')	     = 'A'
		           AND RD.PROJECT_ID     	     = ADL.PROJECT_ID
		           AND RD.TASK_ID            	     = ADL.TASK_ID
		           AND RD.AWARD_ID		     = ADL.AWARD_SET_ID
		           AND trunc(RD.EXPENDITURE_ITEM_DATE) BETWEEN trunc(GPS.START_DATE)
                                AND trunc(GPS.END_DATE) --Bug 9232992
		           AND GPS.ADJUSTMENT_PERIOD_FLAG    = 'N'
		           AND GPS.APPLICATION_ID            = 101
		           AND GPS.SET_OF_BOOKS_ID           = X_SOB_ID
	                 AND pet.expenditure_type            = rd.expenditure_type
                      )  VW
		 WHERE nvl(VW.amount,0) <> 0 ;
        	-- ---------------------------------------------------------------
        	-- TO INSERT Commitments (Purchase Order)	Bug 2009836
        	-- ---------------------------------------------------------------
	      --
            -- Bug : 3362016 Grants integrations with CWK and PO Services.
            -- sub select added in the from clause to use PO encumbered amount api.
		insert into gms_bc_packets (
			packet_id,
			set_of_books_id,
			je_source_name,
			je_category_name,
			actual_flag,
			period_name,
			period_year,
			period_num,
			project_id,
			task_id,
			award_id,
			status_code,
			last_update_date,
			last_updated_by,
			created_by,
			creation_date,
			last_update_login,
			entered_dr,
			entered_cr,
			expenditure_type,
			expenditure_organization_id,
			expenditure_item_date,
			document_type,
			document_header_id,
			document_distribution_id,
			transfered_flag,
			account_type,
			budget_version_id,
			bc_packet_id,
			burdenable_raw_cost,
			vendor_id,			 -- Bug 2069132 ( RLMI Change)
		    	expenditure_category,	 	 -- Bug 2069132 ( RLMI Change)
			revenue_category,		 -- Bug 2069132 ( RLMI Change)
			ind_compiled_set_id		 -- Bug 2387678 ( Performance Tuning )
			)
		select
			x_packet_id,
			x_sob_id,
			'Purchasing',
			'Purchases',
			'E',
			vw.period_name,
			vw.period_year,
			vw.period_num,
			vw.project_id,
			vw.task_id,
			vw.award_id,
			'P',
			sysdate,
			fnd_global.user_id,
			fnd_global.user_id,
			sysdate,
			fnd_global.login_id,
                        vw.amount,
			0, 			-- Entered_Cr
			vw.expenditure_type,
			vw.expenditure_organization_id,
			vw.expenditure_item_date,
			'PO',
			vw.po_header_id,
			vw.po_distribution_id,
			'Y',
			'E',
			x_budget_version_id,
			gms_bc_packets_s.nextval,
			vw.burdenable_raw_cost,
 		        vw.vendor_id,			 -- Bug 2069132 ( RLMI Change)
			vw.expenditure_category,	 -- Bug 2069132 ( RLMI Change)
			vw.revenue_category_code,	 -- Bug 2069132 ( RLMI Change)
                        vw.ind_compiled_set_id          -- Bug 2387678 (Performance Tuning)
		FROM (select
				gps.period_name,
				gps.period_year,
				gps.period_num,
				adl.project_id,
				adl.task_id,
				adl.award_id,
				PO_INTG_DOCUMENT_FUNDS_GRP.get_active_encumbrance_func
					    ('PO', pod.po_DISTRIBUTION_ID) amount,
				pod.expenditure_type,
				pod.expenditure_organization_id,
				trunc(pod.expenditure_item_date) expenditure_item_date,
				pod.po_header_id,
				pod.po_distribution_id,
				adl.burdenable_raw_cost,
	            	        poh.vendor_id,
				pet.expenditure_category,
				pet.revenue_category_code,
            		        adl.ind_compiled_set_id
			FROM
				po_headers_all          poh,
				po_lines_all            pol,
				po_line_locations_all   pll,
				po_releases_all         por,
				po_distributions_all    pod,
				gms_award_distributions adl,
				gl_period_statuses      gps,
				pa_expenditure_types    pet
       		          WHERE POH.TYPE_LOOKUP_CODE IN ('STANDARD','BLANKET','PLANNED')
			    AND POL.PO_HEADER_ID      = POH.PO_HEADER_ID
			    AND POL.PO_LINE_ID        = PLL.PO_LINE_ID
		            AND PLL.SHIPMENT_TYPE IN ('STANDARD','BLANKET','SCHEDULED','PLANNED')
		            AND PLL.LINE_LOCATION_ID  = POD.LINE_LOCATION_ID
		            AND PLL.PO_RELEASE_ID     = POR.PO_RELEASE_ID (+)
                            AND  PO_INTG_DOCUMENT_FUNDS_GRP.get_active_encumbrance_func   /*Bug 6085276 */
                                            ('PO', pod.po_DISTRIBUTION_ID) <> 0
                            AND NVL(POH.CLOSED_CODE,'OPEN') <> 'FINALLY CLOSED' /* 6085276 */
			    AND NVL(pll.closed_code,'OPEN') <> 'FINALLY CLOSED' /* 6085276 */
                          /*AND POD.ENCUMBERED_FLAG   = 'Y'             Commented for bug 6085276 */
		            AND POD.PROJECT_ID        = X_PROJECT_ID
		            AND POD.DISTRIBUTION_TYPE <> 'PREPAYMENT' -- Complex work/subcontractor uptake
		            AND ADL.AWARD_ID          = X_AWARD_Id
		            AND ADL.PROJECT_ID        = POD.PROJECT_ID
		            AND ADL.PO_DISTRIBUTION_ID= POD.PO_DISTRIBUTION_ID
		            AND ADL.TASK_ID           = POD.TASK_ID
		            AND POD.AWARD_ID	      = ADL.AWARD_SET_ID
		            AND ADL.ADL_STATUS        = 'A'
		            AND ADL.DOCUMENT_TYPE     = 'PO'
		            AND NVL(ADL.FC_STATUS,'N')= 'A'
		            AND trunc(POD.EXPENDITURE_ITEM_DATE) BETWEEN trunc(GPS.START_DATE)
                                AND trunc(GPS.END_DATE) --Bug 9232992
		            AND GPS.ADJUSTMENT_PERIOD_FLAG  = 'N'
		            AND GPS.APPLICATION_ID          = 101
		            AND GPS.SET_OF_BOOKS_ID         = X_SOB_ID
    	                    AND pet.expenditure_type = pod.expenditure_type ) VW
            	WHERE NVL(VW.amount,0) <> 0 ;

	-- ---------------------------------------------------------------
	-- TO INSERT Commitments (AP)
	-- ---------------------------------------------------------------
	-- ---------------------------------------------------------------
	-- Bug Fix 2170878. Removed invoice_distribution_id join.In some
	-- scenarios id is null on ad
	-- ---------------------------------------------------------------
     insert into gms_bc_packets (
				  packet_id,
                                  set_of_books_id,
                                  je_source_name,
                                  je_category_name,
				  actual_flag,
                                  period_name,
                                  period_year,
				  period_num,
                                  project_id,
                                  task_id,
                                  award_id,
                                  status_code,
                                  last_update_date,
                                  last_updated_by,
                                  created_by,
                                  creation_date,
                                  last_update_login,
                                  entered_dr,
                                  entered_cr,
                                  expenditure_type,
                                  expenditure_organization_id,
                                  expenditure_item_date,
                                  document_type,
                                  document_header_id,
                                  document_distribution_id,
				  TRANSFERED_FLAG,
				  account_type,
				  budget_version_id,
			          bc_packet_id,
 				  burdenable_raw_cost,
				  vendor_id,			 -- Bug 2069132 ( RLMI Change)
				  expenditure_category,	 	 -- Bug 2069132 ( RLMI Change)
				  revenue_category,		 -- Bug 2069132 ( RLMI Change)
                        	  ind_compiled_set_id              -- Bug 2387678 ( Performance Tuning )
				  )
        select
			x_packet_id,
        		x_sob_id,
        		'Payables',         -- Bug 2603943
			'Purchase Invoices',
        		'E',
        		gps.period_name,
        		gps.period_year,
	 		gps.period_num,
        		adl.project_id,
        		adl.task_id,
        		adl.award_id,
			'P',
        		sysdate,
 	  		FND_GLOBAL.USER_ID,
 			FND_GLOBAL.USER_ID,
 	  		sysdate,
 	  		FND_GLOBAL.LOGIN_ID,
                        -- Added below NVL clause as the base_amount  stores correct amount in multi currency scenario
			-- Bug 1980810 PA Rounding function added
        		pa_currency.round_currency_amt(decode(sign(pa_cmt_utils.get_apdist_amt( aid.invoice_distribution_id,
								     aid.invoice_id,
								     nvl(aid.base_amount,aid.amount),
								     'N', 'GMS', nvl(g.sla_ledger_cash_basis_flag,'N'))),
                                                              1, pa_cmt_utils.get_apdist_amt( aid.invoice_distribution_id,
											     aid.invoice_id,
											     nvl(aid.base_amount,aid.amount),
											     'N', 'GMS', nvl(g.sla_ledger_cash_basis_flag,'N')) ,
                                                              0)),  -- Bug 2386531
        		pa_currency.round_currency_amt(decode(sign(pa_cmt_utils.get_apdist_amt( aid.invoice_distribution_id,
												     aid.invoice_id,
												     nvl(aid.base_amount,aid.amount),
												     'N', 'GMS',nvl(g.sla_ledger_cash_basis_flag,'N') )),
                                                             -1,abs( pa_cmt_utils.get_apdist_amt( aid.invoice_distribution_id,
												     aid.invoice_id,
												     nvl(aid.base_amount,aid.amount),
												     'N', 'GMS', nvl(g.sla_ledger_cash_basis_flag,'N') )),
                                                             0)),--Bug 2386531
        		aid.expenditure_type,
        		aid.expenditure_organization_id,
        		aid.expenditure_item_date,
        		'AP',
        		aid.invoice_id,
        		aid.invoice_distribution_id, -- AP Lines change
			'Y',
			'E',
	  		x_budget_version_id,
			gms_bc_packets_s.nextval,
        		adl.burdenable_raw_cost,
        		ap.vendor_id,
			pet.expenditure_category,
			pet.revenue_category_code,
                        adl.ind_compiled_set_id                  -- Bug 2387678 (Performance Tuning)
	from    ap_invoices_all  	ap,
		gms_award_distributions  	adl,
		ap_invoice_distributions	aid,
		gl_period_statuses 		gps,
		pa_expenditure_types 	pet,
		gl_ledgers			g
	where   ap.invoice_id = aid.invoice_id
	and 	aid.invoice_distribution_id	= adl.invoice_distribution_id  -- AP Lines change
	and	aid.invoice_id			= adl.invoice_id
	and     adl.document_type 		= 'AP'
	and     adl.award_set_id		= aid.award_id
	and     adl.adl_status			= 'A'
	and	nvl(adl.fc_status,'N')		= 'A'
	and	nvl(aid.pa_addition_flag,'N') 	= 'N'
	and     trunc(aid.expenditure_item_date)
        		between trunc(gps.start_date) and trunc(gps.end_date) --Bug 9232992
	and     gps.adjustment_period_flag	= 'N'
	and	gps.application_id 		= 101
	and	gps.set_of_books_id 		= x_sob_id
	and 	adl.project_id 			= x_project_id
	and	adl.award_id 			= x_award_id
        and     pa_cmt_utils.get_apdist_amt( aid.invoice_distribution_id,
                             aid.invoice_id,
                             nvl(aid.base_amount,aid.amount),
                             'N', 'GMS', nvl(g.sla_ledger_cash_basis_flag,'N') ) <> 0
	and 	nvl(aid.match_status_flag, 'X')	= 'A'
	and  pet.expenditure_type = aid.expenditure_type
	and  g.ledger_id = aid.set_of_books_id ;

	/* Commented out for bug 3661740. pa_addition_flag check should preclude items
	   that are interfaced to PA.
	and	not exists (select 'X'
				from    pa_cost_distribution_lines_all cdl
				where   cdl.system_reference2 = to_char(aid.invoice_id)
				and     cdl.system_reference3 = to_char(aid.distribution_line_number))
        */

	exception
		when no_data_found then
			null;
		  when others then
			raise;
	end;

	-- -------------------------------------------------------------------------------------------------------
	-- Bug 3283448 : Removed the earlier code from here, The following statement will handle all the scenarios
	-- The following insert staement should pick up following Scenarios :
	-- Transactions interfaced from AP (these expenditures will have fc_status = 'A'
	-- Expenditures having Funds check passed CDL which failed funds checking during Re-costing
	-- As we are checking for fc_status on ADL , these lines will be picked up
	-- -------------------------------------------------------------------------------------------------------

	begin
	-- ---------------------------------------------------------------
	-- TO INSERT  Expenditures and Encumberances
	-- ---------------------------------------------------------------
		  insert into gms_bc_packets (
			PACKET_ID,
			PROJECT_ID,
			AWARD_ID,
			TASK_ID,
			EXPENDITURE_TYPE,
			EXPENDITURE_ITEM_DATE,
			ACTUAL_FLAG,
			STATUS_CODE,
			LAST_UPDATE_DATE,
			LAST_UPDATED_BY,
			CREATED_BY,
			CREATION_DATE,
			LAST_UPDATE_LOGIN,
			SET_OF_BOOKS_ID,
			JE_CATEGORY_NAME,
			JE_SOURCE_NAME,
			TRANSFERED_FLAG,
		 	DOCUMENT_TYPE,
			EXPENDITURE_ORGANIZATION_ID,
			PERIOD_NAME,
			PERIOD_YEAR,
			PERIOD_NUM,
			DOCUMENT_HEADER_ID,
			DOCUMENT_DISTRIBUTION_ID,
			ACCOUNT_TYPE,
			ENTERED_DR,
			ENTERED_CR,
			BUDGET_VERSION_ID,
	        	bc_packet_id,
		        burdenable_raw_cost,
			person_id,				 -- Bug 2069132 ( RLMI Change)
			job_id,					 -- Bug 2069132 ( RLMI Change)
			vendor_id,				 -- Bug 2069132 ( RLMI Change)
			expenditure_category,	 		 -- Bug 2069132 ( RLMI Change)
			revenue_category,			 -- Bug 2069132 ( RLMI Change)
                        ind_compiled_set_id              -- Bug 2387678 ( Performance Tuning )
			)
		  select
			x_packet_id,
			--task.project_id, -- commented for porting Bug:1703510
			pc.project_id, -- added for above bug
			adl.award_id,
			pe.task_id,
			pe.EXPENDITURE_TYPE,
			trunc(pe.EXPENDITURE_ITEM_DATE),
			'A',
			'P',
			sysdate,
		 	FND_GLOBAL.USER_ID,
		 	FND_GLOBAL.USER_ID,
		 	sysdate,
		 	FND_GLOBAL.LOGIN_ID,
			x_sob_id,
        	        DECODE(pe.system_linkage_function,'OT','Labor Cost',
						          'ST','Labor Cost',
					  		  'ER','Purchase Invoices',
							  'VI','Purchase Invoices',
							  'USG','Usage Cost',
							  'PJ','Miscellaneous Transaction',
							  'INV','Inventory',
					 		  'WIP','WIP'), -- Bug 2461450 : Replaced 'Expenditures' with DECODE statement
			'Project Accounting',
			'Y',
			'EXP', -- for document_type
			nvl(pe.override_to_organization_id,pa.incurred_by_organization_id),
			gl.PERIOD_NAME,
			gl.PERIOD_YEAR,
			gl.PERIOD_NUM,
			pc.expenditure_item_id,
			pc.line_num,
			'E',
			decode(sign(pc.amount),1,pc.amount,0),
			decode(sign(pc.amount),-1,ABS(pc.amount),0),
			x_budget_version_id,
			gms_bc_packets_s.nextval,
			adl.burdenable_raw_cost,
			pa.incurred_by_person_id, 					-- Bug 2069132 ( RLMI Change)
			pe.job_id,							-- Bug 2069132 ( RLMI Change)
			pc.system_reference1,						-- Bug 2069132 ( RLMI Change)
			pet.expenditure_category,					-- Bug 2069132 ( RLMI Change)
			pet.revenue_category_code,					-- Bug 2069132 ( RLMI Change)
                        adl.ind_compiled_set_id                                         -- Bug 2387678 (Performance Tuning)
                       /* Changed the order of queries and
		          removed join with tables
			  gl_date_period_map map,
			  gl_sets_of_books glsob and  pa_implementations imp for bug# 6043224 */
		FROM    GMS_AWARD_DISTRIBUTIONS ADL,
			PA_COST_DISTRIBUTION_LINES_ALL PC,
			GL_PERIOD_STATUSES GL,
			PA_EXPENDITURE_ITEMS_ALL PE,
			PA_EXPENDITURES_ALL PA,
			PA_EXPENDITURE_TYPES PET
			WHERE ADL.PROJECT_ID = x_project_id
			AND ADL.AWARD_ID = x_award_id
			AND ADL.ADL_STATUS = 'A'
			AND NVL(ADL.FC_STATUS,'N') = 'A'
			AND ADL.DOCUMENT_TYPE = 'EXP'
			AND pc.expenditure_item_id = adl.expenditure_item_id
			and pc.line_num = adl.cdl_line_num
			AND PC.LINE_TYPE = 'R'
			AND NVL(PC.AMOUNT,0) <> 0
			AND GL.APPLICATION_ID = 101
			AND GL.SET_OF_BOOKS_ID = x_sob_id
			AND GL.ADJUSTMENT_PERIOD_FLAG = 'N'
			AND trunc(PC.GL_DATE) BETWEEN GL.START_DATE AND GL.END_DATE   -- Added trunc for bug 8458913
			AND PE.EXPENDITURE_ITEM_ID = PC.EXPENDITURE_ITEM_ID
			AND PE.EXPENDITURE_ITEM_ID = ADL.EXPENDITURE_ITEM_ID
			AND PA.EXPENDITURE_ID = PE.EXPENDITURE_ID
			AND PET.EXPENDITURE_TYPE = PE.EXPENDITURE_TYPE;
/*		Commented for Bug 6043224
		  from pa_expenditure_items_all pe,
			pa_expenditures_all pa,
			pa_cost_distribution_lines_all pc,
			gl_period_STATUSES gl,
			-- pa_tasks task, -- commented for Bug:1703510
			gms_award_distributions adl,
			--pa_periods pp,                                                -- Bug 2887849, EPP changes
			pa_expenditure_types pet,	   	  			-- Bug 2069132 (RLMI Change)
-- Added the joins with the tables for Bug 5569067
                        gl_date_period_map map,
                        gl_sets_of_books glsob,
                        pa_implementations imp
		 where  adl.project_id = x_project_id 					-- Bug 2387678
--		 where  pc.project_id = x_project_id 					-- added for porting Bug:1703510
		  --where task.project_id = x_project_id 				-- commented for above bug
		  --and	pe.task_id = task.task_id 					-- commented for above bug
		  and	adl.award_id = x_award_id
--		  and   pe.task_id    = adl.task_id					-- Bug 2387678
	  	  and   adl.adl_status			= 'A'
	  	  and	nvl(adl.fc_status,'N')		= 'A'
		  and	adl.document_type = 'EXP'
		  and	pa.expenditure_id = pe.expenditure_id
--		  and   pp.end_date = pc.pa_date + 0
  		  --and   pp.end_date = pc.pa_date					-- Bug 2887849, EPP changes
		  --and   pp.gl_period_name = gl.period_name                            -- Bug 2887849, EPP changes
		  and   pc.gl_date between gl.start_date and gl.end_date                -- Bug 2887849, EPP changes
		  and	gl.application_id = 101
		  and	gl.set_of_books_id = x_sob_id
		  and   gl.adjustment_period_flag = 'N'  ---> bug 3201867
		  and   nvl(pc.amount,0) <> 0 -- filter burden transactions
		  and	pe.expenditure_item_id = pc.expenditure_item_id
		  and   pe.expenditure_item_id = adl.expenditure_item_id
		  and   pc.line_num = adl.cdl_line_num
		  and	pc.line_type = 'R'
		  --and	pc.reversed_flag is null
		  --and	pc.line_num_reversed is null
		  -- 2337127 ( Budget Baseline should insert all the cdls.
		  -- that has passed fundscheck previously..
		  -- and   pe.cost_distributed_flag = 'Y' -- Bug 3283448 : Only check for fc_status , if fc_status = 'A' we should pick the record
		  and   pet.expenditure_type = pe.expenditure_type		   -- Bug 2069132 (RLMI Change)
-- Added the following conditions for bug 5569067
                  AND map.period_set_name = glsob.Period_set_name
                  AND map.period_type = glsob.accounted_period_type
                  AND imp.org_id = pe.org_id
                  AND glsob.set_of_books_id = imp.set_of_books_id
                  AND map.accounting_date = trunc(pc.gl_date) -- Modified from pe.expenditure_item_date to pc.gl_date for the bug 5725787
		   Added trunc in the above condition for bug5960821
                  AND gl.period_name= map.period_name;  Commented for Bug 6043224 */

		exception
		when no_data_found then
			null;
		  when others then
			raise;
	end;

	-- ---------------------------------------------------------------------------------------------
	-- Encumbrance Insert for Baseline
	-- ---------------------------------------------------------------------------------------------

	-- ---------------------------------------------------------------------------------------------
	-- Bug Fix 2170878. Encumbrance insert should have condition of adl.document_type = 'ENC' as
	-- both encumbrance_item_id and expenditure_item_id is stored in expenditure_item_id in adl table
	-- ---------------------------------------------------------------------------------------------

	begin

		  insert into gms_bc_packets (
			PACKET_ID,
			PROJECT_ID,
			AWARD_ID,
			TASK_ID,
			EXPENDITURE_TYPE,
			EXPENDITURE_ITEM_DATE,
			ACTUAL_FLAG,
			STATUS_CODE,
			LAST_UPDATE_DATE,
			LAST_UPDATED_BY,
			CREATED_BY,
			CREATION_DATE,
			LAST_UPDATE_LOGIN,
			SET_OF_BOOKS_ID,
			JE_CATEGORY_NAME,
			JE_SOURCE_NAME,
			TRANSFERED_FLAG,
		 	DOCUMENT_TYPE,
			EXPENDITURE_ORGANIZATION_ID,
			PERIOD_NAME,
			PERIOD_YEAR,
			PERIOD_NUM,
			DOCUMENT_HEADER_ID,
			DOCUMENT_DISTRIBUTION_ID,
			ACCOUNT_TYPE,
			ENTERED_DR,
			ENTERED_CR,
			BUDGET_VERSION_ID,
			bc_packet_id,
		   	burdenable_raw_cost,
			person_id,				 -- Bug 2069132 ( RLMI Change)
			job_id,					 -- Bug 2069132 ( RLMI Change)
			expenditure_category,	 		 -- Bug 2069132 ( RLMI Change)
			revenue_category,			 -- Bug 2069132 ( RLMI Change)
                        ind_compiled_set_id              	 -- Bug 2387678 ( Performance Tuning )
			)
		 select
			x_packet_id,
			--task.project_id, -- commented out NOCOPY for porting bug:1703510
			adl.project_id, -- added for the above bug
			adl.award_id,
			gei.task_id,
			gei.encumbrance_type,
			trunc(gei.encumbrance_item_date),
			'E',
			'P',
			sysdate,
		 	FND_GLOBAL.USER_ID,
		 	FND_GLOBAL.USER_ID,
		 	sysdate,
		 	FND_GLOBAL.LOGIN_ID,
			x_sob_id,
			'Encumbrances', -- Bug 2461450
			'Project Accounting',
			'Y',
			'ENC', -- for document_type
			nvl(gei.override_to_organization_id,ge.incurred_by_organization_id),
			gl.PERIOD_NAME,
			gl.PERIOD_YEAR,
			gl.PERIOD_NUM,
			gei.encumbrance_item_id,
			adl.adl_line_num, --Bug 5726575 1,
			'E',
			-- Bug 1980810 PA Rounding function added
			pa_currency.round_currency_amt(decode(sign(gei.amount),1,gei.amount,0)),
                        pa_currency.round_currency_amt(decode(sign(gei.amount),-1,-1*gei.amount,0)),
			x_budget_version_id,
			gms_bc_packets_s.nextval,
			adl.burdenable_raw_cost,
			ge.incurred_by_person_id, 					-- Bug 2069132 ( RLMI Change)
			gei.job_id,							-- Bug 2069132 ( RLMI Change)
			pet.expenditure_category,					-- Bug 2069132 ( RLMI Change)
			pet.revenue_category_code,					-- Bug 2069132 ( RLMI Change)
                        adl.ind_compiled_set_id                                         -- Bug 2387678 (Performance Tuning)
		  from gms_encumbrance_items_all gei,
			gms_encumbrances_all ge,
			gl_period_STATUSES gl,
			--pa_tasks task,  -- commented out NOCOPY for porting bug:1703510
			gms_award_distributions adl,
			pa_expenditure_types pet	   	  			-- Bug 2069132 (RLMI Change)
		  -- where task.project_id = x_project_id -- commented out NOCOPY for porting bug:1703510
		  -- and	gei.task_id = task.task_id -- commented out NOCOPY for porting bug:1703510
		  where adl.project_id = x_project_id -- added for the above bug
		  and	adl.award_id = x_award_id
--		  and	adl.project_id = gei.project_id -- commented out NOCOPY for Bug: 1666853
		  and   adl.task_id = gei.task_id
	  	  and   adl.adl_status			= 'A'
	  	  and	nvl(adl.fc_status,'N')		= 'A'
		  and	adl.document_type = 'ENC'
		  and	ge.encumbrance_id = gei.encumbrance_id
--		  and   pp.end_date = gei.pa_date -- commented out NOCOPY for Bug: 1666853
		  and   gei.encumbrance_item_date between gl.start_date and gl.end_date -- added for Bug: 1666853
--		  and   pp.gl_period_name = gl.period_name -- commented out NOCOPY for Bug: 1666853
		  and	gl.application_id = 101
		  and	gl.set_of_books_id = x_sob_id
		  and   gl.adjustment_period_flag = 'N' ---> bug 3201867
		  and   gei.encumbrance_item_id = adl.expenditure_item_id
		  and	gei.enc_distributed_flag = 'Y'
                  and   nvl(adl.reversed_flag, 'N') = 'N' --Bug 5726575
                  and   adl.line_num_reversed is null --Bug 5726575
		  and   pet.expenditure_type = gei.encumbrance_type;		   -- Bug 2069132 (RLMI Change)

	exception
		  when no_data_found then
		    null;
		  when others then
      			gms_error_pkg.gms_message('GMS_UNEXPECTED_ERROR',
							'SQLCODE',
			        			SQLCODE,
							'SQLERRM',
							SQLERRM,
							X_Exec_Type => 'C',
							X_Err_Code => X_Err_Code,
							X_Err_Buff => X_Err_Buff);
			raise;
	end;
END create_direct_cost;
---------------------------------------------------------------------------------------------
-- Procedure to create indirect cost lines in GMS_BC_PACKETS from the raw cost lines
-- in GMS_BC_PACKETS for a given packet;
procedure create_indirect_cost(x_packet_id IN  number) IS
x_err_code number;
x_err_buff varchar2(2000);
begin
     begin
	Insert into gms_bc_packets
	 ( PACKET_ID,
	   PROJECT_ID,
	   AWARD_ID,
	   TASK_ID,
	   EXPENDITURE_TYPE,
	   EXPENDITURE_ITEM_DATE,
	   ACTUAL_FLAG,
	   STATUS_CODE,
	   LAST_UPDATE_DATE,
	   LAST_UPDATED_BY,
	   CREATED_BY,
	   CREATION_DATE,
	   LAST_UPDATE_LOGIN,
	   SET_OF_BOOKS_ID,
	   JE_CATEGORY_NAME,
	   JE_SOURCE_NAME,
	   TRANSFERED_FLAG,
	   DOCUMENT_TYPE,
	   EXPENDITURE_ORGANIZATION_ID,
	   PERIOD_NAME,
	   PERIOD_YEAR,
	   PERIOD_NUM,
	   DOCUMENT_HEADER_ID ,
	   DOCUMENT_DISTRIBUTION_ID,
	   TOP_TASK_ID,
	   BUDGET_VERSION_ID,
	   RESOURCE_LIST_MEMBER_ID,
	   ACCOUNT_TYPE,
	   ENTERED_DR,
	   ENTERED_CR ,
	   TOLERANCE_AMOUNT,
	   TOLERANCE_PERCENTAGE,
	   OVERRIDE_AMOUNT,
	   EFFECT_ON_FUNDS_CODE ,
	   RESULT_CODE,
	   GL_BC_PACKETS_ROWID,
	   BC_PACKET_ID,
	   PARENT_BC_PACKET_ID,
 	   person_id,				 -- Bug 2069132 ( RLMI Change)
	   job_id,				 -- Bug 2069132 ( RLMI Change)
	   vendor_id,				 -- Bug 2069132 ( RLMI Change)
	   expenditure_category,	 	 -- Bug 2069132 ( RLMI Change)
	   revenue_category		 	 -- Bug 2069132 ( RLMI Change)
	   )
	 select /*+ index(gbc GMS_BC_PACKETS_N1) */ --Added the index hint for bug 5689194
	 gbc.PACKET_ID,
	 gbc.PROJECT_ID,
	 gbc.AWARD_ID,
	 gbc.TASK_ID,
	 icc.EXPENDITURE_TYPE,  /* for performance fix bug 5569067 */ /* Bug 5676410 */
	 trunc(gbc.EXPENDITURE_ITEM_DATE),
	 gbc.ACTUAL_FLAG,
	 gbc.STATUS_CODE,
	 gbc.LAST_UPDATE_DATE,
	 gbc.LAST_UPDATED_BY,
	 gbc.CREATED_BY,
	 gbc.CREATION_DATE,
	 gbc.LAST_UPDATE_LOGIN,
	 gbc.SET_OF_BOOKS_ID,
	 gbc.JE_CATEGORY_NAME,
	 gbc.JE_SOURCE_NAME,
	 gbc.TRANSFERED_FLAG,
	 gbc.DOCUMENT_TYPE,
	 gbc.EXPENDITURE_ORGANIZATION_ID,
	 gbc.PERIOD_NAME,
	 gbc.PERIOD_YEAR,
	 gbc.PERIOD_NUM,
	 gbc.DOCUMENT_HEADER_ID ,
	 gbc.DOCUMENT_DISTRIBUTION_ID,
	 gbc.TOP_TASK_ID,
	 gbc.BUDGET_VERSION_ID,
	 gbc.RESOURCE_LIST_MEMBER_ID,
	 gbc.ACCOUNT_TYPE,
	 -- Bug 1980810 PA Rounding function added
	 pa_currency.round_currency_amt(sign(nvl(entered_dr,0)) * abs(nvl(gbc.BURDENABLE_RAW_COST ,0) * nvl(cm.compiled_multiplier,0))),
	 pa_currency.round_currency_amt(sign(nvl(entered_cr,0)) * abs(nvl(gbc.BURDENABLE_RAW_COST ,0) * nvl(cm.compiled_multiplier,0))),
	 gbc.TOLERANCE_AMOUNT,
	 gbc.TOLERANCE_PERCENTAGE,
	 gbc.OVERRIDE_AMOUNT,
	 gbc.EFFECT_ON_FUNDS_CODE ,
	 gbc.RESULT_CODE,
	 gbc.GL_BC_PACKETS_ROWID,
	 gms_bc_packets_s.nextval,
	 gbc.BC_PACKET_ID,
 	 gbc.person_id,				 -- Bug 2069132 ( RLMI Change)
	 gbc.job_id,				 -- Bug 2069132 ( RLMI Change)
	 gbc.vendor_id,				 -- Bug 2069132 ( RLMI Change)
	 et.expenditure_category,	 	 -- Bug 2069132 ( RLMI Change)
	 et.revenue_category_code	 	 -- Bug 2069132 ( RLMI Change)
	 from   /*pa_ind_rate_sch_revisions irsr, --for performance fix bug 5569067 */
	        --pa_cost_bases cb,  --Bug 3630704 : Performance fix
	        pa_expenditure_types et,
	        pa_ind_cost_codes icc, /* Bug 5676410 */
	        pa_cost_base_exp_types cbet,
	        --pa_ind_rate_schedules_all_bg irs, --Bug 3630704 : Performance fix
                pa_cost_base_cost_codes cbcc, /*for performance fix bug 5569067 */
	       /*pa_ind_compiled_sets ics, --for performance fix bug 5569067 */
	        pa_compiled_multipliers cm,
	        gms_bc_packets gbc
	  where gbc.document_type in ('REQ','PO','AP', 'ENC')  -- perf bug 4005086. included 'ENC' here
              and cbcc.cost_plus_structure     = cbet.cost_plus_structure
	    /*and irsr.cost_plus_structure     = cbet.cost_plus_structure bug 5569067 */
	    --and cb.cost_base                 = cbet.cost_base --Bug 3630704 : Performance fix
	    --and cb.cost_base_type            = cbet.cost_base_type --Bug 3630704 : Performance fix
	      and et.expenditure_type          = icc.expenditure_type /* Bug 5676410 */
             and  cbcc.cost_base               = cbet.cost_base   /*for performance fix bug 5569067 */
            /*and ics.cost_base                = cbet.cost_base -- Bug 3003584 */
	      and icc.ind_cost_code            = cm.ind_cost_code /* Bug 5676410 */
	    and cbet.cost_base               = cm.cost_base
            and  cm.cost_base_cost_code_id    = cbcc.cost_base_cost_code_id /*--for performance fix bug 5569067*/
            and  cm.ind_cost_code             = cbcc.ind_cost_code /*--for performance fix bug 5569067*/
	    and cbet.cost_base_type          = 'INDIRECT COST'
	    and cbet.expenditure_type        = gbc.expenditure_type
	    --and irs.ind_rate_sch_id          = irsr.ind_rate_sch_id --Bug 3630704 : Performance fix
	    /*and ics.ind_rate_sch_revision_id = irsr.ind_rate_sch_revision_id --for performance fix bug 5569067
            and ics.ind_compiled_set_id	     = gbc.ind_compiled_set_id -- Replaced the above clause with this for Bug:2387678 --for performance fix bug 5569067
	    and ics.organization_id          = gbc.expenditure_organization_id */
	    and cm.ind_compiled_set_id       = gbc.ind_compiled_set_id
	    and cm.compiled_multiplier <> 0
	    and gbc.packet_id = x_packet_id;

	exception
	 	when no_data_found then
	    		null;
		when others then
      			gms_error_pkg.gms_message('GMS_UNEXPECTED_ERROR',
							'SQLCODE',
			        			SQLCODE,
							'SQLERRM',
							SQLERRM,
							X_Exec_Type => 'C',
							X_Err_Code => X_Err_Code,
							X_Err_Buff => X_Err_Buff);
			raise;
	end;
	Begin
	     Insert into gms_bc_packets
	      ( PACKET_ID,
	        PROJECT_ID,
	        AWARD_ID,
	        TASK_ID,
	        EXPENDITURE_TYPE,
	        EXPENDITURE_ITEM_DATE,
	        ACTUAL_FLAG,
	        STATUS_CODE,
	        LAST_UPDATE_DATE,
	        LAST_UPDATED_BY,
	        CREATED_BY,
	        CREATION_DATE,
	        LAST_UPDATE_LOGIN,
	        SET_OF_BOOKS_ID,
	        JE_CATEGORY_NAME,
	        JE_SOURCE_NAME,
	        TRANSFERED_FLAG,
	        DOCUMENT_TYPE,
	        EXPENDITURE_ORGANIZATION_ID,
	        PERIOD_NAME,
	        PERIOD_YEAR,
	        PERIOD_NUM,
	        DOCUMENT_HEADER_ID ,
	        DOCUMENT_DISTRIBUTION_ID,
	        TOP_TASK_ID,
	        BUDGET_VERSION_ID,
	        RESOURCE_LIST_MEMBER_ID,
	        ACCOUNT_TYPE,
	        ENTERED_DR,
	        ENTERED_CR ,
	        TOLERANCE_AMOUNT,
	        TOLERANCE_PERCENTAGE,
	        OVERRIDE_AMOUNT,
	        EFFECT_ON_FUNDS_CODE ,
	        RESULT_CODE,
	        GL_BC_PACKETS_ROWID,
	        BC_PACKET_ID,
	        PARENT_BC_PACKET_ID,
		person_id,				 -- Bug 2069132 ( RLMI Change)
		job_id,					 -- Bug 2069132 ( RLMI Change)
		vendor_id,				 -- Bug 2069132 ( RLMI Change)
		expenditure_category,	 	 	 -- Bug 2069132 ( RLMI Change)
		revenue_category			 -- Bug 2069132 ( RLMI Change)
			)
	      select /*+ index(gbc GMS_BC_PACKETS_N1) */ --Added the index hint for bug 5689194
	      gbc.PACKET_ID,
	      gbc.PROJECT_ID,
	      gbc.AWARD_ID,
	      gbc.TASK_ID,
	      icc.EXPENDITURE_TYPE,
	      trunc(gbc.EXPENDITURE_ITEM_DATE),
	      gbc.ACTUAL_FLAG,
	      gbc.STATUS_CODE,
	      gbc.LAST_UPDATE_DATE,
	      gbc.LAST_UPDATED_BY,
	      gbc.CREATED_BY,
	      gbc.CREATION_DATE,
	      gbc.LAST_UPDATE_LOGIN,
	      gbc.SET_OF_BOOKS_ID,
	      gbc.JE_CATEGORY_NAME,
	      gbc.JE_SOURCE_NAME,
	      gbc.TRANSFERED_FLAG,
	      gbc.DOCUMENT_TYPE,
	      gbc.EXPENDITURE_ORGANIZATION_ID,
	      gbc.PERIOD_NAME,
	      gbc.PERIOD_YEAR,
	      gbc.PERIOD_NUM,
	      gbc.DOCUMENT_HEADER_ID ,
	      gbc.DOCUMENT_DISTRIBUTION_ID,
	      gbc.TOP_TASK_ID,
	      gbc.BUDGET_VERSION_ID,
	      gbc.RESOURCE_LIST_MEMBER_ID,
	      gbc.ACCOUNT_TYPE,
	      -- Bug 1980810 PA Rounding function added
	      pa_currency.round_currency_amt(decode(nvl(entered_dr,0),0,0,(abs(nvl(gbc.BURDENABLE_RAW_COST ,0)) * nvl(cm.compiled_multiplier,0)))),
	      pa_currency.round_currency_amt(decode(nvl(entered_cr,0),0,0,(abs(nvl(gbc.BURDENABLE_RAW_COST ,0)) * nvl(cm.compiled_multiplier,0)))),
	      gbc.TOLERANCE_AMOUNT,
	      gbc.TOLERANCE_PERCENTAGE,
	      gbc.OVERRIDE_AMOUNT,
	      gbc.EFFECT_ON_FUNDS_CODE ,
	      gbc.RESULT_CODE,
	      gbc.GL_BC_PACKETS_ROWID,
	      gms_bc_packets_s.nextval,
	      gbc.BC_PACKET_ID,
	      gbc.person_id,		 -- Bug 2069132 ( RLMI Change)
	      gbc.job_id,		 -- Bug 2069132 ( RLMI Change)
	      gbc.vendor_id,		 -- Bug 2069132 ( RLMI Change)
	      et.expenditure_category,	 -- Bug 2069132 ( RLMI Change)
	      et.revenue_category_code	 -- Bug 2069132 ( RLMI Change)
	      from   --pa_ind_rate_sch_revisions irsr, /* Commented for bug 5689194 */
	             --pa_cost_bases cb, --Bug 3630704 : Performance fix
	             pa_expenditure_types et,
	             pa_ind_cost_codes icc,
	             pa_cost_base_exp_types cbet,
	             --pa_ind_rate_schedules_all_bg irs,  --Bug 3630704 : Performance fix
		     pa_cost_base_cost_codes cbcc , /* added for bug 5689194 */
	             --pa_ind_compiled_sets ics, /* commented for bug 5689194 */
	             pa_compiled_multipliers cm,
		     pa_expenditure_items_all ei,		--Bug Fix 1482377
		     pa_transaction_sources pts,		--Bug Fix 1482377
	             gms_bc_packets gbc
	  	where gbc.document_type =  'EXP'
	         and cbcc.cost_plus_structure     = cbet.cost_plus_structure -- Bug 5689194
	         --and cb.cost_base                 = cbet.cost_base  --Bug 3630704 : Performance fix
	         --and cb.cost_base_type            = cbet.cost_base_type  --Bug 3630704 : Performance fix
                 --and ics.cost_base                = cbet.cost_base -- 3003584 Bug 5689194
		 and cbcc.cost_base             = cbet.cost_base  -- Bug 5689194
	         and et.expenditure_type          = icc.expenditure_type
	         and icc.ind_cost_code            = cm.ind_cost_code
	         and cbet.cost_base               = cm.cost_base
	         and cbet.cost_base_type          = 'INDIRECT COST'
                 and cm.cost_base_cost_code_id = cbcc.cost_base_cost_code_id --Bug 5689194
                 and cm.ind_cost_code = cbcc.ind_cost_code --Bug 5689194
	         and cbet.expenditure_type        = gbc.expenditure_type
	         --and irs.ind_rate_sch_id          = irsr.ind_rate_sch_id  --Bug 3630704 : Performance fix
	         --and ics.ind_rate_sch_revision_id = irsr.ind_rate_sch_revision_id Bug 5689194
	         and gbc.document_type            = 'EXP'
	         --and ics.ind_compiled_set_id      =  gbc.ind_compiled_set_id Bug 5689194
	         and cm.ind_compiled_set_id       = gbc.ind_compiled_set_id
	         --and ics.organization_id          = gbc.expenditure_organization_id Bug 5689194
	         and cm.compiled_multiplier       <> 0
		 and ei.expenditure_item_id       = gbc.document_header_id              --Bug Fix 1482377
         	 and (ei.transaction_source       = pts.transaction_source (+)          --Bug Fix 1482377
                	and nvl(pts.allow_burden_flag,'N') = 'N')			--Bug Fix 1815635
	         and gbc.packet_id = x_packet_id;

        exception
	  when no_data_found then
	   	null;
	  when others then
      		gms_error_pkg.gms_message('GMS_UNEXPECTED_ERROR',
						'SQLCODE',
			        		SQLCODE,
						'SQLERRM',
						SQLERRM,
						X_Exec_Type => 'C',
						X_Err_Code => X_Err_Code,
						X_Err_Buff => X_Err_Buff);
		raise;
	end ;

      /***** Perf bug 4005086 .. included 'ENC' along with 'PO', 'AP', 'REQ'...

		-- ------------
    	    	-- Encumbrances
		-- ------------
       begin
        Insert into gms_bc_packets
	      ( PACKET_ID,
	        PROJECT_ID,
	        AWARD_ID,
	        TASK_ID,
	        EXPENDITURE_TYPE,
	        EXPENDITURE_ITEM_DATE,
	        ACTUAL_FLAG,
	        STATUS_CODE,
	        LAST_UPDATE_DATE,
	        LAST_UPDATED_BY,
	        CREATED_BY,
	        CREATION_DATE,
	        LAST_UPDATE_LOGIN,
	        SET_OF_BOOKS_ID,
	        JE_CATEGORY_NAME,
	        JE_SOURCE_NAME,
	        TRANSFERED_FLAG,
	        DOCUMENT_TYPE,
	        EXPENDITURE_ORGANIZATION_ID,
	        PERIOD_NAME,
	        PERIOD_YEAR,
	        PERIOD_NUM,
	        DOCUMENT_HEADER_ID ,
	        DOCUMENT_DISTRIBUTION_ID,
	        TOP_TASK_ID,
	        BUDGET_VERSION_ID,
	        RESOURCE_LIST_MEMBER_ID,
	        ACCOUNT_TYPE,
	        ENTERED_DR,
	        ENTERED_CR ,
	        TOLERANCE_AMOUNT,
	        TOLERANCE_PERCENTAGE,
	        OVERRIDE_AMOUNT,
	        EFFECT_ON_FUNDS_CODE ,
	        RESULT_CODE,
	        GL_BC_PACKETS_ROWID,
	        BC_PACKET_ID,
	        PARENT_BC_PACKET_ID,
 	        person_id,				 -- Bug 2069132 ( RLMI Change)
	        job_id,					 -- Bug 2069132 ( RLMI Change)
	        vendor_id,				 -- Bug 2069132 ( RLMI Change)
            	expenditure_category,	 		 -- Bug 2069132 ( RLMI Change)
 	        revenue_category	 	 	 -- Bug 2069132 ( RLMI Change)
			)
      		select
      			gbc.PACKET_ID,
      			gbc.PROJECT_ID,
      			gbc.AWARD_ID,
      			gbc.TASK_ID,
      			icc.EXPENDITURE_TYPE,
      			trunc(gbc.EXPENDITURE_ITEM_DATE),
      			gbc.ACTUAL_FLAG,
      			gbc.STATUS_CODE,
      			gbc.LAST_UPDATE_DATE,
      			gbc.LAST_UPDATED_BY,
      			gbc.CREATED_BY,
      			gbc.CREATION_DATE,
      			gbc.LAST_UPDATE_LOGIN,
      			gbc.SET_OF_BOOKS_ID,
      			gbc.JE_CATEGORY_NAME,
      			gbc.JE_SOURCE_NAME,
      			gbc.TRANSFERED_FLAG,
      			gbc.DOCUMENT_TYPE,
      			gbc.EXPENDITURE_ORGANIZATION_ID,
      			gbc.PERIOD_NAME,
      			gbc.PERIOD_YEAR,
      			gbc.PERIOD_NUM,
      			gbc.DOCUMENT_HEADER_ID ,
      			gbc.DOCUMENT_DISTRIBUTION_ID,
      			gbc.TOP_TASK_ID,
      			gbc.BUDGET_VERSION_ID,
      			gbc.RESOURCE_LIST_MEMBER_ID,
      			gbc.ACCOUNT_TYPE,
			-- Bug 1980810 PA Rounding function added
     			pa_currency.round_currency_amt(decode(nvl(entered_dr,0),0,0,(abs(nvl(gbc.BURDENABLE_RAW_COST ,0)) * nvl(cm.compiled_multiplier,0)))),
     			pa_currency.round_currency_amt(decode(nvl(entered_cr,0),0,0,(abs(nvl(gbc.BURDENABLE_RAW_COST ,0)) * nvl(cm.compiled_multiplier,0)))),
      			gbc.TOLERANCE_AMOUNT,
      			gbc.TOLERANCE_PERCENTAGE,
      			gbc.OVERRIDE_AMOUNT,
      			gbc.EFFECT_ON_FUNDS_CODE ,
      			gbc.RESULT_CODE,
      			gbc.GL_BC_PACKETS_ROWID,
      			gms_bc_packets_s.nextval,
      			gbc.BC_PACKET_ID,
 	        	gbc.person_id,				 -- Bug 2069132 ( RLMI Change)
	        	gbc.job_id,				 -- Bug 2069132 ( RLMI Change)
	        	gbc.vendor_id,				 -- Bug 2069132 ( RLMI Change)
            		et.expenditure_category,	 	 -- Bug 2069132 ( RLMI Change)
 	        	et.revenue_category_code 		 -- Bug 2069132 ( RLMI Change)
      		from   	pa_ind_rate_sch_revisions irsr,
             		--pa_cost_bases cb,  --Bug 3630704 : Performance fix
             		pa_expenditure_types et,
             		pa_ind_cost_codes icc,
             		pa_cost_base_exp_types cbet,
             		--pa_ind_rate_schedules_all_bg irs,  --Bug 3630704 : Performance fix
             		pa_ind_compiled_sets ics,
             		pa_compiled_multipliers cm,
             		gms_bc_packets gbc
       		where 	irsr.cost_plus_structure     = cbet.cost_plus_structure
         	--and 	cb.cost_base                 = cbet.cost_base  --Bug 3630704 : Performance fix
         	--and 	cb.cost_base_type            = cbet.cost_base_type  --Bug 3630704 : Performance fix
                and     ics.cost_base                = cbet.cost_base --Bug 3003584
         	and 	et.expenditure_type          = icc.expenditure_type
         	and 	icc.ind_cost_code            = cm.ind_cost_code
         	and 	cbet.cost_base               = cm.cost_base
         	and 	cbet.cost_base_type          = 'INDIRECT COST'
         	and 	cbet.expenditure_type        = gbc.expenditure_type
         	--and 	irs.ind_rate_sch_id          = irsr.ind_rate_sch_id  --Bug 3630704 : Performance fix
         	and 	ics.ind_rate_sch_revision_id = irsr.ind_rate_sch_revision_id
         	and 	gbc.document_type            = 'ENC'
		and 	ics.ind_compiled_set_id	     = gbc.ind_compiled_set_id -- Replaced the above clause with this for Bug:2387678
         	and 	cm.ind_compiled_set_id       = gbc.ind_compiled_set_id
         	and 	ics.organization_id          = gbc.expenditure_organization_id
         	and 	cm.compiled_multiplier       <> 0  -- Fix for Bug 806481
         	and 	gbc.packet_id = x_packet_id;

	exception
	  when no_data_found then
	   	null;
	  when others then
      		gms_error_pkg.gms_message('GMS_UNEXPECTED_ERROR',
						'SQLCODE',
			        		SQLCODE,
						'SQLERRM',
						SQLERRM,
						X_Exec_Type => 'C',
						X_Err_Code => X_Err_Code,
						X_Err_Buff => X_Err_Buff);
		raise;
	end ;
	*********************************/
end create_indirect_cost;

--------------------------------------------------------------------------------------------------------------------------------------------------
-- This Module sets up the denormalized columns in the queue such as
-- Budgetary Control Options, Funds Check Level, Account Type, Transaction
-- effect on Funds Available, etc. Generating resource_list_member_id for the packet based on the resource list
-- and expenditure_type
--------------------------------------------------------------------------------------------------------------------------------------------------

  Procedure re_base_setup_rlmi(	x_packet_id 		IN 	number,
	        		x_budget_version_id	IN 	number,
				x_err_code		OUT NOCOPY 	number,
				x_err_buff		OUT NOCOPY	varchar2) IS

    	x_resource_list_member_id	number;
    	x_project_id			number ;
	x_award_id			number;
	x_task_id			number;
	--x_budget_version_id		number;
    	x_gms_rowid			varchar2(30);
    	x_res_list_id			number;
    	x_organization_id		number ;
    	x_job_id			number;
    	x_vendor_id			number;
    	x_expenditure_type		varchar2(30);
        x_exptype                       varchar2(30); -- Additional parameter for map trans
    	x_non_labor_resource		varchar2(20);
    	x_expenditure_category		varchar2(30);
    	x_revenue_category		varchar2(30);
    	x_non_labor_resource_org_id	number;
    	x_system_linkage		varchar2(30);
    	x_document_type			varchar2(3);
    	x_person_id			number;
    	x_awd_id			number ;
        x_parent_id                     number;  -- Additional parameter for map trans
    	x_err_stack			varchar2(2000);
    	x_er_code			varchar2(1) := null;
    	x_er_stage	 		varchar2(2000) := null;
    	x_e_code			number;
    	x_bc_packet_id			number;
    	x_fcl				varchar2(1);
	x_bc_option_id 			number(15);
	x_categorization_code  		varchar2(1);
	l_budget_version_id        	gms_bc_packets.budget_version_id%TYPE;
	l_effect_on_funds_code		varchar2(1);
    x_group_by_none	varchar2(60) ;

    -- ------------------------------------------------------------------------
    --  If resource list is setup without resource groups and the
    --  resources are setup as expenditure categories, Funds check
    --  fail due to a resource mapping error.
    -- ------------------------------------------------------------------------


    CURSOR C_group_by_none_cat is
      SELECT 'X'
	FROM pa_child_resources_v a,
	     pa_expenditure_types b,
	     pa_resource_lists	  c
       WHERE a.resource_list_id		= x_res_list_id
	 AND a.resource_type_name	= 'Expenditure Category'
	 AND a.resource_list_id		= c.resource_list_id
	 AND c.group_resource_type_id	= 0
	 AND a.resource_name		= b.expenditure_category
	 AND b.expenditure_type		= x_expenditure_type
	 AND NVL(a.migration_code,'M') ='M'; -- Bug 3626671;


    Cursor cur_update_col is
        select  /*+ index(gms GMS_BC_PACKETS_N1) */ gms.bc_packet_id, -- added the index hint for bug 5689194
                gms.project_id,
                gms.award_id,
                gms.task_id,
                gms.expenditure_organization_id,
                gms.expenditure_type,
                gms.document_type,
                nvl(ei.system_linkage_function,'VI'),
                TYPE.expenditure_category,
                TYPE.revenue_category_code,
                gms.award_id,
                gms.parent_bc_packet_id,
                pm.categorization_code, -- to calculate the correct rlmi if budget without resource
                decode(sign(nvl(gms.entered_dr,0) - nvl(gms.entered_cr,0)),1,'D','I')
        from    gms_bc_packets gms,
                gms_budget_versions bv,
                pa_budget_entry_methods pm,
                pa_expenditure_types TYPE,
                gms_encumbrance_items_all ei
        where   gms.packet_id = x_packet_id
        and     gms.budget_version_id = bv.budget_version_id
	and	gms.document_type = 'ENC'
        and     bv.budget_entry_method_code = pm.budget_entry_method_code
        and     gms.expenditure_type = TYPE.expenditure_type
        and     gms.document_header_id = ei.encumbrance_item_id
	union all
        select  /*+ index(gms GMS_BC_PACKETS_N1) */ gms.bc_packet_id, -- added the index hint for bug 5689194
                gms.project_id,
                gms.award_id,
                gms.task_id,
                gms.expenditure_organization_id,
                gms.expenditure_type,
                gms.document_type,
                nvl(ei.system_linkage_function,'VI'),
                TYPE.expenditure_category,
                TYPE.revenue_category_code,
                gms.award_id,
                gms.parent_bc_packet_id,
                pm.categorization_code, -- to calculate the correct rlmi if budget without resource
                decode(sign(nvl(gms.entered_dr,0) - nvl(gms.entered_cr,0)),1,'D','I')
        from    gms_bc_packets gms,
                gms_budget_versions bv,
                pa_budget_entry_methods pm,
                pa_expenditure_types TYPE,
                pa_expenditure_items_all ei
        where   gms.packet_id = x_packet_id
            and     gms.budget_version_id = bv.budget_version_id
	and	gms.document_type = 'EXP'
        and     bv.budget_entry_method_code = pm.budget_entry_method_code
        and     gms.expenditure_type = TYPE.expenditure_type
        and     gms.document_header_id = ei.expenditure_item_id(+);

  BEGIN
	IF L_DEBUG = 'Y' THEN
		gms_error_pkg.gms_debug('BEGIN SETUP RLMI','C');
	END IF;
     --('*********** IN  GMS_FST PROCESS **************************************');
    if x_mode <> 'U' then

    -- Update denormalized columns for all detail transactions in the packet
    -- open cur_update_col;

    /* ---  Procedure opens the cursor   --- */
       OPEN cur_update_col;
       LOOP
       fetch cur_update_col into 	x_bc_packet_id,
					x_project_id,
					x_award_id,
					x_task_id,
					x_organization_id,
					x_expenditure_type,
					x_document_type,
					x_system_linkage,
					x_expenditure_category,
					x_revenue_category,
					x_awd_id,
					x_parent_id,
					x_categorization_code,
					l_effect_on_funds_code;
	   exit when cur_update_col%notfound;
	Begin

		if x_categorization_code = 'R' then -- if not categorized by resources then no call to map trans to generate rlmi

             		Begin
		    		select bv.resource_list_id  into  x_res_list_id
				from gms_budget_versions bv
				where bv.budget_version_id = x_budget_version_id;
              		Exception
                  		when others then
                   		raise;
              		End;


                  -- INPUT PARAMETERS FOR RESOURCE MAPPING
                  IF (     x_system_linkage = 'VI'
                      AND x_document_type = 'REQ' ) THEN
                     g_error_stage := 'VI-REQ';
                     SELECT DISTINCT line.vendor_id
                       INTO x_vendor_id
                       FROM po_requisition_lines line,
                            po_requisition_headers req,
                            gms_bc_packets bc
                      WHERE bc.packet_id = x_packet_id
                        AND line.requisition_header_id = req.requisition_header_id
                        AND bc.document_header_id = req.requisition_header_id
                        AND bc.bc_packet_id = x_bc_packet_id;
                  ELSIF     x_system_linkage = 'VI'
                        AND x_document_type = 'PO' THEN
                     g_error_stage := 'VI-PO';
                     SELECT DISTINCT head.vendor_id
                       INTO x_vendor_id
                       FROM po_headers_all head,
                            gms_bc_packets bc
                      WHERE bc.packet_id = x_packet_id
                        AND bc.document_header_id = head.po_header_id
                        AND bc.bc_packet_id = x_bc_packet_id;
                  ELSIF     x_system_linkage = 'VI'
                        AND x_document_type = 'AP' THEN
                     g_error_stage := 'VI-AP';
                     SELECT DISTINCT head.vendor_id
                       INTO x_vendor_id
                       FROM ap_invoices_all head,
                            gms_bc_packets bc
                      WHERE bc.packet_id = x_packet_id
                        AND bc.document_header_id = head.invoice_id
                        AND bc.bc_packet_id = x_bc_packet_id;
                  ELSIF (    x_system_linkage = 'ER'
                         OR x_system_linkage = 'ST'
                         OR x_system_linkage = 'OT' ) THEN
                     IF x_document_type = 'EXP' THEN
                        g_error_stage := 'ER/ST/OT-EXP';
                        SELECT DISTINCT EXP.incurred_by_person_id,
                                        item.job_id
                          INTO x_person_id,
                               x_job_id
                          FROM pa_expenditures_all exp,
                               pa_expenditure_items_all item,
                               gms_bc_packets bc
                         WHERE bc.packet_id = x_packet_id
                           AND bc.bc_packet_id = x_bc_packet_id
                           AND bc.document_header_id = item.expenditure_item_id
                           AND item.expenditure_id = EXP.expenditure_id;
                     ELSIF x_document_type = 'ENC' THEN
                        g_error_stage := 'ER/ST/OT-ENC';
                        SELECT DISTINCT enc.incurred_by_person_id,
                                        item.job_id
                          INTO x_person_id,
                               x_job_id
                          FROM gms_encumbrances_all enc,
                               gms_encumbrance_items_all item,
                               gms_bc_packets bc
                         WHERE bc.packet_id = x_packet_id
                           AND bc.bc_packet_id = x_bc_packet_id
                           AND bc.document_header_id = item.encumbrance_item_id
                           AND item.encumbrance_id = enc.encumbrance_id;
                     END IF;
                  ELSIF x_system_linkage = 'USG' THEN
                     IF x_document_type IN ( 'AP', 'PO', 'REQ' ) THEN
                        g_error_stage := 'USG-REQ/PO/AP';
                        SELECT DISTINCT tp.attribute2,
                                        tp.attribute3
                          INTO x_non_labor_resource,
                               x_non_labor_resource_org_id
                          FROM pa_expenditure_types tp,
                               gms_bc_packets bc
                         WHERE bc.packet_id = x_packet_id
                           AND bc.bc_packet_id = x_bc_packet_id
                           AND tp.expenditure_type = bc.expenditure_type;
                     ELSIF x_document_type = 'EXP' THEN
                        g_error_stage := 'USG-EXP';
                        SELECT DISTINCT EXP.incurred_by_person_id,
                                        item.job_id,
                                        item.non_labor_resource,
                                        item.organization_id
                          INTO x_person_id,
                               x_job_id,
                               x_non_labor_resource,
                               x_non_labor_resource_org_id
                          FROM pa_expenditures_all exp,
                               pa_expenditure_items_all item,
                               gms_bc_packets bc
                         WHERE bc.packet_id = x_packet_id
                           AND bc.bc_packet_id = x_bc_packet_id
                           AND bc.document_header_id = item.expenditure_item_id
                           AND item.expenditure_id = EXP.expenditure_id;
                     END IF;
                  END IF;

-- ------------------------------------------------------------------------
-- BUG:1370475 - If resource list is setup without resource groups and the
--       resources are setup as expenditure categories, Funds check
--       fail due to a resource mapping error.
-- ------------------------------------------------------------------------

                  g_error_stage := 'Resource-Exp Category';
                  OPEN c_group_by_none_cat;
                  FETCH c_group_by_none_cat INTO x_group_by_none;

                  IF c_group_by_none_cat%FOUND THEN
                     x_expenditure_type := NULL;
                     x_exptype := NULL;
                  ELSE
			IF x_parent_id is not null then
				x_exptype := NULL;
			ELSE
				x_exptype := x_expenditure_type;
			END IF;
                  CLOSE c_group_by_none_cat;
		  END IF;

--('PARAMETERS FOR RESOURCE MAPPING PROCESS **************************************');
   --gms_error_pkg.gms_debug('map trans :x_project_id >>>>>>'||to_char(x_project_id),'C');
   --gms_error_pkg.gms_debug('map trans :x_res_list_id>>>>>>'||to_char(x_res_list_id),'C');
   --gms_error_pkg.gms_debug('map trans :x_person_id>>>>>>'||to_char(x_person_id),'C');
   --gms_error_pkg.gms_debug('map trans :x_organization_id>>>>>>'||to_char(x_organization_id),'C');
   --gms_error_pkg.gms_debug('map trans :x_expenditure_type>>>>>>'||x_expenditure_type,'C');
   --gms_error_pkg.gms_debug('map trans :x_non_labor_resource>>>>>>'||x_non_labor_resource,'C');
   --gms_error_pkg.gms_debug('map trans :x_expenditure_category>>>>>>'||x_expenditure_category,'C');
   --gms_error_pkg.gms_debug('map trans :x_non_labor_resource_org_id>>>>>>'||to_char(x_non_labor_resource_org_id),'C');
   --gms_error_pkg.gms_debug('map trans :x_system_linkage>>>>>>'||x_system_linkage,'C');
   --gms_error_pkg.gms_debug('map trans :x_resource_list_member_id>>>Before resource mapping is >>>
   --                   '|| to_char(x_resource_list_member_id),'C');
                  g_error_stage := 'Resource Map';
                  gms_res_map.map_trans ( x_project_id,
                     x_res_list_id,
                     x_person_id,
                     x_job_id,
                     x_organization_id,
                     x_vendor_id,
                     x_expenditure_type,
		     NULL,
		     x_non_labor_resource,
                     x_expenditure_category,
                     x_revenue_category,
                     x_non_labor_resource_org_id,
                     NULL, -- x_event_type_classification
                     x_system_linkage,
                     x_exptype,
                     x_resource_list_member_id,
                     x_er_stage,
                     x_e_code);
                  IF L_DEBUG = 'Y' THEN
                  	gms_error_pkg.gms_debug ( 'map trans :x_resource_list_member_id >>>>>>' || x_resource_list_member_id,
                     'C' );
                  END IF;

                  IF    x_e_code > 0
                     OR x_resource_list_member_id IS NULL THEN
                     gms_error_pkg.gms_message ( 'GMS_MAP_TRANS',
                        'BC_PACKET_ID',
                        x_bc_packet_id,
			'PACKET_ID',
			x_packet_id,
                        x_exec_type                => 'C',
                        x_err_code                 => x_err_code,
                        x_err_buff                 => x_err_buff );

                     UPDATE gms_bc_packets
                        SET status_code = 'R',
                            result_code = 'F94',
                            res_result_code = 'F94',
                            res_grp_result_code = 'F94',
                            task_result_code = 'F94',
                            top_task_result_code = 'F94',
                            award_result_code = 'F94'
                      WHERE packet_id = x_packet_id
                        AND bc_packet_id = x_bc_packet_id;
                  ELSE
  ----------------------------------------------------------
--To update effect on funds code,resource list member id
  -- for each record in a packet, if categorized by resource.
----------------------------------------------------------

                     UPDATE gms_bc_packets
                        SET resource_list_member_id = x_resource_list_member_id,
                            effect_on_funds_code = l_effect_on_funds_code
                      WHERE packet_id = x_packet_id
                        AND bc_packet_id = x_bc_packet_id
                        AND budget_version_id = x_budget_version_id;
                  END IF;

                  x_job_id := NULL;
                  x_vendor_id := NULL;
                  x_non_labor_resource := NULL;
                  x_non_labor_resource_org_id := NULL;
                  x_person_id := NULL;
               ELSE
                  g_error_stage := 'Categorized<>R';
                  SELECT resource_list_member_id
                    INTO x_resource_list_member_id
                    FROM gms_balances gb
                   WHERE gb.budget_version_id = x_budget_version_id
                     AND balance_type = 'BGT'
                     AND ROWNUM = 1;
                  IF L_DEBUG = 'Y' THEN
                  	gms_error_pkg.gms_debug ( 'Not Categorized by Resource :x_resource_list_member_id >>>>>>' || x_resource_list_member_id,
                     'C' );
                  END IF;

 ----------------------------------------------------------
     --To update effect on funds code,resource list member id
       -- for each record in a packet, if not categorized by resource.
----------------------------------------------------------
                  IF x_resource_list_member_id IS NULL THEN
                     UPDATE gms_bc_packets
                        SET status_code = 'R',
                            result_code = 'F94',
                            res_result_code = 'F94',
                            res_grp_result_code = 'F94',
                            task_result_code = 'F94',
                            top_task_result_code = 'F94',
                            award_result_code = 'F94'
                      WHERE packet_id = x_packet_id
                        AND bc_packet_id = x_bc_packet_id;

                     x_err_buff := x_er_stage;
                  --('After Resource Mapping Process');
                  ELSE
                     UPDATE gms_bc_packets
                        SET resource_list_member_id = x_resource_list_member_id,
                            effect_on_funds_code = l_effect_on_funds_code
                      WHERE packet_id = x_packet_id
                        AND bc_packet_id = x_bc_packet_id
                        AND budget_version_id = x_budget_version_id;
                  END IF;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  gms_error_pkg.gms_message ( x_err_name=> 'GMS_UNEXPECTED_ERROR',
                     x_token_name1              => 'PROGRAM_NAME',
                     x_token_val1               => g_error_program_name || '.' || g_error_procedure_name || '.' || g_error_stage,
                     x_token_name2              => 'SQLCODE',
                     x_token_val2               => SQLCODE,
                     x_token_name3              => 'SQLERRM',
                     x_token_val3               => SQLERRM,
                     x_exec_type                => 'C',
                     x_err_code                 => x_err_code,
                     x_err_buff                 => x_err_buff );

                  Update gms_bc_packets
			set 	status_code              = 'T',
                     		result_code              = 'F82',
                     		res_result_code          = 'F82',
                     		res_grp_result_code      = 'F82',
                     		task_result_code         = 'F82',
                     		top_task_result_code     = 'F82',
                     		award_result_code        = 'F82'
			where	packet_id= x_packet_id
                     	and	bc_packet_id = x_bc_packet_id;
            END;
         END LOOP;

         COMMIT;
         CLOSE cur_update_col;
      END IF;

      -- x_mode <> 'U' then
      x_err_code := 0;
   EXCEPTION
      WHEN OTHERS THEN
         gms_error_pkg.gms_message ( x_err_name=> 'GMS_UNEXPECTED_ERROR',
            x_token_name1              => 'PROGRAM_NAME',
            x_token_val1               => g_error_program_name || '.' || g_error_procedure_name || '.' || g_error_stage,
            x_token_name2              => 'SQLCODE',
            x_token_val2               => SQLCODE,
            x_token_name3              => 'SQLERRM',
            x_token_val3               => SQLERRM,
            x_exec_type                => 'C',
            x_err_code                 => x_err_code,
            x_err_buff                 => x_err_buff );

                  Update gms_bc_packets
			set 	status_code              = 'T',
                     		result_code              = 'F100',
                     		res_result_code          = 'F100',
                     		res_grp_result_code      = 'F100',
                     		task_result_code         = 'F100',
                     		top_task_result_code     = 'F100',
                     		award_result_code        = 'F100'
			where	packet_id= x_packet_id;
	if cur_update_col%ISOPEN then
		close cur_update_col;
	end if;
	if c_group_by_none_cat%ISOPEN then
		close c_group_by_none_cat;
	end if;
         COMMIT;
         RAISE;

END re_base_setup_rlmi;
---------------------------------------------------------------------------------------------
procedure update_bc_packet_status(x_packet_id in number) is
begin
		update gms_bc_packets
		set status_code = 'A'
		where packet_id = x_packet_id
		and status_code = 'P';
	exception
		when others then
		raise;
end;
---------------------------------------------------------------------------------------------

/***************************************************************************+
|** Procedure to create actual and encumbrance lines in GMS_BALANCES when **|
|** Funds check is not required ********************************************|
+***************************************************************************/

PROCEDURE create_act_enc_gms_balances(x_budget_version_id number,
                                      x_base_budget_version_id number) IS
BEGIN
DELETE FROM gms_balances WHERE budget_version_id = x_budget_version_id;
DELETE FROM gms_bc_packets WHERE budget_version_id = x_budget_version_id;
--
-- Insert Actuals and Encumbrance rows into GMS_BALANCES copied
-- from the previous budget version in GMS_BALANCES

    INSERT INTO gms_balances (
 	                 PROJECT_ID,
 	                 AWARD_ID,
 	                 TASK_ID,
 	                 RESOURCE_LIST_MEMBER_ID,
 	                 SET_OF_BOOKS_ID,
 	                 BUDGET_VERSION_ID,
 	                 LAST_UPDATE_DATE,
 	                 LAST_UPDATED_BY,
 	                 CREATED_BY,
 	                 CREATION_DATE,
 	                 LAST_UPDATE_LOGIN,
 	                 PERIOD_NAME,
 	                 START_DATE,
 	                 END_DATE,
 	                 PARENT_MEMBER_ID,
 	                 BUDGET_PERIOD_TO_DATE,
                       ACTUAL_PERIOD_TO_DATE,
                       ENCUMB_PERIOD_TO_DATE)
               SELECT
                       gms.project_id,
                       gms.award_id,
                       gms.task_id,
                       gms.resource_list_member_id,
                       gms.set_of_books_id,
                       x_budget_version_id,
                       sysdate,
                       FND_GLOBAL.USER_ID,
                       FND_GLOBAL.USER_ID,
                       sysdate,
                       FND_GLOBAL.LOGIN_ID,
                       gms.PERIOD_NAME,
                       gms.START_DATE,
                       gms.END_DATE,
                       gms.PARENT_MEMBER_ID,
                       0,
                       gms.actual_period_to_date,
                       gms.encumb_period_to_date
               FROM    gms_balances gms
               WHERE gms.budget_version_id = x_base_budget_version_id
		   AND ( NVL(gms.actual_period_to_date,0) <> 0 OR NVL(gms.encumb_period_to_date,0) <> 0 );
EXCEPTION WHEN no_data_found THEN
     NULL;
END create_act_enc_gms_balances;

/***********************************************************************+
|** Procedure to get packet ids of the baselined budget and run the ****|
|** Sweeper Process for the packet ids *********************************|
+***********************************************************************/
PROCEDURE sweep_baselined_budget(x_base_budget_version_id number) IS
--
CURSOR get_pacid_cur(p_budget_version_id number) IS
       SELECT packet_id
       FROM gms_bc_packets
       WHERE budget_version_id = p_budget_version_id;
--
BEGIN
       FOR get_pacid_cur_var in get_pacid_cur(x_base_budget_version_id)
       LOOP
           EXIT WHEN get_pacid_cur%NOTFOUND;
           --
           update_bc_packet_status(get_pacid_cur_var.packet_id);
           --
            gms_sweeper.upd_act_enc_bal(ERRBUF, x_e_code, get_pacid_cur_var.packet_id,'B');
       END LOOP;
END sweep_baselined_budget;

/******************************************************************************+
|******** Procedure to update GMS_BALANCES table when funds check not reqd. ***|
+******************************************************************************/

PROCEDURE update_gms_fck_nr(x_budget_version_id number,
                            x_base_bud_version_id number,
                            x_sob_id number) IS
bud_amount number;
CURSOR sel_base_bud_lines(p_budget_version_id number) IS
SELECT
    ra.project_id,
    gbv.award_id,
    ra.task_id,
    ra.resource_list_member_id,
    gbv.budget_version_id,
    FND_GLOBAL.USER_ID,
    sysdate,
    FND_GLOBAL.LOGIN_ID,
    gbl.PERIOD_NAME,
    gbl.START_DATE,
    gbl.END_DATE,
    rm.PARENT_MEMBER_ID,
    gbl.burdened_cost   --pb.raw_cost
FROM
 gms_budget_lines gbl,
 pa_resource_assignments ra,
 gms_budget_versions gbv,
 pa_resource_list_members rm
WHERE
  gbv.budget_version_id = p_budget_version_id
  and ra.resource_assignment_id = gbl.resource_assignment_id
  and ra.budget_version_id = gbv.budget_version_id
  and rm.resource_list_member_id = ra.resource_list_member_id;
--
BEGIN
FOR sel_rec in sel_base_bud_lines(x_budget_version_id)
LOOP
EXIT WHEN sel_base_bud_lines%notfound;
--
BEGIN
  SELECT budget_period_to_date
  INTO bud_amount
  FROM gms_balances
  WHERE project_id = sel_rec.project_id
  AND award_id = sel_rec.award_id
  AND task_id = sel_rec.task_id
  AND resource_list_member_id = sel_rec.resource_list_member_id
  AND set_of_books_id = x_sob_id
  AND budget_version_id = x_budget_version_id
  AND start_date = sel_rec.start_date;
  EXCEPTION WHEN no_data_found THEN

	  INSERT INTO gms_balances (project_id
                            ,award_id
                            ,task_id
                            ,resource_list_member_id
                            ,set_of_books_id
                            ,budget_Version_id
                            ,last_update_date
                            ,last_updated_by
                            ,created_by
                            ,creation_date
                            ,last_update_login
                            ,period_name
                            ,start_date
                            ,end_date
			    ,balance_type
                            ,parent_member_id
                            ,budget_period_to_date
                             )
   VALUES
                           (sel_rec.project_id
                            ,sel_rec.award_id
                            ,sel_rec.task_id
                            ,sel_rec.resource_list_member_id
                            ,x_sob_id
                            ,x_budget_version_id
                            ,sysdate
                            ,FND_GLOBAL.USER_ID
                            ,FND_GLOBAL.USER_ID
                            ,sysdate
                            ,FND_GLOBAL.LOGIN_ID
                            ,sel_rec.period_name
                            ,sel_rec.start_date
                            ,sel_rec.end_date
			    ,'BGT'
                            ,sel_rec.parent_member_id
                            ,sel_rec.burdened_cost
                           );
  END;
  IF bud_amount <> sel_rec.burdened_cost THEN
     UPDATE gms_balances
     SET budget_period_to_date = sel_rec.burdened_cost
     WHERE  Project_id = sel_rec.project_id
     AND award_id = sel_rec.award_id
     AND task_id = sel_rec.task_id
     AND resource_list_member_id = sel_rec.resource_list_member_id
     AND set_of_books_id = x_sob_id
     AND budget_version_id = x_budget_version_id
     AND start_date = sel_rec.start_date;
  END IF;
END LOOP;


END update_gms_fck_nr;

-------------------------------------------------------------------------------


BEGIN


	-- Bug 1980810 : Added to set currency related global variables
	--		 Call to pa_currency.round_currency_amt function will use
	--		 global variables and thus improves performance

	 pa_currency.set_currency_info;


	x_e_stage := '100';
-- TO SELECT SET OF BOOKS ID
	select set_of_books_id into x_sob_id
	from pa_implementations;
	x_e_stage := '200';
    	IF L_DEBUG = 'Y' THEN
    		gms_error_pkg.gms_debug('gms_budget_balance -1','C');
    	END IF;
-- TO SELECT DRAFT_BUDGET_VERSION_ID FROM PA_BUDGET_VERSION TABLE.
	select max(budget_version_id) into x_budget_version_id
	from gms_budget_versions
	where project_id = x_project_id
        and award_id = to_char(x_award_id)
        and  ((budget_status_code ='W' and x_mode='S')
	or (budget_status_code = 'B' and x_mode = 'B'));
    	IF L_DEBUG = 'Y' THEN
    		gms_error_pkg.gms_debug('gms_budget_balance -2','C');
    	END IF;

/* -- Commented out NOCOPY for Bug: 1666853 - will be included in 11.5F

--Logic for Conditional FC : Start -----------------------------------------------------------------

        BEGIN
        x_e_stage := '210';

          select fc_required_flag
          into x_fc_required_flag
          from gms_budget_versions
          where project_id = x_project_id
          and award_id = x_award_id
          and budget_status_code in ('W','S');

          if nvl(x_fc_required_flag,'Y') = 'N' then

            BEGIN

                SELECT budget_version_id
                INTO x_base_bud_version_id
                FROM gms_budget_versions
                WHERE project_id = x_project_id
                AND award_id = x_award_id
                AND budget_status_code = 'B'
                AND (current_flag = 'Y'
			OR current_flag = 'R');


                -- If GMS:Update Actual and Encumbrance balance conc. process is
                -- not run then the actuals and encumbrances should be picked
                -- from GMS_BC_PACKETS otherwise the actuals and encumbrances should
                -- be picked from GMS_BALANCES since it will no longer be in
                -- GMS_BC_PACKETS.

                begin
                    SELECT 1 into x_dummy from dual
                    where exists (select 'x'
                    FROM gms_bc_packets
                    WHERE project_id = x_project_id
                    AND   award_id   = x_award_id
                    AND budget_version_id = x_base_bud_version_id
                    AND status_code ='A');
                exception
                    when no_data_found then
                        SELECT count(1)
                        INTO x_dummy
                        FROM gms_balances
                        WHERE project_id = x_project_id
                        AND   award_id   = x_award_id
                        AND budget_version_id = x_base_bud_version_id
                        AND actual_period_to_date is NOT NULL
                        AND encumb_period_to_date is NOT NULL;
                end;


                IF x_dummy = 0 THEN
                    create_act_enc_gms_balances(x_budget_version_id,x_base_bud_version_id);
                    update_gms_fck_nr(x_budget_version_id,x_base_bud_version_id,x_sob_id);
                    RETCODE := 'S';
                    RETURN;
                ELSE
                    sweep_baselined_budget(x_base_bud_version_id);
                    create_act_enc_gms_balances(x_budget_version_id,x_base_bud_version_id);
                    update_gms_fck_nr(x_budget_version_id,x_base_bud_version_id,x_sob_id);
                    RETCODE := 'S';
                    RETURN;
                END IF;
            EXCEPTION when no_data_found THEN
                NULL;
            END;
        END IF;
    END;

--Logic for Conditional FC : End -----------------------------------------------------------------
 for bug: 1666853 */

-- re-create GMS_BALANCES record
	x_e_stage := '300';
	open gms_bal_lock;    -- lock gms_balances records for the budget version
    	IF L_DEBUG = 'Y' THEN
    		gms_error_pkg.gms_debug('gms_budget_balance -3','C');
    	END IF;
	x_e_stage := '400';
    	IF L_DEBUG = 'Y' THEN
    		gms_error_pkg.gms_debug('gms_budget_balance -4','C');
    	END IF;
	create_gms_balance( x_budget_version_id,  x_sob_id, x_project_id, x_award_id );
-- Get a new packet id
	x_e_stage := '500';
    	IF L_DEBUG = 'Y' THEN
    		gms_error_pkg.gms_debug('gms_budget_balance -5','C');
    	END IF;
	select gl_bc_packets_s.nextval into x_packet_id from dual;
-- Create raw transactions in GMS_BC_PACKETS
	x_e_stage := '600';
    	IF L_DEBUG = 'Y' THEN
    		gms_error_pkg.gms_debug('gms_budget_balance -6','C');
    	END IF;
	create_direct_cost(x_packet_id 	,
			     x_sob_id	,
			     x_project_id,
                 x_award_id,
                 x_budget_version_id);
-- Create burden transactions in GMS_BC_PACKETS
	x_e_stage := '700';
	create_indirect_cost(x_packet_id);
-------------------------------------------------------------
  Begin
  	IF L_DEBUG = 'Y' THEN
  		gms_error_pkg.gms_debug('gms_budget_balance -7','C');
  	END IF;
	x_e_stage := '800';
    begin
       select count(packet_id) into x_run
       from gms_bc_packets
       where  packet_id = x_packet_id
       and    rownum < 2;
	exception
	when no_data_found then
		null;
    end;
	x_e_stage := '900';
    	IF L_DEBUG = 'Y' THEN
    		gms_error_pkg.gms_debug('gms_budget_balance -8','C');
    	END IF;
    if x_run > 0 then
	if x_mode in ('S','B') then
        	if NOT GMS_FUNDS_CONTROL_PKG.GMS_FCK( x_sob_id,
      		             	 	  x_packet_id,
                              	 	  x_mode,                     -- DEFAULT 'R'
    	           	 	                    x_over,			-- DEFAULT 'N'
				                    x_partial,			-- DEFAULT 'N'
    	             		              x_user_id,			-- DEFAULT NULL
                   		              x_user_resp_id,			-- DEFAULT NULL
			 	                    x_execute,			-- DEFAULT 'Y',
				                    x_return_code,
			 	                    x_e_code,
			 	                    x_e_mesg)   then
            		ERRBUF	:= x_e_stage||': '||x_e_mesg;
        	end if;

		if x_e_code = 'S' then
			retcode := 'S';
		else
			retcode := 'F';
		end if;
	else
					--Recreating gms_balances without going thro' FC
		x_e_stage := '910';
        	IF L_DEBUG = 'Y' THEN
        		gms_error_pkg.gms_debug('gms_budget_balance -9','C');
        	END IF;
		-- Update resource list
		RETCODE := 'S';
		re_base_setup_rlmi(x_packet_id, x_budget_version_id,x_err_code,x_err_buff);
			if x_err_code <> 0 then
      				gms_error_pkg.gms_message('GMS_RE_BASE_RLMI_FAILED',
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);

			end if;
		x_e_stage := '920';
        	IF L_DEBUG = 'Y' THEN
        		gms_error_pkg.gms_debug('gms_budget_balance -10','C');
        	END IF;
		update_bc_packet_status(x_packet_id);
		-- Update gms_balances using sweeper process
	end if;
					--Recreating gms_balances without going thro' FC
    else
      RETCODE := 'S';
    end if;
	x_e_stage := '930';
    	IF L_DEBUG = 'Y' THEN
    		gms_error_pkg.gms_debug('gms_budget_balance -11','C');
    	END IF;

/* -- Commented out NOCOPY for Bug: 1666853 ...
   -- Sweeper is now being called from GMS_BUDGET_PUB.BASELINE_BUDGET()
   -- after the budget status flags have been updated.

	if RETCODE = 'S' then


   -- Added if endif so that sweeper called only for baselining

             if x_mode ='B' then

    		IF L_DEBUG = 'Y' THEN
    			gms_error_pkg.gms_debug('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%','C');
                	gms_error_pkg.gms_debug('--------- Calling balance Sweeper ------','C');
    			gms_error_pkg.gms_debug('RETCODE'||RETCODE,'C');
    			gms_error_pkg.gms_debug('x_mode'||x_mode,'C');
    			gms_error_pkg.gms_debug('x_packet_id'||x_packet_id,'C');
    			gms_error_pkg.gms_debug('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%','C');
    		END IF;


		gms_sweeper.upd_act_enc_bal(ERRBUF, x_e_code, x_packet_id,x_mode,x_project_id,x_award_id);
        	IF L_DEBUG = 'Y' THEN
        		gms_error_pkg.gms_debug('gms_budget_balance -12','C');
        	END IF;
             end if;


    		if x_e_code <> 'S' then
			RETCODE := 'H';
    		else
			RETCODE := 'S';
    		end if;
	end if;
.... for Bug: 1666853 */

  Exception
    when resource_busy then
	if gms_bal_lock%isopen then
		close gms_bal_lock ;
	end if;
      RETCODE := 'L';
      ERRBUF  := (SQLCODE||SQLERRM);
	return;
    when OTHERS then
	if gms_bal_lock%isopen then
		close gms_bal_lock;
	end if;
      RETCODE := 'H';
      ERRBUF  := (X_E_STAGE||': '||SQLERRM);
	return;
  End;
  Exception
    when OTHERS then
 RETCODE := 'H';
 	IF L_DEBUG = 'Y' THEN
 		gms_error_pkg.gms_debug('gms_budget_balance -14','C');
 	END IF;
 ERRBUF  := (X_E_STAGE||': '||SQLERRM);
end update_gms_balance;

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Bug 2721095 : The following function is introduced to calculate PO's quantity billed
--              based on following logic :
--              IF its not a new PO distribution Line then return the global variable G_PO_QUANTITY_BILLED
--              ELSE Re calculate the value of  PO's quantity Billed
--
--                       PO's quantity Billed = sum (quantity_invoiced on approved AP that
--                                                   is matched to the PO)
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
FUNCTION get_po_qty_invoiced (p_po_distribution_id NUMBER,
                              p_po_quantity_billed NUMBER ,
                              p_recalc VARCHAR2 ) RETURN NUMBER
IS

CURSOR c_get_quantity_invoiced IS
SELECT nvl(sum(aid.quantity_invoiced),0)
FROM   ap_invoice_distributions aid,
       gms_award_distributions adl
WHERE  aid.po_distribution_id = p_po_distribution_id
AND    aid.distribution_line_number    = adl.distribution_line_number
AND    aid.invoice_distribution_id     = adl.invoice_distribution_id -- AP Lines change
AND    aid.invoice_id                  = adl.invoice_id
AND    adl.document_type               = 'AP'
AND    adl.award_set_id                = aid.award_id
AND    aid.line_type_lookup_code       = 'ITEM'
AND    adl.adl_status                  = 'A'
AND    nvl(adl.fc_status,'N')          = 'A'
AND    nvl(aid.match_status_flag,'N')  = 'A';

BEGIN

IF p_recalc = 'N' and nvl(G_PO_DISTRIBUTION_ID,-999) = p_po_distribution_id THEN

 Return G_PO_QUANTITY_BILLED ;

ELSE

  G_PO_DISTRIBUTION_ID := p_po_distribution_id;

  OPEN  c_get_quantity_invoiced;
  FETCH c_get_quantity_invoiced into G_PO_QUANTITY_BILLED;
  CLOSE c_get_quantity_invoiced;

  RETURN G_PO_QUANTITY_BILLED ;

END IF;

EXCEPTION
WHEN OTHERS THEN

            IF c_get_quantity_invoiced%ISOPEN THEN
               CLOSE c_get_quantity_invoiced;
            END IF;

            IF p_recalc = 'N' and nvl(G_PO_DISTRIBUTION_ID,-999) = p_po_distribution_id THEN
              RETURN G_PO_QUANTITY_BILLED;
	    ELSE
              G_PO_DISTRIBUTION_ID := p_po_distribution_id;
              G_PO_QUANTITY_BILLED := p_po_quantity_billed;
              RETURN G_PO_QUANTITY_BILLED;
            END IF;

END get_po_qty_invoiced ;

end gms_budget_balance;

/
