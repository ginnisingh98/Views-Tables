--------------------------------------------------------
--  DDL for Package Body AHL_UMP_SR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UMP_SR_PVT" AS
/* $Header: AHLVUSRB.pls 120.15.12010000.3 2009/12/10 15:14:57 sracha ship $ */

-----------------------
-- Declare Constants --
-----------------------
G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AHL_UMP_SR_PVT';

G_LOG_PREFIX        CONSTANT VARCHAR2(100) := 'ahl.plsql.AHL_UMP_SR_PVT';

G_NO_FLAG           CONSTANT VARCHAR2(1)  := 'N';
G_YES_FLAG          CONSTANT VARCHAR2(1)  := 'Y';
G_SR_CLOSED_FLAG    CONSTANT VARCHAR2(1)  := 'C';
G_SR_OPEN_FLAG      CONSTANT VARCHAR2(1)  := 'O';

G_APP_MODULE        CONSTANT VARCHAR2(30) := 'AHL';

-- UMP Statuses
G_UMP_TERMINATED_STATUS     CONSTANT VARCHAR2(30) := 'TERMINATED';
G_UMP_SR_CLOSED_STATUS      CONSTANT VARCHAR2(30) := 'SR-CLOSED';
G_UMP_ACCOMPLISHED_STATUS   CONSTANT VARCHAR2(30) := 'ACCOMPLISHED';
G_UMP_DEFERRED_STATUS       CONSTANT VARCHAR2(30) := 'DEFERRED';
G_UMP_EXCEPTION_STATUS      CONSTANT VARCHAR2(30) := 'EXCEPTION';
G_UMP_MR_TERMINATE_STATUS   CONSTANT VARCHAR2(30) := 'MR-TERMINATE';

-- SR Statuses
--JR: Modified on 10/29/2003: Using Status Id instead of Code since STATUS_CODE
--    column of CS_INCIDENT_STATUSES_B is obsoleted per SR Team (Thomas Alex)
G_SR_PLANNED_STATUS_ID    CONSTANT NUMBER := 52;

-- Operation Codes
G_OPR_CREATE              CONSTANT VARCHAR2(1) := 'C';
G_OPR_DELETE              CONSTANT VARCHAR2(1) := 'D';

-- UE Relationship Code
G_UE_PARENT_REL_CODE      CONSTANT VARCHAR2(30) := 'PARENT';

-- UE Object Types
G_UE_MR_OBJECT_TYPE       CONSTANT VARCHAR2(2) := 'MR';
G_UE_SR_OBJECT_TYPE       CONSTANT VARCHAR2(2) := 'SR';

-------------------------------------------------
-- Declare Locally used Record and Table Types --
-------------------------------------------------

------------------------------
-- Declare Local Procedures --
------------------------------
  -- This Procedure validates the request for the SR-MR Association API
  PROCEDURE Validate_Associated_Request(
     p_x_request_id          IN OUT NOCOPY NUMBER,
     p_request_number        IN VARCHAR2,
     p_object_version_number IN NUMBER,
     x_sr_ue_id              OUT NOCOPY NUMBER,
     x_sr_instance_id        OUT NOCOPY NUMBER,
     x_sr_exp_resol_date     OUT NOCOPY DATE);

  -- This Procedure validates SR-MR Association Records
  PROCEDURE Validate_Association_Records(
     p_request_id              IN NUMBER,
     p_sr_ue_id                IN NUMBER,
     p_sr_instance_id          IN NUMBER,
     p_x_sr_mr_association_tbl IN OUT NOCOPY SR_MR_Association_Tbl_Type);

  -- This Procedure deletes SR-MR associations
  PROCEDURE Process_Disassociations(
     p_sr_ue_id              IN NUMBER,
     p_sr_mr_association_tbl IN SR_MR_Association_Tbl_Type);

  -- This Procedure Creates New SR-MR associations
  PROCEDURE Process_New_Associations(
     p_sr_ue_id                IN            NUMBER,
     p_sr_instance_id          IN            NUMBER,
     p_sr_exp_resol_date       IN            DATE,
     p_user_id                 IN            NUMBER,
     p_login_id                IN            NUMBER,
     p_x_sr_mr_association_tbl IN OUT NOCOPY SR_MR_Association_Tbl_Type);

  -- This Procedure Gets the Unit Effectivity Id
  PROCEDURE Get_MR_UnitEffectivity(
     p_sr_ue_id                IN            NUMBER,
     p_x_sr_mr_association_rec IN OUT NOCOPY SR_MR_Association_Rec_Type);

  -- This Procedure does Value to Id Conversion for New Associations
  PROCEDURE Get_New_Asso_Val_To_Id(
     p_x_sr_mr_association_rec IN OUT NOCOPY SR_MR_Association_Rec_Type);

  -- This Procedure creates a new unit effectivity
  PROCEDURE Create_MR_Unit_Effectivity(
     p_instance_id  IN NUMBER,
     p_due_date     IN DATE,
     p_mr_header_id IN NUMBER,
     p_user_id      IN NUMBER,
     p_login_id     IN NUMBER,
     x_ue_id        OUT NOCOPY NUMBER);

  -- This Procedure creates a new UE Relationship
  PROCEDURE Create_UE_Relationship(
     p_ue_id             IN  NUMBER,
     p_related_ue_id     IN  NUMBER,
     p_relationship_code IN  VARCHAR2,
     p_originator_id     IN  NUMBER,
     p_user_id           IN  NUMBER,
     p_login_id          IN  NUMBER,
     x_ue_rel_id         OUT NOCOPY NUMBER);

  -- This Procedure processes group MRs
  PROCEDURE Process_Group_MR(
     p_mr_header_id     IN      NUMBER,
     p_csi_instance_id  IN      NUMBER,
     p_mr_ue_id         IN      NUMBER,
     p_sr_ue_id         IN      NUMBER,
     p_due_date         IN      DATE,
     p_user_id          IN      NUMBER,
     p_login_id         IN      NUMBER,
     p_x_valid_flag     IN OUT NOCOPY BOOLEAN);

  -- This Function gets the MR Title from the MR Header Id
  FUNCTION Get_MR_Title_From_MR_Id(
     p_mr_header_id IN NUMBER) RETURN VARCHAR2;

  -- This Function gets the MR Title from the Unit Effectivity Id
  FUNCTION Get_MR_Title_From_UE_Id(
     p_unit_effectivity_id IN NUMBER) RETURN VARCHAR2;

  -- This Procedure updates the due date and tolerance exceeded flag of UEs
  -- of the MRs associated to the SR in response to change in Exp. Resolution Date of the SR
  PROCEDURE Handle_MR_UE_Date_Change(
     p_sr_ue_id               IN NUMBER,
     p_assigned_to_visit_flag IN BOOLEAN,
     p_new_tolerance_flag     IN VARCHAR2,
     p_new_due_date           IN DATE);

  -- This Procedure updates the Unit Effectivity associated with the Service Request.
  -- It updates the Status, Instance, Due Date and Tolerance Flag in response to updates in a SR
  PROCEDURE Update_SR_Unit_Effectivity(
     p_sr_ue_id                IN NUMBER,
     p_due_date_flag           IN BOOLEAN,
     p_new_due_date            IN DATE,
     p_instance_flag           IN BOOLEAN,
     p_new_instance_id         IN NUMBER,
     p_status_flag             IN BOOLEAN,
     p_new_status_code         IN VARCHAR2,
     x_assigned_to_visit_flag  OUT NOCOPY BOOLEAN,
     x_new_tolerance_flag      OUT NOCOPY VARCHAR2);

  -- This Procedure validates the Service Request during the Post Update process.
  -- It retrieves some information as part of the validation process to be used by subsequent processes
  -- added x_defer_from_ue_id to fix bug# 9166304
  PROCEDURE Validate_Request_For_Update(
     x_sr_ue_id                OUT NOCOPY NUMBER,
     x_sr_ue_ovn               OUT NOCOPY NUMBER,
     x_defer_from_ue_id        OUT NOCOPY NUMBER);

  -- This Procedure handles type (CMRO to Non-CMRO and vice-versa) changes to a SR
  -- added p_defer_from_ue_id to fix bug# 9166304
  PROCEDURE Handle_Type_Change(
     p_sr_ue_id         IN NUMBER,
     p_defer_from_ue_id IN NUMBER);

  -- This Procedure handles other attribute (Instance, Resolution Date and Status) changes to a SR
  PROCEDURE Handle_Attribute_Changes(
     p_sr_ue_id  IN NUMBER);

  -- This Procedure handles the change in the item instance (customer product) of the SR
  -- added p_defer_from_ue_id to fix bug# 9166304
  PROCEDURE Handle_Instance_Change(
     p_sr_ue_id          IN NUMBER,
     p_old_instance_id   IN NUMBER,
     p_x_valid_flag      IN OUT NOCOPY BOOLEAN,  -- This flag will never be set to true in this procedure
     x_instance_changed  OUT NOCOPY BOOLEAN,
     p_defer_from_ue_id  IN NUMBER);

  -- This Procedure handles the change in the status of the Service Request
  PROCEDURE Handle_Status_Change(
     p_sr_ue_id        IN NUMBER,
     p_old_ue_status   IN AHL_UNIT_EFFECTIVITIES_B.STATUS_CODE%TYPE,
     p_x_valid_flag    IN OUT NOCOPY BOOLEAN,  -- This flag will never be set to true in this procedure
     x_status_changed  OUT NOCOPY BOOLEAN,
     x_new_ue_status   OUT NOCOPY AHL_UNIT_EFFECTIVITIES_B.STATUS_CODE%TYPE);

  -- This procedures handles updating the Description of the Workorders to SR Summary
  -- for following cases
  -- 1. Non-Routines(NR) created on the shop floor.
  -- 2. Non-Routines with no MRs associated and planned from UMP into a Visit.
  -- Balaji added this procedure for BAE ER # 4462462.
  PROCEDURE Handle_Summary_Update(
     p_sr_ue_id       IN    NUMBER
  );

-------------------------------------
-- End Local Procedures Declaration--
-------------------------------------

-----------------------------------------
-- Public Procedure Definitions follow --
-----------------------------------------
-- Start of Comments --
--  Procedure name    : Create_SR_Unit_Effectivity
--  Type              : Private
--  Function          : Private API to create a SR type unit effectivity. Called by corresponding Public procedure.
--                      Uses CS_SERVICEREQUEST_PVT.USER_HOOKS_REC to get SR Details.
--  Pre-reqs    :
--  Parameters  :
--      x_return_status                 OUT     VARCHAR2     Required
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

PROCEDURE Create_SR_Unit_Effectivity
(
   x_return_status         OUT  NOCOPY   VARCHAR2) IS
   l_api_name              CONSTANT VARCHAR2(30) := 'Create_SR_Unit_Effectivity';
   L_DEBUG_KEY             CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Create_SR_Unit_Effectivity';

   -- Validate Incident ID
   CURSOR validate_incident_id ( c_request_id in NUMBER )
   IS
   SELECT incident_id
   FROM cs_incidents_all_b
   WHERE incident_id = c_request_id;

   -- Validate Item Instance
   CURSOR validate_instance ( c_instance_id in NUMBER)
   IS
   SELECT instance_id, instance_number, active_end_date
   FROM csi_item_instances
   WHERE instance_id = c_instance_id;

   --Cursor Variables
   l_incident_id     NUMBER;
   l_instance_id     NUMBER;
   l_instance_number VARCHAR2(30);
   l_active_end_date DATE;
   l_name            VARCHAR2(30);
   --Procedure Returned Variables
   l_appln_code      VARCHAR2(20);
   l_return_status   VARCHAR2(1);
   -- User Hook Variables
   l_request_id          NUMBER;
   l_status_flag         VARCHAR2(3);
   l_old_type_cmro_flag  VARCHAR2(3);
   l_new_type_cmro_flag  VARCHAR2(3);
   l_customer_product_id NUMBER;
   l_status_id           NUMBER;
   l_exp_resolution_date DATE;
   -- Local Variables
   l_ump_status          fnd_lookups.lookup_code%TYPE;
   l_unit_effectivity_id NUMBER;
   l_rowid               VARCHAR2(30);
   l_accomplished_date   DATE := null;

   l_uc_hdr_id             NUMBER;
   l_uc_status_code        VARCHAR2(30);

BEGIN

  SAVEPOINT  Create_SR_Unit_Effectivity_Pvt;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Create_SR_Unit_Effectivity Procedure');
  END IF;

  -- Initialize message list
 --AMSRINIV. Bug 5470730. Removing message initialization.
 -- FND_MSG_PUB.Initialize;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Begin Processing

  --Getting all the required values from the user hook record
  l_request_id          := cs_servicerequest_pvt.user_hooks_rec.request_id;
  l_status_flag         := cs_servicerequest_pvt.user_hooks_rec.status_flag;
  l_old_type_cmro_flag  := cs_servicerequest_pvt.user_hooks_rec.old_type_cmro_flag;
  l_new_type_cmro_flag  := cs_servicerequest_pvt.user_hooks_rec.new_type_cmro_flag;
  l_customer_product_id := cs_servicerequest_pvt.user_hooks_rec.customer_product_id;
  l_status_id           := cs_servicerequest_pvt.user_hooks_rec.status_id;
  l_exp_resolution_date := cs_servicerequest_pvt.user_hooks_rec.exp_resolution_date;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY , ' input values:' );
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY , ' Request id::' || cs_servicerequest_pvt.user_hooks_rec.request_id);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY , 'Status flag:' || cs_servicerequest_pvt.user_hooks_rec.status_flag);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY , 'old_type_cmro_flag:' || cs_servicerequest_pvt.user_hooks_rec.old_type_cmro_flag);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY , 'new_type_cmro_flag:' || cs_servicerequest_pvt.user_hooks_rec.new_type_cmro_flag);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY , 'customer_product_id:' || cs_servicerequest_pvt.user_hooks_rec.customer_product_id);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY , 'status id:' || cs_servicerequest_pvt.user_hooks_rec.status_id);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY , 'exp_resolution_date:' || cs_servicerequest_pvt.user_hooks_rec.exp_resolution_date);
  END IF;


  --******************************
  --Validating the Request
  --******************************

  --Raising an error if the request id null
  IF (l_request_id IS NULL OR l_request_id = FND_API.G_MISS_NUM) THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.set_name('AHL', 'AHL_UMP_MISSING_REQUEST_ID');
     FND_MSG_PUB.add;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  --Opening cursor to validate incident id
  OPEN validate_incident_id ( l_request_id );
  FETCH validate_incident_id into l_incident_id;

  --Raise an error if the incident id is not valid.
  IF (validate_incident_id%NOTFOUND) THEN
    fnd_message.set_name('AHL', 'AHL_UMP_INVALID_INCIDENT_ID');
    fnd_message.set_token('INCIDENT_ID', l_request_id, false);
    FND_MSG_PUB.add;
    CLOSE validate_instance;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  CLOSE validate_incident_id;

  --Validating CMRO Type. If not CMRO type, return without processing.
  IF (nvl(l_new_type_cmro_flag, 'N') <> 'Y') THEN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    RETURN;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY , ' Processing for CMRO type of SR');
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY , ' BEFORE Calling AHL_UTIL_PKG.Get_Appln_Usage' );
  END IF;

  --Call the procedure AHL_UTIL_PKG.Get_Appln_Usage
  AHL_UTIL_PKG.Get_Appln_Usage
  (
     x_appln_code    => l_appln_code,
     x_return_status => l_return_status
  );

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY , ' After Calling AHL_UTIL_PKG.Get_Appln_Usage successfully' );
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY , ' l_appln_code: ' ||  l_appln_code);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY , ' l_return_status: ' || l_return_status);
  END IF;


  --Set the return status to an error and raise an error message if the return status is an error.
  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.set_name('AHL', 'AHL_COM_APPL_USG_PROF_NOT_SET');
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  --Set the return status to an error and raise an error message if the application code returned is not AHL
  IF (l_appln_code <> 'AHL') THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.set_name('AHL', 'AHL_COM_APPL_USG_MODE_INVALID');
     FND_MESSAGE.set_token('TASK', l_name, false);
     FND_MSG_PUB.add;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  --******************************
  --Validating the status
  --******************************
  -- JR: Modified on 10/29/2003 (Using Status Id instead of Status Code)
  -- Raise an error if the status is PLANNED.
  IF (l_status_id  = G_SR_PLANNED_STATUS_ID) THEN
    FND_MESSAGE.set_name('AHL', 'AHL_UMP_INVALID_STATUS_CODE');
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --******************************
  --Validating the item instance
  --******************************
  --Raise an error if the item instance id null
  IF (l_customer_product_id IS NULL OR l_customer_product_id = FND_API.G_MISS_NUM) THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.set_name('AHL', 'AHL_UMP_INSTANCE_MANDATORY');
     FND_MSG_PUB.add;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  --Ensuring that the instance exists in csi_item_instances.
  OPEN  validate_instance(l_customer_product_id);
  FETCH validate_instance into l_instance_id, l_instance_number, l_active_end_date;
  --Raise an error if the instance is not a valid CSI Instance
  IF (validate_instance%NOTFOUND) THEN
    fnd_message.set_name('AHL', 'AHL_UMP_INVALID_CSI_INSTANCE');
    fnd_message.set_token('CSI_INSTANCE_ID', l_customer_product_id, false);
    FND_MSG_PUB.add;
    CLOSE validate_instance;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --Raise an error if the instance is inactive.
  IF ( l_active_end_date IS NOT NULL AND l_active_end_date <= SYSDATE ) THEN
    fnd_message.set_name('AHL', 'AHL_UMP_INACTIVE_INSTANCE');
    fnd_message.set_token('INSTANCE_NUMBER', l_instance_number, false);
    FND_MSG_PUB.add;
    CLOSE validate_instance;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  CLOSE validate_instance;

  IF (l_status_flag = 'O') THEN
     l_ump_status := NULL;
  ELSE
     l_ump_status := 'SR-CLOSED';
     /* JR: Modified on 10/21/2003 */
     l_accomplished_date := SYSDATE;
  END IF;

    /* retrieve active unit on which SR instance is installed */
    SELECT ahl_util_uc_pkg.get_uc_header_id(l_customer_product_id) into l_uc_hdr_id from dual;
    IF (l_uc_hdr_id is not null)
    THEN
        -- if the instance's unit is in QUARANTINE/DEACTIVATE_QUARANTINE throw error
        -- if the instance's unit is COMPLETE/INCOMPLETE, it is active hence use the unit
        -- for all other cases treat the NR as being created for IB component only, i.e. no unit info
        l_uc_status_code := ahl_util_uc_pkg.get_uc_status_code(l_uc_hdr_id);
        IF (l_uc_status_code IN ('QUARANTINE', 'DEACTIVATE_QUARANTINE'))
        THEN
            FND_MESSAGE.SET_NAME('AHL', 'AHL_UMP_NR_UNIT_QUAR_INV');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        ELSIF (l_uc_status_code NOT IN ('COMPLETE', 'INCOMPLETE'))
        THEN
            l_uc_hdr_id := null;
        END IF;
    END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY , ' BEFORE Calling TABLE HANDLER AHL_UNIT_EFFECTIVITIES_PKG.Insert_Row' );
  END IF;


  --******************************
  -- Call Table Handler.
  --******************************
    AHL_UNIT_EFFECTIVITIES_PKG.Insert_Row (
        X_ROWID                 => l_rowid,
        X_UNIT_EFFECTIVITY_ID   => l_unit_effectivity_id,
        X_MANUALLY_PLANNED_FLAG => 'Y',
        X_LOG_SERIES_CODE       => null,
        X_LOG_SERIES_NUMBER     => null,
        X_FLIGHT_NUMBER         => null,
        X_MEL_CDL_TYPE_CODE     => null,
        X_POSITION_PATH_ID      => null,
        X_ATA_CODE              => null,
        --X_CLEAR_STATION_ORG_ID  => null,
        --X_CLEAR_STATION_DEPT_ID => null,
        X_UNIT_CONFIG_HEADER_ID => l_uc_hdr_id,
        X_QA_COLLECTION_ID      => null,
        X_CS_INCIDENT_ID        => l_request_id,
        X_OBJECT_TYPE           => 'SR',
        X_APPLICATION_USG_CODE  => l_appln_code,
        X_COUNTER_ID            => null,
        X_EARLIEST_DUE_DATE     => null,
        X_LATEST_DUE_DATE       => null,
        X_FORECAST_SEQUENCE     => null,
        X_REPETITIVE_MR_FLAG    => null,
        X_TOLERANCE_FLAG        => null,
        X_MESSAGE_CODE          => null,
        X_DATE_RUN              => null,
        X_PRECEDING_UE_ID       => null,
        X_SET_DUE_DATE          => null,
        X_ACCOMPLISHED_DATE     => l_accomplished_date,
        X_SERVICE_LINE_ID       => null,
        X_PROGRAM_MR_HEADER_ID  => null,
        X_CANCEL_REASON_CODE    => null,
        X_ATTRIBUTE_CATEGORY    => null,
        X_ATTRIBUTE1            => null,
        X_ATTRIBUTE2            => null,
        X_ATTRIBUTE3            => null,
        X_ATTRIBUTE4            => null,
        X_ATTRIBUTE5            => null,
        X_ATTRIBUTE6            => null,
        X_ATTRIBUTE7            => null,
        X_ATTRIBUTE8            => null,
        X_ATTRIBUTE9            => null,
        X_ATTRIBUTE10           => null,
        X_ATTRIBUTE11           => null,
        X_ATTRIBUTE12           => null,
        X_ATTRIBUTE13           => null,
        X_ATTRIBUTE14           => null,
        X_ATTRIBUTE15           => null,
        X_OBJECT_VERSION_NUMBER => 1,
        X_CSI_ITEM_INSTANCE_ID  => l_customer_product_id,
        X_MR_HEADER_ID          => null,
        X_MR_EFFECTIVITY_ID     => null,
        X_MR_INTERVAL_ID        => null,
        X_STATUS_CODE           => l_ump_status,
        X_DUE_DATE              => l_exp_resolution_date,
        X_DUE_COUNTER_VALUE     => null,
        X_DEFER_FROM_UE_ID      => null,
        X_ORIG_DEFERRAL_UE_ID   => null,
        X_REMARKS               => null,
        X_CREATION_DATE         => sysdate,
        X_CREATED_BY            => fnd_global.user_id,
        X_LAST_UPDATE_DATE      => sysdate,
        X_LAST_UPDATED_BY       => fnd_global.user_id,
        X_LAST_UPDATE_LOGIN     => fnd_global.login_id );

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY , ' AFTER Calling TABLE HANDLER AHL_UNIT_EFFECTIVITIES_PKG.Insert_Row' );
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY , ' Unit Effectivity ID:' || l_unit_effectivity_id);
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY , ' Return Status:' || x_return_status);
     END IF;

   -- End Processing

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Create_SR_Unit_Effectivity Procedure');
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO Create_SR_Unit_Effectivity_Pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;
   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY , ' Error: Return Status:' || x_return_status);
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY , ' Error: Msg Count:' || fnd_msg_pub.count_msg);
   END IF;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO Create_SR_Unit_Effectivity_Pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY , ' UnExpError: Return Status:' || x_return_status);
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY , ' UnExpError: Msg Count:' || fnd_msg_pub.count_msg);
   END IF;

 WHEN OTHERS THEN
    ROLLBACK TO Create_SR_Unit_Effectivity_Pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Create_SR_Unit_Effectivity',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
    END IF;

END Create_SR_Unit_Effectivity;

----------------------------------------
-- Start of Comments --
--  Procedure name    : Process_SR_Updates
--  Type              : Private
--  Function          : Private API to process changes to a (current or former) CMRO type SR
--                      by adding, removing or updating SR type unit effectivities.
--                      Called by the corresponding public procedure.
--                      Uses CS_SERVICEREQUEST_PVT.USER_HOOKS_REC to get SR Details.
--  Pre-reqs    :
--  Parameters  :
--      x_return_status                 OUT     VARCHAR2     Required
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

PROCEDURE Process_SR_Updates
(
   x_return_status         OUT  NOCOPY   VARCHAR2) IS

   l_api_name               CONSTANT VARCHAR2(30) := 'Process_SR_Updates';
   L_DEBUG_KEY              CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Process_SR_Updates';

   l_appln_code             VARCHAR2(30);
   l_skip_processing        BOOLEAN := false;
   l_sr_ue_id               NUMBER;
   l_sr_ue_ovn              NUMBER;
   -- added l_defer_from_ue_id to fix bug# 9166304
   l_defer_from_ue_id       NUMBER;
BEGIN

  SAVEPOINT Process_SR_Updates_Pvt;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  -- JR: Added the following log on 10/21/2003 to help in debugging
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY , 'Relevant User Hook Record (input) Values: ' );
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY , 'old_type_cmro_flag = ' || CS_SERVICEREQUEST_PVT.USER_HOOKS_REC.old_type_cmro_flag ||
                                                          ', new_type_cmro_flag = ' || CS_SERVICEREQUEST_PVT.USER_HOOKS_REC.new_type_cmro_flag ||
                                                          ', request_id = ' || CS_SERVICEREQUEST_PVT.user_hooks_rec.request_id ||
                                                          ', status_id = ' || CS_SERVICEREQUEST_PVT.user_hooks_rec.status_id ||
                                                          ', status_flag = ' || CS_SERVICEREQUEST_PVT.user_hooks_rec.status_flag ||
                                                          ', customer_product_id = ' || CS_SERVICEREQUEST_PVT.user_hooks_rec.customer_product_id ||
                                                          ', exp_resolution_date = ' || CS_SERVICEREQUEST_PVT.user_hooks_rec.exp_resolution_date);
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Initialize message list
  --AMSRINIV. Bug 5470730. Removing message initialization.
  --FND_MSG_PUB.Initialize;

  -- Begin Processing
  IF NOT (NVL(CS_SERVICEREQUEST_PVT.USER_HOOKS_REC.old_type_cmro_flag, G_NO_FLAG) = G_YES_FLAG OR
      NVL(CS_SERVICEREQUEST_PVT.USER_HOOKS_REC.new_type_cmro_flag, G_NO_FLAG)= G_YES_FLAG) THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Not a CMRO Type Service Request.');
    END IF;
    -- Not a CMRO Type Service Request
    -- Just return 'SUCCESS' without doing any processing.
    l_skip_processing := true;
  ELSE
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'From USER_HOOKS_REC: old_type_cmro_flag = ' || CS_SERVICEREQUEST_PVT.USER_HOOKS_REC.old_type_cmro_flag ||
                                                           ', new_type_cmro_flag = ' || CS_SERVICEREQUEST_PVT.USER_HOOKS_REC.new_type_cmro_flag);
    END IF;
  END IF;

  IF (l_skip_processing = false) THEN
    IF (NVL(CS_SERVICEREQUEST_PVT.USER_HOOKS_REC.new_type_cmro_flag, G_NO_FLAG) = G_YES_FLAG) THEN
      -- Since this is a CMRO type SR, ensure that the Application Usage profile option has been set to AHL
      AHL_UTIL_PKG.Get_Appln_Usage(x_appln_code    => l_appln_code,
                                   x_return_status => x_return_status);

      IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_APP_USAGE_NOT_SET');
        FND_MSG_PUB.ADD;
        IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF(l_appln_code IS NULL OR (l_appln_code <> G_APP_MODULE)) THEN
        FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_APP_USAGE_INVALID');
        FND_MSG_PUB.ADD;
        IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSE
        IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_EVENT, L_DEBUG_KEY, 'Application Usage Profile Option Validated');
        END IF;
      END IF;  --  Appln_Usage Valid
    END IF;  -- new_type_cmro_flag = 'Y'

    -- First Validate the request
    Validate_Request_For_Update(x_sr_ue_id         => l_sr_ue_id,
                                x_sr_ue_ovn        => l_sr_ue_ovn,
                                x_defer_from_ue_id => l_defer_from_ue_id);

    IF (NVL(CS_SERVICEREQUEST_PVT.USER_HOOKS_REC.old_type_cmro_flag, G_NO_FLAG) <> NVL(CS_SERVICEREQUEST_PVT.USER_HOOKS_REC.new_type_cmro_flag, G_NO_FLAG)) THEN
      -- Handle Type Change
      Handle_Type_Change(p_sr_ue_id          => l_sr_ue_id,
                         p_defer_from_ue_id  => l_defer_from_ue_id);

    ELSE
      -- Handle other attribute (instance, status and resolution date) changes
      Handle_Attribute_Changes(p_sr_ue_id => l_sr_ue_id);
    END IF;  -- Type change or other change
  END IF;  -- If l_skip_processing = false

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;

EXCEPTION

 WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO Process_SR_Updates_Pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO Process_SR_Updates_Pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

 WHEN OTHERS THEN
    ROLLBACK TO Process_SR_Updates_Pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Process_SR_Updates',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
    END IF;

END Process_SR_Updates;

----------------------------------------

-- Start of Comments --
--  Procedure name    : Process_SR_MR_Associations
--  Type              : Private
--  Function          : Processes new and removed MR associations with a CMRO type SR by
--                      creating or removing unit effectivities and corresponding relationships.
--                      Called by the corresponding public procedure.
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2     Required
--      x_msg_count                     OUT     NUMBER       Required
--      x_msg_data                      OUT     VARCHAR2     Required
--
--  Process_SR_MR_Associations Parameters:
--      p_user_id                       IN      NUMBER       Required
--         The Id of the user calling this API
--      p_login_id                      IN      NUMBER       Required
--         The Login Id of the user calling this API
--      p_request_id                    IN      NUMBER       Required if p_request_number is not given
--         The Id of the Service Request
--      p_object_version_number         IN      NUMBER       Required
--         The object version number of the Service Request
--      p_request_number                IN      VARCHAR2     Required if p_request_id is not given
--         The request number of the Service Request
--      p_x_sr_mr_association_tbl       IN OUT  AHL_UMP_SR_PVT.SR_MR_Association_Tbl_Type  Required
--         The Table of records containing the details about the associations and disassociations
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

PROCEDURE Process_SR_MR_Associations
(
   p_api_version           IN            NUMBER,
   p_init_msg_list         IN            VARCHAR2  := FND_API.G_FALSE,
   p_commit                IN            VARCHAR2  := FND_API.G_FALSE,
   p_validation_level      IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
   x_return_status         OUT  NOCOPY   VARCHAR2,
   x_msg_count             OUT  NOCOPY   NUMBER,
   x_msg_data              OUT  NOCOPY   VARCHAR2,
   p_user_id               IN            NUMBER,
   p_login_id              IN            NUMBER,
   p_request_id            IN            NUMBER,
   p_object_version_number IN            NUMBER,
   p_request_number        IN            VARCHAR2,
   p_x_sr_mr_association_tbl  IN OUT NOCOPY   AHL_UMP_SR_PVT.SR_MR_Association_Tbl_Type) IS

   l_api_version            CONSTANT NUMBER := 1.0;
   l_api_name               CONSTANT VARCHAR2(30) := 'Process_SR_MR_Associations';
   L_DEBUG_KEY              CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Process_SR_MR_Associations';

   l_appln_code             VARCHAR2(30);
   l_request_id             NUMBER := p_request_id;
   l_sr_ue_id               NUMBER := NULL;
   l_sr_instance_id         NUMBER := NULL;
   l_sr_exp_resol_date      DATE := NULL;

BEGIN
  -- Standard start of API savepoint
  SAVEPOINT Process_SR_MR_Associations_pvt;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Begin Processing
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Beginning Processing with p_request_id = ' || p_request_id ||
                                                         ', p_object_version_number = ' || p_object_version_number ||
                                                         ' and p_x_sr_mr_association_tbl.COUNT = ' || p_x_sr_mr_association_tbl.COUNT);
  END IF;
  -- Check if the Application Usage profile option has been set
  AHL_UTIL_PKG.Get_Appln_Usage(x_appln_code    => l_appln_code,
                               x_return_status => x_return_status);

  IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_APP_USAGE_NOT_SET');
    FND_MSG_PUB.ADD;
    IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF(l_appln_code IS NULL OR (l_appln_code <> G_APP_MODULE)) THEN
    FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_APP_USAGE_INVALID');
    FND_MSG_PUB.ADD;
    IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_EVENT, L_DEBUG_KEY, 'Application Usage Profile Option Validated');
  END IF;

  -- Validate the Request
  Validate_Associated_Request(p_x_request_id          => l_request_id,
                              p_request_number        => p_request_number,
                              p_object_version_number => p_object_version_number,
                              x_sr_ue_id              => l_sr_ue_id,
                              x_sr_instance_id        => l_sr_instance_id,
                              x_sr_exp_resol_date     => l_sr_exp_resol_date);

  IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_EVENT, L_DEBUG_KEY, 'Completed Validating the Request');
  END IF;

  IF (p_x_sr_mr_association_tbl.COUNT = 0) THEN
    FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_MR_SR_TBL_EMPTY');
    FND_MSG_PUB.ADD;
    IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Validate the SR-MR Association records
  Validate_Association_Records(p_request_id              => l_request_id,
                               p_sr_ue_id                => l_sr_ue_id,
                               p_sr_instance_id          => l_sr_instance_id,
                               p_x_sr_mr_association_tbl => p_x_sr_mr_association_tbl);

  IF (FND_MSG_PUB.Count_Msg > 0) THEN
       -- There are validation errors: No need to process further
       RAISE FND_API.G_EXC_ERROR;
  END IF;


  -- Process all Disassociations First
  Process_Disassociations(p_sr_ue_id              => l_sr_ue_id,
                          p_sr_mr_association_tbl => p_x_sr_mr_association_tbl);

  -- Process all New Associations Next
  Process_New_Associations(p_sr_ue_id                => l_sr_ue_id,
                           p_sr_instance_id          => l_sr_instance_id,
                           p_sr_exp_resol_date       => l_sr_exp_resol_date,
                           p_user_id                 => p_user_id,
                           p_login_id                => p_login_id,
                           p_x_sr_mr_association_tbl => p_x_sr_mr_association_tbl);

  IF (FND_MSG_PUB.Count_Msg > 0) THEN
    -- There are validation errors from Process_New_Associations: Raise error
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Standard check of p_commit
  IF FND_API.TO_BOOLEAN(p_commit) THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'About to Commit.');
    END IF;
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false
    );

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO Process_SR_MR_Associations_pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
   --AHL_UTIL_PKG.Err_Mesg_To_Table(x_err_mesg_tbl);

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO Process_SR_MR_Associations_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
   --AHL_UTIL_PKG.Err_Mesg_To_Table(x_err_mesg_tbl);

 WHEN OTHERS THEN
    ROLLBACK TO Process_SR_MR_Associations_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Process_SR_MR_Associations',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
    --AHL_UTIL_PKG.Err_Mesg_To_Table(x_err_mesg_tbl);

END Process_SR_MR_Associations;

----------------------------------------

--------------------------------------
-- End Public Procedure Definitions --
--------------------------------------

----------------------------------------
-- Local Procedure Definitions follow --
----------------------------------------
----------------------------------------
-- This Procedure validates the request for the SR-MR Association API
----------------------------------------
PROCEDURE Validate_Associated_Request(
   p_x_request_id          IN OUT NOCOPY NUMBER,
   p_request_number        IN VARCHAR2,
   p_object_version_number IN NUMBER,
   x_sr_ue_id              OUT NOCOPY NUMBER,
   x_sr_instance_id        OUT NOCOPY NUMBER,
   x_sr_exp_resol_date     OUT NOCOPY DATE) IS

  CURSOR get_request_dtls_csr(p_request_id IN NUMBER,
                              p_request_number IN VARCHAR2,
                              p_object_version_number IN NUMBER) IS
    /*SELECT incident_id, incident_status_id, closed_flag, customer_product_id, expected_resolution_date
    FROM CS_INCIDENTS_V
    WHERE INCIDENT_ID like DECODE(p_request_id, null, '%', p_request_id)
      AND INCIDENT_NUMBER like NVL(p_request_number, '%')
      AND OBJECT_VERSION_NUMBER = p_object_version_number;*/

    SELECT INC.incident_id, INC.incident_status_id, NVL(STATUS.CLOSE_FLAG, 'N') closed_flag, INC.customer_product_id, INC.expected_resolution_date
    FROM CS_INCIDENT_STATUSES_B STATUS,CS_INCIDENTS_ALL_B INC
    WHERE INC.INCIDENT_STATUS_ID = STATUS.INCIDENT_STATUS_ID
    AND INC.INCIDENT_ID like DECODE(p_request_id, null, '%', p_request_id)
      AND INC.INCIDENT_NUMBER like NVL(p_request_number, '%')
      AND INC.OBJECT_VERSION_NUMBER = p_object_version_number;

  CURSOR get_ue_dtls_csr(p_request_id IN NUMBER) IS
    SELECT UNIT_EFFECTIVITY_ID
    FROM AHL_UNIT_EFFECTIVITIES_APP_V
    WHERE CS_INCIDENT_ID = p_request_id
      AND (STATUS_CODE IS NULL OR STATUS_CODE NOT IN (G_UMP_DEFERRED_STATUS, G_UMP_EXCEPTION_STATUS));

  CURSOR get_tasks_for_ue_csr(p_ue_id IN NUMBER) IS
    SELECT 'x' from AHL_VISIT_TASKS_B
    where UNIT_EFFECTIVITY_ID = p_ue_id;

  l_sr_status_id     NUMBER := NULL;
  l_closed_flag      CS_INCIDENTS_V.CLOSED_FLAG%TYPE := NULL;
  l_dummy            VARCHAR2(1);

  L_DEBUG_KEY CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Validate_Associated_Request';

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  IF(p_x_request_id IS NULL AND p_request_number IS NULL) THEN
    FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_REQ_ID_NUM_NULL');
    FND_MSG_PUB.ADD;
    IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (p_object_version_number IS NULL) THEN
    FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_REQ_OVN_NULL');
    FND_MSG_PUB.ADD;
    IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSE
    OPEN get_request_dtls_csr(p_request_id            => p_x_request_id,
                              p_request_number        => p_request_number,
                              p_object_version_number => p_object_version_number);
    FETCH get_request_dtls_csr INTO p_x_request_id,
                                    l_sr_status_id,
                                    l_closed_flag,
                                    x_sr_instance_id,     -- OUT Parameter
                                    x_sr_exp_resol_date;  -- OUT Parameter
    IF get_request_dtls_csr%NOTFOUND THEN
      FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_REQ_OVN_INVALID');
      FND_MESSAGE.Set_Token('ID', p_x_request_id);
      FND_MESSAGE.Set_Token('OVN', p_object_version_number);
      FND_MSG_PUB.ADD;
      IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
      END IF;
      CLOSE get_request_dtls_csr;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    CLOSE get_request_dtls_csr;
  END IF;

  IF(l_closed_flag = G_YES_FLAG) THEN
    FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_REQ_CLOSED');
    FND_MSG_PUB.ADD;
    IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  /*
   Balaji commented out this cursor validation for OGMA ER : Adding MRs to Non-Routines
   Since as per this ER requirements, we are going to allow SR UEs to be modified and plan
   new UEs in the hierarchy in a visit.
   Please refer the design document for more information.

  -- JR: Modified on 10/29/2003 (Using Status Id instead of Status Code)
  IF (l_sr_status_id = G_SR_PLANNED_STATUS_ID) THEN
    FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_REQ_PLANNED');
    FND_MSG_PUB.ADD;
    IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  */
  OPEN get_ue_dtls_csr(p_request_id => p_x_request_id);
  FETCH get_ue_dtls_csr INTO x_sr_ue_id;  -- OUT Parameter
  IF (get_ue_dtls_csr%NOTFOUND) THEN
    FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_NO_UE_FOR_REQ');
    FND_MESSAGE.Set_Token('ID', p_x_request_id);
    FND_MSG_PUB.ADD;
    IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
    END IF;
    CLOSE get_ue_dtls_csr;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE get_ue_dtls_csr;

  /*
   Balaji commented out this cursor validation for OGMA ER : Adding MRs to Non-Routines
   Since as per this ER requirements, we are going to allow SR UEs to be modified and plan
   new UEs in the hierarchy in a visit.
   Please refer the design document for more information.
  OPEN get_tasks_for_ue_csr(p_ue_id => x_sr_ue_id);
  FETCH get_tasks_for_ue_csr INTO l_dummy;
  IF (get_tasks_for_ue_csr%FOUND) THEN
    FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_ASGND_TO_VISIT');
    FND_MSG_PUB.ADD;
    IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
    END IF;
    CLOSE get_tasks_for_ue_csr;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE get_tasks_for_ue_csr;
  */
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;
END Validate_Associated_Request;

----------------------------------------
-- This Procedure validates SR-MR Association Records
----------------------------------------
PROCEDURE Validate_Association_Records(
   p_request_id              IN     NUMBER,
   p_sr_ue_id                IN     NUMBER,
   p_sr_instance_id          IN     NUMBER,
   p_x_sr_mr_association_tbl IN OUT NOCOPY SR_MR_Association_Tbl_Type) IS

  CURSOR validate_mr_ue_csr(p_mr_ue_id  IN NUMBER,
                            p_mr_ue_ovn IN NUMBER,
                            p_sr_ue_id  IN NUMBER) IS
    SELECT 'x'
    FROM AHL_UNIT_EFFECTIVITIES_APP_V UE
    WHERE UE.UNIT_EFFECTIVITY_ID = p_mr_ue_id AND
          UE.OBJECT_VERSION_NUMBER = p_mr_ue_ovn AND
          EXISTS (SELECT 'x' from AHL_UE_RELATIONSHIPS UR
                  WHERE UR.UE_ID = p_sr_ue_id AND
                        UR.RELATED_UE_ID = p_mr_ue_id AND
                        UR.relationship_code = G_UE_PARENT_REL_CODE);

  CURSOR validate_mr_id_csr(p_mr_header_id IN NUMBER) IS
    SELECT TITLE, PROGRAM_TYPE_CODE
    FROM AHL_MR_HEADERS_APP_V
    WHERE MR_HEADER_ID = p_mr_header_id;

  CURSOR validate_instance_id_csr(p_csi_instance_id IN NUMBER) IS
    SELECT INSTANCE_NUMBER
    FROM CSI_ITEM_INSTANCES
    WHERE INSTANCE_ID = p_csi_instance_id;

--amsriniv. adding cursor to check if the instances on which the MRs are applicable are part of the SR Instance tree. ER 5883257
  CURSOR validate_sr_mr_intance_rel(c_mr_instance_id IN NUMBER,c_sr_instance_id IN NUMBER) IS
    select 'X'
    from csi_ii_relationships
    where subject_id = c_mr_instance_id
    start with object_id = c_sr_instance_id
    and RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
    and trunc(nvl(ACTIVE_START_DATE, sysdate)) <= trunc(sysdate)
    and trunc(nvl(ACTIVE_END_DATE, sysdate + 1)) > trunc(sysdate)
    connect by prior subject_id = object_id
    and RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
    and trunc(nvl(ACTIVE_START_DATE, sysdate)) <= trunc(sysdate)
    and trunc(nvl(ACTIVE_END_DATE, sysdate + 1)) > trunc(sysdate)
    UNION ALL
    select 'X'
    from csi_item_instances
    where instance_id = c_sr_instance_id
    and instance_id = c_mr_instance_id;

  l_dummy               VARCHAR2(1);
  l_mr_header_id        NUMBER := NULL;
  l_mr_title            AHL_MR_HEADERS_B.TITLE%TYPE := NULL;
  l_mr_version_number   NUMBER := NULL;
  l_valid               BOOLEAN;
  l_flag_sr_mr_inst  VARCHAR2(1); --amsriniv ER 5883257
  l_temp_return_status  VARCHAR2(1);
  l_temp_msg_count      NUMBER;
  l_temp_msg_data       VARCHAR2(2000);
  l_applicable_mr_tbl   AHL_FMP_PVT.APPLICABLE_MR_TBL_TYPE;
  l_mr_applicable       BOOLEAN;

  l_program_type_code   AHL_MR_HEADERS_B.PROGRAM_TYPE_CODE%TYPE;

  L_DEBUG_KEY CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Validate_Association_Records';

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;
  FOR i in p_x_sr_mr_association_tbl.FIRST .. p_x_sr_mr_association_tbl.LAST LOOP
    l_valid := true;
    IF (p_x_sr_mr_association_tbl(i).OPERATION_FLAG NOT IN (G_OPR_CREATE, G_OPR_DELETE)) THEN
      FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_OPR_INVALID');
      FND_MESSAGE.Set_Token('OPR_FLAG', p_x_sr_mr_association_tbl(i).OPERATION_FLAG);
      FND_MESSAGE.Set_Token('INDEX', i);
      FND_MSG_PUB.ADD;
      IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
      END IF;
      l_valid := false;
    ELSIF (p_x_sr_mr_association_tbl(i).OPERATION_FLAG = G_OPR_DELETE) THEN
      -- Delete Operation
      Get_MR_UnitEffectivity(p_sr_ue_id                => p_sr_ue_id,
                             p_x_sr_mr_association_rec => p_x_sr_mr_association_tbl(i));
      IF (p_x_sr_mr_association_tbl(i).UNIT_EFFECTIVITY_ID IS NULL) THEN
        FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_UE_ID_NULL');
        FND_MESSAGE.Set_Token('INDEX', i);
        FND_MSG_PUB.ADD;
        IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
        END IF;
        l_valid := false;
      ELSIF (p_x_sr_mr_association_tbl(i).OBJECT_VERSION_NUMBER IS NULL) THEN
        FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_UE_OVN_NULL');
        FND_MESSAGE.Set_Token('INDEX', i);
        FND_MSG_PUB.ADD;
        IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
        END IF;
        l_valid := false;
      ELSE
        OPEN validate_mr_ue_csr(p_mr_ue_id  => p_x_sr_mr_association_tbl(i).UNIT_EFFECTIVITY_ID,
                                p_mr_ue_ovn => p_x_sr_mr_association_tbl(i).OBJECT_VERSION_NUMBER,
                                p_sr_ue_id  => p_sr_ue_id);
        FETCH validate_mr_ue_csr INTO l_dummy;
        IF (validate_mr_ue_csr%NOTFOUND) THEN
          FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_UE_OVN_INVALID');
          FND_MESSAGE.Set_Token('UE_ID', p_x_sr_mr_association_tbl(i).UNIT_EFFECTIVITY_ID);
          FND_MESSAGE.Set_Token('OVN', p_x_sr_mr_association_tbl(i).OBJECT_VERSION_NUMBER);
          FND_MESSAGE.Set_Token('INDEX', i);
          FND_MSG_PUB.ADD;
          IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
          END IF;
          l_valid := false;
        END IF;  -- UE Id, OVN Not valid
        CLOSE validate_mr_ue_csr;
      END IF;  -- UE Id, OVN Not null
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        IF (l_valid) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Record ' || i || ' for Delete operation is Valid');
        ELSE
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Record ' || i || ' for Delete operation is Not valid');
        END IF;
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Record Details: UE ID: ' || p_x_sr_mr_association_tbl(i).UNIT_EFFECTIVITY_ID ||
                                                                           ', UE OVN: ' || p_x_sr_mr_association_tbl(i).OBJECT_VERSION_NUMBER);
      END IF;  -- Log Statement
    ELSE
      -- Create Operation
      Get_New_Asso_Val_To_Id(p_x_sr_mr_association_rec => p_x_sr_mr_association_tbl(i));
      IF (p_x_sr_mr_association_tbl(i).MR_HEADER_ID IS NULL) THEN
        FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_MR_DTLS_INVALID');
        FND_MESSAGE.Set_Token('TITLE', p_x_sr_mr_association_tbl(i).MR_TITLE);
        FND_MESSAGE.Set_Token('VERSION', p_x_sr_mr_association_tbl(i).MR_VERSION);
        FND_MESSAGE.Set_Token('INDEX', i);
        FND_MSG_PUB.ADD;
        IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
        END IF;
        l_valid := false;
      ELSIF (p_x_sr_mr_association_tbl(i).CSI_INSTANCE_ID IS NULL) THEN
        FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_INST_NUM_INVALID');
        FND_MESSAGE.Set_Token('INST_NUM', p_x_sr_mr_association_tbl(i).CSI_INSTANCE_NUMBER);
        FND_MESSAGE.Set_Token('INDEX', i);
        FND_MSG_PUB.ADD;
        IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
        END IF;
        l_valid := false;
      ELSE
        -- Validate the MR Header Id
        OPEN validate_mr_id_csr(p_mr_header_id => p_x_sr_mr_association_tbl(i).MR_HEADER_ID);
        FETCH validate_mr_id_csr INTO p_x_sr_mr_association_tbl(i).MR_TITLE, l_program_type_code;
        IF (validate_mr_id_csr%NOTFOUND) THEN
          CLOSE validate_mr_id_csr;
          FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_MR_ID_INVALID');
          FND_MESSAGE.Set_Token('MR_ID', p_x_sr_mr_association_tbl(i).MR_HEADER_ID);
          FND_MESSAGE.Set_Token('INDEX', i);
          FND_MSG_PUB.ADD;
          IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
          END IF;
          l_valid := false;
        ELSE
          CLOSE validate_mr_id_csr;
          -- Validate the Instance Id
          OPEN validate_instance_id_csr(p_csi_instance_id => p_x_sr_mr_association_tbl(i).CSI_INSTANCE_ID);
          FETCH validate_instance_id_csr INTO p_x_sr_mr_association_tbl(i).CSI_INSTANCE_NUMBER;
          IF (validate_instance_id_csr%NOTFOUND) THEN
            CLOSE validate_instance_id_csr;
            FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_INST_ID_INVALID');
            FND_MESSAGE.Set_Token('INST_ID', p_x_sr_mr_association_tbl(i).CSI_INSTANCE_ID);
            FND_MESSAGE.Set_Token('INDEX', i);
            FND_MSG_PUB.ADD;
            IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
            END IF;
            l_valid := false;
          ELSE
            CLOSE validate_instance_id_csr;
--amsriniv. adding cursor to check if the instances on which the MRs are applicable are part of the SR Instance tree. ER 5883257
            --Validate SR-MR instance associations
            OPEN validate_sr_mr_intance_rel(c_mr_instance_id => p_x_sr_mr_association_tbl(i).CSI_INSTANCE_ID,c_sr_instance_id => p_sr_instance_id);
            FETCH validate_sr_mr_intance_rel INTO l_flag_sr_mr_inst;
            IF (validate_sr_mr_intance_rel%NOTFOUND) THEN
                CLOSE validate_sr_mr_intance_rel;
                FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_MR_DTLS_INVALID');
                FND_MESSAGE.Set_Token('TITLE', p_x_sr_mr_association_tbl(i).MR_TITLE);
                FND_MESSAGE.Set_Token('VERSION', p_x_sr_mr_association_tbl(i).MR_VERSION);
                FND_MESSAGE.Set_Token('INDEX', i);
                FND_MSG_PUB.ADD;
                IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
                END IF;
                l_valid := false;
            ELSE
                CLOSE validate_sr_mr_intance_rel;
            --amsriniv
            IF (l_program_type_code <> 'MO_PROC') THEN
            -- Check MR - Instance Applicability by calling FMP API
            AHL_FMP_PVT.GET_APPLICABLE_MRS(p_api_version       => 1.0,
                                           x_return_status     => l_temp_return_status,
                                           x_msg_count         => l_temp_msg_count,
                                           x_msg_data          => l_temp_msg_data,
                                           p_item_instance_id  => p_x_sr_mr_association_tbl(i).CSI_INSTANCE_ID,
                                           p_mr_header_id      => p_x_sr_mr_association_tbl(i).MR_HEADER_ID,
                                           x_applicable_mr_tbl => l_applicable_mr_tbl);
            IF (l_temp_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_MR_DTLS_FAILED');
              FND_MESSAGE.Set_Token('INDEX', i);
              FND_MSG_PUB.ADD;
              IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
              END IF;
              l_valid := false;
            ELSE
              l_mr_applicable := false;
              IF (l_applicable_mr_tbl.COUNT > 0) THEN
                FOR j IN l_applicable_mr_tbl.FIRST .. l_applicable_mr_tbl.LAST LOOP
                  IF ((l_applicable_mr_tbl(j).MR_HEADER_ID = p_x_sr_mr_association_tbl(i).MR_HEADER_ID) AND
                      (l_applicable_mr_tbl(j).ITEM_INSTANCE_ID = p_x_sr_mr_association_tbl(i).CSI_INSTANCE_ID))THEN
                    l_mr_applicable := true;
                    EXIT;
                  END IF;  -- Applicable
                END LOOP;  -- All Applicable MRs
              END IF;  -- Table Count > 0
              IF (l_mr_applicable = false) THEN
                FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_MR_NOT_APPLCBL');
                FND_MESSAGE.Set_Token('MR_TITLE', Get_MR_Title_From_MR_Id(p_x_sr_mr_association_tbl(i).MR_HEADER_ID));
                FND_MSG_PUB.ADD;
                IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
                END IF;
                l_valid := false;
              END IF;  -- MR applicable
            END IF;  -- GET_APPLICABLE_MRS successful
            END IF; --amsriniv
          end if; -- program_type_code
          END IF;  -- Instance Id Valid
        END IF;  -- MR Header Id Valid
      END IF;  -- MR Id and Instance Id Not null
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        IF (l_valid) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Record ' || i || ' for Create operation is Valid');
        ELSE
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Record ' || i || ' for Create operation is Not valid');
        END IF;
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Record Details: MR Header ID: ' || p_x_sr_mr_association_tbl(i).MR_HEADER_ID ||
                                                                           ', CSI Instance ID: ' || p_x_sr_mr_association_tbl(i).CSI_INSTANCE_ID);
      END IF;  -- Log Statement
    END IF;  -- Valid Operation flag
  END LOOP;  -- All Association/Disassociation Records

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;
END Validate_Association_Records;

----------------------------------------
-- This Procedure deletes SR-MR associations
----------------------------------------
PROCEDURE Process_Disassociations(
   p_sr_ue_id              IN NUMBER,
   p_sr_mr_association_tbl IN SR_MR_Association_Tbl_Type) IS

  CURSOR get_relationship_id_csr(p_sr_ue_id IN NUMBER,
                                 p_mr_ue_id IN NUMBER) IS
    SELECT UE_RELATIONSHIP_ID
    FROM AHL_UE_RELATIONSHIPS
    WHERE UE_ID = p_sr_ue_id AND
          RELATED_UE_ID = p_mr_ue_id AND
          RELATIONSHIP_CODE = G_UE_PARENT_REL_CODE;

  CURSOR get_rel_dtls_csr(p_mr_ue_id IN NUMBER) IS
    SELECT UE_RELATIONSHIP_ID, RELATED_UE_ID, level
    FROM AHL_UE_RELATIONSHIPS
    START WITH UE_ID = p_mr_ue_id
    CONNECT BY PRIOR RELATED_UE_ID = UE_ID
    ORDER BY LEVEL DESC;  /* Bottom Up */

  l_relationship_id NUMBER;
  l_temp_rel_id     NUMBER;
  l_temp_ue_id      NUMBER;
  l_temp_level      NUMBER;

  L_DEBUG_KEY CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Process_Disassociations';

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  FOR i in p_sr_mr_association_tbl.FIRST .. p_sr_mr_association_tbl.LAST LOOP
    IF (p_sr_mr_association_tbl(i).OPERATION_FLAG = G_OPR_DELETE) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'About to Disassociate Record with index ' || i);
      END IF;
      OPEN get_relationship_id_csr(p_sr_ue_id => p_sr_ue_id,
                                   p_mr_ue_id => p_sr_mr_association_tbl(i).UNIT_EFFECTIVITY_ID);
      FETCH get_relationship_id_csr INTO l_relationship_id;
      CLOSE get_relationship_id_csr;

      -- Delete the Dependents (If Group MR)
      FOR l_rel_dtls_rec IN get_rel_dtls_csr(p_sr_mr_association_tbl(i).UNIT_EFFECTIVITY_ID) LOOP
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'About to Delete Relationship with RELATIONSHIP_ID = ' || l_rel_dtls_rec.UE_RELATIONSHIP_ID || ' for a Group MR');
        END IF;
        AHL_UE_RELATIONSHIPS_PKG.DELETE_ROW(X_UE_RELATIONSHIP_ID => l_rel_dtls_rec.UE_RELATIONSHIP_ID);

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'About to Delete Unit Effectivity with UNIT_EFFECTIVITY_ID = ' || l_rel_dtls_rec.RELATED_UE_ID || ' for a Group MR');
        END IF;
        AHL_UNIT_EFFECTIVITIES_PKG.DELETE_ROW(X_UNIT_EFFECTIVITY_ID => l_rel_dtls_rec.RELATED_UE_ID);
      END LOOP;
      -- Delete the MR Relationship and UE
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'About to Delete Relationship with RELATIONSHIP_ID = ' || l_relationship_id);
      END IF;
      AHL_UE_RELATIONSHIPS_PKG.DELETE_ROW(X_UE_RELATIONSHIP_ID => l_relationship_id);

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'About to Delete Unit Effectivity with UNIT_EFFECTIVITY_ID = ' || p_sr_mr_association_tbl(i).UNIT_EFFECTIVITY_ID);
      END IF;
      AHL_UNIT_EFFECTIVITIES_PKG.DELETE_ROW(X_UNIT_EFFECTIVITY_ID => p_sr_mr_association_tbl(i).UNIT_EFFECTIVITY_ID);

    END IF;  -- Disassociation Record
  END LOOP;  -- All Association/Disassociation Records

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;
END Process_Disassociations;

----------------------------------------
-- This Procedure Creates New SR-MR associations
----------------------------------------
PROCEDURE Process_New_Associations(
   p_sr_ue_id                IN            NUMBER,
   p_sr_instance_id          IN            NUMBER,
   p_sr_exp_resol_date       IN            DATE,
   p_user_id                 IN            NUMBER,
   p_login_id                IN            NUMBER,
   p_x_sr_mr_association_tbl IN OUT NOCOPY SR_MR_Association_Tbl_Type) IS

  CURSOR get_dup_mrs_csr(p_mr_id       IN NUMBER,
                         p_instance_id IN NUMBER,
                         p_sr_ue_id    IN NUMBER) IS
    SELECT 'x' from AHL_UNIT_EFFECTIVITIES_B ue
    WHERE ue.mr_header_id = p_mr_id AND
          ue.csi_item_instance_id = p_instance_id AND
          EXISTS (SELECT 'x' FROM ahl_ue_relationships ur
                  WHERE ur.related_ue_id = ue.unit_effectivity_id
                  START WITH ur.ue_id = p_sr_ue_id
                  CONNECT BY PRIOR ur.related_ue_id = ur.ue_id);

  -- Cursor added for ER # 6123671.
  -- Start changes for ER -- 6123671
  CURSOR c_get_origin_wo_id(p_sr_ue_id    IN NUMBER)
  IS
  SELECT
    ORIGINATING_WO_ID
  FROM
    AHL_UNIT_EFFECTIVITIES_B
  WHERE
    UNIT_EFFECTIVITY_ID = p_sr_ue_id
    AND OBJECT_TYPE = 'SR';

  l_origin_wo_id NUMBER;
  -- End changes for ER -- 6123671

  CURSOR get_num_descendents_csr(p_mr_id IN NUMBER) IS
    SELECT COUNT(*) from AHL_MR_RELATIONSHIPS
    WHERE MR_HEADER_ID = p_mr_id;

  l_temp_level     NUMBER;
  l_dummy          VARCHAR2(1);
  l_valid_flag     BOOLEAN := true;
  l_mr_ue_id       NUMBER;
  l_mr_rel_id      NUMBER;
  l_temp_count     NUMBER;

  L_DEBUG_KEY CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Process_New_Associations';

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  FOR i in p_x_sr_mr_association_tbl.FIRST .. p_x_sr_mr_association_tbl.LAST LOOP
    IF (p_x_sr_mr_association_tbl(i).OPERATION_FLAG = G_OPR_CREATE) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Record ' || i || ' is a Create Record. Checking for Duplicates first.');
      END IF;
      -- Check for duplicates
      OPEN get_dup_mrs_csr(p_mr_id       => p_x_sr_mr_association_tbl(i).MR_HEADER_ID,
                           p_instance_id => p_x_sr_mr_association_tbl(i).CSI_INSTANCE_ID,
                           p_sr_ue_id    => p_sr_ue_id);
      FETCH get_dup_mrs_csr INTO l_dummy;
      IF (get_dup_mrs_csr%FOUND) THEN
        l_valid_flag := false;
        CLOSE get_dup_mrs_csr;
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Record ' || i || ' with MR Id ' ||
                                                                p_x_sr_mr_association_tbl(i).MR_HEADER_ID || ' and Instance Id ' ||
                                                                p_x_sr_mr_association_tbl(i).CSI_INSTANCE_ID || ' is  a Duplicate.');
        END IF;
        FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_DUPLICATE_MR');
        FND_MESSAGE.Set_Token('MR_TITLE', Get_MR_Title_From_MR_Id(p_x_sr_mr_association_tbl(i).MR_HEADER_ID));
        FND_MSG_PUB.ADD;
        IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
        END IF;
      ELSE
        CLOSE get_dup_mrs_csr;
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Record ' || i || ' is not a Duplicate. About to create MR UE and UE Relationship.');
        END IF;

        Create_MR_Unit_Effectivity(p_instance_id  => p_x_sr_mr_association_tbl(i).CSI_INSTANCE_ID,
                                   p_due_date     => p_sr_exp_resol_date,
                                   p_mr_header_id => p_x_sr_mr_association_tbl(i).MR_HEADER_ID,
                                   p_user_id      => p_user_id,
                                   p_login_id     => p_login_id,
                                   x_ue_id        => l_mr_ue_id);

        Create_UE_Relationship(p_ue_id             => p_sr_ue_id,
                               p_related_ue_id     => l_mr_ue_id,
                               p_relationship_code => G_UE_PARENT_REL_CODE,
                               p_originator_id     => p_sr_ue_id,
                               p_user_id           => p_user_id,
                               p_login_id          => p_login_id,
                               x_ue_rel_id         => l_mr_rel_id);

        p_x_sr_mr_association_tbl(i).UNIT_EFFECTIVITY_ID := l_mr_ue_id;
        p_x_sr_mr_association_tbl(i).OBJECT_VERSION_NUMBER := 1;
        p_x_sr_mr_association_tbl(i).UE_RELATIONSHIP_ID := l_mr_rel_id;

        OPEN get_num_descendents_csr(p_x_sr_mr_association_tbl(i).MR_HEADER_ID);
        FETCH get_num_descendents_csr INTO l_temp_count;
        CLOSE get_num_descendents_csr;

        IF(l_valid_flag = true AND l_temp_count > 0) THEN
          -- Process Group MR
          Process_Group_MR(p_mr_header_id    => p_x_sr_mr_association_tbl(i).MR_HEADER_ID,
                           p_csi_instance_id => p_x_sr_mr_association_tbl(i).CSI_INSTANCE_ID,
                           p_mr_ue_id        => l_mr_ue_id,
                           p_sr_ue_id        => p_sr_ue_id,
                           p_due_date        => p_sr_exp_resol_date,
                           p_user_id         => p_user_id,
                           p_login_id        => p_login_id,
                           p_x_valid_flag    => l_valid_flag);

        END IF;
      END IF;  -- Duplicate MR Check
    ELSE
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Record ' || i || ' is not a Create Record. Skipping.');
      END IF;
    END IF;  -- New Association Record
  END LOOP;  -- All Association/Disassociation Records

  -- Balaji added the code for ER # 6123671
  -- UEs corresponding to new MRs added to the SR need to inherit the
  -- Originating Work Order Id of the SR UE. This code need to be here because
  -- MRs can be added independent of Production Non Routine API.
  -- Start Changes ER # 6123671
  OPEN c_get_origin_wo_id(p_sr_ue_id);
  FETCH c_get_origin_wo_id INTO l_origin_wo_id;
  CLOSE c_get_origin_wo_id;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(
                   FND_LOG.LEVEL_STATEMENT,
                   L_DEBUG_KEY,
                   'Before updating Originating Work Order Id');
     FND_LOG.STRING(
                   FND_LOG.LEVEL_STATEMENT,
                   L_DEBUG_KEY,
                   'p_sr_ue_id->'||p_sr_ue_id||' , '||'SR origin_wo_id->'||l_origin_wo_id);
  END IF;

  IF p_sr_ue_id IS NOT NULL AND l_origin_wo_id IS NOT NULL
  THEN
      BEGIN
	  UPDATE
	     AHL_UNIT_EFFECTIVITIES_B
	  SET
	     ORIGINATING_WO_ID = l_origin_wo_id
	  WHERE
	     UNIT_EFFECTIVITY_ID IN (
				     SELECT
					 RELATED_UE_ID
				     FROM
					 AHL_UE_RELATIONSHIPS
				     WHERE
					 ORIGINATOR_UE_ID = p_sr_ue_id
				    )
             AND ORIGINATING_WO_ID IS NULL;

      EXCEPTION

        WHEN OTHERS THEN
          FND_MESSAGE.SET_NAME ('AHL','AHL_PRD_ORIGINWO_UPD_FAILED');
          Fnd_Msg_Pub.ADD;
      END;
  END IF;
  -- End Changes ER # 6123671

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;
END Process_New_Associations;

----------------------------------------
-- This Procedure Gets the Unit Effectivity Id
----------------------------------------
PROCEDURE Get_MR_UnitEffectivity(
   p_sr_ue_id                IN     NUMBER,
   p_x_sr_mr_association_rec IN OUT NOCOPY SR_MR_Association_Rec_Type) IS

  CURSOR get_ue_id_csr(p_mr_title            IN VARCHAR2,
                       p_mr_version          IN NUMBER,
                       p_mr_header_id        IN NUMBER,
                       p_csi_instance_number IN VARCHAR2,
                       p_csi_instance_id     IN NUMBER,
                       p_sr_ue_id            IN NUMBER) IS
/* AMSRINIV : Bug 5208411 : Below Query Tuned */

/*    SELECT UE.UNIT_EFFECTIVITY_ID
    FROM AHL_UNIT_EFFECTIVITIES_APP_V UE
    WHERE UE.MR_HEADER_ID = (SELECT MR_HEADER_ID FROM AHL_MR_HEADERS_APP_V
                             WHERE MR_HEADER_ID like DECODE(p_mr_header_id, null, '%', p_mr_header_id) AND
                                   TITLE like DECODE(p_mr_header_id, null, p_mr_title, '%') AND
                                  VERSION_NUMBER like DECODE(p_mr_header_id, null, p_mr_version, '%')) AND
                                   VERSION_NUMBER like DECODE(p_mr_header_id, null, '' || p_mr_version || '', '%')) AND
          UE.CSI_ITEM_INSTANCE_ID = (SELECT INSTANCE_ID FROM CSI_ITEM_INSTANCES
                                     WHERE INSTANCE_ID like DECODE(p_csi_instance_id, null, '%', p_csi_instance_id) AND
                                           INSTANCE_NUMBER like DECODE(p_csi_instance_id, null, p_csi_instance_number, '%')) AND
          EXISTS (SELECT 'x' FROM AHL_UE_RELATIONSHIPS
                  WHERE UE_ID = p_sr_ue_id AND
                        RELATED_UE_ID = UE.UNIT_EFFECTIVITY_ID AND
                        RELATIONSHIP_CODE = G_UE_PARENT_REL_CODE);*/

/* AMSRINIV : Bug 5208411 : Tuned query */
            SELECT  UE.UNIT_EFFECTIVITY_ID
            FROM    AHL_UNIT_EFFECTIVITIES_APP_V UE
            WHERE   UE.MR_HEADER_ID =
                    (SELECT MR_HEADER_ID
                    FROM    AHL_MR_HEADERS_APP_V
                    WHERE   MR_HEADER_ID = NVL(p_mr_header_id,MR_HEADER_ID)
                            AND TITLE like DECODE(p_mr_header_id, null, p_mr_title, '%')
                            AND VERSION_NUMBER like DECODE(p_mr_header_id, null, '' || p_mr_version || '', '%')
                    )
                    AND UE.CSI_ITEM_INSTANCE_ID =
                    (SELECT INSTANCE_ID
                    FROM    CSI_ITEM_INSTANCES
                    WHERE   INSTANCE_ID = NVL(p_csi_instance_id,INSTANCE_ID)
                            AND INSTANCE_NUMBER like DECODE(p_csi_instance_id, null, p_csi_instance_number, '%')
                    )
                    AND EXISTS
                    (SELECT 'x'
                    FROM    AHL_UE_RELATIONSHIPS
                    WHERE   UE_ID                 = p_sr_ue_id
                            AND RELATED_UE_ID     = UE.UNIT_EFFECTIVITY_ID
                            AND RELATIONSHIP_CODE = G_UE_PARENT_REL_CODE
                    );

  L_DEBUG_KEY CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Get_MR_UnitEffectivity';
  l_get_ue_flag  BOOLEAN := true;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  IF(p_x_sr_mr_association_rec.UNIT_EFFECTIVITY_ID IS NOT NULL) THEN
    l_get_ue_flag := false;  -- No need to get the UE Id: It is already available
  END IF;

  IF((p_x_sr_mr_association_rec.MR_HEADER_ID IS NULL AND p_x_sr_mr_association_rec.MR_TITLE IS NULL) OR
     (p_x_sr_mr_association_rec.MR_HEADER_ID IS NULL AND p_x_sr_mr_association_rec.MR_VERSION IS NULL) OR
     (p_x_sr_mr_association_rec.CSI_INSTANCE_ID IS NULL AND p_x_sr_mr_association_rec.CSI_INSTANCE_NUMBER IS NULL)) THEN
    l_get_ue_flag := false;  -- No need to get the UE Id: There is insufficient info to derive it
  END IF;

  IF(l_get_ue_flag = true) THEN
    OPEN get_ue_id_csr(p_mr_title            => p_x_sr_mr_association_rec.MR_TITLE,
                       p_mr_version          => p_x_sr_mr_association_rec.MR_VERSION,
                       p_mr_header_id        => p_x_sr_mr_association_rec.MR_HEADER_ID,
                       p_csi_instance_number => p_x_sr_mr_association_rec.CSI_INSTANCE_NUMBER,
                       p_csi_instance_id     => p_x_sr_mr_association_rec.CSI_INSTANCE_ID,
                       p_sr_ue_id            => p_sr_ue_id);
    FETCH get_ue_id_csr INTO p_x_sr_mr_association_rec.UNIT_EFFECTIVITY_ID;
    CLOSE get_ue_id_csr;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;
END Get_MR_UnitEffectivity;

----------------------------------------
-- This Procedure does Value to Id Conversion for New Associations
-- It derives the MR Header Id and the CSI Instance Id
----------------------------------------
PROCEDURE Get_New_Asso_Val_To_Id(
   p_x_sr_mr_association_rec IN OUT NOCOPY SR_MR_Association_Rec_Type) IS

  CURSOR get_mr_id_csr(p_mr_title IN VARCHAR2,
                       p_mr_version IN NUMBER) IS
    SELECT MR_HEADER_ID
    FROM AHL_MR_HEADERS_APP_V
    WHERE UPPER(TITLE) = UPPER(p_mr_title) AND
          VERSION_NUMBER = p_mr_version;

  CURSOR get_csi_instance_id_csr(p_csi_instance_number IN VARCHAR2) IS
    SELECT INSTANCE_ID
    FROM CSI_ITEM_INSTANCES
    WHERE INSTANCE_NUMBER = p_csi_instance_number;

  L_DEBUG_KEY CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Get_New_Asso_Val_To_Id';
  l_get_mr_flag  BOOLEAN := true;
  l_get_inst_flag  BOOLEAN := true;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  IF (p_x_sr_mr_association_rec.MR_HEADER_ID IS NOT NULL) THEN
    l_get_mr_flag := false;  -- No need to get the MR Id: It is already available
  END IF;

  IF ((p_x_sr_mr_association_rec.MR_HEADER_ID IS NULL AND p_x_sr_mr_association_rec.MR_TITLE IS NULL) OR
     (p_x_sr_mr_association_rec.MR_HEADER_ID IS NULL AND p_x_sr_mr_association_rec.MR_VERSION IS NULL)) THEN
    l_get_mr_flag := false;  -- No need to get the MR Id: There is insufficient info to derive it
  END IF;

  IF (l_get_mr_flag = true) THEN
    OPEN get_mr_id_csr(p_mr_title   => p_x_sr_mr_association_rec.MR_TITLE,
                       p_mr_version => p_x_sr_mr_association_rec.MR_VERSION);
    FETCH get_mr_id_csr INTO p_x_sr_mr_association_rec.MR_HEADER_ID;
    CLOSE get_mr_id_csr;
  END IF;

  IF (p_x_sr_mr_association_rec.CSI_INSTANCE_ID IS NOT NULL) THEN
    l_get_inst_flag := false;  -- No need to get the Instance Id: It is already available
  END IF;

  IF (p_x_sr_mr_association_rec.CSI_INSTANCE_ID IS NULL AND p_x_sr_mr_association_rec.CSI_INSTANCE_NUMBER IS NULL) THEN
    l_get_inst_flag := false;  -- No need to get the Instance Id: There is insufficient info to derive it
  END IF;

  IF (l_get_inst_flag = true) THEN
    OPEN get_csi_instance_id_csr(p_csi_instance_number => p_x_sr_mr_association_rec.CSI_INSTANCE_NUMBER);
    FETCH get_csi_instance_id_csr INTO p_x_sr_mr_association_rec.CSI_INSTANCE_ID;
    CLOSE get_csi_instance_id_csr;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;
END Get_New_Asso_Val_To_Id;

----------------------------------------
-- This Procedure creates a new unit effectivity
-- It returns the id of the newly created UE
----------------------------------------
PROCEDURE Create_MR_Unit_Effectivity(
   p_instance_id  IN NUMBER,
   p_due_date     IN DATE,
   p_mr_header_id IN NUMBER,
   p_user_id      IN NUMBER,
   p_login_id     IN NUMBER,
   x_ue_id        OUT NOCOPY NUMBER) IS

  l_temp_row_id        VARCHAR2(30);
  L_DEBUG_KEY CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Create_MR_Unit_Effectivity';

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  AHL_UNIT_EFFECTIVITIES_PKG.Insert_Row (
        X_ROWID                 => l_temp_row_id,
        X_UNIT_EFFECTIVITY_ID   => x_ue_id,
        X_MANUALLY_PLANNED_FLAG => 'Y',
        X_LOG_SERIES_CODE       => null,
        X_LOG_SERIES_NUMBER     => null,
        X_FLIGHT_NUMBER         => null,
        X_MEL_CDL_TYPE_CODE     => null,
        X_POSITION_PATH_ID      => null,
        X_ATA_CODE              => null,
        --X_CLEAR_STATION_ORG_ID  => null,
        --X_CLEAR_STATION_DEPT_ID => null,
        X_UNIT_CONFIG_HEADER_ID => null,
        X_QA_COLLECTION_ID      => null,
        X_CS_INCIDENT_ID        => null,
        X_OBJECT_TYPE           => G_UE_MR_OBJECT_TYPE,
        X_APPLICATION_USG_CODE  => G_APP_MODULE,
        X_COUNTER_ID            => null,
        X_EARLIEST_DUE_DATE     => null,
        X_LATEST_DUE_DATE       => null,
        X_FORECAST_SEQUENCE     => null,
        X_REPETITIVE_MR_FLAG    => null,
        X_TOLERANCE_FLAG        => null,
        X_MESSAGE_CODE          => null,
        X_DATE_RUN              => null,
        X_PRECEDING_UE_ID       => null,
        X_SET_DUE_DATE          => null,
        X_ACCOMPLISHED_DATE     => null,
        X_SERVICE_LINE_ID       => null,
        X_PROGRAM_MR_HEADER_ID  => null,
        X_CANCEL_REASON_CODE    => null,
        X_ATTRIBUTE_CATEGORY    => null,
        X_ATTRIBUTE1            => null,
        X_ATTRIBUTE2            => null,
        X_ATTRIBUTE3            => null,
        X_ATTRIBUTE4            => null,
        X_ATTRIBUTE5            => null,
        X_ATTRIBUTE6            => null,
        X_ATTRIBUTE7            => null,
        X_ATTRIBUTE8            => null,
        X_ATTRIBUTE9            => null,
        X_ATTRIBUTE10           => null,
        X_ATTRIBUTE11           => null,
        X_ATTRIBUTE12           => null,
        X_ATTRIBUTE13           => null,
        X_ATTRIBUTE14           => null,
        X_ATTRIBUTE15           => null,
        X_OBJECT_VERSION_NUMBER => 1,
        X_CSI_ITEM_INSTANCE_ID  => p_instance_id,
        X_MR_HEADER_ID          => p_mr_header_id,
        X_MR_EFFECTIVITY_ID     => null,
        X_MR_INTERVAL_ID        => null,
        X_STATUS_CODE           => null,
        X_DUE_DATE              => p_due_date,
        X_DUE_COUNTER_VALUE     => null,
        X_DEFER_FROM_UE_ID      => null,
        X_ORIG_DEFERRAL_UE_ID   => null,
        X_REMARKS               => null,
        X_CREATION_DATE         => sysdate,
        X_CREATED_BY            => fnd_global.user_id,
        X_LAST_UPDATE_DATE      => sysdate,
        X_LAST_UPDATED_BY       => fnd_global.user_id,
        X_LAST_UPDATE_LOGIN     => fnd_global.login_id );

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Created New UE with Id ' || x_ue_id);
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;
END Create_MR_Unit_Effectivity;

----------------------------------------
-- This Procedure creates a new UE Relationship
-- It returns the id of the newly created Relationship
----------------------------------------
PROCEDURE Create_UE_Relationship(
   p_ue_id             IN  NUMBER,
   p_related_ue_id     IN  NUMBER,
   p_relationship_code IN  VARCHAR2,
   p_originator_id     IN  NUMBER,
   p_user_id           IN  NUMBER,
   p_login_id          IN  NUMBER,
   x_ue_rel_id         OUT NOCOPY NUMBER) IS

  L_DEBUG_KEY CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Create_UE_Relationship';

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  AHL_UE_RELATIONSHIPS_PKG.INSERT_ROW(
   X_UE_RELATIONSHIP_ID    => x_ue_rel_id,
   X_UE_ID                 => p_ue_id,
   X_RELATED_UE_ID         => p_related_ue_id,
   X_RELATIONSHIP_CODE     => p_relationship_code,
   X_ORIGINATOR_UE_ID      => p_originator_id,
   X_ATTRIBUTE_CATEGORY    => null,
   X_ATTRIBUTE1            => null,
   X_ATTRIBUTE2            => null,
   X_ATTRIBUTE3            => null,
   X_ATTRIBUTE4            => null,
   X_ATTRIBUTE5            => null,
   X_ATTRIBUTE6            => null,
   X_ATTRIBUTE7            => null,
   X_ATTRIBUTE8            => null,
   X_ATTRIBUTE9            => null,
   X_ATTRIBUTE10           => null,
   X_ATTRIBUTE11           => null,
   X_ATTRIBUTE12           => null,
   X_ATTRIBUTE13           => null,
   X_ATTRIBUTE14           => null,
   X_ATTRIBUTE15           => null,
   X_OBJECT_VERSION_NUMBER => 1,
   X_LAST_UPDATE_DATE      => SYSDATE,
   X_LAST_UPDATED_BY       => p_user_id,
   X_CREATION_DATE         => SYSDATE,
   X_CREATED_BY            => p_user_id,
   X_LAST_UPDATE_LOGIN     => p_login_id);

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Created New UE Relationship with Id ' || x_ue_rel_id);
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;
END Create_UE_Relationship;

----------------------------------------
-- This Procedure processes group MRs
-- It creates a hierarchy of unit effectivities and UE relationships
-- If any descendent MR is already present for the SR, the p_x_valid_flag
-- is set to false and the error message is added to the stack.
----------------------------------------
PROCEDURE Process_Group_MR(
   p_mr_header_id     IN      NUMBER,
   p_csi_instance_id  IN      NUMBER,
   p_mr_ue_id         IN      NUMBER,
   p_sr_ue_id         IN      NUMBER,
   p_due_date         IN      DATE,
   p_user_id          IN      NUMBER,
   p_login_id         IN      NUMBER,
   p_x_valid_flag     IN OUT NOCOPY BOOLEAN) IS

  CURSOR get_duplicate_mrs_csr(p_sr_ue_id IN NUMBER) IS
    SELECT UE.MR_HEADER_ID, UE.CSI_ITEM_INSTANCE_ID
    FROM AHL_UNIT_EFFECTIVITIES_B UE, AHL_UE_RELATIONSHIPS UR
    WHERE UR.ORIGINATOR_UE_ID = p_sr_ue_id AND
          UR.RELATIONSHIP_CODE = G_UE_PARENT_REL_CODE AND
          UE.UNIT_EFFECTIVITY_ID = UR.RELATED_UE_ID
    INTERSECT
    SELECT RELATED_MR_HEADER_ID, RELATED_CSI_ITEM_INSTANCE_ID
    FROM AHL_APPLICABLE_MR_RELNS;

  CURSOR mr_relns_upd_csr IS
    SELECT * FROM AHL_APPLICABLE_MR_RELNS
    FOR UPDATE OF UE_ID;

  CURSOR get_mr_reln_dtls_csr(p_mr_ue_id        IN NUMBER,
                              p_mr_header_id    IN NUMBER,
                              p_csi_instance_id IN NUMBER) IS
    SELECT child.ue_id child_ue_id, NVL(parent.ue_id, p_mr_ue_id) parent_ue_id, child.relationship_code
    FROM AHL_APPLICABLE_MR_RELNS child, AHL_APPLICABLE_MR_RELNS parent
    WHERE child.ORIG_MR_HEADER_ID = p_mr_header_id AND  -- Filter condition
          child.ORIG_CSI_ITEM_INSTANCE_ID = p_csi_instance_id AND  -- Filter condition
          parent.RELATED_MR_HEADER_ID (+) = child.MR_HEADER_ID AND  -- Join condition
          parent.RELATED_CSI_ITEM_INSTANCE_ID (+) = child.CSI_ITEM_INSTANCE_ID;  -- Join condition

  CURSOR get_app_mr_table_count_csr IS
    SELECT count(*) from AHL_APPLICABLE_MRS;

  /*CURSOR get_relns_table_count_csr IS
    SELECT count(*) from AHL_APPLICABLE_MR_RELNS;*/


  l_duplicate_mr_id    NUMBER;
  l_dup_mr_title       AHL_MR_HEADERS_B.TITLE%TYPE;
  l_curr_mr_title      AHL_MR_HEADERS_B.TITLE%TYPE;
  l_duplicate_inst_id  NUMBER;
  l_new_ue_id          NUMBER;
  l_new_rel_id         NUMBER;
  l_temp_count         NUMBER := 0;
  l_temp_return_status VARCHAR2(1);
  l_temp_msg_count     NUMBER;
  l_temp_msg_data      VARCHAR2(2000);

  L_DEBUG_KEY CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Process_Group_MR';

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Processing Group MR with Id: ' || p_mr_header_id);
  END IF;

  -- Evaluate Group MRs
  -- Populate AHL_APPLICABLE_MRS if required
  OPEN get_app_mr_table_count_csr;
  FETCH get_app_mr_table_count_csr INTO l_temp_count;
  CLOSE get_app_mr_table_count_csr;
  IF (l_temp_count > 0) THEN
    -- AHL_APPLICABLE_MRS is already populated. No need to Call Populate_Appl_MRs
    IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_EVENT, L_DEBUG_KEY, 'Number of records in AHL_APPLICABLE_MRS: ' || l_temp_count || '. Not calling AHL_UMP_UTIL_PKG.Populate_Appl_MRs.');
    END IF;
  ELSE
    IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_EVENT, L_DEBUG_KEY, 'Number of records in AHL_APPLICABLE_MRS is zero. Calling AHL_UMP_UTIL_PKG.Populate_Appl_MRs with p_csi_ii_id = ' || p_csi_instance_id);
    END IF;
    AHL_UMP_UTIL_PKG.Populate_Appl_MRs(p_csi_ii_id     => p_csi_instance_id,
                                       x_return_status => l_temp_return_status,
                                       x_msg_count     => l_temp_msg_count,
                                       x_msg_data      => l_temp_msg_data);
    IF NOT (l_temp_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      p_x_valid_flag := false;
      l_curr_mr_title := Get_MR_Title_From_MR_Id(p_mr_header_id);
      FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_GRP_MR_FAILED');
      FND_MESSAGE.Set_Token('MR_TITLE', l_curr_mr_title);
      FND_MSG_PUB.ADD;
      IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
      END IF;
      RETURN;  -- No need to process this Group MR further
    END IF;  -- Populate_Appl_MRs Failed
    OPEN get_app_mr_table_count_csr;
    FETCH get_app_mr_table_count_csr INTO l_temp_count;
    CLOSE get_app_mr_table_count_csr;
    IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_EVENT, L_DEBUG_KEY, 'After calling AHL_UMP_UTIL_PKG.Populate_Appl_MRs, Number of records in AHL_APPLICABLE_MRS: ' || l_temp_count);
    END IF;
  END IF;  -- AHL_APPLICABLE_MRS temp table is empty

  -- Call process_Group_MR_Instance
  /*OPEN get_relns_table_count_csr;
  FETCH get_relns_table_count_csr INTO l_temp_count;
  CLOSE get_relns_table_count_csr;
  IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_EVENT, L_DEBUG_KEY, 'Number of records in AHL_APPLICABLE_MR_RELNS before processing: ' || l_temp_count);
    FND_LOG.STRING(FND_LOG.LEVEL_EVENT, L_DEBUG_KEY, 'About to call AHL_UMP_UTIL_PKG.process_Group_MR_Instance with p_top_mr_id = ' ||
                                                      p_mr_header_id || ' and p_top_item_instance_id = ' || p_csi_instance_id);
  END IF;*/
  AHL_UMP_UTIL_PKG.process_Group_MR_Instance(p_top_mr_id            => p_mr_header_id,
                                             p_top_item_instance_id => p_csi_instance_id,
                                             p_init_temp_table      => G_YES_FLAG);  -- To clean up temp table first
  /*OPEN get_relns_table_count_csr;
  FETCH get_relns_table_count_csr INTO l_temp_count;
  CLOSE get_relns_table_count_csr;
  IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_EVENT, L_DEBUG_KEY, 'Number of records in AHL_APPLICABLE_MR_RELNS after calling AHL_UMP_UTIL_PKG.process_Group_MR_Instance: ' || l_temp_count);
  END IF;*/

  -- Check for duplicates
  OPEN get_duplicate_mrs_csr(p_sr_ue_id => p_sr_ue_id);
  FETCH get_duplicate_mrs_csr INTO l_duplicate_mr_id, l_duplicate_inst_id;
  IF(get_duplicate_mrs_csr%FOUND) THEN
    -- At least one duplicate found
    CLOSE get_duplicate_mrs_csr;
    l_dup_mr_title := Get_MR_Title_From_MR_Id(l_duplicate_mr_id);
    l_curr_mr_title := Get_MR_Title_From_MR_Id(p_mr_header_id);
    FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_GROUP_DUP_MR');
    FND_MESSAGE.Set_Token('NEW_MR', l_curr_mr_title);
    FND_MESSAGE.Set_Token('DUP_MR', l_dup_mr_title);
    FND_MSG_PUB.ADD;
    IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
    END IF;
    p_x_valid_flag := false;
    RETURN;  -- No need to process this Group MR further
  END IF;
  CLOSE get_duplicate_mrs_csr;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Adding this Group MR will not cause any duplicates.');
  END IF;

  -- First create all the Unit Effectivities
  l_temp_count := 0;
  FOR mr_rel_rec IN mr_relns_upd_csr LOOP
    -- Create the new Unit Effectivity Record
    Create_MR_Unit_Effectivity(p_instance_id  => mr_rel_rec.RELATED_CSI_ITEM_INSTANCE_ID,
                               p_due_date     => p_due_date,
                               p_mr_header_id => mr_rel_rec.RELATED_MR_HEADER_ID,
                               p_user_id      => p_user_id,
                               p_login_id     => p_login_id,
                               x_ue_id        => l_new_ue_id);

    l_temp_count := l_temp_count + 1;
    -- Update AHL_APPLICABLE_MR_RELNS with the new UE Id
    UPDATE AHL_APPLICABLE_MR_RELNS
    SET UE_ID = l_new_ue_id
    WHERE CURRENT OF mr_relns_upd_csr;
  END LOOP;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Created ' || l_temp_count || ' Unit Effectivities for the Group MR.');
  END IF;

  -- Next, Create the UE Relationships
  l_temp_count := 0;
  FOR rel_dtls_rec IN get_mr_reln_dtls_csr(p_mr_ue_id        => p_mr_ue_id,
                                           p_mr_header_id    => p_mr_header_id,
                                           p_csi_instance_id => p_csi_instance_id) LOOP

    Create_UE_Relationship(p_ue_id             => rel_dtls_rec.parent_ue_id,
                           p_related_ue_id     => rel_dtls_rec.child_ue_id,
                           p_relationship_code => rel_dtls_rec.relationship_code,
                           p_originator_id     => p_sr_ue_id,
                           p_user_id           => p_user_id,
                           p_login_id          => p_login_id,
                           x_ue_rel_id         => l_new_rel_id);

    l_temp_count := l_temp_count + 1;

  END LOOP;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Created ' || l_temp_count || ' UE Relationships for the Group MR.');
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;
END Process_Group_MR;

----------------------------------------
-- This Function gets the MR Title from the MR Header Id
----------------------------------------
FUNCTION Get_MR_Title_From_MR_Id(p_mr_header_id IN NUMBER)
RETURN VARCHAR2 IS

  CURSOR get_mr_title_csr IS
    SELECT TITLE
    FROM AHL_MR_HEADERS_B
    WHERE MR_HEADER_ID = p_mr_header_id;

  l_mr_title AHL_MR_HEADERS_B.TITLE%TYPE := null;

BEGIN
  OPEN get_mr_title_csr;
  FETCH get_mr_title_csr INTO l_mr_title;
  CLOSE get_mr_title_csr;
  RETURN l_mr_title;
END Get_MR_Title_From_MR_Id;

----------------------------------------
-- This Function gets the MR Title from the Unit Effectivity Id
----------------------------------------
FUNCTION Get_MR_Title_From_UE_Id(p_unit_effectivity_id IN NUMBER)
RETURN VARCHAR2 IS

  CURSOR get_mr_title_csr IS
    SELECT MR.TITLE
    FROM AHL_MR_HEADERS_B MR, AHL_UNIT_EFFECTIVITIES_APP_V UE
    WHERE UE.UNIT_EFFECTIVITY_ID = p_unit_effectivity_id AND
          UE.MR_HEADER_ID = MR.MR_HEADER_ID;

  l_mr_title AHL_MR_HEADERS_B.TITLE%TYPE := null;

BEGIN
  OPEN get_mr_title_csr;
  FETCH get_mr_title_csr INTO l_mr_title;
  CLOSE get_mr_title_csr;
  RETURN l_mr_title;
END Get_MR_Title_From_UE_Id;

----------------------------------------
-- This Procedure updates the due date and tolerance exceeded flag of UEs
-- of the MRs associated to the SR in response to change in Exp. Resolution Date of the SR
----------------------------------------
PROCEDURE Handle_MR_UE_Date_Change(
   p_sr_ue_id               IN NUMBER,
   p_assigned_to_visit_flag IN BOOLEAN,
   p_new_tolerance_flag     IN VARCHAR2,
   p_new_due_date           IN DATE) IS

  CURSOR get_MR_UEs_csr IS
    SELECT * FROM AHL_UNIT_EFFECTIVITIES_APP_V
    WHERE UNIT_EFFECTIVITY_ID IN (SELECT RELATED_UE_ID from AHL_UE_RELATIONSHIPS
                                  WHERE ORIGINATOR_UE_ID = p_sr_ue_id
                                    AND RELATIONSHIP_CODE = G_UE_PARENT_REL_CODE);

  L_DEBUG_KEY CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Handle_MR_UE_Date_Change';

  l_temp_tolerance_flag AHL_UNIT_EFFECTIVITIES_B.TOLERANCE_FLAG%TYPE;
  l_temp_count NUMBER := 0;


BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  FOR l_curr_ue_rec in get_MR_UEs_csr LOOP
    IF (p_assigned_to_visit_flag = TRUE) THEN
      l_temp_tolerance_flag := p_new_tolerance_flag;
    ELSE
      l_temp_tolerance_flag := l_curr_ue_rec.TOLERANCE_FLAG;
    END IF;
    -- Update the unit effectivity
    AHL_UNIT_EFFECTIVITIES_PKG.UPDATE_ROW(
        X_UNIT_EFFECTIVITY_ID   => l_curr_ue_rec.UNIT_EFFECTIVITY_ID,
        X_MANUALLY_PLANNED_FLAG => l_curr_ue_rec.MANUALLY_PLANNED_FLAG,
        X_LOG_SERIES_CODE       => l_curr_ue_rec.LOG_SERIES_CODE,
        X_LOG_SERIES_NUMBER     => l_curr_ue_rec.LOG_SERIES_NUMBER,
        X_FLIGHT_NUMBER         => l_curr_ue_rec.FLIGHT_NUMBER,
        X_MEL_CDL_TYPE_CODE     => l_curr_ue_rec.MEL_CDL_TYPE_CODE,
        X_POSITION_PATH_ID      => l_curr_ue_rec.POSITION_PATH_ID,
        X_ATA_CODE              => l_curr_ue_rec.ATA_CODE,
        --X_CLEAR_STATION_ORG_ID  => l_curr_ue_rec.CLEAR_STATION_ORG_ID,
        --X_CLEAR_STATION_DEPT_ID => l_curr_ue_rec.CLEAR_STATION_DEPT_ID,
        X_UNIT_CONFIG_HEADER_ID => l_curr_ue_rec.UNIT_CONFIG_HEADER_ID,
        X_QA_COLLECTION_ID      => l_curr_ue_rec.QA_COLLECTION_ID,
        X_CS_INCIDENT_ID        => l_curr_ue_rec.CS_INCIDENT_ID,
        X_OBJECT_TYPE           => l_curr_ue_rec.OBJECT_TYPE,
        X_APPLICATION_USG_CODE  => l_curr_ue_rec.APPLICATION_USG_CODE,
        X_COUNTER_ID            => l_curr_ue_rec.COUNTER_ID,
        X_EARLIEST_DUE_DATE     => l_curr_ue_rec.EARLIEST_DUE_DATE,
        X_LATEST_DUE_DATE       => l_curr_ue_rec.LATEST_DUE_DATE,
        X_FORECAST_SEQUENCE     => l_curr_ue_rec.FORECAST_SEQUENCE,
        X_REPETITIVE_MR_FLAG    => l_curr_ue_rec.REPETITIVE_MR_FLAG,
        X_TOLERANCE_FLAG        => l_temp_tolerance_flag,                    -- Updated
        X_MESSAGE_CODE          => l_curr_ue_rec.MESSAGE_CODE,
        X_DATE_RUN              => l_curr_ue_rec.DATE_RUN,
        X_PRECEDING_UE_ID       => l_curr_ue_rec.PRECEDING_UE_ID,
        X_SET_DUE_DATE          => l_curr_ue_rec.SET_DUE_DATE,
        X_ACCOMPLISHED_DATE     => l_curr_ue_rec.ACCOMPLISHED_DATE,
        X_SERVICE_LINE_ID       => l_curr_ue_rec.SERVICE_LINE_ID,
        X_PROGRAM_MR_HEADER_ID  => l_curr_ue_rec.PROGRAM_MR_HEADER_ID,
        X_CANCEL_REASON_CODE    => l_curr_ue_rec.CANCEL_REASON_CODE,
        X_ATTRIBUTE_CATEGORY    => l_curr_ue_rec.ATTRIBUTE_CATEGORY,
        X_ATTRIBUTE1            => l_curr_ue_rec.ATTRIBUTE1,
        X_ATTRIBUTE2            => l_curr_ue_rec.ATTRIBUTE2,
        X_ATTRIBUTE3            => l_curr_ue_rec.ATTRIBUTE3,
        X_ATTRIBUTE4            => l_curr_ue_rec.ATTRIBUTE4,
        X_ATTRIBUTE5            => l_curr_ue_rec.ATTRIBUTE5,
        X_ATTRIBUTE6            => l_curr_ue_rec.ATTRIBUTE6,
        X_ATTRIBUTE7            => l_curr_ue_rec.ATTRIBUTE7,
        X_ATTRIBUTE8            => l_curr_ue_rec.ATTRIBUTE8,
        X_ATTRIBUTE9            => l_curr_ue_rec.ATTRIBUTE9,
        X_ATTRIBUTE10           => l_curr_ue_rec.ATTRIBUTE10,
        X_ATTRIBUTE11           => l_curr_ue_rec.ATTRIBUTE11,
        X_ATTRIBUTE12           => l_curr_ue_rec.ATTRIBUTE12,
        X_ATTRIBUTE13           => l_curr_ue_rec.ATTRIBUTE13,
        X_ATTRIBUTE14           => l_curr_ue_rec.ATTRIBUTE14,
        X_ATTRIBUTE15           => l_curr_ue_rec.ATTRIBUTE15,
        X_OBJECT_VERSION_NUMBER => l_curr_ue_rec.OBJECT_VERSION_NUMBER + 1,  -- Updated
        X_CSI_ITEM_INSTANCE_ID  => l_curr_ue_rec.CSI_ITEM_INSTANCE_ID,
        X_MR_HEADER_ID          => l_curr_ue_rec.MR_HEADER_ID,
        X_MR_EFFECTIVITY_ID     => l_curr_ue_rec.MR_EFFECTIVITY_ID,
        X_MR_INTERVAL_ID        => l_curr_ue_rec.MR_INTERVAL_ID,
        X_STATUS_CODE           => l_curr_ue_rec.STATUS_CODE,
        X_DUE_DATE              => p_new_due_date,                           -- Updated
        X_DUE_COUNTER_VALUE     => l_curr_ue_rec.DUE_COUNTER_VALUE,
        X_DEFER_FROM_UE_ID      => l_curr_ue_rec.DEFER_FROM_UE_ID,
        X_ORIG_DEFERRAL_UE_ID   => l_curr_ue_rec.ORIG_DEFERRAL_UE_ID,
        X_REMARKS               => l_curr_ue_rec.REMARKS,
        X_LAST_UPDATE_DATE      => SYSDATE,                                  -- Updated
        X_LAST_UPDATED_BY       => fnd_global.user_id,                       -- Updated
        X_LAST_UPDATE_LOGIN     => fnd_global.login_id                       -- Updated
    );
    l_temp_count := l_temp_count + 1;
  END LOOP;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Updated Due Date and Tolerance Flag in ' || l_temp_count|| ' dependent unit effectivities.');
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;
END Handle_MR_UE_Date_Change;

----------------------------------------
-- This Procedure updates the Unit Effectivity associated with the Service Request.
-- It updates the Status, Instance, Due Date and Tolerance Flag in response to updates in a SR
-- It returns two flags: The first flag indicated if the UE is assigned to a visit.
-- The second flag (which applies only if date has changed and only if assigned to a visit)
-- indicates if date tolerance has been exceeded (Visit Start Date vs. New UE Due Date)
----------------------------------------
PROCEDURE Update_SR_Unit_Effectivity(
   p_sr_ue_id                IN NUMBER,
   p_due_date_flag           IN BOOLEAN,
   p_new_due_date            IN DATE,
   p_instance_flag           IN BOOLEAN,
   p_new_instance_id         IN NUMBER,
   p_status_flag             IN BOOLEAN,
   p_new_status_code         IN VARCHAR2,
   x_assigned_to_visit_flag  OUT NOCOPY BOOLEAN,
   x_new_tolerance_flag      OUT NOCOPY VARCHAR2) IS

  CURSOR get_UE_dtls_csr IS
    SELECT * FROM AHL_UNIT_EFFECTIVITIES_APP_V
    WHERE UNIT_EFFECTIVITY_ID = p_sr_ue_id;

  CURSOR is_ue_assigned_to_visit_csr IS
    SELECT 'x' FROM AHL_VISIT_TASKS_B
    WHERE UNIT_EFFECTIVITY_ID = p_sr_ue_id;

  L_DEBUG_KEY CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Update_SR_Unit_Effectivity';

  l_temp_tolerance_flag AHL_UNIT_EFFECTIVITIES_B.TOLERANCE_FLAG%TYPE;
  l_temp_instance_id    NUMBER;
  l_temp_status_code    AHL_UNIT_EFFECTIVITIES_B.STATUS_CODE%TYPE;
  l_temp_due_date       DATE;
  l_curr_ue_rec         get_UE_dtls_csr%ROWTYPE;
  l_dummy               VARCHAR2(1);
  l_visit_start_date    DATE;
  l_visit_end_date      DATE;
  l_visit_assign_code   VARCHAR2(30);
  l_accomplished_date   DATE;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  OPEN get_UE_dtls_csr;
  FETCH get_UE_dtls_csr INTO l_curr_ue_rec;
  CLOSE get_UE_dtls_csr;

  IF (p_instance_flag = TRUE) THEN
    l_temp_instance_id := p_new_instance_id;
  ELSE
    l_temp_instance_id := l_curr_ue_rec.CSI_ITEM_INSTANCE_ID;
  END IF;

  l_accomplished_date := l_curr_ue_rec.ACCOMPLISHED_DATE;
  IF (p_status_flag = TRUE) THEN
    l_temp_status_code := p_new_status_code;
    -- JR: Added the following on 10/21/2003 to set the accomplished date for SR-CLOSED UEs
    IF (p_new_status_code = G_UMP_SR_CLOSED_STATUS) THEN
      l_accomplished_date := SYSDATE;
    END IF;
  ELSE
    l_temp_status_code := l_curr_ue_rec.STATUS_CODE;
  END IF;

  x_assigned_to_visit_flag := FALSE;
  x_new_tolerance_flag := null;
  IF (p_due_date_flag = TRUE) THEN
    l_temp_tolerance_flag := l_curr_ue_rec.TOLERANCE_FLAG;
    l_temp_due_date := p_new_due_date;
    OPEN is_ue_assigned_to_visit_csr;
    FETCH is_ue_assigned_to_visit_csr INTO l_dummy;
    IF (is_ue_assigned_to_visit_csr%FOUND) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Unit Effectivity ' || p_sr_ue_id || ' has been assigned to a visit.');
      END IF;
      x_assigned_to_visit_flag := TRUE;
      -- Get the Visit Start Date
      AHL_UMP_UTIL_PKG.Get_Visit_Details(p_unit_effectivity_id => p_sr_ue_id,
                                         x_visit_Start_date    => l_visit_start_date,
                                         x_visit_End_date      => l_visit_end_date,
                                         x_visit_Assign_code   => l_visit_assign_code);
      IF (p_new_due_date is not null and l_visit_start_date is not null and (l_visit_start_date > p_new_due_date)) THEN
        l_temp_tolerance_flag := G_YES_FLAG;
        x_new_tolerance_flag := G_YES_FLAG;
      ELSE
        l_temp_tolerance_flag := null;
      END IF;
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Visit Start Date: ' || l_visit_start_date ||
                                                             ', New Expected Resolution date of SR: ' || p_new_due_date ||
                                                             ', Tolerance Flag Set to ' || l_temp_tolerance_flag);
      END IF;
    ELSE
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Unit Effectivity ' || p_sr_ue_id || ' has not been assigned to a visit.');
      END IF;
    END IF;  -- Assigned to a visit or not
    CLOSE is_ue_assigned_to_visit_csr;
  ELSE
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'No Due Date change for Unit Effectivity ' || p_sr_ue_id);
    END IF;
    l_temp_due_date := l_curr_ue_rec.DUE_DATE;
    l_temp_tolerance_flag := l_curr_ue_rec.TOLERANCE_FLAG;
  END IF;

  -- Update the unit effectivity
  AHL_UNIT_EFFECTIVITIES_PKG.UPDATE_ROW(
        X_UNIT_EFFECTIVITY_ID   => l_curr_ue_rec.UNIT_EFFECTIVITY_ID,
        X_MANUALLY_PLANNED_FLAG => l_curr_ue_rec.MANUALLY_PLANNED_FLAG,
        X_LOG_SERIES_CODE       => l_curr_ue_rec.LOG_SERIES_CODE,
        X_LOG_SERIES_NUMBER     => l_curr_ue_rec.LOG_SERIES_NUMBER,
        X_FLIGHT_NUMBER         => l_curr_ue_rec.FLIGHT_NUMBER,
        X_MEL_CDL_TYPE_CODE     => l_curr_ue_rec.MEL_CDL_TYPE_CODE,
        X_POSITION_PATH_ID      => l_curr_ue_rec.POSITION_PATH_ID,
        X_ATA_CODE              => l_curr_ue_rec.ATA_CODE,
        --X_CLEAR_STATION_ORG_ID  => l_curr_ue_rec.CLEAR_STATION_ORG_ID,
        --X_CLEAR_STATION_DEPT_ID => l_curr_ue_rec.CLEAR_STATION_DEPT_ID,
        X_UNIT_CONFIG_HEADER_ID => l_curr_ue_rec.UNIT_CONFIG_HEADER_ID,
        X_QA_COLLECTION_ID      => l_curr_ue_rec.QA_COLLECTION_ID,
        X_CS_INCIDENT_ID        => l_curr_ue_rec.CS_INCIDENT_ID,
        X_OBJECT_TYPE           => l_curr_ue_rec.OBJECT_TYPE,
        X_APPLICATION_USG_CODE  => l_curr_ue_rec.APPLICATION_USG_CODE,
        X_COUNTER_ID            => l_curr_ue_rec.COUNTER_ID,
        X_EARLIEST_DUE_DATE     => l_curr_ue_rec.EARLIEST_DUE_DATE,
        X_LATEST_DUE_DATE       => l_curr_ue_rec.LATEST_DUE_DATE,
        X_FORECAST_SEQUENCE     => l_curr_ue_rec.FORECAST_SEQUENCE,
        X_REPETITIVE_MR_FLAG    => l_curr_ue_rec.REPETITIVE_MR_FLAG,
        X_TOLERANCE_FLAG        => l_temp_tolerance_flag,                    -- Updated
        X_MESSAGE_CODE          => l_curr_ue_rec.MESSAGE_CODE,
        X_DATE_RUN              => l_curr_ue_rec.DATE_RUN,
        X_PRECEDING_UE_ID       => l_curr_ue_rec.PRECEDING_UE_ID,
        X_SET_DUE_DATE          => l_curr_ue_rec.SET_DUE_DATE,
        X_ACCOMPLISHED_DATE     => l_accomplished_date,                      -- Updated
        X_SERVICE_LINE_ID       => l_curr_ue_rec.SERVICE_LINE_ID,
        X_PROGRAM_MR_HEADER_ID  => l_curr_ue_rec.PROGRAM_MR_HEADER_ID,
        X_CANCEL_REASON_CODE    => l_curr_ue_rec.CANCEL_REASON_CODE,
        X_ATTRIBUTE_CATEGORY    => l_curr_ue_rec.ATTRIBUTE_CATEGORY,
        X_ATTRIBUTE1            => l_curr_ue_rec.ATTRIBUTE1,
        X_ATTRIBUTE2            => l_curr_ue_rec.ATTRIBUTE2,
        X_ATTRIBUTE3            => l_curr_ue_rec.ATTRIBUTE3,
        X_ATTRIBUTE4            => l_curr_ue_rec.ATTRIBUTE4,
        X_ATTRIBUTE5            => l_curr_ue_rec.ATTRIBUTE5,
        X_ATTRIBUTE6            => l_curr_ue_rec.ATTRIBUTE6,
        X_ATTRIBUTE7            => l_curr_ue_rec.ATTRIBUTE7,
        X_ATTRIBUTE8            => l_curr_ue_rec.ATTRIBUTE8,
        X_ATTRIBUTE9            => l_curr_ue_rec.ATTRIBUTE9,
        X_ATTRIBUTE10           => l_curr_ue_rec.ATTRIBUTE10,
        X_ATTRIBUTE11           => l_curr_ue_rec.ATTRIBUTE11,
        X_ATTRIBUTE12           => l_curr_ue_rec.ATTRIBUTE12,
        X_ATTRIBUTE13           => l_curr_ue_rec.ATTRIBUTE13,
        X_ATTRIBUTE14           => l_curr_ue_rec.ATTRIBUTE14,
        X_ATTRIBUTE15           => l_curr_ue_rec.ATTRIBUTE15,
        X_OBJECT_VERSION_NUMBER => l_curr_ue_rec.OBJECT_VERSION_NUMBER + 1,  -- Updated
        X_CSI_ITEM_INSTANCE_ID  => l_temp_instance_id,
        X_MR_HEADER_ID          => l_curr_ue_rec.MR_HEADER_ID,
        X_MR_EFFECTIVITY_ID     => l_curr_ue_rec.MR_EFFECTIVITY_ID,
        X_MR_INTERVAL_ID        => l_curr_ue_rec.MR_INTERVAL_ID,
        X_STATUS_CODE           => l_temp_status_code,                       -- Updated
        X_DUE_DATE              => l_temp_due_date,                          -- Updated
        X_DUE_COUNTER_VALUE     => l_curr_ue_rec.DUE_COUNTER_VALUE,
        X_DEFER_FROM_UE_ID      => l_curr_ue_rec.DEFER_FROM_UE_ID,
        X_ORIG_DEFERRAL_UE_ID   => l_curr_ue_rec.ORIG_DEFERRAL_UE_ID,
        X_REMARKS               => l_curr_ue_rec.REMARKS,
        X_LAST_UPDATE_DATE      => SYSDATE,                                  -- Updated
        X_LAST_UPDATED_BY       => fnd_global.user_id,                       -- Updated
        X_LAST_UPDATE_LOGIN     => fnd_global.login_id                       -- Updated
  );
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Unit Effectivity ' || p_sr_ue_id || ' has been updated.');
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;
END Update_SR_Unit_Effectivity;

----------------------------------------
-- This Procedure validates the Service Request during the Post Update process.
-- It retrieves some information as part of the validation process to be used by subsequent routines
----------------------------------------
PROCEDURE Validate_Request_For_Update(
   x_sr_ue_id                OUT NOCOPY NUMBER,
   x_sr_ue_ovn               OUT NOCOPY NUMBER,
   x_defer_from_ue_id        OUT NOCOPY NUMBER) IS

  CURSOR check_request_exists_csr IS
    SELECT 'x' FROM CS_INCIDENTS
    WHERE INCIDENT_ID = CS_SERVICEREQUEST_PVT.user_hooks_rec.request_id;

  CURSOR get_ue_dtls_csr IS
    SELECT UNIT_EFFECTIVITY_ID, OBJECT_VERSION_NUMBER, DEFER_FROM_UE_ID
    FROM AHL_UNIT_EFFECTIVITIES_APP_V
    WHERE CS_INCIDENT_ID = CS_SERVICEREQUEST_PVT.user_hooks_rec.request_id
      AND (STATUS_CODE IS NULL OR STATUS_CODE NOT IN (G_UMP_DEFERRED_STATUS, G_UMP_EXCEPTION_STATUS));

  L_DEBUG_KEY CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Validate_Request_For_Update';

  l_dummy              VARCHAR2(1);

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  -- Ensure that request id is not null
  IF(CS_SERVICEREQUEST_PVT.user_hooks_rec.request_id IS NULL) THEN
    FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_REQ_ID_NULL');
    FND_MSG_PUB.ADD;
    IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Ensure that the request id is valid
  OPEN check_request_exists_csr;
  FETCH check_request_exists_csr INTO l_dummy;
  IF(check_request_exists_csr%NOTFOUND) THEN
    CLOSE check_request_exists_csr;
    FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_REQ_ID_INVALID');
    FND_MESSAGE.Set_Token('REQ_ID', CS_SERVICEREQUEST_PVT.user_hooks_rec.request_id);
    FND_MSG_PUB.ADD;
    IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  CLOSE check_request_exists_csr;

  -- If already a CMRO SR, ensure that an unit effectivity exists for the SR
  IF (NVL(CS_SERVICEREQUEST_PVT.user_hooks_rec.old_type_cmro_flag, G_NO_FLAG) = G_YES_FLAG) THEN
    -- apattark added x_defer_from_ue_id for bug #9166304
    OPEN get_ue_dtls_csr;
    FETCH get_ue_dtls_csr INTO x_sr_ue_id, x_sr_ue_ovn, x_defer_from_ue_id;
    IF (get_ue_dtls_csr%NOTFOUND) THEN
      CLOSE get_ue_dtls_csr;
      FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_REQ_ID_INVALID');
      FND_MESSAGE.Set_Token('REQ_ID', CS_SERVICEREQUEST_PVT.user_hooks_rec.request_id);
      FND_MSG_PUB.ADD;
      IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
      END IF;
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Could not find any valid Unit Effectivity for this CS_INCIDENT_ID: ' || CS_SERVICEREQUEST_PVT.user_hooks_rec.request_id);
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;  -- UE Not Found
    CLOSE get_ue_dtls_csr;
  END IF;  -- CMRO Type SR

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;

END Validate_Request_For_Update;

----------------------------------------
-- This Procedure handles type (CMRO to Non-CMRO and vice-versa) changes to a SR
----------------------------------------
PROCEDURE Handle_Type_Change(
   p_sr_ue_id         IN NUMBER,
   p_defer_from_ue_id IN NUMBER) IS

  CURSOR get_tasks_for_ue_csr IS
    SELECT 'x' from AHL_VISIT_TASKS_B
    WHERE UNIT_EFFECTIVITY_ID = p_sr_ue_id;

  CURSOR get_all_ue_and_rel_ids_csr IS
    SELECT UE_RELATIONSHIP_ID, RELATED_UE_ID, LEVEL
    FROM AHL_UE_RELATIONSHIPS
    WHERE originator_ue_id = p_sr_ue_id
    START WITH UE_ID = p_sr_ue_id
    CONNECT BY PRIOR RELATED_UE_ID = UE_ID
    ORDER BY LEVEL DESC;  /* Bottom Up ordering*/

  L_DEBUG_KEY CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Handle_Type_Change';

  l_dummy              VARCHAR2(1);
  l_temp_return_status VARCHAR2(1);

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  -- Ensure that the SR is not closed
  IF (CS_SERVICEREQUEST_PVT.user_hooks_rec.status_flag = G_SR_CLOSED_FLAG) THEN
    FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_REQ_CLOSED');
    FND_MSG_PUB.ADD;
    IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (NVL(CS_SERVICEREQUEST_PVT.user_hooks_rec.new_type_cmro_flag, G_NO_FLAG) = G_NO_FLAG) THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'CMRO to Non-CMRO type conversion');
    END IF;
    -- CMRO to Non-CMRO type
    -- apattark start changes for bug #9166304
    IF (p_defer_from_ue_id IS NOT NULL) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'UE was deferred.');
      END IF;
      FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_REQ_DEFERRED');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- apattark end changes for bug #9166304
    -- JR: Modified on 10/29/2003 (Using Status Id instead of Status Code)
    IF (CS_SERVICEREQUEST_PVT.user_hooks_rec.status_id = G_SR_PLANNED_STATUS_ID) THEN
      OPEN get_tasks_for_ue_csr;
      FETCH get_tasks_for_ue_csr INTO l_dummy;
      IF (get_tasks_for_ue_csr%FOUND) THEN
        FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_ASGND_TO_VISIT');
        FND_MSG_PUB.ADD;
        IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
        END IF;
      ELSE
        -- This condition of a (originally) CMRO SR in Planned Status but not associated
        -- to a visit is not possible
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Odd case of originally CMRO type SR in Planned status but not assigned to a visit');
        END IF;
        FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_REQ_PLANNED');
        FND_MSG_PUB.ADD;
      END IF;  -- tasks found
      CLOSE get_tasks_for_ue_csr;
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      -- Not yet Planned, but open
      -- Delete all the dependent UEs and UE relationships
      FOR rel_and_ue_id_rec in get_all_ue_and_rel_ids_csr LOOP
        -- First delete the relationship
        AHL_UE_RELATIONSHIPS_PKG.DELETE_ROW(X_UE_RELATIONSHIP_ID => rel_and_ue_id_rec.UE_RELATIONSHIP_ID);
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Deleted Relationship with UE_RELATIONSHIP_ID = ' || rel_and_ue_id_rec.UE_RELATIONSHIP_ID);
        END IF;
        -- Next delete the unit effectivity
        AHL_UNIT_EFFECTIVITIES_PKG.DELETE_ROW(X_UNIT_EFFECTIVITY_ID => rel_and_ue_id_rec.RELATED_UE_ID);
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Deleted Unit Effectivity with UNIT_EFFECTIVITY_ID = ' || rel_and_ue_id_rec.RELATED_UE_ID);
        END IF;
      END LOOP;

      -- Delete the SR's Unit Effectivity
      AHL_UNIT_EFFECTIVITIES_PKG.DELETE_ROW(X_UNIT_EFFECTIVITY_ID => p_sr_ue_id);
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Deleted Unit Effectivity with UNIT_EFFECTIVITY_ID = ' || p_sr_ue_id);
      END IF;
    END IF;  -- Planned or Not
  ELSE
    -- Non-CMRO to CMRO type
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Non-CMRO to CMRO type conversion');
    END IF;
    IF (CS_SERVICEREQUEST_PVT.user_hooks_rec.status_id = G_SR_PLANNED_STATUS_ID) THEN
      FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_REQ_PLANNED');
      FND_MSG_PUB.ADD;
      IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      -- Not yet Planned, but open: Call Create_SR_Init_Effectivity
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'About to call Create_SR_Unit_Effectivity.');
      END IF;
      Create_SR_Unit_Effectivity(x_return_status => l_temp_return_status);
      /* For Testing
      UMP_SR_TEST.Create_SR_Unit_Effectivity(x_return_status => l_temp_return_status);
      */
      IF (l_temp_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Create_SR_Unit_Effectivity Returned Success.');
        END IF;
      ELSIF (l_temp_return_status = FND_API.G_RET_STS_ERROR) THEN
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Create_SR_Unit_Effectivity Returned User Error.');
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Create_SR_Unit_Effectivity Returned Unexpected Error.');
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF; -- Planned or not
  END IF;  -- CMRO to Non-CMRO or vice-versa

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;

END Handle_Type_Change;

----------------------------------------
-- This Procedure handles other attribute (Instance, Resolution Date and Status) changes to a SR
----------------------------------------
PROCEDURE Handle_Attribute_Changes(
   p_sr_ue_id IN NUMBER) IS
  --apattark added DEFER_FROM_UE_ID to check if it is null
  CURSOR get_and_lock_ue_dtls_csr IS
    SELECT CSI_ITEM_INSTANCE_ID, DUE_DATE, STATUS_CODE, DEFER_FROM_UE_ID from AHL_UNIT_EFFECTIVITIES_B
    WHERE UNIT_EFFECTIVITY_ID = p_sr_ue_id
    FOR UPDATE NOWAIT;

  L_DEBUG_KEY CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Handle_Attribute_Changes';

  l_instance_changed   BOOLEAN := false;
  l_due_date_changed   BOOLEAN := false;
  l_status_changed     BOOLEAN := false;
  l_old_instance       NUMBER;
  l_old_due_date       DATE;
  l_old_status         AHL_UNIT_EFFECTIVITIES_B.STATUS_CODE%TYPE;
  l_valid_flag         BOOLEAN := true;
  l_new_instance       NUMBER := CS_SERVICEREQUEST_PVT.USER_HOOKS_REC.customer_product_id;
  l_new_ue_status      AHL_UNIT_EFFECTIVITIES_B.STATUS_CODE%TYPE;
  l_new_due_date       DATE := CS_SERVICEREQUEST_PVT.USER_HOOKS_REC.exp_resolution_date;
  l_assigned           BOOLEAN;
  l_new_tolerance_flag VARCHAR2(1);
  --apattark added for bug #9166304
  l_defer_from_ue_id   NUMBER;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  -- Get the original (old) values and lock the row
  OPEN get_and_lock_ue_dtls_csr;  -- Will throw exception (ORA-00054) if cannot acquire lock
  FETCH get_and_lock_ue_dtls_csr into l_old_instance, l_old_due_date, l_old_status, l_defer_from_ue_id;
  CLOSE get_and_lock_ue_dtls_csr;

   -- Handle Instance Changes
  Handle_Instance_Change(p_sr_ue_id         => p_sr_ue_id,
                         p_old_instance_id  => l_old_instance,
                         p_x_valid_flag     => l_valid_flag,
                         x_instance_changed => l_instance_changed,
			 p_defer_from_ue_id => l_defer_from_ue_id);

  -- Handle Status Change
  Handle_Status_Change(p_sr_ue_id       => p_sr_ue_id,
                       p_old_ue_status  => l_old_status,
                       p_x_valid_flag   => l_valid_flag,
                       x_status_changed => l_status_changed,
                       x_new_ue_status  => l_new_ue_status);

  -- Handle Expected Resolution Date (Due Date) Change
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_old_due_date = ' || l_old_due_date || ', l_new_due_date = ' || l_new_due_date);
  END IF;
  --apattark added condition to check defer from ue id
  IF(l_defer_from_ue_id IS NULL) THEN
    IF((l_old_due_date IS NOT NULL AND l_new_due_date IS NULL) OR
      (l_old_due_date IS NULL AND l_new_due_date IS NOT NULL) OR
      (l_old_due_date IS NOT NULL AND l_new_due_date IS NOT NULL AND l_old_due_date <> l_new_due_date)) THEN
    -- Date has changed
      IF (l_old_status IS NULL OR l_old_status <> G_UMP_DEFERRED_STATUS) THEN
      -- Unit Effectivity has not been deferred: uptake
      l_due_date_changed := true;
      END IF;
    END IF;
  END IF;

  IF (l_valid_flag = false) THEN
    -- At least one Validation has failed: No need to do any further processing
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (l_instance_changed = true OR l_status_changed = true OR l_due_date_changed = true) THEN
    -- Apply changes to the SR Unit Effectivity
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Changes have happened.');
      IF (l_instance_changed = true) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_instance_changed = Y');
      ELSE
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_instance_changed = N');
      END IF;
      IF (l_status_changed = true) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_status_changed = Y');
      ELSE
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_status_changed = N');
      END IF;
      IF (l_due_date_changed = true) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_due_date_changed = Y');
      ELSE
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_due_date_changed = N');
      END IF;
    END IF;
    Update_SR_Unit_Effectivity(p_sr_ue_id               => p_sr_ue_id,
                               p_due_date_flag          => l_due_date_changed,
                               p_new_due_date           => l_new_due_date,
                               p_instance_flag          => l_instance_changed,
                               p_new_instance_id        => l_new_instance,
                               p_status_flag            => l_status_changed,
                               p_new_status_code        => l_new_ue_status,
                               x_assigned_to_visit_flag => l_assigned,
                               x_new_tolerance_flag     => l_new_tolerance_flag);

    IF (l_due_date_changed = true) THEN
      -- Propagate Due Date changes to the UEs of all associated MRs
      Handle_MR_UE_Date_Change(p_sr_ue_id               => p_sr_ue_id,
                               p_assigned_to_visit_flag => l_assigned,
                               p_new_tolerance_flag     => l_new_tolerance_flag,
                               p_new_due_date           => l_new_due_date);
    END IF;
  ELSE
    -- No Changes to Update
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'No change to instance, due date or status');
    END IF;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;

  -- Call this API to Sync up SR summary updates with Workorder Description
  Handle_Summary_Update(
   p_sr_ue_id          => p_sr_ue_id
  );

END Handle_Attribute_Changes;

----------------------------------------
-- This Procedure handles the change in the item instance (customer product) of the Service Request
----------------------------------------
PROCEDURE Handle_Instance_Change(
   p_sr_ue_id          IN NUMBER,
   p_old_instance_id   IN NUMBER,
   p_x_valid_flag      IN OUT NOCOPY BOOLEAN,  -- This flag will never be set to true in this procedure
   x_instance_changed  OUT NOCOPY BOOLEAN,
   p_defer_from_ue_id  IN NUMBER) IS

  CURSOR get_rel_count_csr IS
    SELECT COUNT(*) FROM AHL_UE_RELATIONSHIPS
    WHERE UE_ID = p_sr_ue_id;

  L_DEBUG_KEY CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Handle_Instance_Change';

  l_temp_count NUMBER := 0;
  l_new_instance_id NUMBER := CS_SERVICEREQUEST_PVT.USER_HOOKS_REC.customer_product_id;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'p_old_instance_id = ' || p_old_instance_id || ', l_new_instance_id = ' || l_new_instance_id);
  END IF;
  -- Initialize the Instance Changed Flag to false
  x_instance_changed := false;

  IF (l_new_instance_id IS NULL) THEN
    p_x_valid_flag := false;
    FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_INST_NULL');
    FND_MSG_PUB.ADD;
    IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
    END IF;
  ELSIF (l_new_instance_id <> p_old_instance_id) THEN
    -- Instance has changed: Validate
    --apattark begin changes for bug #9166304
    IF (p_defer_from_ue_id IS NOT NULL) THEN
      p_x_valid_flag := false;
      FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_INST_CHG_DEFERRED');
      FND_MSG_PUB.ADD;
      IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
      END IF;
    END IF;
    --apattark end changes for bug #9166304
    IF (CS_SERVICEREQUEST_PVT.USER_HOOKS_REC.status_flag = G_SR_CLOSED_FLAG) THEN
      p_x_valid_flag := false;
      FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_INST_CHG_CLOSED');
      FND_MSG_PUB.ADD;
      IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
      END IF;

    ELSIF (CS_SERVICEREQUEST_PVT.user_hooks_rec.status_id = G_SR_PLANNED_STATUS_ID) THEN
      p_x_valid_flag := false;
      FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_INST_CHG_PLANNED');
      FND_MSG_PUB.ADD;
      IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
      END IF;
    ELSE
      OPEN get_rel_count_csr;
      FETCH get_rel_count_csr INTO l_temp_count;
      CLOSE get_rel_count_csr;
      IF (l_temp_count > 0) THEN
        p_x_valid_flag := false;
        FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_INST_CHG_HAS_MRS');
        FND_MSG_PUB.ADD;
        IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
        END IF;
      ELSE
        -- All validations passed
        x_instance_changed := true;
        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY, 'Instance has changed from ' || p_old_instance_id || ' to ' || l_new_instance_id || '. All instance validations have succeeded.');
        END IF;
      END IF;  -- Status Check
    END IF;  -- Old <> New Check
  END IF;  -- New Instance Null Check

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;

END Handle_Instance_Change;

----------------------------------------
-- This Procedure handles the change in the status of the Service Request
----------------------------------------
PROCEDURE Handle_Status_Change(
   p_sr_ue_id        IN NUMBER,
   p_old_ue_status   IN AHL_UNIT_EFFECTIVITIES_B.STATUS_CODE%TYPE,
   p_x_valid_flag    IN OUT NOCOPY BOOLEAN,  -- This flag will never be set to true in this procedure
   x_status_changed  OUT NOCOPY BOOLEAN,
   x_new_ue_status   OUT NOCOPY AHL_UNIT_EFFECTIVITIES_B.STATUS_CODE%TYPE) IS

  CURSOR get_tasks_for_ue_csr IS
    SELECT 'x' from AHL_VISIT_TASKS_B
    where UNIT_EFFECTIVITY_ID = p_sr_ue_id;

  CURSOR get_rel_count_csr IS
    SELECT COUNT(*) FROM AHL_UE_RELATIONSHIPS
    WHERE UE_ID = p_sr_ue_id;

  L_DEBUG_KEY CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Handle_Status_Change';

  l_temp_count NUMBER := 0;
  l_dummy      VARCHAR2(1);
  l_assigned   BOOLEAN;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;
  -- Initialize the Status Changed Flag to false
  x_status_changed := false;

  IF (CS_SERVICEREQUEST_PVT.USER_HOOKS_REC.status_flag = G_SR_CLOSED_FLAG) THEN
    -- SR is or is being Closed
    OPEN get_tasks_for_ue_csr;
    FETCH get_tasks_for_ue_csr INTO l_dummy;
    IF(get_tasks_for_ue_csr%FOUND) THEN
      -- SR UE Assigned to a visit
      IF (p_old_ue_status IS NULL OR (p_old_ue_status NOT IN (G_UMP_ACCOMPLISHED_STATUS, G_UMP_TERMINATED_STATUS, G_UMP_MR_TERMINATE_STATUS))) THEN
        -- UE Neither accomplished nor terminated
        p_x_valid_flag := false;
        FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_TASK_NOT_ACC');
        FND_MSG_PUB.ADD;
        IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
        END IF;
      ELSE
        -- Unit Effectivities already accomplished: No impact on UMP, Allow the SR to be closed.
        null;
      END IF;  -- UE accomplished or terminated Status check
    ELSE
      -- Not assigned to any Visit: Check if MRs are associated
      OPEN get_rel_count_csr;
      FETCH get_rel_count_csr INTO l_temp_count;
      CLOSE get_rel_count_csr;
      IF (l_temp_count > 0) THEN
        -- SR has associated MRs, but the SR UE has not been assigned to any visit.
        p_x_valid_flag := false;
        FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_MRS_NOT_ACC');
        FND_MSG_PUB.ADD;
        IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
        END IF;
      ELSE
        -- No associated MRs
        IF ((p_old_ue_status IS NULL) OR (p_old_ue_status <> G_UMP_SR_CLOSED_STATUS)) THEN
          x_status_changed := true;
          x_new_ue_status := G_UMP_SR_CLOSED_STATUS;
        ELSE
          -- Already Closed: No need to update UE.
          null;
        END IF;  -- Old UE Status is SR-CLOSED or not
      END IF;  -- Has associated MRs or not
    END IF;  -- SR UE assigned to a visit or not
    CLOSE get_tasks_for_ue_csr;
  ELSE
    -- SR is Open
    -- JR: Added the following check on 10/21/2003 to prevent
    -- reopening an SR whose UE is already SR_CLOSED
    IF (p_old_ue_status = G_UMP_SR_CLOSED_STATUS) THEN
      -- Attempting to open an SR whose UE is already SR_CLOSED.
      p_x_valid_flag := false;
      FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_UE_SR_CLSD');
      FND_MSG_PUB.ADD;
      IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
      END IF;
    ELSE
      OPEN get_tasks_for_ue_csr;
      FETCH get_tasks_for_ue_csr INTO l_dummy;
      IF(get_tasks_for_ue_csr%FOUND) THEN
        l_assigned := true;
      ELSE
        l_assigned := false;
      END IF;
      CLOSE get_tasks_for_ue_csr;
      IF (CS_SERVICEREQUEST_PVT.user_hooks_rec.status_id = G_SR_PLANNED_STATUS_ID) THEN
        IF (l_assigned = false) THEN
          -- SR is being moved to Planned status without assigning SR UE to any visit
          p_x_valid_flag := false;
          FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_NOT_ASSND');
          FND_MSG_PUB.ADD;
          IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
          END IF;
        END IF;  -- Not assigned
      ELSE
        IF (l_assigned = true) THEN
          -- SR is being moved to a not-planned status while SR UE has already been assigned to a visit
          p_x_valid_flag := false;
          FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_SR_ALREADY_ASSND');
          FND_MSG_PUB.ADD;
          IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
          END IF;
        END IF;  -- Already Assigned
      END IF;  -- SR is in Planned Status or Not
    END IF;  -- Old UE Status SR-CLOSED or not
  END IF;  -- If SR is Closed or not

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;

END Handle_Status_Change;

--------------------------------------------------------------------------------
-- This Procedure Updates WO Description if corresponding SR Summary changes.
-- Happens only for following cases
-- 1. Non-Routines(NR) created on the shop floor.
-- 2. Non-Routines with no MRs associated and planned from UMP into a Visit.
--------------------------------------------------------------------------------
PROCEDURE Handle_Summary_Update(
   p_sr_ue_id              IN            NUMBER
)IS

--Check if the SR fits in any of below conditions
-- 1. Non-Routines(NR) created on the shop floor.
-- 2. Non-Routines with no MRs associated and planned from UMP into a Visit.

--Get Corresponding NR Workorders for the given SR Ue id.
CURSOR c_get_ue_wo(p_sr_ue_id IN NUMBER)
IS
SELECT
  WO.workorder_id,
  WIPJ.description,
  VTSK.visit_task_number,
  VST.visit_number
FROM
  AHL_WORKORDERS WO,
  WIP_DISCRETE_JOBS WIPJ,
  AHL_VISIT_TASKS_B VTSK,
  AHL_VISITS_B VST,
  AHL_UNIT_EFFECTIVITIES_B UE
WHERE
  WO.status_code not in (4,12,7,5) AND -- Completed/Closed/Cancelled/Completed_No_Charge
  WO.wip_entity_id = WIPJ.wip_entity_id AND
  WO.visit_task_id = VTSK.visit_task_id AND
  WO.visit_id = VST.visit_id AND
  VTSK.unit_effectivity_id = UE.Unit_effectivity_id AND
  UE.Unit_effectivity_id = p_sr_ue_id AND
  UE.manually_planned_flag = 'Y' AND
  UE.cs_incident_id IS NOT NULL AND
  NOT EXISTS (SELECT
                 'X'
              FROM
                  AHL_UE_RELATIONSHIPS UER
              WHERE
                  UER.related_ue_id = UE.Unit_effectivity_id OR
                  UER.ue_id = UE.Unit_effectivity_id);


--Get Summary corresponding to SR UE.
CURSOR c_get_SR_details(p_sr_ue_id IN NUMBER)
IS
SELECT
  CSIA.summary,
  CSIT.name -- incident type name.
FROM
  CS_INCIDENTS_ALL CSIA,
  CS_INCIDENT_TYPES_VL CSIT,
  AHL_UNIT_EFFECTIVITIES_B UE
WHERE
  UE.unit_effectivity_id = p_sr_ue_id AND
  CSIA.incident_id = ue.cs_incident_id AND
  CSIT.incident_type_id = CSIA.incident_type_id;


-- declare all local variables for the procedure.
l_return_status       VARCHAR2(1);
l_msg_count           NUMBER;
l_msg_data            VARCHAR2(40);
l_sr_summary          VARCHAR2(240);
l_sr_type             VARCHAR2(30);
l_wo_description      VARCHAR2(240);
l_count               NUMBER;
--l_exists              VARCHAR2(1);
l_prd_workorder_tbl   AHL_PRD_WORKORDER_PVT.PRD_WORKORDER_TBL;
l_prd_workorder_rel_tbl AHL_PRD_WORKORDER_PVT.PRD_WORKORDER_REL_TBL;

L_DEBUG_KEY           CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Handle_Summary_Update';

BEGIN

       l_count := 1;

       IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(
                         FND_LOG.LEVEL_STATEMENT,
                         L_DEBUG_KEY,
                         'Entering the procedure Handle_Summary_Update ..'
                        );
       END IF;

        -- Check if the SR is one of the following
        -- 1. Non-Routines(NR) created on the shop floor.
        -- 2. Non-Routines with no MRs associated and planned from UMP into a Visit.
        --OPEN c_check_SR_rel(p_sr_ue_id);
        --FETCH c_check_SR_rel INTO l_exists;
        --CLOSE c_check_SR_rel;

        -- Manually fetching the SR Summary from UE table because SR doesnt
        OPEN c_get_SR_details(p_sr_ue_id);
        FETCH c_get_SR_details INTO l_sr_summary, l_sr_type;
        CLOSE c_get_SR_details;
        --l_sr_summary := CS_SERVICEREQUEST_PVT.USER_HOOKS_REC.summary;
	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

	    FND_LOG.STRING(
			   FND_LOG.LEVEL_STATEMENT,
			   L_DEBUG_KEY,
			   'l_sr_summary -->'||l_sr_summary
			  );
	    FND_LOG.STRING(
			   FND_LOG.LEVEL_STATEMENT,
			   L_DEBUG_KEY,
			   'l_sr_type -->'||l_sr_type
			  );

	END IF;

	--Concatenate SR summary and SR type to be of size <= 240 chars
	--since workorder description is of size 240 chars.
	l_wo_description := SUBSTRB(l_sr_type || ' - ' ||l_sr_summary, 1, 240);

        -- Get the workorders for SR if it exists.
        FOR ue_wo_rec IN c_get_ue_wo(p_sr_ue_id)
        LOOP
           IF ue_wo_rec.description <> l_wo_description THEN
	      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		   FND_LOG.STRING(
			   FND_LOG.LEVEL_STATEMENT,
			   L_DEBUG_KEY,
			   'ue_wo_rec.workorder_id -->'||ue_wo_rec.workorder_id
			  );
	      END IF;
              l_prd_workorder_tbl(l_count).batch_id          := ue_wo_rec.visit_number;
              l_prd_workorder_tbl(l_count).header_id         := ue_wo_rec.visit_task_number;
              l_prd_workorder_tbl(l_count).workorder_id      := ue_wo_rec.workorder_id;
              l_prd_workorder_tbl(l_count).job_description   := l_wo_description;
              l_prd_workorder_tbl(l_count).dml_operation     := 'U';
              l_count := l_count + 1;
	   END IF;
        END LOOP;

        IF l_prd_workorder_tbl.COUNT > 0
        THEN
           -- Update the workorders
           AHL_PRD_WORKORDER_PVT.Process_Jobs
           (
            p_api_version          => 1.0,
            p_init_msg_list        => FND_API.G_FALSE,
            p_commit               => FND_API.G_FALSE,
            p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
            p_default              => FND_API.G_TRUE,
            p_module_type          => 'API',
            x_return_status        => l_return_status,
            x_msg_count            => l_msg_count,
            x_msg_data             => l_msg_data,
            p_x_prd_workorder_tbl  => l_prd_workorder_tbl,
            p_prd_workorder_rel_tbl=> l_prd_workorder_rel_tbl
            );

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS
            THEN
               RAISE FND_API.G_EXC_ERROR;
               IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
               END IF;
            END IF;
        END IF;

       IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(
                         FND_LOG.LEVEL_STATEMENT,
                         L_DEBUG_KEY,
                         'Exiting the procedure Handle_Summary_Update ..'
                        );
       END IF;
END Handle_Summary_Update;

-------------------------------------
-- End Local Procedure Definitions --
-------------------------------------

END AHL_UMP_SR_PVT;

/
