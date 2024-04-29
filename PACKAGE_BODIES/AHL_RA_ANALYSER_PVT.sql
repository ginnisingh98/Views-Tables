--------------------------------------------------------
--  DDL for Package Body AHL_RA_ANALYSER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_RA_ANALYSER_PVT" AS
/* $Header: AHLVRAAB.pls 120.29.12000000.3 2007/05/09 10:37:38 mpothuku ship $*/

 G_PKG_NAME      CONSTANT    VARCHAR2(30)    := 'AHL_RA_ANALYSER_PVT';

    -- To log error messages into a log file if called from concurrent process.
    PROCEDURE log_error_messages;

    --  Start of Comments  --
    --
    --  Procedure name      : PROCESS_RA_DATA
    --  Type                : Private
    --  Function            : This API would create the setup data for Reliability Framework in AHL_RA_DEFINITION_HDR
    --  Pre-reqs            :
    --
    --  Standard IN  Parameters :
    --      p_api_version                   IN      NUMBER                Required
    --      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
    --
    --  Standard OUT Parameters :
    --      x_return_status                 OUT     VARCHAR2              Required
    --      x_msg_count                     OUT     NUMBER                Required
    --      x_msg_data                      OUT     VARCHAR2              Required
    --
    --  PROCESS_RA_DATA Parameters :
    --      p_start_date        IN DATE Required
    --      p_end_date          IN DATE Required
    --
    --  Version :
    --      Initial Version   1.0
    --
    --  End of Comments  --
    PROCEDURE PROCESS_RA_DATA (
        p_api_version               IN               NUMBER,
        p_init_msg_list             IN               VARCHAR2  := FND_API.G_FALSE,
        p_commit                    IN               VARCHAR2  := FND_API.G_FALSE,
        p_validation_level          IN               NUMBER    := FND_API.G_VALID_LEVEL_FULL,
        p_module_type               IN               VARCHAR2,
        x_return_status             OUT      NOCOPY  VARCHAR2,
        x_msg_count                 OUT      NOCOPY  NUMBER,
        x_msg_data                  OUT      NOCOPY  VARCHAR2,
        p_start_date                IN               DATE,
        p_end_date                  IN               DATE,
        p_concurrent_flag           IN               VARCHAR2,
        x_xml_data                  OUT      NOCOPY  CLOB) IS

    l_api_name      CONSTANT    VARCHAR2(30)    := 'PROCESS_RA_DATA';
    l_api_version   CONSTANT    NUMBER          := 1.0;
    L_FULL_NAME     CONSTANT    VARCHAR2(60)    := 'ahl.plsql.'||G_PKG_NAME || '.' || L_API_NAME;

    CURSOR c_setup_counter_data IS
        SELECT NEW.COUNTER_ID,                  -- l_tmp_new_ctr_id_tbl
               NEW.START_DATE_ACTIVE,           -- l_tmp_new_start_date_tbl
               NEW.END_DATE_ACTIVE,             -- l_tmp_new_end_date_tbl
               OVER.COUNTER_ID,                 -- l_tmp_over_ctr_id_tbl
               OVER.START_DATE_ACTIVE,          -- l_tmp_over_start_date_tbl
               OVER.END_DATE_ACTIVE             -- l_tmp_over_end_date_tbl
             FROM csi_counter_template_vl NEW,
                  csi_counter_template_vl OVER,
                  AHL_RA_CTR_ASSOCIATIONS CTR
            WHERE CTR.SINCE_NEW_COUNTER_ID = NEW.COUNTER_ID
              AND CTR.SINCE_OVERHAUL_COUNTER_ID = OVER.COUNTER_ID(+);

/*
-- Comment Here Starts
     -- This Cursor Usage is replaced by UA API Call below
    CURSOR c_flight_schedule_data(c_start_date DATE, c_end_date DATE) IS
        SELECT US.UNIT_SCHEDULE_ID,         -- l_fs_unit_sch_id_tbl
               US.ARRIVAL_ORG_ID,           -- l_fs_arr_org_id_tbl
               US.UNIT_CONFIG_HEADER_ID,    -- l_fs_uc_header_id_tbl
               US.CSI_ITEM_INSTANCE_ID,     -- l_fs_csi_instance_id_tbl
               ORG.organization_code,        -- l_fs_org_code_tbl
               TRUNC(NVL(US.ACTUAL_ARRIVAL_TIME,US.EST_ARRIVAL_TIME)) -- l_fs_arrival_date_tbl
          FROM AHL_UNIT_SCHEDULES_V US,org_organization_definitions org
         WHERE TRUNC(NVL(US.ACTUAL_ARRIVAL_TIME,US.EST_ARRIVAL_TIME)) BETWEEN C_START_DATE AND C_END_DATE
           AND ORG.ORGANIZATION_ID = US.ARRIVAL_ORG_ID
           AND UC_STATUS_CODE IN ('COMPLETE', 'INCOMPLETE');
-- Comment Here Ends
*/

/* -- Bug 4777658 : Perf Fix : Rewriting cursor c_uc_node_details below.
    -- Perf Fix -- MTL_SYSTEM_ITEMS need not be used here as DESCRIPTION can be fetched from MTL_SYSTEM_ITEMS_KFV
    CURSOR c_uc_node_details(c_csi_instance_id csi_ii_relationships.object_id%TYPE) IS
        SELECT CIIR.OBJECT_ID,                  -- l_dtls_object_id_tbl
               CIIR.SUBJECT_ID,                 -- l_dtls_subject_id_tbl
               DECODE(UC.CSI_ITEM_INSTANCE_ID,
                                         NULL,CIIR.POSITION_REFERENCE,
                                             (SELECT RELATIONSHIP_ID
                                                FROM AHL_MC_RELATIONSHIPS MCR,
                                                     AHL_UNIT_CONFIG_HEADERS UCI
                                               WHERE MCR.MC_HEADER_ID = UCI.MASTER_CONFIG_ID
                                                 AND MCR.PARENT_RELATIONSHIP_ID IS NULL
                                                 AND UCI.UNIT_CONFIG_HEADER_ID = AHL_UTIL_UC_PKG.GET_SUB_UC_HEADER_ID(UC.CSI_ITEM_INSTANCE_ID))),   -- l_dtls_pos_ref_tbl
               CII.INVENTORY_ITEM_ID,           -- l_dtls_inv_item_id_tbl
               CII.INV_MASTER_ORGANIZATION_ID,  -- l_dtls_inv_master_org_id_tbl
               CII.INVENTORY_REVISION,          -- l_dtls_inv_revision_tbl
               CII.QUANTITY,                    -- l_dtls_quantity_tbl
               CII.UNIT_OF_MEASURE,             -- l_dtls_uom_tbl
               CII.SERIAL_NUMBER,               -- l_dtls_srl_no_tbl
               KFV.CONCATENATED_SEGMENTS,       -- l_dtls_item_name_tbl
               KFV.DESCRIPTION                  -- l_dtls_item_desc_tbl
          FROM CSI_II_RELATIONSHIPS CIIR,
               CSI_ITEM_INSTANCES CII,
               --MTL_SYSTEM_ITEMS MSI,
               MTL_SYSTEM_ITEMS_KFV KFV,
               AHL_UNIT_CONFIG_HEADERS UC
         WHERE CII.INSTANCE_ID = CIIR.SUBJECT_ID
           AND CII.INVENTORY_ITEM_ID = KFV.INVENTORY_ITEM_ID
           AND CII.INV_MASTER_ORGANIZATION_ID = KFV.ORGANIZATION_ID
           --AND KFV.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
           --AND KFV.ORGANIZATION_ID = MSI.ORGANIZATION_ID
           AND UC.CSI_ITEM_INSTANCE_ID(+) = CIIR.SUBJECT_ID
        START WITH CIIR.OBJECT_ID = c_csi_instance_id
               AND CIIR.RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
               AND TRUNC(NVL(CIIR.ACTIVE_START_DATE,SYSDATE)) <= TRUNC(SYSDATE)
               AND TRUNC(SYSDATE) < TRUNC(NVL(CIIR.ACTIVE_END_DATE,SYSDATE+1))
        CONNECT BY PRIOR CIIR.SUBJECT_ID = CIIR.OBJECT_ID
               AND CIIR.RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
               AND TRUNC(NVL(CIIR.ACTIVE_START_DATE,SYSDATE)) <= TRUNC(SYSDATE)
               AND TRUNC(SYSDATE) < TRUNC(NVL(CIIR.ACTIVE_END_DATE,SYSDATE+1));
*/

-- Bug 4777658 : Perf Fix : Modified Cursor

CURSOR c_uc_node_details(c_csi_instance_id csi_ii_relationships.object_id%TYPE) IS
 Select A.OBJECT_ID,                   -- l_dtls_object_id_tbl
        A.SUBJECT_ID,                  -- l_dtls_subject_id_tbl
        DECODE(A.CSI_ITEM_INSTANCE_ID,
                                 NULL,A.POSITION_REFERENCE,
                                      MCR.RELATIONSHIP_ID) X, -- l_dtls_pos_ref_tbl
        A.INVENTORY_ITEM_ID,           -- l_dtls_inv_item_id_tbl
        A.INV_MASTER_ORGANIZATION_ID,  -- l_dtls_inv_master_org_id_tbl
        A.INVENTORY_REVISION,          -- l_dtls_inv_revision_tbl
        A.QUANTITY,                    -- l_dtls_quantity_tbl
        A.UNIT_OF_MEASURE,             -- l_dtls_uom_tbl
        A.SERIAL_NUMBER,               -- l_dtls_srl_no_tbl
        A.CONCATENATED_SEGMENTS,       -- l_dtls_item_name_tbl
        A.DESCRIPTION,                  -- l_dtls_item_desc_tbl
        --Added by mpothuku on 09-Nov-2006 for fixing the Bug# 5651645
        /* This is a point of contention. For MTBF flow, the header node for the Sub-config is considered for
        MTBF definition. But for part changes, the position_key correspnding to the node where the sub-config is considered
        So we need to consider both */
        A.POSITION_REFERENCE           --l_dtls_pos_ref_his_tbl
   FROM (SELECT CIIR.OBJECT_ID,                                 -- l_dtls_object_id_tbl
                CIIR.SUBJECT_ID,                                -- l_dtls_subject_id_tbl
                CII.INVENTORY_ITEM_ID,                          -- l_dtls_inv_item_id_tbl
                CII.INV_MASTER_ORGANIZATION_ID,                 -- l_dtls_inv_master_org_id_tbl
                CII.INVENTORY_REVISION,                         -- l_dtls_inv_revision_tbl
                CII.QUANTITY,                                   -- l_dtls_quantity_tbl
                CII.UNIT_OF_MEASURE,                            -- l_dtls_uom_tbl
                CII.SERIAL_NUMBER,                              -- l_dtls_srl_no_tbl
                KFV.CONCATENATED_SEGMENTS,                      -- l_dtls_item_name_tbl
                KFV.DESCRIPTION,                                -- l_dtls_item_desc_tbl
                UC.CSI_ITEM_INSTANCE_ID,
                CIIR.POSITION_REFERENCE,
                UCI.MASTER_CONFIG_ID
           FROM (           Select CIIRI.SUBJECT_ID ,
                                   CIIRI.OBJECT_ID ,
                                   CIIRI.POSITION_REFERENCE
                              from CSI_II_RELATIONSHIPS CIIRI
                        START WITH CIIRI.OBJECT_ID = c_csi_instance_id
                               AND CIIRI.RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
                               AND TRUNC(NVL(CIIRI.ACTIVE_START_DATE,SYSDATE)) <= TRUNC(SYSDATE)
                               AND TRUNC(SYSDATE) < TRUNC(NVL(CIIRI.ACTIVE_END_DATE,SYSDATE+1))
                  CONNECT BY PRIOR CIIRI.SUBJECT_ID = CIIRI.OBJECT_ID
                               AND CIIRI.RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
                               AND TRUNC(NVL(CIIRI.ACTIVE_START_DATE,SYSDATE)) <= TRUNC(SYSDATE)
                               AND TRUNC(SYSDATE) < TRUNC(NVL(CIIRI.ACTIVE_END_DATE,SYSDATE+1))) CIIR,
                CSI_ITEM_INSTANCES CII,
                MTL_SYSTEM_ITEMS_KFV KFV,
                AHL_UNIT_CONFIG_HEADERS UC,
                AHL_UNIT_CONFIG_HEADERS UCI
          WHERE CII.INSTANCE_ID = CIIR.SUBJECT_ID
            AND CII.INVENTORY_ITEM_ID = KFV.INVENTORY_ITEM_ID
            AND CII.INV_MASTER_ORGANIZATION_ID = KFV.ORGANIZATION_ID
            AND UC.CSI_ITEM_INSTANCE_ID(+) = CIIR.SUBJECT_ID
            AND UCI.UNIT_CONFIG_HEADER_ID(+) = AHL_UTIL_UC_PKG.GET_SUB_UC_HEADER_ID(UC.CSI_ITEM_INSTANCE_ID)) A,
        AHL_MC_RELATIONSHIPS MCR
  WHERE MCR.MC_HEADER_ID(+) = A.MASTER_CONFIG_ID
    AND nvl(MCR.PARENT_RELATIONSHIP_ID,-1) = -1;

    CURSOR c_get_mtbf_data(c_relationship_id AHL_RA_DEFINITION_HDR.RELATIONSHIP_ID%TYPE,
                           c_inv_item_id AHL_RA_DEFINITION_HDR.INVENTORY_ITEM_ID%TYPE,
                           c_inv_org_id AHL_RA_DEFINITION_HDR.INVENTORY_ORG_ID%TYPE,
                           c_inv_item_revision AHL_RA_DEFINITION_HDR.ITEM_REVISION%TYPE) IS
        SELECT DTLS.COUNTER_ID,
               DTLS.MTBF_VALUE
          FROM AHL_RA_DEFINITION_HDR HDR,
               AHL_RA_DEFINITION_DTLS DTLS
         WHERE HDR.RA_DEFINITION_HDR_ID = DTLS.RA_DEFINITION_HDR_ID
           AND HDR.RELATIONSHIP_ID = TO_NUMBER(c_relationship_id)
           AND HDR.INVENTORY_ITEM_ID = c_inv_item_id
           AND HDR.INVENTORY_ORG_ID = c_inv_org_id
           AND (HDR.ITEM_REVISION IS NULL OR HDR.ITEM_REVISION = c_inv_item_revision)
--           AND nvl(HDR.ITEM_REVISION,-1) = nvl(c_inv_item_revision,-1)
           AND DTLS.MTBF_VALUE IS NOT NULL;

    CURSOR c_get_path_postions(c_relationship_id AHL_RA_DEFINITION_HDR.RELATIONSHIP_ID%TYPE) IS
        Select pos.path_position_id
          from ahl_mc_path_position_nodes pos,
               ahl_mc_relationships rel,
               ahl_mc_headers_b hdr
         where rel.mc_header_id = hdr.mc_header_id
           and rel.relationship_id = to_number(c_relationship_id)
           and hdr.mc_id = pos.mc_id
           and hdr.version_number = nvl(pos.version_number, hdr.version_number)
           and pos.position_key = rel.position_key
           and pos.sequence in (select max(sequence)
                                  from ahl_mc_path_position_nodes
                                 where path_position_id = pos.path_position_id);

    CURSOR c_fetch_dummy_assocs(c_fct_designator AHL_RA_FCT_ASSOCIATIONS.FORECAST_DESIGNATOR%TYPE,
                                c_arrival_org_id AHL_RA_FCT_ASSOCIATIONS.ORGANIZATION_ID%TYPE) IS
        Select FORECAST_DESIGNATOR
          from AHL_RA_FCT_ASSOCIATIONS
         where ASSOCIATION_TYPE_CODE = 'ASSOC_HISTORICAL'
           and FORECAST_DESIGNATOR <> c_fct_designator
           and ORGANIZATION_ID = c_arrival_org_id;

    -- Temp Tables used for fetching data from c_setup_counter_data.
    -- Bulk Counter details data fetched would be further filtered using condition that the analyser input
    -- start date and end date should fall between active dates of counter setup defined in CSI.
    -- These tables have one - to - one correspondance to each another.
    l_tmp_new_ctr_id_tbl          NumTabType;
    l_tmp_new_start_date_tbl      DateTabType;
    l_tmp_new_end_date_tbl        DateTabType;
    l_tmp_over_ctr_id_tbl         NumTabType;
    l_tmp_over_start_date_tbl     DateTabType;
    l_tmp_over_end_date_tbl       DateTabType;

    -- Table to store the final value of counter ids to be used to evaluate the probability of failure.
    -- These tables have one - to - one correspondance to each another.
    -- These tables have one - to - one correspondance to each another.
    l_since_new_ctr_id_tbl        NumTabType;
    l_since_oh_ctr_id_tbl         NumTabType;

    -- Temp Tables used for fetching data from c_flight_schedule_data.
    -- These tables have one - to - one correspondance to each another.
    l_fs_unit_sch_id_tbl          NumTabType;
    l_fs_arr_org_id_tbl           NumTabType;
    l_fs_uc_header_id_tbl         NumTabType;
    l_fs_csi_instance_id_tbl      NumTabType;
    l_fs_arrival_date_tbl         DateTabType;
    l_fs_org_code_tbl             Varchar3TabType;
    l_flight_search_rec_type      AHL_UA_FLIGHT_SCHEDULES_PUB.FLIGHT_SEARCH_REC_TYPE;
    l_flight_schedules_tbl        AHL_UA_FLIGHT_SCHEDULES_PVT.FLIGHT_SCHEDULES_TBL_TYPE;
    l_fs_index                    NUMBER := 1;

    -- Temp Tables used for fetching data from c_uc_node_details
    -- These tables have one - to - one correspondance to each another.
    l_dtls_object_id_tbl          NumTabType;
    l_dtls_subject_id_tbl         NumTabType;
    l_dtls_pos_ref_tbl            Varchar30TabType;
    l_dtls_inv_item_id_tbl        NumTabType;
    l_dtls_inv_master_org_id_tbl  NumTabType;
    l_dtls_inv_revision_tbl       Varchar3TabType;
    l_dtls_quantity_tbl           NumTabType;
    l_dtls_uom_tbl                Varchar3TabType;
    l_dtls_srl_no_tbl             Varchar30TabType;
    l_dtls_item_name_tbl          Varchar40TabType;
    l_dtls_item_desc_tbl          Varchar240TabType;
    --Modified by mpothuku on 09-Nov-2006 for fixing the Bug# 5651645
    l_dtls_pos_ref_his_tbl        Varchar30TabType;

    -- These temp variables have one - to - one correspondance to each another.
    l_root_pos_ref_code           AHL_MC_RELATIONSHIPS.RELATIONSHIP_ID%TYPE;
    l_root_quantity               CSI_ITEM_INSTANCES.QUANTITY%TYPE;
    l_root_uom                    CSI_ITEM_INSTANCES.UNIT_OF_MEASURE%TYPE;
    l_root_inv_item_id            CSI_ITEM_INSTANCES.INVENTORY_ITEM_ID%TYPE;
    l_root_inv_master_org_id      CSI_ITEM_INSTANCES.INV_MASTER_ORGANIZATION_ID%TYPE;
    l_root_item_revision          CSI_ITEM_INSTANCES.INVENTORY_REVISION%TYPE;
    l_root_srl_no                 CSI_ITEM_INSTANCES.SERIAL_NUMBER%TYPE;
    l_root_item_name              MTL_SYSTEM_ITEMS_KFV.CONCATENATED_SEGMENTS%TYPE;
    l_root_item_desc              MTL_SYSTEM_ITEMS_KFV.DESCRIPTION%TYPE;


    -- Table Type to retrieve Counters Associated to a Item Instance.
    l_ctr_values_tbl              AHL_UMP_PROCESSUNIT_PVT.counter_values_tbl_type;
    l_active_ctr_id_tbl           NumTabType;
    l_active_ctr_temp_id_tbl      Num15TabType;
    l_active_ctr_name_tbl         Varchar80TabType;
    l_active_ctr_value_tbl        NumTabType;
    l_active_uom_code_tbl         Varchar3TabType;
    l_ctr_template_id             csi_counters_vl.CREATED_FROM_COUNTER_TMPL_ID%TYPE;

    -- This is used for active counters table index
    l_ctr_index                   NUMBER := 1;

    -- Return Status Handling
    l_msg_count                   NUMBER :=0;
    l_return_status               VARCHAR2(2000);
    l_msg_data                    VARCHAR2(2000);
    l_msg_index_out  NUMBER;

    -- Temp Tables used for fetching data from c_get_mtbf_data.
    -- These tables have one - to - one correspondance to each another.
    l_mtbf_ctr_id_tbl             Num15TabType;
    l_mtbf_value_tbl              NumTabType;

    -- For Path Position Handling for each Item Instance
    l_path_pos_exist_flag         VARCHAR2(1) := 'N';
    l_path_position_id_tbl        NumTabType;

    -- These variables will store the Probability Attribs - A,B,C,D
    l_prob_attrib_a               NUMBER := 0;
    l_prob_attrib_b               NUMBER := 0;
    l_prob_attrib_b_tmp           NUMBER := 0;
    l_prob_attrib_c               NUMBER := 0;
    l_prob_attrib_c_tmp           NUMBER := 0;
    l_prob_attrib_d               NUMBER := 0;
    l_prob_value                  NUMBER := 0;
    l_prob_value_tmp              NUMBER := 0;

    -- This is used to store the Forecast Designator for each Item Instance Id
    l_fct_designator              VARCHAR2(10) := NULL;

    -- Index for l_forecast_interface_tbl
    l_fct_index                   NUMBER := 1;

    -- Index for l_forecast_designator_tbl
    l_dsg_index                   NUMBER := 1;
    -- To indicate if duplicate forecast_desginator is already populated in l_forecast_designator_tbl
    l_ds_rec_found                VARCHAR2(1) := 'N';


    -- This is used for each item instance to indicate if MTBF Data is defined or not
    l_mtbf_data_defined           VARCHAR2(1) := 'N';
    l_mtbf_value_exceeds          VARCHAR2(1) := 'N';

    -- Plsql Table of rec type MRP_FORECAST_INTERFACE_PK.rec_forecast_interface
    l_forecast_interface_tbl      MRP_FORECAST_INTERFACE_PK.t_forecast_interface;
    l_forecast_designator_tbl     MRP_FORECAST_INTERFACE_PK.t_forecast_designator;
    l_forecast_org_code_tbl       Varchar3TabType;
    l_forecast_srl_no_tbl         Varchar30TabType;
    l_forecast_item_name_tbl      Varchar40TabType;
    l_forecast_onhand_qty_tbl     NumTabType;
    l_forecast_item_desc_tbl      Varchar240TabType;
    l_forecast_req_prob_tbl       NumTabType;
    l_forecast_osp_qty_tbl        NumTabType;
    l_forecast_vwp_qty_tbl        NumTabType;
    l_forecast_non_qty_tbl        NumTabType;

    -- For ATP Call - Check Availability API
    l_atp_rec                       MRP_ATP_PUB.ATP_Rec_Typ;
    x_atp_rec                       MRP_ATP_PUB.ATP_Rec_Typ;
    x_atp_supply_demand             MRP_ATP_PUB.ATP_Supply_Demand_Typ;
    x_atp_period                    MRP_ATP_PUB.ATP_Period_Typ;
    x_atp_details                   MRP_ATP_PUB.ATP_Details_Typ;
    l_session_id                    NUMBER;

    -- Dummy PLSql table to fetch dummy forecast associations for population MRP with residual of 100% Probability.
    l_dummy_fct_desg_tbl          Varchar10TabType;
    l_incl_in_rpt_flag_tbl        Varchar1TabType;

    l_mrp_api_return_flag         BOOLEAN := FALSE;

    -- Used to Write to O/P File
    l_fct_data_lob CLOB;
    l_row_count    NUMBER  :=0;
    --mpothuku changed the length from 1000 to 5000 on 09-May-2007 after the XML encoding has been introduced to fix the Bug 6038466
    l_dummy_string VARCHAR2(5000);

    l_dummy_identifier NUMBER;

    BEGIN

        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_procedure,L_FULL_NAME||'.begin','At the start of PLSQL procedure');
        END IF;

        IF (p_concurrent_flag = 'Y') THEN
            fnd_file.put_line(fnd_file.log, 'RA Analyser Process  ---- START ----');
        END IF;

        -- Standard start of API savepoint
        SAVEPOINT PROCESS_RA_DATA_SP;

        -- Standard call to check for call compatibility
        IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE
        IF FND_API.To_Boolean(p_init_msg_list) THEN
           FND_MSG_PUB.Initialize;
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_statement,l_full_name,'RA -- PKG -- PROCESS_RA_DATA -------BEGIN-----------');
            fnd_log.string(fnd_log.level_statement,l_full_name,'RA -- PKG -- PROCESS_RA_DATA -------p_start_date-----------' || p_start_date);
            fnd_log.string(fnd_log.level_statement,l_full_name,'RA -- PKG -- PROCESS_RA_DATA -------p_end_date-----------' || p_end_date);
        END IF;

        IF (p_concurrent_flag = 'Y') THEN
            fnd_file.put_line(fnd_file.log, 'RA Analyser Process  ---- Validating Start / End Date ----');
        END IF;

        -- Input Data Validation
        -- p_start_date and p_end_date should not be null.
        -- p_start_date should be less than equal to p_end_date
        -- p_start_date and p_end_date should not be less than sysdate
        IF (   (p_start_date IS NULL)
            OR (p_end_date IS NULL)
            OR (p_start_date > p_end_date)
            OR (p_start_date < trunc(sysdate))
            OR (p_end_date < trunc(sysdate))
           ) THEN

             IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                 fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed --');
                 fnd_log.string(fnd_log.level_statement,l_full_name,'-- p_start_date -- '||p_start_date);
                 fnd_log.string(fnd_log.level_statement,l_full_name,'-- p_end_date -- '||p_end_date);
             END IF;
             IF (p_concurrent_flag = 'Y') THEN
                fnd_file.put_line(fnd_file.log, '-- Invalid Param Passed -- Dates Validation Failed');
             END IF;
             FND_MESSAGE.Set_Name('AHL','AHL_RA_INV_PARAM_PASSED');
             FND_MESSAGE.Set_Token('NAME','ANALYSER.PROCESS_DATA');
             FND_MSG_PUB.ADD;
             Raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF (p_concurrent_flag = 'Y') THEN
            fnd_file.put_line(fnd_file.log, 'RA Analyser Process  ---- Fetching Counter Details Data from Setup ----');
        END IF;

        -- Fetch Counter Details Data from Setup
        OPEN c_setup_counter_data;
             IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                 fnd_log.string(fnd_log.level_statement,l_full_name,' Bulk Fetching Counter Details Data from Setup');
             END IF;
             IF (p_concurrent_flag = 'Y') THEN
                fnd_file.put_line(fnd_file.log, '-- Bulk Fetching Counter Details Data from Setup --');
             END IF;
             FETCH c_setup_counter_data
              BULK COLLECT INTO l_tmp_new_ctr_id_tbl,
                                l_tmp_new_start_date_tbl,
                                l_tmp_new_end_date_tbl,
                                l_tmp_over_ctr_id_tbl,
                                l_tmp_over_start_date_tbl,
                                l_tmp_over_end_date_tbl;
             IF l_tmp_new_ctr_id_tbl.COUNT = 0 THEN
                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                   fnd_log.string(fnd_log.level_statement,l_full_name,' No Setup Data Found for Counters');
                END IF;
                IF (p_concurrent_flag = 'Y') THEN
                   fnd_file.put_line(fnd_file.log, '-- No Setup Data Found for Counters --');
                END IF;
             END IF;
        CLOSE c_setup_counter_data;

        --Filtering Counter Setup Data based on Active Dates
        IF l_tmp_new_ctr_id_tbl.COUNT > 0 THEN

           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
               fnd_log.string(fnd_log.level_statement,l_full_name,'Filtering Counter Setup Data based on Active Dates - '||l_tmp_new_ctr_id_tbl.COUNT);
               fnd_log.string(fnd_log.level_statement,l_full_name,'Analyser Start Date - '||p_start_date);
               fnd_log.string(fnd_log.level_statement,l_full_name,'Analyser End Date - '||p_end_date);
           END IF;

           IF (p_concurrent_flag = 'Y') THEN
               fnd_file.put_line(fnd_file.log, 'RA Analyser Process  ---- Validating Active Dates of Counter Setup Data ----');
           END IF;

           FOR i IN l_tmp_new_ctr_id_tbl.FIRST .. l_tmp_new_ctr_id_tbl.LAST LOOP -- loop for Setup Cunters fetched

               IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                   fnd_log.string(fnd_log.level_statement,l_full_name,'Looping for (i) - '||i);
                   fnd_log.string(fnd_log.level_statement,l_full_name,'l_tmp_new_ctr_id_tbl - '||l_tmp_new_ctr_id_tbl(i));
                   fnd_log.string(fnd_log.level_statement,l_full_name,'l_tmp_new_start_date_tbl - '||l_tmp_new_start_date_tbl(i));
                   fnd_log.string(fnd_log.level_statement,l_full_name,'l_tmp_new_end_date_tbl - '||l_tmp_new_end_date_tbl(i));
                   fnd_log.string(fnd_log.level_statement,l_full_name,'l_tmp_over_ctr_id_tbl - '||l_tmp_over_ctr_id_tbl(i));
                   fnd_log.string(fnd_log.level_statement,l_full_name,'l_tmp_over_start_date_tbl - '||l_tmp_over_start_date_tbl(i));
                   fnd_log.string(fnd_log.level_statement,l_full_name,'l_tmp_over_end_date_tbl - '||l_tmp_over_end_date_tbl(i));
               END IF;

               IF ((trunc(nvl(l_tmp_new_start_date_tbl(i),p_start_date)) <= trunc(p_start_date)) AND
                   (trunc(nvl(l_tmp_new_end_date_tbl(i),p_end_date + 1)) > trunc(p_end_date))) THEN
                   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                       fnd_log.string(fnd_log.level_statement,l_full_name,'Including Since New - l_since_new_ctr_id_tbl -'||i||'-'||l_tmp_new_ctr_id_tbl(i));
                   END IF;
                   l_since_new_ctr_id_tbl(i) := l_tmp_new_ctr_id_tbl(i);
               ELSE
                   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                       fnd_log.string(fnd_log.level_statement,l_full_name,'Omiting Since New - l_tmp_new_ctr_id_tbl -'||i||'-'||l_tmp_new_ctr_id_tbl(i));
                   END IF;
                   l_since_new_ctr_id_tbl(i) := null;
               END IF;

               IF (l_tmp_over_ctr_id_tbl(i) IS NOT NULL) THEN
                   IF ((trunc(nvl(l_tmp_over_start_date_tbl(i),p_start_date)) <= trunc(p_start_date)) AND
                       (trunc(nvl(l_tmp_over_end_date_tbl(i),p_end_date + 1)) > trunc(p_end_date))) THEN
                       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                           fnd_log.string(fnd_log.level_statement,l_full_name,'Including Since Overhaul - l_since_oh_ctr_id_tbl -'||i||'-'||l_tmp_over_ctr_id_tbl(i));
                       END IF;
                       l_since_oh_ctr_id_tbl(i) := l_tmp_over_ctr_id_tbl(i);
                   ELSE
                   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                       fnd_log.string(fnd_log.level_statement,l_full_name,'Omiting Since Overhaul - l_tmp_over_ctr_id_tbl -'||i||'-'||l_tmp_over_ctr_id_tbl(i));
                   END IF;
                       l_since_oh_ctr_id_tbl(i) := null;
                   END IF;
               ELSE
                   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                       fnd_log.string(fnd_log.level_statement,l_full_name,'Omiting Since Overhaul - l_tmp_over_ctr_id_tbl -'||i||'-'||l_tmp_over_ctr_id_tbl(i));
                   END IF;
                   l_since_oh_ctr_id_tbl(i) := null;
               END IF;

           END LOOP; -- End Loop for Setup Counters Fetched

           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
               IF l_since_new_ctr_id_tbl.COUNT > 0 THEN
                  FOR t in l_since_new_ctr_id_tbl.FIRST .. l_since_new_ctr_id_tbl.LAST LOOP
                      fnd_log.string(fnd_log.level_statement,l_full_name,' --- l_since_new_ctr_id_tbl --- '||l_since_new_ctr_id_tbl(t));
                      fnd_log.string(fnd_log.level_statement,l_full_name,' --- l_since_oh_ctr_id_tbl --- '||l_since_oh_ctr_id_tbl(t));
                  END LOOP;
               END IF;
           END IF;

        ELSE

           IF (p_concurrent_flag = 'Y') THEN
               fnd_file.put_line(fnd_file.log, 'RA Analyser Process  ---- No Counter Setup Done for Active Counters --');
           END IF;

           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
               fnd_log.string(fnd_log.level_statement,l_full_name,' No Setup Data Found for Counters - In Loop Else Clause');
           END IF;
        END IF;

        -- Return if no applicable Counters are retrieved
        IF l_since_new_ctr_id_tbl.COUNT = 0 THEN
           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
               fnd_log.string(fnd_log.level_statement,l_full_name,'None of the defined counters - are active as per date');
           END IF;
           IF (p_concurrent_flag = 'Y') THEN
               fnd_file.put_line(fnd_file.log, 'RA Analyser Process  ---- No Counter Setup - Non Active afer Data Validation - so returning ----');
           END IF;

        ELSE

            IF (p_concurrent_flag = 'Y') THEN
                fnd_file.put_line(fnd_file.log, 'RA Analyser Process  ---- Fetching Flight Schedule Data ----');
            END IF;

/*
-- Comment Here Starts
            -- Commenting out Code Below for fetching Flight Schedule Data using cursor c_flight_schedule_data
            -- Instead UA API is being called to derive the flight schedule data
            -- Fetch Flight Schedules Data For Processing
            OPEN c_flight_schedule_data(p_start_date,p_end_date);
                 IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                     fnd_log.string(fnd_log.level_statement,l_full_name,' Bulk Fetching Flight Schedules Data For Processing');
                 END IF;
                 IF (p_concurrent_flag = 'Y') THEN
                     fnd_file.put_line(fnd_file.log, ' Bulk Fetching Flight Schedules Data For Processing');
                 END IF;
                 FETCH c_flight_schedule_data
                  BULK COLLECT INTO l_fs_unit_sch_id_tbl,
                                    l_fs_arr_org_id_tbl,
                                    l_fs_uc_header_id_tbl,
                                    l_fs_csi_instance_id_tbl,
                                    l_fs_org_code_tbl,
                                    l_fs_arrival_date_tbl;
                 IF l_fs_unit_sch_id_tbl.COUNT = 0 THEN
                    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                       fnd_log.string(fnd_log.level_statement,l_full_name,' No Flight Schedules Data Retrieved');
                    END IF;
                    IF (p_concurrent_flag = 'Y') THEN
                        fnd_file.put_line(fnd_file.log, ' No Flight Schedules Data Retrieved');
                    END IF;
                 ELSE
                    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                       fnd_log.string(fnd_log.level_statement,l_full_name,' Flight Schedules Data Retrieved'||l_fs_unit_sch_id_tbl.COUNT);
                    END IF;
                    IF (p_concurrent_flag = 'Y') THEN
                        fnd_file.put_line(fnd_file.log, 'Flight Schedules Data Retrieved'||l_fs_unit_sch_id_tbl.COUNT);
                    END IF;
                 END IF;
            CLOSE c_flight_schedule_data;
-- Comment Here Ends
*/

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string(fnd_log.level_statement,l_full_name,' Bulk Fetching Flight Schedules Data For Processing - UA API');
            END IF;
            IF (p_concurrent_flag = 'Y') THEN
                fnd_file.put_line(fnd_file.log, ' Bulk Fetching Flight Schedules Data For Processing - UA API');
            END IF;

            l_flight_search_rec_type.START_DATE := p_start_date - 1;
            l_flight_search_rec_type.END_DATE := p_end_date + 1;
            l_flight_search_rec_type.DATE_APPLY_TO_FLAG := AHL_UA_FLIGHT_SCHEDULES_PUB.G_APPLY_TO_ARRIVAL;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string(fnd_log.level_statement,l_full_name,' START_DATE - UA API' || l_flight_search_rec_type.START_DATE);
                fnd_log.string(fnd_log.level_statement,l_full_name,' END_DATE - UA API' || l_flight_search_rec_type.END_DATE);
                fnd_log.string(fnd_log.level_statement,l_full_name,' DATE_APPLY_TO_FLAG - UA API : ' || l_flight_search_rec_type.DATE_APPLY_TO_FLAG);
            END IF;

            AHL_UA_FLIGHT_SCHEDULES_PUB.Get_Flight_Schedule_Details(
                -- standard IN params
                p_api_version           => 1,
                p_init_msg_list         => FND_API.G_FALSE,
                p_commit                => FND_API.G_FALSE,
                p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
                p_default               => FND_API.G_FALSE,
                p_module_type           => NULL,
                -- standard OUT params
                x_return_status         => l_return_status,
                x_msg_count             => l_msg_count,
                x_msg_data              => l_msg_data,
                -- procedure params
                p_flight_search_rec     => l_flight_search_rec_type,
                x_flight_schedules_tbl  => l_flight_schedules_tbl);

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                   fnd_log.string(fnd_log.level_statement,l_full_name,'Called API AHL_UA_FLIGHT_SCHEDULES_PUB.Get_Flight_Schedule_Details Errored');
               END IF;
               IF (p_concurrent_flag = 'Y') THEN
                   fnd_file.put_line(fnd_file.log, 'RA Analyser Process  ---- Error in getting Flight Scedule Details --');
               END IF;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            IF l_flight_schedules_tbl.COUNT > 0 THEN
               FOR f in l_flight_schedules_tbl.FIRST .. l_flight_schedules_tbl.LAST LOOP
                   IF (AHL_UTIL_UC_PKG.IS_UNIT_QUARANTINED(l_flight_schedules_tbl(f).UNIT_CONFIG_HEADER_ID,NULL) = FND_API.G_FALSE) THEN
                       l_fs_unit_sch_id_tbl(l_fs_index)         := l_flight_schedules_tbl(f).UNIT_SCHEDULE_ID;
                       l_fs_arr_org_id_tbl(l_fs_index)          := l_flight_schedules_tbl(f).ARRIVAL_ORG_ID;
                       l_fs_uc_header_id_tbl(l_fs_index)        := l_flight_schedules_tbl(f).UNIT_CONFIG_HEADER_ID;
                       l_fs_csi_instance_id_tbl(l_fs_index)     := l_flight_schedules_tbl(f).CSI_INSTANCE_ID;
                       l_fs_org_code_tbl(l_fs_index)            := l_flight_schedules_tbl(f).ARRIVAL_ORG_CODE;
                       IF  TRUNC(l_flight_schedules_tbl(f).ACTUAL_ARRIVAL_TIME) IS NULL THEN
                          l_fs_arrival_date_tbl(l_fs_index)     := TRUNC(l_flight_schedules_tbl(f).EST_ARRIVAL_TIME);
                       ELSE
                          l_fs_arrival_date_tbl(l_fs_index)     := TRUNC(l_flight_schedules_tbl(f).ACTUAL_ARRIVAL_TIME);
                       END IF;
                       l_fs_index := l_fs_index + 1;
                   END IF;
                END LOOP;
            END IF;
            IF (p_concurrent_flag = 'Y') THEN
                fnd_file.put_line(fnd_file.log, 'RA Analyser Process  ---- Flight Schedule Data fetched ----'||l_fs_unit_sch_id_tbl.COUNT);
            END IF;

            IF l_fs_unit_sch_id_tbl.COUNT > 0 THEN
               -- Loop for each Unit in the Unit Schedule Record fetched above.
               IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                   fnd_log.string(fnd_log.level_statement,l_full_name,' ----- LOOP FOR FLIGHT SCHEDULE BEGINS ----- '||l_fs_unit_sch_id_tbl.COUNT);
               END IF;
               IF (p_concurrent_flag = 'Y') THEN
                   fnd_file.put_line(fnd_file.log, 'RA Analyser Process  ---- Processing Fligth Schedule Data ----');
               END IF;

               FOR i in l_fs_unit_sch_id_tbl.FIRST .. l_fs_unit_sch_id_tbl.LAST LOOP -- Loop for each Unit in the Unit Schedule Record fetched above.
                   -- Fetch details of the Root node of the UC
                   BEGIN

                        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                            fnd_log.string(fnd_log.level_statement,l_full_name,' ----- IN FS LOOP - l_fs_unit_sch_id_tbl ----- '||l_fs_unit_sch_id_tbl(i));
                            fnd_log.string(fnd_log.level_statement,l_full_name,' ----- IN FS LOOP - l_fs_arr_org_id_tbl ----- '||l_fs_arr_org_id_tbl(i));
                            fnd_log.string(fnd_log.level_statement,l_full_name,' ----- IN FS LOOP - l_fs_uc_header_id_tbl ----- '||l_fs_uc_header_id_tbl(i));
                            fnd_log.string(fnd_log.level_statement,l_full_name,' ----- IN FS LOOP - l_fs_csi_instance_id_tbl ----- '||l_fs_csi_instance_id_tbl(i));
                            fnd_log.string(fnd_log.level_statement,l_full_name,' ----- IN FS LOOP - l_fs_org_code_tbl ----- '||l_fs_org_code_tbl(i));
                            fnd_log.string(fnd_log.level_statement,l_full_name,' ----- IN FS LOOP - l_fs_arrival_date_tbl ----- '||l_fs_arrival_date_tbl(i));
                        END IF;
                        IF (p_concurrent_flag = 'Y') THEN
                            fnd_file.put_line(fnd_file.log, 'RA Analyser Process  ---- Fetching UC Root Node Details ----');
                        END IF;

                        Select MCR.RELATIONSHIP_ID,
                               CII.QUANTITY,
                               CII.UNIT_OF_MEASURE,
                               CII.INVENTORY_ITEM_ID,
                               CII.INV_MASTER_ORGANIZATION_ID,
                               CII.INVENTORY_REVISION,
                               CII.SERIAL_NUMBER,
                               KFV.CONCATENATED_SEGMENTS,
                               KFV.DESCRIPTION
                          INTO l_root_pos_ref_code,
                               l_root_quantity,
                               l_root_uom,
                               l_root_inv_item_id,
                               l_root_inv_master_org_id,
                               l_root_item_revision,
                               l_root_srl_no,
                               l_root_item_name,
                               l_root_item_desc
                          FROM AHL_UNIT_CONFIG_HEADERS UC,
                               CSI_ITEM_INSTANCES CII,
                               MTL_SYSTEM_ITEMS_KFV KFV,
                               ahl_mc_relationships MCR
                         WHERE UC.UNIT_CONFIG_HEADER_ID = l_fs_uc_header_id_tbl(i)
                           AND UC.CSI_ITEM_INSTANCE_ID = CII.INSTANCE_ID
                           AND KFV.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
                           AND KFV.ORGANIZATION_ID = CII.INV_MASTER_ORGANIZATION_ID
                           AND MCR.mc_header_id = UC.MASTER_CONFIG_ID
                           and MCR.parent_relationship_id is null;
                   EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                               IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                                   fnd_log.string(fnd_log.level_statement,l_full_name,' ----- Invalid -- UC_HEADER_ID ----- '||l_fs_uc_header_id_tbl(i));
                               END IF;
                               IF (p_concurrent_flag = 'Y') THEN
                                   fnd_file.put_line(fnd_file.log, 'RA Analyser Process  ---- Invalid UC Header Id - Data Corruption ----');
                               END IF;
                               Raise FND_API.G_EXC_UNEXPECTED_ERROR;
                          WHEN OTHERS THEN
                               IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                                   fnd_log.string(fnd_log.level_statement,l_full_name,' ----- OTHERS EXEC BLOCK -- UC_HEADER_ID ----- '||l_fs_uc_header_id_tbl(i));
                               END IF;
                               Raise FND_API.G_EXC_UNEXPECTED_ERROR;
                   END;

                   -- Fetch Unit Config Tree Node Details for the Unit under consideration in the Loop.
                   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                       fnd_log.string(fnd_log.level_statement,l_full_name,' ----- Fetching UC Node Data -----Flight Schedule Id --- '||l_fs_unit_sch_id_tbl(i));
                   END IF;
                   IF (p_concurrent_flag = 'Y') THEN
                       fnd_file.put_line(fnd_file.log, 'RA Analyser Process  ---- For Each UC - Fetching Tree Structure ----');
                   END IF;

                   OPEN c_uc_node_details(l_fs_csi_instance_id_tbl(i));
                        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                            fnd_log.string(fnd_log.level_statement,l_full_name,' Bulk Fetching UC Tree for Root_Instance_id -- '||l_fs_csi_instance_id_tbl(i));
                        END IF;
                        FETCH c_uc_node_details
                         BULK COLLECT INTO l_dtls_object_id_tbl,
                                           l_dtls_subject_id_tbl,
                                           l_dtls_pos_ref_tbl,
                                           l_dtls_inv_item_id_tbl,
                                           l_dtls_inv_master_org_id_tbl,
                                           l_dtls_inv_revision_tbl,
                                           l_dtls_quantity_tbl,
                                           l_dtls_uom_tbl,
                                           l_dtls_srl_no_tbl,
                                           l_dtls_item_name_tbl,
                                           l_dtls_item_desc_tbl,
                                           --Modified by mpothuku on 09-Nov-2006 for fixing the Bug# 5651645
                                           l_dtls_pos_ref_his_tbl;
                        IF l_dtls_subject_id_tbl.COUNT = 0 THEN
                           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                               fnd_log.string(fnd_log.level_statement,l_full_name,' No Nodes are Returned - Inserting Root Node at FIRST - index 1');
                           END IF;
                           IF (p_concurrent_flag = 'Y') THEN
                               fnd_file.put_line(fnd_file.log, 'RA Analyser Process  ---- No Nodes Fetched --Inserting Root Node at FIRST --');
                           END IF;
                           l_dtls_object_id_tbl(1)   := l_fs_csi_instance_id_tbl(i);
                           l_dtls_subject_id_tbl(1)  := l_fs_csi_instance_id_tbl(i);
                           l_dtls_pos_ref_tbl(1)     := l_root_pos_ref_code;
                           l_dtls_inv_item_id_tbl(1) := l_root_inv_item_id;
                           l_dtls_inv_master_org_id_tbl(1)  := l_root_inv_master_org_id;
                           l_dtls_inv_revision_tbl(1)   := l_root_item_revision;
                           l_dtls_quantity_tbl(1)    := l_root_quantity;
                           l_dtls_uom_tbl(1)         := l_root_uom;
                           l_dtls_srl_no_tbl(1)    := l_root_srl_no;
                           l_dtls_item_name_tbl(1)    := l_root_item_name;
                           l_dtls_item_desc_tbl(1)    := l_root_item_desc;
                           --Added by mpothuku on 09-Nov-2006 for fixing the Bug# 5651645
                           l_dtls_pos_ref_his_tbl(1)  := l_root_pos_ref_code;
                        ELSE
                           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                               fnd_log.string(fnd_log.level_statement,l_full_name,' Nodes are Returned - Inserting Root Node at LAST - index LAST + 1');
                           END IF;
                           IF (p_concurrent_flag = 'Y') THEN
                               fnd_file.put_line(fnd_file.log, 'RA Analyser Process  ---- All Nodes Fetched --Inserting Root Node at LAST --');
                           END IF;
                           l_dtls_object_id_tbl(l_dtls_object_id_tbl.LAST + 1)     := l_fs_csi_instance_id_tbl(i);
                           l_dtls_subject_id_tbl(l_dtls_subject_id_tbl.LAST + 1)   := l_fs_csi_instance_id_tbl(i);
                           l_dtls_pos_ref_tbl(l_dtls_pos_ref_tbl.LAST + 1)         := l_root_pos_ref_code;
                           l_dtls_inv_item_id_tbl(l_dtls_inv_item_id_tbl.LAST + 1) := l_root_inv_item_id;
                           l_dtls_inv_master_org_id_tbl(l_dtls_inv_master_org_id_tbl.LAST + 1)   := l_root_inv_master_org_id;
                           l_dtls_inv_revision_tbl(l_dtls_inv_revision_tbl.LAST + 1)             := l_root_item_revision;
                           l_dtls_quantity_tbl(l_dtls_quantity_tbl.LAST + 1)       := l_root_quantity;
                           l_dtls_uom_tbl(l_dtls_uom_tbl.LAST + 1)                 := l_root_uom;
                           l_dtls_srl_no_tbl(l_dtls_srl_no_tbl.LAST + 1)           := l_root_srl_no;
                           l_dtls_item_name_tbl(l_dtls_item_name_tbl.LAST + 1)     := l_root_item_name;
                           l_dtls_item_desc_tbl(l_dtls_item_desc_tbl.LAST + 1)     := l_root_item_desc;
			   --Added by mpothuku on 09-Nov-2006 for fixing the Bug# 5651645
			   l_dtls_pos_ref_his_tbl(l_dtls_pos_ref_his_tbl.LAST + 1) := l_root_pos_ref_code;
                        END IF;
                   CLOSE c_uc_node_details;

                   IF l_dtls_subject_id_tbl.COUNT > 0 THEN
                      IF (p_concurrent_flag = 'Y') THEN
                          fnd_file.put_line(fnd_file.log, 'RA Analyser Process  ---- Start Processing of Each Node --');
                      END IF;
                      FOR j IN l_dtls_subject_id_tbl.FIRST .. l_dtls_subject_id_tbl.LAST LOOP -- Loop for Each node in UC
                          l_ctr_index := 1; -- Reset if Index for Active Counters for each item instance.
                          l_mtbf_data_defined := 'N'; -- Reset if MTBF Data is defined or not indicator for each item instance.
                          l_fct_designator := null; -- Reset if Fct designator is derived or not indicator for each item instance.
                          l_prob_value := 0; -- Final Probability Value - Reset for Each Item Instance
                          l_ds_rec_found := 'N'; -- To indicate if duplicate forecast_desginator is already populated in l_forecast_designator_tbl
                          l_mtbf_value_exceeds := 'N'; -- To Indicates if MTBF Value exceeds for any of the Active counters of the Instance

                          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                              fnd_log.string(fnd_log.level_statement,l_full_name,'Calling API AHL_UMP_PROCESSUNIT_PVT.Get_Forecasted_Counter_Values');
                              fnd_log.string(fnd_log.level_statement,l_full_name,'l_dtls_subject_id_tbl - ' ||l_dtls_subject_id_tbl(j));
                              fnd_log.string(fnd_log.level_statement,l_full_name,'p_end_date - '||to_char(p_end_date, 'DD-MON-YYYY HH24:MI:SS'));
                              fnd_log.string(fnd_log.level_statement,l_full_name,'l_dtls_object_id_tbl - ' ||l_dtls_object_id_tbl(j));
                              fnd_log.string(fnd_log.level_statement,l_full_name,'l_dtls_pos_ref_tbl - ' ||l_dtls_pos_ref_tbl(j));
                              fnd_log.string(fnd_log.level_statement,l_full_name,'l_dtls_inv_item_id_tbl - ' ||l_dtls_inv_item_id_tbl(j));
                              fnd_log.string(fnd_log.level_statement,l_full_name,'l_dtls_inv_master_org_id_tbl - ' ||l_dtls_inv_master_org_id_tbl(j));
                              fnd_log.string(fnd_log.level_statement,l_full_name,'l_dtls_inv_revision_tbl - ' ||l_dtls_inv_revision_tbl(j));
                              fnd_log.string(fnd_log.level_statement,l_full_name,'l_dtls_quantity_tbl - ' ||l_dtls_quantity_tbl(j));
                              fnd_log.string(fnd_log.level_statement,l_full_name,'l_dtls_srl_no_tbl - ' ||l_dtls_srl_no_tbl(j));
                              fnd_log.string(fnd_log.level_statement,l_full_name,'l_dtls_item_name_tbl - ' ||l_dtls_item_name_tbl(j));
                              fnd_log.string(fnd_log.level_statement,l_full_name,'l_dtls_item_desc_tbl - ' ||l_dtls_item_desc_tbl(j));
                              --Added by mpothuku on 09-Nov-2006 for fixing the Bug# 5651645
                              fnd_log.string(fnd_log.level_statement,l_full_name,'l_dtls_pos_ref_his_tbl - ' ||l_dtls_pos_ref_his_tbl(j));
                          END IF;

                          IF (p_concurrent_flag = 'Y') THEN
                              fnd_file.put_line(fnd_file.log, 'RA Analyser Process  ---- Fetch Forecast Counter Value for Node in Context --');
                          END IF;

                          AHL_UMP_PROCESSUNIT_PVT.Get_Forecasted_Counter_Values(
                                        x_return_status         => l_return_status,
                                        x_msg_data              => l_msg_data,
                                        x_msg_count             => l_msg_count,
                                        p_init_msg_list         => FND_API.G_FALSE,
                                        p_csi_item_instance_id  => l_dtls_subject_id_tbl(j),
                                        p_forecasted_date       => l_fs_arrival_date_tbl(i),
                                        x_counter_values_tbl    => l_ctr_values_tbl);

                          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                             IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                                 fnd_log.string(fnd_log.level_statement,l_full_name,'Called API AHL_UMP_PROCESSUNIT_PVT.Get_Forecasted_Counter_Values Errored');
                             END IF;
                             IF (p_concurrent_flag = 'Y') THEN
                                 fnd_file.put_line(fnd_file.log, 'RA Analyser Process  ---- Error in getting Forecasted Counter Value for Node in Context --');
                             END IF;
                             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                          END IF;

                          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                              fnd_log.string(fnd_log.level_statement,l_full_name,'Called API AHL_UMP_PROCESSUNIT_PVT.Get_Forecasted_Counter_Values After');
                              fnd_log.string(fnd_log.level_statement,l_full_name,'l_ctr_values_tbl - COUNT - '||l_ctr_values_tbl.COUNT);
                              fnd_log.string(fnd_log.level_statement,l_full_name,'l_return_status - '||l_return_status);
                              fnd_log.string(fnd_log.level_statement,l_full_name,'l_msg_data - '||l_msg_data);
                              fnd_log.string(fnd_log.level_statement,l_full_name,'l_msg_count - '||l_msg_count);

                              IF (fnd_msg_pub.count_msg > 0 ) THEN

                                  FOR msg IN 1..fnd_msg_pub.count_msg LOOP

                                      fnd_msg_pub.get(p_msg_index => msg,
                                                      p_encoded   => FND_API.G_FALSE,
                                                      p_data      => l_msg_data,
                                                      p_msg_index_out => l_msg_index_out);

                                      fnd_log.string(fnd_log.level_statement,l_full_name,'UMP Returned - '||l_msg_data);

                                   END LOOP;

                              END IF;

                              IF l_ctr_values_tbl.COUNT > 0 THEN
                                 FOR u in l_ctr_values_tbl.FIRST .. l_ctr_values_tbl.LAST LOOP
                                     fnd_log.string(fnd_log.level_statement,l_full_name,' -- Returned From Get_Forecasted_Counter_Values - COUNTER_ID - '||l_ctr_values_tbl(u).COUNTER_ID);
                                     fnd_log.string(fnd_log.level_statement,l_full_name,' -- Returned From Get_Forecasted_Counter_Values - COUNTER_NAME - '||l_ctr_values_tbl(u).COUNTER_NAME);
                                     fnd_log.string(fnd_log.level_statement,l_full_name,' -- Returned From Get_Forecasted_Counter_Values - COUNTER_VALUE - '||l_ctr_values_tbl(u).COUNTER_VALUE);
                                     fnd_log.string(fnd_log.level_statement,l_full_name,' -- Returned From Get_Forecasted_Counter_Values - UOM_CODE - '||l_ctr_values_tbl(u).UOM_CODE);
                                 END LOOP;
                              END IF;
                              fnd_log.string(fnd_log.level_statement,l_full_name,' - Deriving Active Counters - ');
                          END IF;

                          IF (p_concurrent_flag = 'Y') THEN
                              fnd_file.put_line(fnd_file.log, 'RA Analyser Process  ---- Ater fetching the Foprecast Counter details for instance in context --');
                          END IF;

                          -- To hold the counter values.
                          -- Structure of l_ctr_values_tbl is
                          --   COUNTER_ID     NUMBER
                          --   COUNTER_NAME   VARCHAR2(80)
                          --   UOM_CODE       VARCHAR2(3)
                          --   COUNTER_VALUE  NUMBER

                          -- The below logic is as such ::::
                          -- Loop for Setup Counter Data -- A
                          --     For Each Since New/Since Overhaul in Setup Data Loop for Ctr Values returned from UMP API. -- B
                          --         If Since Overhaul counter value matches
                          --            retrieve corresponding ctr data returned from UMP API
                          --            Exit to Outer Loop - A
                          --         Elsif Since New counter value matches
                          --            retrieve corresponding ctr data returned from UMP API
                          --            Continue with inner loop - B
                          --         end if;
                          --     end loop; -- B
                          --     Increment counter assignment index and continue with outer loop
                          -- End Loop; - A

                          IF (p_concurrent_flag = 'Y') THEN
                              fnd_file.put_line(fnd_file.log, 'RA Analyser Process  ---- Deriving Active Counters for the Item Instance - BEFORE -');
                          END IF;

                          IF (l_since_new_ctr_id_tbl.COUNT > 0 AND l_ctr_values_tbl.COUNT > 0) THEN
                             FOR m in l_since_new_ctr_id_tbl.FIRST .. l_since_new_ctr_id_tbl.LAST LOOP
                                 FOR n in l_ctr_values_tbl.FIRST .. l_ctr_values_tbl.LAST LOOP

                                     -- Fetching Corresponding Counter Template Id for the Counter Id Passed.
                                     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                                         fnd_log.string(fnd_log.level_statement,l_full_name,' --- l_ctr_values_tbl.COUNTER_ID --- '||n||' - ' || l_ctr_values_tbl(n).COUNTER_ID);
                                     END IF;

                                     BEGIN
                                        -- Bug Fix for 5296759
                                        SELECT CREATED_FROM_COUNTER_TMPL_ID
                                          INTO l_ctr_template_id
                                          FROM csi_counters_vl
                                         WHERE counter_id = l_ctr_values_tbl(n).COUNTER_ID
                                           AND (   (CREATED_FROM_COUNTER_TMPL_ID IN (SELECT SINCE_NEW_COUNTER_ID
                                                                                       FROM AHL_RA_CTR_ASSOCIATIONS))
                                                OR (     CREATED_FROM_COUNTER_TMPL_ID IN (SELECT SINCE_OVERHAUL_COUNTER_ID
                                                                                            FROM AHL_RA_CTR_ASSOCIATIONS)
                                                     AND EXISTS (SELECT 1
                                                                   FROM CSI_COUNTER_READINGS
                                                                  WHERE COUNTER_ID = l_ctr_values_tbl(n).COUNTER_ID
                                                                    AND NET_READING IS NOT NULL
                                                                    AND DISABLED_FLAG = 'N')
                                                   )
                                               );

                                        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                                            fnd_log.string(fnd_log.level_statement,l_full_name,' --- l_ctr_template_id --- '||l_ctr_template_id);
                                        END IF;

                                     EXCEPTION
                                        WHEN OTHERS THEN
                                             IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                                                 fnd_log.string(fnd_log.level_statement,l_full_name,' --- CSI Data Not Retrieved --- ');
                                             END IF;
                                             l_ctr_template_id := NULL;
                                             NULL;
                                     END;

                                     IF l_ctr_template_id IS NOT NULL THEN
                                        -- l_ctr_template_id can be NULL if
                                        -- a. it is not defined as a since new counter
                                        -- b. it is defined as a since overhaul counter but the counter reading is NULL

                                         IF (l_since_oh_ctr_id_tbl(m) = l_ctr_template_id) THEN
                                            l_active_ctr_id_tbl(l_ctr_index)      := l_ctr_values_tbl(n).COUNTER_ID;
                                            l_active_ctr_temp_id_tbl(l_ctr_index) := l_ctr_template_id;
                                            l_active_ctr_name_tbl(l_ctr_index)    := l_ctr_values_tbl(n).COUNTER_NAME;
                                            l_active_ctr_value_tbl(l_ctr_index)   := l_ctr_values_tbl(n).COUNTER_VALUE;
                                            l_active_uom_code_tbl(l_ctr_index)    := l_ctr_values_tbl(n).UOM_CODE;
                                            EXIT; -- To outer Loop for Since New / Since Overhaul Counters
                                         ELSIF (l_since_new_ctr_id_tbl(m) = l_ctr_template_id) THEN
                                            l_active_ctr_id_tbl(l_ctr_index)      := l_ctr_values_tbl(n).COUNTER_ID;
                                            l_active_ctr_temp_id_tbl(l_ctr_index) := l_ctr_template_id;
                                            l_active_ctr_name_tbl(l_ctr_index)    := l_ctr_values_tbl(n).COUNTER_NAME;
                                            l_active_ctr_value_tbl(l_ctr_index)   := l_ctr_values_tbl(n).COUNTER_VALUE;
                                            l_active_uom_code_tbl(l_ctr_index)    := l_ctr_values_tbl(n).UOM_CODE;
                                         END IF;

                                     END IF;

                                 END LOOP; -- For l_ctr_values_tbl -- n
                                 l_ctr_index := l_ctr_index + 1; -- l_ctr_index is reset for each item instance
                             END LOOP; -- For l_since_new_ctr_id_tbl -- m

                             IF (p_concurrent_flag = 'Y') THEN
                                 fnd_file.put_line(fnd_file.log, 'RA Analyser Process  ---- Deriving Active Counters for the Item Instance - AFTER -');
                             END IF;

                             -- Active Counters are derived and Processing starts.
                             IF (l_active_ctr_id_tbl.COUNT > 0) THEN
                                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                                    fnd_log.string(fnd_log.level_statement,l_full_name,' --- l_active_ctr_id_tbl --- '||l_active_ctr_id_tbl.COUNT);
                                END IF;
                                FOR g in l_active_ctr_id_tbl.FIRST .. l_active_ctr_id_tbl.LAST LOOP
                                    IF l_active_ctr_id_tbl.EXISTS(g) THEN
                                       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                                           fnd_log.string(fnd_log.level_statement,l_full_name,' --- l_active_ctr_id_tbl --- '||g||' - ' || l_active_ctr_id_tbl(g));
                                           fnd_log.string(fnd_log.level_statement,l_full_name,' --- l_active_ctr_temp_id_tbl --- '||g||' - ' || l_active_ctr_temp_id_tbl(g));
                                           fnd_log.string(fnd_log.level_statement,l_full_name,' --- l_active_ctr_name_tbl --- '||g||' - ' || l_active_ctr_name_tbl(g));
                                           fnd_log.string(fnd_log.level_statement,l_full_name,' --- l_active_ctr_value_tbl --- '||g||' - ' || l_active_ctr_value_tbl(g));
                                           fnd_log.string(fnd_log.level_statement,l_full_name,' --- l_active_uom_code_tbl --- '||g||' - ' || l_active_uom_code_tbl(g));
                                       END IF;
                                    END IF;
                                END LOOP;

                                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                                    fnd_log.string(fnd_log.level_statement,l_full_name,' --- Bulk Fetching MTBF DATA --- ');
                                    fnd_log.string(fnd_log.level_statement,l_full_name,' --- Position Reference --- '||l_dtls_pos_ref_tbl(j));
                                    fnd_log.string(fnd_log.level_statement,l_full_name,' --- Item Id --- '||l_dtls_inv_item_id_tbl(j));
                                    fnd_log.string(fnd_log.level_statement,l_full_name,' --- Item Org Id --- '||l_dtls_inv_master_org_id_tbl(j));
                                    fnd_log.string(fnd_log.level_statement,l_full_name,' --- Item Revision --- '||l_dtls_inv_revision_tbl(j));
                                    --Added by mpothuku on 09-Nov-2006 for fixing the Bug# 5651645
                                    fnd_log.string(fnd_log.level_statement,l_full_name,' --- Pos Reference for Historical Flow --- ' ||l_dtls_pos_ref_his_tbl(j));
                                END IF;
                                IF (p_concurrent_flag = 'Y') THEN
                                    fnd_file.put_line(fnd_file.log, 'RA Analyser Process  ---- Deriving MTBF Data for Active Counter if present - BEFORE -');
                                END IF;

                                OPEN c_get_mtbf_data(l_dtls_pos_ref_tbl(j),
                                                     l_dtls_inv_item_id_tbl(j),
                                                     l_dtls_inv_master_org_id_tbl(j),
                                                     l_dtls_inv_revision_tbl(j));
                                     FETCH c_get_mtbf_data
                                      BULK COLLECT INTO l_mtbf_ctr_id_tbl,
                                                        l_mtbf_value_tbl;
                                     IF l_mtbf_ctr_id_tbl.COUNT = 0 THEN
                                        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                            fnd_log.string(fnd_log.level_statement,l_full_name,' ---- MTBF SETUP DATA IS NOT DEFINED ----');
                                        END IF;
                                        l_mtbf_data_defined := 'N';
                                     ELSE
                                        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                            fnd_log.string(fnd_log.level_statement,l_full_name,' ---- MTBF SETUP DATA IS DEFINED ----');
                                        END IF;
                                        l_mtbf_data_defined := 'Y';
                                        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                                            fnd_log.string(fnd_log.level_statement,l_full_name,' --- l_mtbf_ctr_id_tbl --COUNT-- '||l_mtbf_ctr_id_tbl.COUNT);
                                            FOR a in l_mtbf_ctr_id_tbl.FIRST .. l_mtbf_ctr_id_tbl.LAST LOOP
                                                fnd_log.string(fnd_log.level_statement,l_full_name,' --- l_mtbf_ctr_id_tbl --- '||l_mtbf_ctr_id_tbl(a));
                                                fnd_log.string(fnd_log.level_statement,l_full_name,' --- l_mtbf_value_tbl --- '||l_mtbf_value_tbl(a));
                                            END LOOP;
                                        END IF;
                                     END IF;
                                CLOSE c_get_mtbf_data;

                                IF (p_concurrent_flag = 'Y') THEN
                                    fnd_file.put_line(fnd_file.log, 'RA Analyser Process  ---- Deriving MTBF Data for Active Counter if present - BEFORE -');
                                END IF;

                                IF l_mtbf_data_defined = 'Y' THEN
                                    -- Compare Current Counter Value of Item with MTBF data defined for the corresponding Counter
                                    -- If Value Exceeds, Derive the Forecast Designator using the Forecast Association Setup

                                    IF (p_concurrent_flag = 'Y') THEN
                                        fnd_file.put_line(fnd_file.log, 'RA Analyser Process  ---- Check in Ctr Value Exceeds MTBF Value');
                                    END IF;

                                    FOR r in l_active_ctr_temp_id_tbl.FIRST .. l_active_ctr_temp_id_tbl.LAST LOOP
                                        IF l_active_ctr_temp_id_tbl.EXISTS(r) THEN
                                           IF l_mtbf_ctr_id_tbl.COUNT > 0 THEN -- Fall Safe case -- Never to be false
                                               FOR s in l_mtbf_ctr_id_tbl.FIRST .. l_mtbf_ctr_id_tbl.LAST LOOP
                                                   IF (l_active_ctr_temp_id_tbl(r) = l_mtbf_ctr_id_tbl(s) AND
                                                       l_active_ctr_value_tbl(r) >= l_mtbf_value_tbl(s)) THEN
                                                       l_mtbf_value_exceeds := 'Y';
                                                       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                                           fnd_log.string(fnd_log.level_statement,l_full_name,' ---- MTBF VALUE EXCEEDS ----');
                                                           fnd_log.string(fnd_log.level_statement,l_full_name,' ---- l_active_ctr_temp_id_tbl ----'||l_active_ctr_temp_id_tbl(r));
                                                           fnd_log.string(fnd_log.level_statement,l_full_name,' ---- l_active_ctr_value_tbl ----'||l_active_ctr_value_tbl(r));
                                                       END IF;
                                                       EXIT;
                                                   END IF;
                                               END LOOP;
                                           END IF;
                                           EXIT WHEN l_mtbf_value_exceeds = 'Y';
                                        END IF;
                                    END LOOP;

                                    IF l_mtbf_value_exceeds = 'Y' THEN

                                        IF (p_concurrent_flag = 'Y') THEN
                                            fnd_file.put_line(fnd_file.log, 'RA Analyser Process  ---- MTBF Defined - Fetching Forecast Designator - BEFORE');
                                        END IF;

                                        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                            fnd_log.string(fnd_log.level_statement,l_full_name,' ---- MTBF SETUP DATA IS DEFINED --VALUE EXCEEDS--');
                                            fnd_log.string(fnd_log.level_statement,l_full_name,' ---- Deriving Fct Designator ----');
                                        END IF;

                                        BEGIN
                                            Select FORECAST_DESIGNATOR
                                              into l_fct_designator
                                              from AHL_RA_FCT_ASSOCIATIONS
                                             where ASSOCIATION_TYPE_CODE = 'ASSOC_MTBF'
                                               and ORGANIZATION_ID = l_fs_arr_org_id_tbl(i);

                                            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                                fnd_log.string(fnd_log.level_statement,l_full_name,' ---- Derived Fct Designator ----'||l_fct_designator);
                                            END IF;

                                            l_prob_value := 100;

                                        EXCEPTION
                                             WHEN NO_DATA_FOUND THEN
                                                  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                                      fnd_log.string(fnd_log.level_statement,l_full_name,' ---- No Fct Designator Defined ----');
                                                  END IF;
                                                  l_fct_designator := null;
                                             WHEN TOO_MANY_ROWS THEN
                                                  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                                      fnd_log.string(fnd_log.level_statement,l_full_name,' ----- TOO_MANY_ROWS EXEC BLOCK -M- ORG_ID ----- '||l_fs_arr_org_id_tbl(i));
                                                  END IF;
                                                  Raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                             WHEN OTHERS THEN
                                                  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                                      fnd_log.string(fnd_log.level_statement,l_full_name,' ----- OTHERS EXEC BLOCK -M- ORG_ID ----- '||l_fs_arr_org_id_tbl(i));
                                                  END IF;
                                                  Raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                        END;

                                        IF (p_concurrent_flag = 'Y') THEN
                                            fnd_file.put_line(fnd_file.log, 'RA Analyser Process  ---- MTBF Defined - Fetching Forecast Designator - AFTER ');
                                        END IF;
                                    ELSE
                                        l_fct_designator := null;
                                        IF (p_concurrent_flag = 'Y') THEN
                                            fnd_file.put_line(fnd_file.log, 'RA Analyser Process  ---- Ctr Value Does not Exceed MTBF Value');
                                        END IF;
                                        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                            fnd_log.string(fnd_log.level_statement,l_full_name,'RA Analyser Process  ---- Ctr Value Does not Exceed MTBF Value');
                                        END IF;
                                    END IF;

                                ELSIF l_mtbf_data_defined = 'N' THEN
                                    -- Derive Probability of Failure of the Item using the Part Removal Data of the item.
                                    -- Derive this Probabilty for each Counter Assigned to the Item
                                    -- Derive the Forecast Designator using the Forecast Association Setup using the highest value
                                    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                        fnd_log.string(fnd_log.level_statement,l_full_name,' ---- MTBF SETUP DATA IS NOT DEFINED --Processing--');
                                    END IF;
                                    IF (p_concurrent_flag = 'Y') THEN
                                        fnd_file.put_line(fnd_file.log, 'RA Analyser Process  ---- MTBF Not Defined - Fetching Path Positions Ids for Instance - BEFORE');
                                    END IF;

                                    --Modified by mpothuku on 09-Nov-2006 for fixing the Bug# 5651645
                                    --OPEN c_get_path_postions(l_dtls_pos_ref_tbl(j));
                                    OPEN c_get_path_postions(l_dtls_pos_ref_his_tbl(j));-- Derive all Path Positions for the Position Reference
                                         FETCH c_get_path_postions
                                          BULK COLLECT INTO l_path_position_id_tbl;
                                         IF l_path_position_id_tbl.COUNT = 0 THEN
                                            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                                fnd_log.string(fnd_log.level_statement,l_full_name,' ---- NO CORRESPONDING PATH POSITIONS FOUND ----');
                                            END IF;
                                            l_path_pos_exist_flag := 'N';
                                         ELSE
                                            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                                fnd_log.string(fnd_log.level_statement,l_full_name,' ---- CORRESPONDING PATH POSITIONS RETRIEVED ----');
                                                FOR pos_index in l_path_position_id_tbl.FIRST .. l_path_position_id_tbl.LAST LOOP
                                                    fnd_log.string(fnd_log.level_statement,l_full_name,' ---- l_path_position_id_tbl ----'||l_path_position_id_tbl(pos_index));
                                                END LOOP;
                                            END IF;
                                            l_path_pos_exist_flag := 'Y';
                                         END IF;
                                    CLOSE c_get_path_postions;

                                    IF (p_concurrent_flag = 'Y') THEN
                                        fnd_file.put_line(fnd_file.log, 'RA Analyser Process  ---- MTBF Not Defined - Fetching Path Positions Ids for Instance - After');
                                    END IF;

                                    IF l_path_pos_exist_flag = 'Y' THEN -- If NO then Move to Next Instance in Else Part

                                        IF (p_concurrent_flag = 'Y') THEN
                                            fnd_file.put_line(fnd_file.log, 'Deriving Probability of Failure for Each Active Counter of Item Instance');
                                        END IF;

                                        FOR p in l_active_ctr_id_tbl.FIRST .. l_active_ctr_id_tbl.LAST LOOP
                                          IF l_active_ctr_id_tbl.EXISTS(p) THEN
                                            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                                fnd_log.string(fnd_log.level_statement,l_full_name,' ----Looping for active counters --'||l_active_ctr_id_tbl(p));
                                                fnd_log.string(fnd_log.level_statement,l_full_name,' ----Active Counter Value -- A --'||l_active_ctr_value_tbl(p));
                                            END IF;

                                            l_prob_attrib_a := 0; -- Indicates Current Value of Counter
                                            l_prob_attrib_b := 0; -- Number of items per position that failed with counter values less than or equal to A from CMRO's unscheduled removals
                                            l_prob_attrib_c := 0; -- Total number of failed item per position that match the defined removal codes and status
                                            l_prob_attrib_d := 0; -- Number of installed serviceable items per position with current counter values > A
                                            l_prob_value_tmp := 0;

                                            -- Note for B and C
                                            -- They have to be derived individually for each position path id mapped to the
                                            --  postion reference and then summed up to get the final values.

                                            l_prob_attrib_a := l_active_ctr_value_tbl(p);

                                            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                                fnd_log.string(fnd_log.level_statement,l_full_name,' ----deriving l_prob_attrib_c_tmp ----');
                                            END IF;

                                            IF l_path_position_id_tbl.COUNT > 0 THEN -- This should always be true due to l_path_pos_exist_flag = 'Y' check above
                                               FOR q in l_path_position_id_tbl.FIRST .. l_path_position_id_tbl.LAST LOOP
                                                    -- These tmp variables store the Removal History Data for Each Path Position
                                                    -- They are summed into l_prob_attrib_b and l_prob_attrib_c
                                                    l_prob_attrib_b_tmp := 0;
                                                    l_prob_attrib_c_tmp := 0;

                                                    IF (p_concurrent_flag = 'Y') THEN
                                                        fnd_file.put_line(fnd_file.log, 'Deriving Attrib B and C for Each Path Position id mappip to Item Relationship Id');
                                                    END IF;

                                                    -- For deriving l_prob_attrib_c_tmp
                                                    Select count(*)
                                                      into l_prob_attrib_c_tmp
                                                      from (Select chg.removed_instance_id
                                                             from ahl_part_changes chg,
                                                                  csi_item_instances cii,
                                                                  ahl_prd_dispositions_b dis
                                                            where chg.part_change_type IN ('R','S')
                                                              and chg.part_change_id = dis.part_change_id
                                                              and chg.removal_code in (Select Removal_Code from AHL_RA_SETUPS where setup_code = 'REMOVAL_CODE')
                                                              and dis.condition_id in (Select Status_Id from AHL_RA_SETUPS where setup_code = 'ITEM_STATUS')
                                                              and chg.mc_relationship_id = to_number(l_path_position_id_tbl(q))
                                                              AND cii.instance_id = chg.removed_instance_id
                                                              AND cii.inventory_item_id = l_dtls_inv_item_id_tbl(j)
                                                              AND cii.inv_master_organization_id = l_dtls_inv_master_org_id_tbl(j)) query_c;

                                                    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                                        fnd_log.string(fnd_log.level_statement,l_full_name,' ----derived l_prob_attrib_c_tmp ----' || l_prob_attrib_c_tmp);
                                                        fnd_log.string(fnd_log.level_statement,l_full_name,' ----deriving l_prob_attrib_b_tmp ----');
                                                    END IF;

                                                    -- For deriving l_prob_attrib_b_tmp
                                                    -- If l_prob_attrib_c_tmp = 0, it indicates that part removal history contains no data
                                                    -- irrespective of counter values -- so no need to derive l_prob_attrib_b_tmp
                                                    IF l_prob_attrib_c_tmp > 0 THEN

                                                        Select count(*)
                                                         into l_prob_attrib_b_tmp
                                                         from (Select chg.removed_instance_id
                                                                     ,ctr.net_reading
                                                                from ahl_part_changes chg,(Select assoc.source_object_id,
                                                                                                    cv.net_reading,
                                                                                                    cv.VALUE_TIMESTAMP,
                                                                                                    cv.counter_id
                                                                                               from csi_counter_associations assoc,
                                                                                                    csi_counter_readings cv,
                                                                                                    csi_counters_vl cb1,
                                                                                                    csi_counters_vl cb2
                                                                                              where assoc.source_object_code = 'CP'
                                                                                                and assoc.counter_id = cb2.counter_id
                                                                                                and cb1.counter_id = l_active_ctr_id_tbl(p)
                                                                                                and cb1.CREATED_FROM_COUNTER_TMPL_ID = cb2.CREATED_FROM_COUNTER_TMPL_ID
                                                                                                and cv.counter_id = cb2.counter_id
                                                                                                AND cv.disabled_flag = 'N') ctr,
                                                                     csi_item_instances cii,
                                                                     ahl_prd_dispositions_b dis
                                                               where chg.part_change_type IN ('R','S')
                                                                 and chg.part_change_id = dis.part_change_id
                                                                 AND chg.removed_instance_id = ctr.source_object_id
                                                                 and chg.removal_code in (Select Removal_Code from AHL_RA_SETUPS where setup_code = 'REMOVAL_CODE')
                                                                 and dis.condition_id in (Select Status_Id from AHL_RA_SETUPS where setup_code = 'ITEM_STATUS')
                                                                 and chg.mc_relationship_id = to_number(l_path_position_id_tbl(q))
                                                                 AND ctr.value_timestamp = (Select max(maxcv.value_timestamp)
                                                                                             from csi_counter_readings maxcv
                                                                                            where ctr.counter_id = maxcv.counter_id
                                                                                              and trunc(maxcv.value_timestamp) <= trunc(chg.REMOVAL_DATE))
                                                                 AND cii.instance_id = chg.removed_instance_id
                                                                 AND cii.inventory_item_id = l_dtls_inv_item_id_tbl(j)
                                                                 AND cii.inv_master_organization_id = l_dtls_inv_master_org_id_tbl(j)) query_b
                                                        where l_prob_attrib_a > query_b.net_reading;

                                                        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                                            fnd_log.string(fnd_log.level_statement,l_full_name,' ----derived l_prob_attrib_b_tmp as ----'||l_prob_attrib_b_tmp);
                                                        END IF;

                                                    ELSE

                                                        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                                            fnd_log.string(fnd_log.level_statement,l_full_name,' ----derived l_prob_attrib_b_tmp as 0 since l_prob_attrib_c is 0 ----');
                                                        END IF;

                                                        IF (p_concurrent_flag = 'Y') THEN
                                                            fnd_file.put_line(fnd_file.log, 'Setting Attrib B to 0 as C is also 0');
                                                        END IF;

                                                        l_prob_attrib_b_tmp := 0;
                                                    END IF;

                                                    IF (p_concurrent_flag = 'Y') THEN
                                                        fnd_file.put_line(fnd_file.log, 'Summing Up B and C retrieved for Each Path Position Id');
                                                    END IF;

                                                    l_prob_attrib_b := l_prob_attrib_b + l_prob_attrib_b_tmp;
                                                    l_prob_attrib_c := l_prob_attrib_c + l_prob_attrib_c_tmp;

                                               END LOOP; -- l_path_position_id_tbl -- q

                                               IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                                   fnd_log.string(fnd_log.level_statement,l_full_name,' ----deriving l_prob_attrib_d_tmp ----');
                                               END IF;
                                               IF (p_concurrent_flag = 'Y') THEN
                                                   fnd_file.put_line(fnd_file.log, 'Derive Attribute D for Probability');
                                               END IF;

                                               -- For deriving l_prob_attrib_d
                                               SELECT count(*)
                                                 INTO l_prob_attrib_d
                                                 FROM csi_ii_relationships CIIR,
                                                      csi_item_instances cii,
                                                      (SELECT assoc.source_object_id,
                                                              cv.net_reading,
                                                              cv.VALUE_TIMESTAMP
                                                         FROM csi_counter_associations assoc,
                                                              csi_counter_readings cv,
                                                              csi_counters_vl cb1,
                                                              csi_counters_vl cb2
                                                        WHERE assoc.source_object_code = 'CP'
                                                          AND assoc.counter_id = cb2.counter_id
                                                          AND cb1.counter_id = l_active_ctr_id_tbl(p)
                                                          AND cb1.CREATED_FROM_COUNTER_TMPL_ID = cb2.CREATED_FROM_COUNTER_TMPL_ID
                                                          AND cv.counter_id = cb2.counter_id
                                                          AND cv.value_timestamp = (Select max(value_timestamp)
                                                                                      from csi_counter_readings maxcv
                                                                                     where cv.counter_id = maxcv.counter_id)
                                                          AND cv.disabled_flag = 'N') ctr
                                                 WHERE cii.instance_id = CIIR.subject_id
                                                   AND CII.INVENTORY_ITEM_ID = l_dtls_inv_item_id_tbl(j)
                                                   AND CII.inv_master_organization_id = l_dtls_inv_master_org_id_tbl(j)
						   --Modified by mpothuku on 09-Nov-2006 for fixing the Bug# 5651645
                                                   --AND ciir.position_reference = l_dtls_pos_ref_tbl(j)
						   AND ciir.position_reference = l_dtls_pos_ref_his_tbl(j)
                                                   AND ctr.net_reading > l_prob_attrib_a
                                                   AND ctr.source_object_id = cii.instance_id -- CIIR.subject_id -- Perf Fix 4777658
                                                   AND ciir.relationship_type_code = 'COMPONENT-OF'
                                                   AND TRUNC(NVL(CIIR.ACTIVE_START_DATE,SYSDATE)) <= TRUNC(SYSDATE)
                                                   AND TRUNC(SYSDATE) < TRUNC(NVL(CIIR.ACTIVE_END_DATE,SYSDATE+1));

                                               IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                                   fnd_log.string(fnd_log.level_statement,l_full_name,' ----derived l_prob_attrib_d as ----'|| l_prob_attrib_d);
                                               END IF;

                                               IF (p_concurrent_flag = 'Y') THEN
                                                   fnd_file.put_line(fnd_file.log, 'Derive Probability using B C and D');
                                               END IF;

                                               IF ((l_prob_attrib_c + l_prob_attrib_d) > 0) THEN
                                                   l_prob_value_tmp := (l_prob_attrib_b)/(l_prob_attrib_c + l_prob_attrib_d);
                                                   l_prob_value_tmp := l_prob_value_tmp * 100;
                                                   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                                       fnd_log.string(fnd_log.level_statement,l_full_name,' ----denom > 0 .. compute temp prob ----'||l_prob_value_tmp);
                                                   END IF;
                                               ELSE
                                                  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                                      fnd_log.string(fnd_log.level_statement,l_full_name,' ----denom = 0 .. set temp prob to 0----');
                                                  END IF;
                                                  l_prob_value_tmp := 0;
                                               END IF;

                                               IF (p_concurrent_flag = 'Y') THEN
                                                   fnd_file.put_line(fnd_file.log, 'Retain Probability if Higher than Previous Value');
                                               END IF;

                                               IF l_prob_value_tmp > l_prob_value THEN
                                                  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                                      fnd_log.string(fnd_log.level_statement,l_full_name,' ----higher value of prob found .. Set final value ----'||l_prob_value_tmp);
                                                  END IF;
                                                  l_prob_value := l_prob_value_tmp;
                                                  IF (p_concurrent_flag = 'Y') THEN
                                                      fnd_file.put_line(fnd_file.log, 'Retained Probability');
                                                  END IF;
                                               END IF;
                                            ELSE -- l_path_position_id_tbl.COUNT = 0
                                                 -- This should never be true due to l_path_pos_exist_flag = 'Y' check above
                                               IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                                   fnd_log.string(fnd_log.level_statement,l_full_name,' ----No Path Position Found -- so ----');
                                                   fnd_log.string(fnd_log.level_statement,l_full_name,' ----Exit Counter Loop Jump to Next Item ----');
                                                   fnd_log.string(fnd_log.level_statement,l_full_name,' ----This Code Should not be executed -- Extra redundant check ----');
                                               END IF;
                                               IF (p_concurrent_flag = 'Y') THEN
                                                   fnd_file.put_line(fnd_file.log, ' ----No Path Position Found -- so ----');
                                                   fnd_file.put_line(fnd_file.log, '  ----Exit Counter Loop Jump to Next Item ----');
                                               END IF;
                                               EXIT;
                                            END IF; -- l_path_position_id_tbl.COUNT > 0
                                          END IF; -- l_active_ctr_id_tbl.EXISTS(p)
                                        END LOOP; -- l_active_ctr_id_tbl -- p --

                                        -- Derive Forecast Designator from the forecast association setup data
                                        -- for the Probability Data
                                        -- The Fetch for Forecast Designator is Unconditional because of the assumption
                                        -- that the user may also define a Forecast Association for zero probability.
                                        IF l_path_position_id_tbl.COUNT > 0 THEN -- redundant check -- for readability

                                        --Fix for the Bug 5480658, Added by mpothuku on 28th August, 06
                                        --If the probability is derived as zero, the record should not be interfaced
                                        --irrespective of whether a FD for zero is defined.
                                          IF l_prob_value > 0 THEN

                                             BEGIN
                                               IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                                   fnd_log.string(fnd_log.level_statement,l_full_name,' ---- Deriving Fct Designator -- for historical--');
                                               END IF;
                                               IF (p_concurrent_flag = 'Y') THEN
                                                   fnd_file.put_line(fnd_file.log, ' ----No MTBF Data Found -- Retreive Forecast Designator ----');
                                               END IF;
                                               Select FORECAST_DESIGNATOR
                                                 into l_fct_designator
                                                 from AHL_RA_FCT_ASSOCIATIONS
                                                where ASSOCIATION_TYPE_CODE = 'ASSOC_HISTORICAL'
                                                  and PROBABILITY_FROM <= l_prob_value
                                                  and (    PROBABILITY_TO > l_prob_value
                                                       OR (l_prob_value = 100 AND PROBABILITY_TO >= l_prob_value))
                                                  and ORGANIZATION_ID = l_fs_arr_org_id_tbl(i);
                                             EXCEPTION
                                                  WHEN NO_DATA_FOUND THEN
                                                       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                                           fnd_log.string(fnd_log.level_statement,l_full_name,' ---- No Fct Designator Defined ----');
                                                       END IF;
                                                       IF (p_concurrent_flag = 'Y') THEN
                                                           fnd_file.put_line(fnd_file.log, ' ----No MTBF Data Found -- No Forecast Designator Found ----');
                                                       END IF;
                                                       l_fct_designator := null;
                                                  WHEN TOO_MANY_ROWS THEN
                                                       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                                           fnd_log.string(fnd_log.level_statement,l_full_name,' ----- TOO_MANY_ROWS EXEC BLOCK -H- ORG_ID ----- '||l_fs_arr_org_id_tbl(i));
                                                           fnd_log.string(fnd_log.level_statement,l_full_name,' ----- TOO_MANY_ROWS EXEC BLOCK -H- l_prob_value ----- '||l_prob_value);
                                                       END IF;
                                                       Raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                                  WHEN OTHERS THEN
                                                       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                                           fnd_log.string(fnd_log.level_statement,l_full_name,' ----- OTHERS EXEC BLOCK -H- ORG_ID ----- '||l_fs_arr_org_id_tbl(i));
                                                           fnd_log.string(fnd_log.level_statement,l_full_name,' ----- OTHERS EXEC BLOCK -H- l_prob_value ----- '||l_prob_value);
                                                       END IF;
                                                       Raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                             END;
                                             ELSE
                                               IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                                   fnd_log.string(fnd_log.level_statement,l_full_name,' ---- l_prob_value -- for historical--'||l_prob_value);
                                                   fnd_log.string(fnd_log.level_statement,l_full_name,' ---- Since the derived Prob Value is Zero -- Assigning null to l_fct_designator--');
                                               END IF;
                                               l_fct_designator := null;
                                          END IF; --IF l_prob_value > 0

                                        ELSE -- This Code Should not be executed -- Extra redundant check
                                           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                               fnd_log.string(fnd_log.level_statement,l_full_name,' ----No Path Position Found -- so ----');
                                               fnd_log.string(fnd_log.level_statement,l_full_name,' ----Set Fct Assoc Designator to NULL and Continue ----');
                                               fnd_log.string(fnd_log.level_statement,l_full_name,' ----This Code Should not be executed -- Extra redundant check ----');
                                           END IF;
                                           IF (p_concurrent_flag = 'Y') THEN
                                               fnd_file.put_line(fnd_file.log, '  ----No Path Position Found -- so ----');
                                               fnd_file.put_line(fnd_file.log, '  ----Set Fct Assoc Designator to NULL and Continue ----');
                                           END IF;
                                           l_fct_designator := null;
                                        END IF;
                                    ELSE
                                        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                            fnd_log.string(fnd_log.level_statement,l_full_name,' ----No Path Position Found -- First Check -- so bypass ----');
                                            fnd_log.string(fnd_log.level_statement,l_full_name,' ----Set Fct Assoc Designator to NULL and Continue ----');
                                        END IF;
                                        IF (p_concurrent_flag = 'Y') THEN
                                            fnd_file.put_line(fnd_file.log, '  ----No Path Position Found  -- First Check -- so bypass ----');
                                        END IF;
                                        l_fct_designator := null;
                                    END IF; -- l_path_pos_exist_flag = 'Y'
                                END IF; -- l_mtbf_data_defined -- Y or N

                                IF l_fct_designator IS NOT NULL THEN
                                    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                                        fnd_log.string(fnd_log.level_statement,l_full_name,' -- Prepare IO Interface Data -- ');
                                        fnd_log.string(fnd_log.level_statement,l_full_name,' -- l_fct_designator -- ' || l_fct_designator);
                                    END IF;
                                    IF (p_concurrent_flag = 'Y') THEN
                                        fnd_file.put_line(fnd_file.log, ' -- Preparing IO Interface Data -- ');
                                    END IF;

                                    l_forecast_interface_tbl(l_fct_index).INVENTORY_ITEM_ID       := l_dtls_inv_item_id_tbl(j);
                                    l_forecast_interface_tbl(l_fct_index).FORECAST_DESIGNATOR     := l_fct_designator;
                                    l_forecast_interface_tbl(l_fct_index).ORGANIZATION_ID         := l_fs_arr_org_id_tbl(i);
                                    l_forecast_interface_tbl(l_fct_index).FORECAST_DATE           := l_fs_arrival_date_tbl(i);
                                    l_forecast_interface_tbl(l_fct_index).LAST_UPDATE_DATE        := sysdate;
                                    l_forecast_interface_tbl(l_fct_index).LAST_UPDATED_BY         := fnd_global.USER_ID;
                                    l_forecast_interface_tbl(l_fct_index).CREATION_DATE           := sysdate;
                                    l_forecast_interface_tbl(l_fct_index).CREATED_BY              := fnd_global.USER_ID;
                                    l_forecast_interface_tbl(l_fct_index).LAST_UPDATE_LOGIN       := fnd_global.LOGIN_ID;
                                    l_forecast_interface_tbl(l_fct_index).QUANTITY                := l_dtls_quantity_tbl(j);
                                    l_forecast_interface_tbl(l_fct_index).PROCESS_STATUS          := 2;
                                    l_forecast_interface_tbl(l_fct_index).CONFIDENCE_PERCENTAGE   := 100;
                                    l_forecast_interface_tbl(l_fct_index).COMMENTS                := null;
                                    l_forecast_interface_tbl(l_fct_index).ERROR_MESSAGE           := null;
                                    l_forecast_interface_tbl(l_fct_index).REQUEST_ID              := null;
                                    l_forecast_interface_tbl(l_fct_index).PROGRAM_APPLICATION_ID  := null;
                                    l_forecast_interface_tbl(l_fct_index).PROGRAM_ID              := null;
                                    l_forecast_interface_tbl(l_fct_index).PROGRAM_UPDATE_DATE     := null;
                                    l_forecast_interface_tbl(l_fct_index).WORKDAY_CONTROL         := 3; -- shift backward.
                                    l_forecast_interface_tbl(l_fct_index).BUCKET_TYPE             := 1;
                                    l_forecast_interface_tbl(l_fct_index).FORECAST_END_DATE       := null;
                                    l_forecast_interface_tbl(l_fct_index).TRANSACTION_ID          := null;
                                    l_forecast_interface_tbl(l_fct_index).SOURCE_CODE             := 'RA-'||l_fs_unit_sch_id_tbl(i);
                                    l_forecast_interface_tbl(l_fct_index).SOURCE_LINE_ID          := l_dtls_subject_id_tbl(j);
                                    l_forecast_interface_tbl(l_fct_index).ATTRIBUTE1              := null;
                                    l_forecast_interface_tbl(l_fct_index).ATTRIBUTE2              := null;
                                    l_forecast_interface_tbl(l_fct_index).ATTRIBUTE3              := null;
                                    l_forecast_interface_tbl(l_fct_index).ATTRIBUTE4              := null;
                                    l_forecast_interface_tbl(l_fct_index).ATTRIBUTE5              := null;
                                    l_forecast_interface_tbl(l_fct_index).ATTRIBUTE6              := null;
                                    l_forecast_interface_tbl(l_fct_index).ATTRIBUTE7              := null;
                                    l_forecast_interface_tbl(l_fct_index).ATTRIBUTE8              := null;
                                    l_forecast_interface_tbl(l_fct_index).ATTRIBUTE9              := null;
                                    l_forecast_interface_tbl(l_fct_index).ATTRIBUTE10             := null;
                                    l_forecast_interface_tbl(l_fct_index).ATTRIBUTE11             := null;
                                    l_forecast_interface_tbl(l_fct_index).ATTRIBUTE12             := null;
                                    l_forecast_interface_tbl(l_fct_index).ATTRIBUTE13             := null;
                                    l_forecast_interface_tbl(l_fct_index).ATTRIBUTE14             := null;
                                    l_forecast_interface_tbl(l_fct_index).ATTRIBUTE15             := null;
                                    l_forecast_interface_tbl(l_fct_index).PROJECT_ID              := null;
                                    l_forecast_interface_tbl(l_fct_index).TASK_ID                 := null;
                                    l_forecast_interface_tbl(l_fct_index).LINE_ID                 := null;
                                    l_forecast_interface_tbl(l_fct_index).ACTION                  := 'I';
                                    l_forecast_interface_tbl(l_fct_index).ATTRIBUTE_CATEGORY      := null;

                                    IF (p_concurrent_flag = 'Y') THEN
                                        fnd_file.put_line(fnd_file.log, ' -- Preparing Designator Interface Data -- ');
                                    END IF;
                                    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                        fnd_log.string(fnd_log.level_statement,l_full_name,' -- Preparing Designator Interface Data -- ');
                                    END IF;

                                    IF l_forecast_designator_tbl.COUNT > 0 THEN
                                       FOR d in l_forecast_designator_tbl.FIRST .. l_forecast_designator_tbl.LAST LOOP
                                           IF l_forecast_designator_tbl(d).FORECAST_DESIGNATOR = l_fct_designator THEN
                                              l_ds_rec_found := 'Y';
                                              IF (p_concurrent_flag = 'Y') THEN
                                                  fnd_file.put_line(fnd_file.log, ' -- Designator already exists in Interface Data -- ');
                                              END IF;
                                              IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                                  fnd_log.string(fnd_log.level_statement,l_full_name,' -- Designator already exists in Interface Data -- ');
                                              END IF;
                                              EXIT;
                                           END IF;
                                       END LOOP;
                                       IF l_ds_rec_found = 'N' THEN
                                          IF (p_concurrent_flag = 'Y') THEN
                                              fnd_file.put_line(fnd_file.log, ' -- Designator does not exists in Interface Data -- ');
                                          END IF;
                                          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                              fnd_log.string(fnd_log.level_statement,l_full_name,' -- Designator does not exists in Interface Data -- ');
                                          END IF;
                                          l_forecast_designator_tbl(l_dsg_index).ORGANIZATION_ID        := l_fs_arr_org_id_tbl(i);
                                          l_forecast_designator_tbl(l_dsg_index).FORECAST_DESIGNATOR      := l_fct_designator;
                                          l_dsg_index := l_dsg_index + 1;
                                       END IF;
                                    ELSE
                                       IF (p_concurrent_flag = 'Y') THEN
                                           fnd_file.put_line(fnd_file.log, ' -- Inserting first rec in Designator Data -- ');
                                       END IF;
                                       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                           fnd_log.string(fnd_log.level_statement,l_full_name,' -- Insertinf first rec in Designator Data -- ');
                                       END IF;
                                       l_forecast_designator_tbl(l_dsg_index).ORGANIZATION_ID        := l_fs_arr_org_id_tbl(i);
                                       l_forecast_designator_tbl(l_dsg_index).FORECAST_DESIGNATOR      := l_fct_designator;
                                       l_dsg_index := l_dsg_index + 1;
                                    END IF;

                                    -- Reset l_ds_rec_found as it is used for Dummy Recs below.
                                    l_ds_rec_found := 'N';

                                    l_forecast_org_code_tbl(l_fct_index) := l_fs_org_code_tbl(i);
                                    l_forecast_srl_no_tbl(l_fct_index)   := l_dtls_srl_no_tbl(j);
                                    l_forecast_item_name_tbl(l_fct_index):= l_dtls_item_name_tbl(j);
                                    l_forecast_item_desc_tbl(l_fct_index):= l_dtls_item_desc_tbl(j);
                                    l_forecast_req_prob_tbl(l_fct_index):= l_prob_value/100;

                                    MSC_ATP_GLOBAL.Extend_ATP(l_atp_rec, x_return_status);

                                    MSC_ATP_GLOBAL.GET_ATP_SESSION_ID(l_session_id,l_return_status);

                                    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                                       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                                           fnd_log.string(fnd_log.level_statement,l_full_name,'Called API MSC_ATP_GLOBAL.GET_SESSION_ID U Errored');
                                       END IF;
                                       IF (p_concurrent_flag = 'Y') THEN
                                           fnd_file.put_line(fnd_file.log, 'RA Analyser Process  ---- Error in getting on Session Id --');
                                       END IF;
                                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                                    ELSIF  x_return_status = FND_API.G_RET_STS_ERROR THEN
                                       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                                           fnd_log.string(fnd_log.level_statement,l_full_name,'Called API MSC_ATP_GLOBAL.GET_SESSION_ID E Errored');
                                       END IF;
                                       IF (p_concurrent_flag = 'Y') THEN
                                           fnd_file.put_line(fnd_file.log, 'RA Analyser Process  ---- Error in getting on Session Id');
                                       END IF;
                                       RAISE FND_API.G_EXC_ERROR;
                                    END IF;

                                    --Assign values to input record for ATP api.
                                    l_atp_rec.Inventory_Item_Id        := Mrp_Atp_Pub.number_arr(l_dtls_inv_item_id_tbl(j));
                                    l_atp_rec.Organization_Id          := Mrp_Atp_Pub.number_arr(l_fs_arr_org_id_tbl(i));
                                    l_atp_rec.Source_Organization_Id   := Mrp_Atp_Pub.number_arr(l_fs_arr_org_id_tbl(i));
                                    l_atp_rec.Requested_Ship_Date      := Mrp_Atp_Pub.date_arr(to_date(l_fs_arrival_date_tbl(i),'DD-MM-YYYY'));
                                    l_atp_rec.Quantity_Ordered         := Mrp_Atp_Pub.number_arr(l_dtls_quantity_tbl(j));
                                    l_atp_rec.Quantity_UOM             := Mrp_Atp_Pub.char3_arr(l_dtls_uom_tbl(j));
                                    l_atp_rec.Calling_Module           := Mrp_Atp_Pub.number_arr(867);
                                    l_atp_rec.Action                   := Mrp_Atp_Pub.number_arr(100);
                                    l_atp_rec.override_flag            := Mrp_Atp_Pub.char1_arr('N');

                                    SELECT mrp_atp_schedule_temp_s.NEXTVAL
                                    INTO l_dummy_identifier
                                    from dual;

                                    l_atp_rec.Identifier := Mrp_Atp_Pub.number_arr(l_dummy_identifier);

                                    IF (p_concurrent_flag = 'Y') THEN
                                        fnd_file.put_line(fnd_file.log, ' - B - Calling ATP API -- ' || l_dtls_inv_item_id_tbl(j));
                                    END IF;
                                    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                        fnd_log.string(fnd_log.level_statement,l_full_name,' -B- Calling ATP API -- ' || l_dtls_inv_item_id_tbl(j));
                                    END IF;

                                    MRP_ATP_PUB.Call_ATP (l_session_id,
                                                          l_atp_rec,
                                                          x_atp_rec ,
                                                          x_atp_supply_demand ,
                                                          x_atp_period,
                                                          x_atp_details,
                                                          l_return_status,
                                                          l_msg_data,
                                                          l_msg_count
                                                         );

                                    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                                       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                                           fnd_log.string(fnd_log.level_statement,l_full_name,'Called API MRP_ATP_PUB.Call_ATP U Errored');
                                       END IF;
                                       IF (p_concurrent_flag = 'Y') THEN
                                           fnd_file.put_line(fnd_file.log, 'RA Analyser Process  ---- Error in getting on Hand Quantity --' || l_session_id);
                                       END IF;
                                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                                    ELSIF  x_return_status = FND_API.G_RET_STS_ERROR THEN
                                       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                                           fnd_log.string(fnd_log.level_statement,l_full_name,'Called API MRP_ATP_PUB.Call_ATP E Errored');
                                       END IF;
                                       IF (p_concurrent_flag = 'Y') THEN
                                           fnd_file.put_line(fnd_file.log, 'RA Analyser Process  ---- Error in getting on Hand Quantity --' || l_session_id);
                                       END IF;
                                       RAISE FND_API.G_EXC_ERROR;
                                    END IF;

                                    IF (p_concurrent_flag = 'Y') THEN
                                        fnd_file.put_line(fnd_file.log, ' - A - Calling ATP API -- ' || x_atp_rec.Requested_Date_Quantity(1));
                                    END IF;
                                    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                        fnd_log.string(fnd_log.level_statement,l_full_name,' -A- Calling ATP API -- ' || l_dtls_inv_item_id_tbl(j));
                                    END IF;

                                    l_forecast_onhand_qty_tbl(l_fct_index) := nvl(x_atp_rec.Requested_Date_Quantity(1),0);

                                    SELECT COUNT(*)
                                      INTO l_forecast_osp_qty_tbl(l_fct_index)
                                      FROM AHL_OSP_ORDER_LINES_V OSPL,
                                           AHL_OSP_ORDERS_B OSP
                                     WHERE OSPL.OSP_ORDER_ID = OSP.OSP_ORDER_ID
                                       AND OSP.STATUS_CODE <> 'CLOSED'
                                       AND INVENTORY_ITEM_ID = l_dtls_inv_item_id_tbl(j)
                                       AND OSPL.INVENTORY_ORG_ID= l_fs_arr_org_id_tbl(i)
                                       AND NVL(TRUNC(OSPL.NEED_BY_DATE), FND_API.G_MISS_DATE) = l_fs_arrival_date_tbl(i);

                                    IF (p_concurrent_flag = 'Y') THEN
                                        fnd_file.put_line(fnd_file.log, ' - B - Deriving VWP Figure -- ');
                                    END IF;
                                    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                        fnd_log.string(fnd_log.level_statement,l_full_name,' - B - Deriving VWP Figure -- ');
                                        fnd_log.string(fnd_log.level_statement,l_full_name,' - B - Param - Item ID -- '||l_dtls_inv_item_id_tbl(j));
                                        fnd_log.string(fnd_log.level_statement,l_full_name,' - B - Param - Item Org ID -- '||l_dtls_inv_master_org_id_tbl(j));
                                        fnd_log.string(fnd_log.level_statement,l_full_name,' - B - Param - Item Revision -- '||l_dtls_inv_revision_tbl(j));
                                        fnd_log.string(fnd_log.level_statement,l_full_name,' - B - Param - Arrival Org -- '||l_fs_arr_org_id_tbl(i));
                                        fnd_log.string(fnd_log.level_statement,l_full_name,' - B - Param - Arrival Date -- '||l_fs_arrival_date_tbl(i));
                                    END IF;

                                    Select nvl(sum(nvl(QTY_GRP,0)),0) QTY
                                      INTO l_forecast_vwp_qty_tbl(l_fct_index)
                                      FROM (
                                            Select DISTINCT ITEM_INSTANCE AS ITEM_INSTANCE_GRP,
                                                            VISIT_QUANTITY QTY_GRP
                                             From (
                                                       -- Total Quantity from UC Tree in a Visit.
                                                       SELECT CII.INSTANCE_ID AS ITEM_INSTANCE,
                                                              CII.QUANTITY AS VISIT_QUANTITY
                                                         FROM CSI_II_RELATIONSHIPS CIIR,
                                                              CSI_ITEM_INSTANCES CII
                                                        WHERE CII.INVENTORY_ITEM_ID = l_dtls_inv_item_id_tbl(j)
                                                          AND CII.INV_MASTER_ORGANIZATION_ID = l_dtls_inv_master_org_id_tbl(j)
                                                          AND nvl(CII.INVENTORY_REVISION,FND_API.G_MISS_CHAR) = nvl(l_dtls_inv_revision_tbl(j),FND_API.G_MISS_CHAR)
                                                          AND CII.INSTANCE_ID = CIIR.SUBJECT_ID
                                                       START WITH CIIR.OBJECT_ID IN (
                                                                                       Select DISTINCT Visit.ITEM_INSTANCE_ID
                                                                                         from AHL_VISITS_B Visit,
                                                                                              AHL_SIMULATION_PLANS_B SPL
                                                                                        Where Visit.unit_Schedule_id is NULL
                                                                                          AND VISIT.STATUS_CODE NOT IN ('CLOSED', 'CANCELLED', 'DELETED')
                                                                                          AND SPL.SIMULATION_PLAN_ID = VISIT.SIMULATION_PLAN_ID
                                                                                          AND SPL.PRIMARY_PLAN_FLAG = 'Y'
                                                                                          AND Visit.organization_id = l_fs_arr_org_id_tbl(i)
                                                                                          AND l_fs_arrival_date_tbl(i) between TRUNC(Visit.START_DATE_TIME) AND TRUNC(Visit.CLOSE_DATE_TIME)
                                                                                         )
                                                              AND CIIR.RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
                                                              AND TRUNC(NVL(CIIR.ACTIVE_START_DATE,SYSDATE)) <= TRUNC(SYSDATE)
                                                              AND TRUNC(SYSDATE) < TRUNC(NVL(CIIR.ACTIVE_END_DATE,SYSDATE+1))
                                                       CONNECT BY PRIOR CIIR.SUBJECT_ID = CIIR.OBJECT_ID
                                                              AND CIIR.RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
                                                              AND TRUNC(NVL(CIIR.ACTIVE_START_DATE,SYSDATE)) <= TRUNC(SYSDATE)
                                                              AND TRUNC(SYSDATE) < TRUNC(NVL(CIIR.ACTIVE_END_DATE,SYSDATE+1))

                                                       UNION ALL

                                                       -- Total Quantity from Root Node of a Visit.

                                                        Select Visit.ITEM_INSTANCE_ID AS ITEM_INSTANCE,
                                                               CII.QUANTITY AS VISIT_QUANTITY
                                                          from AHL_VISITS_B Visit,
                                                               AHL_SIMULATION_PLANS_B SPL,
                                                               CSI_ITEM_INSTANCES CII
                                                         Where Visit.unit_Schedule_id is NOT NULL
                                                           AND VISIT.STATUS_CODE NOT IN ('CLOSED', 'CANCELLED', 'DELETED')
                                                           AND SPL.SIMULATION_PLAN_ID = VISIT.SIMULATION_PLAN_ID
                                                           AND SPL.PRIMARY_PLAN_FLAG = 'Y'
                                                           AND Visit.organization_id = l_fs_arr_org_id_tbl(i)
                                                           AND l_fs_arrival_date_tbl(i) between TRUNC(Visit.START_DATE_TIME) AND TRUNC(Visit.CLOSE_DATE_TIME)
                                                           AND Visit.ITEM_INSTANCE_ID = CII.INSTANCE_ID
                                                           AND CII.INVENTORY_ITEM_ID = l_dtls_inv_item_id_tbl(j)
                                                           AND CII.INV_MASTER_ORGANIZATION_ID = l_dtls_inv_master_org_id_tbl(j)
                                                           AND nvl(CII.INVENTORY_REVISION,FND_API.G_MISS_CHAR) = nvl(l_dtls_inv_revision_tbl(j),FND_API.G_MISS_CHAR)

                                                       UNION ALL

                                                       -- Total Quantity from Visit, which does not have a unit at the header level.
                                                       -- Without Tree Reversal
                                                       Select CII.INSTANCE_ID AS ITEM_INSTANCE,
                                                              CII.QUANTITY AS VISIT_QUANTITY
                                                         from AHL_VISIT_TASKS_B TASKS,
                                                              AHL_VISITS_B Visit,
                                                              AHL_SIMULATION_PLANS_B SPL,
                                                              CSI_ITEM_INSTANCES CII
                                                        Where Visit.VISIT_ID = TASKS.Visit_id
                                                          AND VISIT.STATUS_CODE NOT IN ('CLOSED', 'CANCELLED', 'DELETED')
                                                          AND SPL.SIMULATION_PLAN_ID = VISIT.SIMULATION_PLAN_ID
                                                          AND SPL.PRIMARY_PLAN_FLAG = 'Y'
                                                          AND Visit.unit_Schedule_id is NULL
                                                          AND Visit.organization_id = l_fs_arr_org_id_tbl(i)
                                                          AND l_fs_arrival_date_tbl(i) between TRUNC(Visit.START_DATE_TIME) AND TRUNC(Visit.CLOSE_DATE_TIME)
                                                          AND TASKS.INSTANCE_ID = CII.INSTANCE_ID
                                                          AND CII.INVENTORY_ITEM_ID = l_dtls_inv_item_id_tbl(j)
                                                          AND CII.INV_MASTER_ORGANIZATION_ID = l_dtls_inv_master_org_id_tbl(j)
                                                          AND nvl(CII.INVENTORY_REVISION,FND_API.G_MISS_CHAR) = nvl(l_dtls_inv_revision_tbl(j),FND_API.G_MISS_CHAR)

                                                       UNION ALL

                                                       -- Total Quantity from Visit, which does not have a unit at the header level.
                                                       -- With Tree Reversal
                                                       SELECT CII.INSTANCE_ID AS ITEM_INSTANCE,
                                                              CII.QUANTITY AS VISIT_QUANTITY
                                                         FROM CSI_II_RELATIONSHIPS CIIR,
                                                              CSI_ITEM_INSTANCES CII
                                                        WHERE CII.INVENTORY_ITEM_ID = l_dtls_inv_item_id_tbl(j)
                                                          AND CII.INV_MASTER_ORGANIZATION_ID = l_dtls_inv_master_org_id_tbl(j)
                                                          AND nvl(CII.INVENTORY_REVISION,FND_API.G_MISS_CHAR) = nvl(l_dtls_inv_revision_tbl(j),FND_API.G_MISS_CHAR)
                                                          AND CII.INSTANCE_ID = CIIR.SUBJECT_ID
                                                       START WITH CIIR.OBJECT_ID IN (
                                                                                       Select CII.INSTANCE_ID AS ITEM_INSTANCE
                                                                                         from AHL_VISIT_TASKS_B TASKS,
                                                                                              AHL_VISITS_B Visit,
                                                                                              AHL_SIMULATION_PLANS_B SPL,
                                                                                              CSI_ITEM_INSTANCES CII
                                                                                        Where Visit.VISIT_ID = TASKS.Visit_id
                                                                                          AND VISIT.STATUS_CODE NOT IN ('CLOSED', 'CANCELLED', 'DELETED')
                                                                                          AND SPL.SIMULATION_PLAN_ID = VISIT.SIMULATION_PLAN_ID
                                                                                          AND SPL.PRIMARY_PLAN_FLAG = 'Y'
                                                                                          AND Visit.unit_Schedule_id is NULL
                                                                                          AND Visit.organization_id = l_fs_arr_org_id_tbl(i)
                                                                                          AND l_fs_arrival_date_tbl(i) between TRUNC(Visit.START_DATE_TIME) AND TRUNC(Visit.CLOSE_DATE_TIME)
                                                                                          AND TASKS.INSTANCE_ID = CII.INSTANCE_ID
                                                                                          AND CII.INVENTORY_ITEM_ID = l_dtls_inv_item_id_tbl(j)
                                                                                          AND CII.INV_MASTER_ORGANIZATION_ID = l_dtls_inv_master_org_id_tbl(j)
                                                                                          AND nvl(CII.INVENTORY_REVISION,FND_API.G_MISS_CHAR) = nvl(l_dtls_inv_revision_tbl(j),FND_API.G_MISS_CHAR)
                                                                                      )
                                                              AND CIIR.RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
                                                              AND TRUNC(NVL(CIIR.ACTIVE_START_DATE,SYSDATE)) <= TRUNC(SYSDATE)
                                                              AND TRUNC(SYSDATE) < TRUNC(NVL(CIIR.ACTIVE_END_DATE,SYSDATE+1))
                                                       CONNECT BY PRIOR CIIR.SUBJECT_ID = CIIR.OBJECT_ID
                                                              AND CIIR.RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
                                                              AND TRUNC(NVL(CIIR.ACTIVE_START_DATE,SYSDATE)) <= TRUNC(SYSDATE)
                                                              AND TRUNC(SYSDATE) < TRUNC(NVL(CIIR.ACTIVE_END_DATE,SYSDATE+1))

                                                   )
                                            );

                                    IF (p_concurrent_flag = 'Y') THEN
                                        fnd_file.put_line(fnd_file.log, ' - A - Deriving VWP Figure -- ' || l_forecast_vwp_qty_tbl(l_fct_index));
                                    END IF;
                                    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                        fnd_log.string(fnd_log.level_statement,l_full_name,' - A - Deriving VWP Figure -- ' || l_forecast_vwp_qty_tbl(l_fct_index));
                                    END IF;

                                    SELECT nvl(SUM(nvl(TRANSACTION_QUANTITY,0)),0)
                                      INTO l_forecast_non_qty_tbl(l_fct_index)
                                      FROM MTL_ONHAND_QUANTITIES QUANT,
                                           MTL_SECONDARY_INVENTORIES SI
                                     WHERE QUANT.INVENTORY_ITEM_ID = l_dtls_inv_item_id_tbl(j)
                                       AND QUANT.ORGANIZATION_ID = l_fs_arr_org_id_tbl(i)
                                       AND QUANT.SUBINVENTORY_CODE = SI.SECONDARY_INVENTORY_NAME
                                       AND QUANT.ORGANIZATION_ID = SI.ORGANIZATION_ID
                                       AND SI.AVAILABILITY_TYPE <> 1;

                                    l_incl_in_rpt_flag_tbl(l_fct_index) := 'Y';

                                    l_fct_index := l_fct_index + 1;

                                    -- As per IO Module requirements - if a Particular Item Requirment is Interfaced with a
                                    -- Probability Percentage of failure - x% then one or more dummy record/s also needs to be
                                    -- interfaced with probability requirment of 100%-x% and Required Quantity - 0.
                                    -- To achieve this - We interface data for all the forecast associations in the system
                                    -- for the arrival organization except the one picked above and interface it to MRP
                                    -- with required quantity - 0, for these records.
                                    -- The constraint that Aggregate Probability Percentages of the Forecast sets sum upto
                                    -- 100% exactly, is marked as a User Setup Data Creation Outline.
                                    IF (p_concurrent_flag = 'Y') THEN
                                        fnd_file.put_line(fnd_file.log, ' -- Creating Dummy Data in FCT Interface Table -- ');
                                    END IF;
                                    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                        fnd_log.string(fnd_log.level_statement,l_full_name,' -- Creating Dummy Data in FCT Interface Table -- ');
                                    END IF;

                                    IF l_mtbf_data_defined = 'N' THEN
                                       -- Dummy Data is created only if Prob of Failure is derived using Historical Data
                                       -- In case in Fct is being created using MTBF data, only Fct Designator can be Associated
                                       -- to the arrival org, and the value of the associated designator would be 100% in IO Plan Setup.

                                       IF (p_concurrent_flag = 'Y') THEN
                                           fnd_file.put_line(fnd_file.log, ' ---- FETCHING FCT ASSOCIATIONS ----');
                                       END IF;
                                       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                           fnd_log.string(fnd_log.level_statement,l_full_name,' ---- FETCHING FCT ASSOCIATIONS ----');
                                       END IF;
                                       OPEN c_fetch_dummy_assocs(l_fct_designator,l_fs_arr_org_id_tbl(i));
                                            FETCH c_fetch_dummy_assocs
                                             BULK COLLECT INTO l_dummy_fct_desg_tbl;
                                            IF l_dummy_fct_desg_tbl.COUNT = 0 THEN
                                               IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                                   fnd_log.string(fnd_log.level_statement,l_full_name,' ---- NO DUMMY FCT ASSOCIATIONS DERIVED ----');
                                               END IF;
                                            ELSE
                                               IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                                   fnd_log.string(fnd_log.level_statement,l_full_name,' ---- DUMMY FCT ASSOCIATIONS RETRIEVED----');
                                               END IF;
                                            END IF;
                                       CLOSE c_fetch_dummy_assocs;

                                       IF l_dummy_fct_desg_tbl.COUNT > 0 THEN
                                          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                              fnd_log.string(fnd_log.level_statement,l_full_name,' ---- INSERTING MRP Recs for Dummy FCT ASSOCIATIONS ----');
                                          END IF;
                                          IF (p_concurrent_flag = 'Y') THEN
                                              fnd_file.put_line(fnd_file.log, ' ---- INSERTING MRP Recs for Dummy FCT ASSOCIATIONS ----');
                                          END IF;
                                          for f in l_dummy_fct_desg_tbl.FIRST .. l_dummy_fct_desg_tbl.LAST LOOP
                                              IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                                  fnd_log.string(fnd_log.level_statement,l_full_name,' ---- INSERTING FOR DUMMY ASSOC ----' || l_dummy_fct_desg_tbl(f));
                                              END IF;

                                              l_forecast_interface_tbl(l_fct_index).INVENTORY_ITEM_ID       := l_dtls_inv_item_id_tbl(j);
                                              l_forecast_interface_tbl(l_fct_index).FORECAST_DESIGNATOR     := l_dummy_fct_desg_tbl(f);
                                              l_forecast_interface_tbl(l_fct_index).ORGANIZATION_ID         := l_fs_arr_org_id_tbl(i);
                                              l_forecast_interface_tbl(l_fct_index).FORECAST_DATE           := l_fs_arrival_date_tbl(i);
                                              l_forecast_interface_tbl(l_fct_index).LAST_UPDATE_DATE        := sysdate;
                                              l_forecast_interface_tbl(l_fct_index).LAST_UPDATED_BY         := fnd_global.USER_ID;
                                              l_forecast_interface_tbl(l_fct_index).CREATION_DATE           := sysdate;
                                              l_forecast_interface_tbl(l_fct_index).CREATED_BY              := fnd_global.USER_ID;
                                              l_forecast_interface_tbl(l_fct_index).LAST_UPDATE_LOGIN       := fnd_global.LOGIN_ID;
                                              l_forecast_interface_tbl(l_fct_index).QUANTITY                := 0;
                                              l_forecast_interface_tbl(l_fct_index).PROCESS_STATUS          := 2;
                                              l_forecast_interface_tbl(l_fct_index).CONFIDENCE_PERCENTAGE   := 100;
                                              l_forecast_interface_tbl(l_fct_index).COMMENTS                := null;
                                              l_forecast_interface_tbl(l_fct_index).ERROR_MESSAGE           := null;
                                              l_forecast_interface_tbl(l_fct_index).REQUEST_ID              := null;
                                              l_forecast_interface_tbl(l_fct_index).PROGRAM_APPLICATION_ID  := null;
                                              l_forecast_interface_tbl(l_fct_index).PROGRAM_ID              := null;
                                              l_forecast_interface_tbl(l_fct_index).PROGRAM_UPDATE_DATE     := null;
                                              l_forecast_interface_tbl(l_fct_index).WORKDAY_CONTROL         := 3; -- shift backward.
                                              l_forecast_interface_tbl(l_fct_index).BUCKET_TYPE             := 1;
                                              l_forecast_interface_tbl(l_fct_index).FORECAST_END_DATE       := null;
                                              l_forecast_interface_tbl(l_fct_index).TRANSACTION_ID          := null;
                                              l_forecast_interface_tbl(l_fct_index).SOURCE_CODE             := 'RA-'||l_fs_unit_sch_id_tbl(i);
                                              l_forecast_interface_tbl(l_fct_index).SOURCE_LINE_ID          := l_dtls_subject_id_tbl(j);
                                              l_forecast_interface_tbl(l_fct_index).ATTRIBUTE1              := null;
                                              l_forecast_interface_tbl(l_fct_index).ATTRIBUTE2              := null;
                                              l_forecast_interface_tbl(l_fct_index).ATTRIBUTE3              := null;
                                              l_forecast_interface_tbl(l_fct_index).ATTRIBUTE4              := null;
                                              l_forecast_interface_tbl(l_fct_index).ATTRIBUTE5              := null;
                                              l_forecast_interface_tbl(l_fct_index).ATTRIBUTE6              := null;
                                              l_forecast_interface_tbl(l_fct_index).ATTRIBUTE7              := null;
                                              l_forecast_interface_tbl(l_fct_index).ATTRIBUTE8              := null;
                                              l_forecast_interface_tbl(l_fct_index).ATTRIBUTE9              := null;
                                              l_forecast_interface_tbl(l_fct_index).ATTRIBUTE10             := null;
                                              l_forecast_interface_tbl(l_fct_index).ATTRIBUTE11             := null;
                                              l_forecast_interface_tbl(l_fct_index).ATTRIBUTE12             := null;
                                              l_forecast_interface_tbl(l_fct_index).ATTRIBUTE13             := null;
                                              l_forecast_interface_tbl(l_fct_index).ATTRIBUTE14             := null;
                                              l_forecast_interface_tbl(l_fct_index).ATTRIBUTE15             := null;
                                              l_forecast_interface_tbl(l_fct_index).PROJECT_ID              := null;
                                              l_forecast_interface_tbl(l_fct_index).TASK_ID                 := null;
                                              l_forecast_interface_tbl(l_fct_index).LINE_ID                 := null;
                                              l_forecast_interface_tbl(l_fct_index).ACTION                  := 'I';
                                              l_forecast_interface_tbl(l_fct_index).ATTRIBUTE_CATEGORY      := null;


                                              IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                                  fnd_log.string(fnd_log.level_statement,l_full_name,' -- Preparing Designator Interface Data -DUMMY- ');
                                              END IF;

                                              IF l_forecast_designator_tbl.COUNT > 0 THEN
                                                 FOR h in l_forecast_designator_tbl.FIRST .. l_forecast_designator_tbl.LAST LOOP
                                                     IF l_forecast_designator_tbl(h).FORECAST_DESIGNATOR = l_dummy_fct_desg_tbl(f) THEN
                                                        l_ds_rec_found := 'Y';
                                                        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                                            fnd_log.string(fnd_log.level_statement,l_full_name,' -- Designator already exists in Interface Data -DUMMY- ');
                                                        END IF;
                                                        EXIT;
                                                     END IF;
                                                 END LOOP;
                                                 IF l_ds_rec_found = 'N' THEN
                                                    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                                        fnd_log.string(fnd_log.level_statement,l_full_name,' -- Designator does not exists in Interface Data -DUMMY- ');
                                                    END IF;
                                                    l_forecast_designator_tbl(l_dsg_index).ORGANIZATION_ID        := l_fs_arr_org_id_tbl(i);
                                                    l_forecast_designator_tbl(l_dsg_index).FORECAST_DESIGNATOR      := l_dummy_fct_desg_tbl(f);
                                                    l_dsg_index := l_dsg_index + 1;
                                                 END IF;
                                              ELSE
                                                 IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                                     fnd_log.string(fnd_log.level_statement,l_full_name,' -- Inserting first rec in Designator Data -DUMMY- ');
                                                 END IF;
                                                 l_forecast_designator_tbl(l_dsg_index).ORGANIZATION_ID        := l_fs_arr_org_id_tbl(i);
                                                 l_forecast_designator_tbl(l_dsg_index).FORECAST_DESIGNATOR      := l_dummy_fct_desg_tbl(f);
                                                 l_dsg_index := l_dsg_index + 1;
                                              END IF;

                                              l_ds_rec_found := 'N';

                                              l_forecast_org_code_tbl(l_fct_index) := l_fs_org_code_tbl(i);
                                              l_forecast_srl_no_tbl(l_fct_index)   := l_dtls_srl_no_tbl(j);
                                              l_forecast_item_name_tbl(l_fct_index):= l_dtls_item_name_tbl(j);
                                              l_forecast_item_desc_tbl(l_fct_index):= l_dtls_item_desc_tbl(j);

                                              -- Set Flag to indicate that dummy records will not be reflected in Output Report.
                                              l_incl_in_rpt_flag_tbl(l_fct_index) := 'N';

                                              l_fct_index := l_fct_index + 1;

                                          END LOOP; -- f for l_dummy_fct_desg_tbl
                                       END IF; -- l_dummy_fct_desg_tbl.COUNT > 0

                                    END IF; -- l_mtbf_data_defined = 'N'
                                    -- End of creation of dummy data.

                                    IF (p_concurrent_flag = 'Y') THEN
                                        fnd_file.put_line(fnd_file.log, ' -- Prepared IO Interface Data -- ');
                                    END IF;

                                ELSE -- l_fct_designator IS NULL
                                    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                                        fnd_log.string(fnd_log.level_statement,l_full_name,' -- No Fct Designator Found -- ');
                                        fnd_log.string(fnd_log.level_statement,l_full_name,' -- Jump to Next instance -- ' || l_fct_designator);
                                    END IF;

                                    IF (p_concurrent_flag = 'Y') THEN
                                        fnd_file.put_line(fnd_file.log, ' -- No Fct Designator Found so No Interfacing to be done -- ');
                                    END IF;

                                END IF;

                             ELSE -- l_active_ctr_id_tbl.COUNT = 0
                                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                                    fnd_log.string(fnd_log.level_statement,l_full_name,' -- No Matching ACTIVE COUNTERS derived -- ');
                                    fnd_log.string(fnd_log.level_statement,l_full_name,' -- Move to next item instace -- l_dtls_subject_id_tbl - '||l_dtls_subject_id_tbl(j));
                                END IF;
                                IF (p_concurrent_flag = 'Y') THEN
                                    fnd_file.put_line(fnd_file.log, ' --  No Matching ACTIVE COUNTERS derived  -- ');
                                END IF;

                            END IF; -- l_active_ctr_id_tbl.COUNT > 0
                          ELSE -- Setup or Retrieved counters are NULL
                             IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                                 fnd_log.string(fnd_log.level_statement,l_full_name,'Setup or Retrieved counters are NULL');
                                 fnd_log.string(fnd_log.level_statement,l_full_name,'l_since_new_ctr_id_tbl - COUNT - '||l_since_new_ctr_id_tbl.COUNT);
                                 fnd_log.string(fnd_log.level_statement,l_full_name,'l_ctr_values_tbl - COUNT - '||l_ctr_values_tbl.COUNT);
                                 fnd_log.string(fnd_log.level_statement,l_full_name,'l_dtls_subject_id_tbl - '||l_dtls_subject_id_tbl(j));
                             END IF;
                             IF (p_concurrent_flag = 'Y') THEN
                                 fnd_file.put_line(fnd_file.log, ' --  Setup or Retrieved counters are NULL  -- ');
                             END IF;
                          END IF; -- l_since_new_ctr_id_tbl.COUNT > 0 AND l_ctr_values_tbl.COUNT > 0
                      END LOOP; -- Loop for Item Instance - UC Nodes - index j
                   ELSE
                      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                          fnd_log.string(fnd_log.level_statement,l_full_name,'No Nodes for Current Unit - Move to Next Sch-Unit');
                          fnd_log.string(fnd_log.level_statement,l_full_name,'l_fs_unit_sch_id_tbl - '||l_fs_unit_sch_id_tbl(i));
                          fnd_log.string(fnd_log.level_statement,l_full_name,'l_fs_uc_header_id_tbl - '||l_fs_uc_header_id_tbl(i));
                          fnd_log.string(fnd_log.level_statement,l_full_name,'l_fs_csi_instance_id_tbl - '||l_fs_csi_instance_id_tbl(i));
                      END IF;
                      IF (p_concurrent_flag = 'Y') THEN
                          fnd_file.put_line(fnd_file.log, ' --  No Nodes for Current Unit - Move to Next Sch-Unit  -- ');
                      END IF;
                   END IF; -- l_dtls_subject_id_tbl.COUNT > 0
               END LOOP; -- Loop for Unit Schedules - i
            ELSE  -- l_fs_unit_sch_id_tbl.COUNT = 0
                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                    fnd_log.string(fnd_log.level_statement,l_full_name,'No Flight Schedules to Process');
                END IF;
                IF (p_concurrent_flag = 'Y') THEN
                    fnd_file.put_line(fnd_file.log, ' --  No Flight Schedules to Process  -- ');
                END IF;
            END IF; -- l_fs_unit_sch_id_tbl.COUNT > 0
        END IF; -- l_since_new_ctr_id_tbl.COUNT = 0

       IF l_forecast_interface_tbl.COUNT > 0 THEN
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
              fnd_log.string(fnd_log.level_statement,l_full_name,'Calling MRP_FORECAST_INTERFACE_PK.MRP_FORECAST_INTERFACE -- Before');
              fnd_log.string(fnd_log.level_statement,l_full_name,' -- INTERFACE DATA -- ');
              FOR b IN l_forecast_interface_tbl.FIRST .. l_forecast_interface_tbl.LAST LOOP
                  fnd_log.string(fnd_log.level_statement,l_full_name,' -- FCT REC STARTS  -- '||b);
                  fnd_log.string(fnd_log.level_statement,l_full_name,' -- INVENTORY_ITEM_ID  -- '||l_forecast_interface_tbl(b).INVENTORY_ITEM_ID);
                  fnd_log.string(fnd_log.level_statement,l_full_name,' -- FORECAST_DESIGNATOR  -- '||l_forecast_interface_tbl(b).FORECAST_DESIGNATOR);
                  fnd_log.string(fnd_log.level_statement,l_full_name,' -- ORGANIZATION_ID  -- '||l_forecast_interface_tbl(b).ORGANIZATION_ID);
                  fnd_log.string(fnd_log.level_statement,l_full_name,' -- FORECAST_DATE  -- '||l_forecast_interface_tbl(b).FORECAST_DATE);
                  fnd_log.string(fnd_log.level_statement,l_full_name,' -- FORECASTED MONTH  -- '||to_char(l_forecast_interface_tbl(b).FORECAST_DATE,'MON-YYYY'));
                  fnd_log.string(fnd_log.level_statement,l_full_name,' -- REQUIRED_QUANTITY  -- '||l_forecast_interface_tbl(b).QUANTITY);
                  fnd_log.string(fnd_log.level_statement,l_full_name,' -- PROCESS_STATUS  -- '||l_forecast_interface_tbl(b).PROCESS_STATUS);
                  fnd_log.string(fnd_log.level_statement,l_full_name,' -- CONFIDENCE_PERCENTAGE  -- '||l_forecast_interface_tbl(b).CONFIDENCE_PERCENTAGE);
                  fnd_log.string(fnd_log.level_statement,l_full_name,' -- WORKDAY_CONTROL  -- '||l_forecast_interface_tbl(b).WORKDAY_CONTROL);
                  fnd_log.string(fnd_log.level_statement,l_full_name,' -- BUCKET_TYPE  -- '||l_forecast_interface_tbl(b).BUCKET_TYPE);
                  fnd_log.string(fnd_log.level_statement,l_full_name,' -- SOURCE_CODE  -- '||l_forecast_interface_tbl(b).SOURCE_CODE);
                  fnd_log.string(fnd_log.level_statement,l_full_name,' -- SOURCE_LINE_ID  -- '||l_forecast_interface_tbl(b).SOURCE_LINE_ID);
                  fnd_log.string(fnd_log.level_statement,l_full_name,' -- ACTION  -- '||l_forecast_interface_tbl(b).ACTION);

              END LOOP;
              IF l_forecast_designator_tbl.COUNT > 0 THEN
                 FOR c IN l_forecast_designator_tbl.FIRST .. l_forecast_designator_tbl.LAST LOOP
                     fnd_log.string(fnd_log.level_statement,l_full_name,' -- DESIGNATOR REC STARTS  -- '||c);
                     fnd_log.string(fnd_log.level_statement,l_full_name,' -- ORGANIZATION_ID  -- '||l_forecast_designator_tbl(c).ORGANIZATION_ID);
                     fnd_log.string(fnd_log.level_statement,l_full_name,' -- FORECAST_DESIGNATOR  -- '||l_forecast_designator_tbl(c).FORECAST_DESIGNATOR);
                 END LOOP;
              END IF;
          END IF;
          IF (p_concurrent_flag = 'Y') THEN
              fnd_file.put_line(fnd_file.log, ' --  Calling MRP_FORECAST_INTERFACE_PK.MRP_FORECAST_INTERFACE -- Before  -- ');
          END IF;

          IF (MRP_FORECAST_INTERFACE_PK.MRP_FORECAST_INTERFACE
                            (l_forecast_interface_tbl,
                             l_forecast_designator_tbl)) THEN
             IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string(fnd_log.level_statement,l_full_name,'Calling MRP_FORECAST_INTERFACE_PK.MRP_FORECAST_INTERFACE -- After');
             END IF;
             IF (p_concurrent_flag = 'Y') THEN
                 fnd_file.put_line(fnd_file.log, ' --  Calling MRP_FORECAST_INTERFACE_PK.MRP_FORECAST_INTERFACE -- After  -- ');
             END IF;
          ELSE
             IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string(fnd_log.level_statement,l_full_name,'Failure Calling MRP_FORECAST_INTERFACE_PK.MRP_FORECAST_INTERFACE -- ');
             END IF;
             IF (p_concurrent_flag = 'Y') THEN
                 fnd_file.put_line(fnd_file.log, ' --  Failure Calling MRP_FORECAST_INTERFACE_PK.MRP_FORECAST_INTERFACE ---- ');
             END IF;
          END IF;

       ELSE
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
             fnd_log.string(fnd_log.level_statement,l_full_name,'MRP_FORECAST_INTERFACE_PK.MRP_FORECAST_INTERFACE Not to be called');
          END IF;
          IF (p_concurrent_flag = 'Y') THEN
              fnd_file.put_line(fnd_file.log, ' --  MRP_FORECAST_INTERFACE_PK.MRP_FORECAST_INTERFACE Not to be called ---- ');
          END IF;
       END IF;

       -- Open a temporary lob for merging the contents.
       dbms_lob.createTemporary( l_fct_data_lob, true );
       dbms_lob.open( l_fct_data_lob, dbms_lob.lob_readwrite );

       -- XML generated with dbms_xmlgen doesnt have encoding information. so we need to manually insert into the resultant CLOB.
       dbms_lob.write(l_fct_data_lob,length('<?xml version="1.0" encoding="UTF-8"?>'),1,'<?xml version="1.0" encoding="UTF-8"?>');
       /*
       mpothuku Added fnd_global.local_chr(10) (or new line) for the Bug 5724555 on 21-Dec-06. FND_FILE.put has a restriction of 32K characters.
       If there is no new-line in these 32K characters, it fails. So ensuring that there are new-line characters after every line
       of the XML
       */
       dbms_lob.write(l_fct_data_lob,length(fnd_global.local_chr(10)),length(l_fct_data_lob)+1,fnd_global.local_chr(10));
       --Put the root node to maintain the XML completeness.
       dbms_lob.write(l_fct_data_lob, length('<G_FCT_DATA_LIST>'),length(l_fct_data_lob)+1, '<G_FCT_DATA_LIST>');
       dbms_lob.write(l_fct_data_lob,length(fnd_global.local_chr(10)),length(l_fct_data_lob)+1,fnd_global.local_chr(10));
       --Put the Start Date and the End Date
       --mpothuku Added to_char on 23 Aug, 06 for XSL canonical date format to be used by the XMLP report for the Bug 5460793
       l_dummy_string := '<P_START_DATE>' || to_char(p_start_date,'YYYY-MM-DD') || '</P_START_DATE>'||fnd_global.local_chr(10);
       l_dummy_string := l_dummy_string || '<P_END_DATE>' || to_char(p_end_date,'YYYY-MM-DD') || '</P_END_DATE>' ||fnd_global.local_chr(10);
       dbms_lob.write(l_fct_data_lob, length(l_dummy_string),length(l_fct_data_lob)+1, l_dummy_string);

       IF l_forecast_interface_tbl.COUNT > 0 THEN
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
             fnd_log.string(fnd_log.level_statement,l_full_name,'Creating Clob for Output File');
          END IF;
          IF (p_concurrent_flag = 'Y') THEN
              fnd_file.put_line(fnd_file.log, ' --  Creating Clob for Output File  -- ');
          END IF;
          --mpothuku added dbms_xmlgen.convert on 08-May-2007 to fix the Bug 6038466
          /*
          Note by mpothuku on 09-May-2007: Consider revising the string concat logic below and
          write each XML line immediately into the CLOB and the log, so that the l_dummy_string size is not huge.
          We already had to increase the size from 1000 to 5000, as XML encode bloats up the size of the strings.
          */
          FOR c in l_forecast_interface_tbl.FIRST .. l_forecast_interface_tbl.LAST LOOP
              IF l_incl_in_rpt_flag_tbl(c) = 'Y' THEN -- Check if Interface rec is candidate for Output report.
                 l_row_count := l_row_count + 1;
                 l_dummy_string := '<G_FCT_ENTRY_REC>'||fnd_global.local_chr(10);
                 l_dummy_string := l_dummy_string || '<ORGANIZATION_ID>'       ||l_forecast_interface_tbl(c).ORGANIZATION_ID       ||'</ORGANIZATION_ID>'||fnd_global.local_chr(10);
                 l_dummy_string := l_dummy_string || '<ORGANIZATION_CODE>'     ||dbms_xmlgen.convert(l_forecast_org_code_tbl(c))                        ||'</ORGANIZATION_CODE>'||fnd_global.local_chr(10);
                 l_dummy_string := l_dummy_string || '<INVENTORY_ITEM_ID>'     ||l_forecast_interface_tbl(c).INVENTORY_ITEM_ID     ||'</INVENTORY_ITEM_ID>'||fnd_global.local_chr(10);
                 l_dummy_string := l_dummy_string || '<CONCATENATED_SEGMENTS>' ||dbms_xmlgen.convert(l_forecast_item_name_tbl(c))                       ||'</CONCATENATED_SEGMENTS>'||fnd_global.local_chr(10);
                 l_dummy_string := l_dummy_string || '<ITEM_DESCRIPTION>'      ||dbms_xmlgen.convert(l_forecast_item_desc_tbl(c))                       ||'</ITEM_DESCRIPTION>'||fnd_global.local_chr(10);
                 l_dummy_string := l_dummy_string || '<SERIAL_NUMBER>'         ||dbms_xmlgen.convert(l_forecast_srl_no_tbl(c))                          ||'</SERIAL_NUMBER>'||fnd_global.local_chr(10);
                 l_dummy_string := l_dummy_string || '<FORECAST_DESIGNATOR>'   ||dbms_xmlgen.convert(l_forecast_interface_tbl(c).FORECAST_DESIGNATOR)   ||'</FORECAST_DESIGNATOR>'||fnd_global.local_chr(10);
                 --mpothuku Added to_char on 23 Aug, 06 for XSL canonical date format to be used by the XMLP report for the Bug 5460793
                 l_dummy_string := l_dummy_string || '<FORECAST_DATE>'         ||to_char(l_forecast_interface_tbl(c).FORECAST_DATE,'YYYY-MM-DD')||'</FORECAST_DATE>'||fnd_global.local_chr(10);
                 l_dummy_string := l_dummy_string || '<FORECASTED_MONTH>'      ||to_char(l_forecast_interface_tbl(c).FORECAST_DATE,'MON-YYYY')||'</FORECASTED_MONTH>'||fnd_global.local_chr(10);
                 l_dummy_string := l_dummy_string || '<REQUIRED_QUANTITY>'     ||l_forecast_interface_tbl(c).QUANTITY              ||'</REQUIRED_QUANTITY>'||fnd_global.local_chr(10);
                 l_dummy_string := l_dummy_string || '<REQUIRED_PROBABILITY>'  ||l_forecast_req_prob_tbl(c)                        ||'</REQUIRED_PROBABILITY>'||fnd_global.local_chr(10);
                 l_dummy_string := l_dummy_string || '<ONHAND_QUANTITY>'       ||l_forecast_onhand_qty_tbl(c)                      ||'</ONHAND_QUANTITY>'||fnd_global.local_chr(10);
                 l_dummy_string := l_dummy_string || '<QUANTITY_DUE_OSP>'      ||l_forecast_osp_qty_tbl(c)                         ||'</QUANTITY_DUE_OSP>'||fnd_global.local_chr(10);
                 l_dummy_string := l_dummy_string || '<QUANTITY_IN_VISIT>'     ||l_forecast_vwp_qty_tbl(c)                         ||'</QUANTITY_IN_VISIT>'||fnd_global.local_chr(10);
                 l_dummy_string := l_dummy_string || '<QUANTITY_NON_SERVICEABLE>' ||l_forecast_non_qty_tbl(c)                      ||'</QUANTITY_NON_SERVICEABLE>'||fnd_global.local_chr(10);
                 l_dummy_string := l_dummy_string || '<PROCESS_STATUS>'        ||l_forecast_interface_tbl(c).PROCESS_STATUS        ||'</PROCESS_STATUS>'||fnd_global.local_chr(10);
                 l_dummy_string := l_dummy_string || '<ERROR_MESSAGE>'         ||dbms_xmlgen.convert(l_forecast_interface_tbl(c).ERROR_MESSAGE)         ||'</ERROR_MESSAGE>'||fnd_global.local_chr(10);
                 l_dummy_string := l_dummy_string || '<SOURCE_CODE>'           ||dbms_xmlgen.convert(l_forecast_interface_tbl(c).SOURCE_CODE)           ||'</SOURCE_CODE>'||fnd_global.local_chr(10);
                 l_dummy_string := l_dummy_string || '<SOURCE_LINE_ID>'        ||l_forecast_interface_tbl(c).SOURCE_LINE_ID        ||'</SOURCE_LINE_ID>'||fnd_global.local_chr(10);

                 -- This 'Hard Coded' Data will be replaced by Lookups / Messages -- Pending
                 IF l_forecast_interface_tbl(c).PROCESS_STATUS = 1 THEN
                    l_dummy_string := l_dummy_string || '<PROCESS_STATUS_DESC>' || ' Do Not Process ' ||'</PROCESS_STATUS_DESC>'||fnd_global.local_chr(10);
                 ELSIF l_forecast_interface_tbl(c).PROCESS_STATUS = 2 THEN
                    l_dummy_string := l_dummy_string || '<PROCESS_STATUS_DESC>' || ' Waiting to be processed ' ||'</PROCESS_STATUS_DESC>'||fnd_global.local_chr(10);
                 ELSIF l_forecast_interface_tbl(c).PROCESS_STATUS = 3 THEN
                    l_dummy_string := l_dummy_string || '<PROCESS_STATUS_DESC>' || ' Being Processed ' ||'</PROCESS_STATUS_DESC>'||fnd_global.local_chr(10);
                 ELSIF l_forecast_interface_tbl(c).PROCESS_STATUS = 4 THEN
                    l_dummy_string := l_dummy_string || '<PROCESS_STATUS_DESC>' || ' Error ' ||'</PROCESS_STATUS_DESC>'||fnd_global.local_chr(10);
                 ELSIF l_forecast_interface_tbl(c).PROCESS_STATUS = 5 THEN
                    l_dummy_string := l_dummy_string || '<PROCESS_STATUS_DESC>' || ' Processed ' ||'</PROCESS_STATUS_DESC>'||fnd_global.local_chr(10);
                 END IF;

                 l_dummy_string := l_dummy_string || '</G_FCT_ENTRY_REC>'||fnd_global.local_chr(10);
                 dbms_lob.write(l_fct_data_lob, length(l_dummy_string),length(l_fct_data_lob)+1, l_dummy_string);
              END IF;
          END LOOP;

       ELSE
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
             fnd_log.string(fnd_log.level_statement,l_full_name,' -- Clob content empty for Output File --');
          END IF;
          IF (p_concurrent_flag = 'Y') THEN
              fnd_file.put_line(fnd_file.log, ' --  Clob content empty for Output File ---- ');
          END IF;
       END IF;

       l_dummy_string := '<ROW_COUNT>' || l_row_count || '</ROW_COUNT>'||fnd_global.local_chr(10);
       dbms_lob.write(l_fct_data_lob, length(l_dummy_string),length(l_fct_data_lob)+1, l_dummy_string);

       dbms_lob.write(l_fct_data_lob, length('</G_FCT_DATA_LIST>'),length(l_fct_data_lob)+1, '</G_FCT_DATA_LIST>');

        x_xml_data := l_fct_data_lob;

        --Close and release the temporary lobs
        dbms_lob.close( l_fct_data_lob );
        dbms_lob.freeTemporary( l_fct_data_lob );

        -- Standard check for p_commit
        IF FND_API.To_Boolean (p_commit) THEN
            COMMIT;
        END IF;

        IF (p_concurrent_flag = 'Y') THEN
            fnd_file.put_line(fnd_file.log, ' --  RA -- PKG -- PROCESS_RA_DATA -------END--------------- ');
        END IF;
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_statement,l_full_name,'RA -- PKG -- PROCESS_RA_DATA -------END-----------');
        END IF;

        -- Standard call to get message count and if count is 1, get message
        FND_MSG_PUB.Count_And_Get
          ( p_count => x_msg_count,
            p_data  => x_msg_data,
            p_encoded => fnd_api.g_false);

        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_procedure,L_FULL_NAME||'.end','Return Status = ' || x_return_status);
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            Rollback to PROCESS_RA_DATA_SP;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                       p_data  => x_msg_data,
                                       p_encoded => fnd_api.g_false);
            IF (p_concurrent_flag = 'Y') THEN
              fnd_file.put_line(fnd_file.log, 'RA Analyser Process Failed. Refer to the error message below.');
              log_error_messages;
            END IF;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            Rollback to PROCESS_RA_DATA_SP;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                       p_data  => x_msg_data,
                                       p_encoded => fnd_api.g_false);
            IF (p_concurrent_flag = 'Y') THEN
              fnd_file.put_line(fnd_file.log, 'RA Analyser Process Failed. Refer to the error message below.');
              log_error_messages;
            END IF;

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            Rollback to PROCESS_RA_DATA_SP;
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                        p_procedure_name => 'PROCESS_RA_DATA',
                                        p_error_text     => SUBSTR(SQLERRM,1,240));
            END IF;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                       p_data  => x_msg_data,
                                       p_encoded => fnd_api.g_false);
            IF (p_concurrent_flag = 'Y') THEN
              fnd_file.put_line(fnd_file.log, 'RA Analyser Process Failed. Refer to the error message below.');
              log_error_messages;
            END IF;

    END PROCESS_RA_DATA;

    PROCEDURE RA_ANALYSER_PROCESS (
        errbuf                  OUT NOCOPY  VARCHAR2,
        retcode                 OUT NOCOPY  NUMBER,
        p_api_version           IN          NUMBER,
        p_start_date            IN          VARCHAR2,
        p_end_date              IN          VARCHAR2
    )
    IS

        l_return_status     VARCHAR2(30);
        l_msg_count         NUMBER;
        l_api_name          VARCHAR2(30) := 'RA_ANALYSER_PROCESS';
        l_api_version       NUMBER := 1.0;
        l_clob CLOB;

        l_offset     NUMBER;
        l_chunk_size NUMBER;
        l_clob_size  NUMBER;
        l_chunk      VARCHAR2(10000);

    BEGIN

        -- Initialize error message stack by default
        FND_MSG_PUB.Initialize;

        -- Standard call to check for call compatibility
        IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
        THEN
            retcode := 2;
            errbuf := FND_MSG_PUB.Get;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        PROCESS_RA_DATA (
            p_api_version               => 1,
            p_init_msg_list             => FND_API.G_TRUE,
            p_commit                    => FND_API.G_TRUE,
            p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
            p_module_type               => NULL,
            x_return_status             => l_return_status,
            x_msg_count                 => l_msg_count,
            x_msg_data                  => errbuf,
            p_start_date                => fnd_date.canonical_to_date(p_start_date),
            p_end_date                  => fnd_date.canonical_to_date(p_end_date),
            p_concurrent_flag           => 'Y',
            x_xml_data                  => l_clob);

        l_offset     := 1;
        l_chunk_size := 3000;
        l_clob_size := dbms_lob.getlength(l_clob);
        fnd_file.put(fnd_file.log, 'l_clob_size - '||l_clob_size);
        WHILE (l_clob_size > 0) LOOP
            l_chunk := dbms_lob.substr (l_clob, l_chunk_size, l_offset);
            fnd_file.put(fnd_file.log, l_chunk);
            l_clob_size := l_clob_size - l_chunk_size;
            l_offset := l_offset + l_chunk_size;
        END LOOP;

        l_msg_count := FND_MSG_PUB.Count_Msg;

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            retcode := 2;  -- error based only on return status
            fnd_file.put(fnd_file.log, '     retcode - '||retcode);
            fnd_file.put(fnd_file.log, '     l_return_status - '||l_return_status);
        ELSIF (l_msg_count > 0 AND l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            retcode := 1;  -- warning based on return status + msg count
            fnd_file.put(fnd_file.log, '     retcode - '||retcode);
            fnd_file.put(fnd_file.log, '     l_msg_count - '||l_msg_count);
        ELSE
            retcode := 0;  -- success, since nothing is wrong
            fnd_file.put(fnd_file.log, '     retcode - '||retcode);
            l_offset     := 1;
            l_chunk_size := 3000;
            l_clob_size := dbms_lob.getlength(l_clob);
            WHILE (l_clob_size > 0) LOOP
                l_chunk := dbms_lob.substr (l_clob, l_chunk_size, l_offset);
                fnd_file.put(fnd_file.output, l_chunk);
                l_clob_size := l_clob_size - l_chunk_size;
                l_offset := l_offset + l_chunk_size;
            END LOOP;
        END IF;
     END RA_ANALYSER_PROCESS;

    --------------------------------------------------------------------------
    -- To log error messages into a log file if called from concurrent process.
    ---------------------------------------------------------------------------
    PROCEDURE log_error_messages IS

    l_msg_count      NUMBER;
    l_msg_index_out  NUMBER;
    l_msg_data       VARCHAR2(2000);

    BEGIN

     -- Standard call to get message count.
    l_msg_count := FND_MSG_PUB.Count_Msg;

    FOR i IN 1..l_msg_count LOOP
      FND_MSG_PUB.get (
          p_msg_index      => i,
          p_encoded        => FND_API.G_FALSE,
          p_data           => l_msg_data,
          p_msg_index_out  => l_msg_index_out );

      fnd_file.put_line(FND_FILE.LOG, 'Err message-'||l_msg_index_out||':' || l_msg_data);
    END LOOP;

    END log_error_messages;

END AHL_RA_ANALYSER_PVT;

/
