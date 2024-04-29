--------------------------------------------------------
--  DDL for Package Body PA_BUDGET_FUND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BUDGET_FUND_PKG" as
-- $Header: PABBFNDB.pls 120.33 2007/12/04 07:41:53 lamalviy ship $

--
-- Procedure            : pa_budget_funds
-- Purpose              : procedure called from budgets forms.
--                        This process will verify if funds check is required
--                        or not. Accordingly the procedure will call gl and/or
--                        cbc funds check procedure for each account summary line
--                        for input budget version id.

--Parameters            :
--                        p_calling_code :  CHECK_FUNDS/CHECK_BASELINE/RESERVE_BASELINE
--                        x_dual_bdgt_cntrl_flag : Y --> Yes, N --> No

CURSOR c_close_period_check( c_set_of_books_id NUMBER, c_budget_version_id NUMBER ) IS
SELECT 'X'
FROM dual
WHERE EXISTS
        (SELECT 'X'
         FROM PA_BUDGET_ACCT_LINES PBA,
              GL_PERIOD_STATUSES       GLS
         WHERE GLS.application_id = PA_Period_Process_Pkg.Application_ID --  101
         AND   GLS.set_of_books_id = c_set_of_books_id
         AND   GLS.period_name = PBA.gl_period_name
         AND   GLS.closing_status not in ('O' , 'F' )
         AND   PBA.curr_ver_available_amount <> PBA.prev_ver_available_amount
         AND   PBA.budget_version_id = c_budget_version_id) ;


-- For R12 Start ------------------------------------------------+
   g_packet_id pa_bc_packets.packet_id%TYPE;
   g_msg_data  VARCHAR2(1000);
   g_procedure_name VARCHAR2(30);
   g_debug_mode     VARCHAR2(10);
   g_draft_bvid     pa_budget_versions.budget_version_id%type;
   g_project_id     pa_projects_all.project_id%type;
   g_org_id         pa_implementations_all.org_id%type; --Bug 6524116

   -- This is an autonomous procedure ...
   PROCEDURE Update_bc_packets_fail(p_bud_ver_id    IN NUMBER,
                                    p_status_code   IN VARCHAR2);
   -- p_status: 'R' (Reject) or 'T' (Fatal)

   -- This is an non-autonomous procedure ...
   PROCEDURE Update_bc_packets_pass(p_bud_ver_id    IN NUMBER);
   -- p_status: 'A' (Pass)

  PROCEDURE ADD_MESSAGE(p_message IN VARCHAR2);

  PROCEDURE LOG_MESSAGE(p_message IN VARCHAR2);

  PROCEDURE DELETE_DRAFT_BC_PACKETS(p_draft_bud_ver_id IN NUMBER);

  -- This procedure is called to determine if any CDLs
  -- that could be burdened have not been burdened
  -- This can lead to burden cost being dropped off during rebaseline

  -- FUNCTION Unburdened_cdl_exists(X_project_id IN Number)
  -- RETURN BOOLEAN;
  -- Defined at Spec level .. accessed from Budget (PAXBUEBU) form ..

  -- This procedure will update the failure code on the draft version
  -- account summary (update only if the lines still have a passed status)
  -- We will pass the status of PSA API ...

  Procedure Fail_draft_acct_summary(p_draft_version_id IN Number,
                                    p_failure_status   IN Varchar2);

-- For R12 End  ------------------------------------------------+

PROCEDURE    cc_funds_chk_rsrv ( p_enc_type_id            IN   NUMBER,
                                 p_budget_version_id      IN   NUMBER,
                                 p_calling_mode           IN   VARCHAR2,
                                 p_balance_type           IN   VARCHAR2,
                                 x_funds_chk_rsrv_status  OUT  NOCOPY VARCHAR2,
                                 x_return_status          OUT  NOCOPY VARCHAR2,
                                 x_msg_count              OUT  NOCOPY NUMBER,
                                 x_msg_data               OUT  NOCOPY VARCHAR2 )
IS


l_cc_funds_resv_fail            EXCEPTION;

l_funds_chk_rsrv_status         VARCHAR2(1);


l_header_id		number; --IGC_CC_INTERFACE.cc_header_id%TYPE ;
l_set_of_books_id	pa_implementations_all.set_of_books_id%type;
l_category_name     	gl_je_categories.user_je_category_name%type ;
l_source_name       	gl_je_sources.user_je_source_name%type;
l_batch_line_num	number; --IGC_CC_INTERFACE.batch_line_num%TYPE ;
l_code_combination_id           gl_code_combinations.code_combination_id%TYPE ;
l_actual_flag                   gl_bc_packets.actual_flag%TYPE ;
l_currency_code                 gl_sets_of_books.currency_code%TYPE ;
l_last_update_date              DATE;
l_last_updated_by               NUMBER(15);
l_creation_date                 DATE;
l_created_by                    NUMBER(15);
l_last_update_login             NUMBER(15);
l_call_mode			VARCHAR2(1) ;
l_ret_code                      boolean ;
--l_result_code                   IGC_CC_INTERFACE.cbc_result_code%TYPE;
l_result_code                   pa_bc_packets.result_code%TYPE;
l_return_status             	VARCHAR2(100) ;
l_msg_index_out                 NUMBER ;
l_chk_res_unres_multi           NUMBER ;

l_period_set_name               VARCHAR2(15);
l_project_num                    pa_projects_all.segment1%type; --Bug 6524116

--PRAGMA AUTONOMOUS_TRANSACTION;--Bug 6524116; Removed as this is causing issue with IGC funds checking.

BEGIN

log_message('Entering cc_funds_chk_rsrv API .........') ;
x_return_status := FND_API.G_RET_STS_SUCCESS;

SELECT imp.set_of_books_id, sob.currency_code, SOB.PERIOD_SET_NAME
INTO  l_set_of_books_id, l_currency_code, l_period_set_name
FROM PA_IMPLEMENTATIONS_all IMP, GL_SETS_OF_BOOKS SOB
where IMP.set_of_books_id = SOB.set_of_books_id
  AND imp.org_id = nvl(g_org_id, imp.org_id);

select user_je_category_name
into  l_category_name
from gl_je_categories
where je_category_name = 'Budget' ;

select user_je_source_name
into l_source_name
from gl_je_sources
where je_source_name = 'Project Accounting' ;

-----------------------------------------------------
-- deriving calling mode
-- l_chk_res_unres_multi is used to switch amounts
-- if the procedure is called i UNRESERVE mode
-----------------------------------------------------
 if ( p_calling_mode = 'CHECK' ) then
  l_call_mode := 'C';
  l_chk_res_unres_multi := 1;
 elsif ( p_calling_mode = 'RESERVE') then
  l_call_mode := 'R';
  l_chk_res_unres_multi := 1;
 elsif ( p_calling_mode = 'UNRESERVE') then
  l_call_mode := 'R';
  l_chk_res_unres_multi := -1;
 -----------------------------------------------------------------
 -- Following code added for Buza Year End Budget Rollover Process
 -----------------------------------------------------------------
 elsif ( p_calling_mode = 'YEAR_END_ROLLOVER') then
  l_call_mode := 'F';
  l_chk_res_unres_multi := 1;
 elsif ( p_calling_mode = 'UNRESERVE_YEAR_END_ROLLOVER') then
  l_call_mode := 'F';
  l_chk_res_unres_multi := -1;
 -----------------------------------------------------------------
 end if;

begin
 delete from IGC_CC_INTERFACE
where cc_header_id = p_budget_version_id
and   document_type = 'PA';
exception
  when no_data_found then
   null;
end;

 log_message('l_call_mode, l_chk_res_unres_multi .........'||l_call_mode||','||l_chk_res_unres_multi) ;

  log_message('l_source_name ... '||l_source_name);
  log_message('l_category_name ... '||l_source_name);
  log_message('l_set_of_books_id ...'||l_set_of_books_id);
  log_message('p_enc_type_id .....'||p_enc_type_id);
  log_message('l_currency_code ...'||l_currency_code);
  log_message('l_period_set_name ...'||l_period_set_name);
  log_message('p_budget_version_id .. '||p_budget_version_id);

-- added for bug 1824164
 log_message('updated pa_budget_acct_lines table with accounted_amount ');

/* Commented for bug 3039985
 UPDATE PA_BUDGET_ACCT_LINES PBA
 SET PBA.accounted_amount  = nvl(PBA.curr_ver_available_amount,0) - nvl(PBA.prev_ver_available_amount,0)
 WHERE PBA.budget_version_id = p_budget_version_id; */

/* Added for bug 3039985 */
  UPDATE PA_BUDGET_ACCT_LINES PBA
 SET PBA.accounted_amount  = nvl(PBA.curr_ver_budget_amount,0) - nvl(PBA.prev_ver_budget_amount,0)
 WHERE PBA.budget_version_id = p_budget_version_id;

 log_message('rows updated .........'||to_char(sql%rowcount)) ;

  --Bug 6524116
  select segment1
  into l_project_num
  from pa_projects_all p,
       pa_budget_versions bv
  where p.project_id = bv.project_id
    and bv.budget_version_id = p_budget_version_id;

 log_message('inserting into table IGC_CC_INTERFACE ..... ');

Insert INTO IGC_CC_INTERFACE (
   CC_HEADER_ID               ,
   DOCUMENT_TYPE              ,
   CODE_COMBINATION_ID        ,
   PERIOD_SET_NAME        ,
   PERIOD_NAME        ,
   BATCH_LINE_NUM             ,
   CC_TRANSACTION_DATE	      ,
   CC_FUNC_CR_AMT	      , --Bug 6633262
   CC_FUNC_DR_AMT	      ,
   JE_SOURCE_NAME             ,
   JE_CATEGORY_NAME           ,
   ACTUAL_FLAG                ,
   BUDGET_DEST_FLAG	      ,
   SET_OF_BOOKS_ID            ,
   ENCUMBRANCE_TYPE_ID        ,
   CURRENCY_CODE              ,
   REFERENCE_1                 ,
   REFERENCE_2                 ,
   REFERENCE_3                 ,
   REFERENCE_4                 ,
   REFERENCE_5                 ,
   creation_date	      ,
   created_by		      ,
   LAST_UPDATE_DATE           ,
   LAST_UPDATED_BY            ,
   CC_ACCT_LINE_ID
   )
  SELECT
 p_budget_version_id,
 'PA',
 PBA.code_combination_id,
 l_period_set_name,
 PBA.gl_period_name,
 to_number(rownum),
 PBA.start_date ,
 --Bug 6524116 Changed 0 to NULL
 decode(GL.account_type,    -- CC_FUNC_CR_AMT column
                'A',decode(sign(PBA.accounted_amount * l_chk_res_unres_multi ),
                            1, (PBA.accounted_amount * l_chk_res_unres_multi ),
                           -1, NULL),
                'E',decode(sign(PBA.accounted_amount * l_chk_res_unres_multi ),
                            1, (PBA.accounted_amount * l_chk_res_unres_multi ),
                           -1, NULL),
                'L',decode(sign(PBA.accounted_amount * l_chk_res_unres_multi ),
                            1, NULL ,
                           -1,abs(PBA.accounted_amount * l_chk_res_unres_multi )),
                'R',decode(sign(PBA.accounted_amount * l_chk_res_unres_multi ),
                            1, NULL ,
                           -1,abs(PBA.accounted_amount * l_chk_res_unres_multi )),
                'O',decode(sign(PBA.accounted_amount * l_chk_res_unres_multi ),
                            1, NULL ,
                           -1,abs(PBA.accounted_amount * l_chk_res_unres_multi )),
                NULL ),
 decode(GL.account_type,    -- CC_FUNC_DR_AMT column
                'A',decode(sign(PBA.accounted_amount * l_chk_res_unres_multi ),
                           -1,abs(PBA.accounted_amount * l_chk_res_unres_multi ),
                            1, NULL),
                'E',decode(sign(PBA.accounted_amount * l_chk_res_unres_multi ),
                           -1,abs(PBA.accounted_amount * l_chk_res_unres_multi ),
                            1, NULL),
                'L',decode(sign(PBA.accounted_amount * l_chk_res_unres_multi ),
                           -1, NULL ,
                            1,PBA.accounted_amount * l_chk_res_unres_multi ),
                'R',decode(sign(PBA.accounted_amount * l_chk_res_unres_multi ),
                           -1, NULL ,
                            1,PBA.accounted_amount * l_chk_res_unres_multi ),
                'O',decode(sign(PBA.accounted_amount * l_chk_res_unres_multi ),
                           -1, NULL ,
                            1,PBA.accounted_amount * l_chk_res_unres_multi ),

                NULL ),
-- l_source_name,
-- l_category_name,
   'Project Accounting',
   'Budget',
 'E' ,
 'C' ,
 l_set_of_books_id,
 p_enc_type_id ,
 l_currency_code ,
 'PA',
 p_budget_version_id,
 PBA.budget_acct_line_id,
 l_project_num, --Bug 6524116
 null,
 sysdate,
 fnd_global.user_id,
 sysdate,
 fnd_global.user_id,
 pba.budget_acct_line_id
FROM
     PA_BUDGET_ACCT_LINES PBA,
     GL_PERIOD_STATUSES GP,
     GL_CODE_COMBINATIONS   GL
WHERE  PBA.accounted_amount <> 0
AND    PBA.budget_version_id = p_budget_version_id
AND    GL.code_combination_id = PBA.code_combination_id
AND    GP.set_of_books_id = l_set_of_books_id
AND    GP.period_name = PBA.gl_period_name
AND    GP.application_id = PA_Period_Process_Pkg.Application_ID; -- 101

/* AND    GP.closing_status in ('O','F') ;  Commented out period status check. for Bug 2950493 */

log_message('rows inserted  into IGC Table .. '||sql%rowcount);
--  Call the CC Funds Check FUnction by passing the packet_id

--    IF   (p_calling_mode = 'CHECK_FUNDS' )   THEN

-- R12 Funds management Uptake: Commenting out the call to procedure which is obsolete in R12
-- Currently CBC is not supported in R12 , hence this will never get fired.
    l_ret_code:=
     IGC_CBC_FUNDS_CHECKER.igcfck(p_sobid               => l_set_of_books_id   ,
                                  p_header_id            => p_budget_version_id,
                                  p_mode                => l_call_mode,
                                  p_actual_flag		=> 'E' ,
                                  p_doc_type		=> 'PA' ,
                                  p_ret_status		=> l_return_status,
                                  p_batch_result_code	=> l_result_code );


log_message(' l_return_status '||l_return_status);
log_message(' l_result_code '||l_result_code);
log_message(' get mesage  '||fnd_msg_pub.get(1));


     -- Update the PA_BUDGET_ACCT_LINES table from the CC Funds Check Results
     UPDATE PA_BUDGET_ACCT_LINES PBA
     SET (PBA.funds_check_status_code,
          PBA.funds_check_result_code) = (SELECT ICC.status_code,
                                                ICC.cbc_result_code
                                         FROM   IGC_CC_INTERFACE ICC
                                         WHERE ICC.DOCUMENT_TYPE = 'PA'
                                         AND   ICC.CC_HEADER_ID  = p_budget_version_id
                                         AND   ICC.reference_1 = 'PA'
                                         AND   ICC.reference_2 = PBA.budget_version_id
                                         AND  ICC.reference_3 = PBA.budget_acct_line_id)
    WHERE ((PBA.budget_version_id,
            PBA.budget_acct_line_id) IN
                        (SELECT ICC.reference_2,
                                ICC.reference_3
                         FROM   IGC_CC_INTERFACE ICC
                         WHERE ICC.cc_header_id = p_budget_version_id
                         AND   ICC.DOCUMENT_TYPE = 'PA'
                         AND   ICC.reference_1 = 'PA')) ;
log_message('rows updated   into PA_BUDGET_ACCT_LINES Table .. '||sql%rowcount);

   --   x_funds_chk_rsrv_status = Decode(l_ret_code,
   -- Funds Check Return Code for the Packet processed. Valid Return Codes
    -- are : 'S' for Success, 'A' for Advisory, 'F' for Failure, 'P' for Partial,
   -- and 'T' for Fatal

 SELECT decode(p_calling_mode,'CHECK',
                                (decode(substr(l_return_status,1,1),'S','P',
                                                      'A','P',
                                                      'F','F',
                                                      'T','F' )),
                                'RESERVE',
                                (decode(substr(l_return_status,1,1),'S','A',
                                                      'A','A',
                                                      'F','F',
                                                      'T','F' )),
                                'UNRESERVE',
                                (decode(substr(l_return_status,1,1),'S','A',
                                                      'A','A',
                                                      'F','F',
                                                      'T','F' )),
                                'YEAR_END_ROLLOVER',
                                (decode(substr(l_return_status,1,1),'S','A',
                                                      'A','A',
                                                      'F','F',
                                                      'T','F' )),
                                'UNRESERVE_YEAR_END_ROLLOVER',
                                (decode(substr(l_return_status,1,1),'S','A',
                                                      'A','A',
                                                      'F','F',
                                                      'T','F' )),
                                 'F')
  INTO  l_funds_chk_rsrv_status
  FROM dual ;

--commit;--Bug 6524116; Removed as this is causing issue with IGC funds checking.

  x_funds_chk_rsrv_status := l_funds_chk_rsrv_status;

log_message('l_funds_chk_rsrv_status ... '||l_funds_chk_rsrv_status);
  if ( l_funds_chk_rsrv_status = 'F' ) then
   raise l_cc_funds_resv_fail;
  end if;

EXCEPTION
   WHEN  l_cc_funds_resv_fail THEN
    PA_UTILS.Add_Message('PA', 'PA_BC_CC_FNDS_RESV_FAIL');
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data :=  'PA_BC_CC_FNDS_RESV_FAIL';
    x_msg_count := 1;
 WHEN OTHERS THEN
log_message('Error in cc_funds_chk_rsrv ... '||SQLERRM);
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   x_msg_count := 1;
   x_msg_data := substr(SQLERRM,1,240);
   FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_BUDGET_FUND_PKG',
      p_procedure_name   => 'cc_funds_chk_rsrv');
   raise;

END cc_funds_chk_rsrv;

 -- ------------------------------------------------------------------------ +
 -- zero $ budget lines cannot be created in pa_bgt_baseline_pkg as it is
 -- not visible in the AUTONOMOUS package

 PROCEDURE Create_txn_lines_in_bc_balance(
                p_project_id         in number,
                p_draft_budget_version_id  in number,
                p_set_of_books_id    in number,
                p_bdgt_intg_flag     in varchar2,
                x_return_status      out NOCOPY varchar2,
                x_error_message_code out NOCOPY varchar2) is

 PRAGMA AUTONOMOUS_TRANSACTION;

 l_start_date  date;
 l_end_date    date;
 l_tab_count   number := 0;
 l_tab_periods PA_FUNDS_CONTROL_UTILS.tab_closed_period;

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
        (p_bdgt_ctrl_type = 'GL' and pbco.external_budget_code is null)
       or
        (p_bdgt_ctrl_type is null and pbco.external_budget_code is null))
 and   a.project_id = p_project_id;

 -- who variables ..
 l_date     date;
 l_login_id number;
 BEGIN
  g_procedure_name := 'Create_txn_lines_in_bc_balance';
  log_message('Create_txn_lines_in_bc_balance:Start');

   --Initialize the return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

  log_message('Create_txn_lines_in_bc_balance: Is it a re-baseline:'||g_cost_rebaseline_flag);

  If ( g_processing_mode = 'BASELINE' and g_cost_rebaseline_flag = 'Y') then
     log_message('Create_txn_lines_in_bc_balance:Before calling Sweeper');

     If g_external_link = 'GL' then
      PA_SWEEPER.UPDATE_ACT_ENC_BALANCE(
            x_return_status      => x_return_status,
            x_error_message_code => x_error_message_code,
            p_project_id         => p_project_id);

     End if;

     log_message('Create_txn_lines_in_bc_balance:After calling Sweeper,RetSts = '||x_return_status);

     If x_return_status <> FND_API.G_RET_STS_SUCCESS then
        GOTO no_processing;
     End If;
 End If;

     --Delete all records for the passed draft budget version id
     --This is to make sure that existing balance records for the draft version id due to
     --a failure in the budget baselining process will be deleted
     log_message('Create_txn_lines_in_bc_balance:'|| 'Delete draft budget version- '||p_draft_budget_version_id);

     Delete pa_bc_balances
     where  budget_version_id = p_draft_budget_version_id;

     log_message('Create_txn_lines_in_bc_balance:'||SQL%ROWCOUNT||' records deleted from pa_bc_balances');

 -- -------------------------------------------------------------------------------------------------+
 IF (g_processing_mode = 'BASELINE' and g_cost_rebaseline_flag = 'Y') then -- II

     -- Bug 5379210 : Deleting pa_bc_packets for draft version
     Delete pa_bc_packets
     where  budget_version_id = p_draft_budget_version_id;

     log_message('Create_txn_lines_in_bc_balance:'||SQL%ROWCOUNT||' records deleted from pa_bc_packets');

     log_message('Create_txn_lines_in_bc_balance: Last baselined version:'||g_cost_prev_bvid);

   --If there is a baselined version then we delete balance records for versions prior to this version
   IF (g_cost_prev_bvid is not null) THEN

       log_message('Create_txn_lines_in_bc_balance: Open cursor c_delbal to delete old verisons of budget');

      OPEN c_delbal(g_external_link,g_cost_prev_bvid);
      LOOP

        l_BalRowIdTab.Delete;

        FETCH c_delbal bulk collect into
           l_BalRowIdTab
        limit 1000;

        if l_BalRowIdTab.count = 0 then
            log_message('Create_txn_lines_in_bc_balance: No record to delete, exit');
           exit;
        end if;

        log_message('Create_txn_lines_in_bc_balance:'||l_BalRowIdTab.count||' records being deleted');

        FORALL j in l_BalRowIdTab.first..l_BalRowIdTab.last
           delete from pa_bc_balances
           where rowid = l_BalRowIdTab(j);

        exit when c_delbal%notfound;
      END LOOP;
      CLOSE c_delbal;

      log_message('Create_txn_lines_in_bc_balance: Closed cursor:c_delbal');

   END IF;

 End If; -- IF (p_calling_mode = 'RESERVE_BASELINE' and g_cost_rebaseline_flag = 'Y') then -- II
 -- -------------------------------------------------------------------------------------------------+

   IF (p_bdgt_intg_flag = 'Y') THEN
          log_message('Create_txn_lines_in_bc_balance:Bdgt Intg Flag = Y');

         Begin
           select  min(start_date), max(end_date)
             into  l_start_date, l_end_date
             from  pa_bc_balances
            where  project_id = p_project_id
              and  budget_version_id = g_cost_prev_bvid;
         Exception
           when no_data_found then
              null;
         End;

         log_message('Create_txn_lines_in_bc_balance:Start Date,End Date = '|| l_start_date ||', '||l_end_date);
         log_message('Create_txn_lines_in_bc_balance:Calling get gl periods');

         --Get all periods given the start and end date.
         PA_FUNDS_CONTROL_UTILS.get_gl_periods
               (p_start_date      => l_start_date,
                p_end_date        => l_end_date,
                p_set_of_books_id => p_set_of_books_id,
                x_tab_count       => l_tab_count,
                x_tab_pds         => l_tab_periods,
                x_return_status   => x_return_status);

         log_message('Create_txn_lines_in_bc_balance:After calling get gl periods,RetSts = '||x_return_status);
         log_message('Create_txn_lines_in_bc_balance:Insert Close Period Balances, TabCount = '||l_tab_count);

         If x_return_status <> FND_API.G_RET_STS_SUCCESS then
            log_message('Create_txn_lines_in_bc_balance: PA_FUNDS_CONTROL_UTILS.get_gl_periods failed');
            GOTO no_processing;
         End If;

            l_login_id := FND_GLOBAL.LOGIN_ID;
            l_date     := SYSDATE;

            FOR i in 1..l_tab_count LOOP
                log_message('Create_txn_lines_in_bc_balance:St,End and Status = ' ||l_tab_periods(i).start_date||':'||
                l_tab_periods(i).end_date||':'||l_tab_periods(i).closing_status);

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
                    p_draft_budget_version_id,
                    l_date,
                    l_login_id,
                    l_login_id,
                    l_date,
                    l_login_id,
                    bal.PERIOD_NAME,
                    bal.START_DATE,
                    bal.END_DATE,
                    bal.PARENT_MEMBER_ID,
                    bal.ACTUAL_PERIOD_TO_DATE,
                    bal.ENCUMB_PERIOD_TO_DATE
                from  pa_bc_balances bal
                where budget_version_id = g_cost_prev_bvid
                and   trunc(start_date) = trunc(l_tab_periods(i).start_date)
                and   trunc(end_date)   = trunc(l_tab_periods(i).end_date)
                and   l_tab_periods(i).closing_status = 'C'
                and   project_id = p_project_id
                and   balance_type <> 'BGT';

            log_message('Create_txn_lines_in_bc_balance:'||SQL%ROWCOUNT||' records inserted');

            END LOOP;

            log_message('Create_txn_lines_in_bc_balance: Inserted closed period balances');

   END IF; --    IF (p_bdgt_intg_flag = 'Y') THEN

 <<no_processing>>
   log_message('Create_txn_lines_in_bc_balance: Commit');
   commit;

   log_message('Create_txn_lines_in_bc_balance: End');

 EXCEPTION
  WHEN OTHERS THEN
     FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_BUDGET_FUND_PKG'
                   ,p_procedure_name => PA_DEBUG.G_Err_Stack );

     IF c_delbal%ISOPEN THEN
        close c_delbal;
     END IF;

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     x_error_message_code := (SQLCODE||' '||SQLERRM);
     log_message('Create_txn_lines_in_bc_balance: x_error_message_code'||x_error_message_code);
     RAISE;
 END Create_txn_lines_in_bc_balance;

 PROCEDURE Create_bgt_lines_in_bc_balance(
                p_set_of_books_id    in number,
                p_budget_version_id  in number,
                p_project_id         in number,
                t_task_id            in PA_PLSQL_DATATYPES.IdTabTyp,
                t_top_task_id        in PA_PLSQL_DATATYPES.IdTabTyp,
                t_rlmi               in PA_PLSQL_DATATYPES.IdTabTyp,
                t_parent_rlmi        in PA_PLSQL_DATATYPES.IdTabTyp,
                t_period             in PA_PLSQL_DATATYPES.Char30TabTyp,
                t_start_date         in PA_PLSQL_DATATYPES.DateTabTyp,
                t_end_date           in PA_PLSQL_DATATYPES.DateTabTyp,
                t_burden_cost        in PA_PLSQL_DATATYPES.NumTabTyp,
                x_ret_status         out NOCOPY varchar2,
                x_err_message_code   out NOCOPY varchar2) is

 PRAGMA AUTONOMOUS_TRANSACTION;

 -- who variables ..
 l_date     date;
 l_login_id number;

 Begin
   g_procedure_name := 'Create_bgt_lines_in_bc_balance';
   log_message('Create_bgt_lines_in_bc_balance: Start');
   l_login_id := FND_GLOBAL.LOGIN_ID;
   l_date     := SYSDATE;
   x_ret_status := FND_API.G_RET_STS_SUCCESS;

    FORALL i in t_task_id.FIRST..t_task_id.LAST
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
            values(
                p_project_id,
                t_task_id(i),
                t_top_task_id(i),
                t_rlmi(i),
                'BGT',
                p_set_of_books_id,
                p_budget_version_id,
                l_date,
                l_login_id,
                l_login_id,
                l_date,
                l_login_id,
                t_period(i),
                t_start_date(i),
                t_end_date(i),
                t_parent_rlmi(i),
                t_burden_cost(i),
                0,
                0);
   log_message('Create_bgt_lines_in_bc_balance: End');
COMMIT;
 EXCEPTION
  WHEN OTHERS THEN
     FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_BUDGET_FUND_PKG'
                   ,p_procedure_name => PA_DEBUG.G_Err_Stack );

     x_ret_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     x_err_message_code := (SQLCODE||' '||SQLERRM);
     log_message('Create_bgt_lines_in_bc_balance: x_err_message_code'||x_err_message_code);
     RAISE;
 End Create_bgt_lines_in_bc_balance;

 PROCEDURE Establish_bc_balances(
                p_project_id         in number,
                p_draft_budget_version_id  in number,
                p_base_budget_version_id in number,
                p_bdgt_intg_flag     in varchar2,
                x_return_status      out NOCOPY varchar2,
                x_error_message_code out NOCOPY varchar2) is

 --Cursor to select BGT budget balances from pa_budget_lines,etc.
 cursor c_bdgt_bal is
 select pa.task_id,
        pt.top_task_id,
        pa.resource_list_member_id,
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
 where pbv.budget_version_id = p_base_budget_version_id
 and   pa.resource_assignment_id = pb.resource_assignment_id
 and   pa.task_id = pt.task_id (+)
 and   pa.budget_version_id = pbv.budget_version_id
 and   rm.resource_list_member_id = pa.resource_list_member_id;

 --Tables to insert BGT lines into pa_bc_balances.
 l_TaskTab    PA_PLSQL_DATATYPES.IdTabTyp;
 l_TTaskTab   PA_PLSQL_DATATYPES.IdTabTyp;
 l_RlmiTab    PA_PLSQL_DATATYPES.IdTabTyp;
 l_PeriodTab  PA_PLSQL_DATATYPES.Char30TabTyp;
 l_StDateTab  PA_PLSQL_DATATYPES.DateTabTyp;
 l_EdDateTab  PA_PLSQL_DATATYPES.DateTabTyp;
 l_ParMemTab  PA_PLSQL_DATATYPES.IdTabTyp;
 l_BurdCostTab PA_PLSQL_DATATYPES.NumTabTyp;

 l_sob_id pa_implementations_all.set_of_books_id%TYPE;

 BEGIN
  g_procedure_name := 'Establish_bc_balances';
  log_message('Establish_bc_balances:Start');

   --Initialize the return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   log_message('Establish_bc_balances: Get SOB_ID');

   select to_number(set_of_books_id) into l_sob_id from pa_implementations_all
   where org_id = g_org_id;

   log_message('Establish_bc_balances: SOB_ID:'||l_sob_id);

   log_message('Establish_bc_balances: Before calling Create_txn_lines_in_bc_balance');

   CREATE_TXN_LINES_IN_BC_BALANCE(
                p_project_id               => p_project_id,
                p_draft_budget_version_id  => p_draft_budget_version_id,
                p_set_of_books_id          => l_sob_id,
                p_bdgt_intg_flag           => p_bdgt_intg_flag,
                x_return_status            => x_return_status,
                x_error_message_code       => x_error_message_code);

   g_procedure_name := 'Establish_bc_balances';
   log_message('Establish_bc_balances: After calling Create_txn_lines_in_bc_balance,RetSts = '||x_return_status);


   --Insert BGT lines.
         log_message('Establish_bc_balances: Before inserting BGT lines');

   open c_bdgt_bal;
   loop
     l_TaskTab.Delete;
     l_TTaskTab.Delete;
     l_RlmiTab.Delete;
     l_PeriodTab.Delete;
     l_StDateTab.Delete;
     l_EdDateTab.Delete;
     l_ParMemTab.Delete;
     l_BurdCostTab.Delete;

     log_message('Establish_bc_balances: Fetch c_bdgt_bal');

      fetch c_bdgt_bal bulk collect into
            l_TaskTab,
            l_TTaskTab,
            l_RlmiTab,
            l_PeriodTab,
            l_StDateTab,
            l_EdDateTab,
            l_ParMemTab,
            l_BurdCostTab
      limit 1000;

      IF (l_TaskTab.count = 0) THEN
          log_message('Establish_bc_balances: No rec in c_bdgt_bal, exit');
          EXIT;
      END IF;

      log_message('Establish_bc_balances: Before Insert, no. of rec = '|| l_TaskTab.count);

      log_message('Establish_bc_balances: Before calling Create_bgt_lines_in_bc_balance');


       CREATE_BGT_LINES_IN_BC_BALANCE(
                p_set_of_books_id    => l_sob_id,
                p_budget_version_id  => p_draft_budget_version_id,
                p_project_id         => p_project_id,
                t_task_id            => l_TaskTab,
                t_top_task_id        => l_TTaskTab,
                t_rlmi               => l_RlmiTab,
                t_parent_rlmi        => l_ParMemTab,
                t_period             => l_PeriodTab,
                t_start_date         => l_StDateTab,
                t_end_date           => l_EdDateTab,
                t_burden_cost        => l_BurdCostTab,
                x_ret_status         => x_return_status,
                x_err_message_code   => x_error_message_code);

       g_procedure_name := 'Establish_bc_balances';
       log_message('Establish_bc_balances: After calling Create_bgt_lines_in_bc_balance,RetSts = '||x_return_status);
      exit when c_bdgt_bal%notfound;
   end loop;
   close c_bdgt_bal;

   log_message('Establish_bc_balances: End');

 EXCEPTION
  WHEN OTHERS THEN
     FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_BUDGET_FUND_PKG'
                   ,p_procedure_name => PA_DEBUG.G_Err_Stack );

     IF c_bdgt_bal%ISOPEN THEN
        close c_bdgt_bal;
     END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     x_error_message_code := (SQLCODE||' '||SQLERRM);
     log_message('Establish_bc_balances: x_error_message_code'||x_error_message_code);
     RAISE;
 END Establish_bc_balances;
 -- zero $ budget lines fix ..
 -- ------------------------------------------------------------------------ +

-- -------------------------------------------------------------------+
-- This is the main procedure called from budget integration/workflow
-- -------------------------------------------------------------------+
PROCEDURE check_or_reserve_funds ( p_project_id      IN   NUMBER,
                            p_budget_version_id      IN   NUMBER,
                            p_calling_mode           IN   VARCHAR2,
                            x_dual_bdgt_cntrl_flag   OUT  NOCOPY VARCHAR2,
                            x_cc_budget_version_id   OUT  NOCOPY NUMBER,
                            x_return_status          OUT  NOCOPY VARCHAR2,
                            x_msg_count              OUT  NOCOPY NUMBER,
                            x_msg_data               OUT  NOCOPY VARCHAR2 )
IS

l_budget_processing_failure      EXCEPTION;

l_top_down_bdgt_failed		EXCEPTION;

l_dual_mode_acct_gen_failed     EXCEPTION;
l_dual_bc_fc_failed             EXCEPTION;
l_cbc_not_supported             EXCEPTION;

l_draft_budget_version_id       PA_BUDGET_VERSIONS.budget_version_id%TYPE;
l_cc_draft_budget_version_id    PA_BUDGET_VERSIONS.budget_version_id%TYPE;
l_total_cc_bdgt_amount          PA_BUDGET_LINES.burdened_cost%TYPE ;
l_total_gl_bdgt_amount          PA_BUDGET_LINES.burdened_cost%TYPE ;
l_rebaseline_flag               VARCHAR2(1);
l_cc_budget_type_code           VARCHAR2(30) ;
l_cc_encumbrance_type_id        NUMBER ;

l_funds_chk_rsrv_status         VARCHAR2(1);
l_calling_module                VARCHAR2(20);

l_budget_type_code          	PA_BUDGET_VERSIONS.budget_type_code%TYPE ;
l_balance_type              	PA_BUDGETARY_CONTROL_OPTIONS.Balance_type%TYPE ;
l_external_budget_code      	PA_BUDGETARY_CONTROL_OPTIONS.External_budget_code%TYPE ;
l_encumbrance_Type_Id       	PA_BUDGETARY_CONTROL_OPTIONS.Encumbrance_Type_Id%TYPE ;
l_bdgt_cntrl_flag         	PA_BUDGETARY_CONTROL_OPTIONS.Bdgt_cntrl_flag%TYPE ;
l_budget_type               	PA_BUDGETARY_CONTROL_OPTIONS.budget_type_code%TYPE ;
l_budget_amount_code            PA_BUDGET_TYPES.Budget_amount_code%TYPE;
l_budget_entry_level_code       PA_Budget_Entry_Methods.entry_level_code%TYPE;

l_dual_bdgt_cntrl_flag      VARCHAR2(1);
l_cc_budget_version_id      NUMBER;
l_gl_budget_version_id      NUMBER;
l_return_status             VARCHAR2(1) ;
t_return_status             VARCHAR2(1) ;
l_msg_count                 NUMBER ;
l_msg_data                  VARCHAR2(240) ;
l_dummy                     number;
l_sqlerrm                   VARCHAR2(4000);
l_request_id                NUMBER;
l_template_flag             pa_projects_all.template_flag%type;
--Bug 6524116
l_cc_budget_entry_level_code    VARCHAR2(30) ;
P_prev_budget_version_id    number;
rejected_event_id_tab       PSA_FUNDS_CHECKER_PKG.num_rec;
ledger_id_tab               PSA_FUNDS_CHECKER_PKG.num_rec;

CURSOR c_budget_sum_amt(c_budget_version_id NUMBER) IS
SELECT sum(decode(nvl(PBL.burdened_cost,0),
                       0,nvl(PBL.raw_cost,0),
                       PBL.burdened_cost))
FROM PA_BUDGET_LINES PBL,
     PA_BUDGET_VERSIONS PBV,
     PA_RESOURCE_ASSIGNMENTS PRA
WHERE    PBV.project_id = p_project_id
AND      PBV.budget_version_id = PRA.budget_version_id
AND      PRA.resource_assignment_id = PBL.resource_assignment_id
AND      PBV.budget_version_id  = c_budget_version_id;


Cursor c_Budget_funds is
    Select  PBV.Budget_type_code,
            PBCO.Balance_type,
            PBCO.External_budget_code,
            PBCO.Encumbrance_Type_Id,
            PBCO.Bdgt_cntrl_flag,
            PBCO.gl_budget_version_id,
	    PBT.budget_amount_code,
            BEM.entry_level_code
    From    PA_BUDGETARY_CONTROL_OPTIONS    PBCO ,
            PA_BUDGET_VERSIONS              PBV,
            PA_BUDGET_TYPES                 PBT,
            PA_BUDGET_ENTRY_METHODS         BEM
    WHERE   PBCO.Project_Id = p_project_id
    AND     PBV.Budget_version_id = p_Budget_version_id
    AND     PBV.Budget_Type_Code = PBCO.Budget_Type_Code
    AND     PBT.Budget_type_code = PBV.Budget_type_code
    AND     PBT.Budget_type_code = PBV.Budget_type_code
    AND     BEM.Budget_Entry_Method_Code = PBV.Budget_Entry_Method_Code;

--Bug 6524116
cursor get_rejected_event_id is
  select bc_event_id, g_org_id
  from pa_budget_lines
  where budget_version_id = P_Budget_version_id
    and bc_event_id is not null
  union
  select bc_rev_event_id, g_org_id
  from pa_budget_lines
  where budget_version_id = P_prev_budget_version_id
    and bc_rev_event_id is not null;

BEGIN

 --x_return_status := FND_API.G_RET_STS_SUCCESS;
 --l_return_status := FND_API.G_RET_STS_SUCCESS; /*Bug 3794994 */

-----------------------------------------------+
-- 0.0: initalize ...
-----------------------------------------------+
 g_procedure_name := 'check_or_reserve_funds';
 g_project_id := p_project_id;

 fnd_profile.get('PA_DEBUG_MODE',g_debug_mode);

 g_debug_mode := nvl(g_debug_mode,'N');

 --- Initialize the error statck
     PA_DEBUG.init_err_stack ('PA_BUDGET_FUND_PKG.check_or_reserve_funds');

     log_message('Entering check_or_reserve_funds API .........') ;

-- ----------------------------------------------------------------------+
-- Check if the project is a template project, if so exit with success ..
-- You should not call FC for template project ...
-- ----------------------------------------------------------------------+
 SELECT nvl(template_flag,'N'), org_id
 INTO l_template_flag , g_org_id
 FROM pa_projects_all
 WHERE project_id = p_project_id;

 If l_template_flag = 'Y' then
   log_message('check_or_reserve_funds called for template project ..exit with success');
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   RETURN;
 End If;

 x_dual_bdgt_cntrl_flag := 'N';
 x_cc_budget_version_id := NULL;

-----------------------------------------------+
-- 1.0: Get the budgetary control options
-----------------------------------------------+
 log_message('Opening budget_funds cursor') ;
 log_message('proj_id '||to_char(p_project_id)||'bver_id '
    ||to_char(p_budget_version_id ));

 OPEN c_Budget_funds ;
 FETCH c_Budget_funds
 INTO   l_budget_type_code ,
        l_balance_type,
        l_external_budget_code,
        l_encumbrance_Type_Id,
        l_bdgt_cntrl_flag ,
        l_gl_budget_version_id,
	l_budget_amount_code,
        l_budget_entry_level_code;

 IF c_Budget_funds%NOTFOUND THEN
   l_msg_data := 'PA_BC_NO_BGT_CNTL';
   RAISE l_budget_processing_failure;

 END IF;

 CLOSE c_Budget_funds ;

 log_message('Fetched Values ... ');
 log_message('--------------------------------');
 log_message(' budget_type_code : '||l_budget_type_code );
 log_message(' balance_type : '||l_balance_type );
 log_message(' external_budget_code : '||l_external_budget_code );
 log_message(' encumbrance_type_id : '||to_char(l_encumbrance_type_id) );
 log_message(' l_bdg_cntrl_flag : '||l_bdgt_cntrl_flag );
 log_message(' l_gl_budget_version_id : '||to_char(l_gl_budget_version_id) );
 log_message(' l_budget_amount_code : '||l_budget_amount_code);
 log_message(' l_budget_entry_level_code : '||l_budget_entry_level_code);

 -----------------------------------------------+
 -- 1.1: Disabling CBC ...
 -----------------------------------------------+
 /* Commented for bug 6524116
 If l_balance_type = 'E' then
   Begin
     select 'CC'
     into   l_cc_budget_type_code
     from   pa_budgetary_control_options cc
     where  cc.project_id = p_project_id
     and    cc.external_budget_code = 'CC';
   Exception
     When no_data_found then
          l_cc_budget_type_code := null;
     When too_many_rows then
          -- This has been added to handle case if multiple
          -- budget types could be added 'cause of issue with
          -- PABDINTG form
          l_cc_budget_type_code := 'CC';
   End;

   If l_cc_budget_type_code = 'CC' then
       l_msg_data := 'PA_CBC_NOT_SUPPORTED';
       RAISE l_cbc_not_supported;
   End If;
 End If;
 */

 -- ------------------------------------------------------------+
 -- 2.0: Check if revenue budget is not a bottom up budget
 -- ------------------------------------------------------------+

 -- Following code was added in r12 but being commented out as the
 -- budgetary control form executes this validation
 -- IF (l_budget_amount_code = 'R' and l_balance_type <> 'E') THEN
 --    log_message(' Revenue Budget Validation');
 --    l_msg_data := 'PA_BC_REV_BUD_ERR';
 --    RAISE l_budget_processing_failure;
 -- END IF;

 -- -----------------------------------------------------------+
 -- 3.0: Set global variables .. Used in funds check -tieback
 -- -----------------------------------------------------------+

 log_message(' Set global variables ');

 g_cost_current_bvid    := p_budget_version_id;
 g_budget_amount_code   := l_budget_amount_code;
 g_balance_type         := l_balance_type;

 Begin
   Select 'Y'
   into   g_cost_rebaseline_flag
   from   pa_budget_versions pbv
   where  pbv.project_id = p_project_id
   and    pbv.budget_version_id <> p_budget_version_id -- not the current budget
   and    pbv.budget_status_code = 'B'
   and    pbv.budget_type_code = l_budget_type_code
   and    rownum =1;
 Exception
   When no_data_found then
        g_cost_rebaseline_flag := 'N';
 End;

   log_message('g_cost_rebaseline_flag : '||g_cost_rebaseline_flag );

 --g_cost_rebaseline_flag := PA_FUNDS_CONTROL_UTILS.Is_Budget_Baselined_Before(p_project_id);
 -- Issue with above API was that even for first time baseline, the flag was being set to 'Y'

 g_cc_rebaseline_flag   := g_cost_rebaseline_flag;

 If p_calling_mode = 'CHECK_FUNDS' then
    g_processing_mode := 'CHECK_FUNDS';
 Elsif p_calling_mode = 'RESERVE_BASELINE' then
    g_processing_mode := 'BASELINE';
 End if;

 log_message('g_processing_mode:'||g_processing_mode);

 If ( l_external_budget_code is not null and l_external_budget_code <> 'CC') then
    g_external_link := 'GL';
 ElsIf l_external_budget_code = 'CC' then
    If g_processing_mode = 'CHECK_FUNDS' then
       g_external_link := 'CC';
    ElsIf g_processing_mode = 'BASELINE' then
       g_external_link := 'DUAL';
    End If;
 End If;

  log_message('g_external_link:'||g_external_link);


 If (g_cost_rebaseline_flag = 'Y' and l_External_budget_code is not null) then -- B1
    log_message('Get previous baselined version');

    If g_processing_mode = 'CHECK_FUNDS' then

      g_cost_prev_bvid := GET_PREVIOUS_BVID(p_project_id       => p_project_id,
                                            p_budget_type_code => l_budget_type_code,
                                            p_curr_budget_status_code => 'S');

    Elsif g_processing_mode = 'BASELINE' then

      g_cost_prev_bvid := GET_PREVIOUS_BVID(p_project_id       => p_project_id,
                                            p_budget_type_code => l_budget_type_code,
                                            p_curr_budget_status_code => 'B');


    End If; -- processing mode

    log_message('g_cost_prev_bvid:'||g_cost_prev_bvid);

 End If; -- B1

 -- ------------------------------------------------------------+
 -- 4.0: For a non- integrated budget or a top down budget, in
 --      reserve mode, do the following:
 -- 4A. Create budgetary control records ..
 --
 -- For top-down and bottom up in reserve mode
 -- 4B. Derive draft version ..
 -- ------------------------------------------------------------+

 IF p_calling_mode = 'RESERVE_BASELINE' THEN -- 4.0

  IF nvl(l_balance_type,'E') <> 'B' THEN -- 4.1

  -- 4A. Create budgetary control records
  log_message('Create budgetary control records');

  pa_budgetary_controls_pkg.bud_ctrl_create
    (x_budget_version_id => p_budget_version_id,
     x_calling_mode      => 'BASELINE',
     X_Return_Status     => l_return_status,
     X_Msg_Count         => l_msg_count,
     X_Msg_Data          => l_msg_data) ;

     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
        RAISE l_budget_processing_failure;
     END IF ;

  END IF; --IF (nvl(l_balance_type,'E') <> 'B' THEN -- 4.1
  g_procedure_name := 'check_or_reserve_funds';

  -- -------------------------------------------------------------+
  --If g_cost_rebaseline_flag = 'Y' then

    -- 4B: Derive draft version
    --  This is reqd. as PA FC will be executed with the draft version and then the budget version will
    --  be udpated to the baselined version. Why was this done? PA FC is called in autonomous mode
    -- where the baselined version will not be visible. Also note: that in PA FC, account level
    -- FC is not executed. Account level FC is executed during FC tieback when called fomr BC API ..

    log_message(' Derive Draft version');

    Begin

      Select pbv.budget_version_id
      into   l_draft_budget_version_id
      from   pa_budget_versions pbv
      where  pbv.project_id = p_project_id
      and    pbv.budget_status_code = 'S'  -- Changed from 'W' to 'S' (UT code fix)
      and    pbv.budget_type_code = l_budget_type_code;

    Exception
      When no_data_found then
        l_msg_data := 'PA_GET_DRAFT_VERSION_FAILED';
        RAISE l_budget_processing_failure;
    End;
  --End If; --If g_cost_rebaseline_flag = 'Y' then

  log_message('  draft version:'||l_draft_budget_version_id);

 END IF; -- 4.0

 If p_calling_mode = 'CHECK_FUNDS' then
    g_draft_bvid := P_Budget_version_id;
 Else
    g_draft_bvid := l_draft_budget_version_id;
 End If;

 log_message(' Main processing');

-- -----------------------------------------------+
-- 5.0: Check Funds Processing ...
-- -----------------------------------------------+

IF  (p_calling_mode = 'CHECK_FUNDS') THEN  -- I

  log_message(' Calling mode CHECK_FUNDS ') ;

  IF  ( l_external_budget_code is not null and l_external_budget_code <> 'CC') THEN

      -- Handle CC here ..

      -- GL Budget, Call create_events_and_fundscheck in 'Check_Baseline' Mode
      -- Only coding for cost budget currently ...

      log_message('Calling CREATE_EVENTS_AND_FUNDSCHECK');

      CREATE_EVENTS_AND_FUNDSCHECK
        (P_calling_module       => 'Cost_Budget',
         P_mode                 => 'Check_Baseline',
         P_External_Budget_Code => 'GL',
         P_budget_version_id    => P_Budget_version_id,
         P_cc_budget_version_id => NULL,
         P_result_code          => l_return_status);

      g_procedure_name := 'check_or_reserve_funds';
      log_message('After call to CREATE_EVENTS_AND_FUNDSCHECK,l_return_status['||l_return_status
                  ||']');

      IF l_return_status = 'E' THEN
              If g_msg_data is null then
                 g_msg_data := 'PA_BC_FATAL';
              End If;
              l_msg_data := g_msg_data;
            RAISE  l_budget_processing_failure ;
      END IF;

      If l_return_status = 'S' THEN
          x_msg_data :=  'PA_CHK_FUNDS_SUCCESSFUL';
	  x_msg_count := 1;
          PA_UTILS.Add_Message('PA', x_msg_data);
      End If;

      COMMIT; -- Success , so commit .. this is reqd. so that the budget lines
              -- reflect the event_id that gets stamped and also the account
              -- change that happens during FC is reflected on budget lines
              -- anda ccount summary table is rebuild with the new acct.

  END IF ;  /* external_budget_code if statement */

ELSIF (p_calling_mode = 'RESERVE_BASELINE') THEN -- I

 log_message('Reserve Baseline Mode');

 -- --------------------------------------------------------------+
 -- 6.A: Delete data from pa_bc_packets for the draft version ..
 -- Basically, data will exist if prev. baseline failed
 -- --------------------------------------------------------------+
  If (p_calling_mode = 'RESERVE_BASELINE' and g_cost_rebaseline_flag ='Y') then
      log_message('Calling Delete draft bc pkt');

      DELETE_DRAFT_BC_PACKETS(p_draft_bud_ver_id => l_draft_budget_version_id);

      g_procedure_name := 'check_or_reserve_funds';
      log_message(' After Calling Delete draft bc pkt');
  End if;


-- -----------------------------------------------+
-- 6.0: Reserve (Baseline) - Non Integrated
-- -----------------------------------------------+

 IF ( l_External_budget_code is null ) then -- II

    --If g_cost_rebaseline_flag ='Y' then

       log_message('Non-Integrated Budgets');

       log_message('Calling Establish_Bc_Balances');

       ESTABLISH_BC_BALANCES(
                p_project_id               => p_project_id,
                p_draft_budget_version_id  => l_draft_budget_version_id,
                p_base_budget_version_id   => p_budget_version_id,
                p_bdgt_intg_flag           => 'N',
                x_return_status            => l_return_status,
                x_error_message_code       => l_msg_data);

       g_procedure_name := 'check_or_reserve_funds';
       log_message('After calling Establish_Bc_Balances,x_return_status:'||x_return_status);

       IF (l_return_status  <>   FND_API.G_RET_STS_SUCCESS ) THEN
          RAISE  l_budget_processing_failure ;
       END IF;

       log_message('Calling maintain_bal_fchk');

       pa_bgt_baseline_pkg.maintain_bal_fchk(
               P_PROJECT_ID => p_project_id,
               P_BUDGET_VERSION_ID => l_draft_budget_version_id,
               P_BASELINED_BUDGET_VERSION_ID => p_budget_version_id,
               P_BDGT_CTRL_TYPE => 'GL' ,
               P_CALLING_MODE => p_calling_mode,
               P_BDGT_INTG_FLAG => 'N',
               X_RETURN_STATUS => l_return_status,
               X_ERROR_MESSAGE_CODE => l_msg_data) ;

       log_message('After Calling maintain_bal_fchk,x_return_status:'||x_return_status);

       IF (l_return_status  <>   FND_API.G_RET_STS_SUCCESS ) THEN
          RAISE  l_budget_processing_failure ;
       Else

          -- Update pa_bc_packets.status_code = 'A'
          Update_bc_packets_pass(p_bud_ver_id  => p_budget_version_id);
	  -- Bug 5206537 : Procedure to stamp latest budget version id and budget line id on CDL
          PA_FUNDS_CONTROL_UTILS.Update_bvid_blid_on_cdl_bccom ( p_bud_ver_id  => p_budget_version_id,
                                                                 p_calling_mode => p_calling_mode);

       END IF ;

   --End If;

 ELSIF ( l_balance_type = 'B') then -- II

 -- -----------------------------------------------+
 -- 7.0: Reserve (Baseline) - Bottom Up
 -- -----------------------------------------------+
   -- bottom_up budgeting
   log_message('implemented bottom up budgeting ....') ;

   log_message('Call Account generator');

 /* =========================================================== +

 || -----------------------------------------------------------+
 || Following code is being commented out ...  11/29/05
 || There is no need to call account generator to create the
 || zero $ lines for bottom up budgeting
 || All other records will have ccid as submit creates the ccid
 || Creating zero $ records for a closed period will fail GL FC
 || with F26. To minimize this ..commenting following code ..
 || -----------------------------------------------------------+

   -- ## Call Budget account generator ..
   -- Calling gen_acct_all_lines which is non autonomous ..

   PA_BUDGET_ACCOUNT_PKG.Gen_Acct_All_Lines (
    P_Budget_Version_ID       => p_budget_version_id,
    P_Calling_Mode            => 'BASELINE' ,
    P_Budget_Type_Code        => l_budget_type_code,
    P_Budget_Entry_Level_Code => l_budget_entry_level_code,
    P_Project_ID              => p_project_id,
    X_Return_Status           => l_return_status,
    X_Msg_Count               => l_msg_count,
    X_Msg_Data                => l_msg_data) ;

     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
        RAISE l_budget_processing_failure ;
     END IF ;

   ============================================================== */

   log_message('Call BC Funds Check API');

  -- ## Call Budgetary Control Funds Check API

       Select decode(g_budget_amount_code,'C','Cost_Budget','R','Revenue_Budget')
       into   l_calling_module
       from   dual;

      log_message('Calling CREATE_EVENTS_AND_FUNDSCHECK');

      CREATE_EVENTS_AND_FUNDSCHECK
        (P_calling_module       => l_calling_module,
         P_mode                 => 'Reserve_Baseline',
         P_External_Budget_Code => 'GL',
         P_budget_version_id    => P_Budget_version_id,
         P_cc_budget_version_id => NULL,
         P_result_code          => l_return_status);

      g_procedure_name := 'check_or_reserve_funds';
      log_message('After call to CREATE_EVENTS_AND_FUNDSCHECK,l_return_status['||l_return_status
                  ||']');

      IF l_return_status = 'E' THEN
            l_msg_data := g_msg_data;
           RAISE  l_budget_processing_failure;
      END IF;

 elsif ( l_balance_type = 'E' ) then  -- II
 -- -----------------------------------------------+
 -- 8.0: Reserve (Baseline) - Top Down
 -- -----------------------------------------------+

-- top down budgeting
   log_message('implemented top down budgeting ....') ;

  -- ## 1. Check if its dual budgeting ...
        log_message(' Check if its dual budgeting ...');

    BEGIN
        Select budget_type_code, encumbrance_type_id
        into   l_cc_budget_type_code, l_cc_encumbrance_type_id
        from   pa_budgetary_control_options
        where project_id         = p_project_id
        and external_budget_code = 'CC' ;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_cc_budget_type_code := NULL ;
        l_cc_encumbrance_type_id := NULL ;
    END ;

    log_message('l_cc_budget_type_code, l_cc_encumbrance_type_id := '
             ||l_cc_budget_type_code||','||to_char(l_cc_encumbrance_type_id)) ;

   -- ------------------------------------------------------------+
   If ( l_cc_budget_type_code is null ) then -- III
       -- ## 2. Its not Dual integration

       --If g_cost_rebaseline_flag = 'Y' then
       -- ## 2.1 Call Budget Account generator ..
       -- Calling gen_acct_all_lines which is non autonomous ..
          log_message('Call Budget Account generator');

          PA_BUDGET_ACCOUNT_PKG.Gen_Acct_All_Lines (
             P_Budget_Version_ID       => p_budget_version_id,
             P_Calling_Mode            => 'BASELINE' ,
             P_Budget_Type_Code        => l_budget_type_code,
             P_Budget_Entry_Level_Code => l_budget_entry_level_code,
             P_Project_ID              => p_project_id,
             X_Return_Status           => l_return_status,
             X_Msg_Count               => l_msg_count,
             X_Msg_Data                => l_msg_data) ;

          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
             RAISE l_budget_processing_failure ;
          END IF ;

       -- ## 2.2 Call Establish_bc_balances
       log_message('Calling Establish_Bc_Balances');

       ESTABLISH_BC_BALANCES(
                p_project_id               => p_project_id,
                p_draft_budget_version_id  => l_draft_budget_version_id,
                p_base_budget_version_id   => p_budget_version_id,
                p_bdgt_intg_flag           => 'Y',
                x_return_status            => l_return_status,
                x_error_message_code       => l_msg_data);

      g_procedure_name := 'check_or_reserve_funds';

       log_message('After Establish_Bc_Balances,x_return_status:'||x_return_status);
       IF (l_return_status  <>   FND_API.G_RET_STS_SUCCESS ) THEN
          RAISE  l_budget_processing_failure ;
       END IF;

       -- ## 2.3 Call PA FCK ..
          log_message('Call PA Funds Check');

          pa_bgt_baseline_pkg.maintain_bal_fchk(
               P_PROJECT_ID => p_project_id,
               P_BUDGET_VERSION_ID => l_draft_budget_version_id,
               P_BASELINED_BUDGET_VERSION_ID => p_budget_version_id,
               P_BDGT_CTRL_TYPE => 'GL' ,
               P_CALLING_MODE => p_calling_mode,
               P_BDGT_INTG_FLAG => 'Y',
               X_RETURN_STATUS => l_return_status,
               X_ERROR_MESSAGE_CODE => l_msg_data) ;

          IF (l_return_status  <>   FND_API.G_RET_STS_SUCCESS ) THEN
             RAISE  l_budget_processing_failure ;
          END IF ;

       --End If; -- re-baseline check ..

       -- ## 2.4 Call BC Funds check API ..
       log_message('Calling CREATE_EVENTS_AND_FUNDSCHECK');

      CREATE_EVENTS_AND_FUNDSCHECK
        (P_calling_module       => 'Cost_Budget',
         P_mode                 => 'Reserve_Baseline',
         P_External_Budget_Code => 'GL',
         P_budget_version_id    => P_Budget_version_id,
         P_cc_budget_version_id => NULL,
         P_result_code          => l_return_status);

      g_procedure_name := 'check_or_reserve_funds';
      log_message('After call to CREATE_EVENTS_AND_FUNDSCHECK,l_return_status['||l_return_status
                  ||']');

      IF l_return_status = 'E' THEN
            l_msg_data := g_msg_data;
           RAISE  l_top_down_bdgt_failed;
      END IF;

      -- Update pa_bc_packets.status_code = 'A' .. as the last step ..
      Update_bc_packets_pass(p_bud_ver_id => p_budget_version_id);
      -- Bug 5206537 : Procedure to stamp latest budget version id and budget line id on CDL
      PA_FUNDS_CONTROL_UTILS.Update_bvid_blid_on_cdl_bccom ( p_bud_ver_id  => p_budget_version_id,
                                                             p_calling_mode => p_calling_mode);
   -- ------------------------------------------------------------+
   Elsif ( l_cc_budget_type_code is not null ) then -- III

      -- Following code needs to be uncommented for CC Integration .
      -- Fix the account generator issue by calling gen_Account_all_lines

       -- Overried g_external_link, used in pa_funds_control_pkg (tieback code)
       g_external_link := 'DUAL';

       -- ## 3 Dual Integration
       -- ## 3.1 Check if CC Budget exists
       -- ## 3.2 Check if CC and GL, total budget amounts match
       -- ## 3.3 Call PA FC for GL Budget
       -- ## 3.4 Get CC Draft version
       -- ## 3.5 Build budgetary control for CC Budget
       -- ## 3.6 Call PA FC for CC Budget
       -- ## 3.7 Call Acount generator for GL Budget
       -- ## 3.8 Call Account generator for CC Budget
       -- ## 3.9 Call BC FC

          Begin
           -- ## 3.1 Check if CC Budget exists

              select budget_version_id
              into   g_cc_current_bvid
              from   pa_budget_versions
              where  project_id = p_project_id
              and    budget_type_code = l_cc_budget_type_code
              and    budget_status_code = 'B'
              and    current_flag ='Y';

            l_cc_budget_version_id := g_cc_current_bvid;
          Exception
            When no_data_found then
               l_msg_data := 'PA_BC_CC_BDGT_ID_ERR';
               RAISE l_budget_processing_failure;
          End;

          /*Commented for Bug 6524116
          If g_cost_rebaseline_flag ='Y' then

             g_cc_prev_bvid :=GET_PREVIOUS_BVID(p_project_id       => p_project_id,
                                                p_budget_type_code => l_cc_budget_type_code,
                                                p_curr_budget_status_code => 'B');
          End IF;
          */

       -- ## 3.2 Check if CC and GL, total budget amounts match
       --------------------------------------------------------------+
       --   Get the total budgeted amounts for CC and GL budgets
       --------------------------------------------------------------+

       log_message('Opening Cursor c_budget_sum_amt with cc version id') ;

       OPEN c_budget_sum_amt(g_cc_current_bvid) ;
       FETCH c_budget_sum_amt INTO l_total_cc_bdgt_amount ;
       CLOSE c_budget_sum_amt ;

       log_message('Opening Cursor c_budget_sum_amt with p_budget version id') ;

       OPEN c_budget_sum_amt(g_cost_current_bvid) ;
       FETCH c_budget_sum_amt INTO l_total_gl_bdgt_amount ;
       CLOSE c_budget_sum_amt ;

       --------------------------------------------------------------+
       --   Total Budget Amounts of CC and GL Budgets Should match.
       --------------------------------------------------------------+

       log_message('l_total_cc_bdgt_amount '||l_total_cc_bdgt_amount);
       log_message('l_total_gl_bdgt_amount '||l_total_gl_bdgt_amount);

       IF ( l_total_cc_bdgt_amount <> l_total_gl_bdgt_amount ) THEN
          l_msg_data := 'PA_BC_CC_GL_AMT_NOT_EQL';
          RAISE l_budget_processing_failure ;
       END IF ;

       --START Bug 6524116
          log_message('Call Budget Account generator');

          PA_BUDGET_ACCOUNT_PKG.Gen_Acct_All_Lines (
             P_Budget_Version_ID       => p_budget_version_id,
             P_Calling_Mode            => 'BASELINE' ,
             P_Budget_Type_Code        => l_budget_type_code,
             P_Budget_Entry_Level_Code => l_budget_entry_level_code,
             P_Project_ID              => p_project_id,
             X_Return_Status           => l_return_status,
             X_Msg_Count               => l_msg_count,
             X_Msg_Data                => l_msg_data) ;

          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
             RAISE l_budget_processing_failure ;
          END IF ;

       log_message('Calling Establish_Bc_Balances');

       ESTABLISH_BC_BALANCES(
                p_project_id               => p_project_id,
                p_draft_budget_version_id  => l_draft_budget_version_id,
                p_base_budget_version_id   => p_budget_version_id,
                p_bdgt_intg_flag           => 'Y',
                x_return_status            => l_return_status,
                x_error_message_code       => l_msg_data);

      g_procedure_name := 'check_or_reserve_funds';

       log_message('After Establish_Bc_Balances,x_return_status:'||x_return_status);
       IF (l_return_status  <>   FND_API.G_RET_STS_SUCCESS ) THEN
          RAISE  l_budget_processing_failure ;
       END IF;
       --END Bug 6524116

       -- ------------------------------------------------------------+
       -- ## 3.3 Call PA FC for GL Budget
       -- ------------------------------------------------------------+
        --If g_cost_rebaseline_flag = 'Y' then
               log_message('Call PA Funds Check for GL budget');

          pa_bgt_baseline_pkg.maintain_bal_fchk(
               P_PROJECT_ID => p_project_id,
               P_BUDGET_VERSION_ID => l_draft_budget_version_id,
               P_BASELINED_BUDGET_VERSION_ID => p_budget_version_id,
               P_BDGT_CTRL_TYPE => 'GL' ,
               P_CALLING_MODE => p_calling_mode,
               P_BDGT_INTG_FLAG => 'Y',
               X_RETURN_STATUS => l_return_status,
               X_ERROR_MESSAGE_CODE => l_msg_data) ;

          IF (l_return_status  <>   FND_API.G_RET_STS_SUCCESS ) THEN
             RAISE  l_budget_processing_failure ;
          END IF ;

        --End IF; -- rebaseline

       -- ------------------------------------------------------------+
       -- ## 3.9 Call BC FC
       -- ------------------------------------------------------------+
          log_message('Call BC FC API');

          CREATE_EVENTS_AND_FUNDSCHECK
             (P_calling_module       => 'Dual_Budget',
              P_mode                 => 'Reserve_Baseline',
              P_External_Budget_Code => 'Dual',
              P_budget_version_id    => P_Budget_version_id,
              P_cc_budget_version_id => l_cc_budget_version_id,
              P_result_code          => l_return_status);

           IF l_return_status = 'E' THEN
                 l_msg_data := g_msg_data;
                 RAISE  l_dual_bc_fc_failed;

           ELSE
              x_cc_budget_version_id   := l_cc_budget_version_id;
              x_dual_bdgt_cntrl_flag   := 'Y';

          END IF;

       -- ------------------------------------------------------------+
       -- ## 3.4 Get CC Draft version
       -- ------------------------------------------------------------+

         log_message(' Derive CC Draft version');

  	 Begin

    	    Select pbv.budget_version_id, budget_entry_method_code
            into   l_cc_budget_version_id, l_cc_budget_entry_level_code
            from   pa_budget_versions pbv
            where  pbv.project_id         = p_project_id
	    and    pbv.budget_type_code   = l_cc_budget_type_code
            and    pbv.budget_status_code = 'B'
            and    pbv.current_flag = 'Y';


        Exception
            When no_data_found then
               l_msg_data := 'PA_GET_DRAFT_VERSION_FAILED';
               RAISE l_top_down_bdgt_failed;
        End;

       -- ------------------------------------------------------------+
       -- ## 3.5 Build budgetary control for CC Budget
       -- ------------------------------------------------------------+
         log_message('Build budgetary control for CC Budget');

         pa_budgetary_controls_pkg.bud_ctrl_create
            (x_budget_version_id => l_cc_budget_version_id,
             x_calling_mode      => 'BASELINE',
             X_Return_Status     => l_return_status,
             X_Msg_Count         => l_msg_count,
             X_Msg_Data          => l_msg_data) ;

         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN

             RAISE l_top_down_bdgt_failed;

         END IF ;

       --START BUG 6524116
          log_message('Call Budget Account generator');

          PA_BUDGET_ACCOUNT_PKG.Gen_Acct_All_Lines (
             P_Budget_Version_ID       => l_cc_budget_version_id,
             P_Calling_Mode            => 'BASELINE' ,
             P_Budget_Type_Code        => l_cc_budget_type_code,
             P_Budget_Entry_Level_Code => l_cc_budget_entry_level_code,
             P_Project_ID              => p_project_id,
             X_Return_Status           => l_return_status,
             X_Msg_Count               => l_msg_count,
             X_Msg_Data                => l_msg_data) ;

          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
             RAISE l_budget_processing_failure ;
          END IF ;

       log_message('Calling Establish_Bc_Balances');

       ESTABLISH_BC_BALANCES(
                p_project_id               => p_project_id,
                p_draft_budget_version_id  => l_cc_budget_version_id,
                p_base_budget_version_id   => g_cc_current_bvid,
                p_bdgt_intg_flag           => 'Y',
                x_return_status            => l_return_status,
                x_error_message_code       => l_msg_data);

      g_procedure_name := 'check_or_reserve_funds';

       log_message('After Establish_Bc_Balances,x_return_status:'||x_return_status);
       IF (l_return_status  <>   FND_API.G_RET_STS_SUCCESS ) THEN
          RAISE  l_budget_processing_failure ;
       END IF;
       --END BUG 6524116

       -- ------------------------------------------------------------+
       -- ## 3.6 Call PA FC for CC Budget
       -- ------------------------------------------------------------+
               log_message('Call PA Funds Check for CC budget');

        --If g_cc_rebaseline_flag = 'Y' then

          pa_bgt_baseline_pkg.maintain_bal_fchk(
               P_PROJECT_ID => p_project_id,
               P_BUDGET_VERSION_ID => l_cc_budget_version_id,
               P_BASELINED_BUDGET_VERSION_ID => g_cc_current_bvid,
               P_BDGT_CTRL_TYPE => 'CC' ,
               P_CALLING_MODE => p_calling_mode,
               P_BDGT_INTG_FLAG => 'Y',
               X_RETURN_STATUS => l_return_status,
               X_ERROR_MESSAGE_CODE => l_msg_data) ;

          IF (l_return_status  <>   FND_API.G_RET_STS_SUCCESS ) THEN

             RAISE  l_top_down_bdgt_failed;
          END IF ;
        --End If; -- rebaseline

       /* Commented for bug Bug 6524116
       -- ------------------------------------------------------------+
       -- ## 3.7 Call Acount generator for GL Budget
       -- ------------------------------------------------------------+
          log_message('Call Budget Account generator for GL budget');

          PA_BUDGET_ACCOUNT_PKG.Gen_Account (
              P_Budget_Version_ID     => l_draft_budget_version_id,
              P_Calling_Mode          => 'BASELINE' ,
              X_Return_Status         => l_return_status,
              X_Msg_Count             => l_msg_count,
              X_Msg_Data              => l_msg_data) ;

          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
             RAISE l_dual_mode_acct_gen_failed ;
          END IF ;

       -- ------------------------------------------------------------+
       -- ## 3.8 Call Account generator for CC Budget
       -- ------------------------------------------------------------+
          log_message('Call Budget Account generator for CC budget');

          PA_BUDGET_ACCOUNT_PKG.Gen_Account (
              P_Budget_Version_ID     => l_cc_budget_version_id,
              P_Calling_Mode          => 'BASELINE' ,
              X_Return_Status         => l_return_status,
              X_Msg_Count             => l_msg_count,
              X_Msg_Data              => l_msg_data) ;

          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
             RAISE l_dual_mode_acct_gen_failed ;
          END IF ;
       */

     --Start Bug 6524116
     CC_FUNDS_CHK_RSRV(
        P_ENC_TYPE_ID => l_Encumbrance_Type_Id,
        P_BUDGET_VERSION_ID   => l_cc_Budget_version_id,
        p_calling_mode        => 'RESERVE' ,
        p_Balance_Type        => l_Balance_type,
        x_funds_chk_rsrv_status => l_funds_chk_rsrv_status,
        x_return_status        => l_return_status,
        x_msg_count           => l_msg_count,
        x_msg_data           =>l_msg_data ) ;

     IF nvl(l_return_status, 'E') <> 'S' then
       --Collect all event_ids
       if g_cost_rebaseline_flag = 'Y' then
         P_prev_budget_version_id := GET_PREVIOUS_BVID(p_project_id       => p_project_id,
                                                p_budget_type_code => l_budget_type_code,
                                                p_curr_budget_status_code => 'B');
         open get_rejected_event_id;
         fetch get_rejected_event_id bulk collect into rejected_event_id_tab, ledger_id_tab;
         close get_rejected_event_id;
       else
         select bc_event_id, g_org_id
         bulk collect into rejected_event_id_tab, ledger_id_tab
         from pa_budget_lines bl
         where budget_version_id = P_Budget_version_id
           and bc_event_id is not null;
       end if;
       /*PSA_FUNDS_CHECKER_PKG.sync_xla_errors(p_failed_ldgr_array => ledger_id_tab,
                                             p_failed_evnt_array => rejected_event_id_tab);*/
       RAISE l_dual_bc_fc_failed;
     END if;
     --END Bug 6524116

      -- As the last step, update pa_bc to pass
      Update_bc_packets_pass(p_bud_ver_id  => p_budget_version_id);
      Update_bc_packets_pass(p_bud_ver_id =>l_cc_budget_version_id);
      -- Bug 5206537 : Procedure to stamp latest budget version id and budget line id on CDL
      PA_FUNDS_CONTROL_UTILS.Update_bvid_blid_on_cdl_bccom ( p_bud_ver_id  => p_budget_version_id,
                                                             p_calling_mode => p_calling_mode);

   End If;  -- III (Top Down: GL or Dual check)


 end if; /* top-down and bottom-up check if */ -- II

END IF; /* calling mode if */ -- I

 -- ------------------------------------------------------------+
 -- 9.0 : Calling Sweeper
 -- ------------------------------------------------------------+
 -- Sweeper process need to be called after the tieback api.
 -- The success/failure of sweeper process should not stop the
 -- baseline process.

    IF (p_calling_mode = 'RESERVE_BASELINE' and g_cost_rebaseline_flag = 'Y' ) then

       log_message('Calling Sweeper ..');

        Begin
            l_request_id := pa_funds_control_utils.runsweeper ;
        Exception
            When others  then
                 null;
        End;

        log_message('After Calling Sweeper,request:'||l_request_id);

    End If;

 -- ------------------------------------------------------------+
 -- 10.0 : Release BC locks
 -- ------------------------------------------------------------+
    IF p_calling_mode = 'RESERVE_BASELINE' then

       log_message('Calling release lock ..');

       release_bc_lock (p_project_id    => p_project_id,
                        x_return_status => x_return_status,
                        x_msg_count     => x_msg_count,
                        x_msg_data      => x_msg_data);

       log_message('After calling release lock ..');

    END IF;

 -- ------------------------------------------------------------+
 -- 11.0 : Pass warning message if unburdened CDL's exist ..
 -- ------------------------------------------------------------+
 -- Following code was added to check whether all CDL's have been
    -- burdened. If not, the actual cost can decrease as burden is not
    -- accounted ...

    --IF (p_calling_mode = 'RESERVE_BASELINE' and
    --    g_cost_rebaseline_flag = 'Y'        and
    --    (l_External_budget_code is null OR l_balance_type = 'E' )
    --   ) then

    --    IF Unburdened_cdl_exists(X_project_id => p_project_id) then
    --      l_msg_data := 'PA_UNBURDENED_CDL_EXISTS';
    --      PA_UTILS.Add_Message('PA', l_msg_data);
    -- 	  x_msg_data  := l_msg_data;
    --      x_msg_count := 1;

    --    END IF;

    --END IF;

    -- Unburdened_cdl_exists will be called from PAXBUEBU.fmb ..

 -- ------------------------------------------------------------+


 -- ## RETURN STATUS .. PASSED :)

 l_return_status := FND_API.G_RET_STS_SUCCESS;
 x_return_status := l_return_status;

 log_message('exiting check_reserve_funds .........') ;
 log_message('l_return_status.........'||l_return_status) ;

EXCEPTION

    WHEN l_cbc_not_supported THEN

          g_procedure_name := 'check_or_reserve_funds';
          log_message(' Exception: l_cbc_not_supported');

          x_return_status := FND_API.G_RET_STS_ERROR;

    	  PA_UTILS.Add_Message('PA', l_msg_data);
     	  x_msg_data :=  l_msg_data;
	  x_msg_count := 1;

	WHEN  l_top_down_bdgt_failed THEN

          g_procedure_name := 'check_or_reserve_funds';
          log_message(' Exception: l_top_down_bdgt_failed');

          IF p_calling_mode = 'RESERVE_BASELINE' then


             Update_bc_packets_fail(p_bud_ver_id => l_draft_budget_version_id,
                               p_status_code=> 'R');

            release_bc_lock (p_project_id    => p_project_id,
                             x_return_status => x_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data);
          END IF;

          -- This should be set at the end .. do not change this position ..
          x_return_status := FND_API.G_RET_STS_ERROR;

    	  PA_UTILS.Add_Message('PA', l_msg_data);
	  x_msg_data :=  l_msg_data;
	  x_msg_count := 3;  -- made to 3 so that it can read all message buffers
                             -- if you dont have enough messages then it does not error out

       WHEN l_dual_mode_acct_gen_failed OR l_dual_bc_fc_failed THEN

          g_procedure_name := 'check_or_reserve_funds';
          log_message(' Exception: l_dual_mode_acct_gen_failed OR l_dual_bc_fc_failed');

          IF p_calling_mode = 'RESERVE_BASELINE' then

            release_bc_lock (p_project_id    => p_project_id,
                             x_return_status => x_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data);

            -- Fail pa_bc_packets for Cost and Commitment budget ..
             -- Fail pa_bc_packets for Cost budget ..
             Update_bc_packets_fail(p_bud_ver_id  => l_draft_budget_version_id,
                               p_status_code => 'R');
             Update_bc_packets_fail(p_bud_ver_id =>l_cc_budget_version_id,
                               p_status_code=>'R');
          END IF;

          -- This should be set at the end .. do not change this position ..
          x_return_status := FND_API.G_RET_STS_ERROR;

    	  PA_UTILS.Add_Message('PA', l_msg_data);
	  x_msg_data :=  l_msg_data;
	  x_msg_count := 3;  -- made to 3 so that it can read all message buffers
                             -- if you dont have enough messages then it does not error out

	WHEN  l_budget_processing_failure THEN

          g_procedure_name := 'check_or_reserve_funds';
          log_message(' Exception: l_budget_processing_failure');

          IF p_calling_mode = 'RESERVE_BASELINE' then

            release_bc_lock (p_project_id    => p_project_id,
                             x_return_status => x_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data);
          END IF;

          -- This should be set at the end .. do not change this position ..
          x_return_status := FND_API.G_RET_STS_ERROR;

    	  PA_UTILS.Add_Message('PA', l_msg_data);
	  x_msg_data :=  l_msg_data;
	  x_msg_count := 3;  -- made to 3 so that it can read all message buffers
                             -- if you dont have enough messages then it does not error out

	WHEN OTHERS THEN

          g_procedure_name := 'check_or_reserve_funds';
          log_message(' Exception: WHEN OTHERS');

          IF p_calling_mode = 'RESERVE_BASELINE' then

            release_bc_lock (p_project_id    => p_project_id,
                             x_return_status => x_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data);

             Update_bc_packets_fail(p_bud_ver_id  => l_draft_budget_version_id,
                               p_status_code => 'T');

             If l_cc_budget_version_id is not null then
                Update_bc_packets_fail(p_bud_ver_id =>l_cc_budget_version_id,
                                  p_status_code=>'T');
             End If;

          END IF;

                 -- This should be set at the end .. do not change this position ..
 		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                 -- Following code was modified to enhance error handling
                 -- If there is an exception raised, g_msg_data may be populated
                 -- (like in create_events_and_fundscheck)
                 -- Else, we get SQLERRM. When there is an event creation error, the
                 -- SQLERRM length is more than 240 and the message has lot of data that users
                 -- would like to get.

                     x_msg_count := 3;

                 If g_msg_data is not null then
                     x_msg_data :=  g_msg_data;
                     PA_UTILS.Add_Message('PA',x_msg_data);

                     log_message('When Others:x_msg_data:'||x_msg_data);

                Else -- SQLERRM

                    l_sqlerrm  := SQLERRM;
                    x_msg_data := substr(SQLERRM,1,240);

                    select length(l_sqlerrm) into l_dummy from dual;

                    If l_dummy > 0 then
                       ADD_MESSAGE(substr(SQLERRM,1,200)||'...');
                       log_message('When Others:'||substr(SQLERRM,1,200));
                    End If;
                    If l_dummy > 201 then
                       ADD_MESSAGE(substr(SQLERRM,201,400));
                       log_message('When Others:'||substr(SQLERRM,201,400));
                    End If;

                End If;

END check_or_reserve_funds;

--
-- Procedure            : get_budget_ctrl_options
-- Purpose              : To get Budget Control Options for given project id and
--                        calling mode.
--Parameters            :
--                        p_calling_code :  STANDARD/COMMITMENT/BUDGET
--                        x_fck_req_flag --> Y (Yes), N (No)
--                        x_bdgt_intg_flag --> G (GL), ,C ( CC ), N (No)

-- sqlplus apps/apps@padev115 @PABBFNDB.pls

PROCEDURE get_budget_ctrl_options ( p_project_id             IN   NUMBER,
                                    p_budget_type_code       IN   VARCHAR2,
                                    p_calling_mode           IN   VARCHAR2,
                                    x_fck_req_flag           OUT  NOCOPY VARCHAR2,
                                    x_bdgt_intg_flag         OUT  NOCOPY VARCHAR2,
                                    x_bdgt_ver_id            OUT  NOCOPY NUMBER,
                                    x_encum_type_id          OUT  NOCOPY NUMBER,
                                    x_balance_type           OUT  NOCOPY VARCHAR2,
                                    x_return_status          OUT  NOCOPY VARCHAR2,
                                    x_msg_count              OUT  NOCOPY NUMBER,
                                    x_msg_data               OUT  NOCOPY VARCHAR2 )
IS

CURSOR C_BUDGET_CONTROL IS
SELECT  budget_type_code,
        encumbrance_type_id,
        external_budget_code,
        balance_type,
        bdgt_cntrl_flag
FROM    PA_BUDGETARY_CONTROL_OPTIONS
WHERE   project_id = p_project_id
AND     ( ( p_calling_mode = 'STANDARD'  AND
          ( nvl(external_budget_code,'-1') IN ('GL','-1') ) )
         OR
          ( p_calling_mode = 'COMMITMENT'  AND
          ( nvl(external_budget_code,'-1') = 'CC') )
         OR
          ( p_calling_mode = 'BUDGET' )
        )
AND     ( ( p_calling_mode = 'BUDGET'  AND
          ( nvl(budget_type_code,'-1') =  p_budget_type_code ) )
         OR
          ( p_calling_mode IN  ('COMMITMENT','STANDARD') )
        )
AND     (
          ( p_calling_mode =   'STANDARD'
            AND ( ( nvl(balance_type,'-1') = 'E'  AND
                     nvl(external_budget_code,'-1') = 'GL' )
                  OR ( nvl(balance_type,'-1') = '-1'  AND
                     nvl(external_budget_code,'-1') = '-1' ))
          )
          OR
          ( p_calling_mode =   'COMMITMENT' AND
            nvl(balance_type,'-1') = 'E'
          )
          OR
          ( p_calling_mode = 'BUDGET' ) );

CURSOR C_BUDGET_VERSION ( c_budget_type_code VARCHAR ) IS
SELECT budget_version_id
FROM  PA_BUDGET_VERSIONS
WHERE project_id = p_project_id
 AND   budget_type_code = c_budget_type_code
 AND   budget_status_code = 'B'
 AND   version_number = (Select MAX(version_number)
                         FROM PA_BUDGET_VERSIONS
                         WHERE project_id = p_project_id
                         AND   budget_type_code = c_budget_type_code
                         AND   budget_status_code = 'B'  );

l_lock_name       VARCHAR2(200);
l_acquire_lock    NUMBER;
l_release_lock    NUMBER;


l_encumbrance_type_id       NUMBER ;

l_budget_type_code        pa_budget_versions.budget_type_code%TYPE ;
l_balance_type            pa_budgetary_control_options.balance_type%TYPE ;
l_bdgt_cntrl_flag            pa_budgetary_control_options.bdgt_cntrl_flag%TYPE ;
l_external_budget_code    pa_budgetary_control_options.external_budget_code%TYPE ;
l_budget_version_id       pa_budget_versions.budget_version_id%TYPE ;
l_msg_index_out		  NUMBER;

l_rel_status              NUMBER;
BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

OPEN C_BUDGET_CONTROL ;

FETCH C_BUDGET_CONTROL INTO
      l_budget_type_code,
      l_encumbrance_type_id ,
      l_external_budget_code,
      l_balance_type,
      l_bdgt_cntrl_flag;

IF    C_BUDGET_CONTROL%NOTFOUND THEN
--dbms_output.put_line('record not found ');
      x_fck_req_flag := 'N' ;
      x_bdgt_intg_flag := 'N' ;
      x_bdgt_ver_id := NULL;
      x_encum_type_id := NULL ;
      x_balance_type  := NULL ;

     --  Add X_msg_data and x_msg count

ELSE
--dbms_output.put_line('record found ');

--ELSIF C_BUDGET_CONTROL%FOUND THEN
      x_balance_type  := l_balance_type ;
    IF (p_calling_mode = 'BUDGET') THEN

/* *****
-- to support this the changes to
-- the baseline API are huge.
-- This will be revisited after testing.
 if l_bdgt_cntrl_flag = 'Y' then
      x_fck_req_flag := 'Y';
 else
      x_fck_req_flag := 'N';
 end if;
*** */

      x_fck_req_flag := 'Y';

      if ( nvl(x_balance_type,'X') = 'B' ) then
         x_bdgt_intg_flag := 'G';
      else
        SELECT decode(nvl(l_external_budget_code,'X'),'GL','G','CC','C','N')
        into   x_bdgt_intg_flag  from dual ;
      end if;

    ELSE
         OPEN C_BUDGET_VERSION( l_budget_type_code ) ;
         FETCH C_BUDGET_VERSION INTO l_budget_version_id ;
         IF C_BUDGET_VERSION%NOTFOUND THEN
        -- then error messages
         x_fck_req_flag := NULL ;
         x_bdgt_intg_flag := NULL ;
         x_bdgt_ver_id := NULL;
         x_encum_type_id := NULL ;
         x_balance_type  := NULL ;

         -- Add X_msg_data and x_msg count

          ELSIF C_BUDGET_VERSION%FOUND THEN
             IF l_external_budget_code is not null THEN
                SELECT decode(l_external_budget_code,'GL','G','CC','C','N') into
                x_bdgt_intg_flag  from dual ;
                x_encum_type_id :=  l_encumbrance_type_id ;
             ELSE
                x_bdgt_intg_flag := 'N' ;
                x_encum_type_id  := NULL ;
             END IF ;
          x_fck_req_flag := 'Y' ;
          x_bdgt_ver_id := l_budget_version_id ;
      --    SET the return status
          END IF ;
          CLOSE C_BUDGET_VERSION ;
     END IF ;
END IF ;
CLOSE C_BUDGET_CONTROL ;

BEGIN
  IF X_Bdgt_Intg_Flag IN ('G','C')
  THEN
/* Commenting for Bug 5726535
    l_lock_name := 'YRENDRLVR:'||P_Project_ID||':'||P_Budget_Type_Code;
    -- Check whether the Budget is locked
    IF NOT Is_Budget_Locked ( l_Lock_Name )
*/
    IF PA_Year_End_Rollover_PKG.Is_Yr_End_Rollover_Running(P_Project_ID, l_budget_type_code) /* Bug 5726535 */
    THEN
      X_Fck_Req_Flag   := 'R';	-- Indicates that Year End Rollover is in progress
      X_Bdgt_Intg_Flag := 'R';	-- Indicates that Year End Rollover is in progress
    END IF;
    x_Return_Status  := FND_API.G_RET_STS_SUCCESS;
  END IF;
END;

EXCEPTION
 WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  x_msg_count := 1;
  x_msg_data := substr(SQLERRM,1,240);
  FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_BUDGET_FUND_PKG',
                           p_procedure_name   => 'get_budget_ctrl_options');

END get_budget_ctrl_options;

--
-- Procedure            : upd_bdgt_acct_bal
-- Purpose              : Update the account level balances for given account, period
--                        and budget version id.
--Parameters            :
--                       p_amount
--                            +ve amount : means amount is send for liquidation.
--                            -ve amount : means amount is send for reservation.
--                        process : Update the available balance field with :
--                                  available_balance - p_amount.
--

PROCEDURE upd_bdgt_acct_bal (    p_gl_period_name         IN   VARCHAR2,
                                 p_budget_version_id      IN  NUMBER,
                                 p_ccid                   IN  NUMBER,
                                 p_amount                 IN  NUMBER,
                                 x_return_status          OUT  NOCOPY VARCHAR2,
                                 x_msg_count              OUT  NOCOPY NUMBER,
                                 x_msg_data               OUT  NOCOPY VARCHAR2 )
IS
l_msg_index_out		     NUMBER;
BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

UPDATE PA_BUDGET_ACCT_LINES
SET curr_ver_available_amount = curr_ver_available_amount - p_amount
WHERE budget_version_id = p_budget_version_id
AND gl_period_name = p_gl_period_name
AND code_combination_id = p_ccid ;

EXCEPTION
 WHEN OTHERS THEN

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 x_msg_count := 1;
		 x_msg_data := substr(SQLERRM,1,240);
		 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_BUDGET_FUND_PKG',
			 p_procedure_name   => 'upd_bdgt_acct_bal');
 raise;

END upd_bdgt_acct_bal;

--
-- Procedure            : upd_bdgt_acct_bal_no_fck
-- Purpose              : Update the amount available column in pa_budget_acct_lines
--                        table during budget baselining process. This is called when
--                        funds check is not required during baselining process.
--                        The projects funds check process deternimes this by comparing
--                        current budget's budget lines with the previous budget's budget
--                        lines. In this case only amounts have changed.
--                        Apply the following formula :
--                          CA = ( CB - PB ) + PA
--
--                          CA : Current Available Amount
--                          CB : Current Budget Amount
--                          PB : Previous Budget Amount
--                          PA : Previous Available Amount
--Parameters            :
--                       p_amount
--                            +ve amount : means amount is send for liquidation.
--                            -ve amount : means amount is send for reservation.
--                        process : Update the available balance field with :
--                                  available_balance - p_amount.
--

PROCEDURE upd_bdgt_acct_bal_no_fck (  p_budget_version_id      IN  NUMBER,
                                      x_return_status          OUT NOCOPY  VARCHAR2,
                                      x_msg_count              OUT NOCOPY  NUMBER,
                                      x_msg_data               OUT NOCOPY  VARCHAR2 )
IS
l_msg_index_out		     NUMBER;

BEGIN

log_message('Entering upd_bdgt_acct_bal_no_fck ..... ');
x_return_status := FND_API.G_RET_STS_SUCCESS;

log_message('budget_version_id  '||to_char(p_budget_version_id));
UPDATE PA_BUDGET_ACCT_LINES
SET curr_ver_available_amount = (curr_ver_budget_amount - prev_ver_budget_amount
                                + prev_ver_available_amount)
WHERE budget_version_id = p_budget_version_id ;

log_message('Updated  '||to_char(sql%rowcount));
log_message('Existing upd_bdgt_acct_bal_no_fck ..... ');

EXCEPTION
 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_count := 1;
    x_msg_data := substr(SQLERRM,1,240);
    FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_BUDGET_FUND_PKG',
    p_procedure_name   => 'upd_bdgt_acct_bal_no_fck');
    raise;

END upd_bdgt_acct_bal_no_fck;

--
-- Function		: Is_bdgt_intg_enabled
-- Purpose		: This functions returns a true/false for a given project_id
--			  and mode
-- Parameters		: P_mode	S-> Standard , C -> Commitment , A -> All
--			  p_project_id

FUNCTION Is_bdgt_intg_enabled (p_project_id      	IN  NUMBER,
			       p_mode			IN  VARCHAR2 )
RETURN BOOLEAN IS

l_msg_index_out		     	NUMBER;
l_ret_value			BOOLEAN ;
l_bdgt_enabled			VARCHAR2(1) ;

CURSOR c_bdgt_enabled IS
SELECT 'X'
FROM DUAL
WHERE EXISTS
   ( SELECT 'x'
     FROM   PA_BUDGETARY_CONTROL_OPTIONS PBA
     WHERE    PBA.project_id = p_project_id
           AND  ( ( p_mode  ='A'  )
                 OR
                  ( p_mode <> 'A' AND
                    PBA.external_budget_code = decode(p_mode,'S','GL','C','CC','-1'))));

BEGIN

OPEN c_bdgt_enabled ;
FETCH c_bdgt_enabled INTO l_bdgt_enabled ;
IF c_bdgt_enabled%NOTFOUND THEN
l_ret_value := FALSE ;
ELSE
l_ret_value := TRUE ;
END IF;
CLOSE c_bdgt_enabled ;

RETURN l_ret_value ;

END Is_bdgt_intg_enabled ;

--
-- Procedure            : copy_budgetary_controls
-- Purpose              : This procedure is called from the copy project api.
--                        This api will copy budgetary controls from one
--                        project to another project.
-- Parameters           :


PROCEDURE copy_budgetary_controls (p_from_project_id      IN   NUMBER,
                                   p_to_project_id        IN   NUMBER,
                                   x_return_status             OUT  NOCOPY VARCHAR2,
                                   x_msg_count                 OUT  NOCOPY NUMBER,
                                   x_msg_data                  OUT  NOCOPY VARCHAR2 )
IS
BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

insert into PA_BUDGETARY_CONTROL_OPTIONS
 (
   PROJECT_TYPE,
   PROJECT_ID,
   BALANCE_TYPE,
   EXTERNAL_BUDGET_CODE,
   GL_BUDGET_VERSION_ID,
   ENCUMBRANCE_TYPE_ID,
   BDGT_CNTRL_FLAG,
   AMOUNT_TYPE,
   BOUNDARY_CODE,
   FUND_CONTROL_LEVEL_PROJECT,
   FUND_CONTROL_LEVEL_TASK,
   FUND_CONTROL_LEVEL_RES_GRP,
   FUND_CONTROL_LEVEL_RES,
   BUDGET_TYPE_CODE,
   PROJECT_TYPE_ORG_ID ,
 LAST_UPDATE_DATE ,
 LAST_UPDATED_BY  ,
 CREATION_DATE    ,
 CREATED_BY       ,
 LAST_UPDATE_LOGIN

 )
select
   PROJECT_TYPE,
   p_to_project_id,
   BALANCE_TYPE,
   EXTERNAL_BUDGET_CODE,
   GL_BUDGET_VERSION_ID,
   ENCUMBRANCE_TYPE_ID,
   BDGT_CNTRL_FLAG,
   AMOUNT_TYPE,
   BOUNDARY_CODE,
   FUND_CONTROL_LEVEL_PROJECT,
   FUND_CONTROL_LEVEL_TASK,
   FUND_CONTROL_LEVEL_RES_GRP,
   FUND_CONTROL_LEVEL_RES,
   BUDGET_TYPE_CODE,
   PROJECT_TYPE_ORG_ID ,
 SYSDATE ,
 -1  ,
 SYSDATE    ,
 -1       ,
 -1
from PA_BUDGETARY_CONTROL_OPTIONS
where PROJECT_ID = p_from_project_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    null;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_count := 1;
    x_msg_data := substr(SQLERRM,1,240);
    FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_BUDGET_FUND_PKG',
    p_procedure_name   => 'copy_budgetary_controls');
    raise;
END copy_budgetary_controls;

--
-- Procedure            : release_bc_lock
-- Purpose              :

-- Parameters           :

PROCEDURE release_bc_lock (p_project_id      IN   NUMBER ,
                            x_return_status          OUT  NOCOPY VARCHAR2,
                            x_msg_count              OUT  NOCOPY NUMBER,
                            x_msg_data               OUT  NOCOPY VARCHAR2 )

IS
l_temp_ret_status NUMBER;
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS;

log_message('entering release_bc_lock ..... ');

    l_temp_ret_status := pa_debug.release_user_lock('BSLNFCHKLOCK:'||to_char(p_project_id));

log_message('after release_user_lock ..... ');

commit;
log_message('exiting release_bc_lock ..... ');

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_count := 1;
    x_msg_data := substr(SQLERRM,1,240);
    FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_BUDGET_FUND_PKG',
    p_procedure_name   => 'release_bc_lock');
    raise;
END release_bc_lock;

--
-- Function             : Is_pa_bc_enabled
-- Purpose              : This functions returns true if the profile option
--                        PA_BC_ENABLED is set as 'Y' otherwise flase.
-- Parameters           : None.
--

FUNCTION Is_pa_bc_enabled RETURN BOOLEAN IS

l_return_value                  VARCHAR(30);
BEGIN

 FND_PROFILE.GET('PA_BC_ENABLED',l_return_value );

 if ( l_return_value = 'Y' ) then
    return TRUE;
 else
    return FALSE;
 end if;

END Is_pa_bc_enabled ;

--
-- Function             : Is_Budget_Locked
-- Purpose              : This functions returns true if the Budget is locked
--                        otherwise false.
-- Parameters           : Lock_Name
--

FUNCTION Is_Budget_Locked (
  P_Lock_Name  IN    VARCHAR2
)
RETURN BOOLEAN IS
l_release_lock    NUMBER;
PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
  IF PA_Debug.Acquire_User_Lock(P_Lock_Name)=0 -- Acquired the lock successfully
  THEN
    l_release_lock := PA_Debug.Release_User_Lock(P_Lock_Name); -- Release the lock
    RETURN True;
  ELSE
    RETURN False;
  END IF;
END Is_Budget_Locked;

-- ------------------------------------------------------------------------------+
-- ------------------------------------ R12 Start -------------------------------+
-- ------------------------------------------------------------------------------+

-- ---------------------------------------------------------------------------------------------------+
-- This procedure will be called during a recosting scenario to clean up date
-- from pa_bc_packets for the "draft version" (meaning if re-baseline had earlier failed)
-- bug reference for this fix: 5253834
-- ---------------------------------------------------------------------------------------------------+
PROCEDURE Delete_draft_bc_packets(p_draft_bud_ver_id IN NUMBER)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  g_procedure_name := 'Delete_draft_bc_packets';
  log_message( 'Before delete');

  Delete from pa_bc_packets where budget_version_id = p_draft_bud_ver_id;

  log_message( 'After delete');

 COMMIT;
END;

-- ----------------------------------------------------------------+
-- ## Following procedure will update pa_bc_packets status
-- ----------------------------------------------------------------+
PROCEDURE Update_bc_packets_pass(p_bud_ver_id IN NUMBER)
IS
BEGIN

  g_procedure_name := 'Update_bc_packets_pass';
  log_message( 'Before bcpkt update');

  Update pa_bc_packets
  set    status_code = 'A'
  where  budget_version_id = p_bud_ver_id;

  log_message(SQL%ROWCOUNT||' records updated');

END Update_bc_packets_pass;

-- ---------------------------------------------------------------------------------------------------+
-- This procedure will be called in budget baseline fails
-- Draft budget version will be passed to this procedure, reason: the baselined version
-- is updated only if the budget baseline passed (PAFCBALB: pa_bgt_baseline_pkg.maintain_bal_fchk)
-- ---------------------------------------------------------------------------------------------------+
PROCEDURE Update_bc_packets_fail(p_bud_ver_id IN NUMBER, p_status_code IN VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

  g_procedure_name := 'Update_bc_packets_fail';
  log_message( 'Before bcpkt update');

  Update pa_bc_packets
  set    status_code = decode(status_code,'R',status_code,p_status_code)
  where  budget_version_id = p_bud_ver_id;

  log_message(SQL%ROWCOUNT||' records updated');

     Delete pa_bc_balances
     where  budget_version_id = p_bud_ver_id;

     log_message(SQL%ROWCOUNT||' records deleted');

  COMMIT;

END Update_bc_packets_fail;

-- ----------------------------------------------------------------+
-- ## Following procedure will derive the previous budget version
-- ## Note:
--    Before check_or_reserve_funds (which calls this function)
--    is executed, a baselined budget version is established.
-- ----------------------------------------------------------------+
FUNCTION Get_previous_bvid(p_project_id              IN NUMBER,
                           p_budget_type_code        IN VARCHAR2,
                           p_curr_budget_status_code IN VARCHAR2)
return NUMBER
Is
  l_prev_budget_version_id pa_budget_versions.budget_version_id%TYPE;
Begin
log_message('In function Get_previous_bvid');

 If p_curr_budget_status_code = 'S' then
    -- Draft version is used during "check funds", so get the current
	-- baselined version for reversal
     Select budget_version_id
     into   l_prev_budget_version_id
     from   pa_budget_versions
     where  project_id         = p_project_id
     and    budget_type_code   = p_budget_type_code
     and    budget_status_code = 'B'
     and    current_flag       = 'Y';

 ElsIf p_curr_budget_status_code = 'B' then
    -- Baselined version is used during "baseline", so get the last
	-- baselined version for reversal

     Select MAX(budget_version_id)
     into   l_prev_budget_version_id
     from   pa_budget_versions
     where  project_id         = p_project_id
     and    budget_type_code   = p_budget_type_code
     and    budget_status_code = 'B'
     and    current_flag       = 'N';
     -- Note: If p_old_budget_version_id is null means first time baseline ..
 End If;

 log_message('In function Get_previous_bvid, Prev. budget version id is:'||l_prev_budget_version_id );

 RETURN l_prev_budget_version_id;

End Get_previous_bvid;

-- -------------------------------------------------------------------------------+
-- PROCEDURE Create_events_and_fundscheck
-- Purpose: This procedure create accounting events and calls BC Funds check
--          API for budget baseline/re-baseline/year-end processing/check funds
--          for budget
-- Parameters and values:
-- p_calling_module       - 'Year_End_Rollover' (Year End)/'Cost_Budget'/
--                          'Cmt_Budget'/'Revenue_Budget'/'Dual_Budget'(Budgets)
-- p_mode                 - 'Reserve_Baseline'/'Check_Baseline'/'Force'(Year-end)
-- p_external_budget_code - 'GL'/'CC'/'Dual'
-- p_budget_version_id    -  GL Budget version id
-- p_cc_budget_version_id -  CC Budget version id
-- p_Result_code          - 'S' for success amd 'E' for failure (OUT parameter)
--
-- Called from : check_or_reserve_funds
--               pa_year_end_rollover_pkg.year_end_rollover
-- -------------------------------------------------------------------------------+
PROCEDURE Create_events_and_fundscheck
   (P_calling_module       IN Varchar2,
    P_mode                 IN Varchar2,
    P_External_Budget_Code IN Varchar2,
    P_budget_version_id    IN Number,
    P_cc_budget_version_id IN Number,
    P_result_code         OUT NOCOPY Varchar2)
IS
  l_calling_module    VARCHAR2(20);
  l_cc_calling_module VARCHAR2(20);
  l_data_set_id       pa_budget_versions.budget_version_id%TYPE;
  l_cc_data_set_id    pa_budget_versions.budget_version_id%TYPE;
  l_project_id        pa_projects_all.project_id%TYPE;
  l_budget_type_code  pa_budget_versions.Budget_type_code%TYPE;

  l_return_status      VARCHAR2(1);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(4000);
  l_result_status_code VARCHAR2(20);
  l_bc_mode            VARCHAR2(1);

  BC_SLA_FAILURE       EXCEPTION;

  Cursor c_bc_api_error is
        Select distinct encoded_msg
        from   xla_accounting_errors
        where  event_id in
               (select evt.event_id
                from   xla_events evt,
                       psa_bc_xla_events_gt tmp
                where  evt.event_id = tmp.event_id
                and    evt.process_status_code in ('E','U'));

  Cursor c_event_status is
         select result_code from psa_bc_xla_events_gt
         where  result_code in ('FAIL','XLA_ERROR','FATAL','XLA_NO_JOURNAL');

  l_dummy number;

Begin

 log_message(' In Create_events_and_fundscheck: Start');
 log_message(' Parameters:P_calling_module:['||P_calling_module||']P_mode:['
                         ||P_mode||']P_External_Budget_Code:['||P_External_Budget_Code
                         ||']P_budget_version_id:['||P_budget_version_id||']');


 g_procedure_name := 'Create_events_and_fundscheck';

 -- --------------------------------------------------------------+
 -- ## 1.0: Set result code ..
 -- --------------------------------------------------------------+
    p_result_code := 'S';


 -- --------------------------------------------------------------+
 -- ## 2.0: Set global variables for YEAR-END
 -- --------------------------------------------------------------+

  -- !!!!!!!!!!! CC NOT HANDLED ... !!!!!!!!!!!!
  -- Added this check for the added requirement mentioned in the federal Tracking bug 5686300
  -- for baselining cost budget.

 if  ( P_calling_module <> 'Revenue_Budget' and NVL(FND_PROFILE.value('FV_ENABLED'), 'N') = 'Y') then
    null;
 else

 If P_calling_module = 'Year_End_Rollover'  then

    If nvl(g_debug_mode,'N') = 'N' then
       fnd_profile.get('PA_DEBUG_MODE',g_debug_mode);
       g_debug_mode := nvl(g_debug_mode,'N');
    End If;

    log_message(' Set global variables for Year-End processing');

    If p_budget_version_id is not null then

       Select  PBCO.Balance_type,
       	       PBT.budget_amount_code,
               PBV.project_id,
	       PBV.Budget_type_code
       into    g_balance_type,
               g_budget_amount_code,
               l_project_id,
               l_budget_type_code
       from    PA_BUDGETARY_CONTROL_OPTIONS    PBCO ,
               PA_BUDGET_VERSIONS              PBV,
               PA_BUDGET_TYPES                 PBT
       where   PBV.Budget_version_id = p_budget_version_id
       and     PBCO.Budget_Type_Code = PBV.Budget_Type_Code
       and     PBCO.project_id       = PBV.project_id
       and     PBT.Budget_type_code  = PBV.Budget_type_code;

    End If;

    log_message('--------------------------------');
    log_message(' YREND:budget_type_code : '||l_budget_type_code );
    log_message(' YREND:balance_type : '||g_balance_type );
    log_message(' YREND:l_budget_amount_code : '||g_budget_amount_code);
    log_message('--------------------------------');

    g_cost_rebaseline_flag := PA_FUNDS_CONTROL_UTILS.Is_Budget_Baselined_Before(l_project_id);
    g_cost_current_bvid    := p_budget_version_id;
    g_processing_mode      := 'YEAR_END';

    log_message(' YREND:g_cost_rebaseline_flag : '||g_cost_rebaseline_flag );
    log_message(' YREND:g_cost_current_bvid : '||g_cost_current_bvid);

    If g_cost_rebaseline_flag = 'Y' then

      g_cost_prev_bvid := GET_PREVIOUS_BVID(p_project_id       => l_project_id,
                                            p_budget_type_code => l_budget_type_code,
                                            p_curr_budget_status_code => 'B');
    End If;

    If P_External_Budget_Code = 'GL' then
       g_external_link := 'GL';
    Else
       g_external_link := 'DUAL';
    End If;

    log_message(' YREND:g_cost_prev_bvid : '||g_cost_prev_bvid );
    log_message(' YREND:g_external_link : '||g_external_link);

 End If; -- For Year-End ..


 -- --------------------------------------------------------------+
 -- ## 3.0: Create encumbrance accounting events ...
 -- --------------------------------------------------------------+
    log_message('Create encumbrance accounting events');

    -- --------------------------------------------------------------+
    -- ## 3.1 Derive 'Calling Module'
    -- --------------------------------------------------------------+
    log_message('Derive Calling Module');

    If    (P_calling_module = 'Year_End_Rollover'  and
           P_External_Budget_Code = 'GL'
          ) then

          l_calling_module := 'COST_BUDGET_YEAR_END';
          l_data_set_id    := P_budget_version_id;

    ElsIf (P_calling_module = 'Year_End_Rollover'  and
           P_External_Budget_Code = 'CC'
          ) then

          l_calling_module := 'CC_BUDGET_YEAR_END';
          l_data_set_id    := P_cc_budget_version_id;

    ElsIf (P_calling_module = 'Cost_Budget'  and
           P_External_Budget_Code = 'GL'
          ) then

          l_calling_module := 'COST_BUDGET';
          l_data_set_id    := P_budget_version_id;

    ElsIf (P_calling_module = 'Dual_Budget'  and
           P_External_Budget_Code = 'Dual'
          ) then

          l_calling_module := 'COST_BUDGET';
          l_data_set_id    := P_budget_version_id;

          l_cc_calling_module := 'CC_BUDGET';
          l_cc_data_set_id    := P_cc_budget_version_id;

    ElsIf (P_calling_module = 'Revenue_Budget'  and
           P_External_Budget_Code = 'GL'
          ) then

          l_calling_module := 'REVENUE_BUDGET';
          l_data_set_id    := P_budget_version_id;

   End If;

    -- --------------------------------------------------------------+
    -- ## 3.2 Call pa_xla_interface_pkg.create_events
    -- --------------------------------------------------------------+
    declare
      MOAC_Current_Org NUMBER;
    Begin
      MOAC_Current_Org := MO_GLOBAL.GET_CURRENT_ORG_ID;
      log_message(' In Create_events_and_fundscheck:Calling create events for GL ');

     pa_xla_interface_pkg.create_events
         (p_calling_module => l_calling_module,
	  p_data_set_id    => l_data_set_id,
	  x_result_code    => l_result_status_code); /*6647310*/

     PA_MOAC_UTILS.set_policy_context('S', MOAC_Current_Org);

      If l_result_status_code <> 'Success' then
           log_message(' In Create_events_and_fundscheck: Error creating GL events');
           g_msg_data := 'PA_XLA_EVENT_CREATION_FAILURE';
           RAISE BC_SLA_FAILURE;
      End If;

    Exception
     When others then
        log_message(' In Create_events_and_fundscheck: When Others: Error creating GL events');
        g_msg_data := SQLERRM;

        select length(g_msg_data) into l_dummy from dual;
        If l_dummy > 0 then
           ADD_MESSAGE(substr(g_msg_data,1,200));
           log_message('Create events failed:'||substr(g_msg_data,1,200));
        End if;
        If l_dummy > 200 then
           ADD_MESSAGE(substr(g_msg_data,201,400));
           log_message('Create events failed:'||substr(g_msg_data,201,400));
        End if;

        g_msg_data := 'PA_XLA_EVENT_CREATION_FAILURE';
        RAISE BC_SLA_FAILURE;
    End;

    -- --------------------------------------------------------------+
    -- ## 3.3 Call pa_xla_interface_pkg.create_events for CC
    -- --------------------------------------------------------------+
    /*Commented for bug 6524116
    If (l_cc_calling_module IS NOT null and p_result_code = 'S') then

      log_message(' In Create_events_and_fundscheck:Calling create events for CC ');

      --Begin
       pa_xla_interface_pkg.create_events
         (p_calling_module => l_cc_calling_module,
	  p_data_set_id    => l_cc_data_set_id,
	  x_result_code    => l_result_status_code);

        If l_result_status_code <> 'Success' then
           log_message(' In Create_events_and_fundscheck: Error creating CC events');
           g_msg_data := 'PA_XLA_EVENT_CREATION_FAILURE';
           RAISE BC_SLA_FAILURE;
        End If;

      --Exception
       --When others then
         --log_message(' In Create_events_and_fundscheck: When Others: Error creating CC events');
         --g_msg_data := 'PA_XLA_EVENT_CREATION_FAILURE';
         --RAISE BC_SLA_FAILURE;
      --End;

    End If; --If l_cc_clling_module IS NOT null then
    */

   -- --------------------------------------------------------------+
      log_message(' In Create_events_and_fundscheck: Populating psa_bc_xla_events_gt');

  If p_result_code = 'S' then -- I

     -- --------------------------------------------------------------+
     -- ## 4.0: Populate budgetary control global table
     -- --------------------------------------------------------------+

     -- Code has been moved to PAXLAIFB.pls ..

     -- --------------------------------------------------------------+
     -- ## 5.0: Call Budgetary Controls Funds check API
     -- --------------------------------------------------------------+
      log_message(' In Create_events_and_fundscheck: Calling PSA_BC_XLA_PUB.Budgetary_Control');

         Select decode(p_mode,'Force','F',              -- 'Year End'
                             'Check_Baseline','C',      -- 'Check funds'
                             'Reserve_Baseline','R')    -- 'Baseline'
         into l_bc_mode
         from dual;

          PSA_BC_XLA_PUB.Budgetary_Control
           (p_api_version    => 1.0
           ,p_init_msg_list  => FND_API.G_FALSE
           ,x_return_status  => l_return_status
           ,x_msg_count      => l_msg_count
           ,x_msg_data       => l_msg_data
           ,p_application_id => 275
           ,p_bc_mode        => l_bc_mode
           ,x_status_code    => l_result_status_code
           ,x_packet_id      => g_packet_id
         );
         -- Following paramters are optional and not used:
         --,P_override_flag,P_user_id,P_user_resp_Id

      log_message(' In Create_events_and_fundscheck: After Calling PSA_BC_XLA_PUB.Budgetary_Control');
      log_message(' In Create_events_and_fundscheck: l_return_status,l_result_status_code:'||
                              l_return_status||';'||l_result_status_code);

         If l_return_status in ('E','U') then

             log_message('In Create_events_and_fundscheck:Budgetary control API failed');
             p_result_code := 'E';

              -- -----------------------------------------------------------------------------+
              -- ERROR HANDLING START .....
              -- -----------------------------------------------------------------------------+

              If l_result_status_code is NULL then

                 open c_event_status;
                 loop
                 fetch c_Event_Status into l_result_status_code;
                 exit; -- basically exit after the 1st fetch ..
                 end loop;
                 close c_event_status;

                 log_message(' In Create_events_and_fundscheck: After c_event_status:l_result_status_code:'||l_result_status_code);

              End If;

             for x in c_bc_api_error
             loop

               If p_mode = 'Check_Baseline' then

                 select length(x.encoded_msg) into l_dummy from dual;

                  If l_dummy > 0 then

                     ADD_MESSAGE(substr(x.encoded_msg,1,200)||'...');

                      --FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PA_BUDGET_FUND_PKG',
                      --                         p_procedure_name  => g_procedure_name,
                      --                         p_error_text      => substr(x.encoded_msg,1,230)||'...');
                  End If;

                  If l_dummy > 200 then

                     ADD_MESSAGE('...'||substr(x.encoded_msg,201,400));
                      --FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PA_BUDGET_FUND_PKG',
                      --                         p_procedure_name  => g_procedure_name,
                      --                         p_error_text      => '...'||substr(x.encoded_msg,231,460));
                  End If;

               End If;

                 log_message(substr(x.encoded_msg,1,230)||'...');
                 log_message('...'||substr(x.encoded_msg,231,460));

             end loop;

             If l_dummy is null then
                Begin
                  select -1 into l_dummy from dual where exists
                   (select evt.event_id
                    from   xla_events evt,
                           psa_bc_xla_events_gt tmp
                    where  evt.event_id = tmp.event_id
                    and    evt.process_status_code = 'U');

                  If p_mode = 'Check_Baseline' then

                     If l_result_status_code is null then
                        g_msg_data := 'PA_BC_EVENTS_NOT_PROCESSED';
                        COMMIT;
                        RAISE BC_SLA_FAILURE;
                     Else
                        ADD_MESSAGE('PA_BC_EVENTS_NOT_PROCESSED');
                     End If;

                  End If;

                  log_message('Events not processed');


                Exception
                    when no_data_found then
                          NULL;
                End;

             End If;

              -- -----------------------------------------------------------------------------+
              -- ERROR HANDLING ENDS  .....
              -- -----------------------------------------------------------------------------+

         End If;

         -- ----------------------------------------------------------------------------------+
         -- Following code is to fail draft account, if there is a failure in SLA ...
         -- ----------------------------------------------------------------------------------+
         If ((l_return_status in ('E','U')) OR
             (l_result_status_code in ('FAIL','XLA_ERROR','XLA_NO_JOURNAL','FATAL'))
            ) then
              -- -------------------------------------------------------------------------------+
              -- For Year end, we need draft version, to pass to Fail_draft_acct_summary below
              -- -------------------------------------------------------------------------------+
              If p_mode = 'Force' then
                 Begin

                   Select pbv.budget_version_id
                   into   g_draft_bvid
                   from   pa_budget_versions pbv
                   where  pbv.project_id         = g_project_id
                   and    pbv.budget_status_code = 'W'
                   and    pbv.budget_type_code   = l_budget_type_code;

                  log_message('Force mode, draft bvid: '||g_draft_bvid);

                 Exception
                   When no_data_found then
                        null;
                 End;

               End If;


              -- This new procedure is being called to fail account summary
              -- in case there is a failure in SLA setup ..
              Fail_draft_acct_summary(p_draft_version_id => g_draft_bvid,
                                      p_failure_status   => l_result_status_code);


         End if; -- If l_return_status in ('E','U') then
         -- ----------------------------------------------------------------------------------+

         If p_mode = 'Check_Baseline' then

            COMMIT;  -- this commit will help debug as the events will be visible
                     -- in case of failure. For baseline, we cannot do this commit
                     -- as the bselined budget will get commited ...

         End If;

         If l_result_status_code = 'FAIL' then
            log_message('BC Funds Check validation failed');
            g_msg_data := 'PA_BC_GL_FNDS_RESV_FAIL';
            RAISE BC_SLA_FAILURE;

         ElsIf l_result_status_code = 'XLA_ERROR' then
            log_message('XLA_ERROR: SLA validation failed');
            g_msg_data := 'PA_BC_XLA_ERROR';
            RAISE BC_SLA_FAILURE;

        ElsIf l_result_status_code = 'XLA_NO_JOURNAL' then
           log_message('XLA_NO_JOURNAL: SLA validation complete');
            g_msg_data := 'PA_BC_XLA_ERROR';
            RAISE BC_SLA_FAILURE;

         ElsIf l_result_status_code = 'FATAL' then
            log_message('Fatal error in budgetary control API');
            g_msg_data := 'PA_BC_FATAL';
            RAISE BC_SLA_FAILURE;

         End If;


  End If; -- Status_code = 'S' -- I
  End if ; -- End for Bug 5686300

 log_message(' In Create_events_and_fundscheck: End');

Exception
  When BC_SLA_FAILURE then
       p_result_code := 'E';

--  When others then
--     log_message(' In Create_events_and_fundscheck: '||SQLERRM);
--     p_result_code := 'E';
--     g_msg_data := substr(SQLERRM,1,240);
--     RAISE;

End Create_events_and_fundscheck;

-- Procedure used to add message to stack
PROCEDURE ADD_MESSAGE(p_message IN VARCHAR2)
IS
BEGIN
     FND_MESSAGE.SET_NAME('PA','PA_UNEXPECTED_ERR_AMG');
     FND_MESSAGE.SET_TOKEN('ORAERR',p_message);
     FND_MSG_PUB.ADD;

END ADD_MESSAGE;

-- Procedure used to call pa_debug.write for FND logging
PROCEDURE LOG_MESSAGE(p_message in VARCHAR2)
IS
BEGIN
 IF g_debug_mode = 'Y' then

  IF p_message is NOT NULL then
    pa_debug.g_err_stage := 'Error Msg :'||substr(p_message,1,250);
    --pa_debug.write_file('LOG: '||pa_debug.g_err_stage);
    PA_DEBUG.write
             (x_Module       => 'pa.plsql.PA_BUDGET_FUND_PKG.'||g_procedure_name
             ,x_Msg          => substr(p_message,1,240)
             ,x_Log_Level    => 3);
  END IF;
 END IF;

END LOG_MESSAGE;

-- -----------------------------------------------------------------------+
-- This function is called to determine if any CDLs
-- that could be burdened have not been burdened
-- This can lead to burden cost being dropped off during rebaseline
-- Called from PAXBUEBU.fmb - Budgets form ...
-- -----------------------------------------------------------------------+

FUNCTION Unburdened_cdl_exists(X_project_id IN Number)
RETURN BOOLEAN
IS
   l_burden_method pa_project_types.burden_amt_display_method%Type;
   l_exists        varchar2(1);
BEGIN

  log_message(' In Unburdened_cdl_exists:Check burden method');

  Select decode(NVL(ppt.burden_cost_flag, 'N'),'Y',
                NVL(ppt.burden_amt_display_method,'S'),'N')
  into    l_burden_method
  from    pa_project_types  ppt,
 	      pa_projects_all   pp
  where	  ppt.project_type = pp.project_type
  and     pp.project_id    = X_project_id;

  log_message(' In Unburdened_cdl_exists:Burden method is :'||l_burden_method);

  If l_burden_method <> 'D' then
     -- For no burden 'N', there is no issue
     -- For same line burden 'S', there is no issue as we use burdened cost
     -- during FC ...
     RETURN FALSE;
  Else
   -- Sep line is the issue, as we use BTC for the burden ..
     Select 'Y' into l_exists
     from dual
     where exists
           (select 1
            from   pa_cost_distribution_lines_all cdl
            where  project_id               = X_project_id
            and    burden_sum_source_run_id = -9999
            and    line_type = 'R');     -- Added for Bug 5864881

      log_message(' In Unburdened_cdl_exists: Unburdened CDLs exist');

     RETURN TRUE;
  End If;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
		RETURN FALSE;
End Unburdened_cdl_exists;


-- -----------------------------------------------------------------------+
-- This procedure will update the failure code on the draft version
-- account summary (update only if the lines still have a passed status)
-- We will pass the status of PSA API ...
-- -----------------------------------------------------------------------+

Procedure Fail_draft_acct_summary(p_draft_version_id IN Number,
                                  p_failure_status   IN Varchar2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
Begin

  log_message(' In Fail_draft_acct_summary');
  Update pa_budget_acct_lines
  set    funds_check_status_code = 'R',
         funds_check_result_code = decode(substr(nvl(funds_check_result_code,'P'),1,1),'P',
                                    decode(p_failure_status,
                                        'FAIL',decode(g_processing_mode,
                                               'CHECK_FUNDS','F150','F155'),
                                         'XLA_ERROR','F172',
                                         'XLA_NO_JOURNAL','F172',
                                         'FATAL','F172',
                                         'F172'),funds_check_result_code
                                         )
  where  budget_version_id = p_draft_version_id
  and    (funds_check_status_code = 'A' or
          nvl(funds_check_result_code,'P') like 'P%'
         );

   log_message(' In Fail_draft_acct_summary: Updated '||sql%rowcount||' records');
  COMMIT;

End Fail_draft_acct_summary;

-- ------------------------------------------------------------------------------+
-- ------------------------------------ R12 End ---------------------------------+
-- ------------------------------------------------------------------------------+

END PA_BUDGET_FUND_PKG;

/
