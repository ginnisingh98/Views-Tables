--------------------------------------------------------
--  DDL for Package Body AHL_UMP_PROCESSUNIT_EXTN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UMP_PROCESSUNIT_EXTN_PVT" AS
/* $Header: AHLVUMEB.pls 120.5.12010000.2 2008/12/27 01:01:31 sracha ship $ */

G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AHL_UMP_ProcessUnit_EXTN_PVT';
G_APPLN_USAGE_CODE  CONSTANT VARCHAR2(30) := LTRIM(RTRIM(FND_PROFILE.VALUE('AHL_APPLN_USAGE')));
G_DEBUG             VARCHAR2(1)   := AHL_DEBUG_PUB.is_log_enabled;

------------------------------
-- Declare Local Procedures --
------------------------------

-- To create ahl_unit_effectivities record.
PROCEDURE create_record (p_x_temp_mr_rec IN OUT NOCOPY ahl_temp_unit_effectivities%ROWTYPE);


-- To update ahl_unit_effectivities record.
PROCEDURE update_record (p_temp_mr_rec IN ahl_temp_unit_effectivities%ROWTYPE,
                         p_mr_rec IN ahl_unit_effectivities_app_v%ROWTYPE);

-- To create decendent records and build relationships if the MR is a group MR.
PROCEDURE create_group (p_x_temp_grp_rec IN OUT NOCOPY ahl_temp_unit_effectivities%ROWTYPE);

-- To update decendent records and update relationships if the MR is a group MR.
PROCEDURE update_group (p_temp_mr_rec IN ahl_temp_unit_effectivities%ROWTYPE,
                        p_mr_rec IN ahl_unit_effectivities_app_v%ROWTYPE);

-- Process deferral and SR records.
-- Added for 11.5.10.
PROCEDURE Flush_Unit_SR_Deferrals;


-- Procedure to delete rows from ahl_schedule_materials.
PROCEDURE Delete_Sch_Materials(p_unit_effectivity_id  IN NUMBER);


------------------------------
-- Define Procedures --
------------------------------

-- To flush the unit effectivities created in the temporary table (ahl_temp_unit_effectivities)
-- by AHL_UMP_PROCESSUNIT_PVT.Process_Unit into ahl_unit_effectivities and ahl_ue_relationships.

PROCEDURE Flush_From_Temp_table (p_config_node_tbl IN AHL_UMP_PROCESSUNIT_PVT.config_node_tbl_type)

IS

  -- get individual MRs for item instance and top group records
  -- from temporary table.
  CURSOR temp_individual_mrs_csr IS
    SELECT  unit_effectivity_id,
            csi_item_instance_id,
            MR_header_id,
            due_date,
            mr_interval_id,
            mr_effectivity_id,
            due_counter_value,
            parent_csi_item_instance_id,
            parent_mr_header_id,
            orig_csi_item_instance_id,
            orig_mr_header_id,
            forecast_sequence,
            repetitive_mr_flag,
            tolerance_flag,
            message_code,
            service_line_id,
            program_mr_header_id,
            earliest_due_date,
            latest_due_date,
            counter_id
    FROM ahl_temp_unit_effectivities
    WHERE MR_header_id = nvl(orig_mr_header_id, mr_header_id) AND
          csi_item_instance_id = nvl(orig_csi_item_instance_id,csi_item_instance_id)
    ORDER by forecast_sequence ASC
    FOR UPDATE OF unit_effectivity_id;

  -- Cursor for getting all temp unit effectivities that have preceding MRs.
  CURSOR dependent_mr_csr IS
     SELECT preceding_mr_header_id, preceding_csi_item_instance_id,
            preceding_forecast_seq, unit_effectivity_id
     FROM ahl_temp_unit_effectivities
     WHERE preceding_mr_header_id IS NOT NULL AND
           preceding_csi_item_instance_id IS NOT NULL AND
           preceding_forecast_seq IS NOT NULL;

  -- Cursor for getting the preceding MR unit effectivity from temporary table.
  CURSOR preceding_mr_csr (p_preceding_mr_header_id IN NUMBER,
                           p_preceding_item_instance IN NUMBER,
                           p_preceding_forecast_seq IN NUMBER) IS
     SELECT unit_effectivity_id
     FROM ahl_temp_unit_effectivities
     WHERE mr_header_id = p_preceding_mr_header_id AND
           csi_item_instance_id = p_preceding_item_instance AND
           forecast_sequence = p_preceding_forecast_seq;


  -- Cursor to get all details of a unit effectivity record.
  CURSOR ahl_unit_effectivity_csr ( p_unit_effectivity_id IN NUMBER) IS
     SELECT
        UNIT_EFFECTIVITY_ID ,
        CSI_ITEM_INSTANCE_ID,
        MR_INTERVAL_ID,
        MR_EFFECTIVITY_ID ,
        MR_HEADER_ID,
        STATUS_CODE ,
        DUE_DATE   ,
        DUE_COUNTER_VALUE ,
        FORECAST_SEQUENCE ,
        REPETITIVE_MR_FLAG ,
        TOLERANCE_FLAG ,
        REMARKS ,
        MESSAGE_CODE ,
        PRECEDING_UE_ID ,
        DATE_RUN ,
        SET_DUE_DATE ,
        ACCOMPLISHED_DATE ,
        SERVICE_LINE_ID,
        PROGRAM_MR_HEADER_ID,
        CANCEL_REASON_CODE,
        EARLIEST_DUE_DATE,
        LATEST_DUE_DATE,
        defer_from_ue_id,
        cs_incident_id,
        qa_collection_id,
        orig_deferral_ue_id,
        application_usg_code,
        object_type,
        counter_id,
        manually_planned_flag,
        LOG_SERIES_CODE,
        LOG_SERIES_NUMBER,
        FLIGHT_NUMBER,
        MEL_CDL_TYPE_CODE,
        POSITION_PATH_ID,
        ATA_CODE,
        UNIT_CONFIG_HEADER_ID,
        ATTRIBUTE_CATEGORY ,
        ATTRIBUTE1,
        ATTRIBUTE2 ,
        ATTRIBUTE3 ,
        ATTRIBUTE4 ,
        ATTRIBUTE5 ,
        ATTRIBUTE6 ,
        ATTRIBUTE7 ,
        ATTRIBUTE8 ,
        ATTRIBUTE9 ,
        ATTRIBUTE10,
        ATTRIBUTE11 ,
        ATTRIBUTE12 ,
        ATTRIBUTE13 ,
        ATTRIBUTE14 ,
        ATTRIBUTE15 ,
        OBJECT_VERSION_NUMBER ,
        LAST_UPDATE_DATE ,
        LAST_UPDATED_BY ,
        LAST_UPDATE_LOGIN

     --FROM ahl_unit_effectivities_app_v
     FROM ahl_unit_effectivities_vl
     WHERE unit_effectivity_id = p_unit_effectivity_id;
     --FOR UPDATE OF preceding_ue_id, status_code NOWAIT; -- not required as these rows were locked before.

   -- Cursor for reading unit effectivity records(top nodes) that have not been updated.
  CURSOR ahl_exception_csr (p_csi_item_instance_id IN NUMBER,
                            p_date_run     IN DATE)  IS
    SELECT
        UNIT_EFFECTIVITY_ID,
        CSI_ITEM_INSTANCE_ID,
        MR_HEADER_ID,
        STATUS_CODE,
        MR_INTERVAL_ID,
        MR_EFFECTIVITY_ID ,
        DUE_DATE   ,
        DUE_COUNTER_VALUE ,
        FORECAST_SEQUENCE ,
        REPETITIVE_MR_FLAG ,
        TOLERANCE_FLAG ,
        REMARKS ,
        MESSAGE_CODE ,
        PRECEDING_UE_ID ,
        DATE_RUN ,
        SET_DUE_DATE ,
        ACCOMPLISHED_DATE ,
        SERVICE_LINE_ID,
        PROGRAM_MR_HEADER_ID,
        CANCEL_REASON_CODE,
        EARLIEST_DUE_DATE,
        LATEST_DUE_DATE,
        defer_from_ue_id,
        cs_incident_id,
        qa_collection_id,
        orig_deferral_ue_id,
        application_usg_code,
        object_type,
        counter_id,
        manually_planned_flag,
        LOG_SERIES_CODE,
        LOG_SERIES_NUMBER,
        FLIGHT_NUMBER,
        MEL_CDL_TYPE_CODE,
        POSITION_PATH_ID,
        ATA_CODE,
        UNIT_CONFIG_HEADER_ID,
        ATTRIBUTE_CATEGORY ,
        ATTRIBUTE1,
        ATTRIBUTE2 ,
        ATTRIBUTE3 ,
        ATTRIBUTE4 ,
        ATTRIBUTE5 ,
        ATTRIBUTE6 ,
        ATTRIBUTE7 ,
        ATTRIBUTE8 ,
        ATTRIBUTE9 ,
        ATTRIBUTE10,
        ATTRIBUTE11 ,
        ATTRIBUTE12 ,
        ATTRIBUTE13 ,
        ATTRIBUTE14 ,
        ATTRIBUTE15 ,
        OBJECT_VERSION_NUMBER

     FROM ahl_unit_effectivities_app_v ue
     WHERE csi_item_instance_id = p_csi_item_instance_id AND
           ( status_code IS NULL OR
             status_code NOT IN ('ACCOMPLISHED','TERMINATED',
                                 'MR-TERMINATE', 'INIT-ACCOMPLISHED',
                                 'DEFERRED', 'SR-CLOSED','CANCELLED'))
           AND date_run < p_date_run
           --AND defer_from_ue_id IS NULL
           AND nvl(manually_planned_flag,'N') = 'N'
           AND NOT EXISTS (SELECT 'x'
                           FROM ahl_ue_relationships
                           WHERE related_ue_id = ue.unit_effectivity_id);
     -- FOR UPDATE OF message_code NOWAIT;
     -- UMP rows are already locked by ahl_ump_processunit_pvt.lock_effectivity
     -- proc.

  -- Cursor to get all decendents for a UE.
  CURSOR decendent_csr (p_unit_effectivity_id IN NUMBER) IS
    SELECT ue_relationship_id, related_ue_id
    FROM ahl_ue_relationships
    WHERE relationship_code = 'PARENT' AND
          originator_ue_id = p_unit_effectivity_id;

  -- Cursor to check if init-due excepion still valid.
  CURSOR exception_init_due_csr (p_unit_effectivity_id IN NUMBER) IS
    SELECT unit_deferral_id
    --FROM ahl_unit_thresholds
    FROM ahl_unit_deferrals_b
    WHERE unit_effectivity_id = p_unit_effectivity_id
      AND unit_deferral_type = 'INIT-DUE';

  -- to check if ue has child ue records.
  CURSOR chk_child_ue_csr (p_unit_effectivity_id IN NUMBER) IS
    SELECT 'x'
    FROM ahl_ue_relationships
    WHERE ue_id = p_unit_effectivity_id;

  l_visit_status_code  VARCHAR2(40);

  l_csi_item_instance_id  NUMBER;
  l_start_time  DATE;

  l_temp_individual_mr_rec temp_individual_mrs_csr%ROWTYPE;

  l_temp_mr_rec ahl_temp_unit_effectivities%ROWTYPE;
  l_mr_rec  ahl_unit_effectivities_app_v%ROWTYPE;

  l_temp_mr_found BOOLEAN;
  l_mr_found BOOLEAN;

  l_unit_effectivity_id  NUMBER;
  l_ue_rec               ahl_unit_effectivity_csr%ROWTYPE;

  l_last_accomplishment_date   DATE;
  l_acc_unit_effectivity_id    NUMBER;
  l_acc_status_code            ahl_unit_effectivities_app_v.status_code%TYPE;
  l_return_val                 BOOLEAN;

  l_exception_upd_flag         BOOLEAN;
  l_delete_flag                BOOLEAN;
  l_exception_code             fnd_lookups.lookup_code%TYPE;
  l_unit_effectivity_rec       ahl_unit_effectivity_csr%ROWTYPE;
  l_junk                       VARCHAR2(1);

  l_incident_id                NUMBER;
  l_incident_number            CS_INCIDENTS_ALL_VL.incident_number%TYPE;
  l_scheduled_date             DATE;

  -- Cursor to check whether contract for exiting UE is valid(bug#4692366)
  CURSOR valid_contract_csr (p_unit_effectivity_id IN NUMBER) IS
  SELECT 'x' from okc_k_lines_b OKCL, ahl_unit_effectivities_b UE
  --WHERE NVL(NVL(DATE_TERMINATED,END_DATE),SYSDATE) >= SYSDATE
  -- Fix for bug# 5517930
  WHERE NVL(NVL(DATE_TERMINATED,END_DATE),SYSDATE+1) >= trunc(SYSDATE)
  AND OKCL.id = UE.service_line_id
  AND UE.unit_effectivity_id = p_unit_effectivity_id;

  -- Added for bug fix 5764351).
  -- delete UMP rows only if due date > termination date/end date.
  CURSOR valid_due_date_csr (p_unit_effectivity_id IN NUMBER,
                             p_due_date            IN DATE) IS
    SELECT 'x'
    FROM okc_k_lines_b OKCL, ahl_unit_effectivities_b UE
    WHERE trunc(p_due_date) <= NVL(DATE_TERMINATED,END_DATE)
      AND OKCL.id = UE.service_line_id
      AND UE.unit_effectivity_id = p_unit_effectivity_id;

  -- Fix for bug# 6711228.
  l_acc_deferral_flag          BOOLEAN;

  l_unit_deferral_id           NUMBER;

BEGIN

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.Debug('Start Flush from Temporary Table');
  END IF;

  -- record start time.
  l_start_time := sysdate;

  -- Read temporary table.
  FOR temp_individual_mr_rec IN temp_individual_mrs_csr LOOP

    l_temp_individual_mr_rec := temp_individual_mr_rec;
    IF (l_temp_individual_mr_rec.unit_effectivity_id is null) THEN  /* no previous record */

        l_mr_found := FALSE;
    ELSE
       OPEN ahl_unit_effectivity_csr (l_temp_individual_mr_rec.unit_effectivity_id);
       -- get unit effectivity record details as we need to update it.
       FETCH ahl_unit_effectivity_csr INTO l_ue_rec;
       IF (ahl_unit_effectivity_csr%FOUND) THEN
         l_mr_found := TRUE;
         -- fix for bug number 4692366
         IF (l_ue_rec.service_line_id IS NOT NULL) THEN
           OPEN valid_contract_csr(l_temp_individual_mr_rec.unit_effectivity_id);
           FETCH valid_contract_csr INTO l_junk;
           IF(valid_contract_csr%NOTFOUND)THEN
             l_mr_found := FALSE;
           END IF;
           CLOSE valid_contract_csr;
           -- end of fix for bug number 4692366
         ELSE
           -- this check is not need for PM flow.
           -- added this check for case where applicable MR is not a group but associated UE is a group MR.
           -- in this case we create a new ue.
           IF (l_temp_individual_mr_rec.orig_mr_header_id IS NULL) THEN
             OPEN chk_child_ue_csr(l_temp_individual_mr_rec.unit_effectivity_id);
             FETCH chk_child_ue_csr INTO l_junk;
             IF (chk_child_ue_csr%FOUND) THEN
                l_mr_found := FALSE;
             END IF;
             CLOSE chk_child_ue_csr;
           END IF; -- l_temp_individual_mr_rec.orig_mr_header_id
         END IF; -- l_ue_rec.service_line_id
       ELSE
         l_mr_found := FALSE;
       END IF;
       CLOSE ahl_unit_effectivity_csr;

    END IF;

    -- convert cursor rowtype to table rowtype.
    l_temp_mr_rec.unit_effectivity_id := l_temp_individual_mr_rec.unit_effectivity_id;
    l_temp_mr_rec.csi_item_instance_id := l_temp_individual_mr_rec.csi_item_instance_id;
    l_temp_mr_rec.MR_HEADER_ID := l_temp_individual_mr_rec.MR_header_id;
    l_temp_mr_rec.due_date := l_temp_individual_mr_rec.due_date;
    l_temp_mr_rec.mr_interval_id := l_temp_individual_mr_rec.mr_interval_id;
    l_temp_mr_rec.mr_effectivity_id := l_temp_individual_mr_rec.mr_effectivity_id;
    l_temp_mr_rec.due_counter_value := l_temp_individual_mr_rec.due_counter_value;
    l_temp_mr_rec.parent_csi_item_instance_id := l_temp_individual_mr_rec.parent_csi_item_instance_id;
    l_temp_mr_rec.parent_mr_header_id := l_temp_individual_mr_rec.parent_mr_header_id;
    l_temp_mr_rec.orig_csi_item_instance_id := l_temp_individual_mr_rec.orig_csi_item_instance_id;
    l_temp_mr_rec.orig_mr_header_id := l_temp_individual_mr_rec.orig_mr_header_id;
    l_temp_mr_rec.forecast_sequence := l_temp_individual_mr_rec.forecast_sequence;
    l_temp_mr_rec.repetitive_mr_flag := l_temp_individual_mr_rec.repetitive_mr_flag;
    l_temp_mr_rec.tolerance_flag := l_temp_individual_mr_rec.tolerance_flag;
    l_temp_mr_rec.message_code := l_temp_individual_mr_rec.message_code;
    l_temp_mr_rec.service_line_id := l_temp_individual_mr_rec.service_line_id;
    l_temp_mr_rec.program_mr_header_id := l_temp_individual_mr_rec.program_mr_header_id;
    l_temp_mr_rec.earliest_due_date := l_temp_individual_mr_rec.earliest_due_date;
    l_temp_mr_rec.latest_due_date := l_temp_individual_mr_rec.latest_due_date;
    l_temp_mr_rec.counter_id := l_temp_individual_mr_rec.counter_id;


    IF (l_mr_found) THEN
      -- convert cursor rowtype to table rowtype.
      l_mr_rec.unit_effectivity_id := l_ue_rec.unit_effectivity_id;
      l_mr_rec.csi_item_instance_id := l_ue_rec.csi_item_instance_id;
      l_mr_rec.MR_header_id := l_ue_rec.MR_header_id ;
      l_mr_rec.STATUS_CODE := l_ue_rec.STATUS_CODE ;
      l_mr_rec.SET_DUE_DATE := l_ue_rec.SET_DUE_DATE;
      l_mr_rec.ACCOMPLISHED_DATE := l_ue_rec.ACCOMPLISHED_DATE;
      l_mr_rec.CANCEL_REASON_CODE := l_ue_rec.CANCEL_REASON_CODE;
      l_mr_rec.defer_from_ue_id := l_ue_rec.defer_from_ue_id;
      l_mr_rec.cs_incident_id := l_ue_rec.cs_incident_id;
      l_mr_rec.qa_collection_id := l_ue_rec.qa_collection_id;
      l_mr_rec.orig_deferral_ue_id := l_ue_rec.orig_deferral_ue_id;
      l_mr_rec.application_usg_code := l_ue_rec.application_usg_code;
      l_mr_rec.object_type := l_ue_rec.object_type;
      --l_mr_rec.counter_id := l_ue_rec.counter_id;
      l_mr_rec.ATTRIBUTE_CATEGORY := l_ue_rec.ATTRIBUTE_CATEGORY;
      l_mr_rec.ATTRIBUTE1 := l_ue_rec.ATTRIBUTE1;
      l_mr_rec.ATTRIBUTE2 := l_ue_rec.ATTRIBUTE2;
      l_mr_rec.ATTRIBUTE3 := l_ue_rec.ATTRIBUTE3;
      l_mr_rec.ATTRIBUTE4 := l_ue_rec.ATTRIBUTE4;
      l_mr_rec.ATTRIBUTE5 := l_ue_rec.ATTRIBUTE5;
      l_mr_rec.ATTRIBUTE6 := l_ue_rec.ATTRIBUTE6;
      l_mr_rec.ATTRIBUTE7 := l_ue_rec.ATTRIBUTE7;
      l_mr_rec.ATTRIBUTE8 := l_ue_rec.ATTRIBUTE8;
      l_mr_rec.ATTRIBUTE9 := l_ue_rec.ATTRIBUTE9;
      l_mr_rec.ATTRIBUTE10 := l_ue_rec.ATTRIBUTE10;
      l_mr_rec.ATTRIBUTE11 := l_ue_rec.ATTRIBUTE11;
      l_mr_rec.ATTRIBUTE12 := l_ue_rec.ATTRIBUTE12;
      l_mr_rec.ATTRIBUTE13 := l_ue_rec.ATTRIBUTE13;
      l_mr_rec.ATTRIBUTE14 := l_ue_rec.ATTRIBUTE14;
      l_mr_rec.ATTRIBUTE15 := l_ue_rec.ATTRIBUTE15;
      l_mr_rec.OBJECT_VERSION_NUMBER := l_ue_rec.OBJECT_VERSION_NUMBER;
      l_mr_rec.REMARKS := l_ue_rec.REMARKS;
    END IF;

    -- Check if l_temp_individual_mr_rec is a group mr.

    IF (l_temp_individual_mr_rec.orig_mr_header_id IS NOT NULL) THEN

       IF (l_mr_found) THEN

           Update_group(l_temp_mr_rec,
                        l_mr_rec);
       ELSE

           Create_group(l_temp_mr_rec);

       END IF;
    ELSE  /* not a group */
       IF (l_mr_found) THEN
          -- update unit_effectivity record with temp details.

          update_record(l_temp_mr_rec,
                        l_mr_rec);

       ELSE

          create_record(l_temp_mr_rec);
          -- update unit effectivity ID.
          UPDATE ahl_temp_unit_effectivities
                 SET unit_effectivity_id = l_temp_mr_rec.unit_effectivity_id
          WHERE CURRENT OF temp_individual_mrs_csr;
       END IF;
    END IF;

  END LOOP; /* for temp_individual_mrs_csr */

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.Debug('End Process of all MRs from temp table');
  END IF;

  -- Now read ahl_unit_effectivities and update preceding_ue_id.
  FOR dependent_rec IN dependent_mr_csr LOOP

      OPEN preceding_mr_csr (dependent_rec.preceding_mr_header_id,
                             dependent_rec.preceding_csi_item_instance_id,
                             dependent_rec.preceding_forecast_seq);
      FETCH preceding_mr_csr INTO l_unit_effectivity_id;

      IF (preceding_mr_csr%NOTFOUND) THEN
         -- check if accomplishment exists for preceding MR to get UE Id.
         -- Fix for bug# 6711228.
         AHL_UMP_UTIL_PKG.get_first_accomplishment(
                                   dependent_rec.preceding_csi_item_instance_id,
                                   dependent_rec.preceding_mr_header_id,
                                   l_last_accomplishment_date,
                                   l_acc_unit_effectivity_id,
                                   l_acc_deferral_flag,
                                   l_acc_status_code,
                                   l_return_val);

         IF (l_acc_unit_effectivity_id IS NOT NULL) THEN
            l_unit_effectivity_id := l_acc_unit_effectivity_id;
         ELSE
           FND_MESSAGE.Set_Name('AHL','AHL_UMP_PUE_PRECID_NOTFOUND');
           FND_MESSAGE.Set_Token('UE_ID',dependent_rec.unit_effectivity_id);
           FND_MSG_PUB.ADD;
           -- dbms_output.put_line('preceding mr not found for dependent ue id in temporary table');
           CLOSE preceding_mr_csr;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF; -- preceding_mr_csr%NOTFOUND
      CLOSE preceding_mr_csr;

      OPEN ahl_unit_effectivity_csr (dependent_rec.unit_effectivity_id);
      FETCH ahl_unit_effectivity_csr INTO l_ue_rec;
      IF (ahl_unit_effectivity_csr%FOUND) THEN

              AHL_UNIT_EFFECTIVITIES_PKG.Update_Row(
                  X_UNIT_EFFECTIVITY_ID   => l_ue_rec.unit_effectivity_id,
                  X_CSI_ITEM_INSTANCE_ID  => l_ue_rec.csi_item_instance_id,
                  X_MR_INTERVAL_ID        => l_ue_rec.mr_interval_id,
                  X_MR_EFFECTIVITY_ID     => l_ue_rec.mr_effectivity_id,
                  X_MR_HEADER_ID          => l_ue_rec.mr_header_id,
                  X_STATUS_CODE           => l_ue_rec.status_code,
                  X_DUE_DATE              => l_ue_rec.due_date,
                  X_DUE_COUNTER_VALUE     => l_ue_rec.due_counter_value,
                  X_FORECAST_SEQUENCE     => l_ue_rec.forecast_sequence,
                  X_REPETITIVE_MR_FLAG    => l_ue_rec.repetitive_mr_flag,
                  X_TOLERANCE_FLAG        => l_ue_rec.tolerance_flag,
                  X_REMARKS               => l_ue_rec.remarks,
                  X_MESSAGE_CODE          => l_ue_rec.message_code,
                  X_PRECEDING_UE_ID       => l_unit_effectivity_id,
                  X_DATE_RUN              => l_ue_rec.date_run,
                  X_SET_DUE_DATE          => l_ue_rec.set_due_date,
                  X_ACCOMPLISHED_DATE     => l_ue_rec.accomplished_date,
                  X_SERVICE_LINE_ID       => l_ue_rec.service_line_id,
                  X_PROGRAM_MR_HEADER_ID  => l_ue_rec.program_mr_header_id,
                  X_CANCEL_REASON_CODE    => l_ue_rec.cancel_reason_code,
                  X_EARLIEST_DUE_DATE     => l_ue_rec.earliest_due_date,
                  X_LATEST_DUE_DATE       => l_ue_rec.latest_due_date,
                  X_defer_from_ue_id      => l_ue_rec.defer_from_ue_id,
                  X_cs_incident_id        => l_ue_rec.cs_incident_id,
                  X_qa_collection_id      => l_ue_rec.qa_collection_id,
                  X_orig_deferral_ue_id   => l_ue_rec.orig_deferral_ue_id,
                  X_application_usg_code  => l_ue_rec.application_usg_code,
                  X_object_type           => l_ue_rec.object_type,
                  X_counter_id            => l_ue_rec.counter_id,
                  X_MANUALLY_PLANNED_FLAG => l_ue_rec.MANUALLY_PLANNED_FLAG,
                  X_LOG_SERIES_CODE       => l_ue_rec.log_series_code,
                  X_LOG_SERIES_NUMBER     => l_ue_rec.log_series_number,
                  X_FLIGHT_NUMBER         => l_ue_rec.flight_number,
                  X_MEL_CDL_TYPE_CODE     => l_ue_rec.mel_cdl_type_code,
                  X_POSITION_PATH_ID      => l_ue_rec.position_path_id,
                  X_ATA_CODE              => l_ue_rec.ATA_CODE,
                  X_UNIT_CONFIG_HEADER_ID  => l_ue_rec.unit_config_header_id,
                  X_ATTRIBUTE_CATEGORY    => l_ue_rec.attribute_category,
                  X_ATTRIBUTE1            => l_ue_rec.attribute1,
                  X_ATTRIBUTE2            => l_ue_rec.attribute2,
                  X_ATTRIBUTE3             => l_ue_rec.attribute3,
                  X_ATTRIBUTE4            => l_ue_rec.attribute4,
                  X_ATTRIBUTE5             => l_ue_rec.attribute5,
                  X_ATTRIBUTE6            => l_ue_rec.attribute6,
                  X_ATTRIBUTE7            => l_ue_rec.attribute7,
                  X_ATTRIBUTE8             => l_ue_rec.attribute8,
                  X_ATTRIBUTE9             => l_ue_rec.attribute9,
                  X_ATTRIBUTE10             => l_ue_rec.attribute10,
                  X_ATTRIBUTE11            => l_ue_rec.attribute11,
                  X_ATTRIBUTE12            => l_ue_rec.attribute12,
                  X_ATTRIBUTE13             => l_ue_rec.attribute13,
                  X_ATTRIBUTE14            => l_ue_rec.attribute14,
                  X_ATTRIBUTE15            => l_ue_rec.attribute15,
                  X_OBJECT_VERSION_NUMBER => l_ue_rec.object_version_number, -- no change to this needed.
                  X_LAST_UPDATE_DATE => sysdate,
                  X_LAST_UPDATED_BY => fnd_global.user_id,
                  X_LAST_UPDATE_LOGIN  => fnd_global.login_id);
       ELSE

             FND_MESSAGE.Set_Name('AHL','AHL_UMP_PUE_UE_NOTFOUND');
             FND_MESSAGE.Set_Token('UE_ID',l_ue_rec.unit_effectivity_id);
             FND_MSG_PUB.ADD;
             -- dbms_output.put_line('preceding mr not found for dependent ue id');
             ClOSE ahl_unit_effectivity_csr;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      ClOSE ahl_unit_effectivity_csr;

  END LOOP;

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.Debug('End Preceding MR processing');
     AHL_DEBUG_PUB.Debug('Start Deferral-SR Processing');
  END IF;

  -- Process deferral and SR records.
  Flush_Unit_SR_Deferrals;

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.Debug('End Deferral-SR processing');
     AHL_DEBUG_PUB.Debug('Start Exception Processing');
  END IF;

  -- Now read ahl_unit_effectivities
  -- for records with date_run < l_startTime.

  -- Read configuration table.
  IF (p_config_node_tbl.COUNT > 0 ) THEN
    FOR i IN p_config_node_tbl.FIRST..p_config_node_tbl.LAST LOOP
      l_csi_item_instance_id := p_config_node_tbl(i).csi_item_instance_id;

      FOR exception_rec IN ahl_exception_csr(l_csi_item_instance_id, l_start_time) LOOP

        IF G_DEBUG = 'Y' THEN
          AHL_DEBUG_PUB.Debug('Exception for unit effectivity ID:' || exception_rec.unit_effectivity_id);
        END IF;

        -- Initialize.
        l_exception_upd_flag := FALSE;
        l_delete_flag := TRUE;

        /*
        -- If status code is INIT-DUE mark as exception.
        IF (exception_rec.status_code = 'INIT-DUE') THEN
            l_visit_status_code := AHL_UMP_UTIL_PKG.get_visit_status (exception_rec.unit_effectivity_id);
            IF G_DEBUG = 'Y' THEN
              AHL_DEBUG_PUB.Debug('Visit Status Code from VWP is:' || l_visit_status_code);
            END IF;

            -- If visit is in released and closed status then, do not mark exception or deletion.
            IF (l_visit_status_code IS NOT NULL AND l_visit_status_code = 'PLANNING') THEN
              l_exception_upd_flag := TRUE;
              l_exception_code := 'INIT-DUE';

              IF G_DEBUG = 'Y' THEN
                AHL_DEBUG_PUB.Debug('Exception - Init-Due');
              END IF;
            ELSIF (l_visit_status_code IS NULL) THEN -- not assigned to visit
              l_delete_flag := TRUE;
            ELSE -- on shop floor
              -- do not update to exception status or delete.
              l_exception_upd_flag := FALSE;
              l_delete_flag := FALSE;
            END IF;

        ELSIF (exception_rec.status_code = 'INIT-ACCOMPLISHED') THEN
            -- Check if accomplishments exist after init-accomplished.
            AHL_UMP_UTIL_PKG.get_last_accomplishment(l_csi_item_instance_id,
                                                     exception_rec.mr_header_id,
                                                     l_last_accomplishment_date,
                                                     l_acc_unit_effectivity_id,
                                                     l_acc_status_code,
                                                     l_return_val);

            IF (l_acc_unit_effectivity_id IS NULL OR
                l_acc_unit_effectivity_id = exception_rec.unit_effectivity_id) THEN
                l_exception_upd_flag := TRUE;
                l_exception_code := 'INIT-ACCOMPLISHED';

                IF G_DEBUG = 'Y' THEN
                  AHL_DEBUG_PUB.Debug('Exception - Init-Accomplished');
                END IF;
            END IF;

        ELSIF (exception_rec.status_code = 'DEFERRED') THEN
                l_exception_upd_flag := TRUE;
                l_exception_code := 'DEFERRED';

                IF G_DEBUG = 'Y' THEN
                  AHL_DEBUG_PUB.Debug('Exception - Deferred');
                END IF;

        ELSIF (exception_rec.status_code = 'EXCEPTION' AND
               exception_rec.message_code = 'INIT-DUE'
                -- OR exception_rec.message_code = 'DEFERRED')
              ) THEN
              -- Check if exception corrected.
              IF (exception_rec.set_due_date IS NOT NULL) THEN
                l_exception_upd_flag := TRUE;
                l_exception_code := exception_rec.message_code;
              ELSE
                OPEN exception_init_due_csr (exception_rec.unit_effectivity_id);
                FETCH exception_init_due_csr INTO l_junk;
                IF (exception_init_due_csr%FOUND) THEN
                   l_exception_upd_flag := TRUE;
                   l_exception_code := exception_rec.message_code;
                   IF G_DEBUG = 'Y' THEN
                     AHL_DEBUG_PUB.Debug('Exception - Init-Due');
                   END IF;
                END IF;
                CLOSE exception_init_due_csr;
              END IF;
        END IF;
        */

        -- check if assigned to visit if not flagged for exception.
        IF (AHL_UTIL_PKG.IS_PM_INSTALLED = 'N') THEN  -- AHL Installation.
          l_visit_status_code := AHL_UMP_UTIL_PKG.get_visit_status (exception_rec.unit_effectivity_id);
          IF G_DEBUG = 'Y' THEN
            AHL_DEBUG_PUB.Debug('Visit Status Code from VWP is:' || l_visit_status_code);
          END IF;

          -- If visit is in released and closed status then, do not mark exception or deletion.
          IF (l_visit_status_code IS NOT NULL) THEN
               IF (l_visit_status_code = 'PLANNING') THEN
                 IF (exception_rec.status_code = 'INIT-DUE') THEN
                     l_exception_upd_flag := TRUE;
                     l_exception_code := 'INIT-DUE';

                     IF G_DEBUG = 'Y' THEN
                       AHL_DEBUG_PUB.Debug('Exception - Init-Due');
                     END IF;

                 ELSE
                   l_exception_upd_flag := TRUE;
                   l_exception_code := 'VISIT-ASSIGN';
                   IF G_DEBUG = 'Y' THEN
                     AHL_DEBUG_PUB.Debug('Exception - Visit Assign');
                   END IF;
                 END IF;

               ELSE
                  -- set no deletion if visit in released/closed status.
                  l_delete_flag := FALSE;
               END IF;
          ELSE
             IF (exception_rec.defer_from_ue_id IS NULL) OR
                (exception_rec.status_code = 'EXCEPTION' AND exception_rec.defer_from_ue_id IS NOT NULL) THEN
               -- not assigned to any visit.
               l_delete_flag := TRUE;
             ELSE
               -- do not delete deferrals not in exception status.
               l_delete_flag := FALSE;
             END IF;
          END IF;
        ELSE
          -- PM Installation.
          AHL_UMP_UTIL_PKG.get_ServiceRequest_Details(exception_rec.unit_effectivity_id,
                                                      l_incident_id,
                                                      l_incident_number,
                                                      l_scheduled_date);
          IF G_DEBUG = 'Y' THEN
            AHL_DEBUG_PUB.Debug('Service request ID-NUM is:' || l_incident_id || '-' || l_incident_number);
          END IF;

          IF (l_incident_id IS NOT NULL) THEN
              l_delete_flag := FALSE;
          ELSE
            IF (exception_rec.due_date IS NOT NULL) THEN
              -- check if associated service line ID has expired. If expired, do
              -- not delete UMP row if due date <= contract termination date.
              OPEN valid_due_date_csr(exception_rec.unit_effectivity_id,
                                      exception_rec.due_date);
              FETCH valid_due_date_csr INTO l_junk;
              IF(valid_due_date_csr%FOUND)THEN
                  l_delete_flag := FALSE;
                  IF AHL_DEBUG_PUB.G_FILE_DEBUG THEN
                      AHL_DEBUG_PUB.Debug('Service Line Expired for UE with due date < termination/end date. Will not delete');
                  END IF;
              END IF;
              CLOSE valid_due_date_csr;
            END IF; -- exception_rec.due_date IS NOT NULL
          END IF; -- l_incident_id
        END IF; -- AHL Installation.

        IF (l_exception_upd_flag) THEN
            IF G_DEBUG = 'Y' THEN
              AHL_DEBUG_PUB.Debug('Updating exception code..');
            END IF;

            -- update unit effectivity.
            exception_rec.message_code := l_exception_code;
            exception_rec.status_code := 'EXCEPTION';

            AHL_UNIT_EFFECTIVITIES_PKG.Update_Row(
                  X_UNIT_EFFECTIVITY_ID   => exception_rec.unit_effectivity_id,
                  X_CSI_ITEM_INSTANCE_ID  => exception_rec.csi_item_instance_id,
                  X_MR_INTERVAL_ID        => exception_rec.mr_interval_id,
                  X_MR_EFFECTIVITY_ID     => exception_rec.mr_effectivity_id,
                  X_MR_HEADER_ID          => exception_rec.mr_header_id,
                  X_STATUS_CODE           => exception_rec.status_code,
                  X_DUE_DATE              => exception_rec.due_date,
                  X_DUE_COUNTER_VALUE     => exception_rec.due_counter_value,
                  X_FORECAST_SEQUENCE     => exception_rec.forecast_sequence,
                  X_REPETITIVE_MR_FLAG    => exception_rec.repetitive_mr_flag,
                  X_TOLERANCE_FLAG        => exception_rec.tolerance_flag,
                  X_REMARKS               => exception_rec.remarks,
                  X_MESSAGE_CODE          => exception_rec.message_code,
                  X_PRECEDING_UE_ID       => exception_rec.preceding_ue_id,
                  X_DATE_RUN              => sysdate,
                  X_SET_DUE_DATE          => exception_rec.set_due_date,
                  X_ACCOMPLISHED_DATE     => exception_rec.accomplished_date,
                  X_SERVICE_LINE_ID       => exception_rec.service_line_id,
                  X_PROGRAM_MR_HEADER_ID  => exception_rec.program_mr_header_id,
                  X_CANCEL_REASON_CODE    => exception_rec.cancel_reason_code,
                  X_EARLIEST_DUE_DATE     => exception_rec.earliest_due_date,
                  X_LATEST_DUE_DATE       => exception_rec.latest_due_date,
                  X_defer_from_ue_id      => exception_rec.defer_from_ue_id,
                  X_cs_incident_id        => exception_rec.cs_incident_id,
                  X_qa_collection_id      => exception_rec.qa_collection_id,
                  X_orig_deferral_ue_id   => exception_rec.orig_deferral_ue_id,
                  X_application_usg_code  => exception_rec.application_usg_code,
                  X_object_type           => exception_rec.object_type,
                  X_counter_id            => exception_rec.counter_id,
                  X_MANUALLY_PLANNED_FLAG => exception_rec.MANUALLY_PLANNED_FLAG,
                  X_LOG_SERIES_CODE       => exception_rec.log_series_code,
                  X_LOG_SERIES_NUMBER     => exception_rec.log_series_number,
                  X_FLIGHT_NUMBER         => exception_rec.flight_number,
                  X_MEL_CDL_TYPE_CODE     => exception_rec.mel_cdl_type_code,
                  X_POSITION_PATH_ID      => exception_rec.position_path_id,
                  X_ATA_CODE              => exception_rec.ATA_CODE,
                  X_UNIT_CONFIG_HEADER_ID  => exception_rec.unit_config_header_id,
                  X_ATTRIBUTE_CATEGORY    => exception_rec.attribute_category,
                  X_ATTRIBUTE1            => exception_rec.attribute1,
                  X_ATTRIBUTE2            => exception_rec.attribute2,
                  X_ATTRIBUTE3             => exception_rec.attribute3,
                  X_ATTRIBUTE4            => exception_rec.attribute4,
                  X_ATTRIBUTE5             => exception_rec.attribute5,
                  X_ATTRIBUTE6            => exception_rec.attribute6,
                  X_ATTRIBUTE7            => exception_rec.attribute7,
                  X_ATTRIBUTE8             => exception_rec.attribute8,
                  X_ATTRIBUTE9             => exception_rec.attribute9,
                  X_ATTRIBUTE10             => exception_rec.attribute10,
                  X_ATTRIBUTE11            => exception_rec.attribute11,
                  X_ATTRIBUTE12            => exception_rec.attribute12,
                  X_ATTRIBUTE13             => exception_rec.attribute13,
                  X_ATTRIBUTE14            => exception_rec.attribute14,
                  X_ATTRIBUTE15            => exception_rec.attribute15,
                  X_OBJECT_VERSION_NUMBER => exception_rec.object_version_number + 1,
                  X_LAST_UPDATE_DATE => sysdate,
                  X_LAST_UPDATED_BY => fnd_global.user_id,
                  X_LAST_UPDATE_LOGIN  => fnd_global.login_id);

           -- Delete the corresponding rows in ahl_schedule materials for this ue.
           Delete_Sch_Materials(exception_rec.unit_effectivity_id);

           -- update all group element's status too.
           FOR ue_reln_rec IN decendent_csr(exception_rec.unit_effectivity_id) LOOP

             OPEN ahl_unit_effectivity_csr (ue_reln_rec.related_ue_id);
             FETCH ahl_unit_effectivity_csr INTO l_ue_rec;
             IF (ahl_unit_effectivity_csr%FOUND) THEN
               AHL_UNIT_EFFECTIVITIES_PKG.Update_Row(
                  X_UNIT_EFFECTIVITY_ID   => l_ue_rec.unit_effectivity_id,
                  X_CSI_ITEM_INSTANCE_ID  => l_ue_rec.csi_item_instance_id,
                  X_MR_INTERVAL_ID        => l_ue_rec.mr_interval_id,
                  X_MR_EFFECTIVITY_ID     => l_ue_rec.mr_effectivity_id,
                  X_MR_HEADER_ID          => l_ue_rec.mr_header_id,
                  X_STATUS_CODE           => exception_rec.status_code,
                  X_DUE_DATE              => l_ue_rec.due_date,
                  X_DUE_COUNTER_VALUE     => l_ue_rec.due_counter_value,
                  X_FORECAST_SEQUENCE     => l_ue_rec.forecast_sequence,
                  X_REPETITIVE_MR_FLAG    => l_ue_rec.repetitive_mr_flag,
                  X_TOLERANCE_FLAG        => l_ue_rec.tolerance_flag,
                  X_REMARKS               => l_ue_rec.remarks,
                  X_MESSAGE_CODE          => l_ue_rec.message_code,
                  X_PRECEDING_UE_ID       => l_ue_rec.preceding_ue_id,
                  X_DATE_RUN              => sysdate,
                  X_SET_DUE_DATE          => l_ue_rec.set_due_date,
                  X_ACCOMPLISHED_DATE     => l_ue_rec.accomplished_date,
                  X_SERVICE_LINE_ID       => l_ue_rec.service_line_id,
                  X_PROGRAM_MR_HEADER_ID  => l_ue_rec.program_mr_header_id,
                  X_CANCEL_REASON_CODE    => l_ue_rec.cancel_reason_code,
                  X_EARLIEST_DUE_DATE     => l_ue_rec.earliest_due_date,
                  X_LATEST_DUE_DATE       => l_ue_rec.latest_due_date,
                  X_defer_from_ue_id      => l_ue_rec.defer_from_ue_id,
                  X_cs_incident_id        => l_ue_rec.cs_incident_id,
                  X_qa_collection_id      => l_ue_rec.qa_collection_id,
                  X_orig_deferral_ue_id   => l_ue_rec.orig_deferral_ue_id,
                  X_application_usg_code  => l_ue_rec.application_usg_code,
                  X_object_type           => l_ue_rec.object_type,
                  X_counter_id          => l_ue_rec.counter_id,
                  X_MANUALLY_PLANNED_FLAG => l_ue_rec.MANUALLY_PLANNED_FLAG,
                  X_LOG_SERIES_CODE       => l_ue_rec.log_series_code,
                  X_LOG_SERIES_NUMBER     => l_ue_rec.log_series_number,
                  X_FLIGHT_NUMBER         => l_ue_rec.flight_number,
                  X_MEL_CDL_TYPE_CODE     => l_ue_rec.mel_cdl_type_code,
                  X_POSITION_PATH_ID      => l_ue_rec.position_path_id,
                  X_ATA_CODE              => l_ue_rec.ATA_CODE,
                  X_UNIT_CONFIG_HEADER_ID  => l_ue_rec.unit_config_header_id,
                  X_ATTRIBUTE_CATEGORY    => l_ue_rec.attribute_category,
                  X_ATTRIBUTE1            => l_ue_rec.attribute1,
                  X_ATTRIBUTE2            => l_ue_rec.attribute2,
                  X_ATTRIBUTE3            => l_ue_rec.attribute3,
                  X_ATTRIBUTE4            => l_ue_rec.attribute4,
                  X_ATTRIBUTE5            => l_ue_rec.attribute5,
                  X_ATTRIBUTE6            => l_ue_rec.attribute6,
                  X_ATTRIBUTE7            => l_ue_rec.attribute7,
                  X_ATTRIBUTE8            => l_ue_rec.attribute8,
                  X_ATTRIBUTE9            => l_ue_rec.attribute9,
                  X_ATTRIBUTE10           => l_ue_rec.attribute10,
                  X_ATTRIBUTE11           => l_ue_rec.attribute11,
                  X_ATTRIBUTE12           => l_ue_rec.attribute12,
                  X_ATTRIBUTE13           => l_ue_rec.attribute13,
                  X_ATTRIBUTE14           => l_ue_rec.attribute14,
                  X_ATTRIBUTE15           => l_ue_rec.attribute15,
                  X_OBJECT_VERSION_NUMBER => l_ue_rec.object_version_number + 1,
                  X_LAST_UPDATE_DATE => sysdate,
                  X_LAST_UPDATED_BY => fnd_global.user_id,
                  X_LAST_UPDATE_LOGIN  => fnd_global.login_id);

               -- Delete the corresponding rows in ahl_schedule materials for this ue.
               Delete_Sch_Materials(l_ue_rec.unit_effectivity_id);

             ELSE
               FND_MESSAGE.Set_Name('AHL','AHL_UMP_PUE_UE_NOTFOUND');
               FND_MESSAGE.Set_Token('UE_ID',l_ue_rec.unit_effectivity_id);
               FND_MSG_PUB.ADD;
               -- dbms_output.put_line('preceding mr not found for dependent ue id');
               ClOSE ahl_unit_effectivity_csr;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
             ClOSE ahl_unit_effectivity_csr;
           END LOOP;

        ELSIF (l_delete_flag) THEN

          IF G_DEBUG = 'Y' THEN
            AHL_DEBUG_PUB.Debug('Deleting exception code..');
          END IF;

          FOR ue_reln_rec IN decendent_csr(exception_rec.unit_effectivity_id) LOOP

            -- delete relationship.
            AHL_UE_RELATIONSHIPS_PKG.Delete_Row (ue_reln_rec.ue_relationship_id);
            -- delete unit effectivity record.
            AHL_UNIT_EFFECTIVITIES_PKG.Delete_Row(ue_reln_rec.related_ue_id);

            -- Delete the corresponding rows in ahl_schedule materials for this ue.
            Delete_Sch_Materials(ue_reln_rec.related_ue_id);


          END LOOP;

          -- Delete the corresponding rows in ahl_schedule materials for this ue.
          Delete_Sch_Materials(exception_rec.unit_effectivity_id);

          IF (exception_rec.status_code = 'INIT-DUE' OR
              exception_rec.message_code = 'INIT-DUE') THEN
             IF G_DEBUG = 'Y' THEN
                AHL_DEBUG_PUB.Debug('Exception - Init-Due');
             END IF;

             OPEN exception_init_due_csr (exception_rec.unit_effectivity_id);
             FETCH exception_init_due_csr INTO l_unit_deferral_id;
             IF (exception_init_due_csr%FOUND) THEN
               DELETE from ahl_unit_thresholds
               WHERE unit_deferral_id = l_unit_deferral_id;

               AHL_UNIT_DEFERRALS_PKG.Delete_Row(l_unit_deferral_id);
             END IF;
             CLOSE exception_init_due_csr;

          END IF; -- exception_rec.status_code

          -- delete ue.
          AHL_UNIT_EFFECTIVITIES_PKG.Delete_Row(exception_rec.unit_effectivity_id);
        END IF;

      END LOOP; /* for exception rec */
    END LOOP; /* for node */
  END IF;

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.Debug('End Flush from temporary table.');
  END IF;


END Flush_From_Temp_table;

-----------------------------------------------------------------------------
-- To create ahl_unit_effectivities record.

PROCEDURE create_record (p_x_temp_mr_rec IN OUT NOCOPY ahl_temp_unit_effectivities%ROWTYPE)

IS
  l_unit_effectivity_id NUMBER;
  l_rowid               VARCHAR2(30);

BEGIN

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.Debug('Start Create Record');
     AHL_DEBUG_PUB.Debug('CSI:MR:' || p_x_temp_mr_rec.csi_item_instance_id || ',' || p_x_temp_mr_rec.MR_header_id);
  END IF;

  -- Default object type and application usage values.

  AHL_UNIT_EFFECTIVITIES_PKG.Insert_Row (
     X_ROWID               =>  l_rowid,
     X_UNIT_EFFECTIVITY_ID =>   l_unit_effectivity_id,
     X_CSI_ITEM_INSTANCE_ID  => p_x_temp_mr_rec.csi_item_instance_id,
     X_MR_INTERVAL_ID        => p_x_temp_mr_rec.mr_interval_id,
     X_MR_EFFECTIVITY_ID     => p_x_temp_mr_rec.mr_effectivity_id,
     X_MR_HEADER_ID          => p_x_temp_mr_rec.MR_header_id,
     X_STATUS_CODE           => null, /* status_code */
     X_DUE_DATE              => p_x_temp_mr_rec.due_date,
     X_DUE_COUNTER_VALUE     => p_x_temp_mr_rec.due_counter_value,
     X_FORECAST_SEQUENCE     => p_x_temp_mr_rec.forecast_sequence,
     X_REPETITIVE_MR_FLAG    => p_x_temp_mr_rec.repetitive_mr_flag,
     X_TOLERANCE_FLAG        => p_x_temp_mr_rec.tolerance_flag,
     X_REMARKS               => null, /* remarks */
     X_MESSAGE_CODE          => p_x_temp_mr_rec.message_code,
     X_PRECEDING_UE_ID       => null, /* p_x_temp_mr_rec.preceding_ue_id */
     X_DATE_RUN              => sysdate, /* date_run */
     X_SET_DUE_DATE          => null, /* set due date */
     X_ACCOMPLISHED_DATE     => null, /* accomplished date */
     X_SERVICE_LINE_ID       => p_x_temp_mr_rec.service_line_id,
     X_PROGRAM_MR_HEADER_ID  => p_x_temp_mr_rec.program_mr_header_id,
     X_CANCEL_REASON_CODE    => null, /* cancel_reason_code */
     X_EARLIEST_DUE_DATE     => p_x_temp_mr_rec.earliest_due_date,
     X_LATEST_DUE_DATE       => p_x_temp_mr_rec.latest_due_date,
     X_defer_from_ue_id      => null,
     X_cs_incident_id        => null,
     X_qa_collection_id      => null,
     X_orig_deferral_ue_id   => null,
     X_application_usg_code  => G_APPLN_USAGE_CODE,
     X_object_type           => 'MR',
     X_counter_id            => p_x_temp_mr_rec.counter_id,
     X_MANUALLY_PLANNED_FLAG => 'N',
     X_LOG_SERIES_CODE       => NULL,
     X_LOG_SERIES_NUMBER     => NULL,
     X_FLIGHT_NUMBER         => NULL,
     X_MEL_CDL_TYPE_CODE     => NULL,
     X_POSITION_PATH_ID      => NULL,
     X_ATA_CODE              => NULL,
     X_UNIT_CONFIG_HEADER_ID  => NULL,
     X_ATTRIBUTE_CATEGORY    => null, /* ATTRIBUTE_CATEGORY */
     X_ATTRIBUTE1            => null, /* ATTRIBUTE1 */
     X_ATTRIBUTE2            => null, /* ATTRIBUTE2 */
     X_ATTRIBUTE3            => null, /* ATTRIBUTE3 */
     X_ATTRIBUTE4            => null, /* ATTRIBUTE4 */
     X_ATTRIBUTE5            => null, /* ATTRIBUTE5 */
     X_ATTRIBUTE6            => null, /* ATTRIBUTE6 */
     X_ATTRIBUTE7            => null, /* ATTRIBUTE7 */
     X_ATTRIBUTE8            => null, /* ATTRIBUTE8 */
     X_ATTRIBUTE9            => null, /* ATTRIBUTE9 */
     X_ATTRIBUTE10           => null, /* ATTRIBUTE10 */
     X_ATTRIBUTE11           => null, /* ATTRIBUTE11 */
     X_ATTRIBUTE12           => null, /* ATTRIBUTE12 */
     X_ATTRIBUTE13           => null, /* ATTRIBUTE13 */
     X_ATTRIBUTE14           => null, /* ATTRIBUTE14 */
     X_ATTRIBUTE15           => null, /* ATTRIBUTE15 */
     X_OBJECT_VERSION_NUMBER => 1, /* object version */
     X_CREATION_DATE         => sysdate,
     X_CREATED_BY            => fnd_global.user_id,
     X_LAST_UPDATE_DATE      => sysdate,
     X_LAST_UPDATED_BY       => fnd_global.user_id,
     X_LAST_UPDATE_LOGIN     => fnd_global.login_id );

     p_x_temp_mr_rec.unit_effectivity_id := l_unit_effectivity_id;

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.Debug('End Create Record');
  END IF;


EXCEPTION
     -- If any error occurs, then, abort API.
  WHEN NO_DATA_FOUND THEN
    FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
    FND_MSG_PUB.ADD;
    RAISE  FND_API.G_EXC_ERROR;

END create_record;


-----------------------------------------------------------------------------
-- To update ahl_unit_effectivities record.

PROCEDURE update_record (p_temp_mr_rec IN ahl_temp_unit_effectivities%ROWTYPE,
                         p_mr_rec IN ahl_unit_effectivities_app_v%ROWTYPE)
IS

BEGIN

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.Debug('Start Update Record-' || p_mr_rec.unit_effectivity_id);
     AHL_DEBUG_PUB.Debug('CSI:MR:' || p_mr_rec.csi_item_instance_id || ',' || p_mr_rec.MR_header_id);
  END IF;

  AHL_UNIT_EFFECTIVITIES_PKG.Update_Row (
            X_UNIT_EFFECTIVITY_ID   => p_mr_rec.unit_effectivity_id,
            X_CSI_ITEM_INSTANCE_ID  => p_mr_rec.csi_item_instance_id,
            X_MR_INTERVAL_ID        => p_temp_mr_rec.mr_interval_id,
            X_MR_EFFECTIVITY_ID     => p_temp_mr_rec.mr_effectivity_id,
            X_MR_HEADER_ID          => p_mr_rec.MR_header_id,
            X_STATUS_CODE           => p_mr_rec.status_code,
            X_DUE_DATE              => p_temp_mr_rec.due_date,
            X_DUE_COUNTER_VALUE     => p_temp_mr_rec.due_counter_value,
            X_FORECAST_SEQUENCE     => p_temp_mr_rec.forecast_sequence,
            X_REPETITIVE_MR_FLAG    => p_temp_mr_rec.repetitive_mr_flag,
            X_TOLERANCE_FLAG        => p_temp_mr_rec.tolerance_flag,
            X_REMARKS               => p_mr_rec.remarks,
            X_MESSAGE_CODE          => p_temp_mr_rec.message_code,
            X_PRECEDING_UE_ID       => null, /* preceding_ue_id */
            X_DATE_RUN              => sysdate, /* date run */
            X_SET_DUE_DATE          => p_mr_rec.set_due_date,
            X_ACCOMPLISHED_DATE     => p_mr_rec.accomplished_date,
            X_SERVICE_LINE_ID       => p_temp_mr_rec.service_line_id,
            X_PROGRAM_MR_HEADER_ID  => p_temp_mr_rec.program_mr_header_id,
            X_CANCEL_REASON_CODE    => p_mr_rec.cancel_reason_code,
            X_EARLIEST_DUE_DATE     => p_temp_mr_rec.earliest_due_date,
            X_LATEST_DUE_DATE       => p_temp_mr_rec.latest_due_date,
            X_defer_from_ue_id      => p_mr_rec.defer_from_ue_id,
            X_cs_incident_id        => p_mr_rec.cs_incident_id,
            X_qa_collection_id      => p_mr_rec.qa_collection_id,
            X_orig_deferral_ue_id   => p_mr_rec.orig_deferral_ue_id,
            X_application_usg_code  => p_mr_rec.application_usg_code,
            X_object_type           => p_mr_rec.object_type,
            X_counter_id            => p_temp_mr_rec.counter_id,
            X_MANUALLY_PLANNED_FLAG => p_mr_rec.MANUALLY_PLANNED_FLAG,
            X_LOG_SERIES_CODE       => p_mr_rec.log_series_code,
            X_LOG_SERIES_NUMBER     => p_mr_rec.log_series_number,
            X_FLIGHT_NUMBER         => p_mr_rec.flight_number,
            X_MEL_CDL_TYPE_CODE     => p_mr_rec.mel_cdl_type_code,
            X_POSITION_PATH_ID      => p_mr_rec.position_path_id,
            X_ATA_CODE              => p_mr_rec.ATA_CODE,
            X_UNIT_CONFIG_HEADER_ID  => p_mr_rec.unit_config_header_id,
            X_ATTRIBUTE_CATEGORY    => p_mr_rec.ATTRIBUTE_CATEGORY,
            X_ATTRIBUTE1            => p_mr_rec.ATTRIBUTE1,
            X_ATTRIBUTE2            => p_mr_rec.ATTRIBUTE2,
            X_ATTRIBUTE3            => p_mr_rec.ATTRIBUTE3,
            X_ATTRIBUTE4            => p_mr_rec.ATTRIBUTE4,
            X_ATTRIBUTE5            => p_mr_rec.ATTRIBUTE5,
            X_ATTRIBUTE6            => p_mr_rec.ATTRIBUTE6,
            X_ATTRIBUTE7            => p_mr_rec.ATTRIBUTE7,
            X_ATTRIBUTE8            => p_mr_rec.ATTRIBUTE8,
            X_ATTRIBUTE9            => p_mr_rec.ATTRIBUTE9,
            X_ATTRIBUTE10           => p_mr_rec.ATTRIBUTE10,
            X_ATTRIBUTE11           => p_mr_rec.ATTRIBUTE11,
            X_ATTRIBUTE12           => p_mr_rec.ATTRIBUTE12,
            X_ATTRIBUTE13           => p_mr_rec.ATTRIBUTE13,
            X_ATTRIBUTE14           => p_mr_rec.ATTRIBUTE14,
            X_ATTRIBUTE15           => p_mr_rec.ATTRIBUTE15,
            X_OBJECT_VERSION_NUMBER => p_mr_rec.object_version_number+1,
            X_LAST_UPDATE_DATE      => sysdate,
            X_LAST_UPDATED_BY => fnd_global.user_id,
            X_LAST_UPDATE_LOGIN  => fnd_global.login_id );

  IF (p_temp_mr_rec.due_date IS NULL AND p_mr_rec.object_type = 'MR') THEN
     -- Delete the corresponding rows in ahl_schedule materials for this ue.
     Delete_Sch_Materials(p_mr_rec.unit_effectivity_id);
  END IF;

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.Debug('End Update Record');
  END IF;

EXCEPTION
     -- If any error occurs, then, abort API.
  WHEN NO_DATA_FOUND THEN
    FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
    FND_MSG_PUB.ADD;
    RAISE  FND_API.G_EXC_ERROR;

END update_record;


-----------------------------------------------------------------------------
-- To create decendent records and build relationships if the MR is a group MR.

PROCEDURE create_group (p_x_temp_grp_rec IN OUT NOCOPY ahl_temp_unit_effectivities%ROWTYPE)

IS
  -- Read group elements.
  CURSOR ahl_temp_grp_csr(p_csi_item_instance_id IN NUMBER,
                          p_mr_header_id IN NUMBER,
                          p_forecast_sequence IN NUMBER) IS
    SELECT  unit_effectivity_id,
            csi_item_instance_id,
            MR_header_id,
            due_date,
            mr_interval_id,
            mr_effectivity_id,
            due_counter_value,
            parent_csi_item_instance_id,
            parent_mr_header_id,
            orig_csi_item_instance_id,
            orig_mr_header_id,
            forecast_sequence,
            repetitive_mr_flag,
            tolerance_flag,
            message_code,
            earliest_due_date,
            latest_due_date,
            counter_id
    FROM ahl_temp_unit_effectivities
    START WITH parent_csi_item_instance_id = p_csi_item_instance_id
          AND parent_mr_header_id = p_mr_header_id
          AND orig_csi_item_instance_id = p_csi_item_instance_id
          AND orig_mr_header_id = p_mr_header_id
          AND orig_forecast_sequence = p_forecast_sequence
          AND nvl(preceding_check_flag,'N') = 'N'
    CONNECT BY PRIOR MR_header_id = parent_mr_header_id
           AND PRIOR csi_item_instance_id = parent_csi_item_instance_id
           AND orig_csi_item_instance_id = p_csi_item_instance_id
           AND orig_mr_header_id = p_mr_header_id
           AND orig_forecast_sequence = p_forecast_sequence
           AND nvl(preceding_check_flag,'N') = 'N'
    FOR UPDATE OF due_date;

  -- get parent unit effectivity id.
  CURSOR ahl_temp_parent_csr (p_parent_csi_item_instance_id IN NUMBER,
                              p_parent_mr_header_id IN NUMBER,
                              p_orig_csi_item_instance_id IN NUMBER,
                              p_orig_mr_header_id IN NUMBER,
                              p_forecast_sequence IN NUMBER) IS
    SELECT unit_effectivity_id
    FROM   ahl_temp_unit_effectivities
    WHERE  csi_item_instance_id = p_parent_csi_item_instance_id
           AND MR_header_id = p_parent_mr_header_id
           AND orig_csi_item_instance_id = p_orig_csi_item_instance_id
           AND orig_mr_header_id = p_orig_mr_header_id
           AND orig_forecast_sequence = p_forecast_sequence;

    l_ue_relationship_id   NUMBER;

    l_originator_ue_id     NUMBER;
    l_orig_csi_item_instance_id NUMBER;
    l_orig_mr_header_id NUMBER;

    l_parent_ue_id NUMBER;

    l_temp_child_rec  ahl_temp_unit_effectivities%ROWTYPE;

BEGIN

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.Debug('Start Create Group');
     AHL_DEBUG_PUB.Debug('CSI:MR:' || p_x_temp_grp_rec.csi_item_instance_id || ',' || p_x_temp_grp_rec.MR_header_id);
  END IF;

  -- For top node.
  Create_Record (p_x_temp_grp_rec);

  -- Update ahl_temp_unit_effectivities with the unit effectivity id.
  UPDATE ahl_temp_unit_effectivities
  SET unit_effectivity_id = p_x_temp_grp_rec.unit_effectivity_id
  WHERE csi_item_instance_id = p_x_temp_grp_rec.csi_item_instance_id AND
        mr_header_id = p_x_temp_grp_rec.mr_header_id AND
        forecast_sequence = p_x_temp_grp_rec.forecast_sequence;

  -- Read all elements.
  FOR l_temp_grp_rec IN ahl_temp_grp_csr(p_x_temp_grp_rec.csi_item_instance_id,
                                         p_x_temp_grp_rec.mr_header_id,
                                         p_x_temp_grp_rec.forecast_sequence)
  LOOP

    -- set record values.
    l_temp_child_rec.unit_effectivity_id := null;
    l_temp_child_rec.csi_item_instance_id := l_temp_grp_rec.csi_item_instance_id;
    l_temp_child_rec.mr_interval_id := l_temp_grp_rec.mr_interval_id;
    l_temp_child_rec.mr_effectivity_id := l_temp_grp_rec.mr_effectivity_id;
    l_temp_child_rec.MR_header_id := l_temp_grp_rec.mr_header_id;
    l_temp_child_rec.due_date := l_temp_grp_rec.due_date;
    l_temp_child_rec.due_counter_value := l_temp_grp_rec.due_counter_value;
    l_temp_child_rec.forecast_sequence := l_temp_grp_rec.forecast_sequence;
    l_temp_child_rec.repetitive_mr_flag := l_temp_grp_rec.repetitive_mr_flag;
    l_temp_child_rec.tolerance_flag := l_temp_grp_rec.tolerance_flag;
    l_temp_child_rec.message_code := l_temp_grp_rec.message_code;
    l_temp_child_rec.earliest_due_date := l_temp_grp_rec.earliest_due_date;
    l_temp_child_rec.latest_due_date := l_temp_grp_rec.latest_due_date;
    l_temp_child_rec.counter_id := l_temp_grp_rec.counter_id;

    -- Insert into ahl_unit_effectivities.
    Create_Record (l_temp_child_rec);

    -- Update ahl_temp_unit_effectivities with the unit effectivity id.
    UPDATE ahl_temp_unit_effectivities
    SET unit_effectivity_id = l_temp_child_rec.unit_effectivity_id
    WHERE CURRENT OF ahl_temp_grp_csr;

    --dbms_output.put_line ('generated unit effectivity id' || l_unit_effectivity_id);

  END LOOP;

  -- Read from the top group node and build relationships by inserting
  -- into the relationships table.

  l_originator_ue_id := p_x_temp_grp_rec.unit_effectivity_id;
  l_orig_csi_item_instance_id := p_x_temp_grp_rec.csi_item_instance_id;
  l_orig_mr_header_id := p_x_temp_grp_rec.mr_header_id;

  --dbms_output.put_line ('before relationships built');

  FOR l_temp_grp_rec IN ahl_temp_grp_csr(p_x_temp_grp_rec.csi_item_instance_id,
                                         p_x_temp_grp_rec.mr_header_id,
                                         p_x_temp_grp_rec.forecast_sequence)
  LOOP

     OPEN ahl_temp_parent_csr(l_temp_grp_rec.parent_csi_item_instance_id,
                              l_temp_grp_rec.parent_mr_header_id,
                              l_orig_csi_item_instance_id,
                              l_orig_mr_header_id,
                              p_x_temp_grp_rec.forecast_sequence);
     FETCH ahl_temp_parent_csr INTO l_parent_ue_id;
     IF (ahl_temp_parent_csr%NOTFOUND) THEN
        FND_MESSAGE.Set_Name ('AHL','AHL_UMP_PUE_PARENT_NOTFOUND');
        FND_MESSAGE.Set_Token ('INST_ID',l_temp_grp_rec.csi_item_instance_id);
        FND_MESSAGE.Set_Token ('MR_ID',l_temp_grp_rec.mr_header_id);
        FND_MSG_PUB.ADD;
        CLOSE ahl_temp_parent_csr;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
     CLOSE ahl_temp_parent_csr;

     -- Insert into ahl_ue_relationships.
     AHL_UE_RELATIONSHIPS_PKG.Insert_Row(
            X_UE_RELATIONSHIP_ID => l_ue_relationship_id,
            X_UE_ID  => l_parent_ue_id,
            X_RELATED_UE_ID => l_temp_grp_rec.unit_effectivity_id,
            X_RELATIONSHIP_CODE => 'PARENT',
            X_ORIGINATOR_UE_ID => l_originator_ue_id,
            X_ATTRIBUTE_CATEGORY => null, /* ATTRIBUTE_CATEGORY */
            X_ATTRIBUTE1 => null, /* ATTRIBUTE1 */
            X_ATTRIBUTE2 => null, /* ATTRIBUTE2 */
            X_ATTRIBUTE3 => null, /* ATTRIBUTE3 */
            X_ATTRIBUTE4 => null, /* ATTRIBUTE4 */
            X_ATTRIBUTE5 => null, /* ATTRIBUTE5 */
            X_ATTRIBUTE6 => null, /* ATTRIBUTE6 */
            X_ATTRIBUTE7 => null, /* ATTRIBUTE7 */
            X_ATTRIBUTE8 => null, /* ATTRIBUTE8 */
            X_ATTRIBUTE9 => null, /* ATTRIBUTE9 */
            X_ATTRIBUTE10 => null, /* ATTRIBUTE10 */
            X_ATTRIBUTE11 => null, /* ATTRIBUTE11 */
            X_ATTRIBUTE12 => null, /* ATTRIBUTE12 */
            X_ATTRIBUTE13 => null, /* ATTRIBUTE13 */
            X_ATTRIBUTE14 => null, /* ATTRIBUTE14 */
            X_ATTRIBUTE15 => null, /* ATTRIBUTE15 */
            X_OBJECT_VERSION_NUMBER => 1,
            X_LAST_UPDATE_DATE => sysdate,
            X_LAST_UPDATED_BY  => fnd_global.user_id,
            X_CREATION_DATE => sysdate,
            X_CREATED_BY  => fnd_global.user_id,
            X_LAST_UPDATE_LOGIN => fnd_global.login_id);

  END LOOP;

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.Debug('End Create Group');
  END IF;

EXCEPTION
     -- If any error occurs, then, abort API.
  WHEN NO_DATA_FOUND THEN
    FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
    FND_MSG_PUB.ADD;
    RAISE  FND_API.G_EXC_ERROR;

END create_group;

--------------------------------------------------------------------------------
-- To update decendent records and update relationships if the MR is a group MR.

PROCEDURE update_group (p_temp_mr_rec IN ahl_temp_unit_effectivities%ROWTYPE,
                        p_mr_rec IN ahl_unit_effectivities_app_v%ROWTYPE)
IS

  -- Read group elements.
  CURSOR ahl_temp_grp_csr(p_csi_item_instance_id IN NUMBER,
                          p_mr_header_id IN NUMBER,
                          p_forecast_sequence IN NUMBER,
                          p_level IN NUMBER) IS
    SELECT  csi_item_instance_id,
            MR_header_id,
            parent_csi_item_instance_id,
            parent_mr_header_id,
            orig_csi_item_instance_id,
            orig_mr_header_id,
            forecast_sequence
    FROM ahl_temp_unit_effectivities
    WHERE level = p_level
    START WITH parent_csi_item_instance_id = p_csi_item_instance_id
          AND parent_mr_header_id = p_mr_header_id
          AND orig_csi_item_instance_id = p_csi_item_instance_id
          AND orig_mr_header_id = p_mr_header_id
          AND orig_forecast_sequence = p_forecast_sequence
          AND nvl(preceding_check_flag,'N') = 'N'
    CONNECT BY PRIOR MR_header_id = parent_mr_header_id
          AND PRIOR csi_item_instance_id = parent_csi_item_instance_id
          AND orig_csi_item_instance_id = p_csi_item_instance_id
          AND orig_mr_header_id = p_mr_header_id
          AND orig_forecast_sequence = p_forecast_sequence
          AND nvl(preceding_check_flag,'N') = 'N';

  -- Read group elements from ue relationships.
  CURSOR ahl_ue_reln_csr(p_unit_effectivity_id IN NUMBER,
                         p_level IN NUMBER) IS
    SELECT  UE_ID parent_ue_id,
            RELATED_UE_ID ue_id
    FROM ahl_ue_relationships
    WHERE level = p_level
    START WITH ue_id = p_unit_effectivity_id AND
               relationship_code = 'PARENT'
    CONNECT BY PRIOR related_ue_id = ue_id AND
                     relationship_code = 'PARENT';

  -- get related unit effectivities details.
  CURSOR ahl_ue_grp_csr ( p_ue_id IN NUMBER,
                          p_parent_ue_id IN NUMBER ) IS
    SELECT ue1.mr_header_id, ue1.csi_item_instance_id, ue1.unit_effectivity_id,
           ue2.mr_header_id parent_mr_header_id,
           ue2.csi_item_instance_id parent_csi_item_instance_id
    --FROM ahl_unit_effectivities_app_v ue1, ahl_unit_effectivities_app_v ue2
    FROM ahl_unit_effectivities_b ue1, ahl_unit_effectivities_b ue2
    WHERE ue1.unit_effectivity_id = p_ue_id AND
          ue2.unit_effectivity_id = p_parent_ue_id;

  -- Cursor to get all details of a unit effectivity record.
  CURSOR ahl_unit_effectivity_csr ( p_unit_effectivity_id IN NUMBER) IS
     SELECT
        UNIT_EFFECTIVITY_ID ,
        CSI_ITEM_INSTANCE_ID,
        MR_INTERVAL_ID,
        MR_EFFECTIVITY_ID ,
        MR_HEADER_ID,
        STATUS_CODE ,
        DUE_DATE   ,
        DUE_COUNTER_VALUE ,
        FORECAST_SEQUENCE ,
        --REPETITIVE_MR_FLAG ,
        TOLERANCE_FLAG ,
        REMARKS ,
        MESSAGE_CODE ,
        PRECEDING_UE_ID ,
        DATE_RUN ,
        SET_DUE_DATE ,
        ACCOMPLISHED_DATE ,
        CANCEL_REASON_CODE,
        --EARLIEST_DUE_DATE,
        --LATEST_DUE_DATE,
        defer_from_ue_id,
        cs_incident_id,
        qa_collection_id,
        orig_deferral_ue_id,
        application_usg_code,
        object_type,
        --counter_id,
        ATTRIBUTE_CATEGORY ,
        ATTRIBUTE1,
        ATTRIBUTE2 ,
        ATTRIBUTE3 ,
        ATTRIBUTE4 ,
        ATTRIBUTE5 ,
        ATTRIBUTE6 ,
        ATTRIBUTE7 ,
        ATTRIBUTE8 ,
        ATTRIBUTE9 ,
        ATTRIBUTE10,
        ATTRIBUTE11 ,
        ATTRIBUTE12 ,
        ATTRIBUTE13 ,
        ATTRIBUTE14 ,
        ATTRIBUTE15 ,
        OBJECT_VERSION_NUMBER
     --FROM ahl_unit_effectivities_app_v
     FROM ahl_unit_effectivities_vl
     WHERE unit_effectivity_id = p_unit_effectivity_id;
     --FOR UPDATE OF due_date NOWAIT;

  TYPE temp_grp_rec_type IS RECORD (
            csi_item_instance_id NUMBER,
            MR_header_id NUMBER,
            parent_csi_item_instance_id NUMBER,
            parent_mr_header_id NUMBER,
            orig_csi_item_instance_id NUMBER,
            orig_mr_header_id NUMBER,
            forecast_sequence NUMBER );


  TYPE temp_grp_tbl_type IS TABLE OF temp_grp_rec_type INDEX BY BINARY_INTEGER;

  l_temp_grp_rec  temp_grp_rec_type;
  l_temp_grp_tbl  temp_grp_tbl_type;


  TYPE ue_grp_rec_type IS RECORD (
            mr_header_id NUMBER,
            csi_item_instance_id NUMBER,
            unit_effectivity_id NUMBER,
            parent_mr_header_id NUMBER,
            parent_csi_item_instance_id NUMBER);

  TYPE ue_grp_tbl_type IS TABLE OF ue_grp_rec_type INDEX BY BINARY_INTEGER;

  l_ue_grp_tbl ue_grp_tbl_type;
  l_ue_grp_rec ue_grp_rec_type;

  l_level NUMBER;
  l_grp_match_found  BOOLEAN;
  l_temp_grp_found   BOOLEAN;
  l_ue_grp_found     BOOLEAN;

  i  NUMBER;
  l_grp_match_flag  BOOLEAN;

  l_temp_mr_rec ahl_temp_unit_effectivities%ROWTYPE := p_temp_mr_rec;
  l_unit_effectivity_rec  ahl_unit_effectivities_app_v%ROWTYPE;

  -- added for bug# 7586838
  CURSOR unit_deferral_csr(p_ue_id IN NUMBER) IS
    SELECT unit_deferral_id
    FROM ahl_unit_deferrals_b
    WHERE UNIT_EFFECTIVITY_ID = p_ue_id
      AND UNIT_DEFERRAL_TYPE = 'INIT-DUE';

  l_unit_deferral_id   NUMBER;
  l_visit_status       ahl_visits_b.status_code%TYPE;

BEGIN

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.Debug('Start Update Group');
     AHL_DEBUG_PUB.Debug('CSI:MR:' || p_mr_rec.csi_item_instance_id || ',' || p_mr_rec.MR_header_id);
  END IF;

  -- Set savepoint.
  SAVEPOINT update_group;

  l_visit_status := AHL_UMP_UTIL_PKG.get_visit_status (p_temp_mr_rec.unit_effectivity_id);

  IF (l_visit_status IN ('RELEASED','CLOSED')) THEN
     l_grp_match_found := TRUE; -- ignore matching group as UE on shop floor.
     -- update existing UE children.
     UPDATE AHL_UNIT_EFFECTIVITIES_B
        SET mr_interval_id        = p_temp_mr_rec.mr_interval_id,
            mr_effectivity_id     = p_temp_mr_rec.mr_effectivity_id,
            due_date              = p_temp_mr_rec.due_date,
            due_counter_value     = p_temp_mr_rec.due_counter_value,
            forecast_sequence     = p_temp_mr_rec.forecast_sequence,
            repetitive_mr_flag    = p_temp_mr_rec.repetitive_mr_flag,
            tolerance_flag        = p_temp_mr_rec.tolerance_flag,
            message_code          = p_temp_mr_rec.message_code,
            date_run              = sysdate,
            earliest_due_date     = p_temp_mr_rec.earliest_due_date,
            latest_due_date       = p_temp_mr_rec.latest_due_date,
            counter_id            = p_temp_mr_rec.counter_id,
            object_version_number = object_version_number+1,
            LAST_UPDATE_DATE      = sysdate,
            LAST_UPDATED_BY       = fnd_global.user_id,
            LAST_UPDATE_LOGIN     = fnd_global.login_id
      WHERE unit_effectivity_id IN (SELECT related_ue_id
                                    FROM  ahl_ue_relationships
                                    WHERE originator_ue_id = p_temp_mr_rec.unit_effectivity_id
                                      AND relationship_code = 'PARENT');

  ELSE
     -- For each tree level compare and update the effectivity details.
     l_level := 0;
     l_grp_match_found := TRUE;
     l_temp_grp_found := TRUE; /* temp group record found */
     l_ue_grp_found := TRUE; /* ue grp found */


     WHILE ((l_temp_grp_found) AND (l_ue_grp_found) AND (l_grp_match_found)) LOOP

       l_level := l_level + 1;

       -- initialize tables.
       l_temp_grp_tbl.DELETE;
       l_ue_grp_tbl.DELETE;

       -- Build table from temp unit effectivities.
       i := 1;
       FOR temp_rec IN ahl_temp_grp_csr(p_temp_mr_rec.orig_csi_item_instance_id,
                                        p_temp_mr_rec.orig_mr_header_id,
                                        p_temp_mr_rec.forecast_sequence,
                                        l_level)
       LOOP
         l_temp_grp_tbl(i) := temp_rec;
         i := i + 1;
       END LOOP;

       -- Build table from unit effectivities.
       i := 1;
       FOR reln_rec IN ahl_ue_reln_csr (p_temp_mr_rec.unit_effectivity_id,
                                        l_level)
       LOOP
         OPEN ahl_ue_grp_csr(reln_rec.ue_id,
                             reln_rec.parent_ue_id);
         FETCH ahl_ue_grp_csr INTO l_ue_grp_rec;
         IF ahl_ue_grp_csr%NOTFOUND THEN
            FND_Message.Set_Name ('AHL','AHL_UMP_PUE_RELN_NOTFOUND');
            FND_Message.set_token ('UE_ID',reln_rec.parent_ue_id);
            FND_Message.set_token ('RELATED_UE_ID',reln_rec.ue_id);
            FND_MSG_PUB.ADD;
            CLOSE ahl_ue_grp_csr;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
         CLOSE ahl_ue_grp_csr;
         l_ue_grp_tbl(i) := l_ue_grp_rec;
         i := i + 1;
       END LOOP;

       IF (l_temp_grp_tbl.COUNT > 0) THEN
         l_temp_grp_found := TRUE;
       ELSE
         l_temp_grp_found := FALSE;
       END IF;

       IF (l_ue_grp_tbl.COUNT > 0) THEN
         l_ue_grp_found := TRUE;
       ELSE
         l_ue_grp_found := FALSE;
       END IF;

       l_grp_match_flag := TRUE;

       -- match table count.
       IF (l_temp_grp_found) THEN
         IF (l_ue_grp_found) THEN
           IF (l_temp_grp_tbl.COUNT <> l_ue_grp_tbl.COUNT) THEN
               l_grp_match_flag := FALSE;
           END IF;
         ELSE
           l_grp_match_flag := FALSE;
         END IF;
       ELSE
         IF (l_ue_grp_found) THEN
           l_grp_match_flag := FALSE;
         END IF;
       END IF;

       -- update.
       IF ((l_grp_match_flag) AND (l_ue_grp_found) AND (l_temp_grp_found)) THEN
         -- update.
         FOR i IN l_temp_grp_tbl.FIRST..l_temp_grp_tbl.LAST LOOP
           -- Find the matching entry in l_ue_grp_tbl.
           l_grp_match_flag := FALSE; -- this will be set to true when  record gets updated.
           FOR j IN l_ue_grp_tbl.FIRST..l_ue_grp_tbl.LAST LOOP
             IF (l_ue_grp_tbl(j).csi_item_instance_id = l_temp_grp_tbl(i).csi_item_instance_id
                 AND l_ue_grp_tbl(j).mr_header_id = l_temp_grp_tbl(i).mr_header_id
                 AND l_ue_grp_tbl(j).parent_csi_item_instance_id = l_temp_grp_tbl(i).parent_csi_item_instance_id
                 AND l_ue_grp_tbl(j).parent_mr_header_id = l_temp_grp_tbl(i).parent_mr_header_id)
             THEN
               --dbms_output.put_line ('matched');

               -- Read Unit Effectivity record.
               OPEN ahl_unit_effectivity_csr(l_ue_grp_tbl(j).unit_effectivity_id);
               FETCH ahl_unit_effectivity_csr INTO l_unit_effectivity_rec.UNIT_EFFECTIVITY_ID ,
                                                   l_unit_effectivity_rec.CSI_ITEM_INSTANCE_ID,
                                                   l_unit_effectivity_rec.MR_INTERVAL_ID,
                                                   l_unit_effectivity_rec.MR_EFFECTIVITY_ID ,
                                                   l_unit_effectivity_rec.MR_HEADER_ID,
                                                   l_unit_effectivity_rec.STATUS_CODE ,
                                                   l_unit_effectivity_rec.DUE_DATE   ,
                                                   l_unit_effectivity_rec.DUE_COUNTER_VALUE ,
                                                   l_unit_effectivity_rec.FORECAST_SEQUENCE ,
                                                   --l_unit_effectivity_rec.REPETITIVE_MR_FLAG ,
                                                   l_unit_effectivity_rec.TOLERANCE_FLAG ,
                                                   l_unit_effectivity_rec.REMARKS ,
                                                   l_unit_effectivity_rec.MESSAGE_CODE ,
                                                   l_unit_effectivity_rec.PRECEDING_UE_ID ,
                                                   l_unit_effectivity_rec.DATE_RUN ,
                                                   l_unit_effectivity_rec.SET_DUE_DATE ,
                                                   l_unit_effectivity_rec.ACCOMPLISHED_DATE ,
                                                   l_unit_effectivity_rec.CANCEL_REASON_CODE,
                                                   --l_unit_effectivity_rec.earliest_due_date,
                                                   --l_unit_effectivity_rec.latest_due_date,
                                                   l_unit_effectivity_rec.defer_from_ue_id,
                                                   l_unit_effectivity_rec.cs_incident_id,
                                                   l_unit_effectivity_rec.qa_collection_id,
                                                   l_unit_effectivity_rec.orig_deferral_ue_id,
                                                   l_unit_effectivity_rec.application_usg_code,
                                                   l_unit_effectivity_rec.object_type,
                                                   --l_ue_rec.counter_id,
                                                   l_unit_effectivity_rec.ATTRIBUTE_CATEGORY ,
                                                   l_unit_effectivity_rec.ATTRIBUTE1,
                                                   l_unit_effectivity_rec.ATTRIBUTE2 ,
                                                   l_unit_effectivity_rec.ATTRIBUTE3 ,
                                                   l_unit_effectivity_rec.ATTRIBUTE4 ,
                                                   l_unit_effectivity_rec.ATTRIBUTE5 ,
                                                   l_unit_effectivity_rec.ATTRIBUTE6 ,
                                                   l_unit_effectivity_rec.ATTRIBUTE7 ,
                                                   l_unit_effectivity_rec.ATTRIBUTE8 ,
                                                   l_unit_effectivity_rec.ATTRIBUTE9 ,
                                                   l_unit_effectivity_rec.ATTRIBUTE10,
                                                   l_unit_effectivity_rec.ATTRIBUTE11 ,
                                                   l_unit_effectivity_rec.ATTRIBUTE12 ,
                                                   l_unit_effectivity_rec.ATTRIBUTE13 ,
                                                   l_unit_effectivity_rec.ATTRIBUTE14 ,
                                                   l_unit_effectivity_rec.ATTRIBUTE15 ,
                                                   l_unit_effectivity_rec.OBJECT_VERSION_NUMBER;

               IF (ahl_unit_effectivity_csr%NOTFOUND) THEN
                  FND_Message.Set_Name ('AHL','AHL_UMP_PUE_UE_NOTFOUND');
                  FND_Message.set_token ('UE_ID',l_ue_grp_tbl(j).csi_item_instance_id);
                  FND_MSG_PUB.ADD;
                  CLOSE ahl_unit_effectivity_csr;
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               ELSE

                 update_record (p_temp_mr_rec, l_unit_effectivity_rec);
                 l_grp_match_flag := TRUE;  -- matched record.
                 CLOSE ahl_unit_effectivity_csr;
                 EXIT;
               END IF;

             END IF;
           END LOOP; -- for j (ue)
           IF (l_grp_match_flag = FALSE) THEN
              EXIT;
           END IF;
         END LOOP;  -- for i (temp)
       END IF;

       l_grp_match_found := l_grp_match_flag;

     END LOOP; /* while */

  END IF; -- l_visit_status

  IF NOT(l_grp_match_found) THEN
     --rollback to save point
     ROLLBACK to update_group;

     create_group (p_x_temp_grp_rec => l_temp_mr_rec);
     -- fix for bug# 7586838.
     IF (p_mr_rec.status_code = 'INIT-DUE') THEN
        -- update ahl_unit_deferrals_b.
        OPEN unit_deferral_csr(p_mr_rec.unit_effectivity_id);
        FETCH unit_deferral_csr INTO l_unit_deferral_id;
        IF (unit_deferral_csr%FOUND) THEN
            UPDATE ahl_unit_deferrals_b
            SET UNIT_EFFECTIVITY_ID = l_temp_mr_rec.unit_effectivity_id,
                last_update_date = sysdate,
                object_version_number = object_version_number + 1,
                LAST_UPDATED_BY = fnd_global.user_id,
                LAST_UPDATE_LOGIN = fnd_global.login_id
            WHERE unit_deferral_id = l_unit_deferral_id;
        END IF;
        CLOSE unit_deferral_csr;

        -- update unit effectivity status on top node.
        UPDATE ahl_unit_effectivities_b
        SET status_code = 'INIT-DUE'
        WHERE unit_effectivity_id = l_temp_mr_rec.unit_effectivity_id;

     END IF;
  ELSE
     -- Update top group node with p_mr_rec.unit_effectivity_id.
     update_record (p_temp_mr_rec,
                    p_mr_rec);

  END IF;

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.Debug('End Update Group');
  END IF;


EXCEPTION
     -- If any error occurs, then, abort API.
  WHEN NO_DATA_FOUND THEN
    FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
    FND_MSG_PUB.ADD;
    RAISE  FND_API.G_EXC_ERROR;

END update_group;
----------------------------------------------------------------------
-- To update unit effectivities for Deferrals and Service Request UEs.

PROCEDURE Flush_Unit_SR_Deferrals IS

  -- read all top group MRs from the temporary table.
  CURSOR ahl_unit_sr_def_csr IS
    SELECT
        unit_effectivity_id,
        object_type,
        csi_item_instance_id,
        mr_header_id,
        due_date,
        due_counter_value,
        tolerance_flag,
        message_code,
        parent_csi_item_instance_id,
        parent_mr_header_id,
        orig_csi_item_instance_id,
        orig_mr_header_id,
        orig_unit_effectivity_id,
        group_match_flag,
        counter_id
    FROM ahl_temp_unit_SR_deferrals
    WHERE orig_unit_effectivity_id IS NULL
    FOR UPDATE OF unit_effectivity_id;

  -- Read group from ahl_ue_relationships.
  CURSOR ahl_ue_csr (p_orig_ue_id IN NUMBER) IS
    SELECT related_ue_id
    FROM ahl_ue_relationships
    WHERE originator_ue_id = p_orig_ue_id
      AND relationship_code = 'PARENT';

  -- Read group elements.
  CURSOR ahl_temp_csr(p_csi_item_instance_id IN NUMBER,
                      p_mr_header_id IN NUMBER,
                      p_unit_effectivity_id IN NUMBER) IS
    SELECT  unit_effectivity_id,
            csi_item_instance_id,
            MR_header_id,
            due_date,
            due_counter_value,
            parent_csi_item_instance_id,
            parent_mr_header_id,
            orig_csi_item_instance_id,
            orig_mr_header_id,
            tolerance_flag,
            message_code
    FROM ahl_temp_unit_SR_deferrals
    START WITH parent_csi_item_instance_id = p_csi_item_instance_id
          AND parent_mr_header_id = p_mr_header_id
          AND orig_csi_item_instance_id = p_csi_item_instance_id
          AND orig_mr_header_id = p_mr_header_id
          AND orig_unit_effectivity_id = p_unit_effectivity_id
    CONNECT BY PRIOR MR_header_id = parent_mr_header_id
           AND PRIOR csi_item_instance_id = parent_csi_item_instance_id
           AND orig_csi_item_instance_id = p_csi_item_instance_id
           AND orig_mr_header_id = p_mr_header_id
           AND orig_unit_effectivity_id = p_unit_effectivity_id
     FOR UPDATE OF due_date
     ORDER BY level;


  -- get parent unit effectivity id.
  CURSOR ahl_temp_parent_csr (p_parent_csi_item_instance_id IN NUMBER,
                              p_parent_mr_header_id IN NUMBER,
                              p_orig_csi_item_instance_id IN NUMBER,
                              p_orig_mr_header_id IN NUMBER,
                              p_unit_effectivity_id NUMBER) IS
    SELECT unit_effectivity_id
    FROM   ahl_temp_unit_SR_deferrals
    WHERE  csi_item_instance_id = p_parent_csi_item_instance_id
           AND MR_header_id = p_parent_mr_header_id
           AND orig_csi_item_instance_id = p_orig_csi_item_instance_id
           AND orig_mr_header_id  = p_orig_mr_header_id
           AND orig_unit_effectivity_id = p_unit_effectivity_id;

  -- Cursor to get all details of a unit effectivity record.
  CURSOR ahl_unit_effectivity_csr ( p_unit_effectivity_id IN NUMBER) IS
     SELECT
        UNIT_EFFECTIVITY_ID ,
        CSI_ITEM_INSTANCE_ID,
        MR_INTERVAL_ID,
        MR_EFFECTIVITY_ID ,
        MR_HEADER_ID,
        STATUS_CODE ,
        DUE_DATE   ,
        DUE_COUNTER_VALUE ,
        FORECAST_SEQUENCE ,
        REPETITIVE_MR_FLAG ,
        TOLERANCE_FLAG ,
        REMARKS ,
        MESSAGE_CODE ,
        PRECEDING_UE_ID ,
        DATE_RUN ,
        SET_DUE_DATE ,
        ACCOMPLISHED_DATE ,
        CANCEL_REASON_CODE,
        EARLIEST_DUE_DATE,
        LATEST_DUE_DATE,
        SERVICE_LINE_ID,
        PROGRAM_MR_HEADER_ID,
        defer_from_ue_id,
        cs_incident_id,
        qa_collection_id,
        orig_deferral_ue_id,
        application_usg_code,
        object_type,
        counter_id,
        manually_planned_flag,
        LOG_SERIES_CODE,
        LOG_SERIES_NUMBER,
        FLIGHT_NUMBER,
        MEL_CDL_TYPE_CODE,
        POSITION_PATH_ID,
        ATA_CODE,
        UNIT_CONFIG_HEADER_ID,
        ATTRIBUTE_CATEGORY ,
        ATTRIBUTE1,
        ATTRIBUTE2 ,
        ATTRIBUTE3 ,
        ATTRIBUTE4 ,
        ATTRIBUTE5 ,
        ATTRIBUTE6 ,
        ATTRIBUTE7 ,
        ATTRIBUTE8 ,
        ATTRIBUTE9 ,
        ATTRIBUTE10,
        ATTRIBUTE11 ,
        ATTRIBUTE12 ,
        ATTRIBUTE13 ,
        ATTRIBUTE14 ,
        ATTRIBUTE15 ,
        OBJECT_VERSION_NUMBER
     FROM ahl_unit_effectivities_vl
     WHERE unit_effectivity_id = p_unit_effectivity_id;
     --FOR UPDATE OF due_date NOWAIT; -- not required as we locked the UEs before

  -- Get all mr-terminated children under the SR-UE.
  CURSOR ahl_term_mr_csr (p_sr_ue_id  IN NUMBER) IS
    SELECT unit_effectivity_id
    FROM ahl_unit_effectivities_b UE, ahl_ue_relationships UER
    WHERE UE.unit_effectivity_id = UER.related_ue_id
      AND UER.ue_id = p_sr_ue_id
      AND UE.status_code = 'MR-TERMINATE';

  l_unit_effectivity_rec      ahl_unit_effectivity_csr%ROWTYPE;
  l_unit_effectivity_id       NUMBER;
  l_top_unit_effectivity_rec  ahl_unit_effectivity_csr%ROWTYPE;
  l_parent_ue_id              NUMBER;
  l_ue_relationship_id        NUMBER;
  l_new_top_ue_id             NUMBER;
  l_rowid                     VARCHAR2(30);

  -- added for bug# 7586838
  TYPE nbr_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  l_delete_ue_id_tbl          nbr_tbl_type;
  l_index                     number := 0;

  l_visit_status              ahl_visits_b.status_code%TYPE;

BEGIN

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.Debug('Start Unit Sr Deferrals');
  END IF;

  FOR unit_sr_def_rec IN ahl_unit_sr_def_csr LOOP
     IF G_DEBUG = 'Y' THEN
        AHL_DEBUG_PUB.Debug('UE_ID:' || unit_sr_def_rec.unit_effectivity_id);
     END IF;

     IF (unit_sr_def_rec.group_match_flag = 'Y') THEN
        IF G_DEBUG = 'Y' THEN
          AHL_DEBUG_PUB.Debug('Group flag match');
        END IF;


        -- update unit effectivities with due date and tolerance info.
        -- Update top node.

            OPEN ahl_unit_effectivity_csr(unit_sr_def_rec.unit_effectivity_id);
            FETCH ahl_unit_effectivity_csr INTO l_unit_effectivity_rec;
            IF (ahl_unit_effectivity_csr%NOTFOUND) THEN
               FND_Message.Set_Name ('AHL','AHL_UMP_PUE_UE_NOTFOUND');
               FND_Message.set_token ('UE_ID',unit_sr_def_rec.unit_effectivity_id);
               FND_MSG_PUB.ADD;
               CLOSE ahl_unit_effectivity_csr;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSE
                l_unit_effectivity_rec.tolerance_flag := unit_sr_def_rec.tolerance_flag;
                l_unit_effectivity_rec.message_code   := unit_sr_def_rec.message_code;
                l_unit_effectivity_rec.due_date       := unit_sr_def_rec.due_date;
                l_unit_effectivity_rec.due_counter_value := unit_sr_def_rec.due_counter_value;
                l_unit_effectivity_rec.counter_id := unit_sr_def_rec.counter_id;

                -- update record.
                IF G_DEBUG = 'Y' THEN
                  AHL_DEBUG_PUB.Debug('Update Record-' || l_unit_effectivity_rec.unit_effectivity_id);
                  AHL_DEBUG_PUB.Debug('CSI:MR:' || l_unit_effectivity_rec.csi_item_instance_id || ',' || unit_sr_def_rec.MR_header_id);
                END IF;

                AHL_UNIT_EFFECTIVITIES_PKG.Update_Row (
                   X_UNIT_EFFECTIVITY_ID   => l_unit_effectivity_rec.unit_effectivity_id,
                   X_CSI_ITEM_INSTANCE_ID  => l_unit_effectivity_rec.csi_item_instance_id,
                   X_MR_INTERVAL_ID        => l_unit_effectivity_rec.mr_interval_id,
                   X_MR_EFFECTIVITY_ID     => l_unit_effectivity_rec.mr_effectivity_id,
                   X_MR_HEADER_ID          => l_unit_effectivity_rec.MR_header_id,
                   X_STATUS_CODE           => l_unit_effectivity_rec.status_code,
                   X_DUE_DATE              => l_unit_effectivity_rec.due_date,
                   X_DUE_COUNTER_VALUE     => l_unit_effectivity_rec.due_counter_value,
                   X_FORECAST_SEQUENCE     => l_unit_effectivity_rec.forecast_sequence,
                   X_REPETITIVE_MR_FLAG    => l_unit_effectivity_rec.repetitive_mr_flag,
                   X_TOLERANCE_FLAG        => l_unit_effectivity_rec.tolerance_flag,
                   X_REMARKS               => l_unit_effectivity_rec.remarks,
                   X_MESSAGE_CODE          => l_unit_effectivity_rec.message_code,
                   X_PRECEDING_UE_ID       => l_unit_effectivity_rec.preceding_ue_id,
                   X_DATE_RUN              => sysdate, /* date run */
                   X_SET_DUE_DATE          => l_unit_effectivity_rec.set_due_date,
                   X_ACCOMPLISHED_DATE     => l_unit_effectivity_rec.accomplished_date,
                   X_SERVICE_LINE_ID       => l_unit_effectivity_rec.service_line_id,
                   X_PROGRAM_MR_HEADER_ID  => l_unit_effectivity_rec.program_mr_header_id,
                   X_CANCEL_REASON_CODE    => l_unit_effectivity_rec.cancel_reason_code,
                   X_EARLIEST_DUE_DATE     => l_unit_effectivity_rec.earliest_due_date,
                   X_LATEST_DUE_DATE       => l_unit_effectivity_rec.latest_due_date,
                   X_defer_from_ue_id      => l_unit_effectivity_rec.defer_from_ue_id,
                   X_cs_incident_id        => l_unit_effectivity_rec.cs_incident_id,
                   X_qa_collection_id      => l_unit_effectivity_rec.qa_collection_id,
                   X_orig_deferral_ue_id   => l_unit_effectivity_rec.orig_deferral_ue_id,
                   X_application_usg_code  => l_unit_effectivity_rec.application_usg_code,
                   X_object_type           => l_unit_effectivity_rec.object_type,
                   X_counter_id            => l_unit_effectivity_rec.counter_id,
                   X_MANUALLY_PLANNED_FLAG => l_unit_effectivity_rec.MANUALLY_PLANNED_FLAG,
                   X_LOG_SERIES_CODE       => l_unit_effectivity_rec.log_series_code,
                   X_LOG_SERIES_NUMBER     => l_unit_effectivity_rec.log_series_number,
                   X_FLIGHT_NUMBER         => l_unit_effectivity_rec.flight_number,
                   X_MEL_CDL_TYPE_CODE     => l_unit_effectivity_rec.mel_cdl_type_code,
                   X_POSITION_PATH_ID      => l_unit_effectivity_rec.position_path_id,
                   X_ATA_CODE              => l_unit_effectivity_rec.ATA_CODE,
                   X_UNIT_CONFIG_HEADER_ID  => l_unit_effectivity_rec.unit_config_header_id,
                   X_ATTRIBUTE_CATEGORY    => l_unit_effectivity_rec.ATTRIBUTE_CATEGORY,
                   X_ATTRIBUTE1            => l_unit_effectivity_rec.ATTRIBUTE1,
                   X_ATTRIBUTE2            => l_unit_effectivity_rec.ATTRIBUTE2,
                   X_ATTRIBUTE3            => l_unit_effectivity_rec.ATTRIBUTE3,
                   X_ATTRIBUTE4            => l_unit_effectivity_rec.ATTRIBUTE4,
                   X_ATTRIBUTE5            => l_unit_effectivity_rec.ATTRIBUTE5,
                   X_ATTRIBUTE6            => l_unit_effectivity_rec.ATTRIBUTE6,
                   X_ATTRIBUTE7            => l_unit_effectivity_rec.ATTRIBUTE7,
                   X_ATTRIBUTE8            => l_unit_effectivity_rec.ATTRIBUTE8,
                   X_ATTRIBUTE9            => l_unit_effectivity_rec.ATTRIBUTE9,
                   X_ATTRIBUTE10           => l_unit_effectivity_rec.ATTRIBUTE10,
                   X_ATTRIBUTE11           => l_unit_effectivity_rec.ATTRIBUTE11,
                   X_ATTRIBUTE12           => l_unit_effectivity_rec.ATTRIBUTE12,
                   X_ATTRIBUTE13           => l_unit_effectivity_rec.ATTRIBUTE13,
                   X_ATTRIBUTE14           => l_unit_effectivity_rec.ATTRIBUTE14,
                   X_ATTRIBUTE15           => l_unit_effectivity_rec.ATTRIBUTE15,
                   X_OBJECT_VERSION_NUMBER => l_unit_effectivity_rec.object_version_number+1,
                   X_LAST_UPDATE_DATE      => sysdate,
                   X_LAST_UPDATED_BY => fnd_global.user_id,
                   X_LAST_UPDATE_LOGIN  => fnd_global.login_id );
                CLOSE ahl_unit_effectivity_csr;

                IF (l_unit_effectivity_rec.due_date IS NULL
                    AND l_unit_effectivity_rec.object_type = 'MR') THEN
                  -- Delete the corresponding rows in ahl_schedule materials for this ue.
                  Delete_Sch_Materials(l_unit_effectivity_rec.unit_effectivity_id);
                END IF;

                -- Update all group children.
                FOR l_ue_rec IN ahl_ue_csr (unit_sr_def_rec.unit_effectivity_id) LOOP
                   -- Read Unit Effectivity record.
                   OPEN ahl_unit_effectivity_csr(l_ue_rec.related_ue_id);
                   FETCH ahl_unit_effectivity_csr INTO l_unit_effectivity_rec;
                   IF (ahl_unit_effectivity_csr%NOTFOUND) THEN
                      FND_Message.Set_Name ('AHL','AHL_UMP_PUE_UE_NOTFOUND');
                      FND_Message.set_token ('UE_ID',l_ue_rec.related_ue_id);
                      FND_MSG_PUB.ADD;
                      CLOSE ahl_unit_effectivity_csr;
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                   ELSE
                      l_unit_effectivity_rec.tolerance_flag := unit_sr_def_rec.tolerance_flag;
                      l_unit_effectivity_rec.message_code   := unit_sr_def_rec.message_code;
                      l_unit_effectivity_rec.due_date       := unit_sr_def_rec.due_date;
                      l_unit_effectivity_rec.due_counter_value := unit_sr_def_rec.due_counter_value;

                      l_unit_effectivity_rec.counter_id := unit_sr_def_rec.counter_id;

                      -- update record.
                      IF G_DEBUG = 'Y' THEN
                         AHL_DEBUG_PUB.Debug('Update Record-' || l_unit_effectivity_rec.unit_effectivity_id);
                         AHL_DEBUG_PUB.Debug('CSI:MR:' || l_unit_effectivity_rec.csi_item_instance_id || ',' || l_unit_effectivity_rec.MR_header_id);
                      END IF;

                      AHL_UNIT_EFFECTIVITIES_PKG.Update_Row (
                           X_UNIT_EFFECTIVITY_ID   => l_unit_effectivity_rec.unit_effectivity_id,
                           X_CSI_ITEM_INSTANCE_ID  => l_unit_effectivity_rec.csi_item_instance_id,
                           X_MR_INTERVAL_ID        => l_unit_effectivity_rec.mr_interval_id,
                           X_MR_EFFECTIVITY_ID     => l_unit_effectivity_rec.mr_effectivity_id,
                           X_MR_HEADER_ID          => l_unit_effectivity_rec.MR_header_id,
                           X_STATUS_CODE           => l_unit_effectivity_rec.status_code,
                           X_DUE_DATE              => l_unit_effectivity_rec.due_date,
                           X_DUE_COUNTER_VALUE     => l_unit_effectivity_rec.due_counter_value,
                           X_FORECAST_SEQUENCE     => l_unit_effectivity_rec.forecast_sequence,
                           X_REPETITIVE_MR_FLAG    => l_unit_effectivity_rec.repetitive_mr_flag,
                           X_TOLERANCE_FLAG        => l_unit_effectivity_rec.tolerance_flag,
                           X_REMARKS               => l_unit_effectivity_rec.remarks,
                           X_MESSAGE_CODE          => l_unit_effectivity_rec.message_code,
                           X_PRECEDING_UE_ID       => l_unit_effectivity_rec.preceding_ue_id,
                           X_DATE_RUN              => sysdate, /* date run */
                           X_SET_DUE_DATE          => l_unit_effectivity_rec.set_due_date,
                           X_ACCOMPLISHED_DATE     => l_unit_effectivity_rec.accomplished_date,
                           X_SERVICE_LINE_ID       => l_unit_effectivity_rec.service_line_id,
                           X_PROGRAM_MR_HEADER_ID  => l_unit_effectivity_rec.program_mr_header_id,
                           X_CANCEL_REASON_CODE    => l_unit_effectivity_rec.cancel_reason_code,
                           X_EARLIEST_DUE_DATE     => l_unit_effectivity_rec.earliest_due_date,
                           X_LATEST_DUE_DATE       => l_unit_effectivity_rec.latest_due_date,
                           X_defer_from_ue_id      => l_unit_effectivity_rec.defer_from_ue_id,
                           X_cs_incident_id        => l_unit_effectivity_rec.cs_incident_id,
                           X_qa_collection_id      => l_unit_effectivity_rec.qa_collection_id,
                           X_orig_deferral_ue_id   => l_unit_effectivity_rec.orig_deferral_ue_id,
                           X_application_usg_code  => l_unit_effectivity_rec.application_usg_code,
                           X_object_type           => l_unit_effectivity_rec.object_type,
                           X_counter_id          => l_unit_effectivity_rec.counter_id,
                           X_MANUALLY_PLANNED_FLAG => l_unit_effectivity_rec.MANUALLY_PLANNED_FLAG,
                           X_LOG_SERIES_CODE       => l_unit_effectivity_rec.log_series_code,
                           X_LOG_SERIES_NUMBER     => l_unit_effectivity_rec.log_series_number,
                           X_FLIGHT_NUMBER         => l_unit_effectivity_rec.flight_number,
                           X_MEL_CDL_TYPE_CODE     => l_unit_effectivity_rec.mel_cdl_type_code,
                           X_POSITION_PATH_ID      => l_unit_effectivity_rec.position_path_id,
                           X_ATA_CODE              => l_unit_effectivity_rec.ATA_CODE,
                           X_UNIT_CONFIG_HEADER_ID  => l_unit_effectivity_rec.unit_config_header_id,
                           X_ATTRIBUTE_CATEGORY    => l_unit_effectivity_rec.ATTRIBUTE_CATEGORY,
                           X_ATTRIBUTE1            => l_unit_effectivity_rec.ATTRIBUTE1,
                           X_ATTRIBUTE2            => l_unit_effectivity_rec.ATTRIBUTE2,
                           X_ATTRIBUTE3            => l_unit_effectivity_rec.ATTRIBUTE3,
                           X_ATTRIBUTE4            => l_unit_effectivity_rec.ATTRIBUTE4,
                           X_ATTRIBUTE5            => l_unit_effectivity_rec.ATTRIBUTE5,
                           X_ATTRIBUTE6            => l_unit_effectivity_rec.ATTRIBUTE6,
                           X_ATTRIBUTE7            => l_unit_effectivity_rec.ATTRIBUTE7,
                           X_ATTRIBUTE8            => l_unit_effectivity_rec.ATTRIBUTE8,
                           X_ATTRIBUTE9            => l_unit_effectivity_rec.ATTRIBUTE9,
                           X_ATTRIBUTE10           => l_unit_effectivity_rec.ATTRIBUTE10,
                           X_ATTRIBUTE11           => l_unit_effectivity_rec.ATTRIBUTE11,
                           X_ATTRIBUTE12           => l_unit_effectivity_rec.ATTRIBUTE12,
                           X_ATTRIBUTE13           => l_unit_effectivity_rec.ATTRIBUTE13,
                           X_ATTRIBUTE14           => l_unit_effectivity_rec.ATTRIBUTE14,
                           X_ATTRIBUTE15           => l_unit_effectivity_rec.ATTRIBUTE15,
                           X_OBJECT_VERSION_NUMBER => l_unit_effectivity_rec.object_version_number+1,
                           X_LAST_UPDATE_DATE      => sysdate,
                           X_LAST_UPDATED_BY => fnd_global.user_id,
                           X_LAST_UPDATE_LOGIN  => fnd_global.login_id );


                        -- Delete the corresponding rows in ahl_schedule materials for this ue.
                        IF (l_unit_effectivity_rec.due_date IS NULL
                           AND l_unit_effectivity_rec.object_type = 'MR') THEN
                           Delete_Sch_Materials(l_unit_effectivity_rec.unit_effectivity_id);
                        END IF;

                      END IF;
                      CLOSE ahl_unit_effectivity_csr;
                END LOOP; -- l_ue_rec

            END IF; -- ahl_unit_effectivity_csr

     ELSE /* group match = 'N' */
        -- Create new group.
        OPEN ahl_unit_effectivity_csr(unit_sr_def_rec.unit_effectivity_id);
        FETCH ahl_unit_effectivity_csr INTO l_unit_effectivity_rec;
        IF (ahl_unit_effectivity_csr%NOTFOUND) THEN
           FND_Message.Set_Name ('AHL','AHL_UMP_PUE_UE_NOTFOUND');
           FND_Message.set_token ('UE_ID',unit_sr_def_rec.unit_effectivity_id);
           FND_MSG_PUB.ADD;
           CLOSE ahl_unit_effectivity_csr;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSE
           l_unit_effectivity_rec.tolerance_flag := unit_sr_def_rec.tolerance_flag;
           l_unit_effectivity_rec.message_code   := unit_sr_def_rec.message_code;
           l_unit_effectivity_rec.due_date       := unit_sr_def_rec.due_date;
           l_unit_effectivity_rec.due_counter_value := unit_sr_def_rec.due_counter_value;
           l_unit_effectivity_rec.object_type   := unit_sr_def_rec.object_type;

           -- track old UE for deletion.
           l_index := l_index + 1;
           l_delete_ue_id_tbl(l_index) := unit_sr_def_rec.unit_effectivity_id;

            IF G_DEBUG = 'Y' THEN
               AHL_DEBUG_PUB.Debug('Insert Record-');
               AHL_DEBUG_PUB.Debug('CSI:MR:' || l_unit_effectivity_rec.csi_item_instance_id || ',' || l_unit_effectivity_rec.MR_header_id);
            END IF;

            AHL_UNIT_EFFECTIVITIES_PKG.Insert_Row (
                      X_ROWID               =>  l_rowid,
                      X_UNIT_EFFECTIVITY_ID =>   l_unit_effectivity_id,
                      X_CSI_ITEM_INSTANCE_ID  => l_unit_effectivity_rec.csi_item_instance_id,
                      X_MR_INTERVAL_ID        => null,
                      X_MR_EFFECTIVITY_ID     => null,
                      X_MR_HEADER_ID          => l_unit_effectivity_rec.MR_header_id,
                      X_STATUS_CODE           => null, /* status_code */
                      X_DUE_DATE              => l_unit_effectivity_rec.due_date,
                      X_DUE_COUNTER_VALUE     => l_unit_effectivity_rec.due_counter_value,
                      X_FORECAST_SEQUENCE     => null,
                      X_REPETITIVE_MR_FLAG    => 'N',
                      X_TOLERANCE_FLAG        => l_unit_effectivity_rec.tolerance_flag,
                      X_REMARKS               => l_unit_effectivity_rec.remarks,
                      X_MESSAGE_CODE          => l_unit_effectivity_rec.message_code,
                      X_PRECEDING_UE_ID       => null, /* preceding_ue_id */
                      X_DATE_RUN              => sysdate, /* date_run */
                      X_SET_DUE_DATE          => null, /* set due date */
                      X_ACCOMPLISHED_DATE     => null, /* accomplished date */
                      X_SERVICE_LINE_ID       => l_unit_effectivity_rec.service_line_id,
                      X_PROGRAM_MR_HEADER_ID  => l_unit_effectivity_rec.program_mr_header_id,
                      X_CANCEL_REASON_CODE    => null, /* cancel_reason_code */
                      X_EARLIEST_DUE_DATE     => l_unit_effectivity_rec.earliest_due_date,
                      X_LATEST_DUE_DATE       => l_unit_effectivity_rec.latest_due_date,
                      X_defer_from_ue_id      => l_unit_effectivity_rec.defer_from_ue_id,
                      X_cs_incident_id        => l_unit_effectivity_rec.cs_incident_id,
                      X_qa_collection_id      => l_unit_effectivity_rec.qa_collection_id,
                      X_orig_deferral_ue_id   => l_unit_effectivity_rec.orig_deferral_ue_id,
                      X_application_usg_code  => l_unit_effectivity_rec.application_usg_code,
                      X_object_type           => l_unit_effectivity_rec.object_type,
                      X_counter_id            => l_unit_effectivity_rec.counter_id,
                      X_MANUALLY_PLANNED_FLAG => l_unit_effectivity_rec.manually_planned_flag,
                      X_LOG_SERIES_CODE       => l_unit_effectivity_rec.log_series_code,
                      X_LOG_SERIES_NUMBER     => l_unit_effectivity_rec.log_series_number,
                      X_FLIGHT_NUMBER         => l_unit_effectivity_rec.flight_number,
                      X_MEL_CDL_TYPE_CODE     => l_unit_effectivity_rec.mel_cdl_type_code,
                      X_POSITION_PATH_ID      => l_unit_effectivity_rec.position_path_id,
                      X_ATA_CODE              => l_unit_effectivity_rec.ATA_CODE,
                      X_UNIT_CONFIG_HEADER_ID  => l_unit_effectivity_rec.unit_config_header_id,
                      X_ATTRIBUTE_CATEGORY    => null, /* ATTRIBUTE_CATEGORY */
                      X_ATTRIBUTE1            => null, /* ATTRIBUTE1 */
                      X_ATTRIBUTE2            => null, /* ATTRIBUTE2 */
                      X_ATTRIBUTE3            => null, /* ATTRIBUTE3 */
                      X_ATTRIBUTE4            => null, /* ATTRIBUTE4 */
                      X_ATTRIBUTE5            => null, /* ATTRIBUTE5 */
                      X_ATTRIBUTE6            => null, /* ATTRIBUTE6 */
                      X_ATTRIBUTE7            => null, /* ATTRIBUTE7 */
                      X_ATTRIBUTE8            => null, /* ATTRIBUTE8 */
                      X_ATTRIBUTE9            => null, /* ATTRIBUTE9 */
                      X_ATTRIBUTE10           => null, /* ATTRIBUTE10 */
                      X_ATTRIBUTE11           => null, /* ATTRIBUTE11 */
                      X_ATTRIBUTE12           => null, /* ATTRIBUTE12 */
                      X_ATTRIBUTE13           => null, /* ATTRIBUTE13 */
                      X_ATTRIBUTE14           => null, /* ATTRIBUTE14 */
                      X_ATTRIBUTE15           => null, /* ATTRIBUTE15 */
                      X_OBJECT_VERSION_NUMBER => 1, /* object version */
                      X_CREATION_DATE         => sysdate,
                      X_CREATED_BY            => fnd_global.user_id,
                      X_LAST_UPDATE_DATE      => sysdate,
                      X_LAST_UPDATED_BY       => fnd_global.user_id,
                      X_LAST_UPDATE_LOGIN     => fnd_global.login_id );

                l_new_top_ue_id := l_unit_effectivity_id;

                -- update new UE ID for top node.
                UPDATE ahl_temp_unit_SR_deferrals
                SET unit_effectivity_id = l_new_top_ue_id,
                    object_type = l_unit_effectivity_rec.object_type
                WHERE CURRENT OF ahl_unit_sr_def_csr ;

                CLOSE ahl_unit_effectivity_csr;

                -- Associate deferral threshold to new UE if exists (deferral from UMP).
                UPDATE AHL_UNIT_DEFERRALS_B
                SET unit_effectivity_id = l_new_top_ue_id,
                    last_update_date = sysdate,
                    object_version_number = object_version_number + 1,
                    LAST_UPDATED_BY = fnd_global.user_id,
                    LAST_UPDATE_LOGIN = fnd_global.login_id
                WHERE unit_effectivity_id = unit_sr_def_rec.unit_effectivity_id;

                -- Create group children.
                FOR ahl_temp_rec IN ahl_temp_csr (
                                   unit_sr_def_rec.csi_item_instance_id,
                                   unit_sr_def_rec.mr_header_id,
                                   unit_sr_def_rec.unit_effectivity_id)
                LOOP
                   -- Initialize.

                   AHL_UNIT_EFFECTIVITIES_PKG.Insert_Row (
                      X_ROWID                 => l_rowid,
                      X_UNIT_EFFECTIVITY_ID   => l_unit_effectivity_id,
                      X_CSI_ITEM_INSTANCE_ID  => ahl_temp_rec.csi_item_instance_id,
                      X_MR_INTERVAL_ID        => null,
                      X_MR_EFFECTIVITY_ID     => null,
                      X_MR_HEADER_ID          => ahl_temp_rec.mr_header_id,
                      X_STATUS_CODE           => null, /* status_code */
                      X_DUE_DATE              => l_unit_effectivity_rec.due_date,
                      X_DUE_COUNTER_VALUE     => l_unit_effectivity_rec.due_counter_value,
                      X_FORECAST_SEQUENCE     => null,
                      X_REPETITIVE_MR_FLAG    => 'N',
                      X_TOLERANCE_FLAG        => l_unit_effectivity_rec.tolerance_flag,
                      X_REMARKS               => l_unit_effectivity_rec.remarks,
                      X_MESSAGE_CODE          => l_unit_effectivity_rec.message_code,
                      X_PRECEDING_UE_ID       => null, /* preceding_ue_id */
                      X_DATE_RUN              => sysdate, /* date_run */
                      X_SET_DUE_DATE          => null, /* set due date */
                      X_ACCOMPLISHED_DATE     => null, /* accomplished date */
                      X_SERVICE_LINE_ID       => l_unit_effectivity_rec.service_line_id,
                      X_PROGRAM_MR_HEADER_ID  => l_unit_effectivity_rec.program_mr_header_id,
                      X_CANCEL_REASON_CODE    => null, /* cancel_reason_code */
                      X_EARLIEST_DUE_DATE     => l_unit_effectivity_rec.earliest_due_date,
                      X_LATEST_DUE_DATE       => l_unit_effectivity_rec.latest_due_date,
                      X_defer_from_ue_id      => l_unit_effectivity_rec.defer_from_ue_id,
                      X_cs_incident_id        => l_unit_effectivity_rec.cs_incident_id,
                      X_qa_collection_id      => l_unit_effectivity_rec.qa_collection_id,
                      X_orig_deferral_ue_id   => l_unit_effectivity_rec.orig_deferral_ue_id,
                      X_application_usg_code  => l_unit_effectivity_rec.application_usg_code,
                      X_object_type           => 'MR',
                      X_counter_id            => l_unit_effectivity_rec.counter_id,
                      X_manually_planned_flag => l_unit_effectivity_rec.manually_planned_flag,
                      X_LOG_SERIES_CODE       => l_unit_effectivity_rec.log_series_code,
                      X_LOG_SERIES_NUMBER     => l_unit_effectivity_rec.log_series_number,
                      X_FLIGHT_NUMBER         => l_unit_effectivity_rec.flight_number,
                      X_MEL_CDL_TYPE_CODE     => l_unit_effectivity_rec.mel_cdl_type_code,
                      X_POSITION_PATH_ID      => l_unit_effectivity_rec.position_path_id,
                      X_ATA_CODE              => l_unit_effectivity_rec.ATA_CODE,
                      X_UNIT_CONFIG_HEADER_ID  => l_unit_effectivity_rec.unit_config_header_id,
                      X_ATTRIBUTE_CATEGORY    => null, /* ATTRIBUTE_CATEGORY */
                      X_ATTRIBUTE1            => null, /* ATTRIBUTE1 */
                      X_ATTRIBUTE2            => null, /* ATTRIBUTE2 */
                      X_ATTRIBUTE3            => null, /* ATTRIBUTE3 */
                      X_ATTRIBUTE4            => null, /* ATTRIBUTE4 */
                      X_ATTRIBUTE5            => null, /* ATTRIBUTE5 */
                      X_ATTRIBUTE6            => null, /* ATTRIBUTE6 */
                      X_ATTRIBUTE7            => null, /* ATTRIBUTE7 */
                      X_ATTRIBUTE8            => null, /* ATTRIBUTE8 */
                      X_ATTRIBUTE9            => null, /* ATTRIBUTE9 */
                      X_ATTRIBUTE10           => null, /* ATTRIBUTE10 */
                      X_ATTRIBUTE11           => null, /* ATTRIBUTE11 */
                      X_ATTRIBUTE12           => null, /* ATTRIBUTE12 */
                      X_ATTRIBUTE13           => null, /* ATTRIBUTE13 */
                      X_ATTRIBUTE14           => null, /* ATTRIBUTE14 */
                      X_ATTRIBUTE15           => null, /* ATTRIBUTE15 */
                      X_OBJECT_VERSION_NUMBER => 1, /* object version */
                      X_CREATION_DATE         => sysdate,
                      X_CREATED_BY            => fnd_global.user_id,
                      X_LAST_UPDATE_DATE      => sysdate,
                      X_LAST_UPDATED_BY       => fnd_global.user_id,
                      X_LAST_UPDATE_LOGIN     => fnd_global.login_id );

                   UPDATE ahl_temp_unit_SR_deferrals
                   SET unit_effectivity_id = l_unit_effectivity_id,
                       object_type = l_unit_effectivity_rec.object_type
                   WHERE CURRENT OF ahl_temp_csr ;

                END LOOP;

                -- Build relationships.
                FOR ahl_temp_rec IN ahl_temp_csr (
                                   unit_sr_def_rec.csi_item_instance_id,
                                   unit_sr_def_rec.mr_header_id,
                                   unit_sr_def_rec.unit_effectivity_id)
                LOOP

                   OPEN ahl_temp_parent_csr(ahl_temp_rec.parent_csi_item_instance_id,
                                            ahl_temp_rec.parent_mr_header_id,
                                            unit_sr_def_rec.csi_item_instance_id,
                                            unit_sr_def_rec.mr_header_id,
                                            unit_sr_def_rec.unit_effectivity_id);

                   FETCH ahl_temp_parent_csr INTO l_parent_ue_id;
                   IF (ahl_temp_parent_csr%NOTFOUND) THEN
                     -- parent is root UE.
                     l_parent_ue_id := l_new_top_ue_id;
                     --FND_MESSAGE.Set_Name ('AHL','AHL_UMP_PUE_PARENT_NOTFOUND');
                     --FND_MESSAGE.Set_Token ('INST_ID',ahl_temp_rec.csi_item_instance_id);
                     --FND_MESSAGE.Set_Token ('MR_ID',ahl_temp_rec.mr_header_id);
                     --FND_MSG_PUB.ADD;
                     --CLOSE ahl_temp_parent_csr;
                     --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                   END IF;
                   CLOSE ahl_temp_parent_csr;

                   -- Insert into ahl_ue_relationships.
                   AHL_UE_RELATIONSHIPS_PKG.Insert_Row(
                     X_UE_RELATIONSHIP_ID => l_ue_relationship_id,
                     X_UE_ID  => l_parent_ue_id,
                     X_RELATED_UE_ID => ahl_temp_rec.unit_effectivity_id,
                     X_RELATIONSHIP_CODE => 'PARENT',
                     X_ORIGINATOR_UE_ID => l_new_top_ue_id,
                     X_ATTRIBUTE_CATEGORY => null, /* ATTRIBUTE_CATEGORY */
                     X_ATTRIBUTE1 => null, /* ATTRIBUTE1 */
                     X_ATTRIBUTE2 => null, /* ATTRIBUTE2 */
                     X_ATTRIBUTE3 => null, /* ATTRIBUTE3 */
                     X_ATTRIBUTE4 => null, /* ATTRIBUTE4 */
                     X_ATTRIBUTE5 => null, /* ATTRIBUTE5 */
                     X_ATTRIBUTE6 => null, /* ATTRIBUTE6 */
                     X_ATTRIBUTE7 => null, /* ATTRIBUTE7 */
                     X_ATTRIBUTE8 => null, /* ATTRIBUTE8 */
                     X_ATTRIBUTE9 => null, /* ATTRIBUTE9 */
                     X_ATTRIBUTE10 => null, /* ATTRIBUTE10 */
                     X_ATTRIBUTE11 => null, /* ATTRIBUTE11 */
                     X_ATTRIBUTE12 => null, /* ATTRIBUTE12 */
                     X_ATTRIBUTE13 => null, /* ATTRIBUTE13 */
                     X_ATTRIBUTE14 => null, /* ATTRIBUTE14 */
                     X_ATTRIBUTE15 => null, /* ATTRIBUTE15 */
                     X_OBJECT_VERSION_NUMBER => 1,
                     X_LAST_UPDATE_DATE => sysdate,
                     X_LAST_UPDATED_BY  => fnd_global.user_id,
                     X_CREATION_DATE => sysdate,
                     X_CREATED_BY  => fnd_global.user_id,
                     X_LAST_UPDATE_LOGIN => fnd_global.login_id);


                 END LOOP;

                 -- If object_type = 'SR', check for any terminated MR's for immediate children of the SR-UE.
                 -- If exists, add them to the new copied node.

                 IF (unit_sr_def_rec.object_type = 'SR') THEN
                   FOR ahl_term_MR_rec IN ahl_term_MR_csr(unit_sr_def_rec.unit_effectivity_id) LOOP
                     -- Get Unit effectivity details.
                     OPEN ahl_unit_effectivity_csr(unit_sr_def_rec.unit_effectivity_id);
                     FETCH ahl_unit_effectivity_csr INTO l_unit_effectivity_rec;
                     IF (ahl_unit_effectivity_csr%NOTFOUND) THEN
                        FND_Message.Set_Name ('AHL','AHL_UMP_PUE_UE_NOTFOUND');
                        FND_Message.set_token ('UE_ID',unit_sr_def_rec.unit_effectivity_id);
                        FND_MSG_PUB.ADD;
                        CLOSE ahl_unit_effectivity_csr;
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                     ELSE
                        AHL_UNIT_EFFECTIVITIES_PKG.Insert_Row (
                           X_ROWID               =>   l_rowid,
                           X_UNIT_EFFECTIVITY_ID =>   l_unit_effectivity_id,
                           X_CSI_ITEM_INSTANCE_ID  => l_unit_effectivity_rec.csi_item_instance_id,
                           X_MR_INTERVAL_ID        => l_unit_effectivity_rec.MR_INTERVAL_ID,
                           X_MR_EFFECTIVITY_ID     => l_unit_effectivity_rec.MR_EFFECTIVITY_ID,
                           X_MR_HEADER_ID          => l_unit_effectivity_rec.MR_header_id,
                           X_STATUS_CODE           => l_unit_effectivity_rec.STATUS_CODE, /* status_code */
                           X_DUE_DATE              => l_unit_effectivity_rec.due_date,
                           X_DUE_COUNTER_VALUE     => l_unit_effectivity_rec.due_counter_value,
                           X_FORECAST_SEQUENCE     => l_unit_effectivity_rec.FORECAST_SEQUENCE,
                           X_REPETITIVE_MR_FLAG    => l_unit_effectivity_rec.REPETITIVE_MR_FLAG,
                           X_TOLERANCE_FLAG        => l_unit_effectivity_rec.tolerance_flag,
                           X_REMARKS               => l_unit_effectivity_rec.remarks,
                           X_MESSAGE_CODE          => l_unit_effectivity_rec.message_code,
                           X_PRECEDING_UE_ID       => l_unit_effectivity_rec.PRECEDING_UE_ID, /* preceding_ue_id */
                           X_DATE_RUN              => sysdate, /* date_run */
                           X_SET_DUE_DATE          => null, /* set due date */
                           X_ACCOMPLISHED_DATE     => l_unit_effectivity_rec.ACCOMPLISHED_DATE, /* accomplished date */
                           X_SERVICE_LINE_ID       => l_unit_effectivity_rec.service_line_id,
                           X_PROGRAM_MR_HEADER_ID  => l_unit_effectivity_rec.program_mr_header_id,
                           X_CANCEL_REASON_CODE    => l_unit_effectivity_rec.CANCEL_REASON_CODE, /* cancel_reason_code */
                           X_EARLIEST_DUE_DATE     => l_unit_effectivity_rec.earliest_due_date,
                           X_LATEST_DUE_DATE       => l_unit_effectivity_rec.latest_due_date,
                           X_defer_from_ue_id      => l_unit_effectivity_rec.defer_from_ue_id,
                           X_cs_incident_id        => l_unit_effectivity_rec.cs_incident_id,
                           X_qa_collection_id      => l_unit_effectivity_rec.qa_collection_id,
                           X_orig_deferral_ue_id   => l_unit_effectivity_rec.orig_deferral_ue_id,
                           X_application_usg_code  => l_unit_effectivity_rec.application_usg_code,
                           X_object_type           => l_unit_effectivity_rec.object_type,
                           X_counter_id            => l_unit_effectivity_rec.counter_id,
                           x_manually_planned_flag => l_unit_effectivity_rec.manually_planned_flag,
                           X_LOG_SERIES_CODE       => l_unit_effectivity_rec.log_series_code,
                           X_LOG_SERIES_NUMBER     => l_unit_effectivity_rec.log_series_number,
                           X_FLIGHT_NUMBER         => l_unit_effectivity_rec.flight_number,
                           X_MEL_CDL_TYPE_CODE     => l_unit_effectivity_rec.mel_cdl_type_code,
                           X_POSITION_PATH_ID      => l_unit_effectivity_rec.position_path_id,
                           X_ATA_CODE              => l_unit_effectivity_rec.ATA_CODE,
                           X_UNIT_CONFIG_HEADER_ID  => l_unit_effectivity_rec.unit_config_header_id,
                           X_ATTRIBUTE_CATEGORY    => null, /* ATTRIBUTE_CATEGORY */
                           X_ATTRIBUTE1            => null, /* ATTRIBUTE1 */
                           X_ATTRIBUTE2            => null, /* ATTRIBUTE2 */
                           X_ATTRIBUTE3            => null, /* ATTRIBUTE3 */
                           X_ATTRIBUTE4            => null, /* ATTRIBUTE4 */
                           X_ATTRIBUTE5            => null, /* ATTRIBUTE5 */
                           X_ATTRIBUTE6            => null, /* ATTRIBUTE6 */
                           X_ATTRIBUTE7            => null, /* ATTRIBUTE7 */
                           X_ATTRIBUTE8            => null, /* ATTRIBUTE8 */
                           X_ATTRIBUTE9            => null, /* ATTRIBUTE9 */
                           X_ATTRIBUTE10           => null, /* ATTRIBUTE10 */
                           X_ATTRIBUTE11           => null, /* ATTRIBUTE11 */
                           X_ATTRIBUTE12           => null, /* ATTRIBUTE12 */
                           X_ATTRIBUTE13           => null, /* ATTRIBUTE13 */
                           X_ATTRIBUTE14           => null, /* ATTRIBUTE14 */
                           X_ATTRIBUTE15           => null, /* ATTRIBUTE15 */
                           X_OBJECT_VERSION_NUMBER => 1, /* object version */
                           X_CREATION_DATE         => sysdate,
                           X_CREATED_BY            => fnd_global.user_id,
                           X_LAST_UPDATE_DATE      => sysdate,
                           X_LAST_UPDATED_BY       => fnd_global.user_id,
                           X_LAST_UPDATE_LOGIN     => fnd_global.login_id );

                     CLOSE ahl_unit_effectivity_csr;

                     -- Now create the relationship record.
                     AHL_UE_RELATIONSHIPS_PKG.Insert_Row(
                       X_UE_RELATIONSHIP_ID => l_ue_relationship_id,
                       X_UE_ID  => l_parent_ue_id,
                       X_RELATED_UE_ID => l_unit_effectivity_id,
                       X_RELATIONSHIP_CODE => 'PARENT',
                       X_ORIGINATOR_UE_ID => l_new_top_ue_id,
                       X_ATTRIBUTE_CATEGORY => null, /* ATTRIBUTE_CATEGORY */
                       X_ATTRIBUTE1 => null, /* ATTRIBUTE1 */
                       X_ATTRIBUTE2 => null, /* ATTRIBUTE2 */
                       X_ATTRIBUTE3 => null, /* ATTRIBUTE3 */
                       X_ATTRIBUTE4 => null, /* ATTRIBUTE4 */
                       X_ATTRIBUTE5 => null, /* ATTRIBUTE5 */
                       X_ATTRIBUTE6 => null, /* ATTRIBUTE6 */
                       X_ATTRIBUTE7 => null, /* ATTRIBUTE7 */
                       X_ATTRIBUTE8 => null, /* ATTRIBUTE8 */
                       X_ATTRIBUTE9 => null, /* ATTRIBUTE9 */
                       X_ATTRIBUTE10 => null, /* ATTRIBUTE10 */
                       X_ATTRIBUTE11 => null, /* ATTRIBUTE11 */
                       X_ATTRIBUTE12 => null, /* ATTRIBUTE12 */
                       X_ATTRIBUTE13 => null, /* ATTRIBUTE13 */
                       X_ATTRIBUTE14 => null, /* ATTRIBUTE14 */
                       X_ATTRIBUTE15 => null, /* ATTRIBUTE15 */
                       X_OBJECT_VERSION_NUMBER => 1,
                       X_LAST_UPDATE_DATE => sysdate,
                       X_LAST_UPDATED_BY  => fnd_global.user_id,
                       X_CREATION_DATE => sysdate,
                       X_CREATED_BY  => fnd_global.user_id,
                       X_LAST_UPDATE_LOGIN => fnd_global.login_id);

                     END IF;
                   END LOOP;
                 END IF;
        END IF;
     END IF;

  END LOOP;

  -- process l_delete_ue_id_tbl for UE deletion.
  IF (l_delete_ue_id_tbl.count > 0) THEN

    FOR i IN l_delete_ue_id_tbl.FIRST..l_delete_ue_id_tbl.LAST LOOP

      -- check if UE assigned to a visit.
      l_visit_status := AHL_UMP_UTIL_PKG.get_Visit_Status (l_delete_ue_id_tbl(i));

      -- only if visit is in planning status we must mark an exception.
      -- if visit is already on the floor, we do nothing.
      IF (l_visit_status = 'PLANNING') THEN
         FOR l_ue_rec IN ahl_ue_csr(l_delete_ue_id_tbl(i)) LOOP
           -- Delete the corresponding rows in ahl_schedule materials for this ue.
           Delete_Sch_Materials(l_ue_rec.related_ue_id);
         END LOOP;

         -- update unit effectivity record to exception.
         UPDATE AHL_UNIT_EFFECTIVITIES_B
            SET status_code = 'EXCEPTION',
                message_code = 'VISIT-ASSIGN',
                object_version_number = object_version_number + 1,
                DATE_RUN = sysdate,
                LAST_UPDATE_DATE = sysdate,
                LAST_UPDATED_BY = fnd_global.user_id,
                LAST_UPDATE_LOGIN = fnd_global.login_id
          WHERE unit_effectivity_id IN (SELECT related_ue_id
                                        FROM ahl_ue_relationships
                                        WHERE originator_ue_id = l_delete_ue_id_tbl(i)
                                          AND relationship_code = 'PARENT');

         -- Update originator UE ID.
         UPDATE AHL_UNIT_EFFECTIVITIES_B
            SET status_code = 'EXCEPTION',
                message_code = 'VISIT-ASSIGN',
                object_version_number = object_version_number + 1,
                DATE_RUN = sysdate,
                LAST_UPDATE_DATE = sysdate,
                LAST_UPDATED_BY = fnd_global.user_id,
                LAST_UPDATE_LOGIN = fnd_global.login_id
          WHERE unit_effectivity_id = l_delete_ue_id_tbl(i);

      ELSIF (l_visit_status IS NULL) THEN
        -- delete ahl_ue_relationships
        FOR l_ue_rec IN ahl_ue_csr(l_delete_ue_id_tbl(i)) LOOP

          -- delete unit effectivity record.
          AHL_UNIT_EFFECTIVITIES_PKG.Delete_Row(l_ue_rec.related_ue_id);

          -- Delete the corresponding rows in ahl_schedule materials for this ue.
          Delete_Sch_Materials(l_ue_rec.related_ue_id);

        END LOOP;
        DELETE FROM ahl_ue_relationships
          WHERE originator_ue_id = l_delete_ue_id_tbl(i);

        -- delete top UE
        AHL_UNIT_EFFECTIVITIES_PKG.Delete_Row(l_delete_ue_id_tbl(i));

        -- Delete the corresponding rows in ahl_schedule materials for this ue.
        Delete_Sch_Materials(l_delete_ue_id_tbl(i));

      END IF; -- l_visit_status
    END LOOP;
  END IF;

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.Debug('End Unit Sr Deferrals');
  END IF;

END Flush_Unit_SR_Deferrals;


-- Procedure to delete rows from ahl_schedule_materials.
PROCEDURE Delete_Sch_Materials(p_unit_effectivity_id  IN NUMBER) IS

  CURSOR ahl_sch_material_csr (p_unit_effectivity_id IN NUMBER) IS
    SELECT scheduled_material_id
    FROM ahl_schedule_materials
    WHERE material_request_type = 'FORECAST'
      AND unit_effectivity_id = p_unit_effectivity_id
      FOR UPDATE NOWAIT;

BEGIN

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.Debug('Start Delete_Sch_Materials for UE:' || p_unit_effectivity_id,'UMP-ProcessUnit');
  END IF;

  FOR sch_material_rec IN ahl_sch_material_csr(p_unit_effectivity_id) LOOP
    AHL_SCHEDULE_MATERIALS_PKG.delete_row(x_scheduled_material_id => sch_material_rec.scheduled_material_id);

  END LOOP;

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.Debug('End Delete_Sch_Materials');
  END IF;

END Delete_Sch_Materials;


END AHL_UMP_PROCESSUNIT_EXTN_PVT;

/
