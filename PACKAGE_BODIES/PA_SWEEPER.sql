--------------------------------------------------------
--  DDL for Package Body PA_SWEEPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_SWEEPER" AS
-- $Header: PAFCUAEB.pls 120.7 2006/03/31 03:52:46 rshaik noship $

 -- Function : GetBCBalStartDate
 -- Purpose  : Based on TPC, returns the start date
 -- Changed 5/29 to check for GL date, PA date when TPC = G, P resp.
 --            If TPC = GL then selects GL period start date where the given GL date falls.
 --            If TPC = PA then selects PA period start date where the given PA date falls.
 --            If TPC = 'N' then get the start_date from pa_bc_balances where EI date falls
 --            for the given task, budget_version and RLMI.
 FUNCTION GetBCBalStartDate(
	p_time_phase_code in varchar2,
	p_project_id in number,
	p_ei_date in date,
	p_bdgt_version in number,
	p_sob_id in number,
        p_org_id in number,
        p_task_id in number,
        p_top_task_id in number,
        p_rlmi in number,
        p_gl_date in date,
        p_pa_date in date) return date
 IS
     l_st_date date;
 BEGIN
     --pa_funds_control_utils.print_message('Entering GetBCBalStartDate, Time Phase = ' || p_time_phase_code || ' Sob = '|| p_sob_id || ' Org Id = ' || p_org_id);
     --pa_fck_util.debug_msg('Entering GetBCBalStartDate' );

     IF p_time_phase_code = 'G' then
           select gps.start_date
             into l_st_date
             from gl_period_statuses gps
            where gps.application_id = 101
              and gps.set_of_books_id = p_sob_id
              and trunc(p_gl_date) between trunc(gps.start_date) and trunc(gps.end_date)
              and gps.adjustment_period_flag = 'N';
     ELSIF p_time_phase_code = 'P' then
           select pda.start_date
             into l_st_date
             from pa_periods_all pda
            where trunc(pda.start_date) <= trunc(p_pa_date)
              and trunc(pda.end_date) >= trunc(p_pa_date)
                  --trunc(p_ei_date) between trunc(pda.start_date) and trunc(pda.end_date)
              -- R12 and nvl(pda.org_id,-99) = nvl(p_org_id,-99);
              and pda.org_id = p_org_id;
     ELSIF p_time_phase_code = 'N' then

	  -- Bug 3487403 and 3400389 Modified the code for time_phase_type_code 'N'

	  DECLARE

		  CURSOR c_prj_start IS
		  SELECT start_date
		    FROM pa_projects_all
		   WHERE project_id = p_project_id;

		  CURSOR c_prj_budg IS
		  SELECT MIN(start_date)
		    FROM pa_bc_balances
		   WHERE project_id = p_project_id
		     AND budget_version_id = p_bdgt_version;

           BEGIN

		OPEN c_prj_start;
	       FETCH c_prj_start INTO l_st_date;
	       CLOSE c_prj_start;

              IF l_st_date IS NULL THEN

	 	 OPEN c_prj_budg;
		FETCH c_prj_budg INTO l_st_date;
	        CLOSE c_prj_budg;

 	      END IF;

	      IF l_st_date IS NULL THEN
	               l_st_date := p_ei_date;
	      ELSIF l_st_date > p_ei_date THEN
		       l_st_date := p_ei_date;
              END IF;

	  END;

     END IF;

     --pa_funds_control_utils.print_message('Leaving Start date');
     --pa_fck_util.debug_msg('Exiting GetBCBalStartDate' );
     return l_st_date;
 EXCEPTION
     WHEN OTHERS THEN
          raise;
 END GetBCBalStartDate;


 -- Function : GetBCBalEndDate
 -- Purpose  : Based on TPC, returns the end date
 -- Changed 5/29 to check for GL date, PA date when TPC = G, P resp.
 --            If TPC = GL then selects GL period end date where the given GL date falls.
 --            If TPC = PA then selects PA period end date where the given PA date falls.
 --            If TPC = 'N' then get the end_date from pa_bc_balances where EI date falls
 --            for the given task, budget_version and RLMI.
 FUNCTION GetBCBalEndDate(
	p_time_phase_code in varchar2,
	p_project_id in number,
	p_ei_date in date,
	p_bdgt_version in number,
	p_sob_id in number,
        p_org_id in number,
        p_task_id in number,
        p_top_task_id in number,
        p_rlmi in number,
        p_gl_date in date,
        p_pa_date in date) return date
 IS
     l_ed_date date;
 BEGIN
     --pa_funds_control_utils.print_message('Entering GetBCBalEndDate');
     --pa_fck_util.debug_msg('Entering GetBCBalEndDate' );

     IF p_time_phase_code = 'G' then
           select gps.end_date
             into l_ed_date
             from gl_period_statuses gps
            where gps.application_id = 101
              and gps.set_of_books_id = p_sob_id
              and trunc(p_gl_date) between trunc(gps.start_date) and trunc(gps.end_date)
              and gps.adjustment_period_flag = 'N';
     ELSIF p_time_phase_code = 'P' then
           select ppd.end_date
             into l_ed_date
             from pa_periods_all ppd
            where trunc(ppd.start_date) <= trunc(p_pa_date)
              and trunc(ppd.end_date) >= trunc(p_pa_date)
                  --trunc(p_ei_date) between trunc(ppd.start_date) and trunc(ppd.end_date)
              -- R12 and nvl(ppd.org_id,-99) = nvl(p_org_id,-99);
              and ppd.org_id = p_org_id;
     ELSIF p_time_phase_code = 'N' then

	-- Bug 3487403 and 3400389 Modified the code for time_phase_type_code 'N'

	DECLARE

          CURSOR c_prj_end IS
	  SELECT completion_date
	    FROM pa_projects_all
	   WHERE project_id = p_project_id;

	  CURSOR c_prj_budg IS
	  SELECT MAX(end_date)
	    FROM pa_bc_balances
	   WHERE project_id = p_project_id
	     AND budget_version_id = p_bdgt_version;

	BEGIN

	   OPEN c_prj_end;
	   FETCH c_prj_end INTO l_ed_date;
	   CLOSE c_prj_end;

	   IF l_ed_date IS NULL THEN
	  	 OPEN c_prj_budg;
	         FETCH c_prj_budg INTO l_ed_date;
		 CLOSE c_prj_budg;
	   END IF;

	   IF l_ed_date IS NULL THEN
	            l_ed_date := p_ei_date;
	   ELSIF l_ed_date < p_ei_date THEN
	            l_ed_date := p_ei_date;
	   END IF;

	END;

     END IF;

     --pa_funds_control_utils.print_message('Leaving End date');
     --pa_fck_util.debug_msg('Exiting GetBCBalEndDate' );
     return l_ed_date;
 EXCEPTION
     WHEN OTHERS THEN
          raise;
 END GetBCBalEndDate;

PROCEDURE update_act_enc_balance(
                 x_return_status       OUT NOCOPY VARCHAR2
                 ,x_error_message_code OUT NOCOPY VARCHAR2
                 --PA.M
                 ,p_project_id         IN  NUMBER DEFAULT NULL) IS

  cursor c_pkt_proj is
   select distinct project_id project_id
   from pa_bc_packets
   where status_code = 'A'
   and substr(result_code ,1,1) = 'P'
   --PA.M
   and (Pa_Bc_Packets.Project_Id = P_Project_Id
        Or P_ProjecT_Id is NULL) ;

  cursor c_bc_packets(l_project_id in number) is
   select  pbc.budget_version_id
   ,       pbc.project_id
   ,       pbc.task_id
   ,       pbc.bud_task_id
   ,       pbc.top_task_id
   ,       pbc.document_type
   ,       pbc.period_name
   ,       pbc.resource_list_member_id
   ,       pbc.parent_resource_id
   ,       pbc.set_of_books_id
   ,       trunc(pbc.expenditure_item_date) expenditure_item_date
   ,       pbc.accounted_dr
   ,       pbc.accounted_cr
   ,       pbc.actual_flag
   ,       pbv.resource_list_id
   ,       pbm.time_phased_type_code
   ,       pbc.document_header_id
   ,       pbc.document_distribution_id
   ,       pbc.bc_commitment_id
   ,       pbc.packet_id
   ,       pbc.expenditure_type
   ,       pbc.pa_date
   ,       pbc.gl_date
   ,       pbc.period_year
   ,       pbc.period_num
   ,       pbc.je_category_name
   ,       pbc.je_source_name
   ,       pbc.expenditure_organization_id
   ,       pbc.entered_dr
   ,       pbc.entered_cr
   ,       pbc.budget_ccid
   ,       pbc.txn_ccid
   ,       pbc.bc_packet_id
   ,       pbc.parent_bc_packet_id
   ,       pbc.bud_resource_list_member_id
   ,       pbc.balance_posted_flag
   ,       pbc.encumbrance_type_id
   ,       pbc.proj_encumbrance_type_id
   ,       pbc.status_code
   ,       pbc.org_id
   ,       pbc.burden_cost_flag
   --PA.M
   ,       pbc.Document_Line_Id
   ,       pbc.Compiled_Multiplier
   ,       pbc.Fc_Start_Date
   ,       pbc.Fc_End_Date
   ,       pbc.Comm_Tot_Raw_Amt
   ,       pbc.Comm_Tot_Bd_Amt
   ,       pbc.Comm_Raw_Amt_Relieved
   ,       pbc.Comm_Bd_Amt_Relieved
   ,       pbc.Summary_Record_Flag
   ,       pbc.Exp_Item_Id
   ,       pbc.reference1
   ,       pbc.reference2
   ,       pbc.reference3
   --R12
   ,       pbc.bc_event_id
   ,       pbc.vendor_id
   ,       pbc.budget_line_id
   ,       pbc.burden_method_code
   ,       pbc.document_header_id_2
   ,       pbc.document_distribution_type
   from    pa_budget_versions pbv
           , pa_bc_packets   pbc
           , pa_budget_entry_methods pbm
   where   pbc.status_code = 'A'
   and     substr(pbc.result_code ,1,1) = 'P'
   and     pbc.balance_posted_flag = 'N'
   and     pbv.budget_version_id = pbc.budget_version_id
   and     pbc.project_id = pbv.project_id
   and     pbv.budget_entry_method_code = pbm.budget_entry_method_code
   and     pbc.project_id = l_project_id
   order by pbc.packet_id;

  cursor c_ins_packets(l_project_id in number) is
   select  pbc.budget_version_id
   ,       pbc.project_id
   ,       pbc.task_id
   ,       pbc.top_task_id
   ,       pbc.document_type
   ,       pbc.resource_list_member_id
   ,       pbc.parent_resource_id
   ,       pbc.set_of_books_id
   ,       sum((nvl(pbc.accounted_dr,0)- nvl(pbc.accounted_cr,0)))*decode(pbc.document_type,'EXP',1,0)
           actual_ptd
   ,       sum((nvl(pbc.accounted_dr,0)- nvl(accounted_cr,0)))*decode(pbc.document_type,'REQ',1,'PO',1,'AP',1,'CC_P_CO',1,'CC_C_CO',1,'CC_P_PAY',1,'CC_C_PAY',1,0)
           encumb_ptd
   ,       pbc.balance_posted_flag
   ,       pbc.status_code
   ,       pbm.time_phased_type_code
   --,       trunc(pbc.expenditure_item_date)
   ,       PA_SWEEPER.GetBCBalStartDate(pbm.time_phased_type_code,pbc.project_id,pbc.expenditure_item_date,pbc.budget_version_id, pbc.set_of_books_id, pbc.org_id, pbc.task_id, pbc.top_task_id, pbc.resource_list_member_id,pbc.gl_date,pbc.pa_date)
   ,       PA_SWEEPER.GetBCBalEndDate(pbm.time_phased_type_code,pbc.project_id,pbc.expenditure_item_date, pbc.budget_version_id, pbc.set_of_books_id, pbc.org_id, pbc.task_id, pbc.top_task_id, pbc.resource_list_member_id,pbc.gl_date,pbc.pa_date)
   /*Bug 3007393*/
   /*,       pbc.org_id*/
   from    pa_budget_versions pbv
           , pa_bc_packets   pbc
           , pa_budget_entry_methods pbm
   where   pbc.status_code = 'A'
   and     substr(pbc.result_code ,1,1) = 'P'
   and     pbc.balance_posted_flag = 'N'
   and     pbv.budget_version_id = pbc.budget_version_id
   and     pbv.budget_entry_method_code = pbm.budget_entry_method_code
   and     pbc.project_id = pbv.project_id
   and     pbc.project_id = l_project_id
   and     not exists (
           select 'X'
           from   pa_bc_balances pb
           where  pb.project_id = l_project_id
           AND    pb.task_id   = pbc.task_id
           AND    pb.resource_list_member_id = pbc.resource_list_member_id
           AND    pb.set_of_books_id = pbc.set_of_books_id
           AND    pb.budget_version_id = pbc.budget_version_id
           AND    pb.balance_type = pbc.document_type
           AND    ((pbm.time_phased_type_code = 'N' and
                   trunc(pbc.expenditure_item_date) between trunc(pb.start_date) and trunc(pb.end_date))
                  OR (pbm.time_phased_type_code = 'P' and
                   trunc(pbc.pa_date) between trunc(pb.start_date) and trunc(pb.end_date))
                  OR (pbm.time_phased_type_code = 'G' and
                   trunc(pbc.gl_date) between trunc(pb.start_date) and trunc(pb.end_date))))
   group by  pbc.budget_version_id
   ,       pbc.project_id
   ,       pbc.task_id
   ,       pbc.top_task_id
   ,       pbc.document_type
   --,       trunc(pbc.expenditure_item_date)
   ,       PA_SWEEPER.GetBCBalStartDate(pbm.time_phased_type_code,pbc.project_id,pbc.expenditure_item_date,pbc.budget_version_id, pbc.set_of_books_id, pbc.org_id, pbc.task_id, pbc.top_task_id, pbc.resource_list_member_id,pbc.gl_date,pbc.pa_date)
   ,       PA_SWEEPER.GetBCBalEndDate(pbm.time_phased_type_code,pbc.project_id,pbc.expenditure_item_date, pbc.budget_version_id, pbc.set_of_books_id, pbc.org_id, pbc.task_id, pbc.top_task_id, pbc.resource_list_member_id,pbc.gl_date,pbc.pa_date)
   ,       pbc.resource_list_member_id
   ,       pbc.parent_resource_id
   ,       pbc.set_of_books_id
   ,       pbm.time_phased_type_code
   ,       pbc.balance_posted_flag
   ,       pbc.status_code;
   /*Bug 3007393*/
   /*,       pbc.org_id;*/

   l_profile_value varchar2(255) := FND_PROFILE.VALUE('PA_MAINTAIN_FC_PACKETS'); -- Added for Bug 4588095

   cursor c_delete_pkts is
   select rowid
     from pa_bc_packets
    where status_code in ('X', 'V', 'L')
--    and (trunc(sysdate) - trunc(creation_date)) >= FND_PROFILE.VALUE_SPECIFIC('PA_MAINTAIN_FC_PACKETS'); Modified for Bug 4588095
      and (trunc(sysdate) - trunc(creation_date)) >= l_profile_value
   union all
   select rowid
     from pa_bc_packets pbc
    where pbc.status_code in ('P')
      and ((pbc.session_id is not null and
            pbc.serial_id is not null  and
            NOT EXISTS (SELECT 'x'
		        FROM v$session
		       WHERE audsid = pbc.session_id
	                 AND Serial# = pbc.serial_id)
          ) OR
          (pbc.session_id is null and
            pbc.serial_id is null and
            (trunc(sysdate) - trunc(creation_date)) >= 10
             -- modified from 3 to 10 days .. we're not expecting any process to run for 10 days
             -- interface runs by batch size and we're not expecting batches to run for 10 days
          )
         )
   union all
   select rowid
     from pa_bc_packets
    where status_code in ('I')
      and (trunc(sysdate) - trunc(creation_date)) >= 3
   union all
   select rowid
     from pa_bc_packets pbc
    where pbc.status_code in ('S','F','T','R')
    and   (trunc(sysdate) - trunc(pbc.creation_date)) >= l_profile_value
    and  ((pbc.bc_event_id is null) OR
          (pbc.bc_event_id is not null AND
           NOT EXISTS (select 1 from xla_events xl
                       where  xl.event_id = pbc.bc_event_id)
          )
         );


   l_st_date       date;
   l_ed_date       date;
   l_debug_mode    varchar2(1) := 'N';
   l_count 	   number := 0;
   l_project_id    number;

   num             number := 0;

   l_PktBdgtVerTab  PA_PLSQL_DATATYPES.IdTabTyp;
   l_PktProjectTab  PA_PLSQL_DATATYPES.IdTabTyp;
   l_PktTaskTab     PA_PLSQL_DATATYPES.IdTabTyp;
   l_PktDocTypTab   PA_PLSQL_DATATYPES.Char10TabTyp;
   l_PktSobTab      PA_PLSQL_DATATYPES.IdTabTyp;
   l_PktDocHeadTab  PA_PLSQL_DATATYPES.IdTabTyp;
   l_PktDocDistTab  PA_PLSQL_DATATYPES.IdTabTyp;
   l_PktEiDateTab   PA_PLSQL_DATATYPES.DateTabTyp;
   l_PktExpTypTab   PA_PLSQL_DATATYPES.Char30TabTyp;
   l_PktExpOrgTab   PA_PLSQL_DATATYPES.IdTabTyp;
   l_PktActFlagTab  PA_PLSQL_DATATYPES.Char1TabTyp;
   l_PktPeriodTab   PA_PLSQL_DATATYPES.Char15TabTyp;
   l_PktTPCTab      PA_PLSQL_DATATYPES.Char30TabTyp;
   l_PktRlmiTab     PA_PLSQL_DATATYPES.IdTabTyp;
   l_PktParResTab   PA_PLSQL_DATATYPES.IdTabTyp;
   l_PktBdgtTaskTab PA_PLSQL_DATATYPES.IdTabTyp;
   l_PktBdgtRlmiTab PA_PLSQL_DATATYPES.IdTabTyp;
   l_PktTTaskTab    PA_PLSQL_DATATYPES.IdTabTyp;
   l_PktEntDrTab    PA_PLSQL_DATATYPES.NumTabTyp;
   l_PktEntCrTab    PA_PLSQL_DATATYPES.NumTabTyp;
   l_PktAcctDrTab   PA_PLSQL_DATATYPES.NumTabTyp;
   l_PktAcctCrTab   PA_PLSQL_DATATYPES.NumTabTyp;
   l_PktStatusTab   PA_PLSQL_DATATYPES.Char1TabTyp;
   l_PktBcCommTab   PA_PLSQL_DATATYPES.IdTabTyp;
   l_PktPADateTab   PA_PLSQL_DATATYPES.DateTabTyp;
   l_PktGLDateTab   PA_PLSQL_DATATYPES.DateTabTyp;
   l_PktBdgtCCIDTab PA_PLSQL_DATATYPES.IdTabTyp;
   l_PktTxnCCIDTab  PA_PLSQL_DATATYPES.IdTabTyp;
   l_PktParBcPktTab PA_PLSQL_DATATYPES.IdTabTyp;
   l_PktBcPktTab    PA_PLSQL_DATATYPES.IdTabTyp;
   l_PktIdTab       PA_PLSQL_DATATYPES.IdTabTyp;
   l_PktSrcNameTab  PA_PLSQL_DATATYPES.Char30TabTyp;
   l_PktCatNameTab  PA_PLSQL_DATATYPES.Char30TabTyp;
   l_PktPdYearTab   PA_PLSQL_DATATYPES.NumTabTyp;
   l_PktPdNumTab    PA_PLSQL_DATATYPES.NumTabTyp;
   l_PktRlistTab    PA_PLSQL_DATATYPES.NumTabTyp;
   l_PktBalPostFlagTab PA_PLSQL_DATATYPES.Char1TabTyp;
   l_PktEncTypIdTab    PA_PLSQL_DATATYPES.IdTabTyp;
   l_PktPrjEncTypIdTab PA_PLSQL_DATATYPES.IdTabTyp;
   l_PktOrgIdTab    PA_PLSQL_DATATYPES.IdTabTyp;
   l_PktCstBurdFlagTab  PA_PLSQL_DATATYPES.Char1TabTyp;

   l_InsBdgtVerTab  PA_PLSQL_DATATYPES.IdTabTyp;
   l_InsProjectTab  PA_PLSQL_DATATYPES.IdTabTyp;
   l_InsTaskTab     PA_PLSQL_DATATYPES.IdTabTyp;
   l_InsTTaskTab    PA_PLSQL_DATATYPES.IdTabTyp;
   l_InsDocTypTab   PA_PLSQL_DATATYPES.Char10TabTyp;
   l_InsRlmiTab     PA_PLSQL_DATATYPES.IdTabTyp;
   l_InsParResTab   PA_PLSQL_DATATYPES.IdTabTyp;
   l_InsSobTab      PA_PLSQL_DATATYPES.IdTabTyp;
   l_InsActPTDTab   PA_PLSQL_DATATYPES.NumTabTyp;
   l_InsEncPTDTab   PA_PLSQL_DATATYPES.NumTabTyp;
   l_InsBalPostFlagTab PA_PLSQL_DATATYPES.Char1TabTyp;
   l_InsStatusTab   PA_PLSQL_DATATYPES.Char1TabTyp;
   l_InsTPCTab      PA_PLSQL_DATATYPES.Char30TabTyp;
 --l_InsEiDateTab   PA_PLSQL_DATATYPES.DateTabTyp;
   l_InsStDateTab   PA_PLSQL_DATATYPES.DateTabTyp;
   l_InsEdDateTab   PA_PLSQL_DATATYPES.DateTabTyp;
   l_InsOrgIdTab    PA_PLSQL_DATATYPES.IdTabTyp;

   l_StsUpdPktIdTab PA_PLSQL_DATATYPES.IdTabTyp;
   l_StsUpdBcPktIdTab PA_PLSQL_DATATYPES.IdTabTyp;

   l_RowIdTab       PA_PLSQL_DATATYPES.RowidTabTyp;

   --PA.M
   l_PktDocLineIdTab           PA_PLSQL_DATATYPES.IdTabTyp;
   l_PktCompMultiplierTab      PA_PLSQL_DATATYPES.NumTabTyp;
   l_PktFcStartDateTab         PA_PLSQL_DATATYPES.DateTabTyp;
   l_PktFcEndDateTab           PA_PLSQL_DATATYPES.DateTabTyp;
   l_PktCommTotRawAmtTab       PA_PLSQL_DATATYPES.NumTabTyp;
   l_PktCommTotBdAmtTab        PA_PLSQL_DATATYPES.NumTabTyp;
   l_PktCommRawAmtRelievedTab  PA_PLSQL_DATATYPES.NumTabTyp;
   l_PktCommBdAmtRelievedTab   PA_PLSQL_DATATYPES.NumTabTyp;
   l_PktSummaryRecordFlagTab   PA_PLSQL_DATATYPES.Char1TabTyp;
   l_PktExpItemIdTab           PA_PLSQL_DATATYPES.IdTabTyp;
   l_PktReference1Tab          PA_PLSQL_DATATYPES.Char80TabTyp;
   l_PktReference2Tab          PA_PLSQL_DATATYPES.Char80TabTyp;
   l_PktReference3Tab          PA_PLSQL_DATATYPES.Char80TabTyp;

   --R12
   l_PktBcEventIDTab           PA_PLSQL_DATATYPES.IdTabTyp;
   l_PktBudgetLineIDTab        PA_PLSQL_DATATYPES.IdTabTyp;
   l_PktBurdenMethodCodeTab    PA_PLSQL_DATATYPES.Char30TabTyp;
   l_PktVendorIdTab            PA_PLSQL_DATATYPES.IdTabTyp;
   l_PktDocHdrId2Tab           PA_PLSQL_DATATYPES.IdTabTyp;
   l_PktDocDistTypeTab         PA_PLSQL_DATATYPES.Char30TabTyp;

   rows   NATURAL := 200;

  --Code Changes for Bug No.2984871 start
     l_rowcount number :=0;
  --Code Changes for Bug No.2984871 end

 --Procedure to initialize the pl/sql tables
 PROCEDURE InitPlSqlTabs is
 BEGIN
   l_PktBdgtVerTab.Delete;
   l_PktProjectTab.Delete;
   l_PktTaskTab.Delete;
   l_PktDocTypTab.Delete;
   l_PktSobTab.Delete;
   l_PktDocHeadTab.Delete;
   l_PktDocDistTab.Delete;
   l_PktEiDateTab.Delete;
   l_PktExpTypTab.Delete;
   l_PktExpOrgTab.Delete;
   l_PktActFlagTab.Delete;
   l_PktPeriodTab.Delete;
   l_PktTPCTab.Delete;
   l_PktRlmiTab.Delete;
   l_PktParResTab.Delete;
   l_PktBdgtTaskTab.Delete;
   l_PktBdgtRlmiTab.Delete;
   l_PktTTaskTab.Delete;
   l_PktEntDrTab.Delete;
   l_PktEntCrTab.Delete;
   l_PktAcctDrTab.Delete;
   l_PktAcctCrTab.Delete;
   l_PktStatusTab.Delete;
   l_PktBcCommTab.Delete;
   l_PktPADateTab.Delete;
   l_PktGLDateTab.Delete;
   l_PktBdgtCCIDTab.Delete;
   l_PktTxnCCIDTab.Delete;
   l_PktParBcPktTab.Delete;
   l_PktBcPktTab.Delete;
   l_PktIdTab.Delete;
   l_PktSrcNameTab.Delete;
   l_PktCatNameTab.Delete;
   l_PktPdYearTab.Delete;
   l_PktPdNumTab.Delete;
   l_PktRlistTab.Delete;
   l_PktBalPostFlagTab.Delete;
   l_PktEncTypIdTab.Delete;
   l_PktPrjEncTypIdTab.Delete;
   l_PktOrgIdTab.Delete;
   l_PktCstBurdFlagTab.Delete;
   l_InsBdgtVerTab.Delete;
   l_InsProjectTab.Delete;
   l_InsTaskTab.Delete;
   l_InsTTaskTab.Delete;
   l_InsDocTypTab.Delete;
   l_InsRlmiTab.Delete;
   l_InsParResTab.Delete;
   l_InsSobTab.Delete;
   l_InsActPTDTab.Delete;
   l_InsEncPTDTab.Delete;
   l_InsBalPostFlagTab.Delete;
   l_InsStatusTab.Delete;
   l_InsTPCTab.Delete;
 --l_InsEiDateTab.Delete;
   l_InsStDateTab.Delete;
   l_InsEdDateTab.Delete;
   l_InsOrgIdTab.Delete;
   l_StsUpdPktIdTab.Delete;
   l_StsUpdBcPktIdTab.Delete;
   --PA.M
   l_PktDocLineIdTab.Delete;
   l_PktCompMultiplierTab.Delete;
   l_PktFcStartDateTab.Delete;
   l_PktFcEndDateTab.Delete;
   l_PktCommTotRawAmtTab.Delete;
   l_PktCommTotBdAmtTab.Delete;
   l_PktCommRawAmtRelievedTab.Delete;
   l_PktCommBdAmtRelievedTab.Delete;
   l_PktSummaryRecordFlagTab.Delete;
   l_PktExpItemIdTab.Delete;
   l_PktReference1Tab.delete;
   l_PktReference2Tab.delete;
   l_PktReference3Tab.delete;
   --R12
   l_PktBcEventIDTab.delete;
   l_PktBudgetLineIDTab.delete;
   l_PktBurdenMethodCodeTab.delete;
   l_PktVendorIdTab.delete;
   l_PktDocHdrId2Tab.delete;
   l_PktDocDistTypeTab.delete;
 EXCEPTION
   WHEN OTHERS THEN
      RAISE;
 END InitPlSqlTabs;

 --Procedure to initialize the pl/sql tables
 PROCEDURE InitPlSqlTabs2 is
 BEGIN
   l_InsBdgtVerTab.Delete;
   l_InsProjectTab.Delete;
   l_InsTaskTab.Delete;
   l_InsTTaskTab.Delete;
   l_InsDocTypTab.Delete;
   l_InsRlmiTab.Delete;
   l_InsParResTab.Delete;
   l_InsSobTab.Delete;
   l_InsActPTDTab.Delete;
   l_InsEncPTDTab.Delete;
   l_InsBalPostFlagTab.Delete;
   l_InsStatusTab.Delete;
   l_InsTPCTab.Delete;
   l_InsStDateTab.Delete;
   l_InsEdDateTab.Delete;
   l_InsOrgIdTab.Delete;
 EXCEPTION
   WHEN OTHERS THEN
      RAISE;
 END InitPlSqlTabs2;
 BEGIN

   --Initialize the error stack
   PA_DEBUG.init_err_stack('PA_SWEEPER.UPDATE_ACT_ENC_BALANCE');

   --Initialize the message table for FND_MSG_PUB
   fnd_msg_pub.initialize;

   fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
   l_debug_mode := NVL(l_debug_mode, 'N');

   pa_debug.set_process('PLSQL','LOG',l_debug_mode);

   --Initialize the return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

IF l_debug_mode = 'Y' THEN   /* added for bug#2672653 */
   pa_debug.g_err_stage := 'Log: Start of Update_Act_Enc_Balance';
   pa_debug.write_file('LOG',pa_debug.g_err_stage);
END IF;

   pa_funds_control_utils.print_message('Entering Sweeper');
IF l_debug_mode = 'Y' THEN   /* added for bug#2672653 */
   pa_fck_util.debug_msg('PB:Entering Sweeper');
END IF;

   --deleting rows older than 'X' days which is set in the profile
   --Pkts with status C should not exist ideally
   --Pkts with status B will be taken care of during rebaselining
   --Pkts with status P are yet to be funds checked, do not delete here.
   pa_funds_control_utils.print_message('Open c_delete_pkts');
   open c_delete_pkts;
   loop
      l_RowIdTab.Delete;
      fetch c_delete_pkts bulk collect into
         l_RowIdTab
      limit rows;

IF l_debug_mode = 'Y' THEN   /* added for bug#2672653 */
      pa_debug.g_err_stage := 'Log: No. of records to delete ' || l_RowIdTab.count;
      pa_debug.write_file('LOG',pa_debug.g_err_stage);
END IF;

      pa_funds_control_utils.print_message('No. of records to delete = ' || l_RowIdTab.count);

      if l_RowIdTab.count = 0 then
       IF l_debug_mode = 'Y' THEN   /* added for bug#2672653 */
         pa_debug.g_err_stage := 'Log: No records in c_delete_pkts, exit';
         pa_debug.write_file('LOG',pa_debug.g_err_stage);
       END IF;
         pa_funds_control_utils.print_message('No records from c_delete_pkts, exit');
         exit;
      end if;

      FORALL i in l_RowIdTab.first..l_RowIdTab.last
         delete from pa_bc_packets
         where  rowid = l_RowIdTab(i);

	/*Code Changes for Bug No.2984871 start */
	 l_rowcount:=sql%rowcount;
	/*Code Changes for Bug No.2984871 end */
      commit;
      exit when c_delete_pkts%notfound;
   end loop;
   close c_delete_pkts;
   pa_funds_control_utils.print_message('Close c_delete_pkts');

IF l_debug_mode = 'Y' THEN   /* added for bug#2672653 */
   /* Bug 2984871: Replaced sql%rwocount with l_rowcount in the below statement */
   pa_debug.g_err_stage := 'Log: Last Deleted ' || to_char(l_rowcount) || ' records from PA_BC_PACKETS older than ' || l_profile_value || ' days';
   pa_debug.write_file('LOG',pa_debug.g_err_stage);
END IF;
   /* Bug 2984871: Replaced sql%rwocount with l_rowcount in the below statement */
   pa_funds_control_utils.print_message('No of Deleted old packets in pa_bc_packets = ' || to_char(l_rowcount));

   --deleting rows older than 'X' days which is set in the profile
   --(batch_id of -999 are those belonging to actuals)
   /*
   The below delete is removed for R12
   delete from gl_bc_packets
   where  je_batch_id = -999
   and    (trunc(sysdate) - trunc(last_update_date)) >= FND_PROFILE.VALUE_SPECIFIC('PA_MAINTAIN_FC_PACKETS');
   */

/*Code Changes for Bug No.2984871 start */
   l_rowcount:=sql%rowcount;
/*Code Changes for Bug No.2984871 end */
IF l_debug_mode = 'Y' THEN   /* added for bug#2672653 */
   /* Bug 2984871: Replaced sql%rwocount with l_rowcount in the below statement */
   pa_debug.g_err_stage := 'Log: Deleted ' || to_char(l_rowcount) || ' records from GL_BC_PACKETS older than ' || l_profile_value || ' days';
   pa_debug.write_file('LOG',pa_debug.g_err_stage);
END IF;
   /* Bug 2984871: Replaced sql%rwocount with l_rowcount in the below statement */
   pa_funds_control_utils.print_message('No of Deleted old packets in gl_bc_packets = '|| to_char(l_rowcount));

IF l_debug_mode = 'Y' THEN   /* added for bug#2672653 */
   pa_debug.g_err_stage := 'Log: Entering Loop';
   pa_debug.write_file('LOG',pa_debug.g_err_stage);
END IF;

   --Loop for distinct project in pa_bc_packets
   FOR eRec in c_pkt_proj LOOP

    l_project_id := eRec.project_id;
    pa_funds_control_utils.print_message('*******************************************************');
    pa_funds_control_utils.print_message('Inside Project loop ' || to_char(l_project_id));

IF l_debug_mode = 'Y' THEN   /* added for bug#2672653 */
    pa_debug.g_err_stage := '*******************************************************';
    pa_debug.write_file('LOG',pa_debug.g_err_stage);

    pa_debug.g_err_stage := 'Log: Inside Loop for Project = ' || to_char(l_project_id);
    pa_debug.write_file('LOG',pa_debug.g_err_stage);
END IF;

    --Acquire lock on project
    IF (pa_debug.acquire_user_lock('SWEEPLOCK:'||to_char(l_project_id)) = 0) THEN

     pa_funds_control_utils.print_message('Acquired Lock on project '||to_char(l_project_id));

IF l_debug_mode = 'Y' THEN   /* added for bug#2672653 */
     pa_debug.g_err_stage := 'Log: Lock Acquired for Project = ' || to_char(l_project_id) ;
     pa_debug.write_file('LOG',pa_debug.g_err_stage);
END IF;

     pa_funds_control_utils.print_message('Open cursor c_bc_packets');
     --Open c_bc_packets cursor
     open c_bc_packets(l_project_id);

     l_count := 0;

     --Start loop
     LOOP
        l_count := l_count+1;

        --Initialize the counter for maintaining updated balance records
        num := 0;

        --Call procedure to initialize the tables
        InitPlSqlTabs;

     IF l_debug_mode = 'Y' THEN   /* added for bug#2672653 */
        pa_debug.g_err_stage := 'Log: Fetched ' || l_count || ' batch';
        pa_debug.write_file('LOG',pa_debug.g_err_stage);
     END IF;

        pa_funds_control_utils.print_message('No of cursor batch fetched = ' || l_count);

     IF l_debug_mode = 'Y' THEN   /* added for bug#2672653 */
        pa_debug.g_err_stage := 'Log: Fetch cursor c_bc_packets';
        pa_debug.write_file('LOG',pa_debug.g_err_stage);
     END IF;


        pa_funds_control_utils.print_message('Fetch cursor c_bc_packets');

        --Fetch cursor c_bc_packets limiting rows
        FETCH c_bc_packets BULK COLLECT INTO
	      l_PktBdgtVerTab,
	      l_PktProjectTab,
	      l_PktTaskTab   ,
	      l_PktBdgtTaskTab,
	      l_PktTTaskTab   ,
	      l_PktDocTypTab  ,
	      l_PktPeriodTab  ,
	      l_PktRlmiTab    ,
	      l_PktParResTab  ,
	      l_PktSobTab     ,
	      l_PktEiDateTab  ,
	      l_PktAcctDrTab  ,
	      l_PktAcctCrTab  ,
 	      l_PktActFlagTab ,
              l_PktRlistTab   ,
	      l_PktTPCTab     ,
	      l_PktDocHeadTab ,
	      l_PktDocDistTab ,
	      l_PktBcCommTab  ,
	      l_PktIdTab      ,
	      l_PktExpTypTab  ,
	      l_PktPADateTab  ,
	      l_PktGLDateTab  ,
	      l_PktPdYearTab  ,
	      l_PktPdNumTab   ,
	      l_PktCatNameTab ,
	      l_PktSrcNameTab ,
   	      l_PktExpOrgTab   ,
	      l_PktEntDrTab   ,
	      l_PktEntCrTab   ,
	      l_PktBdgtCCIDTab,
	      l_PktTxnCCIDTab ,
	      l_PktBcPktTab   ,
	      l_PktParBcPktTab,
              l_PktBdgtRlmiTab,
 	      l_PktBalPostFlagTab,
              l_PktEncTypIdTab,
              l_PktPrjEncTypIdTab,
              l_PktStatusTab,
              l_PktOrgIdTab,
              l_PktCstBurdFlagTab
              --PA.M
              ,l_PktDocLineIdTab
              ,l_PktCompMultiplierTab
              ,l_PktFcStartDateTab
              ,l_PktFcEndDateTab
              ,l_PktCommTotRawAmtTab
              ,l_PktCommTotBdAmtTab
              ,l_PktCommRawAmtRelievedTab
              ,l_PktCommBdAmtRelievedTab
              ,l_PktSummaryRecordFlagTab
              ,l_PktExpItemIdTab
	      ,l_PktReference1Tab
	      ,l_PktReference2Tab
	      ,l_PktReference3Tab
              --R12
              ,l_PktBcEventIDTab
              ,l_PktVendorIdTab
              ,l_PktBudgetLineIDTab
              ,l_PktBurdenMethodCodeTab
              ,l_PktDocHdrId2Tab
              ,l_PktDocDistTypeTab
        LIMIT rows;

      IF l_debug_mode = 'Y' THEN   /* added for bug#2672653 */
        pa_debug.g_err_stage := 'Log: No. of records fetched ' || l_PktIdTab.count;
        pa_debug.write_file('LOG',pa_debug.g_err_stage);
      END IF;

        pa_funds_control_utils.print_message('No. of records fetched = ' || l_PktIdTab.count);

        --If no rows fetched, exit
        IF l_PktIdTab.count = 0 THEN
           IF l_debug_mode = 'Y' THEN   /* added for bug#2672653 */
              pa_debug.g_err_stage := 'Log: No records in c_bc_packets, exit';
              pa_debug.write_file('LOG',pa_debug.g_err_stage);
           END IF;
              pa_funds_control_utils.print_message('No records from c_bc_packets, exit');
              EXIT;
        END IF;

        pa_funds_control_utils.print_message('In c_bc_packets loop');

      IF l_debug_mode = 'Y' THEN   /* added for bug#2672653 */
        pa_debug.g_err_stage := 'Log: Before update of balances';
        pa_debug.write_file('LOG',pa_debug.g_err_stage);
      END IF;

        pa_funds_control_utils.print_message('Before update of balances');

        --Update the balances if the record exists in pa_bc_balances
       	FORALL i in l_PktIdTab.FIRST..l_PktIdTab.LAST
          UPDATE  pa_bc_balances pb
    	  SET     pb.last_update_date = sysdate,
                  pb.last_update_login = fnd_global.login_id,
                  pb.last_updated_by  = fnd_global.user_id,
                  pb.request_id = fnd_global.conc_request_id,
                  pb.program_id = fnd_global.conc_program_id,
                  pb.program_application_id = fnd_global.prog_appl_id,
                  pb.program_update_date = sysdate,
                  pb.actual_period_to_date = nvl(pb.actual_period_to_date,0) +
    	    	   (nvl(l_PktAcctDrTab(i),0)- nvl(l_PktAcctCrTab(i),0))  *
                   decode(l_PktDocTypTab(i),'EXP',1,0),
	          pb.encumb_period_to_date = nvl(pb.encumb_period_to_date,0) +
   	    	   ((nvl(l_PktAcctDrTab(i),0)- nvl(l_PktAcctCrTab(i),0))  *
                   decode(l_PktDocTypTab(i),'REQ',1,'PO',1,'AP',1,'CC_P_CO',1,'CC_C_CO',1,'CC_P_PAY',1,'CC_C_PAY',1,0))
       	  WHERE   pb.project_id = l_PktProjectTab(i)
          AND     pb.task_id   = l_PktTaskTab(i)
    	  AND     pb.resource_list_member_id = l_PktRlmiTab(i)
       	  AND     pb.set_of_books_id = l_PktSobTab(i)
    	  AND     pb.budget_version_id = l_PktBdgtVerTab(i)
	  AND     pb.balance_type = l_PktDocTypTab(i)
    	  AND     ((l_PktTPCTab(i) = 'N' and
                   trunc(l_PktEiDateTab(i)) between trunc(pb.start_date) and trunc(pb.end_date))
                  OR (l_PktTPCTab(i) = 'P' and
                   trunc(l_PktPaDateTab(i)) between trunc(pb.start_date) and trunc(pb.end_date))
                  OR (l_PktTPCTab(i) = 'G' and
                   trunc(l_PktGlDateTab(i)) between trunc(pb.start_date) and trunc(pb.end_date)));

        --Collect no of records updated and store the packet id in another table
        for i in l_PktIdTab.FIRST..l_PktIdTab.LAST loop
          IF l_debug_mode = 'Y' THEN   /* added for bug#2672653 */
           pa_debug.g_err_stage := 'Log: Updating Balances , Index = '|| i || ' RowCount = ' || SQL%BULK_ROWCOUNT(i) ||' Pkt Id ' || l_PktBcPktTab(i);
           pa_debug.write_file('LOG',pa_debug.g_err_stage);
          END IF;
           pa_funds_control_utils.print_message('Updating Balances ' || SQL%BULK_ROWCOUNT(i) ||' Pkt Id ' || l_PktBcPktTab(i));

           --If no. of rec updated not = 0 then place packet id in another table.
           --This is to ensure that we update the status of these packets only
           if (SQL%BULK_ROWCOUNT(i) <> 0) then
              num := num + 1;
              l_StsUpdPktIdTab(num) := l_PktIdTab(i);
              l_StsUpdBcPktIdTab(num) := l_PktBcPktTab(i);
            IF l_debug_mode = 'Y' THEN   /* added for bug#2672653 */
              pa_debug.g_err_stage := 'Log: Num = ' || num || ' Status Pkt Id = ' || l_StsUpdPktIdTab(num) || ' Bc Pkt = ' || l_StsUpdBcPktIdTab(num);
              pa_debug.write_file('LOG',pa_debug.g_err_stage);
            END IF;
              pa_funds_control_utils.print_message('Status Packet Id = ' || l_StsUpdPktIdTab(num)|| ' Bc Pkt = ' || l_StsUpdBcPktIdTab(num));
           end if;
        end loop;

      IF l_debug_mode = 'Y' THEN   /* added for bug#2672653 */
        pa_debug.g_err_stage := 'Log: Updated Records = ' || l_StsUpdPktIdTab.count;
        pa_debug.write_file('LOG',pa_debug.g_err_stage);
      END IF;

        --The below loop is only for debugging. Can be removed, if log file is huge.
        if l_StsUpdPktIdTab.count<>0 then
          for i in l_StsUpdPktIdTab.FIRST..l_StsUpdPktIdTab.LAST loop
           IF l_debug_mode = 'Y' THEN   /* added for bug#2672653 */
            pa_debug.g_err_stage := 'Log: No of Status updates = ' || l_StsUpdPktIdTab(i)|| ' Bc Pkt = ' || l_StsUpdBcPktIdTab(i);
            pa_debug.write_file('LOG',pa_debug.g_err_stage);
           END IF;
            pa_funds_control_utils.print_message('No of Status updates = ' || l_StsUpdPktIdTab(i)|| ' Bc Pkt = ' || l_StsUpdBcPktIdTab(i));
          end loop;
        end if;

       IF l_debug_mode = 'Y' THEN   /* added for bug#2672653 */
        pa_debug.g_err_stage := 'Log: After Update of balances';
        pa_debug.write_file('LOG',pa_debug.g_err_stage);

        pa_debug.g_err_stage := 'Log: Before Insert into commitments';
        pa_debug.write_file('LOG',pa_debug.g_err_stage);
       END IF;

        pa_funds_control_utils.print_message('Inserting Commitments');

        --Insert into pa_bc_commitments_all if bc_commitment_id is null in pa_bc_packets
        FORALL k in l_PktIdTab.FIRST..l_PktIdTab.LAST
          insert into pa_bc_commitments_all(
                bc_commitment_id,
                packet_id,
                project_id,
                task_id,
                expenditure_type,
                expenditure_item_date,
                pa_date,
                gl_date,
                period_name,
                period_year,
                period_num,
                je_category_name,
                je_source_name,
                document_type,
                expenditure_organization_id,
                document_header_id,
                document_distribution_id,
                top_task_id,
                parent_resource_id,
                budget_version_id,
                resource_list_member_id,
                accounted_dr,
                accounted_cr,
                entered_dr,
                entered_cr,
                budget_ccid,
                txn_ccid,
                bc_packet_id,
                parent_bc_packet_id,
                set_of_books_id,
                bud_resource_list_member_id,
                bud_task_id,
                actual_flag,
                encumbrance_type_id,
                proj_encumbrance_type_id,
                org_id,
                burden_cost_flag,
                last_update_date,
                last_updated_by,
                created_by,
                creation_date,
                last_update_login,
                transfer_status_code,
                request_id,
                program_id,
                program_application_id,
                program_update_date
                --PA.M
                ,Document_Line_Id
                ,Compiled_Multiplier
                ,Fc_Start_Date
                ,Fc_End_Date
                ,Comm_Tot_Raw_Amt
                ,Comm_Tot_Bd_Amt
                ,Comm_Raw_Amt_Relieved
                ,Comm_Bd_Amt_Relieved
                ,Summary_Record_Flag
                ,Exp_Item_Id
		,reference1
		,reference2
		,reference3
                --R12
                ,bc_event_id
                ,budget_line_id
                ,burden_method_code
                ,vendor_id
                ,document_header_id_2
                ,document_distribution_type)
          select
                pa_bc_commitments_s.nextval,
                l_PktIdTab(k),
                l_PktProjectTab(k),
                l_PktTaskTab(k),
                l_PktExpTypTab(k),
                l_PktEiDateTab(k),
                l_PktPaDateTab(k),
                l_PktGlDateTab(k),
                l_PktPeriodTab(k),
                l_PktPdYearTab(k),
                l_PktPdNumTab(k),
                l_PktCatNameTab(k),
                l_PktSrcNameTab(k),
                l_PktDocTypTab(k),
                l_PktExpOrgTab(k),
                l_PktDocHeadTab(k),
                l_PktDocDistTab(k),
                l_PktTTaskTab(k),
                l_PktParResTab(k),
                l_PktBdgtVerTab(k),
                l_PktRlmiTab(k),
                l_PktAcctDrTab(k),
                l_PktAcctCrTab(k),
                l_PktEntDrTab(k),
                l_PktEntCrTab(k),
                l_PktBdgtCCIDTab(k),
                l_PktTxnCCIDTab(k),
                l_PktBcPktTab(k),
                l_PktParBCPktTab(k),
                l_PktSobTab(k),
                l_PktBdgtRlmiTab(k),
                l_PktBdgtTaskTab(k),
                l_PktActFlagTab(k),
                l_PktEncTypIdTab(k),
                l_PktPrjEncTypIdTab(k),
                l_PktOrgIdTab(k),
                l_PktCstBurdFlagTab(k),
                sysdate,
                FND_GLOBAL.USER_ID,
                FND_GLOBAL.USER_ID,
                sysdate,
                FND_GLOBAL.LOGIN_ID,
                'P',
                fnd_global.conc_request_id,
                fnd_global.conc_program_id,
                fnd_global.prog_appl_id,
                sysdate
                --PA.M
                ,l_PktDocLineIdTab(k)
                ,l_PktCompMultiplierTab(k)
                ,l_PktFcStartDateTab(k)
                ,l_PktFcEndDateTab(k)
                ,l_PktCommTotRawAmtTab(k)
                ,l_PktCommTotBdAmtTab(k)
                ,l_PktCommRawAmtRelievedTab(k)
                ,l_PktCommBdAmtRelievedTab(k)
                ,l_PktSummaryRecordFlagTab(k)
                ,l_PktExpItemIdTab(k)
		,l_PktReference1Tab(k)
		,l_PktReference2Tab(k)
		,l_PktReference3Tab(k)
                --R12
                ,l_PktBcEventIDTab(k)
                ,l_PktBudgetLineIdTab(k)
                ,l_PktBurdenMethodCodeTab(k)
                ,l_PktVendorIdTab(k)
                ,l_PktDocHdrId2Tab(k)
                ,l_PktDocDistTypeTab(k)
          from dual
          where l_PktBcCommTab(k) is null
          and   l_PktRlmiTab(k) is not null
          and   l_PktBdgtVerTab(k) is not null
          and   l_PktDocTypTab(k) in ('AP', 'PO', 'REQ', 'CC_P_CO', 'CC_C_CO', 'CC_P_PAY', 'CC_C_PAY')
          and   not exists (select 'X'
                            from pa_bc_commitments_all
                            where document_type = l_PktDocTypTab(k)
                            and l_PktDocTypTab(k) in ('AP', 'PO', 'REQ', 'CC_P_CO', 'CC_C_CO', 'CC_P_PAY', 'CC_C_PAY')
                            and document_header_id = l_PktDocHeadTab(k)
                            and (document_distribution_id = l_PktDocDistTab(k)
                                or (document_distribution_id = -9999
                                    and
                                    document_line_id = l_PktDocLineIdTab(k))
                                )
                            and bc_packet_id = l_PktBcPktTab(k));

        --The below loop is only for debugging. Can be removed, if log file is huge.
        for i in l_PktIdTab.first..l_PktIdTab.last loop
          IF l_debug_mode = 'Y' THEN   /* added for bug#2672653 */
            pa_debug.g_err_stage := 'Log: No of commitment inserts = ' || SQL%BULK_ROWCOUNT(i)||' Pkt Id ' || l_PktBcPktTab(i);
            pa_debug.write_file('LOG',pa_debug.g_err_stage);
          END IF;
            pa_funds_control_utils.print_message('No. of commitment insert = ' || SQL%BULK_ROWCOUNT(i)||' Pkt Id ' || l_PktBcPktTab(i));
        end loop;

       IF l_debug_mode = 'Y' THEN   /* added for bug#2672653 */
        pa_debug.g_err_stage := 'Log: After Insert into commitments';
        pa_debug.write_file('LOG',pa_debug.g_err_stage);

        pa_debug.g_err_stage := 'Log: Before Update of commitments';
        pa_debug.write_file('LOG',pa_debug.g_err_stage);
       END IF;

        pa_funds_control_utils.print_message('Before update of pa_bc_commitments_all');

        --Update pa_bc_commitments_all if bc_commitment_id is not null
        FORALL j in l_PktIdTab.FIRST..l_PktIdTab.LAST
          UPDATE  pa_bc_commitments_all pbc
          SET   pbc.packet_id               = l_PktIdTab(j),
                pbc.top_task_id             = l_PktTTaskTab(j),
                pbc.parent_resource_id      = l_PktParResTab(j),
                pbc.budget_version_id       = l_PktBdgtVerTab(j),
                pbc.resource_list_member_id = l_PktRlmiTab(j),
                pbc.entered_dr              = l_PktEntDrTab(j),
                pbc.entered_cr              = l_PktEntCrTab(j),
                pbc.accounted_dr            = l_PktAcctDrTab(j),
                pbc.accounted_cr            = l_PktAcctCrTab(j),
                pbc.budget_ccid             = l_PktBdgtCCIDTab(j),
                pbc.txn_ccid                = l_PktTxnCCIDTab(j),
              --pbc.bc_packet_id            = l_PktBCPktTab(j),
              --pbc.parent_bc_packet_id     = l_PktParBCPktTab(j),
                pbc.set_of_books_id         = l_PktSobTab(j),
                pbc.bud_resource_list_member_id = l_PktBdgtRlmiTab(j),
                pbc.bud_task_id              = l_PktBdgtTaskTab(j),
                pbc.actual_flag              = l_PktActFlagTab(j),
                pbc.encumbrance_type_id      = l_PktEncTypIdTab(j),
                pbc.proj_encumbrance_type_id = l_PktPrjEncTypIdTab(j),
                pbc.last_updated_by          = fnd_global.user_id,
                pbc.last_update_date         = sysdate,
                pbc.last_update_login        = fnd_global.login_id,
                pbc.request_id = fnd_global.conc_request_id,
                pbc.program_id = fnd_global.conc_program_id,
                pbc.program_application_id = fnd_global.prog_appl_id,
                pbc.program_update_date    = sysdate,
                pbc.budget_line_id         = l_PktBudgetLineIdTab(j)
          where ((pbc.bc_commitment_id         = l_PktBcCommTab(j))
                or (l_PktBcCommTab(j) is null
                    --Bug 2779986: This exist clause will be true for reversing commitment txns
                    --that came when baseline is in progress (what we call delta txns) for the project.
                    --We have to update only that record which satisfies the document id combination
                    --and bc_packet_id and not all the records. Hence added the extra conditions.
                    and pbc.document_header_id = l_PktDocHeadTab(j)
                    and (pbc.document_distribution_id = l_PktDocDistTab(j)
                         or (pbc.document_distribution_id = -9999
                             and
                             pbc.document_line_id = l_PktDocLineIdTab(j))
                        )
                    and pbc.bc_packet_id = l_PktBcPktTab(j)
                    and exists (select 'X'
                            from pa_bc_commitments_all pbc1
                            where pbc1.project_id = l_PktProjectTab(j)
                            and pbc1.task_id = l_PktTaskTab(j)
                            and pbc1.document_type = l_PktDocTypTab(j)
                            and l_PktDocTypTab(j) in ('AP', 'PO', 'REQ', 'CC_P_CO', 'CC_C_CO', 'CC_P_PAY', 'CC_C_PAY')
                            and pbc1.document_header_id = l_PktDocHeadTab(j)
                            and (pbc1.document_distribution_id = l_PktDocDistTab(j)
                                 or (pbc1.document_distribution_id = -9999
                                     and
                                     pbc1.document_line_id = l_PktDocLineIdTab(j))
                                )
                            and pbc1.bc_packet_id = l_PktBcPktTab(j)
                            and pbc1.budget_version_id < l_PktBdgtVerTab(j))))
          and   pbc.project_id = l_PktProjectTab(j)
          and   l_PktRlmiTab(j) is not null
          and   l_PktBdgtVerTab(j) is not null
          and   l_PktDocTypTab(j) in ('AP', 'PO', 'REQ', 'CC_P_CO', 'CC_C_CO', 'CC_P_PAY', 'CC_C_PAY');

        --The below loop is only for debugging. Can be removed, if log file is huge.
        for i in l_PktIdTab.first..l_PktIdTab.last loop
           IF l_debug_mode = 'Y' THEN   /* added for bug#2672653 */
            pa_debug.g_err_stage := 'Log: No of commitment updates = ' || SQL%BULK_ROWCOUNT(i)||' Pkt Id ' || l_PktBcPktTab(i);
            pa_debug.write_file('LOG',pa_debug.g_err_stage);
           END IF;
            pa_funds_control_utils.print_message('No. of commitment updates = ' || SQL%BULK_ROWCOUNT(i)||' Pkt Id ' || l_PktBcPktTab(i));
        end loop;

       IF l_debug_mode = 'Y' THEN   /* added for bug#2672653 */
        pa_debug.g_err_stage := 'Log: After Update of commitments';
        pa_debug.write_file('LOG',pa_debug.g_err_stage);

	pa_debug.g_err_stage := 'Log: Before update status_code, balance_posted_flag in c_bc_packets loop '||l_StsUpdPktIdTab.count;
        pa_debug.write_file('LOG',pa_debug.g_err_stage);
       END IF;

        pa_funds_control_utils.print_message('Before update of status_code');
        pa_funds_control_utils.print_message('No. of status updates in c_bc_packets= '||l_StsUpdPktIdTab.count);

        --Update status_code and balance_posted_flag
        IF (l_StsUpdPktIdTab.count <> 0) THEN
         IF l_debug_mode = 'Y' THEN   /* added for bug#2672653 */
          pa_debug.write_file('LOG', 'Pkt FIRST = ' || l_StsUpdPktIdTab.FIRST || ' LAST = '|| l_StsUpdPktIdTab.LAST );
          pa_debug.write_file('LOG', 'Bc Pkt FIRST = ' || l_StsUpdBcPktIdTab.FIRST || ' LAST = '|| l_StsUpdBcPktIdTab.LAST );
         END IF;
          FORALL m in l_StsUpdPktIdTab.FIRST..l_StsUpdPktIdTab.LAST
            UPDATE  pa_bc_packets pbc
            SET     pbc.status_code         = 'X',
                    pbc.balance_posted_flag = 'Y',
                    pbc.last_update_date    = sysdate,
                    pbc.last_update_login   = fnd_global.login_id,
                    pbc.last_updated_by     = fnd_global.user_id
            WHERE   pbc.status_code = 'A'
            AND     pbc.packet_id   = l_StsUpdPktIdTab(m)
            AND     pbc.bc_packet_id = l_StsUpdBcPktIdTab(m)
            AND     pbc.balance_posted_flag = 'N'
            AND     l_PktStatusTab(m)       = 'A'
            AND     l_PktBalPostFlagTab(m)  = 'N';
        END IF;

        --The below loop is for debugging, can be removed if log file is huge
        if (l_StsUpdPktIdTab.count <> 0) then
          for i in l_StsUpdPktIdTab.FIRST..l_StsUpdPktIdTab.LAST loop
           IF l_debug_mode = 'Y' THEN   /* added for bug#2672653 */
            pa_debug.g_err_stage := 'Log: No of status update ' || SQL%BULK_ROWCOUNT(i)||' Pkt Id ' || l_PktBcPktTab(i);
            pa_debug.write_file('LOG',pa_debug.g_err_stage);
           END IF;
            pa_funds_control_utils.print_message('No of status update ' || SQL%BULK_ROWCOUNT(i)||' Pkt Id ' || l_PktBcPktTab(i));
          end loop;
        end if;

       IF l_debug_mode = 'Y' THEN   /* added for bug#2672653 */
        pa_debug.g_err_stage := 'Log: After Update of status_code and balance_posted_flag in c_bc_packets loop';
        pa_debug.write_file('LOG',pa_debug.g_err_stage);
       END IF;

        --Commit in a batch i.e. 200 rows
        commit;
        pa_funds_control_utils.print_message('End loop');

        EXIT WHEN c_bc_packets%NOTFOUND;
     END LOOP;

     pa_funds_control_utils.print_message('Close c_bc_packets');

     CLOSE c_bc_packets;
    IF l_debug_mode = 'Y' THEN   /* added for bug#2672653 */
     pa_debug.g_err_stage := 'Log: Open cursor c_ins_packets';
     pa_debug.write_file('LOG',pa_debug.g_err_stage);
    END IF;

     pa_funds_control_utils.print_message('Open cursor c_ins_packets');

     l_count := 0;

     --Open cursor c_ins_packets
     OPEN c_ins_packets(l_project_id);
     LOOP

      --Initialize PL/SQL tables
      InitPlSqlTabs2;

      l_count := l_count+1;

     IF l_debug_mode = 'Y' THEN   /* added for bug#2672653 */
      pa_debug.g_err_stage := 'Log: Fetched ' || l_count || ' batch';
      pa_debug.write_file('LOG',pa_debug.g_err_stage);
     END IF;

      pa_funds_control_utils.print_message('No of cursor batch fetched = ' || l_count);

     IF l_debug_mode = 'Y' THEN   /* added for bug#2672653 */
      pa_debug.g_err_stage := 'Log: Fetch cursor c_ins_packets';
      pa_debug.write_file('LOG',pa_debug.g_err_stage);
     END IF;

      pa_funds_control_utils.print_message('Fetch cursor c_ins_packets');

      --Fetch records from cursor in batch
      FETCH c_ins_packets bulk collect into
        l_InsBdgtVerTab,
        l_InsProjectTab,
        l_InsTaskTab,
        l_InsTTaskTab,
        l_InsDocTypTab,
        l_InsRlmiTab,
        l_InsParResTab,
        l_InsSobTab,
        l_InsActPTDTab,
        l_InsEncPTDTab,
        l_InsBalPostFlagTab,
        l_InsStatusTab,
        l_InsTPCTab,
        --l_InsEiDateTab,
        l_InsStDateTab,
        l_InsEdDateTab
        /*Bug 3007393*/
        /*,l_InsOrgIdTab*/
      LIMIT rows;

     IF l_debug_mode = 'Y' THEN   /* added for bug#2672653 */
      pa_debug.g_err_stage := 'Log: No. of records fetched = '||l_InsProjectTab.count;
      pa_debug.write_file('LOG',pa_debug.g_err_stage);
     END IF;

      pa_funds_control_utils.print_message('No. of records fetched = ' || l_InsProjectTab.count);

      --If no. of records fetched = 0 then exit
      IF l_InsProjectTab.count = 0 THEN
       IF l_debug_mode = 'Y' THEN   /* added for bug#2672653 */
        pa_debug.g_err_stage := 'Log: No records from cursor c_ins_packets, exit';
        pa_debug.write_file('LOG',pa_debug.g_err_stage);
       END IF;
        pa_funds_control_utils.print_message('No records from cursor c_ins_packets, exit');
        EXIT;
      END IF;

     IF l_debug_mode = 'Y' THEN   /* added for bug#2672653 */
      pa_debug.g_err_stage := 'Log: Before inserting balances';
      pa_debug.write_file('LOG',pa_debug.g_err_stage);
     END IF;

      pa_funds_control_utils.print_message('Before inserting into pa_bc_balances');

      --Insert into pa_bc_balances
      FORALL p in l_InsProjectTab.FIRST..l_InsProjectTab.LAST
        insert into pa_bc_balances(project_id
          ,task_id
          ,top_task_id
          ,resource_list_member_id
          ,set_of_books_id
          ,budget_version_id
          ,balance_type
          ,last_update_date
          ,last_updated_by
          ,created_by
          ,creation_date
          ,last_update_login
          ,start_date
          ,end_date
          ,parent_member_id
          ,budget_period_to_date
          ,actual_period_to_date
          ,encumb_period_to_date
          ,request_id
          ,program_id
          ,program_application_id
          ,program_update_date)
        select
          l_InsProjectTab(p),
          l_InsTaskTab(p),
          l_InsTTaskTab(p),
          l_InsRlmiTab(p),
          l_InsSobTab(p),
          l_InsBdgtVerTab(p),
          l_InsDocTypTab(p),
          sysdate,
          FND_GLOBAL.USER_ID,
          FND_GLOBAL.USER_ID,
          sysdate,
          FND_GLOBAL.LOGIN_ID,
          --GetBCBalStartDate(l_InsTPCTab(p),l_InsProjectTab(p),l_InsEiDateTab(p),
          --                 l_InsBdgtVerTab(p),l_InsSobTab(p),l_InsOrgIdTab(p)),
          --GetBCBalEndDate(l_InsTPCTab(p),l_InsProjectTab(p),l_InsEiDateTab(p),
          --                l_InsBdgtVerTab(p),l_InsSobTab(p),l_InsOrgIdTab(p)),
          l_InsStDateTab(p),
          l_InsEdDateTab(p),
          l_InsParResTab(p),
          0,
          l_InsActPTDTab(p),
          l_InsEncPTDTab(p),
          fnd_global.conc_request_id,
          fnd_global.conc_program_id,
          fnd_global.prog_appl_id,
          sysdate
        from dual where l_InsDocTypTab(p) in ('EXP', 'AP','PO','REQ','CC_C_CO','CC_P_CO','CC_C_PAY','CC_P_PAY');

       IF l_debug_mode = 'Y' THEN   /* added for bug#2672653 */
        pa_debug.g_err_stage := 'Log: After inserting balances';
        pa_debug.write_file('LOG',pa_debug.g_err_stage);

	pa_debug.g_err_stage := 'Log: Before update status_code and balance_posted_flag in c_ins_packets';
        pa_debug.write_file('LOG',pa_debug.g_err_stage);
       END IF;

        pa_funds_control_utils.print_message('Update status_code and balance_posted_flag');

        --Update status_code and balance_posted_flag in pa_bc_packets
        FORALL m in l_InsProjectTab.FIRST..l_InsProjectTab.LAST
          UPDATE  pa_bc_packets pbc
          SET     pbc.status_code         = 'X',
                  pbc.balance_posted_flag = 'Y',
                  pbc.last_update_date    = sysdate,
                  pbc.last_update_login   = fnd_global.login_id,
                  pbc.last_updated_by     = fnd_global.user_id
          WHERE   pbc.status_code = 'A'
          AND     pbc.project_id = l_InsProjectTab(m)
          AND     pbc.task_id = l_InsTaskTab(m)
          AND     pbc.balance_posted_flag = 'N'
          AND     l_InsStatusTab(m) = 'A'
          AND     l_InsBalPostFlagTab(m) = 'N';

        --Below loop for debugging, can be removed if log file is huge
        for i in l_InsProjectTab.first..l_InsProjectTab.last loop
          IF l_debug_mode = 'Y' THEN   /* added for bug#2672653 */
           pa_debug.g_err_stage := 'Log: No. of status update in c_ins_packets = ' || SQL%BULK_ROWCOUNT(i);
           pa_debug.write_file('LOG',pa_debug.g_err_stage);
          END IF;
           pa_funds_control_utils.print_message('No. of status update in c_ins_packets = ' || SQL%BULK_ROWCOUNT(i));
        end loop;

       IF l_debug_mode = 'Y' THEN   /* added for bug#2672653 */
        pa_debug.g_err_stage := 'Log: After Update of status_code and balance_posted_flag in c_ins_packets loop';
        pa_debug.write_file('LOG',pa_debug.g_err_stage);
       END IF;

      --Commit in a batch, i.e. 200 rows
      commit;
      EXIT WHEN c_ins_packets%NOTFOUND;

     END LOOP;

     --Close c_ins_packets cursor
     CLOSE c_ins_packets;

     --Release lock on project
     IF (pa_debug.release_user_lock('SWEEPLOCK:'||to_char(l_project_id)) = 0) THEN
          pa_funds_control_utils.print_message('Releasing lock for '|| l_project_id);
         IF l_debug_mode = 'Y' THEN   /* added for bug#2672653 */
          pa_debug.g_err_stage := 'Log: Finished processing,  release lock on Project = ' || to_char(l_project_id);
          pa_debug.write_file('LOG',pa_debug.g_err_stage);
         END IF;
          null;
     END IF;

    ELSE
     --Unable to acquire user lock
    IF l_debug_mode = 'Y' THEN   /* added for bug#2672653 */
     pa_debug.g_err_stage := 'Log: Could not acquire lock for Project = '||to_char(l_project_id);
     pa_debug.write_file('LOG',pa_debug.g_err_stage);
    END IF;
    END IF;

   END LOOP;

  IF l_debug_mode = 'Y' THEN   /* added for bug#2672653 */
   pa_debug.g_err_stage := '*******************************************************';
   pa_debug.write_file('LOG',pa_debug.g_err_stage);

   pa_debug.g_err_stage := 'Log: End of Update_Act_Enc_Balance';
   pa_debug.write_file('LOG',pa_debug.g_err_stage);
  END IF;

   pa_fck_util.debug_msg('PB:Exiting Sweeper');

   --Reset the error stack when returning to the calling program
   PA_DEBUG.Reset_Err_Stack;

 EXCEPTION
   WHEN OTHERS THEN
      --Since release_user_lock always issues a commit, do a
      --rollback before calling release_user_lock.
      rollback;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_SWEEPER'
                   ,p_procedure_name => PA_DEBUG.G_Err_Stack );

      x_error_message_code := (SQLCODE||' '||SQLERRM);

      IF (pa_debug.release_user_lock('SWEEPLOCK:'||to_char(l_project_id)) = 0) THEN
          pa_funds_control_utils.print_message('In others Releasing lock for proj '|| l_project_id);
          null;
      END IF;

      IF c_bc_packets%isopen THEN
          close c_bc_packets;
      END IF;
      IF c_ins_packets%isopen THEN
          close c_ins_packets;
      END IF;
      IF c_delete_pkts%isopen THEN
          close c_delete_pkts;
      END IF;

      raise;
 END update_act_enc_balance;

END PA_SWEEPER;

/
