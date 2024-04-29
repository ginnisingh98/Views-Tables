--------------------------------------------------------
--  DDL for Package Body PA_ASSIGNMENT_PROGRESS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ASSIGNMENT_PROGRESS_PUB" AS
/* $Header: PAPRASPB.pls 120.9.12010000.3 2010/04/01 17:11:23 rbruno ship $ */

G_PKG_NAME              CONSTANT VARCHAR2(30) := 'PA_ASSIGNMENT_PROGRESS_PUB';

--g1_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

PROCEDURE UPDATE_ASSIGNMENT_PROGRESS(
 p_api_version             IN NUMBER    := 1.0                             ,
 p_init_msg_list           IN VARCHAR2  := FND_API.G_TRUE                  ,
 p_commit                  IN VARCHAR2  := FND_API.G_FALSE                 ,
 p_validate_only           IN VARCHAR2  := FND_API.G_TRUE                  ,
 p_validation_level        IN NUMBER    := FND_API.G_VALID_LEVEL_FULL      ,
 p_calling_module          IN VARCHAR2  := 'SELF_SERVICE'                  ,
 p_action                  IN VARCHAR2  := 'SAVE'                          ,
 p_bulk_load_flag          IN VARCHAR2  := 'N'                             ,
 p_progress_mode           IN VARCHAR2  := 'FUTURE'                        ,
 p_percent_complete_id     IN NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM      ,
 p_project_id              IN NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM      ,
 p_object_id               IN NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM      ,
 p_object_version_id       IN NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM      ,
 p_task_id                 IN NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM      ,
 p_as_of_date                 IN   DATE      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE     ,
 p_progress_comment           IN   VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR     ,
 p_brief_overview             IN   VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR     ,
 p_actual_start_date          IN   DATE      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE     ,
 p_actual_finish_date         IN   DATE      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE     ,
 p_estimated_start_date       IN   DATE      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE     ,
 p_estimated_finish_date      IN   DATE      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE     ,
 p_record_version_number      IN   NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM      ,
 p_pm_product_code            IN   VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR     ,
 p_rate_based_flag            IN   VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR     ,
 p_resource_class_code        IN   VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR     ,
 p_txn_currency_code          IN        VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR         ,
 p_rbs_element_id             IN        NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM          ,
 --p_resource_list_member_id    IN        NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM          , --bug# 3764224
 p_resource_assignment_id    IN        NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM          ,
 p_actual_cost                IN        NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM          , -- Bug3621404 This parameter represents raw cost
 p_actual_effort              IN        NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM          ,
 p_planned_cost               IN   NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM      , -- Bug3621404 This parameter represents raw cost
 p_planned_effort             IN   NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM      ,
 p_structure_type             IN   VARCHAR2       := 'WORKPLAN'                                ,
 p_structure_version_id       IN   NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM      ,
 p_actual_cost_this_period    IN   NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM      , -- Bug3621404 This parameter represents raw cost
 p_actual_effort_this_period  IN   NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM      ,
 p_etc_cost_this_period       IN   NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM      , -- Though the name of this column is this period but it is cumulative -- Bug3621404 This parameter represents raw cost
 p_etc_effort_this_period     IN   NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM      , -- Though the name of this column is this period but it is cumulative
 p_scheduled_start_date       IN   DATE           := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE     ,
 p_scheduled_finish_date      IN   DATE           := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE     ,
 x_return_status              OUT  NOCOPY VARCHAR2                                                    , --File.Sql.39 bug 4440895
 x_msg_count                  OUT  NOCOPY NUMBER                                                      , --File.Sql.39 bug 4440895
 x_msg_data                   OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

   l_api_name                      CONSTANT VARCHAR(30) := 'UPDATE_ASSIGNMENT_PROGRESS'             ;
   l_api_version                   CONSTANT NUMBER      := 1.0                            ;
   l_return_status                 VARCHAR2(1)                                       ;
   l_msg_count                     NUMBER                                       ;
   l_msg_data                      VARCHAR2(250)                                ;
   l_data                          VARCHAR2(250)                                ;
   l_msg_index_out                 NUMBER                                       ;
   l_error_msg_code                VARCHAR2(250)                                ;
   l_user_id                       NUMBER         := FND_GLOBAL.USER_ID                   ;
   l_login_id                      NUMBER         := FND_GLOBAL.LOGIN_ID                  ;
   l_task_id                NUMBER                                    ;
   l_assignment_id                 NUMBER                                       ;
   l_project_id                    NUMBER                                       ;
   l_percent_complete_id    NUMBER                                    ;
   l_PROGRESS_ROLLUP_ID          NUMBER                                    ;
   l_last_progress_date            DATE                                         ;
   l_progress_exists_on_aod        VARCHAR2(15)                                      ;
   l_db_action                     VARCHAR2(10)                                      ;
   l_published_flag                VARCHAR2(1)                                       ;
   l_current_flag                  VARCHAR2(1)                                       ;
   l_actual_start_date             DATE                                         ;
   l_actual_finish_date            DATE                                         ;
    --bug no. 3586648  start
   l_scheduled_start_date          DATE                                         ;
   l_scheduled_finish_date         DATE                                         ;
    --bug no. 3586648  end
   l_estimated_start_date          DATE                                         ;
   l_estimated_finish_date         DATE                                         ;
   l_est_remaining_eff_flag        VARCHAR2(1)                                       ;
   l_rollup_rec_ver_number         NUMBER                                       ;
   l_published_by_party_id         NUMBER            := PA_UTILS.get_party_id( l_user_id )          ;
   l_working_aod                   DATE                                         ;
   l_aod                           DATE                                         ;
   l_progress_entry_enable_flag    VARCHAR2(1)                                       ;
   l_object_type            VARCHAR2(15)          := 'PA_ASSIGNMENTS'                ;
   l_structure_version_id        NUMBER                                    ;
   l_published_structure           VARCHAR2(1)                                       ;
   l_object_version_id           NUMBER                                    ;
   g1_debug_mode            VARCHAR2(1)                                    ;
   --l_structure_shared          VARCHAR2(1)                                    ;
   l_structure_sharing_code        VARCHAR2(30)                                      ;  --bug no. 3586648
   l_actual_effort_this_period     NUMBER                                       ;
   l_etc_effort_this_period        NUMBER                                       ;
   l_brief_overview         VARCHAR2(250)                                  ;
   l_progress_comment            VARCHAR2(4000)                                 ;
   l_pm_product_code               VARCHAR2(30)                                      ;


  -- Raw Cost Changes : Changed the variables to include raw or burden
   l_ppl_act_raw_cost_to_date_tc   NUMBER                                       ;
   l_ppl_act_raw_cost_to_date_fc   NUMBER                                       ;
   l_ppl_act_raw_cost_to_date_pc   NUMBER                                       ;
   l_ppl_act_bur_cost_to_date_tc   NUMBER                                       ;
   l_ppl_act_bur_cost_to_date_fc   NUMBER                                       ;
   l_ppl_act_bur_cost_to_date_pc   NUMBER                                       ;
   l_eqp_act_raw_cost_to_date_tc NUMBER                                    ;
   l_eqp_act_raw_cost_to_date_fc NUMBER                                    ;
   l_eqp_act_raw_cost_to_date_pc NUMBER                                    ;
   l_eqp_act_bur_cost_to_date_tc NUMBER                                    ;
   l_eqp_act_bur_cost_to_date_fc NUMBER                                    ;
   l_eqp_act_bur_cost_to_date_pc NUMBER                                    ;
   l_oth_act_raw_cost_to_date_tc   NUMBER                                       ;
   l_oth_act_raw_cost_to_date_fc   NUMBER                                       ;
   l_oth_act_raw_cost_to_date_pc   NUMBER                                       ;
   l_oth_act_bur_cost_to_date_tc   NUMBER                                       ;
   l_oth_act_bur_cost_to_date_fc   NUMBER                                       ;
   l_oth_act_bur_cost_to_date_pc   NUMBER                                       ;
   l_ppl_act_effort_to_date        NUMBER                                       ;
   l_eqpmt_act_effort_to_date    NUMBER                                    ;
   l_act_txn_raw_cost            NUMBER                                    ;
   l_act_txn_bur_cost            NUMBER                                    ;

   l_ppl_etc_raw_cost_tc    NUMBER                                    ;
   l_ppl_etc_raw_cost_fc    NUMBER                                    ;
   l_ppl_etc_raw_cost_pc    NUMBER                                    ;
   l_ppl_etc_bur_cost_tc    NUMBER                                    ;
   l_ppl_etc_bur_cost_fc    NUMBER                                    ;
   l_ppl_etc_bur_cost_pc    NUMBER                                    ;
   l_eqpmt_etc_raw_cost_tc       NUMBER                                    ;
   l_eqpmt_etc_raw_cost_fc       NUMBER                                    ;
   l_eqpmt_etc_raw_cost_pc       NUMBER                                    ;
   l_eqpmt_etc_bur_cost_tc       NUMBER                                    ;
   l_eqpmt_etc_bur_cost_fc       NUMBER                                    ;
   l_eqpmt_etc_bur_cost_pc       NUMBER                                    ;
   l_oth_etc_raw_cost_tc    NUMBER                                    ;
   l_oth_etc_raw_cost_fc    NUMBER                                    ;
   l_oth_etc_raw_cost_pc    NUMBER                                    ;
   l_oth_etc_bur_cost_tc    NUMBER                                    ;
   l_oth_etc_bur_cost_fc    NUMBER                                    ;
   l_oth_etc_bur_cost_pc    NUMBER                                    ;
   l_ppl_etc_effort         NUMBER                                    ;
   l_eqpmt_etc_effort            NUMBER                                    ;
   l_etc_txn_raw_cost            NUMBER                                    ;
   l_etc_txn_bur_cost       NUMBER                                    ;
   l_txn_currency_code           VARCHAR2(30)                                        ;
   l_project_curr_code             VARCHAR2(30)                                      ;
   l_project_rate_type             VARCHAR2(30)                                      ;
   l_project_rate_date             DATE                                         ;
   l_project_exch_rate             NUMBER                                       ;
   l_act_project_raw_cost          NUMBER                                       ;
   l_act_project_bur_cost          NUMBER                                       ;
   l_projfunc_curr_code            VARCHAR2(30)                                      ;
   l_projfunc_cost_rate_type       VARCHAR2(30)                                      ;
   l_projfunc_cost_rate_date       DATE                                         ;
   l_projfunc_cost_exch_rate       NUMBER                                       ;
   l_act_projfunc_raw_cost         NUMBER                                       ;
   l_act_projfunc_bur_cost         NUMBER                                       ;

   l_etc_project_raw_cost          NUMBER                                       ;
   l_etc_projfunc_raw_cost         NUMBER                                       ;
   l_etc_project_bur_cost          NUMBER                                       ;
   l_etc_projfunc_bur_cost         NUMBER                                       ;

   l_prog_pa_period_name    VARCHAR2(30)                                        ;
   l_prog_gl_period_name    VARCHAR2(30)                                        ;

   --bug no.3595585 Satish start
   l_etc_txn_raw_cost_this_period      NUMBER                                        ;
   l_etc_prj_raw_cost_this_period      NUMBER                                        ;
   l_etc_pfc_raw_cost_this_period      NUMBER                                        ;
   l_etc_txn_bur_cost_this_period      NUMBER                                        ;
   l_etc_prj_bur_cost_this_period      NUMBER                                        ;
   l_etc_pfc_bur_cost_this_period      NUMBER                                        ;

   l_etc_effort_incr               NUMBER                                       ;
   l_etc_effort_last             NUMBER                                         ;
   --bug no.3595585 Satish end

   -- required for compilation
   l_percent_complete              NUMBER                                       ;
   l_progress_status_code          VARCHAR2(30)  :='PROGRESS_STAT_ON_TRACK'                               ;
   l_task_status            VARCHAR2(150)                                       ;
   l_rollup_progress_status      VARCHAR2(150):='PROGRESS_STAT_ON_TRACK'                                  ;
   l_INCREMENTAL_WORK_QTY        NUMBER                                         ;
   l_CUMULATIVE_WORK_QTY    NUMBER                                              ;
   l_BASE_PERCENT_COMPLETE       NUMBER                                         ;
   l_EFF_ROLLUP_PERCENT_COMP     NUMBER                                         ;
   l_rollup_completed_percentage   NUMBER                                       ;
   l_BASE_PERCENT_COMP_DERIV_CODE  VARCHAR2(30)                                 ;
   l_BASE_PROGRESS_STATUS_CODE     VARCHAR2(30) :='PROGRESS_STAT_ON_TRACK'                                ;
   l_EFF_ROLLUP_PROG_STAT_CODE     VARCHAR2(150)                                ;
   l_ACTUAL_WQ_ENTRY_CODE          VARCHAR2(30)                                 ;
   l_wq_enabled_flag             VARCHAR2(1)                                    ;
   l_percent_complete_flag       VARCHAR2(1)                                    ;
   l_allow_collab_prog_entry     VARCHAR2(1)                                    ;
   l_allw_phy_prcnt_cmp_overrides  VARCHAR2(1)                                  ;
   l_task_weight_basis_code      VARCHAR2(30)                                   ;

--   l_res_list_memb_id_tbl          SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()             ;
--   l_res_effort_tbl            SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()            ;
--   l_res_txn_cost_tbl          SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()            ;
--   l_etc_res_effort_tbl             SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()            ;
--   l_etc_res_txn_cost_tbl      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()            ;

   CURSOR cur_check_published_version(c_structure_version_id number, c_project_id number)
   IS
   SELECT decode(status.project_system_status_code, 'STRUCTURE_PUBLISHED', 'Y', 'N')
   FROM pa_proj_elem_ver_structure str, pa_project_statuses status
   where str.element_version_id = c_structure_version_id
   AND str.project_id = c_project_id
   AND str.status_code = status.project_status_code;


   -- FPM Dev CR 3 Begin
   l_task_elem_version_id_tbl      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()               ;
   l_planned_people_effort_tbl        SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()            ;
   l_planned_equip_effort_tbl    SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()            ;
   l_resource_assignment_id_tbl       SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()            ;
   l_resource_list_member_id_tbl   SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()               ;
   l_resource_class_code_tbl     SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE() ;

-- Raw Cost Changes : Changed the cost columns to Raw Cost
   CURSOR cur_task_cost(c_project_id number, c_object_id number, c_structure_type VARCHAR2, c_resource_class_code VARCHAR2, c_as_of_date DATE)
   IS
    SELECT decode(c_resource_class_code, 'PEOPLE', nvl(ppr.ppl_act_rawcost_to_date_tc,0), 'EQUIPMENT', nvl(ppr.eqpmt_act_rawcost_to_date_tc,0), nvl(ppr.oth_act_rawcost_to_date_tc,0)) tc_raw_cost,
         decode(c_resource_class_code, 'PEOPLE', nvl(ppr.ppl_act_rawcost_to_date_pc,0), 'EQUIPMENT', nvl(ppr.eqpmt_act_rawcost_to_date_pc,0), nvl(ppr.oth_act_rawcost_to_date_pc,0)) pc_raw_cost,
         decode(c_resource_class_code, 'PEOPLE', nvl(ppr.ppl_act_rawcost_to_date_fc,0), 'EQUIPMENT', nvl(ppr.eqpmt_act_rawcost_to_date_fc,0), nvl(ppr.oth_act_rawcost_to_date_fc,0)) fc_raw_cost,
         decode(c_resource_class_code, 'PEOPLE', nvl(ppr.ppl_act_cost_to_date_tc,0), 'EQUIPMENT', nvl(ppr.eqpmt_act_cost_to_date_tc,0), nvl(ppr.oth_act_cost_to_date_tc,0)) tc_bur_cost,
         decode(c_resource_class_code, 'PEOPLE', nvl(ppr.ppl_act_cost_to_date_pc,0), 'EQUIPMENT', nvl(ppr.eqpmt_act_cost_to_date_pc,0), nvl(ppr.oth_act_cost_to_date_pc,0)) pc_bur_cost,
         decode(c_resource_class_code, 'PEOPLE', nvl(ppr.ppl_act_cost_to_date_fc,0), 'EQUIPMENT', nvl(ppr.eqpmt_act_cost_to_date_fc,0), nvl(ppr.oth_act_cost_to_date_fc,0)) fc_bur_cost,
         decode(c_resource_class_code, 'PEOPLE', nvl(ppr.PPL_ACT_EFFORT_TO_DATE,0), 'EQUIPMENT', nvl(ppr.EQPMT_ACT_EFFORT_TO_DATE,0), nvl(ppr.OTH_QUANTITY_TO_DATE,0)) act_effort -- 3696572 OTH_QUANTITY_TO_DATE shd also be considered here
     FROM pa_progress_rollup ppr
    WHERE  ppr.project_id = c_project_id
     AND   ppr.object_id  = c_object_id
     AND   ppr.structure_type = c_structure_type
     AND   ppr.structure_version_id is null        --bug# 3821106 Satish
     AND   ppr.object_type = 'PA_ASSIGNMENTS'
     AND   ppr.proj_element_id = p_task_id    --bug 3861360
     AND   ppr.current_flag <> 'W'   -- Bug 3879461
     --bug# 3821106 Satish
     /*AND   ppr.as_of_date = ( SELECT max(as_of_date)
                           from pa_progress_rollup ppr2
                          WHERE ppr2.as_of_date < c_as_of_date
                           AND  ppr2.project_id = c_project_id
                           AND ppr2.object_id  = c_object_id
                           AND ppr2.object_type = 'PA_ASSIGNMENTS'
                           AND ppr2.structure_type = c_structure_type
                       );*/
     AND   ppr.as_of_date = ( SELECT max(as_of_date)
                           from pa_progress_rollup ppr2
                          WHERE ppr2.as_of_date < c_as_of_date ---4290592
                           AND  ppr2.project_id = c_project_id
                           AND ppr2.object_id  = c_object_id
                           AND ppr2.object_type = 'PA_ASSIGNMENTS'
                           AND ppr2.structure_type = c_structure_type
			   AND ppr2.structure_version_id is null
                           AND ppr2.proj_element_id = p_task_id    --bug 3861360
			   AND ppr2.current_flag <> 'W'   -- Bug 3879461
			   -- Bug 3879461 : Not exists is not required now
--			   AND NOT EXISTS (
--					    SELECT 'X' FROM pa_percent_completes ppc
--					    WHERE ppc.date_computed = ppr2.as_of_date
--					    AND   ppc.project_id = c_project_id
--					    AND   ppc.object_id  = c_object_id
--					    AND   ppc.object_type = 'PA_ASSIGNMENTS'
--					    AND   ppc.structure_type = c_structure_type
--					    AND   ppc.published_flag = 'N'
--                                             AND  ppc.task_id = p_task_id   --3861360
--					  )
                       );

   CURSOR cur_task_cost_shared(c_project_id number, c_object_id number, c_structure_type VARCHAR2, c_resource_class_code VARCHAR2, c_as_of_date DATE)
   IS
    SELECT decode(c_resource_class_code, 'PEOPLE', nvl(ppr.ppl_act_rawcost_to_date_tc,0), 'EQUIPMENT', nvl(ppr.eqpmt_act_rawcost_to_date_tc,0), nvl(ppr.oth_act_rawcost_to_date_tc,0)) tc_raw_cost,
         decode(c_resource_class_code, 'PEOPLE', nvl(ppr.ppl_act_rawcost_to_date_pc,0), 'EQUIPMENT', nvl(ppr.eqpmt_act_rawcost_to_date_pc,0), nvl(ppr.oth_act_rawcost_to_date_pc,0)) pc_raw_cost,
         decode(c_resource_class_code, 'PEOPLE', nvl(ppr.ppl_act_rawcost_to_date_fc,0), 'EQUIPMENT', nvl(ppr.eqpmt_act_rawcost_to_date_fc,0), nvl(ppr.oth_act_rawcost_to_date_fc,0)) fc_raw_cost,
         decode(c_resource_class_code, 'PEOPLE', nvl(ppr.ppl_act_cost_to_date_tc,0), 'EQUIPMENT', nvl(ppr.eqpmt_act_cost_to_date_tc,0), nvl(ppr.oth_act_cost_to_date_tc,0)) tc_bur_cost,
         decode(c_resource_class_code, 'PEOPLE', nvl(ppr.ppl_act_cost_to_date_pc,0), 'EQUIPMENT', nvl(ppr.eqpmt_act_cost_to_date_pc,0), nvl(ppr.oth_act_cost_to_date_pc,0)) pc_bur_cost,
         decode(c_resource_class_code, 'PEOPLE', nvl(ppr.ppl_act_cost_to_date_fc,0), 'EQUIPMENT', nvl(ppr.eqpmt_act_cost_to_date_fc,0), nvl(ppr.oth_act_cost_to_date_fc,0)) fc_bur_cost,
         decode(c_resource_class_code, 'PEOPLE', nvl(ppr.PPL_ACT_EFFORT_TO_DATE,0), 'EQUIPMENT', nvl(ppr.EQPMT_ACT_EFFORT_TO_DATE,0), nvl(ppr.OTH_QUANTITY_TO_DATE,0)) act_effort -- 3696572 OTH_QUANTITY_TO_DATE shd also be considered here
     FROM pa_progress_rollup ppr
    WHERE  ppr.project_id = c_project_id
     AND   ppr.object_id  = c_object_id
     AND   ppr.structure_type = c_structure_type
     AND   ppr.structure_version_id is null        --bug# 3821106 Satish
     AND   ppr.object_type = 'PA_ASSIGNMENTS'
     AND   ppr.proj_element_id = p_task_id    --bug 3861360
     AND   ppr.current_flag <> 'W'   -- Bug 3879461
     --bug# 3821106 Satish
     AND   ppr.as_of_date = ( SELECT max(as_of_date)
                           from pa_progress_rollup ppr2
                          WHERE ppr2.as_of_date <= c_as_of_date ---4290592
                           AND  ppr2.project_id = c_project_id
                           AND ppr2.object_id  = c_object_id
                           AND ppr2.object_type = 'PA_ASSIGNMENTS'
                           AND ppr2.structure_type = c_structure_type
			   AND ppr2.structure_version_id is null
                           AND ppr2.proj_element_id = p_task_id    --bug 3861360
			   AND ppr2.current_flag <> 'W'   -- Bug 3879461
                       );

 CURSOR cur_task_cost_latest(c_project_id number, c_object_id number, c_structure_type VARCHAR2, c_resource_class_code VARCHAR2, c_as_of_date DATE)
   IS
    SELECT decode(c_resource_class_code, 'PEOPLE', nvl(ppr.ppl_act_rawcost_to_date_tc,0), 'EQUIPMENT', nvl(ppr.eqpmt_act_rawcost_to_date_tc,0), nvl(ppr.oth_act_rawcost_to_date_tc,0)) tc_raw_cost,
         decode(c_resource_class_code, 'PEOPLE', nvl(ppr.ppl_act_rawcost_to_date_pc,0), 'EQUIPMENT', nvl(ppr.eqpmt_act_rawcost_to_date_pc,0), nvl(ppr.oth_act_rawcost_to_date_pc,0)) pc_raw_cost,
         decode(c_resource_class_code, 'PEOPLE', nvl(ppr.ppl_act_rawcost_to_date_fc,0), 'EQUIPMENT', nvl(ppr.eqpmt_act_rawcost_to_date_fc,0), nvl(ppr.oth_act_rawcost_to_date_fc,0)) fc_raw_cost,
         decode(c_resource_class_code, 'PEOPLE', nvl(ppr.ppl_act_cost_to_date_tc,0), 'EQUIPMENT', nvl(ppr.eqpmt_act_cost_to_date_tc,0), nvl(ppr.oth_act_cost_to_date_tc,0)) tc_bur_cost,
         decode(c_resource_class_code, 'PEOPLE', nvl(ppr.ppl_act_cost_to_date_pc,0), 'EQUIPMENT', nvl(ppr.eqpmt_act_cost_to_date_pc,0), nvl(ppr.oth_act_cost_to_date_pc,0)) pc_bur_cost,
         decode(c_resource_class_code, 'PEOPLE', nvl(ppr.ppl_act_cost_to_date_fc,0), 'EQUIPMENT', nvl(ppr.eqpmt_act_cost_to_date_fc,0), nvl(ppr.oth_act_cost_to_date_fc,0)) fc_bur_cost,
         decode(c_resource_class_code, 'PEOPLE', nvl(ppr.PPL_ACT_EFFORT_TO_DATE,0), 'EQUIPMENT', nvl(ppr.EQPMT_ACT_EFFORT_TO_DATE,0), nvl(ppr.OTH_QUANTITY_TO_DATE,0)) act_effort
     FROM pa_progress_rollup ppr
    WHERE  ppr.project_id = c_project_id
     AND   ppr.object_id  = c_object_id
     AND   ppr.structure_type = c_structure_type
     AND   ppr.structure_version_id is null        --bug# 3821106 Satish
     AND   ppr.object_type = 'PA_ASSIGNMENTS'
     AND   ppr.proj_element_id = p_task_id    --bug 3861360
     AND   ppr.current_flag <> 'W'   -- Bug 3879461
     AND   ppr.as_of_date = c_as_of_date;

    subm_prog_exists_aod                VARCHAR2(1):='N';
    l_act_raw_cost_last_subm_tc         NUMBER             ;
    l_act_raw_cost_last_subm_pc         NUMBER             ;
    l_act_raw_cost_last_subm_fc         NUMBER             ;
    l_act_bur_cost_last_subm_tc         NUMBER             ;
    l_act_bur_cost_last_subm_pc         NUMBER             ;
    l_act_bur_cost_last_subm_fc         NUMBER             ;
    l_act_effort_last_subm         NUMBER               ;
    l_act_raw_cost_latest_subm_tc         NUMBER           ;
    l_act_raw_cost_latest_subm_pc         NUMBER           ;
    l_act_raw_cost_latest_subm_fc         NUMBER           ;
    l_act_bur_cost_latest_subm_tc         NUMBER           ;
    l_act_bur_cost_latest_subm_pc         NUMBER           ;
    l_act_bur_cost_latest_subm_fc         NUMBER           ;
    l_act_effort_latest_subm         NUMBER              ;
    l_total_effort            NUMBER                                       ;
    l_record_version_number        NUMBER                                       ;
    -- FPM Dev CR 3 End

    --bug 3608801
    l_oth_quantity_to_date              NUMBER;
    l_oth_etc_quantity                  NUMBER;
    --bug 3608801
    -- Bug 3606627 Start
    l_resource_list_member_id      NUMBER;
    l_rate_based_flag                   VARCHAR2(1);
    l_resource_class_code          pa_task_assignments_v.resource_class_code%TYPE;
    l_rbs_element_id               NUMBER;
    l_actual_raw_cost              NUMBER;
    l_actual_raw_cost_this_period       NUMBER;
    l_actual_bur_cost              NUMBER;
    l_actual_bur_cost_this_period       NUMBER;

    l_actual_effort           NUMBER;
    l_etc_raw_cost_this_period          NUMBER;
    l_etc_bur_cost_this_period          NUMBER;
    L_DUMMY_RAW_COST                    NUMBER;
    L_RES_RAW_RATE                      NUMBER;
    L_RES_BURDEN_RATE                   NUMBER;
    L_BURDEN_MULTIPLIER                 NUMBER;
    L_RES_CUR_CODE                      VARCHAR2(15);
    l_etc_txn_raw_cost_last        NUMBER;
    l_etc_prj_raw_cost_last        NUMBER;
    l_etc_pfc_raw_cost_last        NUMBER;
    l_etc_txn_bur_cost_last        NUMBER;
    l_etc_prj_bur_cost_last        NUMBER;
    l_etc_pfc_bur_cost_last        NUMBER;
    L_DUMMY_BURDEN_COST            NUMBER;

 -- Bug 3627315 : Added new parameters to hold plan rates for ETC
    l_plan_res_cur_code		   VARCHAR2(15);
    l_plan_res_raw_rate            NUMBER;
    l_plan_res_burden_rate	   NUMBER;
    l_plan_burden_multiplier       NUMBER;

    -- Bug 3696429 Satish start
    l_proj_res_raw_rate            NUMBER;
    l_projfunc_res_raw_rate        NUMBER;
    l_proj_res_burden_rate         NUMBER;
    l_projfunc_res_burden_rate     NUMBER;
    -- Bug 3696429 Satish end


    --Begin add by rtarway
    --BUG 3630743( This cursor is to get planned values)
    CURSOR c_get_planned_values (l_resource_list_member_id NUMBER, l_resource_assignment_id NUMBER, l_project_id NUMBER) IS
    SELECT
     planned_quantity,
     planned_bur_cost_txn_cur,
     planned_bur_cost_projfunc,
     planned_bur_cost_proj_cur,
     planned_raw_cost_txn_cur,
     planned_raw_cost_proj_cur,
     planned_raw_cost_projfunc,
     budget_version_id       ---4372462
     FROM
     pa_task_asgmts_v
     WHERE
     RESOURCE_LIST_MEMBER_ID = l_resource_list_member_id
     AND
     RESOURCE_ASSIGNMENT_ID  = l_resource_assignment_id
     AND
     PROJECT_ID = l_project_id;

     --This cursor to see if any progress record exists.
     CURSOR c_if_progress_exists(l_object_id NUMBER, l_project_id NUMBER, l_structure_version_id NUMBER) IS
     SELECT 'x' FROM dual
     WHERE EXISTS
     (
      SELECT 'y' FROM PA_PROGRESS_ROLLUP
      WHERE OBJECT_ID = l_object_id
      AND PROJECT_ID = l_project_id
      AND OBJECT_TYPE = 'PA_ASSIGNMENTS'
      AND STRUCTURE_TYPE = 'WORKPLAN'
      and proj_element_id = l_task_id  --3818384
      AND current_flag <> 'W'   -- Bug 3879461
      AND
      (
       ( l_published_structure = 'Y' AND STRUCTURE_VERSION_ID IS NULL)
       OR
       ( l_published_structure = 'N' AND STRUCTURE_VERSION_ID = l_structure_version_id)
      )
     );

     --bug# 3814545 Satish
     l_progress_exists VARCHAR2(1):='N';
     l_budget_version_id        NUMBER; -- 4372462
     l_planned_quantity  NUMBER;
     l_planned_bur_cost_txn_cur NUMBER;
     l_planned_bur_cost_projfunc NUMBER;
     l_planned_bur_cost_proj_cur NUMBER;
     l_planned_raw_cost_txn_cur NUMBER;
     l_planned_raw_cost_proj_cur NUMBER;
     l_planned_raw_cost_projfunc NUMBER;
     l_track_wp_cost_flag  VARCHAR2(1) := 'Y'; -- Bug 3801745

     --bug 3824042
     l_prj_currency_code VARCHAR2(15) := null;
     l_prjfunc_currency_code VARCHAR2(15) := null;
     l_rollup_current_flag VARCHAR2(1);  -- Bug 3879461

     /*
     --bug 3958686, check whether the the assignment is hidden assignment, start
     CURSOR cur_assgmt(l_resource_list_member_id NUMBER, l_resource_assignment_id NUMBER, l_task_id NUMBER, l_project_id NUMBER, l_structure_version_id NUMBER) IS
     SELECT ta_display_flag
     FROM pa_task_assignments_v
     WHERE RESOURCE_LIST_MEMBER_ID = l_resource_list_member_id  AND
           RESOURCE_ASSIGNMENT_ID  = l_resource_assignment_id   AND
	   TASK_ID                 = l_task_id                  AND
           PROJECT_ID              = l_project_id               AND
	   STRUCTURE_VERSION_ID    = l_structure_version_id;

     l_ta_display_flag VARCHAR2(1);
     --bug 3958686, check whether the the assignment is hidden assignment, end
     */
-- 4533112 Begin
CURSOR c_get_dates_overrides(c_project_id number, c_object_id number, c_object_type varchar2, c_as_of_date Date) IS
SELECT decode(ppr.base_progress_status_code,'Y','Y','N') date_override_flag
, ppr.estimated_start_date
, ppr.estimated_finish_date
, ppr.actual_start_date
, ppr.actual_finish_date
, ppe.status_code
FROM pa_progress_rollup ppr
, pa_proj_elements ppe
WHERE ppr.project_id = c_project_id
AND ppr.object_id = c_object_id
AND ppr.object_type = c_object_type
AND ppr.structure_type = 'WORKPLAN'
AND ppr.structure_version_id is null
AND trunc(ppr.as_of_date) <= trunc(c_as_of_date)
AND ppr.current_flag IN ('Y', 'N')
AND ppr.proj_element_id = ppe.proj_element_id
ORDER by as_of_date desc;


l_date_override_flag		VARCHAR2(1):='N';
l_db_date_override_flag		VARCHAR2(1):='N';
l_db_estimated_start_date	DATE;
l_db_estimated_finish_date	DATE;
l_db_actual_start_date		DATE;
l_db_actual_finish_date		DATE;
l_clex_estimated_start_date	DATE;
l_clex_estimated_finish_date	DATE;
l_clex_actual_start_date	DATE;
l_clex_actual_finish_date	DATE;
l_task_status_code		VARCHAR2(150);
-- 4533112 End

BEGIN

        -- Percent Complete          Progress Rollup     Possible         Comments
        -- Insert                    Update              No               Applicable for summary level
        -- Insert                    Insert              Yes              Normal Case
        -- Update                    Insert              Yes              When record save on 1st March(current) and then publish on 8th March(future)
        -- Update                    Update              Yes              Normal Case

    g1_debug_mode := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
    IF g1_debug_mode  = 'Y' THEN
       pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'ENTERED', x_Log_Level=> 3);
    END IF;

    IF g1_debug_mode  = 'Y' THEN
       pa_debug.init_err_stack ('PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint UPDATE_ASSIGNMENT_PROGRESS;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF g1_debug_mode  = 'Y' THEN
       pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'p_task_id: '||p_task_id, x_Log_Level=> 3);
       pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'p_object_version_id: '||p_object_version_id, x_Log_Level=> 3);
       pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'p_project_id: '||p_project_id, x_Log_Level=> 3);
       pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'p_object_id: '||p_object_id, x_Log_Level=> 3);
       pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'p_as_of_date: '||p_as_of_date, x_Log_Level=> 3);
       pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'p_percent_complete_id: '||p_percent_complete_id, x_Log_Level=> 3);
       pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'p_actual_start_date: '||p_actual_start_date, x_Log_Level=> 3);
       pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'p_actual_finish_date: '||p_actual_finish_date, x_Log_Level=> 3);
       pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'p_estimated_start_date: '||p_estimated_start_date, x_Log_Level=> 3);
       pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'p_estimated_finish_date: '||p_estimated_finish_date, x_Log_Level=> 3);
       pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'p_record_version_number: '||p_record_version_number, x_Log_Level=> 3);
       pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'p_actual_cost_this_period: '||p_actual_cost_this_period, x_Log_Level=> 3);
       pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'p_actual_effort_this_period: '||p_actual_effort_this_period, x_Log_Level=> 3);
       pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'p_etc_cost_this_period: '||p_etc_cost_this_period, x_Log_Level=> 3);
       pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'p_etc_effort_this_period: '||p_etc_effort_this_period, x_Log_Level=> 3);
       pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'p_structure_type: '||p_structure_type, x_Log_Level=> 3);
       pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'p_structure_version_id: '||p_structure_version_id, x_Log_Level=> 3);
       pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'p_resource_class_code: '||p_resource_class_code, x_Log_Level=> 3);
       pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'p_rate_based_flag: '||p_rate_based_flag, x_Log_Level=> 3);
    END IF;


    x_return_status := FND_API.G_RET_STS_SUCCESS;

SELECT DECODE(ptt.REMAIN_EFFORT_ENABLE_FLAG, 'Y', DECODE(pppa.REMAIN_EFFORT_ENABLE_FLAG, 'Y', 'Y', 'N'), 'N')
INTO   l_est_remaining_eff_flag
FROM   pa_proj_elements ppe,
       pa_task_types ptt   ,
       pa_proj_progress_attr pppa
WHERE  ppe.proj_element_id = p_task_id
   AND ppe.type_id         = ptt.task_type_id
   AND pppa.project_id     = ppe.project_id
   AND pppa.structure_type = 'WORKPLAN'; -- For Bug 8887270

    --moved this up for bug 3675107
    ---4457403, added begin/end block to handle no_data_found exception
    begin
      l_prog_pa_period_name := PA_PROGRESS_UTILS.Prog_Get_Pa_Period_Name(p_as_of_date);
      l_prog_gl_period_name := PA_PROGRESS_UTILS.Prog_Get_gl_Period_Name(p_as_of_date);
    exception
      WHEN OTHERS THEN
                 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                            p_msg_name => 'PA_FP_INVALID_DATE_RANGE');
                 x_msg_data := 'PA_FP_INVALID_DATE_RANGE';
                 x_return_status := 'E';
                 x_msg_count := fnd_msg_pub.count_msg;
                 RAISE  FND_API.G_EXC_ERROR;
    end;

    l_track_wp_cost_flag :=  pa_fp_wp_gen_amt_utils.get_wp_track_cost_amt_flag(p_project_id);  --Bug 3801745
--moved this up for bug 3675107

    --bug 3824042
    SELECT project_currency_code, projfunc_currency_code  INTO  l_prj_currency_code, l_prjfunc_currency_code  FROM pa_projects_all WHERE project_id = p_project_id;

    IF p_task_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    THEN
       l_task_id := 0;
    ELSE
       l_task_id := nvl(p_task_id, 0);
    END IF;

    --bug# 3764224 Changes for RLM start
    /*IF p_object_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    THEN
       l_assignment_id := 0;
    ELSE
       l_assignment_id := nvl(p_object_id, 0);
    END IF;*/

    IF p_resource_assignment_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    THEN
       l_assignment_id := 0;
    ELSE
       l_assignment_id := nvl(p_resource_assignment_id, 0);
    END IF;
    --bug# 3764224 Changes for RLM end

    IF p_object_version_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    THEN
       l_object_version_id := 0;
    ELSE
       l_object_version_id := nvl(p_object_version_id, 0);
    END IF;

    IF p_brief_overview = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    THEN
       l_brief_overview := null;
    ELSE
       l_brief_overview := p_brief_overview;
    END IF;

    IF p_progress_comment = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    THEN
       l_progress_comment := null;
    ELSE
       l_progress_comment := p_progress_comment;
    END IF;

    IF p_pm_product_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    THEN
       l_pm_product_code := null;
    ELSE
       l_pm_product_code := p_pm_product_code;
    END IF;

    OPEN cur_check_published_version(p_structure_version_id, p_project_id);
    FETCH cur_check_published_version INTO l_published_structure;
    CLOSE cur_check_published_version;

    IF l_published_structure = 'Y'
       OR p_structure_version_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  --maansari4/8
    THEN
     l_structure_version_id := null;
    ELSE
     l_structure_version_id := p_structure_version_id;
    END IF;

    --bug no. 3586648  start
    IF p_scheduled_start_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    THEN
        l_scheduled_start_date := null;
    ELSE
        l_scheduled_start_date := p_scheduled_start_date;
    END IF;

    IF p_scheduled_finish_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    THEN
        l_scheduled_finish_date := null;
    ELSE
        l_scheduled_finish_date := p_scheduled_finish_date;
    END IF;

    /* Bug 3606627 : Shifting this code below
    IF p_actual_start_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    THEN
        IF p_actual_cost_this_period > 0 OR p_actual_effort_this_period > 0
     THEN
         l_actual_start_date := l_scheduled_start_date;
     ELSE
            l_actual_start_date  := null;
     END IF;
    ELSE
        l_actual_start_date  := p_actual_start_date;
    END IF;
    */

    --bug no. 3586648  end

    IF p_actual_finish_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    THEN
        l_actual_finish_date  := null;
    ELSE
        l_actual_finish_date  := p_actual_finish_date;
    END IF;

    IF p_estimated_start_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    THEN
        l_estimated_start_date  := null;
    ELSE
        l_estimated_start_date  := p_estimated_start_date;
    END IF;

    IF p_estimated_finish_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    THEN
        l_estimated_finish_date  := null;
    ELSE
        l_estimated_finish_date  := p_estimated_finish_date;
    END IF;

    IF p_actual_effort_this_period <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND
       p_actual_effort_this_period IS NOT NULL
    THEN
        l_actual_effort_this_period          := p_actual_effort_this_period; -- This is incremental
    ELSE
     l_actual_effort_this_period        := null;
    END IF;

    -- 3958686, moved this code from below
    --bug# 3764224 Changes for RLM start
    -- Bug 3606627 Start
    /*IF p_resource_list_member_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND
       p_resource_list_member_id IS NOT NULL
    THEN
     l_resource_list_member_id          := p_resource_list_member_id;
    ELSE
     l_resource_list_member_id          := null;
    END IF;*/

    IF p_object_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND
       p_object_id IS NOT NULL
    THEN
     l_resource_list_member_id          := p_object_id;
    ELSE
     l_resource_list_member_id          := null;
    END IF;
    --bug# 3764224 Changes for RLM end
    /*
    --bug 3958686, start
    OPEN cur_assgmt(l_resource_list_member_id, l_assignment_id, l_task_id, p_project_id, p_structure_version_id);
    FETCH cur_assgmt INTO l_ta_display_flag;
    CLOSE cur_assgmt;
    --bug 3958686, end

    IF g1_debug_mode  = 'Y' THEN
       pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_ta_display_flag '||l_ta_display_flag, x_Log_Level=> 3);
    END IF;
    */

  -- 3970229 actuals can be -ive
  /*--3779387, 3958686 this error should not be raised for hidden assignment as in this case it is being called from update_task_progress
    IF l_actual_effort_this_period < 0 AND  l_ta_display_flag = 'Y'
    THEN
        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                             ,p_msg_name       => 'PA_TP_NO_NEG_ACT');
        x_msg_data := 'PA_TP_NO_NEG_ACT';
        x_return_status := 'E';
        RAISE  FND_API.G_EXC_ERROR;
    END IF;
  */
     --bug 3958686, end


    IF p_etc_effort_this_period <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND
       p_etc_effort_this_period IS NOT NULL AND l_est_remaining_eff_flag =  'Y' --For Bug 8887270
       --p_actual_finish_date  IS NULL AND p_actual_finish_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE maansari4/27
    THEN
     l_etc_effort_this_period      := p_etc_effort_this_period; -- This is cumulative
    ELSE
     l_etc_effort_this_period      := null;
    END IF;

    /* 5726773
--bug 3779387
    IF l_etc_effort_this_period < 0
    THEN
        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                             ,p_msg_name       => 'PA_TP_NO_NEG_ETC');
        x_msg_data := 'PA_TP_NO_NEG_ETC';
        x_return_status := 'E';
        RAISE  FND_API.G_EXC_ERROR;
    END IF;
    */


    --maansari 4/27
    -- Bug 3956299 : As per discussion with Saima, ETC should be given precedence over act finish date
    --IF p_actual_finish_date  IS NOT NULL AND p_actual_finish_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    --THEN
    --   l_etc_effort_this_period := 0;
    --END IF;
    IF l_etc_effort_this_period  IS NOT NULL AND l_etc_effort_this_period > 0
    THEN
       l_actual_finish_date := null;
    END IF;

--maansari 4/27


    IF p_txn_currency_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND
       p_txn_currency_code IS NOT NULL
    THEN
     l_txn_currency_code      := p_txn_currency_code;
    ELSE
     l_txn_currency_code      := null;
    END IF;

    IF p_rate_based_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND
       p_rate_based_flag IS NOT NULL
    THEN
     l_rate_based_flag        := p_rate_based_flag;
    ELSE
     l_rate_based_flag        := null;
    END IF;

    IF p_resource_class_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND
       p_resource_class_code IS NOT NULL
    THEN
     l_resource_class_code         := p_resource_class_code;
    ELSE
     l_resource_class_code         := null;
    END IF;

    IF p_rbs_element_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND
       p_rbs_element_id IS NOT NULL
    THEN
     l_rbs_element_id         := p_rbs_element_id;
    ELSE
     l_rbs_element_id         := null;
    END IF;
    -- Raw Cost Changes : Changed the vaiable names to include raw
    IF p_actual_cost <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND
       p_actual_cost IS NOT NULL
    THEN
     l_actual_raw_cost        := p_actual_cost;
    ELSE
     l_actual_raw_cost        := null;
    END IF;
    -- Raw Cost Changes : Changed the vaiable names to include raw
    IF p_actual_cost_this_period <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND
       p_actual_cost_this_period IS NOT NULL
    THEN
     l_actual_raw_cost_this_period      := p_actual_cost_this_period;
    ELSE
     l_actual_raw_cost_this_period      := null;
    END IF;

  ---- 3970229 actuals can be -ive
  /* --3779387
    IF l_actual_raw_cost_this_period < 0
    THEN
        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                             ,p_msg_name       => 'PA_TP_NO_NEG_ACT');
        x_msg_data := 'PA_TP_NO_NEG_ACT';
        x_return_status := 'E';
        RAISE  FND_API.G_EXC_ERROR;
    END IF;
  */


    IF p_actual_effort <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND
       p_actual_effort IS NOT NULL
    THEN
     l_actual_effort          := p_actual_effort;
    ELSE
     l_actual_effort          := null;
    END IF;
    -- Raw Cost Changes : Changed the vaiable names to include raw
    IF p_etc_cost_this_period <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND
       p_etc_cost_this_period IS NOT NULL
    THEN
     l_etc_raw_cost_this_period         := p_etc_cost_this_period;
    ELSE
     l_etc_raw_cost_this_period         := null;
    END IF;
    -- Bug 3606627 End

   /* 5726773
--bug 3779387 ---4378391 Added l_etc_effort_this_period is null
    IF l_etc_raw_cost_this_period < 0 and l_etc_effort_this_period is null
    THEN
        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                             ,p_msg_name       => 'PA_TP_NO_NEG_ETC');
        x_msg_data := 'PA_TP_NO_NEG_ETC';
        x_return_status := 'E';
        RAISE  FND_API.G_EXC_ERROR;
    END IF;
    */

    /* Bug 3606627 Shifting this code below
    l_res_list_memb_id_tbl.extend(1);
    l_res_list_memb_id_tbl(1)      := p_resource_list_member_id;
    l_txn_currency_code            := p_txn_currency_code;
    */


    ---- if status is CANCELLED
    IF PA_PROGRESS_UTILS.get_system_task_status(PA_PROGRESS_UTILS.get_task_status( p_project_id, p_task_id)) = 'CANCELLED'
    THEN
       PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                            ,p_msg_name       => 'PA_TP_ASSG_CANT_NTER_PRG_CNCEL');
       x_msg_data := 'PA_TP_ASSG_CANT_NTER_PRG_CNCEL';
       x_return_status := 'E';
       RAISE  FND_API.G_EXC_ERROR;
    END IF;
    ---- if status is CANCELLED

    /* Commented by rtarway for BUG 3762650
    ---- if status is ON HOLD
    IF PA_PROGRESS_UTILS.get_system_task_status(PA_PROGRESS_UTILS.get_task_status( p_project_id, p_task_id)) = 'ON HOLD'
    THEN
       PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                            ,p_msg_name       => 'PA_TP_ASSG_CANT_NTER_PRG_ONHOLD');
       x_msg_data := 'PA_TP_ASSG_CANT_NTER_PRG_ONHOLD';
       x_return_status := 'E';
       RAISE  FND_API.G_EXC_ERROR;
    END IF;
    ---- if status is ON HOLD
    */
     --bug no. 3586648  start
    SELECT structure_sharing_code
    INTO l_structure_sharing_code
    FROM pa_projects_all
    WHERE project_id = p_project_id;

    --- check if structure is shared and actuals are passed
    /*l_structure_shared := PA_PROJECT_STRUCTURE_UTILS.Check_Sharing_Enabled(p_project_id);
    IF l_structure_shared = 'Y'
    THEN
     IF (p_actual_cost_this_period <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND p_actual_cost_this_period >0)
        OR (p_actual_effort_this_period <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND p_actual_effort_this_period >0)
     THEN
            PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                        ,p_msg_name       => 'PA_TP_CANT_NTER_ACT_SHR_STR');
            x_msg_data := 'PA_TP_CANT_NTER_ACT_SHR_STR';
            x_return_status := 'E';
            RAISE  FND_API.G_EXC_ERROR;
     END IF;
    END IF;*/
    --- check if structure is shared and actuals are passed
    --bug no. 3586648  end
    --added by rtarway for 3816022
    IF (p_calling_module = 'AMG' AND l_structure_sharing_code = 'SHARE_FULL')
    THEN
          IF (l_actual_effort IS NOT NULL AND l_actual_effort >0)
          OR (l_actual_raw_cost IS NOT NULL AND l_actual_raw_cost >0)
          THEN

            PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                        ,p_msg_name       => 'PA_TP_CANT_NTER_ACT_SHR_STR');
            x_msg_data := 'PA_TP_CANT_NTER_ACT_SHR_STR';
            x_return_status := 'E';
            RAISE  FND_API.G_EXC_ERROR;
          END IF;
    END IF;
    --end added by rtarway for 3816022

    ----- Wrong MODE
    IF p_progress_mode not in ( 'FUTURE' )
    THEN
        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                             ,p_msg_name       => 'PA_TP_WRONG_PRG_MODE4');
        x_msg_data := 'PA_TP_WRONG_PRG_MODE4';
        x_return_status := 'E';
        RAISE  FND_API.G_EXC_ERROR;
    END IF;
    ----- Wrong MODE

    ----- Invalid DATE
    IF p_as_of_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR p_as_of_date IS NULL
    THEN
        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                             ,p_msg_name       => 'PA_TP_INV_AOD');
       x_msg_data := 'PA_TP_INV_AOD';
       x_return_status := 'E';
       RAISE  FND_API.G_EXC_ERROR;
    END IF;
    ----- Wrong DATE


    -- Bug 3979303 : Commentee code here and moved it below with some modification
    /*
    IF p_estimated_finish_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE AND p_estimated_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    THEN
        IF (p_estimated_finish_date  < p_estimated_start_date)
     THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            pa_utils.add_message(p_app_short_name => 'PA',
                                  p_msg_name => 'PA_EST_DATES_INV');
            raise fnd_api.g_exc_error;
     END IF;
    END IF;
    */

  --bug 4185364, start
  -- if action is SAVE then delete al the present and future working records.
  --there shud be only one working record.
    if  p_action = 'SAVE'
    THEN
       delete from pa_percent_completes
       where project_id= p_project_id
         and object_id = p_object_id
         and published_flag = 'N'
         and task_id = p_task_id
         and structure_type = p_structure_type
         ;

       delete from pa_progress_rollup
       where project_id= p_project_id
         and object_id = p_object_id
         and current_flag = 'W'
         and proj_element_id = p_task_id
         and structure_type = p_structure_type
         and structure_version_id is null
         ;
    end if;
  --bug 4185364, end


  --bug 3879461
    --This code is required is PUBLISH mode  to delete working progress records on previous dates.
    if  p_action = 'PUBLISH' and p_structure_type = 'WORKPLAN'
    then
       delete from pa_percent_completes
       where project_id= p_project_id
         and object_id = p_object_id
         and published_flag = 'N'
         and date_computed <= p_as_of_date      --bug 4247839, modified so that two records are not created for same as of date
         and task_id = p_task_id
         and structure_type = p_structure_type
         ;

       delete from pa_progress_rollup
       where project_id= p_project_id
         and object_id = p_object_id
         and current_flag = 'W'
         and as_of_date < p_as_of_date
         and proj_element_id = p_task_id
         and structure_type = p_structure_type
         and structure_version_id is null
         ;
    end if;
  --bug 3879461


    -- Bug 3606627 Start
    IF p_calling_module = 'AMG' THEN
     BEGIN
         /* COMMENTING for performance issues
          SELECT rate_based_flag, resource_class_code, txn_currency_code,
               rbs_element_id, resource_list_member_id, assignment_start_date, assignment_end_date -- Bug 3956299 : Added assignment_end_date
          INTO l_rate_based_flag, l_resource_class_code, l_txn_currency_code,
               l_rbs_element_id, l_resource_list_member_id, l_scheduled_start_date, l_scheduled_finish_date -- Bug 3956299 : Added l_scheduled_finish_date
          FROM pa_task_assignments_v
          WHERE --resource_assignment_id = l_assignment_id Bug 3799841
	  resource_list_member_id = l_resource_list_member_id -- Bug 3799841
          AND structure_version_id = p_structure_version_id
          AND task_version_id = l_object_version_id;
         */

          SELECT rate_based_flag,
                 resource_class_code,
                 PA_TASK_ASSIGNMENT_UTILS.get_planned_currency_info(pra.resource_assignment_id, pra.project_id, 'txn_currency_code') as txn_currency_code,
                 rbs_element_id,
                 resource_list_member_id,
                 schedule_start_date,
                 schedule_end_date,
		 pra.resource_assignment_id -- Bug 4186007 : Derive res_assignment_id from AMG, it can be null
            INTO l_rate_based_flag, l_resource_class_code, l_txn_currency_code,
                 l_rbs_element_id, l_resource_list_member_id, l_scheduled_start_date,
                 l_scheduled_finish_date,
		 l_assignment_id -- Bug 4186007 : Derive res_assignment_id from AMG, it can be null
            FROM pa_resource_assignments pra,
                 PA_PROJ_ELEMENT_VERSIONS PPEV
           where resource_list_member_id = l_resource_list_member_id
             AND PPEV.PROJECT_ID = p_project_id
             AND PPEV.PARENT_STRUCTURE_VERSION_ID = p_structure_version_id
             AND pra.TASK_ID = PPEV.PROJ_ELEMENT_ID
             AND pra.wbs_element_version_id = ppev.element_version_id
             --Added following conditions bug4110593, rtarway
             AND pra.task_id = p_task_id
             AND pra.wbs_element_version_id = p_object_version_id;
     EXCEPTION
          WHEN NO_DATA_FOUND THEN
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_TP_INV_ASSGN_AMG',
                     P_TOKEN1         => 'OBJECT_ID',
                     P_VALUE1         => l_resource_list_member_id);
               x_msg_data := 'PA_TP_INV_ASSGN_AMG';
               x_return_status := FND_API.G_RET_STS_ERROR;
               RAISE  FND_API.G_EXC_ERROR;
     END;


    /* Begin: Fix for Bug # 3988457. */

    /* Currently the value of p_txn_currency_code is not passed to this API in the AMG flow.
       However, the following code will handle the case if the AMG flow is later modified to
       pass the value of p_txn_currency_code to this API. */

    IF (p_txn_currency_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND

    	p_txn_currency_code IS NOT NULL)

    THEN

    	l_txn_currency_code := p_txn_currency_code;

    END IF;

    /* End: Fix for Bug # 3988457. */

    END IF;

    -- Bug 3979303 : Begin
    IF l_estimated_finish_date is not null and l_estimated_start_date IS NULL THEN
	l_estimated_start_date := l_scheduled_start_date;
    END IF;

    IF l_estimated_finish_date is not null and l_estimated_finish_date < nvl(l_estimated_start_date,l_estimated_finish_date+1) THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
	pa_utils.add_message(p_app_short_name => 'PA',
                               p_msg_name => 'PA_EST_DATES_INV');
	raise fnd_api.g_exc_error;
    END IF;
    -- Bug 3979303 : End


    IF p_actual_start_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    THEN
        IF l_actual_raw_cost_this_period > 0 OR l_actual_effort_this_period > 0
     THEN
         l_actual_start_date := l_scheduled_start_date;
     ELSE
            l_actual_start_date  := null;
     END IF;
    ELSE
        l_actual_start_date  := p_actual_start_date;
    END IF;

    -- FPM Dev CR 3 : Added Logic to get total cost from last submission and this period.
    --bug# 3764224 Changes for RLM
    --OPEN cur_task_cost(p_project_id, l_assignment_id, p_structure_type, l_resource_class_code, p_as_of_date);

    -- if structure is shared then we need to get last actuals <= to as_of_date
    if (l_structure_sharing_code = 'SHARE_FULL' OR p_calling_module = 'AMG' or p_calling_module = 'HIDDEN_ASGMT') then -- Bug 5294838:Added AMG check; 5441402:added HIDDEN_ASGMT
       OPEN cur_task_cost_shared(p_project_id, l_resource_list_member_id, p_structure_type, l_resource_class_code, p_as_of_date);
       FETCH cur_task_cost_shared INTO l_act_raw_cost_last_subm_tc, l_act_raw_cost_last_subm_pc, l_act_raw_cost_last_subm_fc,l_act_bur_cost_last_subm_tc, l_act_bur_cost_last_subm_pc, l_act_bur_cost_last_subm_fc, l_act_effort_last_subm;
       CLOSE cur_task_cost_shared;
    else
       OPEN cur_task_cost(p_project_id, l_resource_list_member_id, p_structure_type, l_resource_class_code, p_as_of_date);
       FETCH cur_task_cost INTO l_act_raw_cost_last_subm_tc, l_act_raw_cost_last_subm_pc, l_act_raw_cost_last_subm_fc,l_act_bur_cost_last_subm_tc, l_act_bur_cost_last_subm_pc, l_act_bur_cost_last_subm_fc, l_act_effort_last_subm;
       CLOSE cur_task_cost;
    end if;

    OPEN cur_task_cost_latest(p_project_id, l_resource_list_member_id, p_structure_type, l_resource_class_code, p_as_of_date);
    FETCH cur_task_cost_latest INTO l_act_raw_cost_latest_subm_tc, l_act_raw_cost_latest_subm_pc, l_act_raw_cost_latest_subm_fc,l_act_bur_cost_latest_subm_tc, l_act_bur_cost_latest_subm_pc, l_act_bur_cost_latest_subm_fc, l_act_effort_latest_subm;
    if cur_task_cost_latest%notfound then
       subm_prog_exists_aod := 'N';
    else
       subm_prog_exists_aod := 'Y';
    end if;
    CLOSE cur_task_cost_latest;


    IF p_calling_module = 'AMG' THEN
     -- If called from AMG then l_Actual_cost and l_actual_effort will behave as to_date cost and not as last_submitted
     -- So we need to derive this_period cost or effort
     -- Bug 5294838 : Commented the fix of 4541353, Added new
/*
     -- Begin Bug # 4541353.
     -- Need to set the values of: l_actual_raw_cost and l_actual_effort before calculating: l_actual_raw_cost_this_period
     -- and l_actual_effort_this_period.
     l_actual_raw_cost := nvl(l_act_raw_cost_last_subm_tc,0);
     l_actual_effort := nvl(l_act_effort_last_subm,0);
     -- End Bug # 4541353.
*/
     -- rbruno commented for bug 9545413  - start
     -- commenting this because l_actual_effort_this_period is already calculated and sent to this api
     -- from  PA_PROGRESS_PUB.UPDATE_TASK_PROGRESS api
     /*


     l_actual_raw_cost_this_period := nvl(l_actual_raw_cost,0) - nvl(l_act_raw_cost_last_subm_tc,0);
     l_actual_effort_this_period := nvl(l_actual_effort,0) - nvl(l_act_effort_last_subm,0);

     l_actual_raw_cost := nvl(l_act_raw_cost_last_subm_tc,0);
     l_actual_effort := nvl(l_act_effort_last_subm,0);
     */
      -- rbruno commented for bug 9545413 - end


     -- Bug 5294838 : Added code below
     if (l_structure_sharing_code = 'SHARE_FULL') then
          l_actual_raw_cost_this_period := 0;
          l_actual_effort_this_period := 0;
     end if;

    END IF;


--    l_res_list_memb_id_tbl.extend(1);
--    l_res_list_memb_id_tbl(1)         := l_resource_list_member_id;

    -- Bug 3606627 End

	-- 4533112 Begin

	IF g1_debug_mode  = 'Y' THEN
		pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'Client Extension Logic Starts', x_Log_Level=> 3);
	END IF;

	OPEN c_get_dates_overrides(p_project_id,l_resource_list_member_id,'PA_ASSIGNMENTS',p_as_of_date);
	FETCH c_get_dates_overrides INTO
	l_db_date_override_flag
	, l_db_estimated_start_date
	, l_db_estimated_finish_date
	, l_db_actual_start_date
	, l_db_actual_finish_date
	, l_task_status_code;
	CLOSE c_get_dates_overrides;

	IF g1_debug_mode  = 'Y' THEN
		pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_db_date_override_flag='||l_db_date_override_flag, x_Log_Level=> 3);
		pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_db_estimated_start_date='||l_db_estimated_start_date, x_Log_Level=> 3);
		pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_db_estimated_finish_date='||l_db_estimated_finish_date, x_Log_Level=> 3);
		pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_db_actual_start_date='||l_db_actual_start_date, x_Log_Level=> 3);
		pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_db_actual_finish_date='||l_db_actual_finish_date, x_Log_Level=> 3);
		pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_task_status_code='||l_task_status_code, x_Log_Level=> 3);
		pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'Calling PA_PROGRESS_CLIENT_EXTN.GET_TASK_RES_OVERRIDE_INFO with following params', x_Log_Level=> 3);
		pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'p_project_id='||p_project_id, x_Log_Level=> 3);
		pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'p_structure_version_id='||p_structure_version_id, x_Log_Level=> 3);
		pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_object_type='||l_object_type, x_Log_Level=> 3);
		pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_object_version_id='||l_object_version_id, x_Log_Level=> 3);
		pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_resource_list_member_id='||l_resource_list_member_id, x_Log_Level=> 3);
		pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'p_task_id='||p_task_id, x_Log_Level=> 3);
		pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_estimated_start_date='||l_estimated_start_date, x_Log_Level=> 3);
		pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_estimated_finish_date='||l_estimated_finish_date, x_Log_Level=> 3);
		pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_actual_start_date='||l_actual_start_date, x_Log_Level=> 3);
		pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_actual_finish_date='||l_actual_finish_date, x_Log_Level=> 3);
	END IF;


	l_date_override_flag := 'N';

	PA_PROGRESS_CLIENT_EXTN.GET_TASK_RES_OVERRIDE_INFO(
		p_project_id		=> p_project_id,
		p_structure_type        => 'WORKPLAN',
		p_structure_version_id	=> p_structure_version_id,
		p_object_type		=> l_object_type,
		p_object_id		=> l_resource_list_member_id,
		p_object_version_id     => l_object_version_id,
		p_proj_element_id	=> p_task_id,
		p_task_status		=> l_task_status_code,
		p_percent_complete	=> null,
		p_estimated_start_date	=> l_estimated_start_date,
		p_estimated_finish_date	=> l_estimated_finish_date,
		p_actual_start_date	=> l_actual_start_date,
		p_actual_finish_date	=> l_actual_finish_date,
		x_estimated_start_date	=> l_clex_estimated_start_date,
		x_estimated_finish_date	=> l_clex_estimated_finish_date,
		x_actual_start_date	=> l_clex_actual_start_date,
		x_actual_finish_date	=> l_clex_actual_finish_date,
		x_return_status		=> x_return_status,
		x_msg_count		=> x_msg_count,
		x_msg_data		=> x_msg_data
		);

	IF g1_debug_mode  = 'Y' THEN
		pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'After Call PA_PROGRESS_CLIENT_EXTN.GET_TASK_RES_OVERRIDE_INFO x_return_status='||x_return_status, x_Log_Level=> 3);
		pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_clex_estimated_start_date='||l_clex_estimated_start_date, x_Log_Level=> 3);
		pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_clex_estimated_finish_date='||l_clex_estimated_finish_date, x_Log_Level=> 3);
		pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_clex_actual_start_date='||l_clex_actual_start_date, x_Log_Level=> 3);
		pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_clex_actual_finish_date='||l_clex_actual_finish_date, x_Log_Level=> 3);
	END IF;

	IF x_return_status <> 'S' THEN
		raise FND_API.G_EXC_ERROR;
	END IF;

	IF nvl(l_estimated_start_date,FND_API.g_miss_date) <> nvl(l_clex_estimated_start_date,FND_API.g_miss_date)
	OR nvl(l_estimated_finish_date,FND_API.g_miss_date) <> nvl(l_clex_estimated_finish_date,FND_API.g_miss_date)
	OR nvl(l_actual_start_date,FND_API.g_miss_date) <> nvl(l_clex_actual_start_date,FND_API.g_miss_date)
	OR nvl(l_actual_finish_date,FND_API.g_miss_date) <> nvl(l_clex_actual_finish_date,FND_API.g_miss_date)
	THEN
		l_date_override_flag := 'Y';
		l_estimated_start_date := l_clex_estimated_start_date;
		l_estimated_finish_date := l_clex_estimated_finish_date;
		l_actual_start_date := l_clex_actual_start_date;
		l_actual_finish_date := l_clex_actual_finish_date;
	END IF;

	IF l_date_override_flag = 'N' AND nvl(l_db_date_override_flag, 'N') = 'Y' THEN
		l_date_override_flag := 'Y';
	END IF;

	IF l_date_override_flag = 'N' AND
	(nvl(l_estimated_start_date,FND_API.g_miss_date) <> nvl(l_db_estimated_start_date,FND_API.g_miss_date)
	OR nvl(l_estimated_finish_date,FND_API.g_miss_date) <> nvl(l_db_estimated_finish_date,FND_API.g_miss_date)
	OR nvl(l_actual_start_date,FND_API.g_miss_date) <> nvl(l_db_actual_start_date,FND_API.g_miss_date)
	OR nvl(l_actual_finish_date,FND_API.g_miss_date) <> nvl(l_db_actual_finish_date,FND_API.g_miss_date))
	THEN
		l_date_override_flag := 'Y';
	END IF;

	IF l_etc_effort_this_period  IS NOT NULL AND l_etc_effort_this_period > 0    THEN
		l_actual_finish_date := null;
	END IF;

	IF g1_debug_mode  = 'Y' THEN
		pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_date_override_flag='||l_date_override_flag, x_Log_Level=> 3);
		pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_estimated_start_date='||l_estimated_start_date, x_Log_Level=> 3);
		pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_estimated_finish_date='||l_estimated_finish_date, x_Log_Level=> 3);
		pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_actual_start_date='||l_actual_start_date, x_Log_Level=> 3);
		pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_actual_finish_date='||l_actual_finish_date, x_Log_Level=> 3);
	END IF;

	-- 4533112 End



    IF l_actual_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE AND l_actual_finish_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    THEN
        IF l_actual_finish_date < l_actual_start_date
        THEN
            IF TRUNC(SYSDATE) < l_actual_start_date
            THEN
                l_actual_finish_date := l_actual_start_date;
            ELSE
                l_actual_finish_date := TRUNC(SYSDATE);
            END IF;
        END IF;
    END IF;


    l_last_progress_date := PA_PROGRESS_UTILS.GET_LATEST_AS_OF_DATE(
                         p_task_id        => p_task_id
                        ,p_project_id     => p_project_id
                        --,p_object_id      => l_assignment_id        --bug# 3764224 Changes for RLM
                        ,p_object_id      => l_resource_list_member_id
                        ,p_object_type    => l_object_type
                        ,p_structure_type => p_structure_type
                   );


    IF g1_debug_mode  = 'Y' THEN
       pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_last_progress_date: '||l_last_progress_date, x_Log_Level=> 3);
    END IF;

    l_working_aod := PA_PROGRESS_UTILS.Working_version_exist(
                                      --p_task_id          => l_assignment_id     --bug# 3764224 Changes for RLM
                                      p_task_id          => p_task_id
                                     ,p_project_id       => p_project_id
                                     ,p_object_type      => l_object_type
				     ,p_object_id        => l_resource_list_member_id --bug# 3764224 Added for RLM
				     ,p_as_of_date       => p_as_of_date);  --bug 4185364, get working record upto p_as_of_date
				                                           -- as we dont want to update future working records.

    IF g1_debug_mode  = 'Y' THEN
       pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_working_aod: '||l_working_aod, x_Log_Level=> 3);
    END IF;


    l_progress_exists_on_aod := PA_PROGRESS_UTILS.check_prog_exists_on_aod(
                                      p_project_id         => p_project_id
                                     ,p_object_type        => l_object_type
                                     ,p_object_version_id  => l_object_version_id
                                     --,p_task_id            => l_assignment_id     --bug# 3764224 Changes for RLM
                                     ,p_task_id            => p_task_id
                                     ,p_as_of_date         => p_as_of_date
				     ,p_structure_type      => p_structure_type
				     ,p_object_id           => l_resource_list_member_id  --bug# 3764224 Added for RLM
                                    );

    IF g1_debug_mode  = 'Y' THEN
       pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_progress_exists_on_aod: '||l_progress_exists_on_aod, x_Log_Level=> 3);
    END IF;


    IF p_as_of_date < NVL( l_last_progress_date, p_as_of_date )
    --AND l_working_aod IS NULL  -- progress exists after  as of date -- commented as not needed  Satish
    THEN
        --You cannot create a future progress when there exists a progress
        --after AS_OF_DATE for this task.
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => 'PA_TP_ASSG_WRONG_PRG_MODE3',
                             p_token1         => 'AS_OF_DATE',
                             p_value1         => p_as_of_date );
        x_msg_data := 'PA_TP_ASSG_WRONG_PRG_MODE3';
        x_return_status := 'E';
        RAISE  FND_API.G_EXC_ERROR;
    --bug# 3821106 Satish start,  bug 4185364
    /*ELSIF (p_as_of_date = NVL(l_last_progress_date, p_as_of_date + 1 ) AND  p_action = 'SAVE')
    THEN
       if (l_working_aod = p_as_of_date) then
          l_db_action := 'UPDATE';
       else
          l_db_action := 'CREATE';
       end if;
    ELSIF (p_as_of_date = NVL(l_last_progress_date, p_as_of_date + 1 ) AND  p_action = 'PUBLISH')
    THEN
          l_db_action := 'CREATE';*/
   /* commenting out as now we will allow to create a working rec if published record exists on that as_of_date
        --You cannot save progress when there exists a published progress
        --for this as of date.
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => 'PA_TP_ASSG_WRONG_ACTION',
                             p_token1         => 'AS_OF_DATE',
                             p_value1         => p_as_of_date );
        x_msg_data := 'PA_TP_ASSG_WRONG_ACTION';
        x_return_status := 'E';
        RAISE  FND_API.G_EXC_ERROR;
    --bug# 3821106 Satish end
   */
    ELSE
       --Validate as of date
          -- Bug 3627315 : Check valid as of date should not be called from AMG or Task Progress Details page
	  -- Beacuse from both the places we submit progress for all objects against one cycle date

       --bug 3994165, commmenting as as of date validation is not required
       /*IF p_calling_module <> 'AMG' -- Bug 3627315
       AND p_calling_module <> 'TASK_PROG_DET_PAGE' -- Bug 3627315
       --bug# 3764224 Added for RLM
       --AND PA_PROGRESS_UTILS.CHECK_VALID_AS_OF_DATE( p_as_of_date, p_project_id, l_assignment_id, l_object_type  ) = 'N'
       AND PA_PROGRESS_UTILS.CHECK_VALID_AS_OF_DATE( p_as_of_date, p_project_id, l_resource_list_member_id, l_object_type, p_task_id  ) = 'N'
       AND nvl(l_last_progress_date,p_as_of_date + 1 ) <> p_as_of_date
       THEN
           --Add message
        --Invalid as of date
        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                                ,p_msg_name       => 'PA_TP_INV_AOD2');
           x_msg_data := 'PA_TP_INV_AOD2';
           x_return_status := 'E';
           RAISE  FND_API.G_EXC_ERROR;
       END IF;*/

       IF l_progress_exists_on_aod = 'WORKING'
       THEN
           --update the existing working progress record
           l_db_action := 'UPDATE';
      --This code is modified for Correction flow bug no.3595585. Satish
      --In ppc for correction flow record should be inserted. bug no. 3595585 Satish
       ELSIF l_progress_exists_on_aod = 'PUBLISHED'
       THEN
            --bug 4185364, if correcting published record it should be update as we dont want to maintain history of corrected records
	    --and if action is save then create a new record
            IF p_action = 'PUBLISH' THEN
		l_db_action := 'UPDATE';
	    ELSE
		l_db_action := 'CREATE';
	    END IF;
       ELSIF l_progress_exists_on_aod = 'N'
       THEN
            --Create a new working progress record.
            l_db_action := 'CREATE';
         --there is only one working version allowed hence update that record only if it exists
            --IF  l_working_aod IS NOT NULL ,  now this case will never come
            IF  l_working_aod IS NOT NULL
            THEN
                l_db_action := 'UPDATE';
            END IF;
        END IF;
    END IF;

    IF g1_debug_mode  = 'Y' THEN
       pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_db_action: '||l_db_action, x_Log_Level=> 3);
    END IF;

    IF ( p_action = 'PUBLISH')
    THEN
        l_published_flag        := 'Y';
        l_current_flag          := 'Y';
        l_rollup_current_flag := 'Y'; -- Bug 3879461

        UPDATE pa_percent_completes
        SET current_flag = 'N'
        WHERE project_id = p_project_id
        --AND object_id = l_assignment_id  --bug# 3764224 Changes for RLM
        AND object_id = l_resource_list_member_id
        AND task_id = l_task_id    --maansari7/21 bug# 3764224 Changes for RLM
        AND current_flag = 'Y'
        AND object_type = l_object_type;

        UPDATE pa_progress_rollup
        SET current_flag = 'N'
        WHERE project_id = p_project_id
        --AND object_id = l_assignment_id --bug# 3764224 Changes for RLM
        AND object_id = l_resource_list_member_id
        AND proj_element_id = l_task_id    --maansari7/21 bug# 3764224 Changes for RLM
        AND current_flag = 'Y'
        AND object_type = l_object_type
	AND structure_version_id is null -- Bug 3846353 : *** AMKSINGH  08/24/04 09:53 am ***  Issue F - 2
	;
        -- Bug 3879461 Begin
-----	IF l_db_action = 'UPDATE' THEN
		/*
		-- Delete the published progress record on the same as of date
		DELETE FROM pa_progress_rollup
		where project_id = p_project_id
		and object_id = l_resource_list_member_id
		and proj_element_id = l_task_id
		and object_type = l_object_type
		and structure_version_id is null
		and structure_type = 'WORKPLAN'
		and current_flag = 'Y'
		and trunc(as_of_date) = trunc(p_as_of_date)
		and exists(select 1
				from pa_progress_rollup
				where project_id = p_project_id
				and object_id = l_resource_list_member_id
				and proj_element_id = l_task_id
				and object_type = l_object_type
				and structure_version_id is null
				and structure_type = 'WORKPLAN'
				and current_flag = 'W'
				and trunc(as_of_date) = trunc(p_as_of_date)
		  	   );
		-- Update the  working progress record on the same as of date as published progress
		-- so that while updating rollup record its values can be considered
		-- Basically this is done so get_prog_rollup_id can return this row for update mode

		Update pa_progress_rollup
		set current_flag = 'Y'
		where project_id = p_project_id
		and object_id = l_resource_list_member_id
		and proj_element_id = l_task_id
		and object_type = l_object_type
		and structure_version_id is null
		and structure_type = 'WORKPLAN'
		and current_flag = 'W'
		and trunc(as_of_date) = trunc(p_as_of_date);
		*/
                --- while PUBLISH we delete all working rec <= to as_of_date
		Delete from pa_progress_rollup
		where project_id = p_project_id
		and object_id = l_resource_list_member_id
		and proj_element_id = l_task_id
		and object_type = l_object_type
		and structure_version_id is null
		and structure_type = 'WORKPLAN'
		and current_flag = 'W'
		and trunc(as_of_date) <= trunc(p_as_of_date);
------	END IF;
        -- Bug 3879461 End
    ELSE
        l_published_flag := 'N';
        l_current_flag := 'N';
        l_rollup_current_flag := 'W'; -- Bug 3879461
    END IF;


    --bug 3824042, round effort upto 2 deciaml places, start
    IF l_rate_based_flag = 'Y'
    THEN
	    l_actual_effort_this_period := round(l_actual_effort_this_period, 5);
	    l_etc_effort_this_period    := round(l_etc_effort_this_period, 5);
    ELSE
	    l_actual_effort_this_period := pa_currency.round_trans_currency_amt(l_actual_effort_this_period, l_txn_currency_code);
	    l_etc_effort_this_period    := pa_currency.round_trans_currency_amt(l_etc_effort_this_period, l_txn_currency_code);
    END IF;
    --bug 3824042, round effort upto 2 deciaml places, end

     --BUG3630743 (Get all planned values)
    -- Bug 3696572 : Wrongly l_project_id was passed to below cursor instead of p_project_id
    ---4372462 (moved this code here from below)
    OPEN c_get_planned_values (l_resource_list_member_id , l_assignment_id, p_project_id ) ;
    FETCH c_get_planned_values INTO
          l_planned_quantity ,
          l_planned_bur_cost_txn_cur,
          l_planned_bur_cost_projfunc,
          l_planned_bur_cost_proj_cur,
          l_planned_raw_cost_txn_cur,
          l_planned_raw_cost_proj_cur,
          l_planned_raw_cost_projfunc,
          l_budget_version_id ;
    CLOSE c_get_planned_values;
    --BUG3630743


-- Raw Cost Changes Begin
-- IF l_actual_effort_this_period IS NOT NULL   bug 3784733  need to call this api even for non-rate based  assgns to get the burden multiplier.
-- THEN

     IF NVL(l_track_wp_cost_flag, 'Y') = 'Y' THEN -- Bug 3801745
       --bug 4334545
       if (l_actual_effort_this_period is not null AND (l_actual_effort_this_period <> 0 or l_actual_raw_cost_this_period <> 0)) then
       BEGIN
       IF g1_debug_mode  = 'Y' THEN
          pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'Calling Get_Res_txn_Cost_Rate', x_Log_Level=> 3);
       END IF;
       PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier(
            P_res_list_mem_id             => l_resource_list_member_id
           ,P_project_id                  => p_project_id
           ,P_task_id                  => p_task_id      --bug 3860575
           ,p_as_of_date               => p_as_of_date   --bug 3901289
           --maansari6/14 3686920
           ,p_structure_version_id        => p_structure_version_id
           ,p_currency_code               => l_txn_currency_code
           --maansari6/14 3686920
	   ,p_calling_mode                => 'ACTUAL_RATES'
           ,x_resource_curr_code          => l_res_cur_code
           ,x_resource_raw_rate           => l_res_raw_rate
           ,x_resource_burden_rate        => l_res_burden_rate
           ,X_burden_multiplier           => l_burden_multiplier
           ,x_return_status               => l_return_status
           ,x_msg_count                   => l_msg_count
           ,x_msg_data                    => l_msg_data
          );

       IF g1_debug_mode  = 'Y' THEN
            pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => ' Before conversion l_res_raw_rate'||l_res_raw_rate, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'Before conversion l_res_burden_rate'||l_res_burden_rate, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'Before conversion l_res_cur_code'||l_res_cur_code, x_Log_Level=> 3);
       END IF;


      EXCEPTION
           WHEN OTHERS THEN
                fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_ASSIGNMENT_PROGRESS_PUB',
                            p_procedure_name =>        'UPDATE_ASSIGNMENT_PROGRESS',
                            p_error_text     => SUBSTRB('PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier1:'||SQLERRM,1,240));
                RAISE FND_API.G_EXC_ERROR;

      END;

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_return_status := 'E';
          x_msg_data      := l_msg_data;
          x_msg_count     := l_msg_count;
          RAISE  FND_API.G_EXC_ERROR;
      END IF;

    -- Bug 3696429 currency conversion for resource  Satish 03-JUL-2004 start
    IF l_txn_currency_code <> l_res_cur_code
    THEN
        PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS(
             p_project_id               => p_project_id
            ,p_task_id                  => p_task_id
            --,p_as_of_date               => SYSDATE
            ,p_as_of_date               => p_as_of_date     --bug 3901289
            ,p_txn_cost                 => l_res_raw_rate
            ,p_txn_curr_code            => l_res_cur_code
            ,p_project_curr_code        => l_txn_currency_code
            ,p_project_rate_type        => l_project_rate_type
            ,p_project_rate_date        => l_project_rate_date
            ,p_project_exch_rate        => l_project_exch_rate
            ,p_project_raw_cost         => l_proj_res_raw_rate
            --,p_projfunc_curr_code       => l_txn_currency_code
            ,p_projfunc_curr_code       => l_projfunc_curr_code --BUG 4354031
            ,p_projfunc_cost_rate_type  => l_projfunc_cost_rate_type
            ,p_projfunc_cost_rate_date  => l_projfunc_cost_rate_date
            ,p_projfunc_cost_exch_rate  => l_projfunc_cost_exch_rate
            ,p_projfunc_raw_cost        => l_projfunc_res_raw_rate
            ,p_structure_version_id     => p_structure_version_id -- 3627787
            ,x_return_status            => l_return_status
            ,x_msg_count                => l_msg_count
            ,x_msg_data                 => l_msg_data
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              x_return_status := 'E';
              x_msg_data      := l_msg_data;
              x_msg_count     := l_msg_count;
              RAISE  FND_API.G_EXC_ERROR;
        END IF;

        IF l_res_raw_rate <> l_res_burden_rate
	THEN
		PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS(
		     p_project_id               => p_project_id
		    ,p_task_id                  => p_task_id
	--	    ,p_as_of_date               => SYSDATE
                    ,p_as_of_date               => p_as_of_date     --bug 3901289
		    ,p_txn_cost                 => l_res_burden_rate
		    ,p_txn_curr_code            => l_res_cur_code
		    ,p_project_curr_code        => l_txn_currency_code
		    ,p_project_rate_type        => l_project_rate_type
		    ,p_project_rate_date        => l_project_rate_date
		    ,p_project_exch_rate        => l_project_exch_rate
		    ,p_project_raw_cost         => l_proj_res_burden_rate
		    --,p_projfunc_curr_code       => l_txn_currency_code
		    ,p_projfunc_curr_code       => l_projfunc_curr_code --BUG 4354031
                    ,p_projfunc_cost_rate_type  => l_projfunc_cost_rate_type
		    ,p_projfunc_cost_rate_date  => l_projfunc_cost_rate_date
		    ,p_projfunc_cost_exch_rate  => l_projfunc_cost_exch_rate
		    ,p_projfunc_raw_cost        => l_projfunc_res_burden_rate
		    ,p_structure_version_id     => p_structure_version_id -- 3627787
		    ,x_return_status            => l_return_status
		    ,x_msg_count                => l_msg_count
		    ,x_msg_data                 => l_msg_data
		);
		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		      x_return_status := 'E';
		      x_msg_data      := l_msg_data;
		      x_msg_count     := l_msg_count;
		      RAISE  FND_API.G_EXC_ERROR;
		END IF;

		l_res_burden_rate := l_proj_res_burden_rate;
	ELSE
		l_res_burden_rate := l_proj_res_raw_rate;
	END IF;
	l_res_raw_rate := l_proj_res_raw_rate;
    END IF; -- IF l_txn_currency_code <> l_res_cur_code

    IF g1_debug_mode  = 'Y' THEN
         pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => ' After conversion l_res_raw_rate'||l_res_raw_rate, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'After conversion l_res_burden_rate'||l_res_burden_rate, x_Log_Level=> 3);
    END IF;

    end if;

--    IF l_etc_effort_this_period IS NOT NULL  --maansari6/14 bug 3784733  need to call this api even for non-rate based  assgns to get the burden multiplier.
   --bug 4334545
    if (l_etc_effort_this_period is not null and (l_etc_effort_this_period <> 0 or l_etc_raw_cost_this_period <> 0)) then
     BEGIN
     PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier(
            P_res_list_mem_id             => l_resource_list_member_id
           ,P_project_id                  => p_project_id
           ,P_task_id                     => p_task_id      --bug 3860575
          ,p_as_of_date               => p_as_of_date   --bug 3901289
           --maansari6/14 3686920
           ,p_structure_version_id        => p_structure_version_id
           ,p_currency_code               => l_txn_currency_code
           --maansari6/14 3686920
	   ,p_calling_mode                => 'PLAN_RATES'
           ,x_resource_curr_code          => l_plan_res_cur_code
           ,x_resource_raw_rate           => l_plan_res_raw_rate
           ,x_resource_burden_rate        => l_plan_res_burden_rate
           ,X_burden_multiplier           => l_plan_burden_multiplier
           ,x_return_status               => l_return_status
           ,x_msg_count                   => l_msg_count
           ,x_msg_data                    => l_msg_data
          );

    IF g1_debug_mode  = 'Y' THEN
         pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'Before conversion l_plan_res_raw_rate'||l_plan_res_raw_rate, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'Before conversion l_plan_res_burden_rate'||l_plan_res_burden_rate, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_plan_res_cur_code'||l_plan_res_cur_code, x_Log_Level=> 3);
    END IF;

    EXCEPTION
           WHEN OTHERS THEN
                fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_ASSIGNMENT_PROGRESS_PUB',
                            p_procedure_name =>        'UPDATE_ASSIGNMENT_PROGRESS',
                            p_error_text     => SUBSTRB('PA_PROGRESS_UTILS.Get_Res_Rate_Burden_Multiplier2:'||SQLERRM,1,240));
                RAISE FND_API.G_EXC_ERROR;

    END;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_return_status := 'E';
          x_msg_data      := l_msg_data;
          x_msg_count     := l_msg_count;
          RAISE  FND_API.G_EXC_ERROR;
    END IF;
    -- Bug 3784874 currency conversion for ETC Start
    --IF l_txn_currency_code <> l_res_cur_code
    IF l_txn_currency_code <> l_plan_res_cur_code -- 06-sep-2004,3860575 Satish
    THEN
        PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS(
             p_project_id               => p_project_id
            ,p_task_id                  => p_task_id
--            ,p_as_of_date               => SYSDATE
            ,p_as_of_date               => p_as_of_date     --bug 3901289
            ,p_txn_cost                 => l_plan_res_raw_rate
            ,p_txn_curr_code            => l_plan_res_cur_code
            ,p_project_curr_code        => l_txn_currency_code
            ,p_project_rate_type        => l_project_rate_type
            ,p_project_rate_date        => l_project_rate_date
            ,p_project_exch_rate        => l_project_exch_rate
            ,p_project_raw_cost         => l_proj_res_raw_rate
            --,p_projfunc_curr_code       => l_txn_currency_code
            ,p_projfunc_curr_code       => l_projfunc_curr_code --BUG 4354031
            ,p_projfunc_cost_rate_type  => l_projfunc_cost_rate_type
            ,p_projfunc_cost_rate_date  => l_projfunc_cost_rate_date
            ,p_projfunc_cost_exch_rate  => l_projfunc_cost_exch_rate
            ,p_projfunc_raw_cost        => l_projfunc_res_raw_rate
            ,p_structure_version_id     => p_structure_version_id
            ,x_return_status            => l_return_status
            ,x_msg_count                => l_msg_count
            ,x_msg_data                 => l_msg_data
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              x_return_status := 'E';
              x_msg_data      := l_msg_data;
              x_msg_count     := l_msg_count;
              RAISE  FND_API.G_EXC_ERROR;
        END IF;

        IF l_plan_res_raw_rate <> l_plan_res_burden_rate
	THEN
		PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS(
		     p_project_id               => p_project_id
		    ,p_task_id                  => p_task_id
--		    ,p_as_of_date               => SYSDATE
            ,p_as_of_date               => p_as_of_date     --bug 3901289
		    ,p_txn_cost                 => l_plan_res_burden_rate
		    ,p_txn_curr_code            => l_plan_res_cur_code
		    ,p_project_curr_code        => l_txn_currency_code
		    ,p_project_rate_type        => l_project_rate_type
		    ,p_project_rate_date        => l_project_rate_date
		    ,p_project_exch_rate        => l_project_exch_rate
		    ,p_project_raw_cost         => l_proj_res_burden_rate
		    --,p_projfunc_curr_code       => l_txn_currency_code
		    ,p_projfunc_curr_code       => l_projfunc_curr_code --BUG 4354031
		    ,p_projfunc_cost_rate_type  => l_projfunc_cost_rate_type
		    ,p_projfunc_cost_rate_date  => l_projfunc_cost_rate_date
		    ,p_projfunc_cost_exch_rate  => l_projfunc_cost_exch_rate
		    ,p_projfunc_raw_cost        => l_projfunc_res_burden_rate
		    ,p_structure_version_id     => p_structure_version_id
		    ,x_return_status            => l_return_status
		    ,x_msg_count                => l_msg_count
		    ,x_msg_data                 => l_msg_data
		);
		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		      x_return_status := 'E';
		      x_msg_data      := l_msg_data;
		      x_msg_count     := l_msg_count;
		      RAISE  FND_API.G_EXC_ERROR;
		END IF;

		l_plan_res_burden_rate := l_proj_res_burden_rate;
	ELSE
		l_plan_res_burden_rate := l_proj_res_raw_rate;
	END IF;
	l_plan_res_raw_rate := l_proj_res_raw_rate;
    END IF; -- l_txn_currency_code <> l_plan_res_cur_code

   END IF;
  END IF;-- NVL(l_track_wp_cost_flag, 'Y') = 'Y' THEN -- Bug 3801745

    IF g1_debug_mode  = 'Y' THEN
         pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => ' After conversion l_plan_res_raw_rate'||l_plan_res_raw_rate, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'After conversion l_plan_res_burden_rate'||l_plan_res_burden_rate, x_Log_Level=> 3);
    END IF;

    -- Bug 3784874 currency conversion for ETC End

/*   l_burden_cost := pa_currency.round_trans_currency_amt(
                                            l_txn_raw_cost * l_burden_multiplier, l_txn_curr_code) +
                                            l_txn_raw_cost ;*/

-- Raw Cost Changes End

    IF l_rate_based_flag = 'Y'    --maansari7/6 bug 3742356
    THEN

      --IF p_actual_cost_this_period = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR p_actual_cost_this_period IS NULL
      --THEN  --maansari4/10
    IF NVL(l_track_wp_cost_flag, 'Y') = 'Y' THEN -- Bug 3801745

     --maansari4/10
     IF l_actual_effort_this_period IS NOT NULL
     THEN
     --maansari4/10
     /* Raw Cost Changes Begin
          l_res_effort_tbl.extend(1);
          l_res_effort_tbl(1) := l_actual_effort_this_period; -- This is incremental

             IF g1_debug_mode  = 'Y' THEN
                  pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'calling effort to cost for actual', x_Log_Level=> 3);
             END IF;

          PA_PROGRESS_UTILS.GET_TXN_COST_FOR_EFFORT(
               p_project_id        => p_project_id
              ,p_res_list_memb_id_tbl     => l_res_list_memb_id_tbl
              ,P_res_effort_tbl           => l_res_effort_tbl
              ,P_res_txn_cost_tbl         => l_res_txn_cost_tbl
              ,x_return_status             => x_return_status
              ,x_msg_count         => x_msg_count
              ,x_msg_data               => x_msg_data
          );
             IF x_return_status <> FND_API.G_RET_STS_SUCCESS -- FPM Dev CR 8
          THEN
                 RAISE  FND_API.G_EXC_ERROR;
             END IF;

          l_act_txn_cost := l_res_txn_cost_tbl(1); -- This is incremental
          */
          l_act_txn_raw_cost := nvl(l_actual_effort_this_period,0) * l_res_raw_rate; -- This is incremental
          l_act_txn_bur_cost := nvl(l_actual_effort_this_period,0) * l_res_burden_rate; -- This is incremental
          -- Raw Cost Changes End
	  --bug 3824042 start
          l_act_txn_raw_cost      := pa_currency.round_trans_currency_amt(l_act_txn_raw_cost, l_txn_currency_code);
          l_act_txn_bur_cost      := pa_currency.round_trans_currency_amt(l_act_txn_bur_cost, l_txn_currency_code);
	  --bug 3824042 end
     ELSE
          --l_act_txn_cost := null; -- This is incremental
          l_act_txn_raw_cost  := null; -- Raw Cost Changes
          l_act_txn_bur_cost := null; -- Raw Cost Changes
     END IF;  --if effort not equal to g_miss_num and not null --maansari4/10
     END IF;-- NVL(l_track_wp_cost_flag, 'Y') = 'Y' THEN -- Bug 3801745

     --bug 3851528
     if p_action = 'PUBLISH'
     then
        --If etc is not passed then it can be taken as not overidden and let summarization do plann - actual.
        IF l_etc_effort_this_period IS NOT NULL OR
           l_etc_raw_cost_this_period IS NOT NULL
        THEN
           UPDATE pa_proj_elements
              SET progress_outdated_flag = 'Y'
            WHERE project_id=p_project_id
             and object_type= 'PA_TASKS'
             and proj_element_id = p_task_id
             and progress_outdated_flag = 'N'
             ;
        END IF;
     end if;

     IF NVL(l_track_wp_cost_flag, 'Y') = 'Y' THEN -- Bug 3801745
     --maansari4/10
     IF l_etc_effort_this_period IS NOT NULL
     THEN
     --maansari4/10
     /* Raw Cost Changes Begin
          l_etc_res_effort_tbl.extend(1);
          l_etc_res_effort_tbl(1) := l_etc_effort_this_period; -- This is cumulative

             IF g1_debug_mode  = 'Y' THEN
                  pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'calling effort to cost for etc', x_Log_Level=> 3);
             END IF;

          PA_PROGRESS_UTILS.GET_TXN_COST_FOR_EFFORT(
               p_project_id        => p_project_id
              ,p_res_list_memb_id_tbl     => l_res_list_memb_id_tbl
              ,P_res_effort_tbl           => l_etc_res_effort_tbl
              ,P_res_txn_cost_tbl         => l_etc_res_txn_cost_tbl
              ,x_return_status             => x_return_status
              ,x_msg_count         => x_msg_count
              ,x_msg_data               => x_msg_data
          );

             IF x_return_status <> FND_API.G_RET_STS_SUCCESS
          THEN
                 RAISE  FND_API.G_EXC_ERROR;
             END IF;
          l_etc_txn_cost := l_etc_res_txn_cost_tbl(1); -- This is cumulative
          */
	  -- Bug 3627315 : Using plan rates instead of actual rates
          l_etc_txn_raw_cost := nvl(l_etc_effort_this_period,0)*l_plan_res_raw_rate; -- This is cumulative
          l_etc_txn_bur_cost := nvl(l_etc_effort_this_period,0)*l_plan_res_burden_rate; -- This is cumulative
          -- Raw Cost Changes End
	  --bug 3824042 start
          l_etc_txn_raw_cost      := pa_currency.round_trans_currency_amt(l_etc_txn_raw_cost, l_txn_currency_code);
          l_etc_txn_bur_cost      := pa_currency.round_trans_currency_amt(l_etc_txn_bur_cost, l_txn_currency_code);
	  --bug 3824042 end
      ELSE
          --l_etc_txn_cost := null; -- This is cumulative
          l_etc_txn_raw_cost := null; -- Raw Cost Changes
          l_etc_txn_bur_cost := null; -- Raw Cost Changes
      END IF;    --if etc effort not equal to g_miss_num and not null --maansari4/10
      End IF;-- NVL(l_track_wp_cost_flag, 'Y') = 'Y' THEN -- Bug 3801745

     --maansari4/10
      --ELSE
      --    l_act_txn_cost := p_actual_cost_this_period; -- This is incremental
      --    l_etc_txn_cost := p_etc_cost_this_period; -- This is cumulative
      --END IF;
     --maansari4/10


       IF g1_debug_mode  = 'Y' THEN
            pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_etc_txn_raw_cost'||l_etc_txn_raw_cost, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_etc_txn_bur_cost'||l_etc_txn_bur_cost, x_Log_Level=> 3);
       END IF;

    ELSIF  l_rate_based_flag = 'N' --maansari7/6 bug 3742356
    THEN
      IF NVL(l_track_wp_cost_flag, 'Y') = 'Y' THEN -- Bug 3801745
     --Bug 3606627 : Used l_ varable instead of p_

    -- Bug 3801745 Begin : Commented below code and added new
--     l_act_txn_raw_cost := l_actual_raw_cost_this_period; -- This is incremental.
--     l_etc_txn_raw_cost := l_etc_raw_cost_this_period; -- This is cumulative.
--     l_actual_effort_this_period := null; -- This is incremental
--     l_etc_effort_this_period := null; -- This is cumulative
    -- Raw Cost Changes Begin
     l_act_txn_raw_cost := l_actual_effort_this_period;
     l_etc_txn_raw_cost := l_etc_effort_this_period;
    -- Bug 3801745 End

    l_act_txn_bur_cost := nvl( pa_currency.round_trans_currency_amt(
                                            l_act_txn_raw_cost * l_burden_multiplier, l_txn_currency_code),0) +
                                            l_act_txn_raw_cost ;
    -- Bug 3627315 : Using plan burden multiplier instead of actual
    l_etc_txn_bur_cost := nvl( pa_currency.round_trans_currency_amt(
                                            l_etc_txn_raw_cost * l_plan_burden_multiplier, l_txn_currency_code),0) +
                                            l_etc_txn_raw_cost ;
    End IF;-- NVL(l_track_wp_cost_flag, 'Y') = 'Y' THEN -- Bug 3801745
    -- Raw Cost Changes End

    END IF;

    --bug no. 3586648
    -- IF ((l_etc_txn_raw_cost = 0 OR l_etc_txn_raw_cost = null) AND l_actual_finish_date = null) Bug 3801745
--    IF ((l_etc_effort_this_period = 0 OR l_etc_effort_this_period = null) AND l_actual_finish_date = null) Bug 3956299
   --bug 4341100, moved this code below after defaulting etc as planned - actual
   /*IF ((l_etc_effort_this_period = 0 OR l_etc_effort_this_period is null) AND l_actual_finish_date is null) -- Bug 3956299
    THEN
        -- Bug 3956299 : We can default actual finish date in this case from scheduled_finish_date
	l_actual_finish_date := l_scheduled_finish_date;
	IF l_actual_finish_date is null THEN
		--You have to pass actual finish date if etc is 0
		PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
				     ,p_msg_name       => 'PA_TP_ASSG_NTER_FIN_DATE');
	       x_msg_data := 'PA_TP_ASSG_NTER_FIN_DATE';
	       x_return_status := 'E';
	       RAISE  FND_API.G_EXC_ERROR;
	END IF;
    END IF;*/
    --bug no. 3586648

   IF NVL(l_track_wp_cost_flag, 'Y') = 'Y' THEN -- Bug 3801745

   IF l_act_txn_raw_cost IS NOT NULL AND l_act_txn_raw_cost <> 0 THEN
    PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS(
          p_project_id             => p_project_id
               ,p_task_id               => p_task_id
--            ,p_as_of_date               => SYSDATE
            ,p_as_of_date               => p_as_of_date     --bug 3901289
            ,p_txn_cost            => l_act_txn_raw_cost
            ,p_txn_curr_code            => l_txn_currency_code
            ,p_project_curr_code        => l_project_curr_code
            ,p_project_rate_type        => l_project_rate_type
            ,p_project_rate_date        => l_project_rate_date
            ,p_project_exch_rate        => l_project_exch_rate
            ,p_project_raw_cost         => l_act_project_raw_cost
            ,p_projfunc_curr_code       => l_projfunc_curr_code
            ,p_projfunc_cost_rate_type  => l_projfunc_cost_rate_type
            ,p_projfunc_cost_rate_date  => l_projfunc_cost_rate_date
            ,p_projfunc_cost_exch_rate  => l_projfunc_cost_exch_rate
            ,p_projfunc_raw_cost        => l_act_projfunc_raw_cost
            ,p_structure_version_id          => p_structure_version_id -- 3627787
            ,x_return_status            => x_return_status
            ,x_msg_count           => x_msg_count
            ,x_msg_data            => x_msg_data
    );
             IF x_return_status <> FND_API.G_RET_STS_SUCCESS -- FPM Dev CR 8
          THEN
                 RAISE  FND_API.G_EXC_ERROR;
             END IF;
     -- Raw Cost Changes Begin
    PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS(
          p_project_id             => p_project_id
               ,p_task_id               => p_task_id
--            ,p_as_of_date               => SYSDATE
            ,p_as_of_date               => p_as_of_date     --bug 3901289
            ,p_txn_cost            => l_act_txn_bur_cost
            ,p_txn_curr_code            => l_txn_currency_code
            ,p_project_curr_code        => l_project_curr_code
            ,p_project_rate_type        => l_project_rate_type
            ,p_project_rate_date        => l_project_rate_date
            ,p_project_exch_rate        => l_project_exch_rate
            ,p_project_raw_cost         => l_act_project_bur_cost
            ,p_projfunc_curr_code       => l_projfunc_curr_code
            ,p_projfunc_cost_rate_type  => l_projfunc_cost_rate_type
            ,p_projfunc_cost_rate_date  => l_projfunc_cost_rate_date
            ,p_projfunc_cost_exch_rate  => l_projfunc_cost_exch_rate
            ,p_projfunc_raw_cost        => l_act_projfunc_bur_cost
            ,p_structure_version_id          => p_structure_version_id -- 3627787
            ,x_return_status            => x_return_status
            ,x_msg_count           => x_msg_count
            ,x_msg_data            => x_msg_data
    );
             IF x_return_status <> FND_API.G_RET_STS_SUCCESS
          THEN
                 RAISE  FND_API.G_EXC_ERROR;
             END IF;
     -- Raw Cost Changes End

    ELSE
     l_act_project_raw_cost := null;
     l_act_projfunc_raw_cost := null;
     l_act_project_bur_cost := null; --Raw Cost Changes
     l_act_projfunc_bur_cost := null; --Raw Cost Changes
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
         RAISE  FND_API.G_EXC_ERROR;
    END IF;

    IF g1_debug_mode  = 'Y' THEN
--          pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_act_txn_cost'||l_act_txn_cost, x_Log_Level=> 3);
          pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_act_project_raw_cost'||l_act_project_raw_cost, x_Log_Level=> 3);
          pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_act_projfunc_raw_cost'||l_act_projfunc_raw_cost, x_Log_Level=> 3);
    END IF;

    IF l_etc_txn_raw_cost IS NOT NULL AND l_etc_txn_raw_cost <> 0 THEN
    PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS(
          p_project_id             => p_project_id
               ,p_task_id               => p_task_id
--            ,p_as_of_date               => SYSDATE
            ,p_as_of_date               => p_as_of_date     --bug 3901289
            ,p_txn_cost            => l_etc_txn_raw_cost
            ,p_txn_curr_code            => l_txn_currency_code
            ,p_calling_mode             => 'PLAN_RATES'    ---4372462
            ,p_res_assignment_id        => l_assignment_id ---4372462
            ,p_budget_version_id        => l_budget_version_id ---4372462
            ,p_project_curr_code        => l_project_curr_code
            ,p_project_rate_type        => l_project_rate_type
            ,p_project_rate_date        => l_project_rate_date
            ,p_project_exch_rate        => l_project_exch_rate
            ,p_project_raw_cost         => l_etc_project_raw_cost
            ,p_projfunc_curr_code       => l_projfunc_curr_code
            ,p_projfunc_cost_rate_type  => l_projfunc_cost_rate_type
            ,p_projfunc_cost_rate_date  => l_projfunc_cost_rate_date
            ,p_projfunc_cost_exch_rate  => l_projfunc_cost_exch_rate
            ,p_projfunc_raw_cost        => l_etc_projfunc_raw_cost
            ,p_structure_version_id          => p_structure_version_id -- 3627787
            ,x_return_status            => x_return_status
            ,x_msg_count           => x_msg_count
            ,x_msg_data            => x_msg_data
    );
             IF x_return_status <> FND_API.G_RET_STS_SUCCESS -- FPM Dev CR 8
          THEN
                 RAISE  FND_API.G_EXC_ERROR;
             END IF;
    -- Raw Cost Changes Begin
    PA_PROGRESS_UTILS.CONVERT_CURRENCY_AMOUNTS(
          p_project_id             => p_project_id
               ,p_task_id               => p_task_id
--            ,p_as_of_date               => SYSDATE
            ,p_as_of_date               => p_as_of_date     --bug 3901289
            ,p_txn_cost            => l_etc_txn_bur_cost
            ,p_txn_curr_code            => l_txn_currency_code
            ,p_calling_mode             => 'PLAN_RATES'    ---4372462
            ,p_res_assignment_id        => l_assignment_id ---4372462
            ,p_budget_version_id        => l_budget_version_id ---4372462
            ,p_project_curr_code        => l_project_curr_code
            ,p_project_rate_type        => l_project_rate_type
            ,p_project_rate_date        => l_project_rate_date
            ,p_project_exch_rate        => l_project_exch_rate
            ,p_project_raw_cost         => l_etc_project_bur_cost
            ,p_projfunc_curr_code       => l_projfunc_curr_code
            ,p_projfunc_cost_rate_type  => l_projfunc_cost_rate_type
            ,p_projfunc_cost_rate_date  => l_projfunc_cost_rate_date
            ,p_projfunc_cost_exch_rate  => l_projfunc_cost_exch_rate
            ,p_projfunc_raw_cost        => l_etc_projfunc_bur_cost
            ,p_structure_version_id          => p_structure_version_id -- 3627787
            ,x_return_status            => x_return_status
            ,x_msg_count           => x_msg_count
            ,x_msg_data            => x_msg_data
    );
             IF x_return_status <> FND_API.G_RET_STS_SUCCESS -- FPM Dev CR 8
          THEN
                 RAISE  FND_API.G_EXC_ERROR;
             END IF;
    -- Raw Cost Changes End
    ELSE
     l_etc_project_raw_cost := null;
     l_etc_projfunc_raw_cost := null;
     l_etc_project_bur_cost := null;
     l_etc_projfunc_bur_cost := null;
     -- Bug 4116080 : Begin
     IF l_etc_txn_raw_cost = 0 THEN
	l_etc_project_raw_cost := 0;
	l_etc_projfunc_raw_cost := 0;
	l_etc_project_bur_cost := 0;
	l_etc_projfunc_bur_cost := 0;
     END IF;
     -- Bug 4116080 : End
    END IF;
    END IF;-- NVL(l_track_wp_cost_flag, 'Y') = 'Y' THEN -- Bug 3801745

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
         RAISE  FND_API.G_EXC_ERROR;
    END IF;


    IF g1_debug_mode  = 'Y' THEN
--          pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_etc_txn_cost'||l_etc_txn_cost, x_Log_Level=> 3);
          pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_etc_project_raw_cost'||l_etc_project_raw_cost, x_Log_Level=> 3);
          pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_etc_projfunc_raw_cost'||l_etc_projfunc_raw_cost, x_Log_Level=> 3);
          pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_project_rate_type'||l_project_rate_type, x_Log_Level=> 3);
          pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_project_rate_date'||l_project_rate_date, x_Log_Level=> 3);
          pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_project_exch_rate'||l_project_exch_rate, x_Log_Level=> 3);
          pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_projfunc_cost_rate_type'||l_projfunc_cost_rate_type, x_Log_Level=> 3);
          pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_projfunc_cost_rate_date'||l_projfunc_cost_rate_date, x_Log_Level=> 3);
          pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_projfunc_cost_exch_rate'||l_projfunc_cost_exch_rate, x_Log_Level=> 3);
          pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_act_effort_last_subm'||l_act_effort_last_subm, x_Log_Level=> 3);
          pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_act_raw_cost_last_subm_tc'||l_act_raw_cost_last_subm_tc, x_Log_Level=> 3);
    END IF;

    /* Bug 3606627 : Shifted this code up
    -- FPM Dev CR 3 : Added Logic to get total cost from last submission and this period.
    OPEN cur_task_cost(p_project_id, l_assignment_id, p_structure_type, l_resource_class_code, p_as_of_date);
    FETCH cur_task_cost INTO l_act_cost_last_subm_tc, l_act_cost_last_subm_pc, l_act_cost_last_subm_fc, l_act_effort_last_subm;
    CLOSE cur_task_cost;
    */

  /*  MOVING THIS CODE ABOVE TO GET BUDGET_VERSION_ID FOR CONVERSION to fix 4372462
    --BUG3630743 (Get all planned values)
    -- Bug 3696572 : Wrongly l_project_id was passed to below cursor instead of p_project_id
    OPEN c_get_planned_values (l_resource_list_member_id , l_assignment_id, p_project_id ) ;
    FETCH c_get_planned_values INTO
          l_planned_quantity ,
          l_planned_bur_cost_txn_cur,
          l_planned_bur_cost_projfunc,
          l_planned_bur_cost_proj_cur,
          l_planned_raw_cost_txn_cur,
          l_planned_raw_cost_proj_cur,
          l_planned_raw_cost_projfunc;
    CLOSE c_get_planned_values;
    --BUG3630743
    */


    --bug 3824042, round all the cost figures by calling pa_currency api,   start

    l_act_projfunc_raw_cost := pa_currency.round_trans_currency_amt(l_act_projfunc_raw_cost, l_prjfunc_currency_code);
    l_act_project_raw_cost  := pa_currency.round_trans_currency_amt(l_act_project_raw_cost, l_prj_currency_code);
    l_act_projfunc_bur_cost := pa_currency.round_trans_currency_amt(l_act_projfunc_bur_cost, l_prjfunc_currency_code);
    l_act_project_bur_cost  := pa_currency.round_trans_currency_amt(l_act_project_bur_cost, l_prj_currency_code);

    l_etc_projfunc_raw_cost := pa_currency.round_trans_currency_amt(l_etc_projfunc_raw_cost, l_prjfunc_currency_code);
    l_etc_project_raw_cost  := pa_currency.round_trans_currency_amt(l_etc_project_raw_cost, l_prj_currency_code);
    l_etc_projfunc_bur_cost := pa_currency.round_trans_currency_amt(l_etc_projfunc_bur_cost, l_prjfunc_currency_code);
    l_etc_project_bur_cost  := pa_currency.round_trans_currency_amt(l_etc_project_bur_cost, l_prj_currency_code);

    --bug 3824042, round all the cost figures by calling pa_currency api,   end


    IF l_resource_class_code = 'PEOPLE'   --maansari7/6 bug 3742356
    THEN

     -- Actuals are incremental amounts
     IF NVL(l_track_wp_cost_flag, 'Y') = 'Y' THEN -- Bug 3801745
	     l_ppl_act_raw_cost_to_date_tc := NVL( l_act_raw_cost_last_subm_tc, 0) + NVL( l_act_txn_raw_cost, 0);
	     l_ppl_act_raw_cost_to_date_fc := NVL( l_act_raw_cost_last_subm_fc, 0) + NVL( l_act_projfunc_raw_cost, 0);
	     l_ppl_act_raw_cost_to_date_pc := NVL( l_act_raw_cost_last_subm_pc, 0) + NVL( l_act_project_raw_cost, 0);
	     -- Raw Cost Changes
	     l_ppl_act_bur_cost_to_date_tc := NVL( l_act_bur_cost_last_subm_tc, 0) + NVL( l_act_txn_bur_cost, 0);
	     l_ppl_act_bur_cost_to_date_fc := NVL( l_act_bur_cost_last_subm_fc, 0) + NVL( l_act_projfunc_bur_cost, 0);
	     l_ppl_act_bur_cost_to_date_pc := NVL( l_act_bur_cost_last_subm_pc, 0) + NVL( l_act_project_bur_cost, 0);
     END IF;-- NVL(l_track_wp_cost_flag, 'Y') = 'Y' THEN -- Bug 3801745

     l_ppl_act_effort_to_date  := NVL( l_act_effort_last_subm, 0 ) + NVL( l_actual_effort_this_period, 0 ); --added NVL maansari4/8

     -- here we need to decide what is the correct value of actual this period
     if (subm_prog_exists_aod = 'Y') then
         l_act_txn_raw_cost := l_ppl_act_raw_cost_to_date_tc - nvl(l_act_raw_cost_latest_subm_tc,0);
         l_act_projfunc_raw_cost := l_ppl_act_raw_cost_to_date_fc - nvl(l_act_raw_cost_latest_subm_fc,0);
         l_act_project_raw_cost := l_ppl_act_raw_cost_to_date_pc - nvl(l_act_raw_cost_latest_subm_pc,0);
         l_act_txn_bur_cost := l_ppl_act_bur_cost_to_date_tc - nvl(l_act_bur_cost_latest_subm_tc,0);
         l_act_projfunc_bur_cost := l_ppl_act_bur_cost_to_date_fc - nvl(l_act_bur_cost_latest_subm_fc,0);
         l_act_project_bur_cost := l_ppl_act_bur_cost_to_date_pc - nvl(l_act_bur_cost_latest_subm_pc,0);
         l_actual_effort_this_period := l_ppl_act_effort_to_date - nvl(l_act_effort_latest_subm,0);
     end if;

     --BUG3630743 ( If etc is passed as null , default it with planned-actual )
     -- Added If part
     --IF (l_etc_txn_raw_cost IS NULL OR l_etc_effort_this_period IS NULL) THEN Bug 3801745
       IF l_etc_effort_this_period IS NULL THEN
          -- Default Etc as planned - Actual
          -- Since ETC is always cumulative , use to_date values of actuals to subtract from planned
	  IF NVL(l_track_wp_cost_flag, 'Y') = 'Y' THEN -- Bug 3801745
		  l_ppl_etc_raw_cost_tc := NVL (l_planned_raw_cost_txn_cur,0) -  NVL(l_ppl_act_raw_cost_to_date_tc,0);
		  l_ppl_etc_raw_cost_fc := NVL(l_planned_raw_cost_projfunc,0) - NVL(l_ppl_act_raw_cost_to_date_fc,0);
		  l_ppl_etc_raw_cost_pc := NVL(l_planned_raw_cost_proj_cur,0) - NVL(l_ppl_act_raw_cost_to_date_pc,0);

		  l_ppl_etc_bur_cost_tc := NVL(l_planned_bur_cost_txn_cur,0) - NVL(l_ppl_act_bur_cost_to_date_tc,0);
		  l_ppl_etc_bur_cost_fc := NVL(l_planned_bur_cost_projfunc,0) - NVL(l_ppl_act_bur_cost_to_date_fc,0);
		  l_ppl_etc_bur_cost_pc := NVL(l_planned_bur_cost_proj_cur,0) - NVL(l_ppl_act_bur_cost_to_date_pc,0);

		  --bug 3968789, if planned - actual is -ve then make it 0, start
		  IF l_ppl_etc_raw_cost_tc < 0
		  THEN
			l_ppl_etc_raw_cost_tc := 0;
			l_ppl_etc_raw_cost_fc := 0;
			l_ppl_etc_raw_cost_pc := 0;
			l_ppl_etc_bur_cost_tc := 0;
			l_ppl_etc_bur_cost_fc := 0;
			l_ppl_etc_bur_cost_pc := 0;
		  END IF;
		  --bug 3968789, if planned - actual is -ve then make it 0, end
    	  END IF;-- NVL(l_track_wp_cost_flag, 'Y') = 'Y' THEN -- Bug 3801745

          l_ppl_etc_effort := NVL(l_planned_quantity,0) - NVL(l_ppl_act_effort_to_date,0);
	  --bug 3968789,
	  IF l_ppl_etc_effort < 0
	  THEN
		l_ppl_etc_effort := 0;
	  END IF;
     --Added Else
     ELSE
          -- ETC's are cumulative amounts
	  IF NVL(l_track_wp_cost_flag, 'Y') = 'Y' THEN -- Bug 3801745
		  l_ppl_etc_raw_cost_tc := l_etc_txn_raw_cost;
		  l_ppl_etc_raw_cost_fc := l_etc_projfunc_raw_cost;
		  l_ppl_etc_raw_cost_pc := l_etc_project_raw_cost;
		  -- Raw Cost Changes

		  l_ppl_etc_bur_cost_tc := l_etc_txn_bur_cost;
		  l_ppl_etc_bur_cost_fc := l_etc_projfunc_bur_cost;
		  l_ppl_etc_bur_cost_pc := l_etc_project_bur_cost;
	 END IF;-- NVL(l_track_wp_cost_flag, 'Y') = 'Y' THEN -- Bug 3801745

          l_ppl_etc_effort  := l_etc_effort_this_period;
     END IF;
--maansari4/28
    ELSIF l_resource_class_code = 'EQUIPMENT'       --maansari7/6 bug 3742356
    THEN
     -- Actuals are incremental amounts
     IF NVL(l_track_wp_cost_flag, 'Y') = 'Y' THEN -- Bug 3801745
	     l_eqp_act_raw_cost_to_date_tc := NVL(l_act_raw_cost_last_subm_tc,0) + NVL(l_act_txn_raw_cost,0);
	     l_eqp_act_raw_cost_to_date_fc := NVL(l_act_raw_cost_last_subm_fc,0) + NVL(l_act_projfunc_raw_cost,0);
	     l_eqp_act_raw_cost_to_date_pc := NVL(l_act_raw_cost_last_subm_pc,0) + NVL(l_act_project_raw_cost,0);
	     -- Raw Cost Changes
	     l_eqp_act_bur_cost_to_date_tc := NVL(l_act_bur_cost_last_subm_tc,0) + NVL(l_act_txn_bur_cost,0);
	     l_eqp_act_bur_cost_to_date_fc := NVL(l_act_bur_cost_last_subm_fc,0) + NVL(l_act_projfunc_bur_cost,0);
	     l_eqp_act_bur_cost_to_date_pc := NVL(l_act_bur_cost_last_subm_pc,0) + NVL(l_act_project_bur_cost,0);
     END IF;-- NVL(l_track_wp_cost_flag, 'Y') = 'Y' THEN -- Bug 3801745

     l_eqpmt_act_effort_to_date  := NVL(l_act_effort_last_subm,0) + NVL(l_actual_effort_this_period,0);

     -- here we need to decide what is the correct value of actual this period
     if (subm_prog_exists_aod = 'Y') then
         l_act_txn_raw_cost := l_eqp_act_raw_cost_to_date_tc - nvl(l_act_raw_cost_latest_subm_tc,0);
         l_act_projfunc_raw_cost := l_eqp_act_raw_cost_to_date_fc - nvl(l_act_raw_cost_latest_subm_fc,0);
         l_act_project_raw_cost := l_eqp_act_raw_cost_to_date_pc - nvl(l_act_raw_cost_latest_subm_pc,0);
         l_act_txn_bur_cost := l_eqp_act_bur_cost_to_date_tc - nvl(l_act_bur_cost_latest_subm_tc,0);
         l_act_projfunc_bur_cost := l_eqp_act_bur_cost_to_date_fc - nvl(l_act_bur_cost_latest_subm_fc,0);
         l_act_project_bur_cost := l_eqp_act_bur_cost_to_date_pc - nvl(l_act_bur_cost_latest_subm_pc,0);
         l_actual_effort_this_period := l_eqpmt_act_effort_to_date - nvl(l_act_effort_latest_subm,0);
     end if;

     --BUG3630743 Added If part Default Etc as planned - Actual
     -- IF (l_etc_txn_raw_cost IS NULL OR l_etc_effort_this_period IS NULL) THEN  Bug 3801745
        IF l_etc_effort_this_period IS NULL THEN
          -- Since ETC is always cumulative , use to_date values of actuals to subtract from planned
          IF NVL(l_track_wp_cost_flag, 'Y') = 'Y' THEN -- Bug 3801745
		  l_eqpmt_etc_raw_cost_tc := NVL(l_planned_raw_cost_txn_cur,0)  - NVL(l_eqp_act_raw_cost_to_date_tc,0);
		  l_eqpmt_etc_raw_cost_fc := NVL(l_planned_raw_cost_projfunc,0) - NVL(l_eqp_act_raw_cost_to_date_fc,0);
		  l_eqpmt_etc_raw_cost_pc := NVL(l_planned_raw_cost_proj_cur,0) - NVL(l_eqp_act_raw_cost_to_date_pc,0);

		  l_eqpmt_etc_bur_cost_tc := NVL(l_planned_bur_cost_txn_cur,0)  -  NVL(l_eqp_act_bur_cost_to_date_tc,0);
		  l_eqpmt_etc_bur_cost_fc := NVL(l_planned_bur_cost_projfunc,0) -  NVL(l_eqp_act_bur_cost_to_date_fc,0);
		  l_eqpmt_etc_bur_cost_pc := NVL(l_planned_bur_cost_proj_cur ,0)-  NVL(l_eqp_act_bur_cost_to_date_pc,0);

		  --bug 3968789, if planned - actual is -ve then make it 0, start
		  IF l_eqpmt_etc_raw_cost_tc < 0
		  THEN
			l_eqpmt_etc_raw_cost_tc := 0;
			l_eqpmt_etc_raw_cost_fc := 0;
			l_eqpmt_etc_raw_cost_pc := 0;
			l_eqpmt_etc_bur_cost_tc := 0;
			l_eqpmt_etc_bur_cost_fc := 0;
			l_eqpmt_etc_bur_cost_pc := 0;
		  END IF;
		  --bug 3968789, if planned - actual is -ve then make it 0, end
	  END IF;-- NVL(l_track_wp_cost_flag, 'Y') = 'Y' THEN -- Bug 3801745

          l_eqpmt_etc_effort := NVL(l_planned_quantity,0) - NVL(l_eqpmt_act_effort_to_date,0);
	  --bug 3968789
	  IF l_eqpmt_etc_effort < 0
	  THEN
		l_eqpmt_etc_effort := 0;
	  END IF;

     ELSE
          -- ETC's are cumulative amounts
          IF NVL(l_track_wp_cost_flag, 'Y') = 'Y' THEN -- Bug 3801745
		  l_eqpmt_etc_raw_cost_tc := l_etc_txn_raw_cost;
		  l_eqpmt_etc_raw_cost_fc := l_etc_projfunc_raw_cost;
		  l_eqpmt_etc_raw_cost_pc := l_etc_project_raw_cost;
		  -- Raw Cost Changes
		  l_eqpmt_etc_bur_cost_tc := l_etc_txn_bur_cost;
		  l_eqpmt_etc_bur_cost_fc := l_etc_projfunc_bur_cost;
		  l_eqpmt_etc_bur_cost_pc := l_etc_project_bur_cost;
	  END IF;-- NVL(l_track_wp_cost_flag, 'Y') = 'Y' THEN -- Bug 3801745

          l_eqpmt_etc_effort := l_etc_effort_this_period;
     END IF;

    ELSIF l_resource_class_code = 'FINANCIAL_ELEMENTS' OR l_resource_class_code = 'MATERIAL_ITEMS'   --maansari7/6 bug 3742356
    THEN
     -- Actuals are incremental amounts
     IF NVL(l_track_wp_cost_flag, 'Y') = 'Y' THEN -- Bug 3801745
	     l_oth_act_raw_cost_to_date_tc := NVL(l_act_raw_cost_last_subm_tc,0) + NVL(l_act_txn_raw_cost,0);
	     l_oth_act_raw_cost_to_date_fc := NVL(l_act_raw_cost_last_subm_fc,0) + NVL(l_act_projfunc_raw_cost,0);
	     l_oth_act_raw_cost_to_date_pc := NVL(l_act_raw_cost_last_subm_pc,0) + NVL(l_act_project_raw_cost,0);
	     -- Raw Cost Changes
	     l_oth_act_bur_cost_to_date_tc := NVL(l_act_bur_cost_last_subm_tc,0) + NVL(l_act_txn_bur_cost,0);
	     l_oth_act_bur_cost_to_date_fc := NVL(l_act_bur_cost_last_subm_fc,0) + NVL(l_act_projfunc_bur_cost,0);
	     l_oth_act_bur_cost_to_date_pc := NVL(l_act_bur_cost_last_subm_pc,0) + NVL(l_act_project_bur_cost,0);
     END IF;-- NVL(l_track_wp_cost_flag, 'Y') = 'Y' THEN -- Bug 3801745

     l_oth_quantity_to_date  := NVL(l_act_effort_last_subm,0) + NVL(l_actual_effort_this_period,0); --bug 3608801

-- here we need to decide what is the correct value of actual this period
     if (subm_prog_exists_aod = 'Y') then
         l_act_txn_raw_cost := l_oth_act_raw_cost_to_date_tc - nvl(l_act_raw_cost_latest_subm_tc,0);
         l_act_projfunc_raw_cost := l_oth_act_raw_cost_to_date_fc - nvl(l_act_raw_cost_latest_subm_fc,0);
         l_act_project_raw_cost := l_oth_act_raw_cost_to_date_pc - nvl(l_act_raw_cost_latest_subm_pc,0);
         l_act_txn_bur_cost := l_oth_act_bur_cost_to_date_tc - nvl(l_act_bur_cost_latest_subm_tc,0);
         l_act_projfunc_bur_cost := l_oth_act_bur_cost_to_date_fc - nvl(l_act_bur_cost_latest_subm_fc,0);
         l_act_project_bur_cost := l_oth_act_bur_cost_to_date_pc - nvl(l_act_bur_cost_latest_subm_pc,0);
         l_actual_effort_this_period := l_oth_quantity_to_date - nvl(l_act_effort_latest_subm,0);
     end if;

        --IF (l_etc_txn_raw_cost IS NULL OR  Bug 3801745
        -- ( l_etc_effort_this_period IS NULL AND l_rate_based_flag = 'Y')) THEN  --bug 3779387 aded to prevent -ve ETC computation.
        IF l_etc_effort_this_period IS NULL THEN
          -- Default Etc as planned - Actual
          -- Since ETC is always cumulative , use to_date values of actuals to subtract from planned
	  IF NVL(l_track_wp_cost_flag, 'Y') = 'Y' THEN -- Bug 3801745
		  l_oth_etc_raw_cost_tc := NVL(l_planned_raw_cost_txn_cur,0)  - NVL(l_oth_act_raw_cost_to_date_tc,0);
		  l_oth_etc_raw_cost_fc := NVL(l_planned_raw_cost_projfunc,0) - NVL(l_oth_act_raw_cost_to_date_fc,0);
		  l_oth_etc_raw_cost_pc := NVL(l_planned_raw_cost_proj_cur,0) - NVL(l_oth_act_raw_cost_to_date_pc,0);

		  l_oth_etc_bur_cost_tc := NVL(l_planned_bur_cost_txn_cur,0)  - NVL(l_oth_act_bur_cost_to_date_tc,0);
		  l_oth_etc_bur_cost_fc := NVL(l_planned_bur_cost_projfunc,0) - NVL(l_oth_act_bur_cost_to_date_fc,0);
		  l_oth_etc_bur_cost_pc := NVL(l_planned_bur_cost_proj_cur ,0)- NVL(l_oth_act_bur_cost_to_date_pc,0);

		  --bug 3968789, if planned - actual is -ve then make it 0, start
		  IF l_oth_etc_raw_cost_tc < 0
		  THEN
			l_oth_etc_raw_cost_tc := 0;
			l_oth_etc_raw_cost_fc := 0;
			l_oth_etc_raw_cost_pc := 0;
			l_oth_etc_bur_cost_tc := 0;
			l_oth_etc_bur_cost_fc := 0;
			l_oth_etc_bur_cost_pc := 0;
		  END IF;
		  --bug 3968789, if planned - actual is -ve then make it 0, end

	  END IF;-- NVL(l_track_wp_cost_flag, 'Y') = 'Y' THEN -- Bug 3801745

          l_oth_etc_quantity    := NVL(l_planned_quantity,0)- NVL(l_oth_quantity_to_date,0);
	  --bug 3968789
	  IF l_oth_etc_quantity < 0
	  THEN
		l_oth_etc_quantity := 0;
	  END IF;

     ELSE
          -- ETC's are cumulative amounts
	  IF NVL(l_track_wp_cost_flag, 'Y') = 'Y' THEN -- Bug 3801745
		  l_oth_etc_raw_cost_tc   := l_etc_txn_raw_cost;
		  l_oth_etc_raw_cost_fc   := l_etc_projfunc_raw_cost;
		  l_oth_etc_raw_cost_pc   := l_etc_project_raw_cost;
		  -- Raw Cost Changes
		  l_oth_etc_bur_cost_tc   := l_etc_txn_bur_cost;
		  l_oth_etc_bur_cost_fc   := l_etc_projfunc_bur_cost;
		  l_oth_etc_bur_cost_pc   := l_etc_project_bur_cost;
          END IF;-- NVL(l_track_wp_cost_flag, 'Y') = 'Y' THEN -- Bug 3801745

   	  l_oth_etc_quantity := l_etc_effort_this_period; --bug 3608801
     END IF;
    END IF;
--maansari4/28
    IF g1_debug_mode  = 'Y' THEN
       pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'calling api to push actuals ', x_Log_Level=> 3);
    END IF;


    --bug no. 3586648
    --IF l_structure_shared = 'N' AND (l_act_txn_cost IS NOT NULL OR l_act_effort_this_period IS NOT NULL)
    --bug no. 3595585 moved the call after updating progress rollup Satish start
    /*IF ((l_structure_sharing_code <> 'SHARE_FULL') AND (l_act_txn_cost IS NOT NULL OR l_act_effort_this_period IS NOT NULL))
    THEN
     PA_PROGRESS_PUB.push_workplan_actuals(
          p_project_Id                 => p_project_id,
          p_structure_version_id       => p_structure_version_id,
          p_proj_element_id            => p_task_id,
          p_object_id                  => p_object_id,
          p_object_type                => l_object_type,
          p_as_of_date                 => p_as_of_date,
          p_rbs_element_id             => l_rbs_element_id,    --maansari7/6 bug 3742356
          p_rate_based_flag            => l_rate_based_flag,   --maansari7/6 bug 3742356
          p_resource_class_code        => l_resource_class_code,  --maansari7/6 bug 3742356
          p_TXN_CURRENCY_CODE          =>  l_txn_currency_code, -- Fix for Bug # 3988457.
					   -- p_txn_currency_code,
          p_act_TXN_COST_this_period   => l_act_txn_cost,
          p_act_PRJ_COST_this_period   => l_act_project_raw_cost,
          p_act_POU_COST_this_period   => l_act_projfunc_raw_cost,
          p_act_effort_this_period     => l_act_effort_this_period,
          -- BUG # 3659659.
	  --p_txn_currency_code	       => l_txn_currency_code,  	* already we are passing this parameter Bug: 4537865
	  p_prj_currency_code 	       => l_project_curr_code,
	  p_pfn_currency_code	       => l_projfunc_curr_code,
	  -- BUG # 3659659.
          x_return_status              => x_return_status,
          x_msg_count                  => x_msg_count,
          x_msg_data                   => x_msg_data
     );
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
         RAISE  FND_API.G_EXC_ERROR;
    END IF;*/

    IF (p_action='PUBLISH' AND (l_act_txn_raw_cost IS NOT NULL OR l_actual_effort_this_period IS NOT NULL
        OR l_etc_txn_raw_cost IS NOT NULL OR l_etc_effort_this_period IS NOT NULL)) --bug etc was not getting pushed to PJI due to this statement.
    THEN
     -- Raw Cost Changes : Added Burden parameters
     PA_PROGRESS_UTILS.get_last_etc_all(
                                        p_project_id                => p_project_id
                                       ,p_object_id                 => p_object_id
                                       ,p_object_type               => l_object_type
                                       ,p_as_of_date                => p_as_of_date
                                       ,p_structure_type        => 'WORKPLAN'
                           ,x_etc_txn_raw_cost_last_subm => l_etc_txn_raw_cost_last
                           ,x_etc_prj_raw_cost_last_subm => l_etc_prj_raw_cost_last
                           ,x_etc_pfc_raw_cost_last_subm => l_etc_pfc_raw_cost_last
                           ,x_etc_effort_last_subm       => l_etc_effort_last
                           ,x_etc_txn_bur_cost_last_subm => l_etc_txn_bur_cost_last
                           ,x_etc_prj_bur_cost_last_subm => l_etc_prj_bur_cost_last
                           ,x_etc_pfc_bur_cost_last_subm => l_etc_pfc_bur_cost_last
                           ,x_return_status           => x_return_status
                           ,x_msg_count          => x_msg_count
                           ,x_msg_data           => x_msg_data
			   ,p_proj_element_id    => p_task_id   --bug# 3764224 Added for RLM
			   ,p_resource_class_code => l_resource_class_code -- Bug 3836485
                                         );

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
            RAISE  FND_API.G_EXC_ERROR;
        END IF;
     --BUG 3630743 (If No progress exists default ETC this period as etc - planned)
--     OPEN c_if_progress_exists(l_assignment_id , l_project_id , l_structure_version_id );  --bug# 3764224 Changes for RLM

     IF g1_debug_mode  = 'Y' THEN
	pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_etc_effort_last ='||l_etc_effort_last, x_Log_Level=> 3);
	pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_etc_txn_raw_cost_last ='||l_etc_txn_raw_cost_last, x_Log_Level=> 3);
	pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_etc_txn_bur_cost_last ='||l_etc_txn_bur_cost_last, x_Log_Level=> 3);
     END IF;

     --bug# 3814545 Satish
     OPEN c_if_progress_exists(l_resource_list_member_id , p_project_id , l_structure_version_id );
     FETCH c_if_progress_exists INTO l_progress_exists;
     CLOSE c_if_progress_exists;

     IF g1_debug_mode  = 'Y' THEN
	pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'Checking the cursor l_progress_exists='||l_progress_exists, x_Log_Level=> 3);
     END IF;

--     IF c_if_progress_exists%NOTFOUND THEN
       IF nvl(l_progress_exists, 'N')='N'  THEN

	    -- Bug 3696572 , we shd not be using l_etc_txn_raw_cost varables instead we shd sum up individual buckets
	    -- this is because l_etc_txn_raw_cost will be null if not passed from UI, in this case
	    -- up in the code we default individual etc buckets, we shd use them
            /*l_etc_txn_raw_cost_this_period := NVL(l_etc_txn_raw_cost,0) - NVL(l_planned_raw_cost_txn_cur,0);
            l_etc_prj_raw_cost_this_period := NVL(l_etc_project_raw_cost,0) - NVL(l_planned_raw_cost_proj_cur,0);
            l_etc_pfc_raw_cost_this_period := NVL(l_etc_projfunc_raw_cost,0) - NVL(l_planned_raw_cost_projfunc,0);
            l_etc_txn_bur_cost_this_period := NVL(l_etc_txn_bur_cost,0) - NVL(l_planned_bur_cost_txn_cur,0);
	    l_etc_prj_bur_cost_this_period := NVL(l_etc_project_bur_cost,0) - NVL(l_planned_bur_cost_projfunc,0);
            l_etc_pfc_bur_cost_this_period := NVL(l_etc_projfunc_bur_cost ,0)- NVL(l_planned_bur_cost_proj_cur,0);
            l_etc_effort_incr              := NVL(l_etc_effort_this_period,0) - NVL(l_planned_quantity,0);
	    */
	    IF g1_debug_mode  = 'Y' THEN
		  pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'Progress does not exist', x_Log_Level=> 3);
	    END IF;
	    IF NVL(l_track_wp_cost_flag, 'Y') = 'Y' THEN -- Bug 3801745
		    l_etc_txn_raw_cost_this_period := NVL(l_ppl_etc_raw_cost_tc,0) + NVL(l_eqpmt_etc_raw_cost_tc,0) + NVL(l_oth_etc_raw_cost_tc,0) - NVL(l_planned_raw_cost_txn_cur,0);
		    l_etc_prj_raw_cost_this_period := NVL(l_ppl_etc_raw_cost_pc,0) + NVL(l_eqpmt_etc_raw_cost_pc,0) + NVL(l_oth_etc_raw_cost_pc,0) - NVL(l_planned_raw_cost_proj_cur,0);
		    l_etc_pfc_raw_cost_this_period := NVL(l_ppl_etc_raw_cost_fc,0) + NVL(l_eqpmt_etc_raw_cost_fc,0) + NVL(l_oth_etc_raw_cost_fc,0) - NVL(l_planned_raw_cost_projfunc,0);
		    l_etc_txn_bur_cost_this_period := NVL(l_ppl_etc_bur_cost_tc,0) + NVL(l_eqpmt_etc_bur_cost_tc,0) + NVL(l_oth_etc_bur_cost_tc,0) - NVL(l_planned_bur_cost_txn_cur,0);
		    l_etc_prj_bur_cost_this_period := NVL(l_ppl_etc_bur_cost_pc,0) + NVL(l_eqpmt_etc_bur_cost_pc,0) + NVL(l_oth_etc_bur_cost_pc,0) - NVL(l_planned_bur_cost_projfunc,0);
		    l_etc_pfc_bur_cost_this_period := NVL(l_ppl_etc_bur_cost_fc,0) + NVL(l_eqpmt_etc_bur_cost_fc,0) + NVL(l_oth_etc_bur_cost_fc,0) - NVL(l_planned_bur_cost_proj_cur,0);
	    END IF;-- NVL(l_track_wp_cost_flag, 'Y') = 'Y' THEN -- Bug 3801745
            l_etc_effort_incr              := NVL(l_ppl_etc_effort,0) + NVL(l_eqpmt_etc_effort,0) + NVL(l_oth_etc_quantity,0) - NVL(l_planned_quantity,0);
     ELSE
          /*l_etc_txn_raw_cost_this_period := NVL(l_etc_txn_raw_cost,0) - NVL(l_etc_txn_raw_cost_last,0);
          l_etc_prj_raw_cost_this_period := NVL(l_etc_project_raw_cost,0) - NVL(l_etc_prj_raw_cost_last,0);
          l_etc_pfc_raw_cost_this_period := NVL(l_etc_projfunc_raw_cost,0) - NVL(l_etc_pfc_raw_cost_last,0);
          l_etc_txn_bur_cost_this_period := NVL(l_etc_txn_bur_cost,0) - NVL(l_etc_txn_bur_cost_last,0);
          l_etc_prj_bur_cost_this_period := NVL(l_etc_project_bur_cost,0) - NVL(l_etc_prj_bur_cost_last,0);
          l_etc_pfc_bur_cost_this_period := NVL(l_etc_projfunc_bur_cost,0) - NVL(l_etc_pfc_bur_cost_last,0);
          l_etc_effort_incr              := NVL(l_etc_effort_this_period,0) - NVL(l_etc_effort_last,0);
	  */
	  IF g1_debug_mode  = 'Y' THEN
	      pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'Progress  exists', x_Log_Level=> 3);
	  END IF;
          IF NVL(l_track_wp_cost_flag, 'Y') = 'Y' THEN -- Bug 3801745
           -- 3818384 (etc = current_etc - nvl(last etc, (planned - last act))
          if (l_planned_raw_cost_txn_cur >= l_act_raw_cost_last_subm_tc) then
             l_etc_txn_raw_cost_this_period := NVL(l_ppl_etc_raw_cost_tc,0) + NVL(l_eqpmt_etc_raw_cost_tc,0) + NVL(l_oth_etc_raw_cost_tc,0) - NVL(l_etc_txn_raw_cost_last,nvl(l_planned_raw_cost_txn_cur,0)-nvl(l_act_raw_cost_last_subm_tc,0));
          else
             l_etc_txn_raw_cost_this_period := NVL(l_ppl_etc_raw_cost_tc,0) + NVL(l_eqpmt_etc_raw_cost_tc,0) + NVL(l_oth_etc_raw_cost_tc,0) - NVL(l_etc_txn_raw_cost_last,0);
          end if;
          if (l_planned_raw_cost_proj_cur >= l_act_raw_cost_last_subm_pc) then
             l_etc_prj_raw_cost_this_period := NVL(l_ppl_etc_raw_cost_pc,0) + NVL(l_eqpmt_etc_raw_cost_pc,0) + NVL(l_oth_etc_raw_cost_pc,0) - NVL(l_etc_prj_raw_cost_last,nvl(l_planned_raw_cost_proj_cur,0)-nvl(l_act_raw_cost_last_subm_pc,0));
          else
             l_etc_prj_raw_cost_this_period := NVL(l_ppl_etc_raw_cost_pc,0) + NVL(l_eqpmt_etc_raw_cost_pc,0) + NVL(l_oth_etc_raw_cost_pc,0) - NVL(l_etc_prj_raw_cost_last,0);
          end if;
          if (l_planned_raw_cost_projfunc >= l_act_raw_cost_last_subm_fc) then
             l_etc_pfc_raw_cost_this_period := NVL(l_ppl_etc_raw_cost_fc,0) + NVL(l_eqpmt_etc_raw_cost_fc,0) + NVL(l_oth_etc_raw_cost_fc,0) - NVL(l_etc_pfc_raw_cost_last,nvl(l_planned_raw_cost_projfunc,0)-nvl(l_act_raw_cost_last_subm_fc,0));
          else
             l_etc_pfc_raw_cost_this_period := NVL(l_ppl_etc_raw_cost_fc,0) + NVL(l_eqpmt_etc_raw_cost_fc,0) + NVL(l_oth_etc_raw_cost_fc,0) - NVL(l_etc_pfc_raw_cost_last,0);
          end if;
          if (l_planned_bur_cost_txn_cur >= l_act_bur_cost_last_subm_tc) then
             l_etc_txn_bur_cost_this_period := NVL(l_ppl_etc_bur_cost_tc,0) + NVL(l_eqpmt_etc_bur_cost_tc,0) + NVL(l_oth_etc_bur_cost_tc,0) - NVL(l_etc_txn_bur_cost_last,nvl(l_planned_bur_cost_txn_cur,0)-nvl(l_act_bur_cost_last_subm_tc,0));
          else
             l_etc_txn_bur_cost_this_period := NVL(l_ppl_etc_bur_cost_tc,0) + NVL(l_eqpmt_etc_bur_cost_tc,0) + NVL(l_oth_etc_bur_cost_tc,0) - NVL(l_etc_txn_bur_cost_last,0);
          end if;
          if (l_planned_bur_cost_proj_cur >= l_act_bur_cost_last_subm_pc) then
             l_etc_prj_bur_cost_this_period := NVL(l_ppl_etc_bur_cost_pc,0) + NVL(l_eqpmt_etc_bur_cost_pc,0) + NVL(l_oth_etc_bur_cost_pc,0) - NVL(l_etc_prj_bur_cost_last,nvl(l_planned_bur_cost_proj_cur,0)-nvl(l_act_bur_cost_last_subm_pc,0));
          else
             l_etc_prj_bur_cost_this_period := NVL(l_ppl_etc_bur_cost_pc,0) + NVL(l_eqpmt_etc_bur_cost_pc,0) + NVL(l_oth_etc_bur_cost_pc,0) - NVL(l_etc_prj_bur_cost_last,0);
          end if;
          if (l_planned_bur_cost_projfunc >= l_act_bur_cost_last_subm_fc) then
             l_etc_pfc_bur_cost_this_period := NVL(l_ppl_etc_bur_cost_fc,0) + NVL(l_eqpmt_etc_bur_cost_fc,0) + NVL(l_oth_etc_bur_cost_fc,0) - NVL(l_etc_pfc_bur_cost_last,nvl(l_planned_bur_cost_projfunc,0)-nvl(l_act_bur_cost_last_subm_fc,0));
          else
             l_etc_pfc_bur_cost_this_period := NVL(l_ppl_etc_bur_cost_fc,0) + NVL(l_eqpmt_etc_bur_cost_fc,0) + NVL(l_oth_etc_bur_cost_fc,0) - NVL(l_etc_pfc_bur_cost_last,0);
          end if;
          END IF;-- NVL(l_track_wp_cost_flag, 'Y') = 'Y' THEN -- Bug 3801745
          if (l_planned_quantity >= l_act_effort_last_subm) then
             l_etc_effort_incr              := NVL(l_ppl_etc_effort,0) + NVL(l_eqpmt_etc_effort,0) + NVL(l_oth_etc_quantity,0) - NVL(l_etc_effort_last,nvl(l_planned_quantity,0)-nvl(l_act_effort_last_subm,0));
          else
             l_etc_effort_incr              := NVL(l_ppl_etc_effort,0) + NVL(l_eqpmt_etc_effort,0) + NVL(l_oth_etc_quantity,0) - NVL(l_etc_effort_last,0);
          end if;
     END IF;

--     CLOSE c_if_progress_exists;

     IF g1_debug_mode  = 'Y' THEN
	      pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_etc_txn_raw_cost_this_period '||l_etc_txn_raw_cost_this_period, x_Log_Level=> 3);
	      pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_etc_txn_bur_cost_this_period '||l_etc_txn_bur_cost_this_period, x_Log_Level=> 3);
	      pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_etc_effort_incr '||l_etc_effort_incr, x_Log_Level=> 3);
     END IF;

     -- Raw Cost Changes : Modified  push_workplan actuals call
     PA_PROGRESS_PUB.push_workplan_actuals(
          p_project_Id                 => p_project_id,
          p_structure_version_id       => p_structure_version_id,
          p_proj_element_id            => p_task_id,
          p_object_id                  => p_object_id,
          p_object_type                => l_object_type,
          p_as_of_date                 => p_as_of_date,
          p_resource_assignment_id     => l_assignment_id, -- Bug 4186007
          p_resource_list_member_id    => l_resource_list_member_id, -- Bug 4186007
          p_rbs_element_id             => l_rbs_element_id,               --maansari7/6 bug 3742356
          p_rate_based_flag            => l_rate_based_flag,              --maansari7/6 bug 3742356
          p_resource_class_code        => l_resource_class_code,          --maansari7/6 bug 3742356
          p_act_TXN_COST_this_period   => l_act_txn_bur_cost,
          p_act_PRJ_COST_this_period   => l_act_project_bur_cost,
          p_act_POU_COST_this_period   => l_act_projfunc_bur_cost,
          p_act_effort_this_period     => l_actual_effort_this_period,
                p_etc_TXN_COST_this_period   => l_etc_txn_bur_cost_this_period,
                p_etc_PRJ_COST_this_period   => l_etc_prj_bur_cost_this_period,
                p_etc_POU_COST_this_period   => l_etc_pfc_bur_cost_this_period,
                p_etc_effort_this_period     => l_etc_effort_incr,
                p_act_TXN_raw_COST_this_period => l_act_txn_raw_cost,
                p_act_PRJ_raw_COST_this_period => l_act_project_raw_cost,
                p_act_POU_raw_COST_this_period => l_act_projfunc_raw_cost,
                p_etc_TXN_raw_COST_this_period => l_etc_txn_raw_cost_this_period,
                p_etc_PRJ_raw_COST_this_period => l_etc_prj_raw_cost_this_period,
                p_etc_POU_raw_COST_this_period => l_etc_pfc_raw_cost_this_period,
	  -- BUG # 3659659.
          p_txn_currency_code          => l_txn_currency_code,
          p_prj_currency_code          => l_project_curr_code,
          p_pfn_currency_code          => l_projfunc_curr_code,
	  -- BUG # 3659659.
      --bug 3675107
          p_pa_period_name             => l_prog_pa_period_name,
          p_gl_period_name             => l_prog_gl_period_name,
      --bug 3675107
          x_return_status              => x_return_status,
          x_msg_count                  => x_msg_count,
          x_msg_data                   => x_msg_data
     );

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
            RAISE  FND_API.G_EXC_ERROR;
        END IF;

    END IF;
    --bug no. 3595585 Satish end

   --bug 4341100, start
    IF  l_etc_effort_this_period is null
    THEN
	    IF l_resource_class_code = 'PEOPLE'
	    THEN
		  l_etc_effort_this_period  := l_ppl_etc_effort;
	    ELSIF l_resource_class_code = 'EQUIPMENT'
	    THEN
		  l_etc_effort_this_period := l_eqpmt_etc_effort;
	    ELSIF l_resource_class_code = 'FINANCIAL_ELEMENTS' OR l_resource_class_code = 'MATERIAL_ITEMS'
	    THEN
		   l_etc_effort_this_period := l_oth_etc_quantity;
	    END IF;
    END IF;

   IF ((l_etc_effort_this_period = 0 OR l_etc_effort_this_period is null) AND l_actual_finish_date is null) -- Bug 3956299
    THEN
        -- Bug 3956299 : We can default actual finish date in this case from scheduled_finish_date
	l_actual_finish_date := l_scheduled_finish_date;
	IF l_actual_finish_date is null THEN
		--You have to pass actual finish date if etc is 0
		PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
				     ,p_msg_name       => 'PA_TP_ASSG_NTER_FIN_DATE');
	       x_msg_data := 'PA_TP_ASSG_NTER_FIN_DATE';
	       x_return_status := 'E';
	       RAISE  FND_API.G_EXC_ERROR;
	END IF;
    END IF;
   --bug 4341100, end

    IF l_etc_effort_this_period  IS NOT NULL AND l_etc_effort_this_period > 0
    THEN
       l_actual_finish_date := null;
    END IF; --Bug 8887270


    IF l_db_action = 'CREATE'
    THEN
       /* FPM Dev CR 3
       IF p_percent_complete_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
        THEN
            l_percent_complete_id := null;
        ELSE
            l_percent_complete_id := p_percent_complete_id;
        END IF;
     */
        l_percent_complete_id := null;


        PA_PERCENT_COMPLETES_PKG.INSERT_ROW(
                      p_TASK_ID                  => l_task_id
                      ,p_DATE_COMPUTED           => p_as_of_date
                      ,p_LAST_UPDATE_DATE        => SYSDATE
                      ,p_LAST_UPDATED_BY         => l_user_id
                      ,p_CREATION_DATE           => SYSDATE
                      ,p_CREATED_BY              => l_user_id
                      ,p_LAST_UPDATE_LOGIN       => l_login_id
                ,p_COMPLETED_PERCENTAGE    => l_percent_complete
                      ,p_DESCRIPTION             => l_brief_overview
                      ,p_PROJECT_ID              => p_project_id
                      ,p_PM_PRODUCT_CODE         => l_pm_product_code
                      ,p_CURRENT_FLAG            => l_current_flag
                      ,p_OBJECT_TYPE             => l_object_type
                      --,p_OBJECT_ID               => l_assignment_id     --bug# 3764224 Changes for RLM
                      ,p_OBJECT_ID               => l_resource_list_member_id
                ,p_OBJECT_VERSION_ID       => l_object_version_id
                ,p_PROGRESS_STATUS_CODE    => l_progress_status_code
                      ,p_ACTUAL_START_DATE       => l_actual_start_date
                      ,p_ACTUAL_FINISH_DATE      => l_actual_finish_date
                      ,p_ESTIMATED_START_DATE    => l_estimated_start_date
                      ,p_ESTIMATED_FINISH_DATE   => l_estimated_finish_date
                      ,p_PUBLISHED_FLAG          => l_published_flag
                      ,p_PUBLISHED_BY_PARTY_ID   => l_published_by_party_id
                      ,p_PROGRESS_COMMENT        => l_progress_comment
                      ,p_HISTORY_FLAG            => 'N'
                ,p_status_code             => l_task_status
                      ,x_PERCENT_COMPLETE_ID     => l_percent_complete_id
                      ,p_ATTRIBUTE_CATEGORY      => null
                      ,p_ATTRIBUTE1              => null
                      ,p_ATTRIBUTE2              => null
                      ,p_ATTRIBUTE3              => null
                      ,p_ATTRIBUTE4              => null
                      ,p_ATTRIBUTE5              => null
                      ,p_ATTRIBUTE6              => null
                      ,p_ATTRIBUTE7              => null
                      ,p_ATTRIBUTE8              => null
                      ,p_ATTRIBUTE9              => null
                      ,p_ATTRIBUTE10             => null
                      ,p_ATTRIBUTE11             => null
                      ,p_ATTRIBUTE12             => null
                      ,p_ATTRIBUTE13             => null
                      ,p_ATTRIBUTE14             => null
                      ,p_ATTRIBUTE15             => null
                ,p_structure_type        => p_structure_type
        );

          IF Fnd_Msg_Pub.count_msg > 0 THEN -- FPM Dev CR 8
               RAISE  FND_API.G_EXC_ERROR;
          END IF;

        l_PROGRESS_ROLLUP_ID := null;
        --Create record in progress rollup

        IF g1_debug_mode  = 'Y' THEN
            pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'INSERTED IN PPC', x_Log_Level=> 3);
        END IF;


        l_PROGRESS_ROLLUP_ID := PA_PROGRESS_UTILS.get_prog_rollup_id(
                                   p_project_id             => p_project_id
                                  --,p_object_id            => l_assignment_id  --bug# 3764224 Changes for RLM
                                  ,p_object_id              => l_resource_list_member_id
                                  ,p_object_type	    => l_object_type
                                  ,p_object_version_id      => l_object_version_id
                                  ,p_as_of_date             => p_as_of_date
				  ,p_structure_version_id   => l_structure_version_id
				  ,p_action                 => p_action -- Bug 3879461
                                  ,x_record_version_number  => l_rollup_rec_ver_number
				  ,p_proj_element_id        => p_task_id   --bug# 3764224 Added for RLM
                                );
          IF Fnd_Msg_Pub.count_msg > 0 THEN
               RAISE  FND_API.G_EXC_ERROR;
          END IF;


        IF g1_debug_mode  = 'Y' THEN
            pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_PROGRESS_ROLLUP_ID '||l_PROGRESS_ROLLUP_ID, x_Log_Level=> 3);
        END IF;


        IF l_PROGRESS_ROLLUP_ID IS NULL
        THEN
            IF g1_debug_mode  = 'Y' THEN
               pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'INSERTING IN PPR', x_Log_Level=> 3);
            END IF;

            PA_PROGRESS_ROLLUP_PKG.INSERT_ROW(
                       X_PROGRESS_ROLLUP_ID              => l_PROGRESS_ROLLUP_ID
                      ,X_PROJECT_ID                      => p_project_id
                      --,X_OBJECT_ID                       => l_assignment_id    --bug# 3764224 Changes for RLM
                      ,X_OBJECT_ID                       => l_resource_list_member_id
                      ,X_OBJECT_TYPE                     => l_object_type
                      ,X_AS_OF_DATE                      => p_as_of_date
		,X_OBJECT_VERSION_ID          => l_object_version_id
                      ,X_LAST_UPDATE_DATE                => SYSDATE
                      ,X_LAST_UPDATED_BY                 => l_user_id
                      ,X_CREATION_DATE                   => SYSDATE
                      ,X_CREATED_BY                      => l_user_id
                ,X_PROGRESS_STATUS_CODE            => l_rollup_progress_status
                      ,X_LAST_UPDATE_LOGIN               => l_login_id
                      ,X_INCREMENTAL_WORK_QTY            => l_INCREMENTAL_WORK_QTY
                      ,X_CUMULATIVE_WORK_QTY             => l_CUMULATIVE_WORK_QTY
                      ,X_BASE_PERCENT_COMPLETE           => l_BASE_PERCENT_COMPLETE
                      ,X_EFF_ROLLUP_PERCENT_COMP         => l_EFF_ROLLUP_PERCENT_COMP
                      ,X_COMPLETED_PERCENTAGE            => l_rollup_completed_percentage
                      ,X_ESTIMATED_START_DATE            => l_estimated_start_date
                      ,X_ESTIMATED_FINISH_DATE           => l_estimated_finish_date
                      ,X_ACTUAL_START_DATE               => l_actual_start_date
                      ,X_ACTUAL_FINISH_DATE              => l_actual_finish_date
                      ,X_EST_REMAINING_EFFORT            => l_ppl_etc_effort
                      ,X_BASE_PERCENT_COMP_DERIV_CODE    => l_BASE_PERCENT_COMP_DERIV_CODE
                      ,X_BASE_PROGRESS_STATUS_CODE       => l_date_override_flag -- 4533112 l_BASE_PROGRESS_STATUS_CODE
                      ,X_EFF_ROLLUP_PROG_STAT_CODE       => l_EFF_ROLLUP_PROG_STAT_CODE
                ,x_percent_complete_id             => l_percent_complete_id
                ,X_STRUCTURE_TYPE                  => p_structure_type
                ,X_PROJ_ELEMENT_ID                 => p_task_id
                      ,X_STRUCTURE_VERSION_ID            => l_structure_version_id
                      ,X_PPL_ACT_EFFORT_TO_DATE          => l_ppl_act_effort_to_date
                      ,X_EQPMT_ACT_EFFORT_TO_DATE        => l_eqpmt_act_effort_to_date
                      ,X_EQPMT_ETC_EFFORT                => l_eqpmt_etc_effort
                      ,X_OTH_ACT_COST_TO_DATE_TC   => l_oth_act_bur_cost_to_date_tc
                      ,X_OTH_ACT_COST_TO_DATE_FC   => l_oth_act_bur_cost_to_date_fc
                      ,X_OTH_ACT_COST_TO_DATE_PC   => l_oth_act_bur_cost_to_date_pc
                      ,X_OTH_ETC_COST_TC                 => l_oth_etc_bur_cost_tc
                      ,X_OTH_ETC_COST_FC                 => l_oth_etc_bur_cost_fc
                      ,X_OTH_ETC_COST_PC                 => l_oth_etc_bur_cost_pc
                      ,X_PPL_ACT_COST_TO_DATE_TC   => l_ppl_act_bur_cost_to_date_tc
                      ,X_PPL_ACT_COST_TO_DATE_FC   => l_ppl_act_bur_cost_to_date_fc
                      ,X_PPL_ACT_COST_TO_DATE_PC   => l_ppl_act_bur_cost_to_date_pc
                      ,X_PPL_ETC_COST_TC                 => l_ppl_etc_bur_cost_tc
                      ,X_PPL_ETC_COST_FC                 => l_ppl_etc_bur_cost_fc
                      ,X_PPL_ETC_COST_PC                 => l_ppl_etc_bur_cost_pc
                      ,X_EQPMT_ACT_COST_TO_DATE_TC      => l_eqp_act_bur_cost_to_date_tc
                      ,X_EQPMT_ACT_COST_TO_DATE_FC      => l_eqp_act_bur_cost_to_date_fc
                      ,X_EQPMT_ACT_COST_TO_DATE_PC      => l_eqp_act_bur_cost_to_date_pc
                      ,X_EQPMT_ETC_COST_TC               => l_eqpmt_etc_bur_cost_tc
                      ,X_EQPMT_ETC_COST_FC               => l_eqpmt_etc_bur_cost_fc
                      ,X_EQPMT_ETC_COST_PC               => l_eqpmt_etc_bur_cost_pc
                      ,X_EARNED_VALUE                    => null
                      ,X_TASK_WT_BASIS_CODE              => null
                      ,X_SUBPRJ_PPL_ACT_EFFORT           => null
                      ,X_SUBPRJ_EQPMT_ACT_EFFORT         => null
                      ,X_SUBPRJ_PPL_ETC_EFFORT           => null
                      ,X_SUBPRJ_EQPMT_ETC_EFFORT         => null
                      ,X_SBPJ_OTH_ACT_COST_TO_DATE_TC    => null
                      ,X_SBPJ_OTH_ACT_COST_TO_DATE_FC    => null
                      ,X_SBPJ_OTH_ACT_COST_TO_DATE_PC    => null
                      ,X_SUBPRJ_PPL_ACT_COST_TC          => null
                      ,X_SUBPRJ_PPL_ACT_COST_FC          => null
                      ,X_SUBPRJ_PPL_ACT_COST_PC          => null
                      ,X_SUBPRJ_EQPMT_ACT_COST_TC        => null
                      ,X_SUBPRJ_EQPMT_ACT_COST_FC        => null
                      ,X_SUBPRJ_EQPMT_ACT_COST_PC        => null
                      ,X_SUBPRJ_OTH_ETC_COST_TC          => null
                      ,X_SUBPRJ_OTH_ETC_COST_FC          => null
                      ,X_SUBPRJ_OTH_ETC_COST_PC          => null
                      ,X_SUBPRJ_PPL_ETC_COST_TC          => null
                      ,X_SUBPRJ_PPL_ETC_COST_FC          => null
                      ,X_SUBPRJ_PPL_ETC_COST_PC          => null
                      ,X_SUBPRJ_EQPMT_ETC_COST_TC        => null
                      ,X_SUBPRJ_EQPMT_ETC_COST_FC        => null
                      ,X_SUBPRJ_EQPMT_ETC_COST_PC        => null
                ,X_SUBPRJ_EARNED_VALUE             => null
                ,X_CURRENT_FLAG               => l_rollup_current_flag -- Bug 3879461 l_current_flag
                ,X_PROJFUNC_COST_RATE_TYPE         => l_projfunc_cost_rate_type
                ,X_PROJFUNC_COST_EXCHANGE_RATE     => l_projfunc_cost_exch_rate
                ,X_PROJFUNC_COST_RATE_DATE         => l_projfunc_cost_rate_date
                ,X_PROJ_COST_RATE_TYPE             => l_project_rate_type
                ,X_PROJ_COST_EXCHANGE_RATE         => l_project_exch_rate
                ,X_PROJ_COST_RATE_DATE             => l_project_rate_date
                ,X_TXN_CURRENCY_CODE          =>  l_txn_currency_code -- Fix for Bug # 3988457.
						  -- p_txn_currency_code    --maansari4/30
                ,X_PROG_PA_PERIOD_NAME        => l_prog_pa_period_name
                ,X_PROG_GL_PERIOD_NAME        => l_prog_gl_period_name
                --bug 3608801
                ,X_OTH_QUANTITY_TO_DATE            => l_oth_quantity_to_date  -- bug no.3608801
                     ,X_OTH_ETC_QUANTITY                => l_oth_etc_quantity
                --bug 3608801
                      ,X_OTH_ACT_RAWCOST_TO_DATE_TC     => l_oth_act_raw_cost_to_date_tc
                      ,X_OTH_ACT_RAWCOST_TO_DATE_FC     => l_oth_act_raw_cost_to_date_fc
                      ,X_OTH_ACT_RAWCOST_TO_DATE_PC     => l_oth_act_raw_cost_to_date_pc
                      ,X_OTH_ETC_RAWCOST_TC        => l_oth_etc_raw_cost_tc
                      ,X_OTH_ETC_RAWCOST_FC        => l_oth_etc_raw_cost_fc
                      ,X_OTH_ETC_RAWCOST_PC        => l_oth_etc_raw_cost_pc
                      ,X_PPL_ACT_RAWCOST_TO_DATE_TC     => l_ppl_act_raw_cost_to_date_tc
                      ,X_PPL_ACT_RAWCOST_TO_DATE_FC     => l_ppl_act_raw_cost_to_date_fc
                      ,X_PPL_ACT_RAWCOST_TO_DATE_PC     => l_ppl_act_raw_cost_to_date_pc
                      ,X_PPL_ETC_RAWCOST_TC        => l_ppl_etc_raw_cost_tc
                      ,X_PPL_ETC_RAWCOST_FC        => l_ppl_etc_raw_cost_fc
                      ,X_PPL_ETC_RAWCOST_PC        => l_ppl_etc_raw_cost_pc
                      ,X_EQPMT_ACT_RAWCOST_TO_DATE_TC   => l_eqp_act_raw_cost_to_date_tc
                      ,X_EQPMT_ACT_RAWCOST_TO_DATE_FC   => l_eqp_act_raw_cost_to_date_fc
                      ,X_EQPMT_ACT_RAWCOST_TO_DATE_PC   => l_eqp_act_raw_cost_to_date_pc
                      ,X_EQPMT_ETC_RAWCOST_TC           => l_eqpmt_etc_raw_cost_tc
                      ,X_EQPMT_ETC_RAWCOST_FC           => l_eqpmt_etc_raw_cost_fc
                      ,X_EQPMT_ETC_RAWCOST_PC           => l_eqpmt_etc_raw_cost_pc
                      ,X_SP_OTH_ACT_RAWCOST_TODATE_TC   => null
                      ,X_SP_OTH_ACT_RAWCOST_TODATE_FC   => null
                      ,X_SP_OTH_ACT_RAWCOST_TODATE_PC   => null
                      ,X_SUBPRJ_PPL_ACT_RAWCOST_TC      => null
                      ,X_SUBPRJ_PPL_ACT_RAWCOST_FC      => null
                      ,X_SUBPRJ_PPL_ACT_RAWCOST_PC      => null
                      ,X_SUBPRJ_EQPMT_ACT_RAWCOST_TC    => null
                      ,X_SUBPRJ_EQPMT_ACT_RAWCOST_FC    => null
                      ,X_SUBPRJ_EQPMT_ACT_RAWCOST_PC    => null
                      ,X_SUBPRJ_OTH_ETC_RAWCOST_TC      => null
                      ,X_SUBPRJ_OTH_ETC_RAWCOST_FC      => null
                      ,X_SUBPRJ_OTH_ETC_RAWCOST_PC      => null
                      ,X_SUBPRJ_PPL_ETC_RAWCOST_TC      => null
                      ,X_SUBPRJ_PPL_ETC_RAWCOST_FC      => null
                      ,X_SUBPRJ_PPL_ETC_RAWCOST_PC      => null
                      ,X_SUBPRJ_EQPMT_ETC_RAWCOST_TC    => null
                      ,X_SUBPRJ_EQPMT_ETC_RAWCOST_FC    => null
                      ,X_SUBPRJ_EQPMT_ETC_RAWCOST_PC    => null
            );

          IF Fnd_Msg_Pub.count_msg > 0 THEN
               RAISE  FND_API.G_EXC_ERROR;
          END IF;

            IF g1_debug_mode  = 'Y' THEN
                 pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'INSERTED IN PPR', x_Log_Level=> 3);
            END IF;

        ELSE
            --update progress rollup
         --This case is not possible for Assignments but the code has been kept.
            IF g1_debug_mode  = 'Y' THEN
                 pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'UPDATING PPR', x_Log_Level=> 3);
            END IF;

            PA_PROGRESS_ROLLUP_PKG.UPDATE_ROW(
                       X_PROGRESS_ROLLUP_ID              => l_PROGRESS_ROLLUP_ID
                      ,X_PROJECT_ID                      => p_project_id
                      --,X_OBJECT_ID                       => l_assignment_id  --bug# 3764224 Changes for RLM
                      ,X_OBJECT_ID                       => l_resource_list_member_id
                      ,X_OBJECT_TYPE                     => l_object_type
                      ,X_AS_OF_DATE                      => p_as_of_date
                ,X_OBJECT_VERSION_ID          => l_object_version_id
                      ,X_LAST_UPDATE_DATE                => SYSDATE
                      ,X_LAST_UPDATED_BY                 => l_user_id
                ,X_PROGRESS_STATUS_CODE            => l_rollup_progress_status
                      ,X_LAST_UPDATE_LOGIN               => l_login_id
                      ,X_INCREMENTAL_WORK_QTY            => l_INCREMENTAL_WORK_QTY
                      ,X_CUMULATIVE_WORK_QTY             => l_CUMULATIVE_WORK_QTY
                      ,X_BASE_PERCENT_COMPLETE           => l_BASE_PERCENT_COMPLETE
                      ,X_EFF_ROLLUP_PERCENT_COMP         => l_EFF_ROLLUP_PERCENT_COMP
                      ,X_COMPLETED_PERCENTAGE            => l_rollup_completed_percentage
                ,X_ESTIMATED_START_DATE            => l_estimated_start_date
                      ,X_ESTIMATED_FINISH_DATE           => l_estimated_finish_date
                      ,X_ACTUAL_START_DATE               => l_actual_start_date
                      ,X_ACTUAL_FINISH_DATE              => l_actual_finish_date
                      ,X_EST_REMAINING_EFFORT            => l_ppl_etc_effort  -- need to populate the buckets
                      ,X_BASE_PERCENT_COMP_DERIV_CODE    => l_BASE_PERCENT_COMP_DERIV_CODE
                      ,X_BASE_PROGRESS_STATUS_CODE       => l_date_override_flag -- 4533112 l_BASE_PROGRESS_STATUS_CODE
                      ,X_EFF_ROLLUP_PROG_STAT_CODE       => l_EFF_ROLLUP_PROG_STAT_CODE
                ,X_RECORD_VERSION_NUMBER           => l_rollup_rec_ver_number
                      ,x_percent_complete_id             => l_percent_complete_id
                      ,X_STRUCTURE_TYPE                  => p_structure_type
                      ,X_PROJ_ELEMENT_ID                 => p_task_id
                      ,X_STRUCTURE_VERSION_ID            => l_structure_version_id
                      ,X_PPL_ACT_EFFORT_TO_DATE         => l_ppl_act_effort_to_date
                      ,X_EQPMT_ACT_EFFORT_TO_DATE  => l_eqpmt_act_effort_to_date
                      ,X_EQPMT_ETC_EFFORT                => l_eqpmt_etc_effort
                      ,X_OTH_ACT_COST_TO_DATE_TC   => l_oth_act_bur_cost_to_date_tc
                      ,X_OTH_ACT_COST_TO_DATE_FC   => l_oth_act_bur_cost_to_date_fc
                      ,X_OTH_ACT_COST_TO_DATE_PC   => l_oth_act_bur_cost_to_date_pc
                      ,X_OTH_ETC_COST_TC                 => l_oth_etc_bur_cost_tc
                      ,X_OTH_ETC_COST_FC                 => l_oth_etc_bur_cost_fc
                      ,X_OTH_ETC_COST_PC                 => l_oth_etc_bur_cost_pc
                      ,X_PPL_ACT_COST_TO_DATE_TC   => l_ppl_act_bur_cost_to_date_tc
                      ,X_PPL_ACT_COST_TO_DATE_FC   => l_ppl_act_bur_cost_to_date_fc
                      ,X_PPL_ACT_COST_TO_DATE_PC   => l_ppl_act_bur_cost_to_date_pc
                      ,X_PPL_ETC_COST_TC                 => l_ppl_etc_bur_cost_tc
                      ,X_PPL_ETC_COST_FC                 => l_ppl_etc_bur_cost_fc
                      ,X_PPL_ETC_COST_PC                 => l_ppl_etc_bur_cost_pc
                      ,X_EQPMT_ACT_COST_TO_DATE_TC      => l_eqp_act_bur_cost_to_date_tc
                      ,X_EQPMT_ACT_COST_TO_DATE_FC      => l_eqp_act_bur_cost_to_date_fc
                      ,X_EQPMT_ACT_COST_TO_DATE_PC      => l_eqp_act_bur_cost_to_date_pc
                      ,X_EQPMT_ETC_COST_TC               => l_eqpmt_etc_bur_cost_tc
                      ,X_EQPMT_ETC_COST_FC               => l_eqpmt_etc_bur_cost_fc
                      ,X_EQPMT_ETC_COST_PC               => l_eqpmt_etc_bur_cost_pc
                      ,X_EARNED_VALUE                    => null
                      ,X_TASK_WT_BASIS_CODE              => null
                      ,X_SUBPRJ_PPL_ACT_EFFORT           => null
                      ,X_SUBPRJ_EQPMT_ACT_EFFORT         => null
                      ,X_SUBPRJ_PPL_ETC_EFFORT           => null
                      ,X_SUBPRJ_EQPMT_ETC_EFFORT         => null
                      ,X_SBPJ_OTH_ACT_COST_TO_DATE_TC    => null
                      ,X_SBPJ_OTH_ACT_COST_TO_DATE_FC    => null
                      ,X_SBPJ_OTH_ACT_COST_TO_DATE_PC    => null
                      ,X_SUBPRJ_PPL_ACT_COST_TC          => null
                      ,X_SUBPRJ_PPL_ACT_COST_FC          => null
                      ,X_SUBPRJ_PPL_ACT_COST_PC          => null
                      ,X_SUBPRJ_EQPMT_ACT_COST_TC        => null
                      ,X_SUBPRJ_EQPMT_ACT_COST_FC        => null
                      ,X_SUBPRJ_EQPMT_ACT_COST_PC        => null
                      ,X_SUBPRJ_OTH_ETC_COST_TC          => null
                      ,X_SUBPRJ_OTH_ETC_COST_FC          => null
                      ,X_SUBPRJ_OTH_ETC_COST_PC          => null
                      ,X_SUBPRJ_PPL_ETC_COST_TC          => null
                      ,X_SUBPRJ_PPL_ETC_COST_FC          => null
                      ,X_SUBPRJ_PPL_ETC_COST_PC          => null
                      ,X_SUBPRJ_EQPMT_ETC_COST_TC        => null
                      ,X_SUBPRJ_EQPMT_ETC_COST_FC        => null
                      ,X_SUBPRJ_EQPMT_ETC_COST_PC        => null
                      ,X_SUBPRJ_EARNED_VALUE             => null
                ,X_CURRENT_FLAG               => l_rollup_current_flag -- Bug 3879461 l_current_flag
                ,X_PROJFUNC_COST_RATE_TYPE         => l_projfunc_cost_rate_type
                ,X_PROJFUNC_COST_EXCHANGE_RATE     => l_projfunc_cost_exch_rate
                ,X_PROJFUNC_COST_RATE_DATE         => l_projfunc_cost_rate_date
                ,X_PROJ_COST_RATE_TYPE             => l_project_rate_type
                ,X_PROJ_COST_EXCHANGE_RATE         => l_project_exch_rate
                ,X_PROJ_COST_RATE_DATE             => l_project_rate_date
                ,X_TXN_CURRENCY_CODE             =>  l_txn_currency_code -- Fix for Bug # 3988457.
						     -- p_txn_currency_code    --maansari4/30
                ,X_PROG_PA_PERIOD_NAME             => l_prog_pa_period_name
                ,X_PROG_GL_PERIOD_NAME        => l_prog_gl_period_name
                --bug 3608801
                      ,X_OTH_QUANTITY_TO_DATE            => l_oth_quantity_to_date -- bug no.3608801
                      ,X_OTH_ETC_QUANTITY                => l_oth_etc_quantity
                --bug 3608801
                      ,X_OTH_ACT_RAWCOST_TO_DATE_TC     => l_oth_act_raw_cost_to_date_tc
                      ,X_OTH_ACT_RAWCOST_TO_DATE_FC     => l_oth_act_raw_cost_to_date_fc
                      ,X_OTH_ACT_RAWCOST_TO_DATE_PC     => l_oth_act_raw_cost_to_date_pc
                      ,X_OTH_ETC_RAWCOST_TC        => l_oth_etc_raw_cost_tc
                      ,X_OTH_ETC_RAWCOST_FC        => l_oth_etc_raw_cost_fc
                      ,X_OTH_ETC_RAWCOST_PC        => l_oth_etc_raw_cost_pc
                      ,X_PPL_ACT_RAWCOST_TO_DATE_TC     => l_ppl_act_raw_cost_to_date_tc
                      ,X_PPL_ACT_RAWCOST_TO_DATE_FC     => l_ppl_act_raw_cost_to_date_fc
                      ,X_PPL_ACT_RAWCOST_TO_DATE_PC     => l_ppl_act_raw_cost_to_date_pc
                      ,X_PPL_ETC_RAWCOST_TC        => l_ppl_etc_raw_cost_tc
                      ,X_PPL_ETC_RAWCOST_FC        => l_ppl_etc_raw_cost_fc
                      ,X_PPL_ETC_RAWCOST_PC        => l_ppl_etc_raw_cost_pc
                      ,X_EQPMT_ACT_RAWCOST_TO_DATE_TC   => l_eqp_act_raw_cost_to_date_tc
                      ,X_EQPMT_ACT_RAWCOST_TO_DATE_FC   => l_eqp_act_raw_cost_to_date_fc
                      ,X_EQPMT_ACT_RAWCOST_TO_DATE_PC   => l_eqp_act_raw_cost_to_date_pc
                      ,X_EQPMT_ETC_RAWCOST_TC           => l_eqpmt_etc_raw_cost_tc
                      ,X_EQPMT_ETC_RAWCOST_FC           => l_eqpmt_etc_raw_cost_fc
                      ,X_EQPMT_ETC_RAWCOST_PC           => l_eqpmt_etc_raw_cost_pc
                      ,X_SP_OTH_ACT_RAWCOST_TODATE_TC   => null
                      ,X_SP_OTH_ACT_RAWCOST_TODATE_FC   => null
                      ,X_SP_OTH_ACT_RAWCOST_TODATE_PC   => null
                      ,X_SUBPRJ_PPL_ACT_RAWCOST_TC      => null
                      ,X_SUBPRJ_PPL_ACT_RAWCOST_FC      => null
                      ,X_SUBPRJ_PPL_ACT_RAWCOST_PC      => null
                      ,X_SUBPRJ_EQPMT_ACT_RAWCOST_TC    => null
                      ,X_SUBPRJ_EQPMT_ACT_RAWCOST_FC    => null
                      ,X_SUBPRJ_EQPMT_ACT_RAWCOST_PC    => null
                      ,X_SUBPRJ_OTH_ETC_RAWCOST_TC      => null
                      ,X_SUBPRJ_OTH_ETC_RAWCOST_FC      => null
                      ,X_SUBPRJ_OTH_ETC_RAWCOST_PC      => null
                      ,X_SUBPRJ_PPL_ETC_RAWCOST_TC      => null
                      ,X_SUBPRJ_PPL_ETC_RAWCOST_FC      => null
                      ,X_SUBPRJ_PPL_ETC_RAWCOST_PC      => null
                      ,X_SUBPRJ_EQPMT_ETC_RAWCOST_TC    => null
                      ,X_SUBPRJ_EQPMT_ETC_RAWCOST_FC    => null
                      ,X_SUBPRJ_EQPMT_ETC_RAWCOST_PC    => null
            );
          IF Fnd_Msg_Pub.count_msg > 0 THEN
               RAISE  FND_API.G_EXC_ERROR;
          END IF;


        END IF;

    ELSIF l_db_action = 'UPDATE'
    THEN
        IF  l_working_aod IS NOT NULL
        THEN
            l_aod := l_working_aod;
        ELSE
            l_aod := p_as_of_date;
        END IF;

	-- Bug 3879461 : Temporary getting percent complete id and record version number from database
	-- So no locking.
	-- There is issue in UI, after calling API under Recalculate, it should incrment the VO record version number

--        IF p_percent_complete_id IS NULL OR p_percent_complete_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--        THEN
            l_percent_complete_id := PA_PROGRESS_UTILS.get_ppc_id(
                                      p_project_id        => p_project_id
                                     --,p_object_id         => l_assignment_id  --bug# 3764224 Changes for RLM
                                     ,p_object_id         => l_resource_list_member_id
                                     ,p_object_type       => l_object_type
                         ,p_object_version_id => l_object_version_id
                                     ,p_as_of_date        => l_aod
                         ,p_structure_type    => p_structure_type
			 ,p_task_id            => p_task_id                   --bug# 3764224 Added for RLM
                                     );
           -- FPM Dev CR 3 Getting Record Version Number too
        BEGIN
          SELECT record_version_number into l_record_version_number
          FROM pa_percent_completes
          where percent_complete_id = l_percent_complete_id;
        END;

  --      ELSE
--           l_percent_complete_id := p_percent_complete_id;
  --      l_record_version_number := p_record_version_number;
    --    END IF;

        IF g1_debug_mode  = 'Y' THEN
           pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_percent_complete_id: '||l_percent_complete_id, x_Log_Level=> 3);
        END IF;


        PA_PERCENT_COMPLETES_PKG.UPDATE_ROW(
                       p_TASK_ID                 => l_task_id
                      ,p_DATE_COMPUTED           => p_as_of_date
                      ,p_LAST_UPDATE_DATE        => SYSDATE
                      ,p_LAST_UPDATED_BY         => l_user_id
                      ,p_LAST_UPDATE_LOGIN       => l_login_id
                ,p_COMPLETED_PERCENTAGE    => l_percent_complete
                      ,p_DESCRIPTION             => l_brief_overview
                ,p_PM_PRODUCT_CODE         => l_pm_product_code
                ,p_CURRENT_FLAG            => l_current_flag
                ,p_PERCENT_COMPLETE_ID     => l_percent_complete_id
                      ,p_project_id              => p_project_id
                      ,p_OBJECT_TYPE             => l_object_type
                      --,p_OBJECT_ID               => l_assignment_id  --bug# 3764224 Changes for RLM
                      ,p_OBJECT_ID               => l_resource_list_member_id
                ,p_OBJECT_VERSION_ID       => l_object_version_id
                ,p_PROGRESS_STATUS_CODE    => l_progress_status_code
                      ,p_ACTUAL_START_DATE       => l_actual_start_date
                      ,p_ACTUAL_FINISH_DATE      => l_actual_finish_date
                      ,p_ESTIMATED_START_DATE    => l_estimated_start_date
                      ,p_ESTIMATED_FINISH_DATE   => l_estimated_finish_date
                      ,p_PUBLISHED_FLAG          => l_published_flag
                      ,p_PUBLISHED_BY_PARTY_ID   => l_published_by_party_id
                      ,p_PROGRESS_COMMENT        => l_progress_comment
                      ,p_HISTORY_FLAG            => 'N'
                ,p_status_code             => l_task_status
                      ,p_RECORD_VERSION_NUMBER   => l_record_version_number
                      ,p_ATTRIBUTE_CATEGORY      => null
                      ,p_ATTRIBUTE1              => null
                      ,p_ATTRIBUTE2              => null
                      ,p_ATTRIBUTE3              => null
                      ,p_ATTRIBUTE4              => null
                      ,p_ATTRIBUTE5              => null
                      ,p_ATTRIBUTE6              => null
                      ,p_ATTRIBUTE7              => null
                      ,p_ATTRIBUTE8              => null
                      ,p_ATTRIBUTE9              => null
                      ,p_ATTRIBUTE10             => null
                      ,p_ATTRIBUTE11             => null
                      ,p_ATTRIBUTE12             => null
                      ,p_ATTRIBUTE13             => null
                      ,p_ATTRIBUTE14             => null
                      ,p_ATTRIBUTE15             => null
                ,p_structure_type        => p_structure_type

        );
          IF Fnd_Msg_Pub.count_msg > 0 THEN
               RAISE  FND_API.G_EXC_ERROR;
          END IF;



        --update progress rollup
        l_PROGRESS_ROLLUP_ID := PA_PROGRESS_UTILS.get_prog_rollup_id(
                                   p_project_id   => p_project_id
                                  --,p_object_id    => l_assignment_id   --bug# 3764224 Changes for RLM
                                  ,p_object_id    => l_resource_list_member_id
                                  ,p_object_type  => l_object_type
                                  ,p_object_version_id => l_object_version_id
                                  ,p_as_of_date   => l_aod -- FPM Dev CR 3 : Using l_aod instead of p_as_of_date
                      ,p_structure_type => p_structure_type
                      ,p_structure_version_id => l_structure_version_id
				  ,p_action                 => p_action -- Bug 3879461
                                  ,x_record_version_number => l_rollup_rec_ver_number
				  ,p_proj_element_id      => p_task_id   --bug# 3764224 Added for RLM
                                );

        IF g1_debug_mode  = 'Y' THEN
             pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'l_PROGRESS_ROLLUP_ID: '||l_PROGRESS_ROLLUP_ID, x_Log_Level=> 3);
        END IF;


        IF l_PROGRESS_ROLLUP_ID IS NOT NULL
        THEN
            PA_PROGRESS_ROLLUP_PKG.UPDATE_ROW(
                       X_PROGRESS_ROLLUP_ID              => l_PROGRESS_ROLLUP_ID
                      ,X_PROJECT_ID                      => p_project_id
                      --,X_OBJECT_ID                       => l_assignment_id   --bug# 3764224 Changes for RLM
                      ,X_OBJECT_ID                       => l_resource_list_member_id
                      ,X_OBJECT_TYPE                     => l_object_type
                      ,X_AS_OF_DATE                      => p_as_of_date
                ,X_OBJECT_VERSION_ID          => l_object_version_id
                      ,X_LAST_UPDATE_DATE                => SYSDATE
                      ,X_LAST_UPDATED_BY                 => l_user_id
                ,X_PROGRESS_STATUS_CODE            => l_rollup_progress_status
                      ,X_LAST_UPDATE_LOGIN               => l_login_id
                      ,X_INCREMENTAL_WORK_QTY            => l_INCREMENTAL_WORK_QTY
                      ,X_CUMULATIVE_WORK_QTY             => l_CUMULATIVE_WORK_QTY
                      ,X_BASE_PERCENT_COMPLETE           => l_BASE_PERCENT_COMPLETE
                      ,X_EFF_ROLLUP_PERCENT_COMP         => l_EFF_ROLLUP_PERCENT_COMP
                      ,X_COMPLETED_PERCENTAGE            => l_rollup_completed_percentage
                ,X_ESTIMATED_START_DATE            => l_estimated_start_date
                      ,X_ESTIMATED_FINISH_DATE           => l_estimated_finish_date
                      ,X_ACTUAL_START_DATE               => l_actual_start_date
                      ,X_ACTUAL_FINISH_DATE              => l_actual_finish_date
                      ,X_EST_REMAINING_EFFORT            => l_ppl_etc_effort  -- need to populate the buckets
                      ,X_BASE_PERCENT_COMP_DERIV_CODE    => l_BASE_PERCENT_COMP_DERIV_CODE
                      ,X_BASE_PROGRESS_STATUS_CODE       => l_date_override_flag -- 4533112 l_BASE_PROGRESS_STATUS_CODE
                      ,X_EFF_ROLLUP_PROG_STAT_CODE       => l_EFF_ROLLUP_PROG_STAT_CODE
                ,X_RECORD_VERSION_NUMBER           => l_rollup_rec_ver_number
                      ,x_percent_complete_id             => l_percent_complete_id
                      ,X_STRUCTURE_TYPE                  => p_structure_type
                      ,X_PROJ_ELEMENT_ID                 => p_task_id
                      ,X_STRUCTURE_VERSION_ID            => l_structure_version_id
                      ,X_PPL_ACT_EFFORT_TO_DATE         => l_ppl_act_effort_to_date
                      ,X_EQPMT_ACT_EFFORT_TO_DATE  => l_eqpmt_act_effort_to_date
                      ,X_EQPMT_ETC_EFFORT                => l_eqpmt_etc_effort
                      ,X_OTH_ACT_COST_TO_DATE_TC   => l_oth_act_bur_cost_to_date_tc
                      ,X_OTH_ACT_COST_TO_DATE_FC   => l_oth_act_bur_cost_to_date_fc
                      ,X_OTH_ACT_COST_TO_DATE_PC   => l_oth_act_bur_cost_to_date_pc
                      ,X_OTH_ETC_COST_TC                 => l_oth_etc_bur_cost_tc
                      ,X_OTH_ETC_COST_FC                 => l_oth_etc_bur_cost_fc
                      ,X_OTH_ETC_COST_PC                 => l_oth_etc_bur_cost_pc
                      ,X_PPL_ACT_COST_TO_DATE_TC   => l_ppl_act_bur_cost_to_date_tc
                      ,X_PPL_ACT_COST_TO_DATE_FC   => l_ppl_act_bur_cost_to_date_fc
                      ,X_PPL_ACT_COST_TO_DATE_PC   => l_ppl_act_bur_cost_to_date_pc
                      ,X_PPL_ETC_COST_TC                 => l_ppl_etc_bur_cost_tc
                      ,X_PPL_ETC_COST_FC                 => l_ppl_etc_bur_cost_fc
                      ,X_PPL_ETC_COST_PC                 => l_ppl_etc_bur_cost_pc
                      ,X_EQPMT_ACT_COST_TO_DATE_TC      => l_eqp_act_bur_cost_to_date_tc
                      ,X_EQPMT_ACT_COST_TO_DATE_FC      => l_eqp_act_bur_cost_to_date_fc
                      ,X_EQPMT_ACT_COST_TO_DATE_PC      => l_eqp_act_bur_cost_to_date_pc
                      ,X_EQPMT_ETC_COST_TC               => l_eqpmt_etc_bur_cost_tc
                      ,X_EQPMT_ETC_COST_FC               => l_eqpmt_etc_bur_cost_fc
                      ,X_EQPMT_ETC_COST_PC               => l_eqpmt_etc_bur_cost_pc
                      ,X_EARNED_VALUE                    => null
                      ,X_TASK_WT_BASIS_CODE              => null
                      ,X_SUBPRJ_PPL_ACT_EFFORT           => null
                      ,X_SUBPRJ_EQPMT_ACT_EFFORT         => null
                      ,X_SUBPRJ_PPL_ETC_EFFORT           => null
                      ,X_SUBPRJ_EQPMT_ETC_EFFORT         => null
                      ,X_SBPJ_OTH_ACT_COST_TO_DATE_TC    => null
                      ,X_SBPJ_OTH_ACT_COST_TO_DATE_FC    => null
                      ,X_SBPJ_OTH_ACT_COST_TO_DATE_PC    => null
                      ,X_SUBPRJ_PPL_ACT_COST_TC          => null
                      ,X_SUBPRJ_PPL_ACT_COST_FC          => null
                      ,X_SUBPRJ_PPL_ACT_COST_PC          => null
                      ,X_SUBPRJ_EQPMT_ACT_COST_TC        => null
                      ,X_SUBPRJ_EQPMT_ACT_COST_FC        => null
                      ,X_SUBPRJ_EQPMT_ACT_COST_PC        => null
                      ,X_SUBPRJ_OTH_ETC_COST_TC          => null
                      ,X_SUBPRJ_OTH_ETC_COST_FC          => null
                      ,X_SUBPRJ_OTH_ETC_COST_PC          => null
                      ,X_SUBPRJ_PPL_ETC_COST_TC          => null
                      ,X_SUBPRJ_PPL_ETC_COST_FC          => null
                      ,X_SUBPRJ_PPL_ETC_COST_PC          => null
                      ,X_SUBPRJ_EQPMT_ETC_COST_TC        => null
                      ,X_SUBPRJ_EQPMT_ETC_COST_FC        => null
                      ,X_SUBPRJ_EQPMT_ETC_COST_PC        => null
                      ,X_SUBPRJ_EARNED_VALUE             => null
                ,X_CURRENT_FLAG               => l_rollup_current_flag -- Bug 3879461 l_current_flag
                ,X_PROJFUNC_COST_RATE_TYPE         => l_projfunc_cost_rate_type
                ,X_PROJFUNC_COST_EXCHANGE_RATE     => l_projfunc_cost_exch_rate
                ,X_PROJFUNC_COST_RATE_DATE         => l_projfunc_cost_rate_date
                ,X_PROJ_COST_RATE_TYPE             => l_project_rate_type
                ,X_PROJ_COST_EXCHANGE_RATE         => l_project_exch_rate
                ,X_PROJ_COST_RATE_DATE             => l_project_rate_date
                ,X_TXN_CURRENCY_CODE             =>  l_txn_currency_code -- Fix for Bug # 3988457.
						     -- p_txn_currency_code    --maansari4/30
                ,X_PROG_PA_PERIOD_NAME             => l_prog_pa_period_name
                ,X_PROG_GL_PERIOD_NAME        => l_prog_gl_period_name
                --bug 3608801
                      ,X_OTH_QUANTITY_TO_DATE            => l_oth_quantity_to_date  -- bug no.3608801
                      ,X_OTH_ETC_QUANTITY                => l_oth_etc_quantity
                --bug 3608801
                      ,X_OTH_ACT_RAWCOST_TO_DATE_TC     => l_oth_act_raw_cost_to_date_tc
                      ,X_OTH_ACT_RAWCOST_TO_DATE_FC     => l_oth_act_raw_cost_to_date_fc
                      ,X_OTH_ACT_RAWCOST_TO_DATE_PC     => l_oth_act_raw_cost_to_date_pc
                      ,X_OTH_ETC_RAWCOST_TC        => l_oth_etc_raw_cost_tc
                      ,X_OTH_ETC_RAWCOST_FC        => l_oth_etc_raw_cost_fc
                      ,X_OTH_ETC_RAWCOST_PC        => l_oth_etc_raw_cost_pc
                      ,X_PPL_ACT_RAWCOST_TO_DATE_TC     => l_ppl_act_raw_cost_to_date_tc
                      ,X_PPL_ACT_RAWCOST_TO_DATE_FC     => l_ppl_act_raw_cost_to_date_fc
                      ,X_PPL_ACT_RAWCOST_TO_DATE_PC     => l_ppl_act_raw_cost_to_date_pc
                      ,X_PPL_ETC_RAWCOST_TC        => l_ppl_etc_raw_cost_tc
                      ,X_PPL_ETC_RAWCOST_FC        => l_ppl_etc_raw_cost_fc
                      ,X_PPL_ETC_RAWCOST_PC        => l_ppl_etc_raw_cost_pc
                      ,X_EQPMT_ACT_RAWCOST_TO_DATE_TC   => l_eqp_act_raw_cost_to_date_tc
                      ,X_EQPMT_ACT_RAWCOST_TO_DATE_FC   => l_eqp_act_raw_cost_to_date_fc
                      ,X_EQPMT_ACT_RAWCOST_TO_DATE_PC   => l_eqp_act_raw_cost_to_date_pc
                      ,X_EQPMT_ETC_RAWCOST_TC           => l_eqpmt_etc_raw_cost_tc
                      ,X_EQPMT_ETC_RAWCOST_FC           => l_eqpmt_etc_raw_cost_fc
                      ,X_EQPMT_ETC_RAWCOST_PC           => l_eqpmt_etc_raw_cost_pc
                ,X_SP_OTH_ACT_RAWCOST_TODATE_TC    => null
                      ,X_SP_OTH_ACT_RAWCOST_TODATE_FC   => null
                      ,X_SP_OTH_ACT_RAWCOST_TODATE_PC   => null
                      ,X_SUBPRJ_PPL_ACT_RAWCOST_TC      => null
                      ,X_SUBPRJ_PPL_ACT_RAWCOST_FC      => null
                      ,X_SUBPRJ_PPL_ACT_RAWCOST_PC      => null
                      ,X_SUBPRJ_EQPMT_ACT_RAWCOST_TC    => null
                      ,X_SUBPRJ_EQPMT_ACT_RAWCOST_FC    => null
                      ,X_SUBPRJ_EQPMT_ACT_RAWCOST_PC    => null
                      ,X_SUBPRJ_OTH_ETC_RAWCOST_TC      => null
                      ,X_SUBPRJ_OTH_ETC_RAWCOST_FC      => null
                      ,X_SUBPRJ_OTH_ETC_RAWCOST_PC      => null
                      ,X_SUBPRJ_PPL_ETC_RAWCOST_TC      => null
                      ,X_SUBPRJ_PPL_ETC_RAWCOST_FC      => null
                      ,X_SUBPRJ_PPL_ETC_RAWCOST_PC      => null
                      ,X_SUBPRJ_EQPMT_ETC_RAWCOST_TC    => null
                      ,X_SUBPRJ_EQPMT_ETC_RAWCOST_FC    => null
                      ,X_SUBPRJ_EQPMT_ETC_RAWCOST_PC    => null
            );
          IF Fnd_Msg_Pub.count_msg > 0 THEN
               RAISE  FND_API.G_EXC_ERROR;
          END IF;

        ELSE
            PA_PROGRESS_ROLLUP_PKG.INSERT_ROW(
                       X_PROGRESS_ROLLUP_ID              => l_PROGRESS_ROLLUP_ID
                      ,X_PROJECT_ID                      => p_project_id
                      --,X_OBJECT_ID                       => l_assignment_id  --bug# 3764224 Changes for RLM
                      ,X_OBJECT_ID                       => l_resource_list_member_id
                      ,X_OBJECT_TYPE                     => l_object_type
                      ,X_AS_OF_DATE                      => p_as_of_date
                ,X_OBJECT_VERSION_ID          => l_object_version_id
                      ,X_LAST_UPDATE_DATE                => SYSDATE
                      ,X_LAST_UPDATED_BY                 => l_user_id
                      ,X_CREATION_DATE                   => SYSDATE
                      ,X_CREATED_BY                      => l_user_id
                ,X_PROGRESS_STATUS_CODE            => l_rollup_progress_status
                      ,X_LAST_UPDATE_LOGIN               => l_login_id
                      ,X_INCREMENTAL_WORK_QTY            => l_INCREMENTAL_WORK_QTY
                      ,X_CUMULATIVE_WORK_QTY             => l_CUMULATIVE_WORK_QTY
                      ,X_BASE_PERCENT_COMPLETE           => l_BASE_PERCENT_COMPLETE
                      ,X_EFF_ROLLUP_PERCENT_COMP         => l_EFF_ROLLUP_PERCENT_COMP
                      ,X_COMPLETED_PERCENTAGE            => l_rollup_completed_percentage
                      ,X_ESTIMATED_START_DATE            => l_estimated_start_date
                      ,X_ESTIMATED_FINISH_DATE           => l_estimated_finish_date
                      ,X_ACTUAL_START_DATE               => l_actual_start_date
                      ,X_ACTUAL_FINISH_DATE              => l_actual_finish_date
                      ,X_EST_REMAINING_EFFORT            => l_ppl_etc_effort
                      ,X_BASE_PERCENT_COMP_DERIV_CODE    => l_BASE_PERCENT_COMP_DERIV_CODE
                      ,X_BASE_PROGRESS_STATUS_CODE       => l_date_override_flag -- 4533112 l_BASE_PROGRESS_STATUS_CODE
                      ,X_EFF_ROLLUP_PROG_STAT_CODE       => l_EFF_ROLLUP_PROG_STAT_CODE
                ,x_percent_complete_id             => l_percent_complete_id
                ,X_STRUCTURE_TYPE                  => p_structure_type
                ,X_PROJ_ELEMENT_ID                 => p_task_id
                      ,X_STRUCTURE_VERSION_ID            => l_structure_version_id
                      ,X_PPL_ACT_EFFORT_TO_DATE          => l_ppl_act_effort_to_date
                      ,X_EQPMT_ACT_EFFORT_TO_DATE        => l_eqpmt_act_effort_to_date
                      ,X_EQPMT_ETC_EFFORT                => l_eqpmt_etc_effort
                      ,X_OTH_ACT_COST_TO_DATE_TC   => l_oth_act_bur_cost_to_date_tc
                      ,X_OTH_ACT_COST_TO_DATE_FC   => l_oth_act_bur_cost_to_date_fc
                      ,X_OTH_ACT_COST_TO_DATE_PC   => l_oth_act_bur_cost_to_date_pc
                      ,X_OTH_ETC_COST_TC                 => l_oth_etc_bur_cost_tc
                      ,X_OTH_ETC_COST_FC                 => l_oth_etc_bur_cost_fc
                      ,X_OTH_ETC_COST_PC                 => l_oth_etc_bur_cost_pc
                      ,X_PPL_ACT_COST_TO_DATE_TC   => l_ppl_act_bur_cost_to_date_tc
                      ,X_PPL_ACT_COST_TO_DATE_FC   => l_ppl_act_bur_cost_to_date_fc
                      ,X_PPL_ACT_COST_TO_DATE_PC   => l_ppl_act_bur_cost_to_date_pc
                      ,X_PPL_ETC_COST_TC                 => l_ppl_etc_bur_cost_tc
                      ,X_PPL_ETC_COST_FC                 => l_ppl_etc_bur_cost_fc
                      ,X_PPL_ETC_COST_PC                 => l_ppl_etc_bur_cost_pc
                      ,X_EQPMT_ACT_COST_TO_DATE_TC      => l_eqp_act_bur_cost_to_date_tc
                      ,X_EQPMT_ACT_COST_TO_DATE_FC      => l_eqp_act_bur_cost_to_date_fc
                      ,X_EQPMT_ACT_COST_TO_DATE_PC      => l_eqp_act_bur_cost_to_date_pc
                      ,X_EQPMT_ETC_COST_TC               => l_eqpmt_etc_bur_cost_tc
                      ,X_EQPMT_ETC_COST_FC               => l_eqpmt_etc_bur_cost_fc
                      ,X_EQPMT_ETC_COST_PC               => l_eqpmt_etc_bur_cost_pc
                      ,X_EARNED_VALUE                    => null
                      ,X_TASK_WT_BASIS_CODE              => null
                      ,X_SUBPRJ_PPL_ACT_EFFORT           => null
                      ,X_SUBPRJ_EQPMT_ACT_EFFORT         => null
                      ,X_SUBPRJ_PPL_ETC_EFFORT           => null
                      ,X_SUBPRJ_EQPMT_ETC_EFFORT         => null
                      ,X_SBPJ_OTH_ACT_COST_TO_DATE_TC    => null
                      ,X_SBPJ_OTH_ACT_COST_TO_DATE_FC    => null
                      ,X_SBPJ_OTH_ACT_COST_TO_DATE_PC    => null
                      ,X_SUBPRJ_PPL_ACT_COST_TC          => null
                      ,X_SUBPRJ_PPL_ACT_COST_FC          => null
                      ,X_SUBPRJ_PPL_ACT_COST_PC          => null
                      ,X_SUBPRJ_EQPMT_ACT_COST_TC        => null
                      ,X_SUBPRJ_EQPMT_ACT_COST_FC        => null
                      ,X_SUBPRJ_EQPMT_ACT_COST_PC        => null
                      ,X_SUBPRJ_OTH_ETC_COST_TC          => null
                      ,X_SUBPRJ_OTH_ETC_COST_FC          => null
                      ,X_SUBPRJ_OTH_ETC_COST_PC          => null
                      ,X_SUBPRJ_PPL_ETC_COST_TC          => null
                      ,X_SUBPRJ_PPL_ETC_COST_FC          => null
                      ,X_SUBPRJ_PPL_ETC_COST_PC          => null
                      ,X_SUBPRJ_EQPMT_ETC_COST_TC        => null
                      ,X_SUBPRJ_EQPMT_ETC_COST_FC        => null
                      ,X_SUBPRJ_EQPMT_ETC_COST_PC        => null
                ,X_SUBPRJ_EARNED_VALUE             => null
                ,X_CURRENT_FLAG               => l_rollup_current_flag -- Bug 3879461 l_current_flag
                ,X_PROJFUNC_COST_RATE_TYPE         => l_projfunc_cost_rate_type
                ,X_PROJFUNC_COST_EXCHANGE_RATE     => l_projfunc_cost_exch_rate
                ,X_PROJFUNC_COST_RATE_DATE         => l_projfunc_cost_rate_date
                ,X_PROJ_COST_RATE_TYPE             => l_project_rate_type
                ,X_PROJ_COST_EXCHANGE_RATE         => l_project_exch_rate
                ,X_PROJ_COST_RATE_DATE             => l_project_rate_date
                ,X_TXN_CURRENCY_CODE          =>  l_txn_currency_code -- Fix for Bug # 3988457.
						  -- p_txn_currency_code    --maansari4/30
                ,X_PROG_PA_PERIOD_NAME        => l_prog_pa_period_name
                ,X_PROG_GL_PERIOD_NAME        => l_prog_gl_period_name
                --bug 3608801
                      ,X_OTH_QUANTITY_TO_DATE            => l_oth_quantity_to_date   -- bug no.3608801
                      ,X_OTH_ETC_QUANTITY                => l_oth_etc_quantity
                --bug 3608801
                      ,X_OTH_ACT_RAWCOST_TO_DATE_TC     => l_oth_act_raw_cost_to_date_tc
                      ,X_OTH_ACT_RAWCOST_TO_DATE_FC     => l_oth_act_raw_cost_to_date_fc
                      ,X_OTH_ACT_RAWCOST_TO_DATE_PC     => l_oth_act_raw_cost_to_date_pc
                      ,X_OTH_ETC_RAWCOST_TC        => l_oth_etc_raw_cost_tc
                      ,X_OTH_ETC_RAWCOST_FC        => l_oth_etc_raw_cost_fc
                      ,X_OTH_ETC_RAWCOST_PC        => l_oth_etc_raw_cost_pc
                      ,X_PPL_ACT_RAWCOST_TO_DATE_TC     => l_ppl_act_raw_cost_to_date_tc
                      ,X_PPL_ACT_RAWCOST_TO_DATE_FC     => l_ppl_act_raw_cost_to_date_fc
                      ,X_PPL_ACT_RAWCOST_TO_DATE_PC     => l_ppl_act_raw_cost_to_date_pc
                      ,X_PPL_ETC_RAWCOST_TC        => l_ppl_etc_raw_cost_tc
                      ,X_PPL_ETC_RAWCOST_FC        => l_ppl_etc_raw_cost_fc
                      ,X_PPL_ETC_RAWCOST_PC        => l_ppl_etc_raw_cost_pc
                      ,X_EQPMT_ACT_RAWCOST_TO_DATE_TC   => l_eqp_act_raw_cost_to_date_tc
                      ,X_EQPMT_ACT_RAWCOST_TO_DATE_FC   => l_eqp_act_raw_cost_to_date_fc
                      ,X_EQPMT_ACT_RAWCOST_TO_DATE_PC   => l_eqp_act_raw_cost_to_date_pc
                      ,X_EQPMT_ETC_RAWCOST_TC           => l_eqpmt_etc_raw_cost_tc
                      ,X_EQPMT_ETC_RAWCOST_FC           => l_eqpmt_etc_raw_cost_fc
                      ,X_EQPMT_ETC_RAWCOST_PC           => l_eqpmt_etc_raw_cost_pc
                ,X_SP_OTH_ACT_RAWCOST_TODATE_TC    => null
                      ,X_SP_OTH_ACT_RAWCOST_TODATE_FC   => null
                      ,X_SP_OTH_ACT_RAWCOST_TODATE_PC   => null
                      ,X_SUBPRJ_PPL_ACT_RAWCOST_TC      => null
                      ,X_SUBPRJ_PPL_ACT_RAWCOST_FC      => null
                      ,X_SUBPRJ_PPL_ACT_RAWCOST_PC      => null
                      ,X_SUBPRJ_EQPMT_ACT_RAWCOST_TC    => null
                      ,X_SUBPRJ_EQPMT_ACT_RAWCOST_FC    => null
                      ,X_SUBPRJ_EQPMT_ACT_RAWCOST_PC    => null
                      ,X_SUBPRJ_OTH_ETC_RAWCOST_TC      => null
                      ,X_SUBPRJ_OTH_ETC_RAWCOST_FC      => null
                      ,X_SUBPRJ_OTH_ETC_RAWCOST_PC      => null
                      ,X_SUBPRJ_PPL_ETC_RAWCOST_TC      => null
                      ,X_SUBPRJ_PPL_ETC_RAWCOST_FC      => null
                      ,X_SUBPRJ_PPL_ETC_RAWCOST_PC      => null
                      ,X_SUBPRJ_EQPMT_ETC_RAWCOST_TC    => null
                      ,X_SUBPRJ_EQPMT_ETC_RAWCOST_FC    => null
                      ,X_SUBPRJ_EQPMT_ETC_RAWCOST_PC    => null
            );
          IF Fnd_Msg_Pub.count_msg > 0 THEN
               RAISE  FND_API.G_EXC_ERROR;
          END IF;

        END IF;

     IF g1_debug_mode  = 'Y' THEN
             pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'COMPLETED ', x_Log_Level=> 3);
        END IF;

    END IF;  --<l_db_action>


    -- FPM Dev CR 3 Begin

    --bug no.3595585 Satish start
    /*--bug no.3586648
    IF l_structure_sharing_code <> 'SHARE_FULL'
    THEN
         l_total_effort := nvl(l_ppl_act_effort_to_date,0) + nvl(l_ppl_etc_effort,0) + nvl(l_eqpmt_act_effort_to_date,0) + nvl(l_eqpmt_etc_effort,0);

         IF p_structure_type = 'WORKPLAN' AND p_progress_mode = 'FUTURE'
            AND l_total_effort > 0
            AND l_total_effort > p_planned_effort
            AND PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(p_project_id) = 'N'
            AND p_action = 'PUBLISH'
            AND l_rate_based_flag = 'Y'    --maansari7/6 bug 3742356
         THEN

            l_task_elem_version_id_tbl.extend(1);
            l_planned_people_effort_tbl.extend(1);
            l_planned_equip_effort_tbl.extend(1);
            l_resource_assignment_id_tbl.extend(1);
            l_resource_list_member_id_tbl.extend(1);
            l_resource_class_code_tbl.extend(1);
     --       l_start_date_tbl.extend(1);
     --       l_end_date_tbl.extend(1);

            l_task_elem_version_id_tbl(1)    := p_object_version_id;
            l_planned_people_effort_tbl(1)   := l_ppl_act_effort_to_date + l_ppl_etc_effort;
            l_planned_equip_effort_tbl(1)    := l_eqpmt_act_effort_to_date + l_eqpmt_etc_effort;
            l_resource_assignment_id_tbl(1)  := p_object_id;
            l_resource_list_member_id_tbl(1) := p_resource_list_member_id;
            l_resource_class_code_tbl(1)     := l_resource_class_code;      --maansari7/6 bug 3742356
     --       l_start_date_tbl(1)       := l_actual_start_date;
     --       l_end_date_tbl(1)         := l_actual_finish_date;

            BEGIN
             pa_fp_planning_transaction_pub.update_planning_transactions
             (
               p_context                      => 'WORKPLAN'
              ,p_struct_elem_version_id       => p_structure_version_id
              ,p_task_elem_version_id_tbl     => l_task_elem_version_id_tbl
              ,p_planned_people_effort_tbl    => l_planned_people_effort_tbl
              ,p_planned_equip_effort_tbl     => l_planned_equip_effort_tbl
              ,p_resource_assignment_id_tbl   => l_resource_assignment_id_tbl
              ,p_resource_list_member_id_tbl  => l_resource_list_member_id_tbl
              ,p_resource_class_code_tbl      => l_resource_class_code_tbl
     --            ,p_start_date_tbl               => l_start_date_tbl
     --            ,p_end_date_tbl                 => l_end_date_tbl
              ,x_return_status                => l_return_status
              ,x_msg_count                    => l_msg_count
              ,x_msg_data                     => l_msg_data
             );
            EXCEPTION
             WHEN OTHERS THEN
               fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_ASSIGNMENT_PROGRESS_PUB',
                              p_procedure_name => 'UPDATE_ASSIGNMENT_PROGRESS',
                              p_error_text     => SUBSTRB('pa_fp_planning_transaction_pub.update_planning_transactions:'||SQLERRM,1,240));
             RAISE FND_API.G_EXC_ERROR;
            END;
         END IF;
    END IF;*/
    --bug no.3595585 Satish end
    -- FPM Dev CR 3 End

    IF g1_debug_mode  = 'Y' THEN
           pa_debug.write(x_Module=>'PA_ASSIGNMENT_PROGRESS_PUB.UPDATE_ASSIGNMENT_PROGRESS', x_Msg => 'EXITING ', x_Log_Level=> 3);
    END IF;

EXCEPTION
 when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR;
      l_msg_count := Fnd_Msg_Pub.count_msg;

      if p_commit = FND_API.G_TRUE then
         rollback to UPDATE_ASSIGNMENT_PROGRESS;
      end if;

     IF l_msg_count = 1 AND x_msg_data IS NULL
      THEN
          Pa_Interface_Utils_Pub.get_messages
              ( p_encoded        => Fnd_Api.G_TRUE
              , p_msg_index      => 1
              , p_msg_count      => l_msg_count
              , p_msg_data       => l_msg_data
              , p_data           => l_data
              , p_msg_index_out  => l_msg_index_out);
          x_msg_data := l_data;
          x_msg_count := l_msg_count;
     ELSE
          x_msg_count := l_msg_count;
     END IF;

     when FND_API.G_EXC_UNEXPECTED_ERROR then
       x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
       x_msg_count     := 1;
       x_msg_data      := SQLERRM;

      if p_commit = FND_API.G_TRUE then
         rollback to UPDATE_ASSIGNMENT_PROGRESS;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_ASSIGNMENT_PROGRESS_PUB',
                              p_procedure_name => 'UPDATE_ASSIGNMENT_PROGRESS',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SUBSTRB(SQLERRM,1,240);
      if p_commit = FND_API.G_TRUE then
         rollback to UPDATE_DELIVERABLE_PROGRESS;
      end if;

      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_ASSIGNMENT_PROGRESS_PUB',
                              p_procedure_name => 'UPDATE_ASSIGNMENT_PROGRESS',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;


END UPDATE_ASSIGNMENT_PROGRESS;

END PA_ASSIGNMENT_PROGRESS_PUB;

/
