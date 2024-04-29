--------------------------------------------------------
--  DDL for Package Body PA_BGT_BASELINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BGT_BASELINE_PKG" AS
-- $Header: PAFCBALB.pls 120.10.12010000.2 2009/05/22 20:11:57 djanaswa ship $
P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

PROCEDURE MAINTAIN_BAL_FCHK(
		p_project_id         IN  number,
                p_budget_version_id  IN  number,
		p_baselined_budget_version_id IN NUMBER, --R12 Funds Management Uptake :Parameter to store newly baselined version ID
                p_bdgt_ctrl_type     IN  varchar2,  --GL, CC
                p_calling_mode       IN  varchar2,  --CHECK_BASELINE, RESERVE_BASELINE
		p_bdgt_intg_flag     IN  varchar2,  --Y, N
                x_return_status      OUT NOCOPY varchar2 ,
                x_error_message_code OUT NOCOPY varchar2) IS

 PRAGMA AUTONOMOUS_TRANSACTION;

 l_sob_id			number;
 l_packet_id			number;
 l_return_status                varchar2(1);

 x_error_stage                  VARCHAR2(100);
 x_error_msg                    VARCHAR2(1000);
 l_org_id                       number; --Bug 6524116
 rows                           NATURAL := 200;
 --R12 Funds Management Uptake : deleted obsolete variables

 resource_busy                  exception;
 pragma exception_init(resource_busy,-00054);

 ACQUIRE_LOCK_EXCEPTION         exception;

 --Cursor to lock pa_bc_balances table for the project_id that is being baselined.
 cursor c_bal_lock is
 select end_date from pa_bc_balances
 where project_id = p_project_id
 for update nowait;

 --When baselining errors with oracle error, insufficient funds and if user rebaselines
 --then we have to delete from pa_bc_packets all the transactions that were created
 --during the first baseline. The cursor below is for this purpose
 -- R12 Funds Management Uptake : Obsolete logic with new architecture

 --Cursor to update status code from C to A for packets that have been funds checked
 --before the budget baselining notification was approved
 -- R12 Funds Management Uptake : Obsolete cursor c_updsts with new architecture

 ---------------------------------------------------------------------------------------------
 -- procedure to create pa_bc_balances records from PA_BUDGET_LINES and to clean up PA_BC_PACKETS
/* ========================================================================================== +
  FOLLOWING CODE MOVED TO PA_BUDGET_FUND_PKG (PABBFNDB.pls)

 PROCEDURE INSERT_BGT_BALANCES(
                p_project_id         in number,
                p_budget_version_id  in number,
                p_set_of_books_id    in number,
                p_bdgt_intg_flag     in varchar2,
                --p_fc_reqd            in varchar2, --R12 Funds Management Uptake
                x_return_status      out NOCOPY varchar2,
                x_error_message_code out NOCOPY varchar2) is

 l_start_date  date;
 l_end_date    date;
 l_tab_count   number := 0;
 l_tab_periods PA_FUNDS_CONTROL_UTILS.tab_closed_period;

 l_base_version_id number;
 l_res_list_id     number;
 l_entry_level_code varchar2(1);

 --Cursor to select BGT budget balances from pa_budget_lines,etc.
 cursor c_bdgt_bal is
 select pa.project_id,
        pa.task_id,
        pt.top_task_id,
        pa.resource_list_member_id,
        pbv.budget_version_id,
        pb.PERIOD_NAME,
        pb.START_DATE,
        pb.END_DATE,
        rm.PARENT_MEMBER_ID,
        pb.burdened_cost
 from
        pa_budget_lines pb,
        pa_resource_assignments pa,
        pa_tasks pt,
        pa_resource_list_members rm,
        pa_budget_versions pbv
 where pbv.budget_version_id = p_budget_version_id
 and   pa.resource_assignment_id = pb.resource_assignment_id
 and   pa.task_id = pt.task_id (+)
 and   pa.budget_version_id = pbv.budget_version_id
 and   rm.resource_list_member_id = pa.resource_list_member_id;

 --Cursor to copy actual/encumbrance balance when FC is not reqd
 -- R12 Funds Management Uptake : Obsolete cursor c_actencbal

 cursor c_actencbal(p_base_version_id in number) is
 select pb.project_id,
        pb.task_id,
        pb.top_task_id,
        pb.resource_list_member_id,
        pb.balance_type,
        pb.set_of_books_id,
        pb.PERIOD_NAME,
        pb.START_DATE,
        pb.END_DATE,
        pb.PARENT_MEMBER_ID,
        pb.actual_period_to_date,
        pb.encumb_period_to_date
 from   pa_bc_balances pb
 where pb.budget_version_id = p_base_version_id
 and   pb.balance_type <> 'BGT';

 --Tables to insert BGT lines into pa_bc_balances.
 l_ProjTab    PA_PLSQL_DATATYPES.IdTabTyp;
 l_TaskTab    PA_PLSQL_DATATYPES.IdTabTyp;
 l_TTaskTab   PA_PLSQL_DATATYPES.IdTabTyp;
 l_RlmiTab    PA_PLSQL_DATATYPES.IdTabTyp;
 l_BdgtVerTab PA_PLSQL_DATATYPES.IdTabTyp;
 l_PeriodTab  PA_PLSQL_DATATYPES.Char30TabTyp;
 l_StDateTab  PA_PLSQL_DATATYPES.DateTabTyp;
 l_EdDateTab  PA_PLSQL_DATATYPES.DateTabTyp;
 l_ParMemTab  PA_PLSQL_DATATYPES.IdTabTyp;
 l_BurdCostTab PA_PLSQL_DATATYPES.NumTabTyp;

 --Tables to copy ACT ENC lines into pa_bc_balances.
 -- R12 Funds Management Uptake : Deleted variables used in obsolete logic

 l_BalRowIdTab PA_PLSQL_DATATYPES.RowidTabTyp;

 --cursor to delete all versions prior to the latest baselined balance records if the
 --budget has been baselined before.
 cursor c_delbal(p_bdgt_ctrl_type in varchar2, p_bdgt_ver in number) is
 select a.rowid
 from pa_bc_balances a, pa_budgetary_control_options pbco, pa_budget_versions pbv
 where pbv.budget_version_id <> p_bdgt_ver
 and   a.project_id = pbco.project_id
 and   a.project_id = pbv.project_id
 and   a.budget_version_id = pbv.budget_version_id
 and   pbco.bdgt_cntrl_flag = 'Y'
 and   pbco.budget_type_code = pbv.budget_type_code
 and   ((p_bdgt_ctrl_type = 'GL' and pbco.external_budget_code = 'GL')
       or
        (p_bdgt_ctrl_type = 'CC' and pbco.external_budget_code = 'CC')
       or
        (p_bdgt_ctrl_type = 'GL' and pbco.external_budget_code is null))
 and   a.project_id = p_project_id;

 --cursor to delete draft version balance records when there is a failure in budget
 --baselining and the budget has not been baselined before.
 cursor c_deldraftbal(p_draft_bdgt_ver in number) is
 select rowid
 from pa_bc_balances
 where budget_version_id = p_draft_bdgt_ver;

 BEGIN

   --Initialize the error stack
   PA_DEBUG.set_err_stack('Insert BGT Balances');

   --Initialize the return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF P_DEBUG_MODE = 'Y' THEN
      pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'Entering Insert BGT Balances');
   END IF;

   --Delete all records for the passed draft budget version id
   --This is to make sure that existing balance records for the draft version id due to
   --a failure in the budget baselining process will be deleted
   IF P_DEBUG_MODE = 'Y' THEN
      pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'Open cursor to delete draft budget version- '||p_budget_version_id);
   END IF;
   OPEN c_deldraftbal(p_budget_version_id);
   LOOP

     l_BalRowIdTab.Delete;

     FETCH c_deldraftbal bulk collect into
        l_BalRowIdTab
     limit rows;

     if l_BalRowIdTab.count = 0 then
        IF P_DEBUG_MODE = 'Y' THEN
           pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'No rec in c_deldraftbal, exit');
        END IF;
        exit;
     end if;

     IF P_DEBUG_MODE = 'Y' THEN
        pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'Delete draft budget versions = ' || l_BalRowIdTab.count);
     END IF;
     FORALL j in l_BalRowIdTab.first..l_BalRowIdTab.last
        delete from pa_bc_balances
        where rowid = l_BalRowIdTab(j);

     commit;
     exit when c_deldraftbal%notfound;
   END LOOP;
   CLOSE c_deldraftbal;
   IF P_DEBUG_MODE = 'Y' THEN
      pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'After deleting draft versions, close cursor');
   END IF;

   --If Budget is baselined before then we need to get the latest baselined
   --version and delete from pa_bc_balances where budget_version_id not equal
   --to the latest baselined version. This is to maintain 2 budget versions at any
   --time. If budget is linked then we need to copy closed period balances to the
   --current budget version id.
   --IF (PA_FUNDS_CONTROL_UTILS.Is_Budget_Baselined_Before(p_project_id) = 'Y') then

   --Get latest Baselined budget version id
   IF P_DEBUG_MODE = 'Y' THEN
      pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'Get baselined budget');
   END IF;

   PA_FUNDS_CONTROL_UTILS.Get_Baselined_Budget_Version(
            p_calling_mode       => p_bdgt_ctrl_type,
            p_project_id         => p_project_id,
            x_base_version_id    => l_base_version_id,
            x_res_list_id        => l_res_list_id,
            x_entry_level_code   => l_entry_level_code,
            x_return_status      => x_return_status,
            x_error_message_code => x_error_message_code);

   IF P_DEBUG_MODE = 'Y' THEN
      pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'After get baselined budget = '||l_base_version_id||' RetSts = '||x_return_status);
   END IF;

   --If there is a baselined version then we delete balance records for versions prior to this version
   IF (l_base_version_id is not null) THEN

      IF P_DEBUG_MODE = 'Y' THEN
         pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'Baselined budget exists, delete old versions');
      END IF;
      --l_BalRowIdTab.Delete;

      --delete from pa_bc_balances where budget_version_id <> l_base_version_id
      PA_DEBUG.set_err_stack('Delete');
      IF P_DEBUG_MODE = 'Y' THEN
         pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'Open cursor to delete old budget versions');
      END IF;
      OPEN c_delbal(p_bdgt_ctrl_type,l_base_version_id);
      LOOP

        l_BalRowIdTab.Delete;

        FETCH c_delbal bulk collect into
           l_BalRowIdTab
        limit rows;

        if l_BalRowIdTab.count = 0 then
           IF P_DEBUG_MODE = 'Y' THEN
              pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'No rec in c_delbal, exit');
           END IF;
           exit;
        end if;

        IF P_DEBUG_MODE = 'Y' THEN
           pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'Delete old budget versions = ' || l_BalRowIdTab.count);
        END IF;
        FORALL j in l_BalRowIdTab.first..l_BalRowIdTab.last
           delete from pa_bc_balances
           where rowid = l_BalRowIdTab(j);

        commit;
        exit when c_delbal%notfound;
      END LOOP;
      CLOSE c_delbal;
      IF P_DEBUG_MODE = 'Y' THEN
         pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'After deleting old budget versions, close cursor');
      END IF;
   PA_DEBUG.Reset_Err_Stack;  --3912094
   END IF;

   -- R12 Funds management Uptake : Removed check for if fundscheck required which was always YES

   IF (p_bdgt_intg_flag = 'Y') THEN

         IF P_DEBUG_MODE = 'Y' THEN
            pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'Bdgt Intg Flag = Y');
         END IF;

         PA_DEBUG.set_err_stack('Bdgt linked');
         begin
           select  min(start_date), max(end_date)
             into  l_start_date, l_end_date
             from  pa_bc_balances
            where  project_id = p_project_id
              and  budget_version_id = l_base_version_id;
         exception
           when no_data_found then
              null;
         end;

         IF P_DEBUG_MODE = 'Y' THEN
            pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'Start,End = '|| l_start_date ||', '||l_end_date);
            pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'Calling get gl periods');
         END IF;
         PA_DEBUG.Reset_Err_Stack;  --3912094

         PA_DEBUG.set_err_stack('Call get_gl_periods');

         --Get all periods given the start and end date.
         PA_FUNDS_CONTROL_UTILS.get_gl_periods
               (p_start_date      => l_start_date,
                p_end_date        => l_end_date,
                p_set_of_books_id => p_set_of_books_id,
                x_tab_count       => l_tab_count,
                x_tab_pds         => l_tab_periods,
                x_return_status   => x_return_status);

         IF P_DEBUG_MODE = 'Y' THEN
            pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'After get gl periods, RetSts = '||x_return_status);
         END IF;
         PA_DEBUG.Reset_Err_Stack;  --3912094

         PA_DEBUG.set_err_stack('Insert Close Period Bal');
         IF P_DEBUG_MODE = 'Y' THEN
            pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'Insert closed period balances, TabCount = '||l_tab_count);
         END IF;

         FOR i in 1..l_tab_count LOOP
          begin
           IF P_DEBUG_MODE = 'Y' THEN
              pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'St,End and Status = ' ||l_tab_periods(i).start_date||':'||
                l_tab_periods(i).end_date||':'||l_tab_periods(i).closing_status);
           END IF;
           insert into pa_bc_balances(
                PROJECT_ID,
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
                ACTUAL_PERIOD_TO_DATE,
                ENCUMB_PERIOD_TO_DATE)
           select
                bal.PROJECT_ID,
                bal.TASK_ID,
                bal.TOP_TASK_ID,
                bal.RESOURCE_LIST_MEMBER_ID,
                bal.BALANCE_TYPE,
                bal.SET_OF_BOOKS_ID,
                p_budget_version_id,
                sysdate,
                FND_GLOBAL.USER_ID,
                FND_GLOBAL.USER_ID,
                sysdate,
                FND_GLOBAL.LOGIN_ID,
                bal.PERIOD_NAME,
                bal.START_DATE,
                bal.END_DATE,
                bal.PARENT_MEMBER_ID,
                bal.ACTUAL_PERIOD_TO_DATE,
                bal.ENCUMB_PERIOD_TO_DATE
           from pa_bc_balances bal
          where budget_version_id = l_base_version_id
            and trunc(start_date) = trunc(l_tab_periods(i).start_date)
            and trunc(end_date) = trunc(l_tab_periods(i).end_date)
            and l_tab_periods(i).closing_status = 'C'
            and project_id = p_project_id
            and balance_type <> 'BGT';
          exception
           when no_data_found then
             null;
          end;
         END LOOP;
         IF P_DEBUG_MODE = 'Y' THEN
            pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'Inserted closed period balances');
         END IF;
         PA_DEBUG.Reset_Err_Stack;  --3912094
   END IF;

   -- R12 Funds management Uptake : Deleted logic which was fired when fundscheck is not required .
   -- This procedure is always fired with fundscheck required as Yes.

   --Insert BGT lines.
   IF P_DEBUG_MODE = 'Y' THEN
      pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'Before inserting BGT lines');
   END IF;
   PA_DEBUG.set_err_stack('Insert BGT lines');

   open c_bdgt_bal;
   loop
     l_ProjTab.Delete;
     l_TaskTab.Delete;
     l_TTaskTab.Delete;
     l_RlmiTab.Delete;
     l_BdgtVerTab.Delete;
     l_PeriodTab.Delete;
     l_StDateTab.Delete;
     l_EdDateTab.Delete;
     l_ParMemTab.Delete;
     l_BurdCostTab.Delete;

      IF P_DEBUG_MODE = 'Y' THEN
         pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'Fetch c_bdgt_bal');
      END IF;
      fetch c_bdgt_bal bulk collect into
            l_ProjTab,
            l_TaskTab,
            l_TTaskTab,
            l_RlmiTab,
            l_BdgtVerTab,
            l_PeriodTab,
            l_StDateTab,
            l_EdDateTab,
            l_ParMemTab,
            l_BurdCostTab
      limit rows;

      IF (l_ProjTab.count = 0) THEN
          IF P_DEBUG_MODE = 'Y' THEN
             pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'No rec in c_bdgt_bal, exit');
          END IF;
          EXIT;
      END IF;

      IF P_DEBUG_MODE = 'Y' THEN
         pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'Before Insert, no. of rec = '|| l_ProjTab.count);
      END IF;
      -- insert into pa_bc_balances from pa_budget_lines
      FORALL i in l_ProjTab.FIRST..l_ProjTab.LAST
            insert into pa_bc_balances(
                PROJECT_ID,
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
                BUDGET_PERIOD_TO_DATE,
                ACTUAL_PERIOD_TO_DATE,
                ENCUMB_PERIOD_TO_DATE)
            select
                l_ProjTab(i),
                l_TaskTab(i),
                l_TTaskTab(i),
                l_RlmiTab(i),
                'BGT',
                p_set_of_books_id,
                l_BdgtVerTab(i),
                sysdate,
                FND_GLOBAL.USER_ID,
                FND_GLOBAL.USER_ID,
                sysdate,
                FND_GLOBAL.LOGIN_ID,
                l_PeriodTab(i),
                l_StDateTab(i),
                l_EdDateTab(i),
                l_ParMemTab(i),
                l_BurdCostTab(i),
                0,
                0
            from dual;
      commit;
      IF P_DEBUG_MODE = 'Y' THEN
         pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'After inserting BGT lines');
      END IF;
      exit when c_bdgt_bal%notfound;
   end loop;
   close c_bdgt_bal;
   PA_DEBUG.Reset_Err_Stack;  --3912094
   PA_DEBUG.set_err_stack('Inserted BGT lines');

   IF P_DEBUG_MODE = 'Y' THEN
      pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'Exiting Insert BGT Balances');
   END IF;

   --Reset the error stack when returning to the calling program
   PA_DEBUG.Reset_Err_Stack;
   PA_DEBUG.Reset_Err_Stack; -- Bug 5064900

 EXCEPTION
  WHEN OTHERS THEN
     FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_BGT_BASELINE_PKG'
                   ,p_procedure_name => 'INSERT_BGT_BALANCES'  --Bug 5064900
		   ,p_error_text => PA_DEBUG.G_Err_Stack );

     IF c_bdgt_bal%ISOPEN THEN
        close c_bdgt_bal;
     END IF;
     IF c_delbal%ISOPEN THEN
        close c_delbal;
     END IF;
     IF c_deldraftbal%ISOPEN THEN
        close c_delbal;
     END IF;

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     x_error_message_code := (SQLCODE||' '||SQLERRM);
     PA_DEBUG.Reset_Err_Stack; --Bug 5064900
     RAISE;
 END INSERT_BGT_BALANCES;
 ================================================================================================ */
 -----------------------------------------------------------------------------------


 /******************************IS FC REQUIRED********************************
    This funtion will return TRUE for Buza Phase 1.
    All conditions will be included for Phase 2

    Aug 01 - This function will not be implemented as the current supported
             document types for budgetary control and top-down integration
             is going to be AP INV,PO, REQ, INV ADJ. Since the volume will
             be less this function is not implemented. Moreover there is
             no design consideration of maintaining amount type/boundary code
             for each budget version id.
 ****************************************************************************/

 -- This Function is to see if Funds checking (FC) is required for this Budget.

 -- Conditions for FC requirement is:
 -- 1. If Budget Entry Method has been changed in the new draft budget.
 -- 2. If Resource List has been changed in the new draft budget.
 -- 3. If Budgetted amount is decreased for a particular Resource
 -- 4. If a new resource is added to the budget (To be enabled later).

 FUNCTION is_fc_required (p_project_id IN NUMBER, p_bdgt_ctrl_type in varchar2) RETURN boolean IS

   l_draft_entry_method varchar2(30);
   l_draft_res_list_id number;
   l_draft_burdened_cost number;

   l_baselined_entry_method varchar2(30);
   l_baselined_res_list_id number;
   l_baselined_burdened_cost number;

   CURSOR c_bdgt_ver(p_project_id in NUMBER, p_bdgt_ctrl_type in varchar2) IS
   select
        draft_array.budget_entry_method_code,
        baselined_array.budget_entry_method_code,
        draft_array.resource_list_id,
        baselined_array.resource_list_id,
        draft_array.burdened_cost,
        baselined_array.burdened_cost
   from
        (select
                pbv_b.budget_entry_method_code budget_entry_method_code,
                pbv_b.resource_list_id resource_list_id,
                pbl_b.burdened_cost burdened_cost,
                pra_b.resource_list_member_id resource_list_member_id,
                pra_b.project_id project_id,
                pra_b.task_id task_id,
                pbl_b.start_date start_date
        from    pa_budget_versions pbv_b,
                pa_budgetary_control_options pbco_b,
                pa_budget_lines pbl_b,
                pa_resource_assignments pra_b
        where   pbv_b.project_id = p_project_id
        and     pbv_b.budget_status_code = 'B'
        and     pbv_b.current_flag ='Y'
        and     pbco_b.bdgt_cntrl_flag = 'Y'
        and     pbco_b.budget_type_code = pbv_b.budget_type_code
        and     pbco_b.project_id = pbv_b.project_id
        and     ((p_bdgt_ctrl_type = 'GL' and pbco_b.external_budget_code = 'GL')
                or
                 (p_bdgt_ctrl_type = 'CC' and pbco_b.external_budget_code = 'CC')
                or
                 (p_bdgt_ctrl_type = 'GL' and pbco_b.external_budget_code is null))
        and    pbv_b.budget_version_id = pra_b.budget_version_id
        and    pra_b.resource_assignment_id = pbl_b.resource_assignment_id) baselined_array,
        (select
                pbv_d.budget_entry_method_code budget_entry_method_code,
                pbv_d.resource_list_id resource_list_id,
                pbl_d.burdened_cost burdened_cost,
		pra_d.resource_list_member_id resource_list_member_id,
                pra_d.project_id project_id,
                pra_d.task_id task_id,
                pbl_d.start_date start_date
        from    pa_budget_versions pbv_d,
                pa_budgetary_control_options pbco_d,
                pa_budget_lines pbl_d,
                pa_resource_assignments pra_d
        where   pbv_d.project_id = p_project_id
        and     pbv_d.budget_status_code in ('W','S')
        and     pbco_d.bdgt_cntrl_flag = 'Y'
        and     pbco_d.budget_type_code = pbv_d.budget_type_code
        and     pbco_d.project_id = pbv_d.project_id
        and     ((p_bdgt_ctrl_type = 'GL' and pbco_d.external_budget_code = 'GL')
                or
                 (p_bdgt_ctrl_type = 'CC' and pbco_d.external_budget_code = 'CC')
                or
                 (p_bdgt_ctrl_type = 'GL' and pbco_d.external_budget_code is null))
        and    pbv_d.budget_version_id = pra_d.budget_version_id
        and    pra_d.resource_assignment_id = pbl_d.resource_assignment_id) draft_array
   where   baselined_array.project_id = draft_array.project_id(+)
   and     baselined_array.resource_list_member_id = draft_array.resource_list_member_id (+)
   and     baselined_array.task_id = draft_array.task_id(+)
   and     baselined_array.start_date = draft_array.start_date(+);

 BEGIN

    IF P_DEBUG_MODE = 'Y' THEN
       pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'Entering Is FC reqd');
    END IF;

    /**********************************************************
     Commented for Phase 1.
     To be enabled for Phase 2 with additional conditions

    open c_bdgt_ver(p_project_id, p_bdgt_ctrl_type);

    loop
      fetch c_bdgt_ver into
         l_draft_entry_method,
         l_baselined_entry_method,
         l_draft_res_list_id,
         l_baselined_res_list_id,
         l_draft_burdened_cost,
         l_baselined_burdened_cost;

      exit when c_bdgt_ver%NOTFOUND;

      -- Check to see if Budget Entry Method has been changed in Draft Budget
      if nvl(l_draft_entry_method,'x') <> nvl(l_baselined_entry_method,'x') then
         close c_bdgt_ver;
         return TRUE; -- FC reqd.
      end if;

      -- Check to see if Resource List has been changed in Draft Budget
      if nvl(l_draft_res_list_id,0) <> nvl(l_baselined_res_list_id,0) then
         close c_bdgt_ver;
         return TRUE; -- FC reqd.
      end if;

      if nvl(l_draft_burdened_cost,0) < nvl(l_baselined_burdened_cost,0) then
         close c_bdgt_ver;
         return TRUE; -- FC reqd.
      end if;

    end loop;

    IF P_DEBUG_MODE = 'Y' THEN
       pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'Exiting Is FC Reqd');
    END IF;

    close c_bdgt_ver;
    return FALSE;
    ***********************************************************/

    return TRUE;

 END is_fc_required;
 -------------------------------------------------------------------------------

 -- procedure to load all the vendor invoices, expense reports and BTC transactions
 -- into pa_bc_packets for funds check
 PROCEDURE INSERT_VI_ER_BTC_TXNS(
                p_packet_id          IN NUMBER,
                p_sob_id             IN NUMBER,
                p_project_id         IN NUMBER,
                p_budget_version_id  IN NUMBER,
                p_bdgt_intg_flag     IN VARCHAR2,
                x_return_status      OUT NOCOPY VARCHAR2,
                x_error_message_code OUT NOCOPY VARCHAR2) IS

 l_ExpProjTab    PA_PLSQL_DATATYPES.IdTabTyp;
 l_ExpTaskTab    PA_PLSQL_DATATYPES.IdTabTyp;
 l_ExpExpTypTab  PA_PLSQL_DATATYPES.Char30TabTyp;
 l_ExpEiDateTab  PA_PLSQL_DATATYPES.DateTabTyp;
 l_ExpExpOrgTab  PA_PLSQL_DATATYPES.IdTabTyp;
 l_ExpPeriodTab  PA_PLSQL_DATATYPES.Char15TabTyp;
 l_ExpPdYearTab  PA_PLSQL_DATATYPES.NumTabTyp;
 l_ExpPdNumTab   PA_PLSQL_DATATYPES.NumTabTyp;
 l_ExpDocDistTab PA_PLSQL_DATATYPES.IdTabTyp;
 l_ExpDocHdrTab  PA_PLSQL_DATATYPES.IdTabTyp;
 l_ExpEntDrTab   PA_PLSQL_DATATYPES.NumTabTyp;
 l_ExpEntCrTab   PA_PLSQL_DATATYPES.NumTabTyp;
 l_ExpAcctDrTab  PA_PLSQL_DATATYPES.NumTabTyp;
 l_ExpAcctCrTab  PA_PLSQL_DATATYPES.NumTabTyp;
 l_ExpGlDateTab  PA_PLSQL_DATATYPES.DateTabTyp;
 l_ExpPaDateTab  PA_PLSQL_DATATYPES.DateTabTyp;
 l_ExpTxnCCIDTab PA_PLSQL_DATATYPES.IdTabTyp;
 l_ExpOrgIdTab   PA_PLSQL_DATATYPES.IdTabTyp;
 l_ExpBdgtCCIDTab PA_PLSQL_DATATYPES.IdTabTyp;

 --PA.M
 l_ExpPoLineIdTab PA_PLSQL_DATATYPES.IdTabTyp;
 l_ExpReference1Tab PA_PLSQL_DATATYPES.Char80TabTyp;
 l_ExpReference2Tab PA_PLSQL_DATATYPES.Char80TabTyp;
 l_ExpReference3Tab PA_PLSQL_DATATYPES.Char80TabTyp;
 l_ExpParBcPktIdTab PA_PLSQL_DATATYPES.IdTabTyp;

 TYPE t_ref_cursor IS REF CURSOR;

 c_vierbtc_txns t_ref_cursor;

 PROCEDURE proc_open_cursor(p_project_id in number, p_sob_id in number, p_bdgt_intg_flag in varchar2) IS
 BEGIN
 IF (p_bdgt_intg_flag = 'Y') THEN
   OPEN c_VIERBTC_txns FOR
        --(p_project_id in number, p_sob_id in number, p_bdgt_intg_flag in varchar2) is
     select cdl.project_id,
        cdl.task_id,
        ei.EXPENDITURE_TYPE,
        trunc(ei.EXPENDITURE_ITEM_DATE) expenditure_item_date,
       --  nvl(ei.override_to_organization_id,exp.incurred_by_organization_id) organization_id,   -- 7531681
        nvl(ei.override_to_organization_id,( select exp.incurred_by_organization_id from pa_expenditures_all exp
                 where exp.expenditure_id = ei.expenditure_id)) organization_id,                  -- 7531681
       gl.PERIOD_NAME,
        gl.PERIOD_YEAR,
        gl.PERIOD_NUM,
        cdl.expenditure_item_id,
        cdl.line_num,
	/** Commented out for burdening enhancements
        --decode(sign(cdl.denom_burdened_cost),1,cdl.denom_burdened_cost,0) entered_dr,
        --decode(sign(cdl.denom_burdened_cost),-1,ABS(cdl.denom_burdened_cost),0) entered_cr,
        --decode(sign(cdl.acct_burdened_cost),1,cdl.acct_burdened_cost,0) accounted_dr,
        --decode(sign(cdl.acct_burdened_cost),-1,ABS(cdl.acct_burdened_cost),0) accounted_cr,
	**/
        decode(sign(nvl(cdl.denom_burdened_cost,0)+nvl(cdl.DENOM_BURDENED_CHANGE,0))
		   ,1,(nvl(cdl.denom_burdened_cost,0)+nvl(cdl.DENOM_BURDENED_CHANGE,0))
		   ,0) entered_dr,
        decode(sign(nvl(cdl.denom_burdened_cost,0)+nvl(cdl.DENOM_BURDENED_CHANGE,0))
		   ,-1,ABS(nvl(cdl.denom_burdened_cost,0)+nvl(cdl.DENOM_BURDENED_CHANGE,0))
		   ,0) entered_cr,
        decode(sign(nvl(cdl.acct_burdened_cost,0)+nvl(cdl.ACCT_BURDENED_CHANGE,0))
		   ,1,(nvl(cdl.acct_burdened_cost,0)+nvl(cdl.ACCT_BURDENED_CHANGE,0))
		   ,0) accounted_dr,
        decode(sign(nvl(cdl.acct_burdened_cost,0)+nvl(cdl.ACCT_BURDENED_CHANGE,0))
                   ,-1,ABS(nvl(cdl.acct_burdened_cost,0)+nvl(cdl.ACCT_BURDENED_CHANGE,0))
		   ,0) accounted_cr,
        cdl.gl_date,
        cdl.pa_date,
        cdl.dr_code_combination_id,
        cdl.org_id,
        cdl.budget_ccid
        --PA.M
        , ei.po_line_id
        ,'EXP'
        ,cdl.expenditure_item_id
        ,cdl.line_num
        --PA.M selecting -99 for parent bc pkt for CWK BTC EIs
        ,decode(ei.system_linkage_function, 'BTC', decode(nvl(ei.po_line_id,-99), -99, null, -99), null)
     from  pa_expenditure_items_all ei,
          --  pa_expenditures_all exp,    -- 7531681
           pa_cost_distribution_lines_all cdl,
           gl_period_STATUSES gl,
           pa_tasks pt
     where cdl.project_id = p_project_id
       and pt.task_id = ei.task_id
       -- and ei.expenditure_id = exp.expenditure_id    -- 7531681
       --and trunc(gl.end_date) = trunc(cdl.gl_date)
       --commented above since AP gl_date = transaction date rather end date of period
       and trunc(cdl.gl_date) between trunc(gl.start_date) and trunc(gl.end_date)
       and gl.application_id = 101
       and gl.set_of_books_id = p_sob_id
       and gl.adjustment_period_flag = 'N'
       and gl.closing_status in ('O','F')
       --and nvl(cdl.amount,0) <> 0 -- filter burden transactions
       and ei.expenditure_item_id = cdl.expenditure_item_id
       and cdl.line_type = 'R'
       and cdl.reversed_flag is null
       and cdl.line_num_reversed is null
       --and ei.cost_distributed_flag = 'Y' commented out to handle failed ER batches
       and nvl(ei.net_zero_adjustment_flag,'N') <> 'Y'
       --PA.M: Added ST OT where PO Line ID is populated
       and ((ei.system_linkage_function =  'VI' --'ER'
            or
            (ei.system_linkage_function in ('ST', 'OT')
             and ei.po_line_id is not null)
            )
        or (ei.system_linkage_function = 'BTC'
             /* 7531681   start */
            and exists (select null
                          from pa_expenditure_items_all ei1,
                               pa_cost_distribution_lines_all cdl1
                          where ( cdl1.burden_sum_source_run_id = ei.burden_sum_dest_run_id
           and cdl1.project_id = p_project_id
                       and ei1.expenditure_item_id = cdl1.expenditure_item_id
                    )
                        and (ei1.system_linkage_function = 'VI'
                            or
                            (ei1.system_linkage_function in ('ST', 'OT')
                             and ei1.po_line_id is not null)
                            )
       UNION ALL
      select null from pa_expenditure_items_all ei1,
                        pa_aud_cost_dist_lines aud
                   WHERE
               ( aud.burden_sum_source_run_id = ei.burden_sum_dest_run_id
              and aud.expenditure_item_id = ei1.expenditure_item_id
             )
                        and (ei1.system_linkage_function = 'VI'
                            or
                            (ei1.system_linkage_function in ('ST', 'OT')
                             and ei1.po_line_id is not null)
                            )
     )));
         /*   7531681 end */
           --Bug 2795051
           --           from pa_expenditure_items_all ei1,
           --           and ei1.expenditure_item_id = cdl1.expenditure_item_id
           --           and ei1.system_linkage_function = 'VI'
           --Bug 3019361
           --Added pa_aud_cost_dist_lines to select BTC EIs of previous run ids
           --During PA.L testing, the below exists clause performed faster than alternative 2 below.
           --hence replaced pa_bc_commitments join with pa_expenditure_items_all as it was originally
/* 7531681    and exists (select null
                         from pa_expenditure_items_all ei1,
                              pa_cost_distribution_lines_all cdl1,
		              pa_aud_cost_dist_lines aud
                        --PA.M added outer join to cdl1 and aud plus changed the or to and
                        --     cos if there are no records in aud,
                        --     then this will not pick up the BTC txns
                        where ( cdl1.burden_sum_source_run_id(+) = ei.burden_sum_dest_run_id
			        and cdl1.expenditure_item_id(+) = ei1.expenditure_item_id
			      )
   			       --or
   			       and
 			      ( aud.burden_sum_source_run_id(+) = ei.burden_sum_dest_run_id
			        and aud.expenditure_item_id(+) = ei1.expenditure_item_id
			      )
                      and cdl1.expenditure_item_id = ei1.expenditure_item_id
                      --PA.M: Added ST OT where PO Line ID is populated
                      and (ei1.system_linkage_function = 'VI'
                           or
                           (ei1.system_linkage_function in ('ST', 'OT')
                            and ei1.po_line_id is not null)
                           )
                      )
           )
          );   7531681  */

          /*If above exists clause performs badly, alternative 2 is to replace join to ei with pa_bc_commitments_all */
          /*Exists clause before fixing bug 3019361 is as follows
          and exists (select null
                      from pa_bc_commitments_all bc,
                           pa_cost_distribution_lines_all cdl1
                      where cdl1.burden_sum_source_run_id = ei.burden_sum_dest_run_id
                      and bc.document_header_id = to_number(cdl1.system_reference2)
                      and bc.document_distribution_id = to_number(cdl1.system_reference3)))); --'ER'
          */
 ELSE
   OPEN c_VIERBTC_txns FOR
    select cdl.project_id,
        cdl.task_id,
        ei.EXPENDITURE_TYPE,
        trunc(ei.EXPENDITURE_ITEM_DATE) expenditure_item_date,
       --  nvl(ei.override_to_organization_id,exp.incurred_by_organization_id) organization_id,  -- 7531681
        nvl(ei.override_to_organization_id,( select exp.incurred_by_organization_id from pa_expenditures_all exp
                  where exp.expenditure_id = ei.expenditure_id)) organization_id,                 -- 7531681

        gl.PERIOD_NAME,
        gl.PERIOD_YEAR,
        gl.PERIOD_NUM,
        cdl.expenditure_item_id,
        cdl.line_num,
	/** Commented out for Burdening enhancements
        --decode(sign(cdl.denom_burdened_cost),1,cdl.denom_burdened_cost,0) entered_dr,
        --decode(sign(cdl.denom_burdened_cost),-1,ABS(cdl.denom_burdened_cost),0) entered_cr,
        --decode(sign(cdl.acct_burdened_cost),1,cdl.acct_burdened_cost,0) accounted_dr,
        --decode(sign(cdl.acct_burdened_cost),-1,ABS(cdl.acct_burdened_cost),0) accounted_cr,
	**/
        decode(sign(nvl(cdl.denom_burdened_cost,0)+nvl(cdl.DENOM_BURDENED_CHANGE,0))
                   ,1,(nvl(cdl.denom_burdened_cost,0)+nvl(cdl.DENOM_BURDENED_CHANGE,0))
                   ,0) entered_dr,
        decode(sign(nvl(cdl.denom_burdened_cost,0)+nvl(cdl.DENOM_BURDENED_CHANGE,0))
                   ,-1,ABS(nvl(cdl.denom_burdened_cost,0)+nvl(cdl.DENOM_BURDENED_CHANGE,0))
                   ,0) entered_cr,
        decode(sign(nvl(cdl.acct_burdened_cost,0)+nvl(cdl.ACCT_BURDENED_CHANGE,0))
                   ,1,(nvl(cdl.acct_burdened_cost,0)+nvl(cdl.ACCT_BURDENED_CHANGE,0))
                   ,0) accounted_dr,
        decode(sign(nvl(cdl.acct_burdened_cost,0)+nvl(cdl.ACCT_BURDENED_CHANGE,0))
                   ,-1,ABS(nvl(cdl.acct_burdened_cost,0)+nvl(cdl.ACCT_BURDENED_CHANGE,0))
                   ,0) accounted_cr,
        cdl.gl_date,
        cdl.pa_date,
        cdl.dr_code_combination_id,
        cdl.org_id,
        cdl.budget_ccid
        --PA.M
        ,ei.po_line_id
	,'EXP'
	,cdl.expenditure_item_id
	,cdl.line_num
        --PA.M selecting -99 for parent bc pkt for CWK BTC EIs
        ,decode(ei.system_linkage_function, 'BTC', decode(nvl(ei.po_line_id,-99), -99, null, -99), null)
    from  pa_expenditure_items_all ei,
        --  pa_expenditures_all exp,   -- 7531681
          pa_cost_distribution_lines_all cdl,
          gl_period_STATUSES gl,
          pa_tasks pt
    where cdl.project_id = p_project_id
      and  pt.task_id = ei.task_id
      -- and ei.expenditure_id = exp.expenditure_id   -- 7531681
      --and trunc(gl.end_date) = trunc(cdl.gl_date)
      --commented above since AP gl_date = transaction date rather end date of period
      and trunc(cdl.gl_date) between trunc(gl.start_date) and trunc(gl.end_date)
      and gl.application_id = 101
      and gl.set_of_books_id = p_sob_id
      and gl.adjustment_period_flag = 'N'
      --and gl.closing_status = decode(p_bdgt_intg_flag, 'Y', 'O', gl.closing_status)
      --and nvl(cdl.amount,0) <> 0 -- filter burden transactions
      and ei.expenditure_item_id = cdl.expenditure_item_id
      and cdl.line_type = 'R'
      and cdl.reversed_flag is null
      and cdl.line_num_reversed is null
      --and ei.cost_distributed_flag = 'Y' commented out to handle failed ER batches
      and nvl(ei.net_zero_adjustment_flag,'N') <> 'Y'
      --PA.M: Added ST OT where PO Line ID is populated
      and ((ei.system_linkage_function = 'VI'  --'ER'
            or
            (ei.system_linkage_function in ('ST', 'OT')
             and ei.po_line_id is not null)
            )
       or (ei.system_linkage_function = 'BTC'
              /* 7531681 start */
                   and exists (select null
                          from pa_expenditure_items_all ei1,
                               pa_cost_distribution_lines_all cdl1
                          where ( cdl1.burden_sum_source_run_id = ei.burden_sum_dest_run_id
           and cdl1.project_id = p_project_id
                   and ei1.expenditure_item_id = cdl1.expenditure_item_id
                    )
                        and (ei1.system_linkage_function = 'VI'
                            or
                            (ei1.system_linkage_function in ('ST', 'OT')
                             and ei1.po_line_id is not null)
                            )
       UNION ALL
      select null from pa_expenditure_items_all ei1,
                        pa_aud_cost_dist_lines aud
                   WHERE
               ( aud.burden_sum_source_run_id = ei.burden_sum_dest_run_id
              and aud.expenditure_item_id = ei1.expenditure_item_id
             )
                        and (ei1.system_linkage_function = 'VI'
                            or
                            (ei1.system_linkage_function in ('ST', 'OT')
                             and ei1.po_line_id is not null)
                            )
     )
            )
           );
/* 7531681 end */
           --Bug 2795051
           --           from pa_expenditure_items_all ei1,
           --           and ei1.expenditure_item_id = cdl1.expenditure_item_id
           --           and ei1.system_linkage_function = 'VI'
           --Bug 3019361
           --Added pa_aud_cost_dist_lines to select BTC EIs of previous run ids
           --During PA.L testing, the below exists clause performed faster than alternative 2 below.
           --hence replaced pa_bc_commitments join with pa_expenditure_items_all as it was originally
/* 7531681            and exists (select null
                         from pa_expenditure_items_all ei1,
                              pa_cost_distribution_lines_all cdl1,
                              pa_aud_cost_dist_lines aud
                        --PA.M added outer join to cdl1 and aud plus changed the or to and
                        --     cos if there are no records in aud,
                        --     then this will not pick up the BTC txns
                        where ( cdl1.burden_sum_source_run_id(+) = ei.burden_sum_dest_run_id
                                and cdl1.expenditure_item_id(+) = ei1.expenditure_item_id
                              )
                              -- or
                              and
                              ( aud.burden_sum_source_run_id(+) = ei.burden_sum_dest_run_id
                                and aud.expenditure_item_id(+) = ei1.expenditure_item_id
                              )
                      and cdl1.expenditure_item_id = ei1.expenditure_item_id
                      --PA.M: Added ST OT where PO Line ID is populated
                      and (ei1.system_linkage_function = 'VI'
                           or
                           (ei1.system_linkage_function in ('ST', 'OT')
                            and ei1.po_line_id is not null)
                          )
                      )
           )
          );   7531681 */

          /*If above exists clause performs badly, alternative 2 is to replace join to ei with pa_bc_commitments_all */
          /*Exists clause before fixing bug 3019361 is as follows
          and exists (select null
                      from pa_bc_commitments_all bc,
                           pa_cost_distribution_lines_all cdl1
                      where cdl1.burden_sum_source_run_id = ei.burden_sum_dest_run_id
                      and bc.document_header_id = to_number(cdl1.system_reference2)
                      and bc.document_distribution_id = to_number(cdl1.system_reference3)))); --'ER'
          */
 END IF;
 END proc_open_cursor;

 BEGIN

   --Initialize the error stack
   PA_DEBUG.set_err_stack('Insert VIERBTC Txns');

   --Initialize the return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF P_DEBUG_MODE = 'Y' THEN
      pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'Entering VI ER BTC Project = '|| p_project_id||' SOB = '|| p_sob_id || ' Intg = '||p_bdgt_intg_flag);
   END IF;

   --OPEN c_VIERBTC_txns(p_project_id, p_sob_id, p_bdgt_intg_flag);
   --Call procedure to open cursor c_vierbtc_txns
   proc_open_cursor(p_project_id, p_sob_id, p_bdgt_intg_flag);

   LOOP

        --Initialize pl/sql tables
        l_ExpProjTab.Delete;
        l_ExpTaskTab.Delete;
        l_ExpExpTypTab.Delete;
        l_ExpEiDateTab.Delete;
        l_ExpExpOrgTab.Delete;
        l_ExpPeriodTab.Delete;
        l_ExpPdYearTab.Delete;
        l_ExpPdNumTab.Delete;
        l_ExpDocDistTab.Delete;
        l_ExpDocHdrTab.Delete;
        l_ExpEntDrTab.Delete;
        l_ExpEntCrTab.Delete;
        l_ExpAcctDrTab.Delete;
        l_ExpAcctCrTab.Delete;
        l_ExpGlDateTab.Delete;
        l_ExpPaDateTab.Delete;
        l_ExpTxnCCIDTab.Delete;
        l_ExpOrgIdTab.Delete;
        l_ExpBdgtCCIDTab.Delete;
        --PA.M
        l_ExpPoLineIdTab.Delete;
	l_ExpReference1Tab.delete;
	l_ExpReference2Tab.delete;
	l_ExpReference3Tab.delete;
        l_ExpParBcPktIdTab.delete;

        IF P_DEBUG_MODE = 'Y' THEN
           pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'Before Fetch of c_vierbtc');
        END IF;

        --Insert ER, VI, BTC
        FETCH c_VIERBTC_txns bulk collect into
               l_ExpProjTab,
               l_ExpTaskTab,
               l_ExpExpTypTab,
               l_ExpEiDateTab,
               l_ExpExpOrgTab,
               l_ExpPeriodTab,
               l_ExpPdYearTab,
               l_ExpPdNumTab,
               l_ExpDocHdrTab,
               l_ExpDocDistTab,
               l_ExpEntDrTab,
               l_ExpEntCrTab,
               l_ExpAcctDrTab,
               l_ExpAcctCrTab,
               l_ExpGlDateTab,
               l_ExpPaDateTab,
               l_ExpTxnCCIDTab,
               l_ExpOrgIdTab,
               l_ExpBdgtCCIDTab
               --PA.M
               ,l_ExpPOLineIdTab
	       ,l_ExpReference1Tab
               ,l_ExpReference2Tab
               ,l_ExpReference3Tab
               ,l_ExpParBcPktIdTab
        LIMIT rows;

        IF P_DEBUG_MODE = 'Y' THEN
           pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'Fetched ER VI BTC, count = ' || l_ExpProjTab.count);
        END IF;

        IF l_ExpProjTab.count=0 THEN
           IF P_DEBUG_MODE = 'Y' THEN
              pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'No rec in cursor c_vierbtc exit');
           END IF;
           exit;
        END IF;

        IF P_DEBUG_MODE = 'Y' THEN
           pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'Before inserting VIERBTC');
        END IF;
        FORALL m in l_ExpProjTab.FIRST..l_ExpProjTab.LAST
        insert into pa_bc_packets (
              PACKET_ID,
              PROJECT_ID,
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
              DOCUMENT_TYPE,
              EXPENDITURE_ORGANIZATION_ID,
              PERIOD_NAME,
              PERIOD_YEAR,
              PERIOD_NUM,
              DOCUMENT_HEADER_ID,
              DOCUMENT_DISTRIBUTION_ID,
              ENTERED_DR,
              ENTERED_CR,
              accounted_dr,
              accounted_cr,
              BUDGET_VERSION_ID,
              bc_packet_id,
              funds_process_mode,
              parent_bc_packet_id,
              gl_date,
              pa_date,
              txn_ccid,
              result_code,
              balance_posted_flag,
              org_id,
              burden_cost_flag,
              old_budget_ccid
              --PA.M
              ,document_line_id
	      ,reference1
	      ,reference2
	      ,reference3 )
        select
              p_packet_id,
              l_ExpProjTab(m),
              l_ExpTaskTab(m),
              l_ExpExpTypTab(m),
              l_ExpEiDateTab(m),
              'A',
              'P',
              sysdate,
              FND_GLOBAL.USER_ID,
              FND_GLOBAL.USER_ID,
              sysdate,
              FND_GLOBAL.LOGIN_ID,
              p_sob_id,
              'Project Accounting',
              'Expenditures',
              'EXP',
              l_ExpExpOrgTab(m),
              l_ExpPeriodTab(m),
              l_ExpPdYearTab(m),
              l_ExpPdNumTab(m),
              l_ExpDocHdrTab(m),
              l_ExpDocDistTab(m),
              l_ExpEntDrTab(m),
              l_ExpEntCrTab(m),
              l_ExpAcctDrTab(m),
              l_ExpAcctCrTab(m),
              p_budget_version_id,
              pa_bc_packets_s.nextval,
              'B',
              --PA.M insert parent bc pkt as -99 for CWK BTC EIs
              --null,
              l_ExpParBcPktIdTab(m),
              l_ExpGlDateTab(m),
              l_ExpPaDateTab(m),
              l_ExpTxnCCIDTab(m),
              'P',
              'N',
              l_ExpOrgIdTab(m),
              'N',
              l_ExpBdgtCCIDTab(m)
              --PA.M
              ,l_ExpPoLineIdTab(m)
		,l_ExpReference1Tab(m)
        	,l_ExpReference2Tab(m)
        	,l_ExpReference3Tab(m)
        from  dual;

        commit;
        EXIT WHEN c_VIERBTC_txns%NOTFOUND;
  END LOOP;
  CLOSE c_VIERBTC_txns;
  PA_DEBUG.Reset_Err_Stack;  --3912094
  PA_DEBUG.set_err_stack('Inserted VIERBTC Txns');

  IF P_DEBUG_MODE = 'Y' THEN
     pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'Exiting VIERBTC');
  END IF;

  --Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;

 EXCEPTION
  WHEN OTHERS THEN
     FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_BGT_BASELINE_PKG'
                   ,p_procedure_name => 'INSERT_VI_ER_BTC_TXNS'  -- Bug 5064900
		   ,p_error_text => PA_DEBUG.G_Err_Stack );

     IF c_VIERBTC_txns%ISOPEN THEN
        close c_VIERBTC_txns;
     END IF;

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     x_error_message_code := (SQLCODE||' '||SQLERRM);
     PA_DEBUG.Reset_Err_Stack; -- Bug 5064900
     RAISE;
 END INSERT_VI_ER_BTC_TXNS;
 ---------------------------------------------------------------------------------------------

 -- procedure to load all commitment transactions in pa_bc_packets for funds check
 PROCEDURE INSERT_COMMITMENT_TXNS(
		p_packet_id 	     IN NUMBER,
		p_sob_id	     IN NUMBER,
		p_project_id  	     IN NUMBER,
                p_budget_version_id  IN NUMBER,
		p_bdgt_ctrl_type     IN VARCHAR2,
		p_bdgt_intg_flag     IN VARCHAR2,
		x_return_status      OUT NOCOPY VARCHAR2,
		x_error_message_code OUT NOCOPY VARCHAR2) IS

 l_ProjTab     PA_PLSQL_DATATYPES.IdTabTyp;
 l_TaskTab     PA_PLSQL_DATATYPES.IdTabTyp;
 l_ExpTypTab   PA_PLSQL_DATATYPES.Char30TabTyp;
 l_EiDateTab   PA_PLSQL_DATATYPES.DateTabTyp;
 l_SobTab      PA_PLSQL_DATATYPES.IdTabTyp;
 l_CatNameTab  PA_PLSQL_DATATYPES.Char30TabTyp;
 l_SrcNameTab  PA_PLSQL_DATATYPES.Char30TabTyp;
 l_DocTypTab   PA_PLSQL_DATATYPES.Char10TabTyp;
 l_ExpOrgTab   PA_PLSQL_DATATYPES.IdTabTyp;
 l_PeriodTab   PA_PLSQL_DATATYPES.Char15TabTyp;
 l_PdYearTab   PA_PLSQL_DATATYPES.NumTabTyp;
 l_PdNumTab    PA_PLSQL_DATATYPES.NumTabTyp;
 l_DocHdrTab   PA_PLSQL_DATATYPES.IdTabTyp;
 l_DocDistTab  PA_PLSQL_DATATYPES.IdTabTyp;
 l_EntDrTab    PA_PLSQL_DATATYPES.NumTabTyp;
 l_EntCrTab    PA_PLSQL_DATATYPES.NumTabTyp;
 l_AcctDrTab   PA_PLSQL_DATATYPES.NumTabTyp;
 l_AcctCrTab   PA_PLSQL_DATATYPES.NumTabTyp;
 l_BcPktTab    PA_PLSQL_DATATYPES.IdTabTyp;
 l_ParBCPktTab PA_PLSQL_DATATYPES.IdTabTyp;
 l_GlDateTab   PA_PLSQL_DATATYPES.DateTabTyp;
 l_PaDateTab   PA_PLSQL_DATATYPES.DateTabTyp;
 l_TxnCCIDTab  PA_PLSQL_DATATYPES.IdTabTyp;
 l_ParResTab   PA_PLSQL_DATATYPES.IdTabTyp;
 l_OrgIdTab    PA_PLSQL_DATATYPES.IdTabTyp;
 l_BurCstFlagTab PA_PLSQL_DATATYPES.Char1TabTyp;
 l_BcCommIdTab PA_PLSQL_DATATYPES.IdTabTyp;
 l_BdgtCCIDTab PA_PLSQL_DATATYPES.IdTabTyp;
 --PA.M
 l_DocLineIdTab PA_PLSQL_DATATYPES.IdTabTyp;
 l_SummRecFlagTab PA_PLSQL_DATATYPES.Char1TabTyp;
 l_PktReference1Tab PA_PLSQL_DATATYPES.Char80TabTyp;
 l_PktReference2Tab PA_PLSQL_DATATYPES.Char80TabTyp;
 l_PktReference3Tab PA_PLSQL_DATATYPES.Char80TabTyp;
 -- R12 Funds Management Uptake
 l_BurMethodcodeTab  PA_PLSQL_DATATYPES.Char30TabTyp;

 --Cursor to select all commitment transactions from pa_bc_commitments_all
 --for a given project_id and the current baselined budget version id. The
 --check for later is because there might be commitments with old budget
 --version id which were funds checked during the delta time.
 --Removing the current baselined budget check as now we are handling that
 --there is only one commitment line for a tx. This is done in the sweeper while
 --moving the delta and new tx. to commitments.
 cursor c_bc_comm(p_project_id in number) is
 select bc.project_id,
       bc.task_id,
       bc.EXPENDITURE_TYPE,
       trunc(bc.EXPENDITURE_ITEM_DATE) expenditure_item_date,
       bc.set_of_books_id,
       bc.je_category_name,
       bc.je_source_name,
       bc.document_type,
       bc.expenditure_organization_id,
       bc.PERIOD_NAME,
       bc.PERIOD_YEAR,
       bc.PERIOD_NUM,
       bc.document_header_id,
       bc.document_distribution_id,
       bc.entered_dr,
       bc.entered_cr,
       bc.accounted_dr,
       bc.accounted_cr,
       bc.bc_packet_id,
       bc.parent_bc_packet_id,
       bc.gl_date,
       bc.pa_date,
       bc.txn_ccid,
       bc.org_id,
       bc.burden_cost_flag,
       bc.bc_commitment_id,
       bc.budget_ccid
       --PA.M
       ,bc.document_line_id
       ,bc.summary_record_flag
       ,bc.reference1
       ,bc.reference2
       ,bc.reference3
       -- R12 Funds Management Uptake
       ,bc.burden_method_code
  from pa_bc_commitments_all bc,
       pa_tasks pt
       --,pa_budget_versions pbv,
       --pa_budget_types pbt
 where bc.project_id = p_project_id
 and   pt.task_id    = bc.task_id;
   --and bc.budget_version_id = pbv.budget_version_id
   --and pbv.current_flag = 'Y'
   --and pbv.budget_status_code = 'B'
   --and pbv.budget_type_code = pbt.budget_type_code
   --and pbt.budget_amount_code = 'C';
   --and bc.budget_version_id = p_budget_version_id;

 BEGIN

  --Initialize the error stack
  PA_DEBUG.set_err_stack('Insert Commitment Txns');

  --Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF P_DEBUG_MODE = 'Y' THEN
     pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'Entering Insert Commitment Txns');
  END IF;

  OPEN c_bc_comm(p_project_id);
  LOOP

    --Initialize pl/sql tables
    l_ProjTab.Delete;
    l_TaskTab.Delete;
    l_ExpTypTab.Delete;
    l_EiDateTab.Delete;
    l_SobTab.Delete;
    l_CatNameTab.Delete;
    l_SrcNameTab.Delete;
    l_DocTypTab.Delete;
    l_ExpOrgTab.Delete;
    l_PeriodTab.Delete;
    l_PdYearTab.Delete;
    l_PdNumTab.Delete;
    l_DocHdrTab.Delete;
    l_DocDistTab.Delete;
    l_EntDrTab.Delete;
    l_EntCrTab.Delete;
    l_AcctDrTab.Delete;
    l_AcctCrTab.Delete;
    l_BcPktTab.Delete;
    l_ParBCPktTab.Delete;
    l_GlDateTab.Delete;
    l_PaDateTab.Delete;
    l_TxnCCIDTab.Delete;
    l_ParResTab.Delete;
    l_OrgIdTab.Delete;
    l_BurCstFlagTab.Delete;
    l_BcCommIdTab.Delete;
    l_BdgtCCIDTab.Delete;
    --PA.M
    l_DocLineIdTab.Delete;
    l_SummRecFlagTab.Delete;
    l_pktReference1Tab.Delete;
    l_pktReference2Tab.Delete;
    l_pktReference3Tab.Delete;
    -- R12 Funds Management Uptake
    l_BurMethodcodeTab.delete;

    IF P_DEBUG_MODE = 'Y' THEN
       pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'Fetch c_bc_comm cursor');
    END IF;

    FETCH c_bc_comm BULK COLLECT INTO
        l_ProjTab,
	l_TaskTab,
        l_ExpTypTab,
        l_EiDateTab,
        l_SobTab,
        l_CatNameTab,
        l_SrcNameTab,
        l_DocTypTab,
        l_ExpOrgTab,
        l_PeriodTab,
        l_PdYearTab,
        l_PdNumTab,
        l_DocHdrTab,
        l_DocDistTab,
        l_EntDrTab,
        l_EntCrTab,
        l_AcctDrTab,
        l_AcctCrTab,
        l_BcPktTab,
        l_ParBCPktTab,
        l_GlDateTab,
        l_PaDateTab,
        l_TxnCCIDTab,
        l_OrgIdTab,
        l_BurCstFlagTab,
        l_BcCommIdTab,
        l_BdgtCCIDTab
        --l_ParResTab
        --Pa.M
        , l_DocLineIdTab
        , l_SummRecFlagTab
        ,l_pktReference1Tab
        ,l_pktReference2Tab
        ,l_pktReference3Tab
         -- R12 Funds Management Uptake
        ,l_BurMethodcodeTab
    LIMIT rows;

    IF l_ProjTab.count = 0 THEN
       IF P_DEBUG_MODE = 'Y' THEN
          pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'No records in c_bc_comm, exit');
       END IF;
       exit;
    END IF;

    --If budgetary control type is CC, then load only contract commitment transactions into
    --pa_bc_packets. Also if budget is linked then consider only open period
    --transactions else consider all transactions.
    IF P_DEBUG_MODE = 'Y' THEN
       pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'No. of rec in c_bc_comm = '|| l_ProjTab.count);
    END IF;

    IF (p_bdgt_ctrl_type = 'CC') THEN

        PA_DEBUG.set_err_stack('CC');   --Bug 3912094
        IF P_DEBUG_MODE = 'Y' THEN
           pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'Bdgt Ctrl = CC');
        END IF;

	-- Insert Contract Commitments
	IF (p_bdgt_intg_flag = 'Y') THEN

            PA_DEBUG.set_err_stack('Insert CC, linked');  --Bug 3912094
            IF P_DEBUG_MODE = 'Y' THEN
               pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'Bdgt Intg Flag = Y');
            END IF;
	    FORALL i in l_ProjTab.FIRST..l_ProjTab.LAST
              insert into pa_bc_packets (
	          PACKET_ID,
		  PROJECT_ID,
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
		  DOCUMENT_TYPE,
	          EXPENDITURE_ORGANIZATION_ID,
		  PERIOD_NAME,
	          PERIOD_YEAR,
	          PERIOD_NUM,
	          DOCUMENT_HEADER_ID,
	          DOCUMENT_DISTRIBUTION_ID,
	          ENTERED_DR,
	          ENTERED_CR,
	          accounted_dr,
	          accounted_cr,
	          BUDGET_VERSION_ID,
	          bc_packet_id,
		  funds_process_mode,
		  parent_bc_packet_id,
		  gl_date,
		  pa_date,
		  txn_ccid,
                  result_code,
                  balance_posted_flag,
                  org_id,
                  burden_cost_flag,
                  bc_commitment_id,
                  old_budget_ccid
                  --PA.M
                  ,document_line_id
                  ,summary_record_flag
		  ,reference1
		  ,reference2
		  ,reference3
       	          -- R12 Funds Management Uptake
                  ,burden_method_code
                  )
              select
		  p_packet_id,
		  l_ProjTab(i),
                  l_TaskTab(i),
                  l_ExpTypTab(i),
                  l_EiDateTab(i),
                  'E',
                  'P',
                  sysdate,
                  FND_GLOBAL.USER_ID,
		  FND_GLOBAL.USER_ID,
		  sysdate,
		  FND_GLOBAL.LOGIN_ID,
                  l_SobTab(i),
                  l_CatNameTab(i),
                  l_SrcNameTab(i),
                  l_DocTypTab(i),
                  l_ExpOrgTab(i),
                  l_PeriodTab(i),
                  l_PdYearTab(i),
                  l_PdNumTab(i),
                  l_DocHdrTab(i),
                  l_DocDistTab(i),
                  l_EntDrTab(i),
                  l_EntCrTab(i),
                  l_AcctDrTab(i),
                  l_AcctCrTab(i),
                  p_budget_version_id,
                  l_BcPktTab(i),
                  'B',
                  l_ParBCPktTab(i),
                  l_GlDateTab(i),
                  l_PaDateTab(i),
                  l_TxnCCIDTab(i),
                  'P',
                  'N',
                  l_OrgIdTab(i),
                  l_BurCstFlagTab(i),
                  l_BcCommIdTab(i),
                  l_BdgtCCIDTab(i)
                  --Pa.M
                  ,l_DocLineIdTab(i)
                  ,l_SummRecFlagTab(i)
		  ,l_pktReference1Tab(i)
        	  ,l_pktReference2Tab(i)
        	  ,l_pktReference3Tab(i)
                  -- R12 Funds Management Uptake
                  ,l_BurMethodcodeTab(i)
	      from gl_period_statuses gl
	     where l_DocTypTab(i) in ('CC_C_CO', 'CC_P_CO')
  	     --and l_GlDateTab(i) = gl.end_date
               and trunc(l_GlDateTab(i)) between trunc(gl.start_date) and trunc(gl.end_date)
               and gl.application_id = 101
               and gl.set_of_books_id = p_sob_id
               and gl.adjustment_period_flag = 'N'
	       and gl.closing_status in ( 'O', 'F');

            for i in l_ProjTab.FIRST..l_ProjTab.LAST loop
              IF P_DEBUG_MODE = 'Y' THEN
                 pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'CC - Y, record count = '|| SQL%BULK_ROWCOUNT(i));
              END IF;
            end loop;

            PA_DEBUG.Reset_Err_Stack;  --3912094
	ELSE

            PA_DEBUG.set_err_stack('Insert CC, no link'); --Bug 3912094
            IF P_DEBUG_MODE = 'Y' THEN
               pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'Bdgt Intg Flag = N');
            END IF;

	    FORALL j in l_ProjTab.FIRST..l_ProjTab.LAST
  	      insert into pa_bc_packets (
	          PACKET_ID,
		  PROJECT_ID,
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
		  DOCUMENT_TYPE,
	          EXPENDITURE_ORGANIZATION_ID,
		  PERIOD_NAME,
	          PERIOD_YEAR,
	          PERIOD_NUM,
	          DOCUMENT_HEADER_ID,
	          DOCUMENT_DISTRIBUTION_ID,
	          ENTERED_DR,
	          ENTERED_CR,
	          accounted_dr,
	          accounted_cr,
	          BUDGET_VERSION_ID,
	          bc_packet_id,
		  funds_process_mode,
		  parent_bc_packet_id,
		  gl_date,
		  pa_date,
		  txn_ccid,
                  result_code,
                  balance_posted_flag,
                  org_id,
                  burden_cost_flag,
                  bc_commitment_id,
                  old_budget_ccid
                  --PA.M
                  ,document_line_id
                  ,summary_record_flag
		  ,reference1
		  ,reference2
		  ,reference3
                  -- R12 Funds Management Uptake
                  ,burden_method_code
                  )
              select
		  p_packet_id,
		  l_ProjTab(j),
                  l_TaskTab(j),
                  l_ExpTypTab(j),
                  l_EiDateTab(j),
                  'E',
                  'P',
                  sysdate,
                  FND_GLOBAL.USER_ID,
		  FND_GLOBAL.USER_ID,
		  sysdate,
		  FND_GLOBAL.LOGIN_ID,
                  l_SobTab(j),
                  l_CatNameTab(j),
                  l_SrcNameTab(j),
                  l_DocTypTab(j),
                  l_ExpOrgTab(j),
                  l_PeriodTab(j),
                  l_PdYearTab(j),
                  l_PdNumTab(j),
                  l_DocHdrTab(j),
                  l_DocDistTab(j),
                  l_EntDrTab(j),
                  l_EntCrTab(j),
                  l_AcctDrTab(j),
                  l_AcctCrTab(j),
                  p_budget_version_id,
                  l_BcPktTab(j),
                  'B',
                  l_ParBCPktTab(j),
                  l_GlDateTab(j),
                  l_PaDateTab(j),
                  l_TxnCCIDTab(j),
                  'P',
                  'N',
                  l_OrgIdTab(j),
                  l_BurCstFlagTab(j),
                  l_BcCommIdTab(j),
                  l_BdgtCCIDTab(j)
                  --Pa.M
                  ,l_DocLineIdTab(j)
                  , l_SummRecFlagTab(j)
		  ,l_pktReference1Tab(j)
        	  ,l_pktReference2Tab(j)
        	  ,l_pktReference3Tab(j)
                  -- R12 Funds Management Uptake
                  ,l_BurMethodcodeTab(j)
	      from dual
	     where l_DocTypTab(j) in ('CC_C_CO', 'CC_P_CO');

            for i in l_ProjTab.FIRST..l_ProjTab.LAST loop
              IF P_DEBUG_MODE = 'Y' THEN
                 pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'CC - N, record count = '|| SQL%BULK_ROWCOUNT(i));
              END IF;
            end loop;

            PA_DEBUG.Reset_Err_Stack;  --3912094
	END IF;
        PA_DEBUG.Reset_Err_Stack;  --3912094

    --If budgetary control type is GL, then load all commitment transactions
    --(AP, PO, REQ, Contract Payments) into pa_bc_packets.
    --Also check if budget is linked then consider only open period
    --transactions else consider all transactions.
    ELSIF (p_bdgt_ctrl_type = ('GL')) THEN

        PA_DEBUG.set_err_stack('GL');   --Bug 3912094
        IF P_DEBUG_MODE = 'Y' THEN
           pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'Bdgt Ctrl Type = GL');
        END IF;

	IF (P_bdgt_intg_flag = 'Y') THEN

           PA_DEBUG.set_err_stack('Insert Std, linked');
           IF P_DEBUG_MODE = 'Y' THEN
              pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'Bdgt Intg Flag = Y');
           END IF;

	   --For Other commitment transactions (AP,PO,REQ,CC_P_PAY,CC_C_PAY)
	   --when there is a link
           FORALL k in l_ProjTab.FIRST..l_ProjTab.LAST
	     insert into pa_bc_packets (
		  PACKET_ID,
		  PROJECT_ID,
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
		  DOCUMENT_TYPE,
	          EXPENDITURE_ORGANIZATION_ID,
	          PERIOD_NAME,
	          PERIOD_YEAR,
	          PERIOD_NUM,
	          DOCUMENT_HEADER_ID,
	          DOCUMENT_DISTRIBUTION_ID,
	          ENTERED_DR,
	          ENTERED_CR,
	          accounted_dr,
	          accounted_cr,
	          BUDGET_VERSION_ID,
	          bc_packet_id,
		  funds_process_mode,
		  parent_bc_packet_id,
		  gl_date,
		  pa_date,
		  txn_ccid,
                  result_code,
                  balance_posted_flag,
                  org_id,
                  burden_cost_flag,
                  bc_commitment_id,
                  old_budget_ccid
                  --PA.M
                  ,document_line_id
                  ,summary_record_flag
		  ,reference1
		  ,reference2
		  ,reference3
                  -- R12 Funds Management Uptake
                  ,burden_method_code
                  )
              select
		  p_packet_id,
		  l_ProjTab(k),
                  l_TaskTab(k),
                  l_ExpTypTab(k),
                  l_EiDateTab(k),
                  'E',
                  'P',
                  sysdate,
                  FND_GLOBAL.USER_ID,
		  FND_GLOBAL.USER_ID,
		  sysdate,
		  FND_GLOBAL.LOGIN_ID,
                  l_SobTab(k),
                  l_CatNameTab(k),
                  l_SrcNameTab(k),
                  l_DocTypTab(k),
                  l_ExpOrgTab(k),
                  l_PeriodTab(k),
                  l_PdYearTab(k),
                  l_PdNumTab(k),
                  l_DocHdrTab(k),
                  l_DocDistTab(k),
                  l_EntDrTab(k),
                  l_EntCrTab(k),
                  l_AcctDrTab(k),
                  l_AcctCrTab(k),
                  p_budget_version_id,
                  l_BcPktTab(k),
                  'B',
                  l_ParBCPktTab(k),
                  l_GlDateTab(k),
                  l_PaDateTab(k),
                  l_TxnCCIDTab(k),
                  'P',
                  'N',
                  l_OrgIdTab(k),
                  l_BurCstFlagTab(k),
                  l_BcCommIdTab(k),
                  l_BdgtCCIDTab(k)
                  --Pa.M
                  ,l_DocLineIdTab(k)
                  , l_SummRecFlagTab(k)
	        ,l_pktReference1Tab(k)
        	,l_pktReference2Tab(k)
        	,l_pktReference3Tab(k)
                -- R12 Funds Management Uptake
                ,l_BurMethodcodeTab(k)
	     from gl_period_statuses gl
 	    where l_DocTypTab(k) in ('AP','PO','REQ','CC_C_PAY','CC_P_PAY')
  	      --and l_GlDateTab(k) = gl.end_date
              and trunc(l_GlDateTab(k)) between trunc(gl.start_date) and trunc(gl.end_date)
              and gl.application_id = 101
              and gl.set_of_books_id = p_sob_id
              and gl.adjustment_period_flag = 'N'
	      and gl.closing_status in ( 'O', 'F');

            for i in l_ProjTab.FIRST..l_ProjTab.LAST loop
              IF P_DEBUG_MODE = 'Y' THEN
                 pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'GL - Y, record count = '|| SQL%BULK_ROWCOUNT(i));
              END IF;
            end loop;
            PA_DEBUG.Reset_Err_Stack;  --3912094
	ELSE

           PA_DEBUG.set_err_stack('Insert Std, no link');
           IF P_DEBUG_MODE = 'Y' THEN
              pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'Bdgt Intg Flag = N');
           END IF;

	   --For Other commitment transactions (AP,PO,REQ,CC_C_PAY,CC_P_PAY)
	   --when there is a link
           FORALL l in l_ProjTab.FIRST..l_ProjTab.LAST
	     insert into pa_bc_packets (
		  PACKET_ID,
		  PROJECT_ID,
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
		  DOCUMENT_TYPE,
	          EXPENDITURE_ORGANIZATION_ID,
	          PERIOD_NAME,
	          PERIOD_YEAR,
	          PERIOD_NUM,
	          DOCUMENT_HEADER_ID,
	          DOCUMENT_DISTRIBUTION_ID,
	          ENTERED_DR,
	          ENTERED_CR,
	          accounted_dr,
	          accounted_cr,
	          BUDGET_VERSION_ID,
	          bc_packet_id,
		  funds_process_mode,
		  parent_bc_packet_id,
		  gl_date,
		  pa_date,
		  txn_ccid,
                  result_code,
                  balance_posted_flag,
                  org_id,
                  burden_cost_flag,
                  bc_commitment_id,
                  old_budget_ccid
                  --PA.M
                  ,document_line_id
                  ,summary_record_flag
		  ,reference1
		  ,reference2
		  ,reference3
                  -- R12 Funds Management Uptake
                  ,burden_method_code
		 )
              select
		  p_packet_id,
		  l_ProjTab(l),
                  l_TaskTab(l),
                  l_ExpTypTab(l),
                  l_EiDateTab(l),
                  'E',
                  'P',
                  sysdate,
                  FND_GLOBAL.USER_ID,
		  FND_GLOBAL.USER_ID,
		  sysdate,
		  FND_GLOBAL.LOGIN_ID,
                  l_SobTab(l),
                  l_CatNameTab(l),
                  l_SrcNameTab(l),
                  l_DocTypTab(l),
                  l_ExpOrgTab(l),
                  l_PeriodTab(l),
                  l_PdYearTab(l),
                  l_PdNumTab(l),
                  l_DocHdrTab(l),
                  l_DocDistTab(l),
                  l_EntDrTab(l),
                  l_EntCrTab(l),
                  l_AcctDrTab(l),
                  l_AcctCrTab(l),
                  p_budget_version_id,
                  l_BcPktTab(l),
                  'B',
                  l_ParBCPktTab(l),
                  l_GlDateTab(l),
                  l_PaDateTab(l),
                  l_TxnCCIDTab(l),
                  'P',
                  'N',
                  l_OrgIdTab(l),
                  l_BurCstFlagTab(l),
                  l_BcCommIdTab(l),
                  l_BdgtCCIDTab(l)
                  --Pa.M
                  , l_DocLineIdTab(l)
                  , l_SummRecFlagTab(l)
		  ,l_pktReference1Tab(l)
        	  ,l_pktReference2Tab(l)
        	  ,l_pktReference3Tab(l)
                  -- R12 Funds Management Uptake
                  ,l_BurMethodcodeTab(l)
	     from dual
	    where l_DocTypTab(l) in ('AP','PO','REQ','CC_C_PAY','CC_P_PAY');

            for i in l_ProjTab.FIRST..l_ProjTab.LAST loop
              IF P_DEBUG_MODE = 'Y' THEN
                 pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'GL - N, record count = '|| SQL%BULK_ROWCOUNT(i));
              END IF;
            end loop;
            PA_DEBUG.Reset_Err_Stack;  --3912094

	END IF;
        PA_DEBUG.Reset_Err_Stack;  --3912094
    END IF;
    commit;
    EXIT WHEN c_bc_comm%NOTFOUND;
  END LOOP;
  CLOSE c_bc_comm;

  PA_DEBUG.set_err_stack('Inserted Commitments');

  IF P_DEBUG_MODE = 'Y' THEN
     pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'Exiting Insert Commitment Txns');
  END IF;

  --Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;
  PA_DEBUG.Reset_Err_Stack; -- Bug 5064900

 EXCEPTION
  WHEN OTHERS THEN
     FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_BGT_BASELINE_PKG'
                   ,p_procedure_name => 'INSERT_COMMITMENT_TXNS'  -- Bug 5064900
		   ,p_error_text => PA_DEBUG.G_Err_Stack );

     IF c_bc_comm%ISOPEN THEN
        close c_bc_comm;
     END IF;

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     x_error_message_code := (SQLCODE||' '||SQLERRM);
     PA_DEBUG.Reset_Err_Stack; -- Bug 5064900
     RAISE;
 END INSERT_COMMITMENT_TXNS;

 ---------------------------------------------------------------------------------------------
 --R12 Funds Management Uptake : As per new logic, fundscheck will be performed only during
 --budget baseline and not during submit.Hence obsoleting this procedure INSERT_DELTA_TXNS
 --which holds logic for performing delta fundscheck of transactions which were
 --fundschecked against submitted budget and having 'C' status code.
 ---------------------------------------------------------------------------------------------

 --(MAIN)
BEGIN

       --Initialize the error stack
       PA_DEBUG.init_err_stack('PA_BGT_BASELINE_PKG.Maintain_Bal_Fchk');

       fnd_msg_pub.initialize;

       --Initialize the return status to success
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       IF P_DEBUG_MODE = 'Y' THEN
          pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'Passed parameters = ' || p_project_id || ':' || p_budget_version_id || ':' || p_bdgt_ctrl_type || ':' || p_calling_mode || ':' || p_bdgt_intg_flag);
       END IF;

       --Bug 6524116
       SELECT org_id INTO l_org_id FROM pa_projects_all WHERE project_id = p_project_id;

       --Select SET OF BOOKS ID
       IF P_DEBUG_MODE = 'Y' THEN
          pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'Before selecting SOB');
       END IF;

       select to_number(set_of_books_id) into l_sob_id from pa_implementations_all --Bug 6524116
       where org_id = l_org_id;

       IF P_DEBUG_MODE = 'Y' THEN
          pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'After selecting SOB = '|| l_sob_id);
       END IF;

 /* =============================================================================================== +
    FOLLOWING CODE MOVED TO PA_BUDGET_FUND_PKG (PABBFNDB.pls)

       --Before start of baselining call sweeper to sweep approved packets sitting in
       --pa_bc_packets
       --Bug 2779986: Run sweeper irrespective of the p_bdgt_ctrl_type
       --Revert Bug 2779986 fix: Sweeper process is to be run only the first time this API is
       --called from PA_BUDGET_FUNDS_PKG. There are 2 calls to this API, first for
       --for p_bdgt_ctrl_type = GL and then for p_bdgt_ctrl_type = CC, hence running the
       --sweeper the first time will suffice as per design.

       if (p_bdgt_ctrl_type = 'GL') then
          pa_sweeper.update_act_enc_balance(
                  x_return_status      => x_return_status,
                  x_error_message_code => x_error_message_code
                  --PA.M
                  ,P_Project_Id         => P_project_id);
       end if;
   ========================================================================================================== */

       --lock pa_bc_balances records for the budget version
       open c_bal_lock;

       --R12 Funds Management Uptake : Deleted logic to pouplate l_reservemode,l_bsnlpkt_id,l_fcreqd
       --and l_deltapktid as these variables are obsolete with new architecture.
       --Budget fundscheck will always be fired with calling mode = 'RESERVE_BASELINE' and fundscheck
       --has to be performed.

 /* =============================================================================================== +
    FOLLOWING CODE MOVED TO PA_BUDGET_FUND_PKG (PABBFNDB.pls)

       IF P_DEBUG_MODE = 'Y' THEN
          pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'Calling Insert BGT Balances');
       END IF;
       PA_DEBUG.set_err_stack('M:Insert BGT Balances');
       --create pa_bc_balances record

       INSERT_BGT_BALANCES(
                p_project_id         => p_project_id,
                p_budget_version_id  => p_budget_version_id,
                p_set_of_books_id    => l_sob_id,
                p_bdgt_intg_flag     => p_bdgt_intg_flag,
                --p_fc_reqd            => l_FcReqd, --R12 Funds Management Uptake : obsolete variable
                x_return_status      => x_return_status,
                x_error_message_code => x_error_message_code );

       IF P_DEBUG_MODE = 'Y' THEN
          pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'After Insert BGT Balances, RetSts = ' || x_return_status);
       END IF;

       PA_DEBUG.Reset_Err_Stack;  --3912094
   ========================================================================================================== */

       PA_DEBUG.set_err_stack('M:Is FC Reqd');

       -- R12 Funds Management Uptake : Obsolete logic to DELETE packets associated with
       -- Draft version Id lying in status 'B'/'R'/'T'.With previous functionality these
       -- records were created if baselining errors for some reason after funds check OR
       -- if user rebaselines.
       -- With new architecture baselining is performed before fundscheck and fundscheck
       -- is fired only during baselining for the newly baselined version.If fundscheck fails
       -- then baselining will be rolled back and hence there wont be any 'B' status data
       -- lying in pa_bc_packets and sweeper will clean the 'R' and 'T' status records.

       -- R12 Funds Management Uptake : Removed check of 'IF fc required'

       -- Get a new packet id
       select gl_bc_packets_s.nextval into l_packet_id from dual;

       IF P_DEBUG_MODE = 'Y' THEN
          pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'PacketId = '|| l_packet_id);
       END IF;

       PA_DEBUG.set_err_stack('M:Create Dir Cost');

       -- Insert commitments into PA_BC_PACKETS
       IF P_DEBUG_MODE = 'Y' THEN
          pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'Calling Insert Commitment Txns');
       END IF;

       INSERT_COMMITMENT_TXNS(
		p_packet_id 	     => l_packet_id,
		p_sob_id	     => l_sob_id,
		p_project_id         => p_project_id,
                p_budget_version_id  => p_budget_version_id,
		p_bdgt_ctrl_type     => p_bdgt_ctrl_type,
		p_bdgt_intg_flag     => p_bdgt_intg_flag,
		x_return_status      => x_return_status,
		x_error_message_code => x_error_message_code);

       IF P_DEBUG_MODE = 'Y' THEN
          pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'After Insert Commitment Txns, RetSts = ' ||x_return_status);
       END IF;
       PA_DEBUG.Reset_Err_Stack;  --3912094

       -- If Budgetary Control is GL then also
       -- insert vendor invoices, expense reports and BTC txns.
       if (p_bdgt_ctrl_type = 'GL') then

               PA_DEBUG.set_err_stack('M:Insert VIERBTC');
               IF P_DEBUG_MODE = 'Y' THEN
                  pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'Calling Insert VI ER BTC');
               END IF;

               INSERT_VI_ER_BTC_TXNS(
                p_packet_id          => l_packet_id,
                p_sob_id             => l_sob_id,
                p_project_id         => p_project_id,
                p_budget_version_id  => p_budget_version_id,
                p_bdgt_intg_flag     => p_bdgt_intg_flag,
                x_return_status      => x_return_status,
                x_error_message_code => x_error_message_code);
                IF P_DEBUG_MODE = 'Y' THEN
                   pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'After Insert VI ER BTC, RetSts = ' ||x_return_status);
                END IF;
                PA_DEBUG.Reset_Err_Stack;  --3912094

        end if;

       -- R12 Funds Management Uptake : Deleted call to main fundscheck API in 'CHECK_BASELINE' mode
       -- R12 Funds Management Uptake : Deleted call to PA_BUDGET_FUND_PKG.Upd_Bdgt_Acct_Bal_No_Fck as
       --                               it will be handled during tieback
       -- R12 Funds Management Uptake : Deleted resrver mode check as this procedure is fired for reserve mode only

       if (p_bdgt_ctrl_type = 'GL') then

            pa_debug.Set_User_Lock_Mode(x_TimeOut => 10);
            --acquire lock
            IF (pa_debug.acquire_user_lock('BSLNFCHKLOCK:'||to_char(p_project_id)) = 0) THEN

                IF P_DEBUG_MODE = 'Y' THEN
                   pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'Acquired lock on Proj ' || p_project_id);
                END IF;
                -- PA_DEBUG.set_err_stack('M:Acquired Lock');  3912094 This is not required

            ELSE

                --Unable to acquire user lock
                IF P_DEBUG_MODE = 'Y' THEN
                   pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'Could not acquire lock');
                END IF;
                -- PA_DEBUG.set_err_stack('M:Could not acquire lock BSLNFCHKLOCK');

                raise ACQUIRE_LOCK_EXCEPTION;

            END IF;

       end if;

       -- R12 Funds Management Uptake : Deleted delta logic as fundscheck will be perfomed only once i.e. during baselining
       -- R12 Funds Management Uptake : Deleted logic to update status_code from 'C' to 'A' . With new architecture
       -- there will be no delta fundscheck and hence no 'C' status.

       PA_DEBUG.set_err_stack('M:FC Reserve Mode');
       IF P_DEBUG_MODE = 'Y' THEN
            pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'Call Funds Check in Reserve Mode');
       END IF;

       --Call Funds Check for the delta transactions
       --in RESERVE_BASELINE mode
       IF PA_FUNDS_CONTROL_PKG.PA_FUNDS_CHECK(
                   p_calling_module  => 'RESERVE_BASELINE',
                   p_conc_flag       => null,
                   p_set_of_book_id  => l_sob_id,
                   p_packet_id       => l_packet_id,
                   p_mode            => 'B',
                   p_partial_flag    => 'N',
                   p_reference1      => p_bdgt_intg_flag,
                   p_reference2      => to_char(p_project_id),
                   p_reference3      => to_char(p_budget_version_id),
                   x_return_status   => l_return_status,
                   x_error_stage     => x_error_stage,
                   x_error_msg       => x_error_msg) then

            IF P_DEBUG_MODE = 'Y' THEN
               pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'FCHK in Reserve Mode called');
            END IF;
            --Call Update Bdgt Acct Lines API

	    -- R12 Funds Management Uptake : Deleted call to PA_FUNDS_CONTROL_PKG.upd_bdgt_encum_bal
	    -- as it will be fired during tieback .

	    -- R12 Funds Management Uptake : Added below update for updating pa_bc_packets with
	    -- uncommited newly created budget version id.

            If l_return_status not in ('F','T') then

	       UPDATE pa_bc_packets
	          SET budget_version_id = p_baselined_budget_version_id
	        WHERE packet_id = l_packet_id
	          AND budget_version_id = p_budget_version_id;

	       -- R12 Funds Management Uptake : Update pa_bc_balances (draft version) with the latest budget version ..

	       UPDATE pa_bc_balances
	          SET budget_version_id = p_baselined_budget_version_id
	        WHERE budget_version_id = p_budget_version_id;

            End If;

            PA_DEBUG.Reset_Err_Stack;  --3912094

            if (l_return_status = 'F') then

               -- PA_DEBUG.set_err_stack('M:Funds Check process in reserve mode returned failure');
                     -- , Stage = '||x_error_stage || ' Msg from Funds Check = '|| x_error_msg);
               IF P_DEBUG_MODE = 'Y' THEN
                  pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'FCHK in Reserve Mode returned failure');
               END IF;

               raise FND_API.G_EXC_ERROR;

            elsif (l_return_status = 'T') then

               -- PA_DEBUG.set_err_stack('M:Funds Check process in reserve mode returned fatal error');
               IF P_DEBUG_MODE = 'Y' THEN
                  pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'FCHK in Reserve Mode returned fatal error');
               END IF;

               raise FND_API.G_EXC_UNEXPECTED_ERROR;

            end if;
            IF P_DEBUG_MODE = 'Y' THEN
               pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'End of FCHK, l_return_status = ' || l_return_status);
            END IF;

       ELSE

            IF P_DEBUG_MODE = 'Y' THEN
               pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'FCHK in Reserve Mode not called');
            END IF;
            -- PA_DEBUG.set_err_stack('M:Funds Check process in reserve mode returned failure');
            raise FND_API.G_EXC_UNEXPECTED_ERROR;

       END IF;


       PA_DEBUG.set_err_stack('M:End of API');
       IF P_DEBUG_MODE = 'Y' THEN
          pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'End of API, RetSts = ' || x_return_status);
       END IF;

       close c_bal_lock;

       --Reset the error stack when returning to the calling program
       PA_DEBUG.Reset_Err_Stack;
       PA_DEBUG.Reset_Err_Stack; -- Bug 5064900
       PA_DEBUG.Reset_Err_Stack; -- Bug 5064900

        /**************************************************
	Sweeper to be called after the tieback API is called
	*************************************************/

       --We need to issue the below explicit commit since this API is
       --in autonomous mode. Or else will encounter ORA-6519 error
       commit;

EXCEPTION
    when resource_busy then
       IF P_DEBUG_MODE = 'Y' THEN
          pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'In resource busy');
       END IF;
       if c_bal_lock%isopen then
          close c_bal_lock ;
       end if;
       PA_DEBUG.Reset_Err_Stack; --Bug 5064900
    WHEN ACQUIRE_LOCK_EXCEPTION THEN
        rollback;
        IF P_DEBUG_MODE = 'Y' THEN
           pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'Cannot Acquire lock BSLNFCHKLOCK for GL');
        END IF;

        FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_BGT_BASELINE_PKG'
                   ,p_procedure_name => 'MAINTAIN_BAL_FCHK'  --Bug 5064900
		   ,p_error_text => PA_DEBUG.G_Err_Stack );

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_error_message_code := 'PA_BC_CANNOT_ACQUIRE_LOCK';

        if c_bal_lock%isopen then
           close c_bal_lock;
        end if;
        PA_DEBUG.Reset_Err_Stack; -- Bug 5064900
	PA_DEBUG.Reset_Err_Stack; -- Bug 5064900
        raise;

    WHEN FND_API.G_EXC_ERROR THEN
           --rollback; this exception raised when FC fails
           commit; -- commit required to commit failure status_code

        IF P_DEBUG_MODE = 'Y' THEN
           pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'Funds check returned failure');
        END IF;

        IF (pa_debug.release_user_lock('BSLNFCHKLOCK:'||to_char(p_project_id)) = 0) THEN
          pa_debug.g_err_stage := '   ' || to_char(p_project_id);
        END IF;

        --When funds check fails due to insufficient funds then
        --we should not add error message to error stack.
        /*FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_BGT_BASELINE_PKG'
                   ,p_procedure_name => PA_DEBUG.G_Err_Stack ); */

        x_return_status := FND_API.G_RET_STS_ERROR;

        if (p_bdgt_ctrl_type = 'GL') then
            x_error_message_code := 'PA_BC_BASELINE_FCHK_FAILED';
        elsif (p_bdgt_ctrl_type = 'CC') then
            x_error_message_code := 'PA_BC_CC_BSLN_FCHK_FAILED';
        end if;

        if c_bal_lock%isopen then
           close c_bal_lock;
        end if;

       PA_DEBUG.Reset_Err_Stack; -- Bug 5064900
       PA_DEBUG.Reset_Err_Stack; -- Bug 5064900

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        If nvl(l_return_status,'P') = 'T' then
           commit; -- FC exception
        Else
           rollback; -- this package exception
        End if;

        IF P_DEBUG_MODE = 'Y' THEN
           pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'Funds check returned fatal error');
        END IF;

        IF (pa_debug.release_user_lock('BSLNFCHKLOCK:'||to_char(p_project_id)) = 0) THEN
          pa_debug.g_err_stage := '   ' || to_char(p_project_id);
        END IF;

        FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_BGT_BASELINE_PKG'
                   ,p_procedure_name => 'MAINTAIN_BAL_FCHK'  -- Bug 5064900
		   ,p_error_text => PA_DEBUG.G_Err_Stack );

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_error_message_code := (SQLCODE||' '||SQLERRM);

        IF P_DEBUG_MODE = 'Y' THEN
           pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || SQLERRM);
        END IF;

        if c_bal_lock%isopen then
           close c_bal_lock;
        end if;
        PA_DEBUG.Reset_Err_Stack; -- Bug 5064900
        PA_DEBUG.Reset_Err_Stack; -- Bug 5064900
        raise;

    WHEN OTHERS THEN
        rollback;
        IF P_DEBUG_MODE = 'Y' THEN
           pa_fck_util.debug_msg('MAINTAIN_BAL_FCHK: ' || 'In others of main');
        END IF;

	FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_BGT_BASELINE_PKG'
                   ,p_procedure_name => 'MAINTAIN_BAL_FCHK'  -- Bug 5064900
		   ,p_error_text => PA_DEBUG.G_Err_Stack );

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        x_error_message_code := (SQLCODE||' '||SQLERRM);

        if c_bal_lock%isopen then
           close c_bal_lock;
        end if;
        PA_DEBUG.Reset_Err_Stack; -- Bug 5064900
        RAISE;

END MAINTAIN_BAL_FCHK;

END PA_BGT_BASELINE_PKG;

/
