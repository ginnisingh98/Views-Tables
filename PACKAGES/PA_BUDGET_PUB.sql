--------------------------------------------------------
--  DDL for Package PA_BUDGET_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BUDGET_PUB" AUTHID DEFINER as
/*$Header: PAPMBUPS.pls 120.13.12010000.2 2010/04/20 13:54:14 rthumma ship $*/
/*#
 * This package contains the public APIs for budgets.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Create Budget
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_BUDGET
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_FORECAST
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

--Global constants to be used in error messages
G_PKG_NAME              CONSTANT VARCHAR2(30) := 'PA_BUDGET_PUB';
G_BUDGET_CODE           CONSTANT VARCHAR2(6)  := 'BUDGET';
G_PROJECT_CODE          CONSTANT VARCHAR2(7)  := 'PROJECT';
G_TASK_CODE             CONSTANT VARCHAR2(4)  := 'TASK';
G_RESOURCE_CODE         CONSTANT VARCHAR2(8)  := 'RESOURCE';

--Locking exception
ROW_ALREADY_LOCKED      EXCEPTION;
PRAGMA EXCEPTION_INIT(ROW_ALREADY_LOCKED, -54);

--Package constant used for package version validation

G_API_VERSION_NUMBER    CONSTANT NUMBER := 1.0;


--Record and table type definitions
TYPE budget_line_in_rec_type IS RECORD
(pa_task_id                   NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,pm_task_reference            VARCHAR2(30)      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,resource_alias               VARCHAR2(80)      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR   --Bug # 3507156 : Patchset M: B and F impact changes : AMG
,resource_list_member_id      NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,budget_start_date            DATE              := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
,budget_end_date              DATE              := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
,period_name                  VARCHAR2(30)      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,description                  VARCHAR2(255)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,raw_cost                     NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,burdened_cost                NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,revenue                      NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,quantity                     NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,pm_product_code              VARCHAR2(30)      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,pm_budget_line_reference  pa_budget_lines.pm_budget_line_reference%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR --Bug 3231587
,attribute_category           VARCHAR2(30)      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,attribute1                   VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,attribute2                   VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,attribute3                   VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,attribute4                   VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,attribute5                   VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,attribute6                   VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,attribute7                   VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,attribute8                   VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,attribute9                   VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,attribute10                  VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,attribute11                  VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,attribute12                  VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,attribute13                  VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,attribute14                  VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,attribute15                  VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR

--Additional parameters for finplan model in FP L
--Changes the default of the following parameters from NULL to G_PA_MISS_XXX 24-APR-03 by Xin Liu
,txn_currency_code            pa_fp_txn_currencies.txn_currency_code%TYPE         :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,projfunc_cost_rate_type      pa_proj_fp_options.projfunc_cost_rate_type%TYPE     :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,projfunc_cost_rate_date_type pa_proj_fp_options.projfunc_cost_rate_date_type%TYPE:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,projfunc_cost_rate_date      pa_proj_fp_options.projfunc_cost_rate_date%TYPE     :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
,projfunc_cost_exchange_rate  pa_budget_lines.projfunc_cost_exchange_rate%TYPE    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,projfunc_rev_rate_type       pa_proj_fp_options.projfunc_rev_rate_type%TYPE      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,projfunc_rev_rate_date_type  pa_proj_fp_options.projfunc_rev_rate_date_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,projfunc_rev_rate_date       pa_proj_fp_options.projfunc_rev_rate_date%TYPE      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
,projfunc_rev_exchange_rate   pa_budget_lines.projfunc_rev_exchange_rate%TYPE     :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,project_cost_rate_type       pa_proj_fp_options.project_cost_rate_type%TYPE      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,project_cost_rate_date_type  pa_proj_fp_options.project_cost_rate_date_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,project_cost_rate_date       pa_proj_fp_options.project_cost_rate_date%TYPE      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
,project_cost_exchange_rate   pa_budget_lines.project_cost_exchange_rate%TYPE     :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,project_rev_rate_type        pa_proj_fp_options.project_rev_rate_type%TYPE       :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,project_rev_rate_date_type   pa_proj_fp_options.project_rev_rate_date_type%TYPE  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,project_rev_rate_date        pa_proj_fp_options.project_rev_rate_date%TYPE       :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
,project_rev_exchange_rate    pa_budget_lines.project_rev_exchange_rate%TYPE      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,change_reason_code           pa_budget_lines.change_reason_code%TYPE             :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
);

TYPE budget_line_in_tbl_type IS TABLE OF budget_line_in_rec_type
      INDEX BY BINARY_INTEGER;

TYPE row_id_tbl_type             IS TABLE OF rowid
      INDEX BY BINARY_INTEGER;
TYPE budget_line_id_tbl_type     IS TABLE OF pa_budget_lines.budget_line_id%TYPE
      INDEX BY BINARY_INTEGER;
TYPE res_assignment_id_tbl_type  IS TABLE OF pa_budget_lines.resource_assignment_id%TYPE
      INDEX BY BINARY_INTEGER;
TYPE date_tbl_type               IS TABLE OF pa_budget_lines.start_date%TYPE
      INDEX BY BINARY_INTEGER;
TYPE txn_currency_code_tbl_type  IS TABLE OF pa_budget_lines.txn_currency_code%TYPE
      INDEX BY BINARY_INTEGER;
TYPE period_name_tbl_type  IS TABLE OF pa_budget_lines.period_name%TYPE
      INDEX BY BINARY_INTEGER;
TYPE quantity_tbl_type           IS TABLE OF pa_budget_lines.quantity%TYPE
      INDEX BY BINARY_INTEGER;
TYPE display_quantity_tbl_type   IS TABLE OF pa_budget_lines.display_quantity%TYPE   --IPM Arch Enhancement Bug 4865563
      INDEX BY BINARY_INTEGER;
TYPE raw_cost_tbl_type           IS TABLE OF pa_budget_lines.raw_cost%TYPE
      INDEX BY BINARY_INTEGER;
TYPE burdened_cost_tbl_type      IS TABLE OF pa_budget_lines.burdened_cost%TYPE
      INDEX BY BINARY_INTEGER;
TYPE revenue_tbl_type            IS TABLE OF pa_budget_lines.revenue%TYPE
      INDEX BY BINARY_INTEGER;
TYPE task_id_tbl_type            IS TABLE OF pa_tasks.task_id%TYPE
      INDEX BY BINARY_INTEGER;
TYPE resource_list_id_tbl_type   IS TABLE OF pa_resource_list_members.resource_list_id%TYPE
      INDEX BY BINARY_INTEGER;
TYPE res_list_member_id_tbl_type IS TABLE OF pa_resource_list_members.resource_list_member_id%TYPE
      INDEX BY BINARY_INTEGER;
TYPE resource_id_tbl_type        IS TABLE OF pa_resource_list_members.resource_id%TYPE
      INDEX BY BINARY_INTEGER;
TYPE resource_name_tbl_type      IS TABLE OF pa_resources.name%TYPE
      INDEX BY BINARY_INTEGER;

TYPE rate_based_flag_tbl_type      IS TABLE OF pa_resource_assignments.rate_based_flag%TYPE
      INDEX BY BINARY_INTEGER;




TYPE calc_budget_line_out_rec_type IS RECORD
(pa_task_id                NUMBER             := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,pm_task_reference         VARCHAR2(30)       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,resource_alias            VARCHAR2(80)       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR      --Bug # 3507156 : Patchset M: B and F impact changes : AMG
,resource_list_member_id   NUMBER             := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,budget_start_date         DATE               := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
,budget_end_date           DATE               := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
,period_name               VARCHAR2(30)       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,calculated_raw_cost       NUMBER             := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,calculated_burdened_cost  NUMBER             := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,calculated_revenue        NUMBER             := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,quantity                  NUMBER             := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,return_status             VARCHAR2(1)        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 -- for Bug 2863564 the following columns have been added
--Changes the default of the following parameters from NULL to G_PA_MISS_XXX 24-APR-03 by Xin Liu
,txn_currency_code         VARCHAR2(30)       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,project_raw_cost               NUMBER             := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,project_burdened_cost          NUMBER             := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,project_revenue                NUMBER             := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,projfunc_raw_cost         NUMBER             := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,projfunc_burdened_cost    NUMBER             := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,projfunc_revenue          NUMBER             := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,display_quantity          NUMBER             := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM   --IPM Arch Enhancement Bug 4865563
);

TYPE calc_budget_line_out_tbl_type IS TABLE OF calc_budget_line_out_rec_type
      INDEX BY BINARY_INTEGER;

TYPE budget_line_out_rec_type IS RECORD
(return_status          VARCHAR2(1) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
);
TYPE budget_line_out_tbl_type IS TABLE OF budget_line_out_rec_type
      INDEX BY BINARY_INTEGER;

TYPE FINPLAN_TRANS_REC IS RECORD (
 PM_PRODUCT_CODE        PA_BUDGET_VERSIONS.PM_PRODUCT_CODE%TYPE      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,TASK_ID                NUMBER DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,PM_TASK_REFERENCE      PA_TASKS.PM_TASK_REFERENCE%TYPE              DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,PM_RES_ASGMT_REFERENCE VARCHAR2(30)                                 DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,RESOURCE_ALIAS         PA_RESOURCE_LIST_MEMBERS.ALIAS%TYPE          DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  --bug 3711693
,CURRENCY_CODE          PA_BUDGET_LINES.TXN_CURRENCY_CODE%TYPE       DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,UNIT_OF_MEASURE_CODE   PA_RESOURCE_ASSIGNMENTS.UNIT_OF_MEASURE%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,START_DATE    PA_RESOURCE_ASSIGNMENTS.PLANNING_START_DATE%TYPE      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
,END_DATE      PA_RESOURCE_ASSIGNMENTS.PLANNING_END_DATE%TYPE        DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
,QUANTITY                NUMBER DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,RAW_COST                NUMBER DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,BURDENED_COST           NUMBER DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,REVENUE                 NUMBER DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,RESOURCE_LIST_MEMBER_ID NUMBER DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,ATTRIBUTE_CATEGORY     PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE_CATEGORY%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,ATTRIBUTE1 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE1%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,ATTRIBUTE2 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE2%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,ATTRIBUTE3 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE3%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,ATTRIBUTE4 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE4%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,ATTRIBUTE5 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE5%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,ATTRIBUTE6 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE6%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,ATTRIBUTE7 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE7%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,ATTRIBUTE8 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE8%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,ATTRIBUTE9 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE9%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,ATTRIBUTE10 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE10%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,ATTRIBUTE11 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE11%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,ATTRIBUTE12 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE12%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,ATTRIBUTE13 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE13%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,ATTRIBUTE14 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE14%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,ATTRIBUTE15 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE15%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,ATTRIBUTE16 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE16%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,ATTRIBUTE17 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE17%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,ATTRIBUTE18 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE18%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,ATTRIBUTE19 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE19%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,ATTRIBUTE20 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE20%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,ATTRIBUTE21 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE21%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,ATTRIBUTE22 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE22%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,ATTRIBUTE23 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE23%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,ATTRIBUTE24 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE24%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,ATTRIBUTE25 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE25%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,ATTRIBUTE26 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE26%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,ATTRIBUTE27 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE27%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,ATTRIBUTE28 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE28%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,ATTRIBUTE29 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE29%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,ATTRIBUTE30 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE30%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
);
TYPE Finplan_trans_tab IS TABLE OF FINPLAN_TRANS_REC INDEX BY BINARY_INTEGER;


--Bug 5509192
   TYPE planning_element_rec_type IS RECORD
    (pa_task_id                   NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,pm_task_reference            VARCHAR2(30)      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,resource_alias               VARCHAR2(80)      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,resource_list_member_id      NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,planning_start_date          DATE              := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,planning_end_date            DATE              := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,etc_method_name              VARCHAR2(80)      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,spread_curve                 VARCHAR2(240)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,fixed_date                   DATE              := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,assignment_description       varchar2(240)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,attribute_category           VARCHAR2(30)      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,attribute1                   VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,attribute2                   VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,attribute3                   VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,attribute4                   VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,attribute5                   VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,attribute6                   VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,attribute7                   VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,attribute8                   VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,attribute9                   VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,attribute10                  VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,attribute11                  VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,attribute12                  VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,attribute13                  VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,attribute14                  VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,attribute15                  VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,attribute16                  VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,attribute17                  VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,attribute18                  VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,attribute19                  VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,attribute20                  VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,attribute21                  VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,attribute22                  VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,attribute23                  VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,attribute24                  VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,attribute25                  VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,attribute26                  VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,attribute27                  VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,attribute28                  VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,attribute29                  VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,attribute30                  VARCHAR2(150)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    );

    TYPE planning_element_rec_tbl_type IS TABLE OF planning_element_rec_type
    INDEX BY BINARY_INTEGER;
   --Bug 5509192


G_PM_PRODUCT_CODE_TBL        SYSTEM.PA_VARCHAR2_30_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
G_TASK_ID_TBL                SYSTEM.pa_num_tbl_type DEFAULT SYSTEM.PA_NUM_TBL_TYPE();
G_PM_TASK_REFERENCE_TBL      SYSTEM.PA_VARCHAR2_240_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
G_PM_RES_ASGMT_REFERENCE_TBL SYSTEM.PA_VARCHAR2_30_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
G_RESOURCE_ALIAS_TBL         SYSTEM.PA_VARCHAR2_80_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
G_CURRENCY_CODE_TBL          SYSTEM.PA_VARCHAR2_15_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_15_TBL_TYPE();
G_UNIT_OF_MEASURE_CODE_TBL   SYSTEM.PA_VARCHAR2_30_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
G_START_DATE_TBL             SYSTEM.pa_date_tbl_type DEFAULT SYSTEM.PA_DATE_TBL_TYPE();
G_END_DATE_TBL               SYSTEM.pa_date_tbl_type DEFAULT SYSTEM.PA_DATE_TBL_TYPE();
G_QUANTITY_TBL               SYSTEM.pa_num_tbl_type  DEFAULT SYSTEM.PA_NUM_TBL_TYPE();
G_DISPLAY_QUANTITY_TBL       SYSTEM.pa_num_tbl_type  DEFAULT SYSTEM.PA_NUM_TBL_TYPE(); --IPM Arch Enhancement Bug 4865563
G_RAW_COST_TBL               SYSTEM.pa_num_tbl_type  DEFAULT SYSTEM.PA_NUM_TBL_TYPE();
G_BURDENED_COST_TBL          SYSTEM.pa_num_tbl_type  DEFAULT SYSTEM.PA_NUM_TBL_TYPE();
G_REVENUE_TBL                SYSTEM.pa_num_tbl_type  DEFAULT SYSTEM.PA_NUM_TBL_TYPE();
G_RESOURCE_LIST_MEMBER_ID_TBL SYSTEM.pa_num_tbl_type  DEFAULT SYSTEM.PA_NUM_TBL_TYPE();
G_ATTRIBUTE_CATEGORY_TBL     SYSTEM.PA_VARCHAR2_30_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
G_ATTRIBUTE1_TBL             SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
G_ATTRIBUTE2_TBL             SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
G_ATTRIBUTE3_TBL             SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
G_ATTRIBUTE4_TBL             SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
G_ATTRIBUTE5_TBL             SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
G_ATTRIBUTE6_TBL             SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
G_ATTRIBUTE7_TBL             SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
G_ATTRIBUTE8_TBL             SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
G_ATTRIBUTE9_TBL             SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
G_ATTRIBUTE10_TBL            SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
G_ATTRIBUTE11_TBL            SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
G_ATTRIBUTE12_TBL            SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
G_ATTRIBUTE13_TBL            SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
G_ATTRIBUTE14_TBL            SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
G_ATTRIBUTE15_TBL            SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
G_ATTRIBUTE16_TBL            SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
G_ATTRIBUTE17_TBL            SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
G_ATTRIBUTE18_TBL            SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
G_ATTRIBUTE19_TBL            SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
G_ATTRIBUTE20_TBL            SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
G_ATTRIBUTE21_TBL            SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
G_ATTRIBUTE22_TBL            SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
G_ATTRIBUTE23_TBL            SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
G_ATTRIBUTE24_TBL            SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
G_ATTRIBUTE25_TBL            SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
G_ATTRIBUTE26_TBL            SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
G_ATTRIBUTE27_TBL            SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
G_ATTRIBUTE28_TBL            SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
G_ATTRIBUTE29_TBL            SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
G_ATTRIBUTE30_TBL            SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE();

--Globals to be used by the LOAD/EXECUTE/FETCH process
--IN types
G_budget_lines_in_tbl         budget_line_in_tbl_type;

--Counters
G_budget_lines_tbl_count      NUMBER:=0;
G_calc_budget_lines_tbl_count NUMBER:=0;

--OUT types
G_budget_lines_out_tbl        budget_line_out_tbl_type;
G_calc_budget_lines_out_tbl   calc_budget_line_out_tbl_type;


--Added by Xin Liu.24-APR-03
/* The following global variable can be set by calling get_project_id
   procedure with project_id parameter. The value set in the global
   variable is returned by get_project_id function.
   As of now, the set_project_id procedure is set by the project
   connect team to set the global variable and get_project_id is used
   by pa_finplan_types_v view which is inturn used by project
   connect team */

G_Project_Id                    pa_projects_all.project_id%type;


   -- Bug 4588279, 27-SEP-05, jwhite ----------------------------------
   -- Add global G_Latest_Encumbrance_Year for conditional
   -- budget line budgetary control processing.

      G_Latest_Encumbrance_Year gl_ledgers.Latest_Encumbrance_Year%TYPE := -99;


   -- -----------------------------------------------------------------


/*#
 * This API is used to return the PROJECT_ID for the project in context used by the public view
 * PA_FINPLAN_TYPES_V.
 * @return The project id for the project
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Project ID
 * @rep:compatibility S
*/
FUNCTION get_project_id return pa_projects_all.project_id%type;

/*#
 * This API is used to set the public variable G_PROJECT_ID which is used by public view PA_FINPLAN_TYPES_V.
 * @param p_project_id The identifier of the project for which the public view PA_FINPLAN_TYPES_V is created
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Set Project ID
 * @rep:compatibility S
*/
PROCEDURE set_project_id(p_project_id pa_projects_all.project_id%type);

/*#
 * This API is used to create a draft budget and its budget lines in Oracle Projects for a project using a selected budget type and budget entry method.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @rep:paraminfo {@rep:precision 1}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param p_pm_product_code The identifier of the external project management system from which the project was imported
 * @rep:paraminfo {@rep:required}
 * @param p_pm_budget_reference The reference code that uniquely identifies the budget in the external system
 * @param p_budget_version_name The user-defined name for the budget version
 * @param p_pa_project_id The reference code that uniquely identifies the project in the Oracle Projects
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system
 * @param p_budget_type_code The identifier of the budget type
 * @rep:paraminfo {@rep:required}
 * @param p_change_reason_code The identifier of the change reason
 * @param p_description Description of the budget
 * @param p_entry_method_code The identifier of the budget entry method
 * @param p_resource_list_name Name of the resource list
 * @param p_resource_list_id The identifier of the resource list
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
 * @param p_attribute11 Descriptive flexfield segment
 * @param p_attribute12 Descriptive flexfield segment
 * @param p_attribute13 Descriptive flexfield segment
 * @param p_attribute14 Descriptive flexfield segment
 * @param p_attribute15 Descriptive flexfield segment
 * @param p_budget_lines_in Input budget lines
 * @rep:paraminfo {@rep:required}
 * @param p_budget_lines_out Output budget lines
 * @rep:paraminfo {@rep:required}
 * @param p_fin_plan_type_id Financial plan type identifier. You must supply a valid value for either p_fin_plan_type_name or p_fin_plan_type_id for budget or forecast versions created for financial plan types.
 * @param p_fin_plan_type_name Financial plan type name in Oracle Projects. You must specify a value for this parameter or p_fin_plan_type_id.
 * @param p_version_type Financial plan version type. Required if planning separately for cost and revenue. Valid values are COST, REVENUE, and ALL.
 * @param p_fin_plan_level_code The planning level for the plan version. Valid values are P (project-level planning), T (top task-level planning), M (mixed-level planning - top and lowest tasks), and L (lowest task-level planning).
 * @param p_time_phased_code The indicator of the time periods to be used, if applicable, when planning for cost and revenue amounts together
 * @param p_plan_in_multi_curr_flag Flag indicating whether the plan amounts can be entered in any currency
 * @param p_projfunc_cost_rate_type Rate type used to convert costs from transaction currency to project functional currency
 * @param p_projfunc_cost_rate_date_typ The rate date type for converting cost amounts from transaction currency to project functional currency
 * @param p_projfunc_cost_rate_date The rate date for converting cost amounts from transaction currency to project functional currency
 * @param p_projfunc_rev_rate_type The rate type for converting revenue amounts from the transaction currency to the project functional currency
 * @param p_projfunc_rev_rate_date_typ The rate date type for converting revenue amounts from transaction currency to project functional currency
 * @param p_projfunc_rev_rate_date The rate date for converting revenue amounts from transaction currency to project functional currency
 * @param p_project_cost_rate_type The rate type for converting cost amounts from the transaction currency to the project currency
 * @param p_project_cost_rate_date_typ The rate date type for converting cost amounts from transaction currency to project currency
 * @param p_project_cost_rate_date The rate date for converting cost amounts from transaction currency to project currency
 * @param p_project_rev_rate_type The rate type for converting revenue amounts from the transaction currency to the project currency
 * @param p_project_rev_rate_date_typ The rate date type for converting revenue amounts from transaction currency to project currency
 * @param p_project_rev_rate_date The rate date for converting revenue amounts from transaction currency to project currency
 * @param p_raw_cost_flag Flag indicating whether raw cost can be entered
 * @rep:paraminfo {@rep:precision 1}
 * @param p_burdened_cost_flag Flag indicating whether burdened cost can be entered
 * @rep:paraminfo {@rep:precision 1}
 * @param p_revenue_flag Flag indicating whether revenue can be entered
 * @rep:paraminfo {@rep:precision 1}
 * @param p_cost_qty_flag Flag indicating whether cost quantity can be entered
 * @rep:paraminfo {@rep:precision 1}
 * @param p_revenue_qty_flag Flag indicating whether revenue quantity can be entered
 * @rep:paraminfo {@rep:precision 1}
 * @param p_all_qty_flag Flag indicating whether quantity can be entered when planning for cost and revenue together
 * @rep:paraminfo {@rep:precision 1}
 * @param p_create_new_curr_working_flag Flag indicating whether a current working version should be created
 * @param p_replace_current_working_flag Flag indicating whether the current working version should be deleted and the newly created version marked as the current working version
 * @param p_using_resource_lists_flag Flag indicating whether resource lists are used
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Draft Budget
 * @rep:compatibility S
*/
PROCEDURE create_draft_budget
( p_api_version_number        IN    NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit                    IN    VARCHAR2          := FND_API.G_FALSE
 ,p_init_msg_list             IN    VARCHAR2          := FND_API.G_FALSE
 ,p_msg_count                 OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_msg_data                  OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_return_status             OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_pm_product_code           IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pm_budget_reference       IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_budget_version_name       IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id             IN    NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_project_reference      IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_type_code          IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_change_reason_code        IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_description               IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_entry_method_code         IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_resource_list_name        IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_resource_list_id          IN    NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_attribute_category        IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute1                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute2                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute3                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute4                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute5                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute6                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute7                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute8                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute9                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute10               IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute11               IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute12               IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute13               IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute14               IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute15               IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_lines_in           IN    budget_line_in_tbl_type
 ,p_budget_lines_out          OUT   NOCOPY budget_line_out_tbl_type

 --The following parameters are added because of changes to due to finplan model
 --Changes the default of the following parameters from NULL to G_PA_MISS_XXX 24-APR-03 by Xin Liu
 ,p_fin_plan_type_id              IN   pa_fin_plan_types_b.fin_plan_type_id%TYPE  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_fin_plan_type_name            IN   pa_fin_plan_types_vl.name%TYPE  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_version_type                  IN   pa_budget_versions.version_type%TYPE  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_fin_plan_level_code           IN   pa_proj_fp_options.cost_fin_plan_level_code%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_time_phased_code              IN   pa_proj_fp_options.cost_time_phased_code%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_plan_in_multi_curr_flag       IN   pa_proj_fp_options.plan_in_multi_curr_flag%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_cost_rate_type       IN   pa_proj_fp_options.projfunc_cost_rate_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_cost_rate_date_typ   IN   pa_proj_fp_options.projfunc_cost_rate_date_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_cost_rate_date       IN   pa_proj_fp_options.projfunc_cost_rate_date%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_projfunc_rev_rate_type        IN   pa_proj_fp_options.projfunc_rev_rate_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_rev_rate_date_typ    IN   pa_proj_fp_options.projfunc_rev_rate_date_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_rev_rate_date        IN   pa_proj_fp_options.projfunc_rev_rate_date%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_project_cost_rate_type        IN   pa_proj_fp_options.project_cost_rate_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_cost_rate_date_typ    IN   pa_proj_fp_options.project_cost_rate_date_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_cost_rate_date        IN   pa_proj_fp_options.project_cost_rate_date%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_project_rev_rate_type         IN   pa_proj_fp_options.project_rev_rate_type%TYPE  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_rev_rate_date_typ     IN   pa_proj_fp_options.project_rev_rate_date_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_rev_rate_date         IN   pa_proj_fp_options.project_rev_rate_date%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_raw_cost_flag                 IN   VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_burdened_cost_flag            IN   VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_revenue_flag                  IN   VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_cost_qty_flag                 IN   VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_revenue_qty_flag              IN   VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_all_qty_flag                  IN   VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_create_new_curr_working_flag  IN   VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_replace_current_working_flag  IN   VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_using_resource_lists_flag           IN   VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
);


/*#
 * This API is used to set up the global data structures that other Load-Execute-Fetch procedures use to create a new or update an existing draft budget in Oracle Projects.
 * In order to execute this API, the following list of APIs should be executed in order of sequence.
 * INIT_BUDGET
 * INIT_CALCULATE_AMOUNTS
 * LOAD_BUDGET_LINE
 * EXECUTE_CALCULATE_AMOUNTS
 * EXECUTE_CREATE_DRAFT_BUDGET/EXECUTE_UPDATE_BUDGET
 * FETCH_CALCULATE_AMOUNTS
 * FETCH_BUDGET_LINE
 * CLEAR_BUDGET
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Multiple Budgets-Initialize
 * @rep:compatibility S
*/
PROCEDURE init_budget;

/*#
 * This API is used to load a budget line to a global PL/SQL table.
 * In order to execute this API, the following list of APIs should be executed in order of sequence.
 * INIT_BUDGET
 * INIT_CALCULATE_AMOUNTS
 * LOAD_BUDGET_LINE
 * EXECUTE_CALCULATE_AMOUNTS
 * EXECUTE_CREATE_DRAFT_BUDGET/EXECUTE_UPDATE_BUDGET
 * FETCH_CALCULATE_AMOUNTS
 * FETCH_BUDGET_LINE
 * CLEAR_BUDGET
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @rep:paraminfo {@rep:precision 1}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param p_pa_task_id The reference code that uniquely identifies the task within a project in Oracle Projects
 * @param p_pm_task_reference The unique reference code that identifies the task's parent task
 * @param p_resource_alias Alias of the resource
 * @param p_resource_list_member_id The identifier of the resource
 * @param p_budget_start_date Start date of budget line
 * @param p_budget_end_date End date of budget line
 * @param p_period_name PA or GL period name
 * @param p_description Description of the budget
 * @param p_raw_cost Budgeted raw cost amount
 * @param p_burdened_cost Budgeted burdened cost amount
 * @param p_revenue Budgeted revenue amount
 * @param p_quantity The quantity in the budget line
 * @param p_pm_product_code The identifier of the external project management system from which the project was imported
 * @param p_pm_budget_line_reference The identifier of the budget in the external project management system from
 * which the budget was imported
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
 * @param p_attribute11 Descriptive flexfield segment
 * @param p_attribute12 Descriptive flexfield segment
 * @param p_attribute13 Descriptive flexfield segment
 * @param p_attribute14 Descriptive flexfield segment
 * @param p_attribute15 Descriptive flexfield segment
 * @param p_txn_currency_code The transaction currency code
 * @rep:paraminfo {@rep:required}
 * @param p_projfunc_cost_rate_type Rate type used to convert costs from transaction currency to project functional currency
 * @param p_projfunc_cost_rate_date_type The rate date type for converting cost amounts from transaction currency to project functional currency
 * @param p_projfunc_cost_rate_date The rate date for converting cost amounts from transaction currency to project functional currency
 * @param p_projfunc_cost_exchange_rate Exchange rate used to convert costs from the transaction currency to the project functional currency if the exchange rate type is User
 * @param p_projfunc_rev_rate_type The rate type for converting revenue amounts from the transaction currency to the project functional currency
 * @param p_projfunc_rev_rate_date_type The rate date type for converting revenue amounts from transaction currency to project functional currency
 * @param p_projfunc_rev_rate_date The rate date for converting revenue amounts from transaction currency to project functional currency
 * @param p_projfunc_rev_exchange_rate Exchange rate used to convert revenue from the transaction currency to the project functional currency if the exchange rate type is User
 * @param p_project_cost_rate_type The rate type for converting cost amounts from the transaction currency to the project currency
 * @param p_project_cost_rate_date_type The rate date type for converting cost amounts from transaction currency to project currency
 * @param p_project_cost_rate_date The rate date for converting cost amounts from transaction currency to project currency
 * @param p_project_cost_exchange_rate Exchange rate used to convert costs from the transaction currency to the project currency if the exchange rate type is User
 * @param p_project_rev_rate_type The rate type for converting revenue amounts from the transaction currency to the project currency
 * @param p_project_rev_rate_date_type The rate date type for converting revenue amounts from transaction currency to project currency
 * @param p_project_rev_rate_date The rate date for converting revenue amounts from transaction currency to project currency
 * @param p_project_rev_exchange_rate Exchange rate used to convert revenue from the transaction currency to the project currency if the exchange rate type is User
 * @param p_change_reason_code The identifier of the change reason
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname  Create Multiple Budgets- Load Budget Line
 * @rep:compatibility S
*/
PROCEDURE load_budget_line
( p_api_version_number              IN    NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit                          IN    VARCHAR2    := FND_API.G_FALSE
 ,p_init_msg_list                   IN    VARCHAR2    := FND_API.G_FALSE
 ,p_return_status                   OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_pa_task_id                      IN    NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_task_reference               IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_resource_alias                  IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_resource_list_member_id         IN    NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_budget_start_date               IN    DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_budget_end_date                 IN    DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_period_name                     IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_description                     IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_raw_cost                        IN    NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_burdened_cost                   IN    NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_revenue                         IN    NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_quantity                        IN    NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,p_pm_product_code                  IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,p_pm_budget_line_reference         IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute_category              IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute1                      IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute2                      IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute3                      IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute4                      IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute5                      IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute6                      IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute7                      IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute8                      IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute9                      IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute10                     IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute11                     IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute12                     IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute13                     IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute14                     IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute15                     IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR

 --Parameters for fin plan model
 --Changes the default of the following parameters from NULL to G_PA_MISS_XXX 24-APR-03 by Xin Liu
 ,p_txn_currency_code             IN  pa_fp_txn_currencies.txn_currency_code%TYPE         :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_cost_rate_type       IN   pa_proj_fp_options.projfunc_cost_rate_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_cost_rate_date_type  IN   pa_proj_fp_options.projfunc_cost_rate_date_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_cost_rate_date       IN   pa_proj_fp_options.projfunc_cost_rate_date%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_projfunc_cost_exchange_rate   IN   pa_budget_lines.projfunc_cost_exchange_rate%TYPE    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_projfunc_rev_rate_type      IN   pa_proj_fp_options.projfunc_rev_rate_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_rev_rate_date_type   IN   pa_proj_fp_options.projfunc_rev_rate_date_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_rev_rate_date        IN   pa_proj_fp_options.projfunc_rev_rate_date%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_projfunc_rev_exchange_rate    IN   pa_budget_lines.projfunc_cost_exchange_rate%TYPE    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_cost_rate_type        IN   pa_proj_fp_options.project_cost_rate_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_cost_rate_date_type   IN   pa_proj_fp_options.project_cost_rate_date_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_cost_rate_date        IN   pa_proj_fp_options.project_cost_rate_date%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_project_cost_exchange_rate    IN  pa_budget_lines.project_cost_exchange_rate%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_rev_rate_type         IN   pa_proj_fp_options.project_rev_rate_type%TYPE  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_rev_rate_date_type    IN   pa_proj_fp_options.project_rev_rate_date_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_rev_rate_date         IN   pa_proj_fp_options.project_rev_rate_date%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_project_rev_exchange_rate     IN  pa_budget_lines.project_rev_exchange_rate%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_change_reason_code            IN  pa_budget_lines.change_reason_code%TYPE             :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 );

/*#
 * This API is used to create a budget and its budget lines using the data stored in the global tables during the load process.
 * In order to execute this API, the following list of APIs should be executed in order of sequence.
 * INIT_BUDGET
 * INIT_CALCULATE_AMOUNTS
 * LOAD_BUDGET_LINE
 * EXECUTE_CALCULATE_AMOUNTS
 * EXECUTE_CREATE_DRAFT_BUDGET/EXECUTE_UPDATE_BUDGET
 * FETCH_CALCULATE_AMOUNTS
 * FETCH_BUDGET_LINE
 * CLEAR_BUDGET
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @rep:paraminfo {@rep:precision 1}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param p_pm_product_code The identifier of the external project management system from which the project was imported
 * @rep:paraminfo {@rep:required}
 * @param p_pm_budget_reference The reference code that uniquely identifies the budget in the external system
 * @param p_budget_version_name The user-defined name for the budget version
 * @param p_pa_project_id The reference code that uniquely identifies the project in the Oracle Projects
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system
 * @param p_budget_type_code The identifier of the budget type
 * @param p_change_reason_code The identifier of the change reason
 * @param p_description Description of the budget
 * @param p_entry_method_code The identifier of the budget entry method
 * @param p_resource_list_name Name of the resource list
 * @param p_resource_list_id The identifier of the resource list
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
 * @param p_attribute11 Descriptive flexfield segment
 * @param p_attribute12 Descriptive flexfield segment
 * @param p_attribute13 Descriptive flexfield segment
 * @param p_attribute14 Descriptive flexfield segment
 * @param p_attribute15 Descriptive flexfield segment
 * @param p_fin_plan_type_name Financial plan type name in Oracle Projects. You must specify a value for this parameter or p_fin_plan_type_id.
 * @param p_fin_plan_type_id Financial plan type identifier. You must supply a valid value for either p_fin_plan_type_name or p_fin_plan_type_id for budget or forecast versions created for financial plan types.
 * @param p_version_type Financial plan version type. Required if planning separately for cost and revenue. Valid values are COST, REVENUE, and ALL.
 * @param p_fin_plan_level_code The planning level for the plan version. Valid values are P (project-level planning), T (top task-level planning), M (mixed-level planning - top and lowest tasks), and L (lowest task-level planning).
 * @param p_time_phased_code The time phasing option. Valid values are P (planning by PA periods), G (planning by GL periods), and N (None: planning is done for the duration of the project or task).
 * @param p_plan_in_multi_curr_flag Flag indicating whether the plan amounts can be entered in any currency
 * @param p_projfunc_cost_rate_type Rate type used to convert costs from transaction currency to project functional currency
 * @param p_projfunc_cost_rate_date_typ The rate date type for converting cost amounts from transaction currency to project functional currency
 * @param p_projfunc_cost_rate_date The rate date for converting cost amounts from transaction currency to project functional currency
 * @param p_projfunc_rev_rate_type The rate type for converting revenue amounts from the transaction currency to the project functional currency
 * @param p_projfunc_rev_rate_date_typ The rate date type for converting revenue amounts from transaction currency to project functional currency
 * @param p_projfunc_rev_rate_date The rate date for converting revenue amounts from transaction currency to project functional currency
 * @param p_project_cost_rate_type The rate type for converting cost amounts from the transaction currency to the project currency
 * @param p_project_cost_rate_date_typ The rate date type for converting cost amounts from transaction currency to project currency
 * @param p_project_cost_rate_date The rate date for converting cost amounts from transaction currency to project currency
 * @param p_project_rev_rate_type The rate type for converting revenue amounts from the transaction currency to the project currency
 * @param p_project_rev_rate_date_typ The rate date type for converting revenue amounts from transaction currency to project currency
 * @param p_project_rev_rate_date The rate date for converting revenue amounts from transaction currency to project currency
 * @param p_raw_cost_flag Flag indicating whether raw cost can be entered
 * @rep:paraminfo {@rep:precision 1}
 * @param p_burdened_cost_flag Flag indicating whether burdened cost can be entered
 * @rep:paraminfo {@rep:precision 1}
 * @param p_revenue_flag Flag indicating whether revenue can be entered
 * @rep:paraminfo {@rep:precision 1}
 * @param p_cost_qty_flag Flag indicating whether cost quantity can be entered
 * @rep:paraminfo {@rep:precision 1}
 * @param p_revenue_qty_flag Flag indicating whether revenue quantity can be entered
 * @rep:paraminfo {@rep:precision 1}
 * @param p_all_qty_flag Flag indicating whether quantity can be entered when planning for cost and revenue together
 * @rep:paraminfo {@rep:precision 1}
 * @param p_create_new_curr_working_flag Flag indicating whether a current working version should be created
 * @param p_replace_current_working_flag Flag indicating whether the current working version should be deleted and the newly created version marked as the current working version
 * @param p_using_resource_lists_flag Flag indicating whether resource lists are used
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Multiple Budgets-Create Draft Budget
 * @rep:compatibility S
*/
PROCEDURE execute_create_draft_budget
( p_api_version_number            IN  NUMBER
 ,p_commit                        IN  VARCHAR2    := FND_API.G_FALSE
 ,p_init_msg_list                 IN  VARCHAR2    := FND_API.G_FALSE
 ,p_msg_count                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_msg_data                      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_pm_product_code               IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pm_budget_reference           IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_budget_version_name           IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id                 IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_project_reference          IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_type_code              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_change_reason_code            IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_description                   IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_entry_method_code             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_resource_list_name            IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_resource_list_id              IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_attribute_category            IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute1                    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute2                    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute3                    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute4                    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute5                    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute6                    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute7                    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute8                    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute9                    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute10                   IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute11                   IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute12                   IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute13                   IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute14                   IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute15                   IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR

 --Added the following parameters for changes in AMG due to finplan model
 --Changes the default of the following parameters from NULL to G_PA_MISS_XXX 24-APR-03 by Xin Liu
 ,p_fin_plan_type_id              IN   pa_fin_plan_types_b.fin_plan_type_id%TYPE  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_fin_plan_type_name            IN   pa_fin_plan_types_vl.name%TYPE  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_version_type                  IN   pa_budget_versions.version_type%TYPE  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_fin_plan_level_code           IN   pa_proj_fp_options.cost_fin_plan_level_code%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_time_phased_code              IN   pa_proj_fp_options.cost_time_phased_code%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_plan_in_multi_curr_flag       IN   pa_proj_fp_options.plan_in_multi_curr_flag%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_cost_rate_type       IN   pa_proj_fp_options.projfunc_cost_rate_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_cost_rate_date_typ   IN   pa_proj_fp_options.projfunc_cost_rate_date_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_cost_rate_date       IN   pa_proj_fp_options.projfunc_cost_rate_date%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_projfunc_rev_rate_type        IN   pa_proj_fp_options.projfunc_rev_rate_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_rev_rate_date_typ    IN   pa_proj_fp_options.projfunc_rev_rate_date_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_rev_rate_date        IN   pa_proj_fp_options.projfunc_rev_rate_date%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_project_cost_rate_type        IN   pa_proj_fp_options.project_cost_rate_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_cost_rate_date_typ    IN   pa_proj_fp_options.project_cost_rate_date_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_cost_rate_date        IN   pa_proj_fp_options.project_cost_rate_date%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_project_rev_rate_type         IN   pa_proj_fp_options.project_rev_rate_type%TYPE  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_rev_rate_date_typ     IN   pa_proj_fp_options.project_rev_rate_date_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_rev_rate_date         IN   pa_proj_fp_options.project_rev_rate_date%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_raw_cost_flag                 IN   VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_burdened_cost_flag            IN   VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_revenue_flag                  IN   VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_cost_qty_flag                 IN   VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_revenue_qty_flag              IN   VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_all_qty_flag                  IN   VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_create_new_curr_working_flag  IN   VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_replace_current_working_flag  IN   VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_using_resource_lists_flag         IN   VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 );

/*#
 * This API is used to retrieve the return status determined during the creation of a budget line from a global PL/SQL table.
 * In order to execute this API, the following list of APIs should be executed in order of sequence.
 * INIT_BUDGET
 * INIT_CALCULATE_AMOUNTS
 * LOAD_BUDGET_LINE
 * EXECUTE_CALCULATE_AMOUNTS
 * EXECUTE_CREATE_DRAFT_BUDGET/EXECUTE_UPDATE_BUDGET
 * FETCH_CALCULATE_AMOUNTS
 * FETCH_BUDGET_LINE
 * CLEAR_BUDGET
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param p_line_index Pointer to the budget line
 * @rep:paraminfo {@rep:required}
 * @param p_line_return_status Return status for the budget line
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Multiple Budgets-Load Fetch Line
 * @rep:compatibility S
*/
PROCEDURE fetch_budget_line
( p_api_version_number        IN    NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_init_msg_list             IN    VARCHAR2          := FND_API.G_FALSE
 ,p_return_status             OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_line_index                IN    NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_line_return_status        OUT   NOCOPY VARCHAR2                            ); --File.Sql.39 bug 4440895

/*#
 * This API is used clear the global data structures set up during the Initialize step.
 * In order to execute this API, the following list of APIs should be executed in order of sequence.
 * INIT_BUDGET
 * INIT_CALCULATE_AMOUNTS
 * LOAD_BUDGET_LINE
 * EXECUTE_CALCULATE_AMOUNTS
 * EXECUTE_CREATE_DRAFT_BUDGET/EXECUTE_UPDATE_BUDGET
 * FETCH_CALCULATE_AMOUNTS
 * FETCH_BUDGET_LINE
 * CLEAR_BUDGET
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Multiple Budgets-Clear
 * @rep:compatibility S
*/
PROCEDURE clear_budget;

/*#
 * This API is used to set an existing budget as the baseline budget in Oracle Projects.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @rep:paraminfo {@rep:precision 1}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param p_workflow_started Flag indicating whether a workflow has been started
 * @rep:paraminfo {@rep:required}
 * @param p_pm_product_code The identifier of the external project management system from which the project was imported
 * @param p_pa_project_id The reference code that uniquely identifies the project in the Oracle Projects
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system
 * @param p_budget_type_code The identifier of the budget type
 * @rep:paraminfo {@rep:required}
 * @param p_mark_as_original Flag indicating whether to mark the budget as original
 * @param p_fin_plan_type_name Financial plan type name in Oracle Projects. You must specify a value for this parameter or p_fin_plan_type_id.
 * @param p_fin_plan_type_id Financial plan type identifier. You must supply a valid value for either p_fin_plan_type_name or p_fin_plan_type_id for budget or forecast versions created for financial plan types.
 * @param p_version_type Financial plan version type. Required if planning separately for cost and revenue. Valid values are COST, REVENUE, and ALL.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Verify Budget Amounts
 * @rep:compatibility S
*/
PROCEDURE Baseline_Budget
( p_api_version_number        IN    NUMBER
 ,p_commit                    IN    VARCHAR2          := FND_API.G_FALSE
 ,p_init_msg_list             IN    VARCHAR2          := FND_API.G_FALSE
 ,p_msg_count                 OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_msg_data                  OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_return_status             OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_workflow_started          OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_pm_product_code           IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id             IN    NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_project_reference      IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_type_code          IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_mark_as_original          IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_fin_plan_type_id          IN    pa_fin_plan_types_b.fin_plan_type_id%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_fin_plan_type_name        IN    pa_fin_plan_types_tl.name%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_version_type              IN    pa_budget_versions.version_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR);

/*#
 * This API is used to add a budget line to a working budget in Oracle Projects for a given project and budget type.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @rep:paraminfo {@rep:precision 1}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param p_pm_product_code The identifier of the external project management system from which the project was imported
 * @rep:paraminfo {@rep:required}
 * @param p_pa_project_id The reference code that uniquely identifies the project in the Oracle Projects
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system
 * @param p_budget_type_code The identifier of the budget type
 * @param p_pa_task_id The reference code that uniquely identifies the task within a project in Oracle Projects
 * @param p_pm_task_reference The reference code that uniquely identifies the task in the external system
 * @param p_resource_alias Alias of the resource
 * @param p_resource_list_member_id The identifier of the resource
 * @param p_budget_start_date Start date of budget line
 * @param p_budget_end_date End date of budget line
 * @param p_period_name PA or GL period name
 * @param p_description Plan line description
 * @param p_raw_cost Budgeted raw cost amount
 * @param p_burdened_cost Budgeted burdened cost amount
 * @param p_revenue Budgeted revenue amount
 * @param p_quantity The quantity entered into the budget line
 * @param p_pm_budget_line_reference The identifier of the budget in the external project management system from
 * which the budget was imported
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
 * @param p_attribute11 Descriptive flexfield segment
 * @param p_attribute12 Descriptive flexfield segment
 * @param p_attribute13 Descriptive flexfield segment
 * @param p_attribute14 Descriptive flexfield segment
 * @param p_attribute15 Descriptive flexfield segment
 * @param p_fin_plan_type_id Financial plan type identifier. You must supply a valid value for either p_fin_plan_type_name or p_fin_plan_type_id for budget or forecast versions created for financial plan types.
 * @param p_fin_plan_type_name Financial plan type name in Oracle Projects. You must specify a value for this parameter or p_fin_plan_type_id.
 * @param p_version_type Financial plan version type. Required if planning separately for cost and revenue. Valid values are COST, REVENUE, and ALL.
 * @param p_version_number Financial plan version number. Required to add a plan line to a version other than the current working version.
 * @param p_currency_code Financial plan currency identifier. Required if planning in multiple transaction currencies
 * @param p_change_reason_code The reference code that identifies the change reason
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Budget Line
 * @rep:compatibility S
*/
PROCEDURE add_budget_line
( p_api_version_number        IN    NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit                    IN    VARCHAR2          := FND_API.G_FALSE
 ,p_init_msg_list             IN    VARCHAR2          := FND_API.G_FALSE
 ,p_msg_count                 OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_msg_data                  OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_return_status             OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_pm_product_code           IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id             IN    NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_project_reference      IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_type_code          IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_task_id                IN    NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_task_reference         IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_resource_alias            IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_resource_list_member_id   IN    NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_budget_start_date         IN    DATE              := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_budget_end_date           IN    DATE              := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_period_name               IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_description               IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_raw_cost                  IN    NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_burdened_cost             IN    NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_revenue                   IN    NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_quantity                  IN    NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_budget_line_reference  IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute_category        IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute1                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute2                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute3                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute4                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute5                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute6                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute7                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute8                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute9                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute10               IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute11               IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute12               IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute13               IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute14               IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute15               IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--Parameters added for FP.M
 ,p_fin_plan_type_id          IN    NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_fin_plan_type_name        IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_version_type              IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_version_number            IN    NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_currency_code             IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_change_reason_code        IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR );

/*#
 * This API is used to delete a working budget in Oracle Projects for a given project and budget type.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @rep:paraminfo {@rep:precision 1}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param p_pm_product_code The identifier of the external project management system from which the project was imported
 * @rep:paraminfo {@rep:required}
 * @param p_pa_project_id The reference code that uniquely identifies the project in the Oracle Projects
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system
 * @param p_budget_type_code The identifier of the budget type
 * @param p_fin_plan_type_name Financial plan type name in Oracle Projects. You must specify a value for this parameter or p_fin_plan_type_id.
 * @param p_fin_plan_type_id Financial plan type identifier. You must supply a valid value for either p_fin_plan_type_name or p_fin_plan_type_id for budget or forecast versions created for financial plan types.
 * @param p_version_number Financial plan version number. Required to delete a plan version other than the current working version
 * @param p_version_type Financial plan version type. Required if planning separately for cost and revenue. Valid values are COST, REVENUE, and ALL.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Draft Budget
 * @rep:compatibility S
*/
PROCEDURE delete_draft_budget
( p_api_version_number          IN  NUMBER
 ,p_commit                      IN  VARCHAR2    := FND_API.G_FALSE
 ,p_init_msg_list               IN  VARCHAR2    := FND_API.G_FALSE
 ,p_msg_count                   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_msg_data                    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_return_status               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_pm_product_code             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id               IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_project_reference        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_type_code            IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR

 -- Parameters required for Fin Plan Model
 -- Changes by Xin Liu, change the default to G_PA_MISS_XXX
 ,p_fin_plan_type_name          IN  pa_fin_plan_types_vl.name%TYPE            :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_fin_plan_type_id            IN  pa_fin_plan_types_b.fin_plan_type_id%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_version_number              IN  pa_budget_versions.version_number%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_version_type                IN  pa_budget_versions.version_type%TYPE      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ) ;

/*#
 * This API is used to delete a budget line from a working budget in Oracle Projects for a given project and budget type.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @rep:paraminfo {@rep:precision 1}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param p_pm_product_code The identifier of the external project management system from which the project was imported
 * @rep:paraminfo {@rep:required}
 * @param p_pa_project_id The reference code that uniquely identifies the project in the Oracle Projects
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system
 * @param p_budget_type_code The identifier of the budget type
 * @param p_pa_task_id The reference code that uniquely identifies the task within a project in Oracle Projects
 * @param p_pm_task_reference The unique reference code that identifies the task's parent task
 * @param p_resource_alias Alias of the resource
 * @param p_resource_list_member_id The identifier of the resource
 * @param p_start_date Start date of budget line
 * @param p_period_name PA or GL period name
 * @param p_fin_plan_type_id Financial plan type identifier. You must supply a valid value for either p_fin_plan_type_name or p_fin_plan_type_id for budget or forecast versions created for financial plan types.
 * @param p_fin_plan_type_name Financial plan type name in Oracle Projects. You must specify a value for this parameter or p_fin_plan_type_id.
 * @param p_version_type Financial plan version type. Required if planning separately for cost and revenue. Valid values are COST, REVENUE, and ALL.
 * @param p_version_number Financial plan version number. Required to delete a plan line from a version other than the current working version
 * @param p_currency_code Financial plan currency identifier. Required if planning in multiple transaction currencies
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Budget Line
 * @rep:compatibility S
*/
PROCEDURE delete_budget_line
( p_api_version_number              IN    NUMBER
 ,p_commit                          IN    VARCHAR2    := FND_API.G_FALSE
 ,p_init_msg_list                   IN    VARCHAR2    := FND_API.G_FALSE
 ,p_msg_count                       OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_msg_data                        OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_return_status                   OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_pm_product_code                 IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id                   IN    NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_project_reference            IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_type_code                IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_task_id                      IN    NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_task_reference               IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_resource_alias                  IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_resource_list_member_id         IN    NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_start_date                      IN    DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_period_name                     IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--Parameters added for FP.M
 ,p_fin_plan_type_id                IN    NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_fin_plan_type_name              IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_version_type                    IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_version_number                  IN    NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_currency_code                   IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR );

/*#
 * This API is used to update a working budget.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @rep:paraminfo {@rep:precision 1}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param p_pm_product_code The identifier of the external project management system from which the project was imported
 * @rep:paraminfo {@rep:required}
 * @param p_pa_project_id The reference code that uniquely identifies the project in the Oracle Projects
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system
 * @param p_budget_type_code The identifier of the budget type
 * @param p_change_reason_code The identifier of the change reason
 * @param p_description Description of the budget
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
 * @param p_attribute11 Descriptive flexfield segment
 * @param p_attribute12 Descriptive flexfield segment
 * @param p_attribute13 Descriptive flexfield segment
 * @param p_attribute14 Descriptive flexfield segment
 * @param p_attribute15 Descriptive flexfield segment
 * @param p_budget_lines_in Input budget lines
 * @param p_budget_lines_out Output budget lines
 * @param p_resource_list_id The identifier of the resource list
 * @param p_set_current_working_flag Flag indicating whether to set the plan as the current working version
 * @param p_budget_version_number Budget version number
 * @param p_budget_version_name Budget version name
 * @param p_version_type Financial plan version type. Required if planning separately for cost and revenue. Valid values are COST, REVENUE, and ALL.
 * @param p_finplan_type_id Financial plan type identifier. You must supply a valid value for either p_fin_plan_type_name or p_fin_plan_type_id for budget or forecast versions created for financial plan types.
 * @param p_finplan_type_name Financial plan type name in Oracle Projects. You must specify a value for this parameter or P_FIN_PLAN_TYPE_ID.
 * @param p_plan_in_multi_curr_flag Flag indicating whether the plan allows multi currency transactions
 * @param p_time_phased_code The time phasing option. Valid values are P (planning by PA periods), G (planning by GL periods), and N (None: planning is done for the duration of the project or task).
 * @param p_projfunc_cost_rate_type Rate type used to convert costs from transaction currency to project functional currency
 * @param p_projfunc_cost_rate_date_typ The rate date type for converting cost amounts from transaction currency to project functional currency
 * @param p_projfunc_cost_rate_date The rate date for converting cost amounts from transaction currency to project functional currency
 * @param p_projfunc_cost_exchange_rate Exchange rate used to convert costs from the transaction currency to the project functional currency if the exchange rate type is User
 * @param p_projfunc_rev_rate_type The rate type for converting revenue amounts from the transaction currency to the project functional currency
 * @param p_projfunc_rev_rate_date_typ The rate date type for converting revenue amounts from transaction currency to project functional currency
 * @param p_projfunc_rev_rate_date The rate date for converting revenue amounts from transaction currency to project functional currency
 * @param p_projfunc_rev_exchange_rate Exchange rate used to convert revenue from the transaction currency to the project functional currency if the exchange rate type is User
 * @param p_project_cost_rate_type The rate type for converting cost amounts from the transaction currency to the project currency
 * @param p_project_cost_rate_date_typ The rate date type for converting cost amounts from transaction currency to project currency
 * @param p_project_cost_rate_date The rate date for converting cost amounts from transaction currency to project currency
 * @param p_project_cost_exchange_rate Exchange rate used to convert costs from the transaction currency to the project currency if the exchange rate type is User
 * @param p_project_rev_rate_type The rate type for converting revenue amounts from the transaction currency to the project currency
 * @param p_project_rev_rate_date_typ The rate date type for converting revenue amounts from transaction currency to project currency
 * @param p_project_rev_rate_date The rate date for converting revenue amounts from transaction currency to project currency
 * @param p_project_rev_exchange_rate Exchange rate used to convert revenue from the transaction currency to the project currency if the exchange rate type is User
 * @param p_raw_cost_flag  Flag that indicates whether raw cost is enterable
 * @rep:paraminfo {@rep:precision 1}
 * @param p_burdened_cost_flag  Flag that indicates whether burdened cost is enterable
 * @rep:paraminfo {@rep:precision 1}
 * @param p_revenue_flag   Flag that indicates whether revenue is enterable
 * @rep:paraminfo {@rep:precision 1}
 * @param p_cost_qty_flag  Indicates whether cost quantity could be entered
 * @rep:paraminfo {@rep:precision 1}
 * @param p_revenue_qty_flag  Indicates whether revenue quantity could be entered
 * @rep:paraminfo {@rep:precision 1}
 * @param p_all_qty_flag  Indicates whether quantity can be entered when planning for Cost and Revenue together
 * @rep:paraminfo {@rep:precision 1}
 * @param p_bill_rate_flag  Indicates whether bill rate could be entered
 * @rep:paraminfo {@rep:precision 1}
 * @param p_cost_rate_flag  Indicates whether cost rate could be entered
 * @rep:paraminfo {@rep:precision 1}
 * @param p_burden_rate_flag  Indicates whether burden rate could be entered
 * @rep:paraminfo {@rep:precision 1}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Budget
 * @rep:compatibility S
*/
PROCEDURE update_budget
( p_api_version_number        IN    NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit                    IN    VARCHAR2          := FND_API.G_FALSE
 ,p_init_msg_list             IN    VARCHAR2          := FND_API.G_FALSE
 ,p_msg_count                 OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_msg_data                  OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_return_status             OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_pm_product_code           IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id             IN    NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_project_reference      IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_type_code          IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_change_reason_code        IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_description               IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute_category        IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute1                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute2                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute3                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute4                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute5                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute6                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute7                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute8                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute9                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute10               IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute11               IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute12               IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute13               IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute14               IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute15               IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_lines_in           IN    budget_line_in_tbl_type
 ,p_budget_lines_out          OUT   NOCOPY budget_line_out_tbl_type
  --Added for bug 4224464(this fix is available on 44 branch)
  --Added for the bug 3453650
 ,p_resource_list_id              IN   pa_budget_versions.resource_list_id%TYPE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_set_current_working_flag      IN   pa_budget_versions.current_working_flag%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_version_number         IN   pa_budget_versions.version_number%TYPE  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_budget_version_name           IN   pa_budget_versions.version_name%TYPE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_version_type                  IN   pa_budget_versions.version_type%TYPE  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  -- 3453650
 ,p_finplan_type_id               IN   pa_budget_versions.fin_plan_type_id%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_finplan_type_name             IN   pa_fin_plan_types_vl.name%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_plan_in_multi_curr_flag       IN   pa_proj_fp_options.plan_in_multi_curr_flag%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_time_phased_code              IN   pa_proj_fp_options.cost_time_phased_code%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_cost_rate_type       IN   pa_proj_fp_options.projfunc_cost_rate_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_cost_rate_date_typ   IN   pa_proj_fp_options.projfunc_cost_rate_date_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_cost_rate_date       IN   pa_proj_fp_options.projfunc_cost_rate_date%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_projfunc_cost_exchange_rate   IN   pa_budget_lines.projfunc_cost_exchange_rate%TYPE    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_projfunc_rev_rate_type        IN   pa_proj_fp_options.projfunc_rev_rate_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_rev_rate_date_typ    IN   pa_proj_fp_options.projfunc_rev_rate_date_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_rev_rate_date        IN   pa_proj_fp_options.projfunc_rev_rate_date%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_projfunc_rev_exchange_rate    IN   pa_budget_lines.projfunc_cost_exchange_rate%TYPE    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_cost_rate_type        IN   pa_proj_fp_options.project_cost_rate_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_cost_rate_date_typ    IN   pa_proj_fp_options.project_cost_rate_date_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_cost_rate_date        IN   pa_proj_fp_options.project_cost_rate_date%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_project_cost_exchange_rate    IN  pa_budget_lines.project_cost_exchange_rate%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_rev_rate_type         IN   pa_proj_fp_options.project_rev_rate_type%TYPE  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_rev_rate_date_typ     IN   pa_proj_fp_options.project_rev_rate_date_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_rev_rate_date         IN   pa_proj_fp_options.project_rev_rate_date%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_project_rev_exchange_rate     IN  pa_budget_lines.project_rev_exchange_rate%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 /* Plan Amount Entry flags introduced by bug 6408139 */
 ,p_raw_cost_flag                 IN   VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_burdened_cost_flag            IN   VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_revenue_flag                  IN   VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_cost_qty_flag                 IN   VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_revenue_qty_flag              IN   VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_all_qty_flag                  IN   VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_bill_rate_flag                IN   VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_cost_rate_flag                IN   VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_burden_rate_flag              IN   VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
);

/*#
 * This API is used to update a budget and its budget lines using the data stored in the global tables during the load process.
 * In order to execute this API, the following list of APIs should be executed in order of sequence.
 * INIT_BUDGET
 * INIT_CALCULATE_AMOUNTS
 * LOAD_BUDGET_LINE
 * EXECUTE_CALCULATE_AMOUNTS
 * EXECUTE_CREATE_DRAFT_BUDGET/EXECUTE_UPDATE_BUDGET
 * FETCH_CALCULATE_AMOUNTS
 * FETCH_BUDGET_LINE
 * CLEAR_BUDGET
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @rep:paraminfo {@rep:precision 1}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param p_pm_product_code The identifier of the external project management system from which the project was imported
 * @rep:paraminfo {@rep:required}
 * @param p_pa_project_id The reference code that uniquely identifies the project in the Oracle Projects
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system
 * @param p_budget_type_code The identifier of the budget type
 * @rep:paraminfo {@rep:required}
 * @param p_change_reason_code The identifier of the change reason
 * @param p_description Description of the budget
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
 * @param p_attribute11 Descriptive flexfield segment
 * @param p_attribute12 Descriptive flexfield segment
 * @param p_attribute13 Descriptive flexfield segment
 * @param p_attribute14 Descriptive flexfield segment
 * @param p_attribute15 Descriptive flexfield segment
 * @param p_resource_list_id Resource list identifier
 * @param p_set_current_working_flag Flag indicating whether to set the plan as the current working version
 * @param p_budget_version_number Budget version number
 * @param p_budget_version_name Budget version Name
 * @param p_version_type Financial plan version type. Required if planning separately for cost and revenue. Valid values are COST, REVENUE, and ALL.
 * @param p_finplan_type_id The identifier of financial plan type
 * @param p_plan_in_multi_curr_flag Flag indicating if the version can be planned in multiple transaction currencies
 * @param p_time_phased_code The time phasing option. Valid values are P (planning by PA periods), G (planning by GL periods), and N (None: planning is done for the duration of the project or task).
 * @param p_projfunc_cost_rate_type Rate type used to convert costs from transaction currency to project functional currency
 * @param p_projfunc_cost_rate_date_typ The rate date type for converting cost amounts from transaction currency to project functional currency
 * @param p_projfunc_cost_rate_date The rate date for converting cost amounts from transaction currency to project functional currency
 * @param p_projfunc_cost_exchange_rate Exchange rate used to convert costs from the transaction currency to the project functional currency if the exchange rate type is User
 * @param p_projfunc_rev_rate_type The rate type for converting revenue amounts from the transaction currency to the project functional currency
 * @param p_projfunc_rev_rate_date_typ The rate date type for converting revenue amounts from transaction currency to project functional currency
 * @param p_projfunc_rev_rate_date The rate date for converting revenue amounts from transaction currency to project functional currency
 * @param p_projfunc_rev_exchange_rate Exchange rate used to convert revenue from the transaction currency to the project functional currency if the exchange rate type is User
 * @param p_project_cost_rate_type The rate type for converting cost amounts from the transaction currency to the project currency
 * @param p_project_cost_rate_date_typ The rate date type for converting cost amounts from transaction currency to project currency
 * @param p_project_cost_rate_date The rate date for converting cost amounts from transaction currency to project currency
 * @param p_project_cost_exchange_rate Exchange rate used to convert costs from the transaction currency to the project currency if the exchange rate type is User
 * @param p_project_rev_rate_type The rate type for converting revenue amounts from the transaction currency to the project currency
 * @param p_project_rev_rate_date_typ The rate date type for converting revenue amounts from transaction currency to project currency
 * @param p_project_rev_rate_date The rate date for converting revenue amounts from transaction currency to project currency
 * @param p_project_rev_exchange_rate Exchange rate used to convert revenue from the transaction currency to the project currency if the exchange rate type is User
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Multiple Budgets
 * @rep:compatibility S
*/
PROCEDURE execute_update_budget
( p_api_version_number              IN    NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit                          IN    VARCHAR2    := FND_API.G_FALSE
 ,p_init_msg_list                   IN    VARCHAR2    := FND_API.G_FALSE
 ,p_msg_count                       OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_msg_data                        OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_return_status                   OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_pm_product_code                 IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id                   IN    NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_project_reference            IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_type_code                IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_change_reason_code              IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_description                     IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute_category              IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute1                      IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute2                      IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute3                      IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute4                      IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute5                      IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute6                      IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute7                      IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute8                      IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute9                      IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute10                     IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute11                     IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute12                     IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute13                     IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute14                     IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute15                     IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 --Added for bug 4224464(this fix is available on 44 branch)
 --Added for the bug 3453650
 ,p_resource_list_id              IN   pa_budget_versions.resource_list_id%TYPE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_set_current_working_flag      IN   pa_budget_versions.current_working_flag%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_version_number         IN   pa_budget_versions.version_number%TYPE  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_version_name           IN   pa_budget_versions.version_name%TYPE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_version_type                  IN   pa_budget_versions.version_type%TYPE  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR -- 3453650
 ,p_finplan_type_id               IN   pa_budget_versions.fin_plan_type_id%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_plan_in_multi_curr_flag       IN   pa_proj_fp_options.plan_in_multi_curr_flag%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_time_phased_code              IN   pa_proj_fp_options.cost_time_phased_code%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_cost_rate_type       IN   pa_proj_fp_options.projfunc_cost_rate_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_cost_rate_date_typ  IN   pa_proj_fp_options.projfunc_cost_rate_date_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_cost_rate_date       IN   pa_proj_fp_options.projfunc_cost_rate_date%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_projfunc_cost_exchange_rate   IN   pa_budget_lines.projfunc_cost_exchange_rate%TYPE    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_projfunc_rev_rate_type      IN   pa_proj_fp_options.projfunc_rev_rate_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_rev_rate_date_typ   IN   pa_proj_fp_options.projfunc_rev_rate_date_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_rev_rate_date        IN   pa_proj_fp_options.projfunc_rev_rate_date%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_projfunc_rev_exchange_rate    IN   pa_budget_lines.projfunc_cost_exchange_rate%TYPE    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_cost_rate_type        IN   pa_proj_fp_options.project_cost_rate_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_cost_rate_date_typ   IN   pa_proj_fp_options.project_cost_rate_date_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_cost_rate_date        IN   pa_proj_fp_options.project_cost_rate_date%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_project_cost_exchange_rate    IN  pa_budget_lines.project_cost_exchange_rate%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_rev_rate_type         IN   pa_proj_fp_options.project_rev_rate_type%TYPE  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_rev_rate_date_typ    IN   pa_proj_fp_options.project_rev_rate_date_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_rev_rate_date         IN   pa_proj_fp_options.project_rev_rate_date%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_project_rev_exchange_rate     IN  pa_budget_lines.project_rev_exchange_rate%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  );

/*#
 * This API is used to update an existing budget line of a working budget in Oracle Projects for a given project and budget type.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @rep:paraminfo {@rep:precision 1}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param p_pm_product_code The identifier of the external project management system from which the project was imported
 * @rep:paraminfo {@rep:required}
 * @param p_pa_project_id The reference code that uniquely identifies the project in the Oracle Projects
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system
 * @param p_budget_type_code The identifier of the budget type
 * @param p_pa_task_id The reference code that uniquely identifies the task within a project in Oracle Projects
 * @param p_pm_task_reference The unique reference code that identifies the task's parent task
 * @param p_resource_alias Alias of the resource
 * @param p_resource_list_member_id The identifier of the resource
 * @param p_budget_start_date Start date of budget line
 * @param p_budget_end_date End date of budget line
 * @param p_period_name PA or GL period name
 * @param p_description Description of the budget line
 * @param p_raw_cost Budgeted raw cost amount
 * @param p_burdened_cost Budgeted burdened cost amount
 * @param p_revenue Budgeted revenue amount
 * @param p_quantity Budgeted quantity
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
 * @param p_attribute11 Descriptive flexfield segment
 * @param p_attribute12 Descriptive flexfield segment
 * @param p_attribute13 Descriptive flexfield segment
 * @param p_attribute14 Descriptive flexfield segment
 * @param p_attribute15 Descriptive flexfield segment
 * @param p_fin_plan_type_id Financial plan type identifier. You must supply a valid value for either p_fin_plan_type_name or p_fin_plan_type_id for budget or forecast versions created for financial plan types.
 * @param p_fin_plan_type_name Financial plan type name in Oracle Projects. You must specify a value for this parameter or p_fin_plan_type_id.
 * @param p_version_type Financial plan version type. Required if planning separately for cost and revenue. Valid values are COST, REVENUE, and ALL.
 * @param p_version_number Financial plan version number. Required to update a plan line to a version other than the current working version
 * @param p_currency_code Financial plan currency identifier. Required if planning in multiple transaction currencies
 * @param p_change_reason_code The identifier of the change reason
 * @param p_projfunc_cost_rate_type Rate type used to convert costs from transaction currency to project functional currency
 * @param p_projfunc_cost_rate_date_typ The rate date type for converting cost amounts from transaction currency to project functional currency
 * @param p_projfunc_cost_rate_date The rate date for converting cost amounts from transaction currency to project functional currency
 * @param p_projfunc_cost_exchange_rate Exchange rate used to convert costs from the transaction currency to the project functional currency if the exchange rate type is User
 * @param p_projfunc_rev_rate_type Rate type used to convert revenue from transaction currency to project functional currency
 * @param p_projfunc_rev_rate_date_typ The rate date type for converting revenue amounts from transaction currency to project functional currency
 * @param p_projfunc_rev_rate_date The rate date for converting revenue amounts from transaction currency to project functional currency
 * @param p_projfunc_rev_exchange_rate Exchange rate used to convert revenue from the transaction currency to the project functional currency if the exchange rate type is User
 * @param p_project_cost_rate_type Rate type used to convert costs from transaction currency to project currency
 * @param p_project_cost_rate_date_typ The rate date type for converting cost amounts from transaction currency to project currency
 * @param p_project_cost_rate_date The rate date for converting cost amounts from transaction currency to project currency
 * @param p_project_cost_exchange_rate Exchange rate used to convert costs from the transaction currency to the project currency if the exchange rate type is User
 * @param p_project_rev_rate_type Rate type used to convert revenue from transaction currency to project currency
 * @param p_project_rev_rate_date_typ The rate date type for converting revenue amounts from transaction currency to project currency
 * @param p_project_rev_rate_date The rate date for converting revenue amounts from transaction currency to project currency
 * @param p_project_rev_exchange_rate Exchange rate used to convert revenue from the transaction currency to the project currency if the exchange rate type is User
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Budget Line
 * @rep:compatibility S
*/
PROCEDURE update_budget_line
( p_api_version_number            IN  NUMBER
 ,p_commit                        IN  VARCHAR2   := FND_API.G_FALSE
 ,p_init_msg_list                 IN  VARCHAR2   := FND_API.G_FALSE
 ,p_msg_count                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_msg_data                      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_pm_product_code               IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id                 IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_project_reference          IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_type_code              IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_task_id                    IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_task_reference             IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_resource_alias                IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_resource_list_member_id       IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_budget_start_date             IN  DATE       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_budget_end_date               IN  DATE       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_period_name                   IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_description                   IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_raw_cost                      IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_burdened_cost                 IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_revenue                       IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_quantity                      IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_attribute_category            IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute1                    IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute2                    IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute3                    IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute4                    IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute5                    IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute6                    IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute7                    IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute8                    IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute9                    IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute10                   IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute11                   IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute12                   IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute13                   IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute14                   IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute15                   IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 --Parameters added for FP.M
 ,p_fin_plan_type_id              IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_fin_plan_type_name            IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_version_type                  IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_version_number                IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_currency_code                 IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_change_reason_code            IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_cost_rate_type       IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_cost_rate_date_typ   IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_cost_rate_date       IN  DATE       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_projfunc_cost_exchange_rate   IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_projfunc_rev_rate_type        IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_rev_rate_date_typ    IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_rev_rate_date        IN  DATE       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_projfunc_rev_exchange_rate    IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_cost_rate_type        IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_cost_rate_date_typ    IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_cost_rate_date        IN  DATE       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_project_cost_exchange_rate    IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_rev_rate_type         IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_rev_rate_date_typ     IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_rev_rate_date         IN  DATE       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_project_rev_exchange_rate     IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
);

/*#
 * Using the PA_CLIENT_EXTN_BUDGET extension, you can use this API to recalculate raw cost, burdened cost, and revenue amounts for existing budget lines.
 * @param p_api_version_number API standard: version number
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @rep:paraminfo {@rep:precision 1}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_pm_product_code The identifier of the external project management system from which the project was imported
 * @rep:paraminfo {@rep:required}
 * @param p_pa_project_id The reference code that uniquely identifies the project in the Oracle Projects
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system
 * @param p_budget_type_code The identifier of the budget type
 * @param p_calc_raw_cost_yn Flag indicating whether to calculate raw cost
 * @param p_calc_burdened_cost_yn Flag indicating whether to calculate burden cost
 * @param p_calc_revenue_yn Flag indicating whether to calculate revenue
 * @param p_update_db_flag Flag indicating whether to update the database
 * @param p_calc_budget_lines_out Calculated budget lines
 * @rep:paraminfo {@rep:required}
 * @param p_budget_version_id The identifier of the budget version
 * @param p_fin_plan_type_id Financial plan type identifier. You must supply a valid value for either p_fin_plan_type_name or p_fin_plan_type_id for budget or forecast versions created for financial plan types.
 * @param p_fin_plan_type_name Financial plan type name in Oracle Projects. You must specify a value for this parameter or p_fin_plan_type_id.
 * @param p_version_type Financial plan version type. Required if planning separately for cost and revenue. Valid values are COST, REVENUE, and ALL.
 * @param p_budget_version_number Budget version number
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Budget Amounts
 * @rep:compatibility S
*/
PROCEDURE Calculate_Amounts
( p_api_version_number        IN    NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit                    IN    VARCHAR2   := FND_API.G_FALSE
 ,p_init_msg_list             IN    VARCHAR2   := FND_API.G_FALSE
 ,p_msg_count                 OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_msg_data                  OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_return_status             OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_pm_product_code           IN    VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id             IN    NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_project_reference      IN    VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_type_code          IN    VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_calc_raw_cost_yn          IN    VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_calc_burdened_cost_yn     IN    VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_calc_revenue_yn           IN    VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_update_db_flag            IN    VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_calc_budget_lines_out     OUT   NOCOPY calc_budget_line_out_tbl_type
  -- Bug 2863564 Parameters required for new Fin Plan Model
 ,p_budget_version_id         IN    pa_budget_versions.budget_version_id%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_fin_plan_type_id          IN    pa_fin_plan_types_b.fin_plan_type_id%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_fin_plan_type_name        IN    pa_fin_plan_types_tl.name%TYPE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_version_type              IN    pa_budget_versions.version_type%TYPE      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_version_number     IN    pa_budget_versions.version_number%TYPE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 );

/*#
 * This API is used to set up the global data structures used by the CALCULATE_AMOUNTS API.
 * In order to execute this API, the following list of APIs should be executed in order of sequence.
 * INIT_BUDGET
 * INIT_CALCULATE_AMOUNTS
 * LOAD_BUDGET_LINE
 * EXECUTE_CALCULATE_AMOUNTS
 * EXECUTE_CREATE_DRAFT_BUDGET/EXECUTE_UPDATE_BUDGET
 * FETCH_CALCULATE_AMOUNTS
 * FETCH_BUDGET_LINE
 * CLEAR_BUDGET
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Multiple Budgets-Initialize Calculate Amounts
 * @rep:compatibility S
*/
PROCEDURE Init_Calculate_Amounts ;

/*#
 * This API is used to calculate the raw cost, burdened cost, and revenue amounts using existing budget lines for a given project and budget type.
 * In order to execute this API, the following list of APIs should be executed in order of sequence.
 * INIT_BUDGET
 * INIT_CALCULATE_AMOUNTS
 * LOAD_BUDGET_LINE
 * EXECUTE_CALCULATE_AMOUNTS
 * EXECUTE_CREATE_DRAFT_BUDGET/EXECUTE_UPDATE_BUDGET
 * FETCH_CALCULATE_AMOUNTS
 * FETCH_BUDGET_LINE
 * CLEAR_BUDGET
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @rep:paraminfo {@rep:precision 1}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_tot_budget_lines_calculated Indicates the total number of budget lines calculated and determines how many times to call the API FETCH_CALCULATE_AMOUNTS
 * @rep:paraminfo {@rep:required}
 * @param p_pm_product_code The identifier of the external project management system from which the project was imported
 * @rep:paraminfo {@rep:required}
 * @param p_pa_project_id The reference code that uniquely identifies the project in the Oracle Projects
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system
 * @param p_budget_type_code The identifier of the budget type
 * @rep:paraminfo {@rep:required}
 * @param p_calc_raw_cost_yn Flag indicating whether raw cost should be calculated
 * @param p_calc_burdened_cost_yn Flag indicating whether burden cost should be calculated
 * @param p_calc_revenue_yn Flag indicating whether revenue should be calculated
 * @param p_update_db_flag Flag indicating whether to update changes to database
 * @param p_budget_version_id The identifier of the budget version
 * @param p_fin_plan_type_id Financial plan type identifier. You must supply a valid value for either p_fin_plan_type_name or p_fin_plan_type_id for budget or forecast versions created for financial plan types.
 * @param p_fin_plan_type_name Financial plan type name in Oracle Projects. You must specify a value for this parameter or p_fin_plan_type_id.
 * @param p_version_type Financial plan version type. Required if planning separately for cost and revenue. Valid values are COST, REVENUE, and ALL.
 * @param p_budget_version_number Budget version number
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Multiple Budgets-Execute Calculate Amounts
 * @rep:compatibility S
*/
PROCEDURE Execute_Calculate_Amounts
( p_api_version_number          IN   NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit                      IN   VARCHAR2    := FND_API.G_FALSE
 ,p_init_msg_list               IN   VARCHAR2    := FND_API.G_FALSE
 ,p_msg_count                   OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_msg_data                    OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_return_status               OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_tot_budget_lines_calculated OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_pm_product_code             IN   VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id               IN   NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_project_reference        IN   VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_type_code            IN   VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_calc_raw_cost_yn            IN   VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_calc_burdened_cost_yn       IN   VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_calc_revenue_yn             IN   VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_update_db_flag              IN   VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  -- Bug 2863564 Parameters required for new Fin Plan Model
 ,p_budget_version_id           IN   pa_budget_versions.budget_version_id%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_fin_plan_type_id            IN   pa_fin_plan_types_b.fin_plan_type_id%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_fin_plan_type_name          IN   pa_fin_plan_types_tl.name%TYPE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_version_type                IN   pa_budget_versions.version_type%TYPE      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_version_number       IN   pa_budget_versions.version_number%TYPE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
);

/*#
 * This API is used to get the raw cost, burdened cost, and revenue amounts by budget line from global records.
 * In order to execute this API, the following list of APIs should be executed in order of sequence.
 * INIT_BUDGET
 * INIT_CALCULATE_AMOUNTS
 * LOAD_BUDGET_LINE
 * EXECUTE_CALCULATE_AMOUNTS
 * EXECUTE_CREATE_DRAFT_BUDGET/EXECUTE_UPDATE_BUDGET
 * FETCH_CALCULATE_AMOUNTS
 * FETCH_BUDGET_LINE
 * CLEAR_BUDGET
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_line_index Pointer to the budget line
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param p_pa_task_id The reference code that uniquely identifies the task within a project in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_pm_task_reference The unique reference code that identifies the task's parent task
 * @rep:paraminfo {@rep:required}
 * @param p_budget_start_date Start date of budget line
 * @rep:paraminfo {@rep:required}
 * @param p_budget_end_date End date of budget line
 * @rep:paraminfo {@rep:required}
 * @param p_period_name PA or GL period name
 * @rep:paraminfo {@rep:required}
 * @param p_resource_list_member_id The identifier of the resource
 * @rep:paraminfo {@rep:required}
 * @param p_quantity The quantity in the budget line
 * @rep:paraminfo {@rep:required}
 * @param p_resource_alias Alias of the resource
 * @rep:paraminfo {@rep:required}
 * @param p_calculated_raw_cost Calculated raw cost
 * @rep:paraminfo {@rep:required}
 * @param p_calculated_burdened_cost Calculated burdened cost
 * @rep:paraminfo {@rep:required}
 * @param p_calculated_revenue Calculated revenue
 * @rep:paraminfo {@rep:required}
 * @param p_line_return_status Return status for the budget line
 * @rep:paraminfo {@rep:required}
 * @rep:primaryinstance
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Multiple Budgets-Fetch Calculate Amounts
 * @rep:compatibility S
*/
PROCEDURE fetch_calculate_amounts
( p_api_version_number         IN   NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_init_msg_list              IN   VARCHAR2    := FND_API.G_FALSE
 ,p_line_index                 IN   NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_return_status             OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_pa_task_id                OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_pm_task_reference         OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_budget_start_date         OUT   NOCOPY DATE --File.Sql.39 bug 4440895
 ,p_budget_end_date           OUT   NOCOPY DATE --File.Sql.39 bug 4440895
 ,p_period_name               OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_resource_list_member_id   OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_quantity                  OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_resource_alias            OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_calculated_raw_cost       OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_calculated_burdened_cost  OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_calculated_revenue        OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_line_return_status        OUT   NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

--  Bug 2863564
--  The following is an overloaded api created to support new financial planning model
--  The requirement is that extra new 'OUT' parameters be added.
--  By overloading, dependencies have been avoided.

/*#
 * This API is used to get the raw cost, burdened cost, and revenue amounts by budget line from global records updated by the API EXECUTE_CALCULATE_AMOUNTS.
 * In order to execute this API, the following list of APIs should be executed in order of sequence.
 * INIT_BUDGET
 * INIT_CALCULATE_AMOUNTS
 * LOAD_BUDGET_LINE
 * EXECUTE_CALCULATE_AMOUNTS
 * EXECUTE_CREATE_DRAFT_BUDGET/EXECUTE_UPDATE_BUDGET
 * FETCH_CALCULATE_AMOUNTS
 * FETCH_BUDGET_LINE
 * CLEAR_BUDGET
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_line_index Pointer to the budget line
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param p_pa_task_id The reference code that uniquely identifies the task within a project in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_pm_task_reference The unique reference code that identifies the task's parent task
 * @rep:paraminfo {@rep:required}
 * @param p_budget_start_date Start date of budget line
 * @rep:paraminfo {@rep:required}
 * @param p_budget_end_date End date of budget line
 * @rep:paraminfo {@rep:required}
 * @param p_period_name PA or GL period name
 * @rep:paraminfo {@rep:required}
 * @param p_resource_list_member_id The identifier of the resource
 * @rep:paraminfo {@rep:required}
 * @param p_quantity API The quantity in the budget line
 * @rep:paraminfo {@rep:required}
 * @param p_resource_alias Alias of the resource
 * @rep:paraminfo {@rep:required}
 * @param p_calculated_raw_cost Calculated raw cost
 * @rep:paraminfo {@rep:required}
 * @param p_calculated_burdened_cost Calculated burdened cost
 * @rep:paraminfo {@rep:required}
 * @param p_calculated_revenue Calculated revenue
 * @rep:paraminfo {@rep:required}
 * @param p_line_return_status Return status for a specific line
 * @rep:paraminfo {@rep:required}
 * @param p_txn_currency_code The transaction currency code.
 * @param p_project_raw_cost The raw cost in project currency
 * @param p_project_burdened_cost The burdened cost in project currency
 * @param p_project_revenue The revenue in project currency
 * @param p_projfunc_raw_cost The raw cost in project functional currency
 * @param p_projfunc_burdened_cost The burdened cost in project functional currency
 * @param p_projfunc_revenue The revenue in project functional currency
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Multiple Budgets-Fetch Calculate Amounts
 * @rep:compatibility S
*/
PROCEDURE fetch_calculate_amounts
( p_api_version_number         IN   NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_init_msg_list              IN   VARCHAR2    := FND_API.G_FALSE
 ,p_line_index                 IN   NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_return_status             OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_pa_task_id                OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_pm_task_reference         OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_budget_start_date         OUT   NOCOPY DATE --File.Sql.39 bug 4440895
 ,p_budget_end_date           OUT   NOCOPY DATE --File.Sql.39 bug 4440895
 ,p_period_name               OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_resource_list_member_id   OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_quantity                  OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_resource_alias            OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_calculated_raw_cost       OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_calculated_burdened_cost  OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_calculated_revenue        OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_line_return_status        OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_txn_currency_code         OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_project_raw_cost          OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_project_burdened_cost     OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_project_revenue           OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_projfunc_raw_cost         OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_projfunc_burdened_cost    OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_projfunc_revenue          OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_display_quantity          OUT   NOCOPY NUMBER  --IPM Arch Enhancement Bug 4865563
 );

/*#
 * This API is used to reset the global data structures used by the Load-Execute-Fetch procedure CALCULATE_AMOUNTS.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Clear Calculate Amounts
 * @rep:compatibility S
*/
PROCEDURE Clear_Calculate_Amounts ;

/*#
 * This API is used to create draft budgets and forecasts for financial plan types. This API accepts summary
 * data at the project, task, resource, and currency levels. For budget and forecast versions that are
 * time-phased by PA or GL period, the API also spreads the data, including quantities and amounts, across
 * periods based on the spread curve associated with a resource. This API does not perform any edits to the data.
 * @param p_api_version_number API standard: version number
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @rep:paraminfo {@rep:precision 1}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_pm_product_code The identifier of the external project management system from which the project was imported
 * @rep:paraminfo {@rep:required}
 * @param p_pm_finplan_reference The reference code that uniquely identifies the financial plan in the external system
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system. You must specify a value for either this parameter or P_PA_PROJECT_ID.
 * @param p_pa_project_id The reference code that uniquely identifies the project in the Oracle Projects. You must specify a value for this parameter or P_PM_PROJECT_REFERENCE.
 * @param p_fin_plan_type_id Financial plan type identifier. You must provide a valid value for either P_FIN_PLAN_TYPE_NAME or P_FIN_PLAN_TYPE_ID for budget or forecast versions created for the financial plan types.
 * @param p_fin_plan_type_name Financial plan type name in Oracle Projects. You must specify a value for this parameter or P_FIN_PLAN_TYPE_ID.
 * @param p_version_type Financial plan version type. Required if planning separately for cost and revenue. The valid values are COST, REVENUE, and ALL.
 * @param p_time_phased_code The time phasing option. Valid values are P (planning by PA periods), G (planning by GL periods), and N (None: planning is done for the duration of the project or task).
 * @param p_resource_list_name Resource list name
 * @param p_resource_list_id Resource list identifier
 * @param p_fin_plan_level_code Planning level identifier. Valid values are P (project level), T (top task level), and L (lowest task level).
 * @param P_PLAN_IN_MULTI_CURR_FLAG Flag indicating if the version can be planned in multiple transaction currencies
 * @param p_budget_version_name Budget version name
 * @rep:paraminfo {@rep:required}
 * @param p_description Financial plan description
 * @param p_change_reason_code Reference code that identifies a change reason
 * @param p_raw_cost_flag Flag indicating whether raw cost can be planned for the plan version
 * @param p_burdened_cost_flag Flag indicating whether burdened cost can be planned for the plan version
 * @param p_revenue_flag Flag indicating whether revenue can be planned for the plan version
 * @param p_cost_qty_flag Flag indicating whether cost quantity can be planned for a cost plan version
 * @param p_revenue_qty_flag Flag indicating whether revenue quantity can be planned for a revenue plan version
 * @param p_all_qty_flag Flag indicating whether quantity can be planned when cost and revenue are planned together in the same plan version
 * @param p_create_new_curr_working_flag Flag indicating whether a current working version should be created
 * @param p_replace_current_working_flag Flag indicating whether the current working version should be deleted and the newly created version marked as the current working version
 * @param p_using_resource_lists_flag Flag indicating whether a resource list is used. Required for budgets and forecasts created for financial plan types. If plan amounts are not classified using resource lists, then the value must be N.
 * @param p_finplan_trans_tab PL/SQL table containing planning transaction information for the financial plan version
 * @param p_attribute_category Descriptive flexfield category for a budget version
 * @param p_attribute1 Descriptive flexfield segment for a budget version
 * @param p_attribute2 Descriptive flexfield segment for a budget version
 * @param p_attribute3 Descriptive flexfield segment for a budget version
 * @param p_attribute4 Descriptive flexfield segment for a budget version
 * @param p_attribute5 Descriptive flexfield segment for a budget version
 * @param p_attribute6 Descriptive flexfield segment for a budget version
 * @param p_attribute7 Descriptive flexfield segment for a budget version
 * @param p_attribute8 Descriptive flexfield segment for a budget version
 * @param p_attribute9 Descriptive flexfield segment for a budget version
 * @param p_attribute10 Descriptive flexfield segment for a budget version
 * @param p_attribute11 Descriptive flexfield segment for a budget version
 * @param p_attribute12 Descriptive flexfield segment for a budget version
 * @param p_attribute13 Descriptive flexfield segment for a budget version
 * @param p_attribute14 Descriptive flexfield segment for a budget version
 * @param p_attribute15 Descriptive flexfield segment for a budget version
 * @param x_finplan_version_id Financial plan version identifier of the plan version created using the API
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1}
 * @param x_msg_count API standard: number of error messages
 * @param x_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Draft Financial Plan
 * @rep:compatibility S
*/
PROCEDURE CREATE_DRAFT_FINPLAN
 ( p_api_version_number              IN      NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_commit                              IN      VARCHAR2          := FND_API.G_FALSE
  ,p_init_msg_list                       IN      VARCHAR2          := FND_API.G_FALSE
  ,p_pm_product_code                 IN      pa_budget_versions.pm_product_code%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_pm_finplan_reference            IN      pa_budget_versions.pm_budget_reference%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_pm_project_reference            IN      pa_projects_all. PM_PROJECT_REFERENCE%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_pa_project_id                   IN      pa_budget_versions.project_id%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_fin_plan_type_id                IN      pa_budget_versions.fin_plan_type_id%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_fin_plan_type_name              IN      pa_fin_plan_types_vl.name%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_version_type                    IN      pa_budget_versions.version_type%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_time_phased_code                IN      pa_proj_fp_options.cost_time_phased_code%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_resource_list_name              IN      pa_resource_lists.name%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_resource_list_id                IN      pa_budget_versions.resource_list_id%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_fin_plan_level_code             IN      pa_proj_fp_options.cost_fin_plan_level_code%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,P_PLAN_IN_MULTI_CURR_FLAG         IN      pa_proj_fp_options.plan_in_multi_curr_flag%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_budget_version_name             IN      pa_budget_versions.version_name%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_description                     IN      pa_budget_versions.description%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_change_reason_code              IN      pa_budget_versions.change_reason_code%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_raw_cost_flag                   IN      pa_fin_plan_amount_sets.raw_cost_flag%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_burdened_cost_flag              IN      pa_fin_plan_amount_sets.burdened_cost_flag%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_revenue_flag                    IN      pa_fin_plan_amount_sets.revenue_flag%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_cost_qty_flag                   IN      pa_fin_plan_amount_sets.cost_qty_flag%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_revenue_qty_flag                IN      pa_fin_plan_amount_sets.revenue_qty_flag%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_all_qty_flag                    IN      pa_fin_plan_amount_sets.all_qty_flag%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_create_new_curr_working_flag    IN      VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_replace_current_working_flag    IN      VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_using_resource_lists_flag       IN      VARCHAR2 DEFAULT 'N'
  ,p_finplan_trans_tab               IN      pa_budget_pub.FinPlan_Trans_Tab
  ,p_attribute_category              IN      pa_budget_versions.attribute_category%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute1                      IN      pa_budget_versions.attribute1%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute2                      IN      pa_budget_versions.attribute2%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute3                      IN      pa_budget_versions.attribute3%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute4                      IN      pa_budget_versions.attribute4%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute5                      IN      pa_budget_versions.attribute5%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute6                      IN      pa_budget_versions.attribute6%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute7                      IN      pa_budget_versions.attribute7%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute8                      IN      pa_budget_versions.attribute8%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute9                      IN      pa_budget_versions.attribute9%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute10                     IN      pa_budget_versions.attribute10%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute11                     IN      pa_budget_versions.attribute11%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute12                     IN      pa_budget_versions.attribute12%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute13                     IN      pa_budget_versions.attribute13%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute14                     IN      pa_budget_versions.attribute14%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute15                     IN      pa_budget_versions.attribute15%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,x_finplan_version_id              OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_return_status                   OUT NOCOPY VARCHAR2
  ,x_msg_count                       OUT NOCOPY NUMBER
  ,x_msg_data                        OUT NOCOPY VARCHAR2
 );

/*#
 * This API is used to load the resource information along with summary amounts required to create
 * a budget or forecast, to a global PL/SQL table used by the EXECUTE_CREATE_DRAFT_FINPLAN API.
 * @param P_PM_PRODUCT_CODE The identifier of the external project management system from which the project was imported
 * @param P_TASK_ID Task identifier in Oracle Projects. If not planning at the project level, you must specify a value for this parameter or P_PM_TASK_REFERENCE.
 * @param P_PM_TASK_REFERENCE Task identifier in the external system. If not planning at the project level, you must specify a value for this parameter or P_TASK_ID.
 * @param P_PM_RES_ASGMT_REFERENCE Identifier of the resource assignment in the external system
 * @param P_RESOURCE_ALIAS The resource alias. If the resource list is categorized, you must specify a value for either this parameter or P_RESOURCE_LIST_MEMBER_ID.
 * @param P_CURRENCY_CODE The currency identifier. Required if planning in multiple transaction currencies.
 * @param P_UNIT_OF_MEASURE_CODE The unit of measure
 * @param P_START_DATE Start date of budget line
 * @param P_END_DATE Indicates the budget line end date for budgets and forecasts that are time-phased by PA or GL periods
 * @param P_QUANTITY The quantity entered into the budget line
 * @param P_RAW_COST Raw cost amount
 * @param P_BURDENED_COST Burdened cost amount
 * @param P_REVENUE Revenue amount
 * @param P_RESOURCE_LIST_MEMBER_ID Resource list member identifier. If the resource list is categorized, you must specify a value for this parameter or P_RESOURCE_ALIAS.
 * @param P_ATTRIBUTE_CATEGORY Descriptive flexfield category for a resource assignment
 * @param P_ATTRIBUTE1 Descriptive flexfield segment for a resource assignment
 * @param P_ATTRIBUTE2 Descriptive flexfield segment for a resource assignment
 * @param P_ATTRIBUTE3 Descriptive flexfield segment for a resource assignment
 * @param P_ATTRIBUTE4 Descriptive flexfield segment for a resource assignment
 * @param P_ATTRIBUTE5 Descriptive flexfield segment for a resource assignment
 * @param P_ATTRIBUTE6 Descriptive flexfield segment for a resource assignment
 * @param P_ATTRIBUTE7 Descriptive flexfield segment for a resource assignment
 * @param P_ATTRIBUTE8 Descriptive flexfield segment for a resource assignment
 * @param P_ATTRIBUTE9 Descriptive flexfield segment for a resource assignment
 * @param P_ATTRIBUTE10 Descriptive flexfield segment for a resource assignment
 * @param P_ATTRIBUTE11 Descriptive flexfield segment for a resource assignment
 * @param P_ATTRIBUTE12 Descriptive flexfield segment for a resource assignment
 * @param P_ATTRIBUTE13 Descriptive flexfield segment for a resource assignment
 * @param P_ATTRIBUTE14 Descriptive flexfield segment for a resource assignment
 * @param P_ATTRIBUTE15 Descriptive flexfield segment for a resource assignment
 * @param P_ATTRIBUTE16 Descriptive flexfield segment for a resource assignment
 * @param P_ATTRIBUTE17 Descriptive flexfield segment for a resource assignment
 * @param P_ATTRIBUTE18 Descriptive flexfield segment for a resource assignment
 * @param P_ATTRIBUTE19 Descriptive flexfield segment for a resource assignment
 * @param P_ATTRIBUTE20 Descriptive flexfield segment for a resource assignment
 * @param P_ATTRIBUTE21 Descriptive flexfield segment for a resource assignment
 * @param P_ATTRIBUTE22 Descriptive flexfield segment for a resource assignment
 * @param P_ATTRIBUTE23 Descriptive flexfield segment for a resource assignment
 * @param P_ATTRIBUTE24 Descriptive flexfield segment for a resource assignment
 * @param P_ATTRIBUTE25 Descriptive flexfield segment for a resource assignment
 * @param P_ATTRIBUTE26 Descriptive flexfield segment for a resource assignment
 * @param P_ATTRIBUTE27 Descriptive flexfield segment for a resource assignment
 * @param P_ATTRIBUTE28 Descriptive flexfield segment for a resource assignment
 * @param P_ATTRIBUTE29 Descriptive flexfield segment for a resource assignment
 * @param P_ATTRIBUTE30 Descriptive flexfield segment for a resource assignment
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Load Resource Information
 * @rep:compatibility S
*/
PROCEDURE load_resource_info(
 P_PM_PRODUCT_CODE PA_BUDGET_VERSIONS.PM_PRODUCT_CODE%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_TASK_ID PA_TASKS.TASK_ID%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_PM_TASK_REFERENCE PA_TASKS.PM_TASK_REFERENCE%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_PM_RES_ASGMT_REFERENCE VARCHAR2 DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_RESOURCE_ALIAS         VARCHAR2 DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_CURRENCY_CODE PA_BUDGET_LINES.TXN_CURRENCY_CODE%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_UNIT_OF_MEASURE_CODE PA_RESOURCE_ASSIGNMENTS.UNIT_OF_MEASURE%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_START_DATE PA_RESOURCE_ASSIGNMENTS.PLANNING_START_DATE%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
,P_END_DATE PA_RESOURCE_ASSIGNMENTS.PLANNING_END_DATE%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
,P_QUANTITY                NUMBER DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,P_RAW_COST                NUMBER DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,P_BURDENED_COST           NUMBER DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,P_REVENUE                 NUMBER DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,P_RESOURCE_LIST_MEMBER_ID NUMBER DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,P_ATTRIBUTE_CATEGORY PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE_CATEGORY%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE1 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE1%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE2 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE2%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE3 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE3%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE4 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE4%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE5 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE5%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE6 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE6%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE7 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE7%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE8 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE8%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE9 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE9%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE10 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE10%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE11 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE11%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE12 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE12%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE13 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE13%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE14 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE14%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE15 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE15%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE16 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE16%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE17 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE17%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE18 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE18%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE19 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE19%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE20 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE20%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE21 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE21%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE22 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE22%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE23 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE23%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE24 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE24%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE25 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE25%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE26 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE26%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE27 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE27%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE28 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE28%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE29 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE29%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE30 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE30%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
);

/*#
 * This API is used to create budgets and forecasts using the data stored in the global tables during
 * the load process.
 * In order to execute this API, the following API should be executed.
 * LOAD_RESOURCE_INFO
 * @param p_api_version_number API standard: version number
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_pm_product_code The identifier of the external project management system from which the project was imported
 * @rep:paraminfo {@rep:required}
 * @param p_pm_finplan_reference The reference code that uniquely identifies the financial plan in the external system
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system. You must specify a value for this parameter or P_PA_PROJECT_ID.
 * @param p_pa_project_id The reference code that uniquely identifies the project in the Oracle Projects. You must specify a value for this parameter or P_PM_PROJECT_REFERENCE.
 * @param p_fin_plan_type_id Financial plan type identifier. You must supply a valid value for either P_FIN_PLAN_TYPE_NAME or P_FIN_PLAN_TYPE_ID for budget or forecast versions created for financial plan types.
 * @param p_fin_plan_type_name Financial plan type name in Oracle Projects. You must specify a value for this parameter or P_FIN_PLAN_TYPE_ID.
 * @param p_version_type Financial plan version type. Required if planning separately for cost and revenue. The valid values are COST, REVENUE, and ALL.
 * @param p_time_phased_code The time phasing option. The valid values are P (planning by PA periods), G (planning by GL periods), and N (None: planning is done for the duration of the project or task).
 * @param p_resource_list_name Resource list name
 * @param p_resource_list_id Resource list identifier
 * @param p_fin_plan_level_code Financial planning level code identifier. The valid values are P (project level), T (top task level), and L (lowest task level).
 * @param P_PLAN_IN_MULTI_CURR_FLAG Flag indicating if the version can be planned in multiple transaction currencies
 * @param p_budget_version_name Budget version name
 * @rep:paraminfo {@rep:required}
 * @param p_description Financial plan description
 * @param p_change_reason_code Reference code that identifies a change reason
 * @param p_raw_cost_flag Flag indicating whether raw cost can be planned for the plan version
 * @param p_burdened_cost_flag Flag indicating whether burdened cost can be planned for the plan version
 * @param p_revenue_flag Flag indicating whether revenue can be planned for the plan version
 * @param p_cost_qty_flag Flag indicating whether cost quantity can be planned for a cost plan version
 * @param p_revenue_qty_flag Flag indicating whether revenue quantity can be planned for a revenue plan version
 * @param p_all_qty_flag Flag indicating whether quantity can be planned when cost and revenue are planned together in the same plan version
 * @param p_attribute_category Descriptive flexfield category for a budget version
 * @param p_attribute1 Descriptive flexfield segment for a budget version
 * @param p_attribute2 Descriptive flexfield segment for a budget version
 * @param p_attribute3 Descriptive flexfield segment for a budget version
 * @param p_attribute4 Descriptive flexfield segment for a budget version
 * @param p_attribute5 Descriptive flexfield segment for a budget version
 * @param p_attribute6 Descriptive flexfield segment for a budget version
 * @param p_attribute7 Descriptive flexfield segment for a budget version
 * @param p_attribute8 Descriptive flexfield segment for a budget version
 * @param p_attribute9 Descriptive flexfield segment for a budget version
 * @param p_attribute10 Descriptive flexfield segment for a budget version
 * @param p_attribute11 Descriptive flexfield segment for a budget version
 * @param p_attribute12 Descriptive flexfield segment for a budget version
 * @param p_attribute13 Descriptive flexfield segment for a budget version
 * @param p_attribute14 Descriptive flexfield segment for a budget version
 * @param p_attribute15 Descriptive flexfield segment for a budget version
 * @param p_create_new_curr_working_flag Flag indicating whether a current working version should be created
 * @param p_replace_current_working_flag Flag indicating whether the current working version should be deleted and the newly created version marked as the current working version
 * @param p_using_resource_lists_flag Flag indicating whether a resource list is used. Required for budgets and forecasts created for financial plan types. If plan amounts are not classified using resource lists, then the value must be N.
 * @param x_finplan_version_id Financial plan version identifier of the plan version created using the API
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @param x_msg_count API standard: number of error messages
 * @param x_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Execute Create Draft Financial Plan
 * @rep:compatibility S
*/
PROCEDURE EXECUTE_CREATE_DRAFT_FINPLAN
 ( p_api_version_number              IN      NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_commit                          IN      VARCHAR2          := FND_API.G_FALSE
  ,p_init_msg_list                   IN      VARCHAR2          := FND_API.G_FALSE
  ,p_pm_product_code                 IN      pa_budget_versions.pm_product_code%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_pm_finplan_reference            IN      pa_budget_versions.pm_budget_reference%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_pm_project_reference            IN      pa_projects_all.PM_PROJECT_REFERENCE%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_pa_project_id                   IN      pa_budget_versions.project_id%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_fin_plan_type_id                IN      pa_budget_versions.fin_plan_type_id%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_fin_plan_type_name              IN      pa_fin_plan_types_vl.name%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_version_type                    IN      pa_budget_versions.version_type%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_time_phased_code                IN      pa_proj_fp_options.cost_time_phased_code%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_resource_list_name              IN      pa_resource_lists.name%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_resource_list_id                IN      pa_budget_versions.resource_list_id%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_fin_plan_level_code             IN      pa_proj_fp_options.cost_fin_plan_level_code%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,P_PLAN_IN_MULTI_CURR_FLAG         IN      pa_proj_fp_options.plan_in_multi_curr_flag%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_budget_version_name             IN      pa_budget_versions.version_name%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_description                     IN      pa_budget_versions.description%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_change_reason_code              IN      pa_budget_versions.change_reason_code%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_raw_cost_flag                   IN      pa_fin_plan_amount_sets.raw_cost_flag%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_burdened_cost_flag              IN      pa_fin_plan_amount_sets.burdened_cost_flag%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_revenue_flag                    IN      pa_fin_plan_amount_sets.revenue_flag%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_cost_qty_flag                   IN      pa_fin_plan_amount_sets.cost_qty_flag%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_revenue_qty_flag                IN      pa_fin_plan_amount_sets.revenue_qty_flag%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_all_qty_flag                    IN      pa_fin_plan_amount_sets.all_qty_flag%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute_category              IN      pa_budget_versions.attribute_category%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute1                      IN      pa_budget_versions.attribute1%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute2                      IN      pa_budget_versions.attribute2%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute3                      IN      pa_budget_versions.attribute3%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute4                      IN      pa_budget_versions.attribute4%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute5                      IN      pa_budget_versions.attribute5%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute6                      IN      pa_budget_versions.attribute6%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute7                      IN      pa_budget_versions.attribute7%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute8                      IN      pa_budget_versions.attribute8%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute9                      IN      pa_budget_versions.attribute9%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute10                     IN      pa_budget_versions.attribute10%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute11                     IN      pa_budget_versions.attribute11%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute12                     IN      pa_budget_versions.attribute12%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute13                     IN      pa_budget_versions.attribute13%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute14                     IN      pa_budget_versions.attribute14%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute15                     IN      pa_budget_versions.attribute15%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_create_new_curr_working_flag    IN      VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_replace_current_working_flag    IN      VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_using_resource_lists_flag       IN      VARCHAR2 DEFAULT 'N'
  ,x_finplan_version_id              OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_return_status                   OUT NOCOPY VARCHAR2
  ,x_msg_count                       OUT NOCOPY NUMBER
  ,x_msg_data                        OUT NOCOPY VARCHAR2
 );

/*#
 * This API is used to delete an existing baseline budget version and the corresponding budget lines
 * in Oracle Projects for a given project and budget type or a project and financial plan type.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @rep:paraminfo {@rep:precision 1}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param p_pm_product_code The identifier of the external project management system from which the project was imported
 * @rep:paraminfo {@rep:required}
 * @param p_pa_project_id The reference code that uniquely identifies the project in the Oracle Projects. You must specify a value for this parameter or P_PM_PROJECT_REFERENCE.
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system. You must specify a value for this parameter or P_PA_PROJECT_ID.
 * @param p_budget_type_code Budget type code identifier in Oracle Projects
 * @param p_fin_plan_type_id Financial plan type identifier. You must provide a valid value for either P_FIN_PLAN_TYPE_NAME or P_FIN_PLAN_TYPE_ID for budget or forecast versions created for financial plan types.
 * @param p_fin_plan_type_name Financial plan type name in Oracle Projects. You must specify a value for this parameter or P_FIN_PLAN_TYPE_ID
 * @param p_version_type Financial plan version type. Required if planning separately for cost and revenue. The valid values are COST, REVENUE, and ALL.
 * @param p_version_number Baseline plan version number
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Baseline Budget
 * @rep:compatibility S
*/
PROCEDURE delete_baseline_budget
( p_api_version_number          IN  NUMBER
 ,p_commit                      IN  VARCHAR2    := FND_API.G_FALSE
 ,p_init_msg_list               IN  VARCHAR2    := FND_API.G_FALSE
 ,p_msg_count                   OUT NOCOPY NUMBER
 ,p_msg_data                    OUT NOCOPY VARCHAR2
 ,p_return_status               OUT NOCOPY VARCHAR2
 ,p_pm_product_code             IN  pa_projects_all.pm_product_code%TYPE      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id               IN  pa_projects_all.project_id%TYPE           := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_project_reference        IN  pa_projects_all.pm_project_reference%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_type_code            IN  pa_budget_versions.budget_type_code%TYPE  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_fin_plan_type_id            IN  pa_fin_plan_types_b.fin_plan_type_id%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_fin_plan_type_name          IN  pa_fin_plan_types_vl.name%TYPE            :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_version_type                IN  pa_budget_versions.version_type%TYPE      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_version_number              IN  pa_budget_versions.version_number%TYPE    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ) ;


--bug 5509192
/*#
 * This API is used to update the existing planning element
 * attributes: Planning Start Date, Planning End Date,Etc Method, Spread Curve, Description, Attribute Category,
 * attribute1 thru attribute30 in a plan version.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @rep:paraminfo {@rep:precision 1}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param p_pm_product_code The identifier of the external project management system from which the project was imported
 * @rep:paraminfo {@rep:required}
 * @param p_pa_project_id The reference code that uniquely identifies the project in the Oracle Projects. You must specify a value for this parameter or P_PM_PROJECT_REFERENCE.
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system. You must specify a value for this parameter or P_PA_PROJECT_ID.
 * @param p_fin_plan_type_id Financial plan type identifier. You must provide a valid value for either P_FIN_PLAN_TYPE_NAME or P_FIN_PLAN_TYPE_ID for budget or forecast versions created for financial plan types.
 * @param p_fin_plan_type_name The financial plan type name
 * @param p_version_type Financial plan version type. Required if planning separately for cost and revenue. The valid values are COST, REVENUE, and ALL.
 * @param p_budget_version_number Budget version number
 * @param p_planning_element_rec_tbl Planning Elements Attributes Input Record
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Planning Element Attributes
 * @rep:compatibility S
*/

   PROCEDURE update_plannning_element_attr
    (p_api_version_number            IN   NUMBER
    ,p_commit                        IN   VARCHAR2                             := FND_API.G_FALSE
    ,p_init_msg_list                 IN   VARCHAR2                             := FND_API.G_FALSE
    ,p_pm_product_code               IN   VARCHAR2                             := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_pa_project_id                 IN   NUMBER                               := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_pm_project_reference          IN   VARCHAR2                             := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_fin_plan_type_id              IN   pa_budget_versions.fin_plan_type_id%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_fin_plan_type_name            IN   pa_fin_plan_types_tl.name%TYPE           := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_budget_version_number         IN   pa_budget_versions.version_number%TYPE   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_version_type                  IN   pa_budget_versions.version_type%TYPE     :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_planning_element_rec_tbl      IN   planning_element_rec_tbl_type
    ,p_distribute_amounts            IN   VARCHAR2     DEFAULT 'Y'   -- Bug 9610380
    ,x_msg_count                     OUT  NOCOPY NUMBER
    ,x_msg_data                      OUT  NOCOPY VARCHAR2
    ,x_return_status                 OUT  NOCOPY VARCHAR2);
   --bug 5509192


end PA_BUDGET_PUB;

/
