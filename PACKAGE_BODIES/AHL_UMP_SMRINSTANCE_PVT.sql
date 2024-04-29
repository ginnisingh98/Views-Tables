--------------------------------------------------------
--  DDL for Package Body AHL_UMP_SMRINSTANCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UMP_SMRINSTANCE_PVT" AS
/* $Header: AHLVSMRB.pls 120.9.12010000.3 2009/04/21 01:15:10 sikumar ship $ */

G_PKG_NAME   CONSTANT  VARCHAR2(30) := 'AHL_UMP_SMRINSTANCE_PVT';

-- FND Logging Constants
G_DEBUG_LEVEL       CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_DEBUG_PROC        CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
G_DEBUG_STMT        CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
G_DEBUG_UEXP        CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

-------------------------------
-- Declare Local Procedures --
-------------------------------
PROCEDURE populate_instances(
    p_module_type            IN            VARCHAR2,
    p_search_mr_instance_rec IN            AHL_UMP_SMRINSTANCE_PVT.Search_MRInstance_Rec_Type);


PROCEDURE populate_dependent_instances(
    p_module_type            IN            VARCHAR2,
    p_search_mr_instance_rec IN            AHL_UMP_SMRINSTANCE_PVT.Search_MRInstance_Rec_Type);

TYPE nbr_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

-------------------------------------
-- End Local Procedures Declaration--
-------------------------------------

------------------------
-- Define  Procedures --
------------------------
--------------------------------------------------------------------------------------------
-- Start of Comments --
--  Procedure name    : Search_MR_Instances
--  Type              : Private
--  Function          : This procedure fetches all the MR Instances based both at the instance level
--                      and the item level for the given search criteria.
--  Pre-reqs          :
--  Parameters        :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                      Required
--      p_init_msg_list                 IN      VARCHAR2                    Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2                    Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER                      Default  FND_API.G_VALID_LEVEL_FULL
--      p_default                       IN      VARCHAR2                    Default  FND_API.G_TRUE
--         Based on this flag, the API will set the default attributes.
--      p_module_type                   IN      VARCHAR2                    Default  NULL
--         This will be null.
--  Standard OUT Parameters :
--      x_return_status                 OUT NOCOPY VARCHAR2                    Required
--      x_msg_count                     OUT NOCOPY NUMBER                      Required
--      x_msg_data                      OUT NOCOPY VARCHAR2                    Required
--
--  Search_MR_Instances Parameters :
--      p_start_row                     IN      NUMBER                      Required
--         The row from which the search results table should be displayed.
--      p_rows_per_page                 IN      NUMBER                      Required
--         The number of rows to be displayed per page.
--      p_search_mr_instance_rec        IN      Search_MRInstance_Rec_Type  Required
--         The search criteria based on which the query needs to be run to
--         return the MR Instances.
--      x_results_mr_instance_tbl       OUT NOCOPY Results_MRInstance_Tbl_Type Required
--         List of all the MR Instances which match the search criteria entered.
--      x_results_count                 OUT NOCOPY NUMBER                      Required
--         The total count of the results returned from the entered search criteria.
--
--  Version :
--      Initial Version   1.0
--      Sunil Kumar redesigned and recoded. Performance optimized.
--
--  End of Comments.
--------------------------------------------------------------------------------------------

PROCEDURE Search_MR_Instances
   (
    p_api_version                   IN            NUMBER,
    p_init_msg_list                 IN            VARCHAR2  := FND_API.G_FALSE,
    p_commit                        IN            VARCHAR2  := FND_API.G_FALSE,
    p_validation_level              IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_default                       IN            VARCHAR2  := FND_API.G_TRUE,
    p_module_type                   IN            VARCHAR2  := NULL,
    p_start_row                     IN            NUMBER,
    p_rows_per_page                 IN            NUMBER,
    p_search_mr_instance_rec        IN            AHL_UMP_SMRINSTANCE_PVT.Search_MRInstance_Rec_Type,
    x_results_mr_instance_tbl       OUT NOCOPY    AHL_UMP_SMRINSTANCE_PVT.Results_MRInstance_Tbl_Type,
    x_results_count                 OUT NOCOPY    NUMBER,
    x_return_status                 OUT NOCOPY    VARCHAR2,
    x_msg_count                     OUT NOCOPY    NUMBER,
    x_msg_data                      OUT NOCOPY    VARCHAR2 ) IS

   l_api_version      CONSTANT NUMBER := 1.0;
   l_api_name         CONSTANT VARCHAR2(30) := 'Search_MR_Instances';

   -- Local Variable for the sql string.
   l_sql_string              VARCHAR2(30000);
   l_get_items_sql           VARCHAR2(4000);
   -- Local Variables for Instance Level Search queries
   l_all_csi_items_sql       VARCHAR2(4000);
   l_get_csi_ii_id_sql       VARCHAR2(4000);
   l_unit_effectivity_id   number;
   --Local Variable for iterating through the result set.
   l_counter NUMBER;
   --Local Variable for triggering the record to be picked.
   l_pick_record_flag boolean;
   --Local Variable for getting the row count.
   row_count NUMBER;
   --Fix for Bug 2745891
   l_early_exit_status boolean;
   -- Bind variable index and table
   l_bind_index     NUMBER;
   l_bindvar_tbl AHL_OSP_UTIL_PKG.ahl_conditions_tbl;
   -- dynamic cursor
   l_cur            AHL_OSP_UTIL_PKG.ahl_search_csr;
   -- Logging purposes
   l_sql_segment_count NUMBER;
   -- Added for deferral details.
   CURSOR ahl_defer_to_ue_csr(p_unit_effectivity_id IN NUMBER) IS
   SELECT unit_effectivity_id
   FROM ahl_unit_effectivities_b
   WHERE defer_from_ue_id = p_unit_effectivity_id
   AND rownum < 2;
   -- cursor to actually fecth details
   -- anraj: added UMP.cs_incident_id, UMP.cs_incident_number for bug#4133332
   CURSOR ump_details_csr(p_unit_effectivity_id IN NUMBER) IS
   SELECT UMP.program_type, UMP.Title, UMP.part_number, UMP.serial_number,
          -- R12: Fix for bug# 5231770.
          -- Due to CSI counter schema changes, the latest net_reading is
          -- no longer available in csi_cp_counters_v. Net_reading will be
          -- queried seperately to calculate uom_remain.
          -- In this cursor, UMP.due_counter_value will be retrieved instead.
          --(UMP.due_counter_value - nvl(UMP.net_reading,0)) uom_remain,
          UMP.due_counter_value uom_remain,
          UMP.counter_name, UMP.earliest_due_date, UMP.due_date, UMP.latest_due_date,
          UMP.tolerance, UMP.status_code, UMP.status, UMP.originator_title, UMP.dependant_title,
          UMP.unit_effectivity_id, UMP.mr_header_id, UMP.csi_item_instance_id, UMP.instance_number,
          UMP.mr_interval_id, UMP.unit_name, UMP.program_title, UMP.contract_number,
          UMP.defer_from_ue_id, UMP.object_type, UMP.counter_id, UMP.MANUALLY_PLANNED_FLAG,
          UMP.MANUALLY_PLANNED_DESC,
          UMP.cs_incident_id, UMP.cs_incident_number,
          -- added for bug# 6530920.
          UMP.orig_ue_instance_id
   FROM ahl_unit_effectivities_v UMP
   WHERE UMP.unit_effectivity_id = p_unit_effectivity_id;

   -- Added to fix bug# 2780716.
   l_counter_id  NUMBER;

   -- to get uom remain from a counter_id.
   -- Changed for R12 CSI Counter changes.
   CURSOR ump_ctr_name_csr (p_counter_id IN NUMBER) IS
   /* modified for uptake of IB changes 7374316.
   SELECT cc.counter_template_name counter_name,
          nvl(cv.net_reading,0) net_reading
   FROM csi_counter_values_v cv, csi_counters_vl cc
   WHERE cv.counter_id = cc.counter_id
     AND cv.counter_id = p_counter_id
     AND rownum < 2;
   */

   SELECT cc.counter_template_name counter_name,
          (select ccr.net_reading from csi_counter_readings ccr
           where ccr.counter_value_id = cc.CTR_VAL_MAX_SEQ_NO
             and nvl(ccr.disabled_flag,'N') = 'N')
   FROM csi_counters_vl cc
   WHERE cc.counter_id = p_counter_id;

   -- Added to fix bug number 3693957
   l_service_req_id NUMBER;
   l_service_req_num VARCHAR2(64);
   l_service_req_date DATE;

   l_scheduled_date DATE;
   l_visit_number VARCHAR2(80);

   --PDOKI Added for ER# 6333770
   l_visit_id   NUMBER;

/*
   -- 11.5.10CU2: Ignore Simulated visits.
   CURSOR ahl_visit_csr(p_ue_id IN NUMBER) IS
   SELECT vst.start_date_time, vst.visit_number
   FROM ahl_visit_tasks_b tsk,
        (select vst1.* from
         ahl_visits_b vst1, ahl_simulation_plans_b sim
         where vst1.simulation_plan_id = sim.simulation_plan_id
           and sim.primary_plan_flag = 'Y'
         UNION ALL
         select vst1.* from
         ahl_visits_b vst1
         where simulation_plan_id IS NULL)vst
   WHERE vst.visit_id = tsk.visit_id
   AND NVL(vst.status_code,'x') NOT IN ('DELETED','CANCELLED')
   AND NVL(tsk.status_code,'x') NOT IN ('DELETED','CANCELLED')
   AND tsk.unit_effectivity_id = p_ue_id;
*/
--amsriniv ER 6116245 Begin
   CURSOR ahl_visit_csr(p_ue_id IN NUMBER, p_visit_num IN VARCHAR2, p_visit_org_name IN VARCHAR2, p_visit_dept_name IN VARCHAR2) IS
   SELECT vst.start_date_time, vst.visit_number, vst.visit_id
   FROM ahl_visit_tasks_b tsk,
        (select vst1.* from
         ahl_visits_b vst1, ahl_simulation_plans_b sim
         where vst1.simulation_plan_id = sim.simulation_plan_id
           and sim.primary_plan_flag = 'Y'
         UNION ALL
         select vst1.* from
         ahl_visits_b vst1
         where simulation_plan_id IS NULL)vst,
         hr_all_organization_units hrou,
         bom_departments bdpt
   WHERE vst.visit_id = tsk.visit_id
   AND NVL(vst.status_code,'x') NOT IN ('DELETED','CANCELLED')
   AND NVL(tsk.status_code,'x') NOT IN ('DELETED','CANCELLED')
   AND tsk.unit_effectivity_id = p_ue_id
   AND vst.organization_id    = hrou.organization_id(+)
   AND ((vst.organization_id IS NULL AND p_visit_org_name IS NULL) OR upper(hrou.name) LIKE NVL(upper(p_visit_org_name),upper(hrou.name)))
   AND vst.department_id    = bdpt.department_id(+)
   AND ((vst.department_id IS NULL AND p_visit_dept_name IS NULL) OR upper(bdpt.description) LIKE NVL(upper(p_visit_dept_name),upper(bdpt.description)))
   AND vst.visit_number like nvl(p_visit_num,vst.visit_number);
--amsriniv ER 6116245 End

   -- R12: MEL/CDL changes.
   -- get deferral status for deferred UMP rows.
   cursor get_deferral_sts (p_ue_id in number) IS
     select decode(unit_deferral_type, 'MEL', 'MEL ' || fk.meaning,
                                  'CDL', 'CDL ' || fk.meaning,
                                   fk.meaning) deferral_meaning
        from ahl_unit_deferrals_b, fnd_lookup_values_vl fk
        where unit_effectivity_id = p_ue_id
          and fk.lookup_type = 'AHL_PRD_DF_APPR_STATUS_TYPES'
          and fk.lookup_code = approval_status_code;

   -- get deferral status for open UMP rows.
   cursor get_open_deferral_sts (p_ue_id in number) IS
     select fk.meaning defer_meaning
       from ahl_unit_deferrals_b udf, fnd_lookup_values_vl fk
      where udf.unit_effectivity_id = p_ue_id
        and fk.lookup_code = decode(udf.approval_status_code, 'DRAFT',
                                    'DEFERRAL_DRAFT',udf.approval_status_code)
        and fk.lookup_type = 'AHL_PRD_DF_APPR_STATUS_TYPES'
        and udf.unit_deferral_type = 'DEFERRAL';

   -- get mel/cdl status for open UMP rows.
   cursor get_open_mel_cdl_sts (p_ue_id in number) IS
     select unit_deferral_type || ' ' || fk.meaning defer_meaning
       from ahl_unit_deferrals_b udf, fnd_lookup_values_vl fk
      where udf.unit_effectivity_id = p_ue_id
        and fk.lookup_code = decode(udf.approval_status_code, 'DEFERRED',
                                    'APPROVED',udf.approval_status_code)
        and fk.lookup_type = 'AHL_PRD_DF_APPR_STATUS_TYPES'
        and udf.unit_deferral_type IN ('MEL','CDL') ;

  --l_defer_code   VARCHAR2(30);
  l_defer_mean   VARCHAR2(80);

  -- R12: Fix for bug# 5231770.
  l_due_counter_value  NUMBER;
  l_net_reading        NUMBER;
  l_approval_status_code VARCHAR2(30);
  l_unit_deferral_type   VARCHAR2(30);

  -- to get the net counter reading for a counter name and item instance.
  -- modified for uptake of IB fix. Refer bug 7374316.
  CURSOR get_net_reading_csr (p_csi_item_instance_id IN NUMBER,
                              p_ctr_template_name    IN VARCHAR2)
  IS
     SELECT (select ccr.net_reading from csi_counter_readings ccr
             where ccr.counter_value_id = cc.CTR_VAL_MAX_SEQ_NO
               and nvl(ccr.disabled_flag,'N') = 'N') net_reading
     FROM CSI_COUNTER_ASSOCIATIONS CCA, CSI_COUNTERS_VL CC
     WHERE CCA.COUNTER_ID = CC.COUNTER_ID
       AND CCA.SOURCE_OBJECT_ID = p_csi_item_instance_id
       AND CCA.SOURCE_OBJECT_CODE = 'CP'
       AND CC.COUNTER_TEMPLATE_NAME = p_ctr_template_name;
     /*
     SELECT nvl(CV.NET_READING, 0)
     FROM CSI_COUNTER_READINGS CV, CSI_COUNTER_ASSOCIATIONS CCA, CSI_COUNTERS_VL CC
     WHERE CCA.SOURCE_OBJECT_CODE = 'CP'
       AND CCA.COUNTER_ID = CV.COUNTER_ID
       --AND CC.COUNTER_ID = CV.COUNTER_ID
       AND CC.CTR_VAL_MAX_SEQ_NO = CV.counter_value_id
       AND CCA.SOURCE_OBJECT_ID = p_csi_item_instance_id
       AND CC.COUNTER_TEMPLATE_NAME = p_ctr_template_name;
     --ORDER BY CV.VALUE_TIMESTAMP DESC;
     */

   -- added for bug# 6530920.
   l_orig_ue_instance_id  NUMBER;
   l_buffer_limit number := 500;
   l_ue_id_tbl       nbr_tbl_type;

   l_is_pm_installed VARCHAR2(3) := AHL_UTIL_PKG.is_pm_installed();
   l_mr_select_sql_string VARCHAR2(4000);
   l_select_sql_string    VARCHAR2(4000);
   l_mr_select_flag   BOOLEAN;
   l_nr_select_sql_string  VARCHAR2(4000);

   l_due_to DATE;

BEGIN
    IF (G_DEBUG_PROC >= G_DEBUG_LEVEL)THEN
        fnd_log.string
        (
            G_DEBUG_PROC,
            'ahl.plsql.AHL_UMP_SMRINSTANCE_PVT.Search_MR_Instances.begin',
            'At the start of PLSQL procedure'
        );
    END IF;
    -- Standard start of API savepoint
    SAVEPOINT Search_MR_Instances_Pvt;

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.Initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- other initilizations needed for API
    l_early_exit_status := TRUE;
    l_bind_index     := 1;
    -- Logging input
    IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)THEN
        fnd_log.string
        (
            G_DEBUG_STMT, 'ahl.plsql.AHL_UMP_SMRINSTANCE_PVT.Search_MR_Instances',
            'p_search_mr_instance_rec.unit_name :' || p_search_mr_instance_rec.unit_name
        );
        fnd_log.string
        (
            G_DEBUG_STMT, 'ahl.plsql.AHL_UMP_SMRINSTANCE_PVT.Search_MR_Instances',
            'p_search_mr_instance_rec.part_number :' || p_search_mr_instance_rec.part_number
        );
        fnd_log.string
        (
            G_DEBUG_STMT, 'ahl.plsql.AHL_UMP_SMRINSTANCE_PVT.Search_MR_Instances',
            'p_search_mr_instance_rec.serial_number :' || p_search_mr_instance_rec.serial_number
        );
        fnd_log.string
        (
            G_DEBUG_STMT, 'ahl.plsql.AHL_UMP_SMRINSTANCE_PVT.Search_MR_Instances',
            'p_search_mr_instance_rec.sort_by :' || p_search_mr_instance_rec.sort_by
        );
        fnd_log.string
        (
            G_DEBUG_STMT, 'ahl.plsql.AHL_UMP_SMRINSTANCE_PVT.Search_MR_Instances',
            'p_search_mr_instance_rec.mr_status :' || p_search_mr_instance_rec.mr_status
        );
        fnd_log.string
        (
            G_DEBUG_STMT, 'ahl.plsql.AHL_UMP_SMRINSTANCE_PVT.Search_MR_Instances',
            'p_search_mr_instance_rec.program_type :' || p_search_mr_instance_rec.program_type
        );
        fnd_log.string
        (
            G_DEBUG_STMT, 'ahl.plsql.AHL_UMP_SMRINSTANCE_PVT.Search_MR_Instances',
            'p_search_mr_instance_rec.due_from :' || p_search_mr_instance_rec.due_from
        );
        fnd_log.string
        (
            G_DEBUG_STMT, 'ahl.plsql.AHL_UMP_SMRINSTANCE_PVT.Search_MR_Instances',
            'p_search_mr_instance_rec.due_to :' || p_search_mr_instance_rec.due_to
        );
        fnd_log.string
        (
            G_DEBUG_STMT, 'ahl.plsql.AHL_UMP_SMRINSTANCE_PVT.Search_MR_Instances',
            'p_search_mr_instance_rec.show_tolerance :' || p_search_mr_instance_rec.show_tolerance
        );
        fnd_log.string
        (
            G_DEBUG_STMT, 'ahl.plsql.AHL_UMP_SMRINSTANCE_PVT.Search_MR_Instances',
            'p_search_mr_instance_rec.components_flag :' || p_search_mr_instance_rec.components_flag
        );
        fnd_log.string
        (
            G_DEBUG_STMT, 'ahl.plsql.AHL_UMP_SMRINSTANCE_PVT.Search_MR_Instances',
            'p_search_mr_instance_rec.repetitive_flag :' || p_search_mr_instance_rec.repetitive_flag
        );
        fnd_log.string
        (
            G_DEBUG_STMT, 'ahl.plsql.AHL_UMP_SMRINSTANCE_PVT.Search_MR_Instances',
            'p_search_mr_instance_rec.contract_number :' || p_search_mr_instance_rec.contract_number
        );
        fnd_log.string
        (
            G_DEBUG_STMT, 'ahl.plsql.AHL_UMP_SMRINSTANCE_PVT.Search_MR_Instances',
            'p_search_mr_instance_rec.contract_modifier :' || p_search_mr_instance_rec.contract_modifier
        );
        fnd_log.string
        (
            G_DEBUG_STMT, 'ahl.plsql.AHL_UMP_SMRINSTANCE_PVT.Search_MR_Instances',
            'p_search_mr_instance_rec.contract_number :' || p_search_mr_instance_rec.contract_number
        );
        fnd_log.string
        (
            G_DEBUG_STMT, 'ahl.plsql.AHL_UMP_SMRINSTANCE_PVT.Search_MR_Instances',
            'p_search_mr_instance_rec.service_line_id :' || p_search_mr_instance_rec.service_line_id
        );
        fnd_log.string
        (
            G_DEBUG_STMT, 'ahl.plsql.AHL_UMP_SMRINSTANCE_PVT.Search_MR_Instances',
            'p_search_mr_instance_rec.service_line_num :' || p_search_mr_instance_rec.service_line_num
        );
        fnd_log.string
        (
            G_DEBUG_STMT, 'ahl.plsql.AHL_UMP_SMRINSTANCE_PVT.Search_MR_Instances',
            'p_search_mr_instance_rec.program_id :' || p_search_mr_instance_rec.program_id
        );
        fnd_log.string
        (
            G_DEBUG_STMT, 'ahl.plsql.AHL_UMP_SMRINSTANCE_PVT.Search_MR_Instances',
            'p_search_mr_instance_rec.program_title :' || p_search_mr_instance_rec.program_title
        );
        fnd_log.string
        (
            G_DEBUG_STMT, 'ahl.plsql.AHL_UMP_SMRINSTANCE_PVT.Search_MR_Instances',
            'p_search_mr_instance_rec.show_groupmr :' || p_search_mr_instance_rec.show_groupmr
        );
        fnd_log.string
        (
            G_DEBUG_STMT, 'ahl.plsql.AHL_UMP_SMRINSTANCE_PVT.Search_MR_Instances',
            'p_search_mr_instance_rec.object_type :' || p_search_mr_instance_rec.object_type
        );

      fnd_log.string
        (
            G_DEBUG_STMT, 'ahl.plsql.AHL_UMP_SMRINSTANCE_PVT.Search_MR_Instances',
            'p_search_mr_instance_rec.search_for_type :' || p_search_mr_instance_rec.search_for_type
        );

      fnd_log.string
        (
            G_DEBUG_STMT, 'ahl.plsql.AHL_UMP_SMRINSTANCE_PVT.Search_MR_Instances',
            'p_search_mr_instance_rec.INCIDENT_TYPE_ID :' || p_search_mr_instance_rec.INCIDENT_TYPE_ID
        );

      fnd_log.string
        (
            G_DEBUG_STMT, 'ahl.plsql.AHL_UMP_SMRINSTANCE_PVT.Search_MR_Instances',
            'p_search_mr_instance_rec.SERVICE_REQ_NUM :' || p_search_mr_instance_rec.SERVICE_REQ_NUM
        );
    END IF;

    l_mr_select_flag := FALSE;

    IF p_search_mr_instance_rec.due_to is NOT NULL THEN
         --l_due_to := TRUNC(p_search_mr_instance_rec.due_to) + 86399/86400;
         l_due_to := TRUNC(p_search_mr_instance_rec.due_to) + 1;
         IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)THEN
          fnd_log.string
          (
            G_DEBUG_STMT, 'ahl.plsql.AHL_UMP_SMRINSTANCE_PVT.Search_MR_Instances',
            'l_due_to :' || to_char(l_due_to,'DD-MON-YYYY HH24:MI:SS')
          );
         END IF;
    END IF;

    -- validate input
    -- if both MR title and (INCIDENT_TYPE_ID and/or SERVICE_REQ_NUM) entered, raise error.
    IF (p_search_mr_instance_rec.mr_title is NOT NULL) AND
       (p_search_mr_instance_rec.INCIDENT_TYPE_ID IS NOT NULL OR p_search_mr_instance_rec.SERVICE_REQ_NUM IS NOT NULL)
    THEN
      FND_MESSAGE.Set_Name('AHL','AHL_UMP_MR_SERQ_INPUT');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

     --start fix for bug#7327283
     --SELECT Clause
     --l_sql_string := 'SELECT  UMP.unit_effectivity_id FROM AHL_UNIT_EFFECTIVITIES_V UMP WHERE 0=0 ';

     --fix for bug# 7562008. Added hint /*+ dynamic_sampling(AAI1 4) */ to queries based on AHL_APPLICABLE_INSTANCES table
     --as per feedback from Application Performance team.
     IF (l_is_pm_installed = 'Y') THEN
       l_sql_string := 'SELECT  UMP.unit_effectivity_id FROM AHL_UNIT_EFFECTIVITIES_V UMP WHERE 0=0 ';
     ELSE
       IF (p_search_mr_instance_rec.unit_name is NOT NULL OR nvl(p_search_mr_instance_rec.part_number,'%')
                    <> '%' OR p_search_mr_instance_rec.serial_number IS NOT NULL) THEN
          --l_sql_string := 'SELECT  UMP.unit_effectivity_id FROM AHL_UNIT_EFFECTIVITIES_B UMP WHERE UMP.application_usg_code= ''AHL'' ';
          l_select_sql_string := 'SELECT /*+ dynamic_sampling(AAI1 4) */ UMP.unit_effectivity_id FROM AHL_UNIT_EFFECTIVITIES_B UMP, AHL_APPLICABLE_INSTANCES AAI1 ';
          l_select_sql_string := l_select_sql_string || 'WHERE UMP.application_usg_code= :APPL_USG_CODE AND AAI1.csi_item_instance_id = UMP.csi_item_instance_id ';

          l_mr_select_sql_string := 'SELECT /*+ dynamic_sampling(AAI1 4) */ UMP.unit_effectivity_id FROM AHL_UNIT_EFFECTIVITIES_B UMP, AHL_APPLICABLE_INSTANCES AAI1, AHL_MR_HEADERS_B MR';
          l_mr_select_sql_string := l_mr_select_sql_string || ' WHERE UMP.application_usg_code= :APPL_USG_CODE AND AAI1.csi_item_instance_id = UMP.csi_item_instance_id AND UMP.mr_header_id = MR.mr_header_id ';

          l_bindvar_tbl(l_bind_index) := ltrim(rtrim(fnd_profile.value('AHL_APPLN_USAGE')));
          l_bind_index := l_bind_index + 1;

          IF p_search_mr_instance_rec.INCIDENT_TYPE_ID IS NOT NULL  THEN
            IF nvl(p_search_mr_instance_rec.SERVICE_REQ_NUM, '%') <> '%' THEN
                l_nr_select_sql_string := 'SELECT /*+ dynamic_sampling(AAI1 4) */ UMP.unit_effectivity_id FROM AHL_UNIT_EFFECTIVITIES_B UMP , AHL_APPLICABLE_INSTANCES AAI1, CS_INCIDENTS_ALL_B CI, CS_INCIDENT_TYPES_VL CIT ';
                l_nr_select_sql_string := l_nr_select_sql_string || 'WHERE UMP.application_usg_code= :APPL_USG_CODE AND AAI1.csi_item_instance_id = UMP.csi_item_instance_id AND ';
                l_nr_select_sql_string := l_nr_select_sql_string || 'UMP.cs_incident_id = CI.incident_id AND CI.incident_number like :CS_SERVC_NUM AND CI.incident_type_id = CIT.incident_type_id AND CIT.incident_type_id = :INC_TYPE_ID ';

                l_bindvar_tbl(l_bind_index) := p_search_mr_instance_rec.SERVICE_REQ_NUM;
                l_bind_index := l_bind_index + 1;

                l_bindvar_tbl(l_bind_index) := p_search_mr_instance_rec.INCIDENT_TYPE_ID;
                l_bind_index := l_bind_index + 1;

            ELSE -- servc req num is null.
                l_nr_select_sql_string := 'SELECT /*+ dynamic_sampling(AAI1 4) */ UMP.unit_effectivity_id FROM AHL_UNIT_EFFECTIVITIES_B UMP, AHL_APPLICABLE_INSTANCES AAI1, CS_INCIDENTS_ALL_B CI,CS_INCIDENT_TYPES_VL CIT ';
                l_nr_select_sql_string := l_nr_select_sql_string || 'WHERE UMP.application_usg_code= :APPL_USG_CODE AND AAI1.csi_item_instance_id = UMP.csi_item_instance_id AND UMP.cs_incident_id = CI.incident_id';
               l_nr_select_sql_string := l_nr_select_sql_string || ' AND CI.incident_type_id = CIT.incident_type_id AND CIT.incident_type_id = :INC_TYPE_ID ';
               l_bindvar_tbl(l_bind_index) := p_search_mr_instance_rec.INCIDENT_TYPE_ID;
               l_bind_index := l_bind_index + 1;
            END IF; -- p_search_mr_instance_rec.SERVICE_REQ_NUM
          ELSE -- INCIDENT_TYPE_ID is null
            IF (nvl(p_search_mr_instance_rec.SERVICE_REQ_NUM, '%') <> '%') THEN
               -- servc req is not null
               l_nr_select_sql_string := 'SELECT /*+ dynamic_sampling(AAI1 4) */ UMP.unit_effectivity_id FROM AHL_UNIT_EFFECTIVITIES_B UMP,AHL_APPLICABLE_INSTANCES AAI1, CS_INCIDENTS_ALL_B CI ';
               l_nr_select_sql_string := l_nr_select_sql_string || 'WHERE UMP.application_usg_code= :APPL_USG_CODE AND AAI1.csi_item_instance_id = UMP.csi_item_instance_id ';
               l_nr_select_sql_string := l_nr_select_sql_string || 'AND UMP.cs_incident_id = CI.incident_id AND CI.incident_number like :CS_SERVC_NUM ';
               l_bindvar_tbl(l_bind_index) := p_search_mr_instance_rec.SERVICE_REQ_NUM;
               l_bind_index := l_bind_index + 1;
            ELSE
              -- both are null
              null;
            END IF;
          END IF; -- p_search_mr_instance_rec.INCIDENT_TYPE_ID
       ELSE -- p_search_mr_instance_rec.unit_name
          l_select_sql_string := 'SELECT  UMP.unit_effectivity_id FROM AHL_UNIT_EFFECTIVITIES_B UMP WHERE UMP.application_usg_code= :APPL_USG_CODE ';

          l_mr_select_sql_string := 'SELECT  UMP.unit_effectivity_id FROM AHL_UNIT_EFFECTIVITIES_B UMP, AHL_MR_HEADERS_B MR  WHERE UMP.application_usg_code= :APPL_USG_CODE AND UMP.mr_header_id = MR.mr_header_id ';
          l_bindvar_tbl(l_bind_index) := ltrim(rtrim(fnd_profile.value('AHL_APPLN_USAGE')));
          l_bind_index := l_bind_index + 1;
          IF p_search_mr_instance_rec.INCIDENT_TYPE_ID IS NOT NULL THEN
            IF nvl(p_search_mr_instance_rec.SERVICE_REQ_NUM, '%') <> '%' THEN
                l_nr_select_sql_string := 'SELECT  UMP.unit_effectivity_id FROM AHL_UNIT_EFFECTIVITIES_B UMP, CS_INCIDENTS_ALL_B CI, CS_INCIDENT_TYPES_VL CIT WHERE UMP.application_usg_code= :APPL_USG_CODE ';
                l_nr_select_sql_string := l_nr_select_sql_string || ' AND UMP.cs_incident_id = CI.incident_id  AND CI.incident_number like :CS_SERVC_NUM AND CI.incident_type_id = CIT.incident_type_id AND CIT.incident_type_id = :INC_TYPE_ID ';

                l_bindvar_tbl(l_bind_index) := p_search_mr_instance_rec.SERVICE_REQ_NUM;
                l_bind_index := l_bind_index + 1;

                l_bindvar_tbl(l_bind_index) := p_search_mr_instance_rec.INCIDENT_TYPE_ID;
                l_bind_index := l_bind_index + 1;

            ELSE -- servc req num is null.
                l_nr_select_sql_string := 'SELECT  UMP.unit_effectivity_id FROM AHL_UNIT_EFFECTIVITIES_B UMP,CS_INCIDENTS_ALL_B CI,CS_INCIDENT_TYPES_VL CIT ';
                l_nr_select_sql_string := l_nr_select_sql_string || 'WHERE UMP.application_usg_code= :APPL_USG_CODE AND UMP.cs_incident_id = CI.incident_id ';
                l_nr_select_sql_string := l_nr_select_sql_string || 'AND CI.incident_type_id = CIT.incident_type_id AND CIT.incident_type_id = :INC_TYPE_ID ';

               l_bindvar_tbl(l_bind_index) := p_search_mr_instance_rec.INCIDENT_TYPE_ID;
               l_bind_index := l_bind_index + 1;
            END IF; -- p_search_mr_instance_rec.SERVICE_REQ_NUM
          ELSE -- INCIDENT_TYPE_ID is null
            IF (nvl(p_search_mr_instance_rec.SERVICE_REQ_NUM, '%') <> '%') THEN
               -- servc req is not null
               l_nr_select_sql_string := 'SELECT UMP.unit_effectivity_id FROM AHL_UNIT_EFFECTIVITIES_B UMP,CS_INCIDENTS_ALL_B CI ';
               l_nr_select_sql_string := l_nr_select_sql_string || 'WHERE UMP.application_usg_code= :APPL_USG_CODE AND UMP.cs_incident_id = CI.incident_id AND CI.incident_number like :CS_SERVC_NUM ';

               l_bindvar_tbl(l_bind_index) := p_search_mr_instance_rec.SERVICE_REQ_NUM;
               l_bind_index := l_bind_index + 1;
            ELSE
              -- both are null
              null;
            END IF;
          END IF; -- p_search_mr_instance_rec.INCIDENT_TYPE_ID
       END IF; --p_search_mr_instance_rec.unit_name
     END IF;

     --end fix for bug#7327283

     --MR Title Check
     IF p_search_mr_instance_rec.mr_title is NOT NULL THEN
         IF (l_is_pm_installed = 'Y') THEN
           l_sql_string := l_sql_string || ' AND UPPER(UMP.TITLE) like :MR_TITLE ';
         ELSE
           l_sql_string := l_sql_string || ' AND UPPER(MR.TITLE) like :MR_TITLE ';
           l_mr_select_flag := TRUE;
         END IF;
         l_bindvar_tbl(l_bind_index) := UPPER(p_search_mr_instance_rec.mr_title);
         l_bind_index := l_bind_index + 1;
     END IF;

     --Program Type
     IF p_search_mr_instance_rec.program_type is NOT NULL THEN
        /*
        IF p_module_type = 'VWP' THEN
         --If the caller is 'VWP'
         l_sql_string := l_sql_string || ' AND UMP.OBJECT_TYPE = ''MR''  ';
        ELSIF p_search_mr_instance_rec.program_type = 'NON-ROUTINE' THEN
          --If the Prgram_type_code is NON_ROUTINE
          l_sql_string := l_sql_string || ' AND UMP.OBJECT_TYPE IN (''SR'',''MR'')  ';
        END IF;
        */
        IF (l_is_pm_installed = 'Y') THEN
          l_sql_string := l_sql_string || ' AND UMP.PROGRAM_TYPE_CODE like :FMP_PROGRAM_TYPE ';
        ELSE
          IF (p_search_mr_instance_rec.program_type = 'NON-ROUTINE' AND l_mr_select_flag = FALSE AND
              l_nr_select_sql_string IS NULL)  THEN
               --If the Prgram_type_code is NON_ROUTINE
               l_sql_string := l_sql_string || ' AND UMP.OBJECT_TYPE IN (''SR'',''MR'')  ';
               -- fix for bug#7327283
               l_sql_string := l_sql_string || ' AND DECODE(UMP.OBJECT_TYPE,''SR'',''NON-ROUTINE'',
                (select MR.program_type_code from AHL_MR_HEADERS_B MR where MR.mr_header_id = UMP.mr_header_id)) like :FMP_PROGRAM_TYPE ';

               l_bindvar_tbl(l_bind_index) := p_search_mr_instance_rec.program_type;
               l_bind_index := l_bind_index + 1;

          ELSIF (p_search_mr_instance_rec.program_type = 'NON-ROUTINE' AND l_nr_select_sql_string IS NOT NULL) THEN
               null; -- filter not required.
          ELSIF (l_nr_select_sql_string IS NULL) THEN
              -- only MRs to be selected
              l_sql_string := l_sql_string || ' AND MR.PROGRAM_TYPE_CODE like :FMP_PROGRAM_TYPE ';
              l_mr_select_flag := TRUE;

              l_bindvar_tbl(l_bind_index) := p_search_mr_instance_rec.program_type;
              l_bind_index := l_bind_index + 1;
          END IF;
        END IF;
     END IF;

     --MR Status Check
     IF (p_search_mr_instance_rec.mr_status is NOT NULL AND UPPER(p_search_mr_instance_rec.mr_status) <> 'ALL') THEN
        IF UPPER(p_search_mr_instance_rec.mr_status) IN ('OPEN','SCHEDULED','UNSCHEDULED') THEN
           --l_sql_string := l_sql_string || ' AND nvl(UMP.status_code,''x'') NOT IN (''ACCOMPLISHED'', ''EXCEPTION'', ''INIT-ACCOMPLISHED'', ''TERMINATED'',''MR-TERMINATE'',''DEFERRED'', ''SR-CLOSED'')';
           l_sql_string := l_sql_string || ' AND (UMP.status_code IS NULL OR UMP.status_code = ''INIT-DUE'') ';
        ELSIF p_search_mr_instance_rec.mr_status IN ('DEFERRAL_PENDING',
                                                     'DEFERRAL_REJECTED',
                                                     'DRAFT')
        THEN
          l_sql_string := l_sql_string || ' AND (UMP.status_code IS NULL OR UMP.status_code = ''INIT-DUE'') ';
          l_sql_string := l_sql_string || ' AND EXISTS (Select ''x'' FROM ahl_unit_deferrals_b WHERE unit_effectivity_id = UMP.unit_effectivity_id AND approval_status_code = :DEFERRAL_STATUS) ';
          l_bindvar_tbl(l_bind_index) := p_search_mr_instance_rec.mr_status;
          l_bind_index := l_bind_index + 1;
        /*
        ELSIF p_search_mr_instance_rec.mr_status like 'CDL%' THEN
          l_sql_string := l_sql_string || ' AND EXISTS (Select ''x'' FROM ahl_unit_deferrals_b WHERE unit_effectivity_id = UMP.unit_effectivity_id AND unit_deferral_type = ''CDL'' AND approval_status_code = :CDL_STATUS) ';
          l_bindvar_tbl(l_bind_index) := 'CDL:' || p_search_mr_instance_rec.mr_status;
          l_bind_index := l_bind_index + 1;
        ELSIF p_search_mr_instance_rec.mr_status like 'MEL%' THEN
          l_sql_string := l_sql_string || ' AND EXISTS (Select ''x'' FROM ahl_unit_deferrals_b WHERE unit_effectivity_id = UMP.unit_effectivity_id AND unit_deferral_type = ''MEL'' AND approval_status_code = :MEL_STATUS) ';
          l_bindvar_tbl(l_bind_index) := 'MEL:' || p_search_mr_instance_rec.mr_status;
          l_bind_index := l_bind_index + 1;
        */
        ELSE
           l_sql_string := l_sql_string || ' AND UMP.STATUS_CODE = :MR_STATUS ';
           l_bindvar_tbl(l_bind_index) := p_search_mr_instance_rec.mr_status;
           l_bind_index := l_bind_index + 1;
        END IF;
     END IF;

 --Manually Planned Flag Check
     IF (p_search_mr_instance_rec.search_for_type is NOT NULL AND p_search_mr_instance_rec.search_for_type <> 'ALL')
    THEN
        IF (p_search_mr_instance_rec.search_for_type = 'FORECASTED')
        THEN
        l_sql_string := l_sql_string || ' AND NVL(UMP.MANUALLY_PLANNED_FLAG, ''N'') = ''N'' ';
        ELSIF (p_search_mr_instance_rec.search_for_type = 'MANUALLY_PLANNED')
        THEN
        l_sql_string := l_sql_string || ' AND UMP.MANUALLY_PLANNED_FLAG = ''Y'' ';
        END IF;
    END IF;


     /* *********************************** BEGIN: SHOW TOLERANCE ****************************************** */
     -- Show Tolerance is N
     IF p_search_mr_instance_rec.show_tolerance ='N' THEN
       --Due-From Date Check
       IF p_search_mr_instance_rec.due_from is NOT NULL THEN
         l_sql_string := l_sql_string || ' AND UMP.DUE_DATE >= :DUE_FROM1 ';
         l_bindvar_tbl(l_bind_index) := TRUNC(p_search_mr_instance_rec.due_from);
         l_bind_index := l_bind_index + 1;
       END IF;
       --Due-To Date Check
       IF p_search_mr_instance_rec.due_to is NOT NULL THEN
         --l_sql_string := l_sql_string || ' AND UMP.DUE_DATE <= :DUE_TO1 ';
         l_sql_string := l_sql_string || ' AND UMP.DUE_DATE < :DUE_TO1 ';--bug8265049
         l_bindvar_tbl(l_bind_index) := l_due_to;--TRUNC(p_search_mr_instance_rec.due_to);//bug8265049
         l_bind_index := l_bind_index + 1;
       END IF;
     ELSE -- Show Tolerance is Y
        IF ( p_search_mr_instance_rec.due_from is NOT NULL AND  p_search_mr_instance_rec.due_to is NOT NULL ) THEN
          -- Both Due-From and Due-To Dates are there
--adivenka modified the following part of the query for bug# 4315128
       l_sql_string := l_sql_string || ' AND (
                       (:DUE_FROM2 <= nvl(UMP.earliest_due_date, UMP.due_date) AND nvl(UMP.earliest_due_date, UMP.due_date) < :DUE_TO2)
                       OR (nvl(UMP.earliest_due_date, UMP.due_date) <= :DUE_FROM3 AND :DUE_TO3 < nvl(UMP.latest_due_date, UMP.due_date))
                       OR (:DUE_FROM4 <= nvl(UMP.latest_due_date, UMP.due_date) AND nvl(UMP.latest_due_date, UMP.due_date) < :DUE_TO4)
                       )';
--adivenka changes end

          -- due from2 and due to2
          l_bindvar_tbl(l_bind_index) := TRUNC(p_search_mr_instance_rec.due_from);
          l_bind_index := l_bind_index + 1;
          l_bindvar_tbl(l_bind_index) := l_due_to;--TRUNC(p_search_mr_instance_rec.due_to);//bug8265049
          l_bind_index := l_bind_index + 1;
          -- due from3 and due to3
          l_bindvar_tbl(l_bind_index) := TRUNC(p_search_mr_instance_rec.due_from);
          l_bind_index := l_bind_index + 1;
          l_bindvar_tbl(l_bind_index) := l_due_to;--TRUNC(p_search_mr_instance_rec.due_to);//bug8265049
          l_bind_index := l_bind_index + 1;
          -- due from4 and due to4
          l_bindvar_tbl(l_bind_index) := TRUNC(p_search_mr_instance_rec.due_from);
          l_bind_index := l_bind_index + 1;
          l_bindvar_tbl(l_bind_index) := l_due_to;--TRUNC(p_search_mr_instance_rec.due_to);//bug8265049
          l_bind_index := l_bind_index + 1;
        ELSIF ( p_search_mr_instance_rec.due_from is NOT NULL AND  p_search_mr_instance_rec.due_to is NULL ) THEN
          -- Only Due-From Date is there and Due-To Date is NULL
          --adivenka modified the following part of the query for bug# 4315128
          l_sql_string := l_sql_string || ' AND ( ( ( :DUE_FROM2 <= nvl(UMP.earliest_due_date, UMP.due_date) )
                            )
                            OR
                            ( ( :DUE_FROM3 <= nvl(UMP.latest_due_date, UMP.due_date) )
                            ) )';
          l_bindvar_tbl(l_bind_index) := TRUNC(p_search_mr_instance_rec.due_from);
          l_bind_index := l_bind_index + 1;
          l_bindvar_tbl(l_bind_index) := TRUNC(p_search_mr_instance_rec.due_from);
          l_bind_index := l_bind_index + 1;
        ELSIF ( p_search_mr_instance_rec.due_from is NULL AND  p_search_mr_instance_rec.due_to is NOT NULL ) THEN
          -- Only Due-To Date is there and Due-From Date is NULL
          --adivenka modified the following part of the query for bug# 4315128
          l_sql_string := l_sql_string || ' AND ( ( ( nvl(UMP.earliest_due_date, UMP.due_date) < :DUE_TO2 )
                        )
                        OR
                        ( ( nvl(UMP.latest_due_date, UMP.due_date) < :DUE_TO3 )
                        ) )';
          l_bindvar_tbl(l_bind_index) := l_due_to;--TRUNC(p_search_mr_instance_rec.due_to);//bug8265049
          l_bind_index := l_bind_index + 1;
          l_bindvar_tbl(l_bind_index) := l_due_to;--TRUNC(p_search_mr_instance_rec.due_to);//bug8265049
          l_bind_index := l_bind_index + 1;
        END IF;--Case is ignored when Both Due-From and Due-To Dates are NOT here
    END IF;
    /* ***********************************END: SHOW TOLERANCE ****************************************** */

    --Repetitive MR Flag Check
    IF p_search_mr_instance_rec.repetitive_flag is NOT NULL THEN
      IF UPPER(p_search_mr_instance_rec.repetitive_flag) <> 'Y' THEN
         l_sql_string := l_sql_string || ' AND nvl(UMP.REPETITIVE_MR_FLAG,''x'') <> ''Y'' ';
      END IF;
    END IF;

    -- Show GroupMR check.
    IF p_search_mr_instance_rec.show_GroupMR is NOT NULL THEN
      IF UPPER(p_search_mr_instance_rec.show_GroupMR) = 'Y' THEN
         l_sql_string := l_sql_string || ' AND  NOT EXISTS (SELECT ''x'' FROM AHL_UE_RELATIONSHIPS WHERE RELATED_UE_ID = UMP.unit_effectivity_id)';
      ELSE
         -- Added to fix bug# 6972854.
         -- Child MRs for parent MR that is Init-Accomplished should not be displayed.
         l_sql_string := l_sql_string || ' AND NOT EXISTS (SELECT ''x'' FROM AHL_UNIT_EFFECTIVITIES_B PARENT_UE, AHL_UE_RELATIONSHIPS CHILD_UER';
         l_sql_string := l_sql_string || ' WHERE PARENT_UE.UNIT_EFFECTIVITY_ID = CHILD_UER.ORIGINATOR_UE_ID AND CHILD_UER.RELATED_UE_ID = UMP.unit_effectivity_id AND PARENT_UE.STATUS_CODE = ''INIT-ACCOMPLISHED'') ';

      END IF;
    END IF;

     /*
       * Temporary table use is introduced to improve performance to fix bug # 3786626
       */
     IF p_search_mr_instance_rec.components_flag is NOT NULL THEN
      DELETE AHL_APPLICABLE_INSTANCES;
      IF p_search_mr_instance_rec.components_flag = 'N' THEN
        IF (p_search_mr_instance_rec.unit_name is NOT NULL OR nvl(p_search_mr_instance_rec.part_number,'%')
                    <> '%' OR p_search_mr_instance_rec.serial_number IS NOT NULL) THEN
            populate_instances
            (
               p_module_type            => p_module_type,
               p_search_mr_instance_rec => p_search_mr_instance_rec
            );
            -- not required as included in join in l_select_sql_string
            -- l_sql_string := l_sql_string || ' AND EXISTS (Select ''x'' from AHL_APPLICABLE_INSTANCES AAI WHERE AAI.csi_item_instance_id = UMP.csi_item_instance_id)' ; */
         END IF;
         /*ELSE
            l_sql_string := l_sql_string || ' AND EXISTS (Select ''x'' From csi_unit_instances_v csiu WHERE csiu.instance_id = UMP.csi_item_instance_id )';
         END IF;*/
      ELSIF p_search_mr_instance_rec.components_flag = 'Y' THEN
         IF (p_search_mr_instance_rec.unit_name is NOT NULL OR nvl(p_search_mr_instance_rec.part_number,'%')
                    <> '%' OR p_search_mr_instance_rec.serial_number IS NOT NULL) THEN
            populate_instances
            (
              p_module_type            => p_module_type,
              p_search_mr_instance_rec => p_search_mr_instance_rec
            );
            populate_dependent_instances
            (
              p_module_type            => p_module_type,
              p_search_mr_instance_rec => p_search_mr_instance_rec
            );
            -- not required as included in join in l_select_sql_string
            --l_sql_string := l_sql_string || ' AND EXISTS (Select ''x'' from AHL_APPLICABLE_INSTANCES AAI WHERE AAI.csi_item_instance_id = UMP.csi_item_instance_id)' ;
         END IF;
      END IF;
     END IF;

   --start fix for bug#7327283

  IF (l_is_pm_installed = 'Y') THEN
     --Contract Number
     IF p_search_mr_instance_rec.contract_number is NOT NULL THEN
        l_sql_string := l_sql_string || ' AND UPPER(UMP.contract_number) like :CONTRACT_NUMBER ';
        l_bindvar_tbl(l_bind_index) := UPPER(p_search_mr_instance_rec.contract_number);
        l_bind_index := l_bind_index + 1;
     END IF;

     --Contract Modifier
     IF p_search_mr_instance_rec.contract_modifier is NOT NULL THEN
        l_sql_string := l_sql_string || ' AND UPPER(UMP.contract_number_modifier) like :CONTRACT_MODIFIER ';
        l_bindvar_tbl(l_bind_index) := UPPER(p_search_mr_instance_rec.contract_modifier);
        l_bind_index := l_bind_index + 1;
     END IF;

     --If Contract Number is NOT NULL but Contract Modifier is NULL.
     IF (  p_search_mr_instance_rec.contract_number is NOT NULL AND p_search_mr_instance_rec.contract_modifier is NULL ) THEN
        l_sql_string := l_sql_string || ' AND UMP.contract_number_modifier is NULL';
     END IF;

     --Service Line ID
     IF ( p_search_mr_instance_rec.service_line_id is NOT NULL AND p_search_mr_instance_rec.service_line_num is NULL) THEN
        l_sql_string := l_sql_string || ' AND UMP.service_line_id = :SERVICE_LINE_ID ' ;
        l_bindvar_tbl(l_bind_index) := p_search_mr_instance_rec.service_line_id;
        l_bind_index := l_bind_index + 1;
     END IF;

    --Service Line Number
     IF p_search_mr_instance_rec.service_line_num is NOT NULL THEN
        l_sql_string := l_sql_string || ' AND UPPER(UMP.service_line_number) like :SERVICE_LINE_NUM ';
        l_bindvar_tbl(l_bind_index) := UPPER(p_search_mr_instance_rec.service_line_num);
        l_bind_index := l_bind_index + 1;
     END IF;

     --Program ID
     IF ( p_search_mr_instance_rec.program_id is NOT NULL AND p_search_mr_instance_rec.program_title is NULL ) THEN
        l_sql_string := l_sql_string || ' AND UMP.program_mr_header_id = :PROGRAM_ID ';
        l_bindvar_tbl(l_bind_index) := p_search_mr_instance_rec.program_id;
        l_bind_index := l_bind_index + 1;
     END IF;

     --Program Title
     IF p_search_mr_instance_rec.program_title is NOT NULL THEN
        l_sql_string := l_sql_string || ' AND UPPER(UMP.program_title) like :PROGRAM_TITLE ';
        l_bindvar_tbl(l_bind_index) := UPPER(p_search_mr_instance_rec.program_title);
        l_bind_index := l_bind_index + 1;
     END IF;
   END IF;

     --Object Type
     -- Set when calling for VWP search.
     IF p_search_mr_instance_rec.object_type is NOT NULL THEN
        l_sql_string := l_sql_string || ' AND UMP.OBJECT_TYPE = :UMP_OBJECT_TYPE ';
        l_bindvar_tbl(l_bind_index) := p_search_mr_instance_rec.object_type;
        l_bind_index := l_bind_index + 1;
     END IF;

--amsriniv Begin
     --Visit Number
     --Set when calling for UMP Search when not in PM Mode.
     IF p_search_mr_instance_rec.visit_number is NOT NULL THEN
        l_sql_string := l_sql_string || ' and exists (select ''x'' from ahl_visits_b vst1,ahl_simulation_plans_b sim, ahl_visit_tasks_b tsk where vst1.simulation_plan_id = sim.simulation_plan_id(+) ';
        l_sql_string := l_sql_string || 'and sim.primary_plan_flag(+) = ''Y'' and vst1.visit_number like :VISIT_NUMBER and vst1.visit_id = tsk.visit_id AND NVL(vst1.status_code,''x'') NOT ';
        l_sql_string := l_sql_string || 'IN (''DELETED'',''CANCELLED'') AND NVL(tsk.status_code,''x'') NOT IN (''DELETED'',''CANCELLED'') AND tsk.unit_effectivity_id = UMP.unit_effectivity_id) ' ;
        l_bindvar_tbl(l_bind_index) := p_search_mr_instance_rec.visit_number;
        l_bind_index := l_bind_index + 1;
     END IF;
--amsriniv End

     -- order by clause.. based on the sortBy criteria
     IF p_search_mr_instance_rec.sort_by is NOT NULL THEN
        IF p_search_mr_instance_rec.sort_by = 'AHL_COM_DUE_DATE' THEN
           l_sql_string := l_sql_string || ' ORDER BY UMP.DUE_DATE ASC NULLS FIRST';
        ELSIF p_search_mr_instance_rec.sort_by = 'AHL_UMP_MR_PROGRAM' THEN
            IF (l_is_pm_installed = 'Y') THEN
              l_sql_string := l_sql_string || ' ORDER BY UMP.PROGRAM_TYPE_CODE';
            ELSIF (l_mr_select_flag = TRUE) THEN
              l_sql_string := l_sql_string || ' ORDER BY MR.PROGRAM_TYPE_CODE';
            ELSIF (l_nr_select_sql_string IS NOT NULL) THEN
              l_sql_string := l_sql_string || ' ORDER BY ''NONROUTINE'' ';
            ELSE
              l_sql_string := l_sql_string || ' ORDER BY DECODE(UMP.OBJECT_TYPE,''SR'',''NON-ROUTINE'',
              (select MR.program_type_code from AHL_MR_HEADERS_B MR where MR.mr_header_id = UMP.mr_header_id))';
            END IF;
        ELSIF p_search_mr_instance_rec.sort_by =  'AHL_UMP_MR_CATEGORY' THEN
            IF (l_is_pm_installed = 'Y') THEN
              l_sql_string := l_sql_string || ' ORDER BY UMP.CATEGORY_CODE';
            ELSIF (l_mr_select_flag = TRUE) THEN
              l_sql_string := l_sql_string || ' ORDER BY MR.CATEGORY_CODE';
            ELSE
              l_sql_string := l_sql_string || ' ORDER BY DECODE(UMP.OBJECT_TYPE,''SR'',NULL,
              (select MR.category_code from AHL_MR_HEADERS_B MR where MR.mr_header_id = UMP.mr_header_id))';
            END IF;
        ELSIF p_search_mr_instance_rec.sort_by = 'AHL_UMP_IMPL_STATUS' THEN
           l_sql_string := l_sql_string || ' ORDER BY UMP.STATUS_CODE';
        END IF;
     END IF;

    -- form complete SQL
    IF (l_mr_select_flag = TRUE) THEN
      l_sql_string := l_mr_select_sql_string || l_sql_string;
    ELSIF (l_nr_select_sql_string IS NOT NULL) THEN
      l_sql_string := l_nr_select_sql_string || l_sql_string;
    ELSE
      l_sql_string := l_select_sql_string || l_sql_string;
    END IF;

    -- Logging the sql string .
    IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)THEN
       fnd_log.string
       (
            G_DEBUG_STMT, 'ahl.plsql.AHL_UMP_SMRINSTANCE_PVT.Search_MR_Instances',
            'Prepared SQL string IS '
       );
       l_sql_segment_count := CEIL(LENGTH(l_sql_string)/4000);
       FOR i in 1..l_sql_segment_count LOOP
         IF(i < l_sql_segment_count - 1) THEN
           fnd_log.string
           (
              G_DEBUG_STMT, 'ahl.plsql.AHL_UMP_SMRINSTANCE_PVT.Search_MR_Instances',
              SUBSTR(l_sql_string,(i-1)*4000,4000)
           );
         ELSE
           fnd_log.string
           (
              G_DEBUG_STMT, 'ahl.plsql.AHL_UMP_SMRINSTANCE_PVT.Search_MR_Instances',
              SUBSTR(l_sql_string,(i-1)*4000, LENGTH(l_sql_string) - (l_sql_segment_count -1 ) * 4000)
           );
         END IF;
      END LOOP;
    END IF;

    --Fix for Bug 2745891
    IF ( p_search_mr_instance_rec.mr_status = 'SCHEDULED' OR p_search_mr_instance_rec.mr_status = 'UNSCHEDULED') THEN
      l_early_exit_status := false;
    END IF;

    --open l_cur FOR l_sql_string;
    AHL_OSP_UTIL_PKG.OPEN_SEARCH_CURSOR
    (
       p_conditions_tbl => l_bindvar_tbl,
       p_sql_str        => l_sql_string,
       p_x_csr          => l_cur
    );

    -- initialize loop counters
    row_count := 0;
    l_counter:= 0;
    LOOP
       -- l_unit_effectivity_id
     FETCH l_cur BULK COLLECT INTO l_ue_id_tbl LIMIT l_buffer_limit;
     EXIT WHEN (l_ue_id_tbl.count = 0);

      FOR j IN l_ue_id_tbl.FIRST..l_ue_id_tbl.LAST LOOP
       l_unit_effectivity_id := l_ue_id_tbl(j);
       l_pick_record_flag := TRUE;--record picked

       -- Fix for Bug 2745891
       -- Get details only if required
       IF ( l_early_exit_status = FALSE OR ( row_count >= p_start_row AND row_count < p_start_row + p_rows_per_page)) THEN
         -- Check if PM is installed
         IF (l_is_pm_installed = 'Y') THEN
            -- IF PM is installed, Service Request Details are displayed.
            l_service_req_id := NULL;
            l_service_req_num := NULL;
            l_service_req_date := NULL;

            AHL_UMP_UTIL_PKG.get_ServiceRequest_Details
            (
                  l_unit_effectivity_id,
                  l_service_req_id,
                  l_service_req_num,
                  l_service_req_date
            );

            -- Handling Scheduled and Unscheduled status.
            IF ( p_search_mr_instance_rec.mr_status = 'SCHEDULED' AND
                 l_service_req_num IS NULL ) OR
               ( p_search_mr_instance_rec.mr_status = 'UNSCHEDULED' AND
                 l_service_req_num IS NOT NULL )
            THEN
               l_pick_record_flag := FALSE;
            END IF;
         ELSE
            -- IF PM is NOT installed, Visit Details are displayed.
            l_scheduled_date := NULL;
            l_visit_number := NULL;
	    l_visit_id := NULL;   --PDOKI Added for ER# 6333770
--amsriniv ER 6116245
            OPEN ahl_visit_csr (l_unit_effectivity_id, p_search_mr_instance_rec.visit_number, p_search_mr_instance_rec.visit_org_name, p_search_mr_instance_rec.visit_dept_name);
            FETCH ahl_visit_csr INTO l_scheduled_date, l_visit_number, l_visit_id;
            CLOSE ahl_visit_csr;
            IF ((p_search_mr_instance_rec.visit_number IS NOT NULL OR
                p_search_mr_instance_rec.visit_org_name IS NOT NULL OR
                p_search_mr_instance_rec.visit_dept_name IS NOT NULL) AND
                l_visit_number IS NULL) THEN
                l_pick_record_flag := FALSE;
            END IF;
--amsriniv ER 6116245
            --Error check
            IF FND_MSG_PUB.count_msg > 0 THEN
               RAISE  FND_API.G_EXC_ERROR;
            END IF;
            -- Handling Scheduled and Unscheduled status.
            IF ( p_search_mr_instance_rec.mr_status = 'SCHEDULED' AND
                 l_visit_number IS NULL ) OR
               ( p_search_mr_instance_rec.mr_status = 'UNSCHEDULED' AND
                 l_visit_number IS NOT NULL ) THEN
              l_pick_record_flag := FALSE;
            END IF;
          END IF; -- End ifPMinstalled check
        END IF;  -- End if Get Details Only if required

       -- Picking the records for which the l_pick_record_flag is true.
       IF(l_pick_record_flag) THEN
         IF ( row_count >= p_start_row AND row_count < p_start_row + p_rows_per_page) THEN

           OPEN ump_details_csr(l_unit_effectivity_id);
           FETCH ump_details_csr INTO x_results_mr_instance_tbl(l_counter).PROGRAM_TYPE_MEANING,
                                      x_results_mr_instance_tbl(l_counter).MR_TITLE,
                                      x_results_mr_instance_tbl(l_counter).PART_NUMBER,
                                      x_results_mr_instance_tbl(l_counter).SERIAL_NUMBER,
                                      -- R12: Fix for bug# 5231770.
                                      -- commented uom_remain and added l_due_counter_value
                                      -- x_results_mr_instance_tbl(l_counter).UOM_REMAIN,
                                      l_due_counter_value,
                                      x_results_mr_instance_tbl(l_counter).COUNTER_NAME,
                                      x_results_mr_instance_tbl(l_counter).EARLIEST_DUE_DATE,
                                      x_results_mr_instance_tbl(l_counter).DUE_DATE,
                                      x_results_mr_instance_tbl(l_counter).LATEST_DUE_DATE,
                                      x_results_mr_instance_tbl(l_counter).TOLERANCE_FLAG,
                                      x_results_mr_instance_tbl(l_counter).UMR_STATUS_CODE,
                                      x_results_mr_instance_tbl(l_counter).UMR_STATUS_MEANING,
                                      x_results_mr_instance_tbl(l_counter).ORIGINATOR_TITLE,
                                      x_results_mr_instance_tbl(l_counter).DEPENDANT_TITLE,
                                      x_results_mr_instance_tbl(l_counter).UNIT_EFFECTIVITY_ID,
                                      x_results_mr_instance_tbl(l_counter).MR_ID,
                                      x_results_mr_instance_tbl(l_counter).CSI_ITEM_INSTANCE_ID,
                                      x_results_mr_instance_tbl(l_counter).INSTANCE_NUMBER,
                                      x_results_mr_instance_tbl(l_counter).MR_INTERVAL_ID,
                                      x_results_mr_instance_tbl(l_counter).UNIT_NAME,
                                      x_results_mr_instance_tbl(l_counter).PROGRAM_TITLE,
                                      x_results_mr_instance_tbl(l_counter).CONTRACT_NUMBER,
                                      x_results_mr_instance_tbl(l_counter).DEFER_FROM_UE_ID,
                                      x_results_mr_instance_tbl(l_counter).OBJECT_TYPE,
                                      l_counter_id,
                                      x_results_mr_instance_tbl(l_counter).MANUALLY_PLANNED_FLAG,
                                      x_results_mr_instance_tbl(l_counter).MANUALLY_PLANNED_DESC,
                                      -- anraj: added UMP.cs_incident_id, UMP.cs_incident_number
                                      -- for bug#4133332
                                      x_results_mr_instance_tbl(l_counter).service_req_id,
                                      x_results_mr_instance_tbl(l_counter).service_req_num,
                                      l_orig_ue_instance_id;

           CLOSE ump_details_csr;-- no record found case is not possible

           -- Added to fix bug number 3693957
           IF (l_is_pm_installed = 'Y') THEN
              x_results_mr_instance_tbl(l_counter).service_req_id := l_service_req_id;
              x_results_mr_instance_tbl(l_counter).service_req_num := l_service_req_num;
              x_results_mr_instance_tbl(l_counter).service_req_date := l_service_req_date;
           ELSE
              x_results_mr_instance_tbl(l_counter).scheduled_date := l_scheduled_date;
              x_results_mr_instance_tbl(l_counter).visit_number := l_visit_number;
	      x_results_mr_instance_tbl(l_counter).visit_id := l_visit_id; --PDOKI Added for ER# 6333770

           END IF;
           -- end of fix for bug number 3693957

           --Type of record
           IF(x_results_mr_instance_tbl(l_counter).MR_ID IS NULL) THEN
              x_results_mr_instance_tbl(l_counter).unit_effectivity_type  := 'SR';
           ELSE
              x_results_mr_instance_tbl(l_counter).unit_effectivity_type  := 'MR';
           END IF;

           -- For 'Deferred' UE, get the defer to ue id.
           IF (x_results_mr_instance_tbl(l_counter).UMR_STATUS_CODE = 'DEFERRED') THEN
              OPEN ahl_defer_to_ue_csr(l_unit_effectivity_id);
              FETCH ahl_defer_to_ue_csr INTO x_results_mr_instance_tbl(l_counter).DEFER_TO_UE_ID;
              CLOSE ahl_defer_to_ue_csr;

              -- indicate if MEL or CDL deferred.
              OPEN get_deferral_sts(l_unit_effectivity_id);
              FETCH get_deferral_sts INTO l_defer_mean;
              IF (get_deferral_sts%FOUND) THEN
                 --x_results_mr_instance_tbl(l_counter).UMR_STATUS_CODE := l_defer_code;
                 x_results_mr_instance_tbl(l_counter).UMR_STATUS_MEANING := l_defer_mean;
              END IF;
              CLOSE get_deferral_sts;
           END IF;

           -- set status code based on deferrals. Note this changes the
           -- UMR_STATUS_CODE.
           --IF (x_results_mr_instance_tbl(l_counter).UMR_STATUS_CODE IS NULL OR
           --    x_results_mr_instance_tbl(l_counter).UMR_STATUS_CODE = 'INIT-DUE') THEN
           --END IF;

           -- Set UOM remain as Null for closed UMPs.
           -- R12: Fix for bug# 5231770 - calculate uom_remain.
           IF (x_results_mr_instance_tbl(l_counter).UMR_STATUS_CODE IS NULL OR
               x_results_mr_instance_tbl(l_counter).UMR_STATUS_CODE = 'INIT-DUE')
           THEN
              IF (x_results_mr_instance_tbl(l_counter).COUNTER_NAME IS NOT NULL) THEN
                  -- uom_remain based on interval threshold.
                  IF (x_results_mr_instance_tbl(l_counter).ORIGINATOR_TITLE IS NULL) THEN
                     OPEN get_net_reading_csr (
                               x_results_mr_instance_tbl(l_counter).CSI_ITEM_INSTANCE_ID,
                               x_results_mr_instance_tbl(l_counter).COUNTER_NAME);
                  ELSE
                     OPEN get_net_reading_csr (
                               l_orig_ue_instance_id,
                               x_results_mr_instance_tbl(l_counter).COUNTER_NAME);
                  END IF;
                  FETCH get_net_reading_csr INTO l_net_reading;
                  IF (get_net_reading_csr%NOTFOUND) OR (l_net_reading IS NULL) THEN
                         l_net_reading := 0;
                  END IF;
                  CLOSE get_net_reading_csr;
                  x_results_mr_instance_tbl(l_counter).UOM_REMAIN := l_due_counter_value - l_net_reading;

              -- UOM remain based on init due threshold counter_id.
              ELSIF (l_counter_id IS NOT NULL) THEN
                  OPEN ump_ctr_name_csr(l_counter_id);
                  FETCH ump_ctr_name_csr INTO x_results_mr_instance_tbl(l_counter).COUNTER_NAME,
                                              l_net_reading;
                  IF (ump_ctr_name_csr%NOTFOUND) THEN
                     l_net_reading := 0;
                  ELSIF (l_net_reading IS NULL) THEN
                     l_net_reading := 0;
                  END IF;
                  CLOSE ump_ctr_name_csr;

                  x_results_mr_instance_tbl(l_counter).UOM_REMAIN := l_due_counter_value - l_net_reading;

              END IF; -- x_results_mr_instance_tbl(l_counter).COUNTER_NAME

              -- get MEL/CDL deferral status
              -- first check for deferral record.
              OPEN get_open_deferral_sts(l_unit_effectivity_id);
              FETCH get_open_deferral_sts INTO l_defer_mean;
              IF (get_open_deferral_sts%FOUND) THEN
                 x_results_mr_instance_tbl(l_counter).UMR_STATUS_MEANING := l_defer_mean;
              ELSE -- no deferral record found. Chk for MEL/CDL deferral.
                 OPEN get_open_mel_cdl_sts(l_unit_effectivity_id);
                 FETCH get_open_mel_cdl_sts INTO l_defer_mean;
                 IF (get_open_mel_cdl_sts%FOUND) THEN
                   x_results_mr_instance_tbl(l_counter).UMR_STATUS_MEANING := l_defer_mean;
                 END IF;
                 CLOSE get_open_mel_cdl_sts;
              END IF;
              CLOSE get_open_deferral_sts;

           ELSE
                  x_results_mr_instance_tbl(l_counter).UOM_REMAIN := NULL;
           END IF; -- x_results_mr_instance_tbl(l_counter).UMR_STATUS_CODE

           -- increment counter
           l_counter := l_counter +1;
         END IF;
         row_count := row_count + 1;
       END IF; -- End l_picked_flag
     END LOOP; -- l_ue_id_tbl loop
     l_ue_id_tbl.DELETE;
    END LOOP; -- End LOOP
    -- The total number of rows returned
    x_results_count := row_count;
    --Close the dynamic cursor and free up resources
    CLOSE l_cur;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get
    (
        p_count => x_msg_count,
        p_data  => x_msg_data,
        p_encoded => fnd_api.g_false
    );

    -- Logging input
    IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)THEN
        fnd_log.string
        (
            G_DEBUG_STMT, 'ahl.plsql.AHL_UMP_SMRINSTANCE_PVT.Search_MR_Instances',
            'number of records returned :' || x_results_count
        );
    END IF;

    IF (G_DEBUG_PROC >= G_DEBUG_LEVEL)THEN
        fnd_log.string
        (
            G_DEBUG_PROC,
            'ahl.plsql.AHL_UMP_SMRINSTANCE_PVT.Search_MR_Instances.end',
            'At the end of PLSQL procedure'
        );
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      ROLLBACK TO Search_MR_Instances_Pvt;
      FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                 p_data  => x_msg_data,
                                 p_encoded => fnd_api.g_false);


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO Search_MR_Instances_Pvt;
      FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                 p_data  => x_msg_data,
                                 p_encoded => fnd_api.g_false);

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO Search_MR_Instances_Pvt;
      FND_MSG_PUB.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Search_MR_Instances',
                               p_error_text     => SQLERRM);

      FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                 p_data  => x_msg_data,
                                 p_encoded => fnd_api.g_false);

END Search_MR_Instances;


PROCEDURE populate_instances(
    p_module_type            IN            VARCHAR2,
    p_search_mr_instance_rec IN            AHL_UMP_SMRINSTANCE_PVT.Search_MRInstance_Rec_Type) IS


    CURSOR only_units_csr(p_unit_name in VARCHAR2) IS
    Select ahlu.csi_item_instance_id from ahl_unit_config_headers ahlu
    where UPPER(ahlu.name) like upper(p_unit_name);


    l_unit_related_ii_sql     VARCHAR2(4000);

    l_bind_index     NUMBER;
    l_bindvar_tbl AHL_OSP_UTIL_PKG.ahl_conditions_tbl;

    -- dynamic cursor
    l_cur            AHL_OSP_UTIL_PKG.ahl_search_csr;
    --l_instance_id    NUMBER;

    l_inst_tbl       nbr_tbl_type;
    l_buffer_limit number := 500;

BEGIN
    --l_all_csi_ii_id sql_string [ Blind search at unit level]
    IF (p_search_mr_instance_rec.unit_name is NOT NULL AND nvl(p_search_mr_instance_rec.part_number,'%')
                    = '%' AND p_search_mr_instance_rec.serial_number is NULL) THEN
        FOR only_units_rec IN only_units_csr(p_search_mr_instance_rec.unit_name) LOOP
          INSERT INTO AHL_APPLICABLE_INSTANCES (CSI_ITEM_INSTANCE_ID, POSITION_ID) VALUES (only_units_rec.csi_item_instance_id,0);
        END LOOP;

    ELSE
      l_bind_index := 1;
      l_unit_related_ii_sql := 'select csii.instance_id from csi_item_instances csii ';

      IF nvl(p_search_mr_instance_rec.part_number,'%')
                    <> '%'  THEN
         l_unit_related_ii_sql := l_unit_related_ii_sql || ', mtl_system_items_kfv mtl ';
      END IF;

      IF p_search_mr_instance_rec.unit_name is NOT NULL THEN
         l_unit_related_ii_sql := l_unit_related_ii_sql || ', ahl_unit_config_headers uc ';
      END IF;

      l_unit_related_ii_sql := l_unit_related_ii_sql || 'where 0=0 ';

      IF nvl(p_search_mr_instance_rec.part_number,'%')
                    <> '%'  THEN
         l_unit_related_ii_sql := l_unit_related_ii_sql || 'and mtl.inventory_item_id = csii.inventory_item_id and mtl.organization_id = csii.inv_master_organization_id ';

         /*
         IF p_module_type = 'VWP' THEN
            l_unit_related_ii_sql := l_unit_related_ii_sql || 'and csidv.concatenated_segments like :PART_NUMBER ';
            l_bindvar_tbl(l_bind_index) := p_search_mr_instance_rec.part_number;
         ELSE
            l_unit_related_ii_sql := l_unit_related_ii_sql || 'and UPPER(csidv.concatenated_segments) like :PART_NUMBER ';
            l_bindvar_tbl(l_bind_index) := UPPER(p_search_mr_instance_rec.part_number);
         END IF;
         */

         /* Using UPPER() on concatenated_segments does not pick up any index and cost is very high ~ 45K in gsihrms
          * Also Ahmed Alomari's mail to appsperf_us (dt: 17-Feb-2006) says the following...
          * Part numbers are rarely case insensitive, so you can remove the upper.
          */

         l_unit_related_ii_sql := l_unit_related_ii_sql || 'and mtl.concatenated_segments like :PART_NUMBER ';
         l_bindvar_tbl(l_bind_index) := p_search_mr_instance_rec.part_number;
         l_bind_index := l_bind_index + 1;
      END IF;

      IF p_search_mr_instance_rec.serial_number is NOT NULL THEN
         IF p_module_type = 'VWP' THEN
            l_unit_related_ii_sql := l_unit_related_ii_sql || 'and csii.serial_number like :SERIAL_NUMBER ';
            l_bindvar_tbl(l_bind_index) := p_search_mr_instance_rec.serial_number;
         ELSE
            l_unit_related_ii_sql := l_unit_related_ii_sql || 'and UPPER(csii.serial_number) like :SERIAL_NUMBER ';
            l_bindvar_tbl(l_bind_index) := UPPER(p_search_mr_instance_rec.serial_number);
         END IF;
         l_bind_index := l_bind_index + 1;
      END IF;

      IF p_search_mr_instance_rec.unit_name is NOT NULL THEN
        l_unit_related_ii_sql := l_unit_related_ii_sql || 'and csii.instance_id = uc.csi_item_instance_id ';
        IF p_module_type = 'VWP' THEN
           l_unit_related_ii_sql := l_unit_related_ii_sql || 'and uc.name like :UNIT_NAME ';
           l_bindvar_tbl(l_bind_index) := p_search_mr_instance_rec.unit_name;
        ELSE
           l_unit_related_ii_sql := l_unit_related_ii_sql || 'and UPPER(uc.name) like :UNIT_NAME ';
           l_bindvar_tbl(l_bind_index) := UPPER(p_search_mr_instance_rec.unit_name);
        END IF;
        l_bind_index := l_bind_index + 1;
      END IF;

      IF p_search_mr_instance_rec.components_flag = 'N' THEN
        l_unit_related_ii_sql := l_unit_related_ii_sql || 'and EXISTS (select ''x'' from ahl_unit_effectivities_b UE where UE.csi_item_instance_id = csii.instance_id)';
      END IF;

      AHL_OSP_UTIL_PKG.OPEN_SEARCH_CURSOR
      (
         p_conditions_tbl => l_bindvar_tbl,
         p_sql_str        => l_unit_related_ii_sql,
         p_x_csr          => l_cur
      );
      -- use dynamic cursor to execute query
      LOOP
         FETCH l_cur BULK COLLECT INTO l_inst_tbl LIMIT l_buffer_limit;
         EXIT WHEN (l_inst_tbl.count = 0);
         FOR j IN l_inst_tbl.FIRST..l_inst_tbl.LAST LOOP
           --FETCH l_cur INTO l_instance_id;
           --EXIT WHEN l_cur%NOTFOUND;
           INSERT INTO AHL_APPLICABLE_INSTANCES (CSI_ITEM_INSTANCE_ID, POSITION_ID) VALUES(l_inst_tbl(j),0);
         END LOOP; -- l_ue_id_tbl loop
         l_inst_tbl.DELETE;
      END LOOP;

      CLOSE l_cur;
    END IF;


END populate_instances;


PROCEDURE populate_dependent_instances(
    p_module_type            IN            VARCHAR2,
    p_search_mr_instance_rec IN            AHL_UMP_SMRINSTANCE_PVT.Search_MRInstance_Rec_Type)IS

   CURSOR dependent_components_csr IS
   SELECT subject_id from csi_ii_relationships csii WHERE
   EXISTS (select 'x' from ahl_unit_effectivities_b UE where UE.csi_item_instance_id = csii.subject_id)
   AND NOT EXISTS (select 'x' from AHL_APPLICABLE_INSTANCES where csi_item_instance_id = csii.subject_id)
   START WITH object_id IN (SELECT csi_item_instance_id FROM  AHL_APPLICABLE_INSTANCES WHERE POSITION_ID = 0)
   AND trunc(nvl(csii.active_start_date, sysdate)) <=  Trunc(sysdate)
   AND trunc(nvl(csii.active_end_date, sysdate+1)) > Trunc(sysdate)
   AND relationship_type_code = 'COMPONENT-OF'
   CONNECT BY PRIOR subject_id = object_id
   AND trunc(nvl(csii.active_start_date, sysdate)) <=  Trunc(sysdate)
   AND trunc(nvl(csii.active_end_date, sysdate+1)) > Trunc(sysdate)
   AND relationship_type_code = 'COMPONENT-OF';

   l_inst_tbl       nbr_tbl_type;
   l_buffer_limit number := 500;


BEGIN
    /*FOR dependent_component_rec IN dependent_components_csr
    LOOP
       INSERT INTO AHL_APPLICABLE_INSTANCES (CSI_ITEM_INSTANCE_ID, POSITION_ID)
       VALUES(dependent_component_rec.subject_id,1);
    END LOOP;*/

    OPEN dependent_components_csr;
    LOOP
         FETCH dependent_components_csr BULK COLLECT INTO l_inst_tbl LIMIT l_buffer_limit;
         EXIT WHEN (l_inst_tbl.count = 0);
         FOR j IN l_inst_tbl.FIRST..l_inst_tbl.LAST LOOP
           INSERT INTO AHL_APPLICABLE_INSTANCES (CSI_ITEM_INSTANCE_ID, POSITION_ID) VALUES(l_inst_tbl(j),1);
         END LOOP;
         l_inst_tbl.DELETE;
    END LOOP;

    CLOSE dependent_components_csr;


END populate_dependent_instances;

END AHL_UMP_SMRINSTANCE_PVT;

/
