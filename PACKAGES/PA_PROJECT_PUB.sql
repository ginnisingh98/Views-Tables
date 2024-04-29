--------------------------------------------------------
--  DDL for Package PA_PROJECT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECT_PUB" AUTHID DEFINER as
/* $Header: PAPMPRPS.pls 120.24.12010000.13 2010/01/20 11:10:15 rthumma ship $ */
/*#
 * This package contains the public APIs for project, task and deliverable information.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Project Definition
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

  /*
   * p_mode constants (Duplicated from EGO_USER_ATTRS_DATA_PVT to avoid
   * Spec dependency on EGO package)
   * ----------------
   * Possible values for p_mode parameter in Load_Extensible_Attribute(s)
   * : the value of the p_mode parameter affects how these APIs treat the
   * passed-in data.For example, passing G_CREATE_MODE will
   * cause the API to execute an Insert statement on the extension table.
   * As a more complicated example, consider an Attribute Group called
   * 'Emp Info' with a 'Date Logged' Attribute and a 'Current Status'
   * Attribute.  The 'Date Logged' Attribute might well have a Minimum
   * and Maximum value range of 'SYSDATE'.  Thus, if G_CREATE_MODE were
   * passed to Validate_Row, then the API would need to verify that the
   * value of the 'Date Logged' Attribute was the Date on the day of that
   * insertion.  Say, however, that sometime later the bug status changes,
   * and we want to update the extension table to reflect this.  In this
   * case, we wouldn't want Validate_Row to evaluate the 'Date Logged'
   * Attribute as if it were just being inserted, so we'd pass either
   * G_UPDATE_MODE or G_SYNC_MODE to Validate_Row so it would know the
   * context in which it should apply the validation rules for the row.
   * (G_SYNC_MODE instructs the API to determine for itself whether there
   * exists a row in the extension table for the passed-in data.  If such
   * a row exists, then it is updated; if not, a row is created and the
   * data are inserted into it.)
   * If no value is passed for p_mode, G_SYNC_MODE is assumed.  If an
   * invalid value is passed for p_mode, such as G_DELETE_MODE on a row
   * that doesn't exist, an error occurs.
   */
G_CREATE_MODE               CONSTANT VARCHAR2(10) := 'CREATE';        --4th
G_UPDATE_MODE               CONSTANT VARCHAR2(10) := 'UPDATE';        --2nd
G_DELETE_MODE               CONSTANT VARCHAR2(10) := 'DELETE';        --1st
G_SYNC_MODE                 CONSTANT VARCHAR2(10) := 'SYNC';          --3rd


--Package constant used for package version validation
G_API_VERSION_NUMBER    CONSTANT NUMBER := 1.0;
-- Package variable to indicate whether some date checks in Update_task
-- need to be deferred until all tasks have been processed
G_ParChildTsk_chks_deferred  VARCHAR2(1) := 'N';


--Locking exception
ROW_ALREADY_LOCKED  EXCEPTION;
PRAGMA EXCEPTION_INIT(ROW_ALREADY_LOCKED, -54);

G_PROJECT_NUMBER_GEN_MODE  VARCHAR2(30) := PA_PROJECT_UTILS.GetProjNumMode;
G_PROJECT_NUMBER_TYPE      VARCHAR2(30) := PA_PROJECT_UTILS.GetProjNumType;

--bug 2738747
G_Published_version_exists    VARCHAR2(1);
G_IS_WP_SEPARATE_FROM_FN      VARCHAR2(1);
G_IS_WP_VERSIONING_ENABLED    VARCHAR2(1);
--bug 2738747
G_WP_STR_EXISTS               VARCHAR2(1);

-- 3700247 Added global variable
G_DLVR_STRUCTURE_ENABLED      VARCHAR2(1) := NULL;

-- bug 4199694
G_FLOW_MODE                   VARCHAR2(30);
G_OP_VALIDATE_FLAG            VARCHAR2(1);

-- 4096218  Changed param name from G_DELETED_TASK_VER_IDS_FROM_OP to  G_DELETED_TASK_IDS_FROM_OP
G_DELETED_TASK_IDS_FROM_OP        PA_NUM_1000_NUM := PA_NUM_1000_NUM();

--DHI ER , rtarway BUG 4413568
G_TASK_STR_UPDATE_MODE        VARCHAR2(30) := NULL;

/*--The following variables are defined to support load_tasks and fetch_tasks apis.
 TYPE pa_vc_1000_25 IS VARRAY(1000) OF VARCHAR2(25);
 TYPE pa_vc_1000_20 IS VARRAY(1000) OF VARCHAR2(20);
 TYPE pa_vc_1000_10 IS VARRAY(1000) OF VARCHAR2(10);
 TYPE pa_vc_1000_150 IS VARRAY(1000) OF VARCHAR2(150);
 TYPE pa_vc_1000_2000 IS VARRAY(1000) OF VARCHAR2(2000);
 TYPE pa_num_1000_num IS VARRAY(1000) OF NUMBER;
 TYPE pa_vc_1000_4000 IS VARRAY(1000) OF VARCHAR2(4000);
 TYPE number_table IS VARRAY(10) OF NUMBER;
 TYPE pa_date_1000_date IS VARRAY(1000) OF DATE;
*/

--Record and table type definitions
--Project record type that is used to pass data to an API
--Added new parameters to the project_in_rec_type

TYPE project_in_rec_type IS RECORD
(pm_project_reference       VARCHAR2(25)    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 pa_project_id          NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 pa_project_number      VARCHAR2(25)    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 project_name           VARCHAR2(30)    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 long_name          VARCHAR2(240)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 created_from_project_id    NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 carrying_out_organization_id   NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 public_sector_flag     VARCHAR2(1)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 project_status_code        VARCHAR2(30)    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 description            VARCHAR2(250)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 start_date         DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 completion_date        DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 distribution_rule      VARCHAR2(30)    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 customer_id            NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 project_relationship_code  VARCHAR2(30)    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 actual_start_date              DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 actual_finish_date             DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 early_start_date               DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 early_finish_date              DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 late_start_date                DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 late_finish_date               DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 scheduled_start_date           DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 scheduled_finish_date          DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 attribute_category     VARCHAR2(30)    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 attribute1         VARCHAR2(150)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 attribute2         VARCHAR2(150)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 attribute3         VARCHAR2(150)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 attribute4         VARCHAR2(150)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 attribute5         VARCHAR2(150)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 attribute6         VARCHAR2(150)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 attribute7         VARCHAR2(150)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 attribute8         VARCHAR2(150)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 attribute9         VARCHAR2(150)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 attribute10            VARCHAR2(150)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 output_tax_code VARCHAR2(30) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 retention_tax_code VARCHAR2(30) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 project_currency_code VARCHAR2(15) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 allow_cross_charge_flag VARCHAR2(1):= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 project_rate_date         DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 project_rate_type      VARCHAR2(30)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 cc_process_labor_flag VARCHAR2(1):= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 labor_tp_schedule_id       NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 labor_tp_fixed_date         DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 cc_process_nl_flag VARCHAR2(1):= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 nl_tp_schedule_id       NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 nl_tp_fixed_date         DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 cc_tax_task_id       NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 role_list_id       NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 work_type_id       NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 calendar_id        NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 location_id        NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 probability_member_id    NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 project_value    NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 expected_approval_date    DATE   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 cost_job_group_id    NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 bill_job_group_id    NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 team_template_id     NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 country_code         VARCHAR2(250) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 region               VARCHAR2(250) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 city                 VARCHAR2(250) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 emp_bill_rate_schedule_id    NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 job_bill_rate_schedule_id    NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ,
--Sakthi MCB
 invproc_currency_type        VARCHAR2(30) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 revproc_currency_code        VARCHAR2(15) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 project_bil_rate_date_code   VARCHAR2(30) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 project_bil_rate_type        VARCHAR2(30) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 project_bil_rate_date        DATE         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 project_bil_exchange_rate    NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 projfunc_currency_code       VARCHAR2(15) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 projfunc_bil_rate_date_code  VARCHAR2(30) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 projfunc_bil_rate_type       VARCHAR2(30) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 projfunc_bil_rate_date       DATE         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 projfunc_bil_exchange_rate   NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 funding_rate_date_code  VARCHAR2(30) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 funding_rate_type       VARCHAR2(30) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 funding_rate_date       DATE         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 funding_exchange_rate   NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 baseline_funding_flag        VARCHAR2(1)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 multi_currency_billing_flag  VARCHAR2(1)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 competence_match_wt          NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 availability_match_wt        NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 job_level_match_wt           NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 enable_automated_search      VARCHAR2(1)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 search_min_availability      NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 search_org_hier_id           NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 search_starting_org_id       NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 search_country_id            NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 min_cand_score_reqd_for_nom  NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 max_num_of_sys_nom_cand      NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 non_lab_std_bill_rt_sch_id   NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 search_country_code          VARCHAR2(2)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 inv_by_bill_trans_curr_flag  VARCHAR2(1)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 projfunc_cost_rate_type      VARCHAR2(30) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 projfunc_cost_rate_date      DATE         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
--Sakthi Structure
 assign_precedes_task           VARCHAR2(1)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 split_cost_from_workplan_flag  VARCHAR2(1)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 split_cost_from_bill_flag      VARCHAR2(1)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
--Sakthi Structure
--Advertisement
 adv_action_set_id              NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 start_adv_action_set_flag      VARCHAR2(1)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
--Advertisement
--Project Setup
 priority_code                  VARCHAR2(30) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
--Project Setup
--Retention
 retn_billing_inv_format_id     NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 retn_accounting_flag           VARCHAR2(1)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
--Retention
-- anlee opportunity changes
 opp_value_currency_code        VARCHAR2(15) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
-- anlee
-- patchset K changes
 revaluate_funding_flag         VARCHAR2(1)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 include_gains_losses_flag    VARCHAR2(1)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 security_level               NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 labor_disc_reason_code     VARCHAR2(30) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 non_labor_disc_reason_code     VARCHAR2(30) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 --sramesh Code starts for bug 2802984
 labor_schedule_fixed_date  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 labor_schedule_discount    NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 non_labor_bill_rate_org_id NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 non_labor_schedule_fixed_date  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 non_labor_schedule_discount    NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 rev_ind_rate_sch_id        NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 inv_ind_rate_sch_id        NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 rev_ind_sch_fixed_date     DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 inv_ind_sch_fixed_date     DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 labor_sch_type         VARCHAR2(1) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 non_labor_sch_type     VARCHAR2(1) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 --sramesh Code ends for bug 2802984
-- End of changes
--PA L changes -- bug 2872708
 asset_allocation_method       VARCHAR2(30)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 capital_event_processing      VARCHAR2(30)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 cint_rate_sch_id              NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 cint_eligible_flag            VARCHAR2(1)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 cint_stop_date                DATE         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
--end PA L changes -- bug 2872708
-- crm changes
Bill_To_Customer_id         NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
Ship_To_Customer_id         NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
-- crm changes
-- PA L Changes 3010538
process_mode                VARCHAR2(30) := 'ONLINE',
-- FP M changes begin (venkat)
 sys_program_flag              VARCHAR2(1)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 allow_multi_program_rollup    VARCHAR2(1)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR, -- Bug # 5072032.
 enable_top_task_customer_flag VARCHAR2(1)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 enable_top_task_inv_mth_flag    VARCHAR2(1)    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 projfunc_attr_for_ar_flag   VARCHAR2(1)    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
-- FP M changes end (venkat)
--These parameters are added for Bug 3911782
bill_to_address_id            NUMBER (15) := null,
ship_to_address_id            NUMBER (15) := NULL ,
--sunkalya:federal Bug#5511353
date_eff_funds_flag VARCHAR2(1)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
--sunkalya:federal Bug#5511353
ar_rec_notify_flag VARCHAR2(1)   := 'N', -- 7508661 : EnC
auto_release_pwp_inv VARCHAR2(1) := 'Y',  -- 7508661 : EnC
status_change_comment VARCHAR2(4000) := null -- Added for bug#9110781
);

--Project record type that is used to pass data coming out of an API
TYPE project_out_rec_type IS RECORD
(pa_project_id          NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 pa_project_number      VARCHAR2(25)    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 return_status          VARCHAR2(1) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
);

-- Customer Record type created for Tracking bug to all users -- AA
TYPE customer_in_rec_type IS RECORD
( customer_id            NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  project_relationship_code  VARCHAR2(30)    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  Bill_To_Customer_id         NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  Ship_To_Customer_id         NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  bill_to_address_id            NUMBER (15) := null,
  ship_to_address_id            NUMBER (15) := null,
  CONTACT_ID                NUMBER (15) := null,
  PROJECT_CONTACT_TYPE_CODE  VARCHAR (30) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  CUSTOMER_BILL_SPLIT        NUMBER   := NULL,
  ALLOW_INV_USER_RATE_TYPE_FLAG  VARCHAR2(1)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  INV_RATE_DATE        DATE       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  INV_RATE_TYPE        VARCHAR (256) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR, --bug 5554475
  INV_CURRENCY_CODE    VARCHAR (15) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  INV_EXCHANGE_RATE    NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  enable_top_task_cust_flag VARCHAR2(1)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  BILL_ANOTHER_PROJECT_FLAG     VARCHAR (1) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR, --Added later for tracking 4153629
  RECEIVER_TASK_ID      NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  --Added later for tracking 4153629
 );

TYPE customer_tbl_type IS TABLE OF customer_in_rec_type
    INDEX BY BINARY_INTEGER;
 /** changes end for tracking **/

TYPE project_role_rec_type IS RECORD
(person_id          NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 project_role_type      VARCHAR2(20)    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 -- Modified from the size from 20 to 80 for project_role_meaning for 8523543
 project_role_meaning      VARCHAR2(80)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR, -- Bug 6408593
 start_date         DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 end_date           DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
);
TYPE project_role_tbl_type IS TABLE OF project_role_rec_type
    INDEX BY BINARY_INTEGER;

TYPE class_category_rec_type IS RECORD
(class_category         VARCHAR2(30)    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 class_code             VARCHAR2(30)    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 new_class_code         VARCHAR2(30)    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR, --5348726 added for bug#5294891
 code_percentage        NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
);
TYPE class_category_tbl_type IS TABLE OF class_category_rec_type
    INDEX BY BINARY_INTEGER;

TYPE task_in_rec_type IS RECORD
(pm_task_reference           VARCHAR2(25)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 pa_task_id              NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 task_name               VARCHAR2(240)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR, -- Bug 6193314  Changed to 240 from 20
 long_task_name          VARCHAR2(240)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 pa_task_number          VARCHAR2(100)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR, -- Bug 6193314  Changed to 100 from 25
 task_description            VARCHAR2(2000)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,  -- Bug 9080164 : Changed from 250 to 2000
 task_start_date             DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 task_completion_date        DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 pm_parent_task_reference     VARCHAR2(25)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 pa_parent_task_id           NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 address_id              NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 carrying_out_organization_id   NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 service_type_code           VARCHAR2(30)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 task_manager_person_id      NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 billable_flag               VARCHAR2(1)    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 chargeable_flag             VARCHAR2(1)    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 ready_to_bill_flag          VARCHAR2(1)    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 ready_to_distribute_flag     VARCHAR2(1)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 limit_to_txn_controls_flag VARCHAR2(1) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 labor_bill_rate_org_id     NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 labor_std_bill_rate_schdl  VARCHAR2(20)    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 labor_schedule_fixed_date  DATE             := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 labor_schedule_discount         NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 non_labor_bill_rate_org_id  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 non_labor_std_bill_rate_schdl VARCHAR2(30) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 non_labor_schedule_fixed_date DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 non_labor_schedule_discount     NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 labor_cost_multiplier_name  VARCHAR2(20)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 cost_ind_rate_sch_id        NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 rev_ind_rate_sch_id         NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 inv_ind_rate_sch_id         NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 cost_ind_sch_fixed_date          DATE      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 rev_ind_sch_fixed_date      DATE       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 inv_ind_sch_fixed_date      DATE       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 labor_sch_type          VARCHAR2(1)    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 non_labor_sch_type           VARCHAR2(1)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 actual_start_date             DATE          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 actual_finish_date            DATE          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 early_start_date              DATE          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 early_finish_date             DATE          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 late_start_date               DATE          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 late_finish_date              DATE          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 scheduled_start_date          DATE          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 scheduled_finish_date         DATE          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 tasks_dff                    VARCHAR2(1)   := 'N', --bug 6153503
 attribute_category           VARCHAR2(30)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 attribute1               VARCHAR2(150) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 attribute2               VARCHAR2(150) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 attribute3               VARCHAR2(150) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 attribute4               VARCHAR2(150) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 attribute5               VARCHAR2(150) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 attribute6               VARCHAR2(150) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 attribute7               VARCHAR2(150) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 attribute8               VARCHAR2(150) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 attribute9               VARCHAR2(150) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 attribute10                  VARCHAR2(150) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 attribute11               VARCHAR2(150) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,--bug 6153503
 attribute12               VARCHAR2(150) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,--bug 6153503
 attribute13               VARCHAR2(150) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,--bug 6153503
 attribute14               VARCHAR2(150) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,--bug 6153503
 attribute15               VARCHAR2(150) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,--bug 6153503
 allow_cross_charge_flag       VARCHAR2(1)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 project_rate_date             DATE          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 project_rate_type             VARCHAR2(30)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 cc_process_labor_flag         VARCHAR2(1)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 labor_tp_schedule_id          NUMBER        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 labor_tp_fixed_date           DATE          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 cc_process_nl_flag            VARCHAR2(1)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 nl_tp_schedule_id             NUMBER        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 nl_tp_fixed_date              DATE          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
receive_project_invoice_flag   VARCHAR2(1)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 work_type_id                  NUMBER        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 emp_bill_rate_schedule_id     NUMBER        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ,
 job_bill_rate_schedule_id     NUMBER        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ,
--Sakthi MCB
 non_lab_std_bill_rt_sch_id    NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ,
 taskfunc_cost_rate_type       VARCHAR2(30)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 taskfunc_cost_rate_date       DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
--Sakthi MCB
 display_sequence            NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 wbs_level                     NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
--Project structure
 OBLIGATION_START_DATE         DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 OBLIGATION_FINISH_DATE        DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 ESTIMATED_START_DATE          DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 ESTIMATED_FINISH_DATE         DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 BASELINE_START_DATE           DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 BASELINE_FINISH_DATE          DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 CLOSED_DATE                   DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 WQ_UOM_CODE                   VARCHAR2(30) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 WQ_ITEM_CODE                  VARCHAR2(30) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 STATUS_CODE                   VARCHAR2(30) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 WF_STATUS_CODE                VARCHAR2(30) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 PM_SOURCE_CODE                VARCHAR2(30) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 PRIORITY_CODE                 VARCHAR2(30) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 MILESTONE_FLAG                VARCHAR2(1) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 CRITICAL_FLAG                 VARCHAR2(1) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 INC_PROJ_PROGRESS_FLAG        VARCHAR2(1) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ,
 LINK_TASK_FLAG                VARCHAR2(1) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 CALENDAR_ID                   NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 PLANNED_EFFORT                NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 DURATION                      NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 PLANNED_WORK_QUANTITY         NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ,
 TASK_TYPE                     NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
--Project structure
 labor_disc_reason_code        VARCHAR2(30) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 non_labor_disc_reason_code    VARCHAR2(30) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
--PA L changes -- bug 2872708
 retirement_cost_flag          VARCHAR2(1)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 cint_eligible_flag            VARCHAR2(1)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 cint_stop_date                DATE         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
--end PA L changes -- bug 2872708
-- FP-M Bug # 3301192
 pred_string                   VARCHAR2(4000) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 pred_delimiter           VARCHAR2(1)    DEFAULT ',',
-- FP M changes begin (venkat)
 base_percent_comp_deriv_code    VARCHAR2(30) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 sch_tool_tsk_type_code  VARCHAR2(30) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 constraint_type_code        VARCHAR2(30) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 constraint_date             DATE       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 free_slack              NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 total_slack                 NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 effort_driven_flag          VARCHAR2(1)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 level_assignments_flag      VARCHAR2(1)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 invoice_method          VARCHAR2(30) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 customer_id                 NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 gen_etc_source_code         VARCHAR2(30) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
-- FP M changes end (venkat)
-- FP M changes Start (Mapping )
 financial_task_flag         VARCHAR2(1)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 mapped_task_id                NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 mapped_task_reference         VARCHAR2(150)       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,  --SMUKKA
 -- FP M changes end (Mapping )
 deliverable                   VARCHAR2(4000) :=  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,  --SMUKKA
 deliverable_id                NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,  -- 3661788 Added In paramter
-- (Begin Venkat) Bug # 3450684 -----------------------------------------------
 ext_act_duration       NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 ext_remain_duration    NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 ext_sch_duration       NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- (End Venkat) Bug # 3450684 ------------------------------------------------

-- Progress Management Changes. Bug # 3420093.
  ,etc_effort                 NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,percent_complete           NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- Progress Management Changes. Bug # 3420093.

);

TYPE task_in_tbl_type IS TABLE OF task_in_rec_type
    INDEX BY BINARY_INTEGER;

TYPE task_out_rec_type IS RECORD
(pa_task_id         NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 pm_task_reference      VARCHAR2(25)    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 return_status          VARCHAR2(1) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 --project structure
 task_version_id                NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 --project structure
);

TYPE task_out_tbl_type IS TABLE OF task_out_rec_type
    INDEX BY BINARY_INTEGER;

-- Project Connect 4.0
TYPE struc_out_rec_type IS RECORD
(structure_version_id           NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 structure_type                 VARCHAR2(25)    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 return_status                  VARCHAR2(1)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
);
TYPE struc_out_tbl_type IS TABLE OF struc_out_rec_type
        INDEX BY BINARY_INTEGER;
G_struc_out_tbl         struc_out_tbl_type;
-- Project Connect 4.0

--project structures
--Adding a record type for structure data
TYPE structure_in_rec_type IS RECORD
( pa_project_id              NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,structure_type             VARCHAR2(25)      := 'FINANCIAL'
 ,structure_version_name     VARCHAR2(240)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,structure_version_id       NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,DESCRIPTION                VARCHAR2(250)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 /*,VERSION_NUMBER             NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,NAME                       VARCHAR2(240)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,CURRENT_FLAG               VARCHAR2(1)       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,ORIGINAL_FLAG              VARCHAR2(1)       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,LATEST_EFF_PUBLISHED_FLAG  VARCHAR2(1)       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,EFFECTIVE_DATE             DATE              := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,PUBLISHED_DATE             DATE              := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,PUBLISHED_BY_PERSON_ID     NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,CURRENT_BASELINE_DATE      DATE              := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,CURRENT_BASELINE_PERSON_ID   NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,ORIGINAL_BASELINE_DATE       DATE           := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,ORIGINAL_BASELINE_PERSON_ID  NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,LOCK_STATUS_CODE             VARCHAR2(30)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,LOCKED_BY_PERSON_ID          NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,LOCKED_DATE                  DATE           := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,STATUS_CODE                  VARCHAR2(30)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,WF_STATUS_CODE               VARCHAR2(30)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,PM_SOURCE_CODE               VARCHAR2(30)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,PM_SOURCE_REFERENCE          VARCHAR2(25)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,CHANGE_REASON_CODE           VARCHAR2(30)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
*/
);

TYPE structure_out_rec_type IS RECORD
(pa_structure_id             NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 pa_structure_version_id     NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 return_status               VARCHAR2(1)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
);

-- <EA Pl/SQL table data structure>

TYPE PA_EXT_ATTR_ROW_TYPE IS RECORD (
   PROJ_ELEMENT_ID        NUMBER,
   PROJ_ELEMENT_REFERENCE VARCHAR2(30),
   ROW_IDENTIFIER         NUMBER,
   ATTR_GROUP_INT_NAME    VARCHAR2(30),
   ATTR_GROUP_ID          NUMBER,
   ATTR_INT_NAME          VARCHAR2(30),
   ATTR_VALUE_STR         VARCHAR2(150),
   ATTR_VALUE_NUM         NUMBER,
   ATTR_VALUE_DATE        DATE,
   ATTR_DISP_VALUE        VARCHAR2(150),
   ATTR_UNIT_OF_MEASURE   VARCHAR2(30),
   USER_ROW_IDENTIFIER    VARCHAR2(150),
   TRANSACTION_TYPE       VARCHAR2(30)
);

TYPE PA_EXT_ATTR_TABLE_TYPE IS TABLE OF PA_EXT_ATTR_ROW_TYPE
   INDEX BY BINARY_INTEGER;
-- </EA Pl/SQL table data structure>

-- 3435905 FP M Changes for deliverables : Start

TYPE deliverable_in_rec_type IS RECORD
(deliverable_short_name   VARCHAR2(100) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,deliverable_name         VARCHAR2(240) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,description              VARCHAR2(2000):= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,deliverable_owner_id     NUMBER        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- for bug# 3729250
--,carrying_out_org_id      NUMBER        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,status_code              VARCHAR2(30)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,deliverable_type_id      NUMBER        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,progress_weight          NUMBER        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,due_date                 DATE          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
,completion_date          DATE          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
,pm_source_code           VARCHAR2(30)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,pm_deliverable_reference VARCHAR2(25)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,deliverable_id           NUMBER        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,task_id                  NUMBER        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,task_source_reference    VARCHAR2(25)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- OKE Item parameters Starts
,item_id                  NUMBER        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,inventory_org_id         NUMBER        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,quantity                 NUMBER        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,uom_code                 VARCHAR2(30)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- for bug# 3729250
--,item_description         VARCHAR2(2000):= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,unit_price               NUMBER        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,unit_number              VARCHAR2(30)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,currency_code            VARCHAR2(15)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- OKE Item  parameters End
);

TYPE deliverable_out_rec_type IS RECORD
( deliverable_id  NUMBER        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,return_status  VARCHAR2(1)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
);

TYPE action_in_rec_type IS RECORD
( action_name                  VARCHAR2(100)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,action_owner_id              NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,action_id                    NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,function_code                VARCHAR2(30)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,due_date                     DATE           := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,completion_date              DATE           := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,description                  VARCHAR2(2000) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,pm_source_code               VARCHAR2(30)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,pm_action_reference          VARCHAR2(25)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 -- for bug# 3729250
-- ,carrying_out_org_id          NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,pm_deliverable_reference     VARCHAR2(25)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,deliverable_id               NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- OKE procurement parameters
 ,financial_task_id            NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 -- added for bug# 3729250
 ,financial_task_reference     VARCHAR2(25)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,destination_type_code        VARCHAR2(30)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,receiving_org_id             NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,receiving_location_id        NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,po_need_by_date              DATE           := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,vendor_id                    NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,vendor_site_code             VARCHAR2(15)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- ,project_currency             VARCHAR2(15)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,quantity                     NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,uom_code                     VARCHAR2(30)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,unit_price                   NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,exchange_rate_type           VARCHAR2(30)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,exchange_rate_date           DATE           := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,exchange_rate                NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,expenditure_type             VARCHAR2(30)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,expenditure_org_id           NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,expenditure_item_date        DATE           := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,requisition_line_type_id     NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,category_id                  NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,ready_to_procure_flag        VARCHAR2(1)    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,initiate_procure_flag        VARCHAR2(1)    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- OKE procurement parameters
-- OKE shipping parameters
 ,ship_from_organization_id    NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,ship_from_location_id        NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,ship_to_organization_id      NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,ship_to_location_id          NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,demand_schedule              VARCHAR2(10)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,expected_shipment_date       DATE           := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,promised_shipment_date       DATE           := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,volume                       NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,volume_uom                   VARCHAR2(10)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,weight                       NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,weight_uom                   VARCHAR2(10)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,ready_to_ship_flag           VARCHAR2(1)    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,initiate_planning_flag       VARCHAR2(1)    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,initiate_shipping_flag       VARCHAR2(1)    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- OKE shipping parameters
-- Billing parameters
 ,event_type                   VARCHAR2(30)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,currency                     VARCHAR2(30)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,invoice_amount               NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,revenue_amount               NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,event_date                   DATE           := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,event_number                 NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,organization_id              NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,bill_hold_flag               VARCHAR2(1)    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,project_functional_rate_type VARCHAR2(30)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,project_functional_rate_date DATE           := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,project_functional_rate      NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,project_rate_type            VARCHAR2(30)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,project_rate_date            DATE           := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,project_rate                 NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,funding_rate_type            VARCHAR2(30)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,funding_rate_date            DATE           := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,funding_rate                 NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,pm_event_reference           VARCHAR2(25)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR -- 3651489 added parameter
-- Billing parameters
);


TYPE action_out_rec_type IS RECORD
(action_id      NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,return_status  VARCHAR2(1) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
);

-- Bug # 5072032.

TYPE program_links_rec_type IS RECORD
(object_relationship_id		NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, parent_project_id		NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, pm_parent_project_reference	VARCHAR2(25)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, task_id			NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, pm_task_reference		VARCHAR2(25)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, task_version_id		NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, structure_type                VARCHAR2(25)    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, sub_project_id		NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, pm_sub_project_reference	VARCHAR2(25)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, comments			VARCHAR2(240)	:= NULL);

TYPE program_links_tbl_type IS TABLE OF program_links_rec_type INDEX BY BINARY_INTEGER;

-- End of Bug # 5072032.


TYPE action_out_tbl_type         IS TABLE OF action_out_rec_type  INDEX BY BINARY_INTEGER ;
TYPE deliverable_in_tbl_type     IS TABLE OF deliverable_in_rec_type INDEX BY BINARY_INTEGER ;
TYPE deliverable_out_tbl_type    IS TABLE OF deliverable_out_rec_type  INDEX BY BINARY_INTEGER ;
TYPE action_in_tbl_type          IS TABLE OF action_in_rec_type INDEX BY BINARY_INTEGER ;

-- 3435905 FP M Changes for deliverables : End

--project structures

--Globals to be used by the LOAD/EXECUTE/FETCH process
--IN types
G_project_in_null_rec       project_in_rec_type;
G_project_in_rec        project_in_rec_type;

  --project structure
G_structure_in_rec      structure_in_rec_type;
  --project structure

G_key_members_in_tbl        project_role_tbl_type;
G_class_categories_in_tbl   class_category_tbl_type;
G_tasks_in_tbl          task_in_tbl_type;
-- anlee org roles changes
G_org_roles_in_tbl      project_role_tbl_type;
-- <EA table to store ext attr data/>
G_ext_attr_in_tbl            PA_EXT_ATTR_TABLE_TYPE;

--Counters
G_key_members_tbl_count     NUMBER:=0;
G_class_categories_tbl_count    NUMBER:=0;
G_tasks_tbl_count       NUMBER:=0;
-- anlee org roles changes
G_org_roles_tbl_count       NUMBER:=0;
-- <EA counter for ext attr data table/>
G_ext_attr_tbl_count         NUMBER := 0;

--OUT types
G_project_out_null_rec      project_out_rec_type;
G_project_out_rec       project_out_rec_type;
G_tasks_out_tbl         task_out_tbl_type;

  --project structures
G_structure_out_rec             structure_out_rec_type;
  --project structures

--3435905 FP : M Global Tables Deliverables : Starts
G_deliverables_in_tbl          deliverable_in_tbl_type     ;
G_deliverables_out_tbl         deliverable_out_tbl_type    ;
G_deliverable_actions_in_tbl   action_in_tbl_type  ;
G_deliverable_actions_out_tbl  action_out_tbl_type ;
G_deliverables_in_tbl_count    NUMBER := 0;
G_dlvr_actions_in_tbl_count    NUMBER := 0;
--3435905 FP : M Global Tables Deliverables : Ends
G_customers_in_tbl          customer_tbl_type; -- Added for tracking bug

/*#
 * This API creates a project in the Oracle Projects using a template or existing project.
 * @param p_api_version_number API standard version number
 * @param p_commit API standard (default = F): indicates if transaction will be committed
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_workflow_started Flag indicating whether a workflow has been started
 * @rep:paraminfo {@rep:required}
 * @param p_pm_product_code Identifier of the external system from which the project was imported
 * @rep:paraminfo {@rep:precision 25}
 * @param p_op_validate_flag Indicates whether the system performs scheduling validations. Default is Y.
 * @rep:paraminfo {@rep:precision 1}
 * @param p_project_in Input project details
 * @rep:paraminfo {@rep:required}
 * @param p_project_out Output project details
 * @rep:paraminfo {@rep:required}
 * @param p_customers_in Input customer details
 * @param p_key_members The identification code for the role that the members have on the project
 * @rep:paraminfo {@rep:required}
 * @param p_class_categories Identifier of the categories by which the project is classified
 * @rep:paraminfo {@rep:required}
 * @param p_tasks_in  Input task details of the project
 * @rep:paraminfo {@rep:required}
 * @param p_tasks_out Output task details of the project
 * @rep:paraminfo {@rep:required}
 * @param p_org_roles Identifier of the organization roles for project
 * @param p_structure_in Identifier of structure data
 * @param p_ext_attr_tbl_in Identifier of external attributes
 * @param p_deliverables_in Input deliverable details
 * @param p_deliverable_actions_in Input deliverable actions details
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Project
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:category BUSINESS_ENTITY PA_PROJ_DELIVERABLE
 * @rep:compatibility S
*/
PROCEDURE create_project
( p_api_version_number      IN  NUMBER      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit                  IN  VARCHAR2    := FND_API.G_FALSE
 ,p_init_msg_list           IN  VARCHAR2    := FND_API.G_FALSE
 ,p_msg_count              OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_msg_data               OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_return_status          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_workflow_started       OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_pm_product_code         IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_op_validate_flag        IN VARCHAR2     := 'Y' --added by rtarway 4218977
 ,p_project_in              IN  project_in_rec_type
 ,p_project_out            OUT  NOCOPY  project_out_rec_type    /*added the nocopy check for the bug 2674619*/
 /* Added for tracking bug - add customers */
 ,p_customers_in     IN  pa_project_pub.customer_tbl_type := G_customers_in_tbl
/*added default value 3683732*/
 ,p_key_members             IN  project_role_tbl_type := G_key_members_in_tbl
 ,p_class_categories        IN  class_category_tbl_type := G_class_categories_in_tbl
 ,p_tasks_in                IN  task_in_tbl_type
 ,p_tasks_out              OUT  NOCOPY  task_out_tbl_type /*added the nocopy check for the bug 2674619*/
 ,p_org_roles               IN  project_role_tbl_type := G_org_roles_in_tbl
--project structures
 ,p_structure_in            IN  structure_in_rec_type := G_structure_in_rec
 ,p_ext_attr_tbl_in         IN  PA_EXT_ATTR_TABLE_TYPE := G_ext_attr_in_tbl -- <EA added parameter for Ext Attr/>

-- ,p_structure_out               OUT     structure_out_rec_type
--project structures
--3435905 FP M : deliverables
 ,p_deliverables_in         IN  deliverable_in_tbl_type := G_deliverables_in_tbl -- 3435905 passing default
-- ,p_deliverables_out          OUT NOCOPY  deliverable_out_tbl_type    -- 3435905 removed
 ,p_deliverable_actions_in  IN  action_in_tbl_type := G_deliverable_actions_in_tbl -- 3435905 passing default
-- ,p_deliverable_actions_out   OUT NOCOPY  action_out_tbl_type -- 3435905 removed
--3435905 FP M : deliverables
);

/*#
 * This API is used to add new subtasks to a task of a project in Oracle Projects.
 * @param p_api_version_number API standard version number
 * @param p_commit API standard (default = F): indicates if transaction will be committed
 * @rep:paraminfo {@rep:precision 1}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_pm_product_code Identifier of the external system from which the project was imported
 * @rep:paraminfo {@rep:precision 25}
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system
 * @param p_pa_project_id The reference code that uniquely identifies the project in the Oracle Projects
 * @param p_pm_task_reference  The reference code that uniquely identifies project's task in the external system
 * @param p_pa_task_number  The number that identifies the task in Oracle Projects
 * @param p_ref_task_id The reference code that uniquely identifies the task in a project in Oracle Projects
 * @param p_task_name The name that uniquely identifies the task within a project
 * @param p_long_task_name  Long name of the task
 * @param p_task_description Description of the task
 * @param p_task_start_date The start date of the task
 * @param p_task_completion_date The completion date of the task
 * @param p_pm_parent_task_reference The unique reference code that identifies the task's parent task
 * @param p_pa_parent_task_id The identifier of task's parent task in Oracle Projects
 * @param p_address_id The address of one of the customers that is logically linked to the task
 * @param p_carrying_out_organization_id The identifier of the organization that is responsible for the project work
 * @param p_service_type_code The type of work performed on the task
 * @param p_task_manager_person_id The identifier of the employee who manages the task.
 * @param p_billable_flag Flag indicating whether items charged to the task can accrue revenue
 * @rep:paraminfo {@rep:precision 1}
 * @param p_chargeable_flag Flag indicating whether expenditure items can be charged to the task. Only lowest level tasks can be chargeable
 * @rep:paraminfo {@rep:precision 1}
 * @param p_ready_to_bill_flag Flag indicating whether the task is authorized to be invoiced
 * @rep:paraminfo {@rep:precision 1}
 * @param p_ready_to_distribute_flag Flag indicating whether the task is authorized for revenue accrual
 * @rep:paraminfo {@rep:precision 1}
 * @param p_limit_to_txn_controls_flag Flag indicating whether users can only charge expenditures to the tasks that are listed in task transaction controls
 * @rep:paraminfo {@rep:precision 1}
 * @param p_labor_bill_rate_org_id  The identifier of the organization that owns the labor standard bill rate schedule
 * @param p_labor_std_bill_rate_schdl The labor standard bill rate schedule that is used to calculate revenue for labor expenditure items charged to the task
 * @param p_labor_schedule_fixed_date The date used to determine the effective bill rates of the task standard labor bill rate schedule. If no
 * fixed date is entered, the expenditure item date is used to determine the effective bill rate for the item.
 * @param p_labor_schedule_discount The discount percent for the task standard labor bill rate schedule
 * @param p_nl_bill_rate_org_id The identifier of the organization that owns the non-labor standard bill rate schedule
 * @param p_nl_std_bill_rate_schdl The non-labor standard bill rate schedule that is used to calculate revenue for non-labor expenditure items charged to the task
 * @param p_nl_schedule_fixed_date The fixed date used to determine the effective bill rates of the standard non-labor bill rate schedule
 * @param p_nl_schedule_discount The discount percent from the task standard non-labor bill rate schedule
 * @param p_labor_cost_multiplier_name The labor cost multiplier defined for the task of a premium project
 * @param p_cost_ind_rate_sch_id The identifier of the default costing burden schedule
 * @param p_rev_ind_rate_sch_id The identifier of the default revenue burden schedule
 * @param p_inv_ind_rate_sch_id The identifier of the default invoice burden schedule
 * @param p_cost_ind_sch_fixed_date The schedule fixed date of the firm costing burden schedule
 * @param p_rev_ind_sch_fixed_date The schedule fixed date of the firm revenue burden schedule
 * @param p_inv_ind_sch_fixed_date The schedule fixed date of the firm invoice burden schedule
 * @param p_labor_sch_type The schedule type of labor expenditure items
 * @param p_nl_sch_type The schedule type of non-labor expenditure items
 * @param p_actual_start_date The actual start date of the project
 * @param p_actual_finish_date The actual end date of the project
 * @param p_early_start_date The early start date of the project. Applicable only for a project that originated in an external system.
 * @param p_early_finish_date The early finish date of the project
 * @param p_late_start_date The late start date of the project. Applicable only for a project that originated in an external system.
 * @param p_late_finish_date The late finish date of the project. Applicable only for a project that originated in an external system.
 * @param p_scheduled_start_date The scheduled start date of the project
 * @param p_scheduled_finish_date The scheduled finish date of the project
 * @param p_attribute_category Descriptive flexfield category
 * @param p_attribute1 Identifies Descriptive flexfield segment
 * @param p_attribute2 Identifies Descriptive flexfield segment
 * @param p_attribute3 Identifies Descriptive flexfield segment
 * @param p_attribute4 Identifies Descriptive flexfield segment
 * @param p_attribute5 Identifies Descriptive flexfield segment
 * @param p_attribute6 Identifies Descriptive flexfield segment
 * @param p_attribute7 Identifies Descriptive flexfield segment
 * @param p_attribute8 Identifies Descriptive flexfield segment
 * @param p_attribute9 Identifies Descriptive flexfield segment
 * @param p_attribute10 Identifies Descriptive flexfield segment
 * @param p_allow_cross_charge_flag Flat indicating whether cross charges are allowed
 * @param p_project_rate_date Task-level default value for project rate date
 * @param p_project_rate_type Task-level default value for project rate type
 * @param p_cc_process_labor_flag Flag indicating whether cross charge processing is to be performed for labor
 * transactions charged to the project. The default value for the project template is N. The default value for a
 * project is the value on the project template. The default value for a task is the value on the project.
 * @rep:paraminfo {@rep:precision 1}
 * @param p_labor_tp_schedule_id Identifier of the transfer price schedule to use for cross charged labor transactions.
 * The default value for a project is the value on the project template. The default value for a task is the value on the project.
 * If cc_process_labor_flag is set to Y, this field is required.
 * @param p_labor_tp_fixed_date Fixed date to find the effective rate of the bill rate or burden schedule when determining the
 * transfer price for labor transactions. The default value for a project is the value on the project template.
 * The default value for a task is the value on the project.
 * @param p_cc_process_nl_flag Flag indicating cross charge processing is to be performed for non-labor transactions charged to the project.
 * The default value for the project template is N. The default value for a project is the value on the project template.
 * The default value for a task is the value on the project.
 * @rep:paraminfo {@rep:precision 1}
 * @param p_nl_tp_schedule_id Identifier of the transfer price schedule to use for cross charged non-labor transactions.
 * The default value for a project is the value on the project template. The default value for a task is the value on the project.
 * If cc_process_nl_flag is set to Y, this field is required
 * @param p_nl_tp_fixed_date Fixed date to find the effective rate of the bill rate or burden schedule when determining the transfer
 * price for non-labor transactions.The default value for a project is the value on the project template. The default value for a task
 * is the value on the project.
 * @param p_receive_project_invoice_flag Flag indicating whether the task can receive charges from internal supplies using interproject billing
 * @rep:paraminfo {@rep:precision 1}
 * @param p_work_type_id Identifier of the work type
 * @param p_emp_bill_rate_schedule_id Identifier of the employee bill rate schedule
 * @param p_job_bill_rate_schedule_id Identifier of the job bill rate schedule
 * @param p_non_lab_std_bill_rt_sch_id Identifier of the non-labor standard bill rate schedule
 * @param p_taskfunc_cost_rate_type Task-level default value for project functional cost rate type
 * @param p_taskfunc_cost_rate_date Task-level default value for project functional cost rate date
 * @param p_structure_type  Identifier of the project structure type
 * @param p_structure_version_id Identifier of the structure version
 * @param P_OBLIGATION_START_DATE The obligation start date of the workplan version
 * @param P_OBLIGATION_FINISH_DATE The obligation finish date of the workplan version
 * @param P_ESTIMATED_START_DATE The estimated start date of the workplan version
 * @param P_ESTIMATED_FINISH_DATE The estimated finish date of the workplan version
 * @param P_BASELINE_START_DATE The baseline start date for the task or the workplan
 * @param P_BASELINE_FINISH_DATE The baseline finish date for the task or the workplan
 * @param P_CLOSED_DATE The date that the element status was set to Closed. This is a task-specific attribute.
 * @param P_WQ_UOM_CODE The unit of measure used for work quantity for a task
 * @param P_WQ_ITEM_CODE The work item for work quantity for a task
 * @param P_STATUS_CODE The status of the project element
 * @param P_WF_STATUS_CODE  The status of workflow associated with the element
 * @param P_PM_SOURCE_CODE Identifier of the the source code system
 * @param P_PRIORITY_CODE The priority of the task. This is a task-specific attribute.
 * @param P_MILESTONE_FLAG  Flag indicating whether the task version is a milestone. This is a task-specific attribute.
 * @param P_CRITICAL_FLAG Flag that indicates if the task version is part of the critical path.
 * @param P_INC_PROJ_PROGRESS_FLAG Project progress flag
 * @param P_LINK_TASK_FLAG  Flag indicating that a task is used for linking purposes and is not displayed in the user interface
 * @param P_CALENDAR_ID The identifier of the work calendar used to schedule the task. This is a task-specific attribute.
 * @param P_PLANNED_EFFORT The planned effort for the task
 * @param P_DURATION The duration between scheduled start date and scheduled end date using work calendar.
 * @param P_PLANNED_WORK_QUANTITY The planned work quantity for the task
 * @param P_TASK_TYPE The task type
 * @param p_labor_disc_reason_code Labor discount reason code
 * @param p_non_labor_disc_reason_code Non-labor discount reason code
 * @param p_retirement_cost_flag Flag indicating whether the task is identified for retirement cost collection
 * @rep:paraminfo  {@rep:precision 1}
 * @param p_cint_eligible_flag Flag indicating whether the project is eligible for capitalized interest
 * @rep:paraminfo  {@rep:precision 1}
 * @param p_cint_stop_date  Stop date for capital interest calculation
 * @param p_pa_project_id_out The unique identifier of the project in Oracle Projects
 * @rep:paraminfo  {@rep:required}
 * @param p_pa_project_number_out A project code that uniquely identifies the project
 * @rep:paraminfo  {@rep:required}
 * @param p_task_id  Unique identifier of the the task
 * @rep:paraminfo  {@rep:required}
 * @param p_process_mode Processing mode. Indicates whether task processing should be done online or via consurrent request
 * @rep:paraminfo  {@rep:required}
 * @param p_pred_string The string containing the predecessor information
 * @rep:paraminfo  {@rep:precision 400} {@rep:required}
 * @param p_pred_delimiter Delimiter that separates predecessors in the predecessor string
 * @rep:paraminfo  {@rep:precision 1} {@rep:required}
 * @param p_base_percent_comp_deriv_code Base percent complete derivation code for the task
 * @rep:paraminfo  {@rep:precision 30} {@rep:required}
 * @param p_sch_tool_tsk_type_code Default scheduling tool task type for the task version
 * @rep:paraminfo  {@rep:precision 30} {@rep:required}
 * @param p_constraint_type_code Constraint type for the task version
 * @rep:paraminfo  {@rep:precision 30} {@rep:required}
 * @param p_constraint_date Constraint date for the task version
 * @rep:paraminfo  {@rep:required}
 * @param p_free_slack Free slack for the task version
 * @rep:paraminfo  {@rep:required}
 * @param p_total_slack Total slack for the task version
 * @rep:paraminfo  {@rep:required}
 * @param p_effort_driven_flag The flag that indicates whether the task is effort driven
 * @rep:paraminfo  {@rep:precision 1} {@rep:required}
 * @param p_level_assignments_flag Flag that indicates whether the assignments on this task should be leveled
 * @rep:paraminfo  {@rep:precision 1} {@rep:required}
 * @param p_invoice_method The invoice method for the task. Valid only for top tasks with Invoice Method enabled.
 * @rep:paraminfo  {@rep:precision 30} {@rep:required}
 * @param p_customer_id The customer for the task. Valid only for top tasks with Customer enabled
 * @rep:paraminfo  {@rep:required}
 * @param p_gen_etc_source_code Estimate to complete source
 * @rep:paraminfo  {@rep:precision 30} {@rep:required}
 * @param p_financial_task_flag Flag that indicates whether the task is a financial task.
 * This flag is valid only for partially shared structures. Tasks that are above this level are used for financial management.
 * @rep:paraminfo  {@rep:precision 1} {@rep:required}
 * @param p_mapped_task_id Mapped task ID.This parameter is applicable only in case of split-mapped structure sharing between workplan
 * and financial structures.
 * @rep:paraminfo  {@rep:required}
 * @param p_mapped_task_reference Mapped task reference
 * @rep:paraminfo  {@rep:required}
 * @param p_deliverable Deliverable reference to be associated with the task.
 * @rep:paraminfo  {@rep:precision 4000}
 * @param p_deliverable_id Deliverable ID to be associated with the task
 * @param p_ext_act_duration From the external application, the actual duration
 * @rep:paraminfo  {@rep:required}
 * @param p_ext_remain_duration From the external application, the remaining duration
 * @rep:paraminfo  {@rep:required}
 * @param p_ext_sch_duration From the external application, the scheduled duration
 * @rep:paraminfo  {@rep:required}
 * @param p_op_validate_flag Indicates whether the system performs scheduling validations. Default is Y.
 * @rep:paraminfo  {@rep:precision 1}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Task
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:compatibility S
*/
PROCEDURE add_task
( p_api_version_number      IN  NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit              IN  VARCHAR2    := FND_API.G_FALSE
 ,p_init_msg_list           IN  VARCHAR2    := FND_API.G_FALSE
 ,p_msg_count               OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_msg_data                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_return_status           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_pm_product_code         IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pm_project_reference        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id           IN  NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_task_reference       IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_task_number          IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--Project Structures
 ,p_ref_task_id               IN   NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--Project Structures
 ,p_task_name               IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_long_task_name          IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_task_description        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_task_start_date         IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_task_completion_date        IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_pm_parent_task_reference    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_parent_task_id       IN  NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_address_id              IN  NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_carrying_out_organization_id    IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_service_type_code           IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_task_manager_person_id      IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_billable_flag                IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_chargeable_flag              IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_ready_to_bill_flag          IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_ready_to_distribute_flag        IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_limit_to_txn_controls_flag  IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_labor_bill_rate_org_id      IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_labor_std_bill_rate_schdl       IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_labor_schedule_fixed_date       IN DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_labor_schedule_discount     IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_nl_bill_rate_org_id         IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_nl_std_bill_rate_schdl      IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_nl_schedule_fixed_date      IN DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_nl_schedule_discount            IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_labor_cost_multiplier_name  IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_cost_ind_rate_sch_id             IN NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_rev_ind_rate_sch_id         IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_inv_ind_rate_sch_id         IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_cost_ind_sch_fixed_date     IN DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_rev_ind_sch_fixed_date      IN DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_inv_ind_sch_fixed_date      IN DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_labor_sch_type               IN VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_nl_sch_type             IN VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_actual_start_date              IN DATE      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_actual_finish_date             IN DATE      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_early_start_date               IN DATE      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_early_finish_date              IN DATE      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_late_start_date                IN DATE      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_late_finish_date               IN DATE      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_scheduled_start_date           IN DATE      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_scheduled_finish_date          IN DATE      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_tasks_dff                    IN VARCHAR2    := 'N'--bug 6153503
 ,p_attribute_category          IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute1                   IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute2                   IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute3                   IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute4                   IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute5                   IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute6                   IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute7                   IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute8                   IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute9                   IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute10             IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute11                  IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR--bug 6153503
 ,p_attribute12                  IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR--bug 6153503
 ,p_attribute13                  IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR--bug 6153503
 ,p_attribute14                  IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR--bug 6153503
 ,p_attribute15                  IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR--bug 6153503
 ,p_allow_cross_charge_flag        IN VARCHAR2:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_rate_date              IN DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_project_rate_type              IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_cc_process_labor_flag          IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_labor_tp_schedule_id           IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_labor_tp_fixed_date            IN DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_cc_process_nl_flag             IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_nl_tp_schedule_id              IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_nl_tp_fixed_date               IN DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_receive_project_invoice_flag   IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_work_type_id                   IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_emp_bill_rate_schedule_id      IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_job_bill_rate_schedule_id      IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--Sakthi MCB
 ,p_non_lab_std_bill_rt_sch_id     IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_taskfunc_cost_rate_type        IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_taskfunc_cost_rate_date        IN DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--Sakthi MCB
--Project Structures
 ,p_structure_type                 IN VARCHAR2 := 'FINANCIAL'
 ,p_structure_version_id           IN NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,P_OBLIGATION_START_DATE          IN DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,P_OBLIGATION_FINISH_DATE         IN DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,P_ESTIMATED_START_DATE           IN DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,P_ESTIMATED_FINISH_DATE          IN DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,P_BASELINE_START_DATE            IN DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,P_BASELINE_FINISH_DATE           IN DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,P_CLOSED_DATE                    IN DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,P_WQ_UOM_CODE                    IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_WQ_ITEM_CODE                   IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_STATUS_CODE                    IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_WF_STATUS_CODE                 IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_PM_SOURCE_CODE                 IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_PRIORITY_CODE                  IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_MILESTONE_FLAG                 IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_CRITICAL_FLAG                  IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_INC_PROJ_PROGRESS_FLAG         IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_LINK_TASK_FLAG                 IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_CALENDAR_ID                    IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,P_PLANNED_EFFORT                 IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,P_DURATION                       IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,P_PLANNED_WORK_QUANTITY          IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,P_TASK_TYPE                      IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--Project Structures
 ,p_labor_disc_reason_code       IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_non_labor_disc_reason_code   IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--PA L changes -- bug 2872708   --Add task
 ,p_retirement_cost_flag          VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_cint_eligible_flag            VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_cint_stop_date                DATE         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--end PA L changes -- bug 2872708
 ,p_pa_project_id_out           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_pa_project_number_out       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_task_id                  OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 -- PA L Changes 3010538
 ,p_process_mode                   IN VARCHAR2 := 'ONLINE'
-- FP-M Bug # 3301192
 ,p_pred_string                    IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- ,p_pred_delimiter                 IN VARCHAR2    DEFAULT ','
  ,p_pred_delimiter                IN VARCHAR2   :=  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- FP M changes begin (venkat)
  ,p_base_percent_comp_deriv_code   IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_sch_tool_tsk_type_code      IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_constraint_type_code       IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_constraint_date            IN DATE   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,p_free_slack             IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_total_slack                 IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_effort_driven_flag         IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_level_assignments_flag     IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_invoice_method              IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_customer_id                 IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_gen_etc_source_code             IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- FP M changes end (venkat)
-- FP M changes start (Mapping )
  ,p_financial_task_flag        IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_mapped_task_id             IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_mapped_task_reference      IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- FP M changes end (Mapping )
  ,p_deliverable                 IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR    -- 3435905
  ,p_deliverable_id              IN NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM -- 3661788 Added IN parameter
-- (Begin Venkat) Bug # 3450684 ----------------------------------------------------------
  ,p_ext_act_duration            IN NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM --Bug no 3450684
  ,p_ext_remain_duration         IN NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM --Bug no 3450684
  ,p_ext_sch_duration            IN NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM --Bug no 3450684
-- (End Venkat) Bug # 3450684 ------------------------------------------------------------
  ,p_op_validate_flag        IN VARCHAR2     := 'Y' --added by rtarway 4218977
  ,p_structure_updates_flag  IN VARCHAR2     := 'Y' --Added for Bug 7264422
) ;

/*#
 * This API is used to delete tasks of a project in Oracle Projects.
 * @param p_api_version_number API standard version number
 * @param p_commit API standard (default = F): indicates if transaction will be committed
 * @rep:paraminfo {@rep:precision 1}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @rep:paraminfo {@rep:precision 1}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_pm_product_code Identifier of the external system from which the project was imported
 * @rep:paraminfo {@rep:precision 25}
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system
 * @param p_pa_project_id The reference code that uniquely identifies the project in the Oracle Projects
 * @param p_pm_task_reference  The reference code that uniquely identifies project's task in the external system
 * @param p_pa_task_id  The reference code that uniquely identifies the task in a project in Oracle Projects
 * @param p_cascaded_delete_flag The flag indicating whether the whole hierarchy of task below the passed task needs
 * to be deleted or just the passed task id need to be deleted.The value Y indicates that whole task hierarchy will
 * get deleted below passed task. Default=N.
 * @param p_project_id The unique identifier of the project in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_task_id The unique identifier of the the task
 * @rep:paraminfo {@rep:required}
 * @param p_task_version_id Identifier of task version
 * @param p_structure_type  Identifier of the project structure type
 * @param p_process_mode Processing mode
 * @param p_structure_updates_flag When 'N' is passed, defer Process Structure Updates
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Task
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:compatibility S
*/
PROCEDURE delete_task
( p_api_version_number  IN  NUMBER      := 1.0  -- for bug# 3802319, earlier PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM was used
 ,p_commit              IN  VARCHAR2    := FND_API.G_FALSE
 ,p_init_msg_list       IN  VARCHAR2    := FND_API.G_FALSE
 ,p_msg_count           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_msg_data            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_pm_product_code     IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pm_project_reference    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id       IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_task_reference   IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_task_id          IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_cascaded_delete_flag    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_id          OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_task_id         OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_task_version_id      IN  NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_structure_type       IN VARCHAR2 := 'FINANCIAL'
  -- PA L Changes 3010538
 ,p_process_mode         IN   VARCHAR2   := 'ONLINE'
 ,p_structure_updates_flag IN  VARCHAR2   := 'Y' -- Bug 7390781
);

/*#
 * This API procedure is used to create the global data structures. Other Load-Execute-Fetch procedures
 * use the global data structures to create a new project.
 * In order to execute this API the following list of API's should be executed in the following order.
 * INIT_PROJECT,
 * LOAD_PROJECT,
 * LOAD_TASK,
 * LOAD_CLASS_CATEGORY,
 * LOAD_KEY_MEMBER,
 * EXECUTE_CREATE_PROJECT/EXECUTE_UPDATE_PROJECT,
 * FETCH_TASK and
 * CLEAR_PROJECT
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Multiple Projects: Init Project
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:compatibility S
*/
PROCEDURE init_project;

/*#
 * This API is used to load a project to a global PL/SQL record.
 * In order to execute this API the following list of API's should be executed in the following order.:
 * INIT_PROJECT,
 * LOAD_PROJECT,
 * LOAD_TASK,
 * LOAD_CLASS_CATEGORY,
 * LOAD_KEY_MEMBER,
 * EXECUTE_CREATE_PROJECT/EXECUTE_UPDATE_PROJECT,
 * FETCH_TASK and
 * CLEAR_PROJECT
 * @param p_api_version_number API standard version number
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_return_status API standard: return of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_pa_project_id The reference code that uniquely identifies the project in the Oracle Projects
 * @param p_pa_project_number The unique Oracle Projects number for the new project
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system
 * @param p_project_name The name of the project
 * @param p_long_name Long name of the project
 * @param p_created_from_project_id The unique reference code that identifies the source template in Oracle Projects
 * @param p_carrying_out_organization_id The identifier of the organization that carries out the project
 * @param p_public_sector_flag Flag indicating whether the project is in the public sector or the private sector
 * @param p_project_status_code The code for the project status
 * @param p_description The description of the project
 * @param p_start_date Start date of the project
 * @param p_completion_date End date of the project
 * @param p_distribution_rule The distribution rule that specifies the contract project's revenue accrual and billing method
 * @param p_customer_id The identifier of the project customer in Oracle Projects
 * @param p_project_relationship_code The type of customer relationship that the customer has on the project
 * @param p_actual_start_date The actual start date of the project.
 * @param p_actual_finish_date The actual end date of the project.
 * @param p_early_start_date The early start date of the project. Applicable only for a project that originated in an external system
 * @param p_early_finish_date The early finish date of the project. Applicable only for a project that originated in an external system
 * @param p_late_start_date The late start date of the project. Applicable only for a project that originated in an external system
 * @param p_late_finish_date The late finish date of the project. Applicable only for a project that originated in an external system
 * @param p_scheduled_start_date The scheduled start date of the project.
 * @param p_scheduled_finish_date The scheduled finish date of the project.
 * @param p_attribute_category The descriptive flexfield category
 * @param p_attribute1 Descriptive flexfield segment
 * @param p_attribute2 Descriptive flexfield segment
 * @param p_attribute3 Descriptive flexfield segment
 * @param p_attribute4 Descriptive flexfield segment
 * @param p_attribute5 Descriptive flexfield segment
 * @param p_attribute6 Descriptive flexfield segment
 * @param p_attribute7 Descriptive flexfield segment
 * @param p_attribute8 Descriptive flexfield segment
 * @param p_attribute9 Descriptive flexfield segment
 * @param p_attribute10 Descriptive flexfield segment
 * @param p_output_tax_code Flag indicating whether tax rate defined for the project will be used for customer invoices.
 * @param p_retention_tax_code The tax rate defined for retention invoices.
 * @rep:paraminfo {@rep:precision 30}
 * @param p_project_currency_code Project currency code. The default value is the currency code of the set of books.
 * @param p_allow_cross_charge_flag Indicates whether cross charge is  allowed or not.
 * Default Value is 'N'. This value can be overridden at any task level.
 * @rep:paraminfo {@rep:precision 1}
 * @param p_project_rate_date Task-level default value for project rate date
 * @param p_project_rate_type Task-level default value for project rate type
 * @param p_cc_process_labor_flag Flag indicating whether cross charge processing is to be performed for labor
 * transactions charged to the project. The default value for the project template is N. The default value for a
 * project is the value on the project template. The value for the project is the default value for the task.
 * @param p_labor_tp_schedule_id Identifier of the transfer price schedule to use for cross charged labor transactions.
 * The default value for a project is the value on the project template. The value for the project is the default value for the task.
 * If cc_process_labor_flag is set to Y, this field is required.
 * @param p_labor_tp_fixed_date Fixed date to find the effective rate of the bill rate or burden schedule when
 * determining the transfer price for labor transactions. . The default value for a project is the value on the project template.
 * The value for the project is the default value for the task.
 * @param p_cc_process_nl_flag Flag indicating whether cross charge processing is to be performed for non-labor transactions
 * charged to the project. The default value for the project template is N. The default value for a project is the value on the
 * project template. The value for the project is the default value for the task.
 * @rep:paraminfo {@rep:precision 1}
 * @param p_nl_tp_schedule_id Identifier of the transfer price schedule to use for cross charged non labor transactions.
 * The default value for a project is the value on the project template. The value for the project is the default value for the task
 * If cc_process_nl_flag is set to Y, this field is required.
 * @param p_nl_tp_fixed_date Fixed date to find the effective rate of the bill rate or burden schedule when determining
 * the transfer price for non labor transactions. The default value for a project is the value on the project template.
 * The value for the project is the default value for the task.
 * @param p_cc_tax_task_id Identifier of the task to which intercompany tax items on the intercompany payables invoice are charged
 * @param p_role_list_id Identifier of the role list. The role list is a list of allowable roles that are displayed when the
 * members are assigned.
 * @param p_work_type_id Identifier of the work type
 * @param p_calendar_id Identifier of the calendar used on the project.
 * @param p_location_id Identifier of the project work site location.
 * @param p_probability_member_id Probability of a project becoming approved. This value is used as a weighting average for reporting.
 * @param p_project_value The OPPORTUNITY_VALUE converted to the project  functional currency
 * @param p_expected_approval_date The expected date of the project approval
 * @param p_cost_job_group_id Identifier of the job group that will be used for costing functionality
 * @param p_bill_job_group_id Identifier of the job group that will be used for billing functionality
 * @param p_emp_bill_rate_schedule_id Identifier for employee bill rate schedule
 * @param p_job_bill_rate_schedule_id Identifier for job bill rate schedule
 * @param p_invproc_currency_type Invoice processing currency type
 * @param p_revproc_currency_code Revenue processing currency code
 * @param p_project_bil_rate_date_code Exchange rate date type for determining the date to use for conversion from bill
 * transaction currency/ funding currency to project currency used for customer billing.
 * @param p_project_bil_rate_type Exchange rate type to use for conversion from bill transaction currency/ funding currency
 * to project currency used for customer billing.
 * @param p_project_bil_rate_date Exchange rate date to use for conversion from bill transaction currency/ funding currency
 * to project currency if Fixed Date rate date type is used for customer billing.
 * @param p_project_bil_exchange_rate Exchange rate to use for conversion from bill transaction currency/ funding currency
 * to project if User exchange rate type is used.
 * @param p_projfunc_currency_code Project functional currency.  The default value is the value entered for the associated set of books.
 * @param p_projfunc_bil_rate_date_code Exchange rate date type for determining the date to use for conversion from bill
 * transaction currency/ funding currency to project functional currency for customer billing
 * @param p_projfunc_bil_rate_type Exchange rate type to use for conversion from bill transaction currency/ funding currency
 * to project functional currency for customer billing
 * @param p_projfunc_bil_rate_date Exchange rate date to use for conversion from bill transaction currency/funding currency
 * to project functional currency if Fixed Date rate date type is used for customer billing
 * @param p_projfunc_bil_exchange_rate Exchange rate for conversion from bill transaction currency or
 * funding currency to project functional currency if the rate type is User
 * @param p_funding_rate_date_code Exchange rate date type for determining the date to use for conversion from bill transaction
 * currency to funding currency for customer billing
 * @param p_funding_rate_type Exchange rate type to use for conversion from bill transaction currency to funding currency for
 * customer billing
 * @param p_funding_rate_date Exchange rate date to use for conversion from bill  transaction currency to funding currency
 * if Fixed Date rate date type is used for customer billing
 * @param p_funding_exchange_rate Exchange rate to use for conversion from bill transaction currency to project or functional
 * currency if User exchange rate type is used
 * @param p_baseline_funding_flag Flag indicating whether baseline funding can be created without a revenue budget.
 * @rep:paraminfo {@rep:precision 1}
 * @param p_multi_currency_billing_flag Flag indicating whether multi-currency billing is allowed for this project
 * @rep:paraminfo {@rep:precision 1}
 * @param p_competence_match_wt Weighting value for competence match used to calculate score
 * @param p_availability_match_wt Weighting value for availability match used to calculate score
 * @param p_job_level_match_wt Weighting value for job level match used to calculate score
 * @param p_enable_automated_search Flag indicating whether automated candidate nomination is done for the requirements on a project
 * (whether the enable Automated Search check box is enabled).
 * @param p_search_min_availability The minimum required availability of a resource to be returned in the search result
 * @param p_search_org_hier_id The organization hierarchy for the search
 * @param p_search_starting_org_id The starting organization for the search
 * @param p_search_country_id The country for the search
 * @param p_min_cand_score_reqd_for_nom Minimum score required for a resource to be nominated as candidate on a requirement
 * @param p_max_num_of_sys_nom_cand Maximum number of candidates nominated
 * @param p_non_lab_std_bill_rt_sch_id Identifier of the non-labor standard bill rate schedule.
 * @param p_search_country_code Code used for country for the search
 * @param p_inv_by_bill_trans_curr_flag Flag indicating whether invoicing is by bill transaction currency
 * @rep:paraminfo {@rep:precision 1}
 * @param p_projfunc_cost_rate_type The default value for the project functional cost rate
 * @param p_projfunc_cost_rate_date The default value for the project functional cost rate date
 * @param p_assign_precedes_task Flag indicating whether assignment level attributes override task-level attributes
 * @param p_split_cost_from_wokplan_flag Split cost from bill flag
 * @rep:paraminfo {@rep:precision 1}
 * @param p_split_cost_from_bill_flag Split cost from workplan flag
 * @rep:paraminfo {@rep:precision 1}
 * @param p_adv_action_set_id The default advertisement action set of the project or the project template
 * @param p_start_adv_action_set_flag Flag indicating whether the advertisement action set will be started immediately after a
 * requirement is created
 * @rep:paraminfo {@rep:precision 1}
 * @param p_priority_code The priority code of the project.
 * @param p_retn_billing_inv_format_id Identifier of the retention billing invoice format.
 * @param p_retn_accounting_flag Flag indicating whether the retention accounting is enabled for the project
 * @param p_opp_value_currency_code The currency code for project opportunity value
 * @param p_revaluate_funding_flag Flag indicating whether the funding has to be revaluated
 * @rep:paraminfo {@rep:precision 1}
 * @param p_include_gains_losses_flag Flag indicating whether gains and losses  to be included in project revenue
 * @rep:paraminfo {@rep:precision 1}
 * @param p_security_level Security level of the project. 0 indicated the project is private. 100 indicates project is public.
 * @param p_labor_disc_reason_code Reason code for labor discount
 * @param p_non_labor_disc_Reason_code Discount reason code for non-labor
 * @param p_asset_allocation_method The method used to allocate indirect and common costs across the assets
 * assigned to a grouping level
 * @param p_capital_event_processing Capital event processing method.  Used to determine when cost and assets are grouped for
 * capitalization or retirement adjustment processing.
 * @param p_cint_rate_sch_id  Identifier of the capital interest rate schedule
 * @param p_cint_eligible_flag Flag used to determine whether the project is eligible for capitalized interest.
 * @rep:paraminfo {@rep:precision 1}
 * @param p_cint_stop_date Stop date for capital interest calculation
 * @param p_bill_To_Customer_id  Identifier of the bill-to customer
 * @param p_ship_To_Customer_id  Identifier of the ship-to customer
 * @param p_process_mode Processing mode
 * @param p_sys_program_flag Flag that indicates whether the project can work as a program.
 * Valid values are Y and N.
 * @rep:paraminfo {@rep:precision 1}
 * @param p_enable_top_task_cust_flag Flag that indicates whether to enable Top Task Customer
 * for the project. Valid values are Y and N.
 * @rep:paraminfo {@rep:precision 1}
 * @param p_enable_top_task_inv_mth_flag Flag that indicates whether to enable the top task invoice
 * method for the project. Valid values are Y and N.
 * @rep:paraminfo {@rep:precision 1}
 * @param p_projfunc_attr_for_ar_flag This is an internal attribute.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Multiple Projects: Load Project
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:compatibility S
*/
PROCEDURE load_project
( p_api_version_number      IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_init_msg_list       IN  VARCHAR2    := FND_API.G_FALSE
 ,p_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_pa_project_id       IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pa_project_number       IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pm_project_reference    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_name        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_long_name           IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_created_from_project_id IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_carrying_out_organization_id IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_public_sector_flag      IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_status_code     IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_description         IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_start_date          IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_completion_date     IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_distribution_rule       IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_customer_id         IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_relationship_code   IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_actual_start_date           IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_actual_finish_date          IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_early_start_date            IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_early_finish_date           IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_late_start_date             IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_late_finish_date            IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_scheduled_start_date        IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_scheduled_finish_date       IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_attribute_category      IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute1          IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute2          IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute3          IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute4          IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute5          IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute6          IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute7          IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute8          IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute9          IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute10         IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_output_tax_code     IN VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_retention_tax_code  IN VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_currency_code IN VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_allow_cross_charge_flag IN VARCHAR2:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_rate_date       IN DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_project_rate_type       IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_cc_process_labor_flag   IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_labor_tp_schedule_id    IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_labor_tp_fixed_date     IN DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_cc_process_nl_flag   IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_nl_tp_schedule_id    IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_nl_tp_fixed_date     IN DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_cc_tax_task_id       IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_role_list_id    IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_work_type_id    IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_calendar_id     IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_location_id     IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_probability_member_id   IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_value   IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_expected_approval_date   IN DATE   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_cost_job_group_id   IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_bill_job_group_id   IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_emp_bill_rate_schedule_id  IN NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_job_bill_rate_schedule_id  IN NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--Sakthi MCB
 ,p_invproc_currency_type        IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_revproc_currency_code        IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_bil_rate_date_code   IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_bil_rate_type        IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_bil_rate_date        IN DATE         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_project_bil_exchange_rate    IN NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_projfunc_currency_code      IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_bil_rate_date_code  IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_bil_rate_type       IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_bil_rate_date       IN DATE         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_projfunc_bil_exchange_rate   IN NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_funding_rate_date_code  IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_funding_rate_type       IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_funding_rate_date       IN DATE         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_funding_exchange_rate   IN NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_baseline_funding_flag        IN VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_multi_currency_billing_flag  IN VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_competence_match_wt          IN NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_availability_match_wt        IN NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_job_level_match_wt           IN NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_enable_automated_search      IN VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_search_min_availability      IN NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_search_org_hier_id           IN NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_search_starting_org_id       IN NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_search_country_id            IN NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_min_cand_score_reqd_for_nom  IN NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_max_num_of_sys_nom_cand      IN NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_non_lab_std_bill_rt_sch_id   IN NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_search_country_code          IN VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_inv_by_bill_trans_curr_flag  IN VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_cost_rate_type      IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_cost_rate_date      IN DATE         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--Sakthi MCB
--Sakthi Structure
 ,p_assign_precedes_task            IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_split_cost_from_wokplan_flag   IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_split_cost_from_bill_flag       IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--Sakthi Structure
--Advertisement
 ,p_adv_action_set_id              IN NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_start_adv_action_set_flag      IN VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--Advertisement
--Project Setup
 ,p_priority_code                  IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--Project Setup
--Retention
 ,p_retn_billing_inv_format_id     IN NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_retn_accounting_flag           IN VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--Retention
-- anlee opportunity changes
 ,p_opp_value_currency_code        VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- anlee
-- patchset K changes
 ,p_revaluate_funding_flag         VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_include_gains_losses_flag    VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_security_level               IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_labor_disc_reason_code       IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_non_labor_disc_reason_code   IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- End of changes
--PA L changes -- bug 2872708   --load_project
 ,p_asset_allocation_method       VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_capital_event_processing      VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_cint_rate_sch_id              NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_cint_eligible_flag            VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_cint_stop_date                DATE         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--end PA L changes -- bug 2872708

-- crm changes
 ,p_bill_To_Customer_id          NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_ship_To_Customer_id          NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- crm changes
-- PA L Changes 3010538
 ,p_process_mode         IN   VARCHAR2   := 'ONLINE'

-- FP M changes begin (venkat)
 ,p_sys_program_flag            IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 , p_allow_multi_program_rollup  IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR -- Bug # 5072032.
 ,p_enable_top_task_cust_flag      IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_enable_top_task_inv_mth_flag    IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_attr_for_ar_flag       IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- FP M changes begin (venkat)
 ,p_ar_rec_notify_flag              IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  -- 7508661 : EnC
 ,p_auto_release_pwp_inv            IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  -- 7508661 : EnC
 );

/*#
 * This Load-Execute-Fetch API is used is used to load key members to a global PL/SQL table.
 * In order to execute this API the following list of API's should be executed in the following order.
 * INIT_PROJECT,
 * LOAD_PROJECT,
 * LOAD_TASK,
 * LOAD_CLASS_CATEGORY,
 * LOAD_KEY_MEMBER,
 * EXECUTE_CREATE_PROJECT/EXECUTE_UPDATE_PROJECT,
 * FETCH_TASK and
 * CLEAR_PROJECT
 * @param p_api_version_number API standard version number
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_return_status API standard: return of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_person_id Identifier of the person
 * @param p_project_role_type The type of role played by the person in the project.
 * @param p_start_date The start date from when the person is playing a role.
 * Default = sysdate
 * @param p_end_date Project End date
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Multiple Projects-Load Key Member
 * @rep:category  BUSINESS_ENTITY PA_PROJECT
 * @rep:compatibility S
*/
PROCEDURE load_key_member
( p_api_version_number      IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_init_msg_list       IN  VARCHAR2    := FND_API.G_FALSE
 ,p_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_person_id           IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_role_type       IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_role_meaning       IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR -- Bug 6408593
 ,p_start_date          IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_end_date            IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE  );

-- anlee org role changes

/*#
 * This API is a Load-Execute-Fetch procedure used to load organization roles
 * from the client side to a PL/SQL table on the server side, where the roles will be used
 * by the Load-Execute-Fetch cycle. Please refer to the API user guide for more information
 * on required parameters and optional parameters of this API.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @rep:paraminfo {@rep:precision 1}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1}
 * @param p_resource_source_id Source identifier of the resource
 * @param p_project_role_type Project role type
 * @param p_start_date Start date of the organization role (DEFAULT = SYSDATE)
 * @param p_end_date End date of the organization role
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Load Organization Role
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:compatibility S
 */
PROCEDURE load_org_role
( p_api_version_number      IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_init_msg_list       IN  VARCHAR2    := FND_API.G_FALSE
 ,p_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_resource_source_id      IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_role_type       IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_start_date          IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_end_date            IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE  );

/*#
 * This Load-Execute-Fetch API is used to load class categories to a global PL/SQL table.
 * In order to execute this API the following list of API's should be executed in the following order.
 * INIT_PROJECT,
 * LOAD_PROJECT,
 * LOAD_TASK,
 * LOAD_CLASS_CATEGORY,
 * LOAD_KEY_MEMBER,
 * EXECUTE_CREATE_PROJECT/EXECUTE_UPDATE_PROJECT,
 * FETCH_TASK and
 * CLEAR_PROJECT
 * @param p_api_version_number API standard version number
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_return_status API standard: return of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_class_category Class category
 * @param p_class_code Yes, Class code
 * @param p_code_percentage Class code percentage
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Multiple Projects: Load Class Category
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:compatibility S
*/
PROCEDURE load_class_category
( p_api_version_number      IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_init_msg_list       IN  VARCHAR2    := FND_API.G_FALSE
 ,p_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_class_category      IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_class_code          IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_new_class_code      IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR   -- Added for Bug 7028230
 ,p_code_percentage             IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  );

/*#
 * This API is used to load a task to a global PL/SQL table.
 * In order to execute this API the following list of API's should be executed in the following order.:
 * INIT_PROJECT,
 * LOAD_PROJECT,
 * LOAD_TASK,
 * LOAD_CLASS_CATEGORY,
 * LOAD_KEY_MEMBER,
 * EXECUTE_CREATE_PROJECT/EXECUTE_UPDATE_PROJECT,
 * FETCH_TASK and
 * CLEAR_PROJECT.
 * @param p_api_version_number API standard version number
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_return_status API standard: return of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_pm_task_reference  The reference code that uniquely identifies project's task in the external system
 * @param p_pa_task_id The reference code that uniquely identifies the task within a project in Oracle Projects
 * @param p_task_name The name that uniquely identifies the task within a project
 * @param p_long_task_name  Long name of the task
 * @param p_pa_task_number  The number that identifies the task in the Oracle projects
 * @param p_task_description Description of the task
 * @param p_task_start_date The start date of the task
 * @param p_task_completion_date The completion date of the task
 * @param p_pm_parent_task_reference The unique reference code that identifies the task's parent task
 * @param p_pa_parent_task_id The identifier of task's parent task in Oracle Projects
 * @param p_address_id The address of one of the customers that is logically linked to this task
 * @param p_carrying_out_organization_id The identifier of the organization that is responsible for the project work
 * @param p_service_type_code The type of work performed on the task
 * @param p_task_manager_person_id The identifier of the employee who manages the task
 * @param p_billable_flag Flag indicating whether items charged to the task can accrue revenue
 * @rep:paraminfo {@rep:precision 1}
 * @param p_chargeable_flag Flag indicating whether expenditure items can be charged to the task. Only lowest level tasks can be chargeable
 * @rep:paraminfo {@rep:precision 1}
 * @param p_ready_to_bill_flag Flag indicating whether the task is authorized to be invoiced
 * @rep:paraminfo {@rep:precision 1}
 * @param p_ready_to_distribute_flag Flag indicating whether the task is authorized for revenue accrual
 * @rep:paraminfo {@rep:precision 1}
 * @param p_limit_to_txn_controls_flag Flag indicating whether users can only charge expenditures
 * to the tasks that are listed in task transaction controls
 * @rep:paraminfo {@rep:precision 1}
 * @param p_labor_bill_rate_org_id  The identifier of the organization that owns the labor standard bill rate schedule
 * @param p_labor_std_bill_rate_schdl The labor standard bill rate schedule that is used to calculate revenue for labor
 * expenditure items charged to the task
 * @param p_labor_schedule_fixed_date The date used to determine the effective bill rates of the task standard labor bill rate schedule
 * @param p_labor_schedule_discount The discount percent on the task standard labor bill rate schedule
 * @param p_nl_bill_rate_org_id The identifier of the organization that owns the non-labor standard bill rate schedule
 * @param p_nl_std_bill_rate_schdl The non-labor standard bill rate schedule that is used to calculate revenue
 * for non-labor expenditure items charged to the task
 * @param p_nl_schedule_fixed_date The fixed date used to determine the effective bill rates of the standard non-labor bill rate schedule.
 * @param p_nl_schedule_discount The discount percent on the task standard non-labor bill rate schedule
 * @param p_labor_cost_multiplier_name The labor cost multiplier defined for the task of a premium project
 * @param p_cost_ind_rate_sch_id The identifier of the default costing burden schedule
 * @param p_rev_ind_rate_sch_id The identifier of the default revenue burden schedule
 * @param p_inv_ind_rate_sch_id The identifier of the default invoice burden schedule
 * @param p_cost_ind_sch_fixed_date The schedule fixed date of the firm costing burden schedule
 * @param p_rev_ind_sch_fixed_date The schedule fixed date of the firm revenue burden schedule
 * @param p_inv_ind_sch_fixed_date The schedule fixed date of the firm invoice burden schedule
 * @param p_labor_sch_type The schedule type of labor expenditure items
 * @param p_nl_sch_type The schedule type of non-labor expenditure items
 * @param p_actual_start_date The actual start date of the project. Applicable only for a project that originated in an external system.
 * @param p_actual_finish_date The actual end date of the project. Applicable only for a project that originated in an external system.
 * @param p_early_start_date The early start date of the project. Applicable only for a project that originated in an external system.
 * @param p_early_finish_date The early finish date of the project. Applicable only for a project that originated in an external system.
 * @param p_late_start_date The late start date of the project. Applicable only for a project that originated in an external system.
 * @param p_late_finish_date The late finish date of the project. Applicable only for a project that originated in an external system.
 * @param p_scheduled_start_date The scheduled start date of the project
 * @param p_scheduled_finish_date The scheduled finish date of the project
 * @param p_attribute_category Descriptive flexfield category
 * @param p_attribute1 Descriptive flexfield segment
 * @param p_attribute2 Descriptive flexfield segment
 * @param p_attribute3 Descriptive flexfield segment
 * @param p_attribute4 Descriptive flexfield segment
 * @param p_attribute5 Descriptive flexfield segment
 * @param p_attribute6 Descriptive flexfield segment
 * @param p_attribute7 Descriptive flexfield segment
 * @param p_attribute8 Descriptive flexfield segment
 * @param p_attribute9 Descriptive flexfield segment
 * @param p_attribute10 Descriptive flexfield segment
 * @param p_allow_cross_charge_flag Flag indicating whether cross charges are allowed
 * @param p_project_rate_date Task-level default value for project rate date
 * @param p_project_rate_type Task-level default value for project rate type
 * @param p_cc_process_labor_flag Flag indicating cross charge processing is to be performed for labor transactions charged to the project.
 * The default value for the project template is N. The default value for a project is the value on the project template. The value for
 * the project is the default value for the task.
 * @rep:paraminfo {@rep:precision 1}
 * @param p_labor_tp_schedule_id Identifier of the transfer price schedule to use for cross charged labor transactions. The default value
 * for a project is the value on the project template. The value for the project is the default value for the task. If cc_process_labor_flag
 * is set to Y, this field is required
 * @param p_labor_tp_fixed_date Fixed date to find the effective rate of the bill rate or burden schedule when determining the transfer price
 * for labor transactions. The default value for a project is the value on the project template. The value for the project is
 * the default value for the task.
 * @param p_cc_process_nl_flag Flag indicating cross charge processing is to be performed for non-labor transactions charged to the project.
 * The default value for the project template is N. The default value for a project is the value on the project template. The value for the
 * project is the default value for the task.
 * @rep:paraminfo {@rep:precision 1}
 * @param p_nl_tp_schedule_id Identifier of the transfer price schedule to use for cross charged non-labor transactions. The default value
 * for a project is the value on the project template. The value for the project is the default value for the task. If cc_process_nl_flag
 * is set to Y, this field is required
 * @param p_nl_tp_fixed_date Fixed date to find the effective rate of the bill rate or burden schedule when determining the transfer price
 * for non-labor transactions. The default value for a project is the value on the project template. The value for the project is the default
 * value for the task.
 * @param p_receive_project_invoice_flag Flag indicating whether the task cancan receive charges from internal supplies using interproject billing
 * via inter project billing
 * @rep:paraminfo {@rep:precision 1}
 * @param p_work_type_id Identifier of the work type
 * @param p_emp_bill_rate_schedule_id Identifier of the the employee bill rate schedule
 * @param p_job_bill_rate_schedule_id Identifier of the the job bill rate schedule
 * @param p_non_lab_std_bill_rt_sch_id Identifier of the the non-labor standard bill rate schedule
 * @param p_taskfunc_cost_rate_type Task-level default value for the project functional cost rate type
 * @param p_taskfunc_cost_rate_date Task-level default value for the project functional cost rate date
 * @param p_display_sequence Order of display
 * @param p_wbs_level The level of the task in the work breakdown structure
 * @param P_OBLIGATION_START_DATE The obligation start date of the workplan version
 * @param P_OBLIGATION_FINISH_DATE The obligation finish date of the workplan version
 * @param P_ESTIMATED_START_DATE The estimated start date of the workplan version
 * @param P_ESTIMATED_FINISH_DATE The estimated finish date of the workplan version
 * @param P_BASELINE_START_DATE The baseline start date for the task or the workplan
 * @param P_BASELINE_FINISH_DATE The baseline finish date for the task or the workplan
 * @param P_CLOSED_DATE The date on which the element status was set to Closed. This is a task-specific attribute.
 * @param P_WQ_UOM_CODE The unit of measure used for work quantity for a task
 * @param P_WQ_ITEM_CODE The work item for work quantity for a task
 * @param P_STATUS_CODE The status of the project element
 * @param P_WF_STATUS_CODE  The status of workflow associated with the element
 * @param P_PM_SOURCE_CODE Identifier of the source code system
 * @param P_PRIORITY_CODE The priority of the task. This is a task-specific attribute.
 * @param P_MILESTONE_FLAG  Flag indicating whether the task version is a milestone. This is a task-specific attribute.
 * @param P_CRITICAL_FLAG Flag indicating whether the task version is part of the critical path. This is a task-specific attribute..
 * @param P_INC_PROJ_PROGRESS_FLAG Project progress flag
 * @param P_LINK_TASK_FLAG  Flag indicating whether a task is used for linking purposes and is not displayed in the user interface
 * @param P_CALENDAR_ID The identifier of the work calendar used to schedule the task. This is a task-specific attribute.
 * @param P_PLANNED_EFFORT The planned effort for the task
 * @param P_DURATION The duration between scheduled start date and scheduled end date using the work calendar
 * @param P_PLANNED_WORK_QUANTITY The planned work quantity for the task
 * @param P_TASK_TYPE Type of task.
 * @param p_labor_disc_reason_code Labor discount reason code
 * @param p_non_labor_disc_reason_code Non-labor discount reason code
 * @param p_retirement_cost_flag Flag indicating whether the task is marked for retirement cost collection
 * @rep:paraminfo  {@rep:precision 1}
 * @param p_cint_eligible_flag Flag indicating whether the project is eligible for capitalized interest.
 * @rep:paraminfo  {@rep:precision 1}
 * @param p_cint_stop_date  Stop date for capital interest calculation
 * @param p_pred_string The string containing the predecessor information
 * @rep:paraminfo {@rep:precision 400} {@rep:required}
 * @param p_pred_delimiter Delimiter that separates predecessors in the predecessor string
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_base_percent_comp_deriv_code Base percent complete derivation code for the task
 * @rep:paraminfo {@rep:precision 30} {@rep:required}
 * @param p_sch_tool_tsk_type_code Default scheduling tool task type for the task version
 * @rep:paraminfo {@rep:precision 30} {@rep:required}
 * @param p_constraint_type_code Constraint type for the task version
 * @rep:paraminfo {@rep:precision 30} {@rep:required}
 * @param p_constraint_date Constraint date for the task version
 * @rep:paraminfo {@rep:required}
 * @param p_free_slack Free slack for the task version
 * @rep:paraminfo {@rep:required}
 * @param p_total_slack Total slack for the task version
 * @rep:paraminfo {@rep:required}
 * @param p_effort_driven_flag Flag that indicates whether the task is effort driven
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_level_assignments_flag Flag that indicates whether the assignments on this task should be leveled
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_invoice_method The invoice method for the task. This parameter is valid only if invoice method at top task is enabled.
 * @rep:paraminfo {@rep:precision 30} {@rep:required}
 * @param p_customer_id The customer for the task. This parameter is valid only if customer at top task is enabled.
 * @rep:paraminfo {@rep:required}
 * @param p_gen_etc_source_code Estimate to complete source
 * @rep:paraminfo {@rep:precision 30} {@rep:required}
 * @param p_financial_task_flag Flag that indicates whether the task is a financial task or not.
 * This flag is valid only for partially shared structures. Tasks that are above this level are used
 * for financial management.
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_mapped_task_id Mapped task ID. This parameter is applicable only in case of split-mapped structure
 * sharing between workplan and financial structures.
 * @rep:paraminfo {@rep:required}
 * @param p_mapped_task_reference Mapped task reference
 * @rep:paraminfo {@rep:precision 150} {@rep:required}
 * @param p_deliverable Deliverable reference to be associated with the task
 * @rep:paraminfo {@rep:precision 4000}
 * @param p_deliverable_id Deliverable ID to be associated with the task
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_ext_act_duration From the external application, the actual duration
 * @rep:paraminfo {@rep:required}
 * @param p_ext_remain_duration  From the external application, the remaining duration
 * @rep:paraminfo {@rep:required}
 * @param p_ext_sch_duration From the external application, the scheduled duration
 * @rep:paraminfo {@rep:required}
 * @param p_etc_effort Estimated remaining effort for the task
 * @rep:paraminfo {@rep:required}
 * @param p_percent_complete Percentage of work complete on the task.
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Multiple Tasks: Load
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:compatibility S
*/
PROCEDURE load_task
(  p_api_version_number         IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_init_msg_list          IN  VARCHAR2    := FND_API.G_FALSE
  ,p_return_status          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,p_pm_task_reference          IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_pa_task_id                         IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_task_name              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_long_task_name         IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_pa_task_number             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_task_description           IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_task_start_date            IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,p_task_completion_date       IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,p_pm_parent_task_reference       IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_pa_parent_task_id          IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_address_id             IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_carrying_out_organization_id   IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_service_type_code          IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_task_manager_person_id     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_billable_flag          IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_chargeable_flag            IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_ready_to_bill_flag         IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_ready_to_distribute_flag       IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_limit_to_txn_controls_flag     IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_labor_bill_rate_org_id     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_labor_std_bill_rate_schdl      IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_labor_schedule_fixed_date      IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,p_labor_schedule_discount        IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_nl_bill_rate_org_id        IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_nl_std_bill_rate_schdl     IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_nl_schedule_fixed_date     IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,p_nl_schedule_discount       IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_labor_cost_multiplier_name     IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_cost_ind_rate_sch_id       IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_rev_ind_rate_sch_id        IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_inv_ind_rate_sch_id        IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_cost_ind_sch_fixed_date        IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,p_rev_ind_sch_fixed_date     IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,p_inv_ind_sch_fixed_date     IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,p_labor_sch_type         IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_nl_sch_type            IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 , p_actual_start_date                  IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 , p_actual_finish_date                 IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 , p_early_start_date                   IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 , p_early_finish_date                  IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 , p_late_start_date                    IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 , p_late_finish_date                   IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 , p_scheduled_start_date               IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 , p_scheduled_finish_date              IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,p_tasks_dff                    IN VARCHAR2    := 'N'--bug 6153503
  ,p_attribute_category         IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute1             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute2             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute3             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute4             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute5             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute6             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute7             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute8             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute9             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute10            IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  --bug 6153503
  ,p_attribute11             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute12             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute13             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute14             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute15             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  --end bug 6153503
  ,p_allow_cross_charge_flag IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_project_rate_date       IN DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,p_project_rate_type       IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_cc_process_labor_flag  IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_labor_tp_schedule_id   IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_labor_tp_fixed_date    IN DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,p_cc_process_nl_flag     IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_nl_tp_schedule_id      IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_nl_tp_fixed_date       IN DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,p_receive_project_invoice_flag IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_work_type_id           IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_emp_bill_rate_schedule_id  IN NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_job_bill_rate_schedule_id  IN NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--Sakthi  MCB
 ,p_non_lab_std_bill_rt_sch_id  IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_taskfunc_cost_rate_type     IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_taskfunc_cost_rate_date     IN DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--Sakthi  MCB
 ,p_display_sequence        IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_wbs_level               IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--Project structure
 ,P_OBLIGATION_START_DATE              IN DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,P_OBLIGATION_FINISH_DATE             IN DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,P_ESTIMATED_START_DATE               IN DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,P_ESTIMATED_FINISH_DATE              IN DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,P_BASELINE_START_DATE                IN DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,P_BASELINE_FINISH_DATE               IN DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,P_CLOSED_DATE                        IN DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,P_WQ_UOM_CODE                        IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_WQ_ITEM_CODE                       IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_STATUS_CODE                        IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_WF_STATUS_CODE                     IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_PM_SOURCE_CODE                      IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_PRIORITY_CODE                      IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_MILESTONE_FLAG                     IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_CRITICAL_FLAG                      IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_INC_PROJ_PROGRESS_FLAG             IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_LINK_TASK_FLAG                     IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_CALENDAR_ID                        IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,P_PLANNED_EFFORT                     IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,P_DURATION                           IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,P_PLANNED_WORK_QUANTITY              IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,P_TASK_TYPE                          IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--Project structure
 ,p_labor_disc_reason_code       IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_non_labor_disc_reason_code   IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--PA L changes -- bug 2872708  --load_task
 ,p_retirement_cost_flag          VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_cint_eligible_flag            VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_cint_stop_date                DATE         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--end PA L changes -- bug 2872708
-- FP-M Bug # 3301192
 ,p_pred_string                   IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- ,p_pred_delimiter                IN VARCHAR2    DEFAULT ','
 ,p_pred_delimiter                IN VARCHAR2   :=  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- FP M changes begin (venkat)
  ,p_base_percent_comp_deriv_code IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_sch_tool_tsk_type_code   IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_constraint_type_code       IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_constraint_date            IN DATE  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,p_free_slack             IN NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_total_slack                IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_effort_driven_flag         IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_level_assignments_flag     IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_invoice_method             IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_customer_id                IN NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_gen_etc_source_code            IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- FP M changes end (venkat)
-- FP M changes start (Mapping )
   ,p_financial_task_flag        IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  --SMukka
   ,p_mapped_task_id             IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM   --SMukka
   ,p_mapped_task_reference      IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  --SMukka
-- FP M changes end (Mapping )
  ,p_deliverable                IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR    --3435905
  ,p_deliverable_id             IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM     -- 3661788 Added IN parameter
-- (begin venkat) new params for bug #3450684 --------------------------------------
   ,p_ext_act_duration           IN NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM --Bug no 3450684
  ,p_ext_remain_duration         IN NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM --Bug no 3450684
  ,p_ext_sch_duration            IN NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM --Bug no 3450684
-- (end venkat) new params for bug #3450684 --------------------------------------

-- Progress Management Changes. Bug # 3420093.
  ,p_etc_effort                 IN NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_percent_complete           IN NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- Progress Management Changes. Bug # 3420093.

  );

/*#
 * This Load-Execute-Fetch API is used to create a project and its tasks using the data that is stored in the global tables
 * during the Load process.
 * INIT_PROJECT,
 * LOAD_PROJECT,
 * LOAD_TASK,
 * LOAD_CLASS_CATEGORY,
 * LOAD_KEY_MEMBER,
 * EXECUTE_CREATE_PROJECT/EXECUTE_UPDATE_PROJECT,
 * FETCH_TASK and
 * CLEAR_PROJECT
 * @param p_api_version_number API standard version number
 * @param p_commit API standard (default = F): indicates if transaction will be committed
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_workflow_started Indicates if a workflow has been started (Y or N)
 * @rep:paraminfo {@rep:required}
 * @param p_pm_product_code Identifier of the external system from which the project was imported
 * @rep:paraminfo {@rep:precision 25}
 * @param p_op_validate_flag Indicates whether the system performs scheduling validations. Default is Y.
 * @rep:paraminfo {@rep:precision 1}
 * @param p_pa_project_id The unique Oracle Projects identification code for the project
 * @rep:paraminfo {@rep:precision 25} {@rep:required}
 * @param p_pa_project_number  The unique Oracle Projects number for the Project
 * @rep:paraminfo {@rep:precision 25} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Multiple Projects: Execute Create Project
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:category BUSINESS_ENTITY PA_PROJ_DELIVERABLE
 * @rep:compatibility S
*/
PROCEDURE execute_create_project
( p_api_version_number          IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit              IN  VARCHAR2    := FND_API.G_FALSE
 ,p_init_msg_list                         IN    VARCHAR2    := FND_API.G_FALSE
 ,p_msg_count               OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_msg_data                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_return_status                         OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_workflow_started                      OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_pm_product_code         IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_op_validate_flag     IN  VARCHAR2  := 'Y'--added by rtarway, 4218977
 ,p_pa_project_id           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_pa_project_number           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

/*#
 * This Load Execute Fetch API is used to fetch output parameters related to tasks.
 * In order to execute this API the following list of API's should be executed in the following order.
 * INIT_PROJECT,
 * LOAD_PROJECT,
 * LOAD_TASK,
 * LOAD_CLASS_CATEGORY,
 * LOAD_KEY_MEMBER,
 * EXECUTE_CREATE_PROJECT/EXECUTE_UPDATE_PROJECT,
 * FETCH_TASK and
 * CLEAR_PROJECT
 * @param p_api_version_number API standard version number
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_return_status API standard: return of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_task_index Pointer to a single task
 * @param p_pa_task_id Unique id for the task to be fetched
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_pm_task_reference The reference code that identifies the task in the external system
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_task_return_status  Indicates whether the API has handled the task successfully. 'S'
 * indicates success. E indicates a business rule violation, and U indicates that an unexpected error occurred.
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Multiple Tasks: Fetch
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:compatibility S
*/
PROCEDURE fetch_task
( p_api_version_number      IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_init_msg_list       IN  VARCHAR2    := FND_API.G_FALSE
 ,p_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_task_index          IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pa_task_id          OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_pm_task_reference       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_task_return_status      OUT NOCOPY VARCHAR2                ); --File.Sql.39 bug 4440895

/*#
 * This API procedure is used to clear the global structures created during the load process.
 * INIT_PROJECT,
 * LOAD_PROJECT,
 * LOAD_TASK,
 * LOAD_CLASS_CATEGORY,
 * LOAD_KEY_MEMBER,
 * EXECUTE_CREATE_PROJECT/EXECUTE_UPDATE_PROJECT,
 * FETCH_TASK and
 * CLEAR_PROJECT
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Multiple Projects: Clear Project
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:compatibility S
*/
PROCEDURE clear_project;

/*#
 * This API is used to determine if you can delete a task.
 * @param p_api_version_number API standard version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_return_status API standard: return of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_project_id The unique identifier of the project in Oracle Projects
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system
 * @param p_task_id The reference code that uniquely identifies a task within a project in Oracle Projects
 * @param p_pm_task_reference The reference code that identifies the task in the external system
 * @param p_structure_type Identifier of the project structure type
 * @param p_task_version_id The reference code that identifies the task in the external system
 * @param p_delete_task_ok_flag Flag indicating whether or not the task number can be changed
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Verify Task Deletion
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:compatibility S
*/
PROCEDURE Check_Delete_Task_OK
( p_api_version_number      IN  NUMBER
, p_init_msg_list       IN  VARCHAR2    := FND_API.G_FALSE
, p_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_msg_count           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
, p_msg_data            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_project_id          IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_project_reference    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_task_id         IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_task_reference       IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--Project Structure changes done for bug 2765115
, p_structure_type              IN      VARCHAR2        := 'FINANCIAL'
, p_task_version_id     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--END Project Structure changes done for bug 2765115
, p_delete_task_ok_flag     OUT NOCOPY VARCHAR2                ); --File.Sql.39 bug 4440895

/*#
 * This API is used to determine if a subtask can be added to a parent task.
 * @param p_api_version_number API standard version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_return_status API standard: return of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_project_id The unique identifier of the project in Oracle Projects
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system
 * @param p_task_id The reference code that uniquely identifies a task within a project in Oracle Projects
 * @param p_pm_task_reference The reference code that identifies the task in the external system
 * @param p_add_subtask_ok_flag Flag indicating whether or not a subtask can be added to this task
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Verify Subtask Addition
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:compatibility S
*/
PROCEDURE Check_Add_Subtask_OK
(p_api_version_number       IN  NUMBER
,p_init_msg_list        IN  VARCHAR2    := FND_API.G_FALSE
, p_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_msg_count           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
, p_msg_data            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_project_id          IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_project_reference    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_task_id         IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_task_reference       IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_add_subtask_ok_flag     OUT NOCOPY VARCHAR2                ); --File.Sql.39 bug 4440895

/*#
 * This API is used to determine if a new or changed task reference (PM_TASK_REFERENCE) is unique.
 * @param p_api_version_number API standard version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_return_status API standard: return of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_project_id The unique identifier of the project in Oracle Projects
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system
 * @param p_pm_task_reference The reference code that identifies the task in the external system
 * @rep:paraminfo {@rep:required}
 * @param p_unique_task_ref_flag Flag indicating whether or not a subtask can be added to this task
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Verify Task Reference Uniqueness
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:compatibility S
*/
PROCEDURE Check_Unique_Task_Reference
(p_api_version_number       IN  NUMBER
, p_init_msg_list       IN  VARCHAR2    := FND_API.G_FALSE
, p_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_msg_count           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
, p_msg_data            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_project_id          IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_project_reference    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_pm_task_reference       IN  VARCHAR2
, p_unique_task_ref_flag    OUT NOCOPY VARCHAR2                ); --File.Sql.39 bug 4440895

/*#
 * This API is used to determine if a new or changed project reference(PM_PROJECT_REFERENCE) is unique.
 * @param p_api_version_number API standard version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_return_status API standard: return of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system
 * @rep:paraminfo {@rep:required}
 * @param p_unique_project_ref_flag Flag indicating whether or not this project reference is unique in Oracle Projects
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Verify Project Reference Uniqueness
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:compatibility S
*/
PROCEDURE Check_Unique_Project_Reference
(p_api_version_number       IN  NUMBER
, p_init_msg_list       IN  VARCHAR2    := FND_API.G_FALSE
, p_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_msg_count           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
, p_msg_data            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_pm_project_reference    IN  VARCHAR2
, p_unique_project_ref_flag OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

/*#
 * This API is used to determine if you can delete a project.
 * @param p_api_version_number API standard version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_return_status API standard: return of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_project_id The unique identifier of the project in Oracle Projects
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system
 * @param p_delete_project_ok_flag Flag indicating whether or not the project can be deleted
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Validate Project Deletion
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:compatibility S
*/
PROCEDURE Check_Delete_Project_OK
(p_api_version_number       IN  NUMBER
, p_init_msg_list       IN  VARCHAR2    := FND_API.G_FALSE
, p_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_msg_count           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
, p_msg_data            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_project_id          IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_project_reference    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_delete_project_ok_flag  OUT NOCOPY VARCHAR2                ); --File.Sql.39 bug 4440895

/*#
 * This API is used to determine if you can move a task from one parent task to another. You
 * can move a task as long as it retains the same top task
 * @param p_api_version_number API standard version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_return_status API standard: return of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_project_id The unique identifier of the project in Oracle Projects
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system
 * @param p_task_id The reference code that uniquely identifies a task within a project in Oracle Projects
 * @param p_pm_task_reference The reference code that identifies the task in the external system
 * @param p_new_parent_task_id The Oracle Projects identification code of the new parent task
 * @param p_pm_new_parent_task_reference The external system reference code of the new parent task
 * @param p_change_parent_ok_flag Flag indicating whether or not this task can be assigned to a new parent task
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Verify Parent Change
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:compatibility S
*/
PROCEDURE Check_Change_Parent_OK
(p_api_version_number        IN NUMBER
, p_init_msg_list        IN VARCHAR2    := FND_API.G_FALSE
, p_return_status        OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_msg_count            OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
, p_msg_data             OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_project_id           IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_project_reference     IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_task_id          IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_task_reference        IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_new_parent_task_id       IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_new_parent_task_reference IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_change_parent_ok_flag    OUT    NOCOPY VARCHAR2                ); --File.Sql.39 bug 4440895

/*#
 * This API is used to determine if you can change the CARRYING_OUT_ORGANIZATION_ID field for a particular project or task.
 * @param p_api_version_number API standard version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_return_status API standard: return of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_project_id The unique identifier of the project in Oracle Projects
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system
 * @param p_change_project_org_ok_flag The reference code that uniquely identifies a task within a project in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Validate Project Organization Change
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:compatibility S
*/
PROCEDURE Check_Change_Project_Org_OK
(p_api_version_number       IN  NUMBER
, p_init_msg_list       IN  VARCHAR2    := FND_API.G_FALSE
, p_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_msg_count           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
, p_msg_data            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_project_id          IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_project_reference    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_change_project_org_ok_flag  OUT NOCOPY VARCHAR2                ); --File.Sql.39 bug 4440895

/*#
 * This API is used to determine if a new or changed task number is unique within a project.
 * @param p_api_version_number API standard version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_return_status API standard: return of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_project_id The unique identifier of the project in Oracle Projects
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system
 * @param p_task_number The number that identifies the task in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_unique_task_number_flag Flag indicating whether or not this task number is unique in the project within Oracle Projects
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Verify Task Number Uniqueness
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:compatibility S
*/
PROCEDURE Check_Unique_Task_Number
(p_api_version_number       IN  NUMBER
, p_init_msg_list       IN  VARCHAR2    := FND_API.G_FALSE
, p_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_msg_count           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
, p_msg_data            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_project_id          IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_project_reference    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_task_number         IN  VARCHAR2
, p_unique_task_number_flag OUT NOCOPY VARCHAR2                ); --File.Sql.39 bug 4440895

/*#
 * This API is used to determine if you can change a tasks number.
 * @param p_api_version_number API standard version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_return_status API standard: return of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_project_id The unique identifier of the project in Oracle Projects
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system
 * @param p_task_id The reference code that uniquely identifies a task within a project in Oracle Projects
 * @param p_pm_task_reference The reference code that identifies the task in the external system
 * @param p_task_number_change_Ok_flag Flag indicating whether or not the task number can be changed
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Verify Task Number Change
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:compatibility S
*/
PROCEDURE Check_Task_Number_Change_Ok
( p_api_version_number      IN  NUMBER
, p_init_msg_list       IN  VARCHAR2    := FND_API.G_FALSE
, p_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_msg_count           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
, p_msg_data            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_project_id          IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_project_reference    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_task_id         IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_task_reference       IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_task_number_change_Ok_flag  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

/*#
 * This API procedure pushes project and task information from your external system to Oracle Projects to reflect any
 * changes you have made in the external system.
 * @param p_api_version_number API standard version number
 * @param p_commit API standard (default = F): indicates if transaction will be committed
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_workflow_started Flag indicating whether a workflow has been started
 * @rep:paraminfo {@rep:required}
 * @param p_pm_product_code Identifier of the external system from which the project was imported
 * @rep:paraminfo {@rep:precision 25}
 * @param p_op_validate_flag Indicates whether the system performs scheduling validations.
 * @rep:paraminfo {@rep:precision 1}
 * @param p_project_in Input project details
 * @rep:paraminfo {@rep:required}
 * @param p_project_out Output project details
 * @rep:paraminfo {@rep:required}
 * @param p_customers_in Input customer details
 * @param p_key_members The identifier for the role that the members have on the project
 * @rep:paraminfo {@rep:required}
 * @param p_class_categories Identifier of the the categories by which the project is classified
 * @rep:paraminfo {@rep:required}
 * @param p_tasks_in  Input task details of the project
 * @rep:paraminfo {@rep:required}
 * @param p_tasks_out Output task details of the project
 * @rep:paraminfo {@rep:required}
 * @param p_org_roles Identifier of the organization roles for project
 * @param p_structure_in Identifier of structure data
 * @param p_ext_attr_tbl_in Table of external attributes
 * @param p_pass_entire_structure Flag indicating whether to pass entire structure.If you use the UPDATE_PROJECT API to
 * update structure tasks, and the financial and workplan
 * structures are either shared or split, this parameter
 * enables updates in one structure to pass to the
 * other structure.This enables you to take advantage
 * of bulk processing. When workplan and financial
 * structures are shared or split, this parameter
 * needs to be passed as 'Y.' When this happens, the
 * entire structure needs to be passed. Default = 'N'
 * @rep:paraminfo {@rep:precision 1}
 * @param p_deliverables_in Input deliverable details
 * @param p_deliverable_actions_in Input deliverable action details
 * @param p_update_mode This parameter can have the following
 * two values: PA_TASKS or PA_STRUCTURES. The default value is
 * PA_STRUCTURES. If the value is PA_TASKS, other users can update
 * task attributes in the structure at one time. (This excludes
 * the ability to update task-level deliverable attributes and task
 * attachments.) If the value is PA_STRUCTURES, the structure version
 * is locked during updates so that no other user can perform changes
 * to the structure.
 * @rep:paraminfo {@rep:precision 20}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Project
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:category BUSINESS_ENTITY PA_PROJ_DELIVERABLE
 * @rep:compatibility S
*/
PROCEDURE update_project
( p_api_version_number      IN  NUMBER      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit                  IN  VARCHAR2    := FND_API.G_FALSE
 ,p_init_msg_list           IN  VARCHAR2    := FND_API.G_FALSE
 ,p_msg_count              OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_msg_data               OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_return_status          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_workflow_started       OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_pm_product_code         IN  VARCHAR2
 ,p_op_validate_flag        IN VARCHAR2     := 'Y' --added by rtarway 4218977
 ,p_project_in              IN  pa_project_pub.project_in_rec_type
 ,p_project_out            OUT NOCOPY  pa_project_pub.project_out_rec_type /*added the nocopy check for bug 2674619*/
 /* Added for tracking bug - add customers */
 ,p_customers_in     IN  pa_project_pub.customer_tbl_type := G_customers_in_tbl
/*added default values for p_key_members and p_class_categories 3683732*/
 ,p_key_members             IN  pa_project_pub.project_role_tbl_type := G_key_members_in_tbl
 ,p_class_categories        IN  pa_project_pub.class_category_tbl_type := G_class_categories_in_tbl
 ,p_tasks_in                IN  pa_project_pub.task_in_tbl_type
 ,p_tasks_out              OUT NOCOPY  pa_project_pub.task_out_tbl_type /*added the nocopy check for bug 2674619*/
-- anlee org role changes
 ,p_org_roles               IN  pa_project_pub.project_role_tbl_type := G_org_roles_in_tbl
--project structures
 ,p_structure_in            IN      structure_in_rec_type := G_structure_in_rec
 ,p_ext_attr_tbl_in         IN   PA_EXT_ATTR_TABLE_TYPE := G_ext_attr_in_tbl
-- ,p_structure_out               OUT     structure_out_rec_type
 ,p_pass_entire_structure       IN      VARCHAR2 := 'N'  -- bug 3548473 : BUg 3627124
--project structures
--3435905 FP M : deliverables
 ,p_deliverables_in         IN  deliverable_in_tbl_type := G_deliverables_in_tbl -- 3435905 passing default
-- ,p_deliverables_out          OUT NOCOPY  deliverable_out_tbl_type -- 3435905 removed out parameter
 ,p_deliverable_actions_in  IN  action_in_tbl_type := G_deliverable_actions_in_tbl -- 3435905 passing default
-- ,p_deliverable_actions_out   OUT NOCOPY  action_out_tbl_type -- 3435905 removed out parameter
--3435905 FP M : deliverables
 ,p_update_mode             in varchar2 := 'PA_UPD_WBS_ATTR' --DHI ER, BUG 4413568   --bug4534919
);

/*#
 * This API is used to update existing tasks of a project in Oracle Projects.
 * @param p_api_version_number API standard version number
 * @param p_commit API standard (default = F): indicates if transaction will be committed
 * @rep:paraminfo {@rep:precision 1}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_ref_task_id  The reference code that uniquely identifies the reference to a task within a project in Oracle Projects
 * @param p_pm_product_code Identifier of the external system from which the project was imported
 * @rep:paraminfo {@rep:precision 25}
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system
 * @param p_pa_project_id The reference code that uniquely identifies the project in the Oracle Projects
 * @param p_pm_task_reference  The reference code that uniquely identifies project's task in the external system
 * @param p_task_number The number that identifies the task in Oracle Projects
 * @rep:paraminfo {@rep:precision 25} {@rep:required}
 * @param p_pa_task_id  The reference code that uniquely identifies the task within a project in Oracle Projects
 * @param p_task_name The name that uniquely identifies the task within a project
 * @param p_long_task_name  Long name of the task
 * @param p_task_description Description of the task
 * @param p_task_start_date The start date of the task
 * @param p_task_completion_date The completion date of the task
 * @param p_pm_parent_task_reference The unique reference code that identifies the task's parent task
 * @param p_pa_parent_task_id The identifier of task's parent task in Oracle Projects
 * @param p_address_id The address of one of the customers that is logically linked to this task
 * @param p_carrying_out_organization_id The identifier of the organization that is responsible for the project work
 * @param p_service_type_code The type of work performed on the task
 * @param p_task_manager_person_id The identifier of the employee who manages the task
 * @param p_billable_flag Flag indicating whether items charged to the task can accrue revenue
 * @rep:paraminfo {@rep:precision 1}
 * @param p_chargeable_flag Flag indicating whether expenditure items can be charged to the task. Only lowest level tasks can be chargeable
 * @rep:paraminfo {@rep:precision 1}
 * @param p_ready_to_bill_flag Flag indicating whether the task is authorized to be invoiced
 * @rep:paraminfo {@rep:precision 1}
 * @param p_ready_to_distribute_flag Flag indicating whether the task is authorized for revenue accrual
 * @rep:paraminfo {@rep:precision 1}
 * @param p_limit_to_txn_controls_flag Flag indicating whether users can only charge expenditures to
 * the tasks that are listed in task transaction controls
 * @rep:paraminfo {@rep:precision 1}
 * @param p_labor_bill_rate_org_id  The identifier of the organization that owns the labor standard bill rate schedule
 * @param p_labor_std_bill_rate_schdl The labor standard bill rate schedule that is used to calculate revenue for labor
 * expenditure items charged to the task
 * @param p_labor_schedule_fixed_date The date used to determine the effective bill rates of the task standard labor bill rate schedule
 * @param p_labor_schedule_discount The discount percent for the task standard labor bill rate schedule
 * @param p_nl_bill_rate_org_id The identifier of the organization that owns the non-labor standard bill rate schedule
 * @param p_nl_std_bill_rate_schdl The non-labor standard bill rate schedule that is used to calculate revenue for non-labor
 * expenditure items charged to the task
 * @param p_nl_schedule_fixed_date The fixed date used to determine the effective bill rates of the standard non-labor bill rate schedule
 * @param p_nl_schedule_discount The discount percent for the task standard non-labor bill rate schedule
 * @param p_labor_cost_multiplier_name The labor cost multiplier defined for the task of a premium project
 * @param p_cost_ind_rate_sch_id The identifier of the default costing burden schedule
 * @param p_rev_ind_rate_sch_id The identifier of the default revenue burden schedule
 * @param p_inv_ind_rate_sch_id The identifier of the default invoice burden schedule
 * @param p_cost_ind_sch_fixed_date The schedule fixed date of the firm costing burden schedule
 * @param p_rev_ind_sch_fixed_date The schedule fixed date of the firm revenue burden schedule
 * @param p_inv_ind_sch_fixed_date The schedule fixed date of the firm invoice burden schedule
 * @param p_labor_sch_type The schedule type of labor expenditure items
 * @param p_nl_sch_type The schedule type of non-labor expenditure items
 * @param p_actual_start_date The actual start date of the project
 * @param p_actual_finish_date The actual end date of the project. Applicable only for a project that originated in an external system.
 * @param p_early_start_date The early start date of the project. Applicable only for a project that originated in an external system.
 * @param p_early_finish_date The early finish date of the project. Applicable only for a project that originated in an external system.
 * @param p_late_start_date The late start date of the project. Applicable only for a project that originated in an external system.
 * @param p_late_finish_date The late finish date of the project. Applicable only for a project that originated in an external system.
 * @param p_scheduled_start_date The scheduled start date of the project
 * @param p_scheduled_finish_date The scheduled finish date of the project
 * @param p_attribute_category Descriptive flexfield category
 * @param p_attribute1 Identifies Descriptive flexfield
 * @param p_attribute2 Identifies Descriptive flexfield
 * @param p_attribute3 Identifies Descriptive flexfield
 * @param p_attribute4 Identifies Descriptive flexfield
 * @param p_attribute5 Identifies Descriptive flexfield
 * @param p_attribute6 Identifies Descriptive flexfield
 * @param p_attribute7 Identifies Descriptive flexfield
 * @param p_attribute8 Identifies Descriptive flexfield
 * @param p_attribute9 Identifies Descriptive flexfield
 * @param p_attribute10 Identifies Descriptive flexfield
 * @param p_allow_cross_charge_flag Flag indicating whether cross charges are allowed
 * @param p_project_rate_date Task-level default value for project rate date
 * @param p_project_rate_type Task-level default value for project rate type
 * @param p_cc_process_labor_flag Flag indicating whether cross charge processing is to be performed for labor transactions charged
 * to the project. The default value for the project template is N. The default value for a project is the value on the project template.
 * The default value for a task is the value on the project.
 * @rep:paraminfo {@rep:precision 1}
 * @param p_labor_tp_schedule_id Identifier of the transfer price schedule to use for cross charged labor transactions. The default value
 * for a project is the value on the project template. The default value for a task is the value on the project. If cc_process_labor_flag is
 * set to Y, this field is required.
 * @param p_labor_tp_fixed_date Fixed date to find the effective rate of the bill rate or burden schedule when determining the transfer price
 * for labor transactions. The default value for a project is the value on the project template. The default value for a task is the value on
 * the project.
 * @param p_cc_process_nl_flag Flag indicating whether cross charge processing is to be performed for non-labor transactions charged to the project.
 * The default value for the project template is N. The default value for a project is the value on the project template. The default value for a
 * task is the value on the project.
 * @rep:paraminfo {@rep:precision 1}
 * @param p_nl_tp_schedule_id Identifier of the transfer price schedule to use for cross charged non-labor transactions. The default value for a
 * project is the value on the project template. The default value for a task is the value on the project. If cc_process_nl_flag is set to Y,
 * this field is required.
 * @param p_nl_tp_fixed_date Fixed date to find the effective rate of the bill rate or burden schedule when determining the transfer price for
 * non-labor transactions. The default value for a project is the value on the project template. The default value for a task is the value on the project.
 * @param p_receive_project_invoice_flag Flag indicating whether the task can receive charges from internal supplies using inter project billing
 * @rep:paraminfo {@rep:precision 1}
 * @param p_work_type_id Identifier of the work type
 * @param p_emp_bill_rate_schedule_id Identifier of the employee bill rate schedule
 * @param p_job_bill_rate_schedule_id Identifier of the job bill rate schedule
 * @param p_non_lab_std_bill_rt_sch_id Identifier of the non-labor standard bill rate schedule
 * @param p_taskfunc_cost_rate_type Task-level default value for project functional cost rate type
 * @param p_taskfunc_cost_rate_date Task-level default value for project functional cost rate date
 * @param p_structure_type  Identifier of the project structure type
 * @param p_structure_version_id Identifier of the structure version.
 * @param P_OBLIGATION_START_DATE The obligation start date of the workplan version
 * @param P_OBLIGATION_FINISH_DATE The obligation finish date of the workplan version
 * @param P_ESTIMATED_START_DATE The estimated start date of the workplan version
 * @param P_ESTIMATED_FINISH_DATE The estimated finish date of the workplan version
 * @param P_BASELINE_START_DATE Baseline start date for the task or the workplan
 * @param P_BASELINE_FINISH_DATE Baseline finish date for the task or the workplan
 * @param P_CLOSED_DATE The date that the element status was set to Closed. This is a task-specific attribute.
 * @param P_WQ_UOM_CODE The unit of measure used for work quantity for a task
 * @param P_WQ_ITEM_CODE The work item for work quantity for a task
 * @param P_STATUS_CODE The status of the project element
 * @param P_WF_STATUS_CODE  The status of workflow associated with the element
 * @param P_PM_SOURCE_CODE Identifier of the the source code system
 * @param P_PRIORITY_CODE The priority of the task. This is a task-specific attribute.
 * @param P_MILESTONE_FLAG  Flag indicating whether the task version is a milestone. This is a task-specific attribute.
 * @param P_CRITICAL_FLAG Flag indicating whether the task version is part of the critical path
 * @param P_INC_PROJ_PROGRESS_FLAG Project progress flag
 * @param P_LINK_TASK_FLAG  Flag indicating whether a task is used for linking purposes and is therefore not displayed in the user interface
 * @param P_CALENDAR_ID The identifier of the work calendar used to schedule the task. This is a task-specific attribute.
 * @param P_PLANNED_EFFORT The planned effort for the task
 * @param P_DURATION The number of days between scheduled start date and scheduled end date using the work calendar
 * @param P_PLANNED_WORK_QUANTITY The planned work quantity for the task
 * @param P_TASK_TYPE The task type
 * @param p_labor_disc_reason_code Labor discount reason code
 * @param p_non_labor_disc_reason_code Non-labor discount reason code
 * @param p_retirement_cost_flag Flag indicating whether the task is identified for retirement cost collection.
 * @rep:paraminfo  {@rep:precision 1}
 * @param p_cint_eligible_flag Flag indicating whether the project is eligible for capitalized interest
 * @rep:paraminfo  {@rep:precision 1}
 * @param p_cint_stop_date  Stop date for capital interest calculation
 * @param p_out_pa_task_id Identifier of the output task
 * @rep:paraminfo  {@rep:required}
 * @param p_out_pm_task_reference Unique identifier for the task in the external system
 * @rep:paraminfo  {@rep:required}
 * @param p_update_task_structure Task structure
 * @param p_process_mode Processing mode
 * @param p_pred_string The string containing the predecessors information
 * @rep:paraminfo {@rep:precision 400} {@rep:required}
 * @param p_pred_delimiter Delimiter that separates predecessor in the predecessor string
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_base_percent_comp_deriv_code Base percent complete derivation code for the task
 * @rep:paraminfo {@rep:precision 30} {@rep:required}
 * @param p_sch_tool_tsk_type_code Default scheduling tool task type for the task version
 * @rep:paraminfo {@rep:precision 30} {@rep:required}
 * @param p_constraint_type_code Constraint type for the task version
 * @rep:paraminfo {@rep:precision 30} {@rep:required}
 * @param p_constraint_date Constraint date for the task version
 * @rep:paraminfo {@rep:required}
 * @param p_free_slack Free slack for the task version
 * @rep:paraminfo {@rep:required}
 * @param p_total_slack Total slack for task version
 * @rep:paraminfo {@rep:required}
 * @param p_effort_driven_flag The flag that indicates whether the task is effort driven
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_level_assignments_flag Flag that indicates whether the assignments
 * on this task should be leveled
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_invoice_method The invoice method for the task. This parameter is valid only if invoice
 * method at top task is enabled.
 * @rep:paraminfo {@rep:precision 30} {@rep:required}
 * @param p_customer_id The customer for the task. This parameter is valid only if customer at top task is enabled.
 * @rep:paraminfo {@rep:required}
 * @param p_gen_etc_source_code Estimate to complete source
 * @rep:paraminfo {@rep:precision 30} {@rep:required}
 * @param p_financial_task_flag The flag that indicates
 * whether the task is a financial task or not. This flag
 * is valid only for partially shared structures. Tasks
 * that are above this level are used for financial management.
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_mapped_task_id Mapped task ID. This is parameter only in case of split-mapped structure
 * sharing between workplan and financial structures.
 * @rep:paraminfo {@rep:required}
 * @param p_mapped_task_reference Mapped task reference
 * @rep:paraminfo {@rep:required}
 * @param p_deliverable Deliverable reference to be associated with the task
 * @rep:paraminfo {@rep:precision 4000}
 * @param p_ext_act_duration From the external application, the actual duration
 * @rep:paraminfo {@rep:required}
 * @param p_ext_remain_duration From the external application, the remaining duration
 * @rep:paraminfo {@rep:required}
 * @param p_ext_sch_duration From the external application, the scheduled duration
 * @rep:paraminfo {@rep:required}
 * @param p_etc_effort Estimated remaining effort for the task
 * @rep:paraminfo {@rep:required}
 * @param p_percent_complete Percentage of work complete on the task
 * @rep:paraminfo {@rep:required}
 * @param p_is_wp_seperate_from_fn Flag that indicates whether Workplan structure is shared with financial structure or not. Default='X'
 * @param p_calling_api The calling API name. (Default = 'UPDATE_TASK')
 * @param p_op_validate_flag Flag indicating whether the system performs scheduling validations. Default is Y.
 * @rep:paraminfo {@rep:precision 1}
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Task
 * @rep:compatibility S
*/
PROCEDURE update_task
( p_api_version_number               IN NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_commit                        IN    VARCHAR2    := FND_API.G_FALSE,
  p_init_msg_list                     IN    VARCHAR2    := FND_API.G_FALSE,
  p_msg_count                         OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
  p_msg_data                          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  p_return_status                     OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
--Project Structures
  p_ref_task_id                         IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
--Project Structures
  p_pm_product_code                   IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_pm_project_reference            IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_pa_project_id                   IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_pm_task_reference               IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_task_number                     IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_pa_task_id                      IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_task_name                       IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_long_task_name                      IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_task_description                IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_task_start_date                 IN DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_task_completion_date            IN DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_pm_parent_task_reference        IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_pa_parent_task_id                IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_address_id                        IN NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_carrying_out_organization_id    IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_service_type_code               IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_task_manager_person_id          IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_billable_flag                   IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_chargeable_flag                 IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_ready_to_bill_flag              IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_ready_to_distribute_flag        IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_limit_to_txn_controls_flag      IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_labor_bill_rate_org_id          IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_labor_std_bill_rate_schdl       IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_labor_schedule_fixed_date       IN DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_labor_schedule_discount         IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_nl_bill_rate_org_id             IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_nl_std_bill_rate_schdl          IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_nl_schedule_fixed_date          IN DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_nl_schedule_discount            IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_labor_cost_multiplier_name      IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_cost_ind_rate_sch_id            IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_rev_ind_rate_sch_id             IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_inv_ind_rate_sch_id             IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_cost_ind_sch_fixed_date         IN DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_rev_ind_sch_fixed_date          IN DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_inv_ind_sch_fixed_date          IN DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_labor_sch_type                  IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_nl_sch_type                     IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_actual_start_date                   IN DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_actual_finish_date                  IN DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_early_start_date                    IN DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_early_finish_date                   IN DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_late_start_date                     IN DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_late_finish_date                    IN DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_scheduled_start_date                IN DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_scheduled_finish_date               IN DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_tasks_dff                           IN VARCHAR2    := 'N',  --bug 6153503
  p_attribute_category               IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_attribute1                        IN VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_attribute2                        IN VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_attribute3                        IN VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_attribute4                        IN VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_attribute5                        IN VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_attribute6                        IN VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_attribute7                        IN VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_attribute8                        IN VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_attribute9                        IN VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_attribute10                  IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  --bug 6153503
  p_attribute11                        IN VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_attribute12                        IN VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_attribute13                        IN VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_attribute14                        IN VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_attribute15                        IN VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  --end bug 6153503
  p_allow_cross_charge_flag             IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_project_rate_date                   IN DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_project_rate_type                   IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_cc_process_labor_flag               IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_labor_tp_schedule_id                IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_labor_tp_fixed_date                 IN DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_cc_process_nl_flag                  IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_nl_tp_schedule_id                   IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_nl_tp_fixed_date                    IN DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_receive_project_invoice_flag        IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_work_type_id                        IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_emp_bill_rate_schedule_id           IN NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_job_bill_rate_schedule_id           IN NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
--Sakthi  MCB
 p_non_lab_std_bill_rt_sch_id           IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_taskfunc_cost_rate_type              IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_taskfunc_cost_rate_date              IN DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
--Sakthi  MCB
--Project Structures
 p_structure_type                     IN VARCHAR2 := 'FINANCIAL',
 p_structure_version_id               IN NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 P_OBLIGATION_START_DATE              IN DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 P_OBLIGATION_FINISH_DATE             IN DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 P_ESTIMATED_START_DATE               IN DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 P_ESTIMATED_FINISH_DATE              IN DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 P_BASELINE_START_DATE                IN DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 P_BASELINE_FINISH_DATE               IN DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 P_CLOSED_DATE                        IN DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 P_WQ_UOM_CODE                        IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 P_WQ_ITEM_CODE                       IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 P_STATUS_CODE                        IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 P_WF_STATUS_CODE                     IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 P_PM_SOURCE_CODE                     IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 P_PRIORITY_CODE                      IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 P_MILESTONE_FLAG                     IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 P_CRITICAL_FLAG                      IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 P_INC_PROJ_PROGRESS_FLAG             IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 P_LINK_TASK_FLAG                     IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 P_CALENDAR_ID                        IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 P_PLANNED_EFFORT                     IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 P_DURATION                           IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 P_PLANNED_WORK_QUANTITY              IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 P_TASK_TYPE                          IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
--Project Structures
 p_labor_disc_reason_code       IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_non_labor_disc_reason_code   IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
--PA L changes -- bug 2872708  --update_task
 p_retirement_cost_flag          VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_cint_eligible_flag            VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_cint_stop_date                DATE         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
--end PA L changes -- bug 2872708
  p_out_pa_task_id               OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  p_out_pm_task_reference        OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  p_update_task_structure        IN      VARCHAR2  := 'Y'         -- Added new parameter for performance changes. Bug 2931183
  -- PA L Changes 3010538
 ,p_process_mode                 IN VARCHAR2 := 'ONLINE'
-- FP-M Bug # 3301192
 ,p_pred_string                  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- ,p_pred_delimiter               VARCHAR2    DEFAULT ','
 ,p_pred_delimiter               VARCHAR2   :=  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- FP M changes begin (venkat)
  ,p_base_percent_comp_deriv_code   IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_sch_tool_tsk_type_code IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_constraint_type_code       IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_constraint_date            IN DATE   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,p_free_slack             IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_total_slack                 IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_effort_driven_flag         IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_level_assignments_flag     IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_invoice_method              IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_customer_id                 IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_gen_etc_source_code             IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- FP M changes end (venkat)
-- FP M changes start (Mapping )
  ,p_financial_task_flag           IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_mapped_task_id                IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_mapped_task_reference         IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- FP M changes end (Mapping )
 ,p_deliverable                 IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR   --3435905
-- (Begin venkat) Bug #3450684 --------------------------------------------------------------------
  ,p_ext_act_duration            IN NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_ext_remain_duration         IN NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_ext_sch_duration            IN NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- (End venkat) Bug #3450684 --------------------------------------------------------------------

-- Progress Management Changes. Bug # 3420093.
  ,p_etc_effort                 IN NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_percent_complete           IN NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- Progress Management Changes. Bug # 3420093.
  ,p_is_wp_seperate_from_fn      IN VARCHAR2 := 'X'   -- Added for Bug # 3451073
  ,p_calling_api      IN VARCHAR2 := 'UPDATE_TASK'   -- Added for Bug # 4199694
  ,p_op_validate_flag        IN VARCHAR2     := 'Y' --added by rtarway 4218977
);

/*#
 * This API procedure is used to update an existing project, including changing or adding project data,
 * adding new tasks, and updating existing tasks. This API does not delete tasks; rather, it uses the
 * data stored in the global tables during the Load process.
 * In order to execute this API the following list of API's should be executed in the following order.
 * INIT_PROJECT,
 * LOAD_PROJECT,
 * LOAD_TASK,
 * LOAD_CLASS_CATEGORY,
 * LOAD_KEY_MEMBER,
 * EXECUTE_CREATE_PROJECT/EXECUTE_UPDATE_PROJECT,
 * FETCH_TASK and
 * CLEAR_PROJECT
 * @param p_api_version_number API standard version number
 * @param p_commit API standard (default = F): indicates if transaction will be committed
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_op_validate_flag Indicates whether the system performs scheduling validations. Default is Y.
 * @rep:paraminfo {@rep:precision 1}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_workflow_started Indicates if a workflow has been started (Y or N)
 * @rep:paraminfo {@rep:required}
 * @param p_pm_product_code Identifier of the external system from which the project was imported
 * @rep:paraminfo {@rep:precision 25}
 * @param p_pass_entire_structure In situations where structures are completely shared,
 * this parameter enables updates to one structure to pass to the other structure(s). Default = 'N'.
 * @rep:paraminfo {@rep:precision 1}
 * @param p_update_mode Update mode. This parameter can have the following two
 * values:PA_TASKS or PA_STRUCTURES. The default value is PA_STRUCTURES.
 * If the value is PA_TASKS, other users can update task attributes in the
 * structure at one time. (This excludes the ability to update
 * task-level deliverable attributes and task attachments). If the value is
 * PA_STRUCTURES, the structure version is locked during updates
 * so that no other user can perform changes to the structure.
 * @rep:paraminfo {@rep:precision 20}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Multiple Projects: Execute Update Project
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:category BUSINESS_ENTITY PA_PROJ_DELIVERABLE
 * @rep:compatibility S
*/
PROCEDURE execute_update_project
( p_api_version_number          IN NUMBER       :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit                   IN VARCHAR2    := FND_API.G_FALSE
 ,p_init_msg_list                IN VARCHAR2    := FND_API.G_FALSE
 ,p_op_validate_flag  IN VARCHAR2 := 'Y'--added by rtarway, bug 4218977
 ,p_msg_count                    OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_msg_data                     OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_return_status                OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_workflow_started             OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_pm_product_code                IN   VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pass_entire_structure       IN      VARCHAR2 := 'N' -- Added for bug 3696234 : Bug 3627124
 ,p_update_mode                 IN VARCHAR2      := 'PA_UPD_WBS_ATTR'--DHI ER BUG 4413568 --bug 4534919
 );

/*#
 * This API procedure is used to delete a project and its tasks from Oracle Projects.
 * @param p_api_version_number API standard version number
 * @param p_commit API standard (default = F): indicates if transaction will be committed
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_pm_product_code Identifier of the external system from which the project was imported
 * @rep:paraminfo {@rep:precision 25}
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system
 * @param p_pa_project_id The unique identifier of the project in Oracle Projects
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Project
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:compatibility S
*/
PROCEDURE delete_project
( p_api_version_number  IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit          IN  VARCHAR2    := FND_API.G_FALSE
 ,p_init_msg_list       IN  VARCHAR2    := FND_API.G_FALSE
 ,p_msg_count           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_msg_data            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_pm_product_code     IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pm_project_reference    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id       IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM     );


PROCEDURE approve_project
( p_api_version_number  IN  NUMBER
 ,p_commit          IN  VARCHAR2    := FND_API.G_FALSE
 ,p_init_msg_list       IN  VARCHAR2    := FND_API.G_FALSE
 ,p_msg_count           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_msg_data            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_pm_product_code     IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pm_project_reference    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id       IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM     );


/*#
 * This is a Load-Execute-Fetch procedure used to load tasks to a global
 * PL/SQL table.
 * In order to execute this API,the following list of API's should be executed in the following order.:
 * INIT_PROJECT,
 * LOAD_PROJECT,
 * LOAD_TASKS,
 * LOAD_CLASS_CATEGORY,
 * LOAD_KEY_MEMBER,
 * EXECUTE_CREATE_PROJECT/EXECUTE_UPDATE_PROJECT,
 * FETCH_TASK and
 * CLEAR_PROJECT
 * @param p_api_version_number API standard: version number
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_pm_task_reference  The reference code that uniquely identifies the project task in the external system
 * @param p_pa_task_id The reference code that uniquely identifies the task in a project in Oracle Projects
 * @param p_task_name The name that uniquely identifies a task in a project
 * @param p_long_task_name The long name of a task
 * @param p_pa_task_number The number that indicates the task in the Oracle Projects
 * @param p_task_description Description of the task
 * @param p_task_start_date The date on which the task starts
 * @param p_task_completion_date The date on which the task is completed
 * @param p_pm_parent_task_reference The unique reference code that identifies the task's parent task
 * @param p_pa_parent_task_id Identifier of the task's parent task in Oracle Projects
 * @param p_address_id The address identifier of one of the customers that is logically linked to this task
 * @param p_carrying_out_organization_id The identifier of the organization that is responsible for the project work
 * @param p_service_type_code The type of work performed on the task
 * @param p_task_manager_person_id The identifier of the employee who manages the task
 * @param p_billable_flag Default flag for items charged to the task that indicates whether the item can accrue revenue (Y or N)
 * @rep:paraminfo {@rep:precision 1}
 * @param p_chargeable_flag Flag that indicates if expenditure items can be charged to the task. Only lowest tasks can be charged
 * @rep:paraminfo {@rep:precision 1}
 * @param p_ready_to_bill_flag Flag that indicates if the task is authorized to be invoiced
 * @rep:paraminfo {@rep:precision 1}
 * @param p_ready_to_distribute_flag Flag that indicates if the task is authorized for revenue accrual
 * @rep:paraminfo {@rep:precision 1}
 * @param p_limit_to_txn_controls_flag Flag that indicates if users can only charge expenditures to the task that are listed in
 * task transaction controls
 * @rep:paraminfo {@rep:precision 1}
 * @param p_labor_bill_rate_org_id  The identifier of the organization that owns the labor standard bill rate schedule
 * @param p_labor_std_bill_rate_schdl The labor standard bill rate schedule that is used to calculate revenue for labor expenditure
 * items charged to the task
 * @param p_labor_schedule_fixed_date The date used to determine the effective bill rates of the task standard labor bill rate schedule.
 * @param p_labor_schedule_discount The percentage to be discounted from the task standard labor bill rate schedule
 * @param p_nl_bill_rate_org_id The identifier of the organization that owns the non-labor standard bill rate schedule
 * @param p_nl_std_bill_rate_schdl The non-labor standard bill rate schedule that is used to calculate revenue for non-labor
 * expenditure items charged to the task
 * @param p_nl_schedule_fixed_date The fixed date used to determine the effective bill rates of the standard non-labor bill rate schedule
 * @param p_nl_schedule_discount The percentage to be discounted from the task standard non-labor bill rate schedule
 * @param p_labor_cost_multiplier_name The labor cost multiplier defined for the task of a premium project
 * @param p_cost_ind_rate_sch_id The identifier of default costing burden schedule
 * @param p_rev_ind_rate_sch_id The identifier of default revenue burden schedule
 * @param p_inv_ind_rate_sch_id The identifier of default invoice burden schedule
 * @param p_cost_ind_sch_fixed_date The schedule fixed date of firm costing burden schedule
 * @param p_rev_ind_sch_fixed_date The schedule fixed date of firm revenue burden schedule
 * @param p_inv_ind_sch_fixed_date The schedule fixed date of firm invoice burden schedule
 * @param p_labor_sch_type The schedule type of labor expenditure items
 * @param p_nl_sch_type The schedule type of non labor expenditure items
 * @param p_actual_start_date The actual start date of the project. Applicable only for a project that originated in
 * an external system.
 * @param p_actual_finish_date The actual end date of the project. Applicable only for a project that originated in
 * an external system.
 * @param p_early_start_date The early start date of the project. Applicable only for a project that originated in an external system.
 * @param p_early_finish_date The early finish date of the project. Applicable only for a project that originated in an external
 * system.
 * @param p_late_start_date The late start date of the project. Applicable only for a project that originated in an external system.
 * @param p_late_finish_date The late finish date of the project. Applicable only for a project that originated in an external system.
 * @param p_scheduled_start_date The scheduled start date of the project
 * @param p_scheduled_finish_date The scheduled finish date of the project
 * @param p_attribute_category Descriptive flexfield category
 * @param p_attribute1 Descriptive flexfield attribute
 * @param p_attribute2 Descriptive flexfield attribute
 * @param p_attribute3 Descriptive flexfield attribute
 * @param p_attribute4 Descriptive flexfield attribute
 * @param p_attribute5 Descriptive flexfield attribute
 * @param p_attribute6 Descriptive flexfield attribute
 * @param p_attribute7 Descriptive flexfield attribute
 * @param p_attribute8 Descriptive flexfield attribute
 * @param p_attribute9 Descriptive flexfield attribute
 * @param p_attribute10 Descriptive flexfield attribute
 * @param p_allow_cross_charge_flag Flag indicating if cross-charge is allowed
 * @param p_project_rate_date Task level default value for project rate date
 * @param p_project_rate_type Task level default value for project rate type
 * @param p_cc_process_labor_flag Flag that indicates if cross-charge processing is to be performed for labor
 * transactions charged to the project. The default value for the project template is N.
 * @rep:paraminfo {@rep:precision 1}
 * @param p_labor_tp_schedule_id Identifier of the transfer price schedule to use for cross-charged labor transactions.
 * If P_CC_PROCESS_LABOR_FLAG is set to Y, this field is required.
 * @param p_labor_tp_fixed_date Fixed date to find the effective rate of the bill rate or burden schedule when
 * determining the transfer price for labor transactions.
 * @param p_cc_process_nl_flag Flag that indicates if cross-charge processing is to be performed for non-labor transactions
 * charged to the project. The default value for the project template is N.
 * @rep:paraminfo {@rep:precision 1}
 * @param p_nl_tp_schedule_id Identifier of the transfer price schedule to use for cross-charged non labor transactions.
 * If P_CC_PROCESS_NL_FLAG is set to Y, this field is required.
 * @param p_nl_tp_fixed_date Fixed date to find the effective rate of the bill rate or burden schedule when determining
 * the transfer price for non-labor transactions.
 * @param p_receive_project_invoice_flag Flag that indicates if the task can receive charges from internal supplies
 * using inter-project billing
 * @rep:paraminfo {@rep:precision 1}
 * @param p_work_type_id Identifier for predefined types of work
 * @param p_emp_bill_rate_schedule_id Identifier of the employee bill rate schedule
 * @param p_job_bill_rate_schedule_id Identifier of the job bill rate schedule
 * @param p_non_lab_std_bill_rt_sch_id Identifier of the non-labor standard bill rate schedule
 * @param p_taskfunc_cost_rate_type Task level default value for project functional cost rate type
 * @param p_taskfunc_cost_rate_date Task level default value for project functional cost rate date
 * @param p_display_sequence Order of display
 * @param p_wbs_level The level of the task in the work breakdown structure
 * @param p_milestone Flag that indicates if the task version is a milestone. This is a task-specific attribute.
 * @param p_duration The duration between scheduled start date and scheduled end date using the calendar
 * @param p_duration_unit The unit of duration between scheduled start date and scheduled end date using the calendar
 * @param p_login_user_name The logged in user name
 * @param p_critical_flag Flag that indicates if the task version is part of the critical path.
 * This is a task-specific attribute.
 * @param p_sub_project_id The unique identifier of the sub project associated with the task
 * @param p_progress_status_code The progress status code
 * @param p_progress_comments Progress comments
 * @param p_progress_asof_date The cycle date on which progress information can be entered
 * @param p_progress_description Progress description
 * @param p_predecessors The predecessor for specified task. This parameter is applicable for workplan tasks.
 * @param p_priority_code The priority of the task. This is a task-specific attribute.
 * @param p_wbs_number Outline number for the task
 * @param P_ESTIMATED_START_DATE The estimated start date of the workplan version
 * @param P_ESTIMATED_FINISH_DATE The estimated finish date of the workplan version
 * @param p_estimate_to_complete Estimated time to complete the task
 * @param p_language Language in which the task details are stored
 * @param p_delimiter Delimiter that separates predecessors in the predecessor string
 * @param p_structure_version_id Unique identifier of the workplan structure
 * @param P_OBLIGATION_START_DATE The obligation start date of the workplan version
 * @param P_OBLIGATION_FINISH_DATE The obligation finish date of the workplan version
 * @param P_BASELINE_START_DATE Baseline start date for the task or the workplan
 * @param P_BASELINE_FINISH_DATE Baseline finish date for the task or the workplan
 * @param P_CLOSED_DATE The date that the element status was set to Closed. This is a task-specific attribute.
 * @param P_WQ_UOM_CODE The unit of measure used for work quantity for a task
 * @param P_WQ_ITEM_CODE The work item for work quantity for a task
 * @param P_STATUS_CODE The status of the project element.
 * @param P_WF_STATUS_CODE  The status of workflow associated with the element
 * @param P_PM_SOURCE_CODE Identifier of the source code system
 * @param P_INC_PROJ_PROGRESS_FLAG Flag indicating the project progress
 * @param P_LINK_TASK_FLAG Flag indicating whether a task is used for linking purposes and is not displayed in the user interface
 * @param P_CALENDAR_ID The identifier of the calendar used to schedule the task. This is a task-specific attribute.
 * @param P_PLANNED_EFFORT The planned effort for the task
 * @param P_PLANNED_WORK_QUANTITY The planned work quantity for the task
 * @param P_TASK_TYPE Type of task
 * @param p_labor_disc_reason_code Labor discount reason code
 * @param p_non_labor_disc_reason_code Non-labor discount reason code
 * @param p_retirement_cost_flag Flag indicating whether the task is identified for retirement cost collection
 * @rep:paraminfo  {@rep:precision 1}
 * @param p_cint_eligible_flag Flag indicating whether the project is eligible for capitalized interest
 * @rep:paraminfo  {@rep:precision 1}
 * @param p_cint_stop_date  Stop date for capital interest calculation
 * @param p_pred_string The string containing the predecessor information
 * @rep:paraminfo  {@rep:precision 400} {@rep:required}
 * @param p_pred_delimiter Delimiter that separates predecessors in the predecessor string
 * @rep:paraminfo  {@rep:precision 1} {@rep:required}
 * @param p_deliverable Deliverable reference to be associated with the task
 * @rep:paraminfo  {@rep:precision 4000}
 * @param p_deliverable_id Deliverable identifier to be associated with a task
 * @param p_base_percent_comp_deriv_code Base percent complete derivation code for the task
 * @rep:paraminfo  {@rep:precision 30} {@rep:required}
 * @param p_sch_tool_tsk_type_code Default scheduling tool task type for the task version
 * @rep:paraminfo  {@rep:precision 30} {@rep:required}
 * @param p_constraint_type_code Constraint type for the task version
 * @rep:paraminfo  {@rep:precision 30} {@rep:required}
 * @param p_constraint_date Constraint date for the task version
 * @rep:paraminfo  {@rep:required}
 * @param p_free_slack  Free slack for the task version
 * @rep:paraminfo  {@rep:required}
 * @param p_total_slack Total slack for the task version
 * @rep:paraminfo  {@rep:required}
 * @param p_effort_driven_flag Flag that indicates whether the task is effort driven
 * @rep:paraminfo  {@rep:precision 1} {@rep:required}
 * @param p_level_assignments_flag Flag that indicates whether the assignments on this task should be leveled
 * @rep:paraminfo  {@rep:precision 1} {@rep:required}
 * @param p_invoice_method The invoice method for the task. This parameter is valid only if invoice method at top task is enabled.
 * @rep:paraminfo  {@rep:precision 30} {@rep:required}
 * @param p_customer_id The customer for the task. This parameter is valid only if customer at top task is enabled.
 * @rep:paraminfo {@rep:required}
 * @param p_gen_etc_source_code Estimate to complete source
 * @rep:paraminfo {@rep:precision 30} {@rep:required}
 * @param p_financial_task_flag Flag that indicates whether the task is a financial task. This flag
 * is valid only for partially shared structures. Tasks that are above this level are used for financial management.
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_mapped_task_id Mapped task identifier. This parameter is applicable only in case of split-mapped structure
 * sharing between workplan and financial structures.
 * @rep:paraminfo {@rep:required}
 * @param p_mapped_task_reference Mapped task reference
 * @rep:paraminfo {@rep:required}
 * @param p_ext_act_duration The actual duration from the external application
 * @rep:paraminfo {@rep:required}
 * @param p_ext_remain_duration The remaining duration from the external application
 * @rep:paraminfo {@rep:required}
 * @param p_ext_sch_duration The scheduled duration from the external application
 * @rep:paraminfo {@rep:required}
 * @param p_etc_effort Estimated remaining effort for the task
 * @rep:paraminfo {@rep:required}
 * @param p_percent_complete Percentage of work complete on the task
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Load Tasks
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:compatibility S
*/
PROCEDURE load_tasks
(
   p_api_version_number     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_init_msg_list           IN VARCHAR2    := FND_API.G_FALSE
  ,p_return_status           OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,p_pm_task_reference      IN  PA_VC_1000_150
  ,p_pa_task_id               IN   PA_NUM_1000_NUM
  ,p_task_name                IN    PA_VC_1000_2000 := PA_VC_1000_2000(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) -- bug 6193314 .modified from PA_VC_1000_150
  ,p_long_task_name           IN   PA_VC_1000_2000 := PA_VC_1000_2000(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  ,p_pa_task_number           IN    PA_VC_1000_150 := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  ,p_task_description       IN  PA_VC_1000_2000 := PA_VC_1000_2000(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  ,p_task_start_date         IN PA_DATE_1000_DATE := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
  ,p_task_completion_date   IN  PA_DATE_1000_DATE := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
  ,p_pm_parent_task_reference   IN  PA_VC_1000_150 := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  ,p_pa_parent_task_id      IN  PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  ,p_address_id         IN  PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  ,p_carrying_out_organization_id IN PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  ,p_service_type_code       IN PA_VC_1000_150 := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  ,p_task_manager_person_id   IN    PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  ,p_billable_flag            IN    PA_VC_1000_10 := PA_VC_1000_10(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  ,p_chargeable_flag         IN PA_VC_1000_10 := PA_VC_1000_10(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  ,p_ready_to_bill_flag      IN PA_VC_1000_10 := PA_VC_1000_10(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  ,p_ready_to_distribute_flag IN   PA_VC_1000_10 := PA_VC_1000_10(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_limit_to_txn_controls_flag IN  PA_VC_1000_10 := PA_VC_1000_10(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  ,p_labor_bill_rate_org_id IN   PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_labor_std_bill_rate_schdl IN   PA_VC_1000_150 := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  ,p_labor_schedule_fixed_date IN  PA_DATE_1000_DATE := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
  ,p_labor_schedule_discount  IN    PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  ,p_nl_bill_rate_org_id      IN    PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  ,p_nl_std_bill_rate_schdl   IN    PA_VC_1000_150 := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  ,p_nl_schedule_fixed_date   IN    PA_DATE_1000_DATE := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
  ,p_nl_schedule_discount     IN    PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_labor_cost_multiplier_name IN  PA_VC_1000_25 := PA_VC_1000_25(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  ,p_cost_ind_rate_sch_id     IN    PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  ,p_rev_ind_rate_sch_id      IN    PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  ,p_inv_ind_rate_sch_id      IN    PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  ,p_cost_ind_sch_fixed_date  IN    PA_DATE_1000_DATE := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
  ,p_rev_ind_sch_fixed_date   IN    PA_DATE_1000_DATE := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
  ,p_inv_ind_sch_fixed_date   IN    PA_DATE_1000_DATE := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
  ,p_labor_sch_type           IN    PA_VC_1000_10 := PA_VC_1000_10(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  ,p_nl_sch_type              IN    PA_VC_1000_10 := PA_VC_1000_10(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  ,p_actual_start_date        IN      PA_DATE_1000_DATE := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
  ,p_actual_finish_date       IN      PA_DATE_1000_DATE := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
  ,p_early_start_date         IN      PA_DATE_1000_DATE := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
  ,p_early_finish_date        IN      PA_DATE_1000_DATE := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
  ,p_late_start_date          IN      PA_DATE_1000_DATE := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
  ,p_late_finish_date         IN      PA_DATE_1000_DATE := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
  ,p_scheduled_start_date     IN     PA_DATE_1000_DATE := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
  ,p_scheduled_finish_date    IN      PA_DATE_1000_DATE := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
  ,p_attribute_category      IN PA_VC_1000_150 := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  ,p_attribute1           IN PA_VC_1000_150 := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  ,p_attribute2          IN PA_VC_1000_150 := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  ,p_attribute3          IN PA_VC_1000_150 := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  ,p_attribute4          IN PA_VC_1000_150 := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  ,p_attribute5          IN PA_VC_1000_150 := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  ,p_attribute6          IN PA_VC_1000_150 := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  ,p_attribute7         IN  PA_VC_1000_150 := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  ,p_attribute8          IN PA_VC_1000_150 := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  ,p_attribute9          IN PA_VC_1000_150 := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  ,p_attribute10              IN    PA_VC_1000_150 := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  ,p_allow_cross_charge_flag  IN      PA_VC_1000_10 := PA_VC_1000_10(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  ,p_project_rate_date        IN      PA_DATE_1000_DATE := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
  ,p_project_rate_type        IN      PA_VC_1000_150 := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  ,p_cc_process_labor_flag    IN      PA_VC_1000_10 := PA_VC_1000_10(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  ,p_labor_tp_schedule_id     IN      PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  ,p_labor_tp_fixed_date      IN      PA_DATE_1000_DATE := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
  ,p_cc_process_nl_flag       IN      PA_VC_1000_10 := PA_VC_1000_10(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  ,p_nl_tp_schedule_id        IN      PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  ,p_nl_tp_fixed_date         IN   PA_DATE_1000_DATE := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
  ,p_receive_project_invoice_flag    IN      PA_VC_1000_10 := PA_VC_1000_10(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  ,p_work_type_id                IN      PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  ,p_emp_bill_rate_schedule_id   IN      PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  ,p_job_bill_rate_schedule_id   IN      PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
--Sakthi  MCB
 ,p_non_lab_std_bill_rt_sch_id   IN      PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_taskfunc_cost_rate_type      IN      PA_VC_1000_150 := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_taskfunc_cost_rate_date      IN      PA_DATE_1000_DATE := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
--Sakthi  MCB
 ,p_display_sequence IN      PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_wbs_level        IN      PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_milestone        IN     PA_VC_1000_10 := PA_VC_1000_10(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_duration        IN      PA_VC_1000_150 := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_duration_unit   IN      PA_VC_1000_150 := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_login_user_name     IN      PA_VC_1000_150:= PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_critical_flag       IN      PA_VC_1000_10 := PA_VC_1000_10(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_sub_project_id      IN      PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_progress_status_code IN     PA_VC_1000_150 := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_progress_comments    IN     PA_VC_1000_4000 := PA_VC_1000_4000(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_progress_asof_date   IN     PA_DATE_1000_DATE := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
 ,p_progress_description    IN      PA_VC_1000_2000 := PA_VC_1000_2000(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_predecessors                IN      PA_VC_1000_2000 := PA_VC_1000_2000(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_priority_code               IN      PA_VC_1000_150 := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_wbs_number                  IN      PA_VC_1000_2000 := PA_VC_1000_2000(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_estimated_start_date  IN PA_DATE_1000_DATE := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
 ,p_estimated_finish_date IN  PA_DATE_1000_DATE := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
 ,p_estimate_to_complete  IN    PA_VC_1000_10 := PA_VC_1000_10(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_language                        IN      VARCHAR2 default 'US'
 ,p_delimiter                       IN      VARCHAR2 default ','
 ,p_structure_version_id            IN      NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- ,p_calling_mode                      IN      VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--  Bug 2683364
 ,P_OBLIGATION_START_DATE   IN PA_DATE_1000_DATE := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
 ,P_OBLIGATION_FINISH_DATE  IN PA_DATE_1000_DATE := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
 ,P_BASELINE_START_DATE     IN PA_DATE_1000_DATE := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
 ,P_BASELINE_FINISH_DATE    IN PA_DATE_1000_DATE := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
 ,P_CLOSED_DATE             IN PA_DATE_1000_DATE := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
 ,P_WQ_UOM_CODE             IN PA_VC_1000_150 := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,P_WQ_ITEM_CODE            IN PA_VC_1000_150 := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,P_STATUS_CODE             IN PA_VC_1000_150 := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,P_WF_STATUS_CODE          IN PA_VC_1000_150 := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,P_PM_SOURCE_CODE          IN PA_VC_1000_150 := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,P_INC_PROJ_PROGRESS_FLAG  IN PA_VC_1000_10 := PA_VC_1000_10(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,P_LINK_TASK_FLAG          IN PA_VC_1000_10 := PA_VC_1000_10(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,P_CALENDAR_ID             IN PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,P_PLANNED_EFFORT          IN PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,P_PLANNED_WORK_QUANTITY   IN PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,P_TASK_TYPE               IN PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
-- Bug 2683364
 ,p_labor_disc_reason_code       IN PA_VC_1000_150 := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_non_labor_disc_reason_code   IN PA_VC_1000_150 := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
--PA L changes -- bug 2872708  --load_tasks
 ,p_retirement_cost_flag          IN PA_VC_1000_10    := PA_VC_1000_10(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_cint_eligible_flag            IN PA_VC_1000_10    := PA_VC_1000_10(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_cint_stop_date       IN PA_DATE_1000_DATE         := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
--end PA L changes -- bug 2872708
-- FP-M Bug # 3301192
 ,p_pred_string                 IN PA_VC_1000_4000 := PA_VC_1000_4000(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
-- ,p_pred_delimiter              IN PA_VC_1000_10   := PA_VC_1000_10(',')
 ,p_pred_delimiter                IN PA_VC_1000_10   := PA_VC_1000_10(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
-- FP M : Deliverable
--,p_deliverable                 IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR      --3435905
  ,p_deliverable                 IN PA_VC_1000_4000 := PA_VC_1000_4000(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  ,p_deliverable_id              IN PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)  -- 3661788 Added IN paramter
-- FP M changes begin (venkat)
  ,p_base_percent_comp_deriv_code IN PA_VC_1000_150 := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  ,p_sch_tool_tsk_type_code       IN PA_VC_1000_150 := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  ,p_constraint_type_code         IN PA_VC_1000_150 := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  ,p_constraint_date          IN PA_DATE_1000_DATE:= PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
  ,p_free_slack                   IN PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  ,p_total_slack                  IN PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  ,p_effort_driven_flag           IN PA_VC_1000_10 := PA_VC_1000_10(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  ,p_level_assignments_flag       IN PA_VC_1000_10 := PA_VC_1000_10(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  ,p_invoice_method           IN PA_VC_1000_4000 := PA_VC_1000_4000(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  ,p_customer_id                  IN PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  ,p_gen_etc_source_code          IN PA_VC_1000_150 := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
-- FP M changes end (venkat)

-- FP M changes start (Mapping )
--  ,p_financial_task_flag        IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--  ,p_mapped_task_id             IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--  ,p_mapped_task_reference      IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_financial_task_flag        IN PA_VC_1000_10 := PA_VC_1000_10(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
   ,p_mapped_task_id             IN PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
   ,p_mapped_task_reference      IN PA_VC_1000_150 := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 -- FP M changes end (Mapping )  -- FP M changes end (Mapping )

-- (begin venkat) new params for bug #3450684 ----------------------------------------------
  ,p_ext_act_duration            IN PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  ,p_ext_remain_duration         IN PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  ,p_ext_sch_duration            IN PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
-- (end venkat) new params for bug #3450684 -------------------------------------------------

-- Progress Management Changes. Bug # 3420093.
  ,p_etc_effort                 IN PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  ,p_percent_complete           IN PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
-- Progress Management Changes. Bug # 3420093.

);

/*#
 * This is a wrapper API for FETCH_TASK to handle multiple calls to FETCH_TASK.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @rep:paraminfo {@rep:precision 1}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1}
 * @param p_task_index Points to a single task
 * @rep:paraminfo {@rep:required}
 * @param p_pa_task_id Unique identifier for the task to be fetched
 * @rep:paraminfo {@rep:precision 15}
 * @param p_task_version_id Task version identifier
 * @param p_pm_task_reference The reference code that identifies the task in the external system
 * @rep:paraminfo {@rep:precision 25}
 * @param p_task_return_status Flag indicating whether the API has handled the task successfully. S indicates
 * success, E indicates a business rule violation, and U indicates that an unexpected error occurred
 * @rep:paraminfo {@rep:precision 1}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Fetch Tasks
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:compatibility S
 */
PROCEDURE fetch_tasks
( p_api_version_number  IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_init_msg_list       IN  VARCHAR2    := FND_API.G_FALSE
 ,p_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_task_index          IN  PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
 ,p_pa_task_id          OUT     NOCOPY PA_NUM_1000_NUM --File.Sql.39 bug 4440895
 ,p_task_version_id     OUT     NOCOPY PA_NUM_1000_NUM --File.Sql.39 bug 4440895
 ,p_pm_task_reference   OUT     NOCOPY PA_VC_1000_150 --File.Sql.39 bug 4440895
 ,p_task_return_status  OUT     NOCOPY PA_VC_1000_150 --File.Sql.39 bug 4440895
);

-- <EA Load API>
/**
P_API_VERSION_NUMBER
P_INIT_MSG_LIST
P_COMMIT
X_RETURN_STATUS
P_TRANSACTION_TYPE
P_TASK_ID
P_TASK_REFERENCE
P_ATTR_GRP_INTERNAL_NAME
P_ATTR_GRP_ID
P_ATTR_GRP_ROW_INDEX
P_ATTR_INTERNAL_NAME
P_ATTR_VALUE_STR
P_ATTR_VALUE_NUM
P_ATTR_VALUE_NUM_UOM
P_ATTR_VALUE_DATE
P_ATTR_DISP_VALUE
**/

/*#
 * This API loads a single attribute value for a given attribute group for the specified
 * project and task. Please refer the API User Guide to find more on required parameters
 * and optional parameters of this API.
 * @param P_API_VERSION_NUMBER API standard version number
 * @param P_INIT_MSG_LIST API standard (default = F): indicates if message stack will be initialized
 * @rep:paraminfo {@rep:precision 1}
 * @param P_COMMIT API standard (default = F): indicates if transaction will be committed
 * @rep:paraminfo {@rep:precision 1}
 * @param X_RETURN_STATUS API standard: return of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1}
 * @param P_TRANSACTION_TYPE The mode of processing for a logical attribute group row.
 * The value should correspond to the following constants:
 * PA_PROJECT_PUB: G_DELETE_MODE, G_UPDATE_MODE, G_SYNC_MODE (which either creates or
 * updates, as appropriate), and G_CREATE_MODE. Rows are processed in the
 * order in which they are displayed (deletion, updates and synchronization, and creation).
 * @param P_TASK_ID  Identifier of the task, if known. Required only if
 * a task-level extensible attribute is provided.
 * @param P_TASK_REFERENCE Unique task reference, if task identifier is unknown.
 * Required only if a task-level extensible attribute is provided.
 * @param P_ATTR_GRP_INTERNAL_NAME Internal name of the attribute group to which the current row belongs
 * @param P_ATTR_GRP_ID Identifier of the attribute group to which the current row belongs
 * @param P_ATTR_GRP_ROW_INDEX Logical row identifier
 * @rep:paraminfo {@rep:required}
 * @param P_ATTR_INTERNAL_NAME Internal name of the current row attribute
 * @param P_ATTR_VALUE_STR The value of the current row attribute if its data type is String
 * @param P_ATTR_VALUE_NUM The value of the current row attribute if its data type is Number
 * @param P_ATTR_VALUE_NUM_UOM The unit of measure selected to display number attributes
 * @param P_ATTR_VALUE_DATE The value for the current row attribute if its data type is Date
 * @param P_ATTR_DISP_VALUE The value for the current row attribute (as a String, regardless
 * of its data type) if the attribute has a value set with separate display and internal values
 * (for example, value sets with validation type set to Independent or Table).
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Load Extensible Attribute
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:compatibility S
 */
PROCEDURE load_extensible_attribute(P_API_VERSION_NUMBER     IN     NUMBER   := 1.0,
                                    P_INIT_MSG_LIST          IN     VARCHAR2 := FND_API.G_FALSE,
                                    P_COMMIT                 IN     VARCHAR2 := FND_API.G_FALSE,
                                    X_RETURN_STATUS             OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                    P_TRANSACTION_TYPE       IN     VARCHAR2 := PA_PROJECT_PUB.G_SYNC_MODE,
                        P_TASK_ID                IN     NUMBER   := NULL,
                                    P_TASK_REFERENCE         IN     VARCHAR2 := NULL,
                                    P_ATTR_GRP_INTERNAL_NAME IN     VARCHAR2 := NULL,
                                    P_ATTR_GRP_ID            IN     NUMBER   := NULL,
                                    P_ATTR_GRP_ROW_INDEX     IN     NUMBER   := NULL,
                                    P_ATTR_INTERNAL_NAME     IN     VARCHAR2 := NULL,
                                    P_ATTR_VALUE_STR         IN     VARCHAR2 := NULL,
                                    P_ATTR_VALUE_NUM         IN     NUMBER   := NULL,
                                    P_ATTR_VALUE_NUM_UOM     IN     VARCHAR2 := NULL,
                                    P_ATTR_VALUE_DATE        IN     DATE     := NULL,
                                    P_ATTR_DISP_VALUE        IN     VARCHAR2 := NULL
                                    );

/*#
 * This is a bulk load API that loads the attribute values in a batch of 1000 attributes per
 * API call. This procedure calls the LOAD_EXTENSIBLE_ATTRIBUTE API.
 * @param P_API_VERSION_NUMBER API standard: version number
 * @param P_INIT_MSG_LIST API standard (default = F): indicates if message stack will be initialized
 * @rep:paraminfo {@rep:precision 1}
 * @param P_COMMIT API standard (default = F): indicates if the transaction will be committed
 * @rep:paraminfo {@rep:precision 1}
 * @param X_RETURN_STATUS API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1}
 * @param P_TRANSACTION_TYPE The mode of processing for a logical attribute group row.
 * The value should correspond to the following constants:
 * PA_PROJECT_PUB : G_DELETE_MODE, G_UPDATE_MODE, G_SYNC_MODE (which either creates or
 * updates, as appropriate), and G_CREATE_MODE. Rows are processed in the
 * order in which they are displayed (deletion, updates and
 * synchronization, and creation).
 * @param P_TASK_ID  Identifier of the task, if known. Required only if
 * a task-level extensible attribute is provided.
 * @param P_TASK_REFERENCE Unique task reference, if task identifier is unknown.
 * Required only if a task-level extensible attribute is provided.
 * @param P_ATTR_GRP_INTERNAL_NAME Internal name of the attribute group to which the current row belongs
 * @param P_ATTR_GRP_ID Identifier of the attribute group to which the current row belongs
 * @param P_ATTR_GRP_ROW_INDEX Logical row identifier
 * @rep:paraminfo {@rep:required}
 * @param P_ATTR_INTERNAL_NAME Internal name of the current row attribute
 * @param P_ATTR_VALUE_STR The value of the current row attribute if its data type is String
 * @param P_ATTR_VALUE_NUM The value of the current row attribute if its data type is Number
 * @param P_ATTR_VALUE_NUM_UOM The unit of measure selected to display number attributes
 * @param P_ATTR_VALUE_DATE The value for the current row attribute if its data type is Date
 * @param P_ATTR_DISP_VALUE The value for the current row attribute (as a String, regardless
 * of its data type) if the attribute has a value set with separate display and internal values
 * (for example, value sets with validation type set to Independent or Table).
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Load Extensible Attributes
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:compatibility S
 */
PROCEDURE load_extensible_attributes(P_API_VERSION_NUMBER     IN     NUMBER,
                                     P_INIT_MSG_LIST          IN     VARCHAR2          := FND_API.G_FALSE,
                                     P_COMMIT                 IN     VARCHAR2          := FND_API.G_FALSE,
                                     X_RETURN_STATUS          OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                     P_TRANSACTION_TYPE       IN     PA_VC_1000_10     := PA_VC_1000_10(PA_PROJECT_PUB.G_SYNC_MODE),
                                     P_TASK_ID        IN     PA_NUM_1000_NUM   := PA_NUM_1000_NUM(NULL),
                                     P_TASK_REFERENCE IN     PA_VC_1000_150    := PA_VC_1000_150(NULL),
                                     P_ATTR_GRP_INTERNAL_NAME    IN     PA_VC_1000_30     := PA_VC_1000_30(NULL),
                                     P_ATTR_GRP_ID          IN     PA_NUM_1000_NUM   := PA_NUM_1000_NUM(NULL),
                                     P_ATTR_GRP_ROW_INDEX          IN     PA_NUM_1000_NUM   := PA_NUM_1000_NUM(NULL),
                                     P_ATTR_INTERNAL_NAME          IN     PA_VC_1000_30     := PA_VC_1000_30(NULL),
                                     P_ATTR_VALUE_STR         IN     PA_VC_1000_150    := PA_VC_1000_150(NULL),
                                     P_ATTR_VALUE_NUM         IN     PA_NUM_1000_NUM   := PA_NUM_1000_NUM(NULL),
                                     P_ATTR_VALUE_NUM_UOM   IN     PA_VC_1000_30     := PA_VC_1000_30(NULL),
                                     P_ATTR_VALUE_DATE        IN     PA_DATE_1000_DATE := PA_DATE_1000_DATE(NULL),
                                     P_ATTR_DISP_VALUE        IN     PA_VC_1000_150    := PA_VC_1000_150(NULL)
                         );
-- </EA Load API>

--Project Structures
/*#
 * This is a Load-Execute-Fetch procedure used to load structure data.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @rep:paraminfo {@rep:precision 1}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1}
 * @param p_pa_project_id The unique identifier of the project
 * @param p_structure_type Structure type
 * @rep:paraminfo {@rep:precision 25}
 * @param p_structure_version_name The name of the structure version
 * @param P_structure_version_id The unique identifier of the structure version
 * @param P_DESCRIPTION Description of the structure version
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Load Structure
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:compatibility S
 */
PROCEDURE load_structure
( p_api_version_number             IN   NUMBER
 ,p_init_msg_list              IN   VARCHAR2           := FND_API.G_FALSE
 ,p_return_status              OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_pa_project_id              IN   NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_structure_type             IN    VARCHAR2          := 'FINANCIAL'
 ,p_structure_version_name     IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_structure_version_id       IN    NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,P_DESCRIPTION                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 /*,P_VERSION_NUMBER             IN    NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,P_NAME                       IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_CURRENT_FLAG               IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_ORIGINAL_FLAG              IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_LATEST_EFF_PUBLISHED_FLAG IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_EFFECTIVE_DATE             IN    DATE              := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,P_PUBLISHED_DATE             IN    DATE              := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,P_PUBLISHED_BY_PERSON_ID     IN    NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,P_CURRENT_BASELINE_DATE      IN    DATE              := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,P_CURRENT_BASELINE_PERSON_ID   IN    NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,P_ORIGINAL_BASELINE_DATE       IN    DATE           := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,P_ORIGINAL_BASELINE_PERSON_ID  IN    NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,P_LOCK_STATUS_CODE             IN    VARCHAR2       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_LOCKED_BY_PERSON_ID          IN    NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,P_LOCKED_DATE                  IN    DATE           := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,P_STATUS_CODE                  IN    VARCHAR2       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_WF_STATUS_CODE               IN    VARCHAR2       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_PM_SOURCE_CODE               IN    VARCHAR2       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_PM_SOURCE_REFERENCE          IN    VARCHAR2       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_CHANGE_REASON_CODE           IN    VARCHAR2       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 */
);


/*#
 * This API is used to delete a workplan structure version from Oracle Projects.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @rep:paraminfo {@rep:precision 1}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @rep:paraminfo {@rep:precision 1}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1}
 * @param p_structure_version_id The unique identifier of the workplan structure
 * @rep:paraminfo {@rep:required}
 * @param p_record_version_number The unique identifier of the published workplan structure version
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Structure Version
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:compatibility S
 */
PROCEDURE delete_structure_version
( p_api_version_number          IN      NUMBER          := 1.0 -- for bug# 3802759
 ,p_commit                      IN      VARCHAR2        := FND_API.G_FALSE
 ,p_init_msg_list               IN      VARCHAR2        := FND_API.G_FALSE
 ,p_msg_count                   OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_msg_data                    OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_return_status               OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_structure_version_id        IN  NUMBER
 ,p_record_version_number       IN      NUMBER
);

/*#
 * This PL/SQL procedure is used to publish, submit, rework, reject, or approve
 * a workplan structure and thereby change its status code. The valid status codes are:STRUCTURE_WORKING,
 * STRUCTURE_PUBLISHED, STRUCTURE_SUBMITTED, STRUCTURE_REJECTED, and STRUCTURE_APPROVED.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @rep:paraminfo {@rep:precision 1}
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @rep:paraminfo {@rep:precision 1}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_structure_version_id The unique identifier of the workplan structure
 * @rep:paraminfo {@rep:required}
 * @param p_pa_project_id The unique identifier of the project
 * @rep:paraminfo {@rep:required}
 * @param p_status_code The workplan status code. The valid values: STRUCTURE_WORKING, STRUCTURE_PUBLISHED,
 * STRUCTURE_SUBMITTED, STRUCTURE_REJECTED, and STRUCTURE_APPROVED
 * @rep:paraminfo {@rep:required}
 * @param p_process_mode Process mode
 * @rep:paraminfo {@rep:precision 30}
 * @param p_published_struct_ver_id The unique identifier of the published workplan structure version
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Change Structure Status
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:compatibility S
 */
PROCEDURE change_structure_status
(p_api_version_number           IN      NUMBER          := 1.0 -- for bug# 3802319
, p_init_msg_list               IN      VARCHAR2        := 'F'
, p_commit                      IN      VARCHAR2        := 'F'
, p_return_status               OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_msg_count                   OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
, p_msg_data                    OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_structure_version_id        IN      NUMBER
, p_pa_project_id               IN      NUMBER
, p_status_code                 IN      VARCHAR2
, p_process_mode                IN      VARCHAR2 := 'ONLINE'
, p_published_struct_ver_id     OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895

);


/*#
 * This API is used to baseline a workplan structure version.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @rep:paraminfo {@rep:precision 1}
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @rep:paraminfo {@rep:precision 1}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_structure_version_id The unique identifier of the workplan structure
 * @rep:paraminfo {@rep:required}
 * @param p_pa_project_id The unique identifier of the project
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Baseline Structure Version
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:compatibility S
 */
PROCEDURE baseline_structure
(p_api_version_number           IN      NUMBER
, p_init_msg_list               IN      VARCHAR2        := 'F'
, p_commit                      IN      VARCHAR2        := 'F'
, p_return_status               OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_msg_count                   OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
, p_msg_data                    OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_structure_version_id        IN      NUMBER
, p_pa_project_id               IN      NUMBER

);

--Project Structures

--Project Connect 4.0
--------------------------------------------------------------------------------
--Name:               fetch_structure_version
--Type:               Procedure
--Description:        This procedure can be used to get the structure version ids
--                    to the client side as part part of the LOAD/EXECUTE/FETCH cycle.
--
--Called subprograms:
--
--
--
--History:
--    03-DEC-2002        Created
--

/*#
 * This API is a Load-Execute-Fetch procedure that returns
 * structure version identifiers of workplan and financial structures.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @rep:paraminfo {@rep:precision 1}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1}
 * @param p_structure_type Structure type
 * @param p_pa_structure_version_id The unique identifier of the structure
 * @rep:paraminfo {@rep:required}
 * @param p_struc_return_status Structure status
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Fetch Structure Version
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:compatibility S
 */
PROCEDURE fetch_structure_version
( p_api_version_number        IN      NUMBER
 ,p_init_msg_list             IN      VARCHAR2        := FND_API.G_FALSE
 ,p_return_status             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_structure_type            IN      VARCHAR2        := 'FINANCIAL'
 ,p_pa_structure_version_id   OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_struc_return_status       OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
;
--Project Connect 4.0


/*#
 * This API is a Load-Execute-Fetch procedure that returns version identifier
 * for a task.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @rep:paraminfo {@rep:precision 1}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1}
 * @param p_task_index Points to a single task
 * @param p_task_version_id Task version identifier
 * @param p_task_return_status Flag indicating whether the API has handled the task successfully. S indicates
 *  success, E indicates a business rule violation, and U indicates that an unexpected error occurred
 * @rep:paraminfo {@rep:precision 1}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Fetch Task Version
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:compatibility S
 */
PROCEDURE fetch_task_version
( p_api_version_number      IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_init_msg_list       IN  VARCHAR2    := FND_API.G_FALSE
 ,p_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_task_index          IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_task_version_id     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_task_return_status      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

--bug 2765115

/*#
 * This API is used to get the task version identifier of a task for a particular
 * workplan structure version.
 * @param p_api_version_number API standard: version number
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @rep:paraminfo {@rep:precision 1}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1}
 * @param p_pa_project_id The unique identifier of a project
 * @param p_pa_task_id The unique identifier of a task
 * @param p_pa_structure_version_id The unique identifier of a workplan structure
 * @param p_task_version_id Task version identifier
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Task Version
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:compatibility S
 */
PROCEDURE get_task_version
( p_api_version_number          IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_init_msg_list               IN      VARCHAR2        := FND_API.G_FALSE
 ,p_return_status               OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_pa_project_id                  IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pa_task_id                     IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pa_structure_version_id        IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_task_version_id             OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
);
--bug 2765115

 -- FP M changes begin (venkat)

/*#
 * This API is used to change the current working version of a workplan structure.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @rep:paraminfo {@rep:precision 1}
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @rep:paraminfo {@rep:precision 1}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_structure_version_id The unique identifier of the workplan structure
 * @rep:paraminfo {@rep:required}
 * @param p_pa_project_id The unique identifier of the project
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Change Current Working Version
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:compatibility S
 */
PROCEDURE change_current_working_version
(p_api_version_number           IN      NUMBER
, p_init_msg_list               IN      VARCHAR2        := 'F'
, p_commit                      IN      VARCHAR2        := 'F'
, p_return_status               OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_msg_count                   OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
, p_msg_data                    OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_structure_version_id        IN      NUMBER
, p_pa_project_id               IN      NUMBER
);
-- FP M changes end (venkat)

-- Progress Management Changes. Bug # 3420093.

/*#
 * This API is used to apply the latest progress information on the
 * current working version of a workplan structure.
 * @param p_api_version API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @rep:paraminfo {@rep:precision 1}
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @rep:paraminfo {@rep:precision 1}
 * @param p_pa_project_id The unique identifier of the project
 * @rep:paraminfo {@rep:required}
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system
 * @rep:paraminfo {@rep:precision 25}
 * @param p_working_str_version_id Identifier of the working version of a workplan structure
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Apply Latest Progress
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:compatibility S
 */
PROCEDURE apply_lp_prog_on_cwv(
  p_api_version                 IN      NUMBER          :=1.0
 ,p_init_msg_list               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_commit                      IN      VARCHAR2        :=FND_API.G_FALSE
 ,p_pa_project_id               IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_project_reference        IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_working_str_version_id      IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_return_status               OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_msg_count                   OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_msg_data                    OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- Progress Management Changes. Bug # 3420093.

-- 3435905 FP M Changes for Deliverables : Start

/*#
 * This API is used to load one deliverable into a PL/SQL table.
 * @param p_api_version API standard: version number
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_debug_mode Indicates to the system whether to display debug messages
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param p_deliverable_name Deliverable name
 * @rep:paraminfo {@rep:required}
 * @param p_deliverable_short_name Deliverable short name
 * @rep:paraminfo {@rep:required}
 * @param p_deliverable_type_id Identifier of the deliverable type
 * @param p_deliverable_owner_id Deliverable owner identifier
 * @param p_description Deliverable description
 * @param p_status_code Deliverable status
 * @param p_due_date Deliverable due date
 * @param p_completion_date Deliverable completion date
 * @param p_progress_weight Progress weight
 * @param p_pm_source_code Identifier of the source code system
 * @param px_deliverable_id Unique identifier of the deliverable in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_pm_deliverable_reference Unique identifier of the deliverable in the external system
 * @rep:paraminfo {@rep:required}
 * @param p_task_id Task identifier of the task associated with the deliverable
 * @param p_task_source_reference Task reference of the task associated with the deliverable
 * @param p_item_id The item identifier. Applies only to item-based deliverables.
 * @param P_inventory_org_id The inventory organization identifier of the item. Applies only to item-based deliverables.
 * @param p_quantity The quantity of the item. Applies only to item-based deliverables.
 * @param p_uom_code The unit of measure code of the deliverable. Applies only to item-based deliverables.
 * @rep:paraminfo {@rep:precision 30}
 * @param p_unit_price The unit price of the deliverable. Applies only to item-based deliverables.
 * @param p_unit_number The unit number of the deliverable. Required when an item-based deliverable
 * is unit number-enabled.
 * @rep:paraminfo {@rep:precision 30}
 * @param p_currency_code The currency code of the deliverable. Applies only to item-based deliverables.
 * @rep:paraminfo {@rep:precision 15}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Load Deliverable
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_PROJ_DELIVERABLE
 * @rep:compatibility S
 */
PROCEDURE load_deliverable
(   p_api_version            IN  NUMBER     := 1.0
  , p_init_msg_list          IN  VARCHAR2   := FND_API.G_TRUE
  , p_debug_mode             IN  VARCHAR2   := 'N'
  , x_return_status          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  , p_deliverable_name       IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_deliverable_short_name IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_deliverable_type_id    IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_deliverable_owner_id   IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_description            IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_status_code            IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_due_date               IN  DATE       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  , p_completion_date        IN  DATE       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  , p_progress_weight        IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_pm_source_code         IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , px_deliverable_id     IN OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  , p_pm_deliverable_reference IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  -- for bug# 3729250
--  , p_carrying_out_org_id    IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_task_id                IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_task_source_reference  IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_item_id                IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , P_inventory_org_id       IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_quantity               IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_uom_code               IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  -- for bug# 3729250
--  , p_item_description       IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_unit_price         IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  -- for bug# 3729250
  , p_unit_number        IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_currency_code      IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ) ;



/*#
 * This API is used to load deliverables into a PL/SQL table.
 * @param p_api_version API standard: version number
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_debug_mode Indicates to the system whether to display debug messages
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param p_deliverable_name Deliverable name
 * @rep:paraminfo {@rep:required}
 * @param p_deliverable_short_name Deliverable short name
 * @rep:paraminfo {@rep:required}
 * @param p_deliverable_type_id Identifier of the deliverable type
 * @param p_deliverable_owner_id Deliverable owner identifier
 * @param p_description Deliverable description
 * @param p_status_code Deliverable status
 * @param p_due_date Deliverable due date
 * @param p_completion_date Deliverable completion date
 * @param p_progress_weight Progress weight
 * @param p_pm_source_code Identifier of the source code system
 * @param px_deliverable_id Unique identifier of the deliverable in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_pm_deliverable_reference Unique identifier of the deliverable in the external system
 * @rep:paraminfo {@rep:required}
 * @param p_task_id Task identifier of the task associated with the deliverable
 * @param p_task_source_reference Task reference of the task associated with the deliverable
 * @param p_item_id The item identifier. Applies only to item-based deliverables.
 * @param P_inventory_org_id The inventory organization identifier of the item. Applies only to item-based deliverables.
 * @param p_quantity The quantity of the item. Applies only to item-based deliverables.
 * @param p_uom_code The unit of measure code of the deliverable. Applies only to item-based deliverables.
 * @rep:paraminfo {@rep:precision 30}
 * @param p_unit_price The unit price of the deliverable. Applies only to item-based deliverables.
 * @param p_unit_number The unit number of the deliverable. Required when an item-based deliverable
 * is unit number-enabled.
 * @rep:paraminfo {@rep:precision 30}
 * @param p_currency_code The currency code of the deliverable. Applies only to item-based deliverables.
 * @rep:paraminfo {@rep:precision 15}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Load Deliverables
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_PROJ_DELIVERABLE
 * @rep:compatibility S
 */
PROCEDURE load_deliverables
(   p_api_version            IN  NUMBER     := 1.0
  , p_init_msg_list          IN  VARCHAR2   := FND_API.G_TRUE
  , p_debug_mode             IN  VARCHAR2  := 'N'
  , x_return_status          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  , p_deliverable_name       IN  PA_VC_1000_150 := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  --, p_deliverable_name       IN  PA_VC_1000_240 := PA_VC_1000_240(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
--  , p_deliverable_short_name IN  PA_VC_1000_100 := PA_VC_1000_100(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  , p_deliverable_short_name IN  PA_VC_1000_150 := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  , p_deliverable_type_id    IN  PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  , p_deliverable_owner_id   IN  PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  , p_description            IN  PA_VC_1000_2000 := PA_VC_1000_2000(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  , p_status_code            IN  PA_VC_1000_30 := PA_VC_1000_30(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  , p_due_date               IN  PA_DATE_1000_DATE := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
  , p_completion_date        IN  PA_DATE_1000_DATE := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
  , p_progress_weight        IN  PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  , p_pm_source_code         IN  PA_VC_1000_30 := PA_VC_1000_30(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  , px_deliverable_id     IN OUT  NOCOPY PA_NUM_1000_NUM --File.Sql.39 bug 4440895
  , p_pm_deliverable_reference IN  PA_VC_1000_25 := PA_VC_1000_25(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  -- for bug# 3729250
--  , p_carrying_out_org_id    IN  PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  , p_task_id                IN  PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  , p_task_source_reference  IN  PA_VC_1000_25 := PA_VC_1000_25(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  , p_item_id                IN  PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  , P_inventory_org_id       IN  PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  , p_quantity               IN  PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  , p_uom_code               IN  PA_VC_1000_30 := PA_VC_1000_30(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  -- for bug# 3729250
--  , p_item_description       IN  PA_VC_1000_2000 := PA_VC_1000_2000(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  , p_unit_price         IN  PA_NUM_1000_NUM := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  -- for bug# 3729250
  , p_unit_number        IN  PA_VC_1000_30 := PA_VC_1000_30(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
--  , p_currency_code        IN  PA_VC_1000_15 := PA_VC_1000_15(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  , p_currency_code      IN  PA_VC_1000_30 := PA_VC_1000_30(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  ) ;

/*
 * This API is used to load a single deliverable action in the PL/SQL table for
 * deliverable actions.
 * @param p_api_version_number API standard: version number
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_debug_mode Indicates to the system whether to display debug messages
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @param p_action_name Unique identifier of the project in the external system
 * @param p_action_id Unique identifier of the deliverable action
 * @param p_action_owner_id Action owner identifier
 * @param p_function_code Deliverable action function code
 * @param p_due_date Due date of the deliverable action
 * @param p_description Description of the action
 * @param p_completion_date Completion date
 * @param p_pm_source_code Unique identifier of the external system
 * @param p_pm_action_reference Unique identifier of the deliverable action in the external system
 * @param p_pm_deliverable_reference Unique identifier of the deliverable in the external system
 * @param p_deliverable_id Unique identifier of the deliverable in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_financial_task_reference Unique identifier of the financial task
 * @param p_financial_task_id Identifier of the financial task
 * @param p_destination_type_code The destination type code of the deliverable action
 * @rep:paraminfo {@rep:precision 30}
 * @param p_receiving_org_id The identifier of the inventory organization that will receive the item
 * @param p_receiving_location_id The location (address) identifier where the item will be received. The
 * RECEIVING_LO CATION_ID must be related to the RECEIVING_ORG_ID.
 * @param p_po_need_by_date The date by which the purchase order is needed
 * @param p_vendor_id The identifier of the vendor that will supply the object
 * @param p_vendor_site_code The location (address) identifier of the vendor from where the object will be supplied.
 * @param p_Quantity Quantity for procurement deliverable action
 * @param p_uom_code The unit of measure code for procurement deliverable action
 * @rep:paraminfo {@rep:precision 30}
 * @param p_unit_price The unit price of the object. The unit price is needed only for non-item
 * deliverable procurement actions.
 * @param p_exchange_rate_type Exchange rate type for procurement deliverable actions
 * @param p_exchange_rate_date Exchange rate date for procurement deliverable actions
 * @param p_exchange_rate Exchange rate for procurement deliverable actions
 * @param p_expenditure_type The expenditure type is needed only for non-item based deliverable procurement actions.
 * @param p_expenditure_org_id Expenditure organization for procurement deliverable actions
 * @param p_expenditure_item_date Expenditure item date for procurement deliverable actions
 * @param p_requisition_line_type_id The requisition line type can only have a type of AMOUNT
 * The requisition line type is needed only for non-item based deliverable procurement actions
 * @param p_category_id The item category identifier is needed only for non-item based deliverable procurement actions
 * @param p_ready_to_procure_flag Flag that indicates whether an item is ready to be procured
 * @rep:paraminfo {@rep:precision 1}
 * @param p_initiate_procure_flag Flag that indicates whether a procurement action should be initiated
 * @rep:paraminfo {@rep:precision 1}
 * @param p_ship_from_organization_id The inventory organization identifier of the inventory organization that will ship the item
 * @param p_ship_from_location_id The location (address) identifier where the item will be shipped.
 * The SHIP_FROM_LOCATION_ID must be related to the SHIP_FROM_ORG_ID.
 * @param p_ship_to_organization_id The customer account identifier to which the item will be shipped.
 * @param p_ship_to_location_id The customer location (address) identifier to where the item will be shipped
 * The SHIP_TO_LOCATION_ID must be related to the SHIP_TO_ORG_ID
 * @param p_demand_schedule Demand schedule
 * @rep:paraminfo {@rep:precision 10}
 * @param p_expected_shipment_date Expected shipment date
 * @param p_promised_shipment_date Promised shipment date
 * @param p_volume The volume of each object to be shipped. The volume is needed only for non-item shipping.
 * @param p_volume_uom The volume unit of measure of each object to be shipped.
 * The volume unit of measure is needed only for non-item shipping.
 * @rep:paraminfo {@rep:precision 10}
 * @param p_weight The weight of each object to be shipped. The weight is needed only for non-item shipping.
 * @param p_weight_uom The weight unit of measure of each object to be shipped. The weight unit of
 * measure is needed only for non-item shipping.
 * @rep:paraminfo {@rep:precision 10}
 * @param p_ready_to_ship_flag Flag that indicates whether an item is ready to be shiped
 * @rep:paraminfo {@rep:precision 1}
 * @param p_initiate_planning_flag Flag that indicates whether planning should be initiated
 * @rep:paraminfo {@rep:precision 1}
 * @param p_initiate_shipping_flag Flag that indicates whether shipping should be initiated
 * @rep:paraminfo {@rep:precision 1}
 * @param p_event_type Billing event type
 * @rep:paraminfo {@rep:precision 30}
 * @param p_currency Currency code for the billing event
 * @rep:paraminfo {@rep:precision 30}
 * @param p_invoice_amount Invoice amount for the billing
 * @param p_revenue_amount Revenue amount for the billing event
 * @param p_event_date Event date for the billing event.
 * @param p_event_number Event number for the billing event.
 * @param p_organization_id Organization identifier of the organization associated with the billing event
 * @param p_bill_hold_flag Flag that indicates whether a billing event is on hold
 * @rep:paraminfo {@rep:precision 1}
 * @param p_project_functional_rate_type Rate type for project functional currency for the billing event
 * @rep:paraminfo {@rep:precision 30}
 * @param p_project_functional_rate_date Rate date for project functional currency for the billing event
 * @param p_project_functional_rate Rate for project functional currency for the billing event
 * @param p_project_rate_type Rate type for project currency for the billing event
 * @rep:paraminfo {@rep:precision 30}
 * @param p_project_rate_date Rate date for project currency for the billing event
 * @param p_project_rate Rate for project currency for the billing event
 * @param p_funding_rate_type Rate type for funding currency for the billing event
 * @rep:paraminfo {@rep:precision 30}
 * @param p_funding_rate_date Rate date for funding currency for the billing event
 * @param p_funding_rate Rate for funding currency for the billing event
 * @param p_pm_event_reference The unique identifier of the billing event in the external system
 * @rep:paraminfo {@rep:precision 25}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Load Deliverable Action
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_PROJ_DELIVERABLE
 * @rep:compatibility S
 */
PROCEDURE load_action
(   p_api_version                  IN  NUMBER    := 1.0
  , p_init_msg_list                IN  VARCHAR2  := FND_API.G_TRUE
  , p_debug_mode                   IN  VARCHAR2  := 'N'
  , x_return_status                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  , p_action_name                  IN  VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_action_id                    IN  NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_action_owner_id              IN  NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_function_code                IN  VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_due_date                     IN  DATE      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  , p_description                  IN  VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_completion_date              IN  DATE      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  , p_pm_source_code               IN  VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_pm_action_reference          IN  VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  -- for bug# 3729250
--  , p_carrying_out_org_id          IN  NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_pm_deliverable_reference     IN  VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_deliverable_id               IN  NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  -- added for bug# 3729250
  , p_financial_task_reference     IN  VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_financial_task_id            IN  NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_destination_type_code        IN  VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_receiving_org_id             IN  NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_receiving_location_id        IN  NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_po_need_by_date              IN  DATE      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  , p_vendor_id                    IN  NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_vendor_site_code             IN  VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--  , p_project_currency             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_Quantity                     IN  NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_uom_code                     IN  VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_unit_price                   IN  NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_exchange_rate_type           IN  VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_exchange_rate_date           IN  DATE      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  , p_exchange_rate                IN  NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM       /* Bug # 3590235 */
  , p_expenditure_type             IN  VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_expenditure_org_id           IN  NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_expenditure_item_date        IN  DATE      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  , p_requisition_line_type_id     IN  NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_category_id                  IN  NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_ready_to_procure_flag        IN  VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_initiate_procure_flag        IN  VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_ship_from_organization_id    IN  NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_ship_from_location_id        IN  NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_ship_to_organization_id      IN  NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_ship_to_location_id          IN  NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_demand_schedule              IN  VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_expected_shipment_date       IN  DATE      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  , p_promised_shipment_date       IN  DATE      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  , p_volume                       IN  NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_volume_uom                   IN  VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_weight                       IN  NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_weight_uom                   IN  VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_ready_to_ship_flag           IN  VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_initiate_planning_flag       IN  VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_initiate_shipping_flag       IN  VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_event_type                   IN  VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_currency                     IN  VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_invoice_amount               IN  NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_revenue_amount               IN  NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_event_date                   IN  DATE      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  , p_event_number                 IN  NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_organization_id              IN  NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_bill_hold_flag               IN  VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_project_functional_rate_type IN  VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_project_functional_rate_date IN  DATE      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  , p_project_functional_rate      IN  NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_project_rate_type            IN  VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_project_rate_date            IN  DATE      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  , p_project_rate                 IN  NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_funding_rate_type            IN  VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_funding_rate_date            IN  DATE      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  , p_funding_rate                 IN  NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_pm_event_reference           IN  VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR -- 3651489 added parameter
);

/*
 * This API is used to load deliverable actions in the PL/SQL table for
 * deliverable actions.
 * @param p_api_version_number API standard: version number
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_debug_mode Indicates to the system whether to display debug messages
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @param p_action_name Unique identifier of the project in the external system
 * @param p_action_id Unique identifier of the deliverable action
 * @param p_action_owner_id Action owner identifier
 * @param p_function_code Deliverable action function code
 * @param p_due_date Due date of the deliverable action
 * @param p_description Description of the action
 * @param p_completion_date Completion date
 * @param p_pm_source_code Unique identifier of the external system
 * @param p_pm_action_reference Unique identifier of the deliverable action in the external system
 * @param p_pm_deliverable_reference Unique identifier of the deliverable in the external system
 * @param p_deliverable_id Unique identifier of the deliverable in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_financial_task_reference Unique identifier of the financial task
 * @param p_financial_task_id Identifier of the financial task
 * @param p_destination_type_code The destination type code of the deliverable action
 * @rep:paraminfo {@rep:precision 30}
 * @param p_receiving_org_id The identifier of the inventory organization that will receive the item
 * @param p_receiving_location_id The location (address) identifier where the item will be received. The
 * RECEIVING_LO CATION_ID must be related to the RECEIVING_ORG_ID.
 * @param p_po_need_by_date The date by which the purchase order is needed
 * @param p_vendor_id The identifier of the vendor that will supply the object
 * @param p_vendor_site_code The location (address) code of the vendor from where the object will be supplied
 * @param p_Quantity Quantity for procurement deliverable action
 * @param p_uom_code The unit of measure code for procurement deliverable action
 * @rep:paraminfo {@rep:precision 30}
 * @param p_unit_price The unit price of the object. The unit price is needed only for non-item
 * deliverable procurement actions.
 * @param p_exchange_rate_type Exchange rate type for procurement deliverable actions
 * @param p_exchange_rate_date Exchange rate date for procurement deliverable actions
 * @param p_exchange_rate Exchange rate for procurement deliverable actions
 * @param p_expenditure_type The expenditure type is needed only for non-item based deliverable procurement actions.
 * @param p_expenditure_org_id Expenditure organization for procurement deliverable actions
 * @param p_expenditure_item_date Expenditure item date for procurement deliverable actions
 * @param p_requisition_line_type_id The requisition line type can only have a type of AMOUNT
 * The requisition line type is needed only for non-item based deliverable procurement actions
 * @param p_category_id The item category identifier is needed only for non-item based deliverable procurement actions.
 * @param p_ready_to_procure_flag Flag that indicates whether an item is ready to be procured
 * @rep:paraminfo {@rep:precision 1}
 * @param p_initiate_procure_flag Flag that indicates whether a procurement action should be initiated
 * @rep:paraminfo {@rep:precision 1}
 * @param p_ship_from_organization_id The inventory organization identifier of the inventory organization that will ship the item
 * @param p_ship_from_location_id The location (address) identifier where the item will be shipped.
 * The SHIP_FROM_LOCATION_ID must be related to the SHIP_FROM_ORG_ID.
 * @param p_ship_to_organization_id The customer account identifier to which the item will be shipped
 * @param p_ship_to_location_id The customer location (address) identifier to where the item will be shipped.
 * The SHIP_TO_LOCATION_ID must be related to the SHIP_TO_ORG_ID.
 * @param p_demand_schedule Demand schedule.
 * @rep:paraminfo {@rep:precision 10}
 * @param p_expected_shipment_date Expected shipment date
 * @param p_promised_shipment_date Promised shipment date
 * @param p_volume The volume of each object to be shipped. The volume is needed only for non-item shipping.
 * @param p_volume_uom The volume unit of measure of each object to be shipped.
 * The volume unit of measure is needed only for non-item shipping.
 * @rep:paraminfo {@rep:precision 10}
 * @param p_weight The weight of each object to be shipped. The weight is needed only for non-item shipping.
 * @param p_weight_uom The weight unit of measure of each object to be shipped. The weight unit of
 * measure is needed only for non-item shipping.
 * @rep:paraminfo {@rep:precision 10}
 * @param p_ready_to_ship_flag Flag that indicates whether an item is ready to be shiped
 * @rep:paraminfo {@rep:precision 1}
 * @param p_initiate_planning_flag Flag that indicates whether planning should be initiated
 * @rep:paraminfo {@rep:precision 1}
 * @param p_initiate_shipping_flag Flag that indicates whether shipping should be initiated
 * @rep:paraminfo {@rep:precision 1}
 * @param p_event_type Billing event type
 * @rep:paraminfo {@rep:precision 30}
 * @param p_currency Currency code for the billing event
 * @rep:paraminfo {@rep:precision 30}
 * @param p_invoice_amount Invoice amount for the billing
 * @param p_revenue_amount Revenue amount for the billing event
 * @param p_event_date Event date for the billing event
 * @param p_event_number Event number for the billing event
 * @param p_organization_id Organization identifier of the organization associated with the billing event
 * @param p_bill_hold_flag Flag that indicates whether a billing event is on hold
 * @rep:paraminfo {@rep:precision 1}
 * @param p_project_functional_rate_type Rate type for project functional currency for the billing event
 * @rep:paraminfo {@rep:precision 30}
 * @param p_project_functional_rate_date Rate date for project functional currency for the billing event
 * @param p_project_functional_rate Rate for project functional currency for the billing event
 * @param p_project_rate_type Rate type for project currency for the billing event
 * @rep:paraminfo {@rep:precision 30}
 * @param p_project_rate_date Rate date for project currency for the billing event
 * @param p_project_rate Rate for project currency for the billing event
 * @param p_funding_rate_type Rate type for funding currency for the billing event
 * @rep:paraminfo {@rep:precision 30}
 * @param p_funding_rate_date Rate date for funding currency for the billing event
 * @param p_funding_rate Rate for funding currency for the billing event
 * @param p_pm_event_reference The unique identifier of the billing event in the external system
 * @rep:paraminfo {@rep:precision 25}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Load Deliverable Actions
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_PROJ_DELIVERABLE
 * @rep:compatibility S
 */
PROCEDURE load_actions
(   p_api_version                  IN  NUMBER            := 1.0
  , p_init_msg_list                IN  VARCHAR2          := FND_API.G_TRUE
  , p_debug_mode                   IN  VARCHAR2          := 'N'
  , x_return_status            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  --, p_action_name                  IN  PA_VC_1000_240  := PA_VC_1000_240(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  , p_action_name                  IN  PA_VC_1000_150    := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  , p_action_id                    IN  PA_NUM_1000_NUM   := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  , p_action_owner_id              IN  PA_NUM_1000_NUM   := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  , p_function_code                IN  PA_VC_1000_30     := PA_VC_1000_30(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  , p_due_date                     IN  PA_DATE_1000_DATE := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
  , p_description                  IN  PA_VC_1000_2000   := PA_VC_1000_2000(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  , p_completion_date              IN  PA_DATE_1000_DATE := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
  , p_pm_source_code               IN  PA_VC_1000_30     := PA_VC_1000_30(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  , p_pm_action_reference          IN  PA_VC_1000_25     := PA_VC_1000_25(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  -- for bug# 3729250
--  , p_carrying_out_org_id          IN  PA_NUM_1000_NUM   := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  , p_pm_deliverable_reference     IN  PA_VC_1000_25     := PA_VC_1000_25(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  , p_deliverable_id               IN  PA_NUM_1000_NUM   := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  -- added for bug# 3729250
  , p_financial_task_reference     IN  PA_VC_1000_25     := PA_VC_1000_25(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  , p_financial_task_id            IN  PA_NUM_1000_NUM   := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  , p_destination_type_code        IN  PA_VC_1000_25     := PA_VC_1000_25(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  , p_receiving_org_id             IN  PA_NUM_1000_NUM   := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  , p_receiving_location_id        IN  PA_NUM_1000_NUM   := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  , p_po_need_by_date              IN  PA_DATE_1000_DATE := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
  , p_vendor_id                    IN  PA_NUM_1000_NUM   := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  , p_vendor_site_code             IN  PA_VC_1000_30     := PA_VC_1000_30(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
--  , p_project_currency             IN  PA_VC_1000_25   := PA_VC_1000_25(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  , p_Quantity                     IN  PA_NUM_1000_NUM   := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  , p_uom_code                     IN  PA_VC_1000_25     := PA_VC_1000_25(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  , p_unit_price                   IN  PA_NUM_1000_NUM   := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  , p_exchange_rate_type           IN  PA_VC_1000_30     := PA_VC_1000_30(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  , p_exchange_rate_date           IN  PA_DATE_1000_DATE := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
  , p_exchange_rate                IN  PA_NUM_1000_NUM   := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)   /* Bug # 3590235 */
  , p_expenditure_type             IN  PA_VC_1000_30     := PA_VC_1000_30(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  , p_expenditure_org_id           IN  PA_NUM_1000_NUM   := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  , p_expenditure_item_date        IN  PA_DATE_1000_DATE := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
  , p_requisition_line_type_id     IN  PA_NUM_1000_NUM   := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  , p_category_id                  IN  PA_NUM_1000_NUM   := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
--  , p_ready_to_procure_flag        IN  PA_VC_1000_1    := PA_VC_1000_1(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
--  , p_initiate_procure_flag        IN  PA_VC_1000_1    := PA_VC_1000_1(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  , p_ready_to_procure_flag        IN  PA_VC_1000_10     := PA_VC_1000_10(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  , p_initiate_procure_flag        IN  PA_VC_1000_10     := PA_VC_1000_10(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  , p_ship_from_organization_id    IN  PA_NUM_1000_NUM   := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  , p_ship_from_location_id        IN  PA_NUM_1000_NUM   := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  , p_ship_to_organization_id      IN  PA_NUM_1000_NUM   := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  , p_ship_to_location_id          IN  PA_NUM_1000_NUM   := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  , p_demand_schedule              IN  PA_VC_1000_10     := PA_VC_1000_10(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  , p_expected_shipment_date       IN  PA_DATE_1000_DATE := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
  , p_promised_shipment_date       IN  PA_DATE_1000_DATE := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
  , p_volume                       IN  PA_NUM_1000_NUM   := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  , p_volume_uom                   IN  PA_VC_1000_10     := PA_VC_1000_10(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  , p_weight                       IN  PA_NUM_1000_NUM   := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  , p_weight_uom                   IN  PA_VC_1000_10     := PA_VC_1000_10(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
--  , p_ready_to_ship_flag           IN  PA_VC_1000_1    := PA_VC_1000_1(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
--  , p_initiate_planning_flag       IN  PA_VC_1000_1    := PA_VC_1000_1(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
--  , p_initiate_shipping_flag       IN  PA_VC_1000_1    := PA_VC_1000_1(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  , p_ready_to_ship_flag           IN  PA_VC_1000_10     := PA_VC_1000_10(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  , p_initiate_planning_flag       IN  PA_VC_1000_10     := PA_VC_1000_10(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  , p_initiate_shipping_flag       IN  PA_VC_1000_10     := PA_VC_1000_10(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  , p_event_type                   IN  PA_VC_1000_30     := PA_VC_1000_30(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  , p_currency                     IN  PA_VC_1000_30     := PA_VC_1000_30(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  , p_invoice_amount               IN  PA_NUM_1000_NUM   := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  , p_revenue_amount               IN  PA_NUM_1000_NUM   := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  , p_event_date                   IN  PA_DATE_1000_DATE := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
  , p_event_number                 IN  PA_NUM_1000_NUM   := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  , p_organization_id              IN  PA_NUM_1000_NUM   := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  , p_bill_hold_flag               IN  PA_VC_1000_30     := PA_VC_1000_30(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  , p_project_functional_rate_type IN  PA_VC_1000_30     := PA_VC_1000_30(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  , p_project_functional_rate_date IN  PA_DATE_1000_DATE := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
  , p_project_functional_rate      IN  PA_NUM_1000_NUM   := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  , p_project_rate_type            IN  PA_VC_1000_30     := PA_VC_1000_30(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  , p_project_rate_date            IN  PA_DATE_1000_DATE := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
  , p_project_rate                 IN  PA_NUM_1000_NUM   := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  , p_funding_rate_type            IN  PA_VC_1000_30     := PA_VC_1000_30(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  , p_funding_rate_date            IN  PA_DATE_1000_DATE := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
  , p_funding_rate                 IN  PA_NUM_1000_NUM   := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  , p_pm_event_reference           IN  PA_VC_1000_25     := PA_VC_1000_25(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) -- 3651489 added parameter
);

/*#
 * This API is used to create a deliverable for a project.
 * @param p_api_version API standard: version number
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @param p_debug_mode Indicates to the system whether to display debug messages
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param p_deliverable_name Deliverable name
 * @rep:paraminfo {@rep:required}
 * @param p_deliverable_short_name Deliverable short name
 * @rep:paraminfo {@rep:required}
 * @param p_deliverable_type_id Identifier of the deliverable type
 * @param p_deliverable_owner_id Deliverable owner identifier
 * @param p_description Deliverable description
 * @param p_status_code Deliverable status
 * @param p_due_date Deliverable due date
 * @param p_completion_date Deliverable completion date
 * @param p_progress_weight Progress weight
 * @param px_deliverable_id Unique identifier of the deliverable in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_pm_deliverable_reference Unique identifier of the deliverable in the external system
 * @rep:paraminfo {@rep:required}
 * @param p_task_id Task identifier of the task associated with the deliverable
 * @param p_task_source_reference Task reference of the task associated with the deliverable
 * @param p_project_id Unique identifier of the project
 * @param p_proj_source_reference Unique identifier of the project in the external system
 * @param p_action_in_tbl Table of deliverable actions that need to be created
 * @param x_action_out_tbl Table of successfully processed actions
 * @param p_item_id The identifier of the item. Applies only to item-based deliverables.
 * @param P_inventory_org_id The inventory organization identifier of the item. Applies only to item-based deliverables.
 * @param p_quantity The quantity of the item. Applies only to item-based deliverables.
 * @param p_uom_code The unit of measure code of the deliverable. Applies only to item-based deliverables.
 * @rep:paraminfo {@rep:precision 30}
 * @param p_unit_price The unit price of the deliverable. Applies only to item-based deliverables.
 * @param p_unit_number The unit number of the deliverable. Required when an item-based deliverable
 * is unit number enabled.
 * @rep:paraminfo {@rep:precision 30}
 * @param p_currency_code The currency code of the deliverable. Applies only to item-based deliverables.
 * @rep:paraminfo {@rep:precision 15}
 * @param p_pm_source_code Identifier of the external system
 * @param x_msg_count API standard: number of error messages
 * @param x_msg_data API standard: error message
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Deliverable
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_PROJ_DELIVERABLE
 * @rep:compatibility S
 */
PROCEDURE create_deliverable
(   p_api_version            IN  NUMBER     := 1.0
  , p_init_msg_list          IN  VARCHAR2   := FND_API.G_TRUE
  , p_commit                 IN  VARCHAR2   := FND_API.G_FALSE
  , p_debug_mode             IN  VARCHAR2   := 'N'
  , x_return_status          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  , p_deliverable_name       IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_deliverable_short_name IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_deliverable_type_id    IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_deliverable_owner_id   IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_description            IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_status_code            IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_due_date               IN  DATE       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  , p_completion_date        IN  DATE       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  , p_progress_weight        IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , px_deliverable_id        IN OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  , p_pm_deliverable_reference IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  -- for bug# 3729250
--  , p_carrying_out_org_id    IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_task_id                IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_task_source_reference  IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_project_id             IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_proj_source_reference  IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_action_in_tbl          IN  action_in_tbl_type := G_deliverable_actions_in_tbl -- 3435905 passing default
  , x_action_out_tbl         OUT NOCOPY action_out_tbl_type --File.Sql.39 bug 4440895
  , p_item_id                IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , P_inventory_org_id       IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_quantity               IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_uom_code               IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  -- for bug# 3729250
--  , p_item_description       IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_unit_price             IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  -- for bug# 3729250
  , p_unit_number            IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_currency_code          IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_pm_source_code         IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR              /* Bug no. 3651113 */
  , x_msg_count              OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  , x_msg_data               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) ;


/*#
 * This API is used to create a deliverable action for a deliverable.
 * @param p_api_version API standard: version number
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_debug_mode Indicates to the system whether to display debug messages
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @param p_action_name Deliverable action name
 * @param p_action_owner_id Action owner identifier
 * @param p_function_code Deliverable action function code
 * @param p_due_date Due date of the deliverable action
 * @param p_description Description of the action
 * @param p_completion_date Completion date
 * @param p_pm_source_code Unique identifier of the external system
 * @param p_pm_action_reference Unique identifier of the deliverable action in the external system
 * @param p_deliverable_reference Unique identifier of the deliverable in the external system
 * @param p_deliverable_id Unique identifier of the deliverable in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_pm_proj_reference Unique identifier of the project in the external system
 * @param p_project_id Unique identifier of the project
 * @param p_financial_task_reference Unique identifier of the financial task
 * @param p_financial_task_id Identifier of the financial task
 * @param p_destination_type_code The destination type code of the deliverable action
 * @rep:paraminfo {@rep:precision 30}
 * @param p_receiving_org_id The identifier of the inventory organization that will receive the item
 * @param p_receiving_location_id The location (address) where the item will be received. The
 * RECEIVING_LO CATION_ID must be related to the RECEIVING_ORG_ID
 * @param p_po_need_by_date The date by which the purchase order is needed
 * @param p_vendor_id The identifier of the vendor that will supply the object
 * @param p_vendor_site_code The location (address) code of the vendor from where the object will be supplied
 * @param p_Quantity Quantity for procurement deliverable action
 * @param p_uom_code The unit of measure code for procurement deliverable action
 * @rep:paraminfo {@rep:precision 30}
 * @param p_unit_price The unit price of the object. The unit price is needed only for non-item
 * deliverable procurement actions.
 * @param p_exchange_rate_type Exchange rate type for procurement deliverable actions
 * @param p_exchange_rate_date Exchange rate date for procurement deliverable actions
 * @param p_exchange_rate Exchange rate for procurement deliverable actions
 * @param p_expenditure_type The expenditure type is needed only for non-item-based deliverable procurement actions.
 * @param p_expenditure_org_id Expenditure organization identifier for procurement deliverable actions
 * @param p_expenditure_item_date Expenditure item date for procurement deliverable actions
 * @param p_requisition_line_type_id The requisition line type identifier. This can only have a type of AMOUNT.
 * The requisition line type is needed only for non-item-based deliverable procurement actions.
 * @param p_category_id The item category identifier is needed only for non-item-based deliverable procurement actions.
 * @param p_ready_to_procure_flag Flag that indicates if an idem is ready to be procured
 * @rep:paraminfo {@rep:precision 1}
 * @param p_initiate_procure_flag Flag that indicates if a procurement action should be initiated
 * @rep:paraminfo {@rep:precision 1}
 * @param p_ship_from_organization_id The inventory org identifier of the inventory organization that will ship the item
 * @param p_ship_from_location_id The location (address) identifier where the item will be shipped to.
 * The SHIP_FROM_LOCATION_ID must be related to the P_SHIP_FROM_ORGANIZATION_ID .
 * @param p_ship_to_organization_id The customer account identifier to which the item will be shipped to
 * @param p_ship_to_location_id The customer location (address) identifier where the item will be shipped to.
 * The SHIP_TO_LOCATION_ID must be related to the P_SHIP_TO_ORGANIZATION_ID .
 * @param p_demand_schedule Demand schedule
 * @rep:paraminfo {@rep:precision 10}
 * @param p_expected_shipment_date Expected shipment date
 * @param p_promised_shipment_date Promised shipment date
 * @param p_volume The volume of each object to be shipped. The volume is needed only for non-item shipping.
 * @param p_volume_uom The volume unit of measure of each object to be shipped.
 * The volume unit of measure is needed only for non-item shipping.
 * @rep:paraminfo {@rep:precision 10}
 * @param p_weight The weight of each object to be shipped. The weight is needed only for non-item shipping.
 * @param p_weight_uom The weight unit of measure of each object to be shipped. The weight unit of
 * measure is needed only for non-item shipping.
 * @rep:paraminfo {@rep:precision 10}
 * @param p_ready_to_ship_flag Flag that indicates if an item is ready to shipped
 * @rep:paraminfo {@rep:precision 1}
 * @param p_initiate_planning_flag Flag that indicates if planning should be initiated
 * @rep:paraminfo {@rep:precision 1}
 * @param p_initiate_shipping_flag Flag that indicates if shipping should be initiated
 * @rep:paraminfo {@rep:precision 1}
 * @param p_event_type Billing event type
 * @rep:paraminfo {@rep:precision 30}
 * @param p_currency Currency code for the billing event
 * @rep:paraminfo {@rep:precision 30}
 * @param p_invoice_amount Invoice amount for the billing
 * @param p_revenue_amount Revenue amount for the billing event
 * @param p_event_date Event date for the billing event
 * @param p_event_number Event number for the billing event
 * @param p_organization_id Organization identifier of the organization associated with the billing event
 * @param p_bill_hold_flag Flag that indicates if a billing event is on hold
 * @rep:paraminfo {@rep:precision 1}
 * @param p_project_functional_rate_type Rate type for project functional currency for the billing event
 * @rep:paraminfo {@rep:precision 30}
 * @param p_project_functional_rate_date Rate date for project functional currency for the billing event
 * @param p_project_functional_rate Rate for project functional currency for the billing event
 * @param p_project_rate_type Rate type for project currency for the billing event
 * @rep:paraminfo {@rep:precision 30}
 * @param p_project_rate_date Rate date for project currency for the billing event
 * @param p_project_rate Rate for project currency for the billing event
 * @param p_funding_rate_type Rate type for funding currency for the billing event
 * @rep:paraminfo {@rep:precision 30}
 * @param p_funding_rate_date Rate date for funding currency for the billing event
 * @param p_funding_rate Rate for funding currency for the billing event
 * @param p_pm_event_reference The unique identifier of the billing event in the external system
 * @rep:paraminfo {@rep:precision 25}
 * @param x_action_out Table of successfully processed actions
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param x_msg_count API standard: number of error messages
 * @param x_msg_data API standard: error message
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Deliverable Action
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_PROJ_DELIVERABLE
 * @rep:compatibility S
 */
PROCEDURE create_deliverable_action
(   p_api_version                  IN  NUMBER   := 1.0
  , p_init_msg_list                IN  VARCHAR2 := FND_API.G_TRUE
  , p_debug_mode                   IN  VARCHAR2 := FND_API.G_FALSE
  , p_commit                       IN  VARCHAR2 := FND_API.G_FALSE
  , p_action_name                  IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_action_owner_id              IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_function_code                IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_due_date                     IN  DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  , p_description                  IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_completion_date              IN  DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  , p_pm_source_code               IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_pm_action_reference          IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  -- for bug# 3729250
--  , p_carrying_out_org_id          IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_deliverable_reference        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_deliverable_id               IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  -- added for bug# 3729250
  , p_pm_proj_reference            IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_project_id                   IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  -- added for bug# 3729250
  , p_financial_task_reference     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_financial_task_id            IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_destination_type_code        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_receiving_org_id             IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_receiving_location_id        IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_po_need_by_date              IN  DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  , p_vendor_id                    IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_vendor_site_code             IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--  , p_project_currency             IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_Quantity                     IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_uom_code                     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_unit_price                   IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_exchange_rate_type           IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_exchange_rate_date           IN  DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  , p_exchange_rate                IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_expenditure_type             IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_expenditure_org_id           IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_expenditure_item_date        IN  DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  , p_requisition_line_type_id     IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_category_id                  IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_ready_to_procure_flag        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_initiate_procure_flag        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_ship_from_organization_id    IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_ship_from_location_id        IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_ship_to_organization_id      IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_ship_to_location_id          IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_demand_schedule              IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_expected_shipment_date       IN  DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  , p_promised_shipment_date       IN  DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  , p_volume                       IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_volume_uom                   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_weight                       IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_weight_uom                   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_ready_to_ship_flag           IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_initiate_planning_flag       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_initiate_shipping_flag       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_event_type                   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_currency                     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  -- 3749462 changed data type
  , p_invoice_amount               IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_revenue_amount               IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_event_date                   IN  DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  , p_event_number                 IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_organization_id              IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_bill_hold_flag               IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_project_functional_rate_type IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_project_functional_rate_date IN  DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  , p_project_functional_rate      IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_project_rate_type            IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_project_rate_date            IN  DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  , p_project_rate                 IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_funding_rate_type            IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_funding_rate_date            IN  DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  , p_funding_rate                 IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_pm_event_reference           IN  VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR -- 3651489 added parameter
  , x_action_out                   OUT NOCOPY  action_out_tbl_type
  , x_return_status                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  , x_msg_count                    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  , x_msg_data                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );


  /*#
 * This API is used to update attributes of a deliverable for a project.
 * @param p_api_version API standard: version number
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @param p_debug_mode Indicates to the system whether to display debug messages
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param p_deliverable_name Deliverable name
 * @rep:paraminfo {@rep:required}
 * @param p_deliverable_short_name Deliverable short name
 * @rep:paraminfo {@rep:required}
 * @param p_deliverable_type_id Identifier of the deliverable type
 * @param p_deliverable_owner_id Deliverable owner identifier
 * @param p_description Deliverable description
 * @param p_status_code Deliverable status code
 * @param p_due_date Deliverable due date
 * @param p_completion_date Deliverable completion date
 * @param p_progress_weight Progress weight
 * @param px_deliverable_id Unique identifier of the deliverable in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_pm_deliverable_reference Unique identifier of the deliverable in the external system
 * @rep:paraminfo {@rep:required}
 * @param p_task_id Task identifier of the task associated with the deliverable
 * @param p_task_source_reference Task reference of the task associated with the deliverable
 * @param p_project_id Unique identifier of the project
 * @param p_proj_source_reference Unique identifier of the project in the external system
 * @param p_action_in_tbl Table of deliverable actions that need to be created
 * @param x_action_out_tbl Table of successfully processed actions
 * @param p_item_id The identifier of the item. Applies only to item-based deliverables.
 * @param P_inventory_org_id The inventory organization identifier of the item. Applies only to item-based deliverables.
 * @param p_quantity The quantity of the item. Applies only to item-based deliverables.
 * @param p_uom_code The unit of measure code of the deliverable. Applies only to item-based deliverables.
 * @rep:paraminfo {@rep:precision 30}
 * @param p_unit_price The unit price of the deliverable. Applies only to item-based deliverables.
 * @param p_unit_number The unit number of the deliverable. Required when an item-based deliverable
 * is unit number-enabled.
 * @rep:paraminfo {@rep:precision 30}
 * @param p_currency_code The currency code of the deliverable. Applies only to item-based deliverables.
 * @rep:paraminfo {@rep:precision 15}
 * @param p_pm_source_code Identifier of the external system
 * @param x_msg_count API standard: number of error messages
 * @param x_msg_data API standard: error message
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Deliverable
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_PROJ_DELIVERABLE
 * @rep:compatibility S
 */
PROCEDURE update_deliverable
(   p_api_version            IN  NUMBER     := 1.0
  , p_init_msg_list          IN  VARCHAR2   := 'F'
  , p_commit                 IN  VARCHAR2   := FND_API.G_FALSE
  , p_debug_mode             IN  VARCHAR2   := 'N'
  , x_return_status          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  , p_deliverable_name       IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_deliverable_short_name IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_deliverable_type_id    IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_deliverable_owner_id   IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_description            IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_status_code            IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_due_date               IN  DATE       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  , p_completion_date        IN  DATE       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  , p_progress_weight        IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , px_deliverable_id        IN OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  , p_pm_deliverable_reference IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  -- for bug# 3729250
--  , p_carrying_out_org_id    IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_task_id                IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_task_source_reference  IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_project_id             IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_proj_source_reference  IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_action_in_tbl          IN  action_in_tbl_type := G_deliverable_actions_in_tbl -- 3435905 passing default
  , x_action_out_tbl         OUT NOCOPY action_out_tbl_type --File.Sql.39 bug 4440895
  , p_item_id                IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , P_inventory_org_id       IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_quantity               IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_uom_code               IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  -- for bug# 3729250
--  , p_item_description       IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_unit_price             IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  -- for bug# 3729250
  , p_unit_number            IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_currency_code          IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_pm_source_code         IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR              /* Bug no. 3651113 */
  , x_msg_count              OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  , x_msg_data               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) ;


/*#
 * This API is used to update a deliverable action for a deliverable.
 * @param p_api_version API standard: version number
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_debug_mode Indicates to the system whether to display debug messages
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @param p_action_name Deliverable action name
 * @param p_action_owner_id Action owner identifier
 * @param p_function_code Deliverable action function code
 * @param p_due_date Due date of the deliverable action
 * @param p_description Description of the action
 * @param p_completion_date Completion date
 * @param p_pm_source_code Unique identifier of the external system
 * @param p_pm_action_reference Unique identifier of the deliverable action in the external system
 * @param p_action_id Unique identifier of the deliverable action
 * @param p_deliverable_reference Unique identifier of the deliverable in the external system
 * @param p_deliverable_id Unique identifier of the deliverable in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_pm_proj_reference Unique identifier of the project in the external system
 * @param p_project_id Unique identifier of the project
 * @param p_financial_task_reference Unique identifier of the financial task
 * @param p_financial_task_id Identifier of the financial task
 * @param p_destination_type_code The destination type code of the deliverable action
 * @rep:paraminfo {@rep:precision 30}
 * @param p_receiving_org_id The identifier of the inventory organization that will receive the item
 * @param p_receiving_location_id The location (address) identifier where the item will be received. The
 * RECEIVING_LO CATION_ID must be related to the RECEIVING_ORG_ID.
 * @param p_po_need_by_date The date by which the purchase order is needed
 * @param p_vendor_id The identifier of the vendor that will supply the object
 * @param p_vendor_site_code The location (address) code of the vendor from where the object will be supplied
 * @param p_Quantity Quantity for procurement deliverable action
 * @param p_uom_code The unit of measure code for procurement deliverable action
 * @rep:paraminfo {@rep:precision 30}
 * @param p_unit_price The unit price of the object. The unit price is needed only for non-item
 * deliverable procurement actions.
 * @param p_exchange_rate_type Exchange rate type for procurement deliverable actions
 * @param p_exchange_rate_date Exchange rate date for procurement deliverable actions
 * @param p_exchange_rate Exchange rate for procurement deliverable actions
 * @param p_expenditure_type The expenditure type. This is needed only for non-item based deliverable procurement actions.
 * @param p_expenditure_org_id Expenditure organization identifier for procurement deliverable actions
 * @param p_expenditure_item_date Expenditure item date for procurement deliverable actions
 * @param p_requisition_line_type_id The requisition line type identifier. This can only have a type of AMOUNT.
 * The requisition line type is needed only for non-item based deliverable procurement actions.
 * @param p_category_id The item category identifier. This is needed only for non-item based deliverable procurement actions.
 * @param p_ready_to_procure_flag Flag that indicates if an item is ready to be procured
 * @rep:paraminfo {@rep:precision 1}
 * @param p_initiate_procure_flag Flag that indicates if a procurement action should be initiated
 * @rep:paraminfo {@rep:precision 1}
 * @param p_ship_from_organization_id The inventory organization identifier of the inventory organization that will ship the item
 * @param p_ship_from_location_id The location (address) identifier where the item will be shipped.
 * The P_SHIP_FROM_LOCATION_ID must be related to the P_SHIP_FROM_ORGANIZATION_ID.
 * @param p_ship_to_organization_id The customer account identifier to which the item will be shipped
 * @param p_ship_to_location_id The customer location (address) identifier to where the item will be shipped
 * The P_SHIP_TO_LOCATION_ID must be related to the P_SHIP_TO_ORGANIZATION_ID.
 * @param p_demand_schedule Demand schedule
 * @rep:paraminfo {@rep:precision 10}
 * @param p_expected_shipment_date Expected shipment date
 * @param p_promised_shipment_date Promised shipment date
 * @param p_volume The volume of each object to be shipped. The volume is needed only for non-item shipping.
 * @param p_volume_uom The volume unit of measure of each object to be shipped.
 * The volume unit of measure is needed only for non-item shipping.
 * @rep:paraminfo {@rep:precision 10}
 * @param p_weight The weight of each object to be shipped. The weight is needed only for non-item shipping.
 * @param p_weight_uom The weight unit of measure of each object to be shipped. The weight unit of
 * measure is needed only for non-item shipping.
 * @rep:paraminfo {@rep:precision 10}
 * @param p_ready_to_ship_flag Flag that indicates if an item is ready to be shiped.
 * @rep:paraminfo {@rep:precision 1}
 * @param p_initiate_planning_flag Flag that indicates if planning should be initiated.
 * @rep:paraminfo {@rep:precision 1}
 * @param p_initiate_shipping_flag Flag that indicates if shipping should be initiated.
 * @rep:paraminfo {@rep:precision 1}
 * @param p_event_type Billing event type
 * @rep:paraminfo {@rep:precision 30}
 * @param p_currency Currency code for the billing event
 * @rep:paraminfo {@rep:precision 30}
 * @param p_invoice_amount Invoice amount for the billing
 * @param p_revenue_amount Revenue amount for the billing event
 * @param p_event_date Event date for the billing event
 * @param p_event_number Event number for the billing event
 * @param p_organization_id Organization identifier of the organization associated with the billing event
 * @param p_bill_hold_flag Flag that indicates if a billing event is on hold
 * @rep:paraminfo {@rep:precision 1}
 * @param p_project_functional_rate_type Rate type for project functional currency for the billing event
 * @rep:paraminfo {@rep:precision 30}
 * @param p_project_functional_rate_date Rate date for project functional currency for the billing event
 * @param p_project_functional_rate Rate for project functional currency for the billing event
 * @param p_project_rate_type Rate type for project currency for the billing event
 * @rep:paraminfo {@rep:precision 30}
 * @param p_project_rate_date Rate date for project currency for the billing event
 * @param p_project_rate Rate for project currency for the billing event
 * @param p_funding_rate_type Rate type for funding currency for the billing event
 * @rep:paraminfo {@rep:precision 30}
 * @param p_funding_rate_date Rate date for funding currency for the billing event
 * @param p_funding_rate Rate for funding currency for the billing event
 * @param p_pm_event_reference The unique identifier of the billing event in the external system
 * @rep:paraminfo {@rep:precision 25}
 * @param x_action_out Table of successfully processed actions
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param x_msg_count API standard: number of error messages
 * @param x_msg_data API standard: error message
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Deliverable Action
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_PROJ_DELIVERABLE
 * @rep:compatibility S
 */
PROCEDURE update_deliverable_action
(   p_api_version                  IN  NUMBER   := 1.0
  , p_init_msg_list                IN  VARCHAR2 := FND_API.G_TRUE
  , p_debug_mode                   IN  VARCHAR2 := FND_API.G_FALSE
  , p_commit                       IN  VARCHAR2 := FND_API.G_FALSE
  , p_action_name                  IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_action_owner_id              IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_function_code                IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_due_date                     IN  DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  , p_description                  IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_completion_date              IN  DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  , p_pm_source_code               IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_pm_action_reference          IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  -- added for bug# 3729250
  , p_action_id                    IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  -- for bug# 3729250
--  , p_carrying_out_org_id          IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_deliverable_reference        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_deliverable_id               IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  -- added for bug# 3729250
  , p_pm_proj_reference            IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_project_id                   IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_financial_task_id            IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  -- added for bug# 3729250
  , p_financial_task_reference     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_destination_type_code        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_receiving_org_id             IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_receiving_location_id        IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_po_need_by_date              IN  DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  , p_vendor_id                    IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_vendor_site_code             IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--  , p_project_currency             IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_Quantity                     IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_uom_code                     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_unit_price                   IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_exchange_rate_type           IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_exchange_rate_date           IN  DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  , p_exchange_rate                IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_expenditure_type             IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_expenditure_org_id           IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_expenditure_item_date        IN  DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  , p_requisition_line_type_id     IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_category_id                  IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_ready_to_procure_flag        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_initiate_procure_flag        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_ship_from_organization_id    IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_ship_from_location_id        IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_ship_to_organization_id      IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_ship_to_location_id          IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_demand_schedule              IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_expected_shipment_date       IN  DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  , p_promised_shipment_date       IN  DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  , p_volume                       IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_volume_uom                   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_weight                       IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_weight_uom                   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_ready_to_ship_flag           IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_initiate_planning_flag       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_initiate_shipping_flag       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_event_type                   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_currency                     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  -- 3749474 changed data type
  , p_invoice_amount               IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_revenue_amount               IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_event_date                   IN  DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  , p_event_number                 IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_organization_id              IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_bill_hold_flag               IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_project_functional_rate_type IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_project_functional_rate_date IN  DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  , p_project_functional_rate      IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_project_rate_type            IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_project_rate_date            IN  DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  , p_project_rate                 IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_funding_rate_type            IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_funding_rate_date            IN  DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  , p_funding_rate                 IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_pm_event_reference           IN  VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR -- 3651489 added parameter
  , x_action_out                   OUT NOCOPY  action_out_tbl_type
  , x_return_status                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  , x_msg_count                    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  , x_msg_data                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

/*#
 * This API is used to delete a deliverable for a project.
 * @param p_api_version API standard: version number
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @param p_pm_source_code Identifier of the external system
 * @param p_pm_project_reference Unique identifier of the project in the external system
 * @param p_project_id Unique identifier of the project in Oracle Projects
 * @param p_deliverable_id Unique identifier of the deliverable
 * @param p_pm_dlv_source_reference Unique identifier of the deliverable in the external system
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @param x_msg_count API standard: number of error messages
 * @param x_msg_data API standard: error message
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Deliverable
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_PROJ_DELIVERABLE
 * @rep:compatibility S
 */
Procedure  Delete_Deliverables (
   p_api_version              IN  NUMBER   := 1.0
  ,p_init_msg_list            IN  VARCHAR2 := FND_API.G_FALSE
  ,p_commit               IN  VARCHAR2 := FND_API.G_FALSE
  ,p_pm_source_code           IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_pm_project_reference     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_project_id               IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  -- for bug# 3729250
  ,p_deliverable_id           IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_pm_dlv_source_reference  IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,x_return_status            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count                OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


/*#
 * This API is used to delete a deliverable action for a deliverable.
 * @param p_api_version API standard: version number
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @param p_pm_source_code Identifier of the external system
 * @param p_pm_project_reference Unique identifier of the project in the external system
 * @param p_project_id Unique identifier of the project in Oracle Projects
 * @param p_pm_deliverable_reference Unique identifier of the deliverable in the external system
 * @rep:paraminfo {@rep:required}
 * @param p_deliverable_id Unique identifier of the deliverable
 * @rep:paraminfo {@rep:required}
 * @param p_action_source_reference Unique identifier of the deliverable action in the external system
 * @param p_action_id Unique identifier of the deliverable action
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @param x_msg_count API standard: number of error messages
 * @param x_msg_data API standard: error message
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Deliverable Action
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_PROJ_DELIVERABLE
 * @rep:compatibility S
 */
PROCEDURE delete_deliverable_actions
(  p_api_version              IN  NUMBER   := 1.0       -- 3749480 changed default value
  ,p_init_msg_list            IN  VARCHAR2 := FND_API.G_FALSE
  ,p_commit               IN  VARCHAR2 := FND_API.G_FALSE
  ,p_pm_source_code           IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_pm_project_reference     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_project_id               IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  -- for bug# 3729250 , changed datatype from NUMBER to VARCHAR2
  ,p_pm_deliverable_reference IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_deliverable_id           IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  -- for bug# 3729250 , changed datatype from NUMBER to VARCHAR2
  ,p_action_source_reference  IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_action_id                IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,x_return_status            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count                OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


/*#
 * This API is used to associate a deliverable with a task.
 * @param p_api_version API standard: version number
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @param p_debug_mode Indicates whether to display debug messages
 * @param p_pm_source_code Identifier of the external system
 * @param p_pm_project_reference Unique identifier of the project in the external system
 * @param p_project_id Unique identifier of the project in Oracle Projects
 * @param p_pm_task_reference Unique identifier of the task in the external system
 * @param p_task_id  Unique identifier of the task
 * @param p_deliverable_reference Unique identifier of the deliverable in the external system
 * @rep:paraminfo {@rep:required}
 * @param p_deliverable_id Unique identifier of the deliverable
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @param x_msg_count API standard: number of error messages
 * @param x_msg_data API standard: error message
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Associate Deliverable with Task
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_PROJ_DELIVERABLE
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:compatibility S
 */
Procedure ASSOCIATE_DLV_TO_TASK (
      p_api_version              IN  NUMBER   := 1.0
     ,p_init_msg_list            IN  VARCHAR2 := FND_API.G_TRUE
     ,p_commit                   IN  VARCHAR2 := FND_API.G_FALSE
     ,p_debug_mode               IN  VARCHAR2 := FND_API.G_FALSE
     ,p_pm_source_code           IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     -- added for bug# 3729250
     ,p_pm_project_reference     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     ,p_project_id               IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     -- added for bug# 3729250
     ,p_pm_task_reference        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     ,p_task_id                  IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     -- added for bug# 3729250
     ,p_deliverable_reference    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     ,p_deliverable_id           IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,x_return_status            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     );

 /*#
  * This API is used to associate a deliverable with a task assignment.
  * @param p_api_version API standard: version number
  * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
  * @param p_commit API API standard (default = F): indicates if the transaction will be committed
  * @param p_debug_mode Indicates whether to display debug messages
  * @param p_pm_source_code Identifier of the external system
  * @param p_pm_project_reference Unique identifier of the project in the external system
  * @param p_project_id Unique identifier of the project in Oracle Projects
  * @param p_pm_task_asgmt_reference Unique identifier of the task assignment in the external system
  * @param p_task_assign_id Unique identifier of the task assignment
  * @param p_deliverable_reference Unique identifier of the deliverable in the external system
  * @rep:paraminfo {@rep:required}
  * @param p_deliverable_id Unique identifier of the deliverable
  * @rep:paraminfo {@rep:required}
  * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
  * @param x_msg_count API standard: number of error messages
  * @param x_msg_data API standard: error message
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Associate Deliverable to Task Assignment
  * @rep:category BUSINESS_ENTITY PA_PROJECT
  * @rep:category BUSINESS_ENTITY PA_PROJ_DELIVERABLE
  * @rep:category BUSINESS_ENTITY PA_TASK_RESOURCE
  * @rep:compatibility S
  */
Procedure ASSOCIATE_DLV_TO_TASK_ASSIGN (
      p_api_version              IN  NUMBER   := 1.0
     ,p_init_msg_list            IN  VARCHAR2 := FND_API.G_TRUE
     ,p_commit                   IN  VARCHAR2 := FND_API.G_FALSE
     ,p_debug_mode               IN  VARCHAR2 := FND_API.G_FALSE
     ,p_pm_source_code           IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     -- added for bug# 3729250
     ,p_pm_project_reference     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     ,p_project_id               IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_pm_task_asgmt_reference  IN  VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     ,p_task_assign_id           IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     -- added for bug# 3729250
     ,p_deliverable_reference    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     ,p_deliverable_id           IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,x_return_status            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     );


 /*#
 * This API is used to delete a deliverable-to-task association.
 * @param p_api_version API standard: version number
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @param p_pm_source_code Identifier of the external system
 * @param p_pm_project_reference Unique identifier of the project in the external system
 * @param p_project_id Unique identifier of the project in Oracle Projects
 * @param p_task_reference Unique identifier of the task in the external system
 * @param p_task_id  Unique identifier of the task
 * @param p_pm_deliverable_reference Unique identifier of the deliverable in the external system
 * @rep:paraminfo {@rep:required}
 * @param p_deliverable_id Unique identifier of the deliverable
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @param x_msg_count API standard: number of error messages
 * @param x_msg_data API standard: error message
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Deliverable-Task Association
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_PROJ_DELIVERABLE
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:compatibility S
 */
Procedure DELETE_DLV_TO_TASK_ASSCN (
      p_api_version              IN NUMBER   :=1.0
     ,p_init_msg_list            IN VARCHAR2 :=FND_API.G_TRUE
     ,p_commit                   IN VARCHAR2 :=FND_API.G_FALSE
     ,p_pm_source_code           IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     ,p_pm_project_reference     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     ,p_project_id               IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_task_reference           IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     ,p_task_id                  IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_pm_deliverable_reference IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     ,p_deliverable_id           IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,x_return_status            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     );

-- 3729250 Added procedure to spec, procedure was already defined in body
-- added p_pm_project_reference IN parameter also

/*#
 * This API is used to delete a deliverable-to-task assignment association.
 * @param p_api_version API standard: version number
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @param p_debug_mode  Indicates whether to display debug messages
 * @param p_pm_source_code Identifier of the external system
 * @param p_project_id Unique identifier of the project in Oracle Projects
 * @param p_pm_project_reference Unique identifier of the project in the external system
 * @param p_task_assign_id Unique identifier of the task assignment
 * @param p_pm_task_asgmt_reference Unique identifier of the task assignment in the external system
 * @param p_deliverable_id Unique identifier of the deliverable
 * @rep:paraminfo {@rep:required}
 * @param p_pm_deliverable_reference Unique identifier of the deliverable in the external system
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @param x_msg_count API standard: number of error messages
 * @param x_msg_data API standard: error message
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Deliverable-Task Assignment Association
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_PROJ_DELIVERABLE
 * @rep:category BUSINESS_ENTITY PA_TASK_RESOURCE
 * @rep:compatibility S
 */
Procedure DELETE_DLV_TO_TASK_ASSIGN (
      p_api_version              IN  NUMBER   := 1.0
     ,p_init_msg_list            IN  VARCHAR2 := FND_API.G_TRUE
     ,p_commit                   IN  VARCHAR2 := FND_API.G_FALSE
     ,p_debug_mode               IN  VARCHAR2 := FND_API.G_FALSE
     ,p_pm_source_code           IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     ,p_project_id               IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_pm_project_reference     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     ,p_task_assign_id           IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_pm_task_asgmt_reference  IN VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     ,p_deliverable_id           IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM   -- Added for 3888280
     ,p_pm_deliverable_reference IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  -- Added for 3888280
     ,x_return_status            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     );

-- 3435905 FP M Changes for deliverables : End
-- Added by rtarway for FP.M Changes in Mapping and Set Financial Task

/*#
 * This API is used to update an existing mapping between a workplan task and a financial task for a project
 * having split-mapped structure sharing between workplan and financial structures.
 * @param p_api_version API standard: version number
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @param p_debug_mode Indicates to the system whether to display debug messages (default = N)
 * @param px_mapped_task_id The unique identifier of the financial task in Oracle Projects
 * @param p_mapped_task_reference The reference code that uniquely identifies the financial task in the external system
 * @param p_mapped_task_name Name of the financial task
 * @param p_wkp_task_id The unique identifier of the workplan task
 * @param p_wkp_task_name Name of the workplan task
 * @param p_wkp_structure_version_id The unique identifier of the workplan structure in Oracle Projects
 * @param p_wkp_task_reference The reference code that uniquely identifies the workplan task in the external system
 * @param p_project_id The unique identifier of the project in Oracle Projects
 * @param p_proj_source_reference The reference code that uniquely identifies the project in the external system
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data API standard: error message
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Mapping
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:compatibility S
 */
PROCEDURE update_mapping
(   p_api_version                  IN        NUMBER     := 1.0
  , p_init_msg_list                IN        VARCHAR2   := FND_API.G_TRUE
  , p_commit                       IN        VARCHAR2   := FND_API.G_TRUE
  , p_debug_mode                   IN        VARCHAR2   := 'N'
  , px_mapped_task_id              IN        NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_mapped_task_reference        IN        VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_mapped_task_name             IN        VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_wkp_task_id                  IN        NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_wkp_task_name                IN        VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_wkp_structure_version_id     IN        NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_wkp_task_reference           IN        VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_project_id                   IN        NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_proj_source_reference        IN        VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , x_return_status                OUT       NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  , x_msg_count                    OUT       NOCOPY NUMBER --File.Sql.39 bug 4440895
  , x_msg_data                     OUT       NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

/*#
 * This API is used to create a mapping between a workplan task and a financial task for a project
 * having split-mapped structure sharing between workplan and financial structures.
 * @param p_api_version API standard: version number
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @param p_debug_mode Indicates to the system whether to display debug messages (default = N)
 * @param px_mapped_task_id The unique identifier of the financial task in Oracle Projects
 * @param p_mapped_task_reference The reference code that uniquely identifies the financial task in the external system
 * @param p_mapped_task_name Name of the mapped financial Task
 * @param p_wkp_task_id The unique identifier of the workplan task
 * @param p_wkp_task_name Name of the workplan task
 * @param p_wkp_structure_version_id The unique identifier of the workplan structure version in Oracle Projects
 * @param p_wkp_task_reference The reference code that uniquely identifies the workplan task in the external system
 * @param p_project_id The unique identifier of the project in Oracle Projects
 * @param p_proj_source_reference The reference code that uniquely identifies the project in the external system
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data API standard: error message
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Mapping
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:compatibility S
 */
  PROCEDURE create_mapping
(   p_api_version                  IN        NUMBER     := 1.0
  , p_init_msg_list                IN        VARCHAR2   := FND_API.G_TRUE
  , p_commit                       IN        VARCHAR2   := FND_API.G_TRUE
  , p_debug_mode                   IN        VARCHAR2   := 'N'
  , px_mapped_task_id              IN         NUMBER
  , p_mapped_task_reference        IN        VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_mapped_task_name             IN        VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_wkp_task_id                  IN        NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_wkp_task_name                IN        VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_wkp_structure_version_id     IN        NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_wkp_task_reference           IN        VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_project_id                   IN        NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_proj_source_reference        IN        VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , x_return_status                OUT       NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  , x_msg_count                    OUT       NOCOPY NUMBER --File.Sql.39 bug 4440895
  , x_msg_data                     OUT       NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) ;

PROCEDURE process_tasks_table
(   p_api_version                  IN        NUMBER     := 1.0
  , p_init_msg_list                IN        VARCHAR2   := FND_API.G_TRUE
  , p_debug_mode                   IN        VARCHAR2   := 'N'
  , p_structure_type               IN        VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , p_tasks_in_tbl                 IN OUT       NOCOPY task_in_tbl_type --File.Sql.39 bug 4440895
  , p_project_id                   IN        NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  , p_proj_source_reference        IN        VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  , x_return_status                OUT       NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  , x_msg_count                    OUT       NOCOPY NUMBER --File.Sql.39 bug 4440895
  , x_msg_data                     OUT       NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) ;

  /*#
   * This API is used to delete an existing mapping between a workplan task and a financial task for a project
   * having split-mapped structure sharing between workplan and financial structures.
   * @param p_api_version API standard: version number
   * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
   * @param p_commit API standard (default = F): indicates if the transaction will be committed
   * @param p_debug_mode Indicates to the system whether to display debug messages (default = N)
   * @param p_wp_task_version_id The unique identifier of a workplan task version in Oracle Projects
   * @param p_fp_task_version_id The unique identifier of the financial task version in Oracle Projects
   * @param p_wp_task_id The unique identifier of the workplan task in Oracle Projects
   * @param p_fp_task_id The unique identifier of the financial task in Oracle Projects
   * @param p_pm_wp_task_reference The reference code that uniquely identifies the workplan task in the external system
   * @param p_pm_fp_task_reference The reference code that uniquely identifies the financial task in the external system
   * @param p_wp_structure_version_id The unique identifier of the workplan structure version in Oracle Projects
   * @param p_project_id The unique identifier of the project in Oracle Projects
   * @param p_proj_source_reference The reference code that uniquely identifies the project in the external system
   * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
   * @rep:paraminfo {@rep:required}
   * @param x_msg_count API standard: number of error messages
   * @rep:paraminfo {@rep:required}
   * @param x_msg_data API standard: error message
   * @rep:paraminfo {@rep:required}
   * @rep:scope public
   * @rep:lifecycle active
   * @rep:displayname Delete Mapping
   * @rep:category BUSINESS_ENTITY PA_TASK
   * @rep:compatibility S
   */
PROCEDURE Delete_Mapping
(
   p_api_version              IN   NUMBER     := 1.0
 , p_init_msg_list            IN   VARCHAR2   := FND_API.G_TRUE
 , p_commit                   IN   VARCHAR2   := FND_API.G_TRUE
 , p_debug_mode               IN   VARCHAR2   := 'N'
 , p_wp_task_version_id       IN   NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 , p_fp_task_version_id       IN   NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 , p_wp_task_id               IN   NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 , p_fp_task_id               IN   NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 , p_pm_wp_task_reference     IN   VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 , p_pm_fp_task_reference     IN   VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 , p_wp_structure_version_id  IN   NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 , p_project_id               IN   NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 , p_proj_source_reference    IN   VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 , x_return_status            OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 , x_msg_count                OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
 , x_msg_data                 OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);
-- Added by rtarway for FP.M Changes in Mapping and Set Financial Task

-- added by hsiu
/*#
 * This procedure is used to create an intra-project dependency.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @rep:paraminfo {@rep:precision 1}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @rep:paraminfo {@rep:precision 1}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1}
 * @param p_pm_product_code The identifier of the external project management system
 * from which the project is imported
 * @rep:paraminfo {@rep:required}
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system
 * @rep:paraminfo {@rep:precision 25}
 * @param p_pa_project_id The unique identifier of the project
 * @rep:paraminfo {@rep:required}
 * @param p_structure_version_id Unique identifier of the of the workplan structure version from which
 * the intra project dependency is created
 * @rep:paraminfo {@rep:required}
 * @param p_pm_task_reference The identifier of the task in the external project
 * management system from which the budget is imported
 * @rep:paraminfo {@rep:required}
 * @param p_pa_task_id Unique identifier of the task
 * @rep:paraminfo {@rep:required}
 * @param p_pm_pred_reference The identifier of the predecessor task in the external project
 * management system from which the budget is imported
 * @rep:paraminfo {@rep:required}
 * @param p_pa_pred_id Unique identifier of the predecessor task
 * @rep:paraminfo {@rep:required}
 * @param p_type Type of dependency
 * @param p_lag_days Lag days of the dependency
 * @param p_comments Comments for the dependency
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Dependency
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:compatibility S
 */
PROCEDURE Create_Dependency(
  p_api_version_number          IN  NUMBER   :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit                      IN  VARCHAR2 := FND_API.G_FALSE
 ,p_init_msg_list               IN  VARCHAR2 := FND_API.G_FALSE
 ,p_msg_count                   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_msg_data                    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_return_status               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_pm_product_code     IN  VARCHAR2
 ,p_pm_project_reference    IN  VARCHAR2
 ,p_pa_project_id       IN  NUMBER
 ,p_structure_version_id        IN  NUMBER
 ,p_pm_task_reference           IN  VARCHAR2
 ,p_pa_task_id                  IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_pred_reference           IN  VARCHAR2
 ,p_pa_pred_id                  IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_type                        IN  VARCHAR2 := 'FS'
 ,p_lag_days                    IN  NUMBER   := 0
 ,p_comments                    IN  VARCHAR2 := NULL
);

/*#
 * This procedure is used to update an intra-project dependency.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @rep:paraminfo {@rep:precision 1}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @rep:paraminfo {@rep:precision 1}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1}
 * @param p_pm_product_code The identifier of the external project management system
 * from which the project is imported
 * @rep:paraminfo {@rep:required}
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system
 * @rep:paraminfo {@rep:precision 25}
 * @param p_pa_project_id The unique identifier of the project
 * @rep:paraminfo {@rep:required}
 * @param p_structure_version_id Unique identifier of the of the workplan structure version from which
 * the intra project dependency is created
 * @rep:paraminfo {@rep:required}
 * @param p_pm_task_reference The identifier of the task in the external project
 * management system from which the budget is imported
 * @rep:paraminfo {@rep:required}
 * @param p_pa_task_id Unique identifier of the task
 * @rep:paraminfo {@rep:required}
 * @param p_pm_pred_reference The identifier of the predecessor task in the external project
 * management system from which the budget is imported
 * @rep:paraminfo {@rep:required}
 * @param p_pa_pred_id Unique identifier of the predecessor task
 * @rep:paraminfo {@rep:required}
 * @param p_type Type of dependency
 * @param p_lag_days Lag days of the dependency
 * @param p_comments Comments for the dependency
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Dependency
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:compatibility S
 */

PROCEDURE Update_Dependency(
  p_api_version_number          IN  NUMBER   :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit                      IN  VARCHAR2 := FND_API.G_FALSE
 ,p_init_msg_list               IN  VARCHAR2 := FND_API.G_FALSE
 ,p_msg_count                   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_msg_data                    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_return_status               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_pm_product_code             IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pm_project_reference        IN  VARCHAR2
 ,p_pa_project_id       IN  NUMBER
 ,p_structure_version_id        IN  NUMBER
 ,p_pm_task_reference           IN  VARCHAR2
 ,p_pa_task_id                  IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_pred_reference           IN  VARCHAR2
 ,p_pa_pred_id                  IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_type                        IN  VARCHAR2 := 'FS'
 ,p_lag_days                    IN  NUMBER   := 0
 ,p_comments                    IN  VARCHAR2 := NULL
);

/*#
 * This procedure is used to delete an intra-project dependency.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @rep:paraminfo {@rep:precision 1}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @rep:paraminfo {@rep:precision 1}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1}
 * @param p_pm_product_code The identifier of the external project management system
 * from which the project is imported
 * @rep:paraminfo {@rep:required}
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system
 * @rep:paraminfo {@rep:precision 25}
 * @param p_pa_project_id The unique identifier of the project
 * @rep:paraminfo {@rep:required}
 * @param p_structure_version_id Unique identifier of the workplan structure version from which
 * the intra project dependency is created
 * @rep:paraminfo {@rep:required}
 * @param p_pm_task_reference The identifier of the task in the external project
 * management system from which the budget is imported
 * @rep:paraminfo {@rep:required}
 * @param p_pa_task_id Unique identifier of the task
 * @rep:paraminfo {@rep:required}
 * @param p_pm_pred_reference The identifier of the predecessor task in the external project
 * management system from which the budget is imported
 * @rep:paraminfo {@rep:required}
 * @param p_pa_pred_id Unique identifier of the predecessor task
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Dependency
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:compatibility S
 */

PROCEDURE Delete_Dependency(
  p_api_version_number          IN  NUMBER   :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit                      IN  VARCHAR2 := FND_API.G_FALSE
 ,p_init_msg_list               IN  VARCHAR2 := FND_API.G_FALSE
 ,p_msg_count                   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_msg_data                    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_return_status               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_pm_product_code     IN  VARCHAR2
 ,p_pm_project_reference    IN  VARCHAR2
 ,p_pa_project_id       IN  NUMBER
 ,p_structure_version_id        IN  NUMBER
 ,p_pm_task_reference           IN  VARCHAR2
 ,p_pa_task_id                  IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_pred_reference           IN  VARCHAR2
 ,p_pa_pred_id                  IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
);

-- Begin fix for Bug # Bug # 4096218.
/*#
 * This API is used to determine whether tasks deleted in an external scheduling system
 * such as Microsoft Project would be deleted in Oracle Projects when both the systems are
 * integrated. Tasks are deleted immediately in Oracle Projects
 * if no published version exists, and are marked for deletion or cancelled when the
 * working workplan version is published in Oracle Projects. This procedure prevents
 * tasks from being deleted if they have transactions.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @rep:paraminfo {@rep:precision 1}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_project_id The reference code that uniquely identifies the project in Oracle Projects
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system
 * @param p_task_id The reference code that uniquely identifies the task in a project in Oracle Projects
 * @param p_pm_task_reference The reference code that uniquely identifies the task wit a project in the external system
 * @param p_task_version_id The reference code that uniquely identifies the task version of the task
 * in a project in Oracle Projects
 * @param p_structure_type  The structure type (default = FINANCIAL)
 * @param p_perform_check_delete_task_ok The flag that decides which
 * mode this API will be called in (default = N). If this flag is set to N the value of
 * the flag: P_CHECK_TASK_MFD_FLAG will be decided by the current
 * task status code of the task.If this flag is set to Y the value of
 * the flag: P_CHECK_TASK_MFD_FLAG will be decided by performing a
 * check to see if the task can be deleted immediately from the structure.
 * @param p_check_task_mfd_flag This flag returns the following values:
 * Y if the task can be deleted immediately from the structure.
 * M if the task can be marked for delete from the structure and deleted later in a subsequent publishing flow.
 * N if the task cannot be deleted from the structure.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Check Delete Task
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:compatibility S
 */

PROCEDURE check_task_mfd
( p_api_version_number          IN      NUMBER
 , p_init_msg_list              IN      VARCHAR2        := FND_API.G_FALSE
 , p_return_status              OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 , p_msg_count                  OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
 , p_msg_data                   OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 , p_project_id                 IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 , p_pm_project_reference       IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 , p_task_id                    IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 , p_pm_task_reference          IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 , p_task_version_id            IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 , p_structure_type             IN      VARCHAR2        := 'FINANCIAL'
 , p_perform_check_delete_task_ok IN    VARCHAR2        := 'N'
 , p_check_task_mfd_flag        OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- 4096218 Changed OUT param name to x_deleted_task_ids (earlier it was x_deleted_task_ver_ids)

/*#
 * When you publish a version-enabled workplan in Oracle Projects, tasks in the working
 * version with a status of To Be Deleted are either deleted or set to a Canceled status.
 * The GET_DELETED_TASKS_FROM_OP procedure retrieves the list of deleted tasks in
 * Oracle Projects and displays the tasks in an integrated external system such as
 * Microsoft Project.
 * @param x_deleted_task_ids The list of tasks that were previously marked for deletion and
 * have now been deleted from the workplan structure
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1}
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Tasks from Oracle Projects
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:compatibility S
 */

PROCEDURE get_deleted_tasks_from_op
(
 x_deleted_task_ids      OUT NOCOPY PA_NUM_1000_NUM, --File.Sql.39 bug 4440895
 x_return_status             OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                 OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);
-- End fix for Bug # Bug # 4096218.


-- Bug 5436264 : AMG API FOR PROCESS STRUCTURE UPDATES

PROCEDURE process_structure_updates
(p_api_version_number           IN      NUMBER          := 1.0
, p_init_msg_list               IN      VARCHAR2        := FND_API.G_FALSE
, p_commit                      IN      VARCHAR2        := FND_API.G_FALSE
, p_return_status               OUT     NOCOPY VARCHAR2
, p_msg_count                   OUT     NOCOPY NUMBER
, p_msg_data                    OUT     NOCOPY VARCHAR2
, p_structure_version_id        IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pa_project_id               IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_project_reference	IN	VARCHAR2 	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_process_mode                IN      VARCHAR2        := 'ONLINE'
, p_calling_context             IN      VARCHAR2        := 'AMG');  -- Bug 6727014


-- Bug 6727014. Creating a wrapper on process_structure_updates to be used in new concurrent request

PROCEDURE process_structure_updates_wrp
(errbuf                         OUT NOCOPY   VARCHAR2
, retcode                       OUT NOCOPY   VARCHAR2
, p_operating_unit              IN           VARCHAR2
, p_project_num_from            IN           VARCHAR2
, p_project_num_to              IN           VARCHAR2
);


-- Bug # 5072032.

PROCEDURE SETUP_PROJECT_AS_PROGRAM
(p_api_version			IN	NUMBER		:= 1.0
, p_init_msg_list		IN	VARCHAR2	:= FND_API.G_TRUE
, p_commit			IN	VARCHAR2	:= FND_API.G_FALSE
, p_debug_mode			IN	VARCHAR2	:= 'N'
, p_max_msg_count		IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_project_id			IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_project_reference	IN	VARCHAR2 	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_sys_program_flag		IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_allow_multi_program_rollup	IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, x_return_status		OUT	NOCOPY VARCHAR2
, x_msg_count			OUT	NOCOPY NUMBER
, x_msg_data			OUT	NOCOPY VARCHAR2);

PROCEDURE CREATE_PROGRAM_LINKS
(p_api_version			IN	NUMBER		:= 1.0
, p_init_msg_list		IN	VARCHAR2	:= FND_API.G_TRUE
, p_commit			IN	VARCHAR2	:= FND_API.G_FALSE
, p_debug_mode			IN	VARCHAR2	:= 'N'
, p_max_msg_count		IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_program_links_tbl		IN	PA_PROJECT_PUB.PROGRAM_LINKS_TBL_TYPE
, x_return_status		OUT	NOCOPY VARCHAR2
, x_msg_count			OUT	NOCOPY NUMBER
, x_msg_data			OUT	NOCOPY VARCHAR2);

PROCEDURE UPDATE_PROGRAM_LINK_COMMENTS
(p_api_version			IN	NUMBER		:= 1.0
, p_init_msg_list		IN	VARCHAR2	:= FND_API.G_TRUE
, p_commit			IN	VARCHAR2	:= FND_API.G_FALSE
, p_debug_mode			IN	VARCHAR2	:= 'N'
, p_max_msg_count		IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_program_links_tbl		IN	PA_PROJECT_PUB.PROGRAM_LINKS_TBL_TYPE
, x_return_status		OUT	NOCOPY VARCHAR2
, x_msg_count			OUT	NOCOPY NUMBER
, x_msg_data			OUT	NOCOPY VARCHAR2);

PROCEDURE DELETE_PROGRAM_LINK
(p_api_version			IN	NUMBER		:= 1.0
, p_init_msg_list		IN	VARCHAR2	:= FND_API.G_TRUE
, p_commit			IN	VARCHAR2	:= FND_API.G_FALSE
, p_debug_mode			IN	VARCHAR2	:= 'N'
, p_max_msg_count		IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_object_relationship_id	IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_parent_project_id		IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_parent_project_reference	IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_task_id			IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_task_reference		IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_task_version_id		IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_structure_type              IN      VARCHAR2        := 'WORKPLAN'
, p_sub_project_id		IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_sub_project_reference	IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, x_return_status		OUT	NOCOPY VARCHAR2
, x_msg_count			OUT	NOCOPY NUMBER
, x_msg_data			OUT	NOCOPY VARCHAR2);

-- End of Bug # 5072032.


--Bug 7525628

PROCEDURE UPDATE_FINANCIAL_ATTRIBUTES
(
 P_API_VERSION_NUMBER           IN  NUMBER,
 P_COMMIT                       IN  VARCHAR2,
 P_INIT_MSG_LIST                IN  VARCHAR2,
 P_PA_PROJECT_ID                IN  NUMBER,
 P_TASK_ID_TBL                  IN  SYSTEM.PA_NUM_TBL_TYPE,
 P_SERVICE_TYPE_CODE_TBL        IN  SYSTEM.PA_VARCHAR2_150_TBL_TYPE,
 P_CHARGEABLE_FLAG_TBL          IN  SYSTEM.PA_VARCHAR2_150_TBL_TYPE,
 P_BILLABLE_FLAG_TBL            IN  SYSTEM.PA_VARCHAR2_150_TBL_TYPE,
 X_MSG_COUNT                    OUT NOCOPY NUMBER,
 X_MSG_DATA                     OUT NOCOPY VARCHAR2,
 X_RETURN_STATUS                OUT NOCOPY VARCHAR2
);
-- End fix for Bug 7525628


end PA_PROJECT_PUB;

/
