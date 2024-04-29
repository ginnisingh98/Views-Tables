--------------------------------------------------------
--  DDL for Package Body PA_BURDEN_COSTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BURDEN_COSTING" as
-- /* $Header: PAXCBCAB.pls 120.24.12010000.3 2010/02/25 13:51:31 vchilla ship $

--Start Of Mods(SOM) Bug # 5743708
l_tbl_eiid     typ_tbl_eiid;
l_tbl_cdlln    typ_tbl_cdlln;
--End Of Mods(EOM) Bug # 5743708

current_project_id pa_projects_all.project_id%type;
                                 -- Project id of the project being processed.
current_run_id pa_cost_distribution_lines_all.burden_sum_source_run_id%TYPE;  /*Bug# 2255068*/
                                 -- Run id of the batch being processed.
--  3699045
current_sponsored_flag gms_project_types.sponsored_flag%TYPE := 'N' ;

P_DEBUG_MODE BOOLEAN     := pa_cc_utils.g_debug_mode ;

P_BTC_SRC_RESRC varchar2(1) := NVL(FND_PROFILE.value('PA_RPT_BTC_SRC_RESRC'), 'N');  -- 4057874
G_MOAC_ORG_ID                NUMBER ;

-- ======
-- Bug : 3699045 - PJ.M:B4:P13:OTH:PERF:XPL PERFORMANCE ISSUES IN PAVW341.SQL
-- set_current_sponsored_flag, get_current_sponsored_flag were added.
-- ======
PROCEDURE set_current_sponsored_flag(x_project_id in number) IS
  BEGIN
    if pa_gms_api.is_sponsored_project(x_project_id) THEN
       current_sponsored_flag := 'Y' ;
    else
       current_sponsored_flag := 'N' ;
    end if ;
  END set_current_sponsored_flag;

FUNCTION get_current_sponsored_flag RETURN VARCHAR2 IS
  BEGIN
    return current_sponsored_flag;
  END get_current_sponsored_flag;
-- ======
PROCEDURE set_current_project_id(x_project_id in number) IS
  BEGIN
    current_project_id := x_project_id;
  END set_current_project_id;

FUNCTION get_current_project_id RETURN NUMBER IS
  BEGIN
    return current_project_id;
  END get_current_project_id;
/*Bug# 2255068*/
 PROCEDURE set_current_run_id(x_run_id in number)
 IS
 BEGIN
    current_run_id := x_run_id;
 END set_current_run_id;

 FUNCTION get_current_run_id RETURN pa_cost_distribution_lines_all.burden_sum_source_run_id%TYPE
 IS
 BEGIN
    return current_run_id;
 END get_current_run_id;
/*End of changes for bug# 2255068*/

PROCEDURE create_burden_expenditure_item  (p_start_project_number in pa_projects_all.segment1%TYPE,/*2255068*/
                                           p_end_project_number   in pa_projects_all.segment1%TYPE,/*2255068*/
                                           x_request_id           in number,                       /*2255068*/
                                           x_end_date in varchar2,
                                           status   in out NOCOPY number,
                                           stage    in out NOCOPY number,
                                           x_run_id in out NOCOPY number)
IS

 ------------     Declararion of Variables       ---------------

 current_run_id      number;
                -- run id of burden  accounting program for an invokation.
 create_exp_grp_flag boolean := TRUE;
                -- flag to check if new expenditure_group record to be created
 create_exp_flag     boolean := FALSE;
                 -- flag to check if new expenditure record to be created
 init_cdl_run_id     number := -9999;
                -- Initial value of run id in CDL when they are created - Static
 message_string      varchar2(200);
                -- For debugging messages

 exp_group           pa_expenditure_groups_all.expenditure_group%type;
                --  expenditure group id for each run of this program
 exp_id              pa_expenditures_all.expenditure_id%type;
                --  expenditure id of expenditure items
 x_exp_id            pa_expenditures_all.expenditure_id%type;
 exp_item_id         pa_expenditure_items_all.expenditure_item_id%type;
 exp_org_id          pa_expenditure_items_all.organization_id%type;
                --  expenditure organization/override organization
 over_project_id     pa_projects_all.project_id%type;
                --  project id of the source cdl or the project type level override
 over_task_id        pa_tasks.task_id%type;
                --  task id of the source cdl or the project type level override
 prev_bcc_rec        pa_cdl_burden_summary_v%rowtype;
                -- Record to hold previous record from bcc_cur Cursor
 l_attribute1        pa_projects_all.attribute1%type;
                -- local variable to hold attribute1 from project for locking
 l_burden_cost       pa_expenditure_items_all.burden_cost%type;
                -- Running total of burden cost (project functional currency)for an summarization group
 /*
   Multi-Currency Related changes:
   Added local variables to store the sum of burdened_cost in denom and acct currencies
  (also initialised to 0)
 */
 l_denom_burdened_cost       pa_expenditure_items_all.denom_burdened_cost%type := 0;
             -- Running total of burden cost (denom currency)for an summarization group
 l_acct_burdened_cost       pa_expenditure_items_all.acct_burdened_cost%type := 0;
             -- Running total of burden cost (acct currency)for an summarization group
 l_project_burdened_cost       pa_expenditure_items_all.project_burdened_cost%type := 0;
             -- Running total of burden cost (project currency)for a summarization group

 i                   number := 0;  -- running sequence to load EI

 c_task_id           number;
                           -- The current task id. To maintain the current task id so
                           -- call to patc.get_status needs to be called only if task_id
                           -- or project_id or expenditure_type
 c_project_id        number;
                           -- The current project id
 c_expenditure_type  varchar2(30);
                           -- The current expenditure type
 c_billable_flag     varchar2(1);
 l_work_type_id      pa_expenditure_items_all.work_type_id%TYPE := NULL;

                          -- To maintain the current task id, project_id and expenditure_type
                          -- call to patc.get_status needs to be called only if task_id
                          -- or project_id or expenditure_type
 c_status            varchar2(30);
 c_msg_application   VARCHAR2(30) :='PA';
 c_msg_type          VARCHAR2(1) := 'E';
 c_msg_token1        Varchar2(240) := '';
 c_msg_token2        Varchar2(240) :='';
 c_msg_token3        Varchar2(240) :='';
 c_msg_count         Number ;
 l_debug_mode        VARCHAR2(1);

/*x_request_id        Number;                    commented for bug#2255068*/
 l_profile_set_size       NUMBER := 0 ;        /*2255068*/
 l_default_set_size       NUMBER := 500 ;     /*2255068*/
 /*l_last_batch_for_project VARCHAR2(1) := 'N' ; commented for Bug 4747865 */

 l_user_id                NUMBER ;             /*2933915*/
 lstatus                  NUMBER ;             /*3040724*/
 l_status                 NUMBER ;             /*2933915*/
 l_compiled_multiplier    NUMBER ;            /*2933915*/
 l_compiled_set_id        NUMBER ;            /*2933915*/
 l_stage                  NUMBER ;           /*2933915*/
 l_burden_profile         VARCHAR2(2);       /*2933915*/
 ei_update_count          NUMBER ;           /*2933915*/
 cdl_update_count         NUMBER ;           /*2933915*/
 /*reason 	          PA_Expenditure_Items.Ind_Cost_Dist_Rejection_Code%TYPE;   /*2933915*/
 l_proj_bc_enabled        VARCHAR2(1);



 l_prev_expenditure_id    NUMBER ;  -- Bug 3551106
 l_curr_expenditure_id    NUMBER ;  -- Bug 3551106

/* Local variables added for 4057874 */
 l_job_id                       PA_EXPENDITURE_ITEMS_ALL.job_id%type DEFAULT NULL;
 l_nl_resource                  PA_EXPENDITURE_ITEMS_ALL.non_labor_resource%type DEFAULT NULL;
 l_nl_resource_orgn_id          PA_EXPENDITURE_ITEMS_ALL.organization_id%type DEFAULT NULL;
 l_wip_resource_id              PA_EXPENDITURE_ITEMS_ALL.wip_resource_id%type DEFAULT NULL;
 l_incurred_by_person_id        PA_EXPENDITURES_ALL.incurred_by_person_id%type DEFAULT NULL;
 l_inventory_item_id            PA_EXPENDITURE_ITEMS_ALL.inventory_item_id%type DEFAULT NULL;
 l_vendor_id                    PA_COMMITMENT_TXNS.vendor_id%type default null;
 l_bom_labor_resource_id        PA_COMMITMENT_TXNS.bom_equipment_resource_id%type default null;
 l_bom_equipment_resource_id    PA_COMMITMENT_TXNS.bom_labor_resource_id%type default null;

/* Local variables added for 5980459 */
  l_eiid_tbl                    PA_PLSQL_DATATYPES.NUMTabTyp;
  l_task_id_tbl                 PA_PLSQL_DATATYPES.NUMTabTyp;
  l_org_id_tbl                  PA_PLSQL_DATATYPES.NUMTabTyp;
  l_exp_item_date_tbl           PA_PLSQL_DATATYPES.dateTabTyp;
  l_exp_type_tbl                PA_PLSQL_DATATYPES.Char30TabTyp;
  l_status_tbl                  PA_PLSQL_DATATYPES.Char30tabTyp ;
  l_compiled_multiplier_tbl     PA_PLSQL_DATATYPES.NUMtabTyp;
  l_compiled_set_id_tbl         PA_PLSQL_DATATYPES.NUMtabTyp;
  l_stage_tbl                   PA_PLSQL_DATATYPES.Char30tabTyp;
  reason                        PA_PLSQL_DATATYPES.Char30TabTyp;

 /* SOM Bug# 5743708 */
  l_person_type_tbl             PA_PLSQL_DATATYPES.Char30TabTyp;
  l_incur_per_id_tbl            PA_PLSQL_DATATYPES.NUMTabTyp;

  l_cp_structure_tbl            PA_PLSQL_DATATYPES.Char30TabTyp;
  l_cost_base_tbl               PA_PLSQL_DATATYPES.Char30TabTyp;
  l_cp_structure                VARCHAR2(30);
  l_cost_base                   VARCHAR2(30);
  /* EOM Bug# 5743708 */

 ------------     Decalrarion of Cursors       ---------------

 --  Cursor to select all the Projects for which there are non-summarized CDLs

 -- Modifying to select org_id to be passed to LoadEi program
 /*
  * Bug# 924438
  * The Org_id join is created between project and project_type
  */

/* S.N. Bug 3618193 Added Record Type to fetch different cursors */

TYPE proj_rec_type IS RECORD (
                               project_id                  pa_projects_all.project_id%TYPE,
                               segment1                    pa_projects_all.segment1%TYPE,
                               org_id                      pa_projects_all.org_id%TYPE,
                               burden_account_flag         pa_project_types.burden_account_flag%TYPE,
                               dest_project_id             pa_projects_all.project_id%TYPE,
                               dest_task_id                pa_tasks.task_id%TYPE,
                               burden_amt_display_method   pa_project_types.burden_amt_display_method%TYPE
                             );

proj_rec proj_rec_type;


/* SOM Bug# 5743708 */

TYPE Typ_project_id                IS TABLE OF pa_projects_all.project_id%TYPE INDEX BY BINARY_INTEGER;
TYPE Typ_segment1                  IS TABLE OF pa_projects_all.segment1%TYPE INDEX BY BINARY_INTEGER;
TYPE Typ_org_id                    IS TABLE OF pa_projects_all.org_id%TYPE INDEX BY BINARY_INTEGER;
TYPE Typ_burden_account_flag       IS TABLE OF pa_project_types.burden_account_flag%TYPE INDEX BY BINARY_INTEGER;
TYPE Typ_dest_project_id           IS TABLE OF pa_projects_all.project_id%TYPE INDEX BY BINARY_INTEGER;
TYPE Typ_dest_task_id              IS TABLE OF pa_tasks.task_id%TYPE INDEX BY BINARY_INTEGER;
TYPE Typ_burden_amt_display_method IS TABLE OF pa_project_types.burden_amt_display_method%TYPE INDEX BY BINARY_INTEGER;

l_tbl_project_id                     Typ_project_id;
l_tbl_segment1                       Typ_segment1;
l_tbl_org_id                         Typ_org_id;
l_tbl_burden_account_flag            Typ_burden_account_flag;
l_tbl_dest_project_id                Typ_dest_project_id;
l_tbl_dest_task_id                   Typ_dest_task_id;
l_tbl_burden_amt_disp_method         Typ_burden_amt_display_method;

l_end_date                           DATE := to_date(x_end_date,'DD-MM-RR');

l_gms_installed                      boolean;

/* EOM Bug# 5743708 */


/* E.N. Bug 3618193 Added Record Type to fetch different cursors */

/* Changed this cursor for Bug# 5743708 */

Cursor  projects_with_eb IS /* S.N. Bug 3618193 Updated Cursor Name */
 select    p.project_id
         , p.segment1
         , p.org_id
         , upper(nvl(pt.burden_account_flag,'N')) burden_account_flag
         , pt.burden_sum_dest_project_id          dest_project_id
         , pt.burden_sum_dest_task_id             dest_task_id
         , upper(pt.burden_amt_display_method)    burden_amt_display_method
   from  pa_projects_all p, -- pa_projects_all changed to pa_projects for Bug# 5743708 /*pa_projects is changed to pa_projects_all for the bug 6610145*/
         pa_project_types_all pt -- pa_project_types_all changed to pa_project_types for Bug# 5743708 /*pa_project_types is changed to pa_project_types_all for the bug 6610145*/
 where   pt.project_type = p.project_type
   and   p.segment1 between p_start_project_number and p_end_project_number    /*2255068*/
   and   ( pt.burden_amt_display_method in ('D','d') or
           pt.burden_amt_display_method in ('S','s')  and
           pt.burden_account_flag in ('Y','y'))
   and   pt.org_id = p.org_id                                                 /*5368274*/
   /* Bug#3033030 Added the following to check if the project status allows creation of
      burden trasanction */
   and  pa_project_utils.Check_prj_stus_action_allowed(p.project_status_code, 'GENERATE_BURDEN') = 'Y'
   and  (exists  (select 1
                    /* Removed ei ,pa_tasks table and changed cdl_all table to cdl view for bug# 1668634 */
                      from pa_cost_distribution_lines cdl,
/*2255068*/            pa_expenditure_items ei
                 where cdl.line_type                = 'R'
                    and nvl(cdl.amount,0)            <> 0
                    and cdl.burden_sum_source_run_id = init_cdl_run_id
			        and cdl.project_id = p.project_id
		    and ei.expenditure_item_id = cdl.expenditure_item_id
		    and ei.expenditure_item_date <= nvl(l_end_date,ei.expenditure_item_date)
		    )
          or exists  (select 1
                      from pa_cost_distribution_lines cdl,
                           pa_expenditure_items ei
                    where cdl.line_type                = 'R'
                    and   nvl(cdl.amount,0)            <> 0
                    and   cdl.burden_sum_source_run_id >0
	            and   nvl(cdl.reversed_flag,'N') = 'N'
		    and   cdl.line_num_reversed IS NULL
	            and   ei.adjustment_type  ='BURDEN_RESUMMARIZE'
                    and   cdl.project_id          = p.project_id
                    and   ei.project_id           = p.project_id /* Bug# 5743708 */
                    and   ei.expenditure_item_id  = cdl.expenditure_item_id
                    and   ei.expenditure_item_date  <= nvl(l_end_date,ei.expenditure_item_date))
		    );



/* S.N. Bug 3618193 Added one more cursor */

/* Cursor modified for performance issue 9373031 */
Cursor  projects_without_eb is
 select    p.project_id
         , p.segment1
         , p.org_id
         , upper(nvl(pt.burden_account_flag,'N')) burden_account_flag
         , pt.burden_sum_dest_project_id          dest_project_id
         , pt.burden_sum_dest_task_id             dest_task_id
         , upper(pt.burden_amt_display_method)    burden_amt_display_method
   from  pa_projects p,
         pa_project_types pt
 where   pt.project_type = p.project_type
   and   p.segment1 between p_start_project_number and p_end_project_number
   and   ( pt.burden_amt_display_method in ('D','d') or
           pt.burden_amt_display_method in ('S','s')  and
           pt.burden_account_flag in ('Y','y'))
   and   pt.org_id = p.org_id
   and  pa_project_utils.Check_prj_stus_action_allowed(p.project_status_code, 'GENERATE_BURDEN') = 'Y'
   and  exists (
                  select /*+ INDEX (cdl, PA_COST_DISTRIBUTION_LINES_N10) */ 1
                  from pa_cost_distribution_lines cdl
                  where cdl.line_type||''                = 'R'
                    and nvl(cdl.amount,0)            <> 0
                    and cdl.burden_sum_source_run_id = init_cdl_run_id
                    and cdl.project_id               = p.project_id
                    and ( x_end_date is null OR exists
                            (select 1 from pa_expenditure_items ei
                             where ei.expenditure_item_id       = cdl.expenditure_item_id
                             and ei.expenditure_item_date    <= l_end_date )
                         )
               );

/* E.N. Bug 3618193 Added one more cursor */

/* Condition of PA_DATE <= x_end_date added for bug#1171986  */

-- Cursor to select Burden cost components of all the non-summarized CDLs of a project

/*
    Multi-Currency Related changes:
    Picked up additional columns source_denom_burdened_cost,source_acct_burdened_cost,
    source_denom_currency_code, source_acct_currency_code,source_project_currency_code
*/

/*
 * CRL Related Changes
 * Inclued attribute2 - attibute10 and attribute_category in select clause of the bcc_cur
 */

/*Bug# 2368916: Added the hint ordered in the cursor below to ensure that the
                tables  (mainly:PA_COST_BASE_EXP_TYPES) are accessed in the order
                in which it appears in the base view -pa_cdl_burden_detail_v*/

/*========================================================================================+
 | 03-Feb-2004 - M - The grouping used for budgetory control projects and non-budgetory   |
 | control projects are different. This is, to enabled funds-check for change in burden   |
 | cost following burden schedule recompilation for projects with budgetory control       |
 | enabled. The additional grouping is by the adjustment type (=BURDEN_RESUMMARIZE).      |
 +========================================================================================*/
cursor bcc_cur (p_proj_bc_enabled IN VARCHAR2) is
select  source_project_id
       ,source_task_id
       ,source_org_id
       ,source_pa_date
       ,source_attribute1
       ,source_attribute2
       ,source_attribute3
       ,source_attribute4
       ,source_attribute5
       ,source_attribute6
       ,source_attribute7
       ,source_attribute8
       ,source_attribute9
       ,source_attribute10
       ,source_attribute_category
       ,source_person_type
       ,source_po_line_id
       ,source_adjustment_type
       ,source_ind_cost_code
       ,source_expenditure_type
       ,source_ind_expenditure_type
       ,source_cost_base
       ,source_compiled_multiplier
--     ,source_ind_rate_sch_id
--     ,source_ind_rate_sch_rev_id
       ,source_exp_item_id
       ,source_line_num
       ,source_exp_item_date
       ,source_burden_cost
       ,source_denom_burdened_cost
       ,source_acct_burdened_cost
       ,source_project_burdened_cost
       ,source_projfunc_currency_code
       ,source_denom_currency_code
       ,source_acct_currency_code
       ,source_project_currency_code
       ,source_id
       ,source_burden_reject_code
     /*,dest_project_id
       ,dest_task_id                                                :Commented for :3069632*/
       ,dest_org_id
       ,dest_pa_date
       ,dest_attribute1
       ,dest_ind_expenditure_type
       ,billable_flag                                              /* Added for bug 2091559*/
       ,dest_summary_group_resum dest_summary_group_Y   /* Added for bug 5743708*/
       ,dest_summary_group dest_summary_group_N         /* Added for bug 5743708*/
       ,source_request_id                                         /*Bug# 2161261*/
       ,source_system_linkage_function    /* 4057874 */
       ,source_job_id                     /* 4057874 */
       ,source_nl_resource                /* 4057874 */
       ,source_nl_resource_orgn_id        /* 4057874 */
       ,source_wip_resource_id            /* 4057874 */
       ,source_incurred_by_person_id      /* 4057874 */
       ,source_inventory_item_id          /* 4057874 */
       ,source_vendor_id                  /* 4057874 */
       ,src_acct_rate_date
       ,src_acct_rate_type
       ,src_acct_exchange_rate
       ,src_project_rate_date
       ,src_project_rate_type
       ,src_project_exchange_rate
       ,src_projfunc_cost_rate_date
       ,src_projfunc_cost_rate_type
       ,src_projfunc_cost_xchng_rate
from   pa_cdl_burden_summary_v
order by DECODE(p_proj_bc_enabled, 'Y', dest_summary_group_resum, dest_summary_group), source_exp_item_date;

/* Bug S.N. 5406802 */

TYPE ltbl_bcc_cur IS TABLE OF bcc_cur%ROWTYPE INDEX BY BINARY_INTEGER;

bcc_rec   pa_cdl_burden_summary_v%ROWTYPE;
bcc_rec1  pa_cdl_burden_summary_v%ROWTYPE;

l_bcc_rec ltbl_bcc_cur;

l_loop_ctr  NUMBER := 0;

l_next_weekend_date      DATE;
l_prev_next_weekend_date DATE;

/* END Bug 5406802 */


/******2933915:Cursor to select attributes for deriving new compiled set ids for the 'Special eis/cdls':
By SPECIAL eis we mean the one having corresponding summarized cdls and which are marked with adjsutment type
:BURDEN_RESUMMARIZE by the burden compilation process when the profile option PA_ENHANCED_BURDENING is 'Y'****/

/*Bug# 3040724 :We need to derive new compile set id even when burden_sum_source_run_id =-9999 and
  adjustment_type =:BURDEN_RESUMMARIZE*/

CURSOR get_compile_cursor(l_project_id NUMBER )
IS
select ei.expenditure_item_id , ei.task_id,nvl(ei.override_to_organization_id,e.incurred_by_organization_id) organization_id ,
       ei.expenditure_item_date, ei.expenditure_type ,
       e.person_type person_type,
       e.incurred_by_person_id
from pa_cost_distribution_lines cdl,
     pa_expenditure_items ei,
     pa_expenditures  e                                                              /*3040724*/
where cdl.line_type                = 'R'
and   nvl(cdl.amount,0)            <> 0
and   ((cdl.burden_sum_source_run_id >0
         and   cdl.prev_ind_compiled_set_id is NOT NULL)                             /*2933915*/
       OR  cdl.burden_sum_source_run_id = init_cdl_run_id)                           /*3040724*/
and   cdl.request_id               = x_request_id
and   ei.request_id                = x_request_id                   /*2933915*/
and nvl(cdl.reversed_flag,'N') = 'N'
and cdl.line_num_reversed IS NULL
and ei.adjustment_type  ='BURDEN_RESUMMARIZE'
and ei.project_id = l_project_id /* Bug# 5406802 */
and cdl.burden_sum_rejection_code ='IN_PROCESS'                   /*2933915*/
and cdl.project_id               = l_project_id
and ei.expenditure_item_id       = cdl.expenditure_item_id
and ei.expenditure_id            = e.expenditure_id
and ei.expenditure_item_date    <= nvl(l_end_date,ei.expenditure_item_date);/*5743708*/
--GROUP BY ei.expenditure_item_id , ei.task_id, ei.expenditure_item_date, ei.expenditure_type,nvl(ei.override_to_organization_id,e.incurred_by_organization_id) ;
/* added expenditure_item_id in group by for bug 4311703*/
/****2933915****/

   /*Code Changes for Bug No.2984871 start */
   l_rowcount number :=0;
   /*Code Changes for Bug No.2984871 end */

begin

l_gms_installed :=  pa_gms_api.vert_install; /* Bug# 5406802 */

/*  x_request_id:=FND_GLOBAL.CONC_REQUEST_ID();                --Commented for Bug# 2255068*/

    /*2933915 :Caching the value of user_id and burden profile */

    l_user_id:=FND_GLOBAL.USER_ID();

    --l_burden_profile := nvl(fnd_profile.value('PA_ENHANCED_BURDENING'),'N');    /*2933915*/
    l_burden_profile := pa_utils2.IsEnhancedBurdeningEnabled;

  -- Step 1 . Select All projects

     if pa_cc_utils.g_debug_mode then
       l_debug_mode := 'Y';
     else
       l_debug_mode := 'N';
     end if;
     pa_debug.set_process(
                          x_process    => 'PLSQL',
                          x_debug_mode => l_debug_mode);
     pa_debug.G_Err_Stage := 'Starting Create_burden_expenditure_item' ;

     pa_cc_utils.set_curr_function('create_burden_expenditure_item');

     IF P_DEBUG_MODE  THEN
        pa_cc_utils.log_message('50:Entered create_burden_expenditure_item');
     END IF;

    begin
    -- Expenditure group is set to current run id of the program
    -- Pre-fixed with 6 bytes of the MEANING of  'BURDEN_ACCOUNTING'
    -- lookup code 'BS'

    stage := 100;  -- At start

    /*
    IF P_DEBUG_MODE  THEN
       pa_cc_utils.log_message('create_burden_expenditure_item: ' || '100:Select Org_id from Implementations');
    END IF;
    select org_id
      into x_org_id
    from pa_implementations;
    */
    IF P_DEBUG_MODE  THEN
       pa_cc_utils.log_message('Create_Burden_Expenditure_Item: ' || '100:Select Current Org_id.');
    END IF;
    IF ( G_MOAC_ORG_ID IS NULL )
    THEN
        G_MOAC_ORG_ID := pa_moac_utils.get_current_org_id ;
    END IF ;

    /*
     * Bug#2255068
     * Select the profile set size for CDLs per batch.
     */
    FND_PROFILE.GET('PA_NUM_CDL_PER_SET', l_profile_set_size );
    IF ( NVL(l_profile_set_size, 0) = 0 )
    THEN
       l_profile_set_size := l_default_set_size ;
    END IF;
    /* Bug# 2255068
     *  pa_cc_utils.log_message('150:Get Exp Group and Run Id');
     *  select SUBSTRB(meaning,1,6), pa_burden_sum_run_s.nextval
     *    into exp_group, current_run_id
     *    from pa_lookups
     *   where lookup_type = 'BURDEN_ACCOUNTING'
     *     and lookup_code = 'BS'
     *     and sysdate between start_date_active and nvl(end_date_active,sysdate);
     *     exp_group := exp_group||current_run_id;
     */
    exception
      when no_data_found then
          IF P_DEBUG_MODE  THEN
             pa_cc_utils.log_message('create_burden_expenditure_item: ' || '200:Get Exp Group and Run Id:No_Data_Found');
          END IF;
          goto END_OF_PROCESS;
      when others then
          IF P_DEBUG_MODE  THEN
             pa_cc_utils.log_message('create_burden_expenditure_item: ' || '200:Get Exp Group and Run Id:Others');
          END IF;
          goto END_OF_PROCESS;
    end;

/*SOM Bug# 5743708 */

IF (l_burden_profile= 'Y') THEN
   OPEN projects_with_eb;
ELSE
   OPEN projects_without_eb;
END IF;

<<PROJECT_LOOP>>    --  for projects from projects cursor
LOOP

/* Introduced bulk collect logic for the bug# 5406802 */

l_tbl_project_id.delete;
l_tbl_segment1.delete;
l_tbl_org_id.delete;
l_tbl_burden_account_flag.delete;
l_tbl_dest_project_id.delete;
l_tbl_dest_task_id.delete;
l_tbl_burden_amt_disp_method.delete;

IF (l_burden_profile= 'Y') THEN
    FETCH projects_with_eb BULK COLLECT INTO
    l_tbl_project_id,
    l_tbl_segment1,
    l_tbl_org_id,
    l_tbl_burden_account_flag,
    l_tbl_dest_project_id,
    l_tbl_dest_task_id,
    l_tbl_burden_amt_disp_method
    LIMIT 1000;
ELSE
    FETCH projects_without_eb BULK COLLECT INTO
    l_tbl_project_id,
    l_tbl_segment1,
    l_tbl_org_id,
    l_tbl_burden_account_flag,
    l_tbl_dest_project_id,
    l_tbl_dest_task_id,
    l_tbl_burden_amt_disp_method
    LIMIT 1000;
END IF;

EXIT WHEN l_tbl_project_id.count = 0;

/*EOM Bug# 5743708 */


/*  for  proj_rec in projects   loop -- Bug 3618193 */
/* Bug 3618193 : Added following check
   based on the l_burden_profile we will open different cursosrs */


 FOR K in l_tbl_project_id.first..l_tbl_project_id.last


 LOOP

	 proj_rec.project_id := l_tbl_project_id(K);
     proj_rec.segment1 := l_tbl_segment1(K);
     proj_rec.org_id  := l_tbl_org_id(K);
     proj_rec.burden_account_flag :=l_tbl_burden_account_flag(K);
     proj_rec.dest_project_id := l_tbl_dest_project_id(K);
     proj_rec.dest_task_id := l_tbl_dest_task_id(K);
     proj_rec.burden_amt_display_method := l_tbl_burden_amt_disp_method(K);

     IF P_DEBUG_MODE  THEN
        pa_cc_utils.log_message('create_burden_expenditure_item: ' || '250:Processing for Project:'||to_char(proj_rec.project_id));
     END IF;
     stage := 110;  -- in project loop
     -- Set current project id in the package pa_burden_costing for
     -- view definitions and for local variable

     IF P_DEBUG_MODE  THEN
        pa_cc_utils.log_message('create_burden_expenditure_item: ' || '300:before set current project id');
     END IF;

     /*PA_BURDEN_COSTING.set_current_project_id(proj_rec.project_id); 5406802*/


     /*Bug#  5406802*/
     IF l_gms_installed THEN
	     -- ======
	     -- Bug : 3699045 - PJ.M:B4:P13:OTH:PERF:XPL PERFORMANCE ISSUES IN PAVW341.SQL
	     -- ======
	     PA_BURDEN_COSTING.set_current_sponsored_flag(proj_rec.project_id);
     END IF;

     current_project_id := proj_rec.project_id;
     IF P_DEBUG_MODE  THEN
        pa_cc_utils.log_message('create_burden_expenditure_item: ' || '350:after set current project id');
     END IF;

     l_proj_bc_enabled := Pa_Funds_Control_Utils.Get_Fnd_Reqd_Flag(current_project_id, 'STD'); /* 5406802 moved here */

     -- Step 2a.  Project level validations
     -- Set the project and task id of the burden expenditure item
     -- depending on burden_accounting flag

     if (proj_rec.burden_amt_display_method = 'S' )  then
        if ( proj_rec.burden_account_flag = 'Y')   then
             over_project_id  := proj_rec.dest_project_id;
             over_task_id     := proj_rec.dest_task_id;

           IF P_DEBUG_MODE  THEN
              pa_cc_utils.log_message('create_burden_expenditure_item: ' || '400:within if for burden_account and same ei case');
           END IF;
           if over_project_id is null or over_task_id is null then
             begin

                --- Error: PROJECT_TASK_NULL  Destination project and
                --         task not identified when account to seperated
                --         project/task is opted
                --  Mark all the CDLs of the project with error
                stage := 120;  -- in CDL update for project/task null
                IF P_DEBUG_MODE  THEN
                   pa_cc_utils.log_message('create_burden_expenditure_item: ' || '450:before update CDL for error:project_task_null');
                END IF;

           /* Removed ei table and pa_tasks table and changed cdl_all table to cdl view for
              bug# 1668634 */

           /*Bug#2255068:Added loop and committed by batch.*/

           loop
               /*
                * If the Through Date parameter is NOT provided, join to Expenditure Items
                * is NOT required.
                */
                IF ( X_end_date IS NOT NULL )
                THEN
                    update pa_cost_distribution_lines cdl
                     set burden_sum_rejection_code = 'PROJECT_TASK_NULL'
                    where cdl.line_type                 = 'R'
                      and nvl(cdl.amount,0)            <> 0
                      and (cdl.burden_sum_source_run_id  = init_cdl_run_id
		             OR
 			  (cdl.burden_sum_source_run_id >0                             /*2933915*/
			   and nvl(cdl.reversed_flag,'N') = 'N'                        /*2933915*/
			   and cdl.line_num_reversed IS NULL ))                        /*2933915*/
                      and cdl.project_id                = current_project_id
                      and nvl(cdl.burden_sum_rejection_code, 'ABC') <> 'PROJECT_TASK_NULL'      /*2255068*/
                      and exists ( select NULL
                                     from pa_expenditure_items_all ei
                                   where  ei.expenditure_item_id = cdl.expenditure_item_id
                                    and   ei.expenditure_item_date <= l_end_date
                                    )
                      and rownum <= l_profile_set_size ;
                 ELSE
                     update pa_cost_distribution_lines cdl
                      set cdl.burden_sum_rejection_code = 'PROJECT_TASK_NULL'
                      where  cdl.line_type                   = 'R'
                       and nvl(cdl.amount,0)                 <> 0
                       and (cdl.burden_sum_source_run_id      = init_cdl_run_id
				OR
 			  (cdl.burden_sum_source_run_id >0                             /*2933915*/
			   and nvl(cdl.reversed_flag,'N') = 'N'                        /*2933915*/
			   and cdl.line_num_reversed IS NULL ))                        /*2933915*/
                       and cdl.project_id                    = current_project_id
                       and NVL(cdl.burden_sum_rejection_code, 'ABC') <> 'PROJECT_TASK_NULL'
                       and rownum <= l_profile_set_size ;
                END IF;

	/*Code Changes for Bug No.2984871 start */
	l_rowcount:=sql%rowcount;
	/*Code Changes for Bug No.2984871 end */

		COMMIT ;
                IF ( l_rowcount < l_profile_set_size )
                THEN
                   COMMIT ;
                   EXIT ;
                END IF ;
              end loop ;

                IF P_DEBUG_MODE  THEN
                   pa_cc_utils.log_message('create_burden_expenditure_item: ' || '500:after update CDL for error:project_task_null');
                END IF;
                goto NEXT_PROJECT;
             exception
               when others then
                 IF P_DEBUG_MODE  THEN
                    pa_cc_utils.log_message('create_burden_expenditure_item: ' || '550:CDL update:Others');
                 END IF;
                 goto NEXT_PROJECT;
             end;
           end if;
        end if;
     end if;

     -- Step 3.   Lock current project; skip project if locked by other process.
     -- initialize CDLs  run_id so that the view PA_CDL_BURDEN_DETAIL_V  can
     -- pick up all CDLs

     begin
        stage := 130;  -- Locking current project
        IF P_DEBUG_MODE  THEN
           pa_cc_utils.log_message('create_burden_expenditure_item: ' || '600:Lock the current Project');
        END IF;
        select attribute1
          into l_attribute1
          from pa_projects_all
         where project_id = proj_rec.project_id
           for update of attribute1 nowait;
        exception                                      /*2255068*/
          when resource_busy then
            goto NEXT_PROJECT;
          when others then
            goto NEXT_PROJECT;
     end;

       /*
        * Loop for processing CDLs in batches for this project.
        */
       loop

          /***2933915***/

         /**2933915 :To process special eis : Copying previous compiled_set_id with ind_compiled_set_id****/
	 /*This is to insert audit records for affected cdls before starting with summarisation.
	   Since the update immediately after this loop is updating burden_sum_source_run_id so we have to insert audit record before
	   at this point to identify original burden sum source run id to insert in audit table */

       /************ MOVED THE CODE HERE WHICH WAS AFTER THE IF-ENDIF LOGIC (5406802)***********/

       /*Bug#2255068: Run ids are generated once for each batch*/

           select SUBSTRB(meaning,1,6), pa_burden_sum_run_s.nextval
             into exp_group, current_run_id
            from pa_lookups
           where lookup_type = 'BURDEN_ACCOUNTING'
            and lookup_code = 'BS'
            and sysdate between start_date_active and nvl(end_date_active,sysdate);

            exp_group := exp_group||current_run_id;
          /*
           * Bug#2255068
           * Setting the current_run_id in the global variable so that the cdl_burden_detail_v
           * will pick-up only these records.
           */
           PA_BURDEN_COSTING.set_current_run_id(current_run_id);

          /*
           * Bug#2255068
           * Added - so, new expenditure group is created per batch - since the run_id
           * changes for each batch.
           */
           create_exp_grp_flag := TRUE;

/************ END MOVED THE CODE HERE WHICH WAS AFTER THE IF-ENDIF LOGIC (5406802)***********/


   If  l_burden_profile ='Y' Then 		                           /*3040724 :process special eis only when profile is 'Y'*/

       IF P_DEBUG_MODE  THEN
        pa_cc_utils.log_message('create_burden_expenditure_item: ' || '603:Update CDL with prev_ind_compiled_set_id');
       END IF;
        /*SOM Bug# 5743708*/
       l_tbl_eiid.delete;
	   l_tbl_cdlln.delete;
       /*EOM Bug# 5743708*/
 	    UPDATE pa_cost_distribution_lines cdl
 	     SET  cdl.prev_ind_compiled_set_id = decode(cdl.burden_sum_source_run_id,init_cdl_run_id,NULL
                                                 ,cdl.ind_compiled_set_id),                       /*3071338*/
	          request_id                   = x_request_id,
		  burden_sum_rejection_code    = 'IN_PROCESS'                        /*2933915:Stamping it for intermediate processing*/
	     where cdl.line_num_reversed is null
	     and  nvl(cdl.reversed_flag,'N') = 'N'
	     and  cdl.line_type = 'R'
	     and  nvl(cdl.amount,0) <>0
	 /*  and  cdl.burden_sum_source_run_id > 0                       :3040724*/
	 /*  and  cdl.burden_sum_rejection_code IS NULL                  3040274 -Commented to process rejected cdls of previous runs*/
	     and  cdl.project_id = current_project_id
	     and  cdl.request_id <>x_request_id                                 /*2933915*/
	     and exists 	(select null
                                 from pa_expenditure_items ei
                                 where ei.adjustment_type = 'BURDEN_RESUMMARIZE'
                                 and ei.project_id = current_project_id /*5406802*/
                				 and ei.expenditure_item_id = cdl.expenditure_item_id
	 	        	 and ei.expenditure_item_date <= nvl(l_end_date,ei.expenditure_item_date))
             and rownum <= l_profile_set_size          /*2933915*/
             returning expenditure_item_id, line_num bulk collect into l_tbl_eiid, l_tbl_cdlln; /* Bug# 5406802 */


           IF l_tbl_eiid.count > 0 THEN  /* Bug# 5406802 */

               /* Changed this update for Bug# 5406802 */
	      FORALL I in 1..l_tbl_eiid.count
              UPDATE pa_expenditure_items ei
	      set ei.request_id = x_request_id
	      where ei.adjustment_type = 'BURDEN_RESUMMARIZE'
          and   ei.project_id = current_project_id
	      and   ei.request_id <> x_request_id                            /*2933915*/
          and   ei.expenditure_Item_id = l_tbl_eiid(i);


           IF P_DEBUG_MODE  THEN
            pa_cc_utils.log_message('create_burden_expenditure_item: ' || '604:Creating Audit in pa_aud_cost_dist_lines');
           END IF;

	     PA_BURDEN_COSTING.InsBurdenAudit(current_project_id,x_request_id,l_user_id,lstatus);

            /*To get compiled set for special cdls and update on ei and cdl*/

	  IF P_DEBUG_MODE  THEN
           pa_cc_utils.log_message('create_burden_expenditure_item: ' || '605:Deriving compiled set id for special eis');
          END IF;


OPEN get_compile_cursor(current_project_id) ;

  LOOP
      l_eiid_tbl.Delete;
      l_task_id_tbl.Delete;
      l_org_id_tbl.Delete;
      l_exp_item_date_tbl.Delete;
      l_exp_type_tbl.Delete;
      l_stage_tbl.Delete;
      l_status_tbl.Delete;
      l_compiled_multiplier_tbl.Delete;
      l_compiled_set_id_tbl.Delete;
      l_cp_structure_tbl.Delete;/*5743708*/
      l_cost_base_tbl.Delete;/*5743708*/

      FETCH get_compile_cursor BULK COLLECT INTO
	  l_eiid_tbl     ,
	  l_task_id_tbl  ,
	  l_org_id_tbl   ,
	  l_exp_item_date_tbl,
	  l_exp_type_tbl,
      l_person_type_tbl,
	  l_incur_per_id_tbl
      LIMIT l_profile_set_size ;

  --InsertIntoDummy (' After fetching from get compile cursor ');

  IF nvl(l_eiid_tbl.count,0) =0  THEN   /*3134445*/
       EXIT;
  END IF;

FOR i in 1..l_eiid_tbl.count loop

 pa_cost_plus1.get_compile_set_info(p_txn_interface_id  =>l_eiid_tbl(i),
		                    task_id             =>l_task_id_tbl(i),
				    effective_date      =>l_exp_item_date_tbl(i),
		                    expenditure_type    =>l_exp_type_tbl(i),
		                    organization_id     =>l_org_id_tbl(i),
			                schedule_type       =>'C',
                            compiled_multiplier =>l_compiled_multiplier,
		                    compiled_set_id     =>l_compiled_set_id ,
		                    status              =>l_status,
			                stage               =>l_stage,
                            x_cp_structure      =>l_cp_structure,  -- Bug# 5406802
        				    x_cost_base         =>l_cost_base      -- Bug# 5406802
		        		    );

  --InsertIntoDummy (' After get compile set info ');

l_compiled_multiplier_tbl(i) := l_compiled_multiplier;
l_compiled_set_id_tbl(i) := l_compiled_set_id ;

/* S.N. Bug# 5406802 */
l_cp_structure_tbl(i)    := l_cp_structure;
l_cost_base_tbl(i)       := l_cost_base;
/* E.N Bug# 5406802 */

l_status_tbl(i) := l_status;
l_stage_tbl(i) := l_stage ;

/*2933915 :Added Error handling for pa_cost_plus1.get_compile_set_info*/
 IF ((l_status_tbl(i) = 100) and (l_stage_tbl(i) = 400)) THEN     /*Cannot find cost base -burdened cost equals raw cost :2933915*/
     l_compiled_set_id_tbl(i) :=NULL;
 ELSE
  IF (l_status_tbl(i) <>0 ) THEN
      IF (l_status_tbl(i)  = 100) THEN
          IF (l_stage_tbl(i)  = 200) THEN
            reason(i)  := 'NO_IND_RATE_SCH_REVISION';
          ELSIF (l_stage_tbl(i)  = 300) THEN
            reason(i)  := 'NO_COST_PLUS_STRUCTURE';
          ELSIF (l_stage_tbl(i)  = 500) THEN
            reason(i)  := 'NO_ORGANIZATION';
          ELSIF (l_stage_tbl(i)  = 600) THEN
            reason(i)  := 'NO_COMPILED_MULTIPLIER'; --Added for the bug#6033835
          ELSIF (l_stage_tbl(i)  = 700) THEN
            reason(i)  := 'NO_ACTIVE_COMPILED_SET';
          ELSE
            reason(i)  := 'GET_INDIRECT_COST_FAIL';
          END IF;
      ELSE
        reason(i)  := 'GET_INDIRECT_COST_FAIL';
      END IF;
  ELSE
    reason(i) := NULL ;
  END IF ; /*End if for l_status <>0*/
  END IF ;  /*If ((l_status = 100) and (l_stage = 400))*/
END loop ;

   IF P_DEBUG_MODE  THEN
      pa_cc_utils.log_message('create_burden_expenditure_item: ' || '607 STATUS :Update eis/cdls ');/*5980459*/
   END IF;

    FORALL i in 1..l_eiid_tbl.count
	       update pa_cost_distribution_lines cdl
                 set cdl.burden_sum_rejection_code = reason(i),
		     cdl.prev_ind_compiled_set_id  =NULL
                 where   cdl.request_id = x_request_id
	         AND   cdl.project_id = current_project_id
	         AND   cdl.burden_sum_rejection_code ='IN_PROCESS'
	         AND   cdl.expenditure_item_id = l_eiid_tbl(i)
		     AND  (l_status_tbl(i) <> 0) AND (l_stage_tbl(i) <> 400 or l_status_tbl(i) <> 100);

	       /*2933915 : Update affected ei with the newly derived compiled set_id */

    FORALL i in 1..l_eiid_tbl.count
                UPDATE pa_expenditure_items ei
			SET cost_ind_compiled_set_id = l_compiled_set_id_tbl(i)
			where ei.task_id =l_task_id_tbl(i)
			AND  ei.expenditure_type =l_exp_type_tbl(i)
			AND  trunc(ei.expenditure_item_date) =trunc(l_exp_item_date_tbl(i))
			AND  ei.request_id = x_request_id              /*2933915*/
            AND  ei.expenditure_item_id = l_eiid_tbl(i)
		    AND ((l_status_tbl(i) = 0) OR (l_status_tbl(i) =100 AND l_stage_tbl(i) =400)) ;



   	     /*2933915 : Update affected cdl with the newly derived compiled set_id and burden sum source run id as -9999*/

   FORALL i in 1..l_eiid_tbl.count
               UPDATE pa_cost_distribution_lines cdl
		        set ind_compiled_set_id = l_compiled_set_id_tbl(i) ,
		            burden_sum_source_run_id = -9999 ,
			    burden_sum_rejection_code = NULL
		       where cdl.request_id = x_request_id
		       AND   cdl.project_id = current_project_id
		  /*   AND   cdl.prev_ind_compiled_set_id is NOT NULL                   Commented for 3040724*/
               AND   cdl.burden_sum_rejection_code ='IN_PROCESS'                /*2993915*/
		       AND   cdl.expenditure_item_id = l_eiid_tbl(i)
               AND   ((l_status_tbl(i) = 0) OR (l_status_tbl(i) =100 AND l_stage_tbl(i) =400));



  --InsertIntoDummy (' Before inserting into global temp ');
    /* Bug 5896943: Inserting prvdr_accrual_date in place of expenditure_item_date
       for period accrual transactions so that the reversal BTC's will be in the future period.
    */
   /* Insert into global temp table with the Ei's selected by get_compile_cursor Bug# 5406802  */
   /* Modified expenditure item date for 5907315*/
   FORALL i in 1..l_eiid_tbl.count
             insert into PA_EI_CDL_CM_GTEMP(
		 PROJECT_ID			,TASK_ID			,ORGANIZATION_ID
		,PA_DATE			,PA_PERIOD_NAME			,ATTRIBUTE1
		,ATTRIBUTE2			,ATTRIBUTE3			,ATTRIBUTE4
		,ATTRIBUTE5			,ATTRIBUTE6			,ATTRIBUTE7
		,ATTRIBUTE8			,ATTRIBUTE9			,ATTRIBUTE10
		,ATTRIBUTE_CATEGORY		,PERSON_TYPE			,PO_LINE_ID
		,SYSTEM_LINKAGE_FUNCTION	,EI_EXPENDITURE_TYPE		,IND_COMPILED_SET_ID
		,PREV_IND_COMPILED_SET_ID	,EXPENDITURE_ITEM_ID		,LINE_NUM
		,EXPENDITURE_ITEM_DATE		,CDL_AMOUNT                     ,CDL_PROJFUNC_CURRENCY_CODE
		,CDL_DENOM_RAW_COST             ,CDL_DENOM_CURRENCY_CODE        ,CDL_ACCT_RAW_COST
		,CDL_ACCT_CURRENCY_CODE         ,CDL_PROJECT_RAW_COST           ,CDL_PROJECT_CURRENCY_CODE
		,BURDEN_SUM_SOURCE_RUN_ID 	,BURDEN_SUM_REJECTION_CODE 	,SYSTEM_REFERENCE1
		,DENOM_CURRENCY_CODE 	  	,ACCT_CURRENCY_CODE 	  	,PROJECT_CURRENCY_CODE
		,PROJFUNC_CURRENCY_CODE 	,BILLABLE_FLAG			,REQUEST_ID
		,ADJUSTMENT_TYPE		,JOB_ID				,NON_LABOR_RESOURCE
		,NON_LABOR_RESOURCE_ORGN_ID 	,WIP_RESOURCE_ID 	  	,INCURRED_BY_PERSON_ID
		,INVENTORY_ITEM_ID 	  	,COST_PLUS_STRUCTURE            ,COST_BASE
		,ORG_ID                         ,ACCT_RATE_DATE                 ,ACCT_RATE_TYPE
		,ACCT_EXCHANGE_RATE             ,PROJECT_RATE_DATE              ,PROJECT_RATE_TYPE
                ,PROJECT_EXCHANGE_RATE          ,PROJFUNC_COST_RATE_DATE        ,PROJFUNC_COST_RATE_TYPE
                ,PROJFUNC_COST_EXCHANGE_RATE)
		select
		  cdl.project_id                ,cdl.task_id                     ,l_org_id_tbl(i)
		 ,cdl.pa_date  		        ,decode(cdl.prev_ind_compiled_set_id, null, cdl.pa_period_name
 		    ,nvl(pa_utils2.get_pa_period_name(ei.expenditure_item_date, ei.org_id), cdl.pa_period_name))
		 , ei.attribute1
		 , ei.attribute2         	 , ei.attribute3                , ei.attribute4
		 , ei.attribute5 	         , ei.attribute6                , ei.attribute7
		 , ei.attribute8                 , ei.attribute9                , ei.attribute10
		 , ei.attribute_category         , l_person_type_tbl(i)         , ei.po_line_id
		 , ei.system_linkage_function    , ei.expenditure_type          , cdl.ind_compiled_set_id
		 , cdl.prev_ind_compiled_set_id  , ei.expenditure_item_id       , cdl.line_num
 		 , decode(NVL(fnd_profile.value_specific('PA_REVENUE_ORIGINAL_RATE_FORRECALC'),'N'),'N',nvl(ei.prvdr_accrual_date,ei.expenditure_item_date),ei.expenditure_item_date),
		   cdl.amount                   , cdl.projfunc_currency_code
		 , cdl.denom_raw_cost            , cdl.denom_currency_code      , cdl.acct_raw_cost
		 , cdl.acct_currency_code        , cdl.project_raw_cost         , cdl.project_currency_code
		 , current_run_id                , cdl.burden_sum_rejection_code , cdl.system_reference1
		 , ei.denom_currency_code        , ei.acct_currency_code         , ei.project_currency_code
		 , ei.projfunc_currency_code     , cdl.billable_flag             , cdl.request_id
		 , DECODE(ei.system_linkage_function, 'VI', ei.adjustment_type
						  , DECODE(ei.po_line_id, NULL, NULL, ei.adjustment_type) )   adjustment_type
		 , ei.job_id , ei.non_labor_resource
		 , ei.organization_id NON_LABOR_RESOURCE_ORGN_ID  , ei.wip_resource_id , l_incur_per_id_tbl(i)
		 , ei.inventory_item_id          ,l_cp_structure_tbl(i)          ,l_cost_base_tbl(i)
		 , ei.org_id                     ,CDL.ACCT_RATE_DATE             ,CDL.ACCT_RATE_TYPE
                 ,CDL.ACCT_EXCHANGE_RATE         ,CDL.PROJECT_RATE_DATE          ,CDL.PROJECT_RATE_TYPE
                 ,CDL.PROJECT_EXCHANGE_RATE      ,CDL.PROJFUNC_COST_RATE_DATE    ,CDL.PROJFUNC_COST_RATE_TYPE
                 ,CDL.PROJFUNC_COST_EXCHANGE_RATE
		 FROM
		    PA_COST_DISTRIBUTION_LINES_ALL CDL,
		    PA_EXPENDITURE_ITEMS EI
		 WHERE  ei.expenditure_item_id       = l_eiid_tbl(i)
		 AND    cdl.expenditure_item_id      = ei.expenditure_item_id
		 AND    cdl.request_id               = x_request_id
		 AND    cdl.project_id               = current_project_id
		 AND    cdl.burden_sum_rejection_code  is NULL
		 AND    cdl.line_type                = 'R'
 		 AND    ( ei.transaction_source IS NULL
		 or pa_utils2.get_ts_allow_burden_flag(ei.transaction_source)<>'Y' );

   --InsertIntoDummy (' After inserting into global temp ');


 END LOOP;
close get_compile_cursor ;
End If;	   /* End If for l_tbl_eiid.count > 0 */

/*Commented for bug 5980459
	FOR rec IN get_compile_cursor(current_project_id)
	 LOOP

		/*Deriving new compiled set id for the 'special' eis
		 pa_cost_plus1.get_compile_set_info(p_txn_interface_id  =>rec.expenditure_item_id, /*bug 4311703
                                                    task_id             =>rec.task_id,
			  	                    effective_date      =>rec.expenditure_item_date,
					            expenditure_type    =>rec.expenditure_type,
					            organization_id     => rec.organization_id,
					            schedule_type       =>'C',
				                    compiled_multiplier =>l_compiled_multiplier,
                                                    compiled_set_id     => l_compiled_set_id ,
						    status              => l_status,
						    stage               => l_stage);

             /*2933915 :Added Error handling for pa_cost_plus1.get_compile_set_info
         IF ((l_status = 100) and (l_stage = 400)) THEN     /*Cannot find cost base -burdened cost equals raw
	                                                  cost :2933915
             l_compiled_set_id :=NULL;
         ELSE
	     IF (l_status <>0 ) THEN
                        IF (l_status = 100) THEN
                           IF (l_stage = 200) THEN
                             reason := 'NO_IND_RATE_SCH_REVISION';
                           ELSIF (l_stage = 300) THEN
                              reason := 'NO_COST_PLUS_STRUCTURE';
                           ELSIF (l_stage = 500) THEN
                              reason := 'NO_ORGANIZATION';
                           ELSIF (l_stage = 600) THEN
                              reason := 'NO_COMPILED_MULTIPLIER';
                           ELSIF (l_stage = 700) THEN
                              reason := 'NO_ACTIVE_COMPILED_SET';
                           ELSE
                              reason := 'GET_INDIRECT_COST_FAIL';
                          END IF;
                        ELSE
                              reason := 'GET_INDIRECT_COST_FAIL';
                        END IF;

	   IF P_DEBUG_MODE  THEN
            pa_cc_utils.log_message('create_burden_expenditure_item: ' || '606:Update CDL with rejection reason ');
           END IF;

	       update pa_cost_distribution_lines cdl
                 set cdl.burden_sum_rejection_code = reason,
		     cdl.prev_ind_compiled_set_id  =NULL
                 where   cdl.request_id = x_request_id
	         AND   cdl.project_id = current_project_id
	      /* AND   cdl.prev_ind_compiled_set_id is NOT NULL                           :3040724
                 AND   cdl.burden_sum_rejection_code ='IN_PROCESS'
	         AND   cdl.expenditure_item_id in (select ei.expenditure_item_id
	                                           from pa_expenditure_items_all ei,
			  		                pa_expenditures_all e
					           where e.expenditure_id =ei.expenditure_id
					           AND  ei.task_id =rec.task_id
					           AND  ei.expenditure_type =rec.expenditure_type
					           AND  ei.expenditure_item_date =rec.expenditure_item_date
	                                           AND  rec.organization_id = nvl(ei.override_to_organization_id,
						       e.incurred_by_organization_id)
					           AND ei.adjustment_type = 'BURDEN_RESUMMARIZE'
					      );
             END IF ; /*End if for l_status <>0
         END IF ;  /*If ((l_status = 100) and (l_stage = 400))

	       /*2933915 : Update affected ei with the newly derived compiled set_id

	   IF P_DEBUG_MODE  THEN
            pa_cc_utils.log_message('create_burden_expenditure_item: ' || '607:Update eis/cdls with newly derived compiled set id ');
           END IF;

         IF ((l_status = 0) OR (l_status =100 AND l_stage =400)) THEN

		UPDATE pa_expenditure_items ei
		SET cost_ind_compiled_set_id = l_compiled_set_id
		where ei.adjustment_type = 'BURDEN_RESUMMARIZE'
		AND  ei.task_id =rec.task_id
		AND  ei.expenditure_type =rec.expenditure_type
		AND  ei.project_id =current_project_id
		AND  trunc(ei.expenditure_item_date) =trunc(rec.expenditure_item_date)
		AND  ei.request_id = x_request_id              /*2933915
		AND  exists (select 1
			     from pa_expenditures e,
			          pa_cost_distribution_lines cdl
			     where e.expenditure_id =ei.expenditure_id
			     AND   cdl.expenditure_item_id =ei.expenditure_item_id
			     AND   cdl.burden_sum_rejection_code ='IN_PROCESS'
			     AND nvl(ei.override_to_organization_id,e.incurred_by_organization_id)=rec.organization_id);


   	     /*2933915 : Update affected cdl with the newly derived compiled set_id and burden sum source run id as -9999

               UPDATE pa_cost_distribution_lines cdl
	        set ind_compiled_set_id = l_compiled_set_id ,
	            burden_sum_source_run_id = -9999 ,
		    burden_sum_rejection_code = NULL
	       where cdl.request_id = x_request_id
	       AND   cdl.project_id = current_project_id
	  /*   AND   cdl.prev_ind_compiled_set_id is NOT NULL                   Commented for 3040724
               AND   cdl.burden_sum_rejection_code ='IN_PROCESS'                /*2993915
	       AND   cdl.expenditure_item_id in (select ei.expenditure_item_id
	                                         from pa_expenditure_items_all ei,
		  			              pa_expenditures_all e
					         where e.expenditure_id =ei.expenditure_id
					         AND  ei.task_id =rec.task_id
					         AND  ei.expenditure_type =rec.expenditure_type
					         AND  ei.expenditure_item_date =rec.expenditure_item_date
	                                         AND  rec.organization_id = nvl(ei.override_to_organization_id,e.incurred_by_organization_id)
					         AND ei.adjustment_type = 'BURDEN_RESUMMARIZE'
					      );

	/*        COMMIT; commented for bug4747865
         END IF ;  /*2933915 :End if -((status = 0) OR (status =100 AND stage =400))
        END LOOP; /* End loop for get_compile_cursor
*/
         IF P_DEBUG_MODE  THEN
            pa_cc_utils.log_message('create_burden_expenditure_item: ' || '608:Special cdls are also ready for resummarized now ');
         END IF;
     End if ; /*End of profile option check :3040724*/

	 /*End of changes for 2933915*/

        begin
        stage := 140;                     -- Locking CDLs, initializing rejection code

        IF P_DEBUG_MODE  THEN
           pa_cc_utils.log_message('create_burden_expenditure_item: ' || '650:Lock the CDLs');
        END IF;

        /*Bug#2255068 :Resetting this flag */

         /*l_last_batch_for_project := 'N' ; * Bug 4747865 */

        /*
         * Bug#2255068
         * The following update is modified to update a set of CDLs to the current_run_id.
         * The cdl_burden_detail_v picks up CDLs of this run_id.
         * Also this update is modified to update cdls on the basis of ei date(and not on
         * pa_date.
         */
         IF ( X_end_date IS NOT NULL )
         THEN
           /* Removed ei table and pa_tasks table and changed cdl_all table to cdl view for
              bug# 1668634
            */
	    /* Bug# 9373031: Added hint for performane issue */

          update /*+ INDEX (cdl, PA_COST_DISTRIBUTION_LINES_N10) */ pa_cost_distribution_lines cdl
               set burden_sum_rejection_code = NULL,
                   request_id                = x_request_id,                    /*2161261*/
                   burden_sum_source_run_id  = current_run_id
         where cdl.line_type               = 'R'
           and nvl(cdl.amount,0)           <> 0
           and cdl.burden_sum_source_run_id = init_cdl_run_id
	   and (burden_sum_rejection_code = 'IN_PROCESS' or   /*Added for the bug#5949107*/
	        request_id                <> x_request_id or
		burden_sum_rejection_code is null)
           and cdl.project_id               = current_project_id
           and exists
                (select  null
                  from  pa_expenditure_items_all ei
                 where  ei.expenditure_item_id = cdl.expenditure_item_id
                 and  ei.expenditure_item_date <= l_end_date
                 )
           and rownum <= l_profile_set_size;
          /*and cdl.PA_DATE                 <= nvl(l_end_date,cdl.PA_DATE); Bug# 2255068*/
         ELSE
	 /* Bug# 9373031: Added hint for performane issue */
          update /*+ INDEX (cdl, PA_COST_DISTRIBUTION_LINES_N10) */ pa_cost_distribution_lines cdl
            set burden_sum_rejection_code = NULL,
                request_id                = x_request_id,                                        /*2161261*/
                burden_sum_source_run_id  = current_run_id
          where cdl.line_type               = 'R'
           and nvl(cdl.amount,0)           <> 0
	   and (burden_sum_rejection_code = 'IN_PROCESS' or   /*Added for the bug#5949107*/
	        request_id                <> x_request_id or
		burden_sum_rejection_code is null)
           and cdl.burden_sum_source_run_id = init_cdl_run_id
           and cdl.project_id               = current_project_id
           and rownum <= l_profile_set_size;

	END IF;

         IF ( SQL%ROWCOUNT = 0 )
         THEN
            /*
             * Completed processing all CDLs for this project.
             */
            EXIT ;
         /*ELSIF ( SQL%ROWCOUNT < l_profile_set_size )
         THEN
             l_last_batch_for_project := 'Y' ; * Bug 4747865 */
         END IF;

         /*
          * Bug#2255068
          * The following update ensures that all CDLs of an EI gets processed
          * in the same batch.
          */
           /* Bug# 9373031: Added hint for performane issue */
	   update /*+ INDEX (cdl, PA_COST_DISTRIBUTION_LINES_N10) */ pa_cost_distribution_lines cdl
             set burden_sum_rejection_code = NULL
                ,request_id                = x_request_id
                ,burden_sum_source_run_id  = current_run_id
            where cdl.line_type                  = 'R'
              and nvl(cdl.amount,0)             <> 0
              and cdl.burden_sum_source_run_id   = init_cdl_run_id
              and cdl.project_id                 = current_project_id
	      and (burden_sum_rejection_code = 'IN_PROCESS' or   /*Added for the bug#5949107*/
	        request_id                <> x_request_id or
		burden_sum_rejection_code is null)
              and exists
                  (select NULL
                    from pa_cost_distribution_lines cdl1
                   where cdl1.burden_sum_source_run_id+0 = current_run_id
                   and cdl1.burden_sum_rejection_code is NULL                        /*3071338*/
                    and cdl1.expenditure_item_id= cdl.expenditure_item_id) ;

          /*
           * Bug#2255068
           * The rollback statements in the exception clause is added to avoid
           * any unsummarized CDL getting left-out with a valid source_run_id -
           * due to the above update.
           */
       exception
         when resource_busy then
            IF P_DEBUG_MODE  THEN
               pa_cc_utils.log_message('create_burden_expenditure_item: ' || '700:Lock the CDLs:Resource_busy');
            END IF;
            ROLLBACK;
            goto NEXT_PROJECT;
         when others then
            ROLLBACK;
            IF P_DEBUG_MODE  THEN
               pa_cc_utils.log_message('create_burden_expenditure_item: ' || '700:Lock the CDLs:Others');
            END IF;
            goto NEXT_PROJECT;
      end;


      l_denom_burdened_cost := 0;   /* Bug 1535280 Initialised for every project run */
      prev_bcc_rec.dest_summary_group   := null;
      l_burden_cost                     := 0;
       /*
        * l_project_burdened_cost is newly added and i'm initializing it.
        * but l_acct_burdened_cost was already there and i'm initializing it now - because
        * i thought it should be. It should have been done with bug 1535280 itself. -rahariha
        */
       l_acct_burdened_cost              := 0;
       l_project_burdened_cost           := 0;

       /* Bug# 685104 - Intializing for the next project.*/
       prev_bcc_rec.source_org_id := null;
       prev_bcc_rec.billable_flag := null;  /*bug# 2091559*/
     -- Step 4. select Burden cost components of CDLs.

     /* SOM    Bug# 5406802 */

     populate_gtemp(current_run_id, current_project_id, x_end_date);
     update_gtemp(x_request_id); /*Added for the bug#5949107*/

     /* EOM    Bug# 5406802 */
     begin

     IF P_DEBUG_MODE  THEN
        pa_cc_utils.log_message('create_burden_expenditure_item: ' || '850:call Flusheitabs');
     END IF;
     pa_transactions.FlushEiTabs();
     i := 0;
     /*=========================================================+
      | CWK - See if the project has Budgetory control enabled. |
      +=========================================================*/
      /* Introduced bulk collect logic for bcc cursor for Bug# 5406802 */

     l_bcc_rec.delete;
     bcc_rec := bcc_rec1;
     l_loop_ctr := 0;

     open bcc_cur(l_proj_bc_enabled);
     fetch bcc_cur BULK COLLECT INTO l_bcc_rec;
     close bcc_cur;

     FOR bcc_rec_loop in 1..l_bcc_rec.count /* l_bcc_rec.FIRST..l_bcc_rec.LAST in bcc_cur(l_proj_bc_enabled)  loop */
     LOOP
       l_loop_ctr  := l_loop_ctr + 1;

	bcc_rec.source_project_id            := l_bcc_rec(l_loop_ctr).source_project_id            ;
	bcc_rec.source_org_id                := l_bcc_rec(l_loop_ctr).source_org_id                ;
	bcc_rec.source_attribute1            := l_bcc_rec(l_loop_ctr).source_attribute1            ;
	bcc_rec.source_attribute3            := l_bcc_rec(l_loop_ctr).source_attribute3            ;
	bcc_rec.source_attribute5            := l_bcc_rec(l_loop_ctr).source_attribute5            ;
	bcc_rec.source_attribute7            := l_bcc_rec(l_loop_ctr).source_attribute7            ;
	bcc_rec.source_attribute9            := l_bcc_rec(l_loop_ctr).source_attribute9            ;
	bcc_rec.source_task_id               := l_bcc_rec(l_loop_ctr).source_task_id               ;
	bcc_rec.source_pa_date               := l_bcc_rec(l_loop_ctr).source_pa_date               ;
	bcc_rec.source_attribute2            := l_bcc_rec(l_loop_ctr).source_attribute2            ;
	bcc_rec.source_attribute4            := l_bcc_rec(l_loop_ctr).source_attribute4            ;
	bcc_rec.source_attribute6            := l_bcc_rec(l_loop_ctr).source_attribute6            ;
	bcc_rec.source_attribute8            := l_bcc_rec(l_loop_ctr).source_attribute8            ;
	bcc_rec.source_attribute10           := l_bcc_rec(l_loop_ctr).source_attribute10           ;
	bcc_rec.source_attribute_category    := l_bcc_rec(l_loop_ctr).source_attribute_category    ;
	bcc_rec.source_ind_cost_code         := l_bcc_rec(l_loop_ctr).source_ind_cost_code         ;
	bcc_rec.source_expenditure_type      := l_bcc_rec(l_loop_ctr).source_expenditure_type      ;
	bcc_rec.source_ind_expenditure_type  := l_bcc_rec(l_loop_ctr).source_ind_expenditure_type  ;
	bcc_rec.source_cost_base             := l_bcc_rec(l_loop_ctr).source_cost_base             ;
	bcc_rec.source_compiled_multiplier   := l_bcc_rec(l_loop_ctr).source_compiled_multiplier   ;

	bcc_rec.source_exp_item_id           := l_bcc_rec(l_loop_ctr).source_exp_item_id           ;
	bcc_rec.source_line_num              := l_bcc_rec(l_loop_ctr).source_line_num              ;
	bcc_rec.source_exp_item_date         := l_bcc_rec(l_loop_ctr).source_exp_item_date         ;
	bcc_rec.source_burden_cost           := l_bcc_rec(l_loop_ctr).source_burden_cost           ;
	bcc_rec.source_denom_burdened_cost   := l_bcc_rec(l_loop_ctr).source_denom_burdened_cost   ;
	bcc_rec.source_acct_burdened_cost    := l_bcc_rec(l_loop_ctr).source_acct_burdened_cost    ;
	bcc_rec.source_project_burdened_cost := l_bcc_rec(l_loop_ctr).source_project_burdened_cost  ;
	bcc_rec.source_denom_currency_code   := l_bcc_rec(l_loop_ctr).source_denom_currency_code    ;
	bcc_rec.source_project_currency_code := l_bcc_rec(l_loop_ctr).source_project_currency_code  ;
	bcc_rec.source_burden_reject_code    := l_bcc_rec(l_loop_ctr).source_burden_reject_code     ;
	bcc_rec.dest_pa_date                 := l_bcc_rec(l_loop_ctr).dest_pa_date                  ;
	bcc_rec.dest_ind_expenditure_type    := l_bcc_rec(l_loop_ctr).dest_ind_expenditure_type     ;

	bcc_rec.source_incurred_by_person_Id := l_bcc_rec(l_loop_ctr).source_incurred_by_person_id  ;
	bcc_rec.source_vendor_id             := l_bcc_rec(l_loop_ctr).source_vendor_id;


	IF  l_proj_bc_enabled = 'Y' THEN
	   bcc_rec.dest_summary_group           := l_bcc_rec(l_loop_ctr).dest_summary_group_Y;
        ELSE
	   bcc_rec.dest_summary_group           := l_bcc_rec(l_loop_ctr).dest_summary_group_N;
	END IF;

	bcc_rec.source_projfunc_currency_code:= l_bcc_rec(l_loop_ctr).source_projfunc_currency_code;
	bcc_rec.source_acct_currency_code    := l_bcc_rec(l_loop_ctr).source_acct_currency_code    ;
	bcc_rec.source_id                    := l_bcc_rec(l_loop_ctr).source_id                    ;
	bcc_rec.dest_org_id                  := l_bcc_rec(l_loop_ctr).dest_org_id                  ;
	bcc_rec.dest_attribute1              := l_bcc_rec(l_loop_ctr).dest_attribute1              ;
	bcc_rec.billable_flag                := l_bcc_rec(l_loop_ctr).billable_flag                ;
	bcc_rec.source_request_id            := l_bcc_rec(l_loop_ctr).source_request_id            ;


	stage := 160;  -- In bcc_cur cursor


         -- 5a. For each invokation  create only one expenditure group.

            IF P_DEBUG_MODE  THEN
               pa_cc_utils.log_message('create_burden_expenditure_item: ' || '900:Processing for:'||bcc_rec.dest_summary_group);
            END IF;
            if  (create_exp_grp_flag ) then
                IF P_DEBUG_MODE  THEN
                   pa_cc_utils.log_message('create_burden_expenditure_item: ' || '950:call to insertexpgroup');
                END IF;
                pa_transactions.InsertExpGroup(exp_group,'APPROVED',sysdate,'BTC',0,NULL,NULL,G_MOAC_ORG_ID);
                IF P_DEBUG_MODE  THEN
                   pa_cc_utils.log_message('create_burden_expenditure_item: ' || '1000:back from insertexpgroup');
                END IF;
                -- Handle error
                create_exp_grp_flag := FALSE;
            end if;

        -- 5b. Create expenditures for every organization change if expenditure is not
        --     created for the organization during the run.

          If P_BTC_SRC_RESRC = 'Y' then  -- added for 4057874

          pa_client_extn_burden_resource.client_column_values (
                         p_job_id => l_job_id,
                         p_non_labor_resource => l_nl_resource,
                         p_non_labor_resource_orgn_id => l_nl_resource_orgn_id,
                         p_wip_resource_id => l_wip_resource_id,
                         p_incurred_by_person_id => bcc_rec.source_incurred_by_person_id,
                         p_inventory_item_id => l_inventory_item_id,
                         p_vendor_id => l_vendor_id,
                         p_bom_labor_resource_id => l_bom_labor_resource_id,
                         p_bom_equipment_resource_id => l_bom_equipment_resource_id);
          else
              bcc_rec.source_incurred_by_person_id := null;

          end if; -- profile option

            /* Introduced Caching for deriving weekend date for Bug# 5406802 */
          IF prev_bcc_rec.source_exp_item_date IS NULL THEN
	     l_next_weekend_date      := pa_utils.NewGetWeekEnding(bcc_rec.source_exp_item_date);
	     ELSE
             l_prev_next_weekend_date := l_next_weekend_date;
	     l_next_weekend_date      := pa_utils.NewGetWeekEnding(bcc_rec.source_exp_item_date);
          END IF;

	  /* Changed the if condition for Bug# 5406802 */
	    if (    bcc_rec.source_org_id = prev_bcc_rec.source_org_id
  	        -- Bug 3551106 : Added following And condition, new expenditure should be
		-- created whenever there is a chane in week ending date.
	        and l_next_weekend_date
		    = l_prev_next_weekend_date
             and nvl(bcc_rec.source_incurred_by_person_id,-99) = nvl(prev_bcc_rec.source_incurred_by_person_id,-99)  -- 4057874
             and nvl(bcc_rec.source_vendor_id,-99) = nvl(prev_bcc_rec.source_vendor_id,-99) )then  -- 4057874


               create_exp_flag := FALSE;
            else
        -- begining of a block to process items
               begin
                  IF P_DEBUG_MODE  THEN
                     pa_cc_utils.log_message('create_burden_expenditure_item: ' || '1050:Get Expenditure Information');
                  END IF;
                  /*===================================================+
                   | Bug 4115096 : Added person_id check to create new |
                   | Expenditure for change in person.                 |
                   +===================================================*/

                  /* Changed this query for Bug# 5406802 */

                  select expenditure_id,incurred_by_organization_id
                    into exp_id,exp_org_id
                    from pa_expenditures_all
                   where expenditure_group           = exp_group
                     and incurred_by_organization_id = bcc_rec.source_org_id
                     and NVL(incurred_by_person_id,-99) = nvl(bcc_rec.source_incurred_by_person_id,-99) -- changes done for 4324340 . Bug 4115096 and added NVL By 4282553
                     and expenditure_ending_date = l_next_weekend_date -- Bug 3551106
                     and nvl(vendor_id,-99) = nvl(bcc_rec.source_vendor_id,-99);  -- Bug 6993002

		  IF P_DEBUG_MODE  THEN
                     pa_cc_utils.log_message('create_burden_expenditure_item: ' || 'See ->exp_id'||exp_id);
                  END IF;
               exception
                when no_data_found then
                 IF P_DEBUG_MODE  THEN
                    pa_cc_utils.log_message('create_burden_expenditure_item: ' || '1100:Get Expenditure Information:No_data_found');
                 END IF;
                 create_exp_flag := TRUE;
                 exp_org_id      := bcc_rec.source_org_id;
               end;

            end if;

            if  (create_exp_flag ) then
               -- Get new expenditure id
               IF P_DEBUG_MODE  THEN
                  pa_cc_utils.log_message('create_burden_expenditure_item: ' || '1150:Get Expenditure Id from sequence');
               END IF;
               select pa_expenditures_s.nextval
                 into exp_id from dual;
              stage := 170;  -- Creating burden expenditure

	       l_curr_expenditure_id :=  exp_id ;  -- Bug 3551106

	       -- Bug# 685104 -Creating Burden Cost Component by the period End date

    /*
    Multi-Currency Related changes: Added additional parameters (denom currency code and acct currency code;
    all other currency attributes are set to null)
    */
                                 IF P_DEBUG_MODE  THEN
                                    pa_cc_utils.log_message('create_burden_expenditure_item: ' || '1200:Call InsertExp');
                                 END IF;
                                 pa_transactions.InsertExp(
                                        x_expenditure_id =>exp_id,
                                        x_expend_status =>'APPROVED',
                                        x_expend_ending => pa_utils.NewGetWeekEnding((bcc_rec.source_exp_item_date)),   --Bug 2236707,3551106
                                    --  x_expend_ending =>pa_utils.NewGetWeekEnding(pa_utils2.get_pa_period_end_date_OU(bcc_rec.source_pa_date)-6), -- Bug 2933915,3551106
                                        x_expend_class => 'BT',
                                        x_inc_by_person => bcc_rec.source_incurred_by_person_id, -- 4057874
                                        x_inc_by_org => bcc_rec.source_org_id,
                                        x_expend_group => exp_group,
                                        x_entered_by_id =>exp_org_id,
                                        x_created_by_id =>0,
                                        x_attribute_category => null,
                                        x_attribute1 => null,
                                        x_attribute2 => null,
                                        x_attribute3 => null,
                                        x_attribute4 => null,
                                        x_attribute5 => null,
                                        x_attribute6 => null,
                                        x_attribute7 => null,
                                        x_attribute8 => null,
                                        x_attribute9 => null,
                                        x_attribute10=> null,
                                        x_description=> null,
                                        x_control_total=> null,
                                        x_denom_currency_code =>bcc_rec.source_denom_currency_code,
                                        x_acct_currency_code => bcc_rec.source_acct_currency_code,
                                        x_acct_rate_type => null,
                                        x_acct_rate_date => null,
                                        x_acct_exchange_rate=> null
                                       ,X_person_type => bcc_rec.source_person_type
                                       ,X_vendor_id => bcc_rec.source_vendor_id -- 4057874
				       ,P_Org_Id => G_MOAC_ORG_ID
                                     );

                                       IF P_DEBUG_MODE  THEN
                                          pa_cc_utils.log_message('create_burden_expenditure_item: ' || '1250:Back from InsertExp');
                                       END IF;
  -- Setting the flag to false to avoid unnecessary insertion of the records
  -- 09/11/98
                create_exp_flag := FALSE;
            end if;

        -- 5c. Create expenditure item for every dest_summary_group change

      if  bcc_rec.dest_summary_group = prev_bcc_rec.dest_summary_group and NVL(l_prev_expenditure_id,-1) = NVL(l_curr_expenditure_id,-1) then -- Bug 3551106
               IF P_DEBUG_MODE  THEN
                  pa_cc_utils.log_message('create_burden_expenditure_item: ' || '1300:No change in Summary Group ..');
               END IF;
               l_burden_cost := l_burden_cost + bcc_rec.source_burden_cost;

     /*
       Multi-Currency Related changes: Sum up burdened_cost in denom and Acct currencies also
    */
               l_denom_burdened_cost := l_denom_burdened_cost + bcc_rec.source_denom_burdened_cost;
               l_acct_burdened_cost := l_acct_burdened_cost + bcc_rec.source_acct_burdened_cost;
               l_project_burdened_cost := l_project_burdened_cost + bcc_rec.source_project_burdened_cost;

 /****Bug# 3611675 :Commenting this as it is a redundant code now      ***

               -- Check for other attributes of summarized burden expenditure item
             if nvl(bcc_rec.source_attribute1,'X') <> nvl(prev_bcc_rec.source_attribute1,'X') then
                   l_attribute1 := '';  -- nullify the attribute1 column
             else
                   l_attribute1 := prev_bcc_rec.source_attribute1;
             end if;
******/
      else
            IF P_DEBUG_MODE  THEN
               pa_cc_utils.log_message('create_burden_expenditure_item: ' || '1350:Change in Summary Group ..');
            END IF;

            -- Create new summarization expenditure item
            -- Get new expenditure item id
            -- Checking for l_burden_cost <> 0 rather than l_burden_cost > 0
            -- to handle split/transfer cases (Shree)
           /* Bug # 697690 --  Initializing, for insterting first Exp.item  */

            -- l_burden_cost :=  bcc_rec.source_burden_cost;
            -- prev_bcc_rec.source_exp_item_date        := bcc_rec.source_exp_item_date        ;
            -- prev_bcc_rec.source_ind_expenditure_type := bcc_rec.source_ind_expenditure_type ;

    /*
       Multi-Currency Related changes:
       check is based on denom_burdened_cost and not burden_Cost
    */

   /*
    * Bug 2359625
    * The BTC EI is to be created, even if one of the amount buckets has a non-zero value.
    * if  l_denom_burdened_cost <> 0 then
    */
      --Bug 4444387: Added l_project_burdened_cost <> 0
      /* Bug#54065802 */
      l_denom_burdened_cost   := PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT1(l_denom_burdened_cost, bcc_rec.source_denom_currency_code);
      l_acct_burdened_cost    := PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT1(l_acct_burdened_cost, bcc_rec.source_acct_currency_code);
      l_burden_cost           :=PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT1(l_burden_cost, bcc_rec.source_projfunc_currency_code);
      l_project_burdened_cost := PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT1(l_project_burdened_cost, bcc_rec.source_project_currency_code);
      /* Bug#54065802 */

      if  ( l_denom_burdened_cost <> 0  OR l_acct_burdened_cost <> 0 OR l_burden_cost <> 0 OR l_project_burdened_cost <> 0 )
      then
         begin
           IF P_DEBUG_MODE  THEN
              pa_cc_utils.log_message('create_burden_expenditure_item: ' || '1400:Get Expenditure Item Id from Sequence');
           END IF;
           select pa_expenditure_items_s.nextval
             into exp_item_id from dual;
             i := i +1;



  -- Make sure that burden amount will be displayed as a separate item on same
  -- project and task. Check to see if over_task_id is null and
  -- dest_task_id is null, if it is then assign source_task_id to over_task_id
  --
           if (over_task_id is NULL AND proj_rec.burden_amt_display_method='D')
           then
          --  if bcc_rec.dest_task_id is NULL then -- commented for bug 3069632
              if proj_rec.dest_task_id is NULL then
                   IF P_DEBUG_MODE  THEN
                      pa_cc_utils.log_message('create_burden_expenditure_item: ' || '1450:No Dest Override');
                   END IF;
                   over_task_id := bcc_rec.source_task_id;
                   over_project_id := bcc_rec.source_project_id;
              else  -- destination override was provided by user
                   IF P_DEBUG_MODE  THEN
                      pa_cc_utils.log_message('create_burden_expenditure_item: ' || '1500:Dest Override');
                   END IF;
		   /*3069632 :Commented ************************
                   over_task_id := bcc_rec.dest_task_id;
                   over_project_id := bcc_rec.dest_project_id;
                   *********************************************/
		   /*3069632 :Added this */
		   over_task_id := proj_rec.dest_task_id;
                   over_project_id := proj_rec.dest_project_id;
              end if;
           end if;

/* Moved the derivation of work type id to here for bug 2607781 as it needs to be passed to pa_transactions_pub.validate_transaction */
	   IF ( NVL(pa_utils4.is_exp_work_type_enabled, 'N') = 'Y' )
           THEN
               IF P_DEBUG_MODE  THEN
                  pa_cc_utils.log_message('create_burden_expenditure_item: ' || '1510:Calling Get_work_type_id with Project_id [' ||
                                        to_char(over_project_id) ||
                                       '] task_id [' || to_char(over_task_id) || ']');
               END IF;

               l_work_type_id := pa_utils4.Get_work_type_id
                                ( p_project_id     => over_project_id
                                 ,p_task_id        => over_task_id
                                 ,p_assignment_id  => NULL
                                );
               IF P_DEBUG_MODE  THEN
                  pa_cc_utils.log_message('create_burden_expenditure_item: ' || '1520:Obtained work_type_id [' || to_char(l_work_type_id) || ']');
               END IF;
           END IF; -- 2607781

           -- The following section of the code was added by Sandeep. It gets
           -- the billable_flag value from patc.get_status API. The API is called
           -- only if either task_id, project_id or expenditure_type changes.
           -- patc.get_status will return the billable_flag which will determine the billability of
           -- newly created burden summarized transaction.
           -- Ref Bug # : 609978
           --
           if ((nvl(c_task_id, -999999) <> over_task_id ) or
              (nvl(c_project_id, -999999) <> over_project_id) or
              (nvl(c_expenditure_type, '')  <> prev_bcc_rec.source_ind_expenditure_type)) then
/*
  Multi-Curr Changes.  Chnaged patc.get_status to
  pa_transactions_pub.validate_transaction.  Also passing null's for rate
  attributes, the raw cost for BTC transactions is 0. The burdened costs are
  calculated using existing CDL's which are already converted.
*/

          IF P_DEBUG_MODE  THEN
             pa_cc_utils.log_message('create_burden_expenditure_item: ' || '1550:Call PATC for project,task or exp type change');
          END IF;
/* modified for the Bug#1825827 */
               pa_transactions_pub.validate_transaction(
                               x_project_id =>over_project_id,
                               x_task_id =>over_task_id,
                               x_ei_date =>prev_bcc_rec.source_exp_item_date,
                               x_expenditure_type =>prev_bcc_rec.source_ind_expenditure_type,
                               x_non_labor_resource =>NULL,
                               x_person_id => NULL,
                               x_quantity =>NULL,
                               x_denom_currency_code =>prev_bcc_rec.source_denom_currency_code,
                               x_acct_currency_code  =>prev_bcc_rec.source_acct_currency_code,
                               x_denom_raw_cost => 0,
                               x_acct_raw_cost => 0,
                               x_acct_rate_type => NULL,
                               x_acct_rate_date => NULL,
                               x_acct_exchange_rate => NULL,
                               x_transfer_ei =>NULL,
                               x_incurred_by_org_id =>prev_bcc_rec.source_org_id,
                               x_nl_resource_org_id =>NULL,
                               x_transaction_source =>NULL,
                               x_calling_module =>NULL,
                               x_vendor_id =>NULL,
                               x_entered_by_user_id =>NULL,
                               x_attribute_category =>NULL,
                               x_attribute1 =>NULL,
                               x_attribute2 =>NULL,
                               x_attribute3 =>NULL,
                               x_attribute4 =>NULL,
                               x_attribute5 =>NULL,
                               x_attribute6 =>NULL,
                               x_attribute7 =>NULL,
                               x_attribute8 =>NULL,
                               x_attribute9 =>NULL,
                               x_attribute10 =>NULL,
                               x_attribute11 =>NULL,
                               x_attribute12 =>NULL,
                               x_attribute13 =>NULL,
                               x_attribute14 =>NULL,
                               x_attribute15 =>NULL,
                               x_msg_application =>c_msg_application,
                               x_msg_type =>c_msg_type,
                               x_msg_token1 =>c_msg_token1,
                               x_msg_token2 =>c_msg_token2,
                               x_msg_token3 =>c_msg_token3,
                               x_msg_count =>c_msg_count,
                               x_msg_data =>c_status,
                               x_billable_flag =>c_billable_flag,
			       p_sys_link_function  => 'BTC',
			       p_work_type_id => l_work_type_id -- 2607781
                              );
                IF P_DEBUG_MODE  THEN
                   pa_cc_utils.log_message('create_burden_expenditure_item: ' || '1600:Back from PATC call');
                END IF;
                if c_status is not null then
                   null ;
                end if;

                c_task_id := over_task_id;
                c_project_id := over_project_id;
                c_expenditure_type  := prev_bcc_rec.source_ind_expenditure_type ;
               /*Bug# 2091559 Added followinf If Clause*/
               if nvl(prev_bcc_rec.billable_flag,bcc_rec.billable_flag) = 'N' then
                c_billable_flag :='N' ;
               end if;
           end if;
           -- **********************************
           --dbms_output.put_line('Items will be created on task: '|| to_char(over_task_id));
           stage := 180;  -- Loading EI details
    /*
       Multi-Currency Related changes:
       Added additional parameters
       (denom currency code ,acct currency code, project currency code;
       all other currency attributes are set to null)
    */

     -- Passed the value for parameter x_labor_cost_multiplier_name
     -- which is a new parameter created for bug 791759

     -- IC Changes
     -- BTC txns should not be cross charged, so setting cross charge code to X.

    /*
     * AddEi Attributes - related change.
     * Deriving work_type_id.
     */
    /* Commenting this for bug 2607781 as work type id needs to be derived before the call to pa_transactions_pub.validate_transaction
	   IF ( NVL(pa_utils4.is_exp_work_type_enabled, 'N') = 'Y' )
           THEN
               IF P_DEBUG_MODE  THEN
                  pa_cc_utils.log_message('create_burden_expenditure_item: ' || '1645:Calling Get_work_type_id with Project_id [' ||
                                        to_char(over_project_id) ||
                                       '] task_id [' || to_char(over_task_id) || ']');
               END IF;

               l_work_type_id := pa_utils4.Get_work_type_id
                                ( p_project_id     => over_project_id
                                 ,p_task_id        => over_task_id
                                 ,p_assignment_id  => NULL
                                );
               IF P_DEBUG_MODE  THEN
                  pa_cc_utils.log_message('create_burden_expenditure_item: ' || '1645:Obtained work_type_id [' || to_char(l_work_type_id) || ']');
               END IF;
           END IF; */

   /*
    * CRL Related Changes
    * Passing the  values for attribute2 - attribute10 and
    * attribute_category retrived from previous function call
    */

   /*
    * Bug#2255068
    * Changed the variable passed for incurred_by_organization_id. Passed
    * prev_bcc_rec.source_org_id -  because exp_org_id actually holds the
    * organization_id of the next grouping.
    */
           IF P_DEBUG_MODE  THEN
              pa_cc_utils.log_message('create_burden_expenditure_item: ' || '1650:Call Loadei');
           END IF;

           pa_transactions.LoadEi(
                                  x_expenditure_item_id =>exp_item_id,
                                  x_expenditure_id =>x_exp_id,
                                  x_expenditure_item_date
                                  =>prev_bcc_rec.source_exp_item_date    ,
     --  for 1664962              pa_utils.GetWeekEnding((prev_bcc_rec.source_pa_date)-6),
                                  x_project_id => over_project_id,  --  NULL, bugfix: 2201207
                                  x_task_id =>over_task_id ,
                                  x_expenditure_type =>prev_bcc_rec.source_ind_expenditure_type,
                                  x_non_labor_resource =>prev_bcc_rec.source_nl_resource,  -- 4057874
                                  x_nl_resource_org_id =>prev_bcc_rec.source_nl_resource_orgn_id   ,  -- 4057874
                                  x_quantity =>0,
                                  x_raw_cost =>0      ,
                                  x_raw_cost_rate =>0,
                              /*  x_override_to_org_id =>exp_org_id -Bug# 2255068*/
                                  x_override_to_org_id =>prev_bcc_rec.source_org_id,
                                  x_billable_flag      =>c_billable_flag,  /*Bug4643188:Reverted Bug#2840048 */
                                  x_bill_hold_flag =>'N',
                                  x_orig_transaction_ref =>NULL ,
                                  x_transferred_from_ei =>NULL ,
                                  x_adj_expend_item_id =>NULL,
                                  x_attribute_category =>prev_bcc_rec.source_attribute_category ,
                                  x_attribute1 =>prev_bcc_rec.source_attribute1 ,    /*Bug# 3611675 Replaced l_attribute1*/
                                  x_attribute2 =>prev_bcc_rec.source_attribute2 ,
                                  x_attribute3 =>prev_bcc_rec.source_attribute3 ,
                                  x_attribute4 =>prev_bcc_rec.source_attribute4 ,
                                  x_attribute5 =>prev_bcc_rec.source_attribute5 ,
                                  x_attribute6 =>prev_bcc_rec.source_attribute6 ,
                                  x_attribute7 =>prev_bcc_rec.source_attribute7 ,
                                  x_attribute8 =>prev_bcc_rec.source_attribute8 ,
                                  x_attribute9 =>prev_bcc_rec.source_attribute9 ,
                                  x_attribute10 =>prev_bcc_rec.source_attribute10 ,
                                  x_ei_comment =>NULL ,
                                  x_transaction_source =>NULL ,
                                  x_source_exp_item_id =>NULL ,
                                  i => i    ,
                                  x_job_id =>prev_bcc_rec.source_job_id ,  -- 4057874
                                  x_org_id =>G_MOAC_ORG_ID ,
                                  x_labor_cost_multiplier_name => NULL,
                                  x_drccid =>NULL ,
                                  x_crccid =>NULL ,
                                  x_cdlsr1 =>NULL ,
                                  x_cdlsr2 =>NULL ,
                                  x_cdlsr3 =>NULL ,
                                  x_gldate =>NULL ,
                                  x_bcost =>l_burden_cost ,
                                  x_bcostrate =>NULL ,
                                  x_etypeclass => 'BTC',
                                  x_burden_sum_dest_run_id =>current_run_id,
                                  x_burden_compile_set_id =>null,
                                  x_receipt_currency_amount =>null,
                                  x_receipt_currency_code =>null,
                                  x_receipt_exchange_rate =>null,
                                  x_denom_currency_code =>prev_bcc_rec.source_denom_currency_code,
                                  x_denom_raw_cost =>null,
                                  x_denom_burdened_cost =>l_denom_burdened_cost,
                                  x_acct_currency_code =>prev_bcc_rec.source_acct_currency_code,
                                  x_acct_rate_date =>prev_bcc_rec.src_acct_rate_date,
                                  x_acct_rate_type =>prev_bcc_rec.src_acct_rate_type,
                                  x_acct_exchange_rate =>prev_bcc_rec.src_acct_exchange_rate,
                                  x_acct_raw_cost =>null,
                                  x_acct_burdened_cost =>l_acct_burdened_cost,
                                  x_acct_exchange_rounding_limit =>null,
                                  x_project_currency_code =>prev_bcc_rec.source_project_currency_code,
                                  x_project_rate_date =>prev_bcc_rec.src_project_rate_date,
                                  x_project_rate_type =>prev_bcc_rec.src_project_rate_type,
                                  x_project_exchange_rate =>prev_bcc_rec.src_project_exchange_rate,
                                  p_project_raw_cost =>null,
                                  p_project_burdened_cost =>l_project_burdened_cost,
                                  p_projfunc_currency_code => prev_bcc_rec.source_projfunc_currency_code,
                                  p_projfunc_cost_rate_date => prev_bcc_rec.src_projfunc_cost_rate_date,
                                  p_projfunc_cost_rate_type => prev_bcc_rec.src_projfunc_cost_rate_type,
                                  p_projfunc_cost_exchange_rate => prev_bcc_rec.src_projfunc_cost_xchng_rate,
                                  p_work_type_id => l_work_type_id,
                                  X_Cross_Charge_Code => 'X',
                                  x_recv_operating_unit => proj_rec.org_id
                                 ,p_Po_Line_Id => prev_bcc_rec.source_po_line_id
                                 ,p_adjustment_type => prev_bcc_rec.source_adjustment_type
                                 ,p_Wip_Resource_Id => prev_bcc_rec.source_wip_resource_id  -- 4057874
                                 ,p_Inventory_Item_Id => prev_bcc_rec.source_inventory_item_id  -- 4057874
                                 ,p_src_system_linkage_function => prev_bcc_rec.source_system_linkage_function  -- 4057874
                                 ,p_vendor_id => prev_bcc_rec.source_vendor_id -- Bug 6993002
                               );
                IF P_DEBUG_MODE  THEN
                   pa_cc_utils.log_message('create_burden_expenditure_item: ' || '1700:Back from Loadei');
                END IF;


      -- Frequently create EI and flush EiTabs to reduce load on LoadEi
       if ( i >= 500) then
           IF P_DEBUG_MODE  THEN
              pa_cc_utils.log_message('create_burden_expenditure_item: ' || '1750:Call Insitems for i>=500');
           END IF;
           pa_transactions.InsItems(1,0,'BTC','BTC',i, status,'N');

               -- -----------------------------------------------------------------------
               -- OGM_0.0 - Interface for creating new ADLS for each expenditure Item
               -- created. This will create award distribution lines only when OGM is
               -- installed for the ORG in process.
               -- The folowing procedure returns doing nothing if status returned from
               -- pa_transactions.InsItemsis  is in error.
               -- ------------------------------------------------------------------------
           IF P_DEBUG_MODE  THEN
              pa_cc_utils.log_message('create_burden_expenditure_item: ' || '1760:Call Vertical APPS interface for i>=500');
           END IF;
                 PA_GMS_API.vert_trx_interface(0,0,'PAXCBCAB', 'PA_BURDEN_COSTING', i, status, 'N') ;
           IF P_DEBUG_MODE  THEN
              pa_cc_utils.log_message('create_burden_expenditure_item: ' || '1760:Call Vertical APPS interface for i>=500 END.');
              pa_cc_utils.log_message('create_burden_expenditure_item: ' || '1800:Call FlushEiTabs');
           END IF;
           pa_transactions.FlushEiTabs();
           IF P_DEBUG_MODE  THEN
              pa_cc_utils.log_message('create_burden_expenditure_item: ' || '1850:Back from FlushEiTabs');
           END IF;
           i := 0;
       end if;
-- end of a block to process items
     end;
    end if;
     l_burden_cost :=  bcc_rec.source_burden_cost;

 /***Bug#3611675 :Commented this as it ia redundant code
     --
     -- Bug 907767: Attribute1 was not being set. Added following statement
     --
     l_attribute1  :=  bcc_rec.source_attribute1;

 ******/

    /*
       Multi-Currency Related changes:
       Store denom_burdened_cost and acct_burdened_cost also.
     */
     l_denom_burdened_cost :=  bcc_rec.source_denom_burdened_cost;
     l_acct_burdened_cost  :=  bcc_rec.source_acct_burdened_cost;
     l_project_burdened_cost  :=  bcc_rec.source_project_burdened_cost;
   end if;

     -- Set the project and task id of the burden expenditure item depending
     -- on burden_accounting flag

  -- Make sure that burden amount will be displayed as a separate item on same
  -- project and task. Check to see if over_task_id is null and
  -- dest_task_id is null, if it is then assign source_task_id to over_task_id
  --
           if (proj_rec.burden_amt_display_method='D')
           then
       -----  if bcc_rec.dest_task_id is NULL then
              if proj_rec.dest_task_id is NULL then
                   IF P_DEBUG_MODE  THEN
                      pa_cc_utils.log_message('create_burden_expenditure_item: ' || '1900:Display method D and dest task id null');
                   END IF;
                   over_task_id := bcc_rec.source_task_id;
                   over_project_id := bcc_rec.source_project_id;
              else  -- destination override was provided by user
                   IF P_DEBUG_MODE  THEN
                      pa_cc_utils.log_message('create_burden_expenditure_item: ' || '1950:Display method D and dest task id provided');
                   END IF;
		   /*3069632 :Commented this
                   over_task_id := bcc_rec.dest_task_id;
                   over_project_id := bcc_rec.dest_project_id;
		   ********************************************/
		   /*3069632 :Added this */
                   over_task_id := proj_rec.dest_task_id;
                   over_project_id := proj_rec.dest_project_id;

              end if;
           end if;
           if (proj_rec.burden_amt_display_method='S') then
               IF P_DEBUG_MODE  THEN
                  pa_cc_utils.log_message('create_burden_expenditure_item: ' || '2000:Display method S');
               END IF;

	       /*3069632 :Commented this
               over_task_id := bcc_rec.dest_task_id;
               over_project_id := bcc_rec.dest_project_id;
	       ********************************************/
               /*3069632 :Added this */
               over_task_id := proj_rec.dest_task_id;
               over_project_id := proj_rec.dest_project_id;
           end if;

      -- Set the previous bcc record details
       prev_bcc_rec.source_project_id           := bcc_rec.source_project_id           ;
       prev_bcc_rec.source_task_id              := bcc_rec.source_task_id              ;
       prev_bcc_rec.source_org_id               := bcc_rec.source_org_id               ;
       prev_bcc_rec.source_pa_date              := bcc_rec.source_pa_date              ;
       prev_bcc_rec.source_attribute1           := bcc_rec.source_attribute1           ;
       prev_bcc_rec.source_attribute2           := bcc_rec.source_attribute2           ;
       prev_bcc_rec.source_attribute3           := bcc_rec.source_attribute3           ;
       prev_bcc_rec.source_attribute4           := bcc_rec.source_attribute4           ;
       prev_bcc_rec.source_attribute5           := bcc_rec.source_attribute5           ;
       prev_bcc_rec.source_attribute6           := bcc_rec.source_attribute6           ;
       prev_bcc_rec.source_attribute7           := bcc_rec.source_attribute7           ;
       prev_bcc_rec.source_attribute8           := bcc_rec.source_attribute8           ;
       prev_bcc_rec.source_attribute9           := bcc_rec.source_attribute9           ;
       prev_bcc_rec.source_attribute10          := bcc_rec.source_attribute10          ;
       prev_bcc_rec.source_ind_cost_code        := bcc_rec.source_ind_cost_code        ;
       prev_bcc_rec.source_expenditure_type     := bcc_rec.source_expenditure_type     ;
       prev_bcc_rec.source_ind_expenditure_type := bcc_rec.source_ind_expenditure_type ;
       prev_bcc_rec.source_cost_base            := bcc_rec.source_cost_base            ;
       prev_bcc_rec.source_compiled_multiplier  := bcc_rec.source_compiled_multiplier  ;
--     prev_bcc_rec.source_ind_rate_sch_id      := bcc_rec.source_ind_rate_sch_id      ;
--     prev_bcc_rec.source_ind_rate_sch_rev_id  := bcc_rec.source_ind_rate_sch_rev_id  ;
       prev_bcc_rec.source_exp_item_id          := bcc_rec.source_exp_item_id          ;
       prev_bcc_rec.source_line_num             := bcc_rec.source_line_num             ;
       prev_bcc_rec.source_exp_item_date        := bcc_rec.source_exp_item_date        ;
       prev_bcc_rec.source_burden_cost          := bcc_rec.source_burden_cost          ;
       prev_bcc_rec.source_id                   := bcc_rec.source_id                   ;
       prev_bcc_rec.source_burden_reject_code   := bcc_rec.source_burden_reject_code   ;
       /*3069632 Commented as it seems these variables are used no where.
       prev_bcc_rec.dest_project_id             := bcc_rec.dest_project_id             ;
       prev_bcc_rec.dest_task_id                := bcc_rec.dest_task_id                ;
       ************************/
       prev_bcc_rec.dest_org_id                 := bcc_rec.dest_org_id                 ;
       prev_bcc_rec.dest_pa_date                := bcc_rec.dest_pa_date                ;
       prev_bcc_rec.dest_attribute1             := bcc_rec.dest_attribute1             ;
       prev_bcc_rec.dest_ind_expenditure_type   := bcc_rec.dest_ind_expenditure_type   ;
       prev_bcc_rec.dest_summary_group          := bcc_rec.dest_summary_group          ;
       prev_bcc_rec.billable_flag               := bcc_rec.billable_flag               ;/*2091559*/
       l_prev_expenditure_id                    := l_curr_expenditure_id               ; -- Bug 3551106

    /*
       Multi-Currency Related changes:
       Copy the currency codes
     */
          prev_bcc_rec.source_denom_currency_code     :=bcc_rec.source_denom_currency_code;
          prev_bcc_rec.source_acct_currency_code      :=bcc_rec.source_acct_currency_code;
          prev_bcc_rec.source_project_currency_code   :=bcc_rec.source_project_currency_code;
          prev_bcc_rec.source_projfunc_currency_code  :=bcc_rec.source_projfunc_currency_code;
          prev_bcc_rec.source_po_line_id              :=bcc_rec.source_po_line_id;
          prev_bcc_rec.source_adjustment_type         :=bcc_rec.source_adjustment_type;
          x_exp_id                                    := exp_id;

          /* 4057874 */
          prev_bcc_rec.source_job_id := bcc_rec.source_job_id;
          prev_bcc_rec.source_nl_resource := bcc_rec.source_nl_resource;
          prev_bcc_rec.source_nl_resource_orgn_id := bcc_rec.source_nl_resource_orgn_id;
          prev_bcc_rec.source_wip_resource_id := bcc_rec.source_wip_resource_id;
          prev_bcc_rec.source_incurred_by_person_id := bcc_rec.source_incurred_by_person_id;
          prev_bcc_rec.source_inventory_item_id := bcc_rec.source_inventory_item_id;
          prev_bcc_rec.source_system_linkage_function := bcc_rec.source_system_linkage_function;
          prev_bcc_rec.source_vendor_id := bcc_rec.source_vendor_id;

          prev_bcc_rec.src_acct_rate_date           := bcc_rec.src_acct_rate_date;
          prev_bcc_rec.src_acct_rate_type           := bcc_rec.src_acct_rate_type;
          prev_bcc_rec.src_acct_exchange_rate       := bcc_rec.src_acct_exchange_rate;
          prev_bcc_rec.src_project_rate_date        := bcc_rec.src_project_rate_date;
          prev_bcc_rec.src_project_rate_type        := bcc_rec.src_project_rate_type;
          prev_bcc_rec.src_project_exchange_rate    := bcc_rec.src_project_exchange_rate;
          prev_bcc_rec.src_projfunc_cost_rate_date  := bcc_rec.src_projfunc_cost_rate_date;
          prev_bcc_rec.src_projfunc_cost_rate_type  := bcc_rec.src_projfunc_cost_rate_type;
          prev_bcc_rec.src_projfunc_cost_xchng_rate := bcc_rec.src_projfunc_cost_xchng_rate;

          /* bug fix 4091690 starts */

       IF P_DEBUG_MODE  THEN
          pa_cc_utils.log_message('create_burden_expenditure_item: ' ||
					'1625:Call pa_client_extn_burden_summary grouping.CLIENT_column_values');
       END IF;

    /*
     * CRL Related Changes
     * Included the following Function call get values for attribute2 - attribute10 and
     * attribute_category
     */
      pa_client_extn_burden_summary.CLIENT_COLUMN_VALUES
                            (
                        p_src_attribute2 => prev_bcc_rec.source_attribute2,
                        p_src_attribute3 => prev_bcc_rec.source_attribute3,
                        p_src_attribute4 => prev_bcc_rec.source_attribute4,
                        p_src_attribute5 => prev_bcc_rec.source_attribute5,
                        p_src_attribute6 => prev_bcc_rec.source_attribute6,
                        p_src_attribute7 => prev_bcc_rec.source_attribute7,
                        p_src_attribute8 => prev_bcc_rec.source_attribute8,
                        p_src_attribute9 => prev_bcc_rec.source_attribute9,
                        p_src_attribute10 => prev_bcc_rec.source_attribute10,
                        p_src_attribute_category => prev_bcc_rec.source_attribute_category
                       ,p_src_acct_rate_date            => prev_bcc_rec.src_acct_rate_date
                       ,p_src_acct_rate_type            => prev_bcc_rec.src_acct_rate_type
                       ,p_src_acct_exchange_rate        => prev_bcc_rec.src_acct_exchange_rate
                       ,p_src_project_rate_date         => prev_bcc_rec.src_project_rate_date
                       ,p_src_project_rate_type         => prev_bcc_rec.src_project_rate_type
                       ,p_src_project_exchange_rate     => prev_bcc_rec.src_project_exchange_rate
                       ,p_src_projfunc_cost_rate_date   => prev_bcc_rec.src_projfunc_cost_rate_date
                       ,p_src_projfunc_cost_rate_type   => prev_bcc_rec.src_projfunc_cost_rate_type
                       ,p_src_projfunc_cost_xchng_rate  => prev_bcc_rec.src_projfunc_cost_xchng_rate
                             );

          If P_BTC_SRC_RESRC = 'Y' then  -- 4057874

            IF P_DEBUG_MODE  THEN
               pa_cc_utils.log_message('create_burden_expenditure_item: ' || '1625:Call pa_client_extn_burden_resource.client_column_values');
          END IF;

          pa_client_extn_burden_resource.client_column_values (
                         p_job_id => prev_bcc_rec.source_job_id,
                         p_non_labor_resource => prev_bcc_rec.source_nl_resource,
                         p_non_labor_resource_orgn_id => prev_bcc_rec.source_nl_resource_orgn_id,
                         p_wip_resource_id => prev_bcc_rec.source_wip_resource_id,
                         p_incurred_by_person_id => l_incurred_by_person_id,
                         p_inventory_item_id => prev_bcc_rec.source_inventory_item_id,
                         p_vendor_id => l_vendor_id,
                         p_bom_labor_resource_id => l_bom_labor_resource_id,
                         p_bom_equipment_resource_id => l_bom_equipment_resource_id);
          else
              prev_bcc_rec.source_job_id := null;
              prev_bcc_rec.source_nl_resource := null;
              prev_bcc_rec.source_nl_resource_orgn_id := null;
              prev_bcc_rec.source_wip_resource_id := null;
              prev_bcc_rec.source_inventory_item_id := null;

              -- Bug 4323236 : The source_system_linkage_function parameter will be populated always for BTC as this
              -- can be used to uniquely identify all the source exp's associated with the BTC in pa_res_map_btc_v.
              -- Note : Populating this column value always for a BTC will have no issues as system linkage function
              -- is part of grouping criteria ,hence each BTC line will have unique source system linkage function.
              --prev_bcc_rec.source_system_linkage_function := null;

          end if; -- profile option

          /* bug fix 4091690 */

          IF P_DEBUG_MODE  THEN
             pa_cc_utils.log_message('create_burden_expenditure_item: ' || '2050:End of bcc rec loop');
          END IF;
      end loop;
     end;


    /* create EI for the last set  */
           -- Checking for l_burden_cost <> 0 rather than l_burden_cost > 0
           -- to handle split/transfer cases (Shree)
    /*
       Multi-Currency Related changes:
       check is based on denom_burdened_cost rather than burden_cost.
     */

    /*
     * Bug 2359625
     * The BTC EI is to be created, even if one of the amount buckets has a non-zero value.
     *  if  l_denom_burdened_cost <> 0 then
     */
      --Bug 4444387: Added l_project_burdened_cost <> 0

      /* Bug#54065802 */
        if ( l_bcc_rec.count > 0) then /* Added for bug#6035619 */

      l_denom_burdened_cost    := PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT1(l_denom_burdened_cost, bcc_rec.source_denom_currency_code);
      l_acct_burdened_cost     := PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT1(l_acct_burdened_cost, bcc_rec.source_acct_currency_code);
      l_burden_cost            :=PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT1(l_burden_cost, bcc_rec.source_projfunc_currency_code);
      l_project_burdened_cost  := PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT1(l_project_burdened_cost, bcc_rec.source_project_currency_code);

      /* Bug#54065802 */
      end if; /* Added for bug#6035619 */
      if  ( l_denom_burdened_cost <> 0  OR l_acct_burdened_cost <> 0 OR l_burden_cost <> 0 OR l_project_burdened_cost <> 0 )
      then
         begin

               IF P_DEBUG_MODE  THEN
                  pa_cc_utils.log_message('create_burden_expenditure_item: ' || '2100:Process Last set .. Get Exp item id from sequence');
               END IF;
               select pa_expenditure_items_s.nextval
                 into exp_item_id from dual;

/* Moved the derivation of work type id to here for bug 2607781 as it needs to be passed to pa_transactions_pub.validate_transaction */
	   IF ( NVL(pa_utils4.is_exp_work_type_enabled, 'N') = 'Y' )
           THEN
               IF P_DEBUG_MODE  THEN
                  pa_cc_utils.log_message('create_burden_expenditure_item: ' || '2110:Calling Get_work_type_id with Project_id [' ||
                                       to_char(over_project_id) ||
                                       '] task_id [' || to_char(over_task_id) || ']');
               END IF;
               l_work_type_id := pa_utils4.Get_work_type_id
                                ( p_project_id     => over_project_id
                                 ,p_task_id        => over_task_id
                                 ,p_assignment_id  => NULL
                                 );
               IF P_DEBUG_MODE  THEN
                  pa_cc_utils.log_message('create_burden_expenditure_item: ' || '2120:Obtained work_type_id [' || to_char(l_work_type_id) || ']');
               END IF;
           END IF; -- 2607781


           -- The following section of the code was added by Sandeep. It gets
           -- the billable_flag value from patc.get_status API. The API is called
           -- only if either task_id, project_id or expenditure_type changes.
           -- patc.get_status will return the billable_flag which will determine the billability of
           -- newly created burden summarized transaction.
           -- Ref Bug # : 609978
           --
/*
  Multi-Curr Changes.  Changed patc.get_status to
  pa_transactions_pub.validate_transaction.  Also passing null's for rate
  attributes, the raw cost for BTC transactions is 0. The burdened costs are
  calculated using existing CDL's which are already converted.
*/

               IF P_DEBUG_MODE  THEN
                  pa_cc_utils.log_message('create_burden_expenditure_item: ' || '2150:Process Last Set .. call PATC');
               END IF;
/* modified for the Bug#1825827 */
               pa_transactions_pub.validate_transaction(
                               x_project_id =>over_project_id,
                               x_task_id =>over_task_id,
                               x_ei_date =>prev_bcc_rec.source_exp_item_date,
                               x_expenditure_type =>prev_bcc_rec.source_ind_expenditure_type,
                               x_non_labor_resource =>NULL,
                               x_person_id => NULL,
                               x_quantity =>NULL,
                               x_denom_currency_code =>prev_bcc_rec.source_denom_currency_code,
                               x_acct_currency_code  =>prev_bcc_rec.source_acct_currency_code,
                               x_denom_raw_cost => 0,
                               x_acct_raw_cost => 0,
                               x_acct_rate_type => NULL,
                               x_acct_rate_date => NULL,
                               x_acct_exchange_rate => NULL,
                               x_transfer_ei =>NULL,
                               x_incurred_by_org_id =>prev_bcc_rec.source_org_id,
                               x_nl_resource_org_id =>NULL,
                               x_transaction_source =>NULL,
                               x_calling_module =>NULL,
                               x_vendor_id =>NULL,
                               x_entered_by_user_id =>NULL,
                               x_attribute_category =>NULL,
                               x_attribute1 =>NULL,
                               x_attribute2 =>NULL,
                               x_attribute3 =>NULL,
                               x_attribute4 =>NULL,
                               x_attribute5 =>NULL,
                               x_attribute6 =>NULL,
                               x_attribute7 =>NULL,
                               x_attribute8 =>NULL,
                               x_attribute9 =>NULL,
                               x_attribute10 =>NULL,
                               x_attribute11 =>NULL,
                               x_attribute12 =>NULL,
                               x_attribute13 =>NULL,
                               x_attribute14 =>NULL,
                               x_attribute15 =>NULL,
                               x_msg_application =>c_msg_application,
                               x_msg_type =>c_msg_type,
                               x_msg_token1 =>c_msg_token1,
                               x_msg_token2 =>c_msg_token2,
                               x_msg_token3 =>c_msg_token3,
                               x_msg_count =>c_msg_count,
                               x_msg_data =>c_status,
                               x_billable_flag =>c_billable_flag,
			       p_sys_link_function  => 'BTC',
			       p_work_type_id => l_work_type_id -- 2607781
                              );
                IF P_DEBUG_MODE  THEN
                   pa_cc_utils.log_message('create_burden_expenditure_item: ' || '2200:Process Last Set .. back from PATC');
                END IF;
                if c_status is not null then
                   null ;
                end if;
           -- ***********************
           i := i +1;
/*2091559 Added followinf If Clause*/
                  if prev_bcc_rec.billable_flag = 'N' then
                      c_billable_flag :='N' ;
                   end if;

           /*
            * AddEi Attributes - related change.
            * Deriving work_type_id.
            */
/* Commenting this for bug 2607781 as work type id needs to be derived before the call to pa_transactions_pub.validate_transaction
	   IF ( NVL(pa_utils4.is_exp_work_type_enabled, 'N') = 'Y' )
           THEN
               IF P_DEBUG_MODE  THEN
                  pa_cc_utils.log_message('create_burden_expenditure_item: ' || '2245:Calling Get_work_type_id with Project_id [' ||
                                       to_char(over_project_id) ||
                                       '] task_id [' || to_char(over_task_id) || ']');
               END IF;
               l_work_type_id := pa_utils4.Get_work_type_id
                                ( p_project_id     => over_project_id
                                 ,p_task_id        => over_task_id
                                 ,p_assignment_id  => NULL
                                 );
               IF P_DEBUG_MODE  THEN
                  pa_cc_utils.log_message('create_burden_expenditure_item: ' || '2245:Obtained work_type_id [' || to_char(l_work_type_id) || ']');
               END IF;
           END IF; */

    /*
       Multi-Currency Related changes:
       Added additional parameters
       (denom currency code ,acct currency code, project currency code;
       all other currency attributes are set to null)
     */

     -- Passed the value for parameter x_labor_cost_multiplier_name
     -- which is a new parameter created for bug 791759

     -- IC Changes
     -- BTC txns should not be cross charged, so setting cross charge code to X.
           IF P_DEBUG_MODE  THEN
              pa_cc_utils.log_message('create_burden_expenditure_item: ' || '2250:Process Last Set ..Call Loadei');
           END IF;
           pa_transactions.LoadEi(
                                  x_expenditure_item_id =>exp_item_id,
                                  x_expenditure_id =>x_exp_id,
                                  x_expenditure_item_date
                                  =>prev_bcc_rec.source_exp_item_date    ,
        -- for 1664962            pa_utils.GetWeekEnding((prev_bcc_rec.source_pa_date)-6),
                                  x_project_id => over_project_id , --bugfix: 2201207 NULL,
                                  x_task_id =>over_task_id ,
                                  x_expenditure_type =>prev_bcc_rec.source_ind_expenditure_type,
                                  x_non_labor_resource =>prev_bcc_rec.source_nl_resource,  -- 4057874
                                  x_nl_resource_org_id =>prev_bcc_rec.source_nl_resource_orgn_id   ,  -- 4057874
                                  x_quantity =>0,
                                  x_raw_cost =>0      ,
                                  x_raw_cost_rate =>0,
                                  x_override_to_org_id =>exp_org_id ,
                                  x_billable_flag =>c_billable_flag,    /*Bug# 4643188:Reverted fix of Bug#2840048 */
                                  x_bill_hold_flag =>'N',
                                  x_orig_transaction_ref =>NULL ,
                                  x_transferred_from_ei =>NULL ,
                                  x_adj_expend_item_id =>NULL,
                                  x_attribute_category =>prev_bcc_rec.source_attribute_category ,
                                  x_attribute1 =>prev_bcc_rec.source_attribute1 ,   /*Bug#3611675:Replaced l_attribute1*/
                                  x_attribute2 =>prev_bcc_rec.source_attribute2 ,
                                  x_attribute3 =>prev_bcc_rec.source_attribute3 ,
                                  x_attribute4 =>prev_bcc_rec.source_attribute4 ,
                                  x_attribute5 =>prev_bcc_rec.source_attribute5 ,
                                  x_attribute6 =>prev_bcc_rec.source_attribute6 ,
                                  x_attribute7 =>prev_bcc_rec.source_attribute7 ,
                                  x_attribute8 =>prev_bcc_rec.source_attribute8 ,
                                  x_attribute9 =>prev_bcc_rec.source_attribute9 ,
                                  x_attribute10 =>prev_bcc_rec.source_attribute10 ,
                                  x_ei_comment =>NULL ,
                                  x_transaction_source =>NULL ,
                                  x_source_exp_item_id =>NULL ,
                                  i => i    ,
                                  x_job_id =>prev_bcc_rec.source_job_id ,  -- 4057874
                                  x_org_id =>G_MOAC_ORG_ID ,
                                  x_labor_cost_multiplier_name => NULL,
                                  x_drccid =>NULL ,
                                  x_crccid =>NULL ,
                                  x_cdlsr1 =>NULL ,
                                  x_cdlsr2 =>NULL ,
                                  x_cdlsr3 =>NULL ,
                                  x_gldate =>NULL ,
                                  x_bcost =>l_burden_cost ,
                                  x_bcostrate =>NULL ,
                                  x_etypeclass => 'BTC',
                                  x_burden_sum_dest_run_id =>current_run_id,
                                  x_burden_compile_set_id =>null,
                                  x_receipt_currency_amount =>null,
                                  x_receipt_currency_code =>null,
                                  x_receipt_exchange_rate =>null,
                                  x_denom_currency_code =>prev_bcc_rec.source_denom_currency_code,
                                  x_denom_raw_cost =>null,
                                  x_denom_burdened_cost =>l_denom_burdened_cost,
                                  x_acct_currency_code =>prev_bcc_rec.source_acct_currency_code,
                                  x_acct_rate_date =>prev_bcc_rec.src_acct_rate_date,
                                  x_acct_rate_type =>prev_bcc_rec.src_acct_rate_type,
                                  x_acct_exchange_rate =>prev_bcc_rec.src_acct_exchange_rate,
                                  x_acct_raw_cost =>null,
                                  x_acct_burdened_cost =>l_acct_burdened_cost,
                                  x_acct_exchange_rounding_limit =>null,
                                  x_project_currency_code =>prev_bcc_rec.source_project_currency_code,
                                  x_project_rate_date =>prev_bcc_rec.src_project_rate_date,
                                  x_project_rate_type =>prev_bcc_rec.src_project_rate_type,
                                  x_project_exchange_rate =>prev_bcc_rec.src_project_exchange_rate,
                                  p_project_raw_cost =>null,
                                  p_project_burdened_cost =>l_project_burdened_cost,
                                  p_projfunc_currency_code => prev_bcc_rec.source_projfunc_currency_code,
                                  p_projfunc_cost_rate_date => prev_bcc_rec.src_projfunc_cost_rate_date,
                                  p_projfunc_cost_rate_type => prev_bcc_rec.src_projfunc_cost_rate_type,
                                  p_projfunc_cost_exchange_rate => prev_bcc_rec.src_projfunc_cost_xchng_rate,
                                  p_work_type_id => l_work_type_id,
                                  X_Cross_Charge_Code => 'X',
                                  x_recv_operating_unit => proj_rec.org_id
                                 ,p_Po_line_id => prev_bcc_rec.source_po_line_id
                                 ,p_adjustment_type => prev_bcc_rec.source_adjustment_type
                                 ,p_Wip_Resource_Id => prev_bcc_rec.source_wip_resource_id  -- 4057874
                                 ,p_Inventory_Item_Id => prev_bcc_rec.source_inventory_item_id  -- 4057874
                                 ,p_src_system_linkage_function => prev_bcc_rec.source_system_linkage_function  -- 4057874
                                 ,p_vendor_id => prev_bcc_rec.source_vendor_id -- Bug 6993002
                                  );
       end;

     end if;
     if i > 0 then
         IF P_DEBUG_MODE  THEN
            pa_cc_utils.log_message('create_burden_expenditure_item: ' || '2300:Process Last Set ..Call Insitems');
         END IF;
         pa_transactions.InsItems(1,0,'BTC','BTC',i, status,'N');

             -- -----------------------------------------------------------------------
             -- OGM_0.0 - Interface for creating new ADLS for each expenditure Item
             -- created. This will create award distribution lines only when OGM is
             -- installed for the ORG in process.
             -- The folowing procedure returns doing nothing if status is in ERROR for
             -- pa_transactions.InsItems.
             -- ------------------------------------------------------------------------
         IF P_DEBUG_MODE  THEN
            pa_cc_utils.log_message('create_burden_expenditure_item: ' || '1760:Call Vertical APPS interface for i>=500');
         END IF;

         PA_GMS_API.vert_trx_interface(0,0,'PAXCBCAB', 'PA_BURDEN_COSTING', i, status, 'N') ;

         IF P_DEBUG_MODE  THEN
            pa_cc_utils.log_message('create_burden_expenditure_item: ' || '1760:Call Vertical APPS interface for i>=500 END.');
            pa_cc_utils.log_message('create_burden_expenditure_item: ' || '2350:Process Last Set ..Call Flusheitabs');
         END IF;
         pa_transactions.FlushEiTabs();
         i := 0;
     end if;

     /*<<NEXT_PROJECT>>.....bug# 2255068*/
     /* Bug#2255068
      * Commented this update as this update is no more required.
      *
      *
      *    ** Update those CDLs which are successfully processed with run id
      *
      *   pa_cc_utils.log_message('2400:Update successful CDLs');
      *
      *   ** Removed ei table and pa_tasks table and
      *      changed cdl_all table to cdl view for
      *      bug# 1668634
      *
      *   update pa_cost_distribution_lines cdl
      *      set burden_sum_source_run_id  = current_run_id
      *   where cdl.line_type                   = 'R'
      *   and cdl.burden_sum_source_run_id = init_cdl_run_id
      *   and cdl.project_id               = current_project_id
      *        cdl.PA_DATE <= nvl(to_date(x_end_date,'DD-MM-RR'),cdl.PA_DATE)
      *   and  request_id = x_request_id ;
      *
      *   pa_cc_utils.log_message('2500:before commit');
      */


        /* IF ( l_last_batch_for_project = 'Y')
         THEN  Bug 4747865 */
	     /*
              * Completed processing all CDLs of this project.
              */
IF l_tbl_eiid.count > 0 THEN /* Bug# 5406802 */

         IF l_burden_profile ='Y' Then       /*3040724*/
             /*2933915 :Create Audit records for the special cdls using prev_ind_compiled_set_id and burden_sum_source_run_id*/

	     PA_BURDEN_COSTING.InsBurdenAudit(current_project_id,x_request_id,l_user_id,lstatus);

            /*2933915 :Resetting 'special eis' -Adjustment Type and commiting by batches */

        /* LOOP commented for Bug 4747865 */

	 UPDATE pa_expenditure_items_all ei
	 set  adjustment_type =NULL, /*Start of bug 4754024*/
	 cc_bl_distributed_code =decode(tp_ind_compiled_set_id,NULL,
                                 decode(cc_bl_distributed_code,'Y','N',cc_bl_distributed_code),cc_bl_distributed_code), /*4754024*/
         cc_ic_processed_code   =decode(tp_ind_compiled_set_id,NULL,decode(cc_ic_processed_code,'Y','N',cc_ic_processed_code)
                                ,cc_ic_processed_code),
         Denom_Tp_Currency_Code =decode(tp_ind_compiled_set_id,NULL,decode(cc_bl_distributed_code,'Y',NULL,Denom_Tp_Currency_Code),
                                  Denom_Tp_Currency_Code),
         Denom_Transfer_Price   =decode(tp_ind_compiled_set_id,NULL,decode(cc_bl_distributed_code,'Y',NULL,Denom_Transfer_Price),
                                 Denom_Transfer_Price),
         Acct_Tp_Rate_Type      =decode(tp_ind_compiled_set_id,NULL,decode(cc_bl_distributed_code,'Y',NULL,Acct_Tp_Rate_Type),
                                 Acct_Tp_Rate_Type),
         Acct_Tp_Rate_Date      =decode(tp_ind_compiled_set_id,NULL,decode(cc_bl_distributed_code,'Y',NULL,Acct_Tp_Rate_Date),
                                  Acct_Tp_Rate_Date),
         Acct_Tp_Exchange_Rate  =decode(tp_ind_compiled_set_id,NULL,decode(cc_bl_distributed_code,'Y',NULL,Acct_Tp_Exchange_Rate),
                                  Acct_Tp_Exchange_Rate),
         Acct_Transfer_Price    =decode(tp_ind_compiled_set_id,NULL,decode(cc_bl_distributed_code,'Y',NULL,Acct_Transfer_Price),
                                 Acct_Transfer_Price),
         Projacct_Transfer_Price=decode(tp_ind_compiled_set_id,NULL,decode(cc_bl_distributed_code,'Y',NULL,Projacct_Transfer_Price),
	                         Projacct_Transfer_Price),
         Cc_Markup_Base_Code    =decode(tp_ind_compiled_set_id,NULL,decode(cc_bl_distributed_code,'Y',NULL,Cc_Markup_Base_Code),
	                         Cc_Markup_Base_Code),
         Tp_Base_Amount         =decode(tp_ind_compiled_set_id,NULL,decode(cc_bl_distributed_code,'Y',NULL,Tp_Base_Amount),
	                         Tp_Base_Amount),
         Tp_Bill_Rate           =decode(tp_ind_compiled_set_id,NULL,decode(cc_bl_distributed_code,'Y',NULL,Tp_Bill_Rate),TP_Bill_Rate),
         Tp_Bill_Markup_Percentage=decode(tp_ind_compiled_set_id,NULL,decode(cc_bl_distributed_code,'Y',NULL,
	                           Tp_Bill_Markup_Percentage),Tp_Bill_Markup_Percentage),
         Tp_Schedule_line_Percentage =decode(tp_ind_compiled_set_id,NULL,decode(cc_bl_distributed_code,'Y',NULL,
	                               Tp_Schedule_line_Percentage),Tp_Schedule_line_Percentage),
         Tp_Rule_percentage =         decode(tp_ind_compiled_set_id,NULL,decode(cc_bl_distributed_code,'Y',NULL,Tp_Rule_percentage),
	                              Tp_Rule_percentage) /*End of bug 4754024*/
	 where adjustment_type ='BURDEN_RESUMMARIZE'
	 and   project_id = current_project_id
	 and   exists (select 1 from pa_cost_distribution_lines_all cdl
	               where cdl.expenditure_item_id = ei.expenditure_item_id
		       and   cdl.request_id          = x_request_id
		    /* and   cdl.prev_ind_compiled_set_id is NOT NULL               :Commented for bug# 3040724*/
		       and   cdl.burden_sum_source_run_id  =current_run_id )
          and rownum <=l_profile_set_size;

	  ei_update_count :=SQL%ROWCOUNT ;


         /*2933915 :Resetting prev_ind_compiled_set_id */

      /* Modified this sql for bug 5406802*/

	  FORALL I IN 1..l_tbl_eiid.count

         UPDATE pa_cost_distribution_lines_all
	 set prev_ind_compiled_set_id    =  NULL
	 where prev_ind_compiled_set_id  IS NOT NULL
         and   project_id                = current_project_id
	 and   request_id                = x_request_id
	 and   burden_sum_source_run_id  =current_run_id
       and   expenditure_item_id = l_tbl_eiid(i);

	  cdl_update_count :=SQL%ROWCOUNT ;

      /*   COMMIT; commented for Bug 4747865 */

	 IF (ei_update_count <l_profile_set_size) AND (cdl_update_count <l_profile_set_size) Then
	  COMMIT;
	  /* EXIT; Bug 4747865 */
	 END IF ;
        /*END LOOP; Bug 4747865 */
     END If ;   /*If profile is 'Y' 3040724*/

     END IF; -- IF l_tbl_eiid.count > 0 THEN          /* Bug# 5406802*/


	/***2933915****/
             --COMMIT ;
             --EXIT ;
/*     END IF; End if of last_batch_for_project commented for Bug 4747865 */

         /*
          * Bug#2255068
          * Commit happens once per CDL batch.
          */
           COMMIT ;
      end loop; -- Loop for processing CDLs in batches for this project.

      IF P_DEBUG_MODE  THEN
         pa_cc_utils.log_message('create_burden_expenditure_item: ' || '2550:End of Project loop');
      END IF;
  <<NEXT_PROJECT>>
     null;
      END LOOP; -- FOR LOOP
  end loop project_loop;

/* S.N. Bug 3618193 : Added following code to close the cursor */

  IF projects_with_eb%ISOPEN THEN
     CLOSE projects_with_eb;
  END IF;

  IF projects_without_eb%ISOPEN THEN
     CLOSE projects_without_eb;
  END IF;

/* E.N. Bug 3618193 : Added following code to close the cursor */

  <<END_OF_PROCESS>>
       IF P_DEBUG_MODE  THEN
          pa_cc_utils.log_message('create_burden_expenditure_item: ' || '2600:At the end of the Process');
       END IF;
    null;
     x_run_id := current_run_id;
     pa_cc_utils.reset_curr_function;
end create_burden_expenditure_item;



PROCEDURE create_burden_cmt_transaction ( status   in out NOCOPY number,
                                        stage    in out NOCOPY number,
                                        x_run_id in out NOCOPY number,
                                        x_project_id in number) /* bug#2791563 added x_project_id */
IS

 ------------     Decalrarion of Variables       ---------------

 current_project_id  number;
 current_run_id      number := 1;
 init_cmt_run_id     number := -9999;
 message_string      varchar2(200);

 prev_bcc_rec        pa_cmt_burden_summary_v%rowtype;
 l_attribute1        pa_projects_all.attribute1%type;
 l_cmt_line_id       pa_commitment_txns.cmt_line_id%type;
 l_burden_cost       pa_expenditure_items_all.burden_cost%type;
 l_txn_ref1          pa_commitment_txns.original_txn_reference1%type;
 apps_id             number(3) := 275; -- For PA
 sob_id              number(15);
 l_gl_period         varchar2(15);
 l_pa_end_date       date;

/* start bug 2324127 */

 l_acct_burdened_cost                           pa_commitment_txns.acct_burdened_cost%type;
 l_denom_burdened_cost                          pa_commitment_txns.denom_burdened_cost%type;

/* end bug 2324127 */

/* 4057874 */
l_job_id                                       PA_EXPENDITURE_ITEMS_ALL.job_id%type default null;
l_non_labor_resource                   PA_EXPENDITURE_ITEMS_ALL.non_labor_resource%type default null;
l_non_labor_resource_orgn_id       PA_EXPENDITURE_ITEMS_ALL.organization_id%type default null;
l_wip_resource_id                        PA_EXPENDITURE_ITEMS_ALL.wip_resource_id%type default null;
l_incurred_by_person_id               PA_EXPENDITURES_ALL.incurred_by_person_id%type default null;

 ------------     Decalrarion of Cursors       ---------------

 --  Cursor to select all the Projects for which there are non-summarized Commitment tran

 -- Bug 2556167: Added hint for using hash join
 -- Bug 2838499: Used pa_projects Org view instead of table.
 --              added org_id join between pt and p.
/*
 * Bug 4914022 : Changed projects cursor to join to pa_projects_all
 * pa_project_types_all instead of pa_projects, pa_project_types.
 */
Cursor  projects is
 select  /*+ use_hash(pt p) */
         p.project_id , p.segment1
         , upper(nvl(pt.burden_account_flag,'N')) burden_account_flag
         , upper(pt.burden_amt_display_method)    burden_amt_display_method
   from  pa_projects_all p,
         pa_project_types_all pt
 where   pt.project_type = p.project_type
   and   pt.org_id = p.org_id                                /*5368274*/
   and   pt.burden_amt_display_method in ('D','d')
   and   p.project_id = nvl(x_project_id,p.project_id) /* bug#2791563 */
   and   exists  ( select 1
                     from pa_commitment_txns cmt
                    where nvl(x_project_id,p.project_id)    = cmt.project_id /* Bug 3613712 : Perf Issue SQL rep ID : 7938694 FTS on pa_commitment_txns */
            --Bug#960813
                --    and cmt.line_type                = 'R'
                      and cmt.burden_sum_source_run_id = init_cmt_run_id );

 -- Cursor to select Burden cost components of all the non-summarized CDLs of a project

cursor bcc_cur is
select  source_project_id,
        source_task_id,
        source_org_id    ,
        source_pa_period ,
        source_gl_period ,
        source_txn_source,
        source_line_type ,
        source_ind_cost_code ,
        source_txn_ref1,
        source_expenditure_type,
        source_ind_expenditure_type,
        source_exp_category    ,
        source_revenue_category,
        source_cost_base       ,
        source_compiled_multiplier,
        source_ind_rate_sch_id ,
        source_ind_rate_sch_rev_id,
        source_burden_cost     ,
        source_run_id,
        source_burden_sum_rej_code,
        resource_class,
        source_system_linkage_function,  -- 4057874
        dest_project_id,
        dest_task_id          ,
        dest_org_id,
        dest_pa_period      ,
        dest_txn_source,
        dest_gl_period      ,
        dest_exp_category   ,
        dest_revenue_category   ,
        dest_ind_exp_type   ,
        dest_line_type    ,
        dest_txn_ref1,
        dest_ind_cost_code,
        acct_raw_cost          ,                                           /* 2324127 */
        acct_burdened_cost     ,                                           /* 2324127 */
        denom_currency_code    ,                                           /* 2324127 */
        denom_raw_cost         ,                                           /* 2324127 */
        denom_burdened_cost    ,                                           /* 2324127 */
        acct_currency_code     ,                                           /* 2324127 */
        acct_rate_date         ,                                           /* 2324127 */
        acct_rate_type         ,                                           /* 2324127 */
        acct_exchange_rate     ,                                           /* 2324127 */
 --     receipt_currency_code  ,                                           /* 2324127 */
 --     receipt_currency_amount,                                           /* 2324127 */
 --     receipt_exchange_rate  ,                                           /* 2324127 */
        project_currency_code  ,                                           /* 2324127 */
        project_rate_date      ,                                           /* 2324127 */
        project_rate_type      ,                                           /* 2324127 */
        project_exchange_rate  ,                                           /* 2324127 */
        vendor_id 	       ,					-- 4057874
        inventory_item_id      ,					-- 4057874
        bom_labor_resource_id  ,  					-- 4057874
        bom_equipment_resource_id ,  					-- 4057874
        dest_summary_group
from   pa_cmt_burden_summary_v
order by dest_summary_group;

begin

/* Bug 2989775: If the client extension has been modified to create same line burdening
   for commitment transactions irrespective of project type set up, then no BTC lines
   should be created for commitment transactions and so no processing will be done in this
   procedure. */

IF PA_CLIENT_EXTN_BURDEN_SUMMARY.Same_Line_Burden_Cmt
then null;
else

   select  pa_burden_sum_run_s.nextval
     into  current_run_id
     from  dual;
/*
 * Bug 2838499: commented this stray sql. (nothing related to the bug.)
 * select  set_of_books_id
 *   into  sob_id
 *   from  pa_implementations;
 */

  -- Step 1 . Select All projects

  begin

  <<PROJECT_LOOP>>    --  for projects from projects cursor

     stage := 200;  -- at start
  for  proj_rec in projects   loop
    --dbms_output.put_line('no of projects');
     -- Set current project id in the package pa_burden_costing for view definitions and for local variable

     PA_BURDEN_COSTING.set_current_project_id(proj_rec.project_id);
     current_project_id := proj_rec.project_id;

     -- ======
     -- Bug : 3699045 - PJ.M:B4:P13:OTH:PERF:XPL PERFORMANCE ISSUES IN PAVW341.SQL
     -- ======
     PA_BURDEN_COSTING.set_current_sponsored_flag(proj_rec.project_id);

     -- Step 2a.  Project level validations
     -- Set the project and task id of the burden expenditure item
     -- depending on burden_accounting flag

     begin
     stage := 210;  -- locking project record
        select attribute1
          into l_attribute1
          from pa_projects_all
         where project_id = proj_rec.project_id
           for update of attribute1 nowait;

         update pa_commitment_txns
                set burden_sum_rejection_code = NULL
         where  project_id = current_project_id
           and  burden_sum_source_run_id      = init_cmt_run_id;

       exception
         when resource_busy then
            goto NEXT_PROJECT;
      end;

      -- Step 2b. Do CMT level validations of the project

      begin
        stage := 220;  -- updating error transactions
        update pa_commitment_txns
                set burden_sum_rejection_code = 'BCC_EXP_TYPE_NULL',
                    burden_sum_source_run_id  = current_run_id
         where project_id = current_project_id
           and (cmt_line_id) in
                 (select cmt.cmt_line_id
                    from pa_commitment_txns cmt
-- Bug#960813
--                   where cmt.line_type                   = 'R'
                   where cmt.burden_sum_source_run_id    = current_run_id
                     and cmt.project_id                  = current_project_id
                     and exists (select  1
                          from  pa_compiled_multipliers cm,
                                pa_ind_cost_codes icc
                        where cm.ind_compiled_set_id=cmt.cmt_ind_compiled_set_id
                          and  icc.ind_cost_code      = cm.ind_cost_code
                          and  icc.expenditure_type is null));
           exception
              when others then
                   null;
       end;


       prev_bcc_rec.dest_summary_group   := null;
       l_burden_cost                     := 0;
      /* start fix bug#2324127 */
       l_acct_burdened_cost                := 0;
       l_denom_burdened_cost               := 0;
      /* end fix bug#2324127 */
       prev_bcc_rec.source_org_id        := null;
     -- Step 4. select Burden cost components of CDLs.

     begin

     for  bcc_rec in bcc_cur  loop
        stage := 230;  -- in burden loop

        -- 5c. Create expenditure item for every dest_summary_group change

      if  bcc_rec.dest_summary_group = prev_bcc_rec.dest_summary_group then
              /* commented for bug 5984985
              l_burden_cost := l_burden_cost + bcc_rec.source_burden_cost;
         -- start fix bug#2324127
               l_acct_burdened_cost   := l_acct_burdened_cost   + bcc_rec.acct_burdened_cost   ;
         -- end fix bug#2324127
             l_denom_burdened_cost  := l_denom_burdened_cost  + bcc_rec.denom_burdened_cost  ;
             commented for bug 5984985 */

             l_burden_cost := l_burden_cost + pa_currency.round_currency_amt1(bcc_rec.source_burden_cost); /* added currency rounding for bug 5984985 */
	     l_acct_burdened_cost   := l_acct_burdened_cost   + pa_currency.round_currency_amt1(bcc_rec.acct_burdened_cost); /* added currency rounding for bug 5984985 */
             l_denom_burdened_cost  := l_denom_burdened_cost  + pa_currency.round_trans_currency_amt1(bcc_rec.denom_burdened_cost,bcc_rec.denom_currency_code); /* added currency rounding for bug 5984985 */

             if nvl(bcc_rec.source_txn_ref1,'X') <> nvl(prev_bcc_rec.source_txn_ref1,'X') then
                   l_txn_ref1 := '';  -- nullify the transaction reference column
             else
                   l_txn_ref1 := prev_bcc_rec.source_txn_ref1;
             end if;
          -- Check for other attributes of summarized burden expenditure item
      else
           -- Create new summarization Commitment transaction
           -- Get new commitment transaction id

           -- Checking for l_burden_cost <> 0 rather than l_burden_cost > 0
           -- l_burden_cost is replaced by l_denom_burdened_cost <> 0 for bug 2324127
       if l_denom_burdened_cost <> 0 then

           begin
              select  pa_commitment_txns_s.nextval
                into  l_cmt_line_id
                from  dual;

        -- Getting expenditure_item_date as the end_date for that pa period
              stage := 235;  -- Getting expenditure_item_date
              l_pa_end_date := pa_utils.get_pa_end_date(prev_bcc_rec.dest_pa_period);
        -- Getting GL period from the view itself
              stage := 240;  -- creating transactions
              insert into pa_commitment_txns (
              cmt_line_id,
              project_id,
              task_id ,
              transaction_source ,
              line_type ,
              expenditure_item_date,
              pa_period ,
              gl_period,
              expenditure_type,
              expenditure_category ,
              revenue_category,
              system_linkage_function,
              tot_cmt_burdened_cost ,
              original_txn_reference1,
              last_updated_by ,
              last_update_date ,
              creation_date ,
              created_by ,
              last_update_login,
              acct_raw_cost       ,                     /* 2324127 */
              acct_burdened_cost  ,                     /* 2324127 */
              denom_currency_code ,                     /* 2324127 */
              denom_raw_cost      ,                     /* 2324127 */
              denom_burdened_cost ,                     /* 2324127 */
              acct_currency_code  ,                     /* 2324127 */
              acct_rate_date      ,                     /* 2324127 */
              acct_rate_type      ,                     /* 2324127 */
              acct_exchange_rate  ,                     /* 2324127 */
--            receipt_currency_code   ,                 /* 2324127 */
--            receipt_currency_amount ,                 /* 2324127 */
--            receipt_exchange_rate   ,                 /* 2324127 */
              project_currency_code   ,                 /* 2324127 */
              project_rate_date       ,                 /* 2324127 */
              project_rate_type       ,                 /* 2324127 */
              project_exchange_rate   ,                 /* 2324127 */
              burden_sum_dest_run_id,
              organization_id ,
              resource_class    ,
              vendor_id  ,  				/* 4057874 */
              inventory_item_id ,  			/* 4057874 */
              bom_labor_resource_id  ,  		/* 4057874 */
              bom_equipment_resource_id    ,  		/* 4057874 */
              src_system_linkage_function )   		/* 4057874 */
              values (
              l_cmt_line_id,
              prev_bcc_rec.dest_project_id,
              prev_bcc_rec.dest_task_id,
              prev_bcc_rec.dest_txn_source,
              prev_bcc_rec.dest_line_type,
              nvl(l_pa_end_date, sysdate) ,
              prev_bcc_rec.dest_pa_period,
              prev_bcc_rec.dest_gl_period,
              prev_bcc_rec.dest_ind_exp_type,
              prev_bcc_rec.dest_exp_category,
              prev_bcc_rec.dest_revenue_category,
              'BTC',
              l_burden_cost,
              l_txn_ref1,
              1,
              sysdate,
              sysdate,
              0,
              0,
              0,                                        /* acct_raw_cost  2324127 */
              l_acct_burdened_cost  ,                                  /* 2324127 */
              prev_bcc_rec.denom_currency_code ,                       /* 2324127 */
              0                                ,        /* denom_raw_cost 2324127 */
              l_denom_burdened_cost            ,                       /* 2324127 */
              prev_bcc_rec.acct_currency_code  ,                       /* 2324127 */
              prev_bcc_rec.acct_rate_date      ,                       /* 2324127 */
              prev_bcc_rec.acct_rate_type      ,                       /* 2324127 */
              prev_bcc_rec.acct_exchange_rate  ,                       /* 2324127 */
--            receipt_currency_code   ,                                /* 2324127 */
--            receipt_currency_amount ,                                /* 2324127 */
--            receipt_exchange_rate   ,                                /* 2324127 */
              prev_bcc_rec.project_currency_code   ,                   /* 2324127 */
              prev_bcc_rec.project_rate_date       ,                   /* 2324127 */
              prev_bcc_rec.project_rate_type       ,                   /* 2324127 */
              prev_bcc_rec.project_exchange_rate   ,                   /* 2324127 */
              current_run_id,
              prev_bcc_rec.dest_org_id,
              prev_bcc_rec.resource_class,
              prev_bcc_rec.vendor_id,  					/* 4057874 */
              prev_bcc_rec.inventory_item_id,  				/* 4057874 */
              prev_bcc_rec.bom_labor_resource_id,  			/* 4057874 */
              prev_bcc_rec.bom_equipment_resource_id,  			/* 4057874 */
              prev_bcc_rec.source_system_linkage_function );   		/* 4057874 */
           end;
        end if;

         l_burden_cost :=  pa_currency.round_currency_amt1(bcc_rec.source_burden_cost); /* added currency rounding for bug 5984985 */
         l_acct_burdened_cost := pa_currency.round_currency_amt1(bcc_rec.acct_burdened_cost);    /* added currency rounding for bug 5984985 */        /* 2324127 */
         l_denom_burdened_cost :=  pa_currency.round_trans_currency_amt(bcc_rec.denom_burdened_cost,bcc_rec.denom_currency_code);   /* added currency rounding for bug 5984985 */         /* 2324127 */


          prev_bcc_rec.source_project_id           :=bcc_rec.source_project_id;
          prev_bcc_rec.source_task_id              :=bcc_rec.source_task_id;
          prev_bcc_rec.source_org_id               :=bcc_rec.source_org_id;
          prev_bcc_rec.source_pa_period            :=bcc_rec.source_pa_period;
          prev_bcc_rec.source_gl_period            :=bcc_rec.source_gl_period;
          prev_bcc_rec.source_txn_source           :=bcc_rec.source_txn_source;
          prev_bcc_rec.source_line_type            :=bcc_rec.source_line_type;
          prev_bcc_rec.source_ind_cost_code        :=bcc_rec.source_ind_cost_code;
          prev_bcc_rec.source_txn_ref1             :=bcc_rec.source_txn_ref1;
          prev_bcc_rec.source_expenditure_type     :=bcc_rec.source_expenditure_type;
          prev_bcc_rec.source_ind_expenditure_type :=bcc_rec.source_ind_expenditure_type;
          prev_bcc_rec.source_exp_category         :=bcc_rec.source_exp_category;
          prev_bcc_rec.source_revenue_category     :=bcc_rec.source_revenue_category;
          prev_bcc_rec.source_cost_base            :=bcc_rec.source_cost_base;
          prev_bcc_rec.source_compiled_multiplier  :=bcc_rec.source_compiled_multiplier;
          prev_bcc_rec.source_ind_rate_sch_id      :=bcc_rec.source_ind_rate_sch_id;
          prev_bcc_rec.source_ind_rate_sch_rev_id  :=bcc_rec.source_ind_rate_sch_rev_id;
          prev_bcc_rec.source_burden_cost          :=pa_currency.round_currency_amt1(bcc_rec.source_burden_cost); /* added currency rounding for bug 5984985 */
        -- prev_bcc_rec.source_burden_cost          :=bcc_rec.source_burden_cost;
          prev_bcc_rec.source_run_id               :=bcc_rec.source_run_id;
          prev_bcc_rec.source_burden_sum_rej_code  :=bcc_rec.source_burden_sum_rej_code;
          prev_bcc_rec.dest_project_id             :=bcc_rec.dest_project_id;
          prev_bcc_rec.dest_task_id                :=bcc_rec.dest_task_id;
          prev_bcc_rec.dest_org_id                 :=bcc_rec.dest_org_id;
          prev_bcc_rec.dest_pa_period              :=bcc_rec.dest_pa_period;
          prev_bcc_rec.dest_gl_period              :=bcc_rec.dest_gl_period;
          prev_bcc_rec.dest_txn_source             :=bcc_rec.dest_txn_source;
          prev_bcc_rec.dest_line_type              :=bcc_rec.dest_line_type;
          prev_bcc_rec.dest_exp_category           :=bcc_rec.dest_exp_category;
          prev_bcc_rec.dest_revenue_category       :=bcc_rec.dest_revenue_category;
          prev_bcc_rec.dest_ind_exp_type           :=bcc_rec.dest_ind_exp_type;
          prev_bcc_rec.dest_txn_ref1               :=bcc_rec.dest_txn_ref1;
          prev_bcc_rec.dest_ind_cost_code          :=bcc_rec.dest_ind_cost_code;
          prev_bcc_rec.dest_summary_group          :=bcc_rec.dest_summary_group;
           /* start bug 2324127 */

          prev_bcc_rec.denom_currency_code         :=bcc_rec.denom_currency_code         ;
          prev_bcc_rec.acct_currency_code          :=bcc_rec.acct_currency_code          ;
          prev_bcc_rec.acct_rate_date              :=bcc_rec.acct_rate_date              ;
          prev_bcc_rec.acct_rate_type              :=bcc_rec.acct_rate_type              ;
          prev_bcc_rec.acct_exchange_rate          :=bcc_rec.acct_exchange_rate          ;
          prev_bcc_rec.project_currency_code       :=bcc_rec.project_currency_code       ;
          prev_bcc_rec.project_rate_date           :=bcc_rec.project_rate_date           ;
          prev_bcc_rec.project_rate_type           :=bcc_rec.project_rate_type           ;
          prev_bcc_rec.project_exchange_rate       :=bcc_rec.project_exchange_rate       ;
          prev_bcc_rec.resource_class              :=bcc_rec.resource_class       ;

          /* 4057874 */
          prev_bcc_rec.vendor_id := bcc_rec.vendor_id;
          prev_bcc_rec.inventory_item_id := bcc_rec.inventory_item_id;
          prev_bcc_rec.bom_labor_resource_id := bcc_rec.bom_labor_resource_id;
          prev_bcc_rec.bom_equipment_resource_id := bcc_rec.bom_equipment_resource_id;
          prev_bcc_rec.source_system_linkage_function := bcc_rec.source_system_linkage_function;

         /* bug fix 4091690 starts */
         if P_BTC_SRC_RESRC = 'Y' then

          pa_client_extn_burden_resource.client_column_values (
                         p_job_id => l_job_id,
                         p_non_labor_resource => l_non_labor_resource,
                         p_non_labor_resource_orgn_id => l_non_labor_resource_orgn_id,
                         p_wip_resource_id => l_wip_resource_id,
                         p_incurred_by_person_id => l_incurred_by_person_id,
                         p_vendor_id => prev_bcc_rec.vendor_id,
                         p_inventory_item_id => prev_bcc_rec.inventory_item_id,
                         p_bom_labor_resource_id => prev_bcc_rec.bom_labor_resource_id,
                         p_bom_equipment_resource_id => prev_bcc_rec.bom_equipment_resource_id);
          else
              prev_bcc_rec.vendor_id := null;
              prev_bcc_rec.inventory_item_id := null;
              prev_bcc_rec.bom_labor_resource_id := null;
              prev_bcc_rec.bom_equipment_resource_id := null;

              prev_bcc_rec.source_system_linkage_function := null;

          end if; -- profile option

          /* bug fix 4091690 ends */



          /* start bug 2324127 */
       end if;
      end loop;   -- bcc_cur loop ends here
    end;

    <<NEXT_PROJECT>>
           -- Checking for l_burden_cost <> 0 rather than l_burden_cost > 0
           -- Replaced l_burden_cost by l_denom_burdened_cost for bug#2324127
        if l_denom_burdened_cost <> 0 then
           begin
              select  pa_commitment_txns_s.nextval
                into  l_cmt_line_id
                from  dual;

             -- Getting expenditure_item_date as the end_date for that pa period
                stage := 245;  -- Getting expenditure_item_date
                l_pa_end_date := pa_utils.get_pa_end_date(prev_bcc_rec.dest_pa_period);
             -- create summarized commitment transaction
              insert into pa_commitment_txns (
              cmt_line_id,
              project_id,
              task_id ,
              transaction_source ,
              line_type ,
              expenditure_item_date,
              pa_period ,
              gl_period,
              expenditure_type,
              expenditure_category ,
              revenue_category,
              system_linkage_function,
              tot_cmt_burdened_cost ,
              original_txn_reference1,
              last_updated_by ,
              last_update_date ,
              creation_date ,
              created_by ,
              last_update_login,
              acct_raw_cost       ,                     /* 2324127 */
              acct_burdened_cost  ,                     /* 2324127 */
              denom_currency_code ,                     /* 2324127 */
              denom_raw_cost      ,                     /* 2324127 */
              denom_burdened_cost ,                     /* 2324127 */
              acct_currency_code  ,                     /* 2324127 */
              acct_rate_date      ,                     /* 2324127 */
              acct_rate_type      ,                     /* 2324127 */
              acct_exchange_rate  ,                     /* 2324127 */
--            receipt_currency_code   ,                 /* 2324127 */
--            receipt_currency_amount ,                 /* 2324127 */
--            receipt_exchange_rate   ,                 /* 2324127 */
              project_currency_code   ,                 /* 2324127 */
              project_rate_date       ,                 /* 2324127 */
              project_rate_type       ,                 /* 2324127 */
              project_exchange_rate   ,                 /* 2324127 */
              burden_sum_dest_run_id,
              organization_id
             ,resource_class,
              vendor_id  ,  				/* 4057874 */
              inventory_item_id ,  			/* 4057874 */
              bom_labor_resource_id  ,  		/* 4057874 */
              bom_equipment_resource_id    ,  		/* 4057874 */
              src_system_linkage_function )   		/* 4057874 */

              values (
              l_cmt_line_id,
              prev_bcc_rec.dest_project_id,
              prev_bcc_rec.dest_task_id,
              prev_bcc_rec.dest_txn_source,
              prev_bcc_rec.dest_line_type,
              nvl(l_pa_end_date, sysdate) ,
              prev_bcc_rec.dest_pa_period,
              prev_bcc_rec.dest_gl_period,
              prev_bcc_rec.dest_ind_exp_type,
              prev_bcc_rec.dest_exp_category,
              prev_bcc_rec.dest_revenue_category,
              'BTC',
              l_burden_cost,
              l_txn_ref1,
              1,
              sysdate,
              sysdate,
              0,
              0,
              0,                                        /* acct_raw_cost  2324127 */
              l_acct_burdened_cost  ,                                  /* 2324127 */
              prev_bcc_rec.denom_currency_code ,                       /* 2324127 */
              0                                ,        /* denom_raw_cost 2324127 */
              l_denom_burdened_cost            ,                       /* 2324127 */
              prev_bcc_rec.acct_currency_code  ,                       /* 2324127 */
              prev_bcc_rec.acct_rate_date      ,                       /* 2324127 */
              prev_bcc_rec.acct_rate_type      ,                       /* 2324127 */
              prev_bcc_rec.acct_exchange_rate  ,                       /* 2324127 */
--            receipt_currency_code   ,                                /* 2324127 */
--            receipt_currency_amount ,                                /* 2324127 */
--            receipt_exchange_rate   ,                                /* 2324127 */
              prev_bcc_rec.project_currency_code   ,                   /* 2324127 */
              prev_bcc_rec.project_rate_date       ,                   /* 2324127 */
              prev_bcc_rec.project_rate_type       ,                   /* 2324127 */
              prev_bcc_rec.project_exchange_rate   ,                   /* 2324127 */
              current_run_id,
              prev_bcc_rec.dest_org_id
             ,prev_bcc_rec.resource_class,
              prev_bcc_rec.vendor_id,  					/* 4057874 */
              prev_bcc_rec.inventory_item_id,  				/* 4057874 */
              prev_bcc_rec.bom_labor_resource_id,  			/* 4057874 */
              prev_bcc_rec.bom_equipment_resource_id,  			/* 4057874 */
              prev_bcc_rec.source_system_linkage_function );   		/* 4057874 */
         end;
        end if;

    -- Update those Commitment transactions which are successfully processed
    -- with run id

         update pa_commitment_txns
                set burden_sum_source_run_id  = current_run_id
         where  (cmt_line_id) in
              ( select  cmt_line_id
                from  pa_commitment_txns cmt
                where cmt.burden_sum_rejection_code is NULL
            -- Bug#960813
            -- and cmt.line_type                   = 'R'
                   and cmt.burden_sum_source_run_id = init_cmt_run_id
                   and cmt.project_id                  = current_project_id);
       COMMIT;

  end loop project_loop;
 end;
    <<END_OF_PROCESS>>
     null;
     x_run_id := current_run_id;

end if; -- Same_Line_Burden_Cmt

end CREATE_BURDEN_CMT_TRANSACTION ;

/******************************************************************************
    PROCEDURE InsBurdenAudit
******************************************************************************/
/* Bug#5406802
   Changed the logic for populating the audit table.
   Used the cached expenditure item pl/sql table for populating the audit table
   instead opening the cursor from CDL table.
*/

 PROCEDURE  InsBurdenAudit( p_project_id         IN pa_cost_distribution_lines_all.project_id%TYPE,
                            p_request_id         IN  NUMBER ,
			    p_user_id            IN number,
			    x_status          IN OUT NOCOPY number   )
  IS
  l_program_id NUMBER;
  l_program_application_id NUMBER;
  l_profile_set_size NUMBER ;
  l_eid_tbl                    PA_PLSQL_DATATYPES.IdTabTyp;                  /*2933915*/
  l_line_tbl                   PA_PLSQL_DATATYPES.IdTabTyp;                  /*2933915*/
  l_prev_id_tbl                PA_PLSQL_DATATYPES.IdTabTyp;                  /*2933915*/
  l_run_id_tbl                 PA_PLSQL_DATATYPES.IdTabTyp;                  /*2933915*/



 BEGIN
  l_program_id := FND_GLOBAL.CONC_PROGRAM_ID();
  l_program_application_id := FND_GLOBAL.PROG_APPL_ID();
  FND_PROFILE.GET('PA_NUM_CDL_PER_SET', l_profile_set_size );
  x_status := 0;

 FORALL i in 1..l_tbl_eiid.count
         INSERT INTO pa_aud_cost_dist_lines (
             expenditure_item_id
          ,  line_num
          ,  ind_compiled_set_id
          ,  burden_sum_source_run_id
          ,  creation_date
          ,  created_by
          ,  program_id
          ,  program_application_id
          ,  request_id
          )
          SELECT
	        expenditure_Item_id,
   	        line_num,
	        prev_ind_compiled_set_id,
	        burden_sum_source_run_id,
	        sysdate,
		    p_user_id,
	        l_program_id,
            l_program_application_id,
            p_request_id
	    FROM
	        pa_cost_distribution_lines_all
	    WHERE expenditure_item_id = l_tbl_eiid(i)
	    AND   line_num= l_tbl_cdlln(i)
	    AND   prev_ind_compiled_set_id IS NOT NULL
            AND  request_id = p_request_id
            AND  project_id  = p_project_id;

      EXCEPTION
   WHEN  OTHERS  THEN
    X_status := SQLCODE;
    RAISE;
 END  InsBurdenAudit;


/* Bug# 5406802
   Introduced this procedure to populate global temporary table with valid EI's to be processed
   for BTC generation picked up for the first time.
*/
procedure populate_gtemp(p_current_run_id NUMBER, p_project_id NUMBER, x_end_date varchar2) is

l_end_date                   DATE := to_date(x_end_date,'DD-MM-RR');

begin
/* Bug 5896943: Inserting prvdr_accrual_date in place of expenditure_item_date
   for period accrual transactions so that the reversal BTC's will be in the future period.
*/
/* Modified expenditure item date for bug 5907315*/
/* Bug# 9373031: Added hint for performane issue */

insert into PA_EI_CDL_CM_GTEMP(
 PROJECT_ID			,TASK_ID			,ORGANIZATION_ID
,PA_DATE			,PA_PERIOD_NAME			,ATTRIBUTE1
,ATTRIBUTE2			,ATTRIBUTE3			,ATTRIBUTE4
,ATTRIBUTE5			,ATTRIBUTE6			,ATTRIBUTE7
,ATTRIBUTE8			,ATTRIBUTE9			,ATTRIBUTE10
,ATTRIBUTE_CATEGORY		,PERSON_TYPE			,PO_LINE_ID
,SYSTEM_LINKAGE_FUNCTION	,EI_EXPENDITURE_TYPE		,IND_COMPILED_SET_ID
,PREV_IND_COMPILED_SET_ID	,EXPENDITURE_ITEM_ID		,LINE_NUM
,EXPENDITURE_ITEM_DATE		,CDL_AMOUNT                     ,CDL_PROJFUNC_CURRENCY_CODE
,CDL_DENOM_RAW_COST             ,CDL_DENOM_CURRENCY_CODE        ,CDL_ACCT_RAW_COST
,CDL_ACCT_CURRENCY_CODE         ,CDL_PROJECT_RAW_COST           ,CDL_PROJECT_CURRENCY_CODE
,BURDEN_SUM_SOURCE_RUN_ID 	,BURDEN_SUM_REJECTION_CODE 	,SYSTEM_REFERENCE1
,DENOM_CURRENCY_CODE 	  	,ACCT_CURRENCY_CODE 	  	,PROJECT_CURRENCY_CODE
,PROJFUNC_CURRENCY_CODE 	,BILLABLE_FLAG			,REQUEST_ID
,ADJUSTMENT_TYPE		,JOB_ID				,NON_LABOR_RESOURCE
,NON_LABOR_RESOURCE_ORGN_ID 	,WIP_RESOURCE_ID 	  	,INCURRED_BY_PERSON_ID
,INVENTORY_ITEM_ID
,ORG_ID                         ,ACCT_RATE_DATE                 ,ACCT_RATE_TYPE
,ACCT_EXCHANGE_RATE             ,PROJECT_RATE_DATE              ,PROJECT_RATE_TYPE
,PROJECT_EXCHANGE_RATE          ,PROJFUNC_COST_RATE_DATE        ,PROJFUNC_COST_RATE_TYPE
,PROJFUNC_COST_EXCHANGE_RATE)
(
select /*+ INDEX (cdl, PA_COST_DISTRIBUTION_LINES_N10) */
  cdl.project_id
 ,cdl.task_id
 ,nvl(ei.override_to_organization_id,e.incurred_by_organization_id)
 ,cdl.pa_date
 ,decode(cdl.prev_ind_compiled_set_id, null, cdl.pa_period_name
         ,nvl(pa_utils2.get_pa_period_name(ei.expenditure_item_date, ei.org_id), cdl.pa_period_name))
 , ei.attribute1 , ei.attribute2 , ei.attribute3 , ei.attribute4
 , ei.attribute5  , ei.attribute6 , ei.attribute7
 , ei.attribute8  , ei.attribute9 , ei.attribute10
 , ei.attribute_category , e.person_type , ei.po_line_id
 , ei.system_linkage_function , ei.expenditure_type , cdl.ind_compiled_set_id
 , cdl.prev_ind_compiled_set_id , ei.expenditure_item_id , cdl.line_num
  , decode(NVL(fnd_profile.value_specific('PA_REVENUE_ORIGINAL_RATE_FORRECALC'),'N'),'N',nvl(ei.prvdr_accrual_date,ei.expenditure_item_date),ei.expenditure_item_date)
 , cdl.amount , cdl.projfunc_currency_code
 , cdl.denom_raw_cost , cdl.denom_currency_code        , cdl.acct_raw_cost
 , cdl.acct_currency_code         , cdl.project_raw_cost           , cdl.project_currency_code
 , cdl.burden_sum_source_run_id , cdl.burden_sum_rejection_code , cdl.system_reference1
 , ei.denom_currency_code , ei.acct_currency_code , ei.project_currency_code
 , ei.projfunc_currency_code , cdl.billable_flag , cdl.request_id
 , DECODE(ei.adjustment_type, 'BURDEN_RESUMMARIZE'
                          , DECODE(ei.system_linkage_function, 'VI', ei.adjustment_type
                                  , DECODE(ei.po_line_id, NULL, NULL, ei.adjustment_type)), NULL)   adjustment_type
 , ei.job_id , ei.non_labor_resource
 , ei.organization_id NON_LABOR_RESOURCE_ORGN_ID  , ei.wip_resource_id , e.incurred_by_person_id
 , ei.inventory_item_id
 , ei.org_id                     ,CDL.ACCT_RATE_DATE             ,CDL.ACCT_RATE_TYPE
 ,CDL.ACCT_EXCHANGE_RATE         ,CDL.PROJECT_RATE_DATE          ,CDL.PROJECT_RATE_TYPE
 ,CDL.PROJECT_EXCHANGE_RATE      ,CDL.PROJFUNC_COST_RATE_DATE    ,CDL.PROJFUNC_COST_RATE_TYPE
 ,CDL.PROJFUNC_COST_EXCHANGE_RATE
 FROM
    PA_COST_DISTRIBUTION_LINES_ALL CDL,
    PA_EXPENDITURE_ITEMS EI,
    PA_EXPENDITURES_ALL E
 WHERE  cdl.burden_sum_source_run_id = p_current_run_id
 AND    cdl.project_id               = p_project_id
 AND    cdl.expenditure_item_id      = ei.expenditure_item_id
 AND    cdl.line_type                = 'R'
 AND    e.expenditure_id             = ei.expenditure_id
 AND    nvl(ei.adjustment_type,'-999') <> 'BURDEN_RESUMMARIZE'  /*Bug# 6449677*/
 AND    cdl.burden_sum_rejection_code  is NULL
 AND    cdl.prev_ind_compiled_set_id IS NULL
 AND    ei.expenditure_item_date    <= nvl(l_end_date,ei.expenditure_item_date)
 AND    ( ei.transaction_source IS NULL or pa_utils2.get_ts_allow_burden_flag(ei.transaction_source)<>'Y' ));


 IF SQL%ROWCOUNT > 0 THEN

   /* The sub query should return only one row, if not we have to use distinct clause*/
   UPDATE PA_EI_CDL_CM_GTEMP ei
	set (COST_PLUS_STRUCTURE ,COST_BASE) =
	    (select /*+ ORDERED */ distinct
             cbcc.cost_plus_structure, cbcc.cost_base
  	     from
             PA_COST_BASE_EXP_TYPES CBET,
             PA_COMPILED_MULTIPLIERS CM,
             PA_COST_BASE_COST_CODES CBCC
             WHERE cbet.expenditure_type = ei.ei_expenditure_type
             AND   cbet.cost_base_type = 'INDIRECT COST'
             AND   cm.ind_Compiled_set_id = ei.ind_compiled_set_id
             AND   cm.cost_base = cbet.cost_base
             AND   cbcc.cost_base_cost_code_id = cm.cost_base_cost_code_id
             AND   cbcc.ind_cost_code = cm.ind_cost_code
             AND   cbcc.cost_base = cm.cost_base
             AND   cbcc.cost_base_type = 'INDIRECT COST'
             AND   cbcc.cost_plus_structure = cbet.cost_plus_structure)
	where ei.cost_base is null
	and   ei.prev_ind_compiled_set_id is null
	AND   ei.burden_sum_source_run_id = p_current_run_id
        AND   ei.project_id               = p_project_id;

END IF;

end populate_gtemp;

/* Introduced this Procedure for updating CDL records with rejection code 'BCC_EXP_TYPE_NULL'
   in case if there is no icc_expenditure_type defined for an indirect cost code used in structure
   that is attached to the burden schedule*/

PROCEDURE update_gtemp(l_request_id number) IS

l_eiid  typ_tbl_eiid;
l_linenum  typ_tbl_cdlln; /*added for the bug#5949107*/

BEGIN

     l_eiid.delete;
      l_linenum.delete; /*added for the bug#5949107*/
     UPDATE PA_EI_CDL_CM_GTEMP  gtemp
     set    BURDEN_SUM_REJECTION_CODE = 'BCC_EXP_TYPE_NULL'
     WHERE  BURDEN_SUM_REJECTION_CODE IS NULL
     and    exists ( select 1 from pa_ind_cost_codes icc, pa_cost_base_cost_codes cbcc
                     where    cbcc.cost_plus_structure = gtemp.cost_plus_structure
		     and      cbcc.cost_base = gtemp.cost_base
		     and      cbcc.cost_base_type = 'INDIRECT COST'
		     and      cbcc.ind_cost_code = icc.ind_cost_code
		     and      icc.expenditure_type is NULL )
		   returning expenditure_Item_id,line_num bulk collect into l_eiid,l_linenum; /*l_linenum is added for the bug#5949107*/

     If l_eiid.count > 0 THEN

     FORALL I in 1..l_eiid.count
     UPDATE PA_COST_DISTRIBUTION_LINES
     set    BURDEN_SUM_REJECTION_CODE = 'BCC_EXP_TYPE_NULL'
     where  expenditure_item_id = l_eiid(i)
     and line_num = l_linenum(i); /*added for the bug#5949107*/

     End If;


END update_gtemp;

end PA_BURDEN_COSTING;

/
